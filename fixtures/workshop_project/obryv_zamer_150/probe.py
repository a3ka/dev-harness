#!/usr/bin/env python3
# БАРЬЕР-ГУАРД контракта 150 (prichinnyy-zamer-obryva): судит ОДНУ вещь —
# в каждом красном экранном job по сигнатуре обрыва adb CI публикует
# ограниченный redacted артефакт причинного замера, снятого ДО
# остановки/повтора эмулятора; зелёный и продуктовый красный без обрыва
# не публикуют и не падают; обёртка не меняет итог job.
#
# Основа: слово владельца 2026-10-26 п.2 (docs/owner/2026-10-26-obryv-emulyatora-v2.md),
# §4/§5/§10/§12 verdicts/consultant/obryv-emulyatora-mob-astra-v1.md.
#
# Правило 8: оракул source.json читается в память ДО вызова субъекта;
# порча пиннованных носителей — rc 2 ORACLE_TAMPERED ДО клеток. Н-39:
# обманные стабы — мутации модели КОДОМ (stabs/*.py), привязки — ТОЛЬКО
# source.json:.stab_vhod; рассинхрон — rc 2.
#
# Субъект: дерево продукта (.github/workflows/mobile.yml + mobile/ci-screens.json
# + mobile/scripts/zamer_obryva.sh). Судит КАЖДОГО работника КАРТЫ
# (ekrany[].job + integracija.job — канон разбора тут, не у субъекта):
# структурные клетки (z01–z03, z05) — по всем работникам; скрипт — z04;
# поведенческие (b01–b11) — исполнительный replay обёртки ПЕРВОГО работника
# карты в замкнутой песочнице с подложными adb/sleep (виртуальные секунды)
# и НАСТОЯЩИМИ процессами-подделками qemu/adb-server (живость PID честна;
# КАЖДЫЙ порождённый PID останавливается и дожидается, b12 судит гигиену
# миров после всех replay). RECOVERED-ns моделируется по frozen 995/5:
# финальная попытка зелёная + сохранённый архив diagnostics/attempt-1 с
# сигнатурой — гейт судит ТЕКУЩУЮ попытку (--exclude-dir=diagnostics).
# Экранные тела субъектов НЕ исполняются и не судятся — их держат батареи
# 143/147/148/995; replay управляет МИРОМ вокруг обёртки (живой эмулятор,
# обрыв с маркером signal 9 в журнал, сигнатура в ns, wipe/перезапуск).
"""Батарея 150 (prichinnyy-zamer-obryva).

Режимы (дверь red_obryv_zamer_150.sh передаёт аргументы дальше):
  (без флага, без --repo)  — субъект = дерево харнесса: субъекта нет,
                              rc 1, все клетки красны поимённо (SUBJECT_ABSENT)
  (без флага, --repo R)    — судится живой продукт R (до реализации красен
                              поимённо; зелень без субъекта невозможна)
  --model                  — эталон model/ (контроль входов): rc 0
  --stabs                  — контроль + матрица обманных стабов (SVJAZI N)
  --oracle-tamper          — порча каждого носителя: ORACLE_TAMPERED rc 2 ДО клеток
  --seed N                 — тот же результат при другом порядке (инвариантность)

Коды: 0 — зелено; 1 — красная клетка либо живой стаб (STAB_ZHIV) либо нет
субъекта; 2 — нечем проверять (нет python-зависимостей, ORACLE_TAMPERED,
дрейф стабов/модели).
"""
import hashlib
import importlib.util
import json
import os
import re
import shutil
import signal
import subprocess as sp
import sys
import tempfile
import threading
import time
import uuid
from pathlib import Path

import yaml

HERE = Path(__file__).resolve().parent
MODEL = HERE / "model"
STABS = HERE / "stabs"
SOURCE = HERE / "source.json"

SUBJECT_FILES = [".github/workflows/mobile.yml", "mobile/ci-screens.json",
                 "mobile/scripts/zamer_obryva.sh"]

Z_SHAG_START = "Замер обрыва: запуск сэмплера"
Z_SHAG_SBOR = "Замер обрыва: сбор причинного снимка"
Z_SHAG_ART = "Замер обрыва: артефакт"
EKRANNYE_MARKERY = ("PORT=", "maestro", "ekran_shablon", "ci-e2e")
ZAPRET_MASKIROVKI = "continue-on-error"
SIGNATURY_RE = re.compile(
    r"device offline|adb: device not found|device [^ ]* not found|DeviceServerDiedException")
FAJL_MAKS_BAJT = 524288
ARTEFAKT_MAKS_BAJT = 2097152
# виртуальные секунды сценариев (break на 60 — пробы гостя n%15 успевают 3 раза)
T_KRASNOGO = 60
T_KONTSA = 70
REALMAJ_TIMAUT = 25


class OshibkaOrakula(Exception):
    pass


# ── оракул (правило 8: до субъекта) ─────────────────────────────────────────
def zhestkij_kanon(src):
    problemy = []
    for otn, digest in (src.get("piny") or {}).items():
        p = HERE / otn
        try:
            fakt = hashlib.sha256(p.read_bytes()).hexdigest()
        except OSError as e:
            raise OshibkaOrakula("носитель %s не читается: %s" % (otn, e))
        if fakt != digest:
            problemy.append("носитель %s sha %s != пин" % (otn, fakt[:12]))
    staby = sorted((src.get("stab_vhod") or {}).keys())
    na_diske = sorted(str(p.relative_to(HERE)).replace(os.sep, "/")
                      for p in STABS.glob("stab_*.py")) if STABS.is_dir() else []
    if staby != na_diske:
        raise OshibkaOrakula("дрейф стабов: source.json %s != диск %s" % (staby, na_diske))
    for otn, kletka in (src.get("stab_vhod") or {}).items():
        p = HERE / otn
        if not p.is_file():
            raise OshibkaOrakula("стаб %s отсутствует" % otn)
        tekst = p.read_text(encoding="utf-8")
        if "def mutiruj(" not in tekst:
            raise OshibkaOrakula("стаб %s без mutiruj()" % otn)
    if problemy:
        raise OshibkaOrakula("; ".join(problemy))


# ── независимый канон карты (грамматика 143/2; субъект не зовётся) ─────────
def rabotniki_iz_karty(m):
    spisok = []
    for z in (m.get("ekrany") or []):
        if z.get("job"):
            spisok.append({"job": z["job"], "id": z.get("id", ""),
                           "ns": z.get("output_namespace", "")})
    i = m.get("integracija") or {}
    if i.get("job"):
        spisok.append({"job": i["job"], "id": i.get("id", "integracija"),
                       "ns": i.get("output_namespace", "")})
    return spisok


def karta_subiekta(rep):
    p = Path(rep) / "mobile" / "ci-screens.json"
    if not p.is_file():
        raise KartaNet("KARTA_NET: %s" % p)
    try:
        return json.loads(p.read_text(encoding="utf-8"))
    except Exception as e:
        raise KartaNet("KARTA_NE_JSON: %s" % e)


class KartaNet(Exception):
    pass


def wf_subiekta(rep):
    p = Path(rep) / ".github" / "workflows" / "mobile.yml"
    if not p.is_file():
        return None
    return yaml.safe_load(p.read_text(encoding="utf-8"))


# ── подложные adb/sleep (виртуальное время — счётчик тиков sleep) ───────────
SHIM_SLEEP = """#!/bin/sh
# подложный sleep (150): время виртуально — sleep N добавляет N тиков в
# $ZAMER_TAKTY и возвращается мгновенно; сэмплер живёт виртуальными секундами.
printf '+%s\\n' "$1" >> "${ZAMER_TAKTY:-/dev/null}" 2>/dev/null
exit 0
"""

