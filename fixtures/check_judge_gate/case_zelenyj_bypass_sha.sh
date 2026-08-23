# ПРИЧИНА: НЕ передал свой
# Ветвь (зелёный): барьер ловит judge_gate, который НЕ передаёт свой $1 (sha) в check_ci_gate.
# Зелёный контроль — реальный judge_gate (передаёт sha, fake даёт rc0). Красное — стаб, зовущий
# check_ci_gate с ЖЁСТКИМ чужим sha → fake вернёт rc≠0, а sha в выводе не совпадёт.
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cp "$REPO/scripts/judge_gate.sh" "$G/scripts/judge_gate.sh"
chmod +x "$G/scripts/judge_gate.sh"
"$BARRIER" "$G" зелёный

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/judge_gate.sh" <<'EOF'
#!/usr/bin/env bash
# стаб: зовёт check_ci_gate с ЖЁСТКИМ чужим sha (не передаёт свой $1)
bash "$(dirname "$0")/check_ci_gate.sh" "wrong-sha-ignored"; rc=$?
[ "$rc" = 0 ] && echo OK
exit "$rc"
EOF
chmod +x "$R/scripts/judge_gate.sh"
"$BARRIER" "$R" зелёный
