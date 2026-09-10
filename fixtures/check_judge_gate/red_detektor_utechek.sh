#!/usr/bin/env bash
# ПРЕД-ЗАКЛЮЧИТЕЛЬНОЕ КРАСНОЕ контракта 024 (правка-круг 2, вердикт критика
# 4d1d265) — детектор утечек основного чекаута scripts/check_no_leak.sh
# (семейство 2 записи Н-85; решение владельца Г5 2026-09-10: «D→среда ДА, D
# детектор (дёшев, независим, механизирует ручную меру), среда превенция»).
#
# Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (прецедент red_mera_parallelnosti_
# okon.sh контракта 021): до реализации предмет предъявляется ПРЯМЫМ запуском
# этого файла; конверсия в case_* — пачка architect ПОСЛЕ реализации.
#
# ДОГОВОР детектора (Демаркация контракта 024 — единый источник; фразы несёт
# побайтово). Снимок/сверка судят СОДЕРЖИМОЕ дерева, не множество строк
# статуса (блокер 1 вердикта 4d1d265: строка porcelain описывает состояние
# пути, не его байты — три контрольных эксперимента критика обошли v1-форму):
#   --snapshot <абс-корень>  манифест «XY:отпечаток<TAB>путь» по каждой записи
#                            `status --porcelain -uall -z --no-renames`
#                            (свернутые ?? dir/ РАСКРЫТЫ); отпечаток =
#                            sha256 байтов файла; каталог с .git (submodule/
#                            вложенный репозиторий) — «@head:<sha>» + РЕКУРСИЯ
#                            манифеста внутрь с префиксом пути; D-записи — «-»;
#                            файл-снимок: строка 1 «root <канон-корень>»,
#                            далее манифест; ВНЕ стерегомого, TMPDIR уважается,
#                            перезапись (последний выигрывает); rc 0;
#   --check <абс-корень>     дельта-ПОДМНОЖЕСТВО строк манифеста: новая строка
#                            (новый путь, смена XY ИЛИ отпечатка) → rc 1
#                            «основной чекаут загрязнён: <имена>»; исчезнувшая
#                            — чистка; нет снимка → rc 1 «снимок отсутствует»
#                            (fail-closed); чужая root-строка → rc 1 «снимок
#                            чужого корня»; пусто → rc 0 «основной чекаут
#                            чист»; cwd НЕ влияет на решение НИ В ОДНУ сторону;
#   относительный корень     rc 1 «корень обязан быть абсолютным» в обоих
#                            режимах, ДО какого-либо cd (блокер 5 вердикта).
#
# Ворота (нумерация — для шапок стабов и токенов пробы, Н-39: стаб умирает на
# СВОЁМ входе с именованной причиной; проба сверяет И ворот, И причину):
#   1  утечка после снимка (новый файл + модификация tracked) → rc 1, ОБА имени;
#   2  чисто → rc 0 + маркер;
#   3  мусор ДО снимка (без изменения содержимого) не красен;
#   4  чистка после снимка не красна;
#   5  снимок отсутствует → rc 1 «снимок отсутствует» (fail-closed);
#   6  повторный снимок обновляет базу;
#   7  cwd-независимость: жертва грязна, cwd-приманка грязна, сверка ИЗ
#      приманки → rc 1, имя ЖЕРТВЫ названо, имени приманки НЕТ;
#   8  cwd-симметрия (блокер 2 вердикта): жертва ЧИСТА, cwd-приманка грязна →
#      rc 0 + маркер, имени приманки НЕТ;
#   9  новые байты в УЖЕ-ГРЯЗНОМ tracked-пути → rc 1 (эксперимент 1 вердикта);
#   10 новый файл под УЖЕ-СВЁРНУТЫМ ?? dir/ → rc 1 (эксперимент 2 вердикта);
#   11 правка внутри УЖЕ-ГРЯЗНОГО submodule → rc 1 (эксперимент 3 вердикта);
#   12 относительный корень → rc 1 именованный, оба режима;
#   13 чужая root-строка снимка → rc 1 «снимок чужого корня» (коллизия hash8);
#   14 само-чистота: porcelain жертвы до == после, байтово (оракул в памяти).
# Ворота 3, 4 и 14 — без выделенного стаба-убийцы (v1-паритет: их держат
# честная форма и байтовые сравнения; класс «снимок в дереве» дополнительно
# умирает на воротах 2/14 — собственный снимок объявляется утечкой).
#
# Имена мусора и toy-корни случайны КАЖДЫЙ прогон — константный dispatch по
# именам не собирается ни на одном прогоне (демаркация 023, класс ebc57db).
# TMPDIR редиректится в WORK до вызовов субъекта — снимки ложатся в скратч
# прогона и умирают trap'ом (договор TMPDIR уважает).
#
# СЕГОДНЯ (детектора в дереве нет) файл красен именованным отсутствием
# предмета — это и есть предъявляемое красное.
#
# Коды возврата: 0 — ворота пройдены; 1 — именованный отказ (детектор
#               отсутствует либо нарушил договор на воротах).
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
WORK="$(mktemp -d /tmp/red024-detektor.XXXXXX)"   # А-78: свежий WORK вне дерева
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/snaps"
export TMPDIR="$WORK/snaps"                       # снимки субъекта — в скратч прогона

