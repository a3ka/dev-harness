#!/usr/bin/env bash
# Клетка И-2 «обязательные источники доступны и разрешаются по манифесту»
# (контракт 095, Выход п.2, круг 2). Замороженный мир, implementer: манифест
# НЕПУСТ, несёт каждый вид фрагмента (map/rules/context/zones/trace) с
# обязательностью; каждый profile-путь манифеста существует на диске мира
# (adr-фрагмент — каталог). Обман (s2: манифест не строится) → клетка красна.
set -uo pipefail
TAB="$(printf '\t')"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: manifest-razreshaetsja: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }

W="$(_t95_world i2)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_freeze "$R" 'scripts/toy.sh' >/dev/null
_t95_trace "$W/trace.tsv" implementer glm-4.7 denied

out="$(bash "$SUBJ" --repo "$R" --role implementer --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: i2: честный пак не строится (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
man="$(printf '%s\n' "$out" | sed -n '/^=== MANIFEST ===$/,/^=== BUDGET ===$/p' | sed '1d;$d')"
[ -n "$man" ] || { printf 'КРАСНО: i2: манифест пуст\n' >&2; exit 1; }
printf '%s\n' "$man" | grep -Fq "$(printf 'map\tPROJECT.md\tmandatory\tprofile')" || { printf 'КРАСНО: i2: манифест без map/PROJECT.md\n' >&2; exit 1; }
printf '%s\n' "$man" | grep -Fq "$(printf 'rules\tDEVELOPMENT.md\tmandatory\tprofile')" || { printf 'КРАСНО: i2: манифест без rules/DEVELOPMENT.md\n' >&2; exit 1; }
printf '%s\n' "$man" | grep -Fq "$(printf 'context\tcontracts/777-toy.md\tmandatory\tfrozen')" || { printf 'КРАСНО: i2: манифест без context-фрагмента\n' >&2; exit 1; }
printf '%s\n' "$man" | grep -Fq "$(printf 'zones\tcontracts/777-toy.md\tmandatory\tfrozen')" || { printf 'КРАСНО: i2: манифест без zones-фрагмента\n' >&2; exit 1; }
printf '%s\n' "$man" | grep -Fq "$(printf 'trace\t%s\tmandatory\ttrace' "$W/trace.tsv")" || { printf 'КРАСНО: i2: манифест без trace-фрагмента\n' >&2; exit 1; }
# каждый profile-путь манифеста существует на диске мира (adr — каталог)
while IFS="$TAB" read -r kind path mnd origin; do
  [ -z "${kind:-}" ] && continue
  case "$origin" in
    profile)
      if [ "$kind" = "adr" ]; then
        [ -d "$R/$path" ] || { printf 'КРАСНО: i2: манифест ссылается на несуществующий ADR-каталог: %s\n' "$path" >&2; exit 1; }
      else
        [ -f "$R/$path" ] || { printf 'КРАСНО: i2: манифест ссылается на несуществующий источник: %s\n' "$path" >&2; exit 1; }
      fi ;;
    frozen|draft|taskfile|trace) ;;
    *) printf 'КРАСНО: i2: происхождение вне алфавита: %s\n' "$origin" >&2; exit 1 ;;
  esac
done <<EOF
$man
EOF
exit 0
