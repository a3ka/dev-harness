#!/usr/bin/env bash
# _karkas_staba.sh — КАРКАС правдоподобного «быстрого check_charter» для обманных
# стабов батареи 113. НЕ БАРЬЕР и НЕ реализация предмета: инструмент доказательства
# того, что батарея РАЗЛИЧАЕТ честный быстрый режим и каждый поименованный класс лжи.
#
# Стаб-файл НЕ правит этот каркас: он определяет ПЕРЕМЕННУЮ-указатель ST113_<ИМЯ> на
# свою функцию-ложь и source'ит каркас. Ровно одна точка лжи на стаб (Н-39: привязка
# по коду батареи, не проза).
#
# Точки лжи (default = честное поведение каркаса):
#   ST113_OBHOD     весь обход (default: одиночный проход git log)        — s3
#   ST113_LOG_ARGS  доп. аргументы окна git log                           — s1
#   ST113_RANGE     диапазон прохода git log (default: всегда HEAD)        — s9
#   ST113_MERGE     режим merge-диффов (default: --diff-merges=first-parent) — s2
#   ST113_FILTER    --diff-filter (default: MD)                           — s4
#   ST113_RENAMES   --no-renames (default: вкл)                           — s5
#   ST113_SUDIM     судится ли (<since> <коммит>) для матча               — s6
#   ST113_KESH      кеш сторонней линии (default: полный прогон)          — s7
#   ST113_FINISH    запись кеша в конце (default: HEAD начала HEAD0)    — s10
#   ST113_ORACLE     реакция на --oracle (default: делегировать барьеру)   — s12
#   ST113_PAR_FILTER фильтр области пар после ls-tree+тегов (default: нет)  — s11
#   ST113_SHA_DLINA фильтр длины SHA матча быстрого пути (default: НЕТ — маркер
#                   \x01 однозначен; простая форма Б-3 ревьюера круг 1)    — s13
#
# Интерфейс — как у предмета:  [стаб] [--incr <кеш>] <корень>;  [стаб] --oracle <корень>
# делегирует честному барьеру (RED113_REAL_CHARTER). Грамматика razreshil/is_charter_path
# берётся ИЗ ЕДИНОГО ИСТОЧНИКА — source реального check_charter.sh с CHARTER_LIB=1
# (контракт 019: вторая реализация кольца запрещена; каркас её не пишет).
set -uo pipefail

[ -n "${RED113_REAL_CHARTER:-}" ] || { printf 'СТАБ-КАРКАС: нет RED113_REAL_CHARTER\n' >&2; exit 125; }

_args=(); _ORACLE=0; INCR_CACHE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --oracle) _ORACLE=1 ;;
    --incr)   INCR_CACHE="${2:-}"; shift ;;
    --incr=*) INCR_CACHE="${1#--incr=}" ;;
    *)        _args+=("$1") ;;
  esac
  shift
done
if [ "$_ORACLE" -eq 1 ] && [ "${ST113_ORACLE:-}" != "ignore" ]; then
  # Точка лжи ST113_ORACLE (s12 «нейтрализация --oracle», вердикт адверсария круг 1:
  # `--oracle) ORACLE=0` проходила батарею 22/0): default — флаг ЧЕСТНО делегирует
  # реальному барьеру полный обход; «ignore» — флаг разбирается, но не действует.
  # Флаг ПЕРЕДАЁТСЯ дословно (Б-3, контроль d12/s13: без него «честная сторона»
  # поимки — быстрый путь субъекта — сама слепа на дефектной модели с той же ложью).
  exec bash "$RED113_REAL_CHARTER" --oracle "${_args[@]}"
fi

