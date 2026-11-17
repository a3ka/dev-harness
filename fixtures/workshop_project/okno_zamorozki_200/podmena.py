#!/usr/bin/env python3
"""Подмены батареи 200 «окно заморозки»: честная модель окна (б) поверх
scripts/check_contract_frozen.sh дерева и обманные стабы.

Субъект — СУЩЕСТВУЮЩИЙ scripts/check_contract_frozen.sh; правка предмета —
единственный блок отбора pred_komity (строки с git log --diff-merges=
first-parent). Модель не пишется отдельным файлом: она есть побайтовая копия
субъекта, в которой черновой якорь отбора заменён на целевой блок (слово
владельца 2026-11-17 п.9: коммиты с пустым diff пути к первому родителю в
окно не попадают). На РЕАЛИЗОВАННОМ дереве (блок уже перенесён дословно)
подмена не производится — файл запускается как есть, канал порта закрыт.

Стабы — та же копия с одной обманной заменой; привязка стаб↔клетка — кодом
раннера (Н-39), не этой прозой.

Шим m5 расширяет grandfather-аллоулист ОДНОЙ игрушечной парой (мир клетки),
не трогая исходный список: toy-sha в истории не подделать, а пара — данные
соавтора, не предмет.

Выход: rc 0 — песочница готова; rc 2 (NOT_IMPLEMENTED) — якорь не найден.
"""
import os
import shutil
import sys

# Черновой якорь отбора (ровно 1 вхождение в субъекте черновика).
ANCHOR_DRAFT = (
    '      pred_komity="$(g log -s --format=%H --no-renames --diff-merges=first-parent \\\n'
    '        "refs/tags/frozen/$dir/$NNN/$vmax"..HEAD -- "$f" 2>/dev/null || true)"\n'
)

# Целевой блок: окно (б) = коммиты с НЕПУСТЫМ diff пути к первому родителю.
# Первые две строки — черновой якорь дословно (канон единого источника:
# реализация переносит блок ЦЕЛИКОМ, канал порта закрывается этим же текстом).
MODEL_BLOCK = (
    ANCHOR_DRAFT
    + '      # 200: окно (б) — коммит входит в список ТОЛЬКО когда diff пути $f\n'
      '      # к ПЕРВОМУ родителю НЕ пуст. git log по пути в этом режиме отбирает\n'
      '      # и merge, равные первому родителю, но отличные от боковой ветки\n'
      '      # (int-merge без правки пути): такие merge текст контракта не меняют,\n'
      '      # а требовали РАЗРЕШИЛ и порождали ручные grandfather-пары. Обычные и\n'
      '      # корневые коммиты отбираются log по пути ровно правилу «изменил/\n'
      '      # добавил путь» — фильтр их не трогает.\n'
      '      otobr_200=""\n'
      '      while IFS= read -r c; do\n'
      '        [ -n "$c" ] || continue\n'
      '        if [ "$(g rev-list --parents -n 1 "$c" | wc -w)" -gt 2 ]; then\n'
      '          g diff --quiet --no-renames "${c}^1" "$c" -- "$f" 2>/dev/null && continue\n'
      '        fi\n'
      '        otobr_200="${otobr_200}${c}"$\'\\n\'\n'
      '      done <<<"$pred_komity"\n'
      '      pred_komity="${otobr_200%$\'\\n\'}"\n'
)

# Якорь ветвления razrechen (после отбора): стаб-В подменяет здесь «пусто →
# не разрешено» на «пусто → разрешено», пропуская отказы M2/M3/M4/M7/M8.
ANCHOR_RAZRESHEN = (
    '    razrechen=0\n'
    '    if [ -n "$pred_komity" ]; then\n'
    '      razrechen=1\n'
)
STAB_V_RAZRESHEN = (
    '    razrechen=1\n'
    '    if [ -n "$pred_komity" ]; then\n'
    '      razrechen=1\n'
)

# Якорь вызова grandfather в (в)-ветке (ровно 1 вхождение): стаб-Г снимает его.
ANCHOR_GRANDFATHER = '          grandfather_pair "$c" "$f" && continue\n'

# Стабы заменяют БЛОК отбора целиком — не только черновую строку: на реализованном
# дереве блок есть весь MODEL_BLOCK с фильтром, и замена одной лишь черновой
# строки оставила бы фильтр живым (стаб молчал бы). s01 — прежний отбор (блок →
# черновая строка; на черновике тождественно); s02 — обход только по первой
# линии (пропускает носителей второй линии); s03 — пустое окно всегда разрешено
# (дополнительно подменяет ветвление razrechen); s04 — модель минус вызов
# grandfather в (в)-ветке; s05 — окно без отбора по пути (весь диапазон).
STUB_SELECTION = {
    's01': ANCHOR_DRAFT,
    's02': ('      pred_komity="$(g log -s --format=%H --no-renames --first-parent \\\n'
            '        "refs/tags/frozen/$dir/$NNN/$vmax"..HEAD -- "$f" 2>/dev/null || true)"\n'),
    's03': '      pred_komity=""\n',
    's05': ('      pred_komity="$(g rev-list "refs/tags/frozen/$dir/$NNN/$vmax"..HEAD '
            '2>/dev/null || true)"\n'),
}

