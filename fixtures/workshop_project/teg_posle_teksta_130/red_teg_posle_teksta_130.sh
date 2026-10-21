#!/usr/bin/env bash
# Батарея контракта 130 «тег после текста»: push тега заморозки через scripts/gitw уходит на цель
# только когда текст контракта под тегом (тот же blob по тому же пути) и вердикты критика
# v1..v (первая строка accept) уже в main ЦЕЛИ; иначе — именованный отказ, тег остаётся локальным.
#
#   red_teg_posle_teksta_130.sh                    продукт: scripts/ этого дерева
#   red_teg_posle_teksta_130.sh --candidate <клон> продукт: <клон>/scripts
#   red_teg_posle_teksta_130.sh --model            честная модель (podmena.py model) поверх scripts/ дерева
#   red_teg_posle_teksta_130.sh --stabs            каждый обманный стаб podmena.py: контроль модели в его
#                                                  клетке сходится, стаб расходится → ПОЙМАН
#   ... --cell <id>  одна клетка;  --seed <n>  номер контракта и версия мира от seed
#
# Мир клетки — mktemp: bare-цель + клон; цель канонична ручкой GIT_EXCHANGE_GUARD_CANONICAL
# (единственная ручка 045). Сеть и GitHub не нужны. Ожидания — в памяти раннера ДО вызова субъекта;
# состояние цели после вызова читается из bare-репо (не со слов субъекта).
#
# Коды: 0 — все клетки сошлись / все стабы пойманы; 1 — расхождение / непойманный стаб;
#       2 — нечем судить (нет git/python3/npm/jq/curl, подмена не легла, нет такой клетки).
# Скрипт не печатает PASS: итог — код возврата и строка ИТОГ.
set -uo pipefail
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null LC_ALL=C.UTF-8

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../../.." && pwd)"

CELLS=(c01-chestnyj c02-tolko-wip c03-staryj-blob c04-bez-verdikta c05-verdikt-fail
       c06-lokalnyj-main c07-tracking c08-tags c09-korotkoe-imya c10-done c11-id
       c12-net-main c13-main-ne-lokalno c14-origin-nedostupen c15-071-ne-oslablen
       c16-hold-lend-publikaciya c17-vmeste c18-follow-tags c19-plans c20-vne-grammatiki
       c21-push-option-o c22-push-option-dlinnaya c23-receive-pack c24-razdelitel
       c25-pereimenovanie c26-force c27-mirror c28-all c29-head-v-teg c30-c-followtags
       c31-publikaciya-do-lenda c32-tihij-q c33-tihij-dlinnaya c34-ne-porcelain
       c35-ne-dry-run c36-verbose c37-progress c38-tiho-legitimno c39-perestanovka
       c40-sokraschenie c41-batl-flagov)

mode=product; cand=""; only=""; seed="${RANDOM}"
while [ $# -gt 0 ]; do
  case "$1" in
    --candidate) cand="${2:?--candidate без клона}"; shift 2 ;;
    --model) mode=model; shift ;;
    --stabs) mode=stabs; shift ;;
    --cell) only="${2:?--cell без имени}"; shift 2 ;;
    --seed) seed="${2:?--seed без числа}"; shift 2 ;;
    *) printf 'NOT_IMPLEMENTED: аргумент не распознан: %s\n' "$1" >&2; exit 2 ;;
  esac
done
for t in git python3 npm jq curl; do
  command -v "$t" >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет %s в PATH\n' "$t" >&2; exit 2; }
done
if [ -n "$only" ]; then
  found=0; for c in "${CELLS[@]}"; do [ "$c" = "$only" ] && found=1; done
  [ "$found" -eq 1 ] || { printf 'NOT_IMPLEMENTED: нет такой клетки: %s\n' "$only" >&2; exit 2; }
  CELLS=( "$only" )
fi

RANDOM="$seed"
# RANDOM — только в текущем процессе: подстановка $(…) пересевает его в подоболочке.
printf -v NNN '%03d' $(( 100 + RANDOM % 800 ))
V=$(( 1 + RANDOM % 2 ))

WORK="$(mktemp -d "${TMPDIR:-/tmp}/teg130.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

g()  { git -C "$C" -c user.name=Фикстура -c user.email=fixture@local -c commit.gpgsign=false \
           -c core.hooksPath=/dev/null "$@"; }
