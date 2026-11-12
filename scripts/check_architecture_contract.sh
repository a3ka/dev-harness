#!/usr/bin/env bash
# ДВЕРЬ АРХИТЕКТУРЫ (контракт 187а) — общий шов четырёх дверей станции.
#
# ПРЕДМЕТ: кодовые задачи проекта `repoId=Complior-back` в профильных
# workflowPaths.contracts. Только они получают требования 187а: харнесс, mob,
# документальные задачи и контракты модулей репозитория архитектуры нового
# отказа не получают. Отсутствие локальной `architecture/` после 167 НЕ
# переводит backend в legacy — переносит только ИСТОЧНИК брифа.
#
# ПРИЗНАК РЕЖИМА (две проверки, обе обязательны):
#   (1) эффективный repoId == Complior-back (repoId всегда origin repo —
#       scripts/profile_resolver.sh §merge; слой проекта его не перекрывает);
#   (2) наличие `architecture.lock.json` — пин модели. Это ТОЧКА ПЕРЕКЛЮЧЕНИЯ:
#       до неё бриф компонента читается из локальной `R/architecture/` (контракт
#       170), после — из закреплённого коммита. Пока пина нет, проект не в
#       режиме 187а и старые обязанности 170 живут как объявлены.
#
# ЗАКРЕПЛЁННАЯ МОДЕЛЬ — единственный источник архитектурных сведений:
#   клон модели → $ARCHITECTURE_ROOT (verify-pin клон, который даёт проектный
#                  CI; в нём лежит коммит из architecture.lock.json);
#   коммит      → .commit в architecture.lock.json — ровно 40 hex; отсутствие
#                 значения или не-hex (символьный pin) — ARCHITECTURE_NET,
#                 корректный hex, не разрешающийся в клоне, — ARCH_PIN;
#   чтение     → materialize дерева ЭТОГО коммита (`git archive`) и вызовы
#                `node tooling/checks/cli.js <locate|check>` ВНУТРИ этого
#                дерева; бриф — ПАКЕТНЫМ скриптом дерева
#                (`npm --prefix <дерево> run brief -- --compact
#                 [--with-rules] --component <id>`). Ни HEAD клона, ни локальная
#                `architecture/` продукта источником не являются (две разные
#                версии модели в одном пакете не смешиваются);
#   зависимости → в развёрнутом дереве с package-lock.json и без node_modules
#                 дверь исполняет `npm ci --ignore-scripts`; отсутствие npm
#                 или отказ `npm ci` — именованный ARCH_DEPS rc 2 (никогда
#                 не зелено).
#
# ЧТО СУДИТСЯ:
#   * класс предмета — самостоятельная строка `КЛАСС ЗАДАЧИ:`; её отсутствие —
#     ARCH_CLASS_MISSING на всех четырёх дверях; не-кодовое значение дверь не
#     вооружает (ARCH_187A_SKIP — не отказ);
#   * строка `АРХИТЕКТУРА: L1|L2|L3 <id,…>` — самостоятельная строка; список
#     непустой, без дублей и прозы (id: [A-Za-z0-9_][A-Za-z0-9._-]*). Пустая или
#     отсутствующая строка — ARCH_LINE_MISSING; L3 — отказ до решения владельца
#     (ARCH_OWNER);
#   * продуктовые пути `ЗОНА implementer:` — `locate --path` закреплённой
#     модели. Ответ читается ЦЕЛИКОМ (многострочный JSON) и классифицируется
#     по ЧЕТЫРЁМ классам ОТВЕТА модели (arch187_locate): компонентное размещение
#     (DECLARED с компонентами) судится против строки `АРХИТЕКТУРА:`; ответ без
#     компонентной претензии (безкомпонентный модуль, артефакт репозитория) —
#     конформ; неоднозначное размещение (несколько претендентов) —
#     PATH_WITHOUT_COMPONENT; неразбираемый ответ — ARCH_LOCATE_GRAMMAR rc 2.
#     Вид пути (каталог/расширение/имя) классификатором НЕ является;
#   * операция предмета — только ОБЪЯВЛЕННЫЕ строки `ОПЕРАЦИЯ:` (схемы
#     входа/выхода, не DRAFT); предмет без объявленной операции не отказывает
#     (ARCH_DRAFT — только по объявленной строке);
#   * `check --base` модели против УТВЕРЖДЁННОГО снимка (путь снимка и его
#     digest — по формату 167, из architecture.lock.json): rc 1 — ARCH_CHECK,
#     rc 2 — ARCH_NOT_EVALUATED (никогда не зелено). Вердикт — по rc и
#     именованным полям ворот; подстрочный поиск `NOT_EVALUATED` в теле
#     ответа ЗАПРЕЩЁН (это поле доказательств реализации, не вердикт).
#
# ВОЗВРАТЫ ДВЕРИ: 0 — зелено (или «187а не применима»); 1 — именованный
# отказ (маркер в stderr, первая строка); 2 — нечем проверить: ответ модели не
# разбирается (ARCH_LOCATE_GRAMMAR) либо зависимости дерева недоступны
# (ARCH_DEPS). Код возврата отказа держит ARCH187_RC (1 или 2).
#
# НЕ БАРЬЕР: роль файла объявлена явно, потому что scripts/verify_antiplacebo.sh
# требует фикстуру `fixtures/<ключ>/case_*.sh` от каждого барьера и не
# догадывается (файл без объявленной роли — отказ). Красное покрытие этой двери
# — семейство fixtures/workshop_project/architecture_process_187/ (зона
# architect, контракт 187/1): оно гоняет дверь через публичный интерфейс
# (`make_task`, `freeze_contract.sh`, `pre_critic.sh`, `done_contract.sh`) и
# конвенцию case_* не использует. Тот же приём, что у check_precision_gate.sh
# и check_no_leak.sh.
#
# РЕЖИМ БИБЛИОТЕКИ: `ARCH187_LIB=1 source check_architecture_contract.sh` —
# определены функции (строка архитектуры, зоны, locate/brief/check модели), ухода
# в исполнение двери нет. Тот же приём, что у next_id.sh (контракт 996 Б-5):
# одна реализация правил — одна, а не по копии на дверь.

