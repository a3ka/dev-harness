#!/usr/bin/env bash
# КРАСНОЕ 068 (б) — scripts/mint_line.sh: строка реестра «<NNN> → <tag-object-sha>»
# маршрутом оркестраторского bash-скрипта (боль: 4 ручных минта подряд 064-067 и
# 068-071; spawn_agent/land_agent-класс операции исполнен руками).
#
# ДОГОВОР (контракт 068 §Инварианты (б)): скрипт проверяет dual-control
# провенанс ЖИВОГО тега id/CONTRACT/<NNN> (локально ∧ на origin ∧ sha совпадают),
# отказывает на повторном минте/грязном дереве/не-main, дописывает строку и
# коммитит её на main identity orchestrator; ДВЕРЬ 031 (check_staged ADD-форма)
# остаётся судьёй; тег НЕ минтится (next_id), пуш НЕ делается (gitw).
#
# ПРИВЯЗКА К КОДУ (Н-39; входы — номера из НЕПЕРЕСЕКАЮЩИХСЯ поддиапазонов
# 940-984, вне занятых 023 (120-939) и 031 (020-119)):
#   м0 зелёная (п1-класс 037: отсутствующий субъект — предъявляемое КРАСНОЕ
#     ДО): полный авторитетный минт тега (аннотирован + запушен на origin),
#     строки нет → rc 0, stdout MINTED, в манифесте HEAD ровно одна строка
#     «N → sha» с sha тега, последний коммит author=committer=orchestrator,
#     рабочее дерево чисто. Обманные стабы (ниже) умирают на м1б/м2/м3;
#   м1 self-mint: тег создан локально, НЕ запушен → rc 1, stderr несёт
#     «не достижим на origin (self-mint)», дерево чисто, HEAD не двинулся;
#   м1б fail-closed сети: origin перенаправлен на несуществующий путь → rc 1,
#     «авторитет недоступен (ls-remote origin не ответил», дерево чисто, HEAD
#     не двинулся. Стаб «сетевой отказ = продолжить» (стМ1) умирает здесь:
#     пропустив rc-проверку, называет причину «не достижим на origin» — имя
#     отказа лжёт (сети нет, а не тега);
#   м2 повторный минт: тег + строка уже закоммичены и запушены → rc 1,
#     «ОТКАЗ: номер … уже в манифесте», дерево чисто, HEAD не двинулся. Стаб
#     «не проверяет существующую строку» (стМ3) умирает здесь (пишет дубль —
#     отказ приходит именем ДВЕРИ, не скрипта);
#   м3 переминт: тег на origin (sha X), локально перетегирован (sha Y) → rc 1,
#     «переминт», дерево чисто, HEAD не двинулся. Стаб «sha origin не
#     сверяется» (стМ2) умирает здесь: пишет строку с Y, коммит упирается в
#     дверь «sha тега на origin ≠ sha строки» — имя отказа не «переминт»;
#   м4 дверь судит (контроль): строка с НЕВЕРНЫМ sha, stage'нута руками,
#     коммит orchestrator'ом через живой pre-commit-хук → коммит ОТКАЗАН
#     именем «дверь минта 031», HEAD не двинулся — скрипт не может обойти
#     дверь, и сама дверь жива (не плацебо-зелёная).
#   м5 неотвратимость двери для скрипта: строка N5 в ЖИВОЙ шапке origin/main,
#     локальный HEAD позади (гонка) → коммит САМОГО скрипта отказан дверью:
#     rc 1, stderr «дверь минта 031», HEAD не двинулся, дерево чисто. На этом
#     же классе входа умирает клетка стМ4 — копия субъекта с инъекцией
#     «-c core.hooksPath=/dev/null» в командную строку коммита (дословный
#     обход критика к1 Б2): её коммит идёт МИМО двери (rc 0, MINTED, HEAD
#     двинулся) — «коммит прошёл мимо двери»;
#   м6 конфиг-дизарм: core.hooksPath toy ведёт в каталог без живого
#     pre-commit → именованный отказ ДО записи: rc 1, «дверь 031 отключена
#     конфигом», строки нет в worktree, HEAD не двинулся;
#
# Стабы — мутантные КОПИИ субъекта (одна sed-ручка на копию; применение
# проверяется ДВУМЯ мерами: cmp с субъектом ∧ литеральный grep -F маркер).
# Нейтрализация условия = ЗАМЕНА НА ВСЕГДА-ЛОЖНОЕ (всегда-истинное превращает
# стаб в параноика, неотличимого от честного — поймано живым прогоном пачки).
# Каталог хука — ВНЕ toy-дерева (untracked hooks/ делал дерево «грязным» и
# гасил предмет м0-м3 отказом «грязное дерево» — тоже живой прогон пачки).
#
# Коды возврата: 0 — все ветви зелёные; 1 — есть красная (в т.ч. субъект
# отсутствует — предъявляемое красное ДО, прецедент п1 батареи 037);
# 2 — нечем проверять (нет git / python3).
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"
SUBJ="$ROOT/scripts/mint_line.sh"

