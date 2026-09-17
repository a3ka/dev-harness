# ПРИЧИНА: гейт по ПОСЛЕДНЕЙ: РАСХОЖДЕНИЕ
# ОКРУЖЕНИЕ: HARNESS_SESSION_HOME=$WORK/scratch/dev-harness-sessions/probe-sess/zones/dev
#
# Предмет барьера — расхождение ЗАЯВЛЕННОЙ модели с фактической по трейсу. Оно было
# невидимым в реальности: конфиг объявлял одну модель, TUI поднимал другую.
#
# Положительный контроль обязателен и здесь: сначала подставной трейс называет РОВНО ту
# модель, которую объявляет конфиг, — барьер зелен. Заявленное берётся из конфига тем же
# путём, которым его берёт сам барьер, иначе фикстура проверяла бы своё представление о
# конфиге, а не конфиг.
#
# Сессионный HOME уехал наружу чекаута (контракт 028, инвариант 7): трейс больше НЕ
# создаётся в `<клон>/.zones/dev/`. Фикстура заводит внешний скратч, засевает трейс ТАМ и
# поднимает barrier через `HARNESS_SESSION_HOME=<разрешённый корень>` — потребитель
# находит его по унаследованному значению. Без передачи ручки (внешний запуск) —
# побайтовая формула обслуживает тот же путь (hash8 от HERE).
#
# Ручка проброшена через `# ОКРУЖЕНИЕ:` ШАПКИ — единственный канал, который проверяющий
# кладёт в `env -i` при вызове барьера (`ap_run`, контракт verify_antiplacebo §3.2):
# `export` фикстуры до `$BARRIER` НЕ доходит, потому что клиент канала шлёт только argv,
# а реальный барьер стартует проверяющий потомком.
set -euo pipefail
# Скратч — внешний, ВНЕ дерева: путь рантайма уехал из судимого корня.
SCRATCH="$WORK/scratch"
mkdir -p "$SCRATCH/dev-harness-sessions/probe-sess/zones/dev/probe-slug"
SESSION_TRACE_DIR="$SCRATCH/dev-harness-sessions/probe-sess/zones/dev/probe-slug"
mkdir -p "$WORK/scripts" "$WORK/.omp/agents" "$SESSION_TRACE_DIR"
cp "$REPO/.omp/agents/architect.md" "$WORK/.omp/agents/"
cp "$REPO/.omp/config.yml" "$WORK/.omp/agents/.." 2>/dev/null || cp "$REPO/.omp/config.yml" "$WORK/.omp/"

mr="$(grep -oE '^model: \["@[a-z]+"\]' "$WORK/.omp/agents/architect.md" | sed 's/.*@//;s/"\]//')"
declared="$(grep -oE "^\s+${mr}:\s*\"[^\"]+\"" "$WORK/.omp/config.yml" | sed 's/.*"\(.*\)"/\1/')"
[ -n "$declared" ] || { printf 'фикстура не прочла заявленную модель\n' >&2; exit 1; }

# HARNESS_SESSION_HOME объявлен через `# ОКРУЖЕНИЕ:` шапки — проверяющий кладёт его в env -i
# при запуске барьера; см. комментарий выше.

printf '{"model":"%s","kind":"подставной трейс, модель совпадает"}\n' "$declared" \
  > "$SESSION_TRACE_DIR/session.jsonl"
BARRIER_ROOT="$WORK" "$BARRIER"

printf '{"model":"fake/Fake-1","kind":"подставной трейс, модель расходится"}\n' \
  > "$SESSION_TRACE_DIR/session.jsonl"
BARRIER_ROOT="$WORK" "$BARRIER"
