#!/usr/bin/env python3
"""169: independent task/brief cells against the public make_task CLI."""
import argparse
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[3]
TOY = ROOT / "fixtures/context_pack_095/_toy.sh"
VERIFY = Path("/tmp/dev-harness-verify")
OLD = 'if [ -z "$TRACE" ] || [ ! -f "$TRACE" ]; then die "нет свидетельства модели: $ROLE"; fi'
NEW = '''if [ -n "$TRACE" ] && [ ! -f "$TRACE" ]; then
    die "--model-trace ожидает путь к TSV-файлу трассы (роль<TAB>модель<TAB>allowed); в проектном корне аргумент можно опустить — берётся <registry>/trace.tsv"
  fi
  if [ -z "$TRACE" ]; then die "нет свидетельства модели: $ROLE"; fi'''
ERROR = "ОТКАЗ: --model-trace ожидает путь к TSV-файлу трассы (роль<TAB>модель<TAB>allowed); в проектном корне аргумент можно опустить — берётся <registry>/trace.tsv"
STEP = "0. `bash scripts/make_task.sh --repo <root> --role orchestrator --kind brief --model-trace <путь к TSV>` (095 Р1+12; 169): в проектном корне при наличии `<registry>/trace.tsv` аргумент можно опустить; отказ — стоп, не имитация брефа. Пак: MAP/RULES/BUDGET, ЦЕЛЬ/plan.tsv/РАБОТА/РЕШЕНИЯ/ЗДОРОВЬЕ."


def replace_one(source, old, new):
    if source.count(old) != 1:
        raise ValueError(f"mutation anchor appears {source.count(old)} times")
    return source.replace(old, new)


def run(subject, repo, *extra):
    return subprocess.run(["bash", str(subject), "--repo", str(repo), "--role", "orchestrator", "--kind", "brief", *extra], capture_output=True, text=True, timeout=30)


def check(label, result, expected_rc, expected_line=None):
    actual = result.stderr.splitlines()
    ok = (result.returncode == expected_rc and result.stdout == "" and actual == [expected_line]) if expected_rc else (
        result.returncode == 0 and result.stderr == "" and "TRACE: role=orchestrator model=openai-codex/gpt-6-sol fallback=allowed" in result.stdout.splitlines()
        and "=== GOAL ===" in result.stdout.splitlines())
    print(f"169 {label} {'ok' if ok else 'KRASNO'} rc={result.returncode} stderr={result.stderr.strip()!r}")
    return ok


def cases(subject, repo):
    trace = repo / "registry/trace.tsv"
    trace.write_text("orchestrator\topenai-codex/gpt-6-sol\tallowed\n")
    # Memory oracle: the trace is read before any subject invocation, not from the subject's mutated disk.
    trace_bytes = trace.read_bytes()
    project_no_arg = check("project_no_arg", run(subject, repo), 0)
    explicit_model = check("explicit_model_string", run(subject, repo, "--model-trace", "openai-codex/gpt-5.6-terra"), 1, ERROR)
    explicit_missing = check("explicit_missing_path", run(subject, repo, "--model-trace", str(repo / "missing.tsv")), 1, ERROR)
    unchanged = trace.is_file() and trace.read_bytes() == trace_bytes
    if trace.exists():
        trace.unlink()
    no_trace = check("no_trace_anywhere", run(subject, repo), 1, "ОТКАЗ: нет свидетельства модели: orchestrator")
    unchanged &= not trace.exists()
    if not unchanged:
        print("169 trace_oracle KRASNO")
    return {"project_no_arg": project_no_arg, "explicit_model_string": explicit_model,
            "explicit_missing_path": explicit_missing, "no_trace_anywhere": no_trace,
            "trace_oracle": unchanged}


def role_cell(text):
    ok = STEP in text.splitlines()
    print(f"169 orchestrator_step_0 {'ok' if ok else 'KRASNO'}")
    return ok


