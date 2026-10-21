accept

OBJECT `7b17232349940fc16f1c6dc36f13c85c79ca76ec` verified in the assigned local clone. The two implementation commits after `5e2e32c8` change only `tests/spec-3.15/validate_import_315.py` and regenerated `FILES.sha256`.

## Reproduction of the former route bypasses

Each mutation was inserted immediately after `A_TEXT=merge_openapi()` in the product writer, then rebuilt by the normal sequence: `python3 tests/tools/generate_derived.py`, `node tests/tools/gen-contracts.js`, and a final `generate_derived.py` to refresh `FILES.sha256`. The mutated files were restored after each experiment.

| Mutation | Product validator | Oracle |
|---|---:|---:|
| Extension `createPartnerOnboarding`: `/partner/v1/onboarding-applications` → `…-relocated` | rc 1, `extension-op-iskazhena` route diagnostic | rc 1, `extension-marshrut` |
| Same extension operation: `post` → `put` | rc 1, `extension-op-iskazhena` route diagnostic | rc 1, `extension-marshrut` |
| Core `getSession`: `/v1/session` → `…-relocated` | rc 1, `core-op-iskazhena` | rc 1, `additivnost-operacija` |
| Same core operation: `get` → `post` | rc 1, `core-op-iskazhena` | rc 1, `additivnost-operacija` |

For the extension mutations, both writer checks remained green (`generate_derived.py --check` rc 0 and `gen-contracts.js --check` rc 0), demonstrating that the rejection is from the new independent route checks rather than an incidental stale-derived failure. The relocated extension tree also gave `validate_contract_v3_9.py` rc 0, as expected for a route-only defect; the import validator and oracle were the intended barriers.

I additionally examined the remaining same-class variants: route projection compares `(operationId, path, method)` as a multiset in the oracle; the product validator requires the complete operation-ID set and rejects textual duplicate IDs; the spec-3.14 lane records parsed duplicate IDs. Duplicate YAML map keys cannot provide a green semantic counterexample because the product `yaml` parser reports `DUPLICATE_KEY`. No implementation that retained all asserted barriers green while losing, duplicating, moving between blocks, or changing a route/path parameter was found.

## Positive controls and battery repairs

On the restored honest tree:

- `python3 tests/spec-3.15/validate_import_315.py` → rc 0, `failures=[]`.
- `python3 tests/tools/generate_derived.py --check` → rc 0.
- `python3 tests/spec-3.14/validate_contract_v3_9.py --out <outside-tree-scratch>` → rc 0, `failures=[]`.
- With `node_modules` linked to the supplied dependency tree, `node tests/tools/gen-contracts.js --check` → rc 0.
- The strengthened oracle was run twice on the same linked, clean product tree; both runs returned rc 0: `IMPORT315_OK operations=233 schemas=566 consumers_confirmed=53 consumers_total=123 new_consumers=70 tables=29 known_issues=14 pin=product`. No `evidence/` was left in the judged tree.
- With no npm tree and `NODE_PATH` unset, the oracle returned rc 2 with `NEEDS_ENV: … npm-paket-nedostupen yaml`, not a product diagnosis.
- `red_import315_119.sh --model` → rc 0, `41` green and `0` red cells. It includes d35/d36 for extension routes, d40/d41 for core routes, d37 for missing npm (rc 2 `NEEDS_ENV`), d38 for an npm symlink (rc 0), and d39 for repeatability (rc 0).
- Always-green and always-red oracle stubs both returned rc 1 (`3/38` and `1/40` green/red respectively); an unknown cell returned rc 2.
- The oracle uses `LC_ALL=C comm` for all consumer/projection/set comparisons (B-3).

No blocking bypass remains in the scoped subject. Advice only: the frozen contract still states 34 cells/33 reasons while the strengthened battery has 41 cells/34 reasons; this accepted text drift is non-blocking under the assignment.

All self-created mutations, `evidence/`, dependency symlink, and external oracle scratch directories were removed. No candidate bytecode artifacts remain.
