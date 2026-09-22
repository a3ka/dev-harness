#!/usr/bin/env bash
# ПРИЧИНА: проводка: секция устава не найдена: §Pinned section
# ОКРУЖЕНИЕ: BARRIER_ROOT=$WORK; PATH=$WORK/bin-readlink:$PATH; FORGED_ROOT=$WORK/red
# case_22 — RED (PATH-shim readlink на fd 11, круг 8 Б1): подложный `readlink`
# в `$WORK/bin-readlink` ВОЗВРАЩАЕТ для `/proc/self/fd/11` строку
# `$WORK/red/AGENTS.md` (правдоподобный канонический путь), скрывая что fd 11
# указывает на внешний inode (после `rm + ln -s policies/outside-charter.md
# $R/AGENTS.md`). Без фикса: К одобряет (resolved совпадает с $ROOT/AGENTS.md
# по утверждению шима), awk читает outside-charter.md, находит «Outside
# charter norm.» → ложный rc 0. С фиксом — `export PATH=/usr/bin:/bin` в
# шапке барьера: настоящий `/usr/bin/readlink` отдаёт реальный канон
# `…/policies/outside-charter.md` ≠ `$ROOT/AGENTS.md` → rc 1 «секция устава
# не найдена» (та же фраза, что и для прямого симлинка наружу в К6 Б2б).
# Положительный контроль — без PATH-shim → rc 0.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  REPO="$(cd "$HERE/../.." && pwd -P)"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/case22_038.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
  BARRIER="$REPO/scripts/check_provodka.sh"
  export BARRIER_ROOT="$WORK"
fi

require_absent_subject

# Положительный контроль: честный regular AGENTS.md → rc 0
G="$WORK/green"; make_toy "$G" 1 1
# Перезаписываем AGENTS.md, чтобы там была секция «Pinned section» с «Honest charter norm.»
printf '# Honest charter\n\n## Pinned section\nHonest charter norm.\n' > "$G/AGENTS.md"
put_contract "$G" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Pinned section «Honest charter norm.»'
commit_all "$G" 'g22: chestnyj AGENTS.md (reguljarnyj fajl)'
GREEN_OUT="$("$BARRIER" "$G" "$G/contracts/001-x.md" 2>&1)"; GREEN_RC=$?

# Красный: AGENTS.md — симлинк наружу + PATH-shim readlink лжёт про fd 11.
R="$WORK/red"; make_toy "$R" 1 1
mkdir -p "$R/policies"
printf 'Norma stroki roli v igrushke R.\n' > "$R/roles/fixer.md"
printf '# Outside charter\n\n## Pinned section\nOutside charter norm.\n' > "$R/policies/outside-charter.md"
rm -f -- "$R/AGENTS.md"
ln -s policies/outside-charter.md "$R/AGENTS.md"
put_contract "$R" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Pinned section «Outside charter norm.»'
commit_all "$R" 'r22: charter kanon podmen cherez PATH-shim readlink'

# PATH-shim readlink: на /proc/self/fd/11 ЛОЖНО отдаёт $FORGED_ROOT/AGENTS.md,
# скрывая что fd указывает на outside-charter.md. Остальное — реальный readlink.
mkdir -p "$WORK/bin-readlink"
cat > "$WORK/bin-readlink/readlink" <<'SH'
#!/usr/bin/env bash
set -uo pipefail
case "$*" in
  *'/proc/self/fd/11'*) printf '%s\n' "$FORGED_ROOT/AGENTS.md" ;;
  *) exec /usr/bin/readlink "$@" ;;
esac
SH
chmod +x "$WORK/bin-readlink/readlink"

RED_OUT="$(env PATH="$WORK/bin-readlink:/usr/bin:/bin" FORGED_ROOT="$R" \
  timeout 5 "$BARRIER" "$R" "$R/contracts/001-x.md" 2>&1)"; RED_RC=$?

if [ -z "${BARRIER:-}" ] || [ "${BARRIER:-x}" = "$REPO/scripts/check_provodka.sh" ]; then
  [ "$GREEN_RC" -eq 0 ] || { printf 'FAIL: case_22 green rc=%s, ожидался 0\n%s\n' "$GREEN_RC" "$GREEN_OUT" >&2; exit 1; }
  printf '%s' "$GREEN_OUT" | grep -Fq 'получено:' \
    && { printf 'FAIL: case_22 green: вывод содержит «получено:»\n%s\n' "$GREEN_OUT" >&2; exit 1; }
  [ "$RED_RC" -eq 1 ] || { printf 'FAIL: case_22 red rc=%s, ожидался 1\n%s\n' "$RED_RC" "$RED_OUT" >&2; exit 1; }
  printf '%s' "$RED_OUT" | grep -Fq 'проводка: секция устава не найдена: §Pinned section' \
    || { printf 'FAIL: case_22 red причина не названа дословно\n%s\n' "$RED_OUT" >&2; exit 1; }
  printf 'case_22: прямой rc 0 на зелёном, rc 1 на красном (trusted PATH закрывает readlink-shim на fd 11)\n' >&2
  exit 0
fi
exit 0
