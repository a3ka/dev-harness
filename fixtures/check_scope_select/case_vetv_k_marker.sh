# ПРИЧИНА: не напечатал машинный маркер
# который на одном из двух режимов не печатает маркер.
#
# Теперь (к) проверяет ОБА: scoped (после правки b) И needs-full (после docs-only commit).
# Зелёный стаб честно выдаёт оба: scoped→SCOPED, needs-full→SCOPED+needs-full.
# Красный стаб глотает SCOPED на needs-full (только MODE: needs-full без маркера).
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/root"

# Зелёный: на --changed после правки барьера → scoped с маркером. На docs-only → needs-full с маркером.
sel "$R" <<'EOF'
#!/usr/bin/env bash
# НЕ БАРЬЕР: честный стаб.
set -uo pipefail
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
root="${1:?корень}"; shift
flag="${1:-}"; [ "$#" -gt 0 ] && shift || true
emit() { printf 'SCOPED: %s\n' "$*" >&2; }
case "$flag" in
  --changed)
    base="${1:-}"
    if ! command -v git >/dev/null 2>&1; then emit "нет git — fail-closed"; printf 'MODE: needs-full\n'; exit 2; fi
    if ! git -C "$root" rev-parse --verify --quiet "${base}^{commit}" >/dev/null 2>&1; then emit "база не резолвится"; printf 'MODE: needs-full\n'; exit 2; fi
    names="$(git -C "$root" diff --name-only "$base" HEAD)"
    if printf '%s\n' "$names" | grep -qE '^scripts/.*\.sh$'; then
      emit "не для приёмки"; printf 'MODE: scoped\n'; for k in $(printf '%s\n' "$names" | sed -n 's|^scripts/\(.*\)\.sh$|\1|p' | sort -u); do printf 'KEY: %s\n' "$k"; done; exit 0
    fi
    emit "0 задетых — scoped ничего не доказал, полный гейт в CI"; printf 'MODE: needs-full\n'; exit 2 ;;
  *) echo "неизвестный режим: $flag" >&2; exit 1 ;;
esac
EOF
"$BARRIER" "$R" к

# Красный: при needs-full НЕ печатает SCOPED: (только MODE: needs-full).
sel "$R" <<'EOF'
#!/usr/bin/env bash
# НЕ БАРЬЕР: стаб, глотающий SCOPED на needs-full.
set -uo pipefail
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
root="${1:?корень}"; shift
flag="${1:-}"; [ "$#" -gt 0 ] && shift || true
case "$flag" in
  --changed)
    base="${1:-}"
    if ! git -C "$root" rev-parse --verify --quiet "${base}^{commit}" >/dev/null 2>&1; then printf 'MODE: needs-full\n'; exit 2; fi
    names="$(git -C "$root" diff --name-only "$base" HEAD)"
    if printf '%s\n' "$names" | grep -qE '^scripts/.*\.sh$'; then
      printf 'SCOPED: не для приёмки\n' >&2
      printf 'MODE: scoped\n'; for k in $(printf '%s\n' "$names" | sed -n 's|^scripts/\(.*\)\.sh$|\1|p' | sort -u); do printf 'KEY: %s\n' "$k"; done; exit 0
    fi
    printf 'MODE: needs-full\n'; exit 2 ;;  # ← SCOPED пропущен на needs-full
  *) echo "неизвестный режим: $flag" >&2; exit 1 ;;
esac
EOF
"$BARRIER" "$R" к
