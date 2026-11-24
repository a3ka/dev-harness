# 219: exact snapshot extension; historic 087 cases and predicates are unchanged.
from pathlib import Path
U87 += [row.split('\t')[1] for row in (
    Path(__file__).resolve().parents[1]
    / 'workshop_project/uchetnye_puti_219/model/uchet.tsv'
).read_text(encoding='utf-8').splitlines()]
