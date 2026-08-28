#!/usr/bin/env bash
# Проба контракта 015, развилка 1а (блокер 2 круга 1) + круг 3 (блокеры 2-3):
# миграционная сверка — команда с кодом возврата. Красная ДО миграционной пачки,
# зелёная ПОСЛЕ (пачка в коммите введения). Необязательный аргумент $1 — корень с
# NABLIUDENIA*.md (стаб-входы круга 3 на отдельном дереве); таблица §Материал
# читается всегда из дерева пробы. Мера — как у барьера (инварианты 1-3):
# заголовок ^### (Н|А)-NN. + ПОСЛЕДНЯЯ бэктик-группа той же строки; тело записи
# не судится. Круг 3, блокер 3: формы якоря недостаточно — адресатные ключи
# (категория + идентификатор) каждой строки §Материал обязаны присутствовать в
# маркере записи; ожидания генерируются из таблицы, а не зашиты в пробу.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
TREE="$(cd "$HERE/../.." && pwd)"
ROOT="${1:-$TREE}"
CONTRACT="$TREE/contracts/015-jadro-avtonomnosti-nabljudenij.md"

[ -f "$CONTRACT" ] || { printf 'ОТКАЗ: контракта нет: %s\n' "$CONTRACT" >&2; exit 1; }
[ -d "$ROOT" ] || { printf 'ОТКАЗ: корня нет: %s\n' "$ROOT" >&2; exit 1; }
command -v python3 >/dev/null 2>&1 || { printf 'ОТКАЗ: python3 недоступен\n' >&2; exit 1; }

python3 - "$CONTRACT" "$ROOT" <<'PY'
import os, re, sys

contract, root = sys.argv[1], sys.argv[2]
fails = 0

def fail(msg):
    global fails
    fails += 1
    print('ОТКАЗ: %s' % msg, file=sys.stderr)

# Якорь цели — ERE из блока `# ГРАММАТИКА:` контракта 015 побайтово: стемы
# альтернатив — арбитраж 3 (спор 2), граница токена — круг 3 (блокер 2).
ANCHOR = r'(^|[^0-9A-Za-zа-яёА-ЯЁ_-])(контракт[а-яё]* 0[0-9][0-9]($|[^0-9A-Za-zа-яёА-ЯЁ])|contracts/[^` ]+|очеред[а-яё]* автономности($|[^0-9A-Za-zа-яёА-ЯЁ])|пачк[а-яё]* (Н|А)-[0-9]+($|[^0-9A-Za-zа-яёА-ЯЁ])|ROADMAP[- ]*шаг[а-яё]* [0-9]+($|[^0-9A-Za-zа-яёА-ЯЁ])|правил[а-яё]* роли [A-Za-z]+($|[^0-9A-Za-zа-яёА-ЯЁ])|историческое, не чинить: ..*|cognitive-only.*риск|закрыто [0-9][0-9][0-9]($|[^0-9A-Za-zа-яёА-ЯЁ]))'
ANCHOR_RE = re.compile(ANCHOR)

# Стемы альтернатив — дословно из ANCHOR (охрана двух источников: проба обязана
# искать ключи теми же стемами, что и форма; расхождение — отказ до проверки).
STEMS = [
    ('K',    r'контракт[а-яё]* 0[0-9][0-9]',   r'0[0-9][0-9]'),
    ('PATH', r'contracts/[^` ]+',              r'contracts/\S+'),
    ('Q',    r'очеред[а-яё]* автономности',    None),
    ('P',    r'пачк[а-яё]* (Н|А)-[0-9]+',      r'(Н|А)-[0-9]+'),
    ('R',    r'ROADMAP[- ]*шаг[а-яё]* [0-9]+', r'[0-9]+'),
    ('RR',   r'правил[а-яё]* роли [A-Za-z]+',  r'роли ([A-Za-z]+)'),
    ('H',    r'историческое, не чинить: ..*',  None),
    ('C',    r'cognitive-only.*риск',          None),
    ('Z',    r'закрыто [0-9][0-9][0-9]',       r'[0-9]{3}'),
]
for _n, _stem, _id in STEMS:
    if _stem not in ANCHOR:
        print('ОТКАЗ: проба рассинхронизована — стем %s отсутствует в ERE # ГРАММАТИКА:'
              % _n, file=sys.stderr)
        sys.exit(1)

