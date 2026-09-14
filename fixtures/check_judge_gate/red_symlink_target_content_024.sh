#!/usr/bin/env bash
# Красный контрпример блокера Б3 адверсария к8 contracts-024-k8.md
# (правка-круг после 8748823, контракт 024):
#
#   emit_dotgit_manifest_walk для симлинка печатает ТОЛЬКО строку
#   `DOTGIT:SYMLINK:<readlink-цель>` — цель симлинка хешируется как СТРОКА,
#   не как БАЙТЫ. Уже существовавший на снимке симлинк
#   `.git/info/exclude -> ../hidden-exclude` сохраняет ту же SYMLINK-строку,
#   когда атакующий меняет БАЙТЫ цели: git следует симлинку, начинает
#   игнорировать утечку, `git status --porcelain -uall` пуст, dot-git
#   манифест без дельты ⇒ `--check` объявляет «чисто» при живой утечке.
#   Оба репро адверсария (k8_compound_link_probe.py — относительная цель
#   `../hidden-exclude` внутри .git; k8_dotgit_attack.py — абсолютная цель
#   вне канон-корня) дали ложный rc=0 «основной чекаут чист».
#
# ФИКСТУРА ПРЕДЪЯВЛЯЕТ ЧЕТЫРЕ КОНТРОЛЯ:
#   * контроль 1 (честный вход, без симлинков) — rc 0 «чисто»: фикс не
#     сломал штатный путь (проходит и на пред-фикс коде — не-фикс-кандидат).
#   * контроль 2 (позитивный при живом симлинке) — симлинк
#     `.git/info/exclude -> ../hidden-exclude` существует на снимке, затем
#     обычный видимый untracked БЕЗ правки цели → rc 1, имя файла в выводе:
#     симлинк-носитель сам по себе не ослепляет детектор (проходит и на
#     пред-фикс коде — позитивный контроль репро адверсария).
#   * контроль 3 (атака Б3, носитель 1 — ОТНОСИТЕЛЬНАЯ цель) — мутация
#     БАЙТОВ цели `../hidden-exclude` (файл ВНЕ .git/info и ВНЕ зоны walk,
#     ВНУТРИ канон-корня) + утечка, скрытая новым правилом → rc 1, имя
#     `.git/info/exclude` в выводе, утечка физически на диске.
#   * контроль 4 (атака Б3, носитель 2 — АБСОЛЮТНАЯ цель ВНЕ канон-корня) —
#     симлинк на файл второго каталога скратча (вне канон-корня субъекта
#     целиком), та же мутация байтов цели → rc 1, имя `.git/info/exclude`.
#     Два независимых носителя — по образцу двух репро адверсария к8.
#
# ЗАКРЫТИЕ КЛАССА (что делает эти контроли зелёными): emit_dotgit_manifest_walk
# в scripts/check_no_leak.sh ПОСЛЕ SYMLINK-строки (строки 493-523 на коммите
# 5a188af, функция emit_dotgit_manifest_walk) разрешает цель полностью через
# `readlink -f` (строка 510) и, если резолв ведёт в читаемый регулярный файл,
# добавляет ВТОРУЮ строку манифеста `DOTGIT:CONTENT:<sha256-байтов-цели>`
# (строка 520) ПО ТОМУ ЖЕ ключу-пути `.git/info/exclude`. Мутация байтов цели
# меняет CONTENT-sha ⇒ дельта ⇒ rc 1 именованный. При откате фикса (строки
# 493-523 сведены к голому `continue` после SYMLINK-строки, код c9f2797, диф
# 5a188af9 @@ -490,6 +490,37 @@) SYMLINK-строка стабильна, porcelain слеп
# (правило скрыло утечку) ⇒ дельта пуста ⇒ rc 0 «чисто» ⇒ контроли 3/4 КРАСНЫ
# (фикстура падает именованным ОТКАЗом) — регрессия ловится.
#
# Форма — по прецеденту red_dotgit_info_exclude_024.sh: собственный WORK вне
# дерева, TMPDIR редиректится в WORK, имена мусора случайны КАЖДЫЙ прогон,
# toy-репозитории только `git init` (каталог .git — НЕ worktree-чекаут,
# узкая грань Н-95 вне предмета). Имя ВНЕ case_*-глоба раннера НАМЕРЕННО
# (И-11 контракта 024; тот же прецедент).
#
# Коды возврата: 0 — все четыре контроля прошли (фикс работает); 1 —
#               именованный отказ (детектор отсутствует либо не поймал
#               класс — в т.ч. регрессия фикса Б3).
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
SUBJ="$REPO/scripts/check_no_leak.sh"

