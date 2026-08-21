#!/usr/bin/env bash
# Тестер = CI: гейт ПЕРЕД вызовом судей (решение владельца 2026-08-20, D4б).
#
# «Не зелёный — судью не звать»: адверсарий судит пачку только после того, как
# чистый чекаут внешнего CI прошёл по ЗАПУШЕННОМУ HEAD. Прогон на локальном
# дереве ничего не доказывает — «работает на моём» ловится именно actions/checkout.
#
# ПРОВЕРЯЕТСЯ ЖИВОЙ ПРОГОН, поэтому сам в CI не исполняется (круг: текущий прогон
# не завершён, пока идёт) — объявленное исключение паритета с причиной.
#
# Предмет по шагам, каждый отказ называет шаг и факт:
#   1. sha (умолчание HEAD) разрешается в коммит корня;
#   2. sha лежит на origin/main (git merge-base --is-ancestor): незапушенное
#      не имеет прогона CI вовсе — «судить нечего» называется явно;
#   3. GitHub API отдаёт check-runs коммита (curl; GITHUB_TOKEN опционален —
#      публичному репозиторию хватит и без него);
#   4. прогонов ≥ 1 и ВСЕ conclusion == success.
#
#   bash scripts/check_ci_gate.sh [корень] [sha]
#
# Коды возврата: 0 — CI зелёный по запушенному коммиту, 1 — отказ с названной
# причиной, 2 — нечем проверять (нет curl/jq/git).
set -euo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DATABASE \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${1:-$(cd "$SELF_DIR/.." && pwd)}"
SHA_ARG="${2:-HEAD}"

die()  { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

command -v git  >/dev/null 2>&1 || skip "нет git — историю прочитать нечем"
command -v curl >/dev/null 2>&1 || skip "нет curl — ответ CI не получить"
command -v jq   >/dev/null 2>&1 || skip "нет jq — ответ CI не разобрать"
[ -d "$ROOT" ] || die "корня нет: $ROOT"
ROOT="$(cd "$ROOT" && pwd)"
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 || die "$ROOT не репозиторий git"

g() { git -C "$ROOT" "$@"; }

# 1. sha
sha="$(g rev-parse --verify --quiet "${SHA_ARG}^{commit}" || true)"
[ -n "$sha" ] || die "коммит не разрешается: $SHA_ARG"
short="$(printf '%s' "$sha" | head -c 12)"

# 2. запушен ли: sha обязан быть достижим от origin/main
g rev-parse --verify --quiet refs/remotes/origin/main >/dev/null 2>&1 \
  || die "ветки origin/main нет локально — прогон CI по $short не существует; сделай fetch"
g merge-base --is-ancestor "$sha" refs/remotes/origin/main \
  || die "коммит $short не на origin/main — CI по нему не запускался; запушь и дождись прогона"

# 3. репозиторий из remote origin (ssh и https формы), токен опционален
remote_url="$(g remote get-url origin 2>/dev/null || true)"
[ -n "$remote_url" ] || die "remote origin не объявлен — репозиторий CI не узнать"
repo="$(printf '%s' "$remote_url" \
  | sed -nE 's#^(ssh://git@github\.com/|git@github\.com:|https://github\.com/)([^/]+)/(.+?)(\.git)?$#\2/\3#p' | head -1)"
repo="$(printf '%s' "$repo" | sed -E 's/\.git$//')"
[ -n "$repo" ] || die "из «$remote_url» не извлекается OWNER/REPO github — гейт понимает ssh://git@github.com/, git@github.com: и https://github.com/ формы"

auth=()
if [ -n "${GITHUB_TOKEN:-}" ]; then
  auth=(-H "Authorization: Bearer $GITHUB_TOKEN")
fi

# 4. check-runs: любой сбой сети/HTTP — «не ответил», не молчание
if ! body="$(curl -fsS -m 20 \
        -H 'Accept: application/vnd.github+json' \
        -H 'X-GitHub-Api-Version: 2022-11-28' \
        "${auth[@]}" \
        "https://api.github.com/repos/${repo}/commits/${sha}/check-runs?per_page=100" 2>&1)"; then
  die "CI не ответил по $short (curl): $(printf '%s' "$body" | head -2 | tr '\n' ' ')"
fi
total="$(printf '%s' "$body" | jq -r '.total_count // -1' 2>/dev/null)" || total=-1
[ "$total" -ge 0 ] || die "ответ CI не разобран: total_count нет — $(printf '%s' "$body" | head -c 200)"
[ "$total" -gt 0 ] || die "прогонов CI по $short нет: чек-раны пусты — workflow не запускался"

bad_run="$(printf '%s' "$body" | jq -r '[.check_runs[] | select((.conclusion // "") != "success")][0] | if . then (.name + " → " + (.conclusion // "без завершения")) else "" end')"
if [ -n "$bad_run" ]; then
  die "CI не зелёный по $short: $bad_run — судью не звать, чинить пачку"
fi

printf '  ok   CI зелёный: проверок %s, все success, по %s (%s)\n' "$total" "$short" "$repo" >&2
