#!/usr/bin/env python3
"""Verify D24 390 design is NOT redesigned: only 393 system bars are added.

The shifted retained 390 rectangles must have zero pixel difference;
the separately excluded scroll viewport is 68 pixels, not a claim of
whole-frame identity. Screenshot comparison remains runner 123.
--repo PRODUCT checks both product manifests; --selftest exercises
independent cheating inputs against an in-memory honest manifest.
"""
import argparse
import copy
import hashlib
import json
from pathlib import Path
from tempfile import TemporaryDirectory
import re

from PIL import Image, ImageChops
from generate_safe_area_390 import chrome_geometry, pinned_sources

HERE = Path(__file__).resolve().parent
PREFIX = 'fixtures/workshop_project/vkladki_tabov_148/etalony-safe-area-390/'
PRODUCT_PREFIX = 'docs/ux/05_Kompakt_D24/frames/'
FRAMES = ('GA-02', 'GA-03', 'GA-04', 'GA-09')
THEMES = ('dark', 'light')


def oracle(design):
    # Expected SHA values are read into memory before any subject manifest is inspected.
    spec = (HERE / 'SPEC.md').read_text(encoding='utf-8')
    section = spec.split('| имя 390 референса |', 1)[1].split('\n\n', 1)[0]
    derived = dict(re.findall(r'^\| `(GA-\d+_normal_(?:dark|light)_390x844\.png)` \| `([0-9a-f]{64})` \|$', section, re.M))
    assert len(derived) == 8, 'SPEC_PIN_COUNT'
    source = pinned_sources()
    for name, digest in source.items():
        if hashlib.sha256((design / name).read_bytes()).hexdigest() != digest:
            raise ValueError(f'D24_SOURCE_PIN_MISMATCH {name}')
    return derived, source


def compare_pixels(name, original, chrome, candidate):
    with Image.open(original) as src, Image.open(chrome) as chrome_src, Image.open(candidate) as out:
        src, chrome_src, out = src.convert('RGB'), chrome_src.convert('RGB'), out.convert('RGB')
        if src.size != (390, 844) or chrome_src.size != (393, 852) or out.size != src.size:
            raise ValueError(f'D24_DIMENSIONS_MISMATCH {name}')
        top, bottom = chrome_geometry(chrome_src)
        nav_top = 795
        retained_end = src.height - top - bottom - (src.height - nav_top)
        if top != 48 or bottom != 20 or retained_end != 727 or nav_top - retained_end != top + bottom:
            raise ValueError(f'VIEWPORT_OCCLUSION_{name}')
        # The 68-pixel loss is the excluded scrollable viewport [727,795),
        # NOT the top/header or bottom/nav pixels. No whole-frame identity claim.
        regions = (
            ('top', chrome_src.crop((0, 0, 390, top)), out.crop((0, 0, 390, top))),
            ('retained-content', src.crop((0, 0, 390, retained_end)), out.crop((0, top, 390, top + retained_end))),
            ('retained-nav', src.crop((0, nav_top, 390, 844)), out.crop((0, top + retained_end, 390, 844 - bottom))),
            ('bottom', chrome_src.crop((0, chrome_src.height - bottom, 390, chrome_src.height)), out.crop((0, 844 - bottom, 390, 844))),
        )
        for label, expected_pixels, actual_pixels in regions:
            if ImageChops.difference(expected_pixels, actual_pixels).getbbox() is not None:
                raise ValueError(f'PIXEL_DIFFERENCE_{label}_{name}')
        print(f'PIXELS {name}: chrome=48/20, retained=390x727+390x49, excluded_viewport=68, max_difference=0')

