#!/usr/bin/env python3
"""Статическая проба 111 (CMP-MOB-005): splash, копия каталога, шов экрана,
проводка PilotApp, wordmark-ассет (строгий RGBA-декод), независимость оракула.

Без --model на до-предметном дереве — rc1 FIRST_RUN_SEAM_ABSENT.
С --model/честным C — rc0: splash #0A0A0A (ground D2.2.5.1) без дефолт-B
#208AEF, ключи каталога verbatim (текст+review_status), экран First-Run в
features/auth без литеральных hex-цветов, на SafeAreaView и useTheme,
проводка в PilotApp (FirstRunScreen, legacy «Weiter» удалён), wordmark-ассет
— PNG на месте И настоящий RGBA-растр (A1, суд круг 1: строгий декод чистым
python zlib+struct — IHDR/IDAT/CRC согласованы, w>=200 h>=60, пропорция
канона 143/52.08 ±10%, не одноцветный, есть прозрачные пиксели; 82-байтная
заглушка с магией PNG красна), CTA привязан к testID 995, оракул пробы несёт
литералы и не импортирует копию субъекта.
--matrix: обманные стабы статической семьи красны именованной клеткой.
Выход — только код возврата; перечень case построчно.
"""
import argparse
import json
import re
import struct
from pathlib import Path
import subprocess
import sys
import zlib

from probe_lib import HERE, SCREEN_PATH, installed, load_source, model_bytes

CASES = []
INFRASTRUCTURE = []


SPLASH_EFFECTIVE_JS = """'use strict';
// 111 (B4): эффективная нативная конфигурация splash настоящими резолверами
// expo-splash-screen из node_modules продукта — той же логикой, которой
// prebuild выбирает платформенные значения; корневое свойство plugin options
// не истина (платформенные android/ios-переопределения бьют его). Резолверы
// загружаются абсолютным путём: exports-карта пакета закрывает deep-subpath.
const fs = require('fs');
const path = require('path');
const pkg = path.join(__dirname, 'node_modules', 'expo-splash-screen');
const {getAndroidSplashConfig} = require(path.join(pkg, 'plugin', 'build', 'getAndroidSplashConfig.js'));
const {getIosSplashConfig} = require(path.join(pkg, 'plugin', 'build', 'getIosSplashConfig.js'));
const app = JSON.parse(fs.readFileSync(path.join(__dirname, 'app.json'), 'utf8'));
const entry = (app.expo.plugins || []).find((p) => Array.isArray(p) && p[0] === 'expo-splash-screen');
if (!entry) {
  console.log(JSON.stringify({error: 'NO_SPLASH_PLUGIN'}));
} else {
  const props = entry[1] || {};
  console.log(JSON.stringify({
    android: getAndroidSplashConfig(props).backgroundColor,
    ios: getIosSplashConfig(props).backgroundColor,
  }));
}
"""


def effective_splash(repo: Path):
    """(android, ios) эффективные splash-фоны; None => INFRASTRUCTURE."""
    mobile = repo / 'mobile'
    for rel in ('node_modules/expo-splash-screen/plugin/build/getAndroidSplashConfig.js',
                'node_modules/expo-splash-screen/plugin/build/getIosSplashConfig.js'):
        if not (mobile / rel).exists():
            INFRASTRUCTURE.append('splash resolver отсутствует: ' + rel)
            return None
    script = mobile / '__111_splash_effective__.js'
    with installed({script: SPLASH_EFFECTIVE_JS.encode()}):
        try:
            proc = subprocess.run(['node', str(script)], cwd=mobile,
                                  capture_output=True, text=True, timeout=120)
        except (OSError, subprocess.SubprocessError) as err:
            INFRASTRUCTURE.append('splash resolver не исполнился: ' + repr(err))
            return None
    if proc.returncode != 0:
        INFRASTRUCTURE.append('splash resolver rc=' + str(proc.returncode)
                              + ' stderr=' + proc.stderr[-300:])
        return None
    try:
        return json.loads(proc.stdout.strip().splitlines()[-1])
    except (ValueError, IndexError):
        INFRASTRUCTURE.append('splash resolver вывод не JSON: ' + proc.stdout[-300:])
        return None


