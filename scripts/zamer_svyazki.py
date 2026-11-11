#!/usr/bin/env python3
# НЕ БАРЬЕР: субъект (SUBJECT) батареи fixtures/workshop_project/zamer_svyazki_190/red_zamer_svyazki_190.sh;
# её приёмка — красная проба на сам scripts/zamer_svyazki.sh (22 клетки; режимы --repo/--model/--stabs), не сам скрипт;
# контракт 190 §Проводка: guard=scripts/zamer_svyazki.sh (проводка 038 видит подключение по реестру ci-steps).
"""Замер связки architect ↔ критик (контракт 190, Л6 — С16, часть «связка»).

Одна команда печатает таблицу мер связки по реестру предметов: вызовы критика,
исходы, блоки по происхождению и классу, токены и вызовы модели architect/critic по
журналам сессий, долю одиночных вызовов и долю хвоста.

  bash scripts/zamer_svyazki.sh --repo <корень> --zhurnaly <корень-сессий> \\
      [--s ISO] [--do ISO] [--predmety ERE]

Возвращает: 0 — таблица напечатана (stderr несёт «просмотрено: записей_журналов=N»,
N>0 — число просмотренного наблюдаемо и в зелёном режиме); 1 — ПУСТАЯ_ВЫБОРКА
(каталог журналов есть, записей в окне нет); 2 — НЕТ_ЖУРНАЛОВ/НЕТ_РЕЕСТРА/НЕТ_РЕПО.
"""
import argparse
import json
import re
import sys
from pathlib import Path

# ── Канон таблицы (21 столбец; единый источник — docs/190-zamer-svyazki.md) ─────
HEADER = ("предмет\tвызовы\tfail\taccept\tобрывы\tисход\tблоки\tпервичные\tдельта\tузкое\t"
          "пропущено\tповтор\tпроисх_не_уст\tклассы\tклассы_не_уст\tarch_токены\tarch_вызовы\t"
          "crit_токены\tcrit_вызовы\tодиночные_доля\tхвост_доля")

# Число судейских столбцов (вызовы…классы_не_уст): у неустановленного предмета все
# они несут «не-установлен», а не ноль (инвариант 3).
JUDGE_COLUMNS = 14

# Роль агента — префикс имени файла журнала; «прочие роли» (Rev/Impl/Adv/Arb) в
# столбцы architect/critic не попадают (инвариант 6).
ROLE_PREFIXES = (
    ('architect', ('Architect', 'Arch')),
    ('critic', ('Critic', 'Crit')),
    ('reviewer', ('Rev',)),
    ('implementer', ('Impl',)),
    ('adversary', ('Adv',)),
    ('arbiter', ('Arb',)),
)

# Происхождение блока → столбец таблицы (инвариант 5); порядок — порядок столбцов.
ORIGIN_COLUMNS = (
    ('первичный', 'первичные'),
    ('дельта', 'дельта'),
    ('узкое-закрытие', 'узкое'),
    ('пропущен-ранее', 'пропущено'),
    ('повтор', 'повтор'),
)
ORIGIN_BY_VALUE = dict(ORIGIN_COLUMNS)

# Предмет агента — первый цифровой кластер длины ≥3 (инвариант 6).
SUBJECT_RX = re.compile(r'\d{3,}')
# Номер вызова — ВЕДУЩИЙ цифровой кластер значения поля «вызов=» (инвариант 1):
# живые формы «N/M», «N/M (пояснение)», «N», «N (пояснение)».
LEADING_NUMBER_RX = re.compile(r'^\s*(\d+)')
# Серия вызова — текст в скобках поля «фаза=» (пусто — основная серия).
SERIES_RX = re.compile(r'\(([^)]*)\)')
REGISTRY_RX = re.compile(r'^(\d{3})\s*→')
VERDICT_NAME_RX = re.compile(r'^contracts-(\d{3})-')


def normalize_subject(value):
    """Номер предмета без ведущих нулей («0301» → «301», «000» → «0»)."""
    return value.lstrip('0') or '0'