command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет python3 (канарейка check_staged)\n' >&2; exit 2; }

WORK="$(mktemp -d "${TMPDIR:-/tmp}/red068b.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

# env-изоляция identity (068, разблокировка заморозки): переменные окружения
# GIT_AUTHOR_*/GIT_COMMITTER_* БЬЮТ и toy-конфиг, и -c — наследованная из
# freeze-окружения orchestrator-identity переписывала identity toy-коммитов.
# Снимаем наследие: identity каждого коммита — ЯВНЫЙ -c (роль по замыслу).
unset GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_AUTHOR_DATE \
      GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL GIT_COMMITTER_DATE

# Субъект-барьер двери: копия scripts/ (check_staged + lib_zones/next_id/check_charter
# соседство sourcing'а — BARRIER_ROOT-паттерн семьи check_staged).
BARRIER="$WORK/subj-scripts"
cp -r "$ROOT/scripts" "$BARRIER"

# Случайные входы (А-88): м0 940-949 · м1 950-954 · м1б 955-959 · м2 960-964 ·
# м3 965-969 · м4 970-974 · стаб-тоя 975-977 · м5 978-979 · м6 980-984.
mapfile -t RD < <(awk 'BEGIN{srand();
  printf "%03d\n", 940+int(rand()*10);
  printf "%03d\n", 950+int(rand()*5);
  printf "%03d\n", 955+int(rand()*5);
  printf "%03d\n", 960+int(rand()*5);
  printf "%03d\n", 965+int(rand()*5);
  printf "%03d\n", 970+int(rand()*5);
  for(i=0;i<4;i++) printf "%d\n", 10000000+int(rand()*89999999);
  printf "%03d\n", 978+int(rand()*2);
  printf "%03d\n", 980+int(rand()*5)}')
N0="${RD[0]}"; N1="${RD[1]}"; N1B="${RD[2]}"; N2="${RD[3]}"; N3="${RD[4]}"; N4="${RD[5]}"; N5="${RD[10]}"; N6="${RD[11]}"

g() {
  local r="$1"; shift
  # Явная identity на каждом вызове (env-изоляция 068): -c, не наследие окружения.
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" -c commit.gpgsign=false -c core.hooksPath=/dev/null \
     -c user.name=orchestrator -c user.email=orchestrator@local "$@"
}

