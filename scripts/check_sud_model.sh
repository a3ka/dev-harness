#!/usr/bin/env bash
# Дверь сверки модели судьи (контракт 104, Решение 3; перенос 099 + привязка).
#
# Зачем: Н-270 — спавн `_task` без явного `agent:` даёт судью на `task`-тире
# (рецидивы e15a080d/747258aa/2698c059 — три недействительных вердикта 098).
# Слово владельца 2026-10-12 ~18:35 UTC дословно: «спавн судейской роли (critic,
# adversary, reviewer, arbiter) без явного agent либо с моделью, не совпадающей
# с тиром роли в `config/agent_models.json`, — механический ОТКАЗ (до учёта
# результата); после спавна — сверка модели в трассе субагента с тиром роли;
# несовпадение — вердикт не материализуется (не коммитится в main), именованная
# причина». Контракт 104 добавляет ПРИВЯЗКУ (Решение 2/3): трасса несёт
# session-id судьи и sha объекта суда — чужая трасса или трасса о чужом
# объекте вердикт НЕ материализует. Три ноги этой двери:
#   --spawn <роль> [<модель>] [--root <кат>]   сверка СПАВНА (до исполнения):
#                                              модель ОБЯЗАТЕЛЬНА — её нет
#                                              значит «без явного agent»
#                                              (из 099 без изменений);
#   --frontmatter <роль> [--root <кат>]        статическая сверка модели
#                                              спавна: frontmatter
#                                              `.omp/agents/<роль>.md`
#                                              (строка `model: ["@<тир>"]`)
#                                              против тира роли из конфига
#                                              (из 099 без изменений);
#   --verdict <роль> --trace <tsv> --object <sha> --session <id> [--root <кат>]
#                                              сверка ТРАССЫ ПОСЛЕ спавна:
#                                              строки «роль TAB модель TAB
#                                              allowed|denied TAB session TAB
#                                              object» (грамматика — ЕДИНЫЙ
#                                              источник `models_actual.sh
#                                              --tsv --bind`, Решение 2);
#                                              --object/--session ОБЯЗАТЕЛЬНЫ.
#
# Источник назначений — ЕДИНСТВЕННЫЙ резолвер scripts/roles.ts
# (контракт 198, Р2): `node scripts/roles.ts --resolve-model <роль> --root <кат>`
# возвращает одной TSV-строкой «тир TAB модель TAB фолбек|- TAB autoFallback».
# Сам реестр — `config/agent_models.json` (roles→tiers→models, @семейство
# резолвится; слово владельца 2026-09-12/26):
#   models:  <семейство> → полная строка модели («openai-codex/gpt-6-astra»);
#   tiers:   <тир> → {"model": "@<семейство>", "fallback": "@<семейство>"|null};
#   roles:   <роль> → <тир>.
# Ожидаемая модель роли и объявленный фолбэк тира приходят от резолвера
# (null — фолбэка нет). Override модели закрыт: «ожидаемой модели»-флага нет,
# источник ожиданий — только реестр через резолвер (Решение 3).
# Сверка — ЛИТЕРАЛЬНОЕ равенство строк (норма 041): regex/glob из чужого
# значения не строится. Контракт 173 уточняет СРАВНЕНИЕ ИМЁН: модель с
# префиксом провайдера и та же модель без префикса — одна назначенная
# модель (`anthropic/claude-opus-5-5` ≡ `claude-opus-5-5`); обе строки с
# префиксом — равны только побайтно (чужой провайдер — другая модель), обе
# bare — тоже побайтно. Выводимые фактические ID не меняются: нормализация
# живёт только в сравнении.
#
# Алфавиты (Демаркация 104):
#   роли-судьи — замкнутый алфавит {critic, adversary, reviewer, arbiter} (041);
#   значение модели — латиница/цифры/`-._/`, непустое; TAB/пробел вне алфавита
#   → fail-closed rc 2 (битый вход, не «не совпало»);
#   session-id — [A-Za-z0-9._-]+; object — ровно 40 hex.
#
# Коды возврата:
#   0 — судья своей модели (спавн/frontmatter/честная трасса проходят);
#   1 — именованный отказ (спавн без явного agent / модель не тира роли /
#       frontmatter не тира роли / трасса без строки роли / чужая трасса /
#       трасса не об объекте суда / вердикт не материализуется / фолбэк
#       вне списка тира);
#   2 — нечем проверять (нет node, резолвер отказал, конфиг/файл/строка не
#       читаются, битая грамматика, роль/модель вне алфавита, трасса без
#       привязки, --object/--session не переданы) — fail-closed: расхождение
#       источника назначений НЕ молчит.
#
# Потребители: клетки fixtures/zashchita_main_104/red_sud_model_*; писатель
# scripts/judge_gate.sh --verdict-row --sud (Решение 4). Перехват РЕАЛЬНОГО
# запроса спавна — хук tool_call('task') расширения .omp/extensions/
# spawn-guard.ts (граница арбитража 099: spawn_agent запроса судей не несёт);
# эта дверь — юнит сверки, не вторая конвенция.
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat >&2 <<USAGE
использование: check_sud_model.sh --spawn <роль> [<модель>] [--root <кат>]
           check_sud_model.sh --frontmatter <роль> [--root <кат>]
           check_sud_model.sh --verdict <роль> --trace <tsv> --object <sha> --session <id> [--root <кат>]
