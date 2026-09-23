#!/usr/bin/env bash
# precision-гейт (контракт 043, Н-113/Н-115) — пре-фриз чек трёх независимых свойств
# черновика КОНТРАКТА, каждое исторически ловилось только ПОСЛЕ заморозки (v+1 ценой
# подписи владельца — конкретика в NABLIUDENIA.md Н-113/Н-115, HANDOFF чекпойнт #16):
#
#   (а) ЗОНА-дельта черновика (dry-run union: zones_load с чернoвиком минус без него)
#       не пересекает union живых заморозок ЧУЖИМ автором под ДРУГИМ NNN без явного
#       объявления ПЕРЕСЕЧЕНИЕ в тексте самого черновика (правило 7 AGENTS.md —
#       неразобранное объявление отказывает с названным местом и выходом);
#   (б) КАЖДЫЙ НОВЫЙ (отсутствовавший на HEAD тега минта id/CONTRACT/<NNN>) case-файл
#       ЗАТРОНУТОЙ семьи (fixtures/check_<key>/, объявленной в ЗОНА черновика)
#       структурно заявляет полярность (basename red_*/green_*), барьер семьи
#       вызван ЖИВЬЁМ (внешний независимый трейс — BASH_XTRACEFD, не текстовое
#       совпадение вывода) и собственная самопроверка case-файла зелена;
#   (в) дерево черновика паритетно CI — verify_ci_parity.sh (контракт 020), уже
#       полный и дешёвый механизм, просто не вызывавшийся на freeze-хуке.
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
#          в: зона-коллизия и живая полярность — раньше паритета CI, задача (б)
#          дороже всего и растёт с числом case-файлов — исполняется последней,
#          названо честно, не скрыто);
#   rc 2 — нечем проверить (нет git/контракта/NNN-грамматики/реестра/тега минта,
#          когда нужен задаче б).
#
# НЕ БАРЬЕР: классификация verify_antiplacebo.sh §1 area-scan — семья
# fixtures/check_precision_gate/ называет файлы `red_*`/`green_*` по грамматике
# ЭТОГО ЖЕ контракта (задача б выше — красные/зелёные basename-полярности), а
# не `case_*.sh` — конверсия в case_*-семью не выполнена (прецедент
# drill_path_guard.sh/drill_exit_marker.sh: «red_* вне case_*-глоба раннера»,
# «конверсия — пачка ARCHITECT после land»). Верификация — прямой прогон
# fixtures/_krasnye_043.sh (агрегатор всех 9 сценариев Р1-Р9) и self-application
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
    coll_nnn=""; coll_author=""
    if [ -s "$ZDIR/zones_scoped" ]; then
      while IFS=$'\t' read -r sa sp sn; do
        if [ "$sp" = "$p" ] && [ "$sn" != "$NNN" ] && [ "$sa" != "$a" ]; then
          coll_nnn="$sn"; coll_author="$sa"; break
        fi
      done < "$ZDIR/zones_scoped"
    fi
    [ -n "$coll_nnn" ] || continue
    declared=0
    for ((xi = 0; xi < ${#X_AUTHOR[@]}; xi++)); do
      if [ "${X_AUTHOR[$xi]}" = "$a" ] && [ "${X_PATH[$xi]}" = "$p" ] && [ "${X_NNN[$xi]}" = "$coll_nnn" ]; then
        declared=1; break
      fi
    done
    [ "$declared" -eq 1 ] && continue
    die "зона-коллизия: $p заявлен $a (этот контракт, NNN $NNN), уже в union под NNN $coll_nnn для $coll_author — нужна строка ПЕРЕСЕЧЕНИЕ $a: $p — $coll_nnn <причина>"
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
# черновиком (буквально среди Z_PATH) — гейтом молча не судится (прецедент
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
# ЕЩЁ РАЗ зовут этот гейт на нём — без счётчика глубина растёт неограниченно
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
      if git -C "$ROOT" cat-file -e "$MINT_TAG:fixtures/check_$key/$cf" 2>/dev/null; then
        continue    # существовал уже на HEAD тега минта — не новый, вне области
      fi
      case "$cf" in
        red_*.sh | green_*.sh) ;;
        *) die "полярность не заявлена: fixtures/check_$key/$cf (basename не начинается red_ или green_)" ;;
      esac
      # Внешний независимый трейс — BASH_XTRACEFD (прецедент 036/check_spec_ready.sh
      # В4-2/3, арбитраж 036d1f1): дочерний bash пишет xtrace в НАСЛЕДУЕМЫЙ fd,
      # физически отдельный от stdout/stderr пробы — проба владеет своими потоками,
      # не каналом трассы; ноль внешних зависимостей (в отличие от strace, не
      # гарантированно в PATH каждого окружения — измерено ИМЕННО на этом гейте).
      trc="$(mktemp "${TMPDIR:-/tmp}/pgate043_trace.XXXXXX" 2>/dev/null || mktemp)" \
        || skip "нечем создать trace-файл"
      case_rc=0
      exec {_tfd}>"$trc" || skip "нечем открыть trace-канал"
      env PS4='+ ' SHELLOPTS=xtrace BASH_XTRACEFD=$_tfd _PGATE_TASK_B_DEPTH=$((_PGATE_TASK_B_DEPTH + 1)) bash "$fam_dir/$cf" >/dev/null 2>&1 || case_rc=$?
      # ВАЖНО: `2>/dev/null` НЕ вешается на голый `exec {fd}>&-` — это форма
      # «переопределить дескрипторы ТЕКУЩЕЙ оболочки», и `2>/dev/null` без
      # команды ПЕРМАНЕНТНО увёл бы stderr САМОГО check_precision_gate.sh в
      # /dev/null до конца прогона (найдено живьём при написании — все die()
      # ПОСЛЕ первой такой строки печатали rc без причины). `|| true` один
      # снимает лишь код возврата закрытия.
      exec {_tfd}>&- || true
      live=0
      # Якорь — командная позиция: строка трассы, где ПОСЛЕ PS4-префикса (N
      # символов `+`, реплицируемых bash по глубине вложенности — функция/
      # command-substitution вокруг вызова барьера дают N>1, `+ `→`++ `→…,
      # задокументировано поведением PS4) стоит литерал барьера ПЕРВЫМ словом.
      # Ведущий прогон `+` снимается по длине, НЕ фиксированным `+ ` —
      # `_toy.sh`-конвенция зовёт барьер ИЗ функции `run_barrier` внутри `$(…)`,
      # что даёт глубину ≥2 систематически, не глубину 1.
      while IFS= read -r _trl; do
        _lead="${_trl%%[!+]*}"
        [ -n "$_lead" ] || continue
        _rest="${_trl#"$_lead"}"
        _rest="${_rest# }"
        case "$_rest" in
          "$barrier" | "$barrier"' '*) live=1; break ;;
        esac
      done < "$trc"
      rm -f "$trc"
      [ "$live" -eq 1 ] || die "fixtures/check_$key/$cf: барьер $key не вызван живьём (командная позиция не найдена в трассе)"
      [ "$case_rc" -eq 0 ] || die "fixtures/check_$key/$cf: самопроверка провалена (rc $case_rc, ожидался 0)"
    done
  done
fi
# ── ЗАДАЧА (в): ПАРИТЕТ CI (дешевле всего — измерено 1.574с на здоровом HEAD) ──
[ -f "$SELF_DIR/verify_ci_parity.sh" ] || skip "scripts/verify_ci_parity.sh не существует"
ci_out=""; ci_rc=0
ci_out="$(bash "$SELF_DIR/verify_ci_parity.sh" "$ROOT" 2>&1)" || ci_rc=$?
[ "$ci_rc" -eq 0 ] || die "паритет CI красен (verify_ci_parity.sh rc $ci_rc): $(printf '%s' "$ci_out" | head -n 1)"


printf 'OK\n'
exit 0
