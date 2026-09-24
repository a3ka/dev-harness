#!/usr/bin/env bash
# ПРЕД-ЗАМОРОЗОЧНОЕ КРАСНОЕ контракта 044 — дверь bulk-переснятия базлайна детектора
# утечек (Н-139): режим `scripts/check_no_leak.sh --retake-bulk <абс-корень>`.
#
# Договор двери (контракт 044 §Инварианты — единый источник; фразы побайтово).
# Переснятие bulk-дельты ПРОИСХОДИТ ⟺ ДЕВЯТЬ шагов ВМЕСТЕ (порядок: снимок цел →
# porcelain чист → двойное чтение манифеста → дельта непуста → реестр зон жив →
# origin/main разрешается → на КАЖДЫЙ путь дельты: байты закоммичены ∧ путь покрыт
# зоной ПОЛНОГО реестра (без verdicts/-префикса) ∧ коммит слит на origin/main ∧ автор —
# владелец зоны → глобально left-right origin/main...HEAD == «0<TAB>0»). Отказ — rc 1
# ИМЕНОВАННОЙ причиной, СНИМОК НЕ ТРОНУТ: последующий --check обязан остаться красным
# («переснятие, прячущее недоказанную дельту, краснеет» — слово владельца 2026-09-19,
# наследовано из 031 дословно). Успех — rc 0 + стенограмма «базлайн переснят:
# bulk-дельта <путь> (автор <автор>, коммит <sha>)» на КАЖДЫЙ путь + итог «базлайн
# переснят: bulk-дельта — путей <N>, незакоммиченного/неслитого 0», последующий
# --check rc 0 «чист».
#
# Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (прецедент red_peresnjatie_bazlajna.sh 031
# + поправка v3 031: case-файлы семьи check_judge_gate геновно недостижимы, раннер
# заморожен 008): до реализации предмет предъявляется ПРЯМЫМ запуском; приёмка — ДВА
# прогона подряд с РАЗНЫМИ случайными входами. Фикстура ДВУХФАЗНАЯ: сегодня красна
# ЕДИНОЙ причиной (режим --retake-bulk отсутствует — диспетчер отказывает на ВСЕХ
# входах одинаково), после реализации все ворота зелёные.
#
# Форма — по прецеденту red_peresnjatie_bazlajna.sh: собственный WORK вне дерева,
# TMPDIR редиректится в скратч прогона (снимки субъекта — не в дереве и не в /tmp
# соседних прогонов), имена файлов/каталогов случайны КАЖДЫЙ прогон.
#
# ВХОДЫ (Н-39 — привязка к ветвям по коду двери; каждая фраза ≡ ровно один вход):
#   б0 положительный контроль: snapshot → check на чистом дереве → rc 0 «основной
#      чекаут чист» — ЗЕЛЁНОЕ и ДО, и ПОСЛЕ (новый режим не ломает 024);
#   б1 боль Н-139 (определяющая): bulk-дельта из ЧЕТЫРЁХ путей ЧЕТЫРЁХ зон toy-реестра
#      (verdicts/review/* — reviewer, contracts/* — architect, scripts/* — implementer,
#      HANDOFF.md — orchestrator; класс исходного инцидента: 17 путей разных зон ВНЕ
#      verdicts/-цикла «один вердикт»), каждый закоммичен под верной identity, всё
#      запушено на toy-origin, porcelain чист → --check rc 1 «загрязнён» (детектор
#      ПРАВ по Демаркации 024 — состояние изменилось) → --retake-bulk: ПОСЛЕ rc 0 +
#      стенограмма на каждый путь ПОБАЙТОВО (путь/автор/sha последнего коммита пути) +
#      итог «— путей 4, незакоммиченного/неслитого 0» + --check rc 0. СЕГОДНЯ
#      --retake-bulk отказан диспетчером (режима нет) — КРАСНОЕ;
#   б2 ОДИН путь не закоммичен (staged-правка без коммита поверх закоммиченной
#      дельты, porcelain ГРЯЗНЫЙ) → ПОСЛЕ rc 1 «переснятие-bulk не доказано: porcelain
#      не чист — дельта обязана быть закоммичена» + снимок не тронут. Fail-closed ВСЕЙ
#      группой: ни один путь не переснимается частично;
#   б3 ОДИН путь закоммичен, но НЕ запушен (коммит после пуша — существует только
#      локально) → ПОСЛЕ rc 1 «переснятие-bulk не доказано: коммит <sha> пути <путь>
#      не достижим на origin/main» + снимок не тронут. Ровно та дыра, которую
#      origin-достижимость задумана закрывать: фальсифицируемый локальный коммит — не
#      доказательство. Стаб «проверять только глобальный left-right» умирает здесь
#      (его фраза на этом входе не прозвучала бы — порядок per-path РАНЬШЕ
#      глобального); стаб «только per-path» умирает на б4 (граница-5 044);
#   б4 неслитый tip БЕЗ путей дельты (пустой коммит поверх пуша) → ПОСЛЕ rc 1
#      «переснятие-bulk не доказано: история разошлась с origin/main (left-right ≠ 0
#      0)» + снимок не тронут. Все per-path проверки на этом входе ПРОХОДЯТ — неслитое
#      ловит только глобальная ветвь: её живость доказана входом, а не словами;
#   б5 путь не покрыт НИ ОДНОЙ зоной реестра (docs/*) → ПОСЛЕ rc 1 «переснятие-bulk
#      не доказано: путь <путь> не покрыт ни одной зоной» + снимок не тронут. Замок
#      границы-3 044: единственный реальный кандидат-утечка исходного Н-139-инцидента
#      был .git/config — незонированный путь НЕ переснимается молча;
#   б6 путь зоны architect, коммит авторства reviewer (чужой автор) → ПОСЛЕ rc 1
#      «переснятие-bulk не доказано: автор reviewer пути <путь> не владелец зоны» +
#      снимок не тронут;
#   б7 НЕЗАКОММИЧЕННЫЕ байты под assume-unchanged (продолжение Б3 031): коммиты
#      запушены, затем байты файла изменены БЕЗ коммита + git update-index
#      --assume-unchanged — porcelain ПУСТ, все прочие условия сходились → ПОСЛЕ rc 1
#      «переснятие-bulk не доказано: байты дельта-пути не закоммичены (porcelain лжёт:
#      assume-unchanged/skip-worktree)» + снимок не тронут;
#   б8 ослеплённый реестр (.git/refs/tags закрыт на чтение ПОСЛЕ пуша: zones_load
#      rc 0 с ПУСТЫМ реестром — измерено кругом 2 031) → ПОСЛЕ rc 1 «переснятие-bulk
#      не доказано: реестр зон пуст — читатель ослеплён» + снимок не тронут;
#   б9 отказ читателя зон rc≠0 (frozen-тег запушен на toy-origin и удалён ЛОКАЛЬНО —
#      измерено р10 031: registry_state видит потерю, zones_load rc 2) → ПОСЛЕ rc 1
#      «реестр зон недоступен» + снимок не тронут;
#   б10 дельта ПУСТА (снимок соответствует дереву) → ПОСЛЕ rc 1 «переснятие-bulk не
#      доказано: дельта пуста — нечего переснимать» (пустая выборка красная, не
#      зелёная) + --check rc 0 (дерево чисто — пустая дельта не «загрязнение»).
#
# На каждом отказывающем входе (б2–б9) фикстура сверяет ТРОЙКУ: именованный отказ ∧
# байты снимка до == после ∧ --check остаётся rc 1 «основной чекаут загрязнён» —
# прячущее переснятие наблюдаемо краснеет.
#
# Коды возврата: 0 — ворота пройдены; 1 — именованный отказ (режим отсутствует либо
#               нарушил договор на воротах).
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

