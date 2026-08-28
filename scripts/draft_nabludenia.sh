#!/usr/bin/env bash
# Черновик наблюдения: при отказе гейта пишет файл-заготовку в
# ${TMPDIR}/dev-harness-nabludenia/drafts/ (вне стерегомого дерева).
#
# Контракт 015, механизм 2 (Н-62-ядро). НЕ БАРЬЕР — логика черновиков, судится дриллом
# drill_gate_draft.sh; прецедент — утилиты без фикстур. ИНВАРИАНТЫ:
#
#   1. Гейт-паттерн — в скрипте, единственный источник. Гейт = локальный bash-вызов
#      scripts/{check_,verify_,drill_}*.sh, scripts/{freeze_contract,judge_gate,ci_diag}.sh
#      либо любой `npm run` из приёмки package.json. Команда не из списка → черновика нет,
#      rc=0 (не-гейт не порождает записей — иначе спам-генератор).
#   2. Черновик пишется в ${TMPDIR}/dev-harness-nabludenia/drafts/ (развилка 3) — ВНЕ
#      стерегомого дерева по построению 014.TMPDIR, канонически равный стерегомому корню
#      скрипта или лежащий внутри него (любой лексический вид; путь может не существовать —
#      каноникализация спуском до существующего предка), — именованный отказ код 1 ДО
#      создания чего-либо. При создании каталога кладётся шапка README: «ЧЕРНОВИКИ, не
#      записи: записать в NABLIUDENIA с адресом (механизм 1 красен без него) ИЛИ отвергнуть.
#      Поднимаются дайджестом старта сессии».
#   3. Формат. Одна строка на отказ: `ДАТА · ГЕЙТ <имя> · HEAD <hash8|-> · FAIL: <первые
#      ≤3 строки> · повторов: N`. HEAD — короткий хеш репозитория скрипта, вне git-репозитория
#      — прочерк.
#   4. Анти-спам = дедуп по ключу (команда + первая FAIL-строка): повтор того же отказа —
#      РОВНО ОДИН файл, счётчик повторов растёт, дата последнего обновляется; другой отказ —
#      другой файл (детерминированная функция ключа: одинаковый ключ → один и тот же путь).
#   5. Коды. 0 — черновик записан/дедупнут либо не-гейт пропущен; 1 — именованный отказ
#      (база внутри стерегомого дерева); внутренние ошибки — печать причины в stderr и
# Использование:
#   bash scripts/draft_nabludenia.sh "<команда>" "<голова FAIL-строк>"
#
# НЕ БАРЬЕР: утилита-черновик, логика судится дриллом drill_gate_draft.sh на собственной
# песочнице (7 фикстур красных входов через подмену субъектов).
#
set -uo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUARDED_ROOT="$(cd "$SELF_DIR/.." && pwd)"
COMMAND="${1:-}"
FAIL_HEAD="${2:-}"

# ── инвариант 1: гейт-паттерн (единственный источник) ────────────────────────────
is_gate() {
  case "$1" in
    scripts/check_*.sh|scripts/verify_*.sh|scripts/drill_*.sh) return 0 ;;
    scripts/freeze_contract.sh|scripts/judge_gate.sh|scripts/ci_diag.sh) return 0 ;;
    "npm run "*)
      local script="${1#npm run }"
      # npm run check:*|drill:* — любой из package.json scripts. Запрещённых имён нет:
      # npm-скрипты проверки/дрилла считаются гейтами по построению.
      node -e 'const fs=require("fs");const p=JSON.parse(fs.readFileSync(process.argv[1]+"/package.json","utf8"));process.stdout.write(p.scripts&&process.argv[2] in p.scripts?"1":"0");' "$GUARDED_ROOT" "$script" 2>/dev/null | grep -q '^1$' && return 0
      return 1
      ;;
    *) return 1 ;;
  esac
}

if [ -z "$COMMAND" ]; then
  printf 'FAIL не-гейт: пустая команда\n' >&2; exit 0
fi

if ! is_gate "$COMMAND"; then
  # Не-гейт — спам-генератор не сработает. Тихий rc=0.
  exit 0
fi

# ── инвариант 2: TMPDIR вне стерегомого дерева ───────────────────────────────────
D_BASE_RAW="${TMPDIR:-/tmp}"
D_BASE=""
# Канонизация спуском до существующего предка + pwd -P (мера каноникализации 014).
_p="$D_BASE_RAW"; _tail=""
while [ ! -d "$_p" ] && [ -n "$_p" ]; do _tail="/${_p##*/}${_tail}"; _p="${_p%/*}"; done
if [ -n "$_p" ] && _canon="$(cd "$_p" 2>/dev/null && pwd -P 2>/dev/null)"; then
  D_BASE="${_canon}${_tail}"
