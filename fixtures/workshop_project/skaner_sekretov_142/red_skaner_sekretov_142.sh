#!/usr/bin/env bash
# Контракт 142 «skaner-sekretov» — красная батарея (зона architect).
# Субъект: ПОСТАВЛЯЕМЫЙ scripts/connect_project.sh (дверь подключения 125/136);
# предмет — ТОЛЬКО страж sekret-v-dereve: сканер судит значения СЕКРЕТНЫХ ключей
# дома секретов, а адреса и прочие параметры дома секретов (адресный суффикс
# имени И значение без учётных данных) не судятся (слово владельца
# 2026-10-26, docs/owner/2026-10-26-skaner-sekretov.md). Отказ имени/формата
# sekret-v-dereve, границы сканирования (ls-files --cached --others
# --exclude-standard), парсер KEY=VALUE, обе формы значения, CRLF, идиома
# последней строки — 125 дословно, не ослабляются.
#
# Режимы:
#   без ключей   — субъект = scripts/connect_project.sh КОРНЯ ДЕРЕВА батареи
#                  (до реализации красна: боль — rc 1 на клетке адреса);
#   --model      — честная модель model/connect_project.sh (все клетки зелёные);
#   --stabs      — сперва модель (обязана быть зелёной), затем обманные стабы
#                  stabs/: каждый обязан дать КРАСНОЕ ровно на клетках своей
#                  привязки source.json:.stab_vhod (Н-39: привязка по коду);
#   --repo <корень> — субъект = <корень>/scripts/connect_project.sh; нет файла —
#                  все клетки КРАСНО SUBJECT_ABSENT, rc 1.
# Печать: «КЛЕТКА <id> ЗЕЛЕНА» | «КЛЕТКА <id> КРАСНА: <почему>» |
# «ПОЙМАН/НЕ ПОЙМАН <стаб> @ <клетка>»; итог в stderr.
# rc: 0 — все клетки зелёные (субъект/модель) или все привязки пойманы (стабы);
#     1 — красная клетка / непойманная привязка / SUBJECT_ABSENT;
#     2 — мир сломан (модель не зелёная, рассинхрон осей/стабов/канона/пинов).
#
# Оракулы — в ПАМЯТИ до вызова субъекта (правило 8): значения секретов
# генерируются rnd() на клетку, ожидания заданы кодом клетки; дом секретов
# мира — единственный источник значений. Страж/конфиг/резолвер копируются в
# миры из дерева батареи (не предмет): path-guard.ts, config/agent_models.json,
# scripts/next_id.sh, scripts/profile_resolver.sh; двойник workshop пишет argv0
# и счёт вызовов; стаб omp v10 закрывает пин версии; без сети и gh.
set -uo pipefail
export PYTHONDONTWRITEBYTECODE=1
BATT=$(cd "$(dirname "$0")" && pwd -P)
LIVE=$(cd "$BATT/../../.." && pwd -P)
SRC_JSON="$BATT/source.json"
MODEL="$BATT/model/connect_project.sh"
WORLDS=/tmp/dev-harness-verify/s142
mkdir -p "$WORLDS"
RUNDIR=$(mktemp -d "$WORLDS/run-XXXX") || exit 2
trap 'rm -rf "$RUNDIR"' EXIT
export TMPDIR="$RUNDIR"

MODE=subjekt; REPO_ARG=""
while [ $# -gt 0 ]; do
  case "$1" in
    --model) MODE=model; shift ;;
    --stabs) MODE=stabs; shift ;;
    --repo)  [ $# -ge 2 ] || { printf 's142 ОТКАЗ: --repo <корень>\n' >&2; exit 2; }
             MODE=repo; REPO_ARG=$2; shift 2 ;;
    *)       printf 's142 ОТКАЗ: неизвестный ключ: %s\n' "$1" >&2; exit 2 ;;
  esac
done

die2() { printf 's142: %s\n' "$*" >&2; exit 2; }

# ── согласованность source.json: оси ↔ клетки ↔ стабы ↔ канон ↔ пин модели ──
jq -e '.osi | type == "array" and length == 62' "$SRC_JSON" >/dev/null 2>&1 || die2 "нет .osi длиной 62 в source.json"
mapfile -t OSIDS < <(jq -r '.osi[].id' "$SRC_JSON")
[ "$(printf '%s\n' "${OSIDS[@]}" | LC_ALL=C sort | uniq | wc -l)" = 62 ] || die2 "иды осей не уникальны"
mapfile -t STAB_KEYS < <(jq -r '.stab_vhod | keys[]' "$SRC_JSON" | LC_ALL=C sort)
mapfile -t STAB_FILES < <(cd "$BATT/stabs" && ls stab_*.sh 2>/dev/null | sed 's/\.sh$//' | LC_ALL=C sort)
[ "${STAB_KEYS[*]:-}" = "${STAB_FILES[*]:-}" ] \
  || die2 "стабы и привязки расходятся: файлы [${STAB_FILES[*]:-}] / ключи [${STAB_KEYS[*]:-}]"
