#!/usr/bin/env bash
# КРАСНОЕ контракта 024, ветвь A (детектор утечек), правка-круг 3 — параметризованный
# класс PATH-подмен внешних утилит детектора (вердикт адверсария contracts-024-v1.md,
# блокеры 1-3 «контрпримеры круга 3 — атака на сам фикс», 8911b68) + наблюдение
# оркестратора: голое `tail -n1` в verify-чеке фикса 3bd1880 не в пин-списке.
#
# Суть. Детектор scripts/check_no_leak.sh вызывает по коду (c02f01a, построчно ниже)
# 14 внешних утилит: git, sha256sum, sort, comm, mkdir, mktemp, cat, grep, head,
# tail, stat, chmod, mv, rm. cut НЕ зовётся — hash8 считается bash-substring
# (check_no_leak.sh:197-200), builtin от PATH не зависит. Пин-резолв через
# TRUSTED_PATH на c02f01a применён ТОЛЬКО к sha256sum (фикс к2 04ba744); остальные
# 13 резолвятся полным PATH и достижимы поддельной утилитой в PATH перед /usr/bin.
#
# Н-39 (дословно: стабы к ветвям привязывает architect по КОДУ, не проза): каждая
# ветвь ниже привязана к месту вызова в коде c02f01a и к входу, где её дефект
# НАБЛЮДАЕМ (подмена даёт ложное «основной чекаут чист» при живой утечке на диске,
# честный прогон того же входа даёт именованный отказ/«загрязнён»):
#   git      :174,:192,:239 — producer манифеста; фейк rc0+пустой stdout ⇒ пустой
#             манифест в обоих фазах ⇒ дельта пуста (блокер 1 вердикта к3);
#   sort     :175,:282 — конвейер манифеста; фейк глотает stdin ⇒ манифест пуст;
#   comm     :176,:436 — вычислитель дельты; фейк rc0+пустой stdout на сверке ⇒
#             дельта пуста (блокер 2 вердикта к3);
#   head     :183,:320,:419 — парсер вывода sha256sum; умный фейк (пропускает
#             sanity-строку e3b0c442…, эхает подложный hex в остальных вызовах)
#             затыкает перерасчёт verify ⇒ «verify не сошёлся» не стреляет;
#   tail     :410 — селектор verify-строки; фейк-эхо «verify <верный-sha>» на
#             прод-снимке БЕЗ verify проходит чек вовсе без строки в файле.
#             НАБЛЮДЕНИЕ ОРКЕСТРАТОРА (3bd1880:489, фикс к3): tail остался ГОЛЫМ
#             именем вне пин-списка фикса — ветвь ОСТАЁТСЯ КРАСНОЙ и на фикс-коде
#             (дыра фикса, доклад архитектора; закрывается пином tail);
#   cat      :379 — чтение снимка в базу сверки; фейк-эхо подогнанной базы
#             (root верен, манифест под текущую грязь, verify валиден) ⇒ сверка
#             идёт против выдуманного содержимого, дельта пуста;
#   grep     :410 — извлечение verify-строки; фейк-эхо «verify <верный-sha>»
#             подменяет НЕсходящийся хранимый verify на сходящийся;
#   stat     :394 — mode-замер снимка; фейк-эхо «444» проводит записываемый
#             (подменённый, mode 644) снимок мимо mode-lock;
#   no-verify (дисковая ветвь, блокер 3 вердикта к3, БЕЗ утилитных фейков):
#             подмена прод-снимка — root верен, манифест подогнан под текущую
#             грязь, mode 444, verify-строки НЕТ ⇒ слабая база (verify
#             «опционален») молча пропускает; фикс к3 обязан отказаться именованно.
# ОХРАННЫЕ ветви — подмена НЕ наблюдаема как «чисто» и на слабой базе (Н-39:
# требовать красноты на входе, где дефект не наблюдаем, — ложь в диагнозе, урок
# круга 005); ветвь охраняет от регрессии в обе стороны (после пин-фикса —
# честное поведение, до — именованный fail-closed):
#   sha256sum :179(пин к2),:199,:268,:320,:419 — PATH-фейк НЕ достигает детектора,
#             утеча названа честно (k2-регрессия);
#   mktemp    :177,:234,:303 — фейк-эхо /dev/null выбрасывает spool, но хвостовая
#             `rm -f /dev/null` падает ⇒ именованный «status отказал» rc 1
#             (fail-closed, измерено прогоном); фейк с рабочим путём функционален
#             ⇒ вердикт честен — «чистой» формы подмены нет;
#   mkdir     :178,:297 — пустышка ⇒ mktemp в каталоге снимка отказывает ⇒ rc 2
#             fail-closed;
#   chmod     :326 — пустышка ⇒ снимок без 0444 ⇒ на сверке именованный «режим
#             не read-only»;
#   mv        :328 — пустышка ⇒ снимок не приземлён ⇒ «снимок отсутствует» rc 1;
#   rm        :243,:257,:269,:280,:327,:329 — чистка не влияет на вердикт.
#
# Формула verify-подгонки (ветви cat/grep/stat/tail): детектор режет базу как
# `${base%verify *}` — payload УДЕРЖИВАЕТ перевод строки перед verify; sha
# валидного verify считается по payload С хвостовым \n, ветвь tail (verify в
# файле нет) — по payload БЕЗ хвостового \n ($(cat) срезает). Измерено прогоном
# (arch024_dbg.sh): формула без \n даёт ложное «verify не сошёлся» на СВОИХ же
# крафтах — фикстура обязана подгонять sha ровно мерой детектора.
#
# Форма инварианта единая: при подмене/атаке и живой утечке на диске детектор НЕ
# имеет права печатать «основной чекаут чист» с rc 0. Честный контроль (снимок
# чистого toy → утечка → честная сверка → rc 1 «загрязнён») — первым шагом:
# без него красное ветвей не различает «сломан детектор» и «сломан вход».
# Положительный контроль ветви tail на фикс-коде 3bd1880 исполнен архитектором
# (улика /tmp/dev-harness-verify/arch024_probe2.sh): честный tail → rc 1 именован
# «verify-строка отсутствует», fake tail → rc 0 «основной чекаут чист».
#
# Аргумент (необязательный): абсолютный путь к ДЕТЕКТОРУ — для предъявления
# красного на чужой базе (например, фикс-ветке wip/024/implementer); по умолчанию
# — детектор своего репозитория фикстуры.
#
# Имена мусора и toy-корни случайны КАЖДЫЙ прогон (демаркация 024, класс ebc57db);
# TMPDIR редиректится в скратч прогона — снимки умирают trap'ом.
#
# Коды возврата: 0 — все ветви держат инвариант; 1 — именованный отказ (перечень
#               ветвей, давших ложное «чисто», — каждая поимённо).
set -uo pipefail
export LC_ALL=C

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
WORK="$(mktemp -d /tmp/red024-path.XXXXXX)"   # А-78: свежий WORK вне дерева
trap 'rm -rf "$WORK"' EXIT
export TMPDIR="$WORK/snaps"                   # снимки субъекта — в скратч прогона
mkdir -p "$TMPDIR"

