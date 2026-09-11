// Расширение omp: страж вектора утечки + пин WORKTREE.
// Контракт 025, пачка A (вектор) и C (пин/allowlist, Г1-Г3).
//
// Два режима:
//   1. CLI: `node path-guard.ts --judge '<json>'` — синтетический tool_call,
//      выход одна строка JSON {"decision":"block|pass|refuse","reason":"…"} | rc 2.
//   2. Factory: default-export; omp грузит расширение на старте сессии; на
//      tool_call-событие фабрика судит вызов и возвращает {block,reason} или
//      undefined. Ошибки handler'а трактуются как fail-closed (omp сам).
//
// Решения (контракт 025 §Пачка A-1, §Пачка C-1):
//   - edit/write ОТНОСИТЕЛЬНЫМ path → block «Н-85: абсолютный путь или cwd».
//   - bash форма записи + относительный операнд + нет cwd → block «Н-85».
//   - запись АБСОЛЮТНАЯ в-пинне + actual == pin → pass.
//   - запись абсолютная вне пина (включая чужой корень) → block «Н-85».
//   - pin не существует → refuse «не существует».
//   - pin ≠ actual → refuse «не совпадает».
//   - dev-harness-verify, artifact://, local://, skill://, agent://,
//     history://, xd:// — allowlist (Г3); pass.
//   - read/grep/glob и bash без формы записи — pass (Г1 «читать свободно»).
//   - worktree:null (главная сессия) — пина нет, относительная запись всё равно
//     блокируется ветвью A-1; абсолютная запись свободна по общим правилам.

import { realpathSync } from 'node:fs';

// ── Allowlist URI-схем (Г3 «internal URI харнеса») ─────────────────────────────
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
};

// ── Утилиты ───────────────────────────────────────────────────────────────────
function isAllowedURI(p: string): boolean {
  return URI_SCHEMES.some((s) => p.startsWith(s));
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

  // tee / cp / mv / rm / dd — каждый не-флаг аргумент (после ключевого слова
  // и до следующего оператора | & ; или конца команды).
  for (const kw of ['tee', 'cp', 'mv', 'rm', 'dd']) {
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

// Проверяет, что resolved-путь — внутри пина или allowlist'а. canonicalWt может
// быть null (главная сессия) — тогда проверка только allowlist'а.
function pathAllowed(
  resolved: string,
  canonicalWt: string | null,
  worktree: string | null,
): boolean {
  if (isAllowedURI(resolved)) return true;
  if (worktree === null || canonicalWt === null) return true;
  if (isWithin(canonicalWt, resolved)) return true;
  if (isWithin(getVerifyBase(), resolved)) return true;
  return false;
}

// ── Решения для edit / write ───────────────────────────────────────────────────
function judgeEditWrite(
  args: Record<string, unknown>,
  canonicalWt: string | null,
  worktree: string | null,
): Decision {
  const path = String(args.path ?? '');
  if (!path) return { decision: 'pass' };

  // Allowlist URI
  if (isAllowedURI(path)) return { decision: 'pass' };

  // Относительный путь — всегда блок (Г1, Г2: вектор утечки).
  if (!path.startsWith('/')) {
    return {
      decision: 'block',
      reason: `относительный путь записи запрещён — Н-85: используй абсолютный путь или cwd`,
    };
  }

  // Главная сессия (worktree:null) — пина нет; абсолютная запись свободна.
  if (worktree === null) return { decision: 'pass' };

  // Абсолютный путь в пинне или allowlist'е — pass.
  if (pathAllowed(path, canonicalWt, worktree)) return { decision: 'pass' };

  return {
    decision: 'block',
    reason: `запись вне пина запрещена — Н-85: путь ${path} не входит в WORKTREE=${canonicalWt}`,
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

  const operands = extractFileOperands(cmd);
  if (operands.length === 0) {
    // Команда формы записи, но операндов не извлекли — безопасный пропуск,
    // чтобы не заблокировать легитимную форму записи с экзотическим синтаксисом.
    return { decision: 'pass' };
  }

  for (const op of operands) {
    if (isAllowedURI(op)) continue;

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

    if (!pathAllowed(resolved, canonicalWt, worktree)) {
      return {
        decision: 'block',
        reason: `запись вне пина запрещена — Н-85: путь ${resolved} не входит в WORKTREE=${canonicalWt ?? '(главная сессия)'} и не в allowlist`,
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

  // 1. Канонизация и сверка пина (если задан).
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
  const i = argv.indexOf('--judge');
  if (i === -1 || !argv[i + 1]) {
    console.error('FAIL: нужен --judge <json>');
    process.exit(2);
  }
  let input: JudgeInput;
  try {
    input = JSON.parse(argv[i + 1]);
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

// Запуск CLI, когда файл — прямой аргумент node (не import).
if (import.meta.url === `file://${process.argv[1]}`) {
  runCLI();
}

// ── Фабрика расширения omp ────────────────────────────────────────────────────
//
// Структура omp-события tool_call (замерено живым probe025, формат ИЗ ЭТОГО ПРОГОНА):
//   { type:'tool_call', toolName:'edit'|'write'|..., toolCallId, input:<args> }
//   input — это объект arguments модели. Для edit: {i, input:'[path#tag]\nPUT …'},
//   для write: {i, path, content}, для bash: {i, command, cwd?},
//   для read/grep/glob: {i, path}. Предыдущий код читал call.name/call.args — этих полей
//   в новом omp-событии НЕТ, handler молча пропускал любой ввод (регрессия, поймана
//   живым probe025: edit с относительным путём прошёл УСПЕХ без блока).
//
// Пин/actual берётся из event.worktree/event.actual (если omp их передаёт) иначе
// process.env.WORKTREE/process.env.PI_ACTUAL/process.cwd(). Сессия без WORKTREE —
// главная: allowlist не сужается, но относительная запись всё равно блокируется
// ветвью A-1 (контракт Г1: «страж целит вектор»).
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

  p.on('tool_call', (call: unknown) => {
    if (!isToolCallEvent(call)) return undefined;
    const name = typeof call.toolName === 'string' ? call.toolName : '';
    const raw = call.input;
    const args: Record<string, unknown> = raw !== undefined && raw !== null && typeof raw === 'object'
      ? (raw as Record<string, unknown>)
      : {};
    if (name === 'edit') extractEditPath(args);

    const envWorktree = process.env.WORKTREE ?? null;
    const envActual = process.env.PI_ACTUAL ?? process.cwd();
    const worktree = typeof call.worktree === 'string' ? call.worktree : envWorktree;
    const actual = typeof call.actual === 'string' ? call.actual : envActual;

    let result: Decision;
    try {
      result = judge({ tool: name, args, worktree, actual });
    } catch {
      return { block: true, reason: 'Н-85: внутренняя ошибка стража пути' };
    }
    if (result.decision === 'pass') return undefined;
    return { block: true, reason: result.reason };
  });
}