while IFS=$'\t' read -r st cell; do
  printf '%s\n' "${OSIDS[@]}" | grep -qxF -- "$cell" \
    || die2 "привязка $st @ $cell — клетки нет в .osi"
done < <(jq -r '.stab_vhod | to_entries[] | .key as $k | .value[] | "\($k)\t\(.)"' "$SRC_JSON")
KANON_M=$(jq -r '.kanon.sekretnye_markery' "$SRC_JSON")
KANON_S=$(jq -r '.kanon.adres_suffiksy' "$SRC_JSON")
KANON_U=$(jq -r '.kanon.userinfo_re' "$SRC_JSON")
[ -n "$KANON_M" ] && [ -n "$KANON_S" ] && [ -n "$KANON_U" ] || die2 "канон source.json пуст"
MODEL_SHA=$(jq -r '.model_sha256' "$SRC_JSON")
[ "$(sha256sum "$MODEL" | cut -d' ' -f1)" = "$MODEL_SHA" ] \
  || die2 "ORACLE_TAMPERED: sha256 модели ≠ source.json:.model_sha256"
# канон в модели — побайтово (единый источник)
grep -qF -- "SEKRET_MARKERY=\"$KANON_M\"" "$MODEL" || die2 "канон секретных маркеров не в модели байт в байт"
grep -qF -- "ADRES_SUFFIKSY=\"$KANON_S\"" "$MODEL" || die2 "канон адресных суффиксов не в модели байт в байт"
grep -qF -- "USERINFO_RE='$KANON_U'" "$MODEL" || die2 "канон userinfo не в модели байт в байт"

# ── субъект ──────────────────────────────────────────────────────────────────
case "$MODE" in
  subjekt) SUBJECT="$LIVE/scripts/connect_project.sh" ;;
  model|stabs) SUBJECT="$MODEL" ;;
  repo)
    REPO_ARG=$(cd "$REPO_ARG" 2>/dev/null && pwd -P) || die2 "корень --repo не открывается"
    SUBJECT="$REPO_ARG/scripts/connect_project.sh" ;;
esac
SUBJECT_EST=1; [ -f "$SUBJECT" ] || SUBJECT_EST=0

REALGIT=$(command -v git) || die2 "нет git"
command -v node >/dev/null 2>&1 || die2 "нет node (финальный оракул пина двери)"
command -v jq >/dev/null 2>&1 || die2 "нет jq"

rnd() { printf '%s' "${RANDOM}${RANDOM}$$" | sha256sum | cut -c1-12; }

WP=""   # префикс мира (стабы не переиспользуют миры клеток)
mir() { # $1 = имя мира; установка = SUBJECT + двойник workshop + поддельный HOME
  local M="$RUNDIR/$WP$1"
  mkdir -p "$M/inst/scripts" "$M/inst/.omp/extensions" "$M/inst/config" \
           "$M/home/.config/dev-harness" "$M/bin" "$M/proj/config"
  cp "$SUBJECT" "$M/inst/scripts/connect_project.sh"
  cp "$LIVE/.omp/extensions/path-guard.ts" "$M/inst/.omp/extensions/path-guard.ts"
  cp "$LIVE/config/agent_models.json" "$M/inst/config/agent_models.json"
  cp "$LIVE/scripts/next_id.sh" "$LIVE/scripts/profile_resolver.sh" "$M/inst/scripts/"
  printf '#!/usr/bin/env bash\nprintf "%%s\\0" "$@" > %s/workshop.argv0\nprintf "launch\\n" >> %s/workshop.calls\n' "$M" "$M" > "$M/inst/workshop"
  printf '#!/bin/sh\nif [ "$1" = --version ]; then echo omp/v10; exit 0; fi\nexit 0\n' > "$M/bin/omp"
  chmod +x "$M/inst/workshop" "$M/bin/omp"
  "$REALGIT" -C "$M/proj" init -q
  printf '# projekt 142\n' > "$M/proj/README.md"
  printf '{"version":"v10"}\n' > "$M/proj/config/harness_pin.json"
  "$REALGIT" -C "$M/proj" add -A
  "$REALGIT" -C "$M/proj" -c user.name=t -c user.email=t@t.invalid commit -q -m init
}
run_dver() { # $1 = мир; кладёт RC, $RUNDIR/$WP$1/{out,err}
  local M="$RUNDIR/$WP$1"; RC=0
  ( cd "$M" && env -u HARNESS_PROJECT_LAYER_ROOT HOME="$M/home" PATH="$M/bin:$PATH" \
      bash "$M/inst/scripts/connect_project.sh" "$M/proj" > "$M/out" 2> "$M/err" ) || RC=$?
}
calls() { if [ -f "$RUNDIR/$WP$1/workshop.calls" ]; then grep -cx launch "$RUNDIR/$WP$1/workshop.calls"; else echo 0; fi; }
err1() { sed -n 1p "$RUNDIR/$WP$1/err" 2>/dev/null; }

