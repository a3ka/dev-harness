"""Общая основа lane-стабов батареи 143 v+1 (окно ленда 197; Н-39).

Стаб-файлы получает движок probe.py: каталог копии ЭТАЛОНА этой батареи.
Lane-стаб сначала подменяет mobile.yml копии БАЙТАМИ модели 197 — по ссылке
(../mob_ci_artifacts_local_197/model/...; единственный источник lane-формы,
байты пинирует батарея 197) — затем вносит один дефект. Якоря литеральные:
дрейф модели 197 сверх нормализованного пина = отказ мутатора, не тихий стаб.
"""
import sys
from pathlib import Path

import yaml

ZDES = Path(__file__).resolve().parent
IMJA_DIGEST_SHAGA = "APK сборки: артефакт по имени, digest до установки"
MODEL_197 = (ZDES / "../../mob_ci_artifacts_local_197/model/.github/workflows/mobile.yml").resolve()

def otkaz(soobshchenie):
    print("MUTACIJA_NE_NAIDENA: %s" % soobshchenie, file=sys.stderr)
    raise SystemExit(1)


def osnova_197(cel):
    """Подмена копии эталона на lane-модель 197; возвращает разобранный workflow."""
    if not MODEL_197.is_file():
        otkaz("модель 197 отсутствует: %s" % MODEL_197)
    bajty = MODEL_197.read_bytes()
    (cel / ".github/workflows/mobile.yml").write_bytes(bajty)
    return yaml.safe_load(bajty.decode("utf-8"))


def zapis(wf, cel):
    (cel / ".github/workflows/mobile.yml").write_text(
        yaml.safe_dump(wf, sort_keys=False, allow_unicode=True, width=1000000),
        encoding="utf-8")


def shag_po_imeni(wf, job, imja):
    for i, s in enumerate(wf["jobs"][job].get("steps", [])):
        if (s.get("name") or "") == imja:
            return i, s
    return -1, None
