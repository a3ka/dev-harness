#!/usr/bin/env python3
"""027 public-seam probes; no implementation of the checker.
Н-39 bindings: always-green dies on every negative; always-red on controls;
headings-only -> obligations/missing; product-only -> architecture/dangling;
exists-only -> evidence/drift; rc-only -> assertions/value; rc2-green -> unavailable;
status-blind -> proposal; renderer-noop -> manual; disk-oracle -> rewrite.
Before the new CLI exists, the REAL old readiness gate is the subject: it
accepts typed contracts but ignores the obligations. This is not a fake checker.
"""
import copy
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

REPO = Path(__file__).resolve().parents[2]
CASE = sys.argv[1]
ENV = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
ENV.update(GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null')


def fail(label, text):
    print(f'ОТКАЗ DOC-{CASE}/{label}: {text}', file=sys.stderr)
    raise SystemExit(1)


def run(args, root):
    return subprocess.run([str(x) for x in args], cwd=root, env=ENV,
                          text=True, capture_output=True)


def git(root, *args, author='architect'):
    p = run(['git', '-c', f'user.name={author}', '-c', f'user.email={author}@fixture.local',
             '-c', 'commit.gpgsign=false', '-c', 'core.hooksPath=/dev/null', *args], root)
    if p.returncode:
        fail('fixture-git', p.stderr)
    return p.stdout.strip()


def put(root, path, text):
    p = root / path
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(text, encoding='utf-8')


def dump(value):
    return json.dumps(value, ensure_ascii=False, indent=2) + '\n'


def save(root, spec, package):
    text = ('# Договор Ёж\n\nЗОНА implementer: docs/\nЗОНА architect: contracts/ fixtures/\n\n'
            '## Док-приёмка\n\n```json\n' + dump(spec) + '```\n')
    put(root, 'contracts/001-yozh.md', text)
    put(root, 'contract.md', text)
    put(root, 'docs/ёж.evidence.json', dump(package))


def commit(root, message, author='architect'):
    git(root, 'add', '-A')
    git(root, 'commit', '-qm', message, author=author)


def toy(root):
    root.mkdir()
    git(root, 'init', '-q', '-b', 'main')
    git(root, 'config', 'user.name', 'architect')
    git(root, 'config', 'user.email', 'architect@fixture.local')
    put(root, 'данные/ёлка.json', dump({'число': 7}))
    put(root, 'решения/Ёж.md', '# Ёж\nРешение принято для игрушки.\n')
    put(root, 'fixtures/probe.py', 'print("{\\"число\\":7}")\n')
    commit(root, 'источники')
    profile = 'architecture' if CASE == 'architecture' else 'product'
    s = {'type': 'documentation', 'version': 1, 'profile': profile,
         'outputs': {'markdown': 'docs/ёж.md', 'evidence': 'docs/ёж.evidence.json'},
         'required': {'sections': ['Обзор-Ёж'], 'scenarios': ['Сценарий-ёж'] if profile == 'product' else [],
                      'components': ['Компонент-Ёж', 'Компонент-ёлка'] if profile == 'architecture' else [],
                      'links': ['Связь-ёж'] if profile == 'architecture' else [],
                      'decisions': ['Решение-Ёж'], 'failures': ['Отказ-ёж']},
         'assertions': [{'id': 'Факт-Ёж', 'status': 'as-is', 'kind': 'observation',
                         'evidence': 'Основание-ёж', 'check': {'type': 'json-pointer',
                         'source': 'Источник-ёж', 'pointer': '/число', 'expected': 7}}],
         'sources': [{'id': 'Источник-ёж', 'kind': 'git', 'path': 'данные/ёлка.json',
                      'commit': git(root, 'rev-parse', 'HEAD'),
                      'blob': git(root, 'rev-parse', 'HEAD:данные/ёлка.json'), 'freshness': 'current'}],
         'questions': [{'id': 'Вопрос-Ёж', 'blocking': True, 'allow_open': False}],
         'calibration': {'positive': 'fixtures/positive.json', 'negative': [
             {'evidence': 'fixtures/negative.json', 'violation': 'coverage'}]}}
    p = {'version': 1, 'profile': profile, 'document_date': '2026-09-16',
         'sections': [{'id': 'Обзор-Ёж'}],
         'scenarios': [{'id': 'Сценарий-ёж', 'actor': 'Читатель Ёж', 'input': 'число',
                        'outcomes': [{'id': 'Успех-Ёж', 'kind': 'success', 'result': 'семь'},
                                     {'id': 'Отказ-ёж', 'kind': 'failure', 'result': 'нет данных'}]}] if profile == 'product' else [],
         'components': [{'id': 'Компонент-Ёж', 'boundary': 'ввод'},
                        {'id': 'Компонент-ёлка', 'boundary': 'хранение'}] if profile == 'architecture' else [],
         'links': [{'id': 'Связь-ёж', 'from': 'Компонент-Ёж', 'to': 'Компонент-ёлка',
                    'contract': 'Передача-Ёж'}] if profile == 'architecture' else [],
         'decisions': [{'id': 'Решение-Ёж', 'state': 'accepted', 'source': 'решения/Ёж.md'}],
         'failures': [{'id': 'Отказ-ёж', 'result': 'отказать без потери'}],
         'questions': [{'id': 'Вопрос-Ёж', 'state': 'resolved', 'decision': 'Решение-Ёж'}],
         'assertions': [{'id': 'Факт-Ёж', 'status': 'as-is', 'kind': 'observation',
                         'value': 7, 'evidence': 'Основание-ёж'}],
         'evidence': [{'id': 'Основание-ёж', 'assertion': 'Факт-Ёж', 'kind': 'observation',
                       'source': 'Источник-ёж', 'dependencies': [
                           {'type': 'observation-time', 'value': '2026-09-15T12:00:00Z'},
                           {'type': 'data-time', 'value': '2026-09-14T12:00:00Z'},
                           {'type': 'calculation-version', 'value': 'расчёт-Ёж-1'}]}]}
    put(root, 'docs/ёж.md', '# Ёж\n\n<!-- doc:section Обзор-Ёж -->\nОбъяснение.\n\n<!-- doc:formal:start -->\n<!-- doc:formal:end -->\n')
    save(root, s, p)
    put(root, 'fixtures/positive.json', dump(p))
    n = copy.deepcopy(p)
    n['sections'] = []
    put(root, 'fixtures/negative.json', dump(n))
    put(root, 'verdicts/critic/contracts-001-v1.md', 'accept\nИгрушка.\n')
    commit(root, 'договор')
    git(root, 'tag', '-a', 'frozen/contracts/001/1', '-m', 'игрушечная заморозка')
    return s, p


def subject(root, mode='--check'):
    checker = REPO / 'scripts/check_document.ts'
    if not checker.exists():
        return run(['bash', REPO / 'scripts/check_contract_ready.sh', root], root)
    return run(['node', checker, '--root', root, '--contract', 'contracts/001-yozh.md', mode], root)


def render(root, check=False):
    renderer = REPO / 'scripts/render_document.ts'
    if not renderer.exists():
        return subject(root)
    return run(['node', renderer, '--root', root, '--contract', 'contracts/001-yozh.md'] +
               (['--check'] if check else []), root)


def expect(result, rc, label):
    if result.returncode != rc:
        fail(label, f'поведение rc={result.returncode}, требуется {rc}; ' + (result.stderr + result.stdout).strip())
    if rc == 1 and not (result.stderr + result.stdout).strip():
        fail(label, 'отказ без именованной причины')


def control(root):
    expect(render(root), 0, 'render-control')
    expect(subject(root), 0, 'positive-control')


def mutate(root, s, p, label, mutation):
    altered = copy.deepcopy(p)
    mutation(altered)
    save(root, s, altered)
    r = render(root)
    if r.returncode not in (0, 1):
        fail(label, f'генерация не состоялась rc={r.returncode}: {r.stderr}')
    expect(subject(root), 1, label)
    save(root, s, p)
    control(root)


def refreeze(root, s, p):
    save(root, s, p)
    commit(root, 'новый игрушечный критерий')
    tags = git(root, 'tag', '--list', 'frozen/contracts/001/*').splitlines()
    git(root, 'tag', '-a', f'frozen/contracts/001/{len(tags) + 1}', '-m', 'игрушечная версия')


def obligations(root, s, p):
    mutate(root, s, p, 'missing', lambda x: x.update(sections=[]))
    mutate(root, s, p, 'duplicate', lambda x: x['sections'].append(x['sections'][0].copy()))
    mutate(root, s, p, 'substring', lambda x: x['sections'][0].update(id='Обзор-Ёжик'))
    text = (root / 'docs/ёж.md').read_text()
    put(root, 'docs/ёж.md', text.replace('<!-- doc:section Обзор-Ёж -->', '<!-- упоминание Обзор-Ёж -->'))
    expect(subject(root), 1, 'section-position')


def product(root, s, p):
    mutate(root, s, p, 'outcomes', lambda x: x['scenarios'][0].update(outcomes=[]))
    mutate(root, s, p, 'blocking-question', lambda x: x['questions'][0].update(state='open', decision=None))
    s['questions'][0].update(blocking=False, allow_open=True)
    p['questions'][0].update(state='open', decision=None)
    refreeze(root, s, p)
    control(root)


def architecture(root, s, p):
    mutate(root, s, p, 'dangling', lambda x: x['links'][0].update(to='Чужой-ёж'))
    mutate(root, s, p, 'decision', lambda x: x.update(decisions=[]))
    mutate(root, s, p, 'failure', lambda x: x.update(failures=[]))


def evidence(root, s, p):
    put(root, 'данные/ёлка.json', dump({'число': 8}))
    expect(subject(root), 1, 'drift')
    put(root, 'данные/ёлка.json', dump({'число': 7}))
    control(root)
    mutate(root, s, p, 'ownership', lambda x: x['evidence'][0].update(assertion='Другой-Ёж'))
    mutate(root, s, p, 'evidence-kind', lambda x: x['evidence'][0].update(kind='experiment-plan'))
    s['sources'][0]['freshness'] = 'historical'
    refreeze(root, s, p)
    put(root, 'данные/ёлка.json', dump({'число': 8}))
    control(root)


def assertions(root, s, p):
    mutate(root, s, p, 'value', lambda x: x['assertions'][0].update(value=8))
    s['assertions'][0]['check'] = {'type': 'probe', 'argv': ['python3', 'fixtures/probe.py'],
                                    'pointer': '/число', 'expected': 7}
    refreeze(root, s, p)
    control(root)
    put(root, 'fixtures/probe.py', 'print("{\\"число\\":8}")\n')
    expect(subject(root), 1, 'probe-result')
    put(root, 'fixtures/probe.py', 'raise SystemExit(2)\n')
    expect(subject(root), 2, 'unavailable')


def formal(root):
    lines = (root / 'docs/ёж.md').read_text(encoding='utf-8').splitlines(keepends=True)
    start, end = '<!-- doc:formal:start -->', '<!-- doc:formal:end -->'
    starts = [i for i, line in enumerate(lines) if line.rstrip('\r\n') == start]
    ends = [i for i, line in enumerate(lines) if line.rstrip('\r\n') == end]
    if len(starts) != 1 or len(ends) != 1 or starts[0] >= ends[0]:
        fail('formal-boundaries', 'нужна единственная упорядоченная пара границ')
    a, b = starts[0], ends[0]
    return ''.join(lines[:a + 1]), ''.join(lines[a + 1:b]), ''.join(lines[b:])


def formal_content(body, tokens, label, previous=None):
    # Independent of renderer --check: tokens belong INSIDE the formal region.
    # Empty, value-blind, status-blind and source-blind renderers are bound
    # respectively to content-control, value, status and source below.
    import re
    if not body.strip():
        fail(label, 'formal-фрагмент пуст: факты не сгенерированы')
    for token in tokens:
        if not re.search(r'(?<![\w-])' + re.escape(token) + r'(?![\w-])', body):
            fail(label, f'formal-фрагмент не содержит самостоятельное значение {token}')
    if previous is not None and body == previous:
        fail(label, 'formal-фрагмент не зависит от изменённого обязательства')


def rendered_content(root, tokens, label, previous=None):
    prefix, _, suffix = formal(root)
    control(root)
    after_prefix, body, after_suffix = formal(root)
    if (prefix, suffix) != (after_prefix, after_suffix):
        fail(label, 'renderer изменил свободный текст или section-маркеры')
    formal_content(body, tokens, label, previous)
    expect(render(root, True), 0, label + '-check')
    expect(render(root), 0, label + '-repeat')
    if formal(root) != (prefix, body, suffix):
        fail(label, 'повторная генерация недетерминированна')
    return body


def status_render(root, s, p):
    def freeze_package():
        put(root, 'fixtures/positive.json', dump(p))
        negative = copy.deepcopy(p)
        negative['sections'] = []
        put(root, 'fixtures/negative.json', dump(negative))
        refreeze(root, s, p)

    # Both values exist in the SAME source blob: a value-blind renderer
    # cannot pass merely by displaying a changed source OID.
    put(root, 'данные/ёлка.json', dump({'число': 'СемьЁж', 'другое': 'ВосемьЁлка'}))
    commit(root, 'два синтетических значения')
    s['sources'][0].update(commit=git(root, 'rev-parse', 'HEAD'),
                          blob=git(root, 'rev-parse', 'HEAD:данные/ёлка.json'))
    s['sources'].append(dict(s['sources'][0], id='Источник-ёлка'))
    s['assertions'][0]['check']['expected'] = 'СемьЁж'
    p['assertions'][0]['value'] = 'СемьЁж'
    freeze_package()
    base = rendered_content(root, ['Факт-Ёж', 'СемьЁж', 'as-is', 'Источник-ёж'],
                            'content-control')
    s['assertions'][0]['check'].update(pointer='/другое', expected='ВосемьЁлка')
    p['assertions'][0]['value'] = 'ВосемьЁлка'
    freeze_package()
    changed = rendered_content(root, ['Факт-Ёж', 'ВосемьЁлка', 'as-is', 'Источник-ёж'],
                               'value', base)
    # Only the used source changes; declared sources and their bytes stay put.
    s['assertions'][0]['check']['source'] = 'Источник-ёлка'
    p['evidence'][0]['source'] = 'Источник-ёлка'
    freeze_package()
    sourced = rendered_content(root, ['Факт-Ёж', 'ВосемьЁлка', 'as-is', 'Источник-ёлка'],
                               'source', changed)
    mutate(root, s, p, 'proposal', lambda x: x['assertions'][0].update(status='to-be'))
    text = (root / 'docs/ёж.md').read_text()
    put(root, 'docs/ёж.md', text.replace('<!-- doc:formal:start -->', '<!-- doc:formal:start -->\nподделка Ёж'))
    expect(render(root, True), 1, 'manual')
    expect(render(root), 0, 'regenerate')
    expect(render(root, True), 0, 'render-check')
    s['assertions'][0] = {'id': 'Факт-Ёж', 'status': 'to-be', 'kind': 'proposal',
                         'decision': 'Решение-Ёж', 'check': {'type': 'decision'}}
    p['assertions'][0] = {'id': 'Факт-Ёж', 'status': 'to-be', 'kind': 'proposal',
                         'decision': 'Решение-Ёж', 'value': 'ВосемьЁлка'}
    p['evidence'] = []
    freeze_package()
    rendered_content(root, ['Факт-Ёж', 'ВосемьЁлка', 'to-be', 'Решение-Ёж'],
                     'status', sourced)


def snapshot(root):
    return {str(f.relative_to(root)): hashlib.sha256(f.read_bytes()).hexdigest()
            for f in root.rglob('*') if f.is_file() and '.git' not in f.parts}


def preserving_check(root, rc, label, checker=subject):
    # Capture BEFORE the mutator; compare immediately, even on rejection.
    # A memory-oracle checker running in-place dies on preservation, not rewrite.
    # A disk-oracle checker in isolation dies on rewrite, not preservation.
    before = snapshot(root)
    result = checker(root)
    if snapshot(root) != before:
        fail(label + '-preservation', 'check изменил исходный проект')
    expect(result, rc, label)


def rewriting_probe(value):
    return ('from pathlib import Path\nimport json\n'
            'p=Path("docs/ёж.evidence.json"); x=json.loads(p.read_text())\n'
            'x["assertions"][0]["value"]=8; p.write_text(json.dumps(x,ensure_ascii=False))\n'
            'p=Path("contracts/001-yozh.md"); p.write_text(p.read_text().replace("\\"expected\\": 7", "\\"expected\\": 8"))\n'
            f'print(json.dumps({{"число":{value}}},ensure_ascii=False))\n')


def oracle(root, s, p):
    s['assertions'][0]['check'] = {'type': 'probe', 'argv': ['python3', 'fixtures/probe.py'],
                                    'pointer': '/число', 'expected': 7}
    refreeze(root, s, p)
    control(root)
    # Positive control mutates the sandbox too, but returns the original fact.
    # Rejecting ALL mutating probes is not a substitute for memory + isolation.
    put(root, 'fixtures/probe.py', rewriting_probe(7))
    preserving_check(root, 0, 'mutating-control')
    put(root, 'fixtures/probe.py', rewriting_probe(8))
    preserving_check(root, 1, 'rewrite')
    # Nothing is restored before the preservation assertion above.
    put(root, 'fixtures/probe.py', 'print("{\\"число\\":7}")\n')
    preserving_check(root, 0, 'readonly-control')


def rejected(action, label):
    import contextlib
    import io
    output = io.StringIO()
    code = None
    with contextlib.redirect_stderr(output):
        try:
            action()
        except SystemExit as error:
            code = error.code
    if code is None:
        fail('selftest-survivor', label)
    if code != 1 or f'ОТКАЗ DOC-{CASE}/{label}:' not in output.getvalue():
        fail('selftest-diagnosis', output.getvalue())
    print(output.getvalue().strip())


def status_render_selftest(root, s, p):
    # Execute the whole public probe with narrow synthetic subjects. These are
    # not implementations of doc-check: only the two revised measures are judged.
    from unittest.mock import patch
    for mode, refusal in [('honest', None), ('empty', 'content-control'),
                          ('value-blind', 'value'), ('source-blind', 'source'),
                          ('status-blind', 'status')]:
        project = root.parent / mode
        spec, package = toy(project)

        def body():
            package = json.loads((project / 'docs/ёж.evidence.json').read_text())
            assertion = package['assertions'][0]
            if mode == 'empty':
                return ''
            value = 'СемьЁж' if mode == 'value-blind' else str(assertion['value'])
            status = 'as-is' if mode == 'status-blind' else assertion['status']
            source = (package['evidence'][0]['source'] if package['evidence']
                      else assertion['decision'])
            if mode == 'source-blind':
                source = 'Источник-ёж'
            return f"| {assertion['id']} | {value} | {status} | {source} |\n"

        def renderer(project, check=False):
            prefix, old, suffix = formal(project)
            expected = body()
            if check:
                return subprocess.CompletedProcess([], int(old != expected), '', 'formal mismatch')
            put(project, 'docs/ёж.md', prefix + expected + suffix)
            return subprocess.CompletedProcess([], 0, '', '')

        def checker(project):
            text = (project / 'contracts/001-yozh.md').read_text()
            spec = json.loads(text.split('```json\n', 1)[1].split('```', 1)[0])
            package = json.loads((project / 'docs/ёж.evidence.json').read_text())
            mismatch = spec['assertions'][0]['status'] != package['assertions'][0]['status']
            return subprocess.CompletedProcess([], int(mismatch), '', 'status mismatch')

        with patch.dict(globals(), render=renderer, subject=checker):
            action = lambda: status_render(project, spec, package)
            if refusal:
                rejected(action, refusal)
            else:
                action()
                print('CONTROL DOC-status_render: непустой renderer, value/source/status')


def oracle_selftest(root, s, p):
    import shutil
    # The probe really runs and rewrites files, in a copied project or in-place.
    # Each weak subject is presented where its defect is observable (Н-39).
    cases = [(7, True, False, 0, 'mutating-control', None),
             (8, True, False, 1, 'rewrite', None),
             (8, False, False, 1, 'rewrite', 'rewrite-preservation'),
             (8, True, True, 1, 'rewrite', 'rewrite')]
    for index, (value, isolated, disk_oracle, rc, label, refusal) in enumerate(cases):
        project = root.parent / f'oracle-{index}'
        spec, package = toy(project)
        put(project, 'fixtures/probe.py', rewriting_probe(value))

        def checker(project):
            original = json.loads((project / 'docs/ёж.evidence.json').read_text())['assertions'][0]['value']
            with tempfile.TemporaryDirectory(prefix='doc027-sandbox-', dir='/tmp') as scratch:
                sandbox = Path(scratch) / 'project'
                if isolated:
                    shutil.copytree(project, sandbox)
                else:
                    sandbox = project
                result = run(['python3', 'fixtures/probe.py'], sandbox)
                expect(result, 0, 'selftest-probe')
                expected = (json.loads((sandbox / 'docs/ёж.evidence.json').read_text())
                            ['assertions'][0]['value'] if disk_oracle else original)
                actual = json.loads(result.stdout)['число']
                return subprocess.CompletedProcess([], int(actual != expected), '', 'probe value mismatch')

        action = lambda: preserving_check(project, rc, label, checker)
        if refusal:
            rejected(action, refusal)
        else:
            action()
            print(f'CONTROL DOC-oracle/{label}: rc={rc}, исходный проект сохранён')


def lifecycle(root, s, p):
    expect(run(['bash', REPO / 'scripts/check_contract_ready.sh', root], root), 0, 'ready-control')
    for tag in git(root, 'tag', '--list', 'frozen/*').splitlines():
        git(root, 'tag', '-d', tag)
    s['required']['sections'] = []
    save(root, s, p)
    commit(root, 'пустые doc-обязательства')
    expect(run(['bash', REPO / 'scripts/check_contract_ready.sh', root], root), 1, 'ready-preflight')
    before = git(root, 'for-each-ref', '--format=%(refname):%(objectname)', 'refs/tags/frozen/')
    expect(run(['bash', REPO / 'scripts/freeze_contract.sh', 'contracts/001-yozh.md', 'Ёж', root], root), 1, 'freeze-preflight')
    if git(root, 'for-each-ref', '--format=%(refname):%(objectname)', 'refs/tags/frozen/') != before:
        fail('freeze-atomic', 'отказ оставил frozen-тег')
    s['required']['sections'] = ['Обзор-Ёж']
    save(root, s, p)
    s['calibration']['negative'][0]['evidence'] = 'fixtures/positive.json'
    save(root, s, p)
    commit(root, 'неразличимая калибровка')
    expect(run(['bash', REPO / 'scripts/check_contract_ready.sh', root], root), 1, 'ready-calibration')
    expect(run(['bash', REPO / 'scripts/freeze_contract.sh', 'contracts/001-yozh.md', 'Ёж', root], root), 1, 'freeze-calibration')
    if git(root, 'tag', '--list', 'frozen/*'):
        fail('calibration-atomic', 'неразличимая калибровка оставила тег')
    s['calibration']['negative'][0]['evidence'] = 'fixtures/negative.json'
    save(root, s, p)
    commit(root, 'исправлены обязательства')
    expect(run(['bash', REPO / 'scripts/check_contract_ready.sh', root], root), 0, 'ready-doc-control')
    expect(run(['bash', REPO / 'scripts/freeze_contract.sh', 'contracts/001-yozh.md', 'Ёж', root], root), 0, 'freeze-doc-control')
    regressions(root, s, p)


def regressions(root, s, p):
    git(root, 'tag', '-a', 'ustav/1', '-m', 'игрушечный устав')
    expect(run(['bash', REPO / 'scripts/check_contract_frozen.sh', root], root), 0, 'frozen-control')
    expect(run(['bash', REPO / 'scripts/check_charter.sh', root], root), 0, 'charter-control')
    # Live author identity, not a local-config impersonation (016).
    git(root, 'config', '--unset', 'user.name')
    git(root, 'config', '--unset', 'user.email')
    # Зона-контроль судит ПУТИ коммитов, а check_zones не матчит кириллические
    # пути (git diff-tree отдаёт quoted/octal — pre-existing дефект, отдельный
    # предмет очереди Н-99): обе пробы зон несут только ASCII-пути. Рабочее
    # дерево может нести рендер-правку docs/ёж.md — откат до коммита, чтобы
    # дельта внутризонного коммита была только ASCII; выход за зону — alien.txt
    # в корне. Кириллическая грамматика ID/контента покрыта остальным корпусом.
    git(root, 'checkout', '--', 'docs')
    put(root, 'docs/allowed.txt', 'Ёж\n')
    commit(root, 'допустимый документ', author='implementer')
    expect(run(['bash', REPO / 'scripts/check_zones.sh', root], root), 0, 'zone-control')
    put(root, 'alien.txt', 'утечка ёж\n')
    commit(root, 'выход за зону', author='implementer')
    expect(run(['bash', REPO / 'scripts/check_zones.sh', root], root), 1, 'zone-escape')
    put(root, 'contracts/001-yozh.md', (root / 'contracts/001-yozh.md').read_text() + '\nизменён критерий\n')
    commit(root, 'несанкционированный критерий')
    expect(run(['bash', REPO / 'scripts/check_contract_frozen.sh', root], root), 1, 'frozen-change')
    expect(run(['bash', REPO / 'scripts/check_charter.sh', root], root), 1, 'charter-change')


with tempfile.TemporaryDirectory(prefix='doc027-', dir='/tmp') as scratch:
    root = Path(scratch) / 'project'
    spec, package = toy(root)
    if sys.argv[2:] == ['--self-test'] and CASE in ('status_render', 'oracle'):
        globals()[CASE + '_selftest'](root, spec, package)
    else:
        if CASE != 'lifecycle':
            control(root)
        globals()[CASE](root, spec, package)
