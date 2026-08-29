# ПРИЧИНА: идентичность
#
# Срез 2 контракта 016, ветвь identity: каждый git-вызов spawn_agent ОБЯЗАН идти с явной
# -c user.name/-c user.email. Без них агентский коммит подписывался бы identity ВЫЗЫВАЮЩЕГО
# или глобальным дефолтом, и общий .git переносил её на ВСЕ worktree (факт hft-провала 0171f1b:
# «14 worktree все подписаны reviewer»).
#
# Вход подобран РАЗЛИЧИМЫМ (Н-39): глобальный конфиг машины подменяет author для всех коммитов
# без явной -c. ИСПЫТАНИЕ: стаб spawn_agent без явной identity выдаёт ветку с author =
# глобальному дефолту; стаб с явной identity выдаёт author = implementer. Зелёный контроль
# выполняется ТОЛЬКО в том случае, если ветка подписана implementer'ом (а не глобальным дефолтом).
#
# Контрактный механизм проверки: после spawn читаем refs/heads/wip/<NNN>/<автор> и смотрим
# author последнего коммита через `git log -1 --format='%an'`. Совпадение с author = implementer.
#
# В этой фикстуре САМОГО спавна нет: spawn_agent.sh вызывается через `$BARRIER` (клиент канала).
# Зелёный контроль — barrier возвращает rc=0 и печатает WORKTREE + BRANCH. Красное — author
# подменён глобальным дефолтом и barrier отказывает поимённо «коммит подписан <X> вместо <Y>».
#
# Стаб с явной identity и стаб без неё ОБА живут в одном файле: реализация spawn_agent
# фиксирована кодом (это не декой), и проверка идёт по РЕЗУЛЬТАТУ — author последнего коммита
# в созданной ветке. Канал `$BARRIER` шлёт наружу только имя скрипта; `$WORK` — пустой каталог.
set -uo pipefail
R="$WORK/repo"
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"
make_repo "$R"

# Зелёный контроль: барьер даёт rc=0, stdout содержит WORKTREE + BRANCH.
"$BARRIER" "$R" implementer || true
out_wt="$(git -C "$R" worktree list --porcelain | awk '/^worktree /{w=$2} /^branch /{if($2=="refs/heads/wip/001/implementer"){print w; exit}}')"
if [ -n "$out_wt" ]; then
  # Автор ПОСЛЕДНЕГО коммита ветки wip/001/implementer должен быть implementer,
  # а не глобальный дефолт машины.
  an="$(git -C "$R" log -1 --format='%an' refs/heads/wip/001/implementer)"
  if [ "$an" != "implementer" ]; then
    # Не отказ — просто красное в тесте. Выходим с rc=1 и текстом.
    printf 'ОТКАЗ: identity расщеплена: author=%s, ожидался implementer — спавн не применил явную identity\n' "$an" >&2
    exit 1
  fi
fi
