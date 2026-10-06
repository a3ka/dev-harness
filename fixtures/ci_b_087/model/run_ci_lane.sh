#!/usr/bin/env bash
# МОДЕЛЬ scripts/run_ci_lane.sh (083) с дельтой 087 — НЕ субъект: ключ разрешается по
# строкам step И legkij реестра (И-2), после КАЖДОГО исполненного ключа — строка замера
# «замер: <ключ> <секунды>» отдельной строкой stdout (И-8). Остановка на первом отказе с
# именем ключа, rc шага проксируется (083 И-2). Стабы: M087_STAB=bez-zamera — строки замера
# нет; M087_STAB=legkij-glotaet — отказ ключа вида legkij, последнего в вызове, гасится
# (проверка rc отложена на следующую итерацию и после цикла потеряна; rc 0).
set -uo pipefail
REG=registry/ci-steps.tsv
[ -f "$REG" ] || { printf 'ОТКАЗ: нет %s (вызов из корня worktree)\n' "$REG" >&2; exit 1; }
[ "$#" -ge 1 ] || { printf 'ОТКАЗ: ключей нет\n' >&2; exit 1; }
for key in "$@"; do
  line="$(awk -F'\t' -v k="$key" '($1=="step"||$1=="legkij") && $2==k {print; exit}' "$REG")"
  [ -n "$line" ] || { printf 'ОТКАЗ: неизвестный ключ: %s\n' "$key" >&2; exit 1; }
  cmd="$(printf '%s\n' "$line" | cut -f4-)"
  t0="$(date +%s)"
  bash -c "$cmd"
  rc=$?
  t1="$(date +%s)"
  [ "${M087_STAB:-}" = bez-zamera ] || printf 'замер: %s %d\n' "$key" "$((t1 - t0))"
  [ "${M087_STAB:-}" = legkij-glotaet ] && [ "${line%%$'\t'*}" = legkij ] && [ "$key" = "${!#}" ] && rc=0
  [ "$rc" -eq 0 ] || { printf 'ОТКАЗ: шаг %s rc %d\n' "$key" "$rc" >&2; exit "$rc"; }
done
