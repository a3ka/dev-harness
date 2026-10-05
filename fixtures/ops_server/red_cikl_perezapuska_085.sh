#!/usr/bin/env bash
# Красная/зелёная батарея 085 «цикл перезапуска = репо»
# (contracts/085-cikl-perezapuska-repo.md; семья fixtures/ops_server/ — probe-only 034,
# прямое предъявление вне case_*-глоба; входы-снимки — fixtures/ops_server/cikl_085/).
#
# СУБЪЕКТЫ (дерево OPS_ROOT, по умолчанию — дерево батареи):
#   ops/server/user/orch-loop — цикл перезапуска: станция ebc53f30 + потолок памяти;
#   ops/server/root/orch-peak — сторож: слияние станции b3e354cd и версии 080.
# ВХОДЫ-СНИМКИ (sha256 — пины в памяти батареи; сверяются копии в скратче ДО вызова
# субъекта, оракулы р1/р2 и MSG станции читаются в память из сверенных копий):
#   stancija.orch-loop, stancija.orch-peak — станция, живой съём 2026-10-05;
#   slijanie.orch-peak — git merge-file -p -L stancija -L baza -L v080 (3 конфликта);
#   repo-fad71b15.orch-loop, repo-8380d01f.orch-peak — прежние версии репо (стабы).
#
# КЛЕТКИ (вход → наблюдение):
#   р0  sha256 снимков == пинам; расхождение — rc 2 (подмена входа), не красная;
#   р1  И-1: строки slijanie вне трёх конфликтных кусков есть в orch-peak в том же
#       порядке (вставки допустимы), кроме строки kill_session со стоп-файлом (И-4д);
#   р2  И-2: строки stancija.orch-loop есть в orch-loop в том же порядке, кроме строки
#       запуска сессии (И-5); красное несёт текст первой пропавшей строки;
#   л1-л8 И-3: цикл в скратче, сессия-подделка по плану, токен на сессию (early — маркер
#       на 1 с; normal — на 8 с; exit/crash — выход 0/1; stopkill — ORCH_STOP и выход 143;
#       cancel — маркер снят в GRACE, сам выход 0; termrm — снятие маркера на SIGTERM;
#       oom — SIGKILL себе, rc 137); шим systemd-run в PATH исполняет команду после «--»
#       exec'ом (как --scope); ORCH_GRACE=1 ORCH_MIN_LIFE=9 ORCH_EARLY_WAIT=1
#       ORCH_EARLY_MAX=3, если клетка не задаёт иное;
#   п1-п11 И-4: сторож в мире шва ORCH_PEAK_TEST 080 (say.log, omp-pids, killed.log),
#       ORCH_USER=nobody (дом /nonexistent: запись в пути станции невозможна),
#       ORCH_LOOP_STOP в скратче, toy-repo с bare origin, журнал верхнего уровня с usage;
#       пороги CTX_* и IDLE — умолчания субъекта; п5 — четыре входа, каждый своей строкой;
#   м1-м4 И-5: шим systemd-run (журнал argv и XDG_RUNTIME_DIR; pass — exec после «--»,
#       refuse — rc 1 без исполнения); м5 — живой systemd-run --user (где user-менеджера
#       нет — «пропуск с пометкой»);
#   с1, с2 (режим stancija) И-8: живая станция.
# Граница наблюдаемости: шим подменяет systemd-run через PATH (как и прочие команды
# станционной версии, вызов по имени); абсолютный путь мимо PATH — «не вызван», красное.
#
# Н-39: привязка стабов к входам — список STUBS построителя ниже (id, клетка, метка,
# основа, правки): снимки прежних версий и мутации честной симуляции. Мера смерти
# (А-338): пойман — только исполненное отклонение на своём входе; авария (синтаксис,
# unbound, пустой журнал, завис) — красная «стаб не исполнился». Диффпроба: тот же вход
# на честной симуляции FIXSIM обязан быть зелёным.
#
# Режимы: без аргумента — все клетки, стаб-пак и диффпроба (параллельно, ≈ 1 мин);
#   fast — проба гейта 036: р0 л1 п1 м1; stancija — с1 с2 на живой станции;
#   FIXSIM=1 — субъект = честная симуляция, собранная в скратче из снимков (А-318).
# Коды возврата: 0 — клетки зелёные, стабы N/N пойманы, диффпроба зелёная;
#   1 — красная клетка, живой/неисполнившийся стаб, красная диффпроба;
#   2 — нечем проверить (нет инструмента, подмена входа, нет живого цикла в stancija).
#
# Использование:
#   bash fixtures/ops_server/red_cikl_perezapuska_085.sh [fast|stancija]
#   FIXSIM=1 bash fixtures/ops_server/red_cikl_perezapuska_085.sh [fast]
#   OPS_ROOT=<дерево-субъекта> bash fixtures/ops_server/red_cikl_perezapuska_085.sh

set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
OPS_ROOT="${OPS_ROOT:-$(cd "$HERE/../.." && pwd -P)}"
SNAP_DIR="$HERE/cikl_085"
F080="$HERE/../dver_bugfiks_080/red_dver_bugfiks_080.sh"
FIXSIM_ON="${FIXSIM:-0}"
MODE="${1:-full}"

die2() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 2; }
case "$MODE" in
  full|fast|stancija) ;;
  *) printf 'использование: bash fixtures/ops_server/red_cikl_perezapuska_085.sh [fast|stancija]\n' >&2; exit 2 ;;
esac

# Гигиена: швы станции и git из окружения вызывающего в миры клеток не просачиваются.
for _v in $(compgen -v); do
  case "$_v" in ORCH_*|CIKL085_*|GIT_DIR|GIT_WORK_TREE|GIT_INDEX_FILE|GIT_AUTHOR_*|GIT_COMMITTER_*) unset "$_v" ;; esac
done

(( BASH_VERSINFO[0] > 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 4) )) \
  || die2 'NOT_IMPLEMENTED: нужен bash ≥ 4.4 (wait -n, mapfile -d)'
for _t in sha256sum python3 git jq timeout pgrep pkill getent find stat tac touch sed grep; do
  command -v "$_t" >/dev/null 2>&1 || die2 "NOT_IMPLEMENTED: нет $_t"
done

# ── литералы контракта (единственный источник в батарее) ─────────────────────
LIT_SIGN='СТОРОЖ СТАНЦИИ (автоматически'
LIT_NOT_OWNER='НЕ слово владельца'
LIT_OWNER='ВЛАДЕЛЕЦ (автоматически'
LIT_OOM='OOM: omp убит потолком памяти'
LIT_NOCAP='БЕЗ ПОТОЛКА ПАМЯТИ'
LINE_LAUNCH='"$WORKSHOP" --yolo -- "$MSG"; rc=$?'
LINE_KILLSTOP='  as_u touch "$UHOME/orch-loop.stop"   # намеренный останов: цикл не примет его за падение'
PEAK_SESS='20261005T120000_00000000-0085-0085-0085-000000000001'
PEAK_SESS2='20261005T130000_00000000-0085-0085-0085-000000000002'
MEM_DEFAULT_BYTES=34359738368   # 32G — с2
M5_BYTES=67108864               # 64M — м5

declare -A NAME=(
  [r0]=р0 [r1]=р1 [r2]=р2
  [l1]=л1 [l2]=л2 [l3]=л3 [l4]=л4 [l5]=л5 [l6]=л6 [l7]=л7 [l8]=л8
  [p1]=п1 [p2]=п2 [p3]=п3 [p4]=п4 [p5w]='п5[warn]' [p5s]='п5[ctx550000]'
  [p5h]='п5[ctx650000]' [p5t]='п5[stop]' [p6]=п6 [p7]=п7 [p8]=п8 [p9]=п9 [p10]=п10 [p11]=п11
  [m1]=м1 [m2]=м2 [m3]=м3 [m4]=м4 [m5]=м5
)
# Порядок запуска — длинные миры первыми; порядок печати — ORDER.
CELLS_LOOP=(l8 l2 l6 l7 l1 l4 l3 l5)
CELLS_MEM=(m3 m1 m2 m4)
CELLS_PEAK=(p1 p2 p9 p5h p5t p3 p4 p5w p5s p6 p7 p8 p10 p11)
ORDER=(r0 r1 r2 l1 l2 l3 l4 l5 l6 l7 l8 p1 p2 p3 p4 p5w p5s p5h p5t p6 p7 p8 p9 p10 p11 m1 m2 m3 m4 m5)

fails=0
say_cell() { # <исход 0|1|3|4|9> <имя> <текст>
  case "$1" in
    0) printf '  зелено: %s — %s\n' "$2" "$3" ;;
    4) printf '  пропуск с пометкой: %s — %s\n' "$2" "$3" ;;
    3) fails=$((fails + 1)); printf '  КРАСНО: %s — не исполнился: %s\n' "$2" "$3" ;;
    9) fails=$((fails + 1)); printf '  КРАСНО: %s — нет результата клетки\n' "$2" ;;
    *) fails=$((fails + 1)); printf '  КРАСНО: %s — %s\n' "$2" "$3" ;;
  esac
}

