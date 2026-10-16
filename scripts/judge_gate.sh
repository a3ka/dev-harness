#!/usr/bin/env bash
# Судья: три режима (контракты 008 срез-2 и 098 решения 3-4). НЕ БАРЬЕР:
# предмет — мета-барьер scripts/check_judge_gate.sh.
#
#   judge_gate.sh <sha>
#       семантика 008 НЕИЗМЕННА (Б-7): шлюз к соседнему check_ci_gate.sh,
#       rc-проход, «OK» на зелёном, ЖУРНАЛ НЕ ПИШЕТСЯ. Контракт API (закреплён
#       check_judge_gate.sh): вход $1 = <sha> ОБЯЗАН передаваться в
#       check_ci_gate ПЕРВЫМ аргументом (иначе bypass #3); скрипт ищется рядом
#       (SELF предмета); rc 0 ⟺ его rc 0.
#
#   judge_gate.sh <sha> --verdict-row <задача> <object_id> <вердикт-файл> --sud <роль> <трасса> <session>
#       verdict-писатель (098 решение 3 + 104 Решение 4): исход — ТОЛЬКО
#       СОБЫТИЕ решения из ПЕРВОЙ строки вердикт-файла круга
#       (accept|FAIL|ESCALATE; зелёный CI в accept НЕ превращается);
#       ПЕРЕД записью строки зовёт соседний check_sud_model.sh
#       «--verdict <роль> --trace <трасса> --object <sha> --session <session>»
#       (порядок литеральный): rc двери ≠ 0 → строка НЕ пишется, rc двери
#       пробрасывается; тройки --sud нет → rc 1 «свидетельство судьи не
#       передано» (не bootstrap-пропуск); строка `verdict` с object_id — в
#       журнал принятой стороны $SELF/../registry/candidates.tsv (грамматика
#       И-0 контракта 094; журнал вне проверяемой ветки, Б-6; append-only;
#       создаётся писателем при отсутствии — контракт 098).
#
#   judge_gate.sh <sha> --policy-row <object_id> <старая> <новая> <файл-санкции>
#       policy-писатель (098, решение 4): переход политики — ДОВЕРЕННЫЙ
#       судейский канал, кандидат и ленд строку policy не пишут; первая строка
#       файла-санкции — accept, иначе именованный отказ rc 1.
#
# Коды возврата: 0 — гейт зелёный / строка журнала записана, 1 — отказ с
# именованной причиной («ОТКАЗ: …»), 2 — NOT_IMPLEMENTED (нечем проверять).
set -uo pipefail

SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JOURNAL="$SELF/../registry/candidates.tsv"

d98_die() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
d98_ni()  { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

command -v head >/dev/null 2>&1 || d98_ni "нет head — первую строку вердикт-файла нечем взять"

hex64() { case "$1" in ''|*[!0-9a-f]*) return 1 ;; esac; [ "${#1}" -eq 64 ]; }
hex40() { case "$1" in ''|*[!0-9a-f]*) return 1 ;; esac; [ "${#1}" -eq 40 ]; }

usage() {
  printf 'использование: judge_gate.sh <sha> [--verdict-row <задача> <object_id> <вердикт-файл> --sud <роль> <трасса> <session> | --policy-row <object_id> <старая> <новая> <файл-санкции>]\n' >&2
  exit 1
}

SHA="${1:-}"; [ -n "$SHA" ] || usage
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

