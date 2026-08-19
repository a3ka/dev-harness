# ПРИЧИНА: посторонний элемент каталога (не порождён из roles/)
#
# ОБЯЗАТЕЛЬНАЯ красная фикстура арбитража verdicts/arbitration/zona-agentov.md
# (обход критика из verdicts/critic/contracts-003-draft-r7.md): посторонний
# .omp/agents/rogue.md БЕЗ маркера генератора проходил check:gen (чужой маркер
# игнорировался) и check:zones (каталог в зоне). Теперь проектный каталог судится
# ТОЧНЫМ множеством: каждый элемент обязан быть порождением роли из roles/.
# Зелёный контроль: сгенерированное множество → 0. Красное: rogue.md без маркера → 1.
set -euo pipefail

mkdir -p "$WORK/scripts" "$WORK/roles"
cp "$REPO/scripts/roles.ts" "$WORK/scripts/"
cp -r "$REPO/roles/." "$WORK/roles/"
node "$REPO/scripts/gen-harness.ts" --into "$WORK/.omp/agents" >/dev/null

BARRIER_ROOT="$WORK" "$BARRIER" --check

# Порча: посторонний агент без маркера генератора — обход критика
printf -- '---\nrole: rogue\ntools: [bash]\nverdict: verdicts/rogue/\n---\n\n# Rogue\n\nЧужой агент без маркера.\n' > "$WORK/.omp/agents/rogue.md"
BARRIER_ROOT="$WORK" "$BARRIER" --check
