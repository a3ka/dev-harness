#!/usr/bin/env bash
# scripts/check_project_sources.sh — ГЕЙТ СВЕРКИ С ИСТОЧНИКАМИ (контракт 996,
# пакет C). Запускается ПЕРЕД done-тегом и ПЕРЕД spawn критика.
#
#   bash scripts/check_project_sources.sh --repo R --contract <CONTRACT> --stage <pre_critic|done>
#
# Алгоритм:
#   1. Резолвит эффективный профиль репо (scripts/profile_resolver.sh) и
#      читает sourceCanon (опциональный юнит {sources, gate}). Если
#      sourceCanon отсутствует — rc 0 без запуска gate (К6 «без канона gate
#      не запускается»). Без реестра/профиля — rc 2 NOT_IMPLEMENTED.
#   2. Валидирует структуру sourceCanon (закрытый JSON-алфавит):
#         {sources, gate} ОДИНЕСТВЕННО; sources — массив {path, priority};
#         priority — целое ≥0 (bool НЕ целое); path — непустая строка,
#         относительная, без «..», без NUL; уникальные path.
#         gate — массив непустых строк argv без NUL.
#      Любое нарушение → rc 1 SOURCE_CANON_INVALID (атомарный).
#   3. Для каждой sources-строки проверяет существование файла относительно
#      R; отсутствующий → rc 1 SOURCE_CANON_MISSING (атомарный).
#   4. Исполняет gate argv. Команда `argv[0]` должна быть исполняемой;
#      иначе — rc 1 SOURCE_GATE_UNAVAILABLE. cwd=R (а не cwd исполнителя),
#      env — унаследованный + HARNESS_CONTRACT=<CONTRACT> (отн-путь от R),
#      HARNESS_STAGE=<stage>, HARNESS_HEAD=git HEAD в момент вызова.
#      rc=0 → гейт зелёный; rc≠0 → rc 1 SOURCE_GATE_FAILED.
#
# Коды возврата:
#   0 — зелёная (gate rc 0 ИЛИ canon отсутствует); stdout пуст
#   1 — отказ SOURCE_CANON_INVALID/MISSING/GATE_FAILED/UNAVAILABLE (stderr)
#   2 — NOT_IMPLEMENTED
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
die()  { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

command -v git >/dev/null 2>&1 || skip "нет git"
command -v jq >/dev/null 2>&1  || skip "нет jq"

REPO=""; CONTRACT=""; STAGE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo)     REPO="${2:-}"; shift 2 ;;
    --contract) CONTRACT="${2:-}"; shift 2 ;;
    --stage)    STAGE="${2:-}"; shift 2 ;;
    --) shift; break ;;
    *) die "неизвестный аргумент: $1" ;;
  esac
done
[ -n "$REPO" ] || die "usage: bash scripts/check_project_sources.sh --repo R --contract <CONTRACT> --stage <pre_critic|done>"
[ -n "$CONTRACT" ] || die "--contract обязателен"
[ -n "$STAGE" ] || die "--stage обязателен"
case "$STAGE" in pre_critic|done) ;; *) die "stage вне {pre_critic, done}: $STAGE" ;; esac

[ -d "$REPO" ] || die "репо не существует: $REPO"
REPO="$(cd "$REPO" && pwd -P)"
[ -x "$HERE/profile_resolver.sh" ] || die "нет profile_resolver.sh"

# Профиль — ДО расширения; resolver.sh не знает «исходные» байты, но мы
# используем ТОЛЬКО эффективный профиль (merged). Битый профиль — отказ.
_pr_err="$(mktemp 2>/dev/null || echo /dev/null)"
if ! _pr_out="$(HARNESS_PROJECT_LAYER_ROOT="${HARNESS_PROJECT_LAYER_ROOT:-$REPO}" \
            bash "$HERE/profile_resolver.sh" --repo "$REPO" 2>"$_pr_err")"; then
  _pr_reason="$(cat "$_pr_err" 2>/dev/null || true)"
  rm -f "$_pr_err"
  die "профиль: ${_pr_reason#profile ОТКАЗ: }"
