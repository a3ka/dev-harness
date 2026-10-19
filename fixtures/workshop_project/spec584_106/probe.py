#!/usr/bin/env python3
# Контракт 106 (CMP-BCK-133, спецификация 5.8.4, a3ka/Complior-back#148) —
# красная батарея архитектора dev-harness. Форма — батарея 993
# (fixtures/workshop_project/validator_993/probe.py): контроль обязан быть
# зелёным на честном дереве C, каждая обманная копия отвергается ТОЧНОЙ
# именованной причиной, ожидания снимаются в память ДО вызова субъекта,
# сверка структурная (точное членство строки в списке, не подстрока).
#
# Оракул независим от проверяемого дерева: числа 163/19/51, пятёрка CAS-операций
# и состав ключей x-cas-semantics сняты ЗАМЕРОМ базы B (ветка
# cmp-bck-121/validator-5-8-3 @ 0230ee0, отчёт tests/validate_contract_v3_9.py:
# 57 отказов = 5 *_cas + 1 revokePartnerGrant_conditional_policy +
# 51 *_source_consumers) и запечены здесь и в consumer-ops-51.json рядом.
# Диск проверяемого как источник ожиданий не перечитывается.
#
# rc 0 — контроль зелён И каждый мутант отвергнут ровно своей причиной;
# rc 1 — расхождение (в т.ч. красный контроль на до-предметном дереве —
#        честное состояние базы, а не сбой батареи);
# rc 2 — 106 UNMEASURABLE: нет репо/зависимостей/пустая выборка --case;
#        нерезрешимый пин базы B (BASE_UNRESOLVABLE) либо клетка, чья
#        мутация побайтно не меняет вход (MUTATION_NOOP) — ошибка батареи,
#        а не «не отклонено»: отрицательный вход обязан отличаться от
#        зелёного контроля (Н-39), честная поставка не обязана отвергать
#        побайтно равный контролю вход.
#
# Вызов: <PY> probe.py --repo R --out OUT [--case NAME]
#   R   — полный disposable checkout Complior-back;
#   OUT — новый несуществующий каталог;
#   PY  — python с jsonschema+yaml (requirements-validation.txt).

import argparse
import hashlib
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

PIN_OP_COUNT = 163
PIN_DEPRECATED = 19
PIN_CONSUMER_OPS_COUNT = 51
CAS_OPS = ["acknowledgeDisclosure", "revokeApproval", "revokePermission",
           "requestAction", "revokePartnerGrant"]
# Четыре операции — только версионная защита; revokePermission — закрытый выбор
# из двух (версионный CAS либо идемпотентный отзыв с серверной перепроверкой),
# решение архитектора бэкенда 2026-10-18 §CAS.
IDEMPOTENT_ALLOWED = {"revokePermission"}
CAS_SEMANTICS_KEYS = ["version_source", "retry", "stale_version",
                      "completed_action", "concurrent_execution"]
OPENAPI = "contracts/BrokerOS_Unified_OpenAPI_v3.yaml"
INDEX = "contracts/operation-index.json"
BINDINGS = "contracts/frontend-consumer-bindings.json"
ALIGNMENT = "contracts/backend-5_8_4-alignment.json"
RUNNER = "tools/run_backend_ci.py"
TYPED_KIND = "mobile lifecycle/service"
PENDING_MARKER = "BACKEND_ADOPTION_PENDING"
UNMEASURABLE = "106 UNMEASURABLE"
# До-предметная база B — дерево замера 57 отказов («993 implementer fix
# round 5»). Полный пин проверен git cat-file -e в свежем клоне origin и
# в снимке c995/back; заявленный в первом круге sha 0230ee06867d… не
# разрешался нигде (erratum r1). Клетка version_only материалит этот пин
# из объектного магазина субъекта R (git archive) — её вход отличен от C.
PIN_BASE_COMMIT = "0230ee068d10047b1be99c26747aef1bd1579bcf"


