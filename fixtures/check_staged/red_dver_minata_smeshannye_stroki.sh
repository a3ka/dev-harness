#!/usr/bin/env bash
# КРАСНОЕ по адверсарию 031 двумя кругами: к1 (verdicts/adversary/contracts-031-v1.md,
# ремонт п.3) — СМЕШАННЫЕ строки манифеста, ворота м1/м3 ЗАКРЫТЫ фиксом 6cdcf9c
# (all-lines predicate для непустых строк — регрессионные контроли); к2
# (verdicts/adversary/contracts-031-v2.md) — ПУСТАЯ добавленная строка, ворота
# м4/м5, красные ДО фикса. Инвариант обоих — замороженный 031/4, механизм 1, условие 2.
#
# ОБХОД (измерен адверсарием на toy-репо обоими путями, 57bb16a): и дверь минта
# (scripts/check_staged.sh:445-446), и минт-признание (scripts/check_zones.sh:412-413)
# прогоняют добавленные строки через sed-фильтр грамматики «^[0-9]{3} → [0-9a-f]{40}$»
# и отказывают ТОЛЬКО если фильтр оставил пустоту. Манифест с ВАЛИДНОЙ добавкой +
# НЕВАЛИДНОЙ добавкой (ASCII-стрелка «->» вместо U+2192) проходит: мусор молча
# выброшен, судится подмножество. Нарушено условие 2 механизма 1 frozen 031/4:
# грамматику обязана держать КАЖДАЯ добавленная строка (all-lines predicate).
#
# ОБХОД к2 (измерен адверсарием на toy-репо обоими путями, вердикт на 64b0ae9):
# счётчики добавок add_count (check_staged.sh:439) и mint_add (check_zones.sh:405)
# считают awk-предикатом /^\+[^+]/ — символ ПОСЛЕ плюса обязателен. Git показывает
# добавление пустой строки в diff -U0 единственным байтом «+» (bare plus): пустая
# добавка не входит НИ в счётчик, НИ в sed-отфильтрованные added_lines. Дельта
# «валидная строка + пустая строка» даёт valid_count == add_count == 1 —
# all-lines predicate ложно сходится, проходят ОБА пути (staged-дверь и признание).
#
# ВХОДЫ (Н-39 — привязка к ветвям ПО КОДУ потребителей, не по прозе контракта):
#   м0  ПОЗИТИВ двери: ОДНА валидная строка «N → sha» полным резервом церемонии
#       авторитета (аннотированный тег запушен на origin, main) → check_staged
#       rc 0 + judged «дверь минта 031» — ЗЕЛЁНОЕ и ДО, и ПОСЛЕ фикса (позитив +N
#       не задет, ветвь check_staged.sh:551-552);
#   м1  ВОРОТА 1 (ЗАКРЫТО к1-фиксом — регрессионный контроль): staged-дельта с ДВУМЯ добавками — валидная
#       «N → sha» + невалидная «N -> sha»; ОБА тега живы, аннотированы, запушены,
#       sha строки = tag-object-sha — вход конформен во всём, КРОМЕ стрелки →
#       check_staged ОБЯЗАН rc 1 «дверь минта 031: строка не по грамматике
#       манифеста» (check_staged.sh:447). До к1-фикса sed-фильтр выбрасывал
#       невалидную строку, дверь была зелёная «+1 строк» — предъявляемое красное;
#   м2  ПОЗИТИВ признания: та же одна валидная строка, ЗАКОММИЧЕННАЯ фактическим
#       автором orchestrator в открытом окне toy-контракта → check_zones rc 0 —
#       ЗЕЛЁНОЕ и ДО, и ПОСЛЕ (честный минт признаётся, ветвь skip_path
#       check_zones.sh:443-445);
#   м3  ВОРОТА 2 (ЗАКРЫТО к1-фиксом — регрессионный контроль): смешанная дельта (валидная + невалидная
#       добавка) ЗАКОММИЧЕНА orchestrator'ом → check_zones ОБЯЗАН rc 1 «коммит
#       вне зоны … дверь минта 031: строка не по грамматике манифеста»
#       (check_zones.sh:414). До к1-фикса признание судило подмножество и молчало —
#       предъявляемое красное.
#   м4  ВОРОТА 3 (красное СЕГОДНЯ, к2): staged-дельта = валидная «N → sha» +
#       ПУСТАЯ добавленная строка (физический перенос строки после валидной;
#       в diff -U0 это bare «+») → check_staged ОБЯЗАН rc 1 «дверь минта 031:
#       строка не по грамматике манифеста» (check_staged.sh:453). Сегодня bare +
#       не считается add_count (:439), 1==1 — дверь зелёная «+1 строк» —
#       предъявляемое красное;
#   м5  ВОРОТА 4 (красное СЕГОДНЯ, к2): та же дельта (валидная + пустая строка)
#       закоммичена фактическим автором orchestrator через
#       git -c core.hooksPath=/dev/null commit (commit_kak) → check_zones ОБЯЗАН
#       rc 1 «коммит вне зоны … дверь минта 031: строка не по грамматике
#       манифеста» (check_zones.sh:420). Сегодня mint_add (:405) так же не видит
#       bare +, признание судит подмножество и молчит — предъявляемое красное.
#
# Судимые коммиты создаёт commit_kak — ФАКТИЧЕСКИЙ автор локального конфига
# (set_author); помощник g несёт «-c user.name=Фикстура», перекрывающий конфиг, —
# механизм дыры Б1 (вердикт арбитра 9f86d1c). Ворота м2/м3/м5 ассертят %an ==
# orchestrator ДО вызова судьи: предъявление проверяет само предъявление.
#
# Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (А-82, прецедент red_dver_minta_
# orkestratora.sh): до фикса предмет предъявляется ПРЯМЫМ запуском; конверсия в
# case_* не планована — CI-ветви несут case_dver_minta_*.sh. Фикстура ДВУХФАЗНАЯ:
# сегодня красна именованными воротами м4/м5 (м1/м3 закрыты к1-фиксом и держат
# регрессию), после подсчёта ВСЕХ строк добавления, включая bare +, в ОБОИХ
# потребителях все ворота зелёные (м0/м2 — позитивные контроли, отличающие фикс
# от вечнокрасной пробы).
#
# ПАРАМЕТРИЗАЦИЯ СЛУЧАЙНЫМИ ВХОДАМИ (А-88): NNN из НЕПЕРЕСЕКАЮЩИХСЯ поддиапазонов
# поддиапазонов 020–119 — всё пространство семьи 031 и ВНЕ занятых фикстурами 023
# (120–939), чтобы обёртка с константным dispatch не собиралась ни на одном
# прогоне; имена toy-корней и копии субъекта случайны (BARRIER_ROOT-паттерн:
# копия каталога scripts/ сохраняет соседство sourcing'а lib_zones/next_id).
#
# Охрана «судья не создаёт тег id/*» (правило 8 — ожидание в памяти): снимок
# id-тегов ДО вызова против ПОСЛЕ на каждом судимом репо.
#
# Коды возврата: 0 — ворота пройдены (после фикса); 1 — именованный отказ ворота
#               (сегодня красны м4/м5 — м1/м3 закрыты к1-фиксом; позитив м0/м2 зелёный).
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
WORK="$(mktemp -d /tmp/red031mix.XXXXXX)"   # А-78: свежий WORK вне дерева
trap 'rm -rf "$WORK"' EXIT