def role_of(agent_name):
    """Роль агента по префиксу имени файла; None — роль вне замкнутого алфавита."""
    for role, prefixes in ROLE_PREFIXES:
        for prefix in prefixes:
            if agent_name.startswith(prefix):
                return role
    return None


def subject_of(agent_name):
    """Предмет агента по первому цифровому кластеру длины ≥3; None — «без предмета»."""
    match = SUBJECT_RX.search(agent_name)
    return normalize_subject(match.group(0)) if match else None


def parse_sud_line(line):
    """Учётная СУД-строка → поля (k=v); иначе None. Поля разделены «;»."""
    if not line.startswith('СУД: '):
        return None
    fields = {}
    for part in line[len('СУД: '):].split(';'):
        part = part.strip()
        if '=' in part:
            key, value = part.split('=', 1)
            fields[key.strip()] = value.strip()
    return fields


def lines_outside_fences(lines):
    """Строки вне ```-блоков: цитаты чужих СУД-строк вызовов не создают."""
    outside, fenced = [], False
    for line in lines:
        if line.startswith('```'):
            fenced = not fenced
            continue
        if not fenced:
            outside.append(line)
    return outside


def sud_call_key(fields):
    """Кортеж вызова (предмет, серия, номер); None — вызов неустановим.

    Неузнаваемая форма поля «вызов=» (нет ведущих цифр) даёт None — предмет
    помечается «не-установлен» (инварианты 1 и 3), а не теряется молча.
    """
    if 'предмет' not in fields or 'роль' not in fields or 'вызов' not in fields:
        return None
    number = LEADING_NUMBER_RX.match(fields['вызов'])
    if number is None:
        return None
    phase = fields.get('фаза', '')
    series_match = SERIES_RX.search(phase)
    series = series_match.group(1).strip() if series_match else ''
    return (normalize_subject(fields['предмет']), series, int(number.group(1)))


def read_registry(repo):
    """Предметы реестра (registry/contracts.tsv); None — реестра нет (rc 2)."""
    registry = repo / 'registry' / 'contracts.tsv'
    if not registry.is_file():
        return None
    subjects = []
    for line in registry.read_text(encoding='utf-8').splitlines():
        match = REGISTRY_RX.match(line)
        if match:
            subjects.append(normalize_subject(match.group(1)))
    return subjects


def read_blocks(lines):
    """Блоки «БЛОКИРУЕТ …»: происхождение и класс (инвариант 5)."""
    blocks = []
    current = None
    for line in lines:
        if line.startswith('БЛОКИРУЕТ'):
            current = {'origin': None, 'klass': None}
            blocks.append(current)
        elif line.startswith('#'):
            current = None
        elif current is not None:
            text = line.strip()
            if text.startswith('ПРОИСХОЖДЕНИЕ:'):
                current['origin'] = text[len('ПРОИСХОЖДЕНИЕ:'):].strip()
            elif text.startswith('КЛАСС:'):
                current['klass'] = text[len('КЛАСС:'):].strip()
    return blocks


def read_verdicts(repo):
    """Вердикты критика: предмет файла, исход, учётная СУД-строка, блоки."""
    verdicts = []
    verdict_dir = repo / 'verdicts' / 'critic'
    if not verdict_dir.is_dir():
        return verdicts
    for path in sorted(verdict_dir.glob('contracts-*.md')):
        name_match = VERDICT_NAME_RX.match(path.name)
        if not name_match:
            continue
        lines = path.read_text(encoding='utf-8').splitlines()
        ishod = next((line.strip() for line in lines if line.strip()), None)
        sud = None
        for line in lines_outside_fences(lines):
            fields = parse_sud_line(line.strip())
            if fields is not None:
                sud = fields
                break
        blocks = read_blocks(lines) if ishod == 'FAIL' else []
        verdicts.append({'subject': normalize_subject(name_match.group(1)),
                         'ishod': ishod, 'sud': sud, 'blocks': blocks})
    return verdicts


