#!/usr/bin/env bash
# Клетка red_perehodnyj_gheit_perechen — инвариант З-6 контракта 099 (doc §3):
# переходный доверенный гейт допускает ТОЛЬКО точно перечисленные дефекты,
# исполненные ПОЛНОСТЬЮ, с доверенным происхождением проверок.
# Тринадцать входов (вход н — BLOCKS A099-M2-check-run-name-confusion,
# adversary круг 3; блокеры критика круга 1 :49/:48; входы и/к — граница
# арбитража 099 круга 3 по происхождению кода проверок; вход л — вердикт
# адверсария A099-M1 + Р1-5 reviewer 099 круга 1; вход м — Р1-6 reviewer
# 099 круга 1, нога производителя Решения 2, транзитивно):
#   (н) НЕоднозначность имени составляющей (A099-M2, adversary круг 3):
#       API-ответ несёт ДВА check-run с одним именем l1 (success + failure;
#       GitHub Checks API допускает до 1000 с одним именем); выбор первого
#       совпадения маскирует реальный отказ доверенного lane → именованный
#       отказ «составляющая неоднозначна: l1» В ОБА ПОРЯДКЕ (н-1 success
#       первым, н-2 failure первым — порядок не вправе менять вердикт;
#       0 совпадений уже ловится входами ж/г как «нет результата»).
#   (а) все составляющие зелёны → ДОПУСК;
#   (б) отказ l7a, совпадающий с реестром (sha строк), l7b зелёна → ДОПУСК;
#   (в) неизвестный отказ l7a → блокировка;
#   (г) l7a skipped → «нет результата»;
#   (д) то же ЧИСЛО красных, но красна ДРУГАЯ составляющая → блокировка;
#   (е) дельта трогает config/transition_defects_099.tsv → «база исключений
#       изменена кандидатом»;
#   (ж) раннее прерывание job: l7a отказ ТОЧНО из реестра, но составляющая l7b
#       БЕЗ результата в ответе → «нет результата: l7b» (хеш совпал — полноты
#       исполнения нет; блокер :49);
#   (з) подмена БАЙТ-МИНИМУМА кандидатом: команды ci.yml выпарены (run: true),
#       все имена зелёны → «проверки изменены кандидатом: .github/workflows/ci.yml»
#       (минимум = то, что платформа исполняет из объекта M: .github/workflows/ +
#       package.json; scripts/ и fixtures/ ИЗ МИНИМУМА ИСКЛЮЧЕНЫ — замер 5
#       арбитража 099: заморозка поверхности отказывала 20/40 легитимных лендов);
#   (и) происхождение кода: кандидат заменяет исполняемый проверкой l7a
#       scripts/check_toy.sh на пустую успешную команду, прежние пути не трогает
#       → проверка обязана дать ТОТ ЖЕ результат, что на честном дереве с кодом
#       M^1 (REAL CHECK EXECUTED / rc 1 — материализация замыкания из M^1), а не
#       rc 0; дверь даёт ТОТ ЖЕ вердикт, что честному дереву (ДОПУСК), НЕ отказ
#       «проверки изменены кандидатом: scripts/…»;
#   (к) парный вход: кандидат легитимно ДОБАВЛЯЕТ новую клетку и её скрипт
#       (байт-минимум не тронут) → допуск НЕ отказывает «проверки изменены
#       кандидатом» — новая клетка становится гейтом после своего ленда.
#   (л) ЖИВАЯ структурная сверка .github/workflows/ci.yml по СВОЙСТВУ 1г2
#       («все шаги workflow», не два токена — Р1-5 reviewer 099 круг 1):
#       ни один шаг проверяемой джобы не исполняет байты кандидата
#       (scripts/*, fixtures/*, npm-ключи package.json, config/* — дословно
#       Решение 1г2) ДО шага материализации; живой контрпример reviewer'а:
#       шаг кандидата до материализации делает git replace блоба M^1,
#       материализация восстанавливает подмену, lane отдаёт rc 0;
#   (м) нога производителя Решения 2 (Р1-6 reviewer 099 круга1):
#       пустая/отсутствующая таблица config/transition_producers_099.tsv
#       не вправе молча выключать ногу pr_dopusk; живая таблица несёт
#       РОВНО 13 имён обязательного набора, каждая строка связывает имя
#       с шагом workflow (файл существует, команда дословно).
# Реестр перехода — на СОСТАВЛЯЮЩИХ (шаг-гранулярность l7a/l7b, агрегата l7 нет):
# каждое имя обязано иметь completed-результат — допуск известного дефекта
# удостоверяет полноту остальных результатов и завершённость исполнения.
# До реализации красна «предмет отсутствует»; стаб-пак — battery_stubs.sh
# (t99-m1 вход в, t99-m5 вход д; оба ловятся и на ж/з).
# Проверочные записи передаются одной строкой с разделителем «|» (summary
# отказов содержит пробелы — совет критика круга 1 про некавыченный $2).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z99_BASE/zashchita-099-perechen-$$-${RANDOM}"
API_PID=""
cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; }
trap cleanup EXIT

