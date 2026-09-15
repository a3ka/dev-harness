#!/usr/bin/env bash
# Респек-проба v6 контракта 024 — НОГА-2 «untracked-байты» корневого среза
# манифеста (РАЗРЕШИЛ владелец 2026-09-15, путь 1 из трёх; Н-89 — порочность
# перечисления носителей ослепления: 8 классов / 8 адверсарий-кругов).
#
# СПЕКА ЦЕЛЕВОГО, не текущего: НОВЫЙ untracked-файл при ЛЮБОМ ignore-носителе
# даёт rc 1 С ИМЕНЕМ УТЕЧКИ (не только носителя):
#   контроль 1 — стабильное committed-правило .gitignore (правило ДО снимка,
#                носитель не мутирует) + новая утечка под ним;
#   контроль 2 — стабильное правило .git/info/exclude (до снимка) + утечка;
#   контроль 3 — стабильный внешний core.excludesFile (config и цель до
#                снимка) + утечка;
#   контроль 4 — инвариант ПРЕДСТАВЛЕНИЯ: untracked-путь, живущий под
#                ignore-правилом ЕЩЁ ДО снимка, представлен в манифесте
#                снимка строкой с sha256 (различение текущее/целевое);
#   контроль 5 — КОНТРОЛЬ self-hide (Б6 к9): новый самоигнорирующийся
#                .gitignore + утечка — зелёный ЗЕЛЕНЬЮ: сейчас ловится
#                носителем (WTIGNORE-строка, замер E11: rc=1, назван
#                .gitignore), после среза — ногой-2 (видны ОБА: и носитель,
#                и утечка); ассерт — rc 1 без привязки к тому, ЧЬЁ имя;
#   контроль 6 — КОНТРОЛЬ env-инъекции: GIT_CONFIG_COUNT/KEY/VALUE с
#                core.excludesFile вокруг вызова --check снят санитизацией
#                (замер E12: rc=1, утечка названа) — срез не имеет права
#                регрессировать env-санитизацию (она уже структурна).
#
# КРАСНОТА РЕСПЕКА: контроли 1-3 на текущем коде (porcelain-формы v5,
# HEAD 492ac4d) дают rc 0 «основной чекаут чист» ПРИ ЖИВОЙ УТЕЧЕКЕ — замер
# матрицы 2026-09-15 (E2/E3/E4): Stable-правила не мутируют носители,
# porcelain ослеплён, специальных producer'ов для «файл под правилом» нет.
# Проба умирает ПЕРВЫМ ЖЕ контролем с именованной причиной «ложное чисто» —
# и зеленеет после implementer-фикса (v6 нога-2: git ls-files --others -z
# БЕЗ --exclude-standard видит КАЖДЫЙ untracked-путь МИМО любых
# ignore-правил). Прецедент «красные тесты как контракт» (И-10).
#
# Форма — по прецеденту red_gitignore_selfhide_024.sh: WORK вне дерева,
# TMPDIR редиректится в WORK, имена утечки случайны КАЖДЫЙ прогон, toy
# только git init (НЕ worktree, грань Н-95 вне предмета). Имя ВНЕ case_*-
# глоба раннера НАМЕРЕННО (И-11).
#
# Коды возврата: 0 — все 6 контролей прошли (цель v6 достигнута); 1 —
#               именованный отказ (ложное «чисто» / имя утечки не названо /
#               нога отсутствует / утечка исчезла с диска).
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

WORK="$(mktemp -d /tmp/red024-v6-untracked.XXXXXX)"   # А-78: свежий WORK вне дерева
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

tgit() {
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}

mk_main() {  # <каталог>
  mkdir -p "$1"
  printf 'original\n' > "$1/tracked.txt"
  tgit init -q -b main "$1"
  tgit -C "$1" add -A
  tgit -C "$1" commit -q -m 'toy main'
}

# Путь снимка — ровно как считает субъект: hash8 от канонического корня.
snap_of() {  # <каталог>
  local canon h8
  canon="$(cd "$1" && pwd -P)"
  h8="$(printf '%s' "$canon" | sha256sum)"
  h8="${h8%% *}"; h8="${h8:0:8}"
  printf '%s/dev-harness-leak/%s/porcelain' "$WORK/snaps" "$h8"
}

