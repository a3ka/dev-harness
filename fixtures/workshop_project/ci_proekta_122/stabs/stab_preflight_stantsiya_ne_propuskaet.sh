#!/usr/bin/env bash
# МУТАНТ (Н-39; дельта-205, слово владельца 2026-11-18 ~18:58 UTC, через консультанта 205):
# честная модель ci_preflight минус ОДНА строка с маркером МУТАЦИЯ-122:stantsiya-propusk —
# множество не-судимых классов пусто: у station-джоб текст run и значения env отказывают
# vyrazhenie-ne-podderzhano как у local (классификация буквальная остаётся, но пропуск
# run/env не действует — состояние кандидата до дельты, диагноз консультанта 205:
# otkaz_vyrazhenija вызывался ДО ветки класса).
# Наблюдаемое расхождение (ровно эти клетки): p11-run-station-propusk и
# p11-env-station-propusk — одинаковое неподдержанное выражение у станции обязано
# пропускаться (rc 0 STATION-JOB; парный свидетель local отказывает) — мутант даёт
# rc 1 vyrazhenie-ne-podderzhano. Клетки сохранности (p11 sekret/var/yaml/wd,
# p5-station) зелены — мутант не трогает сверку (а), YAML и разбор каталогов.
# Маркер не ровно один раз — rc 2 ORACLE_TAMPERED (мутант не применён).
set -u
M=$(cd "$(dirname "$0")/../model" && pwd)/ci_preflight.sh
MARK='МУТАЦИЯ-122:stantsiya-propusk'
n=$(grep -cF -- "$MARK" "$M")
[ "$n" = 1 ] || { printf 'ORACLE_TAMPERED: mutant ОТКАЗ: маркер %s в модели %s раз, нужен 1\n' "$MARK" "$n" >&2; exit 2; }
bash <(grep -vF -- "$MARK" "$M") "$@"
