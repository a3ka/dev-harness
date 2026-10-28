#!/usr/bin/env python3
"""Статическая проба 117 v2 (CMP-MOB-006, сужение до splash + иконка):
иконка, нативный splash (ОДИН знак на ground схемы + JS-оверлей кадра окна),
сценарий Maestro splash/First-Run.

Без --model на до-предметном дереве — rc1 VKHOD_SPLASH_COMPOSITE_ABSENT.
С --model/честным C — rc0: производные иконки — канон ЦЕЛЫМ изображением
и не шаблон Expo (sha базы B); splash-плагин несёт знак (imageWidth =
ширина знака артборда, литерал) светлым корнем И тёмным блоком;
КОМПОЗИТ оверлея судится ЭТАЛОНОМ — read-only артборды Splash.png/
Splash-Hell.png, припиненные sha256 (несовпадение — rc2 ORACLE_TAMPERED):
размер = артборд 390x844, recall по ВСЕЙ маске / precision по ВСЕМ
непрозрачным пикселям >= 0.98 (Б1), и PilotApp ПОТРЕБЛЯЕТ ровно эти файлы
(SPLASH_OVERLAY_CONSUMES_COMPOSITE, С2-а);
ГЕОМЕТРИЯ оверлея: сегмент JSX оверлея в PilotApp не несёт transform
(любой) и смещений layout сверх канона (SPLASH_OVERLAY_NO_TRANSFORM,
SPLASH_OVERLAY_NO_LAYOUT_OFFSET — Adv117v2, круг по реализации);
z-ПОРЯДОК оверлея: zIndex >= 1 в сегменте JSX + позиция ПОЗЖЕ
FirstRunScreen (SPLASH_OVERLAY_ZORDER — Adv117v3, круг по реализации);
произведённые платформой ассеты судятся ВЫХОДОМ настоящего генератора
(getAndroidSplashConfig + setSplashImageDrawablesAsync из node_modules
продукта): содержимое drawable-{mdpi..xxxhdpi}/splashscreen_logo.png и
drawable-night-* обеих тем (знак канона, альфа-bbox = imageWidth*mult ±3),
iOS — содержимое по эффективному пути + эффективные imageWidth/resizeMode
клеткой SPLASH_EFFECTIVE_IOS и рамка storyboard настоящего генератора без
legacy-режима (SPLASH_IOS_STORYBOARD); basename НЕ сравнивается (Б2).
Оракул — литералы source.json. Вход F03.01/F03.02 выведен в first-run-ekran
(117 v2, сужение до splash + иконка): клеток входа в статической семье нет.
--matrix: обманные стабы статической семьи красны именованной клеткой;
шаблонные байты базы B — припиненные base_b/ (sha = литералы source.json),
не из --repo (круг 6, Р8). Круг 6 (Р2/Р3): сценарий Maestro судится
ПОРЯДКОМ шагов YAML-парсером (MAESTRO_SPLASH_FRAME_WAIT,
MAESTRO_FIRST_RUN_ORDER), комментарий шагом не является. Видимость кадра
splash на устройстве судит сверка кадра e2e с макетом (123):
SPLASH_FRAME_SVERKA_123_{DARK,LIGHT} — согласованность справочного
манифеста H kadry_117.json с пинами 117 (sha макетов, id, имя снимка,
порог не ниже литерала, снимок снят сценарием); потребление судят
SVERKA_123_{STEP_UNCONDITIONAL,MANIFEST_CANON,HARNESS_PIN} — шаг сверки
123 в задаче e2e-splash workflow субъекта стоит безусловно и исполняет
канонический манифест пина .harness123 (РЕШЕНИЕ арбитра (б)).
117 v4 (класс B, слово владельца 2026-10-27; ПЕРЕСМОТР (Г′) по живой пробе
(Г) run 40497913252/job 122172034122: host-ссылка complior://e2e-splash-hold
разобрана expo-router как ПУТЬ /e2e-splash-hold → динамический
(tabs)/[section].tsx рендерит null (сегмент вне TAB_ORDER, :62–65,100) →
PilotApp НЕ монтирован → hideAsync не вызван → нативный splash залип 15 с,
флоу 117 красен). Канал (Г′): ссылка ведёт на СУЩЕСТВУЮЩИЙ маршрут — КОРЕНЬ
«/» (index.tsx монтирует PilotApp безусловно), маркер — в query
(complior:///?e2e=splash-hold). Клетки классов входов ссылки:
SPLASH_HOLD_LINK_ROUTE_MOUNT (литерал канала — корень+query: host-часть
пути ПУСТА; host-форма — несуществующий маршрут), REPLAY_SPLASH_WHILE_OVERLAY
(реплей: нерамочный старт — оверлей НЕ монтируется, исход NO_PILOT),
REPLAY_LIVE_PROBA_G (живые свидетели провала (Г): кадр нативного splash +
hierarchy json без узлов содержимого + logcat-фрагмент, sha256 припинены),
SPLASH_OVERLAY_HOLD_NE_NEMARSHRUT_{DARK,LIGHT} (поведенческая: URL
несуществующего маршрута удержания НЕ взводит — прод-таймер 1200).
Правка по FAIL критика v4 круг 1: холодный старт канала судится
СОСТОЯНИЕМ «приложение запущено» по последовательности команд
(_cold_start_state), а НЕ суммой команд; классы порядка судят
порождаемые раннером клетки MAESTRO_HOLD_PORJADOK_* (2 перестановки,
вставки, 2 удаления, оба обхода критика, честная цепочка и контроли
арбитража — ожидания литералами до субъекта). Правка по FAIL критика
v4 круг 3 (contracts-117-v4-krug3): ЕДИНЫЙ классификатор запуска
_is_launching (launchApp словарём и скаляром, runFlow — консервативно
любой, openLink любой) — ДО ссылки и НА ИНТЕРВАЛЕ openLink → ожидание;
прежний интервальный предикат (только launchApp-словарь) пропускал
запуск через runFlow/скалярный launchApp между hold-ссылкой и
ожиданием (ложная зелень rc0), семья порядка расширена ×10 → ×15
(4 красных класса запускающего шага на интервале + зелёный контроль
не запускающего шага), стаб splash-hold-runflow-posle-link.
Выход — только код возврата; перечень case построчно.
"""
import argparse
import hashlib
import json
import re
import shlex
import struct
import subprocess
import shutil
import sys
try:
    import yaml
except ImportError:  # fail-closed: без парсера порядок шагов не судится
    yaml = None
import zlib
from pathlib import Path

from probe_lib import HERE, installed, load_source, model_bytes

CASES = []
INFRASTRUCTURE = []

# Замороженные sha шаблонных Expo-ассетов базы B 8748a7a335 (source.json).
TEMPLATE_SHAS = None


SPLASH_EFFECTIVE_JS = """'use strict';
// 117: эффективная нативная конфигурация splash настоящими резолверами
// expo-splash-screen (~57.0.10) — той же логикой, которой prebuild выбирает
// платформенные значения, включая dark-блок (выбор темы ОС).
const fs = require('fs');
const path = require('path');
const pkg = path.join(__dirname, 'node_modules', 'expo-splash-screen');
const {getAndroidSplashConfig} = require(path.join(pkg, 'plugin', 'build', 'getAndroidSplashConfig.js'));
const {getIosSplashConfig} = require(path.join(pkg, 'plugin', 'build', 'getIosSplashConfig.js'));
// Б2 (круг критика 3): iOS-рамка картинки судится ВЫХОДОМ настоящего
// генератора storyboard (getTemplateAsync + applySplashScreenStoryboard).
const {getTemplateAsync} = require(path.join(pkg, 'plugin', 'build', 'withIosSplashScreenStoryboard.js'));
const {applySplashScreenStoryboard} = require(path.join(pkg, 'plugin', 'build', 'withIosSplashScreenStoryboardImage.js'));
const app = JSON.parse(fs.readFileSync(path.join(__dirname, 'app.json'), 'utf8'));
const entry = (app.expo.plugins || []).find((p) => Array.isArray(p) && p[0] === 'expo-splash-screen');
if (!entry) {
  console.log(JSON.stringify({error: 'NO_SPLASH_PLUGIN'}));
} else {
  const props = entry[1] || {};
  const android = getAndroidSplashConfig(props);
  const ios = getIosSplashConfig(props);
  // «enableFullScreenImage_legacy отсутствует» (арбитраж круга 2 §3 Б2):
  // где ключ присутствует в props плагина — getIosSplashConfig сливает
  // {...rest, ...ios}; dark-блоки перечислены для полноты.
  const KEY = 'enableFullScreenImage_legacy';
  const legacyAt = [];
  for (const [where, obj] of [['root', props], ['ios', props.ios], ['dark', props.dark],
                              ['ios.dark', (props.ios || {}).dark]]) {
    if (obj && typeof obj === 'object' && Object.prototype.hasOwnProperty.call(obj, KEY)) {
      legacyAt.push(where);
    }
  }
  const out = {
    android: {
      light: {bg: android.backgroundColor, image: android.image, imageWidth: android.imageWidth, resizeMode: android.resizeMode},
      dark: {bg: (android.dark || {}).backgroundColor, image: (android.dark || {}).image},
    },
    ios: {
      light: {bg: ios.backgroundColor, image: ios.image, imageWidth: ios.imageWidth, resizeMode: ios.resizeMode},
      dark: {bg: (ios.dark || {}).backgroundColor, image: (ios.dark || {}).image},
      legacy_at: legacyAt,
      legacy_eff: ios[KEY],
      storyboard: null,
    },
  };
  getTemplateAsync().then((template) => {
    const sb = applySplashScreenStoryboard(template, ios);
    const view = sb.document.scenes[0].scene[0].objects[0].viewController[0].view[0];
    const iv = (((view.subviews || [])[0] || {}).imageView) || [];
    const rect = iv.length && iv[0].rect ? iv[0].rect[0].$ : null;
    const cons = (((view.constraints || [])[0] || {}).constraint) || [];
    out.ios.storyboard = {
      width: rect ? Number(rect.width) : null,
      height: rect ? Number(rect.height) : null,
      constraints: cons.map((c) => String(c.$.firstAttribute)).sort(),
    };
  }).catch((e) => {
    out.ios.storyboard = {error: 'IOS_STORYBOARD ' + e};
  }).then(() => console.log(JSON.stringify(out)));
}
"""


# Б2 (арбитраж круга 2): настоящий генератор нативных drawable —
# setSplashImageDrawablesAsync(conf, projectRoot) пишет
# res/drawable-{dpi}/splashscreen_logo.png (light) и drawable-night-{dpi}
# (dark) на холст 288*mult, знак contain в imageWidth*mult, смещение
# (288-imageWidth)/2*mult (withAndroidSplashImages.js:89-100). projectRoot —
# временный каталог с symlink assets на ассеты субъекта: записи в R нет,
# содержимое читается у субъекта по его же путям.
SPLASH_GENERATE_JS = """'use strict';
const fs = require('fs');
const path = require('path');
const mobile = path.resolve(process.argv[2]);
const projectRoot = path.resolve(process.argv[3]);
const {createRequire} = require('module');
const req = createRequire(path.join(mobile, 'package.json'));
const pkg = req.resolve('expo-splash-screen/package.json');
const build = path.join(path.dirname(pkg), 'plugin', 'build');
const {getAndroidSplashConfig} = require(path.join(build, 'getAndroidSplashConfig.js'));
const {setSplashImageDrawablesAsync} = require(path.join(build, 'withAndroidSplashImages.js'));
const app = JSON.parse(fs.readFileSync(path.join(mobile, 'app.json'), 'utf8'));
const entry = (app.expo.plugins || []).find((p) => Array.isArray(p) && p[0] === 'expo-splash-screen');
if (!entry) {
  console.error('NO_SPLASH_PLUGIN');
  process.exit(3);
}
const conf = getAndroidSplashConfig(entry[1] || {});
setSplashImageDrawablesAsync(conf, projectRoot).then(
  () => console.log('GENERATED ' + projectRoot),
  (e) => { console.error('' + e); process.exit(4); },
);
"""


def check(good: bool, case: str):
    CASES.append((case, good))


def effective_splash(repo: Path):
    """Эффективные splash-фоны обеих платформ и тем; None => INFRASTRUCTURE."""
    mobile = repo / 'mobile'
    for rel in ('node_modules/expo-splash-screen/plugin/build/getAndroidSplashConfig.js',
                'node_modules/expo-splash-screen/plugin/build/getIosSplashConfig.js'):
        if not (mobile / rel).exists():
            INFRASTRUCTURE.append('splash resolver отсутствует: ' + rel)
            return None
    script = mobile / '__117_splash_effective__.js'
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

    Чистый python (zlib+struct): сигнатура, CRC каждого чанка, IHDR
    (8-bit RGBA, без interlace), полнота IDAT, все пять фильтров.
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
                left = line[i - 4] if i >= 4 else 0
                line[i] = (line[i] + ((left + prev[i]) >> 1)) & 0xFF
        elif f == 4:
            for i in range(stride):
                a = line[i - 4] if i >= 4 else 0
                b = prev[i]
                c = prev[i - 4] if i >= 4 else 0
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pred = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[i] = (line[i] + pred) & 0xFF
        else:
            raise ValueError(f'FILTER {f}')
        out[y * stride:(y + 1) * stride] = line
        prev = line
    return w, h, bytes(out)


def px(w, h, data, x, y):
    stride = w * 4
    i = y * stride + 4 * x
    return tuple(data[i:i + 3]) + (data[i + 3],)


def near(color, target, tol=12):
    return all(abs(a - b) <= tol for a, b in zip(color[:3], target))

# ---- Б1 (круг 2): аналитическая растеризация геометрии канона ----------
# Ожидаемый растр строится из SVG-литералов source.json (complior-app-icon
# .svg / complior-mark-*.svg), НЕ из файла субъекта: классы пиксела —
# dot/ink/фон/прозрачно — вычисляются по геометрии; сравнение ЦЕЛОЕ
# (согласие классов+цветов, покрытие классов, альфа-bbox). Подложки-близнецы
# критика (3/2 пиксела, шаблонные производные) красны покрытием и согла-
# сием, «ещё одна точка» ничего не спасает.

def _hex3toRGB(value: str):
    return tuple(int(value[i:i + 2], 16) for i in (1, 3, 5))


def _mark_class_fn(geom, scale, offx, offy):
    """Пиксель → класс знака в координатах viewBox 96 (dot/ink/пусто)."""
    import math
    acx, acy = geom['arc_center']
    r_in = geom['arc_radius'] - geom['arc_stroke_width'] / 2
    r_out = geom['arc_radius'] + geom['arc_stroke_width'] / 2
    dcx, dcy = geom['dot_center']
    dot_r = geom['dot_radius']
    # открытие C: короткая дуга между концами пути M72 26 A30 30 1 0 66 70
    start = math.atan2(26 - 45.3, 72 - 49.0)
    end = math.atan2(70 - 45.3, 66 - 49.0)

    def fn(x, y):
        vbx = (x - offx) / scale
        vby = (y - offy) / scale
        ddx = vbx - dcx
        ddy = vby - dcy
        if ddx * ddx + ddy * ddy <= dot_r * dot_r:
            return 3
        ax = vbx - acx
        ay = vby - acy
        d2 = ax * ax + ay * ay
        if r_in * r_in <= d2 <= r_out * r_out:
            t = math.atan2(ay, ax)
            while t < start:
                t += 2 * math.pi
            if t >= end:
                return 2
        return 0
    return fn


def _icon_class_fn(size, icon):
    """Пиксель → класс иконки (dot/ink/bg/прозрачно) на масштабе size."""
    s = size / icon['size']
    rx = icon['corner_radius'] * s
    gs = 7.3333 * s
    gox = 160.0 * s
    goy = 160.0 * s
    geom_mark = _mark_class_fn(load_source()['mark_geometry_96'], gs, gox, goy)

    def inside_rounded(x, y):
        if x < 0 or y < 0 or x >= size or y >= size:
            return False
        cx = min(max(x, rx), size - rx)
        cy = min(max(y, rx), size - rx)
        dx = x - cx
        dy = y - cy
        return dx * dx + dy * dy <= rx * rx

    def fn(x, y):
        vb = geom_mark(x, y)
        if vb:
            return vb
        return 1 if inside_rounded(x, y) else 0
    return fn


def _classify_asset(pxv, palette):
    r, g, b, a = pxv
    if a < 32:
        return 0
    best, bd = None, 1 << 30
    for cls, color in palette.items():
        d = abs(r - color[0]) + abs(g - color[1]) + abs(b - color[2])
        if d < bd:
            best, bd = cls, d
    return best if bd <= 90 else 4


def raster_whole_match(blob, cls_fn, palette, thresholds):
    """Целостное сравнение растра с аналитикой: согласие ≥ agree_min,
    покрытие каждого класса (кроме пустого) в полосе, альфа-bbox ± tol."""
    try:
        w, h, data = decode_png_rgba(blob)
    except ValueError:
        return False, {'decode': 'fail'}
    stride = w * 4
    agree = 0
    n = w * h
    asset_counts = {}
    exp_counts = {}
    alpha_xs, alpha_ys = [], []
    for y in range(h):
        base = y * stride
        for x in range(w):
            i = base + 4 * x
            pxv = (data[i], data[i + 1], data[i + 2], data[i + 3])
            acls = _classify_asset(pxv, palette)
            ecls = cls_fn(x + 0.5, y + 0.5)
            asset_counts[acls] = asset_counts.get(acls, 0) + 1
            exp_counts[ecls] = exp_counts.get(ecls, 0) + 1
            if acls == ecls:
                agree += 1
            elif acls != 4 and any(cls_fn(x + 0.5 + jx, y + 0.5 + jy) == acls
                                   for jx, jy in ((-0.75, -0.75), (0.75, -0.75), (-0.75, 0.75), (0.75, 0.75))):
                agree += 1
            if pxv[3] > 32:
                alpha_xs.append(x)
                alpha_ys.append(y)
    ratio = agree / n
    ok = ratio >= thresholds['agree_min']
    lo, hi = thresholds['coverage_band']
    for cls in (1, 2, 3):
        exp = exp_counts.get(cls, 0)
        if exp < 200:
            continue
        got = asset_counts.get(cls, 0)
        if not lo <= got / exp <= hi:
            ok = False
    if alpha_xs:
        ax0, ay0, ax1, ay1 = min(alpha_xs), min(alpha_ys), max(alpha_xs), max(alpha_ys)
        tol = thresholds['bbox_tol']
        # ожидаемый альфа-bbox: по аналитике (классы 1..3)
        exp_alpha = _analytic_alpha_bbox(cls_fn, w, h)
        if exp_alpha:
            for got_v, exp_v in zip((ax0, ay0, ax1, ay1), exp_alpha):
                if abs(got_v - exp_v) > tol:
                    ok = False
    return ok, {'ratio': round(ratio, 4), 'asset': asset_counts, 'expected': exp_counts}


