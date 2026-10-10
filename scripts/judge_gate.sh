#!/usr/bin/env bash
# НЕ БАРЬЕР: предмет среза-2 контракта 008. Судья гейтит через CI-сигнал (Н-41): зовёт
# соседний check_ci_gate.sh с переданным SHA, пропускает его код в свой. Убирает локальный
# ре-прогон 15-23-мин пачки; судья подтверждает зелёное по ЗАПУШЕННОМУ HEAD.
# Принимает аргумент <sha>, поэтому не самодостаточен для прогона на текущем дереве без
# указания — verify_antiplacebo не покрывает.
#
# Контракт API (закреплён meta-барьером check_judge_gate.sh):
#   вход: $1 = <sha> (ОБЯЗАН передать в check_ci_gate — иначе bypass #3);
#   ищет check_ci_gate.sh рядом (SELF_DIR предмета);
#   rc: 0 если check_ci_gate rc=0, иначе rc≠0. На зелёном печатает «OK» последней строкой.
#
# Делегат verdict-строки журнала 094 (контракт 094, Решение 3, ПЕРЕСЕЧЕНИЕ 008/094):
# если окружение передаёт T094_TASK / T094_OBJECT_ID / T094_VERDICT_FILE — пишется
# СОБЫТИЕ решения судьи (вердикт-файл круга; CI success ≠ accept) строкой
#   verdict	<task>	<object_id>	<accept|fail>	<seq>
# в append-only журнал T094_JOURNAL (по умолчанию registry/candidates.tsv). seq =
# max(existing seqs для task) + 1. Семантика кругов 008 НЕ меняется — добавление
# поставки строки, не замена механики критика/адверсария/ревьюера. Источник
# object_id — глагол `object` двери accept_publish.sh (Решение 2): вычисляется
# дверью, не изобретается руками.
set -uo pipefail

sha="${1:?использование: $0 <sha>}"
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[ -x "$SELF/check_ci_gate.sh" ] || {
  printf 'ОТКАЗ: check_ci_gate.sh не найден рядом (нужен %s/check_ci_gate.sh)\n' "$SELF" >&2
  exit 1
}

rc=0
"$SELF/check_ci_gate.sh" "$sha" || rc=$?
if [ "$rc" = 0 ]; then printf 'OK\n'; fi

# ── делегат verdict-строки журнала 094 (контракт 094, ПЕРЕСЕЧЕНИЕ 008/094) ─────
# Поставка работает ТОЛЬКО когда весь набор ручек передан; в противном случае
# 008-семантика остаётся неизменной (судья гейтит через CI-сигнал, ничего не
# пишет). Запись строки verdict — append-only; rc гейта НЕ зависит от успеха
# записи (write — это side-effect журнала, не условие зелёного CI).
if [ "$rc" = 0 ] \
   && [ -n "${T094_TASK:-}" ] \
   && [ -n "${T094_OBJECT_ID:-}" ] \
   && [ -n "${T094_VERDICT_FILE:-}" ]; then
  _t94_journal="${T094_JOURNAL:-registry/candidates.tsv}"
  case "${T094_OBJECT_ID:-}" in
    [0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]) ;;
    *) _t94_journal="" ;;
  esac
  if [ -n "$_t94_journal" ] && [ -f "$_t94_journal" ]; then
    _t94_out=""
    case "${T094_TASK:-}" in ''|*[!A-Za-z0-9._/-]*) _t94_out=1 ;; esac
    if [ -z "$_t94_out" ] && [ -f "$T094_VERDICT_FILE" ]; then
      _t94_v="$(head -n 1 "$T094_VERDICT_FILE" 2>/dev/null | tr -d '\r')"
      _t94_v="${_t94_v#"${_t94_v%%[![:space:]]*}"}"
      _t94_v="${_t94_v%"${_t94_v##*[![:space:]]}"}"
      _t94_norm="$(printf '%s' "$_t94_v" | tr '[:upper:]' '[:lower:]')"
      if [ "$_t94_norm" = "accept" ]; then
        _t94_out="verdict	${T094_TASK}	${T094_OBJECT_ID}	accept"
      else
        _t94_out="verdict	${T094_TASK}	${T094_OBJECT_ID}	fail"
      fi
      _t94_seq=0
      while IFS= read -r line; do
        case "$line" in
          "verdict	${T094_TASK}	${T094_OBJECT_ID}	"*|"verdict	${T094_TASK}	"*)
            _t94_s="${line##*$'\t'}"
            case "$_t94_s" in ''|*[!0-9]*) continue ;; esac
            [ "$_t94_s" -gt "$_t94_seq" ] 2>/dev/null && _t94_seq="$_t94_s"
            ;;
        esac
      done <"$_t94_journal"
      _t94_seq=$((_t94_seq + 1))
      # Если файл журнала не оканчивается \n (артефакт начальной шапки без
      # завершающего перевода строки), добавим разделитель, иначе verdict-строка
      # склеится с последней строкой комментария и done_contract её не отделит.
      if [ -s "$_t94_journal" ] && [ "$(tail -c 1 "$_t94_journal" | wc -l)" -eq 0 ]; then
        printf '\n' >>"$_t94_journal" || true
      fi
      printf '%s\t%s\n' "$_t94_out" "$_t94_seq" >>"$_t94_journal" \
        || printf 'ОТКАЗ: verdict-строка не дописана: %s\n' "$_t94_journal" >&2
    fi
  fi
  unset _t94_journal _t94_v _t94_norm _t94_out _t94_seq _t94_s
fi

exit "$rc"