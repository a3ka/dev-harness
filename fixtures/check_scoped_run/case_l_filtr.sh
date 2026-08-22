# ПРИЧИНА: не сузил
# Ветвь (л): барьер ловит раннер, который на `--changed` НЕ сужает выборку (гонит весь набор).
# Зелёный контроль — референс-раннер (`_ref_va.sh`, корректный фильтр → «барьеров: 1»).
# Красное — обманка, которая ИГНОРИРУЕТ `--changed` (зовёт реальный раннер БЕЗ флага → полный
# прогон → «барьеров: 2»). Реальный раннер брать напрямую нельзя: он теперь корректно фильтрует,
# т.е. перестал бы быть обманкой — красное должно умирать от предмета, не от честной реализации.
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cp "$(dirname "$0")/_ref_va.sh" "$G/scripts/verify_antiplacebo.sh"; chmod +x "$G/scripts/verify_antiplacebo.sh"
"$BARRIER" "$G" л

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<EOF
#!/usr/bin/env bash
# обманка: ИГНОРИРУЕТ scoped-флаги → полный прогон (не сужает выборку)
exec "$REPO/scripts/verify_antiplacebo.sh" "\$1"
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" л
