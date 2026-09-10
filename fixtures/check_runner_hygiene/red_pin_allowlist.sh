#!/usr/bin/env bash
# КРАСНОЕ 025-И-5 (пачка C): пин worktree из строки WORKTREE= задания +
# ALLOWLIST записи (Г3 дословно): пинн ∪ ${TMPDIR}/dev-harness-verify ∪
# artifact:// и внутренние URI; чтение свободно; запись абсолютным путём
# вне пина → блок; несуществующий пинн → именованный отказ; пинн обязан
# КАНОНИЗИРОВАТЬСЯ (realpath: симлинки и «..» нейтрализованы ДО сравнения) и
# СВЕРЯТЬСЯ с фактическим рабочим деревом сессии (поле actual; расхождение →
# именованный отказ) — вердикт 72049b0, блокер 4.
# СУБЪЕКТ: пин-ветвь .omp/extensions/path-guard.ts (тот же judge-протокол,
# что И-1). СЕГОДНЯ: модуль отсутствует → rc 1 именованный. ПОСЛЕ: rc 0.
#
# АНТИ-ПЛАЦЕБО (блокер 4): декои «лексический allowlist без realpath» умирают
# на симлинк-входе (4) и на «..»-входе (3); декой «пин без проверки
# существования» умирает на несуществующем пине (5); декой «пин без сверки с
# фактическим деревом» умирает на расхождении worktree/actual (9); декой
# «пин без allowlist Г3» умирает на записи улик в dev-harness-verify (6).
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
SUBJ="$ROOT/.omp/extensions/path-guard.ts"

if [ ! -f "$SUBJ" ]; then
  printf 'КРАСНОЕ 025-И-5: механизм отсутствует — %s не существует; запись абсолютным путём в основной чекаут из спавн-сессии не стережётся (следствие А-72 не ловится)\n' "$SUBJ" >&2
  exit 1
fi

PIN="$(mktemp -d "${TMPDIR:-/tmp}/pg025pin.XXXXXX")"
FOREIGN="$(mktemp -d "${TMPDIR:-/tmp}/pg025chuzoj.XXXXXX")"
SYM="$PIN-symlink-$RANDOM"
VERIFY_BASE="${TMPDIR:-/tmp}/dev-harness-verify"
mkdir -p "$VERIFY_BASE"
VERIFY_DIR="$(mktemp -d "$VERIFY_BASE/025-verify.XXXXXX")"
GHOST="$PIN/ghost-$RANDOM"
ln -s "$PIN" "$SYM"
trap 'rm -rf "$PIN" "$FOREIGN" "$VERIFY_DIR" "$SYM"' EXIT
F="f_$RANDOM.txt"

fail() {  # <ветвь> <детали>
  printf 'КРАСНОЕ 025-И-5: ветвь «%s» — %s\n' "$1" "$2" >&2
  exit 1
}

# expect <ветвь> <block|pass|refuse> <подстрока reason (пусто = не проверять)> <json>
expect() {
  local vetka="$1" want="$2" substr="$3" evt="$4" out rc dec
  out="$(node "$SUBJ" --judge "$evt")"; rc=$?
  if [ "$rc" -ne 0 ]; then
    fail "$vetka" "субъект не ответил решением (rc $rc, вывод: ${out:-<пусто>}) — декой/сломанный модуль"
  fi
  dec="$(printf '%s' "$out" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{const j=JSON.parse(s);console.log(j.decision??"")}catch(e){console.log("BAD_JSON")}})')"
  if [ -z "$dec" ] || [ "$dec" = "BAD_JSON" ]; then
    fail "$vetka" "субъект не ответил решением-JSON (вывод: ${out:-<пусто>})"
fi
  if [ "$dec" != "$want" ]; then
    fail "$vetka" "ожидалось $want, получено $dec (вывод: $out)"
  fi
  if [ -n "$substr" ]; then
    case "$out" in
      *"$substr"*) ;;
      *) fail "$vetka" "reason без «$substr»: $out" ;;
    esac
  fi
}

# 1-2: границы пина
expect "запись-в-пинне"                pass   ""            "{\"tool\":\"write\",\"args\":{\"path\":\"$PIN/$F\"},\"worktree\":\"$PIN\",\"actual\":\"$PIN\"}"
expect "запись-в-чужой-корень"         block  "Н-85"        "{\"tool\":\"write\",\"args\":{\"path\":\"$FOREIGN/$F\"},\"worktree\":\"$PIN\",\"actual\":\"$PIN\"}"

# 3-4: канонизация (realpath): «..» и симлинк нейтрализованы ДО сравнения
expect "пинн-через-..-канонизируется"  pass   ""            "{\"tool\":\"write\",\"args\":{\"path\":\"$PIN/$F\"},\"worktree\":\"$PIN/../$(basename "$PIN")\",\"actual\":\"$PIN\"}"
expect "пинн-через-симлинк-канонизируется" pass ""          "{\"tool\":\"write\",\"args\":{\"path\":\"$PIN/$F\"},\"worktree\":\"$SYM\",\"actual\":\"$PIN\"}"

# 5: несуществующий пинн → именованный отказ (анти-опечатка wip-022-archtree)
expect "несуществующий-пинн"           refuse "не существует" "{\"tool\":\"write\",\"args\":{\"path\":\"$PIN/$F\"},\"worktree\":\"$GHOST\",\"actual\":\"$PIN\"}"

# 6-8: allowlist Г3 (улики и внутренние URI — легитимные цели записи)
expect "запись-в-dev-harness-verify"   pass   ""            "{\"tool\":\"write\",\"args\":{\"path\":\"$VERIFY_DIR/$F\"},\"worktree\":\"$PIN\",\"actual\":\"$PIN\"}"
expect "запись-artifact-URI"           pass   ""            "{\"tool\":\"write\",\"args\":{\"path\":\"artifact://025/$F\"},\"worktree\":\"$PIN\",\"actual\":\"$PIN\"}"
expect "запись-local-URI"              pass   ""            "{\"tool\":\"write\",\"args\":{\"path\":\"local://025/$F\"},\"worktree\":\"$PIN\",\"actual\":\"$PIN\"}"

# 9: сверка тождества: пинн ≠ фактическое рабочее дерево сессии → отказ
expect "пинн-расходится-с-фактом"      refuse "не совпадает" "{\"tool\":\"write\",\"args\":{\"path\":\"$PIN/$F\"},\"worktree\":\"$PIN\",\"actual\":\"$FOREIGN\"}"

exit 0
