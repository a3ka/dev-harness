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
#   коммит      → .commit в architecture.lock.json — ПОЛНЫЙ 40-hex SHA в
#                  канонической форме git (строчные [0-9a-f]{40}). Символьный
#                  pin (`HEAD`, имя ветки) и сокращённый НЕ принимаются:
#                  разрешимость git не заменяет грамматику, «сначала
#                  разрешить HEAD в SHA» — не выполнение неизменного lock
#                  (после перемещения HEAD клона источником остался бы тот же
#                  полный SHA). Неконформный pin — именованный отказ ARCH_PIN
#                  («закреплённый pin не полный 40-hex SHA: <pin>»),
#                  неразрешимый полный SHA — ARCH_PIN («коммит <pin> не
#                  разрешается в клоне модели»); обе ветви — rc 1, пустой
#                  stdout, бриф не зовётся;
#   чтение     → materialize дерева ЭТОГО коммита (`git archive`) и вызовы
#                `node tooling/checks/cli.js <brief|locate|check|snapshot>` ВНУТРИ
#                этого дерева. Ни HEAD клона, ни локальная `architecture/` продукта
#                источником не являются (две разные версии модели в одном
#                пакете не смешиваются).
#
# ЧТО СУДИТСЯ (порядок шва: строка → pin → членство → зоны):
#   * строка `АРХИТЕКТУРА: L1|L2|L3 <id,…>` — самостоятельная строка; список
#     непустой, без дублей и прозы (id: [A-Za-z0-9_][A-Za-z0-9._-]*). Пустая или
#     отсутствующая строка — ARCH_LINE_MISSING; L3 — отказ до решения владельца
#     (ARCH_OWNER);
#   * грамматика закреплённого pin — сразу ПОСЛЕ строки «АРХИТЕКТУРА:» и ДО
#     зон (arch187_line → arch187_model_prepare → arch187_element_ids →
#     arch187_zones), и ДО вопроса о флаге `--arch-component`: неконформный
#     либо неразрешимый pin — отказ ARCH_PIN (см. «ЗАКРЕПЛЁННАЯ МОДЕЛЬ»), а не
#     ARCH_COMPONENT_NET;
#   * зависимости выгрузки пина (контракт 203) — в arch187_model_prepare, ДО
#     первого вызова CLI: выгрузка с `package-lock.json` требует, чтобы он
#     ПОБАЙТОВО совпадал с `package-lock.json` установленного клона (включая
#     его отсутствие — `cmp -s` даёт rc≠0), в клоне был `node_modules`, и
#     дверь подключает его выгрузке симлинком на абсолютный путь; манифест с
#     runtime-зависимостями без lock — тот же отказ. Расхождение — именованный
#     отказ ARCH_BRIEF_DEPS с требованием `npm ci на закреплённом пине` (сеть
#     дверь не трогает); дерево без lock и без runtime-зависимостей
#     исполняется как прежде;
#   * членство id строки «АРХИТЕКТУРА:» в модели ПО ПИНУ (контракт 203) —
#     краткий `brief --compact --component <id>` из ВЫГРУЗКИ пина: rc 0 —
#     элемент известен; ответ модели с кодом UNKNOWN_ARCHITECTURE_ELEMENT —
#     именованный отказ с САМИМ id. Гейт стоит ДО зон и ДО вопроса о флаге
#     `--arch-component`; ответ модели без кода членства гейт не сужает.
#   * продуктовые пути `ЗОНА implementer:` — `locate --path` закреплённой
#     модели. Ответ модели — многострочный JSON: разбирается ЦЕЛИКОМ, а
#     компоненты — объединение matches[].components всех матчей; класс ответа
#     задаёт поле status, а НЕ код возврата модели (нет status/незнакомый
#     status/не-JSON — именованный отказ ARCH_LOCATE_GRAMMAR, зелёным такой
#     ответ стать не может). Неразмещённый путь — PATH_WITHOUT_COMPONENT;
#     размещённый в ИНОМ компоненте (или вне границы компонента) — ARCH_ZONE;
#     каталог-контейнер БЕЗ компонентов — не претензия (модель размещает
#     компоненты ПО ФАЙЛАМ: путь судится СВОИМ размещением); путь модуля с
#     признаком outsideProductRuntime (признак — ИЗ ВЫГРУЗКИ `snapshot`
#     закреплённой модели: матч locate его НЕ несёт) и путь вне всех областей
#     модели (UNRESOLVED, матчей ноль) — не судятся («вне модели: <путь>»);
#   * операция предмета — со схемами входа/выхода и не DRAFT, иначе
#     ARCH_DRAFT (судится только текст контракта: make_task судит задание);
#   * причина отказа брифа — из ОТВЕТА МОДЕЛИ целиком (контракт 203): stderr
#     модели разбирается ЦЕЛИКОМ; JSON-объект с непустым `findings[0].code`
#     даёт строку причины `<code>: <message>` (CR/LF/TAB нормализуются в
#     пробел, одна строка, без обрезки — id в конце сообщения не срезается);
#     вне грамматики — прежняя первая непустая строка stderr, пустой stderr —
#     прежняя константа. Форма строки `ARCH_BRIEF_STDERR: <причина>` и строка
#     `ОТКАЗ: ARCH_BRIEF_OTKAZ: <id> (закреплённая модель не отдала бриф)`
#     побайтово прежние (потребитель — замороженная батарея 187
#     brief_stderr.py);
#   * `check --base` модели против УТВЕРЖДЁННОГО снимка (путь снимка и его
#     digest — по формату 167, из architecture.lock.json) — по rc-грамматике
#     инструмента: rc 1 — ARCH_CHECK; rc 2 — ARCH_NOT_EVALUATED; rc 0 при
#     requiredModelGate PASS — зелено и при общем status NOT_EVALUATED из-за
#     непустого unresolved latency.* (сообщение печатается, отказом не
#     становится); requiredModelGate != PASS в теле (даже при rc 0) —
#     ARCH_NOT_EVALUATED: rc одному не доверяют.
#
# ВОЗВРАТЫ ДВЕРИ: 0 — зелено (или «187а не применима»); 1 — именованный
# отказ (маркер в stderr, первая строка); 2 — нечем проверить (нет клона, пина
# или контракта) либо вердикта модели нет (ARCH_NOT_EVALUATED).
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
# arch187_profile <repo>: validate before reading the repo-only policy.
arch187_profile() {
  ARCH187_PRODUCT_REPO=""
  ARCH187_REFUSAL=""
  local repo="$1" self value
  [ -f "$repo/harness.project.json" ] || return 0
  self="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if ! HARNESS_PROJECT_LAYER_ROOT="${HARNESS_PROJECT_LAYER_ROOT:-$repo}" \
      bash "$self/profile_resolver.sh" --repo "$repo" >/dev/null; then
    ARCH187_REFUSAL="ARCH_PROFILE: профиль проекта не прошёл resolver"
    return 2
  fi
  # shellcheck disable=SC1091
  PROFILE_RESOLVER_LIB=1 . "$self/profile_resolver.sh"
  value="$(profile_get "$repo" hooks.archBrief false)"
  :
  ARCH187_PRODUCT_REPO="$value"
  return 0
}

