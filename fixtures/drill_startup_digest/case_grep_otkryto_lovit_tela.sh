# ПРИЧИНА: FAIL записи
#
# Ветвь отбора: в дайджест попадают ТОЛЬКО открытые записи (грамматика заголовка
# механизма 1) с их адресами; закрытая запись, цитирующая «ОТКРЫТО» и «адрес:» в ТЕЛЕ,
# не попадает. Стаб «grep ОТКРЫТО по всему файлу» ловится только этим входом — на
# дереве без цитат он неотличим от честного.
set -euo pipefail
mkdir -p "$WORK/scripts" "$WORK/.omp/extensions"

# Зелёный контроль: настоящие субъекты из репозитория
cp "$REPO/scripts/nabludenia_digest.sh" "$WORK/scripts/"
cp "$REPO/scripts/check_nabludenia.sh" "$WORK/scripts/"
cp "$REPO/.omp/extensions/startup-digest.ts" "$WORK/.omp/extensions/"
BARRIER_ROOT="$WORK" "$BARRIER"

# Красное: стаб выбирает записи grep'ом по всему файлу — закрытая с цитатой попадает
cat > "$WORK/scripts/nabludenia_digest.sh" <<'STUB'
#!/usr/bin/env bash
# Подставной дайджест: grep «ОТКРЫТО» по всему файлу, без грамматики заголовка.
R="${2:-.}"
printf 'открытые с адресами:\n'
grep -rn 'ОТКРЫТО' "$R/NABLIUDENIA.md" "$R/NABLIUDENIA_ARCHITECT.md" 2>/dev/null || true
printf 'черновиков: 0\n'
printf 'тегов: 0\n'
STUB
chmod +x "$WORK/scripts/nabludenia_digest.sh"
BARRIER_ROOT="$WORK" "$BARRIER" || true
