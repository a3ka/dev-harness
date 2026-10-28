#!/usr/bin/env bash
# ЗАМОК ПРЕДМЕТА (контракт 140 «odin-agent-na-predmet») — эталон единой двери:
# суд спавна «один рабочий агент на предмет», атомарный замок (repoId, subjectId)
# на batch целиком, единый учёт начатых предметов (лимиты 1/3/2, START до первой
# раздачи, слот до done/ПАУЗЫ). Реализация харнесса (scripts/zamok_predmeta.sh)
# несёт ту же семантику; батарея fixtures/workshop_project/odin_agent_140/
# судит ЭТУ модель, стабы — её мутации по маркерам [Dn].
#
# ВЫЗОВ (грамматика argv замкнута, ровно три формы):
#   zamok_predmeta.sh --sudit     --sostojanie D --zhurnaly D --repo R <event.json>
#   zamok_predmeta.sh --osvobodit --sostojanie D --zhurnaly D --repo R <NNN> <holder>
#   zamok_predmeta.sh --uchet     --sostojanie D --zhurnaly D --repo R
#
# ИСТОЧНИКИ СОБЫТИЙ (ось «источник»):
#   --sostojanie D — замки D/zamki/<repoId>/<NNN>/{mutex,zanyat}/holder.json и
#                    учёт D/uchet.jsonl (append-only, построчный JSON);
#   --zhurnaly  D  — журналы сессий станции …/<holder>.jsonl; сдача (yield) —
#                    литеральная строка `"toolName":"yield"` в журнале holder
#                    (факт отклика инструмента yield; orch-tablo читает тот же
#                    факт разбором JSON — здесь байтовый якорь);
#   --repo      R  — реестр: registry/pauzy.tsv (ПАУЗА владельца), теги
#                    done/contracts/<NNN>/* (слот закрыт), contracts/<NNN>-*.md
#                    (строка с декларацией «КЛАСС РИСКА: рисковый|обычный …»).
#
# ЗАМКНУТЫЕ АЛФАВИТЫ (норма 041; байты-разделители исключены из классов значений):
#   SUBJECT — строка задания `^SUBJECT=[0-9]{3}$`, ровно одна (/m, якорь ^…$);
#   OBJECT  — строка задания `^OBJECT=[0-9a-f]{40}$`, ровно одна (грамматика 104
#             Решение 5 — та же, что models_actual.sh --bind);
#   PIN     — пара строк `^WORKTREE=/[^TAB]+$` и `^BRANCH=wip/[0-9]{3}/[^TAB]+$`
#             (построчная форма грамматики 066; NNN ветки == SUBJECT; байт TAB
#             исключён из класса значения ЛИТЕРАЛЬНО — ERE-скобки не знают \t);
#   ИМЯ     — [A-Za-z0-9._-]+ (грамматика session-id, норма 037);
#   РОЛИ    — рабочие: architect implementer implementer-glm implementer-vision;
#             судьи:  critic critic-sol adversary reviewer;
#   ГРУППЫ  — harness mob back («-» = вне лимитов станции);
#   LEDGER  — строка uchet.jsonl {"t":…} (JSON: значения не сталкиваются
#             с разделителями — склейка полей исключена);
#   СРАВНЕНИЯ — только литеральные ([ = ] / grep -F); значения задания НИКОГДА
#             не попадают в regex/glob.
#
# ОТКАЗЫ rc 1 (именованные; первая причина; stderr «ОТКАЗ: <ИМЯ>: <детали>»):
#   SUBJECT_NET_V_ZADANII SUBEKT_DVA_V_ZADANII GRAMMATIKA_SUBEKTA
#   OBJECT_OTSTUTSVUET SUBEKT_DVA_OBJECTA GRAMMATIKA_OBJECTA
#   PIN_NET GRAMMATIKA_PINA RASHOZHDENIE_PINA VETKA_NEDOSTUPNA
#   IMJA_NET GRAMMATIKA_IMENI AGENT_NET BITYJ_VHOD
#   DUBL_V_PAKETE RABOCHIJ_ZHIV SUDJA_ZHIV ZAMOK_BROSHEN ZANYATO_RESHENIEM
#   AVTOR_ESHCHO_RABOTAET RABOCHEGO_NET OBJECT_RASHODITSJA OBJECT_UZHE_SUZHEN
#   ADVERSARIJ_DO_REVJUERA KLASS_RISKA_NET PAUZA_VLADELTSA LIMIT_GRUPPY
#   ZAMOK_ZHIV DERZHATEL_RASHODITSJA NET_ZAMKA
# rc 0 — разрешено (замки заняты, START дописан ДО возврата) / исполнено / учёт.
# rc 2 — NOT_IMPLEMENTED (нет jq/git/find, мир нечитаем): fail-closed; вызов
#        расширением трактуется как блок «страж сломан» — молчаливого пропуска нет.
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

