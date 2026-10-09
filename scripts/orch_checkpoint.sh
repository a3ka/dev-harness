#!/usr/bin/env bash
set -uo pipefail
P92L_ZAPIS="уже записано"
P92L_ZAPFAIL="запись состояния не удалась"
P92L_GRAMM_PRE="состояние вне грамматики: "
P92L_OPUBL_PRE="уже опубликовано: "
P92L_NEDOKAZ_PRE="публикация не доказана: "
P92L_SOSTOYANIE_NET="состояние отсутствует"
P92L_SOBYTIE_GRAMM="событие вне грамматики"
PYBIN=python3

: "${ORCH_STATE_DIR:=/tmp/dev-harness-verify/orch-state}"

if [ "$#" -lt 1 ]; then
  printf "NOT_IMPLEMENTED: нет subcommand\n" 1>&2
  exit 2
fi

case "$1" in
  init)
    [ "$#" -eq 3 ] || { printf "NOT_IMPLEMENTED: init требует <task> <ref>\n" 1>&2; exit 2; }
    SUBCMD=init; ARG_TASK="$2"; ARG_REF="$3"
    ;;
  get)
    [ "$#" -eq 2 ] || { printf "NOT_IMPLEMENTED: get требует <key>\n" 1>&2; exit 2; }
    SUBCMD=get; ARG_KEY="$2"
    ;;
  put)
    [ "$#" -eq 3 ] || { printf "NOT_IMPLEMENTED: put требует <key> <value>\n" 1>&2; exit 2; }
    SUBCMD=put; ARG_KEY="$2"; ARG_VALUE="$3"
    ;;
  event)
    [ "$#" -eq 4 ] || { printf "NOT_IMPLEMENTED: event требует <kind> <subject> <ref>\n" 1>&2; exit 2; }
    SUBCMD=event; ARG_KIND="$2"; ARG_SUBJECT="$3"; ARG_REF="$4"
    ;;
  --help|-h)
    printf "usage: %s {init|get|put|event}\n" "${BASH_SOURCE[0]##*/}" 1>&2
    exit 2
    ;;
  *)
    printf "NOT_IMPLEMENTED: неизвестный subcommand: %s\n" "$1" 1>&2
    exit 2
    ;;
esac

P92L_ZAPIS_ENV="$P92L_ZAPIS" \
P92L_ZAPFAIL_ENV="$P92L_ZAPFAIL" \
P92L_GRAMM_PRE_ENV="$P92L_GRAMM_PRE" \
P92L_OPUBL_PRE_ENV="$P92L_OPUBL_PRE" \
P92L_NEDOKAZ_PRE_ENV="$P92L_NEDOKAZ_PRE" \
P92L_SOSTOYANIE_NET_ENV="$P92L_SOSTOYANIE_NET" \
P92L_SOBYTIE_GRAMM_ENV="$P92L_SOBYTIE_GRAMM" \
ORCH_STATE_DIR_ENV="$ORCH_STATE_DIR" \
ORCH_REPO_ENV="${ORCH_REPO:-}" \
PYBIN=python3 \
"$PYBIN" - "$SUBCMD" "${ARG_TASK:-}" "${ARG_REF:-}" "${ARG_KEY:-}" "${ARG_VALUE:-}" "${ARG_KIND:-}" "${ARG_SUBJECT:-}" <<'PYEOF'
import os, re, sys, time

SUBCMD = sys.argv[1]
ARG_TASK = sys.argv[2]
ARG_REF = sys.argv[3]
ARG_KEY = sys.argv[4]
ARG_VALUE = sys.argv[5]
ARG_KIND = sys.argv[6]
ARG_SUBJECT = sys.argv[7]

STATE_DIR = os.environ["ORCH_STATE_DIR_ENV"]
REPO = os.environ.get("ORCH_REPO_ENV") or None

L_ZAPIS = os.environ["P92L_ZAPIS_ENV"]
L_ZAPFAIL = os.environ["P92L_ZAPFAIL_ENV"]
L_GRAMM = os.environ["P92L_GRAMM_PRE_ENV"]
L_OPUBL = os.environ["P92L_OPUBL_PRE_ENV"]
L_NEDOKAZ = os.environ["P92L_NEDOKAZ_PRE_ENV"]
L_SNET = os.environ["P92L_SOSTOYANIE_NET_ENV"]
L_EGR = os.environ["P92L_SOBYTIE_GRAMM_ENV"]

