#!/usr/bin/env python3
"""К-08: строгий контроль и адресные мутации настоящего хука (Н-39).

Запускать только на безопасном чистом клоне, как stancija_odin_agent_140.sh.
Дверь/станция/конфиг копируются без изменений; единственная дельта субъекта —
строка нормализации. Каждая привязанная клетка обязана стать красной сама.
"""
import re
import shutil
import subprocess
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
STATION = Path('fixtures/workshop_project/odin_agent_140/stancija_odin_agent_140.sh')
HOOK = Path('.omp/extensions/spawn-guard.ts')
ANCHOR = '      isolated: o.isolated === true,'
NONBOOLEAN = ('string', 'number', 'object')
# Пары мутация↔ветвь живут здесь, не в прозе контракта. p10 — собственный
# факт судьи, p15 — отказ последнего рабочего; p16 — факт второго item.
MUTATIONS = {
    'truthy': ('      isolated: !!o.isolated,', {
        *(f'p10-int-propusk-posle-yield-{v}' for v in NONBOOLEAN),
        *(f'p15-int-rabochij-{v}' for v in NONBOOLEAN),
        *(f'p16-int-smeshannyj-paket-{v}' for v in NONBOOLEAN),
    }),
    'constant': ('      isolated: true,', {
        *(f'p10-int-propusk-posle-yield-{v}' for v in ('false', 'missing')),
        *(f'p15-int-rabochij-{v}' for v in ('false', 'missing')),
        'p16-int-smeshannyj-paket-false',
    }),
}
NEIGHBORS = {'p10-int-propusk-posle-yield-true', 'p20-int-pervyj-rabochij-true'}
RECORD = re.compile(r'PROBA (\S+) (OK|KRASNO)(?::.*)?')


def run(root, label):
    result = subprocess.run(['bash', str(root / STATION)], text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    print(f'NORMALIZACIJA {label} rc={result.returncode}', flush=True)
    print(result.stdout, end='', flush=True)
    records = {}
    for line in result.stdout.splitlines():
        match = RECORD.fullmatch(line)
        if match:
            name, status = match.groups()
            if name in records:
                raise ValueError(f'дублированная клетка {name}')
            records[name] = status
    if not records:
        raise ValueError('пустая выборка PROBA')
    return result.returncode, records


def main():
    original = (ROOT / HOOK).read_text(encoding='utf-8')
    if original.count(ANCHOR) != 1:
        raise ValueError('единственный якорь строгой нормализации не найден')
    rc, control = run(ROOT, 'strict')
    if rc != 0 or any(status != 'OK' for status in control.values()):
        return 1
    with tempfile.TemporaryDirectory(prefix='odin140-normalizacija.') as tmp:
        for label, (replacement, targets) in MUTATIONS.items():
            clone = Path(tmp) / label
            for relative in (STATION, HOOK, Path('scripts/zamok_predmeta.sh'),
                             Path('config/agent_models.json')):
                dest = clone / relative
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(ROOT / relative, dest)
            (clone / HOOK).write_text(original.replace(ANCHOR, replacement), encoding='utf-8')
            rc, observed = run(clone, label)
            # Отдельное предъявление каждой ветви; rc 1 сам по себе не доказательство.
            for name in sorted(targets):
                if control.get(name) != 'OK' or observed.get(name) != 'KRASNO':
                    raise ValueError(f'{label}: не различена клетка {name}')
            for name in sorted(NEIGHBORS):
                if control.get(name) != 'OK' or observed.get(name) != 'OK':
                    raise ValueError(f'{label}: испорчен честный сосед {name}')
            if rc != 1 or set(observed) != set(control):
                raise ValueError(f'{label}: код возврата/набор клеток отличается')
            print(f'NORMALIZACIJA {label} RAZLICHENO {len(targets)}', flush=True)
    return 0


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (OSError, ValueError) as error:
        print(f'NORMALIZACIJA KRASNO: {error}', flush=True)
        raise SystemExit(1)
