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
# CLI (решения 3-4 контракта 098; алфавиты — 041, грамматики строк — И-0 094):
#   judge_gate.sh <sha> --verdict-row <задача> <object_id> <вердикт-файл>
#       первая строка файла — СОБЫТИЕ решения (accept|FAIL|ESCALATE) —
#       ЕДИНСТВЕННЫЙ источник исхода: зелёный CI в accept НЕ превращается;
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
  printf 'использование: judge_gate.sh <sha> [--verdict-row <задача> <object_id> <файл> | --policy-row <object_id> <старая> <новая> <файл-санкции>]\n' >&2
  exit 1
}

SHA="${1:-}"; [ -n "$SHA" ] || usage
case "$SHA" in *[!0-9a-f]*|'') d98_die "sha не 40 hex: $SHA" ;; esac
[ "${#SHA}" -eq 40 ] || d98_die "sha не 40 hex: $SHA"
MODE=""
case "${2:-}" in
  --verdict-row)
    [ $# -eq 5 ] || d98_die "verdict-row: <sha> --verdict-row <задача> <object_id> <вердикт-файл> — аргументов $# , нужно 5"
    TASK="$3"; OID="$4"; VF="$5"; MODE=verdict ;;
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

case "$MODE" in
dver)
  [ -x "$SELF/check_ci_gate.sh" ] || { printf 'ОТКАЗ: check_ci_gate.sh не найден рядом (нужен %s/check_ci_gate.sh)\n' "$SELF" >&2; exit 1; }
  rc=0
  "$SELF/check_ci_gate.sh" "$(cd "$SELF/.." && pwd)" "$SHA" || rc=$? # t98-mV3: 008-семантика — ЖИВОЙ шлюз CI-сигнала (корень передан явно — гашение Р4-3а «корня нет»), ЖУРНАЛ НЕ ПИШЕТСЯ
  if [ "$rc" = 0 ]; then printf 'OK\n'; fi
  exit "$rc"
  ;;
verdict)
  [ -f "$JOURNAL" ] || d98_die "журнал: нет файла: $JOURNAL"
  case "$TASK" in ''|*[!A-Za-z0-9._/-]*) d98_die "задача вне алфавита: $TASK" ;; esac
  hex64 "$OID" || d98_die "object_id не 64 hex: $OID"
  [ -f "$VF" ] || d98_die "вердикт-файла нет: $VF"
  sod="$(head -n1 "$VF")" # t98-mV2: СОБЫТИЕ решения — единственный источник исхода (зелёный CI ≠ accept)
  case "$sod" in
    accept)   out=accept ;;
    FAIL|ESCALATE) out=fail ;;
    *) d98_die "событие решения не распознано: $sod" ;;
  esac
  seq="$(d98_seq)"
  printf 'verdict\t%s\t%s\t%s\t%s\n' "$TASK" "$OID" "$out" "$seq" >>"$JOURNAL" # t98-mV1
  printf 'verdict-строка записана: %s %s %s\n' "$TASK" "$OID" "$out"
  ;;
policy)
  [ -f "$JOURNAL" ] || d98_die "журнал: нет файла: $JOURNAL"
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
