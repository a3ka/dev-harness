#!/usr/bin/env bash
# КРАСНАЯ БАТАРЕЯ 136 «доводка сессий проектов» (125-б; слово владельца
# 2026-10-22 ~11:10 UTC «да, делаем так», docs/owner/2026-10-22-poryadok-slota-i-125b.md).
#
# ШЕСТЬ БОЛЕЙ сессии проекта (замер сессии Complior-back, её .harness/NABLIUDENIA.md 21–22.10):
#   НАБЛ-П3/П11 — write-guard Н-85 запрещает запись в чекаут проекта сессии и её субагентам;
#   НАБЛ-П12    — write agent://<id> из сессии проекта запрещён;
#   НАБЛ-П10    — precision-гейт (нога «в», паритет CI) красен в проектном режиме
#                 без ручного config/ci_parity_exceptions.txt (~40 FAIL на команды CI проекта);
#   НАБЛ-П17    — brief make_task пуст при заданных contextPack.rows (roles без orchestrator);
#   НАБЛ-П5     — make_task --kind brief отказывает «нет свидетельства модели», трассу вписывают руками;
#   НАБЛ-П6     — connect_project.sh поднимает сессию БЕЗ задания (замер: 8 ч простоя 22.10).
#
# СУБЪЕКТЫ: scripts/connect_project.sh, scripts/make_task.sh, scripts/verify_ci_parity.sh
# (дерево | model/ | stabs/<имя>/); страж .omp/extensions/path-guard.ts — РЕАЛЬНЫЙ, не меняется
# (грамматика пина 032/066 уже принимает любой живой linked worktree: git-оракул судит живость,
# не принадлежность dev-harness). Привязка стаб → клетки — ТОЛЬКО source.json:.stab_vhod (Н-39).
# Мутация стаба может красить и клетки вне своей привязки (например, стабы
# двери без пина гасят и выдачу subagent-pin.sh) — привязка в source.json
# это МИНИМУМ гарантированной красноты, а не полный эффект мутации (замечание
# критика r1).
#
# Дверь исполняется из песочницы $SB (копия файла двери + двойник workshop рядом): дверь
# дословно разрешает(exec) $HERE/workshop — двойник пишет по одному аргументу в строку в
# $W/args.txt и выходит 7; сообщение сессии = строки после литеральной строки «--».
#
# РЕЖИМЫ:
#   без ключей  — субъекты из дерева ветки: боли живы → rc 1;
#   --model     — честные модели model/ (дерево + точки правок контракта) → rc 0;
#   --stabs     — каждый стаб гасит свой субъект, его клетки ОБЯЗАНЫ покраснеть;
#                 rc 0 «стабов 18, привязок 34, непойманных 0».
#
# Миры — /tmp/dev-harness-verify/sessii-136-<клетка>/** (оракулы в памяти, правило 8);
# чекауты проектов — /tmp/dev-harness-fakehome-136/<клетка>/** ВНЕ scratch-allowlist Н-85
# (иначе боль П3 немотивированно зелёная: allowlist прикрыл бы её — прецедент pg066).
set -uo pipefail
B="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$B/../../.." && pwd)"
GUARD="$ROOT/.omp/extensions/path-guard.ts"
MODE="plain"; [ "${1:-}" = "--model" ] && MODE="model"; [ "${1:-}" = "--stabs" ] && MODE="stab"
[ -f "$GUARD" ] || { printf 'субъект отсутствует: %s\n' "$GUARD" >&2; exit 2; }
command -v node >/dev/null 2>&1 || { printf 'нет node\n' >&2; exit 2; }
command -v jq   >/dev/null 2>&1 || { printf 'нет jq\n'   >&2; exit 2; }

subj() { case "$MODE" in
    model) printf '%s' "$B/model/$2" ;;
    stab)  printf '%s' "${STAB_DIR:-/NETU-STABA}/$2" ;;
    *)     printf '%s' "$ROOT/$1" ;; esac; }
DOOR="$(subj scripts/connect_project.sh connect_project.sh)"
MKT="$(subj scripts/make_task.sh make_task.sh)"
PAR="$(subj scripts/verify_ci_parity.sh verify_ci_parity.sh)"

