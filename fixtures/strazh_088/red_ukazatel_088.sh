#!/usr/bin/env bash
# Семья 088, часть Б: pre-commit (.githooks/pre-commit → scripts/check_staged.sh) судит
# staged HANDOFF.md грамматикой клетки k7 (074): первая секция — от первой строки,
# начинающейся «## ГДЕ МЫ», до следующей строки `^## ` (подразделы `### ` внутри),
# строка-указатель — самостоятельной строкой (`grep -Fx`), побайтово PTR_088.
# Судится ИНДЕКС (то, что попадёт в коммит), для любого автора, включая необъявленного
# в заморозках оркестратора. Коммит — ЖИВЫМ способом: `-c user.name=orchestrator`,
# пустой file-config, хук из core.hooksPath.
#
# Использование: bash red_ukazatel_088.sh <корень> [B0 B1 … B18] [--sudja <файл>]
#   --sudja <файл> — подменить scripts/check_staged.sh тоу-репо (стаб-пак/диффпроба).
# Коды: 0 — все судимые клетки зелёные; 1 — есть красная; 2 — нечем проверить.
#
# Клетки (вход → ожидание; ДО 088 красны B1 B2 B3 B4 B6 B7 B11 B14 B15 B16 B17 B18;
# на 6f29c59 — B15 B16 B17 B18):
#   B0  первая секция несёт строку                          → коммит
#   B1  строки нет нигде                                     → отказ
#   B2  строка укорочена (без хвоста «(инвентарь…)»)         → отказ (измеренный отказ 06.10)
#   B3  строка с посторонним хвостом                          → отказ (Fx, не подстрока)
#   B4  строка только во ВТОРОЙ секции «## ГДЕ МЫ»            → отказ
#   B5  строка в подразделе `###` первой секции               → коммит
#   B6  строка после конца первой секции (в «## Итог»)        → отказ
#   B7  индекс без строки, рабочее дерево — со строкой        → отказ (судится индекс)
#   B8  индекс со строкой, рабочее дерево — без               → коммит
#   B9  HANDOFF.md не staged (в HEAD без строки), staged README → коммит
#   B11 staged удаление HANDOFF.md                             → отказ
#   B13 staged docs/HANDOFF.md без строки (не корневой)        → коммит
#   B14 первая секция несёт только строку ATAKA_088, env      → отказ (k7 — из индекса,
#       коммита PTR_088=ATAKA_088 (обход 8bc5e68, adversary 088)   env не источник)
#   B15 первая секция несёт только ATAKA_088; РАБОЧАЯ копия   → отказ (k7 — из индекса,
#       k7 (не staged) переписана на HANDOFF_PTR=ATAKA_088         не из рабочего дерева;
#       (adversary 088-v2 §1)                                       staged — только HANDOFF.md)
#   B16 строки нет; рабочая копия k7 УДАЛЕНА (не staged)      → отказ (суд не зависит от
#                                                                   рабочего файла k7)
#   B17 как B1, env коммитёра OTKAZ_088=ATAKA_088              → отказ ровно строкой И-7
#       (adversary 088-v2 §3)
#   B18 как B11, env коммитёра OTKAZ_088=ATAKA_088             → отказ ровно строкой И-7
# Привязка стабов к клеткам — red_stuby_088.sh (Н-39).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${1:-$HERE/../..}" 2>/dev/null && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
shift || true
SUDJA=""
kletki=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --sudja) SUDJA="${2:-}"; [ -f "$SUDJA" ] || { printf 'NOT_IMPLEMENTED: нет судьи-подмены %s\n' "$SUDJA" >&2; exit 2; }; shift 2 ;;
    *) kletki+=("$1"); shift ;;
  esac
done
for subj in scripts/check_staged.sh .githooks/pre-commit; do
  [ -f "$ROOT/$subj" ] || { printf 'NOT_IMPLEMENTED: нет %s\n' "$ROOT/$subj" >&2; exit 2; }
done
# shellcheck disable=SC1091
. "$HERE/_toy.sh" "${kletki[@]}"

mir() {  # <клетка> → r=путь тоу-репо (без подоболочки: отказ построения — rc 2 файла)
  ukazatel_mir "$SCR/$1" "$SUDJA"
  r="$SCR/$1"
}

