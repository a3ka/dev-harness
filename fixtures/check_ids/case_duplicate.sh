# ПРИЧИНА: одинаковый номер
#
# Дефект «два файла одного класса с одним номером». Положительный контроль: дерево с одним
# планом 001 — зелёное (нет дубликатов, номер в истории). Красное: добавлен второй план под
# тем же номером — барьер называет ОБА файла, как требует план 005 §2 дословно.
set -euo pipefail

cd "$WORK"
git init -q .
git config user.email "fixture@test"
git config user.name "fixture"
mkdir -p plans
printf '# первый план\n' > plans/001-foo.md
git add plans/
git commit -q -m "first plan"

# Положительный контроль: один план, номер в истории, дубликатов нет.
BARRIER_ROOT="$WORK" "$BARRIER"

# Вносим обман: второй план под тем же номером 001 — теперь их два.
printf '# второй план\n' > plans/001-bar.md
git add plans/
git commit -q -m "second plan with duplicate number"

BARRIER_ROOT="$WORK" "$BARRIER"