fi
rm -f "$_pr_err"

# Различаем «канон не объявлен» vs «канон объявлен, но null». Первый — gate
# не запускается (К6 «без канона → rc 0 без запуска»); второй — явный invalid,
# canonical canon из merged-профиля (резолвер уже валидировал алфавит и
# отверг оба слоя по SOURCE_CANON_INVALID — отказ выше).
CANON="$(printf '%s' "$_pr_out" | jq -r 'if has("sourceCanon") and (.sourceCanon.value != null) then .sourceCanon.value else empty end' 2>/dev/null)"

# Б-3 (контракт 996 §Lifecycle L53): null/пустой объект — НЕ отсутствие.
# Канон объявлен либо в репо-, либо в defaults-слое — 
# ОБОИХ. Резолвер успешен → алфавит внутри уже валиден; null/пустой/мусор
# на УРОВНЕ полей он отверг сам (scan_canon). Если merged-профиль не несёт
# .sourceCanon, но один из СЛОЁВ его объявил (null или иное) — резолвер уже
# отказал, и мы не здесь. Здесь канон отсутствует в обоих слоях → no-op (К6
# «без канона gate не запускается»).
if [ -z "$CANON" ]; then
  exit 0
fi

# Грамматика sourceCanon-юнита валидируется в profile_resolver.sh (scan_canon);
# к моменту чтения $CANON резолвер уже отказал бы SOURCE_CANON_INVALID на любом
# нарушении алфавита, нечитаемом типе, `..` или NUL в path/argv. Дублирующая
# jq-проверка здесь избыточна (резолвер — единственный источник грамматики;
# НЕ-39: «не подставлять argv через shell-eval», L51, L55).

# Преобразуем sourceCanon → массив путей (отнолжённых к R) и массив argv gate.
mapfile -t SOURCE_PATHS < <(printf '%s' "$CANON" | jq -r '.sources[] | .path' 2>/dev/null)
mapfile -t GATE_ARGV < <(printf '%s' "$CANON" | jq -r '.gate[]' 2>/dev/null)

