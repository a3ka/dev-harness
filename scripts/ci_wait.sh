#!/usr/bin/env bash
# scripts/ci_wait.sh — блокирующее ожидание завершения CI по sha ОДНИМ вызовом
# (контракт 092, И-5; rc 0/1/2/3, rc-грамматика ci_diag).
set -uo pipefail

: "${ORCH_STATE_DIR:=/tmp/dev-harness-verify/orch-state}"
: "${ORCH_GH_API:=https://api.github.com}"
: "${ORCH_REPO:=}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_TREE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CHECKPOINT="$SCRIPT_DIR/orch_checkpoint.sh"

# ORCH_REPO по умолчанию — корень дерева скрипта (прецедент ci_diag.sh): slug
# берётся из git remote этого каталога (Б-1). `.git` — каталог в обычном
# чекауте, ФАЙЛ с `gitdir:` в worktree — обе формы распознаём.
if [ -z "$ORCH_REPO" ] && { [ -d "$SCRIPT_TREE_ROOT/.git" ] || [ -f "$SCRIPT_TREE_ROOT/.git" ]; }; then
  ORCH_REPO="$SCRIPT_TREE_ROOT"
fi

# slug_for_repo <repo-dir> — OWNER/REPO из git remote origin URL (Б-1).
slug_for_repo() {
  local repo="$1" url=''
  if [ -d "$repo" ]; then
    url="$(git -C "$repo" remote get-url origin 2>/dev/null || true)"
  fi
  if [ -z "$url" ]; then
    printf '%s' ""
    return
  fi
  printf '%s' "$url" | sed -nE 's#^(ssh://git@github\.com/|git@github\.com:|https://github\.com/)([^/]+)/(.+)$#\2/\3#p' | sed -E 's/\.git$//'
}

# resolve_token — GITHUB_TOKEN из окружения либо .env (прецедент ci_diag).
resolve_token() {
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    printf '%s' "$GITHUB_TOKEN"
    return
  fi
  if [ -f "$SCRIPT_TREE_ROOT/.env" ]; then
    grep -E '^GITHUB_TOKEN=' "$SCRIPT_TREE_ROOT/.env" 2>/dev/null | head -1 | cut -d= -f2-
  fi
}

# read_state_task — текущий task из state.tsv, либо '-' если состояния нет.
read_state_task() {
  if [ ! -f "$ORCH_STATE_DIR/state.tsv" ]; then
    printf -- '-'
    return
  fi
  awk -F'\t' '$1=="task" {print $2; exit}' "$ORCH_STATE_DIR/state.tsv" 2>/dev/null \
    | grep -E '.' || printf -- '-'
}

# Н-1: --sha без значения и --interval 0 — rc 2 (ошибка аргументов, не «CI
# красный» и не «нечем проверить»). Реализовано НЕ через «$2: unbound variable»,
# а явным отказом: set -u не даёт тихо работать с пустым значением.
SHA=""
TIMEOUT=""
INTERVAL=5
ATTEMPTS=30

