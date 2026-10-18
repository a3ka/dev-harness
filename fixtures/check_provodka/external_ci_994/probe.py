#!/usr/bin/env python3
"""994: ожидания в памяти, каждый вход судится отдельно через публичный bash CLI."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
SUBJECT = REPO / "scripts/check_provodka.sh"
P991 = "не добавлять в CI dev-harness зависимость от чужого checkout/SDK"
P993 = "Общий CI dev-harness не получает зависимость от внешнего checkout"
ENF = "ПРОВОДКА-ЭНФОРСМЕНТ: "
GUARD = "scripts/check_remote_994.sh"
OTHER = "scripts/check_second_994.sh"
SELF = "fixtures/check_provodka/external_ci_994/probe.sh"
KEY = "check:provodka-external-994"
STEP = f"step\t{KEY}\t10\tbash {SELF}"
CONTRACT = "contracts/727-example.md"


def refusal(guard=GUARD):
    return f"проводка: guard не подключён: {guard} не вызывается в .githooks/ или .github/workflows/"


def field(tail="", guards=(GUARD,)):
    return "ПРОВОДКА:\n" + "".join(f"- guard={g}\n" for g in guards) + tail


def cases():
    # Буквальные исходы, не вызов модельного парсера для получения ожиданий.
    rows = []

    def add(name, body, rc=1, message=None, wired=None, missing=(), guards=(GUARD,)):
        rows.append(dict(name=name, body=body, rc=rc,
                         message=refusal() if message is None and rc == 1 else message,
                         wired=wired, missing=missing, guards=guards))

    local = ENF + "Локальная проверка.\n"
    add("LOCAL_UNWIRED", field(local))
    for where in ("hook", "workflow", "registry"):
        add("LOCAL_" + where.upper(), field(local), 0, wired=where)
    add("NO_FIELD", "# Только предмет\n", message="проводка: поле ПРОВОДКА отсутствует")
    add("EMPTY_FIELD", "ПРОВОДКА:\n# Конец\n", message="проводка: поле пусто")
    add("NO_JUSTIFICATION", field(), message="проводка: guard-only поле без предметного канала и строки ПРОВОДКА-ЭНФОРСМЕНТ")
    add("GRAMMAR_FIRST", field("ошибочный канал\n" + ENF + P991), message="проводка: строка вне грамматики: ошибочный канал")
    add("EXTERNAL_991", field(ENF + "Внешняя проверка; " + P991 + ". Действующая норма.\n"), 0)
    add("EXTERNAL_993", field(ENF + "Внешняя проверка. " + P993 + "; действующая норма.\n"), 0)
    add("WRAPPED_991", field(ENF + "Внешняя проверка; " + P991.replace(" ", "\n\t") + ".\n"), 0)
    add("WRAPPED_993", field(ENF + P993.replace(" ", " \t ") + "\n"), 0)
    add("BLANK_BEFORE_PARAGRAPH", field("\n" + ENF + P991), 0)
    role = "- role=roles/fixture.md «Норма 994.»\n"
    charter = "- charter=AGENTS.md §Правило 994 «Норма 994.»\n"
    add("ROLE_BEFORE_PARAGRAPH", field(role + ENF + P991), 0)
    add("CHARTER_BEFORE_PARAGRAPH", field(charter + ENF + P993), 0)
    add("EXTERNAL_THEN_BAD_ROLE", field(role.replace("Норма 994.", "Чужая норма.") + ENF + P991),
        message="проводка: норма-строка не найдена в role-файле: roles/fixture.md")
    add("EXTERNAL_THEN_BAD_CHARTER", field(charter.replace("Норма 994.", "Чужая норма.") + ENF + P993),
        message="проводка: норма-строка не найдена в теле секции §Правило 994")
    add("SHARED_PARAGRAPH", field(ENF + P991 + ".\n", (GUARD, OTHER)), 0, guards=(GUARD, OTHER))
    add("MISSING_EXTERNAL", field(ENF + P991), missing=(GUARD,), message=f"проводка: guard-файл не существует: {GUARD}")
    add("SECOND_GUARD_LOCAL", field(ENF + P991 + "\n\n- guard=" + OTHER + "\n" + local), guards=(GUARD, OTHER), message=refusal(OTHER))
    add("SECOND_GUARD_OWN", field(local + "\n- guard=" + OTHER + "\n" + ENF + P993), 0, wired="hook", guards=(GUARD, OTHER))
    add("ENF_BEFORE_CHANNEL", "ПРОВОДКА:\n" + ENF + P991 + "\n- guard=" + GUARD + "\n" + local)
    add("NO_FOLLOWING_PARAGRAPH", "ПРОВОДКА:\n" + ENF + P993 + "\n- guard=" + GUARD + "\n")
    add("FIRST_PARAGRAPH_ONLY", field(local + "\n" + ENF + P991))
    add("ADJACENT_PARAGRAPH_ONLY", field(local + ENF + P991))
    add("BEFORE_FIELD", ENF + P991 + "\n\n" + field(local))
    for label, terminator in (("HEADING", "## Другой раздел"), ("FENCE", "```")):
        add("AFTER_" + label, field(local + "\n" + terminator + "\n" + ENF + P991))
        add("AFTER_" + label + "_CONTINUATION", field(ENF + "Локальная проверка;\n" + terminator + "\n" + P993))
    add("AFTER_HASH_NO_SPACE_CONTINUATION", field(ENF + "Локальная проверка;\n#заметка.\n" + P993))
    add("AFTER_FENCE_LANGUAGE_CONTINUATION", field(ENF + "Локальная проверка;\n```text;\n" + P993))
    add("SECOND_FIELD", field(local + "\n## Другой раздел\n" + field(ENF + P991)))
    add("QUOTED_MARKER", field(ENF + "Локальная проверка.\n> " + ENF + P991))
    add("COMMENT_MARKER", field(ENF + "Локальная проверка.\n<!-- " + ENF + P993 + " -->"))
    add("FRAGMENT_EDGE_NBSP", field(ENF + "Внешняя;\u00a0" + P991 + "."))
    for label, phrase in (("991", P991), ("993", P993)):
        for suffix, malformed in (
            ("PREFIX", "неверно " + phrase),
            ("SUFFIX", phrase + " временно"),
            ("PARTIAL", phrase[:-1]),
            ("CASE", phrase.swapcase()),
            ("QUOTED", "«" + phrase + "»"),
            ("GLOB", phrase + "*"),
            ("REGEX", phrase.replace("dev-harness", "dev.harness")),
            ("NBSP", phrase.replace(" CI ", " CI\u00a0")),
            ("EN_SPACE", phrase.replace(" CI ", " CI\u2002")),
        ):
            add(label + "_" + suffix, field(ENF + malformed + ".\n"))
        for suffix, delimiter in (("COMMA", ","), ("EXCLAMATION", "!"), ("QUESTION", "?"),
                                  ("COLON", ":"), ("DASH", "—")):
            add(label + "_NEGATED_" + suffix, field(ENF + "Неверно" + delimiter + " " + phrase + ".\n"))
            add(label + "_SUFFIX_" + suffix, field(ENF + phrase + delimiter + " Guard локальный.\n"))
    # Имена/номер не часть исключения; второе непохожее имя ловит пинование значений.
    alternate = "fixtures/other-name_817.py"
    add("RENAMED_EXTERNAL", field(ENF + P993, (alternate,)), 0, guards=(alternate,))
    add("RENAMED_LOCAL", field(local, (alternate,)), guards=(alternate,), message=refusal(alternate))
    return rows


def put(root, path, text):
    target = root / path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(text, encoding="utf-8")


def invoke(subject, root, contract=CONTRACT):
    result = subprocess.run(["bash", str(subject), str(root), contract],
                            capture_output=True, text=True, timeout=20)
    return result.returncode, result.stdout + result.stderr


def run_cases(subject, scratch, selection=None):
    selected = [row for row in cases() if selection is None or row["name"] in selection]
    if not selected:
        raise ValueError("EMPTY_SELECTION")
    mismatches = []
    for row in selected:
        root = scratch / row["name"]
        root.mkdir()
        put(root, CONTRACT, row["body"])
        put(root, "roles/fixture.md", "Норма 994.\n")
        put(root, "AGENTS.md", "## Правило 994\n\nНорма 994.\n")
        for guard in row["guards"]:
            if guard not in row["missing"]:
                put(root, guard, "#!/usr/bin/env bash\nexit 0\n")
        if row["wired"] == "hook":
            put(root, ".githooks/pre-commit", f"bash {GUARD}\n")
        elif row["wired"] == "workflow":
            put(root, ".github/workflows/check.yml", f"jobs:\n  test:\n    steps:\n      - run: bash {GUARD}\n")
        elif row["wired"] == "registry":
            put(root, "registry/ci-steps.tsv", f"lanes\t7\nstep\tcheck:fixture\t1\tbash {GUARD}\n")
        rc, output = invoke(subject, root)
        matched = rc == row["rc"] and (row["message"] is None or row["message"] in output.splitlines())
        if not matched:
            mismatches.append(dict(name=row["name"], actual=rc, output=output))
        print("CASE " + json.dumps(dict(name=row["name"], actual=rc, expected=row["rc"],
                                       matched=matched, output=output), ensure_ascii=False))
    print(f"CASES executed={len(selected)} mismatches={len(mismatches)}")
    return mismatches


def legacy():
    files = sorted(HERE.parent.glob("green_G*.sh")) + sorted(HERE.parent.glob("red_R*.sh"))
    if not files:
        raise ValueError("EMPTY_LEGACY")
    bad = 0
    for path in files:
        result = subprocess.run(["bash", str(path)], cwd=REPO, capture_output=True, text=True, timeout=60)
        print(f"LEGACY {path.name} rc={result.returncode}")
        if result.returncode:
            print(result.stdout + result.stderr)
            bad += 1
    print(f"LEGACY executed={len(files)} mismatches={bad}")
    return bad


def self_wiring(subject, scratch, registry=None):
    # Live-режим берёт настоящую строку; matrix явно предъявляет проектируемую.
    if registry is None:
        registry = (REPO / "registry/ci-steps.tsv").read_text(encoding="utf-8")
    probe = (REPO / SELF).read_text(encoding="utf-8")
    rows = [line for line in registry.splitlines() if line.split("\t")[:2] == ["step", KEY]]
    if rows != [STEP]:
        print("SELF_WIRING MISSING_REAL_STEP " + repr(rows))
        return 1
    bad = 0
    for name, reg, expected, reason in (
        ("REGISTRY_ONLY", "lanes\t7\n" + rows[0] + "\n", 0, None),
        ("WITHOUT_OWN_STEP", "lanes\t7\n", 1, refusal(SELF)),
    ):
        root = scratch / name
        root.mkdir()
        put(root, SELF, probe)
        put(root, "registry/ci-steps.tsv", reg)
        put(root, CONTRACT, field(ENF + "Локальная проба.\n", (SELF,)))
        rc, output = invoke(subject, root)
        matched = rc == expected and (reason is None or reason in output.splitlines())
        bad += not matched
        print("SELF " + json.dumps(dict(name=name, actual=rc, expected=expected, matched=matched, output=output), ensure_ascii=False))
    return bad


def matrix(scratch):
    # Снимок из a3c8cb976:scripts/check_provodka.sh переносится вместе с пробой.
    # Проверка до субъекта: ни история git, ни будущая реализация не служат базой.
    content = (HERE / "baseline_038.sh").read_bytes()
    if hashlib.sha256(content).hexdigest() != "20db5210adda688f85daf980d6bff53c287de0b49e5a6c1b525a887984d704a3":
        raise ValueError("BASELINE_DIGEST")
    baseline = scratch / "baseline.sh"
    baseline.write_bytes(content)
    modes = {
        "honest": None,
        "unchanged": {"EXTERNAL_991", "EXTERNAL_993"},
        "substring": {"991_PREFIX", "993_SUFFIX"},
        "wide-delimiter": {"991_NEGATED_COMMA", "991_NEGATED_EXCLAMATION", "991_NEGATED_QUESTION",
                           "993_SUFFIX_COMMA", "993_SUFFIX_EXCLAMATION", "993_SUFFIX_QUESTION"},
        "unicode-space": {"991_NBSP", "993_EN_SPACE"},
        "heading-space": {"AFTER_HASH_NO_SPACE_CONTINUATION"},
        "bare-fence": {"AFTER_FENCE_LANGUAGE_CONTINUATION"},
        "exit-after-grant": {"EXTERNAL_THEN_BAD_ROLE", "EXTERNAL_THEN_BAD_CHARTER"},
        "whole-file": {"BEFORE_FIELD", "AFTER_HEADING", "AFTER_FENCE"},
        "later-paragraph": {"FIRST_PARAGRAPH_ONLY"},
        "shared-global": {"SECOND_GUARD_LOCAL", "NO_FOLLOWING_PARAGRAPH"},
        "missing-file": {"MISSING_EXTERNAL"},
    }
    bad = 0
    for mode, witnesses in modes.items():
        wrapper = scratch / (mode + ".sh")
        import shlex
        wrapper.write_text("#!/usr/bin/env bash\nexec python3 " + shlex.quote(str(HERE / "models.py")) +
                           " " + shlex.quote(str(baseline)) + " " + mode + ' "$@"\n', encoding="utf-8")
        work = scratch / mode
        work.mkdir()
        mismatch = run_cases(wrapper, work, witnesses)
        if mode == "honest":
            valid = not mismatch
        else:
            valid = {row["name"] for row in mismatch} == witnesses
            for row in mismatch:
                if mode == "unchanged":
                    valid &= row["actual"] == 1 and refusal() in row["output"].splitlines()
                else:
                    valid &= row["actual"] == 0 and not row["output"]
        bad += not valid
        print(f"MODEL {mode} observed={len(mismatch)} valid={int(valid)}")
    work = scratch / "planned-wiring"
    work.mkdir()
    bad += self_wiring(baseline, work, "lanes\t7\n" + STEP + "\n")
    return bad


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group()
    for mode in ("cases", "legacy", "matrix", "self-wiring"):
        group.add_argument("--" + mode, action="store_true")
    parser.add_argument("--subject", type=Path, default=SUBJECT)
    args = parser.parse_args()
    if not args.subject.is_file():
        raise ValueError("MISSING_SUBJECT")
    selected = any((args.cases, args.legacy, args.matrix, args.self_wiring))
    # Существующий scratch корня, уникальный дочерний каталог без shared-state.
    (REPO / "tmp").mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="provodka-994-", dir=REPO / "tmp") as directory:
        scratch = Path(directory)
        bad = 0
        if args.cases or not selected:
            work = scratch / "cases"
            work.mkdir()
            bad += bool(run_cases(args.subject.resolve(), work))
        if args.legacy or not selected:
            bad += legacy()
        if args.matrix or not selected:
            work = scratch / "models"
            work.mkdir()
            bad += matrix(work)
        if args.self_wiring or not selected:
            work = scratch / "self"
            work.mkdir()
            bad += self_wiring(args.subject.resolve(), work)
    return int(bool(bad))


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        print(f"994 UNMEASURABLE: {error}")
        raise SystemExit(2)
