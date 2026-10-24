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
# 136 v2 (слово владельца 2026-10-24 14:58 UTC; Rev136-B1/B2): границы argv И-4 —
# корень ОТДЕЛЬНЫЙ аргумент до `--`, MSG непустой после, дописывание корня в MSG
# запрещено (a25/a26); fail-closed стража установки — strazh-net до exec, никакого
# собственного оракула двери (a27); fail-closed трассы — trassa-net-konfiga при
# отсутствии/неразборе конфига (b3/b4); предикат проектного режима паритета — по
# ОБЪЯВЛЕННОМУ слою профиля, потеря слоя не даёт молчаливого fallback (d4/d5).
# Круг-2 критика (FAIL r1, B1/B2/B3): корень — во ВСЕХ ветвях выбора MSG:
# --task-file a28, служебный бриф a29 (мутант m06 «корень убран только при
# task-file» проходил 41/41); финальный оракул — НАСТОЯЩИЙ страж на целом
# MSG даже когда построчный сканер двери пары не видит (a30, m07), нет node —
# strazh-net, а не свой разбор (a31, m08); слой под .harness/ с ЛЮБЫМ
# объявленным именем — проектный режим (d6, m09), нет jq / битый профиль —
# rc 2 именованный, не молчаливый fallback (d7/d8, m10).
# 136 v2-достройка (арбитраж /tmp/dev-harness-verify/orch/keep136v2/
# arbitration-136v2.md, РЕШЕНИЕ п.1/3а, 2026-10-24): клетка — на КАЖДЫЙ КЛАСС
# ВХОДА, которому frozen-текст назначает исход, из ОДНОЙ ТАБЛИЦЫ ОСЕЙ A–D
# (не «клетка на каждый мутант»): A источник MSG {task-file, NEXT_TASK непуст,
# NEXT_TASK пуст→бриф, нет→бриф} × {argv/байт-в-байт или структурно для брифа;
# формы пина 15×2 (k_pin_case); \r-пара × 2}; B страж {нет файла, нет node,
# нулевой файл}; C конфиг {нет, битый, нет jq при посеве}; D слой {профиля нет,
# вне .harness/, имя {стандарт, иное, вложенное} × {есть, потерян при приманке},
# нет jq, битый профиль}. Таблица — source.json:.osi (+.vne_osi — наследие вне
# осей); стартовая сверка ниже механически держит биекцию «строка ↔ клетка» и
# счёт клеток из таблицы. Мутанты n01–n05/n07 критика r2 → стабы s31–s36
# с адресными привязками к СВОИМ строкам таблицы; s37 — jq-молча (ось C).
# 136 v2-усиление (адверсарий impl-v1 FAIL, вердикт
# /tmp/dev-harness-verify/orch/keep136adv/contracts-136-impl-v1.md, B1/B2):
# «ПОД .harness/» у профиля — свойство ФАЙЛА (канонизация: `..` и symlink
# вне .harness/ = потерянный слой, rc 2 с именем объявленного пути;
# symlink внутрь .harness/ — проектный режим, контроль d14) — d12/d13;
# существующий trace.tsv обязан совпадать с конфигом установки
# (подмена/дубль/лишняя строка/read-only — trassa-rashozhdenie rc 1 до
# exec, файл не изменён; равен — повтор без записи, контроль c10) —
# c6–c10; стабы s38 (префикс-только) и s39–s41 (trace принимается/
# перезаписывается/дописывается).
# SIGPIPE-флейк c2 (критик r2, СОВЕТ): потребитель grep -q выходит раньше
# производителя → под pipefail ложное красное; все потребители mkt_brief —
# БЕЗ раннего -q (выход в переменную, затем полный проход grep).
# Мутация стаба может красить и клетки вне своей привязки (например, стабы
# двери без пина гасят и выдачу subagent-pin.sh) — привязка в source.json
# это МИНИМУМ гарантированной красноты, а не полный эффект мутации (замечание
# критика r1).
#
# Дверь исполняется из песочницы $SB (копия файла двери + двойник workshop рядом): дверь
# дословно разрешает(exec) $HERE/workshop — двойник пишет по одному аргументу в строку в
# $W/args.txt (границы argv — дополнительно NUL-разделённым $W/args0.bin, 136 v2/B1) и
# выходит 7; сообщение сессии = строки после литеральной строки «--».
#
# РЕЖИМЫ:
#   без ключей  — субъекты из дерева ветки: боли живы → rc 1;
#   --model     — честные модели model/ (дерево + точки правок контракта) → rc 0;
#   --stabs     — каждый стаб гасит свой субъект, его клетки ОБЯЗАНЫ покраснеть;
#                 rc 0 «стабов <N>, привязок <M>, непойманных 0» (счёт — из
#                 source.json, v2-усиление: 41/64; текст контракта frozen
#                 136/2 несёт исторические 37/54 своей версии).
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
# Дверь в мирах ставит пин версии через `omp --version` (125 И-5): omp этой
# станции живёт ВНЕ /usr/bin (пользовательский bin);_sessions-среда даёт
# $HOME зоны сессии, поэтому $HOME-пути не годятся — omp обязан быть в PATH
# запускающего (замер круга-2: «omp --version пуст»).
command -v omp >/dev/null 2>&1 || { printf 'нет omp в PATH запускающего\n' >&2; exit 2; }

subj() { case "$MODE" in
    model) printf '%s' "$B/model/$2" ;;
    stab)  printf '%s' "${STAB_DIR:-/NETU-STABA}/$2" ;;
    *)     printf '%s' "$ROOT/$1" ;; esac; }
DOOR="$(subj scripts/connect_project.sh connect_project.sh)"
MKT="$(subj scripts/make_task.sh make_task.sh)"
PAR="$(subj scripts/verify_ci_parity.sh verify_ci_parity.sh)"

