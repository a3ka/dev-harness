#!/usr/bin/env python3
"""Б-7: public CLI --check/--snapshot; disposable bare origin + real clone.

No case_* runner: this family is probe-only (034). --repo exercises production;
--model is an executable control using real --snapshot/--check, not product code.
Oracle bytes/stat/expected diagnostics are captured BEFORE the subject runs.
Stubs are bound in BINDINGS to inputs on which their defect is observable (Н-39).
"""
import argparse
import hashlib
import os
from pathlib import Path
import stat
import subprocess
import tempfile
import sys
import threading
import time

REPO = Path(__file__).resolve().parents[2]
DETECTOR = REPO / "scripts/check_no_leak.sh"
AUTO = "АВТОСНИМОК: снят (а)∧(б)∧(в): {root} HEAD={head}"
CLEAN = "основной чекаут чист"
MISSING = "снимок отсутствует"
# Each binding is a separate trial, never a union satisfied by its first failure.
BINDINGS = {
    "S1": ("ahead", "behind"),
    "S2": ("dirty-tracked", "dirty-untracked"),
    "S3": ("existing-clean", "existing-dirty"),
    "S4": ("clean-auto",),
    "S5": ("clean-auto",),
    "S6": ("missing-ref",),
    "S7": ("dangling-symlink", "existing-symlink"),
    # Б-2 (Rev044B7): дверь без проверки полного refs/remotes/origin/main (:1090)
    # — короткое имя (в) даёт «0 0» за локальной веткой origin/main.
    "S-M2": ("branch-shadow-only-b",),
    # Б-1 (Rev044B7): поведение OBJECT — нет повторного доказательства
    # (а)(б)(в) для состояния, лёгшего в снимок.
    "S-race": ("race-write-during-snapshot",),
    # Б-1 (Rev044B7c, вызов 2): тело манифеста $m не сверяется с доказанным
    # состоянием — запись с откатом (A→B→A) в окне манифеста ложится в снимок.
    "S-aba-u": ("aba-untracked-during-snapshot",),
    "S-aba-t": ("aba-tracked-during-snapshot",),
    # Б-3 (Rev044B7): унаследованный GIT_CONFIG_PARAMETERS не снят (:235-239),
    # porcelain слепнет к untracked, манифест (ls-files) остаётся честным.
    "S-cfg": ("git-config-parameters",),
}
CASES = (
    "clean-auto", "dirty-tracked", "dirty-untracked", "ahead", "behind",
    "missing-ref", "broken-ref", "git-failure", "existing-clean", "existing-dirty",
    "dangling-symlink", "existing-symlink", "snapshot-replaced", "double-check",
    # Исправление FAIL Rev044B7 (Б-1/Б-2/Б-3).
    "race-write-during-snapshot", "branch-shadow-only-b", "git-config-parameters",
    # Исправление FAIL Rev044B7c (Б-1, вызов 2: запись и откат во время автоснимка).
    "aba-untracked-during-snapshot", "aba-tracked-during-snapshot",
)


def command(args, env, cwd=None):
    return subprocess.run(args, cwd=cwd, env=env, text=True,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=60)


def git(root, env, *args):
    return command(["git", "-C", str(root), "-c", "core.hooksPath=/dev/null",
                    "-c", "commit.gpgsign=false", "-c", "user.name=fixture",
                    "-c", "user.email=fixture@local", *args], env)


def required(result):
    if result.returncode:
        raise RuntimeError(f"fixture prerequisite rc={result.returncode}: {result.stderr}")
    return result.stdout.strip()


def snapshot(root, env):
    key = hashlib.sha256(os.fsencode(root)).hexdigest()[:8]
    return Path(env["TMPDIR"]) / "dev-harness-leak" / key / "porcelain"


def image(path):
    if path.is_symlink():
        return ("link", os.readlink(path), path.lstat().st_ino)
    if not path.exists():
        return None
    s = path.stat()
    return (path.read_bytes(), s.st_ino, s.st_mtime_ns, stat.S_IMODE(s.st_mode))

def drop_snapshot(snap):
    if snap.is_symlink() or snap.exists():
        if not snap.is_symlink():
            snap.chmod(0o644)
        snap.unlink()


