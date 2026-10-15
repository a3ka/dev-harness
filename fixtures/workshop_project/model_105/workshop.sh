#!/usr/bin/env bash
# model_105/workshop.sh — ЧЕСТНАЯ МОДЕЛЬ лаунчера по ТЕКСТУ контракта 105 (не по
# каркасу workshop; класс А-418): реализует ТОЛЬКО предмет 105 — передачу политики
# установки в сессию проекта — с тем же интерфейсом вызова, что у workshop
# (`[--probe] [--models <файл>] <репо> [хвост omp]`, $HERE = каталог файла,
# PROFILE=dev, exec omp по PATH). Всё, что вне предмета (резолвер профиля,
# пин, метеринг, лок, промпт), — заглушено литералами.
#
# Раннер `fixtures/_krasnye_105.sh --model` подставляет этот файл субъектом:
# на честной модели все 5 клеток зелёные (диффпроба стаб-пака — тот же файл
# БЕЗ ручки M105_MUTANT честен на всех входах).
#
# МУТАНТЫ (стаб-пак battery_stubs_105.sh; привязка стаба к входу — Н-39, здесь
# в коде; каждый красен РОВНО на клетке, где его дефект наблюдаем, и честен на
# остальных четырёх):
#   M105_MUTANT=project_ext   — список расширений берётся из ПРОЕКТА
#                               ($PROJECT/.omp/extensions), не из установки
#                               → красен на И-1 (evil.ts в argv, счёт ≠ N).
#   M105_MUTANT=overlay_first — оверлей --models стоит в argv РАНЬШЕ политики
#                               → красен на И-2 (политика перекрывает оверлей).
#   M105_MUTANT=agents_user   — роли кладутся в $HOME/.omp/agent/agents (так
#                               делает workshop ДО 105) → красен на И-3.
#   M105_MUTANT=late_refuse   — запретный флаг отвергается ПОСЛЕ `omp --version`
#                               → красен на И-4 (счётчик вызовов стаба = 1).
#   M105_MUTANT=pass_through  — запретный флаг прокидывается в omp хвостом
#                               → красен на И-4 (rc 0, флаг в argv).
#   M105_MUTANT=probe_silent  — проба молчит строками EXT: (живой argv честен)
#                               → красен на И-5 (проба не доказывает exec, А-918).
#   M105_MUTANT=probe_js      — проба печатает EXT: и для *.js (второе вычисление
#                               списка только для вывода) → красен на И-5
#                               (строки пробы ≠ argv живого режима).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE="dev"
MUT="${M105_MUTANT:-}"
die() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }

PROBE=0; PROJECT=""; MODELS=""; LATE_FLAG=""
while [ $# -gt 0 ]; do
  case "$1" in
    --probe)  PROBE=1 ;;
    --models) MODELS="${2:-}"; [ $# -ge 2 ] && shift ;;
    # И-4: флаги, затирающие политику расширений установки, — именованный отказ
    # той же формы, что `--approval-mode` (workshop:484): ДО любого вызова omp.
    --no-extensions|--extension|--extension=*|-e|--hook|--hook=*)
      case "$MUT" in
        pass_through) break ;;
        late_refuse)  LATE_FLAG="$1"; break ;;
      esac
      die "флаг $1 затирает политику расширений установки. Расширения и конфиг сессии проекта задаёт установка харнеса (контракт 105), и командная строка их не отменяет" ;;
    -*) break ;;
    *)  [ -z "$PROJECT" ] && PROJECT="$1" || break ;;
  esac
  shift
done
[ -n "$PROJECT" ] || die "модель 105: нужен каталог проекта"
[ -d "$PROJECT" ] || die "каталога проекта нет: $PROJECT"
PROJECT="$(cd "$PROJECT" && pwd)"

# Сессионный HOME проекта (вне дерева; формула модели, не workshop).
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/model105/$(basename "$PROJECT")"
export HOME="$STATE/home"
mkdir -p "$HOME"

