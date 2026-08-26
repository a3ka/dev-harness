# ПРИЧИНА: удалила существовавший до прогона default-скратч
# Ветвь (techka), райдер (ii) контракта 012, круг 1 критика: обманка повторяет
# дефект, который до правки нёс сам эталон — при пустой VERIFY_ANTIPLACEBO_SCRATCH
# признак владения ставится БЕЗУСЛОВНО, и EXIT делает rm -rf по детерминированному
# default-скратчу, СУЩЕСТВОВАВШЕМУ до прогона: чужой preexisting-файл удалён при
# rc=0, новых путей не остаётся — удаление заметно только маркером в самом
# скратче. Зелёный контроль — эталон (существовавший каталог не наш: не удаляем,
# безымянного не метём; убираем только свои lock и run-<pid>). Красное — обманка:
# чужой скратч исчез целиком.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" techka

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: существовавший default-скратч удаляется как свой (райдер (ii), круг 1)
set -uo pipefail
R1="$(cd "$1" && pwd)"
S="${VERIFY_ANTIPLACEBO_SCRATCH:-}"
if [ -n "$S" ]; then
  D="$S"
else
  D="${TMPDIR:-/tmp}/verify_antiplacebo-$(printf '%s' "$R1" | sha256sum | cut -c1-8)"
fi
mkdir -p "$D"
H="$(printf '%s' "$R1" | sha256sum | cut -c1-8)"
printf '%s %s %s\n' "$$" "$(ps -o pgid= -p "$$" | tr -d ' ')" "$(date +%s)" > "$D/verify_antiplacebo-$H.lock"
mkdir -p "$D/run-$$"
trap 'rm -rf "$D"' EXIT      # безусловно — каталог существовал до прогона, но «наш»
sleep 1
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
TMPDIR="$WORK/red-tmp" "$BARRIER" "$R" techka
