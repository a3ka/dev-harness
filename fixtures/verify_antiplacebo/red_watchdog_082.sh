#!/usr/bin/env bash
# КРАСНОЕ контракта 082 — у раннера verify_antiplacebo нет пер-кейсного дедлайна:
# зависший кейс держит прогон до внешнего потолка (замер CI 2026-10-04: 2 из 14 ap3-прогонов
# убиты в 30m16s по timeout-minutes: 30). Сайты блокировки по main af493c4:
#   A  исполнение субъекта ap_run (:686) — без таймаута;
#   B  запись ответа в resp-FIFO (:696) — open-for-write мёртвому клиенту (обёртка :649-668);
#   C  цикл обслуживания (:699-702) — кейс жив, заявок не пишет, не выходит; wait (:705)
#      недостижим;
#   D  повторный прогон кандидата (:743) — тот же барьер тем же кодом, бюджета нет.
# Боль по дереву: Н-158 (NABLIUDENIA.md:1042 — «если повторится — эскалировать в контракт на
# сам раннер»; повторилось), А-315 (NABLIUDENIA_ARCHITECT.md:7523, ОТКРЫТО).
#
# Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (прецедент 058/070, scripts/verify_antiplacebo.sh:585):
# до реализации предмет предъявляется ПРЯМЫМ запуском. Сегодня файл красен именованными
# причинами клеток Б1–Б7, БН (и ДФ при расхождении с эталоном); ПОСЛЕ реализации — rc 0.
# Приёмка — А1 контракта 082.
#
# ФАЗЫ (порядок: зелёные контроли → боль по сайтам A–D → размер/стена/группа → разбор → дифференциал):
#   ЗК  зелёный контроль зонда: честное подставное дерево (каркас как в _fake_root.sh,
#       переизобретения нет) — раннер обязан быть зелёным И СЕГОДНЯ; отделяет «зонд сломан»
#       от «боль жива»;
#   ЗС  зелёный МЕДЛЕННО-ЖИВОЙ: игрушка спит 2с на вызов (~6с на кейс с повтором) — при
#       AP_CASE_BUDGET=30 и БЕЗ переменной (дефолт) кейс судится нормально, слова «таймаут»
#       в выводе быть не обязано (нет false positive на медленном живом);
#   ЗБ  зелёный tight-бюджет (зеркало Б5/Б6, блокер-1 круга v2): сумма фаз кейса ~2с при
#       AP_CASE_BUDGET=5 — rc=0 без «таймаут»: стена не стреляет по укладывающемуся;
#   Б1  боль A: кейс_1 зовёт барьер, игрушка на красном вызове (флаг .zavis) спит неограниченно
#       — сегодня раннер убит внешним потолком пробы (rc 124); после: именованный таймаут-FAIL
#       по кейсу_1 + кейс_2 (честный, идёт СЛЕДОМ) получает ок-вердикт — бюджет ПЕР-КЕЙСНЫЙ,
#       не глобальный (стаб-ловушка инварианта 5);
#   Б2  боль B: кейс зовёт барьер под `timeout 1`, игрушка на красном вызове спит 3с — клиент
#       умирает раньше ответа, раннер блокируется на записи в resp-FIFO — сегодня rc 124;
#       после: зависания нет, кейс судится (ок или таймаут — стратегия реализации свободна:
#       дедлайн ИЛИ неблокирующая запись), прогон заканчивается с вердиктом по кейсу;
#   Б3  боль C: честный вызов, затем сон навсегда — цикл обслуживания крутится вечно —
#       сегодня rc 124; после: именованный таймаут-FAIL по кейсу;
#   Б4  боль D: игрушка спит неограниченно на ВТОРОМ красном вызове (счётчик .raz), кейс
#       честно заканчивается, зависает ПОВТОРНЫЙ прогон проверяющего — сегодня rc 124;
#       после: именованный таймаут-FAIL по кейсу;
#   Б5  боль РАЗМЕР бюджета (блокер-1 круга v2): одиночный зависший кейс при AP_CASE_BUDGET=5 —
#       таймаут-FAIL обязан прийти со стеной ≤ 5+TOL (допуск объявлен числом, см. TOL ниже);
#       подмена «всегда-N» (N≥10) красна превышением стены, «нет дедлайна» — rc 124/137 потолка;
#   Б6  боль ЕДИНАЯ стена (блокер-1 круга v2): кейс из фаз по 3с — каждая фаза < 5, сумма 6 > 5 —
#       обязан получить таймаут-FAIL; пер-фазовый сброс бюджета красен отсутствием «таймаут»;
#   Б7  боль УБИЙСТВО исходной группы (блокер-2 круга v2): ПОСЛЕ возврата раннера и ДО
#       страховочной чистки зонда (грация 1с на асинхронный сигнал) в setsid-группе кейса нет
#       живых — наблюдение pgrep по токену сна и пути корня фазы; «правильный вывод без
#       убийства» красен;
#   БН  боль РАЗБОР бюджета (блокер-3 круга v2): AP_CASE_BUDGET из {0, -5, abc, пустая} — rc=1,
#       причина именует AP_CASE_BUDGET, маркер запуска кейса НЕ создан (наблюдаемое
#       «до запуска кейсов»); контроль: 7 на том же каркасе — rc=0 и маркер есть.
#       МАРКЕР (арбитраж 082/а-в): один путь zapusk_mark <фаза> — вне стерегомого корня
#       фазы, внутри $WORK пробы; кейсу — окружением ZAPUSK_MARK_082 через run_runner
#       (раннер пропускает чужие переменные, снимая только BARRIER_ROOT/AP_REQ/AP_RESP);
#       конструктор CASE_SENTINEL и все пять наблюдений (БН×4 + контроль) читают этот
#       ОДИН путь — перенос маркера без переноса наблюдений = тавтология (082/б);
#       диагноз контроля разведён (082/в): маркера нет → «не запустил кейс»; маркер есть
#       и rc≠0 → «кейс запущен, но раннер красен: <причина из вывода>»;
#   ДФк контроль компаратора (блокер-4 круга v2): diff_scoped_082.sh различает тождество (0),
#       подмену строки вердикта (1), подмену rc (1) — вечно-нулевой дифференциал красен;
#   ДФ  живой дифференциал А2 (блокер-4 круга v2): scoped-прогон настоящего дерева клона против
#       закоммиченного эталона ДО do_check_spec_ready_082.txt — машиной, кодом возврата.
# Все вечные сны несут уникальный токен 555.082 в командной строке; раннеру каждой фазе —
#   свой явный VERIFY_ANTIPLACEBO_SCRATCH под $WORK пробы; МЕЖФАЗНАЯ чистка (dobit_ostatki)
#   добивает выживших прошлых болевых фаз до следующей — наблюдение Б7 всегда ИСПолняется до
#   её вызова; EXIT-ловушка добивает оставшихся по токену и пути скратча и стирает $WORK целиком
#   (маркеры запуска ZAPUSK_BIL_082.<фаза> живут в ней — арбитраж 082/а), прогон станцию не травит.
#
# Коды возврата: 0 — все фазы зелёные (после реализации); 1 — именованный отказ
#                (боль жива / зонд сломан); 2 — нечем проверить.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
RUNNER="$REPO/scripts/verify_antiplacebo.sh"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/red082-watchdog.XXXXXX")"
trap 'pkill -f "sleep 555\.082" 2>/dev/null; pkill -f "$WORK" 2>/dev/null; rm -rf "$WORK"' EXIT