SUBJ="${1:-$REPO/scripts/check_no_leak.sh}"
case "$SUBJ" in /*) ;; *) printf 'ОТКАЗ: путь детектора обязан быть абсолютным: %s\n' "$SUBJ" >&2; exit 1 ;; esac
[ -f "$SUBJ" ] || { printf 'ОТКАЗ: детектор отсутствует — %s\n' "$SUBJ" >&2; exit 1; }
printf 'субъект: %s\n' "$SUBJ" >&2

# ЕДИНЫЙ источник фраз (Демаркация 024) — побайтово.
P_ZAGR='основной чекаут загрязнён'
P_CHISTO='основной чекаут чист'

VIOL=()
held()   { printf '  ok   ветвь %s (%s; rc=%s)\n' "$1" "$2" "$SUBJ_RC" >&2; }
viol()   { VIOL+=("$1"); printf 'НАРУШЕНИЕ ветвь %s: ложное «%s» при живой утечке (%s); rc=%s; вывод: %s\n' \
             "$1" "$P_CHISTO" "$2" "$SUBJ_RC" "$SUBJ_OUT" >&2; }
# Инвариант ветви: НЕ «чисто»-с-rc0. Сверка структурна — фраза целой строкой.
assert_not_clean() {  # <ветвь> <роль>
  if [ "$SUBJ_RC" -eq 0 ] && printf '%s\n' "$SUBJ_OUT" | grep -qFx -- "$P_CHISTO"; then
    viol "$1" "$2"
  else
    held "$1" "$2"
  fi
}
run_honest() {  # <cwd> <аргументы...> — честный PATH
  local cwd="$1"; shift
  SUBJ_OUT="$( cd "$cwd" && bash "$SUBJ" "$@" 2>&1 )" && SUBJ_RC=0 || SUBJ_RC=$?
}
run_fake() {  # <fake-bin> <cwd> <аргументы...> — fake-bin ПЕРЕД системным PATH
  local bin="$1" cwd="$2"; shift 2
  SUBJ_OUT="$( cd "$cwd" && PATH="$bin:$PATH" bash "$SUBJ" "$@" 2>&1 )" && SUBJ_RC=0 || SUBJ_RC=$?
}

GTOY_ENV=(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null)

# Живой git-чекаут «основного дерева» toy (гигиена — как red_detektor_utechek.sh).
mk_main() {  # <каталог>
  mkdir -p "$1/.githooks" "$1/scripts"
  printf '# toy hook\n'   > "$1/.githooks/pre-push"
  printf '# toy spawn\n'  > "$1/scripts/spawn_agent.sh"
  env "${GTOY_ENV[@]}" git init -q -b main "$1"
  env "${GTOY_ENV[@]}" \
    git -C "$1" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
  env "${GTOY_ENV[@]}" \
    git -C "$1" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      commit -q -m 'toy main'
}

# Утечка живьём: новый untracked файл со случайным именем и содержимым.
add_leak() {  # <toy> — печатает имя утечки
  local n="leak_${RANDOM}${RANDOM}.txt"
  printf 'sekret-%s-%s\n' "$RANDOM" "$RANDOM" > "$1/$n"
  printf '%s' "$n"
}
leak_sha() { sha256sum -- "$1/$2" | sed 's/ .*//'; }

