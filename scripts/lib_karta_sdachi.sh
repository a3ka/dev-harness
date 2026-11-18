#!/usr/bin/env bash
# lib_karta_sdachi.sh — ЕДИНЫЙ ИСТОЧНИК грамматики секции «## Карта классов»
# вердикта критика (контракт 193, Л2). Оба потребителя — scripts/check_verdict_karta.sh
# и scripts/check_sdacha.sh (покрытие дельты) — source этот файл; переизобретение
# грамматики в потребителе запрещено (норма единого источника, контракт 193 И7).
#
# НЕ БАРЬЕР: общая библиотека грамматики секции «## Карта классов» (И7) —
# подключается (source) из scripts/check_sdacha.sh и scripts/check_verdict_karta.sh,
# сама не исполняется и кодов возврата не объявляет.
#
# Грамматика (заморожена нормой critic 192/1, roles/critic.md §Связка с автором):
#   секция  — строка, ровно равная «## Карта классов»;
#   строка  — «К-NN: СТАТУС — ХВОСТ», СТАТУС ∈ {чисто, блок, н/п}, ХВОСТ непуст
#             (после снятия хвостовых пробелов); «чисто» без хвоста — отказ
#             «чисто без команды или входа»;
#   классов — ровно К-01…К-17, каждый ровно один раз;
#   строки класса вне секции не судятся (проза вердикта вправе упоминать К-NN).
#
# karta_proverit <текст-вердикта>
#   rc 0 — карта валидна; stdout: 17 строк «К-NN<TAB>СТАТУС»;
#   rc 1 — stdout: одна строка — именованная первая ошибка.

karta_proverit() { # $1 = текст вердикта целиком
    local v_sekcii=0 videl=() klass status hvost rest stroka i
    local -A vidennye=()
    while IFS= read -r stroka || [ -n "$stroka" ]; do
        stroka="${stroka%$'\r'}"
        if [ "$stroka" = '## Карта классов' ]; then
            [ "$v_sekcii" -eq 0 ] || { printf 'дубль секции «## Карта классов»'; return 1; }
            v_sekcii=1
            continue
        fi
        case "$stroka" in
            '## '*) v_sekcii=0 ;;
        esac
        [ "$v_sekcii" -eq 1 ] || continue
        if [[ "$stroka" =~ ^К-[0-9][0-9] ]]; then
            case "$stroka" in
                'К-'*': '*) : ;;
                *) printf 'строка класса вне грамматики «К-NN: статус — хвост»: %s' "$stroka"; return 1 ;;
            esac
        fi
        case "$stroka" in
            'К-'*': '*)
                klass="${stroka%%:*}"
                if [[ ! "$klass" =~ ^К-(0[1-9]|1[0-7])$ ]]; then
                    printf 'класс вне К-01…К-17: %s' "$klass"
                    return 1
                fi
                if [ -n "${vidennye[$klass]:-}" ]; then
                    printf 'дубль класса: %s' "$klass"
                    return 1
                fi
                vidennye[$klass]=1
                rest="${stroka#*: }"
                case "$rest" in
                    'чисто — '|'блок — '|'н/п — '|'чисто —'|'блок —'|'н/п —')
                        printf '%s: %s без команды или входа' "$klass" "${rest%% — *}"
                        return 1 ;;
                    'чисто — '*|'блок — '*|'н/п — '*) : ;;
                    *) printf 'статус вне алфавита (чисто|блок|н/п) или нет « — »: %s' "$stroka"; return 1 ;;
                esac
                status="${rest%% — *}"
                hvost="${rest#* — }"
                hvost="${hvost%"${hvost##*[![:space:]]}"}"
                if [ -z "$hvost" ]; then
                    printf '%s: %s без команды или входа' "$klass" "$status"
                    return 1
                fi
                videl+=("$klass"$'\t'"$status")
                ;;
        esac
    done <<< "$1"
    local netu=''
    for ((i = 1; i <= 17; i++)); do
        klass="$(printf 'К-%02d' "$i")"
        [ -n "${vidennye[$klass]:-}" ] || netu="$netu $klass"
    done
    if [ "${#videl[@]}" -ne 17 ] || [ -n "$netu" ]; then
        printf 'карта %d строк: нет:%s' "${#videl[@]}" "${netu:- <дубли>}"
        return 1
    fi
    printf '%s\n' "${videl[@]}"
    return 0
}