pains=0
fail() { printf 'FAIL 082 %s\n' "$1" >&2; pains=$((pains + 1)); }
soderzhit() { case "$1" in *"$2"*) return 0 ;; *) return 1 ;; esac; }
command -v timeout >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет timeout(1)\n' >&2; exit 2; }
command -v pgrep  >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет pgrep(1) — нечем наблюдать группу (Б7)\n' >&2; exit 2; }
command -v pkill  >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет pkill(1)\n' >&2; exit 2; }

BUDGET=5   # пер-кейсный бюджет болевых фаз (после реализации)
OUTER=40   # внешний потолок ПРОБЫ: сегодня им убивается зависший раннер;
           # после реализации раннер обязан закончиться много раньше (бюджет 5с на кейс)
TOL=4     # допуск измерения клетки Б5 (блокер-1 круга v2): честная стена кейса = старт
          # раннера + бюджет + планирование; подмена «всегда-10с» даёт стену ≥10с, «всегда-
          # 30с» ≥30с — обе > 5+4=9, джиттер старта (замер живьём по ЗК в выводе фазы)
          # в 4с укладывается с запасом.

# ── каркас подставного дерева (грамматика _fake_root.sh: один барьер-игрушка + фикстуры) ──
mk_root() { mkdir -p "$WORK/$1/scripts" "$WORK/$1/fixtures/verify_toy" "$WORK/$1/tmp"; }