# Payload подгона: root верен, манифест = ровно текущая утечка (без хвостового \n —
# command substitution срезает; установщики дописывают \n сами).
craft_payload() {  # <toy> <утечка> — печатает payload-строку
  local canon fsha
  canon="$(cd "$1" && pwd -P)"
  fsha="$(leak_sha "$1" "$2")"
  printf 'root %s\n??:%s\t%s\n' "$canon" "$fsha" "$2"
}

# Установка подгона на место снимка (дисковая атака).
install_snap() {  # <toy> <содержимое-файл-источник> <mode>
  local toy="$1" src="$2" mode="$3" canon h8 snap
  canon="$(cd "$toy" && pwd -P)"
  h8="$(printf '%s' "$canon" | sha256sum | sed 's/ .*//' | cut -c1-8)"
  snap="${TMPDIR:-/tmp}/dev-harness-leak/$h8/porcelain"
  mkdir -p "$(dirname "$snap")"
  chmod "$mode" "$src"
  mv -f "$src" "$snap"
}

mk_fakebin() { mkdir -p "$WORK/fake-$1"; printf '%s' "$WORK/fake-$1"; }
ZERO64="0000000000000000000000000000000000000000000000000000000000000000"

# ── честный контроль: без подмен детектор обязан назвать утечку ────────────────
M0="$WORK/v0_chestnyj_${RANDOM}"
mk_main "$M0"
run_honest "$M0" --snapshot "$M0"
[ "$SUBJ_RC" -eq 0 ] || { printf 'ОТКАЗ: честный снимок не работает (rc=%s): %s\n' "$SUBJ_RC" "$SUBJ_OUT" >&2; exit 1; }
L0="$(add_leak "$M0")"
run_honest "$M0" --check "$M0"
if [ "$SUBJ_RC" -ne 1 ] || ! printf '%s\n' "$SUBJ_OUT" | grep -qF -- "$P_ZAGR" \
   || ! printf '%s\n' "$SUBJ_OUT" | grep -qF -- "$L0"; then
  printf 'ОТКАЗ: честный контроль — утечка %s не поймана (rc=%s): %s\n' "$L0" "$SUBJ_RC" "$SUBJ_OUT" >&2
  exit 1
