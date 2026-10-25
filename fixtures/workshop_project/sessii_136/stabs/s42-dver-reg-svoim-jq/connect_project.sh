#!/usr/bin/env bash
# НЕ БАРЬЕР: инструмент оркестратора — одна команда подключения проекта (контракт 125 И-5…И-7);
# её приёмка — красная батарея fixtures/workshop_project/sessii_125/red_sessii_125.sh (контракт 125 §ПРОВОДКА).
# scripts/connect_project.sh — ОДНА команда подключения чужого репозитория к режиму
# проекта (контракт 125, И-5…И-7; хвост задания — 136 И-4): клон HTTPS через
# gh-учётные двойника станции (или уже существующий git-клон) → раскладка
# харнеса под `.harness/` и профиль `harness.project.json` → ровно один запуск
# сессии проекта: `workshop --yolo <корень> -- <MSG>` (корень — отдельный
# позиционный аргумент ДО `--`, MSG — непустой, единственный после; последний
# argv — MSG; дописывать корень в MSG запрещено — 136 v2, Rev136-B1).
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
# rc 0 — сессия проекта запущена (exec `workshop --yolo <корень> -- <MSG>`,
# код сессии — её код);
# rc 1 — именованный отказ (см. список выше), сессия НЕ запускалась;
# rc 2 — неверный вызов (аргумента не ровно один).
set -u
HERE=$(cd "$(dirname "$0")/.." && pwd)
otkaz() { printf 'connect ОТКАЗ: %s\n' "$*" >&2; exit 1; }
[ $# -ge 1 ] && [ $# -le 3 ] || { printf 'connect ОТКАЗ: вход — URL или путь [--task-file F]\n' >&2; exit 2; }
TASKFILE_ARG=""
if [ "${1:-}" = "--task-file" ]; then
  TASKFILE_ARG="${2:?}"
  shift 2
fi
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

# ── 136: пин сессии проекта (НАБЛ-П3): worktree ПОД $PSTATE, вне дерева ──────
PSTATE_BASE="${S136_PSTATE_BASE:-$HOME/dev-harness-projects}"
PSTATE="$PSTATE_BASE/$PID"
mkdir -p "$PSTATE/wt"
PIN_WT="$PSTATE/wt/wip-136-demo"
PIN_BR="wip/136/demo"
if [ ! -e "$PIN_WT" ]; then
  git worktree add -q -b "$PIN_BR" "$PIN_WT" \
    || { printf 'connect ОТКАЗ: worktree-пин не создан\n' >&2; exit 1; }
fi

# 136 v3-достройка (Rev136c-B1): путь реестра — из ЕДИНОГО project_paths_resolve
# (frozen И-6 «путь трассы — из ЕДИНОГО project_paths_resolve»; ПЕРЕСЕЧЕНИЕ
# implementer «103 профильные пути — единственный источник»), образец —
# scripts/done_wave.sh:117-124; библиотека next_id.sh — сиблинг установки
# ($HERE/scripts). Никаких собственных jq-разборов пути реестра: на законном
# профиле БЕЗ workflowPaths (996 repo:workflowPaths:optional → FALLBACK-
# NO-WORKFLOW, эффективный реестр $REPO/registry) собственный jq давал
# .harness/registry ≠ резолверу — дверь сеет/сверяет одно место, make_task
# читает другое (обход X Rev136c). Порядок: сперва конфиг трассы (нет jq/
# конфига → trassa-net-konfiga ДО резолвера — резолверу тоже нужен jq, отказ
# остаётся именованным по трассе, b5), затем резолв реестра.
ORCH_MODEL="$(jq -er '.roles.orchestrator as $r | .tiers[$r].model as $m | .models[$m[1:]]' "$HERE/config/agent_models.json" 2>/dev/null)" \
  || { printf 'connect ОТКАЗ: trassa-net-konfiga: %s/config/agent_models.json\n' "$HERE" >&2; exit 1; }
# ОБМАНКА s42 (R136c-B1): путь реестра СВОИМ jq без project_paths_resolve —
# на профиле без workflowPaths даёт дефолт .harness/registry ≠ эффективному
# $REPO/registry резолвера: дверь судит чужое место, подложенный
# registry/trace.tsv не видит, сеет .harness/registry и поднимает сессию.
REG_REL="$(jq -r '.workflowPaths.registry // ".harness/registry"' harness.project.json 2>/dev/null || printf '.harness/registry')"
mkdir -p "$REG_REL"

# Трасса (семантика — см. блок резолва выше): подмена (чужая модель, дубль
# строк, лишняя строка, read-only файл) — trassa-rashozhdenie rc 1 ДО exec,
# файл не изменяется: ни молчаливое принятие, ни перезапись, ни дописывание
# (И-7: повтор пишет только отсутствующее; пустой файл = отсутствующее);
# равен конфигу — повтор без записи, сессия поднимается.
TRASSA="$(printf 'orchestrator\t%s\tallowed\n' "$ORCH_MODEL")"
if [ -s "$REG_REL/trace.tsv" ]; then
  [ "$(cat "$REG_REL/trace.tsv" 2>/dev/null)" = "$TRASSA" ] \
    || otkaz "trassa-rashozhdenie: $REG_REL/trace.tsv ≠ конфигу установки $HERE/config/agent_models.json"
else
  printf '%s\n' "$TRASSA" > "$REG_REL/trace.tsv"
fi

# 136 (НАБЛ-П10): сев ПУСТОГО перечня исключений паритета CI в workflowPaths
# проекта (заполнение — объявления проекта с причинами, НЕ дело двери);
# корневой config/ дереву проекта не пишется (И-6 125). И-7: повтор не пишет.
[ -e "$REG_REL/ci_parity_exceptions.txt" ] || : > "$REG_REL/ci_parity_exceptions.txt"

# 136 (НАБЛ-П11): процедура субагентных пинов — дверь кладёт в $PSTATE/bin
# скрипт выдачи: каждому субагенту сессии — свой linked worktree под $PSTATE/wt
# и пара WORKTREE=/BRANCH= в его задание. Повторная выдача того же <автор> —
# существующий worktree, без дублирования (И-7).
mkdir -p "$PSTATE/bin"
if [ ! -e "$PSTATE/bin/subagent-pin.sh" ]; then
  {
    printf '#!/usr/bin/env bash\n'
    printf '# 136: пин субагента сессии проекта (НАБЛ-П11). Usage: subagent-pin.sh <NNN> <avtor>\n'
    printf 'set -u\n'
    printf '[ $# -eq 2 ] || { printf "subagent-pin ОТKAZ: NNN avtor\\n" >&2; exit 2; }\n'
    printf 'BASE="${S136_PSTATE_BASE:-$HOME/dev-harness-projects}/%s"\n' "$PID"
    printf 'WT="$BASE/wt/wip-$1-$2"; BR="wip/$1/$2"\n'
    printf 'mkdir -p "$BASE/wt"\n'
    printf '[ -e "$WT" ] || git -C "%s" worktree add -q -b "$BR" "$WT" || { printf "subagent-pin OTKAZ: worktree\\n" >&2; exit 1; }\n' "$KOREN"
    printf 'printf "WORKTREE=%%s\\nBRANCH=%%s\\n" "$WT" "$BR"\n'
  } > "$PSTATE/bin/subagent-pin.sh"
  chmod +x "$PSTATE/bin/subagent-pin.sh"
fi

# Стартовое сообщение (НАБЛ-П6): --task-file | NEXT_TASK.md | служебный бриф.
if [ -n "$TASKFILE_ARG" ]; then
  [ -f "$TASKFILE_ARG" ] || { printf 'connect ОТКАЗ: нет файла задания: %s\n' "$TASKFILE_ARG" >&2; exit 1; }
  MSG="$(cat "$TASKFILE_ARG")"
elif [ -s .harness/NEXT_TASK.md ]; then
  MSG="$(cat .harness/NEXT_TASK.md)"
else
  MSG="Сессия проекта поднята без задания: прочитай .harness/HANDOFF.md и .harness/ROADMAP.md проекта, выбери предмет, доложи план."
fi
# 136: распознаём ВСЕ декларации в задании по токенизатору 032/066, включая
# inline pin:WORKTREE=...:BRANCH=... и пустые/половинные декларации. Регулярное
# выражение токена совпадает с path-guard.ts; пустое значение явно отвергается.
# Значения сравниваются только с парой этой двери, до exec workshop.
PIN_TOKENS="$(printf '%s\n' "$MSG" | grep -Eo '(^|[:;,])[[:space:]]*(WORKTREE|BRANCH)=[^[:space:],;:]*' || true)"
_wt_count=0 _br_count=0 _pin_wrong=0
while IFS= read -r _token; do
  [ -n "$_token" ] || continue
  [[ "$_token" =~ (WORKTREE|BRANCH)=(.*)$ ]] || continue
  _key="${BASH_REMATCH[1]}"
  _value="${BASH_REMATCH[2]}"
  # Страж 066 снимает терминальную пунктуацию с непустых значений.
  _value="$(printf '%s' "$_value" | sed -E 's/[.,;:!?]+$//')"
  if [ "$_key" = WORKTREE ]; then
    _wt_count=$((_wt_count+1))
    [ "$_value" = "$PIN_WT" ] || _pin_wrong=1
  else
    _br_count=$((_br_count+1))
    [ "$_value" = "$PIN_BR" ] || _pin_wrong=1
  fi
done <<< "$PIN_TOKENS"
if [ "$_pin_wrong" -ne 0 ] || [ "$_wt_count" -ne "$_br_count" ]; then
  otkaz "PIN_CHUZHOJ: задание несёт чужую либо половинную декларацию пина"
fi
if [ "$_wt_count" -gt 1 ]; then
  otkaz "PIN_DUBL: повтор пин-пары в задании"
fi
if [ "$_wt_count" -eq 0 ]; then
  MSG="$MSG
WORKTREE=$PIN_WT
BRANCH=$PIN_BR"
fi

# ── Adv125-Б: инструменты сканера секретов — fail-closed ДО записи секретов
# и запуска сессии. Без них `sekret-v-dereve` ниже = лотерея: `awk: command not
# found` оставлял пустой список значений и код шёл до `exec workshop`. Хотя бы
# один нужный инструмент отсутствует — отказ.
for _need in sed grep git mktemp xargs; do
  command -v "$_need" >/dev/null 2>&1 \
    || otkaz "нет инструмента сканера секретов: $_need (sekret-v-dereve нуждается в нём)"
done

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
# Adv125-А: парсер как у workshop `load_env` (срез парных кавычек — `sed
# 's/^["'"'"']//;s/["'"'"']$//'`); значения ЛЮБОЙ длины (контракт И-6 порога
# не задаёт — короткое значение = секрет, не пустышка); в файле значений ОБЕ
# формы записи — дословная (как в secrets.env) и без обрамляющих кавычек, —
# иначе значение `"<secret>"` в файле данных не совпадёт со значением,
# которое `sed`-парсер забрал. Без awk (Adv125-Б — `awk: command not found`
# раньше оставлял пустой ZNACH и сканер шёл дальше). Под ЛЮБЫМ именем файла;
# в отказе — имя файла, не значение.
if [ -f "$DOM_SEKRETOV" ]; then
  ZNACH=$(mktemp) || otkaz "нет mktemp"
  # Парсим KEY=VALUE как workshop: разрез по первому «=», ключ — alphanumeric
  # с подчёркиванием (по `[A-Za-z_][A-Za-z0-9_]*`, как load_env). Пишем
  # значение в обеих формах — дословно (для прямой записи значения в файле) и
  # с обрезанными парными кавычками (как workshop его использует). Пустое
  # значение после обрезки — пропускаем.
  # 125 Рв125b-2 (А2-1): идиома последней строки — `read` возвращает ≠0 на
  # неполной строке, и без `|| [ -n "$k" ]` значение ПОСЛЕДНЕЙ строки
  # secrets.env (файл без хвостового LF) терялось здесь, хотя `grep` выше
  # писал его в `.harness/.env`: дверь писала секрет и молчала о нём. CRLF —
  # снять ДО разбора значения, иначе `\r` часть секрета и совпадения не
  # находит (совет S13).
  while IFS='=' read -r k v || [ -n "$k" ]; do
    v="${v%$'\r'}"
    case "$k" in ''|'#'*) continue ;; esac
    k="${k%% *}"
    [ -n "$v" ] || continue
    printf '%s\n' "$v"
    u=$(printf '%s' "$v" | sed 's/^["'"'"']//;s/["'"'"']$//')
    [ -n "$u" ] && printf '%s\n' "$u"
  done < "$DOM_SEKRETOV" > "$ZNACH"
  HIT=""
  if [ -s "$ZNACH" ]; then
    HIT=$(git ls-files -z --cached --others --exclude-standard | xargs -0r grep -lsF -f "$ZNACH" -- | sed -n 1p)
  fi
  rm -f "$ZNACH"
  unset ZNACH _need
  [ -z "$HIT" ] || otkaz "sekret-v-dereve: значение дома секретов в файле «$HIT», который git может проиндексировать — сессия не запускается"
