#!/usr/bin/env bash
# scripts/handoff_rotate.sh — перенос прежней секции «## ГДЕ МЫ» из HANDOFF.md в
# docs/handoff-archive/<дата>.md (контракт 091, И-1 … И-8).
#
# CLI:
#   bash scripts/handoff_rotate.sh [--root <dir>] [--date <YYYY-MM-DD>]
#
# Умолчания:
#   --root — каталог над scripts/ (т.е. worktree, из которого вызван скрипт)
#   --date — локальная дата запуска (date +%F)
#
# Коды возврата:
#   0 — успех: stdout ровно одна строка «архив: docs/handoff-archive/<дата>.md»
#   1 — именованный отказ (строка на stderr, ни одного байта не записано)
#   2 — NOT_IMPLEMENTED: неизвестный флаг / флаг без значения
#
# Маркеры 084 (BEGIN/END) — литеральные константы субъекта (Р8: не импорт lib_plan.sh).
set -uo pipefail

# ── Литеральные константы контракта 091 (побайтово) ──────────────────────────────────
# Заголовок секции: байтовое начало строки (И-2; `### ГДЕ МЫ` и `##  ГДЕ МЫ` — НЕ секция).
H91_SEC='## ГДЕ МЫ'
# Префикс следующего раздела — граница переноса (И-3: первая из …, строки `## `).
H91_H2='## '
# BEGIN-маркер 084 — граница span ЦЕЛОЙ СТРОКОЙ (`grep -Fx`-равенство, клетка o13).
H91_BEGIN='<!-- BEGIN GENERATED NEXT SESSION -->'
# Порог итогового файла (И-5: строго больше → отказ; ровно 30720 — успех).
H91_LIMIT=30720
# Каталог и путь архива от корня — стабильные, прямые слэши (И-1 stdout).
H91_ARCHDIR='docs/handoff-archive'
# Именованные строки отказов (И-2; ровно по одной на stderr, побайтово).
H91_OTKAZ_NET='ОТКАЗ: HANDOFF.md отсутствует'
H91_OTKAZ_DATE='ОТКАЗ: --date вне грамматики YYYY-MM-DD'
H91_OTKAZ_NOL='ОТКАЗ: в HANDOFF.md нет раздела «## ГДЕ МЫ»'
H91_OTKAZ_MANY='ОТКАЗ: в HANDOFF.md больше одного раздела «## ГДЕ МЫ»'
H91_OTKAZ_BIG='ОТКАЗ: итоговый HANDOFF.md больше 30 КБ'
H91_OTKAZ_EXIST_PRE='ОТКАЗ: архив уже существует: '
# Строка stdout успеха (И-1).
H91_OK_PRE='архив: '

# ── CLI ────────────────────────────────────────────────────────────────────────────────
ROOT=''
DATE=''

while [ "$#" -gt 0 ]; do
  case "$1" in
    --root)
      shift
      if [ "$#" -lt 1 ]; then
        printf 'NOT_IMPLEMENTED: --root без значения\n' >&2
        exit 2
      fi
      ROOT="$1"
      shift
      ;;
    --date)
      shift
      if [ "$#" -lt 1 ]; then
        printf 'NOT_IMPLEMENTED: --date без значения\n' >&2
        exit 2
      fi
      DATE="$1"
      shift
      ;;
    --help|-h)
      printf 'usage: %s [--root <dir>] [--date <YYYY-MM-DD>]\n' "${BASH_SOURCE[0]##*/}" >&2
      exit 2
      ;;
    --)
      shift
      if [ "$#" -gt 0 ]; then
        printf 'NOT_IMPLEMENTED: аргументы после --: %s\n' "$*" >&2
        exit 2
      fi
      break
      ;;
    -*)
      printf 'NOT_IMPLEMENTED: неизвестный флаг %s\n' "$1" >&2
      exit 2
      ;;
    *)
      printf 'NOT_IMPLEMENTED: позиционный аргумент %s\n' "$1" >&2
      exit 2
      ;;
  esac
done

# --root по умолчанию — каталог над scripts/ субъекта (И-1).
if [ -z "$ROOT" ]; then
  _here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || {
    printf 'NOT_IMPLEMENTED: не удалось определить корень\n' >&2
    exit 2
  }
  ROOT="$(cd "$_here/.." && pwd -P)" || {
    printf 'NOT_IMPLEMENTED: не удалось определить корень\n' >&2
    exit 2
  }
fi
# --date по умолчанию — локальная дата.
if [ -z "$DATE" ]; then
  DATE="$(date +%F)"
fi