ROOT="$(cd "${_args[0]:-.}" && pwd)" || exit 125
fails=0; docs=0; changes=0; excused=0
ok()  { printf '  ok   %s\n' "$*" >&2; }
bad() { fails=$((fails + 1)); printf '  FAIL %s\n' "$*" >&2; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

command -v git >/dev/null 2>&1 || skip 'нет git'
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 || skip "$ROOT не репозиторий"
git -C "$ROOT" rev-parse --verify --quiet 'refs/tags/ustav/1' >/dev/null \
  || skip 'устав не введён'

# единый источник грамматики: razreshil/is_charter_path из реального барьера
CHARTER_LIB=1 RED113_SAVING=1
# shellcheck disable=SC1090
. "$RED113_REAL_CHARTER"
g() { git -C "$ROOT" "$@"; }
HEAD0="$(g rev-parse HEAD)" || exit 125   # снимок ДО любого чтения истории (зеркало INCR_HEAD lib_incr, арбитраж круга 3)

# ── default-точки (стаб их подменяет указателем ST113_*) ──────────────────────
st113_log_args_default()  { :; }
st113_merge_default()     { printf '%s\n' --diff-merges=first-parent; }
st113_filter_default()    { printf '%s\n' --diff-filter=MD; }
st113_renames_default()   { printf '%s\n' --no-renames; }
# честный матч НЕ фильтрует SHA по длине: маркер \x01 однозначен (простая форма
# Б-3 ревьюера круг 1). Точка лжи s13 — «жёсткие 40 hex»: в sha256-репозитории
# все совпадения 64 hex отбрасываются молча.
st113_sha_dlina_default() { printf '%s\n' "$1"; }
st113_kesh_default()      { INCR_WINDOW=""; }        # (в′): не-предок → полный прогон
st113_sudim_default() {  # <since> <коммит> → 0: судится. c ∈ since..HEAD ⟺ c достижим из
  # HEAD и НЕ является предком-или-самим since — направление аргументов проверено
  # живьём (сначала было инвертировано и поймано контролем честности s7/d8).
  ! git -C "$ROOT" merge-base --is-ancestor "$2" "$1" 2>/dev/null
}
st113_eff_since() {  # <since> → эффективная точка отсчёта матча (зеркало 083:
  # в incr-окне файл, замороженный ДО кеша, судится с кеша; кеш сторонней линии
  # (в′) окна не даёт — остаётся since. Применяется ТОЛЬКО при живом окне.)
  local s="$1"
  if [ -n "${INCR_WINDOW:-}" ] && [ -n "${INCR_BASE:-}" ] \
     && git -C "$ROOT" merge-base --is-ancestor "$s" "$INCR_BASE" 2>/dev/null; then
    printf '%s' "$INCR_BASE"
  else
    printf '%s' "$s"
  fi
}

# ── область: файл → тег первой заморозки (как у барьера) ─────────────────────
TMP="$(mktemp -d "${TMPDIR:-/tmp}/st113.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
: > "$TMP/pairs"
for f in AGENTS.md ROADMAP.md; do
  git -C "$ROOT" cat-file -e "HEAD:$f" 2>/dev/null || continue
  printf '%s\t%s\n' "$f" 'ustav/1' >> "$TMP/pairs"
done
_lt=0
git -C "$ROOT" ls-tree -r --name-only HEAD -- ':(literal)plans/' ':(literal)contracts/' > "$TMP/ls-raw" 2>/dev/null || _lt=$?
[ "$_lt" -eq 0 ] || { bad 'область устава не читается (ls-tree)'; exit 1; }
awk '/\.md$/' "$TMP/ls-raw" | sort > "$TMP/docs"
while IFS= read -r f; do
  [ -n "$f" ] || continue
  dir="${f%%/*}"; base="${f##*/}"
  [ "$dir/$base" = "$f" ] || continue
  case "$base" in [0-9][0-9][0-9]-*) NNN="${base%%-*}";; *) continue;; esac
  git -C "$ROOT" rev-parse --verify --quiet "refs/tags/frozen/$dir/$NNN/1" >/dev/null || continue
  printf '%s\t%s\n' "$f" "frozen/$dir/$NNN/1" >> "$TMP/pairs"
done < "$TMP/docs"

# Точка лжи ST113_PAR_FILTER (s11 «зашитая константа», вердикт адверсария круг 1:
# пропуск contracts/777-secret.md в быстром пути): default — область устава
# выводится из ls-tree+тегов и НЕ фильтруется; ложь — оставить только зашитый
# перечень известных батарее имён (вырожденный случай — skip чужого имени).
"${ST113_PAR_FILTER:-true}"
# ── кеш: ветвь (в′) — через точку лжи ST113_KESH ─────────────────────────────
INCR_WINDOW=""
if [ -n "$INCR_CACHE" ] && [ -f "$INCR_CACHE" ]; then
  INCR_BASE="$(head -c 40 "$INCR_CACHE" 2>/dev/null || true)"
  if [ -n "$INCR_BASE" ] && git -C "$ROOT" rev-parse --verify --quiet "$INCR_BASE^{commit}" >/dev/null 2>&1; then
    if ! git -C "$ROOT" merge-base --is-ancestor "$INCR_BASE" HEAD 2>/dev/null; then
      "${ST113_KESH:-st113_kesh_default}"
    else
      INCR_WINDOW="$INCR_BASE..HEAD"
    fi
  fi
