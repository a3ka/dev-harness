# Красное предъявление 2/3 контракта 030 — Н-106: QA-канал xd://report_issue.
#
# Субъект — реальный страж .omp/extensions/path-guard.ts, вход — его CLI --judge
# (механика та же, что scripts/drill_path_guard.sh). Порядок: сначала границы
# (зелёные сегодня и после предмета) — в ОБЕИХ формах, write-ветвью И bash-операндным
# зеркалом; затем предъявления (красные сегодня — замер пачки: обе формы block —
# зелёные после предмета). Круг 1, Б2: tee-позитив не доказывает ОТРИЦАТЕЛЬНЫЕ
# границы второго зеркала — у обеих ветвей-потребителей своя пара граничных входов.
# Круг 2 (вердикт f493247, A-030-2): «edit/write-ветвь» — ДВЕ ветви, а не одна:
# edit-форма carve-out и его границы проверяются СВОИМИ входами (10-14), и живой
# инструмент — не только CLI: default-фабрика обязана зарегистрировать tool_call
# handler с той же семантикой (factory-блок; формат живого события — :701-704).
#
# СТАБ-ПРИВЯЗКИ (Н-39: живут здесь, не в прозе контракта):
#   S-any-xd    — «всякий xd:// у непинна pass»: умирает на входе 1 (суффикс
#                 xd://report_issue/x, write) и входе 2 (чужой xd://other, write);
#   S-wide-bash — «bash-операндное зеркало широко: всякий xd:// в операнде pass»
#                 (исполненный обход круга 1: узкий judgeEditWrite + широкий
#                 judgeBash startsWith('xd://')): умирает на входах 5–7 —
#                 tee-формы тех же границ (суффикс/чужой xd/local://), которые в
#                 write-форме остаются block;
#   S-all-uri   — «все внутренние URI у непинна pass»: умирает на входе 3
#                 (local:// — регресс-канарейка 025) и входе 7 (tee local://);
#   S-all-block — «всё block»: умирает на входе 4 (пинн) и предъявлениях 8/9/10;
#   S-write-only — «pass только в write-ветви, edit-ветвь блокирует» (контрреали-
#                 зация вердикта f493247 A-030-2: прошла приёмку круга 1, потому
#                 что проба слала только tool:"write"): умирает на входе 10 —
#                 edit точного пути у непинна обязан pass (инвариант 2.5), и на
#                 входах 11-13 (edit-границы зеркала), 14 (пинн edit);
#   S-cli-only  — «--judge решает верно, но живой инструмент (default-фабрика)
#                 не регистрирует tool_call / handler без carve-out»: умирает на
#                 factory-блоке ниже (write/edit точный путь без блока, суффикс —
#                 блок; замер по drill_path_guard — фабрика обязана существовать);
#   S-pred-only — «правка одного isUnpinnedInternalURI выдаёт за решение» (замер
#                 А-175: предикат решениями не потребляется): умирает на
#                 предъявлениях 8/9/10 — все формы остаются block.
set -uo pipefail

REPO="$(cd "$(dirname "$0")/../.." && pwd -P)"
command -v node >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет node\n' >&2; exit 2; }
TS="$REPO/.omp/extensions/path-guard.ts"
[ -f "$TS" ] || { printf 'NOT_IMPLEMENTED: страж не найден: %s\n' "$TS" >&2; exit 2; }
# фабричный handler берёт пин из event.worktree, иначе process.env.WORKTREE
# (:745-748) — снимаем, чтобы factory-проверка судила ИМЕННО непиннованную сессию.
unset WORKTREE || true

judge_decision() {
  node "$TS" --judge "$1" 2>/dev/null | node -e '
    let s=""; process.stdin.on("data",d=>s+=d).on("end",()=>{
      try { const j=JSON.parse(s); process.stdout.write(j.decision??"BAD"); }
      catch { process.stdout.write("BAD_JSON"); }
    });'
}
judge_reason() {
  node "$TS" --judge "$1" 2>/dev/null | node -e '
    let s=""; process.stdin.on("data",d=>s+=d).on("end",()=>{
      try { const j=JSON.parse(s); process.stdout.write(j.reason??""); } catch {}
    });'
}
ozhidat() {  # <метка> <ожидаемое решение> <json события>
  local label="$1" want="$2" evt="$3" got
  got="$(judge_decision "$evt")"
  [ "$got" = "$want" ] || {
    printf 'ОТКАЗ: %s — ожидалось %s, получено %s (%s)\n' "$label" "$want" "$got" "$(judge_reason "$evt")" >&2
    exit 1
  }
}

PIN="$(mktemp -d "${TMPDIR:-/tmp}/qa030pin.XXXXXX")"
trap 'rm -rf "$PIN"' EXIT

# ── границы, write-форма: зелёные сегодня, остаются зелёными после предмета ──
ozhidat '1) суффикс точного пути (xd://report_issue/x) у непинна, write → block — исключение есть путь ЦЕЛИКОМ, не схема' \
  block '{"tool":"write","args":{"path":"xd://report_issue/x"},"worktree":null,"actual":null}'
ozhidat '2) чужой xd://other у непинна, write → block (узость)' \
  block '{"tool":"write","args":{"path":"xd://other"},"worktree":null,"actual":null}'
ozhidat '3) local:// у непинна, write → block (регресс-канарейка 025, инвариант 2.3)' \
  block '{"tool":"write","args":{"path":"local://030/f"},"worktree":null,"actual":null}'
