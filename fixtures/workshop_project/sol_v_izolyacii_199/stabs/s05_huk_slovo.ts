// ОБМАННЫЙ СТАБ s05 «страж спавна выводит isolated из текста задания»:
// флаг события подменяется словом isolated:true внутри task. Различающий
// вход батареи: h2 — item.isolated=false при слове isolated:true в тексте;
// честный страж записывает false, стаб — true.
import { existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const CFG_PATH = join(HERE, '..', '..', 'config', 'agent_models.json');
const DOOR_PATH = join(HERE, '..', '..', 'scripts', 'zamok_predmeta.sh');

function isObject(v: unknown): v is Record<string, unknown> {
  return v !== null && typeof v === 'object';
}
function loadAlphabet(): ReadonlySet<string> {
  const cfg = JSON.parse(readFileSync(CFG_PATH, 'utf8')) as { roles?: Record<string, unknown> };
  if (!cfg.roles) throw new Error('нет roles');
  return new Set(Object.keys(cfg.roles));
}
// ДЕФЕКТ СТАБА: isolated — из текста task, не из поля item.
type TaskItem = { agent: string; name: string; task: string; isolated: boolean };
function taskItems(input: unknown): TaskItem[] {
  const raw: unknown[] =
    isObject(input) && 'tasks' in input && Array.isArray(input.tasks)
      ? (input.tasks as unknown[])
      : [input];
  const out: TaskItem[] = [];
  for (const item of raw) {
    const o = isObject(item) ? item : {};
    const task = typeof o.task === 'string' ? o.task : '';
    out.push({
      agent: typeof o.agent === 'string' ? o.agent : '',
      name: typeof o.name === 'string' ? o.name : '',
      task,
      isolated: /isolated:true/.test(task),
    });
  }
  return out;
}
function firstLine(text: string): string {
  for (const line of text.split('\n')) {
    const t = line.trim();
    if (t.length > 0) return t;
  }
  return '';
}
type Roots = { sost: string; zhurnaly: string };
function stateRoots(sessionFile: string): Roots | null {
  const m = /^(.*\/agent\/sessions)\//.exec(sessionFile);
  if (m === null) return null;
  const z = sessionFile.indexOf('/zones/');
  if (z > 0) return { sost: sessionFile.slice(0, z), zhurnaly: m[1] };
  return null;
}
type PiLike = { on?: (name: string, handler: (...args: unknown[]) => unknown) => unknown };
export default function register(pi: unknown): void {
  if (!isObject(pi)) return;
  const p = pi as PiLike;
  if (typeof p.on !== 'function') return;
  p.on('tool_call', (call: unknown, ctx: unknown) => {
    try {
      if (!isObject(call)) return undefined;
      if (call.toolName !== 'task') return undefined;
      let alphabet: ReadonlySet<string>;
      try {
        alphabet = loadAlphabet();
      } catch {
        return { block: true, reason: `ОТКАЗ: конфиг установленного харнеса не читается: ${CFG_PATH}` };
      }
      const items = taskItems(call.input);
      for (const it of items) {
        if (!alphabet.has(it.agent)) {
          return { block: true, reason: `ОТКАЗ: тип агента вне алфавита: ${it.agent}` };
        }
      }
      const sm = isObject(ctx) ? ctx.sessionManager : null;
      const sf = isObject(sm) && typeof sm.getSessionFile === 'function' ? sm.getSessionFile() : null;
      const sessionFile = typeof sf === 'string' ? sf : null;
      if (sessionFile === null) {
        if (existsSync(DOOR_PATH)) {
          return { block: true, reason: 'ОТКАЗ: страж замка сломан (fail-closed): нет живого контекста сессии' };
        }
        return undefined;
      }
      const roots = stateRoots(sessionFile);
      if (roots === null) {
        return { block: true, reason: 'ОТКАЗ: страж замка сломан (fail-closed): файл сессии вне грамматики' };
      }
      const eventFile = join(
        roots.sost,
        `.zamok140-event-${process.pid}-${Math.random().toString(36).slice(2)}.json`,
      );
      try {
        mkdirSync(join(roots.sost, 'zamok'), { recursive: true });
        writeFileSync(eventFile, JSON.stringify({ tasks: taskItems(call.input) }), 'utf8');
        const r = spawnSync(
          'bash',
          [DOOR_PATH, '--sudit', '--sostojanie', join(roots.sost, 'zamok'), '--zhurnaly', roots.zhurnaly, '--repo', process.cwd(), eventFile],
          { encoding: 'utf8' },
        );
        if (r.error !== undefined || r.signal !== null || r.status === null) {
          return { block: true, reason: 'ОТКАЗ: страж замка сломан (fail-closed): дверь не исполнена' };
        }
        if (r.status === 0) return undefined;
        if (r.status === 1) {
          const prichina = firstLine(r.stderr ?? '');
          return { block: true, reason: prichina.length > 0 ? prichina : 'ОТКАЗ: страж замка сломан (fail-closed): дверь отказала без причины' };
        }
        return { block: true, reason: 'ОТКАЗ: страж замка сломан (fail-closed)' };
      } finally {
        rmSync(eventFile, { force: true });
      }
    } catch {
      return { block: true, reason: 'ОТКАЗ: спавн-страж сломан (fail-closed, Н-270)' };
    }
  });
}
