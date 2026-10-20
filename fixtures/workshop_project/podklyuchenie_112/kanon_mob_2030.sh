#!/usr/bin/env bash
# Контракт 112 v2d — парный оракул ЗАПРЕТА доставки backend-стандартов в
# профиль Complior-mob (блокер критика круга 2 v2: «backend contextPack в
# mob» не судился ничем — проверка mob, проверка back и оракул back
# возвращали rc 0 на профиле mob с обеими строками стандартов).
#
# Слово владельца 2026-10-20 ~13:45/~14:30 UTC (строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ
# v2): «contextPack профиля Complior-back с обоими файлами, профиль
# Complior-mob без них». Оракул судит ДОСТАВЛЕННЫЙ профиль mob: ЛЮБАЯ
# строка contextPack с путём backend-стандарта — включая доставку ЧАСТИ
# строк (один из двух файлов) и любую форму/роли/mandatory строки —
# именованный отказ. Прочие строки contextPack mob (собственные строки
# проекта, если владелец объявит их позже) не судятся; sourceCanon в mob —
# НЕ предмет этого оракула (2330 «канон только для бэкенда»; судьба канона
# mob — форк Ф-1, владелец).
#
# Дисциплина та же, что у kanon_back_2030.sh (v2d): ошибка jq/нечитаемая
# структура = именованный отказ contextpack-forma, НИКОГДА молчаливый
# пропуск; на пути суждения нет 2>/dev/null.
#
# Замкнутый алфавит причин:
#   contextpack-mob-lishnij — строка backend-стандарта доставлена в mob
#   contextpack-forma       — профиль/contextPack нечитаем (rows не массив,
#                             элемент не объект, битый JSON, файла нет)
# rc: 0 — строк backend-стандартов в contextPack профиля нет; 1 — ≥1
# именованный отказ; 2 — неправильный вызов (нет --repo, нет jq, нет каталога).
set -uo pipefail

# ── литеральные пути backend-стандартов (2030 §3 + слово владельца 13:45;
# носитель байтов ожидания — этот оракул, Н-351; те же пути несёт CTXROWS
# kanon_back_2030.sh и мир make_world батареи) ────────────────────────────────
ZAPRET='docs/ARCHITECTURE.md
docs/CODING-STANDARDS.md'

REPO=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:-}"; shift 2 ;;
    --repo=*) REPO="${1#--repo=}"; shift ;;
    *) printf 'kanon-mob-2030: неизвестный аргумент: %s\n' "$1" >&2; exit 2 ;;
  esac
done
[ -n "$REPO" ] && [ -d "$REPO" ] || { printf 'kanon-mob-2030: нет --repo <каталог>\n' >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { printf 'kanon-mob-2030: нет jq\n' >&2; exit 2; }
R="$(cd "$REPO" && pwd -P)"
PROF="$R/harness.project.json"

itog=0
fail() { printf 'ОТКАЗ: kanon-mob-2030: %s: %s\n' "$1" "$2" >&2; itog=1; }

if [ ! -f "$PROF" ]; then
  # fail-closed: судить нечего — но и молча пройти нельзя (правило 8-класса)
  fail contextpack-forma "harness.project.json нет в $R — запрет не проверяем"
  exit "$itog"
fi

while IFS= read -r zpath; do
  [ -n "$zpath" ] || continue
  # rc-проверяемое чтение (v2d): присутствие судится по .path ЛИТЕРАЛЬНО,
  # форма/роли/mandatory строки роли не играют — сам факт доставки запрещён;
  # пустой вывод при rc 0 (пустой/несчитанный профиль) = нечитаем = forma
  cnt="$(jq -r --arg p "$zpath" '.contextPack.rows // [] | map(select(.path == $p)) | length' "$PROF" 2>&1)"
  if [ $? -ne 0 ] || [ -z "$cnt" ]; then
    fail contextpack-forma "$zpath: contextPack нечитаем: ${cnt%%$'\n'*}"
    continue
  fi
  [ "$cnt" = "0" ] || fail contextpack-mob-lishnij "$zpath доставлен в профиль mob (строк: $cnt)"
done < <(printf '%s\n' "$ZAPRET")

exit "$itog"
