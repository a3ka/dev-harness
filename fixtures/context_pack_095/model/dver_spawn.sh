#!/usr/bin/env bash
# Честная модель двери спавна (контракт 095, Решение 5) — носитель ГРАММАТИКИ
# новой ноги scripts/spawn_agent.sh «нет манифеста make_task» (II-3 дословно:
# spawn_agent отказывает без манифеста make_task). Модель — не продукт: несёт
# ТОЛЬКО новую ногу и контракт выхода 016 (WORKTREE=/BRANCH= ровно две строки);
# остальные ноги живой двери (id/CONTRACT 023, worktree, identity) — не здесь.
#
# CLI (дословно как у живой двери):
#   dver_spawn.sh --author <имя> [--nnn <номер>] [--root <каталог>]
#
# Новая нога (контракт 095, Решение 5; cutover-1113 — внешнее размещение):
# манифест пака живёт ТОЛЬКО во внешнем state проекта по формуле 161a —
# <канонический TMPDIR>/dev-harness-project-state/<первые 16 hex
# sha256(общий .git)>/context/<NNN %03d>.tsv; main checkout и linked WT
# сходятся в один каталог (общий .git — общий ключ). Нога действует в скоупе
# живого дерева (А-385): маркер — читаемый <root>/harness.project.json; в
# мирах без маркера нога молчит. Устаревшее размещение <root>/.omp/context/
# <NNN>.tsv НЕ читается: fallback нет — при отсутствии внешнего манифеста
# rc 1 «ОТКАЗ: нет манифеста make_task: <NNN>» ДО сверок 023. Границы 161a
# не ослаблены: TMPDIR внутри чекаутов проекта (всех, по worktree list) или
# общего .git — отказ до побочных эффектов; файл-манифест — символьная
# ссылка → MANIFEST_LINK_UNSAFE.
# Нога не ослабляет отказы 023: они остаются для входов с манифестом.
set -uo pipefail

usage() {
  printf 'usage: dver_spawn.sh --author <имя> [--nnn <номер>] [--root <каталог>]\n' >&2
  exit 1
}

author=""; nnn=""; root_arg=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --author) author="${2:?}"; shift 2 ;;
    --nnn)    nnn="${2:?}"; shift 2 ;;
    --root)   root_arg="${2:?}"; shift 2 ;;
    *)        usage ;;
  esac
done
[ -n "$author" ] || usage
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v sha256sum >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет sha256sum\n' >&2; exit 2; }

if [ -z "$root_arg" ]; then ROOT="$(pwd -P 2>/dev/null || pwd)"; else
  ROOT="$(cd "$root_arg" 2>/dev/null && pwd -P 2>/dev/null)" || {
    printf 'NOT_IMPLEMENTED: %s не каталог\n' "$root_arg" >&2; exit 2; }
fi

