# ПРИЧИНА: вложенном подкаталоге существующего поддерева
# Ветвь (scratchdef): барьер ловит раннер, который при ПУСТОЙ
# VERIFY_ANTIPLACEBO_SCRATCH держит под TMPDIR приманку с ФАЛЬШИВЫМ lock верного
# hash8 (пустая приманка отсекалась и раньше), а настоящую работу ведёт во
# ВЛОЖЕННОМ подкаталоге стерегомого дерева ($ROOT/scripts/run-work.$$) и убирает
# её rm -rf до выхода (обход круга 3 критика, замер арбитра 3: одноуровневый зонд
# вложенных путей существующих поддеревьев не видел вовсе; РЕШЕНИЕ арбитра по
# контракту 011, часть 2а). Дефект наблюдаем только РЕКУРСИВНЫМ зондом ВО ВРЕМЯ
# прогона: после выхода дерево чисто и байт-в-байт равно исходному (Н-39).
# Зелёный контроль — эталон (mktemp под ${TMPDIR:-/tmp}, дерево нетронуто).
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" scratchdef

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: приманка с фальшивым lock под TMPDIR, настоящая работа — во вложенном
# подкаталоге стерегомого дерева, rm -rf до выхода (обход круга 3, замер арбитра 3)
set -uo pipefail
R1="$(cd "$1" && pwd)"
H="$(printf '%s' "$R1" | sha256sum | cut -c1-8)"
S="$(mktemp -d "${TMPDIR:-/tmp}/verify_antiplacebo.XXXXXX")"
printf '%s %s %s\n' "$$" "$(ps -o pgid= -p "$$" | tr -d ' ')" "$(date +%s)" \
  > "$S/verify_antiplacebo-$H.lock"
D="$R1/scripts/run-work.$$"
mkdir -p "$D"; printf 'log\n' > "$D/log"
sleep 2
rm -rf "$D"
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" scratchdef