def main():
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--repo", type=Path)
    group.add_argument("--model", action="store_true")
    group.add_argument("--stabs", action="store_true")
    args = parser.parse_args()
    VERIFY.mkdir(parents=True, exist_ok=True)
    world = subprocess.run(["bash", "-c", '. "$1"; _t95_world model-trace-169', "_", str(TOY)], capture_output=True, text=True, check=True).stdout.strip()
    repo = Path(world) / "repo"
    # 095's toy omits ci.yml deliberately; 169 exercises the early 136
    # project-path resolver, which needs the declared workflow to exist.
    (repo / "ci.yml").write_text("name: toy\n")
    try:
        # Frozen pre-169 source keeps the honest control independent of a
        # later implementation (including changes in the active checkout).
        source = subprocess.run(["git", "-C", str(ROOT), "show",
                                 "frozen/contracts/166/2:scripts/make_task.sh"],
                                capture_output=True, text=True, check=True).stdout
        honest = replace_one(source, OLD, NEW)
        with tempfile.TemporaryDirectory(prefix="model-trace-169-", dir=VERIFY) as tmp:
            out = Path(tmp) / "scripts"
            out.mkdir()
            for dependency in (ROOT / "scripts").iterdir():
                if dependency.is_file() and dependency.name != "make_task.sh":
                    (out / dependency.name).symlink_to(dependency)
            model = out / "honest.sh"
            model.write_text(honest)
            role = (args.repo.resolve() if args.repo else ROOT) / "roles/orchestrator.md"
            if args.repo:
                subject = args.repo.resolve() / "scripts/make_task.sh"
                if not subject.is_file() or not role.is_file():
                    print("169 SUBJECT_ABSENT", file=sys.stderr)
                    return 2
                verdicts = cases(subject, repo)
                verdicts["orchestrator_step_0"] = role_cell(role.read_text())
                return 0 if all(verdicts.values()) else 1
            control = cases(model, repo)
            control["orchestrator_step_0"] = role_cell(STEP)
            if not all(control.values()):
                print("169 CONTROL_INVALID", file=sys.stderr)
                return 2
            if args.model:
                return 0
            # Each impostor must diverge on its own observable case; no first-red shortcut.
            stubs = [
                ("old_missing_error", replace_one(honest, NEW, OLD), "explicit_model_string"),
                ("explicit_falls_back", replace_one(honest, 'if [ -z "$TRACE" ]; then\n  _PP_JSON=', 'if [ -z "$TRACE" ] || [ ! -f "$TRACE" ]; then\n  _PP_JSON='), "explicit_model_string"),
                ("no_default", replace_one(honest, 'if [ -z "$TRACE" ]; then\n  _PP_JSON=', 'if false; then\n  _PP_JSON='), "project_no_arg"),
                ("missing_is_new", replace_one(honest, 'if [ -z "$TRACE" ]; then die "нет свидетельства модели: $ROLE"; fi', 'if [ -z "$TRACE" ]; then die "--model-trace ожидает путь к TSV-файлу трассы (роль<TAB>модель<TAB>allowed); в проектном корне аргумент можно опустить — берётся <registry>/trace.tsv"; fi'), "no_trace_anywhere"),
            ]
            failed = False
            for name, text, branch in stubs:
                path = out / (name + ".sh")
                path.write_text(text)
                observed = cases(path, repo)[branch]
                caught = not observed
                print(f"169 STAB {name} {'caught' if caught else 'ZHIV'} @ {branch}")
                failed |= not caught
            caught = not role_cell("0. `bash scripts/make_task.sh --repo <root> --role orchestrator --kind brief --model-trace <trace>` (095 Р1+12); отказ — стоп.")
            print(f"169 STAB old_step {'caught' if caught else 'ZHIV'} @ orchestrator_step_0")
            return 1 if failed or not caught else 0
    finally:
        shutil.rmtree(world)


if __name__ == "__main__":
    sys.exit(main())
