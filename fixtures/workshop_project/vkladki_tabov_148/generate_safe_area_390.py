#!/usr/bin/env python3
"""Source-only 390 safe-area layout from D24-Kompakt-1.1 (never app captures).

Usage: python3 generate_safe_area_390.py <read-only D24 frames directory>
Requires Pillow for authoring only; CI checks checked-in PNG SHA, never regenerates.
"""
import hashlib
from pathlib import Path
import re
import sys

from PIL import Image

DEST = Path(__file__).resolve().parent / 'etalony-safe-area-390'
SPEC = (Path(__file__).resolve().parent / 'SPEC.md').read_text(encoding='utf-8')


def pinned_sources():
    section = SPEC.split('## 3. Эталонные кадры', 1)[1].split('Производные 390 референсы:', 1)[0]
    hashes = dict(re.findall(r'^\| `(GA-\d+_normal_(?:dark|light)_(?:390x844|393x852)\.png)` \| `([0-9a-f]{64})` \|$', section, re.M))
    if len(hashes) != 16:
        raise SystemExit('D24_SOURCE_PIN_COUNT')
    return hashes


def chrome_geometry(source):
    """Read the D24 393 centreline's top island and bottom gesture pill."""
    x = source.width // 2
    background = source.getpixel((x, 0))
    top_start = next(y for y in range(source.height // 4) if source.getpixel((x, y)) != background)
    top = next(y for y in range(top_start, source.height // 4) if source.getpixel((x, y)) == background)
    pill_end = next(y + 1 for y in range(source.height - 1, source.height * 3 // 4, -1) if source.getpixel((x, y)) != background)
    pill_start = next(y + 1 for y in range(pill_end - 1, source.height * 3 // 4, -1) if source.getpixel((x, y)) == background)
    trailing = source.height - pill_end
    bottom = source.height - pill_start + trailing - 1
    if (top, bottom) != (48, 20) or top_start != 11 or pill_end - pill_start != 5:
        raise SystemExit('D24_CHROME_GEOMETRY')
    return top, bottom


def main():
    if len(sys.argv) != 2:
        raise SystemExit('USAGE: generate_safe_area_390.py <read-only D24 frames directory>')
    frames = Path(sys.argv[1])
    hashes = pinned_sources()
    DEST.mkdir(exist_ok=True)
    for ga in ('GA-02', 'GA-03', 'GA-04', 'GA-09'):
        for theme in ('dark', 'light'):
            name = f'{ga}_normal_{theme}_390x844.png'
            matching = name.replace('390x844', '393x852')
            for src in (name, matching):
                if hashlib.sha256((frames / src).read_bytes()).hexdigest() != hashes[src]:
                    raise SystemExit(f'D24_SOURCE_PIN_MISMATCH {src}')
            with Image.open(frames / name) as original, Image.open(frames / matching) as chrome:
                original = original.convert('RGB')
                chrome = chrome.convert('RGB')
                if original.size != (390, 844) or chrome.size != (393, 852):
                    raise SystemExit(f'D24_DIMENSIONS_MISMATCH {name}')
                top, bottom = chrome_geometry(chrome)
                nav_top = 795  # Immutable 390 D24 nav bar; the 49-pixel bar is retained verbatim.
                nav_height = original.height - nav_top
                retained_end = original.height - top - bottom - nav_height
                if retained_end <= 0:
                    raise SystemExit(f'D24_VIEWPORT_GEOMETRY {name}')
                canvas = Image.new('RGB', original.size)
                canvas.paste(chrome.crop((0, 0, original.width, top)), (0, 0))
                canvas.paste(original.crop((0, 0, original.width, retained_end)), (0, top))
                canvas.paste(original.crop((0, nav_top, original.width, original.height)), (0, top + retained_end))
                canvas.paste(chrome.crop((0, chrome.height - bottom, original.width, chrome.height)), (0, original.height - bottom))
                target = DEST / name
                canvas.save(target)
                print(hashlib.sha256(target.read_bytes()).hexdigest(), target.relative_to(DEST.parent))


if __name__ == '__main__':
    main()
