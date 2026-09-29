#!/usr/bin/env bash
# ПРЕД-ЗАМОРОЗОЧНОЕ КРАСНОЕ контракта 056 — дверь ahead-переснятия базлайна детектора
# утечек: режим `scripts/check_no_leak.sh --retake-ahead <абс-корень>`.
#
# Договор двери (контракт 056 §Инварианты — единый источник; фразы побайтово).
# Переснятие ahead-дельты ПРОИСХОДИТ ⟺ СЕМЬ шагов ВМЕСТЕ (порядок: снимок-цел →
# porcelain чист → двойное чтение манифеста → дельта непуста → ни одного `.git/*`
# в дельте → КАЖДЫЙ путь дельты ∈ `git diff --name-only origin/main..HEAD` →
# переснятие). Отказ — rc 1 ИМЕНОВАННОЙ причиной, СНИМОК НЕ ТРОНУТ; на входах с
# непустой дельтой последующий --check обязан остаться красным («переснятие,
# прячущее недоказанную дельту, краснеет» — слово владельца 2026-09-19, наследовано
# из 031/044 дословно). Успех — rc 0 + стенограмма «базлайн переснят: ahead-дельта
# <путь>» на КАЖДЫЙ путь + итог «базлайн переснят: ahead-дельта — путей <N>,
# вне диффа 0», последующий --check rc 0 «чист».
#
# Имя ВНЕ case_*-глоба — НАМЕРЕННО: семья no_leak раннера НЕ ИМЕЕТ вовсе (детектор
# НЕ БАРЬЕР, шапка scripts/check_no_leak.sh; каталог probe-only, контракт 034 инв. 1);
# предмет предъявляется ПРЯМЫМ запуском. Закоммичена архитектором ДО круга критика
# (AGENTS.md:131-136; блокер 1 вердикта к1): красный критерий кодовой задачи живёт
# в дереве до суда, обещание исполнителя закоммитить «потом» барьера не несёт.
#
# Форма — по прецеденту red_bulk_peresnjatie_bazlajna.sh (044): собственный WORK
# вне дерева, TMPDIR редиректится в скратч прогона (снимки субъекта — не в дереве
# и не в /tmp соседних прогонов), имена файлов/каталогов случайны КАЖДЫЙ прогон,
# toy-репо с toy-origin, ожидания — в переменных ДО вызова субъекта (оракул в
# памяти проверяющего, правило 8). Каждый вызов фикстуры гоняет ВСЕ клетки ДВА
# раза подряд с РАЗНЫМИ случайными входами (контракт 056 §Приёмочный критерий).
#
# ВХОДЫ (Н-39 — привязка стабов к ветвям по наблюдаемому входу; эта шапка —
# ЕДИНСТВЕННЫЙ носитель привязок, проза контракта их не несёт — блокер 2
# вердикта к1; каждая обманка различима от честной двери ровно на своей клетке):
#   а0 положительный контроль: snapshot → check на чистом дереве → rc 0 «основной
#      чекаут чист» — ЗЕЛЁНОЕ и ДО, и ПОСЛЕ (новый режим не ломает 024);
#   а1 определяющая (боль): дельта из ДВУХ путей, HEAD впереди toy-origin/main на
#      ДВА коммита (каждый объясняет СВОЙ путь), porcelain чист → --check rc 1
#      «загрязнён» (детектор ПРАВ по Демаркации 024) → --retake-ahead rc 0 +
#      стенограмма на каждый путь ПОБАЙТОВО + итог «— путей 2, вне диффа 0» +
#      --check rc 0. СЕГОДНЯ --retake-ahead отказан диспетчером (режима нет) —
#      КРАСНОЕ именем «ОТКАЗ а1 (режима)». УМИРАЕТ ЗДЕСЬ: стаб (1)
#      «диспетчер-заглушка» — на положительном входе обязан быть успех, заглушка
#      даёт usage-отказ;
#   а2 красная пара №1 (класс Н-164/165/166): после снимка в toy `.git/config`
#      посажена секция `[user]` (porcelain ЧИСТ — .git не tracked; живой класс
#      инцидента) → rc 1 «.git/* в дельте отказа: .git/config» + снимок не тронут
#      (байты до == после) + --check остаётся rc 1. УМИРАЮТ ЗДЕСЬ: стаб (2)
#      «безусловный do_snapshot» — переснял бы базлайн, байты снимка разошлись бы;
#      стаб (3) «membership раньше .git/*-ловца» — .git/config НЕ входит в diff, на
#      этом входе прозвучало бы генерическое имя «вне диффа», а не класс-имя;
#   а3 красная пара №2 (путь вне диффа, пустой diff): дельта закоммичена и
#      ЗАПУШЕНА (left-right «0 0», снимок устарел — забытый переснимок) → rc 1
#      «путь <путь> вне диффа origin/main..HEAD» (отказ именует единственный путь
#      дельты) + та же тройка. УМИРАЕТ ЗДЕСЬ: стаб (4) «только .git/*-ловец, без
#      membership» — немятый путь прошёл бы молча;
#   а4 красная пара №3 (porcelain): staged-правка поверх честной ahead-дельты →
#      rc 1 «porcelain не чист — дельта обязана быть закоммичена» + та же тройка.
#      УМИРАЕТ ЗДЕСЬ: стаб (5) «без porcelain» — грязное дерево прошло бы;
#   а5 красная пара №4 (пустая выборка): --check rc 0, дверь позвана → rc 1
#      «дельта пуста — нечего переснимать»; после отказа --check остаётся rc 0
#      (прецедент 044 б10: дерево честно чисто, пустая дельта — не загрязнение;
#      тройка НЕ применяется — СОВЕТ к1). УМИРАЕТ ЗДЕСЬ: стаб (6) «пустая дельта
#      = успех» — молчаливый rc 0 без стенограммы путей;
#   а6 красная пара №5 (авторитет недоступен): toy-репо БЕЗ удалённого origin
#      при непустой закоммиченной дельте → rc 1 «origin/main недоступен»
#      (fail-closed именем, не сырой fatal) + та же тройка. УМИРАЕТ ЗДЕСЬ:
#      стаб (7) «diff без rc-обёртки» — сырой fatal git прозвучал бы вместо
#      имени (grep по имени отказа его не находит);
#   а7 membership-клетка (блокер 4 вердикта к1: КАЖДЫЙ путь ∈ diff — не «хотя бы
#      один»): после снимка путь A закоммичен и ЗАПУШЕН, путь B закоммичен БЕЗ
#      пуша; refusal={A,B}, diff={B} → rc 1 «путь <A> вне диффа origin/main..HEAD»
#      + та же тройка (снимок не тронут — отказа БЕЗ переснятия). УМИРАЕТ ЗДЕСЬ:
#      контрмодель (8) «непустое пересечение refusal ∩ diff + переснятие всего
#      базлайна» — дала бы rc 0 и спрятала бы A; тройка ловит и «переснял после
#      первого совпадения» (байты снимка разошлись бы).
#   а8 пост-заморозочная (F2 вердикта contracts-056-v1; прецедент 005): cwd —
#      НЕ-репозиторий без снимка; вход `--retake-ahead .` → rc 1 «корень обязан
#      быть абсолютным» ДО любого обращения к снимку: в выводе НЕТ чужого имени
#      «снимок отсутствует», каталоги снимков не изменились. УМИРАЕТ ЗДЕСЬ:
#      стаб (9) «гард абсолютности принимает точку» — ушёл бы в работу корня и
#      отказал посторонним именем;
#   а9 пост-заморозочная (F3 того вердикта): вход `--retake-ahead /tmp extra`
#      → rc 1 usage-отказ диспетчера «ОТКАЗ диспетчер: использование» — арность
#      ровно два аргумента, лишний отвергнут ДО разбора корня. УМИРАЕТ ЗДЕСЬ:
#      стаб (10) «арность -ge 2» — принял бы третий аргумент и ушёл в работу
#      корня;
#   а10 пост-заморозочная (Р2 вердикта contracts-056-v1; прецедент 005):
#      положительная ahead-дельта из ОДНОГО пути с ЛИТЕРАЛЬНЫМ обратным
#      слэшем в имени (репро F1 ревьюера: docs/a\b.md) → --check rc 1
#      «загрязнён» → --retake-ahead rc 0 + стенограмма пути в enc_path-форме
#      (грамматика манифеста: `\` → `\\`) + итог «— путей 1, вне диффа 0» +
#      --check rc 0. УМИРАЕТ ЗДЕСЬ: откат фикса F1 (c389c47) — enc_path-форма
#      манифеста сравнивалась с C-quoted выводом `git diff --name-only` без
#      -z (`"docs/a\\b.md"` с кавычками), честный путь ложно отказан именем
#      «вне диффа»; ровно на этом входе откат и различим — пути без
#      спецсимволов C-quoting не получают, клетки а0..а9 его не ловят;
#
# На отказывающих входах с непустой дельтой (а2–а4, а6, а7) фикстура сверяет
# ТРОЙКУ: именованный отказ ∧ байты снимка до == после ∧ --check остаётся rc 1
# «основной чекаут загрязнён» — прячущее переснятие наблюдаемо краснеет.
#
# Коды возврата: 0 — ворота пройдены (оба прогона); 1 — именованный отказ
#               (режим отсутствует либо нарушил договор на воротах).
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
SUBJ="$REPO/scripts/check_no_leak.sh"

