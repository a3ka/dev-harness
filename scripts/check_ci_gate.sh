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
# Предмет по шагам, каждый отказ называет шаг и факт (И-6 контракта 087):
#   1. sha (умолчание HEAD) разрешается в коммит корня;
#   2. sha лежит на origin/main (git merge-base --is-ancestor): незапушенное
#      не имеет прогона CI вовсе — «судить нечего» называется явно;
#   3. GitHub API отдаёт check-runs коммита (curl; GITHUB_TOKEN опционален —
#      публичному репозиторию хватит и без него);
#   4. прогонов ≥ 1;
#   5. без skipped среди чек-ранов — прежнее правило (все success);
#   6. при ≥ 1 skipped:
#      — чек-ран вне {success, skipped} — отказ;
#      — чек-раны «legkij» и «legkij (…)» есть и все success, иначе отказ с
#        фразой «legkij» (лёгкое обязано быть зелёным для пропуска тяжёлых);
#      — `ci_klass.sh dokaz <sha>` из корня: rc 0 — зелёное (тяжёлое принято
#        по кодовому хешу с другого sha), rc 1 — отказ с фразой «тяжёл»,
#        rc 2 — отказ «CI не ответил».
#
#   bash scripts/check_ci_gate.sh [корень] [sha]
#
# Коды возврата: 0 — CI зелёный по запушенному коммиту, 1 — отказ с названной
# причиной, 2 — нечем проверять (нет curl/python3/git).
set -euo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DATABASE \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${1:-$(cd "$SELF_DIR/.." && pwd)}"
SHA_ARG="${2:-HEAD}"

die()  { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

command -v git     >/dev/null 2>&1 || skip "нет git — историю прочитать нечем"
command -v curl    >/dev/null 2>&1 || skip "нет curl — ответ CI не получить"
command -v python3 >/dev/null 2>&1 || skip "нет python3 — ответ CI не разобрать"
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

# 4-6 (И-6 контракта 087): разбор в памяти через python (jq-зависимости в репо нет);
# четыре строки вердикта: total, первый красный, число skipped, состояние legkij.
if ! body="$(curl -fsS -m 20 \
        -H 'Accept: application/vnd.github+json' \
        -H 'X-GitHub-Api-Version: 2022-11-28' \
        "${auth[@]}" \
        "https://api.github.com/repos/${repo}/commits/${sha}/check-runs?per_page=100" 2>&1)"; then
  die "CI не ответил по $short (curl): $(printf '%s' "$body" | head -2 | tr '\n' ' ')"
fi
verdict="$(printf '%s' "$body" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
    runs = d["check_runs"]; total = d["total_count"]
    assert isinstance(runs, list) and isinstance(total, int)
except Exception:
    print("-1\n\n0\nнет"); sys.exit(0)
bad = ""; skipped = 0; leg = []
for r in runs:
    c = r.get("conclusion") or "без завершения"
    n = r.get("name") or ""
    if c == "skipped":
        skipped += 1
    elif c != "success" and not bad:
        bad = n + " → " + c
    if n == "legkij" or n.startswith("legkij ("):
        leg.append(c)
legs = "нет" if not leg else ("success" if all(c == "success" for c in leg) else "не success")
print("%d\n%s\n%d\n%s" % (total, bad.replace("\n", " "), skipped, legs))
')"
mapfile -t V <<< "$verdict"
total="${V[0]:--1}"; bad="${V[1]:-}"; skipped="${V[2]:-0}"; legs="${V[3]:-нет}"
[ "$total" -ge 0 ] || die "ответ CI не разобран: $(printf '%s' "$body" | head -c 200)"
[ "$total" -gt 0 ] || die "прогонов CI по $short нет: чек-раны пусты — workflow не запускался"
[ -z "$bad" ] || die "CI не зелёный по $short: $bad — судью не звать, чинить пачку"

if [ "$skipped" -eq 0 ]; then
  # Прежнее правило (все success, без skipped) — зелёное.
  printf '  ok   CI зелёный: проверок %s, все success, по %s (%s)\n' "$total" "$short" "$repo" >&2
  exit 0
fi

# При ≥1 skipped: legkij обязано быть success; иначе отказ с фразой «legkij».
[ "$legs" = success ] \
  || die "лёгкое задание legkij по $short: $legs — пропуск тяжёлых джоб без лёгкого зелёного не принимается"

# Иначе тяжёлое принято по кодовому хешу с другого sha: `ci_klass.sh dokaz <sha>`.
# API-база — производная от $repo, чтобы не зависеть от remote_url в cwd вызова
# (адверсарий 045: cwd вызова и remote могут расходиться; для гейта важна
# текущая remote). Передаём GITHUB_REPOSITORY (через CI_KLASS_API формат
# «repos/<o>/<r>»), тогда ci_klass.sh dokaz идёт по этому base.
set +e
dk="$(CI_KLASS_API="https://api.github.com/repos/${repo}" bash "$SELF_DIR/ci_klass.sh" dokaz "$sha" 2>&1)"
drc=$?
set -e
case "$drc" in
  0) printf '  ok   CI зелёный: лёгкое по %s, тяжёлое — по кодовому хешу, %s\n' "$short" "$dk" >&2
     exit 0 ;;
  2) die "CI не ответил по $short (доказательство тяжёлого): $dk" ;;
  *) die "тяжёлые джобы по $short пропущены, а $dk" ;;
esac