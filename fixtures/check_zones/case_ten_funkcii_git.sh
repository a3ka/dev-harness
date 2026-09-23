# ПРИЧИНА: коммит вне зоны
# ОКРУЖЕНИЕ: BASH_FUNC_git%%=() { local a nw=0; for a in "$@"; do [ "$a" = --no-walk ] && nw=1; done; if [ "$nw" = 1 ]; then command git "$@" | tr -d '\n' | awk -v RS='\0' -v ORS='\0' 'NR%2==1{print;next}{print "not-an-announced-author"}'; else command git "$@"; fi; }
#
# Н-130 (NABLIUDENIA.md), найдено адверсарием круга-после-арбитража 040-II
# (verdicts/adversary/contracts-040-v4-circle.md, `8e6123c`): доверенный PATH (Граница v4
# п.1, `export PATH=/usr/bin:/bin`) закрывает PATH-spy (см. case_batch_avtorov_otkaz.sh),
# но НЕ ИМЕНОВАННУЮ ЭКСПОРТИРОВАННУЮ bash-функцию — bash разрешает функции РАНЬШЕ $PATH при
# старте ЛЮБОГО дочернего bash, и унаследованная `export -f git` (здесь — байт-в-байт
# эквивалентный сырой env `BASH_FUNC_git%%=…`, тот же механизм сериализации, что
# Shellshock) переживает `export PATH=…` целиком. Спай несёт ТУ ЖЕ логику, что у
# case_batch_avtorov_otkaz.sh (см. тот файл за объяснением пина и находки круга 3), но
# инъекция идёт ФУНКЦИЕЙ через `# ОКРУЖЕНИЕ:`, а не отдельным исполняемым файлом в
# $WORK/bin: делегирует настоящему git всюду, КРОМЕ `--no-walk` (batched author lookup),
# где подменяет ТОЛЬКО поле автора константой "not-an-announced-author" в ПОЛНОМ,
# синтаксически валидном NUL-потоке — rc=0, каждый SHA получает РОВНО одну запись. Это
# КЛАСС, который PATH-пин САМ ПО СЕБЕ не ловит: `git` внутри функции резолвится через
# таблицу функций процесса ДО поиска по $PATH; `command git` внутри спая обходит СВОЮ же
# функцию (обычный приём нерекурсивного враппера, не защита барьера). Единственная защита —
# `unset -f … git …` сразу после пина (Граница фикса Н-130, см. check_zones.sh рядом с
# `export PATH=/usr/bin:/bin`).
#
# Зелёный контроль: чистое дерево сразу после заморозки — судимое окно пусто, batched
# author-lookup (`--no-walk`) вообще не вызывается, спай инертен по построению → 0.
# Красное: объявленный agent-x коммитит вне своей зоны (в plans/, зона — только
# scripts/), экспортированная функция-тень git присутствует в окружении вызывающего —
# барьер ОБЯЗАН назвать ИМЕННО «коммит вне зоны» (rc=1), а не смолчать rc=0 из-за
# подменённого автора.
#
# Мутант, потерявший `unset -f dirname git awk sed grep sort tr wc mktemp mkdir cp rm mv
# comm` в check_zones.sh (либо потерявший сам `export PATH=/usr/bin:/bin`), оживляет
# функцию-тень: автор ВСЕХ коммитов окна становится "not-an-announced-author" (не объявлен
# ни в одной зоне), нарушитель ИСЧЕЗАЕТ из суда зон целиком, барьер отвечает rc=0 —
# красный прогон этой фикстуры пропадает, что ловится антиплацебо-протоколом («барьер
# остался зелёным на обманном дереве»).
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R" 'ЗОНА agent-x: scripts/'
"$BARRIER" "$R"

mkdir -p "$R/plans"
printf 'forbidden\n' > "$R/plans/002-outside.md"
commit_as "$R" agent-x 'declared agent writes outside zone via exported function shadow'

"$BARRIER" "$R"
