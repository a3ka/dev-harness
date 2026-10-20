#!/usr/bin/env python3
"""Поведенческая проба 116 (CMP-MOB-005): беседа в одной Mission.

Исполняет настоящий Jest/RNTL на disposable R и разбирает отчёт поимённо.
Без --model: до-предметное дерево — именованный отказ rc1
CONVERSATION_SEAM_ABSENT. С --model: эталон architect ставится по путям
поставки, rc0 с перечнем. --matrix: каждый обманный стаб даёт красноту на
объявленных ветвях (named ∪ depends); краснота вне объявления — дефект
матрицы rc2. Выход — только код возврата; список case печатается построчно.
"""
import argparse
from pathlib import Path
import sys

from probe_lib import (
    FAMILY_PREFIX, HERE, SCREEN_PATH, TEST_INSTALL,
    installed, jest_ready, model_bytes, run_jest,
)

NAMED_RED = 'CONVERSATION_SEAM_ABSENT'

# Привязка стаб↔ветвь живёт только здесь (Н-39): name → (mutations, named, depends).
# depends измерены полным прогоном до записи (см. §Фактический замер контракта).
MUTANTS = {
    # Обход: кнопка отправки не подключена к порту — порт молчит, ничего
    # не отправляется; красны все клетки, нажимающие composer-send.
    'send-not-wired': (
        [('mobile/src/ui/conversation-composer/conversation-composer.tsx',
          'onPress={onSend}', 'onPress={() => {}}')],
        ['SEND_SAME_MISSION_AND_DRAFT_CLEARED'],
        ['ALREADY_ACCEPTED_NO_DUPE', 'NEW_TOPIC_SEPARATE_INTENT', 'QUEUED_OFFLINE_DRAFT_KEPT'],
    ),
    # Обход: добавление вложения стирает текст черновика.
    'draft-cleared-on-attach': (
        [('mobile/src/features/conversation/conversation-screen.tsx',
          '    const picked = onAttach();\n    setAttachments((prev) => [',
          '    const picked = onAttach();\n    handleDraft(\'\');\n    setAttachments((prev) => [')],
        ['DRAFT_KEPT_ON_ATTACH'],
        ['CONTROLLED_DRAFT_PORT'],
    ),
    # Обход: черновик пережил принятую отправку и показывается снова.
    'draft-not-cleared-after-send': (
        [('mobile/src/features/conversation/conversation-screen.tsx',
          "sendState: 'sent' },\n      ]);\n      handleDraft('');",
          "sendState: 'sent' },\n      ]);")],
        ['SEND_SAME_MISSION_AND_DRAFT_CLEARED'], [],
    ),
    # Обход: already_accepted приписывает дубль сообщения.
    'already-accepted-appends-dupe': (
        [('mobile/src/features/conversation/conversation-screen.tsx',
          '      // Сообщение уже на сервере (повтор того же client_message_id):\n'
          '      // дубль НЕ создаётся; черновик больше не нужен.\n'
          "      handleDraft('');",
          '      setLocalTurns((prev) => [\n'
          '        ...prev,\n'
          "        { key: `dupe-${clientMessageSeq}`, role: 'user', text: draft, sendState: 'already_accepted' },\n"
          '      ]);\n'
          "      handleDraft('');")],
        ['ALREADY_ACCEPTED_NO_DUPE'], [],
    ),
    # Обход: выбранный файл сразу назван доставленным (pending скрыт).
    'attach-state-uploaded': (
        [('mobile/src/features/conversation/conversation-screen.tsx',
          "state: 'attachment_pending' },\n    ]);",
          "state: 'uploaded' },\n    ]);")],
        ['ATTACH_PENDING_NOT_READ'],
        ['UPLOAD_GATE_AND_RETRY_NO_DUPE'],
    ),
    # Обход: interrupted показан завершённым ответом.
    'interrupted-shown-completed': (
        [('mobile/src/features/conversation/conversation-screen.tsx',
          '<Text testID="response-state-token" style={{ color: tokens.ink }}>\n              interrupted\n            </Text>',
          '<Text testID="response-state-token" style={{ color: tokens.ink }}>\n              completed\n            </Text>')],
        ['INTERRUPTED_NOT_COMPLETED'], [],
    ),
    # Обход: офлайн-отказ стирает черновик (потеря на пути ошибки отправки).
    'offline-clears-draft': (
        [('mobile/src/features/conversation/conversation-screen.tsx',
          '      // F05.07: черновик СОХРАНЁН и не назван доставленным.\n      setDraftUndelivered(true);',
          "      // F05.07: черновик СОХРАНЁН и не назван доставленным.\n      setDraftUndelivered(true);\n      handleDraft('');")],
        ['QUEUED_OFFLINE_DRAFT_KEPT'], [],
    ),
    # Обход: нет сети — уведомление F05.07 не показано (молчаливая потеря).
    'offline-no-notice': (
        [('mobile/src/features/conversation/conversation-screen.tsx',
          "        {draftUndelivered ? uiCopyDe['frame.F05.07.body'].text : ''}",
          "        {draftUndelivered ? '' : ''}")],
        ['QUEUED_OFFLINE_DRAFT_KEPT'], [],
    ),
    # Обход: повтор загрузки создаёт второе вложение (дубль).
    'retry-upload-dupes': (
        [('mobile/src/features/conversation/conversation-screen.tsx',
          '        setAttachments((prev) =>\n'
          "          prev.map((a) => (a.attachmentId === attachmentId ? { ...a, state: 'uploaded' } : a)),\n"
          '        );',
          "        setAttachments((prev) => [...prev, { attachmentId, name: 'duplikat.pdf', state: 'uploaded' }]);")],
        ['UPLOAD_GATE_AND_RETRY_NO_DUPE'], ['ATTACH_PENDING_NOT_READ'],
    ),
    # Обход: новая тема остаётся в той же Mission (intent не отдельный).
    'new-topic-same-mission': (
        [('mobile/src/features/conversation/conversation-screen.tsx',
          '    setMission(nextMission);', '    setMission(mission);')],
        ['NEW_TOPIC_SEPARATE_INTENT'], [],
    ),
    # Обход: новая тема переносит приватный контекст старой Mission.
    'new-topic-keeps-transcript': (
        [('mobile/src/features/conversation/conversation-screen.tsx',
          '    setLocalTurns([]);', '    // setLocalTurns([]); // обход: контекст перенесён')],
        ['NEW_TOPIC_SEPARATE_INTENT'], [],
    ),
    # Обход: отозванный источник открывается из старого exchange.
    'revoked-source-open': (
        [('mobile/src/features/conversation/conversation-screen.tsx',
          "                {turn.sourceState !== 'revoked' ? (",
          "                {turn.sourceState !== 'revoked-x' ? (")],
        ['REVOKED_SOURCE_CLOSED'], [],
    ),
    # Обход: контролируемый порт черновика игнорируется (хранится, но
    # не восстанавливается после ремоунта слота).
    'controlled-draft-ignored': (
        [('mobile/src/features/conversation/conversation-screen.tsx',
          '  const controlled = draftValue !== undefined && draftOnChange !== undefined;',
          '  const controlled = false;')],
        ['CONTROLLED_DRAFT_PORT'], [],
    ),
    # Обход: идентичность Mission на поверхности подменена литералом.
    'mission-chip-hardcoded': (
        [('mobile/src/features/conversation/conversation-screen.tsx',
          '          {mission}\n        </Text>', "          {'MIS-OTHER'}\n        </Text>")],
        ['CONVERSATION_STRUCTURE_DARK', 'CONVERSATION_STRUCTURE_LIGHT'],
        ['SEND_SAME_MISSION_AND_DRAFT_CLEARED', 'NEW_TOPIC_SEPARATE_INTENT'],
    ),
}


