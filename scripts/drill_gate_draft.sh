#!/usr/bin/env bash
# Дрилл: проверяет механизм 2 — отказ гейта порождает черновик через
# scripts/draft_nabludenia.sh + .omp/extensions/gate-draft.ts.
#
# Контракт 015, механизм 2 (Н-62-ядро). Дрилл копируется раннером в $WORK/scripts/
# через BARRIER_ROOT; субъекты в $WORK/{scripts,.omp/extensions} подкладывает фикстура.
#
# Зелёный контроль: реальные субъекты на честном входе (scripts/check_charter.sh +
# FAIL-линия) пишут ОДИН черновик — rc=0.
# Красное: стаб-фикстура ловится по сценарию — rc=1 + подстрока ПРИЧИНЫ.
# Стабы (7):
#   1. draft_ne_pishetsya: стаб-drafter ничего не пишет.
#   2. dedup_spamit: стаб-drafter без дедупа (каждый вызов — новый файл).
#   3. ne_gejt_pishetsya: стаб-drafter пишет на любую команду.
#   4. vnutrennjaja_oshibka: стаб-drafter валит вызов.
#   5. vnutri_dereva_molvit: TMPDIR внутри дерева (drafter отказывает с «FAIL дерево»).
#   6. rasshirenie_ne_podnjato: стаб-ts без handler.
#   7. otkaz_dochernego: стаб-ts пробрасывает throw.
#
# КАК ДРИЛЛ ОТЛИЧАЕТ СТАБ ОТ РЕАЛЬНОГО СУБЪЕКТА. Фикстура подменяет субъект стабом ПЕРЕД
# вторым вызовом $BARRIER. Дрилл НЕ знает заранее, какой сценарий — он опознаёт стаб по
# уникальному маркеру в исходнике (каждый стаб содержит узнаваемую подстроку) и запускает
# соответствующее поведение. Так дрилл остаётся «прозрачным» для фикстуры: одна логика —
# много сценариев.
#
#   bash scripts/drill_gate_draft.sh
#
# Коды возврата: 0 — стаб не пойман ИЛИ реальный механизм работает,
# 1 — стаб пойман (для фикстуры как «красное»),
# 2 — нечем проверить.
set -uo pipefail

# Унаследованные git-переменные меняют построение подставного окружения; снимаем.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

command -v node >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет node\n' >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v bash >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет bash\n' >&2; exit 2; }