SHIM_ADB = """#!/usr/bin/env python3
# подложный adb (150): состояние устройства — по сценарию (виртуальное время =
# сумма тиков $ZAMER_TAKTY); пробы гостя и logcat отвечают при state=device;
# каждый вызов пишется в $ZAMER_ADB_LOG. Реального транспорта нет.
import json, os, sys


def ticki():
    try:
        s = 0
        with open(os.environ["ZAMER_TAKTY"]) as f:
            for line in f:
                line = line.strip()
                if line.startswith("+"):
                    try:
                        s += float(line[1:])
                    except ValueError:
                        pass
        return s
    except Exception:
        return 0.0


def log(zapros):
    with open(os.environ.get("ZAMER_ADB_LOG", "/dev/null"), "a") as f:
        f.write("ADB %.1f %s\\n" % (ticki(), zapros))


sc = {}
try:
    sc = json.load(open(os.environ.get("ZAMER_ADB_SCENARIJ", "/dev/null")))
except Exception:
    pass
serial = os.environ.get("ZAMER_SERIAL", "")
a = sys.argv[1:]
sostojanie = "netu"
for porog, st in sorted(sc.get("sostojanija", []), key=lambda x: x[0]):
    if ticki() >= porog:
        sostojanie = st
if a[:1] == ["devices"]:
    log("devices")
    print("List of devices attached")
    if sostojanie == "device":
        print(serial + "\\tdevice")
    elif sostojanie == "offline":
        print(serial + "\\toffline")
    sys.exit(0)
if a[:2] == ["-s", serial] and len(a) > 2:
    if a[2] == "logcat":
        log("logcat")
        if sostojanie != "device":
            sys.exit(1)
        tekst = sc.get("logcat", "logcat-tishina\\n")
        p = sc.get("logcat_fajl")
        if p:
            try:
                sys.stdout.write(open(p, encoding="utf-8", errors="replace").read())
                sys.exit(0)
            except Exception:
                sys.exit(1)
        sys.stdout.write(tekst)
        sys.exit(0)
    if a[2] == "shell":
        log("shell")
        if sostojanie != "device":
            sys.exit(1)
        gost = sc.get("gost", {})
        vnutr = " ".join(a[3:])
        if "boot_id" in vnutr:
            print(gost.get("boot_id", "b00t-0000"))
        if "pidof" in vnutr:
            print(gost.get("adbd", "4242"))
        if "uptime" in vnutr:
            print("%s 12.20" % gost.get("uptime", "777.5"))
        if not ("boot_id" in vnutr or "pidof" in vnutr or "uptime" in vnutr):
            sys.exit(1)
        sys.exit(0)
log("neizvestno:" + " ".join(a[:2]))
sys.exit(0)
"""


SHIM_PGREP = """#!/usr/bin/env python3
# подложный pgrep (150): паттерн применяется к НАСТОЯЩИМ /proc cmdline, но
# ответ ограничен процессами мира песочницы (нонс Z150_NONCE в cmdline) —
# чужие qemu/adb-server станции не попадают в замер батареи и наоборот.
import os, re, sys
args = sys.argv[1:]
pat = None
i = 0
while i < len(args):
    if args[i] == "-f" and i + 1 < len(args):
        pat = args[i + 1]
        i += 2
        continue
    i += 1
nonce = os.environ.get("Z150_NONCE", "")
if pat is None or not nonce:
    sys.exit(1)
try:
    rx = re.compile(pat)
except re.error:
    sys.exit(2)
for d in sorted(os.listdir("/proc"), key=lambda x: int(x) if x.isdigit() else 0):
    if not d.isdigit():
        continue
    try:
        with open("/proc/%s/cmdline" % d, "rb") as fh:
            cmdline = fh.read().replace(b"\\0", b" ").decode("utf-8", "replace").strip()
    except OSError:
        continue
    if nonce in cmdline and rx.search(cmdline):
        print(d)
sys.exit(0)
"""


def _napishi(p, tekst):
    p.write_text(tekst, encoding="utf-8")
    p.chmod(0o700)


def _zapusti(tekst_cmd, cwd, env, vremja=60):
    p = sp.Popen(["bash", "-c", tekst_cmd], cwd=str(cwd), env=env,
                 stdout=sp.PIPE, stderr=sp.PIPE, text=True, start_new_session=True)
    try:
        out, err = p.communicate(timeout=vremja)
        return p.returncode, out, err
    except sp.TimeoutExpired:
        try:
            os.killpg(os.getpgid(p.pid), signal.SIGKILL)
        except OSError:
            pass
        p.communicate()
        return 124, "", "TIMEOUT"


def _poddelnyj_proces(imea, tmp):
    """НАСТОЯЩИЙ процесс-подделка (argv0 = имя): kill -0 и /proc честны.
    Дескриптор лога закрывается сразу — процесс переживёт мир, только если
    вызывающий его не остановил (ловец — finally replay + клетка b12)."""
    logf = Path(tmp) / ("proc-%s.log" % re.sub(r"[^A-Za-z0-9_-]", "_", imea)[:40])
    with open(logf, "w") as fh:
        p = sp.Popen(["bash", "-c", 'exec -a "%s" sleep 600' % imea],
                     stdout=fh, stderr=sp.DEVNULL, start_new_session=True)
    return p


class Vremja:
    """Виртуальные секунды мира = сумма тиков подложного sleep."""

    def __init__(self, takty):
        self.takty = Path(takty)

    def tek(self):
        s = 0.0
        try:
            for line in self.takty.read_text(encoding="utf-8").splitlines():
                if line.startswith("+"):
                    try:
                        s += float(line[1:])
                    except ValueError:
                        pass
        except OSError:
            pass
        return s


# ── сценарии replay ----------------------------------------------------------------
# mir: sostojanija adb, gost, logcat(+fajl), sobytija [(t, dejstvie)]
def sc_obryv(dopolnitelno=None):
    sc = {
        "sostojanija": [[0, "device"], [T_KRASNOGO, "offline"]],
        "gost": {"boot_id": "b0b0-1111-2222-3333-444444444444", "adbd": "4242",
                 "uptime": "777.5"},
        # PEM-блок (BEGIN+тело+END) — многострочный секрет кольца/логката (b07)
        "logcat": ("I/SystemUI(1): zapusk\nE/adbd(2): transport error\n"
                   "D/maestro: Bearer AAAABBBBCCCCDDDD1111 zaghiznjaetsja zdes\n"
                   "-----BEGIN RSA PRIVATE KEY-----\n"
                   "SUPERSECRET_PRIVATE_KEY_BODY_150\n"
                   "-----END RSA PRIVATE KEY-----\n"),
        "sobytija": [
            [T_KRASNOGO, "ubit_qemu"],
            [T_KRASNOGO + 2, "signatura"],
            [T_KRASNOGO + 3, "smenit_adb_server"],
        ],
        "ns_zelenyj": False,
    }
    if dopolnitelno:
        sc.update(dopolnitelno)
    return sc


SCENARII = {
    "zelenyj": {
        "sc": {"sostojanija": [[0, "device"]],
               "gost": {"boot_id": "zelen-0000-0000", "adbd": "1111", "uptime": "555.1"},
               "logcat": "I/SystemUI: vse khorosho\n"},
        "sobytija": [[T_KONTSA - 1, "ubit_qemu"]],  # cleanup экранного шага
        "ns": "zelenyj",
    },
    "produkt": {
        "sc": {"sostojanija": [[0, "device"]],
               "gost": {"boot_id": "produkt-000", "adbd": "2222", "uptime": "666.1"},
               "logcat": "I/test: assert proverka\n"},
        "sobytija": [[T_KONTSA - 1, "ubit_qemu"]],
        "ns": "produkt",
        "decoj": True,
    },
    "obryv": {"sc": None, "sobytija": None, "ns": "obryv"},
    "vosstanovlennyj": {
        # RECOVERED по frozen 995/5: финальная (2-я) попытка зелёная, но её
        # публикация СОХРАНЯЕТ архив диагностики УПАВШЕЙ 1-й попытки
        # (opublikovat(): maestro-out/diagnostics/attempt-1/maestro.log с
        # device offline/DeviceServerDiedException) — гейт 150 обязан судить
        # ТЕКУЩУЮ попытку, не весь ns (b11; блокер 4 круга 1)
        "sc": {"sostojanija": [[0, "device"], [T_KRASNOGO, "offline"],
                               [T_KRASNOGO + 8, "device"]],
               "gost": {"boot_id": "vosst-0000-0000", "adbd": "3333", "uptime": "888.1"},
               "logcat": "I/SystemUI: vtoraja popytka\n"},
        "sobytija": [
            [T_KRASNOGO, "ubit_qemu"],
            [T_KRASNOGO + 2, "signatura"],
            [T_KRASNOGO + 5, "perezapust_qemu"],
            [T_KRASNOGO + 8, "wipe_ns_zelenym"],
            [T_KONTSA - 1, "ubit_qemu"],
        ],
        "ns": "obryv",
    },
}


