# ПРИЧИНА: FAIL теги
#
# Ветвь непушенных тегов (Н-65: три рецидива): локальный тег, отсутствующий на remote,
# обязан быть назван по имени; всё запушено — секция печатает ноль. Стаб «тегов: 0
# всегда» ловится только входом с непушенным тегом (на запушенном дереве он честен).
set -euo pipefail
mkdir -p "$WORK/scripts" "$WORK/.omp/extensions"

# Зелёный контроль: настоящие субъекты из репозитория
cp "$REPO/scripts/nabludenia_digest.sh" "$WORK/scripts/"
cp "$REPO/scripts/check_nabludenia.sh" "$WORK/scripts/"
cp "$REPO/.omp/extensions/startup-digest.ts" "$WORK/.omp/extensions/"
BARRIER_ROOT="$WORK" "$BARRIER"

# Красное: стаб всегда печатает ноль тегов
cat > "$WORK/scripts/nabludenia_digest.sh" <<'STUB'
#!/usr/bin/env bash
# Подставной дайджест: секция тегов — всегда ноль.
printf 'открытые с адресами: 0\n'
printf 'черновиков: 0\n'
printf 'непушенных тегов: 0\n'
STUB
chmod +x "$WORK/scripts/nabludenia_digest.sh"
BARRIER_ROOT="$WORK" "$BARRIER" || true
