#!/usr/bin/env bash
# ДВЕРЬ КАРТЫ КЛАССОВ ВЕРДИКТА (контракт 193, Л2).
#
#   bash scripts/check_verdict_karta.sh <корень> <отн-путь-вердикта>
#
# Судит ТОЛЬКО ЗАКОММИЧЕННЫЙ вердикт (AGENTS.md п.8/9: истина — в закоммиченном
# исходнике; вердикт в переписке не переживает сессию): текст читается из
# HEAD-блоба, рабочее дерево не спрашивается. Грамматика секции «## Карта
# классов» — ЕДИНЫЙ ИСТОЧНИК scripts/lib_karta_sdachi.sh (И7); эта дверь
# грамматику не переизобретает.
#
# Коды возврата:
#   0 — карта валидна, stdout «КАРТА: 17/17 зелёный»;
#   1 — именованный отказ «ОТКАЗ: …»;
#   2 — NOT_IMPLEMENTED (нет git/sed, нет корня).

set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES \
      GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

otkaz() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
ni()    { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

command -v git >/dev/null 2>&1  || ni 'нет git'
command -v sed >/dev/null 2>&1 || ni 'нет sed'

[ $# -eq 2 ] || { printf 'использование: check_verdict_karta.sh <корень> <вердикт>\n' >&2; exit 1; }
ROOT="$(cd "$1" 2>/dev/null && pwd -P)" || ni "корня нет: $1"
VERDICT="$2"

case "$VERDICT" in
    verdicts/critic/*) : ;;
    *) otkaz "путь вердикта вне грамматики verdicts/critic/…: $VERDICT" ;;
esac
case "$VERDICT" in
    ''|/*|*..*) otkaz "путь вердикта вне грамматики (относительный, внутри корня): $VERDICT" ;;
esac

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
[ -r "$SELF_DIR/lib_karta_sdachi.sh" ] || ni 'нет lib_karta_sdachi.sh рядом с дверью'
# shellcheck disable=SC1091
. "$SELF_DIR/lib_karta_sdachi.sh"

# ТОЛЬКО закоммиченный вердикт (AGENTS п.9): читаем HEAD-блоб
telo="$(git -C "$ROOT" cat-file -p "HEAD:$VERDICT" 2>/dev/null)"
[ -n "$telo" ] || otkaz "вердикт не закоммичен (AGENTS п.9): $VERDICT нет на HEAD"

grep -q '^## Карта классов$' <<<"$telo" \
    || otkaz "вердикт без раздела «## Карта классов»: $VERDICT"

spisok="$(karta_proverit "$telo")" || otkaz "$VERDICT: $spisok"
printf 'КАРТА: 17/17 зелёный\n'
exit 0