def replej(subjekt_root, worker, imja_scenarija, tmp, dop_scenarij=None, emu_dopol_strok=0,
            emu_dopol_dlina=0):
    """Исполнительный replay обёртки работника в замкнутой песочнице.

    Возвращает dict: rc_start/rc_sbor, out_dir, spool, takty_sum, adb_log,
    markerы (stroki do signatury / do ubijstva), qemu_pid, oshibka|None.
    """
    wf = wf_subiekta(subjekt_root)
    if wf is None:
        return {"oshibka": "SUBJECT_ABSENT: net .github/workflows/mobile.yml"}
    job = (wf.get("jobs") or {}).get(worker["job"]) or {}
    shagi = job.get("steps") or []
    po_imeni = {}
    for s in shagi:
        imja = str(s.get("name") or "")
        for prefiks in (Z_SHAG_START, Z_SHAG_SBOR, Z_SHAG_ART):
            if imja.startswith(prefiks):
                po_imeni[prefiks] = s
    if Z_SHAG_START not in po_imeni or Z_SHAG_SBOR not in po_imeni:
        return {"oshibka": "ZAMER_NET_OBERTKI: %s" % worker["job"]}

    koren = Path(tmp)
    ws = koren / "ws"
    (ws / "mobile" / "scripts").mkdir(parents=True, exist_ok=True)
    skript_src = Path(subjekt_root) / "mobile" / "scripts" / "zamer_obryva.sh"
    if not skript_src.is_file():
        return {"oshibka": "SUBJECT_ABSENT: net mobile/scripts/zamer_obryva.sh"}
    shutil.copy(skript_src, ws / "mobile" / "scripts" / "zamer_obryva.sh")
    os.chmod(ws / "mobile" / "scripts" / "zamer_obryva.sh", 0o700)

    bin_dir = koren / "bin"
    bin_dir.mkdir(exist_ok=True)
    _napishi(bin_dir / "sleep", SHIM_SLEEP)
    _napishi(bin_dir / "adb", SHIM_ADB)
    _napishi(bin_dir / "pgrep", SHIM_PGREP)
    nonce = "z150mir-%s" % uuid.uuid4().hex[:10]

    takty = koren / "takty.txt"
    takty.write_text("", encoding="utf-8")
    adb_log = koren / "adb-log.txt"
    adb_log.write_text("", encoding="utf-8")

    # cgroup-фикстура раннера (счётчики меняются к обрыву — дельта видна)
    cg = koren / "cg"
    cg.mkdir(exist_ok=True)
    (cg / "memory.current").write_text("10951614464\n", encoding="utf-8")
    (cg / "memory.events").write_text("low 0\nhigh 10077\nmax 0\noom 0\noom_kill 0\n",
                                      encoding="utf-8")
    (cg / "cpu.stat").write_text("nr_periods 852408\nnr_throttled 274509\n"
                                 "throttled_usec 133176107812\n", encoding="utf-8")
    (cg / "cpu.pressure").write_text("some avg10=2.31 delta=0.00 total 9050\n",
                                     encoding="utf-8")
    (cg / "memory.pressure").write_text("some avg10=1.02 delta=0.00 total 4110\n",
                                        encoding="utf-8")

    serial = "emulator-5571"
    for k, v in (po_imeni[Z_SHAG_START].get("env") or {}).items():
        if k == "ZAMER_SERIAL":
            serial = str(v)
    ns = worker.get("ns") or "mobile/maestro-out-proba"
    ns_dir = ws / ns
    ns_dir.mkdir(parents=True, exist_ok=True)

    opis = SCENARII[imja_scenarija]
    sc = dict(opis["sc"]) if opis.get("sc") is not None else sc_obryv()
    if dop_scenarij:
        sc.update(dop_scenarij)
    sc["sostojanija"] = sc["sostojanija"] if "sostojanija" in sc else sc_obryv()["sostojanija"]

    # содержимое ns по сценарию
    rod_ns = imja_scenarija
    if rod_ns == "zelenyj":
        (ns_dir / "junit.xml").write_text(
            '<?xml version="1.0"?><testsuites><testsuite name="m"><testcase name="ok"/>'
            "</testsuite></testsuites>\n", encoding="utf-8")
    elif rod_ns == "produkt":
        (ns_dir / "maestro.log").write_text(
            "Assertion is false: \"Ihre Vorgänge\" is visible\n", encoding="utf-8")
    elif rod_ns in ("obryv", "vosstanovlennyj"):
        (ns_dir / "junit.xml").write_text(
            '<?xml version="1.0"?><testsuites><testsuite name="m"><testcase name="x">'
            "</testcase></testsuite></testsuites>\n", encoding="utf-8")

    # журнал эмулятора в воркспейсе (хвост собирается) + приманка-decoy;
    # PEM-блок (BEGIN+тело+END) — многострочный секрет журнала (b07, блокер 5)
    emu_log = ws / ("emulator-ci%s.log" % worker.get("id", "proba"))
    emu_log.write_text(
        "emulator: boot completed\nemulator: warning cannnot unmap ptr\n"
        "emulator: ghp_AAAABBBBCCCCDDDDzzzz token v loge\n"
        "-----BEGIN RSA PRIVATE KEY-----\n"
        "SUPERSECRET_PRIVATE_KEY_BODY_150\n"
        "-----END RSA PRIVATE KEY-----\n", encoding="utf-8")
    if emu_dopol_strok:
        # вектор объёма: tail -n 200 считает СТРОКИ — тяжесть несут байты строк
        pad = "x" * max(0, emu_dopol_dlina - 24)
        with open(emu_log, "a", encoding="utf-8") as f:
            for i in range(emu_dopol_strok):
                f.write("emulator: bolshoj hvost %d %s\n" % (i, pad))
    decoj = None
    if opis.get("decoj"):
        decoj = ws / "emulator-staryj.log"
        decoj.write_text("staryj progon: device offline (ostavljaetsja namerno)\n",
                         encoding="utf-8")

    scen_fajl = koren / "adb-scenarij.json"
    scen_fajl.write_text(json.dumps(sc, ensure_ascii=False), encoding="utf-8")

    env = dict(os.environ)
    env.update({
        "PATH": str(bin_dir) + os.pathsep + "/usr/bin:/bin",
        "HOME": str(koren / "home"),
        "ZAMER_TAKTY": str(takty),
        "ZAMER_ADB_LOG": str(adb_log),
        "ZAMER_ADB_SCENARIJ": str(scen_fajl),
        "ZAMER_SERIAL": serial,
        "ZAMER_CGROUP_DIR": str(cg),
        "Z150_NONCE": nonce,
        "GITHUB_RUN_ID": "4242",
        "GITHUB_RUN_ATTEMPT": "1",
        "GITHUB_JOB": worker["job"],
        "RUNNER_NAME": "poddelka-runner-150",
    })
    (koren / "home").mkdir(exist_ok=True)

    vremja = Vremja(takty)
    port = serial.replace("emulator-", "")
    # гигиена мира (блокер 8): КАЖДЫЙ порождённый процесс регистрируется и
    # умерщвляется/дожидается в finally — включая перезапуски сценария
    # (recovered) и исключительные выходы; клетка b12 доказывает отсутствие
    # живых подделок нонса мира ПОСЛЕ replay
    porozhdennye = []

    def _novyj_proces(imea):
        p = _poddelnyj_proces(imea, koren)
        porozhdennye.append(p)
        return p

    qemu_imea = "qemu-system-x86_64 %s -port %s" % (nonce, port)
    adb_imea = "adb %s -L tcp:5037 fork-server server --reply-fd 4" % nonce
    tekushchie = {"qemu": _novyj_proces(qemu_imea), "adb": _novyj_proces(adb_imea)}
    qemu = tekushchie["qemu"]
    adb_srv = tekushchie["adb"]
    time.sleep(0.05)

    def strok_semplera():
        f = ws / (".zamer-%s" % _ekran_iz_shaga(po_imeni[Z_SHAG_START])) / "sampler.tsv"
        try:
            return len([l for l in f.read_text(encoding="utf-8").splitlines()
                        if l and not l.startswith("#")])
        except OSError:
            return 0

    def ekran():
        return _ekran_iz_shaga(po_imeni[Z_SHAG_START])

    sobytija = list(opis.get("sobytija") or sc_obryv()["sobytija"])
    markery = {"do_signatury": None, "do_ubijstva": None, "adresa": []}
    stop = threading.Event()
    konec = max(t for t, _ in sobytija) if sobytija else T_KONTSA

    def drajver():
        made = set()
        while not stop.is_set():
            t = vremja.tek()
            for tt, dejstvie in sobytija:
                if tt <= t and (tt, dejstvie) not in made:
                    made.add((tt, dejstvie))
                    # адрес события фиксируется ПОСЛЕ исполнения обработчика —
                    # ожидание «все события обработаны» в главном потоке честно
                    if dejstvie == "ubit_qemu":
                        _ubit(tekushchie["qemu"])
                        # реальный cleanup экранного шага оставляет запись о
                        # смерти в журнале — причина для emulator-exit (b04)
                        try:
                            with open(emu_log, "a", encoding="utf-8") as f:
                                f.write("qemu-system: process terminated by "
                                        "signal 9 (SIGKILL) — zapis ekrannogo shaga\n")
                        except OSError:
                            pass
                        # границу считаем ПОСЛЕ оседания: в полёте могла быть
                        # строка, ИЗМЕРЕННАЯ до SIGKILL, но записанная после —
                        # она обязана остаться ДО границы, иначе ложный
                        # PID_ZHIV_POSLE_SMERTI (детерминизм клетки b04)
                        time.sleep(0.4)
                        markery["do_ubijstva"] = strok_semplera()
                    elif dejstvie == "perezapust_qemu":
                        # 995 v2: owned-restart — НОВАЯ инкарнация эмулятора
                        # (новый PID, отслежен и убит в finally/b12)
                        _ubit(tekushchie["qemu"])
                        tekushchie["qemu"] = _novyj_proces(qemu_imea)
                    elif dejstvie == "signatura":
                        markery["do_signatury"] = strok_semplera()
                        try:
                            (ns_dir / "maestro.log").write_text(
                                "CommandFailed: Command failed (host:transport:%s): "
                                "device offline\nDeviceServerDiedException: Device server died\n"
                                % serial, encoding="utf-8")
                        except OSError:
                            pass
                    elif dejstvie == "wipe_ns_zelenym":
                        # RECOVERED 995/5 opublikovat(): ns финальной ЗЕЛЁНОЙ
                        # попытки (top-level junit/report) + СОХРАНЁННЫЙ архив
                        # диагностики упавшей 1-й (diagnostics/attempt-1) —
                        # сигнатура обрыва в ns зелёного recovered job ЕСТЬ,
                        # публиковать нельзя (гейт судит текущую попытку)
                        shutil.rmtree(ns_dir, ignore_errors=True)
                        (ns_dir / "diagnostics" / "attempt-1").mkdir(
                            parents=True, exist_ok=True)
                        (ns_dir / "diagnostics" / "attempt-1" / "maestro.log").write_text(
                            "CommandFailed: Command failed (host:transport:%s): "
                            "device offline\nDeviceServerDiedException: Device server died\n"
                            % serial, encoding="utf-8")
                        (ns_dir / "junit.xml").write_text(
                            '<?xml version="1.0"?><testsuites><testsuite name="m">'
                            '<testcase name="ok"/></testsuite></testsuites>\n',
                            encoding="utf-8")
                        (ns_dir / "report.xml").write_text(
                            '<?xml version="1.0"?><testsuites tests="1" failures="0">'
                            '<testsuite name="m"><testcase name="ok"/></testsuite>'
                            "</testsuites>\n", encoding="utf-8")
                    elif dejstvie == "smenit_adb_server":
                        _ubit(tekushchie["adb"])
                        tekushchie["adb"] = _novyj_proces(adb_imea)
                    markery["adresa"].append((tt, dejstvie))
            if t >= konec + 2:
                break
            time.sleep(0.02)
        stop.set()

    def _ekran_iz_shaga(shag):
        envs = shag.get("env") or {}
        return str(envs.get("ZAMER_EKRAN", "proba-obryv"))

    def _ubit(proc):
        try:
            proc.kill()
        except OSError:
            pass

    rc_start = rc_sbor = None
    out_start = out_sbor = ""
    err_start = err_sbor = ""
    zhiv_posle_sbora = False
    potok = threading.Thread(target=drajver, daemon=True)
    try:
        potok.start()
        telo_start = str(po_imeni[Z_SHAG_START].get("run") or "")
        env_start = dict(env)
        for k, v in (po_imeni[Z_SHAG_START].get("env") or {}).items():
            env_start[k] = str(v)
        rc_start, out_start, err_start = _zapusti(telo_start, ws, env_start)
        # ждём ОБРАБОТКИ всех событий сценария (не только виртуального
        # времени: ubit_qemu оседает 0.4 с, и sbor обязан стартовать ПОСЛЕ
        # него — иначе сигнатура/смерть опаздывают в ns/spool), но не дольше
        # REALMAJ_TIMAUT; виртуальный запас konec+6 страхует от спина
        granica = time.time() + REALMAJ_TIMAUT
        while time.time() < granica:
            if len(markery["adresa"]) >= len(sobytija) or not potok.is_alive():
                break
            if vremja.tek() >= konec + 6:
                break
            time.sleep(0.05)
        telo_sbor = str(po_imeni[Z_SHAG_SBOR].get("run") or "")
        env_sbor = dict(env)
        for k, v in (po_imeni[Z_SHAG_SBOR].get("env") or {}).items():
            env_sbor[k] = str(v)
        rc_sbor, out_sbor, err_sbor = _zapusti(telo_sbor, ws, env_sbor)
        try:
            _pid = int((ws / (".zamer-%s" % ekran()) / "pid").read_text().strip() or 0)
            os.kill(_pid, 0)
            zhiv_posle_sbora = True
        except (OSError, ValueError):
            zhiv_posle_sbora = False
    finally:
        # гигиена мира (блокер 8): остановить и ДОЖДАТЬСЯ каждый порождённый
        # PID — включая recovered-перезапуски и исключительные выходы
        stop.set()
        for proc in porozhdennye:
            _ubit(proc)
        for proc in porozhdennye:
            try:
                proc.wait(timeout=5)
            except Exception:
                try:
                    proc.kill()
                except OSError:
                    pass
        # сэмплер мог пережить sbor — убираем за собой
        try:
            pidf = ws / (".zamer-%s" % ekran()) / "pid"
            if pidf.is_file():
                pid = int(pidf.read_text().strip() or 0)
                if pid > 0:
                    try:
                        os.kill(pid, signal.SIGKILL)
                    except OSError:
                        pass
        except Exception:
            pass
    ekran_id = ekran()
    return {
        "rc_start": rc_start, "rc_sbor": rc_sbor,
        "out_start": out_start, "out_sbor": out_sbor,
        "err_start": err_start[-400:], "err_sbor": err_sbor[-400:],
        "out_dir": ws / ("mobile/zamer-out-%s" % ekran_id),
        "spool": ws / (".zamer-%s" % ekran_id),
        "ws": ws, "ns_dir": ns_dir, "emu_log": emu_log, "decoj": decoj,
        "takty": vremja.tek(), "adb_log": adb_log,
        "markery": markery, "konec": konec,
        "sempler_zhiv_posle_sbora": zhiv_posle_sbora,
        "qemu_pid": qemu.pid, "serial": serial, "ekran": ekran_id,
        "nonce": nonce,
        "oshibka": None,
    }


