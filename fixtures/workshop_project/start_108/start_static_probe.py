#!/usr/bin/env python3
"""Статическая проба 108 (CMP-MOB-004): шов ApiClient, копия каталога, mock,
отсутствие голосового wire-перечня.

Без --model на до-предметном дереве → rc1 START_SEAM_ABSENT.
С --model/честным C → rc0: ключи каталога verbatim (текст+review_status),
операции шва, сценарии mock, проводка runtime, Listening не в wire-enum и
нет аудио-импортов в экранах Start.
--matrix: обманные стабы статической семьи красны именованной клеткой.
Выход — только код возврата; перечень case построчно.
"""
import argparse
import re
from pathlib import Path
import sys

from probe_lib import HERE, installed, load_source, model_bytes

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
            "'" + re.escape(key) + r"': \{ text: '" + re.escape(entry['text'])
            + r"', review_status: '" + re.escape(entry['review_status']) + r"' \}"
        )
        check(re.search(pat, ui), 'COPY_KEY_' + key.replace('.', '_'))
    api = (repo / 'mobile/src/api/api-client.ts').read_text(encoding='utf-8')
    check(re.search(r'getSession\(\): Promise<Session>;', api), 'STATIC_API_SEAM_GETSESSION')
    check(re.search(r'getDisclosure\(disclosureId: string\): Promise<Disclosure>;', api),
          'STATIC_API_SEAM_GETDISCLOSURE')
    check(re.search(r'listMissions\(contextRef\?: string\): Promise<MissionPage>;', api),
          'STATIC_API_SEAM_LISTMISSIONS')
    check(re.search(r'export type MissionState =', api)
          and all(f"| '{state}'" in api for state in src['mission_states']),
          'STATIC_MISSION_STATE_ENUM')
    mock = (repo / 'mobile/src/mocks/start-mock.ts').read_text(encoding='utf-8')
    check("'PRESENT'" in mock and 'missionsFor' in mock, 'STATIC_MOCK_SCENARIOS')
    rt = (repo / 'mobile/src/mocks/runtime.ts').read_text(encoding='utf-8')
    check(re.search(r'mockApiClient: ApiClient = \{[^}]*listMissions', rt),
          'STATIC_MOCK_RUNTIME_WIRED')
    # Listening — UI-состояние, не wire enum; экраны Start без аудио-импортов.
    check("'LISTENING'" not in api, 'STATIC_NO_VOICE_ENUM')
    audio_re = re.compile(r"import[^;\n]*(expo-av|Audio|Speech|microphone)", re.IGNORECASE)
    screens = [
        (repo / 'mobile/src/features/start/start-screen.tsx').read_text(encoding='utf-8'),
        (repo / 'mobile/src/ui/agent-presence/agent-presence.tsx').read_text(encoding='utf-8'),
        (repo / 'mobile/src/ui/conversation-composer/conversation-composer.tsx').read_text(encoding='utf-8'),
    ]
    check(not any(audio_re.search(s) for s in screens), 'STATIC_NO_AUDIO_IMPORTS')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', required=True)
    ap.add_argument('--model', action='store_true')
    ap.add_argument('--matrix', action='store_true')
    args = ap.parse_args()
    repo = Path(args.repo).resolve()

    if args.matrix:
        return matrix(repo)

    seam = repo / 'mobile/src/ui/agent-presence/agent-presence.tsx'
    if not args.model and not (seam.exists() and (repo / 'mobile/src/api/api-client.ts').exists()):
        print('START_SEAM_ABSENT')
        return 1
    files = {}
    if args.model:
        for rel, blob in model_bytes().items():
            files[repo / rel] = blob
    with installed(files):
        run_checks(repo)
    ok = sum(1 for _, good in CASES if good)
    for case, good in CASES:
        if good:
            print('case', case)
    if ok != len(CASES):
        return 1
    print(f'static {ok}/{len(CASES)}')
    return 0


def matrix(repo: Path):
    U = 'mobile/src/i18n/ui-copy.ts'
    A = 'mobile/src/api/api-client.ts'
    R = 'mobile/src/mocks/runtime.ts'
    MUTANTS = {
        'copy-invented': (
            [(U, "  'frame.F04.01.body': { text: 'Was ist passiert? Schreiben Sie, sprechen Sie oder fügen Sie ein Foto oder Dokument hinzu.', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },",
              "  'frame.F04.01.body': { text: 'Was ist passiert?', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },")],
            ['COPY_KEY_frame_F04_01_body'], []),
        'seam-missing-listmissions': (
            [(A, "  /** READ: ACL-filtered list of missions of the current context (W0). */\n"
                 '  listMissions(contextRef?: string): Promise<MissionPage>;',
              '  /** READ: ACL-filtered list of missions of the current context (W0). */')],
            ['STATIC_API_SEAM_LISTMISSIONS'], []),
        'mock-not-wired': (
            [(R, 'const mockApiClient: ApiClient = { getSession, getDisclosure, listMissions };',
              'const mockApiClient: ApiClient = { getSession, getDisclosure };')],
            ['STATIC_MOCK_RUNTIME_WIRED'], []),
        'voice-enum-leak': (
            [(A, "  | 'CANCELLED';", "  | 'CANCELLED'\n  | 'LISTENING';")],
            ['STATIC_NO_VOICE_ENUM'], []),
    }
    bad = 0
    for name, (muts, named, depends) in MUTANTS.items():
        files = {repo / rel: blob for rel, blob in model_bytes(muts).items()}
        with installed(files):
            CASES.clear()
            run_checks(repo)
        red = {case for case, good in CASES if not good}
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