# Ассерт целевого поведения «утечка под правилом поймана С ИМЕНЕМ утечки»:
# rc 1, фраза, имя УТЕЧКИ (не носителя), файл жив на диске.
assert_leak_named() {  # <метка> <сценарий> <носитель-текстом> <имя-утечки> <файл-утечки>
  local meta="$1" scen="$2" nositel="$3" ut="$4" disk="$5"
  [ "$SUBJ_RC" -eq 1 ] || fail "$meta" "$scen" \
    "rc=$SUBJ_RC — ложное «чисто» при живой утечке под стабильным правилом ($nositel): текущий код ослеплён porcelain-формами, цель v6 — нога-2 (ls-files --others -z БЕЗ --exclude-standard) обязана видеть утечку МИМО любых ignore-правил. Вывод: $SUBJ_OUT"
  has "$P_ZAGR" || fail "$meta" "$scen" "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
  has "$ut" || fail "$meta" "$scen" "имя утечки $ut не названо (назван только носитель?). Вывод: $SUBJ_OUT"
  if has "$P_CHISTO"; then
    fail "$meta" "$scen" "ложное «$P_CHISTO» при живой утечке. Вывод: $SUBJ_OUT"
  fi
  [ -f "$disk" ] || fail "$meta" "$scen" "утечка физически исчезла с диска — сверка тронула чужой файл"
  ok "$meta" "$scen: rc 1, утечка $ut названа, файл жив на диске"
}

# Sanity: porcelain toy-репозитория НЕ видит утечку (правило реально ослепляет
# источник) — иначе контроль доказывает не механику носителя, а обычный untracked.
assert_porcelain_blind() {  # <каталог> <имя-утечки> <метка>
  local porc
  porc="$(tgit -C "$1" status --porcelain -uall --no-renames --ignore-submodules=none 2>/dev/null)"
  if printf '%s' "$porc" | grep -qF "$2"; then
    fail "$3" "sanity porcelain" "porcelain toy ВИДИТ утечку $2 — правило носителя не ослепляет, механика контроля не та"
  fi
}

# ─── контроль 1: стабильное committed-правило .gitignore + утечка → rc 1 ───────
K1="$WORK/k1_gitignore_${RANDOM}"
mk_main "$K1"
printf 'hid*\n' > "$K1/.gitignore"
tgit -C "$K1" add -A
tgit -C "$K1" commit -q -m 'toy gitignore'
run_subj "$K1" --snapshot "$K1"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-1 "снимок" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
UT1="hid_leak_${RANDOM}.txt"
printf 'LEAK UNDER GITIGNORE\n' > "$K1/$UT1"
assert_porcelain_blind "$K1" "$UT1" контроль-1
run_subj "$K1" --check "$K1"
assert_leak_named контроль-1 "утечка под стабильным committed .gitignore-правилом" "committed .gitignore" "$UT1" "$K1/$UT1"

# ─── контроль 2: стабильное правило .git/info/exclude + утечка → rc 1 ──────────
K2="$WORK/k2_exclude_${RANDOM}"
mk_main "$K2"
printf 'exc*\n' >> "$K2/.git/info/exclude"
run_subj "$K2" --snapshot "$K2"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-2 "снимок" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
UT2="exc_leak_${RANDOM}.txt"
printf 'LEAK UNDER EXCLUDE\n' > "$K2/$UT2"
assert_porcelain_blind "$K2" "$UT2" контроль-2
run_subj "$K2" --check "$K2"
assert_leak_named контроль-2 "утечка под стабильным правилом .git/info/exclude" ".git/info/exclude" "$UT2" "$K2/$UT2"

# ─── контроль 3: стабильный внешний core.excludesFile + утечка → rc 1 ──────────
K3="$WORK/k3_extexc_${RANDOM}"
mk_main "$K3"
EXTRULES="$WORK/ext_rules_${RANDOM}.txt"
printf 'ext*\n' > "$EXTRULES"
tgit -C "$K3" config core.excludesFile "$EXTRULES"
run_subj "$K3" --snapshot "$K3"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-3 "снимок" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
UT3="ext_leak_${RANDOM}.txt"
printf 'LEAK UNDER EXT\n' > "$K3/$UT3"
assert_porcelain_blind "$K3" "$UT3" контроль-3
run_subj "$K3" --check "$K3"
assert_leak_named контроль-3 "утечка под стабильным внешним core.excludesFile" "внешний core.excludesFile" "$UT3" "$K3/$UT3"

