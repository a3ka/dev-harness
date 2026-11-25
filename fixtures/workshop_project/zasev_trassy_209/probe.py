#!/usr/bin/env python3
"""209: real launcher -> archive -> make_task; bound judge evidence stays factual.

All worlds are disposable repositories under TMPDIR. The launcher and its real
chain are copied without alteration, except the selected workshop model/mutant.
Expected artifacts are literals in memory. The unchanged frozen launcher supplies
FULL byte stdout/stderr oracles before each subject invocation in the same world.
Only bash's NUL-input warning line numbers and the added assigned-model usage
literal for an empty --object are normalized, each only in its own case.
"""
import argparse
import contextlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
FROZEN = "frozen/contracts/204/1"
OLD = b'''prepare_model_trace() {
  local runtime="${HARNESS_SESSION_HOME:-$HOME}/runtime" raw
  mkdir -p "$runtime" || die "\xd0\xbd\xd0\xb5 \xd1\x81\xd0\xbe\xd0\xb7\xd0\xb4\xd0\xb0\xd1\x82\xd1\x8c runtime \xd1\x82\xd1\x80\xd0\xb0\xd1\x81\xd1\x81\xd1\x8b: $runtime"
  export HARNESS_MODEL_TRACE="$runtime/model-trace.tsv"
  raw="$runtime/model-trace.$$.raw"
  if bash "$HERE/scripts/models_actual.sh" --tsv >"$raw" 2>"$raw.error"; then
    awk -F'\\t' 'NF == 3 && $1 != "" && $1 != "orchestrator" && !seen[$1]++ {print}' \\
      "$raw" >"$HARNESS_MODEL_TRACE.new"
  else
    printf 'TRACE_ARCHIVE_NOT_READY: '; cat "$raw.error" >&2
    : >"$HARNESS_MODEL_TRACE.new"
  fi
  chmod 600 "$HARNESS_MODEL_TRACE.new"
  mv -f "$HARNESS_MODEL_TRACE.new" "$HARNESS_MODEL_TRACE"
  rm -f "$raw" "$raw.error"
}
'''
ROLES = ("architect", "critic", "implementer", "implementer-glm", "adversary", "reviewer", "arbiter")
ROWS = tuple((r, f"toy/station-{i}", "denied" if r == "implementer" else "allowed")
             for i, r in enumerate(ROLES))
SEED = b"".join(("\t".join(row) + "\n").encode() for row in reversed(ROWS))
OWN = b"architect\ttoy/project-own\tallowed\n"
OBJECT = "0123456789abcdef0123456789abcdef01234567"
SOURCE_ERROR = "ОТКАЗ: TRACE_SEED_SOURCE_INVALID: bootstrapTrace должен быть station\n".encode()
UNKNOWN = b"TRACE_SEED_ROLE_UNKNOWN: outsider\n"
NO_BIND = "ОТКАЗ: трасса без привязки (нужно 5 полей: роль TAB модель TAB allowed|denied TAB session TAB object)\n".encode()
OMP = b'''#!/usr/bin/env bash
if [ "${1:-}" = --version ]; then printf 'omp/209-toy\\n'; exit 0; fi
printf 'EXEC\\n' >> "$OMP_STUB_LOG"
exit 0
'''


class ProbeFault(RuntimeError):
    pass


def run(argv, cwd, env=None, timeout=120):
    try:
        return subprocess.run(argv, cwd=cwd, env=env, capture_output=True, timeout=timeout)
    except (OSError, subprocess.TimeoutExpired) as exc:
        raise ProbeFault(f"environment: {exc}") from exc


def checked(argv, cwd, env=None):
    result = run(argv, cwd, env)
    if result.returncode:
        raise ProbeFault(f"command rc={result.returncode}: {argv!r}: {result.stderr!r}")
    return result.stdout


def replace_one(data, old, new):
    if data.count(old) != 1:
        raise ProbeFault(f"ORACLE_TAMPERED anchor multiplicity={data.count(old)}: {old!r}")
    return data.replace(old, new, 1)


def frozen(path):
    return checked(["git", "show", f"{FROZEN}:{path}"], ROOT)


def result_tuple(result):
    return result.returncode, result.stdout, result.stderr


