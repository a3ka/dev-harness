# ПРИЧИНА: ожидался 200 при переходе потолка
#
# Ветвь (г): составной переход потолка — бюджет < ceiling, вызов ПЕРЕСЕКАЕТ →
# запрос проходит, budget после > ceiling. Зелёный — реальный прокси.
# Красный — стаб, подменяющий ответ на 402 и не пишущий стоимость: на ЛЮБОЙ
# запрос отдаёт 402 и не пишет журнальную строку. Ветвь (г) ожидает 200 и
# ловит «ожидался 200 при переходе потолка ПРОХОДИТ, получено 402». Этот же
# стаб не даёт прокси-циклу на остальных ветвях записи usd в бюджет, и (в)/(
# в2)/(г2) валятся по своим причинам — но причина (г) «ожидался 200 при
# переходе потолка ПРОХОДИТ, получено 402» в выводе остаётся.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$(make_repo)"
WORK_REPO="$R"

BARRIER_ROOT="$R" "$BARRIER" >/dev/null 2>&1 \
  || die "зелёный прогон не 0 — реальный прокси не поднимается или ветвь (г) не зелёная"

STUB_DIR="$(mktemp -d /tmp/mstub_g.XXXXXX)"
trap "rm -rf '$STUB_DIR'" EXIT
cat > "$STUB_DIR/metering_proxy.ts" <<'STUB'
// Стаб ветви (г): на ЛЮБОЙ запрос (валидный токен, нормальный budget) отдаёт
// 402. Стоимость НЕ списывается, журнал НЕ пишется. Это именно та подмена,
// которую контракт называет «стаб, подменяющий ответ на 402 и не пишущий
// стоимость». Ветвь (г) ожидает 200 при переходе потолка — ловит.
import * as http from "node:http";
import * as fs from "node:fs";
const i = process.argv.indexOf("--config");
const cfg = JSON.parse(fs.readFileSync(process.argv[i + 1], "utf8"));
const port = cfg.port;
const srv = http.createServer((req, res) => {
  if (req.url === "/healthz") { res.statusCode = 200; res.end('{"ok":true}'); return; }
  res.statusCode = 402;
  res.setHeader("content-type", "application/json");
  res.end(JSON.stringify({
    error: "ceiling_exceeded",
    period: "1970-01", provider: "stub", spent_usd: 0, limit_usd: 0
  }));
});
srv.listen(port, "127.0.0.1", () => process.stderr.write("stub_g on " + port + "\n"));
STUB
stub_proxy "$STUB_DIR/metering_proxy.ts"

set +e
out="$(BARRIER_ROOT="$R" "$BARRIER" 2>&1)"
rc=$?
set -e
[ "$rc" = "1" ] || die "красный прогон не 1: rc=$rc; вывод: $out"
printf '%s' "$out" | grep -qF "ожидался 200 при переходе потолка" \
  || die "красный прогон не назвал причину «ожидался 200 при переходе потолка»: $out"
exit 0
