#!/usr/bin/env bash
# ПРЕД-ЗАМОРОЗОЧНОЕ КРАСНОЕ контракта 031, механизм-1 — дверь оркестратора-минта
# (Н-81) в scripts/check_staged.sh + признание в scripts/check_zones.sh.
#
# Договор двери (контракт 031 §Инварианты-1 — единый источник; фразы побайтово):
# staged-путь registry/contracts.tsv под автором orchestrator пропускается БЕЗ суда
# зон ⟺ ШЕСТЬ условий ВМЕСТЕ (порядок: форма → грамматика → реестр → провенанс →
# ветка):
#   (1) форма: staged-дельта пути — ТОЛЬКО добавления (N ≥ 1, ноль правок/удалений);
#   (2) грамматика каждой строки: «^[0-9]{3} → [0-9a-f]{40}$» (U+2192, tag-object-sha);
#   (3) реестр: NNN нет в манифесте HEAD И в манифесте ЖИВОЙ шапки origin/main;
#   (4) тег id/CONTRACT/<NNN> жив локально, ANNOTATED, tag-object-sha == sha строки;
#   (5) тот же тег достижим на origin, sha на origin == sha строки; отказ сети —
#       fail-closed «авторитет недоступен» (имя ОТДЕЛЬНОЕ от «не выдан авторитетом»);
#   (6) текущая ветка = main.
# Прочие staged-пути того же коммита судятся обычным порядком (дверь — не индульгенция
# на весь коммит). Дверь действительна ТОЛЬКО для автора orchestrator: implementer и
# прочие → «вне зоны» (канарейка в10).
#
# Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (А-82, прецедент red_dver_po_tegu.sh 023):
# до реализации предмет предъявляется ПРЯМЫМ запуском; приёмка — ДВА прогона подряд с
# РАЗНЫМИ случайными входами. Фикстура ДВУХФАЗНАЯ: сегодня красна именованной причиной
# (боль Н-81: честный минт отказан «вне зоны»; обманные ветви — тем же классом, без
# имени двери), после реализации все ворота зелёные. Конверсия в case_* НЕ планована:
# CI-покрытие ветвей несут case_dver_minta_*.sh исполнителя (ЗОНА implementer 031).
#
# ПАРАМЕТРИЗАЦИЯ СЛУЧАЙНЫМИ ВХОДАМИ (А-88): NNN черпаются из НЕПЕРЕСЕКАЮЩИХСЯ
# поддиапазонов 020–119 — ВНЕ занятых фикстурами 023 (120–939), чтобы обёртка с
# константным dispatch не собиралась ни на одном прогоне; basename toy-корней и копии
# субъекта случайны (BARRIER_ROOT-паттерн: у судьи нет константного пути, копия
# каталога scripts/ сохраняет соседство sourcing'а lib_zones/next_id/check_charter).
#
# ВХОДЫ (Н-39 — привязка к ветвям по коду двери; номер РАЗНЫ у каждого входа — форма,
# ключащаяся на константу одного входа, умирает на соседних):
#   в0  положительный контроль: orchestrator в СВОЕЙ зоне (HANDOFF.md) → rc 0
#       («ok: staged в зоне автора») — ЗЕЛЁНОЕ и ДО, и ПОСЛЕ (дверь не ломает зон);
#   в1  боль Н-81 (определяющая дельта): полный минт церемонией авторитета (тег
#       аннотирован и запушен на origin, main запушен), строка «N1 → sha» staged,
#       автор orchestrator, ветка main → ПОСЛЕ rc 0 + «judged: … (дверь минта 031…».
#       СЕГОДНЯ «вне зоны» — КРАСНОЕ;
#   в1б +N-квантор: ДВЕ строки, оба тега живы (двойной минт одним коммитом,
#       прецедент d28c688 +024/+025) → ПОСЛЕ rc 0;
#   в2  не только-добавление: правка СУЩЕСТВУЮЩЕЙ строки манифеста (sha заменён на
#       переминченный тег) → ПОСЛЕ rc 1 «дверь минта 031: дельта манифеста не
#       только-добавление»;
#   в3  грамматика: строка «N3 -> sha» (ASCII-стрелка вместо U+2192) → ПОСЛЕ rc 1
#       «дверь минта 031: строка не по грамматике манифеста»;
#   в4  повторный минт: NNN уже в манифесте (HEAD), staged вторая строка того же NNN
#       с sha свежего тега → ПОСЛЕ rc 1 «дверь минта 031: номер N4 уже в манифесте —
#       повторный минт»;
#   в5  тег не создан вовсе: строка на N5, тега id/CONTRACT/N5 нет → ПОСЛЕ rc 1
#       «дверь минта 031: тег id/CONTRACT/N5 не жив локально»;
#   в5б LIGHTWEIGHT-тег (совет 3 круга 1): `git tag` без -a — объект-КОММИТ под
#       refs/tags, грамматики строки не нарушает → ПОСЛЕ rc 1 «дверь минта 031: тег
#       id/CONTRACT/N5б не аннотированный» (аннотированность — имя отдельное от
#       «не жив»);
#   в6  self-mint: тег создан ЛОКАЛЬНО, НЕ запушен (ровно self-mint агента из
#       worktree; refs общие) → ПОСЛЕ rc 1 «дверь минта 031: тег N6 не выдан
#       авторитетом: тег не достижим на origin»;
#   в7  peeled-sha: строка несёт sha КОММИТА (N7^{}), не tag-object-sha — частая
#       ошибка церемонии → ПОСЛЕ rc 1 «дверь минта 031: sha строки ≠ tag-object-sha
#       живого тега»;
#   в8  origin недоступен: полный резерв, затем origin перенаправлен на
#       несуществующий путь (файловый, детерминированно; DNS не касается) → ПОСЛЕ
#       rc 1 «дверь минта 031: авторитет недоступен» (fail-closed; имя отдельное от
#       «не выдан авторитетом»);
#   в8б ДРЕЙФ АВТОРИТЕТА (совет 3 круга 1): origin ДОСТУПЕН, но несёт ДРУГОЙ
#       tag-object под тем же refs/tags/id/CONTRACT/N8б (локальный тег == строке;
#       второй объект форс-пушнут на origin) → ПОСЛЕ rc 1 «дверь минта 031: sha
#       тега на origin ≠ sha строки (дрейф авторитета)» — имя отдельное от
#       недостижимости в8;
#   в9  ветка не main: свой wip/<N9>/orchestrator (страж 018 пускает — своя ветка),
#       полный резерв, строка staged → ПОСЛЕ rc 1 «дверь минта 031: дверь не на main»;
#   в10 не-orchestrator: implementer при ПОЛНОМ резерве → «вне зоны» ДО и ПОСЛЕ
#       (дверь не расширяет права за пределы orchestrator);
#   в11 ПРИЗНАНИЕ в check_zones, честный случай (Б1 круга 1): полный минт
#       ЗАКОММИЧЕН orchestrator'ом в открытом окне toy-контракта → $BARRIER/
#       check_zones.sh на toy: СЕГОДНЯ rc 1 «коммит вне зоны» (боль CI предъявлена
#       красным), ПОСЛЕ rc 0 (признание исключает ровно путь манифеста);
#   в12 признание НЕ индульгенция (Б1): orchestrator коммитит ПРАКУ существующей
#       строки манифеста (не-минтная дельта того же пути) → check_zones rc 1
#       «коммит вне зоны» ДО и ПОСЛЕ — убивает стаб «пропускать registry/ целиком»;
#   в13 дверь НЕ индульгенция на staged-коммит (Б2 круга 1): честная строка
#       манифеста + отдельный путь вне зоны (registry/extra.tsv) в ОДНОМ staged →
#       rc 1 именем ВТОРОГО пути ∧ stdout несёт judged-строку двери для манифеста.
#
# Охрана «судья не создаёт тег id/*» (мера не меняет предмет): снимок id-тегов ДО
# вызова против ПОСЛЕ на каждом судимом репо (правило 8 — ожидание в памяти).
#
# СЕГОДНЯ (двери в коде нет) файл красен на в1 именованной причиной «вне зоны» — это
# и есть предъявляемое красное (боль Н-81); в2–в9 — тем же классом (отказ без имени
# двери), в0/в10 зелёные канарейки. ПОСЛЕ реализации все ворота проходят.
#
# Коды возврата: 0 — ворота пройдены; 1 — именованный отказ (дверь отсутствует либо
#               нарушила договор на воротах).
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
WORK="$(mktemp -d /tmp/red031-mint.XXXXXX)"   # А-78: свежий WORK вне дерева
trap 'rm -rf "$WORK"' EXIT

