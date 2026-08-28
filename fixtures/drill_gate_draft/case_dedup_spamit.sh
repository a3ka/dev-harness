# ПРИЧИНА: FAIL дедуп
#
# Ветвь анти-спама: ПОВТОР того же отказа (тот же ключ: команда + первая FAIL-строка)
# обязан давать РОВНО ОДИН файл со счётчиком «повторов: 2» и обновлённой датой; другой
# отказ — отдельный файл. Стаб «новый файл на каждый вызов» — спам-генератор, ловится
# только этим входом (на первом отказе он неотличим от честного).
set -euo pipefail
mkdir -p "$WORK/scripts" "$WORK/.omp/extensions"

# Зелёный контроль: настоящие субъекты из репозитория
cp "$REPO/scripts/draft_nabludenia.sh" "$WORK/scripts/"
cp "$REPO/.omp/extensions/gate-draft.ts" "$WORK/.omp/extensions/"
BARRIER_ROOT="$WORK" "$BARRIER"

# Красное: стаб без дедупа — каждый вызов плодит новый файл
cat > "$WORK/scripts/draft_nabludenia.sh" <<'STUB'
#!/usr/bin/env bash
# Подставной субъект: дедупа нет, каждый отказ — новый файл.
D="${TMPDIR:-/tmp}/dev-harness-nabludenia/drafts"
mkdir -p "$D"
printf 'ДАТА · ГЕЙТ %s · HEAD - · FAIL: %s · повторов: 1\n' "$1" "$2" > "$D/draft-$RANDOM$$.md"
exit 0
STUB
chmod +x "$WORK/scripts/draft_nabludenia.sh"
BARRIER_ROOT="$WORK" "$BARRIER" || true
