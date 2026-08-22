# ПРИЧИНА: принят
# Ветвь (о): не-барьерный ключ (lib_x, шапка «НЕ БАРЬЕР») обязан быть отвергнут кодом 1 (§3:
# --scope принимает ключ БАРЬЕРА). Барьер ловит селектор, ПРИНИМАЮЩИЙ не-барьер как ключ.
# Зелёный — честный (отвергает не-барьер), красное — обманный (принимает).
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/root"

sel "$R" <<'EOF'
#!/usr/bin/env bash
shift
[ "${1:-}" = --scope ] && { shift; for k in "$@"; do case "$k" in a|b) ;; *) echo "нет ключа барьера $k" >&2; exit 1 ;; esac; done; }
echo "MODE: scoped"
EOF
"$BARRIER" "$R" о

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "MODE: scoped"; echo "KEY: lib_x"; exit 0
EOF
"$BARRIER" "$R" о