# ── случайные входы: м0 020-049 · м1 050-064 (валидная) + 065-079 (ASCII) ·
# м2 080-089 · м3 090-094 (валидная) + 095-099 (ASCII) · м4 100-109 · м5 110-119 · хвост — имена каталогов.
mapfile -t RD < <(awk 'BEGIN{srand();
  printf "%03d\n", 20+int(rand()*30);
  printf "%03d\n", 50+int(rand()*15);
  printf "%03d\n", 65+int(rand()*15);
  printf "%03d\n", 80+int(rand()*10);
  printf "%03d\n", 90+int(rand()*5);
  printf "%03d\n", 95+int(rand()*5);
  printf "%03d\n", 100+int(rand()*10);
  printf "%03d\n", 110+int(rand()*10);
  for (i=0;i<10;i++) printf "%d\n", 10000000+int(rand()*89999999)}')
M0="${RD[0]}"; M1V="${RD[1]}"; M1I="${RD[2]}"; M2="${RD[3]}"; M3V="${RD[4]}"; M3I="${RD[5]}"; M4="${RD[6]}"; M5="${RD[7]}"

# Субъект — копия scripts/ под случайным именем (BARRIER_ROOT-паттерн).
BARRIER="$WORK/subj-${RD[8]}"
cp -r "$REPO/scripts" "$BARRIER"
# shellcheck disable=SC1091
. "$HERE/_repo.sh"

