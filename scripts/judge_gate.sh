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
#   bash scripts/judge_gate.sh <sha> --verdict-row <задача> <object_id> <вердикт-файл>
# после зелёного CI-сигнала пишется СОБЫТИЕ решения судьи (вердикт-файл круга;
# CI success ≠ accept) строкой
#   verdict<TAB><задача><TAB><object_id><TAB><accept|fail><TAB><seq>
# в append-only журнал registry/candidates.tsv (относительно cwd вызывающего;
# создаётся писателем по требованию — Р2-2: журнал реален, не toy/mktemp).
# seq = max(seq строк задачи) + 1. Исход — первая строка вердикт-файла: «accept»
# (без учёта регистра/пробелов) → accept, иначе fail. Источник object_id — глагол
# `object` двери accept_publish.sh (Решение 2): вычисляется дверью, не изобретается.
# Р2-2 круга 3: T094_* env-гейты умерли — поставщик вызывается аргументами CLI из
# порядка ленда роли (roles/orchestrator.md), переключателей окружения нет.
# Без --verdict-row семантика 008 неизменна (судья гейтит CI-сигнал, ничего не пишет).
# rc гейта НЕ зависит от успеха записи (side-effect журнала, не условие зелёного CI).
set -uo pipefail

sha="${1:?использование: $0 <sha> [--verdict-row <задача> <object_id> <вердикт-файл>]}"
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── разбор делегата 094 (полный набор трёх значений; неполный — usage-отказ) ──
VR_TASK=""; VR_OID=""; VR_FILE=""
if [ $# -ge 2 ]; then
  shift
  while [ $# -gt 0 ]; do
    case "$1" in
      --verdict-row)
        VR_TASK="${2:?--verdict-row: задача}"; VR_OID="${3:?--verdict-row: object_id}"; VR_FILE="${4:?--verdict-row: вердикт-файл}"
        shift 4 ;;
      *) printf 'judge_gate: неизвестный аргумент: %s\n' "$1" >&2; exit 2 ;;
    esac
  done
fi

[ -x "$SELF/check_ci_gate.sh" ] || {
  printf 'ОТКАЗ: check_ci_gate.sh не найден рядом (нужен %s/check_ci_gate.sh)\n' "$SELF" >&2
  exit 1
}

rc=0
"$SELF/check_ci_gate.sh" "$sha" || rc=$?
if [ "$rc" = 0 ]; then printf 'OK\n'; fi

# ── поставка verdict-строки (только на зелёном CI-сигнале и полном наборе) ────
if [ "$rc" = 0 ] && [ -n "$VR_TASK" ] && [ -n "$VR_OID" ] && [ -n "$VR_FILE" ]; then
  _t94_journal="registry/candidates.tsv"
  printf '%s' "$VR_OID" | grep -qE '^[0-9a-f]{64}$' || _t94_journal=""
  case "$VR_TASK" in ''|*[!A-Za-z0-9._/-]*) _t94_journal="" ;; esac
  if [ -n "$_t94_journal" ] && [ -f "$VR_FILE" ]; then
    _t94_v="$(head -n 1 "$VR_FILE" 2>/dev/null | tr -d '\r')"
    _t94_v="${_t94_v#"${_t94_v%%[![:space:]]*}"}"
    _t94_v="${_t94_v%"${_t94_v##*[![:space:]]}"}"
    _t94_norm="$(printf '%s' "$_t94_v" | tr '[:upper:]' '[:lower:]')"
    if [ "$_t94_norm" = "accept" ]; then
      _t94_out="verdict	${VR_TASK}	${VR_OID}	accept"
    else
      _t94_out="verdict	${VR_TASK}	${VR_OID}	fail"
    fi
    mkdir -p "$(dirname "$_t94_journal")" 2>/dev/null || true
    # Журнал создаётся по требованию (Р2-2): писатель — первый, кто его коснулся.
    [ -f "$_t94_journal" ] || : >"$_t94_journal"
    _t94_seq=0
    while IFS= read -r line; do
      case "$line" in
        "verdict	${VR_TASK}	"*)
          _t94_s="${line##*$'\t'}"
          case "$_t94_s" in ''|*[!0-9]*) continue ;; esac
          [ "$_t94_s" -gt "$_t94_seq" ] 2>/dev/null && _t94_seq="$_t94_s"
          ;;
      esac
    done <"$_t94_journal"
    _t94_seq=$((_t94_seq + 1))
    # Если файл журнала не оканчивается \n (артефакт создания без строк), добавим
    # разделитель, иначе verdict-строка склеится с последней строкой комментария
    # и done_contract/дверь её не отделит.
    if [ -s "$_t94_journal" ] && [ "$(tail -c 1 "$_t94_journal" | wc -l)" -eq 0 ]; then
      printf '\n' >>"$_t94_journal" || true
    fi
    printf '%s\t%s\n' "$_t94_out" "$_t94_seq" >>"$_t94_journal" \
      || printf 'ОТКАЗ: verdict-строка не дописана: %s\n' "$_t94_journal" >&2
  fi
  unset _t94_journal _t94_v _t94_norm _t94_out _t94_seq _t94_s
fi
exit "$rc"