W=""; FH=""; SEED=""; DVER_CONFIG=""; DVER_RC=""; DVER_NOGUARD=0; DVER_PATH=""; ARGS=()
mk_mir() { # mk_mir <слуг> [next] [harness]
  local slug="$1"
  W="/tmp/dev-harness-verify/sessii-136-$slug"
  FH="/tmp/dev-harness-fakehome-136/$slug"
  DVER_CONFIG=""; DVER_RC=""; DVER_NOGUARD=0; DVER_EMPTYGUARD=0; DVER_PATH=""; ARGS=()
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
  # DVER_CONFIG — управляемое содержимое конфига клетки, "NETU" — конфига нет
  # (136 v2/B2б); DVER_NOGUARD=1 — установка без стража (136 v2/B2а);
  # DVER_EMPTYGUARD=1 — страж ЕСТЬ, но нулевого размера (ось B, арбитраж 136v2).
  # Сообщение — после «--»; границы argv — NUL-файл args0.bin.
  local SB="$W/sb"; mkdir -p "$SB/scripts" "$SB/config" "$SB/.omp/extensions"
  cp "$DOOR" "$SB/scripts/connect_project.sh"
  [ "$DVER_NOGUARD" = 1 ] || cp "$GUARD" "$SB/.omp/extensions/path-guard.ts"
  [ "$DVER_EMPTYGUARD" = 1 ] && : > "$SB/.omp/extensions/path-guard.ts"
  if [ "${DVER_CONFIG:-}" = "NETU" ]; then :
  elif [ -n "${DVER_CONFIG:-}" ]; then printf '%s' "$DVER_CONFIG" > "$SB/config/agent_models.json"
  else cp "$ROOT/config/agent_models.json" "$SB/config/agent_models.json"; fi
  printf '#!/usr/bin/env bash\nfor a in "$@"; do printf "%%s\\n" "$a"; done > "%s"\nprintf "%%s\\0" "$@" > "%s"\nexit 7\n' "$W/args.txt" "$W/args0.bin" > "$SB/workshop"
  chmod +x "$SB/workshop"
  # 136 v2 (критик r1, B2/m08 и B3/m10): «нет node»/«нет jq» — ЖИВОЙ PATH, не
  # фикстурная заглушка: каталог символических ссылок на настоящие бинарники
  # системных каталогов, кроме исключённого имени. node этой станции живёт в
  # $HOME/.local/bin — в каталог попадает только /usr/bin и /bin, чтобы не
  # подтянуть node мимо фильтра именем из другого каталога (замер критика:
  # no-node-bin/no-jq-bin). Каталог общий на прогон, сбор идемпотентен.
  # DVER_PATH — подмена PATH клетки (a31: без node).
  # сбор ОДИН раз на дерево scratch (флаг-файл): ~1900 ссылок на каталог,
  # а run_dver зовётся десятки раз даже в одном прогоне
  if [ ! -e /tmp/dev-harness-verify/sessii-136-bin-bez-node/.gotovo ]; then
    mkdir -p /tmp/dev-harness-verify/sessii-136-bin-bez-node /tmp/dev-harness-verify/sessii-136-bin-bez-jq
    mk_bez_bin /tmp/dev-harness-verify/sessii-136-bin-bez-node node
    mk_bez_bin /tmp/dev-harness-verify/sessii-136-bin-bez-jq jq
    : > /tmp/dev-harness-verify/sessii-136-bin-bez-node/.gotovo
  fi
  if [ -n "${2:-}" ]; then
    env HOME="$FH" HARNESS_PROJECTS_DIR="$FH/projects" \
      S136_PSTATE_BASE="$FH/dev-harness-projects" PATH="${DVER_PATH:-$PATH}" \
      bash "$SB/scripts/connect_project.sh" --task-file "$2" "${1:-$SEED}" >"$W/dvor.out" 2>"$W/dvor.err"
  else
    env HOME="$FH" HARNESS_PROJECTS_DIR="$FH/projects" \
      S136_PSTATE_BASE="$FH/dev-harness-projects" PATH="${DVER_PATH:-$PATH}" \
      bash "$SB/scripts/connect_project.sh" "${1:-$SEED}" >"$W/dvor.out" 2>"$W/dvor.err"
  fi
  DVER_RC=$?
}
mk_bez_bin() { # $1 = каталог; $2 = исключаемое имя
  # источники: /usr/bin, /bin и каталог НАСТОЯЩЕГО omp (command -v): omp этой
  # станции живёт вне /usr/bin, а без него дверь не доходит до проверки node;
  # HOME сессии — зона, $HOME-пути не годятся (замер круга-2). Исключение —
  # по ИМЕНИ во всех каталогах.
  local d="$1" isklyuch="$2" f b src="/usr/bin/* /bin/*"
  command -v omp >/dev/null 2>&1 && src="$src $(dirname "$(command -v omp)")/*"
  for f in $src; do
    b="${f##*/}"
    [ "$b" = "$isklyuch" ] && continue
    [ -f "$f" ] && [ -x "$f" ] && ln -sf "$f" "$d/$b"
  done
}
dver_msg() { awk 'f{print} $0=="--"{f=1}' "$W/args.txt" 2>/dev/null; }
dver_argv() { ARGS=(); if [ -f "$W/args0.bin" ]; then mapfile -d '' -t ARGS < "$W/args0.bin"; fi; }
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
    [[ "$msg" == *"$txt"* ]] || return 1
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
k_a25() { # 136 v2 (Rev136-B1): границы argv — NUL-наблюдатель, не построчный
  # tail. Форма И-4: ровно [--yolo, KOREN, --, MSG]; KOREN — отдельный аргумент
  # ДО разделителя; MSG — выбранный текст + дверная пара, БАЙТ В БАЙТ: никакого
  # дописанного корня (мутант «корень в хвосте MSG» красен).
  mk_mir a25-argv-koren-do-razdelitelja next; run_dver; dver_argv
  local exp wt="$FH/dev-harness-projects/toy-proj/wt/wip-136-demo"
  exp="$(cat "$SEED/.harness/NEXT_TASK.md")
WORKTREE=$wt
BRANCH=wip/136/demo"
  [ "${#ARGS[@]}" = 4 ] && [ "${ARGS[0]}" = --yolo ] && [ "${ARGS[1]}" = "$SEED" ] \
    && [ "${ARGS[2]}" = -- ] && [ "${ARGS[3]}" = "$exp" ]; }
k_a26() { # 136 v2 положительный контроль: MSG многострочный и кончается ПУТЁМ
  # проекта — честная дверь передаёт его байт в байт (никакой «чистки хвоста»
  # и никакого отказа от задания с путём), корень — отдельным аргументом до --,
  # пин полного MSG извлекается настоящим стражем.
  mk_mir a26-ctrl-msg-zakanchivaetsya-putem
  printf 'Задание: релиз 1.3, две строки.\nФинальная строка — путь проекта: %s\n' "$SEED" > "$SEED/.harness/NEXT_TASK.md"
  run_dver; dver_argv
  local exp pin wt="$FH/dev-harness-projects/toy-proj/wt/wip-136-demo"
  exp="$(cat "$SEED/.harness/NEXT_TASK.md")
WORKTREE=$wt
BRANCH=wip/136/demo"
  { [ "${#ARGS[@]}" = 4 ] && [ "${ARGS[0]}" = --yolo ] && [ "${ARGS[1]}" = "$SEED" ] \
      && [ "${ARGS[2]}" = -- ] && [ "${ARGS[3]}" = "$exp" ]; } || return 1
  pin="$(epin "${ARGS[3]}" | jq -r '.worktree // empty')"
  [ "$pin" = "$wt" ]; }
