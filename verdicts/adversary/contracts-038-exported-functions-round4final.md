# Adversary 038 — exported functions bypass PATH pinning

**Verdict: FAIL.**

Judged subject: `f536524d5e1c4a7b8127249b2805b31d7eb466af`.

## New live bypass

`export PATH=/usr/bin:/bin` does not make `readlink`, `grep`, or `awk`
trustworthy in a Bash process. Before it evaluates the script body, Bash imports
an exported caller function (`BASH_FUNC_<name>%%`); function lookup has higher
precedence than `PATH`. The checker's reset therefore leaves every externally
named command forgeable. An exported `exit` function also supersedes the shell
builtin in `die()`, converting an ordinary rejection to rc 0.

The subject and its checks were not modified. The committed executable repro is
`verdicts/adversary/contracts-038-exported-functions.repro.sh`:

```text
$ bash verdicts/adversary/contracts-038-exported-functions.repro.sh
honest-role: rc=0
honest-charter: rc=0
exported-readlink-role-canonicality: rc=0
exported-grep-role-norm: rc=0
exported-awk-charter-section: rc=0
exported-exit-masks-rejection: rc=0
REPRODUCED: imported Bash functions bypass PATH-pinned role/charter validation and can mask rejection rc.
```

The controls prove the deceptive cases are not merely an always-green stub:

- the honest role and honest charter controls use real tools and return rc 0;
- `readlink` approves `roles/alias.md` while its open descriptor points through
  a symlink to `policies/outside-role.md`, whose norm is absent from the honest
  role;
- `grep` accepts an absent role norm;
- `awk` fabricates a charter section containing an absent norm; and
- `exit() { return 0; }`, inherited into the child Bash, changes a malformed
  role declaration's specified rejection into rc 0.

This is one remaining bypass class (inherited Bash function shadowing), with
four independently executed role/charter failure vectors. It remains reachable
although all prior PATH-directory shims are correctly blocked.

## Required positive and regression controls

Real contract positive control stayed green:

```text
$ bash scripts/check_provodka.sh . contracts/038-provodka-done-gejt.md
# rc=0; no output
```

Required full red-fixture regression:

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

Scoped anti-placebo control also stayed green: `bash
scripts/verify_antiplacebo.sh --scope check_provodka` returned rc 0 and
presented 27/27 checker fixtures red on repetition.

## All four old adversary repro inversions

Each old script retains the obsolete exploit expectation (0), sees a checker
rejection (1), and therefore intentionally exits rc 1. Its honest control
remains rc 0.

```text
$ bash verdicts/adversary/contracts-038-role-parser-laxity.repro.sh
honest-minimal: rc=0
FAIL arbitrary-text-around-norm-accepted: rc=1, expected 0
проводка: строка вне грамматики: - role=roles/valid.md NOT-GRAMMAR «Honest role norm.» TRAILING-GARBAGE
# script rc=1

$ bash verdicts/adversary/contracts-038-role-toctou.repro.sh
honest-flat-alias: rc=0
FAIL swap-after-canonicalization: rc=1, expected 0
проводка: норма-строка не найдена в role-файле: roles/alias.md
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

$ bash verdicts/adversary/contracts-038-forged-readlink.repro.sh
honest-role: rc=0
honest-role-hardlink: rc=0
honest-charter: rc=0
FAIL forged-role-canonicality-accepted: rc=1, expected 0
проводка: role-канал обязан ссылаться строго на roles/<роль>.md, получено: roles/alias.md (резолв: /tmp/adversary038-forged-tools.<random>/tree/policies/outside-role.md)
# script rc=1
```

The old readlink/FIFO repro stops at its first now-rejected forged tool case, so
it does not re-exercise its later FIFO branch; that branch is covered by the
scoped anti-placebo case `case_26_fifo_blocks_role.sh`, which passed its honest
control and observed the required rc 1 rejection.
