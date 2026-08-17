# ПРИЧИНА: одинаковый номер
#
# Дефект «гонка двух клонов» (находка 2 второго круга). Два независимых клона
# одновременно выдают 007 — каждый создаёт свой локальный тег `id/PLAN/007` и свой
# файл `007-x.md`. Тег локален, общего реестра между клонами нет.
#
# `next_id.sh` это не закрывает (локальная атомарность в одном `.git` держится, общей
# нет), и это ГРАНИЦА механизма, не дыра. После слияния двух таких веток в одном
# репозитории оба файла оказываются на HEAD, и `check_ids.sh` ОБЯЗАН увидеть дубль
# номера, назвать ОБА пути и отказать. Так общая атомарность достигается не выдачей,
# а сверкой — `find` в локации класса перечисляет оба файла.
#
# Положительный контроль: один план 001 с тегом — зелёный. Красное: добавлена вторая
# ветка со своим 007, обе слиты — `check_ids.sh` называет ОБА файла в красном.
set -euo pipefail

cd "$WORK"
# `check_ids.sh` импортирует разбор имени из `next_id.sh` через `NEXT_ID_LIB=1 source`.
# Копируем `next_id.sh` рядом: обёртка `verify_antiplacebo` копирует в `$WORK/scripts/`
# только сам вызванный барьер.
mkdir -p "$WORK/scripts"
cp "$REPO/scripts/next_id.sh" "$WORK/scripts/"

git init -q -b main
git config user.email "fixture@test"
git config user.name "fixture"
git config commit.gpgsign false
git config core.hooksPath /dev/null
mkdir -p plans
git commit --allow-empty -q -m "root"

# Положительный контроль: один план 001 с тегом — зелёный.
printf '# one\n' > plans/001-a.md
git add plans/
git commit -q -m "branch a issued 001"
git tag id/PLAN/001 -m "выдача механизмом"

BARRIER_ROOT="$WORK" "$BARRIER"

# Обман: вторая ветка со своим `007-a.md` и тегом `id/PLAN/007`. Первая ветка
# (`branch-a`) уже есть на main с 001; создаём `branch-b` от корня со своим 007.
git checkout -q -b branch-b
printf '# branch b issued 007\n' > plans/007-b.md
git add plans/
git commit -q -m "branch b issued 007"
git tag id/PLAN/007 -m "branch b issued 007 locally"

# Теперь отдельная ветка со своим 007 (имитация клона, который не знает про branch-b).
git checkout -q -b branch-c
printf '# branch c also issued 007\n' > plans/007-c.md
git add plans/
git commit -q -m "branch c issued 007 locally"
git tag id/PLAN/007 -m "branch c issued 007 locally" -f

# Возвращаемся на main и сливаем обе ветки с `--allow-unrelated-histories`, чтобы
# оба файла 007-b.md и 007-c.md оказались в дереве main (без этого merge откажется —
# у них разные родители от main).
git checkout -q main
git merge --allow-unrelated-histories branch-b -q -m "merge b"
git merge --allow-unrelated-histories branch-c -q -m "merge c"

# Состояние после слияния: 001-a.md, 007-b.md и 007-c.md в одном дереве. `find` в
# `plans/` увидит ОБА 007 — `check_ids.sh` должен назвать ОБА в красном.
ls plans/ >&2
echo "---tags:" >&2
git for-each-ref --format='%(refname:short)' 'refs/tags/' >&2

BARRIER_ROOT="$WORK" "$BARRIER"