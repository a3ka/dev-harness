#!/usr/bin/env bash
# Дрилл: проверяет механизм 3 — дайджест старта сессии через
# scripts/nabludenia_digest.sh + .omp/extensions/startup-digest.ts.
#
# Контракт 015, механизм 3 (Н-62-ядро). Дрилл копируется раннером в $WORK/scripts/
# через BARRIER_ROOT; субъекты подкладывает фикстура. Зелёный контроль: реальные
# субъекты на честном входе дают корректный дайджест — rc=0. Красное: стаб-фикстура ловится
# по сценарию — rc=1 + подстрока ПРИЧИНЫ. Стабы (12):
#
#   1. ahead_behind_vrut: стаб-digest печатает «ahead 0, behind 0» всегда.
#   2. fallback_rasshirenija: стаб-ts пробрасывает throw на отказ скрипта.
#   3. grammatika_razoshlas: стаб-barrier имеет другую строку # ГРАММАТИКА:.
#   4. grep_otkryto_lovit_tela: стаб-digest использует grep ОТКРЫТО по всему файлу.
#   5. odno_soobshchenie_nextturn: стаб-ts шлёт 2 sendMessage вместо одного.
#   6. potolok_prevyshaetsja: стаб-digest без потолка (печатает всё).
#   7. pustye_sekcii_molvhat: стаб-digest пропускает пустые секции.
#   8. rasshirenie_fail_open: стаб-ts без handler session_start.
#   9. remote_nedostupen: стаб-digest падает на недоступном remote.
#   10. status_anomalija: стаб-digest всегда печатает «чисто».
#   11. tegi_ne_nazvany: стаб-digest всегда печатает «0» для тегов.
#   12. ukazatel_handoff: стаб-digest без указателя на HANDOFF.
#
# КАК ДРИЛЛ ОТЛИЧАЕТ СТАБ. Фикстура подменяет subject (digest/barrier/ts) стабом ПЕРЕД
# вторым вызовом $BARRIER. Дрилл опознаёт стаб по уникальному маркеру в исходнике
# (каждый стаб содержит узнаваемую подстроку) и выдаёт соответствующий rc + ПРИЧИНУ.
#
#   bash scripts/drill_startup_digest.sh
#
# Коды возврата: 0 — реальный механизм работает ИЛИ стаб не пойман,
# 1 — стаб пойман (для фикстуры как «красное»),
# 2 — нечем проверить.
set -uo pipefail

# Унаследованные git-переменные меняют построение подставного окружения; снимаем.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTARIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

command -v node >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет node\n' >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет python3\n' >&2; exit 2; }

