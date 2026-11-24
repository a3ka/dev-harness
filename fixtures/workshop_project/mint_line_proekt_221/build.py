#!/usr/bin/env python3
"""Materialize the pinned station canon, reference and addressed mutations."""
import hashlib
import json
import subprocess
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
BASE = '8b52fade7975034d7cabece67e46c16a7d1abe3b'
PROJECT = '''# 221: project invocation owns its temporary hook; station branch is unchanged.
if [ -f "$ROOT/harness.project.json" ]; then
  project_paths_resolve "$ROOT" >/dev/null || exit 1
  # Normalize prohibited file identity rather than weakening the live 080 guard.
  for key in user.name user.email; do
    cfg_rc=0
    git -C "$ROOT" config --local --unset-all "$key" || cfg_rc=$?
    case "$cfg_rc" in
      0|5) ;;
      *) printf 'ОТКАЗ: не удалось удалить file-config identity: %s\\n' "$key" >&2; exit 1 ;;
    esac
  done
  HOOK_WORK="$(mktemp -d)" || exit 2
  trap 'rm -rf -- "$HOOK_WORK"' EXIT
  printf '#!/usr/bin/env bash\\nexec bash %q %q\\n' "$SELF_DIR/check_staged.sh" "$ROOT" > "$HOOK_WORK/pre-commit"
  chmod 700 "$HOOK_WORK/pre-commit"
  export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=core.hooksPath GIT_CONFIG_VALUE_0="$HOOK_WORK"
fi

'''
# Code is the sole stab-to-input registry (Н-39). No contractual prose pairs.
MUTATIONS = {
    'st01-no-project-hook': ('if [ -f "$ROOT/harness.project.json" ]; then', 'if false; then', ['p01-no-hook']),
    'st02-name-left': ('for key in user.name user.email; do', 'for key in user.email; do', ['p02-foreign-config']),
    'st03-email-left': ('for key in user.name user.email; do', 'for key in user.name; do', ['p04-email-only']),
    'st04-config-identity': ('GIT_AUTHOR_NAME=orchestrator GIT_AUTHOR_EMAIL=orchestrator@dev-harness.local GIT_COMMITTER_NAME=orchestrator GIT_COMMITTER_EMAIL=orchestrator@dev-harness.local ', '', ['p05-foreign-env']),
    'st05-no-verify': ('commit -q --no-gpg-sign', 'commit --no-verify -q --no-gpg-sign', ['p07-live-door-refusal', 'p01-no-hook']),
    'st06-no-rollback': ('git -C "$ROOT" checkout HEAD -- "$_REG_FILE" 2>/dev/null || true', ': # rollback removed', ['p07-live-door-refusal']),
    'st07-project-on-station': ('if [ -f "$ROOT/harness.project.json" ]; then', 'if true; then', ['s02-no-hook', 's03-foreign-config']),
    'st08-config-hook-wins': ('GIT_CONFIG_VALUE_0="$HOOK_WORK"', 'GIT_CONFIG_VALUE_0=/dev/null', ['p06-disabled-config-hook', 'p07-live-door-refusal']),
    'st09-repeat-unchecked': ('if grep -qF -- "$NNN → " <<<"$head_manifest"; then', 'if false; then', ['p08-repeat']),
    'st10-empty-name-left': ('git -C "$ROOT" config --local --unset-all "$key" || cfg_rc=$?', 'if [ -n "$(git -C "$ROOT" config --local --get "$key" || true)" ]; then git -C "$ROOT" config --local --unset-all "$key" || cfg_rc=$?; fi', ['p03-empty-config']),
    'st11-single-value-unset': ('config --local --unset-all "$key"', 'config --local --unset "$key"', ['p11-multivalue-config']),
    'st12-unrelated-config': ('  project_paths_resolve "$ROOT" >/dev/null || exit 1', '  project_paths_resolve "$ROOT" >/dev/null || exit 1\n  git -C "$ROOT" config --local core.ignorecase true', ['p01-no-hook']),
}


def put(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)
    path.chmod(0o755 if path.suffix == '.sh' else 0o644)


def main():
    baseline = subprocess.run(['git', '-C', str(REPO), 'show', BASE + ':scripts/mint_line.sh'], check=True, capture_output=True).stdout
    original = baseline.decode()
    anchor = '# 0. Дверь 031 неотвратима для ЭТОГО коммита'
    assert original.count(anchor) == 1
    model = original.replace('NEXT_ID_LIB=1', 'export NEXT_ID_LIB=1').replace(anchor, PROJECT + anchor)
    carriers = {'model/station.sh': baseline, 'model/mint_line.sh': model.encode()}
    links = []
    for name, (old, new, cases) in MUTATIONS.items():
        assert model.count(old) == 1, (name, model.count(old))
        rel = 'stabs/' + name + '/mint_line.sh'
        carriers[rel] = model.replace(old, new).encode()
        for case in cases:
            links.append({'stab': rel, 'case': case})
    for rel, data in carriers.items():
        put(HERE / rel, data)
    manifest = {'base': BASE, 'nositeli': {rel: hashlib.sha256(data).hexdigest() for rel, data in carriers.items()}, 'stab_vhod': links}
    put(HERE / 'source.json', (json.dumps(manifest, ensure_ascii=False, indent=2) + '\n').encode())
    print('NOSITELI', len(carriers), 'STABY', len(MUTATIONS), 'SVJAZI', len(links))


if __name__ == '__main__':
    main()
