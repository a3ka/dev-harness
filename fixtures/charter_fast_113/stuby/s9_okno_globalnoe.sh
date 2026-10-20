#!/usr/bin/env bash
# s9_okno_globalnoe.sh — ОБМАННЫЙ СТАБ: глобальное incr-окно обрезает проход git log
# до cache..HEAD для ВСЕХ документов сразу (дефект прототипа круга 2 критика).
# Наблюдаемая ложь: d9_bokovaja_zamorozka — боковая заморозка ПОСЛЕ кеша (тег не
# предок кеша, merge пустой дельтой): per-document диапазон документа остаётся
# since..HEAD и включает коммит-кеш, глобальное окно его теряет.
# Честен на d8_kesh_valid: там глобальное окно совпадает с per-document
# (since каждого документа — предок кеша).
st113_range_globalnoe() { printf '%s\n' "${INCR_WINDOW:-HEAD}"; }
ST113_RANGE=st113_range_globalnoe
. "$(dirname "${BASH_SOURCE[0]}")/../_karkas_staba.sh"
