# Красное предъявление 1/3 контракта 030 — Н-105: hub в инвентаре ведущей сессии.
# Круг 5 — ВЫДЕЛЕННЫЙ КАНАЛ НАБЛЮДЕНИЯ по РЕШЕНИЮ арбитра (verdicts/arbitration/
# redizajn-transporta-030.md @ 8758348; инварианты Т-1..Т-5 дословно — закон).
# Диагноз вердикта: к4 упал на новом классе — сломан КАНАЛ, не декодер;
# свидетельство exec ехало через stdout проверяемого дерева, которым то владеет
# легально и целиком, и суд, выбирающий запись из общего потока, судит
# САМОНАЗВАНИЕ (происхождение записи доказывалось её префиксом): обход к4
# «forged-record» — сорсимый файл печатал подложную {"omp_stub":1,…} до exec —
# получал ложный rc 0 на пиннутой пробе к4. Никакая дисциплина разбора внутри
# недоверенного потока это не чинит; конструкция требует ключевого свойства —
# ГРОМКИЙ ОТКАЗ вместо ложного зелёного:
#   Т-1 происхождение: stdout/stderr проверяемого судом НЕ читаются вовсе;
#       свидетельство — ОДНА JSON-запись в выделенном файл-канале; путь канала и
#       одноразовый криптослучайный nonce (генерация на запуск пробы) вшиты в
#       ТЕКСТ стаба при генерации, в окружение проверяемого НЕ экспортируются
#       (случайности пути мало: PATH выдаёт дереву каталог стаба — nonce обязателен);
#   Т-2 привязка к exec: стаб открывает канал УСЕЧЕНИЕМ (O_TRUNC, `>`) в момент
#       своего исполнения — на exec-пути строго ПОСЛЕ всего кода дерева (после
#       exec кода дерева не существует); всё написанное в канал до exec
#       уничтожается; проба удаляет канал перед КАЖДЫМ живым запуском — запись
#       прошлого запуска не судится как свидетельство упавшего;
#   Т-3 единственность/целостность: суд читает ВЕСЬ канал и принимает РОВНО ОДНУ
#       завершённую \n запись: чистый ASCII на проводе (стаб эскейпит \\, \", все
#       байты <0x20 И >=0x7f ветвью \uXXXX; NUL в argv невозможен — строки C),
#       валидный JSON без дубль-ключей, точная схема {omp_stub:1, nonce,
#       tools_operand:str}, nonce совпал; ЛЮБОЕ отклонение — пустой канал, не
#       ровно одна запись, не-ASCII байт, битый JSON, дубль ключа, чужая схема,
#       чужой nonce — именованный rc 2; префикс-поиск, splitlines и
#       decode('replace') из суда исключены полностью;
#   Т-4 байтовая точность: суд восстанавливает операнд ПОБАЙТНО (все не-ASCII
#       байты приходят эскейпами; восстановление через latin-1); байт <0x21 или
#       0x7f в токене → rc 1 именованно; невалидный UTF-8 (0xff) → rc 1
#       именованно, не молчаливый U+FFFD; валидные символы с isspace() или
#       категориями Cc/Cf/Zs/Zl/Zp (U+2028, U+0085) → rc 1, не rc 2; обычный
#       UTF-8 в токенах проходит;
#   Т-5 неизменность остального: критерий арбитра 0375aed остаётся законом —
#       живой запуск, оба режима, оба exec-пути (f0/f1/proj), состояние $TOOLS
#       в точке exec; батарея, подписи классов, дисциплина rc 0/1/2 и
#       доминирование слома над красным не пересматриваются; Н-39 — привязки
#       живут в пробе по коду, контракт несёт инварианты и rc-команды, не
#       механизм канала.
#
# Инварианты — на НАБЛЮДЁННОМ операнде, не на тексте workshop:
#   инв. 1  — операнд тул-режима F=0 содержит токен hub;
#   инв. 1' — операнд проектного exec-пути :597 содержит hub (присваивание :473
#             питает ОБА пути; арбитр 0375aed, пункт 4 — v5);
#   инв. 2  — операнд FABLE-режима НЕ содержит hub;
#   инв. 3  — грамматика наблюдённого операнда (Т-4): без пустых токенов,
#             пробельных/управляющих БАЙТОВ в токенах (LF/CR/TAB — один класс
#             operand-integrity), запятых на краю/подряд, дублей; юникод-края
#             (U+2028/U+0085, невалидный UTF-8) — тем же именованным rc 1.
#
# ВНЕШНЯЯ КЛАССИФИКАЦИЯ (к3-Б2): текстовых предусловий ДО живого наблюдения
# НЕТ — суд главного входа всецело динамический, любая форма workshop (включая
# легальный v4 — сорс базового списка) судится исполнением полной командой.
# Батарея селективности строится патчами от якорных строк, но каждый
# построенный артефакт проверяется ПОДПИСЬЮ класса (точные строки-признаки в
# построенном файле); на чуждой форме workshop запись не строится и ГРОМКО
# пропускается («пропущен» в таблице), не запрещая легальные входы и не подменяя
# вердикт живого суда. Граница допустимых обходов (норма вердикта): допустимое
# дерево вправе печатать что угодно в собственные потоки и файлы — подлог в
# stdout безразличен, rc остаётся по настоящему операнду; чтение файлов
# инструмента ради вшитых пути/nonce, фоновые писатели в приватный канал пробы,
# снятие exec ради перезаписи улик — атака на инструмент, судом 030 не
# оценивается (их след в любом случае громок, rc 2, не ложно-зелён).
#
# ДИСЦИПЛИНА КОДОВ (к3-совет): rc 0 = инварианты держатся; rc 1 = именованный
# инвариантный отказ (предмет/обход); rc 2 = ПРОБА НЕДОСТОВЕРНА — живой запуск
# не дошёл до exec, канал наблюдения пуст/повреждён/чужой, батарея сломана.
# СЛОМ доминирует над красным (сломанный стаб даёт 2, не 1). Печати PASS нет:
# решение = код возврата.
#
# СТАБ-ПРИВЯЗКИ (Н-39: живут здесь, не в прозе контракта) — каждый вход
# привязан к наблюдению, на котором его дефект различим живым запуском:
#   S-comment  (w1) — hub только в комментарии: грепающая текст проверка
#             ПРИНЯЛА бы вход; живой exec получает операнд без hub → отказ
#             инв. 1 (наблюдаемость: F=0-операнд без hub);
#   S-obhod-k1 (w2) — исполненный обход круга 1 ДОСЛОВНО (база без edit и без
#             hub, FABLE с edit,hub): идентичность режимов по составу ПРИНЯЛА
#             бы; живые операнды F=0 без hub (инв. 1) И F=1 С hub (инв. 2);
#   S-grammar  (w3) — запятая на краю списка: отказ инв. 3 на самом операнде;
#   S-lf       (b1) — исполненный обход к3-Б1 ДОСЛОВНО: база с hub (легальна),
#             сразу после FABLE-присваивания TOOLS="$TOOLS"$'\n,hub' — строковый
#             транспорт круга 3 терял хвост и давал rc 0 при живом hub в FABLE;
#             выделенный канал доносит операнд ЦЕЛИКОМ → именованный отказ;
#   S-cr       (cr) — брат к3-Б1 на CR ($'\r,hub'): тот же класс контрольного
#             байта, одной ветвью \uXXXX — транспорту безразличен вид байта;
#   k1 (дерево) — обход круга 1 на живом workshop: оба патча по якорям :473/:494;
#   k2 (дерево) — обход круга 2: hub-строка, ЗАТЕМ вторая базовая без hub;
#   v1 (дерево) — затирание внутри СУЩЕСТВУЮЩЕГО if [ -z "$PROJECT" ] до FABLE;
#   v2 (дерево) — затирание сразу после fi блока FABLE, до exec;
#   v3 (дерево) — сорс файла, переприсваивающего TOOLS без hub;
#   v5 (дерево) — hub цел в тул-режиме, затирание перед require_metering
#             "$PROJECT": красен ТОЛЬКО проектным путём (инв. 1');
#   Позитивы (доказательство не-всегда-красности):
#   w4/w5/w6 (мини) — база с hub, FABLE без; FABLE С edit при базе с hub (edit —
#             свободный признак состава); база без edit, но с hub;
#   pos (дерево) — базовая строка :473 с ,hub — все три наблюдения зелёные;
#   v4 (дерево) — ЛЕГАЛЬНАЯ форма: база вынесена в сорсимый файл С hub —
#             к3-Б2: полная команда обязана давать 0, предусловия не запрещают.
# ЯКОРЬ СУДЬИ: строка `if [ "${1:-}" = "--version" ]…` стаба ниже — дословный
# якорь внешней матрицы (класс broken строится sed'ом сразу после неё);
# формулировку менять нельзя, не сломав построение судьи.
set -uo pipefail

