#!/usr/bin/env bash
# Клетка И-4в «полный набор нарушений — каждое названо, ни одно не скрыто за
# предыдущим» (контракт 103). Из эталона строится ОДИН мир с ТРЕМЯ
# одновременными нарушениями komandy-true, env-example, harness-pin. Субъект
# обязан дать rc 1, РОВНО 3 строки «ОТКАЗ: стандарт:» и каждую из трёх
# «ОТКАЗ: стандарт: <имя>:» (порядок не судится). Обман «exit после первой
# красной строки» → одна строка вместо трёх → красно; «одна строка на всё»
# → имена не названы → красно.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t103_standard)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: standart-polnyj-nabor: предмет отсутствует: scripts/check_project_standard.sh\n' >&2; exit 1; }
W="$(_t103_complior i4v)" || exit 2
trap '_t103_cleanup "$W"' EXIT
R="$W/repo"
( cd "$R" \
  && jq '.commands.test = "true"' harness.project.json >harness.project.json.new && mv harness.project.json.new harness.project.json \
  && rm .env.example \
  && rm config/harness_pin.json ) || { printf 'КРАСНО: i4v: порча мира не применилась\n' >&2; exit 2; }
out="$(cd / && HARNESS_PROJECT_LAYER_ROOT="$R" bash "$SUBJ" --repo "$R" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ]; then
  printf 'КРАСНО: i4v: rc=%s (ждали 1): %s\n' "$rc" "$out" >&2; exit 1
fi
n="$(printf '%s\n' "$out" | grep -c 'ОТКАЗ: стандарт:')"
if [ "$n" -ne 3 ]; then
  printf 'КРАСНО: i4v: строк «ОТКАЗ: стандарт:» %s, ждали 3 (вывод: %s)\n' "$n" "$out" >&2; exit 1
fi
itog=0
for name in komandy-true env-example harness-pin; do
  if printf '%s\n' "$out" | grep -Fq "ОТКАЗ: стандарт: $name:"; then
    printf -- '— i4v/%s: названо\n' "$name"
  else
    printf 'КРАСНО: i4v/%s: причина не названа (вывод: %s)\n' "$name" "$out" >&2; itog=1
  fi
done
exit "$itog"
