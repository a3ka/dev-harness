# ПРИЧИНА: не наблюдался на непредсказуемом составе
# Ветвь (sostav): обманка «ГИГИЕНА БЕЗ РАБОТЫ» — ядро находки 2 адверсария (круг 2):
# «sostav наблюдает лишь rc=0, lock и run-*». Обманка безупречна в гигиене на ЛЮБОМ
# составе (трёхпольный lock, run-каталог, чистота дерева, rc=0) — и не вызывает НИ
# ОДНОГО барьера/фикстуры: до усиления проходила ветвь целиком, теперь краснеет на
# СЕМАНТИЧЕСКОМ свидетельстве — пустые журналы green/red/fix. По конструкции это
# эталон до усиления, предъявленный обманкой. Зелёный контроль — усиленный эталон:
# та же гигиена плюс фактический зелёный/красный цикл каждой фикстуры.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" sostav

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: безупречная гигиена (lock/run/чистота) без единого вызова барьеров —
# ровно то, что принимала ветвь sostav до усиления («наблюдает лишь rc=0, lock и
# run-*» — находка 2 адверсария, круг 2)
set -uo pipefail
R="${1:-}"; [ -n "$R" ] || exit 1
R="$(cd "$R" 2>/dev/null && pwd)" || exit 1
S="${VERIFY_ANTIPLACEBO_SCRATCH:-}"; [ -n "$S" ] || exit 1
case "$S" in /*) ;; *) S="$PWD/$S" ;; esac
mkdir -p "$S"
h="$(printf '%s' "$R" | sha256sum | cut -c1-8)"
L="$S/verify_antiplacebo-$h.lock"
printf '%s %s %s\n' "$$" "$(ps -o pgid= -p "$$" | tr -d ' ')" "$(date +%s)" > "$S/ltmp-$$"
ln "$S/ltmp-$$" "$L" 2>/dev/null || { rm -f "$S/ltmp-$$"; exit 3; }
rm -f "$S/ltmp-$$"
D="$S/run-$$"; mkdir -p "$D"; printf 'работа без работы\n' > "$D/log"
sleep 2
rm -rf "$D"; rm -f "$L"
printf 'complete verification accepted\n'
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" sostav
