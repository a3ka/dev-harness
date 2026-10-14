#!/usr/bin/env bash
# ДВЕРЬ ПЕРЕЗАПУСКА КРИТИКА (контракт 072, v2.2 — адверсарий 072-r1 Б1).
# КОНТРАКТ 103 (Frontier И-2): флаг --repo <R> — контракт резолвится от корня
# ПРОЕКТА (cwd-независимо); нога (г) вооружается профильным реестром
# <workflowPaths.registry>/contracts.tsv в R. Без --repo — 072 дословно.
# ЕДИНСТВЕННЫЙ вход к спавну критика: критик зовётся только после rc 0
# этой двери; отказ (rc 1) = назад архитектору, критик не зовётся.
#
# Три ноги, порядок строгий (а)→(б)→(в):
#   (а) npm run check:precision-gate -- . <contract> → красное = отказ
#                                                       (маркер «precision-gate»)
#   (б) npm run check:spec-ready -- . <contract>     → красное = отказ
#                                                       (маркер «spec-ready»)
#   (в) эвристика Н-39 по тексту контракта: связка, где стаб
#       (s<N>|стаб|обманка) связан глаголом привязки
#       (умирает|ловится|краснеет|падает) с клеткой/входом/кейсом →
#       отказ ДОСЛОВНО «Н-39: привязка стаба в прозе, строка N»
#       (N — номер строки; порог отсекает отметку от предложения,
#       правило 8: совпадение внутри ЦИТАТЫ «…» „…" "…" `…` — отметка,
#       не предложение). Связка ловится и ОДНОЙ строкой, и РАЗНЕСЁННОЙ
#       переводом строки на соседнюю непустую строку (адверсарий 072-r1
#       Б1: перенос строки не меняет утверждения) — N тогда ПЕРВАЯ
#       строка связки.
#   (г) ФОРМА КОНТЕКСТ:/§Существующее (Решение 6 контракта 095, §13.3
#       слова владельца 2026-10-03). pre_critic проверяет ФОРМУ (наличие
#       обеих меток); критик — полноту содержимого. Без `КОНТЕКСТ:`-
#       строк или без секции `## Существующее` — именованный отказ ДО
#       критика. Существующие контракты до-095 правомерно несут эту
#       форму; контракты, написанные после, обязаны (это и есть
#       базовый формат контракта, §13.3).
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
#
# CLI (контракт 103, И-2): [--repo <R>] <отн-путь-контракта>. Путь контракта
# резолвится ТОЛЬКО от R (корень проекта), никогда от cwd; без --repo —
# поведение 072 дословно: путь от ROOT = место скрипта (харнес сам себе
# проект). Вердикт (rc, первая строка stderr) от cwd не зависит.
REPO_ARG=""
CONTRACT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo)
      REPO_ARG="${2:?использование: pre_critic.sh [--repo R] <отн-путь-контракта>}"
      shift 2
      ;;
    *)
      [ -z "$CONTRACT" ] || { printf 'использование: pre_critic.sh [--repo R] <отн-путь-контракта>\n' >&2; exit 1; }
      CONTRACT="$1"
      shift
      ;;
  esac
done
[ -n "$CONTRACT" ] || { printf 'использование: pre_critic.sh [--repo R] <отн-путь-контракта>\n' >&2; exit 1; }

# ROOT резолвится по месту скрипта (Н-85).
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P 2>/dev/null)" \
  || { printf 'NOT_IMPLEMENTED: нет корня скрипта\n' >&2; exit 2; }

# База контракта (И-2): --repo R → R; без флага → ROOT (072 дословно).
if [ -n "$REPO_ARG" ]; then
  BASE="$(cd "$REPO_ARG" 2>/dev/null && pwd -P 2>/dev/null)" \
    || { printf 'NOT_IMPLEMENTED: нет корня проекта: %s\n' "$REPO_ARG" >&2; exit 2; }
