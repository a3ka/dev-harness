#!/usr/bin/env bash
# Честная модель судейского писателя (контракт 098) — носитель ГРАММАТИКИ
# субъекта scripts/judge_gate.sh: без флага — семантика 008 НЕИЗМЕННА (шлюз к
# соседнему check_ci_gate.sh, rc-проход, «OK» на зелёном, ЖУРНАЛ НЕ ПИШЕТСЯ);
# --verdict-row / --policy-row — писатели строк журнала принятой стороны
# registry/candidates.tsv (журнал — $SELF/../registry, объект — git-объекты).
# Модель — не продукт: живёт в семье батареи, используется режимом --model
# раннера и стаб-паком battery_stubs.sh (маркеры # t98-mVN — единственные
# строки-носители инвариантов, НЕ удалять и НЕ переименовывать без синхронной
# правки стаб-пака).
#
# CLI (решения 3-4 контракта 098 + решение 4 контракта 104; алфавиты — 041,
# грамматики строк — И-0 094):
#   judge_gate.sh <sha> --verdict-row <задача> <object_id> <вердикт-файл> --sud <роль> <трасса> <session>
#       первая строка файла — СОБЫТИЕ решения (accept|FAIL|ESCALATE) —
#       ЕДИНСТВЕННЫЙ источник исхода: зелёный CI в accept НЕ превращается;
#       перед записью строки — соседний check_sud_model.sh
#       «--verdict <роль> --trace <трасса> --object <sha> --session <session>»:
#       rc ≠ 0 → строка НЕ пишется, rc пробрасывается; тройки --sud нет →
#       rc 1 «свидетельство судьи не передано» (не bootstrap-пропуск);
#   judge_gate.sh <sha> --policy-row <object_id> <старая> <новая> <файл-санкции>
#       первая строка файла-санкции — accept; переход политики — доверенный
#       канал (судейский), кандидат и ленд строку policy не пишут;
#   judge_gate.sh <sha> — семантика 008: гейт CI-сигнала, ничего не пишет.
# Отказы rc 1 — именованные «ОТКАЗ: …»; rc 2 — NOT_IMPLEMENTED.
set -uo pipefail
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JOURNAL="$SELF/../registry/candidates.tsv"

d98_die() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
d98_ni()  { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }
command -v git >/dev/null 2>&1      || d98_ni "нет git"
command -v sha256sum >/dev/null 2>&1 || d98_ni "нет sha256sum"

hex64() { case "$1" in ''|*[!0-9a-f]*) return 1 ;; esac; [ "${#1}" -eq 64 ]; }

usage() {
  printf 'использование: judge_gate.sh <sha> [--verdict-row <задача> <object_id> <файл> --sud <роль> <трасса> <session> | --policy-row <object_id> <старая> <новая> <файл-санкции>]\n' >&2
  exit 1
}

SHA="${1:-}"; [ -n "$SHA" ] || usage
case "$SHA" in *[!0-9a-f]*|'') d98_die "sha не 40 hex: $SHA" ;; esac
[ "${#SHA}" -eq 40 ] || d98_die "sha не 40 hex: $SHA"
MODE=""
case "${2:-}" in
  --verdict-row)
    case $# in
      5) TASK="$3"; OID="$4"; VF="$5"; MODE=verdict; SUD_MISSING=1 ;;
      9) [ "$6" = --sud ] || d98_die "verdict-row: шестой аргумент — не --sud: $6"
         TASK="$3"; OID="$4"; VF="$5"
         SUD_ROLE="$7"; SUD_TRACE="$8"; SUD_SESSION="$9"; MODE=verdict ;;
      *) d98_die "verdict-row: <sha> --verdict-row <задача> <object_id> <вердикт-файл> --sud <роль> <трасса> <session> — аргументов $#, нужно 5 или 9" ;;
    esac ;;
  --policy-row)
    [ $# -eq 6 ] || d98_die "policy-row: <sha> --policy-row <object_id> <старая> <новая> <файл-санкции> — аргументов $# , нужно 6"
    OID="$3"; OLDV="$4"; NEWV="$5"; SF="$6"; MODE=policy ;;
  '')
    [ $# -eq 1 ] || d98_die "лишние аргументы без флага: семантика 008 — ровно один <sha>"
    MODE=dver ;;
  *) d98_die "неизвестный флаг: ${2:-}" ;;
esac

