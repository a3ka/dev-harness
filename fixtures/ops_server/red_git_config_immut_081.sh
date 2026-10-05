#!/usr/bin/env bash
# Красная батарея 081 (смена предмета 2026-10-04): общий .git/config неприкосновен
# НЕИЗМЕНЯЕМОСТЬЮ ФС (chattr +i), не стражем текста команды. Прежний механизм
# (детектор форм git config/remote/branch в path-guard.ts, круги 1-6) снят словом
# владельца; прежняя батарея fixtures/path_guard/red_git_config_immut_081.sh удалена.
#
# Образец живых измерений — root-проба консультанта
# /tmp/dev-harness-verify/consultant/immut-test.sh: chattr +i на .git/config
# основного чекаута; формы инцидентов падают на ядре, обычная работа проходит.
#
# Режимы:
#   real (умолчание): запирание chattr +i — требует euid 0 / CAP_LINUX_IMMUTABLE.
#     Если chattr-проба падает (нет root) — rc 2 NOT_IMPLEMENTED, НЕ зелёный.
#   IMMU_MOCK=1: запирание = LD_PRELOAD-шим «chattr-подобный ит»: EPERM на
#     open-на-запись / rename / unlink перечисленных путей (список-состояние).
#     ЧЕСТНО: chmod 0444 НЕ моделирует +i — git пишет config через config.lock +
#     rename, chmod rename не мешает (измерено живьём 2026-10-04: все записи
#     прошли rc 0, а последующий push ушёл на подменённый remote и завис).
#     Шим имитирует ядро, НЕ JS-страж: отказ получает сам git в syscall.
#     lsattr для детектора, chattr/chown/id для установщика — моки; состояние
#     списка единое для шима/моков. Каждая строка итога помечена [MOCK].
#     В мок-режиме нужен gcc (компиляция шима); нет gcc — rc 2 NOT_IMPLEMENTED.
#
# Клетки (приёмочные сценарии контракта 081, грамматика 050):
#   R1 основной чекаут (cd MAIN && git config user.name)      — отказ ядра, значение НЕ записано
#   R2 через worktree (git -C <wt> config user.name)          — отказ ядра, значение НЕ записано
#   R3 через GIT_DIR (GIT_DIR=MAIN/.git git config user.name) — отказ ядра, значение НЕ записано
#   R4 из скрипта (bash-файл с git config внутри)             — отказ ядра, значение НЕ записано
#   R5 remote set-url через основной чекаут                   — отказ ядра, url НЕ изменён
#   R6 branch --set-upstream-to через основной чекаут         — отказ ядра в stderr,
#      upstream НЕ записан (замер: git выходит rc 0 — клетка судит значение)
#   R7 git config --worktree (в одиноком репо ТИХО пишет в общий config —
#      замер 2026-10-04; в репо с linked worktrees git сам отказывает rc 128) —
#      под замком отказ ядра, в общий config не попадает
#   G1..G10 обычная работа: commit(-c)/push/fetch/branch/worktree add/
#      worktree commit/worktree remove/branch -D/gc/config --get — rc 0
#   D1 детектор зелёный на запертом чистом репо (субъект scripts/check_git_config_immut.sh;
#      до реализации клетка КРАСНАЯ — батарея red-first)
#   D2 снятие атрибута → детектор rc 1, причина «+i отсутствует»
#   D3 ЗАПЕРТЫЙ репо + extensions.worktreeConfig=true → rc 1, причина
#      «extensions.worktreeConfig» (нога (б) наблюдаема при СТОЯЩЕМ атрибуте —
#      порядок И-4 (а)→(б)→(б2) исполняется честно; критик Б2)
#   D4 ЗАПЕРТЫЙ репо + подсунутый .git/config.worktree → rc 1, причина
#      «config.worktree существует» (нога (б2), та же согласованность)
#   D4b ЗАПЕРТЫЙ репо с linked worktree: основной .git/config.worktree ОТСУТСТВУЕТ,
#      существует .git/worktrees/<n>/config.worktree → rc 1, та же причина
#      (форензика ОБЕИХ локаций (б2); критик Б3 — детектор без обхода
#      .git/worktrees/*/ красен здесь)
#   D5 не-абсолютный корень → детектор rc 1, причина «корень обязан быть абсолютным»
#   D6 порядок ног (а)→(б): атрибут СНЯТ ∧ extension=true → причина ТОЛЬКО
#      «+i отсутствует», «extensions.worktreeConfig» НЕ напечатана (критик Б2:
#      ловит детектор, проверяющий extension/форензику прежде атрибута)
#   D7 порядок ног (б)→(б2): атрибут стоит ∧ extension=true ∧ config.worktree →
#      причина ТОЛЬКО «extensions.worktreeConfig», форензика НЕ напечатана
#   I1  install.sh root, core.hooksPath НЕ установлен → rc 1 ДО chattr (chattr не вызван)
#   I1b install.sh root, hooksPath есть, branch.autoSetupMerge НЕ false → rc 1 ДО chattr
#   I2  install.sh root, оба предусловия → rc 0 ∧ chattr ровно на <MAIN>/.git/config
#      ∧ ПОСТУСЛОВИЕ (критик Б1): атрибут СТОИТ после выхода установщика —
#      lsattr показывает i, запись git config в этот config отказывает ядром,
#      значение НЕ записано; мок-журнал судится только в IMMU_MOCK=1
#      (в нём: +i <путь>, НИ ОДНОЙ -i <путь>, ровно одна +i-строка)
#   W1  ops/server/README.md несёт раздел обслуживания И-5 — чек-строки по
#      конвенции к6 074: «Обслуживание .git/config», chattr -i, chattr +i,
#      check_git_config_immut (критик Б6: без раздела клетка красна, red-first)
#
# Итог: rc 0 — все клетки зелёные; rc 1 — есть красные (перечислены); rc 2 —
# NOT_IMPLEMENTED (нет root и нет IMMU_MOCK, либо в мок-режиме нет gcc).
# Итог — код возврата; слово PASS скрипт не печатает.
set -u

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SANDBOX="${TMPDIR:-/tmp}/dev-harness-081-immut"
MOCK="${IMMU_MOCK:-0}"
DET="$REPO/scripts/check_git_config_immut.sh"
INSTALL="$REPO/ops/server/install.sh"
PAT='Operation not permitted|Permission denied|could not (lock|write) config file'