# следующий seq журнала: положительные целые verdict|$5, policy|$6 (И-0 094)
d98_seq() {
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
  # 008: живой шлюз CI-сигнала; журнал не пишется (запись — только с флагом).
  # Форма вызова «sha первым» пинита мета-барьером check_judge_gate.sh;
  # корень для check_ci_gate вычисляет сам исполнитель (см. шапку соседа).
  [ -x "$SELF/check_ci_gate.sh" ] || { printf 'ОТКАЗ: check_ci_gate.sh не найден рядом (нужен %s/check_ci_gate.sh)\n' "$SELF" >&2; exit 1; }
  rc=0
  "$SELF/check_ci_gate.sh" "$SHA" || rc=$?
  if [ "$rc" = 0 ]; then printf 'OK\n'; fi
  exit "$rc"
  ;;
verdict)
  hex40 "$SHA" || d98_die "sha не 40 hex: $SHA"
  # журнал создаётся писателем при отсутствии (контракт 098: append-only)
  [ -f "$JOURNAL" ] || { : >"$JOURNAL" || d98_die "журнал: не создать: $JOURNAL"; }
  case "$TASK" in ''|*[!A-Za-z0-9._/-]*) d98_die "задача вне алфавита: $TASK" ;; esac
  hex64 "$OID" || d98_die "object_id не 64 hex: $OID"
  [ -f "$VF" ] || d98_die "вердикт-файла нет: $VF"
  sod="$(head -n1 "$VF")"  # СОБЫТИЕ решения — единственный источник исхода (зелёный CI ≠ accept)
  case "$sod" in
    accept)        out=accept ;;
    FAIL|ESCALATE) out=fail ;;
    *) d98_die "событие решения не распознано: $sod" ;;
  esac
  # Свидетельство судьи (контракт 104, Решение 4): строка пишется ТОЛЬКО
  # после rc 0 двери сверки фактической сессии судьи (роль/модель/фолбэк по
  # трассе с привязкой сессии и объекта). Тройки --sud нет — не bootstrap:
  # именованный отказ, строка не пишется. rc двери пробрасывается (1 → 1
  # с причиной двери на stderr, 2 → 2).
  if [ "${SUD_MISSING:-0}" = 1 ]; then
    d98_die "свидетельство судьи не передано (--sud <роль> <трасса> <session>)"
  fi
  [ -x "$SELF/check_sud_model.sh" ] || { printf 'ОТКАЗ: check_sud_model.sh не найден рядом (нужен %s/check_sud_model.sh)\n' "$SELF" >&2; exit 2; }
  rc=0
  "$SELF/check_sud_model.sh" --verdict "$SUD_ROLE" --trace "$SUD_TRACE" --object "$SHA" --session "$SUD_SESSION" || rc=$?
  [ "$rc" -eq 0 ] || exit "$rc"
  seq="$(d98_seq)"
  printf 'verdict\t%s\t%s\t%s\t%s\n' "$TASK" "$OID" "$out" "$seq" >>"$JOURNAL" \
    || d98_die "журнал: verdict-строка не записана: $JOURNAL"
  printf 'verdict-строка записана: %s %s %s\n' "$TASK" "$OID" "$out"
  ;;
policy)
  hex40 "$SHA"  || d98_die "sha не 40 hex: $SHA"
  # журнал создаётся писателем при отсутствии (контракт 098: append-only)
  [ -f "$JOURNAL" ] || { : >"$JOURNAL" || d98_die "журнал: не создать: $JOURNAL"; }
  hex64 "$OID"  || d98_die "object_id не 64 hex: $OID"
  hex64 "$OLDV" || d98_die "старая policyVersion не 64 hex: $OLDV"
  hex64 "$NEWV" || d98_die "новая policyVersion не 64 hex: $NEWV"
  [ "$OLDV" != "$NEWV" ] || d98_die "переход политики: версии совпадают"
  [ -f "$SF" ] || d98_die "файла-санкции нет: $SF"
  sod="$(head -n1 "$SF")"
  [ "$sod" = accept ] || d98_die "санкция не выдана: $sod"
  seq="$(d98_seq)"
  printf 'policy\t%s\t%s\t%s\taccept\t%s\n' "$OID" "$OLDV" "$NEWV" "$seq" >>"$JOURNAL" \
    || d98_die "журнал: policy-строка не записана: $JOURNAL"
  printf 'policy-строка записана: %s %s -> %s\n' "$OID" "$OLDV" "$NEWV"
  ;;
esac
exit 0