# ── константы (канон; пин — source.json батареи 140) ─────────────────────────
WORKERS='architect implementer implementer-glm implementer-vision'
JUDGES='critic critic-sol adversary reviewer'
TAB=$'\t'
CAP_HARNESS=3
CAP_MOB=3
CAP_BACK=3
BROSHEN_TTL_MIN=60
MUTEX_STALE_MIN=5
GRP_MOB_REPO='Complior-mob'
GRP_BACK_REPO='Complior-back'

usage() {
  cat >&2 <<USAGE
использование:
  $0 --sudit     --sostojanie D --zhurnaly D --repo R <event.json>
  $0 --osvobodit --sostojanie D --zhurnaly D --repo R <NNN> <holder>
  $0 --uchet     --sostojanie D --zhurnaly D --repo R
rc 0 — разрешено/исполнено; rc 1 — именованный отказ; rc 2 — нечем проверить.
USAGE
  exit 2
}

otp()  { printf 'ОТКАЗ: %s: %s\n' "$1" "$2" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$1" >&2; exit 2; }

command -v jq   >/dev/null 2>&1 || skip 'нет jq'
command -v git  >/dev/null 2>&1 || skip 'нет git'
command -v find >/dev/null 2>&1 || skip 'нет find'

MODE=''; SOST=''; ZHUR=''; REPO=''; EVENT=''; NNN_ARG=''; HOLDER_ARG=''
while [ "$#" -gt 0 ]; do
  case "$1" in
    --sudit|--osvobodit|--uchet) MODE="$1" ;;
    --sostojanie) SOST="${2:?}"; shift ;;
    --zhurnaly)   ZHUR="${2:?}"; shift ;;
    --repo)       REPO="${2:?}"; shift ;;
    --help|-h)    usage ;;
    *) if [ "$MODE" = '--sudit' ]; then EVENT="$1"
       elif [ "$MODE" = '--osvobodit' ]; then
         if [ -z "$NNN_ARG" ]; then NNN_ARG="$1"; else HOLDER_ARG="$1"; fi
       else usage; fi ;;
  esac
  shift
done
[ -n "$MODE" ] || usage
[ -n "$SOST" ] && [ -n "$ZHUR" ] && [ -n "$REPO" ] || usage
[ -d "$SOST" ] || skip "состояния нет: $SOST"
[ -d "$ZHUR" ] || skip "журналов нет: $ZHUR"
REPO="$(cd "$REPO" 2>/dev/null && pwd -P)" || skip "репо нет: $REPO"
git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1 || skip "не репозиторий: $REPO"
LEDGER="$SOST/uchet.jsonl"
[ -r "$LEDGER" ] || : >> "$LEDGER" || skip "учёт не создать: $LEDGER"

# [D17 repo-id] repoId — пространство имён замка: репозиторий РЕЕСТРА предмета
# (--repo), литеральный basename origin; общий у рабочих и судей предмета.
REPO_URL="$(git -C "$REPO" remote get-url origin 2>/dev/null)" || REPO_URL=''
REPO_ID="${REPO_URL##*/}"; REPO_ID="${REPO_ID%.git}"
[ -n "$REPO_ID" ] || REPO_ID="$(basename "$REPO")"

ts_now() { date -u '+%Y-%m-%dT%H:%M:%SZ'; }

# [D2 yield-istochnik] журнал: состояние holder; yield — литерал отклика
# инструмента; брошенность — молчание журнала дольше BROSHEN_TTL_MIN.
stare_holder() {  # <holder> → yield|bezhit|broshen|net_fajla
  local h="$1" jf
  case "$h" in
    ''|*[!A-Za-z0-9._-]*) printf 'net_fajla'; return 0 ;;
  esac
  jf="$(find "$ZHUR" -type f -name "${h}.jsonl" -print | sed -n '1p')"
  if [ -z "$jf" ]; then printf 'net_fajla'; return 0; fi
  if grep -Fq '"toolName":"yield"' "$jf"; then printf 'yield'; return 0; fi
  if [ -n "$(find "$jf" -mmin +"$BROSHEN_TTL_MIN" -print)" ]; then
    printf 'broshen'
  else
    printf 'bezhit'
  fi
}

