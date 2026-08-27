#!/usr/bin/env bash
# НЕ ФИКСТУРА (нет case_-префикса, раннером не гоняется): проба контракта 014 —
# Н-63, боль 1 (конъюнкция: 011-страж in-tree scratch × 012-детерминированный
# default-scratch × TMPDIR-пара проверяющего, 0c23061). Красна СЕЙЧАС (rc=1,
# несовпавшие ветви напечатаны поимённо), зелена после предмета. Ветви привязаны
# к входам раннера по коду (Н-39), не к прозе контракта — по одной на каждый
# способ обмануть выбор базы:
#   н63-зелёный       TMPDIR=корню (честный fake_root, лексическое равенство):
#                     раннер обязан доработать rc=0 — сейчас отказ код 2;
#   охрана-011        ЯВНЫЙ VERIFY_ANTIPLACEBO_SCRATCH=$W/ja-vnutri обязан
#                     остаться отказом код 2 «внутри стерегомого дерева» —
#                     замороженное поведение 011 (ветвь scratchexpl); зелена
#                     и до, и после предмета;
#   детерминизм       два прогона при TMPDIR=корне: скратч жив по предсказанному
#                     /tmp/verify_antiplacebo-<hash8> в ОБОИХ прогонах, под
#                     корнем путей скратча нет;
#   вложенный-tmpdir  TMPDIR=$W/podkatalog (существует, канонически внутри):
#                     запасная база, не лексическое сравнение строк —
#                     лексическая реализация сохраняет отказ код 2;
#   симлинк-внутрь    TMPDIR=$P/alias→$W (лексически ВНЕ корня, канонически
#                     сам корень): обязан отбрасываться к запасной базе;
#   внешний-tmpdir    TMPDIR=$P/vnesh (канонически вне корня): ОСТАЁТСЯ базой
#                     (замороженное 012) — безусловно-/tmp-реализация не
#                     наблюдаема живой по предсказанному пути; зелена и сейчас;
#   алиасы-хеша       корень по прямому имени и по симлинку: ОДИН путь скратча
#                     — hash8 КАНОНИЧЕСКОГО корня; лексический hash даёт два
#                     разных пути на втором прогоне;
#   без-mkdir         TMPDIR=$W/novyj (несуществующий): rc=0 и novyj НЕ
#                     материализован — канонизация без mkdir, «сначала создать,
#                     потом выбрать» ловится отсутствием каталога после прогона;
#   корень-tmp        ROOT=/tmp живым входом (userns + приватный bind подставного
#                     каталога на /tmp; рецепт — замер 2 арбитража 014): rc=2,
#                     ИМЕНОВАННЫЙ отказ «default scratch без запасной базы вне
#                     стерегомого дерева», БЕЗ текста общего стража, подставной
#                     /tmp после прогона не мутирован;
#   tmp-симлинк-      chroot в userns, /tmp — симлинк внутрь стерегомого корня
#   внутрь-корня      (замер 3 арбитража): тот же именованный отказ — запасная
#                     база каноникализирована ТОЙ ЖЕ мерой; литеральный /tmp
#                     просачивается в общий страж с чужим текстом; внутри корня
#                     ничего не создаётся;
#   корень-tmp-транс  ТРАНС-наблюдение ветви 9 (круг 3 критика): итоговый ls
#                     слеп к пути, созданному и удалённому ДО именованного
#                     отказа — стаб transient-create прошёл все прежние
#                     проверки. Монитор создания (mon_start/mon_check) стоит
#                     на стерегомом корне ДО запуска раннера: ни одного
#                     события создания/переноса за весь вызов; созданный
#                     и удалённый путь — то же нарушение инварианта 2.
#                     Живость наблюдателя на ВСЁМ интервале вызова —
#                     терминальным событием (арбитраж 014, вопрос 1):
#                     ПОСЛЕ раннера, ДО mon_stop проба создаёт в корне
#                     маркер .probe014-mark-<метка> и требует его MON-EVENT
#                     петлёй с таймаутом (как MON-READY); зелёное — ровно
#                     один MON-EVENT, и это маркер;
#   tmp-симлинк-транс то же наблюдение на корне chroot-ветви 10.
# Привязка стабов к ветвям — ЗДЕСЬ, по коду пробы (Н-39), не в прозе
# контракта: transient-create (круг 3) красен чужим MON-EVENT на обоих
# транс-наблюдениях; observer-kill (круг 4: pkill монитора после MON-READY,
# затем create+rm) красен недоставкой маркера на обоих транс-наблюдениях.
# Недоступность userns на машине прогона — КРАСНОЕ ветвей 9–10 с именованной
# причиной «userns недоступен» (fail-closed, решение арбитража 014), не skip:
# зелёный, не видевший этих ветвей, — недоказуемое готово. Недоступность
# монитора создания (нет python3, watch не встал) — равным образом КРАСНОЕ
# транс-наблюдений с именованной причиной (fail-closed, не skip).
# Модель угроз (cognitive-only, остаточный риск назван, слово владельца при
# дельте 014): раннер, подделывающий MON-EVENT, и охота за монитором не
# покрыты; уровень угроз = срезание углов, как везде в репо; расширение —
# отдельный контракт по воле владельца.
# НЕ БАРЬЕР: проба приёмки контракта (как probe_* контракта 013), а не барьер
# с красными предъявлениями; запускается напрямую из приёмочного критерия.
# Коды возврата: 0 — предмет есть, 1 — нет.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
RUNNER="$REPO/scripts/verify_antiplacebo.sh"
. "$HERE/_fake_root.sh"

