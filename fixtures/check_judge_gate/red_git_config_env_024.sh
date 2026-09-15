#!/usr/bin/env bash
# Красный контрпример дефекта Н-96 адверсария contracts-024-k10 (контракт
# 024, фикс ffd6a7f, предмет судится на 324ccaa):
#
#   Детектор снимает GIT_CONFIG_GLOBAL/GIT_CONFIG_SYSTEM/GIT_CONFIG_NOSYSTEM
#   (и HOME/XDG_*) именно потому, что через них подставляется
#   core.excludesFile. Семейство GIT_CONFIG_COUNT + GIT_CONFIG_KEY_<n> +
#   GIT_CONFIG_VALUE_<n> даёт тот же эффект и НЕ снималось: pinнутый git
#   применяет env-конфиг во всех producer'ах, porcelain прячет утечку,
#   дельта пуста ⇒ ложный rc 0 «чисто». Досягаемость — контроль над
#   окружением вызова детектора, ровно та же, что у уже снимаемых
#   GIT_CONFIG_GLOBAL/GIT_CONFIG_SYSTEM.
#   Репро адверсария: /tmp/dev-harness-verify/k10_git_config_env.sh
#   (вердикт: «GIT_CONFIG_COUNT injected core.excludesFile: check rc=0»).
#
# ФИКСТУРА ПРЕДЪЯВЛЯЕТ ЧЕТЫРЕ КОНТРОЛЯ:
#   * контроль 1 (честный вход без env) — rc 0 «чисто» (проходит и на
#     пред-фикс коде — не-фикс-кандидат).
#   * контроль 2 (позитивный — утечка без env) — обычная видимая утечка →
#     rc 1, имя файла: porcelain-половина жива, краснота контроля 4 — именно
#     про env-канал (проходит и на пред-фикс коде).
#   * контроль 3 (стабильность под БЕЗОБРЕДНЫМ env) — GIT_CONFIG_COUNT=1 +
#     KEY_0/VALUE_0 на ОБОИХ вызовах, правила пусты и НЕ мутируют → rc 0:
#     снятие канала не даёт ложной тревоги (проходит и на пред-фикс коде —
#     env без мутации ничего не прячет).
#   * контроль 4 (атака Н-96) — env на ОБОИХ вызовах (snapshot и check);
#     после снимка в правила пишется имя будущей утечки и создаётся сама
#     утечка → rc 1, имя утечки в выводе (unset снимает канал ⇒ porcelain
#     видит утечку). Без env-канала утечку прячет ТОЛЬКО VALUE_0 — механика
#     проверяется sanity-пробами В ОБЕ стороны.
#
# ЗАКРЫТИЕ КЛАССА (что делает контроли зелёными): scripts/check_no_leak.sh
# на коммите 324ccaa — unset GIT_CONFIG_COUNT в блоке санитизации (строка
# 206, блок 202-208; обоснование класса — комментарий (5)
# S-git-config-count-env, строки 164-175). Git игнорирует все
# GIT_CONFIG_KEY_<n>/VALUE_<n> без счётчика (git-config(1): «If
# GIT_CONFIG_COUNT is not set, all GIT_CONFIG_KEY_<n>/VALUE_<n> are
# ignored») ⇒ porcelain всех producer'ов видит дерево как есть ⇒ новая
# строка манифеста ⇒ дельта ⇒ rc 1 именованный. При откате фикса (имени
# нет в unset-списке, пред-фикс блоб 9db8251) env доходит до git ⇒ утечка
# спрятана ⇒ rc 0 «чисто» ⇒ контроль 4 КРАСНЫ — регрессия ловится.
#
# Форма — по прецеденту red_symlink_target_content_024.sh: WORK вне дерева,
# TMPDIR в скратче, имена мусора случайны, toy-репозитории `git init`.
# Имя ВНЕ case_*-глоба раннера НАМЕРЕННО (И-11 контракта 024).
#
# Коды возврата: 0 — все четыре контроля прошли (фикс работает); 1 —
#               именованный отказ (детектор отсутствует либо класс не
#               пойман — в т.ч. регрессия фикса Н-96).
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

