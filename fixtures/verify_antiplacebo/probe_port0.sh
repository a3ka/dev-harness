#!/usr/bin/env bash
# НЕ ФИКСТУРА (нет case_-префикса, раннером не гоняется): пробный слой режима
# --port0 — зелёные пробы среза-2 контракта 007 (p0.gen/p0.up/p0.conc/p0.src)
# и красные пробы среза 4 контракта 017 (p0.stub/p0.i/p0.noreport).
#
# Перенесён ЦЕЛИКОМ из scripts/check_metering.sh в пачке 017 v2 — машинная
# граница зон (блокер 4 вердикта v1: общий файл реализации и приёмки давал
# implementer право ослабить красные пробы в своей зоне). Этот путь — зона
# architect, implementer НЕ выдан: правка проб после заморозки — выход за зону,
# страж режет на коммите. Приёмочная сила И-1/И-2 контракта 017 — у ПРЯМОГО
# пути этой пробы; диспетчер `bash scripts/check_metering.sh --port0` сохраняет
# поверхность контракта 007 и ведёт сюда же.
#
# Пламбинг (stub_upstream, gen_config, proxy_up, proxy_down, req, PROXY,
# PROXY_NODE_FLAGS, TMP_ROOT) подтягивается источником scripts/check_metering.sh
# в БИБЛИОТЕЧНОМ режиме (PROBE017_LIB=1 — исполняющая часть не запускается).
# Вердикты — СВОИ ok/bad/die, объявленные ПОСЛЕ источника: правка sourced-версий
# через check_metering.sh (зона implementer) на приговор пробы не действует.
#
# Предмет срезов: upstream-стаб и ветвь (и) уходят со скан-портов (free_port +
# ss-поллинг, TOCTOU) на OS-назначаемый listen(0) + файл-событие от
# listen-callback; окна готовности умирают как класс (готовность = событие +
# живость процесса), отказ становится различим («медленный» ≠ «мёртвый» ≠
# «не репортит»). Привязка проб ко входам — по коду НИЖЕ (Н-39), не по прозе
# контракта.
#
#   bash fixtures/verify_antiplacebo/probe_port0.sh     приёмка 017 (И-1/И-2)
# Коды возврата: 0 — все пробы зелёные, 1 — расхождение, 2 — нечем проверить.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"

export PROBE017_LIB=1
# shellcheck disable=SC1091
. "$REPO/scripts/check_metering.sh"
unset PROBE017_LIB

# Свои вердикты (шапка): перекрывают sourced-версии.
fails=0
ok()  { printf '  ok   %s\n' "$*" >&2; }
bad() { fails=$((fails + 1)); printf '  FAIL %s\n' "$*" >&2; }
die() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }

