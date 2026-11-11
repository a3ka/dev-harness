#!/usr/bin/env python3
"""Эталон предмета 190 «Л6 — замер связки» (контракт-канон семантик мер).

ЕДИНЫЙ источник заголовка таблицы и семантик чтения: инварианты контракта 190.
Эталон читает те же настоящие форматы, что и реализация implementer:
  --repo <корень>      дерево харнесса: verdicts/critic/*.md, HANDOFF.md, registry/contracts.tsv
  --zhurnaly <корень>  корень сессий: <sanitized-cwd>/<session-dir>/<Агент>.jsonl
  --s <ISO>/--do <ISO> окно по началу сессии (имя каталога YYYY-MM-DDTHH-MM-SS-…Z)
  --predmety <ERE>     фильтр номеров предметов реестра
Коды возврата: 0 — таблица, stderr несёт «просмотрено: записей_журналов=N» (N>0;
инвариант 8: обход печатает число просмотренного и отказывает на нуле);
1 — ПУСТАЯ_ВЫБОРКА; 2 — НЕТ_ЖУРНАЛОВ/НЕТ_РЕЕСТРА/НЕТ_PYTHON.
"""
import argparse
import json
import re
import sys
from pathlib import Path

HEADER = ("предмет\tвызовы\tfail\taccept\tобрывы\tисход\tблоки\tпервичные\tдельта\tузкое\t"
          "пропущено\tповтор\tпроисх_не_уст\tклассы\tклассы_не_уст\tarch_токены\tarch_вызовы\t"
          "crit_токены\tcrit_вызовы\tодиночные_доля\tхвост_доля")

ROLE_PREFIXES = [('architect', ('Architect', 'Arch')), ('critic', ('Critic', 'Crit')),
                 ('reviewer', ('Rev',)), ('implementer', ('Impl',)),
                 ('adversary', ('Adv',)), ('arbiter', ('Arb',))]

ORIGIN_MAP = {'первичный': 'первичные', 'дельта': 'дельта', 'узкое-закрытие': 'узкое',
              'пропущен-ранее': 'пропущено', 'повтор': 'повтор'}
ORIGIN_ORDER = ['первичные', 'дельта', 'узкое', 'пропущено', 'повтор']

SUBJECT_RX = re.compile(r'\d{3,}')
VYZOV_RX = re.compile(r'^\s*(\d+)')



def role_of(agent_name):
    for role, prefixes in ROLE_PREFIXES:
        for p in prefixes:
            if agent_name.startswith(p):
                return role
    return None


def subject_of(agent_name):
    m = SUBJECT_RX.search(agent_name)
    return m.group(0).lstrip('0') or '0' if m else None


def parse_sud_line(line):
    """СУД-строка → dict полей; поля разделены ';', 'k=v'."""
    if not line.startswith('СУД: '):
        return None
    fields = {}
    for part in line[len('СУД: '):].split(';'):
        part = part.strip()
        if '=' in part:
            k, v = part.split('=', 1)
            fields[k.strip()] = v.strip()
    return fields


def lines_outside_fences(lines):
    """Строки вне ```-блоков: цитаты чужих СУД-строк учётной грамматикой не читаются."""
    out, fenced = [], False
    for line in lines:
        if line.startswith('```'):
            fenced = not fenced
            continue
        if not fenced:
            out.append(line)
    return out


def sud_call_key(fields):
    """(предмет, серия, номер) — вызов судьи; серия из скобок фазы, пусто = основная.

    Номер — ВЕДУЩИЙ цифровой кластер значения поля вызов=: живые формы дерева
    «N/M», «N/M (пояснение)», «N», «N (пояснение)» (перечислены командой в
    «Существующем» контракта). Ведущих цифр нет (слово-форма: «scoped»,
    «по-перечню-арбитра») → None — вызов неустановим; предмет при этом
    помечается не-установлен (collect_calls), а не теряется молча."""
    if 'предмет' not in fields or 'роль' not in fields or 'вызов' not in fields:
        return None
    m = VYZOV_RX.match(fields['вызов'])
    if m is None:
        return None
    n = int(m.group(1))
    faza = fields.get('фаза', '')
    mm = re.search(r'\(([^)]*)\)', faza)
    seria = mm.group(1).strip() if mm else ''
    return (fields['предмет'].lstrip('0') or '0', seria, n)


