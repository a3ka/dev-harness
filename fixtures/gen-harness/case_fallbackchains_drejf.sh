# ПРИЧИНА: retry.fallbackChains в .omp/config.yml расходится с config/agent_models.json
#
# ПРЕДМЕТ: третья фаза барьера — живые цепочки подмены omp (`retry.fallbackChains`)
# обязаны совпадать с полями `fallback` + `autoFallback` реестра (единый источник, слово
# владельца 2026-09-26). До этой фазы секция правилась руками: смена opus-5 → 5-5
# потребовала ручной правки ровно здесь, и генератор её не видел — цепочка молча
# осталась бы на старой версии при обновлённом реестре.
#
# Порча — ровно такой дрейф: одна цепочка в конфиге называет не ту модель, что реестр.
# modelRoles не тронута, поэтому барьер, судящий только modelRoles, эту фикстуру
# проваливает «барьер остался зелёным».
#
# Подставное дерево — как в case_modelroles_drejf.sh: барьер вычисляет корень по своему
# пути, `scripts/roles.ts` копируется отдельно ради `import './roles.ts'`.
set -euo pipefail

mkdir -p "$WORK/scripts" "$WORK/roles" "$WORK/config" "$WORK/.omp/agents"
cp "$REPO/scripts/roles.ts" "$WORK/scripts/"
cp "$REPO/scripts/gen-harness.ts" "$WORK/scripts/gen-harness.setup.ts"
cp -r "$REPO/roles/." "$WORK/roles/"
cp "$REPO/config/agent_models.json" "$WORK/config/"
cp "$REPO/.omp/config.yml" "$WORK/.omp/"

# Зелёная основа приводится в согласие своей копией генератора (setup, не $BARRIER).
node "$WORK/scripts/gen-harness.setup.ts" > "$WORK/setup.out" 2>&1

# Положительный контроль: согласованное дерево — 0.
BARRIER_ROOT="$WORK" "$BARRIER" --check

# Порча: первая строка цепочки между маркерами называет чужую модель.
python3 - "$WORK/.omp/config.yml" <<'PY'
import re, sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
blk = re.search(r'  # ── fallbackChains:[\s\S]*?  # ── /fallbackChains ──', s)
if blk is None:
    sys.exit('фикстура: в конфиге нет маркеров fallbackChains')
new, n = re.subn(r'(\n {4}[a-z]+: \[")[^"]+("\])', r'\1vendor/drejf-probe-chain-1\2', blk.group(0), count=1)
if n != 1:
    sys.exit('фикстура: в секции fallbackChains нет ни одной цепочки')
open(p, 'w', encoding='utf-8').write(s[:blk.start()] + new + s[blk.end():])
PY

BARRIER_ROOT="$WORK" "$BARRIER" --check