k_a27() { # 136 v2 (Rev136-B2а): стража в установке нет — именованный отказ
  # strazh-net ДО exec; собственного оракула-замены у двери быть не должно
  # (мир без стража, отказ вместо запуска — мутант «свой pin_scan» красен).
  mk_mir a27-strazh-net; DVER_NOGUARD=1; run_dver
  [ "$DVER_RC" = 1 ] && grep -q 'strazh-net' "$W/dvor.err" && [ ! -e "$W/args.txt" ]; }
k_a28() { # 136 v2 (критик r1, B1/m06): ветвь --task-file — те же границы
  # argv, что и NEXT_TASK (a25): корень ОТДЕЛЬНЫЙ аргумент ДО --, MSG —
  # выбранный текст + дверная пара БАЙТ В БАЙТ; источник задания не меняет
  # форму запуска (мутант «корень убран только при task-file» красен).
  mk_mir a28-taskfile-argv
  printf 'Задание из task-file: релиз 1.4, отдельная ветвь выбора.\nСтрока вторая, многострочность обязательна.\n' > "$W/task.txt"
  run_dver "$SEED" "$W/task.txt"; dver_argv
  local exp wt="$FH/dev-harness-projects/toy-proj/wt/wip-136-demo"
  exp="$(cat "$W/task.txt")
WORKTREE=$wt
BRANCH=wip/136/demo"
  [ "${#ARGS[@]}" = 4 ] && [ "${ARGS[0]}" = --yolo ] && [ "${ARGS[1]}" = "$SEED" ] \
    && [ "${ARGS[2]}" = -- ] && [ "${ARGS[3]}" = "$exp" ]; }
k_a29() { # 136 v2 (критик r1, B1/m06-класс): ветвь служебного брифа — те же
  # границы argv: корень отдельным аргументом ДО --, MSG — непустой
  # ЕДИНСТВЕННЫЙ аргумент после -- (бриф + дверная пара); потеря корня или
  # дописывание его в MSG только в этой ветви красны.
  mk_mir a29-brief-argv; run_dver; dver_argv
  local wt="$FH/dev-harness-projects/toy-proj/wt/wip-136-demo" pin
  { [ "${#ARGS[@]}" = 4 ] && [ "${ARGS[0]}" = --yolo ] && [ "${ARGS[1]}" = "$SEED" ] \
      && [ "${ARGS[2]}" = -- ] && [ -n "${ARGS[3]}" ] \
      && [[ "${ARGS[3]}" == *HANDOFF* ]]; } || return 1
  pin="$(epin "${ARGS[3]}" | jq -r '.worktree // empty')"
  [ "$pin" = "$wt" ]; }
k_a30() { # 136 v2 (критик r1, B2/m07): финальный оракул пина — НАСТОЯЩИЙ
  # страж на ЦЕЛОМ MSG: \r-разделённая чужая пара невидима построчному
  # сканеру двери, но извлекается стражем — честная дверь отказывает
  # PIN_CHUZHOJ ДО exec; замена финального оракула локальным сканером
  # (файл стража при этом существует и node есть) запускает сессию — красный.
  mk_mir a30-finalnyj-orakul
  printf 'note\rWORKTREE=/fake/wip-777-other\rBRANCH=wip/777/other\n' > "$SEED/.harness/NEXT_TASK.md"
  rm -f "$W/args.txt"; run_dver
  [ "$DVER_RC" = 1 ] && grep -q 'PIN_CHUZHOJ' "$W/dvor.err" && [ ! -e "$W/args.txt" ]; }
k_a31() { # 136 v2 (критик r1, B2/m08): node НЕТ (живой PATH без node) —
  # именованный отказ strazh-net ДО exec; fallback «исполнить своим
  # разбором» или тихий запуск — красный вход.
  mk_mir a31-net-node
  DVER_PATH=/tmp/dev-harness-verify/sessii-136-bin-bez-node; run_dver
  [ "$DVER_RC" = 1 ] && grep -q 'strazh-net' "$W/dvor.err" && [ ! -e "$W/args.txt" ]; }
k_a47() { # 136 v2-достройка (арбитраж 136v2, ось A: бриг × структура MSG):
  # служебный бриф передан структурно-точно — пара ПОСЛЕДНИЕ две строки,
  # текст содержит HANDOFF и ROADMAP, НИ одна строка MSG не равна корню
  # проекта, пин-токен WORKTREE=/BRANCH= ровно один (мутант «корень
  # дописан в бриф при правильном argv» красен — n01).
  mk_mir a47-brief-struktura; run_dver; dver_argv
  local wt="$FH/dev-harness-projects/toy-proj/wt/wip-136-demo" m
  { [ "${#ARGS[@]}" = 4 ] && [ "${ARGS[0]}" = --yolo ] && [ "${ARGS[1]}" = "$SEED" ] \
      && [ "${ARGS[2]}" = -- ] && [ -n "${ARGS[3]}" ]; } || return 1
  m="${ARGS[3]}"
  printf '%s\n' "$m" | grep -Fq 'HANDOFF' || return 1
  printf '%s\n' "$m" | grep -Fq 'ROADMAP' || return 1
  [ "$(printf '%s\n' "$m" | tail -n 1)" = "BRANCH=wip/136/demo" ] || return 1
  [ "$(printf '%s\n' "$m" | tail -n 2 | head -n 1)" = "WORKTREE=$wt" ] || return 1
  printf '%s\n' "$m" | grep -Fqx "$SEED" && return 1
  [ "$(printf '%s\n' "$m" | grep -o 'WORKTREE=' | grep -c .)" = 1 ] \
    && [ "$(printf '%s\n' "$m" | grep -o 'BRANCH=' | grep -c .)" = 1 ] \
    && [ "$(epin "$m" | jq -r '.worktree // empty')" = "$wt" ]; }
