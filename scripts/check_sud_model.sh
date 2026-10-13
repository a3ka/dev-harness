#!/usr/bin/env bash
# Дверь сверки модели судьи (контракт 099, Н-270, Решение 4/5; З-7/З-8).
#
# Зачем: Н-270 — спавн `_task` без явного `agent:` даёт судью на `task`-тире
# (рецидивы e15a080d/747258aa/2698c059 — три недействительных вердикта 098).
# Слово владельца 2026-10-12 ~18:35 UTC дословно: «спавн судейской роли (critic,
# adversary, reviewer, arbiter) без явного agent либо с моделью, не совпадающей
# с тиром роли в `config/agent_models.json`, — механический ОТКАЗ (до учёта
# результата); после спавна — сверка модели в трассе субагента с тиром роли;
# несовпадение — вердикт не материализуется (не коммитится в main), именованная
# причина». Три ноги этой двери:
#   --spawn <роль> [<модель>] [--root <кат>]   сверка СПАВНА (до исполнения):
#                                              модель ОБЯЗАТЕЛЬНА — её нет
#                                              значит «без явного agent»;
#   --frontmatter <роль> [--root <кат>]        статическая сверка модели
#                                              спавна: frontmatter
#                                              `.omp/agents/<роль>.md`
#                                              (строка `model: ["@<тир>"]`)
#                                              против тира роли из конфига;
#   --verdict <роль> --trace <tsv>             сверка ТРАССЫ ПОСЛЕ спавна
#   [--root <кат>]                             (грамматика — ЕДИНЫЙ источник
#                                              make_task --model-trace /
#                                              models_actual --tsv: строки
#                                              «роль TAB модель TAB
#                                              allowed|denied»); несовпадение —
#                                              вердикт не материализуется.
#
# Источник назначений — ЕДИНСТВЕННЫЙ `config/agent_models.json`
# (roles→tiers→models, @семейство резолвится; слово владельца 2026-09-12/26):
#   models:  <семейство> → полная строка модели («openai-codex/gpt-6-astra»);
#   tiers:   <тир> → {"model": "@<семейство>"};
#   roles:   <роль> → <тир>.
# Ожидаемая модель роли = models[семейство из tiers[roles[роль]].model].
# Сверка — ЛИТЕРАЛЬНОЕ равенство строк (норма 041): regex/glob из чужого
# значения не строится. Динамический фолбэк модели статике невидим — его
# ловит ТОЛЬКО трасса (--verdict, З-8), вторую конвенцию не заводим.
#
# Алфавиты (Демаркация 099):
#   роли-судьи — замкнутый алфавит {critic, adversary, reviewer, arbiter} (041);
#   значение модели — латиница/цифры/`-._/`, непустое; TAB/пробел вне алфавита
#   → fail-closed rc 2 (битый вход, не «не совпало»).
#
# Коды возврата:
#   0 — судья своей модели (спавн/frontmatter/честная трасса проходят);
#   1 — именованный отказ (спавн без явного agent / модель не тира роли /
#       frontmatter не тира роли / вердикт не материализуется);
#   2 — нечем проверять (нет jq, конфиг/файл/строка не читаются, битая
#       грамматика, роль/модель вне алфавита) — fail-closed: расхождение
#       источника назначений НЕ молчит.
#
# Потребители: клетки fixtures/zashchita_main_099/red_sud_model_*; материализация
# — scripts/check_staged.sh (нога --verdict для staged verdicts/<роль>/**,
# Решение 5). Перехват РЕАЛЬНОГО запроса спавна — хук tool_call('task')
# расширения .omp/extensions/spawn-guard.ts (граница арбитража 099: spawn_agent
# запроса судей не несёт); эта дверь — юнит сверки, не вторая конвенция.
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat >&2 <<USAGE
использование: check_sud_model.sh --spawn <роль> [<модель>] [--root <кат>]
           check_sud_model.sh --frontmatter <роль> [--root <кат>]
           check_sud_model.sh --verdict <роль> --trace <tsv> [--root <кат>]
USAGE
  exit 2
}

command -v jq >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет jq\n' >&2; exit 2; }

# Замкнутый алфавит судейских ролей (041; Н-270 называет ровно эти четыре).
sud_role_ok() {
  case "$1" in
    critic|adversary|reviewer|arbiter) return 0 ;;
    *) return 1 ;;
  esac
}

