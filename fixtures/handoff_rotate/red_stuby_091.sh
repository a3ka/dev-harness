#!/usr/bin/env bash
# Стаб-пак 091 (Н-39: привязка стабов к входам — ЗДЕСЬ, в коде, не в прозе контракта).
#
# Каждый обманный стаб — мини-субъект, подставляемый батареей (env H91_SUBJECT) вместо
# scripts/handoff_rotate.sh, и прогоняется на ОДНОЙ клетке — входе, где его дефект
# наблюдаем: клетка обязана быть красной (rc 1 батареи, «КРАСНО: <клетка>»). Диффпроба:
# честный мини-субъект зелён на ВСЕХ клетках батареи (единый прогон, rc 0) — иначе
# клетки ловят не дефект, а себя. rc 2 — нечем проверить.
#
# Мини-субъекты (честный и стабы) — bash-обёртка + python3; литералы оракула (строки
# отказов, маркеры, префиксы) приходят env-ом из _toy.sh (единый источник), оракул в env
# БЕЗ дефектных вставок стабам не передаётся.
#
# PAK (стаб → клетка; дефект):
#   s1  → к0  архив теряет СЛУЧАЙНУЮ непустую строку секции (класс Н-209: ручной
#             перенос терял строку-указатель; тест по классу — строка произвольна)
#   s2  → к0  архив теряет пустые строки (пересборка «grep .»)
#   s3  → к0  архиву предпослана строка-шапка «История HANDOFF…» (привычка образца
#             2026-10-03) — архив не байт-в-байт
#   s4  → к0  маркерный блок продублирован в итоговом HANDOFF (BEGIN дважды)
#   s5  → к0  маркерная строка BEGIN исчезла из итогового HANDOFF (унесена в архив)
#   s6  → к6  архиву дописан завершающий LF, которого не было («нормализация»)
#   s7  → к0  граница переноса обрывается на `### `-подразделе (секция неполна)
#   s8  → к3  границы нет: перенос до EOF, следующий раздел `^## ` съеден в архив
#   s9  → о1  отказа при нуле секций нет: весь файл «архивирован», rc 0
#   s10 → о2  отказа при двух секциях нет: молча архивируется первая
#   s11 → о3  проверки размера нет: пишет при итоге >30 КБ
#   s12 → о5  существующий архив перезаписан (нет отказа «уже существует»)
#   s13 → о6  грамматики --date нет: любая дата принимается
#   s14 → o11 грамматика --date ищет ПОДСТРОКУ (re.search), не полное соответствие:
#             «../2042-06-17» проходит, пишет архив вне docs/handoff-archive
#   s15 → o12 счёт секций сужен до формы «## ГДЕ МЫ (»: вторая секция с иным суффиксом
#             литерала не считается — молча архивируется первая
#   s16 → o13 граница span — ПРЕФИКС маркерной строки, не целая строка: маркероподобная
#             строка в теле обрывает архив до конца файла
#   s17 → o1  отказ правильный, но перед ним в root остаётся .handoff-rotate.tmp —
#             ловится полным снимком дерева (И-6 «более ничего не создано»)
#
# Использование: bash red_stuby_091.sh <корень>. Итог: «стаб-пак 091: N/17 поймано,
# диффпроба M/17»; rc 0 ⟺ N = M = 17.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
H91_ROOT="$(cd "${1:-$HERE/../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
# shellcheck disable=SC1091
. "$HERE/_toy.sh"

# ── честный мини-субъект: обёртка с литералами оракула из _toy.sh ───────────────────────
gen_obertka() {
  printf '#!/usr/bin/env bash\nset -uo pipefail\n'
  printf 'export H91L_NET=%q H91L_DATE=%q H91L_NOL=%q H91L_MANY=%q H91L_BIG=%q H91L_EXIST=%q\n' \
    "$H91_OTKAZ_NET" "$H91_OTKAZ_DATE" "$H91_OTKAZ_NOL" "$H91_OTKAZ_MANY" "$H91_OTKAZ_BIG" "$H91_OTKAZ_EXIST_PRE"
  printf 'export H91L_SEC=%q H91L_H2=%q H91L_BEGIN=%q H91L_END=%q\n' \
    "$H91_SEC" "$H91_H2" "$H91_BEGIN" "$H91_END"
  cat <<'H91PY'
exec python3 - "$@" <<'H91PYIN'
import os, re, sys
args = sys.argv[1:]
ROOT = None
DATE = None
i = 0
while i < len(args):
    a = args[i]
    if a == '--root' and i + 1 < len(args):
        ROOT = args[i + 1]
        i += 2
    elif a == '--date' and i + 1 < len(args):
        DATE = args[i + 1]
        i += 2
    else:
        sys.stderr.write('NOT_IMPLEMENTED: аргументы\n')
        sys.exit(2)
if ROOT is None:
    ROOT = os.getcwd()
if DATE is None:
    import time
    DATE = time.strftime('%Y-%m-%d')

def refuse(msg):
    sys.stderr.write(msg + '\n')
    sys.exit(1)

SEC = os.environ['H91L_SEC'].encode('utf-8')
H2 = os.environ['H91L_H2'].encode('utf-8')
BEGIN = os.environ['H91L_BEGIN'].encode('utf-8')
HAND = os.path.join(ROOT, 'HANDOFF.md')
ARCH_REL = 'docs/handoff-archive/' + DATE + '.md'
ARCH = os.path.join(ROOT, ARCH_REL)

if not os.path.isfile(HAND):
    refuse(os.environ['H91L_NET'])
if re.fullmatch(r'[0-9]{4}-[0-9]{2}-[0-9]{2}', DATE) is None:
    refuse(os.environ['H91L_DATE'])

with open(HAND, 'rb') as f:
    data = f.read()
lines = data.splitlines(keepends=True)
starts = [k for k, ln in enumerate(lines) if ln.startswith(SEC)]
if len(starts) == 0:
    refuse(os.environ['H91L_NOL'])
if len(starts) > 1:
    refuse(os.environ['H91L_MANY'])
s = starts[0]
end = len(lines)
for k in range(s + 1, len(lines)):
    core = lines[k][:-1] if lines[k].endswith(b'\n') else lines[k]
    if lines[k].startswith(H2) or core == BEGIN:
        end = k
        break
span = b''.join(lines[s:end])
result = b''.join(lines[:s]) + b''.join(lines[end:])
if os.path.exists(ARCH):
    refuse(os.environ['H91L_EXIST'] + ARCH_REL)
if len(result) > 30720:
    refuse(os.environ['H91L_BIG'])
os.makedirs(os.path.dirname(ARCH), exist_ok=True)
with open(ARCH, 'wb') as f:
    f.write(span)
tmp = HAND + '.h91tmp'
with open(tmp, 'wb') as f:
    f.write(result)
os.replace(tmp, HAND)
sys.stdout.write('архив: ' + ARCH_REL + '\n')
H91PYIN
H91PY
}

CHEST="$SCR/chestnoj_091.sh"
gen_obertka > "$CHEST" || { printf 'NOT_IMPLEMENTED: нет честного мини-субъекта\n' >&2; exit 2; }

# ── заплатки стабов: (якорь → замена), якорь ровно один в честном теле ──────────────────
cat > "$SCR/gen_stab_091.py" <<'GENPY'
import sys

PATCHES = {
    's1': (
        "    f.write(span)",
        "    ls_ = span.split(b'\\n')\n"
        "    idx_ = [j for j, t in enumerate(ls_) if t.strip()]\n"
        "    import random\n"
        "    del ls_[random.choice(idx_)]\n"
        "    f.write(b'\\n'.join(ls_))",
    ),
    's2': (
        "    f.write(span)",
        "    f.write(b'\\n'.join(t for t in span.split(b'\\n') if t.strip()))",
    ),
    's3': (
        "    f.write(span)",
        "    f.write('История HANDOFF; текущее состояние — HANDOFF.md.\\n'.encode('utf-8') + span)",
    ),
    's4': (
        "with open(tmp, 'wb') as f:",
        "RL = result.splitlines(keepends=True)\n"
        "b_ = [j for j, t in enumerate(RL) if t.rstrip(b'\\n') == BEGIN][0]\n"
        "e_ = [j for j, t in enumerate(RL) if t.rstrip(b'\\n') == os.environ['H91L_END'].encode('utf-8')][0]\n"
        "result = b''.join(RL[:e_ + 1] + RL[b_:e_ + 1] + RL[e_ + 1:])\n"
        "with open(tmp, 'wb') as f:",
    ),
    's5': (
        "with open(tmp, 'wb') as f:",
        "result = b''.join(t for t in result.splitlines(keepends=True) if t.rstrip(b'\\n') != BEGIN)\n"
        "with open(tmp, 'wb') as f:",
    ),
    's6': (
        "    f.write(span)",
        "    f.write(span if span.endswith(b'\\n') else span + b'\\n')",
    ),
    's7': (
        "    if lines[k].startswith(H2) or core == BEGIN:",
        "    if lines[k].startswith(H2) or core == BEGIN or lines[k].startswith('### '.encode('utf-8')):",
    ),
    's8': (
        "    if lines[k].startswith(H2) or core == BEGIN:",
        "    if False:",
    ),
    's9': (
        "    refuse(os.environ['H91L_NOL'])",
        "    os.makedirs(os.path.dirname(ARCH), exist_ok=True)\n"
        "    with open(ARCH, 'wb') as f:\n"
        "        f.write(data)\n"
        "    sys.stdout.write('архив: ' + ARCH_REL + '\\n')\n"
        "    sys.exit(0)",
    ),
    's10': (
        "    refuse(os.environ['H91L_MANY'])",
        "    starts = starts[:1]",
    ),
    's11': (
        "    refuse(os.environ['H91L_BIG'])",
        "    pass",
    ),
    's12': (
        "    refuse(os.environ['H91L_EXIST'] + ARCH_REL)",
        "    pass",
    ),
    's13': (
        "    refuse(os.environ['H91L_DATE'])",
        "    pass",
    ),
    's14': (
        "if re.fullmatch(r'[0-9]{4}-[0-9]{2}-[0-9]{2}', DATE) is None:",
        "if re.search(r'[0-9]{4}-[0-9]{2}-[0-9]{2}', DATE) is None:",
    ),
    's15': (
        "starts = [k for k, ln in enumerate(lines) if ln.startswith(SEC)]",
        "starts = [k for k, ln in enumerate(lines) if ln.startswith(SEC + b' (')]",
    ),
    's16': (
        "    if lines[k].startswith(H2) or core == BEGIN:",
        "    if lines[k].startswith(H2) or core.startswith(BEGIN):",
    ),
    's17': (
        "def refuse(msg):",
        "def refuse(msg):\n"
        "    with open(os.path.join(ROOT, '.handoff-rotate.tmp'), 'w') as leftover:\n"
        "        leftover.write('rotation pending\\n')",
    ),
}

src, name, dst = sys.argv[1], sys.argv[2], sys.argv[3]
old, new = PATCHES[name]
text = open(src, encoding='utf-8').read()
n = text.count(old)
if n != 1:
    sys.stderr.write('якорь %s встречен %d раз\n' % (name, n))
    sys.exit(3)
open(dst, 'w', encoding='utf-8').write(text.replace(old, new, 1))
GENPY

# ── диффпроба: честный мини-субъект зелён на ВСЕХ клетках ───────────────────────────────
H91_SUBJECT="$CHEST" bash "$HERE/red_rotate_091.sh" "$H91_ROOT" > "$SCR/honest_out" 2> "$SCR/honest_err"
hrc=$?
if [ "$hrc" -ne 0 ]; then
  printf 'NOT_IMPLEMENTED: честный мини-субъект не зелён (rc=%s) — клетки противоречивы:\n' "$hrc" >&2
  cat "$SCR/honest_out" "$SCR/honest_err" >&2
  exit 2
fi
DIF=17
printf 'диффпроба: честный мини-субъект зелён на всех клетках батареи (rc=0)\n'

# ── стабы: каждый красен на СВОЕЙ клетке ────────────────────────────────────────────────
PAK=('s1 k0' 's2 k0' 's3 k0' 's4 k0' 's5 k0' 's6 k6' 's7 k0' 's8 k3'
     's9 o1' 's10 o2' 's11 o3' 's12 o5' 's13 o6' 's14 o11' 's15 o12' 's16 o13' 's17 o1')
POJM=0
for para in "${PAK[@]}"; do
  stab="${para%% *}"; klet="${para##* }"
  python3 "$SCR/gen_stab_091.py" "$CHEST" "$stab" "$SCR/$stab.sh" || {
    printf 'NOT_IMPLEMENTED: заплатка %s не легла\n' "$stab" >&2; exit 2; }
  H91_SUBJECT="$SCR/$stab.sh" bash "$HERE/red_rotate_091.sh" "$H91_ROOT" "$klet" \
    > "$SCR/stab_out" 2> "$SCR/stab_err"
  rc=$?
  if [ "$rc" -eq 1 ] && grep -q "КРАСНО: $klet" "$SCR/stab_out" "$SCR/stab_err"; then
    POJM=$((POJM + 1))
    printf '%s → %s: поймано\n' "$stab" "$klet"
  else
    printf '%s → %s: МИМО (rc=%s) — вывод клетки:\n' "$stab" "$klet" "$rc" >&2
    cat "$SCR/stab_out" "$SCR/stab_err" >&2
  fi
done

printf 'стаб-пак 091: %s/17 поймано, диффпроба %s/17\n' "$POJM" "$DIF"
[ "$POJM" -eq 17 ] && [ "$DIF" -eq 17 ]
