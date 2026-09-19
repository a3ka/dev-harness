#!/usr/bin/env bash
# Красное предъявление 034 — ГРАНИЦЫ probe-only класса: легализация каталогов
# без барьерного ключа НЕ ослабляет сверку §2 «фикстура без барьера».
#
# Три ворота, каждое — свой вход; все три обязаны давать rc 1 (флаг) в обеих
# эрах — ДО предмета (нынешним текстом «фикстура без барьера») и ПОСЛЕ
# (текстами роли каталога):
#   1 чужой каталог с case_*.sh, БЕЗ маркера, БЕЗ барьерного ключа → флагается:
#     «фикстура без барьера» (дословно сегодняшний текст; ворота зелёные в
#     обеих эрах — это контроль НЕ-ослабления, боль измерена в обратную сторону);
#   2 probe-only каталог (маркер) с case_*.sh → флагается: case-батарея живёт
#     только у барьерного ключа, смешение ролей каталога — отказ (роль одна);
#   3 БАРЬЕРНЫЙ каталог с маркером .probe-only → флагается: противоречие ролей
#     (семья барьера и probe-only) не может молчать. СЕГОДНЯ раннер маркер не
#     читает и эти ворота КРАСНЫ отсутствием флага (rc 0 на противоречии) —
#     предъявляемое красное; после предмета rc 1.
#
# Н-39: ворота 1 наблюдаемо на входе «case_* без ключа» (флаг жив и ДО, и
# ПОСЛЕ); ворота 2 — на «маркер ∧ case_*» (ДО флагает за отсутствие ключа,
# ПОСЛЕ — за смешение ролей; rc 1 в обеих эрах); ворота 3 — на «ключ ∧ маркер»
# (ДО молчит — дефект, ПОСЛЕ флагает). Ни одно ворото не судит вход, где его
# ожидание не различимо в его эру.
set -uo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd -P)"
. "$(dirname "$0")/_mini.sh"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/probe034b.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

otkaz() {  # <ворота> <rc> <вывод>
  printf 'ОТКАЗ: ворота %s — rc %s\n' "$1" "$2" >&2
  printf '%s\n' "$3" | tail -n 6 | sed 's/^/    /' >&2
  exit 1
}
beg="$WORK/mini"
mk_mini "$beg"

# ── ворота 1: чужой каталог с case_*.sh, без маркера → флагается (не ослабление) ──
g1="$WORK/g1"; cp -r "$beg" "$g1"; mkdir -p "$g1/fixtures/stranaja"
{
  printf '%s\n' '# ПРИЧИНА: порча найдена'
  printf '%s\n' 'set -euo pipefail'
  printf '%s\n' 'cd "$WORK"'
  printf '%s\n' '"$BARRIER"'
  printf '%s\n' ': > porcha'
  printf '%s\n' '"$BARRIER"'
} > "$g1/fixtures/stranaja/case_chuzhaja.sh"
out="$(VERIFY_ANTIPLACEBO_SCRATCH="$WORK/scr1" bash "$REPO/scripts/verify_antiplacebo.sh" "$g1" 2>&1)"; rc=$?
[ "$rc" -eq 1 ] || otkaz 1 "$rc" "$out"
printf '%s\n' "$out" | grep -qF 'FAIL fixtures/stranaja: фикстура без барьера' \
  || otkaz 1 "$rc" "$out"
printf 'ворота 1: case-каталог без барьера флагается — не ослабление\n' >&2

# ── ворота 2: probe-only каталог (маркер) с case_*.sh → флагается (роль одна) ────
g2="$WORK/g2"; cp -r "$beg" "$g2"
{
  printf '%s\n' '# ПРИЧИНА: порча найдена'
  printf '%s\n' 'set -euo pipefail'
  printf '%s\n' 'cd "$WORK"'
  printf '%s\n' '"$BARRIER"'
  printf '%s\n' ': > porcha'
  printf '%s\n' '"$BARRIER"'
} > "$g2/fixtures/probe_subject/case_vtoroj.sh"
out="$(VERIFY_ANTIPLACEBO_SCRATCH="$WORK/scr2" bash "$REPO/scripts/verify_antiplacebo.sh" "$g2" 2>&1)"; rc=$?
[ "$rc" -eq 1 ] || otkaz 2 "$rc" "$out"
printf '%s\n' "$out" | grep -qF 'FAIL fixtures/probe_subject' \
  || otkaz 2 "$rc" "$out"
printf 'ворота 2: probe-only каталог с case_* флагается — роль каталога одна\n' >&2

# ── ворота 3: барьерный каталог с маркером → флагается (противоречие ролей) ──────
# Мини-дерево БЕЗ probe_subject: единственная аномалия §2 здесь — сам маркер в
# барьерном каталоге; иначе краснота ворот шла бы от боли 1 (посторонний флаг
# probe-каталога), а не от молчания противоречия — Н-39: ворото судит свой вход.
g3="$WORK/g3"; cp -r "$beg" "$g3"; rm -rf "$g3/fixtures/probe_subject"
{
  printf '%s\n' 'probe-only маркер в барьерном каталоге — противоречие ролей (034).'
} > "$g3/fixtures/toy_barrier/.probe-only"
out="$(VERIFY_ANTIPLACEBO_SCRATCH="$WORK/scr3" bash "$REPO/scripts/verify_antiplacebo.sh" "$g3" 2>&1)"; rc=$?
[ "$rc" -eq 1 ] || otkaz 3 "$rc" "$out"
printf 'ворота 3: маркер в барьерном каталоге флагается — противоречие не молчит\n' >&2

exit 0
