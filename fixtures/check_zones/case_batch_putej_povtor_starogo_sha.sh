# ПРИЧИНА: plans/za-zonoj-povtor-sha.md
#
# Контракт 040, адверсарий круг 8 (verdicts/adversary/contracts-040-v8-circle.md):
# позиционный разбор v8 верно сравнивал запись со СЛЕДУЮЩИМ ожидаемым SHA, но
# избыточный fallback `if ($0 in want) seen[$0]++` трактовал ЛЮБОЕ совпадение с
# ИЗВЕСТНЫМ SHA (не только со следующим ожидаемым) как повторный заголовок:
# легальный путь, равный SHA РАНЕЕ уже поглощённого коммита, ложно задваивал
# заголовок ТОГО коммита, и completeness-guard красил ПОЛНЫЙ честный поток тем же
# «ОТКАЗ: batched git diff-tree --stdin вернул неполный/искажённый поток», что и
# настоящую порчу.
#
# Зелёный контроль: чистое дерево → 0; agent-x честно коммитит `scripts/inside.sh`
# (её SHA обозначим C) → 0; штатная заморозка v2 добавляет к зоне ТОЧНЫЙ путь,
# равный C (легальное имя файла — 40 hex-символов), ДОПОЛНИТЕЛЬНО к `scripts/` —
# диапазон суда остаётся от v1 (C уже в нём); agent-x честно создаёт top-level
# файл с именем РОВНО C → 0 (РЕГРЕССИЯ: до структурного `--raw`-разбора — ложный
# «ОТКАЗ: batched git diff-tree --stdin вернул неполный/искажённый поток», путь D
# принят за ВТОРОЙ заголовок уже поглощённого коммита C). Красное: agent-x
# коммитит `plans/za-zonoj-povtor-sha.md` — вне зоны, обычный путь, несвязанный ни
# с C, ни с её sha-именем — барьер обязан назвать ИМЕННО этот файл, а не
# «искажённый поток» (доказывает, что фикс не превратил барьер в вечно-зелёный).
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R" "ЗОНА agent-x: scripts/"
"$BARRIER" "$R"

mkdir -p "$R/scripts"
printf 'honest content\n' > "$R/scripts/inside.sh"
commit_as "$R" agent-x 'C: честный коммит внутри зоны scripts/'
"$BARRIER" "$R"
CSHA="$(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" rev-parse HEAD)"

freeze_v2 "$R" "ЗОНА agent-x: scripts/ $CSHA"
"$BARRIER" "$R"

printf 'named after prior commit sha\n' > "$R/$CSHA"
commit_as "$R" agent-x 'D: легальный top-level файл, имя — ровно SHA РАНЕЕ поглощённого коммита C'
"$BARRIER" "$R"

mkdir -p "$R/plans"
printf 'forbidden\n' > "$R/plans/za-zonoj-povtor-sha.md"
commit_as "$R" agent-x 'коммит вне зоны — несвязанный путь'
"$BARRIER" "$R"