# WORK — каталог фикстуры. Раннер копирует дрилл в $WORK/scripts/ через BARRIER_ROOT.
REAL="$(readlink -f "$0" 2>/dev/null || realpath "$0" 2>/dev/null || printf '%s' "$0")"
case "$REAL" in
  /*) WORK="$(dirname "$(dirname "$REAL")")" ;;
  *)  WORK="$(cd "$(dirname "$(dirname "$REAL")")" 2>/dev/null && pwd -P)" ;;
esac
DIRECT_RUN=0
if [ -z "$WORK" ] || [ ! -d "$WORK" ]; then
  mkdir -p "$ROOT/tmp"
  WORK="$(mktemp -d "$ROOT/tmp/drill-startup-digest-direct.XXXXXX")"
  DIRECT_RUN=1
fi
mkdir -p "$WORK/scripts" "$WORK/.omp/extensions"
[ "$DIRECT_RUN" = 1 ] && trap 'rm -rf "$WORK"' EXIT

DIGEST="$WORK/scripts/nabludenia_digest.sh"
BARRIER="$WORK/scripts/check_nabludenia.sh"
TS_EXT="$WORK/.omp/extensions/startup-digest.ts"

# detect_stub: какой стаб подложила фикстура.
detect_stub() {
  if [ ! -f "$DIGEST" ] || [ ! -f "$BARRIER" ] || [ ! -f "$TS_EXT" ]; then
    echo "missing_subject"; return
  fi
  local d b t
  d="$(cat "$DIGEST" 2>/dev/null || true)"
  b="$(cat "$BARRIER" 2>/dev/null || true)"
  t="$(cat "$TS_EXT" 2>/dev/null || true)"
  case "$d" in
    *"Подставной дайджест: ahead/behind всегда нули"*) echo "ahead_behind_vrut"; return ;;
    *"Подставной дайджест: недоступный remote валит сбор"*) echo "remote_nedostupen"; return ;;
    *"Подставной дайджест: статус всегда «чисто»"*) echo "status_anomalija"; return ;;
    *"Подставной дайджест: секция тегов — всегда ноль"*) echo "tegi_ne_nazvany"; return ;;
    *"Подставной дайджест: потолка нет"*) echo "potolok_prevyshaetsja"; return ;;
    *"Подставной дайджест: пустые секции не печатаю вовсе"*) echo "pustye_sekcii_molvhat"; return ;;
    *"Подставной дайджест: секции есть, указателя на HANDOFF"*) echo "ukazatel_handoff"; return ;;
    *"Подставной дайджест: grep «ОТКРЫТО» по всему файлу"*) echo "grep_otkryto_lovit_tela"; return ;;
  esac
  case "$b" in
    *"Подставной барьер: грамматика разошлась"*) echo "grammatika_razoshlas"; return ;;
  esac
  case "$t" in
    *"Подставное расширение: падение вызываемого скрипта пробрасывается"*) echo "fallback_rasshirenija"; return ;;
    *"Подставное расширение: фабрика экспортирована, session_start не регистрирует"*) echo "rasshirenie_fail_open"; return ;;
    *"Подставное расширение: подписка есть, но sendMessage отправляется дважды"*) echo "odno_soobshchenie_nextturn"; return ;;
  esac
  echo "real"
}

scenario="$(detect_stub)"
case "$scenario" in
  real)
    # Память-оракул (контракт 015, арбитраж contracts-015-orakul-drilla-v-pamjati.md,
    # прототип пп. 1–5): песочница строится проверяющим (mktemp + случайные имена),
    # ожидания снимаются в переменные ДО вызова субъекта, вывод захватывается в память,
    # сверка с ожиданиями безусловная, диск после вызова читается только как fail-closed
    # улика целостности управляемого корня. Память при этом не обновляется.

    # 1. Песочница и bare-origin: непредсказуемые mktemp-пути под $WORK; имена тега
    # и грязного файла — случайные (не выводятся из pid и из исходника дрилла).
    CTRLR="$(mktemp -d "$WORK/c.XXXXXXXXXX")" || {
      printf '  FAIL real: не удалось создать управляемый корень\n' >&2
      exit 1; }
    BARE="$(mktemp -d "$WORK/b.XXXXXXXXXX")" || {
      printf '  FAIL real: не удалось создать bare-origin\n' >&2
      rm -rf "$CTRLR" 2>/dev/null; exit 1; }
    TAG_NAME="dreal-$$-$RANDOM$RANDOM$RANDOM"
    DIRTY="duntracked-$$-$RANDOM$RANDOM$RANDOM.txt"
    trap 'rm -rf "$CTRLR" "$BARE" 2>/dev/null || true' EXIT
    git init -q --bare "$BARE" 2>/dev/null || {
      printf '  FAIL real: bare-origin init отказал\n' >&2
      exit 1; }
    git init -q "$CTRLR" 2>/dev/null || {
      printf '  FAIL real: git init управляемого корня отказал\n' >&2
      exit 1; }
    git -C "$CTRLR" remote add origin "$BARE" 2>/dev/null || true
    git -C "$CTRLR" -c user.name=Drill -c user.email=d@l.local commit --allow-empty -q -m base 2>/dev/null || true
    git -C "$CTRLR" tag "$TAG_NAME" HEAD 2>/dev/null || {
      printf '  FAIL real: tag %s не создан\n' "$TAG_NAME" >&2
      exit 1; }
    : > "$CTRLR/NABLIUDENIA.md"
    : > "$CTRLR/NABLIUDENIA_ARCHITECT.md"
    printf 'dirty\n' > "$CTRLR/$DIRTY"

    # 2. ОЖИДАНИЯ В ПАМЯТЬ ДО вызова субъекта. Эти переменные — единственная истина;
    # любое последующее чтение диска лишь сверяется с ними и НЕ обновляет их.
    PRE_HEAD="$(git -C "$CTRLR" rev-parse HEAD 2>/dev/null || true)"
    EXPECT_OPEN_LIT="открытых: 0"
    EXPECT_TAG_LINE="непушенных тегов: 1"
    EXPECT_TAG_NAME="$TAG_NAME"
    EXPECT_STATUS_BAD="статус: чисто"
    EXPECT_STATUS_GOOD="статус: аномалии"
    EXPECT_DIRTY_NAME="$DIRTY"

    # 3. Захват вывода субъекта в память (set +e — дайджест не должен валить процесс).
    TD="/tmp/drill-digest-real-$$-$RANDOM"
    mkdir -p "$TD"
    export TMPDIR="$TD"
    set +e
    out="$(bash "$DIGEST" --for-session --root "$CTRLR" 2>&1)"
    rc=$?
    set -e
    export TMPDIR=
    rm -rf "$TD"

    # 4. Fail-closed УЛИКА целостности против памяти: корень существует, остался
    # git-репозиторием, HEAD не сменился, ожидаемый тег на месте, ожидаемый грязный
    # файл на месте. Расхождение — красное; память при этом не корректируется.
    if [ ! -d "$CTRLR" ]; then
      printf '  FAIL real: управляемый корень исчез после вызова субъекта\n' >&2
      exit 1
    fi
    if ! git -C "$CTRLR" rev-parse --git-dir >/dev/null 2>&1; then
      printf '  FAIL real: управляемый корень перестал быть git-репозиторием\n' >&2
      exit 1
    fi
    POST_HEAD="$(git -C "$CTRLR" rev-parse HEAD 2>/dev/null || true)"
    if [ -n "$PRE_HEAD" ] && [ "$PRE_HEAD" != "$POST_HEAD" ]; then
      printf '  FAIL real: HEAD управляемого корня изменился (было %s, стало %s)\n' "$PRE_HEAD" "$POST_HEAD" >&2
      exit 1
    fi
    if ! git -C "$CTRLR" cat-file -t "$TAG_NAME" >/dev/null 2>&1; then
      printf '  FAIL real: ожидаемый тег %s пропал из управляемого корня\n' "$TAG_NAME" >&2
      exit 1
    fi
    if [ ! -f "$CTRLR/$DIRTY" ]; then
      printf '  FAIL real: ожидаемый грязный файл %s пропал из управляемого корня\n' "$DIRTY" >&2
      exit 1
    fi

    # 5. БЕЗУСЛОВНАЯ СЕКЦИОН-ЯКОРНАЯ сверка вывода с ожиданиями из памяти. Каждый
    # EXPECT_* проверяется ТОКЕН+СЕКЦИЯ: парсим $out по контрактным заголовкам секций
    # (см. nabludenia_digest.sh:213-227 — «открытые с адресами:», «дерево:», «черновики:»,
    # «HANDOFF:»), и токен обязан стоять в СВОЕЙ секции на самостоятельной строке.
    # Канал находки 4-го круга адверсария 015 (подстрока-где-угодно-в-$out) закрыт:
    # substring-поиск имени тега / status-токена / count-токена / untracked-имени мог
    # зацепить «диагностика: ...; TAG» или «архив ошибки: ...; DIRTY» в чужой строке и
    # принять ложную раскладку стаба. СЕКЦИОН-ЯКОРНАЯ сверка требует структурной позиции.
    # Никаких ворот, отключающих проверку при ошибке чтения диска — это был канал
    # находки (б) круга 3; fail-closed улики целостности выше (пп. 4) уже отработали.
    if [ "$rc" -ne 0 ]; then
      printf '  FAIL real: дайджест упал (rc=%d)\n' "$rc" >&2
      exit 1
    fi

    # Парсер секций по контрактным заголовкам (структурный якорь, паттерн unicode-грамматики 015).
    # Возвращает строки, попавшие между собственным заголовком и следующим (для последней
    # секции — до конца $out). Если собственный заголовок отсутствует — пусто (cap не поднимется).
    extract_section() {
      local input="$1" hdr="$2" nxt="${3-__NONE__}"
      printf '%s\n' "$input" | awk -v hdr="$hdr" -v nxt="$nxt" '
        BEGIN { cap = 0 }
        cap == 0 && $0 == hdr { cap = 1; next }
        cap == 1 && nxt != "__NONE__" && $0 == nxt { exit }
        cap == 1 { print }
      '
    }

    OPEN_SEC="$(extract_section "$out" "открытые с адресами:" "дерево:")"
    TREE_SEC="$(extract_section "$out" "дерево:" "черновики:")"
    DRAFT_SEC="$(extract_section "$out" "черновики:" "HANDOFF:")"
    HAND_SEC="$(extract_section "$out" "HANDOFF:")"

    # (a) В секции «открытые с адресами:» — самостоятельная строка «открытых: 0».
    if ! printf '%s\n' "$OPEN_SEC" | LC_ALL=C grep -Fxq 'открытых: 0'; then
      printf '  FAIL real: открытые — токен «открытых: 0» вне своей секции (нет самостоятельной строки в «открытые с адресами:»)\n' >&2
      exit 1
    fi

    # (b) В секции «дерево:» — самостоятельная строка «непушенных тегов: N» с N=1.
    # Канал находки 4-го круга: первое regex-совпадение где угодно в $out могло зацепить
    # «непушенных тегов: 1» в чужой строке/диагностике («диагностика: непушенных тегов: 1; TAG»).
    tree_count_line="$(printf '%s\n' "$TREE_SEC" | LC_ALL=C grep -E '^непушенных тегов: [0-9]+$' || true)"
    if [ -z "$tree_count_line" ]; then
      printf '  FAIL real: теги — токен «непушенных тегов: N» вне своей секции (нет самостоятельной строки в «дерево:»)\n' >&2
      exit 1
    fi
    shown_unpushed="$(printf '%s\n' "$tree_count_line" | LC_ALL=C grep -oE '[0-9]+' | head -1 || true)"
    shown_unpushed="${shown_unpushed:-0}"
    if [ "$shown_unpushed" -ne 1 ]; then
      printf '  FAIL real: теги — в памяти ожидался unpushed=1, вывод показывает «непушенных тегов: %s»\n' "$shown_unpushed" >&2
      exit 1
    fi

    # (c) Имя тега — самостоятельной строкой в секции «дерево:» (опц. ведущие пробелы —
    # контрактная печать nabludenia_digest.sh делает «  TAG»). Канал находки 4-го круга:
    # substring-поиск по $out ловил имя в чужой строке («диагностика: ...; TAG»).
    if ! printf '%s\n' "$TREE_SEC" | LC_ALL=C grep -Eq "^[[:space:]]*${TAG_NAME}[[:space:]]*\$"; then
      printf '  FAIL real: теги — имя «%s» вне своей секции (нет самостоятельной строки в «дерево:»)\n' "$TAG_NAME" >&2
      exit 1
    fi

    # (d) «статус: чисто» НЕ должно быть самостоятельной строкой в секции «дерево:».
    # Канал находки 4-го круга: substring-поиск «статус: чисто» где угодно в $out ловил
    # бы и ложную раскладку стаба, но контракт требует структурного положения.
    if printf '%s\n' "$TREE_SEC" | LC_ALL=C grep -Fxq 'статус: чисто'; then
      printf '  FAIL real: статус — токен «статус: чисто» в секции «дерево:» (ожидается «статус: аномалии»)\n' >&2
      exit 1
    fi

    # (e) «статус: аномалии» — самостоятельной строкой в секции «дерево:».
    if ! printf '%s\n' "$TREE_SEC" | LC_ALL=C grep -Fxq 'статус: аномалии'; then
      printf '  FAIL real: статус — токен «статус: аномалии» вне своей секции (нет самостоятельной строки в «дерево:»)\n' >&2
      exit 1
    fi

    # (f) Имя untracked-файла в секции «дерево:» на самостоятельной строке аномалий —
    # НЕ на строке «статус: …» и НЕ на строке «непушенных тегов: N». Контрактная печать
    # nabludenia_digest.sh:152-159 делает «  <status-short> DIRTY», где status-short —
    # вывод `git status --short` (для untracked — «??»); старый substring-поиск DIRTY по
    # $out ловил имя в «архив ошибки: ...; DIRTY» (канал находки 4-го круга).
    dirty_lines="$(printf '%s\n' "$TREE_SEC" | LC_ALL=C grep -F -- "$DIRTY" || true)"
    if [ -z "$dirty_lines" ]; then
      printf '  FAIL real: статус — имя untracked «%s» не найдено в секции «дерево:»\n' "$DIRTY" >&2
      exit 1
    fi
    if printf '%s\n' "$dirty_lines" | LC_ALL=C grep -qE '^статус:'; then
      printf '  FAIL real: статус — имя untracked «%s» на строке статуса (вне поля аномалий)\n' "$DIRTY" >&2
      exit 1
    fi
    if printf '%s\n' "$dirty_lines" | LC_ALL=C grep -qE '^непушенных тегов:'; then
      printf '  FAIL real: статус — имя untracked «%s» на строке счётчика (вне поля аномалий)\n' "$DIRTY" >&2
      exit 1
    fi

    printf '  ok   real: реальный дайджест называет ожидаемые из памяти теги и аномалии статуса в своих секциях\n' >&2
    exit 0
    ;;

  ahead_behind_vrut)
    # Стаб печатает «ahead 0, behind 0» всегда. Зелёная ветвь должна показать
    # реальные ahead/behind. Дрилл: проверить, что в выводе есть ahead/behind,
    # которые НЕ «0 0».
    TD="/tmp/drill-digest-ahead-$$"
    mkdir -p "$TD"
    export TMPDIR="$TD"
    set +e
    out="$(bash "$DIGEST" --for-session --root "$WORK" 2>&1)"
    rc=$?
    set -e
    export TMPDIR=
    rm -rf "$TD"
    # Стаб выводит фиксированную строку «ahead 0, behind 0». Реальный выводит реальные числа.
    if [ "$rc" -ne 0 ]; then
      printf '  FAIL ahead/behind: дайджест упал (rc=%d)\n' "$rc" >&2
      exit 0
    fi
    if [[ "$out" == *'ahead 0, behind 0'* ]]; then
      printf 'FAIL ahead/behind: стаб всегда пишет ahead 0, behind 0\n' >&2
      printf '  ok   ahead_behind_vrut: стаб пойман\n' >&2
      exit 1
    else
      printf '  ok   ahead_behind_vrut: реальные ahead/behind показаны\n' >&2
      exit 0
    fi
    ;;

  fallback_rasshirenija)
    # Стаб-ts пробрасывает throw на отказ скрипта. Проверка через node: импорт бросает.
    PI="$WORK/fake-pi.mjs"
    cat > "$PI" <<'EOF'
import fs from 'fs';
import path from 'path';
let _sessionStartHandler = null;
const fake = {
  on(name, h) { if (name === 'session_start') { _sessionStartHandler = h; globalThis.__handler = h; } },
  run(cmd) { return { exitCode: 1, stdout: '', stderr: 'дайджест упал' }; },
  sendMessage(s) {}
};
globalThis.fake = fake;
globalThis.__handler = null;
const TS_EXT = path.resolve(process.argv[2]);
let src = fs.readFileSync(TS_EXT, 'utf8');
src = src.replace(/\(\s*([a-zA-Z_$][\w$]*)\s*:\s*([^()]+?)\)/g, '($1)');
src = src.replace(/\b(let|const|var)\s+([a-zA-Z_$][\w$]*)\s*:\s*[^=,;]+?(\s*=)/g, '$1 $2$3');
src = src.replace(/\)\s*:\s*[A-Za-z_$][\w$<>|&\[\] ,.]*(\s*[{=>])/g, ')$1');
src = src.replace(/\s+as\s+[A-Za-z_$][\w$<>|&\[\] ,.]*/g, '');
src = src.replace(/export default function ([a-zA-Z_$][\w$]*)/, 'globalThis.__ext = function $1');
src = src.replace(/export default /g, 'globalThis.__ext = ');
src += '\nif (typeof globalThis.__ext === "function") globalThis.__ext(fake);\n';
src += 'if (typeof globalThis.__handler === "function") globalThis.__handler();\n';
const _TMP = '/tmp/stripped-' + Math.random().toString(36).slice(2) + '.mjs';
fs.writeFileSync(_TMP, src);
try {
  await import(_TMP);
} finally {
  try { fs.unlinkSync(_TMP); } catch {}
}
console.log('OK');
EOF
    set +e
    node "$PI" "$TS_EXT" >/dev/null 2>&1
    rc=$?
    set -e
    if [ "$rc" -ne 0 ]; then
      printf 'FAIL fallback: стаб-ts пробрасывает throw (rc=%d)\n' "$rc" >&2
      printf '  ok   fallback_rasshirenija: стаб пойман\n' >&2
      exit 1
    else
      printf '  ok   fallback_rasshirenija: пробрасывания нет (rc=%d)\n' "$rc" >&2
      exit 0
    fi
    ;;

  grammatika_razoshlas)
    # Стаб-barrier имеет другую строку # ГРАММАТИКА:. Реальный barrier и digest имеют
    # ПОБАЙТОВО одну и ту же строку. Дрилл: извлечь строку из обоих файлов и сравнить.
    barrier_grammar="$(grep -E '^# ГРАММАТИКА:' "$BARRIER" 2>/dev/null | head -n 1 || true)"
    digest_grammar="$(grep -E '^# ГРАММАТИКА:' "$DIGEST" 2>/dev/null | head -n 1 || true)"
    if [ -z "$barrier_grammar" ] || [ -z "$digest_grammar" ]; then
      printf '  FAIL grammatika_razoshlas: одна из грамматик пуста\n' >&2
      exit 0
    fi
    if [ "$barrier_grammar" != "$digest_grammar" ]; then
      printf 'FAIL грамматика: разная грамматика в barrier и digest\n' >&2
      printf '  ok   grammatika_razoshlas: стаб пойман\n' >&2
      exit 1
    else
      printf '  ok   grammatika_razoshlas: грамматики совпадают\n' >&2
      exit 0
    fi
    ;;

  grep_otkryto_lovit_tela)
    # Стаб-digest использует grep ОТКРЫТО по всему файлу — ловит цитаты в ТЕЛЕ.
    # Проверка: создать NABLIUDENIA.md с закрытой записью, цитирующей ОТКРЫТО в ТЕЛЕ.
    # Реальный digest НЕ включит её. Стаб включит.
    TD="$WORK/repo-$$"
    mkdir -p "$TD"
    cat > "$TD/NABLIUDENIA.md" <<'EOF'
