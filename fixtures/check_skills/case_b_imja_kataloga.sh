# ПРИЧИНА: имя каталога ≠ имени фронтматтера
# ОКРУЖЕНИЕ: PATH=$WORK/repo/bin:$PATH
#
# Ветвь (б): имя каталога и имя фронтматтера разошлись — фильтры --skills ломаются.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_tree "$R"
"$BARRIER" --live "$R"

mv "$R/skills/tdd" "$R/skills/tdd-renamed"
"$BARRIER" --live "$R"
