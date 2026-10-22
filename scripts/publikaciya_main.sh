#!/usr/bin/env bash
# publikaciya_main.sh — публикация main ДОКАЗАННЫМ ПРЕФИКСОМ (контракт 131, честная модель).
#
# Вызов: bash scripts/publikaciya_main.sh   (cwd = репозиторий станции, ветка main локальна)
# Соседи по каталогу: ci_klass.sh (единственный источник кодового хеша H и доказательства,
# контракт 087) и gitw (единственная дверь обмена, контракты 045/071).
#
# Публикуемая точка P — самый новый коммит first-parent линии origin/main..main, для которого
# `ci_klass.sh vorota <вершина main цели> <P>` даёт rc 0 (учётный либо код доказан тяжёлым
# прогоном по H). Всё новее P остаётся локальным и едет следующей публикацией.
#
# Коды: 0 — опубликовано или нечего публиковать; 1 — именованный отказ «ОТКАЗ публикация: …»
# (либо rc gitw ≠ 0 при пуше); 2 — «НЕЧЕМ СУДИТЬ публикация: …».
set -uo pipefail
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_CEILING_DIRECTORIES

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KL="$SELF_DIR/ci_klass.sh"
GW="$SELF_DIR/gitw"

otkaz()  { printf 'ОТКАЗ публикация: %s\n' "$1" >&2; exit 1; }
nechem() { printf 'НЕЧЕМ СУДИТЬ публикация: %s\n' "$1" >&2; exit 2; }

command -v git >/dev/null 2>&1 || nechem 'нет git'
[ -f "$KL" ] || nechem "нет классификатора $KL"
[ -f "$GW" ] || nechem "нет двери обмена $GW"

local_main="$(git rev-parse --verify --quiet 'refs/heads/main^{commit}')" \
  || otkaz 'локальной ветки main нет'
lr_out="$(bash "$GW" ls-remote origin refs/heads/main)" \
  || otkaz 'вершина main на origin не читается'
rmain="$(printf '%s\n' "$lr_out" | awk -F'\t' '$2 == "refs/heads/main" { print $1; exit }')"
[ -n "$rmain" ] || otkaz 'вершина main на origin не читается'
git cat-file -e "${rmain}^{commit}" 2>/dev/null || otkaz "вершина main цели ${rmain} не в локальной истории — сделай fetch"
if [ "$rmain" = "$local_main" ]; then printf 'ПУБЛИКАЦИЯ: нечего публиковать\n'; exit 0; fi
git merge-base --is-ancestor "$rmain" "$local_main" || otkaz "origin/main ${rmain} не предок main — main разошёлся с целью"

cands="$(git rev-list --first-parent "${rmain}..${local_main}")" || otkaz 'диапазон origin/main..main не читается'
P=""
while IFS= read -r c; do
  [ -n "$c" ] || continue
  out="$(bash "$KL" vorota "$rmain" "$c" 2>&1)"; rc=$?
  case "$rc" in
    0) P="$c"; break ;;
    1) : ;;
    *) nechem "доказательство не проверено на ${c}: ${out}" ;;
  esac
done <<<"$cands"

if [ -z "$P" ]; then
  H="$(bash "$KL" hash "$local_main" 2>/dev/null)"
  otkaz "нет доказанного префикса main; поезд нужен для H=${H}"
fi

ostatok="$(git rev-list --count "${P}..${local_main}")"
HP="$(bash "$KL" hash "$P" 2>/dev/null)"
bash "$GW" push origin "${P}:refs/heads/main"; gw_rc=$?
if [ "$gw_rc" -ne 0 ]; then
  printf 'ОТКАЗ публикация: gitw rc=%s на %s\n' "$gw_rc" "$P" >&2
  exit "$gw_rc"
fi
printf 'ПУБЛИКАЦИЯ: %s H=%s остаётся локально %s\n' "$P" "$HP" "$ostatok"
exit 0
