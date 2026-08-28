# ПРИЧИНА: FAIL ahead/behind
#
# Ветвь дерева (инвариант 2 механизма 3): расходящийся с origin репозиторий обязан
# печататься РЕАЛЬНЫМИ ahead/behind. Дрилл сам строит репозиторий с локальным коммитом
# сверх origin; стаб «всегда ahead 0, behind 0» наблюдаем только на этом входе — на
# синхронном дереве он честен.
set -euo pipefail
mkdir -p "$WORK/scripts" "$WORK/.omp/extensions"

# Зелёный контроль: настоящие субъекты из репозитория
cp "$REPO/scripts/nabludenia_digest.sh" "$WORK/scripts/"
cp "$REPO/scripts/check_nabludenia.sh" "$WORK/scripts/"
cp "$REPO/.omp/extensions/startup-digest.ts" "$WORK/.omp/extensions/"
BARRIER_ROOT="$WORK" "$BARRIER"

# Красное: стаб-дайджест печатает нули всегда
cat > "$WORK/scripts/nabludenia_digest.sh" <<'STUB'
#!/usr/bin/env bash
# Подставной дайджест: ahead/behind всегда нули, дерево всегда чисто.
printf 'дерево: HEAD = origin (ahead 0, behind 0), чисто\n'
STUB
chmod +x "$WORK/scripts/nabludenia_digest.sh"
BARRIER_ROOT="$WORK" "$BARRIER" || true