# ── режим stancija (И-8): живая станция, без скратча и снимков ────────────────
if [ "$MODE" = stancija ]; then
  U=harness
  command -v systemctl >/dev/null 2>&1 || die2 'нечем проверить: нет systemctl (режим stancija — только на станции)'
  uid="$(id -u "$U" 2>/dev/null)" || die2 "нечем проверить: нет пользователя $U"
  lp=''; omp=''
  for p in $(pgrep -u "$U" -f 'bin/orch-loop'); do
    [ "$(ps -o comm= -p "$p" 2>/dev/null)" = bash ] || continue
    omp="$(pgrep -P "$p" -f '^omp --profile' | head -n 1)"
    [ -n "$omp" ] && { lp="$p"; break; }
  done
  [ -n "$omp" ] || die2 "нет живого цикла: bin/orch-loop пользователя $U с прямым потомком «omp --profile» не найден"
  printf '085 stancija: цикл %s, omp %s\n' "$lp" "$omp"
  act="$(systemctl is-active orch-memcap.timer 2>/dev/null)"
  if [ "$act" = active ] || [ -e /usr/local/sbin/orch-memcap ]; then
    say_cell 1 с1 "временный сторож памяти жив: orch-memcap.timer=${act:-?}, /usr/local/sbin/orch-memcap $([ -e /usr/local/sbin/orch-memcap ] && echo есть || echo нет)"
  else
    say_cell 0 с1 "orch-memcap.timer не активен (${act:-нет юнита}), /usr/local/sbin/orch-memcap нет"
  fi
  cg="$(sed -n 's/^0:://p' "/proc/$omp/cgroup" 2>/dev/null)"
  mm="$(cat "/sys/fs/cgroup$cg/memory.max" 2>/dev/null)"
  ok=1
  case "${cg##*/}" in run-*.scope) ;; *) ok=0 ;; esac
  case "$cg" in */user@"$uid".service/*) ;; *) ok=0 ;; esac
  [ "$mm" = "$MEM_DEFAULT_BYTES" ] || ok=0
  if [ "$ok" = 1 ]; then
    say_cell 0 с2 "omp цикла в $cg, memory.max $mm"
  else
    say_cell 1 с2 "omp $omp в cgroup ${cg:-?}, memory.max ${mm:-?} (ожидалось run-*.scope под user@$uid.service, $MEM_DEFAULT_BYTES)"
  fi
  printf 'итог 085 stancija: красных=%d\n' "$fails"
  [ "$fails" -eq 0 ] && exit 0
  exit 1
fi

# ── скратч и уборка ────────────────────────────────────────────────────────────
RUN="$$"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/cikl085.XXXXXX")" || die2 'mktemp'
cleanup() {
  local j
  for j in $(jobs -p); do kill -KILL "$j" 2>/dev/null; done
  pkill -KILL -f "^omp --profile cikl085-$RUN-" 2>/dev/null
  pkill -KILL -f "$SCRATCH/" 2>/dev/null
  rm -rf "$SCRATCH"
}
trap cleanup EXIT
trap 'exit 130' INT TERM
mkdir -p "$SCRATCH/snap" "$SCRATCH/w" "$SCRATCH/res" "$SCRATCH/shimbin"

# ── р0: снимки == пинам в памяти; оракулы — в память из сверенных копий ──────
declare -A PIN=(
  [stancija.orch-loop]=ebc53f306a352ef8ec58d130d5d667ea685c6977d932a0439de755ca62038cd9
  [stancija.orch-peak]=b3e354cd2aae1a28e50b1423c6d5164e2d0a7ca2dcec4e17f47ccb4b549824b3
  [slijanie.orch-peak]=d7f74f54716b33651c4111fc1bbaf303c7b8126cb9b0a4d90f006218b16a647c
  [repo-fad71b15.orch-loop]=fad71b1540965d84ed4f3f54759ba76b43628e2be9b91bc9405be62a34a63e2d
  [repo-8380d01f.orch-peak]=8380d01fdd8200f25093a2b11cf6c11124dc0a13eb86851476346f7513c94c6c
)
SNAPS=(stancija.orch-loop stancija.orch-peak slijanie.orch-peak repo-fad71b15.orch-loop repo-8380d01f.orch-peak)
for s in "${SNAPS[@]}"; do
  [ -f "$SNAP_DIR/$s" ] || die2 "подмена входа: нет снимка cikl_085/$s"
  cp -- "$SNAP_DIR/$s" "$SCRATCH/snap/$s"
  h="$(sha256sum <"$SCRATCH/snap/$s" | cut -d' ' -f1)"
  [ "$h" = "${PIN[$s]}" ] || die2 "подмена входа: cikl_085/$s sha256 $h ≠ пину ${PIN[$s]}"
done
R0_MSG="${#SNAPS[@]}/${#PIN[@]} снимков cikl_085/ == пинам в памяти"

mapfile -t SNAP_LOOP <"$SCRATCH/snap/stancija.orch-loop"
mapfile -t SNAP_MERGE <"$SCRATCH/snap/slijanie.orch-peak"
MSG_STATION="$(sed -n "s/^MSG='\(.*\)'\$/\1/p" "$SCRATCH/snap/stancija.orch-loop")"
[ -n "$MSG_STATION" ] && [ "$(printf '%s\n' "$MSG_STATION" | grep -c '')" = 1 ] \
  || die2 'дефект батареи: MSG станции не извлечён из снимка ровно одной строкой'
count_line() { # <имя-массива> <строка> → число вхождений строки целиком
  local -n _a="$1"; local x c=0
  for x in "${_a[@]}"; do [ "$x" = "$2" ] && c=$((c + 1)); done
  printf '%s' "$c"
}
[ "$(count_line SNAP_LOOP "$LINE_LAUNCH")" = 1 ] || die2 'дефект батареи: строка запуска сессии не единственна в снимке станции'
[ "$(count_line SNAP_MERGE "$LINE_KILLSTOP")" = 1 ] || die2 'дефект батареи: строка kill_session со стоп-файлом не единственна в снимке слияния'
[ -f "$F080" ] || die2 "нечем проверить: нет батареи 080 — носителя PHRASE_OK ($F080)"
PHRASE_OK="$(sed -n "s/^PHRASE_OK='\(.*\)'\$/\1/p" "$F080")"
[ -n "$PHRASE_OK" ] && [ "$(printf '%s\n' "$PHRASE_OK" | grep -c '')" = 1 ] \
  || die2 'нечем проверить: PHRASE_OK не извлечён из батареи 080 ровно одной строкой'
NOBODY_HOME="$(getent passwd nobody | cut -d: -f6)"
[ -n "$NOBODY_HOME" ] && [ ! -e "$NOBODY_HOME" ] \
  || die2 "нечем проверить: нужен пользователь nobody без живого дома (демаркация 085), дом: «${NOBODY_HOME:-нет}»"

# ── построитель: FIXSIM (честная симуляция из снимков) и стабы (Н-39) ─────────
python3 - "$SCRATCH" "$PHRASE_OK" "$LIT_OOM" "$LIT_NOCAP" "$LINE_LAUNCH" "$LINE_KILLSTOP" \
  >"$SCRATCH/stubs.tsv" 2>"$SCRATCH/builder.err" <<'PYEOF'
import os, sys
S, PHRASE_OK, LIT_OOM, LIT_NOCAP, LINE_LAUNCH, LINE_KILLSTOP = sys.argv[1:7]

def rd(name):
    with open(os.path.join(S, 'snap', name), encoding='utf-8') as f:
        return f.read()

def wr(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)
    os.chmod(path, 0o755)

def sub1(text, old, new, what):
    c = text.count(old)
    if c != 1:
        raise ValueError('%s: якорь встречается %d раз(а)' % (what, c))
    return text.replace(old, new, 1)

# FIXSIM orch-loop = станция + потолок памяти (И-2, И-5): вставки, строка запуска заменена.
MEM_DEF = 'MEM_MAX="${ORCH_MEM_MAX:-32G}"   # потолок памяти сессии omp (контракт 085, И-5)\n'
XDG_LINE = 'export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"\n'
NOCAP_LINE = ('  scoped=0; log "сессия #$n: @L@ — systemd-run --user --scope не создал scope"\n'
              .replace('@L@', LIT_NOCAP))
DIRECT_LINE = '  ' + LINE_LAUNCH + '\n'
LAUNCH = ("# Потолок памяти (контракт 085, И-5): --scope исполняет команду exec'ом — omp остаётся\n"
          '# прямым потомком цикла; нет scope (нет user-bus) — сессия без потолка, со строкой журнала.\n'
          + XDG_LINE +
          'SCOPE=(systemd-run --user --scope -q -p "MemoryMax=$MEM_MAX" -p MemorySwapMax=0)\n'
          'if "${SCOPE[@]}" -- true >/dev/null 2>&1; then\n'
          '  scoped=1; "${SCOPE[@]}" -- "$WORKSHOP" --yolo -- "$MSG"; rc=$?\n'
          'else\n'
          + NOCAP_LINE + DIRECT_LINE +
          'fi\n')
OOM_LINE = ('  [ "$rc" -eq 137 ] && [ "$scoped" -eq 1 ] && log "сессия #$n: @L@ (MemoryMax=$MEM_MAX, rc=137)"\n'
            .replace('@L@', LIT_OOM))
CRASH = '  crash=$(( ${ORCH_CRASH:-0} + 1 ));'
LOGDEF = 'LOG="${ORCH_LOG:-$HOME/orch-loop.log}"\n'
loop = rd('stancija.orch-loop')
loop = sub1(loop, LOGDEF, LOGDEF + MEM_DEF, 'FIXSIM loop: MEM_MAX')
loop = sub1(loop, '\n' + LINE_LAUNCH + '\n', '\n' + LAUNCH, 'FIXSIM loop: запуск сессии')
loop = sub1(loop, CRASH, OOM_LINE + CRASH, 'FIXSIM loop: строка OOM')
wr(os.path.join(S, 'fixsim', 'orch-loop'), loop)

# FIXSIM orch-peak = снимок слияния, три конфликта разрешены объединением намерений (И-1):
# (1) подпись станции + ожидание субагентов 080; (2) Н-189 перед транзакцией 080 (опрос,
# отчёт, state=hard после маркера); (3) подпись станции + PHRASE_OK. Стоп-файл kill_session —
# шов ORCH_LOOP_STOP, создаётся и в шве ORCH_PEAK_TEST (И-4д).
L = rd('slijanie.orch-peak').splitlines(keepends=True)
out, chunks, i = [], [], 0
while i < len(L):
    if L[i].startswith('<<<<<<< '):
        j, ours, theirs = i + 1, [], []
        while not L[j].startswith('======='):
            ours.append(L[j]); j += 1
        j += 1
        while not L[j].startswith('>>>>>>> '):
            theirs.append(L[j]); j += 1
        chunks.append((ours, theirs)); out.append(len(chunks) - 1); i = j + 1
    else:
        out.append(L[i]); i += 1
if len(chunks) != 3:
    raise SystemExit('FIXSIM peak: конфликтных кусков %d, ожидалось 3' % len(chunks))
(o1, t1), (o2, t2), (o3, t3) = chunks
if len(o1) != 1 or len(o3) != 1 or not o2[-1].lstrip().startswith('as_u touch "$MARK"'):
    raise SystemExit('FIXSIM peak: форма конфликтных кусков не та, что в снимке')
r1 = [sub1(o1[0], 'Новых спавнов не начинай; доведи текущий шаг до коммита;',
           'Новых спавнов не начинай; дождись завершения текущих субагентов, затем перезапуск дверью. '
           'Доведи текущий шаг до коммита;', 'FIXSIM peak: конфликт 1')]
r2 = o2[:-1] + [('  ' + l) if l.strip() else l for l in t2] + ['        fi\n']
r3 = [sub1(o3[0], '(scripts/orch_restart.sh). Done пары',
           '(scripts/orch_restart.sh). ' + PHRASE_OK + '. Done пары', 'FIXSIM peak: конфликт 3')]
RES = [r1, r2, r3]
peak = ''.join(''.join(RES[x]) if isinstance(x, int) else x for x in out)
REPDEF = 'REPORT="${ORCH_REPORT:-$UHOME/orch-peak-report.txt}"\n'
LOOPSTOP_DEF = 'LOOP_STOP="${ORCH_LOOP_STOP:-$UHOME/orch-loop.stop}"   # стоп-файл цикла (контракт 085, И-4д)\n'
SEAM_KILLED = "    printf 'killed: %s\\n' \"$pids\" >> \"$ORCH_PEAK_TEST/killed.log\"\n"
peak = sub1(peak, REPDEF, REPDEF + LOOPSTOP_DEF, 'FIXSIM peak: LOOP_STOP')
peak = sub1(peak, LINE_KILLSTOP + '\n',
            '  as_u touch "$LOOP_STOP"   # намеренный останов: цикл не примет его за падение\n',
            'FIXSIM peak: kill_session')
peak = sub1(peak, SEAM_KILLED,
            '    as_u touch "$LOOP_STOP"   # стоп-файл и в шве: шов подменяет только сигналы (И-4д)\n'
            + SEAM_KILLED, 'FIXSIM peak: шов kill_session')
wr(os.path.join(S, 'fixsim', 'orch-peak'), peak)

# STUBS — (id, клетка, метка, основа, [(якорь, замена)]): каждый стаб — к входу, где его
# дефект НАБЛЮДАЕМ (Н-39); основа snap:<снимок> — прежняя версия как есть, loop/peak —
# мутация честной симуляции (якорь обязан встречаться ровно один раз).
SIGN_OP = 'СТОРОЖ СТАНЦИИ (автоматически, orch-peak; это НЕ слово владельца и НЕ разрешение обходить гарды)'
SIGN_CTX = 'СТОРОЖ СТАНЦИИ (автоматически, сторож контекста; это НЕ слово владельца'
STUBS = [
  # р2: потеря станционных починок при установке из репо — строки станции пропали
  ('s01', 'r2', 'прежняя repo-версия цикла fad71b15', 'snap:repo-fad71b15.orch-loop', []),
  # м1: станционный цикл как есть — systemd-run для сессии не вызывается
  ('s02', 'm1', 'станционный цикл ebc53f30 без потолка', 'snap:stancija.orch-loop', []),
  # п1: версия 080 без станционной дельты — маркер против сменившейся сессии (Н-189)
  ('s03', 'p1', 'прежняя repo-версия сторожа 8380d01f', 'snap:repo-8380d01f.orch-peak', []),
  # р1: станционный сторож как есть — строки дельты 080 (шов, опрос, транзакция) пропали
  ('s04', 'r1', 'станционный сторож b3e354cd без дельты 080', 'snap:stancija.orch-peak', []),
  # л1..л8: мутации честного цикла — каждая видна на своём плане
  ('s05', 'l1', 'ранний маркер — останов', 'loop',
   [('[ "$early" -lt "$EARLY_MAX" ] ||', '[ "$early" -lt 1 ] ||')]),
  ('s06', 'l2', 'ранние маркеры не считаются', 'loop',
   [('early=$(( ${ORCH_EARLY:-0} + 1 ));', 'early=1;')]),
  ('s07', 'l3', 'падение без маркера — останов', 'loop',
   [('if [ "$rc" -eq 0 ] || [ -e "$STOP" ]; then', 'if true; then')]),
  ('s08', 'l4', 'падения не считаются', 'loop',
   [('crash=$(( ${ORCH_CRASH:-0} + 1 ));', 'crash=1;')]),
  ('s09', 'l5', 'стоп-файл не снимается', 'loop',
   [('rm -f "$STOP"; log "сессия #$n: завершилась без маркера', 'log "сессия #$n: завершилась без маркера')]),
  ('s10', 'l6', 'снятие маркера в GRACE не перепроверяется', 'loop',
   [('    [ -e "$MARK" ] || { log "сессия #$n: маркер снят за ${GRACE}с — перезапуск отменён"; continue; }\n', '')]),
  ('s11', 'l7', 'принятие перезапуска обратимо', 'loop',
   [('[ -e "$GO" ] && touch "$MARK"\n', '')]),
  ('s12', 'l8', 'каждый маркер считается ранним', 'loop',
   [('if [ "$life" -lt "$MIN_LIFE" ]; then', 'if true; then')]),
  # м1..м4: мутации потолка памяти
  ('s13', 'm1', 'XDG_RUNTIME_DIR не выставлен', 'loop', [(XDG_LINE, '')]),
  ('s14', 'm2', 'потолок зашит 32G мимо ORCH_MEM_MAX', 'loop',
   [('MEM_MAX="${ORCH_MEM_MAX:-32G}"', 'MEM_MAX=32G')]),
  ('s15', 'm3', 'OOM без строки журнала', 'loop', [(OOM_LINE, '')]),
  ('s16', 'm4', 'нет scope — останов цикла', 'loop', [(NOCAP_LINE + DIRECT_LINE, NOCAP_LINE + '  exit 1\n')]),
  ('s17', 'm4', 'нет scope — без строки журнала', 'loop', [(NOCAP_LINE, '  scoped=0\n')]),
  # п1..п11: мутации честного сторожа
  ('s18', 'p2', 'Н-189 отказывает всегда', 'peak',
   [('if [ "$now" != "$sess" ]; then', 'if true; then')]),
  ('s19', 'p3', 'мягкое сообщение без PHRASE_OK', 'peak', [(' ' + PHRASE_OK + '.', '')]),
  ('s20', 'p4', 'пороги 080: мягкий 300K', 'peak',
   [('CTX_SOFT="${ORCH_CTX_SOFT:-500000}"', 'CTX_SOFT="${ORCH_CTX_SOFT:-300000}"')]),
  ('s21', 'p5w', 'warn с подписью ВЛАДЕЛЕЦ', 'peak',
   [("say '" + SIGN_OP + ': через 20 минут', "say 'ВЛАДЕЛЕЦ (автоматически, orch-peak): через 20 минут")]),
  ('s22', 'p5s', 'мягкое сообщение с подписью 080', 'peak',
   [('say "' + SIGN_CTX + '): контекст', 'say "ВЛАДЕЛЕЦ (автоматически, сторож контекста): контекст')]),
  ('s23', 'p5h', 'жёсткое сообщение с подписью 080', 'peak',
   [('say "' + SIGN_CTX + ' и НЕ разрешение обходить гарды): контекст',
     'say "ВЛАДЕЛЕЦ (автоматически, сторож контекста): контекст')]),
  ('s24', 'p5t', 'сообщение отсрочки с подписью базы', 'peak',
   [('say "' + SIGN_OP + ': $why ОТЛОЖЕН', 'say "ВЛАДЕЛЕЦ (автоматически, orch-peak): $why ОТЛОЖЕН')]),
  ('s25', 'p6', 'простой не реализован', 'peak',
   [('if [ "$idle" -ge "$IDLE" ] && [ -z "$sub_live" ] && [ ! -e "$MARK" ]; then', 'if false; then')]),
  ('s26', 'p7', 'окно живого субагента 120 с', 'peak',
   [('SUB_LIVE="${ORCH_SUB_LIVE:-300}"', 'SUB_LIVE="${ORCH_SUB_LIVE:-120}"')]),
  ('s27', 'p8', 'несохранённое не учитывается в простое', 'peak',
   [('      left="$(unsaved)"\n      if [ -z "$left" ]; then\n        o=',
     '      left=""\n      if [ -z "$left" ]; then\n        o=')]),
  ('s28', 'p9', 'IDLE_MAX не считает подряд', 'peak',
   [('[ "$po" = "$o" ] && pc=$((pc + 1)) || pc=1', 'pc=1')]),
  ('s29', 'p10', 'порог простоя 1700 с', 'peak',
   [('IDLE="${ORCH_IDLE:-1800}"', 'IDLE="${ORCH_IDLE:-1700}"')]),
  ('s30', 'p11', 'шов ORCH_LOOP_STOP проигнорирован', 'peak',
   [('LOOP_STOP="${ORCH_LOOP_STOP:-$UHOME/orch-loop.stop}"', 'LOOP_STOP="$UHOME/orch-loop.stop"')]),
]
for sid, cell, label, base, edits in STUBS:
    try:
        text = rd(base[5:]) if base.startswith('snap:') else (loop if base == 'loop' else peak)
        for old, new in edits:
            text = sub1(text, old, new, sid)
        wr(os.path.join(S, 'stubs', sid), text)
        status = 'ok'
    except Exception as e:
        status = 'ERR ' + str(e)
    print('\t'.join([sid, cell, label, status]))
PYEOF
[ -s "$SCRATCH/fixsim/orch-loop" ] && [ -s "$SCRATCH/fixsim/orch-peak" ] \
  || die2 "дефект батареи: честная симуляция не собрана: $(tail -n 3 "$SCRATCH/builder.err" 2>/dev/null)"
[ -s "$SCRATCH/builder.err" ] && die2 "дефект батареи: построитель упал: $(tail -n 1 "$SCRATCH/builder.err")"
for f in "$SCRATCH/fixsim/orch-loop" "$SCRATCH/fixsim/orch-peak"; do
  bash -n "$f" 2>"$SCRATCH/builder.err" || die2 "дефект батареи: честная симуляция не разбирается bash: $(tail -n 1 "$SCRATCH/builder.err")"
done

if [ "$FIXSIM_ON" = 1 ]; then
  SUBJ_LOOP="$SCRATCH/fixsim/orch-loop"; SUBJ_PEAK="$SCRATCH/fixsim/orch-peak"
  SUBJ_DESC='FIXSIM — честная симуляция, собранная из снимков в скратче (А-318)'
else
  SUBJ_LOOP="$OPS_ROOT/ops/server/user/orch-loop"; SUBJ_PEAK="$OPS_ROOT/ops/server/root/orch-peak"
  SUBJ_DESC="$OPS_ROOT @ $(git -C "$OPS_ROOT" rev-parse --short HEAD 2>/dev/null || echo 'не git')"
fi
hash8() { if [ -f "$1" ]; then sha256sum <"$1" | cut -c1-8; else printf 'нет файла'; fi; }

# ── шим systemd-run ────────────────────────────────────────────────────────────
cat >"$SCRATCH/shimbin/systemd-run" <<'SHIMEOF'
#!/usr/bin/env bash
# шим systemd-run батареи 085: журнал вызова (argv через NUL, XDG_RUNTIME_DIR) и режим
# CIKL085_SHIM_MODE: pass — exec команды после первого «--» (тот же процесс, как --scope);
# refuse — отказ rc 1 без исполнения (как «Failed to connect to bus: No medium found»).
d="${CIKL085_SHIM_DIR:?}"
i=1; while [ -e "$d/call.$i" ]; do i=$((i + 1)); done
printf '%s\0' "$@" >"$d/call.$i"
printf '%s' "${XDG_RUNTIME_DIR-<не задан>}" >"$d/xdg.$i"
if [ "${CIKL085_SHIM_MODE:-pass}" = refuse ]; then
  echo 'Failed to connect to bus: No medium found' >&2; exit 1
fi
while [ $# -gt 0 ] && [ "$1" != -- ]; do shift; done
[ $# -gt 0 ] || { echo 'шим systemd-run: нет «--» — вне грамматики 085' >&2; exit 1; }
shift
exec "$@"
SHIMEOF
chmod 755 "$SCRATCH/shimbin/systemd-run"

# ── мир цикла ─────────────────────────────────────────────────────────────────
write_workshop() { # <W>: сессия-подделка — поведение по плану, токен на сессию, счётчик $W/n
  printf 'omp --profile cikl085-%s-%s' "$RUN" "${1##*/}" >"$1/tag"
  cat >"$1/workshop" <<'WSEOF'
