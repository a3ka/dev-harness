#!/usr/bin/env bash
# Дрилл: проверяет механизм 025-A/C — страж вектора утечки и пин/allowlist через
# .omp/extensions/path-guard.ts.
#
# Контракт 025, пачки A-1 и C-1. Дрилл копируется раннером в $WORK/scripts/
# через BARRIER_ROOT; субъект подкладывает фикстура. Зелёный контроль: реальный
# subject на честных входах даёт ВЕРНЫЕ решения judge (13 входов И-1 + 9 входов
# И-5 + 3 входа null-allowlist правка-круг 3 = 25 предъявлений) И default-фабрика
# регистрирует tool_call handler, который судит верно. Красное: стаб-фикстура
# ловится по сценарию — rc=1 + подстрока ПРИЧИНЫ. Стабы:
#
#   1. fail_closed_no_module:       стаб — файл отсутствует, --judge вернёт ошибку.
#   2. stub_always_pass:            стаб-JSON «всегда pass», умирает на блок-ветвях.
#   3. stub_always_block:           стаб-JSON «всегда block reason=X», умирает на канарейках.
#   4. stub_weak_relative:          стаб ловит только edit-относительный, пропускает bash-write.
#   5. stub_no_realpath:            стаб лексический, не канонизирует pin → ../ и SYMLINK не пройдут.
#   6. stub_no_pin_check:           стаб не проверяет pin вообще, чужие пишутся.
#   7. stub_weak_uri:               стаб не распознаёт artifact:// / local:// URI.
#
# КАК ДРИЛЛ ОТЛИЧАЕТ СТАБ. Фикстура подменяет subject стабом ПЕРЕД вторым вызовом
# $BARRIER. Дрилл опознаёт стаб по уникальной подстроке в исходнике.
#
#   bash scripts/drill_path_guard.sh
#
# НЕ БАРЬЕР: дрилл прямого запуска — зелёный контроль и стаб-детект внутри самого скрипта; runner-семья fixtures/<имя>/ не заводится по заморозке 025 И-7 («red_* вне case_*-глоба раннера», А-82; каталог вне зон отвергается стражем). Конверсия в case_*-семью — пачка ARCHITECT после land. Выходы прежние: 0 — механизм работает ИЛИ стаб не пойман; 1 — стаб пойман; 2 — нечем проверить.
set -uo pipefail

# Унаследованные git-переменные меняют построение подставного окружения; снимаем.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

command -v node >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет node\n' >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v bash >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет bash\n' >&2; exit 2; }

