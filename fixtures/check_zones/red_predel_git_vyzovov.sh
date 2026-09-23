#!/usr/bin/env bash
# Красное 040 v3 (Н-126, вариант A2) — ДИФФЕРЕНЦИАЛЬНЫЙ структурный (без
# wall-clock) предел числа git-подпроцессов check_zones.sh. РЕШЕНИЕ арбитража
# (verdicts/arbitration/040-batching-kriterii-i-tehnika.md, §Б1): круг 2 (critic
# contracts-040-v1, находка 1) и круг 3 (contracts-040-v2, Б1) показали, что
# ЛЮБАЯ абсолютная граница вида a·(K+M)+b на toy с НЕРАВНОМЕРНОЙ нагрузкой имеет
# зазор — критик построил обход дважды подряд (130<=452 батчингом только
# авторов; затем 135<=452 батчингом путей лишь в floor(K/2) окнах на "усиленном"
# M2). Решающим становится не УРОВЕНЬ нагрузки, а её ПРОИЗВОДНАЯ от неё.
#
# КОНСТРУКЦИЯ (дословно по решению арбитра, Б1):
#  1. Строятся ДВА toy-дерева с ОДИНАКОВОЙ структурой K окон и ОДИНАКОВЫМ M,
#     отличающихся ТОЛЬКО величиной L — числом коммитов ОБЪЯВЛЕННОГО автора
#     ОКНА в СВОЮ зону, добавляемых В КАЖДОЕ ИЗ K ОКОН ОДИНАКОВО: L_low и
#     L_high, Δ = L_high − L_low > 0. K контрактов 001..0NN, у каждого свой
#     agentNN и НЕПЕРЕСЕКАЮЩАЯСЯ зона zones/agentNN/, ВСЕ заморожены РАНО —
#     их окна frozen_NNN..HEAD покрывают одни и те же последующие коммиты.
#     M — фоновые --allow-empty коммиты НЕОБЪЯВЛЕННОГО автора «Фон» (нагружает
#     author-lookup половину A2 на каждое окно, НЕИЗМЕННО между деревьями —
#     единственная переменная это L, иначе разность C_high−C_low несла бы
#     вклад ещё одной переменной, и опыт перестал бы быть дифференциальным).
#  2. Измеряется C_low и C_high — полное число git-подпроцессов субъекта на
#     каждом дереве (тот же PATH-шпион, что и раньше).
#  3. Приёмочное (РЕШАЮЩЕЕ) утверждение: C_high − C_low <= S, с обязательным
#     Δ >= 2·S — калибровка К=12, M=60, L_low=5, L_high=35 (Δ=30 на окно),
#     S=15 взята из замера арбитра З4 (отправная точка, не догма, прожита
#     заново ниже этим самым файлом).
#  4. Негативный контроль (Н-39) повторяется на ОБОИХ деревьях: agent03 →
#     zones/agent07/ обязан ловиться и там, и там; иначе rc=1 с причиной
#     «поймана потеря проверки, не производительность» — a НЕ падение через
#     обычный `fail` дифференциала.
#  5. Абсолютная граница a·(K+M)+b СОХРАНЯЕТСЯ как ВТОРОЕ, ГРУБОЕ утверждение
#     (внятный диагноз для случая «батчинга нет вовсе») и проверяется НА
#     ДЕРЕВЕ LOW; РЕШАЮЩИМ остаётся п.3. Правка a,b — зона architect (см.
#     контракт §Риски); правка S/Δ ТУДА НЕ ВХОДИТ — они связаны Δ>=2·S, и
#     ослабление S без роста Δ — ослабление предмета, не «щедрая константа».
#
# ПОЧЕМУ ЭТО ЗАКРЫВАЕТ КЛАСС, А НЕ ОЧЕРЕДНОЙ МУТАНТ: добавочная нагрузка Δ
# попадает в КАЖДОЕ окно одновременно, поэтому реализация, оставившая
# по-коммитный источник хоть в ОДНОМ окне, платит НЕ МЕНЕЕ Δ доп. вызовов
# (diff-tree-половина, для ТОГО ОДНОГО окна) либо НЕ МЕНЕЕ K·Δ (author-
# половина — добавленные K·Δ коммитов входят в диапазон ВСЕХ K окон
# одновременно) — оба случая больше S по построению Δ>=2·S. Правило выбора
# «какие окна оставить по-коммитными» перестаёт быть обходом: неравенство не
# зависит от того, КАКИЕ окна остались медленными, только от того, что таких
# окон >= 1.
#
# Регресс-гарантия (не-ослабление) — ОТДЕЛЬНО от этого файла: все существующие
# 21 файл fixtures/check_zones/case_*.sh обязаны остаться зелёными БЕЗ правки
# их текста (см. контракт §Приёмка Р3, форма diff --diff-filter=MD).
#
# Коды возврата: 0 — оба предела держатся И нарушение поймано на ОБОИХ
#                деревьях; 1 — граница/дифференциал превышены ЛИБО нарушение
#                не поймано (сегодня: и то, и другое); 2 — нечем проверить.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
CZ="$REPO/scripts/check_zones.sh"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/red040-predel.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
[ -f "$CZ" ] || { printf 'NOT_IMPLEMENTED: субъект не найден: %s\n' "$CZ" >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

fail() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }

# ── параметры (Б1, калибровка З4) ──────────────────────────────────────────
K=12
M=60
L_LOW=5
L_HIGH=35
S=15
A=6
B=20

# build_tree <L> <outdir> — toy с K окнами, M фоновыми(Фон) коммитами и L
# коммитами КАЖДОГО объявленного автора agentNN в СВОЮ зону, равномерно во
# ВСЕ K окон (Б1 п.1).
build_tree() {
  local L="$1" R="$2" i nnn an k2 an2 j
  mkdir -p "$R"
  g() { GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" \
        -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$R"

  mkdir -p "$R/contracts" "$R/verdicts/critic"
  {
    printf '# контракт 001\n\n## Предмет\nподставной предмет KxL\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\n'
    printf 'ЗОНА agent01: zones/agent01/\n'
  } > "$R/contracts/001-x.md"
  printf 'accept\nвердикт критика\n' > "$R/verdicts/critic/contracts-001-v1.md"
  mkdir -p "$R/zones/agent01"
  printf 'исходный\n' > "$R/zones/agent01/seed.md"
  g -c user.name=Фикстура -c user.email=fixture@local add -A
  g -c user.name=Фикстура -c user.email=fixture@local commit -q -m 'основание'
  g -c user.name=Фикстура -c user.email=fixture@local tag -a frozen/contracts/001/1 -m 'контракт 001 утверждён'

  i=2
  while [ "$i" -le "$K" ]; do
    nnn=$(printf '%03d' "$i")
    an=$(printf 'agent%02d' "$i")
    printf '# контракт %s\n\n## Предмет\nподставной предмет KxL\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\nЗОНА %s: zones/%s/\n' \
      "$nnn" "$an" "$an" > "$R/contracts/$nnn-y.md"
    mkdir -p "$R/zones/$an"
    printf 'исходный\n' > "$R/zones/$an/seed.md"
    g -c user.name=Фикстура -c user.email=fixture@local add -A
    g -c user.name=Фикстура -c user.email=fixture@local commit -q -m "основание: контракт $nnn"
    g -c user.name=Фикстура -c user.email=fixture@local tag -a "frozen/contracts/$nnn/1" -m "контракт $nnn утверждён"
    i=$((i + 1))
  done

  j=1
  while [ "$j" -le "$M" ]; do
    g -c user.name=Фон -c user.email=fon@local commit -q --allow-empty -m "фон $j"
    j=$((j + 1))
  done

  # L коммитов КАЖДОГО объявленного автора в СВОЮ зону — равномерно во ВСЕ K
  # окон (Б1 п.1: "добавляемых в КАЖДОЕ из K окон одинаково").
  k2=1
  while [ "$k2" -le "$K" ]; do
    an2=$(printf 'agent%02d' "$k2")
    j=1
    while [ "$j" -le "$L" ]; do
      printf 'нагрузка %d\n' "$j" > "$R/zones/$an2/load_$j.md"
      g -c user.name="$an2" -c user.email="$an2@local" add -A
      g -c user.name="$an2" -c user.email="$an2@local" commit -q -m "$an2: нагрузка своей зоны $j"
      j=$((j + 1))
    done
    k2=$((k2 + 1))
  done

  # Нарушение (Н-39, гарантия от быстрой-неверной): agent03 коммитит в ЧУЖУЮ
  # зону (agent07) — ОБЯЗАН остаться пойман И сегодня, И после батчинга.
  mkdir -p "$R/zones/agent07"
  printf 'вторжение\n' > "$R/zones/agent07/x.md"
  g -c user.name=agent03 -c user.email=agent03@local add -A
  g -c user.name=agent03 -c user.email=agent03@local commit -q -m 'agent03 пишет в чужую зону'
}

# run_trace <repo> — прогоняет check_zones.sh под внешней трассировкой (арбитраж 040-II,
# Граница v4 п.1: verdicts/arbitration/contracts-040-batching-dostatochnost-oraculu.md).
# check_zones.sh теперь САМ делает `export PATH=/usr/bin:/bin` до первой внешней команды —
# любой PATH-шим (прежняя форма этой функции, PATH-spy) стирается ЭТОЙ строкой субъекта,
# тем же классом, что уже решён для check_protected.sh: приём `check_spec_ready.sh:246-253`
# / `fixtures/check_protected/red_predel_git_vyzovov_ours.sh:106-114`. `SHELLOPTS=xtrace
# BASH_XTRACEFD=9` заставляет ДОЧЕРНИЙ bash трассировать СРАЗУ на старте, ДО собственного
# `set -euo pipefail` субъекта, независимо от того, что субъект делает с PATH —
# трассировка логирует КОМАНДУ КАК НАПИСАНО. Заполняет глобальные RC/OUT/CALLS.
run_trace() {
  local R="$1" TRACE
  TRACE="$WORK/trace.$RANDOM.$$"
  : > "$TRACE"
  OUT="$(env SHELLOPTS=xtrace BASH_XTRACEFD=9 bash "$CZ" "$R" 2>&1 9>"$TRACE")"; RC=$?
  CALLS="$(grep -cE '^\+{1,} git ' "$TRACE")"
}

# ── дерево LOW ────────────────────────────────────────────────────────────
R_LOW="$WORK/repo-low"
build_tree "$L_LOW" "$R_LOW"
run_trace "$R_LOW"
RC_LOW="$RC"; OUT_LOW="$OUT"; CALLS_LOW="$CALLS"

# ── дерево HIGH ───────────────────────────────────────────────────────────
R_HIGH="$WORK/repo-high"
build_tree "$L_HIGH" "$R_HIGH"
run_trace "$R_HIGH"
RC_HIGH="$RC"; OUT_HIGH="$OUT"; CALLS_HIGH="$CALLS"

# ── ассерт 1: нарушение ОБЯЗАНО быть поймано НА ОБОИХ деревьях (Б1 п.4) ─────
printf '%s\n' "$OUT_LOW" | grep -qF 'коммит вне зоны: agent03' \
  || fail "LOW: нарушение agent03->zones/agent07/ НЕ поймано (rc=$RC_LOW) — поймана потеря проверки, не производительность:
$OUT_LOW"
[ "$RC_LOW" -eq 1 ] || fail "LOW: check_zones rc=$RC_LOW, ожидался 1 (нарушение поймано, общий rc обязан быть 1)"
printf '%s\n' "$OUT_HIGH" | grep -qF 'коммит вне зоны: agent03' \
  || fail "HIGH: нарушение agent03->zones/agent07/ НЕ поймано (rc=$RC_HIGH) — поймана потеря проверки, не производительность:
$OUT_HIGH"
[ "$RC_HIGH" -eq 1 ] || fail "HIGH: check_zones rc=$RC_HIGH, ожидался 1 (нарушение поймано, общий rc обязан быть 1)"

printf 'toy LOW:  K=%d M=%d L=%d -> %d коммитов judged, git-вызовов=%d (нарушение поймано)\n' "$K" "$M" "$L_LOW" "$((K + M + K * L_LOW + 1))" "$CALLS_LOW" >&2
printf 'toy HIGH: K=%d M=%d L=%d -> %d коммитов judged, git-вызовов=%d (нарушение поймано)\n' "$K" "$M" "$L_HIGH" "$((K + M + K * L_HIGH + 1))" "$CALLS_HIGH" >&2

# ── ассерт 2 (ГРУБЫЙ, абсолютный, на LOW): a·(K+M)+b — диагноз «батчинга нет вовсе» ──
bound=$((A * (K + M) + B))
printf 'абсолютная граница (грубая, на LOW) a*(K+M)+b = %d*(%d+%d)+%d = %d\n' "$A" "$K" "$M" "$B" "$bound" >&2
[ "$CALLS_LOW" -le "$bound" ] \
  || fail "git-вызовов на LOW $CALLS_LOW > грубой границы $bound — батчинга похоже нет вовсе (Н-126)"

# ── ассерт 3 (РЕШАЮЩИЙ, дифференциальный): C_high - C_low <= S, Δ>=2·S ──────
delta_L=$((L_HIGH - L_LOW))
[ "$delta_L" -ge $((2 * S)) ] || fail "конструкция фикстуры нарушена: Δ=$delta_L < 2*S=$((2 * S)) — калибровка невалидна"
diff_calls=$((CALLS_HIGH - CALLS_LOW))
printf 'дифференциал: C_high(%d) - C_low(%d) = %d - граница S = %d (Δ на окно = %d, Δ>=2S держится: %d>=%d)\n' \
  "$CALLS_HIGH" "$CALLS_LOW" "$diff_calls" "$S" "$delta_L" "$delta_L" "$((2 * S))" >&2
[ "$diff_calls" -le "$S" ] \
  || fail "дифференциал git-вызовов $diff_calls > S=$S — неполный/отсутствующий батчинг хотя бы в ОДНОМ окне (Н-126): либо author-lookup, либо diff-tree остались по-коммитными"

printf 'ПРЕДЕЛ ДЕРЖИТСЯ: LOW=%d<=%d (грубо) И дифференциал %d<=%d (решающе)\n' "$CALLS_LOW" "$bound" "$diff_calls" "$S" >&2
exit 0
