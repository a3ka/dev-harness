#!/usr/bin/env python3
# Проба контракта 015, круг 5 (unicode-блокер круга 4): строит ПОЛНЫЙ подменённый
# корень из таблицы §Материал контракта — методология критика круга 4 («полный
# подменённый корень из 36 строк §Материал, где только Н-36 заменена»). Каждый
# каталог — собственный tmp вне стерегомого дерева. Аргументы: <корень> [замена Н-36].
# Без второго аргумента корень зелёный (все цели §Материал); со вторым — значение
# адреса Н-36 подменено (обходные входы круга 4: «αконтракт 015», «контракт 015β»).
# Строки «БЕЗ МАРКЕРА» (А-16/А-17) получают маркер закрытия — форма не судится,
# таблица их не якорит. Грамматико-агностичен: читает таблицу, не судит её.
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
CONTRACT = os.path.join(HERE, '..', '..', 'contracts',
                        '015-jadro-avtonomnosti-nabljudenij.md')

if len(sys.argv) < 2:
    print('использование: build_root.py <корень> [замена Н-36]', file=sys.stderr)
    sys.exit(1)
root = sys.argv[1]
override = sys.argv[2] if len(sys.argv) > 2 else None

rows = []
with open(CONTRACT, encoding='utf-8') as fh:
    for line in fh:
        if line.startswith('| Н-') or line.startswith('| А-'):
            cells = re.split(r'(?<!\\)\|', line.strip().strip('|'))
            cells = [c.replace('\\|', '|').strip() for c in cells]
            if len(cells) >= 3:
                rows.append((cells[0], cells[1], cells[2]))

if not rows:
    print('ОТКАЗ: таблица §Материал не найдена в %s' % CONTRACT, file=sys.stderr)
    sys.exit(1)

files = {'Н': 'NABLIUDENIA.md', 'А': 'NABLIUDENIA_ARCHITECT.md'}
for rid, now, target in rows:
    if 'БЕЗ МАРКЕРА' in now:
        body = '### %s. Запись `ЗАКРЫТО (миграция присвоила статус — §Материал)`\n' % rid
    else:
        value = override if (override is not None and rid == 'Н-36') else target
        body = '### %s. Запись `ОТКРЫТО — адрес: %s`\n' % (rid, value)
    with open(os.path.join(root, files[rid[0]]), 'a', encoding='utf-8') as fh:
        fh.write(body)
print('корень: %d строк §Материал (Н-36: %s)' % (len(rows), override or 'цель'))
