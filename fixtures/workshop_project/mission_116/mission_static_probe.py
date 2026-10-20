#!/usr/bin/env python3
"""Статическая проба 116 (CMP-MOB-005): швы, копия и палитра по коду дерева.

Читает файлы продукта в R как текст; ожидания — литералы source.json
(снят с read-only docs/ ДО субъекта, Н-351): проба не импортирует модули
субъекта и не берёт значения из его файлов как оракул. Без --model:
до-предметное дерево — именованный отказ rc1 CONVERSATION_SEAM_ABSENT.
--matrix: побайтовые мутации статических швов; краснота вне объявления —
дефект rc2. Выход — код возврата.
"""
import argparse
from pathlib import Path
import re
import sys

from probe_lib import HERE, SCREEN_PATH, model_bytes

NAMED_RED = 'CONVERSATION_SEAM_ABSENT'

MOCK_PATH = 'mobile/src/mocks/conversation-mock.ts'
RUNTIME_PATH = 'mobile/src/mocks/runtime.ts'
API_PATH = 'mobile/src/api/api-client.ts'
COPY_PATH = 'mobile/src/i18n/ui-copy.ts'
COMPOSER_PATH = 'mobile/src/ui/conversation-composer/conversation-composer.tsx'

# Литералы оракула (source.json → copy), побайтово.
F05_COPY = {
    'frame.F05.01.title': ('Was ist passiert?', 'PRODUCT_COPY_REVIEW_REQUIRED'),
    'frame.F05.01.body': ('Beschreiben Sie, wobei Sie Unterstützung benötigen.', 'EDITORIAL_DRAFT_REVIEW_REQUIRED'),
    'frame.F05.02.title': ('Gesprächsverlauf', 'PRODUCT_COPY_REVIEW_REQUIRED'),
    'frame.F05.05.title': ('Antwort wird vorbereitet', 'EDITORIAL_DRAFT_REVIEW_REQUIRED'),
    'frame.F05.06.body': ('Öffnen Sie die Quelle, um die Grundlage dieser Aussage zu prüfen.', 'EDITORIAL_DRAFT_REVIEW_REQUIRED'),
    'frame.F05.07.body': ('Ihre Nachricht wurde noch nicht gesendet. Sie können sie weiterbearbeiten.', 'EDITORIAL_DRAFT_REVIEW_REQUIRED'),
    'action.F05.A01': ('Nachricht senden', 'PRODUCT_COPY_REVIEW_REQUIRED'),
    'action.F05.A02': ('Dokument hinzufügen', 'PRODUCT_COPY_REVIEW_REQUIRED'),
    'action.F05.A03': ('Neues Thema', 'PRODUCT_COPY_REVIEW_REQUIRED'),
}
# Ключи 108/999 в ui-copy на базе B (закрытый перечень ДО-предметных).
BASE_COPY_KEYS = [
    'ia115.nav.START', 'ia117.nav.VORGAENGE', 'ia115.nav.SCHUTZ', 'ia115.nav.POST',
    'frame.F04.01.title', 'frame.F04.01.body', 'frame.F04.02.title', 'frame.F04.02.body',
    'frame.F04.03.title', 'frame.F04.03.body', 'frame.F04.06.title', 'frame.F04.06.body',
    'frame.F04.07.title', 'frame.F04.07.body', 'action.F04.A01', 'action.F04.A02',
    'action.F04.A03', 'frame.F08.01.title', 'frame.F19.01.title', 'frame.F16.01.title',
    'action.F12.A01', 'global.back',
]
API_OPS = [
    '  listMessages(missionId: string): Promise<MessagePage>;',
    '  postMessage(message: ConversationMessage): Promise<PostMessageStatus>;',
    '  createUpload(missionId: string, fileName: string): Promise<UploadDescriptor>;',
    '  completeUpload(uploadId: string): Promise<UploadDescriptor>;',
    '  listDocuments(missionId: string): Promise<readonly DocumentRef[]>;',
    '  createIntent(topic: string): Promise<NewIntent>;',
]
MOCK_ENTRIES = [
    'const listMessages: ApiClient[\'listMessages\']',
    'const postMessage: ApiClient[\'postMessage\']',
    'const createUpload: ApiClient[\'createUpload\']',
    'const completeUpload: ApiClient[\'completeUpload\']',
    'const listDocuments: ApiClient[\'listDocuments\']',
    'const createIntent: ApiClient[\'createIntent\']',
]