# Существование и КАНОНИЗАЦИЯ каждого source (Б-4, контракт 996 §Lifecycle L53
# «существующих файлов внутри R»). Раньше источник проверялся предикатом `-f`,
# который СЛЕДУЕТ по симлинкам и принимал ссылку, уводящую наружу R —
# адверсарий круг 1 предъявил `LINK.md → ../outside/outside.md` зелёным.
# Защита — readlink -f с принудительной канонизацией ОБОИХ сторон: цель
# обязана оказаться ВНУТРИ REPO_ABS. Цикл по `path` от профиля → `<full>`
# через `${p#./}` (НЕИЗМЕННО); затем `readlink -f -- "$REPO/$full"` обязан
# показать путь под REPO_ABS — иначе отказ SOURCE_CANON_INVALID.
for p in "${SOURCE_PATHS[@]}"; do
  case "$p" in
    /*) die "SOURCE_CANON_INVALID: абсолютный путь источника: $p" ;;
    *..*) die "SOURCE_CANON_INVALID: .. в пути: $p" ;;
    *\0*) die "SOURCE_CANON_INVALID: NUL в пути: $p" ;;
  esac
  full="$REPO/${p#./}"
  # Каталог под R — НЕ regular file; -f требует именно regular file, -e
  # проходит и для каталога (что и адверсарий круг 2 предъявил как обход: 
  # `directory-is-not-file` принимался как источник). Различаем два отказа:
  #   - объект НЕ существует → SOURCE_CANON_MISSING (как было);
  #   - объект есть, но НЕ regular file (каталог, FIFO и пр.) → INVALID.
  if [ ! -e "$full" ]; then
    die "SOURCE_CANON_MISSING: $p"
  fi
  if [ ! -f "$full" ]; then
    die "SOURCE_CANON_INVALID: источник не regular file: $p"
  fi
  # Канонизация цели — относится и к регулярному файлу (readlink -f на
  # регулярный файл печатает его путь), и к симлинку (следует до объекта).
  _canon_target="$(readlink -f -- "$full" 2>/dev/null || true)"
  case "$_canon_target" in
    "$REPO"/*) ;;        # внутри R — закон
    *) die "SOURCE_CANON_INVALID: источник вне репозитория: $p" ;;
  esac
  unset _canon_target
done

# Исполнение gate. cwd=R, env HARNESS_CONTRACT (ОТН-ПУТЬ от R), HARNESS_STAGE,
# HARNESS_HEAD — момент вызова (фиксированный байт HEAD репо, не "HEAD"
# символическое имя).
HEAD_SHA="$(git -C "$REPO" rev-parse HEAD 2>/dev/null || true)"
[ -n "$HEAD_SHA" ] || die "HEAD не определён в $REPO"

# Резолв argv[0] КАНОНИЧЕСКОЙ ФОРМЫ из контракта 996 §Lifecycle L53:
# `"gate":["python3","tools/check_source_trace.py"]` — ИМЯ программы (argv[0])
# резолвится через $PATH, не склейкой с R. Склейка с R применяется ТОЛЬКО
# когда argv[0] указан как относительный ПУТЬ (содержит `/`); абсолютный
# путь берётся литералом.
# Прежний `cmd0="$REPO/$gate0"` для голого `python3` давал `<R>/python3`
# → SOURCE_GATE_UNAVAILABLE (адверсарий круг 1, Б-1). Тут — три формы:
#   * абсолютный путь → литерал, проверка -x
#   * относительный путь (содержит `/`) → $REPO/<...>, проверка -x
#   * имя (без `/`) → команда из $PATH через `command -v`
# Граничный случай «имя с абсолютным путём совпадает» невозможен (POSIX:
# имя argv[0] — первый токен; `/` в имени — это относительный путь от cwd).
gate0="${GATE_ARGV[0]}"
case "$gate0" in
  /*)
    cmd0="$gate0"
    [ -x "$cmd0" ] || die "SOURCE_GATE_UNAVAILABLE: $gate0 не исполняем (отсутствует или нет бита +x)"
    ;;
  */*)
    cmd0="$REPO/$gate0"
    [ -x "$cmd0" ] || die "SOURCE_GATE_UNAVAILABLE: $gate0 не исполняем (отсутствует или нет бита +x)"
    ;;
  *)
    # Имя без `/`: ищем в $PATH. `command -v` ДОСТАТОЧЕН — мы запрещаем
    # относительные имена (они пройдут через «*/*» выше), а абсолютные —
    # через «/*». Здесь — только PATH-резолв.
    cmd0="$(command -v -- "$gate0" 2>/dev/null || true)"
    [ -n "$cmd0" ] || die "SOURCE_GATE_UNAVAILABLE: $gate0 не найден в PATH"
    ;;
esac

# Запуск с явным env (родительское окружение УНАСЛЕДУЕТСЯ без изменений, лишь
# добавляются три ключа — никакая подстановка NUL/LF в значении не происходит).
env_args=( HARNESS_CONTRACT="$CONTRACT" HARNESS_STAGE="$STAGE" HARNESS_HEAD="$HEAD_SHA" )
# argv: gate[1..], cmd0 — gate[0] интерпретируется как path к исполняемому.
argv=( "$cmd0" "${GATE_ARGV[@]:1}" )

# exec с cwd=R. Использование массива — никакая подстановка argv не происходит
# (Н-39: «не подставлять argv через shell-eval»).
gate_rc=0
gate_out="$(cd "$REPO" && env "${env_args[@]}" "${argv[@]}" 2>&1)" || gate_rc=$?
if [ "$gate_rc" -ne 0 ]; then
  printf '%s\n' "SOURCE_GATE_FAILED: $gate_out" >&2
  exit 1
fi
exit 0