#!/usr/bin/env bash
D="$(cd "$(dirname "$0")" && pwd)"; TAG="$(cat "$D/tag")"
n=$(( $(cat "$D/n") + 1 )); echo "$n" >"$D/n"
act="$(sed -n "${n}p" "$D/plan")"
case "$act" in
  early)    ( sleep 1; touch "$D/mark" ) & exec -a "$TAG" sleep 300 ;;
  normal)   ( sleep 8; touch "$D/mark" ) & exec -a "$TAG" sleep 300 ;;
  cancel)   ( sleep 1; touch "$D/mark"; sleep 7; rm -f "$D/mark" ) & exec -a "$TAG" sleep 14 ;;
  termrm)   ( sleep 1; touch "$D/mark" ) &
            exec -a "$TAG" bash -c 'trap "rm -f \"\$1\"; exit 143" TERM; while :; do sleep 0.2; done' _ "$D/mark" ;;
  exit)     sleep 1; exit 0 ;;
  crash)    sleep 1; exit 1 ;;
  stopkill) touch "$D/stop"; sleep 1; exit 143 ;;
  oom)      sleep 1; kill -KILL "$$" ;;
  alloc)    exec -a "$TAG" python3 "$D/alloc.py" "$D/go" ;;
  *)        exit 0 ;;
