#!/usr/bin/env bash
# Проба предмета Б контракта 013 — находка 1 вердикта contracts-013-v1: контроль
# circles=2 на живой истории 012. Реплей ФОРМЫ истории verdicts/critic/contracts-012-v*.md
# (замерено git log --reverse -M --name-status: A v1 FAIL → A v2 accept → D v1 →
# R100 v2→v1 [точка заморозки 012/1] → M v1 → M v1 + A v2 [точка 012/2]) в игрушечном
# репо; счёт проверяется самим механизмом — попыткой заморозки в обеих точках.
#
# Сейчас (счёт по коммитам): в точке /1 глоб даёт 4 коммита, в точке /2 — 6 →
# ложный кап, заморозка отказывает → rc пробы 1.
# После реализации (события [FAIL, accept, accept, accept, accept] → сжатый
# [FAIL, accept]): circles=2 в обеих точках → обе заморозки проходят → rc 0.
# Н-57: ровно эти две точки дали ложные капы circles=4 и circles=6 на живом дереве.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$HERE/_repo.sh"
S="$(cd "$HERE/../.." && pwd)/scripts"
W="$(mktemp -d "${TMPDIR:-/tmp}/probe-012.XXXXXX")"
trap 'rm -rf "$W"' EXIT
R="$W/repo"

# Основание БЕЗ вердиктов (как repo-shum в case_kap_smena_pervoj_stroki): таймлайн
# глоба начинается с первого реплей-коммита, событие контроля в него не входит.
mkdir -p "$R/contracts" "$R/tmp"
printf 'предмет, критерий готовности, РАБОТА НЕ РАЗДАЁТСЯ: кодификация\n' > "$R/contracts/001-x.md"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$R"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" config user.name Фикстура
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" config user.email fixture@local
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" config commit.gpgsign false
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" config core.hooksPath /dev/null
commit_all "$R" 'основание'
V1="$R/verdicts/critic/contracts-001-v1.md"
V2="$R/verdicts/critic/contracts-001-v2.md"

fails=0
sud() {  # вызов заморозки; код и вывод — в RC/OUT
  set +e
  OUT="$(bash "$S/freeze_contract.sh" contracts/001-x.md "$1" "$R" 2>&1)"
  RC=$?
  set -e
}
zap() {  # <ожидаемый rc> <имя точки>
  if [ "$RC" -ne "$1" ]; then
    printf 'точка «%s»: заморозка вернула rc=%s, ожидается %s\n' "$2" "$RC" "$1" >&2
    printf '%s\n' "$OUT" | sed 's/^/    /' >&2
    fails=$((fails + 1))
  fi
}

# Реплей e9814c0/69f9ed0/a189883/e63c1a9 — форма истории 012 до заморозки /1.
put_verdict "$R" 1 FAIL
commit_all "$R" 'реплей e9814c0: A v1 FAIL — круг 1'
put_verdict "$R" 2 accept
commit_all "$R" 'реплей 69f9ed0: A v2 accept — круг 2'
g "$R" rm -q "$V1"
commit_all "$R" 'реплей a189883: D v1 — форма, не содержание'
g "$R" mv "$V2" "$V1"
commit_all "$R" 'реплей e63c1a9: R100 v2→v1 — форма, не содержание'
sud 'реплей точки 012/1: кругов обязано быть 2'
zap 0 'заморозка /1 (4 коммита по глобу, событий после сжатия 2)'

# Реплей f3c933f/a588a8e — до заморозки /2.
printf 'accept\nиная правка тела, первая строка та же\n' > "$V1"
commit_all "$R" 'реплей f3c933f: M v1 — та же первая строка'
printf 'accept\nвосстановление круга 2 под верным именем\n' > "$V1"
put_verdict "$R" 2 accept
commit_all "$R" 'реплей a588a8e: M v1 + A v2 — два файла одним коммитом'
sud 'реплей точки 012/2: кругов обязано быть 2'
zap 0 'заморозка /2 (6 коммитов по глобу, событий после сжатия 2)'

[ "$fails" -eq 0 ] || exit 1
