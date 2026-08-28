# ПРИЧИНА: FAIL указатель
#
# Ветвь указателя (инвариант 4 механизма 3): дайджест обязан печатать указатель на
# HANDOFF.md §«ГДЕ МЫ» (имя раздела, не текст). Дрилл сам кладёт HANDOFF.md с секцией
# «ГДЕ МЫ» в подставной корень; стаб «не печатаю указатель» наблюдаем на любом входе
# дрилла с живым HANDOFF.md — в пустом корне ветвь не различима (сечения и так нули).
set -euo pipefail
mkdir -p "$WORK/scripts" "$WORK/.omp/extensions"

# Зелёный контроль: настоящие субъекты из репозитория
cp "$REPO/scripts/nabludenia_digest.sh" "$WORK/scripts/"
cp "$REPO/scripts/check_nabludenia.sh" "$WORK/scripts/"
cp "$REPO/.omp/extensions/startup-digest.ts" "$WORK/.omp/extensions/"
BARRIER_ROOT="$WORK" "$BARRIER"

# Красное: стаб-дайджест без указателя на HANDOFF
cat > "$WORK/scripts/nabludenia_digest.sh" <<'STUB'
#!/usr/bin/env bash
# Подставной дайджест: секции есть, указателя на HANDOFF §«ГДЕ МЫ» нет.
printf 'открытые с адресами: 0\nчерновиков: 0\nнепушенных тегов: 0\n'
STUB
chmod +x "$WORK/scripts/nabludenia_digest.sh"
BARRIER_ROOT="$WORK" "$BARRIER" || true
