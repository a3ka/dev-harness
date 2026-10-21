#!/usr/bin/env python3
"""Оракул 120: судит спецификацию mobility consumer v1 в дереве Complior-back.

  python3 mobility_spec_oracle.py <репо> [--pin <pin.json>]

Правило 8: факты продукта — из ПИНА (снят gen_pin_120.py с названного коммита),
грамматика спецификации — из grammatika_120.json рядом (единый источник).
Дерево проверяемого даёт ТОЛЬКО артефакты спецификации и байты замороженных
файлов импорта 119 (их sha сверяются с пином).
Коды: 0 — `MOBILITY120_OK …`; 1 — `ОТКАЗ: mobility120: <причина>` (первая красная
проверка в фиксированном порядке); 2 — нечем судить (нет аргумента/пина/git; base_commit
пина отсутствует в клоне). Алфавит причин — REASONS ниже, замкнутый.
Класс узла графа выводится из ПИНА и грамматики по id; поле `kind` проверяемого
сверяется с ним (`graf-kind-protiv-pina`), замыкание V1 судится по id.
"""
import hashlib
import json
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))

REASONS = (
    "spec-otsutstvuet", "json-nevalidno", "import119-izmenen", "vne-zony",
    "processy-nepolny", "service-code-neizvesten", "adapter-ne-sintetika",
    "operaciya-neizvestna", "operaciya-deprecated", "novaya-operaciya-kollizija",
    "terminal-bez-dokazatelstv", "termination-consumer-net", "termination-ne-additivno",
    "termination-terminal-slab", "wunsch-lifecycle-nepolny", "wunsch-avtomat-nekorrekten",
    "oshibki-grammatika", "oshibki-nepolny", "oshibki-protivorechat-119",
    "oshibki-ne-zakryty-specifikaciej", "graf-nevaliden", "graf-ciklichen",
    "graf-ne-consumer-first", "graf-nepolny", "readme-bez-ssylok", "graf-kind-protiv-pina",
)


class Red(Exception):
    pass


class Nechem(Exception):
    pass


def red(reason, detail=""):
    assert reason in REASONS, reason
    raise Red(f"{reason}" + (f" ({detail})" if detail else ""))


def need(cond, reason, detail=""):
    if not cond:
        red(reason, detail)


def is_str_list(x):
    return isinstance(x, list) and all(isinstance(i, str) for i in x)


def closure(start, deps):
    seen, stack = set(), list(deps.get(start, []))
    while stack:
        n = stack.pop()
        if n in seen:
            continue
        seen.add(n)
        stack.extend(deps.get(n, []))
    return seen