P="$(mktemp -d /tmp/probe014.XXXXXX)" || { printf 'probe014: /tmp недоступен\n' >&2; exit 1; }
cleanup() { [ -n "${PROBE014_KEEP:-}" ] || rm -rf "$P"; }
trap cleanup EXIT

fails=0
okb()   { printf '  ok   (%s) %s\n' "$1" "$2" >&2; }
failb() { printf '  FAIL (%s) %s\n' "$1" "$2" >&2; fails=$((fails + 1)); }

h8() {  # <путь> — hash8 канонического пути (та же мера, что у раннера: cd + pwd -P)
  printf '%s' "$(cd "$1" && pwd -P)" | sha256sum | cut -c1-8
}

# ── монитор создания ВО ВРЕМЯ прогона (транс-наблюдение, круг 3 критика) ──────
# Наблюдатель — ядро inotify из python3-ctypes: событие создания ставится
# в очередь ядра В МОМЕНТ создания, create+rm между опросами не теряется
# (итоговый ls слеп к такому пути; стаб transient-create прошёл 10/10).
# Монитор ходит по каталогам стерегомого корня рекурсивно и обязан встать
# ДО запуска раннера (готовность MON-READY); все его потоки — в $P, не в корне.
PY3="$(command -v python3 || :)"
cat > "$P/mon014.py" <<'PYMON'
import ctypes, os, struct, sys
IN_CREATE, IN_MOVED_TO, IN_ISDIR, IN_Q_OVERFLOW = 0x100, 0x80, 0x40000000, 0x4000
MASK = IN_CREATE | IN_MOVED_TO
root = os.path.realpath(sys.argv[1])
libc = ctypes.CDLL(None, use_errno=True)
fd = libc.inotify_init()
if fd < 0:
    print("MON-ERR init", os.strerror(ctypes.get_errno()), flush=True); sys.exit(2)
watched = {}
def add(path):
    wd = libc.inotify_add_watch(fd, os.fsencode(path), MASK)
    if wd < 0:
        print("MON-ERR add", path, os.strerror(ctypes.get_errno()), flush=True); sys.exit(2)
    watched[wd] = os.path.realpath(path)
for d, dn, fn in os.walk(root):
    add(d)
print("MON-READY", flush=True)
while True:
    data = os.read(fd, 65536)
    i = 0
    while i < len(data):
        wd, mask, cookie, ln = struct.unpack_from("iIII", data, i)
        raw = data[i + 16:i + 16 + ln].split(b"\0")[0]
        i += 16 + ln
        if mask & IN_Q_OVERFLOW:
            print("MON-ERR очередь inotify переполнена — события потеряны", flush=True); sys.exit(2)
        if not mask & MASK:
            continue  # IN_IGNORED и прочие артефакты смерти watch — не создание
        path = os.path.join(watched.get(wd, "?"), os.fsdecode(raw))
        how = "перенос" if mask & IN_MOVED_TO else "создание"
        kind = "каталог" if mask & IN_ISDIR else "путь"
        print("MON-EVENT %s %s %s" % (how, kind, os.path.relpath(path, root)), flush=True)
        if mask & IN_ISDIR:
            add(path)