def read_handoff_sud(repo):
    """СУД-строки HANDOFF.md вне код-цитат: все вызовы, включая обрывы."""
    calls = {}
    handoff = repo / 'HANDOFF.md'
    if not handoff.is_file():
        return calls
    for line in lines_outside_fences(handoff.read_text(encoding='utf-8').splitlines()):
        fields = parse_sud_line(line.strip())
        if fields is None or fields.get('роль') != 'critic':
            continue
        key = sud_call_key(fields)
        if key is None:
            continue
        calls.setdefault(key, {'verdict': None, 'n': key[2], 'seria': key[1]})
    return calls


def handoff_unparsed(repo):
    """Предметы, чья критик-СУД в HANDOFF неузнаваема: именованная потеря."""
    unparsed = set()
    handoff = repo / 'HANDOFF.md'
    if not handoff.is_file():
        return unparsed
    for line in lines_outside_fences(handoff.read_text(encoding='utf-8').splitlines()):
        fields = parse_sud_line(line.strip())
        if fields is None or fields.get('роль') != 'critic':
            continue
        if 'предмет' in fields and sud_call_key(fields) is None:
            unparsed.add(normalize_subject(fields['предмет']))
    return unparsed


def collect_calls(repo):
    """(вызовы по кортежам, предметы без привязки) из вердиктов и HANDOFF.

    Дубль-материализация одного вызова несколькими файлами считается один раз;
    вердикт без учётной СУД-строки и неузнаваемая слово-форма «вызов=» дают
    предмет в «не-установлен» (инварианты 1–3).
    """
    calls = read_handoff_sud(repo)
    unparsed = handoff_unparsed(repo)
    for verdict in read_verdicts(repo):
        if verdict['sud'] is None:
            unparsed.add(verdict['subject'])
            continue
        key = sud_call_key(verdict['sud'])
        if key is None:
            unparsed.add(verdict['subject'])
            continue
        entry = calls.setdefault(key, {'verdict': None, 'n': key[2], 'seria': key[1]})
        if entry['verdict'] is None and verdict['ishod'] in ('FAIL', 'accept'):
            entry['verdict'] = {'ishod': verdict['ishod'], 'blocks': verdict['blocks']}
    return calls, unparsed


def session_start(dirname):
    """Имя каталога сессии «YYYY-MM-DDTHH-MM-SS-…Z» → «YYYY-MM-DDTHH:MM:SSZ»."""
    stamp = dirname.split('_')[0]
    if len(stamp) >= 19 and stamp[4] == '-' and stamp[10] == 'T':
        return '%sT%s:%s:%sZ' % (stamp[:10], stamp[11:13], stamp[14:16], stamp[17:19])
    return None


def iter_journals(root, since, until):
    """Файлы журналов в окне: (путь, роль, предмет); None — каталога журналов нет.

    Окно по началу сессии: «--s» включительно, «--do» исключительно (инвариант 6).
    """
    if not root.is_dir():
        return None
    files = []
    for cwd_dir in sorted(root.iterdir()):
        if not cwd_dir.is_dir():
            continue
        for session_dir in sorted(cwd_dir.iterdir()):
            if not session_dir.is_dir():
                continue
            start = session_start(session_dir.name)
            if start is None:
                continue
            if since is not None and start < since:
                continue
            if until is not None and start >= until:
                continue
            for path in sorted(session_dir.glob('*.jsonl')):
                files.append((path, role_of(path.stem), subject_of(path.stem)))
    return files


def measure_agent(path):
    """(вызовы, токены, одиночные, хвост) по журналу агента.

    Вызов модели — запись message с role=assistant и usage; токены — totalTokens;
    одиночный вызов — ровно один toolCall; правка — toolCall edit/write; хвост —
    токены сообщений после ПОСЛЕДНЕЙ правки (агент без правок — весь расход).
    """
    messages = []
    with open(path, encoding='utf-8') as stream:
        for line in stream:
            try:
                record = json.loads(line)
            except ValueError:
                continue  # неконсистентная строка — пропуск без падения (инвариант 8)
            if record.get('type') != 'message':
                continue
            message = record.get('message', {})
            if message.get('role') != 'assistant' or not isinstance(message.get('usage'), dict):
                continue
            tokens = int(message['usage'].get('totalTokens') or 0)
            tools = [part for part in message.get('content', [])
                     if isinstance(part, dict) and part.get('type') == 'toolCall']
            edited = any(tool.get('name') in ('edit', 'write') for tool in tools)
            messages.append((tokens, len(tools) == 1, edited))
    last_edit = -1
    for index, (_, _, edited) in enumerate(messages):
        if edited:
            last_edit = index
    tail = sum(tokens for tokens, _, _ in messages[last_edit + 1:])
    return (len(messages),
            sum(tokens for tokens, _, _ in messages),
            sum(1 for _, single, _ in messages if single),
            tail)