# ── БИБЛИОТЕКА ────────────────────────────────────────────────────────────────

# Утверждённый снимок модели (baseline) — путь ВНУТРИ закреплённого дерева
# модели: раскладка 2.5.x, как его читают run-arch.js и verify-pin.js.
ARCH187_SNAPSHOT="governance/baseline/approved.json"

# arch187_scope <repo> — режим 187а применим к проекту <repo>?
# 0 — применим, 1 — не применим (проект не backend, пин не заведён, профиля нет).
arch187_scope() {
  ARCH187_SCOPE=0
  local repo="${1:-}" rid=""
  [ -n "$repo" ] && [ -d "$repo" ] || return 1
  [ -f "$repo/harness.project.json" ] || return 1
  rid="$(jq -r '.repoId // empty' "$repo/harness.project.json" 2>/dev/null || true)"
  [ "$rid" = "Complior-back" ] || return 1
  [ -f "$repo/architecture.lock.json" ] || return 1
  ARCH187_SCOPE=1
  return 0
}

# arch187_class <file> — класс предмета по самостоятельной строке «КЛАСС ЗАДАЧИ:».
# 0 — кодовый предмет (дверь вооружена); 2 — класс назван и он НЕ кодовый
# (дверь не вооружается: ARCH_187A_SKIP — не отказ); 1 — строки нет:
# именованный отказ ARCH_CLASS_MISSING (rc 1). Значение класса опознаётся по
# началу значения до разделителя (та же грамматика, что в make_task.sh).
arch187_class() {
  local file="${1:-}"
  ARCH187_REFUSAL=""
  ARCH187_RC=1
  [ -f "$file" ] || { ARCH187_REFUSAL="ARCH_CLASS_MISSING: контракт предмета не найден: $file"; return 1; }
  if ! grep -Eq '^[[:space:]]*КЛАСС ЗАДАЧИ:' "$file" 2>/dev/null; then
    ARCH187_REFUSAL="ARCH_CLASS_MISSING: в контракте предмета нет строки «КЛАСС ЗАДАЧИ:»"
    return 1
  fi
  if grep -Eq '^[[:space:]]*КЛАСС ЗАДАЧИ:[[:space:]]*(кодовый|КОДОВЫЙ)([^[:alnum:]_]|$)' "$file" 2>/dev/null; then
    return 0
  fi
  return 2
}

# arch187_lock_commit <repo> — значение .commit из lock (как есть; пусто — пина нет).
arch187_lock_commit() {
  [ -f "${1:-}/architecture.lock.json" ] || return 1
  jq -r '.commit // empty' "$1/architecture.lock.json" 2>/dev/null || true
}

# arch187_hex40 <значение> — ровно 40 строчных hex (символьный pin — не коммит).
arch187_hex40() {
  case "${1:-}" in
    ''|*[!0-9a-f]*) return 1 ;;
  esac
  [ "${#1}" -eq 40 ]
}

# arch187_intersects <список a> <список b> — есть ли общий элемент?
# Списки — через запятую (объединение компонентов ответа модели; id строки
# «АРХИТЕКТУРА:»). Порядок и повторы не важны.
arch187_intersects() {
  local a="${1:-}" b="${2:-}" x y rest
  while [ -n "$a" ]; do
    x="${a%%,*}"
    if [ "$a" = "$x" ]; then a=""; else a="${a#*,}"; fi
    [ -n "$x" ] || continue
    rest="$b"
    while [ -n "$rest" ]; do
      y="${rest%%,*}"
      if [ "$rest" = "$y" ]; then rest=""; else rest="${rest#*,}"; fi
      if [ "$y" = "$x" ]; then return 0; fi
    done
  done
  return 1
}

