# ПРИЧИНА: не совпадает с пином
# ОКРУЖЕНИЕ: PATH=$WORK/repo/bin:$PATH
#
# Ветвь (а), предикат пина: ответу живой пробы можно верить только от бинаря, чей
# sha256 совпадает с config/harness_pin.json. Зелёный контроль: пин под ставку → 0.
# Красное: пин переписан на чужой sha — отказ, а не зелёное (version-only недостаточно).
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_tree "$R"
"$BARRIER" --live "$R"

# Порка: пин называет чужой sha256 — та же версия, другой бинарь
printf '{\n  "version": "17.2.10",\n  "sha256": "%064d"\n' 0 > "$R/config/harness_pin.json"
printf '}\n' >> "$R/config/harness_pin.json"
"$BARRIER" --live "$R"
