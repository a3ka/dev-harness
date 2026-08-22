# ПРИЧИНА: не сужение
# Ветвь (п): смена ОБЪЯВЛЕННОГО кода в шапке барьера → MODE: full (§2 «коды/шапка не менялись»).
# Барьер ловит селектор, сузивший до scoped. Зелёный — честный (full), красное — обманный (scoped).
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/root"

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "SCOPED: не для приёмки" >&2; echo "MODE: full"; exit 0
EOF
"$BARRIER" "$R" п

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "SCOPED: не для приёмки" >&2; echo "MODE: scoped"; echo "KEY: b"; exit 0
EOF
"$BARRIER" "$R" п
