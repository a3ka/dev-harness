#!/usr/bin/env bash
# W — срез-раннер батареи 109 v4 (контракт 109 §Приёмочный критерий):
# число миграций берётся из манифеста репозитория продукта, не из константы.
#
#   bash fixtures/workshop_project/stend_109/red_migracii_109.sh                 # SUBJECT_ABSENT rc 1
#   bash fixtures/workshop_project/stend_109/red_migracii_109.sh --repo <R>      # живой срез на R
#   bash fixtures/workshop_project/stend_109/red_migracii_109.sh --model         # миры базы $STEND109_BASE/--base
#   bash fixtures/workshop_project/stend_109/red_migracii_109.sh --stabs         # контроль + 4 обманных стаба
#
# python3-only (stdlib); docker НЕ вызывается (транспорт ledger — подложный
# docker замкнутого алфавита внутри srez-модуля; живой docker — lane stend109
# и станция стенда). Сеть не нужна.
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$HERE/srez_migracii_109.py" "$@"