# ── случайные входы: один awk, непересекающиеся поддиапазоны 020–119 (вне 120–939
# фикстур 023): в1 020-039 · в1б 040-049+050-054 · в2 055-069 · в3 070-079 ·
# в4 080-089 · в5 090-094 · в6 095-099 · в7 100-104 · в8 105-109 · в9 110-114 ·
# в10 115-119.
mapfile -t RD < <(awk 'BEGIN{srand();
  printf "%03d\n", 20+int(rand()*20);
  printf "%03d\n", 40+int(rand()*10);
  printf "%03d\n", 50+int(rand()*5);
  printf "%03d\n", 55+int(rand()*15);
  printf "%03d\n", 70+int(rand()*10);
  printf "%03d\n", 80+int(rand()*10);
  printf "%03d\n", 90+int(rand()*5);
  printf "%03d\n", 95+int(rand()*5);
  printf "%03d\n", 100+int(rand()*5);
  printf "%03d\n", 105+int(rand()*5);
  printf "%03d\n", 110+int(rand()*5);
  printf "%03d\n", 115+int(rand()*5);
  printf "%03d\n", 10+int(rand()*5);
  printf "%03d\n", 15+int(rand()*4);
  for (i=0;i<11;i++) printf "%d\n", 10000000+int(rand()*89999999)}')
