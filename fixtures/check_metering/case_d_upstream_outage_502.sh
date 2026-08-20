# ПРИЧИНА: ожидался 502 при обрыве upstream
#
# Ветвь (д): обрыв upstream → клиенту 502 + строка полной схемы status=502
# tokens/usd=0. Зелёный — реальный прокси, который при обрыве отдаёт 502
# клиенту и пишет строку. Красный — стаб, который возвращает 200 на ЛЮБОЙ
# запрос (не замечает обрыв upstream, потому что не делает реальных вызовов).
# Ветвь (д) ловит «ожидался 502 при обрыве upstream, получено 200».
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$(make_repo)"
WORK_REPO="$R"

BARRIER_ROOT="$R" "$BARRIER" >/dev/null 2>&1 \
  || die "зелёный прогон не 0 — реальный прокси не поднимается или ветвь (д) не зелёная"

STUB_DIR="$(mktemp -d /tmp/mstub_d.XXXXXX)"
trap "rm -rf '$STUB_DIR'" EXIT
cat > "$STUB_DIR/metering_proxy.ts" <<'STUB'
// Стаб ветви (д): НЕ ходит в upstream, отдаёт 200 на ЛЮБОЙ запрос. Обрыв
// upstream необнаружим — клиент получает 200 вместо 502.
import * as http from "node:http";
import * as fs from "node:fs";
const i = process.argv.indexOf("--config");
const cfg = JSON.parse(fs.readFileSync(process.argv[i + 1], "utf8"));
const port = cfg.port;
const srv = http.createServer((req, res) => {
  if (req.url === "/healthz") { res.statusCode = 200; res.end('{"ok":true}'); return; }
  // Токен НЕ валидируем; upstream НЕ вызываем; 200 и тело «ok».
  res.statusCode = 200;
  res.setHeader("content-type", "application/octet-stream");
  res.end("ok");
});
srv.listen(port, "127.0.0.1", () => process.stderr.write("stub_d on " + port + "\n"));
STUB
stub_proxy "$STUB_DIR/metering_proxy.ts"

set +e
out="$(BARRIER_ROOT="$R" "$BARRIER" 2>&1)"
rc=$?
set -e
[ "$rc" = "1" ] || die "красный прогон не 1: rc=$rc; вывод: $out"
printf '%s' "$out" | grep -qF "ожидался 502 при обрыве upstream" \
  || die "красный прогон не назвал причину «ожидался 502 при обрыве upstream»: $out"
exit 0