ozhidat '4) xd://report_issue у ПИННА, write → pass (Г3 без изменений, инвариант 2.4)' \
  pass  "{\"tool\":\"write\",\"args\":{\"path\":\"xd://report_issue\"},\"worktree\":\"$PIN\",\"actual\":\"$PIN\"}"

# ── границы, bash-операндное зеркало (круг 1, Б2): те же границы своей парой ──
ozhidat '5) суффикс в bash-операндной форме (tee xd://report_issue/x) у непинна → block — второе зеркало не шире write-ветви' \
  block '{"tool":"bash","args":{"command":"tee xd://report_issue/x"},"worktree":null,"actual":null}'
ozhidat '6) чужой xd://other в bash-операндной форме (tee) у непинна → block — узость второго зеркала' \
  block '{"tool":"bash","args":{"command":"tee xd://other"},"worktree":null,"actual":null}'
ozhidat '7) local:// в bash-операндной форме (tee) у непинна → block — зеркало держит инвариант 025' \
  block '{"tool":"bash","args":{"command":"tee local://030/f"},"worktree":null,"actual":null}'

# ── предъявления: красные сегодня (замер пачки: обе block), зелёные после ────
ozhidat '8) QA-канал xd://report_issue у непинна, write-форма → pass (Н-106)' \
  pass '{"tool":"write","args":{"path":"xd://report_issue"},"worktree":null,"actual":null}'
ozhidat '9) QA-канал xd://report_issue у непинна, bash-операндная форма (tee) → pass — единая семантика ветвей (инвариант 2.5)' \
  pass '{"tool":"bash","args":{"command":"tee xd://report_issue"},"worktree":null,"actual":null}'

# ── edit-ветвь carve-out (вердикт f493247, A-030-2): «edit/write» — ДВЕ ветви ──
ozhidat '10) QA-канал xd://report_issue у непинна, edit-форма → pass — решение для пары (путь, пинн) одинаково в edit/write-ветви (инвариант 2.5)' \
  pass '{"tool":"edit","args":{"path":"xd://report_issue"},"worktree":null,"actual":null}'
ozhidat '11) суффикс точного пути (xd://report_issue/x) у непинна, edit → block — исключение путь ЦЕЛИКОМ и в edit-ветви' \
  block '{"tool":"edit","args":{"path":"xd://report_issue/x"},"worktree":null,"actual":null}'
ozhidat '12) чужой xd://other у непинна, edit → block — узость и в edit-ветви' \
  block '{"tool":"edit","args":{"path":"xd://other"},"worktree":null,"actual":null}'
ozhidat '13) local:// у непинна, edit → block — регресс-канарейка 025 в edit-форме' \
  block '{"tool":"edit","args":{"path":"local://030/f"},"worktree":null,"actual":null}'
ozhidat '14) xd://report_issue у ПИННА, edit → pass (Г3 без изменений, обе ветви)' \
  pass  "{\"tool\":\"edit\",\"args\":{\"path\":\"xd://report_issue\"},\"worktree\":\"$PIN\",\"actual\":\"$PIN\"}"

# ── factory-регистрация расширения (A-030-2): живой инструмент, не только CLI ──
# default-экспорт обязан зарегистрировать tool_call handler, повторяющий carve-out
# на живом формате события ({toolName, toolCallId, input}; edit-путь — из
# '[path#tag]'-заголовка, :722-729). Непинн: event без worktree, WORKTREE снят.
FPI="$(mktemp "${TMPDIR:-/tmp}/qa030pi.XXXXXX.mjs")"
cat > "$FPI" <<'EOF'
import path from 'node:path';
const reg = { tool_call: null };
const fake = {
  on(name, h) { if (name === 'tool_call') reg.tool_call = h; },
  run(c) { return { exitCode: 0 }; },
  sendMessage(s) {}
};
globalThis.reg = reg;
const mod = await import(path.resolve(process.argv[2]));
if (typeof mod.default !== 'function') { console.error('фабрика: default не функция'); process.exit(1); }
mod.default(fake);
if (!globalThis.reg.tool_call) { console.error('фабрика: handler tool_call не зарегистрирован'); process.exit(1); }
const cases = [
  ['write точный путь xd://report_issue у непинна — без блока',
   { toolName: 'write', toolCallId: 'qa030', input: { i: 'qa', path: 'xd://report_issue', content: '{}' } }, false],
  ['edit точный путь xd://report_issue у непинна — без блока',
   { toolName: 'edit', toolCallId: 'qa030', input: { i: 'qa', input: '[xd://report_issue#A1B2]\nPUT 1.=1:\n+x' } }, false],
  ['edit суффикс xd://report_issue/x у непинна — блок',
   { toolName: 'edit', toolCallId: 'qa030', input: { i: 'qa', input: '[xd://report_issue/x#A1B2]\nPUT 1.=1:\n+x' } }, true],
];
for (const [label, ev, wantBlock] of cases) {
  const r = await globalThis.reg.tool_call(ev);
  const blocked = !!(r && r.block === true);
  if (blocked !== wantBlock) { console.error('фабрика: ' + label + ' — ' + JSON.stringify(r)); process.exit(1); }
}
console.log('OK');
EOF
fout="$(node "$FPI" "$TS" 2>&1)"; frc=$?
rm -f "$FPI"
[ "$frc" -eq 0 ] && [ "$fout" = "OK" ] || {
  printf 'ОТКАЗ: factory-путь расширения: handler не зарегистрирован или не несёт carve-out (A-030-2):\n%s\n' "$fout" >&2
  exit 1
}

exit 0