# ── Проверка (1) существования HANDOFF.md в bash (ЕДИНСТВЕННАЯ bash-проверка, Р6 #1) ──
# Р6 порядок: HANDOFF отсутствует → отказ «HANDOFF.md отсутствует» ДО проверки даты,
# даже если --date синтаксически невалиден (составной вход «нет файла + плохая дата»,
# клетка Р6/прошлый прогон). Все остальные проверки — в python.
HAND="$ROOT/HANDOFF.md"
if [ ! -f "$HAND" ]; then
  printf '%s\n' "$H91_OTKAZ_NET" >&2
  exit 1
fi

# ── Делегируем работу python3 (И-3/И-4/И-7: байт-в-байт split+склейка) ────────────────
# python-скрипт получает:
#   argv[1] = HAND, argv[2] = DATE, argv[3] = ARCH_REL, argv[4] = ARCH_ABS
#   env H91_*_ENV = литеральные константы контракта (только те, что читаются
#     python'ом после удаления дублей — Р6/Ф-3)
#
# Протокол: на stdout — ровно одна строка успеха «архив: …»; на stderr — ровно одна
# строка именованного отказа; rc=0/1. Любой другой rc — NOT_IMPLEMENTED.
#
# Гарантии атомарности (И-6): все отказы — до записи. Temp-файлы архива и HANDOFF
# создаются В ЦЕЛЕВОМ КАТАЛОГЕ (`dir=…`) — иначе os.replace/rename(2) между ФС
# падает «Errno 18 Invalid cross-device link» (находка ревьюера круг 1, Ф-2).
# Никаких temp-файлов ВНЕ целевого каталога соответствующего файла при отказе.
ARCH_REL="$H91_ARCHDIR/$DATE.md"
ARCH_ABS="$ROOT/$ARCH_REL"

H91_SEC_ENV="$H91_SEC" \
H91_H2_ENV="$H91_H2" \
H91_BEGIN_ENV="$H91_BEGIN" \
H91_LIMIT_ENV="$H91_LIMIT" \
H91_OTKAZ_DATE_ENV="$H91_OTKAZ_DATE" \
H91_OTKAZ_NOL_ENV="$H91_OTKAZ_NOL" \
H91_OTKAZ_MANY_ENV="$H91_OTKAZ_MANY" \
H91_OTKAZ_BIG_ENV="$H91_OTKAZ_BIG" \
H91_OTKAZ_EXIST_PRE_ENV="$H91_OTKAZ_EXIST_PRE" \
H91_OK_PRE_ENV="$H91_OK_PRE" \
python3 - "$HAND" "$DATE" "$ARCH_REL" "$ARCH_ABS" <<'PYEOF'
import os
import re
import sys
import tempfile

HAND = sys.argv[1]
DATE = sys.argv[2]
ARCH_REL = sys.argv[3]
ARCH_ABS = sys.argv[4]

SEC = os.environ['H91_SEC_ENV'].encode('utf-8')
H2 = os.environ['H91_H2_ENV'].encode('utf-8')
BEGIN = os.environ['H91_BEGIN_ENV'].encode('utf-8')
LIMIT = int(os.environ['H91_LIMIT_ENV'])
OTKAZ_DATE = os.environ['H91_OTKAZ_DATE_ENV']
OTKAZ_NOL = os.environ['H91_OTKAZ_NOL_ENV']
OTKAZ_MANY = os.environ['H91_OTKAZ_MANY_ENV']
OTKAZ_BIG = os.environ['H91_OTKAZ_BIG_ENV']
OTKAZ_EXIST_PRE = os.environ['H91_OTKAZ_EXIST_PRE_ENV']
OK_PRE = os.environ['H91_OK_PRE_ENV']

def refuse(msg):
    sys.stderr.write(msg + '\n')
    sys.exit(1)

def not_impl(msg):
    sys.stderr.write('NOT_IMPLEMENTED: ' + msg + '\n')
    sys.exit(2)

# (2) грамматика --date — полное соответствие всей строки (Р9/И-9)
if re.fullmatch(r'[0-9]{4}-[0-9]{2}-[0-9]{2}', DATE) is None:
    refuse(OTKAZ_DATE)

# Читаем HANDOFF побайтово (без text-нормализации; И-3: «включая отсутствие/
# наличие завершающего LF»).
with open(HAND, 'rb') as f:
    data = f.read()

