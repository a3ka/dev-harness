#!/usr/bin/env python3
"""169: consumer cells for the make_task model-trace CLI after config-witness removal.

Семантика-кандидат (core-код уже завершён другими исполнителями; читать, не править):
  - явный --model-trace — ПУТЬ к TSV; не-файл (строка модели, отсутствующий путь)
    отказывает rc 1 с пустым stdout, диагноз называет флаг --model-trace;
    ни HARNESS_MODEL_TRACE, ни <registry>/trace.tsv не маскируют ошибочный ЯВНЫЙ вход;
  - незаданный аргумент — единственный неявный источник HARNESS_MODEL_TRACE живой
    сессии; битый env-путь — именованный отказ, называющий недоступного свидетеля;
  - трассы нет нигде — дословный отказ 095 «нет свидетельства модели: <роль>».
Клетка registry_not_implicit_source кодирует КАНДИДАТА: норма проектного дефолта
реестра 136/169 v1 ещё НЕ пересмотрена (дельта-таблица — см. пакет задания).
Оракул свидетельств — в памяти (правило 8): байты трёх TSV снимаются ДО вызовов
субъекта и сверяются после; диск субъекта как истина не перечитывается.
Каждый обманный стаб привязан к ветви КОДОМ (список stubs, Н-39).
"""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[3]
TOY = ROOT / "fixtures/context_pack_095/_toy.sh"
VERIFY = Path("/tmp/dev-harness-verify")
FROZEN = "frozen/contracts/169/1:scripts/make_task.sh"

NOWITNESS = "ОТКАЗ: нет свидетельства модели: orchestrator"
EXPLICIT_MSG = "--model-trace ожидает путь к TSV-файлу трассы (роль<TAB>модель<TAB>allowed); в штатной сессии свидетельство передаётся через HARNESS_MODEL_TRACE"

# Дореформенный блок frozen/169-1: неявное чтение <registry>/trace.tsv (136)
# плюс общий отказ без свидетеля. Честная модель-кандидат строится заменой
# этого блока на явный/неявный(env) расклад — патчем по коду, не копией продукта.
OLD136 = (
    'if [ -z "$TRACE" ]; then\n'
    '  _PP_JSON="$(project_paths_resolve "$REPO_ABS" 2>/dev/null)" || _PP_JSON=""\n'
    '  if [ -n "$_PP_JSON" ] && [ -f "$(printf \'%s\' "$_PP_JSON" | jq -r \'.registry\')/trace.tsv" ]; then\n'
    '    TRACE="$(printf \'%s\' "$_PP_JSON" | jq -r \'.registry\')/trace.tsv"\n'
    '  fi\n'
    '  unset _PP_JSON\n'
    'fi\n'
    '  if [ -z "$TRACE" ] || [ ! -f "$TRACE" ]; then die "нет свидетельства модели: $ROLE"; fi'
)
CANDIDATE = (
    'if [ -n "$TRACE" ]; then\n'
    '  [ -f "$TRACE" ] || die "' + EXPLICIT_MSG + '"\n'
    'elif [ -n "${HARNESS_MODEL_TRACE:-}" ]; then\n'
    '  [ -f "$HARNESS_MODEL_TRACE" ] || die "свидетельство сессии недоступно: $HARNESS_MODEL_TRACE"\n'
    '  TRACE="$HARNESS_MODEL_TRACE"\n'
    'else\n'
    '  die "нет свидетельства модели: $ROLE"\n'
    'fi'
)

# Якоря стабов — строки честной модели, встречающиеся ровно один раз.
HONEST_EXPLICIT_LINE = '  [ -f "$TRACE" ] || die "' + EXPLICIT_MSG + '"'
HONEST_ENV_LINE = '  [ -f "$HARNESS_MODEL_TRACE" ] || die "свидетельство сессии недоступно: $HARNESS_MODEL_TRACE"'
HONEST_ENV_ADOPT = HONEST_ENV_LINE + '\n  TRACE="$HARNESS_MODEL_TRACE"'
HONEST_ELSE = 'else\n  die "нет свидетельства модели: $ROLE"\nfi'
REGISTRY_RESTORE = (
    'else\n'
    '  _PP_JSON="$(project_paths_resolve "$REPO_ABS" 2>/dev/null)" || _PP_JSON=""\n'
    '  if [ -n "$_PP_JSON" ] && [ -f "$(printf \'%s\' "$_PP_JSON" | jq -r \'.registry\')/trace.tsv" ]; then\n'
    '    TRACE="$(printf \'%s\' "$_PP_JSON" | jq -r \'.registry\')/trace.tsv"\n'
    '  fi\n'
    '  unset _PP_JSON\n'
    '  [ -n "$TRACE" ] || die "нет свидетельства модели: $ROLE"\n'
    'fi'
)


