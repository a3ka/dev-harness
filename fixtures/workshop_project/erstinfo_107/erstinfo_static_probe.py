#!/usr/bin/env python3
"""Статическая проба 107 (CMP-MOB-003): шов ApiClient, копия каталога, mock.

Без --model на до-предметном дереве → rc1 ERSTINFO_MODULE_ABSENT.
С --model/честным C → rc0: ключи каталога verbatim (текст+review_status),
четыре операции шва, сценарии mock, проводка runtime.
--matrix: обманные стабы статической семьи красны именованной клеткой.
Выход — только код возврата; перечень case построчно.
"""
import argparse
import re
from pathlib import Path
import sys

from probe_lib import COMPONENT_PATH, HERE, installed, load_source, model_bytes

CASES = []


def check(cond, case):
    CASES.append((case, bool(cond)))
    if not cond:
        print('RED', case)


def run_checks(repo: Path):
    src = load_source()
    ui = (repo / 'mobile/src/i18n/ui-copy.ts').read_text(encoding='utf-8')
    for key, entry in src['copy'].items():
        pat = (
            r"'" + re.escape(key) + r"': \{ text: '"
            + re.escape(entry['text'])
            + r"', review_status: '" + re.escape(entry['review_status']) + r"' \}"
        )
        check(re.search(pat, ui), 'COPY_KEY_' + key.replace('.', '_'))
    api = (repo / 'mobile/src/api/api-client.ts').read_text(encoding='utf-8')
    check(re.search(r'getSession\(\): Promise<Session>;', api), 'STATIC_API_SEAM_GETSESSION')
    check(re.search(r'getDisclosure\(disclosureId: string\): Promise<Disclosure>;', api),
          'STATIC_API_SEAM_GETDISCLOSURE')
    check(re.search(
        r'acknowledgeDisclosure\(disclosureRef: string, version: number\): Promise<AcknowledgeDisclosureResult>;',
        api), 'STATIC_API_SEAM_ACKNOWLEDGE')
    check(re.search(r'getDisclosureGate\(\): Promise<DisclosureGateSnapshot>;', api),
          'STATIC_API_SEAM_GATE')
    mock = (repo / 'mobile/src/mocks/disclosure-mock.ts').read_text(encoding='utf-8')
    check("'CURRENT_CONFIRMED'" in mock and 'gateFor' in mock, 'STATIC_MOCK_SCENARIOS')
    rt = (repo / 'mobile/src/mocks/runtime.ts').read_text(encoding='utf-8')
    check('  acknowledgeDisclosure,' in rt and '  getDisclosureGate,' in rt,
          'STATIC_MOCK_RUNTIME_WIRED')

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', required=True)
    ap.add_argument('--model', action='store_true')
    ap.add_argument('--matrix', action='store_true')
    args = ap.parse_args()
    repo = Path(args.repo).resolve()

    if args.matrix:
        return matrix(repo)

    blobs = model_bytes() if args.model else None
    files = {repo / rel: blob for rel, blob in blobs.items()} if blobs else {}
    with installed(files):
        if not (repo / COMPONENT_PATH).exists():
            print('ERSTINFO_MODULE_ABSENT')
            return 1
        run_checks(repo)
    ok = sum(1 for _, v in CASES if v)
    for case, v in CASES:
        if v:
            print('case', case)
    print(f'static {ok}/{len(CASES)}')
    return 0 if ok == len(CASES) else 1


def matrix(repo: Path):
    U = 'mobile/src/i18n/ui-copy.ts'
    A = 'mobile/src/api/api-client.ts'
    R = 'mobile/src/mocks/runtime.ts'
    MUTANTS = {
        'api-seam-ack-lost': (
            [(A,
              'acknowledgeDisclosure(disclosureRef: string, version: number): Promise<AcknowledgeDisclosureResult>;',
              'acknowledgeDisclosure(disclosureRef: string, version: number): Promise<AcknowledgeDisclosureResult> | void;')],
            ['STATIC_API_SEAM_ACKNOWLEDGE'], []),
        'mock-runtime-unwired': (
            [(R, 'acknowledgeDisclosure,\n  getDisclosureGate,', '')],
            ['STATIC_MOCK_RUNTIME_WIRED'], []),
        'copy-invented-static': (
            [(U, "text: 'Der Nachweis steht noch aus. Wir prüfen die Übermittlung.'",
              "text: 'Der Nachweis steht noch aus.'")],
            ['COPY_KEY_disclosure_pending'], []),
        'ui-copy-key-dropped': (
            [(U, "  'disclosure.updated': { text: 'Für diesen Schritt ist eine neuere Erstinformation erforderlich.', review_status: 'EDITORIAL_DRAFT_REVIEW_REQUIRED' },\n",
              '')],
            ['COPY_KEY_disclosure_updated'], []),
    }
    bad = 0
    for name, (muts, named, depends) in MUTANTS.items():
        blobs = model_bytes(muts)
        global CASES
        CASES = []
        files = {repo / rel: blob for rel, blob in blobs.items()}
        with installed(files):
            run_checks(repo)
            red = {c for c, v in CASES if not v}
        allowed = set(named) | set(depends)
        unexpected = red - allowed
        if not red & set(named):
            print(f'mutant {name}: named RED отсутствует ({sorted(red)})')
            bad += 1
        elif unexpected:
            print(f'mutant {name}: unexpected_red={sorted(unexpected)}')
            bad += 1
        else:
            print(f'mutant {name}: named RED ok, depends_red={sorted(red & set(depends))}')
    print(f'mutants {len(MUTANTS)}, defects {bad}')
    return 0 if bad == 0 else 2


if __name__ == '__main__':
    sys.exit(main())
