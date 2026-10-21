#!/usr/bin/env bash
# Контракт 119 — МОДЕЛЬ честного аддитивного импорта 3.15 в мини-мир
# (предмет implementer — тот же план на живом Complior-back; модель доказывает
# удовлетворимость ожиданий батареи). Шаги зеркалят §1.4/§6.1 отчёта:
#   core = побайтовая копия НАШЕГО published 5.8.4 (не бандл!); extension и
#   new-consumers — из бандла; активный baseline-lock перезапинен на 5.8.4,
#   исходный lock бандла уходит в provenance/; история 3.14 = наш снапшот;
#   единый генератор (с --check) пишет published/bindings/manifest/FILES;
#   structure-policy узнаёт tests/spec-3.15/; everything коммитится.
set -euo pipefail
W="$1"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
BUNDLE="$HERE/toy_bundle315"
cd "$W"
PUB=docs/contracts/BrokerOS_Unified_OpenAPI_v3.yaml
SRC=docs/sources/backend-3.15

mkdir -p "$SRC/provenance" docs/history/3_14 tests/spec-3.15 docs/plans docs/data

# провенанс нашего 5.8.4 (истина для сверки истории и ядра)
printf '%s  %s\n' "$(sha256sum "$PUB" | cut -d' ' -f1)" "docs/contracts/BrokerOS_Unified_OpenAPI_v3.yaml@base" \
  > "$SRC/provenance/nasha_5_8_4.sha256"

# ядро = побайтовая копия нашего published; extension — из бандла
cp "$PUB" "$SRC/core.openapi.yaml"
cp "$BUNDLE/sources/platform-extension.yaml" "$SRC/platform-extension.yaml"
cp "$BUNDLE/contracts/frontend-consumer-bindings.json" "$SRC/new-consumers.json"

# заявленные счёты считаются по факту (не из прозы)
NEW_OPS="$(grep -c 'operationId:' "$SRC/platform-extension.yaml")"
NEW_CON="$(jq '.new_operation_consumers | length' "$SRC/new-consumers.json")"
OWNERS="$(jq '.tables | length' "$BUNDLE/data/physical-model.json")"
printf '{"new_ops":%s,"new_consumers":%s,"owners":%s}\n' "$NEW_OPS" "$NEW_CON" "$OWNERS" \
  > "$SRC/declared-counts.json"

# активный lock — 5.8.4; исходный lock бандла — история происхождения
printf '{"compatibility_baseline":"5.8.4","provenance":"rebased: bundle 3.15 extension поверх нашей 5.8.4"}\n' \
  > "$SRC/baseline-lock.json"
cp "$BUNDLE/sources/baseline-lock.json" "$SRC/provenance/bundle-baseline-lock.json"
cp "$BUNDLE/KNOWN-ISSUES-DECLARED.json" "$SRC/provenance/KNOWN-ISSUES-DECLARED.json"
cp "$BUNDLE/VERSION_MANIFEST.json" "$SRC/provenance/bundle-VERSION_MANIFEST.json"
cp "$BUNDLE/README_RU.md" "$SRC/provenance/README_RU.md"

# история 3.14 — наш снапшот (не бандл 5.8.2)
cp "$PUB" docs/history/3_14/BrokerOS_Unified_OpenAPI_v3.yaml
cp docs/VERSION_MANIFEST.json docs/history/3_14/VERSION_MANIFEST.json

# данные и план
cp "$BUNDLE/data/physical-model.json" docs/data/physical-model.json
cp "$BUNDLE/plans/delivery-plan.json" docs/plans/delivery-plan-3.15.json

# единый генератор (с --check) и валидатор spec-3.15
cp "$HERE/gen_derived_315.py" tests/tools/generate_derived.py
cp "$HERE/validate_import_315.py" tests/spec-3.15/validate_import_315.py
# v2 (R-1): spec-3.14 мигрирован на смешанные профили; v2 (R-2): производные
# app/schemas пересобирает gen-contracts.js (не руками)
cp "$HERE/validate_spec314_315.py" tests/spec-3.14/validate_contract_v3_9.py
cp "$HERE/gen_contracts_315.js" tests/tools/gen-contracts.js
jq '{ids}' "$SRC/provenance/KNOWN-ISSUES-DECLARED.json" > tests/spec-3.15/known-issues-315.json
mkdir -p app/schemas
python3 - <<'PY'
import json
p = 'structure-policy.json'
d = json.load(open(p))
d['tests/spec-3.15/'] = 'пакетные проверки импорта 3.15 (валидатор, known-issues)'
json.dump(d, open(p, 'w'), ensure_ascii=False, indent=2)
PY

# генерация: published/bindings/manifest; затем производные app/schemas из
# СМЕЖЕННОГО published; затем ПОВТОРНАЯ генерация — FILES.sha256 последним,
# теперь с app/schemas в инвентаре (повтор схождения заодно доказывает
# детерминизм писателя)
python3 tests/tools/generate_derived.py
node tests/tools/gen-contracts.js
python3 tests/tools/generate_derived.py

git add -A
git -c user.name=model315 -c user.email=model@dev-harness.local commit -qm "import 3.15: additive merge (model)"
