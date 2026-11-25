#!/usr/bin/env python3
"""Read-only source census: live highest frozen per subject, literal zone paths."""
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[3]
CONTRACT = ROOT / 'contracts/203-dver-brifa-arhitektury.md'


def git(*args):
    return subprocess.run(['git', '-C', str(ROOT), *args], check=True,
                          capture_output=True, text=True).stdout


def zones(text):
    return {(role, path) for role, body in re.findall(r'^ЗОНА (\w+): (.*)$', text, re.M)
            for path in body.split()}


def main():
    text = CONTRACT.read_text()
    latest = {}
    for tag in git('tag', '-l', 'frozen/contracts/*').splitlines():
        match = re.fullmatch(r'frozen/contracts/(\d{3})/(\d+)', tag)
        if match:
            number, version = match.groups()
            if int(version) > latest.get(number, (0, ''))[0]:
                latest[number] = (int(version), tag)
    found, checked = set(), 0
    for number, (_, tag) in sorted(latest.items()):
        if number == '203': continue
        names = [name for name in git('ls-tree', '-r', '--name-only', tag, 'contracts').splitlines()
                 if name.startswith('contracts/' + number + '-') and name.endswith('.md')]
        for name in names:
            checked += 1
            foreign = zones(git('show', tag + ':' + name))
            found.update((role, path, number) for role, path in zones(text)
                         if any(path == other and (role != author or role == 'implementer')
                                for author, other in foreign))
    if '--emit' in sys.argv:
        for role, path, number in sorted(found):
            reason = ('только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.'
                      if role == 'orchestrator' else
                      'только шов brief 203; прежние карты, pin, правила ролей и остальные двери сохранены.'
                      if role == 'implementer' else 'только новые артефакты 203; чужие файлы не меняются.')
            print(f'ПЕРЕСЕЧЕНИЕ {role}: {path} — {number} {reason}')
        return int(not checked)
    declared = set(re.findall(r'^ПЕРЕСЕЧЕНИЕ (\w+): ([^ ]+) — (\d{3}) ', text, re.M))
    missing = found - declared
    print(f'FROZEN={len(latest)} BLOBS={checked} OVERLAPS={len(found)} MISSING={len(missing)}')
    for row in sorted(missing): print('MISSING', *row)
    return int(not checked or bool(missing))


if __name__ == '__main__':
    raise SystemExit(main())
