#!/usr/bin/env python3
# Оракул s01: меняем ровно байт оригинала, source.json остаётся прежним.
# Вход — изолированная копия СЕМЬИ, не дерево субъекта.
import json
import sys
from pathlib import Path

family = Path(sys.argv[1]).resolve()
metadata = json.loads((family / 'source.json').read_text(encoding='utf-8'))
snapshot = family / metadata['agregat_143']['fixture']
data = snapshot.read_bytes()
snapshot.write_bytes(bytes([data[0] ^ 1]) + data[1:])