def content(path):
    return path.read_bytes() if path.is_file() else None


def trace_file(zone, role, model, index, session=None, obj=None):
    zone.mkdir(parents=True, exist_ok=True)
    name = session or f"station-{role}"
    rows = [{"agent": role}, {"type": "model_change", "model": model,
                              "resolvedModelIsFallback": role == "implementer"}]
    if obj is not None:
        rows.append({"type": "message", "message": {"role": "user", "content": [
            {"type": "text", "text": f"OBJECT={obj}\n"}]}})
    path = zone / f"{name}.jsonl"
    path.write_bytes(b"".join(json.dumps(row, separators=(",", ":")).encode() + b"\n" for row in rows))
    os.utime(path, (1700000000 + index, 1700000000 + index))


class World:
    def __init__(self, base, source, subject, legacy):
        self.base = base
        self.tools = base / "tools"
        self.tools.mkdir()
        for item in ("scripts", "roles", "config", ".omp"):
            shutil.copytree(source / item, self.tools / item,
                            ignore=shutil.ignore_patterns(".git", "__pycache__"))
        for item in ("AGENTS.md", "package.json"):
            shutil.copy2(source / item, self.tools / item)
        overrides = subject if isinstance(subject, dict) else {"workshop": subject}
        self.subject, self.legacy = overrides["workshop"], legacy
        for rel, data in overrides.items():
            (self.tools / rel).write_bytes(data)
        self.workshop = self.tools / "workshop"
        self.home = base / "home"
        self.home.mkdir()
        self.bin = base / "bin"
        self.bin.mkdir()
        (self.bin / "omp").write_bytes(OMP)
        (self.bin / "omp").chmod(0o755)
        self.log = base / "exec.log"
        self.state = base / "state"
        self.station = base / "station"
        for i, (role, model, _) in enumerate(ROWS):
            trace_file(self.station, role, model, i)
        trace_file(self.station, "orchestrator", "toy/live-orchestrator", 20)
        # A repeated older role event must not duplicate a seed role.
        trace_file(self.station, "architect", "toy/stale", -1, session="older-architect")
        env = self.env()
        env["TMPDIR"] = str(base)
        toy = checked(["bash", "-c", '. "$1"; _t95_world zasev209', "_",
                       str(ROOT / "fixtures/context_pack_095/_toy.sh")], base, env)
        self.toy = Path(os.fsdecode(toy).rstrip("\n"))
        self.repo = self.toy / "repo"
        self.profile = self.repo / "harness.project.json"
        self.profile_bytes = self.profile.read_bytes()
        (self.repo / "ci.yml").write_bytes(b"name: toy\n")
        (self.repo / "config").mkdir()
        (self.repo / "config/harness_pin.json").write_bytes(b'{"version":"209-toy"}\n')
        (self.repo / ".env").write_bytes(b"# isolated test environment\n")
        checked(["git", "-C", str(self.repo), "config", "receive.denyCurrentBranch", "refuse"], base, env)
        checked(["bash", "-c", '. "$1"; _t95_freeze "$2" scripts/toy.sh', "_",
                 str(ROOT / "fixtures/context_pack_095/_toy.sh"), str(self.repo)], base, env)
        self.env_base = self.env()
        self.env_base["HARNESS_PROJECT_LAYER_ROOT"] = str(self.repo)

    @property
    def project_home(self):
        return self.state / "dev-harness-projects/toy-project/home"

    @property
    def archive(self):
        return self.project_home / "runtime/model-trace.tsv"

    @property
    def mark(self):
        return self.project_home / "runtime/model-trace.seed.tsv"

    def env(self):
        return {"PATH": f"{self.bin}:{os.environ.get('PATH', '/usr/bin:/bin')}",
                "HOME": str(self.home), "LC_ALL": "C", "XDG_STATE_HOME": str(self.state),
                "HARNESS_SESSION_HOME": str(self.station), "OMP_STUB_LOG": str(self.log),
                "ZAI_API_KEY": "stub", "METERING_PROXY_URL": "http://stub",
                "METERING_PROXY_TOKEN": "stub", "MINIMAX_API_KEY": "stub",
                "GIT_CONFIG_GLOBAL": "/dev/null", "GIT_CONFIG_SYSTEM": "/dev/null"}

    def source_value(self, value):
        profile = json.loads(self.profile_bytes)
        profile["bootstrapTrace"] = value
        self.profile.write_bytes(json.dumps(profile).encode() + b"\n")

    def launch(self, dev=False, invalid=False, unknown=b""):
        runtime = (self.station if dev else self.project_home) / "runtime"
        saved = {p.name: (p.read_bytes(), p.stat().st_mode & 0o777)
                 for p in runtime.iterdir()} if runtime.is_dir() else {}
        args = ["bash", str(self.workshop)] + ([] if dev else [str(self.repo)])
        # Same genuine launch chain, same absolute paths; only the frozen
        # implementation supplies stdout/stderr expectations before the subject.
        self.workshop.write_bytes(self.legacy)
        self.log.unlink(missing_ok=True)
        reference = run(args, self.base, self.env_base)
        if reference.returncode != 0 or content(self.log) != b"EXEC\n":
            raise ProbeFault(f"reference launch unavailable: {result_tuple(reference)!r}")
        if runtime.exists():
            shutil.rmtree(runtime)
        if saved:
            runtime.mkdir(parents=True)
            for name, (data, mode) in saved.items():
                (runtime / name).write_bytes(data)
                (runtime / name).chmod(mode)
        self.workshop.write_bytes(self.subject)
        self.log.unlink(missing_ok=True)
        observed = run(args, self.base, self.env_base)
        wanted = (1 if invalid else 0, reference.stdout,
                  reference.stderr + (SOURCE_ERROR if invalid else unknown))
        healthy = observed.returncode in (0, 1)
        if not healthy:
            raise ProbeFault(f"subject launch failed outside its contract: {result_tuple(observed)!r}")
        ok = result_tuple(observed) == wanted and content(self.log) == (None if invalid else b"EXEC\n")
        if not ok:
            print(f"209 OUTPUT wanted={wanted!r} observed={result_tuple(observed)!r}")
        return ok

    def task(self, role, expected_trace):
        path = self.archive
        path.parent.mkdir(parents=True, exist_ok=True)
        saved = content(path)
        path.write_bytes(expected_trace)
        args = ["bash", str(self.tools / "scripts/make_task.sh"), "--repo", str(self.repo),
                "--role", role, "--contract", "777", "--task-file", str(self.toy / "task.md"),
                "--model-trace", str(path)]
        oracle = run(args, self.base, self.env_base)
        if oracle.returncode != (1 if role == "outsider" else 0):
            raise ProbeFault(f"make_task honest control unavailable ({role}): {result_tuple(oracle)!r}")
        if saved is None:
            path.unlink()
        else:
            path.write_bytes(saved)
        actual = run(args, self.base, self.env_base)
        return result_tuple(actual) == result_tuple(oracle)

    def sud(self, trace, accepted=False):
        registry = self.tools / "registry"
        registry.mkdir(exist_ok=True)
        journal = registry / "candidates.tsv"
        journal.write_bytes(b"")
        verdict = self.base / "verdict.md"
        verdict.write_bytes(b"accept\n")
        oid = "a" * 64
        got = run(["bash", str(self.tools / "scripts/judge_gate.sh"), OBJECT,
                   "--verdict-row", "toy-209", oid, str(verdict), "--sud",
                   "critic", str(trace), "judge-209"], self.base, self.env_base)
        if accepted:
            stdout = ("СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт critic материализуется\n"
                      f"verdict-строка записана: toy-209 {oid} accept\n").encode()
            return (result_tuple(got) == (0, stdout, b"")
                    and content(journal) == f"verdict\ttoy-209\t{oid}\taccept\t1\n".encode())
        return result_tuple(got) == (2, b"", NO_BIND) and content(journal) == b""