def read_registry(repo):
    """Реестр предметов: строки 'NNN → sha' в registry/contracts.tsv."""
    subjects = []
    reg = repo / 'registry' / 'contracts.tsv'
    if not reg.is_file():
        return None
    for line in reg.read_text(encoding='utf-8').splitlines():
        m = re.match(r'^(\d{3})\s*→', line)
        if m:
            subjects.append(m.group(1).lstrip('0') or '0')
    return subjects


def read_verdicts(repo):
    """Вердикты: список dict(предмет_файла, исход, суд_fields|None, блоки)."""
    verdicts = []
    vdir = repo / 'verdicts' / 'critic'
    if not vdir.is_dir():
        return verdicts
    for f in sorted(vdir.glob('contracts-*.md')):
        m = re.match(r'^contracts-(\d{3})-', f.name)
        if not m:
            continue
        subject = m.group(1).lstrip('0') or '0'
        lines = f.read_text(encoding='utf-8').splitlines()
        ishod = None
        for line in lines:
            if line.strip():
                ishod = line.strip()
                break
        sud = None
        for line in lines_outside_fences(lines):
            fields = parse_sud_line(line.strip())
            if fields is not None:
                sud = fields
                break
        blocks = []
        if ishod == 'FAIL':
            cur = None
            for line in lines:
                if line.startswith('БЛОКИРУЕТ'):
                    cur = {'origin': None, 'klass': None}
                    blocks.append(cur)
                elif line.startswith('#'):
                    cur = None
                elif cur is not None:
                    s = line.strip()
                    if s.startswith('ПРОИСХОЖДЕНИЕ:'):
                        cur['origin'] = s[len('ПРОИСХОЖДЕНИЕ:'):].strip()
                    elif s.startswith('КЛАСС:'):
                        cur['klass'] = s[len('КЛАСС:'):].strip()
        verdicts.append({'subject': subject, 'ishod': ishod, 'sud': sud, 'blocks': blocks})
    return verdicts


def read_handoff_sud(repo):
    """СУД-строки HANDOFF.md вне код-цитат (все вызовы, включая обрывы без вердикта)."""
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
    """Предметы, чья критик-СУД в HANDOFF неузнаваема (слово-форма вызова=):
    именованная потеря — предмет уходит в не-установлен, а не выпадает молча."""
    bad = set()
    handoff = repo / 'HANDOFF.md'
    if not handoff.is_file():
        return bad
    for line in lines_outside_fences(handoff.read_text(encoding='utf-8').splitlines()):
        fields = parse_sud_line(line.strip())
        if fields is None or fields.get('роль') != 'critic':
            continue
        if 'предмет' in fields and sud_call_key(fields) is None:
            bad.add(fields['предмет'].lstrip('0') or '0')
    return bad



def session_start(dirname):
    """Имя каталога сессии 'YYYY-MM-DDTHH-MM-SS-…Z_uuid' → 'YYYY-MM-DDTHH:MM:SSZ'."""
    d = dirname.split('_')[0]
    if len(d) >= 19 and d[4] == '-' and d[10] == 'T':
        return d[:10] + 'T' + d[11:13] + ':' + d[14:16] + ':' + d[17:19] + 'Z'
    return None


def iter_journals(root, since, until):
    """Файлы агентов в окне: (путь, роль, предмет)."""
    if not root.is_dir():
        return None
    out = []
    for cwd_dir in sorted(root.iterdir()):
        if not cwd_dir.is_dir():
            continue
        for sess_dir in sorted(cwd_dir.iterdir()):
            if not sess_dir.is_dir():
                continue
            start = session_start(sess_dir.name)
            if start is None:
                continue
            if since is not None and start < since:
                continue
            if until is not None and start >= until:
                continue
            for f in sorted(sess_dir.glob('*.jsonl')):
                out.append((f, role_of(f.stem), subject_of(f.stem)))
    return out
