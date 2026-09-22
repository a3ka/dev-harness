#!/usr/bin/env bash
# Барьер CI-достижимости (контракт 040, критик contracts-040-v1, находка 4):
# §Инварианты п.8 требует ОБЕ новые красные фикстуры ПОСТОЯННЫМИ CI-стражами —
# это проверяется МЕХАНИЧЕСКИ здесь, а не только называется кандидатными
# npm-ключами в прозе §Зоны. Ключ ищется ПО ЗНАЧЕНИЮ (`bash <путь-фикстуры>`),
# не по имени: implementer сам выбирает точное имя ключа (§Зоны контракта),
# барьер не должен зависеть от этого выбора.
#
# rc 0 — обе пробы CI-достижимы (npm rc == прямой rc фикстуры для КАЖДОЙ; шаг
#        реально присутствует в .github/workflows/ci.yml — прямым run: ЛИБО
#        через shard `keys:` matrix; verify_ci_parity.sh зелёный);
# rc 1 — отказ с ИМЕНОВАННОЙ причиной (нашёл несоответствие);
# rc 2 — предмет ещё НЕ реализован (npm-ключ для одной/обеих фикстур
#        отсутствует в package.json) — ОЖИДАЕМОЕ состояние ДО работы
#        implementer'а; отличается от готовности КОДОМ возврата, не текстом.
#
#   bash fixtures/check_zones/probe_ci_dostizhimost_predelov.sh [<корень>]
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="${1:-$(cd "$HERE/../.." && pwd)}"
PKG="$ROOT/package.json"
CI="$ROOT/.github/workflows/ci.yml"
ZFIX="fixtures/check_zones/red_predel_git_vyzovov.sh"
PFIX="fixtures/check_protected/red_predel_git_vyzovov_ours.sh"

command -v python3 >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет python3\n' >&2; exit 2; }
[ -f "$PKG" ] || { printf 'NOT_IMPLEMENTED: нет %s\n' "$PKG" >&2; exit 2; }
[ -f "$ROOT/$ZFIX" ] || { printf 'NOT_IMPLEMENTED: нет %s\n' "$ROOT/$ZFIX" >&2; exit 2; }
[ -f "$ROOT/$PFIX" ] || { printf 'NOT_IMPLEMENTED: нет %s\n' "$ROOT/$PFIX" >&2; exit 2; }

fail() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }

find_key() {
  python3 - "$PKG" "$1" <<'PYEOF'
import json, sys
pkg, want = sys.argv[1], sys.argv[2]
scripts = json.load(open(pkg)).get("scripts", {})
target = "bash " + want
for k, v in scripts.items():
    if v.strip() == target:
        print(k)
        break
PYEOF
}

ZKEY="$(find_key "$ZFIX")"
PKEY="$(find_key "$PFIX")"
if [ -z "$ZKEY" ] || [ -z "$PKEY" ]; then
  printf 'NOT_IMPLEMENTED: package.json не несёт npm-ключ со значением "bash %s" и/или "bash %s" — implementer ещё не подключил (ожидаемо ДО реализации)\n' "$ZFIX" "$PFIX" >&2
  exit 2
fi

# 1. rc через npm совпадает с rc прямого вызова фикстуры (обе независимо).
( cd "$ROOT" && npm run --silent "$ZKEY" >/dev/null 2>&1 ); npm_z=$?
( cd "$ROOT" && bash "$ZFIX" >/dev/null 2>&1 ); direct_z=$?
[ "$npm_z" -eq "$direct_z" ] || fail "npm run $ZKEY (rc=$npm_z) != прямой bash $ZFIX (rc=$direct_z)"

( cd "$ROOT" && npm run --silent "$PKEY" >/dev/null 2>&1 ); npm_p=$?
( cd "$ROOT" && bash "$PFIX" >/dev/null 2>&1 ); direct_p=$?
[ "$npm_p" -eq "$direct_p" ] || fail "npm run $PKEY (rc=$npm_p) != прямой bash $PFIX (rc=$direct_p)"

# 2. оба ключа реально исполняются CI: прямой шаг `run: npm run <key>` ЛИБО
#    покрытие через shard `keys:` matrix (прецедент check_provodka/
#    done_contract/check_consumers в шарде ap2 — контракт 038).
[ -f "$CI" ] || fail "нет $CI — подключать некуда"
wired="$(python3 - "$CI" "$ZKEY" "$PKEY" <<'PYEOF'
import re, sys
ci_text = open(sys.argv[1], encoding="utf-8").read()
zkey, pkey = sys.argv[2], sys.argv[3]
def direct(key):
    return re.search(r'run:\s*npm run(?:-script)? ' + re.escape(key) + r'\b', ci_text) is not None
def base(key):
    return key.split(":", 1)[-1].replace("-", "_")
def matrixed(key):
    return re.search(r'keys:.*\b' + re.escape(base(key)) + r'\b', ci_text) is not None
zok = direct(zkey) or matrixed(zkey)
pok = direct(pkey) or matrixed(pkey)
print("1" if (zok and pok) else "0")
PYEOF
)"
[ "$wired" = "1" ] || fail "npm-ключи ($ZKEY, $PKEY) не найдены ни прямым шагом 'run: npm run <key>', ни через matrix 'keys:' в $CI"

# 3. verify_ci_parity.sh держится зелёным с новой проводкой — распознаёт её,
#    не молча пропускает через недостижимое исключение.
( cd "$ROOT" && bash scripts/verify_ci_parity.sh "$ROOT" >/dev/null 2>&1 ); parity_rc=$?
[ "$parity_rc" -eq 0 ] || fail "verify_ci_parity.sh rc=$parity_rc — новая CI-проводка не распознана паритетом"

printf 'CI-ДОСТИЖИМОСТЬ ДЕРЖИТСЯ: %s -> rc(npm)=%s=rc(прямой)=%s; %s -> rc(npm)=%s=rc(прямой)=%s; подключены в CI; verify_ci_parity rc=0\n' \
  "$ZKEY" "$npm_z" "$direct_z" "$PKEY" "$npm_p" "$direct_p" >&2
exit 0