N1="${RD[0]}"; N1x="${RD[1]}"; N1y="${RD[2]}"; N2="${RD[3]}"; N3="${RD[4]}"
N4="${RD[5]}"; N5="${RD[6]}"; N6="${RD[7]}"; N7="${RD[8]}"; N8="${RD[9]}"
N9="${RD[10]}"; N10="${RD[11]}"; N5b="${RD[12]}"; N8b="${RD[13]}"
N4b="$(printf '%03d' $((6 + RD[21] % 4)))"   # 006-009, производный от случайного — вне занятых диапазонов

# Субъект — копия scripts/ под случайным именем (BARRIER_ROOT-паттерн).
BARRIER="$WORK/subj-${RD[12]}"
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
# (scripts/) И orchestrator (HANDOFF.md). orchestrator ОБЯЗАН быть зонирован — иначе
# «не судится» до суда путей и боль Н-81 плацебо-зелёная (урок ЗЗ 018: зелёный
# контроль обязан упражнять предмет).
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

# mint_tag_avtoritet <корень> <NNN>: АВТОРИТЕТНАЯ половина церемонии — аннотированный
# тег + пуш тега на origin (манифестную строку НЕ пишет: строка — предмет суда, её
# stage'ит orchestrator). Грамматика строки — дословно 023/031: «NNN → tag-object-sha».
mint_tag_avtoritet() {  # <корень> <NNN>
  local r="$1" n="$2"
  g "$r" tag -a "id/CONTRACT/$n" -m 'выдача механизмом (фикстура: авторитетная половина)'
  g "$r" push -q origin "refs/tags/id/CONTRACT/$n"
}

# mint_row_commit <корень> <NNN>: авторитет КОММИТИТ строку манифеста (база для
# «повторного минта» и «правки существующей») + пуш main.
mint_row_commit() {  # <корень> <NNN>
  local r="$1" n="$2" sha
  sha="$(git -C "$r" rev-parse "refs/tags/id/CONTRACT/$n")"
  mkdir -p "$r/registry"
  printf '%s → %s\n' "$n" "$sha" >> "$r/registry/contracts.tsv"
  g "$r" add -A
  g "$r" commit -q -m "реестр: резерв $n (авторитетная строка)"
  g "$r" push -q origin main
}

# stage_row <корень> <NNN> <sha>: orchestrator stage'ит строку манифеста (НЕ коммитит —
# судится staged-множество).
stage_row() {  # <корень> <NNN> <sha>
  local r="$1" n="$2" sha="$3"
  mkdir -p "$r/registry"
  printf '%s → %s\n' "$n" "$sha" >> "$r/registry/contracts.tsv"
  g "$r" add -A
}

run_bar() {  # <корень> → stdout/stderr в $BAR_OUT/$BAR_ERR, rc в $BAR_RC
  BAR_OUT="$("$BARRIER/check_staged.sh" "$1" 2>"$WORK/bar_err")" && BAR_RC=0 || BAR_RC=$?
  BAR_ERR="$(cat "$WORK/bar_err")"
}

# ── в0: положительный контроль (orchestrator в своей зоне — ЗЕЛЁНОЕ ДО и ПОСЛЕ) ──
T0="$WORK/kor-${RD[13]}"
make_repo_orchzone "$T0"
set_author "$T0" orchestrator
printf '\nчекпойнт\n' >> "$T0/HANDOFF.md"
g "$T0" add -A
t0_id0="$(id_tags_of "$T0")"
run_bar "$T0"
assert_no_new_id_tags "$T0" "$t0_id0"
if [ "$BAR_RC" -ne 0 ]; then
  printf 'ОТКАЗ: в0: orchestrator в своей зоне (HANDOFF.md) отказан (rc %s, ожидан rc 0): %s\n' "$BAR_RC" "$BAR_ERR" >&2
  exit 1