while [ "$#" -gt 0 ]; do
  case "$1" in
    --sha) [ "$#" -ge 2 ] || { printf "ci_wait: --sha требует значение\n" >&2; exit 2; }; SHA="$2"; shift 2 ;;
    --timeout) [ "$#" -ge 2 ] || { printf "ci_wait: --timeout требует значение\n" >&2; exit 2; }; TIMEOUT="$2"; shift 2 ;;
    --interval) [ "$#" -ge 2 ] || { printf "ci_wait: --interval требует значение\n" >&2; exit 2; }
      # И-5: --interval должен быть положительным числом (Н-1: --interval 0 — rc 2).
      # Допускаются дробные значения (клетки 3/14 гоняют 0.3/0.5 с) — проверка
      # через python float, иначе bash ломается на «0.5» как «invalid number».
      # Б-10: значение передаётся через sys.argv[1] (а НЕ интерполяцией '$2'
      # в python-исходник) — иначе аргумент пользователя исполняется как
      # python-код: проба «--interval "1'); import os; os.system(...)» даёт
      # регрессию исполнения. sys.argv — канал данных, не исходника.
      if ! python3 -c "import sys; v=float(sys.argv[1]); sys.exit(0 if v>0 else 1)" "$2" 2>/dev/null; then
        printf "ci_wait: --interval должен быть положительным числом: %s\n" "$2" >&2; exit 2
      fi
      INTERVAL="$2"
      shift 2 ;;
    --attempts) [ "$#" -ge 2 ] || { printf "ci_wait: --attempts требует значение\n" >&2; exit 2; }
      if ! printf '%s' "$2" | grep -Eq '^[0-9]+$'; then
        printf "ci_wait: --attempts должен быть положительным целым: %s\n" "$2" >&2; exit 2
      fi
      ATTEMPTS="$2"
      if [ "$ATTEMPTS" -le 0 ]; then
        printf "ci_wait: --attempts должен быть положительным целым: %s\n" >&2; exit 2
      fi
      shift 2 ;;
    --) shift; break ;;
    *) printf "ci_wait: неизвестный флаг %s\n" "$1" >&2; exit 2 ;;
  esac
done

if ! printf "%s" "$SHA" | grep -Eq "^[0-9a-f]{40}$"; then
  printf "ci_wait: невалидный sha: %s\n" "$SHA" >&2
  exit 2
fi

TASK="$(read_state_task)"

mkdir -p "$ORCH_STATE_DIR" 2>/dev/null || true

# Б-2: события wait-start/wait-done — ТОЛЬКО через orch_checkpoint.sh event.
# Никаких прямых дозаписей events.tsv мимо checkpoint (ранее события терялись
# при events.tsv read-only либо дублировались без дедупа).
record_event() {  # <kind> <subject> <ref>
  bash "$CHECKPOINT" event "$1" "$2" "$3" || exit "$?"
}

record_event "wait-start" "$TASK" "$SHA"

# Б-1: slug берётся из git remote origin (НЕ заглушка «owner/repo»).
# Если каталог не git-repo либо remote не GitHub — slug пуст, GitHub API
# пропускается (rc 3 «нечем проверить: не GitHub-репо»).
REPO_SLUG=""
if [ -n "$ORCH_REPO" ]; then
  REPO_SLUG="$(slug_for_repo "$ORCH_REPO")"
fi

AUTH_HDR=()
TOKEN_VAL="$(resolve_token)"
[ -n "$TOKEN_VAL" ] && AUTH_HDR=(-H "Authorization: Bearer ${TOKEN_VAL}")

START=$(date +%s)
N=0
RC=3
MSG="таймаут ожидания CI"
if [ -z "$REPO_SLUG" ]; then
  # Не git-repo или remote не GitHub — нет смысла опрашивать
  printf "ci_wait: нечем проверить: не GitHub-репо\n" >&2
  record_event "wait-done" "$TASK" "$SHA"
  exit 3
fi
PATH_API="${ORCH_GH_API}/repos/${REPO_SLUG}/commits/${SHA}/check-runs?per_page=100"

