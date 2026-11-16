#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ (контракт 198, мутация MU-1 по вердикту Crit198V1): «дверь с
# переиначенным собственным разбором реестра». Рабочая jq-цепочка
# роли→тир→семейство→модель с ПЕРЕИМЕНОВАННЫМИ переменными (--arg rol/tir/fam,
# .roles[$rol]/.tiers[$tir].model/.models[$fam]) и строкой-упоминанием
# --resolve-model: обходит дословные токен-клетки прежней батареи, оставаясь
# вторым резолвером рядом с scripts/roles.ts. Устанавливается на место
# scripts/check_sud_model.sh в мутант-корне; ловится repo-клеткой
# repo_seam_door_no_own_parse (свойство: jq в двери после Р2 не нужен вовсе —
# не дословный токен, а синтаксис/инструмент разбора).
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
# порядок тот же, что у единого резолвера (roles.ts --resolve-model)
tier="$(jq -r --arg rol "$role" '.roles[$rol] // ""' "$CFG" 2>/dev/null)" || tier=""
[ -n "$tier" ] || { printf 'ОТКАЗ: тир роли не читается\n' >&2; exit 2; }
fam="$(jq -r --arg tir "$tier" '.tiers[$tir].model // ""' "$CFG" 2>/dev/null)" || fam=""
expected="$(jq -r --arg fam "${fam#@}" '.models[$fam] // ""' "$CFG" 2>/dev/null)" || expected=""
printf 'ожидалось %s\n' "$expected"
exit 0