def sha256(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def load_ops(api: dict) -> dict:
    ops = {}
    for path_item in (api.get("paths") or {}).values():
        if not isinstance(path_item, dict):
            continue
        for method, op in path_item.items():
            if method in ("get", "post", "put", "patch", "delete") and isinstance(op, dict):
                oid = op.get("operationId")
                if oid:
                    ops[oid] = op
    return ops


def _nonempty(v) -> bool:
    return (isinstance(v, str) and v.strip()) or (isinstance(v, (list, dict)) and v)


def structural_reds(root: Path) -> list:
    """Независимый структурный оракул. Возвращает список именованных причин."""
    reds = []
    try:
        import yaml
        api = yaml.safe_load((root / OPENAPI).read_text(encoding="utf-8"))
    except Exception as e:  # pragma: no cover
        return ["STRUCTURE_UNREADABLE:%s:%s" % (OPENAPI, type(e).__name__)]
    version = ((api.get("info") or {}).get("version")) or ""
    if version != "5.8.4":
        reds.append("VERSION_NOT_584:" + str(version))
    ops = load_ops(api)
    if len(ops) != PIN_OP_COUNT:
        reds.append("OPSET_COUNT_DRIFT:%d!=%d" % (len(ops), PIN_OP_COUNT))
    dep = sum(1 for op in ops.values() if op.get("deprecated"))
    if dep != PIN_DEPRECATED:
        reds.append("OPSET_DEPRECATED_DRIFT:%d!=%d" % (dep, PIN_DEPRECATED))
    for oid in CAS_OPS:
        op = ops.get(oid)
        if op is None:
            reds.append("CAS_OP_MISSING:" + oid)
            continue
        policy = op.get("x-command-policy") or {}
        precond = policy.get("precondition")
        allowed = {"VERSIONED_TARGET_CAS"}
        if oid in IDEMPOTENT_ALLOWED:
            allowed = allowed | {"IDEMPOTENT_TARGET_REVOKE"}
        if precond not in allowed:
            reds.append("CAS_PROFILE:%s:precondition=%s" % (oid, precond))
            continue
        params = [p for p in (op.get("parameters") or [])
                  if isinstance(p, dict) and p.get("name") == "If-Match"]
        responses = op.get("responses") or {}
        if precond == "VERSIONED_TARGET_CAS":
            required_match = [p for p in params if p.get("required") is True]
            if not required_match:
                reds.append("CAS_PROFILE:%s:if_match_not_required" % oid)
            if "412" not in responses or "428" not in responses:
                reds.append("CAS_PROFILE:%s:missing_412_428" % oid)
        else:  # IDEMPOTENT_TARGET_REVOKE — серверная перепроверка ресурса и scope
            recheck = policy.get("server_recheck") or {}
            if not (isinstance(recheck, dict) and recheck.get("resource")
                    and recheck.get("scope") and policy.get("repeat_safe") is True):
                reds.append("CAS_PROFILE:%s:idempotent_without_recheck" % oid)
        sem = op.get("x-cas-semantics")
        if not isinstance(sem, dict):
            reds.append("CAS_SEMANTICS_MISSING:" + oid)
        else:
            for key in CAS_SEMANTICS_KEYS:
                if not _nonempty(sem.get(key)):
                    reds.append("CAS_SEMANTICS_HOLLOW:%s:%s" % (oid, key))
        cond = op.get("x-conditional-policy")
        if not isinstance(cond, dict):
            reds.append("CAS_CONDITIONAL_NOT_STRUCTURED:" + oid)
    index = json.loads((root / INDEX).read_text(encoding="utf-8"))
    if index.get("operation_count") != PIN_OP_COUNT:
        reds.append("OPSET_COUNT_DRIFT_INDEX:%s!=%d"
                    % (index.get("operation_count"), PIN_OP_COUNT))
    if index.get("deprecated_operation_count") != PIN_DEPRECATED:
        reds.append("OPSET_DEPRECATED_DRIFT_INDEX:%s!=%d"
                    % (index.get("deprecated_operation_count"), PIN_DEPRECATED))
    # Согласование вызывающих сторон: список изменённых требований к запросам
    # и проверка всех вызывающих сторон (mobile, web, workers) — решение
    # архитектора бэкенда 2026-10-18 §Порядок п.3.
    align_path = root / ALIGNMENT
    if not align_path.exists():
        reds.append("ALIGNMENT_MISSING")
    else:
        try:
            align = json.loads(align_path.read_text(encoding="utf-8"))
        except Exception:
            align = None
            reds.append("ALIGNMENT_UNREADABLE")
        if isinstance(align, dict):
            cas_list = align.get("cas_operations")
            if sorted(cas_list or []) != sorted(CAS_OPS):
                reds.append("ALIGNMENT_CAS_OPS")
            reqs = align.get("changed_request_requirements")
            if isinstance(reqs, dict):
                for oid in CAS_OPS:
                    if not _nonempty(reqs.get(oid)):
                        reds.append("ALIGNMENT_REQUIREMENTS:" + oid)
            else:
                reds.append("ALIGNMENT_REQUIREMENTS:not_a_mapping")
            callers = align.get("callers")
            if isinstance(callers, dict):
                for surface in ("mobile", "web", "workers"):
                    if not _nonempty(callers.get(surface)):
                        reds.append("ALIGNMENT_CALLERS:" + surface)
            else:
                reds.append("ALIGNMENT_CALLERS:not_a_mapping")
    runner_text = (root / RUNNER).read_text(encoding="utf-8") if (root / RUNNER).exists() else ""
    if "validate_contract_v3_9" not in runner_text:
        reds.append("VALIDATOR_NOT_IN_CI_RUNNER")
    # lane-таблица раннера — точка проводки: агрегат required в ci.yml делает
    # каждый lane обязательным; плейсхолдер @not-run = «объявлена, но не
    # исполняется» (CMP-BCK-130: команды lanes живут в run_backend_ci.py)
    if "NOT_RUN до CMP-BCK-121" in runner_text or "'@not-run'" in runner_text:
        reds.append("VALIDATOR_NOT_RUN_PLACEHOLDER")
    return reds


def run_validator(repo: Path, out: Path, py: str) -> dict:
    """Живой вызов настоящего CLI. rc и отчёт — в память вызывающего."""
    proc = subprocess.run(
        [py, "tests/validate_contract_v3_9.py", "--out", str(out)],
        cwd=str(repo), capture_output=True, text=True)
    report = None
    cand = out / "contract-validation.json"
    if cand.exists():
        try:
            report = json.loads(cand.read_text(encoding="utf-8"))
        except Exception:
            report = None
    return {"rc": proc.returncode, "report": report,
            "stdout": proc.stdout, "stderr": proc.stderr}


def regen_drift(root: Path, scratch: Path, py: str):
    """Производные согласованы с источниками: повторная генерация — no-op
    на паре канонических файлов. Ожидание (sha ДО) снимается в память ДО
    вызова генератора."""
    before = {p: sha256(root / p) for p in (INDEX, BINDINGS)}
    proc = subprocess.run([py, "tools/generate_derived.py"], cwd=str(scratch),
                          capture_output=True, text=True)
    reds = []
    if proc.returncode != 0:
        reds.append("DERIVED_DRIFT:generator_rc=%d" % proc.returncode)
    for p, was in before.items():
        now = sha256(scratch / p)
        if now != was:
            reds.append("DERIVED_DRIFT:" + p)
    return reds, {"rc": proc.returncode, "stdout": proc.stdout,
                  "stderr": proc.stderr}


def yaml_load(root: Path) -> dict:
    import yaml
    return yaml.safe_load((root / OPENAPI).read_text(encoding="utf-8"))


def yaml_dump(root: Path, api: dict) -> None:
    import yaml
    (root / OPENAPI).write_text(
        yaml.safe_dump(api, allow_unicode=True, sort_keys=False, width=10 ** 6),
        encoding="utf-8")


def tree_digest(root: Path) -> dict:
    """Побайтовый снимок дерева клетки: {относительный путь: sha256}."""
    return {str(p.relative_to(root)): sha256(p)
            for p in sorted(root.rglob("*")) if p.is_file()}


def materialize_base(src: Path, dst: Path) -> bool:
    """До-предметный вход B из объектного магазина субъекта: git archive.
    False — пин не разрешим в R (батарея немеряема, а не «не отклонено»)."""
    import io
    import tarfile
    chk = subprocess.run(["git", "-C", str(src), "cat-file", "-e",
                          PIN_BASE_COMMIT + "^{commit}"], capture_output=True)
    if chk.returncode != 0:
        return False
    arc = subprocess.run(["git", "-C", str(src), "archive", "--format=tar",
                          PIN_BASE_COMMIT], capture_output=True)
    if arc.returncode != 0:
        return False
    dst.mkdir(parents=True)
    with tarfile.open(fileobj=io.BytesIO(arc.stdout)) as tf:
        try:
            tf.extractall(dst, filter="data")
        except TypeError:  # python < 3.12 без filter=
            tf.extractall(dst)
    return True


def mut_version_only(dst: Path) -> bool:
    api = yaml_load(dst)
    api["info"]["version"] = "5.8.4"
    yaml_dump(dst, api)
    return True


def mut_cas_rename(dst: Path) -> bool:
    api = yaml_load(dst)
    op = load_ops(api)["acknowledgeDisclosure"]
    op.setdefault("x-command-policy", {})["precondition"] = \
        "CREATE_OR_APPEND_NO_TARGET_CAS"
    yaml_dump(dst, api)
    return True


def mut_cas_no_match_header(dst: Path) -> bool:
    api = yaml_load(dst)
    op = load_ops(api)["revokePartnerGrant"]
    op["parameters"] = [p for p in (op.get("parameters") or [])
                        if not (isinstance(p, dict) and p.get("name") == "If-Match")]
    yaml_dump(dst, api)
    return True


def mut_consumer_kind_pending(dst: Path) -> bool:
    path = dst / BINDINGS
    text = path.read_text(encoding="utf-8")
    n = text.count('"%s"' % TYPED_KIND)
    if n == 0:
        return False
    path.write_text(text.replace('"%s"' % TYPED_KIND,
                                 '"%s"' % PENDING_MARKER), encoding="utf-8")
    return True


def mut_cas_key_hollow(dst: Path) -> bool:
    api = yaml_load(dst)
    op = load_ops(api)["revokeApproval"]
    op.setdefault("x-cas-semantics", {})["completed_action"] = ""
    yaml_dump(dst, api)
    return True


def mut_cas_idempotent_no_recheck(dst: Path) -> bool:
    api = yaml_load(dst)
    op = load_ops(api)["revokePermission"]
    pol = op.setdefault("x-command-policy", {})
    pol["precondition"] = "IDEMPOTENT_TARGET_REVOKE"
    pol.pop("server_recheck", None)
    pol.pop("repeat_safe", None)
    yaml_dump(dst, api)
    return True


def mut_mass_defer(dst: Path) -> bool:
    path = dst / INDEX
    index = json.loads(path.read_text(encoding="utf-8"))
    extra = json.loads((Path(__file__).parent / "consumer-ops-51.json")
                       .read_text(encoding="utf-8"))[:30]
    ids = set(index.get("deprecated_operation_ids") or []) | set(extra)
    index["deprecated_operation_ids"] = sorted(ids)
    index["deprecated_operation_count"] = len(ids)
    path.write_text(json.dumps(index, ensure_ascii=False, indent=2), encoding="utf-8")
    return True


def mut_delete_op(dst: Path) -> bool:
    path = dst / INDEX
    index = json.loads(path.read_text(encoding="utf-8"))
    rows = [r for r in index["operations"]
            if r.get("operation_id") != "streamMissionEvents"]
    if len(rows) == len(index["operations"]):
        return False
    index["operations"] = rows
    index["operation_count"] = len(rows)
    path.write_text(json.dumps(index, ensure_ascii=False, indent=2), encoding="utf-8")
    return True


def mut_manual_derived(dst: Path) -> bool:
    path = dst / INDEX
    path.write_text(path.read_text(encoding="utf-8") + "\n", encoding="utf-8")
    return True


def mut_runner_placeholder(dst: Path) -> bool:
    # моделирует «обязательная проверка объявлена, но не исполняется»:
    # живая команда валидатора в lane-таблице заменяется плейсхолдером @not-run
    path = dst / RUNNER
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines(keepends=True)
    out = []
    replaced = False
    for line in lines:
        if "validate_contract_v3_9" in line and not replaced:
            indent = line[:len(line) - len(line.lstrip())]
            out.append("%s('static', 'validate_contract_v3_9 — NOT_RUN до CMP-BCK-121 (контракт 993)', '@not-run'),\n" % indent)
            replaced = True
        else:
            out.append(line)
    if not replaced:
        return False
    path.write_text("".join(out), encoding="utf-8")
    return True


def mut_alignment_hollow(dst: Path) -> bool:
    path = dst / ALIGNMENT
    if not path.exists():
        return False
    data = json.loads(path.read_text(encoding="utf-8"))
    reqs = data.get("changed_request_requirements")
    if not isinstance(reqs, dict) or not _nonempty(reqs.get("revokePermission")):
        return False
    reqs["revokePermission"] = ""
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    return True


def cases():
    """ЕДИНСТВЕННЫЙ источник перечня. Каждая обманная копия привязана кодом
    к входу, на котором её дефект наблюдаем, и к точной ожидаемой причине."""
    return [
        {"name": "version_only", "kind": "validator", "base": "B",
         "mutate": mut_version_only,
         "expect_id": "acknowledgeDisclosure_cas",
         "why": "номер 5.8.4 сам совместимости не даёт; вход — закреплённая "
                "до-предметная база B (CAS-пятёрка не реализована), версия "
                "поднята без остального: вход отличен от зелёного C"},
        {"name": "cas_rename", "kind": "validator",
         "mutate": mut_cas_rename,
         "expect_id": "acknowledgeDisclosure_cas",
         "why": "переименование профиля вместо версионной защиты"},
        {"name": "cas_no_match_header", "kind": "validator",
         "mutate": mut_cas_no_match_header,
         "expect_id": "revokePartnerGrant_cas",
         "why": "версия гранта без обязательного strong target If-Match"},
        {"name": "consumer_kind_pending", "kind": "validator",
         "mutate": mut_consumer_kind_pending,
         "expect_id": "streamMissionEvents_source_consumers",
         "why": "статус ожидания — не подтверждённый потребитель"},
        {"name": "cas_key_hollow", "kind": "structural",
         "mutate": mut_cas_key_hollow,
         "expect_red": "CAS_SEMANTICS_HOLLOW:revokeApproval:completed_action",
         "why": "поле семантики без содержания"},
        {"name": "cas_idempotent_no_recheck", "kind": "structural",
         "mutate": mut_cas_idempotent_no_recheck,
         "expect_red": "CAS_PROFILE:revokePermission:idempotent_without_recheck",
         "why": "идемпотентный отзыв без серверной перепроверки"},
        {"name": "mass_defer", "kind": "structural",
         "mutate": mut_mass_defer,
         "expect_red": "OPSET_DEPRECATED_DRIFT_INDEX",
         "why": "массовое откладывание ради зелёной проверки"},
        {"name": "delete_op", "kind": "structural",
         "mutate": mut_delete_op,
         "expect_red": "OPSET_COUNT_DRIFT_INDEX",
         "why": "удаление операции вместо подтверждения потребителя"},
        {"name": "manual_derived", "kind": "regen",
         "mutate": mut_manual_derived,
         "expect_red": "DERIVED_DRIFT:contracts/operation-index.json",
         "why": "ручная правка производного реестра"},
        {"name": "runner_placeholder", "kind": "structural",
         "mutate": mut_runner_placeholder,
         "expect_red": "VALIDATOR_NOT_RUN_PLACEHOLDER",
         "why": "обязательная проверка объявлена, но не исполняется"},
        {"name": "alignment_hollow", "kind": "structural",
         "mutate": mut_alignment_hollow,
         "expect_red": "ALIGNMENT_REQUIREMENTS:revokePermission",
         "why": "список изменённых требований без содержания по операции"},
        {"name": "lane_swallows_validator_red", "kind": "lane",
         "mutate": mut_cas_rename,
         "expect": "LANE_PROPAGATES_VALIDATOR_RED",
         "why": "отказ валидатора обязан распространяться через lane "
                "package: rc!=0 и FAIL-строка валидатора в отчёте раннера, "
                "а не только подстрока в lane-таблице"},
    ]


def copy_repo(src: Path, dst: Path) -> None:
    shutil.copytree(src, dst, ignore=shutil.ignore_patterns(".git", "node_modules"))


def _dump(out: Path, raw: dict, mismatches: list, n: int,
          control_green: bool, control_reds: list) -> dict:
    summary = {"control_green": control_green,
               "control_reds": control_reds,
               "cases": n,
               "rejected": n - len(mismatches),
               "mismatches": mismatches}
    (out / "raw.json").write_text(json.dumps(raw, ensure_ascii=False, indent=1),
                                  encoding="utf-8")
    (out / "summary.json").write_text(json.dumps(summary, ensure_ascii=False,
                                                 indent=1), encoding="utf-8")
    return summary


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--py", default=sys.executable)
    ap.add_argument("--case", default=None)
    args = ap.parse_args()

    repo = Path(args.repo).resolve()
    out = Path(args.out).resolve()
    py = args.py
    pin_ops = json.loads((Path(__file__).parent / "consumer-ops-51.json")
                         .read_text(encoding="utf-8"))
    if len(pin_ops) != PIN_CONSUMER_OPS_COUNT:
        print("%s: PIN_BROKEN consumer ops %d!=%d"
              % (UNMEASURABLE, len(pin_ops), PIN_CONSUMER_OPS_COUNT))
        return 2
    if not repo.is_dir() or not (repo / OPENAPI).exists():
        print("%s: NO_REPO %s" % (UNMEASURABLE, repo))
        return 2
    try:
        import yaml  # noqa: F401
        import jsonschema  # noqa: F401
    except Exception as e:
        print("%s: NO_DEPS %s" % (UNMEASURABLE, type(e).__name__))
        return 2
    if out.exists():
        print("%s: OUT_EXISTS %s" % (UNMEASURABLE, out))
        return 2
    out.mkdir(parents=True)
    raw = {"pin": {"op_count": PIN_OP_COUNT, "deprecated": PIN_DEPRECATED,
                   "consumer_ops": PIN_CONSUMER_OPS_COUNT, "cas_ops": CAS_OPS},
           "control": {}, "cases": []}
    selected = [c for c in cases()
                if args.case is None or c["name"] == args.case]
    if not selected:
        print("%s: EMPTY_SELECTION %s" % (UNMEASURABLE, args.case))
        return 2

    # ── КОНТРОЛЬ: ожидания в памяти ДО вызова субъекта ──
    reds = structural_reds(repo)
    scratch = Path(tempfile.mkdtemp(prefix="spec584-control-"))
    copy_repo(repo, scratch / "repo")
    regen_reds, regen_log = regen_drift(repo, scratch / "repo", py)
    reds += regen_reds
    raw["control"]["structural_reds"] = reds
    raw["control"]["regen"] = regen_log
    val = run_validator(repo, out / "control", py)
    val_reds = []
    if val["rc"] != 0:
        val_reds.append("VALIDATOR_RC_%d" % val["rc"])
    rep = val["report"] or {}
    if rep.get("status") != "PASS_STATIC":
        val_reds.append("VALIDATOR_STATUS_%s" % rep.get("status"))
    fids = rep.get("failure_ids") or []
    if fids:
        cas_n = sum(1 for x in fids if x.endswith("_cas"))
        cons_n = sum(1 for x in fids if x.endswith("_source_consumers"))
        other = [x for x in fids if not x.endswith("_cas")
                 and not x.endswith("_source_consumers")]
        val_reds.append("VALIDATOR_FAILURES:%d(cas=%d,consumers=%d,other=%d:%s)"
                        % (len(fids), cas_n, cons_n, len(other),
                           ",".join(sorted(other))))
    raw["control"]["validator"] = {
        "rc": val["rc"], "failure_ids": fids,
        "stdout_tail": val["stdout"][-2000:], "stderr_tail": val["stderr"][-2000:]}
    control_reds = reds + val_reds
    raw["control"]["control_reds"] = control_reds
    control_green = not control_reds

    mismatches = []
    for case in selected:
        entry = {"name": case["name"], "kind": case["kind"]}
        if not control_green:
            entry["result"] = "BLOCKED_BY_RED_CONTROL"
            mismatches.append(case["name"] + ":BLOCKED_BY_RED_CONTROL")
            raw["cases"].append(entry)
            continue
        cdir = out / ("case-" + case["name"])
        cdir.mkdir()
        crepo = cdir / "repo"
        if case.get("base") == "B":
            if not materialize_base(repo, crepo):
                entry["result"] = "BASE_UNRESOLVABLE"
                raw["cases"].append(entry)
                _dump(out, raw, mismatches, len(selected),
                      control_green, control_reds)
                shutil.rmtree(scratch, ignore_errors=True)
                print("%s: BASE_UNRESOLVABLE %s"
                      % (UNMEASURABLE, PIN_BASE_COMMIT[:12]))
                return 2
        else:
            copy_repo(repo, crepo)
        before = tree_digest(crepo)
        applied = case["mutate"](crepo)
        entry["mutated"] = applied
        if not applied:
            entry["result"] = "MUTANT_NOT_APPLIED"
            mismatches.append(case["name"] + ":MUTANT_NOT_APPLIED")
            raw["cases"].append(entry)
            continue
        # Инвариант (Н-39): мутация клетки обязана менять вход. Побайтно
        # равный контролю вход — дефект батареи (rc 2), а не «не отклонено».
        entry["byte_equal"] = tree_digest(crepo) == before
        if entry["byte_equal"]:
            entry["result"] = "MUTATION_NOOP"
            raw["cases"].append(entry)
            _dump(out, raw, mismatches, len(selected),
                  control_green, control_reds)
            shutil.rmtree(scratch, ignore_errors=True)
            print("%s: MUTATION_NOOP %s" % (UNMEASURABLE, case["name"]))
            return 2
        if case["kind"] == "validator":
            run = run_validator(crepo, cdir / "validator-out", py)
            fids = (run["report"] or {}).get("failure_ids") or []
            entry["validator_rc"] = run["rc"]
            entry["failure_ids_head"] = fids[:20]
            ok = run["rc"] == 1 and case["expect_id"] in fids
            entry["expected_id"] = case["expect_id"]
            entry["result"] = "REJECTED_EXACT" if ok else "NOT_REJECTED"
        elif case["kind"] == "structural":
            got = structural_reds(crepo)
            ok = any(r == case["expect_red"] or r.startswith(case["expect_red"])
                     for r in got)
            entry["reds"] = got
            entry["expected_red"] = case["expect_red"]
            entry["result"] = "REJECTED_EXACT" if ok else "NOT_REJECTED"
        elif case["kind"] == "lane":
            proc = subprocess.run(
                [py, RUNNER, "--lane", "package", "--out",
                 str(cdir / "lane-out")],
                cwd=str(crepo), capture_output=True, text=True)
            fail_lines = [ln for ln in proc.stdout.splitlines()
                          if ln.startswith("[package] FAIL")
                          and "validate_contract_v3_9" in ln]
            entry["lane_rc"] = proc.returncode
            entry["lane_fail_validator"] = fail_lines[:3]
            entry["expected"] = case["expect"]
            ok = proc.returncode != 0 and bool(fail_lines)
            entry["result"] = "REJECTED_EXACT" if ok else "NOT_REJECTED"
        else:  # regen
            rr, log = regen_drift(crepo, crepo, py)
            ok = any(r == case["expect_red"] or r.startswith(case["expect_red"])
                     for r in rr)
            entry["reds"] = rr
            entry["expected_red"] = case["expect_red"]
            entry["regen_rc"] = log["rc"]
            entry["result"] = "REJECTED_EXACT" if ok else "NOT_REJECTED"
        if entry["result"] != "REJECTED_EXACT":
            mismatches.append(case["name"] + ":" + entry["result"])
        raw["cases"].append(entry)
    shutil.rmtree(scratch, ignore_errors=True)
    summary = _dump(out, raw, mismatches, len(selected),
                    control_green, control_reds)
    print("106 battery " + json.dumps(summary, ensure_ascii=False))
    return 0 if (control_green and not mismatches) else 1


if __name__ == "__main__":
    sys.exit(main())
