# ПРИЧИНА: FAIL черновики
#
# Ветвь пустых секций нулём: пустая выборка ВИДНА («черновиков: 0»), а не молчит —
# «нечего проверять» не равно «проверено» (правило замеров). Стаб «пропускаю пустые
# секции» ловится только входом с пустым каталогом черновиков.
set -euo pipefail
mkdir -p "$WORK/scripts" "$WORK/.omp/extensions"

# Зелёный контроль: настоящие субъекты из репозитория
cp "$REPO/scripts/nabludenia_digest.sh" "$WORK/scripts/"
cp "$REPO/scripts/check_nabludenia.sh" "$WORK/scripts/"
cp "$REPO/.omp/extensions/startup-digest.ts" "$WORK/.omp/extensions/"
BARRIER_ROOT="$WORK" "$BARRIER"

# Красное: стаб пропускает пустые секции
cat > "$WORK/scripts/nabludenia_digest.sh" <<'STUB'
#!/usr/bin/env bash
# Подставной дайджест: пустые секции не печатаю вовсе.
printf 'открытые с адресами: 0\n'
printf 'непушенных тегов: 0\n'
STUB
chmod +x "$WORK/scripts/nabludenia_digest.sh"
BARRIER_ROOT="$WORK" "$BARRIER" || true
