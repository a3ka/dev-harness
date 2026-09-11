#!/usr/bin/env bash
# Дрилл: проверяет механизм 025-B/2 — маркер [exit=N] в bash tool_result через
# .omp/extensions/exit-marker.ts.
#
# Контракт 025, пачка B-2. Дрилл копируется раннером в $WORK/scripts/ через
# BARRIER_ROOT; субъект подкладывает фикстура. Зелёный контроль: реальный
# subject на честных входах даёт ВЕРНЫЕ решения judge (7 входов fixture) И
# default-фабрика регистрирует tool_result handler. Красное: стаб-фикстура
# ловится по сценарию. Стабы:
#
#   1. fail_closed_no_module:  стаб — файл отсутствует, --judge упадёт.
#   2. stub_always_zero:       стаб «[exit=0]» всегда, умирает на ненулевых кодах.
#   3. stub_from_output:       стаб парсит output, умирает на эхо-лжи (exit=1 при echo rc=0).
#   4. stub_no_handler:        стаб экспортирует default, но не зовёт pi.on('tool_result', …).
#
# КАК ДРИЛЛ ОТЛИЧАЕТ СТАБ. Фикстура подменяет subject стабом ПЕРЕД вторым вызовом
# $BARRIER. Дрилл опознаёт стаб по уникальной подстроке в исходнике.
#
#   bash scripts/drill_exit_marker.sh
#
# Коды возврата: 0 — реальный механизм работает ИЛИ стаб не пойман,
# 1 — стаб пойман, 2 — нечем проверить.
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

command -v node >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет node\n' >&2; exit 2; }
command -v bash >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет bash\n' >&2; exit 2; }

