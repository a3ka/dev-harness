#!/usr/bin/env bash
# Честная модель сборки контекста make_task (контракт 095, круг 2) — носитель
# ГРАММАТИКИ субъекта scripts/make_task.sh: субъект обязан принимать этот CLI и
# эти коды/фразы дословно (детали реализации — implementer; ПРОДУКТ потребляет
# профиль через scripts/profile_resolver.sh — модель несёт ту же семантику
# слияния слоёв напрямую, судится переход профиль→выдача, не библиотека).
# Модель — не продукт: живёт в семье батареи, используется режимом --model
# раннера и стаб-паком battery_stubs.sh (порчи строятся ИЗ этого файла; маркеры
# в комментариях отмечают единственные строки-носители инвариантов — НЕ
# удалять и НЕ переименовывать без синхронной правки стаб-пака).
#
# CLI:
#   dover.sh --repo R --role ROLE [--kind task|brief] [--contract NNN]
#            [--task-file F] [--model-trace F] [--author-role R2]
#   ROLE ∈ orchestrator|architect|critic|implementer|implementer-glm|adversary|reviewer|arbiter
#   kind=task (умолчание) — задачный пак по контракту NNN; kind=brief —
#   стартовый контекст (orch_brief): только оркестратору, без секций контракта.
#
# Отказы rc 1 «ОТКАЗ: …» (якоря клеток, grep -F): нет свидетельства модели /
# свидетельство не той роли / профиль репо не найден /
# нет файла слоя проекта / пин слоя проекта расходится / нет карты контекста /
# источник недоступен / контракт не заморожен / нет выданного задания /
# зона слишком широкая / режь задачу / брифинг только оркестратору /
# workflowPaths вне репо (отказ ЕДИНОГО резолвера путей 996 при снятии
# предусловий И-16). rc 2 — NOT_IMPLEMENTED. Отказ печатается ДО выдачи пака:
# частичного stdout у отказа нет (И-3: без молчаливого усечения).
#
# Инварианты контракта 095: И-0 грамматики, И-1 правила проекта не харнеса,
# И-2 манифест разрешается, И-3 потерянная ссылка точна, И-4 роль меняет
# выдачу, И-5 зоны из frozen-блоба, И-6 режим до заморозки, И-7 ревьюер судит
# выданное + обязательный след автора в трассе (контракт 166: выбор модели
# судьи свободен — совпадение с автором не причина отказа),
# И-8 свидетельство модели, И-9 бюджет вклейки, И-10 ADR и уроки по области,
# И-11 происхождение фрагментов, И-12 брифинг — содержательный отдельный
# режим, И-13 дословная доставка КОНТЕКСТ/§Существующее, И-14 два слоя
# профиля → выдача, И-16 предусловия брифа строками с rc (v2 Б3:
# фактический rc стража и первая строка его stderr против NOT_RUN,
# применимость по эффективным путям 996, бюджеты всего пути пробы).
set -uo pipefail
TAB="$(printf '\t')"

die() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
ni()  { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }
command -v git >/dev/null 2>&1 || ni "нет git"
command -v sha256sum >/dev/null 2>&1 || ni "нет sha256sum"
command -v awk >/dev/null 2>&1 || ni "нет awk"
command -v jq >/dev/null 2>&1 || ni "нет jq"

usage() { printf 'usage: dover.sh --repo R --role ROLE [--kind task|brief] [--contract NNN] [--task-file F] [--model-trace F] [--author-role R2]\n' >&2; exit 1; }

REPO=""; ROLE=""; KIND="task"; CONTRACT=""; TASKFILE=""; TRACE=""; AUTHOR_ROLE_ARG=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:?}"; shift 2 ;;
    --role) ROLE="${2:?}"; shift 2 ;;
    --kind) KIND="${2:?}"; shift 2 ;;
    --contract) CONTRACT="${2:?}"; shift 2 ;;
    --task-file) TASKFILE="${2:?}"; shift 2 ;;
    --model-trace) TRACE="${2:?}"; shift 2 ;;
    --author-role) AUTHOR_ROLE_ARG="${2:?}"; shift 2 ;;
    *) usage ;;
  esac
done
[ -n "$REPO" ] && [ -n "$ROLE" ] || usage
[ -d "$REPO" ] || die "репозитория нет: $REPO"
case "$ROLE" in orchestrator|architect|critic|implementer|implementer-glm|adversary|reviewer|arbiter) ;; *) die "роль вне алфавита: $ROLE" ;; esac # t95-m40
LOGICAL_ROLE="$ROLE"
[ "$ROLE" != "implementer-glm" ] || LOGICAL_ROLE="implementer" # t95-m41
case "$KIND" in task|brief) ;; *) die "kind вне алфавита: $KIND" ;; esac