gq() { g "$@" >/dev/null 2>&1; }

# ── строители мира ──────────────────────────────────────────────────────────
mir() {  # mir <клетка> [ветка-по-умолчанию]
  W="$WORK/$1.$RANDOM"; B="$W/b.git"; C="$W/c"
  mkdir -p "$W"
  git init -q --bare -b "${2:-main}" "$B"
  git clone -q "$B" "$C" 2>/dev/null
  gq checkout -q -b "${2:-main}"
  printf 'основание\n' > "$C/README.md"
  gq add -A; gq commit -q -m основание
  gq push -q origin "${2:-main}"
}
tekst()   { mkdir -p "$C/${2:-contracts}"; printf 'Контракт %s, редакция %s\n' "$NNN" "$1" > "$C/${2:-contracts}/$NNN-t.md"; }
verdikt() { mkdir -p "$C/verdicts/critic"; printf '%s\nкруг %s\n' "$2" "$1" > "$C/verdicts/critic/${3:-contracts}-$NNN-v$1.md"; }
verdikty() { local k=1; while [ "$k" -le "$V" ]; do verdikt "$k" accept "${1:-contracts}"; k=$((k + 1)); done; }
kommit()  { gq add -A; gq commit -q -m "$1"; }
teg()     { gq tag -a "$1" -m заморозка; }
TAG() { printf 'frozen/%s/%s/%s' "${1:-contracts}" "$NNN" "$V"; }

# ── субъект и наблюдение ────────────────────────────────────────────────────
SUBJ=""
subj() {  # subj <args push ...> — gitw субъекта из мира; rc → RC, stderr → ERR
  ( cd "$C" && env GIT_EXCHANGE_GUARD_CANONICAL="$B" bash "$SUBJ/gitw" push "$@" ) \
    >"$W/out" 2>"$W/err"
  RC=$?
}
subjg() {  # subjg <полный argv gitw> — с глобальными флагами перед подкомандой
  ( cd "$C" && env GIT_EXCHANGE_GUARD_CANONICAL="$B" bash "$SUBJ/gitw" "$@" ) \
    >"$W/out" 2>"$W/err"
  RC=$?
}
guard() {  # guard hold|publish <тег> — режим удержания гарда субъекта
  ( cd "$C" && env GIT_EXCHANGE_GUARD_CANONICAL="$B" bash "$SUBJ/gitw_teg_130.sh" "$@" ) \
    >"$W/out" 2>"$W/err"
  RC=$?
}
na_celi()   { git -C "$B" rev-parse -q --verify "refs/tags/$1" >/dev/null 2>&1; }
lokalno()   { g rev-parse -q --verify "refs/tags/$1" >/dev/null 2>&1; }
uderzhan()  { g rev-parse -q --verify "refs/frozen-hold/${1#frozen/}" >/dev/null 2>&1; }
stroka()    { awk -v p="$1" 'index($0,p)==1{f=1} END{exit f?0:1}' "$W/err"; }
otkaz130()  { awk -v p="gitw ТЕГ-ОТКАЗ: $1: $2" 'index($0,p)==1 && (length($0)==length(p) || substr($0,length(p)+1,2)==": "){f=1} END{exit f?0:1}' "$W/err"; }
# wip_teg — мир клетки формы argv: текст и вердикты только на wip, тег на wip; T ← имя тега.
wip_teg() { gq checkout -q -b wip/"$NNN"/architect; tekst 1; verdikty; kommit текст; T="$(TAG)"; teg "$T"; }
# ne_ushel <тег> — общий хвост клеток формы argv: отказ 130 «текст не в main цели», тег не на цели.
ne_ushel() {
  chk "rc=$RC, ожидался 1" rc_is 1
  chk "нет строки «gitw ТЕГ-ОТКАЗ: $1: текст не в main цели»" otkaz130 "$1" "текст не в main цели"
  chk "тег $1 ушёл на цель" not na_celi "$1"
}

WHY=""
need() { [ -n "$WHY" ] && return 0; "$@" || WHY="${WHY_NEXT}"; }
chk() { WHY_NEXT="$1"; shift; need "$@"; }
not() { ! "$@"; }
rc_is() { [ "$RC" -eq "$1" ]; }

