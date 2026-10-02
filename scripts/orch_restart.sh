#!/usr/bin/env bash
# ДВЕРЬ ПЕРЕЗАПУСКА СЕССИИ (контракт 072).
# ЕДИНСТВЕННАЯ постановка маркера /tmp/dev-harness-verify/orch-restart
# (до реализационной пачки — прежний touch по чеклисту; с этой пачкой
# маркер — ТОЛЬКО этой дверью; см. roles/orchestrator.md §Автоперезапуск).
#
# Гейт: пять условий, каждое — именованный отказ rc 1 (маркер НЕ ставится):
#   (а) HEAD == origin/main                                → «HEAD расходится с origin/main»
#   (б) porcelain пуст                                     → «porcelain непуст»
#   (в) HANDOFF.md изменён коммитом ЭТОЙ сессии:
#       (в1) автор ПОСЛЕДНЕГО коммита HANDOFF.md == git config user.name
#                                                            → «HANDOFF.md изменён не этой сессией»
#       (в2) committer-дата этого коммита > стартового следа сессии
#                                                            → «HANDOFF.md изменён до стартового следа сессии»
#   (г) check_no_leak.sh --check rc 0                      → «детектор …»
#   (д) нет мусорных worktree ПОСЛЕ делегирования GC       → «мусорный worktree: <путь>»
#
# Маркер атомарен: ставится ПОСЛЕ всех зелёных проверок; при любом отказе
# маркер отсутствует. Уже стоящий маркер дверь НЕ удаляет — не её
# состояние (инвариант 3).
#
# Стартовый след сессии (инвариант 11): файл ВНЕ дерева, путь — шов
# ORCH_SESSION_START (умолчание /tmp/dev-harness-verify/orch-session-start).
# Содержимое — РОВНО ОДНА строка ISO-8601: момент последнего зелёного
# завершения двери (= граница текущей сессии). Отсутствие следа →
# инициализация «сейчас» + отказ (в2); пустой/нечитаемый → fail-closed rc 2.
#
# Коды возврата:
#   0 — маркер поставлен (stdout несёт строку «ПЕРЕЗАПУСК»)
#   1 — именованный отказ (причина в stderr, маркер не ставится)
#   2 — нечем проверить (NOT_IMPLEMENTED: …; маркер не ставится)

set -uo pipefail

# Гигиена Н-85: снять GIT_DIR/GIT_WORK_TREE и пр. — иначе дверь судит
# чужой репозиторий (прецедент check_no_leak.sh:217-225).
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES \
      GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM

# Тест-швы (инвариант 6): переопределение — дверь НЕ читает и НЕ пишет
# умолчательный путь того же шва.
MARKER="${ORCH_RESTART_MARKER:-/tmp/dev-harness-verify/orch-restart}"
TRACE="${ORCH_SESSION_START:-/tmp/dev-harness-verify/orch-session-start}"

# ROOT резолвится по месту скрипта (Н-85).
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P 2>/dev/null)" \
  || { printf 'NOT_IMPLEMENTED: нет корня скрипта\n' >&2; exit 2; }

command -v git >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

g() { git -C "$ROOT" "$@"; }

# ── санитизация репозитория ──────────────────────────────────────────────────
g rev-parse --git-dir >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: %s не репозиторий git\n' "$ROOT" >&2; exit 2; }
g rev-parse --verify HEAD >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: в %s нет ни одного коммита\n' "$ROOT" >&2; exit 2; }
g rev-parse --verify origin/main >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: нет origin/main\n' >&2; exit 2; }
[ -f "$ROOT/HANDOFF.md" ] \
  || { printf 'NOT_IMPLEMENTED: нет HANDOFF.md\n' >&2; exit 2; }

# ВСЕ git-вызовы — с -C; GIT_CONFIG снят; sanity-gate выше.

# ── (а) HEAD == origin/main ─────────────────────────────────────────────────
h="$(g rev-parse HEAD 2>/dev/null)" \
  || { printf 'NOT_IMPLEMENTED: нет HEAD\n' >&2; exit 2; }
o="$(g rev-parse origin/main 2>/dev/null)" \
  || { printf 'NOT_IMPLEMENTED: нет origin/main\n' >&2; exit 2; }
[ "$h" = "$o" ] \
  || { printf 'ОТКАЗ: HEAD расходится с origin/main\n' >&2; exit 1; }

# ── (б) porcelain пуст ──────────────────────────────────────────────────────
[ -z "$(g status --porcelain)" ] \
  || { printf 'ОТКАЗ: porcelain непуст\n' >&2; exit 1; }

# ── (в) HANDOFF.md изменён коммитом ЭТОЙ сессии ─────────────────────────────
la="$(g log -1 --format=%an -- HANDOFF.md 2>/dev/null)" \
  || { printf 'NOT_IMPLEMENTED: нет HANDOFF.md\n' >&2; exit 2; }
me="$(g config user.name 2>/dev/null)" \
  || { printf 'NOT_IMPLEMENTED: нет git config user.name\n' >&2; exit 2; }
# (в1) identity — author последнего коммита HANDOFF.md == self.user.name
{ [ -n "$la" ] && [ -n "$me" ] && [ "$la" = "$me" ]; } \
  || { printf 'ОТКАЗ: HANDOFF.md изменён не этой сессией\n' >&2; exit 1; }