esac
WSEOF
  chmod 755 "$1/workshop"
}

reap() { # <W>: добить остатки мира клетки (сессии-подделки, наблюдатель, подоболочки)
  local tag; tag="$(cat "$1/tag" 2>/dev/null)"
  [ -n "$tag" ] && pkill -KILL -f "^$tag( |\$)" 2>/dev/null
  pkill -KILL -f "$1/" 2>/dev/null
  return 0
}

loop_prep() { # <субъект> <W> <план>
  mkdir -p "$2/repo" "$2/home" "$2/shim"
  cp -- "$1" "$2/subject-cikl" && chmod 755 "$2/subject-cikl"
  printf '%s\n' $3 >"$2/plan"; echo 0 >"$2/n"
  write_workshop "$2"
}

loop_run() { # <субъект> <W> <план> <таймаут-с> [ИМЯ=ЗНАЧ…] → $W/rc $W/n $W/log $W/out
  local subj="$1" W="$2" plan="$3" tmo="$4"; shift 4
  loop_prep "$subj" "$W" "$plan"
  env -u XDG_RUNTIME_DIR HOME="$W/home" PATH="$SCRATCH/shimbin:$PATH" \
    CIKL085_SHIM_DIR="$W/shim" CIKL085_SHIM_MODE=pass \
    ORCH_REPO="$W/repo" ORCH_WORKSHOP="$W/workshop" ORCH_MARK="$W/mark" ORCH_STOP="$W/stop" \
    ORCH_LOG="$W/log" ORCH_GRACE=1 ORCH_MIN_LIFE=9 ORCH_EARLY_WAIT=1 ORCH_EARLY_MAX=3 \
    "$@" timeout -k 5 "$tmo" bash "$W/subject-cikl" >"$W/out" 2>&1
  echo "$?" >"$W/rc"
  reap "$W"
}

