#!/usr/bin/env bash
# Проба предмета А контракта 013 — находка 3 вердикта contracts-013-v1, план Б
# (решение владельца 2026-08-26, условие — круг 4): сводная строка называет
# исключенное СПИСКОМ, и проба сверяет ТОЧНУЮ последовательность путей с
# повторами в КАЖДОЙ точке. Список накапливается за весь обходимый диапазон,
# поэтому каждая точка сверяет хвост целиком — от первой записи до последней.
#
# ПОВТОР (выход круга 4): тот же процессный путь, исключённый вторым коммитом
# (M того же HANDOFF.md), обязан стоять в хвосте ДВАЖДЫ — дедупликация хвоста
# (множество уникальных путей) расходит последовательность на этой точке.
#
# Пары процессных файлов ОДНОГО вида в обеих ветвях реализации (круги 2–3 +
# РЕШЕНИЕ арбитража kontrakt-013-edinitsa-scheta): подмена записи «исключённый
# файл» на коммит, вид фильтра или префикс пути (в том числе ПО ВЕТВЯМ) расходит
# хвост хотя бы на одной из этих точек:
#  ЧИСТАЯ — два файла ОДНОГО вида (оба в verdicts/critic/) одним коммитом:
#    ОБЕ записи в хвосте, rc 0 (запись-коммит или запись-вид даёт одну);
#  СМЕШАННАЯ — два процессных ОДНОГО вида (оба корневые NABLIUDENIA*.md)
#    плюс предметный вне зоны: ОБЕ записи в хвосте, предметный в хвост НЕ
#    попадает, rc 1 по предметной половине. Смешанная ветвь последняя: её
#    красный необратим (А-35 — все ветви с ожидаемым rc 0 стоят раньше).
#
# Сейчас (списка нет): первая же сверка хвоста расходит → rc 1.
# После реализации: rc 0 ровно когда маркер печатается и хвост точен.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$HERE/_repo.sh"
S="$(cd "$HERE/../.." && pwd)/scripts"
W="$(mktemp -d "${TMPDIR:-/tmp}/probe-svod.XXXXXX")"
trap 'rm -rf "$W"' EXIT
R="$W/repo"
make_repo "$R" 'ЗОНА agent-x: scripts/a.sh'

fails=0
sud() {
  set +e
  OUT="$(bash "$S/check_zones.sh" "$R" 2>&1)"
  RC=$?
  set -e
}
zap() {  # <ожидаемый rc> <ожидаемая последовательность путей> <имя ветви>
  local want="$1" lst="$2" name="$3" line got
  if [ "$RC" -ne "$want" ]; then
    printf 'ветвь «%s»: барьер вернул rc=%s, ожидается %s\n' "$name" "$RC" "$want" >&2
    printf '%s\n' "$OUT" | sed 's/^/    /' >&2
    fails=$((fails + 1))
  fi
  line="$(printf '%s\n' "$OUT" | grep -m1 'процессных вне суда' || true)"
  if [ -z "$line" ]; then
    printf 'ветвь «%s»: в сводной строке нет маркера «процессных вне суда:»\n' "$name" >&2
    printf '%s\n' "$OUT" | sed 's/^/    /' >&2
    fails=$((fails + 1))
    return
  fi
  # хвост после маркера → нормализованная последовательность слов (пути проб
  # пробелов не содержат; разделитель запятая/пробел схлопывается)
  # shellcheck disable=SC2086
  set -- $(printf '%s' "${line#*процессных вне суда:}" | tr ',;' '  ')
  got="$*"
  if [ "$got" != "$lst" ]; then
    printf 'ветвь «%s»: хвост списка расходится:\n    есть: %s\n    ждём: %s\n' \
      "$name" "${got:-(пусто)}" "${lst:-(пусто)}" >&2
    fails=$((fails + 1))
  fi
}

printf 'правка в своей зоне\n' >> "$R/scripts/a.sh"
commit_as "$R" agent-x 'работа внутри объявленной зоны'
sud; zap 0 '' 'положительный контроль: правка в зоне, исключений нет — маркер с пустым хвостом'

printf 'accept\nпроцессный вердикт критика\n' > "$R/verdicts/critic/process-001.md"
commit_as "$R" agent-x 'процессный: вердикт критика'
sud; zap 0 'verdicts/critic/process-001.md' 'первое исключение: запись в хвосте'

printf 'наблюдение архитектора\n' > "$R/NABLIUDENIA_ARCHITECT.md"
commit_as "$R" agent-x 'процессный: наблюдение'
sud; zap 0 'verdicts/critic/process-001.md NABLIUDENIA_ARCHITECT.md' 'второй вид: запись добавлена'

printf 'передача контекста\n' > "$R/HANDOFF.md"
commit_as "$R" agent-x 'процессный: HANDOFF.md'
sud; zap 0 'verdicts/critic/process-001.md NABLIUDENIA_ARCHITECT.md HANDOFF.md' 'третий вид: HANDOFF.md в хвосте'

printf 'вторая передача контекста\n' > "$R/HANDOFF.md"
commit_as "$R" agent-x 'процессный: повторная правка HANDOFF.md другим коммитом'
sud; zap 0 'verdicts/critic/process-001.md NABLIUDENIA_ARCHITECT.md HANDOFF.md HANDOFF.md' \
  'ПОВТОР: тот же путь вторым коммитом — запись в хвосте ДВАЖДЫ (дедупликация расходит здесь)'

printf 'вердикт ревьюера\n' > "$R/verdicts/critic/process-006.md"
printf 'ещё вердикт ревьюера\n' > "$R/verdicts/critic/process-007.md"
commit_as "$R" agent-x 'чисто процессный: два файла одного вида одним коммитом'
sud; zap 0 'verdicts/critic/process-001.md NABLIUDENIA_ARCHITECT.md HANDOFF.md HANDOFF.md verdicts/critic/process-006.md verdicts/critic/process-007.md' \
  'чистая пара ОДНОГО вида одним коммитом: ОБЕ записи в хвосте (запись-коммит и запись-вид дают одну)'

printf 'наблюдение судьи\n' > "$R/NABLIUDENIA_SUDJA.md"
printf 'наблюдение арбитра\n' > "$R/NABLIUDENIA_ARBITRA.md"
printf 'предметный файл вне зоны\n' > "$R/scripts/c.sh"
commit_as "$R" agent-x 'смешанный: два процессных одного вида и предметное одним коммитом'
sud; zap 1 'verdicts/critic/process-001.md NABLIUDENIA_ARCHITECT.md HANDOFF.md HANDOFF.md verdicts/critic/process-006.md verdicts/critic/process-007.md NABLIUDENIA_ARBITRA.md NABLIUDENIA_SUDJA.md' \
  'смешанная пара ОДНОГО вида: ОБЕ записи в хвосте, предметный файл в хвост НЕ попадает, rc 1 по предметной половине (по-ветвевая подмена записи краснеет здесь)'

[ "$fails" -eq 0 ] || exit 1
