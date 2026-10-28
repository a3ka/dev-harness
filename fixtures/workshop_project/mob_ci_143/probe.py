#!/usr/bin/env python3
# БАРЬЕР-ГУАРД контракта 143 (mob-ci-razdelenie): судит разделение CI mob по
# экранам — селектор (поведенческий replay подложными git/gh по ЖИВЫМ форматам
# GitHub API), fail-closed агрегат (replay needs-контекстов), статические
# инварианты DAG mobile.yml и карты экранов. Оракул — source.json в памяти ДО
# вызова субъекта (правило 8); ожидаемый selected-set строит НЕЗАВИСИМЫЙ
# доверенный канон этого файла (python), никогда не субъект-селектор (.cjs).
# Н-39: обманные стабы — мутации моделей КОДОМ (stabs/*.py), привязки —
# ТОЛЬКО source.json:.stab_vhod; рассинхрон множеств — rc 2 ORACLE_TAMPERED.
"""Батарея 143 (mob-ci-razdelenie).

Режимы:
  (без флага)  --repo отсутствует → rc 1 SUBJECT_ABSENT, все клетки красны
                поимённо (зелень без субъекта невозможна);
  --repo R     судится живой продукт R (клон Complior-mob): mobile.yml,
                mobile/ci-screens.json, mobile/scripts/select-ci-screens.cjs,
                mobile/scripts/ci-aggregate.cjs, отсутствие
                .github/workflows/mobile-e2e-retry.yml;
  --model      субъект = model/ (контроль входов);
  --stabs      контроль + матрица обманных стабов (SVJAZI N, живых 0);
  --matrix     синоним --stabs.
Клетка p01-P-nabor — АКТИВНАЯ (перепин исполнен: freeze 995/5, ленд
ffbbc99e7, H-пин 4ac99af9, носители P/S батареи обновлены): replay судит
исполняемый набор P по ЭФФЕКТИВНОМУ checkout .harness — последний checkout
этого каталога (posixpath.normpath: алиасы ./.harness, .harness/ — тот же)
ДО ЕДИНСТВЕННОГО шага запуска maestro_probe.py (по ВСЕМ задачам, в
e2e-pilot; дубль судится последним, checkout после запуска P не влияет,
нелитеральный path неизмерим — П1/П2 арбитража 143-repin; вердикт критика
1/2 — атака двойного checkout); старый пин 66052cdf (frozen 995/4, rglob)
и неизмеренный пин — красные именованные причины.
Коды: 0 зелено; 1 красная клетка либо стаб прошёл; 2 нечем проверять
(нет node, ORACLE_TAMPERED, дрейф стабов/модели).
"""
import hashlib
import json
import os
import posixpath
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import yaml

HERE = Path(__file__).resolve().parent
MODEL = HERE / "model"
NOSITELI = HERE / "nositeli"
STABS = HERE / "stabs"
SOURCE = HERE / "source.json"

SUBJECT_FILES = [
    ".github/workflows/mobile.yml",
    "mobile/ci-screens.json",
    "mobile/scripts/select-ci-screens.cjs",
    "mobile/scripts/ci-aggregate.cjs",
]
RETRY_REL = ".github/workflows/mobile-e2e-retry.yml"

CANON_JOBS = ["select-screens", "quality", "build-apk", "e2e-splash",
              "e2e-first-run", "e2e-erstinformation", "e2e-start", "e2e-pilot",
              "android-e2e", "mobile-regression-signal"]
RABOTNIKI = ["e2e-splash", "e2e-first-run", "e2e-erstinformation", "e2e-start", "e2e-pilot"]
AGREGAT_NEEDS = {"select-screens", "quality", "build-apk"} | set(RABOTNIKI)
P_NABOR = ["pilot.yaml", "mobile/.maestro/start.yaml", "mobile/.maestro/rehearsal.yaml",
           "mobile/.maestro/cmp-mob-002-tabs.yaml"]
STRUKTURA_RE = [re.compile(r"^mobile/e2e-[^/]+/"), re.compile(r"^mobile/\.maestro/[^/]+\.yaml$"),
                re.compile(r"^mobile/src/app/")]
VNUTRI_RE = re.compile(r"^(mobile/|\.github/workflows/mobile\.yml$)")


def oshibka_orakula(msg):
    print("ORACLE_TAMPERED: %s" % msg, file=sys.stderr)
    return 2


