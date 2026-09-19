#!/usr/bin/env bash
# ПРЕД-ЗАМОРОЗОЧНОЕ КРАСНОЕ контракта 031, механизм-2 — дверь переснятия базлайна
# детектора утечек (Н-112): режим `scripts/check_no_leak.sh --retake <абс-корень>`.
#
# Договор двери (контракт 031 §Инварианты-2 — единый источник; фразы побайтово).
# Переснятие базлайна ПРОИСХОДИТ ⟺ ШЕСТЬ условий ВМЕСТЕ (порядок: снимок-целостность →
# porcelain чист → дельта непуста → ровно один путь → путь вердиктный (зона судьи из
# zones_load, начинается с verdicts/) → автор последнего коммита пути — владелец зоны).
# Отказ — rc 1 ИМЕНОВАННОЙ причиной, СНИМОК НЕ ТРОНУТ: последующий --check обязан
# остаться красным («переснятие, прячущее НЕ-вердиктную дельту, краснеет» — слово
# владельца 2026-09-19). Успех — rc 0 + стенограмма «базлайн переснят: вердиктная
# дельта <путь> (автор <автор>, коммит <sha>)», последующий --check rc 0 «чист».
#
# Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (прецедент red_detektor_utechek.sh 024;
# И-11 контракта 024): до реализации предмет предъявляется ПРЯМЫМ запуском; приёмка —
# ДВА прогона подряд с РАЗНЫМИ случайными входами. Фикстура ДВУХФАЗНАЯ: сегодня красна
# (режима --retake нет — диспетчер отказывает), после реализации все ворота зелёные;
# CI-покрытие ветвей несут case_peresnjatie_*.sh исполнителя (ЗОНА implementer 031).
#
# Форма — по прецеденту red_info_refs_drift_024.sh: собственный WORK вне дерева,
# TMPDIR редиректится в скратч прогона (снимки субъекта — не в дереве и не в /tmp
# соседних прогонов), имена файлов/каталогов случайны КАЖДЫЙ прогон.
#
# ВХОДЫ (Н-39 — привязка к ветвям по коду двери):
#   р0 положительный контроль: snapshot → check на чистом дереве → rc 0 «основной
#      чекаут чист» — ЗЕЛЁНОЕ и ДО, и ПОСЛЕ (режим --retake не ломает 024);
#   р1 боль Н-112 (определяющая дельта): вердиктная правка — ОДИН файл
#      verdicts/review/contracts-001-k1.md, автор reviewer (владелец зоны из
#      замороженного toy-контракта), закоммичен после снимка, porcelain чист →
#      --check rc 1 «основной чекаут загрязнён» (детектор ПРАВ по Демаркации 024 —
#      состояние изменилось) → --retake: ПОСЛЕ rc 0 + стенограмма (путь/автор/sha) +
#      --check rc 0. СЕГОДНЯ --retake отказан диспетчером (режима нет) — КРАСНОЕ;
#   р2 дельта из ДВУХ путей (вердикт + закоммиченный мусор scripts/*), porcelain
#      чист → ПОСЛЕ rc 1 «переснятие не доказано: дельта не ровно-один-файл» +
#      снимок не тронут (--check остаётся rc 1). Стаб «переснять любое непустое»
#      умирает здесь: он спрятал бы НЕ-вердиктную дельту;
#   р3 единственный путь ВНЕ verdicts/ (scripts/инженерное), porcelain чист → ПОСЛЕ
#      rc 1 «переснятие не доказано: путь не вердиктный (зона судьи не объявлена)» +
#      снимок не тронут. Убивает слабую форму «путь судится префиксом verdicts/, не
#      реестром зон»;
#   р4 вердиктный путь, автор — НЕ судья зоны (orchestrator закоммитил файл в
#      verdicts/review/) → ПОСЛЕ rc 1 «переснятие не доказано: автор дельты не судья
#      зоны» + снимок не тронут. Убивает слабую форму «автор не сверяется»;
#   р5 porcelain ГРЯЗНЫЙ (staged-правка без коммита поверх закоммиченной вердиктной
#      дельты) → ПОСЛЕ rc 1 «переснятие не доказано: porcelain не чист — дельта
#      обязана быть закоммичена» + снимок не тронут (порядок условий: porcelain
#      проверяется РАНЬШЕ разбора дельты). Убивает слабую форму «судить незакоммиченное
#      состояние по зонам»;
#   р6 дельта ПУСТА (снимок соответствует дереву) → ПОСЛЕ rc 1 «переснятие не
#      доказано: дельта пуста — нечего переснимать» (пустая выборка красная, не
#      зелёная). Убивает слабую форму «--retake = --snapshot»;
#   р7 verdicts/ПОДКАТАЛОГ без ЗОНА-строки (verdicts/konsul/x.md, зона объявлена
#      только на verdicts/review/) → ПОСЛЕ rc 1 «…путь не вердиктный (зона судьи не
#      объявлена)» + снимок не тронут. Пинует: источник — реестр зон, не префикс;
#   р8 НЕЗАКОММИЧЕННЫЕ байты под assume-unchanged (Б3 круга 1, воспроизведение
#      критика): вердикт закоммичен reviewer, снимок снят, затем байты файла
#      изменены БЕЗ коммита и путь помечен `git update-index --assume-unchanged` —
#      porcelain ПУСТ, дельта однопутная вердиктная, автор последнего коммита
#      reviewer: ШЕСТЬ прежних условий сходились, седьмое (побайтовое равенство
#      HEAD) обязано отказать → ПОСЛЕ rc 1 «переснятие не доказано: байты
#      дельта-пути не закоммичены (porcelain лжёт: assume-unchanged/skip-worktree)»
#      + снимок не тронут. Продолжение корневой меры 024 (статус-флаги не
#      ослепляют), не запрет конкретного флага;
#   р9 ОСЛЕПЛЁННЫЙ ЧИТАТЕЛЬ зон (Б4 круга 1): .git/refs/tags закрыт на чтение
#      ПОСЛЕ снимка и вердикта (измерено пробой круга 2: zones_load rc 0 с ПУСТЫМ
#      zones_scoped — молчаливый fail-open; механика манифеста жива: rev-parse
#      HEAD / ls-files / status читают refs/heads) → ПОСЛЕ rc 1 «переснятие не
#      доказано: реестр зон не несёт ни одной судейской зоны — читатель ослеплён»
#      + снимок не тронут. Стаб «запасной префикс/кэш при отказе читателя» умирает
#      здесь: ослеплённый реестр не доказывает зону.
#
# На каждом отказывающем входе (р2–р5, р7) фикстура сверяет ОБА факта: именованный
# отказ И НЕИЗМЕННОСТЬ снимка (байты до == байты после; --check остаётся rc 1 с теми
# же именами) — «прячущее переснятие» наблюдаемо краснеет.
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
P_PERESNJAL='базлайн переснят: вердиктная дельта'

