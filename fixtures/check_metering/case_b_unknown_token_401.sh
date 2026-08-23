# ПРИЧИНА: ожидался 401
#
# Ветвь (б): неизвестный токен → 401, строки нет. Зелёный — реальный прокси
# отдаёт 401 на неизвестный токен. Красный — стаб, который отдаёт 200 на ЛЮБОЙ
# токен. Ветвь (б) ловит «ожидался 401, получено 200». Дефект наблюдаем именно
# на ветви (б).
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$(make_repo)"
WORK_REPO="$R"

BARRIER_ROOT="$R" "$BARRIER" >/dev/null 2>&1 \
  || die "зелёный прогон не 0 — реальный прокси не поднимается или ветвь (б) не зелёная"

STUB_DIR="$(mktemp -d /tmp/mstub_b.XXXXXX)"
trap "rm -rf '$STUB_DIR'" EXIT
cat > "$STUB_DIR/metering_proxy.ts" <<'STUB'
// Стаб ветви (б): 200 на ЛЮБОЙ токен. Дефект: аутентификация не работает.
// Без auth-логики прокси не отличает валидный токен от мусора, и ветвь (б)
// видит 200 вместо 401.
import * as http from "node:http";
import * as fs from "node:fs";
const i = process.argv.indexOf("--config");
const cfg = JSON.parse(fs.readFileSync(process.argv[i + 1], "utf8"));
const port = cfg.port;
const upBase = Object.values(cfg.upstream)[0] as string;
const srv = http.createServer((req, res) => {
  if (req.url === "/healthz") { res.statusCode = 200; res.end('{"ok":true}'); return; }
  // Любой запрос (валидный/невалидный токен) → 200, тело «ok».
  res.statusCode = 200;
  res.setHeader("content-type", "application/octet-stream");
  res.end("ok");
});
srv.listen(port, "127.0.0.1", () => { const _a = srv.address(); const _p = typeof _a === "object" && _a ? _a.port : port; fs.writeFileSync(cfg.data_dir + "/.actual_port", String(_p)); process.stderr.write("stub_b on " + _p + "\n"); });
STUB
stub_proxy "$STUB_DIR/metering_proxy.ts"

set +e
out="$(BARRIER_ROOT="$R" "$BARRIER" 2>&1)"
rc=$?
set -e
[ "$rc" = "1" ] || die "красный прогон не 1: rc=$rc; вывод: $out"
printf '%s' "$out" | grep -qF "ожидался 401" \
  || die "красный прогон не назвал причину «ожидался 401»: $out"
exit 0
