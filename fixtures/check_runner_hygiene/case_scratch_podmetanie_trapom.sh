# ПРИЧИНА: появились новые пути
# Ветвь (scratch): барьер ловит раннер, который пишет в дерево, но ПОДМЕТает за собой
# trap'ом — после прогона дерево чистое, и слепок «до/после» обманку не различает.
# Различает только ЗОНД ВО ВРЕМЯ прогона: дефект (параллельные снапшоты видят чужой
# tmp, Н-48-3) живёт именно во время прогона (Н-39: стаб подан на вход, где его
# дефект наблюдаем). Зелёный контроль — эталон.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" scratch

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: пишет В дерево, подметает trap'ом — во время прогона дерево грязное
D="$1/tmp/antiplacebo/run-$$"
mkdir -p "$D"; printf 'log\n' > "$D/log"
trap 'rm -rf "$1/tmp"' EXIT
sleep 2
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" scratch