@contextlib.contextmanager
def world(source, subject, legacy):
    parent = Path(os.environ.get("TMPDIR", tempfile.gettempdir()))
    parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="zasev209-", dir=parent) as path:
        yield World(Path(path), source, subject, legacy)


def cases(source, subject, legacy, only=None):
    results = {}

    def emit(name, ok):
        if only is None or name in only:
            results[name] = bool(ok)
            print(f"209 {name} {'ok' if ok else 'KRASNO'}")

    def needs(*names):
        return only is None or bool(set(names) & set(only))

    a = ("pustoj", "metka", "archive-mode", "make-task", "bind", "sud-gate", "vytesnenie", "idempotentnost")
    if needs(*a):
        with world(source, subject, legacy) as w:
            boot = w.launch()
            emit("pustoj", boot and content(w.archive) == SEED)
            emit("metka", boot and content(w.mark) == SEED
                 and w.mark.stat().st_mode & 0o777 == 0o600)
            emit("archive-mode", boot and content(w.archive) == SEED and content(w.mark) == SEED
                 and w.archive.stat().st_mode & 0o777 == 0o600
                 and w.mark.stat().st_mode & 0o777 == 0o600)
            if needs("make-task"):
                emit("make-task", all([w.task(role, SEED) for role in ROLES]))
            if needs("bind"):
                env = dict(w.env_base, HARNESS_SESSION_HOME=str(w.project_home))
                actual = run(["bash", str(w.tools / "scripts/models_actual.sh"), "--tsv", "--bind"], w.base, env)
                refused = run(["bash", str(w.tools / "scripts/check_sud_model.sh"), "--verdict", "critic",
                               "--trace", str(w.archive), "--object", OBJECT, "--session", "judge-209"], w.base, env)
                emit("bind", result_tuple(actual) == (2, b"", b"NOT_IMPLEMENTED: \xd1\x82\xd1\x80\xd0\xb5\xd0\xb9\xd1\x81\xd0\xbe\xd0\xb2 \xd0\xb2 \xd0\xb7\xd0\xbe\xd0\xbd\xd0\xb5 \xd0\xbd\xd0\xb5\xd1\x82\n")
                     and result_tuple(refused) == (2, b"", NO_BIND))
            if needs("sud-gate"):
                emit("sud-gate", w.sud(w.archive))
            if needs("idempotentnost"):
                repeat = w.launch()
                emit("idempotentnost", repeat and content(w.archive) == SEED and content(w.mark) == SEED)
            if needs("vytesnenie"):
                trace_file(w.project_home, "architect", "toy/project-own", 40)
                displaced = w.launch()
                remaining = SEED.replace(b"architect\ttoy/station-0\tallowed\n", b"")
                emit("vytesnenie", displaced and content(w.archive) == OWN + remaining
                     and content(w.mark) == remaining and w.task("architect", OWN + remaining))

    if needs("nepustoj"):
        with world(source, subject, legacy) as w:
            trace_file(w.project_home, "architect", "toy/project-own", 40)
            emit("nepustoj", w.launch() and content(w.archive) == OWN and content(w.mark) is None)

    if needs("rejestr"):
        with world(source, subject, legacy) as w:
            trace_file(w.station, "outsider", "toy/unregistered", 30)
            emit("rejestr", w.launch(unknown=UNKNOWN) and content(w.archive) == SEED
                 and content(w.mark) == SEED and w.task("outsider", SEED))

    if needs("partial-role"):
        with world(source, subject, legacy) as w:
            trace_file(w.station, "implementer-g", "toy/unregistered-prefix", 30)
            emit("partial-role", w.launch(unknown=b"TRACE_SEED_ROLE_UNKNOWN: implementer-g\n")
                 and content(w.archive) == SEED and content(w.mark) == SEED)

    if needs("istochnik"):
        with world(source, subject, legacy) as w:
            fake = w.station / "runtime/model-trace.tsv"
            fake.parent.mkdir()
            fake.write_bytes(b"architect\ttoy/forged-file\tallowed\n")
            emit("istochnik", w.launch() and content(w.archive) == SEED
                 and content(fake) == b"architect\ttoy/forged-file\tallowed\n")

    if needs("existing-archive"):
        with world(source, subject, legacy) as w:
            previous = b"architect\ttoy/existing\tallowed\n"
            w.archive.parent.mkdir(parents=True)
            w.archive.write_bytes(previous)
            emit("existing-archive", w.launch() and content(w.archive) == previous
                 and content(w.mark) is None)

    if needs("empty-mark"):
        with world(source, subject, legacy) as w:
            previous = b"architect\ttoy/own\tallowed\n"
            refusal = (1, b"", "ОТКАЗ: свидетельство не той роли: critic\n".encode())
            w.archive.parent.mkdir(parents=True)
            w.archive.write_bytes(previous)
            w.mark.write_bytes(b"")
            w.mark.chmod(0o600)
            args = ["bash", str(w.tools / "scripts/make_task.sh"), "--repo", str(w.repo),
                    "--role", "critic", "--contract", "777", "--task-file", str(w.toy / "task.md"),
                    "--model-trace", str(w.archive)]
            before = run(args, w.base, w.env_base)
            if result_tuple(before) != refusal:
                raise ProbeFault(f"empty-mark refusal control unavailable: {result_tuple(before)!r}")
            launched = w.launch()
            after = run(args, w.base, w.env_base)
            emit("empty-mark", launched and content(w.archive) == previous
                 and content(w.mark) == b"" and result_tuple(after) == refusal)

    if needs("station-explicit"):
        with world(source, subject, legacy) as w:
            w.source_value("station")
            emit("station-explicit", w.launch() and content(w.archive) == SEED and content(w.mark) == SEED)

    invalids = (("source-path", "/tmp/forged-trace.tsv"), ("source-empty", ""),
                ("source-nul", "station\0"), ("source-crlf", "station\r\n"),
                ("source-case", "Station"), ("source-null", None),
                ("source-array", ["station"]), ("source-object", {"source": "station"}))
    for name, value in invalids:
        if needs(name):
            with world(source, subject, legacy) as w:
                w.source_value(value)
                emit(name, w.launch(invalid=True) and content(w.archive) is None and content(w.mark) is None)

    if needs("source-nonutf8"):
        with world(source, subject, legacy) as w:
            profile = json.loads(w.profile_bytes)
            profile["bootstrapTrace"] = "station"
            w.profile.write_bytes(json.dumps(profile).encode().replace(
                b'"bootstrapTrace": "station"', b'"bootstrapTrace": "stat\xffion"'))
            emit("source-nonutf8", w.launch(invalid=True)
                 and content(w.archive) is None and content(w.mark) is None)

    if needs("dev"):
        with world(source, subject, legacy) as w:
            emit("dev", w.launch(dev=True) and content(w.station / "runtime/model-trace.tsv") == SEED
                 and content(w.station / "runtime/model-trace.seed.tsv") is None)

    if needs("judge-fact"):
        with world(source, subject, legacy) as w:
            model = checked(["node", str(w.tools / "scripts/roles.ts"), "--resolve-model", "critic", "--root", str(w.tools)], w.base).split(b"\t")[1]
            trace_file(w.project_home, "critic", model.decode(), 41, "judge-209", OBJECT)
            env = dict(w.env_base, HARNESS_SESSION_HOME=str(w.project_home))
            got = run(["bash", str(w.tools / "scripts/models_actual.sh"), "--bind", "--session", "judge-209"], w.base, env)
            want = b"critic\t" + model + b"\tallowed\tjudge-209\t" + OBJECT.encode() + b"\n"
            trace = w.base / "bound.tsv"
            trace.write_bytes(got.stdout)
            judged = run(["bash", str(w.tools / "scripts/check_sud_model.sh"), "--verdict", "critic", "--trace", str(trace), "--session", "judge-209", "--object", OBJECT], w.base, env)
            recorded = w.sud(trace, accepted=True)
            emit("judge-fact", result_tuple(got) == (0, want, b"")
                 and result_tuple(judged) == (0, "СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт critic материализуется\n".encode(), b"")
                 and recorded)

    if needs("sud-boundaries"):
        with world(source, subject, legacy) as w:
            trace = w.base / "seed.tsv"
            trace.write_bytes(b"critic\ttoy/station\tallowed\n")
            door = w.tools / "scripts/check_sud_model.sh"
            door_subject = door.read_bytes()
            door_legacy = frozen("scripts/check_sud_model.sh")
            values = (b"", OBJECT.encode(), OBJECT.upper().encode(), b"a" * 39, b"a" * 41, b"a" * 39 + b"\r", b"\xff" * 40)

            def empty_object_result(result):
                stderr = result.stderr.replace(b" [--assigned-model <selector>]", b"", 1)
                return result.returncode, result.stdout, stderr

            ok = True
            for obj in values:
                tail = ["--verdict", "critic", "--trace", str(trace), "--object", obj, "--session", "judge-209"]
                door.write_bytes(door_legacy)
                oracle = run(["bash", str(door), *tail], w.base, w.env_base)
                door.write_bytes(door_subject)
                actual = run(["bash", str(door), *tail], w.base, w.env_base)
                observed = empty_object_result(actual) if obj == b"" else result_tuple(actual)
                ok &= oracle.returncode != 0 and observed == result_tuple(oracle)
            # NUL is data in a file, never an impossible execve argument.
            def nul_result(result):
                stderr = re.sub(
                    rb"(?m)^(" + re.escape(os.fsencode(door))
                    + rb": line )[0-9]+(: warning: command substitution: ignored null byte in input)$",
                    rb"\g<1>N\g<2>", result.stderr)
                return result.returncode, result.stdout, stderr

            trace.write_bytes(b"critic\ttoy/station\tallowed\0\n")
            tail = ["--verdict", "critic", "--trace", str(trace), "--object", OBJECT, "--session", "judge-209"]
            door.write_bytes(door_legacy)
            oracle = run(["bash", str(door), *tail], w.base, w.env_base)
            door.write_bytes(door_subject)
            actual = run(["bash", str(door), *tail], w.base, w.env_base)
            emit("sud-boundaries", ok and oracle.returncode != 0 and nul_result(actual) == nul_result(oracle))

    if not results:
        raise ProbeFault("empty cell selection")
    return results