# arch187_snapshot_digest <repo> — digest утверждённого снимка из lock (167).
# Пусто — утверждённого снимка нет: сравнивать не с чем.
arch187_snapshot_digest() {
  [ -f "${1:-}/architecture.lock.json" ] || return 1
  jq -r '.snapshotDigest // empty' "${1}/architecture.lock.json" 2>/dev/null || true
}

# arch187_model_prepare <repo> — развернуть дерево закреплённого коммита.
# ARCH187_MODEL_DIR — каталог дерева; возврат 1 с ARCH187_REFUSAL и ARCH187_RC
# (1 — именованный отказ, 2 — нечем проверить).
arch187_model_prepare() {
  local repo="${1:-}" root pin tmp
  # Уже развёрнутое дерево той же модели — повторно не материализуем: один
  # разбор дерева и одна установка зависимостей на все вызовы (суд зон, затем
  # бриф).
  if [ -n "${ARCH187_MODEL_DIR:-}" ] && [ -d "$ARCH187_MODEL_DIR" ] \
     && [ -f "$ARCH187_MODEL_DIR/tooling/checks/cli.js" ]; then
    return 0
  fi
  ARCH187_MODEL_DIR=""
  # Прежнее развёрнутое дерево — в мусор: повторный вызов (суд зон, затем
  # бриф) не должен оставлять в /tmp копию модели.
  arch187_cleanup
  # Клон модели — только env ARCHITECTURE_ROOT (verify-pin клон проектного CI);
  # поле .clone из lock дверь НЕ читает.
  root="${ARCHITECTURE_ROOT:-}"
  if [ -z "$root" ]; then
    ARCH187_REFUSAL="ARCHITECTURE_NET: нет репозитория архитектуры ARCHITECTURE_ROOT"
    ARCH187_RC=1
    return 1
  fi
  if [ ! -d "$root" ]; then
    ARCH187_REFUSAL="ARCHITECTURE_NET: клон модели не найден: $root"
    ARCH187_RC=1
    return 1
  fi
  pin="$(arch187_lock_commit "$repo")"
  if [ -z "$pin" ]; then
    ARCH187_REFUSAL="ARCHITECTURE_NET: в architecture.lock.json нет закреплённого коммита"
    ARCH187_RC=1
    return 1
  fi
  if ! arch187_hex40 "$pin"; then
    ARCH187_REFUSAL="ARCHITECTURE_NET: lock не указывает на коммит архитектуры: $pin"
    ARCH187_RC=1
    return 1
  fi
  if ! git -C "$root" cat-file -e "${pin}^{commit}" 2>/dev/null; then
    ARCH187_REFUSAL="ARCH_PIN: коммит $pin не разрешается в клоне модели: $root"
    ARCH187_RC=1
    return 1
  fi
  tmp="$(mktemp -d 2>/dev/null || true)"
  if [ -z "$tmp" ] || [ ! -d "$tmp" ]; then
    ARCH187_REFUSAL="ARCH_PIN: временный каталог для дерева модели не создать"
    ARCH187_RC=2
    return 1
  fi
  if ! git -C "$root" archive "$pin" 2>/dev/null | tar -x -C "$tmp" 2>/dev/null; then
    rm -rf "$tmp"
    ARCH187_REFUSAL="ARCH_PIN: дерево закреплённого коммита $pin не развернуть"
    ARCH187_RC=2
    return 1
  fi
  if [ ! -f "$tmp/tooling/checks/cli.js" ]; then
    rm -rf "$tmp"
    ARCH187_REFUSAL="ARCH_PIN: в закреплённом дереве нет tooling/checks/cli.js"
    ARCH187_RC=2
    return 1
  fi
  if [ -L "$tmp/tooling/checks/cli.js" ]; then
    rm -rf "$tmp"
    ARCH187_REFUSAL="ARCH_PIN: tooling/checks/cli.js в закреплённом дереве — ссылка, а не файл"
    ARCH187_RC=2
    return 1
  fi
  # Зависимости закреплённого дерева: package-lock без node_modules → дверь
  # исполняет `npm ci --ignore-scripts` В ЭТОМ дереве (детерминирован
  # package-lock'ом, скрипты пакета не исполняются). Отказ npm — именованный
  # ARCH_DEPS rc 2: дверь без зависимостей отвечала бы «нечем проверить» под
  # видом зелёного результата.
  if [ -f "$tmp/package-lock.json" ] && [ ! -d "$tmp/node_modules" ]; then
    if ! command -v npm >/dev/null 2>&1; then
      rm -rf "$tmp"
      ARCH187_REFUSAL="ARCH_DEPS: зависимости модели недоступны (нет npm)"
      ARCH187_RC=2
      return 1
    fi
    if ! ( cd "$tmp" && npm ci --ignore-scripts >/dev/null 2>&1 ); then
      rm -rf "$tmp"
      ARCH187_REFUSAL="ARCH_DEPS: зависимости модели недоступны (npm ci --ignore-scripts)"
      ARCH187_RC=2
      return 1
    fi
  fi
  ARCH187_MODEL_DIR="$tmp"
  ARCH187_MODEL_TMP="$tmp"
  return 0
}