[ -f "$SUBJ" ] || {
  printf 'ОТКАЗ: детектор отсутствует — scripts/check_no_leak.sh (реализация за implementer после заморозки 024)\n' >&2
  exit 1
}

# ЕДИНЫЙ источник фраз (Демаркация 024) — побайтово во всех проверках ниже.
P_ZAGR='основной чекаут загрязнён'
P_CHISTO='основной чекаут чист'

WORK="$(mktemp -d /tmp/red024-k8-b3-symlink-target.XXXXXX)"   # А-78: свежий WORK вне дерева
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/snaps"
export TMPDIR="$WORK/snaps"                       # снимки субъекта — в скратч прогона

ok()   { printf '  ok   %s (%s)\n' "$1" "$2" >&2; }
fail() { printf 'ОТКАЗ %s (%s): %s\n' "$1" "$2" "$3" >&2; exit 1; }

# Запуск субъекта: cwd=arg2, аргументы дальше — rc без пайпов (Н-84/Н-85).
run_subj() {
  local cwd="$1"; shift
  SUBJ_OUT="$( cd "$cwd" && bash "$SUBJ" "$@" 2>&1 )" && SUBJ_RC=0 || SUBJ_RC=$?
}
has() { printf '%s\n' "$SUBJ_OUT" | grep -qF -- "$1"; }

# Живой git-чекаут toy: два tracked-файла (каналы ночи). НЕ создаём .git/info/
# до снимка — чтобы первая итерация контроля была действительно «честной».
mk_main() {  # <каталог>
  mkdir -p "$1/.githooks" "$1/scripts"
  printf '# toy hook\n'   > "$1/.githooks/pre-push"
  printf '# toy spawn\n'  > "$1/scripts/spawn_agent.sh"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git init -q -b main "$1"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$1" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$1" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      commit -q -m 'toy main'
}

# ─── контроль 1: честный вход (без симлинков) → rc 0 «чисто» ──────────────────
# Регрессионная защита «фикс не сломал штатный путь»: проходит и ДО фикса Б3
# (симлинков нет — правок нет). При регрессии фикса продолжают проходить
# контроли 1-2 и падают 3-4 — разделение «не сломал» / «закрывает».
K1="$WORK/v1_chestnyj_${RANDOM}"
mk_main "$K1"
run_subj "$K1" --snapshot "$K1"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-1 "честный снимок" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
run_subj "$K1" --check "$K1"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-1 "честный вход" \
  "rc=$SUBJ_RC (ожидался 0). Вывод: $SUBJ_OUT"
has "$P_CHISTO" || fail контроль-1 "честный вход" \
  "нет маркера «$P_CHISTO». Вывод: $SUBJ_OUT"
ok контроль-1 "честный вход без симлинков: rc 0 «чисто»"