REAL="$(readlink -f "$0" 2>/dev/null || realpath "$0" 2>/dev/null || printf '%s' "$0")"
case "$REAL" in
  /*) WORK="$(dirname "$(dirname "$REAL")")" ;;
  *)  WORK="$(cd "$(dirname "$(dirname "$REAL")")" 2>/dev/null && pwd -P)" ;;
esac
DIRECT_RUN=0
if [ -z "$WORK" ] || [ ! -d "$WORK" ]; then
  mkdir -p "$ROOT/tmp"
  WORK="$(mktemp -d "$ROOT/tmp/drill-exit-marker-direct.XXXXXX")"
  DIRECT_RUN=1
fi
mkdir -p "$WORK/.omp/extensions"
[ "$DIRECT_RUN" = 1 ] && trap 'rm -rf "$WORK"' EXIT

TS_EXT="$WORK/.omp/extensions/exit-marker.ts"

detect_stub() {
  if [ ! -f "$TS_EXT" ]; then
    echo "fail_closed_no_module"; return
  fi
  local t
  t="$(cat "$TS_EXT" 2>/dev/null || true)"
  case "$t" in
    *"Подставной маркер: всегда [exit=0]"*) echo "stub_always_zero"; return ;;
    *"Подставной маркер: парсит output"*)    echo "stub_from_output"; return ;;
    *"Подставной маркер: handler не регистрирует"*) echo "stub_no_handler"; return ;;
  esac
  echo "real"
}

scenario="$(detect_stub)"
case "$scenario" in

  real)
    judge_append() {
      node "$TS_EXT" --judge "$1" 2>/dev/null | node -e '
        let s=""; process.stdin.on("data",d=>s+=d).on("end",()=>{
          try { const j=JSON.parse(s); process.stdout.write(j.append===null?"null":(j.append??"BAD")); }
          catch { process.stdout.write("BAD_JSON"); }
        });'
    }
    expect() {  # <метка> <ожидаемое_значение_или_null> <json>
      local label="$1" want="$2" evt="$3" got
      got="$(judge_append "$evt")"
      if [ "$got" != "$want" ]; then
        printf '  FAIL real/%s: ожидалось %s, получено %s\n' "$label" "$want" "$got" >&2
        exit 1
      fi
    }

    # 7 входов из red_marker_exit.sh:
    expect "код-7"                  '[exit=7]'   '{"tool":"bash","result":{"exitCode":7,"output":"…" }}'
    expect "код-0"                  '[exit=0]'   '{"tool":"bash","result":{"exitCode":0,"output":"ok"}}'
    expect "код-141"                '[exit=141]' '{"tool":"bash","result":{"exitCode":141,"output":"…"}}'
    expect "эхо-лжёт-exitCode-1"    '[exit=1]'   '{"tool":"bash","result":{"exitCode":1,"output":"rc=0"}}'
    expect "эхо-лжёт-обратно"       '[exit=0]'   '{"tool":"bash","result":{"exitCode":0,"output":"rc=1"}}'
    expect "не-bash-результат"      'null'       '{"tool":"read","result":{"exitCode":0,"output":"x"}}'
    expect "exitCode-отсутствует"   '[exit=?]'   '{"tool":"bash","result":{"exitCode":null,"output":"x"}}'

    # ── интеграция default-фабрики: должна зарегистрировать tool_result handler ──
    PI="$WORK/fake-pi.mjs"
    cat > "$PI" <<'EOF'
import path from 'node:path';
const reg = { tool_result: null };
const fake = {
  on(name, h) { if (name === 'tool_result') reg.tool_result = h; },
  run(c) { return { exitCode: 0 }; },
  sendMessage(s) {}
};
globalThis.fake = fake;
globalThis.reg = reg;
const mod = await import(path.resolve(process.argv[2]));
if (typeof mod.default !== 'function') {
  console.error('FAIL фабрика: default не функция');
  process.exit(1);
}
mod.default(fake);
if (!globalThis.reg.tool_result) {
  console.error('FAIL фабрика: handler tool_result не зарегистрирован');
  process.exit(1);
}
// Smoke: bash с exitCode=7 → handler должен вернуть append=[exit=7].
const result = await globalThis.reg.tool_result({
  tool: 'bash',
  result: { exitCode: 7, output: 'x' },
});
if (!result || result.append !== '[exit=7]') {
  console.error('FAIL фабрика: bash exitCode=7 не маркирован — ' + JSON.stringify(result));
  process.exit(1);
}
// Smoke: read → handler должен вернуть append=null (не-bash не маркируется).
const r2 = await globalThis.reg.tool_result({
  tool: 'read',
  result: { exitCode: 0, output: 'x' },
});
if (r2 !== undefined && r2 !== null && r2.append !== null) {
  console.error('FAIL фабрика: read результат не-нулевой — ' + JSON.stringify(r2));
  process.exit(1);
}
console.log('OK');
EOF
    out="$(node "$PI" "$TS_EXT" 2>&1)"
    rc=$?
    if [ "$rc" -ne 0 ] || [ "$out" != "OK" ]; then
      printf '  FAIL real/factory: фабрика не зарегистрировала tool_result или не маркирует bash-результат\n' >&2
      printf '%s\n' "$out" >&2
      exit 1
    fi

    printf '  ok   real: 7 предъявлений judge верны; фабрика регистрирует tool_result handler и маркирует bash\n' >&2
    exit 0
    ;;

  fail_closed_no_module)
    out="$(node "$TS_EXT" --judge '{"tool":"bash","result":{"exitCode":0,"output":"x"}}' 2>&1)"; rc=$?
    if [ "$rc" -ne 0 ]; then
      printf '  ok   fail_closed_no_module: --judge отказал rc=%d (модуль отсутствует)\n' "$rc" >&2
      exit 0
    fi
    printf 'FAIL fail_closed_no_module: модуль отсутствует, но --judge дал rc=0 (out: %s)\n' "$out" >&2
    exit 1
    ;;

  stub_always_zero)
    # Стаб «[exit=0]» всегда. На входе exitCode=7 должен дать не [exit=0].
    out="$(node "$TS_EXT" --judge '{"tool":"bash","result":{"exitCode":7,"output":"…"}}' 2>&1)"
    case "$out" in
      *'"append":"[exit=0]"'*|*'"append":"[exit=7]"')
        # Если [exit=7] — стаб не подложен (правильный ответ).
        if [[ "$out" == *'"append":"[exit=7]"'* ]]; then
          printf '  ok   stub_always_zero: реальный ответ [exit=7] (стаб не подложен)\n' >&2
          exit 0
        fi
        printf 'FAIL stub_always_zero: ненулевой код отдан как [exit=0] — стаб всегда ноль\n' >&2
        exit 1 ;;
      *)
        printf 'FAIL stub_always_zero: неожиданный вывод: %s\n' "$out" >&2
        exit 1 ;;
    esac
    ;;

  stub_from_output)
    # Стаб парсит output — на входе exitCode=1, output=rc=0 он выдаст [exit=0] или подобное.
    out="$(node "$TS_EXT" --judge '{"tool":"bash","result":{"exitCode":1,"output":"rc=0"}}' 2>&1)"
    case "$out" in
      *'"append":"[exit=1]"'*)
        printf '  ok   stub_from_output: реальный ответ [exit=1] (стаб не подложен)\n' >&2
        exit 0 ;;
      *)
        printf 'FAIL stub_from_output: вход exitCode=1, output=rc=0 — стаб проглотил эхо и отдал не [exit=1] (out: %s)\n' "$out" >&2
        exit 1 ;;
    esac
    ;;

  stub_no_handler)
    # Стаб экспортирует default, но не зовёт pi.on('tool_result', …).
    PI="$WORK/fake-pi.mjs"
    cat > "$PI" <<'EOF'
import path from 'node:path';
let registered = 0;
const fake = {
  on(name, h) { registered++; },
  run(c) { return { exitCode: 0 }; },
  sendMessage(s) {}
};
globalThis.fake = fake;
const mod = await import(path.resolve(process.argv[2]));
if (typeof mod.default !== 'function') {
  console.error('FAIL default не функция');
  process.exit(1);
}
mod.default(fake);
console.log('registered=' + registered);
EOF
    out="$(node "$PI" "$TS_EXT" 2>&1)"
    if [[ "$out" == *"registered=0"* ]]; then
      printf 'FAIL stub_no_handler: handler tool_result не зарегистрирован — стаб пойман\n' >&2
      exit 1
    fi
    printf '  ok   stub_no_handler: handler зарегистрирован (стаб не подложен)\n' >&2
    exit 0
    ;;

  *)
    printf 'NOT_IMPLEMENTED: неизвестный сценарий: %s\n' "$scenario" >&2
    exit 2
    ;;
esac
