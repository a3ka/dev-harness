# ПРИЧИНА: имя каталога ≠ имени фронтматтера
#
# Ветвь (б): имя каталога и имя фронтматтера разошлись — фильтры --skills ломаются.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_tree "$R"
"$BARRIER" "$R"

mv "$R/skills/tdd" "$R/skills/tdd-renamed"
"$BARRIER" "$R"
