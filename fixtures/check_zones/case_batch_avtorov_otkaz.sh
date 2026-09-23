# ПРИЧИНА: batched git log --no-walk --stdin отказал
# ОКРУЖЕНИЕ: PATH=$WORK/bin:$PATH
#
# Контракт 040 v2-fix — адверсарий (verdicts/adversary/contracts-040-oracle-a2-diff-tree.md,
# круг 1) предъявил обход A2: единственный batched-вызов авторов окна (`git log --no-walk
# --stdin`) при отказе (например rc=127) молча превращался в ПУСТОЙ author_map — нарушитель
# исчезал из суда зон целиком, а весь барьер отвечал rc=0 («отказ, выглядящий успехом», не
# постоянная заглушка). PATH-spy `git` ниже возвращает 127 ТОЛЬКО на аргументе `--no-walk`,
# делегируя КАЖДЫЙ прочий вызов реальному git — точная топология живой репродукции
# адверсария.
#
# Зелёный контроль: чистое дерево сразу после заморозки, окно ещё без коммитов, честный git
# → 0. Красное: объявленный agent-x коммитит вне своей зоны (в plans/, зона — только
# scripts/), И единственный batched author-lookup этого окна отказывает — барьер обязан
# назвать ИМЕННО отказ инструмента (rc=1), а не смолчать rc=0.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R" 'ЗОНА agent-x: scripts/'
"$BARRIER" "$R"

printf 'forbidden\n' > "$R/plans/002-outside.md"
commit_as "$R" agent-x 'declared agent writes outside zone'

REALGIT="$(command -v git)"
mkdir -p "$WORK/bin"
cat > "$WORK/bin/git" <<EOF
#!/bin/sh
for arg in "\$@"; do [ "\$arg" = --no-walk ] && exit 127; done
exec "$REALGIT" "\$@"
EOF
chmod +x "$WORK/bin/git"
"$BARRIER" "$R"
