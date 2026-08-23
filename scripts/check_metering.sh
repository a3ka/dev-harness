#!/usr/bin/env bash
# scripts/check_metering.sh — барьер приёмки прокси учёта трафика моделей (контракт 005).
#
# Три режима:
#   bash scripts/check_metering.sh              пятнадцать ветвей с подставным upstream;
#   bash scripts/check_metering.sh --live       живой omp-вызов через настоящий прокси;
#   bash scripts/check_metering.sh --cold-start холодный старт через лаунчер workshop.
#
# Этот файл реализует ТОЛЬКО режим по умолчанию (пятнадцать ветвей, критерий 2
# контракта). Режимы --live и --cold-start дописывает отдельный агент: каркас
# режима и его NOT_IMPLEMENTED-пометка оставлены, чтобы сосед знал, куда встраиваться.
#
# ОБЩИЙ ПЛУМБИНГ (`stub_upstream`, `proxy_up`, `proxy_down`, `req`, `gen_config`,
# `branch`) живёт в одном экземпляре и используется ВСЕМИ ветвями — три других
# агента подключают тот же файл. Зашитые константы вместо порождаемых значений
# ЗАПРЕЩЕНЫ (арбитраж K1-5): токены, provider id, model id, upstream-пути и порты
# порождаются `gen_config` при каждом прогоне.
#
# Герметичность: HOME, data_dir и secrets_env — ВСЕ в своём tmp каталоге прогона.
# Реальный дом секретов ~/.config/dev-harness/secrets.env НЕ читается и НЕ пишется;
# ветвь (и) пишет свой собственный файл секретов и передаёт его через --config.
#
# SELF_DIR — каталог барьера. Прокси ищется РЯДОМ с барьером, а не через REPO:
# фикстура make_repo копирует прокси в $WORK/repo/scripts/proxy/, а verify_antiplacebo
# копирует барьер в $BARRIER_ROOT/scripts/ — это ОДИН каталог, и относительный путь
# даёт подменённую копию после stub_proxy.
#
# Коды возврата: 0 — все ветви зелёные, 1 — расхождение (отказ с именем и фактом),
# 2 — нечем проверить.
set -uo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROXY="$SELF_DIR/proxy/metering_proxy.ts"
# Правило 16 нормы: временное — в ./tmp РЕПОЗИТОРИЯ, не в системном /tmp. Прежняя редакция
# писала в ${TMPDIR:-/tmp}, и прогон печатал «работа в /tmp/metering.Jqytji» (замер 2026-08-20).
REPO_ROOT="$(cd "$SELF_DIR/.." && pwd)"
TMP_ROOT="$REPO_ROOT/tmp"
mkdir -p "$TMP_ROOT" 2>/dev/null || die "каталог $TMP_ROOT не создать — временному некуда лечь"
[ -w "$TMP_ROOT" ] || die "каталог $TMP_ROOT не записываем — временному некуда лечь"

fails=0
ok()   { printf '  ok   %s\n' "$*" >&2; }
bad()  { fails=$((fails + 1)); printf '  FAIL %s\n' "$*" >&2; }
die()  { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

command -v node      >/dev/null 2>&1 || skip "нет node — прокси/подставной upstream не запустить"
command -v jq        >/dev/null 2>&1 || skip "нет jq — конфиг/журнал не разобрать"
command -v ss        >/dev/null 2>&1 || skip "нет ss — свободный порт не выбрать"
command -v sha256sum >/dev/null 2>&1 || skip "нет sha256sum — тело ответа нечем сверить"
command -v base64    >/dev/null 2>&1 || skip "нет base64 — тело сценария нечем кодировать"
command -v curl      >/dev/null 2>&1 || skip "нет curl — healthz не дёрнуть"

MODE="default"
case "${1:-}" in
  --live|--cold-start|--port0) MODE="${1#--}" ;;
  ""|--default)        MODE="default" ;;
  *) die "неизвестный режим: $1 (ожидался --live, --cold-start, --port0 или пусто)" ;;
esac
case "$MODE" in
  default) ;;
  live|cold-start) skip "режим --$MODE дописывается соседним агентом; этот файл реализует только default" ;;
esac

# ── ПЛУМБИНГ: общие функции для всех ветвей ───────────────────────────────────

free_port() {
  local p tries=0
  while [ "$tries" -lt 200 ]; do
    p="$(( RANDOM * 32768 + RANDOM ))"
    p=$(( p % 40000 + 10000 ))
    [ "$p" != "8765" ] || { tries=$((tries + 1)); continue; }
    if ! ss -ltn 2>/dev/null | awk '{print $4}' | grep -qE ":${p}\$"; then
      printf '%s' "$p"; return 0
    fi
    tries=$((tries + 1))
  done
  die "не нашлось свободного порта за 200 попыток"
}

rnd_label() {
  local n="$1" out="" i
  for i in $(seq 1 "$n"); do
    out="${out}$(printf '%s' "$RANDOM" | tr '0-9' 'a-j' | head -c1)"
  done
  printf '%s' "$out"
}

stub_upstream() {
  local dir="$1"
  mkdir -p "$dir"
  : > "$dir/requests.jsonl"
  printf '0\n' > "$dir/count"
  printf '{"status":200,"content_type":"application/octet-stream","body_b64":"","headers":{}}\n' \
    > "$dir/scenario.json"
  local port pid i attempt=0 race
  # ГОНКА ПОРТА (TOCTOU): между free_port и listen порт занять может соседняя
  # фикстура (анти-плацебо крутит их параллельно десятки). Гибель слушателя с
  # EADDRINUSE — не отказ, а сигнал взять НОВЫЙ порт и повторить; повтор ограничен,
  # исчерпание — отказ с причиной и числом попыток. Прочая гибель — отказ сразу.
  while [ "$attempt" -lt 5 ]; do
    attempt=$((attempt + 1))
    port="$(free_port)"
    printf '%s' "$port" > "$dir/port"
    # БЕЗ setsid: setsid форкается, и $! — pid РОДИТЕЛЯ-setsid (сразу выходит), а
    # node получает другой pid → в stub.pid попадал мёртвый pid, kill_all_proxies
    # бил пустую группу, стаб-node выживал (утечка ~2/прогон, замер 2026-08-21;
    # «убийца стаба л.о»). Без setsid $! = pid node, pid-файловый проход его глушит.
    PORT="$port" DIR="$dir" \
    node -e '
      const fs = require("node:fs");
      const http = require("node:http");
      const port = parseInt(process.env.PORT, 10);
      const dir = process.env.DIR;
      const reqlog = dir + "/requests.jsonl";
      const countf = dir + "/count";
      const scen = dir + "/scenario.json";
      const server = http.createServer((req, res) => {
        const chunks = [];
        req.on("data", c => chunks.push(c));
        req.on("end", () => {
          const body = Buffer.concat(chunks);
          fs.appendFileSync(reqlog, JSON.stringify({
            method: req.method, path: req.url,
            body_b64: body.toString("base64"),
            content_type: req.headers["content-type"] || "",
            request_id: req.headers["x-request-id"] || ""
          }) + "\n");
          let cnt = 0;
          try { cnt = parseInt(fs.readFileSync(countf, "utf8"), 10) || 0; } catch (_) { cnt = 0; }
          fs.writeFileSync(countf, String(cnt + 1));
          let sc = { status: 200, content_type: "application/octet-stream", body_b64: "", headers: {} };
          try { sc = JSON.parse(fs.readFileSync(scen, "utf8")); } catch (_) {}
          const bodyResp = Buffer.from(sc.body_b64 || "", "base64");
          if (sc.headers) for (const [k, v] of Object.entries(sc.headers)) res.setHeader(k, v);
          res.statusCode = sc.status || 200;
          res.setHeader("content-type", sc.content_type || "application/octet-stream");
          res.end(bodyResp);
        });
      });
      server.listen(port, "127.0.0.1", () => {
        process.stderr.write("stub upstream listening on " + port + "\n");
      });
    ' metering-stub-upstream "$dir" > "$dir/stub.log" 2> "$dir/stub.err" &
    pid="$!"
    echo "$pid" > "$dir/stub.pid"
    race=0
    # Терпение 15 с (не 3): под внешней нагрузкой (qemu-VM, браузер) холодный старт
    # Node до listen порой > 3 с — стаб ЖИВ, но не успел. Ранний выход по готовности
    # сохранён, happy-path не медленнее; смерть процесса ловится тут же (не ждём зря).
    for i in $(seq 1 300); do
      if ss -ltn 2>/dev/null | awk '{print $4}' | grep -qE ":${port}\$"; then
        printf '%s\n' "$port"; return 0
      fi
      if ! kill -0 "$pid" 2>/dev/null; then
        if grep -q "EADDRINUSE" "$dir/stub.err" 2>/dev/null; then
          race=1
          break
        fi
        die "stub_upstream погиб на старте (pid=$pid, порт $port) — лог: $dir/stub.err"
      fi
      sleep 0.05
    done
    [ "$race" -eq 1 ] || die "stub_upstream не поднялся на порту $port за 15 с — лог: $dir/stub.err"
  done
  die "порт stub_upstream занят гонкой EADDRINUSE во всех $attempt попытках — последнее: $dir/stub.err"
}

# РАНТАЙМ-ЭНФОРСМЕНТ builtins-only (арбитраж verdicts/arbitration/grep-vs-runtime-builtins.md,
# f175567): статический греп ветвей (к1)/(к2) — регресс-гард, ПРИЁМОЧНУЮ силу даёт запуск
# прокси под флагами node. --disallow-code-generation-from-strings закрывает code-gen канал
# (Function/eval → любой динамический import, как ни склеивай строку — EvalError на исполнении);
# --permission без --allow-child-process запрещает порождение процессов пер-процессно (никакая
# JS-рефлексия не обходит). fs открыт широко (/): выигрыш замеров арбитра от fs-области не зависит.
# Остаток (cognitive-only, правило 8): node:vm под codegen-флагом и рефлексивный createRequire —
# сужены грепом литералов в (к1). Все ТРИ точки запуска прокси в барьере несут эти флаги.
readonly PROXY_NODE_FLAGS="--disallow-code-generation-from-strings --permission --allow-fs-read=/ --allow-fs-write=/ --allow-net"

proxy_up() {
  local cfg="$1" pidfile="$2"
  [ -f "$PROXY" ] || die "прокси не найден рядом с барьером: $PROXY"
  local attempt=0
  # ГОНКА ПОРТА (TOCTOU): порт из конфига мог занять соседняя фикстура между
  # free_port (в gen_config) и listen. Гибель ребёнка с EADDRINUSE — взять НОВЫЙ
  # свободный порт, переписать его в конфиг и повторить, ограниченно; прочая
  # гибель и молчащий healthz — отказ с причиной. Ветви читают порт из $cfg
  # ПОСЛЕ proxy_up, смена порта им прозрачна; pid-файл всегда несёт живого.
  while [ "$attempt" -lt 5 ]; do
    attempt=$((attempt + 1))
    (
      cd "$(dirname "$cfg")"
      exec node $PROXY_NODE_FLAGS "$PROXY" --config "$cfg"
    ) > "$pidfile.log" 2> "$pidfile.err" &
    local pid="$!"
    echo "$pid" > "$pidfile"
    local port win
    port="$(jq -r '.port' "$cfg")"
    if [ "$port" = 0 ]; then
      # port:0 → прокси биндит OS-эфемерный и репортит фактический в <data_dir>/.actual_port
      # (срез-2 контракта 007). Читаем его и переписываем cfg.port — ветви читают порт как обычно.
      local _ap _dd _pi
      _dd="$(jq -r '.data_dir' "$cfg")"; _ap="$_dd/.actual_port"
      for _pi in $(seq 1 100); do
        [ -s "$_ap" ] && { port="$(cat "$_ap")"; break; }
        kill -0 "$pid" 2>/dev/null || break
        sleep 0.05
      done
      if [ -n "$port" ] && [ "$port" != 0 ]; then
        jq --argjson p "$port" '.port = $p' "$cfg" > "${cfg}.p0" && mv "${cfg}.p0" "$cfg"
      fi
    fi
    win="$(jq -r '.healthz_window_sec' "$cfg")"
    # Пол терпения 15 с под нагрузкой (см. stub_upstream): win*20 при win=5 = 5 с
    # мало, когда Node стартует медленно; смерть процесса ловится в цикле раньше.
    local max=$(( win * 20 )); [ "$max" -lt 300 ] && max=300
    local i race=0
    for i in $(seq 1 "$max"); do
      if curl -fsS -o /dev/null -m 0.5 "http://127.0.0.1:${port}/healthz" 2>/dev/null; then
        printf '%s' "$pid"; return 0
      fi
      if ! kill -0 "$pid" 2>/dev/null; then
        if grep -q "EADDRINUSE" "$pidfile.err" 2>/dev/null; then
          race=1
          break
        fi
        die "прокси погиб на старте (pid=$pid), лог: $pidfile.err"
      fi
      sleep 0.05
    done
    [ "$race" -eq 1 ] || {
      kill "$pid" 2>/dev/null || true
      die "healthz не ответил за ${win} с на порту $port — лог: $pidfile.err"
    }
    local newport
    newport="$(free_port)"
    jq --argjson p "$newport" '.port = $p' "$cfg" > "${cfg}.new" \
      || die "не переписать порт в $cfg после гонки EADDRINUSE"
    mv "${cfg}.new" "$cfg"
  done
  die "порт прокси занят гонкой EADDRINUSE во всех $attempt попытках — лог: $pidfile.err"
}

proxy_down() {
  local pid="${1:-}"
  [ -n "$pid" ] || return 0
  kill -- "-$pid" 2>/dev/null || kill "$pid" 2>/dev/null || true
  local i
  for i in $(seq 1 20); do
    kill -0 "$pid" 2>/dev/null || return 0
    sleep 0.05
  done
  kill -9 "$pid" 2>/dev/null || true
}

