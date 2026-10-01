#!/usr/bin/env bash
# ДВЕРЬ ПЕРЕЗАПУСКА КРИТИКА (контракт 072, v2.1).
# ЕДИНСТВЕННЫЙ вход к спавну критика: критик зовётся только после rc 0
# этой двери; отказ (rc 1) = назад архитектору, критик не зовётся.
#
# Три ноги, порядок строгий (а)→(б)→(в):
#   (а) npm run check:precision-gate -- . <contract> → красное = отказ
#                                                       (маркер «precision-gate»)
#   (б) npm run check:spec-ready -- . <contract>     → красное = отказ
#                                                       (маркер «spec-ready»)
#   (в) эвристика Н-39 по тексту контракта: строка, где стаб
#       (s<N>|стаб|обманка) связан глаголом привязки
#       (умирает|ловится|краснеет|падает) с клеткой/входом/кейсом →
#       отказ ДОСЛОВНО «Н-39: привязка стаба в прозе, строка N»
#       (N — номер строки; порог отсекает отметку от предложения,
#       правило 8: совпадение внутри ЦИТАТЫ «…» „…" "…" `…` — отметка,
#       не предложение).
#
# Команды (а)/(б) — дословное расширение БЕЗАРГУМЕНТНЫХ npm-ключей
# («bash scripts/check_…sh . <contract>»). Снятие запечённых аргументов с
# ключа check:precision-gate — package.json/ci.yml (инвариант 15).
#
# Коды возврата:
#   0 — черновик прошёл, критика можно звать
#   1 — именованный отказ (маркер ноги в stderr; критик не зовётся)
#   2 — нечем проверить (NOT_IMPLEMENTED: …; fail-closed, критик не зовётся)

set -uo pipefail

# Гигиена Н-85: снять GIT_DIR и пр.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES \
      GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM

# Тест-швы
CONTRACT="${1:?использование: pre_critic.sh <отн-путь-контракта>}"

# ROOT резолвится по месту скрипта (Н-85).
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P 2>/dev/null)" \
  || { printf 'NOT_IMPLEMENTED: нет корня скрипта\n' >&2; exit 2; }

command -v git >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v bash >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: нет bash\n' >&2; exit 2; }

# Контракт существует и читается (отн-путь от ROOT)
[ -f "$ROOT/$CONTRACT" ] \
  || { printf 'NOT_IMPLEMENTED: контракт не найден: %s\n' "$CONTRACT" >&2; exit 2; }
[ -r "$ROOT/$CONTRACT" ] \
  || { printf 'NOT_IMPLEMENTED: контракт не читается: %s\n' "$CONTRACT" >&2; exit 2; }

refuse() { printf 'ОТКАЗ: %s\n' "$1" >&2; exit 1; }

# cd в ROOT — ноги (а)/(б) гейтов ожидают `.` == ROOT-пути (а не чужого cwd);
# прецедент stub-двери батареи 072.
cd "$ROOT" || { printf 'NOT_IMPLEMENTED: нет корня\n' >&2; exit 2; }

# ── (а) precision-гейт на ПЕРЕДАННОМ контракте (без запечённых аргументов) ──
# Гейт идёт ОТНОСИТЕЛЬНЫМ путём (bash scripts/check_…sh), чтобы `.` при
# вызове гейта резолвилось в cwd-окружения (== ROOT после cd); абсолютный
# путь оставил бы `.` в исходном cwd вызывающей стороны (батарея ставит
# `cd /` для изоляции), и контракт-путь был бы неверным.
if ! bash scripts/check_precision_gate.sh . "$CONTRACT" >/dev/null 2>&1; then
  refuse "precision-gate красен: $CONTRACT"
fi

# ── (б) spec-preflight на ПЕРЕДАННОМ контракте (без запечённых аргументов) ─
if ! bash scripts/check_spec_ready.sh . "$CONTRACT" >/dev/null 2>&1; then
  refuse "spec-ready красен: $CONTRACT"
fi

# ── (в) Н-39 — привязка стаба в прозе; порог (правило 8): цитата в
# кавычках — отметка, не предложение; вырезаем кавычные спаны до поиска.
#
# Словари токенов/глаголов — дословно из слова владельца (контракт 072 §Предмет):
#   стаб-токены:   s[0-9]+ | стаб | обманка
#   глаголы:       умирает | ловится | краснеет | падает
#   связки:        клетк | вход | кейс
#
# Все три словаря должны присутствовать в одной строке ВНЕ кавычек → отказ.
n=0
n39_pattern_stub='s[0-9]+|стаб|обманка'
n39_pattern_verb='умирает|ловится|краснеет|падает'
n39_pattern_link='клетк[а-яё]*|вход|кейс'
while IFS= read -r line || [ -n "$line" ]; do
  n=$((n + 1))
  # Порог (правило 8): цитата в кавычках — отметка, не предложение.
  scan="$(printf '%s\n' "$line" | sed -e 's/«[^»]*»//g' -e 's/„[^“]*“//g' -e 's/"[^"]*"//g' -e 's/`[^`]*`//g')"
  if printf '%s\n' "$scan" | grep -Eq "$n39_pattern_stub" \
     && printf '%s\n' "$scan" | grep -Eq "$n39_pattern_verb" \
     && printf '%s\n' "$scan" | grep -Eq "$n39_pattern_link"; then
    refuse "Н-39: привязка стаба в прозе, строка $n"
  fi
done < "$ROOT/$CONTRACT"

printf 'КРИТИК: дверь зелёная\n'
exit 0