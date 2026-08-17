#!/usr/bin/env bash
# Дрилл: изменение уставного документа ПО ПРОЦЕДУРЕ действительно принимается.
#
# Заведён потому, что механизм анти-плацебо доказывает только КРАСНОЕ: фикстура обязана завалить
# барьер. Законный путь зелёный по определению, и фикстурой он не выражается. Непроверенное зелёное
# ветвление — это ровно тот случай, когда защита выглядит работающей, а процедура не работает:
# тогда единственный законный способ изменить утверждённый текст закрыт, и правило начнут обходить,
# а не соблюдать. У нас это уже проверено на соседнем предмете — `drill_protected_exception.sh`.
#
# ПРОЦЕДУРА ЦЕЛИКОМ, как она объявлена планом 007:
#
#   1. контракт закоммичен, вердикт критика v1 первой строкой `accept`;
#   2. `freeze_contract.sh` → v1;
#   3. устав введён тегом `ustav/1`;
#   4. правка контракта ОДНИМ коммитом, который несёт и вердикт критика v2, и строку
#      `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: <путь> <причина>` в первой колонке;
#   5. `freeze_contract.sh` → v2;
#   6. `check_contract_frozen.sh` и `check_charter.sh` обязаны вернуть 0.
#
# Шаг 4 умышленно один коммит: разрешение, выданное заранее или задним числом, есть индульгенция
# (урок круга 2 по `ALLOW-ARTIFACT-DELETE`), и оба барьера это ловят. Дрилл проверяет, что
# ПРАВИЛЬНЫЙ порядок при этом проходит, а не только неправильный падает.
#
# Барьеры берутся РЯДОМ С СОБОЙ (`$(dirname $0)/…`) намеренно: так подмена подставного корня
# работает без флагов, и дрилл проверяет те барьеры, которые лежат вместе с ним, а не те, которые
# случайно нашлись в PATH.
#
# ЗЕЛЁНОЕ НАЗЫВАЕТСЯ ПОШАГОВО. Дрилл, печатающий один «ok» в конце, не даёт понять, какой из шести
# шагов процедуры сработал: рецидив «барьер молчит на зелёном» записан в `NABLIUDENIA.md` (Н-15) и
# трижды за одну пачку стоил лишних кругов правка-прогон.
#
#   bash scripts/drill_contract_change.sh
#
# Коды возврата: 0 — процедура принята, 1 — не принята, 2 — нечем проверить.
set -euo pipefail

# Унаследованные git-переменные меняют построение подставной истории ДО запуска проверяемых
# барьеров: адверсарий предъявил `GIT_DIR`, `GIT_INDEX_FILE` и `GIT_WORK_TREE` на механизме 4,
# каждая выводила соседний дрилл в код 2. Заявленный положительный контроль, который выключается
# окружением, контролем не является.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

FREEZE="$HERE/freeze_contract.sh"
FROZEN="$HERE/check_contract_frozen.sh"
CHARTER="$HERE/check_charter.sh"

for b in "$FREEZE" "$FROZEN" "$CHARTER"; do
  [ -f "$b" ] || { printf 'NOT_IMPLEMENTED: рядом нет %s — нечего прогонять\n' "$(basename "$b")" >&2; exit 2; }
done
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

mkdir -p "$ROOT/tmp"
W="$(mktemp -d "$ROOT/tmp/drill-charter.XXXXXX")"
trap 'rm -rf "$W"' EXIT

ok() { printf '  ok   %s\n' "$*" >&2; }
otkaz() {  # <шаг> <код> <файл вывода>
  printf 'ОТКАЗ: изменение устава по процедуре не принято на шаге «%s»: код %s\n' "$1" "$2" >&2
  printf 'Законный путь обязан быть зелёным, иначе правило начнут обходить, а не соблюдать.\n' >&2
  sed 's/^/  | /' "$3" >&2 || true
  exit 1
}

