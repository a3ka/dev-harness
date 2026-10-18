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
# Якоря сверены живым прогоном против дерева приёмки этой пачки (5a089758,
# wip/int-093/implementer после Рв2-5/Рв2-6; А-906: якоря снимаются на
# ДЕРЕВО ПРИЁМКИ пачки, не на дерево прошлой пачки): kill_tree +
# reap_session — обе точки зачистки, единственная форма AGENT_HOME; s4 —
# блок verify-start v2 (t0 + restart + oneshot_new_run_done), s8 —
# сравнение свежести oneshot_new_run_done. Правка этих мест субъекта
# меняет текст — якорь не найден → стаб не построен → батарея честно
# краснеет, якорь переснять.
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
# (включая комментарии). Миграция Н-304: отказ переехал с файловой метки $RAN
# на канал подтверждения — якорь снят по новой форме «if [ "$receipt" != SCOPED ]».
S1="$SCRATCH/s1"; build_copy "$S1" "$ROOT"
total=$((total+1))
if build_out="$(/usr/bin/python3 -c "
p = '$S1/ops/server/user/orch-loop'
with open(p) as f: c = f.read()
old = 'if [ \"\$receipt\" != SCOPED ]; then\\n  # И-5 (997, инв. 2): scope создан, но подтверждение не получено (systemd-run отказал,\\n  # stdout SCOPED не считается, ошибка подготовки/чтения канала) — именованный отказ rc 1,\\n  # сессия НЕ стартует, цикл останавливается, повторов нет.\\n  log \"сессия #\$n: запуск в scope не подтверждён — запуск без потолка запрещён (И-5, контракт 093)\"\\n  kill \"\$watcher\" 2>/dev/null; wait \"\$watcher\" 2>/dev/null\\n  exit 1\\nfi'
new_block = 'if [ \"\$receipt\" != SCOPED ]; then\\n  log \"БЕЗ ПОТОЛКА\"\\n  \"\$WORKSHOP\" --yolo -- \"\$MSG\"; rc=\$?\\n  kill \"\$watcher\" 2>/dev/null; wait \"\$watcher\" 2>/dev/null\\n  exit \"\$rc\"\\nfi'
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

# Stub s2: bootstrap-из-репо — возвращает root-bootstrap на ${REPO}
# (предпочтение репо-пути над установленным; валидация А-1 сохранена —
# мутант проверяет i1 на РЕПО-пути). Поимка (А-6): клетка 1 моделирует
# станцию stat-шимом (установленная пара = root 0; репо-путь — реальный
# harness-uid) и требует в прогоне A rc 0 честной пары — мутант обязан
# либо отказаться на harness-uid репо-пути (rc≠0, регрессия доступности),
# либо исполнить отраву (свидетель SVID_REPO); обе формы красны прогоном
# A. Замер до А-6 (5a089758): стаб неразличим — честный субъект и мутант
# оба отказывают на i1-владельце ДО source (реальный stat uid≠0 на любом
# пути безроотного toy-мира), свидетель недостижим.
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
# не запуская юнит ЭТОЙ пробой и не спрашивая systemctl. Ловится клеткой 5
# v2: мир-ок — в журнале шима нет start/restart ЭТОЙ пробы; мир-падение —
# упавший юнит принят за успех. Якорь (переснят на код v2 кругом
# реализации Рв2-5, дерево приёмки 5a089758): ДОСЛОВНЫЙ блок verify-start
# — t0 + restart + oneshot_new_run_done (сообщения «юнит не стартует»
# встречаются только в verify-start — блок уникален); ПОРЧА ТОЛЬКО
# ПЕРВОГО вхождения: рестарт и опрос свойств вырезаются, печать успеха
# (строки ниже блока) остаётся. ДО-v2 якорь (строка is-active) снят
# реализацией Рв2-5.
S4="$SCRATCH/s4"; build_copy "$S4" "$ROOT"
total=$((total+1))
if build_out="$(/usr/bin/python3 -c "
p = '$S4/ops/server/install.sh'
with open(p) as f: c = f.read()
old = '    t0=\"\$(date +%s%N)\"\\n    \"\$SYSTEMCTL\" restart \"\$UNIT\" >/dev/null 2>&1 \\\\\\n      || { printf \\'юнит не стартует: %s (restart отказал)\\\\n\\' \"\$UNIT\" >&2; exit 1; }\\n    why=\"\$(oneshot_new_run_done \"\$UNIT\" \"\$t0\")\" \\\\\\n      || { printf \\'юнит не стартует: %s (%s)\\\\n\\' \"\$UNIT\" \"\$why\" >&2; exit 1; }'
if old in c:
    c = c.replace(old, '    : # s4 стаб: успех без старта — рестарт и опрос свойств вырезаны', 1)
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

