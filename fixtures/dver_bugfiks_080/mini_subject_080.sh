#!/usr/bin/env bash
# mini_subject_080.sh — SUBJECT-STUB для стаб-мутаций scripts/orch_restart.sh
# (контракт 080). Используется как честная копия предмета (после
# реализации) и как основа для стабов (s1-s5). По аналогии с
# mini_core_078.sh: «пак 5 стабов одной строкой-заменой по маркеру
# `# STUB:<метка>` на копию».
#
# Структура: pass-through для всех ног гейта 072 (HEAD==origin,
# porcelain пуст, HANDOFF-identity, detector, worktree) — СВОИ
# проверки на identity (а) + живых субагентах (б).
# Минимальный git-контекст: HEAD==origin==main, porcelain пуст,
# HANDOFF.md коммитом «identity» (той же, что в env/--as).
#
# Маркеры (НЕ правятся реализацией — это файл батареи):
#   STUB:IDENTITY_FILECONFIG  — заменить identity-пешную ветвь на
#     вариант «только git config user.name», игнорируя env и --as
#   STUB:IDENTITY_AS_REQUIRED  —_REQUIRED  — заменить identity-пешную
# ветвь на вариант, требующий --as всегда (env игнорируется)
#   STUB:AS_NO_VALUE         — пустая строка после --as не отказ (defect)
#   STUB:SKIP_AGENTS         — живой субагент не блокирует (defect)
#   STUB:AS_MULTI            — --as foo --as bar без отказа (defect)
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
[ -n "$ROOT" ] || { printf 'NOT_IMPLEMENTED: не репозиторий\n' >&2; exit 2; }

MARKER="${ORCH_RESTART_MARKER:-/tmp/dev-harness-verify/orch-restart-stub}"
SESS="${ORCH_SESS_DIR:-/tmp/dev-harness-verify/_nope_sess_$$}"
TRACE="${ORCH_SESSION_START:-/tmp/dev-harness-verify/orch-session-start-stub}"

refuse() { printf 'ОТКАЗ: %s\n' "$1" >&2; exit 1; }

# ── pass-through гейта 072 (всегда зелёный для toy-мира): HEAD==origin,
# porcelain пуст, HANDOFF-identity (см. toy_make в батарее).
h="$(git -C "$ROOT" rev-parse HEAD 2>/dev/null)" || refuse "нет HEAD"
o="$(git -C "$ROOT" rev-parse origin/main 2>/dev/null)" || refuse "нет origin"
[ "$h" = "$o" ] || refuse 'HEAD расходится с origin/main'
[ -z "$(git -C "$ROOT" status --porcelain 2>/dev/null)" ] || refuse 'porcelain непуст'

# ── Identity (предмет а) ────────────────────────────────────────────────
IDENTITY=""
# Приоритет 1: env
if [ -n "${GIT_AUTHOR_NAME:-}" ]; then IDENTITY="$GIT_AUTHOR_NAME"
elif [ -n "${GIT_COMMITTER_NAME:-}" ]; then IDENTITY="$GIT_COMMITTER_NAME"
fi
# Приоритет 2: --as
while [ "$#" -gt 0 ]; do
  case "$1" in
    --as)
      shift
      if [ -z "${1:-}" ]; then
        refuse 'identity двери не определена: ни env GIT_AUTHOR_NAME/GIT_COMMITTER_NAME, ни --as'
      fi
      if [ -n "$IDENTITY" ]; then
        refuse '--as задан дважды'
      fi
      IDENTITY="$1"
      shift
      ;;
    *) shift ;;
  esac
done

if [ -z "$IDENTITY" ]; then
  refuse 'identity двери не определена: ни env GIT_AUTHOR_NAME/GIT_COMMITTER_NAME, ни --as'
fi

# HANDOFF-identity (pass-through): последний committer HANDOFF.md ==
# identity (toy-мир предписывает то же).
cname="$(git -C "$ROOT" log -1 --format=%cn -- HANDOFF.md 2>/dev/null)" || refuse "нет HANDOFF.md"
[ "$cname" = "$IDENTITY" ] || refuse 'HANDOFF.md изменён не этой сессией'

# ── Живые субагенты (предмет б) ────────────────────────────────────────
FRESH_NAMES=""
if [ -d "$SESS" ]; then
  NOW=$(date +%s)
  for f in "$SESS"/*.jsonl; do
    [ -e "$f" ] || continue
    mt=$(stat -c %Y "$f" 2>/dev/null || echo 0)
    [ "$((NOW - mt))" -lt 120 ] || continue
    n=$(basename "$f" .jsonl)
    if [ -z "$FRESH_NAMES" ]; then FRESH_NAMES="$n"; else FRESH_NAMES="$FRESH_NAMES,$n"; fi
  done
  if [ -n "$FRESH_NAMES" ]; then
    # Сортировка имён через запятую (правило 8: форма, не смысл)
    SORTED=$(printf '%s\n' "$FRESH_NAMES" | tr ',' '\n' | sort | paste -sd ',' -)
    FRESH_NAMES="$SORTED"
  fi
fi
if [ -n "$FRESH_NAMES" ]; then
  refuse "живые субагенты: $FRESH_NAMES"
fi

# ── Стартовый след (pass-through) — инициализация при отсутствии ───────
mkdir -p "$(dirname "$TRACE")"
if [ ! -f "$TRACE" ]; then
  printf '%s\n' "$(date -Is)" > "$TRACE.tmp.$$"
  mv -f "$TRACE.tmp.$$" "$TRACE"
fi

# ── Маркер атомарно ────────────────────────────────────────────────────
mkdir -p "$(dirname "$MARKER")"
: > "$MARKER.tmp.$$" || refuse "запись маркера не удалась"
mv -f "$MARKER.tmp.$$" "$MARKER" || refuse "запись маркера не удалась"

printf 'ПЕРЕЗАПУСК: identity=%s\n' "$IDENTITY"
exit 0