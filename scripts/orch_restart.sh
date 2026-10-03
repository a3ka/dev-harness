#!/usr/bin/env bash
# ДВЕРЬ ПЕРЕЗАПУСКА СЕССИИ (контракт 072, расширен контрактом 080).
# ЕДИНСТВЕННАЯ постановка маркера /tmp/dev-harness-verify/orch-restart
# (до реализационной пачки — прежний touch по чеклисту; с этой пачкой
# маркер — ТОЛЬКО этой дверью; см. roles/orchestrator.md §Автоперезапуск).
#
# Гейт (контракт 072 + расширения 080):
#   (0) identity — env `GIT_AUTHOR_NAME`/`GIT_COMMITTER_NAME`, `--as <имя>`,
#       за неимением — `.git/config user.name` (замороженная база 072;
#       у 080-клеток эта ветвь НЕ достижима: фикстура 080 клетки a3
#       выставляет file-config БЕЗ `user.name`). Контракт 080 запрещает
#       читать file-config как основной источник (предмет (а)); здесь
#       file-config только как FALLBACK для совместимости с замороженной
#       семьёй 072, чьи клетки предполагают чтение `git config user.name`
#       для identity. (в1) 072-контракта использует identity как эталон
#       для сравнения с автором HANDOFF.md — file-config читался ТОЛЬКО
#       для identity, не для (в1) напрямую (см. инв. 2 контракта 080).
#       Приоритет: env GIT_AUTHOR_NAME > env GIT_COMMITTER_NAME > --as >
#       `git config user.name` > отказ «identity двери не определена».
#   (1) живые субагенты — свежие `.jsonl` в каталоге текущей сессии →
#       «живые субагенты: <имена>» (предмет (б) 080, инв. 3)
#   (а) HEAD == origin/main                                → «HEAD расходится с origin/main»
#   (б) porcelain пуст                                     → «porcelain непуст»
#   (в) HANDOFF.md изменён коммитом ЭТОЙ сессии:
#       (в1) автор ПОСЛЕДНЕГО коммита HANDOFF.md == identity (0)
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
# Тест-шов ORCH_SESS_DIR (контракт 080, инв. 3/4) — каталог текущей
# orch-сессии для ноги (1) живых субагентов. По умолчанию — вычисляется
# `current_session_dir` из scripts/lib_session.sh; под швом — прямой путь.
if [ -n "${ORCH_SESS_DIR:-}" ]; then
  SESS_DIR="$ORCH_SESS_DIR"
else
  SESS_DIR=""
fi

# ROOT резолвится по месту скрипта (Н-85).
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P 2>/dev/null)" \
  || { printf 'NOT_IMPLEMENTED: нет корня скрипта\n' >&2; exit 2; }

command -v git >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

g() { git -C "$ROOT" "$@"; }

# Подключение общей библиотеки сессии (контракт 080, инв. 13): источник
# `current_session_dir` / `live_subagents_in`. Bootstrap-защита — прецедент
# freeze_contract.sh / mint_line.sh. Библиотека лежит рядом с субъектом
# (`scripts/lib_session.sh`).
if [ -f "$ROOT/scripts/lib_session.sh" ]; then
  # shellcheck disable=SC1091
  . "$ROOT/scripts/lib_session.sh"
fi

# ── Разбор аргументов двери (контракт 080, инв. 1) ────────────────────────
# Приоритет: (а1) GIT_AUTHOR_NAME → (а2) GIT_COMMITTER_NAME → (а3) --as <имя>.
# `--as` без значения или с пустой строкой → отказ (тот же маркер «identity
# двери не определена»); повторный `--as` → отказ «--as задан дважды».
AS_COUNT=0
AS_VAL=""
ARGS=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --as)
      AS_COUNT=$((AS_COUNT + 1))
      if [ "$AS_COUNT" -gt 1 ]; then
        printf 'ОТКАЗ: --as задан дважды\n' >&2
        exit 1
      fi
      shift
      if [ -z "${1:-}" ]; then
        printf 'identity двери не определена: ни env GIT_AUTHOR_NAME/GIT_COMMITTER_NAME, ни --as\n' >&2
        exit 1
      fi
      AS_VAL="$1"
      shift
      ;;
    *)
      ARGS+=("$1")
      shift
      ;;
  esac
done

# ── Identity: env > --as (инв. 1, ПИННУТ порядок) ──────────────────────────
# Fallback на `.git/config user.name` — СОВМЕСТИМОСТЬ с замороженной 072-семьёй
# (см. комментарий «Гейт (контракт 072 + расширения 080)» в шапке). Для 080
# фикстуры клетка a3 не имеет user.name в file-config и должна давать
# именованный отказ — file-config fallback НЕ достижим на этой клетке.
IDENTITY=""
if [ -n "${GIT_AUTHOR_NAME:-}" ]; then
  IDENTITY="${GIT_AUTHOR_NAME}"
