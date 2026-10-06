#!/usr/bin/env bash
# МОДЕЛЬ субъекта scripts/check_ci_gate.sh после контракта 087 — НЕ субъект. Тело —
# живой check_ci_gate.sh (шаги 1–3 по смыслу) плюс шаг 4 И-6 контракта 087: пропущенные
# (skipped) джобы допустимы ТОЛЬКО при зелёном лёгком задании на самом sha и доказательстве
# тяжёлого прогона по кодовому хешу (ci_klass.sh dokaz). Стаб стаб-пака:
# M087_STAB=skipped-bez-dokaza (привязка — шапка red_ci_b_087.sh, Н-39).
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
command -v python3 >/dev/null 2>&1 || skip "нет python3 — ответ CI не разобрать"
[ -d "$ROOT" ] || die "корня нет: $ROOT"
ROOT="$(cd "$ROOT" && pwd)"
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 || die "$ROOT не репозиторий git"

g() { git -C "$ROOT" "$@"; }

# 1. sha
sha="$(g rev-parse --verify --quiet "${SHA_ARG}^{commit}" || true)"
[ -n "$sha" ] || die "коммит не разрешается: $SHA_ARG"
short="$(printf '%s' "$sha" | head -c 12)"

# 2. запушен ли
g rev-parse --verify --quiet refs/remotes/origin/main >/dev/null 2>&1 \
  || die "ветки origin/main нет локально — прогон CI по $short не существует; сделай fetch"
g merge-base --is-ancestor "$sha" refs/remotes/origin/main \
  || die "коммит $short не на origin/main — CI по нему не запускался; запушь и дождись прогона"

# 3. check-runs коммита
remote_url="$(g remote get-url origin 2>/dev/null || true)"
[ -n "$remote_url" ] || die "remote origin не объявлен — репозиторий CI не узнать"
repo="$(printf '%s' "$remote_url" \
  | sed -nE 's#^(ssh://git@github\.com/|git@github\.com:|https://github\.com/)([^/]+)/(.+?)(\.git)?$#\2/\3#p' | head -1)"
repo="$(printf '%s' "$repo" | sed -E 's/\.git$//')"
[ -n "$repo" ] || die "из «$remote_url» не извлекается OWNER/REPO github"

auth=()
if [ -n "${GITHUB_TOKEN:-}" ]; then
  auth=(-H "Authorization: Bearer $GITHUB_TOKEN")
fi
if ! body="$(curl -fsS -m 20 \
        -H 'Accept: application/vnd.github+json' \
        -H 'X-GitHub-Api-Version: 2022-11-28' \
        "${auth[@]}" \
        "https://api.github.com/repos/${repo}/commits/${sha}/check-runs?per_page=100" 2>&1)"; then
  die "CI не ответил по $short (curl): $(printf '%s' "$body" | head -2 | tr '\n' ' ')"
fi

# 4 (И-6 контракта 087): разбор в памяти; четыре строки вердикта: total, первый красный
# чек-ран, число пропущенных, состояние legkij (нет | success | не success)
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
  printf '  ok   CI зелёный: проверок %s, все success, по %s (%s)\n' "$total" "$short" "$repo" >&2
  exit 0
fi
[ "$legs" = success ] \
  || die "лёгкое задание legkij по $short: $legs — пропуск тяжёлых джоб без лёгкого зелёного не принимается"
if [ "${M087_STAB:-}" = skipped-bez-dokaza ]; then
  printf '  ok   CI зелёный (стаб): лёгкое по %s\n' "$short" >&2
  exit 0
fi
set +e
dk="$(cd "$ROOT" && CI_KLASS_API="${CI_KLASS_API:-https://api.github.com/repos/${repo}}" \
      bash "$SELF_DIR/ci_klass.sh" dokaz "$sha" 2>&1)"
drc=$?
set -e
case "$drc" in
  0) printf '  ok   CI зелёный: лёгкое по %s, тяжёлое — по кодовому хешу, %s\n' "$short" "$dk" >&2 ;;
  2) die "CI не ответил по $short (доказательство тяжёлого): $dk" ;;
  *) die "тяжёлые джобы по $short пропущены, а $dk" ;;
esac