if ! SUBJ="$(z99_subject pr_dopusk.sh)"; then
  printf 'КРАСНО: red_perehodnyj_gheit_perechen: предмет отсутствует: scripts/pr_dopusk.sh\n' >&2
  exit 1
fi

command -v sha256sum >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет sha256sum\n' >&2; exit 2; }

ALLGREEN='l1:success|l2:success|l3:success|l4:success|l5:success|l6:success|l7a:success|l7b:success|ap1:success|ap2:success|ap3:success|ap4:success|ap5:success'
L='check_protected: конфликт 263/266 (известный дефект main)'
L2='check_protected: НОВЫЙ отказ'
LHOST='иная проверка: новый отказ'
# sha256 отсортированных строк отказа (каждая с завершающим \n) — формула контракта, единый источник
L_SHA="$(printf '%s\n' "$L" | LC_ALL=C sort | sha256sum | awk '{print $1}')"

# Реестр перехода с исключением для l7a (13 составляющих, шаг-гранулярность)
REG="$(for n in l1 l2 l3 l4 l5 l6; do printf '%s\t-\n' "$n"; done; printf 'l7a\t%s\n' "$L_SHA"; printf 'l7b\t-\n'; for n in ap1 ap2 ap3 ap4 ap5; do printf '%s\t-\n' "$n"; done)"

# zcr <файл> <проверки|проверки> — ответ check-runs API из |-строки
zcr() {
  local f="$1" s="$2" IFS='|'
  read -ra _e <<<"$s"
  z99_json_checkruns "$f" "${_e[@]}"
}

# zpg <вход> <checks-строка> [Z99_BASE_DEFECTS]
zpg() {
  rm -rf "$W/api"
  Z99_BASE_DEFECTS="${3:-}" z99_mir_repo "$W" 1
  git -C "$Z99_REPO" tag frozen/contracts/099/1 "$Z99_M"
  git -C "$Z99_REPO" push -q origin refs/tags/frozen/contracts/099/1
  API="$(z99_api_dir "$W")"
  mkdir -p "$API/repos/o/r/pulls" "$API/repos/o/r/commits/$Z99_M"
  z99_json_pr "$API/repos/o/r/pulls/7" 7 "$Z99_B" "$Z99_M"
  zcr "$API/repos/o/r/commits/$Z99_M/check-runs" "$2"
  if [ -z "${API_PID:-}" ]; then
    sv="$(z99_api_serve "$API")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
    z99_wait_api "$PORT" || { printf 'КРАСНО: red_perehodnyj_gheit_perechen: стаб API не поднялся\n' >&2; exit 2; }
  fi
}
vypolnit() { # вызов субъекта; кладёт out/rc в оболочку клетки
  out="$(PR_DOPUSK_API="http://127.0.0.1:$PORT" bash "$SUBJ" "$Z99_REPO" --pr 7 2>&1)"; rc=$?
}
zelyona() { # <вход>: ждём ДОПУСК rc 0
  vypolnit
  if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq 'ДОПУСК'; then
    printf 'КРАСНО: red_perehodnyj_gheit_perechen: вход %s: ожидался ДОПУСК rc 0; факт rc=%s, вывод: %s\n' \
      "$1" "$rc" "$(printf '%s' "$out" | head -c 200)" >&2
    exit 1
  fi
}
krasno() { # <вход> <фраза>: ждём именованный отказ rc 1
  vypolnit
  if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq "$2"; then
    printf 'КРАСНО: red_perehodnyj_gheit_perechen: вход %s: ожидался отказ rc 1 «%s»; факт rc=%s, вывод: %s\n' \
      "$1" "$2" "$rc" "$(printf '%s' "$out" | head -c 200)" >&2
    exit 1
  fi
}

