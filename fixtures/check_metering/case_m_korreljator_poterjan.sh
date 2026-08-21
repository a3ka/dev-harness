# ПРИЧИНА: м: в строке журнала request_id «», ожидался
#
# Ветвь (м): значение заголовка x-request-id обязано попасть в строку
# журнала ДОСЛОВНО (коррелятор). Красный — копия реального прокси, пишущая
# в журнал пустой request_id: upstream получает заголовок честно (проба
# канала), но строка журнала коррелятора не несёт.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$(make_repo)"
WORK_REPO="$R"

BARRIER_ROOT="$R" "$BARRIER" >/dev/null 2>&1 \
  || die "зелёный прогон не 0 — честный прокси не проходит ветвь (м)"

python3 - "$R/scripts/proxy/metering_proxy.ts" <<'PY'
import sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
old = "  const requestId = typeof ridHeader === 'string' ? ridHeader : ''"
new = "  const requestId = ''"
assert s.count(old) == 1, "якорь не уникален: requestId"
open(p, 'w', encoding='utf-8').write(s.replace(old, new))
PY

set +e
out="$(BARRIER_ROOT="$R" "$BARRIER" 2>&1)"
rc=$?
set -e
[ "$rc" = "1" ] || die "красный прогон не 1: rc=$rc; вывод: $out"
printf '%s' "$out" | grep -qF "м: в строке журнала request_id «», ожидался" \
  || die "красный прогон не назвал причину «м: в строке журнала request_id «», ожидался»: $out"
exit 0