# arch187_cleanup — убрать развёрнутое дерево модели (вызывающий зовёт сам:
# ловушку в библиотеке ставить нельзя — она снесла бы ловушку вызывающего).
arch187_cleanup() {
  if [ -n "${ARCH187_MODEL_TMP:-}" ] && [ -d "$ARCH187_MODEL_TMP" ]; then
    rm -rf "$ARCH187_MODEL_TMP"
  fi
  ARCH187_MODEL_TMP=""
  ARCH187_MODEL_DIR=""
  return 0
}

# arch187_locate <path> — ответ ЗАКРЕПЛЁННОЙ модели о размещении пути.
#
# Ответ настоящего CLI — МНОГОСТРОЧНЫЙ JSON (scope/path/status/matches[]/
# components/implementationEvidence). Тело читается ЦЕЛИКОМ (первая строка
# JSON — не компонент), четыре класса ответа (контракт 187 v3, §Размещение
# путей):
#   placed     — status DECLARED, объединение matches[].components всех матчей
#                НЕПУСТО — компонентное размещение (ARCH187_LOCATE_COMPS);
#   empty      — status DECLARED, объединение ПУСТО — безкомпонентный модуль
#                (tests/**, worker/**): компонентной претензии нет;
#   unresolved — status UNRESOLVED, матчей НОЛЬ — ни один модуль не притязает
#                на префикс пути (артефакты репозитория);
#   ambiguous  — status UNRESOLVED, матчей НЕСКОЛЬКО — размещение неоднозначно.
# Однострочный ответ из одного идентификатора компонента (мир 170/187-1 до
# cutover) — единственный компонент (placed).
# Возврат: 0 — ответ разобран; 1 — ответ НЕ разбирается: ARCH187_REFUSAL=
# «ARCH_LOCATE_GRAMMAR: …», ARCH187_RC=2 (fail-closed: догадываться нельзя).
arch187_locate() {
  local path="${1:-}" out rc=0 body ans status count comps lines
  ARCH187_LOCATE_CLASS=""
  ARCH187_LOCATE_COMPS=""
  ARCH187_REFUSAL=""
  [ -n "${ARCH187_MODEL_DIR:-}" ] || { ARCH187_REFUSAL="ARCH_LOCATE_GRAMMAR: дерево модели не развёрнуто"; ARCH187_RC=2; return 1; }
  out="$(cd "$ARCH187_MODEL_DIR" && node tooling/checks/cli.js locate --path "$path" 2>/dev/null)" || rc=$?
  body="$(printf '%s' "$out" | tr -d '\r')"
  # Тело пустое: модель не разместила путь (мир 170 отвечает в stderr, rc≠0).
  if [ -z "$(printf '%s' "$body" | tr -d '[:space:]')" ]; then
    if [ "$rc" -eq 0 ]; then
      ARCH187_REFUSAL="ARCH_LOCATE_GRAMMAR: ответ locate не парсится как JSON ($path)"
      ARCH187_RC=2
      return 1
    fi
    ARCH187_LOCATE_CLASS="unplaced"
    return 0
  fi
  # Канон настоящего CLI: JSON-объект с массивом matches.
  ans="$(printf '%s' "$body" | jq -r 'if (type == "object") and ((.matches | type) == "array") then "ok" else "bad" end' 2>/dev/null)" || ans=""
  if [ "$ans" = "ok" ]; then
    status="$(printf '%s' "$body" | jq -r '(.status // "") | tostring | ascii_upcase' 2>/dev/null)"
    count="$(printf '%s' "$body" | jq -r '(.matches | length)' 2>/dev/null)"
    comps="$(printf '%s' "$body" | jq -r '[ (.matches[]?) | (.components? // []) | if type == "array" then .[] else empty end ] | unique | join(",")' 2>/dev/null)"
    case "$count" in ''|*[!0-9]*) count=0 ;; esac
    case "$status" in
      DECLARED)
        if [ -n "$comps" ]; then ARCH187_LOCATE_CLASS="placed"; else ARCH187_LOCATE_CLASS="empty"; fi
        ;;
      UNRESOLVED)
        if [ "$count" -eq 0 ]; then ARCH187_LOCATE_CLASS="unresolved"; else ARCH187_LOCATE_CLASS="ambiguous"; fi
        ;;
      *)
        # Статус не назван или незнаком — класс выводится из rc ответа модели
        # (декарено: rc 0 — DECLARED, rc≠0 — UNRESOLVED).
        if [ "$rc" -eq 0 ]; then
          if [ -n "$comps" ]; then ARCH187_LOCATE_CLASS="placed"; else ARCH187_LOCATE_CLASS="empty"; fi
        elif [ "$count" -eq 0 ]; then
          ARCH187_LOCATE_CLASS="unresolved"
        else
          ARCH187_LOCATE_CLASS="ambiguous"
        fi
        ;;
    esac
    ARCH187_LOCATE_COMPS="$comps"
    return 0
  fi
  # Не JSON: мир 170/187-1 до cutover отвечает однострочным идентификатором
  # компонента — принимаем его как единственный компонент.
  lines="$(printf '%s\n' "$body" | wc -l | tr -d '[:space:]')"
  if [ "$lines" = "1" ] && printf '%s' "$body" | grep -Eq '^[A-Za-z0-9_][A-Za-z0-9._-]*$'; then
    ARCH187_LOCATE_CLASS="placed"
    ARCH187_LOCATE_COMPS="$body"
    return 0
  fi
  # Тело не разбирается (обрыв, незакрытая скобка) — именованный отказ, а не
  # догадка и не сужение до иного имени отказа.
  ARCH187_REFUSAL="ARCH_LOCATE_GRAMMAR: ответ locate не парсится как JSON ($path)"
  ARCH187_RC=2
  return 1
}