# (а) все составляющие зелёны (исключение в реестре НЕ требует красноты) → ДОПУСК
zpg а "$ALLGREEN" "$REG"
zelyona а

# (б) отказ l7a точно совпадает с реестром, l7b зелёна → ДОПУСК
zpg б "l1:success|l2:success|l3:success|l4:success|l5:success|l6:success|l7a:failure:$L|l7b:success|ap1:success|ap2:success|ap3:success|ap4:success|ap5:success" "$REG"
zelyona б

# (в) отказ l7a с ИНЫМ содержимым → «неизвестный отказ»
zpg в "l1:success|l2:success|l3:success|l4:success|l5:success|l6:success|l7a:failure:$L2|l7b:success|ap1:success|ap2:success|ap3:success|ap4:success|ap5:success" "$REG"
krasno в 'неизвестный отказ: l7a'

# (г) l7a skipped → «нет результата» (зелёная оболочка без фактического выполнения)
zpg г "l1:success|l2:success|l3:success|l4:success|l5:success|l6:success|l7a:skipped|l7b:success|ap1:success|ap2:success|ap3:success|ap4:success|ap5:success" "$REG"
krasno г 'нет результата: l7a'

# (д) то же ЧИСЛО красных (1), но красна ДРУГАЯ составляющая с иным текстом → блокировка
zpg д "l1:success|l2:success|l3:success|l4:success|l5:success|l6:success|l7a:success|l7b:success|ap1:success|ap2:failure:$LHOST|ap3:success|ap4:success|ap5:success" "$REG"
krasno д 'неизвестный отказ: ap2'

# (ж) раннее прерывание job (блокер :49): l7a отказ ТОЧНО из реестра, но
# составляющая l7b ВООБЩЕ НЕ ПРИСУТСТВУЕТ в ответе — у неё нет результата;
# совпадение хеша не доказывает полноту исполнения → блокировка
zpg ж "l1:success|l2:success|l3:success|l4:success|l5:success|l6:success|l7a:failure:$L|ap1:success|ap2:success|ap3:success|ap4:success|ap5:success" "$REG"
krasno ж 'нет результата: l7b'

# (н) A099-M2-check-run-name-confusion (adversary круг 3): dup-имя l1,
# один success + один failure; первый-match выбор двери маскирует отказ
zpg н-1 "l1:success|l1:failure:$L2|l2:success|l3:success|l4:success|l5:success|l6:success|l7a:success|l7b:success|ap1:success|ap2:success|ap3:success|ap4:success|ap5:success" "$REG"
krasno н-1 'составляющая неоднозначна: l1'
zpg н-2 "l1:failure:$L2|l1:success|l2:success|l3:success|l4:success|l5:success|l6:success|l7a:success|l7b:success|ap1:success|ap2:success|ap3:success|ap4:success|ap5:success" "$REG"
krasno н-2 'составляющая неоднозначна: l1'

# (е) дельта объекта трогает реестр перехода → «база исключений изменена кандидатом»
zpg е "$ALLGREEN" ""
printf 'l7a\t00000000000000000000000000000000000000000000000000000000000000ff\n' >| "$Z99_REPO/config/transition_defects_099.tsv"
git -C "$Z99_REPO" add config/transition_defects_099.tsv
git -C "$Z99_REPO" -c user.name=demo -c user.email=demo@dev-harness.local \
  commit -q -m "кандидат правит реестр перехода (toy)"
M2="$(git -C "$Z99_REPO" rev-parse HEAD)"
git -C "$Z99_REPO" tag -f frozen/contracts/099/1 "$M2"
git -C "$Z99_REPO" push -q -f origin refs/tags/frozen/contracts/099/1
mkdir -p "$W/api/repos/o/r/commits/$M2"
z99_json_pr "$W/api/repos/o/r/pulls/7" 7 "$Z99_B" "$M2"
zcr "$W/api/repos/o/r/commits/$M2/check-runs" "$ALLGREEN"
krasno е 'база исключений изменена кандидатом'

