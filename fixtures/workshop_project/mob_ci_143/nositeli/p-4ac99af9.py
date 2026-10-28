#!/usr/bin/env python3
"""Run frozen Android flow without publishing the verification value.

Keep code-file outside repository/artifact paths. Only redacted text is published;
secureTextEntry and screenshot inspection remain required for binary artifacts.

Maestro substitutions require explicit -e arguments, not plain process environment.
For ci-e2e, a private PATH adapter supplies the code to `test` without changing the
snapshotted product script; other Maestro commands pass through unchanged.

995 v+1: ci-e2e owns the emulator restart and one retry; this probe owns the
publication. It collects BOTH attempts' textual diagnostics (maestro-out/diagnostics
plus a text-only fallback from attempt directories when the run was cut short),
redacts every text channel before writing anything, echoes a brief redacted
RECOVERED/EXHAUSTED event, and on --timeout kills only its own child process tree
(session) while still publishing what was collected.
995 v5 (143): the executable set is FIXED by the product map mobile/ci-screens.json
(integracija.fiksirovannyj_nabor) — the whole .maestro catalog is no longer copied
(other screens' flows run in their own jobs). The set cannot shrink silently: a
missing/unparsable map, a missing key, an empty/non-list set or an entry outside
mobile/.maestro/ refuses by name (SKHEMA_KARTY); a listed flow missing from the
repo refuses by name (FIKSIROVANNYJ_NABOR_NEPOLEN). config.yaml (provenance gate
of 118) travels with the set unchanged. Copied is not executed: the flows filter
of the copied config.yaml (118 grammar, literal '!name' exclusions) cannot
silently drop a set flow — named refusal BEFORE the run; the published JUnit
must carry exactly the fixed set's named testcases (Maestro names a testcase
after the flow header's name: field).
"""
import argparse
import json
import os
from pathlib import Path, PurePosixPath
import shutil
import signal
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET

HERE = Path(__file__).resolve().parent

SOBYTIJA = ('RECOVERED:', 'EXHAUSTED:', 'ПОВТОР:')


def _iskljuchenija_konfiga(tekst):
    """flows-фильтр config.yaml каталога Maestro — грамматика 118 (блок-список
    после строки 'flows:', элементы '- значение', кавычки сняты): значение с
    префиксом '!' — ЛИТЕРАЛЬНОЕ имя исключённого файла. Позитивные шаблоны вне
    '*' не интерпретируются — полнота исполнения судится отдельно по JUnit."""
    iskljuchenija = set()
    v_spiske = False
    for line in tekst.splitlines():
        s = line.strip()
        if v_spiske:
            if not s.startswith('- '):
                break
            znach = s[2:].strip().strip('\'"')
            if znach.startswith('!') and len(znach) > 1:
                iskljuchenija.add(znach[1:])
        elif s == 'flows:':
            v_spiske = True
    return iskljuchenija


def _imja_testcasea(raw):
    """Имя testcase Maestro — поле name: заголовка флоу (строки до первого
    '---'); при отсутствии — None (вызывающий откатывается к имени файла)."""
    zagolovok = raw.decode('utf-8', 'replace').partition('---')[0]
    for line in zagolovok.splitlines():
        if line.startswith('name:'):
            imja = line.partition(':')[2].strip()
            if imja:
                return imja
    return None


def _ubit_derevo(proc):
    """Stop only our own child process tree (new session), not the station."""
    try:
        os.killpg(os.getpgid(proc.pid), signal.SIGTERM)
    except (ProcessLookupError, PermissionError, OSError):
        proc.terminate()
    try:
        proc.wait(timeout=5)
    except subprocess.TimeoutExpired:
        try:
            os.killpg(os.getpgid(proc.pid), signal.SIGKILL)
        except (ProcessLookupError, PermissionError, OSError):
            proc.kill()
        proc.wait(timeout=5)


def pech_sobytija(stdout, stderr, secret):
    """Brief redacted lifecycle event so first failures stay visible in the log."""
    text = (stdout or '') + '\n' + (stderr or '')
    text = text.replace(secret, '[REDACTED]')
    for marker in SOBYTIJA:
        for line in text.splitlines():
            if marker in line:
                print('995 sobytie: ' + line.strip()[:200])
                return