fi
printf '  ok   честный контроль: утечка %s названа именованно\n' "$L0" >&2

# ── ветвь git: фейк rc0+пустой stdout ⇒ пустой манифест в ОБОИХ фазах ─────────
Mg="$WORK/git_${RANDOM}"
mk_main "$Mg"
Bg="$(mk_fakebin git)"
printf '#!/bin/sh\nexit 0\n' > "$Bg/git"; chmod +x "$Bg/git"
run_fake "$Bg" "$Mg" --snapshot "$Mg"
[ "$SUBJ_RC" -eq 0 ] || { printf 'ОТКАЗ: git-ветвь — снимок при фейке отказал rc=%s: %s\n' "$SUBJ_RC" "$SUBJ_OUT" >&2; exit 1; }
Lg="$(add_leak "$Mg")"
run_fake "$Bg" "$Mg" --check "$Mg"
assert_not_clean git "фейк git: пустой rc0-porcelain, блокер 1 к3 (:239)"

# ── ветвь sort: фейк глотает stdin ⇒ манифест пуст в обоих фазах ──────────────
Ms="$WORK/sort_${RANDOM}"
mk_main "$Ms"
Bs="$(mk_fakebin sort)"
printf '#!/bin/sh\ncat >/dev/null 2>&1\nexit 0\n' > "$Bs/sort"; chmod +x "$Bs/sort"
run_fake "$Bs" "$Ms" --snapshot "$Ms"
[ "$SUBJ_RC" -eq 0 ] || { printf 'ОТКАЗ: sort-ветвь — снимок при фейке отказал rc=%s: %s\n' "$SUBJ_RC" "$SUBJ_OUT" >&2; exit 1; }
Ls="$(add_leak "$Ms")"
run_fake "$Bs" "$Ms" --check "$Ms"
assert_not_clean sort "фейк sort: конвейер манифеста проглочен (:282)"

# ── ветвь comm: фейк rc0+пустой stdout на СВЕРКЕ ⇒ дельта пуста ───────────────
Mc="$WORK/comm_${RANDOM}"
mk_main "$Mc"
run_honest "$Mc" --snapshot "$Mc"
[ "$SUBJ_RC" -eq 0 ] || { printf 'ОТКАЗ: comm-ветвь — честный снимок отказал: %s\n' "$SUBJ_OUT" >&2; exit 1; }
Lc="$(add_leak "$Mc")"
Bc="$(mk_fakebin comm)"
printf '#!/bin/sh\ncat >/dev/null 2>&1\nexit 0\n' > "$Bc/comm"; chmod +x "$Bc/comm"
run_fake "$Bc" "$Mc" --check "$Mc"
assert_not_clean comm "фейк comm: пустая дельта, блокер 2 к3 (:436)"