id_tags_of() { git -C "$1" for-each-ref --format='%(refname)' 'refs/tags/id/'; }
assert_no_new_id_tags() {  # <корень> <снимок-до>
  novye="$(comm -13 <(printf '%s\n' "$2" | sort) <(printf '%s\n' "$(id_tags_of "$1")" | sort))"
  if [ -n "${novye//$'\n'/}" ]; then
    printf 'ОТКАЗ: судья создал тег выдачи id/* — мера изменила предмет (%s): %s\n' "$1" "$novye" >&2
    exit 1
  fi
}

# make_repo_orchzone: toy с замороженным контрактом 001, несущим зоны implementer
# (scripts/) И orchestrator (HANDOFF.md). orchestrator ОБЯЗАН быть зонирован —
# иначе «не судится» до суда путей и обход плацебо-зелёный (урок ЗЗ 018).
make_repo_orchzone() {  # <корень>
  local r="$1"
  mkdir -p "$r/contracts" "$r/scripts" "$r/verdicts/critic"
  {
    printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\n'
    printf 'ЗОНА implementer: scripts/\n'
    printf 'ЗОНА orchestrator: HANDOFF.md\n'
  } > "$r/contracts/001-x.md"
  printf 'исходный файл в зоне\n' > "$r/scripts/a.sh"
  printf '# передача\n' > "$r/HANDOFF.md"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.name orchestrator
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.email orchestrator@local
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config commit.gpgsign false
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config core.hooksPath /dev/null
  g "$r" add -A
  g "$r" commit -q -m 'основание: контракт и зоны implementer+orchestrator'
  g "$r" tag -a frozen/contracts/001/1 -m 'контракт утверждён'
}

# mint_tag_avtoritet <корень> <NNN>: АВТОРИТЕТНАЯ половина церемонии —
# аннотированный тег + пуш тега на origin (манифестную строку НЕ пишет: строка —
# предмет суда, её stage'ит orchestrator). Грамматика строки — дословно 023/031:
# «NNN → tag-object-sha».
mint_tag_avtoritet() {  # <корень> <NNN>
  local r="$1" n="$2"
  g "$r" tag -a "id/CONTRACT/$n" -m 'выдача механизмом (фикстура: авторитетная половина)'
  g "$r" push -q origin "refs/tags/id/CONTRACT/$n"
}

# stage_row <корень> <NNN> <sha>: orchestrator stage'ит ВАЛИДНУЮ строку
# грамматики (U+2192, tag-object-sha) — НЕ коммитит, судится staged-множество.
stage_row() {  # <корень> <NNN> <sha>
  local r="$1" n="$2" sha="$3"
  mkdir -p "$r/registry"
  printf '%s → %s\n' "$n" "$sha" >> "$r/registry/contracts.tsv"
  g "$r" add -A
}

