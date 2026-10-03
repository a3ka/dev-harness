#!/usr/bin/env bash
# 080-БАТАРЕЯ — «бугфикс двери перезапуска»: четыре предмета (а)-(г).
# Дом семьи — fixtures/dver_bugfiks_080/ (probe-only 034:
# МНОГОсубъектная проба — субъекты scripts/orch_restart.sh (а)+(б) И
# ops/server/root/orch-peak (в)+(г); барьерного ключа
# scripts/dver_bugfiks.sh НЕТ и не появится), раннер —
# fixtures/_krasnye_080.sh. До-заморозочный носитель закоммичен
# АРХИТЕКТОРОМ (красные предъявления ДО круга критика; прецеденты
# 058/070/072/078).
#
# Структура (v2, круг 2 по вердикту критика к1):
#   1. СТАБ-ПАК (9 обманных стабов + 9 диффпроб): каждый стаб красен
#      на входе, где его дефект наблюдаем; clean-stub на той же клетке
#      даёт другой rc → стаб пойман; clean-stub на чистом входе
#      проходит rc 0 → диффпроба зелёная.
#   2. ЧЕСТНАЯ ЧАСТЬ (21 клетка a1-a5, б1-б3, в1-в3, г1-г2, г6-г8,
#      д'1-д'5) — против реальных scripts/orch_restart.sh,
#      ops/server/root/orch-peak И scripts/check_staged.sh дерева;
#      предъявляется живым прогоном. Клетки в3/г6/г7/г8 — ПОВЕДЕНЧЕСКИЕ:
#      субъект реально запускается командой ctx в sandbox-мире через шов
#      ORCH_PEAK_TEST (инв. 4 контракта), наблюдается ПРИНЯТОЕ РЕШЕНИЕ
#      (say.log с фразой / маркер поставлен-ждёт / отчёт «погибнут»),
#      не только текст исходника. Клетка д'5 — linked worktree:
#      загрязнение ОБЩЕГО config командой из worktree, субъект
#      запущен ИЗ worktree (живая проба критика к1).
#   3. г0 — fail-fast: orch_restart.sh без расширения (нет env/--as) →
#      батарея красна на клетках двери.
#
# Привязки обманных стабов к входам (Н-39 — живут ЗДЕСЬ):
#   s9 STUB:CSID_PARTIAL         «нога (д') в check_staged.sh проверяет
#        ТОЛЬКО user.name, НЕ user.email» — красен на д'2-входе
#        (sandbox с user.email без user.name): s9 rc 0 (пропускает),
#        clean-stub rc 1 (ловит).
#   s1 STUB:IDENTITY_FILECONFIG  «только git config user.name» — красен
#        на a1-входе: env identity + file-config пуст → rc 2 NOT_IMPLEMENTED.
#   s2 STUB:IDENTITY_AS_REQUIRED «требует --as, env игнорирует» — красен
#        на a1-входе (env без --as): rc 1 «identity двери не определена».
#   s3 STUB:AS_NO_VALUE          «--as без значения → НЕ отказ при наличии
#        env» — красен на a4-входе (env+--as no value): s3 rc 0,
#        clean-stub rc 1.
#   s4 STUB:SKIP_AGENTS          «живые субагенты не блокируют» — красен
#        на б1-входе (свежий .jsonl): s4 rc 0, clean-stub rc 1.
#   s5 STUB:AS_MULTI             «--as foo --as bar → rc 0» — красен на
#        a5-входе: s5 rc 0, clean-stub rc 1 «--as задан дважды».
#   s6 orch-peak WITHOUT фразы    «CTX_SOFT без новой фразы» — красен
#        на в1-входе: grep фразы rc 1.
#   s7 orch-peak WITHOUT polling  «CTX_HARD без ORCH_HARD_GRACE» — красен
#        на г1-входе: grep var rc 1.
#   s8 orch-peak WITHOUT report  «CTX_HARD без 'живые субагенты
#        погибнут'» — красен на г2-входе: grep строки rc 1.
#
# Демаркация контрпримеров: toy-мир двери = bare-init main +
# bare-origin + HANDOFF.md (коммитом «architect» через env, file-config
# БЕЗ user.name) + стаб/мини-subject в scripts/orch_restart.sh.
# check_no_leak.sh копируется в scripts/ (нога (г) двери). Свежесть
# журнала = `touch -d "@$(($(date +%s) - off))"` на пустом файле
# (off=30 свежий, off=300 старый). Для orch-peak — копия source →
# SBIN_DST; install.sh verify с швом OPS_SERVER_SRC/SBIN_DST/BIN_DST/ETC_DST.
#
# Прогон: bash red_dver_bugfiks_080.sh [корень worktree]
#   rc 0 — стаб-пак 9/9 пойман + диффпроба 9/9 + честные 21/21.
#   rc 1 — расхождение / стаб не пойман.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT="${1:-$(cd "$HERE/../.." && pwd -P)}"
# Аргумент-корень абсолютизируется ДО любого cd (иначе toy-строители,
# уже сделавшие cd, читают относительный «./scripts/...» мимо клона —
# измерено кругом 2: прогон с аргументом «.» дал rc=127 по всем клеткам).
case "$ROOT" in
  /*) ;;
  *) ROOT="$PWD/$ROOT" ;;
esac
ROOT="$(cd "$ROOT" 2>/dev/null && pwd -P)" || { printf 'ОТКАЗ: корень %s не каталог\n' "$ROOT" >&2; exit 1; }

die_pack() { printf '080-батарея ОТКАЗ: %s\n' "$*" >&2; exit 1; }
command -v git >/dev/null 2>&1 || die_pack "нет git"
command -v touch >/dev/null 2>&1 || die_pack "нет touch"
command -v jq >/dev/null 2>&1 || die_pack "нет jq (cur_ctx субъекта читает usage через jq)"
command -v timeout >/dev/null 2>&1 || die_pack "нет timeout (поведенческие клетки в3/г6-г8)"

# Гигиена: ambient-шовы сняты (включая шовы orch-peak — поведенческие
# клетки подставляют СВОИ миры; ambient-переменные станции не должны
# просачиваться в субъект).
unset ORCH_RESTART_MARKER ORCH_SESSION_START ORCH_SESS_DIR \
      GIT_AUTHOR_NAME GIT_COMMITTER_NAME ORCH_HARD_GRACE ORCH_HARD_POLL \
      ORCH_PEAK_TEST ORCH_TMUX_SOCK ORCH_USER ORCH_REPO ORCH_MARK \
      ORCH_STATE ORCH_LOG ORCH_REPORT ORCH_CTX_SOFT ORCH_CTX_HARD \
      ORCH_SESS_GLOB ORCH_PEAK_GRACE ORCH_PEAK_POLL
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# ── строитель toy-мира двери ─────────────────────────────────────────────
# toy_door <toy-root> <subject-script-path>:
#   bare-init main, без файлов user.name (file-config влючая,
#   только user.email), через env — коммит от «architect», bare-origin,
#   стаб/subject в scripts/orch_restart.sh, check_no_leak.sh тоже
#   скопирован (нога (г) двери).
toy_door() {
  local t="$1" subject="$2"
  rm -rf "$t"
  mkdir -p "$t/scripts"
  cd "$t"
  git init -q -b main
  # Файловый config — БЕЗ user.name (как станция 148.251.131.204)
  git config user.email "architect@dev-harness.local"
  # Коммит через env
  GIT_AUTHOR_NAME="architect" GIT_AUTHOR_EMAIL="architect@dev-harness.local" \
    GIT_COMMITTER_NAME="architect" GIT_COMMITTER_EMAIL="architect@dev-harness.local" \
    bash -c '
    printf "## GDE (toy 080)\n" > HANDOFF.md
    cp "$1" scripts/orch_restart.sh
    [ -f "$ROOT_REAL/scripts/check_no_leak.sh" ] && cp "$ROOT_REAL/scripts/check_no_leak.sh" scripts/
    chmod +x scripts/orch_restart.sh
    git add -A
    git commit -qm "toy: init + subject"
    git init -q --bare -b main "$t-origin.git"
    git remote add origin "$t-origin.git"
    git push -q origin main >/dev/null 2>&1
  ' _ "$subject" || true
  cd - >/dev/null 2>&1 || true
}

# Альтернатива toy_door без ROOT_REAL — вызывающий должен экспортировать
# ROOT_REAL в окружении или передавать как третий аргумент. Проще
# принимать его как 3-й параметр.
toy_door2() {
  local t="$1" subject="$2" root_real="$3"
  rm -rf "$t" "$t-origin.git"
  mkdir -p "$t/scripts"
  (
    cd "$t" || return 1
    git init -q
    git checkout -q -b main 2>/dev/null || true
    git config user.email "architect@dev-harness.local"
    GIT_AUTHOR_NAME="architect" GIT_AUTHOR_EMAIL="architect@dev-harness.local" \
      GIT_COMMITTER_NAME="architect" GIT_COMMITTER_EMAIL="architect@dev-harness.local" \
      bash -c '
      printf "## GDE (toy 080)\n" > HANDOFF.md
      cp "$1" scripts/orch_restart.sh
      cp "$2/scripts/check_no_leak.sh" scripts/ 2>/dev/null || true
      chmod +x scripts/orch_restart.sh
      git add -A
      git commit -qm "toy: init + subject"
      git init -q --bare --initial-branch=main "$3-origin.git" 2>/dev/null || git init -q --bare "$3-origin.git"
      cd "$3-origin.git"
      git symbolic-ref HEAD refs/heads/main 2>/dev/null || true
      cd "$OLDPWD" 2>/dev/null || true
      git remote add origin "$3-origin.git"
      git push -q origin main 2>&1 | head -5
    ' _ "$subject" "$root_real" "$t"
  )
}

# subagent_journal <dir> <name> <offset_sec>
subagent_journal() {
  local d="$1" name="$2" off="$3"
  mkdir -p "$d"
  : > "$d/$name.jsonl"
  if [ "$off" -gt 0 ]; then
    touch -d "@$(( $(date +%s) - off ))" "$d/$name.jsonl"
  fi
}

# ── stub-файлы ─────────────────────────────────────────────────────────────
MINI="$HERE/mini_subject_080.sh"
DIFFPROBE="$HERE/stub_diffprobe.sh"
S1="$HERE/stub_s1.sh"
S2="$HERE/stub_s2.sh"
S3="$HERE/stub_s3.sh"
S4="$HERE/stub_s4.sh"
S5="$HERE/stub_s5.sh"
S9="$HERE/stub_s9.sh"
for f in "$MINI" "$DIFFPROBE" "$S1" "$S2" "$S3" "$S4" "$S5" "$S9"; do
  [ -f "$f" ] || die_pack "в батарее нет $f"
done

ORCHPEAK_SRC="$ROOT/ops/server/root/orch-peak"
[ -f "$ORCHPEAK_SRC" ] || die_pack "в дереве нет ops/server/root/orch-peak"
[ -f "$ROOT/ops/server/install.sh" ] || die_pack "нет ops/server/install.sh"
[ -f "$ROOT/ops/server/user/orch-loop" ] || die_pack "нет ops/server/user/orch-loop"
for u in orch-peak@.service orch-peak-warn.timer orch-peak-stop.timer orch-peak-start.timer orch-peak-reenable.timer orch-peak-reenable.service orch-ctx.timer; do
  [ -f "$ROOT/ops/server/root/systemd/$u" ] || die_pack "нет systemd/$u"
done

# ── sandbox install для orch-peak ─────────────────────────────────────────
SBIN_DST="$WORK/sbin"
BIN_DST="$WORK/bin"
ETC_DST="$WORK/etc"
mkdir -p "$SBIN_DST" "$BIN_DST" "$ETC_DST"

sandbox_install() {
  cp "$1" "$SBIN_DST/orch-peak"
  chmod +x "$SBIN_DST/orch-peak"
  cp "$ROOT/ops/server/user/orch-loop" "$BIN_DST/orch-loop"
  chmod +x "$BIN_DST/orch-loop"
  for u in orch-peak@.service orch-peak-warn.timer orch-peak-stop.timer orch-peak-start.timer orch-peak-reenable.timer orch-peak-reenable.service orch-ctx.timer; do
    cp "$ROOT/ops/server/root/systemd/$u" "$ETC_DST/$u"
  done
}

verify_run() {
  OPS_SERVER_SRC="$ROOT/ops/server" \
  OPS_SERVER_BIN_DST="$BIN_DST" \
  OPS_SERVER_SBIN_DST="$SBIN_DST" \
  OPS_SERVER_ETC_DST="$ETC_DST" \
    bash "$ROOT/ops/server/install.sh" verify 2>&1
}

# Строки, которые должны присутствовать (после реализации) /
# отсутствовать (pre-implementation).
PHRASE_OK='новых спавнов не начинай, дождись завершения текущей субагентов, затем перезапуск дверью'

# (s6) orch-peak WITHOUT phrase: копия current минус строка фразы
S6="$WORK/orch-peak-s6"
cp "$ORCHPEAK_SRC" "$S6"
if grep -qF "$PHRASE_OK" "$S6"; then
  sed -i "\|$PHRASE_OK|d" "$S6"
fi

# (s7) orch-peak WITHOUT polling var: удаляются ВСЕ строки, содержащие
# ORCH_HARD_GRACE / ORCH_HARD_POLL — форма строки (присваивание,
# подстановка, отступ) — выбор реализатора, стаб обязан быть
# различим при любой форме
S7="$WORK/orch-peak-s7"
cp "$ORCHPEAK_SRC" "$S7"
sed -i '/ORCH_HARD_GRACE/d; /ORCH_HARD_POLL/d' "$S7"

# (s8) orch-peak WITHOUT report string
S8="$WORK/orch-peak-s8"
cp "$ORCHPEAK_SRC" "$S8"
if grep -qF 'живые субагенты погибнут' "$S8"; then
  sed -i '/живые субагенты погибнут/d' "$S8"
fi

# reference (fixed) orch-peak для диффпробы s6/s7/s8: копия current +
# инъекция фраз/var/report (НЕ зависит от того, есть ли фикс в репо
# сейчас; reference — «fixed» образец для теста grep).
SREF="$WORK/orch-peak-ref"
cp "$ORCHPEAK_SRC" "$SREF"
if ! grep -qF "$PHRASE_OK" "$SREF"; then
  printf '\n# === injected for diff-probe (in %s) ===\n%s\n' "$SREF" "$PHRASE_OK" >> "$SREF"
fi
if ! grep -qF 'ORCH_HARD_GRACE' "$SREF"; then
  printf 'ORCH_HARD_GRACE="${ORCH_HARD_GRACE:-1800}"\nORCH_HARD_POLL="${ORCH_HARD_POLL:-60}"\n' >> "$SREF"
fi
if ! grep -qF 'живые субагенты погибнут' "$SREF"; then
  printf '%s\n' 'живые субагенты погибнут' >> "$SREF"
fi

# ── СЧЁТЧИКИ ─────────────────────────────────────────────────────────────
STAB_CAUGHT=0
DIFF_GREEN=0
HONEST_GREEN=0
HONEST_TOTAL=21

# ── ХЕЛПЕРЫ предикатов ───────────────────────────────────────────────────
fail_cell() { printf 'клетка %s: %s\n' "$1" "$2" >&2; CELL_FAIL=1; }

p_pass() {
  local name="$1"
  local rc; rc=$(cat "$WORK/_rc" 2>/dev/null || echo "?")
  local stdout; stdout=$(cat "$WORK/stdout" 2>/dev/null || echo "")
  local marker; marker=$(stat -c %Y "$WORK/marker" 2>/dev/null || echo "")
  if [ "$rc" = "0" ] && [ -n "$marker" ] && printf '%s' "$stdout" | grep -qF 'ПЕРЕЗАПУСК'; then
    : # ok
  else
    fail_cell "$name" "rc=$rc marker=$marker stdout=$stdout (ожидалось: rc=0, marker есть, stdout «ПЕРЕЗАПУСК»)"
  fi
}

p_refuse() {
  local name="$1" sub="$2"
  local rc; rc=$(cat "$WORK/_rc" 2>/dev/null || echo "?")
  local stderr; stderr=$(cat "$WORK/stderr" 2>/dev/null || echo "")
  local marker; marker=$(stat -c %Y "$WORK/marker" 2>/dev/null || echo "")
  if [ "$rc" = "1" ] && [ -z "$marker" ] && printf '%s' "$stderr" | grep -qF -- "$sub"; then
    : # ok
  else
    fail_cell "$name" "rc=$rc marker=$marker stderr=$stderr (ожидалось: rc=1, marker пуст, stderr содержит «$sub»)"
  fi
}

# ── Прогон subject в toy-мире ─────────────────────────────────────────────────────────────
# run_subject <toy> <subject> <rcfile> <stderr_file> <stdout_file> <SESS_DIR> [ARGs …]
run_subject() {
  local t="$1" subj="$2" rcfile="$3" stderr_file="$4" stdout_file="$5" sess="$6"
  shift 6
  rm -f "$WORK/marker"
  toy_door2 "$t" "$subj" "$ROOT"
  (
    cd "$t"
      export ORCH_RESTART_MARKER="$WORK/marker"
      export ORCH_SESSION_START="$WORK/trace"
      export ORCH_SESS_DIR="$sess"
      bash scripts/orch_restart.sh "$@" >"$stdout_file" 2>"$stderr_file"
      echo $? > "$rcfile"
    ) >/dev/null 2>&1 || true
}

# Запуск subject с env
run_subject_env() {
  local t="$1" subj="$2" rcfile="$3" stderr_file="$4" stdout_file="$5" sess="$6"
  shift 6
  rm -f "$WORK/marker"
  toy_door2 "$t" "$subj" "$ROOT"
  (
    cd "$t"
      export ORCH_RESTART_MARKER="$WORK/marker"
      export ORCH_SESSION_START="$WORK/trace"
      export ORCH_SESS_DIR="$sess"
      export "$@"
      bash scripts/orch_restart.sh >"$stdout_file" 2>"$stderr_file"
      echo $? > "$rcfile"
    ) >/dev/null 2>&1 || true
}

# Клетка: имя, subject, имя клетки, предикат (p_pass/p_refuse), аргументы
run_cell_door() {
  local name="$1" subj="$2" cell="$3" predicate="$4"
  shift 4
  local t="$WORK/door-$$"
  local sess="$WORK/sess-$$"
  rm -rf "$sess"
  CELL_FAIL=0
  case "$cell" in
    a1)
      run_subject_env "$t" "$subj" "$WORK/_rc" "$WORK/stderr" "$WORK/stdout" "$sess" \
        GIT_AUTHOR_NAME=architect
      ;;
    a2)
      run_subject "$t" "$subj" "$WORK/_rc" "$WORK/stderr" "$WORK/stdout" "$sess" --as architect
      ;;
    a3)
      run_subject "$t" "$subj" "$WORK/_rc" "$WORK/stderr" "$WORK/stdout" "$sess"
      ;;
    a4)
      # env + --as no value
      (
        cd "$t"
        rm -f "$WORK/marker"
        export ORCH_RESTART_MARKER="$WORK/marker"
        export ORCH_SESSION_START="$WORK/trace"
        export ORCH_SESS_DIR="$sess"
        export GIT_AUTHOR_NAME="architect"
        toy_door2 "$t" "$subj" "$ROOT"
        bash scripts/orch_restart.sh --as >"$WORK/stdout" 2>"$WORK/stderr"
        echo $? > "$WORK/_rc"
      ) >/dev/null 2>&1 || true
      ;;
    a5)
      run_subject "$t" "$subj" "$WORK/_rc" "$WORK/stderr" "$WORK/stdout" "$sess" --as foo --as bar
      ;;
    б1)
      rm -rf "$sess"
      subagent_journal "$sess" LiveAgent 30
      run_subject_env "$t" "$subj" "$WORK/_rc" "$WORK/stderr" "$WORK/stdout" "$sess" \
        GIT_AUTHOR_NAME=architect
      ;;
    б2)
      rm -rf "$sess"
      subagent_journal "$sess" OldAgent 300
      run_subject_env "$t" "$subj" "$WORK/_rc" "$WORK/stderr" "$WORK/stdout" "$sess" \
        GIT_AUTHOR_NAME=architect
      ;;
    б3)
      rm -rf "$sess"
      run_subject_env "$t" "$subj" "$WORK/_rc" "$WORK/stderr" "$WORK/stdout" "$sess" \
        GIT_AUTHOR_NAME=architect
      ;;
    *) die_pack "неизвестная дверная клетка: $cell" ;;
  esac
  $predicate "$name" "${@:-identity двери не определена}"
  rm -rf "$t" "$t-origin.git" "$sess"
  [ "$CELL_FAIL" = 0 ]
}
# Клетка для orch-peak (s6/s7/s8)
run_cell_peak() { # $1=name $3stub=$4 $4=cell $5=marker-phrase
  local name="$1" subj="$2" cell="$3" phrase="$4"
  CELL_FAIL=0
  case "$cell" in
    в1)
      # grep phrase in subject; expect present (post-fix) — но для stub
      # s6 — expect absent. Здесь run_cell_peak используется ТОЛЬКО для
      # тестирования ref vs stub в диффпробе — см. run_peak_diff_probe.
      if grep -qF "$phrase" "$subj"; then : ; else fail_cell "$name" "grep не нашёл «$phrase»"; fi
      ;;
    г1)
      if grep -qF "$phrase" "$subj"; then : ; else fail_cell "$name" "grep не нашёл «$phrase»"; fi
      ;;
    г2)
      if grep -qF "$phrase" "$subj"; then : ; else fail_cell "$name" "grep не нашёл «$phrase»"; fi
      ;;
  esac
  [ "$CELL_FAIL" = 0 ]
}

# ── Стаб vs clean-stub (стаб-проверки) ─────────────────────────────────
# stab_probe_rc <subj> <cell>: создаёт toy с subj, прогоняет cell,
# возвращает rc.
stab_probe_rc() {
  local subj="$1" cell="$2"
  local t="$WORK/door-stab"
  local sess="$WORK/sess-stab"
  rm -rf "$sess"
  CELL_FAIL=0
  case "$cell" in
    a1)
      run_subject_env "$t" "$subj" "$WORK/_rc_stab" "$WORK/stderr_stab" "$WORK/stdout_stab" "$sess" \
        GIT_AUTHOR_NAME=architect
      ;;
    a2)
      run_subject "$t" "$subj" "$WORK/_rc_stab" "$WORK/stderr_stab" "$WORK/stdout_stab" "$sess" --as architect
      ;;
    a4)
      (
        cd "$t"
        rm -f "$WORK/marker"
        export ORCH_RESTART_MARKER="$WORK/marker"
        export ORCH_SESSION_START="$WORK/trace"
        export ORCH_SESS_DIR="$sess"
        export GIT_AUTHOR_NAME="architect"
        toy_door2 "$t" "$subj" "$ROOT"
        bash scripts/orch_restart.sh --as >"$WORK/stdout_stab" 2>"$WORK/stderr_stab"
        echo $? > "$WORK/_rc_stab"
      ) >/dev/null 2>&1 || true
      ;;
    a5)
      run_subject "$t" "$subj" "$WORK/_rc_stab" "$WORK/stderr_stab" "$WORK/stdout_stab" "$sess" --as foo --as bar
      ;;
    б1)
      rm -rf "$sess"
      subagent_journal "$sess" LiveAgent 30
      run_subject_env "$t" "$subj" "$WORK/_rc_stab" "$WORK/stderr_stab" "$WORK/stdout_stab" "$sess" \
        GIT_AUTHOR_NAME=architect
      ;;
  esac
  rm -rf "$t" "$t-origin.git" "$sess"
  cat "$WORK/_rc_stab" 2>/dev/null
}
# ADDITIONAL DEBUG: dump _rc_stab after the call
dump_debug() {
  echo "DEBUG: _rc_stab=$(cat $WORK/_rc_stab 2>/dev/null) stderr_stab=$(cat $WORK/stderr_stab 2>/dev/null)"
}

clean_probe_rc() {
  local cell="$1"
  local t="$WORK/door-clean"
  local sess="$WORK/sess-clean"
  rm -rf "$sess"
  case "$cell" in
    a1)
      run_subject_env "$t" "$DIFFPROBE" "$WORK/_rc_clean" "$WORK/stderr_clean" "$WORK/stdout_clean" "$sess" \
        GIT_AUTHOR_NAME=architect
      ;;
    a2)
      run_subject "$t" "$DIFFPROBE" "$WORK/_rc_clean" "$WORK/stderr_clean" "$WORK/stdout_clean" "$sess" --as architect
      ;;
    a4)
      (
        cd "$WORK/door-clean"
        rm -f "$WORK/marker"
        export ORCH_RESTART_MARKER="$WORK/marker"
        export ORCH_SESSION_START="$WORK/trace"
        export ORCH_SESS_DIR="$sess"
        export GIT_AUTHOR_NAME="architect"
        toy_door2 "$t" "$DIFFPROBE" "$ROOT"
        bash scripts/orch_restart.sh --as >"$WORK/stdout_clean" 2>"$WORK/stderr_clean"
        echo $? > "$WORK/_rc_clean"
      ) >/dev/null 2>&1 || true
      ;;
    a5)
      run_subject "$t" "$DIFFPROBE" "$WORK/_rc_clean" "$WORK/stderr_clean" "$WORK/stdout_clean" "$sess" --as foo --as bar
      ;;
    б1)
      rm -rf "$sess"
      subagent_journal "$sess" LiveAgent 30
      run_subject_env "$t" "$DIFFPROBE" "$WORK/_rc_clean" "$WORK/stderr_clean" "$WORK/stdout_clean" "$sess" \
        GIT_AUTHOR_NAME=architect
      ;;
    diff_green)
      # clean-stub на чистом входе — все условия зелёные, должно быть rc 0
      rm -rf "$sess"
      run_subject_env "$t" "$DIFFPROBE" "$WORK/_rc_clean" "$WORK/stderr_clean" "$WORK/stdout_clean" "$sess" \
        GIT_AUTHOR_NAME=architect
      ;;
  esac
  rm -rf "$t" "$t-origin.git" "$sess"
  cat "$WORK/_rc_clean" 2>/dev/null
}

run_stab_cell() { # $1=name $2=stub-path $3=cell
  local name="$1" stub="$2" cell="$3"
  local s_rc c_rc
  s_rc=$(stab_probe_rc "$stub" "$cell")
  c_rc=$(clean_probe_rc "$cell")
  if [ "$s_rc" != "$c_rc" ]; then
    STAB_CAUGHT=$((STAB_CAUGHT + 1))
  else
    fail_cell "стаб-$name" "stab_rc=$s_rc clean_rc=$c_rc (ожидалось РАЗЛИЧИЕ)"
  fi
  # Диффпроба: clean-stub на чистом входе → rc 0
  local dg_rc
  dg_rc=$(clean_probe_rc diff_green)
  if [ "$dg_rc" = "0" ]; then
    DIFF_GREEN=$((DIFF_GREEN + 1))
  else
    fail_cell "дифф-$name" "clean-stub на чистом входе: rc=$dg_rc (ожидалось 0)"
  fi
}

run_peak_stab_cell() { # $1=name $2=stub-path $3=cell $4=phrase
  CELL_FAIL=0
  if grep -qF "$4" "$2"; then
    fail_cell "стаб-$1" "ожидалось отсутствие «$4» в $2, найдено"
  else
    STAB_CAUGHT=$((STAB_CAUGHT + 1))
  fi
  # reference (fixed) должна содержать phrase
  if grep -qF "$4" "$SREF"; then
    DIFF_GREEN=$((DIFF_GREEN + 1))
  else
    fail_cell "дифф-$1" "reference $SREF не содержит «$4» (батарея битая)"
  fi
}

# ── Поведенческий мир orch-peak (шов ORCH_PEAK_TEST, инв. 4 контракта) ──────
# peak_world <dir> <usage-tokens> <agent|пусто> <age-sec|пусто=без журнала>:
#   session-level .jsonl (cur_ctx читает usage через jq) + каталог сессии
#   (совпадает с basename session-файла — та же конвенция, что у живых
#   журналов) с субагентским <agent>.jsonl управляемого mtime + чистый
#   toy-repo для ORCH_REPO (unsaved/wait_saved) + omp-pids файл шва.
PEAK_SESS="20261003T120000_00000000-1111-2222-3333-444444444444"
peak_world() {
  local w="$1" usage="$2" agent="$3" age="$4"
  rm -rf "$w"
  mkdir -p "$w/peak-sess/$PEAK_SESS" "$w/testdir/state" "$w/repo"
  printf '{"message":{"usage":{"input":%s,"cacheRead":0,"cacheWrite":0}}}\n' "$usage" \
    > "$w/peak-sess/$PEAK_SESS.jsonl"
  if [ -n "$agent" ]; then
    : > "$w/peak-sess/$PEAK_SESS/$agent.jsonl"
    [ -n "$age" ] && touch -d "@$(( $(date +%s) - age ))" "$w/peak-sess/$PEAK_SESS/$agent.jsonl"
  fi
  printf '424242\n' > "$w/testdir/omp-pids"
  (
    cd "$w/repo" || return 1
    git init -q -b main
    printf '## GDE (peak toy 080)\n' > HANDOFF.md
    git init -q --bare -b main origin.git
    git remote add origin "$PWD/origin.git"
    git add -A
    git -c user.name=architect -c user.email=architect@dev-harness.local \
      commit -qm "toy: peak repo"
    git push -q origin main >/dev/null 2>&1 || true
  ) >/dev/null 2>&1
}

# run_peak_ctx <world-dir> <subject> [env NAME=VAL …] — запуск `ctx` в мире.
#   Наблюдаемые выходы: $w/rc, $w/testdir/say.log (шов say), $w/mark,
#   $w/report (явные ORCH_MARK/ORCH_REPORT). ORCH_TMUX_SOCK — несуществующий
#   сокет: реальные tmux-панели станции не тронуты ни до, ни после правки.
run_peak_ctx_env() {
  local w="$1" subj="$2"
  shift 2
  rm -f "$w/rc" "$w/rc_stderr" "$w/mark" "$w/report" \
        "$w/testdir/say.log" "$w/testdir/report" "$w/testdir/mark"
  (
    cd "$w" || exit 1
    export ORCH_USER="$(id -un)"
    export ORCH_REPO="$w/repo"
    export ORCH_MARK="$w/mark"
    export ORCH_REPORT="$w/report"
    export ORCH_PEAK_TEST="$w/testdir"
    export ORCH_SESS_GLOB="$w/peak-sess/*.jsonl"
    export ORCH_TMUX_SOCK="$w/no-tmux-socket"
    export ORCH_STATE="$w/testdir/state"
    export ORCH_LOG="$w/testdir/log"
    export ORCH_CTX_SOFT=300000
    export ORCH_CTX_HARD=500000
    export "$@"
    timeout 30 bash "$subj" ctx >/dev/null 2>"$w/rc_stderr"
    echo $? > "$w/rc"
  ) >/dev/null 2>&1 || true
}

# Фоновый вариант для клетки г7 (состаривание журнала ПОКА субъект ждёт).
run_peak_ctx_bg() {
  local w="$1" subj="$2"
  shift 2
  rm -f "$w/rc" "$w/rc_stderr" "$w/mark" "$w/report" \
        "$w/testdir/say.log" "$w/testdir/report" "$w/testdir/mark"
  (
    cd "$w" || exit 1
    export ORCH_USER="$(id -un)"
    export ORCH_REPO="$w/repo"
    export ORCH_MARK="$w/mark"
    export ORCH_REPORT="$w/report"
    export ORCH_PEAK_TEST="$w/testdir"
    export ORCH_SESS_GLOB="$w/peak-sess/*.jsonl"
    export ORCH_TMUX_SOCK="$w/no-tmux-socket"
    export ORCH_STATE="$w/testdir/state"
    export ORCH_LOG="$w/testdir/log"
    export ORCH_CTX_SOFT=300000
    export ORCH_CTX_HARD=500000
    export "$@"
    timeout 30 bash "$subj" ctx >/dev/null 2>"$w/rc_stderr"
    echo $? > "$w/rc"
  ) >/dev/null 2>&1 &
}

# helpers ноги (д') (sandbox check_staged) ─
setup_cs_sandbox() {
  local s="$1" wn="$2" we="$3"
  rm -rf "$s"
  mkdir -p "$s"
  (
    cd "$s" || return 1
    git init -q -b main
    : > .trigger
    git add .trigger
    git -c user.name=architect -c user.email=architect@dev-harness.local commit -qm "sandbox: init"
    cp -r "$ROOT/scripts" "./scripts"
    if [ "$wn" = 1 ]; then
      git config user.name "leaked-by-sandbox"
    fi
    if [ "$we" = 1 ]; then
      git config user.email "leaked@by-sandbox"
    fi
  ) >/dev/null 2>&1
}

run_cs_subject() {
  local s="$1" staged="$2" rcfile="$3" stderr_file="$4" stdout_file="$5"
  (
    cd "$s" || return 1
    if [ -n "$staged" ]; then
      cp "$staged" "scripts/check_staged.sh"
    fi
    bash scripts/check_staged.sh . >"$stdout_file" 2>"$stderr_file"
    echo $? > "$rcfile"
  ) >/dev/null 2>&1 || true
}

run_cs_subject_env() {
  local s="$1" staged="$2" rcfile="$3" stderr_file="$4" stdout_file="$5"
  (
    cd "$s" || return 1
    if [ -n "$staged" ]; then
      cp "$staged" "scripts/check_staged.sh"
    fi
    export GIT_AUTHOR_NAME="env-bot"
    bash scripts/check_staged.sh . >"$stdout_file" 2>"$stderr_file"
    echo $? > "$rcfile"
  ) >/dev/null 2>&1 || true
}

run_cs_cell() {
  local name="$1" s="$2" staged="$3" wn="$4" we="$5" predicate="$6" expect="$7"
  setup_cs_sandbox "$s" "$wn" "$we"
  CELL_FAIL=0
  if [ "$predicate" = "p_pass" ]; then
    run_cs_subject_env "$s" "$staged" "$WORK/cs_rc" "$WORK/cs_err" "$WORK/cs_out"
  else
    run_cs_subject "$s" "$staged" "$WORK/cs_rc" "$WORK/cs_err" "$WORK/cs_out"
  fi
  local rc; rc=$(cat "$WORK/cs_rc" 2>/dev/null || echo "?")
  local err; err=$(cat "$WORK/cs_err" 2>/dev/null || echo "")
  case "$predicate" in
    p_pass)
      if [ "$rc" = "0" ]; then :; else fail_cell "$name" "rc=$rc err=$err (ожидалось rc=0)"; fi ;;
    p_refuse)
      if [ "$rc" = "1" ] && printf '%s' "$err" | grep -qF -- "$expect"; then
        : # ok
      else
        fail_cell "$name" "rc=$rc err=$err (ожидалось rc=1 stderr содержит «$expect»)"
      fi ;;
  esac
  rm -rf "$s"
}

run_cs_stab_cell() {
  local name="$1" stub="$2"
  local s_stab="$WORK/cs-stab"
  local s_clean="$WORK/cs-clean"
  # Sandbox с user.email (без user.name) + env GIT_AUTHOR_NAME=env-bot.
  # Post-fix: real ловит user.email → rc 1; s9 пропускает (частичная проверка)
  # → identity из env → "не судится" → rc 0. РАЗЛИЧИЕ → пойман.
  setup_cs_sandbox "$s_stab" 0 1
  run_cs_subject_env "$s_stab" "$stub" "$WORK/cs_rc_stab" "$WORK/cs_err_stab" "$WORK/cs_out_stab"
  local s_rc; s_rc=$(cat "$WORK/cs_rc_stab" 2>/dev/null || echo "?")
  setup_cs_sandbox "$s_clean" 0 1
  run_cs_subject_env "$s_clean" "" "$WORK/cs_rc_clean" "$WORK/cs_err_clean" "$WORK/cs_out_clean"
  local c_rc; c_rc=$(cat "$WORK/cs_rc_clean" 2>/dev/null || echo "?")
  if [ "$s_rc" != "$c_rc" ]; then
    STAB_CAUGHT=$((STAB_CAUGHT + 1))
    echo "  stab-$name: caught (s_rc=$s_rc c_rc=$c_rc)"
  else
    fail_cell "стаб-$name" "stab_rc=$s_rc clean_rc=$c_rc (ожидалось РАЗЛИЧИЕ; s9 пропускает email, real — нет)"
  fi
  local s_clean2="$WORK/cs-clean2"
  setup_cs_sandbox "$s_clean2" 0 0
  run_cs_subject_env "$s_clean2" "" "$WORK/cs_rc_clean2" "$WORK/cs_err_clean2" "$WORK/cs_out_clean2"
  local dg_rc; dg_rc=$(cat "$WORK/cs_rc_clean2" 2>/dev/null || echo "?")
  if [ "$dg_rc" = "0" ]; then
    DIFF_GREEN=$((DIFF_GREEN + 1))
    echo "  diff-$name: green (clean stub на чистом входе rc=0)"
  else
    fail_cell "дифф-$name" "clean-stub на чистом входе: rc=$dg_rc (ожидалось 0)"
  fi
  rm -rf "$s_stab" "$s_clean" "$s_clean2"
}

# helpers клетки д'5 (linked worktree — живая проба критика к1):
# sandbox-репозиторий с ЗАКОММИЧЕННОЙ scripts-копией + linked worktree;
# загрязнение ОБЩЕГО config выполняется командой ИЗ worktree
# (git config --local в worktree пишет в общий git-dir — измерено),
# субъект запускается ИЗ worktree.
setup_cs_worktree_sandbox() {
  local s="$1"
  rm -rf "$s" "$s-wt"
  mkdir -p "$s"
  (
    cd "$s" || return 1
    git init -q -b main
    cp -r "$ROOT/scripts" scripts
    : > .trigger
    git add -A
    git -c user.name=architect -c user.email=architect@dev-harness.local \
      commit -qm "sandbox: init + scripts"
    git worktree add -q "$s-wt" -b wt-sandbox
    git -C "$s-wt" config --local user.name "leaked-by-worktree"
    : > "$s-wt/wt.trigger"
    git -C "$s-wt" add wt.trigger
  ) >/dev/null 2>&1
}

run_cs_worktree_cell() {
  local name="$1" s="$2" predicate="$3" expect="$4"
  setup_cs_worktree_sandbox "$s"
  CELL_FAIL=0
  (
    cd "$s-wt" || exit 1
    export GIT_AUTHOR_NAME="env-bot"
    bash scripts/check_staged.sh . >"$WORK/csw_out" 2>"$WORK/csw_err"
    echo $? > "$WORK/csw_rc"
  ) >/dev/null 2>&1 || true
  local rc; rc=$(cat "$WORK/csw_rc" 2>/dev/null || echo "?")
  local err; err=$(cat "$WORK/csw_err" 2>/dev/null || echo "")
  case "$predicate" in
    p_refuse)
      if [ "$rc" = "1" ] && printf '%s' "$err" | grep -qF -- "$expect"; then
        : # ok
      else
        fail_cell "$name" "rc=$rc err=$err (ожидалось rc=1 stderr содержит «$expect»; прямой ROOT/.git/config в worktree не видит загрязнения — до реализации нога (д') отсутствует)"
      fi ;;
  esac
  rm -rf "$s" "$s-wt"
}

# ── Прогон пака стабов ──────────────────────────────────────────────────
run_stab_cell s1 "$S1" a1
run_stab_cell s2 "$S2" a1
run_stab_cell s3 "$S3" a4
run_stab_cell s4 "$S4" б1
run_stab_cell s5 "$S5" a5
run_peak_stab_cell s6 "$S6" в1 "$PHRASE_OK"
run_peak_stab_cell s7 "$S7" г1 'ORCH_HARD_GRACE'
run_peak_stab_cell s8 "$S8" г2 'живые субагенты погибнут'

# (s9) — нога (д') в check_staged.sh проверяет ТОЛЬКО user.name;
# тест привязан к д'2-входу (sandbox с user.email, без user.name) +
# env GIT_AUTHOR_NAME=env-bot (чтобы identity была валидна и post-fix
# real reject'нул по (д') с rc 1, а s9 пропустил — rc 0 «не судится»).
# Pre-fix: оба fail-closed → одинаковый rc → не пойман.
# Post-fix: real rc 1, s9 rc 0 → DIFFERENT → пойман.
# diffprobe (д'3): real check_staged на чистом sandbox без user.* +
# env identity → rc 0.
run_cs_stab_cell s9 "$S9"

# ── ЧЕСТНАЯ ЧАСТЬ ────────────────────────────────────────────────────────
echo "── честная часть (real subjects) ──"

# (a1) env identity, no file-config → rc 0 (post-fix); pre-fix rc 2
run_cell_door a1 "$ROOT/scripts/orch_restart.sh" a1 p_pass
[ "$CELL_FAIL" = 0 ] && HONEST_GREEN=$((HONEST_GREEN + 1))

# (a2) --as architect, no env → rc 0 (post-fix); pre-fix rc 2
run_cell_door a2 "$ROOT/scripts/orch_restart.sh" a2 p_pass
[ "$CELL_FAIL" = 0 ] && HONEST_GREEN=$((HONEST_GREEN + 1))

# (a3) no env, no --as → rc 1 «identity двери не определена»; pre-fix rc 2
run_cell_door a3 "$ROOT/scripts/orch_restart.sh" a3 p_refuse
[ "$CELL_FAIL" = 0 ] && HONEST_GREEN=$((HONEST_GREEN + 1))

# (a4) --as (no value) → rc 1 «identity двери не определена»; pre-fix rc 2
run_cell_door a4 "$ROOT/scripts/orch_restart.sh" a4 p_refuse
[ "$CELL_FAIL" = 0 ] && HONEST_GREEN=$((HONEST_GREEN + 1))

# (a5) --as foo --as bar → rc 1 «--as задан дважды»; pre-fix rc 2
run_cell_door a5 "$ROOT/scripts/orch_restart.sh" a5 p_refuse
[ "$CELL_FAIL" = 0 ] && HONEST_GREEN=$((HONEST_GREEN + 1))

# (б1) свежий журнал → rc 1 «живые субагенты: …»; pre-fix rc 0 marker set
run_cell_door б1 "$ROOT/scripts/orch_restart.sh" б1 p_refuse
[ "$CELL_FAIL" = 0 ] && HONEST_GREEN=$((HONEST_GREEN + 1))

# (б2) старый журнал → rc 0; pre-fix rc 0 (passes through)
run_cell_door б2 "$ROOT/scripts/orch_restart.sh" б2 p_pass
[ "$CELL_FAIL" = 0 ] && HONEST_GREEN=$((HONEST_GREEN + 1))

# (б3) сессия без журналов → rc 0; pre-fix rc 0
run_cell_door б3 "$ROOT/scripts/orch_restart.sh" б3 p_pass
[ "$CELL_FAIL" = 0 ] && HONEST_GREEN=$((HONEST_GREEN + 1))

# ── ПОВЕДЕНЧЕСКИЕ клетки сторожа (шов ORCH_PEAK_TEST) ─────────────────────
# (в3) SOFT: сообщение с фразой ДОСТАВЛЕНО (say.log шва), маркер не ставится.
W3="$WORK/peak-v3"
peak_world "$W3" 400000 "" ""
run_peak_ctx_env "$W3" "$ORCHPEAK_SRC"
CELL_FAIL=0
if grep -qF "$PHRASE_OK" "$W3/testdir/say.log" 2>/dev/null && [ ! -e "$W3/mark" ]; then
  HONEST_GREEN=$((HONEST_GREEN + 1))
else
  fail_cell в3 "say.log=[$(cat "$W3/testdir/say.log" 2>/dev/null)] mark=$([ -e "$W3/mark" ] && echo есть || echo нет) (ожидалось: фраза в say.log, маркера нет — до реализации шов ORCH_PEAK_TEST не поддержан)"
fi

# (г6) HARD, свежих нет на входе: маркер ставится, отчёта «погибнут» нет.
W6="$WORK/peak-g6"
peak_world "$W6" 600000 OldPeakAgent 300
run_peak_ctx_env "$W6" "$ORCHPEAK_SRC" \
  ORCH_HARD_GRACE=5 ORCH_HARD_POLL=1 ORCH_PEAK_GRACE=1 ORCH_PEAK_POLL=1
CELL_FAIL=0
if [ -e "$W6/mark" ] && ! grep -qF 'живые субагенты погибнут' "$W6/report" 2>/dev/null; then
  HONEST_GREEN=$((HONEST_GREEN + 1))
else
  fail_cell г6 "mark=$([ -e "$W6/mark" ] && echo есть || echo нет) report=[$(cat "$W6/report" 2>/dev/null)] (ожидалось: маркер поставлен, «погибнут» в отчёте НЕТ — до реализации шов не поддержан: as_u/runuser отказывает без root, маркер не ставится)"
fi

# (г7) HARD, свежий состарился ДО таймаута: маркер ПОСЛЕ состаривания
# (до состаривания маркера нет — наблюдается ожидание), отчёта «погибнут» нет.
W7="$WORK/peak-g7"
peak_world "$W7" 600000 LivePeakAgent 0
run_peak_ctx_bg "$W7" "$ORCHPEAK_SRC" \
  ORCH_HARD_GRACE=8 ORCH_HARD_POLL=1 ORCH_PEAK_GRACE=1 ORCH_PEAK_POLL=1
sleep 2
CELL_FAIL=0
if [ -e "$W7/mark" ]; then
  fail_cell г7 "маркер поставлен ДО состаривания журнала (на T+2s журнал ещё свежий — до реализации опрос свежести отсутствует, предмет (г) не реализован)"
else
  touch -d "@$(( $(date +%s) - 300 ))" "$W7/peak-sess/$PEAK_SESS/LivePeakAgent.jsonl"
  for _ in $(seq 1 40); do [ -s "$W7/rc" ] && break; sleep 1; done
  if [ -e "$W7/mark" ] && ! grep -qF 'живые субагенты погибнут' "$W7/report" 2>/dev/null; then
    HONEST_GREEN=$((HONEST_GREEN + 1))
  else
    fail_cell г7 "после состаривания: mark=$([ -e "$W7/mark" ] && echo есть || echo нет) report=[$(cat "$W7/report" 2>/dev/null)] (ожидалось: маркер поставлен, «погибнут» НЕТ)"
  fi
fi

# (г8) HARD, свежий НЕ состарился за ORCH_HARD_GRACE: принудительный маркер
# + отчёт «живые субагенты погибнут: <имя>» (окно свежести 120s ≫ grace 3s).
W8="$WORK/peak-g8"
peak_world "$W8" 600000 LivePeak2 0
run_peak_ctx_env "$W8" "$ORCHPEAK_SRC" \
  ORCH_HARD_GRACE=3 ORCH_HARD_POLL=1 ORCH_PEAK_GRACE=1 ORCH_PEAK_POLL=1
CELL_FAIL=0
if [ -e "$W8/mark" ] && grep -qF 'живые субагенты погибнут: LivePeak2' "$W8/report" 2>/dev/null; then
  HONEST_GREEN=$((HONEST_GREEN + 1))
else
  fail_cell г8 "mark=$([ -e "$W8/mark" ] && echo есть || echo нет) report=[$(cat "$W8/report" 2>/dev/null)] (ожидалось: принудительный маркер + «живые субагенты погибнут: LivePeak2» в отчёте — до реализации шов не поддержан)"
fi

# Клетки в1-в2, г1-г2 (real ops/server/root/orch-peak + install.sh verify)
sandbox_install "$ORCHPEAK_SRC"
CELL_FAIL=0
vout="$(verify_run)"
vrc=$?
if [ "$vrc" = 0 ]; then
  HONEST_GREEN=$((HONEST_GREEN + 1))
else
  fail_cell в2 "install.sh verify: rc=$vrc, вывод: $vout"
fi

CELL_FAIL=0
if grep -qF "$PHRASE_OK" "$ORCHPEAK_SRC"; then
  HONEST_GREEN=$((HONEST_GREEN + 1))
else
  fail_cell в1 "grep фразы в $ORCHPEAK_SRC не нашёл (предмет в не реализован)"
fi

CELL_FAIL=0
if grep -qF 'ORCH_HARD_GRACE' "$ORCHPEAK_SRC"; then
  HONEST_GREEN=$((HONEST_GREEN + 1))
else
  fail_cell г1 "grep ORCH_HARD_GRACE в $ORCHPEAK_SRC не нашёл"
fi

CELL_FAIL=0
if grep -qF 'живые субагенты погибнут' "$ORCHPEAK_SRC"; then
  HONEST_GREEN=$((HONEST_GREEN + 1))
else
  fail_cell г2 "grep «живые субагенты погибнут» в $ORCHPEAK_SRC не нашёл"
fi

# (д'1) sandbox с user.name в .git/config → rc 1 «identity в общем .git/config запрещена»
run_cs_cell "д'1" "$WORK/cs-d1" "" 1 0 p_refuse "identity в общем .git/config запрещена"
[ "$CELL_FAIL" = 0 ] && HONEST_GREEN=$((HONEST_GREEN + 1))

# (д'2) sandbox с user.email (без user.name) → rc 1 тот же маркер
run_cs_cell "д'2" "$WORK/cs-d2" "" 0 1 p_refuse "identity в общем .git/config запрещена"
[ "$CELL_FAIL" = 0 ] && HONEST_GREEN=$((HONEST_GREEN + 1))

# (д'3) sandbox без user.*, identity коммита через -c: git пробрасывает
# -c-значения в hook-окружение как GIT_AUTHOR_* (измерено, шапка
# check_staged.sh), клетка моделирует hook-окружение env-прогоном → rc 0
run_cs_cell "д'3" "$WORK/cs-d3" "" 0 0 p_pass ""
[ "$CELL_FAIL" = 0 ] && HONEST_GREEN=$((HONEST_GREEN + 1))

# (д'4) sandbox без user.*, identity через env сессии (без -c) → rc 0
run_cs_cell "д'4" "$WORK/cs-d4" "" 0 0 p_pass ""
[ "$CELL_FAIL" = 0 ] && HONEST_GREEN=$((HONEST_GREEN + 1))

# (д'5) linked worktree: загрязнение ОБЩЕГО config из worktree (живая
# проба критика к1 — прямой $ROOT/.git/config в worktree не видит его);
# субъект запущен ИЗ worktree → rc 1 с маркером (д')
run_cs_worktree_cell "д'5" "$WORK/cs-d5" p_refuse "identity в общем .git/config запрещена"
[ "$CELL_FAIL" = 0 ] && HONEST_GREEN=$((HONEST_GREEN + 1))

# ── ИТОГ ────────────────────────────────────────────────────────────────
echo ""
printf 'стаб-пак: %d/9 поймано, диффпроба %d/9\n' "$STAB_CAUGHT" "$DIFF_GREEN"
printf 'честная часть: %d/%d зелёная\n' "$HONEST_GREEN" "$HONEST_TOTAL"
printf 'итог 080-батареи: предъявлений стабы %d/9 + дифф %d/9 + честные %d/%d\n' \
  "$STAB_CAUGHT" "$DIFF_GREEN" "$HONEST_GREEN" "$HONEST_TOTAL"

if [ "$STAB_CAUGHT" -ne 9 ] || [ "$DIFF_GREEN" -ne 9 ] || [ "$HONEST_GREEN" -ne "$HONEST_TOTAL" ]; then
  die_pack "батарея красная: стабы=$STAB_CAUGHT/9 дифф=$DIFF_GREEN/9 честные=$HONEST_GREEN/$HONEST_TOTAL"
fi
exit 0