// Спавн-страж — точка перехвата РЕАЛЬНОГО запроса спавна (контракт 099,
// З-7/Н-270; граница арбитража verdicts/arbitration/contracts-099-spawn-trust-v1.md).
//
// Замеры арбитража (дословно из вердикта):
//   Замер 1: scripts/spawn_agent.sh НЕ лежит на пути реального запроса спавна
//            судьи (за историю ни одной ветки wip/*/critic|adversary|arbiter;
//            судьи спавнятся изолированными сессиями _task, omp/task/<id>).
//   Замер 2: omp излучает tool_call для toolName 'task' ДО исполнения;
//            {block:true} → вызов обрывается; расширение родителя судит и
//            вложенные спавны детей; исключение в обработчике = fail-closed.
//   Замер 3: omp резолвит дефолт agent:"task" ДО хука — «agent опущен» и
//            agent:"task" в событии НЕРАЗЛИЧИМЫ. Потому предикат один:
//            РЕЗОЛВНУТЫЙ agent ∈ замкнутого алфавита; "task" (тихий дефолт)
//            в алфавит НЕ входит — Н-270-дефект ловится только так.
//
// Алфавит — ЕДИНСТВЕННОЕ место перечисления: РОЛИ config/agent_models.json +
// явно перечисленные харнесные типы (scout, AGENTS.md:71). Сравнение —
// литеральное равенство строк (норма 041), без regex/glob из чужого значения.
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

// Харнесные типы, не являющиеся ролями config/agent_models.json — замкнутый
// список, ЕДИНСТВЕННОЕ место явного перечисления.
const HARNESS_TYPES: readonly string[] = ['scout'];

export const NO_AGENT = 'ОТКАЗ: спавн без явного agent';
export const OUT_OF_ALPHABET = 'ОТКАЗ: тип агента вне алфавита';
const BROKEN = 'ОТКАЗ: спавн-страж сломан (fail-closed, Н-270)';

type Block = { block: true; reason: string };

function isObject(v: unknown): v is Record<string, unknown> {
  return typeof v === 'object' && v !== null;
}

// Единый источник алфавита: роли config/agent_models.json (cwd корня проекта)
// + HARNESS_TYPES. Бросает при нечитаемом/битом конфиге — регистратор
// превращает это в fail-closed блок task-вызова, не в молчаливый пропуск.
let alphabetCache: { cwd: string; set: ReadonlySet<string> } | null = null;
function loadAlphabet(cwd: string): ReadonlySet<string> {
  if (alphabetCache !== null && alphabetCache.cwd === cwd) return alphabetCache.set;
  const raw = readFileSync(join(cwd, 'config', 'agent_models.json'), 'utf8');
  const cfg = JSON.parse(raw) as unknown;
  if (!isObject(cfg) || !isObject(cfg.roles)) throw new Error('agent_models.json: нет секции roles');
  const set = new Set<string>(Object.keys(cfg.roles));
  for (const t of HARNESS_TYPES) set.add(t);
  // Тихий дефолт "task" не входит в алфавит НИ ПРИ КАКИХ ролях конфига
  // (замер 3 арбитража) — защищено явно, а не только отсутствием в конфиге.
  set.delete('task');
  alphabetCache = { cwd, set };
  return set;
}

// Суд входа задачи: КАЖДЫЙ элемент input.tasks[] (batch) и input целиком
// (flat, omp://tools/task.md:50). Первый блок обрывает вызов — один плохой
// элемент заражает весь batch. Битый вход бросает → fail-closed наверху.
export function judgeTaskInput(input: unknown, alphabet: ReadonlySet<string>): Block | undefined {
  let items: unknown[];
  if (isObject(input) && 'tasks' in input) {
    // ключ tasks присутствует, но не массив — битый вход, не flat-форма
    if (!Array.isArray(input.tasks)) throw new Error('tasks не массив');
    items = input.tasks;
  } else {
    items = [input];
  }
  for (const item of items) {
    if (!isObject(item)) throw new Error('битый элемент tasks');
    const agent = item.agent;
    if (agent === undefined) {
      // omp всегда резолвит дефолт ДО хука (замер 3); отсутствие ключа в
      // событии означает «явного агента нет» — тот же отказ, что agent:"task".
      return { block: true, reason: `${NO_AGENT}: task` };
    }
    if (typeof agent !== 'string') throw new Error('agent не строка');
    if (agent === 'task') return { block: true, reason: `${NO_AGENT}: ${agent}` };
    if (!alphabet.has(agent)) return { block: true, reason: `${OUT_OF_ALPHABET}: ${agent}` };
  }
  return undefined; // все элементы — валидные роли алфавита
}

type PiLike = { on?: (name: string, handler: (...args: unknown[]) => unknown) => unknown };

export default function register(pi: unknown): void {
  if (!isObject(pi)) return;
  const p = pi as PiLike;
  if (typeof p.on !== 'function') return;
  p.on('tool_call', (call: unknown): Block | undefined => {
    try {
      if (!isObject(call)) return undefined;
      // Хук не вмешивается в чужие инструменты: судится только task.
      if (call.toolName !== 'task') return undefined;
      const alphabet = loadAlphabet(process.cwd());
      return judgeTaskInput(call.input, alphabet);
    } catch {
      return { block: true, reason: BROKEN };
    }
  });
}
