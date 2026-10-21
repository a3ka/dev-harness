#!/usr/bin/env python3
"""Модель 120: мир-фабрика раскладки Complior-back и честная спецификация.

  model_mobility_120.py build <каталог-мира> <pin-реальный> <pin-мира-выход> [--spec]
  model_mobility_120.py mutate <каталог-мира> <клетка>

Мир строится из РЕАЛЬНОГО пина (233 операции, коды PMServiceCode, внешние
зависимости и шаги partner плана 119, id реестра 119), поэтому честная
спецификация модели сходится с продуктом по идентификаторам, а не по игрушке.
Пин мира снимается тем же gen_pin_120.py с закоммиченного мира (провенанс
исполним и в модели). Клетки d01…d46, d50…d52 — ОДНА мутация честной спецификации
(или дерева) каждая; g01 — дифференциал (мутация, при которой честный оракул зелен);
ожидаемая причина клетки живёт в раннере литералом (Н-39).
"""
import json
import os
import shutil
import subprocess
import sys

import yaml

HERE = os.path.dirname(os.path.abspath(__file__))
SPEC = "docs/spec/mobility-consumer-v1"
GIT = ["git", "-c", "user.name=model120", "-c", "user.email=model120@local",
       "-c", "commit.gpgsign=false"]

CHAIN = ["listMobilityServices", "createMobilityServiceCase", "getMobilityServiceRequirements",
         "answerMobilityServiceRequirements", "linkMobilityServiceDependency",
         "prepareMobilityFormBundle", "getMobilityFormBundle", "createMobilityFormSignature",
         "getMobilityFormSignature", "decideMobilityFormBundle", "requestMobilityCaseSubmission",
         "getMobilityOperation", "getMobilityServiceOutcome"]
PLATE_NEW = ["checkMobilityPlateAvailability", "createMobilityPlateReservation",
             "getMobilityPlateReservation", "expireMobilityPlateReservation",
             "cancelMobilityPlateReservation"]
INSURANCE = ["listInsuranceCapabilities", "createQuoteJob", "getQuoteRequirements",
             "answerQuoteRequirements", "getPlacementQuotes", "getEvbIssuance", "getEvbUseEvidence"]
INSURANCE_NEW = ["selectConsumerKfzQuote", "submitConsumerKfzApplication"]

ERRORS = [  # (id, индекс строки §5.2 в пине, severity, disposition, spec_artifact)
    ("m5-2-baseline-5-8-2-otkat", [0], "Блокер импорта", "CLOSED_BY_119", None),
    ("m5-2-poterya-51-consumer", [1], "Блокер импорта", "CLOSED_BY_119", None),
    ("m1-kfz-termination-consumer-gap", [2], "Блокер consumer v1", "SPEC_120", "kfz-termination-consumer.json"),
    ("m1-wunschkennzeichen-lifecycle", [3], "Блокер полного набора", "SPEC_120", "wunschkennzeichen-lifecycle.json"),
    ("m1-release-graph-partner-first", [4], "Высокая", "SPEC_120", "release-graph.json"),
    ("m1-termination-confirmed-unverified-report", [5], "Высокая", "SPEC_120", "kfz-termination-consumer.json"),
    ("m1-done-bez-evidence-step-key", [6], "Высокая", "SPEC_120", "processes.json"),
    ("m1-generic-current-value", [7], "Средняя/высокая", "INTEGRATION_LATER", None),
    ("m1-physical-model-fk-grants-invitation-owner", [8, 9, 10, 11], "Блокер DDL", "DDL_TRACK", None),
    ("m1-validate-bundle-exact-projection", [12], "Средняя", "INTEGRATION_LATER", None),
    ("m1-otsutstvuyushchie-artefakty-a312-521", [13], "Средняя", "INTEGRATION_LATER", None),
    ("m1-a689-obeshchaniya-generacii", [14], "Средняя", "INTEGRATION_LATER", None),
    ("m1-a300-if-match-obobshchenie", [15], "Средняя", "INTEGRATION_LATER", None),
    ("m1-shrifty-render-architecture-c2b", [16], "Средняя", "NOT_RUN_EXTERNAL", None),
    ("m1-pg-boss-konflikt", [17], "Интеграционный конфликт", "INTEGRATION_LATER", None),
]


def wjson(path, obj):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(obj, fh, ensure_ascii=False, indent=1)
        fh.write("\n")


def rjson(path):
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


