# ПРИЧИНА: pid перерождён
# Ветвь (pidrec), райдер (iii) контракта 012: обманка ведёт себя как нынешний
# раннер — живость владельца lock проверяет kill -0 <pid> БЕЗ сверки pgid.
# Барьер подаёт lock, чей pid ЖИВ (посторонний decoy-процесс), но pgid в lock
# ЧУЖОЙ: владелец мёртв, pid перерождён. Обманка отказывает «занят» rc=3 и
# держит мёртвый lock вечно. Зелёный контроль — эталон (сверка pgid опознаёт
# владельца мёртвым: lock убран, прогон прошёл rc=0, decoy-процесс цел).
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" pidrec

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: живость владельца по kill -0 без сверки pgid (райдер (iii))
set -uo pipefail
R1="$(cd "$1" && pwd)"
S="${VERIFY_ANTIPLACEBO_SCRATCH:-}"
[ -n "$S" ] || S="$(mktemp -d "${TMPDIR:-/tmp}/verify_antiplacebo.XXXXXX")"
mkdir -p "$S"
L="$S/verify_antiplacebo-$(printf '%s' "$R1" | sha256sum | cut -c1-8).lock"
if [ -f "$L" ]; then
  pid=""; read -r pid _ < "$L" 2>/dev/null || true
  if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
    printf 'занят: владелец pid %s жив\n' "$pid" >&2; exit 3
  fi
  rm -f "$L"
fi
printf '%s %s %s\n' "$$" "$(ps -o pgid= -p "$$" | tr -d ' ')" "$(date +%s)" > "$L"
sleep 1
rm -f "$L"
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" pidrec
