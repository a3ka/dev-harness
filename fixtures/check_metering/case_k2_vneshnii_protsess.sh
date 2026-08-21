# ПРИЧИНА: к2: child_process / внешние процессы в
#
# Ветвь (к2): builtins-only по ПРОЦЕССАМ — exec/spawn с первым аргументом
# вне «node». Красный — копия реального прокси ТОЛЬКО с внешним curl (без
# сторонних импортов: сам execSync приходит из node:child_process, к1
# остаётся зелёной). Вызов недостижим по окружению — поведение не меняется,
# дефект наблюдаем ровно на входе (к2).
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$(make_repo)"
WORK_REPO="$R"

BARRIER_ROOT="$R" "$BARRIER" >/dev/null 2>&1 \
  || die "зелёный прогон не 0 — честный прокси не проходит ветвь (к2)"

python3 - "$R/scripts/proxy/metering_proxy.ts" <<'PY'
import sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
probe = ('import { execSync } from "node:child_process";\n'
         'if (process.env.__probe_never === "1") execSync("curl", ["--version"]);\n')
assert '__probe_never' not in s, "маркер уже есть"
open(p, 'w', encoding='utf-8').write(s + "\n" + probe)
PY

set +e
out="$(BARRIER_ROOT="$R" "$BARRIER" 2>&1)"
rc=$?
set -e
[ "$rc" = "1" ] || die "красный прогон не 1: rc=$rc; вывод: $out"
printf '%s' "$out" | grep -qF "к2: child_process / внешние процессы в" \
  || die "красный прогон не назвал причину «к2: child_process / внешние процессы в»: $out"
exit 0