# (з) подмена проверок кандидатом (блокер :48): команды ci.yml выпарены до
# «run: true», имена/статусы прежние (13 зелёных) — доверенный источник команд
# это байты поверхности первого родителя → блокировка ДО статусов
zpg з "$ALLGREEN" ""
printf 'name: ci\non: pull_request\njobs:\n  checks:\n    steps:\n      - run: true\n' >| "$Z99_REPO/.github/workflows/ci.yml"
git -C "$Z99_REPO" add .github/workflows/ci.yml
git -C "$Z99_REPO" -c user.name=demo -c user.email=demo@dev-harness.local \
  commit -q -m "кандидат выпаривает команды проверок (toy)"
M3="$(git -C "$Z99_REPO" rev-parse HEAD)"
git -C "$Z99_REPO" tag -f frozen/contracts/099/1 "$M3"
git -C "$Z99_REPO" push -q -f origin refs/tags/frozen/contracts/099/1
mkdir -p "$W/api/repos/o/r/commits/$M3"
z99_json_pr "$W/api/repos/o/r/pulls/7" 7 "$Z99_B" "$M3"
zcr "$W/api/repos/o/r/commits/$M3/check-runs" "$ALLGREEN"
krasno з 'проверки изменены кандидатом: .github/workflows/ci.yml'

# (и) происхождение кода проверок (граница арбитража 099 по З-5): кандидат
# выпаривает исполняемый проверкой l7a scripts/check_toy.sh; код гейта —
# из ПЕРВОГО РОДИТЕЛЯ M^1 (материализация замыкания шагом workflow M^1)
zpg и "l1:success|l2:success|l3:success|l4:success|l5:success|l6:success|l7a:failure:$L|l7b:success|ap1:success|ap2:success|ap3:success|ap4:success|ap5:success" "$REG"
# (и-1) честное дерево M^1: проверка реально исполнена — rc 1, метка REAL CHECK
# EXECUTED, строка известного дефекта
git -C "$Z99_REPO" worktree add -q --detach "$W/i-honest" "$Z99_A"
h_out="$(cd "$W/i-honest" && bash fixtures/_krasnye_toy.sh 2>&1)"; h_rc=$?
if [ "$h_rc" -ne 1 ] || ! printf '%s' "$h_out" | grep -Fq 'REAL CHECK EXECUTED' || ! printf '%s' "$h_out" | grep -Fq "$L"; then
  printf 'КРАСНО: red_perehodnyj_gheit_perechen: вход и-1: честное дерево не даёт REAL CHECK EXECUTED/rc 1; факт rc=%s, вывод: %s\n' "$h_rc" "$(printf '%s' "$h_out" | head -c 200)" >&2
  exit 1
fi
# кандидат: scripts/check_toy.sh → пустая успешная команда, прежние пути не тронуты
printf '#!/usr/bin/env bash\nexit 0\n' >| "$Z99_REPO/scripts/check_toy.sh"
git -C "$Z99_REPO" add scripts/check_toy.sh
git -C "$Z99_REPO" -c user.name=demo -c user.email=demo@dev-harness.local \
  commit -q -m "кандидат выпаривает scripts/check_toy.sh (toy, вход и)"
M4="$(git -C "$Z99_REPO" rev-parse HEAD)"
git -C "$Z99_REPO" tag -f frozen/contracts/099/1 "$M4"
git -C "$Z99_REPO" push -q -f origin refs/tags/frozen/contracts/099/1
mkdir -p "$W/api/repos/o/r/commits/$M4"
z99_json_pr "$W/api/repos/o/r/pulls/7" 7 "$Z99_B" "$M4"
zcr "$W/api/repos/o/r/commits/$M4/check-runs" "l1:success|l2:success|l3:success|l4:success|l5:success|l6:success|l7a:failure:$L|l7b:success|ap1:success|ap2:success|ap3:success|ap4:success|ap5:success"
# (и-2) БЕЗ механизма (исполнены байты кандидата): rc 0 — «зелёная оболочка»,
# ровно та атака, от которой граница защищает
git -C "$Z99_REPO" worktree add -q --detach "$W/i-attack" "$M4"
a_out="$(cd "$W/i-attack" && bash fixtures/_krasnye_toy.sh 2>&1)"; a_rc=$?
if [ "$a_rc" -ne 0 ]; then
  printf 'КРАСНО: red_perehodnyj_gheit_perechen: вход и-2: выпаренные байты кандидата обязаны молчать (rc 0); факт rc=%s, вывод: %s\n' "$a_rc" "$(printf '%s' "$a_out" | head -c 200)" >&2
  exit 1
