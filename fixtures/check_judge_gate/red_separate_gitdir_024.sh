#!/usr/bin/env bash
# Красный контрпример блокера Б8 адверсария contracts-024-k10 (контракт 024,
# фикс ffd6a7f, предмет судится на 324ccaa):
#
#   Чекаут, созданный `git init --separate-git-dir=<внешний-gitdir>`, несёт
#   `.git` РЕГУЛЯРНЫЙ ФАЙЛ `gitdir: <path>`, а не каталог. Пред-фиксный
#   emit_dotgit_manifest начинался с `[ -d "$1/.git" ] || return 0` — для
#   этой формы dot-git половина манифеста ПУСТА ЦЕЛИКОМ: подмена активного
#   барьера hooks/pre-push, правка .git/config (резолвящегося во внешний
#   gitdir) невидимы НИ для porcelain (он .git не судит), НИ для walk-а —
#   ложный rc 0 «чисто» при живой подмене. Ровно исходный инцидент 024.
#   Репро адверсария: /tmp/dev-harness-verify/k10_separate_gitdir_hook.sh,
#   k10_separate_gitdir.sh, k10_separate_gitdir_positive.sh (вердикт:
#   «separate-git-dir pre-push hook replacement: check rc=0»).
#   Это НЕ Н-95: Н-95 — worktree-чекаут и ложный rc 1 (безопасное
#   направление); здесь ложный rc 0 на основном чекауте.
#
# ФИКСТУРА ПРЕДЪЯВЛЯЕТ ЧЕТЫРЕ КОНТРОЛЯ:
#   * контроль 1 (честный отдельный-gitdir чекаут) — живой чекаут, ≥1 коммит,
#     tracked-файлы, pre-push существует; между снимком и сверкой ничего не
#     меняется → rc 0 «чисто» (проходит и на пред-фикс коде — не-фикс-кандидат).
#   * контроль 2 (позитивный на той же форме) — обычная ВИДИМАЯ untracked
#     утечка в отдельном-gitdir чекауте → rc 1, имя файла: слепа именно
#     dot-git половина, porcelain-половина жива (проходит и на пред-фикс
#     коде — позитивный контроль репро адверсария: вход конформный).
#   * контроль 3 (атака Б8 — подмена pre-push в resolved-gitdir) — хук
#     существует на снимке (`exit 1`), после снимка заменён на `exit 0` с
#     маркером → rc 1, имя `.git/hooks/pre-push` в выводе.
#   * контроль 4 (атака Б8, носитель 2 — правка resolved-gitdir/config) —
#     после снимка `git config` пишет ключ во ВНЕШНИЙ gitdir → rc 1, имя
#     `.git/config` в выводе.
#
# ЗАКРЫТИЕ КЛАССА (что делает контроли зелёными): emit_dotgit_manifest в
# scripts/check_no_leak.sh на коммите 324ccaa, строки 576-603 — в начале
# функции `[ -f "$gitdir" ]` (строка 586) распознаёт `.git`-ФАЙЛ, чтение
# через пинованный $CAT (строка 587), срез префикса `gitdir: ` (строка 591)
# и trailing newline (строка 592), относительный путь резолвится от $1
# (строки 593-596), канонизация `readlink -f` (строка 597), `gitdir="$resolved"`
# (строка 601); прежний ранний выход `[ -d "$gitdir" ] || return 0` — теперь
# строка 603, ПОСЛЕ резолва. Walk хеширует resolved-gitdir/hooks (строки
# 604-608), info (609-617) и config (618-628) под КЛЮЧАМИ `.git/hooks/...`
# и `.git/config` — подмена/правка меняет DOTGIT-sha ⇒ дельта ⇒ rc 1
# именованный. При откате фикса (резолв отсутствует, код 9db8251) walk
# выходит целиком ⇒ контроли 3/4 КРАСНЫ — регрессия ловится.
#
# Форма — по прецеденту red_symlink_target_content_024.sh: WORK вне дерева,
# TMPDIR в скратче, имена мусора случайны. Toy — ИМЕННО отдельный-gitdir
# чекаут (проверяется формой: `.git` — файл со строкой `gitdir: `).
# Имя ВНЕ case_*-глоба раннера НАМЕРЕННО (И-11 контракта 024).
#
# Коды возврата: 0 — все четыре контроля прошли (фикс работает); 1 —
#               именованный отказ (детектор отсутствует либо класс не
#               пойман — в т.ч. регрессия фикса Б8).
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

WORK="$(mktemp -d /tmp/red024-k10-b8-separate-gitdir.XXXXXX)"   # А-78: свежий WORK вне дерева
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