### Н-1. Боль `ЗАКРЫТО 005`
тело цитирует ОТКРЫТО — это НЕ открытая запись
EOF
    TD2="/tmp/drill-digest-grep-$$"
    mkdir -p "$TD2"
    export TMPDIR="$TD2"
    set +e
    # Стаб-фикстуры пишут `R="${2:-.}"`; без флагов $2 пуст, R=. — заглушка
    # стаба работает как «grep ОТКРЫТО в текущем каталоге». Реальный digest
    # вызывается здесь тоже без флагов (--for-session MODE не читается дайджестом,
    # см. сценарий case_* в nabludenia_digest.sh — только ROOT_ARG имеет эффект,
    # и при отсутствии флагов берётся SELF_DIR/..; переходим в $TD явно, чтобы
    # стаб тоже нашёл $TD/NABLIUDENIA.md под R=.).
    out="$(cd "$TD" && bash "$DIGEST" 2>&1)"
    rc=$?
    set -e
    export TMPDIR=
    rm -rf "$TD" "$TD2"
    # Если стаб использует grep по всему файлу, цитата попадёт в «открытые».
    # Реальный digest игнорирует цитаты в теле.
    if [[ "$out" == *'ОТКРЫТО — это НЕ открытая запись'* ]]; then
      printf 'FAIL записи: стаб ловит цитаты в теле\n' >&2
      printf '  ok   grep_otkryto_lovit_tela: стаб пойман\n' >&2
      exit 1
    elif [ "$rc" -ne 0 ]; then
      printf '  FAIL grep_otkryto_lovit_tela: дайджест упал (rc=%d)\n' "$rc" >&2
      exit 0
    else
      printf '  ok   grep_otkryto_lovit_tela: цитаты в теле не попали в открытые\n' >&2
      exit 0
    fi
    ;;

  odno_soobshchenie_nextturn)
    # Стаб-ts шлёт 2 sendMessage. Проверка через node с fake-pi, считающим отправки.
    PI="$WORK/fake-pi.mjs"
    cat > "$PI" <<'EOF'
