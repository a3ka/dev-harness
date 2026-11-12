#!/usr/bin/env python3
"""192: сборка честной модели ролей из ЕДИНОГО источника — base/roles (пин SHA256SUMS),
норм 188 (fixtures/workshop_project/roles_architecture_188/norms.tsv, канон соседней семьи)
и черновиков 192 (drafts/). Модель — «роли после вставки 188 + 192»; потолок 73728 байт
проверяет батарея (probe.py), здесь только сборка.

Коды возврата: 0 — собрано; 2 — NOT_IMPLEMENTED (пин разошёлся, фрагмент не уникален,
источник отсутствует). Выход: <каталог>/roles/<роль>.md по семи ролям 192.

Использование: python3 build_model.py <каталог-назначения>
"""
import hashlib
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
LIMIT = 73728
ROLES = ('critic', 'architect', 'orchestrator', 'arbiter', 'adversary', 'reviewer', 'critic-sol')


class NotBuilt(Exception):
    pass


def read(path):
    if not path.is_file():
        raise NotBuilt(f'нет файла {path}')
    return path.read_text(encoding='utf-8')


def verify_pins():
    sums = (HERE / 'base' / 'SHA256SUMS').read_text(encoding='utf-8')
    for row in sums.splitlines():
        digest, rel = row.split('  ', 1)
        data = (HERE / 'base' / rel).read_bytes()
        if hashlib.sha256(data).hexdigest() != digest:
            raise NotBuilt(f'пин разошёлся: {rel}')
    return {r: read(HERE / 'base' / 'roles' / f'{r}.md') for r in ROLES}


def insertion_188():
    """Минимальная структурная вставка 188: раздел + маркер + литерал на каждую норму.

    Источник — norms.tsv семьи 188 (канон её контракта), а не копия в этой семье."""
    rows = []
    src = REPO / 'fixtures' / 'workshop_project' / 'roles_architecture_188' / 'norms.tsv'
    for row in read(src).splitlines():
        role, key, literal = row.split('\t')
        for recipient in ('architect', 'critic', 'implementer', 'adversary',
                          'reviewer') if role == 'all5' else (role,):
            rows.append((recipient, literal))
    grouped = {}
    for recipient, literal in rows:
        grouped.setdefault(recipient, []).append(literal)
    return grouped


def replace_once(text, old_path, new_path):
    old = read(old_path)
    new = read(new_path)
    if text.count(old) != 1:
        raise NotBuilt(f'фрагмент не уникален: {old_path.name} ({text.count(old)} вхождений)')
    return text.replace(old, new.rstrip('\n'))


def section_from_draft(block):
    """### roles/<роль>.md — раздел `## <заголовок>` … → (заголовок, тело)."""
    first, body = block.split('\n', 1)
    if '`## ' not in first:
        raise NotBuilt(f'заголовок раздела не разобран: {first[:80]}')
    head = first.split('`## ', 1)[1].split('`', 1)[0]
    return '## ' + head, body.strip('\n')


def apply_192(model):
    # critic: правка §Остановка + голова и хвост «Второй FAIL» + новый раздел в конец файла
    model['critic'] = replace_once(
        model['critic'], HERE / 'drafts/edits/critic-ostanovka.old', HERE / 'drafts/edits/critic-ostanovka.new')
    model['critic'] = replace_once(
        model['critic'], HERE / 'drafts/edits/critic-vtorojfail-golova.old',
        HERE / 'drafts/edits/critic-vtorojfail-golova.new')
    model['critic'] = replace_once(
        model['critic'], HERE / 'drafts/edits/critic-vtorojfail-tail.old',
        HERE / 'drafts/edits/critic-vtorojfail-tail.new')
    model['critic'] = model['critic'].rstrip('\n') + '\n\n' + \
        read(HERE / 'drafts' / 'critic_section.md').strip('\n') + '\n'

    # architect: три правки абзацев + три пункта в список «Барьер…» + новый раздел
    # после «Неисправная проверка», перед «Правила исполнения плана»
    for name in ('startup', 'otvet', 'byudzhet', 'barer'):
        model['architect'] = replace_once(
            model['architect'], HERE / f'drafts/edits/architect-{name}.old',
            HERE / f'drafts/edits/architect-{name}.new')
    marker = '## Правила исполнения плана'
    if model['architect'].count(marker) != 1:
        raise NotBuilt('якорь вставки раздела architect не уникален')
    model['architect'] = model['architect'].replace(
        marker, read(HERE / 'drafts' / 'architect_section.md').strip('\n') + '\n\n' + marker)

    # orchestrator/arbiter/adversary/reviewer: по разделу из others_sections.md в конец файла
    # critic-sol: одна строка в существующий ## Быстрый-процесс
    others = read(HERE / 'drafts' / 'others_sections.md')
    blocks = others.split('\n### ')
    for block in [blocks[0]] + ['### ' + b for b in blocks[1:]]:
        role = block.split('### roles/', 1)[1].split('.md', 1)[0]
        if role == 'critic-sol':
            line = block.split('\n', 1)[1].strip('\n')
            section = '## Быстрый-процесс'
            lines = model[role].split('\n')
            if lines.count(section) != 1:
                raise NotBuilt('раздел Быстрый-процесс critic-sol не уникален')
            start = lines.index(section) + 1
            end = next((i for i in range(start, len(lines)) if lines[i].startswith('#')), len(lines))
            lines[end:end] = [line, '']
            model[role] = '\n'.join(lines)
        else:
            heading, body = section_from_draft(block)
            model[role] = model[role].rstrip('\n') + '\n\n' + heading + '\n\n' + body + '\n'
    return model


def main():
    target = Path(sys.argv[1]) if len(sys.argv) > 1 else HERE / 'model' / '.build'
    try:
        model = verify_pins()
        grouped = insertion_188()
        for role in ROLES:
            if role in grouped:
                parts = ['## Архитектура 188', '']
                for literal in grouped[role]:
                    parts += [f'Норма-строка (ПРОВОДКА roles/{role}.md, заморожена 188/1):', '', literal, '']
                model[role] = model[role].rstrip('\n') + '\n\n' + '\n'.join(parts).rstrip('\n') + '\n'
        model = apply_192(model)
    except NotBuilt as exc:
        print(f'NOT_IMPLEMENTED: {exc}', file=sys.stderr)
        return 2
    out = target / 'roles'
    out.mkdir(parents=True, exist_ok=True)
    for role, text in model.items():
        (out / f'{role}.md').write_text(text, encoding='utf-8')
    for role in ROLES:
        size = len(model[role].encode())
        print(f'{role}.md {size} байт запас {LIMIT - size}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
