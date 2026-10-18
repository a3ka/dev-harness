#!/usr/bin/env python3
"""Generated-types vs schema probe (995, круг 1 ревьюера B2).

`src/api/generated/api-5_8.ts` заявлен как производный от
`api/mock-5_8.json#components/schemas`. Проба выводит двустороннее TypeScript-
доказательство ИЗ схемы (конформное значение обязано typecheck-иться,
неконформное — обязано отказывать) и компилирует проект с этим доказательством:
Digest — строка `^sha256:[0-9a-f]{64}$`, DocumentDeliveryProof — 7 обязательных
полей с additionalProperties:false. Расхождение типов со схемой → rc1
TYPES_SCHEMA_MISMATCH; посторонние ошибки tsc → rc2 (не предмет).
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

HERE = Path(__file__).resolve().parent


def digest_sample(schema):
    pattern = schema.get('pattern')
    if schema.get('type') != 'string' or not pattern:
        raise RuntimeError('UNSUPPORTED_DIGEST_SHAPE')
    sample = 'sha256:' + '0' * 64
    if not re.fullmatch(pattern.lstrip('^').rstrip('$'), sample):
        raise RuntimeError('DIGEST_SAMPLE_NONCONFORMANT')
    return sample


def property_sample(name, prop, digest):
    if '$ref' in prop:
        if prop['$ref'] != '#/components/schemas/Digest': raise RuntimeError('UNSUPPORTED_REF:' + name)
        return digest
    if 'enum' in prop:
        values = prop['enum']
        if not values or prop.get('type') != 'string': raise RuntimeError('UNSUPPORTED_ENUM:' + name)
        return values[0]
    kind = prop.get('type')
    if kind == 'string':
        return '2026-10-18T00:00:00Z' if prop.get('format') == 'date-time' else 'pilot995-sample'
    raise RuntimeError('UNSUPPORTED_PROPERTY_TYPE:' + name + ':' + str(kind))


def proof_ts(ddp, digest, required, properties):
    fields = ', '.join(f'{name}: {property_sample(name, properties[name], digest)!r}'
                       for name in required)
    lines = [
        '// Сгенерировано fixtures/workshop_project/pilot_995/types_probe.py — не редактировать.',
        '// Двустороннее доказательство: типы generated/api-5_8.ts против компонентов схемы.',
        "import type { Digest, DocumentDeliveryProof } from '../api/generated/api-5_8';",
        '',
        "const digestSample: string = 'sha256:' + '0'.repeat(64);",
        'const digestConformant: Digest = digestSample;',
        '// @ts-expect-error schema: Digest — type string, объектная форма неконформна',
        'const digestAsObject: Digest = { sha256: digestSample };',
        'const proofConformant: DocumentDeliveryProof = {',
    ]
    lines.append('  ' + fields + ',')
    lines.append('};')
    for name in required:
        rest = ', '.join(f'{other}: {property_sample(other, properties[other], digest)!r}'
                         for other in required if other != name)
        lines.append(f'// @ts-expect-error schema: {name} обязателен')
        lines.append(f'const proofMissing_{name}: DocumentDeliveryProof = {{ {rest} }};')
    lines.append('// @ts-expect-error schema: additionalProperties=false')
    lines.append("const proofExtra: DocumentDeliveryProof = { ...proofConformant, pilot995Extra: 'x' };")
    lines.append('export const pilot995TypeProof = [digestConformant, digestAsObject,')
    lines.append('  proofConformant, proofExtra];')
    return '\n'.join(lines) + '\n'


def run(repo):
    repo = repo.resolve()
    if not repo.is_relative_to('/tmp/dev-harness-verify'): raise RuntimeError('DISPOSABLE_REQUIRED')
    mobile = repo / 'mobile'
    types_file = mobile / 'src/api/generated/api-5_8.ts'
    if not types_file.exists():
        print('995 TYPES_FILE_ABSENT'); return 1
    expected = json.loads((HERE / 'source.json').read_text())
    raw = (repo / 'api/mock-5_8.json').read_bytes()
    if hashlib.sha256(raw).hexdigest() != expected['hashes']['schema']:
        raise RuntimeError('SCHEMA_SOURCE_CHANGED')
    schemas = json.loads(raw)['components']['schemas']
    digest = digest_sample(schemas['Digest'])
    ddp = schemas['DocumentDeliveryProof']
    required = ddp.get('required') or []
    properties = ddp.get('properties') or {}
    if ddp.get('type') != 'object' or not required or ddp.get('additionalProperties') is not False:
        raise RuntimeError('UNSUPPORTED_DDP_SHAPE')
    workspace = mobile / 'src/__pilot995_types__'
    if workspace.exists(): raise RuntimeError('TYPES_WORKSPACE_OCCUPIED')
    workspace.mkdir()
    try:
        (workspace / 'type-proof.ts').write_text(proof_ts(ddp, digest, required, properties))
        proc = subprocess.run(['node', str(mobile / 'node_modules/typescript/bin/tsc'), '--noEmit'],
                              cwd=mobile, capture_output=True, text=True, timeout=240)
        errors = [line for line in proc.stdout.splitlines() + proc.stderr.splitlines()
                  if 'error TS' in line]
        mine = [line for line in errors if '__pilot995_types__' in line]
        alien = [line for line in errors if '__pilot995_types__' not in line]
        if proc.returncode == 0 and not errors:
            print('995 types checked=2 schema=matched'); return 0
        if alien:
            raise RuntimeError('UNRELATED_TSC_ERROR:' + '; '.join(alien[:3]))
        print('995 TYPES_SCHEMA_MISMATCH: ' + ' | '.join(mine[:8])); return 1
    finally:
        for child in workspace.iterdir(): child.unlink()
        workspace.rmdir()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo', type=Path, required=True)
    args = parser.parse_args()
    return run(args.repo)


if __name__ == '__main__':
    try: sys.exit(main())
    except (OSError, RuntimeError, ValueError, KeyError, subprocess.TimeoutExpired) as error:
        print('995 INFRASTRUCTURE:', error, file=sys.stderr); sys.exit(2)