mk_toy() {  # <корень> <тело-игрушки>
  {
    printf '#!/usr/bin/env bash\n'
    printf '# Барьер-игрушка (082): красен, если в корне лежит файл `.slomano`.\n'
    printf '# Коды возврата: 0 — цело, 1 — сломано, 2 — нечем проверить.\n'
    printf 'here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"\n'
    printf '%s\n' "$2"
  } > "$WORK/$1/scripts/verify_toy.sh"
  chmod +x "$WORK/$1/scripts/verify_toy.sh"
}

TOY_FAST='if [ -e "$here/.slomano" ]; then printf "ОТКАЗ: игрушка сломана\n" >&2; exit 1; fi
printf "  ok   игрушка цела\n" >&2'

TOY_SLOW='sleep 2
if [ -e "$here/.slomano" ]; then printf "ОТКАЗ: игрушка сломана\n" >&2; exit 1; fi
printf "  ok   игрушка цела\n" >&2'

TOY_HANG_FLAG='if [ -e "$here/.slomano" ]; then
  if [ -f "$here/.zavis" ]; then sleep 555.082; fi
  printf "ОТКАЗ: игрушка сломана\n" >&2; exit 1
fi
printf "  ok   игрушка цела\n" >&2'

TOY_SLOW_RED='if [ -e "$here/.slomano" ]; then sleep 3; printf "ОТКАЗ: игрушка сломана\n" >&2; exit 1; fi
printf "  ok   игрушка цела\n" >&2'

TOY_S1RED='if [ -e "$here/.slomano" ]; then sleep 1; printf "ОТКАЗ: игрушка сломана\n" >&2; exit 1; fi
printf "  ok   игрушка цела\n" >&2'

TOY_HANG_RERUN='if [ -e "$here/.slomano" ]; then
  n=0; if [ -f "$here/.raz" ]; then n="$(cat "$here/.raz" 2>/dev/null || printf "%s" 0)"; fi
  n=$((n + 1)); printf "%s\n" "$n" > "$here/.raz"
  if [ "$n" -ge 2 ]; then sleep 555.082; fi
  printf "ОТКАЗ: игрушка сломана\n" >&2; exit 1
fi
printf "  ok   игрушка цела\n" >&2'

CASE_HONEST='# ПРИЧИНА: игрушка сломана
set -euo pipefail
mkdir -p "$WORK/scripts"
BARRIER_ROOT="$WORK" "$BARRIER"
touch "$WORK/.slomano"
BARRIER_ROOT="$WORK" "$BARRIER"'

CASE_HANG='# ПРИЧИНА: игрушка сломана
set -euo pipefail
mkdir -p "$WORK/scripts"
BARRIER_ROOT="$WORK" "$BARRIER"
touch "$WORK/.slomano" "$WORK/.zavis"
BARRIER_ROOT="$WORK" "$BARRIER"'

CASE_DEAD_CLIENT='# ПРИЧИНА: игрушка сломана
set -euo pipefail
mkdir -p "$WORK/scripts"
BARRIER_ROOT="$WORK" "$BARRIER"
touch "$WORK/.slomano"
BARRIER_ROOT="$WORK" timeout 1 "$BARRIER"'

CASE_NEVER_EXIT='# ПРИЧИНА: игрушка сломана
set -euo pipefail
mkdir -p "$WORK/scripts"
BARRIER_ROOT="$WORK" "$BARRIER"
sleep 555.082'
CASE_SENTINEL='# ПРИЧИНА: игрушка сломана
set -euo pipefail
touch "$ZAPUSK_MARK_082"
mkdir -p "$WORK/scripts"
BARRIER_ROOT="$WORK" "$BARRIER"
touch "$WORK/.slomano"
BARRIER_ROOT="$WORK" "$BARRIER"'


mk_case() { printf '%s\n' "$2" > "$WORK/$1/fixtures/verify_toy/$3"; }

