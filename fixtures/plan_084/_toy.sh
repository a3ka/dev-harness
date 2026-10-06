# fixtures/plan_084/_toy.sh — каркас toy-миров семьи plan_084 (контракт 084 «реестр плана»).
#
# Имя НЕ red_*/case_*: сам он фикстурой не является. Подключают его раннер
# fixtures/_krasnye_084.sh (список субъектов), батарея red_plan_084.sh и профиль гигиены
# парсинга fixtures/parsing_hygiene_battery/profiles/check_plan.sh. При подключении —
# только определения, побочных действий нет (раннер обязан уложиться в <1 с, урок Н-198).
#
# ЧТО ДАЁТ:
#  * P84_SUBJECTS — ЕДИНСТВЕННЫЙ список «предмет присутствует» (§Приёмка 084: четыре
#    скрипта); раннер и батарея читают его отсюда, второй копии списка нет.
#  * Константы грамматики — побайтово из контракта 084 (И-1, И-4, И-5, И-8, И-9); батарея и
#    профиль несут их отсюда, переизобретение запрещено.
#  * МОДЕЛЬ МИРА В ПАМЯТИ (W_*): строки плана в порядке файла, статусы (теги/закрытые),
#    реестр, заголовки контрактов. Файлы toy пишутся ИЗ модели; оракул И-3/И-4/И-5/И-8/И-9
#    считается ИЗ ТОЙ ЖЕ модели (строк батареи), а НЕ вызовом lib_plan.sh и не чтением
#    toy-диска обратно (правило 8: ожидание — в памяти проверяющего ДО вызова субъекта).
#  * Построитель toy-репозитория p84_build — конформный вход по И-1/И-2 (демаркация §Приёмка):
#    теги frozen|done/contracts/NNN/*, closed-without-done.tsv «NNN⇥причина»,
#    docs/owner/*.md с заголовками-разделами, registry/contracts.tsv «NNN → <sha>».
#  * p84_py — байтовые операции над файлами toy (блоки между маркерами, порча байта,
#    вставка строки) и сверка коммита переноса И-12 с таблицей §Перенос (ж6, режим
#    `red_plan_084.sh --perenos`) — python3, чтобы перевод строки и UTF-8 не терялись в $(…).
#
# ГЕРМЕТИЧНОСТЬ: каждый git-вызов каркаса — с GIT_CONFIG_GLOBAL/SYSTEM=/dev/null и identity
# через -c. Identity в ФАЙЛ конфига toy НЕ пишется: хук-клетки (в1/в2) коммитят через
# настоящий pre-commit → check_staged.sh, а он отказывает при user.name/user.email в общем
# .git/config (нога (д') 080). Миры заморозки (ф*) строит make_repo семьи freeze_contract —
# там identity в конфиге нужна самому freeze (git tag -a без -c, Н-12), хука там нет.

P84_SUBJECTS=(scripts/lib_plan.sh scripts/gen_plan.sh scripts/check_plan.sh scripts/track_digest.sh)

# p84_missing_subjects <корень> — печатает через пробел отсутствующие субъекты (пусто — все есть).
p84_missing_subjects() {
  local root="$1" s miss=''
  for s in "${P84_SUBJECTS[@]}"; do
    [ -f "$root/$s" ] || miss="$miss $s"
  done
  printf '%s' "${miss# }"
}

# ── Грамматика контракта 084 (побайтово) ────────────────────────────────────────────────
P84_HDR=$'id\tпара\tэтап\tзависит\tисточник\tтрек'
P84_STAGE_A='до V-2'
P84_STAGE_B='параллельно с V-2'
P84_RM_BEGIN='<!-- BEGIN GENERATED PLAN -->'
P84_RM_END='<!-- END GENERATED PLAN -->'
P84_HO_BEGIN='<!-- BEGIN GENERATED NEXT SESSION -->'
P84_HO_END='<!-- END GENERATED NEXT SESSION -->'
P84_RM_TITLE='**Итоговый порядок** (генерируется из registry/plan.tsv: bash scripts/gen_plan.sh --write; правка — строкой плана)'
P84_RM_THEAD='| пара | id | этап | трек | зависит | источник |'
P84_RM_TSEP='|---|---|---|---|---|---|'
P84_HO_TITLE='## Следующая сессия (генерируется: bash scripts/gen_plan.sh --write)'
P84_HO_EMPTY='- нет пунктов: всё закрыто или зависимости открыты'
P84_ST_DONE='done'
P84_ST_CLOSED='закрыт без done'
P84_ST_FROZEN='заморожен'
P84_ST_ISSUED='номер выдан'
P84_ST_NEW='не начат'
P84_FREEZE_SKIP='  ok   план не заведён: проверка «вне плана» не применяется'
P84_PHRASE='Итоговый порядок'
# Перенос И-12 (ж6): контракт с таблицей, её раздел, переименование прозаических пунктов, §11.
P84_CONTRACT='contracts/084-reestr-plana.md'
P84_PERENOS_H='## Перенос'
P84_OLD_ORDER='Итоговый порядок Odelix'
P84_NEW_ORDER='Обоснование порядка Odelix'
P84_S11='## 11.'