REPO="$(cd "$(dirname "$0")/../.." && pwd -P)"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/inv030.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
[ -f "$REPO/workshop" ] || { printf 'NOT_IMPLEMENTED: workshop не найден: %s\n' "$REPO/workshop" >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: python3 недоступен — структурный разбор JSON-транспорта невозможен\n' >&2; exit 2; }

# ── стаб omp: ОДНА JSON-запись ВЫДЕЛЕННЫМ ФАЙЛ-КАНАЛОМ (Т-1/Т-2) ──────────────
mkdir -p "$WORK/stub" "$WORK/minis" "$WORK/trees"
cat > "$WORK/stub/omp" <<'EOF'
#!/usr/bin/env bash
# Т-1: стаб пишет ровно ОДНУ запись в файл-канал; путь канала и nonce вшиты в
# ЭТОТ текст пробой (sed ниже) — в окружении проверяемого их НЕТ. Т-2: канал
# открывается УСЕЧЕНИЕМ (>) в момент исполнения стаба — на exec-пути это строго
# ПОСЛЕ всего кода дерева: всё написанное в канал ДО exec уничтожается.
# stdout/stderr стаба свидетельства не несут — суд их не читает вовсе.
# ЯКОРЬ СУДЬИ (внешняя матрица, класс broken): следующая строка — дословно.
export LC_ALL=C
if [ "${1:-}" = "--version" ]; then printf 'omp/18.1.18\n'; exit 0; fi
s=''
while [ $# -gt 0 ]; do
  if [ "$1" = '--tools' ]; then s="${2:-}"; break; fi
  shift
done
o=''
i=0
while [ "$i" -lt "${#s}" ]; do
  c="${s:i:1}"
  case "$c" in
    \\) o="$o\\\\" ;;
    \") o="$o\\\"" ;;
    *)
      if [ "$c" \< ' ' ] || [ "$c" \> '~' ]; then
        printf -v c '\\u%04x' "'$c"
      fi
      o="$o$c" ;;
  esac
  i=$((i+1))