[ -f "$SUBJ" ] || {
  printf 'ОТКАЗ: детектор отсутствует — scripts/check_no_leak.sh\n' >&2
  exit 1
}

P_ZAGR='основной чекаут загрязнён'
P_CHISTO='основной чекаут чист'

ok()   { printf '  ok   %s (%s)\n' "$1" "$2" >&2; }
fail() { printf 'ОТКАЗ %s (%s): %s\n' "$1" "$2" "$3" >&2; exit 1; }

run_subj() {  # <режим> <корень>: rc без пайпов (Н-84/Н-85), вывод в SUBJ_OUT
  local mode="$1" root="$2"
  SUBJ_OUT="$( bash "$SUBJ" "$mode" "$root" 2>&1 )" && SUBJ_RC=0 || SUBJ_RC=$?
}
has() { printf '%s\n' "$SUBJ_OUT" | grep -qF -- "$1"; }

# gtoy <каталог> <git-аргументы...> — герметичный git toy-репо (прецедент 044:
# глобальный/системный конфиг отключён, gpgsign/hooks — мимо).
gtoy() {
  local d="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$d" -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}

# mk_root <каталог>: минимальный toy-репо (дверь 056 НЕ читает реестр зон —
# граница-4 контракта; зонных тегов toy не несёт).
mk_root() {  # <каталог>
  local r="$1"
  mkdir -p "$r/docs"
  printf 'база\n' > "$r/HANDOFF.md"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  gtoy "$r" -c user.name=Фикстура -c user.email=fixture@local add -A
  gtoy "$r" -c user.name=Фикстура -c user.email=fixture@local commit -q -m 'основание'
}

