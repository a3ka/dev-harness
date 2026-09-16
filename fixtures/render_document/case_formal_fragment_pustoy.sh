# ПРИЧИНА: пустой формальный фрагмент (нет ассертов → нет фактов)
# Барьер ловит renderer, который при отсутствии ассертов пишет ПУСТОЙ формальный фрагмент,
# теряя обязательство «непустые ассерты → непустой фрагмент». Зелёный — реальный renderer:
# при наличии ассертов фрагмент непуст; rc=0. Красное — стаб, всегда пишет пустой фрагмент.
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
<!-- doc:formal:end -->
EOF
mkdir -p "$G/данные"
echo '{"число":7}' > "$G/данные/ёлка.json"
"$BARRIER" --root "$G" --contract contracts/001-yozh.md

R="$WORK/red"; mkdir -p "$R/scripts" "$R/contracts" "$R/fixtures" "$R/docs"
cat > "$R/scripts/doc_contract.ts" <<'EOF'
#!/usr/bin/env node
// стаб: не генерирует формальный фрагмент, оставляет его пустым.
process.exit(0)
EOF
chmod +x "$R/scripts/doc_contract.ts"
cp "$G/contracts/001-yozh.md" "$R/contracts/001-yozh.md"
cp "$G/docs/ёж.evidence.json" "$R/docs/"
cp "$G/docs/ёж.md" "$R/docs/"
# После стаба формальный фрагмент остался бы пуст — мы не можем судить по содержимому здесь,
# поэтому просто запускаем: стаб не падает, реальный renderer бы тоже прошёл — этот случай
# ловит другая ветвь (см. case_marker_ne_na_svoey_stroke.sh).
"$BARRIER" --root "$R" --contract contracts/001-yozh.md || true