req() {
  local method="$1" url="$2" token="$3" model="$4" body="$5" ctype="$6" rid="$7"
  METHOD="$method" URL="$url" TOKEN="$token" MODEL="$model" \
    BODY="$body" CTYPE="$ctype" RID="$rid" node -e '
      const http = require("node:http");
      const url = new URL(process.env.URL);
      const req = http.request({
        method: process.env.METHOD,
        hostname: url.hostname,
        port: url.port,
        path: url.pathname + url.search,
        headers: {
          "authorization": "Bearer " + process.env.TOKEN,
          "x-metering-model": process.env.MODEL,
          "x-request-id": process.env.RID,
          "content-type": process.env.CTYPE,
          "content-length": Buffer.byteLength(process.env.BODY, "utf8")
        }
      }, (res) => {
        const chunks = [];
        res.on("data", c => chunks.push(c));
        res.on("end", () => {
          const body = Buffer.concat(chunks);
          process.stdout.write(res.statusCode + "\n");
          process.stdout.write((res.headers["content-type"] || "") + "\n");
          process.stdout.write(require("node:crypto").createHash("sha256").update(body).digest("hex") + "\n");
          process.stdout.write("__BODY__" + body.toString("utf8"));
        });
      });
      req.on("error", () => {
        process.stdout.write("0\n\n\n__BODY__");
      });
      req.write(process.env.BODY);
      req.end();
    '
}

gen_config() {
  local dir="$1"
  local portup role provider model token proxy_port
  portup="$(free_port)"
  proxy_port=0
  role="$(rnd_label 8)"
  provider="$(rnd_label 6)"
  model="$(rnd_label 6)"
  token="$(rnd_label 24)"
  mkdir -p "$dir/data"
  cat > "$dir/secrets.env" <<EOF
METERING_TOKEN_${role}=${token}
EOF
  cat > "$dir/config.json" <<EOF
{
  "port": ${proxy_port},
  "healthz_window_sec": 5,
  "secrets_env": "${dir}/secrets.env",
  "data_dir": "${dir}/data",
  "upstream": { "${provider}": "http://127.0.0.1:${portup}" },
  "prices": {
    "${provider}": { "${model}": { "per_m_tokens": { "in": 1200000, "out": 3400000 } } }
  },
  "ceilings": { "${provider}": { "usd_per_month": 1000000000 } },
  "now_file": null
}
EOF
  cat > "$dir/vars.json" <<EOF
{ "role": "${role}", "provider": "${provider}", "model": "${model}",
  "token": "${token}", "upstream_port": ${portup},
  "proxy_port": ${proxy_port} }
EOF
  printf '%s\n' "$dir/config.json"
}

branch() {
  local name="$1" fn="${2:-branch_${name}}"
  if "$fn"; then
    printf '  ok   %s\n' "$name" >&2
  else
    printf '  FAIL %s\n' "$name" >&2
  fi
}

# ── ВЕТВИ (мои семь) ────────────────────────────────────────────────────────────

branch_а() {
  local cfg="$BARRIER_CFG"
  local port win
  port="$(jq -r '.port' "$cfg")"
  win="$(jq -r '.healthz_window_sec' "$cfg")"
  local status
  status="$(curl -s -o /dev/null -w '%{http_code}' -m "$win" "http://127.0.0.1:${port}/healthz" 2>/dev/null)"
  case "$status" in
    200) ok "а: healthz 200"; return 0 ;;
    "") bad "а: healthz таймаут за ${win} с"; return 1 ;;
    *) bad "а: healthz вернул $status, ожидался 200"; return 1 ;;
  esac
}

branch_б() {
  local cfg="$BARRIER_CFG" data="$BARRIER_DATA" vars="$BARRIER_VARS"
  local port provider model
  port="$(jq -r '.port' "$cfg")"
  provider="$(jq -r '.provider' "$vars")"
  model="$(jq -r '.model' "$vars")"
  local unknown_token
  unknown_token="$(rnd_label 32)"
  : > "$data/calls.jsonl"
  local resp status
  resp="$(req POST "http://127.0.0.1:${port}/${provider}/chat/completions" \
    "$unknown_token" "$model" "anything" "application/octet-stream" "$(rnd_label 12)")"
  status="$(printf '%s\n' "$resp" | head -1)"
  if [ "$status" != "401" ]; then
    bad "б: ожидался 401 на неизвестный токен, получено ${status:-<нет ответа>}"
    return 1
  fi
  if [ -s "$data/calls.jsonl" ]; then
    bad "б: при 401 строка журнала существует ($(wc -l < "$data/calls.jsonl") строк)"
    return 1
  fi
  ok "б: 401 на неизвестный токен, строки в журнале нет"
  return 0
}

branch_в() {
  local cfg="$BARRIER_CFG" data="$BARRIER_DATA" up_dir="$BARRIER_UP_DIR" vars="$BARRIER_VARS"
  local port provider model rid path req_body ctype
  port="$(jq -r '.port' "$cfg")"
  provider="$(jq -r '.provider' "$vars")"
  model="$(jq -r '.model' "$vars")"
  rid="$(rnd_label 16)"
  path="/${provider}/$(rnd_label 5)/$(rnd_label 7)"
  req_body="$(printf 'BINARY-%s' "$(rnd_label 64)")"
  ctype="application/x-port"
  local tok_in=1234 tok_out=567
  local up_body
  up_body="$(printf 'UPSTREAM-BODY-%s' "$(rnd_label 80)")"
  cat > "$up_dir/scenario.json" <<EOF
{"status":201,"content_type":"text/x-port","body_b64":"$(printf '%s' "$up_body" | base64 -w0)","headers":{"x-usage-tokens-in":"${tok_in}","x-usage-tokens-out":"${tok_out}"}}
EOF
  rm -f "$up_dir/requests.jsonl" "$up_dir/count" "$data/calls.jsonl"
  local resp status ctype_resp body_sha
  resp="$(req POST "http://127.0.0.1:${port}${path}" \
    "$(jq -r '.token' "$vars")" "$model" "$req_body" "$ctype" "$rid")"
  status="$(printf '%s\n' "$resp" | head -1)"
  ctype_resp="$(printf '%s\n' "$resp" | sed -n '2p')"
  body_sha="$(printf '%s\n' "$resp" | sed -n '3p')"
  if [ "$status" != "201" ]; then
    bad "в: ожидался 201, получено $status"; return 1
  fi
  if [ "$ctype_resp" != "text/x-port" ]; then
    bad "в: ожидался content-type text/x-port, получено «$ctype_resp»"; return 1
  fi
  local up_sha
  up_sha="$(printf '%s' "$up_body" | sha256sum | awk '{print $1}')"
  if [ "$body_sha" != "$up_sha" ]; then
    bad "в: тело ответа клиенту не равно телу upstream байт-в-байт"; return 1
  fi
  if [ ! -s "$up_dir/requests.jsonl" ]; then
    bad "в: upstream не зафиксировал запрос"; return 1
  fi
  local req_line up_method up_path_rec up_body_b64 up_ctype up_rid
  req_line="$(head -1 "$up_dir/requests.jsonl")"
  up_method="$(jq -r '.method' <<<"$req_line")"
  up_path_rec="$(jq -r '.path' <<<"$req_line")"
  up_body_b64="$(jq -r '.body_b64' <<<"$req_line")"
  up_ctype="$(jq -r '.content_type' <<<"$req_line")"
  up_rid="$(jq -r '.request_id' <<<"$req_line")"
  if [ "$up_method" != "POST" ]; then
    bad "в: upstream получил метод «$up_method», ожидался POST"; return 1
  fi
  if [ "$up_path_rec" != "${path#/$provider}" ]; then
    bad "в: upstream получил путь «$up_path_rec», ожидался «${path#/$provider}»"; return 1
  fi
  if [ "$(printf '%s' "$req_body" | base64 -w0)" != "$up_body_b64" ]; then
    bad "в: тело клиента не дошло до upstream байт-в-байт"; return 1
  fi
  if [ "$up_ctype" != "$ctype" ]; then
    bad "в: upstream content-type «$up_ctype», ожидался «$ctype»"; return 1
  fi
  if [ "$up_rid" != "$rid" ]; then
    bad "в: upstream x-request-id «$up_rid», ожидался «$rid»"; return 1
  fi
  if [ ! -s "$data/calls.jsonl" ]; then
    bad "в: журнал пуст, ожидалась строка с полной схемой"; return 1
  fi
  local line usd nkeys
  line="$(head -1 "$data/calls.jsonl")"
  nkeys="$(printf '%s' "$line" | jq -r 'keys | length' 2>/dev/null)"
  if [ "$nkeys" != "11" ]; then
    bad "в: строка журнала $nkeys ключей, ожидалось 11: $line"; return 1
  fi
  usd="$(printf '%s' "$line" | jq -r '.usd' 2>/dev/null)"
  if ! [[ "$usd" =~ ^[0-9]+$ ]] || [ "$usd" = "0" ]; then
    bad "в: usd «$usd» — не ненулевое целое"; return 1
  fi
  local expect_lo expect_hi
  expect_lo=$(( (tok_in * 1200000 + tok_out * 3400000) / 1000000 ))
  expect_hi=$(( ((tok_in * 1200000 + tok_out * 3400000) + 999999) / 1000000 ))
  if [ "$usd" -lt "$expect_lo" ] || [ "$usd" -gt "$expect_hi" ]; then
    bad "в: usd=$usd вне диапазона [$expect_lo..$expect_hi] для формулы"; return 1
  fi
  ok "в: POST 201, тело и заголовки дословно, журнал 11 полей, usd=$usd"
  return 0
}

branch_в2() {
  local cfg="$BARRIER_CFG" data="$BARRIER_DATA" up_dir="$BARRIER_UP_DIR" vars="$BARRIER_VARS"
  local port provider model rid path req_body ctype
  port="$(jq -r '.port' "$cfg")"
  provider="$(jq -r '.provider' "$vars")"
  model="$(jq -r '.model' "$vars")"
  rid="$(rnd_label 16)"
  path="/${provider}/$(rnd_label 5)/$(rnd_label 7)"
  req_body="$(printf 'GET-BODY-%s' "$(rnd_label 32)")"
  ctype="application/x-get"
  local tok_in=99 tok_out=11
  local up_body
  up_body="$(printf 'GET-UP-%s' "$(rnd_label 64)")"
  cat > "$up_dir/scenario.json" <<EOF
{"status":202,"content_type":"text/x-get-resp","body_b64":"$(printf '%s' "$up_body" | base64 -w0)","headers":{"x-usage-tokens-in":"${tok_in}","x-usage-tokens-out":"${tok_out}"}}
EOF
  rm -f "$up_dir/requests.jsonl" "$up_dir/count" "$data/calls.jsonl"
  local resp status ctype_resp body_sha
  resp="$(req GET "http://127.0.0.1:${port}${path}" \
    "$(jq -r '.token' "$vars")" "$model" "$req_body" "$ctype" "$rid")"
  status="$(printf '%s\n' "$resp" | head -1)"
  ctype_resp="$(printf '%s\n' "$resp" | sed -n '2p')"
  body_sha="$(printf '%s\n' "$resp" | sed -n '3p')"
  if [ "$status" != "202" ]; then
    bad "в2: ожидался 202, получено $status"; return 1
  fi
  if [ "$ctype_resp" != "text/x-get-resp" ]; then
    bad "в2: content-type «$ctype_resp», ожидался text/x-get-resp"; return 1
  fi
  local up_sha
  up_sha="$(printf '%s' "$up_body" | sha256sum | awk '{print $1}')"
  if [ "$body_sha" != "$up_sha" ]; then
    bad "в2: тело ответа клиенту не равно телу upstream байт-в-байт"; return 1
  fi
  if [ ! -s "$up_dir/requests.jsonl" ]; then
    bad "в2: upstream не зафиксировал запрос"; return 1
  fi
  local req_line up_method up_body_b64 up_ctype up_rid up_path_rec
  req_line="$(head -1 "$up_dir/requests.jsonl")"
  up_method="$(jq -r '.method' <<<"$req_line")"
  up_path_rec="$(jq -r '.path' <<<"$req_line")"
  up_body_b64="$(jq -r '.body_b64' <<<"$req_line")"
  up_ctype="$(jq -r '.content_type' <<<"$req_line")"
  up_rid="$(jq -r '.request_id' <<<"$req_line")"
  if [ "$up_method" != "GET" ]; then
    bad "в2: upstream получил «$up_method», ожидался GET — POST-only стаб"; return 1
  fi
  if [ "$up_path_rec" != "${path#/$provider}" ]; then
    bad "в2: upstream получил путь «$up_path_rec», ожидался «${path#/$provider}»"; return 1
  fi
  if [ "$(printf '%s' "$req_body" | base64 -w0)" != "$up_body_b64" ]; then
    bad "в2: тело клиента не дошло до upstream байт-в-байт"; return 1
  fi
  if [ "$up_ctype" != "$ctype" ]; then
    bad "в2: upstream content-type «$up_ctype», ожидался «$ctype»"; return 1
  fi
  if [ "$up_rid" != "$rid" ]; then
    bad "в2: upstream x-request-id «$up_rid», ожидался «$rid»"; return 1
  fi
  if [ ! -s "$data/calls.jsonl" ]; then
    bad "в2: журнал пуст"; return 1
  fi
  local line usd nkeys
  line="$(head -1 "$data/calls.jsonl")"
  nkeys="$(printf '%s' "$line" | jq -r 'keys | length' 2>/dev/null)"
  if [ "$nkeys" != "11" ]; then
    bad "в2: строка журнала $nkeys ключей, ожидалось 11: $line"; return 1
  fi
  usd="$(printf '%s' "$line" | jq -r '.usd' 2>/dev/null)"
  if ! [[ "$usd" =~ ^[0-9]+$ ]] || [ "$usd" = "0" ]; then
    bad "в2: usd «$usd» — не ненулевое целое"; return 1
  fi
  ok "в2: GET 202, тело и заголовки дословно, журнал 11 полей, usd=$usd"
  return 0
}

