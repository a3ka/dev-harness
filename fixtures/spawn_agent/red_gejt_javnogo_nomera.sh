#!/usr/bin/env bash
# ПРЕД-ЗАМОРОЗОЧНОЕ КРАСНОЕ контракта 023, ветвь (ii) — гейт явного номера в
# spawn_agent (Н-77(г), дверь спавна). Договор: `--nnn N` требует живого
# refs/tags/id/CONTRACT/N (show-ref --verify точного имени); отказ rc 1 «номер N не
# выдан — спавн мимо реестра» — именованная причина; место — после разбора
# аргументов (spawn_agent.sh:52-63), до локальной нумерации (:108). Спавн БЕЗ
# --nnn не меняется: автонумерация wip/* (:108-121) жива.
#
# Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (А-82, прецедент red_mera 021): до
# реализации предмет предъявляется ПРЯМЫМ запуском этого файла; конверсия в
# case_* — следующая пачка architect ПОСЛЕ реализации.
#
# ВХОДЫ (Н-39 — привязка к коду; номера РАЗНЫ между воротами):
#   в1 мимо реестра (стаб С4 «spawn-без-гейта» — нынешний код): --nnn 045, тега
#      нет → честный rc 1 «не выдан». СЕГОДНЯ спавн ПРОХОДИТ (rc 0, worktree
#      создан) — КРАСНОЕ предъявлено;
#   в2 чужой класс (стаб С5 «гейт-не-того-класса»): жив id/PLAN/045, id/CONTRACT/045
#      нет → честный rc 1; стаб, матчащий id/*/045, пускает — ловится здесь;
#   в3 выдан — пускает (положительный контроль): id/CONTRACT/047 жив → rc 0,
#      WORKTREE/BRANCH=wip/047/architect напечатаны. ЗЕЛЁНОЕ ДО и ПОСЛЕ (гейт не
#      свёрхблокирующий);
#   в4 без --nnn (канарейка автонумерации): --author sonic → rc 0,
#      BRANCH=wip/001/sonic. ЗЕЛЁНОЕ ДО и ПОСЛЕ.
# Побочный эффект спавна — каталог worktree ВНЕ игрушечного репо
# (${TMPDIR}/dev-harness-worktrees/<hash8 корня>): каждое успешное подспавнивание
# убирается разобранным WORKTREE= (сегодня успешны ВСЕ входы — гейта нет).
#
# СЕГОДНЯ (гейта в коде нет) файл красен именованной причиной на в1 — это и есть
# предъявляемое красное. ПОСЛЕ реализации все ворота дают rc 0.
#
# Коды возврата: 0 — ворота пройдены; 1 — именованный отказ (гейт отсутствует
#               либо нарушил договор на воротах).
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
# shellcheck disable=SC1091
. "$HERE/_repo.sh"
WORK="$(mktemp -d /tmp/red023-gejt.XXXXXX)"   # А-78: свежий WORK вне дерева
trap 'rm -rf "$WORK"' EXIT

# run_spawn <toy> <аргументы spawn>… → $out/$rc, worktree убран
run_spawn() {
  local toy="$1"; shift
  out="$(bash "$REPO/scripts/spawn_agent.sh" --root "$toy" "$@" 2>"$WORK/err")" && rc=0 || rc=$?
  local wt
  wt="$(printf '%s\n' "$out" | sed -n 's/^WORKTREE=//p' | head -1)"
  if [ -n "$wt" ] && [ -d "$wt" ]; then rm -rf "$wt"; fi
}

# ── в1: мимо реестра (стаб С4 — нынешний код, определяющая дельта) ────────────
T1="$WORK/repo_mimo_reestra"
make_repo "$T1"
run_spawn "$T1" --author architect --nnn 045
if [ "$rc" -ne 1 ] || ! grep -qF 'не выдан' "$WORK/err"; then
  printf 'ОТКАЗ: гейт явного номера отсутствует (стаб С4): спавн --nnn 045 без тега id/CONTRACT/045 ПРОШЁЛ (rc %s, ожидан rc 1 «номер 045 не выдан»): %s\n' "$rc" "$(cat "$WORK/err")" >&2
  exit 1
fi

# ── в2: чужой класс (стаб С5 «гейт-не-того-класса») ─────────────────────────────
T2="$WORK/repo_chuzhoj_klass"
make_repo "$T2"
g "$T2" tag -a id/PLAN/045 -m 'выдача механизмом другого класса (фикстура-приманка)'
run_spawn "$T2" --author architect --nnn 045
if [ "$rc" -ne 1 ] || ! grep -qF 'не выдан' "$WORK/err"; then
  printf 'ОТКАЗ: гейт не того класса (стаб С5): спавн --nnn 045 при живом id/PLAN/045 без id/CONTRACT/045 ПРОШЁЛ (rc %s, ожидан rc 1 «не выдан»): %s\n' "$rc" "$(cat "$WORK/err")" >&2
  exit 1
fi

# ── в3: выдан — пускает (положительный контроль) ───────────────────────────────
T3="$WORK/repo_vydan"
make_repo "$T3"
g "$T3" tag -a id/CONTRACT/047 -m 'выдача механизмом (фикстура)'
run_spawn "$T3" --author architect --nnn 047
if [ "$rc" -ne 0 ]; then
  printf 'ОТКАЗ: гейт свёрхблокирующий: спавн --nnn 047 при живом id/CONTRACT/047 отказан (rc %s, ожидан rc 0): %s\n' "$rc" "$(cat "$WORK/err")" >&2
  exit 1
fi
if ! printf '%s\n' "$out" | grep -qF 'WORKTREE=' \
   || ! printf '%s\n' "$out" | grep -qxF 'BRANCH=wip/047/architect'; then
  printf 'ОТКАЗ: контракт вывода спавна нарушен (WORKTREE/BRANCH=wip/047/architect): %s\n' "$out" >&2
  exit 1
fi

# ── в4: без --nnn — автонумерация жива (канарейка) ─────────────────────────────
T4="$WORK/repo_bez_nnn"
make_repo "$T4"
run_spawn "$T4" --author sonic
if [ "$rc" -ne 0 ] \
   || ! printf '%s\n' "$out" | grep -qxF 'BRANCH=wip/001/sonic'; then
  printf 'ОТКАЗ: автонумерация wip/* сломана (ожидан rc 0, BRANCH=wip/001/sonic): rc %s, %s\n' "$rc" "$out" >&2
  exit 1
fi

exit 0
