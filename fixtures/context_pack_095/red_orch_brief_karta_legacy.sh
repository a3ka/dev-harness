#!/usr/bin/env bash
# Клетка И-12-скоуп «карта WORK на неполном реестре» (А-387, Б4 круга 1
# ревьюера): brief-цикл НЕ умирает на первом неудобном контракте — предмет
# несёт ЦЕПОЧКА носителей (И-19, followup-1112). Ветви:
#   (а) контракт ВНЕ plan.tsv без §Предмет (666, legacy) — бриф жив (rc 0),
#       WORK-строки НЕ несёт: вне-планные опускаются СО СЧЁТНОЙ строкой
#       (судит red_orch_brief_bounded_work.sh);
#   (б) АКТИВНЫЙ (строка в plan.tsv) без секции/inline, с фактическим H1
#       (534, класс harness 154/157/184) — WORK-строка с предметом H1:
#       реальное описание, не смерть брифа и не placeholder;
#   (в) суффикс-заголовок «## Предмет (…)» (555, класс 092/094/095 живого
#       дерева) — предмет извлекается строкой WORK, не пропускается.
# Контракты-входы живут в toy-мире (не в настоящем contracts/), оракул-строки
# — литералы в памяти ДО вызова (правило 8).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: orch-brief-karta-legacy: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }

W="$(_t95_world karta)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_trace "$W/trace.tsv" orchestrator glm-4.7 allowed

# мир (а)/(б)/(в): 666 — legacy ВНЕ плана без §Предмет (класс 006/007/…);
# 534 — АКТИВНЫЙ без носителя предмета, только H1 (класс 154/157/184);
# 555 — АКТИВНЫЙ с суффикс-заголовком (класс 092/094/095). 888 уже в
# plan.tsv каркасом, файла нет.
cat >"$R/contracts/666-legacy-toy.md" <<'EOF'
# Контракт 666 — legacy toy

## Существующее

- toy-код без секции предмета
EOF
cat >"$R/contracts/534-aktiv-bez-sekcii-toy.md" <<'EOF'
# Контракт 534 — актив без секции toy

## Существующее

- toy-код без носителя предмета
EOF
cat >"$R/contracts/555-suffiks-toy.md" <<'EOF'
# Контракт 555 — суффикс toy

## Предмет (сводка владельца)

предмет-с-суффиксом-заголовка.
EOF
printf '534\t1\tдо V-2\t-\ttoy\ttrack\n' >>"$R/registry/plan.tsv"
printf '555\t1\tдо V-2\t-\ttoy\ttrack\n' >>"$R/registry/plan.tsv"
git -C "$R" add -A && git -C "$R" commit -qm 'карта WORK: legacy вне плана + актив с H1 + суффикс-заголовок'

# оракули ДО вызова (правило 8)
WANT_H1='WORK: 534 :: Контракт 534 — актив без секции toy'
WANT_SUFFIKS='WORK: 555 :: предмет-с-суффиксом-заголовка.'

# (а)+(б)+(в): бриф жив; H1 активного — реальный предмет; суффикс — предмет
out="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: karta: бриф умер на неполном реестре (Б4): rc=%s, вывод: %s\n' "$rc" "$out" >&2; exit 1
fi
printf '%s\n' "$out" | grep -q '^WORK: 666 ::' && { printf 'КРАСНО: karta: вне-планный legacy (666) показан WORK-строкой — bounded WORK (И-17) не опускает вне плана\n' >&2; exit 1; }
printf '%s\n' "$out" | grep -Fxq -- "$WANT_H1" || { printf 'КРАСНО: karta: активный без секции (534) не несёт предмет фактическим H1 — смерть/placeholder вместо реального описания\n' >&2; exit 1; }
printf '%s\n' "$out" | grep -Fxq -- "$WANT_SUFFIKS" || { printf 'КРАСНО: karta: суффикс-заголовок «## Предмет (…)» — предмет не извлечён строкой WORK\n' >&2; exit 1; }
exit 0
