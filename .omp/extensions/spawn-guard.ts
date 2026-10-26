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
//
// СЛОЙ ПРЕДМЕТА (контракт 140, инвариант 1) — ПОСЛЕ алфавита 104: алфавит не
// прошёл — вызова двери нет (семантика 104 переносится дословно и не
// ослабляется). Дверь — scripts/zamok_predmeta.sh рядом с расширением (пин по
// расположению, НЕ env); вся логика предмета (замок, единый учёт, порядок
// судейства) живёт в двери, расширение только вызывает её и разбирает код
// возврата: rc 0 — пропуск, rc 1 — именованный отказ двери (первая строка
// stderr), rc 2 — «страж замка сломан» (fail-closed).
//
// КОРНИ состояний — из ЖИВОГО контекста сессии omp (ctx.sessionManager.
// getSessionFile(), прецедент wait-guard.ts): корень журналов — каталог
// agent/sessions над файлом сессии; корень состояний (формула 028) — префикс
// пути до /zones/, --sostojanie = <корень состояний>/zamok; --repo — cwd
// процесса. Ничего из env не читается (env наследуется и подделывается
// ребёнком — тот же довод, что у алфавита 104).
//
// ОГОВОРКА (противоречие контракта и дерева, измерено): инвариант 1 требует
// «нет ctx → блок “страж сломан”», а замороженная батарея 104 зовёт
// обработчик БЕЗ ctx и ждёт «pass» для валидных ролей
// (fixtures/zashchita_main_104/_mir.sh:89, red_huk_task_spavna.sh клетки
// 6-*, red_huk_alfavit_ustanovki.sh клетки 2–4). Оба текста заморожены.
// Разведено так: предметный слой развёрнут тогда, когда в установке есть
// дверь; дверь есть, а живого контекста сессии нет — fail-closed (инвариант
// 1); двери в установке нет — предметного слоя в этой установке нет и вердикт
// алфавита 104 остаётся в силе. Без этой оговорки `bash fixtures/_krasnye_104.sh`
// → rc 1 (красны red_huk_task_spavna и red_huk_alfavit_ustanovki).
import { existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

// Харнесные типы, не являющиеся ролями config/agent_models.json — замкнутый
// список, ЕДИНСТВЕННОЕ место явного перечисления.
const HARNESS_TYPES: readonly string[] = ['scout'];

export const NO_AGENT = 'ОТКАЗ: спавн без явного agent';
export const OUT_OF_ALPHABET = 'ОТКАЗ: тип агента вне алфавита';
export const NOCFG = 'ОТКАЗ: конфиг установленного харнеса не читается';
const BROKEN = 'ОТКАЗ: спавн-страж сломан (fail-closed, Н-270)';

// Страж ПРЕДМЕТА (контракт 140, инвариант 1) — слой ПОСЛЕ алфавита 104.
// Логика предмета живёт в двери scripts/zamok_predmeta.sh; здесь только вызов
// и разбор кода возврата: rc 0 — пропуск, rc 1 — именованный отказ двери
// (первая строка stderr), rc 2 — страж сломан (fail-closed).
export const ZAMOK_BROKEN = 'ОТКАЗ: страж замка сломан (fail-closed)';

// Установка = где лежит расширение: <ext>/../../config/agent_models.json.
const HERE = dirname(fileURLToPath(import.meta.url));
const CFG_PATH = join(HERE, '..', '..', 'config', 'agent_models.json');
// Дверь предмета — ТОЖЕ по расположению расширения (инвариант 1), не по env.
const DOOR_PATH = join(HERE, '..', '..', 'scripts', 'zamok_predmeta.sh');

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

// ── слой предмета 140 (инвариант 1) ─────────────────────────────────────────
// ЖИВОЙ контекст сессии omp — единственный источник корней (прецедент
// wait-guard.ts): ctx.sessionManager.getSessionFile(). Файл сессии даёт:
//   корень журналов  — каталог agent/sessions НАД файлом сессии (дверь ищет
//                      журналы holder рекурсивно);
//   корень состояний — префикс пути до /zones/ (формула 028); --sostojanie
//                      = <корень состояний>/zamok.
// --repo — cwd процесса (проект сессии). Ничего из env не читается: env
// наследуется и подделывается ребёнком (тот же довод, что у алфавита 104).
function sessionFileOf(ctx: unknown): string | null {
  if (!isObject(ctx)) return null;
  const sm = ctx.sessionManager;
  if (!isObject(sm)) return null;
  const get = sm.getSessionFile;
  if (typeof get !== 'function') return null;
  const file = (get as () => unknown).call(sm);
  return typeof file === 'string' && file.length > 0 ? file : null;
}

type Roots = { sost: string; zhurnaly: string };

function stateRoots(sessionFile: string): Roots | null {
  // корень журналов: последний каталог agent/sessions над файлом сессии
  const m = /^(.*\/agent\/sessions)\//.exec(sessionFile);
  if (m === null) return null;
  // корень состояний (формула 028): префикс пути до /zones/
  const z = sessionFile.indexOf('/zones/');
  if (z <= 0) return null;
  return { sost: sessionFile.slice(0, z), zhurnaly: m[1] };
}

// Событие двери — items {agent, name, task}; та же нормализация 104 (batch
// разворачивается в список, flat — один элемент). Значения задания в дверь
// попадают байт-в-байт: дверь разбирает их своими замкнутыми алфавитами.
type TaskItem = { agent: string; name: string; task: string };

function taskItems(input: unknown): TaskItem[] {
  const raw: unknown[] =
    isObject(input) && 'tasks' in input && Array.isArray(input.tasks)
      ? (input.tasks as unknown[])
      : [input];
  const out: TaskItem[] = [];
  for (const item of raw) {
    const o = isObject(item) ? item : {};
    out.push({
      agent: typeof o.agent === 'string' ? o.agent : '',
      name: typeof o.name === 'string' ? o.name : '',
      task: typeof o.task === 'string' ? o.task : '',
    });
  }
  return out;
}

// Именованная причина двери — первая непустая строка её stderr.
function firstLine(text: string): string {
  for (const line of text.split('\n')) {
    const t = line.trim();
    if (t.length > 0) return t;
  }
  return '';
}

type PiLike = { on?: (name: string, handler: (...args: unknown[]) => unknown) => unknown };

export default function register(pi: unknown): void {
  if (!isObject(pi)) return;
  const p = pi as PiLike;
  if (typeof p.on !== 'function') return;
  p.on('tool_call', (call: unknown, ctx: unknown): Block | undefined => {
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
      const verdict = judgeTaskInput(call.input, alphabet);
      if (verdict !== undefined) return verdict;
      // [ZAMOK140] начало блока вызова двери
      // Предметный суд (контракт 140, инвариант 1) — ПОСЛЕ алфавита 104:
      // алфавит не прошёл — вызова двери нет (семантика 104 не ослаблена).
      // Корни состояний — из ЖИВОГО ctx сессии omp; дверь — по расположению
      // расширения; логика предмета живёт в двери, здесь только вызов.
      const sessionFile = sessionFileOf(ctx);
      if (sessionFile === null) {
        // ЖИВОГО контекста сессии нет — корни состояний вывести не из чего.
        // Предметный слой развёрнут ТОГДА, когда в установке есть дверь
        // (scripts/zamok_predmeta.sh рядом с расширением — тот же пин по
        // расположению, что и алфавит 104): дверь есть, живого контекста нет —
        // страж предметов сломан (fail-closed, инвариант 1); двери в установке
        // нет — предметного слоя в этой установке нет, вердикт алфавита 104
        // остаётся в силе (семантика 104 переносится дословно).
        // Противоречие зафиксировано: контракт 140 инв. 1 требует «нет ctx →
        // блок», а замороженная батарея 104 зовёт обработчик БЕЗ ctx и ждёт
        // «pass» для валидных ролей (fixtures/zashchita_main_104/_mir.sh:89).
        // Измерение: без этой оговорки `bash fixtures/_krasnye_104.sh` → rc 1
        // (клетки red_huk_task_spavna и red_huk_alfavit_ustanovki красные).
        if (existsSync(DOOR_PATH)) {
          return { block: true, reason: `${ZAMOK_BROKEN}: нет живого контекста сессии` };
        }
        return undefined;
      }
      const roots = stateRoots(sessionFile);
      if (roots === null) {
        return { block: true, reason: `${ZAMOK_BROKEN}: файл сессии вне грамматики` };
      }
      // Событие — во временный файл ВНУТРИ корня состояний: писатель —
      // процесс расширения (сессия вне null-allowlist на диск не пишет,
      // Н-85/Н-212). Файл удаляется сразу после суда.
      const eventFile = join(
        roots.sost,
        `.zamok140-event-${process.pid}-${Math.random().toString(36).slice(2)}.json`,
      );
      try {
        // Каталог состояния замка создаёт РАСШИРЕНИЕ — оно и есть писатель
        // состояния (Н-85/Н-212: сессия вне null-allowlist на диск не пишет).
        // Дверь требует существующий --sostojanie (иначе rc 2 «состояния нет»),
        // а на живой станции каталога ещё нет — значит, его создаёт тот, кто
        // состоянием владеет.
        mkdirSync(join(roots.sost, 'zamok'), { recursive: true });
        writeFileSync(eventFile, JSON.stringify({ tasks: taskItems(call.input) }), 'utf8');
        const r = spawnSync(
          'bash',
          [
            DOOR_PATH,
            '--sudit',
            '--sostojanie',
            join(roots.sost, 'zamok'),
            '--zhurnaly',
            roots.zhurnaly,
            '--repo',
            process.cwd(),
            eventFile,
          ],
          { encoding: 'utf8' },
        );
        if (r.error !== undefined || r.signal !== null || r.status === null) {
          return { block: true, reason: `${ZAMOK_BROKEN}: дверь не исполнена` };
        }
        if (r.status === 0) return undefined;
        if (r.status === 1) {
          const prichina = firstLine(r.stderr ?? '');
          return {
            block: true,
            reason:
              prichina.length > 0
                ? prichina
                : `${ZAMOK_BROKEN}: дверь отказала без причины`,
          };
        }
        return { block: true, reason: ZAMOK_BROKEN };
      } finally {
        rmSync(eventFile, { force: true });
      }
      // [ZAMOK140] конец блока вызова двери
    } catch {
      return { block: true, reason: BROKEN };
    }
  });
}
