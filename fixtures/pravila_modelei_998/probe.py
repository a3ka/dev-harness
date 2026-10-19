#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""998 pravila-modelei — красная проба: правила работы моделей в одном месте.

Субъект — дерево харнесса: каталог, содержащий эту фикстуру, либо
PROBE_SUBJECT_ROOT (доказательство достижимости на отдельной копии).

Правило 8 (AGENTS.md): ВСЕ ожидания и инварианты неизменности исходного
config/agent_models.json снимаются в память ДО первого вызова субъекта
(AM0 ниже, импорт модуля); после запуска субъекта диск проверяемого дерева
как источник ожиданий не перечитывается — он только сверяется с предзагрузкой.

Режимы: --cases (предъявление на дереве субъекта), --matrix (различимость
барьера: честная модель и обманные формы на мутациях seed-дерева), --case ИМЯ.

Коды возврата: 0 — ожидания совпали; 1 — расхождение (каждая клетка печатает
имя, реальный исход, ожидание и именованную причину); 2 — нет входа.
"""
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.realpath(__file__))
SUBJECT = os.path.realpath(
    os.environ.get("PROBE_SUBJECT_ROOT")
    or os.path.dirname(os.path.dirname(HERE))
)

# ── Оракул: константы ожиданий ───────────────────────────────────────────────
ROUTING_HEADER = "## Правила выбора роли (routing — config/agent_models.json)"
ROLE_GLM = "implementer-glm"
TIER_NAME = "task-glm"
TIER_MODEL = "@glm"
TIER_FALLBACK = "@sonnet"
STALE_UNTIL = "роли нет до контракта pravila-modelei"
AGENTS_OLD_TOKENS = ("перевёрнуто", "на MiniMax")  # строки старого нарратива
AGENTS_OLD_HEAD = "Какую модель ведёт сессия"
D002_OLD_PAIR = ("implementer", "MiniMax")
D005_OLD_PAIR = ("своя роль", "apex")
CONSULTANT_OLD = "НЕ `@fable`"
CONSULTANT_NEW = "замена Astra — только Fable"
CONSULTANT_NEGATIONS = ("НЕ действует", "не действует", "вместо Astra", "разрешён Sonnet", "запрещает")
CONSULTANT_REF = "raskladka-modelei"
ORCH_NORM_TOKENS = ("config/agent_models.json", "routing", "отказ", "спавна", "не смена роли")
REF_A = "config/agent_models.json"
REF_B = "routing"

CASES = []


def case(name):
    def deco(fn):
        CASES.append((name, fn))
        return fn
    return deco


def unavailable(msg):
    print(f"NOT_IMPLEMENTED: {msg}", file=sys.stderr)
    sys.exit(2)


def run(cmd, cwd=None):
    p = subprocess.run(cmd, capture_output=True, text=True, cwd=cwd)
    return p.returncode, p.stdout, p.stderr


def read(path):
    with open(path, encoding="utf-8") as f:
        return f.read()


def first_line(text):
    for ln in text.splitlines():
        if ln.strip():
            return ln.strip()
    return ""


def paragraphs(text):
    return [blk for blk in re.split(r"\n\s*\n", text) if blk.strip()]


NODE = shutil.which("node") or unavailable("нет node")
SUBJECT_CFG = os.path.join(SUBJECT, "config", "agent_models.json")
if not os.path.isfile(SUBJECT_CFG):
    unavailable(f"нет config/agent_models.json субъекта: {SUBJECT_CFG}")

# ── ПРЕДЗАГРУЗКА (правило 8): всё, что станет ожиданием, читается ЗДЕСЬ,
# до первого запуска субъекта. Дальше эти значения не переопределяются.
AM0 = json.loads(read(SUBJECT_CFG))
AM0_TEXT = read(SUBJECT_CFG)
IMPL_BODY = read(os.path.join(SUBJECT, "roles", "implementer.md")) if os.path.isfile(
    os.path.join(SUBJECT, "roles", "implementer.md")) else None
ARCH_BODY = read(os.path.join(SUBJECT, "roles", "architect.md")) if os.path.isfile(
    os.path.join(SUBJECT, "roles", "architect.md")) else None


def body_text(raw):
    m = re.match(r"^---\n.*?\n---\n(.*)$", raw, re.S)
    return (m.group(1) if m else raw).strip("\n") + "\n"


def split_role_file(path):
    """(строки frontmatter, тело) или None, если файла нет."""
    if not os.path.isfile(path):
        return None
    t = read(path)
    m = re.match(r"^---\n(.*?)\n---\n(.*)$", t, re.S)
    if not m:
        return ([], t)
    return (m.group(1).split("\n"), m.group(2))


def routing_rules(am):
    rt = am.get("routing")
    if not isinstance(rt, dict) or not isinstance(rt.get("rules"), list):
        return []
    return [r for r in rt["rules"] if isinstance(r, dict)]


def grammar_violations(am):
    v = []
    rt = am.get("routing")
    if not isinstance(rt, dict):
        return ["routing: секция отсутствует или не объект"]
    for k in rt:
        if k in ("rules", "conditional", "emergency") or k.startswith("_"):
            continue
        v.append(f"routing: неизвестный ключ «{k}»")
    rules = rt.get("rules")
    if not isinstance(rules, list) or not rules:
        v.append("routing.rules: отсутствует или пуст")
    for i, r in enumerate(rules if isinstance(rules, list) else []):
        if not isinstance(r, dict):
            v.append(f"routing.rules[{i}]: не объект")
            continue
        for k in r:
            if k in ("class", "role", "tier", "constraint", "until") or k.startswith("_"):
                continue
            v.append(f"routing.rules[{i}]: неизвестный ключ «{k}»")
        if not isinstance(r.get("class"), str) or not r["class"].strip():
            v.append(f"routing.rules[{i}]: class не непустая строка")
        tgts = [k for k in ("role", "tier") if k in r]
        if len(tgts) != 1:
            v.append(f"routing.rules[{i}]: ровно один из role|tier, получено {len(tgts)}")
        elif not isinstance(r[tgts[0]], str) or not r[tgts[0]].strip():
            v.append(f"routing.rules[{i}].{tgts[0]}: не непустая строка")
        for f in ("constraint", "until"):
            if f in r and not isinstance(r[f], str):
                v.append(f"routing.rules[{i}].{f}: не строка")
    for k in ("conditional", "emergency"):
        if k in rt and not isinstance(rt[k], str):
            v.append(f"routing.{k}: не строка")
    return v


def refs_violations(am, root):
    v = []
    for i, r in enumerate(routing_rules(am)):
        if "role" in r:
            role = r["role"]
            if role not in am.get("roles", {}):
                v.append(f"routing.rules[{i}]: роль «{role}» отсутствует в roles-таблице config/agent_models.json")
            if not os.path.isfile(os.path.join(root, "roles", f"{role}.md")):
                v.append(f"routing.rules[{i}]: роли «{role}» нет файла roles/{role}.md")
        if "tier" in r:
            t = r["tier"]
            if t not in am.get("tiers", {}):
                v.append(f"routing.rules[{i}]: тира «{t}» нет в tiers")
    return v


def composition_violations(am, root):
    """Композиция «та же роль»: файл роли отличается ТОЛЬКО строкой role:,
    тир task-glm — живая цепочка (model/fallback/autoFallback как у task),
    производная modelRoles согласована."""
    v = []
    roles = am.get("roles", {})
    got = roles.get(ROLE_GLM)
    if got != TIER_NAME:
        v.append(f"roles.{ROLE_GLM} = {got!r}, ожидается «{TIER_NAME}»")
    spec = am.get("tiers", {}).get(TIER_NAME)
    task = am.get("tiers", {}).get("task")
    if not isinstance(spec, dict):
        v.append(f"tiers.{TIER_NAME} отсутствует")
    else:
        if spec.get("model") != TIER_MODEL:
            v.append(f"tiers.{TIER_NAME}.model = {spec.get('model')!r}, ожидается «{TIER_MODEL}»")
        if spec.get("fallback") != TIER_FALLBACK:
            v.append(f"tiers.{TIER_NAME}.fallback = {spec.get('fallback')!r}, ожидается «{TIER_FALLBACK}»")
        if spec.get("autoFallback") is not True:
            v.append(f"tiers.{TIER_NAME}.autoFallback = {spec.get('autoFallback')!r}, ожидается true (живая цепочка)")
        elif isinstance(task, dict) and task.get("autoFallback") is not True:
            v.append("tiers.task.autoFallback не true: цепочка task-glm повторяет мёртвую")
    impl = split_role_file(os.path.join(root, "roles", "implementer.md"))
    iglm = split_role_file(os.path.join(root, "roles", "implementer-glm.md"))
    if iglm is None:
        v.append(f"roles/{ROLE_GLM}.md не существует")
    elif impl is not None:
        fm_i, body_i = impl
        fm_g, body_g = iglm
        if body_i != body_g:
            v.append(f"тело roles/{ROLE_GLM}.md не байт-в-байт с roles/implementer.md")
        if len(fm_i) != len(fm_g):
            v.append(f"frontmatter roles/{ROLE_GLM}.md отличается числом строк от implementer.md")
        else:
            for a, b in zip(fm_i, fm_g):
                if a == b:
                    continue
                norm_b = b.replace(ROLE_GLM, "implementer")
                if norm_b != a:
                    v.append(f"frontmatter roles/{ROLE_GLM}.md расходится вне поля role:: {b.strip()!r}")
                    break
    omp_cfg = os.path.join(root, ".omp", "config.yml")
    if os.path.isfile(omp_cfg):
        models = am.get("models", {})
        fam = TIER_MODEL.lstrip("@")
        mid = models.get(fam, f"<{fam}>")
        if not any(re.match(r"^\s*" + re.escape(TIER_NAME) + r":\s*\"?" + re.escape(mid), ln)
                   for ln in read(omp_cfg).splitlines()):
            v.append(f".omp/config.yml modelRoles не несёт строку {TIER_NAME}: {mid}")
    return v


def render_section(stdout):
    """Строки секции routing в промпте (от заголовка до следующего '## ')."""
    lines = stdout.splitlines()
    if ROUTING_HEADER not in lines:
        return []
    start = lines.index(ROUTING_HEADER)
    section = []
    for ln in lines[start + 1:]:
        if ln.startswith("## "):
            break
        section.append(ln)
    return section


def render_problems(stdout, am):
    """Построчная структурная сверка секции routing в промпте: заголовок своей
    строкой; каждое правило — РОВНО одной строкой (несущей class, цель, а при
    наличии constraint/until — и их); conditional/emergency — своими строками;
    посторонних строк в секции нет. Сравнение — с ПРЕДЗГРУЖЕННЫМ am."""
    p = []
    section = render_section(stdout)
    if not section and ROUTING_HEADER not in stdout.splitlines():
        return [f"в промпте нет строки-заголовка «{ROUTING_HEADER}»"]
    rules = routing_rules(am)
    classes = [r.get("class") for r in rules]
    accounted = [False] * len(section)
    for i, r in enumerate(rules):
        cls = r.get("class")
        if not isinstance(cls, str) or not cls:
            continue
        cands = []
        if isinstance(r.get("role"), str):
            cands = [r["role"]]
        elif isinstance(r.get("tier"), str):
            cands = [r["tier"], "@" + r["tier"]]
        found = None
        for j, ln in enumerate(section):
            if not ln.strip():
                continue
            if cls in ln and any(c in ln for c in cands):
                others = [c for k, c in enumerate(classes)
                          if k != i and isinstance(c, str) and c in ln]
                if others:
                    p.append(
                        f"правило routing.rules[{i}]: строка рендера несёт class другого правила "
                        f"(«{others[0]}») — одно правило = одна строка"
                    )
                    continue
                found = j
                break
        if found is None:
            tgt = r.get("role") or r.get("tier")
            p.append(f"правило routing.rules[{i}] («{cls}» → {tgt}) не своей строкой в секции промпта")
            continue
        accounted[found] = True
        ln = section[found]
        for f in ("constraint", "until"):
            val = r.get(f)
            if isinstance(val, str) and val and val not in ln:
                p.append(f"routing.rules[{i}].{f} («{val}») не на строке правила в рендере")
    rt = am.get("routing")
    if isinstance(rt, dict):
        for k in ("conditional", "emergency"):
            val = rt.get(k)
            if isinstance(val, str) and val:
                j = next((j for j, ln in enumerate(section) if val in ln), None)
                if j is None:
                    p.append(f"{k}-строка routing («{val}») не отрендерена в промпт")
                else:
                    accounted[j] = True
    for j, ln in enumerate(section):
        if ln.strip() and not accounted[j]:
            p.append(f"посторонняя строка секции рендера routing: {ln.strip()[:60]!r}")
    return p


def agents_anchor_problems(text):
    """Структурная замена в AGENTS.md: старый абзац удалён ЦЕЛИКОМ (строки
    старого нарратива отсутствуют), абзац с заголовком «Какую модель ведёт
    сессия» — если жив — несёт ссылку; ссылка-строка существует."""
    v = []
    for tok in AGENTS_OLD_TOKENS:
        if tok in text:
            v.append(f"AGENTS.md: жива строка старого нарратива («…{tok}…»)")
    for para in paragraphs(text):
        if AGENTS_OLD_HEAD in para and not (REF_A in para and REF_B in para):
            v.append(f"AGENTS.md: абзац «{AGENTS_OLD_HEAD}» не замещён ссылкой (ссылка не ВМЕСТО него)")
    if not any(REF_A in ln and REF_B in ln for ln in text.splitlines()):
        v.append("AGENTS.md: нет строки-ссылки, несущей «config/agent_models.json» и «routing»")
    return v


def decision_anchor_problems(text, pair, label):
    v = []
    a, b = pair
    for ln in text.splitlines():
        if a in ln and b in ln:
            v.append(f"{label}: жива старая строка решения («{a}…{b}»)")
            break
    if not any(REF_A in ln and REF_B in ln for ln in text.splitlines()):
        v.append(f"{label}: нет строки-ссылки, несущей «config/agent_models.json» и «routing»")
    return v


def consultant_problems(text):
    v = []
    m = re.search(r"^## Модель\b(.*?)(?=^## |\Z)", text, re.S | re.M)
    sec = m.group(1) if m else text
    if CONSULTANT_OLD in sec or re.search(r"НЕ\s+@?`?fable", sec):
        v.append(f"§Модель: жива старая норма запрета («{CONSULTANT_OLD}»)")
    norm_lines = [ln for ln in sec.splitlines() if CONSULTANT_NEW in ln]
    if not norm_lines:
        v.append(f"§Модель: нет нормы «{CONSULTANT_NEW}»")
    for ln in norm_lines:
        for neg in CONSULTANT_NEGATIONS:
            if neg in ln:
                v.append(f"§Модель: строка нормы несёт противоположную полярность («{neg}»): {ln.strip()[:70]!r}")
                break
    if CONSULTANT_REF not in sec:
        v.append(f"§Модель: нет ссылки на docs/owner/2026-10-18-{CONSULTANT_REF}.md")
    return v


def orchestrator_norm_problems(text):
    hits = [ln for ln in text.splitlines() if all(t in ln for t in ORCH_NORM_TOKENS)]
    if not hits:
        return [
            "roles/orchestrator.md: нет нормы-строки (routing config/agent_models.json; "
            "при отказе спавна — доклад причины, не смена роли, Н-315)"
        ]
    return []


def copy_subject(dst):
    """Минимальное дерево для gen-harness: scripts/roles.ts + gen-harness.ts,
    roles/, config/agent_models.json, .omp/config.yml, .omp/agents/."""
    os.makedirs(os.path.join(dst, "scripts"), exist_ok=True)
    for f in ("gen-harness.ts", "roles.ts"):
        src = os.path.join(SUBJECT, "scripts", f)
        if not os.path.isfile(src):
            unavailable(f"у субъекта нет scripts/{f}")
        shutil.copy2(src, os.path.join(dst, "scripts", f))
    shutil.copytree(os.path.join(SUBJECT, "roles"), os.path.join(dst, "roles"))
    os.makedirs(os.path.join(dst, "config"), exist_ok=True)
    shutil.copy2(SUBJECT_CFG, os.path.join(dst, "config", "agent_models.json"))
    os.makedirs(os.path.join(dst, ".omp"), exist_ok=True)
    shutil.copy2(os.path.join(SUBJECT, ".omp", "config.yml"), os.path.join(dst, ".omp", "config.yml"))
    shutil.copytree(os.path.join(SUBJECT, ".omp", "agents"), os.path.join(dst, ".omp", "agents"))
    return dst


def json_edit(path, fn):
    am = json.loads(read(path))
    fn(am)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(am, f, ensure_ascii=False, indent=2)
        f.write("\n")
    return am


def clone_am(am):
    return json.loads(json.dumps(am))


# ── мутации отрицательного класса (Б1→К1 арбитража 998): ЗАКРЫТЫЙ перечень
# ветвей грамматики инварианта 1 — одна ветвь = один мутант = одна клетка
# gen_reject_* в обеих точках входа (--check и --prompt), с именованием
# routing, индекса правила и самого нарушителя. Порядок — нумерация перечня
# К1 вердикта арбитража (contracts-998-perechen-vetvej-v1); перечень
# порождает и предъявление, и матрицу (model_<name>), ветвь вне таблицы
# клеток не получает — таблица и есть граница класса.
def _rule(am, idx):
    return am["routing"]["rules"][idx]


def _first_tier_rule(am):
    for i, r in enumerate(am["routing"]["rules"]):
        if "tier" in r:
            return i
    return 0


def _alt_key(table, current):
    """Другой СУЩЕСТВУЮЩИЙ ключ той же таблицы (для мутаций целей К2)."""
    for k in table:
        if k != current:
            return k
    return None


# idx: int — статический индекс rules[N]; None — нарушение вне rules[N];
# "first_tier" — индекс первого tier-правила РЕШАЕТСЯ по мутируемому конфигу
# (субъект и seed различаются раскладкой правил).
ROUTING_BRANCHES = [
    ("K1.1", "missing_section",
     lambda am: am.pop("routing"),
     ["отсутствует"], None),
    ("K1.2", "routing_not_object",
     lambda am: am.update({"routing": [1]}),
     ["не объект"], None),
    ("K1.3", "rules_missing",
     lambda am: am["routing"].pop("rules"),
     ["rules"], None),
    ("K1.4", "rules_not_array",
     lambda am: am["routing"].update({"rules": {"x": 1}}),
     ["rules"], None),
    ("K1.5", "empty_rules",
     lambda am: am["routing"].update({"rules": []}),
     ["пуст"], None),
    ("K1.6", "unknown_routing_key",
     lambda am: am["routing"].update({"unknown-key-998": 1}),
     ["unknown-key-998"], None),
    ("K1.7", "rule_not_object",
     lambda am: am["routing"]["rules"].__setitem__(0, "строка"),
     ["не объект"], 0),
    ("K1.8", "unknown_rule_key",
     lambda am: _rule(am, 0).update({"priority": "high"}),
     ["priority"], 0),
    ("K1.9", "class_number",
     lambda am: _rule(am, 0).update({"class": 42}),
     ["class"], 0),
    ("K1.10", "class_blank",
     lambda am: _rule(am, 0).update({"class": "  "}),
     ["class"], 0),
    ("K1.11", "class_missing",
     lambda am: _rule(am, 0).pop("class"),
     ["class"], 0),
    ("K1.12", "target_number",
     lambda am: _rule(am, 0).update({"role": 7}),
     ["role"], 0),
    ("K1.13", "role_blank",
     lambda am: _rule(am, 0).update({"role": ""}),
     ["role"], 0),
    ("K1.14", "tier_number",
     lambda am: _rule(am, _first_tier_rule(am)).update({"tier": 5}),
     ["tier"], "first_tier"),
    ("K1.15", "tier_blank",
     lambda am: _rule(am, _first_tier_rule(am)).update({"tier": ""}),
     ["tier"], "first_tier"),
    ("K1.16", "constraint_number",
     lambda am: _rule(am, 0).update({"constraint": 42}),
     ["constraint"], 0),
    ("K1.17", "until_type",
     lambda am: _rule(am, 0).update({"until": ["x"]}),
     ["until"], 0),
    ("K1.18", "target_conflict",
     lambda am: _rule(am, 0).update({"tier": "default"}),
     ["role|tier"], 0),
    ("K1.19", "rule_no_target",
     lambda am: _rule(am, 1).pop("role"),
     ["role|tier"], 1),
    ("K1.20", "conditional_number",
     lambda am: am["routing"].update({"conditional": 1}),
     ["conditional"], None),
    ("K1.21", "emergency_object",
     lambda am: am["routing"].update({"emergency": {"a": 1}}),
     ["emergency"], None),
    ("K1.22", "bogus_role",
     lambda am: _rule(am, 0).update({"role": "does-not-exist-998"}),
     ["does-not-exist-998"], 0),
    ("K1.23", "bogus_tier",
     lambda am: _rule(am, _first_tier_rule(am)).update({"tier": "does-not-exist-998"}),
     ["does-not-exist-998"], "first_tier"),
]
NEG_MUTS = [(name, mut, tokens, idx)
            for _branch, name, mut, tokens, idx in ROUTING_BRANCHES]
NEG_BY_NAME = {name: (mut, tokens, idx) for name, mut, tokens, idx in NEG_MUTS}


def resolve_idx(idx, am):
    if callable(idx):
        return idx(am)
    return _first_tier_rule(am) if idx == "first_tier" else idx


def _first_role_ref(role):
    """Индекс первого правила routing с целью role=<role>; None — ссылок нет
    (К1.23 обобщённо: и снесённая роль, и файл роли называют индекс ПЕРВОЙ
    ссылки routing, а не фиксированное число — раскладки деревьев различны)."""
    def resolve(am):
        for i, r in enumerate(am.get("routing", {}).get("rules", [])):
            if isinstance(r, dict) and r.get("role") == role:
                return i
        return None
    return resolve


FIRST_GLM_REF = _first_role_ref(ROLE_GLM)


def named_reject(out, tokens, idx, require_routing=True):
    text = out or ""
    if require_routing and "routing" not in text:
        return "нет слова «routing»"
    for t in tokens:
        if t not in text:
            return f"нарушитель «{t}» не назван"
    if idx is not None and not re.search(rf"rules\[{idx}\]", text):
        return f"индекс rules[{idx}] не назван"
    return None


def sandbox(mut_json=None, drop_role_glm=False, drop_files=()):
    d = tempfile.mkdtemp(prefix="p998-")
    copy_subject(d)
    am = None
    if mut_json is not None:
        am = json_edit(os.path.join(d, "config", "agent_models.json"), mut_json)
    if drop_role_glm:
        for p in (
            os.path.join(d, "roles", "implementer-glm.md"),
            os.path.join(d, ".omp", "agents", "implementer-glm.md"),
        ):
            if os.path.exists(p):
                os.remove(p)
        am = json_edit(
            os.path.join(d, "config", "agent_models.json"),
            lambda a: a["roles"].pop("implementer-glm", None),
        )
    # К1.24 (критик круг 3): удаление ТОЛЬКО файлов ролей — таблица roles и
    # ссылки routing не трогаются (совместный снос записи таблицы зеленел
    # за счёт К1.22, а файловая проверка оставалась непроверенной).
    for slug in drop_files:
        p = os.path.join(d, "roles", f"{slug}.md")
        if os.path.exists(p):
            os.remove(p)
    if am is None:
        am = clone_am(AM0)
    return d, am


def gen(sb):
    return run([NODE, os.path.join(sb, "scripts", "gen-harness.ts"), "--check"])


def gen_prompt(sb, role="orchestrator"):
    return run([NODE, os.path.join(sb, "scripts", "gen-harness.ts"), "--prompt", role])


def disk_drift(sb, am):
    """Субъект не имеет права переписывать config во время проверки (Б8):
    диск после запуска обязан совпадать с тем, что записала проба."""
    try:
        now = json.loads(read(os.path.join(sb, "config", "agent_models.json")))
    except Exception as e:  # noqa: BLE001
        return f"config после запуска не читается: {e}"
    if now != am:
        return "субъект изменил config/agent_models.json на диске во время прогона"
    return None


# ── ПРЕДЪЯВЛЕНИЕ: --cases ────────────────────────────────────────────────────
@case("gen_check_harness")
def c_gen_check():
    sb, _ = sandbox()
    rc, out, err = gen(sb)
    ok = rc == 0
    detail = f"rc={rc} (ожидается 0 — контроль прежней сверки agents/roles): {first_line(out or err)}"
    shutil.rmtree(sb, ignore_errors=True)
    return ok, detail


@case("routing_grammar")
def c_grammar():
    v = grammar_violations(AM0)
    return (not v), ("; ".join(v) if v else "грамматика routing замкнута")


@case("routing_refs")
def c_refs():
    v = refs_violations(AM0, SUBJECT)
    return (not v), ("; ".join(v) if v else "routing называет только существующие роли и тиры")


@case("stale_until_removed")
def c_until():
    hit = STALE_UNTIL in AM0_TEXT
    return (not hit), (
        f"в config/agent_models.json жива оговорка «{STALE_UNTIL}»" if hit
        else "сняты ограничения переходного периода"
    )


@case("orchestrator_render")
def c_render():
    rc, out, err = gen_prompt(SUBJECT)
    if rc != 0:
        return False, f"--prompt orchestrator rc={rc}: {first_line(out or err)}"
    p = render_problems(out, AM0)
    return (not p), ("; ".join(p) if p else "routing отрендерен в промпт оркестратора построчно")


@case("other_roles_untouched")
def c_other_roles():
    v = []
    for slug, body in (("implementer", IMPL_BODY), ("architect", ARCH_BODY)):
        if body is None:
            continue
        rc, out, err = gen_prompt(SUBJECT, slug)
        if rc != 0:
            v.append(f"--prompt {slug} rc={rc}: {first_line(out or err)}")
        elif out != body_text(body):
            v.append(f"--prompt {slug} расходится с телом roles/{slug}.md (рендер чужих ролей)")
    return (not v), ("; ".join(v) if v else "рендер routing не затрагивает другие роли")


@case("role_pair_glm")
def c_pair():
    v = composition_violations(AM0, SUBJECT)
    return (not v), ("; ".join(v) if v else f"пара {ROLE_GLM}={TIER_NAME} ({TIER_MODEL}/{TIER_FALLBACK}, autoFallback) на месте")


@case("charter_duplicates")
def c_dup():
    v = agents_anchor_problems(read(os.path.join(SUBJECT, "AGENTS.md")))
    for rel, pair in (
        ("decisions/002-raskladka-modelei-dorogoe-tochechno.md", D002_OLD_PAIR),
        ("decisions/005-kritik-na-top-chuzogo-semeistva.md", D005_OLD_PAIR),
    ):
        path = os.path.join(SUBJECT, rel)
        text = read(path) if os.path.isfile(path) else ""
        v.extend(decision_anchor_problems(text, pair, rel))
    return (not v), ("; ".join(v) if v else "дубликаты правил моделей структурно замещены ссылкой на routing")


@case("consultant_norm")
def c_consultant():
    path = os.path.join(SUBJECT, "roles", "consultant.md")
    text = read(path) if os.path.isfile(path) else ""
    v = consultant_problems(text)
    return (not v), ("; ".join(v) if v else "норма замены Astra приведена к решению 2026-10-18")


@case("orchestrator_role_norm")
def c_orch_norm():
    path = os.path.join(SUBJECT, "roles", "orchestrator.md")
    text = read(path) if os.path.isfile(path) else ""
    v = orchestrator_norm_problems(text)
    return (not v), ("; ".join(v) if v else "норма-строка выбора роли по routing в roles/orchestrator.md")


def _neg_case(mut, tokens, idx):
    sb, am = sandbox(mut_json=mut)
    idx = resolve_idx(idx, am)
    rc1, o1, e1 = gen(sb)
    rc2, o2, e2 = gen_prompt(sb)
    drift = disk_drift(sb, am)
    shutil.rmtree(sb, ignore_errors=True)
    why = []
    for rc, o, e, entry in ((rc1, o1, e1, "--check"), (rc2, o2, e2, "--prompt")):
        if rc != 1:
            why.append(f"{entry} rc={rc} (ожидается 1)")
        else:
            named = named_reject(o + e, tokens, idx)
            if named:
                why.append(f"{entry}: {named}")
    if drift:
        why.append(drift)
    return (not why), (
        "; ".join(why) if why else
        "нарушение отвергнуто в обеих точках входа (routing, индекс, нарушитель названы)"
    )


def _make_neg(name, mut, tokens, idx):
    @case(f"gen_reject_{name}")
    def c_neg(mut=mut, tokens=tokens, idx=idx):
        return _neg_case(mut, tokens, idx)
    return c_neg


for _name, _mut, _tokens, _idx in NEG_MUTS:
    _make_neg(_name, _mut, _tokens, _idx)


@case("gen_reject_missing_role")
def c_missing_role():
    sb, am = sandbox(drop_role_glm=True)
    rc1, o1, e1 = gen(sb)
    rc2, o2, e2 = gen_prompt(sb)
    shutil.rmtree(sb, ignore_errors=True)
    idx = resolve_idx(FIRST_GLM_REF, am)
    why = []
    for rc, o, e, entry in ((rc1, o1, e1, "--check"), (rc2, o2, e2, "--prompt")):
        if rc != 1:
            why.append(f"{entry} rc={rc} (ожидается 1)")
        else:
            named = named_reject(o + e, [ROLE_GLM], idx)
            if named:
                why.append(f"{entry}: {named}")
    return (not why), ("; ".join(why) if why else
                       "удаление роли, на которую ссылается routing, отвергнуто в обеих точках "
                       "(routing, индекс первой ссылки, нарушитель названы)")


# К1.24 (арбитраж 998, критик круг 3): «роль в таблице осталась, файла нет» —
# СОБСТВЕННЫЙ вход файловой проверки routing; таблица roles и обе ссылки
# routing не трогаются (прежняя клетка сносила запись таблицы и зеленела за
# счёт К1.22). Удаляется только roles/implementer-glm.md.
@case("gen_reject_missing_role_file")
def c_missing_role_file():
    sb, am = sandbox(drop_files=(ROLE_GLM,))
    rc1, o1, e1 = gen(sb)
    rc2, o2, e2 = gen_prompt(sb)
    drift = disk_drift(sb, am)
    shutil.rmtree(sb, ignore_errors=True)
    why = []
    for rc, o, e, entry in ((rc1, o1, e1, "--check"), (rc2, o2, e2, "--prompt")):
        if rc != 1:
            why.append(f"{entry} rc={rc} (ожидается 1)")
        else:
            named = named_reject(o + e, [ROLE_GLM, f"roles/{ROLE_GLM}.md"], None,
                                 require_routing=False)
            if named:
                why.append(f"{entry}: {named}")
    if drift:
        why.append(drift)
    return (not why), ("; ".join(why) if why else
                       "роль в таблице без файла roles/implementer-glm.md отвергнута в обеих точках "
                       "(роль и файл названы; таблица и ссылки routing живы)")


# Вторая файловая проверка — общий table→file двухсторонней сверки loadRoles
# (существующая 002): СВОЙ вход «роль в таблице БЕЗ ссылок routing, файла нет»
# (обход круга 3 сносил ОБА цикла проверки файлов — каждая половина обязана
# различаться собственной клеткой).
def _mut_unref_implementer(am):
    am["routing"]["rules"] = [
        r for r in am["routing"]["rules"]
        if not (isinstance(r, dict) and r.get("role") == "implementer")
    ]


@case("gen_reject_unreferenced_role_file")
def c_unref_role_file():
    sb, am = sandbox(mut_json=_mut_unref_implementer, drop_files=("implementer",))
    rc1, o1, e1 = gen(sb)
    rc2, o2, e2 = gen_prompt(sb)
    drift = disk_drift(sb, am)
    shutil.rmtree(sb, ignore_errors=True)
    why = []
    for rc, o, e, entry in ((rc1, o1, e1, "--check"), (rc2, o2, e2, "--prompt")):
        if rc != 1:
            why.append(f"{entry} rc={rc} (ожидается 1)")
        else:
            named = named_reject(o + e, ["implementer", "roles/implementer.md"], None,
                                 require_routing=False)
            if named:
                why.append(f"{entry}: {named}")
    if drift:
        why.append(drift)
    return (not why), ("; ".join(why) if why else
                       "роль в таблице без routing-ссылок и без файла отвергнута в обеих точках "
                       "(роль и файл названы; общий table→file различим)")


def mut_render_class(am):
    am["routing"]["rules"][0]["class"] = am["routing"]["rules"][0]["class"] + " МУТАЦИЯ-998"


def mut_render_all_fields(am):
    rt = am["routing"]
    for i, r in enumerate(rt["rules"]):
        if isinstance(r.get("class"), str):
            r["class"] = r["class"] + f" МУТАЦИЯ-{i}-998"
        if isinstance(r.get("constraint"), str) and r["constraint"]:
            r["constraint"] = r["constraint"] + f" МУТАЦИЯ-K{i}"
        elif "constraint" not in r:
            r["constraint"] = f"МУТАЦИЯ-новый-K{i}"
        if isinstance(r.get("until"), str) and r["until"]:
            r["until"] = r["until"] + f" МУТАЦИЯ-U{i}"
        elif "until" not in r:
            r["until"] = f"МУТАЦИЯ-новый-U{i}"
    # К2.2 (арбитраж 998): ЦЕЛИ мутируются тоже — role первого role-правила и
    # tier первого tier-правила меняются на другие СУЩЕСТВУЮЩИЕ значения той же
    # таблицы конфига (субъект и seed различаются — значение выбирается из
    # самого мутируемого конфига, а не зашито).
    for r in rt["rules"]:
        if isinstance(r, dict) and isinstance(r.get("role"), str) and r["role"]:
            alt = _alt_key(am.get("roles", {}), r["role"])
            if alt is not None:
                r["role"] = alt
            break
    for r in rt["rules"]:
        if isinstance(r, dict) and isinstance(r.get("tier"), str) and r["tier"]:
            alt = _alt_key(am.get("tiers", {}), r["tier"])
            if alt is not None:
                r["tier"] = alt
            break
    if isinstance(rt.get("conditional"), str):
        rt["conditional"] = rt["conditional"] + " МУТАЦИЯ-C"
    if isinstance(rt.get("emergency"), str):
        rt["emergency"] = rt["emergency"] + " МУТАЦИЯ-E"


@case("gen_render_follows_config")
def c_render_follows():
    sb, am = sandbox(mut_json=mut_render_class)
    rc1, out1, err1 = gen(sb)
    rc2, out2, err2 = gen_prompt(sb)
    drift = disk_drift(sb, am)
    shutil.rmtree(sb, ignore_errors=True)
    why = []
    if rc1 != 0:
        why.append(f"--check rc={rc1}: {first_line(out1 or err1)}")
    if rc2 != 0:
        why.append(f"--prompt rc={rc2}: {first_line(out2 or err2)}")
    p = render_problems(out2, am)
    why.extend(p)
    if drift:
        why.append(drift)
    return (not why), ("; ".join(why) if why else "рендер производен от config: мутация класса дошла до промпта")


@case("gen_render_all_fields")
def c_render_all_fields():
    sb, am = sandbox(mut_json=mut_render_all_fields)
    rc1, out1, err1 = gen(sb)
    rc2, out2, err2 = gen_prompt(sb)
    drift = disk_drift(sb, am)
    shutil.rmtree(sb, ignore_errors=True)
    why = []
    if rc1 != 0:
        why.append(f"--check rc={rc1}: {first_line(out1 or err1)}")
    if rc2 != 0:
        why.append(f"--prompt rc={rc2}: {first_line(out2 or err2)}")
    why.extend(render_problems(out2, am))
    if drift:
        why.append(drift)
    return (not why), ("; ".join(why) if why else "рендер несёт class/цель/constraint/until/conditional/emergency всех правил")

# ── К2.3 (арбитраж 998): секция следует за НАБОРОМ правил — добавление,
# удаление и смена формы цели role↔tier; перечень порождает клетки перебором.
def _mut_rule_added(am):
    alt = _alt_key(am.get("roles", {}), am["routing"]["rules"][0].get("role"))
    am["routing"]["rules"].append({"class": "НОВЫЙ-КЛАСС-998", "role": alt})


def _mut_rule_removed(am):
    am["routing"]["rules"].pop()


def _mut_target_form_switch(am):
    r = am["routing"]["rules"][0]
    r.pop("role", None)
    r["tier"] = _alt_key(am.get("tiers", {}), r.get("tier"))


RULE_SET_MUTS = [
    ("правило добавлено", _mut_rule_added),
    ("последнее правило удалено", _mut_rule_removed),
    ("смена формы цели role→tier", _mut_target_form_switch),
]


@case("gen_render_rule_set")
def c_render_rule_set():
    why = []
    for label, mut in RULE_SET_MUTS:
        sb, am = sandbox(mut_json=mut)
        rc1, out1, err1 = gen(sb)
        rc2, out2, err2 = gen_prompt(sb)
        drift = disk_drift(sb, am)
        shutil.rmtree(sb, ignore_errors=True)
        if rc1 != 0:
            why.append(f"{label}: --check rc={rc1}: {first_line(out1 or err1)}")
        if rc2 != 0:
            why.append(f"{label}: --prompt rc={rc2}: {first_line(out2 or err2)}")
        why.extend(f"{label}: {p}" for p in render_problems(out2, am))
        if drift:
            why.append(f"{label}: {drift}")
    return (not why), ("; ".join(why) if why else
                       "секция следует за набором правил: добавление/удаление правила "
                       "и смена формы цели role→tier дошли до промпта")


# ── К2.4 (арбитраж 998): удаление необязательного поля не оставляет
# устаревшего текста — старое значение обязано ОТСУТСТВОВАТЬ в секции.
# Старые значения — из ПРЕДЗАГРУЗКИ (AM0, правило 8), не с диска субъекта.
def _optional_values(am):
    vals = []
    rt = am.get("routing", {})
    rules = rt.get("rules") if isinstance(rt, dict) else None
    if isinstance(rules, list):
        for r in rules:
            if not isinstance(r, dict):
                continue
            for f in ("constraint", "until"):
                if isinstance(r.get(f), str):
                    vals.append(r[f])
    if isinstance(rt, dict):
        for f in ("conditional", "emergency"):
            if isinstance(rt.get(f), str):
                vals.append(rt[f])
    return vals


def _mut_drop_optional(am):
    for r in am["routing"]["rules"]:
        if isinstance(r, dict):
            r.pop("constraint", None)
            r.pop("until", None)
    am["routing"].pop("conditional", None)
    am["routing"].pop("emergency", None)


@case("gen_render_stale_absent")
def c_render_stale_absent():
    stale = _optional_values(AM0)
    sb, am = sandbox(mut_json=_mut_drop_optional)
    rc1, out1, err1 = gen(sb)
    rc2, out2, err2 = gen_prompt(sb)
    drift = disk_drift(sb, am)
    shutil.rmtree(sb, ignore_errors=True)
    why = []
    if rc1 != 0:
        why.append(f"--check rc={rc1}: {first_line(out1 or err1)}")
    if rc2 != 0:
        why.append(f"--prompt rc={rc2}: {first_line(out2 or err2)}")
    why.extend(render_problems(out2, am))
    section = render_section(out2)
    for v in stale:
        if any(v in ln for ln in section):
            why.append(f"удалённое значение «{v[:40]}…» осталось в секции рендера")
    if drift:
        why.append(drift)
    return (not why), ("; ".join(why) if why else
                       "удаление необязательных полей (constraint/until/conditional/"
                       "emergency) не оставляет устаревшего текста в секции")

# ── К3 (арбитраж 998, Б6): фазы --check инварианта 2 — КАЖДАЯ своей клеткой
# с поломкой РОВНО одной производной (образцы поломок — З-4 арбитража).
# Совмещённая поломка двух производных маскировала потерю любой одной фазы;
# перечень фаз порождает клетки перебором.
def _break_agent_content(d):
    """К3.1: агент расходится содержимым (sameAgent) — только файл агента."""
    with open(os.path.join(d, ".omp", "agents", "implementer-glm.md"), "w", encoding="utf-8") as f:
        f.write("broken derivative\n")
    return True


def _break_agent_missing(d):
    """К3.2: производный агент отсутствует — удалён только файл."""
    p = os.path.join(d, ".omp", "agents", "implementer-glm.md")
    if os.path.exists(p):
        os.remove(p)
        return True
    return False


def _break_agent_stray(d):
    """К3.3: посторонний элемент каталога .omp/agents/."""
    with open(os.path.join(d, ".omp", "agents", "stray-998.md"), "w", encoding="utf-8") as f:
        f.write("stray\n")
    return True


def _break_model_roles(d):
    """К3.4: расходится ТОЛЬКО строка task-glm: в modelRoles (.omp/config.yml)."""
    p = os.path.join(d, ".omp", "config.yml")
    lines = read(p).splitlines(True)
    hit = next((i for i, ln in enumerate(lines) if re.match(r"^\s*task-glm:\s*\"", ln)), None)
    if hit is None:
        return False
    lines[hit] = re.sub(r'"[^"]*"', '"zai/broken-998"', lines[hit], count=1)
    with open(p, "w", encoding="utf-8") as f:
        f.writelines(lines)
    return True


def _break_fallback_chains(d):
    """К3.5: расходится ТОЛЬКО строка task-glm: в retry.fallbackChains."""
    p = os.path.join(d, ".omp", "config.yml")
    s = read(p)
    s2, n = re.subn(r"(?m)^(\s*task-glm:\s*\[)[^\]]*(\])", r'\1"broken-998"\2', s, count=1)
    if not n:
        return False
    with open(p, "w", encoding="utf-8") as f:
        f.write(s2)
    return True


DRIFT_PHASES = [
    ("gen_check_drift_agent_content", _break_agent_content,
     ["implementer-glm.md"], "агент расходится содержимым (sameAgent)"),
    ("gen_check_drift_agent_missing", _break_agent_missing,
     ["implementer-glm.md"], "производный агент отсутствует"),
    ("gen_check_drift_agent_stray", _break_agent_stray,
     ["stray-998.md"], "посторонний элемент каталога .omp/agents/"),
    ("gen_check_drift_model_roles", _break_model_roles,
     ["modelRoles"], "modelRoles расходится (строка task-glm:)"),
    ("gen_check_drift_fallback_chains", _break_fallback_chains,
     ["fallbackChains"], "fallbackChains расходится (строка task-glm:)"),
]


def _make_drift(name, brk, tokens, phase):
    @case(name)
    def c_drift(brk=brk, tokens=tokens, phase=phase):
        sb, _ = sandbox()
        applied = brk(sb)
        rc, out, err = gen(sb)
        shutil.rmtree(sb, ignore_errors=True)
        if not applied:
            return False, (
                f"поломка фазы «{phase}» не применима к дереву субъекта "
                "(нет элемента фазы — производная 998 не реализована)"
            )
        if rc != 1:
            return False, f"rc={rc} (ожидается 1 — фаза «{phase}»): {first_line(out or err)}"
        absent = [t for t in tokens if t not in (out or "") and t not in (err or "")]
        if absent:
            return False, f"rc=1, но производная фазы не названа ({', '.join(absent)}): {first_line(out or err)}"
        return True, f"--check rc=1, фаза «{phase}» названа: {first_line(out or err)}"
    return c_drift


for _dname, _dbrk, _dtokens, _dphase in DRIFT_PHASES:
    _make_drift(_dname, _dbrk, _dtokens, _dphase)


@case("gen_no_disk_mutation")
def c_no_disk_mutation():
    sb, _ = sandbox()
    before = read(os.path.join(sb, "config", "agent_models.json"))
    gen(sb)
    gen_prompt(sb)
    after = read(os.path.join(sb, "config", "agent_models.json"))
    shutil.rmtree(sb, ignore_errors=True)
    ok = before == after
    return ok, (
        "субъект переписал config/agent_models.json во время --check/--prompt"
        if not ok else "чтение не пишет: config неизменен после --check/--prompt"
    )


# ── МАТРИЦА РАЗЛИЧИМОСТИ: --matrix ───────────────────────────────────────────
SEED = os.path.join(HERE, "seed")
MODELS = {
    "model": os.path.join(HERE, "model_gen.ts"),
    "key_only": os.path.join(HERE, "decoy_key_only.ts"),
    "empty_render": os.path.join(HERE, "decoy_empty_render.ts"),
    "hardcoded": os.path.join(HERE, "decoy_hardcoded.ts"),
    "narrow_disk": os.path.join(HERE, "decoy_narrow_disk.ts"),
    "all_roles": os.path.join(HERE, "decoy_all_roles.ts"),
    "drop_constraint": os.path.join(HERE, "decoy_drop_constraint.ts"),
    "drift_blind": os.path.join(HERE, "decoy_drift_blind.ts"),
    "role_file_blind": os.path.join(HERE, "decoy_role_file_blind.ts"),
}

SEED_AM = json.loads(read(os.path.join(SEED, "config", "agent_models.json")))
SEED_IMPL_BODY = read(os.path.join(SEED, "roles", "implementer.md"))


def seed_copy(dst):
    shutil.copytree(SEED, dst, dirs_exist_ok=True)
    return dst


def seed_sandbox(mut_json=None, drop_role_glm=False, break_derivative=False, drop_files=()):
    d = tempfile.mkdtemp(prefix="m998-")
    seed_copy(d)
    if mut_json is not None:
        am = json_edit(os.path.join(d, "config", "agent_models.json"), mut_json)
    else:
        am = clone_am(SEED_AM)
    if drop_role_glm:
        os.remove(os.path.join(d, "roles", "implementer-glm.md"))
        am = json_edit(
            os.path.join(d, "config", "agent_models.json"),
            lambda a: a["roles"].pop("implementer-glm", None),
        )
    # К1.24 (критик круг 3): удаление ТОЛЬКО файла роли — таблица и ссылки
    # живы; производная .omp/agents остаётся (дрейф-фаза модели итерирует
    # таблицу и не должна подменять файловую ветву своим отказом).
    for slug in drop_files:
        p = os.path.join(d, "roles", f"{slug}.md")
        if os.path.exists(p):
            os.remove(p)
    if break_derivative:
        with open(os.path.join(d, ".omp", "agents", "implementer-glm.md"), "w", encoding="utf-8") as f:
            f.write("broken derivative\n")
    return d, am


def mrun(model, tree, args):
    return run([NODE, MODELS[model], "--root", tree] + args)


def _mutated_seed(fn):
    am = clone_am(SEED_AM)
    fn(am)
    return am


def matrix():
    cells = []

    def add(name, fn):
        cells.append((name, fn))

    # А. честная модель: ожидание совпадает на каждом входе, включая входы,
    # где честный исход — именованный отказ rc 1 (сравнивается ФАКТИЧЕСКИЙ rc).
    def cell_model_check(name, mut=None, drop=False, want_rc=0, tokens=None, idx=None, drop_files=()):
        def fn():
            tree, am = seed_sandbox(mut_json=mut, drop_role_glm=drop, drop_files=drop_files)
            rc, out, err = mrun("model", tree, ["--check"])
            shutil.rmtree(tree, ignore_errors=True)
            if want_rc == 0:
                return rc == 0, f"rc={rc} (ожидается 0): {first_line(out or err)}"
            named = named_reject(out + err, tokens or [], resolve_idx(idx, am))
            ok = rc == 1 and named is None
            return ok, f"rc={rc} (ожидается 1): {named or 'именованный отказ с routing/индексом/нарушителем'}"
        return fn

    add("model_seed_check", cell_model_check("model_seed_check"))
    for name, mut, tokens, idx in NEG_MUTS:
        add(f"model_{name}", cell_model_check(f"model_{name}", mut=mut, want_rc=1, tokens=tokens, idx=idx))
    add("model_missing_role", cell_model_check(
        "model_missing_role", drop=True, want_rc=1, tokens=[ROLE_GLM], idx=FIRST_GLM_REF))
    # К1.24 (критик круг 3): файл роли удалён, таблица roles и ссылка routing
    # живы — собственный вход файловой проверки (совместная поломка со сносом
    # записи таблицы зеленела за счёт ветви «роли нет в таблице»).
    add("model_missing_role_file", cell_model_check(
        "model_missing_role_file", drop_files=(ROLE_GLM,), want_rc=1,
        tokens=[ROLE_GLM, f"roles/{ROLE_GLM}.md"], idx=FIRST_GLM_REF))

    def cell_model_prompt(name, mut=None):
        def fn():
            tree, am = seed_sandbox(mut_json=mut)
            rc1, o1, e1 = mrun("model", tree, ["--check"])
            rc2, out, err = mrun("model", tree, ["--prompt", "orchestrator"])
            drift = disk_drift(tree, am)
            probs = render_problems(out, am) if rc2 == 0 else [f"rc={rc2}"]
            shutil.rmtree(tree, ignore_errors=True)
            ok = rc1 == 0 and rc2 == 0 and not probs and not drift
            return ok, f"--check rc={rc1}, --prompt rc={rc2}, рендер полон={not probs}" + (f", {drift}" if drift else "")
        return fn

    add("model_seed_prompt", cell_model_prompt("model_seed_prompt"))
    add("model_render_mutation", cell_model_prompt("model_render_mutation", mut=mut_render_class))
    add("model_render_all_fields", cell_model_prompt("model_render_all_fields", mut=mut_render_all_fields))

    def cell_model_other_role(name):
        def fn():
            tree, _ = seed_sandbox()
            rc, out, err = mrun("model", tree, ["--prompt", "implementer"])
            shutil.rmtree(tree, ignore_errors=True)
            ok = rc == 0 and out == body_text(SEED_IMPL_BODY)
            return ok, f"rc={rc}, промпт implementer == тело роли={out == body_text(SEED_IMPL_BODY)}"
        return fn

    add("model_prompt_implementer_parity", cell_model_other_role("model_prompt_implementer_parity"))

    # Оракулы композиции и якорей — в обе полярности.
    def cell_oracle(name, mut, want_flag):
        def fn():
            am = clone_am(SEED_AM)
            if mut is not None:
                mut(am)
            tree, _ = seed_sandbox(mut_json=mut)
            v = composition_violations(am, tree)
            shutil.rmtree(tree, ignore_errors=True)
            flagged = bool(v)
            return flagged == want_flag, (
                f"композиция помечена={flagged} (ожидается {want_flag}): {first_line('; '.join(v)) or 'чисто'}"
            )
        return fn

    def mut_no_autofallback(am):
        am["tiers"]["task-glm"]["autoFallback"] = False

    def mut_wrong_tier_glm(am):
        am["roles"]["implementer-glm"] = "task"

    def cell_oracle_tools(name, want_flag):
        def fn():
            tree, _ = seed_sandbox()
            p = os.path.join(tree, "roles", "implementer-glm.md")
            txt = read(p).replace("tools: [read, bash]", "tools: [read]")
            with open(p, "w", encoding="utf-8") as f:
                f.write(txt)
            v = composition_violations(clone_am(SEED_AM), tree)
            shutil.rmtree(tree, ignore_errors=True)
            flagged = bool(v)
            return flagged == want_flag, f"композиция (иные поля frontmatter) помечена={flagged} (ожидается {want_flag})"
        return fn

    add("oracle_seed_clean", cell_oracle("oracle_seed_clean", None, False))
    add("oracle_wrong_tier_glm", cell_oracle("oracle_wrong_tier_glm", mut_wrong_tier_glm, True))
    add("oracle_no_autofallback", cell_oracle("oracle_no_autofallback", mut_no_autofallback, True))
    add("oracle_different_tools", cell_oracle_tools("oracle_different_tools", True))

    def cell_anchor(name, problems, want_flag):
        def fn():
            v = problems()
            flagged = bool(v)
            return flagged == want_flag, f"якорь помечен={flagged} (ожидается {want_flag}): {'; '.join(v) or 'чисто'}"
        return fn

    honest_agents = (
        "**Какую модель ведёт сессия.** Правила — `config/agent_models.json` §routing;\n"
        "при расхождении действует файл.\n"
    )
    bypass_agents = (
        "**Какую модель ведёт сессия.** Дважды перевёрнуто владельцем: 2026-08-24 — на модель MiniMax.\n"
        "Ссылка: config/agent_models.json §routing.\n"
    )
    honest_consultant = (
        "## Модель\n\nПри недоступности astra — замена Astra — только Fable "
        "(docs/owner/2026-10-18-raskladka-modelei.md).\n"
    )
    bypass_consultant = (
        "## Модель\n\nНЕ действует правило «замена Astra — только Fable»: вместо Astra разрешён Sonnet "
        "(docs/owner/2026-10-18-raskladka-modelei.md).\n"
    )
    honest_orch = (
        "## Спавн\n\nВыбор роли субагента — по routing `config/agent_models.json`; "
        "при отказе спавна — доклад причины консультанту, не смена роли (Н-315).\n"
    )
    add("anchor_agents_honest", cell_anchor("anchor_agents_honest", lambda: agents_anchor_problems(honest_agents), False))
    add("anchor_agents_tweaked_old", cell_anchor("anchor_agents_tweaked_old", lambda: agents_anchor_problems(bypass_agents), True))
    add("anchor_consultant_honest", cell_anchor("anchor_consultant_honest", lambda: consultant_problems(honest_consultant), False))
    add("anchor_consultant_negated", cell_anchor("anchor_consultant_negated", lambda: consultant_problems(bypass_consultant), True))
    add("anchor_orchestrator_norm", cell_anchor("anchor_orchestrator_norm", lambda: orchestrator_norm_problems(honest_orch), False))
    add("anchor_orchestrator_absent", cell_anchor("anchor_orchestrator_absent", lambda: orchestrator_norm_problems("## Спавн\n\nНормы нет.\n"), True))

    # Б. обманные формы: различимы на назначенных входах, честны там, где их
    # дефект не наблюдаем. Привязки — в этой таблице, не в прозе контракта.
    def cell_decoy(name, model, args, mut=None, drop=False, break_derivative=False, expect=None, drop_files=()):
        def fn():
            tree, am = seed_sandbox(mut_json=mut, drop_role_glm=drop, break_derivative=break_derivative, drop_files=drop_files)
            rc, out, err = mrun(model, tree, args)
            drift = disk_drift(tree, am)
            shutil.rmtree(tree, ignore_errors=True)
            caught = expect(rc, out, err, drift)
            return caught, f"rc={rc}{'; ' + drift if drift else ''}: {first_line(out or err)}"
        return fn

    add("decoy_key_only_bogus_role", cell_decoy(
        "decoy_key_only_bogus_role", "key_only", ["--check"],
        mut=NEG_BY_NAME["bogus_role"][0],
        expect=lambda rc, out, err, d: rc == 0))
    add("decoy_key_only_unknown_key", cell_decoy(
        "decoy_key_only_unknown_key", "key_only", ["--check"],
        mut=NEG_BY_NAME["unknown_routing_key"][0],
        expect=lambda rc, out, err, d: rc == 0))
    add("decoy_key_only_constraint_number", cell_decoy(
        "decoy_key_only_constraint_number", "key_only", ["--check"],
        mut=NEG_BY_NAME["constraint_number"][0],
        expect=lambda rc, out, err, d: rc == 0))
    add("decoy_key_only_class_number", cell_decoy(
        "decoy_key_only_class_number", "key_only", ["--check"],
        mut=NEG_BY_NAME["class_number"][0],
        expect=lambda rc, out, err, d: rc == 0))
    add("decoy_key_only_seed_parity", cell_decoy(
        "decoy_key_only_seed_parity", "key_only", ["--check"],
        expect=lambda rc, out, err, d: rc == 0 and d is None))
    add("decoy_empty_render_seed_prompt", cell_decoy(
        "decoy_empty_render_seed_prompt", "empty_render", ["--prompt", "orchestrator"],
        expect=lambda rc, out, err, d: rc == 0 and bool(render_problems(out, SEED_AM))))
    add("decoy_empty_render_seed_check_parity", cell_decoy(
        "decoy_empty_render_seed_check_parity", "empty_render", ["--check"],
        expect=lambda rc, out, err, d: rc == 0 and d is None))
    add("decoy_hardcoded_render_mutation", cell_decoy(
        "decoy_hardcoded_render_mutation", "hardcoded", ["--prompt", "orchestrator"],
        mut=mut_render_class,
        expect=lambda rc, out, err, d: rc == 0 and bool(render_problems(out, _mutated_seed(mut_render_class)))))
    add("decoy_hardcoded_seed_prompt_parity", cell_decoy(
        "decoy_hardcoded_seed_prompt_parity", "hardcoded", ["--prompt", "orchestrator"],
        expect=lambda rc, out, err, d: rc == 0 and not render_problems(out, SEED_AM) and d is None))
    add("decoy_narrow_disk_seed_prompt", cell_decoy(
        "decoy_narrow_disk_seed_prompt", "narrow_disk", ["--prompt", "orchestrator"],
        expect=lambda rc, out, err, d: d is not None or bool(render_problems(out, SEED_AM))))
    add("decoy_drop_constraint_seed_prompt", cell_decoy(
        "decoy_drop_constraint_seed_prompt", "drop_constraint", ["--prompt", "orchestrator"],
        expect=lambda rc, out, err, d: rc == 0 and bool(render_problems(out, SEED_AM))))
    add("decoy_all_roles_implementer", cell_decoy(
        "decoy_all_roles_implementer", "all_roles", ["--prompt", "implementer"],
        expect=lambda rc, out, err, d: rc == 0 and out != body_text(SEED_IMPL_BODY)))
    add("decoy_all_roles_orchestrator_parity", cell_decoy(
        "decoy_all_roles_orchestrator_parity", "all_roles", ["--prompt", "orchestrator"],
        expect=lambda rc, out, err, d: rc == 0 and not render_problems(out, SEED_AM) and d is None))
    add("decoy_drift_blind_broken_derivative", cell_decoy(
        "decoy_drift_blind_broken_derivative", "drift_blind", ["--check"],
        break_derivative=True,
        expect=lambda rc, out, err, d: rc == 0))
    add("decoy_drift_blind_seed_parity", cell_decoy(
        "decoy_drift_blind_seed_parity", "drift_blind", ["--check"],
        expect=lambda rc, out, err, d: rc == 0 and d is None))
    # К1.24 (критик круг 3): обманка «слепая к файлу роли» — грамматика и
    # таблица честные, существование roles/<роль>.md для цели routing не
    # проверяется. Назначенный вход: удалён ТОЛЬКО roles/implementer-glm.md,
    # таблица и ссылка живы — обманка принимает rc 0, честная модель даёт
    # именованный отказ (см. model_missing_role_file).
    add("decoy_role_file_blind_missing_file", cell_decoy(
        "decoy_role_file_blind_missing_file", "role_file_blind", ["--check"],
        drop_files=(ROLE_GLM,),
        expect=lambda rc, out, err, d: rc == 0))
    add("decoy_role_file_blind_seed_parity", cell_decoy(
        "decoy_role_file_blind_seed_parity", "role_file_blind", ["--check"],
        expect=lambda rc, out, err, d: rc == 0 and d is None))

    return cells


def run_cells(cells, label):
    bad = []
    for name, fn in cells:
        ok, detail = fn()
        print(f"CASE {label} {name}: {'ok' if ok else 'РАСХОЖДЕНИЕ'} — {detail}")
        if not ok:
            bad.append(name)
    return bad


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "--cases"
    if mode == "--case":
        name = sys.argv[2] if len(sys.argv) > 2 else unavailable("--case требует имя")
        fns = dict(CASES)
        if name not in fns:
            unavailable(f"нет случая {name}; есть: {', '.join(dict(CASES))}")
        ok, detail = fns[name]()
        print(f"CASE {name}: {'ok' if ok else 'РАСХОЖДЕНИЕ'} — {detail}")
        sys.exit(0 if ok else 1)
    if mode == "--cases":
        bad = run_cells(CASES, "cases")
        census = len(CASES)
        print(f"census cases: исполнено {census}, расхождений {len(bad)}")
        if bad:
            print(f"КРАСНО: {', '.join(bad)}", file=sys.stderr)
            sys.exit(1)
        sys.exit(0)
    if mode == "--matrix":
        cells = matrix()
        bad = run_cells(cells, "matrix")
        census = len(cells)
        print(f"census matrix: исполнено {census}, расхождений {len(bad)}")
        if bad:
            print(f"КРАСНО: {', '.join(bad)}", file=sys.stderr)
            sys.exit(1)
        sys.exit(0)
    unavailable(f"неизвестный режим {mode}: --cases | --matrix | --case ИМЯ")


if __name__ == "__main__":
    main()
