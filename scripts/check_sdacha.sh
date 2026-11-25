#!/usr/bin/env bash
# ДВЕРЬ СДАТОЧНОГО ЛИСТА (контракт 193, Л2).
#
# CLI заморожен нормами (architect.md:164, critic.md:272, orchestrator.md:461):
#   bash scripts/check_sdacha.sh <корень> <отн-путь-контракта> --run
#
# Судит ТОЛЬКО форму и согласованность: грамматику листа, существование и
# прогон команд (бюджет), равенство заявленных и фактических rc, покрытие
# дельтой блоков предыдущего ЗАКОММИЧЕННОГО вердикта. Карта вердикта раскрывается
# единой библиотекой (И5/И7): ссылка «без изменений с вызова N» наследует статус
# ТОГО ЖЕ класса вызова N (исторический OBJECT остаётся записью, а не ревизией
# чтения); кроме предъявленной карты покрытием судится последний FAIL той же
# темы и роли critic — старый accept его не скрывает. Смысл («доказательство
# доказывает») судит критик — дверь смысла не разбирает.
#
# Коды возврата:
#   0 — лист зелёный либо не требуется (именованный маркер в stdout);
#   1 — именованный отказ «ОТКАЗ: …» (место и выход названы);
#   2 — NOT_IMPLEMENTED: нечем проверять (нет git/timeout/awk, нет контракта).
#
# Швы (объявлены контрактом 193, И3): SDACHA_TIMEOUT_SEK — бюджет одной
# команды, SDACHA_BUDZHET_SEK — бюджет листа. Источники по старшинству
# (R-0102): ENV-шов > профиль проекта (harness.project.json: sdacha.timeoutSec /
# sdacha.budgetSec) > умолчание станции 300/900 — fallback для проектов без
# ключа; без профиля поведение двери побайтно прежнее.
# Команду, пережившую TERM, добивает SIGKILL через KILL_SEK=2 с (timeout -k):
# rc 137 — именованный отказ «убита», предел стены — predel + KILL_SEK (Б-4
# Rev193: бюджет ограничивает и ВЫПОЛНЯЮЩУЮСЯ команду, И3).
# На время прогона команд листа выставляется SDACHA_OKRUG=1: нога (к) двери
# pre_critic по маркеру пропускается — разрыв рекурсии лист↔дверь (И6).

set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES \
      GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