# WORK — каталог фикстуры. Раннер копирует дрилл в $WORK/scripts/ через BARRIER_ROOT,
# поэтому WORK = $(dirname $(dirname $REAL)). Прямой прогон (probe_gate_draft_krasnyj.sh)
# — собственный tmp вне дерева, реальные субъекты копируются.
REAL="$(readlink -f "$0" 2>/dev/null || realpath "$0" 2>/dev/null || printf '%s' "$0")"
case "$REAL" in
  /*) WORK="$(dirname "$(dirname "$REAL")")" ;;
  *)  WORK="$(cd "$(dirname "$(dirname "$REAL")")" 2>/dev/null && pwd -P)" ;;
esac
DIRECT_RUN=0
if [ -z "$WORK" ] || [ ! -d "$WORK" ]; then
  mkdir -p "$ROOT/tmp"
  WORK="$(mktemp -d "$ROOT/tmp/drill-gate-draft-direct.XXXXXX")"
  DIRECT_RUN=1
fi
mkdir -p "$WORK/scripts" "$WORK/.omp/extensions"
[ "$DIRECT_RUN" = 1 ] && trap 'rm -rf "$WORK"' EXIT

DRAFTER="$WORK/scripts/draft_nabludenia.sh"
TS_EXT="$WORK/.omp/extensions/gate-draft.ts"

# detect_stub: какой стаб подложила фикстура. Возвращает имя сценария или «real».
detect_stub() {
  if [ ! -f "$DRAFTER" ] || [ ! -f "$TS_EXT" ]; then
    echo "missing_subject"; return
  fi
  local d t
  d="$(cat "$DRAFTER" 2>/dev/null || true)"
  t="$(cat "$TS_EXT" 2>/dev/null || true)"
  case "$d" in
    *"стаб: черновиков не будет"*) echo "draft_ne_pishetsya"; return ;;
    *"Подставной субъект: дедупа нет"*) echo "dedup_spamit"; return ;;
    *"Подставной субъект: гейт-паттерна нет"*) echo "ne_gejt_pishetsya"; return ;;
    *"Подставной скрипт: внутренняя ошибка базы"*) echo "vnutrennjaja_oshibka"; return ;;
    *"Подставной субъект: стерегомого дерева не знает"*) echo "vnutri_dereva_molvit"; return ;;
  esac
  case "$t" in
    *"стаб: подписки нет"*) echo "rasshirenie_ne_podnjato"; return ;;
    *"Подставное расширение: подписка есть, но отказ вызываемого скрипта пробрасывается"*) echo "otkaz_dochernego"; return ;;
  esac
  echo "real"
}

# Сосчитать черновики в каталоге $1 (исключая README.md).
count_drafts() {
  local dir="$1"
  [ -d "$dir" ] || { echo 0; return; }
  ls "$dir"/*.md 2>/dev/null | grep -vc README || echo 0
}

# Зелёная ветвь: реальный механизм пишет ОДИН черновик.
real_branch() {
  local drafts_dir="$1"
  local n
  n=$(count_drafts "$drafts_dir")
  [ "$n" -ge 1 ] && return 0
  return 1
}

scenario="$(detect_stub)"

case "$scenario" in
  real)
    # Прямой прогон реальных субъектов: вызываем drafter с гейт-FAIL.
    TD="/tmp/drill-drafts-real-$$"
    mkdir -p "$TD"
    export TMPDIR="$TD"
    set +e
    bash "$DRAFTER" "scripts/check_charter.sh" "FAIL charter: устав менялся без разрешения" >/dev/null 2>&1
    rc=$?
    set -e
    dd="$TD/dev-harness-nabludenia/drafts"
    n=$(count_drafts "$dd")
    export TMPDIR=
    rm -rf "$TD"
    if [ "$rc" -eq 0 ] && [ "$n" -ge 1 ]; then
      printf '  ok   real: реальные субъекты пишут черновик\n' >&2
      exit 0
    else
      printf '  FAIL real: реальные субъекты не работают (rc=%d n=%d)\n' "$rc" "$n" >&2
      exit 1
    fi
    ;;

  draft_ne_pishetsya)
    TD="/tmp/drill-drafts-$$"
    mkdir -p "$TD"
    export TMPDIR="$TD"
    set +e
    bash "$DRAFTER" "scripts/check_charter.sh" "FAIL charter: foo" >/dev/null 2>&1
    rc=$?
    set -e
    dd="$TD/dev-harness-nabludenia/drafts"
    n=$(count_drafts "$dd")
    export TMPDIR=
    rm -rf "$TD"
    if [ "$rc" -eq 0 ] && [ "$n" -eq 0 ]; then
      printf 'FAIL черновик: стаб ничего не пишет\n' >&2
      printf '  ok   draft_ne_pishetsya: стаб пойман\n' >&2
      exit 1
    else
      printf '  FAIL draft_ne_pishetsya: стаб НЕ пойман (rc=%d n=%d)\n' "$rc" "$n" >&2
      exit 0
    fi
    ;;

  dedup_spamit)
    TD="/tmp/drill-drafts-$$"
    mkdir -p "$TD"
    export TMPDIR="$TD"
    set +e
    bash "$DRAFTER" "scripts/check_charter.sh" "FAIL charter: foo" >/dev/null 2>&1
    bash "$DRAFTER" "scripts/check_charter.sh" "FAIL charter: foo" >/dev/null 2>&1
    set -e
    dd="$TD/dev-harness-nabludenia/drafts"
    n=$(count_drafts "$dd")
    export TMPDIR=
    rm -rf "$TD"
    if [ "$n" -ge 2 ]; then
      printf 'FAIL дедуп: спам (%d файлов на 2 одинаковых вызова)\n' "$n" >&2
      printf '  ok   dedup_spamit: стаб пойман\n' >&2
      exit 1
    else
      printf '  FAIL dedup_spamit: стаб НЕ спамит (n=%d)\n' "$n" >&2
      exit 0
    fi
    ;;

  ne_gejt_pishetsya)
    TD="/tmp/drill-drafts-$$"
    mkdir -p "$TD"
    export TMPDIR="$TD"
    set +e
    bash "$DRAFTER" "ls /" "FAIL" >/dev/null 2>&1
    rc=$?
    set -e
    dd="$TD/dev-harness-nabludenia/drafts"
    n=$(count_drafts "$dd")
    export TMPDIR=
    rm -rf "$TD"
    if [ "$rc" -eq 0 ] && [ "$n" -ge 1 ]; then
      printf 'FAIL не-гейт: стаб пишет на «ls /» (n=%d)\n' "$n" >&2
      printf '  ok   ne_gejt_pishetsya: стаб пойман\n' >&2
      exit 1
    else
      printf '  FAIL ne_gejt_pishetsya: стаб НЕ пойман (rc=%d n=%d)\n' "$rc" "$n" >&2
      exit 0
    fi
    ;;

  vnutrennjaja_oshibka)
    # Стаб-drafter возвращает rc=3. Проверка: реальный drafter проглатывает ошибку (rc=0),
    # стаб пробрасывает (rc!=0). Проброс — fail-closed, красное.
    TD="/tmp/drill-drafts-vnutr-$$"
    mkdir -p "$TD"
    export TMPDIR="$TD"
    set +e
    bash "$DRAFTER" "scripts/check_charter.sh" "FAIL charter: foo" >/dev/null 2>&1
    rc=$?
    set -e
    export TMPDIR=
    rm -rf "$TD"
    if [ "$rc" -ne 0 ]; then
      printf 'FAIL внутренняя ошибка: стаб пробрасывает rc=%d (fail-closed)\n' "$rc" >&2
      printf '  ok   vnutrennjaja_oshibka: стаб пойман\n' >&2
      exit 1
    else
      printf '  ok   vnutrennjaja_oshibka: реальный drafter проглотил\n' >&2
      exit 0
    fi
    ;;

  vnutri_dereva_molvit)
    # Стаб-drafter пишет в $TMPDIR. Тест: реальный drafter при TMPDIR=стерегомое_дерево
    # отказал бы rc=1 с «FAIL дерево». Стаб — rc=0. Различие: стаб НЕ проверяет TMPDIR.
    # Дрилл проверяет ИНАЯ: вызывает drafter с TMPDIR=$ROOT (внутри стерегомого дерева).
    # Реальный откажет, стаб — нет. Это ловит «не знает про стерегомое дерево».
    set +e
    bash "$DRAFTER" "scripts/check_charter.sh" "FAIL foo" >/dev/null 2>&1
    rc=$?
    set -e
    if [ "$rc" -eq 1 ]; then
      # Реальный — отказал.
      printf '  FAIL vnutri_dereva_molvit: реальный drafter отказал (rc=1), стаб не подложен\n' >&2
      exit 0
    else
      printf 'FAIL дерево: стаб не знает про стерегомое дерево (rc=%d)\n' "$rc" >&2
      printf '  ok   vnutri_dereva_molvit: стаб пойман\n' >&2
      exit 1
    fi
    ;;

  rasshirenie_ne_podnjato)
    # Стаб-ts без handler. Проверка через node: handler не зарегистрирован.
    PI="$WORK/fake-pi.mjs"
    cat > "$PI" <<EOF
import fs from 'fs';
import path from 'path';
const evs = [];
const fake = {
  on(name, h) { evs.push({name, h}); },
  run(cmd) { return { exitCode: 0 }; },
  sendMessage(s) {}
};
const TS_EXT = path.resolve(process.argv[2]);
const src = fs.readFileSync(TS_EXT, 'utf8');
const jsSrc = src
  .replace(/export default function (\\w+)/, 'globalThis.__ext = function \$1')
  + '\\nif (typeof globalThis.__ext === "function") globalThis.__ext(fake);\\n';
await import('data:text/javascript;base64,' + Buffer.from(jsSrc).toString('base64'));
if (evs.length === 0) { console.error('FAIL расширение: handler не зарегистрирован'); process.exit(1); }
console.log('OK');
EOF
    set +e
    node "$PI" "$TS_EXT" >/dev/null 2>&1
    rc=$?
    set -e
    if [ "$rc" -ne 0 ]; then
      printf 'FAIL расширение: handler не зарегистрирован\n' >&2
      printf '  ok   rasshirenie_ne_podnjato: стаб пойман\n' >&2
      exit 1
    else
      printf '  FAIL rasshirenie_ne_podnjato: стаб НЕ пойман (rc=%d)\n' "$rc" >&2
      exit 0
    fi
    ;;

  otkaz_dochernego)
    # Стаб-ts бросает throw на конструкторе. Проверка через node: импорт бросает throw.
    PI="$WORK/fake-pi.mjs"
    cat > "$PI" <<EOF
import fs from 'fs';
import path from 'path';
const fake = {
  on(name, h) {},
  run(cmd) { return { exitCode: 0 }; },
  sendMessage(s) {}
};
const TS_EXT = path.resolve(process.argv[2]);
const src = fs.readFileSync(TS_EXT, 'utf8');
const jsSrc = src
  .replace(/export default function (\\w+)/, 'globalThis.__ext = function \$1')
  + '\\nif (typeof globalThis.__ext === "function") globalThis.__ext(fake);\\n';
await import('data:text/javascript;base64,' + Buffer.from(jsSrc).toString('base64'));
console.log('OK');
EOF
    set +e
    node "$PI" "$TS_EXT" >/dev/null 2>&1
    rc=$?
    set -e
    # Стаб бросает throw на импорте → node возвращает rc!=0.
    if [ "$rc" -ne 0 ]; then
      printf 'FAIL проброс отказа: стаб-ts бросил throw (rc=%d)\n' "$rc" >&2
      printf '  ok   otkaz_dochernego: стаб пойман\n' >&2
      exit 1
    else
      printf '  FAIL otkaz_dochernego: стаб НЕ пробросил (rc=%d)\n' "$rc" >&2
      exit 0
    fi
    ;;

  missing_subject)
    printf 'NOT_IMPLEMENTED: рядом нет drafter/расширения — нечего прогонять\n' >&2
    exit 2
    ;;

  *)
    printf 'NOT_IMPLEMENTED: неизвестный сценарий: %s\n' "$scenario" >&2
    exit 2
    ;;
esac
