#!/usr/bin/env bash
# Барьер CI-достижимости (контракт 040). РЕШЕНИЕ арбитража
# (verdicts/arbitration/040-batching-kriterii-i-tehnika.md, §Б3, «РЕШЕНИЕ,
# часть 2»): предикат — fail-closed СТРУКТУРНЫЙ, не построчное регулярное
# выражение. Прежняя редакция (critic contracts-040-v2, Б3) засчитывала
# `if: false`, `run: npm run <key> || true`, `run: npm run <key>; true` —
# ТЕКСТОВОЕ присутствие ключа, не гарантию исполнения. Здесь:
#
#  1. Разбор — СТРУКТУРНЫЙ, по объявленному подмножеству формы: блочный YAML,
#     `steps:` — список `- ` элементов на общем отступе. Flow-стиль
#     (`steps: [...]`), якоря/алиасы (`&x`/`*x`) и теги (`!x`) — ВНЕ
#     подмножества → rc=1 «форма шага вне объявленного подмножества», НЕ
#     молчаливый пропуск (доктрина verdicts/arbitration/oblast-i-porog.md,
#     вопрос 1: сверх-приближение — да, но НЕ произвольная форма без отказа).
#  2. Шаг с нужной командой ОТКАЗЫВАЕТ при наличии `if:` на шаге, его джобе
#     или в ЕЁ needs:-транзитивном замыкании — БЕЗ вычисления выражения
#     (тот же прецедент «if: не читается, не решает, какой шаг исполнится» —
#     verify_ci_parity.sh не правится ни на байт, направление здесь обратное:
#     `if:` ЗАПРЕЩЁН, а не сверх-приближён).
#  3. `continue-on-error: true` на шаге или джобе → rc=1.
#  4. `run:` сверяется на РАВЕНСТВО канонической форме (`npm run <ключ>` либо
#     `npm run-script <ключ>`, опционально хвост ` -- <аргументы>`), не на
#     вхождение подстроки; наличие `|`, `&&`, `;`, `>`, `` ` ``, `$(` в строке
#     `run` → rc=1 (замер арбитра З6 — иначе `|| true`/`; true` проходят).
#  5. Существующие проверки (rc через npm == rc напрямую для ОБЕИХ проб,
#     зелёный verify_ci_parity.sh) сохраняются НИЖЕ без изменений.
#
#  Разбор ПИШЕТСЯ В САМОЙ ПРОБЕ (не переиспользует парсер
#  verify_ci_parity.sh): дублирование — принятая цена (арбитраж, §Б3 п.6):
#  тот барьер принадлежит замороженному контракту 020, править чужой
#  замороженный предмет ради выноса разбора в общий модуль было бы неверно.
#
# rc 0 — обе пробы CI-достижимы структурно (см. п.1-5) И rc-паритет держится
#        И verify_ci_parity.sh зелёный;
# rc 1 — отказ с ИМЕНОВАННОЙ причиной;
# rc 2 — предмет ещё НЕ реализован (npm-ключ для одной/обеих фикстур
#        отсутствует в package.json) — ОЖИДАЕМОЕ состояние ДО implementer'а.
#
#   bash fixtures/check_zones/probe_ci_dostizhimost_predelov.sh [<корень>]
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="${1:-$(cd "$HERE/../.." && pwd)}"
PKG="$ROOT/package.json"
CI="$ROOT/.github/workflows/ci.yml"
ZFIX="fixtures/check_zones/red_predel_git_vyzovov.sh"
PFIX="fixtures/check_protected/red_predel_git_vyzovov_ours.sh"

command -v python3 >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет python3\n' >&2; exit 2; }
[ -f "$PKG" ] || { printf 'NOT_IMPLEMENTED: нет %s\n' "$PKG" >&2; exit 2; }
[ -f "$ROOT/$ZFIX" ] || { printf 'NOT_IMPLEMENTED: нет %s\n' "$ROOT/$ZFIX" >&2; exit 2; }
[ -f "$ROOT/$PFIX" ] || { printf 'NOT_IMPLEMENTED: нет %s\n' "$ROOT/$PFIX" >&2; exit 2; }

fail() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }

find_key() {
  python3 - "$PKG" "$1" <<'PYEOF'
import json, sys
pkg, want = sys.argv[1], sys.argv[2]
scripts = json.load(open(pkg)).get("scripts", {})
target = "bash " + want
for k, v in scripts.items():
    if v.strip() == target:
        print(k)
        break
PYEOF
}

ZKEY="$(find_key "$ZFIX")"
PKEY="$(find_key "$PFIX")"
if [ -z "$ZKEY" ] || [ -z "$PKEY" ]; then
  printf 'NOT_IMPLEMENTED: package.json не несёт npm-ключ со значением "bash %s" и/или "bash %s" — implementer ещё не подключил (ожидаемо ДО реализации)\n' "$ZFIX" "$PFIX" >&2
  exit 2
fi

# 1. rc через npm совпадает с rc прямого вызова фикстуры (обе независимо).
( cd "$ROOT" && npm run --silent "$ZKEY" >/dev/null 2>&1 ); npm_z=$?
( cd "$ROOT" && bash "$ZFIX" >/dev/null 2>&1 ); direct_z=$?
[ "$npm_z" -eq "$direct_z" ] || fail "npm run $ZKEY (rc=$npm_z) != прямой bash $ZFIX (rc=$direct_z)"

( cd "$ROOT" && npm run --silent "$PKEY" >/dev/null 2>&1 ); npm_p=$?
( cd "$ROOT" && bash "$PFIX" >/dev/null 2>&1 ); direct_p=$?
[ "$npm_p" -eq "$direct_p" ] || fail "npm run $PKEY (rc=$npm_p) != прямой bash $PFIX (rc=$direct_p)"

# 2. СТРУКТУРНЫЙ fail-closed предикат (РЕШЕНИЕ §Б3, часть 2, п.1-4).
[ -f "$CI" ] || fail "нет $CI — подключать некуда"
struct_out="$(python3 - "$CI" "$ZKEY" "$PKEY" <<'PYEOF'
import re, sys

path, zkey, pkey = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path, encoding='utf-8', errors='replace') as f:
    raw = [l.rstrip('\n') for l in f]

def indent(l):
    return len(l) - len(l.lstrip(' '))

def is_blank_or_comment(l):
    s = l.strip()
    return s == '' or s.startswith('#')

# ── п.1: подмножество — блочный YAML только. Якоря/алиасы/теги/flow ЗАПРЕЩЕНЫ. ──
ANCHOR_RE = re.compile(r'(^|[:\-]\s)[&*!][^\s#\'"]')
for i, l in enumerate(raw):
    if is_blank_or_comment(l):
        continue
    stripped = l.strip()
    if ANCHOR_RE.search(l) and not re.match(r'^\s*#', stripped):
        # исключаем ложные срабатывания на URL/строках в кавычках — якорь/алиас/тег
        # всегда идёт СРАЗУ после ': ' или '- ' без кавычек.
        m = re.search(r'(:|-)\s([&*!])(\S)', l)
        if m and m.group(3) not in ('{', '['):
            print("FAIL\tформа шага вне объявленного подмножества: якорь/алиас/тег на строке %d: %s" % (i + 1, stripped))
            sys.exit(0)
    m = re.match(r'^(\s*)steps:\s*(\[.*)$', l)
    if m:
        print("FAIL\tформа шага вне объявленного подмножества: flow-стиль steps на строке %d" % (i + 1))
        sys.exit(0)

# ── минимальный блочный разбор: jobs -> {if, needs, steps:[{run,if,coe}]} ──
def parse_block_map(lines, i, ind):
    """Разобрать отображение НАЧИНАЯ со строки i на отступе ind. Вернуть (dict, next_i).
    dict: key -> (raw_value_or_None, child_lines_start, child_indent) для вложенных;
    плоские значения хранятся как строки."""
    out = {}
    n = len(lines)
    while i < n:
        l = lines[i]
        if is_blank_or_comment(l):
            i += 1
            continue
        cur = indent(l)
        if cur < ind:
            break
        if cur > ind:
            i += 1
            continue
        s = l.strip()
        if s.startswith('- '):
            break
        km = re.match(r'^([^:]+):\s?(.*)$', s)
        if not km:
            i += 1
            continue
        key = km.group(1).strip()
        rest = km.group(2).strip()
        i += 1
        if rest == '' or rest.startswith('#'):
            out[key] = ('__BLOCK__', i)
        else:
            out[key] = (rest, None)
    return out, i