branch_г() {
  local cfg="$BARRIER_CFG" data="$BARRIER_DATA" up_dir="$BARRIER_UP_DIR" vars="$BARRIER_VARS"
  local port provider model rid
  port="$(jq -r '.port' "$cfg")"
  provider="$(jq -r '.provider' "$vars")"
  model="$(jq -r '.model' "$vars")"
  rid="$(rnd_label 16)"
  local ceiling
  ceiling="$(jq -r ".ceilings.${provider}.usd_per_month" "$cfg")"
  local spent=$((ceiling - 1000))
  local period
  period="$(date -u +%Y-%m)"
  mkdir -p "$data"
  cat > "$data/budget.json" <<EOF
{ "${period}": { "${provider}": ${spent} } }
EOF
  rm -f "$data/calls.jsonl" "$up_dir/requests.jsonl" "$up_dir/count"
  # Большой usage, чтобы перерасход был заметным и ОБЯЗАТЕЛЬНО пересёк потолок.
  # cost = ceil((tok_in * 1_200_000 + tok_out * 3_400_000) / 1_000_000).
  # Для tok_in=2000, tok_out=1: cost = ceil(2403.4) = 2404 микро-USD.
  # spent + cost = 999_999_000 + 2404 = 1_000_001_404 > ceiling 1_000_000_000.
  local tok_in=2000 tok_out=1
  cat > "$up_dir/scenario.json" <<EOF
{"status":200,"content_type":"application/octet-stream","body_b64":"$(printf 'ok' | base64 -w0)","headers":{"x-usage-tokens-in":"${tok_in}","x-usage-tokens-out":"${tok_out}"}}
EOF
  local resp status
  resp="$(req POST "http://127.0.0.1:${port}/${provider}/chat/completions" \
    "$(jq -r '.token' "$vars")" "$model" "ping" "application/octet-stream" "$rid")"
  status="$(printf '%s\n' "$resp" | head -1)"
  if [ "$status" != "200" ]; then
    bad "г: ожидался 200 при переходе потолка ПРОХОДИТ, получено $status"; return 1
  fi
  if [ ! -s "$up_dir/requests.jsonl" ]; then
    bad "г: upstream не получил запрос — потолок отрезал ДО запроса"; return 1
  fi
  if [ ! -s "$data/budget.json" ]; then
    bad "г: budget.json не записан"; return 1
  fi
  local new_spent
  new_spent="$(jq -r ".[\"${period}\"][\"${provider}\"]" "$data/budget.json" 2>/dev/null)"
  if [ -z "$new_spent" ] || [ "$new_spent" = "null" ]; then
    bad "г: budget.json не содержит записи за $period/$provider"; return 1
  fi
  if [ "$new_spent" -le "$ceiling" ]; then
    bad "г: budget после ($new_spent) ≤ ceiling ($ceiling) — перерасход не записан"; return 1
  fi
  if [ ! -s "$data/calls.jsonl" ]; then
    bad "г: журнал пуст"; return 1
  fi
  local line usd nkeys
  line="$(head -1 "$data/calls.jsonl")"
  nkeys="$(printf '%s' "$line" | jq -r 'keys | length' 2>/dev/null)"
  if [ "$nkeys" != "11" ]; then
    bad "г: строка журнала $nkeys ключей, ожидалось 11: $line"; return 1
  fi
  usd="$(printf '%s' "$line" | jq -r '.usd' 2>/dev/null)"
  if ! [[ "$usd" =~ ^[0-9]+$ ]] || [ "$usd" = "0" ]; then
    bad "г: usd «$usd» не ненулевое целое"; return 1
  fi
  ok "г: 200 при переходе потолка, budget после=$new_spent > ceiling=$ceiling, usd=$usd"
  return 0
}

branch_г2() {
  local cfg="$BARRIER_CFG" data="$BARRIER_DATA" up_dir="$BARRIER_UP_DIR" vars="$BARRIER_VARS"
  local port provider model rid
  port="$(jq -r '.port' "$cfg")"
  provider="$(jq -r '.provider' "$vars")"
  model="$(jq -r '.model' "$vars")"
  rid="$(rnd_label 16)"
  local ceiling period spent
  ceiling="$(jq -r ".ceilings.${provider}.usd_per_month" "$cfg")"
  period="$(date -u +%Y-%m)"
  spent="$ceiling"
  mkdir -p "$data"
  cat > "$data/budget.json" <<EOF
{ "${period}": { "${provider}": ${spent} } }
EOF
  rm -f "$data/calls.jsonl" "$up_dir/requests.jsonl" "$up_dir/count"
  local resp status body
  resp="$(req POST "http://127.0.0.1:${port}/${provider}/chat/completions" \
    "$(jq -r '.token' "$vars")" "$model" "ping" "application/octet-stream" "$rid")"
  status="$(printf '%s\n' "$resp" | head -1)"
  body="${resp##*__BODY__}"
  if [ "$status" != "402" ]; then
    bad "г2: ожидался 402 при исчерпанном потолке, получено $status"; return 1
  fi
  if [ -s "$up_dir/requests.jsonl" ]; then
    bad "г2: upstream вызван при исчерпанном потолке — должен быть ДО запроса"; return 1
  fi
  for k in period provider spent_usd limit_usd; do
    if ! printf '%s' "$body" | grep -q "\"${k}\""; then
      bad "г2: тело 402 не содержит «${k}»: $body"; return 1
    fi
  done
  local got_period got_provider got_spent got_limit
  got_period="$(printf '%s' "$body" | jq -r '.period' 2>/dev/null)"
  got_provider="$(printf '%s' "$body" | jq -r '.provider' 2>/dev/null)"
  got_spent="$(printf '%s' "$body" | jq -r '.spent_usd' 2>/dev/null)"
  got_limit="$(printf '%s' "$body" | jq -r '.limit_usd' 2>/dev/null)"
  if [ "$got_period" != "$period" ]; then
    bad "г2: period в 402 «$got_period», ожидался «$period»"; return 1
  fi
  if [ "$got_provider" != "$provider" ]; then
    bad "г2: provider в 402 «$got_provider», ожидался «$provider»"; return 1
  fi
  if [ "$got_spent" != "$spent" ]; then
    bad "г2: spent_usd в 402 «$got_spent», ожидался «$spent»"; return 1
  fi
  if [ "$got_limit" != "$ceiling" ]; then
    bad "г2: limit_usd в 402 «$got_limit», ожидался «$ceiling»"; return 1
  fi
  if [ ! -s "$data/calls.jsonl" ]; then
    bad "г2: 402 обязан писаться строкой, журнал пуст"; return 1
  fi
  local line usd nkeys status_field
  line="$(head -1 "$data/calls.jsonl")"
  nkeys="$(printf '%s' "$line" | jq -r 'keys | length' 2>/dev/null)"
  if [ "$nkeys" != "11" ]; then
    bad "г2: строка журнала $nkeys ключей, ожидалось 11: $line"; return 1
  fi
  usd="$(printf '%s' "$line" | jq -r '.usd' 2>/dev/null)"
  status_field="$(printf '%s' "$line" | jq -r '.status' 2>/dev/null)"
  if [ "$usd" != "0" ]; then
    bad "г2: usd строки 402 «$usd», ожидался 0"; return 1
  fi
  if [ "$status_field" != "402" ]; then
    bad "г2: status строки «$status_field», ожидался 402"; return 1
  fi
  ok "г2: 402 до запроса, тело с бюджетом, строка полной схемы usd=0"
  return 0
}

branch_д() {
  local cfg="$BARRIER_CFG" data="$BARRIER_DATA" up_dir="$BARRIER_UP_DIR" vars="$BARRIER_VARS"
  local port provider model rid
  port="$(jq -r '.port' "$cfg")"
  provider="$(jq -r '.provider' "$vars")"
  model="$(jq -r '.model' "$vars")"
  # Сбрасываем budget.json: после ветви (г) бюджет СВЫШЕ потолка, и без сброса
  # ветвь (д) получит 402 ещё до попытки сходить к upstream. Нам нужен 502 от
  # МЁРТВОГО upstream, а не 402 от потолка.
  local period
  period="$(date -u +%Y-%m)"
  printf '{"%s":{"%s":0}}\n' "$period" "$provider" > "$data/budget.json"
  rid="$(rnd_label 16)"
  rm -f "$data/calls.jsonl"
  local up_pid
  up_pid="$(cat "$up_dir/stub.pid")"
  kill -- "-$up_pid" 2>/dev/null || kill "$up_pid" 2>/dev/null || true
  local i
  for i in $(seq 1 20); do
    if ! kill -0 "$up_pid" 2>/dev/null; then break; fi
    sleep 0.05
  done
  local resp status
  resp="$(req POST "http://127.0.0.1:${port}/${provider}/chat/completions" \
    "$(jq -r '.token' "$vars")" "$model" "ping" "application/octet-stream" "$rid")"
  status="$(printf '%s\n' "$resp" | head -1)"
  if [ "$status" != "502" ]; then
    bad "д: ожидался 502 при обрыве upstream, получено $status"; return 1
  fi
  if [ ! -s "$data/calls.jsonl" ]; then
    bad "д: журнал пуст — 502 обязан писаться строкой"; return 1
  fi
  local line nkeys status_field tokens_in tokens_out usd
  line="$(head -1 "$data/calls.jsonl")"
  nkeys="$(printf '%s' "$line" | jq -r 'keys | length' 2>/dev/null)"
  if [ "$nkeys" != "11" ]; then
    bad "д: строка журнала $nkeys ключей, ожидалось 11: $line"; return 1
  fi
  tokens_in="$(printf '%s' "$line" | jq -r '.tokens_in' 2>/dev/null)"
  tokens_out="$(printf '%s' "$line" | jq -r '.tokens_out' 2>/dev/null)"
  usd="$(printf '%s' "$line" | jq -r '.usd' 2>/dev/null)"
  status_field="$(printf '%s' "$line" | jq -r '.status' 2>/dev/null)"
  if [ "$status_field" != "502" ]; then
    bad "д: status строки «$status_field», ожидался 502"; return 1
  fi
  if [ "$tokens_in" != "0" ] || [ "$tokens_out" != "0" ] || [ "$usd" != "0" ]; then
    bad "д: tokens/usd не нули: in=$tokens_in out=$tokens_out usd=$usd"; return 1
  fi
  ok "д: 502 при обрыве upstream, строка 11 полей status=502 tokens/usd=0"
  return 0
}

# ── ВЕТВИ (е), (ж), (з), (и) — спасены из клона погибшего исполнителя (рецидив Н-29) ──
branch_е() {
  # (е) — маркер append-only жив после прогона, удалённый budget.json пересобран
  # --rebuild-budget и РАВЕН свёртке журнала (сверка СОДЕРЖИМОГО, не факта
  # существования). Два независимых красных дефекта (по контракту):
  #   1) appendLog через truncate+write → маркер мёртв (--verify-appendonly=1);
  #   2) --rebuild-budget константой → budget.json != fold(calls.jsonl).
  # Здесь ловится дефект (1): маркер обязан выжить и согласоваться с
  # содержимым calls.jsonl на момент проверки.
  local cfg="$BARRIER_CFG" data="$BARRIER_DATA"
  local rc
  # ГРАНИЦА ВРЕМЕНИ ОБЯЗАТЕЛЬНА. Обманная заглушка прокси флагов не знает и на
  # `--verify-appendonly` поднимает СЕРВЕР — вызов не возвращается никогда. Барьер,
  # висящий на заглушке, хуже красного: он не даёт вердикта вовсе, а результат есть
  # код возврата. Измерено 2026-08-20: анти-плацебо встало на
  # `case_a_proxy_up_healthz`, в процессах — `metering_proxy.ts --verify-appendonly`.
  # Истечение границы — ОТКАЗ с названной причиной, а не пропуск.
  local CLI_MAX=20
  timeout "$CLI_MAX" node $PROXY_NODE_FLAGS "$PROXY" --config "$cfg" --verify-appendonly >/dev/null 2>&1
  rc=$?
  if [ "$rc" = "124" ]; then
    bad "е: --verify-appendonly не вернулся за ${CLI_MAX}с — режим не одноразовый (заглушка поднимает сервер)"
    return 1
  fi
  if [ "$rc" != "0" ]; then
    bad "е: --verify-appendonly вернул $rc — маркер мёртв (appendLog не аппендит)"
    return 1
  fi
  # Полная проверка (е): удалённый budget.json пересобран --rebuild-budget и
  # РАВЕН свёртке журнала (сверка СОДЕРЖИМОГО). Здесь ловится второй дефект
  # контракта: --rebuild-budget пишет НЕ из журнала (константой).
  rm -f "$data/budget.json"
  timeout "$CLI_MAX" node $PROXY_NODE_FLAGS "$PROXY" --config "$cfg" --rebuild-budget >/dev/null 2>&1
  rc=$?
  if [ "$rc" = "124" ]; then
    bad "е: --rebuild-budget не вернулся за ${CLI_MAX}с — режим не одноразовый (заглушка поднимает сервер)"
    return 1
  fi
  if [ ! -s "$data/budget.json" ]; then
    bad "е: --rebuild-budget не записал budget.json"; return 1
  fi
  # Ручная свёртка calls.jsonl по (period_at(ts), provider): сумма usd.
  # Прокси сериализует usd в budget.json СТРОКОЙ (BigInt-safe), журнал тоже
  # хранит usd строкой. Сворачиваем в строки, чтобы форматы совпали.
  # НЕЗАВИСИМАЯ свёртка журнала целочисленным оракулом (BigInt): группировка по
  # (periodAt(ts), provider), сумма usd; прокси хранит usd строкой (int64-safe),
  # сворачиваем так же и сверяем ПОБАЙТОВО с budget.json. Пустая свёртка —
  # красное: константный --rebuild-budget пишет {} и «сходится» с пустым
  # ожидаемым (находка адверсария 2026-08-21: сравнения не было вовсе).
  expected="$(node -e '
    const fs=require("node:fs");
    let lines=[];try{lines=fs.readFileSync(process.argv[1],"utf8").split("\n").filter(Boolean)}catch{}
    const b={};
    for(const ln of lines){let r;try{r=JSON.parse(ln)}catch{continue}
      if(r.usd==null||r.ts==null||r.provider==null||!(Number(r.ts)>0))continue;
      const d=new Date(Number(r.ts));
      const per=d.getUTCFullYear()+"-"+String(d.getUTCMonth()+1).padStart(2,"0");
      (b[per]??={})[r.provider]=((b[per][r.provider]?BigInt(b[per][r.provider]):0n)+BigInt(r.usd)).toString();
    }
    const s={};for(const per of Object.keys(b).sort()){s[per]={};for(const pr of Object.keys(b[per]).sort())s[per][pr]=b[per][pr];}
    process.stdout.write(JSON.stringify(s));
  ' "$data/calls.jsonl" 2>/dev/null)"
  actual="$(node -e '
    const fs=require("node:fs");
    let b={};try{b=JSON.parse(fs.readFileSync(process.argv[1],"utf8"))}catch{}
    const s={};for(const per of Object.keys(b).sort()){s[per]={};for(const pr of Object.keys(b[per]).sort())s[per][pr]=String(b[per][pr]);}
    process.stdout.write(JSON.stringify(s));
  ' "$data/budget.json" 2>/dev/null)"
  if [ -z "$expected" ] || [ "$expected" = "{}" ]; then
    bad "е: свёртка calls.jsonl пуста — нечем доказать производность (журнал без usd-строк на момент (е))"; return 1
  fi
  if [ "$expected" != "$actual" ]; then
    bad "е: budget.json после rebuild ≠ свёртке журнала: свёртка=$expected budget=$actual"; return 1
  fi
  ok "е: budget.json после rebuild равен свёртке calls.jsonl (непустой, побайтово)"
}

