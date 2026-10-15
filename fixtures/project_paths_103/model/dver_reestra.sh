#!/usr/bin/env bash
# Честная модель 103 для ветви spawn_agent dual-control (И-3): манифест
# читается с origin/main по пути <workflowPaths.registry>/contracts.tsv ПРОЕКТА
# (эффективное значение профиля --root), не по registry/contracts.tsv харнеса.
# Эффективное значение — ТОЛЬКО из MERGED scripts/profile_resolver.sh --repo R
# (единственный источник, §Предмет 103; слой проекта — HARNESS_PROJECT_LAYER_ROOT,
# по умолчанию R, как make_task.sh). Свой jq по harness.project.json/profilePath
# под R — «второй резолвер» (Рв96-2): при слое вне репо и репо-слое без
# workflowPaths он не видит значение (ложный отказ) либо читает устаревшую
# копию слоя в R (спавн по корневому реестру харнеса при чужом sha в профильном).
# Грамматика строки — 023 дословно («<NNN> → <40-hex>», sha объекта
# аннотированного тега id/CONTRACT/<NNN> на origin). Успех печатает
# WORKTREE=/BRANCH= (016) без создания ветки/worktree (модель — грамматика ноги).
set -uo pipefail
AUTHOR=""; NNN=""; ROOT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --author) AUTHOR="${2:?}"; shift 2 ;;
    --nnn) NNN="${2:?}"; shift 2 ;;
    --root) ROOT="${2:?}"; shift 2 ;;
    *) shift ;;
  esac
done
[ -n "$AUTHOR" ] && [ -n "$NNN" ] && [ -d "$ROOT" ] || { printf 'NOT_IMPLEMENTED: --author/--nnn/--root\n' >&2; exit 2; }
nnn="$(printf '%03d' "$NNN")"
[ -s "$ROOT/.omp/context/$nnn.tsv" ] || { printf 'ОТКАЗ: нет манифеста make_task: %s\n' "$nnn" >&2; exit 1; }
# Единственный источник эффективного профиля — profile_resolver.sh харнеса
# (корень — PP103_ROOT раннера; стаб-копии модели лежат вне семьи, поэтому
# BASH_SOURCE — только фолбэк живого прогона модели по месту).
RESOLVER="${PP103_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}/scripts/profile_resolver.sh"
[ -f "$RESOLVER" ] || { printf 'NOT_IMPLEMENTED: нет %s\n' "$RESOLVER" >&2; exit 2; }
[ -n "${HARNESS_PROJECT_LAYER_ROOT:-}" ] || export HARNESS_PROJECT_LAYER_ROOT="$ROOT"
MERGED="$(bash "$RESOLVER" --repo "$ROOT" 2>/dev/null)" || { printf 'ОТКАЗ: профиль не резолвится: %s\n' "$ROOT" >&2; exit 1; }
REG="$(printf '%s' "$MERGED" | jq -r '.workflowPaths.registry.value // empty' 2>/dev/null)" # t103-m15
[ -n "$REG" ] || { printf 'ОТКАЗ: профиль без workflowPaths.registry\n' >&2; exit 1; }
MANIFEST_PATH="$REG/contracts.tsv" # t103-m8
tag_sha="$(git -C "$ROOT" ls-remote origin "refs/tags/id/CONTRACT/$nnn" 2>/dev/null | grep -v '\^{}' | awk '{print $1}')"
[ -n "$tag_sha" ] || { printf 'ОТКАЗ: тег %s не выдан авторитетом: тег не достижим на origin (3а)\n' "$nnn" >&2; exit 1; }
main_sha="$(git -C "$ROOT" ls-remote origin refs/heads/main 2>/dev/null | awk '{print $1}')"
git -C "$ROOT" fetch -q origin refs/heads/main 2>/dev/null || { printf 'ОТКАЗ: авторитет недоступен\n' >&2; exit 1; }
text="$(git -C "$ROOT" cat-file -p "${main_sha}:${MANIFEST_PATH}" 2>/dev/null)"
[ -n "$text" ] || { printf 'ОТКАЗ: тег %s не выдан авторитетом: манифест %s отсутствует на origin/main (3б)\n' "$nnn" "$MANIFEST_PATH" >&2; exit 1; }
line_sha="$(printf '%s\n' "$text" | grep -F "$nnn → " | head -1 | awk '{print $3}')"
[ -n "$line_sha" ] || { printf 'ОТКАЗ: тег %s не выдан авторитетом: строки нет в манифесте %s (3б)\n' "$nnn" "$MANIFEST_PATH" >&2; exit 1; }
[ "$line_sha" = "$tag_sha" ] || { printf 'ОТКАЗ: тег %s не выдан авторитетом: sha манифеста %s ≠ sha тега на origin (3в)\n' "$nnn" "$MANIFEST_PATH" >&2; exit 1; }
printf 'WORKTREE=%s\nBRANCH=wip/%s/%s\n' "/tmp/dev-harness-verify/model-wt-$nnn" "$nnn" "$AUTHOR"
exit 0
