#!/usr/bin/env bash
# Красное предъявление 2/6 контракта 028 (структурный фикс судимого дерева, Н-98).
#
# ПРИВЯЗКА К ВЕТВЯМ КОДА (Н-39): ветки — workshop:437/:502 `export HOME="$ZONE"`,
# :465/:546 `exec omp …` и экспорт `HARNESS_SESSION_HOME="$ZONE"` до подмены HOME
# (инвариант 1, блокер к2 вердикта critic-028-v1). Вход: ВНЕШНИЙ HARNESS_SCRATCH +
# запуск workshop из одноразового клона (omp — PATH-подставной, объявлен ниже,
# прецедент А-156; живая сессия НЕ спавнится, токены не тратятся).
#
# Честная реализация на этом входе: подставной omp видит
# HOME=<HARNESS_SCRATCH>/zones/dev (внешний, байт-точно), session-prompt-*
# лежит там же, манифест путей ВСЕГО дерева клона не растёт (инвариант 3) — и
# ПЕРЕДАЧА разрешённого корня наблюдается В РЕАЛЬНОМ ОКРУЖЕНИИ ПОТОМКА workshop
# (блокер к2): подставной omp снимает УНАСЛЕДОВАННУЮ HARNESS_SESSION_HOME и
# запускает потребителя scripts/models_actual.sh ИЗ УНАСЛЕДОВАННОЙ среды.
# Проба НЕ подставляет переменную за предмет: ручная подстановка проверяла бы
# собственную подстановку, а обход «лаунчер молчит» оставался бы зелёным
# (обход к2, воспроизведён моделью bez-peredachi — models/patch.py).
# Отсутствие экспорта лаунчером — именованный отказ peredacha-net.
#
# СТАБ, который предъявление ловит: «выключить composer конфигом» — фикс,
# оставляющий HOME в дереве и глушащий лишь один класс писателей. Дефект
# стаба наблюдаем РОВНО на этом входе: HOME уходит в дерево, пути рантайма
# появляются в клоне. Живой end-to-end (настоящая сессия omp на живом дереве)
# — канарейка 5 (canary_solo_028.sh): она видит ВСЕХ писателей дерева, не
# только ветку лаунчера.
#
# Прогоны ДО предмета — из одноразового клона; после предмета — в живом дереве.
# Ожидание сегодня (ручка не читается): rc 1 именованный. После предмета: rc 0.
# Коды возврата: 0 — HOME внешний, дерево чисто, передача наблюдается потомком;
# 1 — именованный отказ пробы.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
SUBJ="$REPO/workshop"
KONSUMENT="$REPO/scripts/models_actual.sh"

[ -f "$SUBJ" ] || { printf 'ОТКАЗ net-subekta: workshop не найден: %s\n' "$SUBJ" >&2; exit 1; }
[ -f "$KONSUMENT" ] || { printf 'ОТКАЗ net-potrebitelja: models_actual.sh не найден: %s\n' "$KONSUMENT" >&2; exit 1; }

WORK="$(mktemp -d /tmp/red028-vne.XXXXXX)"    # А-78: свежий WORK вне дерева
trap 'rm -rf "$WORK"' EXIT

SCRATCH="$WORK/scratch"                # ВНЕШНИЙ скратч: вне клонов и деревей
export OMP_SHIM_LOG="$WORK/omp-shim.log"          # журнал подставного omp
export OMP_SHIM_SESSHOME="$WORK/omp-sesshome"     # унаследованная HARNESS_SESSION_HOME
export OMP_SHIM_KONSUMENT="$WORK/omp-konsument"   # вывод потребителя из сессии
export PROBE_KLON="$REPO"                          # путь клона для подставного omp

# Герметичность require_metering (workshop:115-133): достаточно непустых
# значений; наружу не печатаются.
export ZAI_API_KEY=dummy-probe
export METERING_PROXY_URL=http://127.0.0.1:1
export METERING_PROXY_TOKEN=dummy-probe
export MINIMAX_API_KEY=dummy-probe

# Трейс потребителя создаётся ДО запуска workshop: обычный старт с УЖЕ
# существующей зоной законен (durable-состояние переживает рестарты — сам
# предмет контракта); СТОП-при-существовании — церемония миграции
# (инвариант 5б), не обычный запуск.
SESS_DIR="$SCRATCH/zones/dev/probe-sess"
mkdir -p "$SESS_DIR"
printf '{"model":"probe/konsument-028"}\n' \
  > "$SESS_DIR/2026-01-01T00-00-00Z_00000000-0000-0000-0000-000000000000.jsonl"

# Манифест путей всего дерева ДО запуска (инвариант 3).
find "$REPO" -printf '%y %p\n' | LC_ALL=C sort > "$WORK/tree.do"

# PATH-подставной omp (объявлен здесь, прецедент А-156): фиксирует HOME и
# УНАСЛЕДОВАННУЮ сессионную среду, затем запускает НАСТОЯЩЕГО потребителя
# scripts/models_actual.sh ИЗ этой среды — не задавая HARNESS_SESSION_HOME за
# лаунчер (блокер к2: наблюдается ПЕРЕДАННОЕ лаунчером, не подставленное
# пробой; потребитель — потомок workshop в той же среде).
mkdir -p "$WORK/bin"
cat > "$WORK/bin/omp" <<'EOS'
#!/usr/bin/env bash
printf 'OMP_SHIM_RAN HOME=%s PWD=%s\n' "$HOME" "$PWD" >> "${OMP_SHIM_LOG:?}"
if [ -n "${HARNESS_SESSION_HOME:-}" ]; then
  printf '%s' "$HARNESS_SESSION_HOME" > "${OMP_SHIM_SESSHOME:?}"
