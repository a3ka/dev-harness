#!/usr/bin/env bash
# Батарея обманных стабов 093 (Н-39): каждая порча — точечная правка копии
# субъекта. ЯКОРЬ обязателен и проверяется КОДОМ (починка Рв2-2 круга 3):
# строителю запрещено молчать — якорь не найден → стаб не построен → клетка
# НЕ запускается и НЕ засчитывается (именованный отказ «ЯКОРЬ-НЕ-НАЙДЕН»,
# батарея краснеет через caught<total). Ручной прогон клетки на нестабе
# исключён: verdict() видит только построенные стабы. Соответствующая клетка
# обязана отказать rc 1 на стабе.
# ПОИМКА (починка Р1-2/Р1-3 круга 1): засчитывается ТОЛЬКО rc 1 — именованный
# отказ клетки. rc 0 — стаб прошёл (дефект клетки); rc 2 NOT_IMPLEMENTED —
# ПОИМКА ПУСТАЯ (клетка вышла 2 при любом субъекте — не доказывает
# различимость стаба) и НЕ засчитывается.
# Якоря сверены живым прогоном против дерева круга 3 (merge ad61f9f5 с
# implementer-фиксом b2fa5360: kill_tree + reap_session — обе точки зачистки,
# единственная форма AGENT_HOME). Правка этих мест субъекта меняет текст —
# якорь не найден → стаб не построен → батарея честно краснеет, якорь
# переснять.
set -o pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${OPS093_ROOT:-$(cd "$HERE/../.." && pwd)}"
[ -f "$ROOT/ops/server/install.sh" ] || { printf 'NOT_IMPLEMENTED: нет install.sh\n' >&2; exit 2; }
[ -f "$ROOT/ops/server/root/orch-peak" ] || { printf 'NOT_IMPLEMENTED: нет orch-peak\n' >&2; exit 2; }
[ -f "$ROOT/ops/server/user/orch-loop" ] || { printf 'NOT_IMPLEMENTED: нет orch-loop\n' >&2; exit 2; }

SCRATCH="$(mktemp -d /tmp/dev-harness-verify/ops-granica-bat-XXXXXX)" || { printf 'NOT_IMPLEMENTED: mktemp\n' >&2; exit 2; }
trap 'rm -rf "$SCRATCH"' EXIT

build_copy() { # $1=dst $2=src — толерантный bulk-copy + гарантированные
  # субъектные файлы (клетке 6 нужны и юниты; сбой bulk-копии не должен
  # оставлять стаб без субъекта — иначе rc 2 «поимка пустая» вместо порчи)
  mkdir -p "$1/ops/server/root/systemd" "$1/ops/server/user" "$1/scripts" "$1/fixtures/ops_granica"
  /bin/cp -r "$2/." "$1/" 2>/dev/null || true
  /bin/cp "$2/ops/server/install.sh" "$1/ops/server/install.sh"
  /bin/cp "$2/ops/server/root/orch-peak" "$1/ops/server/root/orch-peak"
  /bin/cp "$2/ops/server/user/orch-loop" "$1/ops/server/user/orch-loop"
  /bin/cp -r "$2/ops/server/root/systemd/." "$1/ops/server/root/systemd/"
}
caught=0
total=0

verdict() { # $1=метка $2=rc клетки — поимка ТОЛЬКО rc 1 (см. шапку)
  local tag="$1" rc="$2"
  if [ "$rc" -eq 1 ]; then
    caught=$((caught+1)); printf '%s: ПОЙМАН (rc=1)\n' "$tag" >&2
  elif [ "$rc" -eq 2 ]; then
    printf '✗ %s: НЕ ПОЙМАН (rc=2 NOT_IMPLEMENTED — поимка пустая, не засчитана)\n' "$tag" >&2
  else
    printf '✗ %s: НЕ ПОЙМАН (rc=%s)\n' "$tag" "$rc" >&2
  fi
}

# Stub s1: фолбэк-без-потолка — возвращает удалённую ветку orch-loop (запуск
# сессии при несозданном scope). Якорь — ДОСЛОВНЫЙ блок отказа И-5 субъекта
# (включая комментарии; прежний якорь пропускал строку комментария).
S1="$SCRATCH/s1"; build_copy "$S1" "$ROOT"
total=$((total+1))
if build_out="$(/usr/bin/python3 -c "
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
    raise SystemExit(1)
" 2>&1)"; then
  printf '%s\n' "$build_out" >&2
  OPS093_ROOT="$S1" /bin/bash "$HERE/red_limit_otkaz_bez_zapuska.sh" >/dev/null 2>&1
  verdict 's1 фолбэк-без-потолка' $?
else
  printf '%s\n' "$build_out" >&2
  printf '✗ s1: ЯКОРЬ-НЕ-НАЙДЕН — стаб не построен, клетка НЕ засчитывается (переснять якорь по коду субъекта)\n' >&2
fi

# Stub s2: bootstrap-из-репо — возвращает root-bootstrap на ${REPO}.
S2="$SCRATCH/s2"; build_copy "$S2" "$ROOT"
total=$((total+1))
if build_out="$(/usr/bin/python3 -c "
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
    raise SystemExit(1)
