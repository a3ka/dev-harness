# ПРИЧИНА: неизвестный класс
#
# Дефект `next_id.sh`: класс, которого нет в PLAN/VERDICT/ADR, должен отказать с названной
# причиной. Положительный контроль: PLAN — зелёный (печатает номер). Красное: FOO — отказ.
#
# Герметичное окружение задаётся здесь, потому что `next_id.sh` создаёт теги (`git tag`),
# и без локального `user.name`/`user.email` оно валится «empty ident name» — адверсарий
# измерил это на механизме 4, и здесь то же: фикстура обязана дать барьеру инструменты.
set -euo pipefail

cd "$WORK"
git init -q .
git config user.email "fixture@test"
git config user.name "fixture"
git config commit.gpgsign false
git config core.hooksPath /dev/null
mkdir -p plans
# `git tag` без HEAD падает «Failed to resolve HEAD». Пустой коммит — самое дешёвое
# основание: ни планов, ни вердиктов; `next_id.sh` на пустом выдаст `001` и создаст тег.
git commit --allow-empty -q -m "основание"

# Положительный контроль: валидный класс — барьер печатает номер, код 0.
BARRIER_ROOT="$WORK" "$BARRIER" PLAN

# Вносим обман: несуществующий класс.
BARRIER_ROOT="$WORK" "$BARRIER" FOO