#!/usr/bin/env bash
# Клетка И-16 «PRECOND брифа», часть 5 (контракт 095 v2 Б3; арбитраж
# 095-granica-v2, решение 4): пограничная сериализация. Байты PRECOND входят и
# в финальный BUDGET, и в базовый размер перед усечением WORK: на мире, где
# WORK-обзор упирается в кап, обязательные три строки PRECOND не теряются,
# WORK сокращён ЯВНО строкой остатка (счёт сходится: выдано + опущено = все
# открытые контракты плана), реальный пересчёт байтов пака до MANIFEST
# совпадает со строкой BUDGET, кап 40000 не поднят. Секция — непосредственно
# после HEALTH. Обман s60 «BUDGET без байтов PRECOND» → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: precond-serial: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }
red() { printf 'КРАСНО: precond-serial: %s\n' "$*" >&2; exit 1; }
ROOT="${CP095_ROOT:-$(cd "$HERE/../.." && pwd)}"

W="$(_t95_world i16ser)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_plan_green "$R" || red 'план-зелёный мир не строится'
_t95_trace "$W/trace.tsv" orchestrator glm-4.7 allowed

# 90 открытых контрактов плана с длинными предметами (~460 байт строка WORK):
# обзор WORK гарантированно упирается в кап вклейки и усекается
subj="$(head -c 460 /dev/zero | tr '\0' 'x')"
{
  head -n 1 "$R/registry/plan.tsv"
  i=300; while [ "$i" -lt 390 ]; do printf '%s\t1\tдо V-2\t-\tdocs/owner/PLAN-toy.md#Контур\ttrack\n' "$i"; i=$((i+1)); done
} >"$W/plan.wide"
cp "$W/plan.wide" "$R/registry/plan.tsv"
sha="$(git -C "$R" rev-parse HEAD)"
{
  printf '777 → %s\n' "$sha"
  i=300; while [ "$i" -lt 390 ]; do printf '%s → %s\n' "$i" "$sha"; i=$((i+1)); done
} >"$R/registry/contracts.tsv"
i=300; while [ "$i" -lt 390 ]; do
  printf '# Контракт %s — serial\n\n## Предмет\n\n%s\n\nЗОНА implementer: scripts/toy.sh\n' "$i" "$subj" >"$R/contracts/${i}-s.md"
  i=$((i+1))
done
bash "$ROOT/scripts/gen_plan.sh" --write --root "$R" >/dev/null 2>&1 || red 'ROADMAP/HANDOFF не регенерируются'
git -C "$R" add -A && git -C "$R" -c user.name=f -c user.email=f@l commit -qm 'широкий план'

# оракул ДО вызова (правило 8): мир без origin — sync NOT_RUN, gate зелёная,
# slice исполнился и отказал именованно (фактический rc=1 и его stderr)
s_rc=0; s_err=""
s_err="$(bash "$ROOT/scripts/orch_plan_slice.sh" --repo "$R" 2>&1 >/dev/null)" || s_rc=$?
[ "$s_rc" -eq 1 ] || red "оракул среза 182 без origin: rc=$s_rc (мир построен неверно)"
a_tail="$(_t95_tail120 "$s_err")"

out="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
[ "$rc" -eq 0 ] || red "бриф rc=$rc: $out"
# обязательные три строки не потеряны усечением — дословно
[ "$(grep -c '^PRECOND: ' <<<"$out")" -eq 3 ] || red 'PRECOND-строк не 3 (замкнутый перечень потерян усечением?)'
grep -Fxq 'PRECOND: sync_main rc=2 NOT_RUN нет origin/main' <<<"$out" || red 'sync_main-строка потеряна/искажена усечением'
grep -Fxq 'PRECOND: plan_gate rc=0' <<<"$out" || red 'plan_gate-строка потеряна/искажена усечением'
grep -Fxq "PRECOND: plan_slice rc=1 $a_tail" <<<"$out" || red 'plan_slice-строка потеряна/искажена усечением'
# секция — непосредственно после HEALTH
l_health="$(grep -n '^=== HEALTH ===$' <<<"$out" | cut -d: -f1)"
l_precond="$(grep -n '^=== PRECOND ===$' <<<"$out" | cut -d: -f1)"
next_hdr="$(printf '%s\n' "$out" | awk -v h="$l_health" 'NR>h && /^=== /{print NR; exit}')"
[ "$next_hdr" = "$l_precond" ] || red 'секция PRECOND не непосредственно после HEALTH'
# WORK сокращён ЯВНО, счёт сходится
grep -Eq '^WORK: за бюджетом брифа: [0-9]+ строк; полный план и контракты — по MAP$' <<<"$out" \
  || red 'WORK усечён без явной строки остатка'
omitted="$(printf '%s\n' "$out" | sed -n 's/^WORK: за бюджетом брифа: \([0-9]\+\) строк;.*/\1/p')"
included="$(grep -c '^WORK: [0-9]\+ :: ' <<<"$out")"
[ "$((included + omitted))" -eq 90 ] || red "счёт WORK не сходится: выдано $included + опущено ${omitted:-0} ≠ 90"
# реальный пересчёт совпадает со строкой BUDGET; кап не поднят
vk_line="$(printf '%s\n' "$out" | grep '^BUDGET: vklejka=' || true)"
[ -n "$vk_line" ] || red 'нет строки BUDGET'
vk="$(printf '%s\n' "$vk_line" | sed -n 's/^BUDGET: vklejka=\([0-9]\+\)\/40000$/\1/p')"
[ -n "$vk" ] || red "строка BUDGET не по грамматике: $vk_line"
recount="$(printf '%s\n' "$out" | awk '/^=== MANIFEST ===$/{exit} {print}' | wc -c | tr -d ' ')"
[ "$vk" = "$recount" ] || red "BUDGET врёт: строка vklejka=$vk, реальный пересчёт до MANIFEST = $recount (байты PRECOND обязаны входить)"
[ "$vk" -le 40000 ] || red "кап вклейки поднят: $vk > 40000"
exit 0
