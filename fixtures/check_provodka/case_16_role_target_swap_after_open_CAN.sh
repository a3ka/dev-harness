#!/usr/bin/env bash
# ПРИЧИНА: проводка: норма-строка не найдена в role-файле: roles/honest.md
# ОКРУЖЕНИЕ: BARRIER_ROOT=$WORK; PATH=$WORK/bin:$PATH; RACE_ROOT=$WORK/red
# case_16 — RED (TOCTOU К→г4, круг 6 Б1, атомарный fd-реад): легитимный
# плоский файл `roles/honest.md` есть на момент К, но МЕЖДУ `readlink -f`
# (через дескриптор) и `grep` подменяется на symlink `../policies/role-policy.md`
# (PATH-shim `readlink` сначала печатает реальный ответ, потом атомарно меняет
# объект). С fd-атомарным open ДО работы К: дескриптор биндится к inode на
# момент открытия, подмена ПОСЛЕ не влияет на чтение через /proc/self/fd/<fd>.
# grep ОБЯЗАН дать rc 1: норма «Policy-only role norm.» в СТАРОМ inode
# («Honest role norm.») отсутствует. Положительный контроль — честный файл
# без подмены → rc 0.
# Формат — `case_*.sh` семьи `_toy.sh`/`put_contract`/`commit_all`,
# не дословный repro (тот вне конвенции, см. 038-round6-atomic-fd §5).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  REPO="$(cd "$HERE/../.." && pwd -P)"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/case16_038.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
  BARRIER="$REPO/scripts/check_provodka.sh"
  export BARRIER_ROOT="$WORK"
fi

require_absent_subject

# ── Положительный контроль: честный файл без подмены → rc 0 ───────────────
G="$WORK/green"; make_toy "$G" 1 0
# В honest.md кладём «Honest role norm.» (отдельной строкой) — норма, что
# должна найтись по grep'у в той же inode.
printf 'Honest role norm.\n' > "$G/roles/honest.md"
put_contract "$G" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/honest.md «Honest role norm.»'
commit_all "$G" 'g16: chestnyj honest (reguljarnyj fajl, ne simlink)'
GREEN_OUT="$("$BARRIER" "$G" "$G/contracts/001-x.md" 2>&1)"; GREEN_RC=$?

# ── Красный контроль: PATH-shim подменяет honest.md ПОСЛЕ К, ДО г4 → rc 1 ──
R="$WORK/red"; make_toy "$R" 1 0
mkdir -p "$R/policies"
printf 'Honest role norm.\n' > "$R/roles/honest.md"
printf 'Policy-only role norm.\n' > "$R/policies/role-policy.md"
put_contract "$R" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/honest.md «Policy-only role norm.»'
commit_all "$R" 'r16: role-kanal s potencialom swap posle K'

# PATH-shim readlink: детерминированно печатает реальный ответ ДЛЯ СВОИХ
# АРГУМЕНТОВ (включая `/proc/self/fd/<fd>` — реальный readlink развернёт его
# в канонический путь подложенного inode), потом атомарно меняет ФАЙЛ ПО
# ПУТИ `roles/honest.md` (именно то, что было открыто). Техника ИДЕНТИЧНА
# postk5-repro, мишень другая — здесь сама подмена ФАЙЛА-ОРИГИНАЛА, а не
# симлинка (поведение для проверки сути: «подмена ПОСЛЕ open/К, до grep»).
mkdir -p "$WORK/bin"
cat > "$WORK/bin/readlink" <<'SH'
#!/usr/bin/env bash
set -uo pipefail
resolved="$(/usr/bin/readlink "$@")" || exit $?
printf '%s\n' "$resolved"
rm -f -- "$RACE_ROOT/roles/honest.md"
ln -s ../policies/role-policy.md "$RACE_ROOT/roles/honest.md"
SH
chmod +x "$WORK/bin/readlink"

RED_OUT="$(env PATH="$WORK/bin:$PATH" RACE_ROOT="$R" "$BARRIER" "$R" "$R/contracts/001-x.md" 2>&1)"; RED_RC=$?

if [ -z "${BARRIER:-}" ] || [ "${BARRIER:-x}" = "$REPO/scripts/check_provodka.sh" ]; then
  [ "$GREEN_RC" -eq 0 ] || { printf 'FAIL: case_16 green rc=%s, ожидался 0\n%s\n' "$GREEN_RC" "$GREEN_OUT" >&2; exit 1; }
  printf '%s' "$GREEN_OUT" | grep -Fq 'получено:' \
    && { printf 'FAIL: case_16 green: вывод содержит «получено:»\n%s\n' "$GREEN_OUT" >&2; exit 1; }
  [ "$RED_RC" -eq 1 ] || { printf 'FAIL: case_16 red rc=%s, ожидался 1\n%s\n' "$RED_RC" "$RED_OUT" >&2; exit 1; }
  printf '%s' "$RED_OUT" | grep -Fq 'проводка: норма-строка не найдена в role-файле: roles/honest.md' \
    || { printf 'FAIL: case_16 red причина не названа дословно\n%s\n' "$RED_OUT" >&2; exit 1; }
  printf 'case_16: прямой rc 0 на зелёном, rc 1 на красном (atomic-fd К→г4 закрыт)\n' >&2
  exit 0
fi
exit 0