# [D15 pauza] ПАУЗА владельца — только строка registry/pauzy.tsv.
na_pauze() {  # <NNN>
  local f="$REPO/registry/pauzy.tsv" l
  [ -r "$f" ] || return 1
  while IFS= read -r l; do
    case "$l" in '#'*|'') continue ;; esac
    [ "${l%%$'\t'*}" = "$1" ] && return 0
  done < "$f"
  return 1
}
# [D18 done-uchet] done-тег закрывает слот предмета (локальные теги чекаута).
predmet_done() { [ -n "$(git -C "$REPO" tag -l "done/contracts/$1/*")" ]; }
# [D13 klass-riska] строка «КЛАСС РИСКА:» в contracts/<NNN>-*.md обязательна:
# нет файла ИЛИ нет строки — класс не определён (fail-closed, слово владельца 24.10).
# [D29 odnoznachnyj-istochnik-riska] класс читается по ВСЕМ файлам предмета:
# ноль файлов, нет строки в любом из них, значение вне алфавита (обычный|рисковый)
# или РАЗНЫЕ значения — класс не определён; «первый результат find» не каноничен
# (вердикт адверсария 140 вызов 1/2: один «рисковый» файл среди шести молча
# определял класс «обычный» — ревьюер шёл без адверсария). Перечень файлов
# сортируется LC_ALL=C — сообщение отказа детерминировано. Декларация —
# в любой позиции строки, хвост-основание допустим (норма roles/architect.md),
# вторая декларация в файле — неоднозначность.
klass_riska() {  # <NNN> → risikovyj|obychnyj|net_stroki:<…>|neodnoznachno:<файлы>
  local spisok f val znach='' ploh=''
  spisok="$(find "$REPO/contracts" -maxdepth 1 -name "$1-*.md" -print | LC_ALL=C sort)"
  if [ -z "$spisok" ]; then printf 'net_stroki:файлов contracts/%s-*.md нет' "$1"; return 0; fi
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    val="$(grep -E -o 'КЛАСС РИСКА:[[:blank:]]*(обычный|рисковый)([[:blank:].,;]|$)' "$f" 2>/dev/null \
          | sed -E -e 's/^КЛАСС РИСКА:[[:blank:]]*//' -e 's/[[:blank:].,;]$//')"
    case "$val" in
      обычный)  val='obychnyj' ;;
      рисковый) val='risikovyj' ;;
      *)        ploh="${ploh:+$ploh }$f"; continue ;;
    esac
    if [ -z "$znach" ]; then znach="$val"
    elif [ "$znach" != "$val" ]; then ploh="${ploh:+$ploh }$f"; fi
  done <<EOF
$spisok
EOF
  if [ -n "$ploh" ]; then printf 'neodnoznachno:%s' "$ploh"; return 0; fi
  printf '%s' "$znach"
}

# ── учёт (jq над JSONL; значения из замкнутых алфавитов) ────────────────────
poslednij_rabochij() {  # <NNN> → «holder<TAB>object<TAB>worktree<TAB>branch» | пусто
  jq -rs --arg r "$REPO_ID" --arg n "$1" '
    [ .[] | select(.t == "START" and .repoId == $r and .subjectId == $n and .klass == "rabochij") ]
    | last // empty
    | [ .holder, .object, .worktree, .branch ] | @tsv' "$LEDGER" 2>/dev/null
}
gruppa_ledger() {  # <NNN> → группа последнего рабочего START предмета | -
  local g
  g="$(jq -rs --arg r "$REPO_ID" --arg n "$1" '
    [ .[] | select(.t == "START" and .repoId == $r and .subjectId == $n and .klass == "rabochij") ]
    | last // {group: "-"} | .group' "$LEDGER" 2>/dev/null)"
  [ -n "$g" ] || g='-'
  printf '%s' "$g"
}
# [D11 uzhe-suzhen] судья роли ROL сдал на предмете (yield в его журнале).
subekt_suzhen_sudej() {  # <NNN> <rol>
  local holders h
  holders="$(jq -rs --arg r "$REPO_ID" --arg n "$1" --arg rol "$2" '
    [ .[] | select(.t == "START" and .repoId == $r and .subjectId == $n
                   and .klass == "sudja" and .rol == $rol) ]
    | map(.holder) | .[]' "$LEDGER" 2>/dev/null)"
  [ -n "$holders" ] || return 1
  while IFS= read -r h; do
    [ -n "$h" ] || continue
    [ "$(stare_holder "$h")" = 'yield' ] && return 0
  done <<EOF
$holders
EOF
  return 1
}
# Сверка по учёту: судья РОЛИ на OBJECT сдал (аргументы jq — из замкнутых
# алфавитов: rol из JUDGES, object 40-hex, subjectId [0-9]{3}; сравнения
# литеральные в самом фильтре, склеек из чужого текста нет).
subekt_suzhen_sudej_obj() {  # <NNN> <rol> <object>
  jq -se --arg r "$REPO_ID" --arg n "$1" --arg roli "$2" --arg o "$3" 'any(.[]; .t == "START" and .repoId == $r and .subjectId == $n and .klass == "sudja" and .rol == $roli and .object == $o)' "$LEDGER" >/dev/null 2>&1
}
# [D16 slovo] СЛОВО владельца — строка SLOVO в учёте (санкция сверх лимита).
slovo_vladelca() {  # <NNN>
  jq -se --arg r "$REPO_ID" --arg n "$1" \
    'any(.[]; .t == "SLOVO" and .repoId == $r and .subjectId == $n)' "$LEDGER" >/dev/null 2>&1
}
# Активные предметы группы: START без последующего RELEASE; done/ПАУЗА слот
# освобождают (слово владельца 2026-10-24 п.2/2а).
zhivye_subekty_gruppy() {  # <group> → «repoId/subjectId» построчно
  jq -rs --arg g "$1" '
    reduce .[] as $l (
      {};
      if $l.t == "START" then .[$l.repoId + "/" + $l.subjectId] = $l.group
      elif $l.t == "RELEASE" then .[$l.repoId + "/" + $l.subjectId] = null
      else . end
    ) | to_entries | map(select(.value != null and .value == $g)) | map(.key) | .[]' \
    "$LEDGER" 2>/dev/null
}
zhivykh_v_gruppe() {  # <group> [iskljuchit-NNN] → число (без done и ПАУЗ);
  # смена держателя предмета слот НЕ занимает второй раз (исключается сам предмет)
  # [D30 chuzhoj-reestr] done/ПАУЗА/исключение — ТОЛЬКО записи своего REPO_ID:
  # теги и паузы локального --repo о предмете чужого реестра не говорят;
  # запись чужого repoId занята до её RELEASE — fail-safe (отказ в лишнем
  # спавне, не пропуск дубля; РЕШЕНИЕ арбитража contracts-140-impl-v2-arbitraz,
  # блокер B1: локальный done освобождал слот чужой записи).
  local n s cnt=0 iskl="${2:-}"
  n="$(zhivye_subekty_gruppy "$1")"
  while IFS= read -r s; do
    [ -n "$s" ] || continue
    [ "${s%%/*}" = "$REPO_ID" ] || { cnt=$((cnt + 1)); continue; }
    [ "${s#*/}" = "$iskl" ] && continue
    predmet_done "${s#*/}" && continue
    na_pauze "${s#*/}" && continue
    cnt=$((cnt + 1))
  done <<EOF
$n
EOF
  printf '%s' "$cnt"
}

