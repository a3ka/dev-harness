#!/usr/bin/env python3
# Пин подменён ПРИ удалённом каноне субъекта; снимок неизменен.
import json
import sys
from pathlib import Path

family = Path(sys.argv[1]).resolve()
source = family / 'source.json'
metadata = json.loads(source.read_text(encoding='utf-8'))
metadata['agregat_143']['sha256'] = '0' * 64
source.write_text(json.dumps(metadata, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
(family / 'subject/mobile/scripts/ci-artefakty.cjs').unlink()
