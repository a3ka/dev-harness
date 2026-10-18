#!/usr/bin/env python3
"""Статические пробы оболочки 999 (CMP-MOB-002): проекция темы, шрифты,
web-bundle, deep link scheme. Читают только дерево R и source.json.

theme/ — нативная проекция tokens.json D2.2.5.1 (не второй придуманный
набор); DM Sans идёт с OFL в assets/fonts; web bundle React 18 из design
snapshot в RN не импортируется; scheme deep link сохраняется.
"""
import argparse
import re
from pathlib import Path
import sys

from probe_lib import installed, load_source, model_bytes, sha256_file, source_hashes

TOKENS_TS = 'mobile/src/theme/tokens.ts'
FONT_TTF = 'mobile/assets/fonts/DMSans-Variable.ttf'
FONT_OFL = 'mobile/assets/fonts/OFL-DMSans.txt'
APP_JSON = 'mobile/app.json'
SCAN_PATHS = ['mobile/src/app', 'mobile/src/ui', 'mobile/src/navigation',
              'mobile/src/features/start/start-screen.tsx', 'mobile/src/bootstrap/tab-shell.tsx']
NAME_RE = re.compile(r"['\"]?([a-z-]+)['\"]?:\s*'([^']+)'")
BLOCK_RE = {'dark': re.compile(r'\bdark:\s*\{([^{}]*)\}'), 'light': re.compile(r'\blight:\s*\{([^{}]*)\}')}
WEB_BUNDLE_RE = re.compile(r"from\s+['\"][^'\"]*(?:components/bundle|docs/ux)[^'\"]*['\"]")
HEX_RE = re.compile(r'#[0-9a-fA-F]{3,8}\b')

CASES = ['TOKENS_MATCH', 'LITERAL_PALETTE', 'FONTS_PRESENT', 'FONTS_OFL', 'NO_WEB_BUNDLE', 'DEEP_LINK_SCHEME']

# Стаб↔ветвь (Н-39); None-тело мутации — удаление файла.
MUTANTS = [
    ('invented-palette', 'TOKENS_MATCH', (TOKENS_TS, 'dark: {\n    ground: \'#0a0a0a\',', 'dark: {\n    ground: \'#000000\',')),
    ('theme-light-dropped', 'TOKENS_MATCH', (TOKENS_TS, """  light: {
    ground: '#f3f2ee',
    ink: '#121211',
    panel: '#e6e5df',
    card: '#ffffff',
    'on-card': '#121211',
    primary: '#121211',
    'on-primary': '#f3f2ee',
    accent: '#d6f75a',
  },
};""", '  light: themeTokens.dark,\n};')),
    ('literal-hex-screen', 'LITERAL_PALETTE', ('mobile/src/features/start/start-screen.tsx', 'backgroundColor: tokens.ground }', "backgroundColor: '#0a0a0a' }")),
    ('font-ttf-missing', 'FONTS_PRESENT', (FONT_TTF, None, None)),
    ('ofl-missing', 'FONTS_OFL', (FONT_OFL, None, None)),
    ('web-bundle-import', 'NO_WEB_BUNDLE', ('mobile/src/ui/button.tsx', "import React from 'react';", "import { CompliorBento } from '../../docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/design-system/project/components/bundle.js';\nimport React from 'react';")),
    ('scheme-changed', 'DEEP_LINK_SCHEME', (APP_JSON, '"scheme": "complior"', '"scheme": "other-app"')),
]


def check_tokens(repo: Path, source):
    path = repo / TOKENS_TS
    if not path.exists():
        return 1, 'THEME_ABSENT: mobile/src/theme/tokens.ts'
    text = path.read_text()
    blocks = {}
    for mode, pattern in BLOCK_RE.items():
        match = pattern.search(text)
        if not match:
            return 1, f'THEME_MODE_ABSENT: {mode}'
        blocks[mode] = dict(NAME_RE.findall(match.group(1)))
    for name, modes in source['tokens'].items():
        for mode, value in modes.items():
            if name not in blocks[mode]:
                return 1, f'TOKEN_NAME_ABSENT: {name}.{mode}'
            if blocks[mode][name] != value:
                return 1, f'TOKEN_VALUE_MISMATCH: {name}.{mode}: {blocks[mode][name]!r} != {value!r}'
    return 0, f'names={len(source["tokens"])} dark/light совпали побайтово'


def check_literal(repo: Path):
    offenders = []
    files = []
    for scan in SCAN_PATHS:
        base = repo / scan
        if base.is_dir():
            files.extend(f for f in base.rglob('*') if f.suffix in ('.ts', '.tsx') and f.is_file())
        elif base.is_file() and base.suffix in ('.ts', '.tsx'):
            files.append(base)
    for file in files:
        hits = HEX_RE.findall(file.read_text())
        if hits:
            offenders.append(f'{file.relative_to(repo)}:{"|".join(sorted(set(hits)))}')
    if offenders:
        return 1, 'LITERAL_PALETTE: ' + '; '.join(offenders[:5])
    return 0, 'зоны 002 (app/ui/navigation/tab-shell/start-screen) без hex-литералов'