SUBJ="$REPO/scripts/check_no_leak.sh"
[ -f "$SUBJ" ] || {
  printf 'ОТКАЗ: детектор отсутствует — scripts/check_no_leak.sh (реализация за implementer после заморозки 024)\n' >&2
  exit 1
}

# ЕДИНЫЙ источник фраз (Демаркация 024) — побайтово во всех проверках ниже.
P_ZAGR='основной чекаут загрязнён'
P_CHISTO='основной чекаут чист'
P_NET_SNIMKA='снимок отсутствует'
P_ABS='корень обязан быть абсолютным'
P_CHUZH='снимок чужого корня'

ok()   { printf '  ok   ворота %s (%s)\n' "$1" "$2" >&2; }
fail() { printf 'ОТКАЗ ворота %s (%s): %s\n' "$1" "$2" "$3" >&2; exit 1; }
has()  { printf '%s\n' "$SUBJ_OUT" | grep -qF -- "$1"; }

GTOY_ENV=(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null)

# Живой git-чекаут «основного дерева» toy: два tracked-файла — каналы ночи.
mk_main() {  # <каталог>
  mkdir -p "$1/.githooks" "$1/scripts"
  printf '# toy hook\n'   > "$1/.githooks/pre-push"
  printf '# toy spawn\n'  > "$1/scripts/spawn_agent.sh"
  env "${GTOY_ENV[@]}" git init -q -b main "$1"
  env "${GTOY_ENV[@]}" \
    git -C "$1" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
  env "${GTOY_ENV[@]}" \
    git -C "$1" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      commit -q -m 'toy main'
}

# Submodule-toy: gitlink БЕЗ .gitmodules (update-index --cacheinfo 160000) —
# ровно механика «правка внутри уже-грязного submodule» эксперимента 3.
mk_gitlink() {  # <родитель-уже-git> <имя-подмодуля>
  local parent="$1" name="$2" sha
  mkdir -p "$parent/$name"
  printf 'inner toy\n' > "$parent/$name/inner.txt"
  env "${GTOY_ENV[@]}" git init -q -b main "$parent/$name"
  env "${GTOY_ENV[@]}" \
    git -C "$parent/$name" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
  env "${GTOY_ENV[@]}" \
    git -C "$parent/$name" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -q -m 'toy inner'
  sha="$(env "${GTOY_ENV[@]}" git -C "$parent/$name" rev-parse HEAD)"
  env "${GTOY_ENV[@]}" \
    git -C "$parent" update-index --add --cacheinfo "160000,$sha,$name"
  env "${GTOY_ENV[@]}" \
    git -C "$parent" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -q -m 'toy gitlink'
}

run_subj() {  # <cwd> <аргументы...> — rc без пайпов (Н-84/Н-85)
  local cwd="$1"; shift
  SUBJ_OUT="$( cd "$cwd" && bash "$SUBJ" "$@" 2>&1 )" && SUBJ_RC=0 || SUBJ_RC=$?
}

