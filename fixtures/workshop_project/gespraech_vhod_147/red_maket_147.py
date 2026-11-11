#!/usr/bin/env python3
"""Screen 147: visual evidence from real screenshots; isolated decoys for each branch.

The expected frame names/colors come from the pinned Kompakt package, not from
files in the candidate product. --model reads the package's actual PNGs.
"""
import argparse
import hashlib
import json
import re
import sys
from pathlib import Path
from PIL import Image, ImageChops, ImageStat

HERE = Path(__file__).resolve().parent
PINS = json.loads((HERE / 'piny.json').read_text())
LIME = tuple(bytes.fromhex(PINS['tokeny']['znachenija']['color.light.accent'].lstrip('#')))
FAMILY = PINS['tokeny']['znachenija']['font.sans']


def images(root, model, refs):
    # Load and authenticate the ENTIRE oracle before opening a candidate frame.
    oracle = {}
    for name in PINS['kadry']['pikselnaja_sverka']:
        reference = refs / name
        source = reference.read_bytes()
        if hashlib.sha256(source).hexdigest() != PINS['kadry']['sha256'][name]:
            raise ValueError(f'ETALON_SHA256_NE_SOVPAL: {name}')
        with Image.open(reference) as opened:
            oracle[name] = opened.convert('RGB')
    for name, expected in oracle.items():
        state = name[3:5]
        scheme = 'light' if '_light_' in name else 'dark'
        profile = '393' if '_393x852' in name else '390'
        if model:
            image = expected
        else:
            alias = f'gespraech-ga-{state}' + ('-393' if profile == '393' else '') + '.png'
            matches = list((root / scheme).glob(f'**/takeScreenshot/{alias}'))
            if len(matches) != 1:
                raise ValueError(f'KADR_NET_ODNOZNACHNO: {name}: {len(matches)}')
            with Image.open(matches[0]) as opened:
                image = opened.convert('RGB').resize(expected.size)
        yield name, scheme, image


def visual(name, scheme, image, check='all'):
    # Top 60..330 × 80..320 contains the scrim/backdrop, not pills or labels.
    if check in ('all', 'blur'):
        backdrop = image.crop((60, 80, 330, 320)).convert('L')
        if ImageStat.Stat(backdrop).stddev[0] <= 1.2:
            raise ValueError(f'PODLOZHKA_NE_RAZMYTA: {name}')
    # First pill center is clear of label/icon/rounded ends in both profiles.
    if check in ('all', 'color'):
        px = image.getpixel((210, 540))
        if any(abs(actual - expected) > 35 for actual, expected in zip(px, LIME)):
            raise ValueError(f'SPRECHEN_NE_LAIM: {name}: {px}')

def backdrop_changes(before, after, label):
    a = before.crop((60, 80, 330, 320)).convert('L')
    b = after.crop((60, 80, 330, 320)).convert('L')
    delta = ImageStat.Stat(ImageChops.difference(a, b)).mean[0]
    if delta <= 2:
        raise ValueError(f'PODLOZHKA_ZASTYLA: {label}: {delta:.2f}')


def font(loader, style, asset):
    if not asset.is_file() or asset.stat().st_size < 1024:
        raise ValueError('DM_SANS_RESOURCE_NET')
    font_text(loader.read_text(), style.read_text())


