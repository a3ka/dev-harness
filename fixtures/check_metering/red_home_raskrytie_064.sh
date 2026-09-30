#!/usr/bin/env bash
# ПРЕД-ЗАМОРОЗОЧНОЕ КРАСНОЕ контракта 064 — прокси учёта не раскрывает ${HOME}
# в data_dir/secrets_env (config/metering.json:5-6 несёт литеральные «${HOME}/…»,
# loadConfig валидирует строки БЕЗ раскрытия — metering_proxy.ts:283-288,347-348,
# а :1214/:1259 делают mkdirSync/path.join на сырое cfg.data_dir: при запуске из
# чекаута под cwd вырастает каталог с буквальным именем «${HOME}»; замер владельца
# 2026-09-30 11:31 UTC, ОБЕ машины, check_no_leak красен).
#
# Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (прецедент А-82 / red_dver_minta_031):
# до реализации предмет предъявляется ПРЯМЫМ запуском. Сегодня файл красен
# именованной причиной фазы Б (боль жива); ПОСЛЕ реализации — rc 0. Приёмка —
# ДВА прогона подряд (случайные входы различают их).
#
# ФАЗЫ (порядок: зонд-контроль → стабы → боль):
#   ЗК  зелёный контроль ЗОНДА: честный прокси + конфиг с АБСОЛЮТНЫМИ путями
#       (тот же профиль полей, без ${HOME}) — все утверждения зонда обязаны пройти
#       И СЕГОДНЯ: файл-порт в data_dir, POST 200, calls.jsonl в data_dir,
#       cwd-дерево чисто. Отделяет «зонд сломан» от «боль жива» (шапка
#       verify_antiplacebo: причина, не умеющая быть зелёной, боль не доказывает).
#   С1  стаб «без раскрытия»: cfg.data_dir используется литерально (класс
#       сегодняшнего прокси) — наблюдаем на входе «конфиг с ${HOME}»: под cwd
#       растёт буквальное «${HOME}»-дерево (зонд: пишет мимо песочницы);
#   С2  стаб «хардкод дома»: конфиг игнорируется, порт-файл пишется в
#       предопределённый $HOME/.local/share/dev-harness/metering — наблюдаем на
#       входе со СЛУЧАЙНЫМ хвостом data_dir: репорт порта не в data_dir конфига;
#   С3  стаб «порт-только»: .actual_port пишется в раскрытый путь (имитация
#       фикса), secrets_env/journal остаются литеральными — наблюдаем на входе
#       «POST с токеном»: статус не 200, журнала в раскрытом data_dir нет.
#   Б   боль (определяющая): ЧЕСТНЫЙ прокси + конфиг с ${HOME} в песочнице HOME —
#       сегодня красна именованной причиной, ПОСЛЕ реализации зелёна.
#
# Инвариант трекаемости (б) — тоже прогоном: закоммиченный config/metering.json
# несёт data_dir/secrets_env с литеральным префиксом «${HOME}» и без машинно-
# специфичных абсолютных путей — зелёное и до, и после (конфиг не меняется).
#
# Каркас семьи: _repo.sh (make_repo/stub_proxy/rnd); пламбинг запуска —
# БИБЛИОТЕЧНЫЙ режим барьера-копии (PROBE017_LIB=1, прецедент probe_port0.sh):
# stub_upstream/req/PROXY_NODE_FLAGS/proxy_down из одного источника,
# переизобретения нет. Флаги node — те же, что у всех точек запуска барьера
# (арбитраж grep-vs-runtime-builtins, f175567).
#
# Коды возврата: 0 — все фазы пройдены (после реализации); 1 — именованный отказ
#               (боль жива / стаб не пойман / зонд сломан); 2 — нечем проверить.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/red064-home.XXXXXX")"   # А-78: свежий WORK вне дерева
trap 'pkill -f "metering-stub-upstream $WORK" 2>/dev/null; rm -rf "$WORK"' EXIT

# soderzhit <стог> <игла> — подстрочная проверка своей фразы (литеральный case,
# без regex; у причин зонда фиксированные байты — контракт цитирует их дословно).
soderzhit() { case "$1" in *"$2"*) return 0 ;; *) return 1 ;; esac; }

command -v node >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет node — прокси не запустить\n' >&2; exit 2; }
command -v jq   >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет jq — конфиг не разобрать\n' >&2; exit 2; }
command -v curl >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет curl — healthz не дёрнуть\n' >&2; exit 2; }

# shellcheck disable=SC1091
. "$HERE/_repo.sh"