# Живой отдельный-gitdir чекаут toy: `git init --separate-git-dir` кладёт
# `.git`-ФАЙЛ; tracked-файл коммитится через него. pre-push <arg3:yes/no>
# создаётся ДО снимка в РЕЗОЛВНЕННОМ gitdir (для честной базы и атаки).
mk_sep() {  # <каталог-чекаута> <внешний-gitdir> <pre-push:da|net>
  mkdir -p "$1/scripts"
  printf '# toy spawn\n' > "$1/scripts/spawn_agent.sh"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git init -q --separate-git-dir="$2" -b main "$1"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$1" -c user.name=Фикстура -c user.email=fixture@local \
    -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$1" -c user.name=Фикстура -c user.email=fixture@local \
    -c commit.gpgsign=false -c core.hooksPath=/dev/null \
    commit -q -m 'toy sep'
  if [ "$3" = da ]; then
    printf '#!/bin/sh\nexit 1\n' > "$2/hooks/pre-push"
    chmod +x "$2/hooks/pre-push"
  fi
}

# Форма входа обязана быть отдельным-gitdir: `.git` — ФАЙЛ со строкой
# `gitdir: ` (иначе фикстура судит не тот класс — конформность входа,
# позитивный контроль репро адверсария k10_separate_gitdir_positive.sh).
prover_formy() {  # <каталог-чекаута>
  [ -f "$1/.git" ] || fail форма "отдельный-gitdir" \
    "$1/.git — не ФАЙЛ (ожидалась форма --separate-git-dir)"
  grep -q '^gitdir: ' "$1/.git" || fail форма "отдельный-gitdir" \
    "$1/.git без строки «gitdir: » — форма не воспроизводит класс Б8"
}

# ─── контроль 1: честный отдельный-gitdir чекаут → rc 0 «чисто» ─────────────
# Регрессионная защита «фикс не сломал штатный путь»: резолв gitdir и walk
# по нему на НЕизменяемом входе стабилен (снимок и сверка видят одинаковые
# DOTGIT-строки). Проходит и ДО фикса Б8 (walk пуст в обеих фазах).
K1="$WORK/v1_chestnyj_${RANDOM}"
GD1="$WORK/gd1_${RANDOM}"
mk_sep "$K1" "$GD1" da
prover_formy "$K1"
run_subj "$K1" --snapshot "$K1"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-1 "честный снимок" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
run_subj "$K1" --check "$K1"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-1 "честный отдельный-gitdir вход" \
  "rc=$SUBJ_RC (ожидался 0) — стабильный отдельный-gitdir чекаут дал ложную тревогу. Вывод: $SUBJ_OUT"
has "$P_CHISTO" || fail контроль-1 "честный отдельный-gitdir вход" \
  "нет маркера «$P_CHISTO». Вывод: $SUBJ_OUT"
ok контроль-1 "честный отдельный-gitdir чекаут (pre-push жив): rc 0 «чисто»"

# ─── контроль 2: позитивный — обычная видимая утечка на той же форме ────────
# МЕХАНИКА (позитивный контроль репро адверсария): у той же формы ловится
# ОБЫЧНАЯ untracked утечка через porcelain. Доказывает: краснота контролей
# 3/4 — именно про dot-git половину, а не про слепоту формы целиком.
K2="$WORK/v2_pozitiv_${RANDOM}"
GD2="$WORK/gd2_${RANDOM}"
mk_sep "$K2" "$GD2" net
prover_formy "$K2"
run_subj "$K2" --snapshot "$K2"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-2 "снимок" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
UT2="plain-leak-${RANDOM}.txt"
printf 'leak\n' > "$K2/$UT2"
run_subj "$K2" --check "$K2"
[ "$SUBJ_RC" -eq 1 ] || fail контроль-2 "видимая утечка в отдельном-gitdir" \
  "rc=$SUBJ_RC (ожидался 1) — porcelain-половина слепа на форме отдельного-gitdir (не та механика: класс Б8 про dot-git половину). Вывод: $SUBJ_OUT"
has "$P_ZAGR" || fail контроль-2 "видимая утечка в отдельном-gitdir" \
  "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
has "$UT2" || fail контроль-2 "видимая утечка в отдельном-gitdir" \
  "имя $UT2 не названо. Вывод: $SUBJ_OUT"
[ -f "$K2/$UT2" ] || fail контроль-2 "видимая утечка в отдельном-gitdir" \
  "утечка $UT2 физически исчезла с диска — сверка удалила чужой файл"
ok контроль-2 "видимая утечка на той же форме: rc 1, $UT2 назван"