def mutations(model):
    return {
        "FILE-AS-SOURCE": replace_one(model,
            b'if HARNESS_SESSION_HOME="$ZONE" bash "$HERE/scripts/models_actual.sh" --tsv >"$raw" 2>"$raw.error"; then',
            b'if cat "$ZONE/runtime/model-trace.tsv" >"$raw" 2>"$raw.error"; then'),
        "NO-REGISTRY": replace_one(model, b'if grep -Fx -- "$role" "$roles" >/dev/null; then', b'if true; then'),
        "DROP-ACTUAL": replace_one(model, b'cat "$seed" >>"$HARNESS_MODEL_TRACE.new"', b': >"$HARNESS_MODEL_TRACE.new"; cat "$seed" >>"$HARNESS_MODEL_TRACE.new"'),
        "NO-DISPLACE": replace_one(model, b'!($1 in fact)', b'1'),
        "SEED-NONEMPTY": replace_one(model, b'[ ! -s "$HARNESS_MODEL_TRACE.new" ] && [ ! -s "$seed" ]', b'[ ! -s "$seed" ]'),
        "NO-MARK": replace_one(model, b'mv -f "$seed.new" "$seed"\n      rm -f', b'mv -f "$seed.new" "$seed.hidden"\n      rm -f'),
        "DUPLICATE": replace_one(model, b'cat "$seed" >>"$HARNESS_MODEL_TRACE.new"', b'cat "$seed" "$seed" >>"$HARNESS_MODEL_TRACE.new"'),
        "SOURCE-OVERRIDE": replace_one(model, b'if [ "$source" != true ]; then', b'if false; then'),
        "EMPTY-FIRST-AWK": replace_one(model, b'FILENAME == ARGV[1]', b'NR == FNR'),
        "EMPTY-MARK": replace_one(model,
            b'if [ ! -s "$HARNESS_MODEL_TRACE.new" ] && [ -s "$HARNESS_MODEL_TRACE" ] && [ ! -s "$seed" ]; then',
            b'if [ ! -s "$HARNESS_MODEL_TRACE.new" ] && [ -s "$HARNESS_MODEL_TRACE" ] && [ ! -e "$seed" ]; then'),
        "ARCHIVE-MODE": replace_one(model, b'chmod 600 "$HARNESS_MODEL_TRACE.new"',
            b'chmod 644 "$HARNESS_MODEL_TRACE.new"'),
        "PARTIAL-ROLE": replace_one(model, b'grep -Fx -- "$role" "$roles"',
            b'grep -F -- "$role" "$roles"'),
        "OVERWRITE-EXISTING": replace_one(model, b'if [ ! -s "$HARNESS_MODEL_TRACE.new" ] && [ -s "$HARNESS_MODEL_TRACE" ] && [ ! -s "$seed" ]; then',
            b'if false; then'),
        "DROP-ROLE": replace_one(model, b'done <"$raw.rows"',
            b'''done < <(awk -F'\\t' '$1 != "architect"' "$raw.rows")'''),
        "BIND-AS-FACT": {
            "workshop": model,
            "scripts/models_actual.sh": replace_one(frozen("scripts/models_actual.sh"),
                b'if [ "$TSV" = "1" ]; then',
                b'''if [ "$TSV" = "1" ]; then
  if [ "$BIND" = "1" ] && [ -s "$ZONE/runtime/model-trace.tsv" ]; then
    cat "$ZONE/runtime/model-trace.tsv"
    exit 0
  fi''')},
        "JUDGE-ACCEPTS-SEED": {
            "workshop": model,
            "scripts/check_sud_model.sh": replace_one(frozen("scripts/check_sud_model.sh"),
                b'  verdict)\n',
                b'  verdict)\n    exit 0\n')},
        "JUDGE-GATE-BYPASS": {
            "workshop": model,
            "scripts/judge_gate.sh": replace_one(frozen("scripts/judge_gate.sh"),
                b'  [ "$rc" -eq 0 ] || exit "$rc"\n',
                b'  : # deceptive: records a refused witness\n')},
    }