# ── инвариант (б): трекаемость закоммиченного конфига ──────────────────────────
_dd_cfg="$(jq -r '.data_dir' "$REPO/config/metering.json")"
_se_cfg="$(jq -r '.secrets_env' "$REPO/config/metering.json")"
case "$_dd_cfg" in '${HOME}'/*) ;; *) die "трекаемость: data_dir конфига без литерального префикса \${HOME}: $_dd_cfg" ;; esac
case "$_se_cfg" in '${HOME}'/*) ;; *) die "трекаемость: secrets_env конфига без литерального префикса \${HOME}: $_se_cfg" ;; esac
case "$_dd_cfg $_se_cfg" in *'/'home/*) die "трекаемость: машинно-специфичный абсолютный путь в конфиге: $_dd_cfg / $_se_cfg" ;; esac

# ── сборка семьи: копия прокси+барьера+конфига; барьер-копия — источник пламбинга ──
R="$(make_repo)"
WORK_REPO="$R"
# shellcheck disable=SC1091
PROBE017_LIB=1 . "$R/scripts/check_metering.sh"
unset PROBE017_LIB
PROXY="$R/scripts/proxy/metering_proxy.ts"   # библиотечный PROXY — копия семьи

# ── движок: один прогон прокси, все утверждения; результат в Z_RC/Z_REASON ─────
# Аргументы: <файл-прокси> <метка> <режим: abs|home>. Ожидания снимаются в память
# ДО вызова субъекта (правило 8); диск проверяемого как истина не перечитывается.
# Утверждения: (1) .actual_port в РАСКРЫТОМ data_dir конфига; (2) healthz 200;
# (3) POST с токеном 200 (secrets_env раскрыт); (4) calls.jsonl в раскрытом
# data_dir с коррелятором; (5) cwd-дерево ЧИСТО (ни ${HOME}-литерала, ни чего
# либо ещё). Быстрые красные: буквальное «${HOME}»-дерево под cwd; порт-файл в
# чужом месте под песочницей.
dvigatel() {
  local proxy="$1" tag="$2" mode="$3"
  local home tree cfg dd t1 t2 role model token rid pref up_dir up_port
  local pid port i cand status tail3
  Z_RC=0; Z_REASON=""
  home="$WORK/home-$tag"; tree="$WORK/tree-$tag"
  mkdir -p "$home/.config/dev-harness" "$tree"
  role="$(rnd_label 8)"; model="$(rnd_label 8)"; token="$(rnd_label 24)"; rid="$(rnd_label 12)"
  # СЛУЧАЙНЫЕ хвосты: стаб-хардкод (С2) не может угадать раскрытый путь.
  t1="$(rnd c1)"; t2="$(rnd c2)"
  dd="$home/.local/share/dev-harness/metering-064-$t2"
  printf 'METERING_TOKEN_%s=%s\n' "$role" "$token" > "$home/.config/dev-harness/secrets-064-$t1.env"
  up_dir="$WORK/up-$tag"; up_port="$(stub_upstream "$up_dir")"
  if [ "$mode" = home ]; then pref='${HOME}'; else pref="$home"; fi
  cfg="$WORK/cfg-$tag.json"
  cat > "$cfg" <<EOF
{
  "port": 0,
  "healthz_window_sec": 5,
  "secrets_env": "${pref}/.config/dev-harness/secrets-064-${t1}.env",
  "data_dir": "${pref}/.local/share/dev-harness/metering-064-${t2}",
  "upstream": { "prov-${tag}": "http://127.0.0.1:${up_port}" },
  "prices": { "prov-${tag}": { "${model}": { "per_m_tokens": { "in": 1200000, "out": 3400000 } } } },
  "ceilings": { "prov-${tag}": { "usd_per_month": 1000000000 } },
  "now_file": null
}
EOF
  # грамматика предъявления: в home-режиме конфиг несёт ЛИТЕРАЛЬНЫЙ ${HOME}
  if [ "$mode" = home ] && ! grep -Fq '"${HOME}/' "$cfg"; then
    die "сборка конфига сломана: литерал \${HOME} раскрылся до записи ($cfg)"
  fi
  ( cd "$tree" && HOME="$home" exec node $PROXY_NODE_FLAGS "$proxy" --config "$cfg" ) \
    > "$WORK/log-$tag.out" 2> "$WORK/log-$tag.err" &
  pid=$!
  port=""
  for i in $(seq 1 600); do   # бюджет 30 с — потолок от зависания, не окно (А-18)
    if [ -s "$dd/.actual_port" ]; then port="$(cat "$dd/.actual_port" 2>/dev/null)"; break; fi
    if [ -e "$tree/\${HOME}" ]; then
      proxy_down "$pid"; Z_RC=1
      Z_REASON="пишет мимо песочницы: под cwd вырос literal \${HOME}-путь"
      return 0
    fi
    cand="$(find "$home" -name .actual_port -not -path "$dd/*" -print -quit 2>/dev/null)"
    if [ -n "$cand" ]; then
      proxy_down "$pid"; Z_RC=1
      Z_REASON="репорт порта не в data_dir конфига: $cand"
      return 0
    fi
    if ! kill -0 "$pid" 2>/dev/null; then
      tail3="$(tail -n 3 "$WORK/log-$tag.err" 2>/dev/null | tr '\n' ' ')"
      Z_RC=1; Z_REASON="прокси погиб до репорта порта (хвост err: ${tail3:-<пусто>})"
      return 0
    fi
    sleep 0.05
  done
  if [ -z "$port" ]; then
    proxy_down "$pid"
    tail3="$(tail -n 3 "$WORK/log-$tag.err" 2>/dev/null | tr '\n' ' ')"
    Z_RC=1; Z_REASON=".actual_port не появился в data_dir конфига за 30 с (хвост err: ${tail3:-<пусто>})"
    return 0
  fi
  if ! curl -fsS -o /dev/null -m 2 "http://127.0.0.1:${port}/healthz" 2>/dev/null; then
    proxy_down "$pid"; Z_RC=1; Z_REASON="healthz не 200 на порту $port"
    return 0
  fi
  # маршрут прокси: /<provider>/… — первый сегмент пути есть провайдер конфига
  local resp
  resp="$(req POST "http://127.0.0.1:${port}/prov-${tag}/chat/completions" "$token" "$model" \
    'body-064' 'application/octet-stream' "$rid")"
  status="$(printf '%s\n' "$resp" | head -1)"
  if [ "$status" != "200" ]; then
    proxy_down "$pid"; Z_RC=1
    Z_REASON="запрос с токеном дал ${status:-<пусто>}, а не 200: secrets_env/маршрут не раскрыты"
    return 0
  fi
  if ! grep -Fq "$rid" "$dd/calls.jsonl" 2>/dev/null; then
    proxy_down "$pid"; Z_RC=1
    Z_REASON="calls.jsonl не в data_dir конфига (коррелятора $rid нет)"
    return 0
  fi
  cand="$(find "$tree" -mindepth 1 -print -quit 2>/dev/null)"
  if [ -n "$cand" ]; then
    proxy_down "$pid"; Z_RC=1
    Z_REASON="cwd-дерево не чисто: $cand"
    return 0
  fi
  proxy_down "$pid"
}

# ── ЗК: зелёный контроль зонда на абсолютных путях — зелёное И СЕГОДНЯ ─────────
dvigatel "$PROXY" zk abs
if [ "$Z_RC" != 0 ]; then
  die "ЗК: зонд сломан на абсолютных путях (это не боль, а сломанный зонд): $Z_REASON"
fi
printf '  ok   ЗК: зонд зелёный на абсолютных путях (порт/healthz/POST/журнал/дерево)\n' >&2

# ── С1: стаб «без раскрытия» — литеральный data_dir ────────────────────────────
cat > "$WORK/stub-c1.ts" <<'STUB'
// Стаб С1 (064): cfg.data_dir используется ЛИТЕРАЛЬНО — класс сегодняшнего прокси.
import * as http from "node:http";
import * as fs from "node:fs";
import * as path from "node:path";
const i = process.argv.indexOf("--config");
const cfg = JSON.parse(fs.readFileSync(process.argv[i + 1], "utf8"));
fs.mkdirSync(cfg.data_dir, { recursive: true });
const srv = http.createServer((req, res) => {
  if (req.url === "/healthz") { res.statusCode = 200; res.end("ok"); return; }
  res.statusCode = 404; res.end();
});
srv.listen(0, "127.0.0.1", () => {
  const a = srv.address();
  const p = typeof a === "object" && a ? a.port : cfg.port;
  fs.writeFileSync(path.join(cfg.data_dir, ".actual_port"), String(p));
  process.stderr.write("stub-c1 on " + p + "\n");
});
STUB
stub_proxy "$WORK/stub-c1.ts"
dvigatel "$PROXY" s1 home
if [ "$Z_RC" != 1 ] || ! soderzhit "$Z_REASON" "под cwd вырос literal"; then
  die "С1: стаб «без раскрытия» не пойман (или пойман не той причиной): rc=$Z_RC причина: $Z_REASON"
fi
printf '  ok   С1: стаб «без раскрытия» пойман — под cwd вырос literal ${HOME}-путь\n' >&2

# ── С2: стаб «хардкод дома» — конфиг игнорируется ──────────────────────────────
cat > "$WORK/stub-c2.ts" <<'STUB'
// Стаб С2 (064): data_dir ХАРДКОД предопределённым домашним путём, конфиг игнорируется.
import * as http from "node:http";
import * as fs from "node:fs";
import * as path from "node:path";
const i = process.argv.indexOf("--config");
const cfg = JSON.parse(fs.readFileSync(process.argv[i + 1], "utf8"));
const dd = path.join(process.env.HOME || "/tmp", ".local/share/dev-harness/metering");
fs.mkdirSync(dd, { recursive: true });
const srv = http.createServer((req, res) => {
  if (req.url === "/healthz") { res.statusCode = 200; res.end("ok"); return; }
  res.statusCode = 404; res.end();
});
srv.listen(0, "127.0.0.1", () => {
  const a = srv.address();
  const p = typeof a === "object" && a ? a.port : cfg.port;
  fs.writeFileSync(path.join(dd, ".actual_port"), String(p));
  process.stderr.write("stub-c2 on " + p + "\n");
});
STUB
stub_proxy "$WORK/stub-c2.ts"
dvigatel "$PROXY" s2 home
if [ "$Z_RC" != 1 ] || ! soderzhit "$Z_REASON" "репорт порта не в data_dir конфига"; then
  die "С2: стаб «хардкод дома» не пойман (или пойман не той причиной): rc=$Z_RC причина: $Z_REASON"
fi
printf '  ok   С2: стаб «хардкод дома» пойман — репорт порта не в data_dir конфига\n' >&2

# ── С3: стаб «порт-только» — порт-файл раскрыт, секреты/журнал литеральны ──────
cat > "$WORK/stub-c3.ts" <<'STUB'
// Стаб С3 (064): .actual_port — в РАСКРЫТОМ data_dir (имитация фикса), но
// secrets_env читается и журнал пишется по ЛИТЕРАЛЬНЫМ путям конфига.
import * as http from "node:http";
import * as fs from "node:fs";
import * as path from "node:path";
const i = process.argv.indexOf("--config");
const cfg = JSON.parse(fs.readFileSync(process.argv[i + 1], "utf8"));
const expand = (s: string) => s.replace("${HOME}", process.env.HOME || "");
const ddPort = expand(cfg.data_dir);
fs.mkdirSync(ddPort, { recursive: true });
const srv = http.createServer((req, res) => {
  if (req.url === "/healthz") { res.statusCode = 200; res.end("ok"); return; }
  if (req.method === "POST") {
    const tok: Record<string, string> = {};
    try {
      for (const line of fs.readFileSync(cfg.secrets_env, "utf8").split("\n")) {
        const m = /^METERING_TOKEN_(\w+)=(.+)$/.exec(line);
        if (m) tok[m[2]] = m[1];
      }
    } catch { /* литеральный путь не существует — карта пуста */ }
    const auth = String(req.headers["authorization"] || "");
    const bearer = auth.startsWith("Bearer ") ? auth.slice(7) : "";
    if (!tok[bearer]) { res.statusCode = 401; res.end("no token"); return; }
    fs.mkdirSync(cfg.data_dir, { recursive: true });  // журнал — ЛИТЕРАЛЬНО
    fs.appendFileSync(path.join(cfg.data_dir, "calls.jsonl"), JSON.stringify({ rid: req.headers["x-request-id"] || "" }) + "\n");
    res.statusCode = 200; res.end("ok");
    return;
  }
  res.statusCode = 404; res.end();
});
srv.listen(0, "127.0.0.1", () => {
  const a = srv.address();
  const p = typeof a === "object" && a ? a.port : cfg.port;
  fs.writeFileSync(path.join(ddPort, ".actual_port"), String(p));
  process.stderr.write("stub-c3 on " + p + "\n");
});
STUB
stub_proxy "$WORK/stub-c3.ts"
dvigatel "$PROXY" s3 home
if [ "$Z_RC" != 1 ] || ! { soderzhit "$Z_REASON" "не 200" || soderzhit "$Z_REASON" "calls.jsonl не в data_dir"; }; then
  die "С3: стаб «порт-только» не пойман (или пойман не той причиной): rc=$Z_RC причина: $Z_REASON"
fi
printf '  ok   С3: стаб «порт-только» пойман — секреты/журнал не раскрыты\n' >&2

# ── Б: боль — честный прокси, конфиг с ${HOME} ─────────────────────────────────
cp "$REPO/scripts/proxy/metering_proxy.ts" "$PROXY"   # восстановить честную копию после стабов
dvigatel "$PROXY" bol home
if [ "$Z_RC" != 0 ]; then
  die "064 боль жива: прокси не раскрывает \${HOME} в data_dir/secrets_env — $Z_REASON"
fi
printf 'ok: 064 — ${HOME} раскрывается рантаймом (ЗК зелёный, С1-С3 пойманы, боль зелёная)\n' >&2
exit 0
