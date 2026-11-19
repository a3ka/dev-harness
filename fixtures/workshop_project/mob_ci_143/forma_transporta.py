"""143 v+1 (v5, окно ленда 197): форма артефактного транспорта субъекта.

Единственный источник lane-формы — модель контракта 197
(``fixtures/workshop_project/mob_ci_artifacts_local_197/model/.github/
workflows/mobile.yml``) по ССЫЛКЕ, не копией: байты этой модели пинирует
собственная батарея 197 (еши source.json 197), а здесь пинируется её
СТРУКТУРНЫЙ канон — safe_load + нормализация run-шагов обоих агрегатов тем
же правилом, каким их сравнивает sweep (срезка строк-комментариев и
одиночный mkdir «screen-evidence-collected»). Нормализация делает пин
инвариантным к правкам комментариев/формулировок внутри агрегатных run-шагов
(замер: модель 197 v2 → v3 меняет только такие тексты — структурные каноны
равны) и КРАСНЫМ при любой иной структурной правке модели 197: смена
lane-формы без нового v+1 у 143 не даёт зелёное (rc 2 ORACLE_TAMPERED ДО
клеток).

Форма транспорта ЦЕЛА по работникам: 'lane' ⇔ НИ ОДИН из пяти legacy-работников
не несёт канал артефактов GitHub (uses actions/upload-artifact@* /
actions/download-artifact@*, run с «gh run download») — зеркало И-1 197 в
объёме, которым владеет 143. Смешанный workflow (часть работников на lane,
часть на канале GitHub) формой 'lane' не становится и целыми базами пинов
не принимается: клетка legacy красна LEGACY_JOB_CHANGED. Закрытие канала
артефактов ВО ВСЁМ workflow (вне пяти работников) судит батарея 197 (a01–a03),
не эта — разделение зон дословно по замороженным нормам 197 §1.
"""

import hashlib
import json
from pathlib import Path

import yaml

HERE = Path(__file__).resolve().parent
PUT_MODELI_197 = "../mob_ci_artifacts_local_197/model/.github/workflows/mobile.yml"

# Пять legacy-работников frozen 143 (И-15): носители формы транспорта.
LEGACY = ("e2e-splash", "e2e-first-run", "e2e-erstinformation", "e2e-start", "e2e-pilot")

# Продюсерская пара чтения APK (И-4 197 на работниках 143): литералы env,
# которые digest-чтение обязано брать ИЗ outputs сборки, не из своего прогона.
PARA_SBORKI = ("${{ needs.build-apk.outputs.run_id }}",
               "${{ needs.build-apk.outputs.run_attempt }}")


def _kanonichno(v):
    if isinstance(v, dict):
        # PyYAML парсит `on:` в bool True; смешение bool/str ключей не
        # сортируется json — тегируем bool, коллизий с текстовыми нет.
        return {("_b:" + str(k).lower()) if isinstance(k, bool) else str(k): _kanonichno(x)
                for k, x in v.items()}
    if isinstance(v, list):
        return [_kanonichno(x) for x in v]
    return v


def _norm_agregat(text):
    # То же правило, что в workflow_sweep_v3.aggregate_run: комментарии
    # run-шага и одиночная страховка-mkdir не меняют исполняемую суть.
    if not isinstance(text, str):
        return text
    commands = [line for line in text.splitlines() if not line.lstrip().startswith("#")]
    mkdir = "mkdir -p mobile/screen-evidence-collected"
    if commands.count(mkdir) == 1:
        commands.remove(mkdir)
    return "\n".join(commands)


def kanon_struktury(wf):
    v = _kanonichno(wf)
    for job in ("android-e2e", "mobile-regression-signal"):
        for s in (v.get("jobs", {}).get(job, {}) or {}).get("steps", []):
            if "run" in s:
                s["run"] = _norm_agregat(s["run"])
    return json.dumps(v, sort_keys=True, ensure_ascii=False)


def bajty_modeli_197():
    p = (HERE / PUT_MODELI_197).resolve()
    if not p.is_file():
        return None, "файла нет %s" % PUT_MODELI_197
    return p.read_bytes(), None


def model_197(src=None):
    """(workflow|None, ошибка|None). Пин — source.json:.ssylki['model-197']
    (sha256 структурного канона); рассинхрон = ORACLE_TAMPERED у вызывающего."""
    bajty, osh = bajty_modeli_197()
    if osh:
        return None, osh
    try:
        wf = yaml.safe_load(bajty.decode("utf-8"))
    except yaml.YAMLError as e:
        return None, "не YAML: %s" % e
    if not isinstance(wf, dict) or not isinstance(wf.get("jobs"), dict):
        return None, "workflow без jobs"
    for j in LEGACY:
        if j not in wf["jobs"]:
            return None, "модель 197 без legacy-работника %s" % j
    if src is not None:
        ssylka = (src.get("ssylki") or {}).get("model-197") or {}
        ozhidal = ssylka.get("sha256_struktury")
        if not ozhidal:
            return None, "source.json без ssylki.model-197.sha256_struktury"
        fakt = hashlib.sha256(kanon_struktury(wf).encode("utf-8")).hexdigest()
        if fakt != ozhidal:
            return None, "структурный канон %s ≠ пину %s" % (fakt, ozhidal)
    return wf, None


def forma_transporta(wf):
    """'lane' | 'old' — по ЦЕЛОМУ набору пяти legacy-работников."""
    for j in LEGACY:
        for s in (wf.get("jobs", {}).get(j) or {}).get("steps", []):
            uses = str(s.get("uses") or "")
            if uses.startswith("actions/upload-artifact@") or uses.startswith("actions/download-artifact@"):
                return "old"
            if "gh run download" in str(s.get("run") or ""):
                return "old"
    return "lane"
