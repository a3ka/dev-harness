# ПРИЧИНА: явный scratch внутри стерегомого дерева
# Ветвь (scratchexpl): барьер ловит раннер, чтущий непустой VERIFY_ANTIPLACEBO_SCRATCH
# буквально — без канонизации и сравнения с корнем (находка 1 адверсария, круг 1 по
# контракту 011): явный скратч, разрешающийся ВНУТРИ стерегомого дерева, разводит по
# нему lock/run-каталоги/журналы ещё ДО чистки. Зелёный контроль — эталон: именованный
# отказ до создания (канонизация pwd -P спуском до существующего предка, сравнение по
# границе пути) оставляет дерево байт-в-байт чистым; вынос скратча наружу — равным
# образом честное лекарство, ветвь пинует чистоту дерева, а не код отказа. Дефект
# наблюдаем РЕКУРСИВНЫМ зондом ВО ВРЕМЯ прогона (Н-39): после выхода честный контроль
# не отличим от подметания.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" scratchexpl

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: чтит VERIFY_ANTIPLACEBO_SCRATCH буквально, без канонизации и отказа —
# как раннер до закрытия находки 1 адверсария (mkdir в стерегомом дереве)
set -uo pipefail
S="${VERIFY_ANTIPLACEBO_SCRATCH:-}"
[ -n "$S" ] || S="$(mktemp -d "${TMPDIR:-/tmp}/verify_antiplacebo.XXXXXX")"
mkdir -p "$S"
D="$S/run-$$"; mkdir -p "$D"; printf 'log\n' > "$D/log"
sleep 2
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" scratchexpl