def _analytic_alpha_bbox(cls_fn, w, h):
    xs, ys = [], []
    for y in range(h):
        for x in range(w):
            if cls_fn(x + 0.5, y + 0.5):
                xs.append(x)
                ys.append(y)
    if not xs:
        return None
    return [min(xs), min(ys), max(xs), max(ys)]


def _png_bytes(w, h, pixels):
    """Минимальный RGBA PNG (filter 0) — для обманных близнецов матрицы."""
    rows = bytearray()
    for y in range(h):
        rows.append(0)
        rows.extend(pixels[y * w * 4:(y + 1) * w * 4])

    def chunk(ctype, data):
        return struct.pack('>I', len(data)) + ctype + data + struct.pack(
            '>I', zlib.crc32(ctype + data) & 0xFFFFFFFF)

    blob = b'\x89PNG\r\n\x1a\n'
    blob += chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
    blob += chunk(b'IDAT', zlib.compress(bytes(rows), 9))
    blob += chunk(b'IEND', b'')
    return blob


def _twin_png(src_blob, keep_points):
    """Прозрачная копия размера исходника с сохранёнными цветами в точках."""
    w, h, data = decode_png_rgba(src_blob)
    out = bytearray(w * h * 4)
    stride = w * 4
    for x, y in keep_points:
        i = y * stride + 4 * x
        out[i:i + 4] = data[i:i + 4]
    return _png_bytes(w, h, out)


def decode_png_any_rgb(path):
    """PNG RGB(A) → (w, h, rgb-байты по 3 на пиксель) — эталоны артбордов
    записаны в color type 2 (RGB). ValueError — именованный отказ."""
    blob = path.read_bytes()
    if not blob.startswith(b'\x89PNG\r\n\x1a\n'):
        raise ValueError('PNG_SIGNATURE')
    pos = 8
    idat = bytearray()
    ihdr = None
    while pos + 8 <= len(blob):
        length, ctype = struct.unpack('>I4s', blob[pos:pos + 8])
        data = blob[pos + 8:pos + 8 + length]
        crc = struct.unpack('>I', blob[pos + 8 + length:pos + 12 + length])[0]
        if zlib.crc32(ctype + data) & 0xFFFFFFFF != crc:
            raise ValueError('CHUNK_CRC ' + ctype.decode('latin1'))
        if ctype == b'IHDR':
            ihdr = struct.unpack('>IIBBBBB', data)
        elif ctype == b'IDAT':
            idat += data
        pos += 12 + length
    if ihdr is None:
        raise ValueError('IHDR_ABSENT')
    w, h, depth, color, comp, flt, inter = ihdr
    if depth != 8 or color not in (2, 6) or comp or flt or inter:
        raise ValueError(f'IHDR_MODE w={w} h={h} color={color}')
    raw = zlib.decompress(bytes(idat))
    nch = 3 if color == 2 else 4
    stride = w * nch
    if len(raw) != h * (1 + stride):
        raise ValueError('IDAT_LEN')
    out = bytearray()
    prev = bytearray(stride)
    for y in range(h):
        f = raw[y * (1 + stride)]
        line = bytearray(raw[y * (1 + stride) + 1:(y + 1) * (1 + stride)])
        if f == 1:
            for i in range(nch, stride):
                line[i] = (line[i] + line[i - nch]) & 0xFF
        elif f == 2:
            for i in range(stride):
                line[i] = (line[i] + prev[i]) & 0xFF
        elif f == 3:
            for i in range(stride):
                left = line[i - nch] if i >= nch else 0
                line[i] = (line[i] + ((left + prev[i]) >> 1)) & 0xFF
        elif f == 4:
            for i in range(stride):
                a = line[i - nch] if i >= nch else 0
                b = prev[i]
                c = prev[i - nch] if i >= nch else 0
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pred = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[i] = (line[i] + pred) & 0xFF
        elif f != 0:
            raise ValueError(f'FILTER {f}')
        out += line
        prev = line
    if color == 6:
        return w, h, bytes(bytearray(
            b for i, b in enumerate(out) if i % 4 != 3))
    return w, h, bytes(out)


def etalon_of(repo: Path, spec):
    """Эталон артборда с sha-пином (правило 8/Н-351): несовпадение sha256 —
    тамpered-оракул, rc2 ORACLE_TAMPERED (не зелень). Возвращает
    (w, h, mask bytearray 0/1, rgb bytes 3/px)."""
    path = repo / spec['path']
    if not path.is_file():
        raise EtalonError('ORACLE_TAMPERED: эталона нет: ' + spec['path'])
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    if digest != spec['sha256']:
        raise EtalonError('ORACLE_TAMPERED: sha256 ' + spec['path'] + ' = ' + digest)
    w, h, rgb = decode_png_any_rgb(path)
    bgc = _hex3toRGB(spec['bg'])
    tol = spec.get('_bg_tol', 40)
    mask = bytearray(w * h)
    for p in range(w * h):
        r, g, b = rgb[3 * p], rgb[3 * p + 1], rgb[3 * p + 2]
        if abs(r - bgc[0]) <= tol and abs(g - bgc[1]) <= tol and abs(b - bgc[2]) <= tol:
            mask[p] = 0
        else:
            mask[p] = 1
    return w, h, mask, rgb


class EtalonError(Exception):
    pass


def composite_etalon_match(blob, etalon, ref):
    """Б1 (арбитраж круга 2; круг критика 3): композит = эталон ЦЕЛОЙ
    поверхностью. E — маска артборда (фон±bg_tol прозрачен). Субъект C
    обязан иметь РАЗМЕР эталона (литерал ref['size'] = 390x844): иной
    масштаб при точном aspect теряет маску (свидетель круга 3 — 195x422:
    recall по всей маске 0.88) и красен именованной причиной. recall =
    доля ВСЕХ пикселей M (E непрозрачен), где C непрозрачен (alpha>=
    subject_alpha_min) и |RGB(C)-RGB(E)|<=color_tol; precision = доля
    ВСЕХ непрозрачных пикселей C, попавших в M с тем же цветом. Пороги
    >=0.98. Выборки нет: m_total = |M| (тёмный 15439, светлый 15346)."""
    try:
        cw, ch, data = decode_png_rgba(blob)
    except ValueError as err:
        return False, str(err)
    ew, eh, mask, ergb = etalon
    sw, sh = ref['size']
    if (ew, eh) != (sw, sh):
        return False, f'эталон {ew}x{eh} != литерал {sw}x{sh}'
    if (cw, ch) != (ew, eh):
        return False, f'размер {cw}x{ch} != эталон {ew}x{eh} (масштаб теряет маску)'
    amin = ref['subject_alpha_min']
    ctol = ref['color_tol']
    m_total = 0
    c_op = 0
    hit = 0
    for p in range(ew * eh):
        ci = 4 * p
        cop = data[ci + 3] >= amin
        inm = mask[p]
        m_total += inm
        c_op += cop
        if inm and cop:
            ei = 3 * p
            if (abs(data[ci] - ergb[ei]) <= ctol and abs(data[ci + 1] - ergb[ei + 1]) <= ctol
                    and abs(data[ci + 2] - ergb[ei + 2]) <= ctol):
                hit += 1
    if not m_total or not c_op:
        return False, f'пустая сторона M={m_total} C={c_op}'
    recall = hit / m_total
    precision = hit / c_op
    ok = recall >= ref['recall_min'] and precision >= ref['precision_min']
    return ok, {'recall': round(recall, 4), 'precision': round(precision, 4),
                'm_total': m_total, 'c_op': c_op}


def _sign_class_fn(sign):
    """Класс пикселя кропа знака (181x173): 3 точка / 2 кольцо / 0 пусто —
    геометрия splash_sign source.json (замер по артбордам, Б2)."""
    import math
    (cx, cy) = sign['ring_center']
    r_out = sign['ring_outer_r']
    r_in = r_out - sign['ring_thickness']
    (dx, dy) = sign['dot_center']
    dr = sign['dot_radius']
    g0, g1 = (math.radians(v) for v in sign['gap_deg'])

    def fn(x, y):
        ddx = x - dx
        ddy = y - dy
        if ddx * ddx + ddy * ddy <= dr * dr:
            return 3
        d2 = (x - cx) ** 2 + (y - cy) ** 2
        if r_in * r_in <= d2 <= r_out * r_out:
            t = math.atan2(y - cy, x - cx)
            while t < g0:
                t += 2 * math.pi
            if t >= g1:
                return 2
        return 0
    return fn


def _drawable_class_fn(sign, mult, image_width, canvas):
    """Класс пикселя ПРОИЗВЕДЁННОГО drawable (холст canvas*mult): знак
    contain в image_width*mult, смещение (canvas-image_width)/2*mult по X
    и Y + центрирование высоты знака внутри квадрата (логика
    withAndroidSplashImages: фон cover canvas, foreground contain size)."""
    inner = _sign_class_fn(sign)
    off = (canvas - image_width) / 2.0
    dy_extra = (image_width - sign['size'][1]) / 2.0

    def fn(x, y):
        return inner(x / mult - off, y / mult - off - dy_extra)
    return fn


def generate_drawables(repo: Path):
    """Б2: настоящий setSplashImageDrawablesAsync во временный projectRoot
    (symlink assets → субъект); возвращает Path или None (INFRASTRUCTURE)."""
    import os
    import shutil
    import tempfile
    mobile = repo / 'mobile'
    if not (mobile / 'node_modules/expo-splash-screen/plugin/build/withAndroidSplashImages.js').exists():
        INFRASTRUCTURE.append('splash generator отсутствует в node_modules')
        return None
    tmp = Path(tempfile.mkdtemp(prefix='vkhod117-native-'))
    script = tmp / '__117_splash_generate__.cjs'
    script.write_text(SPLASH_GENERATE_JS, encoding='utf-8')
    try:
        os.symlink(mobile / 'assets', tmp / 'assets')
    except OSError as err:
        INFRASTRUCTURE.append('symlink assets: ' + repr(err))
        shutil.rmtree(tmp, ignore_errors=True)
        return None
    try:
        proc = subprocess.run(['node', str(script), str(mobile), str(tmp)],
                              cwd=tmp, capture_output=True, text=True, timeout=180)
    except (OSError, subprocess.SubprocessError) as err:
        INFRASTRUCTURE.append('splash generator не исполнился: ' + repr(err))
        shutil.rmtree(tmp, ignore_errors=True)
        return None
    if proc.returncode != 0:
        INFRASTRUCTURE.append('splash generator rc=' + str(proc.returncode)
                              + ' stderr=' + proc.stderr[-300:])
        shutil.rmtree(tmp, ignore_errors=True)
        return None
    return tmp


def _shift_image(src_blob, dy):
    """Копия композита: ВСЁ содержимое сдвинуто на dy строк (стаб
    «сдвиг 9 px» для матрицы: полосы/bbox на месте НЕ остаются)."""
    w, h, data = decode_png_rgba(src_blob)
    out = bytearray(w * h * 4)
    for y in range(h):
        ny = y + dy
        if 0 <= ny < h:
            out[ny * w * 4:(ny + 1) * w * 4] = data[y * w * 4:(y + 1) * w * 4]
    return _png_bytes(w, h, out)


def _erase_rows_png(src_blob, y0, y1):
    """Копия композита: строки [y0, y1] стёрты (стаб «знак без надписей»:
    wordmark и tagline удалены, знак честный)."""
    w, h, data = decode_png_rgba(src_blob)
    out = bytearray(data)
    for y in range(y0, y1 + 1):
        out[y * w * 4:(y + 1) * w * 4] = bytes(w * 4)
    return _png_bytes(w, h, out)


def _halfres_png(src_blob):
    """Копия композита в половинном масштабе при ТОЧНОМ aspect (свидетель
    критика круга 3 halfres-{dark,light}: 195x422, пиксель (x, y) =
    исходный (2x, 2y)) — прежняя решётка C проходила, вся маска — нет."""
    w, h, data = decode_png_rgba(src_blob)
    hw, hh = w // 2, h // 2
    out = bytearray(hw * hh * 4)
    for y in range(hh):
        for x in range(hw):
            si = 4 * (2 * y * w + 2 * x)
            di = 4 * (y * hw + x)
            out[di:di + 4] = data[si:si + 4]
    return _png_bytes(hw, hh, out)


