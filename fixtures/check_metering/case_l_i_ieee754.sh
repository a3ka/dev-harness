# ПРИЧИНА: int64 не сохранён
#
# Ветвь (л.i): барьер порождает ДВА случайных тарифа > 2^53, у которых точный
# usd (BigInt) непредставим в double. Красный — копия реального прокси, считающая
# стоимость числами с плавающей точкой: журнал несёт double-значение, точное
# теряется, и это ловится на любом из порождённых векторов.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$(make_repo)"
WORK_REPO="$R"

BARRIER_ROOT="$R" "$BARRIER" >/dev/null 2>&1 \
  || die "зелёный прогон не 0 — честный прокси не проходит ветвь (л.i)"

python3 - "$R/scripts/proxy/metering_proxy.ts" <<'PY'
import sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
old = ("  const ti = BigInt(tokensIn)\n"
       "  const to = BigInt(tokensOut)\n"
       "  return ceilDivBigInt(ti * inRateMicro + to * outRateMicro, 1_000_000n)")
new = ("  return BigInt(\n"
       "    Math.ceil((tokensIn * Number(inRateMicro) + tokensOut * Number(outRateMicro)) / 1e6),\n"
       "  )")
assert s.count(old) == 1, "якорь не уникален: computeUsd"
open(p, 'w', encoding='utf-8').write(s.replace(old, new))
PY

set +e
out="$(BARRIER_ROOT="$R" "$BARRIER" 2>&1)"
rc=$?
set -e
[ "$rc" = "1" ] || die "красный прогон не 1: rc=$rc; вывод: $out"
printf '%s' "$out" | grep -qF "int64 не сохранён" \
  || die "красный прогон не назвал причину «int64 не сохранён»: $out"
exit 0