# ── клетки: мир → ожидания (в памяти) → субъект → сверка ───────────────────
cell() {
  local c="$1" t
  WHY=""
  case "$c" in
    c01-chestnyj)
      mir "$c"; tekst 1; verdikty; kommit текст; gq push -q origin main; t="$(TAG)"; teg "$t"
      subj origin "refs/tags/$t"
      chk "rc=$RC, ожидался 0" rc_is 0
      chk "тег $t не на цели" na_celi "$t" ;;
    c02-tolko-wip)
      mir "$c"; gq checkout -q -b wip/"$NNN"/architect; tekst 1; verdikty; kommit текст; t="$(TAG)"; teg "$t"
      subj origin "refs/tags/$t"
      chk "rc=$RC, ожидался 1" rc_is 1
      chk "нет строки «gitw ТЕГ-ОТКАЗ: $t: текст не в main цели»" otkaz130 "$t" "текст не в main цели"
      chk "тег $t ушёл на цель" not na_celi "$t"
      chk "локальный тег $t пропал" lokalno "$t" ;;
    c03-staryj-blob)
      mir "$c"; tekst 1; verdikty; kommit "текст v1"; gq push -q origin main
      gq checkout -q -b wip/"$NNN"/architect; tekst 2; kommit "текст v2"; t="$(TAG)"; teg "$t"
      subj origin "refs/tags/$t"
      chk "rc=$RC, ожидался 1" rc_is 1
      chk "нет строки «gitw ТЕГ-ОТКАЗ: $t: текст не в main цели»" otkaz130 "$t" "текст не в main цели"
      chk "тег $t ушёл на цель" not na_celi "$t" ;;
    c04-bez-verdikta)
      mir "$c"; tekst 1; kommit текст; gq push -q origin main; t="$(TAG)"; teg "$t"
      subj origin "refs/tags/$t"
      chk "rc=$RC, ожидался 1" rc_is 1
      chk "нет строки «gitw ТЕГ-ОТКАЗ: $t: вердикт критика не в main цели»" otkaz130 "$t" "вердикт критика не в main цели"
      chk "тег $t ушёл на цель" not na_celi "$t" ;;
    c05-verdikt-fail)
      mir "$c"; tekst 1; verdikty; verdikt "$V" FAIL; kommit текст; gq push -q origin main; t="$(TAG)"; teg "$t"
      subj origin "refs/tags/$t"
      chk "rc=$RC, ожидался 1" rc_is 1
      chk "нет строки «gitw ТЕГ-ОТКАЗ: $t: вердикт критика не в main цели»" otkaz130 "$t" "вердикт критика не в main цели"
      chk "тег $t ушёл на цель" not na_celi "$t" ;;
    c06-lokalnyj-main)
      mir "$c"; tekst 1; verdikty; kommit "текст в локальном main"; t="$(TAG)"; teg "$t"
      subj origin "refs/tags/$t"
      chk "rc=$RC, ожидался 1" rc_is 1
      chk "нет строки «gitw ТЕГ-ОТКАЗ: $t: текст не в main цели»" otkaz130 "$t" "текст не в main цели"
      chk "тег $t ушёл на цель" not na_celi "$t" ;;
    c07-tracking)
      mir "$c"; gq checkout -q -b wip/"$NNN"/architect; tekst 1; verdikty; kommit текст; t="$(TAG)"; teg "$t"
      gq update-ref refs/remotes/origin/main HEAD
      subj origin "refs/tags/$t"
      chk "rc=$RC, ожидался 1" rc_is 1
      chk "нет строки «gitw ТЕГ-ОТКАЗ: $t: текст не в main цели»" otkaz130 "$t" "текст не в main цели"
      chk "тег $t ушёл на цель" not na_celi "$t" ;;
    c08-tags)
      mir "$c"; gq checkout -q -b wip/"$NNN"/architect; tekst 1; verdikty; kommit текст; t="$(TAG)"; teg "$t"
      gq checkout -q main
      subj origin --tags
      chk "rc=$RC, ожидался 1" rc_is 1
      chk "нет строки «gitw ТЕГ-ОТКАЗ: $t: текст не в main цели»" otkaz130 "$t" "текст не в main цели"
      chk "тег $t ушёл на цель" not na_celi "$t" ;;
    c09-korotkoe-imya)
      mir "$c"; gq checkout -q -b wip/"$NNN"/architect; tekst 1; verdikty; kommit текст; t="$(TAG)"; teg "$t"
      subj origin "$t"
      chk "rc=$RC, ожидался 1" rc_is 1
      chk "нет строки «gitw ТЕГ-ОТКАЗ: $t: текст не в main цели»" otkaz130 "$t" "текст не в main цели"
      chk "тег $t ушёл на цель" not na_celi "$t" ;;
    c10-done)
      mir "$c"; gq checkout -q -b wip/"$NNN"/architect; tekst 1; kommit текст; t="done/contracts/$NNN/1"; teg "$t"
      subj origin "refs/tags/$t"
      chk "rc=$RC, ожидался 0 (тег другого класса не судится)" rc_is 0
      chk "тег $t не на цели" na_celi "$t" ;;
    c11-id)
      mir "$c"; gq checkout -q -b wip/"$NNN"/architect; tekst 1; kommit текст; t="id/CONTRACT/$NNN"; teg "$t"
      subj origin "refs/tags/$t"
      chk "rc=$RC, ожидался 0 (тег другого класса не судится)" rc_is 0
      chk "тег $t не на цели" na_celi "$t" ;;
    c12-net-main)
      mir "$c" trunk; tekst 1; verdikty; kommit текст; gq push -q origin trunk; t="$(TAG)"; teg "$t"
      subj origin "refs/tags/$t"
      chk "rc=$RC, ожидался 1" rc_is 1
      chk "нет строки «gitw ТЕГ-ОТКАЗ: $t: main цели не читается»" otkaz130 "$t" "main цели не читается"
      chk "тег $t ушёл на цель" not na_celi "$t" ;;
    c13-main-ne-lokalno)
      mir "$c"; gq checkout -q -b wip/"$NNN"/architect; tekst 1; verdikty; kommit текст; t="$(TAG)"; teg "$t"
      gq push -q origin "wip/$NNN/architect"
      local C0="$C"; C="$W/c2"; git clone -q "$B" "$C" 2>/dev/null
      gq merge -q --no-ff -m "land: wip/$NNN/architect" "origin/wip/$NNN/architect"; gq push -q origin main
      C="$C0"
      subj origin "refs/tags/$t"
      chk "rc=$RC, ожидался 1" rc_is 1
      chk "нет строки «gitw ТЕГ-ОТКАЗ: $t: main цели не читается»" otkaz130 "$t" "main цели не читается"
      chk "тег $t ушёл на цель" not na_celi "$t" ;;
    c14-origin-nedostupen)
      mir "$c"; tekst 1; verdikty; kommit текст; t="$(TAG)"; teg "$t"
      rm -rf "$B"
      subj origin "refs/tags/$t"
      chk "rc=$RC, ожидался 1" rc_is 1
      chk "нет строки «gitw ОТКАЗ: авторитет недоступен»" stroka "gitw ОТКАЗ: авторитет недоступен"
      chk "локальный тег $t пропал" lokalno "$t" ;;
    c15-071-ne-oslablen)
      # Замороженный 071 И-4 на ЭТОМ состоянии требует отказа: 130 его не ослабляет.
      mir "$c"; tekst 1; verdikty; kommit "текст в main до ленда"; t="$(TAG)"; teg "$t"
      local before; before="$(git -C "$B" rev-parse -q --verify refs/heads/main)"
      subj origin main
      chk "rc=$RC, ожидался 1" rc_is 1
      chk "нет строки «gitw ПРЕДПОЛЁТ-ОТКАЗ: локальный тег не на origin: $t»" stroka "gitw ПРЕДПОЛЁТ-ОТКАЗ: локальный тег не на origin: $t"
      chk "main цели сдвинут" test "$(git -C "$B" rev-parse -q --verify refs/heads/main)" = "$before"
      chk "тег $t ушёл на цель" not na_celi "$t"
      chk "локальный тег $t пропал" lokalno "$t" ;;
    c16-hold-lend-publikaciya)
      mir "$c"; tekst 1; verdikty; kommit "текст в main до ленда"; t="$(TAG)"; teg "$t"
      local want; want="$(g rev-parse HEAD)"
      guard hold "$t"
      chk "hold rc=$RC, ожидался 0" rc_is 0
      chk "тег $t остался в refs/tags после hold" not lokalno "$t"
      chk "нет удержания refs/frozen-hold/${t#frozen/}" uderzhan "$t"
      subj origin main
      chk "ленд rc=$RC, ожидался 0: $(tail -n 2 "$W/err" | tr '\n' ' ')" rc_is 0
      chk "main цели не сдвинут на ленд" test "$(git -C "$B" rev-parse -q --verify refs/heads/main)" = "$want"
      guard publish "$t"
      chk "publish rc=$RC, ожидался 0: $(tail -n 2 "$W/err" | tr '\n' ' ')" rc_is 0
      chk "тег $t не на цели" na_celi "$t"
      chk "локального тега $t нет после publish" lokalno "$t"
      chk "удержание refs/frozen-hold/${t#frozen/} не снято" not uderzhan "$t" ;;
    c17-vmeste)
      mir "$c"; tekst 1; verdikty; kommit "текст в main до ленда"; t="$(TAG)"; teg "$t"
      local before; before="$(git -C "$B" rev-parse -q --verify refs/heads/main)"
      subj origin main "refs/tags/$t"
      chk "rc=$RC, ожидался 1" rc_is 1
      chk "нет строки «gitw ТЕГ-ОТКАЗ: $t: текст не в main цели»" otkaz130 "$t" "текст не в main цели"
      chk "тег $t ушёл на цель" not na_celi "$t"
      chk "main цели сдвинут" test "$(git -C "$B" rev-parse -q --verify refs/heads/main)" = "$before" ;;
    c18-follow-tags)
      mir "$c"; gq checkout -q -b wip/"$NNN"/architect; tekst 1; verdikty; kommit текст; t="$(TAG)"; teg "$t"
      subj --follow-tags origin "wip/$NNN/architect"
      chk "rc=$RC, ожидался 1" rc_is 1
      chk "нет строки «gitw ТЕГ-ОТКАЗ: $t: текст не в main цели»" otkaz130 "$t" "текст не в main цели"
      chk "тег $t ушёл на цель" not na_celi "$t" ;;
    c19-plans)
      mir "$c"; tekst 1 plans; verdikty plans; kommit план; gq push -q origin main; t="$(TAG plans)"; teg "$t"
      subj origin "refs/tags/$t"
      chk "rc=$RC, ожидался 0" rc_is 0
      chk "тег $t не на цели" na_celi "$t" ;;
    c20-vne-grammatiki)
      mir "$c"; tekst 1; verdikty; kommit текст; gq push -q origin main; t="frozen/misc/$NNN/1"; teg "$t"
      subj origin "refs/tags/$t"
      chk "rc=$RC, ожидался 1" rc_is 1
      chk "нет строки «gitw ТЕГ-ОТКАЗ: $t: тег вне грамматики»" otkaz130 "$t" "тег вне грамматики"
      chk "тег $t ушёл на цель" not na_celi "$t" ;;
    c21-push-option-o)
      mir "$c"; git -C "$B" config receive.advertisePushOptions true; wip_teg
      subj -o probe130 origin "refs/tags/$T"
      ne_ushel "$T" ;;
    c22-push-option-dlinnaya)
      mir "$c"; git -C "$B" config receive.advertisePushOptions true; wip_teg
      subj --push-option probe130 origin "$T"
      ne_ushel "$T" ;;
    c23-receive-pack)
      mir "$c"; wip_teg
      subj --receive-pack git-receive-pack origin "refs/tags/$T"
      ne_ushel "$T" ;;
    c24-razdelitel)
      mir "$c"; wip_teg
      subj origin -- "refs/tags/$T"
      ne_ushel "$T" ;;
    c25-pereimenovanie)
      mir "$c"; gq checkout -q -b wip/"$NNN"/architect; tekst 1; verdikty; kommit текст
      t="$(TAG)"; teg "ishod/$NNN"
      subj origin "refs/tags/ishod/$NNN:refs/tags/$t"
      ne_ushel "$t" ;;
    c26-force)
      mir "$c"; t="$(TAG)"; teg "$t"; gq push -q origin "refs/tags/$t"
      local old; old="$(git -C "$B" rev-parse -q --verify "refs/tags/$t")"
      gq checkout -q -b wip/"$NNN"/architect; tekst 1; verdikty; kommit текст
      gq tag -f -a "$t" -m заморозка
      subj origin "+refs/tags/$t"
      chk "rc=$RC, ожидался 1" rc_is 1
      chk "нет строки «gitw ТЕГ-ОТКАЗ: $t: текст не в main цели»" otkaz130 "$t" "текст не в main цели"
      chk "тег $t на цели сдвинут" test "$(git -C "$B" rev-parse -q --verify "refs/tags/$t")" = "$old" ;;
    c27-mirror)
      mir "$c"; wip_teg
      subj --mirror origin
      ne_ushel "$T" ;;
    c28-all)
      mir "$c"; wip_teg
      subj --all origin
      chk "rc=$RC, ожидался 1" rc_is 1
      chk "нет строки «gitw ПРЕДПОЛЁТ-ОТКАЗ: локальный тег не на origin: $T»" stroka "gitw ПРЕДПОЛЁТ-ОТКАЗ: локальный тег не на origin: $T"
      chk "тег $T ушёл на цель" not na_celi "$T"
      chk "ветка wip/$NNN/architect ушла на цель" not git -C "$B" rev-parse -q --verify "refs/heads/wip/$NNN/architect" ;;
    c29-head-v-teg)
      mir "$c"; gq checkout -q -b wip/"$NNN"/architect; tekst 1; verdikty; kommit текст; t="$(TAG)"
      subj origin "HEAD:refs/tags/$t"
      ne_ushel "$t" ;;
    c30-c-followtags)
      mir "$c"; wip_teg
      subjg -c push.followTags=true push origin "wip/$NNN/architect"
      ne_ushel "$T" ;;
    c31-publikaciya-do-lenda)
      mir "$c"; wip_teg
      guard hold "$T"
      chk "hold rc=$RC, ожидался 0" rc_is 0
      guard publish "$T"
      ne_ushel "$T"
      chk "тег $T остался в refs/tags после отказа publish" not lokalno "$T"
      chk "удержание refs/frozen-hold/${T#frozen/} пропало" uderzhan "$T" ;;
    c32-tihij-q)
      mir "$c"; wip_teg
      subj -q origin "refs/tags/$T"
      ne_ushel "$T" ;;
    c33-tihij-dlinnaya)
      mir "$c"; wip_teg
      subj --quiet origin "refs/tags/$T"
      ne_ushel "$T" ;;
    c34-ne-porcelain)
      mir "$c"; wip_teg
      subj --no-porcelain origin "refs/tags/$T"
      ne_ushel "$T" ;;
    c35-ne-dry-run)
      mir "$c"; wip_teg
      subj --no-dry-run origin "refs/tags/$T"
      ne_ushel "$T" ;;
    c36-verbose)
      mir "$c"; wip_teg
      subj -v origin "refs/tags/$T"
      ne_ushel "$T" ;;
    c37-progress)
      mir "$c"; wip_teg
      subj --progress origin "refs/tags/$T"
      ne_ushel "$T" ;;
    c38-tiho-legitimno)
      # Тихий push ДОПУЩЕННОГО тега: замена флагов в пробе не ломает легитимный путь.
      mir "$c"; tekst 1; verdikty; kommit "текст в main до ленда"; gq push -q origin main; t="$(TAG)"; teg "$t"
      subj -q origin "refs/tags/$t"
      chk "rc=$RC, ожидался 0" rc_is 0
      chk "тег $t не на цели" na_celi "$t" ;;
    c39-perestanovka)
      mir "$c"; wip_teg
      subj origin --porcelain -n --no-dry-run "refs/tags/$T"
      ne_ushel "$T" ;;
    c40-sokraschenie)
      # --qui — сокращение --quiet; --no-dry — однозначное сокращение --no-dry-run:
      # семейство отмены пробы обязано распознаваться по префиксу, проба остаётся сухой.
      mir "$c"; wip_teg
      subj --qui --no-dry origin "refs/tags/$T"
      ne_ushel "$T" ;;
    c41-batl-flagov)
      # -qn батчится (тихий + сухой): проба глушится, состав не читается — fail-closed отказ,
      # а не допуск по пустому составу.
      mir "$c"; wip_teg
      subj -qn origin "refs/tags/$T"
      chk "rc=$RC, ожидался 1" rc_is 1
      chk "нет строки «gitw ТЕГ-ОТКАЗ: (обмен): состав обмена не читается»" otkaz130 "(обмен)" "состав обмена не читается"
      chk "тег $T ушёл на цель" not na_celi "$T" ;;
    *) printf 'NOT_IMPLEMENTED: нет такой клетки: %s\n' "$c" >&2; exit 2 ;;
  esac
  [ -z "$WHY" ]
}

