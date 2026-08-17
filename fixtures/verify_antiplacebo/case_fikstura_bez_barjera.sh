# ПРИЧИНА: fixtures/verify_ghost: фикстура без барьера
#
# Сверка в обе стороны. Барьер переименовали или удалили, а его фикстура осталась и создаёт
# вид проверенности: каталог есть, кейсы есть, держать нечего.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
fake_root "$WORK"
mkdir -p "$WORK/fixtures/verify_ghost"
printf '# ПРИЧИНА: неважно\ntrue\n' > "$WORK/fixtures/verify_ghost/case_a.sh"
"$BARRIER" "$WORK"
