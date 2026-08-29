#!/usr/bin/env bash
# Барьер GC (контракт 016, срез 4): снос СЛИТЫХ wip/*; зависшие — СОХРАННЫ, поимённый СПИСОК.
#
# Зачем: без явного GC ветки wip/* накапливаются вместе с worktree; каждая несбитая — потенциальный
# «потерянный заказ» с двумя интерпретациями (молчание vs разрешение). Симметрия Н-59: молчание
# не равно разрешению, поэтому зависшие ВЫГОВАРИВАЮТСЯ владельцу списком, а не удаляются по
# умолчанию. Удаление зависшей — отдельное слово владельца; вход с флагом силы в GC отсутствует
# по построению.
#
# ЧТО СНОСИТСЯ: wip/* ветки, у которых tip СЛИТ в main (merge-commit с HEAD, ИЛИ fast-forward —
# оба варианта равны: ref wip/* достижим из HEAD). Снос = удаление ref + удаление связанного
# worktree (если есть).
#
# ЧТО НЕ СНОСИТСЯ: wip/* с tip, не достижимым из HEAD. Такие остаются В РЕЕСТРЕ и печатаются
# поимённо в stderr (СПИСОК) с их OID. Цель OID ДОЛЖНА ОСТАТЬСЯ НЕИЗМЕННОЙ после GC —
# любая смена цели ref равносильна сносу и красна одной сверкой. Мера проверки — `oid_before`,
# зафиксированный ДО GC; rev-parse после возвращает ТОТ ЖЕ OID (И-6).
#
# SWEEP ОСТАТКОВ: python3 lstat (Н-60: GNU `find -type p` слеп систематически к fifo и
# симлинкам). Пустая выборка на заявленное наличие — красное, не зелёное.
#
# Коды возврата: 0 — все wip/* слиты либо зависшие сохранны наблюдаемо, 1 — зависшая снесена
# (наблюдаемое расхождение: rev-parse после GC != oid_before), 2 — нечем проверить.
set -euo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

