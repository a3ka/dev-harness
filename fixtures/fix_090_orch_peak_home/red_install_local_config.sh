#!/usr/bin/env bash
# Клетка Н-216: диагностический шаг install.sh root (предусловия блокировки
# .git/config — контракт 081, И-2) в среде root БЕЗ safe.directory.
#
# Техника симуляции (обоснование): чужое uid-владение каталогом в тест-мире
# недоступно без root, поэтому мокается ТОЛЬКО ownership-guard гита: git-mock
# отказывает форме `config --local` ДОСЛОВНОЙ сигнатурой живого отказа из
# Н-216 («fatal: --local can only be used inside a git repository», rc 1) и
# делегирует всё остальное (включая форму --file) НАСТОЯЩЕМУ /usr/bin/git.
# Моки id (euid 0 — пройти euid-гард install.sh непривилегированно) и chown
# (noop) меняют только привилегийную обвязку, не предмет. Значения
# предусловий читаются установщиком из РЕАЛЬНОГО конфиг-файла тест-репо.
#
# Кейсы (дано: MAIN-репо с конфигом; когда: install.sh root под мок-PATH):
#  A  hooksPath=.githooks, autoSetupMerge=false → ПОСЛЕ фикса предусловия
#     пройдены, отказ ТОЛЬКО на chattr +i (непривилегированный мир не может
#     ставить immutable-бит) — ложного «core.hooksPath не установлен» быть
#     НЕ должно. ДО фикса: ложный отказ «core.hooksPath не установлен» (Н-216).
#  B  hooksPath=/evil/other → отказ с ИМЕНОВАННЫМ значением «(/evil/other)» —
#     доказывает, что значение ПРОЧИТАНО из файла (ловит стаб-хардкод
#     hooks_path=".githooks", который кейс B молча пропускает).
#  C  ключа нет → честный fail-closed отказ «core.hooksPath не установлен»
#     (пин семантики И-2: фикс не ослабил запирание).
#  D  autoSetupMerge=true → отказ «branch.autoSetupMerge не false (true)» —
     # чтение второго предусловия тоже ушло с --local на --file.
# Субъект: ORCH090_SUBJECT (умолчание — корень репо этой фикстуры).
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib.sh"
SUBJ="${ORCH090_SUBJECT:-$(fix090_repo_root "$HERE")}"
W="$(fix090_scratch)"
[ -d "$W" ] || fix090_fail "нет scratch"
MOCK="$W/mocks"
mkdir -p "$MOCK"

cat > "$MOCK/git" <<'EOF'
#!/usr/bin/env bash
# git-mock 090 (Н-216): эмулирует ТОЛЬКО ownership-guard root'а без
# safe.directory для формы `config --local`; всё остальное — настоящий git.
for a in "$@"; do
  if [ "$a" = "--local" ]; then
    printf 'fatal: --local can only be used inside a git repository\n' >&2
    exit 1
  fi
done
exec /usr/bin/git "$@"
EOF
cat > "$MOCK/id" <<'EOF'
#!/bin/sh
# id-mock 090: euid-гард install.sh видит root (непривилегированный тест-мир)
[ "$1" = "-u" ] && { echo 0; exit 0; }
exec /usr/bin/id "$@"
EOF
cat > "$MOCK/chown" <<'EOF'
#!/bin/sh
# chown-mock 090: noop — непривилегированный мир не может chown root:root
exit 0
EOF
chmod 755 "$MOCK/git" "$MOCK/id" "$MOCK/chown"

# самопроверка мока: сигнатура отказа Н-216 воспроизводится дословно
MAIN0="$W/main0"
/usr/bin/git init -q "$MAIN0" || fix090_fail "git init тест-мира не удался"
if PATH="$MOCK:$PATH" git -C "$MAIN0" config --local --get core.hooksPath 2>"$W/mock-sig.txt"; then
  fix090_fail "самопроверка: мок --local не отказал"
fi
grep -Fq -- '--local can only be used inside a git repository' "$W/mock-sig.txt" \
  || fix090_fail "самопроверка: сигнатура мока ≠ сигнатуре Н-216: $(tr '\n' ' ' < "$W/mock-sig.txt")"