def start_race_writer(root, env):
    """Б-1: запись в дерево ВНУТРИ окна двери проверка→манифест.

    Дверь пинит ВСЕ утилиты через TRUSTED_PATH (:309-410), поэтому PATH-обёртка
    git её не перехватывает. Наблюдаемый шов — первый «голый» `$MKTEMP` из
    emit_tracked_manifest (:494): он открывается в $TMPDIR ПОСЛЕ доказанных
    (а)(б)(в) и ДО обхода дерева манифестом. Поллер (0.2 мс) ловит его и пишет
    утечку — наблюдатель того же класса, что race.sh ревьюера (5/5), без
    секундных окон. Пустая выборка (наблюдатель не сработал) — красная.
    """
    tmp = Path(env["TMPDIR"])
    seen = {p.name for p in tmp.iterdir()}
    stop, fired = threading.Event(), threading.Event()

    def watch():
        while not stop.is_set():
            for p in tmp.iterdir():
                if p.name.startswith("tmp.") and p.name not in seen:
                    (root / "leak.txt").write_text("race leak\n")
                    (root / "tracked.txt").write_text("raced\n")
                    fired.set()
                    return
            time.sleep(0.0002)

    threading.Thread(target=watch, daemon=True).start()
    return stop, fired

ABA_CASES = ("aba-untracked-during-snapshot", "aba-tracked-during-snapshot")


def start_aba_observer(root, env, snap, kind):
    """Б-1 (Rev044B7c, вызов 2): запись и откат (A→B→A) в окне манифеста.

    Наблюдатель класса aba2.py ревьюера Rev044B7c (untracked 5/5, tracked 3/3):
    на первом «голом» tmp.* в $TMPDIR (начало манифеста — mktemp из
    emit_tracked_manifest) пишет в дерево состояние B; на появлении
    .porcelain.tmp.* в каталоге снимка (тело $m уже собрано, гвард ещё не
    начался) откатывает запись в состояние A. Гвард двери доказывает чистое
    A, а тело $m несёт B. Оба события обязаны наблюдаться: пустая выборка
    любого из них — красная, а не зелёная.
    """
    tmp = Path(env["TMPDIR"])
    seen = {p.name for p in tmp.iterdir()}
    stop, fired, restored = threading.Event(), threading.Event(), threading.Event()

    def write():
        if kind == "untracked":
            (root / "aba-leak.txt").write_text("aba leak\n")
        else:
            (root / "tracked.txt").write_text("secret edit\n")

    def rollback():
        if kind == "untracked":
            leak = root / "aba-leak.txt"
            if leak.exists():
                leak.unlink()
        else:
            (root / "tracked.txt").write_text("baseline\n")

    def watch():
        wrote = False
        while not stop.is_set():
            if not wrote:
                for p in tmp.iterdir():
                    if p.name.startswith("tmp.") and p.name not in seen:
                        write()
                        wrote = True
                        fired.set()
                        break
            elif snap.parent.is_dir():
                for p in snap.parent.iterdir():
                    if p.name.startswith(".porcelain.tmp."):
                        rollback()
                        restored.set()
                        return
            time.sleep(0.0002)

    threading.Thread(target=watch, daemon=True).start()
    return stop, fired, restored


def real(mode, root, env):
    return command(["bash", str(DETECTOR), mode, str(root)], env)


def refused():
    # Model refusal of the REPAIRED door: rc 1, named diagnosis, no snapshot.
    return subprocess.CompletedProcess(("model-refusal",), 1, "",
                                       f"ОТКАЗ: {MISSING} (model)\n")


