#!/usr/bin/env bash
# ПРИЧИНА: проводка: секция устава не найдена: §Pinned section
# ОКРУЖЕНИЕ: BARRIER_ROOT=$WORK
# case_18 — RED (charter alias, круг 6 Б2б): `AGENTS.md` — прямой симлинк
# наружу (`policies/charter-policy.md`). Без К6-пиннинга на фс-цели: `[ -f ]`
# проходит (симлинк валиден), awk читает файл, находит «нужную» секцию с
# «Swapped charter norm.» → ложный зелёный. С atomic-fd и канонизацией через
# /proc/self/fd/<fd>: дескриптор открывает underlying inode (вне $ROOT), и
# `readlink -f /proc/self/fd/<fd>` возвращает `$ROOT/policies/charter-policy.md`
# — НЕ `$ROOT/AGENTS.md`. Несовпадение → rc 1 «секция устава не найдена»
# (тот же класс причины, что «файла нет» / «секции в файле нет», существующая
# фраза — новую НЕ вводим). Положительный контроль — честный не-симлинк
# AGENTS.md → rc 0.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  REPO="$(cd "$HERE/../.." && pwd -P)"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/case18_038.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
  BARRIER="$REPO/scripts/check_provodka.sh"
  export BARRIER_ROOT="$WORK"
fi

require_absent_subject

# Положительный контроль: AGENTS.md — обычный файл с нормой → rc 0
G="$WORK/green"; make_toy "$G" 1 1
put_contract "$G" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»'
commit_all "$G" 'g18: chestnyj AGENTS.md (reguljarnyj fajl)'
GREEN_OUT="$("$BARRIER" "$G" "$G/contracts/001-x.md" 2>&1)"; GREEN_RC=$?

# Красный: AGENTS.md — прямой симлинк наружу (на файл с «правильной» нормой,
# без К6-пиннинга на $ROOT/AGENTS.md это был бы ложный зелёный).
R="$WORK/red"; make_toy "$R" 1 0
mkdir -p "$R/policies"
# Прямой симлинк наружу — НЕ битый, целевой файл существует и содержит секцию.
rm -f -- "$R/AGENTS.md"
ln -s policies/charter-policy.md "$R/AGENTS.md"
printf '# Outside charter\n\n## Pinned section\nSwapped charter norm.\n' > "$R/policies/charter-policy.md"
put_contract "$R" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Pinned section «Swapped charter norm.»'
commit_all "$R" 'r18: AGENTS.md — prjamoj simlink naruzhu'
RED_OUT="$("$BARRIER" "$R" "$R/contracts/001-x.md" 2>&1)"; RED_RC=$?

if [ -z "${BARRIER:-}" ] || [ "${BARRIER:-x}" = "$REPO/scripts/check_provodka.sh" ]; then
  [ "$GREEN_RC" -eq 0 ] || { printf 'FAIL: case_18 green rc=%s, ожидался 0\n%s\n' "$GREEN_RC" "$GREEN_OUT" >&2; exit 1; }
  printf '%s' "$GREEN_OUT" | grep -Fq 'получено:' \
    && { printf 'FAIL: case_18 green: вывод содержит «получено:»\n%s\n' "$GREEN_OUT" >&2; exit 1; }
  [ "$RED_RC" -eq 1 ] || { printf 'FAIL: case_18 red rc=%s, ожидался 1\n%s\n' "$RED_RC" "$RED_OUT" >&2; exit 1; }
  printf '%s' "$RED_OUT" | grep -Fq 'проводка: секция устава не найдена: §Pinned section' \
    || { printf 'FAIL: case_18 red причина не названа дословно\n%s\n' "$RED_OUT" >&2; exit 1; }
  printf 'case_18: прямой rc 0 на зелёном, rc 1 на красном (charter canon pin $ROOT/AGENTS.md)\n' >&2
  exit 0
fi
exit 0
