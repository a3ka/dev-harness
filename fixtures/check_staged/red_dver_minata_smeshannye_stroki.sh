#!/usr/bin/env bash
# КРАСНОЕ по адверсарию 031 тремя кругами: к1 (verdicts/adversary/contracts-031-v1.md,
# ремонт п.3) — СМЕШАННЫЕ строки манифеста, ворота м1/м3 ЗАКРЫТЫ фиксом 5700400
# (all-lines predicate — регрессионные контроли); к2 (verdicts/adversary/
# contracts-031-v2.md) — ПУСТАЯ добавленная строка, ворота м4/м5 ЗАКРЫТЫ фиксом
# db3936c (счётчик видит bare «+»); к3 (вердикт 05b07e9, РЕШЕНИЕ арбитра
# diff-parser-031-dver-mina) — содержимое с ведущим «+»/«-»: дифф-строки «++x»/
# «--x» вторым байтом неотличимы от мета-«+++»/«---», ворота м6..м9б ЗАКРЫТЫ
# фиксом bd2f906 (хунк-контекстный парсер hunk_body). Инвариант всех кругов —
# замороженный 031/4, механизм 1, условия 1–2.
#
# ОБХОД (измерен адверсарием на toy-репо обоими путями, 57bb16a): и дверь минта
# (scripts/check_staged.sh), и минт-признание (scripts/check_zones.sh)
# прогоняли добавленные строки через sed-фильтр грамматики «^[0-9]{3} → [0-9a-f]{40}$»
# и отказывали ТОЛЬКО если фильтр оставил пустоту. Манифест с ВАЛИДНОЙ добавкой +
# НЕВАЛИДНОЙ добавкой (ASCII-стрелка «->» вместо U+2192) проходит: мусор молча
# выброшен, судится подмножество. Нарушено условие 2 механизма 1 frozen 031/4:
# грамматику обязана держать КАЖДАЯ добавленная строка (all-lines predicate).
#
# ОБХОД к2 (измерен адверсарием на toy-репо обоими путями, вердикт на 64b0ae9):
# счётчики добавок add_count и mint_add считали awk-предикатом /^\+[^+]/ — символ
# ПОСЛЕ плюса обязателен. Git показывает добавление пустой строки в diff -U0
# единственным байтом «+» (bare plus): пустая добавка не входит НИ в счётчик,
# НИ в sed-отфильтрованные added_lines. Дельта «валидная строка + пустая строка»
# даёт valid_count == add_count == 1 — all-lines predicate ложно сходится,
# проходят ОБА пути (staged-дверь и признание).
#
# ОБХОД к3 (измерен адверсарием к3 и арбитром на 05b07e9, РЕШЕНИЕ
# diff-parser-031-dver-mina, замер 1): байтовые предикаты /^\+[^+]/ (после db3936c
# — /^\+([^+]|$)/) и /^-[^-]/ над ПОЛНЫМ диффом не видят строк, чей ВТОРОЙ байт
# «+»/«-»: добавка с содержимым «+garbage»/«++garbage» даёт дифф-строки «++garbage»/
# «+++garbage» — не считаются счётчиком добавок и молча режутся sed-грамматикой;
# удаление строки «-garbage»/«--garbage» даёт «--garbage»/«---garbage» — не
# считается счётчиком удалений, «не только-добавление» не срабатывает. Оба пути
# (дверь и признание) пропускали мусор (rc 0, замер 1 РЕШЕНИЯ). Лечение —
# кандидат (а) РЕШЕНИЯ: перечисление строк дельты ТОЛЬКО внутри тел hunk'ов
# (hunk_body, bd2f906); заголовки «+++»/«---» существуют только ДО первого «@@».
#
# ВХОДЫ (Н-39 — привязка к ветвям ПО КОДУ потребителей, не по прозе контракта):
#   м0  ПОЗИТИВ двери: ОДНА валидная строка «N → sha» полным резервом церемонии
#       авторитета (аннотированный тег запушен на origin, main) → check_staged
#       rc 0 + judged «дверь минта 031» — ЗЕЛЁНОЕ и ДО, и ПОСЛЕ фикса (позитив +N
#       не задет, ветвь check_staged.sh:558-560);
#   м1  ВОРОТА 1 (ЗАКРЫТО к1-фиксом 5700400 — регрессионный контроль): staged-дельта с ДВУМЯ добавками — валидная
#       «N → sha» + невалидная «N -> sha»; ОБА тега живы, аннотированы, запушены,
#       sha строки = tag-object-sha — вход конформен во всём, КРОМЕ стрелки →
#       check_staged ОБЯЗАН rc 1 «дверь минта 031: строка не по грамматике
#       манифеста» (check_staged.sh:454). До к1-фикса sed-фильтр выбрасывал
#       невалидную строку, дверь была зелёная «+1 строк» — предъявляемое красное;
#   м2  ПОЗИТИВ признания: та же одна валидная строка, ЗАКОММИЧЕННАЯ фактическим
#       автором orchestrator в открытом окне toy-контракта → check_zones rc 0 —
#       ЗЕЛЁНОЕ и ДО, и ПОСЛЕ (честный минт признаётся, ветвь skip_path
#       check_zones.sh:450-458);
#   м3  ВОРОТА 2 (ЗАКРЫТО к1-фиксом 5700400 — регрессионный контроль): смешанная дельта (валидная + невалидная
#       добавка) ЗАКОММИЧЕНА orchestrator'ом → check_zones ОБЯЗАН rc 1 «коммит
#       вне зоны … дверь минта 031: строка не по грамматике манифеста»
#       (check_zones.sh:421). До к1-фикса признание судило подмножество и молчало —
#       предъявляемое красное.
#   м4  ВОРОТА 3 (ЗАКРЫТО к2-фиксом db3936c — регрессионный контроль):
#       staged-дельта = валидная «N → sha» + ПУСТАЯ добавленная строка
#       (физический перенос строки после валидной; в diff -U0 это bare «+») →
#       check_staged ОБЯЗАН rc 1 «дверь минта 031: строка не по грамматике
#       манифеста» (check_staged.sh:454; счётчик :440 теперь считает bare «+»
#       по hunk_body). До к2-фикса bare + не считался счётчиком, 1==1 — дверь
#       зелёная «+1 строк» — предъявляемое красное;
#   м5  ВОРОТА 4 (ЗАКРЫТО к2-фиксом db3936c — регрессионный контроль): та же
#       дельта (валидная + пустая строка) закоммичена фактическим автором
#       orchestrator через git -c core.hooksPath=/dev/null commit (commit_kak) →
#       check_zones ОБЯЗАН rc 1 «коммит вне зоны … дверь минта 031: строка не по
#       грамматике манифеста» (check_zones.sh:421; mint_add :406 теперь видит
#       bare +). До к2-фикса признание судило подмножество и молчало —
#       предъявляемое красное.
#   м6  ВОРОТА 5 (ЗАКРЫТО к3-фиксом bd2f906 — регрессионный контроль, РЕШЕНИЕ
#       diff-parser-031-dver-mina маршрут п.2): staged-дельта с ДВУМЯ добавками —
#       валидная «N → sha» + содержимое «+garbage» (дифф-строка «++garbage»);
#       тег валидной строки жив/аннотирован/запушен, sha = tag-object-sha — вход
#       конформен во всём, КРОМЕ содержимого второй добавки → check_staged ОБЯЗАН
#       rc 1 «дверь минта 031: строка не по грамматике манифеста»
#       (check_staged.sh:453, valid_count ≠ add_count по hunk_body :439-440).
#       До к3-фикса второй байт «+» прятал добавку от счётчика — дверь зелёная
#       (rc 0, замер 1 РЕШЕНИЯ);
#   м6б то же с содержимым «++garbage» (дифф «+++garbage» — мимикрия под
#       мета-«+++ b/…», у хунк-парсера неотличима от добавки и режется грамматикой);
#   м7  ВОРОТА 6 (ЗАКРЫТО к3-фиксом): дельта м6 ЗАКОММИЧЕНА фактическим автором
#       orchestrator (commit_kak, core.hooksPath=/dev/null) → check_zones ОБЯЗАН
#       rc 1 «коммит вне зоны … дверь минта 031: строка не по грамматике
#       манифеста» (check_zones.sh:420, valid_count ≠ mint_add по hunk_body :405-406).
#       До к3-фикса mint_add не видел «++garbage» — признание судило подмножество
#       и молчало (rc 0, замер 1 РЕШЕНИЯ);
#   м7б то же с содержимым «++garbage»;
#   м8  ВОРОТА 7 (ЗАКРЫТО к3-фиксом): основа-манифест несёт строку «-garbage»
#       (закоммичена ДО судимой дельты автором ВНЕ ЗОН — Фикстура из -c обёртки g:
#       фильтр авторов check_zones.sh:334 её не судит, краснота м9attributable
#       только минт-ветке), staged-дельта УДАЛЯЕТ её и добавляет валидную
#       «N → sha» → check_staged ОБЯЗАН rc 1 «дверь минта 031: дельта манифеста
#       не только-добавление» (check_staged.sh:442, del_count по hunk_body видит
#       дифф-строку «--garbage»). До к3-фикса /^-[^-]/ не видел «--garbage» —
#       del=0, дверь зелёная (rc 0, замер 1 РЕШЕНИЯ);
#   м8б то же со строкой «--garbage» (дифф «---garbage» — мимикрия под
#       мета-«--- a/…», у хунк-парсера считается удалением);
#   м9  ВОРОТА 8 (ЗАКРЫТО к3-фиксом): дельта м8 ЗАКОММИЧЕНА orchestrator'ом →
#       check_zones ОБЯЗАН rc 1 «коммит вне зоны … дверь минта 031: дельта
#       манифеста не только-добавление» (check_zones.sh:408, mint_del по hunk_body
#       видит «--garbage»);
#   м9б то же со строкой «--garbage».
#
# Судимые коммиты создаёт commit_kak — ФАКТИЧЕСКИЙ автор локального конфига
# (set_author); помощник g несёт «-c user.name=Фикстура», перекрывающий конфиг, —
# механизм дыры Б1 (вердикт арбитра 9f86d1c). Ворота м2/м3/м5/м7/м7б/м9/м9б
# ассертят %an == orchestrator ДО вызова судьи: предъявление проверяет само
# предъявление.
#
# Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (А-82, прецедент red_dver_minta_
# orkestratora.sh): предмет предъявляется ПРЯМЫМ запуском; конверсия в case_*
# не планована — CI-ветви несут case_dver_minta_*.sh. Фикстура ДВУХФАЗНАЯ по
# построению семьи: к1-ворота (м1/м3) были красны до 5700400, к2-ворота (м4/м5) —
# до db3936c, к3-ворота (м6..м9б) — до bd2f906 (rc 0 на 05b07e9, замер 1
# РЕШЕНИЯ арбитра); после приземления фикса ВСЕ ворота зелёные регрессионные
# контроли (м0/м2 — позитивные контроли, отличающие фикс от вечнокрасной пробы).
#
# ПАРАМЕТРИЗАЦИЯ СЛУЧАЙНЫМИ ВХОДАМИ (А-88): NNN из НЕПЕРЕСЕКАЮЩИХСЯ поддиапазонов.
# м0..м5 делят 020–119 — пространство семьи 031 ДО к3; для к3-ворот оно исчерпано
# (и занято в-батареей red_dver_minta_orkestratora.sh: 010–018 + 020–119),
# 120–939 занято фикстурами 023, 999 запрещён next_id (+1 за формат) — м6..м9б
# черпают из свободного хвоста 940–995 (996–998 — резерв). Обёртка с константным
# dispatch не собирается ни на одном прогоне; имена toy-корней и копии субъекта
# случайны (BARRIER_ROOT-паттерн: копия каталога scripts/ сохраняет соседство
# sourcing'а lib_zones/next_id).
#
# Охрана «судья не создаёт тег id/*» (правило 8 — ожидание в памяти): снимок
# id-тегов ДО вызова против ПОСЛЕ на каждом судимом репо.
#
# Коды возврата: 0 — ворота пройдены (фикс bd2f906 в дереве: все м0..м9 зелёные);
#               1 — именованный отказ ворота (регрессия парсера/предиката).
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
WORK="$(mktemp -d /tmp/red031mix.XXXXXX)"   # А-78: свежий WORK вне дерева
trap 'rm -rf "$WORK"' EXIT