CRASH_RE='syntax error|unbound variable|command not found|unexpected EOF|bad substitution'
loop_crash() { # <W> → rc 0 и печать причины, если субъект не исполнился
  local l
  [ "$(cat "$1/rc")" = 124 ] && { printf 'цикл не завершился за отведённое время (завис)'; return 0; }
  l="$(grep -m1 -E "$CRASH_RE" "$1/out" 2>/dev/null)"
  [ -n "$l" ] && { printf 'авария субъекта: %s' "$l"; return 0; }
  [ -s "$1/log" ] || { printf 'цикл не исполнился: журнал пуст, rc %s' "$(cat "$1/rc")"; return 0; }
  return 1
}
lastlog() { local l; l="$(sed -n '$s/^[^ ]* //p' "$1/log" 2>/dev/null)"; printf '%s' "${l:-—}"; }

# loop_cell <субъект> <W> <план> <таймаут> <сессий> <rc: 0|nz|any> <вход> [ИМЯ=ЗНАЧ…]
loop_cell() {
  local s="$1" W="$2" plan="$3" tmo="$4" wn="$5" wrc="$6" what="$7" a n rc ok=1; shift 7
  loop_run "$s" "$W" "$plan" "$tmo" "$@"
  a="$(loop_crash "$W")" && { printf '%s' "$a"; return 3; }
  n="$(cat "$W/n")"; rc="$(cat "$W/rc")"
  [ "$n" = "$wn" ] || ok=0
  case "$wrc" in 0) [ "$rc" = 0 ] || ok=0 ;; nz) [ "$rc" != 0 ] || ok=0 ;; esac
  if [ "$ok" = 1 ]; then printf '%s → сессий %s, rc %s' "$what" "$n" "$rc"; return 0; fi
  case "$wrc" in 0) wrc='rc 0' ;; nz) wrc='rc ≠ 0' ;; *) wrc='rc любой' ;; esac
  printf '%s → сессий %s, rc %s (ожидалось: сессий %s, %s); журнал: %s' \
    "$what" "$n" "$rc" "$wn" "$wrc" "$(lastlog "$W")"
  return 1
}

cell_l1() { loop_cell "$1" "$2" 'early exit' 40 2 0 '«ранний, выход»'; }
cell_l2() { loop_cell "$1" "$2" 'early early early early' 60 3 nz '«ранний ×4»'; }
cell_l3() {
  local r; loop_cell "$1" "$2" 'crash exit' 30 2 0 '«падение rc 1, выход»'; r=$?
  [ "$r" = 0 ] || return "$r"
  grep -Fq -- "$LIT_OOM" "$2/log" && { printf '; но строка И-5б «%s» при rc 1' "$LIT_OOM"; return 1; }
  printf ', строки И-5б нет'; return 0
}
cell_l4() { loop_cell "$1" "$2" 'crash crash crash crash' 30 3 nz '«падение ×4»'; }
cell_l5() {
  local r; loop_cell "$1" "$2" 'stopkill normal' 30 1 any '«сессия ставит ORCH_STOP и выходит 143»'; r=$?
  [ "$r" = 0 ] || return "$r"
  [ -e "$2/stop" ] && { printf '; но ORCH_STOP не снят'; return 1; }
  printf ', ORCH_STOP снят'; return 0
}
cell_l6() { loop_cell "$1" "$2" 'cancel exit' 40 1 0 '«маркер снят в GRACE, сессия сама выходит 0»' ORCH_GRACE=6 ORCH_MIN_LIFE=2; }
# л7: MIN_LIFE=2 — принятый перезапуск идёт обычной ветвью; EARLY_MAX=1 — падение без маркера
# останавливает цикл, иначе ветвь падения (И-3б) маскирует потерю принятия второй сессией.
cell_l7() { loop_cell "$1" "$2" 'termrm exit' 40 2 any '«на SIGTERM сессия снимает маркер» (MIN_LIFE=2, EARLY_MAX=1)' ORCH_MIN_LIFE=2 ORCH_EARLY_MAX=1; }
cell_l8() { loop_cell "$1" "$2" 'early early normal exit' 70 4 0 '«ранний, ранний, обычный, выход»'; }