done
printf '{"omp_stub":1,"nonce":"@NONCE@","tools_operand":"%s"}\n' "$o" > "@CHANNEL@"
exit 0
EOF
cat > "$WORK/stub/node" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod 755 "$WORK/stub/omp" "$WORK/stub/node"
# Т-1: одноразовый криптослучайный nonce на запуск пробы (secrets); путь канала
# и nonce вшиваются в ТЕКСТ стаба (НЕ в окружение проверяемого — переменные
# пробы не экспортированы, rt_* передаёт дереву только явный набор). Гард: если
# sed не вшил плейсхолдеры — громкий rc 2, не тихая деградация.
CHANNEL="$WORK/channel.json"
NONCE="$(python3 -c 'import secrets; print(secrets.token_hex(16))')"
sed -i -e "s|@NONCE@|$NONCE|" -e "s|@CHANNEL@|$CHANNEL|" "$WORK/stub/omp"
if grep -q -e '@NONCE@' -e '@CHANNEL@' "$WORK/stub/omp"; then
  printf 'NOT_IMPLEMENTED: плейсхолдеры канала/nonce не вшиты в стаб\n' >&2
  exit 2
fi

# ── суд инвариантов: ВЕСЬ канал, ОДНА запись, ПОБАЙТНЫЙ операнд (Т-3/Т-4) ──────
cat > "$WORK/court.py" <<'PYEOF'
import json, sys, unicodedata
# argv: <файл-канала> <метка> <роль f0|f1|proj> <nonce>; rc 0/1/2 — шапка пробы.
# Т-1: stdout/stderr проверяемого НЕ читаются вовсе — единственный вход
# свидетельства есть файл-канал. Т-3: ЛЮБОЕ отклонение канала — именованный
# rc 2 (громкий отказ); отклонения самого операнда (Т-4) — именованный rc 1.
path, label, role, nonce = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
def slom(msg):
    sys.stderr.write('ОТКАЗ: %s: %s\n' % (label, msg))
    sys.exit(2)