# NNN: явный номер; без --nnn — следующий свободный (max по wip/<N>/* + 1,
# %03d), дословно как авто-ветка живой двери spawn_agent.sh: в свежем
# репозитории без wip/*-веток это 001, не отказ. Сценарий (в) клетки
# red_dver_spawn_manifest.sh судит ногу И-15 в авто-режиме — номер
# разрешается ДО ноги, отказ ноги несёт его в выводе.
if [ -z "$nnn" ]; then
  max_nnn="$(git -C "$ROOT" for-each-ref --format='%(refname)' 'refs/heads/wip/' 2>/dev/null \
    | sed -n 's|^refs/heads/wip/\([0-9][0-9][0-9]*\)/.*|\1|p' | LC_ALL=C sort -n | tail -n 1)"
  nnn="$(printf '%03d' "$((10#${max_nnn:-0} + 1))")"
fi
case "$nnn" in ''|*[!0-9]*) printf 'ОТКАЗ: номер вне алфавита: %s\n' "$nnn" >&2; exit 1 ;; esac
nnn_pad="$(printf '%03d' "$((10#$nnn))")"

# ── контракт 095, Решение 5 (cutover-1113): обязательность пака на двери ──────
# Формула 161a переиспользована, нового каталога/конфига нет: база —
# канонический TMPDIR (внутри чекаута/общего .git — отказ до побочных
# эффектов), ключ — sha256 ОБЩЕГО .git (main и linked WT дают один каталог),
# манифест — context/<NNN %03d>.tsv. Единственный манифест — внешний;
# legacy <root>/.omp/context дверью не читается.
if [ -r "$ROOT/harness.project.json" ]; then
  _base="${TMPDIR:-/tmp}"
  _base="$(cd "$_base" 2>/dev/null && pwd -P 2>/dev/null)" \
    || { printf 'ОТКАЗ: TMPDIR_UNAVAILABLE: непригодный TMPDIR: %s\n' "${TMPDIR:-/tmp}" >&2; exit 1; }
  _common="$(git -C "$ROOT" rev-parse --git-common-dir 2>/dev/null || true)"
  [ -n "$_common" ] || _common="$ROOT/.git"
  case "$_common" in /*) ;; *) _common="$ROOT/$_common" ;; esac
  _common="$(cd "$_common" 2>/dev/null && pwd -P 2>/dev/null)" \
    || { printf 'ОТКАЗ: STATE_PATH_UNRESOLVABLE: общий .git не разрешается: %s\n' "$_common" >&2; exit 1; }
  case "$_base" in
    "$ROOT"|"$ROOT"/*|"$_common"|"$_common"/*) # t95-m35
      printf 'ОТКАЗ: TMPDIR_INSIDE_MAIN: TMPDIR внутри checkout проекта или его .git: %s\n' "$_base" >&2
      exit 1 ;;
  esac
  # Граница 161a — ВСЕ чекауты проекта (как _state_worktree_paths живой
  # двери): TMPDIR внутри ЛЮБОГО связанного чекаута, не только текущего
  # корня, небезопасен; runtime-файлы — вне чекаутов и общего .git.
  while IFS= read -r _wt; do # t95-m36
    [ -n "$_wt" ] || continue
    _wt="$(cd "$_wt" 2>/dev/null && pwd -P 2>/dev/null || true)"
    [ -n "$_wt" ] || continue
    case "$_base" in "$_wt"|"$_wt"/*)
      printf 'ОТКАЗ: TMPDIR_INSIDE_MAIN: TMPDIR внутри checkout проекта или его .git: %s\n' "$_base" >&2
      exit 1 ;;
    esac
  done < <(git -C "$ROOT" worktree list --porcelain 2>/dev/null | sed -n 's/^worktree //p')
  # Канонический ключ 161a (cutover-1113): живой _git_common_dir ЗАХВАТЫВАЕТ
  # вывод канонизации (c="$(cd … pwd -P)") и печатает общий .git ОДИН раз —
  # ключ = первые 16 hex sha256("<common>") без перевода строки (printf '%s',
  # как _hash_sha256_text живого кода). Хешируется один канонический путь;
  # двойная печать pwd была измеренной случайностью deployed-кода до починки
  # родителя и в модели не закрепляется.
  _key="$(printf '%s' "$_common" | sha256sum | cut -c1-16)"
  MAN="$_base/dev-harness-project-state/$_key/context/$nnn_pad.tsv"
  if [ -L "$MAN" ]; then
    printf 'ОТКАЗ: MANIFEST_LINK_UNSAFE: файл манифеста — символьная ссылка: %s\n' "$MAN" >&2
    exit 1
  fi
  if [ ! -s "$MAN" ]; then
    printf 'ОТКАЗ: нет манифеста make_task: %s\n' "$nnn_pad" >&2 # t95-m15
    exit 1
  fi
fi

# контракт выхода 016 — ровно две строки
printf 'WORKTREE=%s/wt-mock-%s\nBRANCH=wip/%s/%s\n' "$ROOT" "$nnn_pad" "$nnn_pad" "$author"
exit 0