# Привязка стаб↔ветвь живёт только здесь (Н-39); depends измерены прогоном.
MUTANTS = {
    # Обход: операция выпилена из шва (потребители молчат об отсутствующем).
    'api-seam-op-missing': (
        [(API_PATH, '  completeUpload(uploadId: string): Promise<UploadDescriptor>;\n', '')],
        ['API_SEAM_CONVERSATION_OPS'], [],
    ),
    # Обход: mock не реализует операцию (runtime без неё).
    'mock-op-missing': (
        [(RUNTIME_PATH, '  completeUpload,\n', '')],
        ['MOCK_CONVERSATION_OPS'], [],
    ),
    # Обход: формулировка F05.07 «переизобретена» (не байт-равна каталогу).
    'copy-f05-invented': (
        [(COPY_PATH,
          "  'frame.F05.07.body': { text: 'Ihre Nachricht wurde noch nicht gesendet. Sie können sie weiterbearbeiten.',",
          "  'frame.F05.07.body': { text: 'Ihre Nachricht wurde noch nicht gesendet.',")],
        ['COPY_F05_VERBATIM'], [],
    ),
    # Обход: вторая палитра — hex-литерал в экране беседы.
    'screen-hex-literal': (
        [(SCREEN_PATH, 'backgroundColor: tokens.ground', "backgroundColor: '#FF0000'")],
        ['SCREEN_THEME_TOKENS_ONLY'], [],
    ),
    # Обход: композер сломал поверхность 108 (дефолтный testID переименован).
    'composer-backcompat-broken': (
        [(COMPOSER_PATH, "  testID = 'start-composer',", "  testID = 'conv-composer',")],
        ['COMPOSER_BACKCOMPAT_108'], [],
    ),
}


def read(repo: Path, rel: str) -> str:
    return (repo / rel).read_text(encoding='utf-8')


def check_cells(repo: Path, blobs=None):
    """{cell: ok}; отсутствующие файлы — красные клетки, не крэш пробы."""
    def text(rel: str) -> str:
        if blobs and rel in blobs:
            return blobs[rel].decode('utf-8')
        try:
            return read(repo, rel)
        except FileNotFoundError:
            return ''

    cells = {}
    screen = text(SCREEN_PATH)
    mock = text(MOCK_PATH)
    api = text(API_PATH)
    copy_src = text(COPY_PATH)
    composer = text(COMPOSER_PATH)
    runtime = text(RUNTIME_PATH)

    cells['CONVERSATION_SEAM_PRESENT'] = bool(screen) and bool(mock)
    cells['API_SEAM_CONVERSATION_OPS'] = all(op in api for op in API_OPS)
    block_match = re.search(
        r'const mockApiClient: ApiClient = \{(.*?)\n\};', runtime, re.S)
    wired = block_match.group(1) if block_match else ''
    cells['MOCK_CONVERSATION_OPS'] = (
        all(e in runtime for e in MOCK_ENTRIES)
        and all(f'{name},' in wired for name in (
            'listMessages', 'postMessage', 'createUpload', 'completeUpload',
            'listDocuments', 'createIntent'))
    )

    verbatim = all(
        f"'{key}': {{ text: '{t}', review_status: '{rs}' }}" in copy_src
        for key, (t, rs) in F05_COPY.items()
    )
    present_keys = set(re.findall(r"^  '([a-zA-Z0-9_.]+)':", copy_src, re.M))
    additions = present_keys - set(BASE_COPY_KEYS)
    closed = additions <= set(F05_COPY)
    cells['COPY_F05_VERBATIM'] = verbatim and closed

    hex_re = re.compile(r"'#[0-9a-fA-F]{3,8}'")
    cells['SCREEN_THEME_TOKENS_ONLY'] = (
        screen != '' and composer != ''
        and not hex_re.search(screen) and not hex_re.search(composer)
    )

    cells['COMPOSER_BACKCOMPAT_108'] = all(m in composer for m in (
        'testID = \'start-composer\'',
        'value?: string',
        'onChangeText?: (next: string) => void',
        "uiCopyDe['frame.F04.07.title']",
        "uiCopyDe['frame.F04.07.body']",
        'testID="start-composer-input"',
    ))
    cells['COMPOSER_ACTIONS_WIRED'] = all(m in composer for m in (
        'testID="composer-send"', 'onPress={onSend}',
        'testID="composer-attach"', 'onPress={onAttach}',
        'testID="composer-new-topic"', 'onPress={onNewTopic}',
    ))
    own = Path(__file__).read_text(encoding='utf-8')
    # Игла собирается из частей, чтобы самопроверка не находила её в себе.
    import_needle = "'@" + "i18n"
    cells['STATIC_ORACLE_LITERALS'] = (
        all(t in own for _k, (t, _rs) in F05_COPY.items())
        and import_needle not in own
    )
    return cells


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
    cells = check_cells(repo, blobs)
    if not args.model and not any(cells.values()):
        print(NAMED_RED)
        return 1
    failed = sorted(name for name, ok in cells.items() if not ok)
    for name in sorted(cells):
        if cells[name]:
            print('case', name)
    if failed:
        for name in failed:
            print('RED', name)
        return 1
    print(f'honest {len(cells)}/{len(cells)}')
    return 0


def matrix(repo: Path):
    honest = check_cells(repo, model_bytes())
    if not all(honest.values()):
        print('MUTATION_MATRIX_HONEST_NOT_GREEN', sorted(n for n, ok in honest.items() if not ok))
        return 2
    ok = True
    for name, (mutations, named, depends) in MUTANTS.items():
        try:
            blobs = model_bytes(mutations)
        except RuntimeError as err:
            print('MUTANT_ANCHOR_BROKEN', name, err)
            ok = False
            continue
        cells = check_cells(repo, blobs)
        red = {n for n, v in cells.items() if not v}
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
