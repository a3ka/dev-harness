#!/usr/bin/env bash
# ДВЕРЬ ПРЕДДВЕРИЯ СУДЕЙСКОЙ ПРОВОДКИ (контракт 172).
#
# ЧТО ДЕЛАЕТ. Публичная дверь вокруг судейского спавна: готовит объект
# (OBJECT), внешнее состояние (SOSTOJANIE), чистоту манифестов и детектора
# утечки ПЕРЕД КАЖДЫМ спавном судьи; fast-forward'ит основной чекаут после
# fetch; проверяет границу судейского вердикта; требует чистоты archive/*.
#
# ВЫЗОВ (грамматика argv замкнута, четыре формы):
#   bash scripts/pre_judge.sh prepare   --repo R --branch B --sostojanie S [--timeout T]
#   bash scripts/pre_judge.sh sync-main --repo R
#   bash scripts/pre_judge.sh verdict   --repo R --file V
#   bash scripts/pre_judge.sh archive   --repo R
#
# Коды возврата:
#   0 — преддверие готово. Машинный вывод — stdout (OBJECT=, SOSTOJANIE=, MAIN=,
#        VERDICT_BRANCH=, ARCHIVE_WORKTREE=), диагностика — stderr.
#   1 — именованный отказ: ПЕРВАЯ строка stderr — «ОТКАЗ: <КОД>», следом —
#        готовая команда или пояснение (никогда в той же строке).
#   2 — нечем проверить (NOT_IMPLEMENTED): нет git/bash, нет репозитория, нет
#        детектора утечки, git не отдал нужный ref. Фиктивного зелёного не бывает.
#
# ИМЕНОВАННЫЕ ОТКАЗЫ (rc 1):
#   NE_POLNYJ_VHOD        — неполный/некорректный вход: нет --branch/--sostojanie/
#                           --file/--repo, S не абсолютный, --timeout не число
#   VETKA_NE_FIT_AUTORA   — --branch не вида wip/<NNN>/<автор>
#   VETKA_NET_LOKALNO     — локальной ветки --branch в репозитории нет
#   VETKA_NE_OPUBLIKOVANA — origin/B отсутствует либо tip разошёлся с локальным
#   SOSTOJANIE_V_CHECKOUT — состояние внутри основного чекаута
#   SOSTOJANIE_NE_NAIDEN  — каталога состояния по --sostojanie нет
#   MANIFESTY_NE_UBRANY   — манифесты .omp/context/*.tsv не убраны за --timeout
#   CHECK_NO_LEAK_KRASEN  — scripts/check_no_leak.sh --check <R> вернул rc≠0
#   MAIN_NE_FAST_FORWARD  — main разошёлся с origin/main (divergence или локальный
#                           ahead); локальный tip НЕ тронут, автосброса нет
#   MAIN_NE_CHISTY        — в основном чекауте есть незакоммиченные правки
#                           tracked-файлов: ff их перезаписал бы
#   NE_NA_MAIN            — checkout не на ветке main
#   VERDIKT_V_MAIN        — вердикт уже staged либо committed в main
#   NE_SUDJSKAJA_VETKA    — ветка не судейская
#   VERDIKT_VNE_REPO      — --file вне репозитория
#   ARCHIVE_WORKTREE      — на refs/heads/archive/* висит worktree
#
# ГИГИЕНА Н-85: GIT_DIR/GIT_WORK_TREE и прочие сняты — дверь работает с тем
# чекаутом, который указан --repo, а не с тем, что подставило окружение.
# Глобальный git-конфиг НЕ обнуляется: safe.directory из него может быть
# нужен чужому чекауту; источник истины — локальный конфиг R.
#
# НОРМА-СТРОКА роли: роли оркестратора преддверие спавна судьи описано в
# roles/orchestrator.md (контракт 172, ПРОВОДКА) — этот файл и есть guard.
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES

