#!/usr/bin/env bash
# НЕ ФИКСТУРА (нет case_-префикса, раннером не гоняется): проба контракта 017 —
# срез 5 (А-19): наблюдаемость отказа раннера. Красна СЕЙЧАС (rc=1), зелена после
# предмета. Ветви привязаны к входам раннера по коду (Н-39), не к прозе контракта:
#   хранит   прогон с fails>0: игрушечный корень, у ЧЕСТНОЙ фикстуры positive-control
#            сломан заранее лежащим .slomano в её $WORK (первый вызов барьера красен
#            → «нет положительного контроля», rc=1). RUN-каталог $SCRATCH/run-<pid>
#            обязан ПЕРЕЖИТЬ прогон с непустым invocations.log: сообщение
#            «прогон оставлен в …» (verify_antiplacebo.sh:727) становится правдой,
#            die-причина барьера диагностируема. Сейчас release() (:441-452) стирает
#            $RUN безусловно — сообщение врёт, улика уничтожается (frontier-045 §0.1:
#            локальная репродукция флейка 1/24 осталась без диагноза именно поэтому);
#   убирает  зелёный контроль: rc=0 (чистый игрушечный корень) — run-* под скратчем
#            НЕ остаётся; зелена и до, и после предмета: правка хранит RUN ТОЛЬКО при
#            fails>0, вечно живые каталоги — течка (замер райдера (ii) контракта 012).
# Стартовая чистка раннера (уборка мёртвых run-*) не судится пробой — её предмет
# чужие прогоны, здесь прогон один и живой.
# НЕ БАРЬЕР: проба приёмки контракта (как probe_* контрактов 013/014/016); запускается
# напрямую из приёмочного критерия. Коды возврата: 0 — предмет есть, 1 — нет.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
RUNNER="$REPO/scripts/verify_antiplacebo.sh"
. "$HERE/_fake_root.sh"

P="$(mktemp -d "${TMPDIR:-/tmp}/probe017.XXXXXX")" || { printf 'probe017: нет базы временных\n' >&2; exit 1; }
cleanup() { rm -rf "$P"; }
trap cleanup EXIT
mkdir -p "$P/td"

fails=0
okb()   { printf '  ok   (%s) %s\n' "$1" "$2" >&2; }
failb() { printf '  FAIL (%s) %s\n' "$1" "$2" >&2; fails=$((fails + 1)); }

run_toy() {  # <корень> <лог> <скратч> — прогон раннера на игрушечном корне, env пары
  env -i PATH="$PATH" HOME="$1/home" LC_ALL=C.UTF-8 TMPDIR="$P/td" \
    VERIFY_ANTIPLACEBO_SCRATCH="$3" bash "$RUNNER" "$1" > "$2" 2>&1
}

# ── хранит: RUN-каталог переживает отказ (КРАСНОЕ сейчас) ─────────────────────
W1="$P/root1"; mkdir -p "$W1/home"
fake_root "$W1"
# Фикстура «сразу красная»: .slomano лежит в $WORK ДО первого вызова барьера —
# positive control отсутствует, раннер обязан дать rc=1 поимённой ветвью.
cat > "$W1/fixtures/verify_toy/case_krasnyj_srazu.sh" <<'CASE'
# ПРИЧИНА: игрушка сломана
set -euo pipefail
mkdir -p "$WORK/scripts"
touch "$WORK/.slomano"
BARRIER_ROOT="$WORK" "$BARRIER"
CASE
run_toy "$W1" "$P/l1.out" "$P/skr1"; rc1=$?
run_dirs1="$(find "$P/skr1" -maxdepth 1 -type d -name 'run-*' 2>/dev/null | sort)"
if [ "$rc1" != 1 ]; then
  failb хранит "ожидался rc=1 (positive control сломан), получен rc=$rc1: $(head -1 "$P/l1.out")"
elif ! grep -q 'нет положительного контроля' "$P/l1.out"; then
  failb хранит "rc=1 без подписи «нет положительного контроля» — прогон упал не тем предметом: $(head -1 "$P/l1.out")"
elif [ -z "$run_dirs1" ]; then
  failb хранит 'RUN-каталог уничтожен при fails>0 — «прогон оставлен в …» врёт, die-причина барьера не диагностируема (А-19)'
elif [ -z "$(find $run_dirs1 -type f -name invocations.log -size +0 2>/dev/null)" ]; then
  failb хранит 'RUN-каталог выжил, но непустого invocations.log в нём нет — улика не сохранена'
else
  okb хранит "rc=1, RUN пережил отказ ($(printf '%s ' $run_dirs1)) с непустым invocations.log — отказ диагностируем"
fi

# ── убирает: зелёный прогон RUN не копит (зелёное и до, и после предмета) ──────
W2="$P/root2"; mkdir -p "$W2/home"
fake_root "$W2"
run_toy "$W2" "$P/l2.out" "$P/skr2"; rc2=$?
left2="$(find "$P/skr2" -maxdepth 1 -type d -name 'run-*' 2>/dev/null | sort)"
if [ "$rc2" != 0 ]; then
  failb убирает "чистый игрушечный корень дал rc=$rc2 (ожидался 0): $(head -1 "$P/l2.out")"
elif [ -n "$left2" ]; then
  failb убирает "при rc=0 под скратчем остались run-каталоги: $left2"
else
  okb убирает 'rc=0 и run-каталогов не осталось — хранение RUN только при fails>0, не вечно'
fi

[ "$fails" -eq 0 ] || exit 1
exit 0