else
  BASE="$ROOT"
fi

command -v git >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v bash >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: нет bash\n' >&2; exit 2; }

# Контракт существует и читается (отн-путь от базы: ROOT либо R)
[ -f "$BASE/$CONTRACT" ] \
  || { printf 'NOT_IMPLEMENTED: контракт не найден: %s\n' "$CONTRACT" >&2; exit 2; }
[ -r "$BASE/$CONTRACT" ] \
  || { printf 'NOT_IMPLEMENTED: контракт не читается: %s\n' "$CONTRACT" >&2; exit 2; }
CONTRACT_FILE="$BASE/$CONTRACT"

refuse() { printf 'ОТКАЗ: %s\n' "$1" >&2; exit 1; }

# ── (а) precision-гейт и (б) spec-preflight на ПЕРЕДАННОМ контракте ──
# Без --repo — 072 дословно: cd в ROOT, гейты идут с `.` == ROOT.
# С --repo R (Frontier И-2) гейты зовутся с R вместо `.`; вооружение —
# правило А-384 (нога вооружается ФАЙЛОМ в проверяемом дереве, не
# предположением): гейт-механизм обязан быть в дереве проекта
# (scripts/check_precision_gate.sh в R) — чужое дерево без него npm-гейтами
# харнеса не судится (паритет CI харнеса к чужому репо неприменим — «сверять
# не с чем»), контракт там судят ноги (в) Н-39 и (г) формы.
GATE_ROOT=""
if [ -n "$REPO_ARG" ]; then
  [ -f "$BASE/scripts/check_precision_gate.sh" ] && GATE_ROOT="$BASE"
else
  GATE_ROOT="$ROOT"
