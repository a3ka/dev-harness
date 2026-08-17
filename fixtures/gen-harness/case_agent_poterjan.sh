# ПРИЧИНА: нет файла: reviewer.md
#
# Предмет `--check` — пустое расхождение с `roles/`: дрейф обязан быть НЕВОЗМОЖНЫМ, а не
# наказуемым. Подставной каталог агентов сначала полон (барьер зелен), потом недосчитывает
# одну роль.
#
# `BARRIER_ROOT` здесь не нужен и был бы вреден: у барьера есть `--into <каталог>`, а
# побайтовая копия `.ts` в подставном корне потеряла бы `import './roles.ts'`.
set -euo pipefail
mkdir -p "$WORK/agents"
cp "$REPO"/.omp/agents/*.md "$WORK/agents/"
"$BARRIER" --into "$WORK/agents" --check
rm "$WORK/agents/reviewer.md"
"$BARRIER" --into "$WORK/agents" --check