# ── потолок памяти (И-5) ──────────────────────────────────────────────────────
has_tok() { local w="$1" t; shift; for t in "$@"; do [ "$t" = "$w" ] && return 0; done; return 1; }
prop_of() { # <ключ> <опции до «--»…> → последнее значение: -p K=V | --property=K=V | --property K=V
  local key="$1" v='' t; shift
  while [ $# -gt 0 ]; do
    t="$1"; shift
    case "$t" in
      -p|--property) [ $# -gt 0 ] || break; t="$1"; shift ;;
      --property=*) t="${t#--property=}" ;;
      *) continue ;;
    esac
    case "$t" in "$key="*) v="${t#"$key="}" ;; esac
  done
  printf '%s' "$v"
}
judge_scope() { # <W> <MemoryMax>: каждый вызов systemd-run, чья команда — workshop сессии
  local W="$1" want="$2" f i idx found=0 calls=0 v xdg want_xdg
  local -a a opts cmd
  want_xdg="/run/user/$(id -u)"
  for f in "$W"/shim/call.*; do
    [ -e "$f" ] || continue
    calls=$((calls + 1))
    mapfile -d '' -t a <"$f"
    idx=-1
    for i in "${!a[@]}"; do [ "${a[$i]}" = -- ] && { idx=$i; break; }; done
    [ "$idx" -ge 0 ] || continue
    cmd=("${a[@]:$((idx + 1))}")
    [ "${cmd[0]:-}" = "$W/workshop" ] || continue
    found=$((found + 1))
    opts=("${a[@]:0:$idx}")
    has_tok --user "${opts[@]}" || { printf 'нет --user до «--»: %s' "${opts[*]}"; return 1; }
    has_tok --scope "${opts[@]}" || { printf 'нет --scope до «--»: %s' "${opts[*]}"; return 1; }
    v="$(prop_of MemoryMax "${opts[@]}")"
    [ "$v" = "$want" ] || { printf 'MemoryMax=%s (ожидалось %s)' "${v:-нет}" "$want"; return 1; }
    v="$(prop_of MemorySwapMax "${opts[@]}")"
    [ "$v" = 0 ] || { printf 'MemorySwapMax=%s (ожидалось 0)' "${v:-нет}"; return 1; }
    if [ "${#cmd[@]}" -ne 4 ] || [ "${cmd[1]}" != --yolo ] || [ "${cmd[2]}" != -- ] || [ "${cmd[3]}" != "$MSG_STATION" ]; then
      printf 'после «--» не вызов workshop станции «"$WORKSHOP" --yolo -- "$MSG"» (слов: %s)' "${#cmd[@]}"
      return 1
    fi
    xdg="$(cat "$W/shim/xdg.${f##*.}")"
    [ "$xdg" = "$want_xdg" ] || { printf 'XDG_RUNTIME_DIR=%s (ожидалось %s)' "$xdg" "$want_xdg"; return 1; }
  done
  [ "$found" -ge 1 ] || { printf 'systemd-run для сессии не вызван (вызовов шима: %s)' "$calls"; return 1; }
  printf 'сессия под systemd-run --user --scope: MemoryMax=%s, MemorySwapMax=0, после «--» — вызов workshop, XDG_RUNTIME_DIR=%s (сессионных вызовов: %s)' "$want" "$want_xdg" "$found"
  return 0
}
cell_m1() {
  local a; loop_run "$1" "$2" 'exit' 20
  a="$(loop_crash "$2")" && { printf '%s' "$a"; return 3; }
  judge_scope "$2" 32G
}
cell_m2() {
  local a; loop_run "$1" "$2" 'exit' 20 ORCH_MEM_MAX=5G
  a="$(loop_crash "$2")" && { printf '%s' "$a"; return 3; }
  judge_scope "$2" 5G
}
cell_m3() {
  local r; loop_cell "$1" "$2" 'oom exit' 30 2 any '«сессия под шимом кончается rc 137»'; r=$?
  [ "$r" = 0 ] || return "$r"
  grep -Fq -- "$LIT_OOM" "$2/log" || { printf '; но строки И-5б «%s» нет' "$LIT_OOM"; return 1; }
  printf ', строка И-5б есть'; return 0
}
cell_m4() {
  local r; loop_cell "$1" "$2" 'exit' 20 1 0 '«шим отказывает rc 1 без исполнения»' CIKL085_SHIM_MODE=refuse; r=$?
  [ "$r" = 0 ] || return "$r"
  grep -Fq -- "$LIT_NOCAP" "$2/log" || { printf '; но строки И-5в «%s» нет' "$LIT_NOCAP"; return 1; }
  printf ', исполнена напрямую, строка И-5в есть'; return 0
}

# м5 — живой systemd-run --user: предусловие снимается один раз, до запуска клеток.
M5_LIVE=0; M5_SKIP=''
m5_probe() {
  local out
  if [ ! -r /sys/fs/cgroup/cgroup.controllers ] || ! command -v systemd-run >/dev/null 2>&1; then
    M5_SKIP='нет systemd-run или cgroup v2 — живой потолок не наблюдаем (вне станции)'; return 0
  fi
  if out="$(XDG_RUNTIME_DIR="/run/user/$(id -u)" systemd-run --user --scope -q -p MemoryMax=64M -p MemorySwapMax=0 -- true 2>&1)"; then
    M5_LIVE=1
  else
    M5_SKIP="живой systemd-run --user --scope недоступен (вне станции): ${out:-rc≠0}"
  fi
  return 0
}
memcap_quiet() { # временный сторож orch-memcap (вне репо, до И-8) раз в минуту переносит
  # «omp --profile» в свою cgroup: м5 стартует не ближе 12 с до его срабатывания
  command -v systemctl >/dev/null 2>&1 || return 0
  local line nx left
  line="$(systemctl list-timers --no-legend orch-memcap.timer 2>/dev/null | head -n 1)"
  [ -n "$line" ] || return 0
  nx="$(date -d "$(printf '%s' "$line" | awk '{print $1, $2, $3, $4}')" +%s 2>/dev/null)" || return 0
  left=$(( nx - $(date +%s) ))
  if [ "$left" -ge 0 ] && [ "$left" -lt 12 ]; then sleep $(( left + 2 )); fi
  return 0
}
cell_m5() { # ORCH_MEM_MAX=64M; сессия, пока жива — в run-*.scope с memory.max; 256 МиБ → rc 137, вторая сессия
  local s="$1" W="$2" uid tp lp='' sp='' cg='' mm='' gocg rc n
  [ "$M5_LIVE" = 1 ] || { printf '%s' "$M5_SKIP"; return 4; }
  uid="$(id -u)"
  memcap_quiet
  loop_prep "$s" "$W" 'alloc exit'
  cat >"$W/alloc.py" <<'ALLOCEOF'
import os, sys, time
go = sys.argv[1]
t0 = time.time()
while not os.path.exists(go):
    if time.time() - t0 > 30:
        sys.exit(5)
    time.sleep(0.05)
with open('/proc/self/cgroup') as f:
    cg = f.read().strip()
with open(go + '.cg', 'w') as f:
    f.write(cg)
b = bytearray(256 * 1024 * 1024)
for i in range(0, len(b), 4096):
    b[i] = 1
time.sleep(1)
ALLOCEOF
  env -u XDG_RUNTIME_DIR HOME="$W/home" \
    ORCH_REPO="$W/repo" ORCH_WORKSHOP="$W/workshop" ORCH_MARK="$W/mark" ORCH_STOP="$W/stop" \
    ORCH_LOG="$W/log" ORCH_GRACE=1 ORCH_MIN_LIFE=2 ORCH_EARLY_WAIT=1 ORCH_EARLY_MAX=3 ORCH_MEM_MAX=64M \
    timeout -k 5 60 bash "$W/subject-cikl" >"$W/out" 2>&1 &
  tp=$!
  for _ in $(seq 1 100); do lp="$(pgrep -P "$tp" | head -n 1)"; [ -n "$lp" ] && break; sleep 0.05; done
  if [ -n "$lp" ]; then
    for _ in $(seq 1 300); do
      sp="$(pgrep -P "$lp" -f '^omp --profile' | head -n 1)"
      [ -n "$sp" ] && break
      kill -0 "$lp" 2>/dev/null || break
      sleep 0.05
    done
  fi
  if [ -n "$sp" ]; then
    cg="$(sed -n 's/^0:://p' "/proc/$sp/cgroup" 2>/dev/null)"
    mm="$(cat "/sys/fs/cgroup$cg/memory.max" 2>/dev/null)"
  fi
  touch "$W/go"
  wait "$tp"; rc=$?
  echo "$rc" >"$W/rc"
  reap "$W"
  [ "$rc" = 124 ] && { printf 'цикл не завершился за 60 с (завис)'; return 3; }
  [ -s "$W/log" ] || { printf 'цикл не исполнился: журнал пуст, rc %s' "$rc"; return 3; }
  [ -n "$sp" ] || { printf "живая сессия не найдена: pgrep -P <цикл> -f '^omp --profile' пуст"; return 1; }
  case "${cg##*/}" in run-*.scope) ;; *) printf 'живая сессия %s в cgroup %s — не run-*.scope' "$sp" "${cg:-?}"; return 1 ;; esac
  case "$cg" in */user@"$uid".service/*) ;; *) printf 'scope %s не под user@%s.service' "$cg" "$uid"; return 1 ;; esac
  [ "$mm" = "$M5_BYTES" ] || { printf 'memory.max %s (ожидалось %s)' "${mm:-?}" "$M5_BYTES"; return 1; }
  gocg="$(cat "$W/go.cg" 2>/dev/null)"
  [ "0::$cg" = "$gocg" ] || { printf 'сессию перенёс сторонний процесс до аллокации (%s → %s) — живой суд сорван' "$cg" "${gocg:-?}"; return 1; }
  grep -Fq -- "$LIT_OOM" "$W/log" || { printf 'строки И-5б «%s» нет (256 МиБ под потолком не убиты rc 137); журнал: %s' "$LIT_OOM" "$(lastlog "$W")"; return 1; }
  n="$(cat "$W/n")"
  [ "$n" = 2 ] || { printf 'сессий %s (ожидалась вторая после OOM)' "$n"; return 1; }
  [ "$rc" = 0 ] || { printf 'цикл кончился rc %s (ожидался 0 после второй сессии)' "$rc"; return 1; }
  printf 'живая сессия %s в %s, memory.max %s; 256 МиБ → OOM, строка И-5б, вторая сессия, rc 0' "$sp" "${cg##*/}" "$mm"
  return 0
}

# ── мир сторожа (шов ORCH_PEAK_TEST 080) ─────────────────────────────────────
peak_world() { # <W> <usage> <возраст-журнала-с> <возраст-субагента-с|-> <несохранённое 0|1>
  local W="$1" usage="$2" age="$3" sub="$4" dirty="$5" now
  now="$(date +%s)"
  mkdir -p "$W/sess" "$W/test" "$W/home"
  printf '{"message":{"usage":{"input":%s,"cacheRead":0,"cacheWrite":0}}}\n' "$usage" >"$W/sess/$PEAK_SESS.jsonl"
  touch -d "@$((now - age))" "$W/sess/$PEAK_SESS.jsonl"
  if [ "$sub" != - ]; then
    mkdir -p "$W/sess/$PEAK_SESS"
    : >"$W/sess/$PEAK_SESS/Sub.jsonl"
    touch -d "@$((now - sub))" "$W/sess/$PEAK_SESS/Sub.jsonl"
  fi
  printf '424242\n' >"$W/test/omp-pids"
  git init -q --bare -b main "$W/origin.git" \
    && git init -q -b main "$W/repo" \
    && printf '## ГДЕ МЫ (toy 085)\n' >"$W/repo/HANDOFF.md" \
    && git -C "$W/repo" add HANDOFF.md \
    && git -C "$W/repo" -c user.name=architect -c user.email=architect@dev-harness.local \
         -c core.hooksPath=/dev/null -c commit.gpgsign=false commit -qm 'toy 085' \
    && git -C "$W/repo" remote add origin "$W/origin.git" \
    && git -C "$W/repo" -c core.hooksPath=/dev/null push -q -u origin main 2>/dev/null \
    || return 1
  [ "$dirty" = 1 ] && printf 'несохранённое\n' >"$W/repo/dirty.txt"
  return 0
}
peak_run() { # <субъект> <W> <команда> [ИМЯ=ЗНАЧ…] → $W/rc, $W/out (дописывается)
  local subj="$1" W="$2" cmd="$3"; shift 3
  cp -- "$subj" "$W/subject-peak"
  ( cd "$W" && env HOME="$W/home" ORCH_USER=nobody ORCH_REPO="$W/repo" ORCH_MARK="$W/mark" \
      ORCH_REPORT="$W/report" ORCH_PEAK_TEST="$W/test" ORCH_SESS_GLOB="$W/sess/*.jsonl" \
      ORCH_TMUX_SOCK="cikl085-nosock-$RUN" ORCH_STATE="$W/state" ORCH_LOG="$W/peak.log" \
      ORCH_LOOP_STOP="$W/loop.stop" ORCH_LOOP_PAT="cikl085-noloop-$RUN" \
      ORCH_PEAK_GRACE=1 ORCH_PEAK_POLL=1 ORCH_HARD_GRACE=2 ORCH_HARD_POLL=1 \
      "$@" timeout -k 3 30 bash "$W/subject-peak" "$cmd" ) >>"$W/out" 2>&1
  echo "$?" >"$W/rc"
}
peak_crash() { # <W> → rc 0 и печать причины, если сторож не исполнился
  local l
  [ "$(cat "$1/rc")" = 124 ] && { printf 'сторож не завершился за 30 с (завис)'; return 0; }
  l="$(grep -m1 -E "$CRASH_RE" "$1/out" 2>/dev/null)"
  [ -n "$l" ] && { printf 'авария субъекта: %s' "$l"; return 0; }
  [ -d "$1/state" ] || { printf 'сторож не исполнился: ORCH_STATE не создан, rc %s' "$(cat "$1/rc")"; return 0; }
  return 1
}
msgs() { if [ -f "$1/test/say.log" ]; then grep -c '' "$1/test/say.log"; else printf '0'; fi; }
mark_of() { if [ -e "$1/mark" ]; then printf 'есть'; else printf 'нет'; fi; }
lastpeak() { local l; l="$(sed -n '$s/^[^ ]* //p' "$1/peak.log" 2>/dev/null)"; printf '%s' "${l:-—}"; }