def refuse(msg):
    sys.stderr.write('ОТКАЗ: %s: %s\n' % (label, msg))
    sys.exit(1)
try:
    with open(path, 'rb') as f:
        blob = f.read()
except OSError:
    blob = b''
if blob == b'':
    slom('живой запуск не дошёл до exec — канал наблюдения пуст')
if not blob.endswith(b'\n') or blob.count(b'\n') != 1:
    slom('канал наблюдения: не ровно одна завершённая запись')
line = blob[:-1]
if any(b < 0x20 or b > 0x7e for b in line):
    slom('канал наблюдения: не-ASCII/управляющий байт на проводе')
def no_dup(pairs):
    d = {}
    for k, v in pairs:
        if k in d:
            slom('канал наблюдения: дубль ключа в записи: %r' % k)
        d[k] = v
    return d
try:
    rec = json.loads(line.decode('ascii'), object_pairs_hook=no_dup)
except ValueError:
    slom('канал наблюдения: запись не является валидным JSON')
if (not isinstance(rec, dict) or set(rec) != {'omp_stub', 'nonce', 'tools_operand'}
        or rec['omp_stub'] != 1 or not isinstance(rec['tools_operand'], str)
        or not isinstance(rec['nonce'], str)):
    slom('канал наблюдения: чужая схема записи')
if rec['nonce'] != nonce:
    slom('канал наблюдения: nonce записи не от стаба этого запуска')
try:
    op = rec['tools_operand'].encode('latin-1', 'strict')
except UnicodeEncodeError:
    slom('канал наблюдения: небайтовый код в операнде')
disp = rec['tools_operand']
if op == b'' or op.startswith(b',') or op.endswith(b',') or b',,' in op:
    refuse('грамматика операнда (инв. 3): пусто/запятая на краю или подряд: %r' % disp)
seen = set()
toks = []
for tb in op.split(b','):
    if tb == b'':
        refuse('грамматика токена (инв. 3): пустой токен (операнд %r)' % disp)
    if any(b < 0x21 or b == 0x7f for b in tb):
        refuse('грамматика токена (инв. 3): пробельный/управляющий байт: %r (операнд %r)' % (tb, disp))
    try:
        t = tb.decode('utf-8')
    except UnicodeDecodeError:
        refuse('грамматика токена (инв. 3): невалидный UTF-8 байт: %r (операнд %r)' % (tb, disp))
    if any(ch.isspace() or unicodedata.category(ch) in ('Cc', 'Cf', 'Zs', 'Zl', 'Zp') for ch in t):
        refuse('грамматика токена (инв. 3): пробельный/управляющий символ: %r (операнд %r)' % (t, disp))
    if t in seen:
        refuse('дубль токена (инв. 3): %r (операнд %r)' % (t, disp))
    seen.add(t)
    toks.append(t)
if role == 'f1':
    if 'hub' in toks:
        refuse('операнд FABLE несёт hub (инв. 2): %r' % disp)
else:
    if 'hub' not in toks:
        refuse('операнд ведущей сессии без hub (инв. 1): %r' % disp)
sys.exit(0)
PYEOF

# ── живой запуск полного дерева: <дерево> <f0|f1|proj> <файл-захвата> ─────────
# (захват stdout/stderr дерева — гигиена вывода; судом НЕ читается, Т-1)
rt_tree() {
  local t="$1" mode="$2" cap="$3" fh="$WORK/fakehome" zn="$WORK/zone"
  rm -rf "$fh" "$zn"; mkdir -p "$fh" "$zn"
  rm -f "$CHANNEL"   # Т-2: свежий канал перед КАЖДЫМ живым запуском
  local -a args=()
  case "$mode" in
    f1)   args=(--fable) ;;
    proj) args=("$t") ;;
  esac
  ( cd "$t" && PATH="$WORK/stub:$PATH" HOME="$fh" HARNESS_SESSION_HOME="$zn" \
      ZAI_API_KEY=x METERING_PROXY_URL=http://127.0.0.1:1 METERING_PROXY_TOKEN=x \
      MINIMAX_API_KEY=x ./workshop "${args[@]}" ) >"$cap" 2>"$WORK/last-stderr.txt"
}