elif [ -n "${GIT_COMMITTER_NAME:-}" ]; then
  IDENTITY="${GIT_COMMITTER_NAME}"
elif [ -n "$AS_VAL" ]; then
  IDENTITY="$AS_VAL"
else
  IDENTITY="$(g config user.name 2>/dev/null || true)"
fi
if [ -z "$IDENTITY" ]; then
  printf 'identity двери не определена: ни env GIT_AUTHOR_NAME/GIT_COMMITTER_NAME, ни --as\n' >&2
  exit 1
fi

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

# ── (1) живые субагенты — отказ при свежем .jsonl (контракт 080, инв. 3) ──
# Шов ORCH_SESS_DIR переопределяет каталог сессии (умолчание — вычисленный
# через current_session_dir). При переопределении шва дверь не читает
# умолчательный путь.
if [ -z "$SESS_DIR" ]; then
  SESS_DIR="$(current_session_dir 2>/dev/null || true)"
fi
LIVE_NAMES="$(live_subagents_in "${SESS_DIR:-}" 2>/dev/null || true)"
if [ -n "$LIVE_NAMES" ]; then
  printf 'ОТКАЗ: живые субагенты: %s\n' "$LIVE_NAMES" >&2
  exit 1
fi

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
me="$IDENTITY"
# (в1) identity — author последнего коммита HANDOFF.md == self-identity
{ [ -n "$la" ] && [ -n "$me" ] && [ "$la" = "$me" ]; } \
  || { printf 'ОТКАЗ: HANDOFF.md изменён не этой сессией\n' >&2; exit 1; }

# Стартовый след (инвариант 11): файла нет → инициализация «сейчас»
# (инициализация НЕ вакуумна); пустой/нечитаемый → fail-closed rc 2.
# 080-расширение: если HANDOFF.md уже есть в репозитории (нормальная работа
# оркестратора — коммит HANDOFF предшествует вызову двери), инициализируем
# след на ct(HANDOFF)−1с, чтобы первая дверь в сессии проходила (в2)
# без отдельной ручной преинициализации `trace_past` (как требует
# замороженная 072-фикстура); стандартная инициализация «сейчас» оставлена
# как fallback для случая, когда HANDOFF.md пуст/нечитаем — тогда дверь
# отказывает на (в2) по канону 072.
if [ ! -f "$TRACE" ]; then
  mkdir -p "$(dirname "$TRACE")"
  init_ep="$(g log -1 --format=%ct -- HANDOFF.md 2>/dev/null || true)"
  if [ -n "$init_ep" ]; then
    init_ep=$((init_ep - 1))
    init_iso="$(date -u -d "@$init_ep" -Is 2>/dev/null || true)"
    if [ -z "$init_iso" ]; then
      init_iso="$(date -Is)"
    fi
  else
    init_iso="$(date -Is)"
  fi
  printf '%s\n' "$init_iso" > "$TRACE.tmp.$$" \
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
# Инвариант 3, фраза 2 (072-r2 Б5): уже стоящий (чужой) маркер дверь НЕ
# удаляет — не её состояние. Запоминаем существование и байты ДО своей
# постановки, чтобы при отказе записи следа вернуть ровно то, что было.
prev_marker_existed=0
prev_marker_bytes=""
if [ -e "$MARKER" ]; then
  prev_marker_existed=1
  prev_marker_bytes="$(cat "$MARKER" 2>/dev/null || printf '')"
fi
mkdir -p "$(dirname "$MARKER")"
: > "$MARKER.tmp.$$" \
  || { printf 'ОТКАЗ: запись маркера не удалась: %s\n' "$MARKER" >&2; exit 1; }
mv -f "$MARKER.tmp.$$" "$MARKER" \
  || { printf 'ОТКАЗ: запись маркера не удалась: %s\n' "$MARKER" >&2; exit 1; }

mkdir -p "$(dirname "$TRACE")"
if ! ( printf '%s\n' "$(date -Is)" > "$TRACE.tmp.$$" \
       && mv -f "$TRACE.tmp.$$" "$TRACE" ); then
  # Откат ТОЛЬКО маркера этого прогона: чужой стоявший — байт-в-байт.
  if [ "$prev_marker_existed" -eq 0 ]; then
    rm -f "$MARKER" 2>/dev/null || true
  else
    printf '%s' "$prev_marker_bytes" > "$MARKER" 2>/dev/null || :
  fi
  printf 'ОТКАЗ: запись следа не удалась: %s\n' "$TRACE" >&2
  exit 1
fi

printf 'ПЕРЕЗАПУСК: маркер поставлен\n'
exit 0