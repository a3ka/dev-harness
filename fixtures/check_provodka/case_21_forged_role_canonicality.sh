#!/usr/bin/env bash
# ПРИЧИНА: проводка: role-канал обязан ссылаться строго на roles/<роль>.md
# ОКРУЖЕНИЕ: BARRIER_ROOT=$WORK; PATH=$WORK/bin-readlink:$PATH; FORGED_ROOT=$WORK/red
# case_21 — RED (PATH-shim readlink на fd 9, круг 8 Б1): подложный `readlink`
# в `$WORK/bin-readlink` ВЫГЛЯДИТ как успешный и ВОЗВРАЩАЕТ правдоподобный
# канонический путь `$WORK/red/roles/alias.md` для аргумента `/proc/self/fd/9`,
# тем самым обманывая К (читается fd 9, открытый атомарным exec на alias.md —
# реальная цель `$WORK/red/policies/outside-role.md`). Без фикса: К одобряет,
# г4 grep'ом по fd 9 находит «Outside role norm.» в подложном inode → ложный
# rc 0. С фиксом — `export PATH=/usr/bin:/bin` в шапке барьера: настоящий
# `/usr/bin/readlink` отдаёт реальную каноническую цель `…/policies/outside-role.md`,
# `role_component_ok` отказывает → rc 1 «role-канал обязан ссылаться строго
# на roles/<роль>.md». Положительный контроль — без PATH-shim → rc 0.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  REPO="$(cd "$HERE/../.." && pwd -P)"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/case21_038.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
  BARRIER="$REPO/scripts/check_provodka.sh"
  export BARRIER_ROOT="$WORK"
fi

require_absent_subject

# ── Положительный контроль: честный regular roles/alias.md → rc 0 ─────────────
G="$WORK/green"; make_toy "$G" 1 1
printf 'Outside role norm.\n' > "$G/roles/alias.md"
put_contract "$G" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/alias.md «Outside role norm.»
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»'
commit_all "$G" 'g21: chestnyj role alias (reguljarnyj fajl s nuzhnoj normoj)'
GREEN_OUT="$("$BARRIER" "$G" "$G/contracts/001-x.md" 2>&1)"; GREEN_RC=$?

# ── Красный: roles/alias.md — симлинк наружу, + PATH-shim readlink ─────────────
R="$WORK/red"; make_toy "$R" 1 1
mkdir -p "$R/policies"
printf 'Honest role norm.\n' > "$R/roles/fixer.md"
printf 'Outside role norm.\n' > "$R/policies/outside-role.md"
rm -f -- "$R/roles/alias.md"
ln -s ../policies/outside-role.md "$R/roles/alias.md"
put_contract "$R" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/alias.md «Outside role norm.»
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»'
commit_all "$R" 'r21: role kanon podmen cherez PATH-shim readlink'

# PATH-shim readlink: на /proc/self/fd/9 ЛОЖНО отдаёт $FORGED_ROOT/roles/alias.md,
# скрывая что fd указывает на outside-policy. На остальные аргументы — реальный.
mkdir -p "$WORK/bin-readlink"
cat > "$WORK/bin-readlink/readlink" <<'SH'
#!/usr/bin/env bash
set -uo pipefail
case "$*" in
  *'/proc/self/fd/9'*)  printf '%s\n' "$FORGED_ROOT/roles/alias.md" ;;
  *) exec /usr/bin/readlink "$@" ;;
esac
SH
chmod +x "$WORK/bin-readlink/readlink"

# timeout вокруг барьера — на случай, если фикс окажется неполным и зависнет.
RED_OUT="$(env PATH="$WORK/bin-readlink:/usr/bin:/bin" FORGED_ROOT="$R" \
  timeout 5 "$BARRIER" "$R" "$R/contracts/001-x.md" 2>&1)"; RED_RC=$?

if [ -z "${BARRIER:-}" ] || [ "${BARRIER:-x}" = "$REPO/scripts/check_provodka.sh" ]; then
  [ "$GREEN_RC" -eq 0 ] || { printf 'FAIL: case_21 green rc=%s, ожидался 0\n%s\n' "$GREEN_RC" "$GREEN_OUT" >&2; exit 1; }
  printf '%s' "$GREEN_OUT" | grep -Fq 'получено:' \
    && { printf 'FAIL: case_21 green: вывод содержит «получено:»\n%s\n' "$GREEN_OUT" >&2; exit 1; }
  [ "$RED_RC" -eq 1 ] || { printf 'FAIL: case_21 red rc=%s, ожидался 1\n%s\n' "$RED_RC" "$RED_OUT" >&2; exit 1; }
  printf '%s' "$RED_OUT" | grep -Fq 'проводка: role-канал обязан ссылаться строго на roles/<роль>.md' \
    || { printf 'FAIL: case_21 red причина не названа дословно\n%s\n' "$RED_OUT" >&2; exit 1; }
  printf 'case_21: прямой rc 0 на зелёном, rc 1 на красном (trusted PATH закрывает readlink-shim)\n' >&2
  exit 0
fi
exit 0
