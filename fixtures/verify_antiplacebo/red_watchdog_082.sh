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
# причинами фаз Б1-Б4; ПОСЛЕ реализации — rc 0. Приёмка — А1 контракта 082.
#
# ФАЗЫ (порядок: зелёный контроль → зелёный медленный → боль по сайтам):
#   ЗК  зелёный контроль зонда: честное подставное дерево (каркас как в _fake_root.sh,
#       переизобретения нет) — раннер обязан быть зелёным И СЕГОДНЯ; отделяет «зонд сломан»
#       от «боль жива»;
#   ЗС  зелёный МЕДЛЕННО-ЖИВОЙ: игрушка спит 2с на вызов (~6с на кейс с повтором) — при
#       AP_CASE_BUDGET=30 и БЕЗ переменной (дефолт) кейс судится нормально, слова «таймаут»
#       в выводе быть не обязано (нет false positive на медленном живом);
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
#       после: именованный таймаут-FAIL по кейсу.
# Все вечные сны несут уникальный токен 555.082 в командной строке; раннеру каждой фазе —
# свой явный VERIFY_ANTIPLACEBO_SCRATCH под $WORK пробы: EXIT-ловушка добивает выживших
# по токену и по пути скратча, красный прогон станцию не травит.
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

BUDGET=5   # пер-кейсный бюджет болевых фаз (после реализации)
OUTER=40   # внешний потолок ПРОБЫ: сегодня им убивается зависший раннер;
           # после реализации раннер обязан закончиться много раньше (бюджет 5с на кейс)

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

mk_case() { printf '%s\n' "$2" > "$WORK/$1/fixtures/verify_toy/$3"; }

# run_runner <имя-фазы> <корень> [ENV=VAL …] — раннер над подставным корнем под внешним
# потолком; вывод — в память пробы (правило 8: диск проверяемого как истина не перечитывается)
run_runner() {
  local name="$1" r="$2"; shift 2
  local t0; t0=$SECONDS
  OUT="$(timeout -k 3 "$OUTER" env "VERIFY_ANTIPLACEBO_SCRATCH=$WORK/scratch-$name" "$@" \
         bash "$RUNNER" "$r" 2>&1)"; RC=$?
  WALL=$((SECONDS - t0))
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

# ── Б1: боль A — субъект висит внутри ap_run; следующий кейс обязан судиться ────
mk_root b1; mk_toy b1 "$TOY_HANG_FLAG"
mk_case b1 "$CASE_HANG" case_1_zavis_subekt.sh
mk_case b1 "$CASE_HONEST" case_2_chestnyj.sh
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

if [ "$pains" -gt 0 ]; then
  printf 'red_watchdog_082: болей предъявлено %d — пер-кейсного дедлайна у раннера нет (контракт 082)\n' "$pains" >&2
  exit 1
fi
printf 'red_watchdog_082: все фазы зелёные — пер-кейсный дедлайн жив (контракт 082)\n' >&2
exit 0