def case_name(title: str) -> str:
    name = title[len(FAMILY_PREFIX):] if title.startswith(FAMILY_PREFIX) else title
    return name.split(' \u2014 ')[0]


def run_suite(repo: Path, blobs=None):
    mobile = repo / 'mobile'
    if not jest_ready(mobile):
        print('INFRASTRUCTURE: jest не установлен в R/mobile')
        return None
    files = {repo / TEST_INSTALL: (HERE / 'mission.test.tsx').read_bytes()}
    if blobs:
        for rel, blob in blobs.items():
            files[repo / rel] = blob
    with installed(files):
        cases, proc = run_jest(mobile, repo / TEST_INSTALL)
    if not cases and proc.returncode != 0:
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
    if not args.model and not (repo / SCREEN_PATH).exists():
        print(NAMED_RED)
        return 1
    cases = run_suite(repo, blobs)
    if cases is None:
        return 2
    if cases == {}:
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
    ok = True
    for name, (mutations, named, depends) in MUTANTS.items():
        try:
            blobs = model_bytes(mutations)
        except RuntimeError as err:
            print('MUTANT_ANCHOR_BROKEN', name, err)
            ok = False
            continue
        cases = run_suite(repo, blobs)
        if cases is None:
            print('MUTANT_INFRASTRUCTURE', name)
            ok = False
            continue
        red = {case_name(c) for c, s in cases.items() if s != 'passed'}
        expected = set(named) | set(depends)
        if not red:
            print('MUTANT_GREEN', name)
            ok = False
        elif not (set(named) & red):
            print('MUTANT_NAMED_MISS', name, sorted(red))
            ok = False
        elif not red <= expected:
            print('MUTANT_UNEXPECTED_RED', name, sorted(red - expected))
            ok = False
        else:
            print('mutant', name, 'red=', sorted(red))
    return 0 if ok else 2


if __name__ == '__main__':
    sys.exit(main())
