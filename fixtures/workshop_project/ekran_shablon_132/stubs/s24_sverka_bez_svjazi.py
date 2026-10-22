"""Стаб П-2: run_priemka_sverka OBJECT 5f547cedc без связи argv с
пачкой; на трёх входах из verdicts/arbitration/contracts-132-impl-kap.md
раннер/rc/stdout честны, но --manifest/--kadry/--repo направлены не туда.
"""
import subprocess

from _model import m, run


def _run_priemka_sverka_object(f, pack, repo, harness, obrazec_stdout):
    try:
        p = subprocess.run(m.razbit_argv(f['priemka']['sverka']),
                           cwd=str(repo), capture_output=True, text=True,
                           timeout=600)
    except (OSError, subprocess.SubprocessError) as e:
        return [m.otkaz('SAMODELNAYA_SVERKA', 'не исполняется: %r' % e)]
    if p.returncode != 0 or p.stdout.splitlines() != obrazec_stdout.splitlines():
        return [m.otkaz('SAMODELNAYA_SVERKA',
                        'вывод не воспроизводит механизм 123')]
    sv = m.razbit_argv(f['priemka']['sverka'])
    if not m._argv_rannera123(sv):
        return [m.otkaz('SAMODELNAYA_SVERKA',
                        'argv не вызов раннера 123: %s' % f['priemka']['sverka'])]
    if not m._jet_runner123(repo / sv[1], harness):
        return [m.otkaz('SAMODELNAYA_SVERKA', 'файл не раннер 123: %s' % sv[1])]
    return []


m.run_priemka_sverka = _run_priemka_sverka_object
run()
