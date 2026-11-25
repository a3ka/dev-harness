#!/usr/bin/env python3
"""Materialize the pinned station canon, reference and addressed mutations."""
import hashlib
import json
import subprocess
from pathlib import Path
from probe221 import CASES

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
BASE = '8b52fade7975034d7cabece67e46c16a7d1abe3b'
PRODUCTION_BASE = '7cd4dbbe51bc6ba0df021d3104134160a926dfc3'
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
    # Crit221 v1 БЛОК-1 (К-08): очистка одноразового хука стёрта — остаток
    # временного каталога обязан красить и успех (p01), и отказ двери (p07).
    'st13-no-cleanup': ("trap 'rm -rf -- \"$HOOK_WORK\"' EXIT", ': # cleanup removed (m2)', ['p01-no-hook', 'p07-live-door-refusal']),
    # Crit221 v1 БЛОК-2 (К-09): нормализация сносит всю секцию [user] вместо
    # точечного unset-all — клетка p12 несёт иные [user]-ключи.
    'st14-user-section': ('git -C "$ROOT" config --local --unset-all "$key" || cfg_rc=$?',
                          '{ git -C "$ROOT" config --local --remove-section user 2>/dev/null || true; }',
                          ['p12-user-family-config']),
}

# Adv221 К-08: exact production mutants, not approximations of the model.
# C05..C09 change cleanup AND placement; one contiguous, unique source anchor
# spans those edits, retaining all intervening production bytes.
def production_mutations(production):
    clean = 'rm -rf -- "$_mint_hook_work" >/dev/null 2>&1 || true'
    mktemp = '_mint_hook_work="$(mktemp -d)" \\'
    start = production.index(clean)
    end = production.index(mktemp) + len(mktemp)
    cleanup_anchor = production[start:end]
    mutations = {}
    for number, name, location in (
            (15, 'git', '"$ROOT/.git/mint-hook.XXXXXX"'),
            (16, 'tmp', '/tmp/mint-hook.XXXXXX'),
            (17, 'hooks', '"$ROOT/.git/hooks/once.XXXXXX"'),
            (18, 'info', '"$ROOT/.git/info/once.XXXXXX"'),
            (19, 'home', '"${HOME:-/tmp}/.mint-hook.XXXXXX"')):
        changed = cleanup_anchor.replace(clean, ':').replace(
            mktemp, '_mint_hook_work="$(mktemp -d ' + location + ')" \\')
        mutations[f'st{number}-residue-{name}'] = (
            cleanup_anchor, changed, ['p13-hook-cleanup-success', 'p14-hook-cleanup-refusal'])
    minted = 'COMMIT_SHA="$(git -C "$ROOT" rev-parse HEAD)"'
    condition = 'if [ -f "$ROOT/harness.project.json" ]; then\n  # Префлайт'
    rollback = 'git -C "$ROOT" checkout HEAD -- "$_REG_FILE" 2>/dev/null || true'
    mutations.update({
        'st20-tag-created': (minted, 'git -C "$ROOT" tag "minted/$NNN"\n' + minted, ['p15-local-refs-success']),
        'st21-tag-deleted': (minted, 'git -C "$ROOT" tag -d "id/CONTRACT/$NNN" >/dev/null\n' + minted, ['p15-local-refs-success']),
        'st22-tag-rewritten': (minted, 'GIT_COMMITTER_NAME=x GIT_COMMITTER_EMAIL=x@y git -C "$ROOT" tag -f -a "id/CONTRACT/$NNN" -m moved >/dev/null\n' + minted, ['p15-local-refs-success']),
        'st23-branch-created': (minted, 'git -C "$ROOT" branch "minted-$NNN"\n' + minted, ['p15-local-refs-success']),
        'st24-refusal-tag-deleted': ('  printf \'ОТКАЗ: commit строки реестра отказал', '  git -C "$ROOT" tag -d "id/CONTRACT/$NNN" >/dev/null\n  printf \'ОТКАЗ: commit строки реестра отказал', ['p16-local-refs-refusal']),
        'st25-clean-ignored': (rollback, rollback + '\n  git -C "$ROOT" clean -fdxq 2>/dev/null || true', ['p17-ignored-rollback']),
        'st26-marker-layer': (condition, 'if [ -f "$ROOT/.harness/project-layer.json" ]; then\n  # Префлайт', ['s06-layer-only']),
        'st27-marker-cwd': (condition, 'if [ -f harness.project.json ]; then\n  # Префлайт', ['p18-foreign-cwd']),
        'st28-marker-workflow': (condition, 'if [ -f "$ROOT/harness.project.json" ] || [ -d "$ROOT/.workflow" ]; then\n  # Префлайт', ['s08-workflow-only']),
        'st29-marker-tracked': (condition, 'if git -C "$ROOT" cat-file -e HEAD:harness.project.json 2>/dev/null; then\n  # Префлайт', ['p19-untracked-profile']),
        'st30-marker-parent': (condition, 'if [ -f "$ROOT/harness.project.json" ] || [ -f "$ROOT/../harness.project.json" ]; then\n  # Префлайт', ['s07-parent-profile']),
        'st31-no-profile-preflight': ('  project_paths_resolve "$ROOT" >/dev/null || exit 1\n', '', ['p20-broken-profile']),
        'st32-early-normalization': ('current_head="$(git -C "$ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"', '[ ! -f "$ROOT/harness.project.json" ] || { git -C "$ROOT" config --local --unset-all user.name || true; git -C "$ROOT" config --local --unset-all user.email || true; }\ncurrent_head="$(git -C "$ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"', ['p21-not-main', 'p22-dirty']),
        'st33-config-sed': ('git -C "$ROOT" config --local --unset-all "$_mint_key" || _mint_rc=$?', 'sed -i "/^[[:space:]]*${_mint_key#user.} *=/d" "$ROOT/.git/config" || _mint_rc=$?', ['p23-other-config']),
    })
    return mutations



