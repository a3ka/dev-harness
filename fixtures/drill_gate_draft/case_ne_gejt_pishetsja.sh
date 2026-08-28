# ПРИЧИНА: FAIL не-гейт
#
# Ветвь гейт-паттерна: фильтр «гейт или нет» живёт в draft_nabludenia.sh (единственный
# источник), не-гейт (ls /nonexistent) черновика не порождает. Стаб «пишу на ЛЮБУЮ
# команду» — спам-генератор; на настоящем отказе гейта он честен, различим только
# входом «isError, но не гейт».
set -euo pipefail
mkdir -p "$WORK/scripts" "$WORK/.omp/extensions"

# Зелёный контроль: настоящие субъекты из репозитория
cp "$REPO/scripts/draft_nabludenia.sh" "$WORK/scripts/"
cp "$REPO/.omp/extensions/gate-draft.ts" "$WORK/.omp/extensions/"
BARRIER_ROOT="$WORK" "$BARRIER"

# Красное: стаб пишет черновик на любую команду
cat > "$WORK/scripts/draft_nabludenia.sh" <<'STUB'
#!/usr/bin/env bash
# Подставной субъект: гейт-паттерна нет, черновик на любой вызов.
D="${TMPDIR:-/tmp}/dev-harness-nabludenia/drafts"
mkdir -p "$D"
printf 'ДАТА · ГЕЙТ %s · HEAD - · FAIL: %s · повторов: 1\n' "$1" "${2:-}" > "$D/draft-$RANDOM$$.md"
exit 0
STUB
chmod +x "$WORK/scripts/draft_nabludenia.sh"
BARRIER_ROOT="$WORK" "$BARRIER" || true