# ── замки ───────────────────────────────────────────────────────────────────
zamok_dir() { printf '%s/zamki/%s/%s' "$SOST" "$REPO_ID" "$1"; }
# [D22 atomarnost] мьютекс решения: mkdir атомарен между процессами; решение
# пакета целиком под мьютексами всех своих предметов.
mutex_zajavit() {  # <NNN> → 0 взят | 1 не взят
  local d i
  d="$(zamok_dir "$1")"
  mkdir -p "$d" 2>/dev/null || skip "замок не создать: $d"
  i=0
  while [ "$i" -lt 40 ]; do
    mkdir "$d/mutex" 2>/dev/null && return 0
    i=$((i + 1))
    sleep 0.05
  done
  return 1
}
mutexi_snyat_vse() {
  local s
  while IFS= read -r s; do
    [ -n "$s" ] && rmdir "$(zamok_dir "$s")/mutex" 2>/dev/null
  done <<EOF
$SUBJS
EOF
}
# [D19 gruppa-pina] группа — из remote origin worktree пина (единый источник git).
gruppa_iz_pina() {  # <worktree> → harness|mob|back|-
  local url base
  url="$(git -C "$1" remote get-url origin 2>/dev/null)" || url=''
  base="${url##*/}"; base="${base%.git}"
  if [ "$base" = 'dev-harness' ]; then printf 'harness'; return 0; fi
  if [ "$base" = "$GRP_MOB_REPO" ]; then printf 'mob'; return 0; fi
  if [ "$base" = "$GRP_BACK_REPO" ]; then printf 'back'; return 0; fi
  printf '-'
}

# ── разбор строк задания (грамматики 041; ровно одна строка каждого поля) ────
kolvo_strok() { printf '%s\n' "$1" | grep -cE "$2" || true; }
# [D5 jakor-subject] значение только из ЯКОРНОЙ строки ровно один раз.
predmet_iz() {  # <task> → «ok:<NNN>»|net|dva
  local t="$1" c v
  c="$(kolvo_strok "$t" 'SUBJECT=[0-9]{3}')"
  if [ "$c" = '0' ]; then printf 'net'; return 0; fi
  if [ "$c" -gt 1 ]; then printf 'dva'; return 0; fi
  v="$(printf '%s\n' "$t" | grep -E '^SUBJECT=[0-9]{3}$' | sed -n '1p' | cut -c9-11)"
  printf 'ok:%s' "$v"
}
# [D8 object-objazatelnost] OBJECT — ровно одна якорная строка 40-hex.
object_iz() {  # <task> → «ok:<40hex>»|net|dva
  local t="$1" c v
  c="$(kolvo_strok "$t" '^OBJECT=[0-9a-f]{40}$')"
  if [ "$c" = '0' ]; then printf 'net'; return 0; fi
  if [ "$c" -gt 1 ]; then printf 'dva'; return 0; fi
  v="$(printf '%s\n' "$t" | grep -E '^OBJECT=[0-9a-f]{40}$' | sed -n '1p' | cut -c8-47)"
  printf 'ok:%s' "$v"
}
# [D7 pin] пара WORKTREE/BRANCH — построчная форма грамматики 066, ровно одна;
# байт TAB исключён из класса значения литерально (норма 041: ERE-скобки НЕ
# знают \t — класс строится из настоящего байта TAB, а не из написания «\t»).
pin_iz() {  # <task> → «ok:<wt>|<br>»|net|gramm
  local t="$1" wc bc w b rxw rxb
  rxw="^WORKTREE=/[^${TAB}]+$"
  rxb="^BRANCH=wip/[0-9]{3}/[^${TAB}]+$"
  wc="$(kolvo_strok "$t" "$rxw")"
  bc="$(kolvo_strok "$t" "$rxb")"
  if [ "$wc" = '0' ] || [ "$bc" = '0' ]; then printf 'net'; return 0; fi
  if [ "$wc" -gt 1 ] || [ "$bc" -gt 1 ]; then printf 'gramm'; return 0; fi
  w="$(printf '%s\n' "$t" | grep -E "$rxw" | sed -n '1p' | cut -c10-)"
  b="$(printf '%s\n' "$t" | grep -E "$rxb" | sed -n '1p' | cut -c8-)"
  printf 'ok:%s|%s' "$w" "$b"
}

