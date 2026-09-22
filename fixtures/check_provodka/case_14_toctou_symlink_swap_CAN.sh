#!/usr/bin/env bash
# ПРИЧИНА: проводка: норма-строка не найдена в role-файле: roles/alias.md
# ОКРУЖЕНИЕ: BARRIER_ROOT=$WORK; PATH=$WORK/bin:$PATH; RACE_ROOT=$WORK/red
# case_14 — RED (TOCTOU К→г4, круг 4 Б1, круг 5 фикс): легитимный плоский
# alias `roles/alias.md → roles/good.md` есть на момент К, но МЕЖДУ `readlink -f`
# и `grep` подменяется на `../policies/evil.md` (PATH-shim `readlink` сначала
# печатает реальный ответ, потом атомарно меняет симлинк). Честный г4 теперь
# ОБЯЗАН дать rc 1: `grep` читает `$resolved`, а не `$ROOT/$path` заново, и в
# канонической цели (good.md) нормы `Policy-only norm.` нет. Зелёный положи-
# тельный контроль — тот же alias без подмены → rc 0 (норма в good.md есть).
# Формат — `case_*.sh` семьи `_toy.sh`/`put_contract`/`commit_all`/`run_barrier`,
# не дословный repro (тот вне конвенции, см. 038-round5-fix-b1-b2 §5).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  REPO="$(cd "$HERE/../.." && pwd -P)"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/case14_038.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
  BARRIER="$REPO/scripts/check_provodka.sh"
  export BARRIER_ROOT="$WORK"
fi

require_absent_subject

# ── Положительный контроль: плоский alias, без подмены → rc 0 ───────────────
G="$WORK/green"; make_toy "$G" 1 1
# Таргет плоского alias — roles/good.md ВНУТРИ roles/ (резолв плоский, Л+К
# зелёные). В good.md кладём «Honest role norm.» (отдельной строкой) —
# норма присутствует в честной цели.
printf 'Honest role norm.\n' > "$G/roles/good.md"
# Сам alias создаётся ПОСЛЕ коммита, как в кейсах 04/09/12 (барьер читает ФС,
# не git; это согласовано с каноном readlink-на-ФС).
put_contract "$G" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/alias.md «Honest role norm.»'
commit_all "$G" 'g14: chestnyj ploskij alias'
ln -s good.md "$G/roles/alias.md"
GREEN_OUT="$("$BARRIER" "$G" "$G/contracts/001-x.md" 2>&1)"; GREEN_RC=$?

# ── Красный контроль: PATH-shim подменяет alias после K, до г4 → rc 1 ─────
R="$WORK/red"; make_toy "$R" 1 1
mkdir -p "$R/policies"
printf 'Honest role norm.\n' > "$R/roles/good.md"
printf 'Policy-only norm.\n' > "$R/policies/evil.md"
ln -s good.md "$R/roles/alias.md"
put_contract "$R" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/alias.md «Policy-only norm.»'
commit_all "$R" 'r14: role-kanal s potencialom swap'

# PATH-shim readlink: детерминированно печатает /usr/bin/readlink ответ,
# потом атомарно меняет симлинк (как в adversary-repro). Здесь — инлайн
# (без отдельного файла) для краткости и читаемости; ПОВЕДЕНИЕ ИДЕНТИЧНО repro.
mkdir -p "$WORK/bin"
cat > "$WORK/bin/readlink" <<'SH'
#!/usr/bin/env bash
set -uo pipefail
resolved="$(/usr/bin/readlink "$@")" || exit $?
printf '%s\n' "$resolved"
rm -f -- "$RACE_ROOT/roles/alias.md"
ln -s ../policies/evil.md "$RACE_ROOT/roles/alias.md"
SH
chmod +x "$WORK/bin/readlink"

RED_OUT="$(env PATH="$WORK/bin:$PATH" RACE_ROOT="$R" "$BARRIER" "$R" "$R/contracts/001-x.md" 2>&1)"; RED_RC=$?

if [ -z "${BARRIER:-}" ] || [ "${BARRIER:-x}" = "$REPO/scripts/check_provodka.sh" ]; then
  # Положительный контроль — alias без подмены, г4 зелёный.
  [ "$GREEN_RC" -eq 0 ] || { printf 'FAIL: case_14 green rc=%s, ожидался 0\n%s\n' "$GREEN_RC" "$GREEN_OUT" >&2; exit 1; }
  printf '%s' "$GREEN_OUT" | grep -Fq 'получено:' \
    && { printf 'FAIL: case_14 green: вывод содержит «получено:»\n%s\n' "$GREEN_OUT" >&2; exit 1; }
  # Красный контроль — г4 НЕ ДОЛЖЕН пустить policy-норму после подмены alias.
  [ "$RED_RC" -eq 1 ] || { printf 'FAIL: case_14 red rc=%s, ожидался 1\n%s\n' "$RED_RC" "$RED_OUT" >&2; exit 1; }
  printf '%s' "$RED_OUT" | grep -Fq 'проводка: норма-строка не найдена в role-файле: roles/alias.md' \
    || { printf 'FAIL: case_14 red причина не названа дословно\n%s\n' "$RED_OUT" >&2; exit 1; }
  printf 'case_14: прямой rc 0 на зелёном, rc 1 на красном (TOCTOU К→г4 закрыт)\n' >&2
  exit 0
fi
exit 0
