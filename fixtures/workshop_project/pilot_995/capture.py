#!/usr/bin/env python3
"""Capture immutable source expectations before invoking a subject."""
import argparse
import hashlib
import json
from pathlib import Path


def capture(mob, back):
    paths = {
        'copy': back / 'sources/frontend-ux1_17_8_2/BrokerOS_UI_Copy_DE.json',
        'examples': mob / 'api/api-examples.json',
        'schema': mob / 'api/mock-5_8.json',
        'openapi': mob / 'api/BrokerOS_Unified_OpenAPI_v3.yaml',
        'bindings': mob / 'api/frontend-consumer-bindings.json',
        'matrix': back / 'sources/frontend-ux1_17_8_2/Complior_Screen_Matrix_1_16.json',
        'design': back / 'sources/frontend-ux1_17_8_2/BrokerOS_Mobile_Design_Data.json',
        'acceptance': back / 'tests/acceptance-ux1175.json',
    }
    blobs = {key: path.read_bytes() for key, path in paths.items()}
    entries = json.loads(blobs['copy'])['entries']
    keys = ['action.F03.A01', 'action.F03.A02', 'frame.F03.01.title', 'frame.F03.02.title', 'frame.F03.04.title', 'frame.F03.04.body', 'frame.F02.01.body', 'ui.auth.demo_entry', 'ui.auth.code_resend', 'ui.auth.code_resend_sent', 'ui.auth.code_resend_wait']
    selected = {e['copy_key']: e for e in entries if e['copy_key'] in keys}
    assert set(selected) == set(keys)
    assert all(selected[k]['review_status'] == 'PRODUCT_COPY_REVIEW_REQUIRED' for k in keys if k.startswith('ui.auth.'))
    examples = json.loads(blobs['examples'])['examples']
    result = {'copy': {k: e['text'] for k, e in selected.items()}, 'copyStatus': {k: e['review_status'] for k, e in selected.items()}, 'hashes': {k: hashlib.sha256(v).hexdigest() for k, v in blobs.items()}}
    for key, op in [('session', 'getSession'), ('disclosure', 'getDisclosure')]:
        result[key] = next(e['value'] for e in examples if e['operation_id'] == op and e['side'] == 'response_200')
    return result


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--mob', type=Path, required=True)
    p.add_argument('--back', type=Path, required=True)
    args = p.parse_args()
    print(json.dumps(capture(args.mob, args.back), ensure_ascii=False, indent=2))
