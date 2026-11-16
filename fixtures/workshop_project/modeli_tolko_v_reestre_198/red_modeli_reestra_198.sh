#!/usr/bin/env bash
# Раннер батареи 198 «модели только в реестре» (ПРОВОДКА-ЭНФОРСМЕНТ: в CI
# батарея подключается этим bash-раннером, не как python-проба — форма 186).
# Режимы: --model (честная реализация зелена), --stabs (каждый стаб пойман),
# --repo <root> (живое дерево: красное до замены, зелёное после).
set -uo pipefail
root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel) || exit 2
case "${1-}" in
  --model|--stabs) args=("$1") ;;
  --repo)
    if [ "$#" -ne 2 ]; then
      printf '%s\n' 'USAGE: red_modeli_reestra_198.sh --model|--stabs|--repo <root>' >&2
      exit 2
    fi
    args=(--repo "$2")
    ;;
  *)
    printf '%s\n' 'USAGE: red_modeli_reestra_198.sh --model|--stabs|--repo <root>' >&2
    exit 2
    ;;
esac
exec python3 "$root/fixtures/workshop_project/modeli_tolko_v_reestre_198/probe.py" "${args[@]}"