W=""; FH=""; SEED=""; DVER_CONFIG=""; DVER_RC=""
mk_mir() { # mk_mir <слуг> [next] [harness]
  local slug="$1"
  W="/tmp/dev-harness-verify/sessii-136-$slug"
  FH="/tmp/dev-harness-fakehome-136/$slug"
  DVER_CONFIG=""; DVER_RC=""
  rm -rf "$W" "$FH"; mkdir -p "$W" "$FH/projects" "$FH/dev-harness-projects/toy-proj/wt" "$FH/seed"
  SEED="$FH/seed/toy-proj"
  git init -q "$SEED"
  git -C "$SEED" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
  mkdir -p "$SEED/.github/workflows" "$SEED/docs" "$SEED/.harness/contracts" "$SEED/.harness/verdicts" "$SEED/.harness/registry" "$SEED/.harness/records" "$SEED/.harness/fixtures"
  printf 'name: ci\non: [push]\njobs:\n  b:\n    runs-on: ubuntu-latest\n    steps:\n      - run: npm run dev\n' > "$SEED/.github/workflows/ci.yml"
  printf '{"name":"toy","scripts":{"build":"echo b"}}\n' > "$SEED/package.json"
  printf '# Архитектура\nСлои: api, worker, pg.\n' > "$SEED/docs/ARCHITECTURE.md"
  printf '# Стандарт\nИменование: kebab-case.\n' > "$SEED/docs/CODING-STANDARDS.md"
  # workflowPaths.registry ПЕРЕОПРЕДЕЛЕН (.harness/records ≠ дефолт): все
  # клетки двери/паритета обязаны брать каталог реестра ПО ФАКТУ профиля,
  # а не зашитый .harness/registry (блокер 3 критика r1)
  if [ "${2:-}" != "harness" ] && [ "${3:-}" != "harness" ]; then
  jq -n '{schemaVersion:1,repoId:"toy-proj",language:"typescript",
    workflowPaths:{contracts:".harness/contracts",verdicts:".harness/verdicts",
      registry:".harness/records",fixtures:".harness/fixtures",state:".harness"},
    git:{canonicalRemote:"https://github.com/x/toy-proj.git"},
    contextPack:{rows:[
      {kind:"map",path:"docs/ARCHITECTURE.md",roles:"architect,implementer,reviewer,adversary",mandatory:true,why:"карта архитектуры проекта"},
      {kind:"rules",path:"docs/CODING-STANDARDS.md",roles:"architect,implementer,reviewer,adversary",mandatory:true,why:"стандарт проекта"}]},
    projectLayer:{version:"v1",profilePath:".harness/project-layer.json"}}' > "$SEED/harness.project.json"
  fi
  printf '## ГДЕ МЫ\n\n- предмет не выбран.\n' > "$SEED/.harness/HANDOFF.md"
  printf 'id\tpora\tdepend\tsource\tdoc\tdesc\n' > "$SEED/.harness/registry/plan.tsv"
  printf '# 777 toy\n\n## Существующее\n- toy-контракт клетки c4.\n\nЗОНА implementer: docs/ARCHITECTURE.md\n' > "$SEED/.harness/contracts/777-toy.md"
  [ "${2:-}" = "next" ] && printf 'Задание: релиз 1.2, прогнать CI проекта, доложить.\n' > "$SEED/.harness/NEXT_TASK.md"
  git -C "$SEED" add -A; git -C "$SEED" -c user.name=t -c user.email=t@t commit -q -m toy
  # дом секретов (дверь отказывает без него — Adv125): несекретные значения
  mkdir -p "$FH/.config/dev-harness"
  printf 'ZAI_API_KEY=za-dummy\nMINIMAX_API_KEY=mm-dummy\nMETERING_PROXY_URL=http://u\nMETERING_PROXY_TOKEN=mt-dummy\n' > "$FH/.config/dev-harness/secrets.env"
}
run_dver() { # копия двери в песочницу + двойник workshop + двойник КОНФИГА
  # УСТАНОВКИ $SB/config/agent_models.json (источник трассы, блокер 2);
  # DVER_CONFIG — управляемое содержимое конфига клетки. Сообщение — после «--».
  local SB="$W/sb"; mkdir -p "$SB/scripts" "$SB/config" "$SB/.omp/extensions"
  cp "$DOOR" "$SB/scripts/connect_project.sh"
  cp "$GUARD" "$SB/.omp/extensions/path-guard.ts"
  if [ -n "$DVER_CONFIG" ]; then printf '%s' "$DVER_CONFIG" > "$SB/config/agent_models.json"
  else cp "$ROOT/config/agent_models.json" "$SB/config/agent_models.json"; fi
  printf '#!/usr/bin/env bash\nfor a in "$@"; do printf "%%s\\n" "$a"; done > "%s"\nexit 7\n' "$W/args.txt" > "$SB/workshop"
  chmod +x "$SB/workshop"
  if [ -n "${2:-}" ]; then
    env HOME="$FH" HARNESS_PROJECTS_DIR="$FH/projects" \
      S136_PSTATE_BASE="$FH/dev-harness-projects" \
      bash "$SB/scripts/connect_project.sh" --task-file "$2" "${1:-$SEED}" >"$W/dvor.out" 2>"$W/dvor.err"
  else
    env HOME="$FH" HARNESS_PROJECTS_DIR="$FH/projects" \
      S136_PSTATE_BASE="$FH/dev-harness-projects" \
      bash "$SB/scripts/connect_project.sh" "${1:-$SEED}" >"$W/dvor.out" 2>"$W/dvor.err"
  fi
  DVER_RC=$?
}
dver_msg() { awk 'f{print} $0=="--"{f=1}' "$W/args.txt" 2>/dev/null; }
# сцена субъекта make_task: файл субъекта (дерево|модель|стаб) дословно +
# НЕменяемые контрактом 136 спутники дерева (profile_resolver.sh, next_id.sh —
# сиблинги по $(dirname $0), в model/ их нет)
mkt_dir() {
  local d="$W/mktbin"; mkdir -p "$d"
  cp "$MKT" "$d/make_task.sh"
  cp "$ROOT/scripts/profile_resolver.sh" "$ROOT/scripts/next_id.sh" "$d/"
  printf '%s' "$d/make_task.sh"
}
judge() { HOME="$FH" node "$GUARD" --judge "$1"; }
epin()  { HOME="$FH" node "$GUARD" --extract-pin "$1" 2>/dev/null; }