otkaz() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
ni()    { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

# зависимости — до разбора; git первым (К-06: отказ среды ≠ красная клетка)
command -v git >/dev/null 2>&1    || ni 'нет git'
command -v timeout >/dev/null 2>&1 || ni 'нет timeout'
command -v awk >/dev/null 2>&1    || ni 'нет awk'
command -v sed >/dev/null 2>&1    || ni 'нет sed'

[ $# -eq 3 ] || { printf 'использование: check_sdacha.sh <корень> <контракт> --run\n' >&2; exit 1; }
ROOT="$(cd "$1" 2>/dev/null && pwd -P)" || ni "корня нет: $1"
CONTRACT="$2"
[ "$3" = '--run' ] || { printf 'использование: check_sdacha.sh <корень> <контракт> --run\n' >&2; exit 1; }

case "$CONTRACT" in
    plans/*) printf 'СДАЧА: лист не требуется: план\n'; exit 0 ;;
esac
base="$(basename "$CONTRACT")"
NNN="$(printf '%s' "$base" | sed -nE 's/^([0-9]{3})-.*/\1/p')"
[ -n "$NNN" ] || ni "имя контракта вне грамматики NNN-<slug>.md: $base"
[ -f "$ROOT/$CONTRACT" ] || ni "контракт не найден: $ROOT/$CONTRACT"
[ -r "$ROOT/$CONTRACT" ] || ni "контракт не читается: $ROOT/$CONTRACT"

# значение ключа профиля → переменная-приёмник ($2). Ключ не объявлен —
# приёмник не тронут (умолчание станции ниже); значение вне алфавита целых
# секунд (нечисло, пусто, отрицательное) — именованный отказ ni-классом, как
# у швов: неизвестность не превращается в «без бюджета». Отсутствие ключа
# опознаётся маркером: profile_get печатает умолчание и на отсутствующий
# ключ (М-0, контракт 184).
sdacha_iz_profilya() { # $1 jq-путь ключа; $2 имя переменной-приёмника
    local v
    v="$(profile_get "$ROOT" "$1" 'НЕТ-КЛЮЧА')"
    [ "$v" = 'НЕТ-КЛЮЧА' ] && return 0
    case "$v" in
        ''|*[!0-9]*) ni "ключ профиля $1 обязан быть целым числом секунд (получено: «$v»)" ;;
    esac
    printf -v "$2" '%s' "$v"
}
TIMEOUT_SEK="${SDACHA_TIMEOUT_SEK:-}"
BUDZHET_SEK="${SDACHA_BUDZHET_SEK:-}"
if [ -f "$ROOT/harness.project.json" ]; then
    command -v jq >/dev/null 2>&1 || ni 'нет jq'
    _sd_self="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
    [ -r "$_sd_self/profile_resolver.sh" ] || ni 'нет profile_resolver.sh рядом с дверью'
    # ЕДИНЫЙ резолвер 996 — как соседние двери с профилем (pre_critic.sh):
    # отказ резолвера — именованный отказ двери; битый профиль не заменяется
    # молча умолчанием. Слой проекта — корень задан снаружи, иначе сам ROOT.
    if ! _sd_res="$(HARNESS_PROJECT_LAYER_ROOT="${HARNESS_PROJECT_LAYER_ROOT:-$ROOT}" \
            bash "$_sd_self/profile_resolver.sh" --repo "$ROOT" 2>&1)"; then
        otkaz "${_sd_res#profile ОТКАЗ: }"
    fi
    unset _sd_res
    # shellcheck disable=SC1091
    PROFILE_RESOLVER_LIB=1 . "$_sd_self/profile_resolver.sh"
    unset _sd_self
    [ -n "$TIMEOUT_SEK" ] || sdacha_iz_profilya 'sdacha.timeoutSec' TIMEOUT_SEK
    [ -n "$BUDZHET_SEK" ] || sdacha_iz_profilya 'sdacha.budgetSec' BUDZHET_SEK
fi
TIMEOUT_SEK="${TIMEOUT_SEK:-300}"
BUDZHET_SEK="${BUDZHET_SEK:-900}"
KILL_SEK=2   # сек до SIGKILL после TERM (timeout -k, Б-4 Rev193)
case "$TIMEOUT_SEK$BUDZHET_SEK" in
    *[!0-9]*) ni 'швы SDACHA_TIMEOUT_SEK/SDACHA_BUDZHET_SEK обязаны быть целыми секундами' ;;
esac