KEYS = ("task", "stage", "candidate", "last_proven", "waiting", "next_step", "pub_state")
STAGES = ("draft", "spec", "frozen", "implement", "judge", "publish", "close", "done")
PUBS = ("unknown", "nothing", "pushed", "merged", "published", "close_incomplete")
KINDS = ("task-init", "stage", "round-fail", "round-accept", "pub-start", "pub-done", "wait-start", "wait-done")
TOKENRE = r"[^\t\x00-\x1f\x7f]+"

STATE = os.path.join(STATE_DIR, "state.tsv")
EVENTS = os.path.join(STATE_DIR, "events.tsv")

def gitenv():
    return {k: v for k, v in os.environ.items() if k != "GIT_DIR" and k != "GIT_WORK_TREE" and not k.startswith("GIT_CONFIG")}

def git(args, repo=REPO):
    import subprocess
    if repo is None: return 1
    return subprocess.run(["git", "-C", repo] + args, capture_output=True, env=gitenv()).returncode

def out(s): sys.stdout.write(s + "\n")
def err(s): sys.stderr.write(s + "\n")
def refuse(msg, rc=1): err(msg); sys.exit(rc)

def gr(k, v):
    if k == "stage": return v in STAGES
    if k == "pub_state": return v in PUBS
    if k == "waiting": return v in ("none", "owner", "external") or re.fullmatch(r"ci:[0-9a-f]{40}", v) is not None or re.fullmatch(r"judge:[0-9]{3}", v) is not None
    if k == "task": return re.fullmatch(r"[0-9]{3}", v) is not None or (0 < len(v) <= 64 and re.fullmatch(TOKENRE, v) is not None)
    if k == "candidate": return v == "-" or re.fullmatch(r"[0-9a-f]{40}", v) is not None
    if k == "last_proven": return v == "-" or re.fullmatch(r"[a-z-]+@[0-9]+", v) is not None
    if k == "next_step": return 0 < len(v.encode("utf-8")) <= 200 and re.fullmatch(TOKENRE, v) is not None
    return False

def read_state_bytes():
    try:
        with open(STATE, "rb") as f: return f.read()
    except FileNotFoundError: return None

def read_state():
    data = read_state_bytes()
    if data is None: return None
    m = {}
    for raw in data.split(b"\n"):
        if not raw: continue
        line = raw.decode("utf-8", "surrogateescape")
        if "\t" not in line: refuse(L_GRAMM + "state")
        k, v = line.split("\t", 1)
        if k not in KEYS or k in m or not gr(k, v): refuse(L_GRAMM + k)
        m[k] = v
    for k in KEYS:
        if k not in m: refuse(L_GRAMM + k)
    return m

def state_bytes(m):
    return "".join(k + "\t" + m[k] + "\n" for k in KEYS).encode("utf-8")

def read_events():
    try:
        with open(EVENTS, "rb") as f: data = f.read()
    except FileNotFoundError: return []
    out_l = []
    for raw in data.split(b"\n"):
        if not raw: continue
        line = raw.decode("utf-8", "surrogateescape")
        parts = line.split("\t")
        if len(parts) == 4: out_l.append(parts)
    return out_l

def triple_exists(kind, subject, ref):
    for e in read_events():
        if e[1] == kind and e[2] == subject and e[3] == ref: return True
    return False

def ref_ok(kind, ref):
    if kind.startswith("round-"): return re.fullmatch(r"[^\t\x00-\x1f\x7f]+@[0-9a-f]{40}", ref) is not None
    if kind.startswith("pub-"): return re.fullmatch(r"[0-9a-f]{40}@[^\t\x00-\x1f\x7f]+", ref) is not None
    if kind.startswith("wait-"): return re.fullmatch(r"[0-9a-f]{40}", ref) is not None
    return re.fullmatch(r"[^\t\x00-\x1f\x7f]{0,200}", ref) is not None

def candidate_published(m):
    cand = m.get("candidate", "-")
    if cand == "-": return False
    return git(["merge-base", "--is-ancestor", cand, "refs/remotes/origin/main"]) == 0

def pub_proven(m):
    cand = m.get("candidate", "-")
    for e in read_events():
        if e[1] == "pub-done" and e[2] == m.get("task", "-") and e[3].split("@", 1)[0] == cand: return True
    return candidate_published(m)

