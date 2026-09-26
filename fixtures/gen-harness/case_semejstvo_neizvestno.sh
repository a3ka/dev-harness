# ПРИЧИНА: неизвестное семейство «@drejf-net-takogo»
#
# ПРЕДМЕТ: тир реестра ссылается на семейство (`"@opus"`), которого нет в секции
# `models` (слово владельца 2026-09-26: версия живёт одной строкой в `models`). Опечатка
# в ссылке или удалённое семейство обязаны быть отказом с названной ссылкой, а не
# литералом `"@…"` в сгенерированном конфиге: omp принял бы его за имя модели и упал бы
# на первом вызове — причиной, похожей на ошибку провайдера.
#
# Подставное дерево — как в case_modelroles_drejf.sh.
set -euo pipefail

mkdir -p "$WORK/scripts" "$WORK/roles" "$WORK/config" "$WORK/.omp/agents"
cp "$REPO/scripts/roles.ts" "$WORK/scripts/"
cp "$REPO/scripts/gen-harness.ts" "$WORK/scripts/gen-harness.setup.ts"
cp -r "$REPO/roles/." "$WORK/roles/"
cp "$REPO/config/agent_models.json" "$WORK/config/"
cp "$REPO/.omp/config.yml" "$WORK/.omp/"

node "$WORK/scripts/gen-harness.setup.ts" > "$WORK/setup.out" 2>&1

# Положительный контроль: согласованное дерево — 0.
BARRIER_ROOT="$WORK" "$BARRIER" --check

# Порча: основная модель одного тира — ссылка на необъявленное семейство.
python3 - "$WORK/config/agent_models.json" <<'PY'
import json, sys
p = sys.argv[1]
d = json.load(open(p, encoding='utf-8'))
tier = next(iter(d['tiers']))
d['tiers'][tier]['model'] = '@drejf-net-takogo'
json.dump(d, open(p, 'w', encoding='utf-8'), ensure_ascii=False, indent=2)
PY

BARRIER_ROOT="$WORK" "$BARRIER" --check
