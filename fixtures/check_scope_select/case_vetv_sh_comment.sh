# ПРИЧИНА: вычет комментариев
# Ветвь (ш): имя b.sh ТОЛЬКО в полнострочном комментарии → scoped (комментарии вычитаются).
# Барьер ловит селектор, вечно-фуллящий на упоминание в комментарии. Зелёный — честный (scoped KEY b), красное — обманный (full).
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/root"

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "SCOPED: не для приёмки" >&2; echo "MODE: scoped"; echo "KEY: b"; exit 0
EOF
"$BARRIER" "$R" ш

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "MODE: full"; exit 0
EOF
"$BARRIER" "$R" ш
