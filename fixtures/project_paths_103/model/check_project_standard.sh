#!/usr/bin/env bash
# Честная модель 103: грамматика scripts/check_project_standard.sh —
# исполняемая форма офлайн-проверяемых условий стандарта проекта v1 §1
# (docs/owner/2026-10-14-standart-proekta-v1.md). CLI: --repo <R>
# [--layer-root <L>]; слой проекта — приоритет --layer-root > HARNESS_PROJECT_LAYER_ROOT > R.
# Пустой/отсутствующий --repo — «нечем проверить» (rc 2, NOT_IMPLEMENTED), не
# аварийный выход shell (A103-2/Рв96-5).
#
# Условия (единый источник имён причин — ЭТОТ список; продукт несёт его
# побайтово). Каждое нарушение — СВОЯ строка «ОТКАЗ: стандарт: <имя>: <деталь>»
# в stderr; скрипт НЕ останавливается на первом, итог rc 1 при ≥1 нарушении,
# rc 0 — все условия зелены, rc 2 — нечем проверить.
#   git-main         — ветка main есть локально
#   git-origin       — remote origin настроен
#   profil           — harness.project.json + слой проекта: обязательные корневые
#                      ключи (schemaVersion 1, repoId, language, projectLayer,
#                      workflowPaths 4 ключа — эффективно)
#   workflowPaths    — каждый из 4 путей канонизируется ВНУТРЬ репо и есть каталог
#   lockfile         — lockfile менеджера пакетов в корне
#   komandy-true     — ни одна из commands.{test,lint,typecheck,build} не `true`
#   agents-md        — AGENTS.md непуст
#   kontekst-karta   — contextPack.rows содержит kind=map И kind=rules с файлами в дереве
#   env-example      — .env.example есть
#   env-ignore       — .env игнорируется git (check-ignore) и не в индексе
#   harness-pin      — config/harness_pin.json с непустым .version
# Онлайн-условия стандарта (защита main на GitHub, gh pr checks, npm ci/время
# прогонов, живой запуск) — НЕ здесь (см. контракт 103 §НЕ предмет).
set -uo pipefail
REPO=""; LAYER=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:-}"; shift; [ $# -eq 0 ] || shift ;;
    --layer-root) LAYER="${2:-}"; shift; [ $# -eq 0 ] || shift ;;
    *) printf 'usage: check_project_standard.sh --repo R [--layer-root L]\n' >&2; exit 2 ;;
  esac
done
[ -n "$REPO" ] && [ -d "$REPO" ] || { printf 'NOT_IMPLEMENTED: нет репо: %s\n' "$REPO" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет jq\n' >&2; exit 2; }
R="$(cd "$REPO" && pwd -P)"
[ -n "$LAYER" ] || LAYER="${HARNESS_PROJECT_LAYER_ROOT:-$R}" # t103-m11
itog=0
fail() { printf 'ОТКАЗ: стандарт: %s: %s\n' "$1" "$2" >&2; itog=1; }

# git
git -C "$R" show-ref --verify --quiet refs/heads/main || fail git-main "нет ветки main"
git -C "$R" remote get-url origin >/dev/null 2>&1 || fail git-origin "remote origin не настроен"

# profil
RJ="$R/harness.project.json"; PJ=""
if [ ! -f "$RJ" ]; then
  fail profil "нет harness.project.json"
else
  for k in schemaVersion repoId language projectLayer; do
    jq -e --arg k "$k" 'has($k) and .[$k] != null and .[$k] != ""' "$RJ" >/dev/null 2>&1 || fail profil "нет ключа $k" # t103-m6
  done
  [ "$(jq -r '.schemaVersion' "$RJ" 2>/dev/null)" = "1" ] || fail profil "schemaVersion не 1" # t103-m14
  pp="$(jq -r '.projectLayer.profilePath // empty' "$RJ" 2>/dev/null)"
  [ -n "$pp" ] && [ -f "$LAYER/$pp" ] && PJ="$LAYER/$pp" || fail profil "слой проекта не найден: ${pp:-?}"
fi
eff() {  # <ветвь> <ключ> — эффективное значение (репо, иначе defaults слоя)
  local v=""
  [ -f "$RJ" ] && v="$(jq -r --arg b "$1" --arg k "$2" '.[$b][$k] // empty' "$RJ" 2>/dev/null)"
  [ -n "$v" ] || { [ -n "$PJ" ] && v="$(jq -r --arg b "$1" --arg k "$2" '.defaults[$b][$k] // empty' "$PJ" 2>/dev/null)"; }
  printf '%s' "$v"
}

# workflowPaths
for k in contracts verdicts registry fixtures; do
  v="$(eff workflowPaths "$k")"
  if [ -z "$v" ]; then fail profil "нет workflowPaths.$k"; continue; fi
  canon="$(readlink -f -- "$R/$v" 2>/dev/null || true)"
  case "$v" in /*) canon="/вне" ;; esac
  case "$canon" in "$R"/*) ;; *) fail workflowPaths "вне репо: $k=$v"; continue ;; esac # t103-m3
  [ -d "$canon" ] || fail workflowPaths "нет каталога: $k=$v"
done

# lockfile
lf=0; for f in package-lock.json yarn.lock pnpm-lock.yaml Cargo.lock; do [ -f "$R/$f" ] && lf=1; done
[ "$lf" -eq 1 ] || fail lockfile "нет lockfile (package-lock.json|yarn.lock|pnpm-lock.yaml|Cargo.lock)"

# komandy-true
for k in test lint typecheck build; do # t103-m12
  v="$(eff commands "$k")"
  [ "$v" != "true" ] || fail komandy-true "commands.$k замаскирована true" # t103-m4
done

# agents-md
[ -s "$R/AGENTS.md" ] || fail agents-md "AGENTS.md пуст или отсутствует"

# kontekst-karta
rows="$(jq -c '.contextPack.rows // empty' "$RJ" 2>/dev/null)"
[ -n "$rows" ] || { [ -n "$PJ" ] && rows="$(jq -c '.defaults.contextPack.rows // empty' "$PJ" 2>/dev/null)"; }
for kind in map rules; do
  p="$(printf '%s' "${rows:-[]}" | jq -r --arg k "$kind" '[.[] | select(.kind==$k)][0].path // empty' 2>/dev/null)"
  if [ -z "$p" ]; then fail kontekst-karta "нет строки kind=$kind"
  elif [ ! -f "$R/$p" ]; then fail kontekst-karta "файла нет: $kind=$p"; fi
done

# env
[ -f "$R/.env.example" ] || fail env-example "нет .env.example"
if ! git -C "$R" check-ignore -q .env 2>/dev/null; then fail env-ignore ".env не игнорируется"; fi # t103-m5
if git -C "$R" ls-files --error-unmatch .env >/dev/null 2>&1; then fail env-ignore ".env в индексе"; fi # t103-m13

# harness-pin
if [ ! -f "$R/config/harness_pin.json" ]; then fail harness-pin "нет config/harness_pin.json"
else
  pv="$(jq -r '.version // empty' "$R/config/harness_pin.json" 2>/dev/null)"
  [ -n "$pv" ] || fail harness-pin "пустой .version"
fi

exit "$itog"