WORK="$(mktemp -d /tmp/red031-retake.XXXXXX)"   # А-78: свежий WORK вне дерева
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

# mk_sud_root <каталог>: toy-репо с замороженным контрактом 001, зонирующим судью:
# ЗОНА reviewer: verdicts/review/ (+ ЗОНА orchestrator: HANDOFF.md — оркестратор
# зонирован, чтобы отказ р4 был именем АВТОРА, а не «не судится»). Зоны читает
# zones_load по тегу frozen/contracts/001/1 — единый читатель ЗОНА-строк.
mk_sud_root() {  # <каталог>
  local r="$1"
  mkdir -p "$r/contracts" "$r/verdicts/review" "$r/scripts"
  {
    printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\n'
    printf 'ЗОНА reviewer: verdicts/review/\n'
    printf 'ЗОНА orchestrator: HANDOFF.md\n'
  } > "$r/contracts/001-x.md"
  printf 'база\n' > "$r/scripts/a.sh"
  printf '# передача\n' > "$r/HANDOFF.md"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  gtoy "$r" -c user.name=Фикстура -c user.email=fixture@local add -A
  gtoy "$r" -c user.name=Фикстура -c user.email=fixture@local commit -q -m 'основание'
  gtoy "$r" -c user.name=Фикстура -c user.email=fixture@local tag -a frozen/contracts/001/1 -m 'утверждён'
}

# commit_kak <каталог> <автор> <путь> <содержимое>: закоммитить файл от имени автора
# (модель main-direct вердикта судьи / инженерного коммита).
commit_kak() {  # <каталог> <автор> <путь> <содержимое>
  local r="$1" avtor="$2" p="$3"
  mkdir -p "$r/$(dirname "$p")"
  printf '%s\n' "$4" > "$r/$p"
  gtoy "$r" -c user.name="$avtor" -c user.email="$avtor@local" add -A
  gtoy "$r" -c user.name="$avtor" -c user.email="$avtor@local" commit -q -m "посадка $p ($avtor)"
}