# ── структурные клетки (z*) ────────────────────────────────────────────────
def port_rabotnika(shagi, subjekt_root):
    for s in shagi:
        run = str(s.get("run") or "")
        m = re.search(r"(?m)^\s*PORT=([0-9]+)\s*$", run)
        if m:
            return m.group(1)
    s_skript = Path(subjekt_root) / "mobile" / "scripts" / "ci-e2e.sh"
    if s_skript.is_file():
        m = re.search(r"(?m)^PORT=([0-9]+)\s*$", s_skript.read_text(encoding="utf-8"))
        if m:
            return m.group(1)
    return None


def sud_z01(wf, rabotniki):
    """z01-obertka-polnota: у КАЖДОГО работника карты есть все три шага замера."""
    netu = []
    for r in rabotniki:
        job = (wf.get("jobs") or {}).get(r["job"]) or {}
        imena = [str(s.get("name") or "") for s in (job.get("steps") or [])]
        for prefiks in (Z_SHAG_START, Z_SHAG_SBOR, Z_SHAG_ART):
            if not any(i.startswith(prefiks) for i in imena):
                netu.append("%s bez shaga %r" % (r["job"], prefiks))
    return (not netu, "; ".join(netu))


def sud_z02(wf, rabotniki, subjekt_root):
    """z02-obertka-parametry: env шагов согласован с картой и портом тела."""
    netu = []
    for r in rabotniki:
        job = (wf.get("jobs") or {}).get(r["job"]) or {}
        shagi = job.get("steps") or []
        port = port_rabotnika(shagi, subjekt_root)
        for s in shagi:
            imja = str(s.get("name") or "")
            envs = {k: str(v) for k, v in (s.get("env") or {}).items()}
            if imja.startswith(Z_SHAG_START) or imja.startswith(Z_SHAG_SBOR):
                if envs.get("ZAMER_EKRAN") != r["id"]:
                    netu.append("%s: ZAMER_EKRAN %r != karte %r"
                                % (r["job"], envs.get("ZAMER_EKRAN"), r["id"]))
                if envs.get("ZAMER_NS") != r["ns"]:
                    netu.append("%s: ZAMER_NS %r != karte %r"
                                % (r["job"], envs.get("ZAMER_NS"), r["ns"]))
                zhel_serial = "emulator-%s" % port if port else None
                if not zhel_serial or envs.get("ZAMER_SERIAL") != zhel_serial:
                    netu.append("%s: ZAMER_SERIAL %r != emulator-PORT(%s)"
                                % (r["job"], envs.get("ZAMER_SERIAL"), port))
    return (not netu, "; ".join(netu))


