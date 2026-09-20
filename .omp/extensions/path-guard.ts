// Расширение omp: страж вектора утечки + пин WORKTREE.
// Контракт 025, пачка A (вектор) и C (пин/allowlist, Г1-Г3) + резолюция
// владельца 2026-09-11 «ДЫРА B / А-122»: абсолют-в-MAIN-чекаут блокируется,
// непиннованный ребёнок ДЕФОЛТ-ЗАПРЕЩЁН на чекаут-запись, scratch/artifact — pass.
//
// Два режима:
//   1. CLI: `node path-guard.ts --judge '<json>'` — синтетический tool_call,
//      выход одна строка JSON {"decision":"block|pass|refuse","reason":"…"} | rc 2.
//   2. Factory: default-export; omp грузит расширение на старте сессии; на
//      tool_call-событие фабрика судит вызов и возвращает {block,reason} или
//      undefined. Ошибки handler'а трактуются как fail-closed (omp сам).
//
// Решения (контракт 025 §Пачка A-1, §Пачка C-1 + резолюция 2026-09-11):
//   - edit/write ОТНОСИТЕЛЬНЫМ path → block «Н-85: абсолютный путь или cwd».
//   - bash форма записи + относительный операнд + нет cwd → block «Н-85».
//   - edit/write АБСОЛЮТНЫМ path → pass только если путь в-пинне, в scratch
//     (${TMPDIR:-/tmp}/dev-harness-verify/**) или URI-схеме allowlist'а (Г3).
//   - запись АБСОЛЮТНАЯ вне пина/allowlist → block «Н-85».
//     В т.ч. абсолют-в-MAIN-чекаут из непиннованной сессии (fail-closed против
//     принципа; свободный абсолют непиннованного = корень А-72).
//   - pin не существует → refuse «не существует».
//   - pin ≠ actual → refuse «не совпадает».
//   - URI (artifact://, local://, skill://, agent://, history://, xd://):
//     pinned сессия pass (Г3); unpinned (worktree:null) — ТОЛЬКО artifact://
//     проходит, иные внутренние URI — block Н-85 (резолюция 2026-09-11 «дыра B»;
//     null-allowlist узкое «скратч/artifact», local://, mcp://, skill:// — НЕ
//     исключение слова владельца; fix 025 правка-круг 3, вердикт d141dd9
//     блокер 2).
//   - read/grep/glob и bash без формы записи — pass (Г1 «читать свободно»).
//
// Контракт 032, РЕШЕНИЕ арбитра d2ffb8e (сжатая цитата границы модели угроз):
//   Страж path-guard.ts судит tool_call агента, чей процесс поднят не им.
//   За данность принимаются: среда процесса на момент старта (в т.ч. PATH),
//   исполняемые файлы, найденные в ней, и текст задания (первая user-запись).
//   Противник модели — агент, уже запущенный внутри этой среды: может писать
//   файлы и вызывать инструменты, но НЕ может изменить среду собственного
//   процесса и НЕ может переписать своё задание. Подмена бинарника в PATH
//   процесса стража, подмена интерпретатора (node), подмена самого расширения
//   и подделка текста задания — один класс «компрометация старта процесса»,
//   ВНЕ модели (эквивалент компрометации владельца/оркестратора).
//   Страж — НЕ песочница: непрозрачное исполнение (свой бинарник, скрипт-файл
//   интерпретатора) пишет мимо пина и судьёй не ловится — измерено (замер 4).
//   Страж держит непреднамеренный снос чужого дерева и «непиннованная запись»,
//   а не враждебный код.
// Реализация ниже НЕ претендует на аутентификацию. Разрешение `git` при загрузке
// модуля — МЕМОИЗАЦИЯ поиска (один резолв на процесс, абсолютный путь вместо
// голого имени, без повторного поиска). Кэш пуст → поведение no-git прежнее:
// CLI rc 2 NOT_IMPLEMENTED (Н-85), фабрика null/block.

