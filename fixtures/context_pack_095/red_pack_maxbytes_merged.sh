#!/usr/bin/env bash
# Б-2 (вердикт Rev095B4, блок Б-2): неизвестный ключ внутри pack НЕ доходит
# до stdout резолвера — М-0: merged перечисляет только известные листы.
# Прямой вызов резолвера с раздельными потоками: rc 0, ровно одна строка
# «профиль ПРЕДУПРЕЖДЕНИЕ: неизвестный ключ репо-слой: pack.rowz»,
# merged.pack.value несёт ТОЛЬКО maxBytes. На базе (дверь не правлена)
# клетка красна: pack копируется целиком, rowz доходит до stdout.
# Режим --model судит эталонную модель (dover.sh) той же семантикой М-0:
# rc 0, предупреждение, BUDGET по объявленному капу, ключ не влияет на выдачу.
# Стаб-режим (CP095_RESOLVER) судит испорченную копию резолвера.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

fail() { printf 'КРАСНО: pack-maxbytes/merged: %s\n' "$1" >&2; exit 1; }
ROOT="${CP095_ROOT:-$(cd "$HERE/../.." && pwd)}"

W="$(_t95_world maxbytes-merged)" || exit 2
trap '_t95_cleanup "$W"' EXIT

# Оракул в памяти ДО вызова (правило 8): известный и неизвестный ключ в pack.
python3 - "$W/repo/harness.project.json" <<'PY'
import json, sys
p = json.load(open(sys.argv[1]))
p['pack'] = {'maxBytes': 130000, 'rowz': 1}
json.dump(p, open(sys.argv[1], 'w'), ensure_ascii=False, indent=2)
PY
# Объявленный профильом ci.workflow обязан существовать для прямого вызова
# резолвера (P-проверка объявленных путей); make_task этот путь не трогает.
printf '# toy ci\n' >"$W/repo/ci.yml"

if [ -n "${CP095_RESOLVER:-}" ] || [ "${CP095_MODE:-real}" != "model" ]; then
  # ── дверь: резолвер напрямую, потоки раздельны ─────────────────────────────
  RESOLVER="${CP095_RESOLVER:-$ROOT/scripts/profile_resolver.sh}"
  [ -f "$RESOLVER" ] || fail "предмет отсутствует: $RESOLVER"
  HARNESS_PROJECT_LAYER_ROOT="$W/repo" bash "$RESOLVER" --repo "$W/repo" \
    >"$W/out.json" 2>"$W/err"
  rc=$?
  [ "$rc" -eq 0 ] || fail "отказ rc=$rc: $(cat "$W/err")"
  grep -Fxq 'профиль ПРЕДУПРЕЖДЕНИЕ: неизвестный ключ репо-слой: pack.rowz' "$W/err" \
    || fail "нет предупреждения М-0 о pack.rowz: $(cat "$W/err")"
  n="$(grep -c 'ПРЕДУПРЕЖДЕНИЕ' "$W/err")"
  [ "$n" -eq 1 ] || fail "предупреждений $n, ожидается ровно одно"
  ! grep -Fq 'rowz' "$W/out.json" || fail 'неизвестный ключ pack.rowz в stdout merged'
  jq -e '.pack.value | keys == ["maxBytes"]' "$W/out.json" >/dev/null 2>&1 \
    || fail '.pack.value несёт не только maxBytes'
  jq -e '.pack.value.maxBytes == 130000 and .pack.origin == "repo"' "$W/out.json" >/dev/null 2>&1 \
    || fail '.pack.value.maxBytes или .pack.origin расходятся'
  printf 'B4 merged pack.value только maxBytes; предупреждение одно; rc 0\n'
else
  # ── модель: та же семантика М-0 на эталоне ────────────────────────────────
  SUBJ="$(_t95_subject)"
  [ -f "$SUBJ" ] || fail "предмет отсутствует: $SUBJ"
  _t95_trace "$W/trace.tsv" architect glm-4.7 allowed
  HARNESS_PROJECT_LAYER_ROOT="$W/repo" bash "$SUBJ" --repo "$W/repo" --role architect \
    --contract 777 --model-trace "$W/trace.tsv" >"$W/out.txt" 2>"$W/err"
  rc=$?
  [ "$rc" -eq 0 ] || fail "модель отказалась rc=$rc: $(cat "$W/err")"
  grep -Fxq 'профиль ПРЕДУПРЕЖДЕНИЕ: неизвестный ключ репо-слой: pack.rowz' "$W/err" \
    || fail "модель не предупредила о pack.rowz: $(cat "$W/err")"
  n="$(grep -c 'ПРЕДУПРЕЖДЕНИЕ' "$W/err")"
  [ "$n" -eq 1 ] || fail "модель: предупреждений $n, ожидается ровно одно"
  ! grep -Fq 'rowz' "$W/out.txt" || fail 'pack.rowz влияет на выдачу модели'
  grep -Eq '^BUDGET: vklejka=[0-9]+/130000$' "$W/out.txt" \
    || fail 'BUDGET не по объявленному капу 130000'
  printf 'B4 merged (модель): предупреждение одно, rc 0, BUDGET по объявленному капу\n'
fi
