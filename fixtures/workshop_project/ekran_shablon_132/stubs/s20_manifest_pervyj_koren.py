"""Стаб s20 (manifest-pervyj-koren): манифест объявленного пути читается
только из ПЕРВОГО корня, где файл есть (харнесс прежде репо) — реализация
эталона круга 3 дословно, обёрнутая в список одного найденного. Дефект
наблюдаем на входах записи stab_vhod source.json: файл по тому же пути в
--repo с чужим кадром (zamenjaet) либо с кадрами судимой пачки
(ne_trogaet) судом не виден — коллизия корней арбитража 132 Б1–Б2."""
import json

from _model import m, run


def _nahodi_manifest_pervyj(harness, repo, rel):
    for root in (harness, repo):
        p = root / rel
        if not p.is_file():
            continue
        try:
            mm = json.loads(p.read_text(encoding='utf-8'))
        except (OSError, ValueError):
            return None
        if not isinstance(mm, dict) or not isinstance(mm.get('kadry'), list):
            return None
        return [[e.get('id') for e in mm['kadry'] if isinstance(e, dict)]]
    return None


m._nahodi_manifest = _nahodi_manifest_pervyj
run()
