# ПРИЧИНА: реестр выдачи
#
# Дефект «shallow-клон даёт ложное «номер назначен рукой»» (находка 3 второго круга).
# Прежняя `check_ids.sh` не отличала клон shallow от честного дерева и обвиняла
# зарегистрированный план в ручном номере. Барьер теперь различает три состояния:
#
#   (а) реестр полон → сверка по существу;
#   (б) реестр неполен или недоступен (shallow, клон без тегов) → отказ с названной
#       причиной и лечением (`fetch --tags`, `fetch-depth: 0`);
#   (в) реестр полон, а тега на конкретный номер нет → «номер назначен рукой».
#
# Эта фикстура строит сценарий (б): shallow-клон с артефактами в HEAD, но без тегов
# реестра в локальном `.git`. Прежняя сверка давала ложное «номер назначен рукой»
# на ЗАРЕГИСТРИВАННЫЙ план 005 — ложно-красное разрушало доверие к барьеру. Теперь
# барьер возвращает код 1 с НАЗВАННОЙ причиной «реестр выдачи (refs/tags/id/*)
# недоступен; выполни fetch --tags --unshallow либо задай fetch-depth: 0».
#
# Положительный контроль: тот же исходный репозиторий без shallow-клона — на нём
# сверка проходит зелёной (ветка (а), полный реестр). Красное: shallow-клон того же
# репозитория — барьер отказывает с причиной (ветка (б)).
set -euo pipefail

cd "$WORK"
# `check_ids.sh` импортирует разбор имени из `next_id.sh` через `NEXT_ID_LIB=1 source`.
# Копируем `next_id.sh` рядом: обёртка `verify_antiplacebo` копирует в `$WORK/scripts/`
# только сам вызванный барьер.
mkdir -p "$WORK/scripts"
cp "$REPO/scripts/next_id.sh" "$WORK/scripts/"

# Создаём исходный репозиторий: артефакты с тегами реестра. Это «честное» дерево.
rm -rf "$WORK/source" "$WORK/shallow-clone"
git init -q -b main "$WORK/source"
cd "$WORK/source"
git config user.email "fixture@test"
git config user.name "fixture"
git config commit.gpgsign false
git config core.hooksPath /dev/null
mkdir -p plans
printf '# source plan\n' > plans/005-source.md
git add plans/
git commit -q -m "source"
# Тег реестра — именно он в честном дереве ловится сверкой как «выдан механизмом».
git tag id/PLAN/005 -m "выдача механизмом"

# Положительный контроль: на исходном репозитории барьер зелёный (ветка (а),
# полный реестр).
BARRIER_ROOT="$WORK/source" "$BARRIER"

# Теперь shallow-клон. `--depth 1` обрезает историю, и теги реестра (как и все
# остальные refs/tags, не в HEAD) НЕ подтягиваются (`git clone --depth 1` подтягивает
# только HEAD и его теги). Это и есть тот «неполный реестр», на котором прежний барьер
# врал.
cd "$WORK"
git clone --depth 1 --single-branch "file://$WORK/source" "shallow-clone"
cd "$WORK/shallow-clone"
git config commit.gpgsign false
git config core.hooksPath /dev/null
# `git tag -l 'id/*'` пуст — теги НЕ подтянулись в shallow-клон. Это и есть условие
# ветки (б): реестр (refs/tags/id/*) недоступен, а артефакт (plans/005-source.md) на
# месте. Прежняя `check_ids.sh` валила зелёный false positive «номер 5 назначен рукой»
# — теперь барьер возвращает отказ с названной причиной.
echo "shallow=$(git rev-parse --is-shallow-repository)" >&2
echo "tags=$(git tag -l 'id/*' | tr '\n' ' ')" >&2
echo "files=$(ls plans/)" >&2

BARRIER_ROOT="$WORK/shallow-clone" "$BARRIER"