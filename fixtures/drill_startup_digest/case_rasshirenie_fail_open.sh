# ПРИЧИНА: FAIL расширение
#
# Ветвь расширения (.omp/extensions/startup-digest.ts): на session_start — РОВНО ОДИН
# sendMessage (nextTurn) с текстом = вывод скрипта; падение загрузки/регистрации —
# именованный отказ дрилла, не его падение. Стаб «фабрика есть, session_start не
# регистрирует» различим только входом fake-pi.
set -euo pipefail
mkdir -p "$WORK/scripts" "$WORK/.omp/extensions"

# Зелёный контроль: настоящие субъекты из репозитория
cp "$REPO/scripts/nabludenia_digest.sh" "$WORK/scripts/"
cp "$REPO/scripts/check_nabludenia.sh" "$WORK/scripts/"
cp "$REPO/.omp/extensions/startup-digest.ts" "$WORK/.omp/extensions/"
BARRIER_ROOT="$WORK" "$BARRIER"

# Красное: стаб-расширение ничего не регистрирует
cat > "$WORK/.omp/extensions/startup-digest.ts" <<'STUB'
// Подставное расширение: фабрика экспортирована, session_start не регистрирует.
export default function (_pi: unknown): void {
  /* стаб: подписки нет */
}
STUB
BARRIER_ROOT="$WORK" "$BARRIER" || true
