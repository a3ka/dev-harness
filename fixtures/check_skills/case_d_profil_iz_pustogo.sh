# ПРИЧИНА: профиль не совпадает
# ОКРУЖЕНИЕ: PATH=$WORK/repo/bin:$PATH
#
# Ветвь (д): барьер создаёт ПУСТОЙ временный HOME, запускает overlay-скрипт и сверяет
# ПОЛНОЕ дерево каждого скила с репозиторным — не один SKILL.md. Зелёный контроль:
# overlay-скрипта НЕТ — барьер раскладывает сам, деревья совпадают. Красное — из
# вердикта адверсария milestone-003-zakrytie §2: заглушка кладёт ТОЛЬКО SKILL.md,
# вложенные файлы (tdd/mocking.md, agents/openai.yaml, …) пропадают — и это отказ.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_tree "$R"
"$BARRIER" "$R"

# Порча: overlay-заглушка раскладывает по одному SKILL.md на скил — дерево неполно
mkdir -p "$R/scripts"
cat > "$R/scripts/overlay_stub.sh" <<'OV'
#!/usr/bin/env bash
home="${HOME:?}"
skills="$(cd "$(dirname "$0")/.." && pwd)/skills"
for d in "$skills"/*/; do
  s="$(basename "$d")"
  mkdir -p "$home/.omp/agent/skills/$s"
  cp "$d/SKILL.md" "$home/.omp/agent/skills/$s/SKILL.md"
done
OV
chmod +x "$R/scripts/overlay_stub.sh"
"$BARRIER" "$R"
