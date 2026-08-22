#!/usr/bin/env bash
# НЕ БАРЬЕР: диагностика красного CI одной командой (утилита, не барьер, без фикстур).
#
# Заведён по Н-44 как КОНКРЕТНЫЙ инструмент правила стоимости. «Локально зелёное / CI красное»
# — ПО ОПРЕДЕЛЕНИЮ «работает на моём дереве», причина в ЛОГЕ CI, а не в локальном репро (среда
# другая). Один раз это стоило ~2 часа: два 30-мин локальных прогона, не воспроизводивших
# ubuntu-специфичный дефект, плюс CI-круги. Этот скрипт читает лог упавшего джоба ОДНОЙ командой
# — чтобы у дорогого локального репро не было повода. ПРАВИЛО: при расхождении локаль↔remote
# первый ход — `ci_diag.sh`; локальный репро законен лишь ПОСЛЕ того, как лог назвал причину.
#
#   bash scripts/ci_diag.sh [sha]        # sha по умолчанию HEAD
#
# Токен: GITHUB_TOKEN из окружения либо из `.env` (нужен scope actions:read — логи джоба без
# него отдаются как 403). Токен не печатается.
#
# Результат — код возврата, не PASS/FAIL (это утилита):
#   0 — CI зелёный по коммиту; 1 — CI красный (печатает упавший ШАГ + причину из лога);
#   2 — нечем проверить (нет curl/jq/git/токена/remote/коммита); 3 — CI ещё идёт либо не запускался.
set -uo pipefail
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SELF_DIR/.." && pwd)"
SHA_ARG="${1:-HEAD}"

die()  { printf 'ci_diag: %s\n' "$*" >&2; exit 2; }
g()    { git -C "$ROOT" "$@"; }

command -v git  >/dev/null 2>&1 || die "нет git"
command -v curl >/dev/null 2>&1 || die "нет curl"
command -v jq   >/dev/null 2>&1 || die "нет jq"

sha="$(g rev-parse --verify --quiet "${SHA_ARG}^{commit}" || true)"
[ -n "$sha" ] || die "коммит не разрешается: $SHA_ARG"
short="${sha:0:12}"

TOKEN="${GITHUB_TOKEN:-}"
if [ -z "$TOKEN" ] && [ -f "$ROOT/.env" ]; then
  TOKEN="$(grep -E '^GITHUB_TOKEN=' "$ROOT/.env" | head -1 | cut -d= -f2-)"
fi
[ -n "$TOKEN" ] || die "нет GITHUB_TOKEN (окружение или .env) — лог CI без него не прочесть"

url="$(g remote get-url origin 2>/dev/null || true)"
[ -n "$url" ] || die "remote origin не объявлен"
repo="$(printf '%s' "$url" | sed -nE 's#^(ssh://git@github\.com/|git@github\.com:|https://github\.com/)([^/]+)/(.+)$#\2/\3#p' | sed -E 's/\.git$//')"
[ -n "$repo" ] || die "не извлёк OWNER/REPO из «$url»"

api() { curl -fsS -m 25 -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' \
             -H 'X-GitHub-Api-Version: 2022-11-28' "$@"; }

# Запушен ли: GitHub не знает незапушенный коммит и отвечает 422 — это НЕ «нечем проверить»,
# а «CI по нему не гонялся». Ловим до запроса, чтобы не путать с реальным сбоем API.
if g rev-parse --verify --quiet refs/remotes/origin/main >/dev/null 2>&1 \
   && ! g merge-base --is-ancestor "$sha" refs/remotes/origin/main 2>/dev/null; then
  printf 'ci_diag: %s НЕ на origin/main — не запушен, CI по нему не гонялся (push/fetch)\n' "$short" >&2
  exit 3
fi
runs="$(api "https://api.github.com/repos/${repo}/commits/${sha}/check-runs?per_page=100" 2>/dev/null)" || {
  printf 'ci_diag: check-runs по %s не получены — коммит не на GitHub (не запушен?), токен или сеть\n' "$short" >&2
  exit 3
}
total="$(printf '%s' "$runs" | jq -r '.total_count // 0')"
if [ "$total" -eq 0 ]; then
  printf 'ci_diag: прогонов CI по %s НЕТ — не запушено либо workflow не стартовал\n' "$short" >&2
  exit 3
fi

bad="$(printf '%s' "$runs" | jq -r '[.check_runs[]|select((.conclusion//"")!="success")][0] // empty | "\(.status)\t\(.conclusion//"")\t\(.id)\t\(.name)"')"
if [ -z "$bad" ]; then
  printf 'ci_diag: CI ЗЕЛЁНЫЙ по %s (проверок %s, все success)\n' "$short" "$total" >&2
  exit 0
fi
IFS=$'\t' read -r status concl jobid name <<<"$bad"
if [ "$status" != completed ]; then
  printf 'ci_diag: CI ещё идёт по %s (check-run «%s»: %s) — вердикта нет\n' "$short" "$name" "$status" >&2
  exit 3
fi

printf 'ci_diag: CI КРАСНЫЙ по %s — check-run «%s» → %s\n' "$short" "$name" "$concl" >&2

steps="$(api "https://api.github.com/repos/${repo}/actions/jobs/${jobid}" 2>/dev/null \
          | jq -r '.steps[]? | select(.conclusion=="failure") | "  ✗ шаг \(.number): \(.name)"')" || steps=""
[ -n "$steps" ] && printf 'Упавшие шаги:\n%s\n' "$steps" >&2

log="$(curl -fsSL -m 40 -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' \
            "https://api.github.com/repos/${repo}/actions/jobs/${jobid}/logs" 2>/dev/null || true)"
if [ -n "$log" ]; then
  printf 'Причина из лога (FAIL/ошибки, последние строки):\n' >&2
  printf '%s\n' "$log" | grep -aE 'FAIL|расхожд|ОТКАЗ|##\[error\]|[Ee]rror|not found|No such|Permission denied' \
    | grep -avE '^\S+[[:space:]]+ok[[:space:]]' | sed -E 's/^[0-9T:.Z+-]+Z? //' | tail -25 >&2
else
  printf '(лог джоба не отдан — токену нужен scope actions:read; упавшие шаги выше уже называют место)\n' >&2
fi
exit 1
