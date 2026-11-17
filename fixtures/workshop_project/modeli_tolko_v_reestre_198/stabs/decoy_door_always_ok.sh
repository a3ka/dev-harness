#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ (контракт 198): «дверь всегда согласна». Сверки модели с
# назначением нет вовсе — любая модель судьи проходит. Ловится клеткой
# door_spawn_foreign_refused: чужая модель обязана отказывать rc 1.
set -u
mode=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --spawn) mode=spawn ;;
    --frontmatter|--verdict) mode=other ;;
    --root|--trace|--object|--session) shift ;;
  esac
  shift
done
if [ "$mode" = spawn ]; then
  printf 'СУДЬЯ СВОЕЙ МОДЕЛИ: дверь не смотрит\n'
  exit 0
fi
printf 'decoy: только --spawn\n' >&2
exit 2
