#!/usr/bin/env bash
# ПРИЧИНА: проводка: строка вне грамматики: - charter=policies/not-charter.md §Pinned section «External charter norm.»
# ОКРУЖЕНИЕ: BARRIER_ROOT=$WORK
# case_17 — RED (target pinning, круг 6 Б2а): charter= обязан ссылаться ровно
# на `AGENTS.md` (грамматика контракта литерально). `charter=policies/not-charter.md`
# — вне грамматики → rc 1 «строка вне грамматики» с самой строкой канала
# (используем существующую фразу, новую НЕ вводим). Положительный контроль —
# честный `charter=AGENTS.md` → rc 0.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  REPO="$(cd "$HERE/../.." && pwd -P)"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/case17_038.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
  BARRIER="$REPO/scripts/check_provodka.sh"
  export BARRIER_ROOT="$WORK"
fi

require_absent_subject

# Положительный контроль: AGENTS.md как цель → rc 0
G="$WORK/green"; make_toy "$G" 1 1
put_contract "$G" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»'
commit_all "$G" 'g17: chestnyj charter=AGENTS.md'
GREEN_OUT="$("$BARRIER" "$G" "$G/contracts/001-x.md" 2>&1)"; GREEN_RC=$?

# Красный: charter=policies/not-charter.md — вне грамматики (target pinning)
R="$WORK/red"; make_toy "$R" 1 1
mkdir -p "$R/policies"
# В файле «устава-pretендента» есть нужная секция с нормой — но это НЕ
# AGENTS.md, и без К6-пиннинга К нашёл бы файл и секцию, awk прочёл бы,
# grep подтвердил бы норму → ложный зелёный.
printf '# Not a charter\n\n## Pinned section\nExternal charter norm.\n' > "$R/policies/not-charter.md"
put_contract "$R" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=policies/not-charter.md §Pinned section «External charter norm.»'
commit_all "$R" 'r17: charter-target pinning (ne AGENTS.md)'
RED_OUT="$("$BARRIER" "$R" "$R/contracts/001-x.md" 2>&1)"; RED_RC=$?

if [ -z "${BARRIER:-}" ] || [ "${BARRIER:-x}" = "$REPO/scripts/check_provodka.sh" ]; then
  [ "$GREEN_RC" -eq 0 ] || { printf 'FAIL: case_17 green rc=%s, ожидался 0\n%s\n' "$GREEN_RC" "$GREEN_OUT" >&2; exit 1; }
  printf '%s' "$GREEN_OUT" | grep -Fq 'получено:' \
    && { printf 'FAIL: case_17 green: вывод содержит «получено:»\n%s\n' "$GREEN_OUT" >&2; exit 1; }
  [ "$RED_RC" -eq 1 ] || { printf 'FAIL: case_17 red rc=%s, ожидался 1\n%s\n' "$RED_RC" "$RED_OUT" >&2; exit 1; }
  printf '%s' "$RED_OUT" | grep -Fq 'проводка: строка вне грамматики: - charter=policies/not-charter.md §Pinned section «External charter norm.»' \
    || { printf 'FAIL: case_17 red: причина не названа дословно (вся строка канала)\n%s\n' "$RED_OUT" >&2; exit 1; }
  printf 'case_17: прямой rc 0 на зелёном, rc 1 на красном (charter target pinning AGENTS.md)\n' >&2
  exit 0
fi
exit 0