# снимок субъекта живёт ВНЕ дерева; путь вычислим от канонического корня — фиксируем
# байты снимка до/после --retake (снятие НЕ тронуло базлайн).
snap_of() {  # <канон-корень> → путь файла-снимка
  local h8
  h8="$(printf '%s' "$1" | sha256sum)"
  h8="${h8%% *}"; h8="${h8:0:8}"
  printf '%s/dev-harness-leak/%s/porcelain' "$WORK/snaps" "$h8"
}

# ── р0: положительный контроль (снимок/сверка 024 не ломаются) ──────────────────
K0="$WORK/v0_${RANDOM}"
mk_sud_root "$K0"
run_subj --snapshot "$K0"
[ "$SUBJ_RC" -eq 0 ] || fail р0 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
run_subj --check "$K0"
if [ "$SUBJ_RC" -ne 0 ] || ! has "$P_CHISTO"; then
  fail р0 проверки "check на чистом дереве не зелёный (rc=$SUBJ_RC): $SUBJ_OUT"
fi
ok р0 "снимок/сверка 024 живы"

# ── р1: боль Н-112 — вердиктная дельта; --retake сегодня отсутствует ────────────
K1="$WORK/v1_${RANDOM}"
mk_sud_root "$K1"
run_subj --snapshot "$K1"
[ "$SUBJ_RC" -eq 0 ] || fail р1 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
VP="verdicts/review/contracts-001-k1.md"
commit_kak "$K1" reviewer "$VP" 'accept — вердикт ревьюера k1'
run_subj --check "$K1"
if [ "$SUBJ_RC" -ne 1 ] || ! has "$P_ZAGR"; then
  fail р1 детектора "--check обязан краснеть на вердиктной дельте (rc=$SUBJ_RC): $SUBJ_OUT"
fi
run_subj --retake "$K1"
if [ "$SUBJ_RC" -ne 0 ] || ! has "$P_PERESNJAL" || ! has 'reviewer' || ! has "$VP"; then
  printf 'ОТКАЗ р1 (боль Н-112): режим --retake отсутствует либо не прошёл вердиктную дельту — один файл %s, автор reviewer (владелец зоны), porcelain чист; ожидан rc 0 + «%s … (автор reviewer, коммит …)», получено rc %s: %s\n' \
    "$VP" "$P_PERESNJAL" "$SUBJ_RC" "$SUBJ_OUT" >&2
  exit 1
fi
run_subj --check "$K1"
if [ "$SUBJ_RC" -ne 0 ] || ! has "$P_CHISTO"; then
  fail р1 пост-чека "после переснятия --check обязан быть чист (rc=$SUBJ_RC): $SUBJ_OUT"
fi
ok р1 "вердиктная дельта переснята именем, снимок съехал, чекаут чист"

# ── общий каркас отказывающих входов: имя отказа + снимок не тронут ─────────────
# ozhid_otkaz <имя-ворот> <фраза-отказа>
ozhid_otkaz() {  # <ворота> <фраза>
  local imja="$1" fraza="$2"
  local snap do_bytes posle
  snap="$(snap_of "$KURI")"
  do_bytes="$(sha256sum < "$snap" 2>/dev/null)"
  run_subj --retake "$KURI"
  if [ "$SUBJ_RC" -ne 1 ] || ! has "$fraza"; then
    printf 'ОТКАЗ %s: --retake не дал именованного отказа (rc=%s, ожидан rc 1 + «%s»): %s\n' \
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
    printf 'ОТКАЗ %s: после отказа --retake дельта спрятана (--check не красен, rc=%s) — прячущее переснятие\n' "$imja" "$SUBJ_RC" >&2
    exit 1
  fi
  ok "$imja" "отказ именован, снимок не тронут, дельта видна"
}

# ── р2: дельта из двух путей (вердикт + закоммиченный мусор) ────────────────────
KURI="$WORK/v2_${RANDOM}"
mk_sud_root "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail р2 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
commit_kak "$KURI" reviewer "verdicts/review/contracts-001-k2.md" 'accept'
commit_kak "$KURI" reviewer "scripts/musor-${RANDOM}.sh" 'утечка-кандидат'
ozhid_otkaz р2 'переснятие не доказано: дельта не ровно-один-файл'