GL = r'(^|[^0-9A-Za-zа-яёА-ЯЁ_-])'
GR = r'($|[^0-9A-Za-zа-яёА-ЯЁ])'
# Правая граница не нужна альтернативам, съедающим хвост (PATH, H, C).
CATS = [
    (n, re.compile(GL + s + (GR if n not in ('PATH', 'H', 'C') else '')), i)
    for n, s, i in STEMS
]

def keys(text):
    out = set()
    for name, rx, idrx in CATS:
        for m in rx.finditer(text):
            g = m.group(0)
            if idrx is None:
                out.add(name)
            else:
                idm = re.search(idrx, g)
                out.add('%s:%s' % (name, idm.group(1) if idm.lastindex else idm.group(0))
                        if idm else name)
    return out

HDR = re.compile(r'^### ((?:Н|А)-[0-9]+)\.')
BT = re.compile(r'`([^`]*)`')

def read_records(path):
    recs = {}
    try:
        with open(path, encoding='utf-8') as fh:
            for line in fh:
                m = HDR.match(line)
                if m:
                    recs[m.group(1)] = line.rstrip('\n')
    except OSError as e:
        print('ОТКАЗ: %s не читается: %s' % (path, e), file=sys.stderr)
        sys.exit(1)
    return recs

allrec = {}
for f in ('NABLIUDENIA.md', 'NABLIUDENIA_ARCHITECT.md'):
    p = os.path.join(root, f)
    if not os.path.isfile(p):
        fail('%s отсутствует в %s' % (f, root))
        continue
    for rid, hline in read_records(p).items():
        allrec[rid] = (f, hline)

def marker_of(hline):
    gs = BT.findall(hline)
    return gs[-1] if gs else None

def tail_of(marker):
    return marker.split('адрес:', 1)[1]

# ── Общий проход: та же мера, что у барьера (инварианты 2-3), по всем записям ──
for rid, (f, hline) in allrec.items():
    m = marker_of(hline)
    if m is None:
        fail('%s %s: статус не объявлен' % (f, rid))
        continue
    if not m.startswith('ОТКРЫТО'):
        continue
    if 'адрес:' not in m:
        fail('%s %s: открыта без адреса' % (f, rid))
        continue
    tail = tail_of(m)
    if not tail.strip():
        fail('%s %s: адрес пуст' % (f, rid))
        continue
    if not ANCHOR_RE.search(tail):
        fail('%s %s: адрес не называет цель («%s»)' % (f, rid, tail.strip()))

# ── Сверка назначения: адресатные ключи строк §Материал против маркеров записей ──
rows = []
try:
    with open(contract, encoding='utf-8') as fh:
        for line in fh:
            if line.startswith('| Н-') or line.startswith('| А-'):
                cells = re.split(r'(?<!\\)\|', line.strip().strip('|'))
                cells = [c.replace('\\|', '|').strip() for c in cells]
                if len(cells) >= 3:
                    rows.append((cells[0], cells[1], cells[2]))
except OSError as e:
    print('ОТКАЗ: контракт не читается: %s' % e, file=sys.stderr)
    sys.exit(1)

for rid, now, target in rows:
    want = keys(target)
    if not want:
        if 'БЕЗ МАРКЕРА' in now:
            continue
        fail('§Материал %s: строка не называет адресата («%s»)' % (rid, target))
        continue
    if rid not in allrec:
        fail('%s: записи нет в дереве, таблица ждёт адресата %s' % (rid, ' '.join(sorted(want))))
        continue
    _, hline = allrec[rid]
    m = marker_of(hline)
    if m is None or not m.startswith('ОТКРЫТО'):
        # Закрытая/переведённая запись называет цель маркером закрытия; регистр
        # маркера закрытия (ЗАКРЫТО) назначением владеет так же, как адрес.
        have = keys(hline) | keys(hline.lower())
    else:
        if 'адрес:' not in m or not tail_of(m).strip() or not ANCHOR_RE.search(tail_of(m)):
            continue            # уже названа общим проходом
        have = keys(m)
    missing = want - have
    if missing:
        fail('%s: назначение изменено — таблица ждёт %s, маркер несёт %s'
             % (rid, ' '.join(sorted(want)) or '∅', ' '.join(sorted(have)) or '∅'))

if fails:
    sys.exit(1)
print('ok: все ОТКРЫТО-маркеры несут анкоренный адрес; назначение каждой строки §Материал сохранено')
PY
