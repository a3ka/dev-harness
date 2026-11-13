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
#   ROLE ∈ orchestrator|architect|critic|implementer|adversary|reviewer|arbiter
#   kind=task (умолчание) — задачный пак по контракту NNN; kind=brief —
#   стартовый контекст (orch_brief): только оркестратору, без секций контракта.
#
# Отказы rc 1 «ОТКАЗ: …» (якоря клеток, grep -F): нет свидетельства модели /
# свидетельство не той роли / профиль репо не найден /
# нет файла слоя проекта / пин слоя проекта расходится / нет карты контекста /
# источник недоступен / контракт не заморожен / нет выданного задания /
# зона слишком широкая / режь задачу / брифинг только оркестратору. rc 2 —
# NOT_IMPLEMENTED. Отказ печатается ДО выдачи пака: частичного stdout у
# отказа нет (И-3: без молчаливого усечения).
# Предмет WORK-строки брифа — ЦЕПОЧКА носителей с прецеденсом (followup-1112):
# первая непустая строка секции «## Предмет…» → секции «## Обещание и граница»
# (формат backend 167/168/169) → inline «Предмет:» в строке (Н-436, класс
# 149/160) → фактический H1 «# …» (класс harness 154/157/184) — реальное
# описание, не придуманный placeholder. H1 с явной пометкой ЧЕРНОВИК
# сохраняет метку «черновик: » при выборе НЕзаголовочного носителя. Выдержка
# ≤ 480 СИМВОЛОВ (jq — без байтового обрыва). Незнакомый заголовок — НЕ отказ:
# rc 1 без stdout дают только нечитаемый/полностью пустой контракт и настоящая
# невозможность собрать обязательные источники (трасса, слой, mandatory-карта,
# бюджет). Обзор WORK не валидирует готовность контракта и не объявляет
# черновики реализованными.
#
# Инварианты контракта 095: И-0 грамматики, И-1 правила проекта не харнеса,
# И-2 манифест разрешается, И-3 потерянная ссылка точна, И-4 роль меняет
# выдачу, И-5 зоны из frozen-блоба, И-6 режим до заморозки, И-7 ревьюер судит
# выданное + обязательный след автора в трассе (контракт 166: выбор модели
# судьи свободен — совпадение с автором не причина отказа),
# И-8 свидетельство модели, И-9 бюджет вклейки, И-10 ADR и уроки по области,
# И-11 происхождение фрагментов, И-12 брифинг — содержательный отдельный
# режим, И-13 дословная доставка КОНТЕКСТ/§Существующее, И-14 два слоя
# профиля → выдача.
# И-17 bounded WORK-обзор: незакрытые пункты плана строкой WORK; закрытое и
# вне-планное — счётной строкой «WORK: опущено: закрытых N, вне плана M»;
# хвост за бюджетом — строкой остатка; кап вклейки 40000 не снимается.
# И-18 различение состояний — ОДИН общий статус (семантика lib_plan 084):
# done закрывает предмет только если frozen-КОММИТ высшего тега СОДЕРЖИТСЯ
# в done-коммите (git merge-base --is-ancestor); даты тегов НЕ бизнес-
# семантика. Возобновлённый (done-тег есть, статуса done нет) и пауза
# (registry/pauzy.tsv) несут префикс в слоте предмета; терминальный done
# и «закрыт без done» опускаются.
# И-19 (followup-1112) работа без plan.tsv видна: скоуп WORK = ВСЕ контракты;
# предмет — цепочка носителей с ПРЕЦЕДЕНСОМ (§Предмет → §Обещание и граница
# → inline «Предмет:» → фактический H1 — см. шапку); полностью пустой или
# нечитаемый контракт и недоступный обязательный источник — ОТКАЗ rc 1 (бриф
# НЕ маскирует отказ доверия; незнакомый заголовок — НЕ отказ).
set -uo pipefail
TAB="$(printf '\t')"
NL=$'\n'

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
case "$ROLE" in orchestrator|architect|critic|implementer|adversary|reviewer|arbiter) ;; *) die "роль вне алфавита: $ROLE" ;; esac
case "$KIND" in task|brief) ;; *) die "kind вне алфавита: $KIND" ;; esac