# ── р3: единственный путь вне verdicts/ ─────────────────────────────────────────
KURI="$WORK/v3_${RANDOM}"
mk_sud_root "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail р3 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
commit_kak "$KURI" reviewer "scripts/inzhenernoe-${RANDOM}.md" 'инженерный файл'
ozhid_otkaz р3 'переснятие не доказано: путь не вердиктный (зона судьи не объявлена)'

# ── р4: вердиктный путь, автор — не судья зоны ──────────────────────────────────
KURI="$WORK/v4_${RANDOM}"
mk_sud_root "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail р4 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
commit_kak "$KURI" orchestrator "verdicts/review/contracts-001-orch.md" 'подделка канала'
ozhid_otkaz р4 'переснятие не доказано: автор дельты не судья зоны'

# ── р5: porcelain грязный (staged-правка без коммита поверх закоммиченной дельты) ─
KURI="$WORK/v5_${RANDOM}"
mk_sud_root "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail р5 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
commit_kak "$KURI" reviewer "verdicts/review/contracts-001-k3.md" 'accept'
printf '\nнезакоммиченная правка\n' >> "$KURI/HANDOFF.md"
gtoy "$KURI" add -A
ozhid_otkaz р5 'переснятие не доказано: porcelain не чист — дельта обязана быть закоммичена'

# ── р6: дельта пуста — пустая выборка красная ────────────────────────────────────
KURI="$WORK/v6_${RANDOM}"
mk_sud_root "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail р6 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
run_subj --retake "$KURI"
if [ "$SUBJ_RC" -ne 1 ] || ! has 'переснятие не доказано: дельта пуста — нечего переснимать'; then
  printf 'ОТКАЗ р6: --retake на пустой дельте обязан отказать именем (rc=%s, ожидан rc 1 + «переснятие не доказано: дельта пуста — нечего переснимать»): %s\n' \
    "$SUBJ_RC" "$SUBJ_OUT" >&2
  exit 1
fi
run_subj --check "$KURI"
if [ "$SUBJ_RC" -ne 0 ]; then
  fail р6 пост-чека "после отказа на пустой дельте --check обязан остаться чист (rc=$SUBJ_RC): $SUBJ_OUT"
fi
ok р6 "пустая дельта красна именем, не зелёна молча"

# ── р7: verdicts/подкаталог без ЗОНА-строки ─────────────────────────────────────
KURI="$WORK/v7_${RANDOM}"
mk_sud_root "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail р7 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
commit_kak "$KURI" reviewer "verdicts/konsul/svidetelstvo-${RANDOM}.md" 'свидетельство вне зоны'
ozhid_otkaz р7 'переснятие не доказано: путь не вердиктный (зона судьи не объявлена)'

# ── р8: незакоммиченные байты под assume-unchanged (Б3) ─────────────────────────
KURI="$WORK/v8_${RANDOM}"
mk_sud_root "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail р8 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
commit_kak "$KURI" reviewer "verdicts/review/contracts-001-k8.md" 'accept — честный вердикт'
printf 'ПОДМЕНА: незакоммиченные байты\n' > "$KURI/verdicts/review/contracts-001-k8.md"
gtoy "$KURI" update-index --assume-unchanged "verdicts/review/contracts-001-k8.md"
# контроль воспроизведения: porcelain ЛЖЁТ «чисто» — иначе вход не вход Б3
gtoy "$KURI" status --porcelain | grep -q . && fail р8 контроля "porcelain видит правку — вход не воспроизводит Б3"
ozhid_otkaz р8 'переснятие не доказано: байты дельта-пути не закоммичены'
gtoy "$KURI" update-index --no-assume-unchanged "verdicts/review/contracts-001-k8.md" 2>/dev/null || true

# ── р9: ослеплённый читатель зон (Б4) ───────────────────────────────────────────
KURI="$WORK/v9_${RANDOM}"
mk_sud_root "$KURI"
run_subj --snapshot "$KURI"
[ "$SUBJ_RC" -eq 0 ] || fail р9 снимка "snapshot отказал rc=$SUBJ_RC: $SUBJ_OUT"
commit_kak "$KURI" reviewer "verdicts/review/contracts-001-k9.md" 'accept — честный вердикт'
chmod 000 "$KURI/.git/refs/tags"
ozhid_otkaz р9 'переснятие не доказано: реестр зон не несёт ни одной судейской зоны'
chmod 755 "$KURI/.git/refs/tags"

printf 'ok: дверь переснятия 031 — все ворота пройдены (р0..р9)\n'
exit 0