def run_checks(repo: Path):
    src = load_source()
    global TEMPLATE_SHAS
    TEMPLATE_SHAS = src['template_shas_base_8748a7a335']
    mobile = repo / 'mobile'
    app = json.loads((mobile / 'app.json').read_text(encoding='utf-8'))
    expo = app['expo']

    # 1. Все производные иконки объявлены и существуют; корневая иконка — не
    # шаблонные байты Expo (sha ≠ замороженного литерала базы B).
    icon_rel = expo.get('icon', '')
    adaptive = (expo.get('android') or {}).get('adaptiveIcon') or {}
    favicon_rel = ((expo.get('web') or {}).get('favicon') or '')
    paths = [icon_rel, adaptive.get('foregroundImage', ''),
             adaptive.get('backgroundImage', ''), adaptive.get('monochromeImage', ''),
             favicon_rel]
    all_exist = all(p and (mobile / p).exists() for p in paths)
    check(all_exist, 'APP_ICON_DERIVATIVES')
    icon_sha = hashlib.sha256((mobile / icon_rel).read_bytes()).hexdigest() if icon_rel else ''
    check(icon_sha != TEMPLATE_SHAS['icon.png'], 'ICON_NOT_TEMPLATE_BYTES')

    # 2. adaptiveIcon фон — #0A0A0A (ground dark канона), не Expo #E6F4FE.
    check(adaptive.get('backgroundColor') == src['appjson_literals']['adaptive_bg'],
          'ICON_ADAPTIVE_BG_DARK')

    # 3. Пиксельные свойства иконки (геометрия complior-app-icon.svg:
    # translate(160,160) scale(7.3333) → точка (717,644) #d6f75a, верх дуги
    # (519,272) ink dark, фон (512,80) #0a0a0a).
    icon_blob = (mobile / icon_rel).read_bytes()
    icon_ok = False
    try:
        w, h, data = decode_png_rgba(icon_blob)
        dot = src['app_icon']['probe_pixels']['dot']
        arc = src['app_icon']['probe_pixels']['arc_top']
        bgp = src['app_icon']['probe_pixels']['bg']
        dot_c = tuple(int(src['mark_geometry_96']['dot_color'][i:i + 2], 16) for i in (1, 3, 5))
        ink_c = tuple(int(src['tokens']['ink']['dark'][i:i + 2], 16) for i in (1, 3, 5))
        ground_c = tuple(int(src['app_icon']['bg'][i:i + 2], 16) for i in (1, 3, 5))
        icon_ok = (
            w == src['app_icon']['size'] and h == src['app_icon']['size']
            and near(px(w, h, data, *dot), dot_c)
            and near(px(w, h, data, *arc), ink_c)
            and near(px(w, h, data, *bgp), ground_c)
        )
    except ValueError as err:
        print('RED ICON_PIXELS_MARK_DECODES:', err)
    check(icon_ok, 'ICON_PIXELS_MARK')

    # 4. splash-плагин (круг 4, С2): нативный splash = ОДИН знак канона
    # на ground схемы: светлый корень (#F3F2EE, растр знака light) И
    # тёмный блок (#0A0A0A, растр знака dark), imageWidth = ширина знака
    # артборда (литерал 181), resizeMode contain.
    plugins = expo.get('plugins') or []
    entry = next((p for p in plugins if isinstance(p, list) and p[0] == 'expo-splash-screen'), None)
    props = (entry[1] if entry and len(entry) > 1 else {}) or {}
    dark = props.get('dark') or {}
    lit = src['appjson_literals']
    check(
        props.get('backgroundColor') == lit['splash_light_bg']
        and str(props.get('image', '')).endswith(lit['splash_image_light'])
        and props.get('imageWidth') == lit['splash_image_width']
        and props.get('resizeMode') == lit['splash_resize_mode']
        and dark.get('backgroundColor') == lit['splash_dark_bg']
        and str(dark.get('image', '')).endswith(lit['splash_image_dark']),
        'SPLASH_BLOCKS_DARK_LIGHT',
    )

    # 5. Эффективная нативная конфигурация — настоящими резолверами
    # expo-splash-screen: android И ios, light И dark (фоны; эффективные
    # imageWidth/resizeMode судят клетки 6а/6б — Б2).
    eff = effective_splash(repo)
    if eff is None or 'error' in eff:
        if eff is None:
            INFRASTRUCTURE.append('splash resolver: нет эффективной конфигурации')
    else:
        check(
            eff['android']['light'].get('bg') == lit['splash_light_bg']
            and eff['android']['dark'].get('bg') == lit['splash_dark_bg']
            and eff['ios']['light'].get('bg') == lit['splash_light_bg']
            and eff['ios']['dark'].get('bg') == lit['splash_dark_bg'],
            'SPLASH_EFFECTIVE_DARK_LIGHT',
        )

        # 6а (Б2, арбитраж круга 2): ЗНАК нативного splash судится ВЫХОДОМ
        # настоящего генератора — произведённые drawable обеих тем и всех
        # плотностей (basename НЕ сравнивается): dims 288*mult, содержимое
        # = знак канона (аналитика splash_sign), альфа-bbox = imageWidth*
        # mult ±3 (проверено аналитическим bbox raster_whole_match).
        native = src['splash_native']
        sign = src['splash_sign']
        thresholds_sign = {'agree_min': sign['agree_min'],
                           'coverage_band': src['raster_117']['coverage_band'],
                           'bbox_tol': src['raster_117']['bbox_tol']}
        tmp = generate_drawables(repo)
        if tmp is None:
            INFRASTRUCTURE.append('splash generator: не произведено')
        else:
            import shutil
            try:
                gen_ok = True
                thresholds_content = dict(thresholds_sign)
                thresholds_content['bbox_tol'] = 10 ** 6  # позицию знака судит
                # отдельная проверка РАЗМЕРА ниже (арбитраж: bbox =
                # imageWidth×множитель ±3), не аналитический bbox
                for size, mult in native['multipliers'].items():
                    for theme, res_dir, ink_key in (
                            ('light', 'drawable', 'light_ink'),
                            ('dark', 'drawable-night', 'dark_ink')):
                        f = tmp / 'android/app/src/main/res' / f'{res_dir}-{size}' / 'splashscreen_logo.png'
                        case = f'SPLASH_NATIVE_GENERATED_{theme.upper()}_{size.upper()}'
                        if not f.is_file():
                            print('RED ' + case + ': нет файла')
                            check(False, case)
                            gen_ok = False
                            continue
                        blob = f.read_bytes()
                        try:
                            fw, fh, fdata = decode_png_rgba(blob)
                        except ValueError as err:
                            print('RED ' + case + ':', err)
                            check(False, case)
                            gen_ok = False
                            continue
                        canvas = native['canvas_base'] * mult
                        cls_fn = _drawable_class_fn(sign, mult, native['image_width'],
                                                    native['canvas_base'])
                        palette = {2: _hex3toRGB(native[ink_key]),
                                   3: _hex3toRGB(src['mark_geometry_96']['dot_color'])}
                        ok, info = raster_whole_match(blob, cls_fn, palette, thresholds_content)
                        why = []
                        if fw != canvas or fh != canvas:
                            ok = False
                            why.append(f'dims {fw}x{fh} != {canvas}')
                        # размер знака в произведённом файле: ширина =
                        # imageWidth×mult, высота = высота знака×mult (±3).
                        xs, ys = [], []
                        for y in range(fh):
                            for x in range(fw):
                                if fdata[4 * (y * fw + x) + 3] > 32:
                                    xs.append(x)
                                    ys.append(y)
                        if xs:
                            gw, gh = max(xs) - min(xs) + 1, max(ys) - min(ys) + 1
                            ew = native['image_width'] * mult
                            eh = sign['size'][1] * mult
                            if abs(gw - ew) > 3 or abs(gh - eh) > 3:
                                ok = False
                                why.append(f'знак {gw}x{gh} != {ew}x{eh}±3')
                        else:
                            ok = False
                            why.append('пустой drawable')
                        if not ok:
                            print('RED ' + case + ':', why,
                                  info if isinstance(info, str)
                                  else (info.get('ratio'), info.get('asset')))
                        check(ok, case)
                        gen_ok = gen_ok and ok
                check(gen_ok, 'SPLASH_NATIVE_GENERATED')
            finally:
                shutil.rmtree(tmp, ignore_errors=True)

        # 6б (Б2): iOS — содержимое по ЭФФЕКТИВНОМУ пути (light/dark) тем
        # же растровым критерием знака + эффективные imageWidth/resizeMode
        # из резолвера, не из props.
        for variant, eff_img_key in (('LIGHT', 'light'), ('DARK', 'dark')):
            eff_img = str(eff['ios'][eff_img_key].get('image', ''))
            case = 'SPLASH_EFFECTIVE_IOS_' + variant
            ok = False
            info = {}
            path = mobile / eff_img if eff_img else None
            if path is not None and path.is_file():
                ink_key = 'light_ink' if variant == 'LIGHT' else 'dark_ink'
                palette = {2: _hex3toRGB(native[ink_key]),
                           3: _hex3toRGB(src['mark_geometry_96']['dot_color'])}
                ok, info = raster_whole_match(path.read_bytes(), _sign_class_fn(sign),
                                              palette, thresholds_sign)
            else:
                info = 'нет файла по эффективному пути: ' + eff_img
            eff_light = eff['ios']['light']
            ok = ok and eff_light.get('imageWidth') == native['image_width'] \
                and eff_light.get('resizeMode') == lit['splash_resize_mode']
            if not ok:
                print('RED ' + case + ':', info)
            check(ok, case)

        # 6б' (Б2, круг критика 3; арбитраж круга 2 §3: «enableFullScreen
        # Image_legacy отсутствует»): литерал ОТСУТСТВИЯ ключа в props
        # плагина (корень/ios/dark/ios.dark), эффективное значение false и
        # ВЫХОД настоящего генератора storyboard: рамка картинки
        # imageWidth×imageWidth (181×181) с constraints ровно centerX/centerY
        # (legacy-режим даёт 414×736 и краевые top/leading/trailing/bottom).
        sb_lit = native['ios_storyboard']
        ios_eff = eff['ios']
        sb = ios_eff.get('storyboard') or {}
        ok = (ios_eff.get('legacy_at') == sb_lit['legacy_at']
              and ios_eff.get('legacy_eff') is sb_lit['legacy_eff']
              and 'error' not in sb
              and [sb.get('width'), sb.get('height')] == sb_lit['image_rect']
              and sb.get('constraints') == sb_lit['constraints'])
        if not ok:
            print('RED SPLASH_IOS_STORYBOARD:', ios_eff.get('legacy_at'),
                  ios_eff.get('legacy_eff'), sb)
        check(ok, 'SPLASH_IOS_STORYBOARD')

    # 6в (Б1, арбитраж круга 2): композит JS-оверлея = ЭТАЛОН артборда
    # целой поверхностью (sha-пин; recall/precision >= 0.98); полосы
    # artboard_117 остаются дешёвой первой линией и в критерий не входят.
    ref = src['splash_reference']
    for variant, et_key in (('DARK', 'dark'), ('LIGHT', 'light')):
        case = 'SPLASH_COMPOSITE_ETALON_' + variant
        try:
            etalon = etalon_of(repo, ref['etalons'][et_key])
        except EtalonError as err:
            print(err)
            INFRASTRUCTURE.append(str(err))
            continue
        comp = mobile / 'assets/images' / f'splash-composite-{"dark" if variant == "DARK" else "light"}.png'
        ok, info = composite_etalon_match(comp.read_bytes() if comp.is_file() else b'',
                                          etalon, ref)
        if not ok:
            print('RED ' + case + ':', info)
        check(ok, case)

        # 6г (Б2): растр знака нативного splash (файл, на который ссылается
        # плагин) — знак канона ЦЕЛЫМ изображением (та же аналитика).
        rel = str(props.get('image', '')) if variant == 'LIGHT' else str(dark.get('image', ''))
        case = 'SPLASH_SIGN_RASTER_' + variant
        sign_path = mobile / rel if rel else None
        ok, info = (raster_whole_match(sign_path.read_bytes(), _sign_class_fn(sign),
                                       {2: _hex3toRGB(native['light_ink' if variant == 'LIGHT' else 'dark_ink']),
                                        3: _hex3toRGB(src['mark_geometry_96']['dot_color'])},
                                       thresholds_sign)
                    if sign_path is not None and sign_path.is_file() else (False, 'нет файла'))
        if not ok:
            print('RED ' + case + ':', info.get('ratio') if isinstance(info, dict) else info,
                  info.get('asset') if isinstance(info, dict) else '')
        check(ok, case)

    # 6д (С2-а, круг критика 3): оверлей ПОТРЕБЛЯЕТ ровно те файлы
    # композита, содержимое которых судит 6в: require в PilotApp
    # (относительный путь от каталога потребителя) разрешается в
    # mobile/assets/images/splash-composite-{dark,light}.png — литералы
    # overlay_117; подмена источника (icon.png) красна. Связь «Image
    # оверлея ↔ композит СХЕМЫ» судит поведенческая SPLASH_OVERLAY_COMPOSITE_*
    # по эффективному source Image.
    import os
    ov = src['overlay_117']
    consumer = repo / ov['consumer']
    resolved = set()
    if consumer.is_file():
        for _q, rel in re.findall(r"""require\(\s*(['"])([^'"]+)\1\s*\)""",
                                  consumer.read_text(encoding='utf-8')):
            if rel.startswith('.'):
                resolved.add(os.path.normpath(str(consumer.parent / rel)))
    want = {os.path.normpath(str(repo / p)) for p in ov['composites'].values()}
    ok = bool(want) and want <= resolved
    if not ok:
        print('RED SPLASH_OVERLAY_CONSUMES_COMPOSITE:', sorted(want - resolved))
    check(ok, 'SPLASH_OVERLAY_CONSUMES_COMPOSITE')

    # 6е (Adv117v2, круг по реализации): ГЕОМЕТРИЯ оверлея в КОДЕ
    # потребителя. Сегмент JSX оверлея (от testID до закрывающего
    # `: null}` условного рендера) не несёт степеней свободы геометрии
    # сверх канона инварианта 8 (бокс Image следует боксу оверлея,
    # содержимое центрирует resizeMode contain): ни transform (любой —
    # translateX/translateY/scale/rotate/skew, прямым ключом или
    # элементом массива стилей), ни смещений layout (margin* любого
    # значения; left/top/right/bottom ≠ 0; position ≠ 'absolute').
    # Найденный transform краснит SPLASH_OVERLAY_NO_TRANSFORM, смещение —
    # SPLASH_OVERLAY_NO_LAYOUT_OFFSET; отсутствующий сегмент краснит ОБЕ
    # (не зелень). Рендер-истина той же степени свободы — поведенческие
    # SPLASH_OVERLAY_GEOMETRY_{DARK,LIGHT} (vkhod.test.tsx).
    geo = ov['geometry']
    code = consumer.read_text(encoding='utf-8') if consumer.is_file() else ''
    seg_start = code.find('testID="' + ov['test_id'] + '"')
    seg_end = code.find(geo['jsx_end_anchor'], seg_start)
    seg = code[seg_start:seg_end] if seg_start != -1 and seg_end != -1 else None
    if seg is None:
        print('RED SPLASH_OVERLAY_NO_TRANSFORM+SPLASH_OVERLAY_NO_LAYOUT_OFFSET:'
              ' сегмент оверлея не найден в', ov['consumer'])
        check(False, 'SPLASH_OVERLAY_NO_TRANSFORM')
        check(False, 'SPLASH_OVERLAY_NO_LAYOUT_OFFSET')
    else:
        bad_tf = sorted({prop for prop in geo['forbidden_transform_props']
                         if re.search(r'\b' + re.escape(prop) + r'\s*:', seg)})
        if bad_tf:
            print('RED SPLASH_OVERLAY_NO_TRANSFORM:', bad_tf)
        check(not bad_tf, 'SPLASH_OVERLAY_NO_TRANSFORM')
        margin_re = (r'\b(' + re.escape(geo['forbidden_margin_prefix'])
                     + r'[A-Za-z]*)\s*:')
        bad_off = sorted(set().union(
            {m.group(1) for prop in geo['canon_edge_zero_props']
             for m in re.finditer(
                 r'\b' + re.escape(prop) + r'\s*:\s*([^,\n}]+)', seg)
             if m.group(1).strip() != str(geo['canon_edge_zero'])},
            {m.group(1) for m in re.finditer(margin_re, seg)},
            {"position '" + m.group(1) + "'"
             for m in re.finditer(r"\bposition\s*:\s*'([^']+)'", seg)
             if m.group(1) != geo['canon_position']},
        ))
        if bad_off:
            print('RED SPLASH_OVERLAY_NO_LAYOUT_OFFSET:', bad_off)
        check(not bad_off, 'SPLASH_OVERLAY_NO_LAYOUT_OFFSET')

    # 6ж (Adv117v3, круг по реализации): Z-ПОРЯДОК оверлея в КОДЕ
    # потребителя: инвариант 8 — оверлей рендерится ПОВЕРХ дерева
    # оболочки (последний ребёнок корня PilotApp). Находка Adv117v3:
    # `zIndex: -1` у splash-overlay проходил обе пробы (toBeVisible не
    # видит перекрытия соседом) — сплеш под полноэкранным FirstRun,
    # пользователь видит First-Run вместо Splash.png. Судит: (1) сегмент
    # JSX оверлея несёт zIndex — литеральное число >= zindex_min (не
    # отрицательное, не ноль, не отсутствует; fail-closed на
    # не-литеральном значении); (2) сегмент оверлея стоит ПОЗЖЕ вызова
    # FirstRunScreen в файле (порядок sibling: у равных zIndex порядок
    # решают узлы — оверлей рендерится после полноэкранного FirstRun).
    # Рендер-истина — поведенческие SPLASH_OVERLAY_ZORDER_{DARK,LIGHT}
    # (vkhod.test.tsx): сплющенный zIndex > zIndex корня FirstRun и
    # ветка оверлея в дереве хоста позже ветки FirstRun.
    zo = ov['zorder']
    bad_z = []
    if seg is None:
        bad_z.append('сегмент оверлея не найден')
    else:
        mz = re.search(r'\bzIndex\s*:\s*(-?\d+)\b', seg)
        if mz is None:
            bad_z.append('zIndex отсутствует/не литерал')
        elif int(mz.group(1)) < zo['zindex_min']:
            bad_z.append('zIndex ' + mz.group(1))
        fr_at = code.find(zo['firstrun_usage'])
        if fr_at == -1:
            bad_z.append(zo['firstrun_usage'] + ' не найден')
        elif seg_start < fr_at:
            bad_z.append('оверлей раньше ' + zo['firstrun_usage'])
    if bad_z:
        print('RED SPLASH_OVERLAY_ZORDER:', bad_z)
    check(not bad_z, 'SPLASH_OVERLAY_ZORDER')

    # 7. userInterfaceStyle automatic — иначе тёмный splash недостижим
    # на устройстве ( Expo выбирает блок по теме ОС).
    check(expo.get('userInterfaceStyle') == lit['user_interface_style'],
          'USER_STYLE_AUTOMATIC')

    # 10. Независимость оракула: проба несёт литералы и не импортирует
    # копию субъекта.
    probe_test = (HERE / 'vkhod.test.tsx').read_text(encoding='utf-8')
    check(
        src['overlay_117']['test_id'] in probe_test
        and src['tokens']['ground']['dark'] in probe_test
        and src['tokens']['ground']['light'] in probe_test
        and src['surface_995']['bg'] in probe_test
        and "from '@/i18n/ui-copy'" not in probe_test,
        'STATIC_ORACLE_LITERALS',
    )

    # 11–19 (Б1, круг 2): ЦЕЛОЕ изображение каждого эффективного ассета —
    # аналитическая растеризация SVG-геометрии канона (литералы
    # source.json); двойники-подложки и шаблонные производные красны.
    rt = src['raster_117']
    thresholds = {'agree_min': rt['agree_min'], 'coverage_band': rt['coverage_band'],
                  'bbox_tol': rt['bbox_tol']}
    geom = src['mark_geometry_96']
    dot_rgb = _hex3toRGB(geom['dot_color'])
    ink_dark = _hex3toRGB(src['tokens']['ink']['dark'])
    bg_rgb = _hex3toRGB(src['app_icon']['bg'])
    mono_rgb = _hex3toRGB(rt['mono_ink'])
    fg_rgb = _hex3toRGB(rt['adaptive_fg_ink'])
    place = rt['adaptive_mark']

    def raster_case(rel, cls_fn, palette, case):
        path = mobile / rel
        if not rel or not path.is_file():
            check(False, case)
            return
        ok, info = raster_whole_match(path.read_bytes(), cls_fn, palette, thresholds)
        if not ok:
            print('RED ' + case + ':', info.get('ratio'), info.get('asset'))
        check(ok, case)

    raster_case(icon_rel, _icon_class_fn(src['app_icon']['size'], src['app_icon']),
                {1: bg_rgb, 2: ink_dark, 3: dot_rgb}, 'ICON_RASTER_WHOLE')
    raster_case(adaptive.get('foregroundImage', ''), _mark_class_fn(geom, place['scale'], place['offset'], place['offset']),
                {2: fg_rgb, 3: dot_rgb}, 'ADAPTIVE_FG_RASTER')
    raster_case(adaptive.get('monochromeImage', ''), _mark_class_fn(geom, place['scale'], place['offset'], place['offset']),
                {2: mono_rgb, 3: dot_rgb}, 'ADAPTIVE_MONO_RASTER')

    # adaptive-фон: сплошной ground dark, весь непрозрачный.
    bg_ok = False
    bg_path = mobile / adaptive.get('backgroundImage', '')
    if bg_path.exists():
        try:
            w, h, data = decode_png_rgba(bg_path.read_bytes())
            stride = w * 4
            bg_ok = w == h == src['app_icon']['size'] and all(
                data[i] == bg_rgb[0] and data[i + 1] == bg_rgb[1]
                and data[i + 2] == bg_rgb[2] and data[i + 3] == 255
                for i in range(0, len(data), 4)
            )
        except ValueError:
            pass
    check(bg_ok, 'ADAPTIVE_BG_SOLID')

    raster_case(favicon_rel, _icon_class_fn(64, src['app_icon']),
                {1: bg_rgb, 2: ink_dark, 3: dot_rgb}, 'FAVICON_RASTER_WHOLE')

    # ios.icon: наследует expo.icon (уже растровый) ИЛИ ведёт на наш растр,
    # но не на шаблонный каталог Expo (маркер — sha icon.json каталога).
    ios_icon = (expo.get('ios') or {}).get('icon')
    ios_ok = not ios_icon
    if ios_icon:
        target = mobile / ios_icon
        if target.is_dir():
            marker = target / 'icon.json'
            ios_ok = marker.exists() and hashlib.sha256(
                marker.read_bytes()).hexdigest() != rt['expo_icon_dir_marker_sha']
        elif target.exists():
            ios_ok = hashlib.sha256(target.read_bytes()).hexdigest() != TEMPLATE_SHAS['icon.png']
    check(ios_ok, 'IOS_ICON_NOT_TEMPLATE')

    # 20–21 (Р2/Р3, круг 6 — Rev117/Adv117): сценарий Maestro судит
    # ПОРЯДОК шагов настоящим YAML-парсером (закомментированная строка
    # шагом не является; grep по комментариям клетку не зеле́нит).
    # (а) шаг НЕПОСРЕДСТВЕННО перед takeScreenshot vkhod-117-splash —
    #     extendedWaitUntil visible по splash-overlay (совет критика 117 v2
    #     круг 1: маркер окна first-run-continue и любой шаг между ожиданием
    #     и снимком, в т.ч. ожидание исчезновения оверлея, позволяли снять
    #     First-Run под именем splash);
    # (б) перед takeScreenshot vkhod-117-first-run И ПОСЛЕ splash-кадра —
    #     оверлей исчез (extendedWaitUntil notVisible / assertNotVisible
    #     по splash-overlay): свидетельство снятия оверлея, НЕ приёмка
    #     экрана First-Run (состав/копию судит first-run-ekran).
    # 22–23 (вердикт критика 117 v2 круг 1; указание консультанта 15:25):
    # видимость кадра splash на устройстве судит СВЕРКА КАДРА e2e с макетом
    # (123): снимок splash каждой темы входит в перечень сверки 123 —
    # манифест H kadry_117.json (не субъект) объявляет кадр темы против
    # эталона Б1 этой темы (путь и sha256 — литералы source.json), снимок
    # = shot_splash, порог не ниже литерала porog_min; сценарий субъекта
    # снимает именно этот снимок.
    mq = src['maestro_117']
    sv = src['sverka_123']
    etalons = src['splash_reference']['etalons']
    if yaml is None:
        INFRASTRUCTURE.append('pyyaml отсутствует: порядок шагов не судится')
    else:
        maestro_path = repo / mq['scenario']
        steps = None
        if maestro_path.is_file():
            for doc in yaml.safe_load_all(maestro_path.read_text(encoding='utf-8')):
                if isinstance(doc, list):
                    steps = doc
        if steps is None:
            check(False, 'MAESTRO_SPLASH_FRAME_WAIT')
            check(False, 'MAESTRO_FIRST_RUN_ORDER')
            check(False, 'MAESTRO_HOLD_COLD_START')
            check(False, 'MAESTRO_HOLD_ALONE')
            check(False, 'SPLASH_FRAME_SVERKA_123_DARK')
            check(False, 'SPLASH_FRAME_SVERKA_123_LIGHT')
            print('RED MAESTRO_SPLASH_FRAME_WAIT: документ-список шагов не найден')
        else:
            def shot_index(name):
                if not isinstance(name, str):
                    return -1
                for i, st in enumerate(steps):
                    if isinstance(st, dict) and st.get('takeScreenshot') == name:
                        return i
                return -1

            def overlay_wait_right_before(i_shot):
                # Предыдущий шаг — extendedWaitUntil visible id splash-overlay.
                if i_shot < 1:
                    return False
                ewu = steps[i_shot - 1].get('extendedWaitUntil') \
                    if isinstance(steps[i_shot - 1], dict) else None
                return isinstance(ewu, dict) and isinstance(ewu.get('visible'), dict) \
                    and ewu['visible'].get('id') == mq['overlay_id']

            def overlay_gone_between(lo, hi):
                for st in steps[lo:hi]:
                    if not isinstance(st, dict):
                        continue
                    if isinstance(st.get('assertNotVisible'), dict) \
                            and st['assertNotVisible'].get('id') == mq['overlay_id']:
                        return True
                    ewu = st.get('extendedWaitUntil')
                    if isinstance(ewu, dict) and isinstance(ewu.get('notVisible'), dict) \
                            and ewu['notVisible'].get('id') == mq['overlay_id']:
                        return True
                return False

            i_splash = shot_index(mq['shot_splash'])
            ok_splash = overlay_wait_right_before(i_splash)
            if not ok_splash:
                print('RED MAESTRO_SPLASH_FRAME_WAIT: шаг перед', mq['shot_splash'],
                      '— не extendedWaitUntil visible', mq['overlay_id'])
            check(ok_splash, 'MAESTRO_SPLASH_FRAME_WAIT')

            i_first = shot_index(mq['shot_first_run'])
            ok_first = (
                i_first > 0
                and i_splash >= 0
                and overlay_gone_between(i_splash, i_first)
            )
            if not ok_first:
                print('RED MAESTRO_FIRST_RUN_ORDER: между', mq['shot_splash'], 'и',
                      mq['shot_first_run'], 'нет notVisible', mq['overlay_id'])
            check(ok_first, 'MAESTRO_FIRST_RUN_ORDER')

            manifest = None
            man_path = HERE.parents[2] / sv['manifest']
            if man_path.is_file():
                try:
                    manifest = json.loads(man_path.read_bytes())
                except ValueError:
                    manifest = None
            kadry = manifest.get('kadry') if isinstance(manifest, dict) else None
            for tema in ('dark', 'light'):
                case = 'SPLASH_FRAME_SVERKA_123_' + tema.upper()
                ref = etalons[tema]
                rows = [k for k in (kadry if isinstance(kadry, list) else [])
                        if isinstance(k, dict) and k.get('tema') == tema
                        and k.get('maket') == ref['path']]
                row = rows[0] if len(rows) == 1 else {}
                porog = row.get('porog')
                ok = (
                    len(rows) == 1
                    and row.get('id') == sv['kadr_id'][tema]
                    and row.get('maket_sha256') == ref['sha256']
                    and row.get('snimok') == mq['shot_splash']
                    and isinstance(porog, (int, float)) and not isinstance(porog, bool)
                    and sv['porog_min'] <= porog <= 1
                    and shot_index(row.get('snimok')) >= 0
                )
                if not ok:
                    print('RED', case + ':', 'манифест', sv['manifest'], 'строк темы',
                          len(rows), 'кадр', row.get('id'), 'снимок', row.get('snimok'),
                          'порог', porog, 'снят сценарием', shot_index(row.get('snimok')) >= 0)
                check(ok, case)

            # 117 v4 (Г′): удержание приписано ТОЛЬКО сценарию 117 — холодный
            # старт по ЛИТЕРАЛЬНОМУ deep link. Цепочка: launchApp{clearState}
            # (чистка состояния, как в v3) → stopApp (процесс убит) →
            # openLink(литерал) → ожидание видимости оверлея; между openLink
            # и ожиданием НЕТ запускающего шага (круг 3: launchApp любой
            # формы, runFlow, иная ссылка — единый _is_launching; иначе
            # старт не холодный — стартовый URL не читается). Правка по
            # FAIL критика v4 круг 1: холодный
            # старт судится СОСТОЯНИЕМ «приложение запущено» по
            # последовательности команд (_cold_start_state), а НЕ суммой
            # «есть где-то clearState и где-то stopApp» (обходы: второй
            # launchApp{clearState} между stopApp и openLink; перестановка
            # stopApp → launchApp{clearState} → openLink). Команды живые
            # (Maestro 2.11.0): launchApp{clearState} — 5 флоу, stopApp —
            # rehearsal.yaml, openLink complior://… — cmp-mob-002/004.
            rq = src['replay_117']
            lit = rq['hold_link']

            ok_cold, why_cold = _maestro_hold_cold_start_verdict(steps, mq, src)
            if not ok_cold:
                print('RED MAESTRO_HOLD_COLD_START: сценарий не запускает'
                      ' холодный старт каналом (Г′) по СОСТОЯНИЮ команд —',
                      why_cold)
            check(ok_cold, 'MAESTRO_HOLD_COLD_START')

            # Литерал удержания открывает ТОЛЬКО сценарий 117: openLink с
            # этим литералом по ВСЕМУ mobile/.maestro встречается ровно в
            # файле сценария 117 (живые чужие ссылки — complior://start в
            # cmp-mob-002/004 — литералом не являются).
            maestro_dir = maestro_path.parent
            holders = []
            if maestro_dir.is_dir():
                for yf in sorted(maestro_dir.glob('*.yaml')):
                    try:
                        docs = yaml.safe_load_all(
                            yf.read_text(encoding='utf-8'))
                    except yaml.YAMLError:
                        holders.append(yf.name)
                        continue
                    for doc in docs:
                        if not isinstance(doc, list):
                            continue
                        if any(_open_link_of(st) == lit for st in doc):
                            holders.append(yf.name)
                            break
            scenario_name = maestro_path.name
            ok_alone = holders == [scenario_name]
            if not ok_alone:
                print('RED MAESTRO_HOLD_ALONE: литерал', lit, 'открывают',
                      holders, '(ожидание: только', scenario_name, ')')
            check(ok_alone, 'MAESTRO_HOLD_ALONE')

            # 117 v4 (класс B, слово владельца 2026-10-27): реплей тайминга
            # подложного устройства/оверлея по ЖИВОМУ формату сценария —
            # ожидания вычислены из source.json replay_117 ДО чтения
            # субъекта (правило 8); закон: кадр в окне оверлея при ЛЮБОЙ
            # фазе опроса ⇔ HOLD > poll + shot (первый успешный опрос не
            # позже M+P, кадр — в конце команды снимка; замер живого
            # класса B run 40420737331: ~700 мс + ~670 мс > 1200 мс).
            replay_117_cells(repo, src, steps, mq, ok_cold)

    # (правка FAIL критика v4 круг 1, пункт б) клетки классов порядка —
    # порождаются раннером на синтетических входах, субъект не читается.
    porjadok_cells(src)

    # 24–26 (РЕШЕНИЕ арбитра contracts-117-v2-svjaz-123, вариант (б)):
    # проводка шага сверки 123 в задаче e2e-splash субъекта — шаг стоит
    # безусловно, исполняет канонический манифест пина .harness123, пин —
    # 40-hex. 117 только наблюдает workflow; текст шага — предмет 123.
    if yaml is not None:
        for case, good in sverka_provodka(repo, sv['provodka']):
            check(good, case)

    # 117 v4 (б): настоящая сверка 123 на ЖИВЫХ байтах-свидетелях класса B
    # (кадры прогонов 40420737331/40316137237, sha256 припинены в
    # source.json replay_117.live.svideteli): красный кадр NIZHE_POROGA,
    # зелёный контроль OK — ожидания сняты прогоном ДО правки субъекта.
    sverka_class_b_cell(repo, src)


