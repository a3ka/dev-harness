# ПРИЧИНА: незакрытая находка ревьюера: .review/2026-09-30-01.md (status: ready)
#
# Красное предъявление И-3: `.review/<файл>.md` с frontmatter `status: ready`
# ОБЯЗАН блокировать ворота И-1 с ИМЕНОВАННЫМ отказом (контракт 063, И-3;
# прецедент 002 на check_decisions — находка без имени и значения статуса
# проходила молча). Без accept-вердикта rc был бы 1 по другой причине и
# фикстура не отделила бы И-3 от И-2.
#
# Зелёный контроль: accept закоммичен И находка с `status: done` НЕ блокирует.
# После кладки ready-файла — гейт обязан назвать имя `.md` И литерал статуса.
#
# ОКРУЖЕНИЕ: HARNESS_PROJECT_LAYER_ROOT=$WORK/layer
# Барьер (запускается через `env -i` от verify_antiplacebo) требует
# HARNESS_PROJECT_LAYER_ROOT — без него резолвер И-8 отказывает «корень слоя
# проекта не задан». Слой проекта пишется через `_repo.sh::ensure_project_layer`
# в `$WORK/layer/registry/harness-project.json` — декларация ниже передаёт тот
# же путь барьеру.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_repo.sh"

R="$WORK/repo"
make_repo "$R"
put_accept "$R" "stk-063-redy.md"

# Положительный контроль: до .review/ — гейт зелёный.
out="$("$BARRIER" --repo "$R" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ] && [ -z "$out" ]; then
  printf '  ok   «зелёный контроль» accept ∧ нет .review — rc 0\n' >&2
else
  printf '  FAIL «зелёный контроль»: rc=%s\nвывод:\n%s\n' "$rc" "$out" >&2
  exit 1
fi

# Красное: ready-находка.
review_file "$R" "2026-09-30-01.md" ready
out="$("$BARRIER" --repo "$R" 2>&1)"; rc=$?
PHRASE='merge gate ОТКАЗ: незакрытая находка ревьюера: .review/2026-09-30-01.md (status: ready)'
if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$PHRASE"; then
  printf '  ok   «красное» ready-находка блокирует, причина названа дословно\n' >&2
  exit 0
fi
printf '  FAIL «красное» ready-находка: rc=%s (ожидался 1)\nожидалась дословная фраза: %s\nфактический вывод:\n%s\n' \
  "$rc" "$PHRASE" "$out" >&2
exit 1
