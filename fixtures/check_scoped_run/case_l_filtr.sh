# ПРИЧИНА: не сузил
# Ветвь (л): барьер ловит раннер, который на `--changed` НЕ сужает выборку (гонит весь набор).
# Зелёный контроль — референс-раннер (`_ref_va.sh`, корректный фильтр). Красное — реальный
# непатченный раннер (игнорит `--changed`, гонит все барьеры → «барьеров: 2»). Обманный
# стаб-барьер (всегда 0) красноты не даст — фикстура его убивает.
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cp "$(dirname "$0")/_ref_va.sh" "$G/scripts/verify_antiplacebo.sh"; chmod +x "$G/scripts/verify_antiplacebo.sh"
"$BARRIER" "$G" л

R="$WORK/red"; mkdir -p "$R/scripts"
cp "$REPO/scripts/verify_antiplacebo.sh" "$R/scripts/verify_antiplacebo.sh"; chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" л
