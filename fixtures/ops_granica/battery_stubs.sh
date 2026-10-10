#!/usr/bin/env bash
# Батарея обманных стабов 093 (Н-39): каждая порча — точечная правка копии
# субъекта, С ПРОВЕРКОЙ ЯКОРЯ (якорь не найден → стаб не построен, клетка не
# засчитывается). Соответствующая клетка обязана отказать rc≠0 на стабе. Стаб,
# прошедший клетку, — дефект клетки. Якоря посимвольно сверены с субъектом
# d54e5bc7 (живой замер: прежние якоря s1/s6 не совпадали с текстом субъекта).
set -o pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${OPS093_ROOT:-$(cd "$HERE/../.." && pwd)}"
[ -f "$ROOT/ops/server/install.sh" ] || { printf 'NOT_IMPLEMENTED: нет install.sh\n' >&2; exit 2; }
[ -f "$ROOT/ops/server/root/orch-peak" ] || { printf 'NOT_IMPLEMENTED: нет orch-peak\n' >&2; exit 2; }
[ -f "$ROOT/ops/server/user/orch-loop" ] || { printf 'NOT_IMPLEMENTED: нет orch-loop\n' >&2; exit 2; }

SCRATCH="$(mktemp -d /tmp/dev-harness-verify/ops-granica-bat-XXXXXX)" || { printf 'NOT_IMPLEMENTED: mktemp\n' >&2; exit 2; }
trap 'rm -rf "$SCRATCH"' EXIT

build_copy() { # $1=dst $2=src
  mkdir -p "$1/ops/server/root" "$1/ops/server/user" "$1/scripts" "$1/fixtures/ops_granica"
  /bin/cp -r "$ROOT/." "$1/" 2>/dev/null || true
  # Перезаписать нужные файлы
  /bin/cp "$2/ops/server/install.sh" "$1/ops/server/install.sh"
  /bin/cp "$2/ops/server/root/orch-peak" "$1/ops/server/root/orch-peak"
  /bin/cp "$2/ops/server/user/orch-loop" "$1/ops/server/user/orch-loop"
}

caught=0
total=0

# Stub s1: фолбэк-без-потолка — возвращает удалённую ветку orch-loop (запуск
# сессии при несозданном scope). Якорь — ДОСЛОВНЫЙ блок отказа И-5 субъекта
# (включая комментарии; прежний якорь пропускал строку комментария).
S1="$SCRATCH/s1"; build_copy "$S1" "$ROOT"
total=$((total+1))
/usr/bin/python3 -c "
p = '$S1/ops/server/user/orch-loop'
with open(p) as f: c = f.read()
old = 'if [ ! -e \"\$RAN\" ]; then\\n  # И-5: scope не создан — автономный пускач возвращает rc 1, именованный отказ,\\n  # сессия НЕ стартует. Цикл останавливается, НЕ перезапускает сессию без потолка.\\n  log \"сессия #\$n: ресурсный предел не создан — запуск без потолка запрещён (И-5, контракт 093)\"\\n  kill \"\$watcher\" 2>/dev/null; wait \"\$watcher\" 2>/dev/null\\n  exit 1\\nfi'
new_block = 'if [ ! -e \"\$RAN\" ]; then\\n  log \"БЕЗ ПОТОЛКА\"\\n  \"\$WORKSHOP\" --yolo -- \"\$MSG\"; rc=\$?\\n  kill \"\$watcher\" 2>/dev/null; wait \"\$watcher\" 2>/dev/null\\n  exit \"\$rc\"\\nfi'
if old in c:
    c = c.replace(old, new_block, 1)
    with open(p, 'w') as f: f.write(c)
    print('s1 ok')
else:
    print('s1 anchor missing')
