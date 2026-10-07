#!/usr/bin/env bash
# gen_plan.sh — запись блоков ROADMAP (И-4) и HANDOFF (И-5) из registry/plan.tsv (контракт 084 §И-6).
#
# Использование: bash scripts/gen_plan.sh --write [--root <dir>]
#   --write            — пишет блоки (без флага — тестовый/пустой режим, rc 1).
#   --root <dir>       — корень проверяемого дерева (по умолчанию — каталог скрипта).
#
# Коды возврата:
#   0 — блоки записаны (или в HANDOFF.md без маркеров — дописаны в конец, Р5).
#   1 — отказ И-6 (план недоступен, битый, или маркеры блока непарные/повторные в файле).
#   2 — NOT_IMPLEMENTED (нет git).
set -uo pipefail
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Подключение от СВОЕГО каталога: код lib_plan.sh НЕ из проверяемого дерева.
# shellcheck disable=SC1091
. "$SELF_DIR/lib_plan.sh"

die()  { printf 'gen_plan: %s\n' "$*" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

write=0
root="$SELF_DIR/.."
while [ $# -gt 0 ]; do
  case "$1" in
    --write) write=1; shift ;;
    --root)  [ $# -ge 2 ] || die "--root требует путь"; root="$2"; shift 2 ;;
    *)       die "флаг вне грамматики: $1"; shift ;;
  esac
done

[ "$write" -eq 1 ] || die "gen_plan без --write не пишет: bash scripts/gen_plan.sh --write"

command -v git >/dev/null 2>&1 || skip "нет git"
[ -d "$root" ] || skip "корня нет: $root"
root="$(cd "$root" && pwd)"
git -C "$root" rev-parse --git-dir >/dev/null 2>&1 || skip "корень не git-репозиторий: $root"

PLAN="$root/registry/plan.tsv"
[ -f "$PLAN" ] || die "план недоступен: registry/plan.tsv отсутствует"
plan_parse "$PLAN" || die "$P84_PLAN_ERR"

ROADMAP="$root/ROADMAP.md"
[ -f "$ROADMAP" ] || die "ROADMAP.md не существует: $ROADMAP"

# ПРОВЕРКА ОБОИХ БЛОКОВ ДО МУТАЦИИ (И-6: «ни один файл не тронут»). Сначала ROADMAP и
# HANDOFF — оба проверяем, что маркеры либо валидная пара, либо отсутствуют (последнее
# для ROADMAP недопустимо — «нет блока»).
roadmap_block="$(p84_render_roadmap_block)"
HANDOFF="$root/HANDOFF.md"
handoff_block="$(p84_render_handoff_block "$root")"

# ── ROADMAP: маркеры по одному и BEGIN<END (иначе «не один» / «нет блока»).
if ! p84_block_index "$ROADMAP" "$P84_RM_BEGIN" "$P84_RM_END" 2>/dev/null; then
  bc="$(grep -cFx "$P84_RM_BEGIN" "$ROADMAP" 2>/dev/null || true)"
  ec="$(grep -cFx "$P84_RM_END" "$ROADMAP" 2>/dev/null || true)"
  if [ "${bc:-0}" -gt 1 ] || [ "${ec:-0}" -gt 1 ]; then
    die "блок плана в ROADMAP.md не один"
  fi
  die "в ROADMAP.md нет блока плана"
fi

# ── HANDOFF: маркеры либо валидная пара (заменяем), либо оба отсутствуют (дописываем
# в конец, И-5, с4). «Не один» — BEGIN/END с числом ≠ 1, или END выше BEGIN.
if [ -f "$HANDOFF" ]; then
  hb="$(grep -cFx "$P84_HO_BEGIN" "$HANDOFF" 2>/dev/null || true)"
  he="$(grep -cFx "$P84_HO_END" "$HANDOFF" 2>/dev/null || true)"
  if [ "${hb:-0}" -gt 0 ] || [ "${he:-0}" -gt 0 ]; then
    # маркеры есть — нужна валидная (по одному, BEGIN<END)
    if ! p84_block_index "$HANDOFF" "$P84_HO_BEGIN" "$P84_HO_END" 2>/dev/null; then
      die "блок «Следующая сессия» в HANDOFF.md не один"
    fi
  fi
fi

# ── МУТАЦИЯ: только сейчас пишем оба файла.
p84_apply_block "$ROADMAP" "$P84_RM_BEGIN" "$P84_RM_END" "$roadmap_block" \
  || die "блок плана в ROADMAP.md не один"
if [ -f "$HANDOFF" ] && grep -Fqx "$P84_HO_BEGIN" "$HANDOFF"; then
  p84_apply_block "$HANDOFF" "$P84_HO_BEGIN" "$P84_HO_END" "$handoff_block" \
    || die "блок «Следующая сессия» в HANDOFF.md не один"
else
  p84_append_block "$HANDOFF" "$P84_HO_BEGIN" "$P84_HO_END" "$handoff_block" \
    || die "блок «Следующая сессия» в HANDOFF.md не один"
fi