# ── И-12: брифинг — отдельный режим, только оркестратору ────────────────────
SKIP_TASK=0
if [ "$KIND" = "brief" ]; then [ "$ROLE" = "orchestrator" ] || die "брифинг только оркестратору"; SKIP_TASK=1; fi # t95-m12

# ── И-8: роль/модель/fallback подтверждаются трассой; отсутствие — не успех ─
AUTHOR_ROLE="$AUTHOR_ROLE_ARG"
if [ -z "$AUTHOR_ROLE" ]; then
  case "$ROLE" in reviewer) AUTHOR_ROLE="implementer" ;; critic) AUTHOR_ROLE="architect" ;; *) AUTHOR_ROLE="" ;; esac
fi
[ -z "$AUTHOR_ROLE" ] || case "$AUTHOR_ROLE" in orchestrator|architect|critic|implementer|adversary|reviewer|arbiter) ;; *) die "автор вне алфавита: $AUTHOR_ROLE" ;; esac
TRACE_LINE=""; AUTHOR_MODEL=""
if [ -z "$TRACE" ] || [ ! -f "$TRACE" ]; then die "нет свидетельства модели: $ROLE"; fi
ROLE_TRACE="$ROLE" # t95-m42
while IFS="$TAB" read -r r m fb; do
  [ -z "${r:-}" ] && continue
  case "$fb" in allowed|denied) ;; *) die "трасса: грамматика" ;; esac
  if [ "$r" = "$ROLE_TRACE" ]; then TRACE_LINE="TRACE: role=$r model=$m fallback=$fb"; fi # t95-m8
  [ -n "$AUTHOR_ROLE" ] && [ "$r" = "$AUTHOR_ROLE" ] && AUTHOR_MODEL="$m"
done < "$TRACE"
[ -n "$TRACE_LINE" ] || die "свидетельство не той роли: $ROLE"

# ── Б2/И-7: автор и судья — след автора обязателен (контракт 166) ───────────
# Модель судьи выбирается назначением роли: совпадение с моделью, провайдером
# или семейством автора не причина отказа. Обязателен СЛЕД автора в трассе.
if [ "$ROLE" = "reviewer" ] || [ "$ROLE" = "critic" ]; then
  [ -n "$AUTHOR_MODEL" ] || die "свидетельство не той роли: $AUTHOR_ROLE" # t95-m17
fi

# ── И-14: настоящий профиль — два слоя 054, contextPack слит семантикой схемы ─
RJ="$REPO/harness.project.json"
[ -f "$RJ" ] || die "профиль репо не найден: harness.project.json"
jq -e . "$RJ" >/dev/null 2>&1 || die "файл не JSON: $RJ"
PP="$(jq -r '.projectLayer.profilePath // "registry/harness-project.json"' "$RJ")"
LROOT="${HARNESS_PROJECT_LAYER_ROOT:-$REPO}"
PJ="$LROOT/${PP#./}"
[ -f "$PJ" ] || die "нет файла слоя проекта: $PJ"
jq -e . "$PJ" >/dev/null 2>&1 || die "файл не JSON: $PJ"
PIN="$(jq -r '.projectLayer.version // ""' "$RJ")"
LV="$(jq -r '.version // ""' "$PJ")"
[ "$PIN" = "$LV" ] || die "пин слоя проекта расходится: репо пинит '$PIN', слой несёт '$LV'"
CP="$(jq -s '(.[1].defaults.contextPack // {}) * (.[0].contextPack // {})' "$RJ" "$PJ")" # t95-m14: defaults слоя проекта × репо-слой, массивы — юнит-слияние

# ── карта проекта из contextPack (И-1: правила проекта, не харнеса) ─────────
NROWS="$(printf '%s' "$CP" | jq -r '(.rows // []) | length')"
[ "$NROWS" -gt 0 ] || die "нет карты контекста: contextPack"
MAP_LINES=""; RULES_LINES=""; REUSE_LINES=""; MAP_MAN=""
while IFS="$TAB" read -r kind path roles mnd why; do
  [ -z "${kind:-}" ] && continue
  case "$kind" in map|rules|reuse) ;; *) die "карта: грамматика: kind $kind" ;; esac
  case "$path" in ''|*[!A-Za-z0-9._/-]*) die "карта: грамматика: путь $path" ;; esac
  case "$mnd" in true|false) ;; *) die "карта: грамматика: обязательность $mnd" ;; esac
  for rr in ${roles//,/ }; do
    case "$rr" in orchestrator|architect|critic|implementer|adversary|reviewer|arbiter) ;; *) die "карта: грамматика: роль $rr" ;; esac
  done
  case ",$roles," in *",$LOGICAL_ROLE,"*) ;; *) continue ;; esac
  if [ ! -f "$REPO/$path" ]; then
    if [ "$mnd" = "true" ]; then die "источник недоступен: $path"; fi # t95-m3
    continue
  fi
  case "$kind" in
    map)   MAP_LINES="${MAP_LINES}MAP: $path :: $why
