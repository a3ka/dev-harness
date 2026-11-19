#!/usr/bin/env bash
# lib_karta_sdachi.sh — ЕДИНЫЙ ИСТОЧНИК грамматики секции «## Карта классов»
# вердикта критика (контракт 193, Л2). Оба потребителя — scripts/check_verdict_karta.sh
# и scripts/check_sdacha.sh (покрытие дельты) — source этот файл; переизобретение
# грамматики в потребителе запрещено (норма единого источника, контракт 193 И7).
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

karta_stroki() { # Синтаксис один для обеих дверей и исторических карт.
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
                    'без изменений с вызова '*|'без изменений с предыдущего вызова'*)
                        if [[ "$rest" =~ ^без\ изменений\ с\ вызова\ ([0-9]+)([.]|\ —\ .+)?$ ]]; then
                            status="${BASH_REMATCH[1]}"
                            while [[ "$status" == 0* ]]; do status="${status#0}"; done
                            [ -n "$status" ] || { printf '%s: номер вызова вне грамматики' "$klass"; return 1; }
                        elif [[ "$rest" =~ ^без\ изменений\ с\ предыдущего\ вызова([.]|\ —\ .+)?$ ]]; then
                            status="$(karta_predydushchij "$1")" \
                                || { printf '%s: %s' "$klass" "$status"; return 1; }
                        else
                            printf '%s: ссылка вне грамматики' "$klass"; return 1
                        fi
                        videl+=("$klass"$'\t'"ссылка:$status")
                        continue ;;
                    'чисто — '*|'блок — '*|'н/п — '*) : ;;
                    *) printf 'статус вне алфавита (чисто|блок|н/п|ссылка) или нет « — »: %s' "$stroka"; return 1 ;;
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

# Индекс только достижимых из HEAD артефактов той же темы и роли.
# OBJECT — историческая запись, а НЕ ревизия, откуда следует читать карту.
karta_metadannye() {
    local stroka pole
    K193_TEMA='' K193_VYZOV='' K193_ROL=''
    while IFS= read -r stroka; do
        [[ "$stroka" == 'СУД: '* ]] || continue
        stroka="${stroka#СУД: }"
        local -a polja=()
        IFS=';' read -r -a polja <<< "$stroka"
        for pole in "${polja[@]}"; do
            pole="${pole#"${pole%%[![:space:]]*}"}"
            if [[ "$pole" =~ ^предмет=([0-9]+)$ ]]; then K193_TEMA="${BASH_REMATCH[1]}"; fi
            if [[ "$pole" =~ ^роль=critic$ ]]; then K193_ROL=critic; fi
            if [[ "$pole" =~ ^вызов=([0-9]+)([^0-9].*)?$ ]]; then
                K193_VYZOV="${BASH_REMATCH[1]}"
                while [[ "$K193_VYZOV" == 0* ]]; do K193_VYZOV="${K193_VYZOV#0}"; done
            fi
        done
    done <<< "$1"
}

karta_predydushchij() { # N−1 именно источника строки, не последнего вызова/HEAD.
    local nom nuli='' cifra
    karta_metadannye "$1"
    [ "$K193_ROL" = critic ] && [ -n "$K193_VYZOV" ] \
        || { printf 'предыдущий вызов требует СУД с роль=critic и номером вызова'; return 1; }
    [ "$K193_VYZOV" != 1 ] || { printf 'у вызова 1 нет предыдущего вызова'; return 1; }
    nom="$K193_VYZOV"
    # Номер — десятичная строка без ограничения разрядностью bash.
    while [[ "$nom" == *0 ]]; do nom="${nom%0}"; nuli="${nuli}9"; done
    cifra="${nom: -1}"
    nom="${nom%?}$((cifra - 1))$nuli"
    while [[ "$nom" == 0* ]]; do nom="${nom#0}"; done
    printf '%s' "$nom"
}

