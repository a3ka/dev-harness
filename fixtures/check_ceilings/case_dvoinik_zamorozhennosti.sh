# ПРИЧИНА: (132 байт)
#
# Пара-двойник замороженности (контракт 004 v1, арбитраж zamorozhennaya-proba):
# два ПОРОЖДЁННЫХ номера N1≠N2, одинаковое тело вне грамматики, подставной
# замороженный тег — только у N1 и только в изолированном дереве фикстуры.
# СТАДИЯ 1 (зелёная): N1 ОДИН, с тегом → 0 — барьер обязан пропустить замороженный
# черновик с невалидным телом; барьер-vitelist известных номеров здесь краснеет.
# СТАДИЯ 2 (красная): добавлен N2 без тега → 1 с именем и размером (132 байта —
# размер twin-файла фиксирован, потому и в ПРИЧИНЕ).
set -euo pipefail
. "$(dirname "$0")/_gen.sh"
R="$WORK/repo"
mkdir -p "$R/contracts"

while :; do N1=$((RANDOM % 900 + 100)); N2=$((RANDOM % 900 + 100)); [ "$N1" != "$N2" ] && break; done
N1=$(printf '%03d' "$N1"); N2=$(printf '%03d' "$N2")

printf '# Черновик N1\n\n## Предмет\nпроба\n\n## Незаполненные требования:\nпока не решили\n' > "$R/contracts/$N1-dvoinik.md"
[ "$(wc -c < "$R/contracts/$N1-dvoinik.md")" -eq 132 ] || { printf 'фикстура сломана: twin не 132 байт\n' >&2; exit 2; }

GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$R" >/dev/null
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" -c user.name=Фикстура -c user.email=f@l add -A
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" -c user.name=Фикстура -c user.email=f@l commit -q -m base
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" -c user.name=Фикстура -c user.email=f@l tag -a "frozen/contracts/$N1/1" -m подставной

# Стадия 1: замороженный черновик с невалидным телом — ОДИН — обязан пройти
"$BARRIER" "$R"

# Стадия 2: такой же, но БЕЗ тега — отказ с именем и размером
printf '# Черновик N2\n\n## Предмет\nпроба\n\n## Незаполненные требования:\nпока не решили\n' > "$R/contracts/$N2-dvoinik.md"
"$BARRIER" "$R"