fi

# ── в1: боль Н-81 — полный минт авторитетной церемонией, строка staged, main ─────
# ПОСЛЕ: rc 0 + judged-строка двери. СЕГОДНЯ: «вне зоны» — предъявляемое красное.
T1="$WORK/kor-${RD[14]}"
make_repo_orchzone "$T1"
toy_origin "$T1" >/dev/null
mint_tag_avtoritet "$T1" "$N1"
set_author "$T1" orchestrator
stage_row "$T1" "$N1" "$(git -C "$T1" rev-parse "refs/tags/id/CONTRACT/$N1")"
t1_id0="$(id_tags_of "$T1")"
run_bar "$T1"
assert_no_new_id_tags "$T1" "$t1_id0"
if [ "$BAR_RC" -ne 0 ] || ! printf '%s' "$BAR_OUT" | grep -qF 'дверь минта 031'; then
  printf 'ОТКАЗ: дверь минта отсутствует — боль Н-81: полный минт %s (тег жив локально и на origin, строка по грамматике, автор orchestrator, ветка main) отказан (rc %s, ожидан rc 0 + «дверь минта 031»): %s\n' "$N1" "$BAR_RC" "$BAR_ERR" >&2
  exit 1
fi

# ── в1б: +N-квантор — двойной минт одним коммитом (оба тега живы) ───────────────
T1b="$WORK/kor-${RD[12]}"
make_repo_orchzone "$T1b"
toy_origin "$T1b" >/dev/null
mint_tag_avtoritet "$T1b" "$N1x"
mint_tag_avtoritet "$T1b" "$N1y"
set_author "$T1b" orchestrator
stage_row "$T1b" "$N1x" "$(git -C "$T1b" rev-parse "refs/tags/id/CONTRACT/$N1x")"
stage_row "$T1b" "$N1y" "$(git -C "$T1b" rev-parse "refs/tags/id/CONTRACT/$N1y")"
t1b_id0="$(id_tags_of "$T1b")"
run_bar "$T1b"
assert_no_new_id_tags "$T1b" "$t1b_id0"
if [ "$BAR_RC" -ne 0 ] || ! printf '%s' "$BAR_OUT" | grep -qF 'дверь минта 031'; then
  printf 'ОТКАЗ: в1б: двойной минт (+%s +%s, оба тега живы) отказан (rc %s, ожидан rc 0 — квантор +N, прецедент d28c688): %s\n' "$N1x" "$N1y" "$BAR_RC" "$BAR_ERR" >&2
  exit 1
fi

# ── в2: не только-добавление — правка СУЩЕСТВУЮЩЕЙ строки ───────────────────────
# База: авторитетная строка N2 в HEAD. Staged: та же строка с sha ПЕРЕМИНЧЕННОГО
# тега (плюс свежая валидная строка — дельта обязана содержать правку).
# ПОСЛЕ: rc 1 «не только-добавление». СЕГОДНЯ: «вне зоны» без имени — красное по имени.
T2="$WORK/kor-${RD[13]}v2"
make_repo_orchzone "$T2"
toy_origin "$T2" >/dev/null
mint_tag_avtoritet "$T2" "$N2"
mint_row_commit "$T2" "$N2"
g "$T2" tag -d "id/CONTRACT/$N2" >/dev/null
g "$T2" tag -a "id/CONTRACT/$N2" -m 'выдача механизмом (фикстура: переминченный тег)'
g "$T2" push -q --force origin "refs/tags/id/CONTRACT/$N2"
novyj_sha="$(git -C "$T2" rev-parse "refs/tags/id/CONTRACT/$N2")"
sed -i "s/^$N2 → .*$/$N2 → $novyj_sha/" "$T2/registry/contracts.tsv"
set_author "$T2" orchestrator
g "$T2" add -A
t2_id0="$(id_tags_of "$T2")"
run_bar "$T2"
assert_no_new_id_tags "$T2" "$t2_id0"
if [ "$BAR_RC" -ne 1 ] || ! printf '%s' "$BAR_ERR" | grep -qF 'дверь минта 031: дельта манифеста не только-добавление'; then
  printf 'ОТКАЗ: в2: правка существующей строки манифеста %s не опознана (rc %s, ожидан rc 1 «дверь минта 031: дельта манифеста не только-добавление»): %s\n' "$N2" "$BAR_RC" "$BAR_ERR" >&2
  exit 1
