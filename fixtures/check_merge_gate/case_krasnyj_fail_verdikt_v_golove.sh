# ПРИЧИНА: нет закоммиченного accept-вердикта ревьюера
#
# Красное предъявление И-2: единственный закоммиченный вердикт — `FAIL` на
# первой строке блоба `HEAD:<путь>` — НЕ `accept`. Гейт И-2 обязан пройти
# весь `*.md` под `.harness/verdicts/`, не найти ни одного `accept` и отказать
# ИМЕНОВАННОЙ причиной («нет закоммиченного accept-вердикта ревьюера»).
#
# Без этой клетки стаб, читающий вердикт только из РАБОЧЕЙ копии (или
# константно открывающий ворота), прошёл бы зелёным контролем — и фикстура
# была бы неотличима от `case_zelenyj`. Грязная копия tracked-вердикта
# (HEAD блоб FAIL, рабочий файл accept) НЕ открывает ворота — И-2 судит
# блоб, не рабочий файл (контракт 063, защищает явной формулировкой).
#
# Зелёный контроль: чистый accept в HEAD → rc 0; затем подмена на FAIL +
# подмена рабочей копии на accept → rc 1 (тот же именованный отказ).
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
put_accept "$R" "stk-063-fail.md"

# Положительный контроль: чистый accept → rc 0.
out="$("$BARRIER" --repo "$R" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ] && [ -z "$out" ]; then
  printf '  ok   «зелёный контроль» accept → rc 0, stdout пуст\n' >&2
else
  printf '  FAIL «зелёный контроль»: rc=%s\nвывод:\n%s\n' "$rc" "$out" >&2
  exit 1
fi

# Красное: подмена на FAIL + грязная копия поверх (И-2 обязан судить блоб).
printf 'FAIL\n\n# переписано\n' > "$R/.harness/verdicts/stk-063-fail.md"
commit_all "$R" 'вердикт переписан на FAIL'
# Грязная копия: HEAD блоб = FAIL; рабочий файл = accept. Если бы гейт
# читал рабочую копию — был бы зелёный; И-2 обязан красить.
printf 'accept\n\n# dirty copy\n' > "$R/.harness/verdicts/stk-063-fail.md"

out="$("$BARRIER" --repo "$R" 2>&1)"; rc=$?
PHRASE='merge gate ОТКАЗ: нет закоммиченного accept-вердикта ревьюера'
if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$PHRASE"; then
  printf '  ok   «красное» FAIL в HEAD (при грязной копии accept) — rc 1, причина названа дословно\n' >&2
  exit 0
fi
printf '  FAIL «красное» FAIL в HEAD: rc=%s (ожидался 1)\nожидалась дословная фраза: %s\nфактический вывод:\n%s\n' \
  "$rc" "$PHRASE" "$out" >&2
exit 1