" 2>&1
OPS093_ROOT="$S1" /bin/bash "$HERE/red_limit_otkaz_bez_zapuska.sh" >/dev/null 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then caught=$((caught+1)); printf 's1 фолбэк-без-потолка: ПОЙМАН (rc=%s)\n' "$rc" >&2
else printf '✗ s1 фолбэк-без-потолка: НЕ ПОЙМАН (rc=0)\n' >&2; fi

# Stub s2: bootstrap-из-репо — возвращает root-bootstrap на ${REPO}.
S2="$SCRATCH/s2"; build_copy "$S2" "$ROOT"
total=$((total+1))
/usr/bin/python3 -c "
p = '$S2/ops/server/root/orch-peak'
with open(p) as f: c = f.read()
old = '\${OPS_SERVER_LIB_DST-/usr/local/sbin/lib_session.sh}'
new = '\${REPO}/scripts/lib_session.sh'
if old in c:
    c = c.replace(old, new)
    c = c.replace('if [ ! -f \"\$LIB_DST\" ]; then', 'if [ -f \"\${REPO}/scripts/lib_session.sh\" ]; then\n  LIB_DST=\"\${REPO}/scripts/lib_session.sh\"\nelif [ ! -f \"\$LIB_DST\" ]; then')
    with open(p, 'w') as f: f.write(c)
    print('s2 ok')
else:
    print('s2 anchor missing')
" 2>&1
OPS093_ROOT="$S2" /bin/bash "$HERE/red_root_bootstrap_iz_repo.sh" >/dev/null 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then caught=$((caught+1)); printf 's2 bootstrap-из-репо: ПОЙМАН (rc=%s)\n' "$rc" >&2
else printf '✗ s2 bootstrap-из-репо: НЕ ПОЙМАН (rc=0)\n' >&2; fi

# Stub s3: кредит-в-среде — экспортирует publication-креденшл.
S3="$SCRATCH/s3"; build_copy "$S3" "$ROOT"
total=$((total+1))
/usr/bin/python3 -c "
p = '$S3/ops/server/user/orch-loop'
with open(p) as f: c = f.read()
old = 'AGENT_HOME=\"\${ORCH_AGENT_HOME:-\${ORCH_LOOP_AGENT_HOME:-/var/lib/orch-agent}}\"'
new = old + '\\nexport GIT_SSH_COMMAND=\"ssh -i /tmp/fake-rw\"\\nexport GITHUB_TOKEN=\"fake-token\"'
if old in c:
    c = c.replace(old, new, 1)
    with open(p, 'w') as f: f.write(c)
    print('s3 ok')
else:
    print('s3 anchor missing')
" 2>&1
OPS093_ROOT="$S3" /bin/bash "$HERE/red_kredit_publikacii_vne_sredy.sh" >/dev/null 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then caught=$((caught+1)); printf 's3 кредит-в-среде: ПОЙМАН (rc=%s)\n' "$rc" >&2
else printf '✗ s3 кредит-в-среде: НЕ ПОЙМАН (rc=0)\n' >&2; fi

# Stub s4: успех-без-старта — install verify-start не проверяет.
S4="$SCRATCH/s4"; build_copy "$S4" "$ROOT"
total=$((total+1))
/usr/bin/python3 -c "
p = '$S4/ops/server/install.sh'
with open(p) as f: c = f.read()
old = '    state=\"\$(\"\$SYSTEMCTL\" is-active \"\$UNIT\" 2>&1)\" || true'
if old in c:
    c = c.replace(old, '    state=active')
    with open(p, 'w') as f: f.write(c)
    print('s4 ok')
else:
    print('s4 anchor missing')
" 2>&1
OPS093_ROOT="$S4" /bin/bash "$HERE/red_unit_realno_startuet.sh" >/dev/null 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then caught=$((caught+1)); printf 's4 успех-без-старта: ПОЙМАН (rc=%s)\n' "$rc" >&2
else printf '✗ s4 успех-без-старта: НЕ ПОЙМАН (rc=0)\n' >&2; fi