# ── грамматика отказа ────────────────────────────────────────────────────────
# Первая строка отказа несёт ТОЛЬКО код: «ОТКАЗ: <КОД>». Пояснение и готовая
# команда — следующими строками (иначе код перестаёт быть разбираемым).
refuse() {
  printf 'ОТКАЗ: %s\n' "$1" >&2
  if [ -n "${2:-}" ]; then printf '%s\n' "$2" >&2; fi
  if [ -n "${3:-}" ]; then printf '%s\n' "$3" >&2; fi
  exit 1
}
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$1" >&2; exit 2; }
usage() {
  cat >&2 <<'USAGE'
использование:
  pre_judge.sh prepare   --repo R --branch B --sostojanie S [--timeout T]
  pre_judge.sh sync-main --repo R
  pre_judge.sh verdict   --repo R --file V
  pre_judge.sh archive   --repo R
rc 0 — преддверие готово; rc 1 — именованный отказ; rc 2 — нечем проверить.
USAGE
  exit 2
}

# Судейские роли (172 §Предмет: critic|adversary|reviewer|arbiter; critic-sol —
# роль харнеса, в преддверии вердикта она судейской веткой не считается).
JUDGE_ROLES='critic adversary reviewer arbiter'

is_judge_role() {
  case " $JUDGE_ROLES " in
    *" $1 "*) return 0 ;;
  esac
  return 1
}

# ── разбор argv ──────────────────────────────────────────────────────────────
MODE=''; REPO_ARG=''; BRANCH=''; SOSTOJANIE=''; TIMEOUT='30'; VFILE=''
while [ $# -gt 0 ]; do
  case "$1" in
    prepare|sync-main|verdict|archive)
      [ -z "$MODE" ] || usage
      MODE="$1"; shift
      ;;
    --repo)       [ $# -ge 2 ] || usage; REPO_ARG="$2";   shift 2 ;;
    --branch)     [ $# -ge 2 ] || usage; BRANCH="$2";     shift 2 ;;
    --sostojanie) [ $# -ge 2 ] || usage; SOSTOJANIE="$2"; shift 2 ;;
    --timeout)    [ $# -ge 2 ] || usage; TIMEOUT="$2";    shift 2 ;;
    --file)       [ $# -ge 2 ] || usage; VFILE="$2";      shift 2 ;;
    -h|--help)    usage ;;
    *)            usage ;;
  esac
done
[ -n "$MODE" ] || usage
[ -n "$REPO_ARG" ] || refuse NE_POLNYJ_VHOD

command -v git >/dev/null 2>&1 || skip 'нет git'
command -v bash >/dev/null 2>&1 || skip 'нет bash'

# ── репозиторий-цель ─────────────────────────────────────────────────────────
# R — канонический корень основного чекаута: без --repo цели не угадать.
R="$(cd "$REPO_ARG" 2>/dev/null && pwd -P)" || skip "нет каталога: $REPO_ARG"
git -C "$R" rev-parse --git-dir >/dev/null 2>&1 || skip "не репозиторий: $R"
# R обязан быть КОРНЕМ чекаута: все пути двери (.omp/context, scripts/…) и
# список worktree считаются от корня. Поиск git вверх по дереву (чужой .git
# выше R) не должен превращать подкаталог в «репозиторий-цель».
top="$(git -C "$R" rev-parse --show-toplevel 2>/dev/null)" || top=''
[ "$top" = "$R" ] || skip "не корень чекаута: $R (верх репозитория: ${top:-нет})"

# Канонизация состояния: realpath (pwd -P) — сравнение с R идёт по канону.
canon_dir() { (cd "$1" 2>/dev/null && pwd -P); }

