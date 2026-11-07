#!/usr/bin/env python3
"""166: actual make_task CLI, independent positive/negative model-choice cells.

--repo: red against existing product; --model: honest future model; --stabs:
mutate that model and require each mutant's own distinguishable input to fail.
"""
import argparse
import hashlib
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[3]
TOY = ROOT / "fixtures/context_pack_095/_toy.sh"
MODEL_TAG = "frozen/contracts/095/1:fixtures/context_pack_095/model/dover.sh"
VERIFY = Path("/tmp/dev-harness-verify")
START = '# ── Б2/И-7: автор и судья независимы — судья чужого СЕМЕЙСТВА (ADR-005) ─────'
END = '# ── И-14: настоящий профиль — два слоя 054, contextPack слит семантикой схемы ─'
HONEST = '''# 166: identity witness remains mandatory, family equality is unrestricted.
if [ "$ROLE" = "reviewer" ] || [ "$ROLE" = "critic" ]; then
  [ -n "$AUTHOR_MODEL" ] || die "свидетельство не той роли: $AUTHOR_ROLE" # 166-author-witness
fi
'''


def substitute(source, old, new):
    if source.count(old) != 1:
        raise ValueError(f"model mutation anchor count {source.count(old)}: {old[:80]}")
    return source.replace(old, new)


def honest_model():
    # Immutable pre-cutover baseline: updating the 095 live fixture cannot
    # silently alter the 166 oracle (nor break --model after implementation).
    source = subprocess.run(["git", "-C", str(ROOT), "show", MODEL_TAG],
                            text=True, capture_output=True, check=True).stdout
    if source.count(START) != 1 or source.count(END) != 1:
        raise ValueError("frozen 095 model policy anchors absent or duplicated")
    before, after = source.split(START, 1)
    _, suffix = after.split(END, 1)
    return before + HONEST + END + suffix


def run(subject, repo, trace, role, task=True):
    args = ["bash", str(subject), "--repo", str(repo), "--role", role,
            "--contract", "777", "--model-trace", str(trace)]
    if role == "reviewer" and task:
        args += ["--task-file", str(repo.parent / "task.md")]
    return subprocess.run(args, text=True, stdout=subprocess.PIPE,
                          stderr=subprocess.PIPE, timeout=30)


def cell(subject, repo, label, author, judge, role, want, task=True):
    trace = repo.parent / (label + ".tsv")
    author_role = "architect" if role == "critic" else "implementer"
    rows = ([] if author is None else [f"{author_role}\t{author}\tallowed"])
    rows += ([] if judge is None else [f"{role}\t{judge}\tdenied"])
    trace.write_text("\n".join(rows) + "\n")
    task_bytes = (repo.parent / "task.md").read_bytes()  # oracle before subject
    result = run(subject, repo, trace, role, task)
    error = result.stderr.strip()
    if want == "green":
        expected_trace = f"TRACE: role={role} model={judge} fallback=denied"
        ok = (result.returncode == 0 and
              expected_trace in result.stdout.splitlines() and
              (repo.parent / "task.md").read_bytes() == task_bytes)
        if role == "reviewer" and task:
            ok = ok and f"TASK: sha256={hashlib.sha256(task_bytes).hexdigest()}" in result.stdout.splitlines()
            ok = ok and task_bytes.decode().strip() in result.stdout
    else:
        ok = result.returncode == 1 and want in error and result.stdout == ""
    print(f"166 {label}: {'OK' if ok else 'RED'} rc={result.returncode} stderr={error!r}")
    return ok


def cases(subject, repo):
    # Each positive branch is tested separately. Different provider, same exact
    # model and same family/different version must all be permitted.
    checks = [
        ("critic_sol_sol", "openai-codex/gpt-6-sol", "openai-codex/gpt-6-sol", "critic", "green", True),
        ("reviewer_glm_glm", "zai/glm-4.7", "zai/glm-5.3", "reviewer", "green", True),
        ("reviewer_cross", "zai/glm-4.7", "anthropic/claude-opus-5-5", "reviewer", "green", True),
        ("critic_no_author", None, "openai-codex/gpt-6-sol", "critic", "ОТКАЗ: свидетельство не той роли: architect", True),
        ("reviewer_no_author", None, "zai/glm-5.3", "reviewer", "ОТКАЗ: свидетельство не той роли: implementer", True),
        ("critic_no_judge", "openai-codex/gpt-6-sol", None, "critic", "ОТКАЗ: свидетельство не той роли: critic", True),
        ("reviewer_no_task", "zai/glm-4.7", "anthropic/claude-opus-5-5", "reviewer", "ОТКАЗ: нет выданного задания: 777", False),
    ]
    return all([cell(subject, repo, *args) for args in checks])


