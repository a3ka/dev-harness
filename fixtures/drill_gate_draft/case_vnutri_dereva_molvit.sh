# ПРИЧИНА: FAIL дерево
#
# Ветвь «черновики ВНЕ стерегомого дерева» (семантика 014, развилка 3): TMPDIR,
# канонически равный стерегомому корню скрипта или лежащий внутри него, — именованный
# отказ код 1 ДО создания чего-либо (путь может не существовать: каноникализация
# спуском до существующего предка). Стаб «пишу куда сказали» ловится только этим
# входом: на внешнем TMPDIR он честен.
set -euo pipefail
mkdir -p "$WORK/scripts" "$WORK/.omp/extensions"

# Зелёный контроль: настоящие субъекты из репозитория
cp "$REPO/scripts/draft_nabludenia.sh" "$WORK/scripts/"
cp "$REPO/.omp/extensions/gate-draft.ts" "$WORK/.omp/extensions/"
BARRIER_ROOT="$WORK" "$BARRIER"

# Красное: стаб принимает TMPDIR внутри дерева и пишет туда
cat > "$WORK/scripts/draft_nabludenia.sh" <<'STUB'
#!/usr/bin/env bash
# Подставной субъект: стерегомого дерева не знает, пишет куда сказали.
D="${TMPDIR:-/tmp}/dev-harness-nabludenia/drafts"
mkdir -p "$D"
printf 'ДАТА · ГЕЙТ %s · HEAD - · FAIL: %s · повторов: 1\n' "$1" "$2" > "$D/draft.md"
exit 0
STUB
chmod +x "$WORK/scripts/draft_nabludenia.sh"
BARRIER_ROOT="$WORK" "$BARRIER" || true