def put(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)
    path.chmod(0o755 if path.suffix == '.sh' else 0o644)


def main():
    baseline = subprocess.run(['git', '-C', str(REPO), 'show', BASE + ':scripts/mint_line.sh'], check=True, capture_output=True).stdout
    production = subprocess.run(['git', '-C', str(REPO), 'show', PRODUCTION_BASE + ':scripts/mint_line.sh'], check=True, capture_output=True).stdout.decode()
    original = baseline.decode()
    anchor = '# 0. Дверь 031 неотвратима для ЭТОГО коммита'
    assert original.count(anchor) == 1
    # `export NEXT_ID_LIB=1` is NOT part of the contract and NOT required of the
    # implementer: check_staged.sh/check_charter.sh set NEXT_ID_LIB themselves, so it
    # is inert for the hook chain. It exists only so the pinned shellcheck pass on
    # the model (--sintaksis) does not stop on SC2034 for the baseline's bare assignment.
    model = original.replace('NEXT_ID_LIB=1', 'export NEXT_ID_LIB=1').replace(anchor, PROJECT + anchor)
    carriers = {'model/station.sh': baseline, 'model/mint_line.sh': model.encode()}
    links = []
    for name, (old, new, cases) in MUTATIONS.items():
        assert model.count(old) == 1, (name, model.count(old))
        rel = 'stabs/' + name + '/mint_line.sh'
        carriers[rel] = model.replace(old, new).encode()
        for case in cases:
            links.append({'stab': rel, 'case': case})
    new_mutations = production_mutations(production)
    for name, (old, new, cases) in new_mutations.items():
        assert production.count(old) == 1, (name, production.count(old))
        rel = 'stabs/' + name + '/mint_line.sh'
        carriers[rel] = production.replace(old, new).encode()
        links.extend({'stab': rel, 'case': case} for case in cases)
    for rel, data in carriers.items():
        put(HERE / rel, data)
    manifest = {'base': BASE, 'production_base': PRODUCTION_BASE, 'kletki': list(CASES),
                'nositeli': {rel: hashlib.sha256(data).hexdigest() for rel, data in carriers.items()}, 'stab_vhod': links}
    put(HERE / 'source.json', (json.dumps(manifest, ensure_ascii=False, indent=2) + '\n').encode())
    print('KLETKI', len(CASES), 'NOSITELI', len(carriers),
          'STABY', len(MUTATIONS) + len(new_mutations), 'SVJAZI', len(links))


if __name__ == '__main__':
    main()
