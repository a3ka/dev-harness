# ПРИЧИНА: modelRoles в .omp/config.yml расходится с config/agent_models.json
#
# ПРЕДМЕТ: вторая фаза барьера — секция `modelRoles` в `.omp/config.yml` обязана
# совпадать с `config/agent_models.json` (единый источник назначений моделей,
# решение владельца 2026-09-12). Обе фикстуры рядом судят ТОЛЬКО первую фазу
# (agents/↔roles/), и фаза modelRoles жила без красного предъявления вовсе.
#
# КЛАСС ДЕФЕКТА, который ловится ЭТИМ входом (Н-110, измерено живьём): регекс замены
# секции собирался внутри JS template literal — `` `…[\s\S]*?…` `` — где `\s`/`\S`
# для ЯЗЫКА нераспознанные escape'ы: обратный слеш съедается при парсинге исходника,
# и в `new RegExp` уходит `[sS]*?` («буква s или S»). Такой класс не проходит
# многострочную секцию до закрывающего маркера, `replace()` молча возвращает исходную
# строку — запись не происходит НИКОГДА, а `--check` НИКОГДА не видит дрейфа. Гейт
# оставался зелёным на любом расхождении. Красное предъявление этого входа отличает
# честный барьер от такого: на подставном дереве с ЛИШНИМ тиром честный краснеет,
# барьер со съеденным слешем остаётся зелёным (проверено: старая редакция
# `scripts/gen-harness.ts` валит эту фикстуру «барьер остался зелёным»).
#
# Подставное дерево строится ЦЕЛИКОМ в $WORK: барьер вычисляет корень по своему пути
# (`import.meta.dirname/..`), и раннер кладёт его копию в `$WORK/scripts/` по
# BARRIER_ROOT. `scripts/roles.ts` копируется отдельно — байтовая копия одного
# `gen-harness.ts` потеряла бы `import './roles.ts'` (та же причина, что в
# case_agent_poterjan.sh).
set -euo pipefail

mkdir -p "$WORK/scripts" "$WORK/roles" "$WORK/config" "$WORK/.omp/agents"
cp "$REPO/scripts/roles.ts" "$WORK/scripts/"
cp "$REPO/scripts/gen-harness.ts" "$WORK/scripts/gen-harness.setup.ts"
cp -r "$REPO/roles/." "$WORK/roles/"
cp "$REPO/config/agent_models.json" "$WORK/config/"
cp "$REPO/.omp/config.yml" "$WORK/.omp/"

# Зелёная основа не берётся на веру из репозитория: подставное дерево приводится в
# согласие СВОЕЙ копией генератора (setup-вызов, НЕ через $BARRIER — предъявлением он
# не считается). Порождает и `.omp/agents/`, и секцию `modelRoles` — иначе
# положительный контроль зависел бы от состояния чужого файла. Провал setup виден
# раннеру как отсутствие положительного контроля: `set -e` роняет case, а зелёного
# вызова барьера в учёте не появляется.
node "$WORK/scripts/gen-harness.setup.ts" > "$WORK/setup.out" 2>&1

# Положительный контроль: согласованное дерево — 0.
BARRIER_ROOT="$WORK" "$BARRIER" --check

# Порча ровно в предмете: в реестре появляется тир, которого нет в секции конфига.
# Маркеры секции на месте — расхождение обязано быть НАЙДЕНО регексом между ними.
python3 - "$WORK/config/agent_models.json" <<'PY'
import json, sys
p = sys.argv[1]
d = json.load(open(p, encoding='utf-8'))
d['tiers']['drejf_probe'] = {'model': 'vendor/drejf-probe-1', 'fallback': None,
                             'why': 'порча фикстуры: тир есть в реестре и отсутствует в секции modelRoles'}
json.dump(d, open(p, 'w', encoding='utf-8'), ensure_ascii=False, indent=2)
PY

BARRIER_ROOT="$WORK" "$BARRIER" --check
