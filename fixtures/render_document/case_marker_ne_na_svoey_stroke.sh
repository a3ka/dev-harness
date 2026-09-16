# ПРИЧИНА: manual-правка формального фрагмента не отвергнута --check
# Барьер ловит renderer, который на --check принимает ручное искажение формального фрагмента
# без отказа (позволяет редактору «набирать факты вторым исходником»). Зелёный — реальный
# renderer: --check расходится с пересчётом → rc=1. Красное — стаб, --check всегда rc=0.
set -euo pipefail

G="$WORK/green"; mkdir -p "$G/scripts" "$G/contracts" "$G/fixtures" "$G/docs"
cp "$REPO/scripts/doc_contract.ts" "$G/scripts/doc_contract.ts"
chmod +x "$G/scripts/doc_contract.ts"
cat > "$G/contracts/001-yozh.md" <<'EOF'
# Договор

ЗОНА architect: contracts/ fixtures/

## Док-приёмка

```json
{
  "type": "documentation", "version": 1, "profile": "product",
  "outputs": {"markdown": "docs/ёж.md", "evidence": "docs/ёж.evidence.json"},
  "required": {"sections": ["Обзор-Ёж"], "scenarios": ["Сц"], "components": [], "links": [], "decisions": ["Р"], "failures": ["О"]},
  "assertions": [{"id": "Факт-Ёж", "status": "as-is", "kind": "observation", "evidence": "Основание-ёж",
                  "check": {"type": "json-pointer", "source": "Источник-ёж", "pointer": "/число", "expected": 7}}],
  "sources": [{"id": "Источник-ёж", "kind": "git", "path": "данные/ёлка.json",
               "commit": "deadbeef", "blob": "deadbeef", "freshness": "historical"}],
  "questions": []
}
```
EOF
echo '{"sections":[{"id":"Обзор-Ёж"}]}' > "$G/docs/ёж.evidence.json"
cat > "$G/docs/ёж.md" <<'EOF'
# Ёж

<!-- doc:section Обзор-Ёж -->
Объяснение.

<!-- doc:formal:start -->
подделка Ёж
<!-- doc:formal:end -->
EOF
mkdir -p "$G/данные"
echo '{"число":7}' > "$G/данные/ёлка.json"
"$BARRIER" --root "$G" --contract contracts/001-yozh.md --check

R="$WORK/red"; mkdir -p "$R/scripts" "$R/contracts" "$R/fixtures" "$R/docs"
cat > "$R/scripts/doc_contract.ts" <<'EOF'
#!/usr/bin/env node
// стаб: --check всегда rc=0, не сверяет формальный фрагмент.
process.exit(0)
EOF
chmod +x "$R/scripts/doc_contract.ts"
cp "$G/contracts/001-yozh.md" "$R/contracts/001-yozh.md"
cp "$G/docs/ёж.evidence.json" "$R/docs/"
cp "$G/docs/ёж.md" "$R/docs/"
"$BARRIER" --root "$R" --contract contracts/001-yozh.md --check || [ $? -eq 1 ]