WORK="$(mktemp -d /tmp/red024-k10-n96-git-config-env.XXXXXX)"   # А-78: свежий WORK вне дерева
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
# Запуск субъекта ПОД env-каналом Н-96: ровно та форма, что в репро
# адверсария — счётчик + ключ + значение уходят в окружение ВЫЗОВА детектора.
run_subj_env() {  # <cwd> <правила> — дальше аргументы субъекта
  local cwd="$1" rules="$2"; shift 2
  SUBJ_OUT="$( cd "$cwd" && \
    GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=core.excludesFile GIT_CONFIG_VALUE_0="$rules" \
    bash "$SUBJ" "$@" 2>&1 )" && SUBJ_RC=0 || SUBJ_RC=$?
}
has() { printf '%s\n' "$SUBJ_OUT" | grep -qF -- "$1"; }

# Живой git-чекаут toy: tracked-файл (канал ночи).
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

# Санити-пробы механики В ОБЕ стороны: один и тот же git видит/не видит
# утечку в зависимости ТОЛЬКО от env-канала (глобальный конфиг изолирован).
vidit_s_env() {  # <каталог> <правила> <имя> — git ПОД каналом Н-96
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=core.excludesFile \
    GIT_CONFIG_VALUE_0="$2" \
    git -C "$1" status --porcelain -uall 2>/dev/null | grep -qF -- "$3"
}
vidit_bez_env() {  # <каталог> <имя> — тот же git БЕЗ канала
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$1" status --porcelain -uall 2>/dev/null | grep -qF -- "$2"
}

# ─── контроль 1: честный вход без env → rc 0 «чисто» ─────────────────────────
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
ok контроль-1 "честный вход без env: rc 0 «чисто»"

# ─── контроль 2: позитивный — видимая утечка без env → rc 1 ─────────────────
# Доказывает: porcelain-половина жива; краснота контроля 4 — не про слепоту
# детектора вообще, а именно про env-канал.
K2="$WORK/v2_pozitiv_${RANDOM}"
mk_main "$K2"
run_subj "$K2" --snapshot "$K2"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-2 "снимок" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
UT2="utechka_n96_vid_${RANDOM}_${RANDOM}.tmp"
printf 'leak\n' > "$K2/$UT2"
run_subj "$K2" --check "$K2"
[ "$SUBJ_RC" -eq 1 ] || fail контроль-2 "видимая утечка без env" \
  "rc=$SUBJ_RC (ожидался 1) — детектор слеп к обычной утечке (не та механика: Н-96 про env-канал). Вывод: $SUBJ_OUT"
has "$P_ZAGR" || fail контроль-2 "видимая утечка без env" \
  "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
has "$UT2" || fail контроль-2 "видимая утечка без env" \
  "имя $UT2 не названо. Вывод: $SUBJ_OUT"
ok контроль-2 "видимая утечка без env: rc 1, $UT2 назван"

# ─── контроль 3: стабильность под БЕЗОБРЕДНЫМ env → rc 0 ────────────────────
# Канал ПРИСУТСТВУЕТ на обоих вызовах, но правила пусты и не мутируют:
# снятие GIT_CONFIG_COUNT не должно рождать ложную тревогу. Проходит и на
# пред-фикс коде (env без мутации ничего не прячет — «чисто» честно).
K3="$WORK/v3_bezop_env_${RANDOM}"
mk_main "$K3"
EXT3="$WORK/pravila_n96_${RANDOM}"
mkdir -p "$EXT3"
printf '' > "$EXT3/rules"
run_subj_env "$K3" "$EXT3/rules" --snapshot "$K3"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-3 "снимок под env" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
run_subj_env "$K3" "$EXT3/rules" --check "$K3"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-3 "безобредный env" \
  "rc=$SUBJ_RC (ожидался 0) — пустые env-правила дали ложную тревогу. Вывод: $SUBJ_OUT"