# zapusk_mark <фаза> — ЕДИНСТВЕННОЕ определение пути маркера запуска кейса (арбитраж 082/а-б):
# вне стерегомого корня фазы ($WORK/<фаза> — слепок корня раннера его не видит) и внутри $WORK
# пробы (стирается EXIT-ловушкой зонда). Кейс получает путь окружением ZAPUSK_MARK_082 от
# run_runner — раннер снимает только BARRIER_ROOT/AP_REQ/AP_RESP, остальное доходит дословно;
# все пять наблюдений (БН×4 + БН-контроль) читают путь отсюда же — запись и проверка не
# могут разъехаться (главный риск правки по 082/б: путь, по которому никто не пишет).
zapusk_mark() { printf '%s/ZAPUSK_BIL_082.%s\n' "$WORK" "$1"; }

# run_runner <имя-фазы> <корень> [ENV=VAL …] — раннер над подставным корнем под внешним
# потолком; вывод — в память пробы (правило 8: диск проверяемого как истина не перечитывается)
run_runner() {
  local name="$1" r="$2"; shift 2
  local t0; t0=$SECONDS
  OUT="$(timeout -k 3 "$OUTER" env "VERIFY_ANTIPLACEBO_SCRATCH=$WORK/scratch-$name" \
         "ZAPUSK_MARK_082=$(zapusk_mark "$name")" "$@" \
         bash "$RUNNER" "$r" 2>&1)"; RC=$?
  WALL=$((SECONDS - t0))
}

# Межфазная страховочная чистка (НЕ часть наблюдения Б7): добивает вечные сны прошлых
# болевых фаз, чтобы наблюдение текущей фазы не видело чужих процессов. Наблюдение Б7
# всегда исполняется ДО вызова этой функции в своей фазе.
dobit_ostatki() { pkill -f 'sleep 555\.082' 2>/dev/null || true; }

# Число живых процессов фазы: вечные сны (токен 555.082) + любые процессы на корне фазы
# (кейс живёт по пути $WORK/<фаза>/…). Наблюдение — процессами станции, диск проверяемого
# как истина не перечитывается (правило 8).
schet_zhivykh() {  # <корень-фазы>
  local n=0 p
  for p in $(pgrep -f 'sleep 555\.082' 2>/dev/null); do n=$((n + 1)); done
  for p in $(pgrep -f -- "$1" 2>/dev/null); do n=$((n + 1)); done
  printf '%s' "$n"
}


# ── ЗК: зонд зелёный на честном дереве (зелёное И СЕГОДНЯ) ──────────────────────
mk_root zk; mk_toy zk "$TOY_FAST"; mk_case zk "$CASE_HONEST" case_chestnyj.sh
run_runner zk "$WORK/zk"
if [ "$RC" -ne 0 ]; then
  printf 'FAIL 082 ЗК: зонд сломан на честном дереве (rc=%s, wall=%sс) — это не боль 082:\n%s\n' \
    "$RC" "$WALL" "$OUT" >&2
  exit 1
fi
printf '  ok   ЗК: честное дерево зелёное (rc=0, %sс)\n' "$WALL" >&2

# ── ЗС: медленный-но-живой не краснеет (явный бюджет и дефолт) ──────────────────
mk_root zs; mk_toy zs "$TOY_SLOW"; mk_case zs "$CASE_HONEST" case_chestnyj.sh
for bud in "AP_CASE_BUDGET=30" "XDEFAULT=1"; do
  run_runner zs "$WORK/zs" "$bud"
  if [ "$RC" -ne 0 ] || soderzhit "$OUT" "таймаут"; then
    printf 'FAIL 082 ЗС: медленный-но-живой кейс (%s, rc=%s, wall=%sс) словил таймаут или отказ — ложный позитив:\n%s\n' \
      "$bud" "$RC" "$WALL" "$OUT" >&2
    exit 1
  fi
done
printf '  ok   ЗС: медленный-но-живой кейс судится нормально при бюджете 30 и дефолте\n' >&2

# ── ЗБ: зелёный tight-бюджет — сумма фаз кейса ~2с В бюджете 5 (зеркало Б5/Б6) ────
mk_root zb; mk_toy zb "$TOY_S1RED"; mk_case zb "$CASE_HONEST" case_chestnyj.sh
run_runner zb "$WORK/zb" "AP_CASE_BUDGET=5"
if [ "$RC" -ne 0 ] || soderzhit "$OUT" "таймаут"; then
  printf 'FAIL 082 ЗБ: кейс с суммой фаз ~2с при бюджете 5 словил таймаут/отказ (rc=%s, wall=%sс) — стена стреляет по укладывающемуся (ложный позитив):\n%s\n' \
    "$RC" "$WALL" "$OUT" >&2
  exit 1