fi

# Финальный оракул — ТОЛЬКО настоящий extract-pin 066 на ЦЕЛОМ MSG, а не на
# отдельно выданных WT/BR. 136 v2 (Rev136-B2а): собственного сканера-замены у
# двери НЕТ; стража нет или нечем его исполнить — именованный отказ strazh-net
# ДО exec, никакой «эквивалентной» подмены оракулом двери.
command -v node >/dev/null 2>&1 \
  || otkaz "strazh-net: нечем исполнить страж установки (node): $HERE/.omp/extensions/path-guard.ts"
[ -f "$HERE/.omp/extensions/path-guard.ts" ] \
  || otkaz "strazh-net: страж установки отсутствует: $HERE/.omp/extensions/path-guard.ts"
_extracted="$(node "$HERE/.omp/extensions/path-guard.ts" --extract-pin "$MSG")" \
  || otkaz "PIN_CHUZHOJ: невозможно извлечь итоговый пин"
[ "$(printf '%s' "$_extracted" | jq -r '.worktree // empty')" = "$PIN_WT" ] \
  || otkaz "PIN_CHUZHOJ: итоговый текст не извлекается в пин двери"

# ── одна сессия + хвост задания (093 И-5) ────────────────────────────────────
export HARNESS_PROJECT_LAYER_ROOT="${HARNESS_PROJECT_LAYER_ROOT:-$KOREN}"
WORKSHOP_BIN="${S136_WORKSHOP:-$HERE/workshop}"
exec "$WORKSHOP_BIN" --yolo "$KOREN" -- "$MSG"