# ── клетки: ось K (имя ключа) × ось Z (значение) × ось F (файл) × ось D (дом) × R ──
# Внутри клетки: T1/T2 — свежие rnd-значения (оракул в памяти); dom — bytes дома
# секретов мира; файлы создаются ДО вызова субъекта. vid: otkaz|sessija|f7|kanon.
kletka() { # $1 = id клетки; печатает строку вердикта
  local id=$1 why="" T1 T2
  T1="tok-$(rnd)"; T2="tok-$(rnd)"
  local VID=""
  if [ "$SUBJECT_EST" = 0 ]; then
    printf 'КЛЕТКА %s КРАСНА: SUBJECT_ABSENT: %s\n' "$id" "$SUBJECT"; return
  fi
  case "$id" in
    # ── ось K: имя ключа ──
    k1-api-key)
      mir k1; printf 'ZAI_API_KEY=%s\n' "$T1" > "$RUNDIR/$WP"k1/home/.config/dev-harness/secrets.env
      printf 'ключ в файле: %s\n' "$T1" > "$RUNDIR/$WP"k1/proj/notes.txt; VID=otkaz ;;
    k2-token)
      mir k2; printf 'METERING_PROXY_TOKEN=%s\n' "$T1" > "$RUNDIR/$WP"k2/home/.config/dev-harness/secrets.env
      printf 'токен в конфиге: %s\n' "$T1" > "$RUNDIR/$WP"k2/proj/token.txt; VID=otkaz ;;
    k3-secret)
      mir k3; printf 'SHARED_SECRET=%s\n' "$T1" > "$RUNDIR/$WP"k3/home/.config/dev-harness/secrets.env
      printf 'общий секрет: %s\n' "$T1" > "$RUNDIR/$WP"k3/proj/secret.txt; VID=otkaz ;;
    k4-password)
      mir k4; printf 'DB_PASSWORD=%s\n' "$T1" > "$RUNDIR/$WP"k4/home/.config/dev-harness/secrets.env
      printf 'пароль базы: %s\n' "$T1" > "$RUNDIR/$WP"k4/proj/pass.txt; VID=otkaz ;;
    k5-url-adres)
      mir k5; printf 'METERING_PROXY_URL=http://127.0.0.1:8787\n' > "$RUNDIR/$WP"k5/home/.config/dev-harness/secrets.env
      mkdir -p "$RUNDIR/$WP"k5/proj/.harness/verdicts/critic
      printf '## вердикт\n\nпрогон: curl http://127.0.0.1:8787/zamer\n' > "$RUNDIR/$WP"k5/proj/.harness/verdicts/critic/contracts-006-krug1-fail.md; VID=sessija ;;
    k6-host)
      mir k6; printf 'METRICS_HOST=127.0.0.1\n' > "$RUNDIR/$WP"k6/home/.config/dev-harness/secrets.env
      printf 'хост метрик — 127.0.0.1 (loopback)\n' > "$RUNDIR/$WP"k6/proj/infra.md; VID=sessija ;;
    k7-port)
      mir k7; printf 'APP_PORT=8787\n' > "$RUNDIR/$WP"k7/home/.config/dev-harness/secrets.env
      printf 'порт приложения 8787\n' > "$RUNDIR/$WP"k7/proj/ports.txt; VID=sessija ;;
    k8-name)
      mir k8; printf 'SERVICE_NAME=worker-1\n' > "$RUNDIR/$WP"k8/home/.config/dev-harness/secrets.env
      printf 'сервис worker-1 отвечает за очередь\n' > "$RUNDIR/$WP"k8/proj/arch.md; VID=sessija ;;
    k9-endpoint)
      mir k9; printf 'API_ENDPOINT=http://api.internal:9000\n' > "$RUNDIR/$WP"k9/home/.config/dev-harness/secrets.env
      printf 'эндпоинт: http://api.internal:9000/v1\n' > "$RUNDIR/$WP"k9/proj/api.md; VID=sessija ;;
    k10-database-url-creds)
      mir k10; printf 'DATABASE_URL=postgres://back:s3cr3t-pw@127.0.0.1:5432/app\n' > "$RUNDIR/$WP"k10/home/.config/dev-harness/secrets.env
      printf 'dsn: postgres://back:s3cr3t-pw@127.0.0.1:5432/app\n' > "$RUNDIR/$WP"k10/proj/db.txt; VID=otkaz ;;
    k11-private-key)
      mir k11; printf 'PRIVATE_KEY=-----BEGIN RSA PRIVATE KEY-----%s\n' "$T1" > "$RUNDIR/$WP"k11/home/.config/dev-harness/secrets.env
      printf -- '-----BEGIN RSA PRIVATE KEY-----%s\n' "$T1" > "$RUNDIR/$WP"k11/proj/key.txt; VID=otkaz ;;
    k12-stripe-key)
      mir k12; printf 'STRIPE_KEY=sk_live_%s\n' "$T1" > "$RUNDIR/$WP"k12/home/.config/dev-harness/secrets.env
      printf 'платёжный ключ: sk_live_%s\n' "$T1" > "$RUNDIR/$WP"k12/proj/billing.txt; VID=otkaz ;;
    k13-passphrase)
      mir k13; printf 'KEY_PASSPHRASE=pp-%s\n' "$T1" > "$RUNDIR/$WP"k13/home/.config/dev-harness/secrets.env
      printf 'фраза-пароль: pp-%s\n' "$T1" > "$RUNDIR/$WP"k13/proj/crypto.txt; VID=otkaz ;;
    k14-auth)
      mir k14; printf 'AUTH_HEADER=Bearer auth-%s\n' "$T1" > "$RUNDIR/$WP"k14/home/.config/dev-harness/secrets.env
      printf 'заголовок: Bearer auth-%s\n' "$T1" > "$RUNDIR/$WP"k14/proj/auth.txt; VID=otkaz ;;
    k15-cookie)
      mir k15; printf 'SESSION_COOKIE=sess-%s\n' "$T1" > "$RUNDIR/$WP"k15/home/.config/dev-harness/secrets.env
      printf 'печенька: sess-%s\n' "$T1" > "$RUNDIR/$WP"k15/proj/cookies.txt; VID=otkaz ;;
    k16-register-sekret)
      mir k16; printf 'zai_api_key=%s\n' "$T1" > "$RUNDIR/$WP"k16/home/.config/dev-harness/secrets.env
      printf 'ключ нижним регистром: %s\n' "$T1" > "$RUNDIR/$WP"k16/proj/lower.txt; VID=otkaz ;;
    k17-marker-chem-suffiks)
      mir k17; printf 'API_KEY_URL=sk-url-%s\n' "$T1" > "$RUNDIR/$WP"k17/home/.config/dev-harness/secrets.env
      printf 'ключ под адресным суффиксом: sk-url-%s\n' "$T1" > "$RUNDIR/$WP"k17/proj/apikeyurl.txt; VID=otkaz ;;
    k18-register-adres)
      mir k18; printf 'metering_proxy_url=http://127.0.0.1:8787\n' > "$RUNDIR/$WP"k18/home/.config/dev-harness/secrets.env
      mkdir -p "$RUNDIR/$WP"k18/proj/.harness/verdicts/critic
      printf 'прогон: curl http://127.0.0.1:8787/zamer\n' > "$RUNDIR/$WP"k18/proj/.harness/verdicts/critic/kontrol.md; VID=sessija ;;
    # ── ось K, закрытие И-3 (вердикт contracts-142-v1): адресный предикат —
    # АЛФАВИТ суффиксов, не белый список имён. По положительной клетке на
    # КАЖДЫЙ суффикс замкнутого алфавита канона (_URL _HOST _PORT _ADDR
    # _ENDPOINT _NAME и базовые URL HOST PORT ADDR ENDPOINT NAME), имя ранее
    # не использовано и без секретных маркеров по подчёркиванию; парная клетка
    # (k31–k42) — то же имя + userinfo в значении → отказ (учётка сильнее
    # суффикса). Стаб whitelist пяти имён прежних позитивных клеток краснеет
    # ровно на k19–k30.
    k19-reporty-url)
      mir k19; printf 'REPORTS_URL=http://127.0.0.1:8787\n' > "$RUNDIR/$WP"k19/home/.config/dev-harness/secrets.env
      printf 'отчёты: curl http://127.0.0.1:8787/report\n' > "$RUNDIR/$WP"k19/proj/reports.md; VID=sessija ;;
    k20-kesh-host)
      mir k20; printf 'CACHE_HOST=cache.internal\n' > "$RUNDIR/$WP"k20/home/.config/dev-harness/secrets.env
      printf 'кэш развёрнут на cache.internal\n' > "$RUNDIR/$WP"k20/proj/infra.md; VID=sessija ;;
    k21-grpc-port)
      mir k21; printf 'GRPC_PORT=9090\n' > "$RUNDIR/$WP"k21/home/.config/dev-harness/secrets.env
      printf 'grpc слушает 9090\n' > "$RUNDIR/$WP"k21/proj/ports.txt; VID=sessija ;;
    k22-proksi-addr)
      mir k22; printf 'PROXY_ADDR=10.0.0.9\n' > "$RUNDIR/$WP"k22/home/.config/dev-harness/secrets.env
      printf 'прокси узла 10.0.0.9\n' > "$RUNDIR/$WP"k22/proj/net.md; VID=sessija ;;
    k23-metrik-endpoint)
      mir k23; printf 'METRICS_ENDPOINT=http://metrics.internal:9100\n' > "$RUNDIR/$WP"k23/home/.config/dev-harness/secrets.env
      printf 'метрики: http://metrics.internal:9100/metrics\n' > "$RUNDIR/$WP"k23/proj/metrics.md; VID=sessija ;;
    k24-tenant-name)
      mir k24; printf 'TENANT_NAME=tenant-alpha\n' > "$RUNDIR/$WP"k24/home/.config/dev-harness/secrets.env
      printf 'тенант tenant-alpha отвечает за отчёты\n' > "$RUNDIR/$WP"k24/proj/arch.md; VID=sessija ;;
    k25-siteurl)
      mir k25; printf 'SITEURL=http://127.0.0.1:8787\n' > "$RUNDIR/$WP"k25/home/.config/dev-harness/secrets.env
      printf 'сайт: http://127.0.0.1:8787/home\n' > "$RUNDIR/$WP"k25/proj/site.md; VID=sessija ;;
    k26-dbhost)
      mir k26; printf 'DBHOST=db.internal\n' > "$RUNDIR/$WP"k26/home/.config/dev-harness/secrets.env
      printf 'база данных на db.internal\n' > "$RUNDIR/$WP"k26/proj/db.md; VID=sessija ;;
    k27-httpport)
      mir k27; printf 'HTTPPORT=8080\n' > "$RUNDIR/$WP"k27/home/.config/dev-harness/secrets.env
      printf 'http порт 8080\n' > "$RUNDIR/$WP"k27/proj/ports.txt; VID=sessija ;;
    k28-nodeaddr)
      mir k28; printf 'NODEADDR=10.0.0.5\n' > "$RUNDIR/$WP"k28/home/.config/dev-harness/secrets.env
      printf 'узел данных 10.0.0.5\n' > "$RUNDIR/$WP"k28/proj/net.md; VID=sessija ;;
    k29-apiendpoint)
      mir k29; printf 'APIENDPOINT=http://api.internal:9000\n' > "$RUNDIR/$WP"k29/home/.config/dev-harness/secrets.env
      printf 'api: http://api.internal:9000/v1\n' > "$RUNDIR/$WP"k29/proj/api.md; VID=sessija ;;
    k30-clustername)
      mir k30; printf 'CLUSTERNAME=cluster-prod\n' > "$RUNDIR/$WP"k30/home/.config/dev-harness/secrets.env
      printf 'кластер cluster-prod обслуживает прод\n' > "$RUNDIR/$WP"k30/proj/arch.md; VID=sessija ;;
    k31-reporty-url-userinfo)
      mir k31; printf 'REPORTS_URL=http://rep:rep-pw@127.0.0.1:8787\n' > "$RUNDIR/$WP"k31/home/.config/dev-harness/secrets.env
      printf 'отчёты с учёткой: http://rep:rep-pw@127.0.0.1:8787/report\n' > "$RUNDIR/$WP"k31/proj/reports.md; VID=otkaz ;;
    k32-kesh-host-userinfo)
      mir k32; printf 'CACHE_HOST=back:cache-pw@cache.internal\n' > "$RUNDIR/$WP"k32/home/.config/dev-harness/secrets.env
      printf 'dsn кэша: back:cache-pw@cache.internal\n' > "$RUNDIR/$WP"k32/proj/infra.md; VID=otkaz ;;
    k33-grpc-port-userinfo)
      mir k33; printf 'GRPC_PORT=grpc:grpc-pw@grpc.internal:9090\n' > "$RUNDIR/$WP"k33/home/.config/dev-harness/secrets.env
      printf 'grpc dsn: grpc:grpc-pw@grpc.internal:9090\n' > "$RUNDIR/$WP"k33/proj/ports.txt; VID=otkaz ;;
    k34-proksi-addr-userinfo)
      mir k34; printf 'PROXY_ADDR=proxy:proxy-pw@10.0.0.9\n' > "$RUNDIR/$WP"k34/home/.config/dev-harness/secrets.env
      printf 'прокси dsn: proxy:proxy-pw@10.0.0.9\n' > "$RUNDIR/$WP"k34/proj/net.md; VID=otkaz ;;
    k35-metrik-endpoint-userinfo)
      mir k35; printf 'METRICS_ENDPOINT=http://metrics:met-pw@metrics.internal:9100\n' > "$RUNDIR/$WP"k35/home/.config/dev-harness/secrets.env
      printf 'метрики dsn: http://metrics:met-pw@metrics.internal:9100\n' > "$RUNDIR/$WP"k35/proj/metrics.md; VID=otkaz ;;
    k36-tenant-name-userinfo)
      mir k36; printf 'TENANT_NAME=tenant:tenant-pw@tenant-alpha.internal\n' > "$RUNDIR/$WP"k36/home/.config/dev-harness/secrets.env
      printf 'тенант dsn: tenant:tenant-pw@tenant-alpha.internal\n' > "$RUNDIR/$WP"k36/proj/arch.md; VID=otkaz ;;
    k37-siteurl-userinfo)
      mir k37; printf 'SITEURL=http://site:site-pw@127.0.0.1:8787\n' > "$RUNDIR/$WP"k37/home/.config/dev-harness/secrets.env
      printf 'сайт dsn: http://site:site-pw@127.0.0.1:8787\n' > "$RUNDIR/$WP"k37/proj/site.md; VID=otkaz ;;
    k38-dbhost-userinfo)
      mir k38; printf 'DBHOST=back:db-pw@db.internal\n' > "$RUNDIR/$WP"k38/home/.config/dev-harness/secrets.env
      printf 'база dsn: back:db-pw@db.internal\n' > "$RUNDIR/$WP"k38/proj/db.md; VID=otkaz ;;
    k39-httpport-userinfo)
      mir k39; printf 'HTTPPORT=http:hp-pw@port.internal:8080\n' > "$RUNDIR/$WP"k39/home/.config/dev-harness/secrets.env
      printf 'порт dsn: http:hp-pw@port.internal:8080\n' > "$RUNDIR/$WP"k39/proj/ports.txt; VID=otkaz ;;
    k40-nodeaddr-userinfo)
      mir k40; printf 'NODEADDR=node:node-pw@10.0.0.5\n' > "$RUNDIR/$WP"k40/home/.config/dev-harness/secrets.env
      printf 'узел dsn: node:node-pw@10.0.0.5\n' > "$RUNDIR/$WP"k40/proj/net.md; VID=otkaz ;;
    k41-apiendpoint-userinfo)
      mir k41; printf 'APIENDPOINT=http://api:api-pw@api.internal:9000\n' > "$RUNDIR/$WP"k41/home/.config/dev-harness/secrets.env
      printf 'api dsn: http://api:api-pw@api.internal:9000\n' > "$RUNDIR/$WP"k41/proj/api.md; VID=otkaz ;;
    k42-clustername-userinfo)
      mir k42; printf 'CLUSTERNAME=cluster:cl-pw@cluster-prod.internal\n' > "$RUNDIR/$WP"k42/home/.config/dev-harness/secrets.env
      printf 'кластер dsn: cluster:cl-pw@cluster-prod.internal\n' > "$RUNDIR/$WP"k42/proj/arch.md; VID=otkaz ;;
    # ── ось Z: значение ──
    z1-korotkoe)
      mir z1; printf 'ZAI_API_KEY=ab\n' > "$RUNDIR/$WP"z1/home/.config/dev-harness/secrets.env
      printf 'словарь: table of contents\n' > "$RUNDIR/$WP"z1/proj/prose.md; VID=otkaz ;;
    z2-kavychki)
      mir z2; printf 'ZAI_API_KEY="%s"\n' "$T1" > "$RUNDIR/$WP"z2/home/.config/dev-harness/secrets.env
      printf 'значение %s без кавычек\n' "$T1" > "$RUNDIR/$WP"z2/proj/env2.txt; VID=otkaz ;;
    z3-crlf)
      mir z3; printf 'ZAI_API_KEY=%s\r\nMETERING_PROXY_URL=http://127.0.0.1:1\r\n' "$T1" > "$RUNDIR/$WP"z3/home/.config/dev-harness/secrets.env
      printf 'чистое значение %s в файле\n' "$T1" > "$RUNDIR/$WP"z3/proj/clean.txt; VID=otkaz ;;
    z4-pustoe)
      mir z4; printf 'ZAI_API_KEY=\n' > "$RUNDIR/$WP"z4/home/.config/dev-harness/secrets.env; VID=sessija ;;
    z5-podstroka)
      mir z5; printf 'ZAI_API_KEY=tok-%s-long\nOLD_API_KEY=tok-%s\n' "$T1" "$T1" > "$RUNDIR/$WP"z5/home/.config/dev-harness/secrets.env
      printf 'короткое значение: tok-%s\n' "$T1" > "$RUNDIR/$WP"z5/proj/short.txt; VID=otkaz ;;
    z6-dsn-bez-skhemy)
      mir z6; printf 'CACHE_URL=back:cache-pw@cache.internal:6380\n' > "$RUNDIR/$WP"z6/home/.config/dev-harness/secrets.env
      printf 'dsn: back:cache-pw@cache.internal:6380\n' > "$RUNDIR/$WP"z6/proj/cache.txt; VID=otkaz ;;
    z7-pustoj-user)
      mir z7; printf 'REDIS_URL=redis://:pwd@127.0.0.1:6379\n' > "$RUNDIR/$WP"z7/home/.config/dev-harness/secrets.env
      printf 'redis://:pwd@127.0.0.1:6379\n' > "$RUNDIR/$WP"z7/proj/redis.txt; VID=otkaz ;;
    # ── ось F: файл-носитель (ключ ZAI_API_KEY судим) ──
    f1-verdict-md)
      mir f1; printf 'ZAI_API_KEY=%s\n' "$T1" > "$RUNDIR/$WP"f1/home/.config/dev-harness/secrets.env
      mkdir -p "$RUNDIR/$WP"f1/proj/.harness/verdicts/critic
      printf 'свидетельство: %s\n' "$T1" > "$RUNDIR/$WP"f1/proj/.harness/verdicts/critic/kritika.md; VID=otkaz ;;
    f2-env-podobnyj)
      mir f2; printf 'ZAI_API_KEY=%s\n' "$T1" > "$RUNDIR/$WP"f2/home/.config/dev-harness/secrets.env
      printf 'ZAI_API_KEY=%s\n' "$T1" > "$RUNDIR/$WP"f2/proj/config.env; VID=otkaz ;;
    f3-binarnyj)
      mir f3; printf 'ZAI_API_KEY=%s\n' "$T1" > "$RUNDIR/$WP"f3/home/.config/dev-harness/secrets.env
      printf 'BIN\000%s\000\n' "$T1" > "$RUNDIR/$WP"f3/proj/blob.bin; VID=otkaz ;;
    f4-ne-utf8)
      mir f4; printf 'ZAI_API_KEY=%s\n' "$T1" > "$RUNDIR/$WP"f4/home/.config/dev-harness/secrets.env
      printf '\377\376 значение %s\n' "$T1" > "$RUNDIR/$WP"f4/proj/latin1.txt; VID=otkaz ;;
    f5-imya-s-probelom)
      mir f5; printf 'ZAI_API_KEY=%s\n' "$T1" > "$RUNDIR/$WP"f5/home/.config/dev-harness/secrets.env
      printf 'заметка: %s\n' "$T1" > "$RUNDIR/$WP"f5/proj/my notes.txt; VID=otkaz ;;
    f6-ignoriruemyj)
      mir f6; printf 'ZAI_API_KEY=%s\n' "$T1" > "$RUNDIR/$WP"f6/home/.config/dev-harness/secrets.env
      printf 'tmp.log\n' > "$RUNDIR/$WP"f6/proj/.gitignore
      printf 'секрет в игнорируемом: %s\n' "$T1" > "$RUNDIR/$WP"f6/proj/tmp.log; VID=sessija ;;
    f7-otkaz-bez-utchika)
      mir f7; printf 'ZAI_API_KEY=%s\n' "$T1" > "$RUNDIR/$WP"f7/home/.config/dev-harness/secrets.env
      printf 'секрет: %s\n' "$T1" > "$RUNDIR/$WP"f7/proj/sekretnyj-fajl.txt; VID=f7 ;;
    # ── ось D: сам дом секретов ──
    d1-bez-hvostogo-lf)
      mir d1; printf 'METERING_PROXY_TOKEN=%s' "$T1" > "$RUNDIR/$WP"d1/home/.config/dev-harness/secrets.env
      printf 'последнее значение: %s\n' "$T1" > "$RUNDIR/$WP"d1/proj/posl.txt; VID=otkaz ;;
    d2-kommentarii)
      mir d2; printf '# ZAI_API_KEY=%s\nMETERING_PROXY_URL=http://127.0.0.1:1\n' "$T1" > "$RUNDIR/$WP"d2/home/.config/dev-harness/secrets.env
      printf 'в комментарии было %s\n' "$T1" > "$RUNDIR/$WP"d2/proj/komment.txt; VID=sessija ;;
    d3-klyuch-s-probelom)
      mir d3; printf 'ZAI_API_KEY =%s\n' "$T1" > "$RUNDIR/$WP"d3/home/.config/dev-harness/secrets.env
      printf 'значение ключа с пробелом: %s\n' "$T1" > "$RUNDIR/$WP"d3/proj/probel.txt; VID=otkaz ;;
    d4-dubl-klyucha)
      mir d4; printf 'ZAI_API_KEY=%s\nZAI_API_KEY=%s\n' "$T1" "$T2" > "$RUNDIR/$WP"d4/home/.config/dev-harness/secrets.env
      printf 'второе значение ключа: %s\n' "$T2" > "$RUNDIR/$WP"d4/proj/dubli.txt; VID=otkaz ;;
    d5-klyuch-bez-ravno)
      mir d5; printf 'ZAI_API_KEY\n' > "$RUNDIR/$WP"d5/home/.config/dev-harness/secrets.env; VID=sessija ;;
    # ── ось R: реализация ──
    r1-kanon-v-subekte) VID=kanon ;;
    *) printf 'КЛЕТКА %s КРАСНА: клетка не описана в раннере\n' "$id"; return 1 ;;
  esac
  local M
  case "$VID" in
    otkaz)
      M="$RUNDIR/$WP${id%%-*}"
      run_dver "${id%%-*}"
      if [ "$RC" = 1 ] && grep -qF 'sekret-v-dereve' "$M/err" && [ "$(calls "${id%%-*}")" = 0 ]; then
        printf 'КЛЕТКА %s ЗЕЛЕНА\n' "$id"
      else
        printf 'КЛЕТКА %s КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии; rc=%s calls=%s (%s)\n' "$id" "$RC" "$(calls "${id%%-*}")" "$(err1 "${id%%-*}")"
      fi ;;
    sessija)
      M="$RUNDIR/$WP${id%%-*}"
      run_dver "${id%%-*}"
      if [ "$RC" = 0 ] && [ "$(calls "${id%%-*}")" = 1 ]; then
        printf 'КЛЕТКА %s ЗЕЛЕНА\n' "$id"
      else
        printf 'КЛЕТКА %s КРАСНА: ждали сессию rc 0 (адрес/параметр не судится); rc=%s calls=%s (%s)\n' "$id" "$RC" "$(calls "${id%%-*}")" "$(err1 "${id%%-*}")"
      fi ;;
    f7)
      M="$RUNDIR/$WP${id%%-*}"
      run_dver "${id%%-*}"
      why=""
      [ "$RC" = 1 ] || why="$why rc=$RC;"
      grep -qF 'sekret-v-dereve' "$M/err" || why="$why нет имени sekret-v-dereve;"
      grep -qF 'sekretnyj-fajl.txt' "$M/err" || why="$why отказ не называет файл;"
      grep -qF -- "$T1" "$M/err" && why="$why отказ печатает значение секрета;"
      if [ -z "$why" ]; then printf 'КЛЕТКА %s ЗЕЛЕНА\n' "$id"
      else printf 'КЛЕТКА %s КРАСНА: отказ не по форме 125%s\n' "$id" "$why"; fi ;;
    kanon)
      why=""
      grep -qF -- "SEKRET_MARKERY=\"$KANON_M\"" "$SUBJECT" || why="$why нет канона секретных маркеров;"
      grep -qF -- "ADRES_SUFFIKSY=\"$KANON_S\"" "$SUBJECT" || why="$why нет канона адресных суффиксов;"
      grep -qF -- "USERINFO_RE='$KANON_U'" "$SUBJECT" || why="$why нет канона userinfo;"
      if [ -z "$why" ]; then printf 'КЛЕТКА %s ЗЕЛЕНА\n' "$id"
      else printf 'КЛЕТКА %s КРАСНА: канон предиката не в субъекте байт в байт:%s\n' "$id" "$why"; fi ;;
  esac
}

