#!/usr/bin/env python3
"""170: public make_task CLI, independent memory oracle, honest model and deceptive subjects."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[3]
TOY = ROOT / "fixtures/context_pack_095/_toy.sh"
VERIFY = Path("/tmp/dev-harness-verify")
BASE = "frozen/contracts/166/2:scripts/make_task.sh"

# The model applies the same public protocol to the stable pre-170 CLI. It is
# deliberately not a production edit; --repo always runs the caller's tree.
ADDITION = r'''
ARCH_PATH=""
if [ "$KIND" = task ] && [ -d "$REPO/architecture" ]; then
  _backend="$(printf '%s' "$MERGED" | jq -r '.repoId.value // ""')"
  _code=0
  printf '%s\n' "$CBYTES" | grep -Eiq '^КЛАСС ЗАДАЧИ: (кодовый|КОДОВЫЙ)' && _code=1
  if [ "$_backend" = Complior-back ] && [ "$_code" = 1 ] && [ -z "$ARCH_COMPONENT" ]; then
    die "ARCH_COMPONENT_NET: кодовый предмет бэкенда требует --arch-component <id>"
  fi
fi
if [ -n "$ARCH_COMPONENT" ]; then
  case "$ARCH_COMPONENT" in *[!A-Za-z0-9._-]*|''|.*|*..*|*/*) die "ARCH_COMPONENT_ID: вне алфавита" ;; esac
  [ -d "$REPO/architecture" ] || die "ARCHITECTURE_NET: нет architecture/"
  [ -f "$REPO/architecture/checks/cli.js" ] || die "CLI_NET: нет architecture/checks/cli.js"
  command -v node >/dev/null 2>&1 || die "NODE_NET: node не найден"
  _arch_err="$(mktemp)"
  _arch_out="$(mktemp)"
  if ! ( cd "$REPO/architecture" && node checks/cli.js brief --component "$ARCH_COMPONENT" ) >"$_arch_out" 2>"$_arch_err"; then
    rm -f "$_arch_out" "$_arch_err"
    die "BRIEF_CLI_OTKAZ: architecture/checks/cli.js brief --component $ARCH_COMPONENT"
  fi
  rm -f "$_arch_err"
  _arch_lines="$(awk 'END {print NR}' "$_arch_out")"
  if [ "$_arch_lines" -eq 0 ] || [ ! -s "$_arch_out" ]; then rm -f "$_arch_out"; die "BRIEF_PUSTOJ: $ARCH_COMPONENT"; fi
  if [ "$_arch_lines" -gt 300 ]; then rm -f "$_arch_out"; die "BRIEF_SLISHKOM_DLINNYJ: $_arch_lines > 300"; fi
  ARCH_PATH="architecture/generated/briefs/$ARCH_COMPONENT.md"
  mkdir -p "$REPO/architecture/generated/briefs" || die "BRIEF_NE_ZAPISAN: $ARCH_PATH"
  mv "$_arch_out" "$REPO/$ARCH_PATH" || die "BRIEF_NE_ZAPISAN: $ARCH_PATH"
  ARCH_LINE="BRIEF: $ARCH_PATH :: lines=$_arch_lines"
  ARCH_MAN="brief${TAB}${ARCH_PATH}${TAB}mandatory${TAB}architecture
"
  MAP_LINES="$(printf '%s' "$MAP_LINES" | grep -v '^MAP: STRUCTURE.md ::' || true)"
  [ -z "$MAP_LINES" ] || MAP_LINES="${MAP_LINES}
"
fi
'''


def replace_once(text, anchor, replacement):
    if text.count(anchor) != 1:
        raise ValueError(f"model anchor {anchor!r}: {text.count(anchor)} occurrences")
    return text.replace(anchor, replacement)


def model_text():
    text = subprocess.run(["git", "-C", str(ROOT), "show", BASE], capture_output=True, text=True, check=True).stdout
    text = replace_once(text, 'PRINT_CONTEXT=0\nwhile [ $# -gt 0 ]; do', 'PRINT_CONTEXT=0; ARCH_COMPONENT=""\nwhile [ $# -gt 0 ]; do')
    text = replace_once(text, '    --print-context) PRINT_CONTEXT=1; shift ;;', '    --print-context) PRINT_CONTEXT=1; shift ;;\n    --arch-component) ARCH_COMPONENT="${2:-}"; [ -n "$ARCH_COMPONENT" ] || die "ARCH_COMPONENT_ID: пустой id"; shift 2 ;;')
    text = replace_once(text, 'fi\n\nTRACE_MAN=', 'fi\n' + ADDITION + '\nTRACE_MAN=')
    text = replace_once(text, "  printf '=== REUSE ===\\n%s' \"$REUSE_LINES\"", "  printf '=== REUSE ===\\n%s' \"$REUSE_LINES\"\n  if [ -n \"$ARCH_PATH\" ]; then printf '=== BRIEF ===\\n%s\\n' \"$ARCH_LINE\"; fi")
    text = replace_once(text, '${MAP_MAN}${CTX_MAN}${ADR_MAN}', '${MAP_MAN}${ARCH_MAN}${CTX_MAN}${ADR_MAN}')
    text = replace_once(text, 'MAP_LINES=""; RULES_LINES=""; REUSE_LINES=""; MAP_MAN=""', 'MAP_LINES=""; RULES_LINES=""; REUSE_LINES=""; MAP_MAN=""; ARCH_MAN=""')
    return text


def world(tmp, *, architecture=True, code=True, backend=True, n=2, cli=True):
    built = subprocess.run(["bash", "-c", '. "$1"; _t95_world arch-170', "_", str(TOY)], capture_output=True, text=True, check=True).stdout.strip()
    repo = Path(built) / "repo"
    (repo / "ci.yml").write_text("name: toy\n")
    profile = repo / "harness.project.json"
    data = json.loads(profile.read_text())
    data["repoId"] = "Complior-back" if backend else "Complior-mob"
    data["language"] = "javascript"
    data["contextPack"]["rows"].append({"kind": "map", "path": "STRUCTURE.md", "roles": "architect,critic,implementer", "mandatory": True, "why": "all modules"})
    profile.write_text(json.dumps(data, ensure_ascii=False))
    (repo / "STRUCTURE.md").write_text("# Legacy structure\n")
    contract = repo / "contracts/777-toy.md"
    contract.write_text("КЛАСС ЗАДАЧИ: " + ("кодовый" if code else "документальный") + "\n" + contract.read_text())
    (repo / "registry/trace.tsv").write_text("architect\topenai-codex/gpt-6-sol\tallowed\n")
    if architecture:
        checks = repo / "architecture/checks"
        checks.mkdir(parents=True)
        if cli:
            (checks / "cli.js").write_text('''const fs = require('fs');
if (process.argv.length !== 5 || process.argv[2] !== 'brief' || process.argv[3] !== '--component') {
  console.error('UNSUPPORTED_OPTION'); process.exit(13);
}
const id = process.argv[4];
if (id === 'missing.module') { console.error('UNKNOWN_COMPONENT'); process.exit(14); }
const n = Number(process.env.TOY_BRIEF_LINES || '2');
for (let i = 0; i < n; i++) console.log(i === 0 ? `Element: ${id}` : `port.${id}.${i}`);
''')
    return built, repo


def invoke(subject, repo, component=None, *, env=None):
    argv = ["bash", str(subject), "--repo", str(repo), "--role", "architect", "--contract", "777", "--model-trace", str(repo / "registry/trace.tsv")]
    if component is not None:
        argv += ["--arch-component", component]
    return subprocess.run(argv, capture_output=True, text=True, timeout=30, env=env)


def case(label, subject, *, arch=True, code=True, backend=True, n=2, cli=True, component="api.identity", expected="success", env=None, stale=False):
    built, repo = world(label, architecture=arch, code=code, backend=backend, n=n, cli=cli)
    try:
        brief = repo / f"architecture/generated/briefs/{component}.md"
        if stale:
            brief.parent.mkdir(parents=True, exist_ok=True)
            brief.write_text("PRIOR-BRIEF\n")
        # Expected output is independent of any file the subject might write.
        oracle = "\n".join([f"Element: {component}"] + [f"port.{component}.{i}" for i in range(1, n)]) + "\n"
        if env is None:
            env = os.environ.copy()
        env["TOY_BRIEF_LINES"] = str(n)
        result = invoke(subject, repo, component, env=env)
        lines = result.stdout.splitlines()
        stderr = result.stderr.splitlines()
        if expected == "success":
            needle = f"BRIEF: architecture/generated/briefs/{component}.md :: lines={n}"
            ok = (result.returncode == 0 and not stderr and lines.count(needle) == 1
                  and "=== BRIEF ===" in lines and not any(x.startswith("MAP: STRUCTURE.md ::") for x in lines)
                  and brief.is_file() and brief.read_text() == oracle
                  and f"brief\tarchitecture/generated/briefs/{component}.md\tmandatory\tarchitecture" in lines)
        else:
            ok = (result.returncode == 1 and stderr and stderr[0].startswith("ОТКАЗ: " + expected)
                  and result.stdout == "" and (brief.read_text() == "PRIOR-BRIEF\n" if stale else not brief.exists()))
        print(f"170 {label} {'ok' if ok else 'KRASNO'} rc={result.returncode} stderr={result.stderr.strip()!r}")
        return ok
    finally:
        shutil.rmtree(built)


def no_component(label, subject, *, arch=True, code=True, backend=True):
    built, repo = world(label, architecture=arch, code=code, backend=backend)
    try:
        result = invoke(subject, repo)
        lines = result.stdout.splitlines()
        required = arch and backend and code
        ok = (result.returncode == 1 and result.stdout == "" and "ARCH_COMPONENT_NET" in result.stderr) if required else (
            result.returncode == 0 and "MAP: STRUCTURE.md :: all modules" in lines and not any(x.startswith("BRIEF:") for x in lines))
        print(f"170 {label} {'ok' if ok else 'KRASNO'} rc={result.returncode} stderr={result.stderr.strip()!r}")
        return ok
    finally:
        shutil.rmtree(built)


def cells(subject):
    unavailable = os.environ.copy()
    with tempfile.TemporaryDirectory(dir=VERIFY, prefix="arch170-path-") as d:
        for program in ("bash", "git", "jq", "sha256sum", "awk", "grep", "sed", "sort", "head", "tail", "tr", "cat", "mktemp", "dirname", "pwd", "ls", "readlink", "wc", "mkdir", "rm", "mv", "basename", "cut", "date", "find"):
            target = shutil.which(program)
            if target:
                (Path(d) / program).symlink_to(target)
        unavailable["PATH"] = d
        return {
            "required": no_component("required", subject),
            "legacy": no_component("legacy", subject, arch=False),
            "document": no_component("document", subject, code=False),
            "other_project": no_component("other_project", subject, backend=False),
            "brief": case("brief", subject),
            "dynamic_id": case("dynamic_id", subject, component="core.worker"),
            "limit_300": case("limit_300", subject, n=300),
            "limit_301": case("limit_301", subject, n=301, expected="BRIEF_SLISHKOM_DLINNYJ"),
            "empty_brief": case("empty_brief", subject, n=0, expected="BRIEF_PUSTOJ"),
            "stale_on_reject": case("stale_on_reject", subject, n=301, expected="BRIEF_SLISHKOM_DLINNYJ", stale=True),
            "malformed_id": case("malformed_id", subject, component="../escape", expected="ARCH_COMPONENT_ID"),
            "missing_node": case("missing_node", subject, env=unavailable, expected="NODE_NET"),
            "missing_cli": case("missing_cli", subject, cli=False, expected="CLI_NET"),
            "unknown_component": case("unknown_component", subject, component="missing.module", expected="BRIEF_CLI_OTKAZ"),
            "no_architecture": case("no_architecture", subject, arch=False, expected="ARCHITECTURE_NET"),
        }


def main():
    parser = argparse.ArgumentParser()
    modes = parser.add_mutually_exclusive_group(required=True)
    modes.add_argument("--repo", type=Path)
    modes.add_argument("--model", action="store_true")
    modes.add_argument("--stabs", action="store_true")
    args = parser.parse_args()
    VERIFY.mkdir(parents=True, exist_ok=True)
    try:
        if args.repo:
            subject = args.repo.resolve() / "scripts/make_task.sh"
            if not subject.is_file():
                print("170 SUBJECT_ABSENT", file=sys.stderr)
                return 2
            return 0 if all(cells(subject).values()) else 1
        with tempfile.TemporaryDirectory(dir=VERIFY, prefix="arch170-model-") as d:
            directory = Path(d) / "scripts"
            directory.mkdir()
            for src in (ROOT / "scripts").iterdir():
                if src.is_file() and src.name != "make_task.sh":
                    (directory / src.name).symlink_to(src)
            honest = model_text()
            subject = directory / "honest.sh"
            subject.write_text(honest)
            control = cells(subject)
            if not all(control.values()):
                print("170 CONTROL_INVALID", file=sys.stderr)
                return 2
            if args.model:
                return 0
            # Each impostor must fail on its OWN distinguishing input, not on
            # the first failed branch of a merged run (N-39).
            stubs = [
                ("no_requirement", honest.replace('&& [ "$_code" = 1 ]', '&& [ "$_code" = 0 ]'), "required"),
                ("wrong_cli", honest.replace('brief --component "$ARCH_COMPONENT"', 'brief "$ARCH_COMPONENT"'), "brief"),
                ("missing_limit", honest.replace('[ "$_arch_lines" -gt 300 ]', '[ "$_arch_lines" -gt 99999 ]'), "limit_301"),
                ("not_backend_scoped", honest.replace('[ "$_backend" = Complior-back ]', '[ -n "$_backend" ]'), "other_project"),
                ("structure_retained", honest.replace('MAP_LINES="$(printf \'%s\' "$MAP_LINES" | grep -v \'^MAP: STRUCTURE.md ::\' || true)"', ':'), "brief"),
                ("missing_node_skip", honest.replace('command -v node >/dev/null 2>&1 || die "NODE_NET: node не найден"', 'command -v node >/dev/null 2>&1 || true'), "missing_node"),
            ]
            failures = 0
            for name, mutated, branch in stubs:
                if mutated == honest:
                    raise ValueError(f"stub {name} is a no-op")
                subject.write_text(mutated)
                checks = cells(subject)
                caught = not checks[branch]
                print(f"170 STAB {name} {'caught' if caught else 'ZHIV'} @ {branch}")
                failures += not caught
            return 1 if failures else 0
    except (ValueError, subprocess.CalledProcessError, OSError) as err:
        print(f"170 CONTROL_INVALID: {err}", file=sys.stderr)
        return 2

if __name__ == "__main__":
    sys.exit(main())