def find_block_end(lines, start, parent_ind):
    """Отступ первого значимого дочернего элемента, начиная с start."""
    n = len(lines)
    j = start
    while j < n and is_blank_or_comment(lines[j]):
        j += 1
    if j >= n:
        return None, j
    return indent(lines[j]), j

def parse_seq(lines, i, ind):
    """Разобрать последовательность '- ...' элементов на отступе ind, вернуть (list, next_i)."""
    items = []
    n = len(lines)
    while i < n:
        l = lines[i]
        if is_blank_or_comment(l):
            i += 1
            continue
        cur = indent(l)
        if cur < ind:
            break
        if cur > ind:
            i += 1
            continue
        s = l.strip()
        if not s.startswith('-'):
            break
        content = s[1:].lstrip(' ')
        col = cur + (len(s) - len(content))
        if content == '':
            i += 1
            sub_ind, j = find_block_end(lines, i, ind)
            if sub_ind is None or sub_ind <= ind:
                items.append({})
                i = j
                continue
            d, i = parse_block_map(lines, j, sub_ind)
            items.append(d)
        else:
            # содержимое элемента начинается в своей колонке (типичный
            # "- name: X" или "- run: Y")
            lines[i] = ' ' * col + content
            d, i = parse_block_map(lines, i, col)
            items.append(d)
    return items, i

# найти "jobs:" на верхнем уровне
jobs = {}
i = 0
n = len(raw)
while i < n:
    l = raw[i]
    if not is_blank_or_comment(l) and re.match(r'^jobs:\s*$', l):
        i += 1
        break
    i += 1
else:
    print("FAIL\tнет ключа jobs: верхнего уровня в %s" % path)
    sys.exit(0)

jind, i = find_block_end(raw, i, -1)
if jind is None:
    print("FAIL\tjobs: пусто в %s" % path)
    sys.exit(0)
jobs_map, _ = parse_block_map(raw, i, jind)

def resolve_scalar(val):
    v = val.strip()
    if len(v) >= 2 and v[0] == v[-1] and v[0] in ('"', "'"):
        v = v[1:-1]
    return v

parsed_jobs = {}
for jobname, (jv, jstart) in jobs_map.items():
    if jv != '__BLOCK__':
        continue
    jsub_ind, j0 = find_block_end(raw, jstart, -1)
    if jsub_ind is None:
        continue
    jmap, _ = parse_block_map(raw, j0, jsub_ind)
    has_if = 'if' in jmap
    needs = []
    if 'needs' in jmap:
        nv, nstart = jmap['needs']
        if nv == '__BLOCK__':
            nsub_ind, n0 = find_block_end(raw, nstart, -1)
            if nsub_ind is not None:
                nlist, _ = parse_seq(raw, n0, nsub_ind)
                needs = [x if isinstance(x, str) else '' for x in nlist]
        else:
            nv2 = nv.strip()
            if nv2.startswith('['):
                needs = [p.strip().strip('"\'') for p in nv2[1:-1].split(',') if p.strip()]
            else:
                needs = [resolve_scalar(nv2)]
    steps = []
    if 'steps' in jmap:
        sv, sstart = jmap['steps']
        if sv == '__BLOCK__':
            ssub_ind, s0 = find_block_end(raw, sstart, -1)
            if ssub_ind is not None:
                steps, _ = parse_seq(raw, s0, ssub_ind)
        else:
            print("FAIL\tформа шага вне объявленного подмножества: steps: не блочный список в джобе %s" % jobname)
            sys.exit(0)
    parsed_jobs[jobname] = {"if": has_if, "needs": needs, "steps": steps}

def needs_closure_has_if(jobname, seen=None):
    seen = seen or set()
    if jobname in seen:
        return False
    seen.add(jobname)
    j = parsed_jobs.get(jobname)
    if j is None:
        return False
    if j["if"]:
        return True
    for dep in j["needs"]:
        if needs_closure_has_if(dep, seen):
            return True
    return False

FORBIDDEN_CHARS = ['|', '&&', ';', '>', '`', '$(']
CANON_RE = re.compile(r'^npm run(?:-script)? (%s|%s)(?: -- .+)?$')