def stubs(refs, asset):
    # Each mutant is taken from one honest package frame: each branch's own
    # failure must be the first failure on that case, not a sibling's failure.
    reference = refs / 'GA-15_menu_light_390x844.png'
    with Image.open(reference) as opened:
        honest = opened.convert('RGB')
    visual(reference.name, 'light', honest)
    flat = honest.copy()
    flat.paste((243, 242, 238), (60, 80, 330, 320))
    black = honest.copy()
    black.paste((18, 18, 17), (205, 535, 216, 546))
    for name, image, reason in [
        ('flat_scrim', flat, 'PODLOZHKA_NE_RAZMYTA'),
        ('black_sprechen_light', black, 'SPRECHEN_NE_LAIM'),
    ]:
        try:
            visual(reference.name, 'light', image)
        except ValueError as error:
            if not str(error).startswith(reason):
                raise AssertionError(f'{name}: {error} != {reason}') from error
        else:
            raise AssertionError(f'{name}: placebo')
        print(f'{name}: {reason}')
    next_state = refs / 'GA-16_menu_light_390x844.png'
    with Image.open(next_state) as opened:
        honest_next = opened.convert('RGB')
    backdrop_changes(honest, honest_next, 'light 390')
    stale = honest_next.copy()
    stale.paste(honest.crop((60, 80, 330, 320)), (60, 80))
    try:
        backdrop_changes(honest, stale, 'light 390')
    except ValueError as error:
        if not str(error).startswith('PODLOZHKA_ZASTYLA'):
            raise AssertionError(f'stale_image: {error} != PODLOZHKA_ZASTYLA') from error
    else:
        raise AssertionError('stale_image: placebo')
    print('stale_image: PODLOZHKA_ZASTYLA')
    # Decoy font loading only; styling only; a font named in a comment is not
    # the runtime useFonts registration and cannot count as installed.
    honest_loader = "useFonts({ '" + FAMILY + "': require('../../assets/fonts/DMSans-Variable.ttf') })"
    honest_style = "fontFamily: '" + FAMILY + "'"
    temp = HERE / 'model'
    font(temp / 'font-loader.tsx', temp / 'font-style.tsx', asset)
    for name, bad_loader, bad_style, reason in [
        ('font_in_comment', '// ' + honest_loader, honest_style, 'DM_SANS_NE_ZAGRUZHEN'),
        ('font_not_applied', honest_loader, 'fontWeight: 700', 'DM_SANS_NE_PRIMENEN'),
    ]:
        try:
            font_text(bad_loader, bad_style)
        except ValueError as error:
            if str(error) != reason:
                raise AssertionError(f'{name}: {error} != {reason}') from error
        else:
            raise AssertionError(f'{name}: placebo')
        print(f'{name}: {reason}')


def font_text(loading, styling):
    # Comments cannot prove a runtime registration or a Text style. The family
    # name and the asset name come from piny.json (single source), not from
    # the candidate product.
    loading = re.sub(r'[/][*].*?[*][/]|^[ \t]*//[^\n]*', '', loading, flags=re.S | re.M)
    styling = re.sub(r'[/][*].*?[*][/]|^[ \t]*//[^\n]*', '', styling, flags=re.S | re.M)
    if not all(part in loading for part in ('useFonts(', "'" + FAMILY + "': require(", 'DMSans-Variable.ttf')):
        raise ValueError('DM_SANS_NE_ZAGRUZHEN')
    if "fontFamily: '" + FAMILY + "'" not in styling:
        raise ValueError('DM_SANS_NE_PRIMENEN')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--reference', type=Path, required=True)
    parser.add_argument('--screens', type=Path)
    parser.add_argument('--product', type=Path)
    parser.add_argument('--model', action='store_true')
    parser.add_argument('--stubs', action='store_true')
    parser.add_argument('--check', choices=['all', 'blur', 'color', 'font'], default='all')
    args = parser.parse_args()
    if not args.product:
        parser.error('--product required (for the real DM Sans resource)')
    if args.stubs:
        stubs(args.reference, args.product / 'mobile/assets/fonts/DMSans-Variable.ttf')
        return
    if args.check != 'font' and not args.model and not args.screens:
        parser.error('--screens required except in --model/--stubs')
    checked = 0
    if args.check != 'font':
        captures = list(images(args.screens, args.model, args.reference))
        for name, scheme, image in captures:
            visual(name, scheme, image, args.check)
            print(f'{name}: {args.check}')
            checked += 1
        if args.check in ('all', 'blur'):
            by_name = {name: image for name, _, image in captures}
            for scheme in ('light', 'dark'):
                for profile in ('390x844', '393x852'):
                    a = by_name[f'GA-15_menu_{scheme}_{profile}.png']
                    b = by_name[f'GA-16_menu_{scheme}_{profile}.png']
                    backdrop_changes(a, b, f'{scheme} {profile}')
    if args.check in ('all', 'font'):
        if args.model:
            model = HERE / 'model'
            font(model / 'font-loader.tsx', model / 'font-style.tsx', args.product / 'mobile/assets/fonts/DMSans-Variable.ttf')
        else:
            font(args.product / 'mobile/src/app/_layout.tsx', args.product / 'mobile/src/features/conversation/components/menu-overlay.tsx', args.product / 'mobile/assets/fonts/DMSans-Variable.ttf')
        print('DM_SANS_ZAGRUZHEN_PRIMENEN')
    print(f'frames={checked}')


if __name__ == '__main__':
    try:
        main()
    except (ValueError, OSError, AssertionError) as exc:
        print(str(exc), file=sys.stderr)
        sys.exit(1)
