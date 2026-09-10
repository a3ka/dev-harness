#!/usr/bin/env bash
# ПРЕД-ЗАМОРОЗОЧНОЕ КРАСНОЕ контракта 024 — детектор утечек основного чекаута
# (scripts/check_no_leak.sh, семейство 2 записи Н-85; решение владельца Г5
# 2026-09-10: «D→среда ДА, D детектор (дёшев, независим, механизирует ручную
# меру), среда превенция (один носитель/батарея)»). Обе ночные утечки
# 2026-09-10 — ЭТОТ класс: правка tracked-файла (.githooks/pre-push,
# Impl022fix:228) и запись от bash без cwd (Impl023fix2:271/283/307).
#
# Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (прецедент red_mera_parallelnosti_
# okon.sh контракта 021): раннер не имеет режима «видеть красный кейс
# нереализованного предмета, не уронив CI». До реализации предмет предъявляется
# ПРЯМЫМ запуском этого файла (команда — контракт 024, «Красное сейчас»);
# конверсия в case_* — пачка architect ПОСЛЕ реализации.
#
# ДОГОВОР детектора (Демаркация контракта 024 — единый источник; фразы несёт
# побайтово):
#   --snapshot <абс-корень>  rc 0; снимок porcelain ВНЕ стерегомого, путь от
#                            канонического корня, перезапись (последний
#                            выигрывает), porcelain стерегомого НЕ меняет;
#   --check <абс-корень>     дельта (подмножество): новые записи → rc 1
#                            «основной чекаут загрязнён: <имена>» (новый ??
#                            ИЛИ M tracked — оба ночных канала); исчезнувшие —
#                            чистка, не краснеют; снимка нет → rc 1 «снимок
#                            отсутствует» (fail-closed, НЕ пропуск); дельта
#                            пуста → rc 0 «основной чекаут чист».
#
# Ворота (нумерация — для шапок стабов, Н-39: стаб умирает на СВОЁМ входе):
#   1 утечка после снимка (новый файл + модификация tracked) → rc 1, ОБА имени;
#   2 чисто → rc 0 + маркер;
#   3 мусор ДО снимка не красен (дельта, не абсолют);
#   4 чистка после снимка не красна (исчезновение — не утечка);
#   5 снимок отсутствует → rc 1 «снимок отсутствует» (fail-closed);
#   6 повторный снимок обновляет базу (мусор между снимками — в базе);
#   7 cwd-независимость: сверка жертвы из ЧУЖОГО git-репозитория называет имя
#     ЖЕРТВЫ, не приманки (детектор сам несёт Н-85-гигиену);
#   8 снятие/сверка не загрязняют стерегомое: porcelain до == после, байтово
#     (оракул в памяти фикстуры — правило 8).
# Имена мусора и toy-корни случайны КАЖДЫЙ прогон — константный dispatch по
# именам не собирается ни на одном прогоне (демаркация 023, класс ebc57db).
# TMPDIR редиректится в WORK до вызовов субъекта — снимки стаб-форм ложатся в
# скратч прогона и умирают trap'ом (само-чистка; договор TMPDIR уважает).
#
# СЕГОДНЯ (детектора в дереве нет) файл красен именованным отсутствием
# предмета — это и есть предъявляемое красное. Ожидания фаз пробы слабых форм
# (probe_slabyh_detektora.sh) стабильны до и после реализации.
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

ok()   { printf '  ok   ворота %s (%s)\n' "$1" "$2" >&2; }
fail() { printf 'ОТКАЗ ворота %s (%s): %s\n' "$1" "$2" "$3" >&2; exit 1; }
has()  { printf '%s\n' "$SUBJ_OUT" | grep -qF -- "$1"; }

# Живой git-чекаут «основного дерева» toy: два tracked-файла — каналы ночи.
mk_main() {  # <каталог>
  mkdir -p "$1/.githooks" "$1/scripts"
  printf '# toy hook\n'   > "$1/.githooks/pre-push"
  printf '# toy spawn\n'  > "$1/scripts/spawn_agent.sh"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$1"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$1" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$1" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      commit -q -m 'toy main'
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

# ── ворота 3: мусор ДО снимка не красен (дельта, не абсолют) ──────────────────
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

# ── ворота 4: чистка после снимка не красна (исчезновение — не утечка) ────────
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

# ── ворота 7: cwd-независимость (сверка жертвы из ЧУЖОГО репозитория) ────────
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
ok 7 "cwd-независимость: названа жертва, не приманка"

# ── ворота 8: снятие/сверка не загрязняют стерегомое ──────────────────────────
M8="$WORK/v8_samo-chistka_${RANDOM}"
mk_main "$M8"
POR_BEFORE="$(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$M8" status --porcelain)"           # оракул в ПАМЯТИ фикстуры (правило 8)
run_subj "$M8" --snapshot "$M8"
[ "$SUBJ_RC" -eq 0 ] || fail 8 "само-чистота" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
run_subj "$M8" --check "$M8"
[ "$SUBJ_RC" -eq 0 ] || fail 8 "само-чистота" "rc=$SUBJ_RC (ожидался 0). Вывод: $SUBJ_OUT"
has "$P_CHISTO" || fail 8 "само-чистота" "нет маркера «$P_CHISTO». Вывод: $SUBJ_OUT"
POR_AFTER="$(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$M8" status --porcelain)"
[ "$POR_BEFORE" = "$POR_AFTER" ] || fail 8 "само-чистота" "снятие/сверка изменили porcelain стерегомого: до=[$POR_BEFORE] после=[$POR_AFTER] — снимок пишет в стерегомое дерево"
ok 8 "снятие/сверка не загрязняют стерегомое"

printf 'red_detektor_utechek: 8 ворот зелены\n' >&2
exit 0
