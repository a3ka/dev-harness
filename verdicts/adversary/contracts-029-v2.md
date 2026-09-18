FAIL

# Adversary verdict — contract 029, round 2

Judged fresh HEAD `c3a8bc2` in a disposable clone. This verdict judges only the
application of the seven round-1 fixes and channels opened by those edits.

## Live bypasses

1. **`check_fork_route.sh` still accepts a fake `sha256sum` whose empty-input
   answer is false.** With `PATH` prefixed by an executable named `sha256sum`
   that prints `deadbeef  -` and exits 0, a nonempty otherwise conforming
   journal returned `rc=0` (`route-fake-sha-zero-wrong-empty`). The checker
   declares `sha256sum` a required tool and contract invariant 10 requires
   `rc=2` if it cannot be used, but it only performs `command -v` and never
   proves the tool works. This is the requested refusal-that-looks-like-success
   variant of round-1 bypass 2; the new verifier probe correctly returns `rc=2`.

2. **The new G1 implementation trusts the caller-controlled `PATH`; it can
   execute an attacker-supplied `git` and still accept the answer.** A `git`
   wrapper placed first in `PATH` wrote a marker and then `exec`ed `/usr/bin/git`.
   Invoking `verify_consultant.sh` with a complete honest `git status --short`
   answer returned `rc=0`, and the marker existed
   (`path-git-wrapper rc=0; path-git-marker=yes`). Every G2/G4/G5 scan and the
   eventual replay use `env -i PATH="$PATH"`, so `env -i` clears `GIT_*` but
   deliberately reinjects the untrusted executable-search path. Direct argv
   removed the second shell interpretation, but did not create a trusted command
   boundary. A PATH wrapper for any allowed external command is likewise an
   execution channel.

## Re-executed controls and closed round-1 routes

All following probes were separately built and run against the fresh clone:

- **Metacharacters:** `$(touch marker)`, backticks, `|`, `;`, `&`, `<`, `>`, and
  parentheses (each alone in an `ls` answer) all returned `rc=1`; no marker was
  created. Round-1 bypass 1 is closed.
- **Header grammar:** removing each one of `ПРЕДМЕТ`, `МОДЕЛЬ`, `ВОПРОС`, and
  `РЕКОМЕНДАЦИЯ` from an otherwise complete response separately returned `rc=1`.
  Round-1 bypass 3 is closed.
- **Alternates:** ordinary `.git/objects/info/alternates`, a `.git` produced by
  `--separate-git-dir`, and a nested alternate chain each returned `rc=1`.
  Ordinary and nested cases named `alternates` in stderr. A clean repository
  without alternates and a correct `git status --short` response returned `rc=0`.
  Round-1 bypass 4 is closed.
- **Journal grammar:** each of non-ASCII filename, filename/`ФОРК` mismatch,
  duplicate `КЛАСС`, non-ISO `ЗАВЕДЁН`, duplicate `ФОРК` across files, lowercase
  `t`/`z`, empty `ФОРК`, and padded values returned `rc=1`. Round-1 bypass 5 is
  closed for those inputs.
- **Flush:** three records with the first unresolved blocking entry, four
  unresolved nonblocking entries, and an old unresolved middle entry among three
  records all produced `ФЛАШ` with `rc=0`. The neighbouring-record lookup from
  round 1 no longer reappears at 3+ entries.
- **Time:** pending batch records with an empty time, a time without a zone, and
  a `+03:00` zone each returned `rc=1`. Round-1 bypass 7 is closed.
- **G1 positive control:** an inherited `GIT_EXTERNAL_DIFF` marker script did
  not run; a deliberately dirty tree’s exact `git diff` answer was accepted
  (`g1-control rc=0 marker=no`). Thus the failure above is specifically the
  preserved PATH channel, not a claim that `env -i` failed to clear `GIT_*`.

The barrier is not accepted until both live bypasses reject while the cited
positive controls remain green.
