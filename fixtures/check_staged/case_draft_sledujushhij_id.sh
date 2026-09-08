# ПРИЧИНА: не выдан
#
# Контракт 023, И-4 (cutover peek→дверь, поглощение трогания 019): peek-дверь и
# next_id_peek удалены; draft-пуск staged-пути contracts/<NNN>-<slug>.md под
# architect решает ТЕГ выдачи id/CONTRACT/<NNN> + dual-control (ветвь iii: тег
# на origin ∧ строка «<NNN> → <tag-object-sha>» манифеста на origin/main ∧ sha),
# а НЕ вычисление «следующий свободный» из состояния дерева. Прежняя редакция
# этого файла пиновала peek-семантику max+1 по четырём источникам — она умерла
# вместе с peek; её красное «peek-номер без резерва» перешло к
# red_dver_po_tegu.sh (в2, прямые запуски — А-82), пины грамматики разбора
# принадлежат барьеру next_id (issue-режим жив), не двери стража.
#
# Входы (Н-39 — по коду check_staged.sh:274-369; А-82 — различающие ассерты ДО
# первой зелёно-красной пары; серийные входы одного case — А-32):
#   * ПИН (зелёный, ассерт строки): полный резерв mint_rezerv <next> (тег +
#     строка манифеста на origin/main + оба пуша — toy-origin file-path bare,
#     прецедент 022 red_push_*), ветка своя wip/<next>/architect, staged
#     contracts/<next>-draft.md → rc 0 СО СТРОКОЙ
#     «(дверь по тегу id/CONTRACT/<next> пропущена под architect)» — только она
#     отличает пропуск по двери от пропуска по зоне. Доп-зоны contracts/ НЕТ:
#     стаб «всё-зелёный по зонам» и покойный peek-код дают rc без строки —
#     ассерт валит фикстуру ДО красного кандидата (А-73), красный от стаба не
#     становится законным красным кандидатом раннера;
#   * ПИН многоразовости (зелёный, ассерт строки; боль Б2 контракта 023):
#     draft-коммит уже в ветке, staged ПРАВКА того же драфта → rc 0 со строкой
#     двери снова — дверь многоразова до приземления; peek-мир здесь краснел
#     «вне зоны» (peek ушёл на N+1 после первой посадки);
#   * красный кандидат (предмет «реестр, не вычисление»; зелёный контроль
#     прежней peek-редакции, обращён конверсией 023): contracts/<занятый>-base.md
#     на HEAD, тега <next> НЕТ, staged contracts/<next>-draft.md под architect
#     на своей ветке → rc 1 «номер <next> не выдан» (условие 2, реестр
#     первичен, origin воротами не опрашивается). Peek-код этот вход ПУСКАЛ
#     (rc 0, «draft next-id пропущен») — вычисление больше не источник двери;
#   * охрана «судья не создаёт тег id/*» (мера не меняет предмет): снимок
#     id-тегов ДО вызова против ПОСЛЕ на каждом судимом репо (правило 8 —
#     ожидание в памяти проверяющего).
#
# М-1 (арбитраж ebc57db, дисциплина прежней редакции сохранена): занятый номер —
# ПАРАМЕТР, дефолт 019; производный номер драфта — 10#-арифметикой (+1), литерал
# производного запрещён (вторая точка подстановки дала бы стабу ключование).
# Единственная точка подстановки — строка чтения CHECK_STAGED_ZANJATYJ_NOMER
# ниже; подстановка — окружением команды прогона, файлы не правятся:
#   CHECK_STAGED_ZANJATYJ_NOMER=137 bash scripts/verify_antiplacebo.sh . \
#     --scope check_staged/case_draft_sledujushhij_id
# Допустимые значения: три цифры, 002…998 (999 запрещён: +1 вышел бы за формат
# трёх цифр). Без подстановки прогон детерминирован дефолтом.
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"

# ── М-1: занятый номер — параметр (ЕДИНСТВЕННАЯ точка подстановки) ────────────
ZANJATYJ_NOMER="${CHECK_STAGED_ZANJATYJ_NOMER:-019}"
case "$ZANJATYJ_NOMER" in
  [0-9][0-9][0-9]) ;;
  *) printf 'ОТКАЗ: занятый номер «%s» — не три цифры (М-1: 002…998)\n' "$ZANJATYJ_NOMER" >&2
     exit 1 ;;
esac
case "$((10#$ZANJATYJ_NOMER))" in
  [2-9]|[1-9][0-9]|[1-9][0-9][0-8]) ;;
  *) printf 'ОТКАЗ: занятый номер %s вне диапазона 002…998 (М-1)\n' "$ZANJATYJ_NOMER" >&2
     exit 1 ;;