# arch187_brief <component> <with_rules 0|1> — бриф компонента из
# закреплённого дерева. Бриф — ПАКЕТНЫМ скриптом дерева: `npm --prefix
# <дерево> run brief -- --compact [--with-rules] --component <id>` (грамматика
# 170 v2): прямой вызов `node cli.js brief` интерфейсом двери не является.
# 0 — бриф в stdout, 1 — модель брифа не отдала.
arch187_brief() {
  local comp="${1:-}" rules="${2:-0}" out rc=0
  [ -n "${ARCH187_MODEL_DIR:-}" ] || return 1
  if [ "$rules" = "1" ]; then
    out="$(cd "$ARCH187_MODEL_DIR" && npm --prefix "$ARCH187_MODEL_DIR" run brief -- --compact --with-rules --component "$comp" 2>/dev/null)" || rc=$?
  else
    out="$(cd "$ARCH187_MODEL_DIR" && npm --prefix "$ARCH187_MODEL_DIR" run brief -- --compact --component "$comp" 2>/dev/null)" || rc=$?
  fi
  [ "$rc" -eq 0 ] || return 1
  [ -n "$out" ] || return 1
  printf '%s\n' "$out"
  return 0
}

# arch187_model_check <repo> — `check --base` закреплённой модели против
# УТВЕРЖДЁННОГО снимка.
#
# Снимок — governance/baseline/approved.json внутри ЗАКРЕПЛЁННОГО дерева
# (раскладка 2.5.x модели, как её читают run-arch.js и verify-pin.js);
# его digest берётся из architecture.lock.json (snapshotDigest формата 167)
# СЛОВОМ: свой digest дверь НЕ считает. Иначе расхождение «утверждён снимок
# A, закреплён снимок B» не всплыло бы никогда — дверь подставила бы свой
# digest и зелёный свет был бы ложью (мутант check-digest-self-computed).
#
# 0 — зелено; 1 — ARCH_CHECK (красный вердикт модели);
# 2 — ARCH_NOT_EVALUATED (вердикта нет: оценивать нечем).
# Ошибка ВХОДА в инструмент (неизвестная опция, потерянное значение,
# незапустившийся node) — это НЕ красная модель: такой отказ не выдаётся за
# ARCH_CHECK, иначе дверь объявила бы «модель нашла проблемы» там, где модель
# просто не поняла вызов.
arch187_model_check() {
  local repo="${1:-}" digest out err errf rc=0
  [ -n "${ARCH187_MODEL_DIR:-}" ] || { ARCH187_REFUSAL="ARCH_PIN: дерево модели не развёрнуто"; ARCH187_RC=1; return 2; }
  digest="$(arch187_snapshot_digest "$repo")"
  if [ -z "$digest" ]; then
    ARCH187_REFUSAL="ARCH_NOT_EVALUATED: в architecture.lock.json нет snapshotDigest утверждённого снимка"
    ARCH187_RC=1
    return 2
  fi
  errf="$(mktemp 2>/dev/null || true)"
  if [ -z "$errf" ] || [ ! -f "$errf" ]; then errf=""; fi
  out="$(cd "$ARCH187_MODEL_DIR" && node tooling/checks/cli.js check --base "$ARCH187_SNAPSHOT" --base-digest "$digest" 2>"${errf:-/dev/null}")" || rc=$?
  err=""
  if [ -n "$errf" ]; then
    err="$(cat "$errf" 2>/dev/null || true)"
    rm -f "$errf"
  fi
  # Вход инструмента не принят — вердикта о коде нет.
  if printf '%s' "$out" | grep -Eq 'ARCHITECTURE_TOOL_INPUT|MISSING_OPTION_VALUE|UNSUPPORTED_OPTION'; then
    ARCH187_REFUSAL="ARCH_NOT_EVALUATED: check --base отверг вход инструмента (rc=$rc)"
    ARCH187_RC=1
    return 2
  fi
  # Инструмент не запустился (нет node, нет модуля, нет файла) — вердикта нет.
  if [ -z "$out" ] && printf '%s' "$err" | grep -Eqi 'Cannot find module|MODULE_NOT_FOUND|ENOENT|no such file|command not found'; then
    ARCH187_REFUSAL="ARCH_NOT_EVALUATED: инструмент check --base не отработал (rc=$rc): $(printf '%s' "$err" | head -n 1)"
    ARCH187_RC=1
    return 2
  fi
  if [ "$rc" = "2" ]; then
    ARCH187_REFUSAL="ARCH_NOT_EVALUATED: check --base модели не вынес вердикта (rc=$rc)"
    ARCH187_RC=1
    return 2
  fi
  if [ "$rc" -ne 0 ]; then
    ARCH187_REFUSAL="ARCH_CHECK: check --base модели красный (rc=$rc)"
    ARCH187_RC=1
    return 1
  fi
  return 0
}

