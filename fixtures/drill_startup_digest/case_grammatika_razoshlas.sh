# ПРИЧИНА: FAIL грамматика
#
# Ветвь одного источника истины (класс «два источника» из .gitignore-урока): строка
# `# ГРАММАТИКА: …` в check_nabludenia.sh и nabludenia_digest.sh обязана совпадать
# ПОБАЙТОВО — иначе барьер механизма 1 и дайджест разъедутся молча. Стаб с чужим
# маркером ловится только этой сверкой.
set -euo pipefail
mkdir -p "$WORK/scripts" "$WORK/.omp/extensions"

# Зелёный контроль: настоящие субъекты из репозитория
cp "$REPO/scripts/nabludenia_digest.sh" "$WORK/scripts/"
cp "$REPO/scripts/check_nabludenia.sh" "$WORK/scripts/"
cp "$REPO/.omp/extensions/startup-digest.ts" "$WORK/.omp/extensions/"
BARRIER_ROOT="$WORK" "$BARRIER"

# Красное: стаб-барьер с другой грамматикой
cat > "$WORK/scripts/check_nabludenia.sh" <<'STUB'
#!/usr/bin/env bash
# Подставной барьер: грамматика разошлась с дайджестом.
# ГРАММАТИКА: ^### X-\d+\. другой-regex-не-тот
printf 'стаб: другая грамматика\n'
exit 0
STUB
chmod +x "$WORK/scripts/check_nabludenia.sh"
BARRIER_ROOT="$WORK" "$BARRIER" || true