pass=0; fail=0; red=""
ok(){ pass=$((pass+1)); printf 'ок    %s %s%s\n' "$1" "$2" "${3:-}" >&2; }
no(){ fail=$((fail+1)); red="$red $1"; printf 'КРАСНО %s %s\n' "$1" "$2" >&2; }
run(){ out="$("$@" 2>&1)"; rc=$?; }
val(){ git -C "$MAIN" config --local --get "$1" || true; }

rm -rf "$SANDBOX"; mkdir -p "$SANDBOX/bin" "$SANDBOX/state"
IMMUTABLE_LIST="$SANDBOX/state/immutable.list"; : > "$IMMUTABLE_LIST"
CHATTR_LOG="$SANDBOX/state/chattr.log"; : > "$CHATTR_LOG"

# ── моки (только IMMU_MOCK=1) ───────────────────────────────────────────────
if [ "$MOCK" = 1 ]; then
  export MOCK_STATE_DIR="$SANDBOX/state" IMMUTABLE_LIST
  command -v gcc >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: IMMU_MOCK=1 требует gcc для шима\n' >&2; exit 2; }

  # шим «chattr-подобный ит»: EPERM на open-на-запись/rename/unlink путей из списка
  cat > "$SANDBOX/immut_shim.c" <<'SHIM'
#define _GNU_SOURCE
#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/syscall.h>
#include <unistd.h>

static int listed(const char *p) {
  if (!p || !*p) return 0;
  const char *lst = getenv("IMMUT_SHIM_LIST");
  if (!lst) return 0;
  long fd = syscall(SYS_openat, AT_FDCWD, lst, O_RDONLY, 0);
  if (fd < 0) return 0;
  char buf[16384];
  long n = syscall(SYS_read, fd, buf, sizeof buf - 1);
  syscall(SYS_close, fd);
  if (n <= 0) return 0;
  buf[n] = '\0';
  const char *cand = p;
  char abs_p[PATH_MAX];
  if (p[0] != '/') {
    char cwd[PATH_MAX];
    if (getcwd(cwd, sizeof cwd)) {
      if (snprintf(abs_p, sizeof abs_p, "%s/%s", cwd, p) < (int)sizeof abs_p) cand = abs_p;
    }
  }
  char *line = buf;
  while (line) {
    char *nl = strchr(line, '\n');
    if (nl) *nl = '\0';
    if (*line && (!strcmp(line, cand) || !strcmp(line, p))) return 1;
    if (!nl) break;
    line = nl + 1;
  }
  return 0;
}