def check_font(repo: Path, name, case):
    path = repo / name
    if not path.exists():
        return 1, f'{case}_ABSENT: {name}'
    digest = sha256_file(path)
    expected = source_hashes()['font_ttf' if name.endswith('.ttf') else 'font_ofl']
    if digest != expected:
        return 1, f'{case}_HASH_MISMATCH: {digest} != {expected}'
    return 0, f'{name} sha256 совпал'


def check_web_bundle(repo: Path):
    offenders = []
    for file in (repo / 'mobile/src').rglob('*'):
        if file.suffix in ('.ts', '.tsx') and file.is_file() and WEB_BUNDLE_RE.search(file.read_text()):
            offenders.append(str(file.relative_to(repo)))
    if offenders:
        return 1, 'WEB_BUNDLE_IMPORTED: ' + ','.join(offenders)
    return 0, 'импортов design-snapshot bundle/docs в mobile/src нет'


def check_scheme(repo: Path, source):
    path = repo / APP_JSON
    if not path.exists():
        return 1, 'APP_JSON_ABSENT'
    match = re.search(r'"scheme"\s*:\s*"([^"]+)"', path.read_text())
    if not match:
        return 1, 'DEEP_LINK_SCHEME_ABSENT'
    if match.group(1) != source['scheme']:
        return 1, f"DEEP_LINK_SCHEME_CHANGED: {match.group(1)!r} != {source['scheme']!r}"
    return 0, f"scheme={match.group(1)}"


CHECKS = {
    'TOKENS_MATCH': lambda repo, source: check_tokens(repo, source),
    'LITERAL_PALETTE': lambda repo, source: check_literal(repo),
    'FONTS_PRESENT': lambda repo, source: check_font(repo, FONT_TTF, 'FONTS_PRESENT'),
    'FONTS_OFL': lambda repo, source: check_font(repo, FONT_OFL, 'FONTS_OFL'),
    'NO_WEB_BUNDLE': lambda repo, source: check_web_bundle(repo),
    'DEEP_LINK_SCHEME': lambda repo, source: check_scheme(repo, source),
}


def run_cases(repo: Path, cases):
    source = load_source()
    results = {}
    for case in cases:
        rc, detail = CHECKS[case](repo, source)
        results[case] = rc
        print(f'999 static/{case}: rc={rc} {detail}', flush=True)
    return (0 if all(rc == 0 for rc in results.values()) else 1), results


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--case', choices=CASES)
    parser.add_argument('--matrix', action='store_true')
    parser.add_argument('--model', action='store_true')
    args = parser.parse_args()
    repo = args.repo.resolve()
    if not repo.is_relative_to('/tmp/dev-harness-verify'):
        print('999 INFRASTRUCTURE: DISPOSABLE_REQUIRED', file=sys.stderr)
        return 2
    cases = [args.case] if args.case else CASES
    if args.matrix:
        ok = True
        print('MATRIX honest:', flush=True)
        rc, _ = run_cases(repo, cases)
        ok &= rc == 0
        for name, case, (target, old, new) in MUTANTS:
            if case not in cases:
                continue
            files = {}
            if args.model:
                blobs = model_bytes([(target, old, new)] if old else [])
                files.update({repo / t: b for t, b in blobs.items()})
            if old is None:
                files[repo / target] = None
            elif not args.model:
                path = repo / target
                blob = path.read_bytes()
                if blob.count(old.encode()) != 1:
                    raise RuntimeError(f'MUTATION_ANCHOR_NOT_UNIQUE: {target}')
                files[path] = blob.replace(old.encode(), new.encode())
            with installed(files):
                rc, results = run_cases(repo, [case])
            named_red = results.get(case) == 1
            others = {c: v for c, v in results.items() if c != case}
            verdict = named_red and not others
            ok &= verdict
            print(f'MUTANT {name}: named={case} {"RED" if named_red else "GREEN"} -> {"OK" if verdict else "BROKEN"}', flush=True)
        return 0 if ok else 1
    if not (repo / TOKENS_TS).exists() and not args.model:
        print('999 STATIC_THEME_ABSENT')
        return 1
    if args.model:
        blobs = model_bytes()
        extra = {repo / FONT_TTF: None, repo / FONT_OFL: None}
        # шрифты копируем из design-снапшота самого R (источник уже в дереве)
        ttf_src = repo / 'docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/design-system/project/fonts/DMSans-Variable.ttf'
        ofl_src = repo / 'docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/design-system/project/fonts/OFL-DMSans.txt'
        extra[repo / FONT_TTF] = ttf_src.read_bytes()
        extra[repo / FONT_OFL] = ofl_src.read_bytes()
        with installed({**{repo / t: b for t, b in blobs.items()}, **extra}):
            rc, _ = run_cases(repo, cases)
        return rc
    rc, _ = run_cases(repo, cases)
    return rc


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, RuntimeError, ValueError, KeyError) as error:
        print('999 INFRASTRUCTURE:', error, file=sys.stderr)
        sys.exit(2)
