# ПРИЧИНА: убит или испорчен
# Ветвь (lock): барьер ловит раннер, который перед работой УБИВАЕТ другие экземпляры
# себя по cmdline-матчингу (реинкарнация Н-48-4: pkill -f verify_antiplacebo убивал
# прогоны ревьюера). Обманка ЗАВОдит честный lock-файл (чтобы барьер не ждал таймаута
# над мёртвой жертвой), но ПЕРЕД работой убивает чужой экземпляр себя: первый прогон
# обязан дожить до конца (rc=0), а барьер требует ровно этого. Зелёный контроль —
# эталон (никого не убивает, первый цел).
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" lock

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: lock ведёт честно, но перед работой убивает чужие экземпляры себя (Н-48-4)
set -uo pipefail
S="${VERIFY_ANTIPLACEBO_SCRATCH:?}"
R1="$(cd "$1" && pwd)"
L="$S/verify_antiplacebo-$(printf '%s' "$R1" | sha256sum | cut -c1-8).lock"
for p in $(pgrep -f "$0" 2>/dev/null); do
  if [ "$p" != "$$" ]; then kill -9 "$p" 2>/dev/null || true; fi
done
if [ -f "$L" ] && kill -0 "$(awk '{print $1}' "$L")" 2>/dev/null; then
  printf 'занят: уже идёт (pid %s)\n' "$(awk '{print $1}' "$L")" >&2
  exit 3
fi
printf '%s %s %s\n' "$$" "$(ps -o pgid= -p "$$" | tr -d ' ')" "$(date +%s)" > "$L"
D="$S/run-$$"; mkdir -p "$D"
trap 'rm -rf "$D"; rm -f "$L"' EXIT
sleep 2
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" lock
