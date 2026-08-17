# ПРИЧИНА: замораживается только
#
# Грамматика предмета: `plans/NNN-<slug>.md` либо `contracts/NNN-<slug>.md`, ровно три цифры.
# Имя вне грамматики — отказ, а не догадка: номер с двумя смыслами в истории нечем развести, а
# файл без номера не имеет версии заморозки вовсе.
#
# Зелёный контроль: валидный `contracts/001-x.md` при вердикте v1 `accept` → v1.
# Красное: `contracts/draft.md` в том же дереве.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R"
"$BARRIER" contracts/001-x.md "стабилен после трёх переписываний" "$R"

printf 'черновик\n' > "$R/contracts/draft.md"
commit_all "$R" 'черновик без номера'
"$BARRIER" contracts/draft.md "попытка заморозить черновик" "$R"