def wtext(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(text)


def build_world(d, rp):
    os.makedirs(d)
    subprocess.run(GIT + ["init", "-q", d], check=True)
    paths = {f"/x/{i}": {"get": {"operationId": o}} for i, o in enumerate(rp["operations"])}
    wtext(os.path.join(d, "docs/contracts/BrokerOS_Unified_OpenAPI_v3.yaml"),
          yaml.safe_dump({"openapi": "3.1.0", "info": {"version": "5.8.4"}, "paths": paths}))
    ext = {"components": {"schemas": {
        "PMServiceCode": {"type": "string", "enum": rp["pm_service_codes"]},
        "PMConsumerCaseInput": {"properties": {"service_code": {"enum": rp["consumer_case_codes_119"]}}}}}}
    wtext(os.path.join(d, "docs/sources/backend-3.15/platform-extension.yaml"), yaml.safe_dump(ext))
    steps = [{"id": s, "depends_on": []} for s in rp["partner_steps_119"]]
    steps.append({"id": "CONSUMER_MOBILITY", "depends_on": ["PM_REGISTRATION"]})
    wjson(os.path.join(d, "docs/plans/delivery-plan-3.15.json"),
          {"steps": steps, "external_dependencies": [{"id": e} for e in rp["external_dependencies"]]})
    open_ids = sorted(set(rp["ids_119"]) - set(rp["closed_by_119"]))
    wjson(os.path.join(d, "docs/sources/backend-3.15/provenance/KNOWN-ISSUES-DECLARED.json"),
          {"ids": open_ids, "resolved_by_this_import": rp["closed_by_119"]})
    wjson(os.path.join(d, "tests/spec-3.15/known-issues-315.json"), {"ids": rp["ids_119"]})
    wjson(os.path.join(d, "docs/contracts/deprecated-consumer-operations.json"),
          {"operations": rp["deprecated_operations"]})
    wtext(os.path.join(d, "app/index.js"), "module.exports = {};\n")
    wtext(os.path.join(d, "server/index.js"), "module.exports = {};\n")
    wtext(os.path.join(d, ".gitignore"), "node_modules/\n")  # как в продукте: зависимости вне учёта
    subprocess.run(GIT + ["-C", d, "add", "-A"], check=True)
    subprocess.run(GIT + ["-C", d, "commit", "-qm", "мир 120: база после 119"], check=True)


def honest_spec(d, rp):
    s = os.path.join(d, SPEC)
    term = {"state": "OUTCOME_VERIFIED", "requires_evidence": True, "server_predicate": True}

    def proc(pid, codes, ops, new, ext):
        return {"id": pid, "service_codes": codes, "operations": ops, "new_operations": new,
                "adapter": "SYNTHETIC", "real_release": {"status": "NOT_RUN", "blocked_by": ext},
                "terminal": dict(term)}

    wjson(os.path.join(s, "processes.json"), {"spec": "mobility-consumer-v1", "core": "5.8.4", "processes": [
        proc("ZULASSUNG", ["REGISTER_OR_REREGISTER"], CHAIN, [], ["registration_provider_admission", "signature_provider_admission"]),
        proc("ABMELDUNG", ["DEREGISTER"], CHAIN, [], ["registration_provider_admission"]),
        proc("KENNZEICHEN_WUNSCH", ["PLATE_ORDER"], CHAIN, list(PLATE_NEW), ["plate_provider_admission"]),
        proc("VERSICHERUNG_EVB", ["KFZ_INSURANCE"], INSURANCE, list(INSURANCE_NEW), ["insurer_sandbox"]),
        proc("KUENDIGUNG", ["KFZ_TERMINATION"], CHAIN, [], ["insurer_sandbox"]),
    ]})
    wjson(os.path.join(s, "kfz-termination-consumer.json"), {
        "service_code": "KFZ_TERMINATION",
        "consumer_case_codes": rp["consumer_case_codes_119"] + ["KFZ_TERMINATION"],
        "required_checks": ["AUTHORITY", "ELIGIBILITY", "DATES", "CONTRACT_TARGET"],
        "not_substitutes": ["cancelMobilityServiceCase", "WIDERRUF"],
        "abmeldung_link": "SEPARATE_CONFIRMED_INSURANCE_OUTCOME",
        "terminal": {"state": "TERMINATION_CONFIRMED",
                     "requires": {"verification": "VERIFIED", "receipts_min": 1, "effective_end_date": "NON_NULL"}}})
    ops = [{"id": PLATE_NEW[0], "kind": "CHECK"}, {"id": PLATE_NEW[1], "kind": "RESERVE"},
           {"id": PLATE_NEW[2], "kind": "READ"}, {"id": PLATE_NEW[3], "kind": "EXPIRE"},
           {"id": PLATE_NEW[4], "kind": "CANCEL"}]
    tr = [("REQUESTED", "AVAILABLE", PLATE_NEW[0]), ("REQUESTED", "UNAVAILABLE", PLATE_NEW[0]),
          ("REQUESTED", "UNKNOWN", PLATE_NEW[0]), ("UNKNOWN", "AVAILABLE", PLATE_NEW[0]),
          ("UNKNOWN", "UNAVAILABLE", PLATE_NEW[0]), ("AVAILABLE", "RESERVED", PLATE_NEW[1]),
          ("AVAILABLE", "UNAVAILABLE", PLATE_NEW[1]), ("RESERVED", "EXPIRED", PLATE_NEW[3]),
          ("RESERVED", "CANCELLED", PLATE_NEW[4]), ("RESERVED", "CONSUMED_BY_PLATE_ORDER", PLATE_NEW[1])]
    wjson(os.path.join(s, "wunschkennzeichen-lifecycle.json"), {
        "initial": "REQUESTED",
        "states": ["REQUESTED", "UNKNOWN", "AVAILABLE", "UNAVAILABLE", "RESERVED", "EXPIRED",
                   "CANCELLED", "CONSUMED_BY_PLATE_ORDER"],
        "terminal": ["UNAVAILABLE", "EXPIRED", "CANCELLED", "CONSUMED_BY_PLATE_ORDER"],
        "operations": ops, "expiry_field": "expires_at",
        "transitions": [{"from": f, "to": t, "operation": o} for f, t, o in tr]})
    rows = rp["astra_52_rows"]
    errs = []
    for n, (eid, idx, sev, disp, art) in enumerate(ERRORS, 1):
        x = {"code": f"E315-{n:02d}", "id": eid, "astra_rows": [rows[i] for i in idx],
             "severity": sev, "disposition": disp, "fix": "по §5.2 «Как исправить»"}
        if art:
            x["spec_artifact"] = art
        errs.append(x)
    wjson(os.path.join(s, "bundle-errors-315.json"), {"source": "ASTRA-REPORT-3.15.md §5.2", "errors": errs})
    procs = ["ZULASSUNG", "ABMELDUNG", "KENNZEICHEN_WUNSCH", "VERSICHERUNG_EVB", "KUENDIGUNG"]
    nodes = [{"id": "SHARED_MOBILITY_CORE", "kind": "SHARED", "depends_on": []}]
    nodes += [{"id": p, "kind": "PROCESS", "depends_on": ["SHARED_MOBILITY_CORE"]} for p in procs]
    nodes.append({"id": "CONSUMER_MOBILITY_V1", "kind": "CONSUMER", "depends_on": procs})
    nodes += [{"id": e, "kind": "EXTERNAL", "depends_on": []} for e in rp["external_dependencies"]]
    nodes.append({"id": "CONSUMER_MOBILITY_REAL", "kind": "CONSUMER",
                  "depends_on": ["CONSUMER_MOBILITY_V1", "registration_provider_admission",
                                 "plate_provider_admission", "insurer_sandbox", "signature_provider_admission"]})
    pdeps = {"PM_FOUNDATION": ["SHARED_MOBILITY_CORE"], "PM_CAPTURE": ["PM_FOUNDATION"],
             "PM_REGISTRATION": ["PM_CAPTURE", "registration_provider_admission"],
             "PM_KFZ": ["PM_CAPTURE", "insurer_sandbox"],
             "PM_PLATES_TERMINATION": ["PM_REGISTRATION", "plate_provider_admission"],
             "PM_ENGAGEMENT": ["PM_FOUNDATION", "communications_admission"]}
    nodes += [{"id": p, "kind": "PARTNER", "depends_on": pdeps[p]} for p in rp["partner_steps_119"]]
    nodes.append({"id": "BROKER_APP_ENDPOINTS", "kind": "BROKER_APP", "depends_on": ["SHARED_MOBILITY_CORE"]})
    wjson(os.path.join(s, "release-graph.json"), {"consumer_first": True, "nodes": nodes})
    wtext(os.path.join(s, "README_RU.md"), "\n".join([
        "# Mobility consumer v1 — спецификация (контракт 120)", "",
        "Пять процессов на синтетических адаптерах; реальный выпуск — после договоров с каналами.", "",
        "## Артефакты", "",
        "- `processes.json` — пять процессов, операции, терминальные предикаты",
        "- `kfz-termination-consumer.json` — consumer KFZ_TERMINATION",
        "- `wunschkennzeichen-lifecycle.json` — lifecycle Wunschkennzeichen",
        "- `bundle-errors-315.json` — ошибки бандла §5.2 с кодами",
        "- `release-graph.json` — consumer-first release graph", ""]))


def edit(d, name, fn):
    p = os.path.join(d, SPEC, name)
    obj = rjson(p)
    fn(obj)
    wjson(p, obj)


def P(obj, pid):
    return next(p for p in obj["processes"] if p["id"] == pid)


def N(obj, nid):
    return next(n for n in obj["nodes"] if n["id"] == nid)


def E(obj, eid):
    return next(x for x in obj["errors"] if x["id"] == eid)


def mutate(d, cell):
    s = os.path.join(d, SPEC)
    pr, kf, wu, er, gr = ("processes.json", "kfz-termination-consumer.json",
                          "wunschkennzeichen-lifecycle.json", "bundle-errors-315.json", "release-graph.json")
    if cell == "d01-artefakt-udalen":
        os.remove(os.path.join(s, gr))
    elif cell == "d02-json-bityj":
        p = os.path.join(s, pr)
        with open(p, "rb") as fh:
            b = fh.read()
        with open(p, "wb") as fh:
            fh.write(b[: len(b) // 2])
    elif cell == "d03-published-izmenen":
        with open(os.path.join(d, "docs/contracts/BrokerOS_Unified_OpenAPI_v3.yaml"), "a") as fh:
            fh.write("# KFZ_TERMINATION для consumer\n")
    elif cell == "d04-plan-119-perepisan":
        p = os.path.join(d, "docs/plans/delivery-plan-3.15.json")
        o = rjson(p)
        o["steps"][-1]["depends_on"] = []
        wjson(p, o)
    elif cell == "d05-server-tronut":
        wtext(os.path.join(d, "server/mobility-termination.js"), "// consumer termination\n")
    elif cell == "d06-app-izmenen":
        with open(os.path.join(d, "app/index.js"), "a") as fh:
            fh.write("// KFZ_TERMINATION\n")
    elif cell == "d07-chetyre-processa":
        edit(d, pr, lambda o: o.__setitem__("processes", [p for p in o["processes"] if p["id"] != "KUENDIGUNG"]))
    elif cell == "d08-kod-ne-tot":
        edit(d, pr, lambda o: P(o, "KUENDIGUNG").__setitem__("service_codes", ["KFZ_INSURANCE"]))
    elif cell == "d09-kod-vydumannyj":
        edit(d, pr, lambda o: P(o, "KENNZEICHEN_WUNSCH")["service_codes"].append("WUNSCHKENNZEICHEN"))
    elif cell == "d10-realnyj-adapter":
        edit(d, pr, lambda o: P(o, "ZULASSUNG").__setitem__("adapter", "REAL"))
    elif cell == "d11-bez-blokera-kanala":
        edit(d, pr, lambda o: P(o, "VERSICHERUNG_EVB")["real_release"].__setitem__("blocked_by", []))
    elif cell == "d12-vydumannaya-kak-sushchestvuyushchaya":
        edit(d, pr, lambda o: P(o, "KENNZEICHEN_WUNSCH")["operations"].append("reserveWunschkennzeichen"))
    elif cell == "d13-deprecated-route":
        edit(d, pr, lambda o: P(o, "KENNZEICHEN_WUNSCH")["operations"].append("createPlateCheck"))
    elif cell == "d14-novaya-kollizija":
        edit(d, pr, lambda o: P(o, "KUENDIGUNG")["new_operations"].append("createMobilityServiceCase"))
    elif cell == "d15-terminal-bez-evidence":
        edit(d, pr, lambda o: P(o, "ABMELDUNG")["terminal"].__setitem__("requires_evidence", False))
    elif cell == "d16-termination-net-v-consumer":
        edit(d, kf, lambda o: o["consumer_case_codes"].remove("KFZ_TERMINATION"))
    elif cell == "d17-termination-vytesnyaet-kody":
        edit(d, kf, lambda o: o.__setitem__("consumer_case_codes", ["KFZ_TERMINATION"]))
    elif cell == "d18-cancel-kak-kuendigung":
        edit(d, kf, lambda o: o.__setitem__("not_substitutes", ["WIDERRUF"]))
    elif cell == "d19-terminal-unverified":
        edit(d, kf, lambda o: o["terminal"]["requires"].__setitem__("verification", "UNVERIFIED_REPORT"))
    elif cell == "d20-receipts-nol":
        edit(d, kf, lambda o: o["terminal"]["requires"].__setitem__("receipts_min", 0))
    elif cell == "d21-wunsch-odna-ssylka":
        edit(d, wu, lambda o: o.update({"states": ["REQUESTED", "RESERVED"], "terminal": ["RESERVED"]}))
    elif cell == "d22-wunsch-bez-otmeny":
        edit(d, wu, lambda o: o.__setitem__("operations", [x for x in o["operations"] if x["kind"] != "CANCEL"]))
    elif cell == "d23-wunsch-iz-terminala":
        edit(d, wu, lambda o: o["transitions"].append(
            {"from": "EXPIRED", "to": "RESERVED", "operation": "createMobilityPlateReservation"}))
    elif cell == "d24-wunsch-nedostizhimo":
        edit(d, wu, lambda o: o.__setitem__("transitions", [t for t in o["transitions"] if t["to"] != "CANCELLED"]))
    elif cell == "d25-wunsch-op-vne-processa":
        edit(d, wu, lambda o: o["operations"][0].__setitem__("id", "checkWunschkennzeichen"))
    elif cell == "d26-oshibka-propushena":
        edit(d, er, lambda o: o.__setitem__("errors", [x for x in o["errors"] if x["id"] != "m1-validate-bundle-exact-projection"]))
    elif cell == "d27-id-119-pereimenovan":
        edit(d, er, lambda o: E(o, "m1-kfz-termination-consumer-gap").__setitem__("id", "kfz-termination-gap"))
    elif cell == "d28-kod-dubl":
        edit(d, er, lambda o: o["errors"][1].__setitem__("code", o["errors"][0]["code"]))
    elif cell == "d29-zakryto-119-po-tekstu":
        edit(d, er, lambda o: E(o, "m1-a689-obeshchaniya-generacii").__setitem__("disposition", "CLOSED_BY_119"))
    elif cell == "d30-kfz-otlozheno":
        edit(d, er, lambda o: E(o, "m1-kfz-termination-consumer-gap").update(
            {"disposition": "INTEGRATION_LATER", "spec_artifact": None}))
    elif cell == "d31-graf-cikl":
        edit(d, gr, lambda o: N(o, "SHARED_MOBILITY_CORE")["depends_on"].append("CONSUMER_MOBILITY_V1"))
    elif cell == "d32-graf-partner-first":
        edit(d, gr, lambda o: N(o, "CONSUMER_MOBILITY_V1")["depends_on"].append("PM_REGISTRATION"))
    elif cell == "d33-graf-tranzitivno-partner":
        edit(d, gr, lambda o: N(o, "ZULASSUNG")["depends_on"].append("PM_CAPTURE"))
    elif cell == "d34-graf-v1-zhdet-kanal":
        edit(d, gr, lambda o: N(o, "CONSUMER_MOBILITY_V1")["depends_on"].append("insurer_sandbox"))
    elif cell == "d35-graf-bez-processa":
        edit(d, gr, lambda o: N(o, "CONSUMER_MOBILITY_V1")["depends_on"].remove("KUENDIGUNG"))
    elif cell == "d36-graf-broker-bez-yadra":
        edit(d, gr, lambda o: N(o, "BROKER_APP_ENDPOINTS").__setitem__("depends_on", []))
    elif cell == "d37-graf-prizrak":
        edit(d, gr, lambda o: N(o, "CONSUMER_MOBILITY_REAL")["depends_on"].append("GHOST_GATE"))
    elif cell == "d38-readme-bez-ssylki":
        p = os.path.join(s, "README_RU.md")
        with open(p, encoding="utf-8") as fh:
            t = fh.read()
        wtext(p, "\n".join(l for l in t.split("\n") if "release-graph.json" not in l))
    elif cell == "d39-readme-v-proze":
        p = os.path.join(s, "README_RU.md")
        with open(p, encoding="utf-8") as fh:
            t = fh.read()
        t = "\n".join(l for l in t.split("\n") if "release-graph.json" not in l)
        wtext(p, t + "Граф выпуска лежит в `release-graph.json` рядом.\n")
    elif cell == "d40-graf-partner-poteryan":
        edit(d, gr, lambda o: o.__setitem__("nodes", [n for n in o["nodes"] if n["id"] != "PM_ENGAGEMENT"]))
    elif cell == "d41-graf-kanal-pod-vidom-shared":  # обход критика круга 1 дословно
        def f(o):
            N(o, "insurer_sandbox")["kind"] = "SHARED"
            N(o, "CONSUMER_MOBILITY_V1")["depends_on"].append("insurer_sandbox")
            N(o, "KUENDIGUNG")["depends_on"].append("insurer_sandbox")
        edit(d, gr, f)
    elif cell == "d42-graf-kanal-pod-aliasom":
        def f(o):
            o["nodes"].append({"id": "insurer_contract", "kind": "SHARED", "depends_on": []})
            N(o, "CONSUMER_MOBILITY_V1")["depends_on"].append("insurer_contract")
            N(o, "KUENDIGUNG")["depends_on"].append("insurer_contract")
        edit(d, gr, f)
    elif cell == "d43-tests-tronuty":
        wtext(os.path.join(d, "tests/mobility-consumer-v1.test.js"), "// consumer v1\n")
    elif cell == "d44-baza-pina-otsutstvuet":  # клон без коммита базы (squash/переписанная история)
        shutil.rmtree(os.path.join(d, ".git"))
        subprocess.run(GIT + ["init", "-q", d], check=True)
        subprocess.run(GIT + ["-C", d, "add", "-A"], check=True)
        subprocess.run(GIT + ["-C", d, "commit", "-qm", "мир 120: история без базы пина"], check=True)
    elif cell == "d45-indeks-assume-unchanged":  # обход Adv120 (1): правка сервера под флагом индекса
        wtext(os.path.join(d, "server/index.js"), "throw new Error('заглушка');\n")
        subprocess.run(GIT + ["-C", d, "update-index", "--assume-unchanged", "server/index.js"], check=True)
    elif cell == "d46-indeks-skip-worktree-udalen":
        os.remove(os.path.join(d, "app/index.js"))
        subprocess.run(GIT + ["-C", d, "update-index", "--skip-worktree", "app/index.js"], check=True)
    elif cell == "d50-neotslezh-pod-info-exclude":  # обход Rev120b Б-2: локальный ignore клона
        wtext(os.path.join(d, "server/src/evil.js"), "throw new Error('заглушка');\n")
        os.makedirs(os.path.join(d, ".git/info"), exist_ok=True)
        with open(os.path.join(d, ".git/info/exclude"), "a") as fh:
            fh.write("server/src/evil.js\n")
    elif cell == "d51-samoignoriruyushchij-gitignore":  # обход Rev120b Б-2: неотслеживаемый `*`
        wtext(os.path.join(d, "server/src/evil.js"), "throw new Error('заглушка');\n")
        wtext(os.path.join(d, "server/src/.gitignore"), "*\n")
    elif cell == "d52-sparse-checkout":  # Rev120b С-1: честная спека, содержимое вне конуса не видно
        subprocess.run(GIT + ["-C", d, "sparse-checkout", "set", "--no-cone", "/docs/", "/tests/", "/server/"],
                       check=True, capture_output=True)
    elif cell == "g01-node-modules-chestnyj":  # дифференциал Б-2: зависимости под отслеживаемым ignore
        wtext(os.path.join(d, "node_modules/x/index.js"), "module.exports = 1;\n")
        wtext(os.path.join(d, "node_modules/x/.gitignore"), "*.log\n")
    else:
        print(f"нет такой мутации: {cell}", file=sys.stderr)
        return 2
    return 0


def main(a):
    if len(a) >= 4 and a[0] == "build":
        d, rp_path, out = a[1], a[2], a[3]
        rp = rjson(rp_path)
        build_world(d, rp)
        r = subprocess.run([sys.executable, os.path.join(HERE, "gen_pin_120.py"), d, "HEAD"],
                           check=True, capture_output=True, text=True)
        pin = json.loads(r.stdout)
        pin["world"] = "model"
        wjson(out, pin)
        if "--spec" in a[4:]:
            honest_spec(d, rp)
        return 0
    if len(a) == 3 and a[0] == "mutate":
        return mutate(a[1], a[2])
    print(__doc__, file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
