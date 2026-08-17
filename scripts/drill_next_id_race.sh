#!/usr/bin/env bash
# Дрилл: атомарность выдачи — два вызова подряд дают РАЗНЫЕ номера, и каждый с тегом.
#
# Заведён потому, что анти-плацебо доказывает только КРАСНОЕ, а уникальность выдачи
# зелёная по построению: следующий номер по определению отличается от предыдущего.
# Фикстура не может это выразить иначе как подменой барьера. Дрилл переворачивает
# полярность: он требует от настоящего `next_id.sh` двух разных номеров, и предъявляется
# сам красным через фикстуру с подставным `next_id.sh`, который выдаёт один и тот же
# номер. Образец — `drill_protected_exception.sh` и его фикстура.
#
# Барьер берётся РЯДОМ С СОБОЙ (`$(dirname $0)/next_id.sh`) намеренно: так подмена
# подставного корня работает без флагов, и дрилл проверяет тот барьер, который лежит
# вместе с ним, а не тот, который случайно нашёлся в PATH. Дрилл зовёт скрипт с явным
# корнем — своим временным репозиторием — потому что без явного корня скрипт работал бы
# на основном дереве, и его регистр уже содержал бы `005` и `006`.
#
# Требуется РОВНО: первая выдача = max+1, вторая = max+2 (max — по состоянию ДО первого
# вызова, на пустом репозитории 0 → первая 001, вторая 002). Не просто «разные трёхзначные
# с тегами» — адверсарий измерил (находка 7 второго круга), что подставной скрипт,
# игнорирующий максимум и начинающий с 421, проходит прежний дрилл зелёным, и зелёный
# дрилл перестаёт доказывать, что выдача действительно отвечает на вопрос «следующий
# номер». Только привязка к max+1, max+2 делает зелёный прогон доказательством.
#
# ГЕРМЕТИЧНОСТЬ. Дрилл снимает `GIT_DIR`, `GIT_WORK_TREE`, `GIT_INDEX_FILE`,
# `GIT_OBJECT_DIRECTORY`, `GIT_ALTERNATE_OBJECT_DIRECTORIES`, `GIT_TEMPLATE_DIR` — и в
# своём окружении, и в каждом вызове барьера. Адверсарий измерил (находка 6 второго
# круга): `GIT_DIR=<чужой>` делал дрилл зелёным, не создав `.git` в своей временной
# стойке, а теги уезжали в заранее выбранный `hostile-alt`. Так барьер подтверждал
# состояние не проверяемого репозитория.
#
#   bash scripts/drill_next_id_race.sh
#
# Коды возврата: 0 — атомарность держится, 1 — гонка или сбой, 2 — нечем проверить.
set -euo pipefail

# ── ГЕРМЕТИЧНОЕ ОКРУЖЕНИЕ GIT ────────────────────────────────────────────────
# Снимаем шесть переменных окружения, которые перенаправляют `git` в чужой репозиторий
# сильнее, чем `-C "$W"` (см. шапку). Каждый вложенный вызов git и barrier наследует
# окружение, и без `unset` внешний `GIT_DIR=<чужой>` подменяет предмет.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
BARRIER="$HERE/next_id.sh"

