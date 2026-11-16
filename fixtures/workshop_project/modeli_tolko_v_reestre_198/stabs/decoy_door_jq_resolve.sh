#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ (контракт 198): «дверь со собственным разбором реестра». Копия
# ДО-правки: jq-цепочка .roles[$r] → .tiers[$t].model → .models[$f] живёт в
# двери, второй резолвер рядом с scripts/roles.ts. Устанавливается на место
# scripts/check_sud_model.sh в мутант-корне; ловится repo-клеткой
# repo_seam_door_no_private (токены собственного разбора в двери).
set -u
CFG=""
role=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --root) CFG="$2/config/agent_models.json" ;;
    critic|critic-sol|adversary|reviewer|arbiter) role="$1" ;;
  esac
  shift
done
tier="$(jq -r --arg r "$role" '.roles[$r] // ""' "$CFG" 2>/dev/null)" || tier=""
[ -n "$tier" ] || { printf 'ОТКАЗ: тир роли не читается\n' >&2; exit 2; }
fam="$(jq -r --arg t "$tier" '.tiers[$t].model // ""' "$CFG" 2>/dev/null)" || fam=""
expected="$(jq -r --arg f "${fam#@}" '.models[$f] // ""' "$CFG" 2>/dev/null)" || expected=""
printf 'ожидалось %s\n' "$expected"
exit 0