branch_ж() {
  # (ж) — модель без цены → 503 model_unpriced ДО запроса, upstream НЕ вызван,
  # СТРОКИ НЕТ. Цена смотрится по ПАРЕ (provider, model); другой model_id для
  # того же provider — гарантированно без цены. Два независимых красных дефекта
  # (по контракту): (1) прокси ходит в upstream ДО проверки цены; (2) прокси
  # пишет строку на 503. Здесь ловится дефект (1): upstream-счётчик должен
  # остаться неизменным.
  local cfg="$BARRIER_CFG" data="$BARRIER_DATA" up_dir="$BARRIER_UP_DIR" vars="$BARRIER_VARS"
  local port provider priced_model unpriced_model rid
  port="$(jq -r '.port' "$cfg")"
  provider="$(jq -r '.provider' "$vars")"
  priced_model="$(jq -r '.model' "$vars")"
  # ПОРОЖДАЕМЫЙ неценовой model: случаен и не равен priced_model. С вероятностью
  # 1/36^6 совпадёт — перекатим.
  while :; do
    unpriced_model="$(rnd_label 6)"
    [ "$unpriced_model" != "$priced_model" ] && break
  done
  rid="$(rnd_label 16)"
  local calls_before up_count_before
  calls_before="$(wc -l < "$data/calls.jsonl" 2>/dev/null || echo 0)"
  up_count_before="$(cat "$up_dir/count" 2>/dev/null || echo 0)"
  local resp status
  resp="$(req POST "http://127.0.0.1:${port}/${provider}/chat/completions" \
    "$(jq -r '.token' "$vars")" "$unpriced_model" "anything" \
    "application/octet-stream" "$rid")"
  status="$(printf '%s\n' "$resp" | head -1)"
  if [ "$status" != "503" ]; then
    bad "ж: ожидался 503 на модель без цены, получено $status"
    return 1
  fi
  local up_count_after calls_after
  up_count_after="$(cat "$up_dir/count" 2>/dev/null || echo 0)"
  if [ "$up_count_after" != "$up_count_before" ]; then
    bad "ж: upstream вызван ДО проверки цены (счётчик $up_count_before → $up_count_after)"
    return 1
  fi
  calls_after="$(wc -l < "$data/calls.jsonl" 2>/dev/null || echo 0)"
  if [ "$calls_after" -ne "$calls_before" ]; then
    bad "ж: при 503 строка журнала дописана ($calls_before → $calls_after)"
    return 1
  fi
  ok "ж: 503 на unpriced, upstream не вызван, строки нет"
  return 0
}

branch_з() {
  # (з) — в РЕПОЗИТОРИИ нет буквальных значений секретов: grep шаблона значения
  # секрета по ВСЕМ файлам репозитория (не только конфигам) — пуст. Область
  # важнее порога: скрытые файлы и все расширения включительно. Красный дефект:
  # порождённое значение секрета в ФАЙЛЕ ВНЕ конфигов (например в комментарии
  # скрипта). Тест проверяет grep по $BARRIER_ROOT (репозиторию фикстуры):
  # фикстура подкидывает файл с токеном — ловится здесь.
  local vars="$BARRIER_VARS"
  local token
  token="$(jq -r '.token' "$vars")"
  [ -n "$token" ] || { bad "з: токен пустой в vars.json"; return 1; }
  # Дефолт корня — РЕПОЗИТОРИЙ САМОГО БАРЬЕРА ($SELF_DIR/..), а не cwd (`.`):
  # анти-плацебо копирует барьер в BARRIER_ROOT/scripts/, но НЕ экспортирует
  # BARRIER_ROOT в окружение (ap_run кладёт по нему копию и только). При `:-.`
  # ветвь грепала cwd проверяющего (реальный репозиторий), а не песочницу —
  # красное предъявление становилось невозможным (замер 2026-08-21). Предмет
  # ветви — «в ЭТОМ репозитории нет секретов», и он есть $SELF_DIR/..; явный
  # BARRIER_ROOT (standalone-прогон) по-прежнему главнее.
  local root="${BARRIER_ROOT:-$SELF_DIR/..}"
  root="$(cd "$root" 2>/dev/null && pwd || echo .)"
  # grep -lF: литерал, только имена файлов. Обход через find, а не --include, чтобы
  # попали ВСЕ имена, включая скрытые, и все расширения (область важнее порога).
  #
  # ОБЪЯВЛЕННОЕ ИСКЛЮЧЕНИЕ с причиной: `./tmp/` и `./.git/` из обхода выведены.
  # `tmp/` игнорируется git (`.gitignore:20`), то есть НЕ является содержимым
  # репозитория — это черновик, и туда же по правилу 16 нормы кладёт свою работу САМ
  # барьер. Без исключения ветвь находила собственный порождённый токен в
  # `./tmp/metering.*/secrets.env` и краснела на честном дереве — красное с ложным
  # диагнозом (замер 2026-08-20). Остаточный риск: секрет, положенный в `tmp/`, этой
  # ветвью не ловится; он и не попадёт в историю, потому что каталог игнорируется.
  local hits
  hits="$(cd "$root" && find . -type f -not -path './tmp/*' -not -path './.git/*' \
          -exec grep -lF -- "$token" {} + 2>/dev/null | head -20)"
  if [ -n "$hits" ]; then
    bad "з: буквальное значение секрета найдено в файлах: $(printf '%s' "$hits" | tr '\n' ' ')"
    return 1
  fi
  ok "з: буквальное значение секрета не найдено (обход без ./tmp и ./.git — объявленное исключение)"
  return 0
}

branch_и() {
  # (и) — РОТАЦИЯ в одном живом процессе (тождество pid до и после):
  # собственный файл секретов фикстуры через цепочку --config (реальный дом
  # секретов НЕ трогается); T1 приписан роли R → строка с R сверена; pid жив;
  # секретный файл ПЕРЕЗАПИСАН (T1 удалён, T2 приписан ТОЙ ЖЕ роли R); pid жив;
  # T2 принят → строка с R сверена; T1 повторно даёт 401 и НОВОЙ строки нет.
  # Красный дефект: прокси со СТАРТОВЫМ КЭШЕМ карты токенов — падает на шаге T2.
  local workdir
  workdir="$(dirname "$BARRIER_CFG")"
  local bdir="$workdir/branch_и"
  mkdir -p "$bdir/data"
  # ВЕТВЬ ГЕРМЕТИЧНА: свой файл секретов, свой конфиг, свой data_dir — и СВОЙ upstream.
  # Прежняя редакция поднимала общий $BARRIER_UP_DIR, перезаписывая в нём `port`, но НЕ правя
  # общий конфиг. Дальше _restart_proxy_and_upstream видел живой порт, конфига не чинил, а в
  # конфиге оставался мёртвый порт от ветви (д) — (л) и (м) получали 502. Замер 2026-08-20.
  local up_dir="$bdir/up"
  mkdir -p "$up_dir"
  stub_upstream "$up_dir" >/dev/null
  local stub_port
  stub_port="$(cat "$up_dir/port")"
  local role R T1 T2 secrets bcfg proxy_port provider model
  role="$(rnd_label 8)"
  R="$role"
  T1="$(rnd_label 24)"
  T2="$(rnd_label 24)"
  secrets="$bdir/secrets.env"
  bcfg="$bdir/config.json"
  # Стартовый файл секретов: ОДНА роль R, ОДИН токен T1.
  printf 'METERING_TOKEN_%s=%s\n' "$R" "$T1" > "$secrets"
  proxy_port="$(free_port)"
  provider="$(rnd_label 6)"
  model="$(rnd_label 6)"
  cat > "$bcfg" <<EOF
{
  "port": ${proxy_port},
  "healthz_window_sec": 5,
  "secrets_env": "${secrets}",
  "data_dir": "${bdir}/data",
  "upstream": { "${provider}": "http://127.0.0.1:${stub_port}" },
  "prices": { "${provider}": { "${model}": { "per_m_tokens": { "in": 1000000, "out": 1000000 } } } },
  "ceilings": { "${provider}": { "usd_per_month": 1000000000 } },
  "now_file": null
}
EOF
  local pidfile="$bdir/proxy.pid" pid
  pid="$(proxy_up "$bcfg" "$pidfile")"
  local rid status resp line got_role rows_before rows_after
  # Шаг T1: запрос с T1, ожидаем 200 (прокси знает T1 из secrets).
  rid="$(rnd_label 16)"
  resp="$(req POST "http://127.0.0.1:${proxy_port}/${provider}/chat/completions" \
    "$T1" "$model" "ping" "application/octet-stream" "$rid")"
  status="$(printf '%s\n' "$resp" | head -1)"
  if [ "$status" != "200" ]; then
    proxy_down "$pid"
    bad "и: T1 не принят, status=$status"; return 1
  fi
  # Тождество pid ДО перезаписи секретов.
  if ! kill -0 "$pid" 2>/dev/null; then
    proxy_down "$pid"
    bad "и: pid $pid умер после T1"; return 1
  fi
  line="$(head -1 "$bdir/data/calls.jsonl" 2>/dev/null)"
  got_role="$(jq -r '.role' <<<"$line" 2>/dev/null)"
  if [ "$got_role" != "$R" ]; then
    proxy_down "$pid"
    bad "и: T1 строка role=«$got_role», ожидалась $R"; return 1
  fi
  # Перезапись секретов: T1 удалён, T2 приписан ТОЙ ЖЕ роли R.
  printf 'METERING_TOKEN_%s=%s\n' "$R" "$T2" > "$secrets"
  # Тождество pid ПОСЛЕ перезаписи — процесс пережил правку файла.
  if ! kill -0 "$pid" 2>/dev/null; then
    proxy_down "$pid"
    bad "и: pid $pid умер после перезаписи секретов"; return 1
  fi
  # Шаг T2: запрос с T2, ожидаем 200 — прокси должен прочесть secrets СВЕЖО.
  local rid2
  rid2="$(rnd_label 16)"
  resp="$(req POST "http://127.0.0.1:${proxy_port}/${provider}/chat/completions" \
    "$T2" "$model" "ping" "application/octet-stream" "$rid2")"
  status="$(printf '%s\n' "$resp" | head -1)"
  if [ "$status" != "200" ]; then
    proxy_down "$pid"
    bad "и: T2 не принят, status=$status — стартовый кэш карты токенов?"; return 1
  fi
  if ! kill -0 "$pid" 2>/dev/null; then
    proxy_down "$pid"
    bad "и: pid $pid умер после T2"; return 1
  fi
  line="$(tail -1 "$bdir/data/calls.jsonl" 2>/dev/null)"
  got_role="$(jq -r '.role' <<<"$line" 2>/dev/null)"
  if [ "$got_role" != "$R" ]; then
    proxy_down "$pid"
    bad "и: T2 строка role=«$got_role», ожидалась $R"; return 1
  fi
  # Шаг T1 повторно: ожидаем 401 (T1 уже не в secrets) и ОТСУТСТВИЕ новой строки.
  rows_before="$(wc -l < "$bdir/data/calls.jsonl" 2>/dev/null || echo 0)"
  local rid3
  rid3="$(rnd_label 16)"
  resp="$(req POST "http://127.0.0.1:${proxy_port}/${provider}/chat/completions" \
    "$T1" "$model" "ping" "application/octet-stream" "$rid3")"
  status="$(printf '%s\n' "$resp" | head -1)"
  if [ "$status" != "401" ]; then
    proxy_down "$pid"
    bad "и: T1 повторно не дал 401, status=$status"; return 1
  fi
  rows_after="$(wc -l < "$bdir/data/calls.jsonl" 2>/dev/null || echo 0)"
  if [ "$rows_after" -ne "$rows_before" ]; then
    proxy_down "$pid"
    bad "и: при 401 новая строка ($rows_before → $rows_after)"; return 1
  fi
  # Финальное тождество pid: ОДИН живой процесс от T1 до T1-повтора.
  if ! kill -0 "$pid" 2>/dev/null; then
    proxy_down "$pid"
    bad "и: pid $pid умер к концу прогона"; return 1
  fi
  proxy_down "$pid"
  ok "и: ротация в одном pid: T1→T2→401, role=$R"
  return 0
}
_assert_enforcement() {
  # Рантайм-энфорсмент ЖИВ у судимого прокси? (арбитраж f175567). Молчаливое выпадение
  # флагов из proxy_up вернёт дыру k1/k2 незаметно — сверяем /proc/<pid>/cmdline реально
  # запущенного прокси на оба флага. Проба самодостаточна (свой cfg/порт); temp под $work,
  # чтобы kill_all_proxies поймал её при обрыве.
  local who="$1" base w cfg pid cmdline
  base="${BARRIER_DATA%/data}"; [ -d "$base" ] || base="$TMP_ROOT"
  w="$(mktemp -d -p "$base" enfXXXXXX)"
  cfg="$(gen_config "$w")"
  pid="$(proxy_up "$cfg" "$w/proxy.pid")" || { rm -rf "$w"; bad "$who: прокси не встал для сверки энфорсмента"; return 1; }
  cmdline="$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null)"
  proxy_down "$pid"; rm -rf "$w"
  case "$cmdline" in
    *--disallow-code-generation-from-strings*) ;;
    *) bad "$who: судимый прокси БЕЗ --disallow-code-generation-from-strings — энфорсмент выпал: $cmdline"; return 1 ;;
  esac
  case "$cmdline" in
    *--permission*) ;;
    *) bad "$who: судимый прокси БЕЗ --permission — энфорсмент выпал: $cmdline"; return 1 ;;
  esac
  return 0
}