K7=fixtures/ops_server/red_server_obvjazka_074.sh
# tolko_handoff <репо> — вход клеток B15/B16 построен: staged — ровно HANDOFF.md, k7 в
# индексе есть (порча — только в рабочем дереве); иначе rc 2 файла (мир не тот).
tolko_handoff() {
  local s
  s="$(gx "$1" diff --cached --name-only)" || exit 2
  [ "$s" = HANDOFF.md ] || { printf 'NOT_IMPLEMENTED: staged мира — не ровно HANDOFF.md: %s\n' "$s" >&2; exit 2; }
  gx "$1" cat-file -e ":$K7" || { printf 'NOT_IMPLEMENTED: в индексе мира нет %s\n' "$K7" >&2; exit 2; }
}

klet_handoff() {  # <клетка> <вариант индекса> <ожидание>
  mir "$1"
  handoff_v "$r/HANDOFF.md" "$2"
  gx "$r" add -- HANDOFF.md || exit 2
  ozhidaj_b "$1" "$r" "$3"
}

nado B0 && klet_handoff B0 pervaja prinjat
nado B1 && klet_handoff B1 net otkaz
nado B2 && klet_handoff B2 ukorochena otkaz
nado B3 && klet_handoff B3 hvost otkaz
nado B4 && klet_handoff B4 vtoraja otkaz
nado B5 && klet_handoff B5 podrazdel prinjat
nado B6 && klet_handoff B6 posle otkaz

if nado B7; then
  mir B7
  handoff_v "$r/HANDOFF.md" net; gx "$r" add -- HANDOFF.md || exit 2
  handoff_v "$r/HANDOFF.md" pervaja            # рабочее дерево исправлено, индекс — нет
  ozhidaj_b B7 "$r" otkaz
fi

if nado B8; then
  mir B8
  handoff_v "$r/HANDOFF.md" podrazdel; gx "$r" add -- HANDOFF.md || exit 2
  handoff_v "$r/HANDOFF.md" net                # индекс конформен, рабочее дерево — нет
  ozhidaj_b B8 "$r" prinjat
fi

if nado B9; then
  mir B9
  handoff_v "$r/HANDOFF.md" net
  gx "$r" add -- HANDOFF.md && gx "$r" commit -q -m 'HEAD без указателя (построение мира)' || exit 2
  printf 'правка\n' >> "$r/README.md"; gx "$r" add -- README.md || exit 2
  ozhidaj_b B9 "$r" prinjat
fi

if nado B11; then
  mir B11
  gx "$r" rm -q -- HANDOFF.md || exit 2
  ozhidaj_b B11 "$r" otkaz
fi

if nado B13; then
  mir B13
  mkdir -p "$r/docs"; handoff_v "$r/docs/HANDOFF.md" net; gx "$r" add -- docs/HANDOFF.md || exit 2
  ozhidaj_b B13 "$r" prinjat
fi

if nado B14; then
  mir B14
  handoff_v "$r/HANDOFF.md" chuzhaja; gx "$r" add -- HANDOFF.md || exit 2
  ozhidaj_b B14 "$r" otkaz PTR_088="$ATAKA_088"
fi

if nado B15; then
  mir B15
  handoff_v "$r/HANDOFF.md" chuzhaja; gx "$r" add -- HANDOFF.md || exit 2
  sed -i "s/^HANDOFF_PTR='.*'\$/HANDOFF_PTR='$ATAKA_088'/" "$r/$K7" || exit 2
  mapfile -t _p15 < <(sed -n "s/^HANDOFF_PTR='\(.*\)'\$/\1/p" "$r/$K7")
  [ "${#_p15[@]}" -eq 1 ] && [ "${_p15[0]}" = "$ATAKA_088" ] \
    || { printf 'NOT_IMPLEMENTED: рабочая k7 мира B15 не переписана на ATAKA_088\n' >&2; exit 2; }
  tolko_handoff "$r"
  ozhidaj_b B15 "$r" otkaz
fi

if nado B16; then
  mir B16
  handoff_v "$r/HANDOFF.md" net; gx "$r" add -- HANDOFF.md || exit 2
  rm -f -- "$r/$K7" && [ ! -e "$r/$K7" ] || exit 2
  tolko_handoff "$r"
  ozhidaj_b B16 "$r" otkaz
fi

if nado B17; then
  mir B17
  handoff_v "$r/HANDOFF.md" net; gx "$r" add -- HANDOFF.md || exit 2
  ozhidaj_b B17 "$r" otkaz OTKAZ_088="$ATAKA_088"
fi

if nado B18; then
  mir B18
  gx "$r" rm -q -- HANDOFF.md || exit 2
  ozhidaj_b B18 "$r" otkaz OTKAZ_088="$ATAKA_088"
fi

itog_semji red_ukazatel_088.sh
