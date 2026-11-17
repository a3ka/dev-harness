#!/usr/bin/env bash
# МОДЕЛЬ-ЭТАЛОН двери 199 (контракт «Sol в изоляции»): подмножество семантики
# scripts/zamok_predmeta.sh, расширенное инвариантами 199 — реальный флаг
# isolated события спавна обязателен для рабочего, START несёт факт isolated.
# Модель — опора режима --model/--stabs батареи
# fixtures/workshop_project/sol_v_izolyacii_199/ ДО ленда реализации;
# наблюдаемые исходы на входах клеток совпадают с целевой семантикой субъекта.
# Это НЕ субъект: в CI и приёмке судится scripts/zamok_predmeta.sh дерева.
#
# Использование (совпадает с субъектом):
#   zamok_predmeta_199.sh --sudit --sostojanie D --zhurnaly D --repo R <event.json>
# rc 0 — разрешено (START записан); rc 1 — именованный отказ; rc 2 — нечем проверить.
set -u

MODE=''; SOST=''; ZHUR=''; REPO=''; EVENT=''
while [ "$#" -gt 0 ]; do
  case "$1" in
    --sudit) MODE="$1" ;;
    --sostojanie) SOST="${2:?}"; shift ;;
    --zhurnaly)   ZHUR="${2:?}"; shift ;;
    --repo)       REPO="${2:?}"; shift ;;
    *) EVENT="$1" ;;
  esac
  shift
done
[ -n "$MODE" ] || { printf 'использование: --sudit --sostojanie D --zhurnaly D --repo R <event.json>\n' >&2; exit 2; }
[ -n "$SOST" ] && [ -n "$ZHUR" ] && [ -n "$REPO" ] || { printf 'использование: --sudit\n' >&2; exit 2; }
[ -d "$SOST" ] || { printf 'NOT_IMPLEMENTED: состояния нет: %s\n' "$SOST" >&2; exit 2; }
[ -d "$ZHUR" ] || { printf 'NOT_IMPLEMENTED: журналов нет: %s\n' "$ZHUR" >&2; exit 2; }
command -v jq  >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет jq\n'  >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
[ -n "$EVENT" ] && [ -f "$EVENT" ] || { printf 'NOT_IMPLEMENTED: события нет: %s\n' "$EVENT" >&2; exit 2; }
REPO="$(cd "$REPO" 2>/dev/null && pwd -P)" || { printf 'NOT_IMPLEMENTED: репо нет\n' >&2; exit 2; }
git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: не репозиторий\n' >&2; exit 2; }
LEDGER="$SOST/uchet.jsonl"
[ -r "$LEDGER" ] || : >> "$LEDGER" || { printf 'NOT_IMPLEMENTED: учёт не создать\n' >&2; exit 2; }

REPO_URL="$(git -C "$REPO" remote get-url origin 2>/dev/null)" || REPO_URL=''
REPO_ID="${REPO_URL##*/}"; REPO_ID="${REPO_ID%.git}"
[ -n "$REPO_ID" ] || REPO_ID="$(basename "$REPO")"
ts_now() { date -u '+%Y-%m-%dT%H:%M:%SZ'; }
otp() { printf 'ОТКАЗ: %s: %s\n' "$1" "$2" >&2; exit 1; }
zamok_dir() { printf '%s/zamki/%s/%s' "$SOST" "$REPO_ID" "$1"; }

# грамматика полей — построчные якоря, как у субъекта (замкнутые алфавиты 041)
kolvo_strok() { printf '%s\n' "$1" | grep -cE "$2" || true; }
TAB=$'\t'
WORKERS='architect implementer implementer-glm implementer-vision'
JUDGES='critic critic-sol adversary reviewer'

# [D2 yield-istochnik] журнал holder: yield-литерал (подмножество субъекта)
stare_holder() {
  local h="$1" jf
  case "$h" in ''|*[!A-Za-z0-9._-]*) printf 'net_fajla'; return 0 ;; esac
  jf="$(find "$ZHUR" -type f -name "${h}.jsonl" -print | sed -n '1p')"
  if [ -z "$jf" ]; then printf 'net_fajla'; return 0; fi
  if grep -Fq '"toolName":"yield"' "$jf"; then printf 'yield'; return 0; fi
  if tail -n 1 "$jf" | jq -e 'select(.type == "custom" and .customType == "session_exit" and .data.kind == "normal")' >/dev/null 2>&1; then
    printf 'yield'; return 0
  fi
  printf 'bezhit'
}

poslednij_rabochij() {
  jq -rs --arg r "$REPO_ID" --arg n "$1" '
    [ .[] | select(.t == "START" and .subjectId == $n and .klass == "rabochij") ]
    | last // empty | [ .holder, .object, .worktree, .branch ] | @tsv' "$LEDGER" 2>/dev/null
}

# ── разбор события ────────────────────────────────────────────────────────────
if ! N="$(jq -r '(.tasks // [.]) | length' "$EVENT" 2>/dev/null)"; then
  otp BITYJ_VHOD 'событие не разбирается (tasks/flat)'