# ── путь листа: одна строка СДАЧА, закрытый алфавит (041) ─────────────────────
put_ok() { # $1 путь; rc 0 — путь в грамматике
    case "$1" in
        ''|/*) return 1 ;;
    esac
    [[ "$1" =~ ^[A-Za-z0-9._-]+(/[A-Za-z0-9._-]+)*[.]md$ ]] || return 1
    local o; for o in ${1//\// }; do [ "$o" = '..' ] && return 1; done
    return 0
}

sdacha_strok="$(grep -c '^СДАЧА: ' "$ROOT/$CONTRACT" || true)"
[ "$sdacha_strok" -le 1 ] || otkaz "строка СДАЧА: обязана быть одна, найдено $sdacha_strok"
LISTOK_REL="$(sed -n 's/^СДАЧА: //p' "$ROOT/$CONTRACT" | head -n 1)"

if [ -z "$LISTOK_REL" ]; then
    # ── граница обязательности: мера — теги frozen/contracts/<NNN>/*, без
    # ручного списка исключений (И4). Черновик (текст в рабочем дереве)
    # равен замороженному блобу → предмет заведён до внедрения, лист не нужен;
    # отличается или заморозок нет → черновик после внедрения, лист обязателен.
    tegi="$(git -C "$ROOT" for-each-ref --format='%(refname)' \
        "refs/tags/frozen/contracts/$NNN" 2>/dev/null)" \
        || ni "перечень замороженных версий $NNN не читается"
    vmax=0
    while IFS= read -r t; do
        case "$t" in
            "refs/tags/frozen/contracts/$NNN/"*[0-9]) k="${t##*/}" ;;
            *) continue ;;
        esac
        [[ "$k" =~ ^[0-9]+$ ]] || continue
        (( 10#$k > vmax )) && vmax=$(( 10#$k ))
    done <<< "$tegi"
    if [ "$vmax" -eq 0 ]; then
        otkaz "строка СДАЧА: обязательна (у предмета $NNN нет замороженных версий — черновик после внедрения 193)"
    fi
    TEG="frozen/contracts/$NNN/$vmax"
    rabochij_blob="$(git -C "$ROOT" hash-object -- "$ROOT/$CONTRACT" 2>/dev/null)" \
        || ni 'не вычислить блоб контракта'
    zamorozhen_blob="$(git -C "$ROOT" rev-parse --verify -q "$TEG:$CONTRACT" || true)"
    if [ -z "$zamorozhen_blob" ]; then
        put="$(git -C "$ROOT" ls-tree -r --name-only "$TEG" -- contracts 2>/dev/null \
            | awk -v n="$NNN" '$0 ~ "^contracts/"n"-[^/]*[.]md$" {print; exit}')"
        [ -n "$put" ] && zamorozhen_blob="$(git -C "$ROOT" rev-parse --verify -q "$TEG:$put" || true)"
    fi
    if [ -n "$zamorozhen_blob" ] && [ "$rabochij_blob" = "$zamorozhen_blob" ]; then
        printf 'СДАЧА: лист не требуется: текст заморожен (%s)\n' "$TEG"
        exit 0
    fi
    otkaz "строка СДАЧА: обязательна (текст отличается от $TEG — v+1 после внедрения 193)"
fi

put_ok "$LISTOK_REL" || otkaz "путь листа вне грамматики (относительный, внутри корня, .md): $LISTOK_REL"
LISTOK="$ROOT/$LISTOK_REL"
[ -f "$LISTOK" ] || otkaz "лист не найден: $LISTOK_REL"
[ -r "$LISTOK" ] || otkaz "лист не читается: $LISTOK_REL"

# грамматика листа — здесь (не в lib): lib несёт грамматику КАРТЫ ВЕРДИКТА,
# грамматика таблиц листа принадлежит этой двери (И2/И7: у каждой формы один источник)
RAZDEL=' · '
razbit() { # $1 строка-ряд; массив CHASTI
    local s="${1//"$RAZDEL"/$'\x1f'}"
    IFS=$'\x1f' read -r -a CHASTI <<< "$s"
}
rc_ok() { [[ "$1" =~ ^(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])$ ]]; }

# ── разбор секций ─────────────────────────────────────────────────────────────
SEKCII=(Двери Карта_классов Дельта)   # «Карта классов» с пробелом — ключ отдельный
declare -A STROKI_DVERI=() STROKI_KARTA=() STROKI_DELTA=()
declare -A NOMER_DVERI=() NOMER_KARTA=() NOMER_DELTA=()
PRED_VERDIKT=''
PRED_VERDIKT_N=0
sekcija=''
n=0
while IFS= read -r line || [ -n "$line" ]; do
    n=$((n + 1))
    case "$line" in
        '## Двери') sekcija=Dveri; continue ;;
        '## Карта классов') sekcija=Karta; continue ;;
        '## Дельта') sekcija=Delta; continue ;;
        '## '*) sekcija=''; continue ;;
    esac
    case "$line" in
        'ПРЕДЫДУЩИЙ ВЕРДИКТ: '*)
            PRED_VERDIKT_N=$((PRED_VERDIKT_N + 1))
            [ "$PRED_VERDIKT_N" -le 1 ] || otkaz "строка ПРЕДЫДУЩИЙ ВЕРДИКТ: обязана быть одна (строка $n)"
            PRED_VERDIKT="${line#ПРЕДЫДУЩИЙ ВЕРДИКТ: }"
            continue ;;
    esac
    case "$line" in
        '- '*) : ;;
        *) continue ;;
    esac
    ryad="${line#- }"
    case "$sekcija" in
        Dveri) idx=${#STROKI_DVERI[@]}; STROKI_DVERI[$idx]="$ryad"; NOMER_DVERI[$idx]="$n" ;;
        Karta)  idx=${#STROKI_KARTA[@]};  STROKI_KARTA[$idx]="$ryad";  NOMER_KARTA[$idx]="$n" ;;
        Delta)  idx=${#STROKI_DELTA[@]};  STROKI_DELTA[$idx]="$ryad";  NOMER_DELTA[$idx]="$n" ;;
        *) otkaz "строка $n: ряд таблицы («- ») вне машинной секции: $line" ;;
    esac
