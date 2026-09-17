#!/usr/bin/env bash
# ПРИЧИНА: ID вне грамматики
# Барьер ловит предмет, который ПРИНИМАЕТ spec с ID вне грамматики (точка в ID: `Foo.bar`)
# — реальный checker краснит rc=1 с substring «ID вне грамматики» (validateSpecSchema).
# Зелёный контроль — реальный предмет против конформного spec (--preflight rc=0).
# Красное — тот же checker против неконформного spec с ID `Foo.bar`.
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
               "commit": "deadbeefdeadbeefdeadbeefdeadbeefdeadbeef", "blob": "deadbeefdeadbeefdeadbeefdeadbeefdeadbeef", "freshness": "historical"}],
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
  "failures": [{"id": "О"}],
  "assertions": [{"id": "Факт-Ёж", "status": "as-is", "kind": "observation", "value": 7, "evidence": "Основание-ёж"}],
  "evidence": [{"id": "Основание-ёж", "assertion": "Факт-Ёж", "kind": "observation", "source": "Источник-ёж"}]
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

R="$WORK/red"; mkdir -p "$R/scripts" "$R/contracts"
cp "$REPO/scripts/doc_contract.ts" "$R/scripts/doc_contract.ts"
chmod +x "$R/scripts/doc_contract.ts"
cat > "$R/contracts/001-yozh.md" <<'EOF'
# Договор

ЗОНА architect: contracts/

## Док-приёмка

```json
{
  "type": "documentation", "version": 1, "profile": "product",
  "outputs": {"markdown": "docs/ёж.md", "evidence": "docs/ёж.evidence.json"},
  "required": {"sections": ["Foo.bar"], "scenarios": ["Сц"], "components": [], "links": [], "decisions": ["Р"], "failures": ["О"]}
}
```
EOF
"$BARRIER" --root "$R" --contract contracts/001-yozh.md --preflight