static int (*r_rename)(const char *, const char *);
int rename(const char *old, const char *new) {
  if (!r_rename) r_rename = dlsym(RTLD_NEXT, "rename");
  if (listed(new) || listed(old)) { errno = EPERM; return -1; }
  return r_rename(old, new);
}
static int (*r_renameat)(int, const char *, int, const char *);
int renameat(int a, const char *b, int c, const char *d) {
  if (!r_renameat) r_renameat = dlsym(RTLD_NEXT, "renameat");
  if (listed(d) || listed(b)) { errno = EPERM; return -1; }
  return r_renameat(a, b, c, d);
}
static int (*r_renameat2)(int, const char *, int, const char *, unsigned);
int renameat2(int a, const char *b, int c, const char *d, unsigned f) {
  if (!r_renameat2) r_renameat2 = dlsym(RTLD_NEXT, "renameat2");
  if (listed(d) || listed(b)) { errno = EPERM; return -1; }
  return r_renameat2(a, b, c, d, f);
}
static int (*r_unlink)(const char *);
int unlink(const char *p) {
  if (!r_unlink) r_unlink = dlsym(RTLD_NEXT, "unlink");
  if (listed(p)) { errno = EPERM; return -1; }
  return r_unlink(p);
}
static int (*r_unlinkat)(int, const char *, int);
int unlinkat(int a, const char *p, int f) {
  if (!r_unlinkat) r_unlinkat = dlsym(RTLD_NEXT, "unlinkat");
  if (listed(p)) { errno = EPERM; return -1; }
  return r_unlinkat(a, p, f);
}
static int (*r_open)(const char *, int, ...);
int open(const char *p, int flags, ...) {
  if (!r_open) r_open = dlsym(RTLD_NEXT, "open");
  mode_t m = 0;
  if (flags & O_CREAT) { va_list ap; va_start(ap, flags); m = va_arg(ap, mode_t); va_end(ap); }
  if ((flags & (O_WRONLY | O_RDWR | O_CREAT | O_TRUNC)) && listed(p)) { errno = EPERM; return -1; }
  return r_open(p, flags, m);
}
static int (*r_open64)(const char *, int, ...);
int open64(const char *p, int flags, ...) {
  if (!r_open64) r_open64 = dlsym(RTLD_NEXT, "open64");
  mode_t m = 0;
  if (flags & O_CREAT) { va_list ap; va_start(ap, flags); m = va_arg(ap, mode_t); va_end(ap); }
  if ((flags & (O_WRONLY | O_RDWR | O_CREAT | O_TRUNC)) && listed(p)) { errno = EPERM; return -1; }
  return r_open64(p, flags, m);
}
static int (*r_creat)(const char *, mode_t);
int creat(const char *p, mode_t m) {
  if (!r_creat) r_creat = dlsym(RTLD_NEXT, "creat");
  if (listed(p)) { errno = EPERM; return -1; }
  return r_creat(p, m);
}
SHIM
  gcc -O2 -fPIC -shared -o "$SANDBOX/libimmut_shim.so" "$SANDBOX/immut_shim.c" -ldl \
    || { printf 'NOT_IMPLEMENTED: компиляция шима не удалась\n' >&2; exit 2; }
  export IMMUT_SHIM_LIST="$IMMUTABLE_LIST"

  cat > "$SANDBOX/bin/chattr" <<'M1'
#!/usr/bin/env bash
# мок chattr (IMMU_MOCK=1): журнал вызовов + состояние списка immutable
printf '%s\n' "$*" >> "$MOCK_STATE_DIR/chattr.log"
op="$1"; shift
case "$op" in
  +i) for f in "$@"; do grep -Fxq "$f" "$IMMUTABLE_LIST" || printf '%s\n' "$f" >> "$IMMUTABLE_LIST"; done ;;
  -i) for f in "$@"; do
        t="$IMMUTABLE_LIST.tmp"; grep -Fxv "$f" "$IMMUTABLE_LIST" > "$t" || : > "$t"; mv "$t" "$IMMUTABLE_LIST"
      done ;;
esac
exit 0
M1
  cat > "$SANDBOX/bin/lsattr" <<'M2'