# ── ветвь head: умный фейк затыкает перерасчёт verify (:419) ──────────────────
Mh="$WORK/head_${RANDOM}"
mk_main "$Mh"
run_honest "$Mh" --snapshot "$Mh"
[ "$SUBJ_RC" -eq 0 ] || { printf 'ОТКАЗ: head-ветвь — честный снимок отказал: %s\n' "$SUBJ_OUT" >&2; exit 1; }
Lh="$(add_leak "$Mh")"
Ph="$(craft_payload "$Mh" "$Lh")"
printf '%s\nverify %s\n' "$Ph" "$ZERO64" > "$WORK/c-head"   # хранимый verify НЕ сходится
install_snap "$Mh" "$WORK/c-head" 444
Bh="$(mk_fakebin head)"
printf '#!/bin/sh\nin="$(cat 2>/dev/null)"\ncase "$in" in e3b0c442*) printf "%%s\\n" "$in" ;; *) printf "%s  -\\n" "%s" ;; esac\n' "$ZERO64" > "$Bh/head"
chmod +x "$Bh/head"
run_fake "$Bh" "$Mh" --check "$Mh"
assert_not_clean head "фейк head: подложный hex в перерасчёте verify (:419)"

# ── ветвь tail: эхо «verify <верный-sha>» на снимке БЕЗ verify (дыра 3bd1880:489)
Mt="$WORK/tail_${RANDOM}"
mk_main "$Mt"
run_honest "$Mt" --snapshot "$Mt"
[ "$SUBJ_RC" -eq 0 ] || { printf 'ОТКАЗ: tail-ветвь — честный снимок отказал: %s\n' "$SUBJ_OUT" >&2; exit 1; }
Lt="$(add_leak "$Mt")"
Pt="$(craft_payload "$Mt" "$Lt")"
printf '%s\n' "$Pt" > "$WORK/c-tail"                        # манифест подогнан, verify НЕТ
install_snap "$Mt" "$WORK/c-tail" 444
Psha="$(printf '%s' "$Pt" | sha256sum | sed 's/ .*//')"     # sha payload БЕЗ хвостового \n
Bt="$(mk_fakebin tail)"
printf '#!/bin/sh\nprintf "verify %%s\\n" "%s"\n' "$Psha" > "$Bt/tail"
chmod +x "$Bt/tail"
run_fake "$Bt" "$Mt" --check "$Mt"
assert_not_clean tail "фейк tail: verify-строка выдумана эхом (:410; на фикс-коде 3bd1880 — ДЫРА, :489 вне пина)"

# ── ветвь cat: фейк-эхо подогнанной базы сверки (:379), диск честен ────────────
Ma="$WORK/cat_${RANDOM}"
mk_main "$Ma"
run_honest "$Ma" --snapshot "$Ma"
[ "$SUBJ_RC" -eq 0 ] || { printf 'ОТКАЗ: cat-ветвь — честный снимок отказал: %s\n' "$SUBJ_OUT" >&2; exit 1; }
La="$(add_leak "$Ma")"
Pa="$(craft_payload "$Ma" "$La")"
Vsha="$(printf '%s\n' "$Pa" | sha256sum | sed 's/ .*//')"   # sha payload С хвостовым \n
Ba="$(mk_fakebin cat)"
{ printf '#!/bin/sh\n'; printf 'printf "%%s\\nverify %%s\\n" "%s" "%s"\n' "$Pa" "$Vsha"; } > "$Ba/cat"
chmod +x "$Ba/cat"
run_fake "$Ba" "$Ma" --check "$Ma"
assert_not_clean cat "фейк cat: база сверки выдумана эхом (:379)"

# ── ветвь grep: эхо «verify <верный-sha>» вместо несходящегося (:410) ─────────
Mgr="$WORK/grep_${RANDOM}"
mk_main "$Mgr"
run_honest "$Mgr" --snapshot "$Mgr"
[ "$SUBJ_RC" -eq 0 ] || { printf 'ОТКАЗ: grep-ветвь — честный снимок отказал: %s\n' "$SUBJ_OUT" >&2; exit 1; }
Lgr="$(add_leak "$Mgr")"
Pgr="$(craft_payload "$Mgr" "$Lgr")"
printf '%s\nverify %s\n' "$Pgr" "$ZERO64" > "$WORK/c-grep"  # хранимый verify НЕ сходится
install_snap "$Mgr" "$WORK/c-grep" 444
Vgr="$(printf '%s\n' "$Pgr" | sha256sum | sed 's/ .*//')"
Bgr="$(mk_fakebin grep)"
printf '#!/bin/sh\nprintf "verify %%s\\n" "%s"\n' "$Vgr" > "$Bgr/grep"
chmod +x "$Bgr/grep"
run_fake "$Bgr" "$Mgr" --check "$Mgr"
assert_not_clean grep "фейк grep: несходящийся verify подменён эхом (:410)"