fi

# ── в3: грамматика — ASCII-стрелка вместо U+2192 ────────────────────────────────
T3="$WORK/kor-${RD[14]}v3"
make_repo_orchzone "$T3"
toy_origin "$T3" >/dev/null
mint_tag_avtoritet "$T3" "$N3"
set_author "$T3" orchestrator
mkdir -p "$T3/registry"
printf '%s -> %s\n' "$N3" "$(git -C "$T3" rev-parse "refs/tags/id/CONTRACT/$N3")" >> "$T3/registry/contracts.tsv"
g "$T3" add -A
t3_id0="$(id_tags_of "$T3")"
run_bar "$T3"
assert_no_new_id_tags "$T3" "$t3_id0"
if [ "$BAR_RC" -ne 1 ] || ! printf '%s' "$BAR_ERR" | grep -qF 'дверь минта 031: строка не по грамматике манифеста'; then
  printf 'ОТКАЗ: в3: строка «%s -> sha» (ASCII-стрелка) не опознана (rc %s, ожидан rc 1 «дверь минта 031: строка не по грамматике манифеста»): %s\n' "$N3" "$BAR_RC" "$BAR_ERR" >&2
  exit 1
fi

# ── в4: повторный минт — NNN уже в манифесте HEAD ───────────────────────────────
T4="$WORK/kor-${RD[15]}"
make_repo_orchzone "$T4"
toy_origin "$T4" >/dev/null
mint_tag_avtoritet "$T4" "$N4"
mint_row_commit "$T4" "$N4"
g "$T4" tag -d "id/CONTRACT/$N4" >/dev/null
g "$T4" tag -a "id/CONTRACT/$N4" -m 'выдача механизмом (фикстура: свежий переминт)'
g "$T4" push -q --force origin "refs/tags/id/CONTRACT/$N4"
set_author "$T4" orchestrator
stage_row "$T4" "$N4" "$(git -C "$T4" rev-parse "refs/tags/id/CONTRACT/$N4")"
t4_id0="$(id_tags_of "$T4")"
run_bar "$T4"
assert_no_new_id_tags "$T4" "$t4_id0"
if [ "$BAR_RC" -ne 1 ] || ! printf '%s' "$BAR_ERR" | grep -qF 'уже в манифесте — повторный минт'; then
  printf 'ОТКАЗ: в4: повторный минт %s не опознан (rc %s, ожидан rc 1 «дверь минта 031: номер %s уже в манифесте — повторный минт»): %s\n' "$N4" "$BAR_RC" "$N4" "$BAR_ERR" >&2
  exit 1
fi

# ── в4б: дрейф реестра — повтор виден только с origin/main (совет 3 круга 1) ────
# Авторитет коммитит строку N4b и пушит main; локальный HEAD откатан мимо строки
# (reset --hard HEAD~1) — staged-дельта чисто-добавительная ЛОКАЛЬНО, повтор живёт
# только на живой шапке origin/main. ПОСЛЕ: rc 1 «уже в манифесте — повторный минт»
# (origin-половина условия 3). СЕГОДНЯ: «вне зоны» — красное по имени.
T4b="$WORK/kor-${RD[22]}v4b"
make_repo_orchzone "$T4b"
toy_origin "$T4b" >/dev/null
mint_tag_avtoritet "$T4b" "$N4b"
mint_row_commit "$T4b" "$N4b"
g "$T4b" reset -q --hard HEAD~1
set_author "$T4b" orchestrator
stage_row "$T4b" "$N4b" "$(git -C "$T4b" rev-parse "refs/tags/id/CONTRACT/$N4b")"
t4b_id0="$(id_tags_of "$T4b")"
run_bar "$T4b"
assert_no_new_id_tags "$T4b" "$t4b_id0"
if [ "$BAR_RC" -ne 1 ] || ! printf '%s' "$BAR_ERR" | grep -qF 'уже в манифесте — повторный минт'; then
  printf 'ОТКАЗ: в4б: дрейф реестра %s (строка на origin/main, HEAD откачан) не опознан (rc %s, ожидан rc 1 «дверь минта 031: номер %s уже в манифесте — повторный минт»): %s\n' "$N4b" "$BAR_RC" "$N4b" "$BAR_ERR" >&2
  exit 1
fi