" ;;
    rules) RULES_LINES="${RULES_LINES}RULES: $path
" ;;
    reuse) REUSE_LINES="${REUSE_LINES}REUSE: $path
" ;;
  esac
  om="mandatory"; [ "$mnd" = "false" ] && om="optional"
  MAP_MAN="${MAP_MAN}${kind}${TAB}${path}${TAB}${om}${TAB}profile
"
  : # t95-m1: документы харнеса в RULES проекта не попадают
done < <(printf '%s' "$CP" | jq -r '.rows[]? | [.kind, .path, .roles, (.mandatory|tostring), (.why // "")] | @tsv')

# ── скилы: видимость процедурных скилов по роли (слово владельца 13.4) ──────
SKILLS=""
case "$LOGICAL_ROLE" in
  architect)   SKILLS="SKILL: grilling
SKILL: writing-for-agents
SKILL: tdd
" ;;
  implementer) SKILLS="SKILL: tdd
SKILL: diagnosing-bugs
" ;; # t95-m4: матрица видимости по роли — implementer НЕ получает grilling
  adversary)   SKILLS="SKILL: diagnosing-bugs
" ;;
esac

CONTEXT_SEC=""; ZONES_SEC=""; LESSONS_SEC=""; LESSONS_MAN=""; TASK_SEC=""; TASK_MAN=""; CTX_MAN=""
ZONE_PATHS=""
GOAL_SEC=""; WORK_SEC=""; DEC_SEC=""; HEALTH_SEC=""
ADRP="$(printf '%s' "$CP" | jq -r '.adrPath // ""')"
LLP="$(printf '%s' "$CP" | jq -r '.lessonsPath // ""')"
ADR_SEC=""; ADR_MAN=""
if [ -n "$ADRP" ] && [ -d "$REPO/$ADRP" ]; then ADR_MAN="adr${TAB}${ADRP}${TAB}optional${TAB}profile
"; fi

# ── ADR-носитель: decisions/NNN-slug.md, шапка решение:/область:/статус: ────
# Действующие = статус отсутствует или «принято»; предложено/заменено не
# выдаются; ОБЛАСТЬ — метки path-glob | роль:<роль>; потолок задачи — 8.
_adr_load() {  # печатает: id TAB область TAB решение (только действующие)
  local f id st area res line
  for f in $(LC_ALL=C ls "$REPO/$ADRP" 2>/dev/null | LC_ALL=C sort); do
    case "$f" in *.md) ;; *) continue ;; esac
    id="${f%%-*}"
    case "$id" in ''|*[!0-9]*) die "ADR: грамматика: $f" ;; esac
    st="принято"; area=""; res=""
    while IFS= read -r line; do
      case "$line" in
        'статус: '*) st="${line#статус: }" ;;
        'область: '*) area="${line#область: }" ;;
        'решение: '*) res="${line#решение: }" ;;
      esac
    done <"$REPO/$ADRP/$f"
    case "$st" in принято|предложено|заменено*) ;; *) die "ADR: грамматика: статус $st" ;; esac
    case "$st" in принято) ;; *) continue ;; esac # t95-m16: предложено/заменено не выдаются
    [ -n "$res" ] || die "ADR: грамматика: решение пусто: $f"
    printf '%s\t%s\t%s\n' "$id" "$area" "$res"
  done
}

