# ПРИЧИНА: профиль не совпадает
#
# Ветвь (д): барьер создаёт ПУСТОЙ временный HOME, ищет overlay-скрипт, запускает его,
# затем cmp каждого SKILL.md профиля с репозиторным. Зелёный контроль: overlay-скрипта
# НЕТ — барьер раскладывает сам, профиль совпадает. Красное: no-op overlay (печатает ok,
# ничего не кладёт) — профиль пуст, cmp ловит расхождение.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_tree "$R"
"$BARRIER" "$R"

# Порча: no-op overlay — барьер его найдёт, запустит, профиль останется пуст
mkdir -p "$R/scripts"
printf '#!/usr/bin/env bash\nprintf "  ok   скилы разложены\\n" >&2\n' > "$R/scripts/overlay_stub.sh"
chmod +x "$R/scripts/overlay_stub.sh"
"$BARRIER" "$R"
