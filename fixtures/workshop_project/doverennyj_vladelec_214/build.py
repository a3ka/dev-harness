#!/usr/bin/env python3
"""214: pinned existing CLI plus trusted-owner snapshot; no production edits."""
import hashlib
import json
import subprocess
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = 'f82ff8c9d0d4ba45a53b7aa2e712c552141715f9'
HELPER = r'''# [214] --repo is supplied by the trusted runtime, never by the author task.
# Freeze metadata HEAD once. Clone checks out committed bytes, including the
# existing project resolver inputs; local author refs/files are never consulted.
RISK_SNAPSHOTS=()
trap 'if [ "${#RISK_SNAPSHOTS[@]}" -gt 0 ]; then rm -rf -- "${RISK_SNAPSHOTS[@]}"; fi' EXIT
risk_snapshot() {  # trusted repository, immutable commit, destination
  local source="$1" commit="$2" dest="$3"
  git -c core.hooksPath=/dev/null clone -q --shared --no-checkout -- "$source" "$dest" 2>/dev/null || return 1
  git -C "$dest" -c core.hooksPath=/dev/null checkout -q --detach "$commit" 2>/dev/null || return 1
}
risk_metadata_kat() {
  ( unset HARNESS_PROJECT_LAYER_ROOT; kontrakt_kat "$1" )
}
risk_metadata_registry() {
  ( unset HARNESS_PROJECT_LAYER_ROOT; reestr_put "$1" contracts.tsv )
}
'''
# These replace complete operations, each anchor must occur exactly once.
SELECT_OLD = '''      risk_repo="$REPO"
      if [ "$(git -C "$r_wt" remote get-url origin 2>/dev/null)" != "$REPO_URL" ]; then
        risk_repo="$r_wt"
      fi
'''
SELECT_NEW = '''      risk_source="$REPO"
      risk_ref="$(git -C "$risk_source" rev-parse --verify 'HEAD^{commit}' 2>/dev/null)" || {
        mutexi_snyat_vse
        otp ISTOCHNIK_RISKA_NEDOSTUPEN "предмет $sv: нет закреплённого состояния владельца"
      }
      risk_tmp="$(mktemp -d)" || { mutexi_snyat_vse; skip 'risk snapshot: mktemp'; }
      RISK_SNAPSHOTS+=("$risk_tmp")
      risk_repo="$risk_tmp/owner"
      if ! risk_snapshot "$risk_source" "$risk_ref" "$risk_repo"; then
        rm -rf -- "$risk_tmp"
        mutexi_snyat_vse
        otp ISTOCHNIK_RISKA_NEDOSTUPEN "предмет $sv: снимок владельца недоступен"
      fi
'''
TRANSFER_OLD = '        r_wt="$P_WT"; r_br="$P_BRANCH"; risk_repo="$P_WT"\n'
TRANSFER_NEW = '''        r_wt="$P_WT"; r_br="$P_BRANCH"
        # Only the frozen commit authenticated by the station receipt is trusted.
        if [ -z "$P_FROZEN" ]; then
          rm -rf -- "$risk_tmp"
          mutexi_snyat_vse
          otp ISTOCHNIK_RISKA_NEDOSTUPEN "предмет $sv: источник передачи не удостоверен"
        fi
        rm -rf -- "$risk_repo"
        if ! risk_snapshot "$P_WT" "$P_FROZEN" "$risk_repo"; then
          rm -rf -- "$risk_tmp"
          mutexi_snyat_vse
          otp ISTOCHNIK_RISKA_NEDOSTUPEN "предмет $sv: снимок передачи недоступен"
        fi
'''
MUTATIONS = {
    's01-holder-no-origin': ( '      risk_source="$REPO"\n', '      risk_source="$r_wt"\n', ['isolated-risk']),
    's02-working-legacy': ('git -C "$owner" show HEAD:registry/risk-legacy.tsv', 'cat "$risk_source/registry/risk-legacy.tsv"', ['dirty-legacy-risk', 'dirty-legacy-safe', 'dirty-legacy-untracked']),
    's03-working-profile': ('  ( unset HARNESS_PROJECT_LAYER_ROOT; kontrakt_kat "$1" )', '  ( unset HARNESS_PROJECT_LAYER_ROOT; kontrakt_kat "$risk_source" )', ['dirty-profile', 'profile-deleted']),
    's04-holder-tags': ('git -C "$owner" for-each-ref --format=\'%(refname)\' "refs/tags/frozen/contracts/$n/"', 'git -C "$r_wt" for-each-ref --format=\'%(refname)\' "refs/tags/frozen/contracts/$n/"', ['forged-latest-tag']),
    's05-unknown-safe': ("          kr='risikovyj'\n", "          kr='obychnyj'\n", ['arb1', 'arb2', 'arb5', 'arb6', 'unknown-legacy']),
    's06-floating-head': ('checkout -q --detach "$commit"', 'checkout -q --detach HEAD', ['pinned-head']),
    's07-d52-holder-profile': ('kr="$(klass_riska "$sv" "$r_wt" "$obj_fakt" "$risk_repo")"\n', 'kr="$(klass_riska "$sv" "$r_wt" "$obj_fakt" "$r_wt")"\n', ['critic-profile']),
    's08-d64-holder-legacy': ('kr="$(klass_riska "$sv" "$r_wt" "$obj_fakt" "$risk_repo")"; kr_det=\'\'\n', 'kr="$(klass_riska "$sv" "$r_wt" "$obj_fakt" "$r_wt")"; kr_det=\'\'\n', ['dirty-author-legacy']),
    's09-holder-pin': ('P_FROZEN="$(frozen_predmeta "$sv" "$risk_repo")"', 'P_FROZEN="$(frozen_predmeta "$sv" "$r_wt")"', ['forged-pin']),
    's10-transfer-head': ('risk_snapshot "$P_WT" "$P_FROZEN" "$risk_repo"', 'risk_snapshot "$P_WT" HEAD "$risk_repo"', ['product-dirty-profile']),
    's11-symlink-legacy': ('git -C "$owner" show HEAD:registry/risk-legacy.tsv', 'cat "$owner/registry/risk-legacy.tsv"', ['legacy-symlink']),
    's12-receipt-working-profile': ('    reg_put="$(risk_metadata_registry "$risk_repo")" || reg_put=\'\'', '    reg_put="$(reestr_put "$REPO" contracts.tsv)" || reg_put=\'\'', ['product-station-profile']),
}


