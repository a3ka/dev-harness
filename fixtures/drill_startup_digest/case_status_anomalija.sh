# ПРИЧИНА: FAIL чисто
#
# Ветвь дерева (инвариант 2 механизма 3): аномалии git status --short обязаны
# называться; «чисто» печатается только при пустом статусе. Дрилл сам марает рабочее
# дерево подставного корня; стаб «всегда чисто» наблюдаем только на этом входе — на
# чистом дереве он честен.
set -euo pipefail
mkdir -p "$WORK/scripts" "$WORK/.omp/extensions"

# Зелёный контроль: настоящие субъекты из репозитория
cp "$REPO/scripts/nabludenia_digest.sh" "$WORK/scripts/"
cp "$REPO/scripts/check_nabludenia.sh" "$WORK/scripts/"
cp "$REPO/.omp/extensions/startup-digest.ts" "$WORK/.omp/extensions/"
BARRIER_ROOT="$WORK" "$BARRIER"

# Красное: стаб-дайджест печатает «чисто» всегда
cat > "$WORK/scripts/nabludenia_digest.sh" <<'STUB'
#!/usr/bin/env bash
# Подставной дайджест: статус всегда «чисто», аномалии не называются.
printf 'дерево: HEAD = origin (ahead 0, behind 0), чисто\n'
STUB
chmod +x "$WORK/scripts/nabludenia_digest.sh"
BARRIER_ROOT="$WORK" "$BARRIER" || true