# Разбиваем на строки СТРОГО по b'\n' (Ф-1, находка ревьюера круг 1):
# контракт задаёт границу по LF (И-2 / awk `index($0,…)==1` построчно по `\n`).
# splitlines режет по `\r\n`/`\v`/`\f`/`\x1c-\x1e`/U+2028/2029 — это приводило
# к двум ложным сценариям: (a) одиночный CR внутри строки ложно открывал
# вторую секцию (`## ГДЕ МЫ a\r## ГДЕ МЫ b` ⇒ два starts, отказ Р6 o1/o2 хотя
# по LF секция одна); (b) span рвался посреди LF-строки на CR (`x\r## next` ⇒
# `x`|`## next` ⇒ преждевременная граница span, И-3/И-4 нарушены).
parts = data.split(b'\n')
lines = [p + b'\n' for p in parts[:-1]]
if parts[-1]:
    lines.append(parts[-1])

# (3) ровно одна секция «## ГДЕ МЫ» (И-2: байтовое начало СТРОГО LF-строки == SEC)
# Сравнение startswith(SEC) идёт по LF-строкам: `### ГДЕ МЫ` и `##  ГДЕ МЫ`
# (двойной пробел) — НЕ подходят (байты до позиции 9 иные); одиночный CR тоже
# не открывает новую секцию. Суффикс после литерала произволен (клетка o12).
starts = [k for k, ln in enumerate(lines) if ln.startswith(SEC)]
if len(starts) == 0:
    refuse(OTKAZ_NOL)
if len(starts) > 1:
    refuse(OTKAZ_MANY)
s = starts[0]

# Граница span (И-3): первая из (а) целой LF-строки BEGIN (клетка o13),
# (б) LF-строки с префиксом H2 (И-3), (в) EOF. Граница — LF-запись;
# подсегмент внутри одной LF-строки (например, после CR) границей НЕ
# является: «строка» в контракте == LF-запись, не байтовый подсегмент
# (И-2: `index($0,…)==1` идёт по LF-записям; И-3: «строка с префиксом ## »).
end_full = len(lines)
for k in range(s + 1, len(lines)):
    ln = lines[k]
    core = ln[:-1] if ln.endswith(b'\n') else ln
    if core == BEGIN:
        end_full = k
        break
    if ln.startswith(H2):
        end_full = k
        break

# Сборка span/prefix/tail байт-в-байт.
span = b''.join(lines[s:end_full])
prefix = b''.join(lines[:s])
tail = b''.join(lines[end_full:])
result = prefix + tail

# (4) архив этой даты отсутствует
if os.path.lexists(ARCH_ABS):
    refuse(OTKAZ_EXIST_PRE + ARCH_REL)

# (5) размер итогового ≤ LIMIT (И-5: строго больше → отказ)
if len(result) > LIMIT:
    refuse(OTKAZ_BIG)

# Запись: сначала архив, затем HANDOFF (И-7). Атомарно: tempfile.mkstemp(dir=…)
# гарантирует, что os.replace() — переименование ВНУТРИ одной ФС (иначе при
# $TMPDIR на другой ФС /dev/shm tmpfs rename(2) падает Errno 18 Invalid
# cross-device link; Ф-2). Каталог архива создаётся ДО mkstemp (Ф-2 фикс).
arch_dir = os.path.dirname(ARCH_ABS)
try:
    os.makedirs(arch_dir, exist_ok=True)
except OSError as e:
    not_impl('mkdir: ' + str(e))

try:
    fd_arch, tmp_arch = tempfile.mkstemp(
        prefix='handoff091-arch-', suffix='.tmp', dir=arch_dir)
except OSError as e:
    not_impl('arch mkstemp: ' + str(e))
try:
    with os.fdopen(fd_arch, 'wb') as f:
        f.write(span)
    os.replace(tmp_arch, ARCH_ABS)
except OSError as e:
    try: os.unlink(tmp_arch)
    except OSError: pass
    not_impl('arch write: ' + str(e))

hand_dir = os.path.dirname(HAND)
try:
    fd_hand, tmp_hand = tempfile.mkstemp(
        prefix='handoff091-hand-', suffix='.tmp', dir=hand_dir)
except OSError as e:
    not_impl('hand mkstemp: ' + str(e))
try:
    with os.fdopen(fd_hand, 'wb') as f:
        f.write(result)
    os.replace(tmp_hand, HAND)
except OSError as e:
    try: os.unlink(tmp_hand)
    except OSError: pass
    not_impl('hand write: ' + str(e))

sys.stdout.write(OK_PRE + ARCH_REL + '\n')
sys.exit(0)
PYEOF
rc=$?
if [ "$rc" -eq 0 ]; then
  exit 0
elif [ "$rc" -eq 1 ]; then
  exit 1
else
  exit 2
fi
