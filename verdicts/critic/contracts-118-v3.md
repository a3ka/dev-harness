accept
OBJECT=9df27078300aca9976bdd65a5292c880d4d94616

Scoped judgment: the authorized v3 delta replaces the mobile.yml text-order check with an executable same-run script. On the target object, the model exercises one Jest invocation before one checker invocation; the cases for omitted Jest, checker-before-Jest, stale report, and failed Jest have their specified red outcomes. The code-bound s58 stub is caught on all three linked cases. The frozen 118/2 obligations for expiry, byte-pinned carriers, and the screen remain in place; the owner authorization for this v+1 is in the OBJECT commit message. No blocking finding in the scoped delta.

Raw commands/rc (cwd: disposable clone at OBJECT):
- `git rev-parse HEAD` → rc 0: `9df27078300aca9976bdd65a5292c880d4d94616`.
- `TMPDIR="$PWD" bash fixtures/workshop_project/erstinformation_118/red_erstinformation_118.sh --model` → rc 0: 80 `CASE … ok`, `CASE guard-shag ok`, 16 `KADR … 1.000 0.600 G OK`; notably `CASE ci-bez-srok-testov ok`, `CASE ci-bez-otcheta-sroka ok`, `CASE ci-script-odin-progon ok`, `CASE ci-jest-neuspeh ok`, `CASE ci-staryj-otchet ok`.
- `TMPDIR="$PWD" bash fixtures/workshop_project/erstinformation_118/red_erstinformation_118.sh --stabs` → rc 0: `STAB s58_ci_tolko_npm_test.py ci-bez-srok-testov KRASEN`, `STAB s58_ci_tolko_npm_test.py ci-bez-otcheta-sroka KRASEN`, `STAB s58_ci_tolko_npm_test.py ci-staryj-otchet KRASEN`, `SVJAZI 74`; no `STAB_ZHIV`.
- `jq -r '"target cases=\(.kejsy|length) stubs=\(.stab_vhod|length) links=\([.stab_vhod[]|length]|add)"' fixtures/workshop_project/erstinformation_118/source.json` → rc 0: `target cases=80 stubs=52 links=74`.
- `git show frozen/contracts/118/2:fixtures/workshop_project/erstinformation_118/source.json | jq -r '"frozen118v2 cases=\(.kejsy|length) stubs=\(.stab_vhod|length) links=\([.stab_vhod[]|length]|add)"'` → rc 0: `frozen118v2 cases=71 stubs=51 links=69`.
- `bash scripts/pre_critic.sh --repo . contracts/118-erstinformation.md && bash scripts/check_precision_gate.sh . contracts/118-erstinformation.md && bash scripts/check_spec_ready.sh . contracts/118-erstinformation.md && bash scripts/check_ceilings.sh . contracts/118-erstinformation.md && bash scripts/check_provodka.sh . contracts/118-erstinformation.md && bash scripts/check_threat_model.sh . contracts/118-erstinformation.md` → rc 0: `КРИТИК: дверь зелёная`, `потолки в порядке`, `модель угроз: секция валидна`.
- `TMPDIR="$PWD" bash fixtures/workshop_project/erstinformation_118/red_erstinformation_118.sh` → rc 0: 80 `CASE … ok`, `CASE guard-shag ok`. Contract expected rc 1 is conditional on absent `scripts/ekran_shablon.py`; it exists on OBJECT. No source was edited to simulate absence.
- `git status --short && git rev-parse HEAD && git diff --quiet` → rc 0, empty status, matching OBJECT.

Real product CI/Jest and the absent-template red precondition were not exercised. No source edit or push.