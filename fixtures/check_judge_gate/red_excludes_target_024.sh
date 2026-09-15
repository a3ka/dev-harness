#!/usr/bin/env bash
# Красный контрпример блокера Б7 адверсария contracts-024-k10 (контракт 024,
# фикс ffd6a7f, предмет судится на 324ccaa):
#
#   `core.excludesFile` указывает на ВНЕШНИЙ файл правил. `git status
#   --porcelain` НЕ показывает файлы под новыми правилами, а `.git/config`
#   стабилен — ключ выставлен ДО снимка, после мутируются ТОЛЬКО байты цели.
#   dot-git walk цели не касается (цель ВНЕ .git), WTIGNORE не при чём (это не
#   `.gitignore` рабочего дерева), INDEXFLAG не при чём (бит не ставится) ⇒
#   дельта пуста ⇒ `--check` объявляет «чисто» при живой утечке. Класс — тот
#   же, что Б1 ревью v1 (`.git/info/exclude`) и Б3 к8 (байты ЦЕЛИ симлинка),
#   но носитель — строка конфигурации, а не симлинк и не файл в .git/info.
#   Репро адверсария: /tmp/dev-harness-verify/k10_external_exclude.sh
#   (вердикт: «external core.excludesFile target mutation: check rc=0»).
#
# ФИКСТУРА ПРЕДЪЯВЛЯЕТ ТРИ КОНТРОЛЯ:
#   * контроль 1 (честный вход при живом excludesFile) — правило задано ДО
#     снимка, цель НЕ мутирует, утечек нет → rc 0 «чисто»: строка
#     DOTGIT:EXCLUDES стабильна на честном входе, ложных тревог нет
#     (проходит и на пред-фикс коде — не-фикс-кандидат).
#   * контроль 2 (атака Б7 — мутация ТОЛЬКО байтов цели) — после снимка в
#     цель пишется имя будущей утечки и создаётся сама утечка в корне →
#     rc 1, ИМЯ ЦЕЛИ в выводе, утечка физически на диске, `.git/config`
#     не тронут.
#   * контроль 3 (атака Б7, носитель 2 — цель-СИМВОЛКА) — core.excludesFile
#     задан симлинком на внешний файл; после снимка мутируют БАЙТЫ ЦЕЛИ
#     симлинка (сама ссылка стабильна) → rc 1, имя цели-симлинка в выводе.
#
# ЗАКРЫТИЕ КЛАССА (что делает контроли зелёными): emit_dotgit_manifest в
# scripts/check_no_leak.sh на коммите 324ccaa, ветка Б7 — строки 629-670:
# `git config --get core.excludesFile` (строка 645) через пинованный $GIT с
# уже снятыми HOME/GIT_CONFIG_GLOBAL/GIT_CONFIG_SYSTEM/GIT_CONFIG_COUNT (это
# же снятие — строки 200-208) читает ТОЛЬКО локальный .git/config; резолв
# пути — относительный от $1, абсолютный как есть (строки 648-651); sha256
# БАЙТОВ цели (строка 653) отдельной строкой манифеста
# `DOTGIT:EXCLUDES:<sha>\t<путь-цели>` (строка 658); несуществующая либо
# нечитаемая цель — маркер DOTGIT:EXCLUDES:UNREADABLE (строка 663), чтобы
# изменение состояния цели не молчало. Мутация байтов цели меняет sha ⇒
# дельта ⇒ rc 1 именованный. Цель-симлинк хешируется по open(2) — git и
# детектор видят одни и те же байты. При откате фикса (ветка 629-670
# отсутствует, пред-фикс блоб 9db8251) EXCLUDES-строки в манифесте нет,
# porcelain слеп (правило применилось) ⇒ дельта пуста ⇒ rc 0 «чисто» ⇒
# контроли 2/3 КРАСНЫ (фикстура падает именованным ОТКАЗом) — регрессия
# ловится.
#
# Форма — по прецеденту red_symlink_target_content_024.sh: собственный WORK
# вне дерева, TMPDIR редиректится в WORK, имена мусора случайны КАЖДЫЙ прогон,
# toy-репозитории только `git init` (НЕ worktree-чекаут, грань Н-95 вне
# предмета). Имя ВНЕ case_*-глоба раннера НАМЕРЕННО (И-11 контракта 024).
#
# Коды возврата: 0 — все три контроля прошли (фикс работает); 1 — именованный
#               отказ (детектор отсутствует либо класс не пойман — в т.ч.
#               регрессия фикса Б7).
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
SUBJ="$REPO/scripts/check_no_leak.sh"

[ -f "$SUBJ" ] || {
  printf 'ОТКАЗ: детектор отсутствует — scripts/check_no_leak.sh\n' >&2
  exit 1
}