def judge(repo, pin, g):
    sd = os.path.join(repo, g["spec_dir"])
    for a in g["artifacts"]:
        need(os.path.isfile(os.path.join(sd, a)), "spec-otsutstvuet", a)
    docs = {}
    for a in g["artifacts"]:
        if a.endswith(".json"):
            try:
                with open(os.path.join(sd, a), encoding="utf-8") as fh:
                    docs[a] = json.load(fh)
            except (ValueError, UnicodeDecodeError) as e:
                red("json-nevalidno", f"{a}: {e.__class__.__name__}")
            need(isinstance(docs[a], dict), "json-nevalidno", f"{a}: не объект")

    # --- импорт 119 не тронут; вне spec_dir против base_commit ничего не тронуто ---
    for path, sha in sorted(pin["frozen_sha256"].items()):
        p = os.path.join(repo, path)
        need(os.path.isfile(p), "import119-izmenen", path)
        with open(p, "rb") as fh:
            need(hashlib.sha256(fh.read()).hexdigest() == sha, "import119-izmenen", path)
    base = pin["base_commit"]
    if subprocess.run(["git", "-C", repo, "cat-file", "-e", base + "^{commit}"],
                      capture_output=True).returncode != 0:
        raise Nechem(f"base_commit пина отсутствует в клоне ({base} в {repo}; перегенерируй пин gen_pin_120.py)")
    r = subprocess.run(["git", "-C", repo, "diff", "-z", "--name-only", base], capture_output=True)
    u = subprocess.run(["git", "-C", repo, "ls-files", "-z", "--others", "--exclude-standard"],
                       capture_output=True)
    if r.returncode != 0 or u.returncode != 0:
        raise Nechem(f"git diff/ls-files rc={r.returncode}/{u.returncode}")
    spec_pre = g["spec_dir"].rstrip("/") + "/"
    touched = sorted({x for x in (r.stdout + u.stdout).decode("utf-8", "replace").split("\0")
                      if x and not x.startswith(spec_pre)})
    need(not touched, "vne-zony", ",".join(touched[:3]))

    ops = set(pin["operations"])
    deprecated = set(pin["deprecated_operations"])

    # --- processes.json ---
    pr = docs["processes.json"]
    procs = pr.get("processes")
    need(isinstance(procs, list) and all(isinstance(p, dict) for p in procs), "processy-nepolny", "processes")
    ids = [p.get("id") for p in procs]
    need(sorted(ids) == sorted(g["processes"]) and len(set(ids)) == len(ids), "processy-nepolny", "id")
    by_id = {p["id"]: p for p in procs}
    for pid, req in g["processes"].items():
        p = by_id[pid]
        codes = p.get("service_codes")
        need(is_str_list(codes) and codes, "processy-nepolny", f"{pid}.service_codes")
        for c in codes:
            need(c in pin["pm_service_codes"], "service-code-neizvesten", f"{pid}:{c}")
        need(req["service_code"] in codes, "processy-nepolny", f"{pid} без {req['service_code']}")
    for pid, req in g["processes"].items():
        p = by_id[pid]
        rr = p.get("real_release")
        need(p.get("adapter") == g["adapter_v1"], "adapter-ne-sintetika", pid)
        need(isinstance(rr, dict) and rr.get("status") == g["real_release_status"], "adapter-ne-sintetika", f"{pid}.real_release")
        bb = rr.get("blocked_by")
        need(is_str_list(bb) and req["external"] in bb and set(bb) <= set(pin["external_dependencies"]),
             "adapter-ne-sintetika", f"{pid}.blocked_by")
    new_all = []
    for pid in g["processes"]:
        p = by_id[pid]
        ex, nw = p.get("operations"), p.get("new_operations")
        need(is_str_list(ex) and ex and is_str_list(nw), "processy-nepolny", f"{pid}.operations")
        for o in ex:
            need(o in ops, "operaciya-neizvestna", f"{pid}:{o}")
            need(o not in deprecated, "operaciya-deprecated", f"{pid}:{o}")
        new_all += nw
    for o in new_all:
        need(re.fullmatch(g["new_operation_re"], o) is not None and o not in ops,
             "novaya-operaciya-kollizija", o)
    need(len(set(new_all)) == len(new_all), "novaya-operaciya-kollizija", "дубль")
    for pid in g["processes"]:
        t = by_id[pid].get("terminal")
        need(isinstance(t, dict) and isinstance(t.get("state"), str) and t.get("state")
             and t.get("requires_evidence") is True and t.get("server_predicate") is True,
             "terminal-bez-dokazatelstv", pid)

    # --- kfz-termination-consumer.json ---
    tg = g["termination"]
    k = docs["kfz-termination-consumer.json"]
    cc = k.get("consumer_case_codes")
    need(k.get("service_code") == tg["service_code"] and is_str_list(cc) and tg["service_code"] in cc,
         "termination-consumer-net", "consumer_case_codes")
    need(set(pin["consumer_case_codes_119"]) <= set(cc), "termination-ne-additivno",
         ",".join(sorted(set(pin["consumer_case_codes_119"]) - set(cc))))
    for c in cc:
        need(c in pin["pm_service_codes"], "service-code-neizvesten", f"kfz:{c}")
    need(is_str_list(k.get("required_checks")) and set(tg["required_checks"]) <= set(k["required_checks"]),
         "termination-consumer-net", "required_checks")
    need(is_str_list(k.get("not_substitutes")) and set(tg["not_substitutes"]) <= set(k["not_substitutes"]),
         "termination-consumer-net", "not_substitutes")
    need(k.get("abmeldung_link") == tg["abmeldung_link"], "termination-consumer-net", "abmeldung_link")
    term = k.get("terminal")
    need(isinstance(term, dict) and term.get("state") == tg["terminal_state"], "termination-terminal-slab", "state")
    rq = term.get("requires")
    want = tg["terminal_requires"]
    need(isinstance(rq, dict) and rq.get("verification") == want["verification"]
         and rq.get("effective_end_date") == want["effective_end_date"]
         and isinstance(rq.get("receipts_min"), int) and not isinstance(rq.get("receipts_min"), bool)
         and rq["receipts_min"] >= want["receipts_min"], "termination-terminal-slab", "requires")

    # --- wunschkennzeichen-lifecycle.json ---
    wg = g["wunsch"]
    w = docs["wunschkennzeichen-lifecycle.json"]
    states, terminal, init = w.get("states"), w.get("terminal"), w.get("initial")
    wops, trans = w.get("operations"), w.get("transitions")
    need(is_str_list(states) and is_str_list(terminal) and isinstance(init, str)
         and isinstance(wops, list) and isinstance(trans, list)
         and all(isinstance(o, dict) for o in wops) and all(isinstance(t, dict) for t in trans),
         "wunsch-lifecycle-nepolny", "форма")
    need(set(wg["required_states"]) <= set(states), "wunsch-lifecycle-nepolny", "states")
    need(set(wg["required_terminal"]) <= set(terminal), "wunsch-lifecycle-nepolny", "terminal")
    kinds = {o.get("kind") for o in wops}
    need(set(wg["operation_kinds"]) <= kinds, "wunsch-lifecycle-nepolny", "operation kinds")
    need(w.get("expiry_field") == wg["expiry_field"], "wunsch-lifecycle-nepolny", "expiry_field")
    kp = by_id["KENNZEICHEN_WUNSCH"]
    allowed = ops | set(kp["new_operations"])
    op_kind = {}
    for o in wops:
        n = o.get("id")
        need(isinstance(n, str) and n in allowed, "operaciya-neizvestna", f"wunsch:{n}")
        need(n not in deprecated, "operaciya-deprecated", f"wunsch:{n}")
        op_kind[n] = o.get("kind")
    need(len(states) == len(set(states)) and set(terminal) <= set(states) and init in states
         and init not in terminal, "wunsch-avtomat-nekorrekten", "состояния")
    edges = {}
    used = set()
    for t in trans:
        f, to, op = t.get("from"), t.get("to"), t.get("operation")
        need(f in states and to in states and op in op_kind, "wunsch-avtomat-nekorrekten", f"{f}->{to}")
        need(f not in terminal, "wunsch-avtomat-nekorrekten", f"из терминального {f}")
        edges.setdefault(f, []).append(to)
        used.add(op_kind[op])
    need(set(wg["transition_kinds"]) <= used, "wunsch-avtomat-nekorrekten", "kind без перехода")
    reach = closure(init, edges) | {init}
    need(set(states) <= reach, "wunsch-avtomat-nekorrekten", "недостижимо: " + ",".join(sorted(set(states) - reach)))

    # --- bundle-errors-315.json ---
    eg = g["errors"]
    e = docs["bundle-errors-315.json"]
    ents = e.get("errors")
    need(isinstance(ents, list) and all(isinstance(x, dict) for x in ents), "oshibki-grammatika", "errors")
    codes, eids = [], []
    for x in ents:
        need(isinstance(x.get("code"), str) and re.fullmatch(eg["code_re"], x["code"]), "oshibki-grammatika", f"code {x.get('code')}")
        need(isinstance(x.get("id"), str) and re.fullmatch(eg["id_re"], x["id"]), "oshibki-grammatika", f"id {x.get('id')}")
        need(x.get("severity") in eg["severities"], "oshibki-grammatika", f"severity {x.get('id')}")
        need(x.get("disposition") in eg["dispositions"], "oshibki-grammatika", f"disposition {x.get('id')}")
        need(isinstance(x.get("fix"), str) and x["fix"].strip(), "oshibki-grammatika", f"fix {x.get('id')}")
        need(is_str_list(x.get("astra_rows")) and x["astra_rows"], "oshibki-grammatika", f"astra_rows {x.get('id')}")
        codes.append(x["code"])
        eids.append(x["id"])
    need(len(set(codes)) == len(codes) and len(set(eids)) == len(eids), "oshibki-grammatika", "дубль code/id")
    rows = [r for x in ents for r in x["astra_rows"]]
    need(sorted(rows) == sorted(pin["astra_52_rows"]) and len(set(rows)) == len(rows), "oshibki-nepolny",
         f"строк {len(set(rows) & set(pin['astra_52_rows']))}/{len(pin['astra_52_rows'])}")
    need(set(pin["ids_119"]) <= set(eids), "oshibki-nepolny",
         "без id 119: " + ",".join(sorted(set(pin["ids_119"]) - set(eids))))
    closed = sorted(x["id"] for x in ents if x["disposition"] == "CLOSED_BY_119")
    need(closed == sorted(pin["closed_by_119"]), "oshibki-protivorechat-119", ",".join(closed))
    by_row = {r: x for x in ents for r in x["astra_rows"]}
    for row, art in eg["spec_120_required"].items():
        x = by_row[row]
        need(x["disposition"] == "SPEC_120" and x.get("spec_artifact") == art,
             "oshibki-ne-zakryty-specifikaciej", f"{x['id']}")
    for x in ents:
        if x["disposition"] == "SPEC_120":
            need(x.get("spec_artifact") in g["artifacts"], "oshibki-ne-zakryty-specifikaciej", x["id"])

    # --- release-graph.json ---
    gg = g["graph"]
    gr = docs["release-graph.json"]
    nodes = gr.get("nodes")
    need(isinstance(nodes, list) and all(isinstance(n, dict) for n in nodes), "graf-nevaliden", "nodes")
    nids = [n.get("id") for n in nodes]
    need(all(isinstance(i, str) for i in nids) and len(set(nids)) == len(nids), "graf-nevaliden", "id")
    kind = {n["id"]: n.get("kind") for n in nodes}
    deps = {n["id"]: n.get("depends_on") for n in nodes}
    for i in nids:
        need(kind[i] in gg["kinds"], "graf-nevaliden", f"kind {i}")
        need(is_str_list(deps[i]) and set(deps[i]) <= set(nids), "graf-nevaliden", f"depends_on {i}")
    for req, kd in ((gg["shared_core"], "SHARED"), (gg["consumer_v1"], "CONSUMER"),
                    (gg["consumer_real"], "CONSUMER"), (gg["broker_app"], "BROKER_APP")):
        need(kind.get(req) == kd, "graf-nevaliden", req)
    # класс узла — из пина и грамматики по id; kind проверяемого обязан с ним согласиться
    klass = {gg["shared_core"]: "SHARED", gg["consumer_v1"]: "CONSUMER",
             gg["consumer_real"]: "CONSUMER", gg["broker_app"]: "BROKER_APP"}
    klass.update({p: "PROCESS" for p in g["processes"]})
    klass.update({p: "PARTNER" for p in pin["partner_steps_119"]})
    klass.update({e: "EXTERNAL" for e in pin["external_dependencies"]})
    for i in nids:
        need(i not in klass or kind[i] == klass[i], "graf-kind-protiv-pina", f"{i}: {kind[i]}, по пину {klass.get(i)}")
    color = {}

    def dfs(n):
        color[n] = 1
        for m in deps[n]:
            if color.get(m) == 1:
                red("graf-ciklichen", f"{n}->{m}")
            if m not in color:
                dfs(m)
        color[n] = 2

    for i in nids:
        if i not in color:
            dfs(i)
    cv1 = closure(gg["consumer_v1"], deps)
    v1_allowed = {gg["shared_core"]} | set(g["processes"])
    extra = sorted(cv1 - v1_allowed)
    need(not extra, "graf-ne-consumer-first", ",".join(extra))
    proc_nodes = sorted(i for i in nids if kind[i] == "PROCESS")
    need(proc_nodes == sorted(g["processes"]) and set(g["processes"]) <= cv1, "graf-nepolny", "процессы")
    need(gg["shared_core"] in cv1, "graf-nepolny", "consumer_v1 без общего ядра")
    ext_nodes = {i for i in nids if kind[i] == "EXTERNAL"}
    need(ext_nodes <= set(pin["external_dependencies"]), "graf-nepolny", "внешние вне плана 119")
    creal = closure(gg["consumer_real"], deps)
    need(gg["consumer_v1"] in creal and {r["external"] for r in g["processes"].values()} <= creal,
         "graf-nepolny", "consumer_real")
    part = {i for i in nids if kind[i] == "PARTNER"}
    need(set(pin["partner_steps_119"]) <= part, "graf-nepolny", "шаги partner 119")
    for i in sorted(part | {gg["broker_app"]}):
        need(gg["shared_core"] in closure(i, deps), "graf-nepolny", f"{i} без общего ядра")

    # --- README_RU.md ---
    with open(os.path.join(sd, "README_RU.md"), encoding="utf-8", errors="replace") as fh:
        lines = fh.read().splitlines()
    for a in g["artifacts"]:
        if a.endswith(".json"):
            pat = re.compile(r"^- `" + re.escape(a) + r"`( — .+)?$")
            need(any(pat.match(l) for l in lines), "readme-bez-ssylok", a)
    return len(new_all), len(ents), len(nodes)