# ── случайные входы: м0 020-049 · м1 050-064 (валидная) + 065-079 (ASCII) ·
# м2 080-089 · м3 090-094 (валидная) + 095-099 (ASCII) · м4 100-109 · м5 110-119 ·
# к3: м6 940-946 · м6б 947-953 · м7 954-960 · м7б 961-967 · м8 968-974 ·
# м8б 975-981 · м9 982-988 · м9б 989-995 · хвосты — имена каталогов.
mapfile -t RD < <(awk 'BEGIN{srand();
  printf "%03d\n", 20+int(rand()*30);
  printf "%03d\n", 50+int(rand()*15);
  printf "%03d\n", 65+int(rand()*15);
  printf "%03d\n", 80+int(rand()*10);
  printf "%03d\n", 90+int(rand()*5);
  printf "%03d\n", 95+int(rand()*5);
  printf "%03d\n", 100+int(rand()*10);
  printf "%03d\n", 110+int(rand()*10);
  for (i=0;i<10;i++) printf "%d\n", 10000000+int(rand()*89999999);
  printf "%03d\n", 940+int(rand()*7);
  printf "%03d\n", 947+int(rand()*7);
  printf "%03d\n", 954+int(rand()*7);
  printf "%03d\n", 961+int(rand()*7);
  printf "%03d\n", 968+int(rand()*7);
  printf "%03d\n", 975+int(rand()*7);
  printf "%03d\n", 982+int(rand()*7);
  printf "%03d\n", 989+int(rand()*7);
  for (i=0;i<8;i++) printf "%d\n", 10000000+int(rand()*89999999)}')