arch187_scope() {
  ARCH187_SCOPE=0
  local repo="${1:-}"
  [ -n "$repo" ] && [ -d "$repo" ] || return 1
  arch187_profile "$repo" || return 2
  [ -n "$ARCH187_PRODUCT_REPO" ] || return 1
  [ -f "$repo/architecture.lock.json" ] || return 1
  ARCH187_SCOPE=1
  return 0
}

# Грамматика класса предмета — ОДНА на все двери (архитектура, заморозка,
# критика, done, пак задания). Маркер «КЛАСС ЗАДАЧИ:» объявляет класс либо
# самостоятельной строкой (документная форма: «КЛАСС ЗАДАЧИ: кодовый.»), либо
# ВНУТРИ строки после границы предложения — инлайн-форма 180 («Идентификатор:
# `id/CONTRACT/777`. КЛАСС ЗАДАЧИ: кодовый (реализация).»). Граница перед
# маркером — знак препинания или начало строки: упоминание класса в прозе
# («требование КЛАСС ЗАДАЧИ: кодовый соблюдено») объявлением класса НЕ является.
#
# ЗНАЧЕНИЕ класса — ровно «кодовый» или «КОДОВЫЙ»: регистр НЕ сворачивается
# (кириллица под C регистра не имеет), после значения — разделитель (точка,
# «;», скобка, конец строки). Граница значения прежняя: разделителем служит
# любой знак, кроме буквы/цифры/подчёркивания. Всё иное («документальный»,
# «смешанный», …) — не кодовый предмет.
ARCH187_CLASS_RE='(^|[[:punct:]])[[:space:]]*КЛАСС ЗАДАЧИ:[[:space:]]*(кодовый|КОДОВЫЙ)([^[:alnum:]_]|$)'

# arch187_code_subject <file|-> — предмет кодовый? («-» — класс читается из
# stdin: байты контракта без временного файла).
arch187_code_subject() {
  local src="${1:-}"
  [ -n "$src" ] || return 1
  if [ "$src" = "-" ]; then
    # Без -q grep читает весь stdin: ранний выход рвал бы producer в pipefail.
    grep -E "$ARCH187_CLASS_RE" - >/dev/null 2>/dev/null
  else
    [ -f "$src" ] || return 1
    grep -Eq "$ARCH187_CLASS_RE" "$src" 2>/dev/null
  fi
}

# arch187_pin <repo> — закреплённый коммит модели (пусто — пина нет).
arch187_pin() {
  [ -f "$1/architecture.lock.json" ] || return 1
  jq -r '.commit // empty' "$1/architecture.lock.json" 2>/dev/null || true
}

# arch187_pin_full_sha <pin> — значение закреплённого pin конформен грамматике
# контракта 187 (v3, обязательство 1 арбитража 170-1): ПОЛНЫЙ 40-hex SHA в
# канонической форме git (строчные [0-9a-f]{40}).
#
# Символьный pin (`HEAD`, имя ветки) и сокращённый (12 hex) НЕ принимаются:
# разрешимость git (`cat-file -e '<pin>^{commit}'`) НЕ заменяет грамматику —
# «сначала разрешить HEAD в SHA» не является выполнением неизменного lock
# (после перемещения HEAD клона источником остался бы тот же полный SHA).
# Проверка посимвольная и НЕ зависит от локали (набор символов задан
# перечислением, а не диапазоном).
arch187_pin_full_sha() {
  local pin="${1:-}" i
  [ "${#pin}" -eq 40 ] || return 1
  for (( i = 0; i < 40; i++ )); do
    case "${pin:i:1}" in
      0|1|2|3|4|5|6|7|8|9|a|b|c|d|e|f) ;;
      *) return 1 ;;
    esac
  done
  return 0
}

# arch187_snapshot_digest <repo> — digest утверждённого снимка из lock (167).
# Пусто — утверждённого снимка нет: сравнивать не с чем.
arch187_snapshot_digest() {
  [ -f "${1:-}/architecture.lock.json" ] || return 1
  jq -r '.snapshotDigest // empty' "${1}/architecture.lock.json" 2>/dev/null || true
}