# ── И-16 (v2 Б3, слово владельца 2026-11-17): PRECOND — предусловия мира ────
# ── ВХОДА строками с rc; пробы запускает ТОЛЬКО бриф — задачный пак их не ───
# ── запускает вовсе. Замкнутый перечень трёх проб в фиксированном порядке: ──
# sync_main, plan_gate, plan_slice. Снятие — ДО создания placeholder ci.yml,
# как HEALTH: мир на момент ВХОДА. Красная проба НЕ роняет бриф: секция несёт
# факты, решение за сессией. Семантика строки (арбитраж 095-granica-v2):
#   фактический rc — проба ИСПОЛНИЛАСЬ: для plan_gate/plan_slice это rc
#     вызванного стража и первая строка ЕГО stderr (не объединённого потока;
#     нормализация TAB → пробел, ≤120 символов); именованный отказ стража об
#     источнике (PLAN_SOURCE_UNAVAILABLE, «план недоступен…») — ФАКТИЧЕСКИЙ
#     rc, НЕ NOT_RUN; для sync_main — rc/behind/ahead самой пробы;
#   NOT_RUN rc=2 — обёртка НЕ исполнила пробу: нет инструмента стража, нет
#     origin/main (sync_main), объявленная неприменимость, истечение бюджета;
#     перечень причин замкнут: {нет origin/main, нет scripts/check_plan.sh,
#     нет scripts/orch_plan_slice.sh, проектные workflowPaths вне стража,
#     бюджет <N>с, проба не исполнилась}.
# Применимость стражей 084/182 — по ЭФФЕКТИВНЫМ путям ЕДИНОГО резолвера 996
# (project_paths_resolve): канонические корневые registry/, ROADMAP.md и
# HANDOFF.md; наследуемый слой проекта или state вне корня уводит пробы в
# NOT_RUN, не в ложное красное и не в станционную зелень. Отказ резолвера —
# отказ двери «workflowPaths вне репо» ДО пака (канон строгого вызова
# make_task), НЕ выдуманная станционная строка. Бюджет пробы (3/5/5 с)
# ограничивает ВЕСЬ путь пробы, включая подготовку ref: неуспех подготовки
# не висит мимо таймера.
PRECOND_SEC=""
if [ "$KIND" = "brief" ]; then # t95-m61: пробы предусловий — только брифу; задачный пак их не запускает
  _pc_root="${CP095_ROOT:-$(cd "$(dirname "$0")/../../.." 2>/dev/null && pwd)}"
  _pc_repo_abs="$(cd "$REPO" 2>/dev/null && pwd -P)"
  _pc_add() { PRECOND_SEC="${PRECOND_SEC}PRECOND: $1 rc=$2${3:+ $3}
"; }
  _pc_tail() { printf '%s\n' "$1" | LC_ALL=C.UTF-8 awk 'NR==1 { gsub(/\t/, " "); print substr($0, 1, 120); exit }'; }
  # ЕДИНЫЙ резолвер путей 996 — модель зовёт его сама (пакет уже вычислил его
  # строгим вызовом; копий гард/слияния здесь нет)
  if ! _pc_json="$( NEXT_ID_LIB=1; cd "$_pc_root" 2>/dev/null || exit 1
      # shellcheck disable=SC1091
      . ./scripts/next_id.sh 2>/dev/null || exit 1
      [ "$(type -t project_paths_resolve)" = "function" ] || exit 1
      project_paths_resolve "$_pc_repo_abs" )"; then
    die "workflowPaths вне репо" # t95-m57: отказ резолвера — отказ двери, не станционная зелень
  fi
  _pc_reg="$(printf '%s' "$_pc_json" | jq -r '.registry')"
  _pc_canon=1
  [ "$_pc_reg" = "$_pc_repo_abs/registry" ] || _pc_canon=0 # t95-m55: эффективный registry слияния слоёв, не сырой ключ репо-JSON
  _pc_rm="$(printf '%s' "$_pc_json" | jq -r '.roadmap')"
  _pc_ho="$(printf '%s' "$_pc_json" | jq -r '.handoff')"
  [ "$_pc_rm" = "$_pc_repo_abs/ROADMAP.md" ] && [ "$_pc_ho" = "$_pc_repo_abs/HANDOFF.md" ] || _pc_canon=0 # t95-m56: state вне корня — вне домена стражей 084/182
  # (1) sync_main — локальный ref origin/main против HEAD, без сети; ВЕСЬ путь
  # пробы (включая подготовку ref) — под бюджетом 3 с
  _pc_ab=""; _pc_rc=0
  _pc_ab="$(timeout 3 git -C "$REPO" rev-list --left-right --count origin/main...HEAD 2>/dev/null)" || _pc_rc=$? # t95-m50: фактический rc и behind/ahead самой пробы
  if [ "$_pc_rc" -eq 0 ]; then
    _pc_add sync_main 0 "behind=${_pc_ab%%$TAB*} ahead=${_pc_ab#*$TAB}"
  elif [ "$_pc_rc" -eq 124 ]; then
    _pc_add sync_main 2 "NOT_RUN бюджет 3с" # t95-m59: истечение бюджета — честный NOT_RUN, не зелёное
  elif ! timeout 3 git -C "$REPO" rev-parse --verify -q origin/main >/dev/null 2>&1; then
    _pc_add sync_main 2 "NOT_RUN нет origin/main"
  else
    _pc_add sync_main 2 "NOT_RUN проба не исполнилась"
  fi
  # (2) plan_gate — страж 084 по РАБОЧЕМУ дереву цели
  if [ "$_pc_canon" = 0 ]; then
    _pc_add plan_gate 2 "NOT_RUN проектные workflowPaths вне стража"
  elif [ ! -f "$_pc_root/scripts/check_plan.sh" ]; then
    _pc_add plan_gate 2 "NOT_RUN нет scripts/check_plan.sh"
  else
    _pc_o="$(mktemp 2>/dev/null || printf '/tmp/t95pc.%s.%s' "$$" "$RANDOM")"; _pc_e="${_pc_o}.e"
    _pc_rc=0
    timeout 5 bash "$_pc_root/scripts/check_plan.sh" --root "$REPO" >"$_pc_o" 2>"$_pc_e" || _pc_rc=$? # t95-m52: фактический rc стража 084
    if [ "$_pc_rc" -eq 124 ]; then
      _pc_add plan_gate 2 "NOT_RUN бюджет 5с" # t95-m58: истечение бюджета стража — честный NOT_RUN
    elif [ "$_pc_rc" -eq 0 ]; then
      _pc_add plan_gate 0
    else
      _pc_add plan_gate "$_pc_rc" "$(_pc_tail "$(cat "$_pc_e" 2>/dev/null)")"
    fi
    rm -f "$_pc_o" "$_pc_e"
  fi
  # (3) plan_slice — срез 182 по ОПУБЛИКОВАННОМУ origin/main
  if [ "$_pc_canon" = 0 ]; then
    _pc_add plan_slice 2 "NOT_RUN проектные workflowPaths вне стража"
  elif [ ! -f "$_pc_root/scripts/orch_plan_slice.sh" ]; then
    _pc_add plan_slice 2 "NOT_RUN нет scripts/orch_plan_slice.sh"
  else
    _pc_o="$(mktemp 2>/dev/null || printf '/tmp/t95pc.%s.%s' "$$" "$RANDOM")"; _pc_e="${_pc_o}.e"
    _pc_rc=0
    timeout 5 bash "$_pc_root/scripts/orch_plan_slice.sh" --repo "$REPO" >"$_pc_o" 2>"$_pc_e" || _pc_rc=$?
    if [ "$_pc_rc" -eq 0 ]; then
      _pc_sha="$(awk -F= '/^PLAN_SNAPSHOT: origin\/main=/{print $2; exit}' "$_pc_o")" # t95-m51: хвост зелёной строки — из PLAN_SNAPSHOT среза
      _pc_add plan_slice 0 "origin/main=${_pc_sha:0:12}"
    elif [ "$_pc_rc" -eq 124 ]; then
      _pc_add plan_slice 2 "NOT_RUN бюджет 5с" # t95-m53: тайм-аут — NOT_RUN, не зелёное
    else
      _pc_add plan_slice "$_pc_rc" "$(_pc_tail "$(cat "$_pc_e" 2>/dev/null)")" # t95-m54: именованный отказ среза — фактический rc и его stderr, не NOT_RUN
    fi
    rm -f "$_pc_o" "$_pc_e"
  fi
