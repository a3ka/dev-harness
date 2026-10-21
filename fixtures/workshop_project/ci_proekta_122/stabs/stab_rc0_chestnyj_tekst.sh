#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ (Н-39; обход Б1 критика 122 «gate-warns-only»): честный ТЕКСТ, ложный КОД.
# Узнаёт субъекта по грамматике интерфейса (Г1 `--repo R --check|--write`, Г2 `--repo R …`,
# Г3 `<R> <контракт> [--freeze]`), исполняет его честную модель и ВСЕГДА выходит 0 — отказ
# напечатан, но pre_critic/freeze его не видят.
# Наблюдаемое расхождение: каждая клетка с литералом ожидаемого rc 1 (причина есть, rc не тот).
set -u
M=$(cd "$(dirname "$0")/../model" && pwd)
S=check_predposylki
if [ "${1:-}" = --repo ]; then
  S=ci_preflight
  for a in "$@"; do
    case "$a" in --check|--write) S=gen_project_workflow ;; esac
  done
fi
bash "$M/$S.sh" "$@"
exit 0
