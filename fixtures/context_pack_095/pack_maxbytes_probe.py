#!/usr/bin/env python3
"""Б-4: наблюдения публичного make_task CLI; ожидания живут в памяти до вызова."""
import json
import re
import subprocess
import sys
from pathlib import Path

subject, world, branch = sys.argv[1:]
w = Path(world)
r = w / 'repo'
profile = r / 'harness.project.json'
contract = r / 'contracts/777-toy.md'
original_profile = json.loads(profile.read_bytes())
original_contract = contract.read_text()
manifest = r / '.omp/context/777.tsv'


def configure(raw=None):
    p = dict(original_profile)
    if raw is not None:
        # Сохраняем именно JSON-лексему (1e5 не превращается в 100000).
        text = json.dumps(p, ensure_ascii=False)
        text = text[:-1] + ', "pack": ' + raw + '}'
    else:
        text = json.dumps(p, ensure_ascii=False)
    profile.write_text(text)


def cap(value):
    configure('{"maxBytes":' + str(value) + '}')


def context(padding):
    contract.write_text(original_contract.replace(
        'КОНТЕКСТ: модуль toy, сосед один', 'КОНТЕКСТ: ' + 'x' * padding))


def invoke(brief=False):
    before = (profile.read_bytes(), contract.read_bytes())
    if manifest.exists():
        manifest.unlink()
    args = ['bash', subject, '--repo', str(r), '--role',
            'orchestrator' if brief else 'architect', '--model-trace', str(w / 'trace.tsv')]
    args += ['--kind', 'brief'] if brief else ['--contract', '777']
    result = subprocess.run(args, capture_output=True, timeout=30)
    assert before == (profile.read_bytes(), contract.read_bytes()), 'субъект изменил вход'
    return result


def section(out, name):
    start = ('=== ' + name + ' ===\n').encode()
    assert out.count(start) == 1, 'нет единственной секции ' + name
    return out.split(start, 1)[1].split(b'=== ', 1)[0]


def good(limit, brief=False):
    expected_context = next(line.encode() for line in contract.read_text().splitlines()
                            if line.startswith('КОНТЕКСТ:'))
    result = invoke(brief)
    assert result.returncode == 0, f'успех rc={result.returncode}: {result.stderr.decode()}'
    out = result.stdout
    assert out.startswith(b'=== make_task '), 'пак не выдан'
    vk = len(out.split(b'=== MANIFEST ===\n', 1)[0])
    assert b'=== MANIFEST ===\n' in out, 'нет манифеста'
    assert section(out, 'BUDGET') == f'BUDGET: vklejka={vk}/{limit}\n'.encode(), 'BUDGET не равен фактическим байтам/капу'
    assert vk <= limit, 'успех сверх капа'
    if not brief:
        assert expected_context in section(out, 'CONTEXT').splitlines(), 'вклейка усечена'
        assert manifest.is_file() and manifest.stat().st_size, 'манифест не выдан'
    return vk, out


def refused(reason, exact=True, brief=False):
    result = invoke(brief)
    assert result.returncode == 1, f'отказ rc={result.returncode}: {result.stderr.decode()}'
    assert result.stdout == b'', 'отказ выдал пак'
    assert not manifest.exists(), 'отказ выдал манифест'
    lines = result.stderr.decode().splitlines()
    assert any((line == reason if exact else reason in line) for line in lines), f'нет причины {reason!r}: {lines}'
    return lines


def raised():
    context(91445)
    contract.write_text(contract.read_text().replace(
        '- scripts/toy.sh — живой код', '- scripts/toy.sh — живой код\n' + 'y' * 10000))
    cap(130000)
    vk, _ = good(130000)
    assert 100000 <= vk <= 121000, f'не испытан большой пак: {vk}'
    configure()
    refused(f'ОТКАЗ: режь задачу: {vk} > 40000')
    cap(40000)
    refused(f'ОТКАЗ: режь задачу: {vk} > 40000')
    cap(145000)
    good(145000)
    print(f'B4 raised VK={vk} MAX=130000; default/explicit40000 refused')