k_a48() { # 136 v2-достройка (ось A, ТРЕТЬЕ состояние источника): NEXT_TASK.md
  # СУЩЕСТВУЕТ, но пуст — выбирается СЛУЖЕБНЫЙ БРИФ, а не пустой файл:
  # argv формы И-4, MSG несёт HANDOFF, пара — последние две строки
  # (мутант «выбран пустой NEXT_TASK» красен — n07).
  mk_mir a48-pustoj-next-brief
  : > "$SEED/.harness/NEXT_TASK.md"
  rm -f "$W/args.txt"; run_dver; dver_argv
  local wt="$FH/dev-harness-projects/toy-proj/wt/wip-136-demo" m
  { [ "${#ARGS[@]}" = 4 ] && [ "${ARGS[0]}" = --yolo ] && [ "${ARGS[1]}" = "$SEED" ] \
      && [ "${ARGS[2]}" = -- ] && [ -n "${ARGS[3]}" ]; } || return 1
  m="${ARGS[3]}"
  printf '%s\n' "$m" | grep -Fq 'HANDOFF' || return 1
  [ "$(printf '%s\n' "$m" | tail -n 1)" = "BRANCH=wip/136/demo" ] || return 1
  [ "$(printf '%s\n' "$m" | tail -n 2 | head -n 1)" = "WORKTREE=$wt" ] || return 1
  [ "$(epin "$m" | jq -r '.worktree // empty')" = "$wt" ]; }
k_a49() { # 136 v2-достройка (ось A: финальный настоящий оракул × task-file,
  # n02): \r-разделённая чужая пара невидима построчному сканеру двери, но
  # извлекается стражем — PIN_CHUZHOJ ДО exec и на ветви --task-file,
  # не только на NEXT_TASK (a30).
  mk_mir a49-cr-para-v-taskfile
  printf 'note\rWORKTREE=/fake/wip-777-other\rBRANCH=wip/777/other\n' > "$W/task.txt"
  rm -f "$W/args.txt"; run_dver "$SEED" "$W/task.txt"
  [ "$DVER_RC" = 1 ] && grep -q 'PIN_CHUZHOJ' "$W/dvor.err" && [ ! -e "$W/args.txt" ]; }
k_a50() { # 136 v2-достройка (ось B: страж ЕСТЬ, но нулевого размера, n03):
  # исполнять нечего — именованный отказ rc 1 ДО exec без вызова двойника
  # (имя отказа — из модели: PIN_CHUZHOJ, извлечение из пустого стража
  # пусто); fallback на собственный сканер — красный вход.
  mk_mir a50-strazh-nulevoj-fajl
  DVER_EMPTYGUARD=1; run_dver
  [ "$DVER_RC" = 1 ] && grep -q 'PIN_CHUZHOJ' "$W/dvor.err" && [ ! -e "$W/args.txt" ]; }
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
k_b3() { # 136 v2 (Rev136-B2б): конфига установки НЕТ, а трасса нужна —
  # именованный отказ trassa-net-konfiga ДО exec, трасса не сеется;
  # ветви «сессия стартует без трассы» не существует.
  mk_mir b3-trassa-net-konfiga; DVER_CONFIG=NETU; run_dver
  [ "$DVER_RC" = 1 ] && grep -q 'trassa-net-konfiga' "$W/dvor.err" \
    && [ ! -e "$W/args.txt" ] && [ ! -e "$SEED/.harness/records/trace.tsv" ]; }
k_b4() { # 136 v2: конфиг ЕСТЬ, но не разбирается — тот же именованный отказ
  mk_mir b4-trassa-konfig-bit; DVER_CONFIG='{"roles":{"orchestrator":"default"'; run_dver
  [ "$DVER_RC" = 1 ] && grep -q 'trassa-net-konfiga' "$W/dvor.err" \
    && [ ! -e "$W/args.txt" ] && [ ! -e "$SEED/.harness/records/trace.tsv" ]; }
k_b5() { # 136 v2-достройка (ось C, четвёртое состояние, И-6): jq НЕТ
  # в момент, когда нужен посев trace (живой PATH без jq для двери) —
  # ТОТ ЖЕ именованный отказ trassa-net-konfiga rc 1 ДО exec, трасса
  # не сеется нигде; ветви «старт без трассы, если нет jq» не существует.
  mk_mir b5-jq-net-possev
  DVER_PATH=/tmp/dev-harness-verify/sessii-136-bin-bez-jq; run_dver
  [ "$DVER_RC" = 1 ] && grep -q 'trassa-net-konfiga' "$W/dvor.err" \
    && [ ! -e "$W/args.txt" ] \
    && [ ! -e "$SEED/.harness/records/trace.tsv" ] \
    && [ ! -e "$SEED/.harness/registry/trace.tsv" ]; }
mkt_brief() {
  local mb; mb="$(mkt_dir)"
  env HOME="$FH" HARNESS_PROJECT_LAYER_ROOT="$SEED" \
    bash "$mb" --repo "$SEED" --role orchestrator --kind brief "$@" 2>"$W/mkt.err"
}
# (SIGPIPE, критик r2: производитель в конвейере, потребитель с ранним -q —
# под pipefail ложное красное; выход сперва в переменную, grep — полный проход).
k_c1() { mk_mir c1-p17-map; run_dver
  local out; out="$(mkt_brief)" || return 1
  grep -Fqx 'MAP: docs/ARCHITECTURE.md :: карта архитектуры проекта' <<<"$out" >/dev/null; }
k_c2() { mk_mir c2-p17-rules; run_dver
  local out; out="$(mkt_brief)" || return 1
  grep -Fqx 'RULES: docs/CODING-STANDARDS.md' <<<"$out" >/dev/null; }
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
    && grep -Fq "TRACE: role=orchestrator model=$model fallback=allowed" <<<"$out" \
    && ! grep -Fq 'model=zai/glm-5.3' <<<"$out"; }
k_c4() { mk_mir c4-kontrol; run_dver
  local out rc
  # трасса — оракул клетки (не дверь): судья critic + автор architect разных семей
  printf 'orchestrator\tzai/glm-5.3\tallowed\narchitect\tminimax/m1\tallowed\ncritic\tzai/glm-5.3\tallowed\n' > "$W/c4trace.tsv"
  local mb; mb="$(mkt_dir)"
  out="$(env HOME="$FH" HARNESS_PROJECT_LAYER_ROOT="$SEED" \
    bash "$mb" --repo "$SEED" --role critic --kind task --contract 777 \
      --model-trace "$W/c4trace.tsv" 2>"$W/mkt.err")"; rc=$?
  [ "$rc" -eq 0 ] && [ -n "$out" ] && ! grep -Fq 'MAP: docs/ARCHITECTURE.md' <<<"$out"; }