# Внутри ли путь child лежит в parent (оба — канонические).
path_inside() {
  [ "$1" = "$2" ] && return 0
  case "$1" in
    "$2"/*) return 0 ;;
  esac
  return 1
}

# Полный tip локальной/опубликованной ветки; пусто — ветки нет.
tip_of() {
  local out
  out="$(git -C "$R" rev-parse --verify --quiet "$1" 2>/dev/null)" || out=''
  printf '%s' "$out"
}

# --timeout в миллисекунды (дробный срок — тоже конечен).
timeout_ms() {
  local int frac
  case "$TIMEOUT" in
    *.*) int="${TIMEOUT%%.*}"; frac="${TIMEOUT#*.}"; frac="${frac}000"; frac="${frac:0:3}" ;;
    *)   int="$TIMEOUT"; frac='000' ;;
  esac
  printf '%s' $(( int * 1000 + 10#$frac ))
}

# Имя ветки-схоронки локального tip main: wip/<NNN>/<автор|judge>-main-saved
# (172 §Предмет). Ветка-схоронка выводится ИЗ ЛОКАЛЬНЫХ refs чекаута — в
# sync-main других входов нет; авторская ветка предпочтительнее судейской,
# уже занятое имя не переиспользуется (на конце — порядковый хвост).
save_branch_name() {
  local ts name role base n
  local -a plain=() judge=()
  while read -r ts name; do
    [ -n "$name" ] || continue
    case "$name" in
      wip/*/*) ;;
      *) continue ;;
    esac
    case "$name" in
      wip/[0-9][0-9][0-9]/*) ;;
      *) continue ;;
    esac
    case "${name#wip/*/}" in
      */*) continue ;;          # ровно один сегмент после номера предмета
    esac
    case "$name" in
      *-main-saved) continue ;;  # сама схоронка — не кандидат
    esac
    role="${name##*/}"
    if is_judge_role "$role"; then judge+=("$name"); else plain+=("$name"); fi
  done < <(git -C "$R" for-each-ref --format='%(committerdate:unix) %(refname:short)' \
             refs/heads/wip/ 2>/dev/null | LC_ALL=C sort -rn)
  for name in ${plain[@]+"${plain[@]}"} ${judge[@]+"${judge[@]}"}; do
    base="${name}-main-saved"
    n=2
    while git -C "$R" show-ref --verify --quiet "refs/heads/$base"; do
      base="${name}-main-saved-$n"
      n=$((n + 1))
    done
    printf '%s' "$base"
    return 0
  done
  # Авторской ветки в чекауте нет — имя-схоронка по умолчанию.
  base='main-saved'
  n=2
  while git -C "$R" show-ref --verify --quiet "refs/heads/$base"; do
    base="main-saved-$n"
    n=$((n + 1))
  done
  printf '%s' "$base"
}