# arch187_model_prepare <repo> — развернуть дерево закреплённого коммита.
# ARCH187_MODEL_DIR — каталог дерева; возврат 1 с ARCH187_REFUSAL.
arch187_model_prepare() {
  local repo="${1:-}" root pin tmp
  ARCH187_MODEL_DIR=""
  # Прежнее развёрнутое дерево — в мусор: повторный вызов (суд зон, затем
  # бриф) не должен оставлять в /tmp копию модели.
  arch187_cleanup
  # Грамматика закреплённого pin (контракт 187 v3) — ПЕРВЫЙ отказ модели:
  # значение `.commit` обязано быть ПОЛНЫМ 40-hex SHA в канонической форме
  # git. Символьный pin и сокращённый обслуживать НЕЛЬЗЯ: разрешимость git
  # не заменяет грамматику (см. arch187_pin_full_sha). Это свойство самого
  # lock — судится ДО вопроса о клоне модели и ДО вопроса о флаге.
  pin="$(arch187_pin "$repo")"
  if [ -z "$pin" ]; then
    ARCH187_REFUSAL="ARCH_PIN: в architecture.lock.json нет закреплённого коммита"
    return 1
  fi
  if ! arch187_pin_full_sha "$pin"; then
    ARCH187_REFUSAL="ARCH_PIN: закреплённый pin не полный 40-hex SHA: $pin"
    return 1
  fi
  root="${ARCHITECTURE_ROOT:-}"
  if [ -z "$root" ] && [ -f "$repo/architecture.lock.json" ]; then
    root="$(jq -r '.clone // empty' "$repo/architecture.lock.json" 2>/dev/null || true)"
  fi
  if [ -z "$root" ]; then
    ARCH187_REFUSAL="ARCH_PIN: закреплённый клон модели не задан (ARCHITECTURE_ROOT)"
    return 1
  fi
  if [ ! -d "$root" ]; then
    ARCH187_REFUSAL="ARCH_PIN: клон модели не найден: $root"
    return 1
  fi
  if ! git -C "$root" cat-file -e "${pin}^{commit}" 2>/dev/null; then
    ARCH187_REFUSAL="ARCH_PIN: коммит $pin не разрешается в клоне модели: $root"
    return 1
  fi
  tmp="$(mktemp -d 2>/dev/null || true)"
  if [ -z "$tmp" ] || [ ! -d "$tmp" ]; then
    ARCH187_REFUSAL="ARCH_PIN: временный каталог для дерева модели не создать"
    return 1
  fi
  if ! git -C "$root" archive "$pin" 2>/dev/null | tar -x -C "$tmp" 2>/dev/null; then
    rm -rf "$tmp"
    ARCH187_REFUSAL="ARCH_PIN: дерево закреплённого коммита $pin не развернуть"
    return 1
  fi
  if [ ! -f "$tmp/tooling/checks/cli.js" ]; then
    rm -rf "$tmp"
    ARCH187_REFUSAL="ARCH_PIN: в закреплённом дереве нет tooling/checks/cli.js"
    return 1
  fi
  if [ -L "$tmp/tooling/checks/cli.js" ]; then
    rm -rf "$tmp"
    ARCH187_REFUSAL="ARCH_PIN: tooling/checks/cli.js в закреплённом дереве — ссылка, а не файл"
    return 1
  fi
  # КОНТРАКТ 203: зависимости выгрузки закреплённого пина. `git archive` несёт
  # исходники БЕЗ node_modules, а CLI пина может требовать модулей; дверь
  # подключает их САМА — симлинком на абсолютный путь node_modules установленного
  # клона, но только если package-lock.json выгрузки ПОБАЙТОВО равен lock'у
  # клона: иначе в одном пакете смешаны два разных дерева зависимостей.
  # Расхождение (включая отсутствие lock'а в клоне — `cmp -s` даёт rc≠0),
  # отсутствие node_modules в клоне и манифест с runtime-зависимостями без
  # lock — именованный отказ ARCH_BRIEF_DEPS с требованием `npm ci на
  # закреплённом пине`; сеть дверь не трогает. Отказ ДО первого вызова CLI:
  # выгрузка удаляется, донор не тронут (симлинк снимается вместе с выгрузкой).
  if [ -f "$tmp/package-lock.json" ]; then
    if ! cmp -s "$tmp/package-lock.json" "$root/package-lock.json"; then
      rm -rf "$tmp"
      ARCH187_REFUSAL="ARCH_BRIEF_DEPS: package-lock.json закреплённого пина не совпадает с установленным клоном модели: $root; npm ci на закреплённом пине"
      return 1
    fi
    if [ ! -d "$root/node_modules" ]; then
      rm -rf "$tmp"
      ARCH187_REFUSAL="ARCH_BRIEF_DEPS: в установленном клоне модели нет node_modules: $root; npm ci на закреплённом пине"
      return 1
    fi
    if ! ln -s "$(cd "$root/node_modules" && pwd -P)" "$tmp/node_modules" 2>/dev/null; then
      rm -rf "$tmp"
      ARCH187_REFUSAL="ARCH_BRIEF_DEPS: node_modules выгрузки не подключить: $root; npm ci на закреплённом пине"
      return 1
    fi
  elif [ -f "$tmp/package.json" ] \
    && jq -e '(.dependencies // {}) | length > 0' "$tmp/package.json" >/dev/null 2>&1; then
    rm -rf "$tmp"
    ARCH187_REFUSAL="ARCH_BRIEF_DEPS: у закреплённого пина есть runtime-зависимости без package-lock.json; npm ci на закреплённом пине"
    return 1
  fi
  ARCH187_MODEL_DIR="$tmp"
  ARCH187_MODEL_TMP="$tmp"
  return 0
}

# arch187_snapshot_drop — убрать выгрузку snapshot и сбросить её кэш.
# Вызывающий зовёт сам (ловушку в библиотеке ставить нельзя); ловушка вызывающего
# (arch187_cleanup) — backstop.
arch187_snapshot_drop() {
  if [ -n "${ARCH187_SNAPSHOT_TMP:-}" ] && [ -f "$ARCH187_SNAPSHOT_TMP" ]; then
    rm -f "$ARCH187_SNAPSHOT_TMP"
  fi
  ARCH187_SNAPSHOT_TMP=""
  ARCH187_SNAPSHOT_FILE=""
  ARCH187_SNAPSHOT_STATE=""
  ARCH187_SNAPSHOT_REFUSAL=""
  return 0
}

# arch187_cleanup — убрать развёрнутое дерево модели и выгрузку snapshot
# (вызывающий зовёт сам: ловушку в библиотеке ставить нельзя — она снесла бы
# ловушку вызывающего).
arch187_cleanup() {
  if [ -n "${ARCH187_MODEL_TMP:-}" ] && [ -d "$ARCH187_MODEL_TMP" ]; then
    rm -rf "$ARCH187_MODEL_TMP"
  fi
  ARCH187_MODEL_TMP=""
  ARCH187_MODEL_DIR=""
  # Выгрузка snapshot — временный файл ВНЕ дерева модели; её кэш живёт вместе
  # с деревом (новое дерево — новая выгрузка).
  arch187_snapshot_drop
  return 0
}