SUBJECT = 'check_contract_frozen.sh'
CHARTER = 'check_charter.sh'
CHARTER_FN = 'grandfather_pair() {'
CHARTER_LIB_GUARD = '# ── ИМПОРТ КАК БИБЛИОТЕКА'


def target_block(text):
    """Блок отбора субъекта: канон (уже реализован) либо черновая строка."""
    if text.count(MODEL_BLOCK) == 1:
        return MODEL_BLOCK
    if text.count(ANCHOR_DRAFT) == 1:
        return ANCHOR_DRAFT
    die('блок отбора не найден ни в канонной, ни в черновой форме')


def die(msg):
    sys.stderr.write('podmena: %s\n' % msg)
    sys.exit(2)


def read(path):
    with open(path, encoding='utf-8') as f:
        return f.read()


def write(path, text):
    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)


def copy_scripts(src, dst):
    """Песочница <dst>/scripts — полная копия каталога scripts дерева.

    dst создаёт вызывающий (mktemp): уникальность — именем каталога, не
    счётчиком (счётчик в подстановке $( ) не виден родителю).
    """
    sdst = os.path.join(dst, 'scripts')
    if os.path.isdir(sdst):
        die('песочница уже существует: %s' % sdst)
    if not os.path.isdir(dst):
        os.makedirs(dst)
    shutil.copytree(src, sdst)


def subst(path, anchor, repl, why):
    text = read(path)
    n = text.count(anchor)
    if n != 1:
        die('%s: якорь встречается %d раз (нужен 1) в %s' % (why, n, path))
    write(path, text.replace(anchor, repl, 1))


def transform_subject(scripts, kind):
    """Копия субъекта с преобразованием kind; возвращает текст статуса."""
    path = os.path.join(scripts, SUBJECT)
    text = read(path)
    if kind == 'copy':
        return 'скопирован побайтово'
    if kind == 'model':
        if text.count(MODEL_BLOCK) == 1:
            return 'уже несёт окно-200 (канон дословно)'
        block = target_block(text)
        write(path, text.replace(block, MODEL_BLOCK, 1))
        return 'модель окна-200 подставлена'
    if kind == 's04':
        if text.count(MODEL_BLOCK) != 1:
            text = text.replace(target_block(text), MODEL_BLOCK, 1)
        subst(path, ANCHOR_GRANDFATHER, '', 'стаб s04 (снят grandfather (в))')
        return 'стаб s04 подставлен (модель минус grandfather в (в)-ветке)'
    if kind in STUB_SELECTION:
        block = target_block(text)
        write(path, text.replace(block, STUB_SELECTION[kind], 1))
        if kind == 's03':
            subst(path, ANCHOR_RAZRESHEN, STAB_V_RAZRESHEN, 'стаб s03 (пусто = разрешено)')
        return 'стаб %s подставлен' % kind
    die('неизвестное преобразование: %s' % kind)


def shim_charter(scripts, sha, fpath):
    """Расширить grandfather-аллоулист одной игрушечной парой (мир клетки m5).

    Исходный список сохраняется ЦЕЛИКОМ (переименование + обёртка): шим —
    тест-двойник данных соавтора, а не ослабление устава.
    """
    path = os.path.join(scripts, CHARTER)
    text = read(path)
    n = text.count(CHARTER_FN)
    if n != 1:
        die('grandfather_pair() встречается %d раз (нужен 1) в %s' % (n, path))
    text = text.replace(CHARTER_FN, 'grandfather_pair_ishodnaja() {', 1)
    n = text.count(CHARTER_LIB_GUARD)
    if n != 1:
        die('библиотечный якорь устава встречается %d раз (нужен 1) в %s' % (n, path))
    shim = (
        '# 200-m5: шим батареи — исходный grandfather-список целиком плюс ОДНА\n'
        '# игрушечная пара мира клетки (toy-sha в истории не подделать);\n'
        '# вставка ПЕРЕД библиотечным guard: sourcing останавливается на нём.\n'
        'grandfather_pair() {\n'
        '  grandfather_pair_ishodnaja "$@" && return 0\n'
        '  [ "$1" = "%s" ] && [ "$2" = "%s" ] && return 0\n'
        '  return 1\n'
        '}\n\n' % (sha, fpath)
    )
    write(path, text.replace(CHARTER_LIB_GUARD, shim + CHARTER_LIB_GUARD, 1))


def main(argv):
    if len(argv) >= 1 and argv[0] == 'list':
        for k in sorted(list(STUB_SELECTION) + ['s04']):
            print(k)
        return 0
    if len(argv) == 3 and argv[0] in ('copy', 'model') or (len(argv) == 4 and argv[0] == 'stub'):
        kind, src, dst = argv[0], argv[-2], argv[-1]
        copy_scripts(src, dst)
        status = transform_subject(os.path.join(dst, 'scripts'), kind if kind != 'stub' else argv[1])
        print('podmena: %s — %s' % (dst, status))
        return 0
    if len(argv) == 4 and argv[0] == 'shim':
        shim_charter(argv[1], argv[2], argv[3])
        print('podmena: шим m5 вставлен в %s' % argv[1])
        return 0
    sys.stderr.write(
        'вызов: podmena.py copy|model <scripts> <dst> | '
        'stub <id> <scripts> <dst> | shim <scripts> <sha> <путь> | list\n')
    return 2


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
