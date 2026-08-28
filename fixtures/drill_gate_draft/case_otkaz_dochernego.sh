# ПРИЧИНА: FAIL проброс отказа
#
# Ветвь расширения (инвариант 5 механизма 2): отказ ВЫЗЫВАЕМОГО скрипта внутри handler
# проглатывается — процесс жив; стаб «пробрасываю отказ дочернего» наблюдаем только
# входом, где вызываемый скрипт завершается ненулевым кодом: при нулевом коде и без
# вызова он честен (case_chernovik_ne_pishetsja, case_rasshirenie_ne_podnjato).
set -euo pipefail
mkdir -p "$WORK/scripts" "$WORK/.omp/extensions"

# Зелёный контроль: настоящие субъекты из репозитория
cp "$REPO/scripts/draft_nabludenia.sh" "$WORK/scripts/"
cp "$REPO/.omp/extensions/gate-draft.ts" "$WORK/.omp/extensions/"
BARRIER_ROOT="$WORK" "$BARRIER"

# Красное: стаб-расширение роняет процесс на отказе вызываемого скрипта
cat > "$WORK/.omp/extensions/gate-draft.ts" <<'STUB'
// Подставное расширение: подписка есть, но отказ вызываемого скрипта пробрасывается
// throw — процесс падает, вместо проглатывания (fail-open).
export default function (_pi: unknown): void {
  const fail = (): never => {
    throw new Error("дочерний скрипт отказал");
  };
  fail();
}
STUB
BARRIER_ROOT="$WORK" "$BARRIER" || true
