#!/usr/bin/env python3
"""Reference for the materializer public seam; source authenticity is provided by history://."""
import argparse
import json
import re
import sys
from pathlib import Path

QUOTE = 'сделай это с моей подписью, если там есть полноценные законченные вердикты судей'
HEX = re.compile(r'[0-9a-f]{40}\Z')
SESSION = re.compile(r'history://Critic[A-Za-z0-9._-]+\Z')


class Refusal(Exception):
    pass


def decide(history, uri, owner, obj):
    if not SESSION.fullmatch(uri) or history.get('source') != uri:
        raise Refusal('ISTOCHNIK_NE_CRITIC_HISTORY')
    if history.get('agent') != 'critic':
        raise Refusal('AVTOR_NE_CRITIC')
    if QUOTE not in owner:
        raise Refusal('NET_BUKVALNOJ_TSITATY')
    if not HEX.fullmatch(obj):
        raise Refusal('OBJECT_NEVALIDEN')
    task = history.get('task')
    if not isinstance(task, str) or [line for line in task.splitlines() if line.startswith('OBJECT=')] != ['OBJECT=' + obj]:
        raise Refusal('ZADANIE_NE_OB_OBJECT')
    result = history.get('result')
    if not isinstance(result, dict) or result.get('tool') != 'yield' or result.get('complete') is not True:
        raise Refusal('NET_ZAKONCHENNOGO_YIELD')
    text = result.get('verdict')
    if not isinstance(text, str):
        raise Refusal('NET_VERDIKTA')
    lines = text.splitlines()
    if not lines or lines[0] != 'accept':
        raise Refusal('VERDICT_NE_ACCEPT')
    if len(lines) < 3 or lines[1] != 'OBJECT=' + obj or sum(line.startswith('OBJECT=') for line in lines) != 1:
        raise Refusal('VERDICT_OBJECT_NE_SOVPAL')
    fields = [field.strip() for field in lines[2].removeprefix('СУД: ').split(';')]
    if not lines[2].startswith('СУД: ') or fields.count('роль=critic') != 1 or fields.count('сессия=' + uri.removeprefix('history://')) != 1:
        raise Refusal('VERDICT_AVTOR_NE_CRITIC')
    return text


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--history', required=True, type=Path)
    p.add_argument('--history-uri', required=True)
    p.add_argument('--owner-text', required=True, type=Path)
    p.add_argument('--object', required=True)
    p.add_argument('--output', required=True, type=Path)
    args = p.parse_args()
    try:
        text = decide(json.loads(args.history.read_text()), args.history_uri, args.owner_text.read_text(), args.object)
    except (OSError, ValueError, Refusal) as e:
        print('ОТКАЗ:', e, file=sys.stderr)
        return 1
    args.output.write_text(text)
    return 0


if __name__ == '__main__':
    sys.exit(main())