fi

# ── одиночный проход (default ST113_OBHOD) ───────────────────────────────────
st113_range_default() { printf '%s\n' HEAD; }
st113_obhod_odin_prohod() {
  # ЧЕСТНЫЙ диапазон прохода — ВСЕГДА HEAD: кеш сужает судимое множество ТОЛЬКО
  # per-document (st113_eff_since ниже), как lib_incr 083. Глобальная обрезка
  # прохода окном cache..HEAD — НЕ зеркало per-document диапазона since..HEAD
  # (обход круга 2 критика: боковая заморозка после кеша теряла нарушение);
  # эта ложь — точка ST113_RANGE (s9).
  local range; range="$("${ST113_RANGE:-st113_range_default}")"
  mapfile -t _logargv < <("${ST113_MERGE:-st113_merge_default}"; \
                          "${ST113_FILTER:-st113_filter_default}"; \
                          "${ST113_RENAMES:-st113_renames_default}"; \
                          "${ST113_LOG_ARGS:-st113_log_args_default}")
  _lr=0
  # Маркер \x01 (SOH) — имя файла с control-символом невозможно в git, поэтому
  # строки-маркеры коммитов неотличимы от имён путей только для сломанного дерева.
  git -C "$ROOT" log --format=$'\x01%H' --name-only "${_logargv[@]}" "$range" > "$TMP/pass" 2>/dev/null || _lr=$?
  [ "$_lr" -eq 0 ] || { bad 'история не читается (git log rc='"$_lr"')'; return; }
  local c="" line p since
  while IFS= read -r line; do
    case "$line" in
      $'\x01'*) c="$("${ST113_SHA_DLINA:-st113_sha_dlina_default}" "${line#$'\x01'}")" ;;
      "") ;;
      *)
        [ -n "$c" ] || continue
        p="$line"
        since="$(awk -F'\t' -v f="$p" '$1 == f { print $2; exit }' "$TMP/pairs")"
        [ -n "$since" ] || continue
        if "${ST113_SUDIM:-st113_sudim_default}" "$(st113_eff_since "$since")" "$c"; then
          changes=$((changes + 1))
          if razreshil "$c" "$p"; then
            excused=$((excused + 1))
            ok "уставной документ изменён с разрешения владельца: $p в ${c:0:8}"
          else
            printf '%s\n' "$p" >> "$TMP/failed_docs"
            bad "уставной документ изменён без разрешения владельца: $p в ${c:0:8} — тело коммита обязано нести строку «РАЗРЕШИЛ-ВЛАДЕЛЕЦ: $p <причина>» в первой колонке"
          fi
        fi
        ;;
    esac
  done < "$TMP/pass"
}

"${ST113_OBHOD:-st113_obhod_odin_prohod}"
doc_fails_start="$fails"
while IFS=$'\t' read -r f since; do
  [ -n "$f" ] || continue
  docs=$((docs + 1))
  if [ -f "$TMP/failed_docs" ] && grep -qxF -- "$f" "$TMP/failed_docs"; then
    continue   # зеркально барьеру: ok-строка подавлена, если документ дал FAIL
  fi
  scanned="$(git -C "$ROOT" rev-list --count "$since..HEAD" 2>/dev/null || printf 0)"
  ok "$f — уставной с $since, коммитов в диапазоне $scanned, изменений без разрешения нет"
done < "$TMP/pairs"

printf '\nуставных документов: %d · изменений в них: %d · с разрешения: %d\n' \
  "$docs" "$changes" "$excused" >&2
[ "$fails" -eq 0 ] || exit 1
# Запись кеша (инвариант «Запись кеша», арбитраж круга 3): на rc 0 пишется
# ТОЛЬКО HEAD начала HEAD0 — снимок до любого чтения истории (зеркало
# incr_finish 083, пишущей $INCR_HEAD; сеяние для d9 и поимки s9).
# Точка лжи ST113_FINISH (s10): подмена на перечитывание HEAD конца —
# отметка обгоняет проверенный объём, ловится клеткой гонки.
st113_finish_default() { printf '%s\n' "$HEAD0" > "$INCR_CACHE" 2>/dev/null || true; }
if [ -n "$INCR_CACHE" ]; then
  "${ST113_FINISH:-st113_finish_default}"
fi
exit 0