podgotovit() {  # podgotovit <каталог> [stub-id] — копия scripts/ дерева + модель (+ стаб)
  local d="$1"; rm -rf "$d"; mkdir -p "$d"
  cp -R "$ROOT/scripts/." "$d/" || { printf 'NOT_IMPLEMENTED: scripts/ дерева не копируется\n' >&2; exit 2; }
  if [ -n "${2:-}" ]; then
    python3 "$HERE/podmena.py" stub "$2" "$d" || { printf 'NOT_IMPLEMENTED: стаб %s не лёг\n' "$2" >&2; exit 2; }
  else
    python3 "$HERE/podmena.py" model "$d" || { printf 'NOT_IMPLEMENTED: модель не легла\n' >&2; exit 2; }
  fi
}

run_cells() {  # run_cells <метка>
  local n=0 ok=0 bad=0 c
  for c in "${CELLS[@]}"; do
    n=$((n + 1))
    if cell "$c"; then ok=$((ok + 1)); printf 'КЛЕТКА %s: СОШЛОСЬ\n' "$c"
    else bad=$((bad + 1)); printf 'КЛЕТКА %s: РАСХОЖДЕНИЕ — %s\n' "$c" "$WHY"; fi
  done
  printf 'ИТОГ 130 (%s): клеток %d, сошлось %d, расхождений %d (seed %s, NNN %s, v %s)\n' \
    "$1" "$n" "$ok" "$bad" "$seed" "$NNN" "$V"
  [ "$n" -gt 0 ] && [ "$bad" -eq 0 ]
}