# arch187_snapshot_export — выгрузка закреплённой модели (`snapshot --out`).
#
# Канал ПРИЗНАКА непродуктовости — тот же закреплённый CLI, что locate и check
# (тот же корень модели, тот же вызов node tooling/checks/cli.js): матч locate
# признака НЕ несёт (форма настоящего CLI — {module, components,
# specification, explicit, matched}), признак outsideProductRuntime лежит в
# ОПИСАНИИ модуля и выгружается ОТДЕЛЬНО. Выгрузка запрашивается ОДИН раз на
# прогон двери и кэшируется (файл — ARCH187_SNAPSHOT_FILE); путей с пустыми
# components нет — выгрузка не запрашивается вовсе.
#
# Файл выгрузки — mktemp ВНЕ дерева продукта и ВНЕ дерева модели; после
# суждения он убирается (arch187_snapshot_drop), ловушка вызывающего
# (arch187_cleanup) — backstop.
#
# 0 — выгрузка прочитана; 1 — выгрузки нет: отказ ARCH_NOT_EVALUATED с rc 2
# двери (нечем проверить — не зелёный и не пропуск).
arch187_snapshot_export() {
  local tmp rc=0
  case "${ARCH187_SNAPSHOT_STATE:-}" in
    ok) return 0 ;;
    failed)
      ARCH187_REFUSAL="$ARCH187_SNAPSHOT_REFUSAL"
      ARCH187_REFUSAL_RC=2
      return 1
      ;;
  esac
  if [ -z "${ARCH187_MODEL_DIR:-}" ]; then
    ARCH187_SNAPSHOT_STATE="failed"
    ARCH187_SNAPSHOT_REFUSAL="ARCH_NOT_EVALUATED: дерево модели не развёрнуто — выгрузку snapshot взять негде"
    ARCH187_REFUSAL="$ARCH187_SNAPSHOT_REFUSAL"
    ARCH187_REFUSAL_RC=2
    return 1
  fi
  tmp="$(mktemp 2>/dev/null || true)"
  if [ -z "$tmp" ] || [ ! -f "$tmp" ]; then
    ARCH187_SNAPSHOT_STATE="failed"
    ARCH187_SNAPSHOT_REFUSAL="ARCH_NOT_EVALUATED: временный файл выгрузки snapshot не создать"
    ARCH187_REFUSAL="$ARCH187_SNAPSHOT_REFUSAL"
    ARCH187_REFUSAL_RC=2
    return 1
  fi
  ARCH187_SNAPSHOT_TMP="$tmp"
  (cd "$ARCH187_MODEL_DIR" && node tooling/checks/cli.js snapshot --out "$tmp") >/dev/null 2>&1 || rc=$?
  if [ "$rc" -ne 0 ]; then
    ARCH187_SNAPSHOT_STATE="failed"
    ARCH187_SNAPSHOT_REFUSAL="ARCH_NOT_EVALUATED: snapshot закреплённой модели не выгрузился (rc=$rc)"
    ARCH187_REFUSAL="$ARCH187_SNAPSHOT_REFUSAL"
    ARCH187_REFUSAL_RC=2
    return 1
  fi
  # Выгрузка обязана быть разбираемой: без массива модулей признак не взять.
  if ! jq -e '(.model.logicalModules | type) == "array"' "$tmp" >/dev/null 2>&1; then
    ARCH187_SNAPSHOT_STATE="failed"
    ARCH187_SNAPSHOT_REFUSAL="ARCH_NOT_EVALUATED: выгрузка snapshot не разобрана (нет model.logicalModules)"
    ARCH187_REFUSAL="$ARCH187_SNAPSHOT_REFUSAL"
    ARCH187_REFUSAL_RC=2
    return 1
  fi
  ARCH187_SNAPSHOT_FILE="$tmp"
  ARCH187_SNAPSHOT_STATE="ok"
  return 0
}