fi
printf '  ok   ЗБ: сумма фаз ~2с укладывается в бюджет 5 — без таймаута (rc=0, %sс)\n' "$WALL" >&2

# ── Б1: боль A — субъект висит внутри ap_run; следующий кейс обязан судиться ────
mk_root b1; mk_toy b1 "$TOY_HANG_FLAG"
mk_case b1 "$CASE_HANG" case_1_zavis_subekt.sh
mk_case b1 "$CASE_HONEST" case_2_chestnyj.sh
dobit_ostatki
run_runner b1 "$WORK/b1" "AP_CASE_BUDGET=$BUDGET"
if [ "$RC" -eq 124 ]; then
  fail "Б1: раннер завис на исполнении субъекта (сайт A, :686) и убит внешним потолком за ${WALL}с — пер-кейсного дедлайна нет"
elif [ "$RC" -eq 137 ]; then
  fail "Б1: раннер не вышел по SIGTERM — убит SIGKILL внешнего потолка (сайт A)"
elif [ "$RC" -ne 1 ]; then
  fail "Б1: после реализации rc=$RC (ожидался 1: таймаут-FAIL одного кейса не роняет суд остальных)"
elif ! soderzhit "$OUT" "case_1_zavis_subekt.sh" || ! soderzhit "$OUT" "таймаут"; then
  fail "Б1: таймаут-FAIL не именует кейс и/или не называет таймаут (инв. 2)"
elif ! soderzhit "$OUT" "ok   verify_toy/case_2_chestnyj.sh"; then
  fail "Б1: кейс_2 после зависшего не получил ок-вердикт — бюджет глобальный или раннер не продолжил (инв. 5)"
elif [ "$WALL" -gt "$OUTER" ]; then
  fail "Б1: прогон вышел за внешний потолок пробы (${WALL}с)"
else
  printf '  ok   Б1: сайт A — именованный таймаут по кейсу_1, кейс_2 судится (rc=1, %sс)\n' "$WALL" >&2
fi

# ── Б2: боль B — клиент умер до ответа, запись в resp-FIFO блокируется ─────────
mk_root b2; mk_toy b2 "$TOY_SLOW_RED"; mk_case b2 "$CASE_DEAD_CLIENT" case_klient_umer.sh
dobit_ostatki
run_runner b2 "$WORK/b2" "AP_CASE_BUDGET=$BUDGET"
if [ "$RC" -eq 124 ] || [ "$RC" -eq 137 ]; then
  fail "Б2: раннер завис на записи ответа мёртвому клиенту (сайт B, :696) и убит внешним потолком за ${WALL}с — пер-кейсного дедлайна/неблокирующей записи нет"
elif [ "$RC" -ne 0 ] && [ "$RC" -ne 1 ]; then
  fail "Б2: после реализации rc=$RC — прогон не закончился своим вердиктом"
elif ! soderzhit "$OUT" "case_klient_umer.sh"; then
  fail "Б2: кейс не получил вердикта (ок или таймаут) — раннер молча проглотил кейс"
elif [ "$WALL" -gt "$OUTER" ]; then
  fail "Б2: прогон вышел за внешний потолок пробы (${WALL}с)"
else
  printf '  ok   Б2: сайт B — мёртвый клиент не вешает прогон, кейс судится (rc=%s, %sс)\n' "$RC" "$WALL" >&2
fi

# ── Б3: боль C — кейс жив, заявок не пишет, не выходит ─────────────────────────
mk_root b3; mk_toy b3 "$TOY_FAST"; mk_case b3 "$CASE_NEVER_EXIT" case_ne_vyhodit.sh
dobit_ostatki
run_runner b3 "$WORK/b3" "AP_CASE_BUDGET=$BUDGET"
if [ "$RC" -eq 124 ] || [ "$RC" -eq 137 ]; then
  fail "Б3: раннер закрутился навсегда в цикле обслуживания (сайт C, :699-702) и убит внешним потолком за ${WALL}с"
elif [ "$RC" -ne 1 ]; then
  fail "Б3: после реализации rc=$RC (ожидался 1)"
elif ! soderzhit "$OUT" "case_ne_vyhodit.sh" || ! soderzhit "$OUT" "таймаут"; then
  fail "Б3: таймаут-FAIL не именует кейс и/или не называет таймаут (инв. 2)"
