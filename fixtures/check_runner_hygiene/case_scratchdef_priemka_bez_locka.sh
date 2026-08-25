# ПРИЧИНА: каталог-приманка
# Ветвь (scratchdef): барьер ловит приманку, НЕ СВЯЗАННУЮ с работой раннера —
# под TMPDIR появляется пустой каталог, но в нём никогда не возникает
# пиннованный lock «verify_antiplacebo-<hash8>.lock» этого дерева (обход круга 2
# критика: ветвь замечала любое дитя TMPDIR, не связывая найденный путь с
# фактическим скратчем). Зелёный контроль — эталон (lock живёт в скратче).
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" scratchdef

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: пустая приманка под TMPDIR без lock и без работы (обход круга 2)
set -uo pipefail
R1="$(cd "$1" && pwd)"
mkdir -p "${TMPDIR:-/tmp}/priemanka.$$"
sleep 2
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" scratchdef