# mk_origin <каталог>: голый toy-origin + пуш main (remote add правит .git/config —
# ДО снимка, чтобы дельта клетки несла только своё).
mk_origin() {  # <каталог>
  local r="$1"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q --bare "$r-origin.git"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" remote add origin "$r-origin.git"
  gtoy "$r" push -q origin main
}

# commit_kak <каталог> <путь> <содержимое>: закоммитить файл (main-direct коммит).
commit_kak() {  # <каталог> <путь> <содержимое>
  local r="$1" p="$2"
  mkdir -p "$r/$(dirname "$p")"
  printf '%s\n' "$3" > "$r/$p"
  gtoy "$r" -c user.name=Фикстура -c user.email=fixture@local add -A
  gtoy "$r" -c user.name=Фикстура -c user.email=fixture@local commit -q -m "посадка $p"
}

# снимок субъекта живёт ВНЕ дерева; путь вычислим от корня — фиксируем байты снимка
# до/после --retake-ahead (отказ НЕ тронул базлайн). Прецедент 044 snap_of.
snap_of() {  # <корень> → путь файла-снимка
  local h8
  h8="$(printf '%s' "$1" | sha256sum)"
  h8="${h8%% *}"; h8="${h8:0:8}"
  printf '%s/dev-harness-leak/%s/porcelain' "${TMPDIR:-/tmp}" "$h8"
}
# ── общий каркас отказывающих входов: имя отказа + снимок не тронут + дельта видна ─
# ozhid_otkaz <имя-клетки> <фраза-отказа>: фраза подсчитана ДО вызова субъекта.
ozhid_otkaz() {  # <клетка> <фраза>
  local imja="$1" fraza="$2"
  local snap do_bytes posle
  snap="$(snap_of "$KURI")"
  do_bytes="$(sha256sum < "$snap" 2>/dev/null)"
  run_subj --retake-ahead "$KURI"
  if [ "$SUBJ_RC" -ne 1 ] || ! has "$fraza"; then
    printf 'ОТКАЗ %s: --retake-ahead не дал именованного отказа (rc=%s, ожидан rc 1 + «%s»): %s\n' \
      "$imja" "$SUBJ_RC" "$fraza" "$SUBJ_OUT" >&2
    exit 1
  fi
  posle="$(sha256sum < "$snap" 2>/dev/null)"
  if [ "$do_bytes" != "$posle" ]; then
    printf 'ОТКАЗ %s: переснятие-отказ ТРОНУЛО снимок — прячущее переснятие (байты разошлись)\n' "$imja" >&2
    exit 1
  fi
  run_subj --check "$KURI"
  if [ "$SUBJ_RC" -ne 1 ] || ! has "$P_ZAGR"; then
    printf 'ОТКАЗ %s: после отказа --retake-ahead дельта спрятана (--check не красен, rc=%s) — прячущее переснятие\n' "$imja" "$SUBJ_RC" >&2
    exit 1
  fi
  ok "$imja" "отказ именован, снимок не тронут, дельта видна"
}

