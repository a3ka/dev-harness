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

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
BARRIER="$HERE/check_protected.sh"

[ -f "$BARRIER" ] || { printf 'NOT_IMPLEMENTED: рядом нет check_protected.sh — нечего прогонять\n' >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

mkdir -p "$ROOT/tmp"
W="$(mktemp -d "$ROOT/tmp/drill-allow.XXXXXX")"
trap 'rm -rf "$W"' EXIT

g() { git -C "$W" -c user.name=Дрилл -c user.email=drill@local "$@"; }

mkdir -p "$W/roles" "$W/verdicts/adversary" "$W/plans"
printf -- '---\nname: adversary\nverdict: verdicts/adversary/\n---\n' > "$W/roles/adversary.md"
printf 'вердикт\n' > "$W/verdicts/adversary/v-1.md"
printf 'план\n'    > "$W/plans/001-p.md"
git init -q -b main "$W"
g add -A
g commit -q -m 'основание'

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
