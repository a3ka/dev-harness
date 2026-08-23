#!/usr/bin/env bash
# ПРИЧИНА: маркер мёртв
#
# Ветвь (е): маркер append-only жив после прогона, удалённый budget.json
# пересобран --rebuild-budget и РАВЕН свёртке журнала. Два независимых красных
# дефекта (по контракту):
#   1) appendLog через truncate+write (вместо appendFileSync) → маркер мёртв;
#   2) --rebuild-budget пишет КОНСТАНТУ (не из журнала).
# Фикстура ловит дефект (1): подставной прокси перезаписывает calls.jsonl при
# appendLog — маркер .appendonly.json остаётся со старым sha256, и ветвь (е)
# находит «--verify-appendonly вернул 1 — маркер мёртв». Дефект (1)
# фундаментальнее дефекта (2): без согласованного маркера любая проверка
# целостности журнала бессмысленна. Дефект (2) ловится той же ветвью (е) на
# полной проверке rebuild-vs-fold — фикстура для него не пишется отдельная,
# потому что ветвь одна, и каждый дефект виден на своём шаге.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$(make_repo)"
WORK_REPO="$R"

BARRIER_ROOT="$R" "$BARRIER" >/dev/null 2>&1 \
  || die "зелёный прогон не 0 — реальный прокси не поднимается или ветвь (е) не зелёная"

STUB_DIR="$(mktemp -d /tmp/mstub_e.XXXXXX)"
trap "rm -rf '$STUB_DIR'" EXIT
cat > "$STUB_DIR/metering_proxy.ts" <<'STUB'
// Стаб ветви (е): appendLog ПЕРЕЗАПИСЫВАЕТ calls.jsonl (truncate+write вместо
// appendFileSync). Маркер .appendonly.json НЕ обновляется, его bytes/sha256
// расходятся с содержимым calls.jsonl. --verify-appendonly возвращает 1,
// ветвь (е) находит «маркер мёртв».
import * as http from "node:http";
import * as fs from "node:fs";
import * as crypto from "node:crypto";
import * as path from "node:path";

const args = process.argv.slice(2);
let cfgPath = null;
const flags = new Set();
for (let i = 0; i < args.length; i++) {
  if (args[i] === "--config") { cfgPath = args[++i]; continue; }
  flags.add(args[i]);
}
const cfg = JSON.parse(fs.readFileSync(cfgPath, "utf8"));
const port = cfg.port;
const dataDir = cfg.data_dir;
const callsFile = path.join(dataDir, "calls.jsonl");
const markerFile = path.join(dataDir, ".appendonly.json");
fs.mkdirSync(dataDir, { recursive: true });

if (flags.has("--verify-appendonly")) {
  // Маркер обязан существовать и сойтись с префиксом calls.jsonl.
  // В стабе маркер НЕ обновляется → всегда 1.
  if (!fs.existsSync(callsFile) || !fs.existsSync(markerFile)) process.exit(1);
  const m = JSON.parse(fs.readFileSync(markerFile, "utf8"));
  if (typeof m.bytes !== "number" || typeof m.sha256 !== "string") process.exit(1);
  const curBytes = fs.statSync(callsFile).size;
  if (curBytes < m.bytes) process.exit(1);
  if (curBytes === m.bytes) {
    const buf = fs.readFileSync(callsFile);
    const sha = crypto.createHash("sha256").update(buf).digest("hex");
    if (sha !== m.sha256) process.exit(1);
  } else {
    const fd = fs.openSync(callsFile, "r");
    const buf = Buffer.alloc(m.bytes);
    fs.readSync(fd, buf, 0, m.bytes, 0);
    fs.closeSync(fd);
    const sha = crypto.createHash("sha256").update(buf).digest("hex");
    if (sha !== m.sha256) process.exit(1);
  }
  process.exit(0);
}
if (flags.has("--rebuild-budget")) {
  // ЧЕСТНАЯ пересборка из журнала (этот дефект ловится другим стабом; здесь он
  // работает корректно, чтобы ветвь (е) дошла до проверки маркера первой).
  const budget = {};
  if (fs.existsSync(callsFile)) {
    for (const line of fs.readFileSync(callsFile, "utf8").split("\n")) {
      if (!line) continue;
      try {
        const rec = JSON.parse(line);
        const period = new Date(rec.ts).toISOString().slice(0, 7);
        if (!budget[period]) budget[period] = {};
        budget[period][rec.provider] = String(bigAdd(budget[period][rec.provider] || "0", rec.usd));
      } catch {}
    }
  }
  fs.writeFileSync(path.join(dataDir, "budget.json"), JSON.stringify(budget));
  process.exit(0);
}

function bigAdd(a, b) {
  // BigInt-сложение, чтобы стаб не терял точность за 2^53.
  return (BigInt(a) + BigInt(b)).toString();
}

function appendLog(entry) {
  const line = JSON.stringify({
    ts: entry.ts, role: entry.role, provider: entry.provider, model: entry.model,
    path: entry.path, tokens_in: entry.tokens_in, tokens_out: entry.tokens_out,
    usd: String(entry.usd), latency_ms: entry.latency_ms, status: entry.status,
    request_id: entry.request_id,
  }) + "\n";
  fs.writeFileSync(callsFile, line);  // ← ДЕФЕКТ: truncate, не append.
  // Маркер НЕ обновляем — это часть дефекта: реальный прокси обновляет,
  // иначе verify-appendonly проходит.
}

const srv = http.createServer((req, res) => {
  if (req.url === "/healthz") { res.statusCode = 200; res.end('{"ok":true}'); return; }
  appendLog({
    ts: Date.now(), role: "stub", provider: req.url.split("/")[1] || "", model: "",
    path: req.url, tokens_in: 0, tokens_out: 0, usd: "0", latency_ms: 0, status: 200,
    request_id: req.headers["x-request-id"] || "",
  });
  res.statusCode = 200;
  res.setHeader("content-type", "application/octet-stream");
  res.end("ok");
});
srv.listen(port, "127.0.0.1", () => { const _a = srv.address(); const _p = typeof _a === "object" && _a ? _a.port : port; fs.writeFileSync(cfg.data_dir + "/.actual_port", String(_p)); process.stderr.write("stub_e on " + _p + "\n"); });
STUB
stub_proxy "$STUB_DIR/metering_proxy.ts"

set +e
out="$(BARRIER_ROOT="$R" "$BARRIER" 2>&1)"
rc=$?
set -e
[ "$rc" = "1" ] || die "красный прогон не 1: rc=$rc; вывод: $out"
printf '%s' "$out" | grep -qF "маркер мёртв" \
  || die "красный прогон не назвал причину «маркер мёртв»: $out"
exit 0