M0="${RD[0]}"; M1V="${RD[1]}"; M1I="${RD[2]}"; M2="${RD[3]}"; M3V="${RD[4]}"; M3I="${RD[5]}"; M4="${RD[6]}"; M5="${RD[7]}"
M6="${RD[18]}"; M6B="${RD[19]}"; M7="${RD[20]}"; M7B="${RD[21]}"
M8="${RD[22]}"; M8B="${RD[23]}"; M9="${RD[24]}"; M9B="${RD[25]}"

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
# check_staged.sh:440 / mint_add check_zones.sh:406 теперь считают его по
# hunk_body). Валидная строка несёт полную церемонию (U+2192, tag-object-sha
# живого запушенного тега) — контрпример расходится с честным входом РОВНО
# наличием пустой добавленной строки (демаркация к2: инвариантность к значениям ∧
# расхождение на конформном входе).
stage_row_pustaja() {  # <корень> <NNN> <sha>
  local r="$1" n="$2" sha="$3"
  mkdir -p "$r/registry"
  printf '%s → %s\n\n' "$n" "$sha" >> "$r/registry/contracts.tsv"
  g "$r" add -A
}

# stage_row_s_musorom <корень> <NNN> <sha> <содержимое>: добавка-контрпример к3 —
# валидная строка + строка, чьё СОДЕРЖИМОЕ начинается с «+» (дифф-строки
# «++<мусор>»/«+++<мусор>»: второй байт «+» прячет её от байтовых предикатов
# /^\+[^+]/ и /^\+([^+]|$)/ и делает неотличимой от мета-«+++ b/…»; Н-39 —
# привязка к ветви КОДА: hunk_body check_staged.sh:439 / check_zones.sh:405).
# Валидная строка несёт полную церемонию — контрпример расходится с честным
# входом РОВНО классом содержимого с ведущим «+» (демаркация к3: инвариантность
# к значениям ∧ расхождение на конформном входе; класс один — один вход).
stage_row_s_musorom() {  # <корень> <NNN> <sha> <содержимое>
  local r="$1" n="$2" sha="$3" s="$4"
  mkdir -p "$r/registry"
  printf '%s → %s\n' "$n" "$sha" >> "$r/registry/contracts.tsv"
  printf '%s\n' "$s" >> "$r/registry/contracts.tsv"
  g "$r" add -A
}