k_c5() { mk_mir c5-jeksplizit; run_dver
  local out; printf 'orchestrator\tanthropic/opus\tallowed\n' > "$W/explicit.tsv"
  out="$(mkt_brief --model-trace "$W/explicit.tsv")" \
    && grep -Fq 'TRACE: role=orchestrator model=anthropic/opus fallback=allowed' <<<"$out"; }
k_trassa_case() { # 136 v2-усиление (адверсарий B2, вердикт keep136adv):
  # существующий trace.tsv ≠ выведенному из конфига установки — источник
  # трассы один (И-6), рассогласование исключено по построению: подмена
  # (чужая модель / дубль строк / лишняя строка / read-only файл) —
  # именованный отказ trassa-rashozhdenie rc 1 ДО exec, файл не изменён
  # (И-7: ни молчаливое принятие, ни перезапись, ни дописывание); конфиг
  # клетки назначает оркестратору anthropic/claude-sonnet-5-5 (ожидание —
  # той же jq-цепочкой, что у двери: одна грамматика значений).
  local slug="$1" soderzh="$2" tr
  mk_mir "$slug"
  DVER_CONFIG='{"roles":{"orchestrator":"default"},"tiers":{"default":{"model":"@sonnet136"}},"models":{"sonnet136":"anthropic/claude-sonnet-5-5"}}'
  tr="$SEED/.harness/records/trace.tsv"
  printf '%b' "$soderzh" > "$tr"
  [ "$slug" = c9-trassa-readonly ] && chmod 444 "$tr"
  cp "$tr" "$W/tr.before"; rm -f "$W/args.txt"; run_dver
  [ "$DVER_RC" = 1 ] && grep -q 'trassa-rashozhdenie' "$W/dvor.err" \
    && [ ! -e "$W/args.txt" ] && cmp -s "$W/tr.before" "$tr"; }
k_c6()  { k_trassa_case c6-trassa-podmena-modeli 'orchestrator\tevil-model\tallowed\n'; }
k_c7()  { k_trassa_case c7-trassa-dubl-strok 'orchestrator\tfirst-model\tallowed\norchestrator\tsecond-model\tallowed\n'; }
k_c8()  { k_trassa_case c8-trassa-lishnjaja-stroka 'orchestrator\tanthropic/claude-sonnet-5-5\tallowed\ncritic\tminimax/m1\tallowed\n'; }
k_c9()  { k_trassa_case c9-trassa-readonly 'orchestrator\tevil-model\tallowed\n'; }
k_c10() { # 136 v2-усиление КОНТРОЛЬ (адверсарий B2): существующий trace.tsv
  # РАВЕН выведенному из конфига — повтор (И-7): без записи (байт-в-байт),
  # дверь идёт дальше — сессия поднимается (exec двойника, rc 7).
  mk_mir c10-kontrol-trassa-ravna
  DVER_CONFIG='{"roles":{"orchestrator":"default"},"tiers":{"default":{"model":"@sonnet136"}},"models":{"sonnet136":"anthropic/claude-sonnet-5-5"}}'
  printf 'orchestrator\tanthropic/claude-sonnet-5-5\tallowed\n' > "$SEED/.harness/records/trace.tsv"
  cp "$SEED/.harness/records/trace.tsv" "$W/tr10.before"
  rm -f "$W/args.txt"; run_dver
  [ "$DVER_RC" = 7 ] && [ -f "$W/args.txt" ] \
    && cmp -s "$W/tr10.before" "$SEED/.harness/records/trace.tsv"; }
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
k_d4() { # 136 v2 (Rev136-B2в) КОНТРОЛЬ: собственный профиль харнесса —
  # profilePath=registry/... ВНЕ .harness/, каталога .harness/ нет — режим
  # 020 дословно: исключения из корневого config/ci_parity_exceptions.txt, rc 0.
  # Ловит переносачный предикат «есть harness.project.json → проектный режим».
  mk_mir d4-harness-svoj-profil harness
  rm -rf "$SEED/.harness"
  jq -n '{schemaVersion:1,repoId:"toy-harness",language:"bash",
    workflowPaths:{contracts:"contracts",verdicts:"verdicts",registry:"registry",fixtures:"fixtures"},
    projectLayer:{version:"v1",profilePath:"registry/harness-project.json"}}' > "$SEED/harness.project.json"
  mkdir -p "$SEED/config"
  printf 'build = скрипт сборки тоя вне CI проекта, объявлён по причине клетки d4\nкоманда: npm run dev = команда релизного CI проекта, приёмкой пакета не является совсем\n' > "$SEED/config/ci_parity_exceptions.txt"
  env HOME="$FH" bash "$PAR" "$SEED" >"$W/par-d4.out" 2>&1; }
k_d5() { # 136 v2 (Rev136-B2в): у ПРОЕКТНОГО профиля (слой объявлен под
  # .harness/) потерян ОБЪЯВЛЕННЫЙ файл слоя — повреждённое проектное
  # состояние: rc 2 с именем объявленного пути; молчаливый fallback на
  # корневую ловушку config/ запрещён (ловушка в корне достаточна).
  mk_mir d5-sloi-poterjan; run_dver
  rm -f "$SEED/.harness/project-layer.json"
  mkdir -p "$SEED/config"
  printf 'build = скрипт сборки тоя вне CI проекта, объявлён по причине клетки d5\nкоманда: npm run dev = команда релизного CI проекта, приёмкой пакета не является совсем\n' > "$SEED/config/ci_parity_exceptions.txt"
  local rc=0
  env HOME="$FH" bash "$PAR" "$SEED" >"$W/par-d5.out" 2>&1 || rc=$?
  [ "$rc" = 2 ] && grep -Fq "$SEED/.harness/project-layer.json" "$W/par-d5.out"; }
k_d6() { # 136 v2 (критик r1, B3/m09): слой под .harness/ с ДРУГИМ
  # объявленным именем (.harness/alternate.json) — тоже ПРОЕКТНЫЙ режим:
  # исключения ТОЛЬКО профильные (пустые → rc 1 FAIL), корневая ловушка
  # config/ игнорируется; хардкод единственного имени слоя = зелёный
  # обход через корень (красный вход).
  mk_mir d6-sloi-drugoe-imja; run_dver
  [ -f "$SEED/.harness/project-layer.json" ] || return 1
  cp "$SEED/.harness/project-layer.json" "$SEED/.harness/alternate.json"
  jq '.projectLayer.profilePath=".harness/alternate.json"' "$SEED/harness.project.json" > "$W/harness.project.json"
  mv "$W/harness.project.json" "$SEED/harness.project.json"
  mkdir -p "$SEED/config"
  printf 'build = скрипт сборки тоя вне CI проекта, объявлён по причине клетки d6\nкоманда: npm run dev = команда релизного CI проекта, приёмкой пакета не является совсем\n' > "$SEED/config/ci_parity_exceptions.txt"
  : > "$SEED/.harness/records/ci_parity_exceptions.txt"
  local rc=0
  env HOME="$FH" bash "$PAR" "$SEED" >"$W/par-d6.out" 2>&1 || rc=$?
  [ "$rc" = 1 ] && grep -q 'FAIL' "$W/par-d6.out"; }
