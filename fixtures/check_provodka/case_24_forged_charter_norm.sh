#!/usr/bin/env bash
# ПРИЧИНА: проводка: норма-строка не найдена в теле секции §Pinned section
# ОКРУЖЕНИЕ: BARRIER_ROOT=$WORK; PATH=$WORK/bin-grep:$PATH
# case_24 — RED (PATH-shim grep на charter, круг 8 Б2): подложный `grep` в
# `$WORK/bin-grep` ВСЕГДА rc 0. Используется на финальной проверке «норма-строка
# найдена в теле секции» для charter-канала (grep читает section_body через
# пайп от charter_section_body). Без фикса: подложный grep отдаёт rc 0 даже
# для норма-строки, отсутствующей в секции → ложный rc 0. С фиксом —
# `export PATH=/usr/bin:/bin` в шапке барьера: настоящий `/usr/bin/grep -Fxq`
# отдаёт rc 1 (норма действительно отсутствует в теле секции) → rc 1
# «норма-строка не найдена в теле секции §Pinned section». Положительный
# контроль — без PATH-shim → rc 0.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  REPO="$(cd "$HERE/../.." && pwd -P)"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/case24_038.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
  BARRIER="$REPO/scripts/check_provodka.sh"
  export BARRIER_ROOT="$WORK"
fi

require_absent_subject

# Положительный контроль: настоящая норма в секции устава → rc 0
G="$WORK/green"; make_toy "$G" 1 1
put_contract "$G" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»'
commit_all "$G" 'g24: chestnyj charter (realnaja norma v sekcii)'
GREEN_OUT="$("$BARRIER" "$G" "$G/contracts/001-x.md" 2>&1)"; GREEN_RC=$?

# Красный: норма ОТСУТСТВУЕТ в секции + PATH-shim grep «всегда зелёный».
R="$WORK/red"; make_toy "$R" 1 1
printf 'Norma stroki roli v igrushke R.\n' > "$R/roles/fixer.md"
# Создаём секцию, в которой норма отсутствует.
printf '# Ustav\n\n## Pinned section\nSome other content.\n\n## Drugaja sekcija\n\nNorma stroki ustava v igrushke R.\ntelo\n' > "$R/AGENTS.md"
put_contract "$R" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Pinned section «Norm absent from charter.»'
commit_all "$R" 'r24: charter g5 podmen cherez PATH-shim grep'

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
  [ "$GREEN_RC" -eq 0 ] || { printf 'FAIL: case_24 green rc=%s, ожидался 0\n%s\n' "$GREEN_RC" "$GREEN_OUT" >&2; exit 1; }
  printf '%s' "$GREEN_OUT" | grep -Fq 'получено:' \
    && { printf 'FAIL: case_24 green: вывод содержит «получено:»\n%s\n' "$GREEN_OUT" >&2; exit 1; }
  [ "$RED_RC" -eq 1 ] || { printf 'FAIL: case_24 red rc=%s, ожидался 1\n%s\n' "$RED_RC" "$RED_OUT" >&2; exit 1; }
  printf '%s' "$RED_OUT" | grep -Fq 'проводка: норма-строка не найдена в теле секции §Pinned section' \
    || { printf 'FAIL: case_24 red причина не названа дословно\n%s\n' "$RED_OUT" >&2; exit 1; }
  printf 'case_24: прямой rc 0 на зелёном, rc 1 на красном (trusted PATH закрывает grep-shim на charter g5)\n' >&2
  exit 0
fi
exit 0