def check_key(key):
    pat = CANON_RE.pattern % (re.escape(key), re.escape(key))
    canon = re.compile(pat)
    for jobname, j in parsed_jobs.items():
        for step in j["steps"]:
            if not isinstance(step, dict) or 'run' not in step:
                continue
            rv, _ = step['run']
            if rv == '__BLOCK__':
                continue  # блочный скаляр run: | ... — не наша каноническая форма, не кандидат
            run_text = resolve_scalar(rv)
            if key not in run_text:
                continue
            # кандидат найден — теперь СТРОГО: запрещённые символы, затем равенство форме.
            for ch in FORBIDDEN_CHARS:
                if ch in run_text:
                    return ("FAIL", "run содержит запрещённый оператор оболочки '%s' у шага для %s: %s" % (ch, key, run_text))
            if not canon.match(run_text):
                return ("FAIL", "run не в канонической форме для %s: %s" % (key, run_text))
            if 'if' in step:
                return ("FAIL", "шаг для %s несёт if: — исполнение не безусловно" % key)
            if 'continue-on-error' in step:
                cv, _ = step['continue-on-error']
                if resolve_scalar(cv) == 'true':
                    return ("FAIL", "шаг для %s несёт continue-on-error: true" % key)
            if j["if"]:
                return ("FAIL", "джоба %s (несёт шаг для %s) сама имеет if:" % (jobname, key))
            if needs_closure_has_if(jobname):
                return ("FAIL", "needs-замыкание джобы %s (несёт шаг для %s) содержит if:" % (jobname, key))
            return ("OK", jobname)
    return ("MISSING", None)

rz = check_key(zkey)
rp = check_key(pkey)
for key, (status, detail) in ((zkey, rz), (pkey, rp)):
    if status == "FAIL":
        print("FAIL\t%s" % detail)
        sys.exit(0)
if rz[0] == "MISSING" or rp[0] == "MISSING":
    print("MISSING\tшаг с канонической командой не найден для %s и/или %s ни в одной джобе %s" % (zkey, pkey, path))
    sys.exit(0)
print("OK\t%s,%s" % (rz[1], rp[1]))
PYEOF
)"
struct_status="${struct_out%%$'\t'*}"
struct_detail="${struct_out#*$'\t'}"
case "$struct_status" in
  OK) ;;
  MISSING) fail "$struct_detail — implementer добавил npm-скрипты, но не подключил CI-шаг (см. §Зоны 040)" ;;
  *) fail "$struct_detail" ;;
esac

# 3. верхнеуровневый триггер: push{branches:[main]} И pull_request (доктрина §Б3
#    ч.1 — "срабатывающего на push в main и на pull_request").
trig_ok="$(python3 - "$CI" <<'PYEOF'
import re, sys
text = open(sys.argv[1], encoding='utf-8', errors='replace').read()
has_pr = re.search(r'^\s*pull_request:', text, re.M) is not None
has_push_main = re.search(r'^\s*push:\s*\n(?:.*\n)*?\s*branches:\s*\[[^\]]*\bmain\b[^\]]*\]', text, re.M) is not None
print("1" if (has_pr and has_push_main) else "0")
PYEOF
)"
[ "$trig_ok" = "1" ] || fail "workflow $CI не срабатывает безусловно на push{branches:[main]} И pull_request (§Б3 ч.1)"

# 4. verify_ci_parity.sh держится зелёным с новой проводкой.
( cd "$ROOT" && bash scripts/verify_ci_parity.sh "$ROOT" >/dev/null 2>&1 ); parity_rc=$?
[ "$parity_rc" -eq 0 ] || fail "verify_ci_parity.sh rc=$parity_rc — новая CI-проводка не распознана паритетом"

job_z="${struct_detail%%,*}"; job_p="${struct_detail#*,}"
printf 'CI-ДОСТИЖИМОСТЬ ДЕРЖИТСЯ (СТРУКТУРНО, fail-closed): %s -> джоба %s, rc(npm)=%s=rc(прямой)=%s; %s -> джоба %s, rc(npm)=%s=rc(прямой)=%s; безусловный триггер push/pull_request; verify_ci_parity rc=0\n' \
  "$ZKEY" "$job_z" "$npm_z" "$direct_z" "$PKEY" "$job_p" "$npm_p" "$direct_p" >&2
exit 0
