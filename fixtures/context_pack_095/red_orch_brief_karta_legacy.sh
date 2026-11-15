#!/usr/bin/env bash
# Существующая legacy-клетка 095: H1 теперь содержательный носитель,
# вне-планный legacy не занимает WORK; суффикс §Предмет остаётся допустимым.
# Пустой активный контракт по-прежнему настоящий отказ (не placeholder).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: karta: предмет отсутствует\n' >&2; exit 1; }
red() { printf 'КРАСНО: karta: %s\n' "$*" >&2; exit 1; }
W="$(_t95_world karta)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_trace "$W/trace.tsv" orchestrator glm-4.7 allowed
printf '# Контракт 666 — legacy вне плана\n' >"$R/contracts/666-legacy.md"
printf '# Контракт 534 — актив без секции toy\n' >"$R/contracts/534-h1.md"
printf '# Контракт 555\n\n## Предмет (сводка владельца)\n\nпредмет-с-суффиксом-заголовка.\n' >"$R/contracts/555-suffiks.md"
printf '534\t1\tдо V-2\t-\ttoy\ttrack\n555\t1\tдо V-2\t-\ttoy\ttrack\n' >>"$R/registry/plan.tsv"
want_h1='WORK: 534 :: Контракт 534 — актив без секции toy'
want_suffix='WORK: 555 :: предмет-с-суффиксом-заголовка.'
out="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>"$W/err")"; rc=$?
[ "$rc" -eq 0 ] || red "нет брифа rc=$rc: $(cat "$W/err")"
work="$(awk '/^=== WORK ===$/ {f=1;next} /^=== / {f=0} f {print}' <<<"$out")"
grep -Fxq "$want_h1" <<<"$work" || red 'нет фактического H1'
grep -Fxq "$want_suffix" <<<"$work" || red 'суффикс секции потерян'
if grep -q '^WORK: 666 ::' <<<"$work"; then red 'вне-планный legacy заполняет WORK'; fi
: >"$R/contracts/888-empty.md"
no="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>"$W/err")"; rc=$?
[ "$rc" -eq 1 ] && [ -z "$no" ] || red 'пустой активный не отказал без пака'
grep -Fxq "ОТКАЗ: брифинг: контракт без предмета: $R/contracts/888-empty.md" "$W/err" || red 'не та причина отказа'
exit 0