# arch187_line <file> — строка `АРХИТЕКТУРА:` текста.
# ARCH187_LEVEL, ARCH187_COMPONENTS; возврат 1 с ARCH187_REFUSAL.
arch187_line() {
  local file="${1:-}" raw line rest lvl ids id seen=""
  ARCH187_LEVEL=""
  ARCH187_COMPONENTS=""
  ARCH187_REFUSAL=""
  ARCH187_RC=1
  raw="$(grep -m1 '^[[:space:]]*АРХИТЕКТУРА:' "$file" 2>/dev/null || true)"
  if [ -z "$raw" ]; then
    ARCH187_REFUSAL="ARCH_LINE_MISSING: в тексте нет самостоятельной строки «АРХИТЕКТУРА:»"
    return 1
  fi
  line="$(printf '%s' "$raw" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  rest="${line#АРХИТЕКТУРА:}"
  rest="$(printf '%s' "$rest" | tr '\t' ' ' | sed -e 's/^ *//' -e 's/ *$//' -e 's/  */ /g')"
  lvl="${rest%% *}"
  case "$lvl" in
    L1|L2|L3) ;;
    *)
      ARCH187_REFUSAL="ARCH_LINE_MISSING: грамматика строки «АРХИТЕКТУРА:» — уровень L1|L2|L3 и список id: $line"
      return 1
      ;;
  esac
  if [ "$rest" = "$lvl" ]; then
    ids=""
  else
    ids="${rest#"$lvl "}"
  fi
  if [ -z "$ids" ]; then
    ARCH187_REFUSAL="ARCH_LINE_MISSING: пустой список компонентов в строке «АРХИТЕКТУРА:»"
    return 1
  fi
  local rest2="$ids"
  while [ -n "$rest2" ]; do
    id="${rest2%%,*}"
    if [ "$rest2" = "$id" ]; then rest2=""; else rest2="${rest2#*,}"; fi
    case "$id" in
      ''|[!A-Za-z0-9_]*|*[^A-Za-z0-9._-]*|*..*)
        ARCH187_REFUSAL="ARCH_LINE_MISSING: неконформный id компонента: $id"
        return 1
        ;;
    esac
    case " $seen " in
      *" $id "*) ARCH187_REFUSAL="ARCH_LINE_MISSING: дубль id компонента: $id"; return 1 ;;
    esac
    seen="$seen$id "
  done
  ARCH187_LEVEL="$lvl"
  ARCH187_COMPONENTS="$ids"
  if [ "$lvl" = "L3" ]; then
    ARCH187_REFUSAL="ARCH_OWNER: уровень L3 требует решения владельца: $line"
    return 1
  fi
  return 0
}

# arch187_zone_paths <file> — продуктовые пути `ЗОНА implementer:` (по одному).
arch187_zone_paths() {
  sed -n 's/^ЗОНА implementer:[[:space:]]*//p' "$1" 2>/dev/null | tr ' \t' '\n\n' | sed '/^$/d'
}