fi
# (и-3) С механизмом (код гейта = M^1): материализация замыкания из первого
# родителя на дереве кандидата → rc 1 и вывод БАЙТ-В-БАЙТ как честное дерево
git -C "$Z99_REPO" worktree add -q --detach "$W/i-mech" "$M4"
git -C "$W/i-mech" checkout -q "$Z99_A" -- scripts fixtures package.json
m_out="$(cd "$W/i-mech" && bash fixtures/_krasnye_toy.sh 2>&1)"; m_rc=$?
if [ "$m_rc" -ne 1 ] || [ "$m_out" != "$h_out" ]; then
  printf 'КРАСНО: red_perehodnyj_gheit_perechen: вход и-3: с механизмом M^1 результат обязан совпадать с честным деревом (rc 1, тот же вывод); факт rc=%s, вывод: %s\n' "$m_rc" "$(printf '%s' "$m_out" | head -c 200)" >&2
  exit 1
fi
# (и-4) дверь: ответ CI несёт ту же FAIL-строку l7a (исполнен код M^1) → ТОТ ЖЕ
# результат, что честному дереву: ДОПУСК rc 0, НЕ «проверки изменены: scripts/…»
zelyona и

# (к) парный вход: кандидат ДОБАВЛЯЕТ новую клетку и её скрипт — эволюция
# проверок не есть подмена; байт-минимум и реестр не тронуты
zpg к "$ALLGREEN" "$REG"
mkdir -p "$Z99_REPO/fixtures/zashchita_main_099" "$Z99_REPO/scripts"
printf '#!/usr/bin/env bash\nprintf "ЗЕЛЕНО: red_novaya_kletka\\n"\n' >| "$Z99_REPO/fixtures/zashchita_main_099/red_novaya_kletka.sh"
printf '#!/usr/bin/env bash\nexit 0\n' >| "$Z99_REPO/scripts/check_novaya.sh"
git -C "$Z99_REPO" add fixtures/zashchita_main_099/red_novaya_kletka.sh scripts/check_novaya.sh
git -C "$Z99_REPO" -c user.name=demo -c user.email=demo@dev-harness.local \
  commit -q -m "кандидат добавляет новую клетку и скрипт (toy, вход к)"
M5="$(git -C "$Z99_REPO" rev-parse HEAD)"
git -C "$Z99_REPO" tag -f frozen/contracts/099/1 "$M5"
git -C "$Z99_REPO" push -q -f origin refs/tags/frozen/contracts/099/1
mkdir -p "$W/api/repos/o/r/commits/$M5"
z99_json_pr "$W/api/repos/o/r/pulls/7" 7 "$Z99_B" "$M5"
zcr "$W/api/repos/o/r/commits/$M5/check-runs" "$ALLGREEN"
zelyona к