fi
case "$N" in ''|*[!0-9]*) otp BITYJ_VHOD 'длина items не число' ;; esac
[ "$N" -gt 0 ] || otp BITYJ_VHOD 'items пуст'

GATED=''
i=0
while [ "$i" -lt "$N" ]; do
  agent="$(jq -r "(.tasks // [.])[$i].agent // \"\"" "$EVENT" 2>/dev/null)" || otp BITYJ_VHOD "item $i: agent не читается"
  name="$(jq -r "(.tasks // [.])[$i].name // \"\"" "$EVENT" 2>/dev/null)" || otp BITYJ_VHOD "item $i: name не читается"
  task="$(jq -r "(.tasks // [.])[$i].task // \"\"" "$EVENT" 2>/dev/null)" || otp BITYJ_VHOD "item $i: task не читается"
  # [Adv199-impl-1, находка 1] строгое сравнение ПО ТИПУ (инвариант 1):
  # истина — ТОЛЬКО булево true; строка «true», 1, [true], {…}, null,
  # отсутствие поля — false (fail-closed). jq -r + строковое сравнение строку
  # «true» от булева не отличают — сравнение обязан делать jq по типу.
  if jq -e "(.tasks // [.])[$i].isolated == true" "$EVENT" >/dev/null 2>&1; then iso=true; else iso=false; fi
  [ -n "$agent" ] || otp AGENT_NET "item $i: agent отсутствует"
  in_w=0; in_j=0
  for r in $WORKERS; do [ "$r" = "$agent" ] && in_w=1; done
  for r in $JUDGES;  do [ "$r" = "$agent" ] && in_j=1; done
  if [ "$in_w" -eq 0 ] && [ "$in_j" -eq 0 ]; then i=$((i + 1)); continue; fi
  case "$name" in
    ''|*[!A-Za-z0-9._-]*) otp IMJA_NET "item $i: имя «$name» пусто/вне [A-Za-z0-9._-]" ;;
  esac
  c="$(kolvo_strok "$task" '^SUBJECT=[0-9]{3}$')"
  if [ "$c" = '0' ]; then otp SUBJECT_NET_V_ZADANII "item $i: строка ^SUBJECT=[0-9]{3}\$ отсутствует"; fi
  if [ "$c" -gt 1 ]; then otp SUBEKT_DVA_V_ZADANII "item $i: строк SUBJECT= больше одной"; fi
  sv="$(printf '%s\n' "$task" | grep -E '^SUBJECT=[0-9]{3}$' | sed -n '1p' | cut -c9-11)"
  if [ "$in_w" -eq 1 ]; then
    rxw="^WORKTREE=/[^${TAB}]+$"; rxb="^BRANCH=wip/[0-9]{3}/[^${TAB}]+$"
    wc="$(kolvo_strok "$task" "$rxw")"; bc="$(kolvo_strok "$task" "$rxb")"
    if [ "$wc" = '0' ] || [ "$bc" = '0' ]; then otp PIN_NET "item $i: пара ^WORKTREE=/… ^BRANCH=wip/<NNN>/… отсутствует"; fi
    if [ "$wc" -gt 1 ] || [ "$bc" -gt 1 ]; then otp GRAMMATIKA_PINA "item $i: пара пина вне грамматики (дубли строк)"; fi
    wt="$(printf '%s\n' "$task" | grep -E "$rxw" | sed -n '1p' | cut -c10-)"
    br="$(printf '%s\n' "$task" | grep -E "$rxb" | sed -n '1p' | cut -c8-)"
    [ "$(printf '%s' "${br#wip/}" | cut -c1-3)" = "$sv" ] \
      || otp RASHOZHDENIE_PINA "item $i: BRANCH=wip/$(printf '%s' "${br#wip/}" | cut -c1-3)/… ≠ SUBJECT=$sv"
    [ -d "$wt" ] || { printf 'NOT_IMPLEMENTED: worktree пина нет: %s\n' "$wt" >&2; exit 2; }
    git -C "$wt" rev-parse --git-dir >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: worktree пина не репо: %s\n' "$wt" >&2; exit 2; }
    # ИНВАРИАНТ 199: реальный флаг isolated события обязателен для рабочего.
    # Источник — нормализация стража спавна из ПОЛЯ item, НЕ слово в task.
    [ "$iso" = 'true' ] \
      || otp NE_IZOLIROVAN "item $i: рабочий спавн без реального isolated:true (поле события)"
    obj='-'; klass='rabochij'; rol="$agent"
  else
    c2="$(kolvo_strok "$task" '^OBJECT=[0-9a-f]{40}$')"
    if [ "$c2" = '0' ]; then otp OBJECT_OTSTUTSVUET "item $i: строка ^OBJECT=[0-9a-f]{40}\$ отсутствует"; fi
    if [ "$c2" -gt 1 ]; then otp SUBEKT_DVA_OBJECTA "item $i: строк OBJECT= больше одной"; fi
    obj="$(printf '%s\n' "$task" | grep -E '^OBJECT=[0-9a-f]{40}$' | sed -n '1p' | cut -c8-47)"
    wt='-'; br='-'; klass='sudja'; rol="$agent"
  fi
  GATED="${GATED}${i}|${agent}|${name}|${sv}|${obj}|${wt}|${br}|${klass}|${rol}|${iso}
:"
  i=$((i + 1))
done
[ -n "$GATED" ] || { printf 'PROPUST: gated items нет\n'; exit 0; }

# [D20 dubl-v-pakete]
DUBL="$(printf '%s' "$GATED" | cut -d'|' -f4 | sort | uniq -d | sed -n '1p')"
[ -z "$DUBL" ] || otp DUBL_V_PAKETE "два элемента пакета на предмет $DUBL"

# судейские ворота (подмножество: D10/D11-lite/D9/D13)
while IFS='|' read -r idx agent name sv obj wt br klass rol iso; do
  [ -n "$sv" ] || continue
  if [ "$klass" = 'sudja' ]; then
    rab="$(poslednij_rabochij "$sv")"
    if [ -z "$rab" ]; then otp RABOCHEGO_NET "предмет $sv: рабочего START в учёте нет"; fi
    r_holder="$(printf '%s' "$rab" | cut -f1)"
    r_wt="$(printf '%s' "$rab" | cut -f3)"
    r_br="$(printf '%s' "$rab" | cut -f4)"
    [ "$(stare_holder "$r_holder")" = 'yield' ] || otp AVTOR_ESHCHO_RABOTAET "предмет $sv: автор $r_holder не сдал (yield в журнале отсутствует)"
    tip="$(git -C "$r_wt" rev-parse --verify "$r_br" 2>/dev/null)" || otp VETKA_NEDOSTUPNA "предмет $sv: ветка $r_br в $r_wt не читается — OBJECT не сверить"
    [ "$tip" = "$obj" ] || otp OBJECT_RASHODITSJA "предмет $sv: OBJECT задания $obj ≠ tip ветки $r_br ($tip)"
    kr='obychnyj'
    if git -C "$r_wt" cat-file -t "$obj:contracts" >/dev/null 2>&1; then
      fajl="$(git -C "$r_wt" ls-tree "$obj:contracts" | awk -F'\t' -v n="$sv" '$2 ~ "^" n "-[^/]*[.]md$" {print $2}' | LC_ALL=C sort | sed -n '1p')"
      [ -n "$fajl" ] || kr='net_stroki'
      val="$(git -C "$r_wt" show "$obj:contracts/$fajl" 2>/dev/null | grep -E -o 'КЛАСС РИСКА:[[:blank:]]*(обычный|рисковый)' | sed -E 's/.*:[[:blank:]]*//')"
      case "$val" in обычный) kr='obychnyj' ;; рисковый) kr='risikovyj' ;; *) kr='net_stroki' ;; esac
    fi
    [ "$kr" = 'net_stroki' ] && otp KLASS_RISKA_NET "предмет $sv: класс риска не определён"
    if [ "$kr" = 'risikovyj' ] && [ "$rol" = 'reviewer' ]; then
      otp ADVERSARIJ_DO_REVJUERA "предмет $sv рисковый, завершённого адверсария в учёте нет — ревьюер раньше адверсария запрещён"
    fi
  fi
done <<EOF
$GATED
EOF

# START: holder.json + строка учёта с фактом isolated
while IFS='|' read -r idx agent name sv obj wt br klass rol iso; do
  [ -n "$sv" ] || continue
  zdir="$(zamok_dir "$sv")"
  mkdir -p "$zdir/zanyat" 2>/dev/null || { printf 'NOT_IMPLEMENTED: занятие не создать: %s\n' "$zdir/zanyat" >&2; exit 2; }
  printf '{"holder":"%s","klass":"%s","rol":"%s","object":"%s","startedAt":"%s"}\n' \
    "$name" "$klass" "$rol" "$obj" "$(ts_now)" > "$zdir/zanyat/holder.json"
  jq -nc --arg t START --arg r "$REPO_ID" --arg s "$sv" --arg g '-' \
        --arg h "$name" --arg k "$klass" --arg ro "$rol" --arg o "$obj" \
        --arg w "$wt" --arg b "$br" --arg at "$(ts_now)" --argjson iso "$([ "$iso" = 'true' ] && printf true || printf false)" \
    '{t:$t,repoId:$r,subjectId:$s,group:$g,holder:$h,klass:$k,rol:$ro,object:$o,worktree:$w,branch:$b,at:$at,isolated:$iso}' \
    >> "$LEDGER"
  printf 'PUSCHEM %s %s/%s (%s/%s)\n' "$name" "$REPO_ID" "$sv" "$klass" "$rol"
done <<EOF
$GATED
EOF
exit 0