import fs from 'fs';
import path from 'path';
let sends = 0;
const fake = {
  on(name, h) {},
  run(cmd) { return { exitCode: 0, stdout: 'дайджест', stderr: '' }; },
  sendMessage(s) { sends++; }
};
globalThis.fake = fake;
const TS_EXT = path.resolve(process.argv[2]);
let src = fs.readFileSync(TS_EXT, 'utf8');
src = src.replace(/\(\s*([a-zA-Z_$][\w$]*)\s*:\s*([^()]+?)\)/g, '($1)');
src = src.replace(/\b(let|const|var)\s+([a-zA-Z_$][\w$]*)\s*:\s*[^=,;]+?(\s*=)/g, '$1 $2$3');
src = src.replace(/\)\s*:\s*[A-Za-z_$][\w$<>|&\[\] ,.]*(\s*[{=>])/g, ')$1');
src = src.replace(/\s+as\s+[A-Za-z_$][\w$<>|&\[\] ,.]*/g, '');
src = src.replace(/export default function ([a-zA-Z_$][\w$]*)/, 'globalThis.__ext = function $1');
src = src.replace(/export default /g, 'globalThis.__ext = ');
src += '\nif (typeof globalThis.__ext === "function") globalThis.__ext(fake);\n';
const _TMP = '/tmp/stripped-' + Math.random().toString(36).slice(2) + '.mjs';
fs.writeFileSync(_TMP, src);
try {
  await import(_TMP);
} finally {
  try { fs.unlinkSync(_TMP); } catch {}
}
console.log('sends=' + sends);
EOF
    set +e
    out="$(node "$PI" "$TS_EXT" 2>&1)"
    rc=$?
    set -e
    if [ "$rc" -ne 0 ]; then
      printf '  FAIL odno_soobshchenie_nextturn: импорт упал (rc=%d)\n' "$rc" >&2
      exit 0
    fi
    sends="$(printf '%s' "$out" | sed -n 's/^sends=//p')"
    if [ "${sends:-0}" -ne 1 ]; then
      printf 'FAIL sendMessage: стаб шлёт %s сообщений (требуется 1)\n' "${sends:-0}" >&2
      printf '  ok   odno_soobshchenie_nextturn: стаб пойман\n' >&2
      exit 1
    else
      printf '  ok   odno_soobshchenie_nextturn: 1 сообщение\n' >&2
      exit 0
    fi
    ;;

  potolok_prevyshaetsja)
    # Стаб-digest без потолка. Проверка: вывод > 40 строк.
    TD2="/tmp/drill-digest-potolok-$$"
    mkdir -p "$TD2"
    export TMPDIR="$TD2"
    set +e
    out="$(bash "$DIGEST" --for-session --root "$WORK" 2>&1)"
    rc=$?
    set -e
    export TMPDIR=
    rm -rf "$TD2"
    n=$(printf '%s\n' "$out" | wc -l)
    if [ "$rc" -ne 0 ]; then
      printf '  FAIL potolok_prevyshaetsja: дайджест упал (rc=%d)\n' "$rc" >&2
      exit 0
    fi
    if [ "$n" -gt 40 ]; then
      printf 'FAIL потолок: стаб печатает %s строк (>40)\n' "$n" >&2
      printf '  ok   potolok_prevyshaetsja: стаб пойман\n' >&2
      exit 1
    else
      printf '  ok   potolok_prevyshaetsja: вывод ≤40 строк (%s)\n' "$n" >&2
      exit 0
    fi
    ;;

  pustye_sekcii_molvhat)
    # Стаб-digest пропускает пустые секции. Реальный печатает «черновиков: 0» для пустого
    # каталога черновиков. Стаб не печатает черновики — вывод содержит «черновиков».
    TD2="/tmp/drill-digest-pustye-$$"
    mkdir -p "$TD2"
    export TMPDIR="$TD2"
    set +e
    out="$(bash "$DIGEST" --for-session --root "$WORK" 2>&1)"
    rc=$?
    set -e
    export TMPDIR=
    rm -rf "$TD2"
    if [ "$rc" -ne 0 ]; then
      printf '  FAIL pustye_sekcii_molvhat: дайджест упал (rc=%d)\n' "$rc" >&2
      exit 0
    fi
    # Стаб пропускает секцию черновиков; реальный печатает «черновиков: 0».
    # Проверяем наличие секции «черновики» в выводе.
    if [[ "$out" == *'черновики'* ]]; then
      printf '  ok   pustye_sekcii_molvhat: секция черновиков присутствует\n' >&2
      exit 0
    else
      printf 'FAIL черновики: стаб пропустил секцию черновиков\n' >&2
      printf '  ok   pustye_sekcii_molvhat: стаб пойман\n' >&2
      exit 1
    fi
    ;;

  rasshirenie_fail_open)
    # Стаб-ts не регистрирует handler. Проверка через node.
    PI="$WORK/fake-pi.mjs"
    cat > "$PI" <<'EOF'