elif [ "$WALL" -gt "$OUTER" ]; then
  fail "Б3: прогон вышел за внешний потолок пробы (${WALL}с)"
else
  printf '  ok   Б3: сайт C — неотEXITящий кейс получает именованный таймаут (rc=1, %sс)\n' "$WALL" >&2
fi

# ── Б4: боль D — зависает повторный прогон проверяющего ────────────────────────
mk_root b4; mk_toy b4 "$TOY_HANG_RERUN"; mk_case b4 "$CASE_HONEST" case_zavis_povtora.sh
dobit_ostatki
run_runner b4 "$WORK/b4" "AP_CASE_BUDGET=$BUDGET"
if [ "$RC" -eq 124 ] || [ "$RC" -eq 137 ]; then
  fail "Б4: завис повторный прогон проверяющего (сайт D, :743) — убит внешним потолком за ${WALL}с"
elif [ "$RC" -ne 1 ]; then
  fail "Б4: после реализации rc=$RC (ожидался 1)"
elif ! soderzhit "$OUT" "case_zavis_povtora.sh" || ! soderzhit "$OUT" "таймаут"; then
  fail "Б4: таймаут-FAIL не именует кейс и/или не называет таймаут (инв. 2, 7)"
elif [ "$WALL" -gt "$OUTER" ]; then
  fail "Б4: прогон вышел за внешний потолок пробы (${WALL}с)"
else
  printf '  ok   Б4: сайт D — зависший повторный прогон получает именованный таймаут (rc=1, %sс)\n' "$WALL" >&2
fi

# ── Б5: боль «размер бюджета» — заявленные 5с обязаны стать стеной кейса (блокер-1 v2) ──
mk_root b5; mk_toy b5 "$TOY_HANG_FLAG"; mk_case b5 "$CASE_HANG" case_zavis_b5.sh
dobit_ostatki
run_runner b5 "$WORK/b5" "AP_CASE_BUDGET=$BUDGET"
if [ "$RC" -eq 124 ] || [ "$RC" -eq 137 ]; then
  fail "Б5: дедлайна нет вовсе — раннер убит внешним потолком за ${WALL}с при заявленном бюджете $BUDGET: размер бюджета не доказан (блокер-1 круга v2)"
elif [ "$RC" -ne 1 ]; then
  fail "Б5: rc=$RC (ожидался 1: таймаут-FAIL зависшего кейса)"
elif ! soderzhit "$OUT" "case_zavis_b5.sh" || ! soderzhit "$OUT" "таймаут"; then
  fail "Б5: таймаут-FAIL не именует кейс и/или не называет таймаут (инв. 2)"
elif [ "$WALL" -gt $((BUDGET + TOL)) ]; then
  fail "Б5: стена кейса ${WALL}с превысила бюджет $BUDGET + допуск $TOL — заявленный РАЗМЕР не соблюдён (подмена «всегда-N»), блокер-1 круга v2"
else
  printf '  ok   Б5: бюджет %sс соблюдён — стена %sс ≤ %s+%sс, таймаут именован (rc=1)\n' "$BUDGET" "$WALL" "$BUDGET" "$TOL" >&2
fi

# ── Б6: боль «единая стена» — фазы по 3с: каждая < 5, сумма 6 > 5 (блокер-1 v2) ────
mk_root b6; mk_toy b6 "$TOY_SLOW_RED"; mk_case b6 "$CASE_HONEST" case_summa_faz.sh
dobit_ostatki
run_runner b6 "$WORK/b6" "AP_CASE_BUDGET=$BUDGET"
if [ "$RC" -eq 124 ] || [ "$RC" -eq 137 ]; then
  fail "Б6: прогон убит внешним потолком за ${WALL}с — кейс из фаз по 3с не должен висеть вовсе"
elif [ "$RC" -ne 1 ]; then
  fail "Б6: rc=$RC (ожидался 1: сумма фаз 6с > бюджета $BUDGET — таймаут-FAIL)"
elif ! soderzhit "$OUT" "case_summa_faz.sh" || ! soderzhit "$OUT" "таймаут"; then
  fail "Б6: кейс накопил 6с > бюджета $BUDGET, а таймаут-FAIL не предъявлен — стена не единая/не накопительная (сброс по фазам), блокер-1 круга v2"
