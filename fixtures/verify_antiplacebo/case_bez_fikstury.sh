# ПРИЧИНА: verify_toy.sh: нет фикстур
#
# Барьер объявлен барьером и фикстур не имеет. Это главное правило механизма: зелёный,
# которого не видели красным, не доказывает ничего.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
fake_root "$WORK"
"$BARRIER" "$WORK"
rm -rf "$WORK/fixtures/verify_toy"
"$BARRIER" "$WORK"
