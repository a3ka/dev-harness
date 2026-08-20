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
  --live|--cold-start) MODE="${1#--}" ;;
  ""|--default)        MODE="default" ;;
  *) die "неизвестный режим: $1 (ожидался --live, --cold-start или пусто)" ;;
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
  local port
  port="$(free_port)"
  printf '%s' "$port" > "$dir/port"
  PORT="$port" DIR="$dir" \
  setsid node -e '
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
  ' > "$dir/stub.log" 2> "$dir/stub.err" &
  echo "$!" > "$dir/pid"
  local i
  for i in $(seq 1 60); do
    if ss -ltn 2>/dev/null | awk '{print $4}' | grep -qE ":${port}\$"; then
      printf '%s\n' "$port"; return 0
    fi
    sleep 0.05
  done
  die "stub_upstream не поднялся на порту $port за 3 с — лог: $dir/stub.err"
}

proxy_up() {
  local cfg="$1" pidfile="$2"
  [ -f "$PROXY" ] || die "прокси не найден рядом с барьером: $PROXY"
  (
    cd "$(dirname "$cfg")"
    exec node "$PROXY" --config "$cfg"
  ) > "$pidfile.log" 2> "$pidfile.err" &
  local pid="$!"
  echo "$pid" > "$pidfile"
  local port win
  port="$(jq -r '.port' "$cfg")"
  win="$(jq -r '.healthz_window_sec' "$cfg")"
  local max=$(( win * 20 )) i
  for i in $(seq 1 "$max"); do
    if curl -fsS -o /dev/null -m 0.5 "http://127.0.0.1:${port}/healthz" 2>/dev/null; then
      printf '%s' "$pid"; return 0
    fi
    if ! kill -0 "$pid" 2>/dev/null; then
      die "прокси погиб на старте (pid=$pid), лог: $pidfile.err"
    fi
    sleep 0.05
  done
  kill "$pid" 2>/dev/null || true
  die "healthz не ответил за ${win} с на порту $port — лог: $pidfile.err"
}

proxy_down() {
  local pid="$1"
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
  proxy_port="$(free_port)"
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
  local up_pid
  up_pid="$(cat "$up_dir/pid")"
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

# ── ВЕТВИ СОСЕДНИХ АГЕНТОВ ────────────────────────────────────────────────────
branch_е()  { printf "  pend е: Fix005integrity ещё не дописал
" >&2; return 0; }
branch_ж()  { printf "  pend ж: Fix005integrity ещё не дописал
" >&2; return 0; }
branch_з()  { printf "  pend з: Fix005integrity ещё не дописал
" >&2; return 0; }
branch_и()  { printf "  pend и: Fix005integrity ещё не дописал
" >&2; return 0; }
branch_к1() { printf "  pend к1: Fix005limits ещё не дописал
" >&2; return 0; }
branch_к2() { printf "  pend к2: Fix005limits ещё не дописал
" >&2; return 0; }
branch_л()  { printf "  pend л: Fix005limits ещё не дописал
" >&2; return 0; }
branch_м()  { printf "  pend м: Fix005limits ещё не дописал
" >&2; return 0; }

# ── main ──────────────────────────────────────────────────────────────────────
main() {
  local work
  work="$(mktemp -d "${TMPDIR:-/tmp}/metering.XXXXXX")"
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
  tmp="$(mktemp)"
  jq --arg u "$cfg_up" ".upstream[\"$provider\"] = \$u" "$cfg" > "$tmp"
  mv "$tmp" "$cfg"
  export BARRIER_UP_DIR="$up_dir" BARRIER_CFG="$cfg" BARRIER_DATA="$work/data" BARRIER_VARS="$vars"

  local proxy_pid
  proxy_pid="$(proxy_up "$cfg" "$work/data/proxy.pid")"
  trap "proxy_down $proxy_pid; rm -rf '$work'" EXIT

  branch а branch_а
  for br in б в в2 г г2 д е ж з и к1 к2 л м; do
    branch "$br" "branch_${br}"
  done

  proxy_down "$proxy_pid"
  if [ "$fails" -gt 0 ]; then
    printf '\nрасхождений: %d · прогон оставлен в %s\n' "$fails" "$work" >&2
    exit 1
  fi
  printf '\nбарьер зелёный · работа в %s\n' "$work" >&2
  rm -rf "$work"
}

main "$@"