def collect_calls(repo):
    """(предмет → [(номер, серия, вердикт|None)]) из вердиктов + HANDOFF; unpinned —
    без СУД или с неузнаваемой слово-формой вызова= (вердикт и HANDOFF одинаково)."""
    calls = read_handoff_sud(repo)
    unpinned = handoff_unparsed(repo)
    for v in read_verdicts(repo):
        if v['sud'] is None:
            unpinned.add(v['subject'])
            continue
        key = sud_call_key(v['sud'])
        if key is None:
            unpinned.add(v['subject'])
            continue
        entry = calls.setdefault(key, {'verdict': None})
        entry.setdefault('n', key[2])
        entry.setdefault('seria', key[1])
        if entry['verdict'] is None and v['ishod'] in ('FAIL', 'accept'):
            entry['verdict'] = {'ishod': v['ishod'], 'blocks': v['blocks']}
    return calls, unpinned


def measure_agent(path):
    """(вызовы, токены, одиночные, хвост) по журналу агента."""
    msgs = []
    for line in open(path, encoding='utf-8'):
        try:
            r = json.loads(line)
        except ValueError:
            continue
        if r.get('type') != 'message':
            continue
        m = r.get('message', {})
        if m.get('role') != 'assistant' or not isinstance(m.get('usage'), dict):
            continue
        u = m['usage']
        tok = int(u.get('totalTokens') or 0)
        tools = [c for c in m.get('content', []) if isinstance(c, dict) and c.get('type') == 'toolCall']
        is_edit = any(t.get('name') in ('edit', 'write') for t in tools)
        msgs.append((tok, len(tools) == 1, is_edit))
    last_edit = -1
    for i, (_, _, ie) in enumerate(msgs):
        if ie:
            last_edit = i
    tail = sum(t for t, _, _ in msgs[last_edit + 1:])
    return len(msgs), sum(t for t, _, _ in msgs), sum(1 for _, s, _ in msgs if s), tail


def pct(part, whole):
    return '0.0%' if whole == 0 else '%.1f%%' % (100.0 * part / whole)

def journal_measures(files):
    """Меры по журналам: (роль → {calls, tokens, single, tail, by_subject}, просмотрено)."""
    agents = {}
    reviewed = 0
    for f, role, subj in files:
        if role is None:
            continue
        calls, tokens, single, tail = measure_agent(f)
        if calls == 0:
            continue
        reviewed += calls
        st = agents.setdefault(role, {'calls': 0, 'tokens': 0, 'single': 0, 'tail': 0,
                                      'by_subject': {}})
        st['calls'] += calls
        st['tokens'] += tokens
        st['single'] += single
        st['tail'] += tail
        if subj is not None:
            ss = st['by_subject'].setdefault(subj, {'calls': 0, 'tokens': 0, 'single': 0, 'tail': 0})
            ss['calls'] += calls
            ss['tokens'] += tokens
            ss['single'] += single
            ss['tail'] += tail
    return agents, reviewed

