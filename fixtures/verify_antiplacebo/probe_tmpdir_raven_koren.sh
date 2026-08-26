#!/usr/bin/env bash
# НЕ ФИКСТУРА (нет case_-префикса, раннером не гоняется): проба контракта 014 —
# Н-63, боль 1 (конъюнкция: 011-страж in-tree scratch × 012-детерминированный
# default-scratch × TMPDIR-пара проверяющего, 0c23061). Красна СЕЙЧАС (rc=1,
# несовпавшие ветви напечатаны поимённо), зелёна после предмета. Ветви привязаны
# к входам раннера по коду (Н-39), не к прозе контракта:
#   н63-зелёный   раннер на ЧЕСТНОМ подставном корне W при env TMPDIR=W обязан
#                 доработать до rc=0 — сейчас отказ код 2 «внутри стерегомого
#                 дерева» на каждом запуске (22 мета-фикстуры красны тем же);
#   охрана-011    ЯВНЫЙ VERIFY_ANTIPLACEBO_SCRATCH=$W/ja-vnutri (в дереве) обязан
#                 остаться отказом код 2 «внутри стерегомого дерева» — замороженное
#                 поведение 011 (ветвь scratchexpl); зелёна и до, и после предмета;
#   детерминизм   два прогона при TMPDIR=W: скратч наблюдается ЖИВЫМ (lock на месте)
#                 по предсказанному пути /tmp/verify-antiplacebo-<hash8(W)> в ОБОИХ
#                 прогонах (одинаковый корень → одинаковый путь, райдер 012), под W
#                 путей verify-antiplacebo-* не появляется (default ушёл из дерева).
# НЕ БАРЬЕР: проба приёмки контракта (как probe_* контракта 013), а не барьер
# с красными предъявлениями; запускается напрямую из приёмочного критерия.
# Коды возврата: 0 — предмет есть, 1 — нет.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
RUNNER="$REPO/scripts/verify_antiplacebo.sh"
. "$HERE/_fake_root.sh"

P="$(mktemp -d /tmp/probe014.XXXXXX)" || { printf 'probe014: /tmp недоступен\n' >&2; exit 1; }
cleanup() { rm -rf "$P"; }
trap cleanup EXIT

fails=0
okb()   { printf '  ok   (%s) %s\n' "$1" "$2" >&2; }
failb() { printf '  FAIL (%s) %s\n' "$1" "$2" >&2; fails=$((fails + 1)); }

run_runner() {  # <корень> <лог> [явный-scratch] — env пары проверяющего, TMPDIR=корень
  local root="$1" log="$2" expl="${3:-}"
  if [ -n "$expl" ]; then
    env -i PATH="$PATH" HOME="$root/home" LC_ALL=C.UTF-8 TMPDIR="$root" \
      VERIFY_ANTIPLACEBO_SCRATCH="$expl" bash "$RUNNER" "$root" > "$log" 2>&1
  else
    env -i PATH="$PATH" HOME="$root/home" LC_ALL=C.UTF-8 TMPDIR="$root" \
      bash "$RUNNER" "$root" > "$log" 2>&1
  fi
}

# ── ветвь 1: зелёный контроль сценария Н-63 ────────────────────────────────────
W1="$P/root1"; mkdir -p "$W1/home"
fake_root "$W1"
run_runner "$W1" "$P/l1.out"; rc1=$?
if [ "$rc1" = 0 ] && ! grep -q 'ОТКАЗ' "$P/l1.out"; then
  okb н63-зелёный 'раннер доработал до rc=0 при TMPDIR, равном корню'
else
  failb н63-зелёный "ожидались rc=0 без отказов, получено rc=$rc1: $(head -1 "$P/l1.out")"
fi

# ── ветвь 2: охрана замороженного поведения 011 (явный in-tree scratch) ────────
W2="$P/root2"; mkdir -p "$W2/home"
fake_root "$W2"
run_runner "$W2" "$P/l2.out" "$W2/ja-vnutri"; rc2=$?
if [ "$rc2" = 2 ] && grep -q 'внутри стерегомого дерева' "$P/l2.out"; then
  okb охрана-011 'явный in-tree scratch остался отказом код 2 «внутри стерегомого дерева»'
else
  failb охрана-011 "ожидались rc=2 и «внутри стерегомого дерева», получено rc=$rc2: $(head -1 "$P/l2.out")"
fi

# ── ветвь 3: детерминизм default-скратча и уход из дерева при TMPDIR=корне ─────
W3="$P/root3"; mkdir -p "$W3/home"
fake_root "$W3"
# Честная медленная фикстура-игрушка: пока она спит, скратч раннера жив — наблюдаем.
cat > "$W3/fixtures/verify_toy/case_dolgoj.sh" <<'CASE'
# ПРИЧИНА: игрушка сломана
set -euo pipefail
sleep 2
mkdir -p "$WORK/scripts"
BARRIER_ROOT="$WORK" "$BARRIER"
touch "$WORK/.slomano"
BARRIER_ROOT="$WORK" "$BARRIER"
CASE
# Предсказание — та же формула, что в раннере: hash8 канонического корня (cd+pwd),
# запасная база /tmp (инвариант 1 контракта 014), имя райдера 012 не менялось.
H="$(printf '%s' "$(cd "$W3" && pwd)" | sha256sum | cut -c1-8)"
PRED="/tmp/verify-antiplacebo-$H"
rm -rf "$PRED"  # хеш уникален этому запуску (корень — свежий mktemp): мусор убитого
                # прогона не должен изображать наблюдение

obs_run() {  # <n> — прогон №n с наблюдением; печатает "<rc> <seen> <нарушения>"
  local n="$1"
  local log="$P/l3-$n.out"
  local seen=0 viol='' pid rc e
  run_runner "$W3" "$log" & pid=$!
  while kill -0 "$pid" 2>/dev/null; do
    for e in "$W3"/verify-antiplacebo-*; do [ -e "$e" ] && viol="$viol ${e##*/}"; done
    [ -e "$PRED/verify_antiplacebo-$H.lock" ] && seen=1
    sleep 0.05
  done
  wait "$pid"; rc=$?
  printf '%s %s %s\n' "$rc" "$seen" "${viol:-none}"
}

o1="$(obs_run 1)"; o2="$(obs_run 2)"
f1_a=${o1%% *}; r=${o1#* }; s1=${r%% *}; v1=${r#* }
f1_b=${o2%% *}; r=${o2#* }; s2=${r%% *}; v2=${r#* }
d3=0
[ "$f1_a" = 0 ] && [ "$f1_b" = 0 ] \
  || { failb детерминизм "прогоны при TMPDIR=корне упали (rc=$f1_a/$f1_b): $(head -1 "$P/l3-1.out")"; d3=1; }
[ "$s1" = 1 ] && [ "$s2" = 1 ] \
  || { failb детерминизм "скратч не наблюдается живым по предсказанному пути $PRED (seen=$s1/$s2) — default обязан уходить на /tmp/verify-antiplacebo-<hash8> тем же именем"; d3=1; }
[ "$v1" = none ] && [ "$v2" = none ] \
  || { failb детерминизм "под стерегомым корнем появились пути скратча:$v1$v2"; d3=1; }
[ "$fails" = 0 ] || { printf 'probe_tmpdir_raven_koren: расхождений: %d\n' "$fails" >&2; exit 1; }
exit 0