# arch187_module_trait <module-id> — признак outsideProductRuntime модуля из
# выгрузки snapshot: true | false | missing (модуля нет в выгрузке) | absent
# (модуль есть, признака нет). Модуля нет или признака нет — вердикта нет:
# догадкой (по префиксу пути или по id модуля) дверь не заменяет.
arch187_module_trait() {
  local m="${1:-}"
  [ -n "${ARCH187_SNAPSHOT_FILE:-}" ] || { printf 'missing\n'; return 1; }
  jq -r --arg m "$m" '
    [ (.model.logicalModules // [])[]? | select(.id == $m) ]
    | if (length == 0) then "missing"
      else (.[0].outsideProductRuntime | if type == "boolean" then tostring else "absent" end)
      end
  ' "$ARCH187_SNAPSHOT_FILE" 2>/dev/null || printf 'missing\n'
}

# arch187_locate <path> [признак 0|1] — класс размещения пути по ответу модели.
#
# Второй аргумент — нужен ли признак непродуктовости: 1 (по умолчанию) — да;
# 0 — нет (каталог-граница: там признак не влияет на решение — и каталог-
# контейнер без компонентов, и модуль вне продуктового runtime одинаково не
# претензия, — и выгрузка snapshot ради каталога не запрашивается).
#
# Ответ модели — МНОГОСТРОЧНЫЙ JSON (scope/path/status/matches[]/components/
# implementationEvidence); первая строка ответа («{») компонентом НЕ является,
# тело разбирается ЦЕЛИКОМ.
#
# КЛАСС ОТВЕТА ЗАДАЁТ ПОЛЕ status, а НЕ код возврата модели (угадывать по rc
# нельзя — отказ не выдаётся за «модель права»):
#   DECLARED   — модель притязает на путь; компоненты — объединение
#                matches[].components ВСЕХ матчей (первый компонент из
#                множества молча НЕ выбирается). Набор ПУСТ — решение самой
#                модели: модуль матча может быть модулем-КОНТЕЙНЕРОМ
#                (компоненты размещаются по ФАЙЛАМ внутри) либо модулем ВНЕ
#                продуктового runtime — признак outsideProductRuntime МОДУЛЯ
#                матча из выгрузки snapshot (не префикс пути);
#   UNRESOLVED — ни один модуль не притязает: матчей НОЛЬ — путь вне всех
#                областей модели; матчи НЕПУСТЫ — область модели без
#                компонента (несколько претендентов).
# Ответ без status, с незнакомым status, не-JSON или не-объект с массивом
# matches — ВНЕ грамматики: именованный отказ ARCH_LOCATE_GRAMMAR (fail-closed:
# зелёным такой ответ стать не может).
#
# Возврат: 0 — путь размещён с компонентами (класс placed), набор — в
# ARCH187_LOCATE_COMPS; 1 — прочие классы названы в ARCH187_LOCATE_KIND
# (unresolved-none | unresolved-area | outside | componentless |
# not-evaluated); отказ в ARCH187_REFUSAL — у грамматики, componentless и
# not-evaluated (ARCH_NOT_EVALUATED — вердикта модели нет, rc 2 двери).
#
# Результат — переменной, а НЕ stdout: отказ назван в ARCH187_REFUSAL, а
# вызов в подshell (подстановка `$(...)`) этот отказ потерял бы — дверь решила
# бы, что модель просто не разместила путь, и потеряла бы имя отказа.
arch187_locate() {
  local path="${1:-}" need="${2:-1}" out shape status comps c rest module trait
  ARCH187_REFUSAL=""
  ARCH187_REFUSAL_RC="1"
  ARCH187_LOCATE_COMPS=""
  ARCH187_LOCATE_KIND=""
  [ -n "${ARCH187_MODEL_DIR:-}" ] || return 1
  out="$(cd "$ARCH187_MODEL_DIR" && node tooling/checks/cli.js locate --path "$path" 2>/dev/null)" || true
  # Пустой ответ — инструмент не отработал: вердикта о размещении нет.
  if [ -z "$out" ]; then
    ARCH187_REFUSAL="ARCH_LOCATE_GRAMMAR: модель не ответила на locate (пустой ответ): $path"
    return 1
  fi
  # Канон ответа — JSON-объект с массивом matches.
  shape="$(printf '%s' "$out" | jq -r 'if (type == "object") and ((.matches | type) == "array") then "ok" else "bad" end' 2>/dev/null)" || shape=""
  if [ "$shape" != "ok" ]; then
    ARCH187_REFUSAL="ARCH_LOCATE_GRAMMAR: ответ locate не разобран как JSON-объект с массивом matches: $path"
    return 1
  fi
  status="$(printf '%s' "$out" | jq -r '(.status // "") | tostring' 2>/dev/null)" || status=""
  case "$status" in
    DECLARED) ;;
    UNRESOLVED)
      # Матчей НОЛЬ — путь ВНЕ всех областей модели; матчи НЕПУСТЫ —
      # область модели без компонента (несколько претендентов). Класс —
      # из ответа модели, не из rc и не из диска.
      if [ "$(printf '%s' "$out" | jq -r '.matches | length' 2>/dev/null)" = "0" ]; then
        ARCH187_LOCATE_KIND="unresolved-none"
      else
        ARCH187_LOCATE_KIND="unresolved-area"
      fi
      return 1
      ;;
    '')
      ARCH187_REFUSAL="ARCH_LOCATE_GRAMMAR: в ответе locate нет поля status: $path"
      return 1
      ;;
    *)
      ARCH187_REFUSAL="ARCH_LOCATE_GRAMMAR: незнакомое значение status в ответе locate: $status ($path)"
      return 1
      ;;
  esac
  # Компоненты — объединение matches[].components всех матчей (не первый из
  # множества). Компонент не-строкой — ответ вне грамматики.
  comps="$(printf '%s' "$out" | jq -r '
      [ (.matches[]? | (.components? // []) | if type == "array" then .[] else empty end ) ]
      | if all(.[]; type == "string")
        then (unique | join(" "))
        else "non..string"
        end' 2>/dev/null)" || comps=""
  # Грамматика id — та же, что у строки «АРХИТЕКТУРА:».
  rest="$comps"
  while [ -n "$rest" ]; do
    c="${rest%% *}"
    if [ "$rest" = "$c" ]; then rest=""; else rest="${rest#* }"; fi
    case "$c" in
      ''|[!A-Za-z0-9_]*|*[^A-Za-z0-9._-]*|*..*)
        ARCH187_REFUSAL="ARCH_LOCATE_GRAMMAR: неконформный id компонента в ответе locate: $c"
        return 1
        ;;
    esac
  done
  if [ -z "$comps" ]; then
    # DECLARED с ПУСТЫМИ components — решение самой модели. Непродуктовость —
    # ПРИЗНАК МОДЕЛИ (outsideProductRuntime МОДУЛЯ матча), и берётся он из
    # ВЫГРУЗКИ snapshot закреплённой модели: матч locate признака НЕ несёт
    # (форма настоящего CLI — {module, components, specification, explicit,
    # matched}), признак лежит в описании модуля. Такой путь не судится.
    # ЯВНЫЙ false — прежний отказ: компонентной претензии нет, но и границы
    # компонента нет. Признака (или самой выгрузки) нет — честный
    # ARCH_NOT_EVALUATED (rc 2 двери): догадкой дверь не заменяет.
    if [ "$need" != "0" ]; then
      module="$(printf '%s' "$out" | jq -r '(.matches[0].module // "") | tostring' 2>/dev/null)" || module=""
      if [ -n "$module" ]; then
        if ! arch187_snapshot_export; then
          ARCH187_LOCATE_KIND="not-evaluated"
          return 1
        fi
        trait="$(arch187_module_trait "$module")"
        case "$trait" in
          true)
            ARCH187_LOCATE_KIND="outside"
            return 1
            ;;
          false)
            ARCH187_LOCATE_KIND="componentless"
            ARCH187_REFUSAL="PATH_WITHOUT_COMPONENT: путь $path размещён моделью, но компонент не назван"
            return 1
            ;;
          absent)
            ARCH187_LOCATE_KIND="not-evaluated"
            ARCH187_REFUSAL="ARCH_NOT_EVALUATED: признак outsideProductRuntime модуля $module не выгружен"
            ARCH187_REFUSAL_RC=2
            return 1
            ;;
          *)
            ARCH187_LOCATE_KIND="not-evaluated"
            ARCH187_REFUSAL="ARCH_NOT_EVALUATED: модуль матча $module отсутствует в выгрузке snapshot"
            ARCH187_REFUSAL_RC=2
            return 1
            ;;
        esac
      fi
    fi
    ARCH187_LOCATE_KIND="componentless"
    ARCH187_REFUSAL="PATH_WITHOUT_COMPONENT: путь $path размещён моделью, но компонент не назван"
    return 1
  fi
  ARCH187_LOCATE_KIND="placed"
  ARCH187_LOCATE_COMPS="$comps"
  return 0
}