# ── живой запуск мини-workshop: режим — переменная FABLE, как внутри workshop ──
rt_mini() {  # <файл> <0|1> <файл-захвата>
  rm -f "$CHANNEL"   # Т-2: свежий канал перед КАЖДЫМ живым запуском
  ( cd "$WORK/minis" && PATH="$WORK/stub:$PATH" FABLE="$2" bash "$1" ) \
    >"$3" 2>"$WORK/last-mini-stderr.txt"
}

# ── суд полного дерева: ОБОИ режима и ОБОА exec-пути; не дошедшее = 2 (СЛОМ) ───
sudit_tree() {  # <дерево> <имя>: 0 зелёный | 1 именованный отказ | 2 не дошёл
  local t="$1" nm="$2" rc=0 prc
  rt_tree "$t" f0 "$WORK/c-$nm-f0.out" \
    || { printf 'ОТКАЗ: [%s] тул-режим F=0: запуск не состоялся\n' "$nm" >&2; return 2; }
  prc=0; python3 "$WORK/court.py" "$CHANNEL" "[$nm] тул-режим F=0 (exec :516)" f0 "$NONCE" || prc=$?
  [ "$prc" = 2 ] && return 2
  [ "$prc" = 1 ] && rc=1
  rt_tree "$t" f1 "$WORK/c-$nm-f1.out" \
    || { printf 'ОТКАЗ: [%s] FABLE: запуск не состоялся\n' "$nm" >&2; return 2; }
  prc=0; python3 "$WORK/court.py" "$CHANNEL" "[$nm] FABLE (exec :516)" f1 "$NONCE" || prc=$?
  [ "$prc" = 2 ] && return 2
  [ "$prc" = 1 ] && rc=1
  rt_tree "$t" proj "$WORK/c-$nm-pr.out" \
    || { printf 'ОТКАЗ: [%s] проектный путь: запуск не состоялся\n' "$nm" >&2; return 2; }
  prc=0; python3 "$WORK/court.py" "$CHANNEL" "[$nm] проектный путь (exec :597)" proj "$NONCE" || prc=$?
  [ "$prc" = 2 ] && return 2
  [ "$prc" = 1 ] && rc=1
  return "$rc"
}

# ── суд мини-workshop: один exec-путь (мини = тул-режим), оба режима ──────────
sudit_mini() {  # <файл> <имя>: 0 | 1 | 2
  local f="$1" nm="$2" rc=0 prc
  rt_mini "$f" 0 "$WORK/c-$nm-m0.out" \
    || { printf 'ОТКАЗ: [%s] мини F=0: запуск не состоялся\n' "$nm" >&2; return 2; }
  prc=0; python3 "$WORK/court.py" "$CHANNEL" "[$nm] мини F=0" f0 "$NONCE" || prc=$?
  [ "$prc" = 2 ] && return 2
  [ "$prc" = 1 ] && rc=1
  rt_mini "$f" 1 "$WORK/c-$nm-m1.out" \
    || { printf 'ОТКАЗ: [%s] мини FABLE: запуск не состоялся\n' "$nm" >&2; return 2; }
  prc=0; python3 "$WORK/court.py" "$CHANNEL" "[$nm] мини FABLE" f1 "$NONCE" || prc=$?
  [ "$prc" = 2 ] && return 2
  [ "$prc" = 1 ] && rc=1
  return "$rc"
}

# ── мини-workshop'и: герметичны, но ИСПОЛНЯЮТСЯ — судится exec, не текст ──────
printf '%s\n' '#!/usr/bin/env bash' \
  '# hub нужен ведущей сессии: мониторинг/обрыв/ответ субагентам (Н-105)' \
  'TOOLS="read,edit,write,bash"' \
  'if [ "$FABLE" = "1" ]; then' \
  '  TOOLS="read,grep"' \
  'fi' \
  'exec omp --tools "$TOOLS"' > "$WORK/minis/w1"
printf '%s\n' '#!/usr/bin/env bash' \
  'TOOLS="read,write,bash,grep,glob,lsp,web_search,task,todo"' \
  'if [ "$FABLE" = "1" ]; then' \
  '    TOOLS="read,edit,grep,glob,bash,web_search,task,todo,hub"' \
  'fi' \
  'exec omp --tools "$TOOLS"' > "$WORK/minis/w2"