judge_sign() { # <W>: каждое доставленное сообщение — с подписью И-4в; «ВЛАДЕЛЕЦ (автоматически» — ни в одном
  local W="$1" n=0 line
  [ -s "$W/test/say.log" ] || { printf 'сообщение не доставлено — подпись не наблюдаема'; return 1; }
  while IFS= read -r line || [ -n "$line" ]; do
    n=$((n + 1))
    case "$line" in "$LIT_SIGN"*) ;; *) printf 'сообщение %d не начинается «%s»: %s' "$n" "$LIT_SIGN" "$line"; return 1 ;; esac
    case "$line" in *"$LIT_NOT_OWNER"*) ;; *) printf 'сообщение %d без «%s»' "$n" "$LIT_NOT_OWNER"; return 1 ;; esac
    case "$line" in *"$LIT_OWNER"*) printf 'сообщение %d несёт «%s»' "$n" "$LIT_OWNER"; return 1 ;; esac
  done <"$W/test/say.log"
  printf 'сообщений %d: каждое начинается «%s», несёт «%s», «%s» нет' "$n" "$LIT_SIGN" "$LIT_NOT_OWNER" "$LIT_OWNER"
  return 0
}

cell_p1() { # смена журнала верхнего уровня за отсрочку → маркера нет (Н-189)
  local s="$1" W="$2" a sw
  peak_world "$W" 650000 0 - 1 || { printf 'мир не построен (git)'; return 3; }
  ( for _ in $(seq 1 100); do [ -s "$W/test/say.log" ] && break; sleep 0.1; done
    printf '{"message":{"usage":{"input":5000,"cacheRead":0,"cacheWrite":0}}}\n' >"$W/sess/$PEAK_SESS2.jsonl"
    touch -d "@$(( $(date +%s) + 60 ))" "$W/sess/$PEAK_SESS2.jsonl" ) &
  sw=$!
  peak_run "$s" "$W" ctx ORCH_PEAK_GRACE=3
  wait "$sw" 2>/dev/null
  a="$(peak_crash "$W")" && { printf '%s' "$a"; return 3; }
  [ -s "$W/test/say.log" ] || { printf 'CTX_HARD не принят (сообщение не доставлено) — смена за отсрочку не предъявлена'; return 1; }
  [ -e "$W/mark" ] && { printf 'маркер поставлен против сменившейся сессии (Н-189); журнал: %s' "$(lastpeak "$W")"; return 1; }
  printf 'журнал сменился за отсрочку — маркера нет'; return 0
}
cell_p2() { # без смены за отсрочку → маркер
  local s="$1" W="$2" a
  peak_world "$W" 650000 0 - 1 || { printf 'мир не построен (git)'; return 3; }
  peak_run "$s" "$W" ctx ORCH_PEAK_GRACE=3
  a="$(peak_crash "$W")" && { printf '%s' "$a"; return 3; }
  [ -e "$W/mark" ] && { printf 'та же сессия после отсрочки — маркер поставлен'; return 0; }
  printf 'маркера нет при неизменной сессии; журнал: %s' "$(lastpeak "$W")"; return 1
}
cell_p3() { # usage 550000 без ORCH_CTX_* → одно сообщение с PHRASE_OK, маркера нет
  local s="$1" W="$2" a n
  peak_world "$W" 550000 0 - 0 || { printf 'мир не построен (git)'; return 3; }
  peak_run "$s" "$W" ctx
  a="$(peak_crash "$W")" && { printf '%s' "$a"; return 3; }
  n="$(msgs "$W")"
  [ "$n" = 1 ] || { printf 'доставлено сообщений %s (ожидалось одно), маркер %s' "$n" "$(mark_of "$W")"; return 1; }
  grep -Fq -- "$PHRASE_OK" "$W/test/say.log" || { printf 'сообщение без PHRASE_OK 080 «%s»' "$PHRASE_OK"; return 1; }
  [ -e "$W/mark" ] && { printf 'маркер поставлен при 550000 (CTX_HARD по умолчанию — 600000)'; return 1; }
  printf 'одно сообщение с PHRASE_OK, маркера нет'; return 0
}
cell_p4() { # usage 450000 → сообщений нет
  local s="$1" W="$2" a n
  peak_world "$W" 450000 0 - 0 || { printf 'мир не построен (git)'; return 3; }
  peak_run "$s" "$W" ctx
  a="$(peak_crash "$W")" && { printf '%s' "$a"; return 3; }
  n="$(msgs "$W")"
  [ "$n" = 0 ] || { printf 'доставлено сообщений %s при 450000 (CTX_SOFT по умолчанию — 500000): %s' "$n" "$(head -n 1 "$W/test/say.log")"; return 1; }
  printf 'сообщений нет'; return 0
}
sign_cell() { # <субъект> <W> <usage> <несохранённое> <команда> [ИМЯ=ЗНАЧ…]
  local s="$1" W="$2" usage="$3" dirty="$4" cmd="$5" a; shift 5
  peak_world "$W" "$usage" 0 - "$dirty" || { printf 'мир не построен (git)'; return 3; }
  peak_run "$s" "$W" "$cmd" "$@"
  a="$(peak_crash "$W")" && { printf '%s' "$a"; return 3; }
  judge_sign "$W"
}
cell_p5w() { sign_cell "$1" "$2" 100000 0 warn; }
cell_p5s() { sign_cell "$1" "$2" 550000 0 ctx; }
cell_p5h() { sign_cell "$1" "$2" 650000 1 ctx; }
cell_p5t() { sign_cell "$1" "$2" 100000 1 stop; }
idle_cell() { # <субъект> <W> <молчание-с> <субагент-с|-> <несохранённое> <маркер: 1|0> <вход>
  local s="$1" W="$2" age="$3" sub="$4" dirty="$5" want="$6" what="$7" a got
  peak_world "$W" 100000 "$age" "$sub" "$dirty" || { printf 'мир не построен (git)'; return 3; }
  peak_run "$s" "$W" ctx
  a="$(peak_crash "$W")" && { printf '%s' "$a"; return 3; }
  got=0; [ -e "$W/mark" ] && got=1
  if [ "$got" = "$want" ]; then printf '%s → маркер %s' "$what" "$(mark_of "$W")"; return 0; fi
  printf '%s → маркер %s (ожидался: %s); журнал: %s' "$what" "$(mark_of "$W")" \
    "$([ "$want" = 1 ] && echo есть || echo нет)" "$(lastpeak "$W")"
  return 1
}
cell_p6() { idle_cell "$1" "$2" 1860 - 0 1 'молчание 31 мин, чисто, субагентов нет'; }
cell_p7() { idle_cell "$1" "$2" 1860 200 0 0 'молчание 31 мин + субагент моложе 300 с (200 с)'; }
cell_p8() { idle_cell "$1" "$2" 1860 - 1 0 'молчание 31 мин + незакоммиченное'; }
cell_p10() { idle_cell "$1" "$2" 1740 - 0 0 'молчание 29 мин'; }
cell_p9() { # пять прогонов без движения origin → маркер в 1-3, нет в 4-5
  local s="$1" W="$2" a k seen=''
  peak_world "$W" 100000 1860 - 0 || { printf 'мир не построен (git)'; return 3; }
  for k in 1 2 3 4 5; do
    rm -f "$W/mark"
    peak_run "$s" "$W" ctx
    a="$(peak_crash "$W")" && { printf 'прогон %s: %s' "$k" "$a"; return 3; }
    seen="$seen$([ -e "$W/mark" ] && echo 1 || echo 0)"
  done
  [ "$seen" = 11100 ] && { printf 'пять прогонов → маркер 1-3, нет 4-5'; return 0; }
  printf 'маркер по прогонам 1-5: %s (ожидалось 11100); журнал: %s' "$seen" "$(lastpeak "$W")"; return 1
}
cell_p11() { # stop → ORCH_LOOP_STOP создан, killed.log несёт pid
  local s="$1" W="$2" a
  peak_world "$W" 100000 0 - 0 || { printf 'мир не построен (git)'; return 3; }
  peak_run "$s" "$W" stop
  a="$(peak_crash "$W")" && { printf '%s' "$a"; return 3; }
  grep -Fq 424242 "$W/test/killed.log" 2>/dev/null || { printf 'killed.log без pid 424242 — сессия не гашена'; return 1; }
  [ -e "$W/loop.stop" ] || { printf 'ORCH_LOOP_STOP не создан (killed.log несёт pid)'; return 1; }
  printf 'ORCH_LOOP_STOP создан, killed.log несёт pid'; return 0
}

