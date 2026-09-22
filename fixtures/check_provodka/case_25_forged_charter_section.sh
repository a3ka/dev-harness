#!/usr/bin/env bash
# ПРИЧИНА: проводка: секция устава не найдена: §Pinned section
# ОКРУЖЕНИЕ: BARRIER_ROOT=$WORK; PATH=$WORK/bin-awk:$PATH
# case_25 — RED (PATH-shim awk, круг 8 Б3): подложный `awk` в `$WORK/bin-awk`
# ФАБРИКУЕТ тело секции устава, печатая «Norm invented by awk.» в stdout — то
# есть подставляет «правильную» норма-строку ДО того, как charter_section_body
# через /proc/self/fd/11 увидит настоящий (пустой) AGENTS.md. Используется на
# чтении тела секции устава в charter_section_body. Без фикса: подложный awk
# отдаёт «нужную» секцию → финальный grep по телу секции находит «норму» →
# ложный rc 0. С фиксом — `export PATH=/usr/bin:/bin` в шапке барьера:
# настоящий `/usr/bin/awk` честно читает /proc/self/fd/11, секции «Pinned
# section» в честном AGENTS.md нет → section_body пустой → rc 1 «секция
# устава не найдена: §Pinned section». Положительный контроль — без PATH-shim
# и с настоящей секцией → rc 0.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  REPO="$(cd "$HERE/../.." && pwd -P)"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/case25_038.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
  BARRIER="$REPO/scripts/check_provodka.sh"
  export BARRIER_ROOT="$WORK"
fi

require_absent_subject

# Положительный контроль: настоящая секция с нормой в честном AGENTS.md → rc 0
G="$WORK/green"; make_toy "$G" 1 1
put_contract "$G" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»'
commit_all "$G" 'g25: chestnyj charter (realnaja sekcija v AGENTS.md)'
GREEN_OUT="$("$BARRIER" "$G" "$G/contracts/001-x.md" 2>&1)"; GREEN_RC=$?

# Красный: честный AGENTS.md, но секции «Pinned section» в нём НЕТ +
# PATH-shim awk фабрикует её.
R="$WORK/red"; make_toy "$R" 1 1
printf 'Norma stroki roli v igrushke R.\n' > "$R/roles/fixer.md"
# Используем стандартный make_toy AGENTS.md: у него есть только «Воркфлоу майлстоуна»
# и «Drugaja sekcija». Секции «Pinned section» НЕТ.
put_contract "$R" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Pinned section «Norm invented by awk.»'
commit_all "$R" 'r25: charter section podmen cherez PATH-shim awk'

# PATH-shim awk: печатает «норму» в stdout, имитируя успешное чтение секции.
mkdir -p "$WORK/bin-awk"
cat > "$WORK/bin-awk/awk" <<'SH'
#!/usr/bin/env bash
printf '%s\n' 'Norm invented by awk.'
SH
chmod +x "$WORK/bin-awk/awk"

RED_OUT="$(env PATH="$WORK/bin-awk:/usr/bin:/bin" \
  timeout 5 "$BARRIER" "$R" "$R/contracts/001-x.md" 2>&1)"; RED_RC=$?

if [ -z "${BARRIER:-}" ] || [ "${BARRIER:-x}" = "$REPO/scripts/check_provodka.sh" ]; then
  [ "$GREEN_RC" -eq 0 ] || { printf 'FAIL: case_25 green rc=%s, ожидался 0\n%s\n' "$GREEN_RC" "$GREEN_OUT" >&2; exit 1; }
  printf '%s' "$GREEN_OUT" | grep -Fq 'получено:' \
    && { printf 'FAIL: case_25 green: вывод содержит «получено:»\n%s\n' "$GREEN_OUT" >&2; exit 1; }
  [ "$RED_RC" -eq 1 ] || { printf 'FAIL: case_25 red rc=%s, ожидался 1\n%s\n' "$RED_RC" "$RED_OUT" >&2; exit 1; }
  printf '%s' "$RED_OUT" | grep -Fq 'проводка: секция устава не найдена: §Pinned section' \
    || { printf 'FAIL: case_25 red причина не названа дословно\n%s\n' "$RED_OUT" >&2; exit 1; }
  printf 'case_25: прямой rc 0 на зелёном, rc 1 на красном (trusted PATH закрывает awk-shim на section_body)\n' >&2
  exit 0
fi
exit 0
