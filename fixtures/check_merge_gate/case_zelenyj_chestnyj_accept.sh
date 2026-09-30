# ПРИЧИНА: нет закоммиченного accept-вердикта ревьюера
#
# Зелёный контроль семьи check_merge_gate (контракт 063, И-1 ∧ И-2 ∧ И-3):
#   (а) `.harness/verdicts/<файл>.md` закоммичен с первой строкой `accept`
#       блоба `HEAD:<путь>` (И-2: вердикт из `git show`, не рабочей копии);
#   (б) каталог `.review/` отсутствует — И-3 тривиально выполняется.
#
# Красная половина — снятие accept: без закоммиченного accept в HEAD ворота
# закрыты И-1 (конъюнкция). Покрывает деградацию «потерян accept-артефакт»:
# стаб, константно открывающий ворота (печатающий «ok» и выходящий 0) на
# чистом дереве без accept прошёл бы зелёным — этот кейс ловит его по
# второй половине.
#
# Правило 3 нормы (зелёный контроль обязателен): без первой половины клетки
# вечно-красный гейт неотличим от честного — стаб, печатающий «ok» и выходящий
# 0, удовлетворил бы проверку наличия фикстуры (прецедент check_decisions, 002).
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
put_accept "$R" "stk-063-accept.md"

# Положительный контроль: accept в HEAD ∧ нет .review → гейт rc 0, stdout пуст.
out="$("$BARRIER" --repo "$R" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ] && [ -z "$out" ]; then
  printf '  ok   «зелёный контроль»: accept в HEAD ∧ нет .review — rc 0, stdout пуст\n' >&2
else
  printf '  FAIL «зелёный контроль»: rc=%s\nвывод:\n%s\n' "$rc" "$out" >&2
  exit 1
fi

# Красная половина: удалить accept из HEAD (rm + commit) — ворота обязаны
# закрыться И-1 с именованной причиной И-2.
git -C "$R" rm -q .harness/verdicts/stk-063-accept.md
commit_all "$R" 'accept снят'
out="$("$BARRIER" --repo "$R" 2>&1)"; rc=$?
PHRASE='merge gate ОТКАЗ: нет закоммиченного accept-вердикта ревьюера'
if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$PHRASE"; then
  printf '  ok   «красное»: снятие accept — rc 1, причина названа дословно\n' >&2
  exit 0
fi
printf '  FAIL «красное»: rc=%s (ожидался 1)\nожидалась дословная фраза: %s\nфактический вывод:\n%s\n' \
  "$rc" "$PHRASE" "$out" >&2
exit 1