schet() { # $1 = файл клеток; $2 = метка режима
  local G R
  G=$(grep -c '^КЛЕТКА .* ЗЕЛЕНА$' "$1"); R=$(grep -c '^КЛЕТКА .* КРАСНА' "$1")
  printf 's142 %s: клеток %s, зелёных %s, красных %s\n' "$2" "$((G+R))" "$G" "$R" >&2
  [ "$((G+R))" = 62 ] || { printf 's142: клеток %s ≠ 62 — мир сломан\n' "$((G+R))" >&2; return 2; }
  [ "$R" = 0 ] || return 1
}

case "$MODE" in
  subjekt|model|repo)
    : > "$RUNDIR/cells"
    for id in "${OSIDS[@]}"; do kletka "$id" >> "$RUNDIR/cells" || true; done
    cat "$RUNDIR/cells"
    schet "$RUNDIR/cells" "$MODE"
    rc=$?
    if [ "$rc" = 1 ] && [ "$MODE" = "subjekt" ]; then
      printf 'БОЛЬ-SEJCHAS: красные клетки перечислены выше (до реализации это ожидаемо)\n' >&2
    fi
    exit "$rc" ;;
  stabs)
    WP="m."
    : > "$RUNDIR/model.cells"
    for id in "${OSIDS[@]}"; do kletka "$id" >> "$RUNDIR/model.cells" || true; done
    schet "$RUNDIR/model.cells" "model-opora-stabov" || {
      grep '^КЛЕТКА .* КРАСНА' "$RUNDIR/model.cells"
      die2 "модель не зелёная — поимка стабов не доказательна"; }
    N=0; MISS=0; NB=0
    for nm in "${STAB_FILES[@]}"; do
      N=$((N+1)); st="$BATT/stabs/$nm.sh"; subj="$RUNDIR/$nm.subj.sh"
      bash "$st" "$BATT/model" "$subj" || die2 "стаб $nm не собран"
      chmod +x "$subj"
      SUBJECT="$subj"; WP="$nm."
      : > "$RUNDIR/$nm.cells"
      mapfile -t cells < <(jq -r --arg s "$nm" '.stab_vhod[$s][]' "$SRC_JSON")
      [ "${#cells[@]}" -gt 0 ] || die2 "у стаба $nm пустая привязка"
      for c in "${cells[@]}"; do
        NB=$((NB+1))
        grep -q "^КЛЕТКА $c ЗЕЛЕНА\$" "$RUNDIR/model.cells" \
          || die2 "привязка $nm @ $c — клетки нет среди зелёных модели"
        kletka "$c" >> "$RUNDIR/$nm.cells" || true
        if grep -q "^КЛЕТКА $c КРАСНА" "$RUNDIR/$nm.cells"; then
          printf 'ПОЙМАН %s @ %s\n' "$nm" "$c"
        else
          printf 'НЕ ПОЙМАН %s @ %s\n' "$nm" "$c"; MISS=$((MISS+1))
        fi
      done
    done
    printf 's142 stabs: стабов %s, привязок %s, непойманных %s\n' "$N" "$NB" "$MISS" >&2
    [ "$N" -gt 0 ] || die2 "ноль стабов"
    [ "$MISS" = 0 ] || exit 1
    exit 0 ;;
esac