printf '%s\n' '#!/usr/bin/env bash' \
  'TOOLS="read,edit,write,hub,"' \
  'if [ "$FABLE" = "1" ]; then' \
  '  TOOLS="read,grep"' \
  'fi' \
  'exec omp --tools "$TOOLS"' > "$WORK/minis/w3"
printf '%s\n' '#!/usr/bin/env bash' \
  'TOOLS="read,edit,write,bash,grep,glob,lsp,web_search,task,todo,hub"' \
  'if [ "$FABLE" = "1" ]; then' \
  '  TOOLS="read,grep,glob,bash,web_search,task,todo"' \
  'fi' \
  'exec omp --tools "$TOOLS"' > "$WORK/minis/w4"
printf '%s\n' '#!/usr/bin/env bash' \
  'TOOLS="read,edit,write,bash,hub"' \
  'if [ "$FABLE" = "1" ]; then' \
  '  TOOLS="read,edit,grep"' \
  'fi' \
  'exec omp --tools "$TOOLS"' > "$WORK/minis/w5"
printf '%s\n' '#!/usr/bin/env bash' \
  'TOOLS="read,write,bash,grep,glob,lsp,web_search,task,todo,hub"' \
  'if [ "$FABLE" = "1" ]; then' \
  '  TOOLS="read,grep,glob,web_search,todo"' \
  'fi' \
  'exec omp --tools "$TOOLS"' > "$WORK/minis/w6"

# ── деревья-варианты живого workshop: патчи по якорным строкам ────────────────
# Значения передаются awk ЧЕРЕЗ ОКРУЖЕНИЕ (ENVIRON): -v обрабатывает esc-после-
# довательности и превратил бы \n дописей в живой LF. Состав патчей порождает
# смысл сам, поэтому батарею не ломает ни предмет (hub в :473), ни его отсутствие:
# каждая запись затем проверяется ПОДПИСЬЮ класса (postroil), а на чуждой форме
# workshop громко пропускается — якоря больше НЕ стоят до живого наблюдения (к3-Б2).
BASE='TOOLS="read,edit,write,bash,grep,glob,lsp,web_search,task,todo"'
NOEDIT='TOOLS="read,write,bash,grep,glob,lsp,web_search,task,todo"'
HUB='TOOLS="read,edit,write,bash,grep,glob,lsp,web_search,task,todo,hub"'
STOMP='  TOOLS="read,edit,write,bash,grep,glob,lsp,web_search,task,todo"'
FAB_RE='    TOOLS="read,grep,glob,bash,web_search,task,todo"'
FAB_K1='    TOOLS="read,edit,grep,glob,bash,web_search,task,todo,hub"'
SRC='. "$HERE/scripts/session_tools.sh"'
# исполненные дописи к3-Б1 (LF) и его брат на CR — байты дословно, без склейки
LF_DOPIS="    TOOLS=\"\$TOOLS\"\$'\\n,hub'"
CR_DOPIS="    TOOLS=\"\$TOOLS\"\$'\\r,hub'"
mkvar() {  # <имя> <awk-прог> [<содержимое scripts/session_tools.sh>]
  local name="$1" prog="$2"
  local t="$WORK/trees/$name"
  rm -rf "$t"; mkdir -p "$t"
  ( cd "$REPO" && tar -cf - --exclude=./.git . ) | ( cd "$t" && tar -xf - )
  BASE="$BASE" NOEDIT="$NOEDIT" HUB="$HUB" STOMP="$STOMP" FABK1="$FAB_K1" \
  FAB="$FAB_RE" SRC="$SRC" LFD="$LF_DOPIS" CRD="$CR_DOPIS" \
    awk "$prog" "$REPO/workshop" > "$t/workshop"
  chmod 755 "$t/workshop"
  [ -z "${3:-}" ] || printf '%s\n' "$3" > "$t/scripts/session_tools.sh"
  git -C "$t" init -q   # проектному пути достаточно git-репозитория (rev-parse)
}

mkvar pos '$0 == ENVIRON["BASE"] || $0 == ENVIRON["HUB"] { print ENVIRON["HUB"]; next } { print }'
mkvar k1  '$0 == ENVIRON["BASE"] || $0 == ENVIRON["HUB"] { print ENVIRON["NOEDIT"]; next }
           $0 == ENVIRON["FAB"] || $0 == ENVIRON["FABK1"] { print ENVIRON["FABK1"]; next }
           { print }'
