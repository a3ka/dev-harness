# ПРИЧИНА: л.i: usd = «9007199254740992000»
#
# Ветвь (л.i): тариф СТРОКОЙ 9007199254740993 (> 2^53) и tokens_in=1e9 дают
# usd РОВНО 9007199254740993000; IEEE-754 дал бы 9007199254740992000.
# Красный — копия реального прокси, считающая стоимость числами с плавающей
# точкой: журнал несёт double-значение, точное теряется.
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
printf '%s' "$out" | grep -qF "л.i: usd = «9007199254740992000»" \
  || die "красный прогон не назвал причину «л.i: usd = «9007199254740992000»»: $out"
exit 0