PYMON

mon_start() {  # <каталог> <метка> — монитор на всё дерево каталога; rc 0 = стоит и готов
  MON_PID=''; MON_EV="$P/$2.events"
  : > "$MON_EV"; : > "$P/$2.err"
  [ -n "$PY3" ] || return 1
  "$PY3" "$P/mon014.py" "$1" > "$MON_EV" 2> "$P/$2.err" < /dev/null & MON_PID=$!
  local i
  for i in $(seq 1 50); do
    grep -q '^MON-READY' "$MON_EV" 2>/dev/null && return 0
    kill -0 "$MON_PID" 2>/dev/null || return 1
    sleep 0.05
  done
  return 1
}

mon_stop() {
  [ -n "${MON_PID:-}" ] || return 0
  kill "$MON_PID" 2>/dev/null
  wait "$MON_PID" 2>/dev/null
  MON_PID=''
}

mon_why() {  # <метка> — причина нестарта монитора одной строкой
  if [ -z "$PY3" ]; then printf 'python3 недоступен'
  elif [ -s "$P/$1.err" ]; then head -1 "$P/$1.err"
  else printf 'таймаут готовности монитора (2.5с)'; fi
}

mon_check() {  # <ветвь> <метка> <rc-старта> <корень> — «созданий внутри корня
  # за прогон нет И наблюдатель жив на всём интервале вызова». Терминальный
  # маркер (арбитраж 014, вопрос 1): ПОСЛЕ раннера, ДО mon_stop проба создаёт
  # маркер в стерегомом корне и требует его MON-EVENT той же петлёй с
  # таймаутом, что и MON-READY. Зелёное — ровно один MON-EVENT, и это маркер.
  # Красное поимённо: (а) rc старта монитора ≠ 0; (б) MON-ERR (включая
  # переполнение очереди); (в) любой чужой MON-EVENT — создание раннера;
  # (г) недоставка маркера — наблюдатель мёртв или канал не доставляет
  # на интервале вызова (fail-closed).
  local br="$1" tag="$2" started="$3" root="$4"
  local mark=".probe014-mark-$tag" i others
  if [ "$started" != 0 ]; then
    failb "$br" "монитор создания не встал — наблюдение во времени непрогоняемо: $(mon_why "$tag") (fail-closed, не skip)"
    return 1
  fi
  : > "$root/$mark"  # терминальное событие живости — тем же каналом наблюдения
  for i in $(seq 1 50); do
    grep -qF "MON-EVENT создание путь $mark" "$MON_EV" && break
    grep -q '^MON-ERR' "$MON_EV" && break
    kill -0 "$MON_PID" 2>/dev/null || break
    sleep 0.05
  done
  if grep -q '^MON-ERR' "$MON_EV"; then
    failb "$br" "канал наблюдения отказал (fail-closed): $(grep '^MON-ERR' "$MON_EV" | head -1)"
    return 1
  fi
  others="$(grep '^MON-EVENT' "$MON_EV" | grep -vF "MON-EVENT создание путь $mark" | tr '\n' ';')"
  if [ -n "$others" ]; then
    failb "$br" "создание внутри стерегомого корня ВО ВРЕМЯ прогона (до/вместо отказа):$others"
    return 1
  fi
  if ! grep -qF "MON-EVENT создание путь $mark" "$MON_EV"; then
    failb "$br" "терминальный маркер $mark не доставлен — наблюдатель мёртв или канал не доставляет на интервале вызова (fail-closed)"
    return 1
  fi
  okb "$br" 'за время прогона ни одного события создания/переноса; терминальный маркер доставлен — наблюдатель жив на всём интервале вызова'
  return 0
}

slow_case() {  # <корень> — медленная честная игрушка: пока спит, скратч раннера жив
  cat > "$1/fixtures/verify_toy/case_dolgoj.sh" <<'CASE'
# ПРИЧИНА: игрушка сломана
set -euo pipefail
sleep 2
mkdir -p "$WORK/scripts"
BARRIER_ROOT="$WORK" "$BARRIER"
touch "$WORK/.slomano"
BARRIER_ROOT="$WORK" "$BARRIER"
CASE
}