WORKTOP="$(mktemp -d /tmp/red056-ahead.XXXXXX)"   # А-78: свежий WORK вне дерева
trap 'rm -rf "$WORKTOP"' EXIT

# ── ДВА прогона подряд с РАЗНЫМИ случайными входами (контракт §Приёмочный
# критерий; инвариантность к значениям — Демаркация) ─────────────────────────────
for RUN in 1 2; do
R="${RUN}$RANDOM$$"
WORK="$WORKTOP/r$RUN"
mkdir -p "$WORK/snaps"
export TMPDIR="$WORK/snaps"                       # снимки субъекта — в скратч прогона

# ── а0: положительный контроль (снимок/сверка 024 не ломаются) ──────────────────
KURI="$WORK/a0_r${R}"
mk_root "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail а0 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
run_subj --check "$KURI"
if [ "$SUBJ_RC" -ne 0 ] || ! has "$P_CHISTO"; then
  fail а0 проверки "check на чистом дереве не зелёный (rc=$SUBJ_RC): $SUBJ_OUT"
fi
ok а0 "снимок/сверка 024 живы (прогон $RUN)"

# ── а1: боль — двухпутевая ahead-дельта; режима нет ──────────────────────────────
KURI="$WORK/a1_r${R}"
mk_root "$KURI"
mk_origin "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail а1 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
P1="docs/a1-pervyj-${R}.md"
P2="docs/a1-vtoroj-${R}.md"
commit_kak "$KURI" "$P1" 'первый честный ahead-путь'
commit_kak "$KURI" "$P2" 'второй честный ahead-путь'
# контроль воспроизведения: porcelain чист ∧ diff покрывает ОБА пути (head-ahead)
PORC_A1="$(gtoy "$KURI" status --porcelain)"
[ -z "$PORC_A1" ] || fail а1 входа "porcelain не чист — вход не воспроизводит класс: $PORC_A1"
DIFF_A1="$(gtoy "$KURI" diff --name-only origin/main..HEAD | sort)"
[ "$DIFF_A1" = "$(printf '%s\n%s' "$P1" "$P2" | sort)" ] \
  || fail а1 входа "diff не покрывает оба пути: $DIFF_A1"
run_subj --check "$KURI"
if [ "$SUBJ_RC" -ne 1 ] || ! has "$P_ZAGR"; then
  fail а1 детектора "--check обязан краснеть на ahead-дельте (rc=$SUBJ_RC): $SUBJ_OUT"
fi
# ожидания — в памяти ДО вызова субъекта (правило 8)
E1="базлайн переснят: ahead-дельта $P1"
E2="базлайн переснят: ahead-дельта $P2"
EI='базлайн переснят: ahead-дельта — путей 2, вне диффа 0'
run_subj --retake-ahead "$KURI"
if [ "$SUBJ_RC" -ne 0 ]; then
  fail а1 режима "--retake-ahead не дал успеха (rc=$SUBJ_RC): $SUBJ_OUT"
fi
has "$E1" || fail а1 стенограммы "нет строки пути $P1: $SUBJ_OUT"
has "$E2" || fail а1 стенограммы "нет строки пути $P2: $SUBJ_OUT"
has "$EI" || fail а1 итога "нет итоговой строки двух путей: $SUBJ_OUT"
run_subj --check "$KURI"
if [ "$SUBJ_RC" -ne 0 ] || ! has "$P_CHISTO"; then
  fail а1 пост-чека "после переснятия --check обязан быть чист (rc=$SUBJ_RC): $SUBJ_OUT"