elif [ "$WALL" -gt "$OUTER" ]; then
  fail "Б6: прогон вышел за внешний потолок пробы (${WALL}с)"
else
  printf '  ok   Б6: единая стена — сумма фаз 6с > бюджета %sс, таймаут именован (rc=1, %sс)\n' "$BUDGET" "$WALL" >&2
fi

# ── Б7: боль «убийство исходной группы» — наблюдение ДО страховочной чистки (блокер-2 v2) ──
mk_root b7; mk_toy b7 "$TOY_FAST"; mk_case b7 "$CASE_NEVER_EXIT" case_ne_vyhodit_gruppy.sh
dobit_ostatki
run_runner b7 "$WORK/b7" "AP_CASE_BUDGET=$BUDGET"
zhivy="$(schet_zhivykh "$WORK/b7")"
if [ "$zhivy" -gt 0 ]; then  # грация 1с: асинхронный сигнал мог не дойти; обход живёт вечно — и ловится этой грацией
  sleep 1
  zhivy="$(schet_zhivykh "$WORK/b7")"
fi
if [ "$RC" -eq 124 ] || [ "$RC" -eq 137 ]; then
  fail "Б7: дедлайна нет — раннер убит внешним потолком за ${WALL}с, исходная группа кейса при этом ЖИВА (${zhivy} проц.) — убийство группы (инв. 2) не доказано"
elif [ "$zhivy" -gt 0 ]; then
  fail "Б7: вердикт/код корректны, но исходная группа кейса жива (≥1с после возврата раннера, ${zhivy} проц.) ДО страховочной чистки зонда — убийство не исполнено (инв. 2), блокер-2 круга v2"
elif [ "$RC" -ne 1 ] || ! soderzhit "$OUT" "case_ne_vyhodit_gruppy.sh" || ! soderzhit "$OUT" "таймаут"; then
  fail "Б7: rc=$RC — именованный таймаут по неотEXITящему кейсу не предъявлен (инв. 2)"
else
  printf '  ok   Б7: исходная группа кейса убита до возврата раннера (0 живых, rc=1, %sс)\n' "$WALL" >&2
fi

# ── БН: боль «fail-closed разбора AP_CASE_BUDGET» — кейс не запускается вовсе (блокер-3 v2) ──
i=0
for v in 0 -5 abc ''; do
  i=$((i + 1)); koren="bn$i"
  mk_root "$koren"; mk_toy "$koren" "$TOY_FAST"; mk_case "$koren" "$CASE_SENTINEL" case_strazh_starta.sh
  dobit_ostatki
  run_runner "$koren" "$WORK/$koren" "AP_CASE_BUDGET=$v"
  mark="$(zapusk_mark "$koren")"   # тот же путь, что и конструктору окружением (арбитраж 082/б)
  if [ "$RC" -eq 1 ] && soderzhit "$OUT" "AP_CASE_BUDGET" && [ ! -e "$mark" ]; then
    printf '  ok   БН: AP_CASE_BUDGET=<%s> — именованный отказ ДО запуска кейсов (маркер не создан)\n' "${v:-пустая}" >&2
  elif [ -e "$mark" ]; then
    fail "БН: AP_CASE_BUDGET=<${v:-пустая}> принята молча — кейс ЗАПУЩЕН (маркер запуска ZAPUSK_BIL_082 создан, rc=$RC): отказа до запуска кейсов нет (инв. 6), блокер-3 круга v2"
  elif [ "$RC" -eq 1 ]; then
    fail "БН: AP_CASE_BUDGET=<${v:-пустая}> дала rc=1, но причина не именует AP_CASE_BUDGET (инв. 6)"
  else
    fail "БН: AP_CASE_BUDGET=<${v:-пустая}> — ни именованного отказа, ни наблюдаемого незапуска (rc=$RC, маркера нет) — поведение не определено (инв. 6)"
  fi
done
# зеркальный честный контроль: валидный бюджет на том же каркасе ЗАПУСКАЕТ кейс — отказ избирателен
mk_root bnv; mk_toy bnv "$TOY_FAST"; mk_case bnv "$CASE_SENTINEL" case_strazh_starta.sh
run_runner bnv "$WORK/bnv" "AP_CASE_BUDGET=7"
mark="$(zapusk_mark bnv)"   # тот же путь, что и конструктору окружением (арбитраж 082/б)
if [ "$RC" -eq 0 ] && [ -e "$mark" ]; then
  printf '  ok   БН-контроль: валидный AP_CASE_BUDGET=7 запускает кейс, судится зелёным (rc=0)\n' >&2
