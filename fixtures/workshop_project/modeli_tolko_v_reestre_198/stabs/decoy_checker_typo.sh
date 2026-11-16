#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ (контракт 198): «сверщик с опечатанным заголовком». Разбирает
# факты честно, но литерал заголовка правил расходится с каноном AGENTS.md
# («…стоило время» вместо «…стоило времени») — секция никогда не находится,
# множество правил пусто, недоставка НЕ обнаруживается. Это и есть живой
# дефект малой правки; ловится клеткой pravila_missing_detected.
set -u
MA= ME= PA= PE=
while [ "$#" -gt 0 ]; do
  case "$1" in
    --main-argv) MA="$2" ;;
    --main-env) ME="$2" ;;
    --project-argv) PA="$2" ;;
    --project-env) PE="$2" ;;
    *) printf 'НЕЧЕМ-ПРОВЕРИТЬ neizvestnyj-klyuch\n'; exit 2 ;;
  esac
  shift 2
done
for _f in "$MA" "$ME" "$PA" "$PE"; do
  [ -n "$_f" ] && [ -s "$_f" ] || { printf 'НЕЧЕМ-ПРОВЕРИТЬ fakty-otsutstvuyut\n'; exit 2; }
done
exec python3 - "$MA" "$ME" "$PA" "$PE" <<'PY'
import sys

ZAGOLOVOK_PRAVIL = "## Правила, каждое из которых уже стоило время"  # опечатка: канон «времени»


def odino(path, flag):
    with open(path) as h:
        argv = h.read().split("\n")
    vals = [argv[i + 1] for i in range(len(argv) - 1) if argv[i] == flag]
    return vals[0] if vals else None


def env(path):
    env = {}
    with open(path) as h:
        for ln in h.read().split("\n"):
            if "=" in ln:
                k, v = ln.split("=", 1)
                env.setdefault(k, v)
    return env


ma, me, pa, pe = sys.argv[1:5]
prompt = odino(ma, "--append-system-prompt")
cwd = env(me).get("PWD", "")
base = open(prompt).read() if prompt else None
rules = []
try:
    ag = open(cwd + "/AGENTS.md").read()
    lines = ag.split("\n")
    if ZAGOLOVOK_PRAVIL in lines:  # никогда: литерал ≠ канону
        i = lines.index(ZAGOLOVOK_PRAVIL)
        rules = [lines[i]]
        for ln in lines[i + 1:]:
            if ln.startswith("## "):
                break
            rules.append(ln)
except OSError:
    pass
pt = open(odino(pa, "--append-system-prompt")).read()
ok = pt.startswith(base or "") and all(r in pt.split("\n") for r in rules if r.strip())
if not ok:
    print("РАСХОЖДЕНИЕ pravila")
    sys.exit(1)
sys.exit(0)
PY
