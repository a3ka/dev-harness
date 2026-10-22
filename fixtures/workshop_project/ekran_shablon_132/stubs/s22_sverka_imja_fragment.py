"""Стаб s22 (sverka-imja-fragment): исполнение приёмки сверки сравнивает
только rc и stdout, БЕЗ требования точного пути/argv раннера 123
(реализация эталона до блокера 2 вердикта adv-132 дословно): константная
реплика stdout по имени-фрагменту scripts/sverka_maketa.py.fake
проходит."""
import subprocess

from _model import m, run


def _staryj_run_priemka_sverka(f, pack, repo, harness, obrazec_stdout):
    try:
        p = subprocess.run(m.razbit_argv(f['priemka']['sverka']),
                           cwd=str(repo), capture_output=True, text=True,
                           timeout=600)
    except (OSError, subprocess.SubprocessError) as e:
        return [m.otkaz('SAMODELNAYA_SVERKA', 'не исполняется: %r' % e)]
    if p.returncode != 0 or p.stdout.splitlines() != obrazec_stdout.splitlines():
        return [m.otkaz('SAMODELNAYA_SVERKA',
                        'вывод не воспроизводит механизм 123')]
    return []


m.run_priemka_sverka = _staryj_run_priemka_sverka
run()
