# ПРИЧИНА: FAIL потолок
#
# Ветвка потолка: суммарный вывод дайджеста ≤40 строк; превышение списка схлопывается
# строкой «…и ещё N» (не молчит и не разрастается). Стаб «печатаю всё» ловится только
# входом с числом записей выше потолка (на малом дереве он честен).
set -euo pipefail
mkdir -p "$WORK/scripts" "$WORK/.omp/extensions"

# Зелёный контроль: настоящие субъекты из репозитория
cp "$REPO/scripts/nabludenia_digest.sh" "$WORK/scripts/"
cp "$REPO/scripts/check_nabludenia.sh" "$WORK/scripts/"
cp "$REPO/.omp/extensions/startup-digest.ts" "$WORK/.omp/extensions/"
BARRIER_ROOT="$WORK" "$BARRIER"

# Красное: стаб без потолка — печатает всё
cat > "$WORK/scripts/nabludenia_digest.sh" <<'STUB'
#!/usr/bin/env bash
# Подставной дайджест: потолка нет, печатаю всё.
printf 'открытые с адресами:\n'
i=1
while [ "$i" -le 60 ]; do
  printf 'Н-%d → адрес: очередь\n' "$i"
  i=$((i + 1))
done
printf 'черновиков: 0\n'
printf 'непушенных тегов: 0\n'
STUB
chmod +x "$WORK/scripts/nabludenia_digest.sh"
BARRIER_ROOT="$WORK" "$BARRIER" || true