# arch187_brief <component> <with_rules 0|1> — бриф компонента из
# закреплённого дерева. 0 — бриф в stdout, 1 — модель брифа не отдала.
#
# STDERR МОДЕЛИ НЕ ГЛОТАЕТСЯ: он снимается во временный файл (mktemp), и
# файл удаляется ВСЕГДА — и при отказе, и при успехе. Отказ (rc≠0 ИЛИ пустой
# stdout брифа) печатает в stderr двери РОВНО одну строку
# `ARCH_BRIEF_STDERR: <первая непустая строка stderr модели>`; пустой stderr
# модели даёт `ARCH_BRIEF_STDERR: (stderr модели пуст)`. Прежний возврат 1 и
# прежний именованный отказ вызывающего (ARCH_BRIEF_OTKAZ) сохраняются.
# При успехе stdout брифа идёт побайтно как прежде, а stderr двери пуст:
# шум модели при rc 0 не печатается.
#
# ФАЙЛ ЗАХВАТА НЕ ПЕРЕЖИВАЕТ СИГНАЛ ГРУППЕ ПРОЦЕССОВ. Вызов брифа идёт в $(…)
# у вызывающего, а его EXIT-ловушка этот файл не знает: при TERM/INT,
# доставленных ВСЕЙ группе, вызывающий умирает — и файл остался бы лежать в
# TMPDIR. Поэтому тело функции — ПОДОБОЛОЧКА с ловушками: EXIT убирает РОВНО
# свой файл, TERM/INT завершают подоболочку с 128+N, и EXIT-ловушка убирает
# файл. Ловушка INT НЕ снимает EXIT-ловушку (иначе файл пережил бы INT) и
# трогает только свой файл — чужие файлы TMPDIR не удаляются.
arch187_brief() (
  local comp="${1:-}" rules="${2:-0}" out rc=0 err errf first="" rest line reason=""
  [ -n "${ARCH187_MODEL_DIR:-}" ] || return 1
  errf=""
  trap 'if [ -n "${errf:-}" ]; then rm -f "$errf"; fi' EXIT
  trap 'exit 143' TERM
  trap 'exit 130' INT
  errf="$(mktemp 2>/dev/null || true)"
  if [ -z "$errf" ] || [ ! -f "$errf" ]; then errf=""; fi
  if [ "$rules" = "1" ]; then
    out="$(cd "$ARCH187_MODEL_DIR" && node tooling/checks/cli.js brief --compact --with-rules --component "$comp" 2>"${errf:-/dev/null}")" || rc=$?
  else
    out="$(cd "$ARCH187_MODEL_DIR" && node tooling/checks/cli.js brief --compact --component "$comp" 2>"${errf:-/dev/null}")" || rc=$?
  fi
  err=""
  if [ -n "$errf" ]; then
    err="$(cat "$errf" 2>/dev/null || true)"
    rm -f "$errf"
  fi
  if [ "$rc" -ne 0 ] || [ -z "$out" ]; then
    # Первая НЕПУСТАЯ строка stderr модели: пустая строка причиной не является.
    rest="$err"
    while [ -n "$rest" ]; do
      line="${rest%%$'\n'*}"
      if [ "$line" = "$rest" ]; then rest=""; else rest="${rest#*$'\n'}"; fi
      if [ -n "$line" ]; then first="$line"; break; fi
    done
    # КОНТРАКТ 203: причина отказа — ИЗ ОТВЕТА МОДЕЛИ. Настоящий CLI при отказе
    # печатает stderr МНОГОСТРОЧНЫМ JSON-отчётом
    # {status,scope,findings:[{code,message}]}; его первая строка «{» причиной
    # не является, и код с сообщением теряться не должны. Ответ разбирается
    # ЦЕЛИКОМ: JSON-объект с непустым findings[0].code даёт строку причины
    # «<code>: <message>» (CR/LF/TAB нормализуются в пробел, одна строка, без
    # обрезки — id в конце сообщения не срезается). Вне этой грамматики —
    # прежняя первая непустая строка stderr; пустой stderr — прежняя константа.
    reason=""
    reason="$(printf '%s' "$err" | jq -r 'try (if (type == "object") and ((.findings[0].code | type) == "string") and ((.findings[0].code | length) > 0) then (.findings[0].code) + (if ((.findings[0].message | type) == "string") and ((.findings[0].message | length) > 0) then ": " + (.findings[0].message) else "" end) else "" end) catch ""' 2>/dev/null)" || reason=""
    reason="$(printf '%s' "$reason" | tr '\r\n\t' '   ' | sed -e 's/  */ /g' -e 's/^ //' -e 's/ $//')"
    if [ -n "$reason" ]; then
      first="$reason"
    else
      [ -n "$first" ] || first="(stderr модели пуст)"
    fi
    printf 'ARCH_BRIEF_STDERR: %s\n' "$first" >&2
    return 1
  fi
  printf '%s\n' "$out"
  return 0
)

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
# 0 — зелено (rc 0 инструмента при requiredModelGate PASS: общий status
#     NOT_EVALUATED из-за непустого unresolved latency.* конформностью не
#     правит — сообщение печатается, отказом не становится);
# 1 — ARCH_CHECK (красный вердикт модели, rc 1);
# 2 — ARCH_NOT_EVALUATED (вердикта нет: rc 2 инструмента, либо
#     requiredModelGate != PASS в теле даже при rc 0 — rc одному не доверяют).
# rc функции вызывающий доводит до exit-кода двери. Ошибка ВХОДА в
# инструмент (неизвестная опция, потерянное значение, незапустившийся node) —
# это НЕ красная модель: такой отказ не выдаётся за ARCH_CHECK, иначе дверь
# объявила бы «модель нашла проблемы» там, где модель просто не поняла вызов.
arch187_model_check() {
  local repo="${1:-}" digest out err errf rc=0 gate unresolved
  [ -n "${ARCH187_MODEL_DIR:-}" ] || { ARCH187_REFUSAL="ARCH_PIN: дерево модели не развёрнуто"; return 2; }
  digest="$(arch187_snapshot_digest "$repo")"
  if [ -z "$digest" ]; then
    ARCH187_REFUSAL="ARCH_NOT_EVALUATED: в architecture.lock.json нет snapshotDigest утверждённого снимка"
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
    return 2
  fi
  # Инструмент не запустился (нет node, нет модуля, нет файла) — вердикта нет.
  if [ -z "$out" ] && printf '%s' "$err" | grep -Eqi 'Cannot find module|MODULE_NOT_FOUND|ENOENT|no such file|command not found'; then
    ARCH187_REFUSAL="ARCH_NOT_EVALUATED: инструмент check --base не отработал (rc=$rc): $(printf '%s' "$err" | head -n 1)"
    return 2
  fi
  # rc 1 — красный вердикт модели (requiredModelGate FAIL у настоящего CLI):
  # защита «gate != PASS» красный вердикт модели не съедает.
  if [ "$rc" -eq 1 ]; then
    ARCH187_REFUSAL="ARCH_CHECK: check --base модели красный (rc=$rc)"
    return 1
  fi
  # rc 2 — вердикта нет: оценивать нечем.
  if [ "$rc" -eq 2 ]; then
    ARCH187_REFUSAL="ARCH_NOT_EVALUATED: check --base модели не вынес вердикта (rc=$rc)"
    return 2
  fi
  # requiredModelGate != PASS в теле ответа — вердикта о конформности нет
  # ДАЖЕ при rc 0 инструмента (такого тела настоящий CLI не излучает; rc
  # одному не доверяют — подстрочный поиск NOT_EVALUATED тут ни при чём).
  gate="$(printf '%s' "$out" | jq -r 'if (type == "object") and ((.requiredModelGate | type) == "string") then .requiredModelGate else "" end' 2>/dev/null)" || gate=""
  if [ -n "$gate" ] && [ "$gate" != "PASS" ]; then
    ARCH187_REFUSAL="ARCH_NOT_EVALUATED: requiredModelGate не PASS ($gate, rc=$rc)"
    return 2
  fi
  if [ "$rc" -ne 0 ]; then
    # прочий ненулевой rc без конформного гейта — красный вердикт, как прежде.
    ARCH187_REFUSAL="ARCH_CHECK: check --base модели красный (rc=$rc)"
    return 1
  fi
  # rc 0 при requiredModelGate PASS — зелено и тогда, когда общий status
  # NOT_EVALUATED из-за НЕПУСТОГО unresolved latency.* (budgetMs null, живая
  # форма пина): сообщение печатается, отказом не становится.
  unresolved="$(printf '%s' "$out" | jq -r 'if (type == "object") and ((.unresolved | type) == "array") then (.unresolved | join(", ")) else "" end' 2>/dev/null)" || unresolved=""
  if [ -n "$unresolved" ]; then
    printf '  ok   check --base: rc 0, requiredModelGate PASS; вне вердикта модели (unresolved): %s\n' "$unresolved"
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

# arch187_element_ids — членство id строки «АРХИТЕКТУРА:» в модели ПО ПИНУ
# (контракт 203). Отвечает САМА модель: краткий `brief --compact --component
# <id>` для каждого id из ВЫГРУЗКИ закреплённого пина (stdout не нужен,
# stderr несёт вердикт модели и в вывод двери не печатается). rc 0 — элемент
# модели известен; ответ модели с кодом UNKNOWN_ARCHITECTURE_ELEMENT — её
# положительный вердикт «не элемент», и тогда именованный отказ с САМИМ id.
# Прочие исходы (иной код, пустой ответ, недоступный CLI) вердикта о членстве
# НЕ несут: недоступная модель отказала именованно ещё в arch187_model_prepare
# (ARCH_PIN/ARCH_BRIEF_DEPS), а неизвестный id флага `--arch-component`
# отказывает кодом модели в строке ARCH_BRIEF_STDERR (arch187_brief).
# Список id — разбор строки «АРХИТЕКТУРА:» (ARCH187_COMPONENTS).
arch187_element_ids() {
  local rest="${ARCH187_COMPONENTS:-}" id err="" rc=0 code=""
  [ -n "$rest" ] || return 0
  [ -n "${ARCH187_MODEL_DIR:-}" ] || return 0
  while [ -n "$rest" ]; do
    id="${rest%%,*}"
    if [ "$rest" = "$id" ]; then rest=""; else rest="${rest#*,}"; fi
    rc=0
    err="$(cd "$ARCH187_MODEL_DIR" && node tooling/checks/cli.js brief --compact --component "$id" 2>&1 >/dev/null)" || rc=$?
    code=""
    if [ -n "$err" ]; then
      code="$(printf '%s' "$err" | jq -r 'try (if (type == "object") then (.findings[0].code // "") else "" end) catch ""' 2>/dev/null)" || code=""
    fi
    if [ "$rc" -ne 0 ] && [ "$code" = "UNKNOWN_ARCHITECTURE_ELEMENT" ]; then
      ARCH187_REFUSAL="UNKNOWN_ARCHITECTURE_ELEMENT: $id"
      ARCH187_REFUSAL_RC="1"
      return 1
    fi
  done
  return 0
}

# arch187_zone_paths <file> — продуктовые пути `ЗОНА implementer:` (по одному).
arch187_zone_paths() {
  sed -n 's/^ЗОНА implementer:[[:space:]]*//p' "$1" 2>/dev/null | tr ' \t' '\n\n' | sed '/^$/d'
}

# arch187_component_set <список id через запятую> — нормализованный набор
# компонентов (пробел-separated): список строки «АРХИТЕКТУРА:» сравнивается с
# НАБОРОМ компонентов размещения, а не с одним литералом.
arch187_component_set() {
  printf '%s' "${1:-}" | tr ',' ' ' | tr -s ' ' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

# arch187_zones <file> <repo> — размещение продуктовых путей в модели.
# Размещение считается по ОТВЕТУ МОДЕЛИ (locate --path): путь судится СВОИМ
# размещением, а граница компонента — по НЕПУСТОМУ набору каталога (каталог-
# контейнер БЕЗ компонентов не претензия: модель размещает компоненты по
# ФАЙЛАМ). Не судятся (не отказ): путь модуля ВНЕ продуктового runtime
# (признак outsideProductRuntime модуля матча — из выгрузки snapshot) и путь
# ВНЕ всех областей модели (UNRESOLVED, матчей ноль — строка «вне модели:
# <путь>» в stderr, диск не участвует). Отказы прежние: component-less
# DECLARED и UNRESOLVED с непустыми матчами (область модели без компонента) —
# PATH_WITHOUT_COMPONENT; чужой компонент и выход за границу компонента
# каталога — ARCH_ZONE; ответ модели вне грамматики — именованный отказ
# ARCH_LOCATE_GRAMMAR; признака непродуктовости взять негде (выгрузки нет или
# модуля в ней нет) — ARCH_NOT_EVALUATED с rc 2 двери.
arch187_zones() {
  local file="${1:-}" repo="${2:-}" p dir fcomps dcomps c rest declared
  ARCH187_REFUSAL=""
  ARCH187_REFUSAL_RC="1"
  declared="$(arch187_component_set "$ARCH187_COMPONENTS")"
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
    case "$p" in
      */) dir="$p" ;;
      *)  dir="$(dirname "$p")/" ;;
    esac
    # Каталог пути — только граница компонента по НЕПУСТОМУ набору:
    # контейнер без компонентов (компоненты по ФАЙЛАМ), внепродуктовый и
    # беспретензионный каталог отказом не становятся; ответ вне грамматики —
    # именованный отказ, а не догадка.
    dcomps=""
    # Каталог — только граница компонента: признак непродуктовости там на
    # решение НЕ влияет (и контейнер без компонентов, и модуль вне runtime —
    # одинаково не претензия), поэтому выгрузка snapshot ради каталога не
    # запрашивается.
    if arch187_locate "$dir" 0; then
      dcomps="$ARCH187_LOCATE_COMPS"
    else
      case "${ARCH187_LOCATE_KIND:-}" in
        outside|componentless|unresolved-none|unresolved-area)
          ARCH187_REFUSAL=""
          ARCH187_REFUSAL_RC="1"
          ;;
        *)
          [ -n "$ARCH187_REFUSAL" ] || ARCH187_REFUSAL="ARCH_PIN: locate каталога не состоялся: $dir"
          return 1
          ;;
      esac
    fi
    # Сам путь — СВОИМ размещением (frozen 187/1), не набором каталога и не
    # диском.
    if ! arch187_locate "$p" 1; then
      case "${ARCH187_LOCATE_KIND:-}" in
        # Признак МОДЕЛИ (из выгрузки snapshot): модуль матча вне продуктового
        # runtime — не судим.
        outside) continue ;;
        # Вне всех областей модели (матчей ноль): суждение — только там,
        # где модель ПРИТЯЗАЕТ на путь; строка в stderr, отказом не стало.
        unresolved-none)
          printf 'вне модели: %s\n' "$p" >&2
          continue
          ;;
        # Область модели без компонента (несколько претендентов) — прежний
        # отказ.
        unresolved-area)
          ARCH187_REFUSAL="PATH_WITHOUT_COMPONENT: путь $p не размещён однозначно в закреплённой модели (несколько претендентов)"
          ARCH187_REFUSAL_RC="1"
          return 1
          ;;
        # DECLARED без компонентов и без признака непродуктовости — отказ
        # уже назван locate («компонент не назван»).
        componentless) return 1 ;;
        *)
          [ -n "$ARCH187_REFUSAL" ] || ARCH187_REFUSAL="ARCH_PIN: locate пути не состоялся: $p"
          return 1
          ;;
      esac
    fi
    fcomps="$ARCH187_LOCATE_COMPS"
    # Граница компонента: каталог с ДРУГИМ непустым набором — выход за
    # границу; пустой набор каталога — не претензия.
    if [ -n "$dcomps" ] && [ "$dcomps" != "$fcomps" ]; then
      ARCH187_REFUSAL="ARCH_ZONE: путь $p вне границы компонента $fcomps (каталог относится к $dcomps)"
      ARCH187_REFUSAL_RC="1"
      return 1
    fi
    # Каждый компонент размещения должен быть назван строкой «АРХИТЕКТУРА:»:
    # первый из множества молча НЕ выбирается, чужой компонент не проходит.
    rest="$fcomps"
    while [ -n "$rest" ]; do
      c="${rest%% *}"
      if [ "$rest" = "$c" ]; then rest=""; else rest="${rest#* }"; fi
      case " $declared " in
        *" $c "*)
          ;;
        *)
          ARCH187_REFUSAL="ARCH_ZONE: путь $p отнесён моделью к компоненту $c, а строка «АРХИТЕКТУРА:» называет $ARCH187_COMPONENTS"
          ARCH187_REFUSAL_RC="1"
          return 1
          ;;
      esac
    done
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
    ARCH187_REFUSAL="ARCH_DRAFT: предмет не объявляет операцию со схемами входа/выхода"
    return 1
  fi
  return 0
}

