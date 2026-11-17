#!/usr/bin/env bash
# КОМПОНЕНТ ОБМАННОГО ДВОЙНИКА (контракт 198, мутация MU-5 по вердикту
# Crit198V2): файл-хелпер двери из двойника decoy_door_helper_fallback.sh —
# дословная jq-цепочка прежней двери (собственный разбор реестра). Ставится
# инсталлером этого двойника в мутант-корень как scripts/registry_lookup.sh;
# собственной привязки к STAB_BIND не имеет: его дефект наблюдается через
# клетку repo_seam_door_failclosed_resolver вместе с дверью-двойником.
# Справочник ожидания судейской модели (helper двери).
set -uo pipefail
role="${1:-}"; root="${2:-}"
[ -n "$root" ] || root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CFG="$root/config/agent_models.json"
[ -f "$CFG" ] || exit 2
tier="$(jq -r --arg r "$role" '.roles[$r] // ""' "$CFG" 2>/dev/null)" || tier=""
[ -n "$tier" ] || exit 2
fam="$(jq -r --arg t "$tier" '.tiers[$t].model // ""' "$CFG" 2>/dev/null)" || fam=""
case "$fam" in
  @*) fam="${fam#@}" ;;
  *) exit 2 ;;
esac
expected="$(jq -r --arg f "$fam" '.models[$f] // ""' "$CFG" 2>/dev/null)" || expected=""
[ -n "$expected" ] || exit 2
fbfam="$(jq -r --arg t "$tier" '.tiers[$t].fallback // ""' "$CFG" 2>/dev/null)" || fbfam=""
fbexpected=""
case "$fbfam" in
  @*) fbexpected="$(jq -r --arg f "${fbfam#@}" '.models[$f] // ""' "$CFG" 2>/dev/null)" || fbexpected="" ;;
  '') : ;;
esac
printf '%s\t%s\t%s\n' "$tier" "$expected" "$fbexpected"