mkvar k2  '$0 == ENVIRON["BASE"] || $0 == ENVIRON["HUB"] { print ENVIRON["HUB"]; print ENVIRON["BASE"]; next } { print }'
# v1: «условное» затирание внутри СУЩЕСТВУЮЩЕГО if [ -z "$PROJECT" ] до FABLE
mkvar v1  '$0 == ENVIRON["BASE"] || $0 == ENVIRON["HUB"] { print ENVIRON["HUB"]; next }
           $0 == "if [ -z \"$PROJECT\" ]; then" { print; print ENVIRON["STOMP"]; next } { print }'
# v2: затирание сразу после fi блока FABLE (с отступом, до exec тул-режима)
mkvar v2  '$0 == ENVIRON["BASE"] || $0 == ENVIRON["HUB"] { print ENVIRON["HUB"]; next }
           /РЕЖИМ FABLE  консультант read-only/ { print; f = 1; next }
           f && /^  fi$/ { print; print ENVIRON["STOMP"]; f = 0; next } { print }'
# v3: сорс файла БЕЗ hub сразу после hub-строки (текстовый сканер сорс не видит)
mkvar v3  '$0 == ENVIRON["BASE"] || $0 == ENVIRON["HUB"] { print ENVIRON["HUB"]; print ENVIRON["SRC"]; next } { print }' "$BASE"
# v4: ЛЕГАЛЬНОЕ дерево — базовая строка заменена сорсом файла С hub (к3-Б2: зелёное)
mkvar v4  '$0 == ENVIRON["BASE"] || $0 == ENVIRON["HUB"] { print ENVIRON["SRC"]; next } { print }' "$HUB"
# v5: hub цел; затирание кол.0 перед require_metering "$PROJECT" (проектный путь)
mkvar v5  '$0 == ENVIRON["BASE"] || $0 == ENVIRON["HUB"] { print ENVIRON["HUB"]; next }
           /^require_metering "\$PROJECT"$/ { print ENVIRON["BASE"]; print; next } { print }'
# b1: исполненный обход к3-Б1 ДОСЛОВНО — LF-допис сразу после FABLE-присваивания
mkvar b1  '$0 == ENVIRON["BASE"] || $0 == ENVIRON["HUB"] { print ENVIRON["HUB"]; next }
           $0 == ENVIRON["FAB"] { print; print ENVIRON["LFD"]; next } { print }'
# cr: брат к3-Б1 на CR — тот же класс контрольного байта, одна ветвь \uXXXX
mkvar cr  '$0 == ENVIRON["BASE"] || $0 == ENVIRON["HUB"] { print ENVIRON["HUB"]; next }
           $0 == ENVIRON["FAB"] { print; print ENVIRON["CRD"]; next } { print }'

# ── подпись класса: ПОЛНЫЙ инвентарь строк-признаков построенного артефакта ───
# Класс = ТОЧНАЯ кратность каждого маркера (чужие маркеры — 0): патч, частично
# применившийся или построенный поверх чуждой формы workshop (наследованный
# маркер), подписи не даёт — запись громко пропускается, СЛОМом не становится.
cfx() { grep -cFx -- "$1" "$2"; }
postroil() {  # <имя>: rc 0 = инвентарь класса сошлся точно
  local nm="$1"
  local w="$WORK/trees/$nm/workshop" s="$WORK/trees/$nm/scripts/session_tools.sh"
  local inv
  inv="$(cfx "$HUB" "$w")/$(cfx "$BASE" "$w")/$(cfx "$NOEDIT" "$w")/$(cfx "$FAB_K1" "$w")/$(cfx "$STOMP" "$w")/$(cfx "$FAB_RE" "$w")/$(cfx "$SRC" "$w")/$(cfx "$LF_DOPIS" "$w")/$(cfx "$CR_DOPIS" "$w")"
  # порядок инвентаря: HUB/BASE/NOEDIT/FABK1/STOMP/FAB/SRC/LFD/CRD
  case "$nm" in
    pos) [ "$inv" = '1/0/0/0/0/1/0/0/0' ] ;;
    k1)  [ "$inv" = '0/0/1/1/0/0/0/0/0' ] ;;
    k2)  [ "$inv" = '1/1/0/0/0/1/0/0/0' ] ;;
    v1)  [ "$inv" = '1/0/0/0/1/1/0/0/0' ] ;;
    v2)  [ "$inv" = '1/0/0/0/1/1/0/0/0' ] ;;
    v3)  [ "$inv" = '1/0/0/0/0/1/1/0/0' ] && [ "$(cfx "$BASE" "$s")" = 1 ] ;;
    v4)  [ "$inv" = '0/0/0/0/0/1/1/0/0' ] && [ "$(cfx "$HUB" "$s")" = 1 ] ;;
    v5)  [ "$inv" = '1/1/0/0/0/1/0/0/0' ] ;;
    b1)  [ "$inv" = '1/0/0/0/0/1/0/1/0' ] ;;
    cr)  [ "$inv" = '1/0/0/0/0/1/0/0/1' ] ;;
    *)   return 1 ;;
  esac
}