mode_port0() {
  local work t
  work="$(mktemp -d "$TMP_ROOT/metering-port0.XXXXXX")"
  export HOME="$work"
  trap "pkill -f 'metering_proxy.ts --config $work' 2>/dev/null || true; rm -rf '$work'" EXIT

  # ── p0.gen: gen_config эмитит port:0 (OS-эфемерный), не free_port-скан ──
  local gcfg gport
  gcfg="$(gen_config "$work/gen")"
  gport="$(jq -r '.port' "$gcfg")"
  if [ "$gport" = 0 ]; then
    ok "port0.gen: gen_config эмитит port:0 (bind :0, без free_port-скана)"
  else
    bad "port0.gen: gen_config эмитит \"port\":$gport (free_port-скан) — нормальный путь check_metering не мигрирован на bind:0; корень Н-45 остаётся"
  fi

  # ── p0.up: ШТАТНЫЙ proxy_up на port:0 → эфемерный порт, cfg.port переписан, healthz 200 ──
  local ucfg updir upid up_rc uport
  ucfg="$(gen_config "$work/up")"
  updir="$(jq -r '.data_dir' "$ucfg")"
  t="$(mktemp -p "$TMP_ROOT")"; jq '.port = 0' "$ucfg" > "$t" && mv "$t" "$ucfg"
  upid="$( proxy_up "$ucfg" "$updir/proxy.pid" 2>"$work/up.err" )"; up_rc=$?
  if [ "$up_rc" != 0 ] || [ -z "$upid" ]; then
    bad "port0.up: штатный proxy_up не поднял прокси при port:0 (rc=$up_rc) — читает cfg.port=0 вместо репортного. err: $(tr '\n' ' ' < "$work/up.err" 2>/dev/null | tail -c 200)"
  else
    uport="$(jq -r '.port' "$ucfg")"
    if [ -z "$uport" ] || [ "$uport" = 0 ]; then
      bad "port0.up: proxy_up не переписал cfg.port на фактический эфемерный (осталось '$uport') — ветви check_metering читали бы порт 0"
    elif [ "$(curl -s -o /dev/null -w '%{http_code}' -m 5 "http://127.0.0.1:${uport}/healthz" 2>/dev/null)" = 200 ]; then
      ok "port0.up: штатный proxy_up на port:0 → эфемерный $uport, cfg.port переписан, healthz 200"
    else
      bad "port0.up: healthz на переписанном порту $uport не 200"
    fi
    proxy_down "$upid"
  fi

  # ── p0.conc: два конкурентных port:0 прокси → РАЗНЫЕ эфемерные порты (не фикс-константа) ──
  local c1 c2 d1 d2 idx i r1 r2
  local -a cfgs dirs pids
  c1="$(gen_config "$work/c1")"; d1="$(jq -r '.data_dir' "$c1")"
  t="$(mktemp -p "$TMP_ROOT")"; jq '.port = 0' "$c1" > "$t" && mv "$t" "$c1"
  c2="$(gen_config "$work/c2")"; d2="$(jq -r '.data_dir' "$c2")"
  t="$(mktemp -p "$TMP_ROOT")"; jq '.port = 0' "$c2" > "$t" && mv "$t" "$c2"
  cfgs=("$c1" "$c2"); dirs=("$d1" "$d2")
  for idx in 0 1; do
    ( cd "$(dirname "${cfgs[$idx]}")"; exec node $PROXY_NODE_FLAGS "$PROXY" --config "${cfgs[$idx]}" ) \
        > "${dirs[$idx]}/proxy.pid.log" 2> "${dirs[$idx]}/proxy.pid.err" &
    pids[$idx]=$!
    echo "${pids[$idx]}" > "${dirs[$idx]}/proxy.pid"
  done
  r1=""; r2=""
  for i in $(seq 1 100); do
    [ -z "$r1" ] && [ -s "$d1/.actual_port" ] && r1="$(cat "$d1/.actual_port")"
    [ -z "$r2" ] && [ -s "$d2/.actual_port" ] && r2="$(cat "$d2/.actual_port")"
    [ -n "$r1" ] && [ -n "$r2" ] && break
    sleep 0.05
  done
  if [ -n "$r1" ] && [ -n "$r2" ] && [ "$r1" != 0 ] && [ "$r2" != 0 ] && [ "$r1" != "$r2" ] \
     && [ "$(curl -s -o /dev/null -w '%{http_code}' -m 3 "http://127.0.0.1:${r1}/healthz" 2>/dev/null)" = 200 ] \
     && [ "$(curl -s -o /dev/null -w '%{http_code}' -m 3 "http://127.0.0.1:${r2}/healthz" 2>/dev/null)" = 200 ]; then
    ok "port0.conc: два конкурентных port:0 → РАЗНЫЕ OS-эфемерные порты ($r1 ≠ $r2), оба healthz 200"
  else
    bad "port0.conc: конкурентные port:0 не дали два РАЗНЫХ эфемерных порта с healthz (r1='$r1' r2='$r2') — фикс-константа/скан вместо bind:0, TOCTOU Н-45 не устранён"
  fi
  [ -n "${pids[0]:-}" ] && proxy_down "${pids[0]}"
  [ -n "${pids[1]:-}" ] && proxy_down "${pids[1]}"

  # ── p0.src: БЕЛОЩИКОВО — прокси репортит фактический порт РЕАЛЬНЫМ writeFileSync(.actual_port) ──
  # Чёрный ящик не отличает listen(0) от самовыбора (арбитраж krasnye-proby-granica-primera п.3);
  # греп исходника — конвенция к1/к2. Требуем РЕАЛЬНЫЙ вызов writeFileSync(…actual_port) И
  # server.address() В САМОМ $PROXY: адверсарий (verdicts/adversary/contracts-007) прошёл голый греп
  # литералов декой-строкой `void 'server.address() .actual_port'` + выносом отчёта в импортируемый
  # модуль. Голый литерал больше не засчитывается. ОСТАТОК (cognitive-only, standard A, Н-46):
  # встроенный listen-monkeypatch с probe-close-rebind греп не ловит — это адверсарию, не приёмке.
  if grep -Eq 'server\.address\(\)' "$PROXY" \
     && grep -Eq 'writeFileSync\([^;]*\.actual_port' "$PROXY"; then
    ok "port0.src: metering_proxy.ts репортит фактический порт от server.address() реальным writeFileSync(.actual_port)"
  else
    bad "port0.src: нет РЕАЛЬНОГО writeFileSync(…\.actual_port) от server.address() в $PROXY — репорт вынесен/декой, не атомарный bind:0 (free_port scan+TOCTOU Н-45)"
  fi

  # ── p0.stub: upstream-стаб репортит порт файлом-событием, не сканит (контракт 017, срез 1) ──
  # Три независимых предъявления, каждое красное против сканирующей редакции.
  # Привязка ко входам — здесь, по коду (Н-39):
  #   (1) словарная: в теле stub_upstream нет ни free_port, ни ss-поллинга;
  #   (2) запись порта ТОЛЬКО слушателем — вход «node гибнет до listen»:
  #       подменяем node на немедленно гибнущий стаб; событийная редакция файла
  #       порта не оставляет (запись живёт в listen-callback), сканирующая
  #       пишет порт ДО spawn — порт-файл переживает мёртвый node;
  #   (3) готовность НЕ зависит от ss-скана — вход «ss сломан»: тень ss
  #       (exit 1) в PATH; событийная редакция поднимается и отвечает,
  #       сканирующая 15 с ждёт подтверждения сканом и умирает молча.
  local stub_src stubdie stubdie_rc fakenode stubnoss stubnoss_rc stubnoss_port stubnoss_pid
  stub_src="$(awk '/^stub_upstream\(\) \{/,/^\}/' "$SELF_DIR/check_metering.sh")"
  if printf '%s\n' "$stub_src" | grep -qE '\bfree_port\b|ss -ltn'; then
    bad "port0.stub: тело stub_upstream ещё сканит (free_port и/или ss-поллинг готовности) — TOCTOU Н-45 жив в фикстурном пути upstream"
  else
    ok "port0.stub: тело stub_upstream без free_port и ss-скана — порт upstream назначает ОС, готовность событием"
  fi

  # (2) порт-файл пишет ТОЛЬКО слушатель (вход: немедленно гибнущий node).
  fakenode="$(mktemp -d "$work/fakenode.XXXXXX")"
  printf '#!/bin/sh\nexit 3\n' > "$fakenode/node"
  chmod +x "$fakenode/node"
  stubdie="$(mktemp -d "$work/stubdie.XXXXXX")"
  # hash -r обязателен: хэш команд родителя переживает смену PATH в подоболочке,
  # без него node/ss разрешаются по хэшу и декой не включается (замер этой пачки).
  ( export PATH="$fakenode:$PATH"; hash -r; stub_upstream "$stubdie" ) >/dev/null 2>"$work/stubdie.err"
  stubdie_rc=$?
  if [ -s "$stubdie/port" ]; then
    bad "port0.stub: порт-файл upstream записан ДО слушателя (пережил немедленно погибший node, rc=$stubdie_rc, порт '$(cat "$stubdie/port")') — запись не от listen-callback"
  else
    ok "port0.stub: порт-файл upstream пишет сам слушатель — погибший до listen node не оставляет порта"
  fi

  # (3) готовность без рабочего ss (вход: тень ss, exit 1).
  stubnoss="$(mktemp -d "$work/stubnoss.XXXXXX")"
  mkdir -p "$work/nossss"
  printf '#!/bin/sh\nexit 1\n' > "$work/nossss/ss"
  chmod +x "$work/nossss/ss"
  stubnoss_port="$( ( export PATH="$work/nossss:$PATH"; hash -r; stub_upstream "$stubnoss" ) 2>"$work/stubnoss.err" )"
  stubnoss_rc=$?
  if [ -s "$stubnoss/stub.pid" ]; then
    stubnoss_pid="$(cat "$stubnoss/stub.pid")"
  else
    stubnoss_pid=""
  fi
  if [ "$stubnoss_rc" != 0 ] || [ -z "$stubnoss_port" ]; then
    bad "port0.stub: готовность upstream зависит от ss-скана (тень ss: exit 1 → rc=$stubnoss_rc: $(tr '\n' ' ' < "$work/stubnoss.err" 2>/dev/null | tail -c 160)) — событийная готовность не мигрирована"
  elif kill -0 "$stubnoss_pid" 2>/dev/null \
       && [ "$(curl -s -o /dev/null -w '%{http_code}' -m 3 "http://127.0.0.1:${stubnoss_port}/" 2>/dev/null)" = 200 ]; then
    ok "port0.stub: upstream поднимается и отвечает при нерабочем ss — порт $stubnoss_port репортирован слушателем, не найден сканом"
  else
    bad "port0.stub: под ss-тенью стаб отчитался портом, но не отвечает/не жив — предъявление недобросовестно"
  fi
  # чистка обеих ветвей: живой стаб-node не должен переживать пробу (Н-46: утёкшие
  # стабы контеншили порты и изображали регрессию)
  [ -n "$stubnoss_pid" ] && kill "$stubnoss_pid" 2>/dev/null || true

  # ── p0.i: ветвь (и) — свой прокси на bind :0, фактический порт из события (срез 2) ──
  # РАНТАЙМ, не словарная проверка исходника (блокер 2 вердикта v1: проба «в теле
  # branch_и нет слова free_port» обходится выносом скана в алиас — scan_port()).
  # Ветвь (и) исполняется ЦЕЛИКОМ в контролируемом окружении; ловца два, оба
  # поведенческие, привязаны ко входам здесь, по коду (Н-39):
  #   (1) ss-ЛГУН в PATH перечисляет занятыми ВСЕ порты — путь ветви, который
  #       выбирает или подтверждает порт через ss (free_port-скан, алиас
  #       scan_port(), ss-поллинг готовности), под лгуном НЕ ПРОХОДИТ:
  #       скан-выбор не подтверждается (окно готовности истекает именованным
  #       отказом), либо спавн уходит с предвыбранным портом — и его ловит
  #       трассир (2). Честному bind :0 ss в фикстурном пути не нужен вовсе.
  #       (Замер пачки: под set -o pipefail совпадение grep -q на большом
  #       выводе рвёт пайплайн сигпайпом — семантика ss-проверок инвертируется;
  #       ловец опирается на исход ветви, не на текст её отказа.)
  #   (2) node-ТРАССИР снимает конфиг ветви в момент спавна прокси — вход
  #       «порт выбран до слушателя» (скан без ss, фиксированная константа):
  #       при bind :0 снимок несёт "port": 0, заранее выбранный порт — число.
  # Сверка факта после прогона: событие <data_dir>/.actual_port от слушателя
  # существует; конфиг ветви переписан на фактический порт (proxy_up уже умеет).
  local W_i snapcfg REAL_NODE p0i_rc p0i_port p0i_actual p0i_cfg_port p0i_stubpid
  W_i="$(mktemp -d "$work/p0i.XXXXXX")"
  snapcfg="$W_i/config.spawn.json"
  REAL_NODE="$(command -v node)"
  mkdir -p "$W_i/bin"
  # Лгун ss: четвёртое поле «адрес:порт», как настоящий ss -ltn; вывод закеширован
  # в файл — 200 попыток free_port не гоняют генерацию заново.
  seq 1 65535 | sed 's|^|LISTEN 0 0 127.0.0.1:|' > "$W_i/ss.out"
  printf '#!/usr/bin/env bash\ncat "%s/ss.out"\n' "$W_i" > "$W_i/bin/ss"
  # Трассир node: снимок конфига ветви (и) на спавне, затем честный exec.
  cat > "$W_i/bin/node" <<'NODE_TRACE'
#!/usr/bin/env bash
for a in "$@"; do
  if [ "$a" = "$P0I_CFG_PATH" ]; then cp "$a" "$P0I_SNAP" 2>/dev/null || :; fi
done
exec "$P0I_REAL_NODE" "$@"
NODE_TRACE
  chmod +x "$W_i/bin/ss" "$W_i/bin/node"
  # Ветвь целиком, в подоболочке: её bad/ok и die остаются в логе, приговор
  # выносит проба по факту. BARRIER_CFG задаёт корень ветви: конфиг ветви (и)
  # обязан оказаться в $W_i/branch_и/config.json (branch_и строит путь сама).
  (
    export PATH="$W_i/bin:$PATH"
    export P0I_CFG_PATH="$W_i/branch_и/config.json" P0I_SNAP="$snapcfg" P0I_REAL_NODE="$REAL_NODE"
    export BARRIER_CFG="$W_i/cfg.json"
    hash -r   # хэш родителя переживает смену PATH: без сброса лгун/трассир не включаются
    branch_и
  ) > "$W_i/branch.log" 2>&1
  p0i_rc=$?
  # Чистка независимо от исхода (Н-46: утёкшие стаб/прокси контеншили порты и
  # изображали регрессию). Ветвь сама гасит прокси на успехе — здесь страховка.
  if [ -s "$W_i/branch_и/proxy.pid" ]; then
    proxy_down "$(cat "$W_i/branch_и/proxy.pid")"
  fi
  if [ -s "$W_i/branch_и/up/stub.pid" ]; then
    p0i_stubpid="$(cat "$W_i/branch_и/up/stub.pid")"
    kill "$p0i_stubpid" 2>/dev/null || true
  fi
  if [ "$p0i_rc" != 0 ]; then
    bad "port0.i: ветвь (и) не прошла в контролируемом окружении с ss-лгуном (rc=$p0i_rc) — в пути ветви жива ss-зависимость (скан-выбор порта или скан-подтверждение готовности); лог: $(tr '\n' ' ' < "$W_i/branch.log" 2>/dev/null | tail -c 200)"
  elif [ ! -s "$snapcfg" ]; then
    bad "port0.i: спавн прокси ветви не наблюдён трассиром (снимок конфига пуст) — ветвь поднимает прокси мимо --config"
  else
    p0i_port="$(jq -r '.port' "$snapcfg" 2>/dev/null)"
    p0i_actual="$(cat "$W_i/branch_и/data/.actual_port" 2>/dev/null)"
    p0i_cfg_port="$(jq -r '.port' "$W_i/branch_и/config.json" 2>/dev/null)"
    if [ "$p0i_port" != "0" ]; then
      bad "port0.i: прокси ветви (и) взят на спавн с заранее выбранным портом \"$p0i_port\" (не bind :0) — порт выбран до слушателя, скан/фикс жив (снимок: $snapcfg)"
    elif [ -z "$p0i_actual" ]; then
      bad "port0.i: событие .actual_port от слушателя отсутствует — фактический порт ветви берётся не из события"
    elif [ "$p0i_cfg_port" != "$p0i_actual" ]; then
      bad "port0.i: конфиг ветви не переписан на фактический порт (cfg='$p0i_cfg_port', событие='$p0i_actual') — срез 2 не завершён"
    else
      ok "port0.i: ветвь (и) прошла под ss-лгуном; спавн с \"port\": 0, фактический $p0i_actual из события .actual_port — прокси ветви на OS-эфемерном, выбор порта до слушателя мёртв"
    fi
  fi

  # ── p0.noreport: отказ «не репортит порт» ИМЕНОВАН, не молчаливым таймаутом окна ──
  # Живой стаб-node без слушателя и без записи порта: потолок ожидания — бюджет
  # тиков до смерти/бюджета (А-18), исход — именованный отказ «не репортит порт».
  # Скандирующая редакция молчит 15 с и умирает «не поднялся за 15 с» — без имени.
  local noreport_dir noreport_rc
  noreport_dir="$(mktemp -d "$work/noreport.XXXXXX")"
  mkdir -p "$noreport_dir/bin"
  cat > "$noreport_dir/bin/node" <<'FAKENODE'
#!/bin/sh
printf '%s\n' $$ > "$FAKENODE_PID"
exec sleep 120
FAKENODE
  chmod +x "$noreport_dir/bin/node"
  ( export PATH="$noreport_dir/bin:$PATH" FAKENODE_PID="$work/noreport.fakepid"; hash -r; stub_upstream "$noreport_dir" ) >/dev/null 2>"$work/noreport.err"
  noreport_rc=$?
  if grep -q 'не репортит порт' "$work/noreport.err"; then
    ok "port0.noreport: живой стаб без порт-файла — именованный отказ «не репортит порт» (различим с мёртвым и с медленным)"
  else
    bad "port0.noreport: живой стаб без порт-файла умер без имени причины (rc=$noreport_rc: $(tr '\n' ' ' < "$work/noreport.err" 2>/dev/null | tail -c 160)) — «не репортит порт» не различим с «медленный старт»"
  fi
  if [ -s "$work/noreport.fakepid" ]; then
    kill "$(cat "$work/noreport.fakepid")" 2>/dev/null || true
  fi

  [ "$fails" -eq 0 ]
}

if mode_port0; then exit 0; else exit 1; fi
