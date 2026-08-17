# ПРИЧИНА: гейт по ПОСЛЕДНЕЙ: РАСХОЖДЕНИЕ
#
# Предмет барьера — расхождение ЗАЯВЛЕННОЙ модели с фактической по трейсу. Оно было
# невидимым в реальности: конфиг объявлял одну модель, TUI поднимал другую. Подставной
# трейс называет модель, которой в наших ролях нет вовсе, — барьер обязан это увидеть.
set -euo pipefail
mkdir -p "$WORK/scripts" "$WORK/.omp/agents" "$WORK/.zones/dev"
cp "$REPO/.omp/agents/architect.md" "$WORK/.omp/agents/"
cp "$REPO/.omp/config.yml" "$WORK/.omp/"
printf '{"model":"fake/Fake-1","kind":"подставной трейс"}\n' > "$WORK/.zones/dev/session.jsonl"
BARRIER_ROOT="$WORK" "$BARRIER"