# (л) ЖИВАЯ структурная сверка workflow по СВОЙСТВУ 1г2 (Р1-5 reviewer 099
# круг 1; вердикт адверсария A099-M1): барьер средо-зависимый — судится ЖИВОЙ
# .github/workflows/ci.yml дерева, на котором исполняется клетка (не toy-мир).
# Свойство: НИ ОДИН шаг проверяемой джобы не исполняет байты кандидата
# (scripts/*, fixtures/*, npm-ключи package.json, config/* — дословно
# Решение 1г2) ДО шага материализации. Проверяемая джоба — джоба, чьи run-шаги
# производят составляющие обязательного набора: run-строка с токеном
# run_ci_lane.sh или npm-ключ check:antiplacebo, КРОМЕ сам-теста раннера на
# собственных байтах (аргумент $TMP_ROOT, класс арбитража 020): сам-тест судит
# СВОИ байты кандидата и потому обязан жить в ДРУГОЙ джобе — без общего .git
# с lane-джобой (каждая джоба Actions — отдельный раннер с собственным .git).
# Живой контрпример reviewer'а (Р1-5): шаг кандидата ДО материализации
# (check:ci-parity / сам-тест / _krasnye_099) делает git replace блоба
# M^1:scripts/run_ci_lane.sh на «exit 0» — дословная команда материализации
# восстанавливает ПОДМЕНУ, lane отдаёт rc 0 при контроле rc 1. Исполнение
# байтов — строка run-шага (ключ run: или продолжение её блока), содержащая
# путь scripts/|fixtures/|config/ или npm<пробел> (чтение/пуск ключей
# package.json); строки внутри #-комментариев исполнением НЕ считаются.
# Материализация — git checkout <base.sha|HEAD^1|M^1> -- scripts fixtures
# package.json config (форма хвоста — единый источник:
# config/ci_parity_exceptions.txt, дословно). Джоба без единого run-токена —
# NO-CHECKS, в выборке не участвует (не красный класс). Проверяемая джоба без
# материализации ИЛИ с исполнением байтов кандидата до неё → именованный
# красный отказ «живой workflow не материализует замыкание M^1» с именем
# джобы и первым нарушившим шагом (красный не прерывает клетку — вход м
# докладывается тем же прогоном).
LIVE_ROOT="$(cd "$HERE/../.." && pwd)"
LIVE_CI="$LIVE_ROOT/.github/workflows/ci.yml"
LIVE_BAD=0
if [ ! -f "$LIVE_CI" ]; then
  printf 'КРАСНО: red_perehodnyj_gheit_perechen: вход л: живой workflow отсутствует: %s\n' "$LIVE_CI" >&2
  exit 1
fi
L_MAT='git[ \t]+checkout[ \t]+("?([$][{][{][ \t]*)?(github[.]event[.]pull_request[.]base[.]sha([ \t]*[}][}])?|HEAD\^1|M\^1)"?)[ \t]+--[ \t]+scripts[ \t]+fixtures[ \t]+package[.]json[ \t]+config([^a-zA-Z0-9_.-]|$)'
L_RUN='run_ci_lane[.]sh|check:antiplacebo'
L_EXCL='[$]TMP_ROOT'
L_EXEC='(^|[^A-Za-z0-9_.-])(scripts/|fixtures/|config/|npm[ \t])'
if ! L_OUT="$(L_MAT="$L_MAT" L_RUN="$L_RUN" L_EXCL="$L_EXCL" L_EXEC="$L_EXEC" awk '
  function indent(l) { match(l, /^[ \t]*/); return RLENGTH }
  BEGIN { sec = ""; job = ""; sel = 0; mat = 0; bad = 0; badtxt = ""; n = 0; out = ""; runind = -1 }
  function flush() {
    if (job != "" && sel) { n++; if (!mat || bad) out = out (out == "" ? "" : ", ") job (bad ? " [" badtxt "]" : "") }
    sel = 0; mat = 0; bad = 0; badtxt = ""; runind = -1
  }
  /^[^ \t#]/ { flush(); sec = $0; sub(/:.*/, "", sec); job = ""; next }
  sec != "jobs" { next }
  /^  [A-Za-z0-9_-]+:/ { flush(); job = $0; sub(/^ */, "", job); sub(/:.*/, "", job); next }
  /^[ \t]*#/ { next }
  {
    ind = indent($0)
    isexec = 0
    if ($0 ~ /^[ \t]*(-[ \t]+)?run:/) { isexec = 1; runind = ind }
    else if (runind >= 0 && ind > runind) { isexec = 1 }
    else { runind = -1 }
    if (isexec) {
      if ($0 ~ ENVIRON["L_MAT"]) { mat = 1 }
      else if (!mat && $0 ~ ENVIRON["L_EXEC"] && !bad) {
        bad = 1; badtxt = $0; sub(/^[ \t]*/, "", badtxt)
        if (length(badtxt) > 80) badtxt = substr(badtxt, 1, 80) "…"
      }
    }
    if (!sel && $0 ~ ENVIRON["L_RUN"] && !($0 ~ ENVIRON["L_EXCL"])) sel = 1
  }
  END { flush(); printf "%d\t%s\n", n, out }
' "$LIVE_CI")"; then
  printf 'NOT_IMPLEMENTED: red_perehodnyj_gheit_perechen: вход л: awk не разобрал %s\n' "$LIVE_CI" >&2
  exit 2
fi
L_N="${L_OUT%%$'\t'*}"
L_BAD="${L_OUT#*$'\t'}"
case "$L_N" in '' | *[!0-9]*) printf 'NOT_IMPLEMENTED: red_perehodnyj_gheit_perechen: вход л: неожиданный счёт «%s»\n' "$L_N" >&2; exit 2 ;; esac
printf 'вход л: живой workflow: проверяемых джоб %s\n' "$L_N" >&2
if [ "$L_N" -eq 0 ]; then
  printf 'вход л: NO-CHECKS — джоб с run_ci_lane.sh/check:antiplacebo в живом workflow нет; по контракту класс не красный\n' >&2