has "$P_CHISTO" || fail контроль-3 "безобредный env" \
  "нет маркера «$P_CHISTO». Вывод: $SUBJ_OUT"
ok контроль-3 "безобредный env (правила пусты, без мутации): rc 0 «чисто»"

# ─── контроль 4: атака Н-96 — env прячет утечку, снятие ловит → rc 1 ────────
# МЕХАНИКА. Оба вызова (снимок и сверка) идут ПОД каналом; на снимке правила
# пусты. После снимка в правила пишется имя будущей утечки и создаётся сама
# утечка. ДО фикса Н-96: env доходит до пиннутого git ⇒ porcelain всех
# producer'ов прячет утечку ⇒ дельта пуста ⇒ rc 0 «чисто» (репро
# k10_git_config_env.sh). ПОСЛЕ ФИКСА: unset GIT_CONFIG_COUNT
# (scripts/check_no_leak.sh:206) ⇒ git игнорирует KEY_0/VALUE_0 ⇒ утечка в
# манифесте ⇒ rc 1, имя утечки.
K4="$WORK/v4_ataka_n96_${RANDOM}"
mk_main "$K4"
EXT4="$WORK/pravila_n96_ataka_${RANDOM}"
mkdir -p "$EXT4"
printf '' > "$EXT4/rules"
run_subj_env "$K4" "$EXT4/rules" --snapshot "$K4"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-4 "снимок под env" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
UT4="utechka_n96_env_${RANDOM}_${RANDOM}.tmp"
printf '%s\n' "$UT4" > "$EXT4/rules"
printf 'leak\n' > "$K4/$UT4"
# Sanity В ОБЕ стороны: под каналом утечка СПРЯТАНА, без канала — ВИДНА.
# Расхождение доказывает, что прячет её ровно env-канал, ничего иное.
if vidit_s_env "$K4" "$EXT4/rules" "$UT4"; then
  fail контроль-4 "env-канал" \
    "git ПОД env-каналом видит утечку — правила не применились, вход не воспроизводит класс Н-96"
fi
if ! vidit_bez_env "$K4" "$UT4"; then
  fail контроль-4 "env-канал" \
    "git БЕЗ env-канала НЕ видит утечку — её прячет не env, вход не воспроизводит класс Н-96"
fi
run_subj_env "$K4" "$EXT4/rules" --check "$K4"
[ "$SUBJ_RC" -eq 1 ] || fail контроль-4 "env-канал прячет утечку" \
  "rc=$SUBJ_RC (ожидался 1) — GIT_CONFIG_COUNT/KEY_0/VALUE_0 не сняты: env-конфиг дошёл до git, porcelain спрятал утечку ⇒ ложный «чисто» (дефект Н-96 к10). Вывод: $SUBJ_OUT"
has "$P_ZAGR" || fail контроль-4 "env-канал прячет утечку" \
  "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
has "$UT4" || fail контроль-4 "env-канал прячет утечку" \
  "имя $UT4 не названо. Вывод: $SUBJ_OUT"
if has "$P_CHISTO"; then
  fail контроль-4 "env-канал прячет утечку" \
    "вывод одновременно заявляет чисто при rc=1. Вывод: $SUBJ_OUT"
fi
[ -f "$K4/$UT4" ] || fail контроль-4 "env-канал прячет утечку" \
  "утечка $UT4 физически исчезла с диска — сверка удалила чужой файл"
ok контроль-4 "env-канал GIT_CONFIG_COUNT снят: rc 1, $UT4 назван"

printf 'red_git_config_env_024: 4 контроля зелены (дефект Н-96 к10 — GIT_CONFIG_COUNT-канал core.excludesFile снят, утечка под env-правилом ловится)\n' >&2
exit 0
