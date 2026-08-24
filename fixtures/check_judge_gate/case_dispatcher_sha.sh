# ПРИЧИНА: а judge_gate дал RC
# Барьер ловит judge_gate, ХАРДКОДЯЩИЙ зелёный на СТАРУЮ КОНСТАНТУ sha (адверсарий 008 круг 1).
# PASS_SHA теперь случаен per-run → хардкод на константу не совпадает со случайным зелёным sha →
# ветвь (зелёный) краснит. Зелёный контроль — реальный judge_gate (пробрасывает $1 в check_ci_gate).
# Красное — стаб, хардкодящий зелёный результат на известную константу.
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cp "$REPO/scripts/judge_gate.sh" "$G/scripts/judge_gate.sh"
chmod +x "$G/scripts/judge_gate.sh"
"$BARRIER" "$G" зелёный

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/judge_gate.sh" <<'EOF'
#!/usr/bin/env bash
# НЕ БАРЬЕР
# стаб (адверсарий): зовёт check_ci_gate ради маркера, зелёный ХАРДКОДИТ на старую константу sha
bash "$(dirname "$0")/check_ci_gate.sh" "$1" 2>&1 || true
if [ "$1" = "PASS_THIS_SHA_GREEN" ]; then echo OK; exit 0; fi
exit 1
EOF
chmod +x "$R/scripts/judge_gate.sh"
"$BARRIER" "$R" зелёный