run_env() {  # <корень> <лог> <tmpdir> [явный-scratch] — env пары проверяющего
  local root="$1" log="$2" td="$3" expl="${4:-}"
  if [ -n "$expl" ]; then
    env -i PATH="$PATH" HOME="$root/home" LC_ALL=C.UTF-8 TMPDIR="$td" \
      VERIFY_ANTIPLACEBO_SCRATCH="$expl" bash "$RUNNER" "$root" > "$log" 2>&1
  else
    env -i PATH="$PATH" HOME="$root/home" LC_ALL=C.UTF-8 TMPDIR="$td" \
      bash "$RUNNER" "$root" > "$log" 2>&1
  fi
}

obs_env() {  # <метка> <корень> <tmpdir> <предсказанный-скратч> — «<rc> <seen> <нарушения>»
  local tag="$1" root="$2" td="$3" pred="$4"
  local log="$P/$tag.out" seen=0 viol='' pid rc e
  run_env "$root" "$log" "$td" & pid=$!
  while kill -0 "$pid" 2>/dev/null; do
    for e in "$root"/verify_antiplacebo-* "$root"/*/verify_antiplacebo-*; do
      [ -e "$e" ] && viol="$viol ${e##*/}"
    done
    [ -e "$pred/verify_antiplacebo-${pred##*-}.lock" ] && seen=1
    sleep 0.05
  done
  wait "$pid"; rc=$?
  printf '%s %s %s\n' "$rc" "$seen" "${viol:-none}"
}

obs_check() {  # <ветвь> <метка> <вывод-obs_env> <предсказанный-путь> — сверка тройки
  local br="$1" tag="$2" out="$3" pred="$4"
  local rc r s v
  rc="${out%% *}"; r="${out#* }"; s="${r%% *}"; v="${r#* }"
  [ "$rc" = 0 ] || { failb "$br" "ожидался rc=0, получено rc=$rc: $(head -1 "$P/$tag.out" 2>/dev/null)"; return 1; }
  [ "$s" = 1 ] || { failb "$br" "скратч не наблюдается живым по предсказанному пути $pred (seen=$s)"; return 1; }
  [ "$v" = none ] || { failb "$br" "под стерегомым корнем появились пути скратча:$v"; return 1; }
  okb "$br" "rc=0, скратч жив по предсказанному пути $pred, дерево чисто"
}

# ── ветвь 1: зелёный контроль сценария Н-63 (лексическое равенство) ───────────
W1="$P/root1"; mkdir -p "$W1/home"
fake_root "$W1"
run_env "$W1" "$P/l1.out" "$W1"; rc1=$?
if [ "$rc1" = 0 ] && ! grep -q 'ОТКАЗ' "$P/l1.out"; then
  okb н63-зелёный 'раннер доработал до rc=0 при TMPDIR, равном корню'
else
  failb н63-зелёный "ожидались rc=0 без отказов, получено rc=$rc1: $(head -1 "$P/l1.out")"
fi

# ── ветвь 2: охрана замороженного поведения 011 (явный in-tree scratch) ───────
W2="$P/root2"; mkdir -p "$W2/home"
fake_root "$W2"
run_env "$W2" "$P/l2.out" "$W2" "$W2/ja-vnutri"; rc2=$?
if [ "$rc2" = 2 ] && grep -q 'внутри стерегомого дерева' "$P/l2.out"; then
  okb охрана-011 'явный in-tree scratch остался отказом код 2 «внутри стерегомого дерева»'
else
  failb охрана-011 "ожидались rc=2 и «внутри стерегомого дерева», получено rc=$rc2: $(head -1 "$P/l2.out")"
fi

# ── ветвь 3: детерминизм default-скратча при TMPDIR=корне ─────────────────────
W3="$P/root3"; mkdir -p "$W3/home"
fake_root "$W3"; slow_case "$W3"
PRED3="/tmp/verify_antiplacebo-$(h8 "$W3")"
rm -rf "$PRED3"  # хеш уникален этому запуску (корень — свежий mktemp): мусор убитого
                 # прогона не должен изображать наблюдение
obs_check детерминизм l3a "$(obs_env l3a "$W3" "$W3" "$PRED3")" "$PRED3" || :
obs_check детерминизм l3b "$(obs_env l3b "$W3" "$W3" "$PRED3")" "$PRED3" || :