# Stub s8: stale-запуск (v2, Рв2-5) — Result=success принимается БЕЗ
# проверки свежести ExecMainExitTimestamp: старый успех за новый запуск.
# Мутация режет ТОЛЬКО сравнение свежести в oneshot_new_run_done
# (проверка Result=success и разбор штампа сохранены); рестарт и опрос
# свойств остаются честными — стаб зелён в мир-ок/мир-падение обеих
# клеток и красен ТОЛЬКО миром stale. Привязка к клеткам 5 И 6 — решение
# этого кода: обе ветви субъекта (verify-start и rollback) зовут ОДНУ
# функцию oneshot_new_run_done, поэтому её порча обязана дать rc 1 в обеих;
# прохождение любой из двух — поимка пустая, не засчитывается.
S8="$SCRATCH/s8"; build_copy "$S8" "$ROOT"
total=$((total+1))
if build_out="$(/usr/bin/python3 -c "
p = '$S8/ops/server/install.sh'
with open(p) as f: c = f.read()
old = '  if [ \"\$stamp\" -le \"\$t0\" ]; then'
if old in c:
    c = c.replace(old, '  if false; then  # s8 стаб: свежесть не проверяется', 1)
    with open(p, 'w') as f: f.write(c)
    print('s8 ok')
else:
    print('s8 anchor missing')
    raise SystemExit(1)
" 2>&1)"; then
  printf '%s\n' "$build_out" >&2
  OPS093_ROOT="$S8" /bin/bash "$HERE/red_unit_realno_startuet.sh" >/dev/null 2>&1; rc5=$?
  OPS093_ROOT="$S8" /bin/bash "$HERE/red_otkat_vozvrashhaet_rabochuju.sh" >/dev/null 2>&1; rc6=$?
  if [ "$rc5" -eq 1 ] && [ "$rc6" -eq 1 ]; then
    caught=$((caught+1)); printf 's8 stale-запуск: ПОЙМАН (клетка5 rc=1, клетка6 rc=1 — обе предъявили мир stale)\n' >&2
  else
    printf '✗ s8 stale-запуск: НЕ ПОЙМАН (клетка5 rc=%s, клетка6 rc=%s) — мир stale обязан краснеть в обеих\n' "$rc5" "$rc6" >&2
  fi
else
  printf '%s\n' "$build_out" >&2
  printf '✗ s8: ЯКОРЬ-НЕ-НАЙДЕН — стаб не построен, клетка НЕ засчитывается (переснять якорь по коду субъекта)\n' >&2
fi

# Тело provision_agent_code в редакции 96ec3a5b (adversary 093-v4: зеркало
# rsync --delete БЕЗ --delete-excluded — excluded-записи у получателя
# переживают установку). ЕДИНЫЙ источник для s9 (это тело с rsync → true)
# и s10 (это тело дословно). Привязка ОБОИХ стабов — по КОДУ (Н-39): граница
# функции `provision_agent_code() {` … первая `\n}\n` после неё; правка
# implementer'ом тела функции (Р-4(а) арбитража) якорь НЕ ломает —
# стаб подменяет тело целиком; переименование/дубль функции — якорь не
# найден → стаб не построен → батарея честно краснеет.
OLD_PROVISION_BODY='  [ -d "$MAIN_DST" ] \
    || { printf '"'"'ОТКАЗ: нет источника кода агента: %s\n'"'"' "$MAIN_DST" >&2; return 1; }
  command -v rsync >/dev/null 2>&1 \
    || { printf '"'"'NOT_IMPLEMENTED: нет rsync\n'"'"' >&2; exit 2; }
  mkdir -p "$AGENT_ROOT" || die_write "$AGENT_ROOT"
  rsync -a --delete --exclude='"'"'.env'"'"' --exclude='"'"'.env.*'"'"' --exclude='"'"'.ssh'"'"' \
    "$MAIN_DST"/ "$AGENT_ROOT"/ || die_write "$AGENT_ROOT"
  chown -R root:root "$AGENT_ROOT" 2>/dev/null || die_write "chown -R $AGENT_ROOT"
  chmod 755 "$AGENT_ROOT" || die_write "chmod $AGENT_ROOT"
  [ -x "$AGENT_ROOT/workshop" ] \
    || { printf '"'"'ОТКАЗ: в %s нет исполняемого workshop\n'"'"' "$AGENT_ROOT" >&2; return 1; }
  printf '"'"'провизионинг кода агента: %s (из %s, без .env*)\n'"'"' "$AGENT_ROOT" "$MAIN_DST"
'
replace_provision_body() { # $1=install.sh копии $2=новое тело $3=метка → rc 0 построен / 1 якорь не найден
  OLD_BODY_NEW="$2" /usr/bin/python3 - "$1" "$3" <<'PY'
import os, sys
p, tag = sys.argv[1], sys.argv[2]
new_body = os.environ['OLD_BODY_NEW']
with open(p) as f: c = f.read()
head = 'provision_agent_code() {\n'
if c.count(head) != 1:
    print(tag + ' anchor count=' + str(c.count(head))); raise SystemExit(1)
i = c.index(head) + len(head)
j = c.find('\n}\n', i)
if j < 0:
    print(tag + ' anchor: нет закрывающей }'); raise SystemExit(1)
c = c[:i] + new_body + c[j + 1:]
with open(p, 'w') as f: f.write(c)
print(tag + ' ok')
PY
}

