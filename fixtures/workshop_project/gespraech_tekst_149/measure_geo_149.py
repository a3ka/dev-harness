#!/usr/bin/env python3
"""149: измерение КОНЕЧНЫХ прямоугольников настоящего прототипа Kompakt-1.1.

Не барьер: производитель геометрического оракула для red_geo_149.py.
CLI: measure_geo_149.py <docs/ux/05_Kompakt_D24>; JSON в stdout.
Коды возврата: 0 — все экраны/темы/профили измерены; 2 — нет предпосылки
или исходник/рендер не дал требуемых элементов. Ничего в пакете не пишет.
Chrome CDP + websocket-client; файлы HTML и загруженные CSS/JS пинуются.
"""
import hashlib
import json
import re
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from urllib.request import Request, urlopen

SCREENS = {
    'GA-15': {'pill': '.p-dial-list > li:nth-child(2) .p-dial-item'},
    'GA-17': {'field': '.p-chatcomp-field'},
    'GA-11': {'mic': '.p-topics > div:nth-child(2) .p-topic-mic'},
    'GA-31': {'bar': '.p-vbar', 'header': '[data-m=top]'},
    'GA-12': {'chip': '.p-invite-chip', 'field': '.p-chatcomp-field'},
    'GA-32': {'bar': '.p-vbar'},
    'GA-42': {'bar': '.p-vbar'},
    'GA-13': {'field': '.p-chatcomp-field'},
}


def measure(package):
    import websocket
    chrome = shutil.which('google-chrome')
    if not chrome:
        raise RuntimeError('нет google-chrome')
    package = package.resolve()
    hashes, rects = {}, {}
    with tempfile.TemporaryDirectory(prefix='measure-geo149-') as user_data:
        process = subprocess.Popen(
            [chrome, '--headless', '--no-sandbox', '--disable-gpu',
             '--no-first-run', '--no-default-browser-check',
             '--allow-file-access-from-files', '--remote-allow-origins=*',
             '--remote-debugging-port=0', '--user-data-dir=' + user_data],
            stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, text=True)
        connection = None
        try:
            endpoint = None
            for line in process.stderr:
                match = re.search(r'DevTools listening on ws://127.0.0.1:(\d+)/', line)
                if match:
                    endpoint = 'http://127.0.0.1:' + match.group(1)
                    break
            if endpoint is None:
                raise RuntimeError('Chrome не открыл CDP')
            with urlopen(Request(endpoint + '/json/new?about:blank', method='PUT'),
                         timeout=10) as response:
                target = json.load(response)
            connection = websocket.create_connection(target['webSocketDebuggerUrl'],
                                                      timeout=15)
            sequence = 0

            def cdp(method, params=None):
                nonlocal sequence
                sequence += 1
                connection.send(json.dumps({'id': sequence, 'method': method,
                                            'params': params or {}}))
                while True:
                    result = json.loads(connection.recv())
                    if result.get('id') == sequence:
                        if 'error' in result:
                            raise RuntimeError(result['error'])
                        return result.get('result', {})

            def evaluate(expression):
                result = cdp('Runtime.evaluate', {'expression': expression,
                             'returnByValue': True, 'awaitPromise': True})
                if 'exceptionDetails' in result:
                    raise RuntimeError(result['exceptionDetails'])
                return result['result'].get('value')

            for profile in ('390x844', '393x852'):
                width, height = map(int, profile.split('x'))
                cdp('Emulation.setDeviceMetricsOverride',
                    {'width': width, 'height': height, 'deviceScaleFactor': 1,
                     'mobile': False})
                rects[profile] = {}
                for theme, suffix in (('dark', ''), ('light', '-Hell')):
                    rects[profile][theme] = {}
                    for screen, selectors in SCREENS.items():
                        relative = f'source/screens/{profile}/{screen}{suffix}.html'
                        html = package / relative
                        hashes[relative] = hashlib.sha256(html.read_bytes()).hexdigest()
                        cdp('Page.navigate', {'url': html.as_uri()})
                        deadline = time.monotonic() + 15
                        while not evaluate('location.href === ' + json.dumps(html.as_uri())
                                           + ' && document.readyState === "complete" && '
                                           '!document.querySelector("x-import") && '
                                           '!!document.querySelector(".p-chatcomp-field, '
                                           '.p-vbar, .p-dial-item, .p-topic-mic")'):
                            if time.monotonic() > deadline:
                                raise RuntimeError('рендер не готов: ' + relative)
                            time.sleep(0.05)
                        evaluate('document.fonts.ready.then(() => new Promise(resolve => '
                                 'requestAnimationFrame(() => requestAnimationFrame(resolve))))')
                        values = evaluate('(() => { const out = {}; const selectors = '
                                          + json.dumps(selectors) + '; '
                                          'for (const [name, selector] of Object.entries(selectors)) {'
                                          'const found = document.querySelectorAll(selector); '
                                          'if (found.length !== 1) throw new Error(selector + '
                                          '" count=" + found.length); '
                                          'const r = found[0].getBoundingClientRect(); '
                                          'out[name] = [r.x, r.y, r.width, r.height]; '
                                          'if (r.width <= 0 || r.height <= 0) throw new Error(selector); '
                                          '} return out; })()')
                        rects[profile][theme][screen] = values
            # Все реально загруженные зависимости (CSS/JS/fonts), не только HTML.
            for folder in ('source/ds', 'source/vendor'):
                for source in sorted((package / folder).rglob('*')):
                    if source.is_file():
                        hashes[source.relative_to(package).as_posix()] = hashlib.sha256(
                            source.read_bytes()).hexdigest()
            hashes['motion/motion-delta.md'] = hashlib.sha256(
                (package / 'motion/motion-delta.md').read_bytes()).hexdigest()
            return {'source': {'package': 'D24-Kompakt-1.1', 'sha256': hashes,
                               'method': 'Chrome getBoundingClientRect after fonts.ready + 2 rAF'},
                    'rects': rects}
        finally:
            if connection is not None:
                connection.close()
            process.terminate()
            try:
                process.wait(timeout=10)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()


if __name__ == '__main__':
    try:
        if len(sys.argv) != 2:
            raise RuntimeError('использование: measure_geo_149.py <пакет05>')
        print(json.dumps(measure(Path(sys.argv[1])), ensure_ascii=False, indent=2))
    except (OSError, ValueError, ImportError, RuntimeError) as error:
        print('NOT_IMPLEMENTED: ' + str(error), file=sys.stderr)
        sys.exit(2)
