#!/usr/bin/env bash
# scripts/project_workflow.sh — ЕДИНСТВЕННЫЙ печатник проектных путей и
# эффективного sourceCanon контракта 996 (общий контекст пакета A).
#
#   bash scripts/project_workflow.sh --repo <R>
#
# stdout — JSON ОДНОГО документа, ключи:
#     contracts, verdicts, registry, fixtures   — из profile_resolver.workflowPaths.value
#     handoff, observations, architectObservations,
#     roadmap, forks                            — из <state>/{HANDOFF.md, NABLIUDENIA.md,
#                                                NABLIUDENIA_ARCHITECT.md, ROADMAP.md, forks};
#                                                <state> = workflowPaths.value.state || ".harness"
#     sourceCanon                               — effective ЮНИТ источников и gate
#                                                (entry.value, без обёртки origin) либо null
#
# Все пути — АБСОЛЮТНЫЕ, вычислены в корне --repo. Каждый путь проверен на
# относительность и реальность относительно --repo: симлинк вне, «..» и абсолютный
# путь в profile.value — отказ rc 1 «workflowPaths вне репо» ДО печати.
# Источник effective profile — scripts/profile_resolver.sh, второй экземпляр merge-логики
# не вводится (контракт 996 §Интерфейсы «Общий контекст»).
#
# Коды возврата:
#   0 — успех (JSON на stdout)
#   1 — отказ с именованной причиной на stderr
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
die() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }

REPO=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:-}"; [ $# -ge 2 ] && shift ;;
    --) shift; break ;;
    *) REPO="$1" ;;
  esac
  shift
done

[ -n "$REPO" ] || die "usage: bash scripts/project_workflow.sh --repo <корень>"
[ -d "$REPO" ] || die "каталог репо не существует: $REPO"
command -v jq >/dev/null 2>&1 || die "нет jq"
command -v git >/dev/null 2>&1 || die "нет git"
[ -x "$HERE/profile_resolver.sh" ] || die "нет profile_resolver.sh"

REPO_ABS="$(cd "$REPO" && pwd -P)"
export HARNESS_PROJECT_LAYER_ROOT="${HARNESS_PROJECT_LAYER_ROOT:-$REPO_ABS}"

# Один-единственный зов resolver (контракт 996 §Интерфейсы «helper вызывает
# resolver один раз»). Все пути и sourceCanon — из merged-профиля.
_err="$(mktemp 2>/dev/null || echo /dev/null)"
trap 'rm -f "$_err"' EXIT
MERGED=""
if ! MERGED="$("$HERE/profile_resolver.sh" --repo "$REPO_ABS" 2>"$_err")"; then
  _pc_reason="$(cat "$_err" 2>/dev/null || true)"
  rm -f "$_err"
  die "${_pc_reason#profile ОТКАЗ: }"
fi
rm -f "$_err"
[ -n "$MERGED" ] || die "профиль пуст"

# ── Гард И-5: пути строго ВНУТРИ репо ─────────────────────────────────────
# Каждое значение <workflowPaths>.* канонизируется readlink -f и должно
# иметь префикс REPO_ABS. «..», абсолютный путь и симлинк наружу отказывают
# единой фразой. Проверка ДО формирования JSON, чтобы ни одна ветвь не печатала
# частичный результат.
for _wpk in contracts verdicts registry fixtures; do
  _wpv="$(printf '%s' "$MERGED" | jq -r --arg k "$_wpk" '.workflowPaths[$k].value // empty')"
  [ -n "$_wpv" ] || die "профиль без workflowPaths.$_wpk"
  _wpcanon="$(readlink -f -- "$REPO_ABS/$_wpv" 2>/dev/null || true)"
  case "$_wpv" in /*) _wpcanon="/вне" ;; esac
  case "$_wpcanon" in "$REPO_ABS"/*) ;; *) die "workflowPaths вне репо: $_wpk=$_wpv" ;; esac
done
unset _wpk _wpv _wpcanon

STATE="$(printf '%s' "$MERGED" | jq -r '.workflowPaths.state.value // ".harness"')"
[ -n "$STATE" ] || STATE=".harness"
# Гард для state: относительный, без ведущего /, не .., лежит ВНУТРИ репо.
case "$STATE" in
  /*) die "workflowPaths.state обязан быть относительным: $STATE" ;;
esac
case "$STATE" in
  *..*) die "workflowPaths.state содержит ..: $STATE" ;;
esac
_STATE_ABS="$(cd "$REPO_ABS" && readlink -f -- "$STATE" 2>/dev/null || true)"
case "$_STATE_ABS" in
  "$REPO_ABS") ;;            # state="." — сам корень репо
  "$REPO_ABS"/*) ;;          # любой подкаталог репо
  *) die "workflowPaths.state вне репо: $STATE" ;;
esac
unset _STATE_ABS

# Конструкция JSON-а: ключи workflowPaths.* идёт уже канонизированным путём
# (мы сверяли выше, что readlink -f лежит внутри REPO_ABS). State-каталог —
# HANDOFF/NABLIUDENIA*/ROADMAP.md/forks — фиксированные basename-ы.
# State-prefix: «.» → REPO_ABS (state сам репо). workflowPaths.* — ТОП-УРОВНЕВЫЕ
# каталоги внутри REPO_ABS, не под state.
_STATE_PREFIX="$REPO_ABS"
[ "$STATE" != "." ] && _STATE_PREFIX="$REPO_ABS/${STATE%/}"

CONTRACTS="$(printf '%s' "$MERGED" | jq -r '.workflowPaths.contracts.value')"
VERDICTS="$(printf '%s' "$MERGED" | jq -r '.workflowPaths.verdicts.value')"
REGISTRY="$(printf '%s' "$MERGED" | jq -r '.workflowPaths.registry.value')"
FIXTURES="$(printf '%s' "$MERGED" | jq -r '.workflowPaths.fixtures.value')"

SOURCE_CANON="$(printf '%s' "$MERGED" | jq -c '.sourceCanon.value // null')"

# jq-сборка ОДНОГО документа; терминатор — конец JSON, никаких следов.
jq -n \
  --arg contracts    "$REPO_ABS/$CONTRACTS" \
  --arg verdicts     "$REPO_ABS/$VERDICTS" \
  --arg registry     "$REPO_ABS/$REGISTRY" \
  --arg fixtures     "$REPO_ABS/$FIXTURES" \
  --arg handoff      "$_STATE_PREFIX/HANDOFF.md" \
  --arg observations "$_STATE_PREFIX/NABLIUDENIA.md" \
  --arg arch_obs     "$_STATE_PREFIX/NABLIUDENIA_ARCHITECT.md" \
  --arg roadmap      "$_STATE_PREFIX/ROADMAP.md" \
  --arg forks        "$_STATE_PREFIX/forks" \
  --argjson source_canon "$SOURCE_CANON" \
  '{
     contracts:  $contracts,
     verdicts:   $verdicts,
     registry:   $registry,
     fixtures:   $fixtures,
     handoff:    $handoff,
     observations:      $observations,
     architectObservations: $arch_obs,
     roadmap:    $roadmap,
     forks:      $forks,
     sourceCanon: $source_canon
   }'