elif [ -n "$L_BAD" ]; then
  printf 'КРАСНО: red_perehodnyj_gheit_perechen: вход л: живой workflow не материализует замыкание M^1 до запуска проверок (Решение 1г2; Р1-5 reviewer 099 круг 1; контрпример: шаг кандидата до материализации + git replace блоба M^1 → lane rc 0): job %s\n' "$L_BAD" >&2
  LIVE_BAD=1
fi

# (м) НОГА ПРОИЗВОДИТЕЛЯ Решения 2 (Р1-6 reviewer 099 круг 1), транзитивно.
# Дверь pr_dopusk читает config/transition_producers_099.tsv по M^1 и при
# пустой/отсутствующей таблице ПРОПУСКАЕТ ногу целиком (молчаливая инертность
# — 39bf3efa). Решение 2: «каждое имя обязательного набора покрыто строкой,
# шаг существует в .github/workflows/ дерева M^1 и несёт команду дословно» —
# выключателя у ноги нет. Toy-входы: м-1 — таблица ПУСТАЯ (Z99_BASE_PRODUCERS
# в _mir.sh), м-2 — таблица ОТСУТСТВУЕТ; субъект обязан дать именованный
# отказ rc 1 «таблица производителей пуста или отсутствует». Живая часть:
# таблица дерева клетки несёт РОВНО 13 имён (l1..l7b, ap1..ap5 — единый
# источник z99_reg_default/реестр Решения 2), каждая строка <имя> TAB
# .github/workflows/<файл> TAB <команда>, файл существует в дереве и несёт
# команду ДОСЛОВНО (grep -F) — транзитивная связь имени с производящим его
# шагом workflow (l1..l7b → шаг Lane, ap1..ap5 → шаг шарда).
# toy-проверки не прерывают клетку: все красные входы докладываются одним
# прогоном (л, м-1, м-2, живая таблица) — оркестратору нужен полный список.
PROD_TOY_BAD=0
Z99_BASE_PRODUCERS="" zpg м-1 "$ALLGREEN" "$REG"
vypolnit
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'таблица производителей пуста или отсутствует'; then
  printf 'КРАСНО: red_perehodnyj_gheit_perechen: вход м-1 (пустая таблица в M^1): ожидался отказ rc 1 «таблица производителей пуста или отсутствует»; факт rc=%s, вывод: %s\n' \
    "$rc" "$(printf '%s' "$out" | head -c 200)" >&2
  PROD_TOY_BAD=1
fi
Z99_BASE_PRODUCERS=none zpg м-2 "$ALLGREEN" "$REG"
vypolnit
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'таблица производителей пуста или отсутствует'; then
  printf 'КРАСНО: red_perehodnyj_gheit_perechen: вход м-2 (отсутствующая таблица в M^1): ожидался отказ rc 1 «таблица производителей пуста или отсутствует»; факт rc=%s, вывод: %s\n' \
    "$rc" "$(printf '%s' "$out" | head -c 200)" >&2
  PROD_TOY_BAD=1
fi
LIVE_PROD="$LIVE_ROOT/config/transition_producers_099.tsv"
PROD_BAD=0
if [ ! -f "$LIVE_PROD" ]; then
  printf 'КРАСНО: red_perehodnyj_gheit_perechen: вход м: таблица производителей отсутствует: %s (Р1-6 reviewer 099 круг 1; Решение 2)\n' "$LIVE_PROD" >&2
  PROD_BAD=1
