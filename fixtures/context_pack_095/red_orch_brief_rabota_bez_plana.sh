#!/usr/bin/env bash
# Цепочка носителей/прецедент и отсутствие plan.tsv из 660d6d24, без DAG.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: bez-plana: предмет отсутствует\n' >&2; exit 1; }
red() { printf 'КРАСНО: bez-plana: %s\n' "$*" >&2; exit 1; }
W="$(_t95_world bezplana)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_trace "$W/trace.tsv" orchestrator glm-4.7 allowed
rm "$R/registry/plan.tsv"
printf '# Контракт 700 — секция\n\n## Предмет\n\nпредмет-700.\n' >"$R/contracts/700-sekcija.md"
printf '# 710 — ЧЕРНОВИК\n\nКласс: код. Предмет: tools/check-x.py — барьер y.\n' >"$R/contracts/710-inline.md"
printf '# Контракт 720 — обещание\n\n## Обещание и граница\n\nобещание-720.\n' >"$R/contracts/720-obeshanie.md"
printf '# Контракт 730\n\nПредмет: inline-730.\n\n## Обещание и граница\n\nобещание-730.\n\n## Предмет\n\nпредмет-730.\n' >"$R/contracts/730-pretsedens.md"
printf '# Контракт 731\n\nПредмет: inline-731.\n\n## Обещание и граница\n\nобещание-731.\n' >"$R/contracts/731-pretsedens.md"
printf '# Контракт 732 — содержательный заголовок\n' >"$R/contracts/732-h1.md"
# Ожидаемые значения в памяти ДО субъекта, не чтение его диска после вызова.
wants=$'WORK: 700 :: предмет-700.\nWORK: 710 :: черновик: tools/check-x.py — барьер y.\nWORK: 720 :: обещание-720.\nWORK: 730 :: предмет-730.\nWORK: 731 :: обещание-731.\nWORK: 732 :: Контракт 732 — содержательный заголовок\nWORK: 777 :: toy-предмет.'
out="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>"$W/err")"; rc=$?
[ "$rc" -eq 0 ] || red "нет брифа rc=$rc: $(cat "$W/err")"
work="$(awk '/^=== WORK ===$/ {f=1;next} /^=== / {f=0} f {print}' <<<"$out")"
while IFS= read -r want; do grep -Fxq -- "$want" <<<"$work" || red "нет предмета/не тот приоритет: $want"; done <<<"$wants"
[ "$(grep -c '^WORK: [0-9]' <<<"$work")" -eq 7 ] || red 'без плана потеряны или выдуманы предметы'
# Полностью пустой вход — отказ, не придуманный предмет.
: >"$R/contracts/740-empty.md"
no="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>"$W/err")"; rc=$?
[ "$rc" -eq 1 ] && [ -z "$no" ] || red 'пустой контракт не отказал без пака'
grep -Fxq "ОТКАЗ: брифинг: контракт без предмета: $R/contracts/740-empty.md" "$W/err" || red 'не та причина пустого предмета'
# Убираем предыдущую причину: этот отказ обязан быть СВОИМ.
rm "$R/contracts/740-empty.md" "$R/PROJECT.md"
no="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>"$W/err")"; rc=$?
[ "$rc" -eq 1 ] && [ -z "$no" ] || red 'mandatory-потеря не отказала без пака'
# 161a дописывает протокольный маркер; причина и путь остаются точными.
grep -Fxq -e 'ОТКАЗ: источник недоступен: PROJECT.md' -e 'ОТКАЗ: источник недоступен: PROJECT.md (PROFILE_PATH_MISSING)' "$W/err" || red 'не та причина mandatory-отказа'
exit 0