# Stub s5: откат-удаление — rollback удаляет новую версию.
S5="$SCRATCH/s5"; build_copy "$S5" "$ROOT"
total=$((total+1))
/usr/bin/python3 -c "
p = '$S5/ops/server/install.sh'
with open(p) as f: c = f.read()
old = 'cp -- \"\$BACKUP/orch-peak\" \"\$SBIN_DST/orch-peak\"'
new = 'rm -f \"\$SBIN_DST/orch-peak\"; [ -f \"\$BACKUP/orch-peak\" ] && cp -- \"\$BACKUP/orch-peak\" /tmp/.bak'
if old in c:
    c = c.replace(old, new)
    with open(p, 'w') as f: f.write(c)
    print('s5 ok')
else:
    print('s5 anchor missing')
" 2>&1
OPS093_ROOT="$S5" /bin/bash "$HERE/red_otkat_vozvrashhaet_rabochuju.sh" >/dev/null 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then caught=$((caught+1)); printf 's5 откат-удаление: ПОЙМАН (rc=%s)\n' "$rc" >&2
else printf '✗ s5 откат-удаление: НЕ ПОЙМАН (rc=0)\n' >&2; fi

# Stub s6: сироты-живут — пускач не чистит потомков (TERM/KILL-фазы наблюдателя
# вырезаны). Якорь — дословные строки pkill субъекта (прежний якорь содержал
# мусорный шаблон '.\^omp -- profile.' и не совпадал с субъектом).
S6="$SCRATCH/s6"; build_copy "$S6" "$ROOT"
total=$((total+1))
/usr/bin/python3 -c "
p = '$S6/ops/server/user/orch-loop'
with open(p) as f: c = f.read()
old1 = 'pkill -TERM -P \"\$loop_pid\" -f \x27^omp --profile\x27 || exit 0'
old2 = 'pkill -KILL -P \"\$loop_pid\" -f \x27^omp --profile\x27; exit 0'
if old1 in c and old2 in c:
    c = c.replace(old1, 'true', 1)
    c = c.replace(old2, 'true; exit 0', 1)
    with open(p, 'w') as f: f.write(c)
    print('s6 ok')
else:
    print('s6 anchor missing')
" 2>&1
OPS093_ROOT="$S6" /bin/bash "$HERE/red_net_osirotevshih_detej.sh" >/dev/null 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then caught=$((caught+1)); printf 's6 сироты-живут: ПОЙМАН (rc=%s)\n' "$rc" >&2
else printf '✗ s6 сироты-живут: НЕ ПОЙМАН (rc=0)\n' >&2; fi

# Stub s7: uid-не-переключается — orch-loop игнорирует agent uid.
S7="$SCRATCH/s7"; build_copy "$S7" "$ROOT"
total=$((total+1))
/usr/bin/python3 -c "
p = '$S7/ops/server/user/orch-loop'
with open(p) as f: c = f.read()
old = 'if [ -n \"\${ORCH_LOOP_AGENT_CMD:-}\" ]; then'
if old in c:
    c = c.replace(old, 'if false; then')
    with open(p, 'w') as f: f.write(c)
    print('s7 ok')
else:
    print('s7 anchor missing')
" 2>&1
OPS093_ROOT="$S7" /bin/bash "$HERE/red_agent_uid_stancija_nedostupna.sh" >/dev/null 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then caught=$((caught+1)); printf 's7 uid-не-переключается: ПОЙМАН (rc=%s)\n' "$rc" >&2
else printf '✗ s7 uid-не-переключается: НЕ ПОЙМАН (rc=0)\n' >&2; fi

[ "$caught" -eq "$total" ] || { printf 'КЛЕТКА-ОТКАЗ(093-bat): %s/%s стабов пойманы\n' "$caught" "$total" >&2; exit 1; }
printf 'ЗЕЛЁНО(093-bat): %s/%s обманных стабов пойманы\n' "$caught" "$total" >&2
exit 0
