# ПРИЧИНА: plans/za-zonoj-hex40.md
#
# Контракт 040, адверсарий круг 7 (verdicts/adversary/contracts-040-v7-circle.md,
# находка 2): batched `git diff-tree --stdin` разбирал поток регэкспом
# `/^[0-9a-f]{40}$/`, отличая SHA-заголовок от строки-пути ПО ФОРМЕ значения —
# легальное имя файла из ровно 40 hex-символов (git/POSIX это разрешают) неотличимо
# от SHA по форме, только по ПОЗИЦИИ в потоке. Completeness-guard путал такой путь
# с фантомным «лишним заголовком без судимого SHA» и красил ПОЛНЫЙ честный поток.
#
# Зелёный контроль: чистое дерево → 0; автор коммитит top-level файл, чьё имя —
# РОВНО объявленная зона (40 hex-символов, `aaaa…aaaa`) → 0 (РЕГРЕССИЯ: до
# позиционного разбора — ложный «ОТКАЗ: batched git diff-tree --stdin вернул
# неполный/искажённый поток», путь принят за посторонний SHA-заголовок). Красное:
# тот же автор коммитит `plans/za-zonoj-hex40.md` — ВНЕ зоны, обычный путь,
# несвязанный с 40-hex именем выше — барьер обязан назвать ИМЕННО этот файл.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
P=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
make_repo "$R" "ЗОНА agent-x: $P"
"$BARRIER" "$R"

printf 'honest content\n' > "$R/$P"
commit_as "$R" agent-x 'легальное имя файла — ровно 40 hex-символов, top-level, внутри зоны'
"$BARRIER" "$R"

mkdir -p "$R/plans"
printf 'forbidden\n' > "$R/plans/za-zonoj-hex40.md"
commit_as "$R" agent-x 'коммит вне зоны — несвязанный путь'
"$BARRIER" "$R"
