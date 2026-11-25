#!/usr/bin/env python3
"""Честный контроль и два адресных негатива преусловия --stabs (Rev211c Б-1)."""
import json
import os
from pathlib import Path
import sys
import tempfile

sys.dont_write_bytecode = True
import probe211 as p


def main():
    p.zashita_zavisimostej()
    chislo = p.piny_sverka()
    tree = p.plumbing(p.run(['git', 'rev-parse', 'HEAD^{tree}'], cwd=p.KOREN))
    r = p.run(['git', '-c', 'user.name=architect', '-c',
               'user.email=architect@dev-harness.local', 'commit-tree', tree,
               '-m', '211 pin outside history, same tree'], cwd=p.KOREN)
    assert r.returncode == 0, r.stderr
    bokovoj = p.plumbing(r)
    # Существующий commit с настоящей дверью: отсутствие содержимого не
    # может случайно покрасить этот контрпример вместо проверки предковости.
    assert p.run(['git', 'merge-base', '--is-ancestor', bokovoj, 'HEAD'],
                 cwd=p.KOREN).returncode == 1
    assert p.tekst_bazy(bokovoj) == p.tekst_bazy('HEAD')
    fd, name = tempfile.mkstemp(prefix='pin211-', suffix='.json', dir=p.HERE)
    os.close(fd)
    put = Path(name)
    try:
        put.write_text(json.dumps({'pin': p.BAZA_PRODUCTION_211F}) + '\n')
        assert p.piny_sverka() == chislo  # эквивалентная честная запись
        for imja, pin in (('net-obekta', '0' * 40),
                          ('est-obekt-ne-predok', bokovoj)):
            put.write_text(json.dumps({'pin': pin}) + '\n')
            r = p.run(['bash', str(p.HERE / 'red_d52_bootstrap_sudej_211.sh'),
                       '--stabs'], cwd=p.KOREN)
            ozhidanie = ('ORACLE_TAMPERED: PIN_NE_PREDOK_HEAD: %s\n'
                         % pin).encode('ascii')
            assert (r.returncode, r.stdout, r.stderr) == (2, b'', ozhidanie), (
                imja, r.returncode, r.stdout, r.stderr)
            print('PINY NEGATIV %s: rc=%d stdout=%r stderr=%r'
                  % (imja, r.returncode, r.stdout, r.stderr))
    finally:
        put.unlink()
    assert p.piny_sverka() == chislo
    print('PINY 211: PREDKOV %d NEGATIVOV 2' % chislo)
    return 0


if __name__ == '__main__':
    sys.exit(main())