# ── ворота 1: утечка после снимка → rc 1, ОБА имени ───────────────────────────
M1="$WORK/v1_zagrjaznenie_${RANDOM}"
mk_main "$M1"
MUSOR1="skrepka_${RANDOM}${RANDOM}.txt"
run_subj "$M1" --snapshot "$M1"
[ "$SUBJ_RC" -eq 0 ] || fail 1 "утечка" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
printf 'x\n' >> "$M1/.githooks/pre-push"   # канал ночи 1: правка tracked без cwd
: > "$M1/$MUSOR1"                          # канал ночи 2: новый мусор от bash
run_subj "$M1" --check "$M1"
[ "$SUBJ_RC" -eq 1 ] || fail 1 "утечка" "rc=$SUBJ_RC (ожидался 1). Вывод: $SUBJ_OUT"
has "$P_ZAGR"    || fail 1 "утечка" "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
has "$MUSOR1"    || fail 1 "утечка" "имя мусора $MUSOR1 не названо. Вывод: $SUBJ_OUT"
has ".githooks/pre-push" || fail 1 "утечка" "модификация tracked .githooks/pre-push не названа. Вывод: $SUBJ_OUT"
ok 1 "утечка после снимка: оба имени названы"

# ── ворота 2: чисто → rc 0 + маркер ───────────────────────────────────────────
M2="$WORK/v2_chisto_${RANDOM}"
mk_main "$M2"
run_subj "$M2" --snapshot "$M2"
[ "$SUBJ_RC" -eq 0 ] || fail 2 "чисто" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
run_subj "$M2" --check "$M2"
[ "$SUBJ_RC" -eq 0 ] || fail 2 "чисто" "rc=$SUBJ_RC (ожидался 0). Вывод: $SUBJ_OUT"
has "$P_CHISTO" || fail 2 "чисто" "нет маркера «$P_CHISTO» — стаб-всегда-0 без работы не должен проходить. Вывод: $SUBJ_OUT"
ok 2 "чисто проходит с маркером"

# ── ворота 3: мусор ДО снимка (тот же контент) не красен ──────────────────────
M3="$WORK/v3_staryj_musor_${RANDOM}"
mk_main "$M3"
MUSOR3="staryj_${RANDOM}${RANDOM}.log"
: > "$M3/$MUSOR3"
printf 'x\n' >> "$M3/scripts/spawn_agent.sh"   # оба вида мусора ДО снимка
run_subj "$M3" --snapshot "$M3"
[ "$SUBJ_RC" -eq 0 ] || fail 3 "мусор до снимка" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
run_subj "$M3" --check "$M3"
[ "$SUBJ_RC" -eq 0 ] || fail 3 "мусор до снимка" "старый мусор краснеет rc=$SUBJ_RC — детектор судит абсолют, не дельту. Вывод: $SUBJ_OUT"
has "$P_CHISTO" || fail 3 "мусор до снимка" "нет маркера «$P_CHISTO». Вывод: $SUBJ_OUT"
ok 3 "мусор до снимка не краснеет"

# ── ворота 4: чистка после снимка не красна ───────────────────────────────────
M4="$WORK/v4_chistka_${RANDOM}"
mk_main "$M4"
MUSOR4="vremennyj_${RANDOM}${RANDOM}.tmp"
: > "$M4/$MUSOR4"
run_subj "$M4" --snapshot "$M4"
[ "$SUBJ_RC" -eq 0 ] || fail 4 "чистка" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
rm -f "$M4/$MUSOR4"
run_subj "$M4" --check "$M4"
[ "$SUBJ_RC" -eq 0 ] || fail 4 "чистка" "исчезновение записи краснеет rc=$SUBJ_RC — сверка в обе стороны, а не подмножество. Вывод: $SUBJ_OUT"
has "$P_CHISTO" || fail 4 "чистка" "нет маркера «$P_CHISTO». Вывод: $SUBJ_OUT"
ok 4 "чистка после снимка не краснеет"

