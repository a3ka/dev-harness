#!/usr/bin/env bash
# s5_renames.sh — ОБМАННЫЙ СТАБ: без --no-renames (в porcelain log переименования
# ВКЛЮЧЕНЫ по умолчанию) — переименование уставного документа получает статус R и
# выпадает из фильтра MD. Наблюдаемая ложь: d5_pereim (D старого пути не судится).
st113_renames_vkl() { :; }
ST113_RENAMES=st113_renames_vkl
. "$(dirname "${BASH_SOURCE[0]}")/../_karkas_staba.sh"