d98_seq() {  # следующий seq журнала (verdict|$5, policy|$6 — положительные целые)
  local s=0 k f2 f3 f4 f5 f6 sq
  while IFS=$'\t' read -r k f2 f3 f4 f5 f6; do
    case "$k" in verdict) sq="$f5" ;; policy) sq="$f6" ;; *) continue ;; esac
    case "$sq" in ''|*[!0-9]*) d98_die "журнал: грамматика: seq" ;; esac
    [ "$sq" -gt "$s" ] && s="$sq"
  done <"$JOURNAL"
  printf '%s' "$((s+1))"
}

# журнал СОЗДАЁТСЯ писателем (контракт 098: «журнал создаётся писателями,
# append-only»): отсутствие файла — не отказ; создание append-режимом (>>),
# существующий журнал не усекается
d98_journal() {
  [ -f "$JOURNAL" ] || { mkdir -p "${JOURNAL%/*}" && : >>"$JOURNAL"; } || d98_die "журнал: не создаётся: $JOURNAL" # t98-mJ1: писатель создаёт отсутствующий журнал (ревьюер 098 Рв1-1)
}

case "$MODE" in
dver)
  [ -x "$SELF/check_ci_gate.sh" ] || { printf 'ОТКАЗ: check_ci_gate.sh не найден рядом (нужен %s/check_ci_gate.sh)\n' "$SELF" >&2; exit 1; }
  rc=0
  "$SELF/check_ci_gate.sh" "$(cd "$SELF/.." && pwd)" "$SHA" || rc=$? # t98-mV3: 008-семантика — ЖИВОЙ шлюз CI-сигнала (корень передан явно — гашение Р4-3а «корня нет»), ЖУРНАЛ НЕ ПИШЕТСЯ
  if [ "$rc" = 0 ]; then printf 'OK\n'; fi
  exit "$rc"
  ;;
verdict)
  d98_journal
  case "$TASK" in ''|*[!A-Za-z0-9._/-]*) d98_die "задача вне алфавита: $TASK" ;; esac
  hex64 "$OID" || d98_die "object_id не 64 hex: $OID"
  [ -f "$VF" ] || d98_die "вердикт-файла нет: $VF"
  sod="$(head -n1 "$VF")" # t98-mV2: СОБЫТИЕ решения — единственный источник исхода (зелёный CI ≠ accept)
  case "$sod" in
    accept)   out=accept ;;
    FAIL|ESCALATE) out=fail ;;
    *) d98_die "событие решения не распознано: $sod" ;;
  esac
  # свидетельство судьи (контракт 104, Решение 4): строка — только после rc 0
  # двери; тройки нет — именованный отказ, не bootstrap
  if [ "${SUD_MISSING:-0}" = 1 ]; then
    d98_die "свидетельство судьи не передано (--sud <роль> <трасса> <session>)"
  fi
  [ -x "$SELF/check_sud_model.sh" ] || d98_ni "check_sud_model.sh не найден рядом: $SELF"
  rc=0
  "$SELF/check_sud_model.sh" --verdict "$SUD_ROLE" --trace "$SUD_TRACE" --object "$SHA" --session "$SUD_SESSION" || rc=$?
  [ "$rc" -eq 0 ] || exit "$rc"
  seq="$(d98_seq)"
  printf 'verdict\t%s\t%s\t%s\t%s\n' "$TASK" "$OID" "$out" "$seq" >>"$JOURNAL" # t98-mV1
  printf 'verdict-строка записана: %s %s %s\n' "$TASK" "$OID" "$out"
  ;;
policy)
  d98_journal
  hex64 "$OID"  || d98_die "object_id не 64 hex: $OID"
  hex64 "$OLDV" || d98_die "старая policyVersion не 64 hex: $OLDV"
  hex64 "$NEWV" || d98_die "новая policyVersion не 64 hex: $NEWV"
  [ "$OLDV" != "$NEWV" ] || d98_die "переход политики: версии совпадают"
  [ -f "$SF" ] || d98_die "файла-санкции нет: $SF"
  sod="$(head -n1 "$SF")"
  [ "$sod" = accept ] || d98_die "санкция не выдана: $sod"
  seq="$(d98_seq)"
  printf 'policy\t%s\t%s\t%s\taccept\t%s\n' "$OID" "$OLDV" "$NEWV" "$seq" >>"$JOURNAL" # t98-mP1
  printf 'policy-строка записана: %s %s -> %s\n' "$OID" "$OLDV" "$NEWV"
  ;;
esac
exit 0
