#!/usr/bin/env bash
# СТАБ 142: адресный предикат заменён БЕЛЫМ СПИСКОМ имён прежних позитивных
# клеток (k5–k9) вместо алфавита суффиксов — обманный субъект критика
# (вердикт contracts-142-v1, мутант mutate142.py): законные иные адресные имена
# (REPORTS_URL, CACHE_HOST, SITEURL…) ошибочно отказывают. Три строки канона
# сохранены байт в байт.
# Привязка к клеткам — source.json:.stab_vhod["stab_belyj-spisok-pyati-imen"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = '  adresnyj_suffiks() { for _s in $ADRES_SUFFIKSY; do [ "$1" != "${1%$_s}" ] && return 0; done; return 1; }'
b = '  adresnyj_suffiks() { case "$1" in METERING_PROXY_URL|METRICS_HOST|APP_PORT|SERVICE_NAME|API_ENDPOINT) return 0 ;; esac; return 1; }'
assert src.count(a) == 1, "точка правки модели не найдена: adresnyj_suffiks"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(a, b))
PY
