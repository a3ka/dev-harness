#!/usr/bin/env bash
# ПРИЧИНА: формальные границы отсутствуют
# Барьер ловит renderer, который ПРИНИМАЕТ markdown с дублированными формальными границами
# — реальный checker краснит rc=1 с substring «формальные границы отсутствуют»
# (splitFormalRegion: starts.length !== 1). Зелёный контроль — реальный renderer на
# markdown с одной парой границ (rc=0, формальный фрагмент пересчитан). Красное — тот же
# renderer на markdown с дублированным <!-- doc:formal:start -->.
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts" "$G/contracts" "$G/fixtures" "$G/docs" "$G/данные"
cp "$REPO/scripts/doc_contract.ts" "$G/scripts/doc_contract.ts"
chmod +x "$G/scripts/doc_contract.ts"
cat > "$G/contracts/001-yozh.md" <<'EOF'
# Договор

ЗОНА architect: contracts/ fixtures/

## Док-приёмка

```json
{
  "type": "documentation",
  "version": 1,
  "profile": "product",
  "outputs": {"markdown": "docs/ёж.md", "evidence": "docs/ёж.evidence.json"},
  "required": {"sections": ["Обзор-Ёж"], "scenarios": ["Сц"], "components": [], "links": [], "decisions": ["Р"], "failures": ["О"]},
  "assertions": [{"id": "Факт-Ёж", "status": "as-is", "kind": "observation", "evidence": "Основание-ёж",
                  "check": {"type": "json-pointer", "source": "Источник-ёж", "pointer": "/число", "expected": 7}}],
  "sources": [{"id": "Источник-ёж", "kind": "git", "path": "данные/ёлка.json",
               "commit": "deadbeef", "blob": "deadbeef", "freshness": "historical"}],
  "questions": [],
  "calibration": {"positive": "fixtures/p.json", "negative": [{"evidence": "fixtures/n.json", "violation": "coverage"}]}
}
```
EOF
cat > "$G/docs/ёж.evidence.json" <<'EOF'
{
  "sections": [{"id": "Обзор-Ёж"}],
  "scenarios": [{"id": "Сц", "actor": "User", "input": "число",
                 "outcomes": [{"id": "У", "kind": "success"}, {"id": "О", "kind": "failure"}]}],
  "decisions": [{"id": "Р"}],
  "failures": [{"id": "О"}]
}
EOF
cat > "$G/docs/ёж.md" <<'EOF'
# Ёж

<!-- doc:section Обзор-Ёж -->
Объяснение.

<!-- doc:formal:start -->
<!-- doc:formal:end -->
EOF
mkdir -p "$G/данные"
echo '{"число":7}' > "$G/данные/ёлка.json"
cp "$G/docs/ёж.evidence.json" "$G/fixtures/p.json"
echo '{"sections": []}' > "$G/fixtures/n.json"
"$BARRIER" --root "$G" --contract contracts/001-yozh.md --preflight

# Зелёный прогон без --check: фрагмент пересчитан и записан, rc=0.
"$BARRIER" --root "$G" --contract contracts/001-yozh.md

R="$WORK/red"; mkdir -p "$R/scripts" "$R/contracts" "$R/docs" "$R/данные"
cp "$REPO/scripts/doc_contract.ts" "$R/scripts/doc_contract.ts"
chmod +x "$R/scripts/doc_contract.ts"
cp "$G/contracts/001-yozh.md" "$R/contracts/001-yozh.md"
cp "$G/docs/ёж.evidence.json" "$R/docs/ёж.evidence.json"
cat > "$R/docs/ёж.md" <<'EOF'
# Ёж

<!-- doc:section Обзор-Ёж -->
Объяснение.

<!-- doc:formal:start -->
<!-- doc:formal:start -->
подделка
<!-- doc:formal:end -->
EOF
mkdir -p "$R/данные"
echo '{"число":7}' > "$R/данные/ёлка.json"
"$BARRIER" --root "$R" --contract contracts/001-yozh.md