def boundary():
    for limit in (40000, 130000):
        cap(limit)
        context(1)
        base, _ = good(limit)
        padding = 1 + limit - base
        assert padding > 0
        context(padding)
        vk, _ = good(limit)
        assert vk == limit, f'граница не достигнута: {vk} != {limit}'
        context(padding + 1)
        refused(f'ОТКАЗ: режь задачу: {limit + 1} > {limit}')
        print(f'B4 boundary VK={limit} accepted; VK={limit + 1} refused')


def values():
    invalid = ('"130000"', '130000.5', '1e5', '0', '-1', '30000',
               '39999', '1000001', '""', 'null')
    for raw in invalid:
        configure('{"maxBytes":' + raw + '}')
        refused('pack.maxBytes', exact=False)
        cap(130000)
        good(130000)
        print(f'B4 value {raw} refused; valid repeat accepted')
    # М-0 (вердикт Rev095B4, Б-1): неизвестный ключ внутри pack — ПРЕДУПРЕЖДЕНИЕ,
    # не отказ: rc 0, пак с BUDGET по объявленному капу. make_task прячет stderr
    # резолвера при успехе (make_task.sh:569-572), поэтому строка предупреждения
    # судится прямым вызовом резолвера клеткой red_pack_maxbytes_merged.sh.
    configure('{"maxBytes":130000,"foo":1}')
    good(130000)
    for raw in ('{}', None):
        configure(raw)
        good(40000)
    cap(1000000)
    good(1000000)
    print('B4 values unknown key warned (M-0) and pack issued by declared cap; absent/empty-pack default; upper bound accepted')


def brief():
    # 160 полных WORK-строк; каждая короче существующего капа 480 символов.
    subjects = {}
    plan = r / 'registry/plan.tsv'
    with plan.open('a') as stream:
        for n in range(500, 660):
            text = f'item-{n}-' + 'z' * 400
            subjects[n] = text
            (r / f'contracts/{n}-fat.md').write_text(f'# Контракт {n}\n\n## Предмет\n\n{text}\n')
            stream.write(f'{n}\t1\tдо V-2\t-\ttoy\ttrack\n')
    cap(130000)
    vk, out = good(130000, brief=True)
    work = section(out, 'WORK').decode().splitlines()
    assert not any(line.startswith('WORK: за бюджетом брифа:') for line in work), 'WORK преждевременно усечён'
    assert 39800 < len(section(out, 'WORK')) < 129800, 'WORK не испытал старый порог'
    for n, text in subjects.items():
        assert f'WORK: {n} :: {text}' in work, f'WORK {n} потерян'
    # Ожидание хвоста снимается до следующего вызова.
    expected_total = sum(bool(re.match(r'^WORK: [0-9]+ :: ', line)) for line in work)
    for limit in (40000, 60000):
        cap(limit)
        _, small = good(limit, brief=True)
        rows = section(small, 'WORK').decode().splitlines()
        shown = sum(bool(re.match(r'^WORK: [0-9]+ :: ', line)) for line in rows)
        omitted = [re.fullmatch(r'WORK: за бюджетом брифа: ([0-9]+) строк; .*', line) for line in rows]
        counts = [int(m[1]) for m in omitted if m]
        assert len(counts) == 1 and 0 < shown < expected_total, 'нет явного усечения WORK'
        assert shown + counts[0] == expected_total, 'нечестный счёт хвоста'
        kept = [line for line in rows if re.match(r'^WORK: [0-9]+ :: ', line)]
        body = small.split(b'=== MANIFEST ===\n')[0]
        tail_bytes = sum(len((line + '\n').encode()) for line in rows if line.startswith('WORK: за бюджетом'))
        before_tail = len(body) - tail_bytes
        next_line = next(line for line in work if re.match(r'^WORK: [0-9]+ :: ', line) and line not in kept)
        assert before_tail <= limit - 200 < before_tail + len((next_line + '\n').encode()), 'порог WORK не равен MAX-200'
    print(f'B4 brief VK={vk} full WORK; MAX=40000/60000 truncation at MAX-200')


try:
    {'raised': raised, 'boundary': boundary, 'values': values, 'brief': brief}[branch]()
except (AssertionError, subprocess.TimeoutExpired) as error:
    print(f'КРАСНО: pack-maxbytes/{branch}: {error}', file=sys.stderr)
    sys.exit(1)