done < "$LISTOK"

[ "${#STROKI_DVERI[@]}" -ge 1 ] || otkaz 'лист без секции «## Двери» (или в ней нет рядов)'
[ "${#STROKI_KARTA[@]}" -ge 1 ]  || otkaz 'лист без секции «## Карта классов» (или в ней нет рядов)'

# ── валидация рядов и сбор команд к прогону ───────────────────────────────────
KOMANDY=()          # тексты команд
OZHIDALI=()         # заявленный rc
GDE=()              # «строка N» для отказа
komanda_ok() { # $1 команда; rc 0 — существует и исполняема по алфавиту
    local first second
    first="$(printf '%s' "$1" | awk '{print $1}')"
    if [ "$first" = 'bash' ]; then
        second="$(printf '%s' "$1" | awk '{print $2}')"
        [ -n "$second" ] || return 1
        case "$second" in /*|*..*) return 1 ;; esac
        [[ "$second" =~ ^[A-Za-z0-9._/-]+[.][A-Za-z0-9]+$ ]] || return 1
        [ -f "$ROOT/$second" ] || return 1
        [ -r "$ROOT/$second" ] || return 1
    else
        case "$first" in /*|*..*) return 1 ;; esac
        [[ "$first" =~ ^[A-Za-z0-9._/-]+[.][A-Za-z0-9]+$ ]] || return 1
        [ -f "$ROOT/$first" ] || return 1
        [ -x "$ROOT/$first" ] || return 1
    fi
    return 0
}

for i in "${!STROKI_DVERI[@]}"; do
    ryad="${STROKI_DVERI[$i]}"; nom="${NOMER_DVERI[$i]}"
    razbit "$ryad"
    [ "${#CHASTI[@]}" -eq 4 ] || otkaz "строка $nom: ряд «Двери» вне грамматики (4 поля «имя · команда · rc · rc»): $ryad"
    imja="${CHASTI[0]}" komanda="${CHASTI[1]}" o1="${CHASTI[2]}" o2="${CHASTI[3]}"
    [ -n "$imja" ] && [ -n "$komanda" ] || otkaz "строка $nom: пустое поле в ряду «Двери»: $ryad"
    rc_ok "$o1" && rc_ok "$o2" || otkaz "строка $nom: rc вне алфавита 0..255: $ryad"
    [ "$o1" = "$o2" ] || otkaz "строка $nom: заявленные rc расходятся ($o1 ≠ $o2): $ryad"
    komanda_ok "$komanda" || otkaz "строка $nom: команда не существует (алфавит: bash <файл> | <файл>): $komanda"
    KOMANDY+=("$komanda"); OZHIDALI+=("$o1"); GDE+=("$nom")
done

declare -A KLASS_VIDEN=()
for i in "${!STROKI_KARTA[@]}"; do
    ryad="${STROKI_KARTA[$i]}"; nom="${NOMER_KARTA[$i]}"
    razbit "$ryad"
    [ "${#CHASTI[@]}" -eq 5 ] || otkaz "строка $nom: ряд «Карта классов» вне грамматики (5 полей «К-NN · статус · доказательство · rc · rc»): $ryad"
    klass="${CHASTI[0]}" status="${CHASTI[1]}" dok="${CHASTI[2]}" o1="${CHASTI[3]}" o2="${CHASTI[4]}"
    [[ "$klass" =~ ^К-(0[1-9]|1[0-7])$ ]] || otkaz "строка $nom: класс вне К-01…К-17: $klass"
    [ -z "${KLASS_VIDEN[$klass]:-}" ] || otkaz "строка $nom: дубль класса $klass в карте листа"
    KLASS_VIDEN[$klass]=1
    case "$status" in
        чисто)
            case "$dok" in
                'вход: '*) [ "$o1" = '-' ] && [ "$o2" = '-' ] || otkaz "строка $nom: поле «вход» несёт rc «-»: $ryad" ;;
                bash*|scripts/*|fixtures/*)
                    rc_ok "$o1" && rc_ok "$o2" || otkaz "строка $nom: rc вне алфавита 0..255: $ryad"
                    [ "$o1" = "$o2" ] || otkaz "строка $nom: заявленные rc расходятся: $ryad"
                    komanda_ok "$dok" || otkaz "строка $nom: команда не существует: $dok"
                    KOMANDY+=("$dok"); OZHIDALI+=("$o1"); GDE+=("$nom") ;;
                *) otkaz "строка $nom: $klass: чисто без команды или входа: $ryad" ;;
            esac ;;
        н/п) [ "$o1" = '-' ] && [ "$o2" = '-' ] || otkaz "строка $nom: «н/п» несёт rc «-»: $ryad"
             [ -n "$dok" ] || otkaz "строка $nom: «н/п» без причины: $ryad" ;;
        *) otkaz "строка $nom: статус листа вне алфавита (чисто|н/п): $status" ;;
    esac
done
for ((k = 1; k <= 17; k++)); do
    klass="$(printf 'К-%02d' "$k")"
    [ -n "${KLASS_VIDEN[$klass]:-}" ] || otkaz "карта листа неполна: нет $klass"
done

declare -A ZAKRYTO=()
for i in "${!STROKI_DELTA[@]}"; do
    ryad="${STROKI_DELTA[$i]}"; nom="${NOMER_DELTA[$i]}"
    razbit "$ryad"
    [ "${#CHASTI[@]}" -eq 5 ] || otkaz "строка $nom: ряд «Дельта» вне грамматики (5 полей «К-NN · способ · команда · rc · rc»): $ryad"
    klass="${CHASTI[0]}" sposob="${CHASTI[1]}" komanda="${CHASTI[2]}" o1="${CHASTI[3]}" o2="${CHASTI[4]}"
    [[ "$klass" =~ ^К-(0[1-9]|1[0-7])$ ]] || otkaz "строка $nom: класс вне К-01…К-17: $klass"
    case "$sposob" in
        снятие|граница|канон/инструмент|клетка) : ;;
        *) otkaz "строка $nom: способ закрытия вне алфавита (снятие|граница|канон/инструмент|клетка): $sposob" ;;
    esac
    rc_ok "$o1" && rc_ok "$o2" || otkaz "строка $nom: rc вне алфавита 0..255: $ryad"
    [ "$o1" = "$o2" ] || otkaz "строка $nom: заявленные rc расходятся: $ryad"
    komanda_ok "$komanda" || otkaz "строка $nom: команда не существует: $komanda"
    KOMANDY+=("$komanda"); OZHIDALI+=("$o1"); GDE+=("$nom")
    ZAKRYTO[$klass]="$sposob"
done

# ── покрытие дельты против карты предыдущего вердикта (И5) ────────────────────
if [ -n "$PRED_VERDIKT" ]; then
    put_ok "$PRED_VERDIKT" || otkaz "путь предыдущего вердикта вне грамматики: $PRED_VERDIKT"
    telo="$(git -C "$ROOT" cat-file -p "HEAD:$PRED_VERDIKT" 2>/dev/null)" \
        || otkaz "предыдущий вердикт не закоммичен (AGENTS п.9): $PRED_VERDIKT"
    [ -n "$telo" ] || otkaz "предыдущий вердикт не закоммичен (AGENTS п.9): $PRED_VERDIKT"
    SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
    # shellcheck disable=SC1091
    [ -r "$SELF_DIR/lib_karta_sdachi.sh" ] || ni 'нет lib_karta_sdachi.sh рядом с дверью'
    . "$SELF_DIR/lib_karta_sdachi.sh"
    spisok="$(karta_proverit "$telo" "$ROOT" "$PRED_VERDIKT")" || otkaz "предыдущий вердикт: $spisok"
    poslednij="$(karta_poslednij_fail "$ROOT" "$PRED_VERDIKT" "$telo")" \
        || otkaz "последний FAIL: $poslednij"
    spisok="$spisok"$'\n'"$poslednij"
    while IFS=$'\t' read -r klass status; do
        [ -n "$klass" ] || continue
        [ "$status" = 'блок' ] || continue
        [ -n "${ZAKRYTO[$klass]:-}" ] || otkaz "блок $klass предыдущего вердикта не закрыт в «## Дельта»"
    done <<< "$spisok"
fi

# ── прогон команд (бюджет; маркер рекурсии) ──────────────────────────────────
# Бюджет листа (К-07 Crit193V1) ограничивает и ВЫПОЛНЯЮЩУЮСЯ команду: предельное
# время команды — минимум её таймаута и остатка бюджета листа; убийство по
# остатку бюджета — отказ «бюджет … исчерпан», по таймауту команды — «таймаут».
start="$SECONDS"
for i in "${!KOMANDY[@]}"; do
    ostalos=$(( BUDZHET_SEK - (SECONDS - start) ))
    (( ostalos > 0 )) || otkaz "бюджет листа $BUDZHET_SEK исчерпан (строка ${GDE[$i]})"
    predel="$TIMEOUT_SEK"
    (( ostalos < predel )) && predel="$ostalos"
    fact=0
    # И3: алфавит команды — `bash <файл> [аргументы]` либо исполняемый
    # <файл> [аргументы]; разбор по словам и запуск ПРЯМЫМ argv без
    # оболочки: хвост ряда («|| true», «; exit 0») остаётся литеральными
    # аргументами, оператором shell не исполняется и rc не маскирует (Б-3).
    read -r -a ARGV <<< "${KOMANDY[$i]}"
    # TERM по predel; пережившего TERM добивает SIGKILL через KILL_SEK —
    # дверь обязана завершаться в пределах бюджета листа + KILL_SEK (Б-4).
    ( cd "$ROOT" && SDACHA_OKRUG=1 timeout -k "$KILL_SEK" "$predel" "${ARGV[@]}" ) >/dev/null 2>&1 || fact=$?
    if [ "$fact" -eq 124 ]; then
        if (( TIMEOUT_SEK <= ostalos )); then
            otkaz "строка ${GDE[$i]}: таймаут $TIMEOUT_SEK с команды: ${KOMANDY[$i]}"
        fi
        otkaz "строка ${GDE[$i]}: бюджет листа $BUDZHET_SEK исчерпан на команде: ${KOMANDY[$i]}"
    fi
    if [ "$fact" -eq 137 ]; then
        if (( TIMEOUT_SEK <= ostalos )); then
            otkaz "строка ${GDE[$i]}: таймаут $TIMEOUT_SEK с команды — убита SIGKILL по -k (rc=137): ${KOMANDY[$i]}"
        fi
        otkaz "строка ${GDE[$i]}: бюджет листа $BUDZHET_SEK исчерпан на команде — убита SIGKILL по -k (rc=137): ${KOMANDY[$i]}"
    fi
    [ "$fact" = "${OZHIDALI[$i]}" ] || otkaz "строка ${GDE[$i]}: фактический rc=$fact ≠ заявленного ${OZHIDALI[$i]}: ${KOMANDY[$i]}"
done

printf 'СДАЧА: лист зелёный (двери=%d карта=17/17 дельта=%d)\n' \
    "${#STROKI_DVERI[@]}" "${#STROKI_DELTA[@]}"
exit 0
