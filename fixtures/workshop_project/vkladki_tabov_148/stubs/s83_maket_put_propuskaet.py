"""Стаб s83 (maket-put): отсутствие файла по каноническому пути в R
подменяется носителем батареи — докритическое поведение (блок 2
Crit148): продукт без заявленного PNG проходит суд по байтам носителя."""
from pathlib import Path as _Path

from _produkt import m, run


def _podmena(repo, rel):
    put = repo / rel
    if put.is_file():
        return put
    return m.NOS_MAKET / _Path(rel).name


m.put_maketa = _podmena
run()