# ── ворота 5: снимок отсутствует → rc 1 fail-closed ───────────────────────────
M5="$WORK/v5_bez_snimka_${RANDOM}"
mk_main "$M5"    # НИКОГДА не снимался
run_subj "$M5" --check "$M5"
[ "$SUBJ_RC" -eq 1 ] || fail 5 "снимок отсутствует" "rc=$SUBJ_RC (ожидался 1) — сверка без снимка не имеет права проходить: церемониальная дыра «забыл снять снимок». Вывод: $SUBJ_OUT"
has "$P_NET_SNIMKA" || fail 5 "снимок отсутствует" "нет фразы «$P_NET_SNIMKA». Вывод: $SUBJ_OUT"
ok 5 "сверка без снимка отказывает именованно"

# ── ворота 6: повторный снимок обновляет базу ─────────────────────────────────
M6="$WORK/v6_perezapis_${RANDOM}"
mk_main "$M6"
MUSOR6A="mezhdu_${RANDOM}a.txt"
MUSOR6B="mezhdu_${RANDOM}b.txt"
: > "$M6/$MUSOR6A"
run_subj "$M6" --snapshot "$M6"
[ "$SUBJ_RC" -eq 0 ] || fail 6 "повторный снимок" "первый снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
: > "$M6/$MUSOR6B"
run_subj "$M6" --snapshot "$M6"
[ "$SUBJ_RC" -eq 0 ] || fail 6 "повторный снимок" "второй снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
run_subj "$M6" --check "$M6"
[ "$SUBJ_RC" -eq 0 ] || fail 6 "повторный снимок" "rc=$SUBJ_RC — мусор между снимками не вошёл в базу: первый снимок заморожен навсегда. Вывод: $SUBJ_OUT"
has "$P_CHISTO" || fail 6 "повторный снимок" "нет маркера «$P_CHISTO». Вывод: $SUBJ_OUT"
ok 6 "повторный снимок обновляет базу"

# ── ворота 7: cwd-независимость (жертва грязна, приманка грязна, cwd=приманка)
M7="$WORK/v7_zhertva_${RANDOM}"
DECOY="$WORK/v7_primanka_${RANDOM}"
mk_main "$M7"
mk_main "$DECOY"
MUSOR_DEC="lozh_${RANDOM}${RANDOM}.txt"
: > "$DECOY/$MUSOR_DEC"                       # мусор ПРИМАНКИ — не жертвы
MUSOR7="sleza_${RANDOM}${RANDOM}.txt"
run_subj "$M7" --snapshot "$M7"
[ "$SUBJ_RC" -eq 0 ] || fail 7 "cwd" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
printf 'x\n' >> "$M7/.githooks/pre-push"
: > "$M7/$MUSOR7"
run_subj "$DECOY" --check "$M7"               # cwd = чужой репозиторий с мусором
[ "$SUBJ_RC" -eq 1 ] || fail 7 "cwd" "rc=$SUBJ_RC (ожидался 1). Вывод: $SUBJ_OUT"
has "$P_ZAGR" || fail 7 "cwd" "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
has "$MUSOR7" || fail 7 "cwd" "имя ЖЕРТВЫ $MUSOR7 не названо — детектор судит свой cwd, не аргумент (Н-85-класс). Вывод: $SUBJ_OUT"
if has "$MUSOR_DEC"; then
  fail 7 "cwd" "имя приманки $MUSOR_DEC названо — детектор краснеет по объединению статусов, а не по жертве (блокер 2 вердикта 4d1d265). Вывод: $SUBJ_OUT"
fi
ok 7 "cwd-независимость: названа жертва, приманка не названа"

# ── ворота 8: cwd-симметрия — жертва ЧИСТА, cwd-приманка грязна → rc 0 ────────
M8="$WORK/v8_simmetrija_${RANDOM}"
DECOY8="$WORK/v8_primanka_${RANDOM}"
mk_main "$M8"
mk_main "$DECOY8"
MUSOR_DEC8="lozh8_${RANDOM}${RANDOM}.txt"
: > "$DECOY8/$MUSOR_DEC8"
run_subj "$M8" --snapshot "$M8"
[ "$SUBJ_RC" -eq 0 ] || fail 8 "cwd-симметрия" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
run_subj "$DECOY8" --check "$M8"              # жертва чиста, cwd грязен
[ "$SUBJ_RC" -eq 0 ] || fail 8 "cwd-симметрия" "rc=$SUBJ_RC (ожидался 0) — грязный cwd не имеет права краснить чистую жертву: сверка обязана судить только аргумент (блокер 2 вердикта 4d1d265). Вывод: $SUBJ_OUT"
has "$P_CHISTO" || fail 8 "cwd-симметрия" "нет маркера «$P_CHISTO». Вывод: $SUBJ_OUT"
if has "$MUSOR_DEC8"; then
  fail 8 "cwd-симметрия" "имя приманки $MUSOR_DEC8 названо при чистой жертве — cwd влияет на решение. Вывод: $SUBJ_OUT"