g() {
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$W" \
      -c user.name=Дрилл -c user.email=drill@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}

# Провал ПОСТРОЕНИЯ основания — это «нечем проверить», а не «процедура не работает». Иначе дефект
# окружения читался бы как дефект предмета, а ложная мера дороже отсутствующей.
base_or_skip() {
  "$@" && return 0
  printf 'NOT_IMPLEMENTED: не удалось построить подставную историю (%s) — окружение git мешает\n' "$1" >&2
  exit 2
}

out="$W/out.txt"

# ── 1. основание: контракт и вердикт критика v1 ───────────────────────────────
mkdir -p "$W/contracts" "$W/verdicts/critic" "$W/tmp"
printf '# контракт 001\n\nРАБОТА НЕ РАЗДАЁТСЯ: подставной контракт дрилла\n' > "$W/contracts/001-x.md"
printf 'accept\nвердикт критика v1\n' > "$W/verdicts/critic/contracts-001-v1.md"
printf '# норма\n'   > "$W/AGENTS.md"
printf '# роадмап\n' > "$W/ROADMAP.md"
base_or_skip env GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$W"
# Локальная идентичность нужна потому, что `freeze_contract.sh` зовёт `git tag -a` без `-c`: в
# герметичном окружении он иначе падает с `empty ident name`, и дрилл валил бы себя своей же пробой.
base_or_skip env GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$W" config user.name Дрилл
base_or_skip env GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$W" config user.email drill@local
base_or_skip g add -A
base_or_skip g commit -q -m 'основание: контракт, вердикт критика, норма и роадмап'
ok 'шаг 1: контракт и вердикт критика v1 закоммичены'

# ── 2. заморозка v1 ───────────────────────────────────────────────────────────
if ! bash "$FREEZE" contracts/001-x.md "контракт стабилен" "$W" > "$out" 2>&1; then
  otkaz 'заморозка v1' "$?" "$out"
fi
grep -qx 'v1' "$out" || otkaz 'заморозка v1 напечатала не v1' 0 "$out"
ok 'шаг 2: freeze_contract.sh выдал v1'

# ── 3. устав введён ───────────────────────────────────────────────────────────
base_or_skip g tag -a ustav/1 -m 'устав действует'
ok 'шаг 3: устав введён тегом ustav/1'

# ── 4. правка ОДНИМ коммитом: вердикт v2 и строка владельца ───────────────────
printf 'критерий уточнён по решению владельца\n' >> "$W/contracts/001-x.md"
printf 'accept\nвердикт критика v2\n' > "$W/verdicts/critic/contracts-001-v2.md"
base_or_skip g add -A
g commit -q -F - <<'MSG' || otkaz 'коммит правки со строкой владельца' "$?" "$out"
Контракт уточнён по решению владельца

РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/001-x.md критерий готовности расширен по прямому слову владельца
MSG
ok 'шаг 4: правка, вердикт v2 и строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ в ОДНОМ коммите'

# ── 5. заморозка v2 ───────────────────────────────────────────────────────────
if ! bash "$FREEZE" contracts/001-x.md "вторая версия по решению владельца" "$W" > "$out" 2>&1; then
  otkaz 'заморозка v2' "$?" "$out"
fi
grep -qx 'v2' "$out" || otkaz 'заморозка v2 напечатала не v2' 0 "$out"
ok 'шаг 5: freeze_contract.sh выдал v2'

# ── 6. оба барьера обязаны вернуть 0 ──────────────────────────────────────────
if ! bash "$FROZEN" "$W" > "$out" 2>&1; then
  otkaz 'check_contract_frozen.sh на законно изменённом контракте' "$?" "$out"
fi
grep -q 'заморожен v2' "$out" \
  || otkaz 'check_contract_frozen.sh вернул ноль, но не назвал проверенную версию' 0 "$out"
ok 'шаг 6а: check_contract_frozen.sh принял v2 и назвал её'

if ! bash "$CHARTER" "$W" > "$out" 2>&1; then
  otkaz 'check_charter.sh на правке с разрешением владельца' "$?" "$out"
fi
grep -q 'изменён с разрешения владельца: contracts/001-x.md' "$out" \
  || otkaz 'check_charter.sh вернул ноль, но разрешение в отчёте не названо — молчаливое принятие неотличимо от того, что барьер правки не заметил' 0 "$out"
ok 'шаг 6б: check_charter.sh принял правку и назвал разрешение'

printf '\nпроцедура принята целиком: шесть шагов, оба барьера зелёные и оба назвали предмет\n' >&2