fi
_root_canon="$(cd "$GUARDED_ROOT" 2>/dev/null && pwd -P 2>/dev/null || printf '%s' "$GUARDED_ROOT")"
if [ -z "$D_BASE" ]; then
  printf 'FAIL дерево: TMPDIR не разрешается в канонический путь (%s)\n' "$D_BASE_RAW" >&2
  exit 1
fi
case "$D_BASE" in
  "$_root_canon"|"$_root_canon"/*)
    printf 'FAIL дерево: TMPDIR внутри стерегомого корня (%s � %s) — черновики ВНЕ дерева\n' \
      "$D_BASE" "$_root_canon" >&2
    exit 1
    ;;
esac

DRAFTS="$D_BASE/dev-harness-nabludenia/drafts"

if ! mkdir -p "$DRAFTS" 2>/dev/null; then
  printf 'draft_nabludenia: mkdir %s не удался\n' "$DRAFTS" >&2
  exit 0   # fail-open: сессия не падает
fi

# Шапка README кладётся при первом создании каталога. Идемпотентно: только если README нет.
if [ ! -f "$DRAFTS/README.md" ]; then
  {
    printf '# ЧЕРНОВИКИ, не записи: записать в NABLIUDENIA с адресом (механизм 1 красен без него)\n'
    printf '# ИЛИ отвергнуть. Поднимаются дайджестом старта сессии.\n'
  } > "$DRAFTS/README.md" 2>/dev/null || {
    printf 'draft_nabludenia: README не записан\n' >&2
  }
fi

# ── инвариант 4: дедуп по ключу (команда + первая FAIL-строка) ──────────────────
# Первая строка FAIL — берём из $FAIL_HEAD первый перевод строки.
FIRST_FAIL="$(printf '%s\n' "$FAIL_HEAD" | head -n 1)"
KEY="${COMMAND}${FIRST_FAIL}"
# sha256sum — детерминированная функция ключа: одинаковый ключ → один и тот же путь.
HASH="$(printf '%s' "$KEY" | sha256sum | cut -d' ' -f1 | cut -c1-16)"

DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
GATE_NAME="$COMMAND"

# HEAD репозитория скрипта (короткий хеш). Вне git — прочерк.
if command -v git >/dev/null 2>&1 && git -C "$GUARDED_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  HEAD_SHORT="$(git -C "$GUARDED_ROOT" rev-parse --verify --short=8 HEAD 2>/dev/null || printf -- '-')"
else
  HEAD_SHORT="-"
fi

# FAIL: первые ≤3 строки (плоские, перевод строки заменён на ` | `).
FAIL_LINES="$(printf '%s' "$FAIL_HEAD" | head -n 3 | paste -sd' | ' - 2>/dev/null)"
[ -z "$FAIL_LINES" ] && FAIL_LINES="$FAIL_HEAD"

OUT="$DRAFTS/$HASH.md"

# Дедуп: если файл есть, обновляем счётчик и дату; иначе создаём с повторов: 1.
if [ -f "$OUT" ]; then
  PREV_COUNT="$(grep -oE 'повторов: [0-9]+' "$OUT" 2>/dev/null | tail -n 1 | grep -oE '[0-9]+' || printf '1')"
  NEW_COUNT=$((PREV_COUNT + 1))
  # Перезаписываем файл целиком с обновлённой датой и счётчиком.
  if ! printf '%s · ГЕЙТ %s · HEAD %s · FAIL: %s · повторов: %s\n' \
      "$DATE" "$GATE_NAME" "$HEAD_SHORT" "$FAIL_LINES" "$NEW_COUNT" > "$OUT" 2>/dev/null; then
    printf 'draft_nabludenia: перезапись %s не удалась\n' "$OUT" >&2
    exit 0
  fi
else
  if ! printf '%s · ГЕЙТ %s · HEAD %s · FAIL: %s · повторов: 1\n' \
      "$DATE" "$GATE_NAME" "$HEAD_SHORT" "$FAIL_LINES" > "$OUT" 2>/dev/null; then
    printf 'draft_nabludenia: создание %s не удалось\n' "$OUT" >&2
    exit 0
  fi
fi

exit 0
