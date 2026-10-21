#!/usr/bin/env bash
# ЧЕСТНАЯ МОДЕЛЬ субъекта scripts/connect_project.sh (контракт 125, зона architect).
# ОДНА команда: чужой репозиторий (URL https://github.com/<владелец>/<имя>[.git] или путь
# к git-клону) → клон, готовый к сессии проекта → exec <установка>/workshop --yolo <корень>
# (тот же вход, что у основной сессии: orch-loop запускает `workshop --yolo`).
# Харнессовое в дереве проекта — ТОЛЬКО под .harness/ и профиль harness.project.json
# (единственный корневой файл: его читают инструменты харнеса); в корень — ничего больше.
# Секреты: значения не печатаются; .harness/.env — только ключи списка bootstrap_env
# лаунчера, режим 600, исключён локально (.git/info/exclude) — в индекс не попадает;
# уже отслеживаемый git проекта (в индексе) .harness/.env — отказ env-v-indekse до записи
# и до сессии; значение дома секретов в ЛЮБОМ файле, который git может проиндексировать
# (отслеживаемый либо неигнорируемый, под любым именем), — отказ sekret-v-dereve до сессии,
# на КАЖДОМ запуске (первом и повторном).
# Повторный запуск досоздаёт ТОЛЬКО отсутствующее; существующее не перезаписывается.
set -u
HERE=${CONNECT_HERE:-$(cd "$(dirname "$0")/.." && pwd)}
die() { printf 'connect ОТКАЗ: %s\n' "$*" >&2; exit 1; }
[ $# -eq 1 ] || { printf 'connect ОТКАЗ: ровно один вход — URL или путь\n' >&2; exit 2; }
IN=$1
case "$IN" in
  https://github.com/*/*)
    printf '%s' "$IN" | grep -Eqx 'https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+' || die "URL вне грамматики: $IN"
    NAME=${IN##*/}; NAME=${NAME%.git}
    ROOT="${HARNESS_PROJECTS_DIR:-$HOME/projects}/$NAME" ;;
  *)
    [ -d "$IN/.git" ] || die "вход не URL и не git-клон: $IN"
    ROOT=$(cd "$IN" && pwd); NAME=${ROOT##*/} ;;
esac
# projectId — имя репозитория в НИЖНЕМ регистре; символ вне [a-z0-9_-] → «-»; класс лаунчера 055
PID=$(printf '%s' "$NAME" | tr 'A-Z' 'a-z' | tr -c 'a-z0-9_-' '-')
printf '%s' "$PID" | grep -Eqx '[a-z0-9][a-z0-9_-]*' || die "projectid-vne-klassa: имя «$NAME» не даёт projectId класса ^[a-z0-9][a-z0-9_-]*\$"
case "$IN" in
  https://*)
    if [ ! -d "$ROOT/.git" ]; then
      mkdir -p "$(dirname "$ROOT")"
      git -c credential.helper= -c 'credential.helper=!gh auth git-credential' clone -q "$IN" "$ROOT" \
        || die "клон не удался: $IN"
    fi ;;
esac
cd "$ROOT" || die "нет корня: $ROOT"
git ls-files --error-unmatch -- .harness/.env >/dev/null 2>&1 \
  && die "env-v-indekse: .harness/.env отслеживается git проекта — секреты не пишутся; снять с учёта: git rm --cached .harness/.env"
ORIGIN=$(git remote get-url origin 2>/dev/null || printf '%s' "$ROOT")
mkdir -p .harness/contracts .harness/verdicts .harness/registry .harness/fixtures
# .harness/.env из дома секретов (вне дерева проекта): ключи списка bootstrap_env, значения не печатаются
SECRETS="$HOME/.config/dev-harness/secrets.env"
if [ ! -f .harness/.env ] && [ ! -f .env ]; then
  [ -f "$SECRETS" ] || die "нет дома секретов: $SECRETS"
  ( umask 077; grep -E '^(ZAI_API_KEY|MINIMAX_API_KEY|METERING_PROXY_URL|METERING_PROXY_TOKEN)=' "$SECRETS" > .harness/.env || true )
fi
grep -qxF '.harness/.env' .git/info/exclude 2>/dev/null || printf '.harness/.env\n' >> .git/info/exclude
# пин omp — версия установленного omp; наследие config/harness_pin.json — второй пин не ставится
if [ ! -f .harness/harness_pin.json ] && [ ! -f config/harness_pin.json ]; then
  V=$(omp --version 2>/dev/null | sed 's|^omp/||')
  [ -n "$V" ] || die "omp --version пуст — пин не поставить"
  printf '{"version":"%s"}\n' "$V" > .harness/harness_pin.json
fi
git config --local receive.denyCurrentBranch refuse
# каркас слоя проекта — ТОЛЬКО отсутствующее
if [ ! -f harness.project.json ]; then
  LANG_P=bash
  if [ -f Cargo.toml ]; then LANG_P=rust; elif ls package.json ./*/package.json >/dev/null 2>&1; then LANG_P=typescript; fi
  jq -n --arg pid "$PID" --arg origin "$ORIGIN" --arg lang "$LANG_P" '{schemaVersion:1,repoId:$pid,language:$lang,
    workflowPaths:{contracts:".harness/contracts",verdicts:".harness/verdicts",registry:".harness/registry",fixtures:".harness/fixtures",state:".harness"},
    git:{canonicalRemote:$origin},
    contextPack:{rows:[{kind:"map",path:".harness/HANDOFF.md",roles:"orchestrator,architect,implementer,reviewer,adversary",mandatory:true,why:"каркас подключения 125: состояние проекта"}]},
    projectLayer:{version:"v1",profilePath:".harness/project-layer.json"}}' > harness.project.json
fi
[ -f .harness/project-layer.json ] || jq -n --arg pid "$PID" '{schemaVersion:1,version:"v1",projectId:$pid,workspaceId:$pid}' > .harness/project-layer.json
[ -f .harness/HANDOFF.md ] || printf '## ГДЕ МЫ (подключение %s)\n\n- проект подключён одной командой; предмет не выбран.\n' "$PID" > .harness/HANDOFF.md
[ -f .harness/NABLIUDENIA.md ] || printf '# Наблюдения проекта %s\n' "$PID" > .harness/NABLIUDENIA.md
[ -f .harness/ROADMAP.md ] || printf '# ROADMAP проекта %s\n' "$PID" > .harness/ROADMAP.md
# значения дома секретов — ни в одном файле, который git может проиндексировать (отслеживаемые +
# неигнорируемые, под ЛЮБЫМ именем): иначе отказ ДО сессии; значение не печатается
if [ -f "$SECRETS" ]; then
  VALS=$(mktemp) || die "нет mktemp"
  sed -n 's/^[A-Za-z_][A-Za-z0-9_]*=//p' "$SECRETS" | awk 'length($0) >= 8' > "$VALS"
  HIT=""
  if [ -s "$VALS" ]; then
    HIT=$(git ls-files -z --cached --others --exclude-standard | xargs -0r grep -lsF -f "$VALS" -- | sed -n 1p)
  fi
  rm -f "$VALS"
  [ -z "$HIT" ] || die "sekret-v-dereve: значение дома секретов в файле «$HIT», который git может проиндексировать — сессия не запускается"
fi
export HARNESS_PROJECT_LAYER_ROOT="${HARNESS_PROJECT_LAYER_ROOT:-$ROOT}"
exec "$HERE/workshop" --yolo "$ROOT"