def sud_z03(wf, rabotniki):
    """z03-obertka-porjadok-maskirovka: порядок вокруг экраного шага, запрет
    continue-on-error у ВСЕХ шагов работника, старт без if:always(),
    сбор/артефакт if:always(), upload ignore."""
    netu = []
    for r in rabotniki:
        job = (wf.get("jobs") or {}).get(r["job"]) or {}
        shagi = job.get("steps") or []
        for s in shagi:
            if s.get(ZAPRET_MASKIROVKI):
                netu.append("%s: shag %r neset continue-on-error (maskirovka itoga)"
                            % (r["job"], str(s.get("name"))[:40]))
        idx = {}
        for i, s in enumerate(shagi):
            imja = str(s.get("name") or "")
            for prefiks in (Z_SHAG_START, Z_SHAG_SBOR, Z_SHAG_ART):
                if imja.startswith(prefiks) and prefiks not in idx:
                    idx[prefiks] = i
        if Z_SHAG_START in idx and Z_SHAG_SBOR in idx and idx[Z_SHAG_START] >= idx[Z_SHAG_SBOR]:
            netu.append("%s: start позже sbor (замер после экранного шага?)" % r["job"])
        # между стартом и сбором обязан быть экранный шаг (PORT=/maestro/ekran_shablon/ci-e2e)
        mezhdu = shagi[idx.get(Z_SHAG_START, 0) + 1: idx.get(Z_SHAG_SBOR, len(shagi))]
        est_ekran = any(any(m in str(s.get("run") or "") for m in EKRANNYE_MARKERY)
                        for s in mezhdu)
        if not est_ekran:
            netu.append("%s: mezhdu startom i sborom net ekrannogo shaga" % r["job"])
        st = shagi[idx[Z_SHAG_START]] if Z_SHAG_START in idx else None
        if st is not None and "always()" in str(st.get("if") or ""):
            netu.append("%s: start несёт if:always() — сэмплер после экранного шага" % r["job"])
        sb = shagi[idx[Z_SHAG_SBOR]] if Z_SHAG_SBOR in idx else None
        if sb is not None and "always()" not in str(sb.get("if") or ""):
            netu.append("%s: sbor без if:always() — красный потеряет сбор" % r["job"])
        ar = shagi[idx[Z_SHAG_ART]] if Z_SHAG_ART in idx else None
        if ar is not None:
            if "always()" not in str(ar.get("if") or ""):
                netu.append("%s: артефакт-шаг без if:always()" % r["job"])
            if not str(ar.get("uses") or "").startswith("actions/upload-artifact"):
                netu.append("%s: артефакт-шаг не upload-artifact" % r["job"])
            withs = {k: str(v) for k, v in (ar.get("with") or {}).items()}
            if withs.get("if-no-files-found") != "ignore":
                netu.append("%s: артефакт if-no-files-found != ignore (зелёный краснеет)" % r["job"])
    return (not netu, "; ".join(netu))


def sud_z04(subjekt_root, src):
    """z04-kanon-skripta: скрипт субъекта байт-в-байт канону (пин)."""
    p = Path(subjekt_root) / "mobile" / "scripts" / "zamer_obryva.sh"
    if not p.is_file():
        return False, "ZAMER_SKRIPT_NET: mobile/scripts/zamer_obryva.sh"
    digest = hashlib.sha256(p.read_bytes()).hexdigest()
    zhel = (src.get("piny") or {}).get("model/mobile/scripts/zamer_obryva.sh")
    if digest != zhel:
        return False, "ZAMER_SKRIPT_NE_KANON: sha %s" % digest[:12]
    return True, ""

def sud_z05(wf, rabotniki):
    """z05-put-zagruzki: путь/имя upload согласованы с выходом сбора ПО
    КАЖДОМУ работнику карты (with.path == mobile/zamer-out-<ZAMER_EKRAN>;
    name начинается zamer-<ekran>-; sbor пишет --out mobile/zamer-out-…).
    Иначе зелёный CI-шаг «артефакт» молча грузит пустоту (if-no-files-found:
    ignore) — публикация недоказуема (блокер 6 круга 1)."""
    netu = []
    for r in rabotniki:
        job = (wf.get("jobs") or {}).get(r["job"]) or {}
        shagi = job.get("steps") or []
        sbor = art = None
        for s in shagi:
            imja = str(s.get("name") or "")
            if imja.startswith(Z_SHAG_SBOR) and sbor is None:
                sbor = s
            if imja.startswith(Z_SHAG_ART) and art is None:
                art = s
        if sbor is None or art is None:
            netu.append("%s: net shagov sbor/artefakt (sm. z01)" % r["job"])
            continue
        envs = {k: str(v) for k, v in (sbor.get("env") or {}).items()}
        ekr = envs.get("ZAMER_EKRAN")
        if not ekr:
            netu.append("%s: sbor bez ZAMER_EKRAN (z02)" % r["job"])
            continue
        zhel_path = "mobile/zamer-out-%s" % ekr
        withs = {k: str(v) for k, v in (art.get("with") or {}).items()}
        if withs.get("path") != zhel_path:
            netu.append("%s: PUT_ZAGRUZKI_RASHODITSJA: with.path %r != vyhodu sbora %r"
                        % (r["job"], withs.get("path"), zhel_path))
        run_sbor = str(sbor.get("run") or "")
        if "mobile/zamer-out-$ZAMER_EKRAN" not in run_sbor:
            netu.append("%s: sbor bez --out mobile/zamer-out-$ZAMER_EKRAN" % r["job"])
        imja_art = withs.get("name") or ""
        if not imja_art.startswith("zamer-%s-" % ekr):
            netu.append("%s: IMJA_ARTEFAKTA_NE_EKRAN: %r ne zamer-%s-…"
                        % (r["job"], imja_art[:40], ekr))
    return (not netu, "; ".join(netu))


# ── поведенческие клетки (b*) по результатам replay ────────────────────────
def _chitaj(p):
    try:
        return Path(p).read_text(encoding="utf-8", errors="replace")
    except OSError:
        return None


def _sempler_stroki(rez):
    tekst = _chitaj(Path(rez["spool"]) / "sampler.tsv") or ""
    return [l for l in tekst.splitlines() if l and not l.startswith("#")]


def sud_b01(rez):
    """b01-krasnyj-s-signaturoj: красный с сигнатурой публикует артефакт."""
    if rez.get("oshibka"):
        return False, rez["oshibka"]
    if rez["rc_sbor"] != 0:
        return False, "sbor rc=%s (итог job не должен меняться)" % rez["rc_sbor"]
    itog = _chitaj(Path(rez["out_dir"]) / "itog.txt")
    if not itog or "reshenie=publikuem" not in itog:
        return False, "ARTEFAKT_NET: sbor rc 0, но itog/артефакта нет"
    sig = _chitaj(Path(rez["out_dir"]) / "signatury.txt")
    if not sig or "maestro.log" not in sig:
        return False, "SIGNATURY_BEZ_ADRESA: в artefakte нет file:line сигнатуры"
    return True, ""


def sud_b02(rez_zelenyj):
    """b02-zelenyj-tishina: зелёный не публикует и не падает."""
    if rez_zelenyj.get("oshibka"):
        return False, rez_zelenyj["oshibka"]
    if rez_zelenyj["rc_sbor"] != 0:
        return False, "ZELENYJ_KRASN: sbor rc=%s" % rez_zelenyj["rc_sbor"]
    if rez_zelenyj["out_dir"].exists() and any(rez_zelenyj["out_dir"].iterdir()):
        return False, "ZELENYJ_PUBLIKUET: артефакт на зелёном"
    if "ne publikuetsja" not in (rez_zelenyj["out_sbor"] or ""):
        return False, "TISHINA_BEZ_MARKERA: нет маркера «не публикуется»"
    return True, ""


