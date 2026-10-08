#!/usr/bin/env bash
# Клетка Н-219 (ОБЯЗАТЕЛЬНАЯ, NABLIUDENIA.md): ни одна клетка семьи 090 не
# имеет права создать ИЛИ ИЗМЕНИТЬ файл под множеством чтения реального
# orch-peak — подпуть
# `$UHOME/.local/state/dev-harness-sessions/*/zones/dev/.omp/profiles/dev/agent/sessions/--home-harness-dev-harness--/**`
# (SESS_GLOB, orch-peak:34,121,155,246,248; lib_session.sh:18,29) и
# `/var/lib/orch-peak/**` (формулировка — решение арбитража
# verdicts/arbitration/contracts-090-vopros-watcher-i-provodka.md) — живой
# станционный `orch-peak` читает ИМЕННО эти пути напрямую (не через тест-шов
# ORCH_PEAK_TEST), и тестовая сессия, однажды попавшая туда, принимается им
# за настоящую (измерено: 21:45 2026-10-07, ложный «принудительный
# перезапуск», 15м GRACE — см. Н-219).
#
# ВАЖНО (круг 1 critic, найдено живьём): ПЕРВАЯ редакция этой клетки
# фильтровала находки ПО ИМЕНИ (`*z090test*`) — слепа к порче, назвавшей файл
# ИНАЧЕ. Живой контрпример критика: декой пишет
# `.../dev-harness-sessions/ordinary-session/journal.jsonl` под контролируемый
# home — старый предикат давал `WATCHER_RC=0 POLLUTION_EXISTS=True` (ложное
# зелёное на реальной порче). ИСПРАВЛЕНО: предикат больше НЕ фильтрует по
# имени — ЛЮБОЙ НОВЫЙ путь (файл, которого не было в базлайне) ИЛИ ЛЮБОЙ
# СУЩЕСТВОВАВШИЙ путь с ИЗМЕНИВШИМСЯ mtime — нарушение. Полный список путей +
# mtime, не фильтр по подстроке имени.
#
# ВАЖНО №2 (измерено на первой редакции): клетки семьи ЧИСТЯТ СВОЙ СЛЕД сами
# (trap cleanup EXIT) — проверка СНАРУЖИ строго ДО/ПОСЛЕ прогона НЕ видит
# нарушение, если файл существовал только ТРАНЗИТНО. Проверка — ФОНОВЫЙ
# watcher, опрашивающий реальные пути КАЖДЫЕ 0.05с, ПОКА семья исполняется.
#
# Дано:  субъект (ORCH090_SUBJECT, умолчание — корень репо этой фикстуры).
# Когда: вся семья 090 (лёгкая+глубокая+глубокая-дефолт-getent+install+батарея) прогнана подряд,
#        фоновый watcher опрашивает ПОЛНЫЙ список путей+mtime реальных
#        каталогов всё это время.
# Тогда: watcher НИ РАЗУ не увидел НИ НОВОГО пути, НИ ИЗМЕНИВШЕГОСЯ mtime
#        существовавшего пути под реальными каталогами.
# Ловит (Н-39, обманный стаб строится из ТЕКУЩЕГО субъекта — не мёртвая
# копия): декой-клетка — КОПИЯ `red_ctx_deep_no_home.sh` БЕЗ fakehome-
# изоляции (оригинальная архитекторская версия ДО П3) — сажает сессию под
# РЕАЛЬНЫЙ UHOME (полной структурой каталогов сессии — ВНУТРЬ подпути SESS_GLOB,
# потому и ловится) С ПРОИЗВОЛЬНЫМ ИМЕНЕМ (не только `z090test*`) — ЭТА клетка
# обязана поймать её транзитное присутствие НЕЗАВИСИМО от имени файла; запись ВНЕ
# подпути SESS_GLOB клеткой НЕ ловится (вне множества чтения orch-peak — см. СКОУП
# и ОСТАТОЧНЫЙ РИСК ниже, решение арбитража).
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib.sh"
SUBJ="${ORCH090_SUBJECT:-$(fix090_repo_root "$HERE")}"

REAL_UHOME="$(getent passwd "${ORCH_USER:-harness}" | cut -d: -f6)"
[ -n "$REAL_UHOME" ] || fix090_fail "getent не дал home пользователя — нечем сверять герметичность"
REAL_SESS="$REAL_UHOME/.local/state/dev-harness-sessions"
REAL_STATE="/var/lib/orch-peak"

# РЕАЛЬНО сканируемый скоуп для сообщений (решение арбитража, п.3): сообщения
# называют его, а не каталог сессий целиком — сообщение не смеет утверждать
# больше проверенного.
SCOPE_SESS="$REAL_SESS/*/zones/dev/.omp/profiles/dev/agent/sessions/--home-harness-dev-harness--/**"
SCOPE_STATE="$REAL_STATE/**"