WORK="$(mktemp -d /tmp/red044-bulk.XXXXXX)"   # А-78: свежий WORK вне дерева
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/snaps"
export TMPDIR="$WORK/snaps"                       # снимки субъекта — в скратч прогона

ok()   { printf '  ok   %s (%s)\n' "$1" "$2" >&2; }
fail() { printf 'ОТКАЗ %s (%s): %s\n' "$1" "$2" "$3" >&2; exit 1; }

run_subj() {  # <режим> <корень>: rc без пайпов (Н-84/Н-85), вывод в SUBJ_OUT
  local mode="$1" root="$2"
  SUBJ_OUT="$( bash "$SUBJ" "$mode" "$root" 2>&1 )" && SUBJ_RC=0 || SUBJ_RC=$?
}
has() { printf '%s\n' "$SUBJ_OUT" | grep -qF -- "$1"; }

# gtoy <каталог> <git-аргументы...> — герметичный git toy-репо (прецедент _repo.sh:
# глобальный/системный конфиг отключён, gpgsign/hooks — мимо).
gtoy() {
  local d="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$d" -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}

# mk_bulk_root <каталог>: toy-репо с замороженным контрактом 001, зонирующим ЧЕТЫРЕ
# зоны (класс Н-139: дельта живёт в РАЗНЫХ зонах, ВНЕ verdicts/-префикса): ЗОНА
# reviewer: verdicts/review/, ЗОНА architect: contracts/, ЗОНА implementer: scripts/,
# ЗОНА orchestrator: HANDOFF.md. Зоны читает zones_load по тегу frozen/contracts/001/1
# — единый читатель ЗОНА-строк.
mk_bulk_root() {  # <каталог>
  local r="$1"
  mkdir -p "$r/contracts" "$r/verdicts/review" "$r/scripts"
  {
    printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\n'
    printf 'ЗОНА reviewer: verdicts/review/\n'
    printf 'ЗОНА architect: contracts/\n'
    printf 'ЗОНА implementer: scripts/\n'
    printf 'ЗОНА orchestrator: HANDOFF.md\n'
  } > "$r/contracts/001-x.md"
  printf 'база\n' > "$r/scripts/a.sh"
  printf '# передача\n' > "$r/HANDOFF.md"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  gtoy "$r" -c user.name=Фикстура -c user.email=fixture@local add -A
  gtoy "$r" -c user.name=Фикстура -c user.email=fixture@local commit -q -m 'основание'
  gtoy "$r" -c user.name=Фикстура -c user.email=fixture@local tag -a frozen/contracts/001/1 -m 'утверждён'
}

