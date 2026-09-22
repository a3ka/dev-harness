#!/usr/bin/env bash
# ПРИЧИНА: NOT-GRAMMAR «Norma stroki roli v igrushke R.» TRAILING-GARBAGE
# ОКРУЖЕНИЕ: BARRIER_ROOT=$WORK
# case_15 — RED×2 (parser-laxity, круг 4 Б2, круг 5 фикс). Строгая грамматика
# extract_quoted (круг 5): вход после trim'а ведущих/хвостовых ASCII-пробелов
# обязан быть ровно `«<содержимое>»`, без мусора до/после и без вложенных «».
# Любое отклонение → rc 1 «строка вне грамматики: <вся строка канала>». Положи-
# тельный контроль — минимальный `role=roles/x.md «Norm.»` rc 0.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  REPO="$(cd "$HERE/../.." && pwd -P)"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/case15_038.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
  BARRIER="$REPO/scripts/check_provodka.sh"
  export BARRIER_ROOT="$WORK"
fi

require_absent_subject

# ── Положительный контроль: минимальный честный role → rc 0 ────────────────
G="$WORK/green"; make_toy "$G" 1 1
# Чтобы нормы «garbage» и «nested» совпадали с тем, что в red-каталогах
# (общий файл roles/fixer.md; нормы разные — отдельные строки в файле).
put_contract "$G" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»'
commit_all "$G" 'g15: chestnyj minimal'
GREEN_OUT="$("$BARRIER" "$G" "$G/contracts/001-x.md" 2>&1)"; GREEN_RC=$?

# ── Красный А: мусор ДО « и ПОСЛЕ » в role-строке → rc 1 ──────────────────
A="$WORK/red_a"; make_toy "$A" 1 1
put_contract "$A" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md NOT-GRAMMAR «Norma stroki roli v igrushke R.» TRAILING-GARBAGE'
commit_all "$A" 'r15a: musor do i posle kavychek'
RED_A_OUT="$("$BARRIER" "$A" "$A/contracts/001-x.md" 2>&1)"; RED_A_RC=$?

# ── Красный Б: вложенные «…» внутри норма-строки → rc 1 ───────────────────
B="$WORK/red_b"; make_toy "$B" 1 1
put_contract "$B" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Outer «inner» tail»'
commit_all "$B" 'r15b: vlozhennye kavychki'
RED_B_OUT="$("$BARRIER" "$B" "$B/contracts/001-x.md" 2>&1)"; RED_B_RC=$?

if [ -z "${BARRIER:-}" ] || [ "${BARRIER:-x}" = "$REPO/scripts/check_provodka.sh" ]; then
  [ "$GREEN_RC" -eq 0 ] || { printf 'FAIL: case_15 green rc=%s, ожидался 0\n%s\n' "$GREEN_RC" "$GREEN_OUT" >&2; exit 1; }
  printf '%s' "$GREEN_OUT" | grep -Fq 'получено:' \
    && { printf 'FAIL: case_15 green: вывод содержит «получено:»\n%s\n' "$GREEN_OUT" >&2; exit 1; }
  [ "$RED_A_RC" -eq 1 ] || { printf 'FAIL: case_15 red_a (мусор вокруг кавычек) rc=%s, ожидался 1\n%s\n' "$RED_A_RC" "$RED_A_OUT" >&2; exit 1; }
  printf '%s' "$RED_A_OUT" | grep -Fq 'проводка: строка вне грамматики: - role=roles/fixer.md NOT-GRAMMAR «Norma stroki roli v igrushke R.» TRAILING-GARBAGE' \
    || { printf 'FAIL: case_15 red_a: причина не названа дословно (вся строка)\n%s\n' "$RED_A_OUT" >&2; exit 1; }
  [ "$RED_B_RC" -eq 1 ] || { printf 'FAIL: case_15 red_b (вложенные «») rc=%s, ожидался 1\n%s\n' "$RED_B_RC" "$RED_B_OUT" >&2; exit 1; }
  printf '%s' "$RED_B_OUT" | grep -Fq 'проводка: строка вне грамматики: - role=roles/fixer.md «Outer «inner» tail»' \
    || { printf 'FAIL: case_15 red_b: причина не названа дословно (вся строка)\n%s\n' "$RED_B_OUT" >&2; exit 1; }
  printf 'case_15: rc 0/1/1 — мусор вокруг кавычек и вложенные «» оба rc 1\n' >&2
  exit 0
fi
exit 0
