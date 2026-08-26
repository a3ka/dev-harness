#!/usr/bin/env bash
# Проба грамматики событий §Предмет Б контракта 013 — находка 4 вердикта
# contracts-013-v1: R<100, CR/trim-нормировка класса, неизвестный класс и порядок
# двух файлов разных классов в одном коммите обязаны быть ИСПОЛНЯЕМЫМИ ветвями,
# а не прозой. Каждая ветвь — отдельное дерево с чистым таймлайном глоба и заморозкой
# с ожидаемым кодом; частичная A/M-реализация (игнор R<100 или неизвестного класса,
# счёт коммитами, обход файлов в произвольном порядке) оставляет свою ветвь красной.
#
# Ветви и ожидания ПОСЛЕ реализации (сейчас — см. «сейчас» в каждой):
#  1. CR/trim: « accept␍» — та же первая строка после нормировки, круг не растёт;
#     ожидается rc 0 (кругов 2). Сейчас: 3 коммита по глобу → ложный кап → rc 1.
#  2. порядок: один коммит A v2 FAIL + A v3 accept; порядок по пути даёт события
#     [accept, FAIL, accept] = 3 круга → кап → ожидается rc 1. Сейчас: 2 коммита →
#     кап молчит → rc 0.
#  3. неизвестный класс «МУСОР»: событие всё равно; [FAIL, МУСОР, accept] = 3 →
#     ожидается rc 1. Сейчас: 3 коммита → rc 1 (совпадает; ветвь охраняет от
#     стаба «неизвестный класс не считать»).
#  4. R<100: переименование с правкой первой строки даёт событие НАЗНАЧЕНИЯ;
#     [FAIL, accept, FAIL, accept] = 4 → ожидается rc 1. Сейчас: 4 коммита → rc 1
#     (ветвь охраняет от стаба «любое R — форма»).
#  5. R100 (круг 2 вердикта: в обеих прежних R100-историях ложный класс совпадал
#     с хвостом и сжимался): чистое переименование события НЕ даёт; события
#     [FAIL, FAIL, accept] → сжатый [FAIL, accept] = 2 → ожидается rc 0. Сейчас:
#     4 коммита по глобу → счёт коммитами 4 ≥ 3 → ложный кап → rc 1. Стаб «любое
#     R — событие назначения» даст ложное FAIL при хвосте accept: сжатый
#     [FAIL, accept, FAIL] = 3 → кап → rc 1 — краснеет ровно здесь.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$HERE/_repo.sh"
S="$(cd "$HERE/../.." && pwd)/scripts"
W="$(mktemp -d "${TMPDIR:-/tmp}/probe-grammatika.XXXXXX")"
trap 'rm -rf "$W"' EXIT

fails=0
base_repo() {  # <каталог> — основание БЕЗ вердиктов: таймлайн глоба чист
  local r="$1"
  mkdir -p "$r/contracts" "$r/verdicts/critic" "$r/tmp"
  printf 'предмет, критерий готовности, РАБОТА НЕ РАЗДАЁТСЯ: кодификация\n' > "$r/contracts/001-x.md"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.name Фикстура
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.email fixture@local
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config commit.gpgsign false
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config core.hooksPath /dev/null
  commit_all "$r" 'основание'
}
sud() {  # <корень> <причина> — вызов заморозки; код и вывод в RC/OUT
  set +e
  OUT="$(bash "$S/freeze_contract.sh" contracts/001-x.md "$2" "$1" 2>&1)"
  RC=$?
  set -e
}
zap() {  # <ожидаемый rc> <имя ветви>
  if [ "$RC" -ne "$1" ]; then
    printf 'ветвь «%s»: заморозка вернула rc=%s, ожидается %s\n' "$2" "$RC" "$1" >&2
    printf '%s\n' "$OUT" | sed 's/^/    /' >&2
    fails=$((fails + 1))
  fi
}

# ── 1. CR/trim-нормировка класса ──────────────────────────────────────────────
R="$W/cr"; base_repo "$R"
put_verdict "$R" 1 FAIL
commit_all "$R" 'A v1 FAIL — круг 1'
put_verdict "$R" 1 accept
commit_all "$R" 'M v1 accept — круг 2'
printf ' accept\r\nпервая строка с CR и пробелами — тот же класс accept после нормировки\n' \
  > "$R/verdicts/critic/contracts-001-v1.md"
