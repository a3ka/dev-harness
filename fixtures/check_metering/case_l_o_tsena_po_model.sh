# ПРИЧИНА: л.о: usd P1=2400000, ожидался 1200000
#
# Ветвь (л.о): ДВА provider с ОДНОЙ model, цены РАЗНЫЕ — вызов P1 обязан
# списать по цене P1, вызов P2 — по P2. Красный — копия реального прокси,
# ищущая цену по model БЕЗ оси provider: оба вызова списываются по одному
# (последнему встреченному) тарифу → usd P1 расходится с ожидаемым.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$(make_repo)"
WORK_REPO="$R"

BARRIER_ROOT="$R" "$BARRIER" >/dev/null 2>&1 \
  || die "зелёный прогон не 0 — честный прокси не проходит ветвь (л.о)"

python3 - "$R/scripts/proxy/metering_proxy.ts" <<'PY'
import sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
old = "  const priceMap = cfg.prices[provider]"
new = ("  const priceMap = Object.values(cfg.prices).reduce(\n"
       "    (acc, m) => Object.assign(acc, m),\n"
       "    {} as Record<string, unknown>,\n"
       "  ) as typeof cfg.prices[string]")
assert s.count(old) == 1, "якорь не уникален: " + old
open(p, 'w', encoding='utf-8').write(s.replace(old, new))
PY

set +e
out="$(BARRIER_ROOT="$R" "$BARRIER" 2>&1)"
rc=$?
set -e
[ "$rc" = "1" ] || die "красный прогон не 1: rc=$rc; вывод: $out"
printf '%s' "$out" | grep -qF "л.о: usd P1=2400000, ожидался 1200000" \
  || die "красный прогон не назвал причину «л.о: usd P1=2400000, ожидался 1200000»: $out"
exit 0