def new_measure():
    """Пустая мера агента/предмета."""
    return {'calls': 0, 'tokens': 0, 'single': 0, 'tail': 0}


def new_role_measure():
    """Пустая мера роли: свои счётчики и меры по предметам."""
    measure = new_measure()
    measure['by_subject'] = {}
    return measure


def add_measure(measure, calls, tokens, single, tail):
    """Добавить меры агента в накопитель."""
    measure['calls'] += calls
    measure['tokens'] += tokens
    measure['single'] += single
    measure['tail'] += tail


def journal_measures(files):
    """Меры по журналам: (роль → мера с мерами по предметам, число просмотренных записей)."""
    agents = {}
    reviewed = 0
    for path, role, subject in files:
        if role is None:
            continue
        calls, tokens, single, tail = measure_agent(path)
        if calls == 0:
            continue
        reviewed += calls
        role_measure = agents.setdefault(role, new_role_measure())
        add_measure(role_measure, calls, tokens, single, tail)
        if subject is not None:
            subject_measure = role_measure['by_subject'].setdefault(subject, new_measure())
            add_measure(subject_measure, calls, tokens, single, tail)
    return agents, reviewed


def pct(part, whole):
    """Доля в процентах; пустой знаменатель — 0.0% (не деление на ноль)."""
    return '0.0%' if whole == 0 else '%.1f%%' % (100.0 * part / whole)


def journal_cells(architect, critic):
    """Журнальные столбцы строки: токены/вызовы architect и critic, доли."""
    return [str(architect['tokens']), str(architect['calls']),
            str(critic['tokens']), str(critic['calls']),
            pct(architect['single'], architect['calls']),
            pct(architect['tail'], architect['tokens'])]


def judge_cells(subject_calls):
    """Судейские столбцы предмета: вызовы, исходы, блоки (инварианты 1–5)."""
    fail = sum(1 for entry in subject_calls
               if entry['verdict'] and entry['verdict']['ishod'] == 'FAIL')
    accept = sum(1 for entry in subject_calls
                 if entry['verdict'] and entry['verdict']['ishod'] == 'accept')
    obryv = sum(1 for entry in subject_calls if entry['verdict'] is None)
    main_series = [entry for entry in subject_calls if entry['seria'] == '']
    if main_series:
        last = max(main_series, key=lambda entry: entry['n'])
        ishod = last['verdict']['ishod'] if last['verdict'] else 'обрыв'
    else:
        ishod = '-'
    origins = {column: 0 for _origin, column in ORIGIN_COLUMNS}
    origin_unknown = 0
    classes = {}
    class_unknown = 0
    for entry in subject_calls:
        if not entry['verdict']:
            continue
        for block in entry['verdict']['blocks']:
            column = ORIGIN_BY_VALUE.get(block['origin'])
            if column is None:
                origin_unknown += 1
            else:
                origins[column] += 1
            if block['klass']:
                classes[block['klass']] = classes.get(block['klass'], 0) + 1
            else:
                class_unknown += 1
    blocks = sum(origins.values()) + origin_unknown
    classes_cell = ','.join('%s:%d' % (name, classes[name]) for name in sorted(classes)) \
        if classes else '-'
    return ([str(len(subject_calls)), str(fail), str(accept), str(obryv), ishod, str(blocks)]
            + [str(origins[column]) for _origin, column in ORIGIN_COLUMNS]
            + [str(origin_unknown), classes_cell, str(class_unknown)])


def total_calls(established):
    """Сумма вызовов по установленным строкам."""
    return sum(int(row[1]) for row in established)