def decode_png_rgba(blob: bytes):
    """Строгий декод PNG → (w, h, rgba-байты); ValueError — именованный отказ.

    Чистый python (zlib+struct), без внешних библиотек: сигнатура, полнота
    чанков, CRC каждого чанка, IHDR (8-bit RGBA, без interlace), длина
    inflate-данных IDAT == h*(1+w*4), все пять фильтров развернуты.
    """
    if not blob.startswith(b'\x89PNG\r\n\x1a\n'):
        raise ValueError('PNG_SIGNATURE')
    pos = 8
    idat = bytearray()
    ihdr = None
    seen_iend = False
    while pos + 8 <= len(blob):
        length, ctype = struct.unpack('>I4s', blob[pos:pos + 8])
        data = blob[pos + 8:pos + 8 + length]
        if len(data) != length or pos + 12 + length > len(blob):
            raise ValueError('CHUNK_TRUNCATED ' + ctype.decode('latin1'))
        crc = struct.unpack('>I', blob[pos + 8 + length:pos + 12 + length])[0]
        if zlib.crc32(ctype + data) & 0xFFFFFFFF != crc:
            raise ValueError('CHUNK_CRC ' + ctype.decode('latin1'))
        if ctype == b'IHDR':
            ihdr = struct.unpack('>IIBBBBB', data)
        elif ctype == b'IDAT':
            idat += data
        elif ctype == b'IEND':
            seen_iend = True
        pos += 12 + length
    if ihdr is None:
        raise ValueError('IHDR_ABSENT')
    if not seen_iend:
        raise ValueError('IEND_ABSENT')
    w, h, depth, color, comp, flt, inter = ihdr
    if depth != 8 or color != 6 or comp != 0 or flt != 0 or inter != 0:
        raise ValueError(f'IHDR_MODE w={w} h={h} depth={depth} color={color}')
    raw = zlib.decompress(bytes(idat))
    stride = w * 4
    if len(raw) != h * (1 + stride):
        raise ValueError(f'IDAT_LEN {len(raw)} != {h * (1 + stride)}')
    out = bytearray(h * stride)
    prev = bytearray(stride)
    for y in range(h):
        f = raw[y * (1 + stride)]
        line = bytearray(raw[y * (1 + stride) + 1:(y + 1) * (1 + stride)])
        if f == 0:
            pass
        elif f == 1:
            for i in range(4, stride):
                line[i] = (line[i] + line[i - 4]) & 0xFF
        elif f == 2:
            for i in range(stride):
                line[i] = (line[i] + prev[i]) & 0xFF
        elif f == 3:
            for i in range(stride):
                a = line[i - 4] if i >= 4 else 0
                line[i] = (line[i] + ((a + prev[i]) >> 1)) & 0xFF
        elif f == 4:
            for i in range(stride):
                a = line[i - 4] if i >= 4 else 0
                b = prev[i]
                c = prev[i - 4] if i >= 4 else 0
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[i] = (line[i] + pr) & 0xFF
        else:
            raise ValueError(f'FILTER {f}')
        out[y * stride:(y + 1) * stride] = line
        prev = line
    return w, h, bytes(out)


def png_rgba_encode(w: int, h: int, rows) -> bytes:
    """Валидный PNG RGBA 8-bit (filter 0) — материал обманных стабов матрицы."""
    def chunk(ctype: bytes, data: bytes) -> bytes:
        return (struct.pack('>I', len(data)) + ctype + data
                + struct.pack('>I', zlib.crc32(ctype + data) & 0xFFFFFFFF))
    ihdr = struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0)
    raw = b''.join(b'\x00' + row for row in rows)
    return (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', ihdr)
            + chunk(b'IDAT', zlib.compress(raw)) + chunk(b'IEND', b''))


# 82-байтная заглушка из красной реализации круга 1 (cec116cd): IHDR
# 8×44 grayscale, IDAT 25 байт «RGB-данных» — не декодируется, ломала
# aapt2 crunch (rc=139). Хранится литералом — материал стаба матрицы.
WORDMARK_STUB_82 = bytes.fromhex(
    '89504e470d0a1a0a0000000d49484452000000080000002c08000000007d59a677'
    '000000194944415478da63f8f4f10d56c4302a312a312a312a41bc040088c0dcce'
    '04b35f440000000049454e44ae426082'
)


def check(cond, case):
    CASES.append((case, bool(cond)))
    if not cond:
        print('RED', case)


