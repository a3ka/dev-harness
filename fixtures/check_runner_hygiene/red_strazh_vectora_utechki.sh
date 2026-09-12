#!/usr/bin/env bash
# КРАСНОЕ 025-И-1 (пачка A-1): страж вектора утечки — extension path-guard.
# СУБЪЕКТ: .omp/extensions/path-guard.ts. СЕГОДНЯ: модуль отсутствует → rc 1
# именованный. ПОСЛЕ реализации: rc 0.
#
# ГРАММАТИКА judge-протокола (заморожена контрактом 025 §Пачка A-1; Н-39 —
# стабы привязаны к ветвям КОДА инструмента, не к прозе):
#   node path-guard.ts --judge '<json>'  — одно синтетическое tool_call-событие:
#     {"tool":"edit|write|bash|read|grep|glob",
#      "args":{<аргументы инструмента: path/command/cwd/...>},
#      "worktree":"<строка WORKTREE= задания или null>",
#      "actual":"<realpath фактического cwd сессии или null>"}
#   Выход — РОВНО ОДНА строка JSON на stdout, rc модуля 0:
#     {"decision":"block","reason":"… Н-85 …"}   — блок именованный
#     {"decision":"pass"}                        — пропуск
#     {"decision":"refuse","reason":"…"}         — отказ сессии (пинн, пачка C)
#   rc модуля 2 — сломанный вход. Любой иной выход = не-субъект.
#
# АНТИ-ПЛАЦЕБО (вердикт 72049b0, блокер 1): оракул живёт в ЭТОЙ фикстуре
# (правило 8), НЕ в --selftest субъекта; каждый вход — своим предъявлением;
# декой process.exit(0) не отвечает решением и умирает именованно. Матрица
# «отсутствие / декой / честный» — в §Инварианты контракта 025.
# Пути-входы — mktemp/$RANDOM, не константы (инвариантность к значениям).
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
SUBJ="$ROOT/.omp/extensions/path-guard.ts"

if [ ! -f "$SUBJ" ]; then
  printf 'КРАСНОЕ 025-И-1: механизм отсутствует — %s не существует; вектор утечки (относит.-путь запись/edit) не стережётся ни одним носителем\n' "$SUBJ" >&2
  exit 1
fi

PIN="$(mktemp -d "${TMPDIR:-/tmp}/pg025pin.XXXXXX")"
trap 'rm -rf "$PIN"' EXIT
F="f_$RANDOM.txt"

fail() {  # <ном.ветвь> <детали>
  printf 'КРАСНОЕ 025-И-1: ветвь «%s» — %s\n' "$1" "$2" >&2
  exit 1
}

# expect <ветвь> <ожидание: block|pass|refuse> <требовать «Н-85» в reason: 0|1> <json>
expect() {
  local vetka="$1" want="$2" want85="$3" evt="$4" out rc dec
  out="$(node "$SUBJ" --judge "$evt")"; rc=$?
  if [ "$rc" -ne 0 ]; then
    fail "$vetka" "субъект не ответил решением (rc $rc, вывод: ${out:-<пусто>}) — декой/сломанный модуль"
  fi
  dec="$(printf '%s' "$out" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{console.log(JSON.parse(s).decision??"")}catch(e){console.log("BAD_JSON")}})')"
  if [ -z "$dec" ] || [ "$dec" = "BAD_JSON" ]; then
    fail "$vetka" "субъект не ответил решением-JSON (вывод: ${out:-<пусто>}) — декой без ответа умирает здесь"
  fi
  if [ "$dec" != "$want" ]; then
    fail "$vetka" "ожидалось $want, получено $dec (вывод: $out)"
  fi
  if [ "$want" = "block" ] && [ "$want85" = "1" ]; then
    case "$out" in
      *Н-85*) ;;
      *) fail "$vetka" "блок без именованной причины Н-85 (вывод: $out)" ;;
    esac
  fi
}

WT_JSON="\"worktree\":\"$PIN\",\"actual\":\"$PIN\""