[ -f "$BARRIER" ] || { printf 'NOT_IMPLEMENTED: рядом нет next_id.sh — нечего прогонять\n' >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

mkdir -p "$ROOT/tmp"
W="$(mktemp -d "$ROOT/tmp/drill-race.XXXXXX")"
# Уборка за собой — не аккуратность, а предмет: без этого каждый прогон оставлял каталог в
# `./tmp`, и одиннадцать таких нашлось руками, а не механизмом. Барьер, мусорящий в дереве, сам
# становится источником шума, в котором тонут находки.
trap 'rm -rf "$W"' EXIT
# Герметичное окружение для вложенных `git`: `GIT_CONFIG_*` в `/dev/null` отрезает
# глобальные и системные `commit.gpgsign`/`core.hooksPath` от хост-машины (адверсарий
# на механизме 4 измерил, что без этого коммит не создаётся и барьер выходит 128).
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

g() {
  env -u GIT_DIR -u GIT_WORK_TREE -u GIT_INDEX_FILE \
      -u GIT_OBJECT_DIRECTORY -u GIT_ALTERNATE_OBJECT_DIRECTORIES -u GIT_TEMPLATE_DIR \
      GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
      git -C "$W" -c user.name=Дрилл -c user.email=drill@local \
          -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}

# Локальный конфиг в $W, чтобы тег из barrier (отдельный `git tag`, без `-c user.name`)
# нашёл идентичность. Иначе `git tag` унаследует глобальный конфиг, отрезанный в
# герметичном окружении, и упадёт «empty ident name» (находка адверсария на механизме 4).
# Пишем ПОСЛЕ `init`: запись в `git config user.name` до init создаёт .git/config,
# который `init` тут же перезаписывает.
mkdir -p "$W/plans"
g init -q -b main
g config user.name  Дрилл
g config user.email drill@local
g commit --allow-empty -q -m 'основание'

# ── ВЫЧИСЛЕНИЕ ОЖИДАНИЯ ДО ПЕРВОГО ВЫЗОВА ───────────────────────────────────
# max — максимальный номер, уже занятый в реестре `id/PLAN/*`. На пустом стенде max=0,
# ожидаемая первая выдача 001, вторая 002. Если в `$W` остались чужие теги
# (унаследованные от прежнего прогона — `mktemp` даёт уникальный путь, но защита всё
# равно стоит), max отражает их, и ожидания сдвигаются. Так дрилл доказывает именно
# «следующий по порядку», а не «что-то разное».
expected_max=0
while IFS= read -r tag; do
  [ -n "$tag" ] || continue
  if [[ "$tag" =~ id/[^/]+/([0-9]+)$ ]]; then
    m=$((10#${BASH_REMATCH[1]}))
    [ "$m" -gt "$expected_max" ] && expected_max="$m"
  fi
done < <(g for-each-ref --format='%(refname:short)' 'refs/tags/id/PLAN/' 2>/dev/null || true)

expected_first=$(printf '%03d' $((expected_max + 1)))
expected_second=$(printf '%03d' $((expected_max + 2)))

out="$W/out.txt"
: > "$out"

set +e
first=$(env -u GIT_DIR -u GIT_WORK_TREE -u GIT_INDEX_FILE \
          -u GIT_OBJECT_DIRECTORY -u GIT_ALTERNATE_OBJECT_DIRECTORIES -u GIT_TEMPLATE_DIR \
          GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
          bash "$BARRIER" "$W" PLAN 2>>"$out")
rc1=$?
second=$(env -u GIT_DIR -u GIT_WORK_TREE -u GIT_INDEX_FILE \
           -u GIT_OBJECT_DIRECTORY -u GIT_ALTERNATE_OBJECT_DIRECTORIES -u GIT_TEMPLATE_DIR \
           GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
           bash "$BARRIER" "$W" PLAN 2>>"$out")
rc2=$?
set -e

if [ "$rc1" -ne 0 ] || [ "$rc2" -ne 0 ]; then
  printf 'ОТКАЗ: выдача упала — первый=%d, второй=%d. Вывод:\n' "$rc1" "$rc2" >&2
  sed 's/^/  | /' "$out" >&2
  exit 1
fi

# Первая выдача — РОВНО max+1. Это закрывает подмену «случайный старт»: подставной
# `next_id.sh`, начинающий с 421 (находка 7 второго круга), здесь краснеет с названной
# причиной, а не проходит по «разные трёхзначные, оба с тегами».
if [ "$first" != "$expected_first" ]; then
  printf 'ОТКАЗ: первая выдача %s, ожидалась %s — на пустом репозитории первая выдача обязана быть max+1 (%s)\n' \
    "$first" "$expected_first" "$expected_first" >&2
  exit 1
fi

# Вторая выдача — РОВНО max+2. Это закрывает подмену «тот же номер» (прежний дрилл её
# ловил сравнением first==second), но через явную привязку к порядку, а не через побочный
# признак: подставной скрипт, выдающий 001 и 002 (тоже разные), теперь обязан ещё и
# начинать с max+1, и зацикливаться на 001 не пройдёт.
if [ "$second" != "$expected_second" ]; then
  printf 'ОТКАЗ: вторая выдача %s, ожидалась %s — две выдачи подряд обязаны быть max+1 и max+2 (%s и %s)\n' \
    "$second" "$expected_second" "$expected_first" "$expected_second" >&2
  exit 1
fi

# Регистр — теги. Без тега номер не выдан: «история выдачи» — это и есть теги.
for n in "$first" "$second"; do
  if ! g show-ref --tags --quiet -- "refs/tags/id/PLAN/$n"; then
    printf 'ОТКАЗ: номер %s выдан без тега резервации id/PLAN/%s\n' "$n" "$n" >&2
    exit 1
  fi
done

printf '  ok   атомарность выдачи: %s и %s — max+1 и max+2 от пустого репозитория, оба с тегами\n' \
  "$first" "$second" >&2