# arch187_check_text <file> <mode> <repo> — строка архитектуры, зоны и (для
# контракта) операция. mode: task | contract.
arch187_check_text() {
  local file="${1:-}" mode="${2:-task}" repo="${3:-}"
  ARCH187_REFUSAL=""
  ARCH187_REFUSAL_RC="1"
  arch187_line "$file" || return 1
  arch187_model_prepare "$repo" || return 1
  # КОНТРАКТ 203: членство id строки «АРХИТЕКТУРА:» в модели ПО ПИНУ — ДО зон
  # и ДО вопроса о флаге `--arch-component`.
  arch187_element_ids || { arch187_snapshot_drop; return 1; }
  # Выгрузка snapshot — временный файл: после суждения она не нужна (убирается
  # тут, а ловушка вызывающего — backstop).
  arch187_zones "$file" "$repo" || { arch187_snapshot_drop; return 1; }
  if [ "$mode" = "contract" ]; then
    arch187_operations "$file" || { arch187_snapshot_drop; return 1; }
  fi
  arch187_snapshot_drop
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
model_only=0
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) repo="${2:-}"; shift 2 ;;
    --model-only) model_only=1; shift ;;
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
_scope_rc=0
arch187_scope "$repo" || _scope_rc=$?
if [ "$_scope_rc" -gt 1 ]; then
  printf '%s\n' "$ARCH187_REFUSAL" >&2
  exit 1
