# ПРИЧИНА: гейт по ПОСЛЕДНЕЙ: РАСХОЖДЕНИЕ
#
# Предмет барьера — расхождение ЗАЯВЛЕННОЙ модели с фактической по трейсу. Оно было
# невидимым в реальности: конфиг объявлял одну модель, TUI поднимал другую.
#
# Положительный контроль обязателен и здесь: сначала подставной трейс называет РОВНО ту
# модель, которую объявляет конфиг, — барьер зелен. Заявленное берётся из конфига тем же
# путём, которым его берёт сам барьер, иначе фикстура проверяла бы своё представление о
# конфиге, а не конфиг.
set -euo pipefail
mkdir -p "$WORK/scripts" "$WORK/.omp/agents" "$WORK/.zones/dev"
cp "$REPO/.omp/agents/architect.md" "$WORK/.omp/agents/"
cp "$REPO/.omp/config.yml" "$WORK/.omp/"

mr="$(grep -oE '^model: \["@[a-z]+"\]' "$WORK/.omp/agents/architect.md" | sed 's/.*@//;s/"\]//')"
declared="$(grep -oE "^\s+${mr}:\s*\"[^\"]+\"" "$WORK/.omp/config.yml" | sed 's/.*"\(.*\)"/\1/')"
[ -n "$declared" ] || { printf 'фикстура не прочла заявленную модель\n' >&2; exit 1; }

printf '{"model":"%s","kind":"подставной трейс, модель совпадает"}\n' "$declared" \
  > "$WORK/.zones/dev/session.jsonl"
BARRIER_ROOT="$WORK" "$BARRIER"

printf '{"model":"fake/Fake-1","kind":"подставной трейс, модель расходится"}\n' \
  > "$WORK/.zones/dev/session.jsonl"
BARRIER_ROOT="$WORK" "$BARRIER"