# mk_toy <каталог>: toy с замороженным контрактом 001, зоной orchestrator
# (HANDOFF.md — иначе «не судится» гасит дверь ДО её ветви, урок ЗЗ 018),
# засеянным манифестом «000 → <hex>», bare-origin с запушенным main и
# ЖИВЫМ pre-commit-хуком (каталог ВНЕ toy) → дверь 031 судит коммиты toy.
mk_toy() {
  local t="$1" orig hookdir
  mkdir -p "$t/contracts" "$t/registry" "$t/scripts"
  {
    printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\n'
    printf 'ЗОНА orchestrator: HANDOFF.md\n'
  } > "$t/contracts/001-x.md"
  printf '# передача\n' > "$t/HANDOFF.md"
  printf 'seed\n' > "$t/scripts/a.sh"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$t"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$t" config commit.gpgsign false
  g "$t" add -A
  g "$t" commit -q -m 'основание: контракт и зона orchestrator'
  printf '000 → %s\n' "$(git -C "$t" rev-parse HEAD)" > "$t/registry/contracts.tsv"
  g "$t" add -A
  g "$t" commit -q -m 'основание: манифест реестра'
  g "$t" tag -a frozen/contracts/001/1 -m 'контракт утверждён'
  orig="${t%/}-origin.git"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q --bare "$orig"
  git -C "$orig" symbolic-ref HEAD refs/heads/main
  g "$t" remote add origin "$orig"
  g "$t" push -q origin main
  # Живая дверь: pre-commit → check_staged копии-барьера на этот toy.
  # Каталог хука — вне стерегомого toy-дерева (untracked hooks/ внутри toy
  # делал status --porcelain непустым и валил м0-м3 на «грязное дерево»).
  hookdir="$WORK/hookdir-$(basename "$t")"
  mkdir -p "$hookdir"
  printf '#!/bin/sh\nexec bash "%s/check_staged.sh" "%s"\n' "$BARRIER" "$t" > "$hookdir/pre-commit"
  chmod +x "$hookdir/pre-commit"
  git -C "$t" config core.hooksPath "$hookdir"
}

# authority_tag <toy> <NNN>: авторитетная половина — аннотированный тег + пуш
# на origin (строку манифеста НЕ пишет).
authority_tag() {
  g "$1" tag -a "id/CONTRACT/$2" -m 'выдача механизмом (фикстура: авторитетная половина)'
  g "$1" push -q origin "refs/tags/id/CONTRACT/$2"
}

# authority_line <toy> <NNN>: авторитет ЗАКОММИТИЛ строку манифеста + пуш main
# (сквозь живую дверь — полный честный минт).
authority_line() {
  local sha
  sha="$(git -C "$1" rev-parse "refs/tags/id/CONTRACT/$2")"
  printf '%s → %s\n' "$2" "$sha" >> "$1/registry/contracts.tsv"
  g "$1" add -A
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$1" -c commit.gpgsign=false \
      -c user.name=orchestrator -c user.email=orchestrator@local \
      commit -q -m "реестр: резерв $2 (авторитетная строка)"
  g "$1" push -q origin main
}

RED=0; GRN=0; NORUN=0
declare -a REPS=()
fail() { RED=$((RED+1)); REPS+=("$1: КРАСНАЯ — $2"); }
pass() { GRN=$((GRN+1)); REPS+=("$1: ЗЕЛЁНАЯ"); }

# ── м0: честный минт → rc 0, MINTED, строка в HEAD, identity orchestrator ────
if [ -x "$SUBJ" ]; then
  T0="$WORK/k0-${RD[6]}"; mk_toy "$T0"; authority_tag "$T0" "$N0"
  sha0="$(git -C "$T0" rev-parse "refs/tags/id/CONTRACT/$N0")"
  head0="$(git -C "$T0" rev-parse HEAD)"
  out0="$("$SUBJ" --root "$T0" --nnn "$N0" 2>"$WORK/e0")"; rc0=$?
  err0="$(cat "$WORK/e0")"
  lines0="$(git -C "$T0" cat-file -p HEAD:registry/contracts.tsv | grep -cF "$N0 → ")"
  sha_line0="$(git -C "$T0" cat-file -p HEAD:registry/contracts.tsv | grep -F "$N0 → " | awk '{print $3}')"
  an0="$(git -C "$T0" log -1 --format=%an)"
  cn0="$(git -C "$T0" log -1 --format=%cn)"
  cnt0="$(git -C "$T0" rev-list --count "$head0..HEAD")"
  dirty0="$(git -C "$T0" status --porcelain)"
  if [ "$rc0" -eq 0 ] && printf '%s' "$out0" | grep -qF "MINTED nnn=$N0 sha=$sha0" \
     && [ "$lines0" -eq 1 ] && [ "$sha_line0" = "$sha0" ] \
     && [ "$an0" = orchestrator ] && [ "$cn0" = orchestrator ] \
     && [ "$cnt0" -eq 1 ] && [ -z "$dirty0" ]; then
    pass м0
  else
    fail м0 "rc=$rc0 out=$out0 err=$err0 lines=$lines0 an=$an0 cn=$cn0 cnt=$cnt0 dirty=${dirty0:-чисто}"
  fi
