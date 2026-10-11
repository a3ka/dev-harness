#!/usr/bin/env bash
# Клетка И-12-скоуп «карта WORK на неполном реестре» (А-387, Б4 круга 1
# ревьюера): brief-цикл НЕ умирает на первом контракте без §Предмет, а
# триажирует. (а) контракт ВНЕ plan.tsv без §Предмет → бриф жив (rc 0) и
# несёт строку-маркер `WORK: <NNN> :: legacy-без-§Предмет (вне plan.tsv)`
# точной строкой (grep -Fx) — не молчаливый пропуск (И-0); (б) контракт В
# plan.tsv без §Предмет → rc 1, «ОТКАЗ: брифинг: контракт без предмета:
# <путь>» дословно, частичного stdout нет (И-3); (в) суффикс-заголовок
# «## Предмет (…)» (класс 092/094/095 живого дерева) — предмет извлекается
# строкой WORK, не пропускается. Контракты-входы живут в той-мире (не в
# настоящем contracts/), оракул-строки — в памяти ДО вызова (правило 8).
# Обман (s19: отказ активным снят) → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: orch-brief-karta-legacy: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }

W="$(_t95_world karta)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_trace "$W/trace.tsv" orchestrator glm-4.7 allowed

# мир (а)/(в): 666 — legacy ВНЕ плана без §Предмет (класс 006/007/… живого
# дерева); 555 — АКТИВНЫЙ (строка в plan.tsv) с суффикс-заголовком — класс
# 092/094/095. 888 уже в plan.tsv каркасом, файла нет — вход (б) ниже.
cat >"$R/contracts/666-legacy-toy.md" <<'EOF'
# Контракт 666 — legacy toy

## Существующее

- toy-код без секции предмета
EOF
cat >"$R/contracts/555-suffiks-toy.md" <<'EOF'
# Контракт 555 — суффикс toy

## Предмет (сводка владельца)

предмет-с-суффиксом-заголовка.
EOF
printf '555\t1\tдо V-2\t-\ttoy\ttrack\n' >>"$R/registry/plan.tsv"
git -C "$R" add -A && git -C "$R" commit -qm 'карта WORK: legacy вне плана + суффикс-заголовок'

# оракули ДО вызова (правило 8)
WANT_LEGACY='WORK: 666 :: legacy-без-§Предмет (вне plan.tsv)'
WANT_SUFFIKS='WORK: 555 :: предмет-с-суффиксом-заголовка.'

# (а)+(в): legacy не убивает бриф; суффикс-заголовок несёт предмет
out="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: karta: бриф умер на неполном реестре (Б4): rc=%s, вывод: %s\n' "$rc" "$out" >&2; exit 1
fi
printf '%s\n' "$out" | grep -Fxq -- "$WANT_LEGACY" || { printf 'КРАСНО: karta: legacy вне плана без §Предмет — нет строки-маркера «%s» (И-0: не молчаливый пропуск)\n' "$WANT_LEGACY" >&2; exit 1; }
printf '%s\n' "$out" | grep -Fxq -- "$WANT_SUFFIKS" || { printf 'КРАСНО: karta: суффикс-заголовок «## Предмет (…)» — предмет не извлечён строкой WORK\n' >&2; exit 1; }

# (б): активный (plan.tsv) без §Предмет — именованный отказ И-12 дословно
cat >"$R/contracts/888-aktiv-toy.md" <<'EOF'
# Контракт 888 — актив без предмета

## Существующее

- активный контракт без секции предмета
EOF
git -C "$R" add -A && git -C "$R" commit -qm 'актив без предмета'
WANT_OTKAZ="ОТКАЗ: брифинг: контракт без предмета: $R/contracts/888-aktiv-toy.md"
sout="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>"$W/err.b")"; rc=$?
serr="$(cat "$W/err.b")"
[ "$rc" -eq 1 ] || { printf 'КРАСНО: karta: активный без предмета — rc=%s, ожидался 1 (вывод: %s)\n' "$rc" "$serr" >&2; exit 1; }
printf '%s\n' "$serr" | grep -Fxq -- "$WANT_OTKAZ" || { printf 'КРАСНО: karta: отказ не дословен: хотели «%s», получили «%s»\n' "$WANT_OTKAZ" "$serr" >&2; exit 1; }
[ -z "$sout" ] || { printf 'КРАСНО: karta: частичный stdout у отказа (И-3): %s\n' "$sout" >&2; exit 1; }
exit 0