# ── р1/р2: строки снимка — подпоследовательность строк субъекта ────────────────
subseq() { # <имя-массива-снимка> <файл-субъекта> <строка-исключение> <конфликты: 1 — пропускать куски>
  local -n _snap="$1"; local subj="$2" skip="$3" conf="$4" i j=0 m line in_c=0 cnt=0
  local -a sub
  [ -f "$subj" ] || { printf 'нет файла %s' "$subj"; return 1; }
  mapfile -t sub <"$subj"; m="${#sub[@]}"
  for i in "${!_snap[@]}"; do
    line="${_snap[$i]}"
    if [ "$conf" = 1 ]; then
      case "$line" in '<<<<<<< '*) in_c=1; continue ;; '>>>>>>> '*) in_c=0; continue ;; esac
      [ "$in_c" = 1 ] && continue
    fi
    [ "$line" = "$skip" ] && continue
    while [ "$j" -lt "$m" ] && [ "${sub[$j]}" != "$line" ]; do j=$((j + 1)); done
    [ "$j" -lt "$m" ] || { printf 'пропала строка снимка %d (или нарушен порядок): %s' "$((i + 1))" "$line"; return 1; }
    j=$((j + 1)); cnt=$((cnt + 1))
  done
  [ "$cnt" -gt 0 ] || { printf 'пустая выборка строк снимка'; return 1; }
  printf '%d строк снимка на месте в том же порядке' "$cnt"
  return 0
}
cell_r1() { subseq SNAP_MERGE "$1" "$LINE_KILLSTOP" 1; }
cell_r2() { subseq SNAP_LOOP "$1" "$LINE_LAUNCH" 0; }

# ── исполнение клеток: параллельные задания, результат — в $SCRATCH/res ───────
MAXJ=12; RUNNING=0
spawn() { # <ключ> <клетка> <субъект>
  if [ "$RUNNING" -ge "$MAXJ" ]; then wait -n 2>/dev/null; RUNNING=$((RUNNING - 1)); fi
  ( W="$SCRATCH/w/$1"; mkdir -p "$W"
    "cell_$2" "$3" "$W" >"$SCRATCH/res/$1.msg" 2>"$SCRATCH/res/$1.err"
    echo "$?" >"$SCRATCH/res/$1.rc" ) &
  RUNNING=$((RUNNING + 1))
}
static_job() { # <ключ> <клетка> <субъект> — без фона
  "cell_$2" "$3" >"$SCRATCH/res/$1.msg" 2>"$SCRATCH/res/$1.err"
  echo "$?" >"$SCRATCH/res/$1.rc"
}
res_rc() { cat "$SCRATCH/res/$1.rc" 2>/dev/null || printf '9'; }
res_msg() { cat "$SCRATCH/res/$1.msg" 2>/dev/null; }
subj_for() { case "$1" in r1|p*) printf '%s' "$SUBJ_PEAK" ;; *) printf '%s' "$SUBJ_LOOP" ;; esac; }

printf '085: субъект %s\n' "$SUBJ_DESC"
printf '085: orch-loop %s, orch-peak %s; режим %s\n' "$(hash8 "$SUBJ_LOOP")" "$(hash8 "$SUBJ_PEAK")" "$MODE"

if [ "$MODE" = fast ]; then
  CELLS=(r0 l1 p1 m1)
else
  m5_probe
  CELLS=("${ORDER[@]}")
fi

# Субъект: длинные миры — первыми.
for c in "${CELLS_LOOP[@]}" "${CELLS_MEM[@]}" m5 "${CELLS_PEAK[@]}"; do
  has_tok "$c" "${CELLS[@]}" && spawn "S-$c" "$c" "$(subj_for "$c")"
done

# Стаб-пак и диффпроба (не в fast): стабы — из манифеста построителя, диффпроба —
# FIXSIM на каждом входе, к которому привязан стаб (в режиме FIXSIM=1 — сам субъект).
declare -a STUB_ID=() STUB_CELL=() STUB_LABEL=() STUB_STATUS=() DIFF_CELLS=()
if [ "$MODE" = full ]; then
  while IFS=$'\t' read -r sid scell slabel sstatus; do
    [ -n "$sid" ] || continue
    STUB_ID+=("$sid"); STUB_CELL+=("$scell"); STUB_LABEL+=("$slabel"); STUB_STATUS+=("$sstatus")
    has_tok "$scell" "${DIFF_CELLS[@]}" || DIFF_CELLS+=("$scell")
  done <"$SCRATCH/stubs.tsv"
  for k in "${!STUB_ID[@]}"; do
    sid="${STUB_ID[$k]}"; scell="${STUB_CELL[$k]}"
    [ "${STUB_STATUS[$k]}" = ok ] || continue
    if ! bash -n "$SCRATCH/stubs/$sid" 2>"$SCRATCH/res/$sid.syntax"; then
      STUB_STATUS[$k]="ERR синтаксис: $(tail -n 1 "$SCRATCH/res/$sid.syntax")"; continue
    fi
    case "$scell" in
      r1|r2) static_job "$sid" "$scell" "$SCRATCH/stubs/$sid" ;;
      *) spawn "$sid" "$scell" "$SCRATCH/stubs/$sid" ;;
    esac
  done
  if [ "$FIXSIM_ON" != 1 ]; then
    for c in "${DIFF_CELLS[@]}"; do
      case "$c" in
        r1) static_job "F-$c" r1 "$SCRATCH/fixsim/orch-peak" ;;
        r2) static_job "F-$c" r2 "$SCRATCH/fixsim/orch-loop" ;;
        p*) spawn "F-$c" "$c" "$SCRATCH/fixsim/orch-peak" ;;
        *)  spawn "F-$c" "$c" "$SCRATCH/fixsim/orch-loop" ;;
      esac
    done
  fi
fi

# Статические клетки субъекта — пока идут поведенческие.
if [ "$MODE" = full ]; then
  static_job S-r1 r1 "$SUBJ_PEAK"
  static_job S-r2 r2 "$SUBJ_LOOP"
fi
wait

# ── вердикты субъекта ─────────────────────────────────────────────────────────
printf 'клетки:\n'
for c in "${CELLS[@]}"; do
  if [ "$c" = r0 ]; then say_cell 0 р0 "$R0_MSG"; continue; fi
  say_cell "$(res_rc "S-$c")" "${NAME[$c]}" "$(res_msg "S-$c")"
done

if [ "$MODE" = fast ]; then
  printf 'итог 085 fast: красных=%d\n' "$fails"
  [ "$fails" -eq 0 ] && exit 0
  exit 1
fi

# ── стаб-пак: пойман — только исполненное отклонение на своём входе (А-338) ────
printf 'стаб-пак (Н-39 — привязка к входам в STUBS построителя):\n'
caught=0
for k in "${!STUB_ID[@]}"; do
  sid="${STUB_ID[$k]}"; scell="${STUB_CELL[$k]}"; sn="${NAME[$scell]}"
  if [ "${STUB_STATUS[$k]}" != ok ]; then
    fails=$((fails + 1)); printf '  КРАСНО: стаб %s не построен (%s): %s\n' "$sid" "${STUB_LABEL[$k]}" "${STUB_STATUS[$k]}"
    continue
  fi
  case "$(res_rc "$sid")" in
    1) caught=$((caught + 1)); printf '  стаб %s пойман (вход %s): %s — %s\n' "$sid" "$sn" "${STUB_LABEL[$k]}" "$(res_msg "$sid")" ;;
    0) fails=$((fails + 1)); printf '  КРАСНО: стаб %s жив — %s зелёная на обмане «%s»\n' "$sid" "$sn" "${STUB_LABEL[$k]}" ;;
    *) fails=$((fails + 1)); printf '  КРАСНО: стаб %s не исполнился на входе %s (%s): %s\n' "$sid" "$sn" "${STUB_LABEL[$k]}" "$(res_msg "$sid")" ;;
  esac
done

# ── диффпроба: честная симуляция на каждом входе стаба обязана быть зелёной ────
diffok=0
for c in "${DIFF_CELLS[@]}"; do
  if [ "$FIXSIM_ON" = 1 ]; then key="S-$c"; else key="F-$c"; fi
  if [ "$(res_rc "$key")" = 0 ]; then
    diffok=$((diffok + 1))
  else
    fails=$((fails + 1)); printf '  КРАСНО: диффпроба %s — честная симуляция не зелёная: %s\n' "${NAME[$c]}" "$(res_msg "$key")"
  fi
done
printf 'стаб-пак: %d/%d поймано, диффпроба: %d/%d\n' "$caught" "${#STUB_ID[@]}" "$diffok" "${#DIFF_CELLS[@]}"
[ "${#STUB_ID[@]}" -gt 0 ] && [ "${#DIFF_CELLS[@]}" -gt 0 ] \
  || { fails=$((fails + 1)); printf '  КРАСНО: пустой стаб-пак — различимость клеток не предъявлена\n'; }
printf 'итог 085: красных=%d, стабы=%d/%d, диффпроба=%d/%d\n' "$fails" "$caught" "${#STUB_ID[@]}" "$diffok" "${#DIFF_CELLS[@]}"
[ "$fails" -eq 0 ] && exit 0
exit 1