# ══════════════════════════════ --sudit ══════════════════════════════════════
sudit() {
  [ -n "$EVENT" ] && [ -f "$EVENT" ] || skip "события нет: $EVENT"
  # [D27 bityj-vhod] битое событие — именованный отказ, НЕ молчаливый пропуск.
  if ! N="$(jq -r '(.tasks // [.]) | length' "$EVENT" 2>/dev/null)"; then
    otp BITYJ_VHOD 'событие не разбирается (tasks/flat)'
  fi
  case "$N" in ''|*[!0-9]*) otp BITYJ_VHOD 'длина items не число' ;; esac
  [ "$N" -gt 0 ] || otp BITYJ_VHOD 'items пуст'

  # проход 1: грамматика всех gated items; НИ ОДНОЙ записи до полного решения
  GATED=''
  local i=0 agent name task in_w in_j s sv p wt br o obj klass rol r
  while [ "$i" -lt "$N" ]; do
    agent="$(jq -r "(.tasks // [.])[$i].agent // \"\"" "$EVENT" 2>/dev/null)" \
      || otp BITYJ_VHOD "item $i: agent не читается"
    name="$(jq -r "(.tasks // [.])[$i].name // \"\"" "$EVENT" 2>/dev/null)" \
      || otp BITYJ_VHOD "item $i: name не читается"
    task="$(jq -r "(.tasks // [.])[$i].task // \"\"" "$EVENT" 2>/dev/null)" \
      || otp BITYJ_VHOD "item $i: task не читается"
    [ -n "$agent" ] || otp AGENT_NET "item $i: agent отсутствует"
    # [D28 proch-agent] роли вне классов (scout/task/sonic/arbiter/…) — пропуск.
    in_w=0; in_j=0
    for r in $WORKERS; do [ "$r" = "$agent" ] && in_w=1; done
    for r in $JUDGES;  do [ "$r" = "$agent" ] && in_j=1; done
    if [ "$in_w" -eq 0 ] && [ "$in_j" -eq 0 ]; then i=$((i + 1)); continue; fi
    # [D4 imja] holder обязан быть именован — иначе журнал состояний нечитаем.
    case "$name" in
      ''|*[!A-Za-z0-9._-]*) otp IMJA_NET "item $i: имя «$name» пусто/вне [A-Za-z0-9._-]" ;;
    esac
    s="$(predmet_iz "$task")"
    case "$s" in
      ok:*) sv="${s#ok:}" ;;
      net)  otp SUBJECT_NET_V_ZADANII "item $i: строка ^SUBJECT=[0-9]{3}\$ отсутствует" ;;
      dva)  otp SUBEKT_DVA_V_ZADANII "item $i: строк SUBJECT= больше одной" ;;
      *)    otp GRAMMATIKA_SUBEKTA "item $i: SUBJECT вне грамматики [0-9]{3}" ;;
    esac
    if [ "$in_w" -eq 1 ]; then
      p="$(pin_iz "$task")"
      case "$p" in
        ok:*) wt="${p#ok:}"; wt="${wt%%|*}"; br="${p#ok:}"; br="${br#*|}" ;;
        net)  otp PIN_NET "item $i: пара ^WORKTREE=/… ^BRANCH=wip/<NNN>/… отсутствует" ;;
        *)    otp GRAMMATIKA_PINA "item $i: пара пина вне грамматики (дубли строк)" ;;
      esac
      # [D6 pin-rashozhdenie] номер ветки == номер предмета.
      [ "$(printf '%s' "${br#wip/}" | cut -c1-3)" = "$sv" ] \
        || otp RASHOZHDENIE_PINA "item $i: BRANCH=wip/$(printf '%s' "${br#wip/}" | cut -c1-3)/… ≠ SUBJECT=$sv"
      [ -d "$wt" ] || skip "worktree пина нет: $wt"
      git -C "$wt" rev-parse --git-dir >/dev/null 2>&1 || skip "worktree пина не репо: $wt"
      obj='-'; klass='rabochij'; rol="$agent"
    else
      o="$(object_iz "$task")"
      case "$o" in
        ok:*) obj="${o#ok:}" ;;
        net)  otp OBJECT_OTSTUTSVUET "item $i: строка ^OBJECT=[0-9a-f]{40}\$ отсутствует" ;;
        dva)  otp SUBEKT_DVA_OBJECTA "item $i: строк OBJECT= больше одной" ;;
        *)    otp GRAMMATIKA_OBJECTA "item $i: OBJECT вне грамматики 40-hex" ;;
      esac
      wt='-'; br='-'; klass='sudja'; rol="$agent"
    fi
    GATED="${GATED}${i}|${agent}|${name}|${sv}|${obj}|${wt}|${br}|${klass}|${rol}