fi
ok а1 "ahead-дельта переснята, стенограмма 2 путей, чекаут чист (прогон $RUN)"

# ── а2: .git/config в дельте отказа — класс Н-164/165/166 ───────────────────────
KURI="$WORK/a2_r${R}"
mk_root "$KURI"
mk_origin "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail а2 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
printf '\n[user]\n\tname = orchestrator\n\temail = orchestrator@local\n' >> "$KURI/.git/config"
# контроль воспроизведения: porcelain ЧИСТ (живой класс: .git не tracked)
PORC_A2="$(gtoy "$KURI" status --porcelain)"
[ -z "$PORC_A2" ] || fail а2 входа "porcelain видит правку — вход не воспроизводит класс: $PORC_A2"
run_subj --check "$KURI"
[ "$SUBJ_RC" -eq 1 ] || fail а2 детектора "--check обязан видеть .git/config-дельту (rc=$SUBJ_RC): $SUBJ_OUT"
FRAZA_A2='переснятие-ahead не доказано: .git/* в дельте отказа: .git/config'
ozhid_otkaz а2 "$FRAZA_A2"

# ── а3: дельта запушена, diff пуст — путь вне диффа ─────────────────────────────
KURI="$WORK/a3_r${R}"
mk_root "$KURI"
mk_origin "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail а3 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
P3="docs/a3-${R}.md"
commit_kak "$KURI" "$P3" 'запушенная дельта — забытый переснимок'
gtoy "$KURI" push -q origin main
# контроль воспроизведения: left-right «0 0» ∧ diff пуст
LR_A3="$(gtoy "$KURI" rev-list --left-right --count origin/main...HEAD)"
[ "$LR_A3" = "0"$'\t'"0" ] || fail а3 входа "left-right не 0 0: $LR_A3"
DIFF_A3="$(gtoy "$KURI" diff --name-only origin/main..HEAD)"
[ -z "$DIFF_A3" ] || fail а3 входа "diff не пуст: $DIFF_A3"
run_subj --check "$KURI"
[ "$SUBJ_RC" -eq 1 ] || fail а3 детектора "--check обязан видеть устаревший снимок (rc=$SUBJ_RC): $SUBJ_OUT"
FRAZA_A3="переснятие-ahead не доказано: путь $P3 вне диффа origin/main..HEAD"
ozhid_otkaz а3 "$FRAZA_A3"

# ── а4: staged-правка поверх честной ahead-дельты — porcelain не чист ───────────
KURI="$WORK/a4_r${R}"
mk_root "$KURI"
mk_origin "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail а4 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
P4="docs/a4-${R}.md"
commit_kak "$KURI" "$P4" 'честная ahead-дельта'
printf 'незакоммиченная правка\n' >> "$KURI/$P4"
gtoy "$KURI" add -A
# контроль воспроизведения: porcelain ГРЯЗНЫЙ (иначе вход не вход шага 2)
PORC_A4="$(gtoy "$KURI" status --porcelain)"
[ -n "$PORC_A4" ] || fail а4 входа "porcelain чист — вход не воспроизводит класс"
run_subj --check "$KURI"
[ "$SUBJ_RC" -eq 1 ] || fail а4 детектора "--check обязан видеть дельту (rc=$SUBJ_RC): $SUBJ_OUT"
FRAZA_A4='переснятие-ahead не доказано: porcelain не чист — дельта обязана быть закоммичена'
ozhid_otkaz а4 "$FRAZA_A4"

# ── а5: дельта пуста — пустая выборка красная именем ────────────────────────────
KURI="$WORK/a5_r${R}"
mk_root "$KURI"
mk_origin "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail а5 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
run_subj --check "$KURI"
if [ "$SUBJ_RC" -ne 0 ] || ! has "$P_CHISTO"; then
  fail а5 контроля "дерево обязано быть чисто до вызова двери (rc=$SUBJ_RC): $SUBJ_OUT"
fi
SNAP_A5="$(snap_of "$KURI")"
DO_A5="$(sha256sum < "$SNAP_A5" 2>/dev/null)"
FRAZA_A5='переснятие-ahead не доказано: дельта пуста — нечего переснимать'
run_subj --retake-ahead "$KURI"
if [ "$SUBJ_RC" -ne 1 ] || ! has "$FRAZA_A5"; then
  fail а5 режима "--retake-ahead на пустой дельте обязан отказать именем (rc=$SUBJ_RC): $SUBJ_OUT"
