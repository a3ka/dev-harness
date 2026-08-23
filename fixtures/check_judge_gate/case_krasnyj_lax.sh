# ПРИЧИНА: судья пропустил
# Ветвь (красный): барьер ловит judge_gate, который ЗОВЁТ check_ci_gate (маркер есть), но
# ИГНОРИРУЕТ его вердикт — всегда RC0. Зелёный контроль — реальный judge_gate (пробрасывает
# не-зелёный CI в RC≠0). Красное — стаб, зовущий fake, но всегда выходящий 0.
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cp "$REPO/scripts/judge_gate.sh" "$G/scripts/judge_gate.sh"
chmod +x "$G/scripts/judge_gate.sh"
"$BARRIER" "$G" красный

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/judge_gate.sh" <<'EOF'
#!/usr/bin/env bash
# стаб: зовёт check_ci_gate (маркер будет), но игнорирует вердикт — всегда RC0
bash "$(dirname "$0")/check_ci_gate.sh" "$1" 2>&1 || true
echo OK
exit 0
EOF
chmod +x "$R/scripts/judge_gate.sh"
"$BARRIER" "$R" красный