# mk_origin <каталог>: голый toy-origin + пуш main И frozen-тега (модель слитого
# состояния Н-139: HEAD == origin/main, left-right «0 0»).
mk_origin() {  # <каталог>
  local r="$1"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q --bare "$r-origin.git"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" remote add origin "$r-origin.git"
  gtoy "$r" push -q origin main
  gtoy "$r" push -q origin refs/tags/frozen/contracts/001/1
}

# commit_kak <каталог> <автор> <путь> <содержимое>: закоммитить файл от имени автора
# (модель main-direct коммита зоны — вердикт судьи / инженерный фикс / черновик).
commit_kak() {  # <каталог> <автор> <путь> <содержимое>
  local r="$1" avtor="$2" p="$3"
  mkdir -p "$r/$(dirname "$p")"
  printf '%s\n' "$4" > "$r/$p"
  gtoy "$r" -c user.name="$avtor" -c user.email="$avtor@local" add -A
  gtoy "$r" -c user.name="$avtor" -c user.email="$avtor@local" commit -q -m "посадка $p ($avtor)"
}

# append_kak <каталог> <автор> <путь> <строка>: закоммитить ПРАВКУ существующего файла
# (модель модификации — HANDOFF.md инцидента Н-139 менялся, а не создавался).
append_kak() {  # <каталог> <автор> <путь> <строка>
  local r="$1" avtor="$2" p="$3"
  printf '%s\n' "$4" >> "$r/$p"
  gtoy "$r" -c user.name="$avtor" -c user.email="$avtor@local" add -A
  gtoy "$r" -c user.name="$avtor" -c user.email="$avtor@local" commit -q -m "правка $p ($avtor)"
}