else
  : > "${OMP_SHIM_SESSHOME:?}"
fi
bash "${PROBE_KLON:?}/scripts/models_actual.sh" > "${OMP_SHIM_KONSUMENT:?}" 2>&1
printf 'KONSUMENT_RC=%s\n' "$?" >> "${OMP_SHIM_LOG:?}"
exit 0
EOS
chmod +x "$WORK/bin/omp"

OUT="$WORK/out.log"
env -u HARNESS_SESSION_HOME -u XDG_STATE_HOME PATH="$WORK/bin:$PATH" \
  HARNESS_SCRATCH="$SCRATCH" bash "$SUBJ" >"$OUT" 2>&1
RC=$?

fail() { printf 'ОТКАЗ %s: %s\n' "$1" "$2" >&2; exit 1; }

# 0. workshop дошёл до exec (иначе проверка пуста — вакуумная зелёность запрещена).
[ -f "$WORK/omp-shim.log" ] \
  || fail 'sessija-ne-doshla' "подставной omp не запущен (workshop rc=$RC) — предъявление вакуумно. Вывод: $(head -c 600 "$OUT")"

SHIM_HOME="$(sed 's/^OMP_SHIM_RAN HOME=//' "$WORK/omp-shim.log" | head -1 | cut -d' ' -f1)"

# 1. HOME подставного omp — ВНЕШНИЙ скратч, байт-точно ожидаемый префикс.
WANT_HOME="$SCRATCH/zones/dev"
[ "$SHIM_HOME" = "$WANT_HOME" ] \
  || fail 'home-v-dereve' "omp увидел HOME=$SHIM_HOME, ожидан внешний $WANT_HOME — ручка HARNESS_SCRATCH не управляет HOME. Вывод: $(head -c 400 "$OUT")"

# 2. Промпт сессии лежит во внешнем доме.
ls "$WANT_HOME"/session-prompt-*.md >/dev/null 2>&1 \
  || fail 'prompt-ne-v-skratche' "session-prompt-* нет в $WANT_HOME — сессионные файлы пошли мимо внешнего скратча"

# 3. Манифест путей ВСЕГО дерева не вырос (наблюдение — всё дерево, не имя .zones).
find "$REPO" -printf '%y %p\n' | LC_ALL=C sort > "$WORK/tree.posle"
NOVY="$(comm -13 "$WORK/tree.do" "$WORK/tree.posle")"
[ -z "$NOVY" ] \
  || fail 'novye-puti-v-dereve' "дерево выросло: $NOVY — рантайм-писатели остались в судимом дереве (самотрип Н-98 жив, возможно под другим именем)"

# 4. ПЕРЕДАЧА разрешённого корня — наблюдение в РЕАЛЬНОМ окружении потомка
#    workshop (блокер к2 вердикта critic-028-v1): переменную обязан
#    экспортировать ЛАУНЧЕР; проба её НЕ подставляет. Значение снято САМИМ
#    потомком из унаследованной среды.
SESSHOME=""
[ -s "$WORK/omp-sesshome" ] && SESSHOME="$(cat "$WORK/omp-sesshome")"
if [ "$SESSHOME" != "$WANT_HOME" ]; then
  VIDD="${SESSHOME:-ПУСТО}"
  fail 'peredacha-net' "workshop не передал HARNESS_SESSION_HOME потомку: потомок увидел '$VIDD', ожидан байт-точно $WANT_HOME — обход «лаунчер молчит, а проба подставляет env сама» (блокер к2). Вывод: $(head -c 400 "$OUT")"
fi

#    Потребитель из УНАСЛЕДОВАННОЙ сессионной среды (запущен подставным omp,
#    HOME уже подменён лаунчером): находит трейсы разрешённого корня.
K_RC="$(sed -n 's/^KONSUMENT_RC=//p' "$WORK/omp-shim.log" | tail -1)"
if [ -z "$K_RC" ] || [ "$K_RC" -eq 2 ] || ! grep -q 'сессий показано: 1' "$WORK/omp-konsument"; then
  fail 'konsument-ne-vidit-trejsov' "models_actual.sh из УНАСЛЕДОВАННОЙ сессионной среды не нашёл трейсы разрешённого корня: rc=${K_RC:-НЕТ}. Вывод: $(head -c 400 "$WORK/omp-konsument")"
fi

# 5. Демаркация той же развилки БЕЗ передачи: повторная формула от подменённого
#    $HOME (без HARNESS_SESSION_HOME и без ручек-источников) уходит в другой
#    корень — трейсов там нет (наблюдение, ПОЧЕМУ передача обязательна; контроль
#    демаркации, не отказа предмета).
C2_OUT="$WORK/consumer-bez.log"
env -u HARNESS_SESSION_HOME -u HARNESS_SCRATCH -u XDG_STATE_HOME HOME="$WANT_HOME" \
  bash "$KONSUMENT" >"$C2_OUT" 2>&1
C2_RC=$?
if [ "$C2_RC" -ne 2 ] || ! grep -q 'трейсов в зоне нет' "$C2_OUT"; then
  fail 'demarkatsija-slomana' "без HARNESS_SESSION_HOME потребитель обязан уйти в rc 2 «трейсов в зоне нет» (другой корень), получил rc=$C2_RC — демаркация больше не различима. Вывод: $(head -c 400 "$C2_OUT")"
fi

printf 'red_zony_net_v_dereve: HOME внешний (%s), промпт в скратче, дерево не выросло, передача наблюдается потомком, потребитель видит трейсы (workshop rc=%s)\n' "$WANT_HOME" "$RC" >&2
exit 0