# ── ночной вектор: относительная запись → блок (Г1/Г2: таргетно, не «любой bash») ──
expect "edit-относительный"      block 1 "{\"tool\":\"edit\",\"args\":{\"path\":\"$F\"},$WT_JSON}"
expect "write-относительный"     block 1 "{\"tool\":\"write\",\"args\":{\"path\":\"$F\"},$WT_JSON}"
expect "sed-i-без-cwd"           block 1 "{\"tool\":\"bash\",\"args\":{\"command\":\"sed -i s/a/b/ $F\"},$WT_JSON}"
expect "printf-redirect-без-cwd" block 1 "{\"tool\":\"bash\",\"args\":{\"command\":\"printf x >> $F\"},$WT_JSON}"
expect "redirect-без-cwd"        block 1 "{\"tool\":\"bash\",\"args\":{\"command\":\"echo x > $F\"},$WT_JSON}"
expect "edit-относительный-в-главной-сессии" block 1 "{\"tool\":\"edit\",\"args\":{\"path\":\"$F\"},\"worktree\":null,\"actual\":null}"

# ── канарейки Г1: чтения свободны; легитимная запись в-пинне проходит ──
expect "чтение-read-относительный"  pass 0 "{\"tool\":\"read\",\"args\":{\"path\":\"$F\"},$WT_JSON}"
expect "чтение-grep-относительный"  pass 0 "{\"tool\":\"grep\",\"args\":{\"pattern\":\"x\",\"path\":\"$F\"},$WT_JSON}"
expect "bash-чтение-без-cwd"        pass 0 "{\"tool\":\"bash\",\"args\":{\"command\":\"cat $F\"},$WT_JSON}"
expect "bash-запись-с-cwd-в-пинне"  pass 0 "{\"tool\":\"bash\",\"args\":{\"command\":\"sed -i s/a/b/ $F\",\"cwd\":\"$PIN\"},$WT_JSON}"
expect "edit-абсолютный-в-пинне"    pass 0 "{\"tool\":\"edit\",\"args\":{\"path\":\"$PIN/$F\"},$WT_JSON}"

# ── к2 (вердикт c02f01a, B-025-r2-1/-r2-2): формы записи вне deny-набора. Совмещённые
# флаги perl — буква i внутри bundle (-pi/-pi.bak/-pie), \s-i её не видит; скрипт-
# интерпретаторы inline-кодом (ruby -e File.write / node -e writeFileSync /
# php -r file_put_contents); sed с флагом w FILE. Те же Г1/Г2: запись относительным
# операндом без cwd → block Н-85. Подделка PI_ACTUAL (B-025-r2-3) judge-формой
# НЕвыразима: env-фолбэк живёт только в фабрике register() (path-guard.ts:586-589),
# judge-CLI его не читает — основание и прогон в А-134 NABLIUDENIA_ARCHITECT.md.
expect "perl-pi-без-cwd"               block 1 "{\"tool\":\"bash\",\"args\":{\"command\":\"perl -pi -e 's/a/b/' $F\"},$WT_JSON}"
expect "perl-pi.bak-без-cwd"           block 1 "{\"tool\":\"bash\",\"args\":{\"command\":\"perl -pi.bak -e 's/a/b/' $F\"},$WT_JSON}"
expect "perl-pie-без-cwd"              block 1 "{\"tool\":\"bash\",\"args\":{\"command\":\"perl -pie 's/a/b/' $F\"},$WT_JSON}"
expect "ruby-e-file-write-без-cwd"     block 1 "{\"tool\":\"bash\",\"args\":{\"command\":\"ruby -e 'File.write(\\\"$F\\\",\\\"X\\\")'\"},$WT_JSON}"
expect "node-e-writefilesync-без-cwd"  block 1 "{\"tool\":\"bash\",\"args\":{\"command\":\"node -e 'require(\\\"fs\\\").writeFileSync(\\\"$F\\\",\\\"X\\\")'\"},$WT_JSON}"
expect "php-r-fileputcontents-без-cwd" block 1 "{\"tool\":\"bash\",\"args\":{\"command\":\"php -r 'file_put_contents(\\\"$F\\\",\\\"X\\\");'\"},$WT_JSON}"
expect "sed-w-file-без-cwd"            block 1 "{\"tool\":\"bash\",\"args\":{\"command\":\"echo X | sed 's/X/Y/w $F'\"},$WT_JSON}"

exit 0
