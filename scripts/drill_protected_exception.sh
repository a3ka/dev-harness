#!/usr/bin/env bash
# Дрилл: ЯВНОЕ разрешение действительно принимается.
#
# Заведён потому, что механизм анти-плацебо доказывает только КРАСНОЕ: фикстура обязана
# завалить барьер. Путь исключения зелёный по определению, и фикстурой он не выражается.
# Непроверенное зелёное ветвление — это ровно тот случай, когда защита выглядит работающей,
# а разрешение не работает: тогда единственный законный способ удалить артефакт закрыт, и
# правило начинают обходить, а не соблюдать.
#
# Дрилл переворачивает полярность: он строит дерево, где удаление РАЗРЕШЕНО явно и именно,
# и требует от барьера нуля. Сам дрилл предъявляется красным обычной фикстурой — подставным
# `check_protected.sh`, который разрешения не признаёт.
#
# Барьер берётся РЯДОМ С СОБОЙ (`$(dirname $0)/check_protected.sh`) намеренно: так подмена
# подставного корня работает без флагов, и дрилл проверяет тот барьер, который лежит вместе
# с ним, а не тот, который случайно нашёлся в PATH.
#
#   bash scripts/drill_protected_exception.sh
#
# Коды возврата: 0 — разрешение принято, 1 — не принято, 2 — нечем проверить.
set -euo pipefail

# Унаследованные git-переменные меняют построение подставной истории ДО запуска проверяемого
# барьера: адверсарий предъявил `GIT_DIR`, `GIT_INDEX_FILE` и `GIT_WORK_TREE`, каждая выводила
# дрилл в код 2. Заявленный положительный контроль, который выключается окружением, контролем
# не является — поэтому переменные снимаются, а не обходятся.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
BARRIER="$HERE/check_protected.sh"

[ -f "$BARRIER" ] || { printf 'NOT_IMPLEMENTED: рядом нет check_protected.sh — нечего прогонять\n' >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

mkdir -p "$ROOT/tmp"
W="$(mktemp -d "$ROOT/tmp/drill-allow.XXXXXX")"
trap 'rm -rf "$W"' EXIT

# ГЕРМЕТИЧНОСТЬ, а не аккуратность. Адверсарий предъявил измерением: с глобальной
# `commit.gpgsign` без ключа основание не создаётся и дрилл аварийно выходит 128, а с
# `core.hooksPath`, отвергающим коммит, — 1 без собственного текста. Контракт объявляет 0/1/2,
# и внешний конфиг менял исход ДО запуска проверяемого барьера: дрилл был бы ложно-красным на
# другой машине и не доказывал бы заявленную зелёную ветвь.
g() {
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$W" \
      -c user.name=Дрилл -c user.email=drill@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      -c init.defaultBranch=main "$@"
}

mkdir -p "$W/roles" "$W/verdicts/adversary" "$W/plans"
printf -- '---\nname: adversary\nverdict: verdicts/adversary/\n---\n' > "$W/roles/adversary.md"
printf 'вердикт\n' > "$W/verdicts/adversary/v-1.md"
printf 'план\n'    > "$W/plans/001-p.md"

# Провал ПОСТРОЕНИЯ основания — это «нечем проверить», а не «исключение не работает». Иначе
# дефект окружения читался бы как дефект предмета, а ложная мера дороже отсутствующей.
base_or_skip() {
  "$@" && return 0
  printf 'NOT_IMPLEMENTED: не удалось построить подставную историю (%s) — окружение git мешает\n' "$1" >&2
  exit 2
}
base_or_skip env GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$W"
base_or_skip g add -A
base_or_skip g commit -q -m 'основание'

g rm -q verdicts/adversary/v-1.md
g commit -q -F - <<'MSG'
Вердикт снят осознанно

ALLOW-ARTIFACT-DELETE: verdicts/adversary/v-1.md выпущен под номером, который назначили
рукой, и заменён на выданный механизмом
MSG

out="$W/out.txt"
set +e
bash "$BARRIER" "$W" > "$out" 2>&1
rc=$?
set -e

if [ "$rc" -ne 0 ]; then
  printf 'ОТКАЗ: исключение не принято — барьер вернул %d там, где удаление объявлено явно и именно\n' "$rc" >&2
  sed 's/^/  | /' "$out" >&2
  exit 1
fi
if ! grep -qF -e 'исчез с явного разрешения: verdicts/adversary/v-1.md' "$out"; then
  printf 'ОТКАЗ: исключение не принято — барьер вернул ноль, но разрешение в отчёте не названо\n' >&2
  printf 'Молчаливое принятие неотличимо от того, что барьер вовсе не заметил пропажи.\n' >&2
  sed 's/^/  | /' "$out" >&2
  exit 1
fi
printf '  ok   явное именное разрешение принято и названо в отчёте\n' >&2