k_d7() { # 136 v2 (критик r1, B3/m10): профиль ЕСТЬ (проектный), jq НЕТ —
  # режим не выбирается молча: rc 2 именованный («jq нет»); зелёный
  # fallback на режим харнесса/корневые исключения — красный вход.
  mk_mir d7-bez-jq; run_dver
  mkdir -p "$SEED/config"
  printf 'build = скрипт сборки тоя вне CI проекта, объявлён по причине клетки d7\nкоманда: npm run dev = команда релизного CI проекта, приёмкой пакета не является совсем\n' > "$SEED/config/ci_parity_exceptions.txt"
  local rc=0
  env HOME="$FH" PATH="/tmp/dev-harness-verify/sessii-136-bin-bez-jq" \
    bash "$PAR" "$SEED" >"$W/par-d7.out" 2>&1 || rc=$?
  # «jq нет» — имя отказа среды (не «профиль не читается» — это отказ данных
  # d8); слаг мира d7-bez-jq содержит подстроку jq — grep по одному «jq»
  # принимал бы ЛЮБОЙ rc-2 отказ с именем пути (замер круга-2, мутант o9)
  [ "$rc" = 2 ] && grep -q 'NOT_IMPLEMENTED' "$W/par-d7.out" && grep -q 'jq нет' "$W/par-d7.out"; }
k_d8() { # 136 v2 (критик r1, B3): профиль НЕ разбирается — режим не
  # выбирается молча: rc 2 именованный с именем профиля; молчаливый
  # fallback на корневую ловушку config/ — красный вход.
  mk_mir d8-profil-bit; run_dver
  printf '{"schemaVersion":1,"repoId":"toy-proj", language' > "$SEED/harness.project.json"
  mkdir -p "$SEED/config"
  printf 'build = скрипт сборки тоя вне CI проекта, объявлён по причине клетки d8\nкоманда: npm run dev = команда релизного CI проекта, приёмкой пакета не является совсем\n' > "$SEED/config/ci_parity_exceptions.txt"
  local rc=0
  env HOME="$FH" bash "$PAR" "$SEED" >"$W/par-d8.out" 2>&1 || rc=$?
  [ "$rc" = 2 ] && grep -q 'NOT_IMPLEMENTED' "$W/par-d8.out" \
    && grep -Fq "$SEED/harness.project.json" "$W/par-d8.out"; }
k_d9() { # 136 v2-достройка (ось D: имя {иное} × {потерян при приманке},
  # n04): объявлен .harness/alternate.json, файла НЕТ, стандартный
  # .harness/project-layer.json лежит ПРИМАНКОЙ (сеет дверь) — проверка
  # существования по зашитому стандартному имени даёт зелёный обход;
  # честный гейт: rc 2 с именем ОБЪЯВЛЕННОГО пути, корневая ловушка
  # config/ не читается.
  mk_mir d9-sloi-drugoe-imja-poterjan; run_dver
  jq '.projectLayer.profilePath=".harness/alternate.json"' "$SEED/harness.project.json" > "$W/hp9.json"
  mv "$W/hp9.json" "$SEED/harness.project.json"
  rm -f "$SEED/.harness/alternate.json"
  mkdir -p "$SEED/config"
  printf 'build = скрипт сборки тоя вне CI проекта, объявлён по причине клетки d9\nкоманда: npm run dev = команда релизного CI проекта, приёмкой пакета не является совсем\n' > "$SEED/config/ci_parity_exceptions.txt"
  local rc=0
  env HOME="$FH" bash "$PAR" "$SEED" >"$W/par-d9.out" 2>&1 || rc=$?
  [ "$rc" = 2 ] && grep -Fq "$SEED/.harness/alternate.json" "$W/par-d9.out"; }
k_d10() { # 136 v2-достройка (ось D: имя {вложенное} × {есть}, n05):
  # объявлен и СУЩЕСТВУЕТ .harness/layers/custom.json — проектный режим
  # это свойство ПУТИ, не глубины: исключения ТОЛЬКО профильные (пустые
  # → rc 1 FAIL), корневая ловушка config/ игнорируется; перевод вложенного
  # слоя в режим харнесса — зелёный обход через корень (красный вход).
  mk_mir d10-sloi-vlozhennoe-imja; run_dver
  mkdir -p "$SEED/.harness/layers"
  cp "$SEED/.harness/project-layer.json" "$SEED/.harness/layers/custom.json"
  jq '.projectLayer.profilePath=".harness/layers/custom.json"' "$SEED/harness.project.json" > "$W/hp10.json"
  mv "$W/hp10.json" "$SEED/harness.project.json"
  mkdir -p "$SEED/config"
  printf 'build = скрипт сборки тоя вне CI проекта, объявлён по причине клетки d10\nкоманда: npm run dev = команда релизного CI проекта, приёмкой пакета не является совсем\n' > "$SEED/config/ci_parity_exceptions.txt"
  : > "$SEED/.harness/records/ci_parity_exceptions.txt"
  local rc=0
  env HOME="$FH" bash "$PAR" "$SEED" >"$W/par-d10.out" 2>&1 || rc=$?
  [ "$rc" = 1 ] && grep -q 'FAIL' "$W/par-d10.out"; }
k_d11() { # 136 v2-достройка (ось D: имя {вложенное} × {потерян}):
  # объявлен вложенный слой .harness/layers/custom.json, файла НЕТ —
  # rc 2 с именем ОБЪЯВЛЕННОГО пути (поведение d5 на вложенном имени);
  # молчаливый fallback на корневую ловушку / режим харнесса — красный вход.
  mk_mir d11-sloi-vlozhennoe-poterjan; run_dver
  jq '.projectLayer.profilePath=".harness/layers/custom.json"' "$SEED/harness.project.json" > "$W/hp11.json"
  mv "$W/hp11.json" "$SEED/harness.project.json"
  rm -f "$SEED/.harness/layers/custom.json"
  mkdir -p "$SEED/config"
  printf 'build = скрипт сборки тоя вне CI проекта, объявлён по причине клетки d11\nкоманда: npm run dev = команда релизного CI проекта, приёмкой пакета не является совсем\n' > "$SEED/config/ci_parity_exceptions.txt"
  local rc=0
  env HOME="$FH" bash "$PAR" "$SEED" >"$W/par-d11.out" 2>&1 || rc=$?
  [ "$rc" = 2 ] && grep -Fq "$SEED/.harness/layers/custom.json" "$W/par-d11.out"; }