elif [ ! -e "$mark" ]; then
  fail "БН-контроль: валидный AP_CASE_BUDGET=7 не запустил кейс (rc=$RC, маркер запуска не создан) — отказ не избирателен: «всегда-отказ» не лучше молчаливого принятия (инв. 6)"
else
  prichina="$(printf '%s\n' "$OUT" | grep -m1 'FAIL' || true)"
  fail "БН-контроль: кейс запущен (маркер запуска есть), но раннер красен rc=$RC: ${prichina:-в выводе нет FAIL-строки} — это не «не запустил кейс» (арбитраж 082/в)"
fi

# ── ДФк: контроль компаратора — проверка проверки (блокер-4 круга v2) ─────────────
DIF="$HERE/diff_scoped_082.sh"
ETALON="$HERE/do_check_spec_ready_082.txt"
[ -f "$DIF" ] && [ -f "$ETALON" ] || {
  printf 'FAIL 082 ДФк: нет компаратора diff_scoped_082.sh или эталона do_check_spec_ready_082.txt рядом с батареей — зонд сломан\n' >&2
  exit 1
}
mkdir -p "$WORK/dif"
printf '  ok   check_spec_ready/case_sint_a.sh: повторный прогон красный кодом 1 — «синт А»\n  FAIL lib_sint.sh: не классифицирован\nrc=1\n' > "$WORK/dif/do.txt"
cp "$WORK/dif/do.txt" "$WORK/dif/posle.txt"
bash "$DIF" "$WORK/dif/do.txt" "$WORK/dif/posle.txt" >/dev/null 2>&1
[ "$?" -eq 0 ] || { printf 'FAIL 082 ДФк: компаратор не зелёен на идентичных файлах — зонд сломан\n' >&2; exit 1; }
sed 's/«синт А»/«синт Б»/' "$WORK/dif/do.txt" > "$WORK/dif/posle.txt"
bash "$DIF" "$WORK/dif/do.txt" "$WORK/dif/posle.txt" >/dev/null 2>&1
[ "$?" -eq 1 ] || { printf 'FAIL 082 ДФк: компаратор НЕ поймал подмену строки вердикта — вечно-нулевой дифференциал, зонд сломан\n' >&2; exit 1; }
sed 's/^rc=1$/rc=0/' "$WORK/dif/do.txt" > "$WORK/dif/posle.txt"
bash "$DIF" "$WORK/dif/do.txt" "$WORK/dif/posle.txt" >/dev/null 2>&1
[ "$?" -eq 1 ] || { printf 'FAIL 082 ДФк: компаратор НЕ поймал подмену rc — зонд сломан\n' >&2; exit 1; }
printf '  ok   ДФк: компаратор различает тождество (0), подмену строки (1), подмену rc (1)\n' >&2

# ── ДФ: живой дифференциал А2 — scoped-прогон клона против закоммиченного эталона ДО ──
t0=$SECONDS
OUTD="$(timeout -k 3 "$OUTER" env "VERIFY_ANTIPLACEBO_SCRATCH=$WORK/scratch-dif" bash "$RUNNER" --scope check_spec_ready 2>&1)"; RCDIF=$?
printf '%s\nrc=%s\n' "$OUTD" "$RCDIF" > "$WORK/dif/posle.txt"
if bash "$DIF" "$ETALON" "$WORK/dif/posle.txt"; then
  printf '  ok   ДФ: живой scoped-прогон совпал с эталоном ДО (rc=%s, %sс) — дифференциал машиной (инв. 7)\n' "$RCDIF" "$((SECONDS - t0))" >&2
else
  fail "ДФ: живой scoped-прогон разошёлся с эталоном ДО — инв. 7 (дифференциал, не «стало зелёным»); вывод компаратора выше, блокер-4 круга v2"
fi

if [ "$pains" -gt 0 ]; then
  printf 'red_watchdog_082: болей предъявлено %d — пер-кейсного дедлайна у раннера нет (контракт 082)\n' "$pains" >&2
  exit 1
fi
printf 'red_watchdog_082: все фазы зелёные — пер-кейсный дедлайн жив (контракт 082)\n' >&2
exit 0