fi
ok 8 "cwd-симметрия: чистая жертва при грязной приманке проходит"

# ── ворота 9: новые байты в УЖЕ-ГРЯЗНОМ tracked-пути → rc 1 ───────────────────
M9="$WORK/v9_uzhe_grijaznyj_${RANDOM}"
mk_main "$M9"
printf 'namerennaja_pravka\n' >> "$M9/.githooks/pre-push"   # грязь ДО снимка
run_subj "$M9" --snapshot "$M9"
[ "$SUBJ_RC" -eq 0 ] || fail 9 "уже-грязный путь" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
printf 'utechka_dopisana\n' >> "$M9/.githooks/pre-push"     # утечка ПОСЛЕ снимка
run_subj "$M9" --check "$M9"
[ "$SUBJ_RC" -eq 1 ] || fail 9 "уже-грязный путь" "rc=$SUBJ_RC (ожидался 1) — новые байты в уже-грязном пути замаскированы строкой « M»: строка статуса описывает путь, не содержимое (эксперимент 1 вердикта 4d1d265). Вывод: $SUBJ_OUT"
has "$P_ZAGR" || fail 9 "уже-грязный путь" "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
has ".githooks/pre-push" || fail 9 "уже-грязный путь" "путь .githooks/pre-push не назван. Вывод: $SUBJ_OUT"
ok 9 "новые байты в уже-грязном пути пойманы"

# ── ворота 10: новый файл под УЖЕ-СВЁРНУТЫМ ?? dir/ → rc 1 ────────────────────
M10="$WORK/v10_svertka_${RANDOM}"
mk_main "$M10"
SCR10="skrut_${RANDOM}"
mkdir "$M10/$SCR10"                            # untracked-каталог ДО снимка
: > "$M10/$SCR10/staroe_${RANDOM}.txt"
run_subj "$M10" --snapshot "$M10"
[ "$SUBJ_RC" -eq 0 ] || fail 10 "свёрнутый каталог" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
LEAK10="leak_${RANDOM}.txt"
: > "$M10/$SCR10/$LEAK10"                      # новый файл ПОД СВЁРНУТЫМ каталогом
run_subj "$M10" --check "$M10"
[ "$SUBJ_RC" -eq 1 ] || fail 10 "свёрнутый каталог" "rc=$SUBJ_RC (ожидался 1) — новый файл под уже свёрнутым «?? dir/» замаскирован прежней строкой каталога (эксперимент 2 вердикта 4d1d265). Вывод: $SUBJ_OUT"
has "$P_ZAGR" || fail 10 "свёрнутый каталог" "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
has "$SCR10/$LEAK10" || fail 10 "свёрнутый каталог" "имя $SCR10/$LEAK10 не названо. Вывод: $SUBJ_OUT"
ok 10 "новый файл под свёрнутым каталогом пойман"

# ── ворота 11: правка внутри УЖЕ-ГРЯЗНОГО submodule → rc 1 ────────────────────
M11="$WORK/v11_submodule_${RANDOM}"
mk_main "$M11"
mk_gitlink "$M11" "submod"
printf 'zagryaznenie_vnutri\n' >> "$M11/submod/inner.txt"   # грязь ДО снимка
run_subj "$M11" --snapshot "$M11"
[ "$SUBJ_RC" -eq 0 ] || fail 11 "submodule" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
printf 'utechka_vnutri\n' >> "$M11/submod/inner.txt"        # утечка ПОСЛЕ снимка
run_subj "$M11" --check "$M11"
[ "$SUBJ_RC" -eq 1 ] || fail 11 "submodule" "rc=$SUBJ_RC (ожидался 1) — правка внутри уже-грязного submodule замаскирована прежней строкой « M sub» (эксперимент 3 вердикта 4d1d265). Вывод: $SUBJ_OUT"
has "$P_ZAGR" || fail 11 "submodule" "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
has "submod/inner.txt" || fail 11 "submodule" "внутренний путь submod/inner.txt не назван. Вывод: $SUBJ_OUT"
ok 11 "правка внутри уже-грязного submodule поймана"

