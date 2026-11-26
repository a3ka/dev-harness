#!/usr/bin/env python3
"""Reachability reference: native JSON decoding, not a required implementation."""
import json
import os
from pathlib import Path
import re
import sys


def stop(message):
    print('NOT_IMPLEMENTED: ' + message, file=sys.stderr)
    raise SystemExit(2)


def main():
    args = sys.argv[1:]
    selected = None
    bind = '--bind' in args
    for index, arg in enumerate(args):
        if arg == '--session':
            if index + 1 == len(args):
                stop('--session требует ID')
            selected = args[index + 1]
    if selected is not None and not re.fullmatch(r'[A-Za-z0-9._-]+', selected):
        stop('session-id вне алфавита')
    files = sorted(Path(os.environ['HARNESS_SESSION_HOME']).rglob('*.jsonl'))
    if selected is not None:
        files = [p for p in files if p.stem == selected]
    if not files:
        stop('сессия не найдена')
    names = [p.stem for p in files]
    if (selected is not None or bind) and len(set(names)) != len(names):
        stop('SESSION_AMBIGUOUS: ' + ' | '.join(map(str, files)))
    output = []
    for path in files:
        if bind and not re.fullmatch(r'[A-Za-z0-9._-]+', path.stem):
            stop('session-id вне алфавита')
        try:
            events = [json.loads(line) for line in path.read_text().splitlines() if line.strip()]
        except (ValueError, OSError):
            stop('TRACE_INVALID: ' + str(path))
        role = ''
        object_id = '-'
        changes = []
        for event in events:
            if not isinstance(event, dict):
                stop('TRACE_INVALID: ' + str(path))
            message = event.get('message', {})
            if event.get('type') == 'message' and isinstance(message, dict):
                if message.get('agent'):
                    role = message['agent']
                if message.get('role') == 'user':
                    for content in message.get('content', []):
                        if isinstance(content, dict) and isinstance(content.get('text'), str):
                            for line in content['text'].splitlines():
                                if object_id == '-' and re.fullmatch(r'OBJECT=[0-9a-f]{40}', line):
                                    object_id = line[7:]
            if event.get('type') == 'model_change':
                model = event.get('model')
                fallback = event.get('resolvedModelIsFallback')
                if not isinstance(model, str) or not re.fullmatch(r'[A-Za-z0-9._/@:-]+', model) or type(fallback) is not bool:
                    stop('TRACE_INVALID: ' + str(path))
                changes.append((model, fallback))
        if not changes:
            stop('TRACE_EMPTY: ' + str(path))
        for model, fallback in changes:
            row = [role, model, 'denied' if fallback else 'allowed']
            if bind:
                row += [path.stem, object_id]
            output.append('\t'.join(row))
    print('\n'.join(output))


if __name__ == '__main__':
    main()
