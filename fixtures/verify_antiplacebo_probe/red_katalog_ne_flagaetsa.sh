#!/usr/bin/env bash
# Красное предъявление 034, боль 1 — probe-only каталог НЕ флагается раннером:
# полный И scoped И --changed режимы; плюс различающие ворота к1-Б1/к1-Б2
# (вердикт критика 39aa9fc: оба обхода исполнены им на подменённых копиях).
#
# ЗАМЕР БОЛИ (живое дерево, 6c4adc5): scoped-прогон любой семьи красен ДО её
# собственной работы — «bash scripts/verify_antiplacebo.sh --scope next_id» →
# rc 1, «расхождений: 2»: FAIL fixtures/qa_kanal_xd + FAIL fixtures/workshop_inventory
# («фикстура без барьера»), семья next_id зелёная 1/1. CI красен с ec11c86, суды
# всех контрактов заблокированы check_ci_gate.
#
# СУБЪЕКТ: живой scripts/verify_antiplacebo.sh (+ scope_select.sh) на мини-дереве
# (helpers _mini.sh): probe-каталог промаркирован .probe-only, несёт red_* и НЕ
# несёт case_* — легальная форма (прецеденты 024/025/026: red_* вне case-глоба).
#
# ВОРОТА (каждое — свой вход, свой режим; отказ называет ворота и хвост вывода):
#   1 полный:    раннер без --scope на мини-дереве → rc 0.
#   2 scoped:    раннер --scope toy_barrier → rc 0 (выбранная семья зелёная,
#                посторонний probe-каталог не флагается ДО scoped-фильтра).
#   3 --changed: коммит-диффа ТОЛЬКО по файлу probe-каталога → rc 0 (правка
#                probe-only ничего не выбирает: 0 задетых, «нечего гонять» —
#                не «неизвестный ключ» и не пустая выборка барьеров).
#   4 к1-Б1:     нелегальный каталог ВНЕ диффа (fixtures/stranaja/case_bad.sh:
#                case_* без барьерного ключа и без маркера; вторая форма — тот
#                же каталог с маркером: маркер ∧ case_* = смешение ролей) +
#                легальная probe-правка в диффе → нулевая выборка «нечего
#                гонять» НЕ легализует дерево: --changed обязан отказать rc 1
#                с именованным «FAIL fixtures/stranaja». Стаб: реализация,
#                сохранившая ранний выход «MODE: none / exit 0» при нулевой
#                выборке, — §2 печатает FAIL, но код 0; дефект наблюдаем ровно
#                на этом входе (контрпример A вердикта). На живом ДО-дереве
#                ворота даёт rc 1 по чужой причине (пустая выборка барьеров) —
#                краснота предъявлена на стобе, не на живом дефекте.
#   5 к1-Б2:     нуль выбора наблюдаем ВЫВОДОМ, не rc 0: прямой вызов селектора
#                мини-дерева (дифф — только probe-правка) обязан дать строку
#                «MODE: needs-full» с кодом 2 и БЕЗ строк «KEY: »; раннер —
#                строку «MODE: none» и ни одного исполненного case (в выводе
#                нет case_porcha). Стаб: селектор, заменяющий пропуск probe-
#                правки консервативным полным прогоном (MODE: full — контрпри-
#                мер B вердикта): rc раннера тот же 0 и ворота 3 его принимает,
#                эти ворота обязаны краснеть.
#
# СЕГОДНЯ (раннер класса не знает) ворота 1–3 красны именованным флагом
# «фикстура без барьера»/пустой выборкой; ворота 5 красна выбором постороннего
# ключа (селектор живого дерева: «MODE: scoped / KEY: probe_subject», rc 0 —
# выбран ключ, а не нуль). После предмета (реализация 034) все пять ворот rc 0.
#
# Н-39: дефект раннера-ДО (флаг легального probe-каталога) наблюдаем ровно на
# входе «каталог с маркером, red_*, без case_*, без барьерного ключа» в режимах
# ворот 1–3; на каталоге БЕЗ маркера или С case_* дефект не наблюдаем — те входы
# держит red_granicy_klassa.sh (границы класса, не ослабление). Ворота 4/5 —
# пары «стаб пост-реализационного класса ↔ различающий вход» из вердикта к1
# (Б1: ранний exit 0; Б2: консервативный full); каждая красна ровно на своём
# стобе и не судит вход, где её ожидание не различимо.
set -uo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd -P)"
. "$(dirname "$0")/_mini.sh"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/probe034a.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

otkaz() {  # <ворота> <rc> <вывод>
  printf 'ОТКАЗ: ворота %s — rc %s\n' "$1" "$2" >&2
  printf '%s\n' "$3" | tail -n 6 | sed 's/^/    /' >&2
  exit 1
}
beg="$WORK/mini"
mk_mini "$beg"