# ── ворота 12: относительный корень → rc 1 именованный, оба режима ────────────
M12="$WORK/v12_otnositelnyj_${RANDOM}"
mk_main "$M12"
REL12="$(basename "$M12")"                     # существует относительно $WORK
run_subj "$WORK" --snapshot "$REL12"
[ "$SUBJ_RC" -eq 1 ] || fail 12 "абсолютность" "--snapshot: rc=$SUBJ_RC (ожидался 1) — относительный корень молча принят (блокер 5 вердикта 4d1d265). Вывод: $SUBJ_OUT"
has "$P_ABS" || fail 12 "абсолютность" "--snapshot: нет фразы «$P_ABS». Вывод: $SUBJ_OUT"
run_subj "$WORK" --check "$REL12"
[ "$SUBJ_RC" -eq 1 ] || fail 12 "абсолютность" "--check: rc=$SUBJ_RC (ожидался 1) — относительный корень молча принят. Вывод: $SUBJ_OUT"
has "$P_ABS" || fail 12 "абсолютность" "--check: нет фразы «$P_ABS». Вывод: $SUBJ_OUT"
ok 12 "относительный корень отвергнут именованно в обоих режимах"

# ── ворота 13: чужая root-строка снимка → rc 1 «снимок чужого корня» ──────────
M13="$WORK/v13_chuzhoj_root_${RANDOM}"
mk_main "$M13"
MUSOR13="drugoj_${RANDOM}.txt"
: > "$M13/$MUSOR13"
H8_13="$(printf '%s' "$M13" | sha256sum | cut -c1-8)"
FAKE_DIR="$TMPDIR/dev-harness-leak/$H8_13"
mkdir -p "$FAKE_DIR"
printf 'root /vsja-nesushhestvujushhaja-kollekcija-kornej\n' > "$FAKE_DIR/porcelain"
run_subj "$M13" --check "$M13"
[ "$SUBJ_RC" -eq 1 ] || fail 13 "чужой корень" "rc=$SUBJ_RC (ожидался 1) — снимок чужого корня по коллизии hash8 принят за свой (совет 1 вердикта 4d1d265). Вывод: $SUBJ_OUT"
has "$P_CHUZH" || fail 13 "чужой корень" "нет фразы «$P_CHUZH». Вывод: $SUBJ_OUT"
ok 13 "чужая root-строка снимка отвергнута именованно"

# ── ворота 14: снятие/сверка не загрязняют стерегомое ─────────────────────────
M14="$WORK/v14_samo-chistka_${RANDOM}"
mk_main "$M14"
POR_BEFORE="$(env "${GTOY_ENV[@]}" \
  git -C "$M14" status --porcelain)"           # оракул в ПАМЯТИ фикстуры (правило 8)
run_subj "$M14" --snapshot "$M14"
[ "$SUBJ_RC" -eq 0 ] || fail 14 "само-чистота" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
run_subj "$M14" --check "$M14"
[ "$SUBJ_RC" -eq 0 ] || fail 14 "само-чистота" "rc=$SUBJ_RC (ожидался 0). Вывод: $SUBJ_OUT"
has "$P_CHISTO" || fail 14 "само-чистота" "нет маркера «$P_CHISTO». Вывод: $SUBJ_OUT"
POR_AFTER="$(env "${GTOY_ENV[@]}" \
  git -C "$M14" status --porcelain)"
[ "$POR_BEFORE" = "$POR_AFTER" ] || fail 14 "само-чистота" "снятие/сверка изменили porcelain стерегомого: до=[$POR_BEFORE] после=[$POR_AFTER] — детектор пишет в стерегомое дерево"
ok 14 "снятие/сверка не загрязняют стерегомое"

printf 'red_detektor_utechek: 14 ворот зелены\n' >&2
exit 0
