# ПРИЧИНА: 402 обязан писаться строкой
#
# Ветвь (г2): исчерпанный потолок → 402 ДО запроса, тело 402 несёт состояние
# бюджета {period, provider, spent_usd, limit_usd}, ПЛЮС строка полной схемы
# usd=0. Зелёный — реальный прокси. Красный — стаб с 402 И без строки: на
# запрос отдаёт 402 с ВЕРНЫМ телом (period/provider/spent_usd/limit_usd
# читаются из budget.json и config на КАЖДОМ запросе), НО журнальной строки
# НЕ пишет. Ветвь (г2) ловит отсутствие строки и пишет «402 обязан писаться
# строкой».
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$(make_repo)"
WORK_REPO="$R"

BARRIER_ROOT="$R" "$BARRIER" >/dev/null 2>&1 \
  || die "зелёный прогон не 0 — реальный прокси не поднимается или ветвь (г2) не зелёная"

STUB_DIR="$(mktemp -d /tmp/mstub_g2.XXXXXX)"
trap "rm -rf '$STUB_DIR'" EXIT
cat > "$STUB_DIR/metering_proxy.ts" <<'STUB'
// Стаб ветви (г2): 402 с ВЕРНЫМ телом, НО без строки журнала. Главный дефект:
// 402 обязан писаться строкой полной схемы, стаб не пишет. spent_usd читается
// на КАЖДОМ запросе: барьер кладёт budget.json ПОСЛЕ старта прокси, и снимок
// при загрузке видит нули.
import * as http from "node:http";
import * as fs from "node:fs";
const i = process.argv.indexOf("--config");
const cfg = JSON.parse(fs.readFileSync(process.argv[i + 1], "utf8"));
const port = cfg.port;
const provider = Object.keys(cfg.upstream)[0] || "stub";
const period = new Date().toISOString().slice(0, 7);
const limitUsd = (cfg.ceilings && cfg.ceilings[provider] && cfg.ceilings[provider].usd_per_month) || 0;
const srv = http.createServer((req, res) => {
  if (req.url === "/healthz") { res.statusCode = 200; res.end('{"ok":true}'); return; }
  let spentUsd = 0;
  try {
    const b = JSON.parse(fs.readFileSync(cfg.data_dir + "/budget.json", "utf8"));
    spentUsd = (b[period] && b[period][provider]) || 0;
  } catch (_) {}
  res.statusCode = 402;
  res.setHeader("content-type", "application/json");
  res.end(JSON.stringify({
    error: "ceiling_exceeded",
    period, provider, spent_usd: spentUsd, limit_usd: limitUsd
  }));
});
srv.listen(port, "127.0.0.1", () => { const _a = srv.address(); const _p = typeof _a === "object" && _a ? _a.port : port; fs.writeFileSync(cfg.data_dir + "/.actual_port", String(_p)); process.stderr.write("stub_g2 on " + _p + "\n"); });
STUB
stub_proxy "$STUB_DIR/metering_proxy.ts"

set +e
out="$(BARRIER_ROOT="$R" "$BARRIER" 2>&1)"
rc=$?
set -e
[ "$rc" = "1" ] || die "красный прогон не 1: rc=$rc; вывод: $out"
printf '%s' "$out" | grep -qF "402 обязан писаться строкой" \
  || die "красный прогон не назвал причину «402 обязан писаться строкой»: $out"
exit 0