# ── в5: тег не создан вовсе ─────────────────────────────────────────────────────
T5="$WORK/kor-${RD[16]}"
make_repo_orchzone "$T5"
toy_origin "$T5" >/dev/null
set_author "$T5" orchestrator
stage_row "$T5" "$N5" "0000000000000000000000000000000000000000"
t5_id0="$(id_tags_of "$T5")"
run_bar "$T5"
assert_no_new_id_tags "$T5" "$t5_id0"
if [ "$BAR_RC" -ne 1 ] || ! printf '%s' "$BAR_ERR" | grep -qF 'не жив локально'; then
  printf 'ОТКАЗ: в5: строка на %s без тега не опознана (rc %s, ожидан rc 1 «дверь минта 031: тег id/CONTRACT/%s не жив локально»): %s\n' "$N5" "$BAR_RC" "$N5" "$BAR_ERR" >&2
  exit 1
fi

# ── в5б: lightweight-тег — объект-коммит под refs/tags ─────────────────────────
T5b="$WORK/kor-${RD[16]}v5b"
make_repo_orchzone "$T5b"
toy_origin "$T5b" >/dev/null
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$T5b" tag "id/CONTRACT/$N5b"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$T5b" push -q origin "refs/tags/id/CONTRACT/$N5b"
set_author "$T5b" orchestrator
stage_row "$T5b" "$N5b" "$(git -C "$T5b" rev-parse "refs/tags/id/CONTRACT/$N5b")"
t5b_id0="$(id_tags_of "$T5b")"
run_bar "$T5b"
assert_no_new_id_tags "$T5b" "$t5b_id0"
if [ "$BAR_RC" -ne 1 ] || ! printf '%s' "$BAR_ERR" | grep -qF 'не аннотированный'; then
  printf 'ОТКАЗ: в5б: lightweight-тег %s не опознан (rc %s, ожидан rc 1 «дверь минта 031: тег id/CONTRACT/%s не аннотированный»): %s\n' "$N5b" "$BAR_RC" "$N5b" "$BAR_ERR" >&2
  exit 1
fi

# ── в6: self-mint — тег локально, НЕ на origin ──────────────────────────────────
T6="$WORK/kor-${RD[17]}"
make_repo_orchzone "$T6"
toy_origin "$T6" >/dev/null
g "$T6" tag -a "id/CONTRACT/$N6" -m 'выдача (фикстура: self-mint, НЕ запушен)'
set_author "$T6" orchestrator
stage_row "$T6" "$N6" "$(git -C "$T6" rev-parse "refs/tags/id/CONTRACT/$N6")"
t6_id0="$(id_tags_of "$T6")"
run_bar "$T6"
assert_no_new_id_tags "$T6" "$t6_id0"
if [ "$BAR_RC" -ne 1 ] || ! printf '%s' "$BAR_ERR" | grep -qF 'не выдан авторитетом: тег не достижим на origin'; then
  printf 'ОТКАЗ: в6: self-mint %s (локальный тег вне origin) пущен/не назван (rc %s, ожидан rc 1 «дверь минта 031: тег %s не выдан авторитетом: тег не достижим на origin»): %s\n' "$N6" "$BAR_RC" "$N6" "$BAR_ERR" >&2
  exit 1
fi

# ── в7: peeled-sha — sha КОММИТА вместо tag-object-sha ──────────────────────────
T7="$WORK/kor-${RD[18]}"
make_repo_orchzone "$T7"
toy_origin "$T7" >/dev/null
mint_tag_avtoritet "$T7" "$N7"
set_author "$T7" orchestrator
stage_row "$T7" "$N7" "$(git -C "$T7" rev-parse "refs/tags/id/CONTRACT/$N7^{}")"
t7_id0="$(id_tags_of "$T7")"
run_bar "$T7"
assert_no_new_id_tags "$T7" "$t7_id0"
if [ "$BAR_RC" -ne 1 ] || ! printf '%s' "$BAR_ERR" | grep -qF 'sha строки ≠ tag-object-sha живого тега'; then
  printf 'ОТКАЗ: в7: peeled-sha %s не опознан (rc %s, ожидан rc 1 «дверь минта 031: sha строки ≠ tag-object-sha живого тега»): %s\n' "$N7" "$BAR_RC" "$BAR_ERR" >&2
  exit 1
fi