# ── ветвь stat: эхо «444» проводит записываемый снимок мимо mode-lock (:394) ──
Mst="$WORK/stat_${RANDOM}"
mk_main "$Mst"
run_honest "$Mst" --snapshot "$Mst"
[ "$SUBJ_RC" -eq 0 ] || { printf 'ОТКАЗ: stat-ветвь — честный снимок отказал: %s\n' "$SUBJ_OUT" >&2; exit 1; }
Lst="$(add_leak "$Mst")"
Pst="$(craft_payload "$Mst" "$Lst")"
Vst="$(printf '%s\n' "$Pst" | sha256sum | sed 's/ .*//')"
printf '%s\nverify %s\n' "$Pst" "$Vst" > "$WORK/c-stat"     # verify ВАЛИДЕН, mode 644
install_snap "$Mst" "$WORK/c-stat" 644
Bst="$(mk_fakebin stat)"
printf '#!/bin/sh\necho 444\n' > "$Bst/stat"; chmod +x "$Bst/stat"
run_fake "$Bst" "$Mst" --check "$Mst"
assert_not_clean stat "фейк stat: mode-lock обойдён эхом (:394)"

# ── ветвь no-verify: дисковая подмена снимка БЕЗ verify, без фейков (блокер 3) ─
Mv="$WORK/noverify_${RANDOM}"
mk_main "$Mv"
run_honest "$Mv" --snapshot "$Mv"
[ "$SUBJ_RC" -eq 0 ] || { printf 'ОТКАЗ: no-verify-ветвь — честный снимок отказал: %s\n' "$SUBJ_OUT" >&2; exit 1; }
Lv="$(add_leak "$Mv")"
Pv="$(craft_payload "$Mv" "$Lv")"
printf '%s\n' "$Pv" > "$WORK/c-nv"                          # root верен, манифест подогнан, verify НЕТ
install_snap "$Mv" "$WORK/c-nv" 444
run_honest "$Mv" --check "$Mv"
assert_not_clean no-verify "прод-снимок без verify обязан отказывать именованно (блокер 3 к3)"

# ── охранная sha256sum: пин к2 (04ba744) — PATH-фейк НЕ достигает детектора ───
Mss="$WORK/sha_${RANDOM}"
mk_main "$Mss"
run_honest "$Mss" --snapshot "$Mss"
[ "$SUBJ_RC" -eq 0 ] || { printf 'ОТКАЗ: sha-ветвь — честный снимок отказал: %s\n' "$SUBJ_OUT" >&2; exit 1; }
Lss="$(add_leak "$Mss")"
Bss="$(mk_fakebin sha256sum)"
printf '#!/bin/sh\necho "%s  -"\n' "$ZERO64" > "$Bss/sha256sum"
chmod +x "$Bss/sha256sum"
run_fake "$Bss" "$Mss" --check "$Mss"
assert_not_clean sha256sum "охрана пина к2: константный hex на PATH обязан не достигать детектора"

# ── охранная mktemp: эхо /dev/null ⇒ именованный fail-closed, НЕ «чисто» (:234) ─
Mk="$WORK/mktemp_${RANDOM}"
mk_main "$Mk"
run_honest "$Mk" --snapshot "$Mk"
[ "$SUBJ_RC" -eq 0 ] || { printf 'ОТКАЗ: mktemp-ветвь — честный снимок отказал: %s\n' "$SUBJ_OUT" >&2; exit 1; }
Lk="$(add_leak "$Mk")"
Bk="$(mk_fakebin mktemp)"
printf '#!/bin/sh\necho /dev/null\n' > "$Bk/mktemp"; chmod +x "$Bk/mktemp"
run_fake "$Bk" "$Mk" --check "$Mk"
assert_not_clean mktemp "охрана: spool=/dev/null обязан кончаться именованным отказом (rm /dev/null), не «чисто»"