# Алфавит значения модели: латиница/цифры/-._/ , непустое (Демаркация 099).
# tr -Cd под LC_ALL=C отсекает всё вне ASCII-класса; TAB/пробел меняют строку.
sud_model_alphabet_ok() {
  local s="$1"
  [ -n "$s" ] || return 1
  [ "$s" = "$(printf '%s' "$s" | LC_ALL=C tr -Cd 'A-Za-z0-9._/-')" ]
}

mode=""
role=""
model=""
root=""
trace=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --spawn)       mode="spawn"; role="${2:-}"; shift 2 ;;
    --frontmatter) mode="frontmatter"; role="${2:-}"; shift 2 ;;
    --verdict)     mode="verdict"; role="${2:-}"; shift 2 ;;
    --trace)       trace="${2:-}"; shift 2 ;;
    --root)        root="${2:-}"; shift 2 ;;
    --help|-h)     usage ;;
    *)
      # Позиционная модель --spawn: ровно один токен после роли.
      if [ "$mode" = "spawn" ] && [ -z "$model" ] && [ -n "$1" ]; then
        model="$1"; shift
      else
        printf 'check_sud_model: неизвестный аргумент: %s\n' "$1" >&2; usage
      fi
      ;;
  esac
done

[ -n "$mode" ] || usage
[ -n "$role" ] || { printf 'ОТКАЗ: роль не передана\n' >&2; exit 2; }
sud_role_ok "$role" || {
  printf 'ОТКАЗ: роль вне алфавита судей: %s (замкнутый алфавит 041: critic, adversary, reviewer, arbiter)\n' "$role" >&2
  exit 2
}
[ -n "$root" ] || root="$SELF_DIR/.."

# Резолв тира роли и ожидаемой модели: roles→tiers→@семейство→models.
# Любый отказ чтения/структуры → fail-closed rc 2: источник назначений не молчит.
CFG="$root/config/agent_models.json"
if [ ! -f "$CFG" ]; then
  printf 'ОТКАЗ: конфиг назначений не читается: %s (fail-closed, Н-270)\n' "$CFG" >&2
  exit 2
fi
tier="$(jq -r --arg r "$role" '.roles[$r] // ""' "$CFG" 2>/dev/null)" || tier=""
[ -n "$tier" ] || {
  printf 'ОТКАЗ: тир роли не читается из %s: роль %s (fail-closed, Н-270)\n' "$CFG" "$role" >&2
  exit 2
}
fam="$(jq -r --arg t "$tier" '.tiers[$t].model // ""' "$CFG" 2>/dev/null)" || fam=""
case "$fam" in
  @*) fam="${fam#@}" ;;
  *)
    printf 'ОТКАЗ: тир %s роли %s не ссылается на семейство (@…) в %s (fail-closed, Н-270)\n' \
      "$tier" "$role" "$CFG" >&2
    exit 2
    ;;
esac
expected="$(jq -r --arg f "$fam" '.models[$f] // ""' "$CFG" 2>/dev/null)" || expected=""
[ -n "$expected" ] || {
  printf 'ОТКАЗ: семейство %s (тир %s, роль %s) не разрешается в модель в %s (fail-closed, Н-270)\n' \
    "$fam" "$tier" "$role" "$CFG" >&2
  exit 2
}