# stage_row_ascii <корень> <NNN> <sha>: НЕВАЛИДНАЯ добавка — ASCII-стрелка «->»
# вместо U+2192; прочее (NNN ровно %03d, 40-hex tag-object-sha живого тега)
# конформно — контрпример расходится с честным входом РОВНО классом грамматики
# стрелки (демаркация: инвариантность к значениям ∧ расхождение на конформном
# входе; класс один — один вход).
stage_row_ascii() {  # <корень> <NNN> <sha>
  local r="$1" n="$2" sha="$3"
  mkdir -p "$r/registry"
  printf '%s -> %s\n' "$n" "$sha" >> "$r/registry/contracts.tsv"
  g "$r" add -A
}

# stage_row_pustaja <корень> <NNN> <sha>: добавка-контрпример к2 — ПУСТАЯ строка
# (физический перенос строки) после валидной; в diff -U0 это bare «+», который
# awk /^\+[^+]/ не считает (Н-39: привязка к ветви КОДА — счётчики add_count
# check_staged.sh:439 / mint_add check_zones.sh:405). Валидная строка несёт полную
# церемонию (U+2192, tag-object-sha живого запушенного тега) — контрпример
# расходится с честным входом РОВНО наличием пустой добавленной строки
# (демаркация к2: инвариантность к значениям ∧ расхождение на конформном входе).
stage_row_pustaja() {  # <корень> <NNN> <sha>
  local r="$1" n="$2" sha="$3"
  mkdir -p "$r/registry"
  printf '%s → %s\n\n' "$n" "$sha" >> "$r/registry/contracts.tsv"
  g "$r" add -A
}

# commit_kak <корень> <сообщение>: коммит АВТОРОМ ЛОКАЛЬНОГО КОНФИГА репо
# (set_author), БЕЗ -c-перекрытия user.name — g() несёт «-c user.name=Фикстура»,
# перекрывающий конфиг (механизм дыры Б1, вердикт арбитра 9f86d1c, замер 1).
commit_kak() {  # <корень> <сообщение>
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$1" -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -q -m "$2"
}

# assert_an_orchestrator <корень> <ворота>: судимый коммит несёт ФАКТИЧЕСКОГО
# автора orchestrator (критерий 2 вердикта 9f86d1c).
assert_an_orchestrator() {  # <корень> <ворота>
  local an
  an="$(git -C "$1" log -1 --format=%an)"
  if [ "$an" != orchestrator ]; then
    printf 'ОТКАЗ: %s: судимый коммит несёт автора «%s», ожидан orchestrator — предъявление подменено (Б1, вердикт 9f86d1c): %s\n' "$2" "$an" "$1" >&2
    exit 1
  fi
}

run_bar() {  # <корень> → stdout/stderr в $BAR_OUT/$BAR_ERR, rc в $BAR_RC
  BAR_OUT="$("$BARRIER/check_staged.sh" "$1" 2>"$WORK/bar_err")" && BAR_RC=0 || BAR_RC=$?
  BAR_ERR="$(cat "$WORK/bar_err")"
}

run_cz() {  # <корень> → stdout/stderr в $CZ_OUT/$CZ_ERR, rc в $CZ_RC
  CZ_OUT="$(bash "$BARRIER/check_zones.sh" "$1" 2>"$WORK/cz_err")" && CZ_RC=0 || CZ_RC=$?
  CZ_ERR="$(cat "$WORK/cz_err")"
}

# ── м0: ПОЗИТИВ двери — одна валидная строка (ЗЕЛЁНОЕ ДО и ПОСЛЕ фикса) ────────
T="$WORK/kor-${RD[9]}"
make_repo_orchzone "$T"
toy_origin "$T" >/dev/null
mint_tag_avtoritet "$T" "$M0"
set_author "$T" orchestrator
stage_row "$T" "$M0" "$(git -C "$T" rev-parse "refs/tags/id/CONTRACT/$M0")"
id0="$(id_tags_of "$T")"
run_bar "$T"
assert_no_new_id_tags "$T" "$id0"
if [ "$BAR_RC" -ne 0 ] || ! printf '%s' "$BAR_OUT" | grep -qF 'дверь минта 031'; then
  printf 'ОТКАЗ: м0 позитив +N: одна валидная строка «%s → sha» обязана проходить дверь (rc 0, judged «дверь минта 031»); получил rc=%s out=%s err=%s\n' \
    "$M0" "$BAR_RC" "$BAR_OUT" "$BAR_ERR" >&2
  exit 1