def atomic_write_state(m):
    data = state_bytes(m)
    tmp = os.path.join(STATE_DIR, ".state.tsv.tmp")
    try:
        with open(tmp, "wb") as f:
            f.write(data)
            f.flush()
            os.fsync(f.fileno())
    except OSError:
        try: os.unlink(tmp)
        except OSError: pass
        refuse(L_ZAPFAIL)
    try:
        os.replace(tmp, STATE)
    except OSError:
        try: os.unlink(tmp)
        except OSError: pass
        refuse(L_ZAPFAIL)

def atomic_append_event(kind, subject, ref):
    ts = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
    line = (ts + "\t" + kind + "\t" + subject + "\t" + ref + "\n").encode("utf-8")
    try:
        with open(EVENTS, "ab") as f:
            f.write(line)
            f.flush()
            os.fsync(f.fileno())
    except OSError:
        refuse(L_ZAPFAIL)

def composite_write(m, kind, subject, ref):
    data = state_bytes(m)
    line = (time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()) + "\t" + kind + "\t" + subject + "\t" + ref + "\n").encode("utf-8")
    tmp = os.path.join(STATE_DIR, ".state.tsv.tmp")
    try:
        with open(tmp, "wb") as f:
            f.write(data)
            f.flush()
            os.fsync(f.fileno())
    except OSError:
        try: os.unlink(tmp)
        except OSError: pass
        refuse(L_ZAPFAIL)
    try:
        with open(EVENTS, "ab") as f:
            f.write(line)
            f.flush()
            os.fsync(f.fileno())
    except OSError:
        try: os.unlink(tmp)
        except OSError: pass
        refuse(L_ZAPFAIL)
    try:
        os.replace(tmp, STATE)
    except OSError:
        try: os.unlink(tmp)
        except OSError: pass
        refuse(L_ZAPFAIL)

if SUBCMD == "get":
    if ARG_KEY not in KEYS: refuse(L_GRAMM + ARG_KEY)
    m = read_state()
    if m is None: refuse(L_SNET)
    out(m[ARG_KEY])
    sys.exit(0)

if SUBCMD == "put":
    if ARG_KEY not in KEYS: refuse(L_GRAMM + ARG_KEY)
    if not gr(ARG_KEY, ARG_VALUE): refuse(L_GRAMM + ARG_KEY)
    m = read_state()
    if m is None:
        m = {"task": "-", "stage": "draft", "candidate": "-", "last_proven": "-", "waiting": "none", "next_step": "-", "pub_state": "unknown"}
    if ARG_KEY == "pub_state" and ARG_VALUE == "published" and not pub_proven(m):
        refuse(L_NEDOKAZ + m.get("candidate", "-"))
    m[ARG_KEY] = ARG_VALUE
    atomic_write_state(m)
    sys.exit(0)

if SUBCMD == "init":
    if not gr("task", ARG_TASK): refuse(L_GRAMM + "task")
    if triple_exists("task-init", ARG_TASK, ARG_REF):
        out(L_ZAPIS)
        sys.exit(0)
    m = read_state()
    if m is None:
        m = {"task": ARG_TASK, "stage": "draft", "candidate": "-", "last_proven": "-", "waiting": "none", "next_step": "-", "pub_state": "unknown"}
    else:
        m["task"] = ARG_TASK
    composite_write(m, "task-init", ARG_TASK, ARG_REF)
    sys.exit(0)

if SUBCMD == "event":
    if ARG_KIND not in KINDS: refuse(L_EGR)
    if not ref_ok(ARG_KIND, ARG_REF): refuse(L_EGR)
    if triple_exists(ARG_KIND, ARG_SUBJECT, ARG_REF):
        out(L_ZAPIS)
        sys.exit(0)
    if ARG_KIND == "pub-start":
        for e in read_events():
            if e[1] == "pub-done" and e[3] == ARG_REF:
                refuse(L_OPUBL + ARG_REF.split("@", 1)[0])
    if ARG_KIND == "pub-done":
        m = read_state()
        if m is None:
            m = {"task": ARG_SUBJECT, "stage": "draft", "candidate": "-", "last_proven": "-", "waiting": "none", "next_step": "-", "pub_state": "published"}
        m["pub_state"] = "published"
        composite_write(m, ARG_KIND, ARG_SUBJECT, ARG_REF)
        sys.exit(0)
    atomic_append_event(ARG_KIND, ARG_SUBJECT, ARG_REF)
    sys.exit(0)

err("NOT_IMPLEMENTED: subcommand " + SUBCMD)
sys.exit(2)
PYEOF