# arch187_zones <file> <repo> — размещение продуктовых путей в модели.
# Размещение считается ПО ОТВЕТУ МОДЕЛИ (arch187_locate), а не видом пути:
#   placed     — объединение components пересекается с компонентами строки
#                «АРХИТЕКТУРА:», иначе ARCH_ZONE; граница компонента —
#                пересечение компонентов каталога пути с компонентами пути
#                (каталог относится к тому же компоненту, что и сам путь);
#   empty      — безкомпонентный модуль: компонентной претензии нет (конформ);
#   unresolved — ни один модуль не притязает на путь (конформ);
#   ambiguous  — несколько претендентов: PATH_WITHOUT_COMPONENT;
#   unplaced   — модель не разместила путь: PATH_WITHOUT_COMPONENT.
# Существование файла в продукте НЕ участвует: дисковая эвристика снята —
# вид пути не классификатор.
arch187_zones() {
  local file="${1:-}" repo="${2:-}" p dir comp fcomps dcomps
  ARCH187_REFUSAL=""
  ARCH187_RC=1
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    # Продуктовый путь — относительный и без выхода из дерева: значение из
    # текста контракта не должно вести за пределы репозитория (Н-85).
    case "$p" in
      /*) ARCH187_REFUSAL="PATH_WITHOUT_COMPONENT: путь $p не относительный"; return 1 ;;
    esac
    case "/$p/" in
      */../*) ARCH187_REFUSAL="PATH_WITHOUT_COMPONENT: путь $p выходит за пределы дерева"; return 1 ;;
    esac
    arch187_locate "$p" || return 1
    fcomps="$ARCH187_LOCATE_COMPS"
    case "$ARCH187_LOCATE_CLASS" in
      placed)
        comp="${fcomps%%,*}"
        # Граница компонента: каталог пути и сам путь должны относиться к
        # одному компоненту (пересечение множеств компонентов). Если модель не
        # называет компонентов каталога (безкомпонентный модуль или ноль
        # матчей), противоречия нет — проверка не применяется.
        case "$p" in
          */) dir="$p" ;;
          *)  dir="$(dirname "$p")/" ;;
        esac
        arch187_locate "$dir" || return 1
        dcomps="$ARCH187_LOCATE_COMPS"
        if [ "$ARCH187_LOCATE_CLASS" = "placed" ] && ! arch187_intersects "$dcomps" "$fcomps"; then
          ARCH187_REFUSAL="ARCH_ZONE: путь $p вне границы компонента $comp (каталог относится к ${dcomps%%,*})"
          return 1
        fi
        # Компонент, названный строкой «АРХИТЕКТУРА:», должен быть среди
        # компонентов размещения: сверяются ВСЕ компоненты строки (список
        # режется по запятым), любой компонент объединения — свойство
        # множества.
        if ! arch187_intersects "$fcomps" "$ARCH187_COMPONENTS"; then
          ARCH187_REFUSAL="ARCH_ZONE: путь $p отнесён моделью к компоненту $comp, а строка «АРХИТЕКТУРА:» называет $ARCH187_COMPONENTS"
          return 1
        fi
        ;;
      empty|unresolved)
        ;;   # компонентной претензии нет — конформ
      ambiguous)
        ARCH187_REFUSAL="PATH_WITHOUT_COMPONENT: путь $p не размещён однозначно в закреплённой модели (несколько претендентов)"
        return 1
        ;;
      *)
        ARCH187_REFUSAL="PATH_WITHOUT_COMPONENT: путь $p не размещён в закреплённой модели"
        return 1
        ;;
    esac
  done < <(arch187_zone_paths "$file")
  return 0
}

# arch187_draft_token <строка> — 0, если в строке есть токен «draft» (любой
# регистр) на границе слова. Граница — как у \w в re: соседний символ не
# буква/цифра/подчёркивание; кириллица — буква («идdraftи» — НЕ токен),
# а «(DRAFT)» и «schema.draft» — токены. Локаль C.UTF-8 — чтобы класс
# [[:alnum:]] знал не-ASCII буквы (под C кириллица не буква, и «идdraftи»
# сочлось бы за токен).
arch187_draft_token() {
  printf '%s' "${1:-}" | LC_ALL=C.UTF-8 grep -Eq \
    '(^|[^[:alnum:]_])[Dd][Rr][Aa][Ff][Tt]([^[:alnum:]_]|$)' 2>/dev/null
}

# arch187_operations <file> — операции предмета: схемы входа/выхода есть, DRAFT
# нет. Строка операции — «ОПЕРАЦИЯ: <id>; вход <схема>; выход <схема>».
arch187_operations() {
  local file="${1:-}" line id schema found=0
  ARCH187_REFUSAL=""
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    found=1
    id="${line#*ОПЕРАЦИЯ:}"
    id="$(printf '%s' "$id" | sed -e 's/^[[:space:]]*//' -e 's/;.*$//' -e 's/[[:space:]]*$//')"
    # DRAFT — токен в ЛЮБОМ месте строки операции: в id («identity.draft»),
    # в пометке («(DRAFT)») и в схеме («schema.draft»). Токен, а не подстрока:
    # «идdraftи» и «draft_v2» — не DRAFT.
    if arch187_draft_token "$line"; then
      ARCH187_REFUSAL="ARCH_DRAFT: операция $id помечена DRAFT"
      return 1
    fi
    schema="$(printf '%s' "$line" | sed -n 's/.*вход[[:space:]]\{1,\}\([^;]*\).*/\1/p' | sed -e 's/[[:space:]]*$//')"
    if [ -z "$schema" ]; then
      ARCH187_REFUSAL="ARCH_DRAFT: у операции $id нет схемы входа"
      return 1
    fi
    case "$schema" in
      -|--|—|?|TBD|tbd|DRAFT|draft|нет|n/a|N/A)
        ARCH187_REFUSAL="ARCH_DRAFT: схема входа операции $id не задана"
        return 1
        ;;
    esac
    schema="$(printf '%s' "$line" | sed -n 's/.*выход[[:space:]]\{1,\}\([^;]*\).*/\1/p' | sed -e 's/[[:space:]]*$//')"
    if [ -z "$schema" ]; then
      ARCH187_REFUSAL="ARCH_DRAFT: у операции $id нет схемы выхода"
      return 1
    fi
    case "$schema" in
      -|--|—|?|TBD|tbd|DRAFT|draft|нет|n/a|N/A)
        ARCH187_REFUSAL="ARCH_DRAFT: схема выхода операции $id не задана"
        return 1
        ;;
    esac
  done < <(grep '^[[:space:]]*ОПЕРАЦИЯ:' "$file" 2>/dev/null || true)
  if [ "$found" = "0" ]; then
    # Операция не объявлена — отказа нет: обязательность «ОПЕРАЦИЯ: у каждого
    # кодового» снята (контракт 187 v2, С3). Судятся только ОБЪЯВЛЕННЫЕ строки.
    return 0
  fi
  return 0
}