# ── охранная mkdir: пустышка ⇒ fail-closed, НЕ «чисто» (:297) ─────────────────
Md="$WORK/mkdir_${RANDOM}"
mk_main "$Md"
Bd="$(mk_fakebin mkdir)"
printf '#!/bin/sh\nexit 0\n' > "$Bd/mkdir"; chmod +x "$Bd/mkdir"
run_fake "$Bd" "$Md" --snapshot "$Md"
assert_not_clean mkdir "пустышка mkdir обязана ронять снимок fail-closed"

# ── охранная chmod: пустышка ⇒ снимок без 0444 ⇒ именованный отказ (:326) ─────
Mch="$WORK/chmod_${RANDOM}"
mk_main "$Mch"
Bch="$(mk_fakebin chmod)"
printf '#!/bin/sh\nexit 0\n' > "$Bch/chmod"; chmod +x "$Bch/chmod"
run_fake "$Bch" "$Mch" --snapshot "$Mch"
[ "$SUBJ_RC" -eq 0 ] || { printf 'ОТКАЗ: chmod-ветвь — снимок при фейке отказал rc=%s: %s\n' "$SUBJ_RC" "$SUBJ_OUT" >&2; exit 1; }
Lch="$(add_leak "$Mch")"
run_fake "$Bch" "$Mch" --check "$Mch"
assert_not_clean chmod "пустышка chmod: mode-lock обязан стрелять на сверке"

# ── охранная mv: пустышка ⇒ «снимок отсутствует» (:328) ───────────────────────
Mmv="$WORK/mv_${RANDOM}"
mk_main "$Mmv"
Bmv="$(mk_fakebin mv)"
printf '#!/bin/sh\nexit 0\n' > "$Bmv/mv"; chmod +x "$Bmv/mv"
run_fake "$Bmv" "$Mmv" --snapshot "$Mmv"
[ "$SUBJ_RC" -eq 0 ] || { printf 'ОТКАЗ: mv-ветвь — снимок при фейке отказал rc=%s: %s\n' "$SUBJ_RC" "$SUBJ_OUT" >&2; exit 1; }
Lmv="$(add_leak "$Mmv")"
run_fake "$Bmv" "$Mmv" --check "$Mmv"
assert_not_clean mv "пустышка mv: неприземлённый снимок обязан отказывать"

# ── охранная rm: пустышка не влияет на вердикт — утеча названа ────────────────
Mr="$WORK/rm_${RANDOM}"
mk_main "$Mr"
Brm="$(mk_fakebin rm)"
printf '#!/bin/sh\nexit 0\n' > "$Brm/rm"; chmod +x "$Brm/rm"
run_fake "$Brm" "$Mr" --snapshot "$Mr"
[ "$SUBJ_RC" -eq 0 ] || { printf 'ОТКАЗ: rm-ветвь — снимок при фейке отказал rc=%s: %s\n' "$SUBJ_RC" "$SUBJ_OUT" >&2; exit 1; }
Lr="$(add_leak "$Mr")"
run_fake "$Brm" "$Mr" --check "$Mr"
assert_not_clean rm "пустышка rm не имеет права менять вердикт"

# ── итог ──────────────────────────────────────────────────────────────────────
if [ "${#VIOL[@]}" -gt 0 ]; then
  printf 'red_path_fake_utilit_024: КРАСНО — %s ветв(ей) дают ложное «%s» на субъекте %s:\n' \
    "${#VIOL[@]}" "$P_CHISTO" "$SUBJ" >&2
  for v in "${VIOL[@]}"; do printf '  - %s\n' "$v" >&2; done
  exit 1
fi
printf 'red_path_fake_utilit_024: все ветви держат инвариант (путь подменён — «чисто» не выдано)\n' >&2
exit 0