fi

if [ "$SKIP_TASK" = "0" ]; then
  # ── контракт: заморозка приоритетна; до заморозки — architect/critic ──────
  [ -n "$CONTRACT" ] || die "контракт не указан"
  case "$CONTRACT" in ''|*[!0-9]*) die "номер контракта вне алфавита: $CONTRACT" ;; esac
  TAG="$(git -C "$REPO" tag -l "frozen/contracts/$CONTRACT/*" | LC_ALL=C sort -V | tail -n 1)"
  ORIGIN="draft"
  if [ -n "$TAG" ]; then
    CPATH="$(git -C "$REPO" ls-tree --name-only "$TAG" "contracts/" | grep -E "^contracts/${CONTRACT}-[^/]+\.md$" | head -n 1)"
    [ -n "$CPATH" ] || die "заморозка без контракта: $TAG"
    CBYTES="$(git -C "$REPO" show "$TAG:$CPATH" 2>&1)"
    ORIGIN="frozen"
  else
    case "$LOGICAL_ROLE" in architect|critic|arbiter) ;; *) die "контракт не заморожен: $CONTRACT" ;; esac # t95-m6
    CPATH="$(cd "$REPO" && ls contracts/${CONTRACT}-*.md 2>/dev/null | head -n 1)"
    [ -n "$CPATH" ] || die "черновик контракта не найден: $CONTRACT"
    CBYTES="$(cat "$REPO/$CPATH")"
  fi
  # И-5: ЗОНА-строки — ДОСЛОВНО из источника выше (заморозка > черновик)
  ZONES_SEC="$(printf '%s\n' "$CBYTES" | grep '^ЗОНА ' || true)" # t95-m5
  # И-13: КОНТЕКСТ-строки и секция ## Существующее — ДОСЛОВНО из того же источника
  CONTEXT_SEC="$(printf '%s\n' "$CBYTES" | grep '^КОНТЕКСТ:' || true)"
  CONTEXT_SEC="${CONTEXT_SEC}
$(printf '%s\n' "$CBYTES" | awk '/^## Существующее$/{f=1;print;next} /^## /{f=0} f{print}')" # t95-m13
  ZONE_PATHS="$(printf '%s\n' "$ZONES_SEC" | sed -n 's/^ЗОНА [^:]*: //p' | tr ' ' '\n')"
  CTX_MAN="context${TAB}${CPATH}${TAB}mandatory${TAB}${ORIGIN}
zones${TAB}${CPATH}${TAB}mandatory${TAB}${ORIGIN}
" # t95-m11: происхождение каждого фрагмента манифеста — единый источник $ORIGIN

  # И-10: ADR по области (метки к путям ЗОНА-строк и роли пака), потолок 8
  if [ -n "$ADRP" ] && [ -d "$REPO/$ADRP" ]; then
    an=0
    while IFS="$TAB" read -r aid aarea ares; do
      [ -z "${aid:-}" ] && continue
      m=0
      rest="$aarea"
      while [ -n "$rest" ]; do
        lbl="${rest%%,*}"; lbl="${lbl#"${lbl%%[! ]*}"}"
        [ "$rest" = "${rest%%,*}" ] && rest="" || rest="${rest#*,}"
        case "$lbl" in
          'роль:'*)
            ar="${lbl#роль:}"
            case "$ar" in orchestrator|architect|critic|implementer|adversary|reviewer|arbiter) ;; *) die "ADR: грамматика: роль $ar" ;; esac
            [ "$ar" = "$LOGICAL_ROLE" ] && m=1 ;;
          *)
            case "$lbl" in ''|*[!A-Za-z0-9._/*?-]*) die "ADR: грамматика: метка $lbl" ;; esac
            for zp in $ZONE_PATHS; do case "$zp" in $lbl) m=1 ;; esac; done ;;
        esac
      done
      [ "$m" = "1" ] || continue
      an=$((an+1)); [ "$an" -le 8 ] || die "зона слишком широкая, режь задание"
      ADR_SEC="${ADR_SEC}ADR: ${aid} :: ${ares}
"
    done < <(_adr_load)
  fi

  # И-10: уроки по ОБЛАСТИ зоны (glob по путям ЗОНА-строк), кап 5
  if [ -n "$LLP" ] && [ -f "$REPO/$LLP" ]; then
    cnt=0
    while IFS="$TAB" read -r lid glob ltext; do
      [ -z "${lid:-}" ] && continue
      case "$glob" in ''|*[!A-Za-z0-9._/*?-]*) die "уроки: грамматика: $lid" ;; esac
      m=0
      for zp in $ZONE_PATHS; do case "$zp" in $glob) m=1 ;; esac; done # t95-m10
      [ "$m" = "1" ] || continue
      cnt=$((cnt+1)); [ "$cnt" -le 5 ] || break
      LESSONS_SEC="${LESSONS_SEC}LESSON: $lid :: $ltext
"
    done <"$REPO/$LLP"
    LESSONS_MAN="lessons${TAB}${LLP}${TAB}optional${TAB}profile
"
  fi

  # И-7: ревьюер получает ФАКТИЧЕСКИ ВЫДАННОЕ задание дословно
  if [ "$ROLE" = "reviewer" ]; then
    [ -n "$TASKFILE" ] || die "нет выданного задания: $CONTRACT"
    [ -f "$TASKFILE" ] || die "нет выданного задания: $CONTRACT"
    TASK_SHA="$(sha256sum < "$TASKFILE" | cut -d' ' -f1)"
    TASK_BYTES="$(cat "$TASKFILE")" # t95-m7: байты ВЫДАННОГО задания, не пересборка
    TASK_SEC="TASK: sha256=$TASK_SHA
$TASK_BYTES"
    TASK_MAN="task${TAB}${TASKFILE}${TAB}mandatory${TAB}taskfile
"
  fi
else
  # ── И-12: брифинг несёт ЦЕЛЬ/РАБОТУ/РЕШЕНИЯ/ЗДОРОВЬЕ из живых носителей ────
  [ -f "$REPO/registry/plan.tsv" ] && GOAL_SEC="$(cat "$REPO/registry/plan.tsv")"
  # Носители: §Предмет → §Обещание и граница → inline → H1.
  # Без plan.tsv видны все договоры; с планом — только открытые plan-id.
  # WORK — ограниченный обзор, не изменение статусов lib_plan 084.
  _plan_ids=""
  [ -f "$REPO/registry/plan.tsv" ] && _plan_ids="$(awk -F'\t' 'NR>1 && $1 ~ /^[0-9]+$/ {print $1}' "$REPO/registry/plan.tsv")"
  n_closed=0; n_out=0; WORK_LINES=""
  for cf in $(LC_ALL=C ls "$REPO"/contracts/*.md 2>/dev/null | LC_ALL=C sort); do
    cnum="$(basename "$cf")"; cnum="${cnum%%-*}"
    if [ -f "$REPO/registry/plan.tsv" ] && ! grep -Fxq -- "$cnum" <<<"$_plan_ids"; then # t95-x1
      n_out=$((n_out + 1)); continue
    fi
    closed=0
    [ -z "$(git -C "$REPO" tag -l "done/contracts/$cnum/*")" ] || closed=1
    if [ -f "$REPO/registry/closed-without-done.tsv" ] && awk -F'\t' -v id="$cnum" '$1==id {found=1} END {exit !found}' "$REPO/registry/closed-without-done.tsv"; then closed=1; fi
    if [ "$closed" = 1 ]; then n_closed=$((n_closed + 1)); continue; fi # t95-m20
    csubj="$(awk '
      /^# / && title=="" {title=substr($0,3)}
      /^## Предмет/ {section=1;next}
      /^## Обещание и граница/ {section=2;next}
      /^## / {section=0}
      section==1 && NF && subject=="" {subject=$0}
      section==2 && NF && promise=="" {promise=$0}
      inline=="" && match($0, /(^|[[:space:]])Предмет:[[:space:]]*/) {inline=substr($0,RSTART+RLENGTH)}
      END {
        s=subject!="" ? subject : promise!="" ? promise : inline!="" ? inline : title # t95-m31
        if(s!=title && title ~ /ЧЕРНОВИК|Черновик|черновик/) s="черновик: " s # t95-m32
        print s
      }' "$cf" | jq -Rr 'if length>480 then .[0:479]+"…" else . end')" || die "брифинг: не прочитан контракт: $cf"
    [ -n "$csubj" ] || die "брифинг: контракт без предмета: $cf" # t95-m19
    prefix=""
    if [ -f "$REPO/registry/pauzy.tsv" ] && awk -F'\t' -v id="$cnum" '$1==id {found=1} END {exit !found}' "$REPO/registry/pauzy.tsv"; then prefix="ПАУЗА: "; fi
    WORK_LINES="${WORK_LINES}WORK: ${cnum} :: ${prefix}${csubj}"$'\n'
  done
  if [ -n "$ADRP" ] && [ -d "$REPO/$ADRP" ]; then
    while IFS="$TAB" read -r aid _aarea ares; do
      [ -z "${aid:-}" ] && continue
      DEC_SEC="${DEC_SEC}ADR: ${aid} :: ${ares}