# ─── контроль 2: позитивный — видимый untracked при живом симлинке → rc 1 ────
# МЕХАНИКА (позитивный контроль обоих репро адверсария): симлинк существует
# УЖЕ на снимке, но цель не мутирует — обычная видимая утечка ловится через
# porcelain. Доказывает: носитель-симлинк сам по себе детектор не ослепляет,
# краснота контролей 3/4 — именно про мутацию БАЙТОВ цели, не про симлинк.
K2="$WORK/v2_pozitiv_pri_simlinke_${RANDOM}"
mk_main "$K2"
# Цель — ВНЕ .git/info (walk её не хеширует как обычный файл .git/info/*) и
# ВНЕ .git/hooks, ВНУТРИ канон-корня: только симлинк-ветка может её увидеть.
printf '' > "$K2/.git/hidden-exclude"
rm -f "$K2/.git/info/exclude"
ln -s ../hidden-exclude "$K2/.git/info/exclude"
run_subj "$K2" --snapshot "$K2"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-2 "снимок" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
VIDIMYJ="vidimyj_${RANDOM}_${RANDOM}.tmp"
printf 'x\n' > "$K2/$VIDIMYJ"
run_subj "$K2" --check "$K2"
[ "$SUBJ_RC" -eq 1 ] || fail контроль-2 "видимый untracked при симлинке" \
  "rc=$SUBJ_RC (ожидался 1) — симлинк .git/info/exclude ослепил детектор для ОБЫЧНОЙ видимой утечки (не та механика: класс Б3 про мутацию цели). Вывод: $SUBJ_OUT"
has "$P_ZAGR" || fail контроль-2 "видимый untracked при симлинке" \
  "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
has "$VIDIMYJ" || fail контроль-2 "видимый untracked при симлинке" \
  "имя $VIDIMYJ не названо. Вывод: $SUBJ_OUT"
ok контроль-2 "видимый untracked при живом симлинке exclude: rc 1, $VIDIMYJ назван"
rm -f "$K2/$VIDIMYJ"
# Состояние вернулось к снимку (снимок писался без $VIDIMYJ; --check снимок
# не переписывает) — переснимок не нужен, атака контроля 3 идёт от той же базы.

# ─── контроль 3: атака Б3 носитель 1 — относительная цель ../hidden-exclude ───
# МЕХАНИКА. После снимка: меняем БАЙТЫ ЦЕЛИ (не симлинк!): правило в
# `.git/hidden-exclude`, туда же файл-утечку. Git следует симлинку →
# porcelain утечку НЕ видит; SYMLINK-строка манифеста (`../hidden-exclude`)
# НЕ меняется. ДО фикса Б3: дельта пуста ⇒ rc 0 «чисто» (репро
# k8_compound_link_probe.py адверсария к8). ПОСЛЕ ФИКСА: CONTENT-строка
# (scripts/check_no_leak.sh:520, sha256 байтов резолва `readlink -f` с
# строки 510) меняет sha ⇒ дельта ⇒ rc 1, имя `.git/info/exclude`.
UTECHKA3="utechka_b3_otn_${RANDOM}_${RANDOM}.tmp"
printf '%s\n' "$UTECHKA3" > "$K2/.git/hidden-exclude"
printf 'leak\n' > "$K2/$UTECHKA3"
# Sanity: утечка действительно НЕ отражается в porcelain — git следует
# симлинку и применяет правило цели (иначе это не механика Б3).
PORCELAIN="$(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$K2" status --porcelain -uall 2>/dev/null)"
if printf '%s' "$PORCELAIN" | grep -qF "$UTECHKA3"; then
  fail контроль-3 "sanity porcelain" \
    "утечка $UTECHKA3 ВИДНА в porcelain — правило цели симлинка не применилось, атака не воспроизведена"
fi
run_subj "$K2" --check "$K2"
[ "$SUBJ_RC" -eq 1 ] || fail контроль-3 "мутация байтов относительной цели" \
  "rc=$SUBJ_RC (ожидался 1) — мутация цели ../hidden-exclude не поймана: SYMLINK-строка стабильна, porcelain слеп (правило скрыло утечку) ⇒ ложный «чисто» (блокер Б3 к8). Вывод: $SUBJ_OUT"
has "$P_ZAGR" || fail контроль-3 "мутация байтов относительной цели" \
  "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
