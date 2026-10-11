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
SCRIPT_TREE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CHECKPOINT="$SCRIPT_DIR/orch_checkpoint.sh"

# ORCH_REPO по умолчанию — корень дерева скрипта (прецедент ci_diag.sh): slug
# берётся из git remote этого каталога. Переменная всё ещё опциональна —
# явный ORCH_REPO перебивает умолчание. `.git` — каталог в обычном чекауте,
# ФАЙЛ с `gitdir:` в worktree — обе формы распознаём.
if [ -z "$ORCH_REPO" ] && { [ -d "$SCRIPT_TREE_ROOT/.git" ] || [ -f "$SCRIPT_TREE_ROOT/.git" ]; }; then
  ORCH_REPO="$SCRIPT_TREE_ROOT"
fi

get_state() {
  local key="$1"
  bash "$CHECKPOINT" get "$key"
}

# slug_for_repo <repo-dir> — печатает OWNER/REPO из git remote origin URL (Б-1).
# Прецедент ci_diag.sh: тот же sed-регекс для ssh://git@github.com/, git@github.com:,
# https://github.com/.
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

# resolve_token — GITHUB_TOKEN из окружения либо .env в корне дерева скрипта
# (прецедент ci_diag.sh; Б-1).
resolve_token() {
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    printf '%s' "$GITHUB_TOKEN"
    return
  fi
  if [ -f "$SCRIPT_TREE_ROOT/.env" ]; then
    grep -E '^GITHUB_TOKEN=' "$SCRIPT_TREE_ROOT/.env" 2>/dev/null | head -1 | cut -d= -f2-
  fi
}

if [ "${1:-}" = "--next" ]; then
  # Б-4: --next без состояния / вне грамматики — rc 1 (И-4). Безусловный exit 0
  # ранее делал сводку «пустой строкой» с зелёным rc; роль-канал получал мусор.
  get_state next_step || exit 1
  exit 0
fi

# ПЕРВЫЙ вызов get_state проверяется на rc: при пустом ORCH_STATE_DIR
# orch_checkpoint.sh get уже печатает stderr «состояние отсутствует» и
# возвращает rc 1 (И-4) — семиполевую сводку печатать НЕЛЬЗЯ (adversary круг 1,
# находка 1: выдуманное состояние при полном отсутствии).
W_TASK=$(get_state task) || exit 1
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
  # Б-5: значение W_TASK передаётся через ENVIRON, не через -v t="..." (эскейп-
  # инъекция: awk -v раскрывает \t и прочие escape-последовательности в
  # печатных токенах задачи, счёт кругов ломается). Контрактный формат: env
  # W_TASK напрямую в awk.
  COUNT=$(W_TASK="$W_TASK" awk -F'\t' 'BEGIN { t = ENVIRON["W_TASK"] } $2=="round-fail" && $3==t {print $4}' "$EVENTS" | sort -u | wc -l)
  printf "%s%d\n" "$P92L_KRUGOV_PRE" "$COUNT"
  if [ "$COUNT" -ge 3 ]; then
    printf "предел: арбитр\n"
  fi
else
  printf "%s0\n" "$P92L_KRUGOV_PRE"
fi

# Определить «опубликовано»: candidate достижим из refs/remotes/origin/main.
# Снимаем GIT_CONFIG*, чтобы не утаскивать identity родителя.
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
  # Б-1: slug берётся ИЗ git remote origin (прецедент ci_diag.sh), а не из
  # заглушки «owner/repo». Если каталог не git-repo либо remote не GitHub —
  # slug пуст, и GitHub API пропускается (удалённое состояние: неизвестно).
  REPO_SLUG="$(slug_for_repo "$ORCH_REPO")"
  if [ -n "$REPO_SLUG" ]; then
    AUTH_HDR=()
    TOKEN_VAL="$(resolve_token)"
    [ -n "$TOKEN_VAL" ] && AUTH_HDR=(-H "Authorization: Bearer ${TOKEN_VAL}")
    TMPF=$(mktemp)
    # Н-2: HTTP-код берётся НАПРЯМУЮ из curl -w, без побочного файла
    # /tmp/dev-harness-verify/_curl_code_$$ — это скрытое состояние вне шва
    # и зависимость от существования каталога.
    HTTP_CODE=$(curl -sS -m 5 -o "$TMPF" -w '%{http_code}' "${AUTH_HDR[@]}" \
      -H 'Accept: application/vnd.github+json' \
      "${ORCH_GH_API}/repos/${REPO_SLUG}/commits/${W_CAND}/check-runs?per_page=100" 2>/dev/null || echo "000")
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
else
  printf "%s\n" "$P92L_NEIZV"
fi