def main():
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--repo", type=Path)
    group.add_argument("--model", action="store_true")
    group.add_argument("--stabs", action="store_true")
    args = parser.parse_args()
    VERIFY.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="model-choice-166-", dir=VERIFY) as tmp:
        # Existing 095 toy world has real profile, frozen contract, task and
        # trace grammar; it lives outside the checked tree and is removed here.
        world = subprocess.run(["bash", "-c", '. "$1"; _t95_world model-choice-166', "_", str(TOY)],
                               text=True, capture_output=True, check=True).stdout.strip()
        repo = Path(world) / "repo"
        try:
            subprocess.run(["bash", "-c", '. "$1"; _t95_freeze "$2" scripts/toy.sh',
                            "_", str(TOY), str(repo)], capture_output=True, check=True)
            if args.repo:
                subject = args.repo.resolve() / "scripts/make_task.sh"
                if not subject.is_file():
                    print("166 SUBJECT_ABSENT", file=sys.stderr)
                    return 2
                return 0 if cases(subject, repo) else 1
            model_text = honest_model()
            subject = Path(tmp) / "honest.sh"
            subject.write_text(model_text)
            if not cases(subject, repo):
                print("166 CONTROL_INVALID", file=sys.stderr)
                return 2
            if args.model:
                return 0
            # Mutants differ by one policy error each; catch on a cell that
            # distinguishes it. No prose stab-to-branch mapping in contract.
            mutants = [
                ("missing_author", substitute(model_text,
                    '  [ -n "$AUTHOR_MODEL" ] || die "свидетельство не той роли: $AUTHOR_ROLE" # 166-author-witness',
                    '  : # forged missing author witness'),
                 ("critic_no_author", None, "openai-codex/gpt-6-sol", "critic", "green", True)),
                ("forged_trace", substitute(model_text,
                    'if [ "$r" = "$ROLE" ]; then TRACE_LINE="TRACE: role=$r model=$m fallback=$fb"; JUDGE_MODEL="$m"; fi # t95-m8',
                    'if [ "$r" = "$ROLE" ]; then TRACE_LINE="TRACE: role=$r model=fake fallback=$fb"; JUDGE_MODEL="$m"; fi # forged trace'),
                 ("reviewer_glm_glm", "zai/glm-4.7", "zai/glm-5.3", "reviewer", "green", True)),
                ("reviewer_blocked", substitute(model_text,
                    'if [ "$ROLE" = "reviewer" ] || [ "$ROLE" = "critic" ]; then',
                    'if [ "$ROLE" = "reviewer" ]; then die "судья на модели автора: glm"; fi\nif [ "$ROLE" = "reviewer" ] || [ "$ROLE" = "critic" ]; then'),
                 ("reviewer_glm_glm", "zai/glm-4.7", "zai/glm-5.3", "reviewer", "green", True)),
            ]
            for name, text, case in mutants:
                stub = Path(tmp) / f"{name}.sh"
                stub.write_text(text)
                # For a negative honesty criterion, the mutant must illegitimately
                # succeed, not merely produce any other failure.
                if name == "missing_author":
                    result = run(stub, repo, repo.parent / "critic_no_author.tsv", "critic")
                    caught = result.returncode == 0
                else:
                    caught = not cell(stub, repo, *case)
                print(f"166 stub {name}: {'CAUGHT' if caught else 'ESCAPED'}")
                if not caught:
                    return 1
            return 0
        finally:
            shutil.rmtree(world)


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, subprocess.CalledProcessError, subprocess.TimeoutExpired) as exc:
        print(f"166 INFRASTRUCTURE: {exc}", file=sys.stderr)
        sys.exit(2)