def subject(mode, root, env, variant, case=None, fired=None):
    if variant == "repo" or mode != "--check":
        return real(mode, root, env)
    snap = snapshot(root, env)
    # Thin honest control at the PUBLIC seam; no source extraction or private calls.
    exists = snap.exists() or snap.is_symlink()
    if exists and variant != "S3" and not (variant == "S7" and snap.is_symlink()):
        return real(mode, root, env)
    # The repaired door neutralises inherited GIT_CONFIG_PARAMETERS exactly as
    # it already neutralises GIT_CONFIG_COUNT; honest probes mirror that. S-cfg
    # models the OBJECT defect and keeps the poison for its own view.
    probe = env
    if variant != "S-cfg":
        probe = {k: v for k, v in env.items() if k != "GIT_CONFIG_PARAMETERS"}
    status = git(root, probe, "status", "--porcelain")
    head = git(root, probe, "rev-parse", "--verify", "HEAD")
    origin = git(root, probe, "rev-parse", "--verify", "refs/remotes/origin/main")
    lr = git(root, probe, "rev-list", "--left-right", "--count", "origin/main...HEAD")
    clean = status.returncode == 0 and not status.stdout.strip()
    same = (head.returncode == origin.returncode == lr.returncode == 0
            and head.stdout == origin.stdout and lr.stdout.split() == ["0", "0"])
    permitted = clean and same
    if variant == "S1":
        permitted = clean
    elif variant == "S-M2":
        # Б-2: проверки полного refs/remotes/origin/main нет (:1090 удалена),
        # короткое имя (в) выживает за локальной веткой origin/main.
        permitted = clean and lr.returncode == 0 and lr.stdout.split() == ["0", "0"]
    elif variant == "S2":
        permitted = same
    elif variant == "S3" and exists:
        permitted = True
    elif variant == "S6" and origin.returncode:
        permitted = clean
    elif variant == "S7" and snap.is_symlink():
        permitted = clean and same
    if not permitted or (snap.is_symlink() and variant != "S7"):
        if variant == "model" and case == "git-config-parameters":
            # Контроль ПОЧИНЕННОЙ двери: отказ без снимка; делегирование
            # непочиненной двери импортировало бы её дефект в контроль.
            return refused()
        return real(mode, root, env)
    if variant == "S-race":
        # Дефект Б-1: запись ложится между доказанными проверками и манифестом;
        # непочиненная дверь снимает это состояние без повторного доказательства.
        (root / "leak.txt").write_text("race leak\n")
        (root / "tracked.txt").write_text("raced\n")
    if variant == "S-aba-u":
        # Дефект OBJECT (Rev044B7c Б-1): тело $m не сверяется с доказанным
        # состоянием — снимок узаконивает untracked-байты из окна манифеста.
        (root / "aba-leak.txt").write_text("aba leak\n")
    if variant == "S-aba-t":
        # Тот же дефект: в снимок ложатся tracked-байты «secret edit».
        (root / "tracked.txt").write_text("secret edit\n")
    if variant == "S7" and snap.is_symlink():
        snap.unlink()
    taken = real("--snapshot", root, env)
    if taken.returncode:
        return taken
    if variant == "S-aba-u":
        leak = root / "aba-leak.txt"
        if leak.exists():
            leak.unlink()
    if variant == "S-aba-t":
        (root / "tracked.txt").write_text("baseline\n")
    if variant == "S5":
        snap.chmod(0o644)
    if variant == "model" and case == "race-write-during-snapshot":
        # Контроль починенной двери: (а) доказывается ЗАНОВО для состояния,
        # лёгшего в снимок; запись наблюдателя делает его грязным → отказ,
        # снимок удалён, строки АВТОСНИМОК нет.
        if fired is not None:
            fired.wait(5)
        post = git(root, probe, "status", "--porcelain")
        if post.returncode or post.stdout.strip():
            snap.chmod(0o644)
            snap.unlink()
            return refused()
    if variant == "model" and case in ABA_CASES:
        # Контроль починенной двери: каждая строка автоснимка происходит из
        # состояния с доказанными (а)∧(б)(в), привязанного к самому телу $m.
        # Наблюдатель сработал в окне манифеста → тело недоказуемо → отказ,
        # снимок удалён, строки АВТОСНИМОК нет.
        if fired is not None:
            fired.wait(5)
        if fired is not None and fired.is_set():
            snap.chmod(0o644)
            snap.unlink()
            return refused()
    message = AUTO.format(root=root, head=head.stdout.strip()) + "\n"
    checked = real(mode, root, env)
    return subprocess.CompletedProcess(checked.args, checked.returncode,
                                       ("" if variant == "S4" else message) + checked.stdout,
                                       message + checked.stderr)


def world(work):
    env = os.environ.copy()
    for key in tuple(env):
        if key.startswith("GIT_"):
            del env[key]
    env.update(GIT_CONFIG_GLOBAL="/dev/null", GIT_CONFIG_SYSTEM="/dev/null",
               GIT_TERMINAL_PROMPT="0", LC_ALL="C.UTF-8", TMPDIR=str(work / "snaps"))
    Path(env["TMPDIR"]).mkdir()
    seed, origin, root = work / "seed", work / "origin.git", work / "clone"
    required(command(["git", "init", "-q", "-b", "main", str(seed)], env))
    (seed / "tracked.txt").write_text("baseline\n")
    required(git(seed, env, "add", "tracked.txt"))
    required(git(seed, env, "commit", "-qm", "baseline"))
    required(command(["git", "init", "-q", "--bare", "-b", "main", str(origin)], env))
    required(git(seed, env, "remote", "add", "origin", str(origin)))
    required(git(seed, env, "push", "-q", "origin", "main"))
    required(command(["git", "clone", "-q", str(origin), str(root)], env))
    assert required(git(root, env, "status", "--porcelain")) == ""
    assert required(git(root, env, "rev-list", "--left-right", "--count",
                        "origin/main...HEAD")).split() == ["0", "0"]
    return root, env