# ── И-1: расширения УСТАНОВКИ — $HERE/.omp/extensions/*.ts, по одному -e ────
EXT_SRC="$HERE/.omp/extensions"
[ "$MUT" = project_ext ] && EXT_SRC="$PROJECT/.omp/extensions"
EXT_LIST=()
for f in "$EXT_SRC"/*.ts; do
  [ -f "$f" ] || continue
  EXT_LIST+=("$f")
done
EXT_ARGS=()
for f in "${EXT_LIST[@]}"; do EXT_ARGS+=(-e "$f"); done

# ── И-2: политика установки — $HERE/.omp/config.yml оверлеем, РАНЬШЕ --models ─
POLICY_CFG="$HERE/.omp/config.yml"
[ -f "$POLICY_CFG" ] || die "нет политики установки: $POLICY_CFG"
OVERLAY=()
if [ -n "$MODELS" ]; then
  [ -f "$MODELS" ] || [ -f "$HERE/$MODELS" ] || die "оверлея моделей нет: $MODELS"
  [ -f "$MODELS" ] || MODELS="$HERE/$MODELS"
  mkdir -p "$STATE/zone"
  cp "$MODELS" "$STATE/zone/models-overlay.yml"
  OVERLAY=(--config "$STATE/zone/models-overlay.yml")
fi
POLICY_ARGS=(--config "$POLICY_CFG" "${EXT_ARGS[@]}")

# ── И-3: роли — в каталог агента ПРОФИЛЯ, который omp резолвит под --profile ─
AGENTS="$HOME/.omp/profiles/$PROFILE/agent/agents"
[ "$MUT" = agents_user ] && AGENTS="$HOME/.omp/agent/agents"
mkdir -p "$AGENTS"
for r in "$HERE"/roles/*.md; do
  [ -f "$r" ] || continue
  cp "$r" "$AGENTS/$(basename "$r")"
done

# ── И-5: строки политики — ОДИН код для пробы и живого режима ───────────────
print_policy() {
  if [ "$MUT" = probe_js ] && [ "$PROBE" = 1 ]; then
    for f in "$EXT_SRC"/*.ts "$EXT_SRC"/*.js; do [ -f "$f" ] && printf 'EXT: %s\n' "$f"; done
  elif [ "$MUT" = probe_silent ] && [ "$PROBE" = 1 ]; then
    :
  else
    for f in "${EXT_LIST[@]}"; do printf 'EXT: %s\n' "$f"; done
  fi
  printf 'CONFIG: %s\n' "$POLICY_CFG"
  printf 'AGENTS: %s\n' "$AGENTS"
}
print_policy

if [ "$PROBE" = 1 ]; then
  printf 'workshop PROBE OK: %s\n' "$PROJECT"
  exit 0
fi

# Мутант late_refuse: отказ есть, но ПОСЛЕ первого вызова omp (сверка версии).
if [ -n "$LATE_FLAG" ]; then
  omp --version >/dev/null 2>&1 || true
  die "флаг $LATE_FLAG затирает политику расширений установки (поздний отказ — мутант)"
fi

PROMPT_FILE="$HOME/session-prompt-model105.md"
printf '# модель 105\n' > "$PROMPT_FILE"
LIVE_MODEL="model105/literal"
TOOLS="read,bash"
if [ "$MUT" = overlay_first ]; then
  SESSION_ARGS=(--profile "$PROFILE" --model "$LIVE_MODEL" "${OVERLAY[@]}" "${POLICY_ARGS[@]}")
else
  SESSION_ARGS=(--profile "$PROFILE" --model "$LIVE_MODEL" "${POLICY_ARGS[@]}" "${OVERLAY[@]}")
fi
cd "$PROJECT"
exec omp "${SESSION_ARGS[@]}" --append-system-prompt "$PROMPT_FILE" --tools "$TOOLS" "$@"
