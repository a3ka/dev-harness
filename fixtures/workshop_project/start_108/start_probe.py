#!/usr/bin/env python3
"""Поведенческая проба 108 (CMP-MOB-004): Start F04.01–F04.07.

Исполняет настоящий Jest/RNTL на disposable R и разбирает отчёт поимённо.
Без --model: до-предметное дерево → именованный отказ rc1.
С --model: эталон architect ставится по путям поставки → rc0 с перечнем.
--matrix: каждый обманный стаб даёт красноту на объявленных ветвях
(named ∪ depends); краснота вне объявления — дефект матрицы rc2.
Выход — только код возврата; список case печатается построчно.
"""
import argparse
from pathlib import Path
import sys

from probe_lib import (
    COMPONENT_PATH, FAMILY_PREFIX, HERE, TEST_INSTALL, installed,
    jest_ready, model_bytes, run_jest,
)

NAMED_RED = 'START_SEAM_ABSENT'
SEAM_PATH = 'mobile/src/ui/agent-presence/agent-presence.tsx'


def case_name(title: str) -> str:
    return title[len(FAMILY_PREFIX):] if title.startswith(FAMILY_PREFIX) else title


def run_suite(repo: Path, blobs=None):
    mobile = repo / 'mobile'
    if not jest_ready(mobile):
        print('INFRASTRUCTURE: jest не установлен в R/mobile')
        return None
    test_src = (HERE / 'start.test.tsx').read_bytes()
    files = {repo / TEST_INSTALL: test_src}
    if blobs:
        for rel, blob in blobs.items():
            files[repo / rel] = blob
    with installed(files):
        cases, proc = run_jest(mobile, repo / TEST_INSTALL)
    if not cases and proc.returncode != 0:
        # suite failed to run (например, импорт отсутствующего модуля)
        return {}
    return cases


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
    if not args.model and not (
        (repo / SEAM_PATH).exists() and (repo / COMPONENT_PATH).exists()
    ):
        print(NAMED_RED)
        return 1
    cases = run_suite(repo, blobs)
    if cases is None:
        return 2
    if cases == {}:
        # suite не исполнился: без модели это до-предметное дерево,
        # с моделью — инфраструктурный отказ.
        if not args.model:
            print(NAMED_RED)
            return 1
        print('INFRASTRUCTURE: jest suite не исполнился на модели')
        return 2
    if not args.model and all(s == 'failed' for s in cases.values()):
        print(NAMED_RED)
        return 1
    failed = sorted(c for c, s in cases.items() if s != 'passed')
    for title in sorted(case_name(c) for c, s in cases.items() if s == 'passed'):
        print('case', title)
    if failed:
        for c in failed:
            print('RED', case_name(c))
        return 1
    print(f'honest {len(cases)}/{len(cases)}')
    return 0