# ── cutover-1113: внешнее state проекта для манифеста пака (161a/095 И-15) ────
# Формула 161a переиспользована, нового каталога/конфига нет: манифест живёт
# в <канонический TMPDIR>/dev-harness-project-state/<первые 16 hex
# sha256(общий .git)>/context — ОДИН каталог для main checkout и linked WT
# (общий .git — общий ключ). Готовится ДО построения пака: отказ (TMPDIR
# непригоден или внутри чекаутов проекта/общего .git) наступает ДО любого stdout.
# Legacy-размещение <repo>/.omp/context больше не пишется: проверяемый
# чекаут манифестом не загрязняется (Н-89: ignore не защита от детектора
# untracked — источник не появляется вовсе).
MAN_CTX=""
if [ "$KIND" = "task" ] && [ -n "$CONTRACT" ]; then
  _mt_base="${TMPDIR:-/tmp}"
  _mt_base="$(cd "$_mt_base" 2>/dev/null && pwd -P 2>/dev/null)" \
    || die "TMPDIR_UNAVAILABLE: непригодный TMPDIR: ${TMPDIR:-/tmp}"
  _mt_common="$(git -C "$REPO" rev-parse --git-common-dir 2>/dev/null || true)"
  [ -n "$_mt_common" ] || _mt_common="$REPO/.git"
  case "$_mt_common" in /*) ;; *) _mt_common="$REPO/$_mt_common" ;; esac
  _mt_common="$(cd "$_mt_common" 2>/dev/null && pwd -P 2>/dev/null)" \
    || die "STATE_PATH_UNRESOLVABLE: общий .git не разрешается: $_mt_common"
  case "$_mt_base" in
    "$REPO"|"$REPO"/*|"$_mt_common"|"$_mt_common"/*) # t95-m37
      die "TMPDIR_INSIDE_MAIN: TMPDIR внутри checkout проекта или его .git: $_mt_base" ;;
  esac
  # Граница 161a — ВСЕ чекауты проекта (как _state_worktree_paths живого
  # кода): TMPDIR внутри ЛЮБОГО связанного чекаута, не только текущего
  # корня, небезопасен; runtime-файлы — вне чекаутов и общего .git.
  while IFS= read -r _mt_wt; do # t95-m38
    [ -n "$_mt_wt" ] || continue
    _mt_wt="$(cd "$_mt_wt" 2>/dev/null && pwd -P 2>/dev/null || true)"
    [ -n "$_mt_wt" ] || continue
    case "$_mt_base" in "$_mt_wt"|"$_mt_wt"/*)
      die "TMPDIR_INSIDE_MAIN: TMPDIR внутри checkout проекта или его .git: $_mt_base" ;;
    esac
  done < <(git -C "$REPO" worktree list --porcelain 2>/dev/null | sed -n 's/^worktree //p')
  # Канонический ключ 161a (cutover-1113): живой _git_common_dir ЗАХВАТЫВАЕТ
  # вывод канонизации (c="$(cd … pwd -P)") и печатает общий .git ОДИН раз —
  # ключ = первые 16 hex sha256("<common>") без перевода строки (printf '%s',
  # как _hash_sha256_text живого кода). Хешируется один канонический путь;
  # двойная печать pwd была измеренной случайностью deployed-кода до починки
  # родителя и в модели не закрепляется.
  _mt_key="$(printf '%s' "$_mt_common" | sha256sum | cut -c1-16)"
  MAN_CTX="$_mt_base/dev-harness-project-state/$_mt_key/context"
fi

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
while IFS="$TAB" read -r r m fb; do
  [ -z "${r:-}" ] && continue
  case "$fb" in allowed|denied) ;; *) die "трасса: грамматика" ;; esac
  if [ "$r" = "$ROLE" ]; then TRACE_LINE="TRACE: role=$r model=$m fallback=$fb"; fi # t95-m8
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
  case ",$roles," in *",$ROLE,"*) ;; *) continue ;; esac
  if [ ! -f "$REPO/$path" ]; then
    if [ "$mnd" = "true" ]; then # t95-m3
      die "источник недоступен: $path" # t95-x3: бриф тоже отказывает — отказ доверия не маскируется
    fi
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
case "$ROLE" in
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
    case "$ROLE" in architect|critic) ;; *) die "контракт не заморожен: $CONTRACT" ;; esac # t95-m6
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
            [ "$ar" = "$ROLE" ] && m=1 ;;
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
  # ── (И-12-скоуп, А-387; И-17/И-18/И-19, followup-1112) ────────────────────
  # Якорь заголовка — ПРЕФИКС `^## Предмет` (суффикс-аннотации предмет НЕСУТ).
  # СТАТУС — ОДИН общий с генератором ROADMAP/HANDOFF (lib_plan 084): done
  # закрывает предмет только если frozen-КОММИТ высшего тега содержится в
  # done-коммите (merge-base --is-ancestor); даты тегов НЕ бизнес-семантика
  # (followup-1112: прежний оракул на creatordate тегов, стоявших на одном
  # коммите, моделировал сдвиг часов, а не новую версию). СКОУП WORK:
  # plan.tsv есть → его id (вне плана — счётная строка); plan.tsv НЕТ → ВСЕ
  # контракты (работа без реестра видна — так устроен бэкенд). ПРЕДМЕТ —
  # цепочка носителей с ПРЕЦЕДЕНСОМ в ЛЮБОМ мире (см. шапку): §Предмет →
  # §Обещание и граница → inline «Предмет:» (Н-436) → фактический H1
  # (154/157/184); H1 с пометкой ЧЕРНОВИК сохраняет метку у не-заголовочного
  # носителя; выдержка ≤480 СИМВОЛОВ (jq, без байтового обрыва); полностью
  # пустой/нечитаемый контракт — ОТКАЗ rc 1 (настоящая невозможность собрать,
  # не непривычный заголовок). Пауза (registry/pauzy.tsv) и возобновлённый
  # несут префикс в слоте предмета; терминальный done и «закрыт без done»
  # опускаются со счётной строкой — не молчаливое усечение (И-0). Обзор не
  # валидирует готовность контракта и не объявляет черновики реализованными.
  # Кап вклейки 40000 не снимается.
  _plan_status() {  # <NNN> → done|закрыт без done|заморожен|номер выдан
    local id="$1" st='' dref fref blob
    fref="$(git -C "$REPO" for-each-ref --sort=-version:refname --count=1 --format='%(refname)' "refs/tags/frozen/contracts/$id/" 2>/dev/null)"
    while IFS= read -r dref; do
      [ -n "$dref" ] || continue
      if [ -z "$fref" ] || git -C "$REPO" merge-base --is-ancestor "$fref^{commit}" "$dref^{commit}" 2>/dev/null; then # t95-m26
        st='done'; break # t95-m27
      fi
    done < <(git -C "$REPO" for-each-ref --format='%(refname)' "refs/tags/done/contracts/$id/" 2>/dev/null)
    if [ "$st" != 'done' ]; then
      blob=""
      [ -f "$REPO/registry/closed-without-done.tsv" ] && blob="$(cat "$REPO/registry/closed-without-done.tsv")"
      if [ -n "$blob" ] && printf '%s\n' "$blob" | awk -F'\t' -v w="$id" '$1==w {f=1; exit} END{exit !f}'; then
        st='закрыт без done'
      elif [ -n "$fref" ]; then
        st='заморожен'
      else
        st='номер выдан'
      fi
    fi
    printf '%s\n' "$st"
  }
  _subj_of() {  # <файл> → предмет | пусто; ПРЕЦЕДЕНС носителей, выдержка jq
    local s=""
    s="$(awk '
      /^# / && title == "" { title = substr($0, 3) }
      /^## Предмет/ { section = 1; next }
      /^## Обещание и граница/ { section = 2; next }
      /^## / { section = 0 }
      section == 1 && NF && subject == "" { subject = $0 }
      section == 2 && NF && promise == "" { promise = $0 }
      inline == "" && match($0, /(^|[[:space:]])Предмет:[[:space:]]*/) { inline = substr($0, RSTART + RLENGTH) }
      END {
        s = subject != "" ? subject : promise != "" ? promise : inline != "" ? inline : title # t95-x2: ПРЕЦЕДЕНС носителей (Н-436)
        if (s != title && title ~ /ЧЕРНОВИК|Черновик|черновик/) s = "черновик: " s
        print s
      }' "$1" | jq -Rr 'if length > 480 then .[0:479] + "…" else . end')" || return 1
    printf '%s' "$s"
  }
  _plan_ids=""; _pauzy_ids=""
  [ -f "$REPO/registry/plan.tsv" ] && _plan_ids="$(awk -F'\t' 'NR>1 && $1 ~ /^[0-9]+$/ {print $1}' "$REPO/registry/plan.tsv")"
  [ -f "$REPO/registry/pauzy.tsv" ] && _pauzy_ids="$(grep -v '^#' "$REPO/registry/pauzy.tsv" | awk -F'\t' '$1 ~ /^[0-9]+$/ {print $1}')"
  n_closed=0; n_out=0; WORK_LINES=""
  for cf in $(LC_ALL=C ls "$REPO"/contracts/*.md 2>/dev/null | LC_ALL=C sort); do
    cnum="$(basename "$cf")"; cnum="${cnum%%-*}"
    if [ -f "$REPO/registry/plan.tsv" ] && ! printf '%s\n' "$_plan_ids" | grep -Fxq -- "$cnum"; then # t95-x1
      n_out=$((n_out + 1)); continue
    fi
    case "$(_plan_status "$cnum")" in
      done|'закрыт без done') n_closed=$((n_closed + 1)); continue ;;
    esac
    prefix=""
    if git -C "$REPO" for-each-ref --format='%(refname)' "refs/tags/done/contracts/$cnum/" 2>/dev/null | grep -q .; then
      prefix="возобновлён: "
    fi
    if printf '%s\n' "$_pauzy_ids" | grep -Fxq -- "$cnum"; then
      prefix="ПАУЗА: "
    fi
    csubj="$(_subj_of "$cf")" || die "брифинг: не прочитан контракт: $cf" # t95-x4
    [ -n "$csubj" ] || die "брифинг: контракт без предмета: $cf" # t95-x5: полностью пустой контракт — отказ, не placeholder
    WORK_LINES="${WORK_LINES}WORK: ${cnum} :: ${prefix}${csubj}$NL"
  done
  if [ -n "$ADRP" ] && [ -d "$REPO/$ADRP" ]; then
    while IFS="$TAB" read -r aid _aarea ares; do
      [ -z "${aid:-}" ] && continue
      DEC_SEC="${DEC_SEC}ADR: ${aid} :: ${ares}$NL"
    done < <(_adr_load)
  fi
  HEALTH_SEC="$(printf 'HEALTH: branch=%s dirty=%s' "$(git -C "$REPO" rev-parse --abbrev-ref HEAD 2>/dev/null || printf '?')" "$(git -C "$REPO" status --porcelain 2>/dev/null | wc -l | tr -d ' ')")" # t95-m18
  # ── (И-17) сборка WORK-секции под бюджет вклейки 40000 ────────────────────
  # счётная строка опущенного печатается ВСЕГДА — ноль просмотренного не
  # «нечего показать» (замер семьи, пустая выборка красна)
  WORK_HEAD="WORK: опущено: закрытых ${n_closed}, вне плана ${n_out}$NL"
  _pack_no_work() {
    printf '=== make_task contract=%s role=%s kind=%s ===\n' "${CONTRACT:-none}" "$ROLE" "$KIND"
    printf '=== TRACE ===\n%s\n' "$TRACE_LINE"
    printf '=== MAP ===\n%s' "$MAP_LINES"
    printf '=== RULES ===\n%s' "$RULES_LINES"
    printf '=== REUSE ===\n%s' "$REUSE_LINES"
    if [ -n "$SKILLS" ]; then printf '=== SKILLS ===\n%s' "$SKILLS"; fi
    if [ -n "$GOAL_SEC" ]; then printf '=== GOAL ===\n%s\n' "$GOAL_SEC"; fi
    if [ -n "$DEC_SEC" ]; then printf '=== DECISIONS ===\n%s\n' "$DEC_SEC"; fi
    printf '=== HEALTH ===\n%s\n' "$HEALTH_SEC"
  }
  _wbase="$(_pack_no_work | wc -c | tr -d ' ')"
  _whdr="$(printf '=== WORK ===\n' | wc -c | tr -d ' ')"
  _acc="${WORK_HEAD}"; _k=0; _brk=0
  while IFS= read -r _wl; do
    [ -n "$_wl" ] || continue
    _nb="$(printf '%s\n' "$_wl" | wc -c | tr -d ' ')"
    _ab="$(printf '%s' "$_acc" | wc -c | tr -d ' ')"
    if [ "$_brk" = "0" ] && [ "$((_wbase + _whdr + _ab + _nb))" -le 39800 ]; then # t95-m29
      _acc="${_acc}${_wl}$NL"
    else
      _brk=1; _k=$((_k + 1))
    fi
  done < <(printf '%s\n' "$WORK_LINES")
  if [ "$_k" -gt 0 ]; then
    _acc="${_acc}WORK: за бюджетом брифа: ${_k} строк; полный план и контракты — по MAP$NL"
  fi
  WORK_SEC="$_acc"
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
  fi
}
VK="$(pack_body | wc -c | tr -d ' ')"
[ "$VK" -le 40000 ] || die "режь задачу: $VK > 40000" # t95-m9
pack_body
MAN_BODY="=== MANIFEST ===
${MAP_MAN}${CTX_MAN}${ADR_MAN}${LESSONS_MAN}${TASK_MAN}${TRACE_MAN}"
printf '%s' "$MAN_BODY" # t95-m2: манифест обязателен и полон
printf '=== BUDGET ===\nBUDGET: vklejka=%s/40000\n' "$VK"
# Решение 5 (cutover-1113): манифест-файл пака — вход ноги И-15 двери
# spawn_agent; живёт во внешнем state проекта (подготовка — блок cutover-1113
# выше): ОДИН каталог для main checkout и linked WT, проверяемый чекаут
# манифестом не загрязняется. Запись — noclobber после удаления старого
# имени: подмена файла символьной ссылкой не проходит (161a).
if [ "$KIND" = "task" ] && [ -n "$CONTRACT" ]; then
  _man_num="$(printf '%03d' "$((10#$CONTRACT))")"
  mkdir -p "$MAN_CTX" || die "внешнее state проекта не создать: $MAN_CTX"
  _man_file="$MAN_CTX/$_man_num.tsv"
  rm -f "$_man_file" || die "файл манифеста не удалить: $_man_file"
  ( set -C; printf '%s\n' "$MAN_BODY" >"$_man_file" ) \
    || die "манифест пака не записан: $_man_file"
fi
exit 0