def replace_one(source, old, new):
    if source.count(old) != 1:
        raise ValueError(f"mutation anchor appears {source.count(old)} times")
    return source.replace(old, new)


def run(subject, repo, *extra, env_trace=None):
    env = {k: v for k, v in os.environ.items() if k != "HARNESS_MODEL_TRACE"}
    if env_trace is not None:
        env["HARNESS_MODEL_TRACE"] = str(env_trace)
    return subprocess.run(["bash", str(subject), "--repo", str(repo), "--role", "orchestrator", "--kind", "brief", *extra], capture_output=True, text=True, timeout=30, env=env)


def ok_pack(label, result, model):
    lines = result.stdout.splitlines()
    ok = (result.returncode == 0 and result.stderr == ""
          and f"TRACE: role=orchestrator model={model} fallback=allowed" in lines
          and "=== GOAL ===" in lines)
    print(f"169 {label} {'ok' if ok else 'KRASNO'} rc={result.returncode} stderr={result.stderr.strip()!r}")
    return ok


def refuse(label, result, token=None, exact=None):
    text = result.stderr
    named = (token in text) if token is not None else (text.splitlines() == [exact])
    ok = result.returncode == 1 and result.stdout == "" and text != "" and named
    print(f"169 {label} {'ok' if ok else 'KRASNO'} rc={result.returncode} stderr={text.strip()!r}")
    return ok


def cases(subject, repo, world):
    explicit_tsv = world / "explicit-trace.tsv"
    env_tsv = world / "env-trace.tsv"
    missing_tsv = world / "missing-trace.tsv"  # никогда не создаётся
    registry_tsv = repo / "registry/trace.tsv"
    explicit_tsv.write_text("orchestrator\topenai-codex/gpt-6-sol\tallowed\n")
    env_tsv.write_text("orchestrator\tzai/glm-5.3\tallowed\n")
    registry_tsv.write_text("orchestrator\topenai-codex/gpt-6.1-terra\tallowed\n")
    oracle = {p: p.read_bytes() for p in (explicit_tsv, env_tsv, registry_tsv)}
    verdicts = {}
    # Явный вход: валидный путь побеждает env (precedence), ошибочный — отказ
    # без пака, никакой источник его не маскирует; диагноз называет флаг.
    verdicts["explicit_over_env"] = ok_pack(
        "explicit_over_env",
        run(subject, repo, "--model-trace", str(explicit_tsv), env_trace=env_tsv),
        "openai-codex/gpt-6-sol")
    verdicts["explicit_model_string"] = refuse(
        "explicit_model_string",
        run(subject, repo, "--model-trace", "openai-codex/gpt-5.6-terra", env_trace=env_tsv),
        token="--model-trace")
    verdicts["explicit_missing_path"] = refuse(
        "explicit_missing_path",
        run(subject, repo, "--model-trace", str(missing_tsv), env_trace=env_tsv),
        token="--model-trace")
    # Неявный вход: источник — env живой сессии (файл реестра при этом существует
    # и не выигрывает); битый env — именованный отказ без пака.
    verdicts["implicit_env_trace"] = ok_pack(
        "implicit_env_trace",
        run(subject, repo, env_trace=env_tsv),
        "zai/glm-5.3")
    verdicts["implicit_env_missing"] = refuse(
        "implicit_env_missing",
        run(subject, repo, env_trace=missing_tsv),
        token=str(missing_tsv))
    # КАНДИДАТ: env снят, файл реестра с валидной строкой существует — он НЕ
    # является неявным источником; отказ 095 дословно.
    verdicts["registry_not_implicit_source"] = refuse(
        "registry_not_implicit_source",
        run(subject, repo),
        exact=NOWITNESS)
    unchanged = all(p.read_bytes() == b for p, b in oracle.items())
    registry_tsv.unlink()
    # Отсутствие любого источника — прежний отказ 095 дословно.
    verdicts["no_trace_anywhere"] = refuse(
        "no_trace_anywhere",
        run(subject, repo),
        exact=NOWITNESS)
    unchanged &= (explicit_tsv.read_bytes() == oracle[explicit_tsv]
                  and env_tsv.read_bytes() == oracle[env_tsv])
    if not unchanged:
        print("169 trace_oracle KRASNO")
    verdicts["trace_oracle"] = unchanged
    return verdicts