k_d12() { # 136 v2-усиление (адверсарий B1, вердикт keep136adv): объявленный
  # слой «под .harness/» ВЫХОДИТ из .harness/ через `..` (файл существует
  # ВНЕ репозитория) — строковый префикс .harness/* не доказывает «под
  # .harness/»: канонизированный путь вне .harness/ — то же повреждённое
  # состояние, что потерянный слой (И-8): rc 2 с именем ОБЪЯВЛЕННОГО пути.
  # Достаточные исключения в records И корневая ловушка config/ (обе дали
  # бы rc 0 префиксной проверке — атака адверсария) честным гейтом
  # не читаются.
  mk_mir d12-sloi-dotdot-vyhod; run_dver
  jq '.projectLayer.profilePath=".harness/../../outside-layer.json"' "$SEED/harness.project.json" > "$W/hp12.json"
  mv "$W/hp12.json" "$SEED/harness.project.json"
  cp "$SEED/.harness/project-layer.json" "$FH/seed/outside-layer.json"
  printf 'build = скрипт сборки тоя вне CI проекта, объявлён по причине клетки d12\nкоманда: npm run dev = команда релизного CI проекта, приёмкой пакета не является совсем\n' > "$SEED/.harness/records/ci_parity_exceptions.txt"
  mkdir -p "$SEED/config"
  printf 'build = скрипт сборки тоя вне CI проекта, объявлён по причине клетки d12\nкоманда: npm run dev = команда релизного CI проекта, приёмкой пакета не является совсем\n' > "$SEED/config/ci_parity_exceptions.txt"
  local rc=0
  env HOME="$FH" bash "$PAR" "$SEED" >"$W/par-d12.out" 2>&1 || rc=$?
  [ "$rc" = 2 ] && grep -Fq "$SEED/.harness/../../outside-layer.json" "$W/par-d12.out"; }
k_d13() { # 136 v2-усиление (адверсарий B1, вердикт keep136adv): объявленный
  # слой — symlink ПОД .harness/ (.harness/layer-link.json) на файл ВНЕ
  # .harness/ и вне репозитория: `-f` по symlink'у истинен и префикс
  # .harness/* истинен, но файл слоя живёт вне .harness/ — rc 2 с именем
  # ОБЪЯВЛЕННОГО пути; проектный режим по строковому префиксу = обход
  # из вердикта адверсария (rc 0 по достаточным records-исключениям).
  mk_mir d13-sloi-symlink-naruzhu; run_dver
  jq '.projectLayer.profilePath=".harness/layer-link.json"' "$SEED/harness.project.json" > "$W/hp13.json"
  mv "$W/hp13.json" "$SEED/harness.project.json"
  mkdir -p "$FH/vne"; cp "$SEED/.harness/project-layer.json" "$FH/vne/layer.json"
  ln -s "$FH/vne/layer.json" "$SEED/.harness/layer-link.json"
  printf 'build = скрипт сборки тоя вне CI проекта, объявлён по причине клетки d13\nкоманда: npm run dev = команда релизного CI проекта, приёмкой пакета не является совсем\n' > "$SEED/.harness/records/ci_parity_exceptions.txt"
  mkdir -p "$SEED/config"
  printf 'build = скрипт сборки тоя вне CI проекта, объявлён по причине клетки d13\nкоманда: npm run dev = команда релизного CI проекта, приёмкой пакета не является совсем\n' > "$SEED/config/ci_parity_exceptions.txt"
  local rc=0
  env HOME="$FH" bash "$PAR" "$SEED" >"$W/par-d13.out" 2>&1 || rc=$?
  [ "$rc" = 2 ] && grep -Fq "$SEED/.harness/layer-link.json" "$W/par-d13.out"; }
k_d14() { # 136 v2-усиление КОНТРОЛЬ (адверсарий B1): symlink ПОД .harness/
  # на файл ВНУТРИ .harness/ (.harness/layers/custom.json) —
  # канонизированный путь остаётся под .harness/: ПРОЕКТНЫЙ режим
  # (пустой перечень → rc 1 FAIL), корневая ловушка config/ игнорируется;
  # канонизация не запрещает честную индирекцию внутри .harness/ (И-8:
  # «ПОД .harness/» — свойство файла, не строкового префикса).
  mk_mir d14-kontrol-symlink-vnutri; run_dver
  mkdir -p "$SEED/.harness/layers"
  cp "$SEED/.harness/project-layer.json" "$SEED/.harness/layers/custom.json"
  jq '.projectLayer.profilePath=".harness/layer-link.json"' "$SEED/harness.project.json" > "$W/hp14.json"
  mv "$W/hp14.json" "$SEED/harness.project.json"
  ln -s "$SEED/.harness/layers/custom.json" "$SEED/.harness/layer-link.json"
  mkdir -p "$SEED/config"
  printf 'build = скрипт сборки тоя вне CI проекта, объявлён по причине клетки d14\nкоманда: npm run dev = команда релизного CI проекта, приёмкой пакета не является совсем\n' > "$SEED/config/ci_parity_exceptions.txt"
  : > "$SEED/.harness/records/ci_parity_exceptions.txt"
  local rc=0
  env HOME="$FH" bash "$PAR" "$SEED" >"$W/par-d14.out" 2>&1 || rc=$?
  [ "$rc" = 1 ] && grep -q 'FAIL' "$W/par-d14.out"; }
