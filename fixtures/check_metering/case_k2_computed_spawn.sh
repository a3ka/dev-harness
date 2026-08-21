# ПРИЧИНА: healthz не ответил
#
# Ветвь (к2), РАНТАЙМ-энфорсмент (арбитраж f175567). Греп — регресс-гард, приёмочную
# силу даёт --permission без --allow-child-process. Красный — копия прокси, порождающая
# процесс через `process['getBuiltin'+'Module']('node:'+'child_'+'process')['exec'+'FileSync']`:
# склейка строк евадит literal-греп к2 (находка адверсария 2026-08-21), но пер-процессный
# запрет node бросает ERR_ACCESS_DENIED на порождении → обработчик падает → healthz не 200
# → барьер красный. Если флаг выпадет — сверка энфорсмента (к2) покраснеет «энфорсмент выпал».
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
top = "async function handleRequest(\n"
assert s.count(top) >= 1, "якорь handleRequest не найден"
s = s.replace(top, "const __probeK2 = process[\"getBuiltin\" + \"Module\"](\"node:\" + \"child_\" + \"process\")\n\nasync function handleRequest(\n", 1)
handler = "): Promise<void> {\n  // 1. healthz"
assert s.count(handler) == 1, "якорь входа handleRequest не уникален"
s = s.replace(handler, "): Promise<void> {\n  __probeK2[\"exec\" + \"FileSync\"](\"/bin/echo\", [\"probe\"])\n  // 1. healthz")
open(p, 'w', encoding='utf-8').write(s)
PY

set +e
out="$(BARRIER_ROOT="$R" "$BARRIER" 2>&1)"
rc=$?
set -e
[ "$rc" = "1" ] || die "красный прогон не 1: rc=$rc; вывод: $out"
printf '%s' "$out" | grep -qE "healthz не ответил|энфорсмент выпал" \
  || die "красный прогон не назвал причину «healthz не ответил / энфорсмент выпал»: $out"
exit 0