def main():
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--repo", type=Path)
    group.add_argument("--model", action="store_true")
    group.add_argument("--stabs", action="store_true")
    args = parser.parse_args()
    VERIFY.mkdir(parents=True, exist_ok=True)
    world = subprocess.run(["bash", "-c", '. "$1"; _t95_world model-trace-169', "_", str(TOY)], capture_output=True, text=True, check=True).stdout.strip()
    world = Path(world)
    repo = world / "repo"
    # 095's toy omits ci.yml deliberately; profile_resolver requires the
    # declared workflow file to exist.
    (repo / "ci.yml").write_text("name: toy\n")
    try:
        if args.repo:
            subject = args.repo.resolve() / "scripts/make_task.sh"
            if not subject.is_file():
                print("169 SUBJECT_ABSENT", file=sys.stderr)
                return 2
            verdicts = cases(subject, repo, world)
            return 0 if all(verdicts.values()) else 1
        # Honest control: frozen pre-169 source patched BY CODE to the candidate
        # semantics — independent of the active checkout.
        source = subprocess.run(["git", "-C", str(ROOT), "show", FROZEN],
                                capture_output=True, text=True, check=True).stdout
        honest = replace_one(source, OLD136, CANDIDATE)
        with tempfile.TemporaryDirectory(prefix="model-trace-169-", dir=VERIFY) as tmp:
            out = Path(tmp) / "scripts"
            out.mkdir()
            for dependency in (ROOT / "scripts").iterdir():
                if dependency.is_file() and dependency.name != "make_task.sh":
                    (out / dependency.name).symlink_to(dependency)
            model = out / "honest.sh"
            model.write_text(honest)
            control = cases(model, repo, world)
            if not all(control.values()):
                print("169 CONTROL_INVALID", file=sys.stderr)
                return 2
            if args.model:
                return 0
            # Each impostor must diverge on its own observable case; no first-red shortcut.
            stubs = [
                ("old_missing_error",
                 replace_one(honest, HONEST_EXPLICIT_LINE,
                             '  [ -f "$TRACE" ] || die "нет свидетельства модели: $ROLE"'),
                 "explicit_model_string"),
                ("explicit_falls_back",
                 replace_one(honest, HONEST_EXPLICIT_LINE,
                             '  [ -f "$TRACE" ] || TRACE="${HARNESS_MODEL_TRACE:-}"'),
                 "explicit_model_string"),
                ("env_overrides_explicit",
                 replace_one(honest, HONEST_EXPLICIT_LINE,
                             HONEST_EXPLICIT_LINE + '\n  [ -n "${HARNESS_MODEL_TRACE:-}" ] && [ -f "$HARNESS_MODEL_TRACE" ] && TRACE="$HARNESS_MODEL_TRACE"'),
                 "explicit_over_env"),
                ("no_env_source",
                 replace_one(honest, HONEST_ENV_ADOPT,
                             '  die "нет свидетельства модели: $ROLE"'),
                 "implicit_env_trace"),
                ("env_broken_generic",
                 replace_one(honest, HONEST_ENV_LINE,
                             '  [ -f "$HARNESS_MODEL_TRACE" ] || die "нет свидетельства модели: $ROLE"'),
                 "implicit_env_missing"),
                ("registry_still_default",
                 replace_one(honest, HONEST_ELSE, REGISTRY_RESTORE),
                 "registry_not_implicit_source"),
                ("missing_is_new",
                 replace_one(honest, HONEST_ELSE,
                             'else\n  die "' + EXPLICIT_MSG + '"\nfi'),
                 "no_trace_anywhere"),
            ]
            failed = False
            for name, text, branch in stubs:
                path = out / (name + ".sh")
                path.write_text(text)
                observed = cases(path, repo, world)[branch]
                caught = not observed
                print(f"169 STAB {name} {'caught' if caught else 'ZHIV'} @ {branch}")
                failed |= not caught
            return 1 if failed else 0
    finally:
        shutil.rmtree(world)


if __name__ == "__main__":
    sys.exit(main())
