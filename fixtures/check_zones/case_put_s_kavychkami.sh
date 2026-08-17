# ПРИЧИНА: кавычку
#
# Адверсарий предъявил: путь `"scripts/a file.sh"` расщеплялся на два фантома `"scripts/a` и
# `file.sh"`, оба проходили валидацию, и запрещённый путь с пробелом попадал в зону. Грамматика
# путей разделена ПРОБЕЛАМИ — кавычек она не несёт и нести не может по построению.
#
# Зелёный контроль: валидная зона → 0. Красное: путь с кавычкой → код 1.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R" 'ЗОНА Жора: scripts/a.sh'
"$BARRIER" "$R"

printf '# контракт 002\n\nЗОНА Жора: "scripts/a file.sh"\n' > "$R/contracts/002-y.md"
printf 'accept\nвердикт\n' > "$R/verdicts/critic/contracts-002-v1.md"
commit_all "$R" 'контракт 002 с кавычками в пути'
g "$R" tag -a frozen/contracts/002/1 -m 'заморожен'
"$BARRIER" "$R"
