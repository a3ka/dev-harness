# ПРИЧИНА: не появился скратч
# Ветвь (scratchdef): барьер ловит раннер, который при ЯВНОЙ
# VERIFY_ANTIPLACEBO_SCRATCH пишет туда, а при ПУСТОЙ заводит ./tmp внутри дерева —
# обход круга 1 критика: «оставить при пустой переменной нынешний in-tree ./tmp».
# Зелёный контроль — эталон (mktemp -d под ${TMPDIR:-/tmp}). Красное — обманка с
# пустой переменной, пишущей в $1/tmp и не создающей ничего под TMPDIR.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" scratchdef

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: явная переменная уважается, пустая — скратч в дереве (обход круга 1)
set -uo pipefail
R1="$(cd "$1" && pwd)"
S="${VERIFY_ANTIPLACEBO_SCRATCH:-}"
if [ -n "$S" ]; then
  D="$S/run-$$"
else
  D="$R1/tmp/antiplacebo/run-$$"
fi
mkdir -p "$D"; printf 'log\n' > "$D/log"
sleep 3
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" scratchdef