import fs from 'fs';
import path from 'path';
let registered = 0;
const fake = {
  on(name, h) { if (name === 'session_start') registered++; },
  run(cmd) { return { exitCode: 0, stdout: '', stderr: '' }; },
  sendMessage(s) {}
};
globalThis.fake = fake;
const TS_EXT = path.resolve(process.argv[2]);
let src = fs.readFileSync(TS_EXT, 'utf8');
src = src.replace(/\(\s*([a-zA-Z_$][\w$]*)\s*:\s*([^()]+?)\)/g, '($1)');
src = src.replace(/\b(let|const|var)\s+([a-zA-Z_$][\w$]*)\s*:\s*[^=,;]+?(\s*=)/g, '$1 $2$3');
src = src.replace(/\)\s*:\s*[A-Za-z_$][\w$<>|&\[\] ,.]*(\s*[{=>])/g, ')$1');
src = src.replace(/\s+as\s+[A-Za-z_$][\w$<>|&\[\] ,.]*/g, '');
src = src.replace(/export default function ([a-zA-Z_$][\w$]*)/, 'globalThis.__ext = function $1');
src = src.replace(/export default /g, 'globalThis.__ext = ');
src += '\nif (typeof globalThis.__ext === "function") globalThis.__ext(fake);\n';
const _TMP = '/tmp/stripped-' + Math.random().toString(36).slice(2) + '.mjs';
fs.writeFileSync(_TMP, src);
try {
  await import(_TMP);
} finally {
  try { fs.unlinkSync(_TMP); } catch {}
}
console.log('registered=' + registered);
EOF
    set +e
    out="$(node "$PI" "$TS_EXT" 2>&1)"
    rc=$?
    set -e
    if [ "$rc" -ne 0 ]; then
      printf '  FAIL rasshirenie_fail_open: импорт упал (rc=%d)\n' "$rc" >&2
      exit 0
    fi
    registered="$(printf '%s' "$out" | sed -n 's/^registered=//p')"
    if [ "${registered:-0}" -eq 0 ]; then
      printf 'FAIL расширение: стаб не зарегистрировал session_start\n' >&2
      printf '  ok   rasshirenie_fail_open: стаб пойман\n' >&2
      exit 1
    else
      printf '  ok   rasshirenie_fail_open: session_start зарегистрирован\n' >&2
      exit 0
    fi
    ;;

  remote_nedostupen)
    # Стаб-digest падает на недоступном remote. Реальный digest выводит «remote
    # недоступен». Запускаем из НЕ-git каталога, чтобы `git ls-remote --tags origin`
    # (делаемый стабом без `-C`, наследует cwd) упал с rc=128 — стаб валится,
    # реальный digest переживает. git-кеш живого дерева при этом не задевается:
    # пишем во временный pre-cwd `$NO_GIT`, который лежит вне стерегомого корня.
    NO_GIT="/tmp/drill-no-git-$$"
    mkdir -p "$NO_GIT"
    TD2="/tmp/drill-digest-remote-$$"
    mkdir -p "$TD2"
    export TMPDIR="$TD2"
    set +e
    out="$(cd "$NO_GIT" && bash "$DIGEST" --for-session --root "$WORK" 2>&1)"
    rc=$?
    set -e
    export TMPDIR=
    rm -rf "$TD2" "$NO_GIT"
    # Стаб падает с rc!=0; реальный digest переживает.
    if [ "$rc" -ne 0 ]; then
      printf 'FAIL remote недоступен: стаб валит сбор (rc=%d)\n' "$rc" >&2
      printf '  ok   remote_nedostupen: стаб пойман\n' >&2
      exit 1
    else
      printf '  ok   remote_nedostupen: реальный digest жив (rc=0)\n' >&2
      exit 0
    fi
    ;;

  status_anomalija)
    # Стаб-digest всегда печатает «чисто». Реальный digest называет аномалии.
    # В подставном WORK без git (или с чистым деревом) реальный тоже напечатает «чисто».
    # Здесь создаём dirty WORK.
    TD="$WORK/dirty-$$"
    mkdir -p "$TD"
    cd "$TD"
    if git -C "$TD" rev-parse --git-dir >/dev/null 2>&1; then
      touch "$TD/dirty_file_$$"
    else
      git init -q "$TD" 2>/dev/null || true
      git -C "$TD" -c user.name=Test -c user.email=t@t.local commit --allow-empty -q -m base 2>/dev/null || true
      touch "$TD/dirty_file_$$"
    fi
    cd "$HERE"
    TD2="/tmp/drill-digest-status-$$"
    mkdir -p "$TD2"
    export TMPDIR="$TD2"
    set +e
    out="$(bash "$DIGEST" --for-session --root "$TD" 2>&1)"
    rc=$?
    set -e
    export TMPDIR=
    rm -rf "$TD" "$TD2"
    if [ "$rc" -ne 0 ]; then
      printf '  FAIL status_anomalija: дайджест упал (rc=%d)\n' "$rc" >&2
      exit 0
    fi
    # Стаб печатает «чисто». Реальный — аномалии (dirty_file).
    if [[ "$out" == *'чисто'* ]]; then
      printf 'FAIL чисто: стаб печатает «чисто» при грязном дереве\n' >&2
      printf '  ok   status_anomalija: стаб пойман\n' >&2
      exit 1
    else
      printf '  ok   status_anomalija: реальный называет аномалии\n' >&2
      exit 0
    fi
    ;;

  tegi_ne_nazvany)
    # Стаб-digest всегда печатает «0» для тегов. Реальный digest выводит имена тегов.
    # Создаём локальный тег, отсутствующий на remote.
    if git -C "$WORK" rev-parse --git-dir >/dev/null 2>&1; then
      git -C "$WORK" tag "drill-test-$$" HEAD 2>/dev/null || true
    else
      git -C "$WORK" init -q 2>/dev/null && git -C "$WORK" -c user.name=Drill -c user.email=d@l.local commit --allow-empty -q -m base 2>/dev/null && git -C "$WORK" tag "drill-test-$$" HEAD 2>/dev/null || true
      if [ ! -d "$WORK/.git" ]; then
        printf '  FAIL tegi_ne_nazvany: WORK не репозиторий git и init не удался\n' >&2
        exit 0
      fi
    fi
    TD2="/tmp/drill-digest-tegi-$$"
    mkdir -p "$TD2"
    export TMPDIR="$TD2"
    set +e
    out="$(bash "$DIGEST" --for-session --root "$WORK" 2>&1)"
    rc=$?
    set -e
    export TMPDIR=
    rm -rf "$TD2"
    # Стаб печатает «непушенных тегов: 0». Реальный — «drill-test-$$».
    if [ "$rc" -ne 0 ]; then
      printf '  FAIL tegi_ne_nazvany: дайджест упал (rc=%d)\n' "$rc" >&2
      git -C "$WORK" tag -d "drill-test-$$" 2>/dev/null || true
      exit 0
    fi
    if [[ "$out" == *"drill-test-$$"* ]]; then
      git -C "$WORK" tag -d "drill-test-$$" 2>/dev/null || true
      printf '  ok   tegi_ne_nazvany: реальный называет теги\n' >&2
      exit 0
    else
      git -C "$WORK" tag -d "drill-test-$$" 2>/dev/null || true
      printf 'FAIL теги: стаб не называет теги\n' >&2
      printf '  ok   tegi_ne_nazvany: стаб пойман\n' >&2
      exit 1
    fi
    ;;

  ukazatel_handoff)
    # Стаб-digest без указателя на HANDOFF. Реальный печатает «HANDOFF.md §ГДЕ МЫ…».
    # Создаём HANDOFF.md с разделом «ГДЕ МЫ» в WORK.
    cat > "$WORK/HANDOFF.md" <<'EOF'