def sverka_provodka(repo: Path, pv):
    """Клетки SVERKA_123_*: литералы — source.json sverka_123.provodka
    (frozen 123 v1 п.5–6), workflow субъекта разбирается YAML-парсером;
    нечитаемый/неразбираемый workflow — все три красны (не зелень)."""
    doc = None
    wf_path = repo / pv['workflow']
    if wf_path.is_file():
        try:
            doc = yaml.safe_load(wf_path.read_text(encoding='utf-8'))
        except yaml.YAMLError as err:
            print('RED SVERKA_123_*: workflow не разбирается:', err)
    jobs = doc.get('jobs') if isinstance(doc, dict) else None
    job = jobs.get(pv['job']) if isinstance(jobs, dict) else None
    steps = job.get('steps') if isinstance(job, dict) else None
    steps = steps if isinstance(steps, list) else []

    def run_of(st):
        run = st.get('run') if isinstance(st, dict) else None
        return run if isinstance(run, str) else ''

    i_sv = [i for i, st in enumerate(steps) if pv['script'] in run_of(st)]
    step = steps[i_sv[0]] if len(i_sv) == 1 else None

    # STEP_UNCONDITIONAL: ровно один шаг с литералом script, без if и
    # continue-on-error (ключ присутствует — красно при любом значении).
    ok_step = step is not None and 'if' not in step and 'continue-on-error' not in step
    if not ok_step:
        print('RED SVERKA_123_STEP_UNCONDITIONAL: шагов с', pv['script'], len(i_sv),
              'ключи шага', sorted(step) if step is not None else None)

    # MANIFEST_CANON: строка run с литералом script (до первого |, shlex) —
    # ровно `interpreter script` и три пары флаг-литерал, иных токенов нет;
    # каталог кадров не отслеживается git субъекта (кадры — из прогона).
    toks = []
    if step is not None:
        lines = [ln for ln in run_of(step).splitlines() if pv['script'] in ln]
        if len(lines) == 1:
            try:
                toks = shlex.split(lines[0].split('|', 1)[0])
            except ValueError:
                toks = []
    want = {'--manifest': pv['manifest'], '--kadry': pv['kadry'], '--repo': pv['repo']}
    args = toks[2:]
    ok_args = (toks[:2] == [pv['interpreter'], pv['script']] and len(args) == 2 * len(want)
               and dict(zip(args[0::2], args[1::2])) == want)
    ls = subprocess.run(['git', '-C', str(repo), 'ls-files', '--', pv['kadry']],
                        capture_output=True, text=True)
    if ls.returncode != 0:
        INFRASTRUCTURE.append('git ls-files субъекта: rc ' + str(ls.returncode))
    ok_canon = ok_args and ls.returncode == 0 and ls.stdout == ''
    if not ok_canon:
        print('RED SVERKA_123_MANIFEST_CANON: токены', toks, 'кадры в git',
              ls.stdout.splitlines()[:3])

    # HARNESS_PIN: ровно один checkout в path пина, repository — литерал,
    # ref — форма 40-hex, без if, раньше шага сверки.
    i_co = [i for i, st in enumerate(steps) if isinstance(st, dict)
            and isinstance(st.get('uses'), str) and st['uses'].startswith(pv['checkout_uses'])
            and isinstance(st.get('with'), dict) and st['with'].get('path') == pv['checkout_path']]
    ok_pin = False
    if len(i_co) == 1 and len(i_sv) == 1:
        co = steps[i_co[0]]
        ref = co['with'].get('ref')
        ok_pin = (co['with'].get('repository') == pv['checkout_repo']
                  and isinstance(ref, str) and re.search(pv['ref_re'], ref) is not None
                  and 'if' not in co and i_co[0] < i_sv[0])
    if not ok_pin:
        print('RED SVERKA_123_HARNESS_PIN: checkout', pv['checkout_path'], len(i_co),
              'шаг сверки', i_sv, 'checkout', i_co)
    return [('SVERKA_123_STEP_UNCONDITIONAL', ok_step),
            ('SVERKA_123_MANIFEST_CANON', ok_canon),
            ('SVERKA_123_HARNESS_PIN', ok_pin)]

def _open_link_of(st):
    """openLink шага (строка или {link: …}) | None — грамматика живого
    Maestro (witness commands-class-b-dark.json)."""
    if not isinstance(st, dict):
        return None
    ol = st.get('openLink')
    if isinstance(ol, str):
        return ol
    if isinstance(ol, dict) and isinstance(ol.get('link'), str):
        return ol['link']
    return None


def _is_launching(st):
    """ЕДИНЫЙ классификатор «запускающего шага» Maestro (правка по FAIL
    критика v4 круг 3, contracts-117-v4-krug3: до ссылки и на интервале
    openLink → ожидание признаки РАСХОДИЛИСЬ — _cold_start_state знал
    runFlow и словарный launchApp, интервальная проверка видела ТОЛЬКО
    launchApp-словарь, поэтому запуск через runFlow и скалярный
    «- launchApp» между hold-ссылкой и ожиданием оставлял статическую
    батарею ложно зелёной rc0). Запускают: launchApp ЛЮБОЙ формы —
    словарь и скалярная строка (живая форма
    mobile/.maestro/erstinformation.yaml:4), runFlow — ЛЮБОЙ,
    КОНСЕРВАТИВНО (живая семантика: runFlow запускает, только если
    вложенный/указанный flow содержит запуск — живой
    mobile/.maestro/start.yaml:4–7 запускает приложение с clearState;
    разрешение вложенного flow требует чтения других файлов, которого
    нет ни у сценария-субъекта, ни у синтетических входов клеток —
    fail-closed; до ссылки :1452 уже признавал любой runFlow запуском),
    openLink — любой (открытие ссылки стартует приложение). stopApp — не
    запускающий: останавливает, отдельная ветвь _cold_start_state.
    ОБА места (до ссылки и на интервале) зовут ТОЛЬКО эту функцию."""
    if st == 'launchApp':
        return True
    if not isinstance(st, dict):
        return False
    return 'launchApp' in st or 'runFlow' in st or 'openLink' in st


def _cold_start_state(steps, i_open):
    """Состояние «приложение запущено» в момент openLink №i_open — по
    ПОСЛЕДОВАТЕЛЬНОСТИ команд, не по их сумме (правка по FAIL критика
    v4 круг 1: клетка считала холодный старт суммой «есть где-то clearState
    и где-то stopApp», и честную цепочку портили второй launchApp между
    stopApp и openLink либо перестановка stopApp → launchApp → openLink).
    Запускают (единый классификатор _is_launching, круг 3): launchApp
    любой формы (словарь и скаляр), runFlow (любой — консервативно),
    openLink (любой — открытие ссылки стартует приложение); останавливает:
    stopApp. Возвращает
    (running, cleared_stop): running — состояние НЕПОСРЕДСТВЕННО перед
    openLink (fail-closed: до первой запускающей/останавливающей команды
    состояние считается «запущено»); cleared_stop — ПОСЛЕДНЯЯ смена
    состояния перед openLink есть stopApp, стоящий ПОСЛЕ launchApp
    {clearState}, и после него приложение не запускалось снова."""
    running = True
    cleared = False
    cleared_stop = False
    for st in steps[:i_open]:
        if st == 'stopApp' or (isinstance(st, dict) and 'stopApp' in st):
            running = False
            if cleared:
                cleared_stop = True
            continue
        if not _is_launching(st):
            continue
        running = True
        cleared_stop = False
        if isinstance(st, dict) and 'launchApp' in st:
            la = st.get('launchApp')
            if isinstance(la, dict) and la.get('clearState') is True:
                cleared = True
    return running, cleared_stop


def _maestro_hold_cold_start_verdict(steps, mq, src):
    """Вердикт клетки MAESTRO_HOLD_COLD_START (инвариант 10, канал (Г′)):
    openLink ЛИТЕРАЛА — холодный старт ⇔ (1) непосредственно перед ним
    приложение остановлено (последняя запускающая/останавливающая команда =
    stopApp), (2) этот stopApp стоит ПОСЛЕ launchApp{clearState} и между
    ними приложение не запускалось снова, (3) ожидание visible оверлея —
    ПЕРВОЕ ПОСЛЕ openLink, без ЗАПУСКАЮЩЕГО шага между ними (правка по
    FAIL критика v4 круг 3: запуск через runFlow/скалярный launchApp/
    иную ссылку между hold-ссылкой и ожиданием оставлял батарею ложно
    зелёной; арбитраж 117 v4 :213–218 называет запускающими
    launchApp/runFlow/иной openLink; признак — ТОТ ЖЕ классификатор
    _is_launching, что до ссылки; путь (А): добавочные НЕ запускающие
    шаги до stopApp или между ссылкой и ожиданием решения не меняют;
    повторное открытие САМОГО литерала на интервале запускающим НЕ
    считается — его судит SPLASH_HOLD_LINK_ROUTE_MOUNT по числу ссылок
    канала). Единая функция для сценария субъекта и порождаемых клеток
    порядка (MAESTRO_HOLD_PORJADOK_*).
    Возвращает (ok, причина)."""
    lit = src['replay_117']['hold_link']
    i_open = next((i for i, st in enumerate(steps)
                   if _open_link_of(st) == lit), -1)
    i_wait = next((i for i, st in enumerate(steps)
                   if i > i_open and isinstance(st, dict)
                   and isinstance(st.get('extendedWaitUntil'), dict)
                   and isinstance(st['extendedWaitUntil'].get('visible'), dict)
                   and st['extendedWaitUntil']['visible'].get('id')
                   == mq['overlay_id']), -1)
    if i_open < 0:
        return False, ('openLink литерала %s в сценарии нет' % lit)
    running, cleared_stop = _cold_start_state(steps, i_open)
    if running:
        return False, ('openLink#%d: непосредственно перед ссылкой'
                       ' приложение ЗАПУЩЕНО (последняя запускающая/'
                       'останавливающая команда — не stopApp) — старт не'
                       ' холодный, стартовый URL при монтировании не'
                       ' читается' % i_open)
    if not cleared_stop:
        return False, ('openLink#%d: нет stopApp ПОСЛЕ launchApp{clearState}'
                       ' без повторного запуска между ними (состояние'
                       ' приложения не очищено перед ссылкой)' % i_open)
    if not i_wait > i_open:
        return False, ('ожидание visible %s не после openLink'
                       ' (openLink#%d, ожидание#%d)'
                       % (mq['overlay_id'], i_open, i_wait))
    for st in steps[i_open + 1:i_wait]:
        if _is_launching(st) and _open_link_of(st) != lit:
            return False, ('запускающий шаг между openLink#%d и ожиданием#%d'
                           ' — запуск/повторный запуск приложения'
                           ' (launchApp любой формы, runFlow, иная ссылка;'
                           ' единый классификатор _is_launching, круг 3):'
                           ' стартовый URL при монтировании не читается'
                           % (i_open, i_wait))
    return True, ''