fi
if [ "$_scope_rc" = 1 ]; then
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
if ! arch187_code_subject "$contract_file"; then
  printf 'ARCH_187A_SKIP: предмет не кодовый\n'
  exit 0
fi

trap 'arch187_cleanup' EXIT

if [ "$model_only" = "0" ]; then
  arch187_check_text "$contract_file" contract "$repo" || {
    printf '%s\n' "$ARCH187_REFUSAL" >&2
    # rc двери — по КЛАССУ отказа: ARCH_NOT_EVALUATED — вердикта модели нет
    # (rc 2, как у check-канала), прочие именованные отказы — rc 1.
    exit "${ARCH187_REFUSAL_RC:-1}"
  }
fi

arch187_model_prepare "$repo" || {
  printf '%s\n' "$ARCH187_REFUSAL" >&2
  exit 2
}
rc=0
arch187_model_check "$repo" || rc=$?
if [ "$rc" -ne 0 ]; then
  printf '%s\n' "$ARCH187_REFUSAL" >&2
  # rc arch187_model_check доводится до exit-кода двери: 1 — именованный
  # отказ, 2 — ARCH_NOT_EVALUATED (вердикта модели нет).
  exit "$rc"
fi
printf 'ARCH_187A_OK: архитектура сходится с закреплённой моделью\n'
exit 0
