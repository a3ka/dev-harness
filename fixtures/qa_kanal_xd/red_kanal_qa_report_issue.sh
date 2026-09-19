# Красное предъявление 2/3 контракта 030 — Н-106: QA-канал xd://report_issue.
#
# Субъект — реальный страж .omp/extensions/path-guard.ts. Круг 3 (вердикт
# 3722adf, A-030-5): «CLI верен, factory нет» — контрrealизация к2 реализовала
# все 14 CLI-предъявлений корректно, но factory-handler блокировал только один
# вход (edit xd://report_issue/x), остальные живые factory-вызовы получали
# undefined; проба к2 судила factory тремя точечными входами и прошла зелёной.
# Закрытие класса ЦЕЛИКОМ, не точечно: ДИФФЕРЕНЦИАЛЬНЫЙ ОРАКУЛ CLI↔factory —
# ОДНА таблица входов (write/edit/bash-операнд × точный xd://report_issue /
# суффикс / чужой xd://other / local:// × pinned/unpinned), каждый вход судится
# в ОБОИХ каналах — CLI --judge И живой factory-handler — и решения ОБЯЗАНЫ
# совпадать с таблицей в обоих каналах. Грамматика событий — один конструктор
# events() на оба канала (переизобретение формата запрещено). Гард полноты:
# суждено строк меньше заявленных — СЛОМ, не зелёное.
#
# СТАБ-ПРИВЯЗКИ (Н-39: живут здесь, не в прозе контракта):
#   S-any-xd    — «всякий xd:// у непинна pass»: умирает на входе 1 (суффикс,
#                 write) в ОБОИХ каналах;
#   S-wide-bash — «bash-операндное зеркало широко: всякий xd:// в операнде pass»:
#                 умирает на входах 5–7 (tee-формы суффикс/чужой xd/local://);
#   S-all-uri   — «все внутренние URI у непинна pass»: умирает на входе 3
#                 (local:// — регресс-канарейка 025) и входе 7 (tee local://);
#   S-all-block — «всё block»: умирает на входах 4/14/15 (пинны) и 8/9/10
#                 (предъявления carve-out);
#   S-write-only — «pass только в write-ветви, edit-ветвь блокирует» (A-030-2,
#                 вердикт f493247): умирает на входе 10 — edit точного пути у
#                 непинна обязан pass — в ОБОИХ каналах;
#   S-cli-only  — «--judge решает верно, но factory не регистрирует handler
#                 tool_call / default не функция»: умирает на регистрации
#                 factory в драйвере ниже;
#   S-fac-split — «CLI верен, factory пропускает иные непиннованные xd://»
#                 (A-030-5, вердикт 3722adf — ИСПОЛЕННАЯ контрrealизация к2:
#                 блокировался только edit xd://report_issue/x, прочие живые
#                 factory-вызовы возвращали undefined): умирает на FACTORY-
#                 проверке входа 1 (write-суффикс → block) — первого block-
#                 ожидаемого входа таблицы в factory-канале;
#   S-pred-only — «правка одного isUnpinnedInternalURI выдаёт за решение»
#                 (замер А-175): умирает на входах 8/9/10 — все формы block.
set -uo pipefail

REPO="$(cd "$(dirname "$0")/../.." && pwd -P)"
command -v node >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет node\n' >&2; exit 2; }
TS="$REPO/.omp/extensions/path-guard.ts"
[ -f "$TS" ] || { printf 'NOT_IMPLEMENTED: страж не найден: %s\n' "$TS" >&2; exit 2; }
# фабричный handler берёт пин из event.worktree, иначе process.env.WORKTREE
# (:745-748) — снимаем, чтобы factory-проверка судила ИМЕННО непиннованную сессию.
unset WORKTREE || true

PIN="$(mktemp -d "${TMPDIR:-/tmp}/qa030pin.XXXXXX")"
trap 'rm -rf "$PIN"' EXIT

# ── дифференциальный оракул (A-030-5): одна таблица, два канала ────────────────
ORACLE="$(mktemp "${TMPDIR:-/tmp}/qa030oracle.XXXXXX.mjs")"
cat > "$ORACLE" <<'EOF'
import { spawnSync } from 'node:child_process';
import path from 'node:path';
const ts = path.resolve(process.argv[2]);
const pin = process.argv[3];

// ЕДИНАЯ грамматика событий: один конструктор на ОБОА канала — CLI-событие
// {tool,args,worktree,actual} и живое omp-событие {toolName,toolCallId,input,
// worktree,actual} строятся из ОДНОГО (tool, операнд, пинн). Переизобретение
// формата в каналах запрещено: разъезжаться могут только решения, не входы.
function events(tool, operand, pinVal) {
  let input, args;
  if (tool === 'bash') {
    input = { i: 'qa', command: operand };              // живой формат bash
    args = { command: operand };                        // CLI-формат bash
  } else if (tool === 'edit') {
    input = { i: 'qa', input: `[${operand}#A1B2]\nPUT 1.=1:\n+x` };  // edit-путь из '[path#tag]'-заголовка
    args = { path: operand };
  } else {
    input = { i: 'qa', path: operand, content: '{}' };  // живой формат write
    args = { path: operand };
  }
  const cli = { tool, args, worktree: pinVal ?? null, actual: pinVal ?? null };
  const fac = { toolName: tool, toolCallId: 'qa030', input };
  if (pinVal) { fac.worktree = pinVal; fac.actual = pinVal; }
  return { cli, fac };
}