import { realpathSync, statSync, openSync, readSync, closeSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { dirname } from 'node:path';

// ── Allowlist URI-схем (Г3 «internal URI харнеса») ─────────────────────────────
// В pinned сессии все они pass; в unpinned (worktree:null) — ТОЛЬКО artifact://
// (см. isUnpinnedInternalURI). Слово владельца 2026-09-11 дословно: null-allowlist
// = скратч/artifact; local://, mcp://, skill://, agent://, history://, xd:// — НЕ
// исключение.
const URI_SCHEMES: readonly string[] = [
  'artifact://',
  'local://',
  'skill://',
  'agent://',
  'history://',
  'xd://',
];

// ── Типы ──────────────────────────────────────────────────────────────────────
type Decision =
  | { decision: 'pass' }
  | { decision: 'block'; reason: string }
  | { decision: 'refuse'; reason: string };

export type JudgeInput = {
  tool: string;
  args: Record<string, unknown>;
  worktree?: string | null;
  actual?: string | null;
  // Для пина-из-задания сверка с actual НЕ применяется (М2 контракт 032).
  skipActualCheck?: boolean;
};

// ── Утилиты ───────────────────────────────────────────────────────────────────
function isAllowedURI(p: string): boolean {
  return URI_SCHEMES.some((s) => p.startsWith(s));
}

// Непиннованная сессия + URI из allowlist'а, но НЕ artifact:// —
// fail-closed «внутренний URI непиннованной сессии — дефолт-запрет,
// слово владельца 2026-09-11: скратч/artifact». local://, mcp://,
// skill://, agent://, history://, xd:// у непинна → блок Н-85.
function isUnpinnedInternalURI(p: string, worktree: string | null): boolean {
  if (worktree !== null) return false;     // pinned — allowlist действует целиком
  if (!isAllowedURI(p)) return false;      // не URI — другая ветвь судьи
  if (p.startsWith('artifact://')) return false; // unpinned artifact:// — pass
  return true;                              // unpinned + иная URI-схема — block
}

function getVerifyBase(): string {
  return `${process.env.TMPDIR || '/tmp'}/dev-harness-verify`;
}

function safeRealpath(p: string): string | null {
  try {
    return realpathSync(p);
  } catch {
    return null;
  }
}

function isWithin(parent: string, child: string): boolean {
  // parent обязан быть канонизирован (без symlink, без ..)
  return child === parent || child.startsWith(`${parent}/`);
}

// Лексическая нормализация «..» и «.» в пути (М4, контракт 032). Разбор сегментов:
function lexNormalize(p: string): string {
  if (!p) return p;
  const isAbs = p.startsWith('/');
  const segs = p.split('/');
  const stack: string[] = [];
  for (const seg of segs) {
    if (seg === '' || seg === '.') continue;
    if (seg === '..') {
      // POSIX: .. у корня для абсолюта и до первого сегмента для относительного
      if (stack.length > 0) stack.pop();
      continue;
    }
    stack.push(seg);
  }
  return (isAbs ? '/' : '') + stack.join('/');
}

// ── Мемоизация пути git (контракт 032 — кэш абсолютного пути на загрузке модуля) ─
// МЕМОИЗАЦИЯ, НЕ АУТЕНТИФИКАЦИЯ (РЕШЕНИЕ арбитра d2ffb8e). Разрешение
// `git` при загрузке модуля — приём кэширования: один резолв на процесс,
// абсолютный путь вместо голого имени, без повторного поиска. Это НЕ
// устанавливает подтверждение бинарника — граница модели угроз объявлена в шапке
// «компрометация старта процесса» ВНЕ модели.
//
// МЕТОД. Рассматривались два кандидата:
//   (а) `spawnSync('which', ['git'])` — короче, но требует наличия `which` в
//       PATH (он не POSIX, на минимальных контейнерах может отсутствовать)
//       и принимает его вывод без проверки isFile+x; в редких случаях `which`
//       отдаёт путь, который сам не является исполняемым файлом.
//   (б) ручной обход PATH-каталогов с `statSync` + `isFile()` + проверкой
//       хотя бы одного бита x (0o111) — ВЫБРАН.
// Преимущества (б): самодостаточен (не зависит от внешнего `which`), явная
// проверка в нашем коде, без гонки между «нашёл» и «проверил», одна и та же
// логика для всех POSIX-систем. Разделитель PATH — `:` (omp только Linux
// по контексту .omp/config.yml и CI-сценариев).
// Кэш вычисляется ОДИН РАЗ на загрузке модуля — `process.env.PATH` в этот
// момент фиксирован и НЕ зависит от дальнейших манипуляций с PATH. Это
// попутно закрывает класс fake-git-first в ОБЪЯВЛЕННОЙ границе: фейк,
// добавленный в PATH после загрузки расширения, на оракул не влияет (идёт
// спавн по абсолютному пути). Подмена `git` ДО загрузки расширения — ВНЕ
// границы.
// Кэш пуст (нет подходящего `git` в boot-PATH) → поведение no-git прежнее:
// CLI rc 2 NOT_IMPLEMENTED (Н-85), фабрика null/block (М2 + Н-85).
function resolveGitAbsolute(): string {
  const pathEnv = process.env.PATH || '';
  if (!pathEnv) return '';
  for (const dir of pathEnv.split(':')) {
    if (!dir) continue;
    const candidate = `${dir}/git`;
    try {
      const st = statSync(candidate);
      // isFile() следует по симлинку: если цель — обычный файл, симлинк на
      // него тоже isFile(); spawnSync потом сам разрешит симлинк при exec.
      // Проверка 0o111 (union r-x для owner/group/other) — отсекает каталоги
      // с битом x и сокеты; минимальное условие запуска процесса.
      if (!(st.isFile() && (st.mode & 0o111) !== 0)) continue;
      // Shebang-фильтр СНЯТ по РЕШЕНИЮ арбитра d2ffb8e (замер 2): фильтр по
      // форме файла ломал честные шимы asdf/mise/nix/direnv/Homebrew
      // (shell-обёртка `git` отвергалась → DoS пиннов), при этом НЕ
      // аутентифицировал ELF-фейк (замер 1). Граница — шапка файла.
      return candidate;
    } catch {
      // ENOENT/EACCES — следующий каталог PATH.
      continue;
    }
  }
  return '';
}
// Кэш абсолютного пути git; вычисляется ОДИН РАЗ при загрузке модуля.
const GIT_PATH: string = resolveGitAbsolute();

// Проверка «живой linked worktree» через git-оракул (РЕШЕНИЕ арбитра 0c98913,
// §Вопрос 1 п.4): структурные проверки остаются кодом, формат и живость цели
// судит сам git. Ручная грамматика (бывшая /^gitdir:\s*(\S+)$/ + trim, path-guard
// до 032) УДАЛЕНА целиком — третий регэксп этого класса не появится: два круга
// подряд ручная грамматика оказалась мягче git (A1 multiline /m, B1
// не-канонические формы), класс закрывается заменой судьи. Возвращает три
// состояния:
//   - 'live'     кандидат — живой linked worktree (rc 0 И stdout-путь существует)
//   - 'not-live' структурно не подходит, или git отверг форму (rc≠0),
//                или stdout-путь не существует
//   - 'no-git'   git отсутствует в boot-PATH (кэш пуст); CLI → rc 2
//                NOT_IMPLEMENTED (Н-85), фабрика → worktree:null → unpinned →
//                block (НИКОГДА pass)
type OracleResult = 'live' | 'not-live' | 'no-git';

function buildSanitizedEnv(parentDir: string): NodeJS.ProcessEnv {
  // Прецедент scripts/spawn_agent.sh:38-40 — unset GIT_DIR-семейство, /dev/null на
  // GIT_CONFIG_*; плюс GIT_CEILING_DIRECTORIES=<родитель кандидата> против
  // восхождения к чужому родительскому репо (РЕШЕНИЕ 0c98913 §Вопрос 1 п.4 —
  // «гигиена спавна процесса из расширения»).
  const drop: Record<string, true> = {
    GIT_DIR: true,
    GIT_WORK_TREE: true,
    GIT_INDEX_FILE: true,
    GIT_OBJECT_DIRECTORY: true,
    GIT_ALTERNATE_OBJECT_DIRECTORIES: true,
    GIT_TEMPLATE_DIR: true,
    GIT_CEILING_DIRECTORIES: true,
  };
  const env: NodeJS.ProcessEnv = {};
  for (const [k, v] of Object.entries(process.env)) {
    if (drop[k]) continue;
    if (v !== undefined) env[k] = v;
  }
  env.GIT_CONFIG_GLOBAL = '/dev/null';
  env.GIT_CONFIG_SYSTEM = '/dev/null';
  env.GIT_CEILING_DIRECTORIES = parentDir;
  return env;
}

function gitOracle(p: string): OracleResult {
  // Структурные проверки — кодом (РЕШЕНИЕ 0c98913 §Вопрос 1 п.4): <путь>/.git
  // существует и это ФАЙЛ (НЕ каталог). Фильтрует п4 (нет .git) и п4в
  // (.git-каталог) ДО дорогого spawnSync.
  const dotGit = `${p}/.git`;
  let st;
  try {
    st = statSync(dotGit);
  } catch {
    return 'not-live';
  }
  if (!st.isFile()) return 'not-live';

  // МЕМОИЗАЦИЯ (РЕШЕНИЕ арбитра d2ffb8e): GIT_PATH кэшируется ОДИН РАЗ при
  // загрузке модуля (см. resolveGitAbsolute выше) — это НЕ якорь
  // аутентификации (граница — шапка файла). Фейк, добавленный в PATH после
  // загрузки расширения, на оракул не влияет: spawnSync вызывается ТОЛЬКО
  // по абсолютному пути, без поиска в PATH. Кэш пуст → существующее no-git:
  // CLI rc 2 NOT_IMPLEMENTED (Н-85), фабрика null/block.
  if (!GIT_PATH) return 'no-git';

  // Git-оракул: spawnSync <абсолютный-путь-git> rev-parse --absolute-git-dir
  // с санированным env. live ⟺ rc 0 И stdout-путь существует (РЕШЕНИЕ 0c98913
  // §Замер 2). ENOENT-ветка оставлена как страховка — при абсолютном пути
  // не ожидается, но дёшево и не путает not-live с no-git на иных FS.
  const env = buildSanitizedEnv(dirname(p));
  let res;
  try {
    res = spawnSync(GIT_PATH, ['-C', p, 'rev-parse', '--absolute-git-dir'], {
      env,
      stdio: ['ignore', 'pipe', 'pipe'],
    });
  } catch {
    return 'no-git';
  }
  if (res.error) {
    const code = (res.error as NodeJS.ErrnoException).code;
    if (code === 'ENOENT') return 'no-git';
    return 'not-live';
  }
  if (res.status !== 0) return 'not-live';
  const gitdirPath = (res.stdout ?? '').toString('utf8').trim();
  if (!gitdirPath) return 'not-live';
  try {
    statSync(gitdirPath);
    return 'live';
  } catch {
    return 'not-live';
  }
}

// Извлечение пина из текста задания (М1 контракт 032). Три условия одновременно:
// noGit различает «не живой» (фабрика → null/block) и «git отсутствует» (CLI
// отдельно ловит rc 2 NOT_IMPLEMENTED; фабрика идёт через extractPinFromBranch
// и о noGit просто не знает — её путь даст null/block как у прочих fail-closed).
function extractPin(text: string): { worktree: string | null; noGit: boolean } {
  // 1) ровно одна spawn-пара: токен WORKTREE=<абс> + BRANCH=wip/<NNN>/<автор>;
  const tokenRe = /(?:^|[:;,])\s*(WORKTREE|BRANCH)=([^\s,;]+)/g;
  let wtCount = 0, brCount = 0;
  let wt: string | null = null, br: string | null = null;
  let mm: RegExpExecArray | null;
  while ((mm = tokenRe.exec(text)) !== null) {
    if (mm[1] === 'WORKTREE') { wtCount++; wt = mm[2]; }
    else { brCount++; br = mm[2]; }
  }
  if (wtCount !== 1 || brCount !== 1 || wt === null || br === null) {
    return { worktree: null, noGit: false };
  }
  // Терминальная пунктуация (точка в конце предложения): .strip без потери хвостовых точек пути (нет в фикстурах).
  const cleanValue = (s: string): string => s.replace(/[.,;:!?]+$/, '');
  wt = cleanValue(wt);
  br = cleanValue(br);
  // Абсолютный путь.
  if (!wt.startsWith('/')) return { worktree: null, noGit: false };
  // 2) spawn-форма: basename(<путь>) == wip-<NNN>-<автор>.
  const brMatch = br.match(/^wip\/(\d+)\/([A-Za-z0-9_-]+)$/);
  if (!brMatch) return { worktree: null, noGit: false };
  const segs = wt.split('/');
  const baseName = segs[segs.length - 1] ?? '';
  const expectedBase = `wip-${brMatch[1]}-${brMatch[2]}`;
  if (baseName !== expectedBase) return { worktree: null, noGit: false };
  // 3) живой linked worktree через git-оракул (РЕШЕНИЕ 0c98913 §Вопрос 1 п.4).
  // Гигиена: оракул вызывается ТОЛЬКО здесь, после структурных условий и полной
  // грамматики пары; успешный пин мемоизируется (М2) — спавна git на каждый
  // tool_call нет.
  const status = gitOracle(wt);
  if (status === 'no-git') return { worktree: null, noGit: true };
  if (status !== 'live') return { worktree: null, noGit: false };
  return { worktree: wt, noGit: false };
}

// Чтение session_id из omp-контекста (М2: ключ для модульной карты пинов).
function getSessionId(ctx: unknown): string | null {
  if (!ctx || typeof ctx !== 'object') return null;
  const sm = (ctx as { sessionManager?: { getSessionId?: () => unknown } }).sessionManager;
  if (!sm || typeof sm !== 'object') return null;
  if (typeof sm.getSessionId !== 'function') return null;
  const v = sm.getSessionId();
  return typeof v === 'string' ? v : null;
}

// Чтение ветки сессии (массив сообщений) из omp-контекста.
function getBranch(ctx: unknown): unknown {
  if (!ctx || typeof ctx !== 'object') return [];
  const sm = (ctx as { sessionManager?: { getBranch?: () => unknown } }).sessionManager;
  if (!sm || typeof sm !== 'object') return [];
  if (typeof sm.getBranch !== 'function') return [];
  return sm.getBranch();
}

// Извлечение пина из ветки: ТОЛЬКО ПЕРВАЯ user-запись (п9 — steering НЕ перепинивает).
// На фабричном пути noGit не используется: фабрика должна fail-closed null/block (Н-85),
// а CLI --extract-pin отдельно ловит noGit через extractPin (см. runCLI).
function extractPinFromBranch(branch: unknown): string | null {
  if (!Array.isArray(branch)) return null;
  for (const entry of branch) {
    if (!entry || typeof entry !== 'object') continue;
    const msg = (entry as { message?: { role?: string; content?: unknown } }).message;
    if (!msg || typeof msg !== 'object') continue;
    if (msg.role !== 'user') continue;
    const content = msg.content;
    if (!Array.isArray(content)) continue;
    for (const part of content) {
      if (!part || typeof part !== 'object') continue;
      const p = part as { type?: string; text?: string };
      if (p.type === 'text' && typeof p.text === 'string') {
        return extractPin(p.text).worktree;
      }
    }
  }
  return null;
}

// Пин из задания — модульная переменная с КЛЮЧОМ session_id (М2: «registries are
// process-wide», модульная переменная без ключа = перенос пина между сессиями,
// запрещено; прецедент п11 «B наследует пин A»).
const sessionPins = new Map<string, string | null>();

// Детект формы записи в bash-команде. Полосим кавычки (простое удаление
// секций в одинарных/двойных/backtick), затем ищем sed -i / > / >> / tee / cp / mv / rm.
function stripQuotes(s: string): string {
  return s.replace(/(["'`])(?:\\.|(?!\1)[^])*\1/g, '');
}

function isWriteCommand(cmd: string): boolean {
  const c = stripQuotes(cmd);
  if (/\bsed\s+-[A-Za-z]*i\b/.test(c)) return true;
  if (/>>/.test(c)) return true;
  // > не после & и не после цифры (исключаем 2> >&1)
  if (/(?<![&\d])>/.test(c)) return true;
  if (/\btee\b/.test(c)) return true;
  if (/(?:^|\s)cp(?:\s|$)/.test(c)) return true;
  if (/(?:^|\s)mv(?:\s|$)/.test(c)) return true;
  if (/(?:^|\s)rm(?:\s|$)/.test(c)) return true;
  if (/(?:^|\s)dd(?:\s|$)/.test(c)) return true;
  if (/(?:^|\s)touch(?:\s|$)/.test(c)) return true;
  if (/(?:^|\s)truncate(?:\s|$)/.test(c)) return true;
  if (/(?:^|\s)install(?:\s|$)/.test(c)) return true;
  if (/(?:^|\s)ln(?:\s|$)/.test(c)) return true;
  // mkdir — форма записи (создаёт каталог; относительный путь без cwd → вектор).
  if (/(?:^|\s)mkdir(?:\s|$)/.test(c)) return true;
  // perl -i — in-place edit (perl без -i только читает/печатает явно, через FILE,
  // но -i меняет FILE на месте). Совмещённые флаги perl (single-letter-флаги
  // склеиваются): -pi / -pie / -pi.bak / -i / -i.bak — все формы несут флаг -i,
  // который неотделим от других букв в bundle. Регэкс (?<=\s|^)-[a-zA-Z]*i(?:[a-zA-Z.]*)?
  // (?=\s|$|\.) ловит: «-» с предшествующим space/start, затем bundle с
  // обязательной «i», lookahead — граница. Простые \s-i / (?:^|\s|\B)-i НЕ
  // ловят -pi/-pie (литерал «-i» отсутствует в «-pi», 'p' между ними);
  // предшествующая регулярка \s-i была ложно-«закрывающей» (B-025-r2-1).
  if (/(?:^|\s)perl(?:\s|$)/.test(c) && /(?<=\s|^)-[a-zA-Z]*i(?:[a-zA-Z.]*)?(?=\s|$|\.)/.test(c)) return true;
  // python / python3 -c 'CODE' — code может содержать open()/Path().write_*().
  if (/(?:^|\s)python[23]?(?:\s|$)/.test(c) && /\s-c\b/.test(c)) return true;
  // ruby -e / node -e / php -r — скрипт-интерпретаторы с inline-кодом (B-025-r2-2);
  // код может содержать File.write / fs.writeFileSync / file_put_contents и т.п.
  // Детект по ключевому слову В НАЧАЛЕ команды, чтобы не множить «*»-паттерны
  // в deny-слое (И-6 канарейки обязаны жить; tee-блок d141dd9).
  if (/(?:^|\s)ruby(?:\s|$)/.test(c) && /\s-e\b/.test(c)) return true;
  if (/(?:^|\s)node(?:\s|$)/.test(c) && /\s-e\b/.test(c)) return true;
  if (/(?:^|\s)php(?:\s|$)/.test(c) && /\s-r\b/.test(c)) return true;
  // sed с флагом w FILE в substitution (`sed 's/A/B/w FILE'`) — форма записи
  // относительным путём без cwd (B-025-r2-2). Тест на СЫРОЙ команде: после
  // stripQuotes выражение в кавычках исчезает целиком и w-флаг теряется
  // (`echo X | sed 's/X/Y/w foo.txt'` → c=`echo X | sed ` без w).
  if (/(?:^|\s)sed(?:\s|$)/.test(cmd) && /\bw\s+\S+/.test(cmd)) return true;
  // awk с redirect внутри кода (`awk '... > "f"'`) — форма записи относительным
  // путём без cwd (B-025-r2-2). Жёстче чем общий «>» (исключает 2>&1):
  // «>» НЕ после «>» (т.е. не «>>») и НЕ после «&» или цифры.
  if (/(?:^|\s)awk(?:\s|$)/.test(c) && /(?<![&>\d])>\s*\S/.test(c)) return true;
  return false;
}

// Извлечение файловых операндов из команды: после > / >> и последний для sed -i.
// Для tee/cp/mv/rm/dd — каждый не-флаг-аргумент. Достаточно для тестовых форм
// контракта 025; полный разбор выходит за границы текущей пачки.
function extractFileOperands(cmd: string): string[] {
  const c = stripQuotes(cmd);
  const operands: string[] = [];
  const seen = new Set<string>();

  const pushOp = (p: string): void => {
    if (p && !seen.has(p)) {
      seen.add(p);
      operands.push(p);
    }
  };

  // после >> или > — операнд (с обрезкой пробелов; оставляем как есть)
  const reRe = /(?:>>|>)\s*(\S+)/g;
  let m: RegExpExecArray | null;
  while ((m = reRe.exec(c)) !== null) pushOp(m[1]);

  // sed -i … FILE — последний не-флаг токен
  if (/\bsed\s+-[A-Za-z]*i\b/.test(c)) {
    const parts = c.split(/\s+/).filter((p) => p.length > 0);
    for (let i = parts.length - 1; i >= 0; i--) {
      const p = parts[i];
      if (!p.startsWith('-') && p !== 'sed' && !p.includes('=')) {
        pushOp(p);
        break;
      }
    }
  }

  // tee / cp / mv / rm / dd / touch / truncate / install / ln — каждый
  // не-флаг аргумент (после ключевого слова и до следующего оператора
  // | & ; или конца команды).
  for (const kw of ['tee', 'cp', 'mv', 'rm', 'dd', 'touch', 'truncate', 'install', 'ln']) {
    const kwRe = new RegExp(`(?:^|[|&;])\\s*${kw}\\b([^|&;]*)`, 'g');
    while ((m = kwRe.exec(c)) !== null) {
      const args = m[1].trim().split(/\s+/).filter(Boolean);
      for (const a of args) {
        if (!a.startsWith('-')) pushOp(a);
      }
    }
  }

  return operands;
}

// Извлечение операндов для новых команд записи (B-2: mkdir / perl -i / python3 -c).
// Каждая команда имеет свою грамматику; общего решения нет — выделяем в одну функцию
// чтобы при добавлении следующей формы предмет не разрастается.
function extractExtraWriteOperands(cmd: string): string[] {
  const out: string[] = [];
  const seen = new Set<string>();
  const pushOp = (p: string): void => {
    if (p && !seen.has(p)) {
      seen.add(p);
      out.push(p);
    }
  };

  // Корректная токенизация с уважением кавычек и backslash — иначе разделитель
  // внутри python/perl-кода (например ';' в `from x import y; Path("z")...`) рвёт
  // команду по шву и мы теряем хвост, в котором лежит путь.
  const tokens = tokenizeShell(cmd);
  const cmds = splitShellCommands(tokens);

  for (const argv of cmds) {
    if (argv.length === 0) continue;
    const head = argv[0];

    // mkdir DIR [DIR …] — каждый не-флаг аргумент.
    if (head === 'mkdir') {
      for (let i = 1; i < argv.length; i++) {
        if (!argv[i].startsWith('-')) pushOp(argv[i]);
      }
      continue;
    }

    // perl [-i[.bak]] [-pe|-pi|-pie|-ne|-np] [-e 'CODE'] FILE [FILE …]
    // Совмещённые флаги perl — single-letter bundle: -pi = -p + -i, -pie = -p + -i + -e.
    // Для детекта in-place edit ПОЛНОГО bundle (а не только отдельного -i):
    // флаг-bundle считается «in-place», если содержит 'i' среди своих букв.
    if (head === 'perl') {
      let hasInplace = false;
      let skipNext = false;
      for (let i = 1; i < argv.length; i++) {
        const a = argv[i];
        if (skipNext) { skipNext = false; continue; }
        // Отдельный -i или bundle с 'i': -i / -i.bak / -pi / -pi.bak / -pie
        if (a === '-i' || a.startsWith('-i')) { hasInplace = true; continue; }
        // Совмещённые флаги вида -<буквы>.bak где среди букв есть 'i' (perl не
        // принимает форму -pi.bak, но для полноты): -[a-z]*i[a-z]*.bak
        // Регэкс: -bundle где bundle содержит 'i', до '.bak' (или просто -pi).
        // Упрощённо: -<буквы>[.<буквы>]? где первая часть содержит 'i' и нет '='.
        const bundle = /^(-[a-zA-Z]+(?:\.[a-zA-Z]+)?)$/;
        if (bundle.test(a) && /^-[a-zA-Z]*i[a-zA-Z]*(?:\.[a-zA-Z]*)?$/.test(a)) {
          hasInplace = true; continue;
        }
        if (a === '-e' || a === '-E' || a === '-n' || a === '-p' || a === '-l' ||
            a.startsWith('-I') || a.startsWith('-M') || a.startsWith('-F')) {
          // Совмещённые -pe/-pie/-pi/-np содержат и флаг, и -e; их правый операнд
          // — СЛЕДУЮЩИЙ токен, который для -pe/-pie/-pi/-ne/-np ВСЕГДА код.
          // Для совмещённых флагов следующего токена быть не должно (perl сам
          // жалуется), но на всякий случай — скипаем.
          skipNext = true; continue;
        }
        if (a.startsWith('-')) continue;
        pushOp(a);
      }
      // Если -i нет — это НЕ in-place edit; операнды (если были добавлены) выкидываем.
      // (perl без -i лишь читает/печатает, не пишет в файл.)
      if (!hasInplace) {
        const argSet = new Set(argv.slice(1).filter((a) => !a.startsWith('-') && a !== 'perl'));
        for (let i = out.length - 1; i >= 0; i--) {
          if (argSet.has(out[i])) out.splice(i, 1);
        }
      }
      continue;
    }

    // python / python3 / python2 -c 'CODE' — из CODE вытаскиваем строковые литералы.
    if (head === 'python' || head === 'python2' || head === 'python3' ||
        /^python\d+$/.test(head)) {
      for (let i = 1; i < argv.length - 1; i++) {
        if (argv[i] === '-c') {
          const code = argv[i + 1];
          for (const lit of extractPythonStringLiterals(code)) pushOp(lit);
          break;
        }
      }
      continue;
    }

    // ruby -e 'CODE' / node -e 'CODE' / php -r 'CODE' — скрипт-интерпретаторы
    // с inline-кодом (B-025-r2-2). Код может содержать File.write /
    // fs.writeFileSync / file_put_contents с относительным путём. Тест на СЫРОЙ
    // команде через quote-preserving tokenizer: tokenizeShell выкидывает кавычки
    // на границах токенов, и литералы в коде без внешней обёртки (ruby -e
    // File.write("x.txt","X")) теряют кавычки → extractPythonStringLiterals
    // ничего не находит → operands.length===0 → «безопасный пропуск» → pass
    // (ДЫРА). tokenizeShellKeepQuotes оставляет кавычки внутри токенов; внешняя
    // обёртка снимается отдельно (ruby -e 'code' → code), чтобы regex литералов
    // увидел внутренние строки, а не всю внешнюю пару.
    if (head === 'ruby' || head === 'node' || head === 'php' ||
        /^node\d+$/.test(head)) {
      const rawTokens = tokenizeShellKeepQuotes(cmd);
      const rawCmds = splitShellCommands(rawTokens);
      for (const rawArgv of rawCmds) {
        if (rawArgv.length === 0) continue;
        if (rawArgv[0] !== head) continue;
        for (let i = 1; i < rawArgv.length - 1; i++) {
          if (rawArgv[i] === '-e' || rawArgv[i] === '-r') {
            let code = rawArgv[i + 1];
            // Снять внешнюю обёртку одинаковых кавычек (ruby -e 'code' / "code"):
            // без этого extractPythonStringLiterals примет внешнюю пару за литерал
            // и потеряет внутренние.
            if (code.length >= 2) {
              const first = code[0];
              const last = code[code.length - 1];
              if ((first === "'" && last === "'") || (first === '"' && last === '"')) {
                code = code.slice(1, -1);
              }
            }
            for (const lit of extractPythonStringLiterals(code)) pushOp(lit);
            break;
          }
        }
      }
      continue;
    }

    // sed 's/A/B/w FILE' — флаг w в substitution пишет результат в FILE (B-025-r2-2).
    // После stripQuotes код седа доступен; ищем `w FILE` в substitution.
    if (head === 'sed') {
      // Берём все не-флаг аргументы sed (sed-выражения), ищем в них «w <путь>».
      // Структура sed-выражения: s/pattern/replacement/flags (flags могут содержать 'w')
      for (let i = 1; i < argv.length; i++) {
        const a = argv[i];
        if (a.startsWith('-')) continue;
        // Ищем «w <путь>» в substitution (после третьего слэша flags-часть)
        const wMatch = a.match(/s[\s\S]*?w\s+(\S+)/);
        if (wMatch) pushOp(wMatch[1]);
      }
      continue;
    }

    // awk 'PROGRAM' [FILE ...] — redirect внутри PROGRAM (`> FILE` или `>> FILE`).
    // FILE идёт ПОСЛЕ > — вытаскиваем из кода awk.
    if (head === 'awk' || /^g?awk$/.test(head) || /^mawk$/.test(head)) {
      for (let i = 1; i < argv.length; i++) {
        const a = argv[i];
        if (a.startsWith('-')) continue;
        // Первый не-флаг аргумент — PROGRAM; ищем redirect > или >> внутри него.
        const rMatch = a.match(/>>?\s*([\S]+|"[^"]*"|'[^']*')/);
        if (rMatch) {
          // Снимаем кавычки если есть.
          let op = rMatch[1];
          if ((op.startsWith('"') && op.endsWith('"')) ||
              (op.startsWith("'") && op.endsWith("'"))) {
            op = op.slice(1, -1);
          }
          pushOp(op);
        }
        break; // только первый не-флаг = PROGRAM
      }
      continue;
    }
  }

  return out;
}

// Токенизация shell-строки с уважением одинарных/двойных кавычек и backtick,
// а также backslash-эскейпов. Разделители команд: | & ; (вне кавычек).
function tokenizeShell(s: string): string[] {
  const out: string[] = [];
  let cur = '';
  let quote: "'" | '"' | '`' | null = null;
  let i = 0;
  while (i < s.length) {
    const ch = s[i];
    if (quote === "'") {
      // В одинарных кавычках ничего не интерпретируется (кроме закрывающей ').
      if (ch === "'") { quote = null; i++; continue; }
      cur += ch; i++; continue;
    }
    if (quote === '"' || quote === '`') {
      if (ch === '\\' && i + 1 < s.length) {
        cur += s[i + 1];
        i += 2;
        continue;
      }
      if (ch === quote) { quote = null; i++; continue; }
      cur += ch; i++; continue;
    }
    // Без кавычек.
    if (ch === "'" || ch === '"' || ch === '`') { quote = ch; i++; continue; }
    if (ch === '\\' && i + 1 < s.length) { cur += s[i + 1]; i += 2; continue; }
    if (/\s/.test(ch) || ch === '|' || ch === '&' || ch === ';') {
      if (cur.length > 0) { out.push(cur); cur = ''; }
      if (ch === '|' || ch === '&' || ch === ';') out.push(ch);
      i++; continue;
    }
    cur += ch; i++;
  }
  if (cur.length > 0) out.push(cur);
  return out;
}

// Токенизация shell-строки с СОХРАНЕНИЕМ кавычек внутри токенов. Используется
// для извлечения операндов из inline-кода ruby/node/php (B-025-r2-2):
// tokenizeShell по умолчанию выкидывает кавычки на границах токенов, и литералы
// в коде без внешней обёртки (ruby -e File.write("x.txt","X")) теряют кавычки →
// extractPythonStringLiterals ничего не находит → operands.length===0 →
// «безопасный пропуск» → pass (дыра B-025-r2-2). Здесь opening/closing кавычки
// ОСТАЮТСЯ внутри токена; внешняя обёртка снимается отдельно в
// extractExtraWriteOperands (ruby/node/php-ветка), чтобы regex литералов увидел
// внутренние строки, а не всю внешнюю пару.
function tokenizeShellKeepQuotes(s: string): string[] {
  const out: string[] = [];
  let cur = '';
  let quote: "'" | '"' | '`' | null = null;
  let i = 0;
  while (i < s.length) {
    const ch = s[i];
    if (quote === "'") {
      // В одинарных кавычках ничего не интерпретируется (кроме закрывающей ').
      if (ch === "'") { quote = null; cur += ch; i++; continue; }
      cur += ch; i++; continue;
    }
    if (quote === '"' || quote === '`') {
      if (ch === '\\' && i + 1 < s.length) {
        cur += ch + s[i + 1];
        i += 2;
        continue;
      }
      if (ch === quote) { quote = null; cur += ch; i++; continue; }
      cur += ch; i++; continue;
    }
    // Без кавычек.
    if (ch === "'" || ch === '"' || ch === '`') { quote = ch; cur += ch; i++; continue; }
    if (ch === '\\' && i + 1 < s.length) { cur += ch + s[i + 1]; i += 2; continue; }
    if (/\s/.test(ch) || ch === '|' || ch === '&' || ch === ';') {
      if (cur.length > 0) { out.push(cur); cur = ''; }
      if (ch === '|' || ch === '&' || ch === ';') out.push(ch);
      i++; continue;
    }
    cur += ch; i++;
  }
  if (cur.length > 0) out.push(cur);
  return out;
}

// Разбиение токенов на отдельные команды по операторам | & ; .
function splitShellCommands(tokens: string[]): string[][] {
  const cmds: string[][] = [];
  let cur: string[] = [];
  for (const t of tokens) {
    if (t === '|' || t === ';' || t === '&') {
      if (cur.length > 0) { cmds.push(cur); cur = []; }
    } else {
      cur.push(t);
    }
  }
  if (cur.length > 0) cmds.push(cur);
  return cmds;
}

// Извлечение строковых литералов из python-кода: оба вида кавычек, без r/f/b-префиксов.
// Подход достаточен для тестовых форм B-2: open("p"), Path("p").write_text(...),
// os.rename("a", "b"), shutil.copy("s", "d"). Тривиальные .replace/комментарии не мешают.
function extractPythonStringLiterals(code: string): string[] {
  const out: string[] = [];
  const re = /(?<![A-Za-z0-9_])(?:r|R|b|B|f|F|rb|br|RB|Br|bR|fr|rf|Fr|fR|RF|rF)?(["'])(?:\\.|(?!\1).)*\1/g;
  let m: RegExpExecArray | null;
  while ((m = re.exec(code)) !== null) {
    const full = m[0];
    // снять префикс и кавычки
    const open = full.indexOf(m[1]);
    const inner = full.slice(open + 1, full.length - 1);
    // разрешить только строки, похожие на пути: непустые, без переносов
    if (inner.length > 0 && !inner.includes('\n')) {
      out.push(inner);
    }
  }
  return out;
}

// Проверяет, что resolved-путь — внутри пина (если задан) или scratch
// ${TMPDIR:-/tmp}/dev-harness-verify. URI-схемы НЕ идут через pathAllowed
// (они обрабатываются выше — isUnpinnedInternalURI для непинна или pass
// для пина). Для НЕпиннованных сессий (canonicalWt === null) — pass ТОЛЬКО
// при попадании в scratch; всё остальное fail-closed (резолюция 2026-09-11 —
// абсолют-в-MAIN-чекаут блок).
function pathAllowed(
  resolved: string,
  canonicalWt: string | null,
  worktree: string | null,
): boolean {
  if (isAllowedURI(resolved)) return true;
  // Лексическая нормализация .. и . в ОБЕИХ allowlist-ветвях (М4 контракт 032).
  const normalized = lexNormalize(resolved);
  if (isWithin(getVerifyBase(), normalized)) return true;
  if (canonicalWt !== null && isWithin(canonicalWt, normalized)) return true;
  // Непиннованная сессия + путь не в allowlist — fail-closed (бывшая ветка
  // «worktree===null → pass» снята как корень А-72).
  void worktree;
  return false;
}

// Именованная причина для блока URI у непиннованной сессии (слово владельца
// 2026-09-11 «дыра B» + Н-85-подпись).
function unpinnedURIReason(p: string): string {
  return `внутренний URI непиннованной сессии запрещён — Н-85: дефолт-запрет, слово владельца 2026-09-11 «дыра B»: null-allowlist = ${getVerifyBase()}/**, artifact://; цель ${p}`;
}

// ── Решения для edit / write ───────────────────────────────────────────────────
function judgeEditWrite(
  args: Record<string, unknown>,
  canonicalWt: string | null,
  worktree: string | null,
): Decision {
  const path = String(args.path ?? '');
  if (!path) return { decision: 'pass' };

  // URI-схемы: pinned — pass (Г3); unpinned — ТОЛЬКО artifact://, иные внутренние
  // URI (local://, mcp://, skill://, agent://, history://, xd://) — block Н-85
  // с именованной причиной (резолюция 2026-09-11 «дыра B», дословно
  // null-allowlist = скратч/artifact). Сверка pinned/unpinned — по
  // canonicalWt (worktree был проканонизирован через safeRealpath в judge()).
  if (isAllowedURI(path)) {
    if (canonicalWt !== null) return { decision: 'pass' };
    // Контракт 030 Н-106: QA-канал xd://report_issue — точный путь без суффиксов.
    // Исключение есть путь ЦЕЛИКОМ, не схема: xd://report_issue/x и иные xd:// остаются заблокированы.
    if (path === 'xd://report_issue') return { decision: 'pass' };
    if (path.startsWith('artifact://')) return { decision: 'pass' };
    return { decision: 'block', reason: unpinnedURIReason(path) };
  }

  // Относительный путь — блок ВСЕГДА (Г1, Г2: вектор утечки).
  if (!path.startsWith('/')) {
    return {
      decision: 'block',
      reason: `относительный путь записи запрещён — Н-85: используй абсолютный путь или cwd`,
    };
  }

  // Абсолютный путь — общий pathAllowed. Пиновые сессии: pass in-pin + scratch;
  // непиннованные: pass ТОЛЬКО scratch (URI у непинна обработаны выше). Всё
  // прочее — блок (резолюция владельца 2026-09-11: непиннованный ребёнок
  // ДЕФОЛТ-ЗАПРЕЩЁН на чекаут-запись).
  if (pathAllowed(path, canonicalWt, worktree)) return { decision: 'pass' };

  return {
    decision: 'block',
    reason:
      worktree === null
        ? `запись в чекаут из непиннованной сессии запрещена — Н-85/А-122: путь ${path} не в null-allowlist (${getVerifyBase()}/**, artifact://)`
        : `запись вне пина запрещена — Н-85: путь ${path} не входит в WORKTREE=${canonicalWt ?? '(главная сессия)'} и не в allowlist`,
  };
}

// ── Решения для bash ──────────────────────────────────────────────────────────
function judgeBash(
  args: Record<string, unknown>,
  canonicalWt: string | null,
  worktree: string | null,
): Decision {
  const cmd = String(args.command ?? '');
  const cwdRaw = args.cwd;
  const cwd = typeof cwdRaw === 'string' && cwdRaw.length > 0 ? cwdRaw : null;

  if (!cmd) return { decision: 'pass' };

  // Форма чтения — всегда pass (Г1 «читать свободно»).
  if (!isWriteCommand(cmd)) return { decision: 'pass' };

  const operands = [
    ...extractFileOperands(cmd),
    ...extractExtraWriteOperands(cmd),
  ];
  if (operands.length === 0) {
    // Команда формы записи, но операндов не извлекли — безопасный пропуск,
    // чтобы не заблокировать легитимную форму записи с экзотическим синтаксисом.
    return { decision: 'pass' };
  }

  for (const op of operands) {
    // URI-схемы: pinned — pass (Г3); unpinned — ТОЛЬКО artifact://, иные
    // внутренние URI — block Н-85 (зеркало judgeEditWrite, единая семантика).
    if (isAllowedURI(op)) {
      if (canonicalWt !== null) continue;
      // Контракт 030 Н-106: QA-канал xd://report_issue — точный путь без суффиксов.
      // Зеркало judgeEditWrite: единая семантика для write- и bash-операндной ветвей.
      if (op === 'xd://report_issue') continue;
      if (op.startsWith('artifact://')) continue;
      return { decision: 'block', reason: unpinnedURIReason(op) };
    }

    let resolved: string;
    if (op.startsWith('/')) {
      resolved = op;
    } else {
      // Относительный операнд без cwd — вектор утечки.
      if (!cwd) {
        return {
          decision: 'block',
          reason: `запись относительным путём без cwd запрещена — Н-85: используй cwd или абсолютный путь`,
        };
      }
      // cwd может сам быть относительным (не в наших тестах, но безопасно склеиваем).
      const realCwd = safeRealpath(cwd) ?? cwd;
      resolved = realCwd.endsWith('/') ? `${realCwd}${op}` : `${realCwd}/${op}`;
    }

    // Непиннованная сессия + абсолютный операнд вне scratch — блок по
    // pathAllowed (резолюция 2026-09-11). URI у непинна уже отсеяны выше.
    // Пиновая + операнд вне пина и не в scratch — блок по Н-85.
    if (!pathAllowed(resolved, canonicalWt, worktree)) {
      return {
        decision: 'block',
        reason:
          worktree === null
            ? `запись в чекаут из непиннованной сессии запрещена — Н-85/А-122: путь ${resolved} не в null-allowlist (${getVerifyBase()}/**, artifact://)`
            : `запись вне пина запрещена — Н-85: путь ${resolved} не входит в WORKTREE=${canonicalWt ?? '(главная сессия)'} и не в allowlist`,
      };
    }
  }

  return { decision: 'pass' };
}

// ── Публичный judge (и CLI, и фабрика) ────────────────────────────────────────
export function judge(input: JudgeInput): Decision {
  const { tool, args } = input;
  const worktree = input.worktree ?? null;
  const actual = input.actual ?? null;

  // 1. Канонизация и сверка пина (если задан). Для пина-из-задания (М2 контракт
  // 032) сверка с actual НЕ применяется: actual процесса := cwd ведущей сессии,
  // а не worktree цели; аутентичность пина-из-задания — из грамматики М1, не cwd.
  const skipActualCheck = input.skipActualCheck === true;
  let canonicalWt: string | null = null;
  let canonicalActual: string | null = null;
  if (worktree) {
    canonicalWt = safeRealpath(worktree);
    if (canonicalWt === null) {
      return {
        decision: 'refuse',
        reason: `пинн WORKTREE не существует: ${worktree}`,
      };
    }
    if (!skipActualCheck) {
      if (actual) {
        canonicalActual = safeRealpath(actual);
        if (canonicalActual === null) canonicalActual = actual;
      } else {
        canonicalActual = canonicalWt;
      }
      if (canonicalWt !== canonicalActual) {
        return {
          decision: 'refuse',
          reason: `пинн WORKTREE не совпадает с фактическим рабочим деревом сессии (пин=${canonicalWt}, факт=${canonicalActual})`,
        };
      }
    }
  }

  // 2. Распределение по типу инструмента.
  if (tool === 'eval') {
    // eval — та же ветвь записи, что bash (Р8). Считаем поле команды
    // тем же ключом, что bash, если omp передаёт args.code / args.command.
    const evalCode = args.code !== undefined ? String(args.code) : String(args.command ?? '');
    const bashLike: Record<string, unknown> = { ...args, command: evalCode };
    return judgeBash(bashLike, canonicalWt, worktree);
  }
  if (tool === 'edit' || tool === 'write') {
    return judgeEditWrite(args, canonicalWt, worktree);
  }
  if (tool === 'bash') {
    return judgeBash(args, canonicalWt, worktree);
  }
  // read / grep / glob / прочие — pass (Г1).
  return { decision: 'pass' };
}

// ── CLI: `node path-guard.ts --judge '<json>'` ─────────────────────────────────
function runCLI(): void {
  const argv = process.argv.slice(2);
  if (argv[0] === '--extract-pin') {
    if (!argv[1]) {
      console.error('FAIL: нужен --extract-pin <text>');
      process.exit(2);
    }
    const result = extractPin(argv[1]);
    if (result.noGit) {
      // CLI-конвенция Н-85 NOT_IMPLEMENTED: инструмент, на котором держится
      // git-оракул, отсутствует — fail-closed. Фабрика идёт по тому же extractPin
      // (через extractPinFromBranch), и на noGit даёт worktree:null → сессия
      // unpinned → block Н-85 (п4н: фабрика block «Н-85»).
      console.error('NOT_IMPLEMENTED: git отсутствует — git-оракул не может судить .git-форму (spawn ENOENT; PATH без git)');
      process.exit(2);
    }
    process.stdout.write(`${JSON.stringify({ worktree: result.worktree })}\n`);
    process.exit(0);
  }
  if (argv[0] === '--judge') {
    if (!argv[1]) {
      console.error('FAIL: нужен --judge <json>');
      process.exit(2);
    }
    let input: JudgeInput;
    try {
      input = JSON.parse(argv[1]);
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : String(e);
      console.error(`FAIL: невалидный JSON: ${msg}`);
      process.exit(2);
    }
    let result: Decision;
    try {
      result = judge(input);
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : String(e);
      console.error(`FAIL: ошибка judge: ${msg}`);
      process.exit(2);
    }
    process.stdout.write(`${JSON.stringify(result)}\n`);
    process.exit(0);
  }
  console.error('FAIL: нужен --judge <json> или --extract-pin <text>');
  process.exit(2);
}

// Запуск CLI, когда файл — прямой аргумент node (не import).
if (import.meta.url === `file://${process.argv[1]}`) {
  runCLI();
}

// ── Фабрика расширения omp ────────────────────────────────────────────────────
//
// Структура omp-события tool_call (замерено живым probe025, формат ИЗ ЭТОГО ПРОГОНА):
//   { type:'tool_call', toolName:'edit'|'write'|..., toolCallId, input:<args> }
//   input — это объект arguments модели. Для edit: {i, input:'[path#tag]\n…'},
//   для write: {i, path, content}, для bash: {i, command, cwd?},
//   для read/grep/glob: {i, path}. Предыдущий код читал call.name/call.args — этих полей
//   в новом omp-событии НЕТ, handler молча пропускал любой ввод (регрессия, поймана
//   живым probe025: edit с относительным путём прошёл УСПЕХ без блока).
//
// Пин/actual берётся из event.worktree/event.actual (если omp их передаёт) иначе
// process.env.WORKTREE/process.cwd() (PI_ACTUAL env-фолбэк убран по B-025-r2-3: actual = realpath фактического cwd сессии, не env-вход). Сессия без WORKTREE —
// непиннованная: пишет ТОЛЬКО в null-allowlist = scratch ∪ artifact:/
// (резолюция 2026-09-11 «дыра B»; local://, mcp://, skill:// — не исключение;
// fix 025 правка-круг 3).
type PiLike = {
  on?: (name: string, handler: (...args: unknown[]) => unknown) => unknown;
};

function isToolCallEvent(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === 'object';
}

// Для edit path лежит в args.input строкой `[path#tag]\n…` — формат формата guide omp.
// tag опционален (после #). Нормализуем: кладём extracted path в args.path для judgeEditWrite.
function extractEditPath(args: Record<string, unknown>): void {
  if (args.path) return;
  const raw = typeof args.input === 'string' ? args.input : '';
  const m = raw.match(/^\[([^\]#]+)(?:#[^\]]+)?\]/);
  if (m && m[1]) args.path = m[1];
}

export default function register(pi: unknown): void {
  if (!pi || typeof pi !== 'object') return;
  const p = pi as PiLike;
  if (typeof p.on !== 'function') return;

  // Lifecycle (М2 контракт 032): каждое из трёх событий — самостоятельный
  // источник восстановления пина из ПЕРВОЙ user-записи ветки. session_start,
  // session_branch, session_tree (п12: branch/tree поднимают пин и без start).
  const lifecycle = (_event: unknown, ctx: unknown): void => {
    const sid = getSessionId(ctx);
    if (typeof sid !== 'string') return;
    const branch = getBranch(ctx);
    sessionPins.set(sid, extractPinFromBranch(branch));
  };
  p.on('session_start', lifecycle);
  p.on('session_branch', lifecycle);
  p.on('session_tree', lifecycle);

  p.on('tool_call', (call: unknown, ctx: unknown) => {
    if (!isToolCallEvent(call)) return undefined;
    const name = typeof call.toolName === 'string' ? call.toolName : '';
    const raw = call.input;
    const args: Record<string, unknown> = raw !== undefined && raw !== null && typeof raw === 'object'
      ? (raw as Record<string, unknown>)
      : {};
    if (name === 'edit') extractEditPath(args);

    // Источники пина (М2; п13–п15 приоритеты): событие > env > пин-задания.
    const envWorktree = process.env.WORKTREE ?? null;
    const envActual = process.cwd();
    const eventWorktree = typeof call.worktree === 'string' ? call.worktree : null;
    const eventActual = typeof call.actual === 'string' ? call.actual : null;

    const sid = getSessionId(ctx);
    let assignmentPin = sid !== null ? (sessionPins.get(sid) ?? null) : null;

    // Вариант D (живая проводка, дизайн Architect032A1): если оба старших источника
    // (событие, env) пусты и из sessionPins пин не получен — попытка ленивого
    // подъёма из ветки сессии. Мемоизируем ТОЛЬКО ненулевой результат: null
    // оставляем для повтора на следующем call (lifecycle мог записать null на
    // пустой ветке, и его надо уметь перебить).
    if (eventWorktree === null && envWorktree === null && assignmentPin === null) {
      const lifted = extractPinFromBranch(getBranch(ctx));
      if (lifted !== null) {
        if (sid !== null) sessionPins.set(sid, lifted);
        assignmentPin = lifted;
      }
    }

    let worktree: string | null;
    let actual: string;
    let skipActualCheck = false;
    if (eventWorktree !== null) {
      worktree = eventWorktree;
      actual = eventActual ?? envActual;
    } else if (envWorktree !== null) {
      worktree = envWorktree;
      actual = eventActual ?? envActual;
    } else if (assignmentPin !== null) {
      // М2: для пина-из-задания сверка с actual НЕ применяется (аутентичность
      // пина — из грамматики М1, actual процесса := cwd ведущей сессии, не worktree цели).
      worktree = assignmentPin;
      actual = eventActual ?? envActual;
      skipActualCheck = true;
    } else {
      worktree = null;
      actual = eventActual ?? envActual;
    }

    let result: Decision;
    try {
      result = judge({ tool: name, args, worktree, actual, skipActualCheck });
    } catch {
      return { block: true, reason: 'Н-85: внутренняя ошибка стража пути' };
    }
    if (result.decision === 'pass') return undefined;
    return { block: true, reason: result.reason };
  });
}
