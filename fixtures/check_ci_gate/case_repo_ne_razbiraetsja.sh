# ПРИЧИНА: не извлекается OWNER/REPO
# ОКРУЖЕНИЕ: PATH=$WORK/bin:$PATH
#
# Remote чужого вида (не github) — отказ с именем формы, а не поход в сеть
# по мусорному URL. Зелёный контроль: github-remote → 0. Красное: bitbucket → 1.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R"
"$BARRIER" "$R"

g "$R" remote set-url origin git@bitbucket.org:example/probe.git
"$BARRIER" "$R"
