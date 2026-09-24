#!/usr/bin/env bash
# precision-гейт (контракт 043, Н-113/Н-115) — пре-фриз чек трёх независимых свойств
# черновика КОНТРАКТА, каждое исторически ловилось только ПОСЛЕ заморозки (v+1 ценой
# подписи владельца — конкретика в NABLIUDENIA.md Н-113/Н-115, HANDOFF чекпойнт #16):
#
#   (а) ЗОНА-дельта черновика (dry-run union: zones_load с черновиком минус без него)
#       не пересекает union живых заморозок ЧУЖИМ автором под ДРУГИМ NNN без явного
#       объявления ПЕРЕСЕЧЕНИЕ в тексте самого черновика (правило 7 AGENTS.md —
#       неразобранное объявление отказывает с названным местом и выходом).
#       Б1 fix: на пути может быть НЕСКОЛЬКО чужих NNN — каждое требует ОТДЕЛЬНОЕ
#       объявление ПЕРЕСЕЧЕНИЕ, иначе блокер с именованным первым необъявленным;
#   (б) КАЖДЫЙ НОВЫЙ (отсутствовавший на HEAD тега минта id/CONTRACT/<NNN>) case-файл
#       ЗАТРОНУТОЙ семьи (fixtures/check_<key>/, объявленной в ЗОНА черновика)
#       структурно заявляет полярность (basename red_*/green_*), барьер семьи
#       вызван ЖИВЬЁМ (внешний НЕЗАПИСЫВАЕМЫЙ case-файлом оракул — /proc/<pid>/cmdline-
#       опрос ИЗ gate-процесса; trace-fd в BASH_XTRACEFD ОТСУТСТВУЕТ — case не может
#       подделать трассу через >&$BASH_XTRACEFD, как и не может изменить своё
#       `case $-` для дифференциального поведения под xtrace — SHELLOPTS=xtrace
#       НЕ передаётся; Б3 fix: отдельный ПРЯМОЙ (не-трейсовый) запуск case и ЕГО
#       собственный rc обязателен зелёным отдельно от трейсового прогона), и
#       прямая (не-трейсовая) самопроверка case-файла зелена; rc=0 ОБЯЗАТЕЛЕН
#       для файлов, НЕ заявленных черновиком как «Красное сейчас»/«до реализации»
#       — для явно заявленных как ожидаемо красные rc≠0 допустим (проектная
#       конвенция «архитектор сдаёт red-тест ДО реализации», прецеденты 025/032);
#       защита Б2/Б3 (живой вызов барьера) остаётся активной в обоих случаях;
#   (в) дерево черновика паритетно CI — verify_ci_parity.sh (контракт 020), уже
#       полный и дешёвый механизм, просто не вызывавшийся на freeze-хуке (Б4 fix:
#       freeze_contract.sh ВЫЗЫВАЕТ этот гейт ПЕРЕД записью тега, как требует §Инварианты п.7).
#
# Норма 041 (гигиена парсящих гардов) самоприменена: задача (а) вводит и парсит
# НОВОЕ структурное поле ПЕРЕСЕЧЕНИЕ, встречающееся в contracts/043-*.md — этом
# самом контракте (см. его «## Модель угроз» и self-application §Приёмка);
# грамматика — единственный источник тот контракт, реализация несёт фразы
# ПОБАЙТОВО.
#
# Контракт API:
#   bash scripts/check_precision_gate.sh <корень> <отн-путь-контракта>
#   rc 0 — все три задачи зелёные, последняя строка stdout «OK» (канон 008);
#   rc 1 — отказ, ИМЕНОВАННАЯ причина первой красной (порядок исполнения — а → б →
#          в: задача (а) — зона-коллизия, ядро предмета — идёт первой; задача (б)
#          — живая полярность case-файлов — растёт линейно с числом case-файлов
#          затронутых семей (владелец: «цена растёт с числом case-файлов — назови
#          это честно»), исполняется в середине; задача (в) — паритет CI —
#          дешевле всего (1.574с на здоровом HEAD), идёт последней);
#   rc 2 — нечем проверить (нет git/контракта/NNN-грамматики/реестра/тега минта,
#          когда нужен задаче б).
#
# НЕ БАРЬЕР: классификация verify_antiplacebo.sh §1 area-scan — семья
# fixtures/check_precision_gate/ называет файлы `red_*`/`green_*` по грамматике
# ЭТОГО ЖЕ контракта (задача б выше — красные/зелёные basename-полярности), а
# не `case_*.sh` — конверсия в case_*-семью не выполнена (прецедент
# drill_path_guard.sh/drill_exit_marker.sh: «red_* вне case_*-глоба раннера»,
# «конверсия — пачка ARCHITECT после land»). Верификация — прямой прогон
# fixtures/_krasnye_043.sh (агрегатор всех сценариев Р1-РN) и self-application
# green_09 на РЕАЛЬНОМ contracts/043-*.md. Реальный вызов гейта — freeze_contract.sh
# (Вариант Б) и обязательная bash-команда критика (Вариант В), не shard
# verify_antiplacebo (решение владельца, grilling agent://FrontierPrecisionGate).
set -uo pipefail
export PATH=/usr/bin:/bin