has ".git/info/exclude" || fail контроль-3 "мутация байтов относительной цели" \
  "имя .git/info/exclude не названо. Вывод: $SUBJ_OUT"
if has "$P_CHISTO"; then
  fail контроль-3 "мутация байтов относительной цели" \
    "ложный маркер «$P_CHISTO» при живой утечке. Вывод: $SUBJ_OUT"
fi
[ -f "$K2/$UTECHKA3" ] || fail контроль-3 "мутация байтов относительной цели" \
  "утечка $UTECHKA3 физически исчезла с диска — сверка удалила чужой файл"
ok контроль-3 "мутация байтов цели ../hidden-exclude (относительная, вне .git/info): rc 1, .git/info/exclude назван"

# ─── контроль 4: атака Б3 носитель 2 — абсолютная цель ВНЕ канон-корня ────────
# МЕХАНИКА. Свежий toy; цель симлинка — регулярный файл ВТОРОГО каталога
# скратча, ВНЕ канон-корня субъекта ЦЕЛИКОМ (walk не может дойти до него
# обходом дерева). После снимка — та же мутация байтов цели. ДО фикса Б3:
# rc 0 «чисто» (репро k8_dotgit_attack.py адверсария к8). ПОСЛЕ ФИКСА:
# `readlink -f` резолвит абсолютный путь (scripts/check_no_leak.sh:510),
# CONTENT-строка (строка 520) меняет sha ⇒ rc 1 именованный.
K4="$WORK/v4_abs_vne_kornya_${RANDOM}"
mk_main "$K4"
EXT="$WORK/vneshn_cel_${RANDOM}"     # второй каталог скратча — вне канон-корня $K4
mkdir -p "$EXT"
printf '' > "$EXT/rules"
rm -f "$K4/.git/info/exclude"
ln -s "$EXT/rules" "$K4/.git/info/exclude"
run_subj "$K4" --snapshot "$K4"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-4 "снимок" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
UTECHKA4="utechka_b3_abs_${RANDOM}_${RANDOM}.tmp"
printf '%s\n' "$UTECHKA4" > "$EXT/rules"
printf 'leak\n' > "$K4/$UTECHKA4"
PORCELAIN="$(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$K4" status --porcelain -uall 2>/dev/null)"
if printf '%s' "$PORCELAIN" | grep -qF "$UTECHKA4"; then
  fail контроль-4 "sanity porcelain" \
    "утечка $UTECHKA4 ВИДНА в porcelain — правило абсолютной цели не применилось, атака не воспроизведена"
fi
run_subj "$K4" --check "$K4"
[ "$SUBJ_RC" -eq 1 ] || fail контроль-4 "мутация байтов абсолютной цели" \
  "rc=$SUBJ_RC (ожидался 1) — мутация внешней абсолютной цели не поймана: SYMLINK-строка стабильна, porcelain слеп ⇒ ложный «чисто» (блокер Б3 к8, второй носитель). Вывод: $SUBJ_OUT"
has "$P_ZAGR" || fail контроль-4 "мутация байтов абсолютной цели" \
  "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
has ".git/info/exclude" || fail контроль-4 "мутация байтов абсолютной цели" \
  "имя .git/info/exclude не названо. Вывод: $SUBJ_OUT"
if has "$P_CHISTO"; then
  fail контроль-4 "мутация байтов абсолютной цели" \
    "ложный маркер «$P_CHISTO» при живой утечке. Вывод: $SUBJ_OUT"
fi
[ -f "$K4/$UTECHKA4" ] || fail контроль-4 "мутация байтов абсолютной цели" \
  "утечка $UTECHKA4 физически исчезла с диска — сверка удалила чужой файл"
ok контроль-4 "мутация байтов абсолютной цели вне канон-корня: rc 1, .git/info/exclude назван"

printf 'red_symlink_target_content_024: 4 контроля зелены (блокер Б3 к8 — мутация байтов цели симлинка .git/info/exclude ловится по обоим носителям)\n' >&2
exit 0
