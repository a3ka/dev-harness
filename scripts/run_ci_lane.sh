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
declare -A STEP_CMD=()
declare -A STEP_WEIGHT=()
while IFS=$'\t' read -r kind key weight command; do
  case "$kind" in
    step)
      [ -n "$key" ] || continue
      STEP_CMD["$key"]="$command"
      STEP_WEIGHT["$key"]="$weight"
      ;;
  esac
done < <(awk -F'\t' '$1=="step" || $1=="lanes" || $1=="shard"' "$REG")

# Исполнение ключей в порядке вызова; rc 0 на всех, любое отклонение —
# именованный отказ, остановка.
for k in "$@"; do
  cmd="${STEP_CMD[$k]:-}"
  if [ -z "$cmd" ]; then
    printf 'lane: неизвестный ключ: %s\n' "$k" >&2
    exit 1
  fi
  printf '+ %s\n' "$cmd" >&2
  bash -c "$cmd"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    printf 'lane: отказ ключа %s (rc=%s)\n' "$k" "$rc" >&2
    exit "$rc"
  fi
done
exit 0