die()  { printf 'precision-гейт 043: %s\n' "$*" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: precision-гейт 043: %s\n' "$*" >&2; exit 2; }

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$SELF_DIR/lib_registry.sh"
# shellcheck disable=SC1091
. "$SELF_DIR/lib_zones.sh"

ROOT="${1:?использование: $0 <корень> <отн-путь-контракта>}"
CONTRACT_PATH="${2:?использование: $0 <корень> <отн-путь-контракта>}"
ROOT="$(cd "$ROOT" 2>/dev/null && pwd -P)" || skip "корня нет: $ROOT"
[ -f "$ROOT/$CONTRACT_PATH" ] || skip "контракт не найден: $ROOT/$CONTRACT_PATH"

command -v git >/dev/null 2>&1 || skip "нет git"
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 || skip "$ROOT не репозиторий git"
git -C "$ROOT" rev-parse --verify HEAD >/dev/null 2>&1 || skip "в $ROOT нет ни одного коммита"

base="$(basename "$CONTRACT_PATH")"
NNN="$(printf '%s' "$base" | sed -nE 's/^([0-9]{3})-.*/\1/p')"
[ -n "$NNN" ] || skip "имя контракта вне грамматики NNN-<slug>.md: $base"

DRAFT_FULL="$(cat "$ROOT/$CONTRACT_PATH")"

# ── ПАРСИНГ ЗОНА/ПЕРЕСЕЧЕНИЕ ЧЕРНОВИКА (структурные поля — норма 041) ─────────
# Пять свойств формата (§Инварианты контракта 043):
#  1. алфавит: автор — [^:[:space:]]+ (тот же токен, что ЗОНА уже требует
#     репозиторно); путь — без пробелов (пробел разделяет список путей ЗОНА,
#     установлено check_zones.sh); NNN — ровно три цифры.
#  2. представление — параллельные bash-массивы Z_AUTHOR[]/Z_PATH[]/X_*[], НЕ
#     join-строка: путь легально содержит `-`/`:`, ПЕРЕСЕЧЕНИЕ сам несёт `:` и
#     ` — `, join+split молча резал бы по этим байтам.
#  3. сравнение — литеральное `[ = ]`/`case` везде ниже, ни разу regex/glob,
#     построенный из untrusted-стороны (пути/авторов).
#  4. терминатор — построчный разбор, якорь — точный префикс в начале строки
#     (`case "ЗОНА "*`, `case "ПЕРЕСЕЧЕНИЕ "*`), без интерполяции в grep -E.
#  5. self-application green — §Приёмка Р-та + battery-профиль (fixtures/
#     parsing_hygiene_battery/profiles/check_precision_gate.sh).
declare -a Z_AUTHOR=() Z_PATH=()
while IFS= read -r zline; do
  case "$zline" in
    "ЗОНА "*":"*)
      zrest="${zline#ЗОНА }"
      zauthor="${zrest%%:*}"
      zpaths="${zrest#*:}"
      [ -n "$zauthor" ] || continue
      [ "$zauthor" = "$zrest" ] && continue
      set -f
      # shellcheck disable=SC2086
      for zp in $zpaths; do
        Z_AUTHOR+=("$zauthor"); Z_PATH+=("$zp")
      done
      set +f
      ;;
  esac
done <<<"$DRAFT_FULL"

