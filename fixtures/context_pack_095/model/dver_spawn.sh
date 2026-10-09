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
# Новая нога (контракт 095): перед сверками реестра/тегов 023 дверь требует
# построенный пак: файл манифеста <root>/.omp/context/<NNN>.tsv существует и
# непуст; иначе — rc 1 «ОТКАЗ: нет манифеста make_task: <NNN>».
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

if [ -z "$root_arg" ]; then ROOT="$(pwd -P 2>/dev/null || pwd)"; else
  ROOT="$(cd "$root_arg" 2>/dev/null && pwd -P 2>/dev/null)" || {
    printf 'NOT_IMPLEMENTED: %s не каталог\n' "$root_arg" >&2; exit 2; }
fi

# NNN: явный номер; без --nnn — следующий свободный по веткам wip/<N>/*
if [ -z "$nnn" ]; then
  nnn="$(git -C "$ROOT" for-each-ref --format='%(refname:short)' 'refs/heads/wip/*/*' 2>/dev/null \
    | sed -n 's|^wip/\([0-9][0-9][0-9]\)/.*|\1|p' | LC_ALL=C sort -u | tail -n 1)"
  [ -n "$nnn" ] || { printf 'ОТКАЗ: номер не определён\n' >&2; exit 1; }
fi
case "$nnn" in ''|*[!0-9]*) printf 'ОТКАЗ: номер вне алфавита: %s\n' "$nnn" >&2; exit 1 ;; esac

# ── контракт 095, Решение 5: обязательность пака на двери ────────────────────
MAN="$ROOT/.omp/context/$nnn.tsv"
if [ ! -s "$MAN" ]; then
  printf 'ОТКАЗ: нет манифеста make_task: %s\n' "$nnn" >&2 # t95-m15
  exit 1
fi

# контракт выхода 016 — ровно две строки
printf 'WORKTREE=%s/wt-mock-%s\nBRANCH=wip/%s/%s\n' "$ROOT" "$nnn" "$nnn" "$author"
exit 0