# ── Случайность: результат — в глобальной переменной (без подоболочек) ──────────────────
p84_rnd() { P84_R=$(( (RANDOM * 32768 + RANDOM) % $1 )); }          # 0..N-1
p84_pick() { local a=("$@"); p84_rnd "${#a[@]}"; P84_P="${a[$P84_R]}"; } # случайный элемент
p84_sfx() {  # [<длина>=3] — [a-y0-9]{n}, первая — буква (годится хвостом любого id/трека)
  local n="${1:-3}" a='abcdefghijklmnopqrstuvwxy0123456789' s i
  p84_rnd 25; s="${a:$P84_R:1}"
  for ((i = 1; i < n; i++)); do p84_rnd 35; s+="${a:$P84_R:1}"; done
  P84_S="$s"
}
p84_hex() {  # <длина> — случайные hex-символы
  local n="$1" a='0123456789abcdef' s='' i
  for ((i = 0; i < n; i++)); do p84_rnd 16; s+="${a:$P84_R:1}"; done
  P84_H="$s"
}
declare -gA P84_USED=()
p84_num() {  # уникальный в мире номер 900–979 (демаркация §Приёмка)
  local n
  while :; do p84_rnd 80; n=$((900 + P84_R)); [ -z "${P84_USED[$n]+x}" ] && break; done
  P84_USED[$n]=1; P84_N="$n"
}
p84_sec() {  # уникальный в мире раздел «a.b» (a 1–19, b 1–9)
  local s
  while :; do p84_rnd 19; s="$((P84_R + 1))"; p84_rnd 9; s="$s.$((P84_R + 1))"
    [ -z "${P84_USED["sec:$s"]+x}" ] && break; done
  P84_USED["sec:$s"]=1; P84_SEC="$s"
}
P84_WORDS=(план порядок пара этап трек реестр источник раздел замер контур кольцо заморозка
  слово владельца сессия батарея toy prose lane runner gate drill судья критик исполнитель)
p84_prose() {  # <число строк> — случайная проза (без «Итоговый порядок» и без маркеров)
  local n="$1" i k line
  for ((i = 0; i < n; i++)); do
    line=''; p84_rnd 6
    for ((k = 0; k < P84_R + 3; k++)); do p84_pick "${P84_WORDS[@]}"; line+="$P84_P "; done
    p84_sfx 4; printf '%s%s.\n' "$line" "$P84_S"
  done
}

# ── Модель мира ────────────────────────────────────────────────────────────────────────
# W_ID/W_PAIR/W_STAGE/W_DEPS/W_SRC/W_TRACK — строки плана в порядке файла.
# W_SRC_SPEC — источник до разрешения: «@sha:<длина>» → первые <длина> hex коммита-основания
# (обе формы источника И-1); прочее — как есть. W_DONE/W_FROZEN — номера с тегом
# done/frozen; W_CLOSED — номер → причина (closed-without-done.tsv); W_H1 — номер →
# заголовок H1 файла contracts/<номер>-*.md (нет ключа — нет файла); W_REG — номер → sha
# строки registry/contracts.tsv, W_REG_ORDER — порядок строк реестра.
p84_world_reset() {
  W_ID=(); W_PAIR=(); W_STAGE=(); W_DEPS=(); W_SRC=(); W_SRC_SPEC=(); W_TRACK=()
  declare -gA W_DONE=() W_FROZEN=() W_CLOSED=() W_H1=() W_REG=()
  W_REG_ORDER=(); W_CLOSED_ORDER=()
  W_MISS_DOC=''; W_MISS_SEC=''
  W_RM_MODE=block; W_HO_MODE=block
  declare -gA P84_USED=()
}
p84_row() {  # <id> <пара> <этап> <зависит> <источник-spec> <трек>
  W_ID+=("$1"); W_PAIR+=("$2"); W_STAGE+=("$3"); W_DEPS+=("$4"); W_SRC_SPEC+=("$5"); W_SRC+=("$5"); W_TRACK+=("$6")
}
p84_is_num() { case "$1" in [0-9][0-9][0-9]) return 0 ;; *) return 1 ;; esac; }
p84_idx_of() {  # <id> → P84_I (индекс строки) | rc 1
  local i
  for i in "${!W_ID[@]}"; do [ "${W_ID[$i]}" = "$1" ] && { P84_I="$i"; return 0; }; done
  return 1
}
p84_reg_add() {  # <номер> [<sha>] — строка реестра для номера
  local sha="${2:-}"
  [ -n "$sha" ] || { p84_hex 40; sha="$P84_H"; }
  [ -n "${W_REG[$1]+x}" ] || W_REG_ORDER+=("$1")
  W_REG[$1]="$sha"
}
p84_closed_add() {  # <номер> <причина>
  [ -n "${W_CLOSED[$1]+x}" ] || W_CLOSED_ORDER+=("$1")
  W_CLOSED[$1]="$2"
}
p84_closed_write() {  # <файл> — closed-without-done.tsv из модели: «NNN⇥причина» в порядке добавления
  local id
  : > "$1"
  for id in "${W_CLOSED_ORDER[@]}"; do printf '%s\t%s\n' "$id" "${W_CLOSED[$id]}" >> "$1"; done
}
p84_h1_add() {  # <номер> — заголовок H1 со «#», «:», «—» ВНУТРИ (снимается только ведущий «# »)
  p84_sfx 3; W_H1[$1]="Контракт $1 — предмет $P84_S: «реестр» #$((RANDOM % 90 + 10))"
}