# ─── контроль 3: атака Б8 — подмена pre-push в resolved-gitdir → rc 1 ───────
# МЕХАНИКА. Хук существует на снимке (`exit 1` — активный барьер). После
# снимка заменён на `exit 0` с маркером — НИКАКИХ других изменений. Porcelain
# пуст (хук в gitdir, не в рабочем дереве). ДО фикса Б8: dot-git половина
# пуста ⇒ дельта пуста ⇒ rc 0 «чисто» (репро k10_separate_gitdir_hook.sh —
# ровно исходный инцидент 024). ПОСЛЕ ФИКСА: резолв gitdir из `.git`-файла
# (scripts/check_no_leak.sh:586-601) + walk (строки 604-608) видят новый sha
# pre-push ⇒ rc 1, имя `.git/hooks/pre-push`.
K3="$WORK/v3_podmena_huka_${RANDOM}"
GD3="$WORK/gd3_${RANDOM}"
mk_sep "$K3" "$GD3" da
prover_formy "$K3"
run_subj "$K3" --snapshot "$K3"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-3 "снимок" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
printf '#!/bin/sh\nexit 0 # b8marker%s\n' "$RANDOM" > "$GD3/hooks/pre-push"
PORC="$(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$K3" status --porcelain -uall 2>/dev/null)"
if printf '%s' "$PORC" | grep -q .; then
  fail контроль-3 "подмена pre-push" \
    "porcelain НЕ пуст на входе атаки — не механика Б8. Porcelain: $PORC"
fi
run_subj "$K3" --check "$K3"
[ "$SUBJ_RC" -eq 1 ] || fail контроль-3 "подмена pre-push в resolved-gitdir" \
  "rc=$SUBJ_RC (ожидался 1) — подмена активного барьера pre-push во внешнем gitdir не поймана: .git-ФАЙЛ, walk вышел целиком ⇒ ложный «чисто» (блокер Б8 к10). Вывод: $SUBJ_OUT"
has "$P_ZAGR" || fail контроль-3 "подмена pre-push в resolved-gitdir" \
  "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
has ".git/hooks/pre-push" || fail контроль-3 "подмена pre-push в resolved-gitdir" \
  "имя .git/hooks/pre-push не названо. Вывод: $SUBJ_OUT"
if has "$P_CHISTO"; then
  fail контроль-3 "подмена pre-push в resolved-gitdir" \
    "вывод одновременно заявляет чисто при rc=1. Вывод: $SUBJ_OUT"
fi
ok контроль-3 "подмена pre-push в resolved-gitdir: rc 1, .git/hooks/pre-push назван"

# ─── контроль 4: атака Б8, носитель 2 — правка resolved-gitdir/config ───────
# МЕХАНИКА. После снимка `git config` пишет нейтральный ключ — файл
# `<внешний-gitdir>/config` меняется, рабочий ДЕРЕВО нет, porcelain пуст.
# ДО фикса Б8: rc 0 «чисто» (репро k10_separate_gitdir.sh). ПОСЛЕ ФИКСА:
# DOTGIT-строка `.git/config` (scripts/check_no_leak.sh:621-627 по
# резолвнутому gitdir) меняет sha ⇒ rc 1, имя `.git/config`.
K4="$WORK/v4_pravka_konfiga_${RANDOM}"
GD4="$WORK/gd4_${RANDOM}"
mk_sep "$K4" "$GD4" net
prover_formy "$K4"
run_subj "$K4" --snapshot "$K4"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-4 "снимок" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$K4" config red024.b8-marker "proverka-${RANDOM}"
PORC="$(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$K4" status --porcelain -uall 2>/dev/null)"
if printf '%s' "$PORC" | grep -q .; then
  fail контроль-4 "правка resolved-gitdir/config" \
    "porcelain НЕ пуст на входе атаки — не механика Б8. Porcelain: $PORC"
fi
run_subj "$K4" --check "$K4"
[ "$SUBJ_RC" -eq 1 ] || fail контроль-4 "правка resolved-gitdir/config" \
  "rc=$SUBJ_RC (ожидался 1) — правка config внешнего gitdir не поймана: .git-ФАЙЛ, walk вышел целиком ⇒ ложный «чисто» (блокер Б8 к10, носитель 2). Вывод: $SUBJ_OUT"
has "$P_ZAGR" || fail контроль-4 "правка resolved-gitdir/config" \
  "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
has ".git/config" || fail контроль-4 "правка resolved-gitdir/config" \
  "имя .git/config не названо. Вывод: $SUBJ_OUT"
if has "$P_CHISTO"; then
  fail контроль-4 "правка resolved-gitdir/config" \
    "вывод одновременно заявляет чисто при rc=1. Вывод: $SUBJ_OUT"
fi
ok контроль-4 "правка resolved-gitdir/config: rc 1, .git/config назван"

printf 'red_separate_gitdir_024: 4 контроля зелены (блокер Б8 к10 — .git-файл/--separate-git-dir: dot-git половина манифеста жива, оба носителя ловятся)\n' >&2
exit 0
