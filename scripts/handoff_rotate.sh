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
# Грамматика --date: ПОЛНОЕ соответствие всей строки (Р9/И-9, fullmatch, не поиск подстроки).
H91_DATE_RE='^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
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

# ── Проверка (1) существования HANDOFF.md в bash (Р6: ДО грамматики --date) ─────────
# Р6 порядок: HANDOFF отсутствует → отказ «HANDOFF.md отсутствует» ДО проверки даты,
# даже если --date синтаксически невалиден (составной вход «нет файла + плохая дата»).
HAND="$ROOT/HANDOFF.md"
if [ ! -f "$HAND" ]; then
  printf '%s\n' "$H91_OTKAZ_NET" >&2
  exit 1
fi

# ── Проверка грамматики --date в bash (И-2/Р6: ДО любой записи, Р9) ─────────────────
# Р9/И-9: fullmatch всей строки. Делаем bash-регекспом и case-паттерном; python
# потом повторит строже, но отказ уже на этой ступени — никакого диска.
if ! printf '%s' "$DATE" | grep -Eq -- "$H91_DATE_RE"; then
  printf '%s\n' "$H91_OTKAZ_DATE" >&2
  exit 1
fi
case "$DATE" in
  [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) ;;
  *)
    printf '%s\n' "$H91_OTKAZ_DATE" >&2
    exit 1
    ;;
esac

HAND="$ROOT/HANDOFF.md"

# ── Делегируем работу python3 (И-3/И-4/И-7: байт-в-байт splitlines+склейка) ─────────
# python-скрипт получает:
#   argv[1] = ROOT, argv[2] = HAND, argv[3] = DATE, argv[4] = ARCH_REL,
#   argv[5] = ARCH (абсолютный путь к файлу архива)
#   env H91_* = литеральные константы контракта
#
# Протокол: на stdout — ровно одна строка успеха «архив: …»; на stderr — ровно одна
# строка именованного отказа; rc=0/1. Любой другой rc — NOT_IMPLEMENTED.
#
# Гарантии атомарности (И-6): все отказы — до записи. Запись — в $TMPDIR (НЕ в
# $ROOT), затем mv в $ROOT. Никаких temp-файлов в $ROOT при отказе.
ARCH_REL="$H91_ARCHDIR/$DATE.md"
ARCH_ABS="$ROOT/$ARCH_REL"

H91_SEC_ENV="$H91_SEC" \
H91_H2_ENV="$H91_H2" \
H91_BEGIN_ENV="$H91_BEGIN" \
H91_LIMIT_ENV="$H91_LIMIT" \
H91_ARCHDIR_ENV="$H91_ARCHDIR" \
H91_OTKAZ_NET_ENV="$H91_OTKAZ_NET" \
H91_OTKAZ_DATE_ENV="$H91_OTKAZ_DATE" \
H91_OTKAZ_NOL_ENV="$H91_OTKAZ_NOL" \
H91_OTKAZ_MANY_ENV="$H91_OTKAZ_MANY" \
H91_OTKAZ_BIG_ENV="$H91_OTKAZ_BIG" \
H91_OTKAZ_EXIST_PRE_ENV="$H91_OTKAZ_EXIST_PRE" \
H91_OK_PRE_ENV="$H91_OK_PRE" \
H91_DATE_ENV="$DATE" \
H91_DATE_RE_ENV="$H91_DATE_RE" \
python3 - "$ROOT" "$HAND" "$DATE" "$ARCH_REL" "$ARCH_ABS" <<'PYEOF'
import os
import re
import sys
import tempfile

ROOT = sys.argv[1]
HAND = sys.argv[2]
DATE = sys.argv[3]
ARCH_REL = sys.argv[4]
ARCH_ABS = sys.argv[5]

SEC = os.environ['H91_SEC_ENV'].encode('utf-8')
H2 = os.environ['H91_H2_ENV'].encode('utf-8')
BEGIN = os.environ['H91_BEGIN_ENV'].encode('utf-8')
LIMIT = int(os.environ['H91_LIMIT_ENV'])
ARCHDIR = os.environ['H91_ARCHDIR_ENV']
OTKAZ_NET = os.environ['H91_OTKAZ_NET_ENV']
OTKAZ_DATE = os.environ['H91_OTKAZ_DATE_ENV']
OTKAZ_NOL = os.environ['H91_OTKAZ_NOL_ENV']
OTKAZ_MANY = os.environ['H91_OTKAZ_MANY_ENV']
OTKAZ_BIG = os.environ['H91_OTKAZ_BIG_ENV']
OTKAZ_EXIST_PRE = os.environ['H91_OTKAZ_EXIST_PRE_ENV']
OK_PRE = os.environ['H91_OK_PRE_ENV']
DATE_RE = os.environ['H91_DATE_RE_ENV']