case "$mode" in
  product)
    if [ -n "$cand" ]; then SUBJ="$(cd "$cand/scripts" 2>/dev/null && pwd)" || { printf 'NOT_IMPLEMENTED: нет %s/scripts\n' "$cand" >&2; exit 2; }
    else SUBJ="$ROOT/scripts"; fi
    [ -f "$SUBJ/gitw" ] || { printf 'NOT_IMPLEMENTED: нет %s/gitw\n' "$SUBJ" >&2; exit 2; }
    run_cells продукт; exit $? ;;
  model)
    SUBJ="$WORK/model"; podgotovit "$SUBJ"
    run_cells модель; exit $? ;;
  stabs)
    SUBJ="$WORK/model"; podgotovit "$SUBJ"
    n=0; caught=0; miss=0
    while IFS=$'\t' read -r sid scell sdef; do
      [ -n "$sid" ] || continue
      if [ -n "$only" ] && [ "$scell" != "$only" ]; then continue; fi
      n=$((n + 1))
      SUBJ="$WORK/model"
      if ! cell "$scell"; then
        miss=$((miss + 1)); printf 'СТАБ %s (клетка %s): КОНТРОЛЬ РАСХОДИТСЯ — %s\n' "$sid" "$scell" "$WHY"; continue
      fi
      SUBJ="$WORK/stub"; podgotovit "$SUBJ" "$sid"
      if cell "$scell"; then
        miss=$((miss + 1)); printf 'СТАБ %s (клетка %s): НЕ ПОЙМАН — %s\n' "$sid" "$scell" "$sdef"
      else
        caught=$((caught + 1)); printf 'СТАБ %s (клетка %s): ПОЙМАН — %s\n' "$sid" "$scell" "$WHY"
      fi
    done < <(python3 "$HERE/podmena.py" list)
    printf 'ИТОГ 130 (стабы): стабов %d, поймано %d, непойманных %d (seed %s)\n' "$n" "$caught" "$miss" "$seed"
    [ "$n" -gt 0 ] && [ "$miss" -eq 0 ]; exit $? ;;
esac