# а форма --file у мока живая (делегация настоящему гиту)
/usr/bin/git -C "$MAIN0" config core.hooksPath .githooks
PATH="$MOCK:$PATH" git -C "$MAIN0" config --file "$MAIN0/.git/config" --get core.hooksPath \
  | grep -Fxq '.githooks' || fix090_fail "самопроверка: --file через мок не прочитал значение"

run_install() { # $1=MAIN-репо; stderr → $W/i-stderr.txt, rc наружу
  local rc=0
  env PATH="$MOCK:$PATH" \
    OPS_SERVER_SRC="$SUBJ/ops/server" \
    OPS_SERVER_SBIN_DST="$W/sbin" OPS_SERVER_ETC_DST="$W/etc" \
    OPS_SERVER_MAIN="$1" \
    bash "$SUBJ/ops/server/install.sh" root 2>"$W/i-stderr.txt" || rc=$?
  return "$rc"
}

mkmain() { # $1=имя; свежий MAIN-репо с конфигом, задаётся снаружи
  local m="$W/$1"
  /usr/bin/git init -q "$m" || fix090_fail "git init $m не удался"
  printf '%s' "$m"
}

# check <метка> <rc> <errfile> [!]<литерал>… — rc обязан быть 1 (шаг
# блокировки в непривилегированном мире всегда доходит до именованного
# отказа), литералы обязаны/запрещены в stderr.
check() {
  local label="$1" rc="$2" err="$3" spec s bad=0
  shift 3
  if [ "$rc" -ne 1 ]; then
    printf '  ✗ %s: rc=%s, ожидался 1\n' "$label" "$rc" >&2; bad=1
  fi
  for spec in "$@"; do
    if [ "${spec#!}" != "$spec" ]; then
      s="${spec#!}"
      grep -Fq -- "$s" "$err" && { printf '  ✗ %s: в stderr не должно быть: %s\n' "$label" "$s" >&2; bad=1; }
    else
      grep -Fq -- "$spec" "$err" || { printf '  ✗ %s: в stderr ожидалось: %s\n' "$label" "$spec" >&2; bad=1; }
    fi
  done
  [ "$bad" -eq 0 ] && printf '  ✓ %s\n' "$label"
  return "$bad"
}

FAILS=0

MAIN_A="$(mkmain a)"
/usr/bin/git -C "$MAIN_A" config core.hooksPath .githooks
/usr/bin/git -C "$MAIN_A" config branch.autoSetupMerge false
rc=0; run_install "$MAIN_A" || rc=$?
check 'A: предусловия выполнены → отказ только на chattr' "$rc" "$W/i-stderr.txt" \
  'ОТКАЗ: chattr +i на' '!core.hooksPath не установлен' '!branch.autoSetupMerge' || FAILS=1

MAIN_B="$(mkmain b)"
/usr/bin/git -C "$MAIN_B" config core.hooksPath /evil/other
rc=0; run_install "$MAIN_B" || rc=$?
check 'B: hooksPath=/evil/other → отказ с именованным значением' "$rc" "$W/i-stderr.txt" \
  'core.hooksPath не установлен (/evil/other)' || FAILS=1

MAIN_C="$(mkmain c)"
rc=0; run_install "$MAIN_C" || rc=$?
check 'C: ключа нет → честный fail-closed' "$rc" "$W/i-stderr.txt" \
  'core.hooksPath не установлен' || FAILS=1

MAIN_D="$(mkmain d)"
/usr/bin/git -C "$MAIN_D" config core.hooksPath .githooks
/usr/bin/git -C "$MAIN_D" config branch.autoSetupMerge true
rc=0; run_install "$MAIN_D" || rc=$?
check 'D: autoSetupMerge=true → отказ с прочитанным значением' "$rc" "$W/i-stderr.txt" \
  'branch.autoSetupMerge не false (true)' || FAILS=1

[ "$FAILS" -eq 0 ] || fix090_fail "install-клетка: см. ✗ выше (ложный отказ Н-216 либо сломанное чтение предусловий)"
printf 'ЗЕЛЁНО(090-install): предусловия 081 читаются из файла (не через --local), ложный отказ Н-216 ушёл, fail-closed жив\n'
exit 0