# ── prepare: объект + состояние перед спавном судьи ─────────────────────────
if [ "$MODE" = 'prepare' ]; then
  # Вход неполный — отказ ДО любой проверки: без внешнего состояния спавн
  # судьи не имеет предмета (172 §Предмет: S обязателен).
  [ -n "$BRANCH" ] && [ -n "$SOSTOJANIE" ] || refuse NE_POLNYJ_VHOD
  printf '%s' "$TIMEOUT" | grep -Eq '^[0-9]+([.][0-9]+)?$' || refuse NE_POLNYJ_VHOD
  case "$SOSTOJANIE" in
    /*) ;;
    *) refuse NE_POLNYJ_VHOD ;;   # S — абсолютный каталог из живого ctx
  esac
  printf '%s' "$BRANCH" | grep -Eq '^wip/[0-9]{3}/[^/]+$' || refuse VETKA_NE_FIT_AUTORA

  # Состояние: каталог есть, лежит СТРОГО ВНЕ основного чекаута.
  [ -d "$SOSTOJANIE" ] || refuse SOSTOJANIE_NE_NAIDEN
  S_CANON="$(canon_dir "$SOSTOJANIE")" || refuse SOSTOJANIE_NE_NAIDEN
  [ -n "$S_CANON" ] || refuse SOSTOJANIE_NE_NAIDEN
  if path_inside "$S_CANON" "$R"; then
    refuse SOSTOJANIE_V_CHECKOUT "SOSTOJANIE=$S_CANON лежит внутри чекаута $R"
  fi

  # Публикация авторской ветки: локальный tip == опубликованный origin/B.
  # OBJECT всегда — tip origin/B; локальный ahead и HEAD никогда не подменяются.
  local_tip="$(tip_of "refs/heads/$BRANCH")"
  [ -n "$local_tip" ] || refuse VETKA_NET_LOKALNO "локальной ветки $BRANCH нет: $R"
  remote_tip="$(tip_of "refs/remotes/origin/$BRANCH")"
  if [ -z "$remote_tip" ] || [ "$remote_tip" != "$local_tip" ]; then
    refuse VETKA_NE_OPUBLIKOVANA "bash scripts/gitw push origin $BRANCH"
  fi

  # Манифесты: ждём, пока уборщик снимет .omp/context/*.tsv. За уборщика НЕ
  # удаляем — срок конечен, истёк → именованный отказ.
  t_ms="$(timeout_ms)"
  deadline_ns=$(( $(date +%s%N) + t_ms * 1000000 ))
  while :; do
    found=''
    if [ -d "$R/.omp/context" ]; then
      found="$(find "$R/.omp/context" -maxdepth 1 -name '*.tsv' -print -quit 2>/dev/null)"
    fi
    [ -n "$found" ] || break
    if [ "$(date +%s%N)" -ge "$deadline_ns" ]; then
      refuse MANIFESTY_NE_UBRANY "манифест не убран: $found"
    fi
    sleep 0.02
  done

  # Детектор утечки — ВСЕГДА детектор УСТАНОВКИ (каталог этого pre_judge.sh):
  # судим корень R (канонический git-корень из --repo) установочным
  # scripts/check_no_leak.sh. Локальный $R/scripts/check_no_leak.sh не
  # используется НИКОГДА: поддельный «exit 0» в проекте не должен подменять
  # доверенный детектор перед судьёй (контракт 185, маршрут (а)).
  # Отсутствие установочного детектора — rc 2 NOT_IMPLEMENTED, не зелёный.
  HARNESS_SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" \
    || skip "нет каталога скриптов харнесса"
  DETECTOR="$HARNESS_SCRIPTS/check_no_leak.sh"
  [ -f "$DETECTOR" ] || skip "нет детектора утечки харнесса: scripts/check_no_leak.sh"
  leak_out="$(bash "$DETECTOR" --check "$R" 2>&1)"; leak_rc=$?
  if [ "$leak_rc" -ne 0 ]; then
    [ -n "$leak_out" ] && printf '%s\n' "$leak_out" >&2
    refuse CHECK_NO_LEAK_KRASEN "scripts/check_no_leak.sh --check $R вернул rc=$leak_rc"
  fi

  printf 'OBJECT=%s\n' "$remote_tip"
  printf 'SOSTOJANIE=%s\n' "$S_CANON"
  exit 0
fi

# ── sync-main: основной чекаут — только fast-forward ────────────────────────
if [ "$MODE" = 'sync-main' ]; then
  head_branch="$(git -C "$R" symbolic-ref --short HEAD 2>/dev/null)" || head_branch=''
  [ "$head_branch" = 'main' ] || refuse NE_NA_MAIN "checkout на '${head_branch:-отсоединённом HEAD}', а не на main"

  # Незакоммиченные правки tracked-файлов: ff их перезаписал бы — стоп.
  dirty="$(git -C "$R" status --porcelain --untracked-files=no 2>/dev/null)" || dirty=''
  if [ -n "$dirty" ]; then
    printf '%s\n' "$dirty" >&2
    refuse MAIN_NE_CHISTY "в чекауте $R есть незакоммиченные правки tracked-файлов"
  fi

  local_main="$(tip_of 'refs/heads/main')"
  [ -n "$local_main" ] || skip "нет локального main: $R"
  remote_main="$(tip_of 'refs/remotes/origin/main')"
  [ -n "$remote_main" ] || skip "нет origin/main (fetch через scripts/gitw не выполнен): $R"

  if [ "$local_main" = "$remote_main" ]; then
    printf 'MAIN=%s\n' "$remote_main"
    exit 0
  fi

  if git -C "$R" merge-base --is-ancestor "$local_main" "$remote_main"; then
    # Ровно один ff: checkout наблюдаемо обновляется, коммитов не создаётся.
    merge_out="$(git -C "$R" merge --ff-only origin/main 2>&1)"; merge_rc=$?
    if [ "$merge_rc" -ne 0 ]; then
      [ -n "$merge_out" ] && printf '%s\n' "$merge_out" >&2
      skip "ff-main не сошёлся: $R"
    fi
    head_after="$(git -C "$R" rev-parse HEAD 2>/dev/null)" || head_after=''
    [ "$head_after" = "$remote_main" ] || skip "checkout не обновился: $R"
    [ -n "$merge_out" ] && printf '%s\n' "$merge_out" >&2
    printf 'MAIN=%s\n' "$remote_main"
    exit 0
  fi

  # Divergence или локальный ahead: main НЕ трогаем (ни автосброса, ни
  # auto-merge). Отказ несёт ГОТОВУЮ команду: сохранить локальный tip и
  # только потом вернуть main к origin/main.
  save_branch="$(save_branch_name)"
  refuse MAIN_NE_FAST_FORWARD \
    "git -C \"$R\" branch $save_branch $local_main && git -C \"$R\" reset --hard origin/main" \
    "main=$local_main, origin/main=$remote_main: команда выше сохраняет локальный tip веткой $save_branch и возвращает main к origin/main"
fi

# ── verdict: граница судейского вердикта ─────────────────────────────────────
if [ "$MODE" = 'verdict' ]; then
  [ -n "$VFILE" ] || refuse NE_POLNYJ_VHOD

  # Путь вердикта — относительно репозитория (как git -C R): относительный
  # аргумент не привязан к cwd вызывающего.
  case "$VFILE" in
    /*)
      vdir="$(dirname "$VFILE")"; vbase="$(basename "$VFILE")"
      if [ -d "$vdir" ]; then
        vcanon="$(canon_dir "$vdir")/$vbase"
      else
        vcanon="$VFILE"
      fi
      if path_inside "$vcanon" "$R" && [ "$vcanon" != "$R" ]; then
        VREL="${vcanon#"$R"/}"
      else
        refuse VERDIKT_VNE_REPO "файл вердикта вне репозитория: $VFILE"
      fi
      ;;
    *)
      VREL="${VFILE#./}"
      [ -n "$VREL" ] || refuse VERDIKT_VNE_REPO "пустой --file"
      ;;
  esac

  head_branch="$(git -C "$R" symbolic-ref --short HEAD 2>/dev/null)" || head_branch=''

  # Вердикт в main — либо ещё staged, либо уже committed: отказ.
  if [ "$head_branch" = 'main' ]; then
    staged="$(git -C "$R" status --porcelain -- "$VREL" 2>/dev/null)" || staged=''
    committed="$(git -C "$R" log -1 --format=%H -- "$VREL" 2>/dev/null)" || committed=''
    if [ -n "$staged" ] || [ -n "$committed" ]; then
      refuse VERDIKT_V_MAIN "вердикт $VREL уже в main (staged/committed)"
    fi
  fi

  # Ветка судьи: wip/<NNN>/<critic|adversary|reviewer|arbiter>.
  printf '%s' "$head_branch" | grep -Eq '^wip/[0-9]{3}/(critic|adversary|reviewer|arbiter)$' \
    || refuse NE_SUDJSKAJA_VETKA "ветка '${head_branch:-отсоединённый HEAD}' не судейская"

  printf 'VERDICT_BRANCH=%s\n' "$head_branch"
  exit 0
fi

# ── archive: на archive/* не должно висеть ни одного worktree ────────────────
if [ "$MODE" = 'archive' ]; then
  wt_out="$(git -C "$R" worktree list --porcelain 2>/dev/null)" || skip "worktree list не отдан: $R"
  while IFS= read -r line; do
    case "$line" in
      'branch refs/heads/archive/'*)
        refuse ARCHIVE_WORKTREE "worktree на archive-ветке: $line" ;;
    esac
  done <<EOF
$wt_out
EOF
  printf 'ARCHIVE_WORKTREE=0\n'
  exit 0
fi

usage
