#!/usr/bin/env bash
# Раннер реиспользуемой батареи гигиены парсинга (контракт 041, Направление 3,
# fixtures/parsing_hygiene_battery/). Использование:
#   bash run_battery.sh <профиль>
# <профиль> — имя файла (без .sh) в profiles/, объявляющего 4 функции класса
# (см. lib.sh). Этот раннер ОБЩИЙ для всех профилей — не содержит знания ни об
# одном конкретном гарде.
#
# rc 0 — все 4 класса закрыты честно; rc 1 — хотя бы один пробит;
# rc 2 — профиль не найден.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_NAME="${1:?использование: $0 <профиль из profiles/>}"
PROFILE_FILE="$HERE/profiles/$PROFILE_NAME.sh"
if [ ! -f "$PROFILE_FILE" ]; then
  printf 'NOT_IMPLEMENTED: профиль не найден: %s\n' "$PROFILE_FILE" >&2
  exit 2
fi

. "$HERE/lib.sh"
. "$PROFILE_FILE"

battery_case delimiter-collision battery_delimiter_collision
battery_case regex-injection battery_regex_injection
battery_case silent-drop battery_silent_drop
battery_case self-application-green battery_self_application_green

battery_summary
