#!/usr/bin/env bash
# scripts/orch_status.sh — единая сводка: локальные поля всегда; при недоступном
# GitHub — строка «удалённое состояние: неизвестно», НЕ запрет локального восстановления;
# различает «опубликовано» и «закрытие не завершено» (контракт 092, И-4).
set -uo pipefail

PYBIN=python3
: "${ORCH_STATE_DIR:=/tmp/dev-harness-verify/orch-state}"
: "${ORCH_GH_API:=https://api.github.com}"
: "${ORCH_REPO:=}"

P92L_NEIZV="удалённое состояние: неизвестно"
P92L_OPUBL_DA="опубликовано: да"
P92L_OPUBL_NET="опубликовано: нет"
P92L_ZAKR="закрытие: завершено"
P92L_NEZAKR="закрытие: не завершено"
P92L_KRUGOV_PRE="кругов: "

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECKPOINT="$SCRIPT_DIR/orch_checkpoint.sh"

get_state() {
  local key="$1"
  bash "$CHECKPOINT" get "$key"
  return 0
}

if [ "${1:-}" = "--next" ]; then
  get_state next_step
  exit 0
fi

W_TASK=$(get_state task)
W_STAGE=$(get_state stage)
W_CAND=$(get_state candidate)
W_LASTP=$(get_state last_proven)
W_WAITING=$(get_state waiting)
W_NEXT=$(get_state next_step)
W_PUB=$(get_state pub_state)
[ -z "$W_TASK" ] && W_TASK="-"
[ -z "$W_STAGE" ] && W_STAGE="-"
[ -z "$W_CAND" ] && W_CAND="-"
[ -z "$W_LASTP" ] && W_LASTP="-"
[ -z "$W_WAITING" ] && W_WAITING="-"
[ -z "$W_NEXT" ] && W_NEXT="-"
[ -z "$W_PUB" ] && W_PUB="unknown"

printf "task: %s\n" "$W_TASK"
printf "stage: %s\n" "$W_STAGE"
printf "candidate: %s\n" "$W_CAND"
printf "last_proven: %s\n" "$W_LASTP"
printf "waiting: %s\n" "$W_WAITING"
printf "next_step: %s\n" "$W_NEXT"
printf "pub_state: %s\n" "$W_PUB"

EVENTS="$ORCH_STATE_DIR/events.tsv"
if [ -f "$EVENTS" ]; then
  COUNT=$(awk -F'\t' -v t="$W_TASK" '$2=="round-fail" && $3==t {print $4}' "$EVENTS" | sort -u | wc -l)
  printf "%s%d\n" "$P92L_KRUGOV_PRE" "$COUNT"
  if [ "$COUNT" -ge 3 ]; then
    printf "предел: арбитр\n"
  fi
else
  printf "%s0\n" "$P92L_KRUGOV_PRE"
fi

# Определить «опубликовано»: candidate достижим из refs/remotes/origin/main.
PUB_DA=1
if [ -n "$ORCH_REPO" ] && [ "$W_CAND" != "-" ] && [ -d "$ORCH_REPO" ]; then
  REPO="$ORCH_REPO" CAND="$W_CAND" python3 -c "
import os, subprocess, sys
repo = os.environ['REPO']
cand = os.environ['CAND']
env = {k: v for k, v in os.environ.items() if k != 'GIT_DIR' and k != 'GIT_WORK_TREE' and not k.startswith('GIT_CONFIG')}
r = subprocess.run(['git', '-C', repo, 'merge-base', '--is-ancestor', cand, 'refs/remotes/origin/main'], capture_output=True, env=env)
sys.exit(0 if r.returncode == 0 else 1)
" && PUB_DA=0
fi

if [ "$PUB_DA" -eq 0 ]; then
  printf "%s\n" "$P92L_OPUBL_DA"
else
  printf "%s\n" "$P92L_OPUBL_NET"
fi

if [ "$W_PUB" = "published" ]; then
  printf "%s\n" "$P92L_ZAKR"
else
  printf "%s\n" "$P92L_NEZAKR"
fi

# Удалённое состояние: попробовать GitHub API. Делаем попытку если ORCH_REPO
# задан и candidate валиден (даже без GITHUB_TOKEN — toy-API без auth).
NEED_REMOTE=0
if [ -n "$ORCH_REPO" ] && [ "$W_CAND" != "-" ]; then
  NEED_REMOTE=1
fi

if [ "$NEED_REMOTE" -eq 1 ]; then
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
  [ -n "${GITHUB_TOKEN:-}" ] && AUTH_HDR=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
  TMPF=$(mktemp)
  HTTP_CODE=000
  if curl -sS -m 5 -o "$TMPF" -w "%{http_code}" "${AUTH_HDR[@]}" -H 'Accept: application/vnd.github+json' "${ORCH_GH_API}/repos/${REPO_SLUG}/commits/${W_CAND}/check-runs?per_page=100" 2>/dev/null > /tmp/dev-harness-verify/_curl_code_$$; then
    HTTP_CODE=$(cat /tmp/dev-harness-verify/_curl_code_$$ 2>/dev/null || echo "000")
  fi
  rm -f /tmp/dev-harness-verify/_curl_code_$$
  if [ "$HTTP_CODE" = "200" ] && [ -s "$TMPF" ]; then
    REM=$(python3 -c "
import json, sys
d = json.load(open(sys.argv[1]))
bad = [r for r in d.get('check_runs', []) if (r.get('conclusion') or '') != 'success']
if not bad:
  print('CI: ' + str(d.get('total_count', 0)) + ' проверок, все success')
else:
  r = bad[0]
  print('CI: ' + str(r.get('name','?')) + ' → ' + str(r.get('conclusion') or r.get('status','?')))
" "$TMPF" 2>/dev/null)
    if [ -n "$REM" ]; then
      printf "%s\n" "$REM"
    else
      printf "%s\n" "$P92L_NEIZV"
    fi
  else
    printf "%s\n" "$P92L_NEIZV"
  fi
  rm -f "$TMPF"
else
  printf "%s\n" "$P92L_NEIZV"
fi