#!/usr/bin/env bash
# мок lsattr (IMMU_MOCK=1): один файл без флагов, флаг i из списка immutable
while [ $# -gt 0 ]; do case "$1" in -*) shift ;; *) break ;; esac; done
for f in "$@"; do
  if grep -Fxq "$f" "$IMMUTABLE_LIST"; then
    printf -- '----i---------e------- %s\n' "$f"
  else
    printf -- '--------------e------- %s\n' "$f"
  fi
done
M2
  cat > "$SANDBOX/bin/id" <<'M3'
#!/usr/bin/env bash
# мок id (IMMU_MOCK=1): euid-гард установщика проходит в сандбоксе без root
[ "${1:-}" = "-u" ] && { printf '0\n'; exit 0; }
exec /usr/bin/id "$@"
M3
  cat > "$SANDBOX/bin/chown" <<'M4'
#!/usr/bin/env bash
# мок chown (IMMU_MOCK=1): копирование root:root в сандбоксе без root
printf '%s\n' "$*" >> "$MOCK_STATE_DIR/chown.log"
exit 0
M4
  chmod +x "$SANDBOX/bin/chattr" "$SANDBOX/bin/lsattr" "$SANDBOX/bin/id" "$SANDBOX/bin/chown"
  MTAG=" [MOCK]"
else
  MTAG=""
  pf="$SANDBOX/state/probe"; : > "$pf"
  if ! chattr +i "$pf"; then
    printf 'NOT_IMPLEMENTED: chattr +i недоступен (нет root/CAP_LINUX_IMMUTABLE); судите под root либо IMMU_MOCK=1\n' >&2
    exit 2
  fi
  chattr -i "$pf"; rm -f "$pf"
fi

lock(){   if [ "$MOCK" = 1 ]; then "$SANDBOX/bin/chattr" +i "$1" >/dev/null; export LD_PRELOAD="$SANDBOX/libimmut_shim.so"; else chattr +i "$1"; fi; }
unlock(){ if [ "$MOCK" = 1 ]; then "$SANDBOX/bin/chattr" -i "$1" >/dev/null; [ -s "$IMMUTABLE_LIST" ] || unset LD_PRELOAD; else chattr -i "$1"; fi; }
run_det(){ if [ "$MOCK" = 1 ]; then IMMUT_LSATTR_BIN="$SANDBOX/bin/lsattr" "$DET" "$1"; else "$DET" "$1"; fi; }
lattr(){ if [ "$MOCK" = 1 ]; then "$SANDBOX/bin/lsattr" "$1"; else lsattr "$1"; fi; }

cleanup(){ for c in "$SANDBOX/main" "$SANDBOX/d3" "$SANDBOX/d4" "$SANDBOX/d4b" \
  "$SANDBOX/d7" "$SANDBOX/i2"; do unlock "$c/.git/config" 2>/dev/null; done
  rm -rf "$SANDBOX"; }
trap cleanup EXIT

# ── заготовки репо ──────────────────────────────────────────────────────────
MAIN="$SANDBOX/main"; WT="$SANDBOX/wt"
git init -q --bare "$SANDBOX/o.git"
git init -q -b main "$MAIN"
git -C "$MAIN" remote add origin "$SANDBOX/o.git"
git -C "$MAIN" -c user.name=t -c user.email=t@t commit -q --allow-empty -m base
git -C "$MAIN" push -q origin HEAD:main
git -C "$MAIN" fetch -q origin
git -C "$MAIN" config branch.autoSetupMerge false
git -C "$MAIN" branch wip/g
ORIG_URL="$(val remote.origin.url)"

git init -q -b main "$SANDBOX/d3"; git -C "$SANDBOX/d3" config extensions.worktreeConfig true
git init -q -b main "$SANDBOX/d4"; : > "$SANDBOX/d4/.git/config.worktree"
# d4b (критик Б3): linked worktree, форензика ТОЛЬКО в .git/worktrees/<n>/ —
# основной .git/config.worktree отсутствует; extension off
git init -q -b main "$SANDBOX/d4b"
git -C "$SANDBOX/d4b" -c user.name=t -c user.email=t@t commit -q --allow-empty -m base
git -C "$SANDBOX/d4b" worktree add -q "$SANDBOX/d4bwt" -b wip/d4b
: > "$SANDBOX/d4b/.git/worktrees/d4bwt/config.worktree"
# d6 (критик Б2): объединённый вход порядка (а)+(б) — атрибут НЕ ставится
git init -q -b main "$SANDBOX/d6"; git -C "$SANDBOX/d6" config extensions.worktreeConfig true
# d7 (критик Б2): объединённый вход порядка (б)+(б2) — атрибут ставится
git init -q -b main "$SANDBOX/d7"; git -C "$SANDBOX/d7" config extensions.worktreeConfig true
: > "$SANDBOX/d7/.git/config.worktree"
git init -q -b main "$SANDBOX/i1"
git init -q -b main "$SANDBOX/i1b"; git -C "$SANDBOX/i1b" config core.hooksPath .githooks
git init -q -b main "$SANDBOX/i2";  git -C "$SANDBOX/i2" config core.hooksPath .githooks
git -C "$SANDBOX/i2" config branch.autoSetupMerge false

# ── запирание ───────────────────────────────────────────────────────────────
lock "$MAIN/.git/config"
# ноги (б)/(б2) наблюдаемы при СТОЯЩЕМ атрибуте (И-4: порядок (а)→(б)→(б2);
# критик Б2: незапертые d3/d4 делали честный порядок КРАСНЫМ на D3/D4) —
# запираем репо ног (б)/(б2) ДО детектора; записи в их config сделаны ДО замка
lock "$SANDBOX/d3/.git/config"
lock "$SANDBOX/d4/.git/config"
lock "$SANDBOX/d4b/.git/config"
lock "$SANDBOX/d7/.git/config"

# ── R1: основной чекаут ─────────────────────────────────────────────────────
run bash -c 'cd "$1" && git config user.name evil-main' _ "$MAIN"
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -Eq "$PAT" && [ -z "$(val user.name)" ]; then
  ok R1 "основной чекаут: git config user.name — отказ ядра, значение не записано"
else
  no R1 "основной чекаут: git config user.name должен отказывать ядром (rc=$rc)"
fi

# ── R5: remote подмена ──────────────────────────────────────────────────────
run git -C "$MAIN" remote set-url origin ssh://git@8.8.8.8:22/x
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -Eq "$PAT" && [ "$(val remote.origin.url)" = "$ORIG_URL" ]; then
  ok R5 "remote set-url — отказ ядра, url не изменён"
else
  no R5 "remote set-url должен отказывать ядром (rc=$rc)"
fi

# ── R6: upstream перепривязка ───────────────────────────────────────────────
# Замер живьём 2026-10-04: при отказе ядра git branch --set-upstream-to печатает
# error дважды, но выходит rc 0 («branch set up to track», upstream НЕ записан) —
# клетка судит ЗНАЧЕНИЕ + отказ ядра в stderr, не rc.
run git -C "$MAIN" branch --set-upstream-to=origin/main main
if printf '%s' "$out" | grep -Eq "$PAT" && [ -z "$(val branch.main.remote)" ]; then
  ok R6 "branch --set-upstream-to — отказ ядра в stderr, upstream не записан (rc допустим 0)"
else
  no R6 "branch --set-upstream-to не должен записывать upstream (rc=$rc)"
fi

# ── R7: канал --worktree под замком ─────────────────────────────────────────
# Замер живьём 2026-10-04: в репо БЕЗ linked worktrees git config --worktree
# БЕЗ extension ТИХО пишет в ОБЩИЙ config (rc 0, [user] name осел в config);
# в репо С linked worktrees git сам отказывает rc 128. Оба исхода обязаны
# попадать под защиту: под замком ядро отказывает этой форме как и остальным.
run git -C "$MAIN" config --worktree user.name probe-wt
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -Eq "$PAT" && [ -z "$(val user.name)" ]; then
  ok R7 "git config --worktree (в одиноком репо тихо пишет общий config) — под замком отказ ядра"
else
  no R7 "форма --worktree должна отказывать ядром под замком (rc=$rc)"
fi

# ── G-серия: обычная работа проходит ────────────────────────────────────────
run git -C "$MAIN" -c user.name=t -c user.email=t@t commit -q --allow-empty -m c2
[ "$rc" -eq 0 ] && ok G1 "commit с -c identity — rc 0" || no G1 "commit с -c identity (rc=$rc)"

run git -C "$MAIN" push -q origin HEAD:main
[ "$rc" -eq 0 ] && ok G2 "push — rc 0" || no G2 "push (rc=$rc)"

run git -C "$MAIN" fetch -q origin
[ "$rc" -eq 0 ] && ok G3 "fetch — rc 0" || no G3 "fetch (rc=$rc)"

run git -C "$MAIN" branch wip/h
[ "$rc" -eq 0 ] && ok G4 "branch — rc 0 (autoSetupMerge=false поставлен ДО блокировки)" || no G4 "branch (rc=$rc)"

run git -C "$MAIN" worktree add -q "$WT" wip/g
[ "$rc" -eq 0 ] && ok G5 "worktree add — rc 0" || no G5 "worktree add (rc=$rc)"

run git -C "$WT" -c user.name=t -c user.email=t@t commit -q --allow-empty -m wt
[ "$rc" -eq 0 ] && ok G6 "commit в worktree — rc 0" || no G6 "commit в worktree (rc=$rc)"

# ── R2: запись ЧЕРЕЗ worktree ───────────────────────────────────────────────
run git -C "$WT" config user.name evil-wt
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -Eq "$PAT" && [ -z "$(val user.name)" ]; then
  ok R2 "через worktree: git -C <wt> config — отказ ядра (общий config), значение не записано"
else
  no R2 "через worktree запись должна отказывать ядром (rc=$rc)"
fi

# ── R3: GIT_DIR env ─────────────────────────────────────────────────────────
run env GIT_DIR="$MAIN/.git" git config user.name evil-gd
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -Eq "$PAT" && [ -z "$(val user.name)" ]; then
  ok R3 "GIT_DIR=MAIN/.git: git config — отказ ядра, значение не записано"
else
  no R3 "GIT_DIR-форма должна отказывать ядром (rc=$rc)"
fi

# ── R4: из скрипта ──────────────────────────────────────────────────────────
printf '#!/usr/bin/env bash\ncd "%s" && git config user.name evil-script\n' "$MAIN" > "$SANDBOX/inner.sh"
run bash "$SANDBOX/inner.sh"
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -Eq "$PAT" && [ -z "$(val user.name)" ]; then
  ok R4 "из скрипта: bash-файл с git config внутри — отказ ядра, значение не записано"
else
  no R4 "скриптовая форма должна отказывать ядром (rc=$rc)"
fi

# ── G-серия (продолжение) ───────────────────────────────────────────────────
run git -C "$MAIN" worktree remove "$WT"
[ "$rc" -eq 0 ] && ok G7 "worktree remove — rc 0" || no G7 "worktree remove (rc=$rc)"

run git -C "$MAIN" branch -D wip/g
[ "$rc" -eq 0 ] && ok G8 "branch -D — rc 0" || no G8 "branch -D (rc=$rc)"

run git -C "$MAIN" gc -q
[ "$rc" -eq 0 ] && ok G9 "gc — rc 0" || no G9 "gc (rc=$rc)"

run git -C "$MAIN" config --get remote.origin.url
[ "$rc" -eq 0 ] && ok G10 "config --get (чтение) — rc 0" || no G10 "config --get (rc=$rc)"

# ── D-серия: детектор scripts/check_git_config_immut.sh ─────────────────────
if [ -x "$DET" ]; then
  run_det "$MAIN" > "$SANDBOX/d1.out" 2>&1; drc=$?
  [ "$drc" -eq 0 ] && ok D1 "детектор зелёный на запертом чистом репо" \
    || no D1 "детектор должен быть зелён на запертом чистом репо (rc=$drc)"

  unlock "$MAIN/.git/config"
  run_det "$MAIN" > "$SANDBOX/d2.out" 2>&1; drc=$?
  if [ "$drc" -eq 1 ] && grep -Fq '+i отсутствует' "$SANDBOX/d2.out"; then
    ok D2 "снятие атрибута → детектор rc 1, причина «+i отсутствует»"
  else
    no D2 "снятие атрибута должно краснить детектор (rc=$drc)"
  fi

  run_det "$SANDBOX/d3" > "$SANDBOX/d3.out" 2>&1; drc=$?
  if [ "$drc" -eq 1 ] && grep -Fq 'extensions.worktreeConfig' "$SANDBOX/d3.out"; then
    ok D3 "extensions.worktreeConfig=true → детектор rc 1, причина названа"
  else
    no D3 "extension-обход должен краснить детектор (rc=$drc)"
  fi

  run_det "$SANDBOX/d4" > "$SANDBOX/d4.out" 2>&1; drc=$?
  if [ "$drc" -eq 1 ] && grep -Fq 'config.worktree существует' "$SANDBOX/d4.out"; then
    ok D4 "подсунутый config.worktree → детектор rc 1, причина названа"
  else
    no D4 "config.worktree-остаток должен краснить детектор (rc=$drc)"
  fi

  # критик Б3: форензика ОБЕИХ локаций (б2) — linked-worktree-файл при
  # ОТСУТСТВУЮЩЕМ основном .git/config.worktree; детектор, не обходящий
  # .git/worktrees/*/, проходит D4 и красен ЗДЕСЬ
  run_det "$SANDBOX/d4b" > "$SANDBOX/d4b.out" 2>&1; drc=$?
  if [ "$drc" -eq 1 ] && grep -Fq 'config.worktree существует' "$SANDBOX/d4b.out"; then
    ok D4b "linked-worktree config.worktree (основной отсутствует) → rc 1, причина названа"
  else
    no D4b "форензика .git/worktrees/*/config.worktree должна краснить детектор (rc=$drc)"
  fi

  run_det main > "$SANDBOX/d5.out" 2>&1; drc=$?
  if [ "$drc" -eq 1 ] && grep -Fq 'корень обязан быть абсолютным' "$SANDBOX/d5.out"; then
    ok D5 "не-абсолютный корень → детектор rc 1, причина названа"
  else
    no D5 "не-абсолютный корень должен отказывать (rc=$drc)"
  fi

  # критик Б2, разлучитель порядка (а)→(б): объединённый вход — атрибут СНЯТ ∧
  # extension=true; первая причина по И-4 обязана быть «+i отсутствует», причина
  # ноги (б) НЕ печатается. Детектор, проверяющий extension ПРЕЖДЕ атрибута,
  # зелён на D1-D5 и красен ЗДЕСЬ
  run_det "$SANDBOX/d6" > "$SANDBOX/d6.out" 2>&1; drc=$?
  if [ "$drc" -eq 1 ] && grep -Fq '+i отсутствует' "$SANDBOX/d6.out" \
    && ! grep -Fq 'extensions.worktreeConfig' "$SANDBOX/d6.out"; then
    ok D6 "порядок (а)→(б): снятый атрибут ∧ extension → причина ТОЛЬКО «+i отсутствует»"
  else
    no D6 "первая причина на снятом атрибуте — «+i отсутствует», не extension (rc=$drc)"
  fi

  # критик Б2, разлучитель порядка (б)→(б2): объединённый вход — атрибут стоит ∧
  # extension=true ∧ основной config.worktree существует; причина ТОЛЬКО ноги (б)
  run_det "$SANDBOX/d7" > "$SANDBOX/d7.out" 2>&1; drc=$?
  if [ "$drc" -eq 1 ] && grep -Fq 'extensions.worktreeConfig' "$SANDBOX/d7.out" \
    && ! grep -Fq 'config.worktree существует' "$SANDBOX/d7.out"; then
    ok D7 "порядок (б)→(б2): extension ∧ config.worktree → причина ТОЛЬКО «extensions.worktreeConfig»"
  else
    no D7 "при включённом extension причина — «extensions.worktreeConfig», не форензика (rc=$drc)"
  fi
else
  no D1 "субъект scripts/check_git_config_immut.sh отсутствует (red-first: реализует implementer 081)"
  no D2 "субъект отсутствует"
  no D3 "субъект отсутствует"
  no D4 "субъект отсутствует"
  no D4b "субъект отсутствует"
  no D5 "субъект отсутствует"
  no D6 "субъект отсутствует"
  no D7 "субъект отсутствует"
fi

# ── I-серия: ops/server/install.sh root (шаг блокировки, И-2/И-3 контракта) ──
# критик Б7/арбитраж 081: rc субъекта установщика возвращается вызывающему
# (irc=$? в I2) — присваивание rc=$? само по себе статус 0 (класс А-345)
irun(){ out="$(PATH="$SANDBOX/bin:$PATH" OPS_SERVER_SRC="$REPO/ops/server" \
  OPS_SERVER_SBIN_DST="$SANDBOX/sbin" OPS_SERVER_ETC_DST="$SANDBOX/etc" \
  OPS_SERVER_MAIN="$1" bash "$INSTALL" root 2>&1)"; rc=$?; return "$rc"; }

# критик Б8/арбитраж 081: I1/I1b требуют ПУСТОЙ журнал — chattr не вызван ВОВСЕ
# (контракт :374-377), а не только «нет строки +i <config>»: любая иная строка
# журнала (например -i <config> на отказном пути) = обход
: > "$CHATTR_LOG"
irun "$SANDBOX/i1"
if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq 'core.hooksPath' \
  && [ ! -s "$CHATTR_LOG" ]; then
  ok I1 "hooksPath не установлен → rc 1 ДО chattr (chattr не вызван)"
else
  no I1 "отсутствие hooksPath должно отказывать ДО блокировки (rc=$rc)"
fi

: > "$CHATTR_LOG"
irun "$SANDBOX/i1b"
if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq 'autoSetupMerge' \
  && [ ! -s "$CHATTR_LOG" ]; then
  ok I1b "autoSetupMerge не false → rc 1 ДО chattr (chattr не вызван)"
else
  no I1b "autoSetupMerge≠false должен отказывать ДО блокировки (rc=$rc)"
fi

: > "$CHATTR_LOG"
irun "$SANDBOX/i2"; irc=$?
# ПОСТУСЛОВИЕ И-1 (критик Б1): успех установщика = атрибут СТОИТ ПОСЛЕ его
# выхода, а не факт вызова chattr в середине. Обход «+i, сразу за ним -i»
# ловится тройно: мок-журнал (только IMMU_MOCK=1 — real-режим журнала не
# имеет, совет критика), lsattr после выхода, реальная запись в этот config.
lattr "$SANDBOX/i2/.git/config" > "$SANDBOX/i2.attr" 2>&1
[ "$MOCK" = 1 ] && export LD_PRELOAD="$SANDBOX/libimmut_shim.so"
run git -C "$SANDBOX/i2" config user.name proof-post
wrc=$rc; wout="$out"; wpat=0; printf '%s' "$wout" | grep -Eq "$PAT" && wpat=1
ival="$(git -C "$SANDBOX/i2" config --local --get user.name || true)"
attr_i=0; awk '{print $1}' "$SANDBOX/i2.attr" | grep -q i && attr_i=1
i2ok=1
[ "$irc" -eq 0 ] || i2ok=0
if [ "$MOCK" = 1 ]; then
  grep -Fxq "+i $SANDBOX/i2/.git/config" "$CHATTR_LOG" || i2ok=0
  grep -Fxq -- "-i $SANDBOX/i2/.git/config" "$CHATTR_LOG" && i2ok=0
  [ "$(grep -c '^+i ' "$CHATTR_LOG")" -eq 1 ] || i2ok=0
fi
[ "$attr_i" -eq 1 ] || i2ok=0
{ [ "$wrc" -ne 0 ] && [ "$wpat" -eq 1 ] && [ -z "$ival" ]; } || i2ok=0
if [ "$i2ok" -eq 1 ]; then
  ok I2 "оба предусловия → rc 0 ∧ chattr ровно на config ∧ атрибут СТОИТ на выходе ∧ запись отказывает ядром"
else
  no I2 "блокировка обязана ОСТАТЬСЯ после установщика: rc=$irc lsattr-i=$attr_i write-rc=$wrc (критик Б1)"
fi

# ── W1: README — процедура обслуживания И-5 (конвенция чек-строк к6 074) ────
# критик Б6: зона на README лишь РАЗРЕШАЕТ изменение, результат предъявляется
# клеткой: без раздела красна (red-first — раздел ставит implementer 081),
# с ним зелёна. grep -F чек-строк, не машинный суд прозы.
RDM="$REPO/ops/server/README.md"; wmiss=""
grep -Fq 'Обслуживание .git/config' "$RDM" || wmiss="раздел-обслуживания "
grep -Fq 'chattr -i' "$RDM" || wmiss="${wmiss}chattr--i "
grep -Fq 'chattr +i' "$RDM" || wmiss="${wmiss}chattr-+i "
grep -Fq 'check_git_config_immut' "$RDM" || wmiss="${wmiss}check_git_config_immut "
if [ -z "$wmiss" ]; then
  ok W1 "ops/server/README.md несёт раздел обслуживания И-5 (чек-строки)"
else
  no W1 "README без процедуры обслуживания И-5, нет: $wmiss(критик Б6)"
fi

printf 'итог%s: зелёных=%d красных=%d\n' "$MTAG" "$pass" "$fail" >&2
[ "$fail" -eq 0 ] || { printf 'красные клетки:%s\n' "$red" >&2; exit 1; }
exit 0
