#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ (контракт 198): «дверь с жёсткой моделью». Ожидание суда не
# читается из реестра — зашит литерал сегодняшней модели. Ловится клеткой
# door_swap_green: перестановка реестра назначает критику другую модель,
# честная дверь принимает её, стаб отказывает (сценарий owner-PR #1000).
set -u
role="" ; model="" ; mode=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --spawn) mode=spawn ;;
    --frontmatter|--verdict) mode=other ;;
    --root|--trace|--object|--session) shift ;;
  esac
  case "$1" in
    critic|critic-sol|adversary|reviewer|arbiter) role="$1" ;;
    *) [ -n "$2" ] 2>/dev/null && model="$model" ;;
  esac
  [ "$1" = "--spawn" ] && model="${2:-}"
  shift
done
if [ "$mode" = spawn ]; then
  if [ "${model:-}" = "zai/glm-5.3" ]; then
    printf 'СУДЬЯ СВОЕЙ МОДЕЛИ: %s тир default модель %s\n' "$role" "$model"
    exit 0
  fi
  printf 'ОТКАЗ: модель не тира роли: %s тир default спавн %s\n' "$role" "${model:-}" >&2
  exit 1
fi
printf 'decoy: только --spawn\n' >&2
exit 2
