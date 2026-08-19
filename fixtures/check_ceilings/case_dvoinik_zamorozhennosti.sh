# ПРИЧИНА: Незаполненные требования
#
# Пара-двойник замороженности (контракт 004 v1, арбитраж zamorozhennaya-proba):
# два ПОРОЖДЁННЫХ номера N1≠N2, одинаковое тело вне грамматики, подставной
# замороженный тег — только у N1 и только в изолированном дереве фикстуры.
# N1 → 0 (заморожено — вне суда), N2 → 1 (незамороженный черновик с невалидным
# телом). Ловит барьер-vitelist известных номеров в обе стороны.
# Зелёный контроль: валидный незамороженный черновик («нет») — до построения пары.
set -euo pipefail
. "$(dirname "$0")/_gen.sh"
R="$WORK/repo"
mkdir -p "$R/contracts"

# Зелёный контроль: валидный незамороженный черновик
C0="$(rnd_nnn kontrakt-ok)"
printf '# Черновик C0\n\n## Предмет\nпроба\n\n## Незаполненные требования:\nнет\n' > "$R/contracts/$C0.md"
"$BARRIER" "$R"
rm "$R/contracts/$C0.md"

while :; do N1=$((RANDOM % 900 + 100)); N2=$((RANDOM % 900 + 100)); [ "$N1" != "$N2" ] && break; done
N1=$(printf '%03d' "$N1"); N2=$(printf '%03d' "$N2")

printf '# Черновик N1\n\n## Предмет\nпроба\n\n## Незаполненные требования:\nпока не решили\n' > "$R/contracts/$N1-dvoinik.md"
printf '# Черновик N2\n\n## Предмет\nпроба\n\n## Незаполненные требования:\nпока не решили\n' > "$R/contracts/$N2-dvoinik.md"

GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$R" >/dev/null
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" -c user.name=Фикстура -c user.email=f@l add -A
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" -c user.name=Фикстура -c user.email=f@l commit -q -m base
# Тег — ТОЛЬКО у N1: замороженность читается из тегов, не из известных номеров
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" -c user.name=Фикстура -c user.email=f@l tag -a "frozen/contracts/$N1/1" -m подставной
"$BARRIER" "$R"
