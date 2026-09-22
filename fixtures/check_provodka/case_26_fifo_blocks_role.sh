#!/usr/bin/env bash
# ПРИЧИНА: проводка: role-файл не существует: roles/pipe.md
# ОКРУЖЕНИЕ: BARRIER_ROOT=$WORK
# case_26 — RED (FIFO блокирует exec-open, круг 8 Б4): `roles/pipe.md` —
# FIFO без открытого на запись конца. Без фикса: `exec 9<"$ROOT/$path"`
# открывает FIFO НА ЧТЕНИЕ и БЛОКИРУЕТСЯ (ядро ждёт писателя) — барьер
# зависает, не возвращая ни rc 1, ни rc 124 (пока не сработает внешний
# `timeout`). С фиксом — дешёвый не-блокирующий `[ -f ]` ПЕРЕД exec-open:
# `[ -f ]` ложен на FIFO (POSIX: regular file only), и барьер сразу зелёным
# die-веткой выходит с rc 1 «role-файл не существует: roles/pipe.md» (та же
# фраза, что г3-фолбэк, без новых формулировок). Сам прогон барьера
# обёрнут в `timeout` — если фикс окажется неполным и барьер всё-таки
# зависнет, фикстура вернёт rc 124 (или 124+128) и провалится явно, а не
# повиснет на месте проверяющего. Положительный контроль — regular role
# файл → rc 0.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  REPO="$(cd "$HERE/../.." && pwd -P)"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/case26_038.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
  BARRIER="$REPO/scripts/check_provodka.sh"
  export BARRIER_ROOT="$WORK"
fi

require_absent_subject

# Положительный контроль: честный regular roles/fixer.md → rc 0
G="$WORK/green"; make_toy "$G" 1 1
put_contract "$G" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»'
commit_all "$G" 'g26: chestnyj role (reguljarnyj fajl)'
GREEN_OUT="$("$BARRIER" "$G" "$G/contracts/001-x.md" 2>&1)"; GREEN_RC=$?

# Красный: roles/pipe.md — FIFO без открытого на запись конца. Без фикса —
# exec 9< блокируется (тест-предмет); с фиксом — [ -f ] ложен на FIFO,
# барьер сразу выходит с rc 1.
R="$WORK/red"; make_toy "$R" 1 1
mkdir -p "$R/roles"
printf 'Norma stroki roli v igrushke R.\n' > "$R/roles/fixer.md"
# Создаём FIFO на месте role-цели. Никакого писателя — открытие на чтение
# блокируется ядром до явного `exec 9<"$ROOT/$path"` без фикса.
mkfifo "$R/roles/pipe.md"
put_contract "$R" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/pipe.md «Anything.»
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»'
commit_all "$R" 'r26: role FIFO bez pisatelja (bez fiksa exec-open visit)'

# timeout вокруг барьера — на случай, если фикс окажется неполным.
RED_OUT="$(timeout 5 "$BARRIER" "$R" "$R/contracts/001-x.md" 2>&1)"; RED_RC=$?

if [ -z "${BARRIER:-}" ] || [ "${BARRIER:-x}" = "$REPO/scripts/check_provodka.sh" ]; then
  [ "$GREEN_RC" -eq 0 ] || { printf 'FAIL: case_26 green rc=%s, ожидался 0\n%s\n' "$GREEN_RC" "$GREEN_OUT" >&2; exit 1; }
  printf '%s' "$GREEN_OUT" | grep -Fq 'получено:' \
    && { printf 'FAIL: case_26 green: вывод содержит «получено:»\n%s\n' "$GREEN_OUT" >&2; exit 1; }
  [ "$RED_RC" -eq 1 ] || {
    printf 'FAIL: case_26 red rc=%s, ожидался 1 (124=таймаут, фикс неполный)\n%s\n' "$RED_RC" "$RED_OUT" >&2; exit 1
  }
  printf '%s' "$RED_OUT" | grep -Fq 'проводка: role-файл не существует: roles/pipe.md' \
    || { printf 'FAIL: case_26 red причина не названа дословно\n%s\n' "$RED_OUT" >&2; exit 1; }
  printf 'case_26: прямой rc 0 на зелёном, rc 1 на красном (FIFO pre-check [ -f ] до exec-open)\n' >&2
  exit 0
fi
exit 0