def build_table(repo, zhurnaly, since, until, predmety):
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
    calls, unpinned = collect_calls(repo)
    rows = []
    arch = agents.get('architect', {'calls': 0, 'tokens': 0, 'single': 0, 'tail': 0, 'by_subject': {}})
    crit = agents.get('critic', {'calls': 0, 'tokens': 0, 'single': 0, 'tail': 0, 'by_subject': {}})
    for subj in sorted(subjects, key=int):
        if predmety is not None and not re.search(predmety, subj):
            continue
        subj_calls = [v for (s, _ser, _n), v in calls.items() if s == subj]
        has_agents = any(subj in st['by_subject'] for st in (arch, crit))
        if not subj_calls and subj not in unpinned and not has_agents:
            continue
        if subj in unpinned:
            a = arch['by_subject'].get(subj, {'tokens': 0, 'calls': 0, 'single': 0, 'tail': 0})
            c = crit['by_subject'].get(subj, {'tokens': 0, 'calls': 0})
            rows.append([subj, 'не-установлен', 'не-установлен', 'не-установлен', 'не-установлен',
                         'не-установлен', 'не-установлен', 'не-установлен', 'не-установлен',
                         'не-установлен', 'не-установлен', 'не-установлен', 'не-установлен',
                         'не-установлен', 'не-установлен',
                         str(a['tokens']), str(a['calls']), str(c['tokens']), str(c['calls']),
                         pct(a['single'], a['calls']), pct(a['tail'], a['tokens'])])
            continue
        fail = sum(1 for v in subj_calls if v['verdict'] and v['verdict']['ishod'] == 'FAIL')
        accept = sum(1 for v in subj_calls if v['verdict'] and v['verdict']['ishod'] == 'accept')
        obryv = sum(1 for v in subj_calls if v['verdict'] is None)
        main_series = [v for v in subj_calls if v['seria'] == '']
        if main_series:
            last_entry = max(main_series, key=lambda v: v['n'])
            last = last_entry['verdict']['ishod'] if last_entry['verdict'] else 'обрыв'
        else:
            last = '-'
        origins = {k: 0 for k in ORIGIN_ORDER}
        orig_neust = klass_neust = 0
        klasses = {}
        for v in subj_calls:
            if not v['verdict']:
                continue
            for b in v['verdict']['blocks']:
                if b['origin'] in ORIGIN_MAP:
                    origins[ORIGIN_MAP[b['origin']]] += 1
                else:
                    orig_neust += 1
                if b['klass']:
                    klasses[b['klass']] = klasses.get(b['klass'], 0) + 1
                else:
                    klass_neust += 1
        blocks = sum(origins.values()) + orig_neust
        klass_str = ','.join('%s:%d' % (k, klasses[k]) for k in sorted(klasses)) if klasses else '-'
        a = arch['by_subject'].get(subj, {'tokens': 0, 'calls': 0, 'single': 0, 'tail': 0})
        c = crit['by_subject'].get(subj, {'tokens': 0, 'calls': 0})
        rows.append([subj, str(len(subj_calls)), str(fail), str(accept), str(obryv), last,
                     str(blocks)] + [str(origins[k]) for k in ORIGIN_ORDER] +
                    [str(orig_neust), klass_str, str(klass_neust),
                     str(a['tokens']), str(a['calls']), str(c['tokens']), str(c['calls']),
                     pct(a['single'], a['calls']), pct(a['tail'], a['tokens'])])
    out = [HEADER] + ['\t'.join(r) for r in rows]
    total_calls = sum(int(r[1]) for r in rows if r[1] != 'не-установлен')
    established = [r for r in rows if r[1] != 'не-установлен']
    row_subjects = {r[0] for r in established}
    accept_le2 = sum(1 for (s, _ser, _n), v in calls.items()
                     if s in row_subjects and v['seria'] == '' and v['verdict']
                     and v['verdict']['ishod'] == 'accept' and v['n'] <= 2)
    four_plus = sum(1 for r in established if int(r[1]) >= 4)
    out.append('ИТОГО\t%d\t%d\t%d\t%d\t-\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t-\t-\t%d\t%d\t%d\t%d\t%s\t%s' % (
        total_calls,
        sum(int(r[2]) for r in established), sum(int(r[3]) for r in established),
        sum(int(r[4]) for r in established),
        sum(int(r[6]) for r in established),
        sum(int(r[7]) for r in established), sum(int(r[8]) for r in established),
        sum(int(r[9]) for r in established), sum(int(r[10]) for r in established),
        sum(int(r[11]) for r in established), sum(int(r[12]) for r in established),
        arch['tokens'], arch['calls'], crit['tokens'], crit['calls'],
        pct(arch['single'], arch['calls']), pct(arch['tail'], arch['tokens'])))
    avg = ('%.1f' % (total_calls / len(established))) if established else '-'
    out.append('МЕР\tсреднее_вызовов=%s\taccept_do_vtorogo=%d/%d\tchetyre_plus=%d' % (
        avg, accept_le2, len(established), four_plus))
    print('\n'.join(out))
    print('просмотрено: записей_журналов=%d' % reviewed, file=sys.stderr)
    return 0


def main(argv=None):
    p = argparse.ArgumentParser(prog='zamer_svyazki')
    p.add_argument('--repo', required=True)
    p.add_argument('--zhurnaly', required=True)
    p.add_argument('--s', default=None)
    p.add_argument('--do', default=None)
    p.add_argument('--predmety', default=None)
    a = p.parse_args(argv)
    repo = Path(a.repo)
    if not repo.is_dir():
        print('НЕТ_РЕПО: %s' % repo, file=sys.stderr)
        return 2
    since = a.s + 'Z' if a.s and not a.s.endswith('Z') else a.s
    until = a.do + 'Z' if a.do and not a.do.endswith('Z') else a.do
    return build_table(repo, Path(a.zhurnaly), since, until, a.predmety)


if __name__ == '__main__':
    sys.exit(main())
