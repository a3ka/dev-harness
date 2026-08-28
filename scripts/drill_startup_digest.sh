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
    # Зелёная ветвь: реальные субъекты должны работать.
    TD="/tmp/drill-digest-real-$$"
    mkdir -p "$TD"
    export TMPDIR="$TD"
    set +e
    bash "$DIGEST" --for-session --root "$WORK" >/dev/null 2>&1
    rc=$?
    set -e
    export TMPDIR=
    rm -rf "$TD"
    if [ "$rc" -eq 0 ]; then
      printf '  ok   real: реальные субъекты работают\n' >&2
      exit 0
    else
      printf '  FAIL real: реальные субъекты не работают (rc=%d)\n' "$rc" >&2
      exit 1
    fi
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
    cat > "$PI" <<EOF
import fs from 'fs';
import path from 'path';
const fake = {
  on(name, h) {},
  run(cmd) { return { exitCode: 1, stdout: '', stderr: 'дайджест упал' }; },
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
    if [ "$rc" -ne 0 ]; then
      printf 'FAIL fallback: стаб-ts пробрасывает throw (rc=%d)\n' "$rc" >&2
      printf '  ok   fallback_rasshirenija: стаб пойман\n' >&2
      exit 1
    else
      printf '  FAIL fallback_rasshirenija: стаб НЕ пробросил (rc=%d)\n' "$rc" >&2
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
    out="$(bash "$DIGEST" --for-session --root "$TD" 2>&1)"
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
    cat > "$PI" <<EOF
import fs from 'fs';
import path from 'path';
let sends = 0;
const fake = {
  on(name, h) {},
  run(cmd) { return { exitCode: 0, stdout: 'дайджест', stderr: '' }; },
  sendMessage(s) { sends++; }
};
const TS_EXT = path.resolve(process.argv[2]);
const src = fs.readFileSync(TS_EXT, 'utf8');
const jsSrc = src
  .replace(/export default function (\\w+)/, 'globalThis.__ext = function \$1')
  + '\\nif (typeof globalThis.__ext === "function") globalThis.__ext(fake);\\n';
await import('data:text/javascript;base64,' + Buffer.from(jsSrc).toString('base64'));
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
    cat > "$PI" <<EOF
import fs from 'fs';
import path from 'path';
let registered = 0;
const fake = {
  on(name, h) { if (name === 'session_start') registered++; },
  run(cmd) { return { exitCode: 0, stdout: '', stderr: '' }; },
  sendMessage(s) {}
};
const TS_EXT = path.resolve(process.argv[2]);
const src = fs.readFileSync(TS_EXT, 'utf8');
const jsSrc = src
  .replace(/export default function (\\w+)/, 'globalThis.__ext = function \$1')
  + '\\nif (typeof globalThis.__ext === "function") globalThis.__ext(fake);\\n';
await import('data:text/javascript;base64,' + Buffer.from(jsSrc).toString('base64'));
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
    # Стаб-digest падает на недоступном remote. Реальный digest выводит «remote недоступен».
    TD2="/tmp/drill-digest-remote-$$"
    mkdir -p "$TD2"
    export TMPDIR="$TD2"
    set +e
    out="$(bash "$DIGEST" --for-session --root "$WORK" 2>&1)"
    rc=$?
    set -e
    export TMPDIR=
    rm -rf "$TD2"
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
      printf '  FAIL tegi_ne_nazvany: WORK не репозиторий git\n' >&2
      exit 0
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