# commit_baza_musor <корень> <содержимое>: закоммитить базовый манифест из ОДНОЙ
# строки-мусора автором ВНЕ ЗОН (Фикстура из -c обёртки g) ДО судимой дельты —
# HEAD-основа для ворот удаления: строка с ведущим «-» в содержимом даёт при
# удалении дифф-строку «--<мусор>»/«---<мусор>», невидимую байтовому /^-[^-]/.
# Автор Фикстура не в зонах контракта 001 — фильтр авторов check_zones.sh:334
# коммит не судит: краснота м9/м9б attributable ТОЛЬКО минт-ветке судимого
# коммита, не постороннему отказу в том же репо.
commit_baza_musor() {  # <корень> <содержимое>
  local r="$1" s="$2"
  mkdir -p "$r/registry"
  printf '%s\n' "$s" > "$r/registry/contracts.tsv"
  g "$r" add -A
  g "$r" commit -q -m 'манифест: основа со строкой-мусором (автор вне зон, до судимой дельты)'
}

# stage_row_udalenie <корень> <NNN> <sha>: staged-дельта УДАЛЯЕТ строку-мусор из
# HEAD-манифеста (перезапись файла одной валидной строкой) — не-только-добавление,
# спрятанное вторым байтом «-» (к3-2; Н-39: del_count check_staged.sh:441 /
# mint_del check_zones.sh:407 по hunk_body). Валидная строка несёт полную
# церемонию — контрпример расходится с честным входом РОВНО наличием удаления
# (демаркация: инвариантность к значениям ∧ расхождение на конформном входе).
stage_row_udalenie() {  # <корень> <NNN> <sha>
  local r="$1" n="$2" sha="$3"
  mkdir -p "$r/registry"
  printf '%s → %s\n' "$n" "$sha" > "$r/registry/contracts.tsv"
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
# ЗАКРЫТО к1-фиксом (5700400): rc 1 именем грамматики (all-lines predicate).
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
# ЗАКРЫТО к1-фиксом (5700400): rc 1 «коммит вне зоны … строка не по грамматике
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
# ЗАКРЫТО к2-фиксом (db3936c): rc 1 именем грамматики (bare + входит в add_count;
# теперь /^\+/ по hunk_body). До к2-фикса bare + не считался счётчиком,
# valid_count==add_count==1 — дверь зелёная «+1 строк».
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
  printf 'ОТКАЗ: м4 пустая добавленная строка: дверь минта обязана отказать именем грамматики на staged-дельте с валидной «%s → sha» + ПУСТОЙ добавленной строкой (bare + вне счётчика add_count до фикса); получил rc=%s out=%s err=%s\n' \
    "$M4" "$BAR_RC" "$BAR_OUT" "$BAR_ERR" >&2
  exit 1
fi

# ── м5: ВОРОТА 4 — валидная + ПУСТАЯ дельта ЗАКОММИЧЕНА автором orchestrator ───
# (hook-bypass: core.hooksPath=/dev/null в commit_kak). ЗАКРЫТО к2-фиксом
# (db3936c): rc 1 «коммит вне зоны … строка не по грамматике манифеста» (признание
# НЕ срабатывает; mint_add теперь видит bare + по hunk_body). До к2-фикса
# признание судило подмножество и молчало.
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

# ── м6: ВОРОТА 5 — валидная + добавка с СОДЕРЖИМЫМ «+garbage» (дифф «++garbage») ─
# ЗАКРЫТО к3-фиксом (bd2f906, хунк-парсер РЕШЕНИЯ diff-parser-031-dver-mina):
# rc 1 именем грамматики — add_count по hunk_body видит «++garbage», 2≠1. До
# фикса второй байт «+» прятал добавку от счётчика — дверь зелёная (замер 1).
T="$WORK/kor-${RD[26]}"
make_repo_orchzone "$T"
toy_origin "$T" >/dev/null
mint_tag_avtoritet "$T" "$M6"
set_author "$T" orchestrator
stage_row_s_musorom "$T" "$M6" "$(git -C "$T" rev-parse "refs/tags/id/CONTRACT/$M6")" '+garbage'
id0="$(id_tags_of "$T")"
run_bar "$T"
assert_no_new_id_tags "$T" "$id0"
if [ "$BAR_RC" -ne 1 ] || ! printf '%s' "$BAR_ERR" | grep -qF 'дверь минта 031: строка не по грамматике манифеста'; then
  printf 'ОТКАЗ: м6 мусор с ведущим «+»: дверь минта обязана отказать именем грамматики на staged-дельте с валидной «%s → sha» + добавкой «+garbage» (дифф «++garbage» вне счётчика до фикса); получил rc=%s out=%s err=%s\n' \
    "$M6" "$BAR_RC" "$BAR_OUT" "$BAR_ERR" >&2
  exit 1
fi

# ── м6б: то же с СОДЕРЖИМЫМ «++garbage» (дифф «+++garbage» — мимикрия мета-«+++») ─
T="$WORK/kor-${RD[27]}"
make_repo_orchzone "$T"
toy_origin "$T" >/dev/null
mint_tag_avtoritet "$T" "$M6B"
set_author "$T" orchestrator
stage_row_s_musorom "$T" "$M6B" "$(git -C "$T" rev-parse "refs/tags/id/CONTRACT/$M6B")" '++garbage'
id0="$(id_tags_of "$T")"
run_bar "$T"
assert_no_new_id_tags "$T" "$id0"
if [ "$BAR_RC" -ne 1 ] || ! printf '%s' "$BAR_ERR" | grep -qF 'дверь минта 031: строка не по грамматике манифеста'; then
  printf 'ОТКАЗ: м6б мусор с ведущими «++»: дверь минта обязана отказать именем грамматики на staged-дельте с валидной «%s → sha» + добавкой «++garbage» (дифф «+++garbage» мимикрия мета-«+++»); получил rc=%s out=%s err=%s\n' \
    "$M6B" "$BAR_RC" "$BAR_OUT" "$BAR_ERR" >&2
  exit 1
fi

# ── м7: ВОРОТА 6 — валидная + «+garbage» ЗАКОММИЧЕНА orchestrator'ом ───────────
# (hook-bypass: core.hooksPath=/dev/null в commit_kak). ЗАКРЫТО к3-фиксом
# (bd2f906): rc 1 «коммит вне зоны … строка не по грамматике манифеста» (признание
# НЕ срабатывает: mint_add по hunk_body видит «++garbage»). До фикса признание
# судило подмножество и молчало (rc 0, замер 1 РЕШЕНИЯ).
T="$WORK/korcz-${RD[28]}"
make_repo_orchzone "$T"
toy_origin "$T" >/dev/null
mint_tag_avtoritet "$T" "$M7"
set_author "$T" orchestrator
stage_row_s_musorom "$T" "$M7" "$(git -C "$T" rev-parse "refs/tags/id/CONTRACT/$M7")" '+garbage'
commit_kak "$T" "манифест: валидная + мусор $M7"
assert_an_orchestrator "$T" м7
id0="$(id_tags_of "$T")"
run_cz "$T"
assert_no_new_id_tags "$T" "$id0"
if [ "$CZ_RC" -ne 1 ] || ! printf '%s%s' "$CZ_OUT" "$CZ_ERR" | grep -qF 'дверь минта 031: строка не по грамматике манифеста'; then
  printf 'ОТКАЗ: м7 мусор с ведущим «+»: минт-признание обязано флагать коммит вне зоны именем грамматики (валидная «%s → sha» + добавка «+garbage» закоммичены автором orchestrator мимо hook); получил rc=%s out=%s err=%s\n' \
    "$M7" "$CZ_RC" "$CZ_OUT" "$CZ_ERR" >&2
  exit 1
fi

# ── м7б: то же с «++garbage» ───────────────────────────────────────────────────
T="$WORK/korcz-${RD[29]}"
make_repo_orchzone "$T"
toy_origin "$T" >/dev/null
mint_tag_avtoritet "$T" "$M7B"
set_author "$T" orchestrator
stage_row_s_musorom "$T" "$M7B" "$(git -C "$T" rev-parse "refs/tags/id/CONTRACT/$M7B")" '++garbage'
commit_kak "$T" "манифест: валидная + мусор $M7B"
assert_an_orchestrator "$T" м7б
id0="$(id_tags_of "$T")"
run_cz "$T"
assert_no_new_id_tags "$T" "$id0"
if [ "$CZ_RC" -ne 1 ] || ! printf '%s%s' "$CZ_OUT" "$CZ_ERR" | grep -qF 'дверь минта 031: строка не по грамматике манифеста'; then
  printf 'ОТКАЗ: м7б мусор с ведущими «++»: минт-признание обязано флагать коммит вне зоны именем грамматики (валидная «%s → sha» + добавка «++garbage» закоммичены автором orchestrator мимо hook); получил rc=%s out=%s err=%s\n' \
    "$M7B" "$CZ_RC" "$CZ_OUT" "$CZ_ERR" >&2
  exit 1
fi

# ── м8: ВОРОТА 7 — staged-дельта УДАЛЯЕТ «-garbage» (дифф «--garbage») ─────────
# и добавляет валидную. ЗАКРЫТО к3-фиксом (bd2f906): rc 1 «дверь минта 031:
# дельта манифеста не только-добавление» (del_count по hunk_body видит «--garbage»).
# До фикса второй байт «-» прятал удаление от /^-[^-]/ — del=0, дверь зелёная
# (замер 1). Основа-мусор — commit_baza_musor (автор вне зон, до судимой дельты).
T="$WORK/kor-${RD[30]}"
make_repo_orchzone "$T"
toy_origin "$T" >/dev/null
commit_baza_musor "$T" '-garbage'
mint_tag_avtoritet "$T" "$M8"
set_author "$T" orchestrator
stage_row_udalenie "$T" "$M8" "$(git -C "$T" rev-parse "refs/tags/id/CONTRACT/$M8")"
id0="$(id_tags_of "$T")"
run_bar "$T"
assert_no_new_id_tags "$T" "$id0"
if [ "$BAR_RC" -ne 1 ] || ! printf '%s' "$BAR_ERR" | grep -qF 'дверь минта 031: дельта манифеста не только-добавление'; then
  printf 'ОТКАЗ: м8 скрытое удаление: дверь минта обязана отказать именем не-только-добавления на staged-дельте, удаляющей «-garbage» (дифф «--garbage» вне del_count до фикса) и добавляющей валидную «%s → sha»; получил rc=%s out=%s err=%s\n' \
    "$M8" "$BAR_RC" "$BAR_OUT" "$BAR_ERR" >&2
  exit 1
fi

# ── м8б: то же со строкой «--garbage» (дифф «---garbage» — мимикрия мета-«---») ──
T="$WORK/kor-${RD[31]}"
make_repo_orchzone "$T"
toy_origin "$T" >/dev/null
commit_baza_musor "$T" '--garbage'
mint_tag_avtoritet "$T" "$M8B"
set_author "$T" orchestrator
stage_row_udalenie "$T" "$M8B" "$(git -C "$T" rev-parse "refs/tags/id/CONTRACT/$M8B")"
id0="$(id_tags_of "$T")"
run_bar "$T"
assert_no_new_id_tags "$T" "$id0"
if [ "$BAR_RC" -ne 1 ] || ! printf '%s' "$BAR_ERR" | grep -qF 'дверь минта 031: дельта манифеста не только-добавление'; then
  printf 'ОТКАЗ: м8б скрытое удаление: дверь минта обязана отказать именем не-только-добавления на staged-дельте, удаляющей «--garbage» (дифф «---garbage» мимикрия мета-«---») и добавляющей валидную «%s → sha»; получил rc=%s out=%s err=%s\n' \
    "$M8B" "$BAR_RC" "$BAR_OUT" "$BAR_ERR" >&2
  exit 1
fi

# ── м9: ВОРОТА 8 — удаление «-garbage» + валидная ЗАКОММИЧЕНО orchestrator'ом ──
# ЗАКРЫТО к3-фиксом (bd2f906): rc 1 «коммит вне зоны … дверь минта 031: дельта
# манифеста не только-добавление» (mint_del по hunk_body видит «--garbage»).
# До фикса признание пропускало коммит (rc 0, замер 1 РЕШЕНИЯ).
T="$WORK/korcz-${RD[32]}"
make_repo_orchzone "$T"
toy_origin "$T" >/dev/null
commit_baza_musor "$T" '-garbage'
mint_tag_avtoritet "$T" "$M9"
set_author "$T" orchestrator
stage_row_udalenie "$T" "$M9" "$(git -C "$T" rev-parse "refs/tags/id/CONTRACT/$M9")"
commit_kak "$T" "манифест: удаление мусора + выдача $M9"
assert_an_orchestrator "$T" м9
id0="$(id_tags_of "$T")"
run_cz "$T"
assert_no_new_id_tags "$T" "$id0"
if [ "$CZ_RC" -ne 1 ] || ! printf '%s%s' "$CZ_OUT" "$CZ_ERR" | grep -qF 'дверь минта 031: дельта манифеста не только-добавление'; then
  printf 'ОТКАЗ: м9 скрытое удаление: минт-признание обязано флагать коммит вне зоны именем не-только-добавления (удаление «-garbage» + валидная «%s → sha» закоммичены автором orchestrator мимо hook); получил rc=%s out=%s err=%s\n' \
    "$M9" "$CZ_RC" "$CZ_OUT" "$CZ_ERR" >&2
  exit 1
fi

# ── м9б: то же со строкой «--garbage» ──────────────────────────────────────────
T="$WORK/korcz-${RD[33]}"
make_repo_orchzone "$T"
toy_origin "$T" >/dev/null
commit_baza_musor "$T" '--garbage'
mint_tag_avtoritet "$T" "$M9B"
set_author "$T" orchestrator
stage_row_udalenie "$T" "$M9B" "$(git -C "$T" rev-parse "refs/tags/id/CONTRACT/$M9B")"
commit_kak "$T" "манифест: удаление мусора + выдача $M9B"
assert_an_orchestrator "$T" м9б
id0="$(id_tags_of "$T")"
run_cz "$T"
assert_no_new_id_tags "$T" "$id0"
if [ "$CZ_RC" -ne 1 ] || ! printf '%s%s' "$CZ_OUT" "$CZ_ERR" | grep -qF 'дверь минта 031: дельта манифеста не только-добавление'; then
  printf 'ОТКАЗ: м9б скрытое удаление: минт-признание обязано флагать коммит вне зоны именем не-только-добавления (удаление «--garbage» + валидная «%s → sha» закоммичены автором orchestrator мимо hook); получил rc=%s out=%s err=%s\n' \
    "$M9B" "$CZ_RC" "$CZ_OUT" "$CZ_ERR" >&2
  exit 1
fi

printf 'ok: дверь минта 031 mixed-rows — все ворота пройдены (м0..м9)\n'
exit 0