def refuse(msg):
    sys.stderr.write(msg + '\n')
    sys.exit(1)

def not_impl(msg):
    sys.stderr.write('NOT_IMPLEMENTED: ' + msg + '\n')
    sys.exit(2)

# (1) HANDOFF.md существует
if not os.path.isfile(HAND):
    refuse(OTKAZ_NET)

# (2) грамматика --date — полное соответствие всей строки (Р9/И-9)
if re.fullmatch(r'[0-9]{4}-[0-9]{2}-[0-9]{2}', DATE) is None:
    refuse(OTKAZ_DATE)

# Читаем HANDOFF побайтово (без text-нормализации; И-3: «включая отсутствие/
# наличие завершающего LF»).
with open(HAND, 'rb') as f:
    data = f.read()

# Разбиваем на строки, сохраняя LF (splitlines(keepends=True) — стандартная
# семантика: последняя строка с LF если файл его содержит, без — если не
# содержит; клетка k6).
lines = data.splitlines(keepends=True)

# (3) ровно одна секция «## ГДЕ МЫ» (И-2: байтовое начало строки == SEC)
# Сравнение startswith(SEC) ищет литеральный префикс по байтам: `### ГДЕ МЫ`
# и `##  ГДЕ МЫ` (двойной пробел) — НЕ подходят, потому что у них байты до
# позиции 9 — иные. Суффикс после литерала произволен (клетка o12).
starts = [k for k, ln in enumerate(lines) if ln.startswith(SEC)]
if len(starts) == 0:
    refuse(OTKAZ_NOL)
if len(starts) > 1:
    refuse(OTKAZ_MANY)
s = starts[0]

# Граница span (И-3): первая из (а) целой строки BEGIN, (б) строки с префиксом
# H2, (в) EOF. Проверяем целую строку BEGIN как байтовое равенство (т.е. строка
# с финальным \n или без — равна литералу; `### BEGIN …` или `BEGIN …` — НЕ
# граница, клетка o13). Для корректного сравнения: line.rstrip(b'\n') == BEGIN.
end = len(lines)
for k in range(s + 1, len(lines)):
    core = lines[k][:-1] if lines[k].endswith(b'\n') else lines[k]
    if core == BEGIN:
        end = k
        break
    if lines[k].startswith(H2):
        end = k
        break

# Сборка span/prefix/tail байт-в-байт.
span = b''.join(lines[s:end])
prefix = b''.join(lines[:s])
tail = b''.join(lines[end:])
result = prefix + tail

# (4) архив этой даты отсутствует
if os.path.lexists(ARCH_ABS):
    refuse(OTKAZ_EXIST_PRE + ARCH_REL)

# (5) размер итогового ≤ LIMIT (И-5: строго больше → отказ)
if len(result) > LIMIT:
    refuse(OTKAZ_BIG)

# Запись: сначала архив, затем HANDOFF (И-7). Атомарно: tmp-файл В $TMPDIR, не в
# $ROOT, чтобы при отказе (или нашем сбое) в root не оседал .tmp-мусор (стаб s17).
arch_dir = os.path.dirname(ARCH_ABS)
try:
    os.makedirs(arch_dir, exist_ok=True)
except OSError as e:
    not_impl('mkdir: ' + str(e))

fd_arch, tmp_arch = tempfile.mkstemp(prefix='handoff091-arch-', suffix='.tmp')
try:
    with os.fdopen(fd_arch, 'wb') as f:
        f.write(span)
    os.replace(tmp_arch, ARCH_ABS)
except OSError as e:
    try: os.unlink(tmp_arch)
    except OSError: pass
    not_impl('arch write: ' + str(e))

fd_hand, tmp_hand = tempfile.mkstemp(prefix='handoff091-hand-', suffix='.tmp')
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