# СКОУП (круг1-фикс №2, измерено живьём): НЕ весь дерево dev-harness-sessions —
# там живёт `agent.db-shm`/`agent.db-wal` (SQLite WAL СОБСТВЕННОЙ живой сессии
# omp, churnит каждую секунду, НЕ имеет отношения к orch-peak glob'у и даёт
# ложные срабатывания на КАЖДОМ прогоне). orch-peak читает ТОЛЬКО подпуть
# `.../zones/dev/.omp/profiles/dev/agent/sessions/--home-harness-dev-harness--/**`
# (SESS_GLOB, orch-peak:34/lib_session.sh:18) — сканируем РОВНО его, ЛЮБОЙ файл
# внутри, БЕЗ фильтра по имени (круг1-фикс №1: критик поймал «z090test»-only
# фильтр живым контрпримером с другим именем файла). `/var/lib/orch-peak`
# сканируется ПОЛНОСТЬЮ — там нет посторонней живой churn-активности того же
# класса (это собственный state-каталог orch-peak, не омп-сессии).
#
# Записи под `dev-harness-sessions` ВНЕ подпути SESS_GLOB этой клеткой НЕ ловятся:
# они вне множества чтения orch-peak (не вызывают отказ Н-219) и остаются под общей
# нормой write-allowlist (Н-85/А-122: `/tmp/dev-harness-verify/**`) — оговорка сужения
# в контракте, решение арбитража `contracts-090-vopros-watcher-i-provodka.md`.
#
# ОСТАТОЧНЫЙ РИСК (названо прямо, не скрыто):
# 1) если РЕАЛЬНЫЙ станционный `orch-peak` конкурентно пишет СВОЙ ctx-файл ДЛЯ
#    ЭТОЙ ЖЕ РЕАЛЬНОЙ сессии в ТО ЖЕ окно (доли секунды прогона клетки) —
#    возможен ложный срабатывание (флейк, не истинное нарушение герметичности
#    ЭТОЙ фикстуры). Вероятность низка (узкое окно, редкий тик станционного
#    таймера); тест-инфраструктура, не production-граница — риск принят.
# 2) измерено арбитром (контрзамер 2026-10-07 23:42-23:46 UTC): журналы живых
#    субагентов (`<Имя>.jsonl`) и `*.bash.log` текущей сессии лежат ВНУТРИ
#    подпути SESS_GLOB и меняются во время работы — на станции (НЕ в CI)
#    возможен ложный красный, если субагент пишет журнал конкурентно во время
#    прогона клетки (замер: 3 пути за 3.5 минуты); в CI чисто — живой сессии нет.
# 3) orch-peak читает/пишет и `$UHOME/orch-peak-report.txt`,
#    `$UHOME/orch-loop.stop` (orch-peak:25-26) — ВНЕ обоих сканируемых каталогов,
#    этой клеткой НЕ сторожатся: декой с `orch-loop.stop` под реальным home
#    остановил бы реальный цикл и остался бы незамеченным (замечено арбитром);
#    закрывает их общая норма write-allowlist Н-85/А-122 (клетки пишут только в
#    `/tmp/dev-harness-verify/**`), не этот watcher.
scan_real() {
  find "$REAL_SESS" -path '*/zones/dev/.omp/profiles/dev/agent/sessions/--home-harness-dev-harness--*' -type f -printf '%p\t%T@\n' 2>/dev/null
  find "$REAL_STATE" -type f -printf '%p\t%T@\n' 2>/dev/null
}

W="$(fix090_scratch)"
HITS="$W/hits.txt"
: > "$HITS"
WATCH_STOP="$W/stop"

BASELINE="$W/baseline.txt"
scan_real | LC_ALL=C sort > "$BASELINE"

# watcher: на каждом опросе печатает строки ТЕКУЩЕГО скана, ОТСУТСТВУЮЩИЕ в
# базлайне ПО ЦЕЛОЙ СТРОКЕ (путь+mtime) — новый путь ИЛИ изменившийся mtime
# существующего пути ОБА дают новую строку относительно baseline.
watcher() {
  while [ ! -e "$WATCH_STOP" ]; do
    local cur
    cur="$(scan_real | LC_ALL=C sort)"
    comm -23 <(printf '%s\n' "$cur") "$BASELINE" 2>/dev/null
    sleep 0.05
  done
}
watcher >> "$HITS" &
WPID=$!
# гарантия: watcher реально стартовал и сделал хотя бы один проход до того,
# как семья начнёт писать — иначе гонка «семья успела до первого опроса»
sleep 0.1

run_cell() { # $1 = имя (диагностика, не влияет на вердикт ЭТОЙ клетки)
  local name="$1"; shift
  ORCH090_SUBJECT="$SUBJ" "$@" >/dev/null 2>&1 || true
}
run_cell "лёгкая" bash "$HERE/red_no_home_ctx.sh"
run_cell "глубокая" bash "$HERE/red_ctx_deep_no_home.sh"
run_cell "глубокая-дефолт-getent" bash "$HERE/red_ctx_deep_uhome_default.sh"
run_cell "install" bash "$HERE/red_install_local_config.sh"
run_cell "батарея" bash "$HERE/battery_stubs.sh"

touch "$WATCH_STOP"
wait "$WPID" 2>/dev/null || true

NEW_HITS="$(LC_ALL=C sort -u "$HITS" 2>/dev/null | sed '/^$/d' || true)"
if [ -n "$NEW_HITS" ]; then
  # Печатаем только ПУТИ (без mtime) в диагностике — компактнее.
  bad_paths="$(printf '%s\n' "$NEW_HITS" | cut -f1 | LC_ALL=C sort -u | tr '\n' ';')"
  fix090_fail "герметичность нарушена: НОВЫЕ/ИЗМЕНИВШЕЕСЯ пути под множеством чтения реального orch-peak во время прогона (подпуть SESS_GLOB: $SCOPE_SESS; state: $SCOPE_STATE): $bad_paths"
fi

[ "${ORCH090_KEEP:-}" = 1 ] || rm -rf "$W" 2>/dev/null || true
printf 'ЗЕЛЁНО(090-герметичность): семья прогнана целиком под фоновым watcher (опрос каждые 0.05с, полный список путей+mtime, БЕЗ фильтра по имени) по множеству чтения реального orch-peak: ни одного НОВОГО/ИЗМЕНИВШЕГОСЯ пути под подпутём SESS_GLOB %s или под %s не замечено\n' "$SCOPE_SESS" "$SCOPE_STATE"
exit 0
