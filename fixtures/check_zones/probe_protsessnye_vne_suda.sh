#!/usr/bin/env bash
# Проба предмета А контракта 013 — находки 1 и 2 вердикта contracts-013-v1.
#
# Параметризованный обход ПОЛНОГО каталога verdicts/ (все четыре подкаталога) плюс
# обоих корневых NABLIUDENIA*.md и HANDOFF.md: частный фильтр «только verdicts/critic/*»
# обязан краснеть ЗДЕСЬ, собственным кодом возврата пробы, а не в чтении журнала
# раннера. Каждая ветвь — отдельный коммит и вызов барьера с ОЖИДАЕМЫМ кодом;
# расхождение печатается поимённо и делает rc пробы ненулевым.
#
# Сейчас (предмет не реализован): процессные ветви дают 1 → rc пробы 1.
# После реализации: rc 0 ровно когда все процессные ветви зелёные, а смешанный
# коммит и охранная — красные (фильтр не шире и не молчаливее предмета).
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$HERE/_repo.sh"
S="$(cd "$HERE/../.." && pwd)/scripts"
W="$(mktemp -d "${TMPDIR:-/tmp}/probe-protsessnye.XXXXXX")"
trap 'rm -rf "$W"' EXIT
R="$W/repo"
make_repo "$R" 'ЗОНА agent-x: scripts/a.sh fixtures/a/'

fails=0
sud() {  # вызов барьера; код и вывод — в RC/OUT
  set +e
  OUT="$(bash "$S/check_zones.sh" "$R" 2>&1)"
  RC=$?
  set -e
}
zap() {  # <ожидаемый rc> <имя ветви>
  if [ "$RC" -ne "$1" ]; then
    printf 'ветвь «%s»: барьер вернул rc=%s, ожидается %s\n' "$2" "$RC" "$1" >&2
    printf '%s\n' "$OUT" | sed 's/^/    /' >&2
    fails=$((fails + 1))
  fi
}

sud; zap 0 'положительный контроль: зонных коммитов ещё нет'
printf 'правка в своей зоне\n' >> "$R/scripts/a.sh"
commit_as "$R" agent-x 'работа внутри объявленной зоны'
sud; zap 0 'положительный контроль: правка в зоне'

for pod in critic adversary review arbitration; do
  mkdir -p "$R/verdicts/$pod"
  printf 'accept\nпроцессный вердикт роли %s — вне суда зон\n' "$pod" > "$R/verdicts/$pod/process-001.md"
  commit_as "$R" agent-x "процессный: вердикт $pod"
  sud; zap 0 "процессный: verdicts/$pod/"
done

for f in NABLIUDENIA.md NABLIUDENIA_ARCHITECT.md; do
  printf 'процессный файл %s\n' "$f" > "$R/$f"
  commit_as "$R" agent-x "процессный: $f"
  sud; zap 0 "процессный: $f (корневой глоб NABLIUDENIA*.md)"
done

printf 'передача контекста\n' > "$R/HANDOFF.md"
commit_as "$R" agent-x 'процессный: HANDOFF.md'
sud; zap 0 'процессный: HANDOFF.md (точный файл)'

printf 'ещё передача контекста\n' > "$R/HANDOFF.md"
printf 'предметный файл вне зоны\n' > "$R/scripts/c.sh"
commit_as "$R" agent-x 'смешанный: процессное и предметное одним коммитом'
sud; zap 1 'смешанный коммит: суд по предметной половине'

printf 'предметный коммит без процессных файлов\n' > "$R/scripts/b.sh"
commit_as "$R" agent-x 'предметный коммит без процессных файлов'
sud; zap 1 'охранная: исключение не шире трёх путей'

[ "$fails" -eq 0 ] || exit 1
