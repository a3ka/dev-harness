# ПРИЧИНА: локальный git config
#
# Фикстура, затирающая ЛОКАЛЬНЫЙ конфиг инструмента, меняет предмет не меньше правки файла:
# 12 коммитов этого репозитория подписаны именем «Дрилл» именно так — какая-то фикстура или
# дрилл прошлой редакции писала git config без -C (NABLIUDENIA.md, Н-10). .git из слепка
# исключён обоснованно — он меняется от любой законной команды, — поэтому конфиг сверься
# отдельной мерой: хеш выписки локальных значений до и после прогона.
#
# Зелёный контроль: честный игрушечный барьер → 0. Красное: фикстура меняет user.name в
# КОРНЕ подставного репозитория между вызовами → код 1.
set -euo pipefail
mkdir -p "$WORK/scripts" "$WORK/fixtures/igrushka" "$WORK/tmp"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$WORK" >/dev/null
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$WORK" config user.name Original
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$WORK" config user.email orig@local
cat > "$WORK/scripts/igrushka.sh" <<'EOF'
#!/usr/bin/env bash
# Игрушечный барьер пробы слепка.
# Коды возврата: 0 — порчи нет, 1 — порча есть.
set -euo pipefail
[ -f "${1:-.}/porcha" ] && { printf 'FAIL порча найдена\n' >&2; exit 1; }
printf '  ok   порчи нет\n' >&2
EOF
cat > "$WORK/fixtures/igrushka/case_porcha.sh" <<'EOF'
# ПРИЧИНА: порча найдена
set -euo pipefail
"$BARRIER" "$WORK"
touch "$WORK/porcha"
"$BARRIER" "$WORK"
EOF
"$BARRIER" "$WORK"

cat > "$WORK/fixtures/igrushka/case_porcha.sh" <<'EOF'
# ПРИЧИНА: порча найдена
set -euo pipefail
"$BARRIER" "$WORK"
touch "$WORK/porcha"
# Значение уникально за прогон: повторный прогон не исполняет сценарий фикстуры, а гоняет барьер
# на уже-затёртом конфиге — фиксированное значение делало повтор зелёным («запись не подтверждена»).
git -C "$REPO" config user.name "Zaterto-$$"
"$BARRIER" "$WORK"
EOF
rm -rf "$WORK/tmp/antiplacebo"
"$BARRIER" "$WORK"
