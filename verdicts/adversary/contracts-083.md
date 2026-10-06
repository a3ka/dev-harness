FAIL

# 083 — adversary verdict

Subject: `origin/wip/083/integration-2` at `6aa38a58a18d99a9f549e3bb93b7c72e334320b0`.

## Found bypass: foreign-line cache is rejected by three of four checks

Contract 083 invariant 6(v′) requires **each** of `check_charter`, `check_zones`, `check_ids`, and `check_protected` to treat any valid cache SHA which is not an ancestor of `HEAD` (including an existing SHA from another line, where `merge-base --is-ancestor` returns 1) as a named full run and to seed the cache with `HEAD` after a green result.

The shared `scripts/lib_incr.sh` instead turns every nonzero `git merge-base --is-ancestor` result into `INCR_RC=1` and an `ОТКАЗ … не предок HEAD`. `check_charter.sh` carries a separate pre-parse workaround, but `check_zones.sh`, `check_ids.sh`, and `check_protected.sh` do not. This also violates the stipulated single common grammar.

Reproduction in a disposable SSH clone at the cited SHA:

```sh
# origin/main is an existing object, shares merge base 5bfc85c4 with HEAD,
# and is not an ancestor of HEAD (merge-base --is-ancestor exits 1).
printf '%s\n' f8e1f3d3b7a6f98689f516af2de6a9b51dd1bfe0 > tmp/adversary-main.cache
bash scripts/check_zones.sh --incr tmp/adversary-main.cache
bash scripts/check_ids.sh --incr tmp/adversary-main.cache
bash scripts/check_protected.sh --incr tmp/adversary-main.cache
```

Each command exited 1 immediately with its respective `incr: check_<name> ОТКАЗ: кеш tmp/adversary-main.cache — sha f8e1f3d3 не предок HEAD 6aa38a58`, rather than executing the mandated named full run. As a positive control on the same cache, `check_charter` emitted `incr: check_charter полный прогон (база f8e1f3d3 не предок HEAD 6aa38a58 — кеш сторонней линии)` and continued its full check.

The red battery has no cells I4-3/I4-4 for zones, ids, or protected; its I4 cells exercise only charter, so it is green while this required behavior is absent. This is a concrete green-criterion / broken-subject state.

## Battery and adversarial controls

* Clean clone at the cited SHA with tags fetched: `bash fixtures/_krasnye_083.sh` exited 0, `ok=53 FAIL=0`.
* A deceptive `incr_parse` accepting every syntactically valid cache as an ancestor plus a no-op `incr_finish` was caught: battery exited 1, `ok=46 FAIL=7` (including increment/cache advancement checks).
* The required foreign-line behavior above remains untested for three checkers, despite the battery's green result.

## A3 observation

Fresh `bash fixtures/ci_gen_083/timing_083.sh wip/083/integration-2` exited 1: `самая долгая lane-джоба ci = 792 с (> 720): ci (l1, check:charter)`. No post-warmup boundary run was available in this execution.

Required remediation is for the implementation owner: put v′ handling in the shared library (both `merge-base` outcomes 1 and 128), remove the charter-only duplicate, and extend the frozen battery with foreign-line/object cells for all four checks.