def matrix(repo: Path):
    src = model_bytes()
    honest = run_suite(repo, src)
    if honest is None or any(s != 'passed' for s in honest.values()):
        print('MUTATION_MATRIX_HONEST_NOT_GREEN')
        return 2
    # Привязка стаб↔ветвь живёт только здесь (Н-39): name → (mutations, named, depends)
    C = 'mobile/src/features/start/start-screen.tsx'
    U = 'mobile/src/i18n/ui-copy.ts'
    M = 'mobile/src/mocks/start-mock.ts'
    R = 'mobile/src/mocks/runtime.ts'
    A = 'mobile/src/api/api-client.ts'
    P = 'mobile/src/ui/agent-presence/agent-presence.tsx'
    AVATARS = ['idle', 'working', 'unavailable']
    PRESENCES = ['EMPTY', 'PRESENT']
    MOTIONS = ['full', 'reduced']
    STATES = ['RECEIVED', 'WORKING', 'NEEDS_INFORMATION', 'ADVISER_REVIEW',
              'NEEDS_APPROVAL', 'WAITING_EXTERNAL', 'COMPLETED', 'PARTIAL',
              'BLOCKED', 'CANCELLED']

    def cells(prefix, avatars=AVATARS, presences=PRESENCES, motions=MOTIONS):
        return [f'{prefix}_{a}_{p}_{m}' for a in avatars for p in presences for m in motions]

    COMPOSER_ANCHOR = '<ConversationComposer onFocusInput={() => setUiState(\'INPUT\')} />'

    MUTANTS = {
        'empty-start-groups-list': (
            [(C, f'      {COMPOSER_ANCHOR}\n',
              f'      {COMPOSER_ANCHOR}\n'
              '      {(missions ?? []).length === 0 ? (\n'
              '        <View testID="start-empty-groups">\n'
              '          <Text style={[styles.body, { color: tokens.ink }]}>Keine Vorgaenge</Text>\n'
              '        </View>\n'
              '      ) : null}\n')],
            ['STRUCTURE_idle_EMPTY_full'],
            [c for c in cells('STRUCTURE', presences=['EMPTY']) if c != 'STRUCTURE_idle_EMPTY_full']),
        'kpi-dashboard': (
            [(C, '      {/* F04.V01: не более одной контекстной карточки — только resume-brief. */}\n',
              '      {/* F04.V01: не более одной контекстной карточки — только resume-brief. */}\n'
              '      {(missions ?? []).length > 0 ? (\n'
              '        <View testID="start-kpi-dashboard" style={[styles.card, { backgroundColor: tokens.card, borderColor: tokens.panel }]}>\n'
              '          <Text style={[styles.mono, { color: tokens[\'on-card\'] }]}>KPI 3/5</Text>\n'
              '        </View>\n'
              '      ) : null}\n')],
            ['STRUCTURE_idle_PRESENT_full'],
            [c for c in cells('STRUCTURE', presences=['PRESENT']) if c != 'STRUCTURE_idle_PRESENT_full']),
        'presence-replaced-by-list': (
            [(C, '      <AgentPresence state={avatarState} />',
              '      {missions === null ? <AgentPresence state={avatarState} /> : null}')],
            ['STRUCTURE_idle_EMPTY_full'],
            [c for c in cells('STRUCTURE') if c != 'STRUCTURE_idle_EMPTY_full']
            + [f'ACL_REVOKED_{a}' for a in AVATARS]),
        'composer-duplicated': (
            [(C, f'      {COMPOSER_ANCHOR}\n', f'      {COMPOSER_ANCHOR}\n      {COMPOSER_ANCHOR}\n')],
            ['STRUCTURE_idle_EMPTY_full'],
            [c for c in cells('STRUCTURE') if c != 'STRUCTURE_idle_EMPTY_full']
            + [f'MISSIONS_NULL_{a}' for a in AVATARS]
            + [f'ACL_REVOKED_{a}' for a in AVATARS]
            + [f'FRAME_INPUT_{a}' for a in AVATARS]
            + ['DRAFT_PRESERVED_AVATAR_CHANGE', 'DRAFT_PRESERVED_ACL_CHANGE',
               'DRAFT_PRESERVED_LISTENING_ROUNDTRIP']),
        'resume-without-mission': (
            [(C, '  const continuable = available.length > 0 ? available[0] : null;',
              '  const continuable =\n'
              '    available[0] ??\n'
              '    ({ mission_id: \'MIS-CAR-01\', state: \'WORKING\' as const, updated_at: \'2026-10-09T12:00:00Z\' });')],
            ['ACTION_RESUME_idle_EMPTY_full'],
            [c for c in cells('STRUCTURE', presences=['EMPTY'])]
            + [c for c in cells('ACTION_RESUME', presences=['EMPTY']) if c != 'ACTION_RESUME_idle_EMPTY_full']
            + [f'ACL_REVOKED_{a}' for a in AVATARS]
            + [f'MISSIONS_NULL_{a}' for a in AVATARS]),
        'revoked-stale-brief': (
            [(C, 'import React, { useState } from \'react\';',
              'import React, { useRef, useState } from \'react\';'),
             (C, '  const available = missions ?? [];',
              '  const availableRef = useRef<readonly MissionBrief[] | null>(null);\n'
              '  if (missions && missions.length > 0) availableRef.current = missions;\n'
              '  const available = missions && missions.length > 0 ? missions : (availableRef.current ?? []);')],
            ['ACL_REVOKED_idle'],
            ['ACL_REVOKED_working', 'ACL_REVOKED_unavailable']),
        'talk-starts-mic': (
            [(C, '    setUiState(\'LISTENING\');\n    onTalk?.();',
              '    setUiState(\'LISTENING\');\n    onTalk?.();\n    onMicrophoneRequested?.();')],
            ['ACTION_TALK_idle_PRESENT_full'],
            [c for c in cells('ACTION_TALK') if c != 'ACTION_TALK_idle_PRESENT_full']
            + [f'FRAME_LISTENING_{a}' for a in AVATARS]),
        'talk-creates-mission': (
            [(C, '    setUiState(\'LISTENING\');\n    onTalk?.();',
              '    setUiState(\'LISTENING\');\n    onTalk?.();\n    onResume?.(\'MIS-CAR-01\');')],
            ['ACTION_TALK_idle_EMPTY_full'],
            [c for c in cells('ACTION_TALK') if c != 'ACTION_TALK_idle_EMPTY_full']
            + [f'FRAME_LISTENING_{a}' for a in AVATARS]),
        'write-side-nav': (
            [(C, '    if (uiState === \'LISTENING\') setUiState(\'INPUT\');\n    onWrite?.();',
              '    if (uiState === \'LISTENING\') setUiState(\'INPUT\');\n    onWrite?.();\n    onTalk?.();')],
            ['ACTION_WRITE_idle_EMPTY_full'],
            [c for c in cells('ACTION_WRITE') if c != 'ACTION_WRITE_idle_EMPTY_full']),
        'resume-loses-id': (
            [(C, '    if (continuable) onResume?.(continuable.mission_id);',
              '    if (continuable) onResume?.(\'\');')],
            ['ACTION_RESUME_idle_PRESENT_full'],
            [c for c in cells('ACTION_RESUME', presences=['PRESENT']) if c != 'ACTION_RESUME_idle_PRESENT_full']),
        'unavailable-hides-composer': (
            [(C, f'      {COMPOSER_ANCHOR}',
              '      {avatarState === \'unavailable\' ? null : '
              f'{COMPOSER_ANCHOR}}}')],
            ['STRUCTURE_unavailable_EMPTY_full'],
            ['STRUCTURE_unavailable_EMPTY_reduced', 'STRUCTURE_unavailable_PRESENT_full',
             'STRUCTURE_unavailable_PRESENT_reduced', 'MISSIONS_NULL_unavailable',
             'ACL_REVOKED_unavailable', 'FRAME_INPUT_unavailable']),
        'unavailable-looks-working': (
            [(P, '      <View testID={`start-avatar-${state}`} style={[styles.avatar, { borderColor: tokens.ink }]} />',
              '      <View testID="start-avatar-working" style={[styles.avatar, { borderColor: tokens.ink }]} />')],
            ['STRUCTURE_unavailable_EMPTY_full'],
            ['STRUCTURE_unavailable_EMPTY_reduced', 'STRUCTURE_unavailable_PRESENT_full',
             'STRUCTURE_unavailable_PRESENT_reduced',
             'STRUCTURE_idle_EMPTY_full', 'STRUCTURE_idle_EMPTY_reduced',
             'STRUCTURE_idle_PRESENT_full', 'STRUCTURE_idle_PRESENT_reduced']),
        'reduced-motion-drops-brief': (
            [(C, '      {continuable ? (',
              '      {(continuable && !reducedMotion) ? (')],
            ['STRUCTURE_idle_PRESENT_reduced'],
            ['STRUCTURE_working_PRESENT_reduced', 'STRUCTURE_unavailable_PRESENT_reduced',
             'ACTION_RESUME_idle_PRESENT_reduced', 'ACTION_RESUME_working_PRESENT_reduced',
             'ACTION_RESUME_unavailable_PRESENT_reduced']),
        'draft-lost-on-rerender': (
            [(C, f'      {COMPOSER_ANCHOR}',
              f'      <ConversationComposer key={{avatarState + String(missions === null ? \'n\' : missions.length)}} '
              'onFocusInput={() => setUiState(\'INPUT\')} />')],
            ['DRAFT_PRESERVED_AVATAR_CHANGE'],
            ['DRAFT_PRESERVED_ACL_CHANGE']),
        'input-frame-copy-wrong': (
            [(C, "  INPUT: { title: 'frame.F04.02.title', body: 'frame.F04.02.body' },",
              "  INPUT: { title: 'frame.F04.01.title', body: 'frame.F04.01.body' },")],
            ['FRAME_INPUT_idle'],
            ['FRAME_INPUT_working', 'FRAME_INPUT_unavailable']
            + [f'FRAME_LISTENING_{a}' for a in AVATARS]),
        'listening-exit-lost': (
            [(C, '    if (uiState === \'LISTENING\') setUiState(\'INPUT\');\n    onWrite?.();',
              '    onWrite?.();')],
            ['FRAME_LISTENING_idle'],
            ['FRAME_LISTENING_working', 'FRAME_LISTENING_unavailable']),
        'mock-constant-missions': (
            [(M, '  if (presence === \'EMPTY\') return [];',
              '  if (presence === \'EMPTY\') return [{ mission_id: MISSION_ID, state, updated_at: UPDATED_AT }];')],
            ['MOCK_SCENARIO_EMPTY_WORKING'],
            [f'MOCK_SCENARIO_EMPTY_{s}' for s in STATES if s != 'WORKING'] + ['MOCK_SCENARIO_SETTER', 'RUNTIME_LIST_EMPTY']),
        'runtime-list-unimplemented': (
            [(R, "const listMissions: ApiClient['listMissions'] = async () =>\n"
                 '  ({ items: missionsSnapshot().items }) as MissionPage;',
              "const listMissions: ApiClient['listMissions'] = async () => {\n"
                 "  throw new Error('LIST_NOT_IMPLEMENTED');\n};")],
            ['RUNTIME_LIST_EMPTY'],
            ['RUNTIME_LIST_PRESENT', 'RUNTIME_SNAPSHOT_FULL']),
    }
    bad = 0
    for name, (muts, named, depends) in MUTANTS.items():
        blobs = model_bytes(muts)
        cases = run_suite(repo, blobs)
        if cases is None:
            print('mutant', name, 'INFRASTRUCTURE')
            bad += 1
            continue
        red = {case_name(c) for c, s in cases.items() if s != 'passed'}
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