def main():
    parser = argparse.ArgumentParser()
    modes = parser.add_mutually_exclusive_group(required=True)
    modes.add_argument("--repo", type=Path)
    modes.add_argument("--model", action="store_true")
    modes.add_argument("--stabs", action="store_true")
    args = parser.parse_args()
    try:
        legacy = frozen("workshop")
        model = replace_one(legacy, OLD, (HERE / "model/prepare_model_trace_209.txt").read_bytes())
        source = args.repo.resolve() if args.repo else ROOT
        if args.repo:
            subject = (source / "workshop").read_bytes()
            findings = cases(source, subject, legacy)
            green = sum(findings.values())
            print(f"209 KLETKI={len(findings)} ZELENYE={green} KRASNYE={len(findings) - green}")
            return 0 if all(findings.values()) else 1
        if args.model:
            findings = cases(ROOT, model, legacy)
            green = sum(findings.values())
            print(f"209 KLETKI={len(findings)} ZELENYE={green} KRASNYE={len(findings) - green}")
            return 0 if all(findings.values()) else 2
        bindings = []
        for line in (HERE / "stabs.tsv").read_bytes().split(b"\n"):
            if line and not line.startswith(b"#"):
                name, cell = line.decode("ascii").split("\t")
                bindings.append((name, cell))
        stabs = mutations(model)
        if not bindings or set(stabs) != {name for name, _ in bindings}:
            raise ProbeFault("ORACLE_TAMPERED mutation inventory")
        caught = 0
        for name, cell in bindings:
            control = cases(ROOT, model, legacy, {cell})
            if not all(control.values()):
                raise ProbeFault(f"CONTROL_INVALID {name}@{cell}")
            with tempfile.TemporaryDirectory(prefix="zasev209-syntax-", dir=os.environ.get("TMPDIR")) as tmp:
                sources = stabs[name] if isinstance(stabs[name], dict) else {"workshop": stabs[name]}
                for index, data in enumerate(sources.values()):
                    path = Path(tmp) / f"mutant-{index}.sh"
                    path.write_bytes(data)
                    checked(["bash", "-n", str(path)], ROOT)
            observed = cases(ROOT, stabs[name], legacy, {cell})
            detected = not observed[cell]
            caught += detected
            print(f"209 STAB {name} {'caught' if detected else 'ZHIV'} @ {cell}")
        print(f"209 MUTACII={len(stabs)} SVJAZI={len(bindings)} POIMANY={caught} ZHIVYH={len(bindings) - caught}")
        return 0 if caught == len(bindings) else 1
    except (ProbeFault, OSError, ValueError, KeyError) as exc:
        print(f"209 NOT_IMPLEMENTED: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
