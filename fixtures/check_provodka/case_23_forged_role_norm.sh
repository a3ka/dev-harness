#!/usr/bin/env bash
# ПРИЧИНА: проводка: норма-строка не найдена в role-файле: roles/honest.md
# ОКРУЖЕНИЕ: BARRIER_ROOT=$WORK; PATH=$WORK/bin-grep:$PATH
# case_23 — RED (PATH-shim grep, круг 8 Б2): подложный `grep` в
# `$WORK/bin-grep` ВСЕГДА возвращает rc 0 (независимо от входа и искомой
# норма-строки). Используется на г4 — поиск норма-строки в role-файле через
# fd 9. Без фикса: подложный grep отдаёт rc 0 даже для норма-строки,
# отсутствующей в role-файле → ложный rc 0. С фиксом — `export
# PATH=/usr/bin:/bin` в шапке барьера: настоящий `/usr/bin/grep -Fxq` отдаёт
# rc 1 (норма действительно отсутствует) → rc 1 «норма-строка не найдена в
# role-файле». Положительный контроль — без PATH-shim → rc 0.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  REPO="$(cd "$HERE/../.." && pwd -P)"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/case23_038.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
  BARRIER="$REPO/scripts/check_provodka.sh"
  export BARRIER_ROOT="$WORK"
fi

require_absent_subject

# Положительный контроль: настоящая норма в role-файле → rc 0
G="$WORK/green"; make_toy "$G" 1 1
# В make_toy roles/fixer.md уже положен, но нам для согласованности с red-стороной
# нужен roles/honest.md.
printf 'Norma stroki roli v igrushke R.\n' > "$G/roles/honest.md"
put_contract "$G" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/honest.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»'
commit_all "$G" 'g23: chestnyj role (realnaja norma v faile)'
GREEN_OUT="$("$BARRIER" "$G" "$G/contracts/001-x.md" 2>&1)"; GREEN_RC=$?

# Красный: норма-строка ОТСУТСТВУЕТ в role-файле + PATH-shim grep «всегда зелёный».
R="$WORK/red"; make_toy "$R" 1 1
printf 'Some other content\n' > "$R/roles/honest.md"
put_contract "$R" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/honest.md «Norm absent from role.»
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»'
commit_all "$R" 'r23: role g4 podmen cherez PATH-shim grep'

# PATH-shim grep: всегда rc 0.
mkdir -p "$WORK/bin-grep"
cat > "$WORK/bin-grep/grep" <<'SH'
#!/usr/bin/env bash
exit 0
SH
chmod +x "$WORK/bin-grep/grep"

RED_OUT="$(env PATH="$WORK/bin-grep:/usr/bin:/bin" \
  timeout 5 "$BARRIER" "$R" "$R/contracts/001-x.md" 2>&1)"; RED_RC=$?

if [ -z "${BARRIER:-}" ] || [ "${BARRIER:-x}" = "$REPO/scripts/check_provodka.sh" ]; then
  [ "$GREEN_RC" -eq 0 ] || { printf 'FAIL: case_23 green rc=%s, ожидался 0\n%s\n' "$GREEN_RC" "$GREEN_OUT" >&2; exit 1; }
  printf '%s' "$GREEN_OUT" | grep -Fq 'получено:' \
    && { printf 'FAIL: case_23 green: вывод содержит «получено:»\n%s\n' "$GREEN_OUT" >&2; exit 1; }
  [ "$RED_RC" -eq 1 ] || { printf 'FAIL: case_23 red rc=%s, ожидался 1\n%s\n' "$RED_RC" "$RED_OUT" >&2; exit 1; }
  printf '%s' "$RED_OUT" | grep -Fq 'проводка: норма-строка не найдена в role-файле: roles/honest.md' \
    || { printf 'FAIL: case_23 red причина не названа дословно\n%s\n' "$RED_OUT" >&2; exit 1; }
  printf 'case_23: прямой rc 0 на зелёном, rc 1 на красном (trusted PATH закрывает grep-shim)\n' >&2
  exit 0
fi
exit 0
