# ПРИЧИНА: тело ответа клиенту не равно телу upstream
#
# Ветвь (в): составной POST — 5 полей дословно, тройка ответа байт-в-байт,
# строка 11 полей с ненулевым usd. Зелёный — реальный прокси. Красный — стаб
# ПЕРЕСБОРКИ ответа: получает ответ upstream и ПЕРЕкодирует тело (оборачивает
# в JSON), отдаёт клиенту. Ветвь (в) ловит несовпадение байтов. Дефект
# наблюдаем именно на POST-входе: на нём тройка ответа проверяется полностью.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$(make_repo)"
WORK_REPO="$R"

BARRIER_ROOT="$R" "$BARRIER" >/dev/null 2>&1 \
  || die "зелёный прогон не 0 — реальный прокси не поднимается или ветвь (в) не зелёная"

STUB_DIR="$(mktemp -d /tmp/mstub_v.XXXXXX)"
trap "rm -rf '$STUB_DIR'" EXIT
cat > "$STUB_DIR/metering_proxy.ts" <<'STUB'
// Стаб ветви (в): пересборка ответа. Получает ответ upstream, оборачивает тело
// в JSON {"rewrapped": "<base64>"} и отдаёт клиенту. Байты не совпадают с
// upstream — ветвь (в) ловит на сверке sha256.
import * as http from "node:http";
import * as https from "node:http";  // любой порт
import * as fs from "node:fs";
const i = process.argv.indexOf("--config");
const cfg = JSON.parse(fs.readFileSync(process.argv[i + 1], "utf8"));
const port = cfg.port;
const upBase = Object.values(cfg.upstream)[0] as string;
const upUrl = new URL(upBase);

async function proxyUpstream(req: http.IncomingMessage, res: http.ServerResponse) {
  const chunks: Buffer[] = [];
  req.on("data", c => chunks.push(c));
  await new Promise<void>(r => req.on("end", () => r()));
  const body = Buffer.concat(chunks);
  // Прокидываем usage-заголовки.
  const upHeaders: Record<string, string> = {};
  for (const [k, v] of Object.entries(req.headers)) {
    if (Array.isArray(v)) upHeaders[k] = v.join(",");
    else if (typeof v === "string") upHeaders[k] = v;
  }
  const upReq = http.request({
    method: req.method || "POST",
    hostname: upUrl.hostname, port: upUrl.port,
    path: req.url, headers: upHeaders
  }, upRes => {
    const upChunks: Buffer[] = [];
    upRes.on("data", c => upChunks.push(c));
    upRes.on("end", () => {
      const upBody = Buffer.concat(upChunks);
      // ПЕРЕСБОРКА: оборачиваем тело в JSON.
      const wrapped = JSON.stringify({ rewrapped: upBody.toString("base64") });
      res.statusCode = upRes.statusCode || 200;
      const ct = upRes.headers["content-type"];
      if (ct) res.setHeader("content-type", String(ct));
      res.setHeader("x-rewrapped", "yes");
      res.end(Buffer.from(wrapped, "utf8"));
    });
  });
  upReq.on("error", () => { res.statusCode = 502; res.end("upstream_unreachable"); });
  upReq.write(body);
  upReq.end();
}

const srv = http.createServer((req, res) => {
  if (req.url === "/healthz") { res.statusCode = 200; res.end('{"ok":true}'); return; }
  // Токен НЕ валидируем — стаб для красного прогона.
  void proxyUpstream(req, res);
});
srv.listen(port, "127.0.0.1", () => { const _a = srv.address(); const _p = typeof _a === "object" && _a ? _a.port : port; fs.writeFileSync(cfg.data_dir + "/.actual_port", String(_p)); process.stderr.write("stub_v on " + _p + "\n"); });
STUB
stub_proxy "$STUB_DIR/metering_proxy.ts"

set +e
out="$(BARRIER_ROOT="$R" "$BARRIER" 2>&1)"
rc=$?
set -e
[ "$rc" = "1" ] || die "красный прогон не 1: rc=$rc; вывод: $out"
printf '%s' "$out" | grep -qF "тело ответа клиенту не равно телу upstream" \
  || die "красный прогон не назвал причину «тело ответа клиенту не равно телу upstream»: $out"
exit 0