"
    i=$((i + 1))
  done
  # gated нет — спавн вне участка (scout/task/sonic/…): пропуск БЕЗ записей
  if [ -z "$GATED" ]; then printf 'PROPUST: gated items нет\n'; exit 0; fi

  # ПАУЗА владельца — реестр; судится ДО замков, для всех gated предметов.
  while IFS='|' read -r _ _ _ psv _ _ _ _ _; do
    [ -n "$psv" ] || continue
    na_pauze "$psv" && otp PAUZA_VLADELTSA "предмет $psv стоит на ПАУЗЕ владельца (registry/pauzy.tsv)"
  done <<EOF
$GATED
EOF

  # [D20 dubl-v-pakete] два gated item на один предмет в одном вызове.
  DUBL="$(printf '%s' "$GATED" | cut -d'|' -f4 | sort | uniq -d | sed -n '1p')"
  [ -z "$DUBL" ] || otp DUBL_V_PAKETE "два элемента пакета на предмет $DUBL"

  # мьютексы всех предметов пакета (отсортированы — общий порядок у конкурентов)
  SUBJS="$(printf '%s' "$GATED" | cut -d'|' -f4 | sort -u)"
  local ms
  while IFS= read -r ms; do
    [ -n "$ms" ] || continue
    if ! mutex_zajavit "$ms"; then
      mutexi_snyat_vse
      otp ZANYATO_RESHENIEM "предмет $ms: мьютекс решения занят (параллельный суд)"
    fi
  done <<EOF