esac
DRAFT_NOMER="$(printf '%03d' "$((10#$ZANJATYJ_NOMER + 1))")"  # номер драфта = резерв двери

# Локальные ассерты (правило 8: ожидание — в памяти проверяющего, снимок ДО
# вызова субъекта против ПОСЛЕ). Ассерты стоят ДО красного кандидата — после
# него раннер rc фикстуры не судит (А-73).
id_tags_of() {  # <корень> — снимок id-тегов выдачи репо
  git -C "$1" for-each-ref --format='%(refname)' 'refs/tags/id/'
}
assert_no_new_id_tags() {  # <корень> <снимок-до> — новых id-тегов быть не должно
  local novye
  novye="$(comm -13 <(printf '%s\n' "$2" | sort) <(printf '%s\n' "$(id_tags_of "$1")" | sort))"
  if [ -n "${novye//$'\n'/}" ]; then
    printf 'ОТКАЗ: судья создал тег выдачи id/* — мера изменила предмет (%s): %s\n' "$1" "$novye" >&2
    exit 1
  fi
}
assert_dver_propushhena() {  # <вывод барьера> — строка двери обязательна
  if ! printf '%s\n' "$1" | grep -Fq "(дверь по тегу id/CONTRACT/$DRAFT_NOMER пропущена под architect)"; then
    printf 'ОТКАЗ: draft %s пропущен НЕ по двери — строки «(дверь по тегу id/CONTRACT/%s пропущена под architect)» нет (стаб?: пропуск по зоне/peek): %s\n' "$DRAFT_NOMER" "$DRAFT_NOMER" "$1" >&2
    exit 1
  fi
}

# ── ПИН (зелёный, ассерт): полный резерв → дверь пускает СО СТРОКОЙ ───────────
# Занятый <занятый> на HEAD — фон старого мира: дверь его больше не читает
# (источники max+1 не опрашиваются), номер драфта существует только тегом.
GREEN="$WORK/repo_dver_rezerv"
make_repo_archzone "$GREEN"
toy_origin "$GREEN" >/dev/null
mint_rezerv "$GREEN" "$DRAFT_NOMER"
co_wip "$GREEN" "wip/$DRAFT_NOMER/architect"
set_author "$GREEN" architect
green_id0="$(id_tags_of "$GREEN")"
stage "$GREEN" "contracts/$DRAFT_NOMER-draft.md" "черновик $DRAFT_NOMER — первая посадка по резерву (сосед $ZANJATYJ_NOMER занят файлом, дверь его не читает)"
out="$("$BARRIER" "$GREEN" || true)"
assert_dver_propushhena "$out"
assert_no_new_id_tags "$GREEN" "$green_id0"

# ── ПИН многоразовости (зелёный, ассерт; боль Б2): draft-коммит в ветке, ──────
# staged ПРАВКА того же драфта — дверь открыта все круги критика до приземления.
printf '\nправка драфта кругом критика\n' >> "$GREEN/contracts/$DRAFT_NOMER-draft.md"
g "$GREEN" add -A
g "$GREEN" commit -q -m 'draft: первая посадка'
printf '\nвторая правка драфта\n' >> "$GREEN/contracts/$DRAFT_NOMER-draft.md"
g "$GREEN" add -A
out="$("$BARRIER" "$GREEN" || true)"
assert_dver_propushhena "$out"
assert_no_new_id_tags "$GREEN" "$green_id0"

# ── красный кандидат: следующий-свободный БЕЗ резерва (peek-мир пускал) ───────
# <занятый> на HEAD (файл), тега <next> нет, origin не настроен — дверь читает
# ТОЛЬКО реестр (условие 2 первично, провенанс не опрашивается). Peek-код: rc 0
# «(draft next-id пропущен под architect)» — зелёный контроль прежней редакции;
# конверсия 023 обращает его в красное «номер <next> не выдан».
RED="$WORK/repo_dver_bez_rezerva"
make_repo_busy019 "$RED"
co_wip "$RED" "wip/$DRAFT_NOMER/architect"
set_author "$RED" architect
red_id0="$(id_tags_of "$RED")"
stage "$RED" "contracts/$DRAFT_NOMER-draft.md" "черновик $DRAFT_NOMER — следующий свободный по старому max+1, резерва нет"
"$BARRIER" "$RED" || true                    # ожидание: rc 1 «номер <next> не выдан»

# Охрана id/* для этого репо — живой прогон (после красного кандидата механикой
# раннера не судится, А-73; оставлена для прямого запуска фикстуры руками).
assert_no_new_id_tags "$RED" "$red_id0"
