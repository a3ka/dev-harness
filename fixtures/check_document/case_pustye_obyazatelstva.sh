# ПРИЧИНА: required.sections пуст
# Барьер ловит предмет, который не различает «нет секций» от «нарушено покрытие» (silent pass по
# пустому required.sections). Зелёный — реальный предмет (sections непусты → rc=0). Красное —
# стаб, принимающий пустые sections без отказа.
set -euo pipefail

G="$WORK/green"; mkdir -p "$G/scripts" "$G/contracts" "$G/fixtures"
cp "$REPO/scripts/doc_contract.ts" "$G/scripts/doc_contract.ts"
chmod +x "$G/scripts/doc_contract.ts"
cat > "$G/contracts/001-yozh.md" <<'EOF'
# Договор

ЗОНА architect: contracts/ fixtures/

## Док-приёмка

```json
{
  "type": "documentation", "version": 1, "profile": "product",
  "outputs": {"markdown": "docs/x.md", "evidence": "docs/x.evidence.json"},
  "required": {"sections": ["Обзор-Ёж"], "scenarios": ["Сц"], "components": [], "links": [], "decisions": ["Р"], "failures": ["О"]},
  "assertions": [], "sources": [], "questions": [],
  "calibration": {"positive": "fixtures/p.json", "negative": [{"evidence": "fixtures/n.json", "violation": "coverage"}]}
}
```
EOF
echo '{}' > "$G/fixtures/p.json"
echo '{"sections": []}' > "$G/fixtures/n.json"
"$BARRIER" --root "$G" --contract contracts/001-yozh.md --preflight

R="$WORK/red"; mkdir -p "$R/scripts" "$R/contracts"
cat > "$R/scripts/doc_contract.ts" <<'EOF'
#!/usr/bin/env node
// стаб: не различает пустые sections.
import { readFileSync } from 'node:fs'
process.exit(0)
EOF
chmod +x "$R/scripts/doc_contract.ts"
cat > "$R/contracts/001-yozh.md" <<'EOF'
# Договор

ЗОНА architect: contracts/

## Док-приёмка

```json
{
  "type": "documentation", "version": 1, "profile": "product",
  "outputs": {"markdown": "docs/x.md", "evidence": "docs/x.evidence.json"},
  "required": {"sections": [], "scenarios": ["Сц"], "components": [], "links": [], "decisions": ["Р"], "failures": ["О"]},
  "assertions": [], "sources": [], "questions": []
}
```
EOF
"$BARRIER" --root "$R" --contract contracts/001-yozh.md --preflight || [ $? -eq 1 ]