def run_checks(repo: Path):
    src = load_source()

    # Splash: нативный фон = ground D2.2.5.1 (тёмный), ассет/ширина не тронуты.
    app_raw = (repo / 'mobile/app.json').read_text(encoding='utf-8')
    app = json.loads(app_raw)
    splash = None
    for plugin in app['expo']['plugins']:
        if isinstance(plugin, list) and plugin[0] == src['splash']['plugin']:
            splash = plugin[1]
    check(splash is not None
          and splash.get('backgroundColor') == src['splash']['backgroundColor']
          and splash.get('image') == src['splash']['image']
          and splash.get('imageWidth') == src['splash']['imageWidth'],
          'SPLASH_GROUND_DARK')
    check(src['splash']['old_default_B'] not in app_raw, 'SPLASH_DEFAULT_BLUE_GONE')

    # B4 (критик 111, круг 1): эффективный splash на ОБЕИХ платформах —
    # настоящие резолверы expo-splash-screen; платформенное переопределение
    # android/ios.backgroundColor бьёт корневое свойство и ловится здесь.
    effective = effective_splash(repo)
    if effective is None or 'error' in effective:
        if effective is not None:
            INFRASTRUCTURE.append('splash plugin: ' + str(effective))
        check(False, 'SPLASH_EFFECTIVE_GROUND_BOTH')
    else:
        want = src['splash']['backgroundColor'].lower()
        check(isinstance(effective.get('android'), str)
              and isinstance(effective.get('ios'), str)
              and effective['android'].lower() == want
              and effective['ios'].lower() == want,
              'SPLASH_EFFECTIVE_GROUND_BOTH')

    # Копия каталога: два ключа First-Run verbatim (текст + review_status).
    ui = (repo / 'mobile/src/i18n/ui-copy.ts').read_text(encoding='utf-8')
    for key in ('ui.first_run.promise', 'ui.first_run.enter_f03'):
        entry = src['copy'][key]
        pat = (
            "'" + re.escape(key) + r"': \{ text: '" + re.escape(entry['text'])
            + r"', review_status: '" + re.escape(entry['review_status']) + r"' \}"
        )
        check(re.search(pat, ui), 'COPY_KEY_' + key.replace('.', '_'))

    # Шов экрана: файл существует, экспортирует FirstRunScreen.
    screen_path = repo / SCREEN_PATH
    if screen_path.exists():
        screen = screen_path.read_text(encoding='utf-8')
    else:
        screen = ''
    check(re.search(r'export function FirstRunScreen', screen), 'SCREEN_SEAM_FIRST_RUN')
    check(not re.search(r'#[0-9a-fA-F]{3,8}\b', screen), 'SCREEN_NO_HEX_LITERALS')
    check(re.search(r"import \{ SafeAreaView \} from 'react-native-safe-area-context'", screen),
          'SCREEN_SAFEAREA_COMPONENT')
    check('useTheme' in screen, 'SCREEN_THEME_TOKENS')
    check("'first-run-continue'" in screen or '"first-run-continue"' in screen,
          'CTA_TESTID_BOUND')

    # Проводка: PilotApp рендерит FirstRunScreen, legacy «Weiter» удалён.
    pa = (repo / 'mobile/src/bootstrap/pilot-app.tsx').read_text(encoding='utf-8')
    check("from '@/features/auth/first-run-screen'" in pa and '<FirstRunScreen' in pa,
          'PILOT_WIRED_FIRST_RUN')
    check("'Weiter'" not in pa, 'LEGACY_WEITER_GONE')

    # Wordmark: ассет PNG существует и валиден (магия PNG).
    wm = repo / src['wordmark']['asset']
    blob = wm.read_bytes() if wm.exists() else b''
    check(blob.startswith(b'\x89PNG\r\n\x1a\n') and len(blob) > 0, 'WORDMARK_ASSET')

    # A1 (суд 111, круг 1): wordmark — НАСТОЯЩИЙ растр, не заглушка с магией
    # PNG. Строгий декод decode_png_rgba (zlib+struct) + габариты/пропорция
    # канона D2.2.5.1 (viewBox SVG 143.00×52.08, ±10%) + не одноцветный +
    # есть прозрачные пиксели. Модель-растр снят chrome headless с канон-SVG
    # (logo/assets/complior-wordmark-dark.svg байт-равен
    # screens/html/ds/wordmark-dark.svg), команда растеризации:
    #   /usr/bin/google-chrome --headless --no-sandbox --disable-gpu
    #     --hide-scrollbars --force-device-scale-factor=3 --window-size=143,52
    #     --default-background-color=00000000
    #     --screenshot=<out>.png file://<scratch>/complior-wordmark-dark.svg
    # → 429×156 RGBA (прозрачный фон, чернила #f2f1ec).
    try:
        w, h, px = decode_png_rgba(blob)
        canon = 143.00 / 52.08
        problems = []
        if w < 200 or h < 60:
            problems.append(f'габариты {w}x{h} < 200x60')
        if not (canon * 0.9 <= w / h <= canon * 1.1):
            problems.append(f'пропорция {w / h:.3f} вне ±10% канона {canon:.3f}')
        distinct = len({px[i:i + 4] for i in range(0, len(px), 4)})
        if distinct < 2:
            problems.append(f'одноцветный прямоугольник: {distinct} разных пикселей')
        if not any(px[i] < 255 for i in range(3, len(px), 4)):
            problems.append('нет прозрачных пикселей')
        if problems:
            print('RED WORDMARK_ASSET_DECODES:', '; '.join(problems))
        check(not problems, 'WORDMARK_ASSET_DECODES')
    except ValueError as err:
        print('RED WORDMARK_ASSET_DECODES:', err)
        check(False, 'WORDMARK_ASSET_DECODES')

    # Независимость оракула (правило 8, Н-351): проба несёт литералы каталога
    # и токенов и не импортирует копию/токены субъекта как ожидание.
    probe_test = (HERE / 'first_run.test.tsx').read_text(encoding='utf-8')
    check(
        src['copy']['ui.first_run.promise']['text'] in probe_test
        and src['copy']['ui.first_run.enter_f03']['text'] in probe_test
        and src['copy']['frame.F03.01.title']['text'] in probe_test
        and src['tokens']['ground']['dark'] in probe_test
        and src['tokens']['ground']['light'] in probe_test
        and src['tokens']['ink']['dark'] in probe_test
        and src['tokens']['ink']['light'] in probe_test
        and "from '@/i18n/ui-copy'" not in probe_test,
        'STATIC_ORACLE_LITERALS',
    )


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', required=True)
    ap.add_argument('--model', action='store_true')
    ap.add_argument('--matrix', action='store_true')
    args = ap.parse_args()
    repo = Path(args.repo).resolve()

    if args.matrix:
        return matrix(repo)

    if not args.model and not (repo / SCREEN_PATH).exists():
        print('FIRST_RUN_SEAM_ABSENT')
        return 1
    files = {}
    if args.model:
        for rel, blob in model_bytes().items():
            files[repo / rel] = blob
    with installed(files):
        run_checks(repo)
    if INFRASTRUCTURE:
        for line in INFRASTRUCTURE:
            print('INFRASTRUCTURE:', line)
        return 2
    ok = sum(1 for _, good in CASES if good)
    for case, good in CASES:
        if good:
            print('case', case)
    if ok != len(CASES):
        return 1
    print(f'static {ok}/{len(CASES)}')
    return 0


