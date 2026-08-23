# ПРИЧИНА: healthz вернул
#
# Ветвь (а): healthz прокси обязан отвечать 200. Зелёный — реальный прокси из
# scripts/proxy/. Красный — заглушка, которая слушает на ТОМ ЖЕ порту, но
# отдаёт на /healthz не-200 (500). Ветвь (а) ловит и пишет «healthz вернул 500».
# Дефект наблюдаем ИМЕННО на ветви (а) — её единственная обязанность.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$(make_repo)"
WORK_REPO="$R"

# Зелёный контроль: реальный прокси. Остальные 6 ветвей и «pend» других
# агентов дают 0.
BARRIER_ROOT="$R" "$BARRIER" >/dev/null 2>&1 \
  || die "зелёный прогон барьера не 0 — реальный прокси не поднимается или ветвь (а) не зелёная"

# Стаб для красного: /healthz отдаёт 500, всё остальное 404. Дефект ровно один.
STUB_DIR="$(mktemp -d /tmp/mstub_a.XXXXXX)"
trap "rm -rf '$STUB_DIR'" EXIT
cat > "$STUB_DIR/metering_proxy.ts" <<'STUB'
// Стаб ветви (а): healthz 500. Минимальный код, только чтобы дефект проявился.
import * as http from "node:http";
import * as fs from "node:fs";
const i = process.argv.indexOf("--config");
const cfg = JSON.parse(fs.readFileSync(process.argv[i + 1], "utf8"));
const port = cfg.port;
const srv = http.createServer((req, res) => {
  if (req.url === "/healthz") { res.statusCode = 500; res.end("nope"); return; }
  res.statusCode = 404; res.end();
});
srv.listen(port, "127.0.0.1", () => { const _a = srv.address(); const _p = typeof _a === "object" && _a ? _a.port : port; fs.writeFileSync(cfg.data_dir + "/.actual_port", String(_p)); process.stderr.write("stub_a on " + _p + "\n"); });
STUB
stub_proxy "$STUB_DIR/metering_proxy.ts"

# Красный прогон.
set +e
out="$(BARRIER_ROOT="$R" "$BARRIER" 2>&1)"
rc=$?
set -e
[ "$rc" = "1" ] || die "красный прогон не 1: rc=$rc; вывод: $out"
printf '%s' "$out" | grep -qF "healthz вернул" \
  || die "красный прогон не назвал причину «healthz вернул»: $out"
exit 0
