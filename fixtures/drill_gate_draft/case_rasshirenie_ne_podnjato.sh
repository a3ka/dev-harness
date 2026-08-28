# ПРИЧИНА: FAIL расширение
#
# Ветвь расширения (.omp/extensions/gate-draft.ts): фабрика регистрирует РОВНО ОДИН
# handler на tool_result; падение загрузки/регистрации ловится дриллом как именованный
# отказ (не падением дрилла). Стаб «фабрика есть, handler не регистрирует» различим
# только входом fake-pi со synthetic tool_result.
set -euo pipefail
mkdir -p "$WORK/scripts" "$WORK/.omp/extensions"

# Зелёный контроль: настоящие субъекты из репозитория
cp "$REPO/scripts/draft_nabludenia.sh" "$WORK/scripts/"
cp "$REPO/.omp/extensions/gate-draft.ts" "$WORK/.omp/extensions/"
BARRIER_ROOT="$WORK" "$BARRIER"

# Красное: стаб-расширение ничего не регистрирует
cat > "$WORK/.omp/extensions/gate-draft.ts" <<'STUB'
// Подставное расширение: фабрика экспортирована, handler не регистрирует.
export default function (_pi: unknown): void {
  /* стаб: подписки нет */
}
STUB
BARRIER_ROOT="$WORK" "$BARRIER" || true