def sud_b03(rez_produkt):
    """b03-produktovyj-krasnyj: продуктовый красный без обрыва молчит
    (гейт только ns работника; decoy-сигнатура вне ns не соблазняет)."""
    if rez_produkt.get("oshibka"):
        return False, rez_produkt["oshibka"]
    if not (rez_produkt.get("decoj") and rez_produkt["decoj"].is_file()):
        return False, "DECOJ_NET: фикстура-приманка не на месте (дефект батареи)"
    if rez_produkt["rc_sbor"] != 0:
        return False, "PRODUKTOVYJ_KRASN: sbor rc=%s" % rez_produkt["rc_sbor"]
    if rez_produkt["out_dir"].exists() and any(rez_produkt["out_dir"].iterdir()):
        return False, "LOZHNAYA_PUBLIKAJIJA: артефакт без обрыва в ns (grep шире ns?)"
    return True, ""


def sud_b04(rez):
    """b04-dannye-do-ostanovki: PID живого эмулятора записан РАНЬДЕ маркера
    обрыва; после смерти PID исчезает из таймлайна; завершение эмулятора
    (exit/статус в достижимой части — решение владельца 26.10 п.2)
    зафиксировано сэмплером ДО сбора: смерть PID + ом-дельта cgroup +
    причина из журнала + честный маркер недоступности числового кода."""
    if rez.get("oshibka"):
        return False, rez["oshibka"]
    stroki = _sempler_stroki(rez)
    if not stroki:
        return False, "TAJMLAJN_NET: sampler.tsv без строк (замер после остановки?)"
    qpid = str(rez["qemu_pid"])
    mark = rez["markery"]
    if mark.get("do_signatury") is None:
        return False, "MARKER_NET: сценарий не записал границу сигнатуры"
    do_sig = mark["do_signatury"]
    videl_zhivym = any(qpid in l.split("|")[1].strip(",").split(",")
                       for l in stroki[:max(do_sig, 1)])
    if not videl_zhivym:
        return False, "IZMERENO_POSLE_OTSTANOVKI: PID эмулятора не наблюдается ДО сигнатуры"
    do_ub = mark.get("do_ubijstva")
    if do_ub is not None:
        posle = [l for l in stroki[do_ub:]
                 if qpid in l.split("|")[1].strip(",").split(",")]
        if posle:
            return False, "PID_ZHIV_POSLE_SMERTI: таймлайн лжёт о живости"
    # завершение эмулятора: фиксация сэмплером (блокер 3 круга 1)
    exitf = _chitaj(Path(rez["out_dir"]) / "emulator-exit.txt") or ""
    if not exitf:
        return False, "EXIT_NET: смерть эмулятора не зафиксирована (emulator-exit.txt)"
    if ("qemu PID %s " % qpid) not in exitf:
        return False, "EXIT_BEZ_PIDA: фиксация смерти не называет упавший PID"
    if "oom_kill_do=" not in exitf:
        return False, "EXIT_BEZ_OM_DELTY: нет дельты oom_kill cgroup"
    if "signal 9" not in exitf:
        return False, "EXIT_BEZ_PRICHINY: маркер журнала смерти не прочитан"
    if "vyhod_status" not in exitf:
        return False, "EXIT_SKRYVAET: нет честного маркера недоступности числового кода"
    return True, ""


def sud_b05(rez):
    """b05-cgroup-poly: каждая строка несёт cgroup/psi-поля (колонки на месте)."""
    if rez.get("oshibka"):
        return False, rez["oshibka"]
    golova = _chitaj(Path(rez["spool"]) / "sampler.tsv") or ""
    stroki = _sempler_stroki(rez)
    if not stroki:
        return False, "TAJMLAJN_NET"
    for imja in ("cg_mem_current", "cg_ev_high", "cg_ev_max", "cg_ev_oom",
                 "cg_cpu_throttled_nr", "cg_cpu_throttled_us",
                 "psi_cpu_avg10", "psi_mem_avg10"):
        if imja not in golova:
            return False, "CGROUP_POTERJAN: нет колонки %s" % imja
    for l in stroki:
        polja = l.split("|")
        if len(polja) != 16:
            return False, "CGROUP_POTERJAN: строка из %d полей (канон 16)" % len(polja)
        for i in (7, 8, 9, 10, 11, 12, 13, 14):
            if polja[i] in ("",):
                return False, "CGROUP_POTERJAN: пустое поле %d" % (i + 1)
            if i in (7, 8, 11, 12) and polja[i] == "-":
                return False, "CGROUP_POTERJAN: cgroup-значение '-' (фикстура даёт данные)"
    return True, ""


def sud_b06(rez):
    """b06-adb-server-i-device: PID adb-server на старте и сборе, смена
    помечена; boot_id/adbd из живых проб гостя есть в таймлайне;
    предостановочный logcat-кольцо (-t, по живому транспорту ДО смерти)
    записано сэмплером в артефакт (блокер 3 круга 1)."""
    if rez.get("oshibka"):
        return False, rez["oshibka"]
    snimok = _chitaj(Path(rez["out_dir"]) / "sistemnyj-snimok.txt") or ""
    adb_txt = _chitaj(Path(rez["out_dir"]) / "adb-server-i-ustrojstva.txt") or ""
    if "adb_server_start=" not in snimok:
        return False, "NET_START_PIDA adb-server в системном снимке"
    if "adb_server_sbor=" not in adb_txt:
        return False, "NET_SBOR_PIDA adb-server на сборе"
    if "ADB_SERVER_SMENILSJA" not in adb_txt:
        return False, "SMENA_ADB_SERVER_NE_POMECHENA (сценарий сменил сервер)"
    if "adb_devices_sejchas" not in adb_txt:
        return False, "NET_ADB_DEVICES на сборе"
    stroki = _sempler_stroki(rez)
    if not any(l.split("|")[4] == "b0b0-1111-2222-3333-444444444444" for l in stroki):
        return False, "NET_BOOT_ID: живые пробы гостя не попали в таймлайн"
    if not any(l.split("|")[5] == "4242" for l in stroki):
        return False, "NET_ADBD_PID в таймлайне"
    kolco = _chitaj(Path(rez["out_dir"]) / "logcat-kolco.txt") or ""
    if "logcat -d -t 50" not in kolco:
        return False, "KOLCO_NET: предостановочного logcat-кольца нет (или без -t)"
    if "E/adbd(2): transport error" not in kolco:
        return False, "KOLCO_PUSTOE: кольцо не несёт содержимого ДО обрыва"
    return True, ""


SEKRET_RE = re.compile(r"ghp_[A-Za-z0-9]{16}|AKIA[0-9A-Z]{16}|Bearer [A-Za-z0-9]{16}")
# PEM-блок обязан вычищаться ЦЕЛИКОМ: тело и концевая строка — тоже секрет
# (блокер 5 круга 1: замена одной строки BEGIN пропускала тело ключа)
PEM_UTECHKA_RE = re.compile(r"PRIVATE KEY-----|SUPERSECRET_PRIVATE_KEY_BODY_150")


def sud_b07(rez):
    """b07-sekrety-redakcija: секреты из журналов/логката не протекают —
    сканируется ВСЁ опубликованное дерево, включая тело и END многострочного
    PEM-ключа; маркеры редакции на месте."""
    if rez.get("oshibka"):
        return False, rez["oshibka"]
    utechki = []
    for p in sorted(Path(rez["out_dir"]).rglob("*")):
        if not p.is_file():
            continue
        tekst = _chitaj(p) or ""
        for m in SEKRET_RE.finditer(tekst):
            utechki.append("%s:%s" % (p.name, m.group(0)[:14]))
        for m in PEM_UTECHKA_RE.finditer(tekst):
            utechki.append("%s:PEM:%s" % (p.name, m.group(0)[:28]))
    if utechki:
        return False, "SEKRET_UTEK: %s" % utechki[:3]
    hvost = _chitaj(Path(rez["out_dir"]) / "emulator-log-hvost.txt") or ""
    kolco = _chitaj(Path(rez["out_dir"]) / "logcat-kolco.txt") or ""
    if "REDACTED" not in hvost:
        return False, "NET_REDAKTSII: маркер REDACTED не встречен в хвосте"
    if "REDACTED:key" not in (hvost + kolco):
        return False, "NET_REDAKTSII_PEM: PEM-блок не помечен редакцией"
    return True, ""


