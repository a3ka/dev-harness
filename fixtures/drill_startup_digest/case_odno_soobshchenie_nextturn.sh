# ПРИЧИНА: FAIL sendMessage
#
# Ветвь расширения (механизм 3): на session_start — РОВНО ОДИН sendMessage с
# deliverAs "nextTurn". Дрилл подкладывает fake-pi, пишущий отправки; стаб «шлю два»
# наблюдаем только входом с подсчитанными отправками: неподписанное расширение ловит
# case_rasshirenie_fail_open, там счёт отправок не различим.
set -euo pipefail
mkdir -p "$WORK/scripts" "$WORK/.omp/extensions"

# Зелёный контроль: настоящие субъекты из репозитория
cp "$REPO/scripts/nabludenia_digest.sh" "$WORK/scripts/"
cp "$REPO/scripts/check_nabludenia.sh" "$WORK/scripts/"
cp "$REPO/.omp/extensions/startup-digest.ts" "$WORK/.omp/extensions/"
BARRIER_ROOT="$WORK" "$BARRIER"

# Красное: стаб-расширение шлёт ДВА сообщения вместо ровно одного
cat > "$WORK/.omp/extensions/startup-digest.ts" <<'STUB'
// Подставное расширение: подписка есть, но sendMessage отправляется дважды.
export default function (pi: any): void {
  pi.on("session_start", () => {
    pi.sendMessage("дайджест");
    pi.sendMessage("дайджест ещё раз");
  });
}
STUB
BARRIER_ROOT="$WORK" "$BARRIER" || true