// Регистрация factory (S-cli-only): default-экспорт обязан зарегистрировать
// tool_call handler — живой инструмент, не только CLI.
const reg = { tool_call: null };
const fake = {
  on(name, h) { if (name === 'tool_call') reg.tool_call = h; },
  run() { return { exitCode: 0 }; },
  sendMessage() {},
};
const mod = await import(ts);
if (typeof mod.default !== 'function') { console.error('фабрика: default не функция'); process.exit(1); }
mod.default(fake);
if (!reg.tool_call) { console.error('фабрика: handler tool_call не зарегистрирован'); process.exit(1); }

// ОДНА таблица входов (A-030-5): каждая строка судится в ОБОИХ каналах.
const rows = [
  ['1) суффикс точного пути (xd://report_issue/x) у непинна, write → block — исключение есть путь ЦЕЛИКОМ, не схема', 'write', 'xd://report_issue/x', false, 'block'],
  ['2) чужой xd://other у непинна, write → block (узость)', 'write', 'xd://other', false, 'block'],
  ['3) local:// у непинна, write → block (регресс-канарейка 025)', 'write', 'local://030/f', false, 'block'],
  ['4) xd://report_issue у ПИННА, write → pass (Г3 без изменений)', 'write', 'xd://report_issue', true, 'pass'],
  ['5) суффикс в bash-операндной форме (tee xd://report_issue/x) у непинна → block — зеркало не шире write-ветви', 'bash', 'tee xd://report_issue/x', false, 'block'],
  ['6) чужой xd://other в bash-операндной форме (tee) у непинна → block — узость зеркала', 'bash', 'tee xd://other', false, 'block'],
  ['7) local:// в bash-операндной форме (tee) у непинна → block — зеркало держит инвариант 025', 'bash', 'tee local://030/f', false, 'block'],
  ['8) QA-канал xd://report_issue у непинна, write-форма → pass (Н-106)', 'write', 'xd://report_issue', false, 'pass'],
  ['9) QA-канал в bash-операндной форме (tee) у непинна → pass — единая семантика ветвей', 'bash', 'tee xd://report_issue', false, 'pass'],
  ['10) QA-канал у непинна, edit-форма → pass — решение для пары (путь, пинн) одинаково в edit/write-ветви', 'edit', 'xd://report_issue', false, 'pass'],
  ['11) суффикс точного пути у непинна, edit → block — исключение путь ЦЕЛИКОМ и в edit-ветви', 'edit', 'xd://report_issue/x', false, 'block'],
  ['12) чужой xd://other у непинна, edit → block — узость и в edit-ветви', 'edit', 'xd://other', false, 'block'],
  ['13) local:// у непинна, edit → block — регресс-канарейка 025 в edit-форме', 'edit', 'local://030/f', false, 'block'],
  ['14) xd://report_issue у ПИННА, edit → pass (Г3, обе ветви)', 'edit', 'xd://report_issue', true, 'pass'],
  ['15) QA-канал в bash-операндной форме у ПИННА → pass — пинн снимает URI-дефолт и в зеркале', 'bash', 'tee xd://report_issue', true, 'pass'],
];
const ZAYAVLENO = rows.length;
let SUZDENO = 0;
for (const [label, tool, operand, pinned, want] of rows) {
  const { cli, fac } = events(tool, operand, pinned ? pin : null);
  // канал 1: CLI --judge (та же механика, что scripts/drill_path_guard.sh)
  const j = spawnSync(process.execPath, [ts, '--judge', JSON.stringify(cli)], { encoding: 'utf8' });
  if (j.status !== 0) {
    console.error(`ОТКАЗ: ${label} — CLI rc=${j.status}: ${(j.stderr || '').trim()}`);
    process.exit(1);
  }
  let d = null, reason = '';
  try { const o = JSON.parse(j.stdout); d = o.decision ?? null; reason = o.reason ?? ''; }
  catch { console.error(`ОТКАЗ: ${label} — CLI выход не JSON: ${j.stdout.trim()}`); process.exit(1); }
  if (d !== want) {
    console.error(`ОТКАЗ: ${label} — CLI: ожидалось ${want}, получено ${d} (${reason})`);
    process.exit(1);
  }
  // канал 2: живой factory-handler ({block,reason} | undefined)
  const r = await reg.tool_call(fac);
  const blocked = !!(r && r.block === true);
  if (blocked !== (want === 'block')) {
    console.error(`ОТКАЗ: ${label} — FACTORY: ожидалось ${want}, получено ${r === undefined ? 'undefined (нет блока)' : JSON.stringify(r)}`);
    process.exit(1);
  }
  SUZDENO++;
}
if (SUZDENO !== ZAYAVLENO) {
  console.error(`СЛОМ: суждено ${SUZDENO} из ${ZAYAVLENO} строк таблицы — обход не бывает зелёным`);
  process.exit(2);
}
console.log(`OK ${SUZDENO}/${ZAYAVLENO}`);
EOF
out="$(node "$ORACLE" "$TS" "$PIN" 2>&1)"; rc=$?
rm -f "$ORACLE"
if [ "$rc" -eq 0 ]; then
  case "$out" in
    'OK '*) exit 0 ;;
  esac
fi
printf 'ОТКАЗ: дифференциальный оракул CLI↔factory (A-030-5) — таблица входов, оба канала:\n%s\n' "$out" >&2
exit 1