# снимок субъекта живёт ВНЕ дерева; путь вычислим от корня — фиксируем байты снимка
# до/после --retake-bulk (снятие НЕ тронуло базлайн).
snap_of() {  # <корень> → путь файла-снимка
  local h8
  h8="$(printf '%s' "$1" | sha256sum)"
  h8="${h8%% *}"; h8="${h8:0:8}"
  printf '%s/dev-harness-leak/%s/porcelain' "$WORK/snaps" "$h8"
}

# ── б0: положительный контроль (снимок/сверка 024 не ломаются) ──────────────────
K0="$WORK/b0_${RANDOM}"
mk_bulk_root "$K0"
run_subj --snapshot "$K0"
[ "$SUBJ_RC" -eq 0 ] || fail б0 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
run_subj --check "$K0"
if [ "$SUBJ_RC" -ne 0 ] || ! has "$P_CHISTO"; then
  fail б0 проверки "check на чистом дереве не зелёный (rc=$SUBJ_RC): $SUBJ_OUT"
fi
ok б0 "снимок/сверка 024 живы"

# ── б1: боль Н-139 — четырёхпутевая межзонная bulk-дельта; режима нет ────────────
K1="$WORK/b1_${RANDOM}"
mk_bulk_root "$K1"
mk_origin "$K1"
run_subj --snapshot "$K1"
[ "$SUBJ_RC" -eq 0 ] || fail б1 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
VP="verdicts/review/contracts-001-b1.md"
CP="contracts/002-dopolnitelnyj-${RANDOM}.md"
SP="scripts/fix-b1-${RANDOM}.sh"
commit_kak "$K1" reviewer    "$VP" 'accept — вердикт ревьюера'
commit_kak "$K1" architect   "$CP" 'дополнение предмета'
commit_kak "$K1" implementer "$SP" 'инженерный фикс'
append_kak   "$K1" orchestrator HANDOFF.md 'чекпойнт ночи'
gtoy "$K1" push -q origin main
run_subj --check "$K1"
if [ "$SUBJ_RC" -ne 1 ] || ! has "$P_ZAGR"; then
  fail б1 детектора "--check обязан краснеть на bulk-дельте (rc=$SUBJ_RC): $SUBJ_OUT"
fi
# ожидаемые строки стенограммы — по живым sha последнего коммита КАЖДОГО пути
SHA_VP="$(gtoy "$K1" log -1 --format=%H -- "$VP")"
SHA_CP="$(gtoy "$K1" log -1 --format=%H -- "$CP")"
SHA_SP="$(gtoy "$K1" log -1 --format=%H -- "$SP")"
SHA_HP="$(gtoy "$K1" log -1 --format=%H -- HANDOFF.md)"
run_subj --retake-bulk "$K1"
if [ "$SUBJ_RC" -ne 0 ]; then
  fail б1 режима "--retake-bulk не дал успеха (rc=$SUBJ_RC): $SUBJ_OUT"
fi
has "базлайн переснят: bulk-дельта $VP (автор reviewer, коммит $SHA_VP)" \
  || fail б1 стенограммы "нет строки пути $VP: $SUBJ_OUT"
has "базлайн переснят: bulk-дельта $CP (автор architect, коммит $SHA_CP)" \
  || fail б1 стенограммы "нет строки пути $CP: $SUBJ_OUT"
has "базлайн переснят: bulk-дельта $SP (автор implementer, коммит $SHA_SP)" \
  || fail б1 стенограммы "нет строки пути $SP: $SUBJ_OUT"
has "базлайн переснят: bulk-дельта HANDOFF.md (автор orchestrator, коммит $SHA_HP)" \
  || fail б1 стенограммы "нет строки пути HANDOFF.md: $SUBJ_OUT"
has 'базлайн переснят: bulk-дельта — путей 4, незакоммиченного/неслитого 0' \
  || fail б1 итога "нет итоговой строки четырёх путей: $SUBJ_OUT"
run_subj --check "$K1"
if [ "$SUBJ_RC" -ne 0 ] || ! has "$P_CHISTO"; then
  fail б1 пост-чека "после переснятия --check обязан быть чист (rc=$SUBJ_RC): $SUBJ_OUT"
