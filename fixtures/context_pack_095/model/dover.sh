#!/usr/bin/env bash
# Честная модель сборки контекста make_task (контракт 095) — носитель ГРАММАТИКИ
# субъекта scripts/make_task.sh: субъект обязан принимать этот CLI и эти
# коды/фразы дословно (детали реализации — implementer). Модель — не продукт:
# живёт в семье батареи, используется режимом --model раннера и стаб-паком
# battery_stubs.sh (порчи строятся ИЗ этого файла; маркеры # t95-mN отмечают
# единственные строки-носители инвариантов — НЕ удалять и НЕ переименовывать
# без синхронной правки стаб-пака).
#
# CLI:
#   dover.sh --repo R --role ROLE [--kind task|brief] [--contract NNN]
#            [--task-file F] [--model-trace F]
#   ROLE ∈ orchestrator|architect|critic|implementer|adversary|reviewer|arbiter
#   kind=task (умолчание) — задачный пак по контракту NNN; kind=brief —
#   стартовый контекст (orch_brief): только оркестратору, без секций контракта.
#
# Отказы rc 1 «ОТКАЗ: …» (якоря клеток, grep -F): нет свидетельства модели /
# свидетельство не той роли / нет карты контекста / источник недоступен /
# контракт не заморожен / нет выданного задания / режь задачу / брифинг только
# оркестратору. rc 2 — NOT_IMPLEMENTED. Отказ печатается ДО выдачи пака:
# частичного stdout у отказа нет (И-3: без молчаливого усечения).
#
# Инварианты контракта 095: И-0 грамматики, И-1 правила проекта не харнеса,
# И-2 манифест разрешается, И-3 потерянная ссылка точна, И-4 роль меняет
# выдачу, И-5 зоны из frozen-блоба, И-6 режим до заморозки, И-7 ревьюер судит
# фактически выданное, И-8 свидетельство модели, И-9 бюджет вклейки,
# И-10 уроки по области, И-11 происхождение фрагментов, И-12 брифинг —
# отдельный режим.
set -uo pipefail
TAB="$(printf '\t')"

die() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
ni()  { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }
command -v git >/dev/null 2>&1 || ni "нет git"
command -v sha256sum >/dev/null 2>&1 || ni "нет sha256sum"
command -v awk >/dev/null 2>&1 || ni "нет awk"

usage() { printf 'usage: dover.sh --repo R --role ROLE [--kind task|brief] [--contract NNN] [--task-file F] [--model-trace F]\n' >&2; exit 1; }

REPO=""; ROLE=""; KIND="task"; CONTRACT=""; TASKFILE=""; TRACE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:?}"; shift 2 ;;
    --role) ROLE="${2:?}"; shift 2 ;;
    --kind) KIND="${2:?}"; shift 2 ;;
    --contract) CONTRACT="${2:?}"; shift 2 ;;
    --task-file) TASKFILE="${2:?}"; shift 2 ;;
    --model-trace) TRACE="${2:?}"; shift 2 ;;
    *) usage ;;
  esac
done
[ -n "$REPO" ] && [ -n "$ROLE" ] || usage
[ -d "$REPO" ] || die "репозитория нет: $REPO"
case "$ROLE" in orchestrator|architect|critic|implementer|adversary|reviewer|arbiter) ;; *) die "роль вне алфавита: $ROLE" ;; esac
case "$KIND" in task|brief) ;; *) die "kind вне алфавита: $KIND" ;; esac

# ── И-12: брифинг — отдельный режим, только оркестратору ────────────────────
SKIP_TASK=0
if [ "$KIND" = "brief" ]; then [ "$ROLE" = "orchestrator" ] || die "брифинг только оркестратору"; SKIP_TASK=1; fi # t95-m12

# ── И-8: роль/модель/fallback подтверждаются трассой; отсутствие — не успех ─
TRACE_LINE=""
if [ -z "$TRACE" ] || [ ! -f "$TRACE" ]; then die "нет свидетельства модели: $ROLE"; fi # t95-m8
while IFS="$TAB" read -r r m fb; do
  [ -z "${r:-}" ] && continue
  case "$fb" in allowed|denied) ;; *) die "трасса: грамматика" ;; esac
  [ "$r" = "$ROLE" ] && TRACE_LINE="TRACE: role=$r model=$m fallback=$fb"
done < "$TRACE"
[ -n "$TRACE_LINE" ] || die "свидетельство не той роли: $ROLE"