# ─── контроль 4: инвариант ПРЕДСТАВЛЕНИЯ (различение текущее/целевое) ──────────
# Целевой манифест (v6 нога-2) обязан представлять КАЖДЫЙ untracked-путь с
# sha256 байтов — В ТОМ ЧИСЛЕ путь, живущий под ignore-правилом ЕЩЁ ДО
# снимка (стабильный, немутрирующий). Оракул — в артефакте-снимке (правило 8:
# снимок лежит в TMPDIR пробы). Текущий код такие пути не представляет
# (замер E1: hid_seed отсутствует в снимке) → именованный ОТКАЗ.
K4="$WORK/k4_invariant_${RANDOM}"
mk_main "$K4"
printf 'hid*\n' > "$K4/.gitignore"
tgit -C "$K4" add -A
tgit -C "$K4" commit -q -m 'toy gitignore'
SEED="hid_seed_${RANDOM}.txt"
printf 'SEED UNDER RULE\n' > "$K4/$SEED"
run_subj "$K4" --snapshot "$K4"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-4 "снимок" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
SNAP="$(snap_of "$K4")"
[ -f "$SNAP" ] || fail контроль-4 "снимок-файл" "файл снимка K4 не найден: $SNAP"
SNAPLINE="$(grep -P "\t${SEED}\$" "$SNAP" 2>/dev/null)"
if [ -z "$SNAPLINE" ]; then
  fail контроль-4 "нога untracked-байтов отсутствует" \
    "024-v6: untracked-путь $SEED, живущий под стабильным ignore-правилом, НЕ представлен в манифесте снимка (цель: git ls-files --others -z БЕЗ --exclude-standard -> КАЖДЫЙ untracked-путь с sha256; текущее: porcelain-формы v5 его не видят вовсе) — корневой срез не реализован"
fi
printf '%s\n' "$SNAPLINE" | grep -qE '[0-9a-f]{64}' \
  || fail контроль-4 "нога untracked-байтов отсутствует" \
    "024-v6: строка $SEED есть, но без sha256 байтов (64-hex) — представление не байтовое"
ok контроль-4 "инвариант представления: untracked-путь под правилом несёт байтовую строку манифеста"

# ─── контроль 5 (КОНТРОЛЬ, зелёный сейчас): self-hide Б6 → rc 1 ────────────────
K5="$WORK/k5_selfhide_${RANDOM}"
mk_main "$K5"
run_subj "$K5" --snapshot "$K5"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-5 "снимок" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
printf '.gitignore\nsl*\n' > "$K5/.gitignore"
UT5="sl_leak_${RANDOM}.txt"
printf 'LEAK SELFHIDE\n' > "$K5/$UT5"
assert_porcelain_blind "$K5" "$UT5" контроль-5
assert_porcelain_blind "$K5" '.gitignore' контроль-5
run_subj "$K5" --check "$K5"
[ "$SUBJ_RC" -eq 1 ] || fail контроль-5 "self-hide" \
  "rc=$SUBJ_RC — регрессия: сейчас класс Б6 закрыт WTIGNORE-носителем (замер E11: rc=1), целевая нога-2 видит ОБА файла. Вывод: $SUBJ_OUT"
has "$P_ZAGR" || fail контроль-5 "self-hide" "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
if has "$P_CHISTO"; then
  fail контроль-5 "self-hide" "ложное «$P_CHISTO» при живой утечке. Вывод: $SUBJ_OUT"
fi
[ -f "$K5/$UT5" ] || fail контроль-5 "self-hide" "утечка физически исчезла с диска"
ok контроль-5 "self-hide (контроль Б6): rc 1 держится (сейчас — носитель, после среза — нога-2 видит оба)"

# ─── контроль 6 (КОНТРОЛЬ, зелёный сейчас): env-инъекция снята санитизацией ────
K6="$WORK/k6_env_${RANDOM}"
mk_main "$K6"
ENVRULES="$WORK/env_rules_${RANDOM}.txt"
printf 'env*\n' > "$ENVRULES"
run_subj "$K6" --snapshot "$K6"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-6 "снимок" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
UT6="env_leak_${RANDOM}.txt"
printf 'LEAK ENV\n' > "$K6/$UT6"
SUBJ_OUT="$( cd "$K6" && env GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=core.excludesFile GIT_CONFIG_VALUE_0="$ENVRULES" bash "$SUBJ" --check "$K6" 2>&1 )" && SUBJ_RC=0 || SUBJ_RC=$?
[ "$SUBJ_RC" -eq 1 ] || fail контроль-6 "env-канал" \
  "rc=$SUBJ_RC — регрессия env-санитизации: GIT_CONFIG_COUNT обязан сниматься (замер E12: rc=1, утечка названа). Вывод: $SUBJ_OUT"
has "$P_ZAGR" || fail контроль-6 "env-канал" "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
has "$UT6" || fail контроль-6 "env-канал" "имя утечки $UT6 не названо. Вывод: $SUBJ_OUT"
[ -f "$K6/$UT6" ] || fail контроль-6 "env-канал" "утечка физически исчезла с диска"
ok контроль-6 "env-инъекция GIT_CONFIG_COUNT снята санитизацией: rc 1, утечка названа"

printf 'red_rootcut_untracked_024: 6 контролей зелены (v6 нога-2: НОВЫЙ untracked-файл при любом ignore-носителе даёт rc 1 С ИМЕНЕМ утечки; untracked-путь под правилом представлен байтами в манифесте; Б6-контроль и env-санитизация не регрессируют)\n' >&2
exit 0