# ── ворота 1: полный прогон ──────────────────────────────────────────────────
g1="$WORK/g1"; cp -r "$beg" "$g1"
out="$(VERIFY_ANTIPLACEBO_SCRATCH="$WORK/scr1" bash "$REPO/scripts/verify_antiplacebo.sh" "$g1" 2>&1)"; rc=$?
[ "$rc" -eq 0 ] || otkaz 1 "$rc" "$out"
printf 'ворота 1 (полный): rc 0 — probe-only каталог не флагается\n' >&2

# ── ворота 2: scoped-прогон выбранной семьи ──────────────────────────────────
g2="$WORK/g2"; cp -r "$beg" "$g2"
out="$(VERIFY_ANTIPLACEBO_SCRATCH="$WORK/scr2" bash "$REPO/scripts/verify_antiplacebo.sh" "$g2" --scope toy_barrier 2>&1)"; rc=$?
[ "$rc" -eq 0 ] || otkaz 2 "$rc" "$out"
printf 'ворота 2 (scoped): rc 0 — посторонний probe-каталог не красит scoped семьи\n' >&2

# ── ворота 3: --changed по правке ТОЛЬКО probe-каталога ──────────────────────
g3="$WORK/g3"; cp -r "$beg" "$g3"
G3() { GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$g3" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }
G3 init -q
G3 add -A; G3 commit -q -m base
printf '# правка предъявления probe-каталога — барьеров не задета\n' >> "$g3/fixtures/probe_subject/red_probe.sh"
G3 add -A; G3 commit -q -m probe-edit
BASE="$(G3 rev-parse HEAD~1)"
out="$(VERIFY_ANTIPLACEBO_SCRATCH="$WORK/scr3" bash "$REPO/scripts/verify_antiplacebo.sh" "$g3" --changed "$BASE" 2>&1)"; rc=$?
[ "$rc" -eq 0 ] || otkaz 3 "$rc" "$out"
printf 'ворота 3 (--changed): rc 0 — правка probe-only ничего не выбирает у барьеров\n' >&2

# ── ворота 4 (к1-Б1): нелегальный каталог вне диффа + probe-правка → отказ ───
g4="$WORK/g4"; cp -r "$beg" "$g4"; mkdir -p "$g4/fixtures/stranaja"
printf '%s\n' '# ПРИЧИНА: порча найдена' 'exit 1' > "$g4/fixtures/stranaja/case_bad.sh"
G4() { GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$g4" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }
G4 init -q
G4 add -A; G4 commit -q -m base-with-illegal
printf '# правка предъявления probe-каталога — барьеров не задета\n' >> "$g4/fixtures/probe_subject/red_probe.sh"
G4 add -A; G4 commit -q -m probe-edit
BASE4="$(G4 rev-parse HEAD~1)"
out="$(VERIFY_ANTIPLACEBO_SCRATCH="$WORK/scr4" bash "$REPO/scripts/verify_antiplacebo.sh" "$g4" --changed "$BASE4" 2>&1)"; rc=$?
{ [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -qF 'FAIL fixtures/stranaja: фикстура без барьера'; } \
  || otkaz 4 "$rc" "$out"
# вторая форма: маркер нелегальному case-каталогу не легализует его (смешение
# ролей; в вердикте к1 эта форма тоже проходила ранним выходом с напечатанным FAIL)
printf '%s\n' 'маркер нелегальному case-каталогу: смешение ролей (034, к1-Б1).' > "$g4/fixtures/stranaja/.probe-only"
out="$(VERIFY_ANTIPLACEBO_SCRATCH="$WORK/scr4b" bash "$REPO/scripts/verify_antiplacebo.sh" "$g4" --changed "$BASE4" 2>&1)"; rc=$?
[ "$rc" -eq 1 ] || otkaz 4 "$rc" "$out"
printf 'ворота 4 (к1-Б1): нулевая выборка не легализует нелегальный каталог — rc 1\n' >&2

# ── ворота 5 (к1-Б2): наблюдаемый нуль выбора на той же probe-правке ─────────
# (а) селектор мини-дерева: MODE: needs-full, код 2, ни одной KEY:-строки
sel_out="$(bash "$g3/scripts/scope_select.sh" "$g3" --changed "$BASE" 2>/dev/null)"; sel_rc=$?
{ [ "$sel_rc" -eq 2 ] && printf '%s\n' "$sel_out" | grep -Fxq 'MODE: needs-full' \
    && ! printf '%s\n' "$sel_out" | grep -q '^KEY: '; } \
  || otkaz 5 "$sel_rc" "селектор: $sel_out"
# (б) раннер: MODE: none и ни один case не исполнен (в выводе нет case_porcha)
out="$(VERIFY_ANTIPLACEBO_SCRATCH="$WORK/scr5" bash "$REPO/scripts/verify_antiplacebo.sh" "$g3" --changed "$BASE" 2>&1)"; rc=$?
{ [ "$rc" -eq 0 ] && printf '%s\n' "$out" | grep -Fxq 'MODE: none' \
    && ! printf '%s\n' "$out" | grep -q 'case_porcha'; } \
  || otkaz 5 "$rc" "$out"
printf 'ворота 5 (к1-Б2): нуль выбора наблюдаем — селектор needs-full/2 без KEY, раннер MODE: none без case\n' >&2

exit 0
