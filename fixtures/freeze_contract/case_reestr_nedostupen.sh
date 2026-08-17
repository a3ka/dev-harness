# ПРИЧИНА: реестр заморозок
#
# ПИСАТЕЛЬ реестра обязан отказать ДО вычисления версии. Версия считается по локальному максимуму,
# поэтому в клоне с усечённой историей писатель, ничего не подозревая, выдал бы `v1` там, где `v1`
# уже существует в полном дереве, — идентификатор с двумя смыслами, и развести их в истории нечем
# (правило 5 нормы). Читателям то же состояние сообщает `check_ids.sh`, но им оно менее опасно:
# ошибившийся читатель краснеет повторно, ошибившийся писатель оставляет след навсегда.
#
# Зелёный контроль: полное дерево → v1. Красное: shallow-клон того же дерева.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
S="$WORK/source"
make_repo "$S"
"$BARRIER" contracts/001-x.md "полный реестр" "$S"

# `--depth 1` обрезает историю: `rev-parse --is-shallow-repository` даёт true, и библиотека
# сообщает `shallow`. Клонируется файловым URL, иначе git делает жёсткие ссылки и глубина не режется.
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git clone -q --depth 1 --single-branch "file://$S" "$WORK/shallow"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$WORK/shallow" config user.name Фикстура
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$WORK/shallow" config user.email fixture@local
"$BARRIER" contracts/001-x.md "заморозка в усечённом дереве" "$WORK/shallow"