def porjadok_cells(src):
    """(правка FAIL критика v4 круг 1, пункт б; расширение круга 3)
    КЛЕТКИ классов порядка: ПОРОЖДАЮТСЯ раннером из набора живых команд
    {launchApp (словарь и скаляр), stopApp, openLink, runFlow,
    extendedWaitUntil, takeScreenshot} — 2 перестановки, вставки, 2
    удаления, ОБА обхода критика, честная цепочка и контроли арбитража
    117 v4 (добавочные НЕ запускающие шаги до stopApp и между ссылкой и
    ожиданием — зелёны). Круг 3 (contracts-117-v4-krug3): 4 КРАСНЫХ
    КЛАССА запускающего шага МЕЖДУ hold-ссылкой и ожиданием (runFlow,
    скалярный launchApp, словарный launchApp, иная ссылка) + ЗЕЛЁНЫЙ
    контроль не запускающего шага в том же интервале. Ожидание
    каждой клетки — литерал ЗДЕСЬ, вычислен из модели порядка ДО вызова
    субъекта (правило 8: честная цепочка обязана быть зелёной, нарушители —
    красны); входы синтетические — субъект не читается, клетки судят саму
    проверку порядка, а не конкретный yaml."""
    mq = src['maestro_117']
    lit = src['replay_117']['hold_link']
    other = src['replay_117']['other_live_links'][0]
    launch_clear = {'launchApp': {'clearState': True}}
    launch_plain = {'launchApp': None}
    # живые формы запуска (правка круга 3): скалярный «- launchApp» —
    # mobile/.maestro/erstinformation.yaml:4; runFlow — mobile/.maestro/
    # start.yaml (запускает приложение с clearState)
    launch_scalar = 'launchApp'
    runflow = {'runFlow': 'start.yaml'}
    stop = 'stopApp'
    open_lit = {'openLink': lit}
    open_other = {'openLink': other}
    wait = {'extendedWaitUntil': {'visible': {'id': mq['overlay_id']},
                                  'timeout': 10000}}
    shot = {'takeScreenshot': mq['shot_splash']}
    honest = [launch_clear, stop, open_lit, wait, shot]
    cases = [
        # честная цепочка инварианта 10 — зелёна
        ('CHESTNAJA', honest, True),
        # ОБХОД 1 критика (вставка): второй launchApp{clearState} МЕЖДУ
        # stopApp и openLink — приложение работает до открытия ссылки
        ('RELAUNCH_PERED_LINK',
         [launch_clear, stop, launch_clear, open_lit, wait, shot], False),
        # ОБХОД 2 критика (перестановка): stopApp → launchApp{clearState}
        # → openLink — к ссылке приложение запущено, стоп не после очистки
        ('STOP_PERED_LAUNCHOM',
         [stop, launch_clear, open_lit, wait, shot], False),
        # перестановка: ссылка ДО stopApp — старт по ссылке не холодный
        ('PERESTANOVKA_LINK_RANSHE_STOPA',
         [launch_clear, open_lit, stop, wait, shot], False),
        # перестановка: ожидание ДО ссылки — оверлей не привязан к старту
        ('PERESTANOVKA_WAIT_RANSHE_LINKA',
         [launch_clear, stop, wait, open_lit, shot], False),
        # вставка: запуск БЕЗ clearState между stopApp и openLink
        ('VSTAVKA_ZAPUSK_BEZ_CLEAR',
         [launch_clear, stop, launch_plain, open_lit, wait, shot], False),
        # вставка: openLink ДРУГОЙ ссылки (живой complior://start) между
        # stopApp и openLink литерала — последний старт не по литералу
        ('VSTAVKA_DRUGOJ_SSYLKI',
         [launch_clear, stop, open_other, open_lit, wait, shot], False),
        # вставка (арбитраж 117 v4, путь (А)): добавочное НЕ запускающее
        # ожидание visible до stopApp — цепочка критика круга 2 дословно;
        # ожидание судится ПЕРВЫМ ПОСЛЕ openLink — все условия холодного
        # старта выполнены, цепочка ЗЕЛЁНА (прежде — ложная красная)
        ('VSTAVKA_WAIT_DO_STOPA',
         [launch_clear, wait, stop, open_lit, wait, shot], True),
        # вставки (правка FAIL критика v4 круг 3): ЗАПУСКАЮЩИЙ шаг МЕЖДУ
        # openLink литерала и ожиданием — повторный запуск приложения,
        # стартовый URL при монтировании не читается (арбитраж 117 v4
        # :213–218); прежний интервальный предикат видел только
        # launchApp-словарь — runFlow и скалярный launchApp оставляли
        # батарею ложно зелёной (вердикт krug3: run-flow/launch-between-
        # hold-and-wait rc0 static 65/65). Классы по ЖИВЫМ формам:
        # runFlow start.yaml, скалярный «- launchApp», launchApp-словарь,
        # иная живая ссылка complior://start.
        ('VSTAVKA_RUNFLOW_MEZHDU',
         [launch_clear, stop, open_lit, runflow, wait, shot], False),
        ('VSTAVKA_LAUNCH_SKALJAR_MEZHDU',
         [launch_clear, stop, open_lit, launch_scalar, wait, shot], False),
        ('VSTAVKA_LAUNCH_SLOVAR_MEZHDU',
         [launch_clear, stop, open_lit, launch_plain, wait, shot], False),
        ('VSTAVKA_DRUGOJ_SSYLKI_MEZHDU',
         [launch_clear, stop, open_lit, open_other, wait, shot], False),
        # вставка (контроль круга 3, арбитраж путь (А)): добавочный НЕ
        # запускающий шаг (снимок) между ссылкой и ожиданием — цепочка
        # ЗЕЛЕНА; класс покрывает зелёность assertVisible/notVisible/
        # снимка в интервале (вердикт krug3, ЗАКРЫВАЮЩЕЕ СВОЙСТВО)
        ('VSTAVKA_SNIMOK_MEZHDU',
         [launch_clear, stop, open_lit, shot, wait, shot], True),
        # удаление: stopApp нет — к ссылке приложение запущено
        ('UDALENIE_STOPA', [launch_clear, open_lit, wait, shot], False),
        # удаление: launchApp{clearState} нет — состояние не очищено
        ('UDALENIE_LAUNCHA', [stop, open_lit, wait, shot], False),
    ]
    for name, steps, expected in cases:
        got, why = _maestro_hold_cold_start_verdict(steps, mq, src)
        ok = got == expected
        if not ok:
            print('RED MAESTRO_HOLD_PORJADOK_' + name + ': вердикт', got,
                  '— ожидался', expected, '—', why)
        check(ok, 'MAESTRO_HOLD_PORJADOK_' + name)

def _replay_ewu(step):
    """Шаг extendedWaitUntil по оверлею → (kind, timeout_ms) | None.
    Грамматика — ЖИВОЙ формат Maestro (witness commands-class-b-dark.json:
    extendedWaitUntil{id:{visible|notVisible:{id}}} → assertConditionCommand)."""
    if not isinstance(step, dict):
        return None
    e = step.get('extendedWaitUntil')
    if not isinstance(e, dict):
        return None
    for kind in ('visible', 'notVisible'):
        cond = e.get(kind)
        if isinstance(cond, dict) and 'id' in cond:
            return kind, e.get('timeout')
    return None


