# ПРИЧИНА: неправильный формат
#
# Дефект «формат номера» — `0007-x.md` при существующем `id/PLAN/007» (находка 4
# второго круга). Прежняя `check_ids.sh` принимала `^[0-9]+-[a-zA-Z]`, и `0007-x.md`
# (четыре цифры) рядом с выданным `id/PLAN/007` проходил зелёным — тот же
# идентификатор в другой записи. Три цифры обязательны в ОБЕ стороны: и выдача, и
# проверка требуют ровно трёхзначный формат.
#
# Теперь `parse_artifact_basename` (единая реализация в `next_id.sh`, импортируется и
# в `check_ids.sh`) возвращает 2 для неправильного формата, и `check_ids.sh` сообщает
# об этом как «номер 7 в <путь> имеет неправильный формат (4+ цифр, ожидается 3)».
#
# Положительный контроль: один план 007 с тегом — зелёный. Красное: добавлен файл
# `plans/0007-x.md` (четыре цифры) — барьер видит неправильный формат и называет путь.
set -euo pipefail

cd "$WORK"
# `check_ids.sh` импортирует разбор имени из `next_id.sh` через `NEXT_ID_LIB=1 source`.
# Копируем `next_id.sh` рядом: обёртка `verify_antiplacebo` копирует в `$WORK/scripts/`
# только сам вызванный барьер.
mkdir -p "$WORK/scripts"
cp "$REPO/scripts/next_id.sh" "$WORK/scripts/"
git init -q .
git config user.email "fixture@test"
git config user.name "fixture"
git config commit.gpgsign false
git config core.hooksPath /dev/null
mkdir -p plans
printf '# план с правильным номером\n' > plans/007-y.md
git add plans/
git commit -q -m "first plan with valid 007"
git tag id/PLAN/007 -m "выдача механизмом"

# Положительный контроль: один план, тег есть, формат правильный.
BARRIER_ROOT="$WORK" "$BARRIER"

# Вносим обман: тот же номер 7 в записи с четырьмя цифрами — `plans/0007-x.md`.
# Это и есть тот же идентификатор в другой записи: 0007 = 007 как число. Прежняя
# сверка прошла бы зелёной; теперь — отдельное красное о формате.
printf '# план с четырьмя цифрами\n' > plans/0007-x.md
git add plans/
git commit -q -m "ручной 0007-x.md без тега выдачи"

BARRIER_ROOT="$WORK" "$BARRIER"