def main():
    p = argparse.ArgumentParser()
    target = p.add_mutually_exclusive_group(required=True)
    target.add_argument('--device')
    target.add_argument('--repo', type=Path)
    p.add_argument('--apk', type=Path)
    p.add_argument('--code-file', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--timeout', type=int, default=1800,
                   help='budget for the ci-e2e run in seconds (repo mode only)')
    a = p.parse_args()
    secret = a.code_file.read_text().strip()
    if not secret or '\n' in secret:
        raise RuntimeError('INVALID_SECRET_INPUT')
    if a.out.exists():
        raise RuntimeError('OCCUPIED_OUTPUT')
    flow = (HERE / 'pilot.yaml').read_bytes()
    if a.repo and not a.apk:
        raise RuntimeError('APK_REQUIRED')
    # Existing CI owns emulator lifetime. Snapshot its script/flows before execution;
    # run them in private cwd so its hardcoded maestro-out never becomes raw artifacts.
    ci_script = (a.repo / 'mobile/scripts/ci-e2e.sh').read_bytes() if a.repo else None
    # 995 v5 (143 И-8): copy EXACTLY the fixed set from the product map, not the
    # whole .maestro catalog (rglob of 995 v4 is retired); named refusals keep
    # the set from becoming an empty "success" or silently narrower than the map.
    ci_flows = []
    if a.repo:
        try:
            karta = json.loads((a.repo / 'mobile/ci-screens.json').read_text(encoding='utf-8'))
        except (OSError, ValueError):
            print('995 SKHEMA_KARTY: mobile/ci-screens.json отсутствует или не JSON', file=sys.stderr)
            raise RuntimeError('SKHEMA_KARTY')
        integracija = karta.get('integracija') if isinstance(karta, dict) else None
        nabor = integracija.get('fiksirovannyj_nabor') if isinstance(integracija, dict) else None
        if not isinstance(nabor, list) or not nabor \
                or not all(isinstance(zapis, str) and zapis for zapis in nabor):
            print('995 SKHEMA_KARTY: integracija.fiksirovannyj_nabor отсутствует, пуст или не список',
                  file=sys.stderr)
            raise RuntimeError('SKHEMA_KARTY')
        for zapis in nabor:
            if zapis == 'pilot.yaml':
                continue  # private frozen flow from H (HERE), written below
            otnositelno = zapis[len('mobile/.maestro/'):] \
                if zapis.startswith('mobile/.maestro/') else None
            if not otnositelno or otnositelno.startswith('/') \
                    or '..' in PurePosixPath(otnositelno).parts:
                print('995 SKHEMA_KARTY: запись вне mobile/.maestro/: %s' % zapis, file=sys.stderr)
                raise RuntimeError('SKHEMA_KARTY')
            istochnik = a.repo / zapis
            if not istochnik.is_file():
                print('995 FIKSIROVANNYJ_NABOR_NEPOLEN: %s отсутствует в репозитории' % zapis,
                      file=sys.stderr)
                raise RuntimeError('FIKSIROVANNYJ_NABOR_NEPOLEN')
            ci_flows.append((Path(otnositelno), istochnik.read_bytes()))
        config = a.repo / 'mobile/.maestro/config.yaml'
        config_bytes = config.read_bytes() if config.is_file() else None
        if config_bytes is not None:
            ci_flows.append((Path('config.yaml'), config_bytes))
        # 995 v5 (143 И-8; адресная правка по вердикту критика 1/2): исполнение
        # РОВНО набора не подменяется копированием — flows-фильтр скопированного
        # config.yaml (грамматика 118: блок-список после 'flows:', элемент
        # '- значение' со снятыми кавычками; '!имя' — литеральное исключение
        # файла) не может тихо исключить флоу набора: именованный отказ ДО
        # запуска, ничего не исполняется и не публикуется.
        iskljuchenija = _iskljuchenija_konfiga(
            config_bytes.decode('utf-8', 'replace')) if config_bytes is not None else set()
        iskljuchennye = sorted(iskljuchenija & {PurePosixPath(z).name for z in nabor})
        if iskljuchennye:
            print('995 FIKSIROVANNYJ_NABOR_ISKLJUCHEN: mobile/.maestro/config.yaml '
                  'flows исключает %s из фиксированного набора' % ', '.join(iskljuchennye),
                  file=sys.stderr)
            raise RuntimeError('FIKSIROVANNYJ_NABOR_ISKLJUCHEN')
        # Имя testcase Maestro — поле name: заголовка флоу (живой формат,
        # zhivoj/report.xml), при отсутствии — имя файла; полнота исполнения
        # судится по этим именам на опубликованном JUnit ниже.
        ozhidaemye_imena_testcaseov = sorted(
            [_imja_testcasea(raw) or path.name for path, raw in ci_flows
             if path.name != 'config.yaml'] + [_imja_testcasea(flow) or 'pilot.yaml'])
    with tempfile.TemporaryDirectory(prefix='pilot995-native-') as tmp:
        private = Path(tmp)
        env = dict(os.environ, PILOT_DEMO_CODE=secret)
        if a.repo:
            for path, raw in ci_flows:
                dest = private / '.maestro' / path
                dest.parent.mkdir(parents=True, exist_ok=True)
                dest.write_bytes(raw)
            (private / '.maestro').mkdir(exist_ok=True)
            (private / '.maestro/pilot.yaml').write_bytes(flow)
            (private / 'ci-e2e.sh').write_bytes(ci_script)
            maestro = shutil.which('maestro')
            if maestro is None:
                raise RuntimeError('MAESTRO_REQUIRED')
            binary_dir = private / 'bin'
            binary_dir.mkdir()
            adapter = binary_dir / 'maestro'
            adapter.write_text(
                '#!' + sys.executable + '\n'
                'import os, sys\n'
                'args = sys.argv[1:]\n'
                'if "test" in args:\n'
                '    i = args.index("test") + 1\n'
                '    args[i:i] = ["-e", "PILOT_DEMO_CODE=" + os.environ["PILOT_DEMO_CODE"]]\n'
                f'os.execv({os.path.abspath(maestro)!r}, [{os.path.abspath(maestro)!r}, *args])\n')
            adapter.chmod(0o700)
            env['PATH'] = str(binary_dir) + os.pathsep + os.environ.get('PATH', os.defpath)
            publication = private / 'maestro-out'
            report = publication / 'report.xml'
            command = ['bash', str(private / 'ci-e2e.sh'), str(a.apk.resolve())]
        else:
            (private / 'pilot.yaml').write_bytes(flow)
            publication = private
            report = private / 'report.xml'
            command = ['maestro', '--device', a.device, 'test', '-e', 'PILOT_DEMO_CODE=' + secret, '--format', 'junit', '--output', str(report), '--test-output-dir', str(private / 'debug'), str(private / 'pilot.yaml')]
        # Exception-safe publication: everything reachable is captured in memory
        # before the TemporaryDirectory goes away, timeouts included (995 v+1).
        files = {}

        def sobrat(koren, otn):
            for f in koren.rglob('*'):
                if f.is_file() and f.name != 'pilot.yaml':
                    files[otn / f.relative_to(koren)] = f.read_bytes()

        def sbor_i_publikacija(stdout, stderr):
            if publication.is_dir():
                sobrat(publication, Path('.'))
            for podhod in sorted(private.glob('podhod-*')):
                n = podhod.name.split('-', 1)[1]
                otn = Path('diagnostics') / ('attempt-' + n)
                for imja in ('maestro.log', 'report.xml'):
                    if (podhod / imja).is_file():
                        files[otn / imja] = (podhod / imja).read_bytes()
                if (podhod / 'test/commands.json').is_file():
                    files[otn / 'test-commands.json'] = (podhod / 'test/commands.json').read_bytes()
                if (podhod / 'diag').is_dir():
                    sobrat(podhod / 'diag', otn / 'diag')
            a.out.mkdir(parents=True)
            for path, raw in sorted(files.items()):
                dest = a.out / path
                dest.parent.mkdir(parents=True, exist_ok=True)
                if path.suffix.lower() in ('.png', '.jpg', '.jpeg'):
                    dest.write_bytes(raw)
                else:
                    dest.write_bytes(raw.replace(secret.encode(), b'[REDACTED]'))
            log = (stdout + '\n' + stderr).replace(secret, '[REDACTED]').encode('utf-8')
            (a.out / 'maestro.log').write_bytes(log)
        def publikovat_do_vyhoda(stdout, stderr):
            sbor_i_publikacija(stdout, stderr)
            pech_sobytija(stdout, stderr, secret)

        if a.repo:
            proc = subprocess.Popen(command, cwd=str(private), env=env,
                                    stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                    start_new_session=True)
            try:
                vyhod_bajty, oshibki_bajty = proc.communicate(timeout=max(1, a.timeout))
            except subprocess.TimeoutExpired:
                _ubit_derevo(proc)
                vyhod_bajty, oshibki_bajty = proc.communicate()
                stdout, stderr = vyhod_bajty.decode('utf-8', 'replace'), oshibki_bajty.decode('utf-8', 'replace')
                publikovat_do_vyhoda(stdout, stderr)
                print('995 INFRASTRUCTURE: TimeoutExpired (budget %d s); собранное опубликовано редактированно' % a.timeout)
                return 2
            result_returncode = proc.returncode
        else:
            r = subprocess.run(command, cwd=str(private), env=env, capture_output=True, timeout=300)
            vyhod_bajty, oshibki_bajty = r.stdout, r.stderr
            result_returncode = r.returncode
        stdout, stderr = vyhod_bajty.decode('utf-8', 'replace'), oshibki_bajty.decode('utf-8', 'replace')
        # Capture every publication candidate in memory; do not reread after sanitizing.
        sbor_i_publikacija(stdout, stderr)
        pech_sobytija(stdout, stderr, secret)
        published_report = a.out / 'report.xml'
        if not published_report.exists():
            raise RuntimeError('NATIVE_REPORT_MISSING')
        root = ET.fromstring(published_report.read_bytes())
        cases = list(root.iter('testcase'))
        if not cases:
            raise RuntimeError('NATIVE_EMPTY_ASSERTIONS')
        failures = [c for c in cases if c.find('failure') is not None or c.find('error') is not None or c.find('skipped') is not None]
        if a.repo:
            # 995 v5 (адресные правки: вердикт критика 1/2 + РЕШЕНИЕ арбитра
            # по коллизии name:): полнота исполнения — МУЛЬТИМНОЖЕСТВО имён
            # (отсортированный список с кратностью; число testcase == числу
            # скопированных флоу, коллизия name: пропуск не маскирует);
            # сужение/расширение исполнения — красная публикация. Каталожная
            # форма отчёта: имя testcase = name: заголовка флоу (иначе имя
            # файла); отчёт без единого имени набора — до-каталожный формат
            # (замороженные клетки v+1..v4 батареи), полнотой не судится.
            fakticheskie_imena = sorted(c.get('name') for c in cases)
            if (set(fakticheskie_imena) & set(ozhidaemye_imena_testcaseov)
                    and fakticheskie_imena != ozhidaemye_imena_testcaseov):
                print('995 FIKSIROVANNYJ_NABOR_NE_ISPOLNEN: исполнены %s ≠ фиксированного набора %s'
                      % (fakticheskie_imena, ozhidaemye_imena_testcaseov))
                return 1
        # Final evidence belongs to ONE attempt: top-level PNGs only, attempt
        # directories carry text diagnostics and never mix in older screenshots.
        pngs = {path.stem for path, raw in files.items()
                if path.suffix == '.png' and raw and path.parts[0] != 'diagnostics'}
        if result_returncode == 0 and (failures or not {'pilot-first-run', 'pilot-welcome', 'pilot-restart'}.issubset(pngs)):
            print('995 NATIVE_EVIDENCE_INCOMPLETE')
            return 1
        print(f'995 native rc={result_returncode} testcases={len(cases)} failed={len(failures)}')
        return 0 if result_returncode == 0 else 1


if __name__ == '__main__':
    try: sys.exit(main())
    except (OSError, RuntimeError, ET.ParseError, subprocess.TimeoutExpired) as error:
        # Exception messages from subprocess can contain command arguments; never include secret.
        print('995 INFRASTRUCTURE:', type(error).__name__, file=sys.stderr); sys.exit(2)
