# ПРИЧИНА: plans/za-zonoj.md
#
# Контракт 040, адверсарий круг 7 (verdicts/adversary/contracts-040-v7-circle.md,
# находка 1): `git diff-tree --name-only` БЕЗ `-z`/NUL-терминации отдаёт C-quoted
# представление любого байта имени вне печатного ASCII (non-ASCII байт → октальный
# эскейп в кавычках, `scripts/é.sh` → `"scripts/\303\251.sh"`; LF в имени → квотирование
# с ДВУХСИМВОЛЬНЫМ `\n`-эскейпом, `line<LF>break.sh` → `"line\nbreak.sh"`) — сравнение
# этого текста с НЕэкранированным путём зоны ложно красит честный коммит. Находка
# явно называет ОБА случая («Честный файл с LF в имени красится тем же механизмом»).
#
# Зелёный контроль: чистое дерево → 0; автор коммитит ОБА честных пути — UTF-8 имя
# (`é.sh`) И имя с сырым LF-байтом (`line<LF>break.sh`) — ВНУТРИ своей зоны `scripts/`
# → 0 (РЕГРЕССИЯ: до фикса `-z` барьер квотировал пути и ложно называл «коммит вне
# зоны» на C-quoted представлении, не совпавшем с объявленным префиксом `scripts/`).
# Красное: тот же автор коммитит `plans/za-zonoj.md` — ВНЕ зоны, обычный ASCII путь,
# не связанный ни с UTF-8, ни с LF-именем выше — барьер обязан назвать ИМЕННО этот
# файл (не спутать его с уже принятыми UTF-8/LF путями и не смолчать).
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R" 'ЗОНА agent-x: scripts/'
"$BARRIER" "$R"

printf 'utf8\n' > "$R/scripts/é.sh"
NL_NAME="$(printf 'line\nbreak.sh')"
printf 'nl\n' > "$R/scripts/$NL_NAME"
commit_as "$R" agent-x 'честные UTF-8 и LF-в-имени пути внутри объявленной зоны'
"$BARRIER" "$R"

mkdir -p "$R/plans"
printf 'forbidden\n' > "$R/plans/za-zonoj.md"
commit_as "$R" agent-x 'коммит вне зоны — обычный ASCII путь, несвязанный с UTF-8/LF'
"$BARRIER" "$R"
