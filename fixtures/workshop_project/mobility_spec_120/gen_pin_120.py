#!/usr/bin/env python3
"""Пин 120: снимок фактов продукта, против которых оракул судит спецификацию.

Правило 8: оракул сверяет спецификацию с ПИНОМ (память проверяющего), а не с
файлами проверяемого дерева. Пин строится ЭТИМ скриптом из git-дерева продукта
на названном коммите (не руками) — провенанс исполним.

  python3 gen_pin_120.py <клон Complior-back> <коммит> > pin_120.json

Коммит по умолчанию в пине — 0b0c413 (импорт 119, cmp-bck-315/import).
"""
import hashlib
import json
import subprocess
import sys

import yaml

PUBLISHED = "docs/contracts/BrokerOS_Unified_OpenAPI_v3.yaml"
EXTENSION = "docs/sources/backend-3.15/platform-extension.yaml"
PLAN = "docs/plans/delivery-plan-3.15.json"
KNOWN = "tests/spec-3.15/known-issues-315.json"
DECLARED = "docs/sources/backend-3.15/provenance/KNOWN-ISSUES-DECLARED.json"
DEPRECATED = "docs/contracts/deprecated-consumer-operations.json"

# §5.2 ASTRA-REPORT-3.15.md — столбец «Место», 18 строк, дословно (единый источник
# якорей для спецификации: bundle-errors-315.json несёт их байт-в-байт).
ASTRA_52_ROWS = [
    "B/sources/baseline-lock.json:3–7; B/tools/generate_derived.py:24–25",
    "B/contracts/frontend-consumer-bindings.json:8618–8663; B/tools/generate_derived.py:53",
    "E:9824–9851",
    "E:10050–10100; B/contracts/service-workflows.json:61–103",
    "B/plans/delivery-plan.json:64–103; A:887",
    "E:10364–10461",
    "E:10462–10528",
    "E:9929–9981; B/data/service-field-registry.json:276–283,348–355,375–427",
    "P:1214–1227",
    "P:1777–1791,1838–1869",
    "P:119–245,303–436,1864–1869",
    "P:1567–1626,1686–1738,1740–1862",
    "B/tools/validate_bundle.py:64–67",
    "A:312,370,376,382,519,521",
    "A:689 против B/tools/generate_derived.py:29–66",
    "A:300",
    "B/tools/render_architecture.py:13–14",
    "B/tools/generate_derived.py:26; back/structure-policy.json:189–196",
]


def show(repo, rev, path):
    return subprocess.run(["git", "-C", repo, "show", f"{rev}:{path}"],
                          check=True, capture_output=True).stdout


def main():
    repo, rev = sys.argv[1], sys.argv[2]
    pub_b = show(repo, rev, PUBLISHED)
    pub = yaml.safe_load(pub_b)
    ops = sorted(o["operationId"] for p in pub["paths"].values() for o in p.values()
                 if isinstance(o, dict) and "operationId" in o)
    ext = yaml.safe_load(show(repo, rev, EXTENSION))
    sch = ext["components"]["schemas"]
    pm_codes = sch["PMServiceCode"]["enum"]
    consumer_codes = sch["PMConsumerCaseInput"]["properties"]["service_code"]["enum"]
    plan = json.loads(show(repo, rev, PLAN))
    declared = json.loads(show(repo, rev, DECLARED))
    dep = json.loads(show(repo, rev, DEPRECATED))
    base = subprocess.run(["git", "-C", repo, "rev-parse", rev], check=True,
                          capture_output=True, text=True).stdout.strip()
    pin = {
        "world": "real",
        "base_commit": base,
        "frozen_sha256": {p: hashlib.sha256(show(repo, rev, p)).hexdigest()
                          for p in (PUBLISHED, PLAN, KNOWN, DECLARED)},
        "operations": ops,
        "deprecated_operations": sorted(dep["operations"]),
        "pm_service_codes": pm_codes,
        "consumer_case_codes_119": consumer_codes,
        "external_dependencies": sorted(e["id"] for e in plan["external_dependencies"]),
        "partner_steps_119": sorted(s["id"] for s in plan["steps"] if s["id"].startswith("PM_")),
        "astra_52_rows": ASTRA_52_ROWS,
        "ids_119": sorted(declared["ids"] + declared["resolved_by_this_import"]),
        "closed_by_119": sorted(declared["resolved_by_this_import"]),
    }
    json.dump(pin, sys.stdout, ensure_ascii=False, indent=1, sort_keys=True)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