USAGE
  exit 2
}

command -v node >/dev/null 2>&1 || { printf 'ОТКАЗ: нет node — резолвер назначений недоступен (fail-closed, Н-270)\n' >&2; exit 2; }

# Замкнутый алфавит судейских ролей (041; Н-270 называет ровно эти четыре).
sud_role_ok() {
  case "$1" in
    critic|adversary|reviewer|arbiter) return 0 ;;
    *) return 1 ;;
  esac
}

# Алфавит значения модели: латиница/цифры/-._/ , непустое (Демаркация 104).
# tr -Cd под LC_ALL=C отсекает всё вне ASCII-класса; TAB/пробел меняют строку.
sud_model_alphabet_ok() {
  local s="$1"
  [ -n "$s" ] || return 1
  [ "$s" = "$(printf '%s' "$s" | LC_ALL=C tr -Cd 'A-Za-z0-9._/-')" ]
}

# Сверка ИМЕНИ модели (контракт 173): факт и ожидание — одна назначенная
# модель, если это одна и та же строка или одна строка с префиксом
# провайдера, а другая — тот же ID без префикса. Обе с префиксом — только
# побайтно (чужой провайдер ≠ назначенный), обе bare — только побайтно.
# Сравнение литеральное: regex/glob из значения модели не строится, префикс
# отбрасывается ТОЛЬКО для сравнения (выводимые ID не меняются).
sud_same_model() {
  local fact="$1" want="$2"
  [ "$fact" = "$want" ] && return 0
  case "$fact" in
    */*)
      case "$want" in
        */*) return 1 ;;
        *) [ "${fact#*/}" = "$want" ] ;;
      esac
      ;;
    *)
      case "$want" in
        */*) [ "$fact" = "${want#*/}" ] ;;
        *) return 1 ;;
      esac
      ;;
  esac
}

# Алфавит session-id трассы: [A-Za-z0-9._-]+, непустое (Решение 2, 041).
sud_session_alphabet_ok() {
  local s="$1"
  [ -n "$s" ] || return 1
  [ "$s" = "$(printf '%s' "$s" | LC_ALL=C tr -Cd 'A-Za-z0-9._-')" ]
}

# Объект суда — ровно 40 hex (Демаркация 104).
sud_object_ok() {
  case "$1" in ''|*[!0-9a-f]*) return 1 ;; esac
  [ "${#1}" -eq 40 ]
}

mode=""
role=""
model=""
root=""
trace=""
object=""
session=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --spawn)       mode="spawn"; role="${2:-}"; shift 2 ;;
    --frontmatter) mode="frontmatter"; role="${2:-}"; shift 2 ;;
    --verdict)     mode="verdict"; role="${2:-}"; shift 2 ;;
    --trace)       trace="${2:-}"; shift 2 ;;
    --object)      object="${2:-}"; shift 2 ;;
    --session)     session="${2:-}"; shift 2 ;;
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

# Ожидание роли — от ЕДИНСТВЕННОГО резолвера назначений (scripts/roles.ts,
# контракт 198, Р2): цепочка ролей→тиров→моделей разбирается ТАМ, второй
# разбор у двери запрещён. Ответ — одна TSV-строка
# «тир TAB модель TAB фолбек|- TAB autoFallback»; парсинг — cut.
# Любой отказ резолвера (роль/тир/семейство/пустая модель/нет реестра/битое
# тело) → fail-closed rc 2: источник назначений не молчит (Н-270).
tsv="$(node "$SELF_DIR/roles.ts" --resolve-model "$role" --root "$root")"
tsv_rc=$?
if [ "$tsv_rc" -ne 0 ] || [ -z "$tsv" ]; then
  printf 'ОТКАЗ: резолвер назначений отказал для роли %s (fail-closed, Н-270)\n' "$role" >&2
  exit 2