def sud_b08(rez_obem):
    """b08-obem-ogranichen: каждый файл и весь артефакт в пределах — ТОЧНОЕ
    сравнение (маркер обрезки входит в потолок; блокер 7 круга 1: допуск
    +128/+2048 пропускал нарушение самого канона: 524288 + маркер = 524321)."""
    if rez_obem.get("oshibka"):
        return False, rez_obem["oshibka"]
    if not rez_obem["out_dir"].is_dir():
        return False, "ARTEFAKT_NET (сценарий объёма требует публикации)"
    for p in rez_obem["out_dir"].rglob("*"):
        if not p.is_file():
            continue
        razmer = p.stat().st_size
        if razmer > FAJL_MAKS_BAJT:
            return False, "FAIL_BEZ_PREDLA: %s %d байт (потолок %d)" % (
                p.name, razmer, FAJL_MAKS_BAJT)
    total = sum(p.stat().st_size for p in rez_obem["out_dir"].rglob("*")
                if p.is_file())
    if total > ARTEFAKT_MAKS_BAJT:
        return False, "ARTEFAKT_BEZ_PREDLA: %d байт (потолок %d)" % (
            total, ARTEFAKT_MAKS_BAJT)
    return True, ""


def sud_b09(rez, subjekt_root):
    """b09-sampler-legkij: <=1 Гц (тики виртуального времени), <=1 пробы гостя
    в 15 с, никаких bugreport/dumpsys, logcat только ограниченным -t."""
    if rez.get("oshibka"):
        return False, rez["oshibka"]
    virt = rez["konec"]
    if rez["takty"] > virt + 15:
        return False, "SAMPLER_TJAZELOVAT: %.0f тиков за %d виртуальных с (>1 Гц)" % (
            rez["takty"], virt)
    log = _chitaj(rez["adb_log"]) or ""
    zaprosy = [l.split(" ", 2)[-1] for l in log.splitlines() if l.startswith("ADB ")]
    devices = sum(1 for z in zaprosy if z.startswith("devices"))
    shell = sum(1 for z in zaprosy if z.startswith("shell"))
    if devices > virt + 5:
        return False, "SAMPLER_TJAZELOVAT: %d опросов devices за %d с" % (devices, virt)
    if shell > virt / 15 + 3:
        return False, "SAMPLER_TJAZELOVAT: %d проб гостя за %d с (норма <=1/15с)" % (shell, virt)
    logcat_n = sum(1 for z in zaprosy if z.startswith("logcat"))
    if logcat_n > virt / 15 + 3:
        return False, "SAMPLER_TJAZELOVAT: %d logcat-чтений за %d с (норма <=1/15с)" % (
            logcat_n, virt)
    skript_polnyj = _chitaj(Path(subjekt_root) / "mobile" / "scripts" / "zamer_obryva.sh") or ""
    skript = "\n".join(l for l in skript_polnyj.splitlines() if not l.lstrip().startswith("#"))
    for zapret in ("bugreport", "dumpsys"):
        if zapret in skript:
            return False, "SAMPLER_TJAZELOVAT: %s в каноне" % zapret
    for m in re.finditer(r"adb\s+(-s\s+\S+\s+)?logcat(?![^\n]*\s-t\s)", skript):
        return False, "LOGCAT_BEZ_T: неограниченный logcat в каноне"
    return True, ""


def sud_b10(rez):
    """b10-sampler-ostanovlen: после сбора процесса сэмплера нет
    (живость зафиксирована сразу после sbor — до зачистки песочницы)."""
    if rez.get("oshibka"):
        return False, rez["oshibka"]
    pidf = Path(rez["spool"]) / "pid"
    if not pidf.is_file():
        return False, "PIDFILE_NET: сэмплер не зарегистрирован"
    try:
        pid = int(pidf.read_text().strip() or 0)
    except ValueError:
        return False, "PIDFILE_MUSOR"
    if pid <= 0:
        return False, "PIDFILE_PUST"
    if rez.get("sempler_zhiv_posle_sbora"):
        return False, "SEMPLER_ZHIV: процесс %d пережил сбор" % pid
    return True, ""


def sud_b11(rez_vosst):
    """b11-vosstanovlennyj-zelenyj: итог зелёный — артефакт не публикуется.
    Модель мира: frozen 995/5 RECOVERED — ns финальной зелёной попытки
    СОХРАНЯЕТ архив диагностики упавшей 1-й (diagnostics/attempt-1 с
    сигнатурой обрыва); гейт обязан судить ТЕКУЩУЮ попытку, не весь ns
    (блокер 4 круга 1)."""
    if rez_vosst.get("oshibka"):
        return False, rez_vosst["oshibka"]
    if not (rez_vosst["ns_dir"] / "diagnostics" / "attempt-1" / "maestro.log").is_file():
        return False, "RECOVERED_NET: фикстура не несёт архив 995 (дефект батареи)"
    if rez_vosst["rc_sbor"] != 0:
        return False, "VOSST_KRASN: sbor rc=%s" % rez_vosst["rc_sbor"]
    if rez_vosst["out_dir"].exists() and any(rez_vosst["out_dir"].iterdir()):
        return False, "VOSST_PUBLIKUET: зелёный итог после восстановления публикует"
    return True, ""


def sud_b12(noncy):
    """b12-mir-poddelki-umerly: после всех replay НЕТ живых процессов-подделок
    своего мира (нонсы миров): каждый порождённый PID остановлен и дождан.
    Гигиена самоисполняемой батареи (блокер 8 круга 1: recovered-подделка
    пережидала replay и удаление песочницы). Найденных — зачистить на месте."""
    zhivye = []
    for d in os.listdir("/proc"):
        if not d.isdigit():
            continue
        try:
            with open("/proc/%s/cmdline" % d, "rb") as fh:
                cmd = fh.read().replace(b"\0", b" ").decode("utf-8", "replace")
        except OSError:
            continue
        for n in noncy:
            if n in cmd:
                zhivye.append(int(d))
                try:
                    os.kill(int(d), signal.SIGKILL)
                except OSError:
                    pass
                break
    if zhivye:
        return False, "PODDELKI_ZHIVY: pids %s пережили мир" % zhivye[:6]
    return True, ""


# ── главная ────────────────────────────────────────────────────────────────
KLETKI = ["z01-obertka-polnota", "z02-obertka-parametry", "z03-obertka-porjadok-maskirovka",
          "z04-kanon-skripta", "z05-put-zagruzki",
          "b01-krasnyj-s-signaturoj", "b02-zelenyj-tishina", "b03-produktovyj-krasnyj",
          "b04-dannye-do-ostanovki", "b05-cgroup-poly", "b06-adb-server-i-device",
          "b07-sekrety-redakcija", "b08-obem-ogranichen", "b09-sampler-legkij",
          "b10-sampler-ostanovlen", "b11-vosstanovlennyj-zelenyj",
          "b12-mir-poddelki-umerly"]


def sud_subiekta(subjekt_root, src, tmp_koren, porjadok=None):
    """(kletki_krasnye dict, itog_rc). Суд субъекта по всем клеткам."""
    krasnye = {}
    wf = wf_subiekta(subjekt_root)
    try:
        rabotniki = rabotniki_iz_karty(karta_subiekta(subjekt_root))
    except KartaNet as e:
        rabotniki = []
        krasnye["z01-obertka-polnota"] = "SUBJECT_ABSENT: %s" % e
    if not rabotniki and "z01-obertka-polnota" not in krasnye:
        krasnye["z01-obertka-polnota"] = "KARTA_PUSTA: нет работников"

    def zap(modul_imja, fn, *a, **kw):
        if modul_imja in krasnye:
            return
        try:
            ok, prichina = fn(*a, **kw)
        except Exception as e:  # дефект батареи не молчит
            ok, prichina = False, "BATAREJA_OTKAZ: %r" % e
        if not ok:
            krasnye[modul_imja] = prichina or "krasno"

    poredok = list(porjadok or KLETKI)
    for imja in poredok:
        if imja == "z01-obertka-polnota":
            zap(imja, sud_z01, wf, rabotniki) if wf else krasnye.setdefault(
                imja, "SUBJECT_ABSENT: net .github/workflows/mobile.yml")
        elif imja == "z02-obertka-parametry":
            zap(imja, sud_z02, wf, rabotniki, subjekt_root) if wf else krasnye.setdefault(
                imja, "SUBJECT_ABSENT: net workflow")
        elif imja == "z03-obertka-porjadok-maskirovka":
            zap(imja, sud_z03, wf, rabotniki) if wf else krasnye.setdefault(
                imja, "SUBJECT_ABSENT: net workflow")
        elif imja == "z04-kanon-skripta":
            zap(imja, sud_z04, subjekt_root, src)
        elif imja == "z05-put-zagruzki":
            zap(imja, sud_z05, wf, rabotniki) if wf else krasnye.setdefault(
                imja, "SUBJECT_ABSENT: net workflow")
    # поведенческие: replay первого работника карты; каталоги живут ДО КОНЦА
    # суда (правило: проверки читают файлы мира ПОСЛЕ replay — раньше контекст
    # удалял ws между replay и клетками, и все файловые клетки слепли)
    rez = {}
    vremennye = []
    if rabotniki and wf:
        worker0 = rabotniki[0]
        def _mir(imja):
            d = Path(tempfile.mkdtemp(prefix="z150-%s-" % imja, dir=str(tmp_koren)))
            vremennye.append(d)
            return d
        tmp = _mir("obryv")
        rez["obryv"] = replej(subjekt_root, worker0, "obryv", tmp)
        tmp = _mir("zelenyj")
        rez["zelenyj"] = replej(subjekt_root, worker0, "zelenyj", tmp)
        tmp = _mir("produkt")
        rez["produkt"] = replej(subjekt_root, worker0, "produkt", tmp)
        tmp = _mir("vosstanovlennyj")
        rez["vosstanovlennyj"] = replej(subjekt_root, worker0, "vosstanovlennyj", tmp)
        tmp = _mir("obem")
        # объём: огромный logcat-файл сценария + длинный emulator-лог
        (tmp / "ws").mkdir(parents=True, exist_ok=True)
        bolshoj = tmp / "ws" / "bolshoj-logcat.txt"
        bolshoj.write_text("I/x: stroka\n" * 120000, encoding="utf-8")
        rez["obryv_obem"] = replej(
            subjekt_root, worker0, "obryv", tmp,
            dop_scenarij={"logcat_fajl": str(bolshoj)},
            emu_dopol_strok=300, emu_dopol_dlina=12288)
    else:
        for imja in KLETKI:
            if imja.startswith("b"):
                krasnye.setdefault(imja, "SUBJECT_ABSENT: нет субъекта для replay")
    # нонсы всех миров — гигиена b12 (после всех replay живых подделок нет)
    rez["_noncy"] = [r["nonce"] for r in rez.values()
                     if isinstance(r, dict) and r.get("nonce")]

    try:
        return _sud_povedencheskie(krasnye, rez, subjekt_root, poredok, zap)
    finally:
        for d in vremennye:
            shutil.rmtree(d, ignore_errors=True)


