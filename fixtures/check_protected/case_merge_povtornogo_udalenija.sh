# ПРИЧИНА: существовал и на HEAD его нет: verdicts/adversary/v-a.md
#
# Способ шестой, Н-127 блокер Б1 (не-ослабление уточнения `is_lagging_merge_artifact`).
# Путь удалён С разрешением (D1); от D1 отделяется независимая ветка side, не трогающая путь;
# на основной ветке путь ВОССТАНОВЛЕН коммитом R; затем side слита `--no-ff --no-commit`
# (бесконфликтно взяла бы версию R — side его не трогала, «молчит»), и ПОВЕРХ этого явный
# `git rm` убирает путь ЗАНОВО в теле мерж-коммита D2 БЕЗ ALLOW. Разрешение D1 обосновывает
# ПЕРВОЕ, уже случившееся удаление, а не выдаёт индульгенцию на путь навсегда (шапка
# excuse_for, антигейминг). Первая редакция критерия «путь отсутствует хотя бы у одного
# родителя» путала это НАСТОЯЩЕЕ новое удаление (у молчащего родителя side путь
# ПРИСУТСТВУЕТ — бесконфликтный мерж дал бы путь, а не исчезновение) с унаследованным
# отсутствием (repro_n127_otstavshij_roditel.sh, где у молчащего родителя путь уже
# ОТСУТСТВУЕТ) и пропускала D2, принимая устаревшее ALLOW из D1. Уточнённый критерий
# (git merge-base двух родителей + сравнение блобов) обязан различать эти два случая.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R"
"$BARRIER" "$R"
g "$R" rm -q verdicts/adversary/v-a.md
g "$R" commit -q -F - <<'MSG'
D1: разрешённое удаление

ALLOW-ARTIFACT-DELETE: verdicts/adversary/v-a.md первое, законное удаление
MSG
g "$R" checkout -q -b vetka
printf 'независимая правка, путь не трогает\n' > "$R/plans/002-vetka.md"
commit_all "$R" 'side: независимая правка'
g "$R" checkout -q main
mkdir -p "$R/verdicts/adversary"
printf 'вердикт восстановлен\n' > "$R/verdicts/adversary/v-a.md"
commit_all "$R" 'R: путь восстановлен'
g "$R" merge -q --no-ff --no-commit vetka
g "$R" rm -q verdicts/adversary/v-a.md
g "$R" commit -q -m 'D2: путь убран заново в мерже, ALLOW нет'
"$BARRIER" "$R"