def matrix(repo: Path):
    U = 'mobile/src/i18n/ui-copy.ts'
    S = SCREEN_PATH
    P = 'mobile/src/bootstrap/pilot-app.tsx'
    W = 'mobile/assets/images/wordmark-dark.png'
    WM_MODEL = (HERE / 'model' / 'wordmark-dark.png').read_bytes()
    MUTANTS = {
        'splash-stays-default-blue': (
            [('mobile/app.json', '"backgroundColor": "#0A0A0A"', '"backgroundColor": "#208AEF"')],
            ['SPLASH_GROUND_DARK'],
            ['SPLASH_DEFAULT_BLUE_GONE', 'SPLASH_EFFECTIVE_GROUND_BOTH'],
        ),
        # B4 (критик 111, круг 1): платформенное переопределение оставляет
        # корневое свойство верным — ловит только effective-клетка.
        'android-splash-blue': (
            [('mobile/app.json',
              '"imageWidth": 76\n        }',
              '"imageWidth": 76,\n          "android": {\n            "backgroundColor": "#208aef"\n          }\n        }')],
            ['SPLASH_EFFECTIVE_GROUND_BOTH'], [],
        ),
        'copy-promise-invented': (
            [(U, "'ui.first_run.promise': { text: 'Sie sagen, was passiert ist. Complior kümmert sich um den Rest.',",
              "'ui.first_run.promise': { text: 'Sie sagen, was passiert ist.',")],
            ['COPY_KEY_ui_first_run_promise'], [],
        ),
        'copy-enter-missing': (
            [(U, "  'ui.first_run.enter_f03': { text: 'Anmelden oder Konto erstellen', review_status: 'UX_EDITORIAL_REVIEWED; NATIVE_RELEASE_SIGNOFF_REQUIRED' },\n",
              '')],
            ['COPY_KEY_ui_first_run_enter_f03'], [],
        ),
        'screen-hex-literal': (
            [(S, 'backgroundColor: tokens.ground', "backgroundColor: '#FFFFFF'")],
            ['SCREEN_NO_HEX_LITERALS'], [],
        ),
        'pilot-unwired': (
            [(P, "import { FirstRunScreen } from '@/features/auth/first-run-screen';\n", '')],
            ['PILOT_WIRED_FIRST_RUN'], [],
        ),
        'wordmark-missing': (
            [(W, 'PNG', 'XXX')],
            ['WORDMARK_ASSET'],
            # r5: сломанная магия валит и строгий декод (замер матрицей).
            ['WORDMARK_ASSET_DECODES'],
        ),
        # A1 (суд 111, круг 1): заглушки-«PNG» — магия жива (WORDMARK_ASSET
        # зелёна), декодируемость/растр отсутствуют; красны строгим декодом.
        'wordmark-1x1-png': (
            [(W, WM_MODEL, png_rgba_encode(1, 1, [bytes((0, 0, 0, 0))]))],
            ['WORDMARK_ASSET_DECODES'], [],
        ),
        'wordmark-broken-stub-82': (
            [(W, WM_MODEL, WORDMARK_STUB_82)],
            ['WORDMARK_ASSET_DECODES'], [],
        ),
        'wordmark-solid-rectangle': (
            [(W, WM_MODEL, png_rgba_encode(429, 156, [bytes((242, 241, 236, 255)) * 429] * 156))],
            ['WORDMARK_ASSET_DECODES'], [],
        ),
        'cta-testid-unbound': (
            [(S, 'testID="first-run-continue"', 'testID="first-run-enter"')],
            ['CTA_TESTID_BOUND'], [],
        ),
        'screen-plain-view': (
            [(S, "import { SafeAreaView } from 'react-native-safe-area-context';",
              "import { View } from 'react-native';")],
            ['SCREEN_SAFEAREA_COMPONENT'], [],
        ),
    }
    honest_src = model_bytes()
    CASES.clear()
    INFRASTRUCTURE.clear()
    with installed({repo / rel: blob for rel, blob in honest_src.items()}):
        run_checks(repo)
    if INFRASTRUCTURE:
        for line in INFRASTRUCTURE:
            print('INFRASTRUCTURE:', line)
        return 2
    if not all(good for _, good in CASES):
        print('MUTATION_MATRIX_HONEST_NOT_GREEN', [c for c, g in CASES if not g])
        return 2
    ok = True
    for name, (mutations, named, depends) in MUTANTS.items():
        try:
            blobs = model_bytes(mutations)
        except RuntimeError as err:
            print('MUTANT_ANCHOR_BROKEN', name, err)
            ok = False
            continue
        CASES.clear()
        INFRASTRUCTURE.clear()
        with installed({repo / rel: blob for rel, blob in blobs.items()}):
            run_checks(repo)
        if INFRASTRUCTURE:
            for line in INFRASTRUCTURE:
                print('MUTANT_INFRASTRUCTURE', name, line)
            ok = False
            continue
        red = {c for c, good in CASES if not good}
        expected = set(named) | set(depends)
        if not red:
            print('MUTANT_GREEN', name)
            ok = False
        elif not (set(named) & red):
            print('MUTANT_NAMED_MISS', name, sorted(red))
            ok = False
        elif not red <= expected:
            print('MUTANT_UNEXPECTED_RED', name, sorted(red - expected))
            ok = False
        else:
            print('mutant', name, 'red=', sorted(red))
    return 0 if ok else 2


if __name__ == '__main__':
    sys.exit(main())
