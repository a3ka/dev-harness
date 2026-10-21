#!/usr/bin/env bash
# omp_stand.sh — one run of the REAL omp binary against stub_provider.py (contract 129).
#
# usage: omp_stand.sh <world-dir> <plan.json>
#   <world-dir>/proj/ — project tree prepared by battery.py from the SUBJECT
#                       (.omp/agents, .omp/config.yml, config/agent_models.json,
#                       optional .omp/extensions/fallback-route.ts).
#   <plan.json>       — stub behaviour (stub_provider.py) + "providers":
#                       {"<provider>": ["<model id>", ...]} declared in models.yml.
# Writes <world-dir>/out.txt (omp stdout+stderr) and <world-dir>/requests.jsonl.
# Exit code = omp exit code; 124 = stand timeout (STAND_TIMEOUT, default 120 s).
set -u
W="$1"; PLAN="$2"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$W/home/.omp/agent" "$W/sessions"
: > "$W/requests.jsonl"
rm -f "$W/port"
python3 "$HERE/stub_provider.py" "$W/port" "$PLAN" "$W/requests.jsonl" &
SPID=$!
trap 'kill "$SPID" 2>/dev/null; wait "$SPID" 2>/dev/null' EXIT
for _ in $(seq 1 50); do [ -s "$W/port" ] && break; sleep 0.1; done
[ -s "$W/port" ] || { echo "STAND: stub did not start" >&2; exit 3; }
python3 - "$PLAN" "$(cat "$W/port")" "$W/home/.omp/agent/models.yml" <<'PY'
import json, sys
plan, port, out = json.load(open(sys.argv[1])), sys.argv[2], sys.argv[3]
lines = ["providers:"]
for prov, ids in plan["providers"].items():
    lines += [f"  {prov}:", f"    baseUrl: http://127.0.0.1:{port}/v1",
              "    api: openai-completions", "    auth: none", "    models:"]
    for i in ids:
        lines += [f"      - id: {i}", f"        name: {i}",
                  "        contextWindow: 200000", "        maxTokens: 8192"]
open(out, "w").write("\n".join(lines) + "\n")
PY
# Stand overlay (not the subject): the parent BLOCKS on each child, so every
# child's yield or failure reaches the parent's final text inside one run.
printf 'async:\n  enabled: false\n' > "$W/stand-overlay.yml"
# Extensions by DISCOVERY (as live): the parent finds <proj>/.omp/extensions/, each isolated
# child finds its own copy in its workspace. HOME is empty, so nothing else is discovered.
( cd "$W/proj" && env -i PATH="$PATH" HOME="$W/home" TMPDIR="$W" TERM=dumb \
    timeout "${STAND_TIMEOUT:-120}" omp -p --no-title --no-lsp --no-skills --no-rules \
      --config "$W/stand-overlay.yml" \
      --auto-approve --session-dir "$W/sessions" --model stub-main/main \
      "Run the stand." ) > "$W/out.txt" 2>&1
exit $?