def _replay_outcomes(steps, mq, hold_ms, rq, overlay_mounts=True):
    """Реплей подложного устройства/оверлея: кадр splash по сетке
    (poll, shot) из source.json. Возвращает (исходы, t2_ok, причина).
    Детерминизм: без вероятностей — худшая фаза опроса (первый успешный
    опрос не позже M+P) и худший момент кадра (конец команды снимка).
    (Г′) overlay_mounts=False — стартовая ссылка ведёт на НЕсуществующий
    маршрут (host-часть пути непуста): JS-дерево PilotApp не монтируется,
    оверлея НЕТ — ожидание visible краснеет таймаутом на любой точке
    сетки (живой факт пробы (Г) run 40497913252)."""
    poll_grid = rq['poll_ms_grid']
    if not overlay_mounts:
        return {'NO_PILOT'}, None, ('стартовая ссылка канала ведёт на'
                                    ' несуществующий маршрут: PilotApp не'
                                    ' монтируется, оверлей %s не появляется —'
                                    ' ожидание visible краснеет таймаутом'
                                    % mq['overlay_id'])
    shot_grid = rq['shot_ms_grid']
    i_shot = -1
    for i, st in enumerate(steps):
        if isinstance(st, dict) and st.get('takeScreenshot') == mq['shot_splash']:
            i_shot = i
            break
    if i_shot < 0:
        return {'NO_SHOT'}, None, 'снимок %s сценарием не снят' % mq['shot_splash']
    prev = _replay_ewu(steps[i_shot - 1]) if i_shot > 0 else None
    if prev is None:
        return {'UNBOUND'}, None, ('перед снимком %s нет extendedWaitUntil'
                                   ' visible/notVisible по %s — кадр не привязан'
                                   ' к оверлею' % (mq['shot_splash'], mq['overlay_id']))
    kind, t1 = prev
    if kind == 'notVisible':
        return {'CLASS_B'}, None, ('перед снимком %s — notVisible %s: кадр'
                                   ' снимается ПОСЛЕ ухода оверлея'
                                   % (mq['shot_splash'], mq['overlay_id']))
    outcomes = set()
    for p in poll_grid:
        # timeout шага — миллисекунды (живой формат: timeout: 10000)
        if isinstance(t1, (int, float)) and p >= t1:
            outcomes.add('WAIT_FAIL')
            continue
        for d in shot_grid:
            # первый успешный опрос ≤ M+p; кадр в конце команды снимка: M+p+d
            outcomes.add('SPLASH' if p + d < hold_ms else 'CLASS_B')
    t2_ok = None
    for st in steps[i_shot + 1:]:
        e = _replay_ewu(st)
        if e and e[0] == 'notVisible':
            if isinstance(e[1], (int, float)):
                t2_ms = e[1]
                t2_ok = all(
                    -(-max(0, hold_ms - p) // p) * p <= t2_ms
                    for p in poll_grid)
            break
    return outcomes, t2_ok, None


def _pilot_hold(repo, rq, pv):
    """(Г) канал удержания субъекта: pilot-app на монтировании читает
    стартовый URL (Linking.getInitialURL) и при ТОЧНОМ равенстве
    литералу replay_117.hold_link продлевает таймер оверлея до
    SPLASH_HOLD_E2E_MS (clearTimeout + setTimeout). Возвращает
    (ok_link, hold_ms, ok_no_env, env_hold_ms, env_in_pilot):
    ok_link — статическая проводка канала; hold_ms — литерал
    SPLASH_HOLD_E2E_MS из pilot-app; env_hold_ms — значение env (В) из
    workflow, если канал (В) вернулся (None — нет); env_in_pilot — env (В)
    в pilot-app. Канал (В) — общий вход (сборка), отклонён живой пробой:
    оба флага несут клетка SPLASH_HOLD_NO_ENV и реплей SCENARIO_ONLY."""
    pilot = repo / 'mobile/src/bootstrap/pilot-app.tsx'
    text = pilot.read_text(encoding='utf-8') if pilot.is_file() else ''
    lit = rq['hold_link']
    ok_link = (
        'Linking.getInitialURL()' in text
        and ("SPLASH_HOLD_E2E_LINK = '%s'" % lit) in text
        and 'initialUrl !== SPLASH_HOLD_E2E_LINK' in text
        and 'clearTimeout(timer)' in text
        and re.search(r'timer = setTimeout\(\(\) => setSplashVisible\(false\),'
                      r' SPLASH_HOLD_E2E_MS\)', text) is not None
    )
    m = re.search(r'SPLASH_HOLD_E2E_MS = (\d+)', text)
    hold_ms = int(m.group(1)) if m else None
    env_in_pilot = ('process.env.' + rq['hold_env_name']) in text
    wf_path = repo / pv['workflow']
    wf_text = wf_path.read_text(encoding='utf-8') if wf_path.is_file() else ''
    env_hold_ms = None
    m_env = re.search(r"%s: '?(\d+)'?" % re.escape(rq['hold_env_name']), wf_text)
    if m_env is not None:
        try:
            env_hold_ms = int(m_env.group(1))
        except ValueError:
            env_hold_ms = -1  # неразборчивое значение — fail-closed (взведено)
    ok_no_env = not (env_in_pilot or env_hold_ms is not None
                     or rq['hold_env_name'] in wf_text)
    return ok_link, hold_ms, ok_no_env, env_hold_ms, env_in_pilot


def _src_overlay_hide_ms():
    src = load_source()
    val = src.get('overlay_117', {}).get('hide_after_ms')
    return int(val) if isinstance(val, (int, float)) else None



def _expo_route_path(url):
    """(Г′) Путь маршрута expo-router из ссылки: host + pathname ДО «?»
    (fork extractPathFromURL ~57.0.28, node_modules продукта: fromDeepLink
    собирает path как res.host + res.pathname, query в путь не входит;
    измерено proba_gprim/parse_test.js). Корень «/» ⇒ ПУСТАЯ строка;
    host-форма complior://e2e-splash-hold ⇒ 'e2e-splash-hold' — путь
    /e2e-splash-hold, несуществующий маршрут ([section] рендерит null).
    Неразборчивое значение — fail-closed: НЕ корень (вернуть маркер)."""
    if not isinstance(url, str) or '://' not in url:
        return '?'
    rest = url.split('://', 1)[1]
    rest = rest.split('?', 1)[0]
    rest = rest.split('#', 1)[0]
    # authority = до первого '/'; всё после — pathname
    if '/' in rest:
        host, path = rest.split('/', 1)
        route = host + '/' + path
    else:
        route = rest
    return route.rstrip('/')


def _hold_link_matches_grammar(rq):
    """(Г′) Литерал канала соответствует грамматике source.json
    replay_117.hold_link_grammar: scheme + ПУСТОЙ host + путь «/» +
    маркер в query; извлечённый expo-router путь — ПУСТОЙ (корень)."""
    g = rq.get('hold_link_grammar')
    if not isinstance(g, dict):
        return False
    composed = '%s://%s%s?%s=%s' % (g.get('scheme'), g.get('host'),
                                    g.get('path'), g.get('query_key'),
                                    g.get('query_value'))
    return rq['hold_link'] == composed and _expo_route_path(rq['hold_link']) == ''

def replay_117_cells(repo, src, steps, mq, cold_start_ok):
    """Клетки 117 v4 (класс B, канал (Г′)): кадр Splash снимается, ПОКА
    splash-оверлей на экране, а удержание взводится ТОЛЬКО стартовым deep
    link сценария 117 (живые пробы: run 40434807469 отклонила env-удержание
    e2e-сборки — оверлей 8 с закрывал первый кадр КАЖДОГО холодного старта,
    118 F02.03-V01-V0 0.000; run 40497913252 отклонила host-ссылку (Г) —
    expo-router разбирает её как ПУТЬ /e2e-splash-hold, [section] рендерит
    null, PilotApp не монтируется, нативный splash залип). Ссылка канала
    (Г′) ведёт на КОРЕНЬ «/» с маркером в query. Реплей по сетке задержек
    раннера; HOLD — из pilot-app субъекта (литерал SPLASH_HOLD_E2E_MS),
    взведение — цепочка сценария (MAESTRO_HOLD_COLD_START); оракул —
    source.json replay_117 (до субъекта)."""
    rq = src['replay_117']
    pv = src['sverka_123']['provodka']
    live = rq['live']
    # (в) канон оракула: hold_min = poll.max + shot.max + 100; hold_e2e в
    # границах; hold_default = прод-литерал оверлея (единый источник);
    # литерал ссылки непуст и не пересекается с живыми чужими ссылками;
    # (Г′) литерал соответствует грамматике канала (корень+query) и
    # извлекается как ПУСТОЙ путь (корень «/»).
    ok_oracle = (
        rq['hold_min_ms'] == max(rq['poll_ms_grid']) + max(rq['shot_ms_grid']) + 100
        and rq['hold_min_ms'] <= rq['hold_e2e_ms']
        and rq['hold_default_ms_source'] == 'overlay_117.hide_after_ms'
        and isinstance(rq['hold_link'], str)
        and rq['hold_link'].startswith('complior://')
        and rq['hold_link'] not in rq['other_live_links']
        and _hold_link_matches_grammar(rq)
    )
    if not ok_oracle:
        print('RED REPLAY_ORACLE_CONSISTENT: replay_117 расходится с формулой'
              ' hold_min = poll.max + shot.max + 100 / прод-литералом оверлея'
              ' / литералом hold_link против other_live_links / грамматикой'
              ' канала (Г′): корень+query, host-часть пути ПУСТА')
    check(ok_oracle, 'REPLAY_ORACLE_CONSISTENT')

    # Проводка канала (Г′) в pilot-app + отсутствие канала (В).
    ok_link, hold_ms, ok_no_env, env_hold_ms, env_in_pilot = _pilot_hold(repo, rq, pv)
    if not ok_link:
        print('RED SPLASH_HOLD_LINK_CHANNEL: pilot-app не несёт канал (Г):'
              ' Linking.getInitialURL() + точное равенство литералу',
              rq['hold_link'], '+ апгрейд таймера clearTimeout/setTimeout')
    check(ok_link, 'SPLASH_HOLD_LINK_CHANNEL')
    if not ok_no_env:
        print('RED SPLASH_HOLD_NO_ENV: канал (В) env', rq['hold_env_name'],
              'присутствует в pilot-app/workflow (отклонён живой пробой'
              ' run 40434807469 — общий вход сборки)')
    check(ok_no_env, 'SPLASH_HOLD_NO_ENV')

    # (Г′) КЛАСС входов ссылки: канал удержания ведёт на СУЩЕСТВУЮЩИЙ
    # маршрут. Корень «/» монтирует PilotApp БЕЗУСЛОВНО (route_facts:
    # index.tsx); host-часть пути непуста ⇒ путь /<host> — одно-сегментный
    # динамический [section] рендерит null для сегмента вне TAB_ORDER
    # (живой провал пробы (Г) run 40497913252: PilotApp не монтирован,
    # hideAsync не вызван, нативный splash залип 15 с). Клетка требует:
    # сценарий субъекта открывает РОВНО литерал оракула, и его
    # expo-router путь ПУСТ (корень).
    subj_links = []
    for st in steps:
        ol = st.get('openLink') if isinstance(st, dict) else None
        if isinstance(ol, str) and ol.startswith('complior://'):
            subj_links.append(ol)
        elif isinstance(ol, dict) and isinstance(ol.get('link'), str) \
                and ol['link'].startswith('complior://'):
            subj_links.append(ol['link'])
    ok_route = (
        len(subj_links) == 1
        and subj_links[0] == rq['hold_link']
        and _expo_route_path(subj_links[0] if subj_links else '?') == ''
    )
    if not ok_route:
        print('RED SPLASH_HOLD_LINK_ROUTE_MOUNT: ссылка канала сценария',
              subj_links, 'не ведёт на корень «/» литералом', rq['hold_link'],
              '(expo-путь:', _expo_route_path(subj_links[0]) if subj_links
              else 'нет ссылки', '— host-форма = несуществующий маршрут,'
              ' PilotApp не монтируется, hideAsync не вызван)')
    check(ok_route, 'SPLASH_HOLD_LINK_ROUTE_MOUNT')
    # Реплей монтирования: судьбу старта решает ПОСЛЕДНЯЯ complior-ссылка
    # сценария (стартовый URL устройства = последняя открытая): её expo-путь
    # непуст ⇒ PilotApp не монтируется (NO_PILOT); корневая ссылка и старт
    # БЕЗ ссылки (лаунчер → корень «/») — монтируется (v3 живьём: оверлей
    # виден, класс B — гонка кадра, не пустое дерево).
    overlay_mounts = (
        not subj_links or _expo_route_path(subj_links[-1]) == ''
    )

    # Эффективное окно удержания субъекта: env (В) — общий вход (fail-closed
    # на неразборчивом значении); иначе канал (Г) = ok_link ∧ цепочка
    # сценария; иначе прод-литерал overlay_117.
    default = _src_overlay_hide_ms()
    if default is None:
        INFRASTRUCTURE.append('source.json: overlay_117.hide_after_ms не найден')
        return
    if env_in_pilot or env_hold_ms is not None:
        eff_hold = env_hold_ms if isinstance(env_hold_ms, int) and env_hold_ms > 0 else None
    elif ok_link and cold_start_ok:
        eff_hold = hold_ms
    else:
        eff_hold = default
    if eff_hold is None:
        # env-канал есть, значение неразборчиво: fail-closed — судим сетку
        # против недостижимого окна (все точки CLASS_B), не зелень.
        eff_hold = default - 1

    outcomes, t2_ok, why = _replay_outcomes(steps, mq, eff_hold, rq,
                                            overlay_mounts=overlay_mounts)
    ok_frame = outcomes == {'SPLASH'}
    if not ok_frame:
        print('RED REPLAY_SPLASH_WHILE_OVERLAY: hold', eff_hold,
              'исходы', sorted(outcomes), why or '',
              '(канал (Г):', ok_link, 'холодный старт:', cold_start_ok, ')')
    check(ok_frame, 'REPLAY_SPLASH_WHILE_OVERLAY')

    if t2_ok is not None:
        if not t2_ok:
            print('RED REPLAY_HOLD_FITS_WAIT_TIMEOUT: hold', eff_hold,
                  'не накрывается таймаутом notVisible (кадр first-run'
                  ' не снимается после ухода оверлея)')
        check(t2_ok, 'REPLAY_HOLD_FITS_WAIT_TIMEOUT')

    # (г) живой носитель v3: продуктовый сценарий @ ba5ebbc927 (sha256
    # припинен) + живой commands.json класса B — реплей строится по живому
    # формату; на живой проводке v3 (HOLD 1200, канала нет) реплей обязан
    # видеть класс B, включая ЗАМЕРЕННУЮ живую пару poll=700/shot=670 мс.
    ok_live = True
    live_steps = None
    live_yaml = HERE / 'live' / 'vkhod-117-splash-vhod.prod-ba5ebbc9.yaml'
    blob = live_yaml.read_bytes() if live_yaml.is_file() else b''
    if hashlib.sha256(blob).hexdigest() != live['svideteli'][live_yaml.name]:
        print('ORACLE_TAMPERED live/' + live_yaml.name)
        INFRASTRUCTURE.append('свидетель live/%s не сходится к пину sha256'
                              % live_yaml.name)
        return
    for doc in yaml.safe_load_all(blob.decode('utf-8')):
        if isinstance(doc, list):
            live_steps = doc
    if live_steps is None:
        ok_live = False
        print('RED REPLAY_LIVE_CARRIER: живой сценарий не разбирается'
              ' документом-списком шагов')
    else:
        out_live, _, _ = _replay_outcomes(live_steps, mq, default, rq)
        pair_class_b = (700 + live['timings_ms']['shot_red'] >= default)
        if not ('CLASS_B' in out_live and pair_class_b):
            ok_live = False
            print('RED REPLAY_LIVE_CARRIER: на живой проводке v3 (HOLD',
                  default, ') реплей не видит класс B; исходы',
                  sorted(out_live), 'пара 700+',
                  live['timings_ms']['shot_red'], 'мс =', pair_class_b)
    # грамматика реплея — формы живого commands.json (assertCondition/
    # takeScreenshot/launchApp), не собственный диалект
    cj_path = HERE / 'live' / 'commands-class-b-dark.json'
    cj_blob = cj_path.read_bytes() if cj_path.is_file() else b''
    if hashlib.sha256(cj_blob).hexdigest() != live['svideteli'][cj_path.name]:
        print('ORACLE_TAMPERED live/' + cj_path.name)
        INFRASTRUCTURE.append('свидетель live/%s не сходится к пину sha256'
                              % cj_path.name)
        return
    try:
        cmds = json.loads(cj_blob)
    except ValueError:
        ok_live = False
        cmds = None
        print('RED REPLAY_LIVE_CARRIER: живой commands.json не разбирается')
    if isinstance(cmds, list) and live_steps is not None:
        kinds = []
        for c in cmds:
            if isinstance(c, dict):
                inner = c.get('command') if isinstance(c.get('command'), dict) else c
                kinds.append(next(iter(inner)))
        expect_prefix = ['defineVariablesCommand', 'applyConfigurationCommand']
        step_kinds = []
        for st in live_steps:
            if not isinstance(st, dict):
                continue
            if 'launchApp' in st:
                step_kinds.append('launchAppCommand')
            elif 'extendedWaitUntil' in st:
                step_kinds.append('assertConditionCommand')
            elif 'takeScreenshot' in st:
                step_kinds.append('takeScreenshotCommand')
            elif 'assertVisible' in st or 'assertNotVisible' in st:
                step_kinds.append('assertConditionCommand')
        if kinds[:len(expect_prefix)] != expect_prefix or \
                kinds[len(expect_prefix):len(expect_prefix) + len(step_kinds)] != step_kinds:
            ok_live = False
            print('RED REPLAY_LIVE_CARRIER: шаги живого сценария не'
                  ' отображаются в команды живого commands.json')
    check(ok_live, 'REPLAY_LIVE_CARRIER')

    # (д) удержание ТОЛЬКО в сценарии 117 (живая проба (В) run 40434807469:
    # кадр 118 F02.03-V01-V0 dark/light 0.000 — на кадре splash-оверлей).
    # Живой носитель: commands.json шага 118 пробы (sha256) — первый кадр
    # завершается через ЗАМЕРЕННЫЙ зазор после конца launchApp; закон:
    # кадр постороннего сценария закрыт ⇔ удержание взведено на ОБЩЕМ входе
    # (env сборки) ∧ зазор < HOLD. Кадры-свидетели (оверлей на месте V0)
    # припинены sha256; honest-модель (Г) для запуска 118 без литеральной
    # ссылки НЕ взводит → кадр не закрыт (зелёный контроль той же пробы:
    # прочие кадры OK — V02-V0 0.845/0.783, сняты после ухода оверлея).
    ok_scenario = True
    ei_path = HERE / 'live' / 'commands-proba-erstinfo-dark.json'
    ei_blob = ei_path.read_bytes() if ei_path.is_file() else b''
    if hashlib.sha256(ei_blob).hexdigest() != live['svideteli'][ei_path.name]:
        print('ORACLE_TAMPERED live/' + ei_path.name)
        INFRASTRUCTURE.append('свидетель live/%s не сходится к пину sha256'
                              % ei_path.name)
        return
    kinds_ei = []
    gap = None
    try:
        ei = json.loads(ei_blob)
        evs = [(e['command'], e['metadata']) for e in ei if isinstance(e, dict)]
        kinds_ei = [next(iter(c)) for c, _ in evs]
        li = next(i for i, k in enumerate(kinds_ei) if k == 'launchAppCommand')
        si = next(i for i, k in enumerate(kinds_ei) if k == 'takeScreenshotCommand')
        gap = ((evs[si][1]['timestamp'] + evs[si][1]['duration'])
               - (evs[li][1]['timestamp'] + evs[li][1]['duration']))
    except (ValueError, KeyError, StopIteration, TypeError):
        gap = None
    gap_oracle = live['timings_ms']['proba_erstinfo_dark']['shot_v0_after_launch_end']
    no_open_link = not any('openLink' in k for k in kinds_ei)
    env_covers = ((env_in_pilot or env_hold_ms is not None)
                  and gap is not None
                  and (not isinstance(env_hold_ms, int) or env_hold_ms <= 0
                       or env_hold_ms > gap))
    # живой факт пробы: env 8000 закрыл кадр на зазоре 7450 (0.000 обе
    # темы) — закон сверен с оракулом до суда над субъектом
    oracle_covers = rq['hold_e2e_ms'] > gap_oracle
    if gap != gap_oracle or not oracle_covers or not no_open_link:
        ok_scenario = False
        print('RED REPLAY_HOLD_SCENARIO_ONLY: живой носитель 118 расходится'
              ' с оракулом (зазор', gap, '!=', gap_oracle, 'env 8000 закрывает:',
              oracle_covers, 'openLink в 118:', not no_open_link, ')')
    if env_covers:
        ok_scenario = False
        print('RED REPLAY_HOLD_SCENARIO_ONLY: субъект взводит удержание на'
              ' ОБЩЕМ входе (env сборки) — кадр 118 V0 (зазор', gap,
              'мс < HOLD', env_hold_ms, ') закрыт оверлеем, как в пробе'
              ' run 40434807469 (0.000 обе темы)')
    check(ok_scenario, 'REPLAY_HOLD_SCENARIO_ONLY')

    # (Г′) живые свидетели провала пробы (Г) run 40497913252/job
    # 122172034122 (флоу 117 красен: нативный splash залип): кадр провала
    # (нативный знак, НЕ JS-оверлей), hierarchy json шага провала (в дереве
    # приложения НЕТ узлов содержимого — PilotApp не монтирован) и
    # logcat-фрагмент (START VIEW dat=complior://e2e-splash-hold… +
    # Running "main" — ссылка доставлена, JS запущен). Носитель
    # субъект-независим (как REPLAY_LIVE_CARRIER): факты пробы — оракул
    # против нового канала; подмена свидетеля — rc2 ORACLE_TAMPERED.
    ok_g = True
    names_g = ('proba117g-kadr-native-splash.png',
               'proba117g-hierarchy-step006.json',
               'proba117g-logcat-fragment.txt')
    for nm in names_g:
        w = HERE / 'live' / nm
        blob_g = w.read_bytes() if w.is_file() else b''
        if hashlib.sha256(blob_g).hexdigest() != live['svideteli'].get(nm):
            print('ORACLE_TAMPERED live/' + nm)
            INFRASTRUCTURE.append('свидетель live/%s не сходится к пину sha256' % nm)
            return
    hier_g = None
    try:
        hier_g = json.loads((HERE / 'live' / names_g[1]).read_bytes())
    except ValueError:
        ok_g = False
    rids_g, texts_g = [], []

    def _hier_walk(n):
        a = n.get('attributes', {}) if isinstance(n, dict) else {}
        if isinstance(a, dict):
            if isinstance(a.get('resource-id'), str):
                rids_g.append(a['resource-id'])
            if isinstance(a.get('text'), str):
                texts_g.append(a['text'])
        for c in (n.get('children', []) if isinstance(n, dict) else []):
            _hier_walk(c)

    if hier_g is not None:
        _hier_walk(hier_g)
    frag = (HERE / 'live' / names_g[2]).read_text(encoding='utf-8',
                                                  errors='replace')
    ok_g = ok_g and (
        hier_g is not None
        # живой факт: оверлей не появился и дерева содержимого нет —
        # единственный com.complior resource-id — системный каркас
        # action_bar_root (пустое окно активности), контентных testID нет
        and all('splash-overlay' not in r for r in rids_g)
        and all('splash-overlay' not in t for t in texts_g)
        and all(r == 'com.complior.mobile:id/action_bar_root'
                for r in rids_g if r.startswith('com.complior.mobile'))
        # живой факт: ссылка доставлена (платформенное сокращение "/...")
        # и JS запущен
        and 'dat=complior://e2e-splash-hold' in frag
        and 'cmp=com.complior.mobile/.MainActivity' in frag
        and 'Running "main"' in frag
        and 'LAUNCH_SINGLE_TASK' in frag
    )
    if not ok_g:
        print('RED REPLAY_LIVE_PROBA_G: свидетели провала (Г) не несут факты'
              ' (hierarchy resource-id только android/systemui, без'
              ' splash-overlay; logcat: START VIEW dat=… + Running "main")')
    check(ok_g, 'REPLAY_LIVE_PROBA_G')


def sverka_class_b_cell(repo, src):
    """(б) Клетка SVERKA_123_CATCHES_CLASS_B: НАСТОЯЩАЯ сверка 123 на живых
    свидетелях: кадр класса B (run 40420737331, dark) → NIZHE_POROGA rc1,
    зелёный кадр (run 40316137237, dark) → OK rc0; ожидания — из
    source.json replay_117.live.sverka_{bad,ok} (замер до правки субъекта).
    Свидетели sha-припинены; подмена — rc2 ORACLE_TAMPERED."""
    rq = src['replay_117']
    live = rq['live']
    sv_script = HERE.parents[2] / 'scripts' / 'sverka_maketa.py'
    manifest = HERE.parents[2] / src['sverka_123']['manifest']
    if not sv_script.is_file() or not manifest.is_file():
        INFRASTRUCTURE.append('sverka_maketa.py/манифест 123 не найдены'
                              ' в дереве батареи (пин .harness117)')
        return
    for name, sha in live['svideteli'].items():
        p = HERE / 'live' / name
        blob = p.read_bytes() if p.is_file() else b''
        if hashlib.sha256(blob).hexdigest() != sha:
            print('ORACLE_TAMPERED live/' + name)
            INFRASTRUCTURE.append('свидетель live/%s не сходится к пину'
                                  ' sha256' % name)
            return
    import tempfile
    ok = True
    with tempfile.TemporaryDirectory(prefix='vkhod117-sverka-') as tmp:
        for tag, dark, light, expect in (
                ('bad', 'kadr-class-b-dark.png', 'kadr-ok-light.png', live['sverka_bad']),
                ('ok', 'kadr-ok-dark.png', 'kadr-ok-light.png', live['sverka_ok'])):
            kadry = Path(tmp) / tag
            for tema, png in (('dark', dark), ('light', light)):
                shot = kadry / tema / 'run40420737331' / 'flow' / 'takeScreenshot'
                shot.mkdir(parents=True)
                shutil.copyfile(HERE / 'live' / png, shot / 'vkhod-117-splash.png')
            proc = subprocess.run(
                [sys.executable, str(sv_script), '--manifest', str(manifest),
                 '--kadry', str(kadry), '--repo', str(repo)],
                capture_output=True, text=True, timeout=120)
            got = [ln for ln in proc.stdout.splitlines() if ln]
            if proc.returncode != expect['rc'] or got != expect['stdout'] \
                    or proc.stderr.strip() != expect.get('stderr', ''):
                ok = False
                print('RED SVERKA_123_CATCHES_CLASS_B:', tag,
                      'rc', proc.returncode, '!=', expect['rc'])
                for ln in got:
                    print('  got:', ln)
    if not ok:
        print('  сверка обязана краснеть на живом кадре класса B и зеленеть'
              ' на зелёном (замер source.json replay_117.live)')
    check(ok, 'SVERKA_123_CATCHES_CLASS_B')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', required=True)
    ap.add_argument('--model', action='store_true')
    ap.add_argument('--matrix', action='store_true')
    args = ap.parse_args()
    repo = Path(args.repo).resolve()

    if args.matrix:
        return matrix(repo)

    if not args.model and not (repo / 'mobile/assets/images/splash-composite-dark.png').exists():
        print('VKHOD_SPLASH_COMPOSITE_ABSENT')
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
    A = 'mobile/app.json'
    I = 'mobile/assets/images/icon.png'
    # Р8 (круг 6, Rev117): шаблонные байты базы B — ПРИПИНЕННЫЕ копии
    # батареи (base_b/, sha256 сверяется с литералами source.json
    # template_shas_base_8748a7a335; несоответствие — rc2 ORACLE_TAMPERED),
    # НЕ из --repo: на честном C чтение из repo подставляло канонические
    # байты субъекта вместо шаблона, мутанты icon-template-bytes и
    # adaptive-favicon-template были no-op и выходили MUTANT_GREEN.
    template = {}
    for name, sha in load_source()['template_shas_base_8748a7a335'].items():
        blob = (HERE / 'base_b' / name).read_bytes()
        if hashlib.sha256(blob).hexdigest() != sha:
            print('ORACLE_TAMPERED base_b/' + name)
            return 2
        template[name] = blob
    template_icon = template['icon.png']
    FG = 'mobile/assets/images/android-icon-foreground.png'
    BG = 'mobile/assets/images/android-icon-background.png'
    MO = 'mobile/assets/images/android-icon-monochrome.png'
    FV = 'mobile/assets/images/favicon.png'
    CD = 'mobile/assets/images/splash-composite-dark.png'
    CL = 'mobile/assets/images/splash-composite-light.png'
    template_fg = template['android-icon-foreground.png']
    template_bg = template['android-icon-background.png']
    template_mo = template['android-icon-monochrome.png']
    template_favicon = template['favicon.png']
    ICON_MODEL = (HERE / 'model' / 'icon.png').read_bytes()
    COMP_DARK = (HERE / 'model' / 'splash-composite-dark.png').read_bytes()
    COMP_LIGHT = (HERE / 'model' / 'splash-composite-light.png').read_bytes()
    ab = load_source()['artboard_117']
    # Р2/Р3 (круг 6): якоря мутаций сценария модели — блоки шагов
    # побайтово (model/vkhod-117-splash-vhod.yaml).
    MAE = 'mobile/.maestro/vkhod-117-splash-vhod.yaml'
    SPLASH_WAIT = ('- extendedWaitUntil:\n'
                   '    visible:\n'
                   '      id: splash-overlay\n'
                   '    timeout: 10000\n')
    SPLASH_SHOT = '- takeScreenshot: vkhod-117-splash\n'
    OVERLAY_GONE = ('- extendedWaitUntil:\n'
                    '    notVisible:\n'
                    '      id: splash-overlay\n'
                    '    timeout: 10000\n')
    FIRST_RUN_WAIT = ('- extendedWaitUntil:\n'
                      '    visible:\n'
                      '      id: first-run-continue\n'
                      '    timeout: 10000\n')
    # РЕШЕНИЕ арбитра (б): якоря мутаций проводки 123 — шаги модели
    # побайтово (model/github.workflows.mobile.yml = mobile.yml
    # cmp-mob-123/sverka @10cf684, шаги 123 дословно).
    WF = '.github/workflows/mobile.yml'
    SV_CHECKOUT = ('      - name: Checkout scripts/sverka_maketa.py (mob-sverka-123 implementation)\n'
                   '        uses: actions/checkout@v7\n'
                   '        with:\n'
                   '          repository: a3ka/dev-harness\n'
                   '          ref: 2cc58c224a8a9ced9709604f0eeb57d2fba6fb07\n'
                   '          path: .harness123\n'
                   '          persist-credentials: false\n')
    SV_NAME = '      - name: 123 сверка кадров с макетом (scripts/sverka_maketa.py)\n'
    SV_RUN = ('        run: |\n'
              '          set -o pipefail\n'
              '          python3 .harness123/scripts/sverka_maketa.py --manifest'
              ' .harness123/fixtures/workshop_project/mob_sverka_123/kadry_117.json'
              ' --kadry mobile/maestro-out-117 --repo . | tee mobile/maestro-out-117/sverka-123.tsv\n')
    SV_STEP = SV_NAME + '        working-directory: ${{ github.workspace }}\n' + SV_RUN
    # 117 v4 (канал (Г)): якоря стабов удержания — блок чтения стартового
    # URL в pilot-app (модель), env-форма (В).
    PILOT = 'mobile/src/bootstrap/pilot-app.tsx'
    LINK_BLOCK = (
        '    let holdCancelled = false;\n'
        '    void Linking.getInitialURL().then((initialUrl) => {\n'
        '      if (holdCancelled || initialUrl !== SPLASH_HOLD_E2E_LINK) return;\n'
        '      clearTimeout(timer);\n'
        '      timer = setTimeout(() => setSplashVisible(false), SPLASH_HOLD_E2E_MS);\n'
        '    });\n'
    )
    ENV_FORM = (
        '    const timer = setTimeout(() => setSplashVisible(false),\n'
        '      Math.max(SPLASH_OVERLAY_MS,'
        ' Number(process.env.EXPO_PUBLIC_SPLASH_HOLD_E2E_MS || 0) || 0));\n'
    )
    MUTANTS = {
        # (а) иконка осталась шаблонной Expo: байты базы проходят пути,
        # но пиксельные свойства канона и sha-литерал красны.
        'icon-template-bytes': (
            [(I, ICON_MODEL, template_icon)],
            ['ICON_PIXELS_MARK'], ['ICON_NOT_TEMPLATE_BYTES', 'ICON_RASTER_WHOLE'],
        ),
        # (а) adaptiveIcon фон остался Expo-голубым #E6F4FE.
        'adaptive-expo-blue': (
            [(A, '"backgroundColor": "#0A0A0A",\n        "foregroundImage"',
              '"backgroundColor": "#E6F4FE",\n        "foregroundImage"')],
            ['ICON_ADAPTIVE_BG_DARK'], [],
        ),
        # (б) тёмный образ знака подменён шаблонной картинкой той же роли.
        'splash-image-forgery': (
            [(A, '"image": "./assets/images/splash-sign-dark.png"',
              '"image": "./assets/images/splash-icon.png"')],
            ['SPLASH_BLOCKS_DARK_LIGHT', 'SPLASH_SIGN_RASTER_DARK'],
            ['SPLASH_NATIVE_GENERATED', 'SPLASH_NATIVE_GENERATED_DARK_MDPI',
             'SPLASH_NATIVE_GENERATED_DARK_HDPI', 'SPLASH_NATIVE_GENERATED_DARK_XHDPI',
             'SPLASH_NATIVE_GENERATED_DARK_XXHDPI', 'SPLASH_NATIVE_GENERATED_DARK_XXXHDPI',
             'SPLASH_EFFECTIVE_IOS_DARK'],
        ),
        # (Б1, круг 2) ОБХОД критика «подложные иконка/splash»: прозрачный
        # PNG с ТРЕМЯ пикселами в точках старых проб (цвета сохранены) —
        # точечные клетки зелёны, целое изображение красно.
        'icon-twin-three-pixels': (
            [(I, ICON_MODEL, _twin_png(ICON_MODEL, [(717, 644), (519, 272), (512, 80)]))],
            ['ICON_RASTER_WHOLE'], [],
        ),
        # (Б1, арбитраж круга 2) подложный композит «семь пикселей»:
        # прозрачный PNG верного размера окна, сохранены лишь угловые
        # точки полос — эталонный recall ≈ 0.
        'splash-composite-twin': (
            [(CD, COMP_DARK, _twin_png(COMP_DARK, [(109, 357), (115, 360), (262, 406),
                                                   (263, 407), (194, 523), (194, 524), (194, 582)])),
             (CL, COMP_LIGHT, _twin_png(COMP_LIGHT, [(109, 357), (115, 360), (262, 406),
                                                     (263, 407), (194, 523), (194, 524), (194, 582)]))],
            ['SPLASH_COMPOSITE_ETALON_DARK', 'SPLASH_COMPOSITE_ETALON_LIGHT'], [],
        ),
        # (Б1, арбитраж круга 2) «знак без надписей»: знак честный, полосы
        # wordmark/tagline стёрты — recall эталона ниже порога.
        'splash-composite-no-words': (
            [(CD, COMP_DARK, _erase_rows_png(COMP_DARK, ab['wordmark_bbox'][1], ab['tagline_bbox'][3])),
             (CL, COMP_LIGHT, _erase_rows_png(COMP_LIGHT, ab['wordmark_bbox'][1], ab['tagline_bbox'][3]))],
            ['SPLASH_COMPOSITE_ETALON_DARK', 'SPLASH_COMPOSITE_ETALON_LIGHT'], [],
        ),
        # (Б1, арбитраж круга 2) «сдвиг 9 px»: всё содержимое композита
        # сдвинуто на 9 строк — precision/recall ниже порога.
        'splash-composite-shifted': (
            [(CD, COMP_DARK, _shift_image(COMP_DARK, 9)),
             (CL, COMP_LIGHT, _shift_image(COMP_LIGHT, 9))],
            ['SPLASH_COMPOSITE_ETALON_DARK', 'SPLASH_COMPOSITE_ETALON_LIGHT'], [],
        ),
        # (Б1, круг критика 3) свидетель halfres-{dark,light}: композиты
        # 195x422 при ТОЧНОМ aspect (пиксель (x,y) = честный (2x,2y)) —
        # прежняя решётка C давала recall/precision 1.0; размер != эталона
        # красен той же клеткой (вся маска 15439/15346 не представима).
        'splash-composite-halfres': (
            [(CD, COMP_DARK, _halfres_png(COMP_DARK)),
             (CL, COMP_LIGHT, _halfres_png(COMP_LIGHT))],
            ['SPLASH_COMPOSITE_ETALON_DARK', 'SPLASH_COMPOSITE_ETALON_LIGHT'], [],
        ),
        # (круг 4, Б2) imageWidth шаблона 76: произведённые drawable несут
        # bbox 76*mult (знак сжат), литерал блока красен.
        'splash-imagewidth-76': (
            [(A, '"imageWidth": 181,', '"imageWidth": 76,')],
            ['SPLASH_BLOCKS_DARK_LIGHT', 'SPLASH_NATIVE_GENERATED'],
            ['SPLASH_NATIVE_GENERATED_LIGHT_MDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_HDPI',
             'SPLASH_NATIVE_GENERATED_LIGHT_XHDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_XXHDPI',
             'SPLASH_NATIVE_GENERATED_LIGHT_XXXHDPI', 'SPLASH_NATIVE_GENERATED_DARK_MDPI',
             'SPLASH_NATIVE_GENERATED_DARK_HDPI', 'SPLASH_NATIVE_GENERATED_DARK_XHDPI',
             'SPLASH_NATIVE_GENERATED_DARK_XXHDPI', 'SPLASH_NATIVE_GENERATED_DARK_XXXHDPI',
             'SPLASH_EFFECTIVE_IOS_LIGHT', 'SPLASH_EFFECTIVE_IOS_DARK',
             'SPLASH_IOS_STORYBOARD'],
        ),
        # (Б1, круг 2) ОБХОД критика «шаблонные производные при честном
        # корне»: четыре android/favicon-производные — байты шаблона Expo.
        'adaptive-favicon-template': (
            [(FG, (HERE / 'model' / 'android-icon-foreground.png').read_bytes(), template_fg),
             (BG, (HERE / 'model' / 'android-icon-background.png').read_bytes(), template_bg),
             (MO, (HERE / 'model' / 'android-icon-monochrome.png').read_bytes(), template_mo),
             (FV, (HERE / 'model' / 'favicon.png').read_bytes(), template_favicon)],
            ['ADAPTIVE_FG_RASTER', 'ADAPTIVE_MONO_RASTER', 'ADAPTIVE_BG_SOLID', 'FAVICON_RASTER_WHOLE'],
            [],
        ),
        # (Б2, арбитраж круга 2) платформенный override шаблоном при честных
        # корневых image/dark.image: basename у шаблона другой, но критерий
        # basename НЕ сравнивает — красят ПРОИЗВЕДЁННЫЕ файлы (содержимое).
        'platform-image-template-override': (
            [(A, '"backgroundColor": "#F3F2EE",\n          "image": "./assets/images/splash-sign-light.png",',
              '"backgroundColor": "#F3F2EE",\n          "image": "./assets/images/splash-sign-light.png",\n          "android": {\n            "image": "./assets/images/splash-icon.png",\n            "dark": {\n              "image": "./assets/images/splash-icon.png"\n            }\n          },')],
            ['SPLASH_NATIVE_GENERATED'],
            ['SPLASH_NATIVE_GENERATED_LIGHT_MDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_HDPI',
             'SPLASH_NATIVE_GENERATED_LIGHT_XHDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_XXHDPI',
             'SPLASH_NATIVE_GENERATED_LIGHT_XXXHDPI', 'SPLASH_NATIVE_GENERATED_DARK_MDPI',
             'SPLASH_NATIVE_GENERATED_DARK_HDPI', 'SPLASH_NATIVE_GENERATED_DARK_XHDPI',
             'SPLASH_NATIVE_GENERATED_DARK_XXHDPI', 'SPLASH_NATIVE_GENERATED_DARK_XXXHDPI'],
        ),
        # (Б2, арбитраж круга 2) same-basename: платформенный override
        # указывает на файл с BASENAME корневого light-образа, но содержимое
        # — композит кадра (не знак): произведённые drawable красны БЕЗ
        # какого-либо сравнения basename.
        'platform-same-basename': (
            [(A, '"backgroundColor": "#F3F2EE",\n          "image": "./assets/images/splash-sign-light.png",',
              '"backgroundColor": "#F3F2EE",\n          "image": "./assets/images/splash-sign-light.png",\n          "android": {\n            "image": "./assets/images/splash-composite-light.png"\n          },')],
            ['SPLASH_NATIVE_GENERATED'],
            ['SPLASH_NATIVE_GENERATED_LIGHT_MDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_HDPI',
             'SPLASH_NATIVE_GENERATED_LIGHT_XHDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_XXHDPI',
             'SPLASH_NATIVE_GENERATED_LIGHT_XXXHDPI'],
        ),
        # (Б2, арбитраж круга 2) density-ключи = шаблон при честном корне:
        # плотностные drawable произведены из шаблона.
        'platform-density-template': (
            [(A, '"resizeMode": "contain",\n          "dark": {',
              '"resizeMode": "contain",\n          "mdpi": "./assets/images/splash-icon.png",\n          "hdpi": "./assets/images/splash-icon.png",\n          "xhdpi": "./assets/images/splash-icon.png",\n          "xxhdpi": "./assets/images/splash-icon.png",\n          "xxxhdpi": "./assets/images/splash-icon.png",\n          "dark": {')],
            ['SPLASH_NATIVE_GENERATED'],
            ['SPLASH_NATIVE_GENERATED_LIGHT_MDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_HDPI',
             'SPLASH_NATIVE_GENERATED_LIGHT_XHDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_XXHDPI',
             'SPLASH_NATIVE_GENERATED_LIGHT_XXXHDPI'],
        ),
        # (в) тёмного варианта нет: dark-блок удалён.
        'splash-dark-block-missing': (
            [(A, ',\n          "dark": {\n            "backgroundColor": "#0A0A0A",\n'
                 '            "image": "./assets/images/splash-sign-dark.png"\n          }', '')],
            ['SPLASH_BLOCKS_DARK_LIGHT'],
            ['SPLASH_EFFECTIVE_DARK_LIGHT', 'SPLASH_SIGN_RASTER_DARK',
             'SPLASH_NATIVE_GENERATED', 'SPLASH_NATIVE_GENERATED_DARK_MDPI',
             'SPLASH_NATIVE_GENERATED_DARK_HDPI', 'SPLASH_NATIVE_GENERATED_DARK_XHDPI',
             'SPLASH_NATIVE_GENERATED_DARK_XXHDPI', 'SPLASH_NATIVE_GENERATED_DARK_XXXHDPI',
             'SPLASH_EFFECTIVE_IOS_DARK'],
        ),
        # (в) светлого варианта нет: корень splash тёмный.
        'splash-light-missing': (
            [(A, '"backgroundColor": "#F3F2EE"', '"backgroundColor": "#0A0A0A"')],
            ['SPLASH_BLOCKS_DARK_LIGHT'], ['SPLASH_EFFECTIVE_DARK_LIGHT'],
        ),
        # dark-вариант объявлен, но недостижим: userInterfaceStyle light.
        'user-style-light-stays': (
            [(A, '"userInterfaceStyle": "automatic"', '"userInterfaceStyle": "light"')],
            ['USER_STYLE_AUTOMATIC'], [],
        ),
        # (Б2, круг критика 3) свидетель ios-legacy: ios.enableFullScreen
        # Image_legacy=true при честных imageWidth 181/contain и знаках —
        # настоящий генератор storyboard даёт рамку 414x736 с краевыми
        # constraints; литерал отсутствия ключа и рамка 181x181 красны.
        'ios-legacy': (
            [(A, '"imageWidth": 181,',
              '"imageWidth": 181,\n          "ios": {\n            "enableFullScreenImage_legacy": true\n          },')],
            ['SPLASH_IOS_STORYBOARD'], [],
        ),
        # (С2-а, круг критика 3) свидетель overlay-wrong-source: Image
        # оверлея показывает icon.png, честные композиты лежат на диске —
        # потребление файлов, судимых эталоном, красно.
        'overlay-wrong-source': (
            [('mobile/src/bootstrap/pilot-app.tsx',
              "require('../../assets/images/splash-composite-dark.png')",
              "require('../../assets/images/icon.png')"),
             ('mobile/src/bootstrap/pilot-app.tsx',
              "require('../../assets/images/splash-composite-light.png')",
              "require('../../assets/images/icon.png')")],
            ['SPLASH_OVERLAY_CONSUMES_COMPOSITE'], [],
        ),
        # (Adv117v2, круг по реализации) transform на Image оверлея:
        # композит и require каноничны, кадр сдвинут — код потребителя
        # несёт запрещённую степень свободы геометрии.
        'overlay-transform-translatex': (
            [('mobile/src/bootstrap/pilot-app.tsx',
              "            style={[StyleSheet.absoluteFill, { width: '100%', height: '100%' }]}",
              "            style={[StyleSheet.absoluteFill, { width: '100%', height: '100%' },\n"
              "                    { transform: [{ translateX: 19 }] }]}")],
            ['SPLASH_OVERLAY_NO_TRANSFORM'], [],
        ),
        'overlay-transform-translatey': (
            [('mobile/src/bootstrap/pilot-app.tsx',
              "            style={[StyleSheet.absoluteFill, { width: '100%', height: '100%' }]}",
              "            style={[StyleSheet.absoluteFill, { width: '100%', height: '100%' },\n"
              "                    { transform: [{ translateY: 19 }] }]}")],
            ['SPLASH_OVERLAY_NO_TRANSFORM'], [],
        ),
        'overlay-transform-scale': (
            [('mobile/src/bootstrap/pilot-app.tsx',
              "            style={[StyleSheet.absoluteFill, { width: '100%', height: '100%' }]}",
              "            style={[StyleSheet.absoluteFill, { width: '100%', height: '100%' },\n"
              "                    { transform: [{ scale: 0.9 }] }]}")],
            ['SPLASH_OVERLAY_NO_TRANSFORM'], [],
        ),
        # (Adv117v2) margin-смещение Image оверлея: сдвиг layout сверх
        # канона (absoluteFill + width/height 100%).
        'overlay-margin-offset': (
            [('mobile/src/bootstrap/pilot-app.tsx',
              "            style={[StyleSheet.absoluteFill, { width: '100%', height: '100%' }]}",
              "            style={[StyleSheet.absoluteFill, { width: '100%', height: '100%',"
              " marginLeft: 50 }]}")],
            ['SPLASH_OVERLAY_NO_LAYOUT_OFFSET'], [],
        ),
        # (Adv117v3, круг по реализации) Z-ПОРЯДОК: сплеш ПОД полноэкранным
        # FirstRun (zIndex: -1) — код потребителя несёт zIndex ниже
        # zindex_min; прежняя батарея зелена (toBeVisible не видит соседа).
        'overlay-zindex-minus': (
            [('mobile/src/bootstrap/pilot-app.tsx',
              '            zIndex: 1000,\n', '            zIndex: -1,\n')],
            ['SPLASH_OVERLAY_ZORDER'], [],
        ),
        # (Adv117v3) нулевой zIndex: наравне с деревом оболочки.
        'overlay-zindex-zero': (
            [('mobile/src/bootstrap/pilot-app.tsx',
              '            zIndex: 1000,\n', '            zIndex: 0,\n')],
            ['SPLASH_OVERLAY_ZORDER'], [],
        ),
        # (Adv117v3) оверлей ПЕРЕД FirstRun в порядке sibling БЕЗ zIndex:
        # и уровень, и позиция сегмента относительно FirstRunScreen
        # нарушены.
        'overlay-before-firstrun': (
            [('mobile/src/bootstrap/pilot-app.tsx',
              '            zIndex: 1000,\n', ''),
             ('mobile/src/bootstrap/pilot-app.tsx',
              "      {frame === 'first-run' ? (\n"
              '        <FirstRunScreen onEnter={handleFirstRunContinue} />\n'
              '      ) : null}\n', ''),
             ('mobile/src/bootstrap/pilot-app.tsx',
              '      ) : null}\n'
              '    </View>\n'
              '    </ThemeContext.Provider>\n'
              '  );\n}',
              '      ) : null}\n'
              "      {frame === 'first-run' ? (\n"
              '        <FirstRunScreen onEnter={handleFirstRunContinue} />\n'
              '      ) : null}\n'
              '    </View>\n'
              '    </ThemeContext.Provider>\n'
              '  );\n}')],
            ['SPLASH_OVERLAY_ZORDER'], [],
        ),
        # (Р2, круг 6, Rev117/Adv117) кадр splash снят без ожидания окна
        # (форма текущего C: takeScreenshot сразу после launchApp — на
        # стенде снят рабочий стол Android).
        'maestro-splash-no-wait': (
            [(MAE, SPLASH_WAIT, '')],
            ['MAESTRO_SPLASH_FRAME_WAIT'], ['REPLAY_SPLASH_WHILE_OVERLAY',
            # v4 (замер матрицы): шага visible нет — цепочка (Г) рвётся
            # (openLink есть, ожидания нет) → COLD_START.
            'MAESTRO_HOLD_COLD_START'],
        ),
        # (Р2, в) ожидание есть ТОЛЬКО комментарием: строки шага
        # закомментированы — парсер шага не видит (grep бы видел).
        'maestro-splash-wait-commented': (
            [(MAE, SPLASH_WAIT, ''.join('# ' + ln + '\n' for ln in SPLASH_WAIT.splitlines()))],
            ['MAESTRO_SPLASH_FRAME_WAIT'], ['REPLAY_SPLASH_WHILE_OVERLAY',
            # v4 (замер матрицы): ожидание закомментировано — цепочка (Г)
            # рвётся (openLink есть, ожидания visible нет) → COLD_START.
            'MAESTRO_HOLD_COLD_START'],
        ),
        # (Р2, в) ложное размещение: ожидание ПОСЛЕ снимка splash.
        'maestro-splash-wait-after-shot': (
            [(MAE, SPLASH_WAIT + SPLASH_SHOT, SPLASH_SHOT + SPLASH_WAIT)],
            ['MAESTRO_SPLASH_FRAME_WAIT'], ['REPLAY_SPLASH_WHILE_OVERLAY'],
        ),
        # (Р3, круг 6) оверлей не обязан исчезнуть до кадра First-Run
        # (форма текущего C: assertVisible по id находит CTA под
        # оверлеем — снят Splash вместо First-Run).
        'maestro-first-run-overlay-kept': (
            [(MAE, OVERLAY_GONE, '')],
            ['MAESTRO_FIRST_RUN_ORDER'], [],
        ),
        # (совет критика 117 v2 круг 1, свидетель first-run-as-splash.yaml)
        # First-Run под именем splash: ожидание окна First-Run и
        # исчезновения оверлея ДО снимка splash.
        'maestro-first-run-as-splash': (
            [(MAE, SPLASH_WAIT + SPLASH_SHOT, FIRST_RUN_WAIT + OVERLAY_GONE + SPLASH_SHOT)],
            ['MAESTRO_SPLASH_FRAME_WAIT'], ['REPLAY_SPLASH_WHILE_OVERLAY',
            # v4 (замер матрицы): шаг visible splash-overlay заменён —
            # цепочка (Г) рвётся → COLD_START.
            'MAESTRO_HOLD_COLD_START'],
        ),
        # (родственный) ожидание оверлея есть, но между ним и снимком
        # splash — ожидание его исчезновения.
        'maestro-splash-overlay-gone-before-shot': (
            [(MAE, SPLASH_WAIT + SPLASH_SHOT, SPLASH_WAIT + OVERLAY_GONE + SPLASH_SHOT)],
            ['MAESTRO_SPLASH_FRAME_WAIT'], ['REPLAY_SPLASH_WHILE_OVERLAY'],
        ),
        # (сверка 123) снимок splash под иным именем: кадр, объявленный в
        # перечне сверки 123 (kadry_117.json), не снят — сверка с макетом
        # не видит кадр splash.
        'maestro-splash-shot-renamed': (
            [(MAE, SPLASH_SHOT, '- takeScreenshot: vkhod-117-splash-frame\n')],
            ['SPLASH_FRAME_SVERKA_123_DARK', 'SPLASH_FRAME_SVERKA_123_LIGHT'],
            ['MAESTRO_SPLASH_FRAME_WAIT', 'MAESTRO_FIRST_RUN_ORDER',
             'REPLAY_SPLASH_WHILE_OVERLAY'],
        ),
        # (РЕШЕНИЕ арбитра (б), workflow B) шагов 123 нет: ни checkout
        # .harness123, ни шага сверки — потребления манифеста нет.
        'sverka-step-absent': (
            [(WF, SV_CHECKOUT + SV_STEP, '')],
            ['SVERKA_123_STEP_UNCONDITIONAL', 'SVERKA_123_MANIFEST_CANON',
             'SVERKA_123_HARNESS_PIN'], [],
        ),
        # шаг есть, но провал не валит job.
        'sverka-continue-on-error': (
            [(WF, SV_NAME, SV_NAME + '        continue-on-error: true\n')],
            ['SVERKA_123_STEP_UNCONDITIONAL'], [],
        ),
        # шаг есть, но на pull_request пропускается.
        'sverka-if-conditional': (
            [(WF, SV_NAME, SV_NAME + "        if: github.event_name == 'push'\n")],
            ['SVERKA_123_STEP_UNCONDITIONAL'], [],
        ),
        # ОБХОД критика круга 2 дословно (Critic117v2b/wrong-effective-
        # workflow.yml): локальный манифест субъекта compare-117.json, в
        # котором кадр Splash light объявлен темой dark.
        'sverka-local-manifest': (
            [(WF, SV_RUN, '        run: python3 .harness123/scripts/sverka_maketa.py'
                          ' --manifest mobile/.maestro/compare-117.json'
                          ' --kadry mobile/maestro-out-117 --repo .\n')],
            ['SVERKA_123_MANIFEST_CANON'], [],
        ),
        # кадры берутся из иного каталога (не из вывода шага Maestro 117).
        'sverka-kadry-other': (
            [(WF, '--kadry mobile/maestro-out-117 --repo .', '--kadry mobile/maestro-out --repo .')],
            ['SVERKA_123_MANIFEST_CANON'], [],
        ),
        # пин харнесса — подвижная ветка вместо 40-hex SHA.
        'sverka-ref-branch': (
            [(WF, '          ref: 2cc58c224a8a9ced9709604f0eeb57d2fba6fb07\n',
              '          ref: main\n')],
            ['SVERKA_123_HARNESS_PIN'], [],
        ),
        # ---- 117 v4 (класс B, канал (Г)): обманные стабы удержания по
        # стартовому deep link и реплея тайминга. Привязка к ветвям по
        # коду (Н-39): канал (Г) в pilot-app — SPLASH_HOLD_LINK_CHANNEL +
        # REPLAY_SPLASH_WHILE_OVERLAY (без канала окно = прод-литерал);
        # канал (В) (env) — SPLASH_HOLD_NO_ENV + REPLAY_HOLD_SCENARIO_ONLY
        # (живой дефект пробы 40434807469: кадр 118 V0 закрыт); сила
        # удержания — REPLAY_SPLASH_WHILE_OVERLAY (ослаблен) /
        # REPLAY_HOLD_FITS_WAIT_TIMEOUT (сверх таймаута); холодный старт
        # сценария — MAESTRO_HOLD_COLD_START; ослабление порога — только
        # через подложный манифест (канон — SVERKA_123_MANIFEST_CANON:
        # порог живёт в манифесте H пина .harness123, не в субъекте).

        'splash-hold-link-otsutstvuet': (
            [(PILOT, LINK_BLOCK, '')],
            ['SPLASH_HOLD_LINK_CHANNEL', 'REPLAY_SPLASH_WHILE_OVERLAY'], [],
        ),
        'splash-hold-link-oslablen': (
            [(PILOT, 'const SPLASH_HOLD_E2E_MS = 8000;',
              'const SPLASH_HOLD_E2E_MS = 2000;')],
            ['REPLAY_SPLASH_WHILE_OVERLAY'], [],
        ),
        'splash-hold-sverh-timeout-a': (
            [(PILOT, 'const SPLASH_HOLD_E2E_MS = 8000;',
              'const SPLASH_HOLD_E2E_MS = 13000;')],
            ['REPLAY_HOLD_FITS_WAIT_TIMEOUT'], [],
        ),
        # Стаб-дефект живой пробы (В) run 40434807469: удержание на ОБЩЕМ
        # входе (env сборки) — кадр 118 V0 (зазор 7450 мс < 8000) закрыт.
        'splash-hold-env-vmesto-link': (
            [(PILOT,
              '    let timer = setTimeout(() => setSplashVisible(false),'
              ' SPLASH_OVERLAY_MS);\n' + LINK_BLOCK, ENV_FORM),
             (WF, '          EXPO_PUBLIC_API_MODE: mock\n',
              '          EXPO_PUBLIC_API_MODE: mock\n'
              "          EXPO_PUBLIC_SPLASH_HOLD_E2E_MS: '8000'\n")],
            ['SPLASH_HOLD_LINK_CHANNEL', 'SPLASH_HOLD_NO_ENV',
             'REPLAY_HOLD_SCENARIO_ONLY'], [],
        ),
        'splash-hold-vse-ssylki': (
            [(PILOT,
              'if (holdCancelled || initialUrl !== SPLASH_HOLD_E2E_LINK) return;',
              "if (holdCancelled || !initialUrl.startsWith('complior://'))"
              ' return;')],
            ['SPLASH_HOLD_LINK_CHANNEL'],
            # Побочная краснота (замер матрицы v4): канал текстово не точен —
            # эффективное окно судится fail-closed как прод-литерал → REPLAY.
            ['REPLAY_SPLASH_WHILE_OVERLAY'],
        ),
        'splash-hold-start-launchapp': (
            [(MAE, '- stopApp\n- openLink: complior:///?e2e=splash-hold\n', '')],
            ['MAESTRO_HOLD_COLD_START', 'REPLAY_SPLASH_WHILE_OVERLAY'],
            # Замер матрицы v4: литерал исчез из сценария — HOLD_ALONE красен
            # (носителей нет), ROUTE_MOUNT красен (ссылки канала нет) —
            # побочная краснота того же дефекта.
            ['MAESTRO_HOLD_ALONE', 'SPLASH_HOLD_LINK_ROUTE_MOUNT'],
        ),
        'splash-hold-start-ne-holodnyj': (
            [(MAE, '- stopApp\n- openLink: complior:///?e2e=splash-hold\n',
              '- openLink: complior:///?e2e=splash-hold\n'
              '- launchApp:\n    clearState: false\n')],
            ['MAESTRO_HOLD_COLD_START'], ['REPLAY_SPLASH_WHILE_OVERLAY'],
        ),
        # (правка FAIL критика v4 круг 1) ОБХОД 1 критика дословно: второй
        # launchApp{clearState} МЕЖДУ stopApp и openLink — приложение
        # работает до открытия ссылки, стартовый URL не читается при
        # монтировании; прежде (сумма команд) статика была зелёной.
        'splash-hold-relaunch-pered-link': (
            [(MAE, '- stopApp\n- openLink: complior:///?e2e=splash-hold\n',
              '- stopApp\n- launchApp:\n    clearState: true\n'
              '- openLink: complior:///?e2e=splash-hold\n')],
            ['MAESTRO_HOLD_COLD_START'], ['REPLAY_SPLASH_WHILE_OVERLAY'],
        ),
        # (правка FAIL критика v4 круг 1) ОБХОД 2 критика дословно:
        # перестановка stopApp → launchApp{clearState} → openLink — к
        # ссылке приложение запущено (и стоп не после очистки); прежде
        # статика 55/55 И поведение 191/191 были зелёными.
        'splash-hold-porjadok-stop-launch': (
            [(MAE, '- launchApp:\n    clearState: true\n- stopApp\n'
                  '- openLink: complior:///?e2e=splash-hold\n',
                  '- stopApp\n- launchApp:\n    clearState: true\n'
                  '- openLink: complior:///?e2e=splash-hold\n')],
            ['MAESTRO_HOLD_COLD_START'], ['REPLAY_SPLASH_WHILE_OVERLAY'],
        ),
        # (правка FAIL критика v4 круг 3, Н-39 — привязка по коду)
        # запуск через runFlow МЕЖДУ openLink литерала и ожиданием:
        # живой mobile/.maestro/start.yaml:4–7 запускает приложение с
        # clearState — повторный старт НЕ читает стартовый URL при
        # монтировании; старый интервальный предикат («только
        # launchApp-словарь») этот вход не замечал — статика была ЛОЖНО
        # зелёной rc0 (вердикт krug3: run-flow-between-hold-and-wait,
        # клетка VSTAVKA_RUNFLOW_MEZHDU судит предикат синтетически).
        # Скалярная форма «- launchApp» — та же ветвь _is_launching
        # (клетка VSTAVKA_LAUNCH_SKALJAR_MEZHDU), отдельного стаба не
        # требует: один стаб на КЛАСС (единый классификатор).
        'splash-hold-runflow-posle-link': (
            [(MAE, '- openLink: complior:///?e2e=splash-hold\n'
                  '- extendedWaitUntil:',
                  '- openLink: complior:///?e2e=splash-hold\n'
                  '- runFlow: start.yaml\n- extendedWaitUntil:')],
            ['MAESTRO_HOLD_COLD_START'], ['REPLAY_SPLASH_WHILE_OVERLAY'],
        ),
        # (Г′) Стаб-дефект живой пробы (Г) run 40497913252: ссылка канала —
        # host-форма (несуществующий маршрут /e2e-splash-hold) в ОБЕИХ
        # копиях литерала (сценарий и pilot-app): expo-router путь непуст —
        # [section] рендерит null, PilotApp не монтируется, hideAsync не
        # вызван, нативный splash залип — реплей видит NO_PILOT.
        'splash-hold-link-na-marshrut': (
            [(MAE, '- openLink: complior:///?e2e=splash-hold\n',
              '- openLink: complior://e2e-splash-hold\n'),
             (PILOT,
              "const SPLASH_HOLD_E2E_LINK = 'complior:///?e2e=splash-hold';",
              "const SPLASH_HOLD_E2E_LINK = 'complior://e2e-splash-hold';")],
            ['SPLASH_HOLD_LINK_ROUTE_MOUNT', 'REPLAY_SPLASH_WHILE_OVERLAY'],
            # Замер матрицы: канонический литерал исчез из сценария и
            # pilot-app — LINK_CHANNEL/COLD_START/ALONE красны тем же
            # дефектом (живой провал (Г): флоу 117 красен целиком).
            ['SPLASH_HOLD_LINK_CHANNEL', 'MAESTRO_HOLD_COLD_START',
             'MAESTRO_HOLD_ALONE'],
        ),
        'splash-replay-snimok-posle-uhoda': (
            [(MAE, SPLASH_WAIT + SPLASH_SHOT, SPLASH_WAIT + OVERLAY_GONE + SPLASH_SHOT)],
            ['REPLAY_SPLASH_WHILE_OVERLAY', 'MAESTRO_SPLASH_FRAME_WAIT'], [],
        ),
        'splash-kadr-udalen': (
            [(MAE, SPLASH_SHOT, '')],
            ['REPLAY_SPLASH_WHILE_OVERLAY', 'MAESTRO_SPLASH_FRAME_WAIT',
             'SPLASH_FRAME_SVERKA_123_DARK', 'SPLASH_FRAME_SVERKA_123_LIGHT'],
            ['MAESTRO_FIRST_RUN_ORDER'],
        ),
        'splash-porog-oslablen': (
            [(WF, '--manifest .harness123/fixtures/workshop_project/mob_sverka_123/kadry_117.json',
              '--manifest mobile/.maestro/kadry-oslab-117.json')],
            ['SVERKA_123_MANIFEST_CANON'], [],
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
        elif not set(named) <= red:
            print('MUTANT_NAMED_MISS', name, sorted(set(named) - red), 'red=', sorted(red))
            ok = False
        elif not red <= expected:
            print('MUTANT_UNEXPECTED_RED', name, sorted(red - expected))
            ok = False
        else:
            print('mutant', name, 'red=', sorted(red))
    return 0 if ok else 2


if __name__ == '__main__':
    sys.exit(main())