REAL="$(readlink -f "$0" 2>/dev/null || realpath "$0" 2>/dev/null || printf '%s' "$0")"
case "$REAL" in
  /*) WORK="$(dirname "$(dirname "$REAL")")" ;;
  *)  WORK="$(cd "$(dirname "$(dirname "$REAL")")" 2>/dev/null && pwd -P)" ;;
esac
DIRECT_RUN=0
if [ -z "$WORK" ] || [ ! -d "$WORK" ]; then
  mkdir -p "$ROOT/tmp"
  WORK="$(mktemp -d "$ROOT/tmp/drill-path-guard-direct.XXXXXX")"
  DIRECT_RUN=1
fi
mkdir -p "$WORK/.omp/extensions"
[ "$DIRECT_RUN" = 1 ] && trap 'rm -rf "$WORK"' EXIT

TS_EXT="$WORK/.omp/extensions/path-guard.ts"

detect_stub() {
  if [ ! -f "$TS_EXT" ]; then
    echo "fail_closed_no_module"; return
  fi
  local t
  t="$(cat "$TS_EXT" 2>/dev/null || true)"
  case "$t" in
    *"Подставной страж: всегда pass"*)            echo "stub_always_pass"; return ;;
    *"Подставной страж: всегда block"*)           echo "stub_always_block"; return ;;
    *"Подставной страж: ловит только edit-относительный"*) echo "stub_weak_relative"; return ;;
    *"Подставной страж: пина не канонизирует"*)   echo "stub_no_realpath"; return ;;
    *"Подставной страж: пина не проверяет"*)      echo "stub_no_pin_check"; return ;;
    *"Подставной страж: URI не распознаёт"*)      echo "stub_weak_uri"; return ;;
  esac
  echo "real"
}

scenario="$(detect_stub)"
case "$scenario" in

  real)
    # ПОВЕДЕНЧЕСКАЯ проверка реальных субъектов на 25 входах контракта 025:
    # И-1 (13) + И-5 (9) + null-allowlist (3, правка-круг 3). Каждый вход — через
    # --judge; решение сверяется с ожиданием. Строим изолированные mktemp-пути
    # (контракт Н-39: инвариантность к значениям).
    PIN="$(mktemp -d "${TMPDIR:-/tmp}/pg025dpin.XXXXXX")"
    FOREIGN="$(mktemp -d "${TMPDIR:-/tmp}/pg025dforeign.XXXXXX")"
    VERIFY_BASE="${TMPDIR:-/tmp}/dev-harness-verify"
    mkdir -p "$VERIFY_BASE"
    VERIFY_DIR="$(mktemp -d "$VERIFY_BASE/025-drill.XXXXXX")"
    GHOST="$PIN/ghost-$RANDOM"
    SYM="$PIN-sym-$RANDOM"
    ln -s "$PIN" "$SYM"
    trap 'rm -rf "$PIN" "$FOREIGN" "$VERIFY_DIR" "$SYM"' EXIT
    F="f_$RANDOM.txt"

    # ── утилита: запустить judge и получить decision ────────────────────────────
    judge_decision() {
      node "$TS_EXT" --judge "$1" 2>/dev/null | node -e '
        let s=""; process.stdin.on("data",d=>s+=d).on("end",()=>{
          try { const j=JSON.parse(s); process.stdout.write(j.decision??"BAD"); }
          catch { process.stdout.write("BAD_JSON"); }
        });'
    }
    judge_reason() {
      node "$TS_EXT" --judge "$1" 2>/dev/null | node -e '
        let s=""; process.stdin.on("data",d=>s+=d).on("end",()=>{
          try { const j=JSON.parse(s); process.stdout.write(j.reason??""); }
          catch {}
        });'
    }
    expect() {  # <метка> <ожидаемое_решение> <json>
      local label="$1" want="$2" evt="$3" got
      got="$(judge_decision "$evt")"
      if [ "$got" != "$want" ]; then
        local reason; reason="$(judge_reason "$evt")"
        printf '  FAIL real/%s: ожидалось %s, получено %s (reason: %s)\n' "$label" "$want" "$got" "$reason" >&2
        exit 1
      fi
    }
    WT_JSON="\"worktree\":\"$PIN\",\"actual\":\"$PIN\""

    # ── И-1 (пачка A, 13 входов) ────────────────────────────────────────────────
    expect "edit-относительный"      block  "{\"tool\":\"edit\",\"args\":{\"path\":\"$F\"},$WT_JSON}"
    expect "write-относительный"     block  "{\"tool\":\"write\",\"args\":{\"path\":\"$F\"},$WT_JSON}"
    expect "sed-i-без-cwd"           block  "{\"tool\":\"bash\",\"args\":{\"command\":\"sed -i s/a/b/ $F\"},$WT_JSON}"
    expect "printf-redirect-без-cwd" block  "{\"tool\":\"bash\",\"args\":{\"command\":\"printf x >> $F\"},$WT_JSON}"
    expect "redirect-без-cwd"        block  "{\"tool\":\"bash\",\"args\":{\"command\":\"echo x > $F\"},$WT_JSON}"
    expect "touch-без-cwd"          block  "{\"tool\":\"bash\",\"args\":{\"command\":\"touch $F\"},$WT_JSON}"
    expect "edit-относительный-главная" block  "{\"tool\":\"edit\",\"args\":{\"path\":\"$F\"},\"worktree\":null,\"actual\":null}"
    expect "чтение-read"             pass   "{\"tool\":\"read\",\"args\":{\"path\":\"$F\"},$WT_JSON}"
    expect "чтение-grep"             pass   "{\"tool\":\"grep\",\"args\":{\"pattern\":\"x\",\"path\":\"$F\"},$WT_JSON}"
    expect "bash-чтение"             pass   "{\"tool\":\"bash\",\"args\":{\"command\":\"cat $F\"},$WT_JSON}"
    expect "bash-write-cwd"          pass   "{\"tool\":\"bash\",\"args\":{\"command\":\"sed -i s/a/b/ $F\",\"cwd\":\"$PIN\"},$WT_JSON}"
    expect "touch-с-cwd"            pass   "{\"tool\":\"bash\",\"args\":{\"command\":\"touch $F\",\"cwd\":\"$PIN\"},$WT_JSON}"
    expect "edit-абсолютный-в-пинне" pass   "{\"tool\":\"edit\",\"args\":{\"path\":\"$PIN/$F\"},$WT_JSON}"

    # ── И-5 (пачка C, 9 входов) ────────────────────────────────────────────────
    expect "запись-в-пинне"               pass   "{\"tool\":\"write\",\"args\":{\"path\":\"$PIN/$F\"},\"worktree\":\"$PIN\",\"actual\":\"$PIN\"}"
    expect "запись-в-чужой-корень"        block  "{\"tool\":\"write\",\"args\":{\"path\":\"$FOREIGN/$F\"},\"worktree\":\"$PIN\",\"actual\":\"$PIN\"}"
    expect "пинн-через-.."                pass   "{\"tool\":\"write\",\"args\":{\"path\":\"$PIN/$F\"},\"worktree\":\"$PIN/../$(basename "$PIN")\",\"actual\":\"$PIN\"}"
    expect "пинн-через-симлинк"           pass   "{\"tool\":\"write\",\"args\":{\"path\":\"$PIN/$F\"},\"worktree\":\"$SYM\",\"actual\":\"$PIN\"}"
    expect "несуществующий-пинн"          refuse "{\"tool\":\"write\",\"args\":{\"path\":\"$PIN/$F\"},\"worktree\":\"$GHOST\",\"actual\":\"$PIN\"}"
    expect "запись-dev-harness-verify"    pass   "{\"tool\":\"write\",\"args\":{\"path\":\"$VERIFY_DIR/$F\"},\"worktree\":\"$PIN\",\"actual\":\"$PIN\"}"
    expect "запись-artifact-URI"          pass   "{\"tool\":\"write\",\"args\":{\"path\":\"artifact://025/$F\"},\"worktree\":\"$PIN\",\"actual\":\"$PIN\"}"
    expect "запись-local-URI"             pass   "{\"tool\":\"write\",\"args\":{\"path\":\"local://025/$F\"},\"worktree\":\"$PIN\",\"actual\":\"$PIN\"}"
    expect "пинн-расходится-с-фактом"     refuse "{\"tool\":\"write\",\"args\":{\"path\":\"$PIN/$F\"},\"worktree\":\"$PIN\",\"actual\":\"$FOREIGN\"}"

    # ── null-allowlist (правка-круг 3, вердикт d141dd9 блокер 2) ──────────────
    # unpinned (worktree:null): ТОЛЬКО скратч ∪ artifact:// — pass; иные внутренние
    # URI (local://, mcp://, skill://, agent://, history://, xd://) — block Н-85
    # (слово владельца 2026-09-11 «дыра B»: null-allowlist узкое «скратч/artifact»,
    # НЕ «свободные абсолюты»). Пин-сессии — без изменений (И-5 строки выше).
    expect "null-local-URI-блок"      block "{\"tool\":\"write\",\"args\":{\"path\":\"local://025/$F\"},\"worktree\":null,\"actual\":null}"
    expect "null-artifact-URI-pass"   pass  "{\"tool\":\"write\",\"args\":{\"path\":\"artifact://025/$F\"},\"worktree\":null,\"actual\":null}"
    expect "null-scratch-pass"        pass  "{\"tool\":\"write\",\"args\":{\"path\":\"$VERIFY_DIR/$F\"},\"worktree\":null,\"actual\":null}"

    # ── интеграция default-фабрики: должна зарегистрировать tool_call ───────────
    PI="$WORK/fake-pi.mjs"
    cat > "$PI" <<'EOF'
import path from 'node:path';
const reg = { tool_call: null };
const fake = {
  on(name, h) { if (name === 'tool_call') reg.tool_call = h; },
  run(c) { return { exitCode: 0 }; },
  sendMessage(s) {}
};
globalThis.fake = fake;
globalThis.reg = reg;
// Node 26 умеет type-stripping .ts через --experimental-strip-types (включено по умолчанию);
// импортируем .ts напрямую и вызываем default-фабрику с подставным pi.
const mod = await import(path.resolve(process.argv[2]));
if (typeof mod.default !== 'function') {
  console.error('FAIL фабрика: default не функция');
  process.exit(1);
}
mod.default(fake);
if (!globalThis.reg.tool_call) {
  console.error('FAIL фабрика: handler tool_call не зарегистрирован');
  process.exit(1);
}
// Smoke: тривиальный относительный edit должен блокироваться.
const result = await globalThis.reg.tool_call({
  toolName: 'edit',
  input: { i: 'Smoke: relative edit', input: '[relative.txt#0000]\nPUT 1.=1:\n+MARK2' },
  worktree: null,
  actual: null,
});
if (!result || result.block !== true || typeof result.reason !== 'string' || !result.reason.includes('Н-85')) {
  console.error('FAIL фабрика: edit-относительный не заблокирован — ' + JSON.stringify(result));
  process.exit(1);
}
console.log('OK');
EOF
    out="$(node "$PI" "$TS_EXT" 2>&1)"
    rc=$?
    if [ "$rc" -ne 0 ] || [ "$out" != "OK" ]; then
      printf '  FAIL real/factory: фабрика не зарегистрировала tool_call handler или не блокирует относительный edit\n' >&2
      printf '%s\n' "$out" >&2
      exit 1
    fi

    printf '  ok   real: 25 предъявлений judge (И-1 + И-5 + null-allowlist) верны; фабрика регистрирует tool_call handler и блокирует относительный edit\n' >&2
    exit 0
    ;;

  fail_closed_no_module)
    # Модуль отсутствует — любой --judge должен упасть с rc!=0.
    out="$(node "$TS_EXT" --judge '{"tool":"read"}' 2>&1)"; rc=$?
    if [ "$rc" -ne 0 ]; then
      printf '  ok   fail_closed_no_module: --judge отказал rc=%d (модуль отсутствует)\n' "$rc" >&2
      exit 0
    else
      printf 'FAIL fail_closed_no_module: модуль отсутствует, но --judge дал rc=0 (out: %s)\n' "$out" >&2
      exit 1
    fi
    ;;

  stub_always_pass)
    # Стаб всегда pass — должен умереть на блок-ветви (например, edit-относительный).
    out="$(node "$TS_EXT" --judge '{"tool":"edit","args":{"path":"f"},"worktree":"/tmp","actual":"/tmp"}' 2>&1)"
    case "$out" in
      *'"decision":"pass"'*)
        printf 'FAIL stub_always_pass: блок-ветвь не сработала — стаб всегда pass\n' >&2
        exit 1 ;;
      *)
        printf '  ok   stub_always_pass: блок-ветвь поймана (стаб не блокирует)\n' >&2
        exit 0 ;;
    esac
    ;;

  stub_always_block)
    # Стаб всегда block — должен умереть на канарейке чтения.
    out="$(node "$TS_EXT" --judge '{"tool":"read","args":{"path":"f"},"worktree":"/tmp","actual":"/tmp"}' 2>&1)"
    case "$out" in
      *'"decision":"block"'*)
        printf 'FAIL stub_always_block: канарейка чтения заблокирована — стаб всегда block\n' >&2
        exit 1 ;;
      *)
        printf '  ok   stub_always_block: канарейка чтения прошла (стаб не различает чтение/запись)\n' >&2
        exit 0 ;;
    esac
    ;;

  stub_weak_relative)
    # Стаб ловит ТОЛЬКО edit-относительный, пропускает bash-write-относительный.
    # Проверка: относительный bash-write должен блокироваться. Стаб пропустит.
    out="$(node "$TS_EXT" --judge '{"tool":"bash","args":{"command":"sed -i s/a/b/ f"},"worktree":"/tmp","actual":"/tmp"}' 2>&1)"
    case "$out" in
      *'"decision":"block"'*)
        printf '  ok   stub_weak_relative: bash-write-относительный заблокирован (стаб не подложен)\n' >&2
        exit 0 ;;
      *)
        printf 'FAIL stub_weak_relative: bash-write-относительный не заблокирован (out: %s)\n' "$out" >&2
        exit 1 ;;
    esac
    ;;

  stub_no_realpath)
    # Стаб без realpath — пин через ../ или симлинк не канонизируется, realpath(pin)
    # разойдётся с фактом → refuse «не совпадает». Реальный — pass.
    PIN="$(mktemp -d "${TMPDIR:-/tmp}/pg025drealp.XXXXXX")"
    SYM="$PIN-sym-$RANDOM"
    ln -s "$PIN" "$SYM"
    trap "rm -rf '$PIN' '$SYM'" EXIT
    out="$(node "$TS_EXT" --judge "{\"tool\":\"write\",\"args\":{\"path\":\"$PIN/f\"},\"worktree\":\"$SYM\",\"actual\":\"$PIN\"}" 2>&1)"
    case "$out" in
      *'"decision":"pass"'*)
        printf '  ok   stub_no_realpath: симлинк-пинн канонизирован (стаб не подложен)\n' >&2
        exit 0 ;;
      *)
        printf 'FAIL stub_no_realpath: симлинк-пинн НЕ канонизирован — стаб без realpath (out: %s)\n' "$out" >&2
        exit 1 ;;
    esac
    ;;

  stub_no_pin_check)
    # Стаб не проверяет pin — запись в чужой корень должна быть разрешена. Реальный — block.
    PIN="$(mktemp -d "${TMPDIR:-/tmp}/pg025dpinchk.XXXXXX")"
    FOREIGN="$(mktemp -d "${TMPDIR:-/tmp}/pg025dforeign.XXXXXX")"
    trap "rm -rf '$PIN' '$FOREIGN'" EXIT
    out="$(node "$TS_EXT" --judge "{\"tool\":\"write\",\"args\":{\"path\":\"$FOREIGN/f\"},\"worktree\":\"$PIN\",\"actual\":\"$PIN\"}" 2>&1)"
    case "$out" in
      *'"decision":"block"'*Н-85*)
        printf '  ok   stub_no_pin_check: чужой корень заблокирован Н-85 (стаб не подложен)\n' >&2
        exit 0 ;;
      *)
        printf 'FAIL stub_no_pin_check: чужой корень НЕ заблокирован — стаб без проверки пина (out: %s)\n' "$out" >&2
        exit 1 ;;
    esac
    ;;

  stub_weak_uri)
    # Стаб не распознаёт URI — запись artifact:// должна быть разрешена. Стаб заблокирует.
    PIN="$(mktemp -d "${TMPDIR:-/tmp}/pg025duri.XXXXXX")"
    trap "rm -rf '$PIN'" EXIT
    out="$(node "$TS_EXT" --judge "{\"tool\":\"write\",\"args\":{\"path\":\"artifact://025/f\"},\"worktree\":\"$PIN\",\"actual\":\"$PIN\"}" 2>&1)"
    case "$out" in
      *'"decision":"pass"'*)
        printf '  ok   stub_weak_uri: artifact:// пропущен (стаб не подложен)\n' >&2
        exit 0 ;;
      *)
        printf 'FAIL stub_weak_uri: artifact:// заблокирован — стаб не знает URI allowlist (out: %s)\n' "$out" >&2
        exit 1 ;;
    esac
    ;;

  *)
    printf 'NOT_IMPLEMENTED: неизвестный сценарий: %s\n' "$scenario" >&2
    exit 2
    ;;
esac
