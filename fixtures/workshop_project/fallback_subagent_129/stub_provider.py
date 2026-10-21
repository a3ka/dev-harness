#!/usr/bin/env python3
"""Stub OpenAI-chat-completions provider for contract 129 (fallback-subagent).

usage: stub_provider.py <port-file> <plan.json> <requests.jsonl>

One process serves every model of the stand's `stub` provider. plan.json:

  {"_marker": "M129",                 # child yields {"marker": _marker, "model": <id>}
   "_sib_marker": "SIB129",           # prompt marker of the SIBLING child
   "_main_script": [{"name": .., "args": {..}}, ...],  # parent tool calls, in order
   "models": {"<id>": MODE | {"sib": MODE, "default": MODE}}}

MODE:
  main        parent: emits _main_script[k] where k = number of tool results
              already in the conversation; then final text repeating every tool
              result (the child's yield or failure reaches stdout).
  quota       429 + z.ai body code 1310 "Weekly/Monthly Limit Exhausted" with a
              retry-after far beyond retry.maxDelayMs — byte shape of the live
              failure (omp log 2026-10-21, errorStatus 429, retry-after-ms≈3.1e7).
  validation  400 invalid_request_error (a request defect, not a quota wall).
  error500    500 upstream error (unknown class: omp puts the selector into a
              shared cooldown — the sibling-failure half of the live deaths).
  ok          child: first request -> tool call `yield`; afterwards -> text.

A {"sib": .., "default": ..} pair selects by whether the request's messages carry
_sib_marker, so one model can fail for the sibling and serve everybody else.

Every request appends one JSON line {"model", "sib", "status"} to
<requests.jsonl>; batteries count requests per model from THIS log (the stand's
memory), never from the subject's files.
"""
import json
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

PORT_FILE, PLAN_FILE, LOG_FILE = sys.argv[1], sys.argv[2], sys.argv[3]
PLAN = json.load(open(PLAN_FILE))
MODELS = PLAN["models"]

QUOTA_BODY = json.dumps({
    "type": "error",
    "error": {
        "type": "rate_limit_error",
        "code": "1310",
        "message": "[1310][Weekly/Monthly Limit Exhausted. Your limit will reset at 2099-01-01 00:00:00][stub129]",
    },
    "request_id": "stub129",
}).encode()
VALIDATION_BODY = json.dumps({"error": {
    "type": "invalid_request_error", "code": "invalid_request_error",
    "message": "stub129: messages.0.content: field required"}}).encode()
ERROR500_BODY = json.dumps({"error": {"message": "stub129: upstream hiccup"}}).encode()


def chunk(model, delta, finish=None):
    return {"id": "stub129", "object": "chat.completion.chunk", "created": 0, "model": model,
            "choices": [{"index": 0, "delta": delta, "finish_reason": finish}]}


def tool_messages(body):
    return [m for m in body.get("messages") or [] if m.get("role") == "tool"]


def text_of(m):
    c = m.get("content")
    if isinstance(c, list):
        c = "".join(p.get("text", "") for p in c if isinstance(p, dict))
    return str(c)


class H(BaseHTTPRequestHandler):
    def log_message(self, *a):
        pass

    def _json(self, code, payload, headers=()):
        self.send_response(code)
        self.send_header("content-type", "application/json")
        for k, v in headers:
            self.send_header(k, v)
        self.send_header("content-length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def _stream(self, model, events):
        self.send_response(200)
        self.send_header("content-type", "text/event-stream")
        self.send_header("cache-control", "no-cache")
        self.end_headers()
        for ev in events:
            self.wfile.write(b"data: " + json.dumps(ev).encode() + b"\n\n")
        self.wfile.write(b"data: [DONE]\n\n")
        self.wfile.flush()

    def _tool(self, model, name, args):
        self._stream(model, [
            chunk(model, {"role": "assistant", "tool_calls": [{
                "index": 0, "id": "call_stub129", "type": "function",
                "function": {"name": name, "arguments": json.dumps(args)}}]}),
            chunk(model, {}, "tool_calls"),
        ])

    def _text(self, model, text):
        self._stream(model, [chunk(model, {"role": "assistant", "content": text}), chunk(model, {}, "stop")])

    def do_POST(self):
        n = int(self.headers.get("content-length") or 0)
        body = json.loads(self.rfile.read(n) or b"{}")
        model = str(body.get("model", ""))
        sib = PLAN.get("_sib_marker", "\0") in json.dumps(body.get("messages") or [])
        mode = MODELS.get(model, "unknown")
        if isinstance(mode, dict):
            mode = mode["sib" if sib else "default"]
        # "turn": the request carries tool definitions — an agent turn, not a side
        # request (session title, auto-thinking judge) that also hits role models.
        with open(LOG_FILE, "a") as f:
            f.write(json.dumps({"model": model, "sib": sib, "status": mode,
                                "turn": bool(body.get("tools"))}) + "\n")
        if mode == "quota":
            self._json(429, QUOTA_BODY, [("retry-after-ms", "31561000"), ("retry-after", "31561")])
        elif mode == "validation":
            self._json(400, VALIDATION_BODY)
        elif mode == "error500":
            self._json(500, ERROR500_BODY)
        elif mode == "main":
            script = PLAN.get("_main_script") or []
            done = tool_messages(body)
            if len(done) < len(script):
                step = script[len(done)]
                self._tool(model, step["name"], step["args"])
            else:
                self._text(model, "PARENT_SAW:\n" + "\n".join(text_of(m) for m in done))
        elif mode == "ok":
            if tool_messages(body):
                self._text(model, "child done")
            else:
                self._tool(model, "yield", {"data": {"marker": PLAN["_marker"], "model": model}})
        else:
            self._json(404, json.dumps({"error": {"message": "stub129: unknown model " + model}}).encode())


srv = ThreadingHTTPServer(("127.0.0.1", 0), H)
with open(PORT_FILE, "w") as f:
    f.write(str(srv.server_address[1]))
srv.serve_forever()