"
    done < <(_adr_load)
  fi
  HEALTH_SEC="$(printf 'HEALTH: branch=%s dirty=%s' "$(git -C "$REPO" rev-parse --abbrev-ref HEAD 2>/dev/null || printf '?')" "$(git -C "$REPO" status --porcelain 2>/dev/null | wc -l | tr -d ' ')")" # t95-m18
  # Сначала неизменяемые секции (включая PRECOND — байты предусловий входят в
  # базовый размер перед усечением WORK и в строку BUDGET), затем целые
  # WORK-строки под тем же капом.
  WORK_HEAD="WORK: опущено: закрытых ${n_closed}, вне плана ${n_out}"$'\n'
  _pack_no_work() {
    printf '=== make_task contract=%s role=%s kind=%s ===\n' "${CONTRACT:-none}" "$ROLE" "$KIND"
    printf '=== TRACE ===\n%s\n' "$TRACE_LINE"
    printf '=== MAP ===\n%s=== RULES ===\n%s=== REUSE ===\n%s' "$MAP_LINES" "$RULES_LINES" "$REUSE_LINES"
    if [ -n "$SKILLS" ]; then printf '=== SKILLS ===\n%s' "$SKILLS"; fi
    if [ -n "$GOAL_SEC" ]; then printf '=== GOAL ===\n%s\n' "$GOAL_SEC"; fi
    if [ -n "$DEC_SEC" ]; then printf '=== DECISIONS ===\n%s' "$DEC_SEC"; fi
    printf '=== HEALTH ===\n%s\n' "$HEALTH_SEC"
    printf '=== PRECOND ===\n%s' "$PRECOND_SEC"
  }
  base="$(_pack_no_work | wc -c)"
  acc="$WORK_HEAD"; omitted=0
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    bytes="$(printf '%s%s\n' "$acc" "$line" | wc -c)"
    if [ "$omitted" -eq 0 ] && [ "$((base + bytes + 13))" -le 39800 ]; then # t95-m29
      acc="${acc}${line}"$'\n'
    else
      omitted=$((omitted + 1))
    fi
  done <<<"$WORK_LINES"
  if [ "$omitted" -gt 0 ]; then acc="${acc}WORK: за бюджетом брифа: ${omitted} строк; полный план и контракты — по MAP"$'\n'; fi # t95-m21
  WORK_SEC="$acc"
