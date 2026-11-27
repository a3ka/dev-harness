#!/usr/bin/env bash
# scripts/run_ci_lane.sh — lane-раннер параллельной джобы `ci` (контракт 083,
# инвариант 2). Исполняет ключи lane В ПОРЯДКЕ АРГУМЕНТОВ, останавливаясь
# на первом отказе именем ключа. Исполнение в cwd, из которого вызван раннер.
#
# Использование: bash scripts/run_ci_lane.sh <ключ> [<ключ> ...]
#   rc 0 — все ключи lane зелёные (порядок сохранён, журнал done.log по порядку);
#   rc 1 — отказ шага (причина именует ключ) ИЛИ неизвестный ключ (тоже именованный);
#   rc ≥2 — отказ bash'а (например, пропавший registry/ci-steps.tsv).
#
# Коды возврата:
# Грамматика:
#   * registry ОБЯЗАН существовать: `registry/ci-steps.tsv` относительно cwd.
#     Отсутствие — именованный отказ rc 1, файлы не трогаются.
#   * `step`-строка резолвится: `bash <путь>` исполняется в cwd; `npm run <key>`
#     резолвится в `npm run <key>` в cwd (cwd обязан быть деревом с package.json).
#   * Неизвестный ключ — именованный отказ rc 1, ни один более ранний ключ
#     того же вызова не должен был не отработать.
#
# Защиты (модель угроз контракта 083, инвариант 2):
#   * остановка на первом отказе — fail-fast (поведение прежней последовательной
#     джобы, прецедент 082; не ослабление);
#   * неизвестный ключ — rc 1, НЕ тихий успех (НЕ пропуск);
#   * реестр открывается от cwd — никаких абсолютных путей, никаких
#     «по умолчанию» в /home/harness.
set -uo pipefail

REG="registry/ci-steps.tsv"
if [ ! -f "$REG" ]; then
  printf 'lane: предмет отсутствует: нет реестра %s\n' "$REG" >&2
  exit 1
fi
if [ "$#" -lt 1 ]; then
  printf 'lane: использование: bash scripts/run_ci_lane.sh <ключ> [<ключ> ...]\n' >&2
  exit 1
fi

# Сборка индекса ключ→команда в памяти (файл мал, читаем один раз).
# Контракт 087 И-2: ключи обоих видов (step ∪ legkij) исполняются одинаково —
# индекс общий. Контракт 083 И-1: грамматика строки «tab/key/weight/command»,
# комментарии — строки, начинающиеся с «#» (после tab-strip'а).
declare -A LANE_CMD=()
declare -A LANE_WEIGHT=()
while IFS=$'\t' read -r kind key weight command; do
  case "$kind" in
    step|legkij)
      [ -n "$key" ] || continue
      LANE_CMD["$key"]="$command"
      LANE_WEIGHT["$key"]="$weight"
      ;;
  esac
done < <(awk -F'	' '/^[[:space:]]*#/ {next} $1=="step" || $1=="legkij" {print}' "$REG")

# Исполнение ключей в порядке вызова; rc 0 на всех, любое отклонение —
# именованный отказ, остановка. Контракт 087 И-9: после КАЖДОГО исполненного
# ключа печатается строка замера отдельной строкой stdout: «замер: <key> <sec>».
for k in "$@"; do
  cmd="${LANE_CMD[$k]:-}"
  if [ -z "$cmd" ]; then
    printf 'lane: неизвестный ключ: %s\n' "$k" >&2
    exit 1
  fi
  printf '+ %s\n' "$cmd" >&2
  t0="$(date +%s)"
  # GITHUB_EVENT_NAME у self-test'ов СНИМАЕТСЯ (решение консультанта m2541 п.3,
  # вариант (б)). Джоба pull_request экспортирует GITHUB_EVENT_NAME=pull_request
  # в окружение ВСЕХ шагов lane, а замороженное И1 218
  # (contracts/218-okno-frozen-v-pr.md) включает по этой переменной режим
  # окна PR: его включают проверки check_charter/check_contract_frozen по
  # переменной окружения GITHUB_EVENT_NAME=pull_request; миру нужна база
  # origin/main, которой в мирах батарей НЕТ — зелёные на push шаги краснеют
  # PR_WINDOW_BASE_MISSING (PR #1442, run 45772933886: l6
  # check:charter-tekst-do-tega-210-family-selftest, l7
  # check:incr-pustoe-okno-217-family-selftest, l4 check:document, l2
  # drill:contract-change). Правило — данные/узкий предикат по КЛАССАМ ключей
  # (R-0102), не «все шаги»:
  #   * `*-family-selftest` — self-test'ы батарей семей (измерено красны
  #     210/217; остальные члены класса переменную не читают, чистка им
  #     безразлична);
  #   * `check:document` — doc-батарея строит миры с check_charter без
  #     PR-базы;
  #   * `drill:contract-change` — учебный прогон ведёт check_contract_frozen
  #     в toy-мире без origin/main.
  # Реальные проверки уставной защиты (legkij: check:charter,
  # check:contract-frozen и др.) переменную СОХРАНЯЮТ: окно PR в бою обязано
  # видеть событие.
  case "$k" in
    *-family-selftest|check:document|drill:contract-change)
      env -u GITHUB_EVENT_NAME bash -c "$cmd"
      ;;
    *)
      bash -c "$cmd"
      ;;
  esac
  rc=$?
  t1="$(date +%s)"
  printf 'замер: %s %d\n' "$k" "$((t1 - t0))"
  if [ "$rc" -ne 0 ]; then
    printf 'lane: отказ ключа %s (rc=%s)\n' "$k" "$rc" >&2
    exit "$rc"
  fi
done
exit 0