k_a1() { mk_mir a1-p6-hvost next; run_dver
  local msg; msg="$(dver_msg)"
  [ -n "$msg" ] && printf '%s\n' "$msg" | grep -Fq 'релиз 1.2'; }
k_a2() { mk_mir a2-p6-brief-defolt; run_dver
  local msg; msg="$(dver_msg)"
  [ -n "$msg" ] && printf '%s\n' "$msg" | grep -Fq 'HANDOFF'; }
k_a3() { mk_mir a3-p3-pin; run_dver
  local msg wt; msg="$(dver_msg)"; wt="$(printf '%s\n' "$msg" | sed -n 's/^WORKTREE=//p' | head -1)"
  # подмена пина (блокер 1 критика r1): задание несёт ЧУЖУЮ пару — дверь
  # обязана отказаться именованно (PIN_CHUZHOJ) и НЕ поднимать сессию
  # (args.txt двойника не появляется), а не стартовать непиннованной
  { [ -n "$wt" ] \
    && case "$wt" in "$FH"/dev-harness-projects/*) : ;; *) false ;; esac \
    && [ "${wt#"$FH"/projects/}" = "$wt" ] \
    && git -C "$SEED" worktree list --porcelain | grep -Fqx "worktree $wt"; } || return 1
  printf 'Задание: релиз 1.2\nWORKTREE=/fake/wip-777-other\nBRANCH=wip/777/other\n' > "$SEED/.harness/NEXT_TASK.md"
  rm -f "$W/args.txt"; run_dver
  [ "$DVER_RC" -eq 1 ] && grep -q 'PIN_CHUZHOJ' "$W/dvor.err" && [ ! -e "$W/args.txt" ]; }
k_a4() { mk_mir a4-p3-zapis; run_dver
  local msg wt pin; msg="$(dver_msg)"; wt="$(printf '%s\n' "$msg" | sed -n 's/^WORKTREE=//p' | head -1)"
  [ -n "$wt" ] || return 1
  pin="$(epin "$msg" | jq -r '.worktree // empty')"
  [ -n "$pin" ] && [ "$pin" = "$wt" ] \
    && [ "$(judge "{\"tool\":\"write\",\"args\":{\"path\":\"$wt/f.txt\"},\"worktree\":\"$wt\"}" | jq -r .decision)" = "pass" ] || return 1
  # подмена пина на входе записи: чужая пара в NEXT_TASK.md неживá для
  # git-оракула (extract-pin → null: старт был бы непиннован, judge
  # agent:// — block) — единственный честный исход двери: PIN_CHUZHOJ,
  # сессия не поднимается
  printf 'Задание: релиз 1.2\nWORKTREE=/fake/wip-777-other\nBRANCH=wip/777/other\n' > "$SEED/.harness/NEXT_TASK.md"
  [ "$(epin "$(cat "$SEED/.harness/NEXT_TASK.md")" | jq -r '.worktree // empty')" = "" ] || return 1
  rm -f "$W/args.txt"; run_dver
  [ "$DVER_RC" -eq 1 ] && grep -q 'PIN_CHUZHOJ' "$W/dvor.err" && [ ! -e "$W/args.txt" ]; }
# Каждый вход — отдельная клетка: отказ одной формы не маскирует соседнюю.
# Пара WT/BR снята с реально созданного worktree до предъявления задания.
k_pin_case() { # slug source shape result
  local slug="$1" source="$2" shape="$3" expected="$4" wt br pair txt file msg got
  mk_mir "$slug"; run_dver
  wt="$FH/dev-harness-projects/toy-proj/wt/wip-136-demo"
  br="wip/136/demo"
  git -C "$SEED" worktree list --porcelain | grep -Fqx "worktree $wt" || return 1
  pair="WORKTREE=$wt"$'\n'"BRANCH=$br"
  case "$shape" in
    block)        txt="$pair" ;;
    inline)       txt="pin:WORKTREE=$wt:BRANCH=$br" ;;
    delimiters)   txt="note;  WORKTREE=$wt, BRANCH=$br" ;;
    duplicate)    txt="$pair"$'\n'"$pair" ;;
    mixed)        txt="$pair"$'\n''WORKTREE=/fake/wip-777-other'$'\n''BRANCH=wip/777/other' ;;
    reverse)      txt='WORKTREE=/fake/wip-777-other'$'\n''BRANCH=wip/777/other'$'\n'"$pair" ;;
    foreign-wt)   txt="WORKTREE=/fake/wip-777-other"$'\n'"BRANCH=$br" ;;
    foreign-br)   txt="WORKTREE=$wt"$'\n''BRANCH=wip/777/other' ;;
    extra-wt)     txt="$pair"$'\n'"WORKTREE=$wt" ;;
    extra-br)     txt="$pair"$'\n'"BRANCH=$br" ;;
    half-wt)      txt="WORKTREE=$wt" ;;
    empty-br)     txt="BRANCH=" ;;
    inline-mixed) txt="pin:WORKTREE=$wt:BRANCH=$br"$'\n'"$pair" ;;
    live-foreign) git -C "$SEED" worktree add -q -b wip/777/other "$FH/dev-harness-projects/toy-proj/wt/wip-777-other" || return 1
                  txt="WORKTREE=$FH/dev-harness-projects/toy-proj/wt/wip-777-other"$'\n''BRANCH=wip/777/other'
                  [ "$(epin "$txt" | jq -r '.worktree // empty')" = "$FH/dev-harness-projects/toy-proj/wt/wip-777-other" ] || return 1 ;;
    inline-foreign) txt="pin:WORKTREE=$wt:BRANCH=wip/777/other" ;;
    *) return 2 ;;
  esac
  txt="Задание: релиз 1.2, сохранить исходный текст."$'\n'"$txt"
  if [ "$source" = taskfile ]; then file="$W/task.txt"
  else file="$SEED/.harness/NEXT_TASK.md"; fi
  printf '%s\n' "$txt" > "$file"
  rm -f "$W/args.txt"
  if [ "$source" = taskfile ]; then run_dver "$SEED" "$file"; else run_dver; fi
  [ "$(cat "$file")" = "$txt" ] || return 1
  if [ "$expected" = pass ]; then
    [ "$DVER_RC" -eq 7 ] && [ -f "$W/args.txt" ] || return 1
    msg="$(dver_msg)"
    printf '%s\n' "$msg" | grep -Fq 'Задание: релиз 1.2, сохранить исходный текст.' || return 1
    got="$(epin "$msg" | jq -r '.worktree // empty')"
    [ "$got" = "$wt" ] || return 1
    [ "$(judge "{\"tool\":\"write\",\"args\":{\"path\":\"$got/result.txt\"},\"worktree\":\"$got\"}" | jq -r .decision)" = pass ] \
      && [ "$(judge "{\"tool\":\"write\",\"args\":{\"path\":\"agent://Rev1\"},\"worktree\":\"$got\"}" | jq -r .decision)" = pass ]
  else
    [ "$DVER_RC" -eq 1 ] && grep -Fq "$expected" "$W/dvor.err" && [ ! -e "$W/args.txt" ]
  fi
}
k_a5() { mk_mir a5-p12-agent; run_dver
  local wt; wt="$(dver_msg | sed -n 's/^WORKTREE=//p' | head -1)"
  [ -n "$wt" ] \
    && [ "$(judge "{\"tool\":\"write\",\"args\":{\"path\":\"agent://Rev1\"},\"worktree\":\"$wt\"}" | jq -r .decision)" = "pass" ]; }
k_a6() { mk_mir a6-p11-subagent-pin; run_dver
  local P para wt
  P="$FH/dev-harness-projects/toy-proj/bin/subagent-pin.sh"
  [ -x "$P" ] || return 1
  para="$(env HOME="$FH" S136_PSTATE_BASE="$FH/dev-harness-projects" bash "$P" 777 demo)" || return 1
  wt="$(printf '%s\n' "$para" | sed -n 's/^WORKTREE=//p' | head -1)"
  # выдача пина: живой worktree + проход записи субагента
  { [ -n "$wt" ] && [ "$(epin "$para" | jq -r '.worktree // empty')" = "$wt" ] \
    && git -C "$SEED" worktree list --porcelain | grep -Fqx "worktree $wt" \
    && [ "$(judge "{\"tool\":\"bash\",\"args\":{\"command\":\"printf x > f.txt\",\"cwd\":\"$wt\"},\"worktree\":\"$wt\"}" | jq -r .decision)" = "pass" ]; } || return 1
  # доставка результата (блокер 4 критика r1, И-3): субагент коммитит в
  # СВОЙ worktree — tip его ветки виден из чекаута проекта git-каналом
  # (общий object store), без ручного переноса между деревьями
  printf 'agent result 777\n' > "$wt/agent.txt" \
    && git -C "$wt" add agent.txt \
    && git -C "$wt" -c user.name=agent -c user.email=agent@t commit -qm 'agent result' \
    && [ -n "$(git -C "$SEED" rev-parse --verify --quiet wip/777/demo)" ] \
    && [ "$(git -C "$SEED" rev-parse wip/777/demo)" = "$(git -C "$wt" rev-parse HEAD)" ] \
    && [ "$(git -C "$SEED" show wip/777/demo:agent.txt)" = 'agent result 777' ]; }
k_a7() { mk_mir a7-granica; run_dver
  [ "$(judge "{\"tool\":\"write\",\"args\":{\"path\":\"$SEED/f.txt\"},\"worktree\":null,\"actual\":\"$SEED\"}" | jq -r .decision)" = "block" ]; }
k_b1() { mk_mir b1-povtor; run_dver
  local K tr ex tr1 ex1 hd1
  K="$SEED"; tr="$K/.harness/records/trace.tsv"; ex="$K/.harness/records/ci_parity_exceptions.txt"
  [ -f "$tr" ] && [ -f "$ex" ] || return 1
  tr1="$(cat "$tr")"; ex1="$(cat "$ex")"
  printf '## ГДЕ МЫ\n\n- правка владельца между входами двери.\n' > "$K/.harness/HANDOFF.md"
  hd1="$(cat "$K/.harness/HANDOFF.md")"
  run_dver
  [ "$(cat "$tr")" = "$tr1" ] && [ "$(cat "$ex")" = "$ex1" ] \
    && [ "$(cat "$K/.harness/HANDOFF.md")" = "$hd1" ] \
    && [ "$(git -C "$K" worktree list --porcelain | grep -c 'wip-136-demo')" = "1" ]; }
k_b2() { mk_mir b2-p10-raskladka; run_dver
  # раскладка ПО ФАКТУ профиля (registry=.harness/records): сев двери — в
  # records, корневого config/ нет (блокер 3 критика r1)
  local K; K="$SEED"
  [ -f "$K/.harness/records/ci_parity_exceptions.txt" ] && [ -f "$K/.harness/records/trace.tsv" ] \
    && [ ! -e "$K/.harness/registry/trace.tsv" ] \
    && [ ! -e "$K/.harness/registry/ci_parity_exceptions.txt" ] \
    && [ ! -e "$K/config" ]; }
mkt_brief() {
  local mb; mb="$(mkt_dir)"
  env HOME="$FH" HARNESS_PROJECT_LAYER_ROOT="$SEED" \
    bash "$mb" --repo "$SEED" --role orchestrator --kind brief "$@" 2>"$W/mkt.err"
}
k_c1() { mk_mir c1-p17-map; run_dver; mkt_brief | grep -Fqx 'MAP: docs/ARCHITECTURE.md :: карта архитектуры проекта'; }
k_c2() { mk_mir c2-p17-rules; run_dver; mkt_brief | grep -Fqx 'RULES: docs/CODING-STANDARDS.md'; }
k_c3() { mk_mir c3-p5-trassa
  # источник трассы — КОНФИГ УСТАНОВКИ (блокер 2 критика r1, В-4а):
  # конфиг назначает оркестратору Sonnet — трасса обязана нести ЕГО,
  # зашитый GLM = рассогласование trace↔конфиг. Ожидание снято из того же
  # конфига той же jq-цепочкой, что у двери (одна грамматика значений).
  local out model
  DVER_CONFIG='{"roles":{"orchestrator":"default"},"tiers":{"default":{"model":"@sonnet136"}},"models":{"sonnet136":"anthropic/claude-sonnet-5-5"}}'
  run_dver
  model="$(printf '%s' "$DVER_CONFIG" | jq -r '.roles.orchestrator as $r | .tiers[$r].model as $m | .models[$m[1:]]')"
  out="$(mkt_brief)" \
    && [ "$model" = "anthropic/claude-sonnet-5-5" ] \
    && printf '%s\n' "$out" | grep -Fq "TRACE: role=orchestrator model=$model fallback=allowed" \
    && ! printf '%s\n' "$out" | grep -Fq 'model=zai/glm-5.3'; }
k_c4() { mk_mir c4-kontrol; run_dver
  local out rc
  # трасса — оракул клетки (не дверь): судья critic + автор architect разных семей
  printf 'orchestrator\tzai/glm-5.3\tallowed\narchitect\tminimax/m1\tallowed\ncritic\tzai/glm-5.3\tallowed\n' > "$W/c4trace.tsv"
  local mb; mb="$(mkt_dir)"
  out="$(env HOME="$FH" HARNESS_PROJECT_LAYER_ROOT="$SEED" \
    bash "$mb" --repo "$SEED" --role critic --kind task --contract 777 \
      --model-trace "$W/c4trace.tsv" 2>"$W/mkt.err")"; rc=$?
  [ "$rc" -eq 0 ] && [ -n "$out" ] && ! printf '%s\n' "$out" | grep -Fq 'MAP: docs/ARCHITECTURE.md'; }
k_c5() { mk_mir c5-jeksplizit; run_dver
  local out; printf 'orchestrator\tanthropic/opus\tallowed\n' > "$W/explicit.tsv"
  out="$(mkt_brief --model-trace "$W/explicit.tsv")" \
    && printf '%s\n' "$out" | grep -Fq 'TRACE: role=orchestrator model=anthropic/opus fallback=allowed'; }
k_d1() { mk_mir d1-p10; run_dver
  # сев двери: ПУСТОЙ перечень в ПЕРЕОПРЕДЕЛЁННОМ workflowPaths.registry
  # (.harness/records) сразу после входа — заполнение уже дело проекта
  local K; K="$SEED"
  { [ -f "$K/.harness/records/ci_parity_exceptions.txt" ] && [ ! -s "$K/.harness/records/ci_parity_exceptions.txt" ]; } || return 1
  printf 'build = скрипт сборки тоя вне CI проекта, объявлён по причине клетки d1\nкоманда: npm run dev = команда релизного CI проекта, приёмкой пакета не является совсем\n' > "$K/.harness/records/ci_parity_exceptions.txt"
  env HOME="$FH" bash "$PAR" "$K" >"$W/par.out" 2>&1; }
k_d2() { mk_mir d2-kontrol-dom harness
  # контроль режима харнесса ДОСЛОВНО: корень БЕЗ harness.project.json —
  # исключения в config/ci_parity_exceptions.txt, семантика 020 не тронута
  mkdir -p "$SEED/config"
  printf 'build = скрипт сборки тоя вне CI проекта, объявлён по причине клетки d2\nкоманда: npm run dev = команда релизного CI проекта, приёмкой пакета не является совсем\n' > "$SEED/config/ci_parity_exceptions.txt"
  env HOME="$FH" bash "$PAR" "$SEED" >"$W/par2.out" 2>&1; }
k_d3() { mk_mir d3-kontrol; run_dver
  # (блокер 3 критика r1) проектный режим читает ТОЛЬКО профильный перечень;
  # корневой config/ — ловушка: молчаливый обход профиля запрещён
  local K rc1 rc2; K="$SEED"
  # (1) профильный перечень ПУСТ (стёрт до нуля) + достаточная ловушка в
  # корне: честный гейт — rc 1 FAIL на первой непокрытой команде CI
  mkdir -p "$K/config"
  printf 'build = скрипт сборки тоя вне CI проекта, объявлён по причине клетки d3\nкоманда: npm run dev = команда релизного CI проекта, приёмкой пакета не является совсем\n' > "$K/config/ci_parity_exceptions.txt"
  : > "$K/.harness/records/ci_parity_exceptions.txt"
  env HOME="$FH" bash "$PAR" "$K" >"$W/par3.out" 2>&1; rc1=$?
  # (2) профильного файла НЕТ + та же ловушка в корне: честный отказ —
  # rc 2 с именем ПРОФИЛЬНОГО пути, никогда не зелёный от корня
  rm -f "$K/.harness/records/ci_parity_exceptions.txt"
  env HOME="$FH" bash "$PAR" "$K" >"$W/par4.out" 2>&1; rc2=$?
  [ "$rc1" -eq 1 ] && grep -q 'FAIL' "$W/par3.out" \
    && [ "$rc2" -eq 2 ] && grep -q 'NOT_IMPLEMENTED' "$W/par4.out" \
    && grep -Fq "$K/.harness/records/ci_parity_exceptions.txt" "$W/par4.out"; }

ORDER="a1-p6-hvost a2-p6-brief-defolt a3-p3-pin-v-soobshchenii a4-p3-zapis a5-p12-agent a6-p11-subagent-pin a7-granica-unpinned a8-pin-block a9-pin-inline a10-pin-duplicate a11-pin-mixed a12-pin-reverse a13-pin-foreign-wt a14-pin-foreign-br a15-pin-extra-wt a16-pin-extra-br a17-pin-half-wt a18-pin-empty-br a19-pin-inline-mixed a20-pin-delimiters a21-pin-taskfile-duplicate a22-pin-taskfile-inline a23-pin-live-foreign a24-pin-inline-foreign b1-povtor b2-p10-raskladka c1-p17-map c2-p17-rules c3-p5-trassa-defolt c4-kontrol-filtr c5-kontrol-jeksplizit d1-p10-isklyuchenie d2-kontrol-dom d3-kontrol-koren"
run_cell() { case "$1" in
  a1-p6-hvost) k_a1 ;; a2-p6-brief-defolt) k_a2 ;; a3-p3-pin-v-soobshchenii) k_a3 ;;
  a4-p3-zapis) k_a4 ;; a5-p12-agent) k_a5 ;; a6-p11-subagent-pin) k_a6 ;;
  a7-granica-unpinned) k_a7 ;;
  a8-pin-block) k_pin_case a8 next block pass ;;
  a9-pin-inline) k_pin_case a9 next inline pass ;;
  a10-pin-duplicate) k_pin_case a10 next duplicate PIN_DUBL ;;
  a11-pin-mixed) k_pin_case a11 next mixed PIN_CHUZHOJ ;;
  a12-pin-reverse) k_pin_case a12 next reverse PIN_CHUZHOJ ;;
  a13-pin-foreign-wt) k_pin_case a13 next foreign-wt PIN_CHUZHOJ ;;
  a14-pin-foreign-br) k_pin_case a14 next foreign-br PIN_CHUZHOJ ;;
  a15-pin-extra-wt) k_pin_case a15 next extra-wt PIN_CHUZHOJ ;;
  a16-pin-extra-br) k_pin_case a16 next extra-br PIN_CHUZHOJ ;;
  a17-pin-half-wt) k_pin_case a17 next half-wt PIN_CHUZHOJ ;;
  a18-pin-empty-br) k_pin_case a18 next empty-br PIN_CHUZHOJ ;;
  a19-pin-inline-mixed) k_pin_case a19 next inline-mixed PIN_DUBL ;;
  a20-pin-delimiters) k_pin_case a20 next delimiters pass ;;
  a21-pin-taskfile-duplicate) k_pin_case a21 taskfile duplicate PIN_DUBL ;;
  a22-pin-taskfile-inline) k_pin_case a22 taskfile inline pass ;;
  a23-pin-live-foreign) k_pin_case a23 next live-foreign PIN_CHUZHOJ ;;
  a24-pin-inline-foreign) k_pin_case a24 next inline-foreign PIN_CHUZHOJ ;;
  b1-povtor) k_b1 ;; b2-p10-raskladka) k_b2 ;;
  c1-p17-map) k_c1 ;; c2-p17-rules) k_c2 ;; c3-p5-trassa-defolt) k_c3 ;;
  c4-kontrol-filtr) k_c4 ;; c5-kontrol-jeksplizit) k_c5 ;;
  d1-p10-isklyuchenie) k_d1 ;; d2-kontrol-dom) k_d2 ;; d3-kontrol-koren) k_d3 ;; esac; }

case "$MODE" in
  plain|model)
    gr=0 kr=0 spisok=""
    for c in $ORDER; do
      if run_cell "$c"; then gr=$((gr+1)); else kr=$((kr+1)); spisok="$spisok $c"; fi
    done
    printf 'sessii_136: клеток %d, зелёных %d, красных %d\n' "$(printf '%s\n' $ORDER | wc -l | tr -d ' ')" "$gr" "$kr"
    [ -z "$spisok" ] || printf 'красные:%s\n' "$spisok" >&2
    if [ "$MODE" = "model" ]; then [ "$kr" -eq 0 ] || { printf 'модель не зелёная\n' >&2; exit 2; }; fi
    [ "$kr" -eq 0 ] || exit 1; exit 0 ;;
  stab)
    # предпроверка зелёности на ЧЕСТНОЙ модели (стабы гоняются поверх зелёного)
    DOOR="$B/model/connect_project.sh"; MKT="$B/model/make_task.sh"; PAR="$B/model/verify_ci_parity.sh"
    grm=0 krm=0 sp=""
    for c in $ORDER; do
      if run_cell "$c"; then grm=$((grm+1)); else krm=$((krm+1)); sp="$sp $c"; fi
    done
    [ "$krm" -eq 0 ] || { printf 'модель не зелёная, стабы не гоняются:%s\n' "$sp" >&2; exit 2; }
    nstab=0 npriv=0 nepon=0
    for d in "$B"/stabs/*/; do
      s="$(basename "$d")"; STAB_DIR="$d"
      DOOR="$d/connect_project.sh"; [ -f "$DOOR" ] || DOOR="$B/model/connect_project.sh"
      MKT="$d/make_task.sh";   [ -f "$MKT" ]   || MKT="$B/model/make_task.sh"
      PAR="$d/verify_ci_parity.sh"; [ -f "$PAR" ] || PAR="$B/model/verify_ci_parity.sh"
      cells="$(jq -r --arg s "$s" '.stab_vhod[$s][]' "$B/source.json")"
      [ -n "$cells" ] || { printf 'СТАБ БЕЗ ПРИВЯЗОК: %s\n' "$s" >&2; exit 2; }
      nstab=$((nstab+1))
      for c in $cells; do
        npriv=$((npriv+1))
        if run_cell "$c"; then nepon=$((nepon+1)); printf 'НЕ ПОЙМАН %s @ %s\n' "$s" "$c" >&2; fi
      done
    done
    nk="$(jq '[.stab_vhod[]|length]|add' "$B/source.json")"
    nf="$(ls -1 "$B"/stabs/ | wc -l | tr -d ' ')"
    nkeys="$(jq '.stab_vhod|keys|length' "$B/source.json")"
    [ "$nf" = "$nkeys" ] || { printf 'расхождение: stabs/ %s != stab_vhod %s\n' "$nf" "$nkeys" >&2; exit 2; }
    [ "$nk" = "$npriv" ] || { printf 'расхождение привязок: source %s != прогон %s\n' "$nk" "$npriv" >&2; exit 2; }
    printf 'sessii_136 --stabs: стабов %s, привязок %s, непойманных %d\n' "$nf" "$nk" "$nepon"
    [ "$nepon" -eq 0 ] || exit 1; exit 0 ;;
esac