else
  fail м0 "отсутствует: $SUBJ (NOT_IMPLEMENTED — строка реестра минтуется руками, предъявляемое красное ДО)"
fi

if [ -x "$SUBJ" ]; then
  # ── м1: self-mint (тег только локально) → именованный отказ, дерево чисто ──
  T1="$WORK/k1-${RD[6]}"; mk_toy "$T1"
  g "$T1" tag -a "id/CONTRACT/$N1" -m 'self-mint агента (фикстура)'
  head1="$(git -C "$T1" rev-parse HEAD)"
  out1="$("$SUBJ" --root "$T1" --nnn "$N1" 2>"$WORK/e1")"; rc1=$?
  err1="$(cat "$WORK/e1")"
  dirty1="$(git -C "$T1" status --porcelain)"
  cnt1="$(git -C "$T1" rev-list --count "$head1..HEAD")"
  if [ "$rc1" -eq 1 ] && printf '%s' "$err1" | grep -qF 'не достижим на origin (self-mint)' \
     && [ -z "$dirty1" ] && [ "$cnt1" -eq 0 ]; then pass м1
  else fail м1 "rc=$rc1 err=$err1 dirty=${dirty1:-чисто} cnt=$cnt1"; fi

  # ── м1б: origin недоступен → fail-closed «авторитет недоступен» ────────────
  T1B="$WORK/k1b-${RD[7]}"; mk_toy "$T1B"; authority_tag "$T1B" "$N1B"
  g "$T1B" remote set-url origin "$WORK/netstat-netu.git"
  head1b="$(git -C "$T1B" rev-parse HEAD)"
  out1b="$("$SUBJ" --root "$T1B" --nnn "$N1B" 2>"$WORK/e1b")"; rc1b=$?
  err1b="$(cat "$WORK/e1b")"
  dirty1b="$(git -C "$T1B" status --porcelain)"
  cnt1b="$(git -C "$T1B" rev-list --count "$head1b..HEAD")"
  if [ "$rc1b" -eq 1 ] && printf '%s' "$err1b" | grep -qF 'авторитет недоступен (ls-remote origin не ответил' \
     && [ -z "$dirty1b" ] && [ "$cnt1b" -eq 0 ]; then pass м1б
  else fail м1б "rc=$rc1b err=$err1b dirty=${dirty1b:-чисто} cnt=$cnt1b"; fi

  # ── м2: повторный минт (строка уже в HEAD) → отказ скрипта, не двери ───────
  T2="$WORK/k2-${RD[7]}"; mk_toy "$T2"; authority_tag "$T2" "$N2"; authority_line "$T2" "$N2"
  head2="$(git -C "$T2" rev-parse HEAD)"
  out2="$("$SUBJ" --root "$T2" --nnn "$N2" 2>"$WORK/e2")"; rc2=$?
  err2="$(cat "$WORK/e2")"
  dirty2="$(git -C "$T2" status --porcelain)"
  cnt2="$(git -C "$T2" rev-list --count "$head2..HEAD")"
  if [ "$rc2" -eq 1 ] && printf '%s' "$err2" | grep -qF 'ОТКАЗ: номер' \
     && printf '%s' "$err2" | grep -qF 'уже в манифесте' \
     && [ -z "$dirty2" ] && [ "$cnt2" -eq 0 ]; then pass м2
  else fail м2 "rc=$rc2 err=$err2 dirty=${dirty2:-чисто} cnt=$cnt2"; fi

  # ── м3: переминт (локальный sha ≠ origin sha) → «переминт» ──────────────────
  T3="$WORK/k3-${RD[8]}"; mk_toy "$T3"; authority_tag "$T3" "$N3"
  g "$T3" tag -d "id/CONTRACT/$N3" >/dev/null
  g "$T3" tag -a "id/CONTRACT/$N3" -m 'переминт (фикстура: дрейф локального тега)'
  head3="$(git -C "$T3" rev-parse HEAD)"
  out3="$("$SUBJ" --root "$T3" --nnn "$N3" 2>"$WORK/e3")"; rc3=$?
  err3="$(cat "$WORK/e3")"
  dirty3="$(git -C "$T3" status --porcelain)"
  cnt3="$(git -C "$T3" rev-list --count "$head3..HEAD")"
  if [ "$rc3" -eq 1 ] && printf '%s' "$err3" | grep -qF 'переминт' \
     && [ -z "$dirty3" ] && [ "$cnt3" -eq 0 ]; then pass м3
  else fail м3 "rc=$rc3 err=$err3 dirty=${dirty3:-чисто} cnt=$cnt3"; fi

  # ── м4: дверь судит — неверный sha stage'нут руками, коммит через хук ──────
  T4="$WORK/k4-${RD[8]}"; mk_toy "$T4"; authority_tag "$T4" "$N4"
  wrong="$(git -C "$T4" rev-parse HEAD)"
  printf '%s → %s\n' "$N4" "$wrong" >> "$T4/registry/contracts.tsv"
  g "$T4" add -- registry/contracts.tsv
  head4="$(git -C "$T4" rev-parse HEAD)"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$T4" -c commit.gpgsign=false \
      -c user.name=orchestrator -c user.email=orchestrator@local \
      commit -q -m "реестр: строка $N4 (неверный sha)" 2>"$WORK/e4"
  rc4=$?
  err4="$(cat "$WORK/e4")"
  cnt4="$(git -C "$T4" rev-list --count "$head4..HEAD")"
  if [ "$rc4" -ne 0 ] && printf '%s' "$err4" | grep -qF 'дверь минта 031' && [ "$cnt4" -eq 0 ]; then
    pass м4
  else fail м4 "rc=$rc4 err=$err4 cnt=$cnt4"; fi
  g "$T4" reset -q HEAD -- registry/contracts.tsv 2>/dev/null
  g "$T4" checkout -- registry/contracts.tsv 2>/dev/null
  # ── м5: неотвратимость двери для САМОГО скрипта — гонка: строка N5 уже в
  # живой шапке origin/main, локальный HEAD позади. Дверь обязана отказать
  # коммиту СКРИПТА («повторный минт» по живой шапке) — rc 1 именем двери и
  # точечный откат (Б2 круга 1: м4 доказывал живость двери, не обязательность).
  T5="$WORK/k5-${RD[9]}"; mk_toy "$T5"; authority_tag "$T5" "$N5"; authority_line "$T5" "$N5"
  g "$T5" reset -q --hard HEAD~1
  head5="$(git -C "$T5" rev-parse HEAD)"
  out5="$("$SUBJ" --root "$T5" --nnn "$N5" 2>"$WORK/e5")"; rc5=$?
  err5="$(cat "$WORK/e5")"
  dirty5="$(git -C "$T5" status --porcelain)"
  cnt5="$(git -C "$T5" rev-list --count "$head5..HEAD")"
  if [ "$rc5" -eq 1 ] && printf '%s' "$err5" | grep -qF 'дверь минта 031' \
     && [ -z "$dirty5" ] && [ "$cnt5" -eq 0 ]; then pass м5
  else fail м5 "rc=$rc5 err=$err5 dirty=${dirty5:-чисто} cnt=$cnt5"; fi

  # ── м6: конфиг-дизарм — core.hooksPath ведёт мимо живого pre-commit →
  # именованный отказ ДО записи строки (дерево не мутируется вовсе).
  T6="$WORK/k6-${RD[10]}"; mk_toy "$T6"; authority_tag "$T6" "$N6"
  mkdir -p "$WORK/nohooks6"
  g "$T6" config core.hooksPath "$WORK/nohooks6"
  head6="$(git -C "$T6" rev-parse HEAD)"
  out6="$("$SUBJ" --root "$T6" --nnn "$N6" 2>"$WORK/e6")"; rc6=$?
  err6="$(cat "$WORK/e6")"
  line6="$(grep -cF "$N6 → " "$T6/registry/contracts.tsv" 2>/dev/null || true)"
  cnt6="$(git -C "$T6" rev-list --count "$head6..HEAD")"
  if [ "$rc6" -eq 1 ] && printf '%s' "$err6" | grep -qF 'дверь 031 отключена конфигом' \
     && [ "${line6:-0}" -eq 0 ] && [ "$cnt6" -eq 0 ]; then pass м6
  else fail м6 "rc=$rc6 err=$err6 line=${line6:-0} cnt=$cnt6"; fi


  # ── стабы: мутантные копии субъекта; нейтрализация = ВСЕГДА-ЛОЖНОЕ условие ─
  mk_stub() { # <копия> <sed-выражение> <литеральный маркер>
    cp "$SUBJ" "$1"
    sed -i "$2" "$1"
    chmod +x "$1"
    cmp -s "$SUBJ" "$1" && return 1
    grep -qF -- "$3" "$1" || return 1
    return 0
  }
  # стМ1 «сетевой отказ = продолжить»: rc-проверка ls-remote всегда-ложна.
  if mk_stub "$WORK/ml-stM1.sh" 's|\[ "$ls_rc" -ne 0 \]|[ 0 -ne 0 ]|' '[ 0 -ne 0 ]'; then
    TS1="$WORK/s1-${RD[8]}"; mk_toy "$TS1"; authority_tag "$TS1" 975
    g "$TS1" remote set-url origin "$WORK/netstat-netu.git"
    outs1="$("$WORK/ml-stM1.sh" --root "$TS1" --nnn 975 2>"$WORK/es1")"; rcs1=$?
    errs1="$(cat "$WORK/es1")"
    if [ "$rcs1" -eq 1 ] && printf '%s' "$errs1" | grep -qF 'авторитет недоступен (ls-remote origin не ответил'; then
      RED=$((RED+1)); REPS+=("стМ1: ПРОШЁЛ как честный (нейтрализация не различима) — дефект батареи")
    else GRN=$((GRN+1)); REPS+=("стМ1: мёртв (имя отказа лжёт — не «авторитет недоступен»: ${errs1:-пусто})"); fi
  else NORUN=$((NORUN+1)); REPS+=("стМ1: не построен (sed-ручка не применилась)"); fi
  # стМ2 «sha origin не сверяется»: переминт проходит до двери и дверь отказывает.
  if mk_stub "$WORK/ml-stM2.sh" 's|\[ "$TAG_SHA" != "$sha_origin" \]|[ "$TAG_SHA" != "$TAG_SHA" ]|' '"$TAG_SHA" != "$TAG_SHA"'; then
    TS2="$WORK/s2-${RD[9]}"; mk_toy "$TS2"; authority_tag "$TS2" 976
    g "$TS2" tag -d "id/CONTRACT/976" >/dev/null
    g "$TS2" tag -a "id/CONTRACT/976" -m 'переминт (стаб М2)'
    outs2="$("$WORK/ml-stM2.sh" --root "$TS2" --nnn 976 2>"$WORK/es2")"; rcs2=$?
    errs2="$(cat "$WORK/es2")"
    if [ "$rcs2" -eq 1 ] && printf '%s' "$errs2" | grep -qF 'переминт'; then
      RED=$((RED+1)); REPS+=("стМ2: ПРОШЁЛ как честный — дефект батареи")
    else GRN=$((GRN+1)); REPS+=("стМ2: мёртв (отказ пришёл без имени «переминт»: ${errs2:-пусто})"); fi
  else NORUN=$((NORUN+1)); REPS+=("стМ2: не построен (sed-ручка не применилась)"); fi
  # стМ3 «существующая строка не проверяется»: дубль пишет и упирается в дверь.
  if mk_stub "$WORK/ml-stM3.sh" 's|grep -qF "$NNN → "|grep -qF "999 → "|' 'grep -qF "999 → "'; then
    TS3="$WORK/s3-${RD[9]}"; mk_toy "$TS3"; authority_tag "$TS3" 977; authority_line "$TS3" 977
    outs3="$("$WORK/ml-stM3.sh" --root "$TS3" --nnn 977 2>"$WORK/es3")"; rcs3=$?
    errs3="$(cat "$WORK/es3")"
    if [ "$rcs3" -eq 1 ] && printf '%s' "$errs3" | grep -qF 'ОТКАЗ: номер'; then
      RED=$((RED+1)); REPS+=("стМ3: ПРОШЁЛ как честный — дефект батареи")
    else GRN=$((GRN+1)); REPS+=("стМ3: мёртв (отказ пришёл именем двери, не скрипта: ${errs3:-пусто})"); fi
  else NORUN=$((NORUN+1)); REPS+=("стМ3: не построен (sed-ручка не применилась)"); fi
  # стМ4 «hooksPath-инъекция в командную строку коммита» (клетка Б2 круга 1 —
  # дословный обход критика: добавленный -c core.hooksPath=/dev/null отключает
  # дверь ТОЛЬКО на коммите скрипта). Вход — гонка м5-класса: дверь обязана
  # отказать; мутант, чей коммит прошёл мимо двери, наблюдаем (rc 0/MINTED).
  if mk_stub "$WORK/ml-stM4.sh" 's|git -C "$ROOT" commit|git -C "$ROOT" -c core.hooksPath=/dev/null commit|' '-c core.hooksPath=/dev/null commit'; then
    TS4="$WORK/s4c-${RD[10]}"; mk_toy "$TS4"; authority_tag "$TS4" "$N5"; authority_line "$TS4" "$N5"
    g "$TS4" reset -q --hard HEAD~1
    head4c="$(git -C "$TS4" rev-parse HEAD)"
    out4c="$("$WORK/ml-stM4.sh" --root "$TS4" --nnn "$N5" 2>"$WORK/es4")"; rcs4=$?
    errs4="$(cat "$WORK/es4")"
    cnt4c="$(git -C "$TS4" rev-list --count "$head4c..HEAD")"
    if [ "$rcs4" -eq 1 ] && printf '%s' "$errs4" | grep -qF 'дверь минта 031' && [ "$cnt4c" -eq 0 ]; then
      RED=$((RED+1)); REPS+=("стМ4: ПРОШЁЛ как честный (инъекция не отключила дверь) — дефект батареи")
    else GRN=$((GRN+1)); REPS+=("стМ4: мёртв (коммит прошёл мимо двери: rc=$rcs4 out=$out4c cnt=$cnt4c)"); fi
  else NORUN=$((NORUN+1)); REPS+=("стМ4: не построен (sed-ручка не применилась)"); fi
fi

for r in "${REPS[@]}"; do printf 'КРАСНОЕ 068b: %s\n' "$r" >&2; done
printf 'ИТОГ 068b (mint_line): ветвей 8, стабов 4, красных %d, зелёных %d, не прогнано %d\n' "$RED" "$GRN" "$NORUN"
[ "$RED" -eq 0 ] || exit 1
exit 0
