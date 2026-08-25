# ПРИЧИНА: нет изоляции спавна
# Ветвь (izolcfg), шаг А решения владельца 2026-08-26: обманка — конфиг
# БЕЗ вложенного ключа task.isolation.mode: btrfs (нынешнее состояние дерева:
# ключа нет → режим none → параллельные пачки работают над живым деревом,
# замер шага 1: два параллельных verify — оба RC=1, 279с/29с, дважды).
# Зелёный контроль — mk_green_root (конфиг несёт ключ).
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" izolcfg

R="$WORK/red"; mk_green_root "$R"
cat > "$R/.omp/config.yml" <<'EOF'
# обманка: конфиг без изоляции спавна (шаг А, нынешнее состояние)
tools:
  approvalMode: always-ask

modelRoles:
  default: "minimax/MiniMax-M3"
EOF
"$BARRIER" "$R" izolcfg