def trial(case, variant, base):
    with tempfile.TemporaryDirectory(prefix="b7-", dir=base) as directory:
        work = Path(directory)
        root, env = world(work)
        snap = snapshot(root, env)
        head = required(git(root, env, "rev-parse", "HEAD"))
        message = AUTO.format(root=root, head=head)
        # Manual format is the existing public-interface canonical control. It is
        # retained in MEMORY, never reread from the subject's disk as an oracle.
        required(real("--snapshot", root, env))
        canonical = snap.read_bytes()
        assert canonical.splitlines()[0] == os.fsencode(f"root {root}")
        assert image(snap)[3] == 0o444
        snap.unlink()
        target = work / "symlink-target"
        target.write_bytes(canonical)
        target_before = image(target)
        if case.startswith("existing-") or case == "snapshot-replaced":
            required(real("--snapshot", root, env))
        if case in ("dirty-tracked", "existing-dirty"):
            (root / "tracked.txt").write_text("changed\n")
        if case == "dirty-untracked":
            (root / "untracked.txt").write_text("new\n")
        if case == "ahead":
            required(git(root, env, "commit", "-q", "--allow-empty", "-m", "ahead"))
        if case == "behind":
            required(git(work / "seed", env, "commit", "-q", "--allow-empty", "-m", "behind"))
            required(git(work / "seed", env, "push", "-q", "origin", "main"))
            required(git(root, env, "fetch", "-q", "origin"))
        if case == "missing-ref":
            required(git(root, env, "update-ref", "-d", "refs/remotes/origin/main"))
        if case == "broken-ref":
            (root / ".git/refs/remotes/origin/main").write_text("1" * 40 + "\n")
        if case == "git-failure":
            (root / ".git/index").write_bytes(b"invalid index\n")
        if case == "dangling-symlink":
            snap.symlink_to(work / "absent-target")
        if case == "existing-symlink":
            snap.unlink()
            snap.symlink_to(target)
        if case == "snapshot-replaced":
            # A foreign-root replacement cannot be silently repaired by autosnapshot.
            snap.chmod(0o644)
            snap.write_bytes(b"root /foreign-root\nverify invalid\n")
            snap.chmod(0o444)
        if case == "branch-shadow-only-b":
            # Б-2 (Rev044B7): закоммиченная утечка опережает НАСТОЯЩИЙ
            # refs/remotes/origin/main, локальная ветка origin/main даёт
            # короткому имени (в) «0 0» (ambiguous refname). Нарушено ТОЛЬКО (б).
            (root / "leak.txt").write_text("committed leak\n")
            required(git(root, env, "add", "leak.txt"))
            required(git(root, env, "commit", "-qm", "shadow leak"))
            required(git(root, env, "branch", "origin/main"))
        if case == "git-config-parameters":
            # Б-3 (Rev044B7): унаследованный GIT_CONFIG_PARAMETERS слепит
            # porcelain к untracked; ноги манифеста (ls-files) честны.
            (root / "u.txt").write_text("untracked leak\n")
        before = image(snap)
        calls = 2 if case == "double-check" else 1
        results, states = [], []
        stop = fired = None
        restored = None
        if case == "race-write-during-snapshot" and variant in ("repo", "model"):
            stop, fired = start_race_writer(root, env)
        if case in ABA_CASES and variant in ("repo", "model"):
            stop, fired, restored = start_aba_observer(
                root, env, snap,
                "untracked" if case == "aba-untracked-during-snapshot" else "tracked")
        if case == "git-config-parameters":
            rules = work / "exclude-rules"
            rules.write_text("u.txt\n")
            poisons = ["'status.showUntrackedFiles'='no'",
                       "'core.excludesFile'='%s'" % rules]
            for poison in poisons:
                env["GIT_CONFIG_PARAMETERS"] = poison
                results.append(subject("--check", root, env, variant, case, fired))
                states.append(image(snap))
                drop_snapshot(snap)
            env.pop("GIT_CONFIG_PARAMETERS", None)
        else:
            for _ in range(calls):
                results.append(subject("--check", root, env, variant, case, fired))
                states.append(image(snap))
        if stop is not None:
            stop.set()
        after = image(snap)
        errors = []

        def need(condition, reason):
            if not condition:
                errors.append(reason)

        automatic = case in ("clean-auto", "double-check")
        existing_clean = case == "existing-clean"
        if automatic:
            for r in results:
                need(r.returncode == 0, f"check rc={r.returncode}, expected 0")
                need(CLEAN in r.stdout + r.stderr, "ordinary clean check did not continue")
            need(after is not None and not snap.is_symlink(), "snapshot not created")
            if snap.is_file() and not snap.is_symlink():
                need(snap.read_bytes() == canonical, "manual snapshot format/bytes differ")
                need(stat.S_IMODE(snap.stat().st_mode) == 0o444, "mode != 0444")
            need(sum(r.stderr.splitlines().count(message) for r in results) == 1,
                 "stderr: expected exactly one exact AUTO line")
            need(sum(r.stdout.splitlines().count(message) for r in results) == 1,
                 "journal/stdout: expected exactly one exact AUTO line")
            need(sum(line.startswith("АВТОСНИМОК") for r in results
                     for line in (r.stdout + r.stderr).splitlines()) == 2,
                 "unexpected extra AUTO lines")
            if calls == 2:
                need(states[0] is not None and states[0] == states[1],
                     "second check rewrote snapshot bytes/mtime/inode/mode")
        elif case == "git-config-parameters":
            for i, (r, s) in enumerate(zip(results, states)):
                need(r.returncode == 1,
                     f"check rc={r.returncode}, expected 1 (poison {i})")
                need(MISSING in r.stdout + r.stderr,
                     "missing fail-closed diagnosis under inherited GIT_CONFIG_PARAMETERS")
                need(s is None, f"poison {i} left a snapshot")
        elif existing_clean:
            need(results[0].returncode == 0, f"check rc={results[0].returncode}, expected 0")
            need(after == before, "existing snapshot bytes/mtime/inode/mode changed")
        else:
            r = results[0]
            need(r.returncode == 1, f"check rc={r.returncode}, expected 1")
            need(after == before, "refusal created/replaced/changed snapshot")
            text = r.stdout + r.stderr
            if case == "existing-dirty":
                need("основной чекаут загрязнён: tracked.txt" in text, "missing dirty-path diagnosis")
            elif case == "snapshot-replaced":
                need("снимок чужого корня" in text, "missing foreign-root diagnosis")
            elif case == "existing-symlink":
                need("снимок — симлинк" in text, "missing symlink diagnosis")
            elif case != "dangling-symlink":
                need(MISSING in text, "missing fail-closed diagnosis")
        if not automatic:
            need(all("АВТОСНИМОК" not in r.stdout + r.stderr for r in results),
                 "refusal/existing snapshot emitted AUTO transcript")
        if case == "race-write-during-snapshot" and variant in ("repo", "model"):
            need(fired is not None and fired.is_set(),
                 "race writer never observed the manifest window (empty sample)")
        if case in ABA_CASES and variant in ("repo", "model"):
            need(fired is not None and fired.is_set(),
                 "aba observer never observed the manifest window (empty sample)")
            need(restored is not None and restored.is_set(),
                 "aba observer never observed the rollback window (late rollback)")
        need(image(target) == target_before, "symlink target changed")
        need(not (work / "absent-target").exists(), "dangling symlink target created")
        return errors, [r.returncode for r in results]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument("--repo", action="store_true")
    modes.add_argument("--model", action="store_true")
    modes.add_argument("--stabs", action="store_true")
    modes.add_argument("--census", action="store_true")
    args = parser.parse_args()
    if args.census:
        commands = [
            ["bash", str(Path(__file__).with_name("red_bulk_peresnjatie_bazlajna.sh"))],
            ["bash", str(Path(__file__).with_name("red_dver_retake_ahead.sh"))],
            *[[sys.executable, str(Path(__file__).resolve()), mode]
              for mode in ("--repo", "--model", "--stabs")],
        ]
        rcs = []
        for argv in commands:
            result = subprocess.run(argv, check=False)
            rcs.append(result.returncode)
            print(f"RAW_RC={result.returncode} COMMAND={' '.join(argv)}", flush=True)
        return int(any(rcs))
    base = Path(os.environ.get("TMPDIR", "/tmp")).resolve()
    base.mkdir(parents=True, exist_ok=True)
    trials = ([(stub, case) for stub, cases in BINDINGS.items() for case in cases]
              if args.stabs else [("model" if args.model else "repo", c) for c in CASES])
    red, live = [], []
    for variant, case in trials:
        errors, rcs = trial(case, variant, base)
        caught = bool(errors)
        print(f"{variant}/{case}: SUBJECT_RC={','.join(map(str, rcs))} "
              f"{'CAUGHT' if args.stabs and caught else 'RED' if caught else 'LIVE' if args.stabs else 'GREEN'}"
              + (": " + "; ".join(errors) if errors else ""), flush=True)
        if args.stabs:
            if not caught:
                live.append(f"{variant}/{case}")
        elif caught:
            red.append(case)
    print(f"CELLS={len(trials)} RED={len(red)} LIVE={len(live)}", flush=True)
    return int(bool(red or live))


if __name__ == "__main__":
    raise SystemExit(main())
