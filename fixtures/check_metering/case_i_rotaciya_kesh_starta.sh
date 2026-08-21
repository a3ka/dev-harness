# ПРИЧИНА: стартовый кэш карты токенов
#
# Ветвь (и): ротация в ОДНОМ живом процессе — T1 принят, файл секретов
# перезаписан (T1 удалён, T2 приписан той же роли), T2 обязан быть принят.
# Зелёный — реальный прокси, читающий карту на каждом запросе. Красный —
# копия реального прокси, строящая карту ОДИН раз (кэш): T2 неизвестен → 401.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$(make_repo)"
WORK_REPO="$R"

BARRIER_ROOT="$R" "$BARRIER" >/dev/null 2>&1 \
  || die "зелёный прогон не 0 — честный прокси не проходит ветвь (и)"

python3 - "$R/scripts/proxy/metering_proxy.ts" <<'PY'
import sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
old = "  const tokenMap = readTokenMap(cfg.secrets_env)"
new = "  const tokenMap = (globalThis as any).__tmap ??= readTokenMap(cfg.secrets_env)"
assert s.count(old) == 1, "якорь не уникален: " + old
open(p, 'w', encoding='utf-8').write(s.replace(old, new))
PY

set +e
out="$(BARRIER_ROOT="$R" "$BARRIER" 2>&1)"
rc=$?
set -e
[ "$rc" = "1" ] || die "красный прогон не 1: rc=$rc; вывод: $out"
printf '%s' "$out" | grep -qF "и: T2 не принят, status=401" \
  || die "красный прогон не назвал причину «и: T2 не принят»: $out"
exit 0
