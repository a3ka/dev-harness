#!/usr/bin/env bash
# Дрилл: ЧЕСТНЫЙ git-mv байт-в-байт действительно признаётся переносом.
#
# Заведён по той же причине, что drill_protected_exception.sh (контракт 005): механизм
# анти-плацебо доказывает только КРАСНОЕ, и зелёная ветвь переноса без дрилла осталась бы
# непроверенной. Без дрилла перенос «работает» в единственном случае, где его никто не
# зеленел: лес и защита выглядят целыми, а инвариант «существовал → существует» мог быть
# нарушен молча — например, при ветке, где `check_protected.sh` всегда возвращает ноль по
# построению. Прецедент 005 тот же; контракт 039, §Семантика п.5 объявляет этот дрилл
# отдельной строкой проводки рядом с дриллом исключения.
#
# Дрилл проверяет ОБЕ формы переноса — ВНУТРИ области (verdicts/adversary/v-1.md →
# v-2.md, байт-в-байт) и НАРУЖУ области (plans/001-p.md → notes/001-p.md, байт-в-байт).
# Форма «наружу» — основная: блоб живёт на HEAD за пределами области защиты, и инвариант
# переноса требует признания по любому пути, не только внутри `verdicts/…/`. Форма
# «внутри» — симметричная, держит зелёную ветвь и при возврате носителя в область.
#
# Сам дрилл предъявляется красным фикстурой `case_perenos_ne_priznan.sh`: подставной
# барьер рядом с дриллом НЕ признаёт перенос и краснеет — дискриминация «настоящий
# барьер rc0 / стаб rc1» по тому же прецеденту, что `case_iskljuchenie_ne_prinjato.sh`.
#
# Барьер берётся РЯДОМ С СОБОЙ (`$(dirname $0)/check_protected.sh`) намеренно: так
# подмена подставного корня работает без флагов, и дрилл проверяет тот барьер, который
# лежит вместе с ним, а не тот, который случайно нашёлся в PATH.
#
#   bash scripts/drill_protected_rename.sh
#
# Коды возврата: 0 — перенос распознан в обоих случаях, 1 — не распознан, 2 — нечем
# проверить.
set -euo pipefail

# Унаследованные git-переменные подменяют построение подставной истории ДО запуска
# проверяемого барьера (прецедент дрилла исключения). Здесь по той же причине: переменные
# снимаются, а не обходятся.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
BARRIER="$HERE/check_protected.sh"

