# Adversary 038 — atomic fd final round

**Verdict: FAIL.**

Judged subject: `6cb9ddee02caeb0fa371b568b619a6bf46f5fff3`.

## New live bypasses

`verdicts/adversary/contracts-038-forged-readlink.repro.sh` runs the subject
unchanged in a fresh tree. It has three honest positive controls (including the
legitimate same-inode role hardlink), then creates deceptive *successful* PATH
tools and an invalid FIFO target.

1. **Untrusted PATH tools nullify validation.** Atomic descriptors bind what is
   read, but the checker still trusts external `readlink`, `grep`, and `awk`
   selected from caller-controlled `PATH`.
   - A successful `readlink` shim says `/proc/self/fd/9` is
     `$ROOT/roles/alias.md` and fd 11 is `$ROOT/AGENTS.md`; both descriptors are
     actually open on external policy files through symlinks. Canonicality and
     charter target pinning accept the forged report, then the checker reads
     the external fd and returns green.
   - A `grep` shim returning 0 accepts absent norms in both a legitimate role
     file and the legitimate charter section.
   - An `awk` shim emits the requested charter norm, so the subsequent real
     grep accepts a norm absent from `AGENTS.md`.

   This is an executable counterexample to the final implementation's
   fail-closed claim for unavailable/hostile tools: a command that fails (127)
   is red, but a command that lies successfully is green.

2. **A FIFO role target hangs before the nonregular-file rejection.** The code
   executes `exec 9<"$ROOT/$path"` before `[ -f /proc/self/fd/9 ]`. Opening a
   FIFO for reading with no writer blocks; it never reaches the intended
   fail-closed type check and violates the documented 0/1/2 API. The repro
   observes `timeout 2` rc 124 instead of required rejection rc 1.

Raw output of the new repro:

```text
honest-role: rc=0
honest-role-hardlink: rc=0
honest-charter: rc=0
forged-role-canonicality-accepted: rc=0
forged-charter-canonicality-accepted: rc=0
forged-role-norm-accepted: rc=0
forged-charter-norm-accepted: rc=0
forged-charter-section-accepted: rc=0
fifo-open-blocks-instead-of-rc1: rc=124
REPRODUCED: successful PATH tool stubs bypass canonicality/norm checks; FIFO blocks before type rejection.
```

## Boundary controls

Separate throwaway boundary probe (removed after execution) gave:

```text
hardlink-same-inode: rc=0
directory-type-rejected: rc=1
charter-trailing-target-space-rejected: rc=1
charter-unicode-lookalike-target-rejected: rc=1
repeated-channels-under-low-fd-limit: rc=0
fifo-block-instead-of-rejection: rc=124
```

Thus hardlinks are accepted as the same inode, directories and tested charter
lookalikes are rejected, and 256 mixed channels under `ulimit -n 16` do not
accumulate descriptors. The FIFO remains a blocking defect.

## Required controls and old-repro inversions

Real contract positive control:

```text
$ bash scripts/check_provodka.sh . contracts/038-provodka-done-gejt.md
# rc=0; no output
```

Regression:

```text
$ EXPECT_RC=0 bash fixtures/_krasnye_038.sh
check_provodka/red_R10_guard_only_bez_obosnovanija.sh rc=0
check_provodka/red_R1_pole_net.sh rc=0
check_provodka/red_R2_stroka_vne_grammatiki.sh rc=0
check_provodka/red_R3_guard_fajl_prizrak.sh rc=0
check_provodka/red_R4_guard_osirotel.sh rc=0
check_provodka/red_R5_norma_stroka_net.sh rc=0
check_provodka/red_R6_norma_stroka_podstroka.sh rc=0
check_provodka/red_R7_charter_chuzhaja_sekcija.sh rc=0
check_provodka/red_R8_pole_pusto.sh rc=0
check_provodka/red_R9_sekcija_prefiks.sh rc=0
check_provodka/green_G1_polnyj_vhod.sh rc=0
check_provodka/green_G2_guard_only_s_obosnovaniem.sh rc=0
done_contract/red_D1_verdikt_zagolovok.sh rc=0
done_contract/red_D2_verdikt_fail.sh rc=0
done_contract/red_D3_verdikt_prefiks.sh rc=0
done_contract/red_D4_provodka_krasna.sh rc=0
done_contract/red_D5_v2_bez_razreshila.sh rc=0
done_contract/red_D7_ne_zakommichen.sh rc=0
done_contract/red_D8_prichina_pusta.sh rc=0
done_contract/red_D9_dva_verdikta_svezhij_fail.sh rc=0
done_contract/green_D10_env_gigiena.sh rc=0
done_contract/green_D6_v2_s_razreshilom.sh rc=0
done_contract/green_G_polnoe_derevo.sh rc=0
check_consumers/red_C1_potrebitel_ne_verificirovan.sh rc=0
check_consumers/red_C2_zona_ne_zachityvaetsja.sh rc=0
check_consumers/red_C3_potrebitel_proba_krasna.sh rc=0
check_consumers/red_C4_put_mapping_prizrak.sh rc=0
check_consumers/red_C5_zamer_mapping_net.sh rc=0
check_consumers/red_C6_pisateli_minimum_net.sh rc=0
check_consumers/green_G1_zelenaja_proba.sh rc=0
check_consumers/green_G2_vacuous.sh rc=0
итог: 31 файлов, расхождений 0 (режим ожидания rc=0)
# rc=0
```

Scoped anti-placebo control: `bash scripts/verify_antiplacebo.sh --scope
check_provodka` returned rc 0 and reported 21/21 checker fixtures:
`барьеров: 1 · фикстур: 21 · предъявлено красным повторным прогоном: 21`.

Each former exploit now produces its expected inversion: its script retains the
old expected rc 0, receives actual checker rc 1, prints `FAIL`, and itself
returns rc 1. Honest controls in each repro remain rc 0.

```text
$ bash verdicts/adversary/contracts-038-role-toctou.repro.sh
honest-flat-alias: rc=0
FAIL swap-after-canonicalization: rc=1, expected 0
проводка: норма-строка не найдена в role-файле: roles/alias.md
# script rc=1

$ bash verdicts/adversary/contracts-038-role-parser-laxity.repro.sh
honest-minimal: rc=0
FAIL arbitrary-text-around-norm-accepted: rc=1, expected 0
проводка: строка вне грамматики: - role=roles/valid.md NOT-GRAMMAR «Honest role norm.» TRAILING-GARBAGE
# script rc=1

$ bash verdicts/adversary/contracts-038-postk5-bypasses.repro.sh
honest-charter: rc=0
role-trailing-garbage-rejected: rc=1
role-nested-quotes-rejected: rc=1
charter-trailing-garbage-rejected: rc=1
charter-nested-quotes-rejected: rc=1
FAIL role-canonical-target-replaced-accepted: rc=1, expected 0
проводка: норма-строка не найдена в role-файле: roles/honest.md
# script rc=1
```

The old five classes therefore hold against their original controlled exploits,
but the newly demonstrated successful-tool and FIFO cases leave this final gate
open.
