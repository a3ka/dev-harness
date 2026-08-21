# ПРИЧИНА: погиб на старте
#
# Ветвь (к1), РАНТАЙМ-энфорсмент (арбитраж f175567). Греп — регресс-гард, приёмочную
# силу даёт запуск прокси под --disallow-code-generation-from-strings. Красный — копия
# прокси с загрузкой модуля через `Function("return "+"im"+"port(...)")`: склейка строк
# евадит literal-греп к1 (находка адверсария 2026-08-21), но code-gen из строк под
# флагом бросает EvalError на загрузке модуля → прокси не стартует → барьер красный.
# Если флаг выпадет из запуска — прокси стартует, а сверка энфорсмента (к1) покраснеет
# «энфорсмент выпал»: фикстура красна в обоих состояниях, потому грепаем оба.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$(make_repo)"
WORK_REPO="$R"

BARRIER_ROOT="$R" "$BARRIER" >/dev/null 2>&1 \
  || die "зелёный прогон не 0 — честный прокси не проходит барьер"

python3 - "$R/scripts/proxy/metering_proxy.ts" <<'PY'
import sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
needle = "async function handleRequest(\n"
assert s.count(needle) >= 1, "якорь handleRequest не найден"
inject = "const __probeK1 = Function(\"return \" + \"im\" + \"port('node:os')\")\nvoid __probeK1\n\nasync function handleRequest(\n"
open(p, 'w', encoding='utf-8').write(s.replace(needle, inject, 1))
PY

set +e
out="$(BARRIER_ROOT="$R" "$BARRIER" 2>&1)"
rc=$?
set -e
[ "$rc" = "1" ] || die "красный прогон не 1: rc=$rc; вывод: $out"
printf '%s' "$out" | grep -qE "погиб на старте|энфорсмент выпал" \
  || die "красный прогон не назвал причину «погиб на старте / энфорсмент выпал»: $out"
exit 0
