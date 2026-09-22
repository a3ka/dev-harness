#!/usr/bin/env bash
# ПРИЧИНА: проводка: норма-строка не найдена в теле секции §Pinned section
# ОКРУЖЕНИЕ: BARRIER_ROOT=$WORK; PATH=$WORK/bin:$PATH; RACE_ROOT=$WORK/red
# case_19 — RED (TOCTOU charter→awk, круг 6 Б2б, atomic-fd реад): честный
# `AGENTS.md` (regular file с «Honest charter norm.» в секции «Pinned
# section») есть на момент `[ -f ]` (раньше) / `exec {fd}<` (круг 6); но
# МЕЖДУ открытием и реальным чтением секции в awk объект по пути `AGENTS.md`
# подменяется на симлинк наружу (`policies/charter-policy.md` с нормой
# «Swapped charter norm.»). Без К6: awk получает `$ROOT/AGENTS.md`, читает
# УЖЕ НОВЫЙ симлинк, находит «нужную» норму → ложный зелёный. С К6:
# charter_section_body получает `/proc/self/fd/<fd>` — даже если внешний awk
# подменён (PATH-shim) и подменил ФАЙЛ по пути, fd по-прежнему указывает
# на СТАРЫЙ inode («Honest charter norm.»). grep для «Swapped charter
# norm.» в теле старой секции не находит → rc 1 «норма-строка не найдена».
# Положительный контроль — без PATH-shim → rc 0.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  REPO="$(cd "$HERE/../.." && pwd -P)"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/case19_038.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
  BARRIER="$REPO/scripts/check_provodka.sh"
  export BARRIER_ROOT="$WORK"
fi

require_absent_subject

# Положительный контроль: честный AGENTS.md без подмены → rc 0
G="$WORK/green"; make_toy "$G" 1 1
put_contract "$G" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»'
commit_all "$G" 'g19: chestnyj charter bez podmeny'
GREEN_OUT="$("$BARRIER" "$G" "$G/contracts/001-x.md" 2>&1)"; GREEN_RC=$?

# Красный: AGENTS.md подменяется симлинком наружу ПЕРЕД чтением awk
R="$WORK/red"; make_toy "$R" 1 0
mkdir -p "$R/policies"
# ВАЖНО: make_toy с with_charter=1 создаёт AGENTS.md с «Воркфлоу майлстоуна»
# секцией. Перезаписываем целиком — нам нужна «Pinned section».
printf '# Charter\n\n## Pinned section\nHonest charter norm.\n' > "$R/AGENTS.md"
printf '# Outside charter\n\n## Pinned section\nSwapped charter norm.\n' > "$R/policies/charter-policy.md"
put_contract "$R" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Pinned section «Swapped charter norm.»'
commit_all "$R" 'r19: charter TOCTOU [ -f ] -> awk'

# PATH-shim awk: при первом же вызове атомарно подменяет $RACE_ROOT/AGENTS.md
# (rm + ln -s наружу), затем exec настоящего awk с теми же аргументами.
# Без К6 — awk читает УЖЕ подменённый путь; с К6 — charter_section_body
# получает /proc/self/fd/<fd>, и fd указывает на СТАРЫЙ inode, удерживаемый
# барьером.
mkdir -p "$WORK/bin"
cat > "$WORK/bin/awk" <<'SH'
#!/usr/bin/env bash
set -uo pipefail
rm -f -- "$RACE_ROOT/AGENTS.md"
ln -s policies/charter-policy.md "$RACE_ROOT/AGENTS.md"
exec /usr/bin/awk "$@"
SH
chmod +x "$WORK/bin/awk"

RED_OUT="$(env PATH="$WORK/bin:$PATH" RACE_ROOT="$R" "$BARRIER" "$R" "$R/contracts/001-x.md" 2>&1)"; RED_RC=$?

if [ -z "${BARRIER:-}" ] || [ "${BARRIER:-x}" = "$REPO/scripts/check_provodka.sh" ]; then
  [ "$GREEN_RC" -eq 0 ] || { printf 'FAIL: case_19 green rc=%s, ожидался 0\n%s\n' "$GREEN_RC" "$GREEN_OUT" >&2; exit 1; }
  printf '%s' "$GREEN_OUT" | grep -Fq 'получено:' \
    && { printf 'FAIL: case_19 green: вывод содержит «получено:»\n%s\n' "$GREEN_OUT" >&2; exit 1; }
  [ "$RED_RC" -eq 1 ] || { printf 'FAIL: case_19 red rc=%s, ожидался 1\n%s\n' "$RED_RC" "$RED_OUT" >&2; exit 1; }
  printf '%s' "$RED_OUT" | grep -Fq 'проводка: норма-строка не найдена в теле секции §Pinned section' \
    || { printf 'FAIL: case_19 red причина не названа дословно\n%s\n' "$RED_OUT" >&2; exit 1; }
  printf 'case_19: прямой rc 0 на зелёном, rc 1 на красном (atomic-fd [ -f ]→awk закрыт)\n' >&2
  exit 0
fi
exit 0
