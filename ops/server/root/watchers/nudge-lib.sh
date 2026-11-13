# nudge-lib — общие условия «правильного» сторожа простоя (слово владельца 2026-10-27):
# не подгонять сессию, которая законно ждёт: (1) HANDOFF верхним блоком «ЖДЁТ ВЛАДЕЛЬЦА: …»;
# (2) у omp есть дочерний процесс-инструмент (фоновая задача, CI-ожидание, прогон);
# (3) квота GLM читается РАЗДЕЛЬНЫМИ окнами (5 ч и неделя) — решение по ней принимает
# только наблюдатель квот, сторожа простоя сессии за квоту не останавливают.
# Escape не посылается: сообщение встаёт в очередь, текущий инструмент не прерывается.
# Адресация панелей — только по живому процессу (pane_of), сохранённых %id нет.

# Дом пользователя harness (сторожа работают от root, $HOME которых — /root).
NL_HARNESS="${NL_HARNESS:-/home/harness}"

# waiting_owner <HANDOFF.md>: rc 0, если в ТЕКУЩЕМ верхнем блоке HANDOFF есть
# ЯВНЫЙ маркер ожидания владельца «ЖДЁТ ВЛАДЕЛЬЦА: …»; иначе rc 1.
#
# Верхний блок — от начала файла до ВТОРОГО заголовка «## » (первый «## » —
# заголовок блока, второй — его конец; второго нет — блок до конца файла;
# вступление «# …» перед первым «## » входит в блок). Исторические блоки ниже
# не читаются.
#
# Маркер — строка блока, НАЧИНАЮЩАЯся с «ЖДЁТ ВЛАДЕЛЬЦА»: обычный bullet
# («- », «* », «+ », «N. ») и bold/italic («**…**») в начале строки допускаются.
# Первая строка файла, строка под заголовком, строка после указателя — все
# положительны. «ЖДЁТ ВЛАДЕЛЬЦА: нет» — отрицательный маркер (ожидания нет).
# Проза и цитаты («… ЖДЁТ ВЛАДЕЛЬЦА: …» внутри строки, «> ЖДЁТ ВЛАДЕЛЬЦА: …»)
# маркером НЕ являются: смысл произвольной прозы не реконструируется.
waiting_owner() {
  [ -f "$1" ] || return 1
  local rc=0
  awk -v mark='ЖДЁТ ВЛАДЕЛЬЦА' '
    function decor(s) {   # снять markdown-оформление в начале строки
      sub(/^[ \t]+/, "", s)
      sub(/^([-*+][ \t]+|[0-9]+[.)][ \t]+)/, "", s)
      sub(/^(\*\*|__|\*|_)+[ \t]*/, "", s)
      sub(/^[ \t]+/, "", s)
      return s
    }
    /^## / { h2++; if (h2 > 1) exit }   # конец верхнего блока — ВТОРОЙ «## »
    {
      l = decor($0)
      if (substr(l, 1, length(mark)) != mark) next
      r = decor(substr(l, length(mark) + 1))
      sub(/^:[ \t]*/, "", r)
      r = decor(r)
      if (r !~ /^нет($|[ ,;:!.)—-])/) { found = 1; exit }
    }
    END { exit(found ? 0 : 1) }
  ' "$1" 2>/dev/null || rc=$?
  [ "$rc" -eq 0 ] && return 0
  return 1
}

has_job() { # $1 — PID omp → rc 0, если есть дочерний процесс, кроме демона omp
  local c; for c in $(pgrep -P "$1"); do
    case "$(cat /proc/$c/comm 2>/dev/null)" in omp*) ;; *) return 0 ;; esac
  done; return 1
}
omp_pid_of() { # $1 — cwd проекта → PID omp (первый найденный; пусто — процесса нет
  local x; for x in $(pgrep -f '^omp --profile'); do
    [ "$(readlink /proc/$x/cwd)" = "$1" ] && { echo "$x"; return; }
  done
}

# pane_of <repo>: панель tmux через цепочку родителей живого omp с cwd == repo.
# Сохранённых id панелей нет и быть не может: su -P создаёт свой pts, поэтому
# сравнение tty omp с pane_tty ложно (замер 2026-11-12: зашитые %0/%1 давно мертвы,
# живые панели — другие номера). Нет процесса, нет tmux или несколько процессов
# проекта — отказ: в чужую панель не пишем.
pane_of() {
  local repo="$1" pid panes match parent candidates depth=0
  candidates="$(for pid in $(pgrep -f '^omp --profile'); do
    [ "$(readlink "/proc/$pid/cwd")" = "$repo" ] && printf '%s\n' "$pid"
  done)"
  [ "$(printf '%s\n' "$candidates" | grep -c '^[0-9]')" = 1 ] || return 1
  pid="$candidates"
  panes="$(tmux list-panes -a -F '#{pane_pid} #{pane_id}' 2>/dev/null)" || return 1
  while [ "$pid" -gt 1 ] && [ "$depth" -lt 64 ]; do
    match="$(printf '%s\n' "$panes" | awk -v p="$pid" '$1 == p {print $2}')"
    if [ -n "$match" ]; then printf '%s\n' "$match"; return 0; fi
    parent="$(awk '/^PPid:/ {print $2}' "/proc/$pid/status" 2>/dev/null)"
    case "$parent" in ''|*[!0-9]*) return 1 ;; esac
    [ "$parent" != "$pid" ] || return 1
    pid="$parent"
    depth=$((depth+1))
  done
  return 1
}

# pin_handoff <корень проекта>: живой пин-HANDOFF сессии проекта — пин-worktree
# двери подключения (scripts/connect_project.sh: ~/dev-harness-projects/<pid>/wt/
# wip-136-demo/.harness/HANDOFF.md), НЕ старая копия в main. Путь — поле двери
pin_handoff() {
  local hf="$NL_HARNESS/dev-harness-projects/$(printf '%s' "$(basename "$1")" | tr 'A-Z' 'a-z' | tr -c 'a-z0-9_-' '-')/wt/wip-136-demo/.harness/HANDOFF.md"
  [ -f "$hf" ] && { printf '%s\n' "$hf"; return 0; }
  return 1
}

# quota_windows: ответ z.ai api/monitor/usage/quota/limit → «<5ч %> <неделя %>».
# 5-часовое окно — number=5/unit=3, недельный лимит — number=1/unit=6: читаются
# РАЗДЕЛЬНО (старый сторож читал недельные 100% как 5-часовое окно). Неполный
# или неизвестный ответ — ошибка jq: доступной квотой НЕ объявляется.
quota_windows() {
  jq -er '
    .data.limits as $limits |
    [$limits[] | select(.number == 5 and .unit == 3) | .percentage] as $hour |
    [$limits[] | select(.number == 1 and .unit == 6) | .percentage] as $week |
    if ($hour | length) == 1 and ($week | length) == 1
       and ($hour[0] | type) == "number" and ($week[0] | type) == "number"
    then "\($hour[0]) \($week[0])" else error("quota: неизвестные окна") end
  '
}