" 2>&1)"; then
  printf '%s\n' "$build_out" >&2
  OPS093_ROOT="$S2" /bin/bash "$HERE/red_root_bootstrap_iz_repo.sh" >/dev/null 2>&1
  verdict 's2 bootstrap-из-репо' $?
else
  printf '%s\n' "$build_out" >&2
  printf '✗ s2: ЯКОРЬ-НЕ-НАЙДЕН — стаб не построен, клетка НЕ засчитывается (переснять якорь по коду субъекта)\n' >&2
fi

# Stub s3: кредит-в-среде — экспортирует publication-креденшл ПОЛНЫМ
# станционным списком имён (GIT_SSH_COMMAND/GITHUB_TOKEN/ODELIX_GITHUB_TOKEN
# — как клетка 4 после А-4 круга 2: прежние два имени оставляли пятое
# станционное имя — токен org odelixhq — непроверенным). Якорь —
# ЕДИНСТВЕННАЯ форма строки AGENT_HOME живого кода (после сноса ветвей
# В1-9/Р1-9б дубля имён нет; починка Рв2-2 круга 3: мёртвая двуименная
# форма якоря удалена). Точка порчи — экспорт креденшл в среду, из которой
# запускается сессия, ПОСЛЕ съёма на входе (orch-loop:26): инъекция
# переживает unset и обязана дойти до ребёнка. ЕСЛИ фикс А-3 строит
# allowlist-среду НА ТОЧКЕ ЗАПУСКА (env -i у exec) — инъекция после
# AGENT_HOME перестаёт быть наблюдаемой, якорь переснять за точку
# allowlist (Н-39: стаб к входу, где его дефект наблюдаем).
S3="$SCRATCH/s3"; build_copy "$S3" "$ROOT"
total=$((total+1))
if build_out="$(/usr/bin/python3 -c "
p = '$S3/ops/server/user/orch-loop'
with open(p) as f: c = f.read()
old = 'AGENT_HOME=\"\${ORCH_AGENT_HOME:-/var/lib/orch-agent}\"'
new = '\\nexport GIT_SSH_COMMAND=\"ssh -i /tmp/fake-rw\"\\nexport GITHUB_TOKEN=\"fake-token\"\\nexport ODELIX_GITHUB_TOKEN=\"fake-odelix\"'
if old in c:
    c = c.replace(old, old + new, 1)
    with open(p, 'w') as f: f.write(c)
    print('s3 ok')
else:
    print('s3 anchor missing')
    raise SystemExit(1)
" 2>&1)"; then
  printf '%s\n' "$build_out" >&2
  OPS093_ROOT="$S3" /bin/bash "$HERE/red_kredit_publikacii_vne_sredy.sh" >/dev/null 2>&1
  verdict 's3 кредит-в-среде' $?
else
  printf '%s\n' "$build_out" >&2
  printf '✗ s3: ЯКОРЬ-НЕ-НАЙДЕН — стаб не построен, клетка НЕ засчитывается (переснять якорь по коду субъекта)\n' >&2
fi

# Stub s4: успех-без-старта (v2, Рв2-5) — verify-start отвечает успехом,
# не запуская юнит ЭТОЙ пробой и не спрашивая systemctl (state=active).
# Ловится клеткой 5 v2: мир-ок — в журнале шима нет start/restart ЭТОЙ
# пробы; мир-падение — упавший юнит принят за успех. Якорь — дословная
# строка опроса is-active ДО-v2 субъекта; ПОРЧА ТОЛЬКО ПЕРВОГО вхождения
# (verify-start в файле раньше rollback). С реализацией Рв2-5 якорь
# переснимается на строку запуска/опроса свойств v2 тем же кругом, что
# переснимает s5 и заводит s8 «stale-запуск» (контракт v2 §Обманные стабы).
S4="$SCRATCH/s4"; build_copy "$S4" "$ROOT"
total=$((total+1))
if build_out="$(/usr/bin/python3 -c "
p = '$S4/ops/server/install.sh'
with open(p) as f: c = f.read()
old = '    state=\"\$(\"\$SYSTEMCTL\" is-active \"\$UNIT\" 2>&1)\" || true'
if old in c:
    c = c.replace(old, '    state=active', 1)
    with open(p, 'w') as f: f.write(c)
    print('s4 ok')
else:
    print('s4 anchor missing')
    raise SystemExit(1)
" 2>&1)"; then
  printf '%s\n' "$build_out" >&2
  OPS093_ROOT="$S4" /bin/bash "$HERE/red_unit_realno_startuet.sh" >/dev/null 2>&1
  verdict 's4 успех-без-старта' $?
else
  printf '%s\n' "$build_out" >&2
  printf '✗ s4: ЯКОРЬ-НЕ-НАЙДЕН — стаб не построен, клетка НЕ засчитывается (переснять якорь по коду субъекта)\n' >&2
fi