# arch187_check_text <file> <mode> <repo> — строка архитектуры, зоны и (для
# контракта) операция. mode: task | contract.
arch187_check_text() {
  local file="${1:-}" mode="${2:-task}" repo="${3:-}"
  ARCH187_REFUSAL=""
  ARCH187_RC=1
  arch187_line "$file" || return 1
  arch187_model_prepare "$repo" || return 1
  arch187_zones "$file" "$repo" || return 1
  if [ "$mode" = "contract" ]; then
    arch187_operations "$file" || return 1
  fi
  return 0
}

# ── ИМПОРТ КАК БИБЛИОТЕКА ─────────────────────────────────────────────────────
# Когда скрипт импортируется (`ARCH187_LIB=1 source check_architecture_contract.sh`),
# определены функции выше — здесь только ранний возврат. Иначе — основной код
# двери. Возврат стоит ДО `set -euo pipefail`: под `set -e` любой rc 1 функции
# библиотеки валил бы импортирующий скрипт без объявленной причины.
if [ "${ARCH187_LIB:-}" = "1" ]; then
  [ -n "${SELF_DIR:-}" ] || SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  return 0 2>/dev/null || exit 0
fi

set -uo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

repo=""
contract=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) repo="${2:-}"; shift 2 ;;
    --) shift; break ;;
    -*) printf 'NOT_IMPLEMENTED: неизвестный флаг: %s\n' "$1" >&2; exit 2 ;;
    *) contract="${1:-}"; shift ;;
  esac
done

if [ -z "$repo" ]; then
  printf 'NOT_IMPLEMENTED: не задан --repo\n' >&2
  exit 2
fi
repo="$(cd "$repo" 2>/dev/null && pwd -P)" || {
  printf 'NOT_IMPLEMENTED: корень проекта не найден: %s\n' "$repo" >&2
  exit 2
}

# Профиль проекта читается jq; без него режим не определить — «нечем проверить»
# (fail-closed), а не «не применимо».
if [ -f "$repo/harness.project.json" ] && ! command -v jq >/dev/null 2>&1; then
  printf 'ARCH_PIN: jq недоступен — эффективный repoId проекта не прочитан\n' >&2
  exit 2
fi

# Не применимо — не отказ: харнесс, mob и документальные предметы нового
# отказа не получают.
if ! arch187_scope "$repo"; then
  printf 'ARCH_187A_SKIP: проект не в режиме 187а (repoId/пин модели)\n'
  exit 0
fi

if [ -z "$contract" ]; then
  printf 'NOT_IMPLEMENTED: не назван контракт\n' >&2
  exit 2
fi
contract_file="$repo/$contract"
if [ ! -f "$contract_file" ]; then
  printf 'NOT_IMPLEMENTED: контракт не найден: %s\n' "$contract" >&2
  exit 2
fi
# Класс предмета: самостоятельная строка «КЛАСС ЗАДАЧИ:» обязательна (все
# четыре двери) — её отсутствие именованный отказ ARCH_CLASS_MISSING;
# не-кодовое значение дверь не вооружает (ARCH_187A_SKIP — не отказ).
_a187_class=0
arch187_class "$contract_file" || _a187_class=$?
if [ "$_a187_class" = "1" ]; then
  printf '%s\n' "$ARCH187_REFUSAL" >&2
  exit 1
fi
if [ "$_a187_class" != "0" ]; then
  printf 'ARCH_187A_SKIP: предмет не кодовый\n'
  exit 0
fi

trap 'arch187_cleanup' EXIT

arch187_check_text "$contract_file" contract "$repo" || {
  printf '%s\n' "$ARCH187_REFUSAL" >&2
  exit "${ARCH187_RC:-1}"
}

arch187_model_prepare "$repo" || {
  printf '%s\n' "$ARCH187_REFUSAL" >&2
  exit "${ARCH187_RC:-2}"
}
rc=0
arch187_model_check "$repo" || rc=$?
if [ "$rc" -ne 0 ]; then
  printf '%s\n' "$ARCH187_REFUSAL" >&2
  exit "${ARCH187_RC:-1}"
fi
printf 'ARCH_187A_OK: архитектура сходится с закреплённой моделью\n'
exit 0