$SUBJS
EOF

  # [D26 paket-otkat] суд под мьютексами; записи — только после решения по ВСЕМУ пакету
  while IFS='|' read -r idx agent name sv obj wt br klass rol; do
    [ -n "$sv" ] || continue
    zdir="$(zamok_dir "$sv")"
    if [ -d "$zdir/zanyat" ] && [ -f "$zdir/zanyat/holder.json" ]; then
      h_holder="$(jq -r '.holder // ""' "$zdir/zanyat/holder.json" 2>/dev/null)"
      h_klass="$(jq -r '.klass // ""' "$zdir/zanyat/holder.json" 2>/dev/null)"
      case "$(stare_holder "$h_holder")" in
        yield) : ;;
        bezhit)
          mutexi_snyat_vse
          if [ "$h_klass" = 'sudja' ]; then
            # [D21 vtoroj-sudja] живой судья — второй судья на предмет запрещён.
            otp SUDJA_ZHIV "предмет $sv: судья $h_holder бежит без сдачи — второй судья запрещён"
          fi
          # [D1 dubl-rabochego] живой рабочий — дубль запрещён (боль 122: v4+v4b).
          otp RABOCHIJ_ZHIV "предмет $sv: рабочий $h_holder бежит без сдачи — дубль запрещён"
          ;;
        broshen|net_fajla)
          mutexi_snyat_vse
          # [D3 broshennyj-zamok] рестарт ≠ разрешение: дубль после рестарта — отказ.
          otp ZAMOK_BROSHEN "предмет $sv: holder $h_holder без сдачи и без записей >${BROSHEN_TTL_MIN} мин — только --osvobodit, НЕ авто-перезапуск"
          ;;
      esac
      # [D11 uzhe-suzhen] повторный круг ТОЙ ЖЕ РОЛИ на ТОМ ЖЕ OBJECT — отказ
      # (боль 117: 7×); другая роль тот же OBJECT судит свободно (конвейер).
      if [ "$klass" = 'sudja' ] && subekt_suzhen_sudej_obj "$sv" "$rol" "$obj"; then
        mutexi_snyat_vse
        otp OBJECT_UZHE_SUZHEN "предмет $sv: OBJECT $obj уже судился ролью $rol; исправительный круг — новый sha"
      fi
    fi
    if [ "$klass" = 'sudja' ]; then
      rab="$(poslednij_rabochij "$sv")"
      if [ -z "$rab" ]; then
        # [D12 rabochego-net] судья без автора предмета — судить нечего.
        mutexi_snyat_vse; otp RABOCHEGO_NET "предмет $sv: рабочего START в учёте нет"
      fi
      r_holder="$(printf '%s' "$rab" | cut -f1)"
      r_wt="$(printf '%s' "$rab" | cut -f3)"
      r_br="$(printf '%s' "$rab" | cut -f4)"
      # [D10 avtor-sdal] судья — только после yield автора (журнал, независимо
      # от замка: замок мог быть освобождён --osvobodit при живом авторе).
      [ "$(stare_holder "$r_holder")" = 'yield' ] || {
        mutexi_snyat_vse
        otp AVTOR_ESHCHO_RABOTAET "предмет $sv: автор $r_holder не сдал (yield в журнале отсутствует)"
      }
      # [D9 object-sovpadaet] OBJECT == живой tip ветки автора.
      tip="$(git -C "$r_wt" rev-parse --verify "$r_br" 2>/dev/null)" || {
        mutexi_snyat_vse
        otp VETKA_NEDOSTUPNA "предмет $sv: ветка $r_br в $r_wt не читается — OBJECT не сверить"
      }
      [ "$tip" = "$obj" ] || {
        mutexi_snyat_vse
        otp OBJECT_RASHODITSJA "предмет $sv: OBJECT задания $obj ≠ tip ветки $r_br ($tip)"
      }
      # Строка КЛАСС РИСКА обязательна (слово владельца 2026-10-24); [D29]
      # класс определён только при согласии ВСЕХ contracts/<NNN>-*.md — иначе
      # отказ с перечнем неоднозначных файлов (голый net_stroki — от мутаций
      # стабов над klass_riska — отказывается тем же именем).
      kr="$(klass_riska "$sv")"
      case "$kr" in
        risikovyj|obychnyj) : ;;
        *)
          mutexi_snyat_vse
          otp KLASS_RISKA_NET "предмет $sv: класс риска неоднозначно определён (${kr%%:*}); файлы: ${kr#*:}"
          ;;
      esac
      # [D14 adv-do-rev] рисковый предмет: ревьюер — после завершённого адверсария.
      if [ "$kr" = 'risikovyj' ] && [ "$rol" = 'reviewer' ]; then
        if ! subekt_suzhen_sudej "$sv" 'adversary'; then
          mutexi_snyat_vse
          otp ADVERSARIJ_DO_REVJUERA "предмет $sv рисковый, завершённого адверсария в учёте нет — ревьюер раньше адверсария запрещён"
        fi
      fi
    else
      grp="$(gruppa_iz_pina "$wt")"
      case "$grp" in
        harness) cap="$CAP_HARNESS" ;;
        mob)     cap="$CAP_MOB" ;;
        back)    cap="$CAP_BACK" ;;
        *)       cap=0 ;;
      esac
      if [ "$cap" -gt 0 ]; then
        zhivo="$(zhivykh_v_gruppe "$grp" "$sv")"
        # [D25 limit-gruppy] слот 3/3/3 (слово владельца 2026-10-28: 1/3/2 → 3/3/3); СЛОВО и done — в учёте (реестр).
        if [ "$zhivo" -ge "$cap" ] && ! slovo_vladelca "$sv"; then
          mutexi_snyat_vse
          otp LIMIT_GRUPPY "группа $grp: занято $zhivo из $cap (предмет $sv); сверх лимита — только СЛОВО владельца (строка SLOVO)"
        fi
      fi
    fi
  done <<EOF
$GATED
EOF

  # [D23 start-do-razdachi] решение «позволено ВСЕМ» → занятия + START, потом rc 0
  local grp2
  while IFS='|' read -r idx agent name sv obj wt br klass rol; do
    [ -n "$sv" ] || continue
    if [ "$klass" = 'rabochij' ]; then grp2="$(gruppa_iz_pina "$wt")"
    else grp2="$(gruppa_ledger "$sv")"; fi
    zdir="$(zamok_dir "$sv")"
    mkdir -p "$zdir/zanyat" 2>/dev/null || skip "занятие не создать: $zdir/zanyat"
    printf '{"holder":"%s","klass":"%s","rol":"%s","object":"%s","startedAt":"%s"}\n' \
      "$name" "$klass" "$rol" "$obj" "$(ts_now)" > "$zdir/zanyat/holder.json"
    jq -nc --arg t START --arg r "$REPO_ID" --arg s "$sv" --arg g "$grp2" \
          --arg h "$name" --arg k "$klass" --arg ro "$rol" --arg o "$obj" \
          --arg w "$wt" --arg b "$br" --arg at "$(ts_now)" \
      '{t:$t,repoId:$r,subjectId:$s,group:$g,holder:$h,klass:$k,rol:$ro,object:$o,worktree:$w,branch:$b,at:$at}' \
      >> "$LEDGER"
    printf 'PUSCHEM %s %s/%s (%s/%s)\n' "$name" "$REPO_ID" "$sv" "$klass" "$rol"
  done <<EOF
$GATED
EOF

  mutexi_snyat_vse
  exit 0
}

