#!/usr/bin/env bash
# Клетка И-14 «настоящий профиль → выдача: два слоя 054» (контракт 095, Решение
# 3/8, круг 2; закрытие Б1 вердикта критика круга 1). Карта/rules/reuse
# потребляются из contextPack ПРОФИЛЯ семантикой схемы 054: (а) репо-слой без
# contextPack → defaults слоя проекта ЗАПОЛНЯЮТ карту (MAP: DEFAULTS.md);
# (б) репо-слой с contextPack → его rows замещают defaults-rows ЦЕЛИКОМ
# (юнит-слияние массива, прецедент barriers.mandatory) — DEFAULTS.md в паке
# НЕТ; (в) пин версии слоя проекта разошёлся — именованный отказ фразой 054.
# Обман (s14: слой проекта игнорируется) → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: profil-dva-sloja: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }

W="$(_t95_world i14)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_trace "$W/trace.tsv" architect glm-4.7 allowed

# (б) репо-слой с contextPack: юнит-слияние — defaults-строка НЕ в паке
outb="$(bash "$SUBJ" --repo "$R" --role architect --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rcb=$?
if [ "$rcb" -ne 0 ]; then
  printf 'КРАСНО: i14: пак по базовому профилю не строится (rc=%s, вывод: %s)\n' "$rcb" "$outb" >&2; exit 1
fi
printf '%s\n' "$outb" | grep -Fxq 'MAP: PROJECT.md :: карта проекта' || { printf 'КРАСНО: i14: репо-слой contextPack не потреблён\n' >&2; exit 1; }
if printf '%s\n' "$outb" | grep -Fq 'DEFAULTS.md'; then
  printf 'КРАСНО: i14: defaults-строка слоя проекта прошла СКВОЗЬ юнит-слияние репо-rows\n' >&2; exit 1
fi

# (а) репо-слой БЕЗ contextPack (knob отсутствует — ветвь заполнения наблюдаема,
# зеркало А-377): defaults слоя проекта заполняют карту
jq 'del(.contextPack)' "$R/harness.project.json" >"$W/rj.json" && mv "$W/rj.json" "$R/harness.project.json"
outa="$(bash "$SUBJ" --repo "$R" --role architect --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rca=$?
if [ "$rca" -ne 0 ]; then
  printf 'КРАСНО: i14: пак без репо-contextPack не строится (rc=%s, вывод: %s)\n' "$rca" "$outa" >&2; exit 1
fi
printf '%s\n' "$outa" | grep -Fxq 'MAP: DEFAULTS.md :: проектный дефолт' || { printf 'КРАСНО: i14: defaults слоя проекта не заполнили карту\n' >&2; exit 1; }

# (в) пин версии слоя проекта разошёлся — именованный отказ фразой 054
git -C "$R" checkout -q -- harness.project.json
jq '.projectLayer.version = "9"' "$R/harness.project.json" >"$W/rj9.json" && mv "$W/rj9.json" "$R/harness.project.json"
outv="$(bash "$SUBJ" --repo "$R" --role architect --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rcv=$?
if [ "$rcv" -ne 1 ] || ! printf '%s\n' "$outv" | grep -Fq 'пин слоя проекта расходится'; then
  printf 'КРАСНО: i14: расход пина версии не отказан именем 054 (rc=%s, вывод: %s)\n' "$rcv" "$outv" >&2; exit 1
fi
[ -z "$(printf '%s\n' "$outv" | grep -v 'ОТКАЗ:')" ] || { printf 'КРАСНО: i14: отказ пина выдал частичный пак\n' >&2; exit 1; }
exit 0