# Stub s9: no-copy runtime (adversary 093-v3 BLOCKS) — rsync в
# provision_agent_code заменён успешным no-op (true); декларации и
# комментарии с /opt/orch-agent и /var/lib/orch-agent ОСТАВЛЕНЫ — текстовые
# правила R1–R5 клетки 9 такого мутанта не различают (живой замер на
# 412a66dc: rc=0, дефект проверки). Ловится ПОВЕДЕНЧЕСКИМ слоем клетки 9
# (тест-шов OPS_SERVER_AGENT_ROOT субъекта): мир F — install root отказал
# именованно «нет исполняемого workshop»; мир S — сентинел пережил install
# (sha ≠ оракулу в памяти). Тело — OLD_PROVISION_BODY с rsync-вызовом → true.
S9="$SCRATCH/s9"; build_copy "$S9" "$ROOT"
total=$((total+1))
S9_BODY="$(/usr/bin/python3 -c "
import sys
b = sys.stdin.read()
old = '  rsync -a --delete --exclude=\'.env\' --exclude=\'.env.*\' --exclude=\'.ssh\' \\\\\n    \"\$MAIN_DST\"/ \"\$AGENT_ROOT\"/ || die_write \"\$AGENT_ROOT\"\n'
if b.count(old) != 1: raise SystemExit(1)
sys.stdout.write(b.replace(old, '  true\n'))
" <<<"$OLD_PROVISION_BODY")" || { printf '✗ s9: тело no-copy не собрано из OLD_PROVISION_BODY\n' >&2; S9_BODY=""; }
if [ -n "$S9_BODY" ] && build_out="$(replace_provision_body "$S9/ops/server/install.sh" "$S9_BODY"$'\n' s9 2>&1)"; then
  printf '%s\n' "$build_out" >&2
  OPS093_ROOT="$S9" /bin/bash "$HERE/red_agent_runtime_vne_home.sh" >/dev/null 2>&1; rc9=$?
  if [ "$rc9" -eq 1 ]; then
    caught=$((caught+1)); printf 's9 no-copy runtime: ПОЙМАН (клетка9 rc=1 — install не доставил workshop, adversary 093-v3)\n' >&2
  else
    printf '✗ s9 no-copy runtime: НЕ ПОЙМАН (клетка9 rc=%s) — поведенческий слой клетки 9 обязан краснеть\n' "$rc9" >&2
  fi
else
  printf '%s\n' "${build_out:-}" >&2
  printf '✗ s9: ЯКОРЬ-НЕ-НАЙДЕН — стаб не построен, клетка НЕ засчитывается (переснять якорь по коду субъекта)\n' >&2
fi

# Stub s10: stale-mirror (adversary 093-v4 BLOCKS, арбитраж Р-4(б)) — тело
# provision_agent_code в редакции 96ec3a5b ДОСЛОВНО: rsync --delete без
# --delete-excluded, excluded .env/.env.*/.ssh у получателя переживают
# установку с rc 0 и остаются читаемыми uid агента. Различим от честной
# реализации ТОЛЬКО на входе мира S клетки 9 (stale-носители ДО install);
# мир F и sha workshop у него честные. Ловится клеткой 9 rc=1 «старый
# credential-носитель пережил install root».
S10="$SCRATCH/s10"; build_copy "$S10" "$ROOT"
total=$((total+1))
if build_out="$(replace_provision_body "$S10/ops/server/install.sh" "$OLD_PROVISION_BODY" s10 2>&1)"; then
  printf '%s\n' "$build_out" >&2
  OPS093_ROOT="$S10" /bin/bash "$HERE/red_agent_runtime_vne_home.sh" >"$SCRATCH/s10.log" 2>&1; rc10=$?
  if [ "$rc10" -eq 1 ] && grep -q 'старый credential-носитель пережил install' "$SCRATCH/s10.log"; then
    caught=$((caught+1)); printf 's10 stale-mirror: ПОЙМАН (клетка9 rc=1 — stale .env/.env.*/.ssh пережили install, adversary 093-v4)\n' >&2
  else
    printf '✗ s10 stale-mirror: НЕ ПОЙМАН (клетка9 rc=%s, последняя строка: %s) — мир S клетки 9 обязан краснеть ИМЕННО по носителю\n' \
      "$rc10" "$(tail -n 1 "$SCRATCH/s10.log")" >&2
  fi
else
  printf '%s\n' "$build_out" >&2
  printf '✗ s10: ЯКОРЬ-НЕ-НАЙДЕН — стаб не построен, клетка НЕ засчитывается (переснять якорь по коду субъекта)\n' >&2
fi

[ "$caught" -eq "$total" ] || { printf 'КЛЕТКА-ОТКАЗ(093-bat): %s/%s стабов пойманы\n' "$caught" "$total" >&2; exit 1; }
printf 'ЗЕЛЁНО(093-bat): %s/%s обманных стабов пойманы\n' "$caught" "$total" >&2
exit 0