def check(manifests, expected, design, *, allow_top=False, allow_bottom=False, allow_wrong_ref=False):
    derived, source = expected
    for profil, man in ((390, manifests[390]), (393, manifests[393])):
        mera = man['mera']
        top, bottom = (48, 20)
        if not allow_top and mera['chrome_verh_pt'] != top:
            raise ValueError(f'MASKA_VERH_{profil}')
        if not allow_bottom and mera['chrome_niz_pt'] != bottom:
            raise ValueError(f'MASKA_NIZ_{profil}')
        actual_ids = set()
        for k in man['kadry']:
            name = f"{k['id'][:5]}_normal_{k['tema']}_{profil}x{844 if profil == 390 else 852}.png"
            ident = f"{k['id'][:5]} {k['tema']}" + (' 393' if profil == 393 else '')
            if k['id'] != ident or k['id'] in actual_ids or k['tema'] not in THEMES:
                raise ValueError(f'KADR_ID_{profil}')
            actual_ids.add(k['id'])
            path = (PREFIX if profil == 390 else PRODUCT_PREFIX) + name
            digest = (derived if profil == 390 else source)[name]
            if not allow_wrong_ref and (k['maket'] != path or k['maket_sha256'] != digest):
                raise ValueError(f'PIN_{profil}_{name}')
            if k['porog'] != 0.6 or k.get('maski_pt') != []:
                raise ValueError(f'SUD_MASKA_{profil}_{name}')
        expected_ids = {f'{ga} {theme}' + (' 393' if profil == 393 else '') for ga in FRAMES for theme in THEMES}
        if actual_ids != expected_ids:
            raise ValueError(f'KADR_SOSTAV_{profil}')
        for name in (f'{ga}_normal_{theme}_{profil}x{844 if profil == 390 else 852}.png' for ga in FRAMES for theme in THEMES):
            path = (HERE / 'etalony-safe-area-390' / name) if profil == 390 else (design / name)
            digest = (derived if profil == 390 else source)[name]
            if hashlib.sha256(path.read_bytes()).hexdigest() != digest:
                raise ValueError(f'REFERENS_SHA_{profil}_{name}')
            if profil == 390:
                compare_pixels(name, design / name, design / name.replace('390x844', '393x852'), path)


def load_manifests(repo):
    base = repo / 'mobile/e2e-vkladki'
    return {390: json.loads((base / 'kadry.json').read_text()), 393: json.loads((base / 'kadry_profil.json').read_text())}


def selftest(manifests, expected, design):
    honest = copy.deepcopy(manifests)
    derived, source = expected
    honest[390]['mera'].update(chrome_verh_pt=48, chrome_niz_pt=20)
    for k in honest[390]['kadry']:
        name = f"{k['id'][:5]}_normal_{k['tema']}_390x844.png"
        k.update(maket=PREFIX + name, maket_sha256=derived[name])
    check(honest, expected, design)
    print('CONTROL honest masks and both reference sets: rc=0')
    # N-39: each cheating validator is bound to exactly the input where
    # omitting its own branch is observable, never to an unrelated mutant.
    for label, change, cheat, reason in (
        ('top-mask-skip', lambda m: m[390]['mera'].update(chrome_verh_pt=0), {'allow_top': True}, 'MASKA_VERH_390'),
        ('bottom-mask-skip', lambda m: m[390]['mera'].update(chrome_niz_pt=24), {'allow_bottom': True}, 'MASKA_NIZ_390'),
        ('ref-pin-skip', lambda m: m[390]['kadry'][0].update(maket=PRODUCT_PREFIX + 'GA-02_normal_dark_390x844.png', maket_sha256=source['GA-02_normal_dark_390x844.png']), {'allow_wrong_ref': True}, 'PIN_390_GA-02_normal_dark_390x844.png'),
    ):
        mutant = copy.deepcopy(honest)
        change(mutant)
        try:
            check(mutant, expected, design)
        except ValueError as exc:
            assert str(exc) == reason, (label, exc)
        else:
            raise AssertionError(f'STAB_ZHIV {label}: honest checker accepted')
        check(mutant, expected, design, **cheat)
        print(f'STAB {label} distinguished on own mutant: {reason}')
    name = 'GA-02_normal_dark_390x844.png'
    with TemporaryDirectory() as temp:
        candidate = Path(temp) / name
        with Image.open(HERE / 'etalony-safe-area-390' / name) as image:
            changed = image.copy()
        changed.putpixel((10, 100), (255, 0, 0))
        changed.save(candidate)
        try:
            compare_pixels(name, design / name, design / name.replace('390x844', '393x852'), candidate)
        except ValueError as exc:
            assert str(exc) == f'PIXEL_DIFFERENCE_retained-content_{name}', exc
        else:
            raise AssertionError('STAB_ZHIV retained-pixel-change: honest checker accepted')
        print('STAB retained-pixel-change distinguished on own mutant: PIXEL_DIFFERENCE_retained-content')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--design', type=Path, help='read-only D24 frames directory (defaults to --repo/docs/ux/05_Kompakt_D24/frames)')
    parser.add_argument('--selftest', action='store_true')
    args = parser.parse_args()
    try:
        repo = args.repo.resolve()
        design = (args.design or (repo / PRODUCT_PREFIX)).resolve()
        expected = oracle(design)
        manifests = load_manifests(repo)
        if args.selftest:
            selftest(manifests, expected, design)
        else:
            check(manifests, expected, design)
        print('SAFE_AREA_148_OK')
        return 0
    except (AssertionError, KeyError, OSError, ValueError) as exc:
        print(f'SAFE_AREA_148_NEVEREN: {exc}')
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