# ── ветвь 4: вложенный TMPDIR (существует, канонически внутри корня) ──────────
W4="$P/root4"; mkdir -p "$W4/home"
fake_root "$W4"; slow_case "$W4"; mkdir -p "$W4/podkatalog"
PRED4="/tmp/verify_antiplacebo-$(h8 "$W4")"
rm -rf "$PRED4"
obs_check вложенный-tmpdir l4 "$(obs_env l4 "$W4" "$W4/podkatalog" "$PRED4")" "$PRED4" || :
[ -e "$W4/podkatalog/verify_antiplacebo-$(h8 "$W4")" ] \
  && failb вложенный-tmpdir 'скратч возник внутри корня под TMPDIR-базой (podkatalog)'

# ── ветвь 5: симлинк-внутрь (лексически вне корня, канонически — корень) ──────
W5="$P/root5"; mkdir -p "$W5/home"
fake_root "$W5"; slow_case "$W5"; ln -s "$W5" "$P/alias5"
PRED5="/tmp/verify_antiplacebo-$(h8 "$W5")"
rm -rf "$PRED5"
obs_check симлинк-внутрь l5 "$(obs_env l5 "$W5" "$P/alias5" "$PRED5")" "$PRED5" || :

# ── ветвь 6: внешний TMPDIR остаётся базой (охрана замороженного 012) ─────────
W6="$P/root6"; mkdir -p "$W6/home"
fake_root "$W6"; slow_case "$W6"; T6="$P/vnesh6"; mkdir -p "$T6"
PRED6="$T6/verify_antiplacebo-$(h8 "$W6")"
rm -rf "$PRED6"
obs_check внешний-tmpdir l6 "$(obs_env l6 "$W6" "$T6" "$PRED6")" "$PRED6" || :

# ── ветвь 7: алиасы одного корня дают ОДИН путь (hash8 канонического) ─────────
W7="$P/root7"; mkdir -p "$W7/home"
fake_root "$W7"; slow_case "$W7"; ln -s "$W7" "$P/al7"
PRED7="/tmp/verify_antiplacebo-$(h8 "$W7")"
rm -rf "$PRED7"
obs_check алиасы-хеша l7a "$(obs_env l7a "$W7" "$W7" "$PRED7")" "$PRED7" || :
obs_check алиасы-хеша l7b "$(obs_env l7b "$P/al7" "$P/al7" "$PRED7")" "$PRED7" || :

# ── ветвь 8: несуществующая база не материализуется (канонизация без mkdir) ───
W8="$P/root8"; mkdir -p "$W8/home"
fake_root "$W8"; slow_case "$W8"
PRED8="/tmp/verify_antiplacebo-$(h8 "$W8")"
rm -rf "$PRED8"
obs_check без-mkdir l8 "$(obs_env l8 "$W8" "$W8/novyj" "$PRED8")" "$PRED8" || :
[ -e "$W8/novyj" ] \
  && failb без-mkdir 'несуществующий TMPDIR материализовался в стерегомом дереве (mkdir до выбора)'


# ── ветвь 9: корень-tmp — именованный отказ инварианта 2 живым входом ────────
# Рецепт — замер 2 арбитража 014 (verdicts/arbitration/kontrakt-014-koren-tmp.md):
# userns + приватный bind подставного каталога на /tmp; общий /tmp не мутируется
# по построению (ns схлопывается вместе с монтированием), сверка изнутри достаточна.
if unshare --map-root-user --mount true 2>/dev/null; then
  B9="$(mktemp -d /dev/shm/probe014-v9.XXXXXX)" || B9=''
  if [ -n "$B9" ]; then
    mkdir -p "$B9/scripts"; cp "$RUNNER" "$B9/scripts/verify_antiplacebo.sh"
    mon_start "$B9" m9; mon9=$?
    unshare --map-root-user --mount bash -c '
      mount --bind "$0" /tmp || exit 9
      env -i PATH=/usr/bin:/bin HOME=/root TMPDIR=/tmp bash /tmp/scripts/verify_antiplacebo.sh /tmp
    ' "$B9" > "$P/l9.out" 2>&1; rc9=$?
    d9=''
    [ "$rc9" = 2 ] || d9="ожидался rc=2, получено rc=$rc9"
    grep -q 'default scratch без запасной базы вне стерегомого дерева' "$P/l9.out" \
      || d9="${d9:+$d9; }нет именованного текста инварианта 2"
    grep -q 'явный scratch внутри стерегомого дерева' "$P/l9.out" \
      && d9="${d9:+$d9; }общий страж вместо именованного отказа"
    if [ -n "$d9" ]; then
      failb корень-tmp "$d9 — $(head -1 "$P/l9.out" 2>/dev/null)"
    else
      okb корень-tmp 'rc=2, именованный отказ инварианта 2, подставной /tmp чист'
    fi
    mon_check корень-tmp-транс m9 $mon9 "$B9" || :
    mon_stop
    rm -rf "$B9"
  else
    failb корень-tmp '/dev/shm недоступен — нет носителя для подставного /tmp (fail-closed)'
    failb корень-tmp-транс '/dev/shm недоступен — прогон не состоялся (fail-closed)'
  fi