# ── Оракул (из модели; НЕ lib_plan.sh) ──────────────────────────────────────────────────
o_status() {  # <id> → P84_ST (И-2: первый совпавший)
  local id="$1"
  if p84_is_num "$id"; then
    if [ -n "${W_DONE[$id]+x}" ]; then P84_ST="$P84_ST_DONE"
    elif [ -n "${W_CLOSED[$id]+x}" ]; then P84_ST="$P84_ST_CLOSED"
    elif [ -n "${W_FROZEN[$id]+x}" ]; then P84_ST="$P84_ST_FROZEN"
    else P84_ST="$P84_ST_ISSUED"; fi
  else
    P84_ST="$P84_ST_NEW"
  fi
}
o_closed() { o_status "$1"; [ "$P84_ST" = "$P84_ST_DONE" ] || [ "$P84_ST" = "$P84_ST_CLOSED" ]; }
o_order() {  # индексы строк в порядке (пара числом, порядок файла) — в массив P84_ORDER
  local i p
  P84_ORDER=()
  while IFS=$'\t' read -r p i; do P84_ORDER+=("$i"); done < <(
    for i in "${!W_ID[@]}"; do printf '%d\t%d\n' "${W_PAIR[$i]}" "$i"; done | LC_ALL=C sort -t$'\t' -k1,1n -k2,2n)
}
o_roadmap_block() {  # И-4: строки между маркерами ROADMAP
  local i
  o_order
  printf '%s\n\n%s\n%s\n' "$P84_RM_TITLE" "$P84_RM_THEAD" "$P84_RM_TSEP"
  for i in "${P84_ORDER[@]}"; do
    printf '| %s | %s | %s | %s | %s | %s |\n' "${W_PAIR[$i]}" "${W_ID[$i]}" "${W_STAGE[$i]}" \
      "${W_TRACK[$i]}" "${W_DEPS[$i]}" "${W_SRC[$i]}"
  done
}
o_deps_closed() {  # <поле зависит> — каждая зависимость закрыта
  local dep deps
  [ "$1" = - ] && return 0
  IFS=, read -r -a deps <<< "$1"
  for dep in "${deps[@]}"; do o_closed "$dep" || return 1; done
  return 0
}
o_next_session() {  # И-5: индексы выбора в массив P84_NEXT (A, затем E)
  local i k A=() E=()
  o_order
  for i in "${P84_ORDER[@]}"; do o_status "${W_ID[$i]}"; [ "$P84_ST" = "$P84_ST_FROZEN" ] && A+=("$i"); done
  k=$((2 - ${#A[@]})); [ "$k" -ge 0 ] || k=0
  for i in "${P84_ORDER[@]}"; do
    [ "${#E[@]}" -lt "$k" ] || break
    o_status "${W_ID[$i]}"
    case "$P84_ST" in "$P84_ST_ISSUED"|"$P84_ST_NEW") ;; *) continue ;; esac
    o_deps_closed "${W_DEPS[$i]}" && E+=("$i")
  done
  P84_NEXT=("${A[@]}" "${E[@]}")
}
o_handoff_block() {  # И-5: строки между маркерами HANDOFF
  local i
  o_next_session
  printf '%s\n\n' "$P84_HO_TITLE"
  if [ "${#P84_NEXT[@]}" -eq 0 ]; then printf '%s\n' "$P84_HO_EMPTY"; return 0; fi
  for i in "${P84_NEXT[@]}"; do
    o_status "${W_ID[$i]}"
    printf -- '- %s · пара %s · %s · трек %s\n' "${W_ID[$i]}" "${W_PAIR[$i]}" "$P84_ST" "${W_TRACK[$i]}"
  done
}
o_digest() {  # <трек> — И-9: stdout track_digest.sh
  local t="$1" i n id
  o_order
  printf '# трек %s\n' "$t"
  printf '## done\n'; n=0
  for i in "${P84_ORDER[@]}"; do
    [ "${W_TRACK[$i]}" = "$t" ] || continue
    id="${W_ID[$i]}"; o_status "$id"; [ "$P84_ST" = "$P84_ST_DONE" ] || continue
    if [ -n "${W_H1[$id]+x}" ]; then printf -- '- %s — %s\n' "$id" "${W_H1[$id]}"
    else printf -- '- %s — файл контракта отсутствует\n' "$id"; fi
    n=$((n + 1))
  done
  [ "$n" -gt 0 ] || printf -- '- нет\n'
  printf '## заморожено, не done\n'; n=0
  for i in "${P84_ORDER[@]}"; do
    [ "${W_TRACK[$i]}" = "$t" ] || continue
    id="${W_ID[$i]}"; o_status "$id"
    case "$P84_ST" in
      "$P84_ST_FROZEN") printf -- '- %s — заморожен\n' "$id" ;;
      "$P84_ST_CLOSED") printf -- '- %s — закрыт без done: %s\n' "$id" "${W_CLOSED[$id]}" ;;
      *) continue ;;
    esac
    n=$((n + 1))
  done
  [ "$n" -gt 0 ] || printf -- '- нет\n'
  printf '## в работе\n'; n=0
  for i in "${P84_ORDER[@]}"; do
    [ "${W_TRACK[$i]}" = "$t" ] || continue
    o_status "${W_ID[$i]}"; [ "$P84_ST" = "$P84_ST_ISSUED" ] || continue
    printf -- '- %s\n' "${W_ID[$i]}"; n=$((n + 1))
  done
  [ "$n" -gt 0 ] || printf -- '- нет\n'
  printf '## запланировано, не начато\n'; n=0
  for i in "${P84_ORDER[@]}"; do
    [ "${W_TRACK[$i]}" = "$t" ] || continue
    o_status "${W_ID[$i]}"; [ "$P84_ST" = "$P84_ST_NEW" ] || continue
    printf -- '- %s\n' "${W_ID[$i]}"; n=$((n + 1))
  done
  [ "$n" -gt 0 ] || printf -- '- нет\n'
}
o_p0p1() {  # И-3: P84_P0/P84_P1 по открытым строкам модели («нет», если отсутствует)
  local i p
  P84_P0=''; P84_P1=''
  for i in "${!W_ID[@]}"; do
    o_closed "${W_ID[$i]}" && continue
    p="${W_PAIR[$i]}"
    if [ -z "$P84_P0" ] || [ "$p" -lt "$P84_P0" ]; then P84_P0="$p"; fi
  done
  if [ -n "$P84_P0" ]; then
    for i in "${!W_ID[@]}"; do
      o_closed "${W_ID[$i]}" && continue
      p="${W_PAIR[$i]}"
      [ "$p" -gt "$P84_P0" ] || continue
      if [ -z "$P84_P1" ] || [ "$p" -lt "$P84_P1" ]; then P84_P1="$p"; fi
    done
  fi
  [ -n "$P84_P0" ] || P84_P0='нет'
  [ -n "$P84_P1" ] || P84_P1='нет'
}
o_freeze_refusal() {  # <NNN> — дословная строка отказа И-8 (stderr freeze_contract.sh, die)
  o_p0p1
  printf 'ОТКАЗ: контракт вне плана: %s — не в текущей/следующей паре registry/plan.tsv (P0 %s, P1 %s)' \
    "$1" "$P84_P0" "$P84_P1"
}