else
  PROD_ROWS="$(grep -cv '^[ \t]*$' "$LIVE_PROD" 2>/dev/null || true)"
  case "$PROD_ROWS" in ''|*[!0-9]*) printf 'NOT_IMPLEMENTED: red_perehodnyj_gheit_perechen: вход м: неожиданный счёт строк «%s»\n' "$PROD_ROWS" >&2; exit 2 ;; esac
  if [ "$PROD_ROWS" -eq 0 ]; then
    printf 'КРАСНО: red_perehodnyj_gheit_perechen: вход м: таблица производителей пуста (0 строк): %s (Р1-6 reviewer 099 круг 1; Решение 2)\n' "$LIVE_PROD" >&2
    PROD_BAD=1
  else
    EXP="$(printf '%s\n' l1 l2 l3 l4 l5 l6 l7a l7b ap1 ap2 ap3 ap4 ap5 | LC_ALL=C sort)"
    ACT="$(grep -v '^[ \t]*$' "$LIVE_PROD" | cut -f1 | LC_ALL=C sort)"
    MIS="$(printf '%s\n' "$EXP" | comm -23 - <(printf '%s\n' "$ACT") | tr '\n' ' ')"
    EXT="$(printf '%s\n' "$EXP" | comm -13 - <(printf '%s\n' "$ACT") | tr '\n' ' ')"
    DUP="$(grep -v '^[ \t]*$' "$LIVE_PROD" | cut -f1 | sort | uniq -d | tr '\n' ' ')"
    if [ -n "${MIS// /}" ]; then
      printf 'КРАСНО: red_perehodnyj_gheit_perechen: вход м: производитель не объявлен для обязательных имён: %s(%s)\n' "$MIS" "$LIVE_PROD" >&2
      PROD_BAD=1
    fi
    if [ -n "${EXT// /}" ]; then
      printf 'КРАСНО: red_perehodnyj_gheit_perechen: вход м: лишние имена вне обязательного набора: %s(%s)\n' "$EXT" "$LIVE_PROD" >&2
      PROD_BAD=1
    fi
    if [ -n "${DUP// /}" ]; then
      printf 'КРАСНО: red_perehodnyj_gheit_perechen: вход м: дубликаты имён производителей: %s(%s)\n' "$DUP" "$LIVE_PROD" >&2
      PROD_BAD=1
    fi
    if [ "$PROD_ROWS" -ne 13 ]; then
      printf 'КРАСНО: red_perehodnyj_gheit_perechen: вход м: строк %s, обязательный набор — 13 (%s)\n' "$PROD_ROWS" "$LIVE_PROD" >&2
      PROD_BAD=1
    fi
    while IFS=$'\t' read -r pname pfile pcmd prest; do
      [ -n "$pname" ] || continue
      if [ -n "${prest:-}" ] || [ -z "${pcmd:-}" ]; then
        printf 'КРАСНО: red_perehodnyj_gheit_perechen: вход м: строка не по грамматике <имя>TAB<файл>TAB<команда>: %s\n' "$pname" >&2
        PROD_BAD=1; continue
      fi
      case "$pfile" in
        .github/workflows/*) ;;
        *)
          printf 'КРАСНО: red_perehodnyj_gheit_perechen: вход м: производитель вне .github/workflows/: %s → %s\n' "$pname" "$pfile" >&2
          PROD_BAD=1; continue ;;
      esac
      if [ ! -f "$LIVE_ROOT/$pfile" ]; then
        printf 'КРАСНО: red_perehodnyj_gheit_perechen: вход м: файл производителя отсутствует в дереве: %s → %s\n' "$pname" "$pfile" >&2
        PROD_BAD=1; continue
      fi
      if ! grep -Fq -- "$pcmd" "$LIVE_ROOT/$pfile"; then
        printf 'КРАСНО: red_perehodnyj_gheit_perechen: вход м: шаг производителя не несёт команду дословно: %s → %s\n' "$pname" "$pfile" >&2
        PROD_BAD=1
      fi
    done < <(grep -v '^[ \t]*$' "$LIVE_PROD")
  fi
fi

if [ "$LIVE_BAD" -ne 0 ] || [ "$PROD_BAD" -ne 0 ] || [ "$PROD_TOY_BAD" -ne 0 ]; then
  exit 1
fi


printf 'ЗЕЛЕНО: red_perehodnyj_gheit_perechen\n'
exit 0