# ── селективность: обманные входы краснеют ИМЕНОВАННО, легальные зеленеют ──────
# rc 2 = СЛОМ для любого ожидания (это не красное); «пропущен» = громкий пропуск
# строительства на чуждой форме workshop — НЕ провал и НЕ молчание: вердикт по
# входу остаётся за живым судом $REPO ниже.
SLOM=0
vivod() {  # <имя> <red|green> <функция суда> <арг...>
  local nm="$1" exp="$2"; shift 2
  local rc=0 verd
  "$@" >"$WORK/j-$nm.out" 2>"$WORK/j-$nm.err" || rc=$?
  if [ "$rc" = 2 ]; then
    verd=СЛОМ; SLOM=1
  elif { [ "$exp" = red ] && [ "$rc" = 1 ]; } || { [ "$exp" = green ] && [ "$rc" = 0 ]; }; then
    verd=ok
  else
    verd=СЛОМ; SLOM=1
  fi
  printf '%-4s | rc=%s | ожидалось: %s | %s\n' "$nm" "$rc" \
    "$([ "$exp" = red ] && printf 'красное' || printf 'зелёное')" "$verd"
  [ "$verd" = ok ] || cat "$WORK/j-$nm.err" >&2
}
derevo() {  # <имя> <red|green>: строительство → подпись → суд
  local nm="$1" exp="$2"
  local t="$WORK/trees/$nm"
  if cmp -s "$REPO/workshop" "$t/workshop"; then
    printf '%-4s | --      | пропущен: патч не изменил workshop (якорь класса на этой форме не найден)\n' "$nm"
    return
  fi
  postroil "$nm" || { printf '%-4s | --      | пропущен: инвентарь класса не сошлся (частичный патч/чуждая форма)\n' "$nm"; return; }
  vivod "$nm" "$exp" sudit_tree "$t" "$nm"
}
printf 'вход | rc суда | ожидание | вердикт\n'
vivod w1   red   sudit_mini "$WORK/minis/w1" w1
vivod w2   red   sudit_mini "$WORK/minis/w2" w2
vivod w3   red   sudit_mini "$WORK/minis/w3" w3
vivod w4   green sudit_mini "$WORK/minis/w4" w4
vivod w5   green sudit_mini "$WORK/minis/w5" w5
vivod w6   green sudit_mini "$WORK/minis/w6" w6
derevo pos  green
derevo k1   red
derevo k2   red
derevo v1   red
derevo v2   red
derevo v3   red
derevo v4   green
derevo v5   red
derevo b1   red
derevo cr   red

# ── живое предъявление: текущий workshop — главный суд, всецело динамический ──
# (к3-Б2: текстовых предусловий до живого наблюдения нет; ЛЮБАЯ форма workshop,
# включая легальный v4-сорс, судится исполнением полной командой)
live_rc=0
sudit_tree "$REPO" 'живой-workshop' >"$WORK/j-live.out" 2>"$WORK/j-live.err" || live_rc=$?
cat "$WORK/j-live.err" >&2
if [ "$SLOM" = 1 ] || [ "$live_rc" = 2 ]; then
  printf 'СЛОМ: проба недостоверна (живой запуск/батарея/транспорт) — rc 2, не красное\n' >&2
  exit 2
fi
exit "$live_rc"