def build_table(repo, zhurnaly, since, until, predmety):
    """Таблица мер связки по реестру; 0 — напечатана, 1 — пусто, 2 — нет среды."""
    subjects = read_registry(repo)
    if subjects is None:
        print('НЕТ_РЕЕСТРА: registry/contracts.tsv', file=sys.stderr)
        return 2
    files = iter_journals(zhurnaly, since, until)
    if files is None:
        print('НЕТ_ЖУРНАЛОВ: каталог сессий не существует', file=sys.stderr)
        return 2
    agents, reviewed = journal_measures(files)
    if reviewed == 0:
        print('ПУСТАЯ_ВЫБОРКА: в окне нет ни одной записи журналов', file=sys.stderr)
        return 1
    calls, unparsed = collect_calls(repo)
    architect = agents.get('architect', new_role_measure())
    critic = agents.get('critic', new_role_measure())
    rows = []
    for subject in sorted(subjects, key=int):
        if predmety is not None and not re.search(predmety, subject):
            continue
        subject_calls = [entry for (subj, _series, _number), entry in calls.items()
                         if subj == subject]
        has_agents = (subject in architect['by_subject'] or subject in critic['by_subject'])
        if not subject_calls and subject not in unparsed and not has_agents:
            continue
        architect_subject = architect['by_subject'].get(subject, new_measure())
        critic_subject = critic['by_subject'].get(subject, new_measure())
        if subject in unparsed:
            judge = ['не-установлен'] * JUDGE_COLUMNS
        else:
            judge = judge_cells(subject_calls)
        rows.append([subject] + judge + journal_cells(architect_subject, critic_subject))
    established = [row for row in rows if row[1] != 'не-установлен']
    established_subjects = {row[0] for row in established}
    out = [HEADER] + ['\t'.join(row) for row in rows]
    total_row = (['ИТОГО',
                  str(sum(int(row[1]) for row in established)),
                  str(sum(int(row[2]) for row in established)),
                  str(sum(int(row[3]) for row in established)),
                  str(sum(int(row[4]) for row in established)),
                  '-',
                  str(sum(int(row[6]) for row in established))]
                 + [str(sum(int(row[index]) for row in established)) for index in range(7, 13)]
                 + ['-', '-',
                    str(architect['tokens']), str(architect['calls']),
                    str(critic['tokens']), str(critic['calls']),
                    pct(architect['single'], architect['calls']),
                    pct(architect['tail'], architect['tokens'])])
    out.append('\t'.join(total_row))
    average = '%.1f' % (total_calls(established) / len(established)) if established else '-'
    accept_le2 = sum(1 for (subject, _series, number), entry in calls.items()
                     if subject in established_subjects and entry['seria'] == ''
                     and entry['verdict'] and entry['verdict']['ishod'] == 'accept'
                     and number <= 2)
    four_plus = sum(1 for row in established if int(row[1]) >= 4)
    out.append('МЕР\tсреднее_вызовов=%s\taccept_do_vtorogo=%d/%d\tchetyre_plus=%d'
               % (average, accept_le2, len(established), four_plus))
    print('\n'.join(out))
    print('просмотрено: записей_журналов=%d' % reviewed, file=sys.stderr)
    return 0


def main(argv=None):
    """Точка входа: разбор аргументов и сборка таблицы."""
    parser = argparse.ArgumentParser(prog='zamer_svyazki')
    parser.add_argument('--repo', required=True)
    parser.add_argument('--zhurnaly', required=True)
    parser.add_argument('--s', default=None)
    parser.add_argument('--do', default=None)
    parser.add_argument('--predmety', default=None)
    args = parser.parse_args(argv)
    repo = Path(args.repo)
    if not repo.is_dir():
        print('НЕТ_РЕПО: %s' % repo, file=sys.stderr)
        return 2
    since = args.s + 'Z' if args.s and not args.s.endswith('Z') else args.s
    until = args.do + 'Z' if args.do and not args.do.endswith('Z') else args.do
    return build_table(repo, Path(args.zhurnaly), since, until, args.predmety)


if __name__ == '__main__':
    sys.exit(main())