branch_к1() {
  # (к1) builtins-only, ЗАГРУЗКА МОДУЛЕЙ. Честный прокси грузит ТОЛЬКО статическим
  # `import ... from 'node:...'`. Любая иная форма — красное, включая динамические
  # и рефлексивные: адверсарий обошёл literal-grep через `import('file://'+x)` и
  # `process.getBuiltinModule` (замер 2026-08-21). Запрещены: статический import из
  # не-node:, динамический `import(`, `require`/`createRequire`, `getBuiltinModule`.
  local src="${1:-$PROXY}"
  [ -f "$src" ] || { bad "к1: исходник прокси не найден: $src"; return 1; }
  local bad_forms=""
  local stat
  stat="$(grep -nE "(^|[[:space:]])import[[:space:]]+.+from[[:space:]]+['\"][^'\"]+['\"]" "$src" \
          | grep -vE "from[[:space:]]+['\"]node:" || true)"
  [ -n "$stat" ] && bad_forms="${bad_forms}статический-import-вне-node ($(printf '%s' "$stat" | head -1)); "
  grep -qE "import[[:space:]]*(/\*[^*]*\*/[[:space:]]*)*\(" "$src" && bad_forms="${bad_forms}динамический-import(); "
  grep -qE "(^|[^.[:alnum:]])require[[:space:]]*\(|createRequire" "$src" && bad_forms="${bad_forms}require; "
  grep -qE "getBuiltinModule" "$src" && bad_forms="${bad_forms}getBuiltinModule; "
  grep -qE "node:vm|runInThisContext" "$src" && bad_forms="${bad_forms}node:vm; "
  if [ -n "$bad_forms" ]; then
    bad "к1: загрузка модулей вне статического node:-import в $src → ${bad_forms%; }"
    return 1
  fi
  _assert_enforcement к1 || return 1
  ok "к1: только статические node:-импорты в $src"
  return 0
}

branch_к2() {
  # (к2) builtins-only, ПРОЦЕССЫ. Честный прокси НЕ порождает внешних процессов и
  # не трогает child_process. Любой канал к порождению — красное, включая
  # вычисляемые формы: адверсарий обошёл literal-grep через
  # runner['exec'+'FileSync'] и getBuiltinModule('node:'+'child_process') (замер
  # 2026-08-21) — но строка «child_process» в исходнике при этом ОБЯЗАНА быть.
  # Запрещены: модуль child_process (в любой форме), process.binding, вызовы
  # exec*/spawn*/fork( с первым СТРОКОВЫМ аргументом не «node».
  local src="${1:-$PROXY}"
  [ -f "$src" ] || { bad "к2: исходник прокси не найден: $src"; return 1; }
  local bad_forms=""
  grep -qE "child_process" "$src" && bad_forms="${bad_forms}child_process; "
  grep -qE "process\.binding" "$src" && bad_forms="${bad_forms}process.binding; "
  local hits line first_arg
  hits="$(grep -nE "(execFile|exec|spawnSync|spawn|fork)[[:space:]]*\(" "$src" || true)"
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    first_arg="$(printf '%s' "$line" | sed -nE "s/.*\([[:space:]]*['\"]([^'\"]+)['\"].*/\1/p" | head -1)"
    [ -z "$first_arg" ] && continue
    [ "$first_arg" = "node" ] && continue
    bad_forms="${bad_forms}процесс:${first_arg}; "
  done <<< "$hits"
  if [ -n "$bad_forms" ]; then
    bad "к2: child_process / внешние процессы в $src → ${bad_forms%; }"
    return 1
  fi
  _assert_enforcement к2 || return 1
  ok "к2: child_process и внешних процессов в $src нет"
  return 0
}

# _restart_proxy_and_upstream — перезапустить ПРОКСИ с обновлённым cfg и ПОДНЯТЬ upstream,
# если (д) его убил. Каждой под-ветви (л) нужно: (1) изменить cfg (now_file / новый провайдер /
# int64-тариф) и (2) иметь живой upstream, потому что прокси при старте закрывает cfg в
# замыкании — runtime-правка JSON прокси НЕ увидит. Помощник делает оба.
_restart_proxy_and_upstream() {
  local cfg="$BARRIER_CFG" data="$BARRIER_DATA" up_dir="$BARRIER_UP_DIR" vars="$BARRIER_VARS"
  local pidfile="$data/proxy.pid"
  # 1. Гасим прокси, если жив.
  if [ -f "$pidfile" ]; then
    local ppid; ppid="$(cat "$pidfile")"
    [ -n "$ppid" ] && {
      kill -- "-$ppid" 2>/dev/null || kill "$ppid" 2>/dev/null || true
      local j
      for j in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
        kill -0 "$ppid" 2>/dev/null || break
        sleep 0.05
      done
    }
    rm -f "$pidfile"
  fi
  # 2. Поднимаем upstream заново, если (д) его убил.
  if [ -d "$up_dir" ] && [ -f "$up_dir/port" ]; then
    local oldport; oldport="$(cat "$up_dir/port" 2>/dev/null || echo "")"
    if [ -n "$oldport" ] && ! ss -ltn 2>/dev/null | awk '{print $4}' | grep -qE ":${oldport}\$"; then
      local old_pid_file="$up_dir/stub.pid"
      if [ -f "$old_pid_file" ]; then
        local op; op="$(cat "$old_pid_file")"
        [ -n "$op" ] && kill -- "-$op" 2>/dev/null || kill "$op" 2>/dev/null || true
      fi
      stub_upstream "$up_dir" >/dev/null
      local new_port; new_port="$(cat "$up_dir/port")"
      # МИГАНИЕ (л.о), замер 2026-08-20: прежняя правка обновляла upstream-URL только
      # у ПЕРВОГО провайдера, а (л.о) копирует URL второму ДО перезапуска — стаб умирал,
      # перезапуск поднимал его на новом порту, p1 переезжал, p2 оставался на мёртвом:
      # 502 → usd P2=0 в ~8 прогонах из 10. Переезжают ВСЕ провайдеры со старым URL.
      local tmpc; tmpc="$(mktemp -p "$TMP_ROOT")"
      jq --arg old "http://127.0.0.1:${oldport}" --arg new "http://127.0.0.1:${new_port}" \
         '.upstream |= with_entries(.value = (if .value == $old then $new else .value end))' \
         "$cfg" > "$tmpc" && mv "$tmpc" "$cfg"
    fi
  fi
  # 3. Сбросим budget.json — он мог накопиться из предыдущих ветвей.
  rm -f "$data/budget.json"
  # 4. Поднимаем прокси.
  proxy_up "$cfg" "$pidfile" >/dev/null
}

branch_л() {
  # (л) — ТРИ отдельных проверки на честном прокси: каждая — своя красная фикстура.
  #   (л.п) период на каждом запросе через инъекцию now_file;
  #   (л.о) две оси тарифа — два провайдера с одной моделью, цены и потолки разные;
  #   (л.i) int64 > 2^53 — usd в строке журнала точен как текст.
  local cfg="$BARRIER_CFG" data="$BARRIER_DATA" up_dir="$BARRIER_UP_DIR" vars="$BARRIER_VARS"
  local port provider model token
  port="$(jq -r '.port' "$cfg")"
  provider="$(jq -r '.provider' "$vars")"
  model="$(jq -r '.model' "$vars")"
  token="$(jq -r '.token' "$vars")"

  # ── (л.п) период на каждом запросе — ОДИН процесс, два вызова, разные UTC-месяца ─
  # ТРИ дефекта прежней редакции, все измерены архитектором 2026-08-20:
  #  1. `Date.UTC(2026,1,0)` — это 31 ЯНВАРЯ (день 0 = последний день предыдущего месяца),
  #     оба времени попадали в 2026-01, и подветвь не проверяла ничего: прогон печатал
  #     «периоды различаются: false»;
  #  2. `rm -f calls.jsonl` МЕЖДУ вызовами, а затем требование «≥ 2 строк» — недостижимо;
  #  3. ГЛАВНОЕ: три вызова _restart_proxy_and_upstream. Перезапущенный прокси перечитывает
  #     период на старте, поэтому стаб С КЭШЕМ периода прошёл бы эту подветвь. Проверка не
  #     различала предмет (класс Н-40). Теперь конфиг готовится ОДИН раз ДО запуска, между
  #     вызовами меняется ТОЛЬКО now_file, и тождество pid УТВЕРЖДАЕТСЯ.
  local t_jan t_feb now_file="$data/now.txt"
  t_jan="$(node -e 'process.stdout.write(String(Date.UTC(2026, 0, 31, 23, 59, 59, 999)))')"
  t_feb="$(node -e 'process.stdout.write(String(Date.UTC(2026, 1, 1, 0, 0, 0, 0)))')"
  # Потолок НЕ меняется между вызовами. Бюджет периода 2026-01 предзаполнен ровно потолком —
  # значит январь исчерпан, а февраль пуст. Так один и тот же конфиг даёт 402 в январе и
  # 200 в феврале, и различает их ТОЛЬКО перечитанный период.
  local ceil_l; ceil_l="$(jq -r --arg p "$provider" '.ceilings[$p].usd_per_month' "$cfg")"
  local tmpc; tmpc="$(mktemp -p "$data")"
  jq --arg nf "$now_file" '.now_file = $nf' "$cfg" > "$tmpc" && mv "$tmpc" "$cfg"
  mkdir -p "$data"
  printf '%s' "$t_jan" > "$now_file"
  _restart_proxy_and_upstream
  printf '{"2026-01":{"%s":%s}}\n' "$provider" "$ceil_l" > "$data/budget.json"
  local pid_before; pid_before="$(cat "$data/proxy.pid" 2>/dev/null || echo "")"
  [ -n "$pid_before" ] || { bad "л.п: pid прокси не прочитан — тождество процесса недоказуемо"; return 1; }
  # Журнал НЕ удаляем: в нём строки предыдущих ветвей. Считаем ПРИРОСТ.
  local lines_before; lines_before="$(wc -l < "$data/calls.jsonl" 2>/dev/null | tr -d ' ')"
  [ -n "$lines_before" ] || lines_before=0
  cat > "$up_dir/scenario.json" <<EOF
{"status":200,"content_type":"application/octet-stream","body_b64":"$(printf 'ok-jan' | base64 -w0)","headers":{"x-usage-tokens-in":"1000000","x-usage-tokens-out":"0"}}
EOF
  local r1 body1
  r1="$(req POST "http://127.0.0.1:${port}/${provider}/chat/completions" \
        "$token" "$model" "ping-jan" "application/octet-stream" "$(rnd_label 8)")"
  body1="${r1##*__BODY__}"
  # МЕЖДУ ВЫЗОВАМИ МЕНЯЕТСЯ ТОЛЬКО ВРЕМЯ. Ни конфига, ни перезапуска.
  printf '%s' "$t_feb" > "$now_file"
  local r2 s2
  r2="$(req POST "http://127.0.0.1:${port}/${provider}/chat/completions" \
        "$token" "$model" "ping-feb" "application/octet-stream" "$(rnd_label 8)")"
  s2="$(printf '%s\n' "$r2" | head -1)"
  local pid_after; pid_after="$(cat "$data/proxy.pid" 2>/dev/null || echo "")"
  if [ "$pid_before" != "$pid_after" ] || ! kill -0 "$pid_before" 2>/dev/null; then
    bad "л.п: процесс не тот же — pid до $pid_before, после $pid_after; перезапуск обесценивает проверку кэша"; return 1
  fi
  local s1; s1="$(printf '%s' "$body1" | jq -r '.error // empty' 2>/dev/null)"
  if [ "$s1" != "ceiling_exceeded" ]; then
    bad "л.п: первый вызов в 2026-01 не вернул ceiling_exceeded, тело: $body1"; return 1
  fi
  if [ "$s2" != "200" ]; then
    bad "л.п: второй вызов в 2026-02 не прошёл, код $s2 — период не перечитан"; return 1
  fi
  local lines_after grew
  lines_after="$(wc -l < "$data/calls.jsonl" 2>/dev/null | tr -d ' ')"
  grew=$(( lines_after - lines_before ))
  if [ "$grew" -ne 2 ]; then
    bad "л.п: журнал вырос на $grew строк, ожидалось ровно 2 (402 января пишется, 200 февраля пишется)"; return 1
  fi
  local ts1 ts2 period1 period2
  ts1="$(tail -2 "$data/calls.jsonl" | head -1 | sed -nE 's/.*"ts":([0-9]+).*/\1/p')"
  ts2="$(tail -1 "$data/calls.jsonl" | sed -nE 's/.*"ts":([0-9]+).*/\1/p')"
  period1="$(node -e "process.stdout.write(new Date(parseInt('$ts1',10)).toISOString().slice(0,7))")"
  period2="$(node -e "process.stdout.write(new Date(parseInt('$ts2',10)).toISOString().slice(0,7))")"
  if [ "$period1" != "2026-01" ] || [ "$period2" != "2026-02" ]; then
    bad "л.п: периоды в строках $period1/$period2, ожидались 2026-01/2026-02 — кэш периода на старте"; return 1
  fi
  ok "л.п: 2026-01 и 2026-02 различимы в ОДНОМ живом процессе (pid $pid_before до и после)"

  # ── (л.о) две оси тарифа — два провайдера с одной моделью ──────────────────
  local p2 in1 in2
  p2="$(rnd_label 7)"
  # КОНТРАКТ (л.о): ДВА provider с ОДНОЙ model — при разных моделях стаб «цена
  # только по model» неотличим от честного на этом входе (класс Н-39). Прежняя
  # редакция брала порождённую m2 — дефект реализации, зелёный прогон не ловил.
  in1=1200000; in2=2400000
  local ceil_p1=50000000 ceil_p2=30000000
  tmpc="$(mktemp -p "$TMP_ROOT")"
  jq --arg p1 "$provider" --arg p2 "$p2" --arg m "$model" \
     --argjson in1 "$in1" --argjson in2 "$in2" \
     --argjson c1 "$ceil_p1" --argjson c2 "$ceil_p2" \
     '.upstream[$p2] = .upstream[$p1]
      | .prices[$p2] = { ($m): { per_m_tokens: { in: $in2, out: 6800000 } } }
      | .prices[$p1][$m].per_m_tokens.in = $in1
      | .prices[$p1][$m].per_m_tokens.out = 3400000
      | .ceilings[$p1].usd_per_month = $c1
      | .ceilings[$p2].usd_per_month = $c2' "$cfg" > "$tmpc" && mv "$tmpc" "$cfg"
  _restart_proxy_and_upstream
  rm -f "$data/calls.jsonl" "$data/budget.json" "$up_dir/requests.jsonl" "$up_dir/count"
  cat > "$up_dir/scenario.json" <<EOF
{"status":200,"content_type":"application/octet-stream","body_b64":"$(printf 'ok' | base64 -w0)","headers":{"x-usage-tokens-in":"1000000","x-usage-tokens-out":"0"}}
EOF
  local rp1 rp2 line_p1 line_p2 usd_p1 usd_p2 prov_p2
  rp1="$(req POST "http://127.0.0.1:${port}/${provider}/chat/completions" \
         "$token" "$model" "ping-p1" "application/octet-stream" "$(rnd_label 8)")"
  rp2="$(req POST "http://127.0.0.1:${port}/${p2}/chat/completions" \
         "$token" "$model" "ping-p2" "application/octet-stream" "$(rnd_label 8)")"
  line_p1="$(head -1 "$data/calls.jsonl" 2>/dev/null || true)"
  line_p2="$(tail -1 "$data/calls.jsonl" 2>/dev/null || true)"
  usd_p1="$(printf '%s' "$line_p1" | sed -nE 's/.*"usd":"([0-9]+)".*/\1/p')"
  usd_p2="$(printf '%s' "$line_p2" | sed -nE 's/.*"usd":"([0-9]+)".*/\1/p')"
  prov_p2="$(printf '%s' "$line_p2" | sed -nE 's/.*"provider":"([^"]+)".*/\1/p')"
  if [ "$usd_p1" != "$in1" ]; then
    bad "л.о: usd P1=$usd_p1, ожидался $in1"; return 1
  fi
  if [ "$usd_p2" != "$in2" ]; then
    bad "л.о: usd P2=$usd_p2, ожидался $in2"; return 1
  fi
  if [ "$prov_p2" != "$p2" ]; then
    bad "л.о: provider последней строки=$prov_p2, ожидался $p2"; return 1
  fi
  ok "л.о: usd P1=$usd_p1 и P2=$usd_p2 — разные тарифы по разным провайдерам одной модели"

  # ── (л.i) int64 — ДВА вектора > 2^53 с РАЗНЫМ порождённым tokensIn ────────────
  # Фиксированный ti=1e9 позволял стабу зашить развилку РОВНО на вход теста и быть
  # честным на нём (адверсарий 2026-08-21, вердикт 4a45e61, класс Н-39/40). Теперь и
  # tokensIn, и тариф случайны: спец-кейс под пару (ti, тариф) невозможен. Каждая пара
  # порождается петлёй до точного условия различимости exp(BigInt) ≠ dbl(double) —
  # ожидаемое даёт независимый целочисленный оракул, различимость от double — второй флаг (Н-40).
  _li_check_vector() {  # <номер> <tokensIn> <тариф-строка>
    local n="$1" ti="$2" rate="$3" exp dbl usd_str line_i ri tmpv
    exp="$(node -e 'process.stdout.write(((BigInt(process.argv[1])*BigInt(process.argv[2])+999999n)/1000000n).toString())' "$ti" "$rate")"
    dbl="$(node -e 'process.stdout.write(String(Math.ceil(Number(process.argv[1])*Number(process.argv[2])/1e6)))' "$ti" "$rate")"
    if [ "$exp" = "$dbl" ]; then
      bad "л.i: вектор $n (ti=$ti тариф=$rate) не различает предмет — точное совпало с double ($exp)"; return 1
    fi
    tmpv="$(mktemp -p "$data")"
    jq --arg p "$provider" --arg m "$model" --arg hi "$rate" \
       '.prices[$p][$m].per_m_tokens.in = $hi | .prices[$p][$m].per_m_tokens.out = "0"' \
       "$cfg" > "$tmpv" && mv "$tmpv" "$cfg"
    _restart_proxy_and_upstream
    rm -f "$data/calls.jsonl" "$up_dir/requests.jsonl" "$up_dir/count"
    cat > "$up_dir/scenario.json" <<EOF
{"status":200,"content_type":"application/octet-stream","body_b64":"$(printf 'ok' | base64 -w0)","headers":{"x-usage-tokens-in":"${ti}","x-usage-tokens-out":"0"}}
EOF
    ri="$(req POST "http://127.0.0.1:${port}/${provider}/chat/completions" \
          "$token" "$model" "ping-int$n" "application/octet-stream" "$(rnd_label 8)")"
    line_i="$(head -1 "$data/calls.jsonl" 2>/dev/null || true)"
    usd_str="$(printf '%s' "$line_i" | sed -nE 's/.*"usd":"([0-9]+)".*/\1/p')"
    if [ -z "$usd_str" ]; then bad "л.i: вектор $n — строка журнала без usd: «$line_i»"; return 1; fi
    if [ "$usd_str" != "$exp" ]; then
      bad "л.i: вектор $n usd=«$usd_str», точное «$exp» (double дал бы «$dbl») — int64 не сохранён"; return 1
    fi
    if [ "$usd_str" = "$dbl" ]; then
      bad "л.i: вектор $n usd совпал с double «$dbl» — точность потеряна"; return 1
    fi
    return 0
  }
  local ti1 rate1 ti2 rate2 pair1 pair2
  pair1="$(node -e 'const B=BigInt(process.argv[1]);const E=(t,r)=>((t*r+999999n)/1000000n).toString();const D=(t,r)=>String(Math.ceil(Number(t)*Number(r)/1e6));let t,r;do{t=BigInt(100000000+Math.floor(Math.random()*1900000000));r=B+BigInt(Math.floor(Math.random()*100000)*2)}while(E(t,r)===D(t,r));process.stdout.write(t.toString()+" "+r.toString())' 9007199254740993)"
  pair2="$(node -e 'const B=BigInt(process.argv[1]);const E=(t,r)=>((t*r+999999n)/1000000n).toString();const D=(t,r)=>String(Math.ceil(Number(t)*Number(r)/1e6));let t,r;do{t=BigInt(100000000+Math.floor(Math.random()*1900000000));r=B+BigInt(Math.floor(Math.random()*100000)*2)}while(E(t,r)===D(t,r));process.stdout.write(t.toString()+" "+r.toString())' 9500000000000001)"
  read -r ti1 rate1 <<< "$pair1"
  read -r ti2 rate2 <<< "$pair2"
  _li_check_vector 1 "$ti1" "$rate1" || return 1
  _li_check_vector 2 "$ti2" "$rate2" || return 1
  ok "л.i: два вектора >2^53 (ti=$ti1/$rate1, ti=$ti2/$rate2) точны и отличимы от double"
  return 0
}

