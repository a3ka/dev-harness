# ПРИЧИНА: к2: child_process / внешние процессы в
#
# Ветвь (к2): builtins-only по ПРОЦЕССАМ. Честный прокси не порождает внешних
# процессов. Красный — копия прокси с мёртвой функцией, обращающейся к
# `process.binding` (легаси-канал к нативному spawn мимо child_process-литерала
# и exec/spawn-имён): старый барьер проверял только exec/spawn с первым
# строковым аргументом (находка адверсария 2026-08-21), новый ловит process.binding.
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
probe = ('\nfunction __neverK2(): void {\n'
         '  // легаси-канал к нативному spawn мимо child_process\n'
         '  const b = process.binding("spawn_sync")\n'
         '  void b\n'
         '}\n')
assert '__neverK2' not in s, "маркер уже есть"
open(p, 'w', encoding='utf-8').write(s + probe)
PY

set +e
out="$(BARRIER_ROOT="$R" "$BARRIER" 2>&1)"
rc=$?
set -e
[ "$rc" = "1" ] || die "красный прогон не 1: rc=$rc; вывод: $out"
printf '%s' "$out" | grep -qF "к2: child_process / внешние процессы в" \
  || die "красный прогон не назвал причину «к2: child_process / внешние процессы в»: $out"
exit 0
