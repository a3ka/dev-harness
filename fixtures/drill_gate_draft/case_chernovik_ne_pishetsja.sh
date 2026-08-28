# ПРИЧИНА: FAIL черновик
#
# Дрилл-переворот (образец 005/drill_protected_exception): зелёная ветвь «отказ гейта
# порождает черновик со всеми полями и README-шапкой каталога» фикстурой не выражается —
# её предъявляет сам дрилл на НАСТОЯЩИХ субъектах (зелёный контроль ниже). Красное —
# подставной draft_nabludenia.sh, который ничего не пишет: стаб «тихий отказ» ловится
# только на этом входе (на не-гейте и успехе он честен).
set -euo pipefail
mkdir -p "$WORK/scripts" "$WORK/.omp/extensions"

# Зелёный контроль: настоящие субъекты из репозитория
cp "$REPO/scripts/draft_nabludenia.sh" "$WORK/scripts/"
cp "$REPO/.omp/extensions/gate-draft.ts" "$WORK/.omp/extensions/"
BARRIER_ROOT="$WORK" "$BARRIER"

# Красное: стаб — черновик не пишется вовсе
cat > "$WORK/scripts/draft_nabludenia.sh" <<'STUB'
#!/usr/bin/env bash
# Подставной субъект: «успешно» ничего не делает.
printf 'стаб: черновиков не будет\n' >&2
exit 0
STUB
chmod +x "$WORK/scripts/draft_nabludenia.sh"
BARRIER_ROOT="$WORK" "$BARRIER" || true
