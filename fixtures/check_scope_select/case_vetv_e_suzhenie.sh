# ПРИЧИНА: не сужена
# Ветвь (е): правка барьера b → scoped, выбран РОВНО b (не a). Барьер ловит стаб, тянущий в
# выборку незадетый a.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/root"

sel "$R" <<'EOF'
#!/usr/bin/env bash
r="$1"; base="${3:-}"
ch="$(git -C "$r" diff --name-only "$base" HEAD)"
echo "SCOPED: не для приёмки" >&2; echo "MODE: scoped"
printf '%s\n' "$ch" | grep -q 'scripts/b.sh' && echo "KEY: b"
printf '%s\n' "$ch" | grep -q 'scripts/a.sh' && echo "KEY: a"
exit 0
EOF
"$BARRIER" "$R" е

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "SCOPED: не для приёмки" >&2; echo "MODE: scoped"; echo "KEY: b"; echo "KEY: a"; exit 0
EOF
"$BARRIER" "$R" е