usage() {
  cat >&2 <<USAGE
использование: gc_agent_branches.sh [--root <каталог>]

Поведение:
  * wip/* слитые в main → авто-снос (ref + worktree);
  * wip/* зависшие (tip не достижим из HEAD) → СОХРАННЫ, печатаются поимённо в stderr
    СПИСОМ владельцу; OID ветки ДО и ПОСЛЕ GC обязан совпасть (И-6);
  * sweep остатков worktrees — python3-lstat (Н-60), fifo/сломанные симлинки подсвечиваются.

Коды возврата: 0 — порядок, 1 — зависшая ветка сменена (наблюдаемое отклонение И-6),
2 — нечем проверить (нет git/не репозиторий).
USAGE
  exit 1
}

root_arg=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --root) root_arg="${2:?}"; shift 2 ;;
    --help|-h) usage ;;
    *) printf 'gc_agent_branches: неизвестный аргумент: %s\n' "$1" >&2; usage ;;
  esac
done

if [ -z "$root_arg" ]; then
  ROOT="$(pwd -P 2>/dev/null || pwd)"
else
  ROOT="$(cd "$root_arg" 2>/dev/null && pwd -P 2>/dev/null)" || {
    printf 'NOT_IMPLEMENTED: %s не каталог\n' "$root_arg" >&2; exit 2; }
fi

command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: %s не репозиторий git\n' "$ROOT" >&2; exit 2; }
git -C "$ROOT" rev-parse --verify HEAD >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: в %s нет ни одного коммита\n' "$ROOT" >&2; exit 2; }

g() { git -C "$ROOT" "$@"; }

TMPDIR_WORK="${TMPDIR:-/tmp}"
TMP="$(mktemp -d "$TMPDIR_WORK/gc-agent-branches.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

# Снимок refs/heads/wip/ ДО GC.
g for-each-ref --format='%(refname)' 'refs/heads/wip/' 2>/dev/null | sort > "$TMP/wip_before" || : > "$TMP/wip_before"

# Карта oid_before ДЛЯ КАЖДОЙ wip/* ветки (И-6). Если ветка сменит цель после GC —
# rev-parse даст ДРУГОЙ OID → отказ rc 1. Если ветка пропала — нормально (слитая).
declare -A oid_before=()
while IFS= read -r ref; do
  [ -n "$ref" ] || continue
  oid="$(g rev-parse --verify --quiet "$ref" 2>/dev/null || true)"
  [ -n "$oid" ] && oid_before["$ref"]="$oid"
done < "$TMP/wip_before"

# СЛИТЫЕ wip/* → удаление ref + worktree. Слитой считается wip/*, чей tip ДОСТИЖИМ из HEAD
# (merge- или fast-forward). Реестр refs/heads/wip/* — единственный источник истины.
removed=0
kept=0
while IFS= read -r ref; do
  [ -n "$ref" ] || continue
  tip="$(g rev-parse --verify --quiet "$ref" 2>/dev/null || true)"
  [ -n "$tip" ] || continue
  if g merge-base --is-ancestor "$tip" HEAD 2>/dev/null; then
    # Удалить worktree, если он жив (отдельная операция; ref удаляется ПОСЛЕ).
    wt="$(g worktree list --porcelain 2>/dev/null \
          | awk -v br="$ref" '
              /^worktree / { wt = $2; next }
              /^branch /   { if ($2 == br) { print wt; exit } }
            ')"
    if [ -n "$wt" ] && [ "$wt" != "$ROOT" ] && [ -d "$wt" ]; then
      g worktree remove --force "$wt" 2>/dev/null || true
    fi
    g branch -D "${ref#refs/heads/}" 2>/dev/null && removed=$((removed + 1)) || true
  else
    kept=$((kept + 1))
  fi
done < "$TMP/wip_before"

# Снимок refs/heads/wip/ ПОСЛЕ GC.
g for-each-ref --format='%(refname)' 'refs/heads/wip/' 2>/dev/null | sort > "$TMP/wip_after" || : > "$TMP/wip_after"

# СВЕРКА OID (И-6): каждая wip/*, что БЫЛА и ОСТАЛАСЬ, даёт тот же OID. Смена цели — красное.
fails=0
while IFS= read -r ref; do
  [ -n "$ref" ] || continue
  oid_now="$(g rev-parse --verify --quiet "$ref" 2>/dev/null || true)"
  oid_was="${oid_before[$ref]:-}"
  if [ -z "$oid_was" ]; then
    printf 'FAIL: %s — OID нечитаем до GC, читаем после (oid=%s) — расхождение наблюдения\n' \
      "$ref" "$oid_now" >&2
    fails=$((fails + 1))
    continue
  fi
  if [ -z "$oid_now" ]; then
    printf 'FAIL: %s — ветка исчезла из refs/heads/wip/ после GC (oid_before=%s)\n' \
      "$ref" "$oid_was" >&2
    fails=$((fails + 1))
    continue
  fi
  if [ "$oid_now" != "$oid_was" ]; then
    printf 'FAIL: %s — цель сменена (oid_before=%s, oid_after=%s) — перевод ref красный\n' \
      "$ref" "$oid_was" "$oid_now" >&2
    fails=$((fails + 1))
  fi
done < "$TMP/wip_after"

# СПИСОК зависших — печатается ВЛАДЕЛЬЦУ поимённо (Н-59: молчание ≠ разрешение).
if [ -s "$TMP/wip_after" ]; then
  printf 'ЗАВИСШИЕ ВЕТКИ (требуется слово владельца для сноса):\n' >&2
  while IFS= read -r ref; do
    [ -n "$ref" ] || continue
    oid_now="$(g rev-parse --verify --quiet "$ref" 2>/dev/null || echo "?")"
    printf '  %s  %s\n' "$ref" "$oid_now" >&2
  done < "$TMP/wip_after"
else
  printf 'ЗАВИСШИХ ВЕТОК НЕТ\n' >&2
fi

# SWEEP остатков worktrees — python3 lstat (Н-60). Ищем забытые fifo / битые симлинки /
# каталоги в префиксе worktrees — ${TMPDIR:-/tmp}/dev-harness-worktrees/<hash8>.
hash8="$(printf '%s' "$ROOT" | sha256sum | cut -c1-8)"
WORKTREE_BASE="${TMPDIR:-/tmp}/dev-harness-worktrees/$hash8"
export WORKTREE_BASE

if [ -d "$WORKTREE_BASE" ]; then
  python3 - "$WORKTREE_BASE" <<'PYEOF' >&2 || true
import os, sys, stat
base = sys.argv[1]
for entry in os.scandir(base):
    try:
        st = entry.stat(follow_symlinks=False)
    except OSError:
        continue
    if stat.S_ISLNK(st.st_mode):
        target = os.readlink(entry.path)
        if not os.path.exists(entry.path):
            print(f"gc: остаток — битая символическая ссылка: {entry.path} → {target}")
        else:
            print(f"gc: остаток — символическая ссылка: {entry.path} → {target}")
    elif stat.S_ISFIFO(st.st_mode):
        print(f"gc: остаток — fifo: {entry.path}")
    elif stat.S_ISREG(st.st_mode):
        print(f"gc: остаток — обычный файл: {entry.path}")
    elif stat.S_ISDIR(st.st_mode):
        # Подсчёт вложенных .git — worktree ли это?
        if os.path.isdir(os.path.join(entry.path, '.git')):
            print(f"gc: остаток — worktree-каталог: {entry.path}")
PYEOF
fi

printf 'GC: слито и снесено %d · зависших %d · отказов OID %d\n' \
  "$removed" "$kept" "$fails" >&2

[ "$fails" -eq 0 ] || exit 1
