#!/usr/bin/env python3
"""Reference for the materializer public seam; source authenticity is provided by history://.

Инварианты двери (контракт 165, раздел «Входы»), каждое — именованный отказ:
  uri вне алфавита history://Critic<ID>  -> URI_NEVALIDEN
  негекс-OBJECT                          -> OBJECT_NEVALIDEN
  вторая/смещённая строка СУД:           -> SUD_NE_EDINSTVENNA
  имя выхода вне verdicts/critic/        -> OUT_ZONE
  перезапись несовпадающими байтами      -> PEREZAPIS_NE_SOVPAL
"""
import argparse
import json
import re
import sys
from pathlib import Path

QUOTE = 'сделай это с моей подписью, если там есть полноценные законченные вердикты судей'
HEX = re.compile(r'[0-9a-f]{40}\Z')
SESSION = re.compile(r'history://Critic[A-Za-z0-9._-]+\Z')
ZONE = ('verdicts', 'critic')


class Refusal(Exception):
    """Именованный отказ двери: rc 1, запись не производится."""


class EnvMissing(Exception):
    """Негодная среда (в корне нет существующей зоны verdicts/critic/): rc 2."""


def decide(history, uri, owner, obj):
    if not SESSION.fullmatch(uri):
        raise Refusal('URI_NEVALIDEN')
    if history.get('source') != uri:
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
    sud = [i for i, line in enumerate(lines) if line.startswith('СУД:')]
    if len(sud) != 1 or sud[0] != 2:
        raise Refusal('SUD_NE_EDINSTVENNA')
    fields = [field.strip() for field in lines[2].removeprefix('СУД: ').split(';')]
    if fields.count('роль=critic') != 1 or fields.count('сессия=' + uri.removeprefix('history://')) != 1:
        raise Refusal('VERDICT_AVTOR_NE_CRITIC')
    return text


def materialize(root, out, text):
    zone = Path(root).joinpath(*ZONE)
    if not zone.is_dir():
        raise EnvMissing('в корне нет существующей зоны verdicts/critic/')
    if not isinstance(out, str) or not out or '/' in out or '\\' in out or out in ('.', '..'):
        raise Refusal('OUT_ZONE')
    dest = zone / out
    if dest.exists() and dest.read_bytes() != text.encode('utf-8'):
        raise Refusal('PEREZAPIS_NE_SOVPAL')
    dest.write_text(text)


def door(root, history, uri, owner, obj, out):
    text = decide(history, uri, owner, obj)
    materialize(root, out, text)
    return text


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--repo-root', required=True, type=Path)
    p.add_argument('--history', required=True, type=Path)
    p.add_argument('--history-uri', required=True)
    p.add_argument('--owner-text', required=True, type=Path)
    p.add_argument('--object', required=True)
    p.add_argument('--output', required=True)
    args = p.parse_args()
    try:
        history = json.loads(args.history.read_text())
    except (OSError, ValueError) as e:
        print('ОТКАЗ:', e, file=sys.stderr)
        return 1
    try:
        owner = args.owner_text.read_text()
    except OSError as e:
        print('ОТКАЗ:', e, file=sys.stderr)
        return 1
    try:
        door(args.repo_root, history, args.history_uri, owner, args.object, args.output)
    except EnvMissing as e:
        print('NOT_IMPLEMENTED:', e, file=sys.stderr)
        return 2
    except (Refusal, OSError) as e:
        print('ОТКАЗ:', e, file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