fi
POSLE_A5="$(sha256sum < "$SNAP_A5" 2>/dev/null)"
[ "$DO_A5" = "$POSLE_A5" ] || fail а5 снимка "отказ пустой дельты ТРОНУЛ снимок (байты разошлись)"
run_subj --check "$KURI"
if [ "$SUBJ_RC" -ne 0 ]; then
  fail а5 пост-чека "после отказа на пустой дельте --check обязан остаться чист (rc=$SUBJ_RC): $SUBJ_OUT"
fi
ok а5 "пустая дельта красна именем, не зелёна молча (прогон $RUN)"

# ── а6: toy-репо БЕЗ origin — авторитет недоступен, fail-closed именем ─────────
KURI="$WORK/a6_r${R}"
mk_root "$KURI"
# НИКАКОГО mk_origin: удалённого origin нет вовсе
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail а6 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
P6="docs/a6-${R}.md"
commit_kak "$KURI" "$P6" 'непокрытая дельта без origin'
# контроль воспроизведения: origin/main НЕ разрешается ∧ porcelain чист
if gtoy "$KURI" rev-parse --verify --quiet origin/main >/dev/null 2>&1; then
  fail а6 входа "origin/main разрешается — вход не воспроизводит класс"
fi
PORC_A6="$(gtoy "$KURI" status --porcelain)"
[ -z "$PORC_A6" ] || fail а6 входа "porcelain не чист — вход не воспроизводит класс: $PORC_A6"
run_subj --check "$KURI"
[ "$SUBJ_RC" -eq 1 ] || fail а6 детектора "--check обязан видеть дельту (rc=$SUBJ_RC): $SUBJ_OUT"
FRAZA_A6='переснятие-ahead не доказано: origin/main недоступен'
ozhid_otkaz а6 "$FRAZA_A6"

# ── а7: membership-клетка — refusal={A,B}, diff={B} → отказ именем A ────────────
KURI="$WORK/a7_r${R}"
mk_root "$KURI"
mk_origin "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail а7 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
PA="docs/a7-a-${R}.md"
PB="docs/a7-b-${R}.md"
commit_kak "$KURI" "$PA" 'путь A — запушен, дельту НЕ объясняет'
gtoy "$KURI" push -q origin main
commit_kak "$KURI" "$PB" 'путь B — локальный ahead, объясняет свою дельту'
# контроль воспроизведения: porcelain чист ∧ diff ровно {B} (A в origin/main)
PORC_A7="$(gtoy "$KURI" status --porcelain)"
[ -z "$PORC_A7" ] || fail а7 входа "porcelain не чист — вход не воспроизводит класс: $PORC_A7"
DIFF_A7="$(gtoy "$KURI" diff --name-only origin/main..HEAD | sort)"
[ "$DIFF_A7" = "$PB" ] || fail а7 входа "diff не равен ровно {$PB}: $DIFF_A7"
run_subj --check "$KURI"
[ "$SUBJ_RC" -eq 1 ] || fail а7 детектора "--check обязан видеть дельту {A,B} (rc=$SUBJ_RC): $SUBJ_OUT"
FRAZA_A7="переснятие-ahead не доказано: путь $PA вне диффа origin/main..HEAD"
ozhid_otkaz а7 "$FRAZA_A7"

# ── а8: относительный корень — гвард абсолютности ДО любой работы (F2) ──────────
KURI="$WORK/a8_r${R}"                    # cwd-каталог: НЕ репозиторий, снимка нет
mkdir -p "$KURI"
LEAK_A8="${TMPDIR:-/tmp}/dev-harness-leak"
DO_LS_A8="$(ls -1A "$LEAK_A8" 2>/dev/null | LC_ALL=C sort)"
FRAZA_A8='корень обязан быть абсолютным'   # ожидание — в памяти ДО вызова (пр. 8)
FRAZA_A8_CHUZH='снимок отсутствует'
SUBJ_OUT="$( cd "$KURI" && bash "$SUBJ" --retake-ahead . 2>&1 )" && SUBJ_RC=0 || SUBJ_RC=$?
if [ "$SUBJ_RC" -ne 1 ] || ! has "$FRAZA_A8"; then
  fail а8 режима "--retake-ahead . обязан отказать именем абсолютности (rc=$SUBJ_RC): $SUBJ_OUT"