# ── в8: origin недоступен — fail-closed, имя отдельное ──────────────────────────
T8="$WORK/kor-${RD[19]}"
make_repo_orchzone "$T8"
toy_origin "$T8" >/dev/null
mint_tag_avtoritet "$T8" "$N8"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$T8" remote set-url origin "$WORK/netu-origina-${RD[12]}.git"
set_author "$T8" orchestrator
stage_row "$T8" "$N8" "$(git -C "$T8" rev-parse "refs/tags/id/CONTRACT/$N8")"
t8_id0="$(id_tags_of "$T8")"
run_bar "$T8"
assert_no_new_id_tags "$T8" "$t8_id0"
if [ "$BAR_RC" -ne 1 ] || ! printf '%s' "$BAR_ERR" | grep -qF 'авторитет недоступен'; then
  printf 'ОТКАЗ: в8: недоступный origin не дал fail-closed имени (rc %s, ожидан rc 1 «дверь минта 031: авторитет недоступен»): %s\n' "$BAR_RC" "$BAR_ERR" >&2
  exit 1
fi

# ── в8б: дрейф авторитета — origin доступен, sha другой ───────────────────────
T8b="$WORK/kor-${RD[17]}v8b"
make_repo_orchzone "$T8b"
toy_origin "$T8b" >/dev/null
mint_tag_avtoritet "$T8b" "$N8b"
g "$T8b" tag -a "vremennyj-${RD[18]}" -m 'второй объект (фикстура: дрейф авторитета)'
g "$T8b" push -q --force origin "refs/tags/vremennyj-${RD[18]}:refs/tags/id/CONTRACT/$N8b"
set_author "$T8b" orchestrator
stage_row "$T8b" "$N8b" "$(git -C "$T8b" rev-parse "refs/tags/id/CONTRACT/$N8b")"
t8b_id0="$(id_tags_of "$T8b")"
run_bar "$T8b"
assert_no_new_id_tags "$T8b" "$t8b_id0"
if [ "$BAR_RC" -ne 1 ] || ! printf '%s' "$BAR_ERR" | grep -qF 'sha тега на origin ≠ sha строки'; then
  printf 'ОТКАЗ: в8б: дрейф авторитета %s не опознан (rc %s, ожидан rc 1 «дверь минта 031: sha тега на origin ≠ sha строки (дрейф авторитета)»): %s\n' "$N8b" "$BAR_RC" "$BAR_ERR" >&2
  exit 1
fi

# ── в9: ветка не main (своя wip — страж 018 пускает, дверь обязана отказать) ────
T9="$WORK/kor-${RD[20]}"
make_repo_orchzone "$T9"
toy_origin "$T9" >/dev/null
mint_tag_avtoritet "$T9" "$N9"
co_wip "$T9" "wip/$N9/orchestrator"
set_author "$T9" orchestrator
stage_row "$T9" "$N9" "$(git -C "$T9" rev-parse "refs/tags/id/CONTRACT/$N9")"
t9_id0="$(id_tags_of "$T9")"
run_bar "$T9"
assert_no_new_id_tags "$T9" "$t9_id0"
if [ "$BAR_RC" -ne 1 ] || ! printf '%s' "$BAR_ERR" | grep -qF 'дверь не на main'; then
  printf 'ОТКАЗ: в9: минт с ветки wip/%s/orchestrator не опознан (rc %s, ожидан rc 1 «дверь минта 031: дверь не на main»): %s\n' "$N9" "$BAR_RC" "$BAR_ERR" >&2
  exit 1
fi

# ── в10: не-orchestrator при полном резерве (канарейка: дверь не расширяет права) ─
T10="$WORK/kor-${RD[12]}fin"
make_repo_orchzone "$T10"
toy_origin "$T10" >/dev/null
mint_tag_avtoritet "$T10" "$N10"
co_wip "$T10" "wip/$N10/implementer"
set_author "$T10" implementer
stage_row "$T10" "$N10" "$(git -C "$T10" rev-parse "refs/tags/id/CONTRACT/$N10")"
t10_id0="$(id_tags_of "$T10")"
run_bar "$T10"
assert_no_new_id_tags "$T10" "$t10_id0"
if [ "$BAR_RC" -ne 1 ] || ! printf '%s' "$BAR_ERR" | grep -qF 'вне зоны'; then
  printf 'ОТКАЗ: в10: implementer при живом резерве %s пущен дверью (rc %s, ожидан rc 1 «вне зоны»): %s\n' "$N10" "$BAR_RC" "$BAR_ERR" >&2
  exit 1
fi

