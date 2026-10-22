"""Стаб s23 (sverka-tolko-imja): приёмка сверки судит argv по ИМЕНИ файла
(суффикс /scripts/sverka_maketa.py) и вывод, БЕЗ идентичности файла
раннеру 123 (реализация эталона до блокера 1 вердикта adv-132 круг 2
дословно): podmena/scripts/sverka_maketa.py с константной репликой stdout
и совпавшим суффиксом имени проходит."""
import subprocess

from _model import m, run


def _imennoj_argv_rannera123(sv):
    if (len(sv) != 8 or sv[0] != 'python3'
            or (sv[1] != 'scripts/sverka_maketa.py'
                and not sv[1].endswith('/scripts/sverka_maketa.py'))):
        return False
    flagi, znach = sv[2::2], sv[3::2]
    return (sorted(flagi) == ['--kadry', '--manifest', '--repo']
            and all(z and not z.startswith('--') for z in znach))


def _imennoj_run_priemka_sverka(f, pack, repo, harness, obrazec_stdout):
    try:
        p = subprocess.run(m.razbit_argv(f['priemka']['sverka']),
                           cwd=str(repo), capture_output=True, text=True,
                           timeout=600)
    except (OSError, subprocess.SubprocessError) as e:
        return [m.otkaz('SAMODELNAYA_SVERKA', 'не исполняется: %r' % e)]
    if p.returncode != 0 or p.stdout.splitlines() != obrazec_stdout.splitlines():
        return [m.otkaz('SAMODELNAYA_SVERKA',
                        'вывод не воспроизводит механизм 123')]
    if not _imennoj_argv_rannera123(m.razbit_argv(f['priemka']['sverka'])):
        return [m.otkaz('SAMODELNAYA_SVERKA',
                        'argv не вызов раннера 123: %s'
                        % f['priemka']['sverka'])]
    return []


m.run_priemka_sverka = _imennoj_run_priemka_sverka
run()