# ── карта проекта: контекстные ключи (toy-носитель harness/context-map) ─────
MAPF="$REPO/harness/context-map"
[ -f "$MAPF" ] || die "нет карты контекста: harness/context-map"
MAP_LINES=""; RULES_LINES=""; REUSE_LINES=""; MAP_MAN=""
while IFS="$TAB" read -r kind path roles mnd why; do
  [ -z "${kind:-}" ] && continue
  case "$kind" in map|rules|reuse) ;; *) die "карта: грамматика" ;; esac
  case "$path" in ''|*[!A-Za-z0-9._/-]*) die "карта: грамматика" ;; esac
  case "$mnd" in mandatory|optional) ;; *) die "карта: грамматика" ;; esac
  case ",$roles," in *",$ROLE,"*) ;; *) continue ;; esac
  if [ ! -f "$REPO/$path" ]; then
    if [ "$mnd" = "mandatory" ]; then die "источник недоступен: $path"; fi # t95-m3
    continue
  fi
  case "$kind" in
    map)   MAP_LINES="${MAP_LINES}MAP: $path :: $why
" ;;
    rules) RULES_LINES="${RULES_LINES}RULES: $path
" ;; # t95-m1: только пути КАРТЫ репо — харнесовские правила сюда не попадают
    reuse) REUSE_LINES="${REUSE_LINES}REUSE: $path
" ;;
  esac
  MAP_MAN="${MAP_MAN}${kind}${TAB}${path}${TAB}${mnd}${TAB}profile
"
done < "$MAPF"

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

CONTEXT_SEC=""; ZONES_SEC=""; LESSONS_SEC=""; TASK_SEC=""; TASK_MAN=""; CTX_MAN=""
if [ "$SKIP_TASK" = "0" ]; then
  [ -n "$CONTRACT" ] || die "контракт не указан"
  case "$CONTRACT" in ''|*[!0-9]*) die "номер контракта вне алфавита: $CONTRACT" ;; esac
  # И-5/И-6: замороженный блоб приоритетен; до заморозки — только architect/critic
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
  CONTEXT_SEC="$(printf '%s\n' "$CBYTES" | grep '^КОНТЕКСТ:' || true)"
  CONTEXT_SEC="${CONTEXT_SEC}
$(printf '%s\n' "$CBYTES" | awk '/^## Существующее$/{f=1;print;next} /^## /{f=0} f{print}')"
  # И-10: уроки по ОБЛАСТИ зоны (glob по путям ЗОНА-строк), кап 5
  ZONE_PATHS="$(printf '%s\n' "$ZONES_SEC" | sed -n 's/^ЗОНА [^:]*: //p' | tr ' ' '\n')"
  if [ -f "$REPO/harness/lessons" ]; then
    cnt=0
    while IFS="$TAB" read -r lid glob ltext; do
      [ -z "${lid:-}" ] && continue
      m=0
      for zp in $ZONE_PATHS; do
        case "$zp" in $glob) m=1 ;; esac # t95-m10: матч ОБЛАСТИ урока к путям зоны
      done
      [ "$m" = "1" ] || continue
      cnt=$((cnt+1)); [ "$cnt" -le 5 ] || break
      LESSONS_SEC="${LESSONS_SEC}LESSON: $lid :: $ltext
"
    done < "$REPO/harness/lessons"
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
  CTX_MAN="context${TAB}${CPATH}${TAB}mandatory${TAB}${ORIGIN}
zones${TAB}${CPATH}${TAB}mandatory${TAB}${ORIGIN}
" # t95-m11: происхождение каждого фрагмента манифеста — единый источник $ORIGIN
  if [ -f "$REPO/harness/lessons" ]; then
    CTX_MAN="${CTX_MAN}lessons${TAB}harness/lessons${TAB}optional${TAB}profile
"
  fi
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
    if [ -n "$LESSONS_SEC" ]; then printf '=== LESSONS ===\n%s' "$LESSONS_SEC"; fi
    if [ "$ROLE" = "reviewer" ]; then printf '=== TASK ===\n%s\n' "$TASK_SEC"; fi
  fi
}
VK="$(pack_body | wc -c | tr -d ' ')"
[ "$VK" -le 40000 ] || die "режь задачу: $VK > 40000" # t95-m9
pack_body
printf '=== MANIFEST ===\n%s%s%s' "$MAP_MAN" "$CTX_MAN" "$TASK_MAN" # t95-m2: манифест обязателен и полон
printf '%s' "$TRACE_MAN"
printf '=== BUDGET ===\nBUDGET: vklejka=%s/40000\n' "$VK"
