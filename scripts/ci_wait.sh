#!/usr/bin/env bash
# scripts/ci_wait.sh — блокирующее ожидание завершения CI по sha ОДНИМ вызовом
# (контракт 092, И-5; rc 0/1/2/3, rc-грамматика ci_diag).
set -uo pipefail

: "${ORCH_STATE_DIR:=/tmp/dev-harness-verify/orch-state}"
: "${ORCH_GH_API:=https://api.github.com}"
: "${ORCH_REPO:=}"

SHA=""
TIMEOUT=""
INTERVAL=5
ATTEMPTS=30

while [ "$#" -gt 0 ]; do
  case "$1" in
    --sha) SHA="$2"; shift 2 ;;
    --timeout) TIMEOUT="$2"; shift 2 ;;
    --interval) INTERVAL="$2"; shift 2 ;;
    --attempts) ATTEMPTS="$2"; shift 2 ;;
    --) shift; break ;;
    *) printf "ci_wait: неизвестный флаг %s\n" "$1" >&2; exit 2 ;;
  esac
done

if ! printf "%s" "$SHA" | grep -Eq "^[0-9a-f]{40}$"; then
  printf "ci_wait: невалидный sha: %s\n" "$SHA" >&2
  exit 2
fi

TASK="-"
if [ -f "$ORCH_STATE_DIR/state.tsv" ]; then
  T=$(awk -F'\t' '$1=="task" {print $2}' "$ORCH_STATE_DIR/state.tsv" 2>/dev/null || true)
  [ -n "$T" ] && TASK="$T"
fi

# Создать каталог state если нужно.
mkdir -p "$ORCH_STATE_DIR" 2>/dev/null || true

append_event() {
  local kind="$1" subject="$2" ref="$3"
  local ts
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  printf "%s\t%s\t%s\t%s\n" "$ts" "$kind" "$subject" "$ref" >> "$ORCH_STATE_DIR/events.tsv" 2>/dev/null || true
}
append_event "wait-start" "$TASK" "$SHA"

# Вычислить owner/repo из ORCH_REPO (если это URL) или использовать default.
REPO_SLUG="owner/repo"
if [ -n "$ORCH_REPO" ]; then
  EXTRACTED=$(ORCH_REPO="$ORCH_REPO" python3 -c "
import re, os
p = os.environ['ORCH_REPO']
m = re.search(r'(?:ssh://git@github\.com/|git@github\.com:|https://github\.com/)([^/]+)/(.+?)(?:\.git)?$', p)
if m: print(m.group(1) + '/' + m.group(2))
" 2>/dev/null)
  [ -n "$EXTRACTED" ] && REPO_SLUG="$EXTRACTED"
fi

AUTH_HDR=()
if [ -n "${GITHUB_TOKEN:-}" ]; then
  AUTH_HDR=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
fi

START=$(date +%s)
N=0
RC=3
MSG="таймаут ожидания CI"
PATH_API="${ORCH_GH_API}/repos/${REPO_SLUG}/commits/${SHA}/check-runs?per_page=100"

while [ "$N" -lt "$ATTEMPTS" ]; do
  N=$((N + 1))
  TMPF=$(mktemp)
  HTTP_CODE=000
  if curl -sS -m 10 -o "$TMPF" -w "%{http_code}" "${AUTH_HDR[@]}" -H 'Accept: application/vnd.github+json' "$PATH_API" 2>/dev/null > /tmp/dev-harness-verify/_curl_code_$$; then
    HTTP_CODE=$(cat /tmp/dev-harness-verify/_curl_code_$$ 2>/dev/null || echo "000")
  fi
  rm -f /tmp/dev-harness-verify/_curl_code_$$

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
        print('pending', nm)
      else:
        print('fail', nm, cn)
except Exception as e:
  print('parse_err', str(e))
" "$TMPF" 2>/dev/null)
    case "$EVAL" in
      ok)
        RC=0; MSG=""; rm -f "$TMPF"; break
        ;;
      fail*)
        RC=1; MSG="CI КРАСНЫЙ — check-run «$(echo "$EVAL" | awk '{print $2}')» → $(echo "$EVAL" | awk '{print $3}')"; rm -f "$TMPF"; break
        ;;
      no_runs)
        MSG="прогонов CI нет"; rm -f "$TMPF"; break
        ;;
      pending)
        MSG="ещё идёт: $(echo "$EVAL" | awk '{print $2}')"; rm -f "$TMPF"
        ;;
      parse_err)
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

append_event "wait-done" "$TASK" "$SHA"

if [ -n "$MSG" ]; then
  printf "ci_wait: %s\n" "$MSG" >&2
fi
exit "$RC"