# ── Текст plan.tsv из модели (с одной порчей или без) ────────────────────────────────────
p84_join_tab() { local IFS=$'\t'; printf '%s\n' "$*"; }
# p84_emit_plan [set <индекс> <поле 0-5> <значение> | drop <индекс> <поле 0-5>
#                | blank <номер строки файла> | header <текст заголовка> | only-header]
# Номер строки файла у строки модели с индексом i — i+2 (строка 1 — заголовок).
p84_emit_plan() {
  local mode="${1:-}" j="${2:--1}" f="${3:-0}" v="${4:-}" i ln=1 hdr="$P84_HDR" F
  [ "$mode" = header ] && hdr="$j"
  printf '%s\n' "$hdr"
  [ "$mode" = only-header ] && return 0
  for i in "${!W_ID[@]}"; do
    ln=$((ln + 1))
    if [ "$mode" = blank ] && [ "$ln" -eq "$j" ]; then printf '\n'; ln=$((ln + 1)); fi
    F=("${W_ID[$i]}" "${W_PAIR[$i]}" "${W_STAGE[$i]}" "${W_DEPS[$i]}" "${W_SRC[$i]}" "${W_TRACK[$i]}")
    if [ "$mode" = set ] && [ "$i" -eq "$j" ]; then F[$f]="$v"; fi
    if [ "$mode" = drop ] && [ "$i" -eq "$j" ]; then F=("${F[@]:0:$f}" "${F[@]:$((f + 1))}"); fi
    p84_join_tab "${F[@]}"
  done
  if [ "$mode" = blank ] && [ "$j" -eq $((ln + 1)) ]; then printf '\n'; fi
  return 0
}

