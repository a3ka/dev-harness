#!/usr/bin/env bash
# scripts/connect_project.sh — ОДНА команда подключения чужого репозитория к режиму
# проекта (контракт 125, И-5…И-7): клон HTTPS через gh-учётные двойника станции (или
# уже существующий git-клон) → раскладка харнесса под `.harness/` и профиль
# `harness.project.json` → ровно один запуск сессии проекта тем же входом, что у
# основной сессии: `workshop --yolo <корень>`.
#
# CLI: ровно один аргумент —
#   https://github.com/<владелец>/<имя>[.git]  |  путь к git-клону
# Имя URL кладётся в `${HARNESS_PROJECTS_DIR:-$HOME/projects}/<имя>`; projectId —
# это имя в нижнем регистре, символ вне `[a-z0-9_-]` заменён на `-` (класс 055).
#
# Раскладка (И-6): в дереве проекта новое — ТОЛЬКО `.harness/` и профиль. Секреты
# приходят из дома секретов станции в `.harness/.env` (режим 600, локальное
# исключение `.git/info/exclude`), значения не печатаются и не попадают ни в индекс,
# ни в HEAD. Именованные отказы (каждый rc 1 ДО сессии, сессия не запускается):
#   projectid-vne-klassa — имя не даёт projectId класса `^[a-z0-9][a-z0-9_-]*$`;
#   env-v-indekse         — `.harness/.env` уже отслеживается git проекта: секреты
#                           не пишутся, файл не трогаем (снять с учёта: `git rm
#                           --cached .harness/.env`);
#   sekret-v-dereve       — значение дома секретов нашлось в файле, который git
#                           проекта может проиндексировать (отслеживаемом или
#                           неигнорируемом), под ЛЮБЫМ именем — судим рабочую копию
#                           на КАЖДОМ входе, повторный вход не слабее первого.
# Повтор (И-7): досоздаётся только отсутствующее; объявления проекта (свой профиль,
# свой HANDOFF, пин в `config/harness_pin.json`) не переписываются и не дублируются.
#
# Коды возврата:
#   0 — сессия проекта запущена (exec `workshop --yolo <корень>`, код сессии — её код);
#   1 — именованный отказ (см. список выше), сессия НЕ запускалась;
#   2 — неверный вызов (аргумента не ровно один).
set -u
HERE=${CONNECT_HERE:-$(cd "$(dirname "$0")/.." && pwd)}
otkaz() { printf 'connect ОТКАЗ: %s\n' "$*" >&2; exit 1; }
[ $# -eq 1 ] || { printf 'connect ОТКАЗ: ровно один вход — URL или путь\n' >&2; exit 2; }
IN=$1

# ── корень и имя проекта ────────────────────────────────────────────────────
case "$IN" in
  https://github.com/*/*)
    printf '%s' "$IN" | grep -Eqx 'https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+' \
      || otkaz "URL вне грамматики: $IN"
    IMYA=${IN##*/}; IMYA=${IMYA%.git}
    KOREN="${HARNESS_PROJECTS_DIR:-$HOME/projects}/$IMYA" ;;
  *)
    [ -d "$IN/.git" ] || otkaz "вход не URL и не git-клон: $IN"
    KOREN=$(cd "$IN" && pwd); IMYA=${KOREN##*/} ;;
esac

# ── projectId: имя в нижнем регистре, класс 055 ─────────────────────────────
PID=$(printf '%s' "$IMYA" | tr 'A-Z' 'a-z' | tr -c 'a-z0-9_-' '-')
printf '%s' "$PID" | grep -Eqx '[a-z0-9][a-z0-9_-]*' \
  || otkaz "projectid-vne-klassa: имя «$IMYA» не даёт projectId класса ^[a-z0-9][a-z0-9_-]*$"

if [ ! -d "$KOREN/.git" ]; then
  # URL: клон HTTPS с учётными двойника gh; `-c credential.helper=` гасит.helper
  # из конфигурации машины, чтобы маршрут к токену был один — наш.
  mkdir -p "$(dirname "$KOREN")"
  git -c credential.helper= -c 'credential.helper=!gh auth git-credential' clone -q "$IN" "$KOREN" \
    || otkaz "клон не удался: $IN"
fi
cd "$KOREN" || otkaz "нет корня: $KOREN"

# ── секреты: сперва отказ «уже отслеживается», лишь потом запись ──────────────
git ls-files --error-unmatch -- .harness/.env >/dev/null 2>&1 \
  && otkaz "env-v-indekse: .harness/.env отслеживается git проекта — секреты не пишутся; снять с учёта: git rm --cached .harness/.env"
DOM_SEKRETOV="$HOME/.config/dev-harness/secrets.env"

# ── каркас слоя проекта: только то, чего ещё нет ────────────────────────────
ORIGIN=$(git remote get-url origin 2>/dev/null || printf '%s' "$KOREN")
mkdir -p .harness/contracts .harness/verdicts .harness/registry .harness/fixtures

# `.env` — ключи списка bootstrap_env лаунчера, из дома секретов (вне дерева
# проекта), режим 600; корень проекта — наследие подключения до 125.
if [ ! -f .harness/.env ] && [ ! -f .env ]; then
  [ -f "$DOM_SEKRETOV" ] || otkaz "нет дома секретов: $DOM_SEKRETOV"
  ( umask 077; grep -E '^(ZAI_API_KEY|MINIMAX_API_KEY|METERING_PROXY_URL|METERING_PROXY_TOKEN)=' "$DOM_SEKRETOV" > .harness/.env || true )
fi
# Исключение локальное (вне дерева): индекс и HEAD проекта секрет не видят.
grep -qxF '.harness/.env' .git/info/exclude 2>/dev/null || printf '.harness/.env\n' >> .git/info/exclude

# Пин версии omp — версия УСТАНОВЛЕННОГО omp; пин наследия в config/ не дублируется.
if [ ! -f .harness/harness_pin.json ] && [ ! -f config/harness_pin.json ]; then
  VER=$(omp --version 2>/dev/null | sed 's|^omp/||')
  [ -n "$VER" ] || otkaz "omp --version пуст — пин не поставить"
  printf '{"version":"%s"}\n' "$VER" > .harness/harness_pin.json
fi

git config --local receive.denyCurrentBranch refuse

# Профиль — единственный корневой файл харнесса в дереве проекта (его читает
# резолвер 996 и инструменты харнесса); объявления проекта поверх не трогаем.
if [ ! -f harness.project.json ]; then
  YAZYK=bash
  if [ -f Cargo.toml ]; then YAZYK=rust
  elif ls package.json ./*/package.json >/dev/null 2>&1; then YAZYK=typescript
  fi
  jq -n --arg pid "$PID" --arg origin "$ORIGIN" --arg lang "$YAZYK" \
    '{schemaVersion:1,repoId:$pid,language:$lang,
      workflowPaths:{contracts:".harness/contracts",verdicts:".harness/verdicts",
        registry:".harness/registry",fixtures:".harness/fixtures",state:".harness"},
      git:{canonicalRemote:$origin},
      contextPack:{rows:[{kind:"map",path:".harness/HANDOFF.md",
        roles:"orchestrator,architect,implementer,reviewer,adversary",mandatory:true,
        why:"каркас подключения 125: состояние проекта"}]},
      projectLayer:{version:"v1",profilePath:".harness/project-layer.json"}}' \
    > harness.project.json
fi
[ -f .harness/project-layer.json ] \
  || jq -n --arg pid "$PID" '{schemaVersion:1,version:"v1",projectId:$pid,workspaceId:$pid}' \
     > .harness/project-layer.json
[ -s .harness/HANDOFF.md ] \
  || printf '## ГДЕ МЫ (подключение %s)\n\n- проект подключён одной командой; предмет не выбран.\n' "$PID" \
     > .harness/HANDOFF.md
[ -s .harness/NABLIUDENIA.md ] || printf '# Наблюдения проекта %s\n' "$PID" > .harness/NABLIUDENIA.md
[ -s .harness/ROADMAP.md ]    || printf '# ROADMAP проекта %s\n' "$PID"    > .harness/ROADMAP.md

# ── последний страж: значение дома секретов в файле, который git проиндексирует ──
# Отслеживаемые + неигнорируемые (то есть всё, что `git add -A` заберёт), под
# ЛЮБЫМ именем; само значение не печатается — в отказе только имя файла.
if [ -f "$DOM_SEKRETOV" ]; then
  ZNACH=$(mktemp) || otkaz "нет mktemp"
  sed -n 's/^[A-Za-z_][A-Za-z0-9_]*=//p' "$DOM_SEKRETOV" | awk 'length($0) >= 8' > "$ZNACH"
  HIT=""
  if [ -s "$ZNACH" ]; then
    HIT=$(git ls-files -z --cached --others --exclude-standard | xargs -0r grep -lsF -f "$ZNACH" -- | sed -n 1p)
  fi
  rm -f "$ZNACH"
  [ -z "$HIT" ] || otkaz "sekret-v-dereve: значение дома секретов в файле «$HIT», который git может проиндексировать — сессия не запускается"
fi

# ── одна сессия, тот же вход, что у основной ────────────────────────────────
export HARNESS_PROJECT_LAYER_ROOT="${HARNESS_PROJECT_LAYER_ROOT:-$KOREN}"
exec "$HERE/workshop" --yolo "$KOREN"