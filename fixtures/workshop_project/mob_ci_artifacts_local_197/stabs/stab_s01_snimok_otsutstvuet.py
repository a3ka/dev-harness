#!/usr/bin/env python3
# Оракул s01: удаляем снимок при прежнем source.json.
# Вход — изолированная копия СЕМЬИ, не дерево субъекта.
import json
import sys
from pathlib import Path

family = Path(sys.argv[1]).resolve()
metadata = json.loads((family / 'source.json').read_text(encoding='utf-8'))
(family / metadata['agregat_143']['fixture']).unlink()
