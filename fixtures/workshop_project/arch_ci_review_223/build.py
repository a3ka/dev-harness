#!/usr/bin/env python3
"""223 reference changes only service-path selection; addressed mutations (Н-39)."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = 'f82ff8c9d0d4ba45a53b7aa2e712c552141715f9'
SERVICE = '''_arch_ci_service_path() {
  case "$1" in
    .harness/*|.review/*) return 0 ;;
    *) return 1 ;;
  esac
}

'''
OLD = '''            case "$_a187_path" in
              .harness/*) : ;;
              *) _a187_only=0 ;;
            esac'''
NEW = '''            _arch_ci_service_path "$_a187_path" || _a187_only=0'''
# Each named input distinguishes the altered operation from honest behavior.
MUTATIONS = (
    ('s01-review-prefix', '.harness/*|.review/*', '.harness/*|.review*',
     ('reviewx', 'review-file')),
    ('s02-any-dot-directory', '.harness/*|.review/*', '.*/*',
     ('review-other-dot',)),
    ('s03-any-service-mixed', '_a187_only=1\n          _a187_npaths=0',
     '_a187_only=0\n          _a187_npaths=0', ('mixed-review-product', 'mixed-both-product')),
    ('s04-foldcase', 'case "$1" in', 'case "${1,,}" in', ('review-uppercase',)),
    ('s05-no-success-required', '[ "$_a187_n" -gt 0 ] || die', 'true || die',
     ('review-missing-run', 'review-failed-run', 'review-skipped-run', 'review-other-sha')),
    ('s06-harness-broken', '.harness/*|.review/*', '.review/*', ('harness-merge',)),
    ('s07-rename-source-hidden', '--no-renames --ignore-submodules=none --name-only',
     '--find-renames --ignore-submodules=none --name-only', ('product-rename-in',)),
    ('s08-second-parent', '_a187_p1="${_a187_rest%% *}"',
     '_a187_p1="${_a187_rest##* }"', ('review-merge', 'backend177-chain')),
    ('s09-critic-empty-predicate', '[ "$_a187_npaths" -eq 0 ] || [ "$_a187_only" -ne 1 ]',
     '[ "$_a187_only" -ne 1 ]',
     ('empty-first-parent-success', 'empty-first-head-success')),
    ('s10-empty-is-service', '_a187_npaths=0', '_a187_npaths=1',
     ('empty-first-parent-success', 'empty-first-head-success')),
    ('s11-empty-by-second-diff', '"$_a187_p1" "$_a187_sel" )',
     '"${_a187_sel}^2" "$_a187_sel" )',
     ('empty-first-parent-success', 'empty-second-review', 'empty-second-harness')),
    ('s12-octopus-third-ignored', '[ "$_a187_np" -gt 2 ]', '[ "$_a187_np" -gt 3 ]',
     ('octopus-empty', 'octopus-service', 'octopus-mixed')),
    ('s13-reviewer-partial-fold', '.harness/*|.review/*', '.[Hh]arness/*|.[Rr]eview/*',
     ('review-titlecase', 'harness-titlecase')),
    ('s14-reviewer-review-hidden', '.harness/*|.review/*', '.harness/*|.review/[!.]*',
     ('review-hidden',)),
    ('s15-harness-hidden', '.harness/*|.review/*', '.harness/[!.]*|.review/*',
     ('harness-hidden',)),
)
EQUIVALENTS = (
    ('e01-case-order', '.harness/*|.review/*', '.review/*|.harness/*',
     ('both-services', 'harness-merge', 'review-merge', 'mixed-review-product', 'review-file',
      'review-titlecase', 'harness-titlecase', 'review-hidden', 'harness-hidden')),
    ('e02-if-equivalent', NEW,
     '            if ! _arch_ci_service_path "$_a187_path"; then _a187_only=0; fi',
     ('reviewx', 'review-uppercase', 'review-missing-run', 'review-rename',
      'review-titlecase', 'harness-titlecase', 'review-hidden', 'harness-hidden')),
    ('e03-empty-guard-equivalent',
     '[ "$_a187_npaths" -eq 0 ] || [ "$_a187_only" -ne 1 ]',
     '[ "$_a187_only" -ne 1 ] || [ "$_a187_npaths" -lt 1 ]',
     ('empty-first-parent-success', 'empty-first-head-success', 'empty-second-review',
      'empty-second-harness', 'empty-second-product', 'both-services')),
    ('e04-octopus-guard-equivalent', '[ "$_a187_np" -gt 2 ]', '[ "$_a187_np" -ge 3 ]',
     ('octopus-empty', 'octopus-service', 'octopus-mixed', 'harness-merge')),
)


def replace_one(text, old, new):
    if text.count(old) != 1:
        raise RuntimeError('ANCHOR_COUNT ' + repr(old) + ': ' + str(text.count(old)))
    return text.replace(old, new)


def main():
    baseline = subprocess.run(['git', '-C', str(ROOT), 'show', BASE + ':scripts/done_contract.sh'],
                              capture_output=True, check=True).stdout.decode()
    model = replace_one(baseline, 'TARGET="${1:?', SERVICE + 'TARGET="${1:?')
    model = replace_one(model, OLD, NEW)
    # Existing station diagnostics; reference-only annotations, no product edit.
    model = replace_one(model, '#!/usr/bin/env bash\n',
                        '#!/usr/bin/env bash\n# shellcheck disable=SC2034,SC2295,SC1010\n')
    carriers = {'model/done_contract.sh': model}
    links = []
    for name, old, new, cells in MUTATIONS + EQUIVALENTS:
        candidate = replace_one(model, old, new)
        if name == 's03-any-service-mixed':
            candidate = replace_one(candidate, NEW,
                '            if _arch_ci_service_path "$_a187_path"; then _a187_only=1; fi')
        rel = 'stabs/' + name + '/done_contract.sh'
        carriers[rel] = candidate
        links.append({'carrier': rel, 'cells': list(cells),
                      'polarity': 'green' if name.startswith('e') else 'red'})
    for rel, text in carriers.items():
        path = HERE / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)
    source = {'base': BASE, 'files': {rel: hashlib.sha256(text.encode()).hexdigest()
                                    for rel, text in carriers.items()}, 'links': links}
    (HERE / 'source.json').write_text(json.dumps(source, ensure_ascii=False, indent=2) + '\n')
    (HERE / 'stabs.tsv').write_text(''.join(row['carrier'] + '\t' + case + '\t' + row['polarity'] + '\n'
                                         for row in links for case in row['cells']))
    print('NOSITELI', len(carriers), 'STABY', len(MUTATIONS), 'EKVIVALENTY', len(EQUIVALENTS),
          'SVJAZI', sum(len(row['cells']) for row in links))


if __name__ == '__main__':
    main()
