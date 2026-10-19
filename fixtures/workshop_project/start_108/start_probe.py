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
    # Привязка стаб↔ветвь живёт только здесь (Н-39): name → (mutations, named, depends).
    # depends — ИЗМЕРЕННЫЙ полным прогоном red-набор мутанта без named клетки
    # (матрица отвергает любую красноту вне named ∪ depends).
    C = 'mobile/src/features/start/start-screen.tsx'
    M = 'mobile/src/mocks/start-mock.ts'
    R = 'mobile/src/mocks/runtime.ts'
    P = 'mobile/src/ui/agent-presence/agent-presence.tsx'
    AVATARS = ['idle', 'working', 'unavailable']
    PRESENCES = ['EMPTY', 'PRESENT']
    MOTIONS = ['full', 'reduced']
    ACTIONS = ['WRITE', 'TALK', 'RESUME']
    UI_STATES = ['CALM', 'INPUT', 'LISTENING']
    ADMISSIONS = ['EMPTY', 'PRESENT', 'NULL']
    STATES = ['RECEIVED', 'WORKING', 'NEEDS_INFORMATION', 'ADVISER_REVIEW',
              'NEEDS_APPROVAL', 'WAITING_EXTERNAL', 'COMPLETED', 'PARTIAL',
              'BLOCKED', 'CANCELLED']

    def cells(prefix, avatars=AVATARS, presences=PRESENCES, motions=MOTIONS):
        return [f'{prefix}_{a}_{p}_{m}' for a in avatars for p in presences for m in motions]

    def af(uis=UI_STATES, actions=ACTIONS, adms=ADMISSIONS):
        return [f'ACTION_FROM_{u}_{a}_{d}' for u in uis for a in actions for d in adms]

    def sa(uis=('INPUT', 'LISTENING'), avatars=AVATARS, presences=PRESENCES, motions=MOTIONS):
        return [f'STRUCTURE_AFTER_{u}_{a}_{p}_{m}'
                for u in uis for a in avatars for p in presences for m in motions]

    def sr(diagonal=False):
        # Полный квадрат 10×10 (арбитраж 108, Решение 2 A): диагональ —
        # клетки from===to; мутанты удержания снимка красны только вне её.
        return [f'SNAPSHOT_REFRESH_{f}_{t}'
                for f in STATES for t in STATES if (f == t) == diagonal]

    def da():
        return [f'DRAFT_AVATAR_{a}_TO_{b}' for a in AVATARS for b in AVATARS if a != b]

    def scen(prefix, presences=PRESENCES):
        return [f'{prefix}_{p}_{s}' for p in presences for s in STATES]

    def al(uis=UI_STATES, tos=('EMPTY', 'NULL'), avatars=AVATARS):
        return [f'ADMISSION_LOST_{u}_{t}_{a}' for u in uis for t in tos for a in avatars]

    def bf():
        return [f'BRIEF_FIELDS_{i}_{s}_{t}'
                for i in ('FIXED', 'ALT') for s in ('FIXED', 'ALT') for t in ('FIXED', 'ALT')]

    COMPOSER_ANCHOR = '<ConversationComposer onFocusInput={() => setUiState(\'INPUT\')} />'

    MUTANTS = {
        # --- 18 исходных стабов (круг 1; depends перемерены на перечне
        #     арбитража 108: 324 клетки, семьи ADMISSION_LOST/BRIEF_FIELDS) ---
        'empty-start-groups-list': (
            [(C, f'      {COMPOSER_ANCHOR}\n',
              f'      {COMPOSER_ANCHOR}\n'
              '      {(missions ?? []).length === 0 ? (\n'
              '        <View testID="start-empty-groups">\n'
              '          <Text style={[styles.body, { color: tokens.ink }]}>Keine Vorgaenge</Text>\n'
              '        </View>\n'
              '      ) : null}\n')],
            ['STRUCTURE_idle_EMPTY_full'],
            [c for c in cells('STRUCTURE', presences=['EMPTY']) if c != 'STRUCTURE_idle_EMPTY_full']
            + sa(presences=['EMPTY'])),
        'kpi-dashboard': (
            [(C, '      {/* F04.V01: не более одной контекстной карточки — только resume-brief. */}\n',
              '      {/* F04.V01: не более одной контекстной карточки — только resume-brief. */}\n'
              '      {(missions ?? []).length > 0 ? (\n'
              '        <View testID="start-kpi-dashboard" style={[styles.card, { backgroundColor: tokens.card, borderColor: tokens.panel }]}>\n'
              '          <Text style={[styles.mono, { color: tokens[\'on-card\'] }]}>KPI 3/5</Text>\n'
              '        </View>\n'
              '      ) : null}\n')],
            ['STRUCTURE_idle_PRESENT_full'],
            [c for c in cells('STRUCTURE', presences=['PRESENT']) if c != 'STRUCTURE_idle_PRESENT_full']
            + sa(presences=['PRESENT'])),
        'presence-replaced-by-list': (
            [(C, '      <AgentPresence state={avatarState} />',
              '      {missions === null ? <AgentPresence state={avatarState} /> : null}')],
            ['STRUCTURE_idle_EMPTY_full'],
            [c for c in cells('STRUCTURE') if c != 'STRUCTURE_idle_EMPTY_full']
            + sa()
            + al(tos=['EMPTY'])),
        'composer-duplicated': (
            [(C, f'      {COMPOSER_ANCHOR}\n', f'      {COMPOSER_ANCHOR}\n      {COMPOSER_ANCHOR}\n')],
            ['STRUCTURE_idle_EMPTY_full'],
            [c for c in cells('STRUCTURE') if c != 'STRUCTURE_idle_EMPTY_full']
            + sa()
            + [f'MISSIONS_NULL_{a}' for a in AVATARS]
            + al()
            + af(uis=['INPUT'])
            + ['DRAFT_PRESERVED_AVATAR_CHANGE', 'DRAFT_PRESERVED_ACL_CHANGE',
               'DRAFT_PRESERVED_LISTENING_ROUNDTRIP']
            + da() + ['DRAFT_ADMISSION_EMPTY', 'DRAFT_ADMISSION_NULL']
            + [f'FRAME_INPUT_{a}' for a in AVATARS]),
        'resume-without-mission': (
            [(C, '  const continuable = available.length > 0 ? available[0] : null;',
              '  const continuable =\n'
              '    available[0] ??\n'
              "    ({ mission_id: 'MIS-CAR-01', state: 'WORKING' as const, updated_at: '2026-10-09T12:00:00Z' });")],
            ['ACTION_RESUME_idle_EMPTY_full'],
            af(adms=['EMPTY', 'NULL'])
            + [c for c in cells('ACTION_RESUME', presences=['EMPTY']) if c != 'ACTION_RESUME_idle_EMPTY_full']
            + cells('ACTION_TALK', presences=['EMPTY'])
            + cells('ACTION_WRITE', presences=['EMPTY'])
            + al()
            + ['DRAFT_ADMISSION_EMPTY', 'DRAFT_ADMISSION_NULL', 'DRAFT_PRESERVED_ACL_CHANGE']
            + [f'MISSIONS_NULL_{a}' for a in AVATARS]
            + scen('RUNTIME_SCENARIO', presences=['EMPTY'])
            + cells('STRUCTURE', presences=['EMPTY'])
            + sa(presences=['EMPTY'])),
        'revoked-stale-brief': (
            [(C, "import React, { useState } from 'react';",
              "import React, { useRef, useState } from 'react';"),
             (C, '  const available = missions ?? [];',
              '  const availableRef = useRef<readonly MissionBrief[] | null>(null);\n'
              '  if (missions && missions.length > 0) availableRef.current = missions;\n'
              '  const available = missions && missions.length > 0 ? missions : (availableRef.current ?? []);')],
            ['ADMISSION_LOST_CALM_EMPTY_idle'],
            [c for c in al() if c != 'ADMISSION_LOST_CALM_EMPTY_idle']
            + ['DRAFT_ADMISSION_EMPTY', 'DRAFT_ADMISSION_NULL', 'DRAFT_PRESERVED_ACL_CHANGE']),
        'talk-starts-mic': (
            [(C, "    setUiState('LISTENING');\n    onTalk?.();",
              "    setUiState('LISTENING');\n    onTalk?.();\n    onMicrophoneRequested?.();")],
            ['ACTION_TALK_idle_PRESENT_full'],
            [c for c in cells('ACTION_TALK') if c != 'ACTION_TALK_idle_PRESENT_full']
            + af(actions=['TALK'])
            + af(uis=['LISTENING'])
            + sa(uis=['LISTENING'])
            + al(uis=['LISTENING'])
            + [f'FRAME_LISTENING_{a}' for a in AVATARS]
            + ['DRAFT_PRESERVED_LISTENING_ROUNDTRIP']),
        'talk-creates-mission': (
            [(C, "    setUiState('LISTENING');\n    onTalk?.();",
              "    setUiState('LISTENING');\n    onTalk?.();\n    onResume?.('MIS-CAR-01');")],
            ['ACTION_TALK_idle_EMPTY_full'],
            [c for c in cells('ACTION_TALK') if c != 'ACTION_TALK_idle_EMPTY_full']
            + af(actions=['TALK'])
            + af(uis=['LISTENING'])
            + sa(uis=['LISTENING'])
            + al(uis=['LISTENING'])
            + [f'FRAME_LISTENING_{a}' for a in AVATARS]
            + ['DRAFT_PRESERVED_LISTENING_ROUNDTRIP']),
        'write-side-nav': (
            [(C, "    if (uiState === 'LISTENING') setUiState('INPUT');\n    onWrite?.();",
              "    if (uiState === 'LISTENING') setUiState('INPUT');\n    onWrite?.();\n    onTalk?.();")],
            ['ACTION_WRITE_idle_EMPTY_full'],
            [c for c in cells('ACTION_WRITE') if c != 'ACTION_WRITE_idle_EMPTY_full']
            + af(actions=['WRITE'])
            + [f'FRAME_LISTENING_{a}' for a in AVATARS]
            + ['DRAFT_PRESERVED_LISTENING_ROUNDTRIP']),
        'resume-loses-id': (
            [(C, '    if (continuable) onResume?.(continuable.mission_id);',
              "    if (continuable) onResume?.('');")],
            ['ACTION_RESUME_idle_PRESENT_full'],
            [c for c in cells('ACTION_RESUME', presences=['PRESENT']) if c != 'ACTION_RESUME_idle_PRESENT_full']
            + af(actions=['RESUME'], adms=['PRESENT'])
            + [f'RESUME_EFFECT_{s}_{m}' for s in STATES for m in MOTIONS]
            + bf()),
        'unavailable-hides-composer': (
            [(C, f'      {COMPOSER_ANCHOR}',
              '      {avatarState === \'unavailable\' ? null : '
              f'{COMPOSER_ANCHOR}}}')],
            ['STRUCTURE_unavailable_EMPTY_full'],
            ['STRUCTURE_unavailable_EMPTY_reduced', 'STRUCTURE_unavailable_PRESENT_full',
             'STRUCTURE_unavailable_PRESENT_reduced', 'MISSIONS_NULL_unavailable']
            + al(avatars=['unavailable'])
            + ['FRAME_INPUT_unavailable']
            + sa(avatars=['unavailable'])
            + [c for c in da() if 'unavailable' in c]),
        'unavailable-looks-working': (
            [(P, '      <View testID={`start-avatar-${state}`} style={[styles.avatar, { borderColor: tokens.ink }]} />',
              '      <View testID="start-avatar-working" style={[styles.avatar, { borderColor: tokens.ink }]} />')],
            ['STRUCTURE_unavailable_EMPTY_full'],
            ['STRUCTURE_unavailable_EMPTY_reduced', 'STRUCTURE_unavailable_PRESENT_full',
             'STRUCTURE_unavailable_PRESENT_reduced',
             'STRUCTURE_idle_EMPTY_full', 'STRUCTURE_idle_EMPTY_reduced',
             'STRUCTURE_idle_PRESENT_full', 'STRUCTURE_idle_PRESENT_reduced']
            + sa(avatars=['idle', 'unavailable'])),
        'reduced-motion-drops-brief': (
            [(C, '      {continuable ? (',
              '      {(continuable && !reducedMotion) ? (')],
            ['STRUCTURE_idle_PRESENT_reduced'],
            ['STRUCTURE_working_PRESENT_reduced', 'STRUCTURE_unavailable_PRESENT_reduced']
            + cells('ACTION_WRITE', presences=['PRESENT'], motions=['reduced'])
            + cells('ACTION_TALK', presences=['PRESENT'], motions=['reduced'])
            + cells('ACTION_RESUME', presences=['PRESENT'], motions=['reduced'])
            + [f'RESUME_EFFECT_{s}_reduced' for s in STATES]
            + sa(motions=['reduced'], presences=['PRESENT'])),
        'draft-lost-on-rerender': (
            [(C, f'      {COMPOSER_ANCHOR}',
              f"      <ConversationComposer key={{avatarState + String(missions === null ? 'n' : missions.length)}} "
              "onFocusInput={() => setUiState('INPUT')} />")],
            ['DRAFT_PRESERVED_AVATAR_CHANGE'],
            ['DRAFT_PRESERVED_ACL_CHANGE']
            + da() + ['DRAFT_ADMISSION_EMPTY', 'DRAFT_ADMISSION_NULL']),
        'input-frame-copy-wrong': (
            [(C, "  INPUT: { title: 'frame.F04.02.title', body: 'frame.F04.02.body' },",
              "  INPUT: { title: 'frame.F04.01.title', body: 'frame.F04.01.body' },")],
            ['FRAME_INPUT_idle'],
            ['FRAME_INPUT_working', 'FRAME_INPUT_unavailable']),
        'listening-exit-lost': (
            [(C, "    if (uiState === 'LISTENING') setUiState('INPUT');\n    onWrite?.();",
              '    onWrite?.();')],
            ['FRAME_LISTENING_idle'],
            ['FRAME_LISTENING_working', 'FRAME_LISTENING_unavailable']),
        'mock-constant-missions': (
            [(M, '  if (presence === \'EMPTY\') return [];',
              "  if (presence === 'EMPTY') return [{ mission_id: MISSION_ID, state, updated_at: UPDATED_AT }];")],
            ['MOCK_SCENARIO_EMPTY_WORKING'],
            [c for c in scen('MOCK_SCENARIO', presences=['EMPTY']) if c != 'MOCK_SCENARIO_EMPTY_WORKING']
            + ['MOCK_SCENARIO_SETTER', 'RUNTIME_LIST_EMPTY']
            + scen('RUNTIME_SCENARIO', presences=['EMPTY'])),
        'runtime-list-unimplemented': (
            [(R, "const listMissions: ApiClient['listMissions'] = async () =>\n"
                 '  ({ items: missionsSnapshot().items }) as MissionPage;',
              "const listMissions: ApiClient['listMissions'] = async () => {\n"
                 "  throw new Error('LIST_NOT_IMPLEMENTED');\n};")],
            ['RUNTIME_LIST_EMPTY'],
            ['RUNTIME_LIST_PRESENT', 'RUNTIME_SNAPSHOT_FULL'] + scen('RUNTIME_SCENARIO')),
        # --- 14 стабов круга 1 критика (оси 1–9), depends перемерены ---
        'oracle-imported-constants': (
            [(M, "export const MISSION_ID = 'MIS-CAR-01';", "export const MISSION_ID = 'MIS-WRONG-99';"),
             (M, "export const UPDATED_AT = '2026-10-09T12:00:00Z';",
              "export const UPDATED_AT = '1999-01-01T00:00:00Z';")],
            ['MOCK_SCENARIO_PRESENT_WORKING'],
            [c for c in scen('MOCK_SCENARIO', presences=['PRESENT']) if c != 'MOCK_SCENARIO_PRESENT_WORKING']
            + ['MOCK_SCENARIO_SETTER', 'RUNTIME_LIST_PRESENT', 'RUNTIME_SNAPSHOT_FULL']
            + scen('RUNTIME_SCENARIO', presences=['PRESENT'])),
        'write-after-listening-mic': (
            [(C, '    onWrite?.();',
              "    onWrite?.();\n    if (uiState === 'LISTENING') onMicrophoneRequested?.();")],
            ['ACTION_FROM_LISTENING_WRITE_PRESENT'],
            ['ACTION_FROM_LISTENING_WRITE_EMPTY', 'ACTION_FROM_LISTENING_WRITE_NULL']
            + [f'FRAME_LISTENING_{a}' for a in AVATARS]
            + ['DRAFT_PRESERVED_LISTENING_ROUNDTRIP']),
        'focus-then-talk-mic': (
            [(C, '    onTalk?.();',
              "    onTalk?.();\n    if (uiState === 'INPUT') onMicrophoneRequested?.();")],
            ['ACTION_FROM_INPUT_TALK_PRESENT'],
            ['ACTION_FROM_INPUT_TALK_EMPTY', 'ACTION_FROM_INPUT_TALK_NULL']),
        'null-talk-mic': (
            [(C, '    onTalk?.();',
              "    onTalk?.();\n    if (missions === null) onMicrophoneRequested?.();")],
            ['ACTION_FROM_CALM_TALK_NULL'],
            ['ACTION_FROM_INPUT_TALK_NULL', 'ACTION_FROM_LISTENING_TALK_NULL',
             'ACTION_FROM_LISTENING_WRITE_NULL', 'ACTION_FROM_LISTENING_RESUME_NULL']),
        'blocked-reduced-resume': (
            [(C, '    if (continuable) onResume?.(continuable.mission_id);',
              "    if (continuable) onResume?.(reducedMotion && continuable.state === 'BLOCKED' "
              "? 'MIS-WRONG-99' : continuable.mission_id);")],
            ['RESUME_EFFECT_BLOCKED_reduced'],
            []),
        'listening-revoked-acl': (
            [(C, "import React, { useState } from 'react';",
              "import React, { useState, useRef } from 'react';"),
             (C, '  const available = missions ?? [];',
              '  const previous = useRef(missions);\n'
              '  if (uiState !== \'LISTENING\' || (missions && missions.length)) previous.current = missions;\n'
              "  const available = (uiState === 'LISTENING' ? previous.current : missions) ?? [];")],
            ['ADMISSION_LOST_LISTENING_EMPTY_idle'],
            [c for c in al(uis=['LISTENING']) if c != 'ADMISSION_LOST_LISTENING_EMPTY_idle']),
        'null-transition-stale': (
            [(C, "import React, { useState } from 'react';",
              "import React, { useState, useRef } from 'react';"),
             (C, '  const available = missions ?? [];',
              '  const last = useRef<readonly MissionBrief[]>([]);\n'
              '  if (missions !== null) last.current = missions;\n'
              '  const available = missions ?? last.current;')],
            ['ADMISSION_LOST_CALM_NULL_idle'],
            [c for c in al(tos=['NULL']) if c != 'ADMISSION_LOST_CALM_NULL_idle']
            + ['DRAFT_ADMISSION_NULL']),
        'same-presence-stale-snapshot': (
            [(C, "import React, { useState } from 'react';",
              "import React, { useState, useMemo } from 'react';"),
             (C, '  const available = missions ?? [];',
              "  const available = useMemo(() => missions ?? [], [missions?.length]);")],
            ['SNAPSHOT_REFRESH_WORKING_BLOCKED'],
            [c for c in sr() if c != 'SNAPSHOT_REFRESH_WORKING_BLOCKED']),
        'listening-presence-gone': (
            [(C, '      <AgentPresence state={avatarState} />',
              "      {uiState !== 'LISTENING' ? <AgentPresence state={avatarState} /> : null}")],
            ['STRUCTURE_AFTER_LISTENING_idle_EMPTY_full'],
            [c for c in sa(uis=['LISTENING']) if c != 'STRUCTURE_AFTER_LISTENING_idle_EMPTY_full']
            + al(uis=['LISTENING'])),
        'listening-kpi-groups': (
            [(C, '      <AgentPresence state={avatarState} />',
              '      <AgentPresence state={avatarState} />\n'
              '      {uiState === \'LISTENING\' ? <View><View testID="start-kpi-dashboard">'
              '<Text>KPI 3/5</Text></View><View testID="start-empty-groups">'
              '<Text>Keine Vorgaenge</Text></View></View> : null}')],
            ['STRUCTURE_AFTER_LISTENING_idle_EMPTY_full'],
            [c for c in sa(uis=['LISTENING']) if c != 'STRUCTURE_AFTER_LISTENING_idle_EMPTY_full']),
        'brief-hardcoded-fields': (
            [(C, '{continuable.mission_id}', "{'MIS-CAR-01'}"),
             (C, '{continuable.updated_at}', "{'2026-10-09T12:00:00Z'}")],
            ['BRIEF_FIELDS_ALT_ALT_ALT'],
            [c for c in bf() if c not in ('BRIEF_FIELDS_ALT_ALT_ALT', 'BRIEF_FIELDS_FIXED_FIXED_FIXED',
                                          'BRIEF_FIELDS_FIXED_ALT_FIXED')]),
        'runtime-blocked-normalized': (
            [(R, '({ items: missionsSnapshot().items }) as MissionPage;',
              "({ items: missionsSnapshot().items.map(m => ({ ...m, state: m.state === 'BLOCKED' "
              "? 'WORKING' : m.state })) }) as MissionPage;")],
            ['RUNTIME_SCENARIO_PRESENT_BLOCKED'],
            []),
        'draft-unavailable-reset': (
            [(C, "<ConversationComposer onFocusInput={() => setUiState('INPUT')} />",
              "<ConversationComposer key={avatarState === 'unavailable' ? 'reset' : 'normal'} "
              "onFocusInput={() => setUiState('INPUT')} />")],
            ['DRAFT_AVATAR_idle_TO_unavailable'],
            ['DRAFT_AVATAR_working_TO_unavailable', 'DRAFT_AVATAR_unavailable_TO_idle',
             'DRAFT_AVATAR_unavailable_TO_working']),
        'brief-body-empty': (
            [(C, "{uiCopyDe['frame.F04.06.body'].text}", "{''}")],
            ['BRIEF_STATE_WORKING'],
            [f'BRIEF_STATE_{s}' for s in STATES if s != 'WORKING']),
        # --- 4 декоя круга 3 (арбитраж 108, П5): мутации байт-в-байт из
        #     Critic108r2/evidence/*.patch (= Arbiter108/measure.py MUTANTS);
        #     named/depends измерены полным прогоном на перечне 324 ---
        'snapshot-transition-microphone': (
            [(C, "import React, { useState } from 'react';",
              "import React, { useState, useRef, useEffect } from 'react';"),
             (C, '  const available = missions ?? [];',
              '  const previous = useRef(missions?.[0]?.state);\n'
              '  useEffect(() => {\n'
              '    if (previous.current && missions?.[0]?.state && previous.current !== missions[0].state) '
              'onMicrophoneRequested?.();\n'
              '    previous.current = missions?.[0]?.state;\n'
              '  }, [missions, onMicrophoneRequested]);\n'
              '  const available = missions ?? [];')],
            ['SNAPSHOT_REFRESH_WORKING_BLOCKED'],
            [c for c in sr() if c != 'SNAPSHOT_REFRESH_WORKING_BLOCKED']),
        'acl-transition-navigation': (
            [(C, "import React, { useState } from 'react';",
              "import React, { useState, useRef, useEffect } from 'react';"),
             (C, '  const available = missions ?? [];',
              '  const previous = useRef(missions);\n'
              '  useEffect(() => {\n'
              '    if (previous.current?.length && !missions?.length) onTalk?.();\n'
              '    previous.current = missions;\n'
              '  }, [missions, onTalk]);\n'
              '  const available = missions ?? [];')],
            ['ADMISSION_LOST_CALM_EMPTY_idle'],
            [c for c in al() if c != 'ADMISSION_LOST_CALM_EMPTY_idle']
            + ['DRAFT_ADMISSION_EMPTY', 'DRAFT_ADMISSION_NULL', 'DRAFT_PRESERVED_ACL_CHANGE']),
        'runtime-screen-timestamp-omitted': (
            [(C, '{continuable.updated_at}', "{onResume ? continuable.updated_at : ''}")],
            ['RUNTIME_SCENARIO_PRESENT_WORKING'],
            [c for c in scen('RUNTIME_SCENARIO', presences=['PRESENT']) if c != 'RUNTIME_SCENARIO_PRESENT_WORKING']
            + ['RUNTIME_SNAPSHOT_FULL']),
        'brief-timestamp-derived-from-id': (
            [(C, '{continuable.updated_at}',
              "{continuable.mission_id === 'MIS-OTHER-02' ? '2026-10-19T10:11:12Z' : '2026-10-09T12:00:00Z'}")],
            ['BRIEF_FIELDS_FIXED_FIXED_ALT'],
            ['BRIEF_FIELDS_ALT_ALT_FIXED', 'BRIEF_FIELDS_ALT_FIXED_FIXED', 'BRIEF_FIELDS_FIXED_ALT_ALT']),
        # --- 3 декоя круга 3 (ось D критика: alias-мутация входного снимка
        #     ПРОДУКТОМ — Object.assign входа до available; ожидания теста —
        #     литералы EXPECT, не объект входа): патчи байт-в-байт из
        #     Critic108r3/evidence/input-alias-*.patch; depends измерены
        #     полным прогоном до записи ---
        'input-alias-mission_id': (
            [(C, '  const available = missions ?? [];',
              "  if (missions?.[0]?.mission_id === 'MIS-OTHER-02') "
              "Object.assign(missions[0], {mission_id: 'MIS-WRONG-99'});\n"
              '  const available = missions ?? [];')],
            ['BRIEF_FIELDS_ALT_ALT_ALT'],
            ['BRIEF_FIELDS_ALT_ALT_FIXED', 'BRIEF_FIELDS_ALT_FIXED_ALT', 'BRIEF_FIELDS_ALT_FIXED_FIXED']),
        'input-alias-state': (
            [(C, '  const available = missions ?? [];',
              "  if (missions?.[0]?.mission_id === 'MIS-OTHER-02') "
              "Object.assign(missions[0], {state: 'BLOCKED'});\n"
              '  const available = missions ?? [];')],
            ['BRIEF_FIELDS_ALT_ALT_ALT'],
            ['BRIEF_FIELDS_ALT_ALT_FIXED', 'BRIEF_FIELDS_ALT_FIXED_ALT', 'BRIEF_FIELDS_ALT_FIXED_FIXED']),
        'input-alias-updated_at': (
            [(C, '  const available = missions ?? [];',
              "  if (missions?.[0]?.mission_id === 'MIS-OTHER-02') "
              "Object.assign(missions[0], {updated_at: '1999-01-01T00:00:00Z'});\n"
              '  const available = missions ?? [];')],
            ['BRIEF_FIELDS_ALT_ALT_ALT'],
            ['BRIEF_FIELDS_ALT_ALT_FIXED', 'BRIEF_FIELDS_ALT_FIXED_ALT', 'BRIEF_FIELDS_ALT_FIXED_FIXED']),
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
