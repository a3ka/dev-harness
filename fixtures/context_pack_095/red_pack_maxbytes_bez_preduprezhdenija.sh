#!/usr/bin/env bash
# Б-4 (вердикт Rev095B4, блок Б-4): ИЗВЕСТНЫЙ ключ pack.maxBytes не
# предупреждён. make_task прячет stderr резолвера при успехе
# (make_task.sh:569-572), поэтому клетка вызывает резолвер НАПРЯМУЮ с
# раздельными потоками: rc 0, 0 строк «профиль ПРЕДУПРЕЖДЕНИЕ», merged несёт
# pack.value.maxBytes=130000 с origin repo. Мутант M7 (удалён
# repo:pack:maxBytes:optional из SCHEMA_LEVELS) печатает предупреждение о
# известном ключе — клетка красна. Режим --model — та же семантика на эталоне
# dover.sh; стаб-режим (CP095_RESOLVER) судит испорченную копию резолвера.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

fail() { printf 'КРАСНО: pack-maxbytes/bez-preduprezhdenija: %s\n' "$1" >&2; exit 1; }
ROOT="${CP095_ROOT:-$(cd "$HERE/../.." && pwd)}"

W="$(_t95_world maxbytes-tihij)" || exit 2
trap '_t95_cleanup "$W"' EXIT

# Оракул в памяти ДО вызова (правило 8): только известный ключ pack.maxBytes.
python3 - "$W/repo/harness.project.json" <<'PY'
import json, sys
p = json.load(open(sys.argv[1]))
p['pack'] = {'maxBytes': 130000}
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
  n="$(grep -c 'ПРЕДУПРЕЖДЕНИЕ' "$W/err")"
  [ "$n" -eq 0 ] \
    || fail "предупреждение о известном ключе pack.maxBytes: $(grep -m1 'ПРЕДУПРЕЖДЕНИЕ' "$W/err")"
  jq -e '.pack.value.maxBytes == 130000 and .pack.origin == "repo"' "$W/out.json" >/dev/null 2>&1 \
    || fail 'merged не несёт pack.value.maxBytes=130000 origin=repo'
  printf 'B4 известный pack.maxBytes без предупреждения; merged несёт кап; rc 0\n'
else
  # ── модель: та же семантика на эталоне ────────────────────────────────────
  SUBJ="$(_t95_subject)"
  [ -f "$SUBJ" ] || fail "предмет отсутствует: $SUBJ"
  _t95_trace "$W/trace.tsv" architect glm-4.7 allowed
  HARNESS_PROJECT_LAYER_ROOT="$W/repo" bash "$SUBJ" --repo "$W/repo" --role architect \
    --contract 777 --model-trace "$W/trace.tsv" >"$W/out.txt" 2>"$W/err"
  rc=$?
  [ "$rc" -eq 0 ] || fail "модель отказалась rc=$rc: $(cat "$W/err")"
  n="$(grep -c 'ПРЕДУПРЕЖДЕНИЕ' "$W/err")"
  [ "$n" -eq 0 ] \
    || fail "модель предупредила о известном ключе: $(grep -m1 'ПРЕДУПРЕЖДЕНИЕ' "$W/err")"
  grep -Eq '^BUDGET: vklejka=[0-9]+/130000$' "$W/out.txt" \
    || fail 'BUDGET не по объявленному капу 130000'
  printf 'B4 (модель) известный pack.maxBytes без предупреждения, BUDGET по капу\n'
fi
