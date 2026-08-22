# ПРИЧИНА: fail-closed
# Ветвь (л) check_scope_select: барьер САМ вызывает селектор с PATH без git (внутри ветви л) и
# ждёт код 2 + маркер SCOPED:. Фикстура лишь подаёт СЕЛЕКТОР — PATH НЕ трогает (это делает барьер):
# зелёный — честный (fail-closed на отсутствии git: SCOPED: + код 2); красный — обманка (глотает
# git-отсутствие, возвращает 0). Обманный стаб-барьер (всегда 0) красноты не даст.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/root"

sel "$R" <<'EOF'
#!/usr/bin/env bash
# НЕ БАРЬЕР: честный селектор — fail-closed при отсутствии git.
set -uo pipefail
root="${1:?корень}"; shift
flag="${1:-}"
case "$flag" in
  --changed)
    command -v git >/dev/null 2>&1 || { echo "SCOPED: нет git — fail-closed" >&2; printf 'MODE: needs-full\n'; exit 2; }
    echo "SCOPED: не для приёмки" >&2; printf 'MODE: scoped\n'; exit 0 ;;
  *) echo "неизвестный режим" >&2; exit 1 ;;
esac
EOF
"$BARRIER" "$R" л

sel "$R" <<'EOF'
#!/usr/bin/env bash
# НЕ БАРЬЕР: обманка — глотает git-отсутствие (всегда 0, НЕ fail-closed).
set -uo pipefail
printf 'MODE: scoped\n'; exit 0
EOF
"$BARRIER" "$R" л