while [ "$N" -lt "$ATTEMPTS" ]; do
  N=$((N + 1))
  TMPF=$(mktemp)
  # Н-2: HTTP-код — НАПРЯМУЮ из curl -w, без побочного файла вне шва.
  # curl пишет %{http_code} в stdout БЕЗ перевода строки; при отказе сети
  # exit не нулевой, и $(... || echo 000) СКЛЕИВАЕТ «000» (curl) и «000»
  # (echo) → «000000». Поэтому отдельная ветка по rc curl: при ненулевом
  # rc — сразу HTTP_CODE=000, без склейки.
  HTTP_CODE=$(curl -sS -m 10 -o "$TMPF" -w '%{http_code}' "${AUTH_HDR[@]}" \
    -H 'Accept: application/vnd.github+json' "$PATH_API" 2>/dev/null) || HTTP_CODE="000"

  if [ "$HTTP_CODE" = "000" ] || [ "$HTTP_CODE" = "" ]; then
    RC=2
    MSG="нечем проверить: сеть"
    rm -f "$TMPF"
    break
  fi

  if [ -s "$TMPF" ]; then
    EVAL=$(python3 -c "
import json, sys
try:
  d = json.load(open(sys.argv[1]))
  rrs = d.get('check_runs') or []
  tot = d.get('total_count', 0)
  if tot == 0 and not rrs:
    print('no_runs')
  else:
    bad = [r for r in rrs if (r.get('conclusion') or '') != 'success']
    if not bad:
      print('ok')
    else:
      r = bad[0]
      st = r.get('status') or '?'
      cn = r.get('conclusion') or '?'
      nm = r.get('name') or '?'
      if st != 'completed':
        # Б-9: TAB между kind/name, чтобы shell-парсер не резал «ci (l7, …)»
        # по пробелам. Парсится через IFS=\\t read на стороне shell —
        # НЕ наивный «split по пробелу», режущий имена с пробелами.
        print('pending\t' + nm)
      else:
        print('fail\t' + nm + '\t' + cn)
except Exception as e:
  print('parse_err', str(e))
" "$TMPF" 2>/dev/null)
    case "$EVAL" in
      ok)
        RC=0; MSG=""; rm -f "$TMPF"; break
        ;;
      fail*)
        # Б-9: TAB-разделённый «fail\\t<name>\\t<conclusion>»; парсится через
        # IFS=tab read. Наивный awk по пробелу режет имена с пробелами
        # вроде «ci (l7, check:contract-frozen …)». Прецедент ci_diag.sh:79.
        IFS=$'\t' read -r _kind _name _concl <<<"$EVAL"
        RC=1; MSG="CI КРАСНЫЙ — check-run «${_name}» → ${_concl}"; rm -f "$TMPF"; break
        ;;
      no_runs)
        # Б-6: total_count=0 — НЕЗАВЕРШЁННОЕ ожидание (прогонов ещё нет;
        # обычное состояние сразу после push). Продолжаем опрос до таймаута
        # либо исчерпания --attempts; НЕ немедленный rc 3.
        MSG="прогонов CI нет"
        rm -f "$TMPF"
        ;;
      pending*)
        # Б-9: парсим TAB-разделённый «pending\t<name>» (см. выше).
        # Б-11: glob-матч `pending*)` а не точный `pending)`: python печатает
        # «pending\t<имя>», точный паттерн не совпадал → разбор уходил в *).
        IFS=$'\t' read -r _kind _name <<<"$EVAL"
        MSG="ещё идёт: ${_name}"; rm -f "$TMPF"
        ;;
      parse_err*)
        # Б-11: тот же glob-фикс (python печатает «parse_err <текст>» через
        # пробел, точный паттерн не совпадал).
        MSG="parse_err"; rm -f "$TMPF"
        ;;
      *)
        MSG="неизвестно"; rm -f "$TMPF"
        ;;
    esac
  else
    MSG="пустой ответ"; rm -f "$TMPF"
  fi

  if [ -n "$TIMEOUT" ]; then
    NOW=$(date +%s)
    if [ $((NOW - START)) -ge "$TIMEOUT" ]; then
      RC=3; MSG="таймаут"; break
    fi
  fi

  sleep "$INTERVAL"
done

record_event "wait-done" "$TASK" "$SHA"

if [ -n "$MSG" ]; then
  printf "ci_wait: %s\n" "$MSG" >&2
fi

# Б-9 (И-5 rc 1 «шаг + причина»): на rc=1 дополнительно зовём ci_diag.sh —
# это та же sha, второй API-запрос (допустимо). Печатает упавший ШАГ и
# причину из лога в формате ci_diag.sh:79-82 (прецедент). Свой rc НЕ
# перебивает rc=1 ci_wait: если ci_diag тоже не смог (rc 2/3) — просто
# дополняем stderr его диагностикой, выходим с rc 1.
if [ "$RC" = 1 ] && [ -x "$SCRIPT_DIR/ci_diag.sh" ]; then
  bash "$SCRIPT_DIR/ci_diag.sh" "$SHA" >&2 || true
fi

exit "$RC"