# ПРИЧИНА: коммит вне зоны
#
# Н-14: done-тег сужает диапазон. Зелёный: done закрывает диапазон ДО out-of-zone коммита → 0.
# Красное: done ПОСЛЕ out-of-zone коммита → диапазон включает нарушение → код 1.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R" 'ЗОНА agent-x: scripts/'
printf 'правка в зоне\n' >> "$R/scripts/a.sh"
commit_as "$R" agent-x 'в зоне'
g "$R" tag -a done/contracts/001/1 -m 'закрыт до нарушения'
printf 'правка после закрытия\n' > "$R/plans/posle.md"
commit_as "$R" agent-x 'после done'
"$BARRIER" "$R"

# Порча: удаляем done и ставим ПОСЛЕ нарушающего коммита
g "$R" tag -d done/contracts/001/1 >/dev/null
g "$R" tag -a done/contracts/001/1 -m 'теперь после нарушения'
"$BARRIER" "$R"
