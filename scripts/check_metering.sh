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
branch_к1() {
  # (к1) builtins-only, ИМПОРТЫ: grep'аем все `import ... from "..."` и `import ... from '...'`
  # из исходника прокси; строки с `from "node:..."` разрешены, остальные — нет.
  local src="${1:-$PROXY}"
  [ -f "$src" ] || { bad "к1: исходник прокси не найден: $src"; return 1; }
  local bad_imports
  bad_imports="$(grep -nE "(^|[[:space:]])import[[:space:]]+.+from[[:space:]]+['\"][^'\"]+['\"]" "$src" \
                 | grep -vE "from[[:space:]]+['\"]node:" || true)"
  if [ -n "$bad_imports" ]; then
    bad "к1: импорты вне node: в $src → $(printf '%s' "$bad_imports" | head -3 | tr '\n' ';')"
    return 1
  fi
  ok "к1: импортов вне node: в $src нет"
  return 0
}

branch_к2() {
  # (к2) builtins-only, ПРОЦЕССЫ: ищем вызовы exec*/spawn* и смотрим первый строковый
  # аргумент. Разрешён только "node" (или пустая строка — мы не нашли аргумента).
  # Любое другое имя ("curl", "wget", "/usr/bin/...", "sh", "bash") — внешний процесс.
  local src="${1:-$PROXY}"
  [ -f "$src" ] || { bad "к2: исходник прокси не найден: $src"; return 1; }
  local hits
  hits="$(grep -nE "(execFile|exec|spawn)(Sync)?[[:space:]]*\(" "$src" || true)"
  [ -z "$hits" ] && { ok "к2: exec/spawn вызовов в $src нет"; return 0; }
  local bad_args=""
  local line first_arg
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    first_arg="$(printf '%s' "$line" | sed -nE "s/.*\([[:space:]]*['\"]([^'\"]+)['\"].*/\1/p" | head -1)"
    [ -z "$first_arg" ] && continue
    case "$first_arg" in
      node) ;;  # разрешено — сам node
      *)    bad_args="${bad_args}${first_arg}|";;
    esac
  done <<< "$hits"
  if [ -n "$bad_args" ]; then
    bad "к2: внешние процессы в $src → ${bad_args%|}"
    return 1
  fi
  ok "к2: exec/spawn вызовов вне node в $src нет"
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
      local old_pid_file="$up_dir/pid"
      if [ -f "$old_pid_file" ]; then
        local op; op="$(cat "$old_pid_file")"
        [ -n "$op" ] && kill -- "-$op" 2>/dev/null || kill "$op" 2>/dev/null || true
      fi
      stub_upstream "$up_dir" >/dev/null
      local new_port; new_port="$(cat "$up_dir/port")"
      local provider; provider="$(jq -r '.provider' "$vars")"
      local tmpc; tmpc="$(mktemp)"
      jq --arg u "http://127.0.0.1:${new_port}" --arg p "$provider" \
         '.upstream[$p] = $u' "$cfg" > "$tmpc" && mv "$tmpc" "$cfg"
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
  _restart_proxy_and_upstream
  local t_jan t_feb now_file="$data/now.txt"
  t_jan="$(node -e 'process.stdout.write(String(Date.UTC(2026, 0, 31, 23, 59, 59, 999)))')"
  t_feb="$(node -e 'process.stdout.write(String(Date.UTC(2026, 1, 0, 0, 0, 0)))')"
  # Включим now_file и предзаполним бюджет 2026-01 на 1 микро-USD (= ceiling) — тогда
  # первый запрос 2026-01 получит 402 (spent >= limit). Второй запрос 2026-02 идёт в
  local tmpc; tmpc="$(mktemp)"
  jq --arg nf "$now_file" --arg p "$provider" --argjson ce 1 \
    '.now_file = $nf | .ceilings[$p].usd_per_month = $ce' "$cfg" > "$tmpc" && mv "$tmpc" "$cfg"
  mkdir -p "$data"
  _restart_proxy_and_upstream
  printf '{"2026-01":{"%s":1}}\n' "$provider" > "$data/budget.json"
  cat > "$up_dir/scenario.json" <<EOF
{"status":200,"content_type":"application/octet-stream","body_b64":"$(printf 'ok-jan' | base64 -w0)","headers":{"x-usage-tokens-in":"1000000","x-usage-tokens-out":"0"}}
EOF
  printf '%s' "$t_jan" > "$now_file"
  local r1 body1
  r1="$(req POST "http://127.0.0.1:${port}/${provider}/chat/completions" \
        "$token" "$model" "ping-jan" "application/octet-stream" "$(rnd_label 8)")"
  body1="${r1##*__BODY__}"
  # Поднимем ceiling обратно, чтобы второй вызов во втором периоде ПРОШЁЛ.
  tmpc="$(mktemp)"
  jq --arg p "$provider" --argjson ce 1000000000 \
    '.ceilings[$p].usd_per_month = $ce' "$cfg" > "$tmpc" && mv "$tmpc" "$cfg"
  _restart_proxy_and_upstream
  printf '%s' "$t_feb" > "$now_file"
  rm -f "$data/calls.jsonl" "$up_dir/requests.jsonl" "$up_dir/count"
  cat > "$up_dir/scenario.json" <<EOF
{"status":200,"content_type":"application/octet-stream","body_b64":"$(printf 'ok-feb' | base64 -w0)","headers":{"x-usage-tokens-in":"1000000","x-usage-tokens-out":"0"}}
EOF
  local r2 s2
  r2="$(req POST "http://127.0.0.1:${port}/${provider}/chat/completions" \
        "$token" "$model" "ping-feb" "application/octet-stream" "$(rnd_label 8)")"
  s2="$(printf '%s\n' "$r2" | head -1)"
  local s1; s1="$(printf '%s' "$body1" | jq -r '.error // empty' 2>/dev/null)"
  if [ "$s1" != "ceiling_exceeded" ]; then
    bad "л.п: первый вызов в 2026-01 не вернул ceiling_exceeded, тело: $body1"; return 1
  fi
  if [ "$s2" != "200" ]; then
    bad "л.п: второй вызов в 2026-02 не прошёл, код $s2"; return 1
  fi
  local n_lines; n_lines="$(wc -l < "$data/calls.jsonl" | tr -d ' ')"
  if [ "$n_lines" -lt 2 ]; then
    bad "л.п: $n_lines строк в журнале, ожидалось ≥ 2"; return 1
  fi
  local ts1 ts2 period1 period2
  ts1="$(head -1 "$data/calls.jsonl" | sed -nE 's/.*"ts":([0-9]+).*/\1/p')"
  ts2="$(tail -1 "$data/calls.jsonl" | sed -nE 's/.*"ts":([0-9]+).*/\1/p')"
  period1="$(node -e "process.stdout.write((new Date(parseInt('$ts1',10)).getUTCMonth()+1<10?new Date(parseInt('$ts1',10)).getUTCFullYear()+'-0'+(new Date(parseInt('$ts1',10)).getUTCMonth()+1):new Date(parseInt('$ts1',10)).getUTCFullYear()+'-'+(new Date(parseInt('$ts1',10)).getUTCMonth()+1)))")"
  period2="$(node -e "process.stdout.write((new Date(parseInt('$ts2',10)).getUTCMonth()+1<10?new Date(parseInt('$ts2',10)).getUTCFullYear()+'-0'+(new Date(parseInt('$ts2',10)).getUTCMonth()+1):new Date(parseInt('$ts2',10)).getUTCFullYear()+'-'+(new Date(parseInt('$ts2',10)).getUTCMonth()+1)))")"
  if [ "$period1" != "2026-01" ] || [ "$period2" != "2026-02" ]; then
    bad "л.п: периоды в строках $period1/$period2, ожидались 2026-01/2026-02 — кэш периода на старте"; return 1
  fi
  ok "л.п: 2026-01 и 2026-02 различимы в одном живом процессе"

  # ── (л.о) две оси тарифа — два провайдера с одной моделью ──────────────────
  local p2 m2 in1 in2
  p2="$(rnd_label 7)"; m2="$(rnd_label 5)"
  in1=1200000; in2=2400000
  local ceil_p1=50000000 ceil_p2=30000000
  tmpc="$(mktemp)"
  jq --arg p1 "$provider" --arg p2 "$p2" --arg m "$model" --arg m2 "$m2" \
     --argjson in1 "$in1" --argjson in2 "$in2" \
     --argjson c1 "$ceil_p1" --argjson c2 "$ceil_p2" \
     '.upstream[$p2] = .upstream[$p1]
      | .prices[$p2] = { ($m2): { per_m_tokens: { in: $in2, out: 6800000 } } }
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
         "$token" "$m2" "ping-p2" "application/octet-stream" "$(rnd_label 8)")"
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

  # ── (л.i) int64 > 2^53 — текст сверки ─────────────────────────────────────
  local hi=9007199254741
  tmpc="$(mktemp)"
  jq --arg p "$provider" --arg m "$model" --argjson hi "$hi" \
     '.prices[$p][$m].per_m_tokens.in = $hi | .prices[$p][$m].per_m_tokens.out = 0' \
     "$cfg" > "$tmpc" && mv "$tmpc" "$cfg"
  _restart_proxy_and_upstream
  rm -f "$data/calls.jsonl" "$up_dir/requests.jsonl" "$up_dir/count"
  cat > "$up_dir/scenario.json" <<EOF
{"status":200,"content_type":"application/octet-stream","body_b64":"$(printf 'ok' | base64 -w0)","headers":{"x-usage-tokens-in":"1000000","x-usage-tokens-out":"0"}}
EOF
  local ri line_i usd_str
  ri="$(req POST "http://127.0.0.1:${port}/${provider}/chat/completions" \
        "$token" "$model" "ping-int" "application/octet-stream" "$(rnd_label 8)")"
  line_i="$(head -1 "$data/calls.jsonl" 2>/dev/null || true)"
  usd_str="$(printf '%s' "$line_i" | sed -nE 's/.*"usd":"([0-9]+)".*/\1/p')"
  if [ -z "$usd_str" ] || [ "$usd_str" != "$hi" ]; then
    bad "л.i: usd строки = «$usd_str», ожидался «$hi»"; return 1
  fi
  if [ "${#usd_str}" -lt 16 ]; then
    bad "л.i: usd короче 16 цифр ($usd_str) — не похоже на >2^53"; return 1
  fi
  ok "л.i: usd=$usd_str — int64 > 2^53 передан строкой без потери точности"
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
  work="$(mktemp -d "${TMPDIR:-/tmp}/metering-cold.XXXXXX")"
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
  work="$(mktemp -d "${TMPDIR:-/tmp}/metering-live.XXXXXX")"
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
  local tmpc; tmpc="$(mktemp)"
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

main "$@"
