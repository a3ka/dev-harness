# ПРИЧИНА: импорты вне node:
#
# Ветвь (к1): builtins-only по ИМПОРТАМ — grep импортов исходника прокси вне
# `node:`. Красный — копия реального прокси ТОЛЬКО с vendor-импортом (без
# внешних процессов, к2 остаётся зелёной). Импорт type-only: стирается при
# исполнении, поведение не меняется — дефект наблюдаем ровно на входе (к1).
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$(make_repo)"
WORK_REPO="$R"

BARRIER_ROOT="$R" "$BARRIER" >/dev/null 2>&1 \
  || die "зелёный прогон не 0 — честный прокси не проходит ветвь (к1)"

python3 - "$R/scripts/proxy/metering_proxy.ts" <<'PY'
import sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
marker = 'import type __vendorProbe from "lodash";'
assert marker not in s, "маркер уже есть"
open(p, 'w', encoding='utf-8').write(s + "\n" + marker + "\n")
PY

set +e
out="$(BARRIER_ROOT="$R" "$BARRIER" 2>&1)"
rc=$?
set -e
[ "$rc" = "1" ] || die "красный прогон не 1: rc=$rc; вывод: $out"
printf '%s' "$out" | grep -qF "к1: импорты вне node:" \
  || die "красный прогон не назвал причину «к1: импорты вне node:»: $out"
exit 0