fi

# ── м1: ВОРОТА 1 — валидная + невалидная (ASCII) добавка в ОДНОЙ staged-дельте ─
# ЗАКРЫТО к1-фиксом (6cdcf9c): rc 1 именем грамматики (all-lines predicate).
# До к1-фикса sed-фильтр молча выбрасывал невалидную строку — дверь зелёная.
T="$WORK/kor-${RD[10]}"
make_repo_orchzone "$T"
toy_origin "$T" >/dev/null
mint_tag_avtoritet "$T" "$M1V"
mint_tag_avtoritet "$T" "$M1I"
set_author "$T" orchestrator
stage_row "$T" "$M1V" "$(git -C "$T" rev-parse "refs/tags/id/CONTRACT/$M1V")"
stage_row_ascii "$T" "$M1I" "$(git -C "$T" rev-parse "refs/tags/id/CONTRACT/$M1I")"
id0="$(id_tags_of "$T")"
run_bar "$T"
assert_no_new_id_tags "$T" "$id0"
if [ "$BAR_RC" -ne 1 ] || ! printf '%s' "$BAR_ERR" | grep -qF 'дверь минта 031: строка не по грамматике манифеста'; then
  printf 'ОТКАЗ: м1 смешанные строки: дверь минта обязана отказать именем грамматики на staged-дельте с валидной «%s → sha» + невалидной «%s -> sha» (обе церемонией авторитета); получил rc=%s out=%s err=%s\n' \
    "$M1V" "$M1I" "$BAR_RC" "$BAR_OUT" "$BAR_ERR" >&2
  exit 1
fi

# ── м2: ПОЗИТИВ признания — честный минт закоммичен (ЗЕЛЁНОЕ ДО и ПОСЛЕ) ───────
T="$WORK/korcz-${RD[11]}"
make_repo_orchzone "$T"
toy_origin "$T" >/dev/null
mint_tag_avtoritet "$T" "$M2"
set_author "$T" orchestrator
stage_row "$T" "$M2" "$(git -C "$T" rev-parse "refs/tags/id/CONTRACT/$M2")"
commit_kak "$T" "манифест: выдача $M2"
assert_an_orchestrator "$T" м2
id0="$(id_tags_of "$T")"
run_cz "$T"
assert_no_new_id_tags "$T" "$id0"
if [ "$CZ_RC" -ne 0 ]; then
  printf 'ОТКАЗ: м2 позитив признания: честный минт «%s → sha» автором orchestrator обязан признаваться (rc 0); получил rc=%s out=%s err=%s\n' \
    "$M2" "$CZ_RC" "$CZ_OUT" "$CZ_ERR" >&2
  exit 1
fi

# ── м3: ВОРОТА 2 — смешанная дельта ЗАКОММИЧЕНА orchestrator'ом ────────────────
# ЗАКРЫТО к1-фиксом (6cdcf9c): rc 1 «коммит вне зоны … строка не по грамматике
# манифеста» (признание НЕ срабатывает). До к1-фикса признание судило
# подмножество и молчало.
T="$WORK/korcz-${RD[12]}"
make_repo_orchzone "$T"
toy_origin "$T" >/dev/null
mint_tag_avtoritet "$T" "$M3V"
mint_tag_avtoritet "$T" "$M3I"
set_author "$T" orchestrator
stage_row "$T" "$M3V" "$(git -C "$T" rev-parse "refs/tags/id/CONTRACT/$M3V")"
stage_row_ascii "$T" "$M3I" "$(git -C "$T" rev-parse "refs/tags/id/CONTRACT/$M3I")"
commit_kak "$T" "манифест: смешанные строки $M3V/$M3I"
assert_an_orchestrator "$T" м3
id0="$(id_tags_of "$T")"
run_cz "$T"
assert_no_new_id_tags "$T" "$id0"
if [ "$CZ_RC" -ne 1 ] || ! printf '%s%s' "$CZ_OUT" "$CZ_ERR" | grep -qF 'дверь минта 031: строка не по грамматике манифеста'; then
  printf 'ОТКАЗ: м3 смешанные строки: минт-признание обязано флагать коммит вне зоны именем грамматики (валидная «%s → sha» + невалидная «%s -> sha» закоммичены orchestrator); получил rc=%s out=%s err=%s\n' \
    "$M3V" "$M3I" "$CZ_RC" "$CZ_OUT" "$CZ_ERR" >&2
  exit 1
