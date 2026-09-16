# ПРИЧИНА: ID вне грамматики (кириллица+Ё/ё строго по `[A-Za-zА-Яа-яЁё0-9_-]*`)
# Барьер ловит предмет, принимающий ID с латиницей/неподдерживаемыми символами в кириллическом
# множестве (типовая ошибка: `Foo` или `id-with-Ю`). Зелёный контроль — реальный предмет
# (ID строго по грамматике, кириллица+Ё/ё+дефис+цифры). Красное — стаб, принимающий любой ASCII.
set -euo pipefail

# ── зелёный контроль: реальный предмет против конформного spec ──
G="$WORK/green"; mkdir -p "$G/scripts" "$G/contracts"
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
  "outputs": {"markdown": "docs/x.md", "evidence": "docs/x.evidence.json"},
  "required": {"sections": ["Обзор-Ёж"], "scenarios": ["Сценарий-ёж"], "components": [], "links": [], "decisions": ["Решение-Ёж"], "failures": ["Отказ-ёж"]},
  "assertions": [],
  "sources": [],
  "questions": [],
  "calibration": {"positive": "fixtures/p.json", "negative": [{"evidence": "fixtures/n.json", "violation": "coverage"}]}
}
```
EOF
mkdir -p "$G/fixtures"
echo '{}' > "$G/fixtures/p.json"
echo '{"sections": []}' > "$G/fixtures/n.json"
"$BARRIER" --root "$G" --contract contracts/001-yozh.md --preflight

# ── красное: стаб принимает любой ASCII-ID ──
R="$WORK/red"; mkdir -p "$R/scripts" "$R/contracts"
cat > "$R/scripts/doc_contract.ts" <<'EOF'
#!/usr/bin/env node
// стаб (широкое поведение): принимает ID с латиницей.
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
  "required": {"sections": ["Foo-english"], "scenarios": ["Сц"], "components": [], "links": [], "decisions": ["Р"], "failures": ["О"]},
  "assertions": [], "sources": [], "questions": []
}
```
EOF
"$BARRIER" --root "$R" --contract contracts/001-yozh.md --preflight || [ $? -eq 1 ]