case "$mode" in
  spawn)
    # Модель ОБЯЗАТЕЛЬНА: её отсутствие = «спавн без явного agent» (Н-270:
    # без явного agent судья поднимается на дефолт-тире — механический отказ
    # ДО учёта результата).
    if [ -z "$model" ]; then
      printf 'ОТКАЗ: спавн судьи без явного agent: %s\n' "$role" >&2
      exit 1
    fi
    if ! sud_model_alphabet_ok "$model"; then
      printf 'ОТКАЗ: модель вне алфавита: %s (латиница/цифры/-._/, без TAB/пробела; fail-closed, Н-270)\n' "$model" >&2
      exit 2
    fi
    if [ "$model" != "$expected" ]; then
      printf 'ОТКАЗ: модель не тира роли: %s тир %s спавн %s\n' "$role" "$tier" "$model" >&2
      exit 1
    fi
    printf 'СУДЬЯ СВОЕЙ МОДЕЛИ: %s тир %s модель %s\n' "$role" "$tier" "$model"
    exit 0
    ;;
  frontmatter)
    # Статическая сверка модели спавна: frontmatter роли против источника
    # назначений. Файл/строка не читаются → fail-closed rc 2 (несовпадение
    # frontmatter и источника не молчит); динамический фолбэк — только трасса.
    FM="$root/.omp/agents/$role.md"
    if [ ! -f "$FM" ]; then
      printf 'ОТКАЗ: frontmatter роли не читается: %s (нет %s; fail-closed, Н-270)\n' "$role" "$FM" >&2
      exit 2
    fi
    fm_line="$(grep -E '^model: \["@[A-Za-z0-9._-]+"\]' "$FM" | head -1)"
    if [ -z "$fm_line" ]; then
      printf 'ОТКАЗ: frontmatter роли не читается: %s (в %s нет строки model: ["@<тир>"]; fail-closed, Н-270)\n' \
        "$role" "$FM" >&2
      exit 2
    fi
    fm_tier="$(printf '%s' "$fm_line" | sed 's/^model: \["@//; s/"\]$//')"
    if [ "$fm_tier" != "$tier" ]; then
      printf 'ОТКАЗ: frontmatter роли не тира роли: %s frontmatter @%s тир %s\n' "$role" "$fm_tier" "$tier" >&2
      exit 1
    fi
    printf 'СУДЬЯ СВОЕЙ МОДЕЛИ: frontmatter %s @%s = тир роли\n' "$role" "$fm_tier"
    exit 0
    ;;
  verdict)
    # Сверка трассы ПОСЛЕ спавна: строки «роль TAB модель TAB allowed|denied»
    # (единый источник make_task --model-trace / models_actual --tsv).
    # Трасса без строки роли / битая грамматика → rc 2 fail-closed
    # (= вердикт не материализуется); КАЖДАЯ строка роли обязана быть тира —
    # фолбэк-переход внутри сессии судьи наблюдаем и не материализуется.
    if [ -z "$trace" ] || [ ! -f "$trace" ]; then
      printf 'ОТКАЗ: трасса не читается: %s (fail-closed, Н-270 — вердикт не материализуется)\n' \
        "${trace:-не передана}" >&2
      exit 2
    fi
    role_lines="$(awk -F'\t' -v r="$role" '$1 == r { print $2 }' "$trace")"
    if [ -z "$role_lines" ]; then
      printf 'ОТКАЗ: трасса без строки роли: %s (fail-closed, Н-270 — вердикт не материализуется)\n' "$role" >&2
      exit 2
    fi
    bad_grammar=0
    while IFS= read -r l; do
      [ -n "$l" ] || continue
      n="$(printf '%s\n' "$l" | awk -F'\t' '{ print NF }')"
      verdict_flag="$(printf '%s\n' "$l" | awk -F'\t' '{ print $3 }')"
      if [ "$n" -ne 3 ] || [ -z "$(printf '%s\n' "$l" | awk -F'\t' '{ print $2 }')" ] \
         || { [ "$verdict_flag" != "allowed" ] && [ "$verdict_flag" != "denied" ]; }; then
        bad_grammar=1
      fi
    done < <(awk -F'\t' -v r="$role" '$1 == r' "$trace")
    if [ "$bad_grammar" -ne 0 ]; then
      printf 'ОТКАЗ: трасса битой грамматики для роли %s (роль TAB модель TAB allowed|denied; fail-closed, Н-270 — вердикт не материализуется)\n' \
        "$role" >&2
      exit 2
    fi
    while IFS= read -r m; do
      [ -n "$m" ] || continue
      if ! sud_model_alphabet_ok "$m"; then
        printf 'ОТКАЗ: модель вне алфавита: %s (трасса роли %s; fail-closed, Н-270 — вердикт не материализуется)\n' \
          "$m" "$role" >&2
        exit 2
      fi
      if [ "$m" != "$expected" ]; then
        printf 'ОТКАЗ: вердикт не материализуется: судья %s на модели %s, тир %s (Н-270)\n' \
          "$role" "$m" "$tier" >&2
        exit 1
      fi
    done <<< "$role_lines"
    printf 'СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт %s материализуется (трасса = тир %s)\n' "$role" "$tier"
    exit 0
    ;;
esac

# Недостижимо (mode разобран выше), но пустой fall-through не оставляем.
usage