ORDER="a1-p6-hvost a2-p6-brief-defolt a3-p3-pin-v-soobshchenii a4-p3-zapis a5-p12-agent a6-p11-subagent-pin a7-granica-unpinned a8-pin-block a9-pin-inline a10-pin-duplicate a11-pin-mixed a12-pin-reverse a13-pin-foreign-wt a14-pin-foreign-br a15-pin-extra-wt a16-pin-extra-br a17-pin-half-wt a18-pin-empty-br a19-pin-inline-mixed a20-pin-delimiters a21-pin-taskfile-duplicate a22-pin-taskfile-inline a23-pin-live-foreign a24-pin-inline-foreign a25-argv-koren-do-razdelitelja a26-ctrl-msg-zakanchivaetsya-putem a27-strazh-net a28-taskfile-argv a29-brief-argv a30-finalnyj-orakul a31-net-node a34-pin-taskfile-block a35-pin-taskfile-mixed a36-pin-taskfile-reverse a37-pin-taskfile-foreign-wt a38-pin-taskfile-foreign-br a39-pin-taskfile-extra-wt a40-pin-taskfile-extra-br a41-pin-taskfile-half-wt a42-pin-taskfile-empty-br a43-pin-taskfile-inline-mixed a44-pin-taskfile-delimiters a45-pin-taskfile-live-foreign a46-pin-taskfile-inline-foreign a47-brief-struktura a48-pustoj-next-brief a49-cr-para-v-taskfile a50-strazh-nulevoj-fajl b1-povtor b2-p10-raskladka b3-trassa-net-konfiga b4-trassa-konfig-bit b5-jq-net-possev c1-p17-map c2-p17-rules c3-p5-trassa-defolt c4-kontrol-filtr c5-kontrol-jeksplizit c6-trassa-podmena-modeli c7-trassa-dubl-strok c8-trassa-lishnjaja-stroka c9-trassa-readonly c10-kontrol-trassa-ravna d1-p10-isklyuchenie d2-kontrol-dom d3-kontrol-koren d4-harness-svoj-profil d5-sloi-poterjan d6-sloi-drugoe-imja d7-bez-jq d8-profil-bit d9-sloi-drugoe-imja-poterjan d10-sloi-vlozhennoe-imja d11-sloi-vlozhennoe-poterjan d12-sloi-dotdot-vyhod d13-sloi-symlink-naruzhu d14-kontrol-symlink-vnutri"
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
  a25-argv-koren-do-razdelitelja) k_a25 ;; a26-ctrl-msg-zakanchivaetsya-putem) k_a26 ;; a27-strazh-net) k_a27 ;;
  a28-taskfile-argv) k_a28 ;; a29-brief-argv) k_a29 ;; a30-finalnyj-orakul) k_a30 ;; a31-net-node) k_a31 ;;
  a34-pin-taskfile-block) k_pin_case a34 taskfile block pass ;;
  a35-pin-taskfile-mixed) k_pin_case a35 taskfile mixed PIN_CHUZHOJ ;;
  a36-pin-taskfile-reverse) k_pin_case a36 taskfile reverse PIN_CHUZHOJ ;;
  a37-pin-taskfile-foreign-wt) k_pin_case a37 taskfile foreign-wt PIN_CHUZHOJ ;;
  a38-pin-taskfile-foreign-br) k_pin_case a38 taskfile foreign-br PIN_CHUZHOJ ;;
  a39-pin-taskfile-extra-wt) k_pin_case a39 taskfile extra-wt PIN_CHUZHOJ ;;
  a40-pin-taskfile-extra-br) k_pin_case a40 taskfile extra-br PIN_CHUZHOJ ;;
  a41-pin-taskfile-half-wt) k_pin_case a41 taskfile half-wt PIN_CHUZHOJ ;;
  a42-pin-taskfile-empty-br) k_pin_case a42 taskfile empty-br PIN_CHUZHOJ ;;
  a43-pin-taskfile-inline-mixed) k_pin_case a43 taskfile inline-mixed PIN_DUBL ;;
  a44-pin-taskfile-delimiters) k_pin_case a44 taskfile delimiters pass ;;
  a45-pin-taskfile-live-foreign) k_pin_case a45 taskfile live-foreign PIN_CHUZHOJ ;;
  a46-pin-taskfile-inline-foreign) k_pin_case a46 taskfile inline-foreign PIN_CHUZHOJ ;;
  a47-brief-struktura) k_a47 ;; a48-pustoj-next-brief) k_a48 ;;
  a49-cr-para-v-taskfile) k_a49 ;; a50-strazh-nulevoj-fajl) k_a50 ;;
  b1-povtor) k_b1 ;; b2-p10-raskladka) k_b2 ;;
  b3-trassa-net-konfiga) k_b3 ;; b4-trassa-konfig-bit) k_b4 ;; b5-jq-net-possev) k_b5 ;;
  c1-p17-map) k_c1 ;; c2-p17-rules) k_c2 ;; c3-p5-trassa-defolt) k_c3 ;;
  c4-kontrol-filtr) k_c4 ;; c5-kontrol-jeksplizit) k_c5 ;;
  c6-trassa-podmena-modeli) k_c6 ;; c7-trassa-dubl-strok) k_c7 ;;
  c8-trassa-lishnjaja-stroka) k_c8 ;; c9-trassa-readonly) k_c9 ;;
  c10-kontrol-trassa-ravna) k_c10 ;;
  d4-harness-svoj-profil) k_d4 ;; d5-sloi-poterjan) k_d5 ;;
  d6-sloi-drugoe-imja) k_d6 ;; d7-bez-jq) k_d7 ;; d8-profil-bit) k_d8 ;;
  d9-sloi-drugoe-imja-poterjan) k_d9 ;; d10-sloi-vlozhennoe-imja) k_d10 ;; d11-sloi-vlozhennoe-poterjan) k_d11 ;;
  d12-sloi-dotdot-vyhod) k_d12 ;; d13-sloi-symlink-naruzhu) k_d13 ;; d14-kontrol-symlink-vnutri) k_d14 ;;
  d1-p10-isklyuchenie) k_d1 ;; d2-kontrol-dom) k_d2 ;; d3-kontrol-koren) k_d3 ;; esac; }

# ── таблица осей A–D — единственный источник счёта (арбитраж 136v2 п.1) ──────
# source.json:.osi — строки осей A–D (источник MSG × установка стража × конфиг
# трассы × объявленный слой), .vne_osi — наследие v1/v2 вне осей. Механическая
# биекция «строка таблицы ↔ клетка»: множество строк == множество kletki ==
# множество ORDER; счёт клеток кодом = len(osi)+len(vne_osi).
_osi_diff="$( { printf '%s\n' $ORDER
  jq -r '(.osi[].kletka), (.vne_osi[])' "$B/source.json"; } | LC_ALL=C sort | uniq -u )"
[ -z "$_osi_diff" ] || { printf 'таблица осей ≠ клетки (симметричная разница):%s\n' "$_osi_diff" >&2; exit 2; }
[ "$(printf '%s\n' $ORDER | grep -c .)" = "$(jq '(.osi|length)+(.vne_osi|length)' "$B/source.json")" ] \
  || { printf 'счёт клеток ≠ таблица осей (osi+vne_osi)\n' >&2; exit 2; }

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
