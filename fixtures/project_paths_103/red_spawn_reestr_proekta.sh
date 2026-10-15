#!/usr/bin/env bash
# Клетка И-3 «dual-control спавна читает реестр ПРОЕКТА» (контракт 103).
# Toy-репо с origin (bare) и аннотированным тегом id/CONTRACT/777 на origin;
# workflowPaths.registry=tasks/reg. Манифест-файл пака 777 (нога 095) создан.
# (а) tasks/reg/contracts.tsv на origin/main несёт «777 → <sha тега>», корневого
#     registry/contracts.tsv НЕТ → дверь НЕ отказывает «манифест … отсутствует
#     (3б)» и выходит rc 0 с BRANCH=wip/777/implementer (созданное зачищается);
# (б) корневой registry/contracts.tsv с ВЕРНОЙ строкой, а tasks/reg/contracts.tsv
#     с ЧУЖИМ sha → дверь отказывает rc 1 «не выдан авторитетом» (читает
#     профильный реестр, не корневой). Обман (путь реестра зашит) → (а) rc 1
#     или (б) rc 0 → красно.
# Слой проекта ВНЕ репо (Рв96-2; мир _t103_world_sloj_vne: репо-слой без
# workflowPaths, слой по HARNESS_PROJECT_LAYER_ROOT=<мир>/layer, в R нет
# tasks/reg/harness-project.json) — эффективный registry=tasks/reg существует
# ТОЛЬКО через profile_resolver.sh:
# (в) как (а) на этом мире → rc 0 и BRANCH, без «профиль без workflowPaths.registry»
#     (второй резолвер — свой jq по R — значения не видит → ложный отказ → красно);
# (г) как (б) на этом мире плюс УСТАРЕВШАЯ копия слоя в R
#     (tasks/reg/harness-project.json с defaults.workflowPaths.registry=registry)
#     → rc 1 «не выдан авторитетом» (второй резолвер читает копию в R → корневой
#     registry/contracts.tsv с верной строкой → rc 0 → красно).
# Клетка прогоняет все четыре входа, каждый красен своей строкой.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
DOOR="$(_t103_spawn)"
[ -f "$DOOR" ] || { printf 'КРАСНО: spawn-reestr-proekta: предмет отсутствует: scripts/spawn_agent.sh\n' >&2; exit 1; }
itog=0

zachistka() {  # <репо>
  local b wt
  for b in $(git -C "$1" for-each-ref --format='%(refname:short)' 'refs/heads/wip/'); do
    wt="$(git -C "$1" worktree list --porcelain | awk -v b="refs/heads/$b" '$1=="worktree"{w=$2} $1=="branch"&&$2==b{print w}')"
    [ -n "$wt" ] && git -C "$1" worktree remove --force "$wt" 2>/dev/null
    git -C "$1" branch -D "$b" >/dev/null 2>&1
  done
}