commit_all "$R" 'M v1: первая строка та же после tr -d и trim'
sud "$R" 'CR/trim: смена лишь формой — круг один'
zap 0 'CR/trim: [FAIL, accept, accept] → кругов 2, кап не срабатывает'

# ── 2. порядок файлов одного коммита по пути ──────────────────────────────────
R="$W/mnogo"; base_repo "$R"
put_verdict "$R" 1 accept
commit_all "$R" 'A v1 accept — круг 1'
put_verdict "$R" 2 FAIL
put_verdict "$R" 3 accept
commit_all "$R" 'A v2 FAIL + A v3 accept одним коммитом — порядок по пути'
sud "$R" 'порядок по пути: v2 раньше v3'
zap 1 'порядок: [accept, FAIL, accept] → кругов 3, кап на месте'

# ── 3. неизвестный класс — событие всё равно ──────────────────────────────────
R="$W/neizv"; base_repo "$R"
put_verdict "$R" 1 FAIL
commit_all "$R" 'A v1 FAIL — круг 1'
printf 'МУСОР вне грамматики\nтело\n' > "$R/verdicts/critic/contracts-001-v1.md"
commit_all "$R" 'M v1: неизвестный класс'
put_verdict "$R" 1 accept
commit_all "$R" 'M v1 accept — финальный круг'
sud "$R" 'неизвестный класс — тоже событие'
zap 1 'неизвестный класс: [FAIL, МУСОР, accept] → кругов 3'

# ── 4. R<100 — событие НАЗНАЧЕНИЯ ─────────────────────────────────────────────
R="$W/r95"; base_repo "$R"
printf 'FAIL\nтело вердикта\nстрока три\nстрока четыре\n' > "$R/verdicts/critic/contracts-001-v1.md"
commit_all "$R" 'A v1 FAIL — круг 1'
printf 'accept\nтело вердикта\nстрока три\nстрока четыре\n' > "$R/verdicts/critic/contracts-001-v1.md"
commit_all "$R" 'M v1 accept — круг 2'
g "$R" mv "$R/verdicts/critic/contracts-001-v1.md" "$R/verdicts/critic/contracts-001-v1x.md"
printf 'FAIL\nтело вердикта\nстрока три\nстрока четыре\n' > "$R/verdicts/critic/contracts-001-v1x.md"
commit_all "$R" 'R<100 v1→v1x с первой строкой FAIL — событие назначения'
g "$R" mv "$R/verdicts/critic/contracts-001-v1x.md" "$R/verdicts/critic/contracts-001-v1.md"
printf 'accept\nтело вердикта\nстрока три\nстрока четыре\n' > "$R/verdicts/critic/contracts-001-v1.md"
commit_all "$R" 'R<100 v1x→v1 с первой строкой accept — событие назначения'
sud "$R" 'переименование с правкой — событие назначения'
zap 1 'R<100: [FAIL, accept, FAIL, accept] → кругов 4'

# ── 5. R100 — чистое переименование события НЕ даёт ───────────────────────────
# Переносится файл с первой строкой FAIL, ОТЛИЧНОЙ от класса последнего события
# другого файла глоба (v1 → accept): ложно начисленный круг виден — не сжимается.
R="$W/r100"; base_repo "$R"
put_verdict "$R" 1 FAIL
commit_all "$R" 'A v1 FAIL — круг 1'
put_verdict "$R" 2 FAIL
commit_all "$R" 'A v2 FAIL — тот же класс: сжатие держит круг один'
put_verdict "$R" 1 accept
commit_all "$R" 'M v1 accept — круг 2, хвост таймлайна accept'
g "$R" mv "$R/verdicts/critic/contracts-001-v2.md" "$R/verdicts/critic/contracts-001-v9.md"
commit_all "$R" 'R100 v2→v9: чистое переименование, первая строка FAIL не менялась'
sud "$R" 'R100: событие назначения нет — кругов 2'
zap 0 'R100: [FAIL, FAIL, accept] → сжатый [FAIL, accept] → кругов 2, кап не срабатывает'

[ "$fails" -eq 0 ] || exit 1