fi
ok б1 "межзонная bulk-дельта переснята, стенограмма 4 путей, чекаут чист"

# ── общий каркас отказывающих входов: имя отказа + снимок не тронут + дельта видна ─
# ozhid_otkaz <имя-ворот> <фраза-отказа>
ozhid_otkaz() {  # <ворота> <фраза>
  local imja="$1" fraza="$2"
  local snap do_bytes posle
  snap="$(snap_of "$KURI")"
  do_bytes="$(sha256sum < "$snap" 2>/dev/null)"
  run_subj --retake-bulk "$KURI"
  if [ "$SUBJ_RC" -ne 1 ] || ! has "$fraza"; then
    printf 'ОТКАЗ %s: --retake-bulk не дал именованного отказа (rc=%s, ожидан rc 1 + «%s»): %s\n' \
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
    printf 'ОТКАЗ %s: после отказа --retake-bulk дельта спрятана (--check не красен, rc=%s) — прячущее переснятие\n' "$imja" "$SUBJ_RC" >&2
    exit 1
  fi
  ok "$imja" "отказ именован, снимок не тронут, дельта видна"
}

# ── б2: один путь не закоммичен (porcelain грязный) — отказ ВСЕЙ группой ─────────
KURI="$WORK/b2_${RANDOM}"
mk_bulk_root "$KURI"
mk_origin "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail б2 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
commit_kak "$KURI" reviewer  "verdicts/review/contracts-001-b2.md" 'accept'
commit_kak "$KURI" architect "contracts/003-b2-${RANDOM}.md" 'дополнение'
gtoy "$KURI" push -q origin main
printf '\nнезакоммиченная правка\n' >> "$KURI/HANDOFF.md"
gtoy "$KURI" add -A
ozhid_otkaz б2 'переснятие-bulk не доказано: porcelain не чист — дельта обязана быть закоммичена'

# ── б3: один путь закоммичен, но НЕ запушен (только локально) ────────────────────
KURI="$WORK/b3_${RANDOM}"
mk_bulk_root "$KURI"
mk_origin "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail б3 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
commit_kak "$KURI" reviewer "verdicts/review/contracts-001-b3.md" 'accept'
gtoy "$KURI" push -q origin main
SP3="scripts/fix-b3-${RANDOM}.sh"
commit_kak "$KURI" implementer "$SP3" 'локальный коммит без пуша'
SHA3="$(gtoy "$KURI" log -1 --format=%H -- "$SP3")"
ozhid_otkaz б3 "переснятие-bulk не доказано: коммит $SHA3 пути $SP3 не достижим на origin/main"

# ── б4: неслитый tip БЕЗ путей дельты (пустой коммит поверх пуша) ────────────────
KURI="$WORK/b4_${RANDOM}"
mk_bulk_root "$KURI"
mk_origin "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail б4 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
commit_kak "$KURI" reviewer "verdicts/review/contracts-001-b4.md" 'accept'
gtoy "$KURI" push -q origin main
gtoy "$KURI" -c user.name=Фикстура -c user.email=fixture@local commit -q --allow-empty -m 'неслитый tip без путей дельты'
ozhid_otkaz б4 'переснятие-bulk не доказано: история разошлась с origin/main (left-right ≠ 0 0)'

# ── б5: путь не покрыт НИ ОДНОЙ зоной ────────────────────────────────────────────
KURI="$WORK/b5_${RANDOM}"
mk_bulk_root "$KURI"
mk_origin "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail б5 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
commit_kak "$KURI" reviewer "verdicts/review/contracts-001-b5.md" 'accept'
NP="docs/nobody-b5-${RANDOM}.md"
commit_kak "$KURI" architect "$NP" 'незонированный путь'
gtoy "$KURI" push -q origin main
ozhid_otkaz б5 "переснятие-bulk не доказано: путь $NP не покрыт ни одной зоной"

