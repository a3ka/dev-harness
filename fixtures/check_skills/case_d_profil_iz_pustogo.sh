# ПРИЧИНА: профиль не совпадает
#
# Ветвь (д): барьер создаёт ПУСТОЙ временный HOME, запускает overlay, затем cmp каждого
# SKILL.md профиля с репозиторным. No-op overlay — расхождение. Предзаполнить профиль
# невозможно: он создан пустым барьером.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_tree "$R"
mkdir -p "$R/scripts"
cat > "$R/scripts/overlay_stub.sh" <<'EOF'
#!/usr/bin/env bash
# Подставной overlay: копирует скилы в профиль
printf '  ok   скилы разложены\n' >&2
EOF
chmod +x "$R/scripts/overlay_stub.sh"
"$BARRIER" "$R"

# Порча: подменяем overlay на no-op, который только печатает ok
cat > "$R/scripts/overlay_stub.sh" <<'EOF'
#!/usr/bin/env bash
# Подставной overlay: no-op, печатает ok и ничего не кладёт
printf '  ok   скилы разложены\n' >&2
EOF
chmod +x "$R/scripts/overlay_stub.sh"
"$BARRIER" "$R"