# origin_i_mint <мир>: bare origin, аннотированный тег 777, профильный реестр с
# верной строкой на origin/main, манифест пака. Печатает sha объекта тега.
origin_i_mint() {
  local W="$1" R="$1/repo" sha
  git init -q --bare --initial-branch=main "$W/origin.git" || return 2
  git -C "$R" remote add origin "$W/origin.git"
  git -C "$R" tag -a id/CONTRACT/777 -m 'минт 777'
  sha="$(git -C "$R" rev-parse id/CONTRACT/777)"   # sha ОБЪЕКТА тега (023)
  printf '777 → %s\n' "$sha" >"$R/tasks/reg/contracts.tsv"
  git -C "$R" add -A; git -C "$R" commit -qm 'реестр проекта с минтом 777'
  git -C "$R" push -q origin main id/CONTRACT/777 2>/dev/null || return 2
  mkdir -p "$R/.omp/context"; printf '=== MANIFEST ===\ncontext\ttasks/h/777-toy.md\tmandatory\tdraft\n' >"$R/.omp/context/777.tsv"
  [ ! -e "$R/registry" ] || { printf 'КРАСНО: i3: мир сломан — есть корневой registry/\n' >&2; return 2; }
  printf '%s' "$sha"
}
# podmena <репо> <sha>: корневой реестр с верной строкой, профильный — с чужим sha
podmena() {
  mkdir -p "$1/registry"; printf '777 → %s\n' "$2" >"$1/registry/contracts.tsv"
  printf '777 → %s\n' "$(printf '%040d' 7)" >"$1/tasks/reg/contracts.tsv"
  git -C "$1" add -A; git -C "$1" commit -qm 'подмена: корневой верный, профильный чужой'
  git -C "$1" push -q origin main 2>/dev/null
}
# pozitiv <id> <репо> <описание> — rc 0, BRANCH, без фраз второго резолвера/корня
pozitiv() {
  local out rc
  out="$(bash "$DOOR" --author implementer --nnn 777 --root "$2" 2>&1)"; rc=$?
  zachistka "$2"
  if printf '%s\n' "$out" | grep -Fq 'registry/contracts.tsv отсутствует'; then
    printf 'КРАСНО: %s: дверь ищет корневой registry/contracts.tsv, не tasks/reg (%s; вывод: %s)\n' "$1" "$3" "$out" >&2; itog=1; return
  fi
  if printf '%s\n' "$out" | grep -Fq 'профиль без workflowPaths.registry'; then
    printf 'КРАСНО: %s: дверь не видит эффективный workflowPaths.registry резолвера (%s; вывод: %s)\n' "$1" "$3" "$out" >&2; itog=1; return
  fi
  if [ "$rc" -ne 0 ] || ! printf '%s\n' "$out" | grep -Fxq 'BRANCH=wip/777/implementer'; then
    printf 'КРАСНО: %s: спавн по профильному реестру не прошёл (%s; rc=%s, вывод: %s)\n' "$1" "$3" "$rc" "$out" >&2; itog=1; return
  fi
  printf -- '— %s: rc=0, BRANCH по профильному реестру (%s)\n' "$1" "$3"
}
# negativ <id> <репо> <описание> — rc 1 «не выдан авторитетом»
negativ() {
  local out rc
  out="$(bash "$DOOR" --author implementer --nnn 777 --root "$2" 2>&1)"; rc=$?
  zachistka "$2"
  if [ "$rc" -ne 1 ] || ! printf '%s\n' "$out" | grep -Fq 'не выдан авторитетом'; then
    printf 'КРАСНО: %s: дверь зачла корневой registry/contracts.tsv вместо профильного (%s; rc=%s, вывод: %s)\n' "$1" "$3" "$rc" "$out" >&2; itog=1; return
  fi
  printf -- '— %s: rc=1, не выдан авторитетом (%s)\n' "$1" "$3"
}

# ── слой в репо (а)/(б) ──
W="$(_t103_world i3)" || exit 2
trap '_t103_cleanup "$W"; _t103_cleanup "${W2:-}"' EXIT
R="$W/repo"
TAG_SHA="$(origin_i_mint "$W")" || exit 2
pozitiv i3а "$R" 'слой в R'
podmena "$R" "$TAG_SHA" || exit 2
negativ i3б "$R" 'слой в R'

# ── слой вне репо (в)/(г) ──
W2="$(_t103_world_sloj_vne i3-sloj)" || exit 2
R2="$W2/repo"
export HARNESS_PROJECT_LAYER_ROOT="$W2/layer"
TAG_SHA2="$(origin_i_mint "$W2")" || exit 2
pozitiv i3в "$R2" 'слой вне R, репо-слой без workflowPaths'
# устаревшая копия слоя в R: registry=registry (а эффективный — tasks/reg по env)
jq '.defaults.workflowPaths.registry = "registry"' "$W2/layer/tasks/reg/harness-project.json" >"$R2/tasks/reg/harness-project.json" || exit 2
podmena "$R2" "$TAG_SHA2" || exit 2
negativ i3г "$R2" 'слой вне R, устаревшая копия слоя в R'
exit "$itog"