# ── б6: путь зоны architect, коммит авторства reviewer (чужой автор) ─────────────
KURI="$WORK/b6_${RANDOM}"
mk_bulk_root "$KURI"
mk_origin "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail б6 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
commit_kak "$KURI" reviewer "verdicts/review/contracts-001-b6.md" 'accept'
CP6="contracts/004-chuzhoj-b6-${RANDOM}.md"
commit_kak "$KURI" reviewer "$CP6" 'чужая рука в чужой зоне'
gtoy "$KURI" push -q origin main
ozhid_otkaz б6 "переснятие-bulk не доказано: автор reviewer пути $CP6 не владелец зоны"

# ── б7: незакоммиченные байты под assume-unchanged (porcelain лжёт) ──────────────
KURI="$WORK/b7_${RANDOM}"
mk_bulk_root "$KURI"
mk_origin "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail б7 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
commit_kak "$KURI" reviewer  "verdicts/review/contracts-001-b7.md" 'accept — честный вердикт'
commit_kak "$KURI" architect "contracts/005-b7-${RANDOM}.md" 'дополнение'
gtoy "$KURI" push -q origin main
printf 'ПОДМЕНА: незакоммиченные байты\n' > "$KURI/verdicts/review/contracts-001-b7.md"
gtoy "$KURI" update-index --assume-unchanged "verdicts/review/contracts-001-b7.md"
# контроль воспроизведения: porcelain ЛЖЁТ «чисто» — иначе вход не вход Б3
gtoy "$KURI" status --porcelain | grep -q . && fail б7 контроля "porcelain видит правку — вход не воспроизводит Б3"
ozhid_otkaz б7 'переснятие-bulk не доказано: байты дельта-пути не закоммичены (porcelain лжёт: assume-unchanged/skip-worktree)'
gtoy "$KURI" update-index --no-assume-unchanged "verdicts/review/contracts-001-b7.md" 2>/dev/null || true

# ── б8: ослеплённый реестр (refs/tags закрыт на чтение) ──────────────────────────
KURI="$WORK/b8_${RANDOM}"
mk_bulk_root "$KURI"
mk_origin "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail б8 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
commit_kak "$KURI" reviewer  "verdicts/review/contracts-001-b8.md" 'accept'
commit_kak "$KURI" architect "contracts/006-b8-${RANDOM}.md" 'дополнение'
gtoy "$KURI" push -q origin main
chmod 000 "$KURI/.git/refs/tags"
ozhid_otkaz б8 'переснятие-bulk не доказано: реестр зон пуст — читатель ослеплён'
chmod 755 "$KURI/.git/refs/tags"

# ── б9: отказ читателя зон rc≠0 (тег запушен на origin, удалён локально) ─────────
KURI="$WORK/b9_${RANDOM}"
mk_bulk_root "$KURI"
mk_origin "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail б9 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
commit_kak "$KURI" reviewer  "verdicts/review/contracts-001-b9.md" 'accept'
commit_kak "$KURI" architect "contracts/007-b9-${RANDOM}.md" 'дополнение'
gtoy "$KURI" push -q origin main
gtoy "$KURI" tag -d frozen/contracts/001/1 >/dev/null
ozhid_otkaz б9 'реестр зон недоступен'

# ── б10: дельта пуста — пустая выборка красная ───────────────────────────────────
KURI="$WORK/b10_${RANDOM}"
mk_bulk_root "$KURI"
mk_origin "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail б10 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
run_subj --retake-bulk "$KURI"
if [ "$SUBJ_RC" -ne 1 ] || ! has 'переснятие-bulk не доказано: дельта пуста — нечего переснимать'; then
  fail б10 режима "--retake-bulk на пустой дельте обязан отказать именем (rc=$SUBJ_RC): $SUBJ_OUT"
fi
run_subj --check "$KURI"
if [ "$SUBJ_RC" -ne 0 ]; then
  fail б10 пост-чека "после отказа на пустой дельте --check обязан остаться чист (rc=$SUBJ_RC): $SUBJ_OUT"
fi
ok б10 "пустая дельта красна именем, не зелёна молча"

printf 'ok: дверь bulk-переснятия 044 — все ворота пройдены (б0..б10)\n'
exit 0