karta_index() { # ROOT, путь предъявленного вердикта, его неизменённый текст
    local root="$1" put="$2" tema commit f blob telo nom commits files
    karta_metadannye "$3"
    tema="$K193_TEMA"
    K193_POSLED_FAIL=''
    declare -gA K193_TEKST=() K193_BLOB=()
    [ -n "$tema" ] && [ "$K193_ROL" = critic ] || return 0
    local -A videli=()
    commits="$(git -C "$root" rev-list HEAD -- "${put%/*}/")" || return 1
    for commit in $commits; do
        files="$(git -C "$root" ls-tree -r --name-only "$commit" -- "${put%/*}/")" || return 1
        while IFS= read -r f; do
            [[ "$f" == *.md ]] || continue
            blob="$(git -C "$root" rev-parse "$commit:$f" 2>/dev/null)" || continue
            [ -z "${videli[$blob]:-}" ] || continue
            videli[$blob]=1
            telo="$(git -C "$root" cat-file -p "$blob")" || return 1
            karta_metadannye "$telo"
            [ "$K193_TEMA" = "$tema" ] && [ "$K193_ROL" = critic ] \
                && [ -n "$K193_VYZOV" ] || continue
            nom="$K193_VYZOV"
            if [ -n "${K193_BLOB[$nom]:-}" ] && [ "${K193_BLOB[$nom]}" != "$blob" ]; then
                printf 'неоднозначный вызов %s' "$nom"; return 1
            fi
            K193_BLOB[$nom]="$blob"
            K193_TEKST[$nom]="$telo"
            if [ "${telo%%$'\n'*}" = FAIL ]; then
                if [ "${#nom}" -gt "${#K193_POSLED_FAIL}" ] \
                    || { [ "${#nom}" -eq "${#K193_POSLED_FAIL}" ] && [[ "$nom" > "$K193_POSLED_FAIL" ]]; }; then
                    K193_POSLED_FAIL="$nom"
                fi
            fi
        done <<< "$files"
    done
}

karta_klass() { # класс, статус, стек пар вызов:класс; индекс уже в памяти
    local klass="$1" status="$2" stek="$3" nom ryady k s
    case "$status" in
        ссылка:*)
            nom="${status#ссылка:}"
            case "$stek" in
                *"|$nom:$klass|"*) printf 'цикл ссылок: %s вызов %s' "$klass" "$nom"; return 1 ;;
            esac
            [ -n "${K193_TEKST[$nom]:-}" ] || { printf 'отсутствует вызов %s (%s)' "$nom" "$klass"; return 1; }
            ryady="$(karta_stroki "${K193_TEKST[$nom]}")" || { printf 'вызов %s: %s' "$nom" "$ryady"; return 1; }
            while IFS=$'\t' read -r k s; do
                [ "$k" = "$klass" ] || continue
                karta_klass "$klass" "$s" "$stek|$nom:$klass|"
                return $?
            done <<< "$ryady"
            printf 'вызов %s: нет %s' "$nom" "$klass"; return 1 ;;
        *) printf '%s' "$status" ;;
    esac
}

karta_raskryt() {
    local ryady="$1" klass status resolved result=()
    while IFS=$'\t' read -r klass status; do
        resolved="$(karta_klass "$klass" "$status" '')" || { printf '%s' "$resolved"; return 1; }
        result+=("$klass"$'\t'"$resolved")
    done <<< "$ryady"
    printf '%s\n' "${result[@]}"
}

karta_proverit() { # текст; необязательные ROOT и путь для ссылок
    local ryady
    ryady="$(karta_stroki "$1")" || { printf '%s' "$ryady"; return 1; }
    if [[ "$ryady" == *$'\tссылка:'* ]]; then
        [ "$#" -eq 3 ] || { printf 'ссылка требует закоммиченного контекста'; return 1; }
        karta_index "$2" "$3" "$1" || return 1
        karta_raskryt "$ryady"
    else
        printf '%s\n' "$ryady"
    fi
}

karta_poslednij_fail() { # ROOT, путь, текст; полный последний FAIL, не указанный старый accept
    karta_index "$1" "$2" "$3" || return 1
    [ -n "$K193_POSLED_FAIL" ] || return 0
    local ryady
    ryady="$(karta_stroki "${K193_TEKST[$K193_POSLED_FAIL]}")" \
        || { printf 'последний FAIL %s: %s' "$K193_POSLED_FAIL" "$ryady"; return 1; }
    karta_raskryt "$ryady"
}
