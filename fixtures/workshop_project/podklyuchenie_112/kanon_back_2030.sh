#!/usr/bin/env bash
# Контракт 112 — литеральный оракул полноты backend-канона (2030 §3).
#
# Сверяет ДОСТАВЛЕННЫЙ профиль Complior-back (harness.project.json →
# sourceCanon.sources) с обязательным перечнем владельческого канона
# docs/owner/2026-10-17-resheniya-2030.md §3. Фактические пути перечня
# сверены живьём по origin/main Complior-back (2026-10-20, НОВАЯ структура —
# форк n112-v2-kanon-26 ОТВЕЧЕНО (А), слово консультанта 14:20/14:35:
# миграции переехали db/→migrations/, архитектурный документ и
# `contracts/BrokerOS_Unified_OpenAPI_v3.yaml` — в docs/,
# `backend/structure-policy.json` — в корень; 17 путей меняют путь, состав
# и приоритеты НЕ меняются): все 12 не-миграционных файлов существуют,
# migrations/001–014 — 14 миграций (в §3 названы 001–013; дереву верим).
# Итого 26 источников.
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
# v2 (слово владельца 2026-10-20 ~13:45 UTC, docs/owner/2026-10-20-uskorenie-i-standarty.md
# §«Стандарты бэкенда»; форк n112-profil-back-standarty ОТВЕЧЕНО (А) 14:05):
# docs/ARCHITECTURE.md и docs/CODING-STANDARDS.md подняты с priority 1 до
# priority 0 — бэкенд пишется строго по структуре и стилю этих файлов.
# Итог 26 источников = 18 priority 0 + 8 priority 1 (существование обоих
# файлов на origin/main сверено gh api 2026-10-20: shas 70b6109f…, ed4aebed…).
CANON='docs/Complior_Backend_Architecture_v3_14_RU.md	0
docs/contracts/BrokerOS_Unified_OpenAPI_v3.yaml	0
migrations/001_core.sql	0
migrations/002_rls.sql	0
migrations/003_finance.sql	0
migrations/004_runtime_role_fixes.sql	0
migrations/005_service_routing_and_effect_controls.sql	0
migrations/006_deadline_basis_and_provenance.sql	0
migrations/007_standalone_profile_assets.sql	0
migrations/008_service_authorization_lifecycle.sql	0
migrations/009_service_route_isolation.sql	0
migrations/010_ux114_owners.sql	0
migrations/011_profile_contact_extensions.sql	0
migrations/012_evb_issuance_owner.sql	0
migrations/013_profile_release_permissions.sql	0
migrations/014_api_reads_migration_ledger.sql	0
docs/ARCHITECTURE.md	0
docs/CODING-STANDARDS.md	0
AGENTS.md	1
STRUCTURE.md	1
docs/DATABASE.md	1
docs/RUNBOOK.md	1
docs/backend/PORT-PLAN.md	1
docs/backend/DONOR-INVENTORY.md	1
docs/backend/AUTH-AND-DB-DECISIONS.md	1
structure-policy.json	1'

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
