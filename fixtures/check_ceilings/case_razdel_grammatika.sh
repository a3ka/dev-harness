# ПРИЧИНА: Незаполненные требования
#
# Полная матрица раздела (контракт 004 v1): тело «нет» → 0; валидный список → 0;
# отсутствует → 1; пустое тело → 1; тело вне грамматики (произвольная строка) → 1.
# Черновик НЕзаморожен — дерево без git-тегов. Имена черновиков порождаются
# (грамматика NNN-slug — как у настоящих).
set -euo pipefail
. "$(dirname "$0")/_gen.sh"
R="$WORK/repo"
mkdir -p "$R/contracts"

C1="$(rnd_nnn kontrakt-net)"
printf '# Черновик\n\n## Предмет\nпроба\n\n## Незаполненные требования:\nнет\n' > "$R/contracts/$C1.md"
"$BARRIER" "$R"

C2="$(rnd_nnn kontrakt-spisok)"
rm "$R/contracts/$C1.md"
printf '# Черновик\n\n## Предмет\nпроба\n\n## Незаполненные требования:\n- первое\n- второе\n' > "$R/contracts/$C2.md"
"$BARRIER" "$R" || true

C3="$(rnd_nnn kontrakt-bez-razdela)"
rm "$R/contracts/$C2.md"
printf '# Черновик\n\n## Предмет\nпроба\n' > "$R/contracts/$C3.md"
"$BARRIER" "$R" || true

C4="$(rnd_nnn kontrakt-pustoj)"
rm "$R/contracts/$C3.md"
printf '# Черновик\n\n## Предмет\nпроба\n\n## Незаполненные требования:\n' > "$R/contracts/$C4.md"
"$BARRIER" "$R" || true

C5="$(rnd_nnn kontrakt-vne-grammatiki)"
rm "$R/contracts/$C4.md"
printf '# Черновик\n\n## Предмет\nпроба\n\n## Незаполненные требования:\nпока не решили\n' > "$R/contracts/$C5.md"
"$BARRIER" "$R"
