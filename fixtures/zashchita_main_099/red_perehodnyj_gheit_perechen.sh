#!/usr/bin/env bash
# Клетка red_perehodnyj_gheit_perechen — инвариант З-6 контракта 099 (doc §3):
# переходный доверенный гейт допускает ТОЛЬКО точно перечисленные дефекты,
# исполненные ПОЛНОСТЬЮ, с доверенным происхождением проверок.
# Одиннадцать входов (блокеры критика круга 1 :49/:48; входы и/к — граница
# арбитража 099 круга 3 по происхождению кода проверок; вход л — вердикт
# адверсария A099-M1, Решение 1г2: живая материализация замыкания M^1):
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
#   (л) ЖИВАЯ структурная сверка .github/workflows/ci.yml: каждая джоба,
#       запускающая run_ci_lane.sh или npm run check:antiplacebo (запуском
#       считается run-строка с таким токеном, КРОМЕ сам-теста раннера на
#       собственных байтах — аргумент $TMP_ROOT, класс арбитража 020: сам-тест
#       обязан стоять ДО материализации, bootstrap), обязана нести РАНЬШЕ
#       первого такого run-шага шаг материализации
#       git checkout <base.sha|HEAD^1|M^1> -- scripts fixtures package.json
#       config (строки внутри #-комментариев материализацией не считаются);
#       джоба без единого такого run-шага — NO-CHECKS, в выборке не участвует;
#       ≥1 проверяемой джобы и хоть одна без шага до первого run → именованный
#       красный отказ «живой workflow не материализует замыкание M^1».
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

# (л) ЖИВАЯ структурная сверка workflow (вердикт адверсария A099-M1; Решение 1г2):
# барьер средо-зависимый — судится ЖИВОЙ .github/workflows/ci.yml дерева, на котором
# исполняется клетка (не toy-мир). Запуск обязательной проверки — run-строка с
# run_ci_lane.sh или npm run check:antiplacebo, КРОМЕ сам-теста раннера на
# собственных байтах ($TMP_ROOT-аргумент, класс арбитража 020: сам-тест судит
# СВОИ байты кандидата и обязан стоять ДО материализации — bootstrap, base main
# не несёт семью). Такая джоба обязана нести РАНЬШЕ первого такого run-шага шаг
# материализации git checkout <base.sha|HEAD^1|M^1> -- scripts fixtures package.json
# config; строки внутри #-комментариев материализацией НЕ считаются; джоба без
# единого такого run-шага — NO-CHECKS, в выборке не участвует (не красный класс).
# Форма хвоста — единый источник: config/ci_parity_exceptions.txt («-- scripts
# fixtures package.json config», дословно); ref — семейство base.sha|HEAD^1|M^1.
LIVE_ROOT="$(cd "$HERE/../.." && pwd)"
LIVE_CI="$LIVE_ROOT/.github/workflows/ci.yml"
if [ ! -f "$LIVE_CI" ]; then
  printf 'КРАСНО: red_perehodnyj_gheit_perechen: вход л: живой workflow отсутствует: %s\n' "$LIVE_CI" >&2
  exit 1
fi
L_MAT='git[ \t]+checkout[ \t]+("?([$][{][{][ \t]*)?(github[.]event[.]pull_request[.]base[.]sha([ \t]*[}][}])?|HEAD\^1|M\^1)"?)[ \t]+--[ \t]+scripts[ \t]+fixtures[ \t]+package[.]json[ \t]+config([^a-zA-Z0-9_.-]|$)'
L_RUN='run_ci_lane[.]sh|check:antiplacebo'
L_EXCL='[$]TMP_ROOT'
if ! L_OUT="$(L_MAT="$L_MAT" L_RUN="$L_RUN" L_EXCL="$L_EXCL" awk '
  BEGIN { sec = ""; job = ""; sel = 0; rans = 0; mater = 0; ok = 0; n = 0; bad = "" }
  function flush() {
    if (job != "" && sel) { n++; if (!ok) bad = bad (bad == "" ? "" : ", ") job }
    sel = 0; rans = 0; mater = 0; ok = 0
  }
  /^[^ \t#]/ { flush(); sec = $0; sub(/:.*/, "", sec); job = ""; next }
  sec != "jobs" { next }
  /^  [A-Za-z0-9_-]+:/ { flush(); job = $0; sub(/^ */, "", job); sub(/:.*/, "", job); next }
  /^[ \t]*#/ { next }
  { if ($0 ~ ENVIRON["L_MAT"]) mater = 1
    if ($0 ~ ENVIRON["L_RUN"] && !($0 ~ ENVIRON["L_EXCL"]) && !rans) { rans = 1; sel = 1; ok = mater } }
  END { flush(); printf "%d\t%s\n", n, bad }
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
  printf 'КРАСНО: red_perehodnyj_gheit_perechen: вход л: живой workflow не материализует замыкание M^1 до запуска проверок (Решение 1г2; вердикт адверсария A099-M1): job %s\n' "$L_BAD" >&2
  exit 1
fi


printf 'ЗЕЛЕНО: red_perehodnyj_gheit_perechen\n'
exit 0
