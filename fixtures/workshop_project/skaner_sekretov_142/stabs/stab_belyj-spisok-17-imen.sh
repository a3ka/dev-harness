#!/usr/bin/env bash
# СТАБ 142: адресный предикат заменён БЕЛЫМ СПИСКОМ из СЕМНАДЦАТИ фиксированных
# имён — обманный субъект критика 2/2 (вердикт contracts-142-v1-krug2-fail,
# мутант Critic142b/mutate142-expanded.py) дословно: пять имён боли + двенадцать
# адресных имён прежних клеток k19–k42. Клетки батареи с момента арбитража
# contracts-142-arbitraz порождают имена на каждом прогоне (X + 12 HEX +
# суффикс) — ни одно не входит в список, стаб краснеет ровно на k19–k30 по
# построению, а не по совпадению имён. Три строки канона сохранены байт в байт.
# Привязка к клеткам — source.json:.stab_vhod["stab_belyj-spisok-17-imen"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = '  adresnyj_suffiks() { for _s in $ADRES_SUFFIKSY; do [ "$1" != "${1%$_s}" ] && return 0; done; return 1; }'
b = '  adresnyj_suffiks() { case "$1" in METERING_PROXY_URL|METRICS_HOST|APP_PORT|SERVICE_NAME|API_ENDPOINT|REPORTS_URL|CACHE_HOST|GRPC_PORT|PROXY_ADDR|METRICS_ENDPOINT|TENANT_NAME|SITEURL|DBHOST|HTTPPORT|NODEADDR|APIENDPOINT|CLUSTERNAME) return 0 ;; esac; return 1; }'
assert src.count(a) == 1, "точка правки модели не найдена: adresnyj_suffiks"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(a, b))
PY