fi

# ── И-9: бюджет вклейки (манифест — ссылки, не вклейка; §13.6-1 владельца) ──
TRACE_MAN="trace${TAB}${TRACE}${TAB}mandatory${TAB}trace
"
pack_body() {
  printf '=== make_task contract=%s role=%s kind=%s ===\n' "${CONTRACT:-none}" "$ROLE" "$KIND"
  printf '=== TRACE ===\n%s\n' "$TRACE_LINE"
  printf '=== MAP ===\n%s' "$MAP_LINES"
  printf '=== RULES ===\n%s' "$RULES_LINES"
  printf '=== REUSE ===\n%s' "$REUSE_LINES"
  if [ -n "$SKILLS" ]; then printf '=== SKILLS ===\n%s' "$SKILLS"; fi
  if [ "$SKIP_TASK" = "0" ]; then
    printf '=== CONTEXT ===\n%s\n' "$CONTEXT_SEC"
    printf '=== ZONES ===\n%s\n' "$ZONES_SEC"
    if [ -n "$ADR_SEC" ]; then printf '=== ADR ===\n%s' "$ADR_SEC"; fi
    if [ -n "$LESSONS_SEC" ]; then printf '=== LESSONS ===\n%s' "$LESSONS_SEC"; fi
    if [ "$ROLE" = "reviewer" ]; then printf '=== TASK ===\n%s\n' "$TASK_SEC"; fi
  else
    if [ -n "$GOAL_SEC" ]; then printf '=== GOAL ===\n%s\n' "$GOAL_SEC"; fi
    if [ -n "$WORK_SEC" ]; then printf '=== WORK ===\n%s' "$WORK_SEC"; fi
    if [ -n "$DEC_SEC" ]; then printf '=== DECISIONS ===\n%s' "$DEC_SEC"; fi
    printf '=== HEALTH ===\n%s\n' "$HEALTH_SEC"
    if [ -n "$PRECOND_SEC" ]; then printf '=== PRECOND ===\n%s' "$PRECOND_SEC"; fi
  fi
}
VK="$(pack_body | wc -c | tr -d ' ')" # t95-m60: PRECOND-байты входят и в кап, и в строку BUDGET — без вычетов
[ "$VK" -le 40000 ] || die "режь задачу: $VK > 40000" # t95-m9
pack_body
MAN_BODY="=== MANIFEST ===
${MAP_MAN}${CTX_MAN}${ADR_MAN}${LESSONS_MAN}${TASK_MAN}${TRACE_MAN}"
printf '%s' "$MAN_BODY" # t95-m2: манифест обязателен и полон
printf '=== BUDGET ===\nBUDGET: vklejka=%s/40000\n' "$VK"
# Решение 5: манифест-файл пака — вход новой ноги двери spawn_agent (И-15)
if [ "$KIND" = "task" ] && [ -n "$CONTRACT" ]; then
  mkdir -p "$REPO/.omp/context"
  printf '%s\n' "$MAN_BODY" >"$REPO/.omp/context/${CONTRACT}.tsv"
fi