# ═════════════════════════════ --osvobodit ═══════════════════════════════════
osvobodit() {
  [ -n "$NNN_ARG" ] && [ -n "$HOLDER_ARG" ] || usage
  case "$NNN_ARG" in
    [0-9][0-9][0-9]) ;;
    *) otp GRAMMATIKA_SUBEKTA "NNN «$NNN_ARG» вне [0-9]{3}" ;;
  esac
  case "$HOLDER_ARG" in
    ''|*[!A-Za-z0-9._-]*) otp GRAMMATIKA_IMENI "holder «$HOLDER_ARG» вне алфавита" ;;
  esac
  zdir="$(zamok_dir "$NNN_ARG")"
  [ -d "$zdir/zanyat" ] || otp NET_ZAMKA "предмет $NNN_ARG замка не держит"
  if ! mutex_zajavit "$NNN_ARG"; then
    # [D3b stale-mutex] мьютекс решения, переживший сбой, подбирается здесь.
    if [ -n "$(find "$zdir/mutex" -maxdepth 0 -mmin +"$MUTEX_STALE_MIN" -print 2>/dev/null)" ]; then
      rm -rf "$zdir/mutex"
      mutex_zajavit "$NNN_ARG" || otp ZANYATO_RESHENIEM "предмет $NNN_ARG: мьютекс занят и не подбирается"
    else
      otp ZANYATO_RESHENIEM "предмет $NNN_ARG: мьютекс решения занят (моложе ${MUTEX_STALE_MIN} мин — живой суд)"
    fi
  fi
  h_holder="$(jq -r '.holder // ""' "$zdir/zanyat/holder.json" 2>/dev/null)"
  if [ "$h_holder" != "$HOLDER_ARG" ]; then
    rmdir "$zdir/mutex" 2>/dev/null
    otp DERZHATEL_RASHODITSJA "в замке $h_holder, освободить просят $HOLDER_ARG"
  fi
  case "$(stare_holder "$h_holder")" in
    yield) prichina='yield' ;;
    broshen|net_fajla) prichina='broshen' ;;
    bezhit)
      rmdir "$zdir/mutex" 2>/dev/null
      # [D24 zhit-zamok] живой замок не освобождается — это и есть дубль-дверь.
      otp ZAMOK_ZHIV "holder $h_holder пишет в журнал свежее (без yield) — живой замок не освобождается"
      ;;
  esac
  rm -rf "$zdir/zanyat"
  jq -nc --arg t RELEASE --arg r "$REPO_ID" --arg s "$NNN_ARG" --arg h "$h_holder" \
        --arg p "$prichina" --arg at "$(ts_now)" \
    '{t:$t,repoId:$r,subjectId:$s,holder:$h,prichina:$p,at:$at}' >> "$LEDGER"
  rmdir "$zdir/mutex" 2>/dev/null
  printf 'OSVOBOZHDEN %s/%s holder=%s prichina=%s\n' "$REPO_ID" "$NNN_ARG" "$h_holder" "$prichina"
  exit 0
}

# ══════════════════════════════ --uchet ══════════════════════════════════════
uchet() {
  local aktiven r s g h k st
  aktiven="$(jq -rs '
    reduce .[] as $l (
      {};
      if $l.t == "START" then .[$l.repoId + "/" + $l.subjectId] = {repoId:$l.repoId, subjectId:$l.subjectId, group:$l.group, holder:$l.holder, klass:$l.klass}
      elif $l.t == "RELEASE" then .[$l.repoId + "/" + $l.subjectId] = null
      else . end
    ) | to_entries | map(select(.value != null)) | map(.value) | .[] |
    [ .repoId, .subjectId, .group, .holder, .klass ] | @tsv' "$LEDGER" 2>/dev/null)"
  while IFS="$(printf '\t')" read -r r s g h k; do
    [ -n "$s" ] || continue
    st="$(stare_holder "$h")"
    # [D30 chuzhoj-reestr] done/ПАУЗА — источники СВОЕГО реестра (--repo):
    # состояние записи чужого repoId по локальным тегам/паузам не вычисляется
    # (ложный done прятал живой чужой слот — блокер B1 арбитража
    # contracts-140-impl-v2-arbitraz).
    if [ "$r" = "$REPO_ID" ]; then
      if predmet_done "$s"; then st='done'; fi
      if na_pauze "$s"; then st='pauza'; fi
    fi
    printf 'UCHET\t%s\t%s\t%s\t%s\t%s\t%s\n' "$r" "$s" "$g" "$h" "$k" "$st"
  done <<EOF
$aktiven
EOF
  printf 'GRP\tharness\t%s\t%s\n' "$(zhivykh_v_gruppe harness)" "$CAP_HARNESS"
  printf 'GRP\tmob\t%s\t%s\n'    "$(zhivykh_v_gruppe mob)"     "$CAP_MOB"
  printf 'GRP\tback\t%s\t%s\n'   "$(zhivykh_v_gruppe back)"    "$CAP_BACK"
  exit 0
}

case "$MODE" in
  --sudit)     sudit ;;
  --osvobodit) osvobodit ;;
  --uchet)     uchet ;;
  *) usage ;;
esac
