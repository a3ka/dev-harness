# ПРИЧИНА: FAIL fallback
#
# Ветвь расширения (механизм 3): скрипт упал → ОДИН sendMessage со строкой «дайджест
# не собран» — процесс жив. Дрилл сам валит вызываемый скрипт; стаб «пробрасываю
# падение скрипта» наблюдаем только на этом входе: на живом скрипте он честен
# (case_rasshirenie_fail_open судит подписку, не проброс).
set -euo pipefail
mkdir -p "$WORK/scripts" "$WORK/.omp/extensions"

# Зелёный контроль: настоящие субъекты из репозитория
cp "$REPO/scripts/nabludenia_digest.sh" "$WORK/scripts/"
cp "$REPO/scripts/check_nabludenia.sh" "$WORK/scripts/"
cp "$REPO/.omp/extensions/startup-digest.ts" "$WORK/.omp/extensions/"
BARRIER_ROOT="$WORK" "$BARRIER"

# Красное: стаб-расширение роняет процесс на падении скрипта
cat > "$WORK/.omp/extensions/startup-digest.ts" <<'STUB'
// Подставное расширение: падение вызываемого скрипта пробрасывается throw, вместо
// одного sendMessage «дайджест не собран».
export default function (pi: any): void {
  pi.on("session_start", () => {
    const r = pi.run("scripts/nabludenia_digest.sh");
    if (r.exitCode !== 0) throw new Error("дайджест упал: " + r.exitCode);
    pi.sendMessage(r.stdout);
  });
}
STUB
BARRIER_ROOT="$WORK" "$BARRIER" || true