declare -a X_AUTHOR=() X_PATH=() X_NNN=()
while IFS= read -r xline; do
  case "$xline" in
    "ПЕРЕСЕЧЕНИЕ "*)
      # `ПЕРЕСЕЧЕНИЕ <автор>: <путь> — <NNN> <причина>` (em-dash, тот же байт что СПАСЕНО)
      xa="$(printf '%s' "$xline" | sed -nE 's/^ПЕРЕСЕЧЕНИЕ ([^:[:space:]]+): ([^ ]+) — ([0-9]{3}) (.+)$/\1/p')"
      xp="$(printf '%s' "$xline" | sed -nE 's/^ПЕРЕСЕЧЕНИЕ ([^:[:space:]]+): ([^ ]+) — ([0-9]{3}) (.+)$/\2/p')"
      xn="$(printf '%s' "$xline" | sed -nE 's/^ПЕРЕСЕЧЕНИЕ ([^:[:space:]]+): ([^ ]+) — ([0-9]{3}) (.+)$/\3/p')"
      xr="$(printf '%s' "$xline" | sed -nE 's/^ПЕРЕСЕЧЕНИЕ ([^:[:space:]]+): ([^ ]+) — ([0-9]{3}) (.+)$/\4/p')"
      if [ -z "$xa" ] || [ -z "$xp" ] || [ -z "$xn" ] || [ -z "$xr" ]; then
        die "ПЕРЕСЕЧЕНИЕ не по грамматике: $xline"
      fi
      bound=0
      for ((zi = 0; zi < ${#Z_AUTHOR[@]}; zi++)); do
        if [ "${Z_AUTHOR[$zi]}" = "$xa" ] && [ "${Z_PATH[$zi]}" = "$xp" ]; then bound=1; break; fi
      done
      [ "$bound" -eq 1 ] || die "ПЕРЕСЕЧЕНИЕ не привязан: путь $xp не заявлен автором $xa в ЗОНА этого черновика"
      X_AUTHOR+=("$xa"); X_PATH+=("$xp"); X_NNN+=("$xn")
      ;;
  esac
done <<<"$DRAFT_FULL"
# ── ПАРСИНГ «ОЖИДАЕМО КРАСНОЕ СЕЙЧАС» СЕКЦИЙ ЧЕРНОВИКА (задача б, норма
# этого контракта — НЕ отдельная батарея, структурное поле черновика).
#
# Проектная конвенция (AGENTS §Воркфлоу п.1, прецеденты замороженные 025/032):
# архитектор сдаёт red-тест ДО реализации, тест красен rc≠0 до implementer-раздачи.
# Без этого парсинга задача б слепо требует rc=0 ОТ ЛЮБОГО нового red-файла — ломая
# стандартный рабочий процесс. Контрпример: contracts/037 вводит
# `fixtures/check_runner_hygiene/red_self_contained_cwd.sh` (барьер
# scripts/check_runner_hygiene.sh СУЩЕСТВУЕТ, 037 его НЕ правит), файл НОВЫЙ
# относительно тега минта 037; в §Приёмочный критерий 037 явно разделяет «### Красное
# сейчас» (rc=1 ожидаем, реализация ещё не внесена) и «### После реализации» (rc=0).
# Задача б слепа к этому различию — текущий код ломает оба эти контракта в общем случае.
#
# Реализация: построчно парсим DRAFT_FULL, активируем флаг на markdown-заголовке
# (1-6 `#` + пробел + текст) с подстрокой «красное сейчас» / «до реализации» /
# «pre-implementation» / «red now» (case-insensitive), сбрасываем на любом другом
# заголовке; внутри активной секции извлекаем пути `fixtures/check_<key>/<файл>.sh`
# (grep -oE) и заполняем EXPECTED_RED_NOW[path]=1. В проверке rc=0 (ниже) — если
# `fixtures/check_<key>/<cf>` в map, rc≠0 допустим (защита Б2/Б3 — живой вызов
# барьера — остаётся активной, проверяется трейсовым прогоном).
declare -A EXPECTED_RED_NOW=()
_rn_active=0
while IFS= read -r _rn_line; do
  # Markdown-заголовок: ^#{1,6} (1-6 #), затем пробелы и текст. Шебанг #! — не заголовок
  # (нет пробела сразу после `#`). Отступ слева запрещён спецификацией markdown.
  if [[ "$_rn_line" =~ ^\#{1,6}\ +(.+)$ ]]; then
    _rn_head="${BASH_REMATCH[1]}"
    # bash-встроенный ${var,,} корректно лоуэркейсит КИРИЛЛИЦУ (UTF-8 multibyte);
    # `tr '[:upper:]' '[:lower:]'` в C-locale НЕ ловырует кириллические буквы.
    _rn_low="${_rn_head,,}"
    case "$_rn_low" in
      *красное\ сейчас*|*до\ реализации*|*pre-implementation*|*red\ now*)
        _rn_active=1 ;;
      *)
        _rn_active=0 ;;
    esac
  fi
  if [ "$_rn_active" -eq 1 ]; then
    while IFS= read -r _rn_match; do
      [ -n "$_rn_match" ] || continue
      EXPECTED_RED_NOW["$_rn_match"]=1
    done < <(printf '%s' "$_rn_line" | grep -oE 'fixtures/check_[A-Za-z0-9_]+/[A-Za-z0-9_.+-]+\.sh' 2>/dev/null || true)
  fi
done <<<"$DRAFT_FULL"
# ── ЗАДАЧА (а): ЗОНА-КОЛЛИЗИЯ ПРОТИВ UNION ЖИВЫХ ЗАМОРОЗОК ────────────────────
state="$(registry_state "$ROOT" 'frozen/')"
case "$state" in
  full | unknown-remote) ;;
  *) die "реестр заморозок не читается: $state" ;;
esac

ZDIR="$(zones_load "$ROOT")"
zrc=$?
if [ "$zrc" -ne 0 ]; then
  if [ "$zrc" -eq 1 ]; then die "union зон не читается (отказ реестра)"; else skip "zones_load недоступен (rc $zrc)"; fi
fi

# Детерминированный порядок обхода — по пути, затем по автору: «первая красная»
# строка стабильна между прогонами (AGENTS правило 7 — отказ обязан быть именным
# и воспроизводимым, не зависеть от порядка ассоциативного массива bash).
#
# Б1 fix: для КАЖДОЙ пары (author, path) перебираем ВСЕ чужие NNN на этом пути
# (а не только первый), и для каждого требуем ОТДЕЛЬНОЕ объявление ПЕРЕСЕЧЕНИЕ.
# Прежний код останавливался на ПЕРВОМ чужом NNN — объявление этой коллизии
# гасило и ВСЕ остальные коллизии того же пути, что молча пропускало нарушения
# предмета (критик 043 v1 Б1). Детерминированный порядок отказа — по
# возрастанию NNN коллизии, затем автора (тот же порядок, что zones_scoped).
if [ "${#Z_PATH[@]}" -gt 0 ]; then
  mapfile -t Z_ORDER < <(
    for ((i = 0; i < ${#Z_AUTHOR[@]}; i++)); do
      printf '%s\t%s\t%d\n' "${Z_PATH[$i]}" "${Z_AUTHOR[$i]}" "$i"
    done | LC_ALL=C sort
  )
  for row in "${Z_ORDER[@]}"; do
    IFS=$'\t' read -r p a _i <<<"$row"
    own=0
    if [ -s "$ZDIR/zones_scoped" ]; then
      while IFS=$'\t' read -r sa sp sn; do
        if [ "$sp" = "$p" ] && [ "$sa" = "$a" ] && [ "$sn" = "$NNN" ]; then own=1; break; fi
      done < "$ZDIR/zones_scoped"
    fi
    [ "$own" -eq 1 ] && continue
    # Собираем ВСЕ чужие NNN/авторов на этом пути (а не первый).
    declare -a COLL_NNNS=() COLL_AUTHORS=()
    if [ -s "$ZDIR/zones_scoped" ]; then
      while IFS=$'\t' read -r sa sp sn; do
        if [ "$sp" = "$p" ] && [ "$sn" != "$NNN" ] && [ "$sa" != "$a" ]; then
          COLL_NNNS+=("$sn"); COLL_AUTHORS+=("$sa")
        fi
      done < "$ZDIR/zones_scoped"
    fi
    [ "${#COLL_NNNS[@]}" -gt 0 ] || continue
    mapfile -t COLL_ORDER < <(
      for ((ci = 0; ci < ${#COLL_NNNS[@]}; ci++)); do
        printf '%s\t%s\t%d\n' "${COLL_NNNS[$ci]}" "${COLL_AUTHORS[$ci]}" "$ci"
      done | LC_ALL=C sort
    )
    for crow in "${COLL_ORDER[@]}"; do
      IFS=$'\t' read -r coll_nnn coll_author _ci <<<"$crow"
      declared=0
      for ((xi = 0; xi < ${#X_AUTHOR[@]}; xi++)); do
        if [ "${X_AUTHOR[$xi]}" = "$a" ] && [ "${X_PATH[$xi]}" = "$p" ] && [ "${X_NNN[$xi]}" = "$coll_nnn" ]; then
          declared=1; break
        fi
      done
      [ "$declared" -eq 1 ] && continue
      die "зона-коллизия: $p заявлен $a (этот контракт, NNN $NNN), уже в union под NNN $coll_nnn для $coll_author — нужна строка ПЕРЕСЕЧЕНИЕ $a: $p — $coll_nnn <причина>"
    done
  done
fi

# ── ЗАДАЧА (б): ЖИВАЯ ПОЛЯРНОСТЬ КАЖДОГО НОВОГО case-файла ЗАТРОНУТОЙ СЕМЬИ ────
# Семья <key> = fixtures/check_<key>/…, барьер — scripts/check_<key>.sh (036, В4).
# «Новый» — отсутствовал НА ДИСКЕ ПОД ТЕМ ЖЕ ИМЕНЕМ в блобе тега минта
# id/CONTRACT/<NNN> этого же контракта (граница новизны — тот же приём, что
# норма 041 §Инварианты п.1); старые case-файлы семьи этим гейтом НЕ тронуты
# (named residual — «## Модель угроз» НЕ ЗАЩИЩАЕТ, страховка критик).
declare -A FAMILIES=()
for ((i = 0; i < ${#Z_PATH[@]}; i++)); do
  case "${Z_PATH[$i]}" in
    fixtures/check_*/*)
      key="${Z_PATH[$i]#fixtures/check_}"; key="${key%%/*}"
      [ -n "$key" ] && FAMILIES["$key"]=1
      ;;
  esac
done

# Семья, чей барьер `scripts/check_<key>.sh` заявлен к правке ЭТИМ ЖЕ
# черновиком (литерально среди Z_PATH) — гейтом молча не судится (прецедент
# 036 В4-3: «барьер — движущаяся цель драфта», критик решает за него). Живой
# случай — ЭТА САМАЯ семья fixtures/check_precision_gate/: её барьер
# scripts/check_precision_gate.sh вводится этим же контрактом 043, и её
# self-application case-файл рекурсивно зовёт этот же гейт на РЕАЛЬНОМ дереве
# — без исключения задача (б) тестировала бы САМА СЕБЯ неограниченно глубоко.
for _self_key in "${!FAMILIES[@]}"; do
  for ((i = 0; i < ${#Z_PATH[@]}; i++)); do
    if [ "${Z_PATH[$i]}" = "scripts/check_$_self_key.sh" ]; then
      unset "FAMILIES[$_self_key]"
      printf 'precision-гейт 043: семья %s — барьер правится этим же черновиком, задача (б) для неё пропущена (прецедент 036 В4-3)\n' "$_self_key" >&2
      break
    fi
  done
done

# Страж рекурсии (найдено живьём при само-применении, §Приёмка Р9/Р13): семья
# этого САМОГО контракта (`fixtures/check_precision_gate/`) содержит
# self-application case-файл, который САМ вызывает этот же гейт на РЕАЛЬНОМ
# дереве, а часть красных case-файлов задачи (б) САМИ строят toy-репозиторий и
# ЕЩЁ РАЗ зовут этот же гейт на нём — без счётчика глубина растёт неограниченно
# (гейт тестирует case, который тестирует гейт…). ГЛУБИНА ≤1 разрешена (один
# уровень honest self-test — нужен красным case б, проверяющим МЕХАНИКУ задачи
# б на своём toy), ≥2 — задача (б) пропускается (FAMILIES трактуется пустым).
_PGATE_TASK_B_DEPTH="${_PGATE_TASK_B_DEPTH:-0}"
[ "$_PGATE_TASK_B_DEPTH" -ge 2 ] && FAMILIES=()

if [ "${#FAMILIES[@]}" -gt 0 ]; then

  # Базовая линия новизны: ВЫСШАЯ уже живая заморозка ЭТОГО ЖЕ NNN (036-В3-приём:
  # для v2+ «новое» значит «не было в предыдущей версии», ДОБАВЛЕНИЕ красных
  # тестов пост-заморозки легально — AGENTS §Воркфлоу п.3 — и не является
  # «новым» относительно v+1); при первой заморозке (frozen-тега ещё нет) —
  # тег минта id/CONTRACT/<NNN> (до какой-либо работы над этим NNN).
  vmax=0
  while IFS= read -r _t; do
    if [[ "$_t" =~ ^refs/tags/frozen/contracts/${NNN}/([0-9]+)$ ]]; then
      _k=$((10#${BASH_REMATCH[1]}))
      [ "$_k" -gt "$vmax" ] && vmax="$_k"
    fi
  done < <(git -C "$ROOT" for-each-ref --format='%(refname)' "refs/tags/frozen/contracts/$NNN/" 2>/dev/null)
  if [ "$vmax" -gt 0 ]; then
    MINT_TAG="refs/tags/frozen/contracts/$NNN/$vmax"
  else
    MINT_TAG="refs/tags/id/CONTRACT/$NNN"
    git -C "$ROOT" rev-parse --verify --quiet "$MINT_TAG" >/dev/null 2>&1 \
      || die "тег минта $MINT_TAG не существует — новизна case-файлов не определима"
  fi

  for key in "${!FAMILIES[@]}"; do
    barrier="$ROOT/scripts/check_$key.sh"
    [ -f "$barrier" ] || continue    # семья-без-барьера уже красна в check_spec_ready 036
    fam_dir="$ROOT/fixtures/check_$key"
    [ -d "$fam_dir" ] || continue
    mapfile -t case_files < <(cd "$fam_dir" && printf '%s\n' case_*.sh red_*.sh green_*.sh 2>/dev/null | LC_ALL=C sort -u)
    for cf in "${case_files[@]}"; do
      [ -f "$fam_dir/$cf" ] || continue
      case_path="fixtures/check_${key}/${cf}"
      if git -C "$ROOT" cat-file -e "$MINT_TAG:$case_path" 2>/dev/null; then
        continue    # существовал уже на HEAD тега минта — не новый, вне области
      fi
      case "$cf" in
        red_*.sh | green_*.sh) ;;
        *) die "полярность не заявлена: $case_path (basename не начинается red_ или green_)" ;;
      esac
      # ОЖИДАЕМО КРАСНЫЙ СЕЙЧАС — этот case-файл явно заявлен черновиком в секции
      # «Красное сейчас»/«до реализации»/«Pre-implementation» (парсинг выше):
      # стандартная конвенция проекта — архитектор сдаёт red-тест ДО реализации,
      # тест красен rc≠0 до implementer-раздачи. rc≠0 допустим (защита Б2/Б3 —
      # живой вызов барьера — остаётся активной, проверяется трейсовым прогоном).
      expected_red_now="${EXPECTED_RED_NOW[$case_path]:-0}"

      # ── Б3 fix: ОТДЕЛЬНЫЙ прямой (не-трейсовый) запуск case и ЕГО собственный
      # rc обязателен зелёным ОТДЕЛЬНО от трейсового результата (тот же класс
      # риска, что 038 §В2 round-13: case может вести себя иначе под `set -x`,
      # `case $- in *x*)`). Прежний код сохранял rc единственного трейсового
      # прогона; прямой прогон не существовал — обход не отвергался. Прямой
      # прогон НЕ получает ни SHELLOPTS=xtrace, ни BASH_XTRACEFD — никаких
      # переменных окружения, влияющих на поведение case'а; xtrace выключен.
      direct_rc=0
      env -i PATH=/usr/bin:/bin HOME="$HOME" bash "$fam_dir/$cf" || direct_rc=$?
      # rc=0 обязателен для «обычных» case-файлов; для case-файлов, ЗАЯВЛЕННЫХ
      # черновиком как ожидаемо красные сейчас (секция «Красное сейчас»/«до реализации»),
      # rc≠0 допустим (Б3 fix: xtrace-дифференциал отсечён выше пустым env — прямое
      # поведение ИДЕНТИЧНО трейсовому, не на что «ловить» через прямое; файл
      # запускается отдельно просто чтобы зафиксировать синтаксическую корректность
      # и общий характер завершения).
      [ "$expected_red_now" -eq 1 ] || [ "$direct_rc" -eq 0 ] \
        || die "$case_path: самопроверка провалена (rc $direct_rc, ожидался 0)"

      # ── Б2 fix: живость барьера наблюдается НЕЗАПИСЫВАЕМЫМ самим case-файлом
      # оракулом — /proc/<pid>/cmdline-опросом ИЗ gate-процесса. Прежний код
      # использовал BASH_XTRACEFD — case мог подделать трассу через
      # `printf "+ /path" >&"$BASH_XTRACEFD"` (критик 043 v1 Б2). Теперь:
      #  • BASH_XTRACEFD НЕ передаётся case (env-переменная пуста) — подделка
      #    >&"$BASH_XTRACEFD" даёт bash-ошибку «bad fd», case завершается rc=1
      #    ДО трейсового прогона (прямая самопроверка его ловит);
      #  • SHELLOPTS=xtrace НЕ передаётся — `case $- in *x*)` всегда ложен,
      #    дифференциальное поведение под xtrace невозможно (Б3 уже закрыт);
      #  • Барьер exec наблюдается gate'ом через /proc: case запущен в фоне,
      #    gate опрашивает /proc/<ppid>/cmdline всех потомков case_pid на
      #    вхождение канонического абсолютного пути барьера.
      #
      # Источник истины — procfs; case не владеет каналом наблюдения, потому
      # что procfs наблюдается СНАРУЖИ его процесса. Никакого trace-fd в
      # BASH_XTRACEFD — case не имеет fd, в который мог бы писать «+»-строки.
      #
      # Ограничение (документировано в §Модель угроз НЕ ЗАЩИЩАЕТ): при
      # уникально коротком exec'е окно опроса может пропустить cmdline —
      # граница механизма.
      #
      # Б5 fix (043 round-2, ЛОЖНЫЙ ОТКАЗ честному вызову): прежняя реализация
      # порождала ПОДПРОЦЕСС awk И tr|sed на КАЖДЫЙ /proc/<pid>/status И
      # /proc/<pid>/cmdline (~3 fork на процесс × 550 процессов = ~1.4с на одну
      # итерацию внешнего цикла). Барьер `sleep 1` живёт ~1.05с — глоб
      # `/proc/[0-9]*` экспандится ОДИН РАЗ на старте `for`, и за время одной
      # итерации процесса барьера может ещё не быть в списке (case bash ещё
      # делает setup) или уже нет (sleep вернулся). Получали 0–1 внешнюю
      # итерацию за окно живого exec — ровно «/proc-наблюдение не нашло exec»
      # на честном входе. Переписано на чистые bash-встроенные: чтение PPid из
      # /proc/<pid>/status — параметрическим разбором в переменную (без fork);
      # чтение argv[1] из /proc/<pid>/cmdline — `read -d $'\0'` (без fork);
      # построение ppid-карты один раз на старте внешней итерации (≈40мс на
      # 550 процессов), обход дерева — по карте в памяти (≈5мс). Итого одна
      # внешняя итерация ≈50мс → ≥20 итераций за окно `sleep 1`, барьер
      # ловится устойчиво. Глоб `/proc/[0-9]*` переэкспандится на каждом витке
      # внешнего while, чтобы свеже-форкнутый процесс попал в выборку.
      bash "$fam_dir/$cf" &
      case_pid=$!
      live=0
      traced_rc=0
      while kill -0 "$case_pid" 2>/dev/null; do
        declare -A _PG_PPID=()
        for _d in /proc/[0-9]*; do
          [ -r "$_d/status" ] || continue
          _p="${_d##*/}"
          # Разбор PPid из status bash-встроенным regex (≈30мс на 540 процессов
          # против ≈740мс при параметрическом разборе — bash для speed-up).
          _content=$(<"$_d/status")
          if [[ "$_content" =~ $'\n'PPid:[[:space:]]+([0-9]+) ]]; then
            _PG_PPID["$_p"]="${BASH_REMATCH[1]}"
          else
            _PG_PPID["$_p"]=""
          fi
        done
        for _d in /proc/[0-9]*; do
          [ -r "$_d/cmdline" ] || continue
          _p="${_d##*/}"
          # потомок case_pid (включая сам case_pid — `exec` в нём оставляет
          # argv[1] барьера; оригинальный walk-up от PPid этот случай не ловил).
          _cur="$_p"
          _in_tree=0
          while [ -n "$_cur" ] && [ "$_cur" -gt 1 ] 2>/dev/null; do
            if [ "$_cur" = "$case_pid" ]; then _in_tree=1; break; fi
            _cur="${_PG_PPID[$_cur]:-}"
          done
          [ "$_in_tree" -eq 1 ] || continue
          # argv-скан ВСЕХ полей (решение арбитража 043-БС7 — закрытие КЛАССА
          # смещения пути скрипта в окончательном argv, не точечной позиции).
          # ДВА УРОВНЯ преобразования argv образуют наблюдаемый объект, который
          # гейт читает через /proc/<pid>/cmdline:
          #
          #   (ядро) Linux binfmt_script поддерживает НЕ БОЛЕЕ ОДНОГО
          #   опционального shebang-аргумента — то есть максимум argv[2] может
          #   быть shebang-флагом, но НЕ argv[3..] при ОДНОМ ядерном
          #   преобразовании. Возможные ядерные cmdline-формы (NUL-поля, без
          #   финального NUL на конце аргументов — стандартный вывод
          #   /proc/<pid>/cmdline):
          #
          #     [interpreter, script_path, ...args]                  — shebang без опции
          #                                                            (например `#!/usr/bin/env bash`,
          #                                                             `#!/bin/bash`),
          #     [interpreter, shebang_option, script_path, ...args]  — shebang С ОПЦИЕЙ
          #                                                            (например `#!/bin/bash -e`,
          #                                                             `#!/bin/bash -e -u`),
          #     либо явный `bash -e /abs/barrier` (тот же cmdline-формат).
          #
          #   (userspace) GNU `env -S` — ДОКУМЕНТИРОВАННАЯ штатная возможность
          #   coreutils, берёт ОДИН ядерный shebang-аргумент («-S») и
          #   РАЗРЕЗАЕТ его на НЕСКОЛЬКО полей USERPACE-ПРЕОБРАЗОВАНИЕМ. Для
          #   shebang `#!/usr/bin/env -S bash -e -u` ядро видит
          #   `env -S "bash -e -u" <barrier>`, env -S режет «bash -e -u» на
          #   `["bash","-e","-u"]` и exec'ит bash с argv =
          #   `[bash, -e, -u, <barrier>]` — путь скрипта на argv[3], argv[5]
          #   и далее БЕЗ ПРЕДЕЛА (следующая опция интерпретатора добавляет ещё
          #   одно userspace-поле). Это тот же класс риска, что ядерное
          #   shebang-преобразование, но уровнем ВЫШЕ — в userspace.
          #
          # Снятое позиционное допущение «ВСЕГДА на 1 или 2»: гейт НЕ полагается
          # на КОНКРЕТНУЮ позицию, а literal-сканирует ВСЕ NUL-поля cmdline с
          # индекса 1 до конца. Любое поле, ПОБАЙТОВО равное канонически-
          # абсолютному пути барьера — live. Сравнение — только `[ = ]`/`case`-
          # литерал, никаких regex/glob (норма 041 §Инварианты п.2(iii)).
          #
          # БС7-round5 fix (043 round-5, ЛОЖНЫЙ ОТКАЗ честному вызову С
          # USERPACE-РАЗРЕЗАННЫМ env -S MULTI-FLAG shebang, арбитраж 043-БС7
          # `verdicts/arbitration/043-bs7-cmdline-pozicii-env-s.md`): прежний
          # код (round-4) читал ровно 3 NUL-поля и сравнивал ТОЛЬКО argv[1] И
          # argv[2]. Для shebang `#!/usr/bin/env -S bash -e -u` cmdline =
          # `[bash, -e, -u, <barrier>]`, argv[1]="-e", argv[2]="-u" — обе
          # позиции НЕ содержат путь барьера; прежний код давал «барьер dummy
          # не вызван живьём» на честном прямом вызове (нарушение правила 7
          # AGENTS.md — ложный диагноз на честном входе). Теперь: чтение ВСЕХ
          # NUL-полей до EOF, цикл по индексам с 1 до конца, сравнение каждого
          # ПОБАЙТОВО литералом `[ = ]` с `$barrier`; совпадение на argv[3]
          # засчитывается, вызов признаётся живым. green_20 держит инварицию.
          #
          # БС7-round4 fix (043 round-4, ЛОЖНЫЙ ОТКАЗ честному вызову С ОПЦИЕЙ
          # В SHEBANG): прежний код (round-3) читал ровно 2 NUL-поля и
          # сравнивал ТОЛЬКО argv[1]. Для shebang С опцией (`#!/bin/bash -e`)
          # cmdline = `[bash, -e, <script>]`, argv[1] = "-e" — false negative
          # → «барьер не вызван живьём» на честном входе; исправлено чтением
          # 3 полей и сравнением ОБА argv[1] И argv[2] (тот же класс риска,
          # что green_19 держит).
          #
          # Б6 fix (043 round-3): прежнее скользящее окно `_argv0=$_argv1;
          # _argv1=$_part` читало ВСЕ NUL-поля, но оставляло в `_argv1`
          # ПОСЛЕДНЕЕ поле, а не второе. Для `bash <barrier> <arg...>`
          # сравнивался последний аргумент, а не путь барьера — ложный отказ
          # честному вызову, грабивший green_18.
          #
          # ЦЕНА расширения позиционного допущения до «все поля с индекса 1»
          # (прямо названо арбитром 043-БС7): скан расширяет поверхность
          # совпадения «путь барьера как данные чужого argv». Это НЕ новый
          # класс риска — тот же ложный accept измеренно присутствует в
          # сегодняшних позициях 1-2 (З4 арбитража: `tail -f <барьер>` → rc 0
          # уже сейчас) и УЖЕ объявлен контрактом §Модель угроз НЕ ЗАЩИЩАЕТ
          # («в любом поле argv», обобщённая формулировка после БС7-round5).
          # Расширение того же ПРИНЯТОГО остатка, не новый механизм и не новый
          # класс риска.
          #
          # Чистые bash-встроенные, никакого fork на pid (весь смысл Б5 fix).
          _argv=()
          while IFS= read -r -d $'\0' _part; do
            _argv+=("$_part")
          done < "$_d/cmdline"
          _path_seen=0
          for ((_ai = 1; _ai < ${#_argv[@]}; _ai++)); do
            if [ "${_argv[$_ai]}" = "$barrier" ]; then _path_seen=1; break; fi
          done
          if [ "$_path_seen" -eq 1 ]; then live=1; break 2; fi
          unset _argv _part _ai _path_seen _cur _in_tree
        done
        unset _PG_PPID
      done
      wait "$case_pid" || traced_rc=$?

      [ "$live" -eq 1 ] || die "$case_path: барьер $key не вызван живьём (/proc-наблюдение не нашло exec)"
      [ "$expected_red_now" -eq 1 ] || [ "$traced_rc" -eq 0 ] \
        || die "$case_path: самопроверка провалена (rc $traced_rc, ожидался 0)"
    done
  done
fi
# ── ЗАДАЧА (в): ПАРИТЕТ CI (дешевле всего — измерено 1.574с на здоровом HEAD) ─
[ -f "$SELF_DIR/verify_ci_parity.sh" ] || skip "scripts/verify_ci_parity.sh не существует"
ci_out=""; ci_rc=0
ci_out="$(bash "$SELF_DIR/verify_ci_parity.sh" "$ROOT" 2>&1)" || ci_rc=$?
[ "$ci_rc" -eq 0 ] || die "паритет CI красен (verify_ci_parity.sh rc $ci_rc): $(printf '%s' "$ci_out" | head -n 1)"


printf 'OK\n'
exit 0