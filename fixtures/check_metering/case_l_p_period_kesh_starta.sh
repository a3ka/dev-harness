# ПРИЧИНА: период не перечитан
#
# Ветвь (л.п): ОДИН живой процесс, два вызова по РАЗНЫЕ стороны границы
# UTC-месяца (инъекция now_file); январь с исчерпанным потолком даёт 402,
# февраль обязан пройти 200. Красный — копия реального прокси, кэширующая
# время первого запроса: февральский вызов видит январский период → 402.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$(make_repo)"
WORK_REPO="$R"

BARRIER_ROOT="$R" "$BARRIER" >/dev/null 2>&1 \
  || die "зелёный прогон не 0 — честный прокси не проходит ветвь (л.п)"

python3 - "$R/scripts/proxy/metering_proxy.ts" <<'PY'
import sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
old = "  const nowMs = readNowMs(cfg)"
new = "  const nowMs = (globalThis as any).__now ??= readNowMs(cfg)"
assert s.count(old) == 1, "якорь не уникален: " + old
open(p, 'w', encoding='utf-8').write(s.replace(old, new))
PY

set +e
out="$(BARRIER_ROOT="$R" "$BARRIER" 2>&1)"
rc=$?
set -e
[ "$rc" = "1" ] || die "красный прогон не 1: rc=$rc; вывод: $out"
printf '%s' "$out" | grep -qF "л.п: второй вызов в 2026-02 не прошёл" \
  || die "красный прогон не назвал причину «л.п: второй вызов в 2026-02 не прошёл»: $out"
exit 0