# HANDOFF
## ГДЕ МЫ
тестовый
EOF
    TD2="/tmp/drill-digest-handoff-$$"
    mkdir -p "$TD2"
    export TMPDIR="$TD2"
    set +e
    out="$(bash "$DIGEST" --for-session --root "$WORK" 2>&1)"
    rc=$?
    set -e
    export TMPDIR=
    rm -f "$WORK/HANDOFF.md"
    rm -rf "$TD2"
    if [ "$rc" -ne 0 ]; then
      printf '  FAIL ukazatel_handoff: дайджест упал (rc=%d)\n' "$rc" >&2
      exit 0
    fi
    if [[ "$out" == *'HANDOFF.md §ГДЕ МЫ'* ]] || [[ "$out" == *'указатель'* ]]; then
      printf '  ok   ukazatel_handoff: указатель есть\n' >&2
      exit 0
    else
      printf 'FAIL указатель: стаб не печатает указатель на HANDOFF\n' >&2
      printf '  ok   ukazatel_handoff: стаб пойман\n' >&2
      exit 1
    fi
    ;;

  missing_subject)
    printf 'NOT_IMPLEMENTED: рядом нет digest/barrier/расширения — нечего прогонять\n' >&2
    exit 2
    ;;

  *)
    printf 'NOT_IMPLEMENTED: неизвестный сценарий: %s\n' "$scenario" >&2
    exit 2
    ;;
esac