# ЕДИНЫЙ источник фраз (Демаркация 024) — побайтово во всех проверках ниже.
P_ZAGR='основной чекаут загрязнён'
P_CHISTO='основной чекаут чист'

WORK="$(mktemp -d /tmp/red024-k10-b7-excludes-target.XXXXXX)"   # А-78: свежий WORK вне дерева
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/snaps"
export TMPDIR="$WORK/snaps"                       # снимки субъекта — в скратч прогона

ok()   { printf '  ok   %s (%s)\n' "$1" "$2" >&2; }
fail() { printf 'ОТКАЗ %s (%s): %s\n' "$1" "$2" "$3" >&2; exit 1; }

# Запуск субъекта: cwd=arg1, аргументы дальше — rc без пайпов (Н-84/Н-85).
run_subj() {
  local cwd="$1"; shift
  SUBJ_OUT="$( cd "$cwd" && bash "$SUBJ" "$@" 2>&1 )" && SUBJ_RC=0 || SUBJ_RC=$?
}
has() { printf '%s\n' "$SUBJ_OUT" | grep -qF -- "$1"; }

# Живой git-чекаут toy: tracked-файл (канал ночи). Глобальный конфиг git
# изолируется на КАЖДОМ вызове — fixtures не зависят от машины прогона.
mk_main() {  # <каталог>
  mkdir -p "$1/scripts"
  printf '# toy spawn\n' > "$1/scripts/spawn_agent.sh"
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

# Механика класса Б7: правило в ЦЕЛИ прячет утечку от porcelain. Если git
# УТЕЧКУ ВИДИТ — вход не воспроизводит класс, фикстура обязана отказаться,
# а не краснеть по чужой причине.
porcelain_vidit() {  # <каталог> <имя>
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$1" status --porcelain -uall 2>/dev/null | grep -qF -- "$2"
}

# ─── контроль 1: честный вход при живом excludesFile → rc 0 «чисто» ───────────
# Регрессионная защита «фикс не сломал штатный путь»: правило задано ДО
# снимка, цель существует и НЕ мутирует — строка DOTGIT:EXCLUDES должна быть
# СТАБИЛЬНОЙ между snapshot и check (ложных тревог нет). Проходит и ДО фикса
# Б7 (EXCLUDES-строки просто нет). При регрессии фикса продолжают проходить
# контроль 1 и падают 2/3 — разделение «не сломал» / «закрывает».
K1="$WORK/v1_chestnyj_${RANDOM}"
mk_main "$K1"
EXT1="$WORK/vnesh_pravila_${RANDOM}"
mkdir -p "$EXT1"
printf '' > "$EXT1/rules"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$K1" config core.excludesFile "$EXT1/rules"
run_subj "$K1" --snapshot "$K1"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-1 "честный снимок" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
run_subj "$K1" --check "$K1"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-1 "честный вход при excludesFile" \
  "rc=$SUBJ_RC (ожидался 0) — стабильная цель core.excludesFile дала ложную тревогу. Вывод: $SUBJ_OUT"
has "$P_CHISTO" || fail контроль-1 "честный вход при excludesFile" \
  "нет маркера «$P_CHISTO». Вывод: $SUBJ_OUT"
ok контроль-1 "честный вход при живом excludesFile: rc 0 «чисто»"

# ─── контроль 2: атака Б7 — мутация ТОЛЬКО байтов цели → rc 1 ────────────────
# МЕХАНИКА. Правило выставлено ДО снимка (пустая цель), `.git/config` после
# этого НЕ трогается — его sha в манифесте стабилен. После снимка меняются
# ТОЛЬКО байты цели (туда пишется имя будущей утечки) и создаётся сама утечка
# в корне. Git применяет правило → porcelain утечку НЕ видит. ДО фикса Б7:
# дельта пуста ⇒ rc 0 «чисто» (репро k10_external_exclude.sh адверсария к10).
# ПОСЛЕ ФИКСА: EXCLUDES-строка (scripts/check_no_leak.sh:658, sha256 байтов
# цели со строки 653) меняет sha ⇒ дельта ⇒ rc 1, имя ЦЕЛИ в выводе.
K2="$WORK/v2_mutacija_celi_${RANDOM}"
mk_main "$K2"
EXT2="$WORK/vnesh_cel_${RANDOM}"
mkdir -p "$EXT2"
printf '' > "$EXT2/rules"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$K2" config core.excludesFile "$EXT2/rules"
run_subj "$K2" --snapshot "$K2"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-2 "снимок" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
UTECHKA2="utechka_b7_cel_${RANDOM}_${RANDOM}.tmp"
printf '%s\n' "$UTECHKA2" > "$EXT2/rules"
printf 'leak\n' > "$K2/$UTECHKA2"
# Sanity: утечка действительно НЕ отражается в porcelain — правило из цели
# применилось (иначе это не механика Б7).
if porcelain_vidit "$K2" "$UTECHKA2"; then
  fail контроль-2 "мутация байтов цели" \
    "правило из цели НЕ применилось — porcelain видит утечку, вход не воспроизводит класс Б7"
fi
run_subj "$K2" --check "$K2"
[ "$SUBJ_RC" -eq 1 ] || fail контроль-2 "мутация байтов цели" \
  "rc=$SUBJ_RC (ожидался 1) — мутация внешней цели core.excludesFile не поймана: .git/config стабилен, porcelain слеп (правило скрыло утечку) ⇒ ложный «чисто» (блокер Б7 к10). Вывод: $SUBJ_OUT"
has "$P_ZAGR" || fail контроль-2 "мутация байтов цели" \
  "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
has "$EXT2/rules" || fail контроль-2 "мутация байтов цели" \
  "имя цели $EXT2/rules не названо. Вывод: $SUBJ_OUT"
if has "$P_CHISTO"; then
  fail контроль-2 "мутация байтов цели" \
    "вывод одновременно заявляет чисто при rc=1. Вывод: $SUBJ_OUT"
fi
[ -f "$K2/$UTECHKA2" ] || fail контроль-2 "мутация байтов цели" \
  "утечка $UTECHKA2 физически исчезла с диска — сверка удалила чужой файл"
ok контроль-2 "мутация ТОЛЬКО байтов цели: rc 1, цель $EXT2/rules названа"

# ─── контроль 3: атака Б7, носитель 2 — цель-СИМВОЛКА → rc 1 ────────────────
# МЕХАНИКА. core.excludesFile задан СИМВОЛКОЙ на внешний файл: значение
# конфигурации (строка-путь ссылки) стабильно, сама ссылка не трогается —
# после снимка мутируют БАЙТЫ ЦЕЛИ ссылки. Git следует симлинку и применяет
# правило; open(2) в sha256sum (строка 653) идёт по тем же байтам ⇒ дельта
# EXCLUDES-строки ⇒ rc 1. ДО фикса Б7: rc 0 «чисто» — тот же класс, что Б3
# (мутация байтов цели), но носитель — строка конфигурации.
K3="$WORK/v3_cel_simlinka_${RANDOM}"
mk_main "$K3"
EXT3="$WORK/vnesh_simlink_${RANDOM}"
mkdir -p "$EXT3"
printf '' > "$EXT3/rules-real"
ln -s "$EXT3/rules-real" "$EXT3/rules-link"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$K3" config core.excludesFile "$EXT3/rules-link"
run_subj "$K3" --snapshot "$K3"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-3 "снимок" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
UTECHKA3="utechka_b7_sim_${RANDOM}_${RANDOM}.tmp"
printf '%s\n' "$UTECHKA3" > "$EXT3/rules-real"
printf 'leak\n' > "$K3/$UTECHKA3"
if porcelain_vidit "$K3" "$UTECHKA3"; then
  fail контроль-3 "мутация байтов цели симлинка" \
    "правило из цели-симлинка НЕ применилось — porcelain видит утечку, вход не воспроизводит класс Б7"
fi
run_subj "$K3" --check "$K3"
[ "$SUBJ_RC" -eq 1 ] || fail контроль-3 "мутация байтов цели симлинка" \
  "rc=$SUBJ_RC (ожидался 1) — мутация байтов цели-симлинка core.excludesFile не поймана: ссылка стабильна, .git/config стабилен, porcelain слеп ⇒ ложный «чисто» (блокер Б7 к10, носитель 2). Вывод: $SUBJ_OUT"
has "$P_ZAGR" || fail контроль-3 "мутация байтов цели симлинка" \
  "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
has "$EXT3/rules-link" || fail контроль-3 "мутация байтов цели симлинка" \
  "имя цели-симлинка $EXT3/rules-link не названо. Вывод: $SUBJ_OUT"
if has "$P_CHISTO"; then
  fail контроль-3 "мутация байтов цели симлинка" \
    "вывод одновременно заявляет чисто при rc=1. Вывод: $SUBJ_OUT"
fi
[ -f "$K3/$UTECHKA3" ] || fail контроль-3 "мутация байтов цели симлинка" \
  "утечка $UTECHKA3 физически исчезла с диска — сверка удалила чужой файл"
ok контроль-3 "мутация байтов цели-симлинка: rc 1, $EXT3/rules-link назван"

printf 'red_excludes_target_024: 3 контроля зелены (блокер Б7 к10 — мутация внешней цели core.excludesFile ловится по обоим носителям)\n' >&2
exit 0