fi
if [ -n "$GATE_ROOT" ]; then
  # cd в ROOT — ноги (а)/(б) гейтов ожидают `.` == ROOT-пути (а не чужого cwd);
  # прецедент stub-двери батареи 072. Гейт идёт ОТНОСИТЕЛЬНЫМ путём
  # (bash scripts/check_…sh), чтобы `.` при вызове гейта резолвилось в
  # cwd-окружения (== ROOT после cd); с --repo корень гейта — сам R.
  cd "$ROOT" || { printf 'NOT_IMPLEMENTED: нет корня\n' >&2; exit 2; }
  if ! bash scripts/check_precision_gate.sh "$GATE_ROOT" "$CONTRACT" >/dev/null 2>&1; then
    refuse "precision-gate красен: $CONTRACT"
  fi
  if ! bash scripts/check_spec_ready.sh "$GATE_ROOT" "$CONTRACT" >/dev/null 2>&1; then
    refuse "spec-ready красен: $CONTRACT"
  fi
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
# Б1 (адверсарий 072-r1): связка «sN + глагол + клетка/вход/кейс»,
# РАЗНЕСЁННАЯ переводом строки на соседнюю непустую строку, — то же
# утверждение, что и однострочная форма; перенос строки не меняет смысла.
# Проверяем КАЖДУЮ строку (как раньше) И КАЖДУЮ пару физически соседних
# непустых строк (n-1,n) — склейка через пробел; номер отказа — ПЕРВАЯ
# строка связки (n-1 для пары). Однострочная ЗАКАВЫЧЕННАЯ цитата
# остаётся зелёной — кавычки вырезаются ДО склейки, на каждой строке.
n=0
n39_pattern_stub='s[0-9]+|стаб|обманка'
n39_pattern_verb='умирает|ловится|краснеет|падает'
n39_pattern_link='клетк[а-яё]*|вход|кейс'
n39_match() { # $1 = текст (кавычки уже вырезаны)
  printf '%s\n' "$1" | LC_ALL=C grep -Eq "$n39_pattern_stub" \
    && printf '%s\n' "$1" | LC_ALL=C grep -Eq "$n39_pattern_verb" \
    && printf '%s\n' "$1" | LC_ALL=C grep -Eq "$n39_pattern_link"
}
prev_scan=""
prev_n=0
while IFS= read -r line || [ -n "$line" ]; do
  n=$((n + 1))
  # Порог (правило 8): цитата в кавычках — отметка, не предложение.
  scan="$(printf '%s\n' "$line" | sed -e 's/«[^»]*»//g' -e 's/„[^“]*“//g' -e 's/"[^"]*"//g' -e 's/`[^`]*`//g')"
  if n39_match "$scan"; then
    refuse "Н-39: привязка стаба в прозе, строка $n"
  fi
  if [ -n "$scan" ] && [ -n "$prev_scan" ] && [ "$prev_n" -eq $((n - 1)) ] \
     && n39_match "$prev_scan $scan"; then
    refuse "Н-39: привязка стаба в прозе, строка $prev_n"
  fi
  prev_scan="$scan"; prev_n="$n"
done < "$CONTRACT_FILE"

# ── (г) ФОРМА КОНТЕКСТ:/§Существующее (Решение 6 контракта 095, §13.3) ──
# Скоуп: правило А-384 — нога вооружена ТОЛЬКО в живом дереве/клоне харнеса
# (где есть реестр контрактов); toy-миры 072/verify_antiplacebo его
# не несут — там судится СВОЯ механика ног (а)-(в), нога (г) не
# применяется (приёмка 095 п.7: нога формы не ослабляет дверь 072).
# Контракт 103 (Frontier И-2): на проектном --repo нога вооружается
# ПРОФИЛЬНЫМ реестром — <workflowPaths.registry>/contracts.tsv в R
# (эффективное значение: репо-слой, иначе defaults слоя проекта), не
# корневым реестром харнеса; А-384 закрывается тем же движением.
# Контракт без строк `КОНТЕКСТ:` ИЛИ без секции `## Существующее` —
# именованный отказ ДО критика (И-13 инварианта 095; форма проверяется
# здесь, полнота содержимого — критиком). grep -qE '^КОНТЕКСТ:' ищет
# префикс строки; маркер `## Существующее` — точный заголовок секции
# (любой уровень вложенности, без хвостового `:`). Локаль C для
# стабильности диапазонов кириллицы.
_arm_reg_dir=""
if [ -n "$REPO_ARG" ]; then
  if [ -f "$BASE/harness.project.json" ]; then
    command -v jq >/dev/null 2>&1 \
      || { printf 'NOT_IMPLEMENTED: нет jq\n' >&2; exit 2; }
    _arm_reg_dir="$(jq -r '.workflowPaths.registry // empty' "$BASE/harness.project.json" 2>/dev/null)"
    if [ -z "$_arm_reg_dir" ]; then
      _pl="$(jq -r '.projectLayer.profilePath // empty' "$BASE/harness.project.json" 2>/dev/null)"
      [ -n "$_pl" ] && [ -f "$BASE/$_pl" ] \
        && _arm_reg_dir="$(jq -r '.defaults.workflowPaths.registry // empty' "$BASE/$_pl" 2>/dev/null)"
      unset _pl
    fi
  fi
  [ -n "$_arm_reg_dir" ] || _arm_reg_dir="registry"
else
  _arm_reg_dir="registry"
fi
if [ -r "$BASE/$_arm_reg_dir/contracts.tsv" ]; then
if ! LC_ALL=C grep -qE '^КОНТЕКСТ:' "$CONTRACT_FILE"; then
  refuse "форма: контракт без строк КОНТЕКСТ:"
fi
if ! LC_ALL=C grep -qE '^##[[:space:]]+Существующее([[:space:]]*|[[:space:]]+.*)$' "$CONTRACT_FILE"; then
  refuse "форма: контракт без секции ## Существующее"
fi
fi
unset _arm_reg_dir

printf 'КРИТИК: дверь зелёная\n'
exit 0