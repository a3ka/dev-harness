# ПРИЧИНА: FAIL внутренняя ошибка
#
# Ветвь fail-open скрипта (инвариант 5 механизма 2): внутренняя ошибка mkdir/записи —
# печать причины в stderr, rc=0, черновика нет, сессия жива. Дрилл сам заводит
# сломанную базу черновиков; стаб «пробрасываю внутренний отказ наружу» наблюдаем
# только на этом входе: на исправной базе он честен (case_chernovik_ne_pishetsja).
set -euo pipefail
mkdir -p "$WORK/scripts" "$WORK/.omp/extensions"

# Зелёный контроль: настоящие субъекты из репозитория, отказ базы проглочен
cp "$REPO/scripts/draft_nabludenia.sh" "$WORK/scripts/"
cp "$REPO/.omp/extensions/gate-draft.ts" "$WORK/.omp/extensions/"
BARRIER_ROOT="$WORK" "$BARRIER"

# Красное: стаб-скрипт валит вызов вместо fail-open
cat > "$WORK/scripts/draft_nabludenia.sh" <<'STUB'
#!/usr/bin/env bash
# Подставной скрипт: внутренняя ошибка базы — отказ пробрасывается (fail-closed).
set -euo pipefail
mkdir -p "${TMPDIR:-/tmp}/dev-harness-nabludenia/drafts" 2>/dev/null || exit 3
exit 3
STUB
chmod +x "$WORK/scripts/draft_nabludenia.sh"
BARRIER_ROOT="$WORK" "$BARRIER" || true