def one(text, old, new):
    if text.count(old) != 1:
        raise RuntimeError('ANCHOR_COUNT %s %s' % (text.count(old), repr(old)))
    return text.replace(old, new, 1)


def comment_block(text, start, end, replacement):
    if text.count(start) != 1 or text.count(end) != 1:
        raise RuntimeError('COMMENT_ANCHOR_COUNT')
    a, b = text.index(start), text.index(end)
    return text[:a] + replacement + text[b:]


def model():
    text = subprocess.run(['git', '-C', str(ROOT), 'show', BASE + ':scripts/zamok_predmeta.sh'], capture_output=True, check=True).stdout.decode()
    text = comment_block(text, '# v211 (контракт 211, D64 bootstrap-sudej', '# [Б-1 адверсария 211]',
                         '# 214: D42/D52/D64 сохраняют условия bootstrap; владелец — доверенный\n# --repo либо station receipt frozen. Профиль и legacy — закреплённый снимок.\n')
    text = comment_block(text, '# [D64 bootstrap-sudej] (211) 4-й аргумент', '# [Б-1 перечень NUL-безопасен]',
                         '# 214: четвёртый аргумент — доверенный снимок метаданных владельца.\n')
    text = comment_block(text, '# Дерево OBJECT читается в носителе автора', '# Промах любого условия',
                         '# 214: OBJECT — в носителе, профиль/legacy и frozen refs — у владельца.\n')
    text = one(text, 'klass_riska() {', HELPER + 'klass_riska() {')
    text = one(text, SELECT_OLD, SELECT_NEW)
    text = one(text, TRANSFER_OLD, TRANSFER_NEW)
    text = one(text, 'local transfer P_JSON P_WT P_BRANCH P_OBJECT P_FROZEN risk_repo', 'local transfer P_JSON P_WT P_BRANCH P_OBJECT P_FROZEN risk_repo risk_source risk_ref risk_tmp')
    text = one(text, '  kat="$(kontrakt_kat "$owner")" || kat=\'\'', '  kat="$(risk_metadata_kat "$owner")" || kat=\'\'')
    text = one(text, '  kat="$(kontrakt_kat "$owner")" || return 1', '  kat="$(risk_metadata_kat "$owner")" || return 1')
    text = one(text, 'kr="$(klass_riska "$sv" "$r_wt" "$obj_fakt")"', 'kr="$(klass_riska "$sv" "$r_wt" "$obj_fakt" "$risk_repo")"')
    text = one(text, '  put="$(reestr_put "$owner" contracts.tsv)"', '  put="$(risk_metadata_registry "$owner")"')
    receipt_old = '''  reg_put="$(reestr_put "$REPO" contracts.tsv)" || reg_put=''
  reg_put="${reg_put#"$REPO/"}"'''
    receipt_new = '''  if [ -n "${risk_repo:-}" ]; then
    reg_put="$(risk_metadata_registry "$risk_repo")" || reg_put=''
    reg_put="${reg_put#"$risk_repo/"}"
  else
    reg_put="$(reestr_put "$REPO" contracts.tsv)" || reg_put=''
    reg_put="${reg_put#"$REPO/"}"
  fi'''
    text = one(text, receipt_old, receipt_new)
    old_legacy = '''    if [ -z "$val" ] && [ -f "$owner/registry/risk-legacy.tsv" ]; then
      val="$(awk -F'\\t' -v b="$blob" 'b!="" && $1==b {print $2; exit}' "$owner/registry/risk-legacy.tsv")"
    fi'''
    new_legacy = '''    if [ -z "$val" ]; then
      val="$(git -C "$owner" show HEAD:registry/risk-legacy.tsv 2>/dev/null | awk -F'\\t' -v b="$blob" 'b!="" && $1==b {print $2; exit}')"
    fi'''
    text = one(text, old_legacy, new_legacy)
    text = one(text, '      case "$kr" in\n', '      rm -rf -- "$risk_tmp"\n      case "$kr" in\n')
    return text


def main():
    text = model()
    files = {'model/zamok_predmeta.sh': text}
    links = []
    for name, (old, new, cases) in MUTATIONS.items():
        mutant = one(text, old, new)
        path = 'stabs/' + name + '/zamok_predmeta.sh'
        files[path] = mutant
        links.append({'name': name, 'path': path, 'cases': cases})
    for path, content in files.items():
        target = HERE / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content)
    manifest = {'base': BASE, 'files': {p: hashlib.sha256(t.encode()).hexdigest() for p, t in files.items()}, 'links': links}
    (HERE / 'source.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n')
    (HERE / 'stabs.tsv').write_text(''.join('%s\t%s\t%s\n' % (l['name'], l['path'], c) for l in links for c in l['cases']))
    print('CARRIERS', len(files), 'STABS', len(links), 'LINKS', sum(len(l['cases']) for l in links))


if __name__ == '__main__':
    main()
