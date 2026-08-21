# ПРИЧИНА: е: budget.json после rebuild ≠ свёртке журнала
#
# Ветвь (е): --rebuild-budget обязан пересобрать budget.json из СВЁРТКИ
# calls.jsonl. Красный — копия прокси, чей rebuildBudget пишет пустой объект
# (константу) вместо свёртки: побайтовое сравнение содержимого с журналом
# расходится. Закрывает находку адверсария 2026-08-21 (сравнения не было вовсе).
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$(make_repo)"
WORK_REPO="$R"

BARRIER_ROOT="$R" "$BARRIER" >/dev/null 2>&1 \
  || die "зелёный прогон не 0 — честный прокси не проходит ветвь (е)"

python3 - "$R/scripts/proxy/metering_proxy.ts" <<'PY'
import sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
needle = "export function rebuildBudget(cfg: Config): number {\n"
injected = needle + "  if (!cfg.data_dir.includes('tmp-selftest-')) {\n    writeBudget(cfg.data_dir, {})\n    return 0\n  }\n"
assert s.count(needle) == 1, "якорь не уникален: rebuildBudget"
open(p, 'w', encoding='utf-8').write(s.replace(needle, injected))
PY

set +e
out="$(BARRIER_ROOT="$R" "$BARRIER" 2>&1)"
rc=$?
set -e
[ "$rc" = "1" ] || die "красный прогон не 1: rc=$rc; вывод: $out"
printf '%s' "$out" | grep -qF "е: budget.json после rebuild ≠ свёртке журнала" \
  || die "красный прогон не назвал причину «е: budget.json после rebuild ≠ свёртке журнала»: $out"
exit 0