fi
tier="$(printf '%s' "$tsv" | cut -f1)"
expected="$(printf '%s' "$tsv" | cut -f2)"
fbexpected="$(printf '%s' "$tsv" | cut -f3)"
[ -n "$tier" ] && [ -n "$expected" ] || {
  printf 'ОТКАЗ: резолвер назначений вернул неразборчивый ответ для роли %s (fail-closed, Н-270)\n' "$role" >&2
  exit 2
}
# Фолбэк не объявлен — «-» в ответе резолвера; denied-фолбэк не принимается
# вовсе (список фолбэка объявлен владельцем в реестре, второго списка нет).
[ "$fbexpected" = "-" ] && fbexpected=""

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
    if ! sud_same_model "$model" "$expected"; then
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
    # Сверка трассы ПОСЛЕ спавна с ПРИВЯЗКОЙ (Решение 3): строки роли —
    # «роль TAB модель TAB allowed|denied TAB session TAB object» (единый
    # источник models_actual.sh --tsv --bind). --object/--session ОБЯЗАТЕЛЬНЫ;
    # для КАЖДОЙ строки роли (литеральные сравнения, 041): чужая сессия,
    # чужой объект, модель не тира, denied не на объявленном фолбэке —
    # вердикт не материализуется (rc 1, именованная причина).
    if [ -z "$object" ] || [ -z "$session" ]; then
      printf 'ОТКАЗ: привязка обязательна: --object <sha> --session <id> (без них вердикт не материализуется)\n' >&2
      usage
    fi
    if ! sud_object_ok "$object"; then
      printf 'ОТКАЗ: объект суда не 40 hex: %s (fail-closed, Н-270)\n' "$object" >&2
      exit 2
    fi
    if ! sud_session_alphabet_ok "$session"; then
      printf 'ОТКАЗ: session-id вне алфавита: %s ([A-Za-z0-9._-]; fail-closed, Н-270)\n' "$session" >&2
      exit 2
    fi
    if [ -z "$trace" ] || [ ! -f "$trace" ]; then
      printf 'ОТКАЗ: трасса не читается: %s (fail-closed, Н-270 — вердикт не материализуется)\n' \
        "${trace:-не передана}" >&2
      exit 2
    fi
    role_lines="$(awk -F'\t' -v r="$role" '$1 == r' "$trace")"
    if [ -z "$role_lines" ]; then
      printf 'ОТКАЗ: трасса без строки роли: %s\n' "$role" >&2
      exit 1
    fi
    # Грамматика строк роли (до сверки значений): ровно 5 полей, модель,
    # флаг, session, object непусты — иначе fail-closed rc 2 (битый вход,
    # не «не совпало»). Трасса 095 (3 поля) — тот же отказ: нечем привязать.
    bad="$(awk -F'\t' -v r="$role" \
      '$1 == r && (NF != 5 || $2 == "" || $3 == "" || $4 == "" || $5 == "" \
                   || ($3 != "allowed" && $3 != "denied"))' "$trace")"
    if [ -n "$bad" ]; then
      printf 'ОТКАЗ: трасса без привязки (нужно 5 полей: роль TAB модель TAB allowed|denied TAB session TAB object)\n' >&2
      exit 2
    fi
    while IFS=$'\t' read -r r m fb s o; do
      [ -n "$r" ] || continue
      if ! sud_model_alphabet_ok "$m"; then
        printf 'ОТКАЗ: модель вне алфавита: %s (трасса роли %s; fail-closed, Н-270)\n' \
          "$m" "$role" >&2
        exit 2
      fi
      if ! sud_session_alphabet_ok "$s"; then
        printf 'ОТКАЗ: session-id вне алфавита: %s (трасса роли %s; fail-closed, Н-270)\n' \
          "$s" "$role" >&2
        exit 2
      fi
      if [ "$o" != "-" ] && ! sud_object_ok "$o"; then
        printf 'ОТКАЗ: объект трассы не 40 hex и не «-»: %s (трасса роли %s; fail-closed, Н-270)\n' \
          "$o" "$role" >&2
        exit 2
      fi
    done <<< "$role_lines"
    # Сверка значений каждой строки роли (литеральные сравнения, 041):
    # сессия → объект → модель/фолбэк.
    while IFS=$'\t' read -r r m fb s o; do
      [ -n "$r" ] || continue
      if [ "$s" != "$session" ]; then
        printf 'ОТКАЗ: чужая трасса: сессия %s, суд %s\n' "$s" "$session" >&2
        exit 1
      fi
      if [ "$o" != "$object" ]; then
        printf 'ОТКАЗ: трасса не об объекте суда: %s, суд %s\n' "$o" "$object" >&2
        exit 1
      fi
      case "$fb" in
        allowed)
          if ! sud_same_model "$m" "$expected"; then
            printf 'ОТКАЗ: вердикт не материализуется: судья %s на модели %s, тир %s (Н-270)\n' \
              "$role" "$m" "$tier" >&2
            exit 1
          fi
          ;;
        denied)
          # Фолбэк — только из объявленного владельцем списка tiers.<тир>.fallback
          # (Решение 3): фолбэк не объявлен или модель вне списка — отказ.
          if [ -z "$fbexpected" ] || ! sud_same_model "$m" "$fbexpected"; then
            printf 'ОТКАЗ: фолбэк вне списка тира: %s на %s, тир %s (Н-270)\n' \
              "$role" "$m" "$tier" >&2
            exit 1
          fi
          ;;
      esac
    done <<< "$role_lines"
    printf 'СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт %s материализуется\n' "$role"
    exit 0
    ;;
esac

# Недостижимо (mode разобран выше), но пустой fall-through не оставляем.
usage
