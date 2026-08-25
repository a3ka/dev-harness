# ПРИЧИНА: во время default-прогона
# Ветвь (scratchdef): барьер ловит раннер, который при ПУСТОЙ
# VERIFY_ANTIPLACEBO_SCRATCH создаёт под TMPDIR пустой каталог-приманку, а работу
# ведёт В стерегомом дереве и ПОДМЕТАЕТ trap'ом до выхода (обход круга 2 критика:
# дерево осматривалось только ПОСЛЕ прогона — «чисто после» не доказывает «чисто
# во время»; дефект наблюдаем только пока прогон жив, Н-39).
# Зелёный контроль — эталон (mktemp под ${TMPDIR:-/tmp}, дерево нетронуто).
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" scratchdef

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: приманка под TMPDIR, работа в дереве, подметание trap'ом (обход круга 2)
set -uo pipefail
R1="$(cd "$1" && pwd)"
mkdir -p "${TMPDIR:-/tmp}/priemanka.$$"
D="$R1/tmp/antiplacebo/run-$$"
mkdir -p "$D"; printf 'log\n' > "$D/log"
trap 'rm -rf "$R1/tmp"' EXIT
sleep 2
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" scratchdef
