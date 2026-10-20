#!/usr/bin/env bash
# Контракт 112 — литеральный оракул полноты backend-канона (2030 §3).
#
# Сверяет ДОСТАВЛЕННЫЙ профиль Complior-back (harness.project.json →
# sourceCanon.sources) с обязательным перечнем владельческого канона
# docs/owner/2026-10-17-resheniya-2030.md §3. Фактические пути перечня
# сверены живьём по origin/main Complior-back (2026-10-20): все 12
# не-миграционных файлов существуют, db/001–014 — 14 миграций (в §3 названы
# 001–013; дереву верим). Итого 26 источников.
#
# Оракул НЕЗАВИСИМ от check_project_connection.sh и profile_resolver.sh:
# существование объявленных источников судит проверка подключения (причина
# source-canon); ПЕРЕЧЕНЬ (полнота + приоритеты) судит только этот оракул.
# Сравнение множеств путей и пар путь→приоритет — ЛИТЕРАЛЬНОЕ.
#
# Замкнутый алфавит причин:
#   kanon-otsutstvuet — harness.project.json или sourceCanon.sources нет
#   kanon-nepolnyj    — обязательный источник не объявлен в профиле
#   kanon-lishnij     — объявлен источник вне обязательного перечня
#   kanon-prioritet   — приоритет источника ≠ обязательному
# rc: 0 — перечень совпал множеством и приоритетами; 1 — ≥1 именованный
# отказ; 2 — неправильный вызов (нет --repo, нет jq, нет каталога).
set -uo pipefail

# ── литеральный перечень 2030 §3 (путь TAB приоритет; Н-351) ────────────────
CANON='Complior_Backend_Architecture_v3_14_RU.md	0
contracts/BrokerOS_Unified_OpenAPI_v3.yaml	0
db/001_core.sql	0
db/002_rls.sql	0
db/003_finance.sql	0
db/004_runtime_role_fixes.sql	0
db/005_service_routing_and_effect_controls.sql	0
db/006_deadline_basis_and_provenance.sql	0
db/007_standalone_profile_assets.sql	0
db/008_service_authorization_lifecycle.sql	0
db/009_service_route_isolation.sql	0
db/010_ux114_owners.sql	0
db/011_profile_contact_extensions.sql	0
db/012_evb_issuance_owner.sql	0
db/013_profile_release_permissions.sql	0
db/014_api_reads_migration_ledger.sql	0
AGENTS.md	1
STRUCTURE.md	1
docs/ARCHITECTURE.md	1
docs/CODING-STANDARDS.md	1
docs/DATABASE.md	1
docs/RUNBOOK.md	1
docs/backend/PORT-PLAN.md	1
docs/backend/DONOR-INVENTORY.md	1
docs/backend/AUTH-AND-DB-DECISIONS.md	1
backend/structure-policy.json	1'

REPO=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:-}"; shift 2 ;;
    --repo=*) REPO="${1#--repo=}"; shift ;;
    *) printf 'kanon-2030: неизвестный аргумент: %s\n' "$1" >&2; exit 2 ;;
  esac
done
[ -n "$REPO" ] && [ -d "$REPO" ] || { printf 'kanon-2030: нет --repo <каталог>\n' >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { printf 'kanon-2030: нет jq\n' >&2; exit 2; }
R="$(cd "$REPO" && pwd -P)"
PROF="$R/harness.project.json"

itog=0
fail() { printf 'ОТКАЗ: kanon-2030: %s: %s\n' "$1" "$2" >&2; itog=1; }

if [ ! -f "$PROF" ]; then
  fail kanon-otsutstvuet "harness.project.json нет в $R"
  exit "$itog"
fi
n="$(jq -r '.sourceCanon.sources // [] | length' "$PROF" 2>/dev/null)"
if [ -z "$n" ] || [ "$n" = "0" ]; then
  fail kanon-otsutstvuet "sourceCanon.sources пуст/отсутствует"
  exit "$itog"
fi

req_paths="$(printf '%s\n' "$CANON" | awk -F'\t' 'NF==2{print $1}' | sort)"
act_paths="$(jq -r '.sourceCanon.sources[].path' "$PROF" | sort)"

# недостающие (обязательный не объявлен)
while IFS= read -r p; do
  [ -n "$p" ] || continue
  printf '%s\n' "$act_paths" | grep -Fxq -- "$p" || fail kanon-nepolnyj "$p"
done < <(printf '%s\n' "$req_paths" | comm -23 - <(printf '%s\n' "$act_paths"))

# лишние (объявлен вне перечня)
while IFS= read -r p; do
  [ -n "$p" ] || continue
  printf '%s\n' "$req_paths" | grep -Fxq -- "$p" || fail kanon-lishnij "$p"
done < <(printf '%s\n' "$act_paths" | comm -23 - <(printf '%s\n' "$req_paths"))

# приоритеты обязательных (только для объявленных путей)
while IFS=$'\t' read -r p prio; do
  [ -n "$p" ] || continue
  ap="$(jq -r --arg p "$p" '.sourceCanon.sources[]? | select(.path == $p) | (.priority | tostring)' "$PROF")"
  [ -z "$ap" ] && continue
  [ "$ap" = "$prio" ] || fail kanon-prioritet "$p: $ap, обязан $prio"
done < <(printf '%s\n' "$CANON")

exit "$itog"