def _sud_povedencheskie(krasnye, rez, subjekt_root, poredok, zap):
    pary = [("b01-krasnyj-s-signaturoj", sud_b01, "obryv"),
            ("b02-zelenyj-tishina", sud_b02, "zelenyj"),
            ("b03-produktovyj-krasnyj", sud_b03, "produkt"),
            ("b04-dannye-do-ostanovki", sud_b04, "obryv"),
            ("b05-cgroup-poly", sud_b05, "obryv"),
            ("b06-adb-server-i-device", sud_b06, "obryv"),
            ("b07-sekrety-redakcija", sud_b07, "obryv"),
            ("b08-obem-ogranichen", sud_b08, "obryv_obem"),
            ("b09-sampler-legkij", sud_b09, "obryv"),
            ("b10-sampler-ostanovlen", sud_b10, "obryv"),
            ("b11-vosstanovlennyj-zelenyj", sud_b11, "vosstanovlennyj"),
            ("b12-mir-poddelki-umerly", sud_b12, "_noncy")]
    for imja in poredok:
        for kletka, fn, kluch in pary:
            if imja == kletka:
                r = rez.get(kluch)
                if r is None:
                    krasnye.setdefault(kletka, "REPLAY_NET: %s" % kluch)
                elif kletka == "b09-sampler-legkij":
                    zap(kletka, fn, r, subjekt_root)
                else:
                    zap(kletka, fn, r)
    return krasnye


def glavnaja():
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--model", action="store_true")
    ap.add_argument("--stabs", action="store_true")
    ap.add_argument("--oracle-tamper", action="store_true")
    ap.add_argument("--repo")
    ap.add_argument("--seed", type=int)
    a = ap.parse_args()

    try:
        import yaml  # noqa: F401
    except ImportError:
        print("NOT_IMPLEMENTED: net pyyaml", file=sys.stderr)
        return 2
    try:
        src = json.loads(SOURCE.read_text(encoding="utf-8"))
    except OSError as e:
        print("ORACLE_TAMPERED: source.json %s" % e, file=sys.stderr)
        return 2
    try:
        zhestkij_kanon(src)
    except OshibkaOrakula as e:
        print("ORACLE_TAMPERED: %s" % e, file=sys.stderr)
        return 2

    vrem_koren = Path(tempfile.mkdtemp(prefix="z150-glavnaja-"))
    rc = 0
    try:
        if a.oracle_tamper:
            # порча каждого пиннованного носителя в КОПИИ модели → оракул обязан отказать
            provereno = 0
            for otn in (src.get("piny") or {}):
                with tempfile.TemporaryDirectory(prefix="z150-tamper-", dir=str(vrem_koren)) as tmp:
                    kopija = Path(tmp) / "model"
                    shutil.copytree(MODEL, kopija)
                    p = kopija / Path(otn).relative_to("model")
                    b = bytearray(p.read_bytes())
                    b[len(b) // 2] ^= 0x20
                    p.write_bytes(bytes(b))
                    try:
                        zhestkij_kanon_modelja(kopija, src)
                    except OshibkaOrakula:
                        provereno += 1
                    else:
                        print("ORACLE_TAMPER_PROVAL: порча %s не поймана" % otn, file=sys.stderr)
                        return 1
            print("ORACLE_TAMPER_PROVERENO nositelej=%d" % provereno)
            return 0

        subjekt = MODEL if (a.model or a.stabs) else (Path(a.repo) if a.repo else HERE.parents[2])
        porjadok = list(KLETKI)
        if a.seed:
            import random
            random.Random(a.seed).shuffle(porjadok)
        if a.stabs:
            krasnye = sud_subiekta(MODEL, src, vrem_koren, porjadok)
            if krasnye:
                print("KONTROL_KRASN: модель не проходит собственный суд:", file=sys.stderr)
                for k, v in sorted(krasnye.items()):
                    print("  %s: %s" % (k, v), file=sys.stderr)
                return 1
            zhivye = 0
            svjazi = 0
            for otn, kletka in sorted((src.get("stab_vhod") or {}).items()):
                svjazi += 1
                with tempfile.TemporaryDirectory(prefix="z150-stab-", dir=str(vrem_koren)) as tmp:
                    mir = Path(tmp) / "mir"
                    shutil.copytree(MODEL, mir)
                    spec = importlib.util.spec_from_file_location("stab", HERE / otn)
                    mod = importlib.util.module_from_spec(spec)
                    spec.loader.exec_module(mod)
                    try:
                        mod.mutiruj(mir)
                    except Exception as e:
                        print("STAB %s SL OMAL: %r" % (otn, e), file=sys.stderr)
                        return 1
                    kr = sud_subiekta(mir, src, vrem_koren, porjadok)
                if kletka in kr:
                    print("STAB %s → %s KRASEN (%s)" % (Path(otn).name, kletka, kr[kletka][:60]))
                else:
                    zhivye += 1
                    print("STAB_ZHIV %s: клетка %s зелёна на обманной реализации" % (otn, kletka),
                          file=sys.stderr)
            print("SVJAZI %d" % svjazi)
            if zhivye:
                print("STAB_ZHIV: %d" % zhivye, file=sys.stderr)
                return 1
            return 0

        krasnye = sud_subiekta(subjekt, src, vrem_koren, porjadok)
        if krasnye:
            print("KRASNO: клеток %d, красных %d" % (len(KLETKI), len(krasnye)), file=sys.stderr)
            for k in KLETKI:
                if k in krasnye:
                    print("  %s: %s" % (k, krasnye[k]), file=sys.stderr)
            if not a.repo:
                print("SUBJECT_ABSENT: субъект не реализован (продукт без обёртки 150)",
                      file=sys.stderr)
            return 1
        print("ZELENO: клеток %d, зелёных %d" % (len(KLETKI), len(KLETKI)))
        return 0
    finally:
        shutil.rmtree(vrem_koren, ignore_errors=True)


def zhestkij_kanon_modelja(koren_modeli, src):
    """Проверка пинов ОТНОСИТЕЛЬНО копии модели (для --oracle-tamper)."""
    for otn, digest in (src.get("piny") or {}).items():
        p = koren_modeli / Path(otn).relative_to("model")
        fakt = hashlib.sha256(p.read_bytes()).hexdigest()
        if fakt != digest:
            raise OshibkaOrakula("носитель %s sha %s != пин" % (otn, fakt[:12]))


if __name__ == "__main__":
    try:
        sys.exit(glavnaja())
    except KeyboardInterrupt:
        sys.exit(130)