# ── Построитель toy-репозитория ─────────────────────────────────────────────────────────
p84_g() {  # <корень> <git…> — герметичный git каркаса; хуки ВЫКЛЮЧЕНЫ (настройка мира)
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$r" -c user.name=Фикстура -c user.email=fixture@local \
        -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}
p84_g_hooked() {  # <корень> <git…> — тот же git, но хук toy (core.hooksPath из конфига) ЖИВ
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$r" -c user.name=Фикстура -c user.email=fixture@local -c commit.gpgsign=false "$@"
}
p84_tag() { p84_g "$1" tag -a "$2" -m "фикстура 084: $2"; }        # <корень> <ref>
p84_commit() { p84_g "$1" add -A && p84_g "$1" commit -q -m "$2"; }   # <корень> <сообщение>

p84_docs_write() {  # <корень> — docs/owner/*.md: заголовок на КАЖДЫЙ раздел источников модели
  # Формы заголовка ПЕРЕБИРАЮТСЯ по кругу (не случайно): уровни «#»…«####» и три терминатора
  # раздела И-7(3) — пробел, «.», конец строки; мир с ≥4 разделами несёт их все в КАЖДОМ прогоне.
  local r="$1" i src doc sec lvl term d cnt=0
  local terms=(' Заголовок раздела' '. Заголовок с точкой' '')
  local -A body=()
  for i in "${!W_SRC_SPEC[@]}"; do
    src="${W_SRC_SPEC[$i]}"
    case "$src" in docs/owner/*.md\#*) ;; *) continue ;; esac
    doc="${src%%#*}"; sec="${src#*#}"
    lvl='#'; while [ "${#lvl}" -le $((cnt % 4)) ]; do lvl+='#'; done
    term="${terms[$((cnt % 3))]}"; cnt=$((cnt + 1))
    body[$doc]+="$lvl $sec$term"$'\n'"$(p84_prose 1)"$'\n'
  done
  if [ -n "$W_MISS_DOC" ]; then  # раздел W_MISS_SEC, которого НЕТ: только околозаголовки (и2)
    d="${W_MISS_SEC%%.*}x${W_MISS_SEC#*.}"
    body[$W_MISS_DOC]+="## ${W_MISS_SEC}7 Ловушка: продолжение числа"$'\n'
    body[$W_MISS_DOC]+="### $d Ловушка: точка как любой символ"$'\n'
    body[$W_MISS_DOC]+="Проза ссылается на ${W_MISS_SEC} внутри строки."$'\n'
    body[$W_MISS_DOC]+="##${W_MISS_SEC} без пробела после решёток"$'\n'
    body[$W_MISS_DOC]+="## Раздел ${W_MISS_SEC} не в начале"$'\n'
  fi
  for doc in "${!body[@]}"; do
    mkdir -p "$r/${doc%/*}"
    { printf '# Документ владельца (toy)\n\n'; p84_prose 2; printf '\n%s' "${body[$doc]}"; p84_prose 1; } > "$r/$doc"
  done
}
p84_roadmap_write() {  # <корень> — ROADMAP.md по W_RM_MODE (block|none|two)
  local f="$1/ROADMAP.md"
  {
    printf '# Дорожная карта (toy)\n\n'; p84_prose 3
    printf '\n## 11. Порядок работ\n\n'; p84_prose 2
    printf 'Маркер %s упомянут в прозе и строкой-маркером не является.\n' "$P84_RM_BEGIN"
    [ "$W_RM_MODE" = none ] || printf '%s\n' "$P84_RM_BEGIN"
    printf 'устаревшая строка: | 1 | 900 | до V-2 | CI | - | 9606609 |\n'; p84_prose 2
    [ "$W_RM_MODE" = none ] || printf '%s\n' "$P84_RM_END"
    p84_prose 2
    printf 'Хвост %s — тоже не маркер.\n' "$P84_RM_END"
    if [ "$W_RM_MODE" = two ]; then printf '%s\nвторой блок\n%s\n' "$P84_RM_BEGIN" "$P84_RM_END"; fi
    printf '\n## 12. Дальше\n\n'; p84_prose 2
  } > "$f"
}
p84_handoff_write() {  # <корень> — HANDOFF.md по W_HO_MODE (block|none)
  local f="$1/HANDOFF.md"
  {
    printf '## ГДЕ МЫ (toy)\n\n'; p84_prose 3
    printf 'Маркер %s в прозе — не строка-маркер.\n' "$P84_HO_BEGIN"
    if [ "$W_HO_MODE" = block ]; then
      printf '%s\n## Следующая сессия (устаревшее)\n\n- старый-пункт · пара 1 · не начат · трек CI\n%s\n' \
        "$P84_HO_BEGIN" "$P84_HO_END"
    fi
    printf '\n### Следующий шаг\n\n'; p84_prose 2
  } > "$f"
}
p84_resolve_src() {  # <sha-основания> — W_SRC из W_SRC_SPEC
  local base="$1" i spec
  for i in "${!W_SRC_SPEC[@]}"; do
    spec="${W_SRC_SPEC[$i]}"
    case "$spec" in '@sha:'*) W_SRC[$i]="${base:0:${spec#@sha:}}" ;; *) W_SRC[$i]="$spec" ;; esac
  done
}
p84_build() {  # <корень> — toy-репозиторий из модели (два коммита: основание, план; затем теги)
  local r="$1" id
  mkdir -p "$r/registry" "$r/contracts"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r" || return 1
  p84_docs_write "$r"
  for id in "${!W_H1[@]}"; do
    p84_sfx 4; printf '# %s\n\n## Предмет\n\n%s\n' "${W_H1[$id]}" "$(p84_prose 1)" > "$r/contracts/$id-$P84_S.md"
  done
  : > "$r/registry/contracts.tsv"
  for id in "${W_REG_ORDER[@]}"; do printf '%s → %s\n' "$id" "${W_REG[$id]}" >> "$r/registry/contracts.tsv"; done
  p84_closed_write "$r/registry/closed-without-done.tsv"
  p84_roadmap_write "$r"
  p84_handoff_write "$r"
  p84_commit "$r" 'основание toy 084' || return 1
  P84_BASE="$(p84_g "$r" rev-parse HEAD)"
  p84_resolve_src "$P84_BASE"
  p84_emit_plan > "$r/registry/plan.tsv"
  p84_commit "$r" 'план toy 084' || return 1
  for id in "${!W_FROZEN[@]}"; do p84_tag "$r" "frozen/contracts/$id/1" || return 1; done
  for id in "${!W_DONE[@]}"; do p84_tag "$r" "done/contracts/$id/1" || return 1; done
}

# ── Конформный мир к0 ───────────────────────────────────────────────────────────────────
# ≥6 строк, ≥3 пары, обе формы id/источника/зависит, оба этапа. Значения случайны на прогон;
# ФОРМА выбрана так, чтобы нарушения И-4 были НАБЛЮДАЕМЫ: пара ≥10 рядом с парами <10
# (сортировка числом, не строкой); в младшей паре три строки в порядке файла ПО УБЫВАНИЮ id
# (внутри пары — порядок файла, не id); первая строка файла — из старшей пары (порядок
# файла ≠ порядок пар); столбцы таблицы ≠ порядку полей plan.tsv. Символьные id несут
# кириллицу, «.» и «-» (И-1), один из них — «<X>z<Y>» (ловушка з2), один — «пункт-…»
# (собственный префикс «пункт» — ловушка з1). W_MISS_SEC — раздел без заголовка в DOC1,
# окружённый околозаголовками (и2).
p84_world_main() {
  local PL PM PH T1 T2 T3 DOC1 DOC2 n1 n2 n3 n4 s1 s2 s3 s4 x y sA sB sC sD id low=()
  p84_world_reset
  p84_num; n1="$P84_N"; p84_num; n2="$P84_N"; p84_num; n3="$P84_N"; p84_num; n4="$P84_N"
  p84_sfx 3; s1="пункт-$P84_S"
  p84_sfx 2; s2="CI-${P84_S}Б"
  p84_sfx 3; x="$P84_S"; x="${x//[0-9]/q}"; p84_sfx 2; y="$P84_S"; s3="${x}z${y}"
  W_ZX="$x"; W_ZY="$y"
  p84_sfx 2; s4="V-2.$P84_S"
  p84_rnd 4; PL=$((P84_R + 1)); p84_rnd 5; PM=$((P84_R + 5)); p84_rnd 3; PH=$((P84_R + 10))
  p84_sfx 3; T1="CI$P84_S"; p84_sfx 3; T2="plan-infra-$P84_S"; p84_sfx 2; T3="git-safety-$P84_S"
  p84_sfx 4; DOC1="docs/owner/2026-10-03-$P84_S.md"; p84_sfx 4; DOC2="docs/owner/odelix/$P84_S-plan.md"
  p84_sec; sA="$P84_SEC"; p84_sec; sB="$P84_SEC"; p84_sec; sC="$P84_SEC"; p84_sec; sD="$P84_SEC"
  p84_sec; W_MISS_SEC="$P84_SEC"; W_MISS_DOC="$DOC1"
  while IFS= read -r id; do low+=("$id"); done < <(printf '%s\n' "$s1" "$s2" "$n4" | LC_ALL=C sort -r)
  p84_row "$n1"     "$PH" "$P84_STAGE_B" -               '@sha:12'   "$T1"
  p84_row "${low[0]}" "$PL" "$P84_STAGE_A" -             "$DOC1#$sA" "$T2"
  p84_row "$n2"     "$PM" "$P84_STAGE_A" "$n1"           "$DOC1#$sB" "$T1"
  p84_row "${low[1]}" "$PL" "$P84_STAGE_A" -             '@sha:40'   "$T2"
  p84_row "$n3"     "$PH" "$P84_STAGE_B" "$s1,$n2"       "$DOC2#$sC" "$T3"
  p84_row "$s3"     "$PM" "$P84_STAGE_A" "$n3"           "$DOC2#$sD" "$T1"
  p84_row "${low[2]}" "$PL" "$P84_STAGE_A" -             '@sha:9'    "$T3"
  p84_row "$s4"     "$PM" "$P84_STAGE_B" "$s2,$s3,$n1"   '@sha:7'    "$T2"
  for id in "$n1" "$n2" "$n3" "$n4"; do p84_reg_add "$id"; p84_h1_add "$id"; done
  p84_num; p84_reg_add "$P84_N"; p84_num; p84_reg_add "$P84_N"           # шум реестра вне плана
  p84_num; p84_closed_add "$P84_N" "шум вне плана: закрыт решением владельца — toy"
  W_NUMS=("$n1" "$n2" "$n3" "$n4"); W_SYMS=("$s1" "$s2" "$s3" "$s4")
  W_T1="$T1"; W_DOC1="$DOC1"; W_S1="$s1"
}

# ── Байтовые операции над файлами toy ───────────────────────────────────────────────────
# p84_py <команда> <аргументы…>; маркер — ЦЕЛАЯ строка (без «\n»; «\r» маркер ломает).
#   between <ф> <B> <E>          — байты строк строго между единственными B и E (rc 3 — блока нет)
#   outside <ф> <B> <E>          — «sha256(до B включительно) sha256(от E до конца)»
#   count <ф> <строка>           — число целых строк, равных <строка>
#   fill <ф> <B> <E> <src>       — заменить строки между B и E содержимым файла <src>
#   cellbyte <ф> <B> <E> <seed>  — сменить ОДИН ASCII-байт случайной ячейки строки таблицы блока
#   insert <ф> <B> <E> <seed> <текст> — вставить строку вне блока; печать её номера (с 1)
#   tailspace <ф> <строка>       — дописать пробел к единственной строке-маркеру
#   strip <ф> <B> <E>            — удалить B..E включительно
#   unmark <ф> <B> <E>           — удалить только строки B и E
#   invert <ф> <B> <E>           — поменять местами строки B и E (перевёрнутая пара)
#   addpair <ф> <B> <E>          — дописать в конец вторую пару B/E
#   items <ф> <B> <E>            — id строк «- <id> · …» блока, по строке
#   prefix <старый> <новый>      — rc 0, если новый начинается байтами старого
#   sha <ф>                      — sha256 файла («нет-файла», если его нет)
#   perenos-table <контракт> <план> <реестр> <HDR> <раздел> — ж6: план коммита переноса
#        построчно == таблице раздела контракта («O#» раскрыт по «O = `…`» раздела; символьный id
#        заменим только номером из реестра, не id таблицы, согласованно в id и «зависит»);
#        rc 1 — первое расхождение в stdout «перенос: …»; rc 2 — таблицу не прочесть
#   perenos-roadmap <до> <после> <оракул> <B> <E> <старое> <новое> <§11> — ж6: «после» без
#        строк B..E == «до» с заменой старое→новое; между B и E — оракул; блок — в §11 до
#        первого «новое»; rc 1 — расхождение в stdout «перенос: ROADMAP.md: …»
p84_py() {
  python3 - "$@" <<'PY'
import hashlib, os, random, sys
cmd, a = sys.argv[1], sys.argv[2:]
def rd(p):
    with open(p, 'rb') as f:
        return f.read().splitlines(keepends=True)
def wr(p, ls):
    with open(p, 'wb') as f:
        f.write(b''.join(ls))
def bare(l):
    return l[:-1] if l.endswith(b'\n') else l
def idx(ls, m):
    m = m.encode()
    return [i for i, l in enumerate(ls) if bare(l) == m]
def blk(ls, b, e):
    bi, ei = idx(ls, b), idx(ls, e)
    if len(bi) != 1 or len(ei) != 1 or bi[0] >= ei[0]:
        sys.exit(3)
    return bi[0], ei[0]
if cmd == 'between':
    ls = rd(a[0]); b, e = blk(ls, a[1], a[2]); sys.stdout.buffer.write(b''.join(ls[b + 1:e]))
elif cmd == 'outside':
    ls = rd(a[0]); b, e = blk(ls, a[1], a[2])
    print(hashlib.sha256(b''.join(ls[:b + 1])).hexdigest(), hashlib.sha256(b''.join(ls[e:])).hexdigest())
elif cmd == 'count':
    print(len(idx(rd(a[0]), a[1])))
elif cmd == 'fill':
    ls = rd(a[0]); b, e = blk(ls, a[1], a[2])
    with open(a[3], 'rb') as f:
        mid = f.read().splitlines(keepends=True)
    wr(a[0], ls[:b + 1] + mid + ls[e:])
elif cmd == 'cellbyte':
    ls = rd(a[0]); b, e = blk(ls, a[1], a[2]); rnd = random.Random(int(a[3]))
    sep = [i for i in range(b + 1, e) if bare(ls[i]) == b'|---|---|---|---|---|---|']
    if len(sep) != 1:
        sys.exit(4)
    cand = []
    for i in range(sep[0] + 1, e):
        l = ls[i]
        if not l.startswith(b'| '):
            continue
        for p in range(2, len(bare(l)) - 2):
            c = l[p:p + 1]
            if c.isalnum() and c.isascii() and l[p - 1:p] != b'|' and l[p + 1:p + 2] != b'|':
                cand.append((i, p))
    if not cand:
        sys.exit(4)
    i, p = rnd.choice(cand)
    l = bytearray(ls[i]); c = chr(l[p])
    if c.isdigit():
        n = str((int(c) + 1) % 10)
    elif c.islower():
        n = 'a' if c == 'z' else chr(ord(c) + 1)
    else:
        n = 'A' if c == 'Z' else chr(ord(c) + 1)
    l[p] = ord(n); ls[i] = bytes(l); wr(a[0], ls)
    print('строка %d байт %d: %s→%s' % (i + 1, p, c, n))
elif cmd == 'insert':
    ls = rd(a[0]); b, e = blk(ls, a[1], a[2]); rnd = random.Random(int(a[3]))
    k = rnd.choice(list(range(0, b + 1)) + list(range(e + 1, len(ls) + 1)))
    if ls and not ls[-1].endswith(b'\n'):
        ls[-1] += b'\n'
    ls.insert(k, a[4].encode() + b'\n'); wr(a[0], ls); print(k + 1)
elif cmd == 'tailspace':
    ls = rd(a[0]); i = idx(ls, a[1])
    if len(i) != 1:
        sys.exit(3)
    ls[i[0]] = bare(ls[i[0]]) + b' \n'; wr(a[0], ls)
elif cmd == 'strip':
    ls = rd(a[0]); b, e = blk(ls, a[1], a[2]); wr(a[0], ls[:b] + ls[e + 1:])
elif cmd == 'unmark':
    ls = rd(a[0]); b, e = blk(ls, a[1], a[2]); wr(a[0], ls[:b] + ls[b + 1:e] + ls[e + 1:])
elif cmd == 'invert':
    ls = rd(a[0]); b, e = blk(ls, a[1], a[2]); ls[b], ls[e] = ls[e], ls[b]; wr(a[0], ls)
elif cmd == 'addpair':
    ls = rd(a[0])
    if ls and not ls[-1].endswith(b'\n'):
        ls[-1] += b'\n'
    wr(a[0], ls + [a[1].encode() + b'\n', 'второй блок\n'.encode(), a[2].encode() + b'\n'])
elif cmd == 'items':
    ls = rd(a[0]); b, e = blk(ls, a[1], a[2])
    for l in ls[b + 1:e]:
        s = bare(l).decode()
        if s.startswith('- ') and ' · ' in s:
            print(s[2:].split(' · ', 1)[0])
elif cmd == 'prefix':
    with open(a[0], 'rb') as f:
        old = f.read()
    with open(a[1], 'rb') as f:
        new = f.read()
    sys.exit(0 if new.startswith(old) and len(new) > len(old) else 1)
elif cmd == 'sha':
    if not os.path.exists(a[0]):
        print('нет-файла')
    else:
        with open(a[0], 'rb') as f:
            print(hashlib.sha256(f.read()).hexdigest())
elif cmd == 'perenos-table':
    import re
    con, plan, reg, hdr, sect = a[:5]
    fields = hdr.split('\t')
    def na(msg):
        sys.stderr.write('NOT_IMPLEMENTED: таблица §Перенос: %s\n' % msg)
        sys.exit(2)
    def red(msg):
        print('перенос: ' + msg)
        sys.exit(1)
    with open(con, encoding='utf-8') as f:
        t = f.read().split('\n')
    if t.count(sect) != 1:
        na('раздел «%s» не один' % sect)
    s0 = t.index(sect)
    s1 = next((i for i in range(s0 + 1, len(t)) if t[i].startswith('## ')), len(t))
    sec = t[s0 + 1:s1]
    od = re.findall(r'O = `(docs/owner/[^`]+\.md)`', '\n'.join(sec))
    if len(od) != 1:
        na('определение «O = `docs/owner/….md`» не одно')
    th, ts = '| ' + ' | '.join(fields) + ' |', '|' + '---|' * len(fields)
    hi = [i for i, l in enumerate(sec) if l == th]
    if len(hi) != 1 or hi[0] + 1 >= len(sec) or sec[hi[0] + 1] != ts:
        na('шапка «%s» с разделителем не одна' % th)
    fd, fs = fields.index('зависит'), fields.index('источник')
    want = []
    for l in sec[hi[0] + 2:]:
        if not l.startswith('|'):
            break
        cells = l[2:-2].split(' | ') if l.startswith('| ') and l.endswith(' |') else []
        if len(cells) != len(fields):
            na('строка таблицы вне формы: %s' % l)
        if cells[fs].startswith('O#'):
            cells[fs] = od[0] + cells[fs][1:]
        want.append(cells)
    if not want:
        na('таблица пуста')
    with open(reg, encoding='utf-8') as f:
        regs = set(l.split(' → ', 1)[0] for l in f.read().split('\n') if ' → ' in l)
    with open(plan, encoding='utf-8') as f:
        pl = f.read().split('\n')
    if pl and pl[-1] == '':
        pl.pop()
    if not pl or pl[0] != hdr:
        red('строка 1 registry/plan.tsv ≠ заголовку И-1')
    got = [l.split('\t') for l in pl[1:]]
    for k, g in enumerate(got):
        if len(g) != len(fields):
            red('строка %d registry/plan.tsv: полей %d, не %d' % (k + 2, len(g), len(fields)))
    num = re.compile(r'[0-9]{3}\Z')
    tids, sub, n = set(w[0] for w in want), {}, min(len(got), len(want))
    for k in range(n):
        g, w = got[k][0], want[k][0]
        if g == w:
            continue
        if not num.match(w) and num.match(g) and g in regs and g not in tids and g not in sub.values():
            sub[w] = g
            continue
        red('строка %d registry/plan.tsv: поле %s: «%s», в таблице §Перенос «%s»' % (k + 2, fields[0], g, w))
    for k in range(n):
        for f in range(1, len(fields)):
            e = want[k][f]
            if f == fd and e != '-':
                e = ','.join(sub.get(x, x) for x in e.split(','))
            if got[k][f] != e:
                red('строка %d registry/plan.tsv (%s): поле %s: «%s», в таблице §Перенос «%s»' % (k + 2, want[k][0], fields[f], got[k][f], e))
    if len(got) < len(want):
        red('нет строки таблицы §Перенос «%s» (строк в registry/plan.tsv %d, в таблице %d)' % (want[n][0], len(got), len(want)))
    if len(got) > len(want):
        red('лишняя строка %d registry/plan.tsv «%s» (строк %d, в таблице %d)' % (n + 2, got[n][0], len(got), len(want)))
elif cmd == 'perenos-roadmap':
    B, E, OLD, NEW, S11 = (x.encode() for x in a[3:8])
    def red(msg):
        print('перенос: ROADMAP.md: ' + msg)
        sys.exit(1)
    before, after = rd(a[0]), rd(a[1])
    with open(a[2], 'rb') as f:
        oracle = f.read()
    bi = [i for i, l in enumerate(after) if bare(l) == B]
    ei = [i for i, l in enumerate(after) if bare(l) == E]
    if len(bi) != 1 or len(ei) != 1 or bi[0] > ei[0]:
        red('маркеры блока плана в коммите переноса не по одному')
    b, e = bi[0], ei[0]
    if b''.join(after[b + 1:e]) != oracle:
        red('блок плана ≠ генерации И-4 из registry/plan.tsv коммита переноса')
    if not any(OLD in l for l in before):
        red('в ROADMAP.md родителя нет «%s»' % OLD.decode())
    rest, exp = after[:b] + after[e + 1:], [l.replace(OLD, NEW) for l in before]
    if rest != exp:
        k = next((i for i in range(min(len(rest), len(exp))) if rest[i] != exp[i]), min(len(rest), len(exp)))
        red('вне блока ≠ тексту родителя с заменой «%s» → «%s»: строка %d' % (OLD.decode(), NEW.decode(), k + 1 if k < b else k + e - b + 2))
    heads = [bare(l) for l in exp[:b] if l.startswith(b'## ')]
    if not heads or not heads[-1].startswith(S11) or any(NEW in l for l in exp[:b]):
        red('блок плана не в §11 перед первым пунктом «%s»' % NEW.decode())
else:
    sys.exit(2)
PY
}
