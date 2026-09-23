# ПРИЧИНА: batched git log --no-walk --stdin вернул неполный поток
# ОКРУЖЕНИЕ: PATH=$WORK/bin:$PATH
#
# Контракт 040 круг 2 — адверсарий (verdicts/adversary/contracts-040-oracle-a2-diff-tree-v2.md)
# предъявил обход круга-1 фикса (case_batch_avtorov_otkaz.sh): batched-вызов авторов окна
# (`git log --no-walk --stdin`) может ЗАВЕРШИТЬСЯ УСПЕШНО (rc=0), но отдать ЧАСТИЧНЫЙ,
# синтаксически валидный поток. PATH-spy ниже выполняет НАСТОЯЩИЙ git и пропускает через
# него весь запрос, но обрезает stdout ровно после ПЕРВОЙ полной NUL-записи
# (`SHA\0author\0` плюс завершающий `\n`, структурно — не магическим числом байт) и
# возвращает rc=0. rc-проверка круга 1 здесь НЕ срабатывает — команда рапортует успех;
# нарушающий ВТОРОЙ коммит окна исчезает из суда зон той же веткой
# `[ -n "$an" ] || continue`, что и легитимно-неавторские коммиты.
#
# Зелёный контроль: чистое дерево сразу после заморозки (окно ещё без коммитов) → 0;
# легитимный коммит объявленного автора в своей зоне под честным git → 0. Красное: тот же
# автор коммитит ВТОРЫМ вне своей зоны, И PATH-spy обрезает batched-поток авторов до ПЕРВОЙ
# (легитимной) записи, пряча SHA второго (нарушающего) коммита — барьер обязан назвать
# НЕПОЛНОТУ потока (rc=1), а не смолчать rc=0.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R" 'ЗОНА agent-x: scripts/'
"$BARRIER" "$R"

printf 'легитимная правка в зоне\n' >> "$R/scripts/a.sh"
commit_as "$R" agent-x 'легитимный коммит в зоне — сохранённая NUL-запись'
"$BARRIER" "$R"

mkdir -p "$R/plans"
printf 'forbidden\n' > "$R/plans/002-outside.md"
commit_as "$R" agent-x 'нарушающий коммит вне зоны — обрезанная NUL-запись'

REALGIT="$(command -v git)"
mkdir -p "$WORK/bin"
cat > "$WORK/bin/git" <<EOF
#!/bin/sh
no_walk=0
for arg in "\$@"; do [ "\$arg" = --no-walk ] && no_walk=1; done
if [ "\$no_walk" = 1 ]; then
  "$REALGIT" "\$@" | awk -v RS='\0' -v ORS='\0' '{ print; if (++n == 2) exit }'
  printf '\n'
  exit 0
fi
exec "$REALGIT" "\$@"
EOF
chmod +x "$WORK/bin/git"
"$BARRIER" "$R"