branch_м() {
  # (м) ЗАГОЛОВОК ЖИВОГО ВЫЗОВА — ЗАМЕР автора при исполнении: доносит ли клиентский канал
  # `x-request-id` до upstream. Сценарий default-режима: поднимаем прокси (если (д) его убил),
  # посылаем запрос через `req` (тот же клиентский канал, что живой omp: Bearer + x-metering-model
  # + x-request-id + content-type). Проверяем: x-request-id дошёл до upstream ДОСЛОВНО И
  # записан в calls.jsonl request_id. Это замер поведения proxy-канала; замер живой сессии omp
  # — отдельный механизм, живёт в --live (каркас этого режима дописывает соседний агент).
  _restart_proxy_and_upstream
  local cfg="$BARRIER_CFG" data="$BARRIER_DATA" up_dir="$BARRIER_UP_DIR" vars="$BARRIER_VARS"
  local port provider model token
  port="$(jq -r '.port' "$cfg")"
  provider="$(jq -r '.provider' "$vars")"
  model="$(jq -r '.model' "$vars")"
  token="$(jq -r '.token' "$vars")"
  local rid
  rid="$(rnd_label 32)"
  rm -f "$data/calls.jsonl" "$up_dir/requests.jsonl" "$up_dir/count" "$data/budget.json"
  cat > "$up_dir/scenario.json" <<EOF
{"status":200,"content_type":"application/octet-stream","body_b64":"$(printf 'ok-m' | base64 -w0)","headers":{"x-usage-tokens-in":"1000000","x-usage-tokens-out":"0"}}
EOF
  local r s
  r="$(req POST "http://127.0.0.1:${port}/${provider}/chat/completions" \
        "$token" "$model" "body-for-m" "application/octet-stream" "$rid")"
  s="$(printf '%s\n' "$r" | head -1)"
  if [ "$s" != "200" ]; then
    bad "м: ожидался 200 от прокси, получено $s"; return 1
  fi
  if [ ! -s "$up_dir/requests.jsonl" ]; then
    bad "м: upstream не получил запрос"; return 1
  fi
  local up_rid
  up_rid="$(head -1 "$up_dir/requests.jsonl" | sed -nE 's/.*"request_id":"([^"]*)".*/\1/p')"
  if [ "$up_rid" != "$rid" ]; then
    bad "м: upstream x-request-id «$up_rid», ожидался «$rid» — прокси не донёс заголовок"; return 1
  fi
  if [ ! -s "$data/calls.jsonl" ]; then
    bad "м: журнал пуст — вызов не записан"; return 1
  fi
  local jrn_rid
  jrn_rid="$(head -1 "$data/calls.jsonl" | sed -nE 's/.*"request_id":"([^"]*)".*/\1/p')"
  if [ "$jrn_rid" != "$rid" ]; then
    bad "м: в строке журнала request_id «$jrn_rid», ожидался «$rid»"; return 1
  fi
  ok "м: x-request-id прошёл client→upstream и в журнал дословно"
  return 0
}
# ── main ──────────────────────────────────────────────────────────────────────
main() {
  local work
  work="$(mktemp -d "$TMP_ROOT/metering.XXXXXX")"
  export HOME="$work"
  mkdir -p "$work/data"
  local up_dir="$work/up"
  local cfg vars
  cfg="$(gen_config "$work")"
  vars="$work/vars.json"
  local stub_port
  stub_upstream "$up_dir" >/dev/null
  stub_port="$(cat "$up_dir/port")"
  local provider cfg_up tmp
  provider="$(jq -r '.provider' "$vars")"
  cfg_up="http://127.0.0.1:${stub_port}"
  tmp="$(mktemp -p "$TMP_ROOT")"
  jq --arg u "$cfg_up" ".upstream[\"$provider\"] = \$u" "$cfg" > "$tmp"
  mv "$tmp" "$cfg"
  export BARRIER_UP_DIR="$up_dir" BARRIER_CFG="$cfg" BARRIER_DATA="$work/data" BARRIER_VARS="$vars"

  local proxy_pid
  proxy_pid="$(proxy_up "$cfg" "$work/data/proxy.pid")"
  # ВЫХОД ГАСИТ ВСЁ, ЧТО ПОДНЯЛ. Ветви (и) и (л) поднимают СВОИ прокси со своими
  # pid-файлами, и прежняя ловушка их не знала: после прогонов в системе оставалось
  # 21 осиротевший процесс с конфигами в /tmp (замер 2026-08-20). Гасим по ВСЕМ
  # pid-файлам под $work, а не только по тому, что помнит main.
  kill_all_proxies() {
    local root="${1:-}" f p
    [ -n "$root" ] || return 0
    # Проход по pid-файлам — только если каталог ещё существует.
    if [ -d "$root" ]; then
      while IFS= read -r f; do
        [ -n "$f" ] || continue
        p="$(cat "$f" 2>/dev/null)"
        [ -n "$p" ] || continue
        kill -- "-$p" 2>/dev/null || kill "$p" 2>/dev/null || true
      done < <(find "$root" -type f -name '*.pid' 2>/dev/null)
    fi
    # Второй проход идёт ВСЕГДА, даже когда каталога уже нет: на зелёном пути main
    # удаляет $work ДО выхода, и прежний охранник `[ -d "$root" ] || return 0` выходил
    # досрочно — процесс перезапущенного прокси оставался жив, а его pid-файл исчезал
    # вместе с каталогом (замер 2026-08-20: один живой прокси после зелёного прогона).
    # Шаблоны СТРОГО с путём своего каталога: чужие прогоны и клоны не трогаются.
    # Прокси — по `--config $root`; стаб — по argv-маркеру `metering-stub-upstream`
    # с $dir под $root (env DIR в argv pkill не виден, оттого стаб тёк — замер
    # 2026-08-21: $work удалён ДО trap, первый проход по pid-файлам находил пусто).
    pkill -f "metering_proxy.ts --config $root" 2>/dev/null || true
    pkill -f "metering-stub-upstream $root" 2>/dev/null || true
  }
  # Каталог подставляется В МОМЕНТ ОБЪЯВЛЕНИЯ ловушки: $work — локальная переменная
  # main, и к моменту EXIT её уже нет. Прежняя редакция читала её внутри функции и
  # падала с «work: unbound variable», а гашение не доходило до конца (замер 2026-08-20).
  trap "kill_all_proxies '$work'; proxy_down $proxy_pid; rm -rf '$work'" EXIT

  # СПИСОК ВЕТВЕЙ ОБЪЯВЛЕН ОДНИМ МЕСТОМ и сверяется по числу: контракт обещает 15.
  # Расхождение счёта — отказ, а не молчаливый прогон подмножества (самопроверка счёта).
  local -a BRANCHES=(а б в в2 г г2 д е ж з и к1 к2 л м)
  if [ "${#BRANCHES[@]}" -ne 15 ]; then
    printf 'ОТКАЗ: объявлено ветвей %d, контракт обещает 15\n' "${#BRANCHES[@]}" >&2
    exit 1
  fi
  # ОТСУТСТВИЕ ВЕТВИ — НЕ ЗЕЛЁНОЕ. Прежняя редакция держала заглушки `return 0`, и барьер
  # печатал «барьер зелёный» с кодом 0 при ЧЕТЫРЁХ нереализованных ветвях (замер 2026-08-20).
  # Норма: нереализованное возвращает 2 и NOT_IMPLEMENTED, а не 0.
  local notimpl=0 missing=""
  local br
  for br in "${BRANCHES[@]}"; do
    if ! declare -F "branch_${br}" >/dev/null 2>&1; then
      printf 'NOT_IMPLEMENTED: ветвь (%s) не реализована\n' "$br" >&2
      notimpl=$((notimpl + 1)); missing="${missing}${br} "
      continue
    fi
    branch "$br" "branch_${br}"
  done

  proxy_down "$proxy_pid"
  if [ "$fails" -gt 0 ]; then
    printf '\nрасхождений: %d · прогон оставлен в %s\n' "$fails" "$work" >&2
    exit 1
  fi
  if [ "$notimpl" -gt 0 ]; then
    printf '\nNOT_IMPLEMENTED: реализовано %d ветвей из 15, не реализованы: %s\n' \
      "$((15 - notimpl))" "${missing% }" >&2
    exit 2
  fi
  printf '\nбарьер зелёный: 15 ветвей пройдены\n' >&2
  rm -rf "$work"
}

# ════════════════════════════════════════════════════════════════════════════
# Режим --cold-start (критерий 4 контракта 005)
# ════════════════════════════════════════════════════════════════════════════
#
# ПЯТЬ исходов проверяются барьером последовательно. Каждый — отдельный
# под-прогон с собственным конфигом, своим состоянием proxy/upstream и
# замером настенного времени вызова лаунчера. КОД ВОЗВРАТА барьера 0 — все
# пять прошли; 1 — хотя бы один отказ с НАЗВАННОЙ причиной.
#
# Лаунчер — `workshop --check-metering` из PATH или $METERING_WORKSHOP.
# Внутри под-прогонов export HOME=$work — workshop пишет pid-файл
# $work/.config/dev-harness/proxy.pid, прокси кладёт state в $work/data.
# РЕАЛЬНЫЙ ~/.config/dev-harness НЕ ЧИТАЕТСЯ.

W_HEALTHZ=5     # окно ожидания лаунчера, ИЗ КОНФИГА
W_PROBE=15      # внешняя граница фикстуры, строго больше внутреннего

# run_workshop <launcher> <cfg> <err_file> — запуск лаунчера, выставляет
# WS_RC, WS_DURATION_MS, WS_STDERR. СЕКУНДОМЕР — наносекунды `date +%s%N`,
# потому что W_probe в секундах, а разница с W_healthz — доли секунды.
WS_RC=0; WS_DURATION_MS=0; WS_STDERR=""
run_workshop() {
  local launcher="$1" cfg="$2" errf="$3"
  local start_ns end_ns
  start_ns=$(date +%s%N)
  "$launcher" --check-metering --config "$cfg" 2>"$errf"
  WS_RC=$?
  end_ns=$(date +%s%N)
  WS_DURATION_MS=$(( (end_ns - start_ns) / 1000000 ))
  WS_STDERR="$(cat "$errf")"
}

# gen_cold_config <work> <port> <hw> <name> — сгенерировать валидный JSON
# конфиг для cold-start-под-прогона. provider/model/тариф/потолок НЕ нужны —
# прокси не получает вызовы, только healthz. Чтобы не было ложного срабатывания
# на «прокси не поднят» в (д)-ветвях предыдущего прогона, имена провайдеров
# порождаются. secrets_env и data_dir — ВНУТРИ work.
gen_cold_config() {
  local work="$1" port="$2" hw="$3" name="$4"
  local provider model
  provider="$(rnd_label 6)"
  model="$(rnd_label 6)"
  mkdir -p "$work/data_$name"
  cat > "$work/secrets_$name.env" <<EOF
METERING_TOKEN_${provider}=$(rnd_label 24)
EOF
  cat > "$work/cfg_$name.json" <<EOF
{
  "port": $port,
  "healthz_window_sec": $hw,
  "secrets_env": "$work/secrets_$name.env",
  "data_dir": "$work/data_$name",
  "upstream": { "${provider}": "http://127.0.0.1:1" },
  "prices": { "${provider}": { "${model}": { "per_m_tokens": { "in": 1000, "out": 2000 } } } },
  "ceilings": { "${provider}": { "usd_per_month": 1000000000 } },
  "now_file": null
}
EOF
  printf '%s\n' "$work/cfg_$name.json"
}

# coldstart_1 — kill по pid-файлу → workshop --check-metering → healthz
# отвечает, новый pid в pid-файле живой. Это ВЕСЬ цикл лаунчера: предыдущая
# сессия оставила процесс, мы его снимаем, лаунчер стартует заново. pid-файл
# в $work/.config/dev-harness/proxy.pid — путь задан контрактом 005 §6.
coldstart_1() {
  local launcher="$1" work="$2"
  local cfg port pidfile errf
  port="$(free_port)"
  cfg="$(gen_cold_config "$work" "$port" 3 "c1")"
  pidfile="$work/.config/dev-harness/proxy.pid"
  mkdir -p "$work/.config/dev-harness"
  errf="$work/c1.err"

  # 1. Поднимаем ПРОКСИ вручную и пишем pid в pid-файл. Это «предыдущая сессия».
  "$PROXY" --config "$cfg" >"$work/c1.proxy.log" 2>&1 &
  local orig_pid=$!
  echo "$orig_pid" > "$pidfile"
  # Ждём healthz — прокси отвечает 200.
  local i
  for i in $(seq 1 60); do
    if curl -fsS -o /dev/null -m 0.5 "http://127.0.0.1:${port}/healthz" 2>/dev/null; then
      break
    fi
    sleep 0.05
  done
  if ! kill -0 "$orig_pid" 2>/dev/null; then
    bad "cold-1: ручной прокси погиб до старта — лог: $work/c1.proxy.log"
    return 1
  fi

  # 2. «kill по pid-файлу» — читаем pid, гасим, ждём.
  local pid_in_file
  pid_in_file="$(cat "$pidfile")"
  kill -TERM "$pid_in_file" 2>/dev/null || true
  for i in $(seq 1 20); do
    kill -0 "$pid_in_file" 2>/dev/null || break
    sleep 0.05
  done
  if kill -0 "$pid_in_file" 2>/dev/null; then
    kill -KILL "$pid_in_file" 2>/dev/null || true
  fi

  # 3. workshop --check-metering: healthz молчит → spawn нового → 0.
  run_workshop "$launcher" "$cfg" "$errf"
  if [ "$WS_RC" != "0" ]; then
    bad "cold-1: workshop вернул $WS_RC, ожидался 0 (stderr: $WS_STDERR)"
    return 1
  fi
  # 4. В pid-файле — НОВЫЙ живой pid, healthz на настроенном порту отвечает 200.
  local new_pid
  new_pid="$(cat "$pidfile" 2>/dev/null || true)"
  if [ -z "$new_pid" ] || ! kill -0 "$new_pid" 2>/dev/null; then
    bad "cold-1: pid-файл $pidfile не содержит живого pid после workshop"
    return 1
  fi
  if ! curl -fsS -o /dev/null -m 2 "http://127.0.0.1:${port}/healthz" 2>/dev/null; then
    bad "cold-1: healthz на порту $port не отвечает 200 после workshop"
    kill -TERM "$new_pid" 2>/dev/null || true
    return 1
  fi
  # pid в файле не совпадает с убитым (т.е. реально новый процесс).
  if [ "$new_pid" = "$orig_pid" ]; then
    bad "cold-1: pid-файл содержит тот же pid=$new_pid, что и до workshop"
    kill -TERM "$new_pid" 2>/dev/null || true
    return 1
  fi
  kill -TERM "$new_pid" 2>/dev/null || true
  ok "cold-1: kill по pid-файлу → workshop → healthz 200, новый pid=$new_pid жив (был $orig_pid)"
  return 0
}

# coldstart_2 — подставной слушатель на порту (отвечает НЕ 200 / не отвечает
# вовсе). workshop --check-metering обязан отказать с reason=чужой_слушатель.
# Слушатель отвечает 404 на healthz — workshop probe отличает «не наш».
coldstart_2() {
  local launcher="$1" work="$2"
  local cfg port errf
  port="$(free_port)"
  cfg="$(gen_cold_config "$work" "$port" 2 "c2")"
  errf="$work/c2.err"

  # Подставной слушатель. 404 на healthz — workshop не примет за свой.
  PORT_C2="$port" setsid node -e '
    const http = require("http");
    const port = parseInt(process.env.PORT_C2, 10);
    const server = http.createServer((req, res) => {
      if (req.url === "/healthz") { res.statusCode = 404; res.end("not our proxy"); return; }
      res.statusCode = 418; res.end("teapot");
    });
    server.listen(port, "127.0.0.1", () => process.stderr.write("foreign_c2 on " + port + "\n"));
  ' > "$work/c2.foreign.log" 2>&1 &
  local foreign_pid=$!
  echo "$foreign_pid" > "$work/c2.foreign.pid"
  # Ждём подъёма слушателя.
  local i
  for i in $(seq 1 60); do
    if ss -ltn 2>/dev/null | awk '{print $4}' | grep -qE ":${port}\$"; then
      break
    fi
    sleep 0.05
  done

  run_workshop "$launcher" "$cfg" "$errf"
  if [ "$WS_RC" = "1" ] && printf '%s' "$WS_STDERR" | grep -qF "reason=чужой_слушатель"; then
    ok "cold-2: чужой слушатель → код 1, reason=чужой_слушатель"
  else
    bad "cold-2: ожидался код 1 с reason=чужой_слушатель, rc=$WS_RC, stderr: $WS_STDERR"
  fi
  kill -TERM "$foreign_pid" 2>/dev/null || true
  for i in $(seq 1 20); do
    kill -0 "$foreign_pid" 2>/dev/null || break
    sleep 0.05
  done
  [ "$WS_RC" = "1" ] && printf '%s' "$WS_STDERR" | grep -qF "reason=чужой_слушатель" && return 0
  return 1
}

# coldstart_3a — ФАТАЛЬНО битый конфиг (невалидный JSON). workshop --check-metering
# ОБЯЗАН отказать с НАЗВАННОЙ причиной (конфиг_не_читается или конфиг_битый) за
# время ≤ W_probe. Собственный код гибели ребёнка НЕ фиксируется — workshop
# валит JSON ДО spawn'а, и это легитимный (измеренный) исход: арбитраж
# proksi-cold-start §«Вопрос 2 — обязательный минимум» различает формы порчи,
# а workshop сам не пробрасывает невалидный JSON дальше.
coldstart_3a() {
  local launcher="$1" work="$2"
  local cfg="$work/cfg_3a.json"
  errf="$work/c3a.err"
  # Битый JSON: обрезан на полпути — JSON.parse падает.
  printf '{ "port": 18777, "healthz_window_sec": 3, "this_is_broken' > "$cfg"

  run_workshop "$launcher" "$cfg" "$errf"
  local reason_ok=0
  if printf '%s' "$WS_STDERR" | grep -qF "reason=конфиг_не_читается" \
     || printf '%s' "$WS_STDERR" | grep -qF "reason=конфиг_битый"; then
    reason_ok=1
  fi
  if [ "$WS_RC" = "1" ] && [ "$reason_ok" = "1" ] \
     && [ "$WS_DURATION_MS" -le $((W_PROBE * 1000)) ]; then
    ok "cold-3a: битый конфиг → код 1, reason назван, time=${WS_DURATION_MS}мс ≤ ${W_PROBE}с"
    return 0
  fi
  bad "cold-3a: rc=$WS_RC, time=${WS_DURATION_MS}мс, reason_ok=$reason_ok; stderr: $WS_STDERR"
  return 1
}

# coldstart_3b — процесс жив, healthz молчит. workshop --check-metering обязан
# отказать по окну W_healthz с reason=healthz_молчит. Прямой подъём реального
# прокси в workshop выдаёт 200 на healthz → это не 3б. ПОДМЕНА ребёнка: кладём
# в pid-файл путь, по которому workshop запустит НАШУ silent-заглушку вместо
# metering_proxy.ts. Чтобы не править workshop (зона implementer), используем
# «теневой» подход: workshop читает proxy_script = $HERE/scripts/proxy/metering_proxy.ts.
# Если workshop в $HERE = $work/ws_env, а в $work/ws_env/scripts/proxy/ положить
# silent-заглушку — workshop поднимет ЕЁ. Лаунчер для (3б) — локальная копия.
#
# КРИТЕРИЙ ВРЕМЕНИ: ≥ W_healthz (по конфигу, здесь = 3с) И ≤ W_probe (= 15с).
coldstart_3b() {
  local launcher="$1" work="$2"

  # Теневой workshop. Содержит РЕАЛЬНЫЙ workshop, но proxy в нём — silent.
  local ws_env="$work/ws_env"
  mkdir -p "$ws_env/scripts/proxy" "$ws_env/.config/dev-harness"
  cp "$launcher" "$ws_env/workshop" 2>/dev/null \
    || die "cold-3b: не удалось скопировать лаунчер $launcher в $ws_env — фикстура требует путь"
  chmod +x "$ws_env/workshop"

  # Silent-стаб: слушает, но НЕ отвечает на /healthz (accept'ит соединение и висит).
  cat > "$ws_env/scripts/proxy/metering_proxy.ts" <<'STUB_PROXY_3B'
// Silent-заглушка для (3б): слушает на порту из конфига, но на /healthz не отвечает.
// Арбитраж: способ получить «живой-но-молчащий» ребёнок — выбор автора фикстуры.
// Реализация свободна. Здесь — accept без ответа, цикл while(true) на запросе.
import * as http from "node:http";
import * as fs from "node:fs";
const i = process.argv.indexOf("--config");
const cfg = JSON.parse(fs.readFileSync(process.argv[i + 1], "utf8"));
const port = cfg.port;
const server = http.createServer(() => { /* silent: висим */ });
server.listen(port, "127.0.0.1", () => {
  process.stderr.write("stub_silent_3b on " + port + "\n");
});
STUB_PROXY_3B

  # HOME указывает в work — workshop пишет pid в work/.config/dev-harness/proxy.pid.
  local cfg port errf
  port="$(free_port)"
  cfg="$(gen_cold_config "$work" "$port" 3 "c3b")"
  errf="$work/c3b.err"
  # Запускаем теневой workshop С ЕГО ЖЕ HOME (work). Здесь HOME всё равно
  # выставлен в $work родительским mode_cold_start, но для красного —
  # воспроизводимости — выставляем явно.
  HOME="$work" run_workshop "$ws_env/workshop" "$cfg" "$errf"
  local hw_ms
  hw_ms=$(( W_HEALTHZ * 1000 ))
  if [ "$WS_RC" = "1" ] \
     && printf '%s' "$WS_STDERR" | grep -qF "reason=healthz_молчит" \
     && [ "$WS_DURATION_MS" -ge "$hw_ms" ] \
     && [ "$WS_DURATION_MS" -le $((W_PROBE * 1000)) ]; then
    ok "cold-3b: живой-но-молчащий → код 1, reason=healthz_молчит, time=${WS_DURATION_MS}мс в [${hw_ms}..$((W_PROBE * 1000))]мс"
    return 0
  fi
  bad "cold-3b: rc=$WS_RC, time=${WS_DURATION_MS}мс; stderr: $WS_STDERR"
  return 1
}

# coldstart_4 — неумолчательный конфиг: порт ≠ 8765 И W_healthz ≠ 5.
# workshop ОБЯЗАН прочитать ОБА из конфига. В этом тесте: порт=18765, hw=3.
# Проверяем: workshop стартует прокси на 18765 (а не на 8765/с умолчанием 5),
# healthz на 18765 отвечает 200, pid-файл содержит живой pid.
coldstart_4() {
  local launcher="$1" work="$2"
  local cfg port hw pidfile errf
  port=18765
  hw=3
  # Убедимся, что 18765 свободен — иначе тест не настроечный.
  if ss -ltn 2>/dev/null | awk '{print $4}' | grep -qE ":${port}\$"; then
    bad "cold-4: порт $port занят — тест не настроечный"
    return 1
  fi
  cfg="$(gen_cold_config "$work" "$port" "$hw" "c4")"
  pidfile="$work/.config/dev-harness/proxy.pid"
  errf="$work/c4.err"

  run_workshop "$launcher" "$cfg" "$errf"
  if [ "$WS_RC" != "0" ]; then
    bad "cold-4: workshop вернул $WS_RC, ожидался 0 (stderr: $WS_STDERR)"
    return 1
  fi
  # pid в pid-файле живой И процесс реально на настроенном порту.
  local new_pid
  new_pid="$(cat "$pidfile" 2>/dev/null || true)"
  if [ -z "$new_pid" ] || ! kill -0 "$new_pid" 2>/dev/null; then
    bad "cold-4: pid-файл $pidfile не содержит живого pid"
    return 1
  fi
  # ss -ltnp покажет пару (pid, port) — ищем наш pid на настроенном порту.
  if ! ss -ltnp 2>/dev/null | grep -E "pid=${new_pid}," | grep -qE ":${port}\b"; then
    bad "cold-4: pid=$new_pid слушает НЕ на порту $port — workshop не прочитал конфиг"
    kill -TERM "$new_pid" 2>/dev/null || true
    return 1
  fi
  if ! curl -fsS -o /dev/null -m 2 "http://127.0.0.1:${port}/healthz" 2>/dev/null; then
    bad "cold-4: healthz на $port не отвечает 200 после workshop"
    kill -TERM "$new_pid" 2>/dev/null || true
    return 1
  fi
  kill -TERM "$new_pid" 2>/dev/null || true
  ok "cold-4: неумолчательный конфиг (порт=$port ≠8765, hw=$hw ≠5) → код 0, прокси на $port, healthz 200"
  return 0
}

# mode_cold_start — главный вход режима. КАЖДЫЙ из пяти исходов — свой
# под-прогон, общий счётчик fails. ОТКАЗ режима — exit 1; зелёный — exit 0.
mode_cold_start() {
  local launcher="${METERING_WORKSHOP:-workshop}"
  command -v "$launcher" >/dev/null 2>&1 \
    || die "cold-start: лаунчер не найден: $launcher (export METERING_WORKSHOP=<путь>)"

  local work
  work="$(mktemp -d "$TMP_ROOT/metering-cold.XXXXXX")"
  export HOME="$work"
  mkdir -p "$work/data" "$work/.config/dev-harness"

  printf '\n=== режим --cold-start (W_healthz=%dс, W_probe=%dс) ===\n' \
    "$W_HEALTHZ" "$W_PROBE" >&2

  coldstart_1 "$launcher" "$work" || ((++fails))
  coldstart_2 "$launcher" "$work" || ((++fails))
  coldstart_3a "$launcher" "$work" || ((++fails))
  coldstart_3b "$launcher" "$work" || ((++fails))
  coldstart_4 "$launcher" "$work" || ((++fails))

  if [ "$fails" -gt 0 ]; then
    printf '\nрасхождений: %d · работа в %s\n' "$fails" "$work" >&2
    exit 1
  fi
  printf '\nбарьер --cold-start зелёный\n' >&2
  rm -rf "$work"
  exit 0
}

# ════════════════════════════════════════════════════════════════════════════
# Режим --live (критерий 3 контракта 005)
# ════════════════════════════════════════════════════════════════════════════
#
# uuid-вызов через прокси с порождённым x-request-id → строка в calls.jsonl
# с тем же коррелятором И ожидаемой ролью И свежим ts (строго позже старта
# пробы). Прямой маршрут мимо прокси строки не рождает. Без сети — код 2
# NOT_IMPLEMENTED, НИКОГДА 0.
#
# Подставной upstream поднимаем через stub_upstream — это закрывает «сеть
# доступна»: прокси видит ответ, журнал пишется, и нет зависимости от
# внешнего провайдера.

mode_live() {
  local work cfg vars up_dir stub_port provider model token role port
  work="$(mktemp -d "$TMP_ROOT/metering-live.XXXXXX")"
  export HOME="$work"
  mkdir -p "$work/data"

  cfg="$(gen_config "$work")"
  vars="$work/vars.json"
  role="$(jq -r '.role' "$vars")"
  provider="$(jq -r '.provider' "$vars")"
  model="$(jq -r '.model' "$vars")"
  token="$(jq -r '.token' "$vars")"
  port="$(jq -r '.port' "$cfg")"

  up_dir="$work/up"
  stub_upstream "$up_dir" >/dev/null \
    || die "live: stub_upstream не поднялся"
  stub_port="$(cat "$up_dir/port")"
  # Перенаправим upstream в конфиге.
  local tmpc; tmpc="$(mktemp -p "$TMP_ROOT")"
  jq --arg u "http://127.0.0.1:${stub_port}" --arg p "$provider" \
     ".upstream[\"$p\"] = \$u" "$cfg" > "$tmpc" && mv "$tmpc" "$cfg"

  # Сценарий upstream: 200, известные usage-числа.
  cat > "$up_dir/scenario.json" <<EOF
{"status":200,"content_type":"application/octet-stream","body_b64":"$(printf 'live-ok' | base64 -w0)","headers":{"x-usage-tokens-in":"100","x-usage-tokens-out":"50"}}
EOF
  : > "$up_dir/requests.jsonl"
  : > "$work/data/calls.jsonl"

  # Поднимаем прокси.
  local proxy_pid
  proxy_pid="$(proxy_up "$cfg" "$work/data/proxy.pid")" \
    || die "live: прокси не поднялся"
  trap "proxy_down $proxy_pid; rm -rf '$work'" EXIT

  # 1. Прямой маршрут мимо прокси → строка НЕ пишется.
  local rid_direct start_ts
  rid_direct="$(uuidgen 2>/dev/null || node -e 'process.stdout.write(require("crypto").randomUUID())')"
  start_ts=$(date +%s%3N)
  local resp_direct
  resp_direct="$(req POST "http://127.0.0.1:${stub_port}/${provider}/chat/completions" \
                  "$token" "$model" "direct" "application/octet-stream" "$rid_direct")"
  if grep -qF "\"$rid_direct\"" "$work/data/calls.jsonl" 2>/dev/null; then
    bad "live: прямой маршрут (в обход прокси) оставил строку в calls.jsonl с коррелятором $rid_direct"
    return 1
  fi

  # 2. Живой маршрут через прокси → строка пишется с ТЕМ ЖЕ коррелятором,
  # той же ролью и ts > start_ts.
  local rid_live
  rid_live="$(uuidgen 2>/dev/null || node -e 'process.stdout.write(require("crypto").randomUUID())')"
  local resp_live
  resp_live="$(req POST "http://127.0.0.1:${port}/${provider}/chat/completions" \
                "$token" "$model" "live" "application/octet-stream" "$rid_live")"
  local s
  s="$(printf '%s\n' "$resp_live" | head -1)"
  if [ "$s" != "200" ]; then
    bad "live: прокси вернул $s, ожидался 200 (live-вызов с коррелятором)"
    return 1
  fi
  if [ ! -s "$work/data/calls.jsonl" ]; then
    bad "live: calls.jsonl пуст — живой вызов не записан"
    return 1
  fi
  # Ищем строку с rid_live.
  local line
  line="$(grep -F "\"request_id\":\"${rid_live}\"" "$work/data/calls.jsonl" | head -1 || true)"
  if [ -z "$line" ]; then
    bad "live: в calls.jsonl нет строки с коррелятором $rid_live"
    return 1
  fi
  # Тройка: request_id совпал, role = $role, ts > start_ts.
  local line_role line_ts
  line_role="$(printf '%s' "$line" | sed -nE 's/.*"role":"([^"]+)".*/\1/p')"
  line_ts="$(printf '%s' "$line" | sed -nE 's/.*"ts":([0-9]+).*/\1/p')"
  if [ "$line_role" != "$role" ]; then
    bad "live: role в строке «$line_role», ожидалась «$role»"
    return 1
  fi
  if [ -z "$line_ts" ] || [ "$line_ts" -le "$start_ts" ]; then
    bad "live: ts в строке «$line_ts» не свежий (start_ts=$start_ts)"
    return 1
  fi
  ok "live: uuid-вызов через прокси → строка с коррелятором, role=$line_role, ts=$line_ts > $start_ts"
  return 0
}

# ── режим --port0 (красный тест среза-2, контракт 007) ────────────────────────
# Предмет среза-2: НОРМАЛЬНЫЙ путь check_metering перестаёт угадывать порт прокси
# глобальным free_port-сканом (корень флейка Н-45: ~60 портов/прогон + TOCTOU) и
# переходит на OS-назначаемый эфемерный порт (bind :0); прокси РЕПОРТИТ фактический
# порт в <data_dir>/.actual_port. Три под-пробы закрывают обходы круга 1 критика:
#   p0.gen  — gen_config эмитит "port":0 (а не скан), иначе нормальный путь не мигрирован (F4);
#   p0.up   — ШТАТНЫЙ proxy_up на port:0 поднимает прокси, читает репортный порт, переписывает
#             cfg.port на фактический, healthz на нём 200 — миграция самого раннера (F4);
#   p0.conc — ДВА конкурентных port:0 прокси получают РАЗНЫЕ эфемерные порты (фикс-константа
#             дала бы коллизию/один порт) — доказывает OS-назначение, а не самовыбор (F5).
# КРАСНОЕ против текущего дерева: gen_config free_port-сканит (p0.gen), proxy_up healthz-поллит
# cfg.port=0 и die (p0.up), прокси не пишет .actual_port (p0.conc). Переиспользует gen_config,
# proxy_up, proxy_down, PROXY, PROXY_NODE_FLAGS.
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

  [ "$fails" -eq 0 ]
}

case "$MODE" in
  default) main "$@" ;;
  port0)
    if mode_port0; then exit 0; else exit 1; fi ;;
esac
