# ПРИЧИНА: FAIL remote недоступен
#
# Ветвь дерева (инвариант 2 механизма 3): недоступный remote — строка «remote
# недоступен» и живой rc=0, НЕ падение. Дрилл сам указывает репозиторию мёртвый
# remote; стаб «валюсь на ls-remote» наблюдаем только на этом входе — на доступном
# remote он честен.
set -euo pipefail
mkdir -p "$WORK/scripts" "$WORK/.omp/extensions"

# Зелёный контроль: настоящие субъекты из репозитория
cp "$REPO/scripts/nabludenia_digest.sh" "$WORK/scripts/"
cp "$REPO/scripts/check_nabludenia.sh" "$WORK/scripts/"
cp "$REPO/.omp/extensions/startup-digest.ts" "$WORK/.omp/extensions/"
BARRIER_ROOT="$WORK" "$BARRIER"

# Красное: стаб-дайджест падает на недоступном remote
cat > "$WORK/scripts/nabludenia_digest.sh" <<'STUB'
#!/usr/bin/env bash
# Подставной дайджест: недоступный remote валит сбор — нет строки «remote недоступен».
git ls-remote --tags origin >/dev/null 2>&1 || exit 1
printf 'дерево: HEAD = origin (ahead 0, behind 0), чисто\n'
STUB
chmod +x "$WORK/scripts/nabludenia_digest.sh"
BARRIER_ROOT="$WORK" "$BARRIER" || true