else
  failb корень-tmp 'userns недоступен — живой вход корень=/tmp непрогоняем (fail-closed, не skip)'
  failb корень-tmp-транс 'userns недоступен — транс-наблюдение непрогоняемо (fail-closed, не skip)'
fi

# ── ветвь 10: tmp-симлинк-внутрь-корня — запасная база каноникализирована ────
# Рецепт — замер 3 арбитража 014: chroot в том же userns, /tmp — симлинк внутрь
# стерегомого корня; /usr+/proc rbind, /dev/null и /dev/fd — вход в живую систему,
# lib64/lib/bin/sbin — ELF-загрузчик. Наблюдение: тот же именованный отказ
# инварианта 2; литеральный /tmp уходит в общий страж с чужим текстом.
if unshare --map-root-user --mount true 2>/dev/null; then
  N10="$P/chroot10"
  mkdir -p "$N10/work/root/scripts" "$N10/usr" "$N10/proc" "$N10/dev"
  cp "$RUNNER" "$N10/work/root/scripts/verify_antiplacebo.sh"
  ln -s work/root "$N10/tmp"
  ln -s /proc/self/fd "$N10/dev/fd"; touch "$N10/dev/null"
  ln -s usr/lib64 "$N10/lib64"; ln -s usr/lib "$N10/lib"
  ln -s usr/bin "$N10/bin"; ln -s usr/sbin "$N10/sbin"
  mon_start "$N10/work/root" m10; mon10=$?
  unshare --map-root-user --mount bash -c '
    mount --rbind /usr "$0/usr" && mount --rbind /proc "$0/proc" &&
    mount --bind /dev/null "$0/dev/null" &&
    chroot "$0" /usr/bin/env -i PATH=/usr/bin:/bin HOME=/ bash /work/root/scripts/verify_antiplacebo.sh /work/root
  ' "$N10" > "$P/l10.out" 2>&1; rc10=$?
  d10=''
  [ "$rc10" = 2 ] || d10="ожидался rc=2, получено rc=$rc10"
  grep -q 'default scratch без запасной базы вне стерегомого дерева' "$P/l10.out" \
    || d10="${d10:+$d10; }нет именованного текста инварианта 2"
  grep -q 'явный scratch внутри стерегомого дерева' "$P/l10.out" \
    && d10="${d10:+$d10; }общий страж вместо именованного отказа (литеральный /tmp?)"
  [ "$(ls -A "$N10/work/root")" = scripts ] \
    || d10="${d10:+$d10; }внутри стерегомого корня создано: $(ls -A "$N10/work/root" | tr '\n' ' ')"
  if [ -n "$d10" ]; then
    failb tmp-симлинк-внутрь-корня "$d10 — $(head -1 "$P/l10.out" 2>/dev/null)"
  else
    okb tmp-симлинк-внутрь-корня 'rc=2, именованный отказ, запасная база канонична'
  fi
  mon_check tmp-симлинк-транс m10 $mon10 "$N10/work/root" || :
  mon_stop
else
  failb tmp-симлинк-внутрь-корня 'userns недоступен — живой вход /tmp-симлинк непрогоняем (fail-closed, не skip)'
  failb tmp-симлинк-транс 'userns недоступен — транс-наблюдение непрогоняемо (fail-closed, не skip)'
fi

[ "$fails" = 0 ] || { printf 'probe_tmpdir_raven_koren: расхождений: %d\n' "$fails" >&2; exit 1; }
exit 0
