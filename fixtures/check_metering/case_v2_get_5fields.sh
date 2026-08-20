# ПРИЧИНА: ожидался GET
#
# Ветвь (в2): составной GET — 5 полей дословно. Зелёный — реальный прокси.
# Красный — стаб POST-only: ЛЮБОЙ метод, включая GET, превращает в POST.
# Ветвь (в2) ловит «upstream получил POST, ожидался GET». Дефект наблюдаем
# именно на GET-входе: на POST-входе (ветвь в) POST-only стаб честен — он
# передаёт POST как POST.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$(make_repo)"
WORK_REPO="$R"

BARRIER_ROOT="$R" "$BARRIER" >/dev/null 2>&1 \
  || die "зелёный прогон не 0 — реальный прокси не поднимается или ветвь (в2) не зелёная"

STUB_DIR="$(mktemp -d /tmp/mstub_v2.XXXXXX)"
trap "rm -rf '$STUB_DIR'" EXIT
cat > "$STUB_DIR/metering_proxy.ts" <<'STUB'
// Стаб ветви (в2): POST-only ретранслятор. ЛЮБОЙ метод клиента (включая GET)
// превращается в POST при прокидывании на upstream. На ветви (в) это честно
// (POST→POST), на (в2) — дефект: GET приходит к upstream как POST.
import * as http from "node:http";
import * as fs from "node:fs";
const i = process.argv.indexOf("--config");
const cfg = JSON.parse(fs.readFileSync(process.argv[i + 1], "utf8"));
const port = cfg.port;
const upBase = Object.values(cfg.upstream)[0] as string;
const upUrl = new URL(upBase);

const srv = http.createServer((req, res) => {
  if (req.url === "/healthz") { res.statusCode = 200; res.end('{"ok":true}'); return; }
  const chunks: Buffer[] = [];
  req.on("data", c => chunks.push(c));
  req.on("end", () => {
    const body = Buffer.concat(chunks);
    // Конверсия: GET → POST.
    const fwdMethod = "POST";
    const upHeaders: Record<string, string> = { "content-type": "application/octet-stream" };
    for (const [k, v] of Object.entries(req.headers)) {
      if (Array.isArray(v)) upHeaders[k] = v.join(",");
      else if (typeof v === "string") upHeaders[k] = v;
    }
    const upReq = http.request({
      method: fwdMethod, hostname: upUrl.hostname, port: upUrl.port,
      path: req.url, headers: upHeaders
    }, upRes => {
      const upChunks: Buffer[] = [];
      upRes.on("data", c => upChunks.push(c));
      upRes.on("end", () => {
        const upBody = Buffer.concat(upChunks);
        res.statusCode = upRes.statusCode || 200;
        const ct = upRes.headers["content-type"];
        if (ct) res.setHeader("content-type", String(ct));
        res.end(upBody);
      });
    });
    upReq.on("error", () => { res.statusCode = 502; res.end("upstream_unreachable"); });
    upReq.write(body);
    upReq.end();
  });
});
srv.listen(port, "127.0.0.1", () => process.stderr.write("stub_v2 on " + port + "\n"));
STUB
stub_proxy "$STUB_DIR/metering_proxy.ts"

set +e
out="$(BARRIER_ROOT="$R" "$BARRIER" 2>&1)"
rc=$?
set -e
[ "$rc" = "1" ] || die "красный прогон не 1: rc=$rc; вывод: $out"
printf '%s' "$out" | grep -qF "ожидался GET" \
  || die "красный прогон не назвал причину «ожидался GET»: $out"
exit 0