# ── в11: признание в check_zones — честный минт в открытом окне (Б1) ───────────
# СЕГОДНЯ: rc 1 «коммит вне зоны» — боль CI предъявлена красным. ПОСЛЕ: rc 0.
T11="$WORK/korcz-${RD[19]}"
make_repo_orchzone "$T11"
toy_origin "$T11" >/dev/null
mint_tag_avtoritet "$T11" "$N1"
set_author "$T11" orchestrator
stage_row "$T11" "$N1" "$(git -C "$T11" rev-parse "refs/tags/id/CONTRACT/$N1")"
g "$T11" commit -q -m "манифест: выдача $N1"
CZ_OUT="$(bash "$BARRIER/check_zones.sh" "$T11" 2>"$WORK/cz_err11")" && CZ_RC=0 || CZ_RC=$?
CZ_ERR="$(cat "$WORK/cz_err11")"
if [ "$CZ_RC" -ne 0 ]; then
  printf 'ОТКАЗ: в11: признание минта в check_zones отсутствует — честный закоммиченный минт %s (orchestrator, открытое окно) красит CI: rc %s: %s %s\n' "$N1" "$CZ_RC" "$CZ_OUT" "$CZ_ERR" >&2
  exit 1
fi

# ── в12: признание НЕ индульгенция — не-минтная дельта того же пути (Б1) ────────
T12="$WORK/korcz-${RD[20]}"
make_repo_orchzone "$T12"
toy_origin "$T12" >/dev/null
mint_tag_avtoritet "$T12" "$N1x"
mint_row_commit "$T12" "$N1x"
g "$T12" tag -d "id/CONTRACT/$N1x" >/dev/null
g "$T12" tag -a "id/CONTRACT/$N1x" -m 'выдача (фикстура: переминт для правки строки)'
g "$T12" push -q --force origin "refs/tags/id/CONTRACT/$N1x"
novyj12="$(git -C "$T12" rev-parse "refs/tags/id/CONTRACT/$N1x")"
python3 - "$T12/registry/contracts.tsv" "$N1x" "$novyj12" <<'PYE'
import io,sys
f,n,sha=sys.argv[1],sys.argv[2],sys.argv[3]
lines=io.open(f,encoding='utf-8').read().splitlines(True)
out=[]
for L in lines:
    if L.startswith(n+' '):
        out.append('%s → %s\n'%(n,sha))
    else:
        out.append(L)
io.open(f,'w',encoding='utf-8').writelines(out)
PYE
set_author "$T12" orchestrator
g "$T12" add -A
g "$T12" commit -q -m "правка строки манифеста $N1x (не-минтная дельта)"
CZ_OUT="$(bash "$BARRIER/check_zones.sh" "$T12" 2>"$WORK/cz_err12")" && CZ_RC=0 || CZ_RC=$?
CZ_ERR="$(cat "$WORK/cz_err12")"
if [ "$CZ_RC" -ne 1 ] || ! { printf '%s%s' "$CZ_OUT" "$CZ_ERR" | grep -qF 'вне зоны'; } \
   || ! { printf '%s%s' "$CZ_OUT" "$CZ_ERR" | grep -qF 'registry/contracts.tsv'; }; then
  printf 'ОТКАЗ: в12: не-минтная дельта registry/contracts.tsv пропущена признанием (rc %s, ожидан rc 1 «коммит вне зоны» с именем пути): %s %s\n' "$CZ_RC" "$CZ_OUT" "$CZ_ERR" >&2
  exit 1
fi

# ── в13: дверь НЕ индульгенция на staged-коммит (Б2) ────────────────────────────
T13="$WORK/kor-${RD[12]}sm"
make_repo_orchzone "$T13"
toy_origin "$T13" >/dev/null
mint_tag_avtoritet "$T13" "$N1y"
set_author "$T13" orchestrator
stage_row "$T13" "$N1y" "$(git -C "$T13" rev-parse "refs/tags/id/CONTRACT/$N1y")"
mkdir -p "$T13/registry"
printf 'мусор вне зоны\n' > "$T13/registry/extra.tsv"
g "$T13" add -A
t13_id0="$(id_tags_of "$T13")"
run_bar "$T13"
assert_no_new_id_tags "$T13" "$t13_id0"
if [ "$BAR_RC" -ne 1 ] || ! printf '%s' "$BAR_ERR" | grep -qF 'вне зоны: registry/extra.tsv' \
   || ! printf '%s' "$BAR_OUT" | grep -qF 'дверь минта 031'; then
  printf 'ОТКАЗ: в13: смешанный staged (честный минт %s + registry/extra.tsv вне зоны) судится неверно (rc %s, ожидан rc 1 «вне зоны: registry/extra.tsv» ∧ judged-строка манифеста): %s | %s\n' "$N1y" "$BAR_RC" "$BAR_OUT" "$BAR_ERR" >&2
  exit 1
fi

printf 'ok: дверь минта 031 — все ворота пройдены (в0..в13, в4б, в5б, в8б)\n'
exit 0
