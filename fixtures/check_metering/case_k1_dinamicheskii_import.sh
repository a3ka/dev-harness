# ПРИЧИНА: к1: загрузка модулей вне статического node:-import
#
# Ветвь (к1): builtins-only по ЗАГРУЗКЕ модулей. Честный прокси грузит только
# статическим `import ... from 'node:...'`. Красный — копия прокси с мёртвой
# функцией, содержащей ДИНАМИЧЕСКИЙ `import(...)`: литерал-grep старого барьера
# его не видел (находка адверсария 2026-08-21), новый ловит форму `import(`.
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
probe = '\nasync function __neverK1(): Promise<unknown> {\n  return import("node:" + "os")\n}\n'
assert '__neverK1' not in s, "маркер уже есть"
open(p, 'w', encoding='utf-8').write(s + probe)
PY

set +e
out="$(BARRIER_ROOT="$R" "$BARRIER" 2>&1)"
rc=$?
set -e
[ "$rc" = "1" ] || die "красный прогон не 1: rc=$rc; вывод: $out"
printf '%s' "$out" | grep -qF "к1: загрузка модулей вне статического node:-import" \
  || die "красный прогон не назвал причину «к1: загрузка модулей вне статического node:-import»: $out"
exit 0