def main(argv):
    args = list(argv)
    pin_path = os.path.join(HERE, "pin_120.json")
    if "--pin" in args:
        i = args.index("--pin")
        if i + 1 >= len(args):
            print("использование: mobility_spec_oracle.py <репо> [--pin <pin.json>]", file=sys.stderr)
            return 2
        pin_path = args[i + 1]
        del args[i:i + 2]
    if len(args) != 1 or not os.path.isdir(args[0]):
        print("использование: mobility_spec_oracle.py <репо> [--pin <pin.json>]", file=sys.stderr)
        return 2
    try:
        with open(pin_path, encoding="utf-8") as fh:
            pin = json.load(fh)
        with open(os.path.join(HERE, "grammatika_120.json"), encoding="utf-8") as fh:
            g = json.load(fh)
    except (OSError, ValueError) as e:
        print(f"нечем судить: {e}", file=sys.stderr)
        return 2
    try:
        n_new, n_err, n_nodes = judge(args[0], pin, g)
    except Red as r:
        print(f"ОТКАЗ: mobility120: {r}")
        return 1
    except Nechem as e:
        print(f"нечем судить: {e}", file=sys.stderr)
        return 2
    print(f"MOBILITY120_OK processes=5 new_operations={n_new} errors={n_err} "
          f"nodes={n_nodes} pin={pin.get('world')}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
