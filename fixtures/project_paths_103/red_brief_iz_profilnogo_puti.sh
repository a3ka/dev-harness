#!/usr/bin/env bash
# Клетка И-1д «бриф читает план и карту WORK по профильным путям» (контракт
# 103). Профильные источники: tasks/reg/plan.tsv (строка-маркер G) и
# tasks/h/777-toy.md с §Предмет P; приманки harness-layout: корневой
# registry/plan.tsv (маркер G′) и contracts/778-decoy.md с §Предмет P′.
# Субъект (--kind brief --role orchestrator) обязан дать rc 0, G и
# «WORK: 777 :: P» самостоятельными строками; ни G′, ни «WORK: 778» в выводе
# быть не должно. Обман (plan из registry/, WORK из contracts/) → красно.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t103_make_task)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: brief-iz-profilnogo-puti: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }
W="$(_t103_world i1d)" || exit 2
trap '_t103_cleanup "$W"' EXIT
R="$W/repo"
G='# цель-toy-103-g7x1'
G2='# цель-koren-103-k2p9'
P='toy-предмет 103.'
P2='koren-предмет 778.'
printf '%s\n777\t1\tдо V-2\t-\ttoy\ttrack\n' "$G" >"$R/tasks/reg/plan.tsv"
mkdir -p "$R/registry" "$R/contracts"
printf '%s\n778\t1\tдо V-2\t-\tkoren\ttrack\n' "$G2" >"$R/registry/plan.tsv"
_t103_contract "$R/contracts/778-decoy.md" 778
awk -v p="$P" -v q="$P2" '$0==p{print q;next}{print}' "$R/contracts/778-decoy.md" >"$R/contracts/778-decoy.md.new" && mv "$R/contracts/778-decoy.md.new" "$R/contracts/778-decoy.md"
git -C "$R" add -A; git -C "$R" commit -qm 'план и приманки брифа'
# самопроверка мира: §Предмет профильного контракта = P, приманки = P′
grep -Fxq -- "$P" "$R/tasks/h/777-toy.md" || { printf 'КРАСНО: i1d: мир сломан — tasks/h/777-toy.md без §Предмет P\n' >&2; exit 2; }
grep -Fxq -- "$P2" "$R/contracts/778-decoy.md" || { printf 'КРАСНО: i1d: мир сломан — приманка без §Предмет P′\n' >&2; exit 2; }
# оракулы в памяти ДО вызова (правило 8)
WANT_WORK="WORK: 777 :: $P"
_t103_trace "$W/trace.tsv" orchestrator glm-4.7 allowed
out="$(cd / && bash "$SUBJ" --repo "$R" --kind brief --role orchestrator --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: i1d: бриф по профильным путям не строится (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
if printf '%s\n' "$out" | grep -Fq -- "$G2"; then
  printf 'КРАСНО: i1d: G′ из корневого registry/plan.tsv попала в GOAL\n' >&2; exit 1
fi
if ! printf '%s\n' "$out" | grep -Fxq -- "$G"; then
  printf 'КРАСНО: i1d: GOAL не несёт строку G из tasks/reg/plan.tsv (ждали: %s)\n' "$G" >&2; exit 1
fi
if ! printf '%s\n' "$out" | grep -Fxq -- "$WANT_WORK"; then
  printf 'КРАСНО: i1d: WORK не несёт «%s» из tasks/h (вывод: %s)\n' "$WANT_WORK" "$out" >&2; exit 1
fi
if printf '%s\n' "$out" | grep -Fq -- 'WORK: 778'; then
  printf 'КРАСНО: i1d: WORK несёт приманку 778 из корневого contracts/\n' >&2; exit 1
fi
exit 0
