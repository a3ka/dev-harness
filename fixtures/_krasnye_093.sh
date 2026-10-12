#!/usr/bin/env bash
# Раннер красной пачки 093 «граница исполнения и поставка ops» — агрегатор семьи
# fixtures/ops_granica/ (guard, ПРОВОДКА контракта 093).
#
# Использование:
#   bash fixtures/_krasnye_093.sh              # вся семья против $ROOT (умолчание — ..)
#   bash fixtures/_krasnye_093.sh <корень>
#
# Семантика (контракт 093 §Приёмочный критерий, §Клетки): rc 0 ⟺ стаб-пак
# fixtures/ops_granica/battery_stubs.sh rc 0 И каждая клетка семьи rc 0
# (замер контракта: клеток ровно 8); rc 1 — есть красная клетка; rc 2 — нечем
# проверять (нет семьи/клетки/стаб-пака/субъекта).
#
# И-8б (арбитраж 093, РЕШЕНИЕ п.1): семья — ПОТРЕБИТЕЛЬ И-3. Раннер НЕ
# создаёт namespace и НЕ переключает uid: граница устанавливается СНАРУЖИ
# доверенной установленной дверью И-3 (живая станция — п.9 контракта; CI —
# второй uid в задании, `sudo useradd` + `sudo -u <uid агента>`). Клетка 8
# половина-Б меряет УНАСЛЕДОВАННОЕ: запуск под uid владельца станции →
# именованный rc 1 «граница не установлена снаружи». Функциональная
# реализация клеток — implementer ВНУТРИ этого файла и клеток (прецедент
# 070/074: architect — до-заморозочный носитель, implementer — функциональная
# реализация в существующих файлах architect-зоны). До реализации клетки —
# носители «STUB … ждёт implementer»: честный итог — именованный отказ,
# не rc 127 и не зелёное.
#
# На ДОimplementer-дереве клетки 1-4,7 красны ожидаемо, 5/6 — rc 2
# NOT_IMPLEMENTED (подкоманд install нет), 8 красна половиной-Б при запуске
# под владельцем станции (именованный rc 1; под uid агента без наблюдателя
# половины-А — rc 2 NOT_IMPLEMENTED) — guard подключается в CI ТОЛЬКО
# ПОСЛЕ реализации (прецедент 074 §ПРОВОДКА-ЭНФОРСМЕНТ; 059/060/070/090).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${1:-$HERE/..}" 2>/dev/null && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
FAM="$ROOT/fixtures/ops_granica"
[ -d "$FAM" ] || { printf 'NOT_IMPLEMENTED: нет семьи %s\n' "$FAM" >&2; exit 2; }

# Замер контракта §Красные предъявления: клеток ровно 8 (обход печатает число
# просмотренного и отказывает на нуле/расхождении — пустая выборка красна).
n="$(ls "$FAM"/red_*.sh 2>/dev/null | wc -l)"
if [ "$n" -ne 8 ]; then
  printf 'ОТКАЗ: клеток семьи %s, ожидалось 8 по замеру контракта 093\n' "$n" >&2
  exit 2
fi

itog=0
progon() {  # <файл семьи>
  local f="$1" rc
  [ -f "$FAM/$f" ] || { printf 'NOT_IMPLEMENTED: нет %s\n' "$FAM/$f" >&2; itog=2; return; }
  OPS093_ROOT="$ROOT" bash "$FAM/$f"; rc=$?
  printf -- '— %s: rc=%s\n' "$f" "$rc"
  if [ "$rc" -eq 1 ]; then itog=1; elif [ "$rc" -ne 0 ] && [ "$itog" -eq 0 ]; then itog=2; fi
}

progon battery_stubs.sh
progon red_root_bootstrap_iz_repo.sh
progon red_limit_otkaz_bez_zapuska.sh
progon red_agent_uid_stancija_nedostupna.sh
progon red_kredit_publikacii_vne_sredy.sh
progon red_unit_realno_startuet.sh
progon red_otkat_vozvrashhaet_rabochuju.sh
progon red_net_osirotevshih_detej.sh
progon red_germetichnost_semi.sh

printf 'ИТОГ 093: rc=%s\n' "$itog"
exit "$itog"