fi
if has "$FRAZA_A8_CHUZH"; then
  fail а8 порядка "имя абсолютности пришло ПОСЛЕ обращения к снимку (чужое имя в выводе): $SUBJ_OUT"
fi
POSLE_LS_A8="$(ls -1A "$LEAK_A8" 2>/dev/null | LC_ALL=C sort)"
[ "$DO_LS_A8" = "$POSLE_LS_A8" ] || fail а8 снимка "отказ абсолютности изменил каталоги снимков"
ok а8 "относительный корень отказан именем абсолютности до любой работы (прогон $RUN)"

# ── а9: точная арность — лишний аргумент = usage-отказ диспетчера (F3) ──────────
FRAZA_A9='ОТКАЗ диспетчер: использование'  # ожидание — в памяти ДО вызова (пр. 8)
SUBJ_OUT="$( bash "$SUBJ" --retake-ahead /tmp extra 2>&1 )" && SUBJ_RC=0 || SUBJ_RC=$?
if [ "$SUBJ_RC" -ne 1 ] || ! has "$FRAZA_A9"; then
  fail а9 диспетчера "--retake-ahead /tmp extra обязан дать usage-отказ rc 1 (rc=$SUBJ_RC): $SUBJ_OUT"
fi
ok а9 "лишний аргумент отвергнут диспетчером rc 1 (прогон $RUN)"

# ── а10: ahead-дельта с ЛИТЕРАЛЬНЫМ '\' — закрепление F1 (Р2 056-v1) ────────────
KURI="$WORK/a10_r${R}"
mk_root "$KURI"
mk_origin "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail а10 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
P10="docs/a10\a-${R}.md"      # ЛИТЕРАЛЬНЫЙ обратный слэш в имени (репро F1)
commit_kak "$KURI" "$P10" 'честный ahead-путь с обратным слэшем'
# контроль воспроизведения: porcelain чист ∧ -z-дифф = литеральный путь ∧
# без -z git эмитит C-style quoting (класс F1: формы расходятся байтами)
PORC_A10="$(gtoy "$KURI" status --porcelain)"
[ -z "$PORC_A10" ] || fail а10 входа "porcelain не чист — вход не воспроизводит класс: $PORC_A10"
DIFF_A10="$(gtoy "$KURI" diff -z --name-only origin/main..HEAD | tr -d '\0')"
[ "$DIFF_A10" = "$P10" ] \
  || fail а10 входа "-z-дифф не равен литеральному пути $P10: $DIFF_A10"
QC_A10="$(gtoy "$KURI" diff --name-only origin/main..HEAD)"
[ "$QC_A10" = "\"${P10//\\/\\\\}\"" ] \
  || fail а10 входа "дифф без -z не C-quoted — вход не воспроизводит класс F1: $QC_A10"
run_subj --check "$KURI"
if [ "$SUBJ_RC" -ne 1 ] || ! has "$P_ZAGR"; then
  fail а10 детектора "--check обязан краснеть на ahead-дельте (rc=$SUBJ_RC): $SUBJ_OUT"
fi
# ожидания — в памяти ДО вызова субъекта (правило 8); стенограмма несёт
# enc_path-форму манифеста (`\` → `\\`, тот же примитив из единого P10)
E10="базлайн переснят: ahead-дельта ${P10//\\/\\\\}"
EI10='базлайн переснят: ahead-дельта — путей 1, вне диффа 0'
run_subj --retake-ahead "$KURI"
if [ "$SUBJ_RC" -ne 0 ]; then
  fail а10 режима "--retake-ahead не дал успеха (rc=$SUBJ_RC): $SUBJ_OUT"
fi
has "$E10" || fail а10 стенограммы "нет строки enc_path-формы пути ${P10//\\/\\\\}: $SUBJ_OUT"
has "$EI10" || fail а10 итога "нет итоговой строки одного пути: $SUBJ_OUT"
run_subj --check "$KURI"
if [ "$SUBJ_RC" -ne 0 ] || ! has "$P_CHISTO"; then
  fail а10 пост-чека "после переснятия --check обязан быть чист (rc=$SUBJ_RC): $SUBJ_OUT"
fi
ok а10 "ahead-дельта с обратным слэшем переснята, стенограмма enc_path, чекаут чист (прогон $RUN)"

done  # RUN

printf 'ok: дверь ahead-переснятия 056 — все ворота пройдены (а0..а10, два прогона)\n'
exit 0