def sha256_faila(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def zhestkij_kanon(src):
    for otn, digest in (src.get("piny") or {}).items():
        p = HERE / otn
        if not p.is_file():
            return "пин: файла нет %s" % otn
        if sha256_faila(p) != digest:
            return "пин: sha256 %s" % otn
    # перепись черновиков (арбитраж 143 Б4): девять именованных drafts/*.md,
    # каждый с пином sha256 — ДО клеток; отсутствие/лишний/расхождение байтов
    # = ORACLE_TAMPERED rc 2 (правило 1: счётная поставка судится машиной)
    chp = src.get("chernoviki_piny") or {}
    est = sorted(p.name for p in (HERE / "drafts").glob("*.md"))
    if sorted(chp) != est:
        return "черновики: перепись %s ≠ дерево %s" % (sorted(chp), est)
    for imja, digest in chp.items():
        p = HERE / "drafts" / imja
        if not p.is_file():
            return "черновик: файла нет %s" % imja
        if sha256_faila(p) != digest:
            return "черновик: sha256 %s" % imja
    # retired-нагрузка красной ветви p01/стаба p_rglob_kataloga — НЕ пин
    # source.json (перепин ЗАМЕЩАЕТ носитель: пины 21, census nositeli 8 —
    # как в замороженной приёмке п.4), но полезная нагрузка оракула:
    # целостность кодовой константой RETIRED_SHA256 — порча/удаление = rc 2
    # ORACLE_TAMPERED ДО клеток (подделка retired-поведения не даёт зелёное)
    if not RETIRED_NOSITEL.is_file():
        return "retired-нагрузка: файла нет %s" % RETIRED_OTN
    if sha256_faila(RETIRED_NOSITEL) != RETIRED_SHA256:
        return "retired-нагрузка: sha256 %s" % RETIRED_OTN
    return None


# --- НЕЗАВИСИМЫЙ доверенный канон выбора (субъект-селектор не зовётся) --------

def kanon_razberi_kartu(text):
    m = json.loads(text)
    zapisi = []
    for e in m.get("ekrany", []):
        zapisi.append({"id": e["id"], "job": e["job"], "status": e["status"],
                       "puti": e.get("puti") or [], "pack": e.get("pack"),
                       "flows": e.get("flows") or [], "integration": False})
    if m.get("integracija"):
        i = m["integracija"]
        zapisi.append({"id": i["id"], "job": i["job"], "status": i["status"],
                       "puti": i.get("puti") or [], "pack": None,
                       "flows": i.get("fiksirovannyj_nabor") or [], "integration": True})
    return zapisi, m.get("shared", {}).get("puti") or []


def kanon_pokryvaet(koren, p):
    if not koren:
        return False
    if koren.endswith("/"):
        return p == koren[:-1] or p.startswith(koren)
    return p == koren or p.startswith(koren + "/")


def kanon_vybor(karta_base_text, karta_head_text, diff, mode):
    """(rc, selected_ids|None, full_set|None, prichiny)."""
    base_z, base_sh = kanon_razberi_kartu(karta_base_text) if karta_base_text else ([], [])
    head_z, head_sh = kanon_razberi_kartu(karta_head_text)
    union = {}
    porjadok = []
    for z in base_z + head_z:
        if z["id"] not in union:
            union[z["id"]] = dict(z)
            porjadok.append(z["id"])
        else:
            u = union[z["id"]]
            u["puti"] = list(dict.fromkeys(u["puti"] + z["puti"]))
            u["flows"] = list(dict.fromkeys(u["flows"] + z["flows"]))
            if u["pack"] != z["pack"]:
                u["pack"] = u["pack"] or z["pack"]
            if u["status"] != z["status"]:
                u["status"] = "in-development"
    shared = list(dict.fromkeys(base_sh + head_sh))
    # сужение политики — только если карта на base СУЩЕСТВОВАЛА (инвариант
    # селектора: первое появление карты не сужение)
    policy_change = False
    if karta_base_text is not None:
        policy_change = (
            json.dumps([[z["id"], z["job"], z["status"], z["puti"], z["pack"], z["flows"]] for z in base_z], ensure_ascii=False) +
            json.dumps(base_sh, ensure_ascii=False) !=
            json.dumps([[z["id"], z["job"], z["status"], z["puti"], z["pack"], z["flows"]] for z in head_z], ensure_ascii=False) +
            json.dumps(head_sh, ensure_ascii=False))

    def vladelec(p):
        vl = []
        for zid in porjadok:
            z = union[zid]
            korni = list(z["puti"]) + ([z["pack"]] if z["pack"] else []) + list(z["flows"])
            if any(kanon_pokryvaet(k, p) for k in korni):
                vl.append(zid)
        return vl

    if mode in ("schedule", "dispatch"):
        return 0, list(porjadok), True, ["FULL_SET_REZHIM"]

    selected = {zid: "DEVELOPMENT" for zid in porjadok if union[zid]["status"] == "in-development"}
    full = policy_change
    prichiny = ["POLICY_CHANGE"] if policy_change else []
    potoki_vl = {}
    for status_, old, nov in diff:
        for p in {old, nov}:
            if not p:
                continue
            if any(kanon_pokryvaet(k, p) for k in shared):
                full = True
                if "COMMON_CHANGE" not in prichiny:
                    prichiny.append("COMMON_CHANGE")
                continue
            vl = vladelec(p)
            if vl:
                for zid in vl:
                    selected.setdefault(zid, "AFFECTED")
                if re.match(r"^mobile/\.maestro/[^/]+\.yaml$", p):
                    potoki_vl.setdefault(p, set()).update(vl)
                continue
            if any(rx.search(p) for rx in STRUKTURA_RE):
                return 1, None, None, ["INVENTAR_KARTY"]
            if VNUTRI_RE.search(p):
                full = True
                if "UNKNOWN_PATH" not in prichiny:
                    prichiny.append("UNKNOWN_PATH")
    for p, vl in potoki_vl.items():
        if len(vl) > 1:
            return 1, None, None, ["INVENTAR_KARTY"]
    if full:
        for zid in porjadok:
            selected.setdefault(zid, prichiny[0])
    elif not selected:
        for zid in porjadok:
            selected[zid] = "EMPTY_SELECTION_FALLBACK"
        prichiny.append("EMPTY_SELECTION_FALLBACK")
    return 0, list(selected), full, prichiny


# --- подложные git/gh (replay в замкнутом PATH) --------------------------------

SHIM_GIT = """#!/usr/bin/env python3
import os, sys
a = sys.argv[1:]
if len(a) >= 2 and a[0] == "-C":
    a = a[2:]
z = os.environ.get("SCENARII_ZAPISI", "/dev/null")
def zap(l):
    open(z, "a").write(l + "\\n")
if len(a) >= 2 and a[0] == "merge-base":
    zap("GIT merge-base " + " ".join(a[1:]))
    rc = int(os.environ.get("SCENARII_MERGE_BASE_RC", "0"))
    if rc == 0:
        print(os.environ.get("SCENARII_MERGE_BASE_OUT", "base0beef"))
    sys.exit(rc)
if len(a) >= 2 and a[0] == "show":
    zap("GIT show " + " ".join(a[1:]))
    rc = int(os.environ.get("SCENARII_SHOW_RC", "1"))
    if rc == 0:
        sys.stdout.buffer.write(open(os.environ["SCENARII_SHOW_OUT"], "rb").read())
    sys.exit(rc)
if a[:1] == ["diff"]:
    zap("GIT diff " + " ".join(a[1:]))
    rc = int(os.environ.get("SCENARII_DIFF_RC", "0"))
    if rc == 0:
        sys.stdout.buffer.write(open(os.environ["SCENARII_DIFF_OUT"], "rb").read())
    sys.exit(rc)
zap("GIT_VNE_ALFAVITA " + " ".join(a))
sys.exit(127)
"""

SHIM_GH = """#!/usr/bin/env python3
import os, re, sys
a = sys.argv[1:]
z = os.environ.get("SCENARII_ZAPISI", "/dev/null")
def zap(l):
    open(z, "a").write(l + "\\n")
d = os.environ.get("SCENARII_GH_DIR", "")
zap("GH " + " ".join(a))
if len(a) == 2 and a[0] == "api":
    m = re.match(r"^repos/[^/]+/[^/]+/pulls/(\\d+)$", a[1])
    if m:
        rc = int(os.environ.get("SCENARII_GH_PULL_RC", "0"))
        if rc != 0:
            sys.exit(rc)
        sys.stdout.buffer.write(open(os.path.join(d, "pull.json"), "rb").read())
        sys.exit(0)
    m = re.match(r"^repos/[^/]+/[^/]+/pulls/(\\d+)/files", a[1])
    if m:
        page = 1
        q = re.search(r"[?&]page=(\\d+)", a[1])
        if q:
            page = int(q.group(1))
        f = os.path.join(d, "files-page-%d.json" % page)
        if not os.path.isfile(f):
            sys.exit(1)
        sys.stdout.buffer.write(open(f, "rb").read())
        sys.exit(0)
sys.exit(127)
"""


def zapis_diff_v_potok(spisok):
    """diff → сырой -z поток git diff --name-status (живой формат)."""
    ch = b""
    for status_, old, nov in spisok:
        if status_ in ("R", "C"):
            ch += status_.encode() + b"\x00" + old.encode() + b"\x00" + nov.encode() + b"\x00"
        else:
            ch += status_.encode() + b"\x00" + nov.encode() + b"\x00"
    return ch

# --- подложные adb/emulator/avdmanager/maestro/gh-run (replay работника и P) ---

SHIM_ADB = """#!/usr/bin/env python3
import os, sys
log = os.environ.get("ADB_LOG", "/dev/null")
a = sys.argv[1:]
with open(log, "a") as f:
    f.write("ADB " + " ".join(a) + "\\n")
if a[:1] == ["-s"]:
    a = a[2:]
cmd = a[0] if a else ""
rest = a[1:]
if cmd == "get-state":
    print("device")
elif cmd == "install":
    with open(log, "a") as f:
        f.write("USTANOVLEN " + " ".join(rest) + "\\n")
elif cmd == "shell":
    vnutr = rest[0] if rest else ""
    if vnutr == "getprop":
        print("1")
    elif vnutr.startswith("cat"):
        print("b0b0b0b0-1111-2222-3333-444444444444")
    elif vnutr == "pidof":
        print("4242")
elif cmd == "devices":
    print("List of devices attached")
sys.exit(0)
"""

SHIM_EMULATOR = """#!/bin/sh
# подложный эмулятор: живёт фоновым процессом (kill -0 у скриптов честен),
# ничего не занимает; прибивается killpg драйвера либо kill $EMU_PID скрипта.
exec sleep 300
"""

SHIM_MAESTRO = """#!/usr/bin/env python3
import os, sys, time
from pathlib import Path
log = os.environ.get("MAESTRO_LOG", "/dev/null")
args = sys.argv[1:]
with open(log, "a") as f:
    f.write("MAESTRO_ARGV " + " ".join(args) + "\\n")
if "--version" in args:
    print("2.11.0")
    sys.exit(0)
if "test" not in args:
    sys.exit(0)
t = args.index("test")
flags_s_znacheniem = {"--device", "--format", "--output", "--test-output-dir", "-e"}
out = tdir = None
potoki = []
j = t + 1
while j < len(args):
    a = args[j]
    if a in flags_s_znacheniem:
        if a == "--output":
            out = args[j + 1]
        elif a == "--test-output-dir":
            tdir = args[j + 1]
        j += 2
        continue
    if a.startswith("-"):
        j += 1
        continue
    potoki.append(a)
    j += 1
razbor = []
for fl in potoki:
    p = Path(fl)
    if p.is_dir():
        for q in sorted(p.glob("*.yaml")):
            if q.name != "config.yaml":
                razbor.append(q.name)
    else:
        razbor.append(p.name)
with open(log, "a") as f:
    f.write("MAESTRO_POTOKI " + " ".join(razbor) + "\\n")
if out:
    if tdir:
        papka = Path(tdir) / str(int(time.time())) / "pilot" / "takeScreenshot"
        papka.mkdir(parents=True, exist_ok=True)
        for imja in ("pilot-first-run.png", "pilot-welcome.png", "pilot-restart.png"):
            (papka / imja).write_bytes(b"PNG-STUB-143\\n")
    Path(out).parent.mkdir(parents=True, exist_ok=True)
    Path(out).write_text('<?xml version="1.0"?><testsuites><testsuite name="maestro">'
                         '<testcase name="pilot" classname="maestro"/></testsuite></testsuites>')
sys.exit(0)
"""

SHIM_GH_RUN = """#!/usr/bin/env python3
import os, sys
log = os.environ.get("GH_LOG", "/dev/null")
a = sys.argv[1:]
with open(log, "a") as f:
    f.write("GH " + " ".join(a) + "\\n")
if a[:2] == ["run", "download"]:
    d = n = None
    j = 2
    while j < len(a):
        if a[j] == "--name" and j + 1 < len(a):
            n = a[j + 1]; j += 2; continue
        if a[j] == "--dir" and j + 1 < len(a):
            d = a[j + 1]; j += 2; continue
        j += 1
    if d:
        os.makedirs(d, exist_ok=True)
        # ПОДКОЛОТЫЙ APK: digest заведомо ≠ ZHELANYJ_DIGEST прогона
        with open(os.path.join(d, "app-release.apk"), "w") as f:
            f.write("PODKOLYOT-APK-BAJTY-995-143\\n")
sys.exit(0)
"""

SHIM_AVDMANAGER = """#!/bin/sh
# подложный avdmanager: create avd пишет config.ini (sed -i в шагах честен),
# delete avd молча ок; все вызовы пишутся в AVDMANAGER_LOG.
LOG="${AVDMANAGER_LOG:-/dev/null}"
echo "AVDMANAGER $*" >> "$LOG"
case "$1 $2" in
  "create avd")
    shift 2
    n=""
    while [ $# -gt 0 ]; do
      case "$1" in
        -n) n="$2"; shift 2 ;;
        *) shift ;;
      esac
    done
    if [ -n "$n" ]; then
      mkdir -p "${ANDROID_AVD_HOME%/}/$n.avd"
      printf 'hw.ramSize=2048\\n' > "${ANDROID_AVD_HOME%/}/$n.avd/config.ini"
    fi
    exit 0 ;;
  "delete avd") exit 0 ;;
esac
exit 0
"""

PODKOLOTYJ_APK = b"PODKOLYOT-APK-BAJTY-995-143\n"


class RenderVneAlfavita(Exception):
    pass


def render_vyrazhenij(text, znachenija):
    """Рендер ${{ ... }} ЗАКРЫТЫМ алфавитом (контексты прогона батареи);
    неизвестное выражение — исключение (клетка красна именованной причиной)."""
    def podmena(m):
        kluch = m.group(1).strip()
        if kluch not in znachenija:
            raise RenderVneAlfavita(kluch)
        return znachenija[kluch]
    return re.sub(r"\$\{\{([^}]+)\}\}", podmena, text)


def _napishi_shim(p, tekst):
    p.write_text(tekst, encoding="utf-8")
    p.chmod(0o700)


def postroj_pesochitsu(tmp):
    """Замкнутая среда прогона: workspace, bin/ с подложными adb/emulator/
    maestro/gh, фиктивный ANDROID_HOME с avdmanager-подложкой, env."""
    koren = Path(tmp)
    ws = koren / "ws"
    (ws / "mobile").mkdir(parents=True, exist_ok=True)
    bin_dir = koren / "bin"
    bin_dir.mkdir(exist_ok=True)
    android = koren / "android-home"
    avdm = android / "cmdline-tools" / "latest" / "bin"
    avdm.mkdir(parents=True, exist_ok=True)
    avd_home = koren / "avd"
    avd_home.mkdir(exist_ok=True)
    home = koren / "home"
    home.mkdir(exist_ok=True)
    _napishi_shim(bin_dir / "adb", SHIM_ADB)
    _napishi_shim(bin_dir / "emulator", SHIM_EMULATOR)
    _napishi_shim(bin_dir / "maestro", SHIM_MAESTRO)
    _napishi_shim(bin_dir / "gh", SHIM_GH_RUN)
    _napishi_shim(avdm / "avdmanager", SHIM_AVDMANAGER)
    logi = {}
    for imja in ("ADB_LOG", "MAESTRO_LOG", "GH_LOG", "AVDMANAGER_LOG"):
        f = koren / (imja.lower() + ".txt")
        f.write_text("", encoding="utf-8")
        logi[imja] = str(f)
    env = dict(os.environ)
    env.update({
        "PATH": str(bin_dir) + os.pathsep + "/usr/bin:/bin",
        "HOME": str(home),
        "ANDROID_HOME": str(android),
        "ANDROID_AVD_HOME": str(avd_home),
        "GITHUB_RUN_ID": "4242",
        "GITHUB_RUN_ATTEMPT": "1",
        "GH_TOKEN": "TESTTOKEN-143",
    })
    env.update(logi)
    return ws, env


def konteksty_rendera(ws, sborka, needs_joba):
    """Закрытый алфавит выражений прогона: github.*, github.token,
    needs.<job>.outputs.* — ТОЛЬКО для job ∈ needs задачи (семантика ГитХаба,
    арбитраж 143 Б2: у работника без ребра к build-apk рендер её outputs
    невозможен — шаг digest/идентичности вне needs красен рендером)."""
    zn = {
        "github.run_id": "4242",
        "github.run_attempt": "1",
        "github.workspace": str(ws),
        "github.sha": "f" * 40,
        "github.ref": "refs/heads/main",
        "github.event_name": "pull_request",
        "github.event.pull_request.number": "124",
        "github.token": "TESTTOKEN-143",
    }
    if "build-apk" in needs_joba:
        zn.update({
            "needs.build-apk.outputs.apk_sha256": sborka["apk_sha256"],
            "needs.build-apk.outputs.artifact_name": sborka["artifact_name"],
            "needs.build-apk.outputs.run_id": sborka["run_id"],
        })
    return zn


def _ispolni_shag(skript, cwd, env, vremja=120):
    """Один run-шаг: bash в собственной сессии; после выхода — killpg,
    чтобы фоновые подложки (эмулятор) не пережили шаг. (rc, stdout, stderr)."""
    import signal
    import subprocess as sp
    p = sp.Popen(["bash", "-c", skript], cwd=str(cwd), env=env,
                 stdout=sp.PIPE, stderr=sp.PIPE, text=True, start_new_session=True)
    try:
        out, err = p.communicate(timeout=vremja)
        rc = p.returncode
    except sp.TimeoutExpired:
        try:
            os.killpg(os.getpgid(p.pid), signal.SIGKILL)
        except (ProcessLookupError, PermissionError, OSError):
            pass
        out, err = p.communicate()
        return 124, out, err
    try:
        os.killpg(os.getpgid(p.pid), signal.SIGKILL)
    except (ProcessLookupError, PermissionError, OSError):
        pass
    return rc, out, err


def replej_rabotnika(wf, job_imja, tmp, do_posle=None):
    """Последовательный ИСПОЛНИТЕЛЬНЫЙ replay run-шагов job из субъекта:
    ГитХаб-семантика (обычный шаг после отказа не идёт; if: always() идёт;
    uses: — действия, записываются и пропускаются). Возвращает
    (rc_итог, hvost_stderr, ustanovlen_li, oshibka|None)."""
    ws, env = postroj_pesochitsu(tmp)
    digest = hashlib.sha256(b"ETALON-APK-143\n").hexdigest()
    sborka = {"apk_sha256": digest, "artifact_name": "apk-4242-" + digest[:12], "run_id": "4242"}
    znach = konteksty_rendera(ws, sborka, set((wf.get("jobs", {}).get(job_imja) or {}).get("needs") or []))
    shagi = (wf.get("jobs", {}).get(job_imja) or {}).get("steps") or []
    itog = 0
    hvost = ""
    for s in shagi:
        if s.get("uses"):
            continue
        imja = s.get("name") or ""
        if do_posle is not None and imja not in do_posle:
            continue
        if itog != 0 and "always()" not in (s.get("if") or ""):
            continue
        skript = s.get("run") or ""
        try:
            skript = render_vyrazhenij(skript, znach)
        except RenderVneAlfavita as e:
            return itog, hvost, False, "РЕНДЕР_ВНЕ_АЛФАВИТА: %s" % e
        wd = s.get("working-directory")
        cwd = ws
        if wd:
            try:
                wd_r = render_vyrazhenij(wd, znach)
            except RenderVneAlfavita as e:
                return itog, hvost, False, "РЕНДЕР_ВНЕ_АЛФАВИТА: %s" % e
            cwd = Path(wd_r)
            if not cwd.is_dir():
                return itog, hvost, False, "working-directory %s вне песочницы" % wd_r
        env_shaga = dict(env)
        gh_out = Path(tmp) / ("gh-out-%s.txt" % abs(hash(imja)))
        gh_out.write_text("", encoding="utf-8")
        env_shaga["GITHUB_OUTPUT"] = str(gh_out)
        for k, v in (s.get("env") or {}).items():
            if not isinstance(v, str):
                return itog, hvost, False, "env шага %r не строка" % k
            try:
                env_shaga[k] = render_vyrazhenij(v, znach)
            except RenderVneAlfavita as e:
                return itog, hvost, False, "РЕНДЕР_ВНЕ_АЛФАВИТА: %s" % e
        rc, out, err = _ispolni_shag(skript, cwd, env_shaga)
        hvost = (err or "")[-400:]
        if rc != 0:
            itog = rc
            break
    adb_log = Path(env["ADB_LOG"]).read_text(encoding="utf-8")
    ustanovlen = any(l.startswith("USTANOVLEN") for l in adb_log.splitlines())
    return itog, hvost, ustanovlen, None


# --- S-ось: сценарии селектора --------------------------------------------------

# Правило 8 (оракул ДО субъекта): чтение/разбор карты модели на импорте НЕ
# имеет права ронять движок traceback'ом — битые/отсутствующие пинованные
# файлы обязан отвергнуть zhestkij_kanon (rc 2 ORACLE_TAMPERED) ДО клеток.
try:
    KARTA_HEAD = (MODEL / "mobile/ci-screens.json").read_text(encoding="utf-8")
except OSError:
    KARTA_HEAD = None
SCENARII_S = {}


def karta_s_izmeneniem(mutacija):
    m = json.loads(KARTA_HEAD)
    mutacija(m)
    return json.dumps(m, ensure_ascii=False, indent=2) + "\n"


def sc_s(**kw):
    return {
        "mode": kw.get("mode", "push"),
        "karta_head": kw.get("karta_head", KARTA_HEAD),
        "karta_base": kw.get("karta_base"),
        "diff": kw.get("diff", []),
        "diff_rc": kw.get("diff_rc", 0),
        "merge_base_rc": kw.get("merge_base_rc", 0),
        "gh": kw.get("gh"),
        "pr": kw.get("pr", "124"),
    }


def reg_s(imja, sc, ozh):
    SCENARII_S[imja] = {"sc": sc, "ozh": ozh}


def sobiraem_s():
    K = KARTA_HEAD

    def suzit_start(m):
        for e in m["ekrany"]:
            if e["id"] == "start":
                e["puti"] = ["mobile/src/features/start/start-screen.tsx"]

    def snjat_status(m):
        for e in m["ekrany"]:
            if e["id"] == "erstinformation":
                e["status"] = "in-development"

    def udalit_erst(m):
        m["ekrany"] = [e for e in m["ekrany"] if e["id"] != "erstinformation"]

    def dva_vladelca(m):
        m["ekrany"][0]["flows"].append("mobile/.maestro/start.yaml")

    def pustoj_reestr(m):
        m["ekrany"] = []
        m.pop("integracija")

    def shema2(m):
        m["schema"] = 2

    # (а) общий код → полный набор; негативная пара — локальный файл → один экран
    reg_s("s01-obshchij-kod", sc_s(diff=[("M", "", "mobile/src/bootstrap/pilot-app.tsx")]),
          (0, None, True, {"COMMON_CHANGE"}, "vse"))
    reg_s("s02-lokalnyj-ekran", sc_s(diff=[("M", "", "mobile/src/features/start/start-screen.tsx")]),
          (0, ["start"], False, set(), None))
    # (б) инвентарь: новый pack / новый флоу / флоу двух владельцев
    reg_s("s03-novyj-pack", sc_s(diff=[("A", "", "mobile/e2e-mission/kontrakt.md")]),
          (1, None, None, {"INVENTAR_KARTY"}, None))
    reg_s("s04-novyj-potok", sc_s(diff=[("A", "", "mobile/.maestro/mission.yaml")]),
          (1, None, None, {"INVENTAR_KARTY"}, None))
    reg_s("s05-potok-dvoe-vladeltsev", sc_s(karta_head=karta_s_izmeneniem(dva_vladelca),
                                            diff=[("M", "", "mobile/.maestro/start.yaml")]),
          (1, None, None, {"INVENTAR_KARTY"}, None))
    # (в) union base/head: сужение glob / снятие статуса / удаление записи в том же PR
    reg_s("s06-glob-suzhen", sc_s(karta_head=karta_s_izmeneniem(suzit_start),
                                  karta_base=K,
                                  diff=[("M", "", "mobile/src/features/start/start-section-host.tsx")]),
          (0, None, True, {"POLICY_CHANGE"}, None))
    reg_s("s07-status-snjat", sc_s(karta_head=karta_s_izmeneniem(snjat_status),
                                   karta_base=K,
                                   diff=[("M", "", "mobile/e2e-erstinformation/ekran.json")]),
          (0, None, True, {"POLICY_CHANGE"}, None))
    reg_s("s08-zapis-udalena", sc_s(karta_head=karta_s_izmeneniem(udalit_erst),
                                    karta_base=K,
                                    diff=[("M", "", "mobile/e2e-erstinformation/ekran.json")]),
          (0, None, True, {"POLICY_CHANGE"}, None))
    # (г) имена путей: rename обе стороны, delete, пробел, Unicode, \n, typechange
    reg_s("s09-rename-vnutri", sc_s(diff=[("R", "mobile/src/features/start/start-screen.tsx",
                                           "mobile/src/features/start/peremenovannyj.tsx")]),
          (0, ["start"], False, set(), None))
    reg_s("s10-rename-vne-karty", sc_s(diff=[("R", "mobile/src/features/start/start-screen.tsx",
                                              "mobile/src/features/novoe/mesto.tsx")]),
          (0, None, True, {"UNKNOWN_PATH"}, None))
    reg_s("s11-udalenie-fajla", sc_s(diff=[("D", "", "mobile/.maestro/first-run-ekran.yaml")]),
          (0, ["first-run"], False, set(), None))
    reg_s("s12-probel-v-imeni", sc_s(diff=[("A", "", "mobile/e2e-first-run/kadry s probelom.png")]),
          (0, ["first-run"], False, set(), None))
    reg_s("s13-unicode-v-imeni", sc_s(diff=[("M", "", "mobile/src/features/start/кириллица — файл.tsx")]),
          (0, ["start"], False, set(), None))
    reg_s("s14-perevod-stroki", sc_s(diff=[("A", "", "mobile/e2e-first-run/a\nb.png")]),
          (0, ["first-run"], False, set(), None))
    reg_s("s15-tip-izmenenija", sc_s(diff=[("T", "mobile/src/features/start/start-screen.tsx",
                                            "mobile/src/features/start/start-screen.tsx")]),
          (0, ["start"], False, set(), None))
    # (д) отказ входа — красный с именем, не selected=[]
    reg_s("s16-net-bazy", sc_s(merge_base_rc=1), (1, None, None, {"NET_BAZY"}, None))
    reg_s("s17-api-usechenie", sc_s(mode="pull_request", diff_rc=1, gh={"pull_rc": 0, "dir": "trunc"}),
          (1, None, None, {"USECHENIE_API"}, None))
    reg_s("s18-oshibka-diffa", sc_s(diff_rc=128), (1, None, None, {"OSIBKA_DIFFA"}, None))
    reg_s("s19-shema-karty", sc_s(karta_head=karta_s_izmeneniem(shema2)),
          (1, None, None, {"SKHEMA_KARTY"}, None))
    reg_s("s20-pustoj-reestr", sc_s(karta_head=karta_s_izmeneniem(pustoj_reestr)),
          (1, None, None, {"PUSTOJ_REESTR"}, None))
    # (е) пустой первичный выбор — полный набор с причиной; docs-only не skip
    reg_s("s21-doksi-fallback", sc_s(diff=[("M", "", "README.md")]),
          (0, None, True, {"EMPTY_SELECTION_FALLBACK"}, None))
    # (о) ночь/диспетч — полный набор без diff
    reg_s("s22-noch-polnyj-nabor", sc_s(mode="schedule"), (0, None, True, {"FULL_SET_REZHIM"}, "vse"))
    reg_s("s23-push-do-posle", sc_s(mode="push", diff=[("A", "", "mobile/e2e-first-run/novyj-kadr.json")]),
          (0, ["first-run"], False, set(), None))
    # gh-api fallback на ЖИВОМ files-ответе PR #124 (37 файлов; workflow+bootstrap → COMMON)
    reg_s("s24-api-fallback-zhivoj", sc_s(mode="pull_request", diff_rc=1, gh={"pull_rc": 0, "dir": "polnyj"}),
          (0, None, True, {"COMMON_CHANGE"}, None))
    reg_s("s25-merge-gruppa", sc_s(mode="merge_group",
                                   diff=[("M", "", "mobile/src/features/start/start-screen.tsx")]),
          (0, ["start"], False, set(), None))


def zapusti_selektor(subject_selector, sc, tmp):
    sandbox = Path(tmp) / "repo"
    (sandbox / "mobile" / "scripts").mkdir(parents=True, exist_ok=True)
    (sandbox / "mobile" / "ci-screens.json").write_text(sc["karta_head"], encoding="utf-8")
    shutil.copyfile(subject_selector, sandbox / "mobile" / "scripts" / "select-ci-screens.cjs")
    bin_dir = Path(tmp) / "bin"
    bin_dir.mkdir(exist_ok=True)
    zapisi = Path(tmp) / "zapisi.txt"
    zapisi.write_text("", encoding="utf-8")
    diff_out = Path(tmp) / "diff.z"
    diff_out.write_bytes(zapis_diff_v_potok(sc["diff"]))
    env = dict(os.environ)
    env.update({
        "PATH": str(bin_dir) + os.pathsep + "/usr/bin:/bin",
        "SCENARII_ZAPISI": str(zapisi),
        "SCENARII_MERGE_BASE_RC": str(sc["merge_base_rc"]),
        "SCENARII_MERGE_BASE_OUT": "babe0beefbabe0beefbabe0beefbabe0beefbabe",
        "SCENARII_DIFF_RC": str(sc["diff_rc"]),
        "SCENARII_DIFF_OUT": str(diff_out),
    })
    if sc["karta_base"] is not None:
        show_out = Path(tmp) / "karta-base.json"
        show_out.write_text(sc["karta_base"], encoding="utf-8")
        env["SCENARII_SHOW_RC"] = "0"
        env["SCENARII_SHOW_OUT"] = str(show_out)
    else:
        env["SCENARII_SHOW_RC"] = "1"
    if sc["gh"]:
        gh_dir = Path(tmp) / "gh" / sc["gh"]["dir"]
        gh_dir.mkdir(parents=True, exist_ok=True)
        env["SCENARII_GH_DIR"] = str(gh_dir)
        env["SCENARII_GH_PULL_RC"] = str(sc["gh"].get("pull_rc", 0))
        if sc["gh"]["dir"] == "trunc":
            shutil.copyfile(NOSITELI / "api" / "pull-124-files-stranitsa.json", gh_dir / "files-page-1.json")
            pull = json.loads((NOSITELI / "api" / "pull-124.json").read_text(encoding="utf-8"))
            pull["changed_files"] = 37
            (gh_dir / "pull.json").write_text(json.dumps(pull), encoding="utf-8")
        else:
            shutil.copyfile(NOSITELI / "api" / "pull-124-files.json", gh_dir / "files-page-1.json")
            shutil.copyfile(NOSITELI / "api" / "pull-124.json", gh_dir / "pull.json")
    (bin_dir / "git").write_text(SHIM_GIT, encoding="utf-8")
    (bin_dir / "git").chmod(0o700)
    (bin_dir / "gh").write_text(SHIM_GH, encoding="utf-8")
    (bin_dir / "gh").chmod(0o700)
    sel_out = Path(tmp) / "selection.json"
    args = ["node", str(sandbox / "mobile" / "scripts" / "select-ci-screens.cjs"),
            "--mode", sc["mode"], "--base-sha", "b" * 40, "--head-sha", "f" * 40,
            "--out", str(sel_out), "--repo", str(sandbox)]
    if sc["mode"] == "pull_request":
        args += ["--pr", sc["pr"]]
    try:
        r = subprocess.run(args, env=env, capture_output=True, text=True, timeout=120, cwd=str(tmp))
        rc, out, err = r.returncode, r.stdout, r.stderr
    except subprocess.TimeoutExpired:
        return 124, None, "", "TAJMAUT"
    sel = None
    if sel_out.is_file():
        try:
            sel = json.loads(sel_out.read_text(encoding="utf-8"))
        except Exception:
            sel = None
    return rc, sel, out, err


def sudja_s(subject_selector, sc, ozh, tmp):
    rc, sel, out, err = zapusti_selektor(subject_selector, sc, tmp)
    k_rc, k_sel_ids, k_full, k_prichiny, k_vse = ozh
    if rc != k_rc:
        return False, "rc=%d, канон rc=%d (%s)" % (rc, k_rc, (err or "").strip()[:160])
    if k_rc == 1:
        ok_imja = any(p in (err or "") for p in k_prichiny)
        return ok_imja, "rc 1 без имени %s: %s" % (sorted(k_prichiny), (err or "").strip()[:160])
    if sel is None:
        return False, "selection.json не написан/не разобран"
    poluch = {s["job"] for s in sel.get("selected", [])}
    if k_vse == "vse":
        if len(poluch) != len(RABOTNIKI):
            return False, "ожидался полный набор, получено %s" % sorted(poluch)
    elif k_sel_ids is not None:
        want = {("e2e-pilot" if i == "pilot" else "e2e-" + i) for i in k_sel_ids}
        if poluch != want:
            return False, "selected %s ≠ канон %s" % (sorted(poluch), sorted(want))
    if k_full is not None and bool(sel.get("full_set")) != k_full:
        return False, "full_set=%s, канон %s" % (sel.get("full_set"), k_full)
    if k_prichiny:
        polucheny = set(sel.get("prichiny") or []) | {n.split(":")[0] for n in sel.get("notes") or []}
        if not (set(k_prichiny) <= polucheny):
            return False, "причины %s не содержат канон %s" % (sorted(polucheny), sorted(k_prichiny))
    return True, ""


# --- A-ось: агрегат --------------------------------------------------------------

SCENARII_A = {}


def shablon_needs(vybrannye, rezultaty, digests=None, run_ids=None, selection=None, sluzhebnye=None):
    digests = digests or {}
    run_ids = run_ids or {}
    if selection is None:
        selection = {
            "selected": [{"id": "start", "job": j, "reason": "AFFECTED"}
                         for j in vybrannye],
            "excluded": [{"id": "fr", "job": j, "reason": "NOT_SELECTED"}
                         for j in RABOTNIKI if j not in vybrannye],
        }
    needs = {}
    sluzh = sluzhebnye or {}
    for j, rez in (("select-screens", "success"), ("quality", "success"), ("build-apk", "success")):
        needs[j] = {"result": sluzh.get(j, rez), "outputs": {}}
    needs["select-screens"]["outputs"] = {"selection": json.dumps(selection, ensure_ascii=False)}
    needs["build-apk"]["outputs"] = {"apk_sha256": "a" * 64, "artifact_name": "apk-4242-aaaaaaaaaaaa",
                                     "run_id": "4242"}
    for j in RABOTNIKI:
        if j in rezultaty:
            needs[j] = {"result": rezultaty[j],
                        "outputs": {"apk_sha256": digests.get(j, "a" * 64),
                                    "artifact_name": "apk-4242-aaaaaaaaaaaa",
                                    "run_id": run_ids.get(j, "4242")}}
    return needs


def reg_a(imja, needs, ozh_rc, ozh_imja):
    SCENARII_A[imja] = (needs, ozh_rc, ozh_imja)


def sobiraem_a():
    reg_a("a01-pustoj-nabor",
          shablon_needs([], {"e2e-splash": "success"},
                        selection={"selected": [], "excluded": [
                            {"id": "x", "job": j, "reason": "NOT_SELECTED"} for j in RABOTNIKI]}),
          1, "PUSTOJ_NABOR")
    reg_a("a02-vybrannyj-vne-reestra", shablon_needs(["e2e-start"], {}), 1, "VNE_REESTRA")
    reg_a("a03-vybrannyj-skip", shablon_needs(["e2e-start"], {"e2e-start": "skipped"}), 1, "VYBRANNAYA_NE_USPEH")
    reg_a("a04-vybrannyj-cancelled", shablon_needs(["e2e-start"], {"e2e-start": "cancelled"}), 1, "VYBRANNAYA_NE_USPEH")
    reg_a("a05-vybrannyj-timeout", shablon_needs(["e2e-start"], {"e2e-start": "timed_out"}), 1, "VYBRANNAYA_NE_USPEH")
    reg_a("a06-vybrannyj-failure", shablon_needs(["e2e-start"], {"e2e-start": "failure"}), 1, "VYBRANNAYA_NE_USPEH")
    reg_a("a07-selector-upal", shablon_needs(["e2e-start"], {"e2e-start": "success"},
                                             sluzhebnye={"select-screens": "failure"}), 1, "SLUZHEBNAYA_NE_ZELENA")
    reg_a("a08-sborka-upala", shablon_needs(["e2e-start"], {"e2e-start": "success"},
                                            sluzhebnye={"build-apk": "failure"}), 1, "SLUZHEBNAYA_NE_ZELENA")
    reg_a("a09-kachestvo-upalo", shablon_needs(["e2e-start"], {"e2e-start": "success"},
                                               sluzhebnye={"quality": "failure"}), 1, "SLUZHEBNAYA_NE_ZELENA")
    reg_a("a10-digest-chuzhoj", shablon_needs(["e2e-start"], {"e2e-start": "success"},
                                              digests={"e2e-start": "b" * 64}), 1, "APK_DIGEST_RASKHOZHDENIE")
    reg_a("a11-staryj-artefakt", shablon_needs(["e2e-start"], {"e2e-start": "success"},
                                               run_ids={"e2e-start": "1111"}), 1, "STARYJ_ARTEFAKT")
    reg_a("a12-lishnij-rabotnik", shablon_needs(["e2e-start"], {"e2e-start": "success", "e2e-splash": "success"}),
          1, "LISHNIJ_RABOTNIK")
    reg_a("a13-skip-bez-prichiny",
          shablon_needs(["e2e-start"], {"e2e-start": "success", "e2e-splash": "skipped"},
                        selection={"selected": [{"id": "start", "job": "e2e-start", "reason": "AFFECTED"}],
                                   "excluded": []}),
          1, "SKIP_BEZ_PRICHINY")
    reg_a("a14-iskljuchennyj-objasnen",
          shablon_needs(["e2e-start", "e2e-splash"], {"e2e-start": "success", "e2e-splash": "success"}),
          0, "AGREGAT_OK")
    reg_a("a15-otmena-odnogo",
          shablon_needs(["e2e-start", "e2e-splash"], {"e2e-start": "success", "e2e-splash": "cancelled"}),
          1, "VYBRANNAYA_NE_USPEH")
    reg_a("a16-pustoj-needs", {}, 1, "PUSTOJ_NEEDS")


def sudja_a(subject_aggregate, needs, ozh_rc, ozh_imja, tmp):
    f = Path(tmp) / "needs.json"
    f.write_text(json.dumps(needs), encoding="utf-8")
    try:
        r = subprocess.run(["node", str(subject_aggregate), "--needs", str(f)],
                           capture_output=True, text=True, timeout=60)
    except subprocess.TimeoutExpired:
        return False, "TAJMAUT"
    if r.returncode != ozh_rc:
        return False, "rc=%d, канон rc=%d; вывод: %s" % (r.returncode, ozh_rc, (r.stdout + r.stderr).strip()[:160])
    if ozh_rc == 1 and ozh_imja not in r.stdout:
        return False, "rc 1 без имени %s: %s" % (ozh_imja, r.stdout.strip()[:160])
    if ozh_rc == 0 and "AGREGAT_OK" not in r.stdout:
        return False, "rc 0 без AGREGAT_OK: %s" % r.stdout.strip()[:160]
    return True, ""

# --- a17/p01: исполнительные replay-клетки (блокеры 1 и 2 критика 143 v1) ---------

IMJA_DIGEST_SHAGA = "APK сборки: артефакт по имени, digest до установки"


def sud_digest_replej(subject_root, tmp):
    """a17-digest-do-ustanovki (блокер 1): поведенческая отрицательная клетка —
    ИСПОЛНЯЕТ шаги работника с подложным APK иного digest в замкнутом PATH:
    (1) у КАЖДОГО из пяти работников шаг digest обязан упасть rc≠0 с именем
    APK_DIGEST_RASKHOZHDENIE ДО установки (в логе подложного adb нет
    USTANOVLEN); (2) полная цепочка e2e-start (доследующая установка в шаге
    экрана) доказывает остановку ДО adb install: маркер установки не появился.
    Мутант «проверка digest отключена мёртвой веткой» проходит digest-шаг,
    доходит до экранного шага и ставит подложный APK — маркер ловится."""
    d = Path(subject_root)
    wf_p = d / ".github" / "workflows" / "mobile.yml"
    if not wf_p.is_file():
        return False, "SUBJECT_ABSENT"
    try:
        wf = yaml.safe_load(wf_p.read_text(encoding="utf-8"))
    except Exception as e:
        return False, "MOBILE_YML_NE_YAML: %s" % e
    for j in RABOTNIKI:
        shagi = (wf.get("jobs", {}).get(j) or {}).get("steps") or []
        if not any((s.get("name") or "") == IMJA_DIGEST_SHAGA for s in shagi):
            return False, "%s без шага digest" % j
        podtmp = Path(tmp) / ("digest-%s" % j)
        podtmp.mkdir(exist_ok=True)
        rc, hvost, ustanovlen, osh = replej_rabotnika(
            wf, j, podtmp, do_posle={IMJA_DIGEST_SHAGA})
        if osh:
            return False, "%s: %s" % (j, osh)
        if rc == 0:
            return False, "%s: шаг digest прошёл с подложным APK (rc 0) — проверки до установки нет" % j
        if "APK_DIGEST_RASKHOZHDENIE" not in hvost:
            return False, "%s: rc %d без имени APK_DIGEST_RASKHOZHDENIE: %s" % (j, rc, hvost.strip()[:120])
        if ustanovlen:
            return False, "%s: подложный APK УСТАНОВЛЕН до отказа digest" % j
    podtmp = Path(tmp) / "digest-full-e2e-start"
    podtmp.mkdir(exist_ok=True)
    rc, hvost, ustanovlen, osh = replej_rabotnika(wf, "e2e-start", podtmp)
    if osh:
        return False, "полная цепочка e2e-start: %s" % osh
    if rc == 0:
        return False, "полная цепочка e2e-start прошла с подложным APK (rc 0)"
    if "APK_DIGEST_RASKHOZHDENIE" not in hvost:
        return False, "полная цепочка e2e-start rc %d без имени: %s" % (rc, hvost.strip()[:120])
    if ustanovlen:
        return False, "полная цепочка e2e-start: подложный APK установлен (маркер USTANOVLEN) — работник НЕ остановился до установки"
    return True, ""


# Измеренные H-пины задачи, исполняющей P (перепин 995/5): батарея судит набор
# P ТОЛЬКО на пинах, чьи байты maestro_probe.py она сама пинует. Retired пин
# 66052cdf — НЕ пин оракула source.json (перепин ЗАМЕЩАЕТ носитель: пины 21,
# census nositeli 8 — как в замороженной приёмке п.4): его байты — ВСТРОЕННАЯ
# полезная нагрузка красной ветви p01/стаба p_rglob_kataloga, живёт в stabs/
# ВНЕ glob stab_*.py (census stabs 33 не трогает); целостность — кодовой
# константой RETIRED_SHA256 (порча/удаление = rc 2 ORACLE_TAMPERED ДО клеток:
# подделка retired-поведения не даёт зелёное).
PIN_H_STAR_995_4 = "66052cdfd134ab0958421a961caef219694a54df"  # retired: P rglob всего .maestro (frozen 995/4)
PIN_H_NOVYJ_995_5 = "4ac99af9fe8b02f16206b5c98bb9556556c05e74"  # freeze 995/5, ленд ffbbc99e7: P v5 — фиксированный набор из manifest
RETIRED_OTN = "stabs/p-66052cdf.py"
RETIRED_NOSITEL = HERE / RETIRED_OTN
RETIRED_SHA256 = "9a556b48cf4f84a988ba520e6e9ec7389004f461173a8202c6dfb34528803749"
P_IZ_PINA = {
    PIN_H_STAR_995_4: RETIRED_NOSITEL,
    PIN_H_NOVYJ_995_5: NOSITELI / "p-4ac99af9.py",
}
ZHELANYE_P_KLETKA = ("pilot.yaml", "start.yaml", "rehearsal.yaml", "cmp-mob-002-tabs.yaml")
ZHIVYE_POTOKI_MAESTRO = (
    "vkhod-117-splash-vhod.yaml", "first-run-ekran.yaml", "erstinformation.yaml",
    "cmp-mob-004-start.yaml", "start.yaml", "rehearsal.yaml",
    "cmp-mob-002-tabs.yaml", "config.yaml",
)


def _ref_harness_h(wf):
    """ЭФФЕКТИВНЫЙ ref checkout-а path: .harness В МОМЕНТ ЗАПУСКА P — шага,
    чей run исполняет maestro_probe.py (в монолите android-e2e, в разделённом
    DAG e2e-pilot; quality проверяет пробы на СВОЁМ пине .harness — не путать).

    П1 (арбитраж 143-repin, обходы (а)/(а′) критика 2/2): запуск P единственен
    по ВСЕМ задачам — число шагов, чей run содержит литерал maestro_probe.py,
    РОВНО 1 и он в e2e-pilot (И-8: «РОВНО» четыре флоу, оракул «по одному
    разу»); иначе именованный отказ со списком job[индекс-шага] (второй запуск
    — в e2e-pilot или в другой задаче — красен). Ноль запусков — именованный
    отказ «P не исполняется этим workflow» (fail-closed).

    П2 (арбитраж 143-repin, обходы (б1)-(б3)): в шагах checkout ДО запуска P
    path сопоставляется по posixpath.normpath == '.harness' (алиасы ./.harness,
    .harness/, ./.harness/. — тот же каталог); нелитеральный path (содержит
    ${{, абсолютный, normpath начинается с '..') — «путь checkout неизмерим»
    (fail-closed: судья не знает, какой каталог перезаписал этот шаг).
    Checkout без path — корень workspace, не .harness, как и раньше.

    Несколько checkout одного каталога: судится ПОСЛЕДНИЙ до шага запуска —
    actions/checkout перезаписывает каталог, содержимое .harness при запуске P
    задаёт последний checkout этого path (вердикт критика 1/2: судья, берущий
    ПЕРВЫЙ ref, исполнял P v5 при подмене «хороший, затем плохой»). Checkout
    .harness ПОСЛЕ шага запуска P не влияет. Возврат (est, ref, otkaz):
    otkaz — именованный отказ П1/П2 (p01 красна им); est=False, otkaz=None —
    запуска P шагом нет либо до него нет ни одного checkout .harness;
    est=True, ref — эффективный ref (None = checkout без ref: ветка по
    умолчанию, пин неизмерим).

    НЕ ЗАЩИЩАЕТ (остаток арбитража 143-repin; ловцы — ревью cutover-PR со
    сверкой байтов с моделью (§Порядок п.2), адверсарий, живая приёмка п.4):
    запуск P без литерала maestro_probe.py в run (env-косвенность, обёртка,
    composite/reusable — замер «second P via env var path» rc 0), перезапись
    .harness shell-командами в run (rm/cp/git clone/curl) или действиями вне
    actions/checkout, живая семантика платформы (needs/if/concurrency).
    Полное отсутствие литерала — уже fail-closed (замер «literal hidden» →
    красна)."""
    zapuski = []
    for jname, j in wf.get("jobs", {}).items():
        for i, s in enumerate(j.get("steps") or []):
            if "maestro_probe.py" in (s.get("run") or ""):
                zapuski.append((jname, i))
    if not zapuski:
        return False, None, None
    spisok = ", ".join("%s[%d]" % (j, i) for j, i in zapuski)
    if len(zapuski) > 1:
        return False, None, ("запусков P %d: %s — И-8 требует ровно один "
                             "запуск P в e2e-pilot" % (len(zapuski), spisok))
    jname, zapusk_P = zapuski[0]
    if jname != "e2e-pilot":
        return False, None, ("запуск P не в e2e-pilot: %s — И-8 требует "
                             "единственный запуск P в e2e-pilot" % spisok)
    # П2 + эффективный checkout: последний checkout КАТАЛОГА .harness
    # (posixpath.normpath) до шага запуска P
    shagi = (wf.get("jobs", {}).get(jname) or {}).get("steps") or []
    ref = None
    for s in shagi[:zapusk_P]:
        if s.get("uses", "").startswith("actions/checkout"):
            w = s.get("with") or {}
            p = w.get("path")
            if p is None:
                continue  # checkout в корень workspace — не .harness
            if (not isinstance(p, str) or "${{" in p or p.startswith("/")
                    or posixpath.normpath(p).startswith("..")):
                return False, None, "путь checkout неизмерим: %s" % p
            if posixpath.normpath(p) == ".harness":
                ref = w.get("ref")
    return True, ref, None


def sud_P_nabor(subject_root, tmp):
    """p01-P-nabor (блокер 2): ИСПОЛНИТЕЛЬНЫЙ replay цепочки e2e-pilot —
    P (maestro_probe.py пина H) → ci-e2e.sh (S, зона 995) → подложный maestro,
    логирующий argv. Оракул: Maestro запрошен ТОЛЬКО флоу фиксированного набора
    P (И-8), по одному разу, при .maestro, содержащем флоу всех экранов.
    Перепин исполнен (freeze 995/5, ленд ffbbc99e7, H-пин 4ac99af9): клетка
    АКТИВНА. Измеряемый пин — ЭФФЕКТИВНЫЙ checkout .harness в момент запуска P
    (последний checkout этого path ДО шага запуска; дубль судится последним,
    checkout после запуска не влияет — вердикт критика 1/2; запуск P
    единственен по ВСЕМ задачам и в e2e-pilot — П1; path сопоставляется по
    posixpath.normpath, нелитеральный path неизмерим — П2; арбитраж
    143-repin) и судится по ИЗМЕРЕННЫМ байтам (P_IZ_PINA): старый пин
    66052cdf (frozen 995/4) — КРАСНАЯ ветка, replay носителем старых байтов
    (retired-нагрузка) доказывает rglob всего каталога исполнением;
    неизмеренный пин — красная именованная причина (батарея отвечает только
    за пины, чьи байты пинует)."""
    d = Path(subject_root)
    wf_p = d / ".github" / "workflows" / "mobile.yml"
    if not wf_p.is_file():
        return False, "SUBJECT_ABSENT"
    try:
        wf = yaml.safe_load(wf_p.read_text(encoding="utf-8"))
    except Exception as e:
        return False, "MOBILE_YML_NE_YAML: %s" % e
    ref_est, ref, otkaz = _ref_harness_h(wf)
    if otkaz is not None:
        return False, otkaz
    if not ref_est:
        return False, ("нет checkout .harness до шага запуска maestro_probe.py — "
                       "P не исполняется этим workflow")
    nositel_p = P_IZ_PINA.get(ref)
    if nositel_p is None:
        if ref is None:
            return False, ("checkout .harness без ref (ветка по умолчанию) — "
                           "пин неизмерим: измеренные пины — новый %s и "
                           "красный старый %s" % (
                               PIN_H_NOVYJ_995_5, PIN_H_STAR_995_4))
        return False, ("пин .harness %s не измерен батареей: 995/5 исполнен "
                       "(freeze 995/5, ленд ffbbc99e7), измеренные пины — "
                       "новый %s (P v5, фиксированный набор из manifest) и "
                       "красный старый %s (rglob, frozen 995/4)" % (
                           ref, PIN_H_NOVYJ_995_5, PIN_H_STAR_995_4))
    # активный replay по НОСИТЕЛЮ, измеренному для этого пина
    koren = Path(tmp)
    ws, env = postroj_pesochitsu(koren)
    repo = koren / "repo"
    maestro_dir = repo / "mobile" / ".maestro"
    maestro_dir.mkdir(parents=True, exist_ok=True)
    for imja in ZHIVYE_POTOKI_MAESTRO:
        (maestro_dir / imja).write_text("appId: com.complior.mobile\nname: %s\n---\n- launchApp:\n    clearState: true\n" % imja, encoding="utf-8")
    (repo / "mobile" / "scripts").mkdir(parents=True, exist_ok=True)
    shutil.copyfile(NOSITELI / "ci-e2e-995-4.sh", repo / "mobile" / "scripts" / "ci-e2e.sh")
    # карта СУБЪЕКТА в песочнице: пост-995-v5 P читает фиксированный набор из
    # manifest (mobile/ci-screens.json) — без карты replay ложно красен
    karta_subjekta = d / "mobile" / "ci-screens.json"
    if not karta_subjekta.is_file():
        return False, "у субъекта нет mobile/ci-screens.json — пост-995-v5 P читает набор из manifest"
    shutil.copyfile(karta_subjekta, repo / "mobile" / "ci-screens.json")
    hdir = koren / "harness" / "pilot_995"
    hdir.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(nositel_p, hdir / "maestro_probe.py")
    shutil.copyfile(NOSITELI / "pilot-66052cdf.yaml", hdir / "pilot.yaml")
    apk = koren / "app-release.apk"
    apk.write_bytes(b"ETALON-APK-143\n")
    kod = koren / "code"
    kod.write_text("SEKRET-143\n", encoding="utf-8")
    vyhod = koren / "maestro-out"
    env["MAESTRO_LOG"] = str(koren / "maestro_log.txt")
    Path(env["MAESTRO_LOG"]).write_text("", encoding="utf-8")
    try:
        r = subprocess.run(
            [sys.executable, str(hdir / "maestro_probe.py"), "--repo", str(repo),
             "--apk", str(apk), "--code-file", str(kod), "--out", str(vyhod),
             "--timeout", "90"],
            env=env, capture_output=True, text=True, timeout=200, cwd=str(koren))
    except subprocess.TimeoutExpired:
        return False, "TAJMAUT P"
    protokol = Path(env["MAESTRO_LOG"]).read_text(encoding="utf-8")
    zaprosy = [l for l in protokol.splitlines() if l.startswith("MAESTRO_POTOKI")]
    if not zaprosy:
        return False, "Maestro не вызван ни разу — свойство набора не доказано (P rc=%d, вывод: %s)" % (
            r.returncode, (r.stdout or r.stderr or "").strip()[:160])
    zaproscheno = []
    for z in zaprosy:
        zaproscheno.extend(z.split()[1:])
    if ref == PIN_H_STAR_995_4:
        # retired пин: replay ИСПОЛНИЛ старые байты — доказанный rglob всего
        # каталога (замер v3 пачки: 8 флоу) красен и после перепина
        return False, ("пин .harness 66052cdf (frozen 995/4): P копирует ВЕСЬ "
                       "каталог rglob-ом — Maestro запрошен %s, фиксированный "
                       "набор P (И-8) не исполняется; перепин на %s обязателен" % (
                           zaproscheno, PIN_H_NOVYJ_995_5))
    lishnie = sorted(set(zaproscheno) - set(ZHELANYE_P_KLETKA))
    nedostajut = sorted(set(ZHELANYE_P_KLETKA) - set(zaproscheno))
    if lishnie or nedostajut or len(zaproscheno) != len(set(zaproscheno)):
        return False, ("Maestro запрошен набор %s — вне фиксированного набора P: "
                       "лишние %s, без повторов %s, дубли %d" % (
                           zaproscheno, lishnie, nedostajut,
                           len(zaproscheno) - len(set(zaproscheno))))
    return True, ""


# --- Y-ось: статический судья DAG -------------------------------------------------

def text_joba(wf, job):
    return json.dumps(wf.get("jobs", {}).get(job, {}), ensure_ascii=False)


def vse(gen):
    for ok, prichina in gen:
        if not ok:
            return False, prichina
    return True, ""


def sud_sobytija(wf, rep):
    on = wf.get(True) or wf.get("true") or wf.get("on") or {}
    if isinstance(on, str):
        return False, "on — строка"
    if "pull_request" not in on:
        return False, "нет pull_request"
    pr = on.get("pull_request")
    if isinstance(pr, dict) and (pr.get("paths") or pr.get("branches-ignore")):
        return False, "pull_request несёт paths-фильтр (required-агрегат обязан появляться на каждом PR)"
    if "schedule" not in on or "workflow_dispatch" not in on:
        return False, "нет schedule/dispatch"
    if "workflow_run" in on:
        return False, "workflow_run жив"
    if rep is not None and (Path(rep) / RETRY_REL).exists():
        return False, "mobile-e2e-retry.yml жив (139 не выведен)"
    return True, ""


def sud_apk(wf, rep=None):
    build = wf.get("jobs", {}).get("build-apk", {})
    outs = build.get("outputs") or {}
    if not all(k in outs for k in ("apk_sha256", "artifact_name", "run_id")):
        return False, "build-apk без outputs идентичности"
    if not any("Идентичность сборки" in (s.get("name") or "") for s in build.get("steps", [])):
        return False, "нет шага идентичности сборки"
    for j in RABOTNIKI:
        text = text_joba(wf, j)
        if '"IMJA_ARTEFAKTA": "${{ needs.build-apk.outputs.artifact_name }}"' not in text:
            return False, "%s не берёт артефакт по имени из outputs сборки" % j
        if "APK_DIGEST_RASKHOZHDENIE" not in text:
            return False, "%s не сверяет digest до установки" % j
        if "Идентичность прогона работника" not in text:
            return False, "%s без outputs идентичности" % j
    return True, ""


def sud_avd(wf, rep=None):
    porty = {}
    for j in RABOTNIKI:
        text = text_joba(wf, j)
        m = re.findall(r"PORT=(\d+)", text)
        if j == "e2e-pilot":
            # namespace эмулятора pilot — ВНУТРИ ci-e2e.sh (S, зона 995, пин
            # батареей 995); YAML задачи портов не задаёт и не конфликтует
            if "PORT=" in text or 'AVD="ci' in text:
                return False, "%s сам определяет порт/AVD (владелец — ci-e2e.sh)" % j
            porty[j] = "S:5560"
            continue
        if not m:
            return False, "%s без PORT" % j
        porty[j] = m[0]
    if len(set(porty.values())) != len(porty):
        return False, "порты работников совпадают: %s" % porty
    for j in RABOTNIKI:
        text = text_joba(wf, j)
        for line in text.split("\\n"):
            if "pkill" in line and "$AVD" not in line:
                return False, "%s: широкий pkill: %s" % (j, line[:90])
        if "kill-server" in text:
            return False, "%s: adb kill-server" % j
    return True, ""


def sud_povtory(wf, rep=None):
    limity = {"e2e-splash": 1, "e2e-first-run": 1, "e2e-erstinformation": 1, "e2e-start": 1, "e2e-pilot": 0}
    for j, lim in limity.items():
        n = text_joba(wf, j).count('ПОВТОР: ')
        if n != lim:
            return False, "%s: маркеров ПОВТОР %d, канон %d" % (j, n, lim)
    return True, ""


def sud_jest(wf, rep=None):
    text = text_joba(wf, "e2e-erstinformation")
    if "npm test -- --json" not in text:
        return False, "нет same-job session-Jest"
    poz_jest = text.find("npm test -- --json")
    poz_val = text.find("118 erstinformation")
    if not (0 <= poz_jest < poz_val):
        return False, "Jest-отчёт не ДО checker"
    return True, ""


def sud_h(wf, rep=None):
    trebuyutsja = {"e2e-splash": [".harness123"], "e2e-first-run": [".harness135", ".harness123"],
                   "e2e-erstinformation": [".harness118", ".harness123"], "e2e-pilot": [".harness"]}
    for j, puti in trebuyutsja.items():
        text = text_joba(wf, j)
        for p in puti:
            if ('"path": "%s"' % p) not in text and ("path: %s" % p) not in text:
                return False, "%s без checkout %s" % (j, p)
    return True, ""


def sud_signal(wf, rep=None):
    sig = wf.get("jobs", {}).get("mobile-regression-signal", {})
    ag = wf.get("jobs", {}).get("android-e2e", {})
    if "schedule" not in (sig.get("if") or "") or "workflow_dispatch" not in (sig.get("if") or ""):
        return False, "сигнал не ограничен schedule/dispatch"
    if "schedule" in (ag.get("if") or ""):
        return False, "required-агрегат гоняет ночь"
    for j in wf.get("jobs", {}).values():
        if "mobile-regression-signal" in (j.get("needs") or []):
            return False, "сигнал — чья-то зависимость"
    return True, ""


class GrammatikaVneAlfavita(Exception):
    pass


_TOKENY_RE = re.compile(r"""
    \s*(?:
      (?P<str>'[^']*')
    | (?P<op>&&|\|\||==|!=|\(|\)|,)
    | (?P<ident>[A-Za-z_][A-Za-z0-9_.]*)
    )""", re.VERBOSE)

_KONTEKSTY_995 = {"github.event_name", "github.event.number", "github.sha", "github.ref"}


def _leks(text):
    toks = []
    pos = 0
    while pos < len(text):
        m = _TOKENY_RE.match(text, pos)
        if not m or m.end() == pos:
            if text[pos:].strip() == "":
                break
            raise GrammatikaVneAlfavita(text[pos:pos + 20])
        pos = m.end()
        if m.group("str") is not None:
            toks.append(("str", m.group("str")[1:-1]))
        elif m.group("op") is not None:
            toks.append(("op", m.group("op")))
        else:
            toks.append(("ident", m.group("ident")))
    toks.append(("konec", ""))
    return toks


def _vychisli(toks, znach, i=0):
    """or := and ('||' and)*; and := eq ('&&' eq)*; eq := atom (('=='|'!=') atom)?;
    atom := '(' or ')' | str | format(...) | контекст. Семантика ГитХаба:
    && возвращает первый ложный либо последний операнд; || — первый истинный
    либо последний. Возвращает (значение, индекс_после)."""
    def istinno(v):
        return v if isinstance(v, bool) else v != ""

    def atom(i):
        vid, zn = toks[i]
        if vid == "op" and zn == "(":
            v, i = expr(i + 1, 0)
            if toks[i] != ("op", ")"):
                raise GrammatikaVneAlfavita("нет )")
            return v, i + 1
        if vid == "str":
            return zn, i + 1
        if vid == "ident":
            if zn == "format":
                if toks[i + 1] != ("op", "("):
                    raise GrammatikaVneAlfavita("format без (")
                sharder = toks[i + 2]
                if sharder[0] != "str":
                    raise GrammatikaVneAlfavita("format без литерала")
                shablon = sharder[1]
                j = i + 3
                args = []
                while toks[j] == ("op", ","):
                    v, j = atom(j + 1)
                    if not isinstance(v, str):
                        raise GrammatikaVneAlfavita("аргумент format не строка")
                    args.append(v)
                if toks[j] != ("op", ")"):
                    raise GrammatikaVneAlfavita("format без )")
                vyh = shablon
                for n, a in enumerate(args):
                    vyh = vyh.replace("{%d}" % n, a)
                return vyh, j + 1
            if zn in _KONTEKSTY_995:
                # семантика ГитХаба: у ИЗВЕСТНОГО контекста нет значения в этом
                # событии (github.event.number на push) — null, в строковом
                # контексте ''; грамматика закрыта списком имён (опечатка — краш)
                return znach.get(zn, ""), i + 1
            raise GrammatikaVneAlfavita("неизвестный идентификатор %s" % zn)
        raise GrammatikaVneAlfavita("не атом: %r" % (toks[i],))

    def eq(i):
        lev, i = atom(i)
        while toks[i][0] == "op" and toks[i][1] in ("==", "!="):
            op = toks[i][1]
            prav, i = atom(i + 1)
            if not isinstance(lev, type(prav)) and not isinstance(prav, type(lev)):
                raise GrammatikaVneAlfavita("сравнение разных типов")
            lev = (lev == prav) if op == "==" else (lev != prav)
        return lev, i

    def expr(i, _):
        # семантика ГитХаба: a && b — a ложно ⇒ a, иначе b; a || b — a истинно
        # ⇒ a, иначе b (операнды разбираются оба, результат — по истинности)
        lev, i = eq(i)
        while toks[i][0] == "op" and toks[i][1] in ("&&", "||"):
            op = toks[i][1]
            prav, i = eq(i + 1)
            if op == "&&":
                lev = lev if not istinno(lev) else prav
            else:
                lev = lev if istinno(lev) else prav
        return lev, i

    return expr(i, 0)


def vychisli_vyrazhenie(text, znach):
    if isinstance(text, bool):
        return text
    t = text.strip()
    if t.startswith("${{") and t.endswith("}}"):
        t = t[3:-2]
    toks = _leks(t)
    v, i = _vychisli(toks, znach)
    if toks[i] != ("konec", ""):
        raise GrammatikaVneAlfavita("хвост после выражения: %r" % (toks[i:],))
    return v


def sud_concurrency(wf, rep=None):
    """y21-concurrency (блокер 4): семантика concurrency по ЖИВОМУ mobile.yml
    #124 — `group: mobile-${{ github.ref }}`, `cancel-in-progress: true`
    БЕЗУСЛОВНО (ночь делит группу с push-ами в main и отменяется ими). Канон
    143: PR-группа mobile-pr-<номер> с отменой ТОЛЬКО pull_request; ночь и
    диспетч — отдельные группы БЕЗ отмены; push/прочее — mobile-<ref> без
    отмены. Судит ЗАКРЫТЫМ алфавитом выражений (неизвестный синтаксис — красно)."""
    kon = wf.get("concurrency")
    if not isinstance(kon, dict) or "group" not in kon or "cancel-in-progress" not in kon:
        return False, "нет блока concurrency group/cancel-in-progress"
    gruppa, cancel = kon["group"], kon["cancel-in-progress"]
    sobytija = [
        ("pull_request", {"github.event_name": "pull_request", "github.event.number": "7",
                          "github.ref": "refs/pull/7/merge", "github.sha": "e" * 40},
         "mobile-pr-7", True),
        ("push", {"github.event_name": "push", "github.ref": "refs/heads/main",
                  "github.sha": "d" * 40},
         "mobile-refs/heads/main", False),
        ("schedule", {"github.event_name": "schedule", "github.ref": "refs/heads/main",
                      "github.sha": "c" * 40},
         "mobile-nightly", False),
        ("workflow_dispatch", {"github.event_name": "workflow_dispatch",
                               "github.ref": "refs/heads/main", "github.sha": "b" * 40},
         "mobile-dispatch-" + "b" * 40, False),
    ]
    vychislennye = []
    for imja, znach, ozh_g, ozh_c in sobytija:
        try:
            g = vychisli_vyrazhenie(gruppa, znach)
            c = vychisli_vyrazhenie(cancel, znach)
        except GrammatikaVneAlfavita as e:
            return False, "грамматика concurrency вне канона (%s): %s" % (imja, e)
        if g != ozh_g:
            return False, "группа при %s: %r ≠ %r" % (imja, g, ozh_g)
        c_b = c if isinstance(c, bool) else (c in (True, "true"))
        if c_b != ozh_c:
            return False, "cancel-in-progress при %s: %r ≠ %r" % (imja, c, ozh_c)
        vychislennye.append(g)
    if len(set(vychislennye)) != len(vychislennye):
        return False, "группы пересекаются: %s" % vychislennye
    return True, ""

# 143 (Fix143c): git-команды, меняющие рабочее дерево либо источник дерева,
# — красны в run-шагах build-apk до конца задачи. Форма — «git» плюс
# произвольные ведущие токены-флаги (ловит «git -C <dir> checkout»,
# «git --work-tree=<путь> reset», «git fetch origin main && …»), затем
# глагол класса; читающий rev-parse/Status токенами глаголом не становится.
GIT_MENJAET_DEREVO = re.compile(
    r"\bgit\b(?:\s+\S+)*?\s+"
    r"(checkout|switch|restore|reset|clean|fetch|pull|merge|rebase|stash)\b")


def sud_provodka(wf, rep=None):
    """y19-outputs-provodka (блокер 3, структурная нога; адверсарий 1/2 +
    критик Crit143x — source provenance сборки): id шага идентичности,
    job-level outputs работников (ровно три ключа через
    steps.ident.outputs.*), эталон build-apk, ИСПОЛНЯЕМАЯ
    последовательность его шагов ЦЕЛИКОМ (Fix143c: позиция 0 —
    единственный checkout с замкнутым алфавитом with
    persist-credentials/clean, БЕЗ ref/repository/path; позиция 1 —
    test-сверка фактического HEAD с $GITHUB_SHA до source-consuming
    шагов; далее до конца задачи — ни второго checkout, ни действия вне
    алфавита, ни git-команды, меняющей рабочее дерево: npm ci/prebuild на
    подменённом/остаточном workspace = сборка чужой ревизии при честном
    digest), и checkout (persist-credentials: false) в ОБОИХ
    агрегирующих задачах ДО шага запуска ci-aggregate.cjs."""
    kjuchi = ("apk_sha256", "artifact_name", "run_id")
    build = wf.get("jobs", {}).get("build-apk", {})
    if sorted((build.get("outputs") or {}).keys()) != sorted(kjuchi):
        return False, "outputs build-apk: %s" % sorted((build.get("outputs") or {}).keys())
    if not any(s.get("id") == "ident" for s in build.get("steps") or []):
        return False, "у шага идентичности сборки нет id"
    # 143 (Fix143c, содержательный FAIL критика Crit143x — «литерал на
    # месте, исполняемое иное»): судится ИСПОЛНЯЕМАЯ последовательность
    # шагов build-apk ЦЕЛИКОМ, а не наличие checkout среди шагов — checkout
    # с ref: чужой ревизии и второй checkout после правильного первого
    # проходили батарею 69/69. Закрывающее свойство (адверсарий 1/2):
    # позиция 0 — ЕДИНСТВЕННЫЙ actions/checkout проверяемого дерева
    # (замкнутый алфавит with: persist-credentials/clean — ref/repository/
    # path меняют проверяемое дерево, иные ключи не заявлены), позиция 1 —
    # сверка фактического HEAD с $GITHUB_SHA ДО любого шага, читающего
    # дерево, далее до конца задачи — ни checkout, ни действия вне
    # замкнутого алфавита (setup-node/upload-artifact), ни git-команда,
    # меняющая рабочее дерево (после сборки checkout с clean снесёт и
    # артефакт, и идентичность).
    shagi_build = build.get("steps") or []
    if not shagi_build or not (shagi_build[0].get("uses") or "").startswith("actions/checkout"):
        return False, ("build-apk: сборка без checkout продукта первым шагом (needs не "
                       "переносит checkout и не закрепляет runner — переиспользуемый "
                       "раннер собирает остаточный workspace старой ревизии)")
    w_build = shagi_build[0].get("with") or {}
    chuzhoe_derevo = {"ref": "чужая ревизия вместо проверяемой",
                      "repository": "чужое дерево",
                      "path": "дерево вне workspace сборки"}
    for kljuch in sorted(set(w_build) & set(chuzhoe_derevo)):
        return False, ("build-apk: checkout с %s: %r — %s (позиция 0)"
                       % (kljuch, w_build[kljuch], chuzhoe_derevo[kljuch]))
    lishnie_kljuchi = sorted(set(w_build) - {"persist-credentials", "clean"})
    if lishnie_kljuchi:
        return False, ("build-apk: ключи with checkout вне замкнутого алфавита "
                       "(persist-credentials/clean): %s (позиция 0)" % lishnie_kljuchi)
    if w_build.get("persist-credentials") is not False:
        return False, "build-apk: checkout без persist-credentials: false (позиция 0)"
    if w_build.get("clean") is not True:
        return False, ("build-apk: checkout без clean: true — остатки старого дерева "
                       "выживают (позиция 0)")
    if len(shagi_build) < 2 or not shagi_build[1].get("run"):
        return False, ("build-apk: нет сверки HEAD == $GITHUB_SHA сразу после checkout "
                       "(позиция 1) — APK может быть собран не из $GITHUB_SHA")
    sverka = False
    for stroka in str(shagi_build[1].get("run")).splitlines():
        stroka = stroka.strip()
        if ((stroka.startswith("test ") or stroka.startswith("[ "))
                and "git rev-parse HEAD" in stroka and '"$GITHUB_SHA"' in stroka):
            sverka = True
    if not sverka:
        return False, ("build-apk: шаг 1 не сверяет фактический HEAD с $GITHUB_SHA — "
                       "нужна test-команда с операндами \"$(git rev-parse HEAD)\" и "
                       "\"$GITHUB_SHA\" в одной команде (позиция 1)")
    for n, s in enumerate(shagi_build):
        dejstvie = str(s.get("uses") or "")
        if n >= 2 and dejstvie.startswith("actions/checkout"):
            return False, ("build-apk: второй checkout (позиция %d) подменяет рабочее "
                           "дерево сборки" % n)
        if (n >= 2 and dejstvie
                and dejstvie not in ("actions/setup-node@v7", "actions/upload-artifact@v7")):
            return False, ("build-apk: действие %r вне замкнутого алфавита build-apk "
                           "(checkout/setup-node/upload-artifact) — позиция %d"
                           % (dejstvie, n))
        m_git = GIT_MENJAET_DEREVO.search(str(s.get("run") or ""))
        if m_git:
            return False, ("build-apk: run-шаг меняет рабочее дерево git-командой "
                           "«git … %s» (позиция %d)" % (m_git.group(1), n))
    for j in RABOTNIKI:
        job = wf.get("jobs", {}).get(j, {})
        outs = job.get("outputs") or {}
        if sorted(outs.keys()) != sorted(kjuchi):
            return False, "%s без job-level outputs (получено %s)" % (j, sorted(outs.keys()))
        for k in kjuchi:
            if outs.get(k) != "${{ steps.ident.outputs.%s }}" % k:
                return False, "%s: outputs.%s = %r (не из шага ident)" % (j, k, outs.get(k))
        id_shagi = [s.get("id") for s in job.get("steps") or []]
        if "ident" not in id_shagi:
            return False, "%s: шаг идентичности без id: ident (GITHUB_OUTPUT без id не попадает в needs)" % j
        shag = next(s for s in job.get("steps") or [] if s.get("id") == "ident")
        if "Идентичность прогона работника" not in (shag.get("name") or ""):
            return False, "%s: id ident не на шаге идентичности" % j
    for j in ("android-e2e", "mobile-regression-signal"):
        shagi = wf.get("jobs", {}).get(j, {}).get("steps") or []
        poz_checkout = poz_skript = None
        for n, s in enumerate(shagi):
            if s.get("uses", "").startswith("actions/checkout") and (s.get("with") or {}).get("persist-credentials") is False:
                poz_checkout = n
            if "ci-aggregate.cjs" in (s.get("run") or ""):
                poz_skript = n
        if poz_checkout is None:
            return False, "%s: агрегат без checkout (скрипта на чистом раннере нет)" % j
        if poz_skript is None or poz_checkout > poz_skript:
            return False, "%s: checkout (%s) не до запуска скрипта (%s)" % (j, poz_checkout, poz_skript)
    return True, ""


def sud_tojson_needs(wf, rep=None, subject_root=None, tmp=None):
    """y20-tojson-needs (блокер 3, поведенческая нога): replay СЕМАНТИКИ
    ГитХаба — toJSON(needs) собирается ПО workflow-субъекту (selected=e2e-start
    success, служебные success, остальные skipped+причина), outputs работника
    рендерятся как ГитХаб: шаг С id пишет GITHUB_OUTPUT (шаг ИСПОЛНЯЕТСЯ в
    песочнице), шаг БЕЗ id / без job.outputs даёт пустые строки — и этот
    needs-контекст подаётся в НАСТОЯЩИЙ ci-aggregate.cjs: зелёный required
    возможен только при честной проводке outputs."""
    d = Path(subject_root)
    agg = d / "mobile" / "scripts" / "ci-aggregate.cjs"
    if not agg.is_file():
        return False, "SUBJECT_ABSENT"
    for j in AGREGAT_NEEDS | {"android-e2e"}:
        if j not in wf.get("jobs", {}):
            return False, "нет задачи %s" % j
    podtmp = Path(tmp) / "tojson-needs"
    podtmp.mkdir(exist_ok=True)
    ws, env = postroj_pesochitsu(podtmp)
    digest = hashlib.sha256(b"ETALON-APK-143\n").hexdigest()
    sborka = {"apk_sha256": digest, "artifact_name": "apk-4242-" + digest[:12], "run_id": "4242"}
    znach = konteksty_rendera(ws, sborka, set((wf.get("jobs", {}).get("e2e-start") or {}).get("needs") or []))
    apk_dir = ws / "mobile" / "android" / "app" / "build" / "outputs" / "apk" / "release"
    apk_dir.mkdir(parents=True, exist_ok=True)
    (apk_dir / "app-release.apk").write_bytes(b"ETALON-APK-143\n")
    # шаг идентичности e2e-start ИСПОЛНЯЕТСЯ (если у него есть id)
    shagovye_outputs = {}
    job = wf["jobs"]["e2e-start"]
    shag = next((s for s in job.get("steps") or [] if s.get("id") == "ident"), None)
    if shag is not None and shag.get("run"):
        try:
            skript = render_vyrazhenij(shag["run"], znach)
            wd = render_vyrazhenij(shag.get("working-directory") or "${{ github.workspace }}", znach)
        except RenderVneAlfavita as e:
            return False, "РЕНДЕР_ВНЕ_АЛФАВИТА: %s" % e
        if not Path(wd).is_dir():
            return False, "working-directory %s вне песочницы" % wd
        gh_out = podtmp / "gh-output.txt"
        gh_out.write_text("", encoding="utf-8")
        env_sh = dict(env)
        env_sh["GITHUB_OUTPUT"] = str(gh_out)
        rc, out, err = _ispolni_shag(skript, Path(wd), env_sh)
        if rc != 0:
            return False, "шаг идентичности e2e-start rc=%d: %s" % (rc, (err or "")[-160:])
        for line in gh_out.read_text(encoding="utf-8").splitlines():
            if "=" in line:
                k, v = line.split("=", 1)
                shagovye_outputs[k] = v
    # рендер job-outputs ПО СЕМАНТИКЕ ГитХаба: выражение из steps.<id>.outputs.<k>
    # разрешимо ТОЛЬКО если шаг с таким id существует и опубликовал ключ
    vyhody = {}
    for k, vyrazhenie in (job.get("outputs") or {}).items():
        m = re.fullmatch(r"\$\{\{ steps\.([A-Za-z0-9_-]+)\.outputs\.([A-Za-z0-9_-]+) \}\}", vyrazhenie or "")
        if m and m.group(1) in {s.get("id") for s in job.get("steps") or []}:
            vyhody[k] = shagovye_outputs.get(m.group(2), "")
        else:
            vyhody[k] = ""
    vybor = {"selected": [{"id": "start", "job": "e2e-start", "reason": "AFFECTED"}],
             "excluded": [{"id": i, "job": "e2e-" + i, "reason": "NOT_SELECTED"}
                          for i in ("splash", "first-run", "erstinformation", "pilot")]}
    needs = {
        "select-screens": {"result": "success",
                           "outputs": {"selection": json.dumps(vybor, ensure_ascii=False)}},
        "quality": {"result": "success", "outputs": {}},
        "build-apk": {"result": "success", "outputs": sborka},
        "e2e-start": {"result": "success", "outputs": vyhody},
    }
    for j in RABOTNIKI:
        if j != "e2e-start":
            needs[j] = {"result": "skipped", "outputs": {}}
    f = podtmp / "needs.json"
    f.write_text(json.dumps(needs, ensure_ascii=False), encoding="utf-8")
    try:
        r = subprocess.run(["node", str(agg), "--needs", str(f)],
                           capture_output=True, text=True, timeout=60)
    except subprocess.TimeoutExpired:
        return False, "TAJMAUT агрегата"
    if r.returncode != 0 or "AGREGAT_OK" not in r.stdout:
        return False, "needs-контекст по семантике ГитХаба красит агрегат: %s" % (r.stdout + r.stderr).strip()[:160]
    return True, ""


def sud_needs_rabotnikov(wf, rep=None):
    """y22-needs-rabotnikov (арбитраж 143 Б2): needs каждого работника —
    РОВНО {select-screens, build-apk}: без ребра к сборке работник не видит
    её outputs (артефакт/digest недоступны), соседний работник в needs —
    последовательная зависимость экранов, ломающая разделение и независимые
    эмуляторы; рендер needs.<job>.outputs.* вне needs задачи невозможен
    (konteksty_rendera) — a17/y20 краснеют ИСПОЛНЕНИЕМ на этом же мутанте."""
    problemy = []
    for j in RABOTNIKI:
        n = (wf.get("jobs", {}).get(j) or {}).get("needs")
        if isinstance(n, str):
            n = [n]
        if set(n or []) != {"select-screens", "build-apk"}:
            problemy.append("%s: needs %s" % (j, n))
    return (not problemy, "; ".join(problemy))


KLETKI_Y = [
    ("y01-nabor-jobs", lambda wf, rep: (set(wf.get("jobs", {})) == set(CANON_JOBS),
                                        "jobs %s" % sorted(wf.get("jobs", {})))),
    ("y02-agregat-needs", lambda wf, rep: (
        set(wf.get("jobs", {}).get("android-e2e", {}).get("needs") or []) == AGREGAT_NEEDS,
        "needs агрегата %s" % (wf.get("jobs", {}).get("android-e2e", {}).get("needs"),))),
    ("y03-agregat-if-always", lambda wf, rep: (
        (wf.get("jobs", {}).get("android-e2e", {}).get("if") or "").startswith("always()"),
        "if агрегата %r" % wf.get("jobs", {}).get("android-e2e", {}).get("if"))),
    ("y04-net-if-false", lambda wf, rep: (not any(
        j.get("if") in (False, "false") or any(s.get("if") in (False, "false") for s in j.get("steps", []))
        for j in wf.get("jobs", {}).values()), "есть if:false")),
    ("y05-net-continue-on-error", lambda wf, rep: (not any(
        j.get("continue-on-error") or any(s.get("continue-on-error") for s in j.get("steps", []))
        for j in wf.get("jobs", {}).values()), "есть continue-on-error")),
    ("y06-net-strategii", lambda wf, rep: (
        not any("strategy" in j for j in wf.get("jobs", {}).values()), "есть strategy")),
    ("y07-uslovija-rabotnikov", lambda wf, rep: vse(
        (wf.get("jobs", {}).get(j, {}).get("if") == "needs.select-screens.outputs['%s'] == 'true'" % j,
         "if %s: %r" % (j, wf.get("jobs", {}).get(j, {}).get("if"))) for j in RABOTNIKI)),
    ("y08-tajmauty", lambda wf, rep: vse(
        list((wf.get("jobs", {}).get(j, {}).get("timeout-minutes") == 40, "timeout %s" % j) for j in RABOTNIKI) +
        [(wf.get("jobs", {}).get("android-e2e", {}).get("timeout-minutes") == 5, "timeout агрегата")])),
    ("y09-sobytija-i-net-139", sud_sobytija),
    ("y10-rabotniki-na-pule", lambda wf, rep: vse(
        (wf.get("jobs", {}).get(j, {}).get("runs-on") == ["self-hosted", "linux", "x64", "kvm", "complior"],
         "runs-on %s: %s" % (j, wf.get("jobs", {}).get(j, {}).get("runs-on"))) for j in RABOTNIKI)),
    ("y11-apk-identichnost", sud_apk),
    ("y12-avd-namespace", sud_avd),
    ("y13-odin-uroven-vosstanovlenija", sud_povtory),
    ("y14-jest-118", sud_jest),
    ("y15-h-checkouty", sud_h),
    ("y16-noch-polnyj-nabor", lambda wf, rep: (
        "schedule) MODE=schedule" in text_joba(wf, "select-screens"), "селектор не знает schedule")),
    ("y17-noch-ne-required", sud_signal),
    ("y18-marker-nochi", lambda wf, rep: (
        any(s.get("name", "").startswith("Маркер полной регрессии")
            for s in wf.get("jobs", {}).get("mobile-regression-signal", {}).get("steps", [])),
        "нет маркера ночи")),
    ("y19-outputs-provodka", sud_provodka),
    ("y21-concurrency", sud_concurrency),
    ("y22-needs-rabotnikov", sud_needs_rabotnikov),
]


# --- F-ось: карта/потоки ------------------------------------------------------------

def sudji_f(karta_text):
    m = json.loads(karta_text)
    vyp = []
    nabor = m.get("integracija", {}).get("fiksirovannyj_nabor") or []
    vyp.append(("f01-fiksirovannyj-nabor-P", nabor == P_NABOR, "P-набор %s" % nabor))
    vl = {}
    for e in m.get("ekrany", []):
        for f in e.get("flows") or []:
            vl.setdefault(f, []).append(e["id"])
    for f in nabor:
        if f != "pilot.yaml":
            vl.setdefault(f, []).append("pilot")
    dvoinye = {f: v for f, v in vl.items() if len(v) > 1}
    vyp.append(("f02-vladenie-potokami", not dvoinye, "двойное владение %s" % dvoinye))
    statusy = [(e["id"], e["status"]) for e in m.get("ekrany", [])]
    ok_statusy = all(s in ("approved", "in-development") for _, s in statusy)
    bez_vhoda = [e["id"] for e in m.get("ekrany", [])
                 if e["status"] == "in-development" and not (e.get("flows") or e.get("pack") or e.get("legacy_entrypoint"))]
    vyp.append(("f04-statusy-i-vhody", ok_statusy and not bez_vhoda,
                "статусы/входы: %s %s" % (statusy, bez_vhoda)))
    paki = sorted(e["pack"] for e in m.get("ekrany", []) if e.get("pack"))
    vyp.append(("f03-paki-v-karte", all(p.startswith("mobile/e2e-") and p.endswith("/") for p in paki),
                "паки %s" % paki))
    return vyp


try:
    KLETKI_F = [imja for imja, _, _ in sudji_f(KARTA_HEAD)]
except Exception:
    KLETKI_F = None  # битая карта: zhestkij_kanon уже отказал rc 2 ДО клеток


# --- исполнение одной клетки ---------------------------------------------------------

def odna_kletka(imja, subject_root, vrem):
    d = Path(subject_root)
    sel = d / "mobile" / "scripts" / "select-ci-screens.cjs"
    agg = d / "mobile" / "scripts" / "ci-aggregate.cjs"
    karta = d / "mobile" / "ci-screens.json"
    wf_p = d / ".github" / "workflows" / "mobile.yml"
    kletki_dir = Path(vrem) / "kletki"
    kletki_dir.mkdir(exist_ok=True)
    tmp = tempfile.mkdtemp(prefix="k143-", dir=str(kletki_dir))
    try:
        if imja in SCENARII_S:
            if not sel.is_file():
                return False, "SUBJECT_ABSENT"
            return sudja_s(sel, SCENARII_S[imja]["sc"], SCENARII_S[imja]["ozh"], tmp)
        if imja == "a17-digest-do-ustanovki":
            return sud_digest_replej(d, tmp)
        if imja == "p01-P-nabor":
            return sud_P_nabor(d, tmp)
        if imja in SCENARII_A:
            if not agg.is_file():
                return False, "SUBJECT_ABSENT"
            needs, ozh_rc, ozh_imja = SCENARII_A[imja]
            return sudja_a(agg, needs, ozh_rc, ozh_imja, tmp)
        if imja.startswith("y"):
            if not wf_p.is_file():
                return False, "SUBJECT_ABSENT"
            try:
                wf = yaml.safe_load(wf_p.read_text(encoding="utf-8"))
            except Exception as e:
                return False, "MOBILE_YML_NE_YAML: %s" % e
            if imja == "y20-tojson-needs":
                try:
                    return sud_tojson_needs(wf, str(d), subject_root=d, tmp=tmp)
                except Exception as e:
                    return False, "ISKLJUCHENIE %s" % e
            for imja_y, f in KLETKI_Y:
                if imja_y == imja:
                    try:
                        return f(wf, str(d))
                    except Exception as e:
                        return False, "ISKLJUCHENIE %s" % e
            return False, "неизвестная y-клетка"
        if imja in KLETKI_F:
            if not karta.is_file():
                return False, "SUBJECT_ABSENT"
            for imja_f, ok, prichina in sudji_f(karta.read_text(encoding="utf-8")):
                if imja_f == imja:
                    return ok, prichina
        return False, "неизвестная клетка"
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


# --- стабы ---------------------------------------------------------------------------


def progony_stabov(vremennyj):
    src = json.loads(SOURCE.read_text(encoding="utf-8"))
    vh = src.get("stab_vhod") or {}
    staby = sorted(STABS.glob("stab_*.py"), key=lambda p: p.stem)
    obyavlenno = sorted(vh.keys())
    if [p.stem for p in staby] != obyavlenno:
        return -1, 0, ["рассинхрон stabs/ ↔ stab_vhod: %s" % obyavlenno]
    svjazi = 0
    zhivye = []
    for st in staby:
        cel = Path(vremennyj) / ("stub-" + st.stem)
        if cel.exists():
            shutil.rmtree(cel)
        shutil.copytree(MODEL, cel)
        r = subprocess.run([sys.executable, str(st), str(cel)], capture_output=True, text=True, timeout=60)
        if r.returncode != 0:
            return -1, svjazi, ["%s: мутатор rc=%d %s" % (st.stem, r.returncode, r.stderr.strip()[:120])]
        for imja_kletki in vh.get(st.stem) or []:
            svjazi += 1
            ok, _ = odna_kletka(imja_kletki, cel, vremennyj)
            if ok is None:
                zhivye.append("%s не судится на входе %s (клетка отложена — стаб не пойман)" % (st.stem, imja_kletki))
            elif ok:
                zhivye.append("%s прошёл вход %s" % (st.stem, imja_kletki))
    return len(staby), svjazi, zhivye


# --- главная ---------------------------------------------------------------------------

def glavnaja():
    rezhim = None
    repo = None
    args = sys.argv[1:]
    i = 0
    while i < len(args):
        if args[i] == "--model":
            rezhim = "model"
        elif args[i] in ("--stabs", "--matrix"):
            rezhim = "stabs"
        elif args[i] == "--repo":
            repo = args[i + 1]
            i += 1
        else:
            print("NEIZVESTNYJ_ARGUMENT: %s" % args[i], file=sys.stderr)
            return 2
        i += 1
    if shutil.which("node") is None:
        print("NOT_IMPLEMENTED: нет node", file=sys.stderr)
        return 2
    try:
        src = json.loads(SOURCE.read_text(encoding="utf-8"))
    except Exception as e:
        return oshibka_orakula("source.json: %s" % e)
    prog = zhestkij_kanon(src)
    if prog:
        return oshibka_orakula(prog)
    sobiraem_s()
    sobiraem_a()
    vse_kletki = (list(SCENARII_S) + list(SCENARII_A) + ["a17-digest-do-ustanovki"] +
                  [k[0] for k in KLETKI_Y if k[0] != "y20-tojson-needs"] + ["y20-tojson-needs"] +
                  KLETKI_F + ["p01-P-nabor"])
    obyavlennye = [k["id"] for k in src["kletki"]]
    if sorted(obyavlennye) != sorted(vse_kletki):
        return oshibka_orakula("source.json kletki ≠ клетки движка: лишние %s отсутствуют %s" % (
            sorted(set(obyavlennye) - set(vse_kletki)), sorted(set(vse_kletki) - set(obyavlennye))))
    for st, kj in (src.get("stab_vhod") or {}).items():
        for k in kj:
            if k not in set(vse_kletki):
                return oshibka_orakula("привязка стаба %s к неизвестной клетке %s" % (st, k))
    nuzhen_precedent = set()  # перепин исполнен (995/5): отложенных клеток нет
    flagi = {k["id"]: k.get("needs_precedent") for k in src["kletki"]}
    ozhidajut = {i for i, f in flagi.items() if f}
    if ozhidajut != nuzhen_precedent:
        return oshibka_orakula("needs_precedent флаги ≠ движок: %s" % sorted(ozhidajut))

    vrem = tempfile.mkdtemp(prefix="mob-ci-143-")
    try:
        if rezhim in ("model", "stabs"):
            subject = MODEL
        elif repo:
            subject = Path(repo).resolve()
            if not (subject / ".git").exists() and not (subject / "mobile").is_dir():
                print("OTKAZ: --repo не похож на корень продукта: %s" % subject, file=sys.stderr)
                return 2
        else:
            subject = None
        if subject is None:
            print("клеток %d, зелёных 0, красных %d — SUBJECT_ABSENT (задайте --repo <корень продукта> или --model)" % (
                len(vse_kletki), len(vse_kletki)))
            for imja in vse_kletki:
                print("КЛЕТКА %s КРАСНА: SUBJECT_ABSENT" % imja)
            return 1
        zeljonye = 0
        krasnye = []
        otlozhennye = []
        for imja in vse_kletki:
            ok, prichina = odna_kletka(imja, subject, vrem)
            if ok is None:
                otlozhennye.append("%s: %s" % (imja, prichina))
            elif ok:
                zeljonye += 1
            else:
                krasnye.append("%s: %s" % (imja, prichina))
        print("клеток %d, зелёных %d, красных %d" % (len(vse_kletki), zeljonye, len(krasnye)))
        for k in krasnye:
            print("КЛЕТКА %s КРАСНА" % k)
        for o in otlozhennye:
            print("КЛЕТКА %s ОТЛОЖЕНА" % o)
        if otlozhennye:
            print("NOT_IMPLEMENTED: NEEDS_PRECEDENT %d — клетка не зелёная и не красная, место названо выше" % len(otlozhennye))
        if rezhim != "stabs":
            if krasnye:
                return 1
            return 2 if otlozhennye else 0
        if krasnye:
            print("KONTROL_KRASEN — стабы не гоняются", file=sys.stderr)
            return 1
        n, svjazi, zhivye = progony_stabov(vrem)
        if n < 0:
            return oshibka_orakula("стабы: %s" % zhivye[0])
        print("стабов %d, привязок %d, непойманных %d" % (n, svjazi, len(zhivye)))
        for z in zhivye:
            print("STAB_ZHIV: %s" % z)
        if zhivye:
            return 1
        return 2 if otlozhennye else 0
    finally:
        shutil.rmtree(vrem, ignore_errors=True)


if __name__ == "__main__":
    try:
        sys.exit(glavnaja())
    except BrokenPipeError:
        # обрыв пайпа читателем не меняет вердикт; код уже выдан
        sys.exit(1)
