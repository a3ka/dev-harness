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
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
DOOR="$(_t103_spawn)"
[ -f "$DOOR" ] || { printf 'КРАСНО: spawn-reestr-proekta: предмет отсутствует: scripts/spawn_agent.sh\n' >&2; exit 1; }
W="$(_t103_world i3)" || exit 2
trap '_t103_cleanup "$W"' EXIT
R="$W/repo"
git init -q --bare --initial-branch=main "$W/origin.git" || exit 2
git -C "$R" remote add origin "$W/origin.git"
git -C "$R" tag -a id/CONTRACT/777 -m 'минт 777'
TAG_SHA="$(git -C "$R" rev-parse id/CONTRACT/777)"   # sha ОБЪЕКТА тега (023)
printf '777 → %s\n' "$TAG_SHA" >"$R/tasks/reg/contracts.tsv"
git -C "$R" add -A; git -C "$R" commit -qm 'реестр проекта с минтом 777'
git -C "$R" push -q origin main id/CONTRACT/777 2>/dev/null || exit 2
mkdir -p "$R/.omp/context"; printf '=== MANIFEST ===\ncontext\ttasks/h/777-toy.md\tmandatory\tdraft\n' >"$R/.omp/context/777.tsv"
[ ! -e "$R/registry" ] || { printf 'КРАСНО: i3: мир сломан — есть корневой registry/\n' >&2; exit 2; }

zachistka() {
  local b
  for b in $(git -C "$R" for-each-ref --format='%(refname:short)' 'refs/heads/wip/'); do
    wt="$(git -C "$R" worktree list --porcelain | awk -v b="refs/heads/$b" '$1=="worktree"{w=$2} $1=="branch"&&$2==b{print w}')"
    [ -n "$wt" ] && git -C "$R" worktree remove --force "$wt" 2>/dev/null
    git -C "$R" branch -D "$b" >/dev/null 2>&1
  done
}

# (а) профильный реестр — единственный источник
out="$(bash "$DOOR" --author implementer --nnn 777 --root "$R" 2>&1)"; rc=$?
zachistka
if printf '%s\n' "$out" | grep -Fq 'registry/contracts.tsv отсутствует'; then
  printf 'КРАСНО: i3а: дверь ищет корневой registry/contracts.tsv, не tasks/reg (вывод: %s)\n' "$out" >&2; exit 1
fi
if [ "$rc" -ne 0 ] || ! printf '%s\n' "$out" | grep -Fxq 'BRANCH=wip/777/implementer'; then
  printf 'КРАСНО: i3а: спавн по профильному реестру не прошёл (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi

# (б) корневой реестр подложен с верной строкой, профильный — с чужим sha
mkdir -p "$R/registry"; printf '777 → %s\n' "$TAG_SHA" >"$R/registry/contracts.tsv"
printf '777 → %s\n' "$(printf '%040d' 7)" >"$R/tasks/reg/contracts.tsv"
git -C "$R" add -A; git -C "$R" commit -qm 'подмена: корневой верный, профильный чужой'
git -C "$R" push -q origin main 2>/dev/null || exit 2
out2="$(bash "$DOOR" --author implementer --nnn 777 --root "$R" 2>&1)"; rc2=$?
zachistka
if [ "$rc2" -ne 1 ] || ! printf '%s\n' "$out2" | grep -Fq 'не выдан авторитетом'; then
  printf 'КРАСНО: i3б: дверь зачла корневой registry/contracts.tsv вместо профильного (rc=%s, вывод: %s)\n' "$rc2" "$out2" >&2; exit 1
fi
exit 0
