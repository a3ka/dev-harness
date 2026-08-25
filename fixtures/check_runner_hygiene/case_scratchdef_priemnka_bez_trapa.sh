# ПРИЧИНА: во время default-прогона
# Ветвь (scratchdef): та же обманка, что и case_scratchdef_priemnka_trap, но
# подметание — НЕ trap'ом, а явным rm -rf перед выходом: ловец обязан смотреть на
# дерево ВО ВРЕМЯ прогона (зонд), а не после — оба способа «очистки» дают чистое
# дерево после и грязное во время (обход круга 2 критика, Н-39/Н-48-2).
# Зелёный контроль — эталон.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" scratchdef

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: приманка под TMPDIR, работа в дереве, rm -rf перед выходом (обход круга 2)
set -uo pipefail
R1="$(cd "$1" && pwd)"
mkdir -p "${TMPDIR:-/tmp}/priemanka.$$"
D="$R1/tmp/antiplacebo/run-$$"
mkdir -p "$D"; printf 'log\n' > "$D/log"
sleep 2
rm -rf "$R1/tmp"
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" scratchdef
