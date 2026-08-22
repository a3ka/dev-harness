# ПРИЧИНА: HOME течёт
# Ветвь (изол): §4 требует per-fixture изоляцию HOME. Барьер строит home-leak-игрушку, где b
# краснеет ТОЛЬКО при протёкшем из HOME фикстуры a маркере. Корректный раннер (HOME per-fixture)
# → b не краснеет → «красное не предъявлено» → игрушка отвергнута (RC≠0): зелёный контроль на
# _ref_va (изолирует). Красное — раннер, ЗЕЛЕНЯЩИЙ leak-игрушку (RC=0 — так ведёт себя раннер с
# ОБЩИМ HOME: b краснеет на утечке, значит «всё предъявлено красным»): барьер ловит «HOME течёт».
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cp "$(dirname "$0")/_ref_va.sh" "$G/scripts/verify_antiplacebo.sh"; chmod +x "$G/scripts/verify_antiplacebo.sh"
"$BARRIER" "$G" изол

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: зеленит leak-игрушку (RC=0), как раннер с общим HOME (b краснеет на утечке → «всё красное»).
echo "барьеров: 2 · фикстур: 2 · предъявлено красным повторным прогоном: 2"
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" изол
