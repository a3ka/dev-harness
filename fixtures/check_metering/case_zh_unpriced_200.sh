# ПРИЧИНА: ожидался 503 на модель без цены
#
# Ветвь (ж): модель без цены → 503 model_unpriced ДО запроса, upstream НЕ
# вызван, строки нет. Зелёный — реальный прокси. Красный — стаб, который
# цену не проверяет вовсе: 200 на ЛЮБОЙ запрос, unpriced неотличим от
# ценового — ветвь ловит «ожидался 503, получено 200».
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$(make_repo)"
WORK_REPO="$R"

BARRIER_ROOT="$R" "$BARRIER" >/dev/null 2>&1 \
  || die "зелёный прогон не 0 — реальный прокси не поднимается или ветвь (ж) не зелёная"

STUB_DIR="$(mktemp -d "${TMPDIR:-/tmp}/mstub_zh.XXXXXX")"
trap "rm -rf '$STUB_DIR'" EXIT
cat > "$STUB_DIR/metering_proxy.ts" <<'STUB'
// Стаб ветви (ж): цену НЕ проверяет — 200 на ЛЮБОЙ запрос, кроме healthz.
import * as http from "node:http";
import * as fs from "node:fs";
const i = process.argv.indexOf("--config");
const cfg = JSON.parse(fs.readFileSync(process.argv[i + 1], "utf8"));
const port = cfg.port;
const srv = http.createServer((req, res) => {
  if (req.url === "/healthz") { res.statusCode = 200; res.end('{"ok":true}'); return; }
  res.statusCode = 200;
  res.setHeader("content-type", "application/octet-stream");
  res.end("ok");
});
srv.listen(port, "127.0.0.1", () => process.stderr.write("stub_zh on " + port + "\n"));
STUB
stub_proxy "$STUB_DIR/metering_proxy.ts"

set +e
out="$(BARRIER_ROOT="$R" "$BARRIER" 2>&1)"
rc=$?
set -e
[ "$rc" = "1" ] || die "красный прогон не 1: rc=$rc; вывод: $out"
printf '%s' "$out" | grep -qF "ж: ожидался 503 на модель без цены" \
  || die "красный прогон не назвал причину «ж: ожидался 503 на модель без цены»: $out"
exit 0
