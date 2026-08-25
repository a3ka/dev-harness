# ПРИЧИНА: появились новые пути
# Ветвь (scratch): барьер ловит раннер, держащий scratch ВНУТРИ стерегомого дерева —
# как текущий раннер до 011 (Н-48-2: собственный лог ловится «дерево изменилось»;
# Н-48-5: base64-мусор в корне). Зелёный контроль — эталон (scratch в
# $VERIFY_ANTIPLACEBO_SCRATCH). Красное — обманка, пишущая в $1/tmp.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" scratch

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: run-каталоги ВНУТРИ стерегомого дерева (как раннер до 011)
D="$1/tmp/antiplacebo/run-$$"
mkdir -p "$D"; printf 'log\n' > "$D/log"
sleep 2
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" scratch
