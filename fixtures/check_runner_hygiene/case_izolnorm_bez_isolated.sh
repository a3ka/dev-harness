# ПРИЧИНА: не несёт правила
# Ветвь (izolnorm), шаги А/В решения владельца 2026-08-26: обманка — роль
# orchestrator без правила «isolated: true» на спавн параллельных пачек и без
# нормы disposable-клона для длинных прогонов verify_antiplacebo (нынешнее
# состояние: обе нормы не записаны, пачки работают над живым деревом).
# Зелёный контроль — mk_green_root (обе нормы записаны).
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" izolnorm

R="$WORK/red"; mk_green_root "$R"
cat > "$R/roles/orchestrator.md" <<'EOF'
# Роль orchestrator (обманка: без isolated и без disposable-клона)

Параллельные пачки спавнятся над живым деревом; длинные прогоны — прямо в дереве.
EOF
"$BARRIER" "$R" izolnorm