# Стартовый след (инвариант 11): файла нет → инициализация «сейчас»
# (инициализация НЕ вакуумна); пустой/нечитаемый → fail-closed rc 2.
if [ ! -f "$TRACE" ]; then
  mkdir -p "$(dirname "$TRACE")"
  printf '%s\n' "$(date -Is)" > "$TRACE.tmp.$$" \
    && mv -f "$TRACE.tmp.$$" "$TRACE"
fi
# Инвариант 11 (адверсарий 072-r1 Б2): след обязан нести РОВНО ОДНУ
# непустую строку — лишняя строка до/после валидного ISO-8601-хвоста не
# должна судиться `tail -n 1` вместо границы сессии (мусор\n<ISO> не
# имеет права пройти как «ISO в прошлом»). Считаем непустые строки
# ВСЕГО файла; ровно одна → она и есть t_line, иначе fail-closed rc 2
# ДО `date -d` — испорченный формат не читается частично.
nonblank_n=0; t_line=""
while IFS= read -r _tl || [ -n "$_tl" ]; do
  [ -n "$_tl" ] || continue
  nonblank_n=$((nonblank_n + 1))
  t_line="$_tl"
done < "$TRACE" 2>/dev/null \
  || { printf 'NOT_IMPLEMENTED: стартовый след нечитаем\n' >&2; exit 2; }
[ "$nonblank_n" -eq 1 ] \
  || { printf 'NOT_IMPLEMENTED: стартовый след не ровно одна строка\n' >&2; exit 2; }
t_ep="$(date -d "$t_line" +%s 2>/dev/null)" \
  || { printf 'NOT_IMPLEMENTED: стартовый след нечитаем\n' >&2; exit 2; }
c_ep="$(g log -1 --format=%ct -- HANDOFF.md 2>/dev/null)" \
  || { printf 'NOT_IMPLEMENTED: нет HANDOFF.md\n' >&2; exit 2; }
# (в2) committer-дата > стартового следа
[ "$c_ep" -gt "$t_ep" ] \
  || { printf 'ОТКАЗ: HANDOFF.md изменён до стартового следа сессии\n' >&2; exit 1; }

# ── (г) check_no_leak --check rc 0 ──────────────────────────────────────────
dout="$(bash "$ROOT/scripts/check_no_leak.sh" --check "$ROOT" 2>&1)"; drc=$?
[ "$drc" -eq 0 ] \
  || { printf 'ОТКАЗ: детектор красен: %s\n' "$dout" >&2; exit 1; }

# ── (д) нет мусорных worktree ПОСЛЕ делегирования GC ───────────────────────
# Мусорный worktree (инвариант 4): запись git worktree list --porcelain
# НЕ основного чекаута, чья ветка НЕ refs/heads/wip/[0-9]{3}/<автор>
# (включая detached/bare). GC СВОЕГО корня расширением удаляет чистые
# приземлённые мусорные; грязные/неприземлённые — называются GC.
gc_rc=0
bash "$ROOT/scripts/gc_agent_branches.sh" --root "$ROOT" >/dev/null 2>&1 || gc_rc=$?
# rc GC нас не интересует — список worktree ПЕРЕСНИМАЕТСЯ после GC;
# грязные/неприземлённые GC мог назвать, наш гейт — список ПОСЛЕ GC.

found_garbage=0
while IFS='|' read -r wt_path wt_head wt_branch; do
  [ -n "$wt_path" ] || continue
  [ "$wt_path" = "$ROOT" ] && continue
  case "$wt_branch" in
    refs/heads/wip/[0-9][0-9][0-9]/*) continue ;;
  esac
  if [ "$found_garbage" -eq 0 ]; then
    printf 'ОТКАЗ: мусорный worktree: %s\n' "$wt_path" >&2
    found_garbage=1
  fi
done < <(g worktree list --porcelain | awk '
  /^worktree / { if (p != "") print p "|" h "|" b; p=substr($0,10); h=""; b="detached" }
  /^HEAD /     { h=substr($0,6) }
  /^branch /   { b=substr($0,8) }
  /^bare$/     { b="bare" }
  END { if (p != "") print p "|" h "|" b; }
')
[ "$found_garbage" -eq 0 ] || exit 1

# ── ВСЁ ЗЕЛЁНОЕ: атомарная перезапись следа + постановка маркера ────────────
mkdir -p "$(dirname "$MARKER")"
: > "$MARKER.tmp.$$" \
  || { printf 'ОТКАЗ: запись маркера не удалась: %s\n' "$MARKER" >&2; exit 1; }
mv -f "$MARKER.tmp.$$" "$MARKER" \
  || { printf 'ОТКАЗ: запись маркера не удалась: %s\n' "$MARKER" >&2; exit 1; }

mkdir -p "$(dirname "$TRACE")"
if ! ( printf '%s\n' "$(date -Is)" > "$TRACE.tmp.$$" \
       && mv -f "$TRACE.tmp.$$" "$TRACE" ); then
  rm -f "$MARKER" 2>/dev/null || true
  printf 'ОТКАЗ: запись следа не удалась: %s\n' "$TRACE" >&2
  exit 1
fi

printf 'ПЕРЕЗАПУСК: маркер поставлен\n'
exit 0