# Stub s5: откат-удаление — rollback удаляет новую версию, не восстанавливая
# прежнюю. ВНИМАНИЕ (зависимость от В1-1): якорь — строка восстановления
# текущей реализации rollback; правка механизма отката ломает якорь —
# переснять на новую строку восстановления.
S5="$SCRATCH/s5"; build_copy "$S5" "$ROOT"
total=$((total+1))
if build_out="$(/usr/bin/python3 -c "
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
    raise SystemExit(1)
" 2>&1)"; then
  printf '%s\n' "$build_out" >&2
  OPS093_ROOT="$S5" /bin/bash "$HERE/red_otkat_vozvrashhaet_rabochuju.sh" >/dev/null 2>&1
  verdict 's5 откат-удаление' $?
else
  printf '%s\n' "$build_out" >&2
  printf '✗ s5: ЯКОРЬ-НЕ-НАЙДЕН — стаб не построен, клетка НЕ засчитывается (переснать якорь по коду субъекта)\n' >&2
fi

# Stub s6: сироты-живут — пускач не чистит потомков. Починка Рв2-2/Рв2-3
# круга 3: якоря — ОБЕ точки зачистки живого кода: kill_tree в наблюдателе
# (гашение по маркеру — прогон b клетки 7) и вызов reap_session
# (естественный выход rc 0 — прогон a клетки 7). Мёртвая легаси-ветка
# pkill '^omp --profile' удалена: на дереве круга 3 её нет. Клетка 7 судит
# зачистку без фильтра по имени: несовпадающий потомок переживает
# вырезанное → красная.
S6="$SCRATCH/s6"; build_copy "$S6" "$ROOT"
total=$((total+1))
if build_out="$(/usr/bin/python3 -c "
p = '$S6/ops/server/user/orch-loop'
with open(p) as f: c = f.read()
kt1 = 'kill_tree TERM \"\$loop_pid\"'
kt2 = 'kill_tree KILL \"\$loop_pid\"'
kt3 = '\nreap_session   # '
if kt1 in c and kt2 in c and kt3 in c:
    c = c.replace(kt1, 'true', 1)
    c = c.replace(kt2, 'true', 1)
    c = c.replace(kt3, '\ntrue          # ', 1)
    with open(p, 'w') as f: f.write(c)
    print('s6 ok (kill_tree+reap)')
else:
    print('s6 anchor missing')
    raise SystemExit(1)
" 2>&1)"; then
  printf '%s\n' "$build_out" >&2
  OPS093_ROOT="$S6" /bin/bash "$HERE/red_net_osirotevshih_detej.sh" >/dev/null 2>&1
  verdict 's6 сироты-живут' $?
else
  printf '%s\n' "$build_out" >&2
  printf '✗ s6: ЯКОРЬ-НЕ-НАЙДЕН — стаб не построен, клетка НЕ засчитывается (переснять якорь по коду субъекта)\n' >&2
fi

# Stub s7: uid-не-переключается — починка Р1-3 круга 1. Прежняя мутация
# (if false на ветке шва) была НЕНАБЛЮДАЕМА: ветки orch-loop побайтно
# одинаковы, переключение шва ничего не меняло. Мутация режет САМ
# sudo-вызов двери uid: `exec sudo -nu "$3" "$4"` → `exec "$4"` (ВО ВСЕХ
# вхождениях; запасной шаблон ловит перенумерацию позиционных аргументов
# после сноса ветвей В1-9). Сессия стартует напрямую под uid владельца
# станции — клетка 3 (дверь uid) обязана краснеть.
S7="$SCRATCH/s7"; build_copy "$S7" "$ROOT"
total=$((total+1))
if build_out="$(/usr/bin/python3 -c "
import re
p = '$S7/ops/server/user/orch-loop'
with open(p) as f: c = f.read()
n = c.count('exec sudo -nu \"\$3\" \"\$4\"')
if n > 0:
    c = c.replace('exec sudo -nu \"\$3\" \"\$4\"', 'exec \"\$4\"')
    with open(p, 'w') as f: f.write(c)
    print('s7 ok (exact x%d)' % n)
else:
    pat = re.compile(r'exec sudo -nu \"[^\"]+\" (\"\$\w+\")')
    m = pat.findall(c)
    if m:
        c = pat.sub(lambda mm: 'exec ' + mm.group(1), c)
        with open(p, 'w') as f: f.write(c)
        print('s7 ok (generic x%d)' % len(m))
    else:
        print('s7 anchor missing')
        raise SystemExit(1)
" 2>&1)"; then
  printf '%s\n' "$build_out" >&2
  OPS093_ROOT="$S7" /bin/bash "$HERE/red_agent_uid_stancija_nedostupna.sh" >/dev/null 2>&1
  verdict 's7 uid-не-переключается' $?
else
  printf '%s\n' "$build_out" >&2
  printf '✗ s7: ЯКОРЬ-НЕ-НАЙДЕН — стаб не построен, клетка НЕ засчитывается (переснять якорь по коду субъекта)\n' >&2
fi

[ "$caught" -eq "$total" ] || { printf 'КЛЕТКА-ОТКАЗ(093-bat): %s/%s стабов пойманы\n' "$caught" "$total" >&2; exit 1; }
printf 'ЗЕЛЁНО(093-bat): %s/%s обманных стабов пойманы\n' "$caught" "$total" >&2
exit 0
