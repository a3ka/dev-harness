#!/usr/bin/env bash
# ПРИЧИНА: формальный фрагмент не соответствует
# Барьер ловит renderer, который на --check ПРИНИМАЕТ manual-искажение формального фрагмента
# — реальный checker --check краснит rc=1 с substring «формальный фрагмент не соответствует»
# (сравнение ручного и пересчитанного). Зелёный контроль — реальный renderer --check на
# конформной паре (rc=0). Красное — тот же checker --check на паре с manual-искажением
# формального фрагмента.
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

# Без --check фрагмент пересчитан и записан; --check на нём даёт rc=0.
"$BARRIER" --root "$G" --contract contracts/001-yozh.md --check

R="$WORK/red"; mkdir -p "$R/scripts" "$R/contracts" "$R/docs" "$R/данные"
cp "$REPO/scripts/doc_contract.ts" "$R/scripts/doc_contract.ts"
chmod +x "$R/scripts/doc_contract.ts"
cp "$G/contracts/001-yozh.md" "$R/contracts/001-yozh.md"
cp "$G/docs/ёж.evidence.json" "$R/docs/ёж.evidence.json"
cp "$G/docs/ёж.md" "$R/docs/ёж.md"
# Подменить формальный фрагмент ручным мусором, чтобы --check расходился:
node -e 'const fs=require("fs"); const p=process.argv[1]; const t=fs.readFileSync(p,"utf-8"); const body="\nподделка-Ёж\n"; const out=t.replace(/<!-- doc:formal:start -->([\s\S]*?)<!-- doc:formal:end -->/, "<!-- doc:formal:start -->"+body+"<!-- doc:formal:end -->"); fs.writeFileSync(p, out);' "$R/docs/ёж.md"
"$BARRIER" --root "$R" --contract contracts/001-yozh.md --check
