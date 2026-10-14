#!/usr/bin/env bash
# Клетка И-5 «workflowPaths наружу репо — отказ» (контракт 103). Три входа
# для workflowPaths.contracts: (1) `../vne/h` (есть каталог-сосед с
# контрактом 777), (2) абсолютный путь на тот же соседний каталог,
# (3) симлинк `tasks/h` → соседний каталог. Для КАЖДОГО входа два субъекта:
# make_task (--role architect --contract 777) и check_project_standard —
# оба обязаны rc 1 с именованной причиной «workflowPaths вне репо» /
# «ОТКАЗ: стандарт: workflowPaths:». Клетка прогоняет все 3×2 и красна при
# любом принятом побеге. Обман (канонизация снята) → контракт соседа
# прочитан (rc 0) → красно.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
MT="$(_t103_make_task)"; ST="$(_t103_standard)"
[ -f "$MT" ] || { printf 'КРАСНО: puti-vne-repo: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }
[ -f "$ST" ] || { printf 'КРАСНО: puti-vne-repo: предмет отсутствует: scripts/check_project_standard.sh\n' >&2; exit 1; }
W="$(_t103_world i5)" || exit 2
trap '_t103_cleanup "$W"' EXIT
ET="$W/repo"
mkdir -p "$W/vne/h"; _t103_contract "$W/vne/h/777-toy.md" 777
_t103_trace "$W/trace.tsv" architect glm-4.7 allowed

itog=0
proba() {  # <имя> <значение contracts> [symlink]
  local name="$1" val="$2" R out rc
  R="$W/r-$name"; cp -a "$ET" "$R"
  rm -rf "$R/tasks/h"
  if [ "${3:-}" = "symlink" ]; then ln -s "$W/vne/h" "$R/tasks/h"; val="tasks/h"; fi
  _t103_profile "$R" "$val" tasks/v tasks/reg tasks/fx
  out="$(cd / && bash "$MT" --repo "$R" --kind task --role architect --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
  if [ "$rc" -ne 1 ] || ! printf '%s\n' "$out" | grep -Fq 'workflowPaths вне репо'; then
    printf 'КРАСНО: i5/%s/make_task: побег принят (rc=%s, ждали 1 «workflowPaths вне репо»; вывод: %s)\n' "$name" "$rc" "$out" >&2; itog=1
  fi
  if printf '%s\n' "$out" | grep -Fxq -- "$T103_UNIQ"; then
    printf 'КРАСНО: i5/%s/make_task: байты контракта соседа прочитаны\n' "$name" >&2; itog=1
  fi
  out="$(cd / && HARNESS_PROJECT_LAYER_ROOT="$R" bash "$ST" --repo "$R" 2>&1)"; rc=$?
  if [ "$rc" -ne 1 ] || ! printf '%s\n' "$out" | grep -Fq 'ОТКАЗ: стандарт: workflowPaths:'; then
    printf 'КРАСНО: i5/%s/standard: побег принят (rc=%s; вывод: %s)\n' "$name" "$rc" "$out" >&2; itog=1
  fi
  printf -- '— i5/%s: прогнано\n' "$name"
}
proba dotdot   "../vne/h"
proba absolut  "$W/vne/h"
proba symlink  "tasks/h" symlink
exit "$itog"
