// Спавн-страж — точка перехвата РЕАЛЬНОГО запроса спавна (контракт 104
// Решение 1 — перенос 099 с пином установки; З-7/Н-270; граница арбитража
// verdicts/arbitration/contracts-099-spawn-trust-v1.md).
//
// Замеры арбитража 099 (дословно из вердикта):
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
// ПИН УСТАНОВКИ — РАСПОЛОЖЕНИЕ РАСШИРЕНИЯ (Решение 104, отличие от 099):
// алфавит читается из <dirname этого файла>/../../config/agent_models.json
// УСТАНОВЛЕННОГО харнеса (прецедент gate-draft.ts/startup-digest.ts).
// process.cwd() — это ПРОЕКТ: внешний проект подменяет алфавит своим
// config/agent_models.json (И-2) либо не имеет файла вовсе. HARNESS_TOOLS_ROOT
// и любой другой env наследуется и подделывается ребёнком (workshop 060
// экспортирует его в каждую сессию проекта) — НЕ первичный источник и НЕ
// фолбэк. Файла нет / не читается / без roles → именованный отказ КАЖДОГО
// task-вызова (fail-closed, НЕ bootstrap-пропуск и НЕ подхват cwd/env, И-5).
//
// Алфавит — ЕДИНСТВЕННОЕ место перечисления: РОЛИ config/agent_models.json +
// явно перечисленные харнесные типы (scout, AGENTS.md). Сравнение —
// литальное равенство строк (норма 041), без regex/glob из чужого значения.
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

// Харнесные типы, не являющиеся ролями config/agent_models.json — замкнутый
// список, ЕДИНСТВЕННОЕ место явного перечисления.
const HARNESS_TYPES: readonly string[] = ['scout'];

export const NO_AGENT = 'ОТКАЗ: спавн без явного agent';
export const OUT_OF_ALPHABET = 'ОТКАЗ: тип агента вне алфавита';
export const NOCFG = 'ОТКАЗ: конфиг установленного харнеса не читается';
const BROKEN = 'ОТКАЗ: спавн-страж сломан (fail-closed, Н-270)';

// Установка = где лежит расширение: <ext>/../../config/agent_models.json.
const HERE = dirname(fileURLToPath(import.meta.url));
const CFG_PATH = join(HERE, '..', '..', 'config', 'agent_models.json');

type Block = { block: true; reason: string };

function isObject(v: unknown): v is Record<string, unknown> {
  return typeof v === 'object' && v !== null;
}

// Единый источник алфавита: роли УСТАНОВОЧНОГО config/agent_models.json
// (по расположению этого файла, не по cwd/env) + HARNESS_TYPES. Бросает при
// нечитаемом/битом конфиге — регистратор превращает это в именованный
// fail-closed блок каждого task-вызова, не в молчаливый пропуск.
function loadAlphabet(): ReadonlySet<string> {
  const raw = readFileSync(CFG_PATH, 'utf8');
  const cfg = JSON.parse(raw) as unknown;
  if (!isObject(cfg) || !isObject(cfg.roles)) throw new Error('agent_models.json: нет секции roles');
  const set = new Set<string>(Object.keys(cfg.roles));
  for (const t of HARNESS_TYPES) set.add(t);
  // Тихий дефолт "task" не входит в алфавит НИ ПРИ КАКИХ ролях конфига
  // (замер 3 арбитража) — защищено явно, а не только отсутствием в конфиге.
  set.delete('task');
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
      let alphabet: ReadonlySet<string>;
      try {
        alphabet = loadAlphabet();
      } catch {
        // Нет/бит установочный конфиг — именованный отказ КАЖДОГО спавна
        // (И-5): не bootstrap по cwd, не env-фолбэк, не «страж сломан».
        return { block: true, reason: `${NOCFG}: ${CFG_PATH}` };
      }
      return judgeTaskInput(call.input, alphabet);
    } catch {
      return { block: true, reason: BROKEN };
    }
  });
}