fi

# ── м4: ВОРОТА 3 — валидная + ПУСТАЯ добавленная строка в staged-дельте ───────
# ПОСЛЕ фикса: rc 1 именем грамматики (bare + входит в add_count). СЕГОДНЯ:
# bare + не считается счётчиком, valid_count==add_count==1 — дверь зелёная
# «+1 строк» — красное.
T="$WORK/kor-${RD[13]}"
make_repo_orchzone "$T"
toy_origin "$T" >/dev/null
mint_tag_avtoritet "$T" "$M4"
set_author "$T" orchestrator
stage_row_pustaja "$T" "$M4" "$(git -C "$T" rev-parse "refs/tags/id/CONTRACT/$M4")"
id0="$(id_tags_of "$T")"
run_bar "$T"
assert_no_new_id_tags "$T" "$id0"
if [ "$BAR_RC" -ne 1 ] || ! printf '%s' "$BAR_ERR" | grep -qF 'дверь минта 031: строка не по грамматике манифеста'; then
  printf 'ОТКАЗ: м4 пустая добавленная строка: дверь минта обязана отказать именем грамматики на staged-дельте с валидной «%s → sha» + ПУСТОЙ добавленной строкой (bare + вне счётчика add_count, check_staged.sh:439); получил rc=%s out=%s err=%s\n' \
    "$M4" "$BAR_RC" "$BAR_OUT" "$BAR_ERR" >&2
  exit 1
fi

# ── м5: ВОРОТА 4 — валидная + ПУСТАЯ дельта ЗАКОММИЧЕНА автором orchestrator ───
# (hook-bypass: core.hooksPath=/dev/null в commit_kak). ПОСЛЕ фикса: rc 1
# «коммит вне зоны … строка не по грамматике манифеста» (признание НЕ срабатывает).
# СЕГОДНЯ: mint_add не видит bare +, признание судит подмножество и молчит — красное.
T="$WORK/korcz-${RD[14]}"
make_repo_orchzone "$T"
toy_origin "$T" >/dev/null
mint_tag_avtoritet "$T" "$M5"
set_author "$T" orchestrator
stage_row_pustaja "$T" "$M5" "$(git -C "$T" rev-parse "refs/tags/id/CONTRACT/$M5")"
commit_kak "$T" "манифест: валидная + пустая строка $M5"
assert_an_orchestrator "$T" м5
id0="$(id_tags_of "$T")"
run_cz "$T"
assert_no_new_id_tags "$T" "$id0"
if [ "$CZ_RC" -ne 1 ] || ! printf '%s%s' "$CZ_OUT" "$CZ_ERR" | grep -qF 'дверь минта 031: строка не по грамматике манифеста'; then
  printf 'ОТКАЗ: м5 пустая добавленная строка: минт-признание обязано флагать коммит вне зоны именем грамматики (валидная «%s → sha» + ПУСТАЯ строка закоммичены автором orchestrator мимо hook); получил rc=%s out=%s err=%s\n' \
    "$M5" "$CZ_RC" "$CZ_OUT" "$CZ_ERR" >&2
  exit 1
fi

printf 'ok: дверь минта 031 mixed-rows — все ворота пройдены (м0..м5)\n'
exit 0