[ -f "$BARRIER" ] || { printf 'NOT_IMPLEMENTED: рядом нет check_protected.sh — нечего прогонять\n' >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

mkdir -p "$ROOT/tmp"
W="$(mktemp -d "$ROOT/tmp/drill-rename.XXXXXX")"
trap 'rm -rf "$W"' EXIT

# ГЕРМЕТИЧНОСТЬ, а не аккуратность. Тот же прецедент дрилла исключения: внешний конфиг
# (commit.gpgsign без ключа, core.hooksPath отвергающий коммит) менял исход ДО запуска
# проверяемого барьера — здесь по той же логике.
g() {
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$W" \
      -c user.name=Дрилл -c user.email=drill@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      -c init.defaultBranch=main "$@"
}

# Каждый случай строится в СВОЁМ mktemp-подкаталоге: один общий репозиторий для двух
# переносов смешал бы их деревья, и проверка первого переноса задела бы второй. Изоляция
# каталогов — не аккуратность, а отдельное измерение «блоб каждого переноса живёт под
# нужным путём именно в этом репозитории».
case_in_place() {  # <каталог-в-W> → прогоняет барьер на нём, печатает ОК/ОТКАЗ
  local sub="$1" missing="$2" ok_line="$3"
  local out="$sub/out.txt"
  set +e
  bash "$BARRIER" "$sub" > "$out" 2>&1
  local rc=$?
  set -e
  if [ "$rc" -ne 0 ]; then
    printf 'ОТКАЗ: перенос не распознан — барьер вернул %d на случае «%s» (%s)\n' "$rc" "$4" "$sub" >&2
    sed 's/^/  | /' "$out" >&2
    return 1
  fi
  if ! grep -qF -e "$ok_line" "$out"; then
    printf 'ОТКАЗ: перенос не распознан — барьер вернул ноль на «%s», но строки «%s» в отчёте нет\n' "$4" "$ok_line" >&2
    printf 'Молчаливое признание неотличимо от того, что барьер вовсе не заметил пропажи.\n' >&2
    sed 's/^/  | /' "$out" >&2
    return 1
  fi
  printf '  ok   %s — %s\n' "$4" "$ok_line" >&2
  return 0
}

# Случай 1: перенос ВНУТРИ области — вердикт переименован внутри verdicts/adversary/.
# Блоб байт-в-байт, инвариант «существовал → существует на HEAD» выполнен.
S1="$W/inside"
mkdir -p "$S1/roles" "$S1/verdicts/adversary" "$S1/plans"
printf -- '---\nname: adversary\nverdict: verdicts/adversary/\n---\n' > "$S1/roles/adversary.md"
printf 'вердикт v-1\n' > "$S1/verdicts/adversary/v-1.md"
printf 'план\n'        > "$S1/plans/001-p.md"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$S1" \
  || { printf 'NOT_IMPLEMENTED: не удалось построить подставную историю (git init) — окружение git мешает\n' >&2; exit 2; }
(
  cd "$S1"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -c user.name=Дрилл -c user.email=drill@local \
        -c commit.gpgsign=false -c core.hooksPath=/dev/null \
        add -A
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -c user.name=Дрилл -c user.email=drill@local \
        -c commit.gpgsign=false -c core.hooksPath=/dev/null \
        commit -q -m 'основание'
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -c user.name=Дрилл -c user.email=drill@local \
        -c commit.gpgsign=false -c core.hooksPath=/dev/null \
        mv verdicts/adversary/v-1.md verdicts/adversary/v-2.md
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -c user.name=Дрилл -c user.email=drill@local \
        -c commit.gpgsign=false -c core.hooksPath=/dev/null \
        commit -q -m 'вердикт переименован байт-в-байт'
) || { printf 'NOT_IMPLEMENTED: не удалось построить историю переноса внутри области — окружение git мешает\n' >&2; exit 2; }
case_in_place "$S1" 'verdicts/adversary/v-1.md' \
  'перенесён, контент жив на HEAD: verdicts/adversary/v-1.md' \
  'перенос внутри области (v-1.md → v-2.md)' || exit 1

# Случай 2: перенос НАРУЖУ области — план вынесен из plans/ в notes/, блоб байт-в-байт.
# Это основной случай контракта 039: блоб перенесённого артефакта живёт на HEAD ВНЕ
# области защиты, и инвариант обязан признать перенос по любому пути.
S2="$W/outside"
mkdir -p "$S2/roles" "$S2/verdicts/adversary" "$S2/plans"
printf -- '---\nname: adversary\nverdict: verdicts/adversary/\n---\n' > "$S2/roles/adversary.md"
printf 'вердикт v-1\n' > "$S2/verdicts/adversary/v-1.md"
printf 'план\n'        > "$S2/plans/001-p.md"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$S2" \
  || { printf 'NOT_IMPLEMENTED: не удалось построить подставную историю (git init) — окружение git мешает\n' >&2; exit 2; }
(
  cd "$S2"
  mkdir -p notes
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -c user.name=Дрилл -c user.email=drill@local \
        -c commit.gpgsign=false -c core.hooksPath=/dev/null \
        add -A
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -c user.name=Дрилл -c user.email=drill@local \
        -c commit.gpgsign=false -c core.hooksPath=/dev/null \
        commit -q -m 'основание'
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -c user.name=Дрилл -c user.email=drill@local \
        -c commit.gpgsign=false -c core.hooksPath=/dev/null \
        mv plans/001-p.md notes/001-p.md
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -c user.name=Дрилл -c user.email=drill@local \
        -c commit.gpgsign=false -c core.hooksPath=/dev/null \
        commit -q -m 'план вынесен в заметки'
) || { printf 'NOT_IMPLEMENTED: не удалось построить историю переноса наружу — окружение git мешает\n' >&2; exit 2; }
case_in_place "$S2" 'plans/001-p.md' \
  'перенесён, контент жив на HEAD: plans/001-p.md' \
  'перенос наружу области (plans/001-p.md → notes/001-p.md)' || exit 1