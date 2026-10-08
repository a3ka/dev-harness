#!/usr/bin/env bash
# Батарея обманных стабов 090 (Н-39: стаб строится ИЗ ТЕКУЩЕГО субъекта, а не
# хранится мёртвой копией): каждая порча — точечная правка копии субъекта с
# проверкой якоря (якорь пропал — именованный отказ, клетка не молчит),
# после чего СООТВЕТСТВУЮЩАЯ клетка ОБЯЗАНА отказать (rc≠0). Стаб, прошедший
# клетку, — дефект клетки. Работает и ДО фикса (HEAD), и ПОСЛЕ: порчи
# адаптируются к наличию посева ORCH_SESS_GLOB.
#
# Стабы и где их дефект НАБЛЮДАЕМ (Н-39):
#  1 «decoy-глоб» — после фикса: посев ORCH_SESS_GLOB подменён на
#    /nonexistent-090-stub (выглядит как фикс, глоб неверен); до фикса:
#    export HOME=/nonexistent-090-stub перед source. Наблюдаем: в глубокой
#    клетке — нет «живые субагенты погибнут» (глоб пуст, субагент «не найден»).
#    Лёгкую клетку проходит честно — потому глубокая обязательна.
#  2 «subshell-глушение» — source в subshell с 2>/dev/null || true: краш
#    глушится, работают локальные fallback'и orch-peak. Наблюдаем: в глубокой
#    клетке нет LIBSRC-префикса — единый источник И-13 потерян молча.
#  3 «hardcode-hooksPath» — чтение hooks_path заменено константой ".githooks".
#    Наблюдаем: install-клетка, кейс B (в конфиге /evil/other) — стаб молча
#    пропускает невыполненное предусловие, отказа с именованным значением нет.
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib.sh"
SUBJ="${ORCH090_SUBJECT:-$(fix090_repo_root "$HERE")}"
[ -f "$SUBJ/ops/server/root/orch-peak" ] || fix090_fail "нет субъекта orch-peak"
[ -f "$SUBJ/scripts/lib_session.sh" ] || fix090_fail "нет субъекта lib_session.sh"
[ -f "$SUBJ/ops/server/install.sh" ] || fix090_fail "нет субъекта install.sh"

W="$(fix090_scratch)"
trap '[ "${ORCH090_KEEP:-}" = 1 ] || rm -rf "$W"' EXIT

build_subject_copy() { # $1=dst — ор-скрипты + библиотека, как их видят клетки
  mkdir -p "$1/ops" "$1/scripts"
  cp -r "$SUBJ/ops/server" "$1/ops/server" || fix090_fail "не скопирован ops/server"
  cp "$SUBJ/scripts/lib_session.sh" "$1/scripts/lib_session.sh" || fix090_fail "не скопирован lib_session.sh"
}

Caught() { # $1=имя стаба, $2=rc клетки
  if [ "$2" -eq 0 ]; then
    printf '✗ %s: ПРОШЁЛ клетку — дефект клетки, почини клетку\n' "$1" >&2
    return 1
  fi
  printf '✓ %s пойман (rc=%s)\n' "$1" "$2"
  return 0
}

FAILS=0

# ── стаб 1: decoy-глоб ──────────────────────────────────────────────────────
S1="$W/stub1"; build_subject_copy "$S1"
OP1="$S1/ops/server/root/orch-peak"
python3 - "$OP1" <<'PY' || fix090_fail "стаб1: порча не применилась (якоря дрейфнули)"
import sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
seed_old = 'ORCH_SESS_GLOB="$SESS_GLOB"'
seed_new = 'ORCH_SESS_GLOB="/nonexistent-090-stub"'
src_old = '  . "${REPO}/scripts/lib_session.sh"'
src_ins = 'export HOME=/nonexistent-090-stub\n' + src_old
if s.count(seed_old) == 1:            # фикс уже стоит: портим САМ посев
    s = s.replace(seed_old, seed_new)
elif s.count(src_old) == 1:            # фикса нет: классический decoy-HOME
    s = s.replace(src_old, src_ins)
else:
    print('STUB1-REFUSE: нет ни посева ORCH_SESS_GLOB, ни якоря source', file=sys.stderr)
    sys.exit(1)
open(p, 'w', encoding='utf-8').write(s)
PY
rc=0; ORCH090_SUBJECT="$S1" bash "$HERE/red_ctx_deep_no_home.sh" >/dev/null 2>&1 || rc=$?
Caught 'стаб1 decoy-глоб' "$rc" || FAILS=1

# ── стаб 2: subshell-глушение ──────────────────────────────────────────────
S2="$W/stub2"; build_subject_copy "$S2"
OP2="$S2/ops/server/root/orch-peak"
python3 - "$OP2" <<'PY' || fix090_fail "стаб2: порча не применилась (якорь source дрейфнул)"
import sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
old = '  . "${REPO}/scripts/lib_session.sh"'
new = '  ( . "${REPO}/scripts/lib_session.sh" ) 2>/dev/null || true'
n = s.count(old)
if n != 1:
    print('STUB2-REFUSE: якорь source встречен %d раз, ожидался 1' % n, file=sys.stderr)
    sys.exit(1)
open(p, 'w', encoding='utf-8').write(s.replace(old, new))
PY
rc=0; ORCH090_SUBJECT="$S2" bash "$HERE/red_ctx_deep_no_home.sh" >/dev/null 2>&1 || rc=$?
Caught 'стаб2 subshell-глушение' "$rc" || FAILS=1

# ── стаб 3: hardcode-hooksPath ─────────────────────────────────────────────
S3="$W/stub3"; build_subject_copy "$S3"
INS3="$S3/ops/server/install.sh"
python3 - "$INS3" <<'PY' || fix090_fail "стаб3: порча не применилась (якорь hooks_path дрейфнул)"
import sys, re
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
s2, n = re.subn(r'^[ \t]*hooks_path=.*$', '      hooks_path=".githooks"', s, flags=re.M)
if n != 1:
    print('STUB3-REFUSE: строк hooks_path=%d, ожидалась 1' % n, file=sys.stderr)
    sys.exit(1)
open(p, 'w', encoding='utf-8').write(s2)
PY
rc=0; ORCH090_SUBJECT="$S3" bash "$HERE/red_install_local_config.sh" >/dev/null 2>&1 || rc=$?
Caught 'стаб3 hardcode-hooksPath' "$rc" || FAILS=1

[ "$FAILS" -eq 0 ] || fix090_fail "батарея стабов: см. ✗ выше"
printf 'ЗЕЛЁНО(090-батарея): 3/3 обманных стабов пойманы своими клетками\n'
exit 0
