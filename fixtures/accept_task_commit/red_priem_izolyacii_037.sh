#!/usr/bin/env bash
# КРАСНОЕ 037-М3 v+1 «штатный приём ИЗОЛИРОВАННЫХ рабочих пачек» (заявка
# contracts/199-sol-v-izolyacii.md:20, слово владельца 2026-11-18 ~14:05 UTC,
# §4 батча №2; расширение ceremony М3 frozen 037 `:480-515`).
#
# ПРЕДМЕТ БАТАРЕИ (исполнимые клетки ц0–ц5; привязка обманных заглушек к
# различающим прогонам — КОДОМ ниже: stab_kletki/stub_sreda, Н-39 — не прозой
# контракта):
#   * ц0 — раздел «## Ceremony кодового `_task`-дозвона (контракт 037)»
#     субъекта несёт расширение v+1: якоря privjazka_sdachi.sh (сверка ДО
#     приёма), 199-baza- (каноническая синхробаза), 199-nositel- (блок
#     приёма), ПРИНЯТОГО tip (следующий дозвон);
#   * ц1 — каноническая синхробаза: копия работника ДО работы поднимается
#     блоком 199-baza от НОСИТЕЛЯ (устаревший снимок подтягивается к
#     авторскому tip; носитель чист, main не тронут);
#   * ц2 — приём изолированной пачки только после сверы носителя: честная
#     сдача (роль/ветка/предмет/изоляция/репозиторий/владелец копии/tip
#     сходятся с фактом START) — сверка rc 0, root выведен из факта, приём
#     исполняется, ветка продвинута; чужая копия (owner.json ≠ держателю
#     START) — именованный отказ ДО приёма, ветка не двинута;
#   * ц3 — чистота носителя ДО приёма: грязный носитель — отказ без лечения,
#     грязные байты сохранены, ветка не двинута (сверка честной сдачи при
#     этом проходит — стоп именно на носителе);
#   * ц4 — фиксация принятого tip: после блока приёма ветка на НОВОМ tip
#     (cherry-pick меняет sha: tip ≠ авторскому базовому и ≠ sha источника),
#     носитель синхронизирован (HEAD == ветка, индекс/дерево чисты), main
#     не тронут;
#   * ц5 — следующий дозвон от принятого tip: СВЕЖАЯ копия, поднятая блоком
#     199-baza от носителя ПОСЛЕ приёма, стоит ровно на принятом tip —
#     не на устаревшем снимке и не на sha источника.
#
# СУБЪЕКТЫ: раздел М3 и канонические блоки — roles/orchestrator.md; сверка —
# scripts/privjazka_sdachi.sh; приёмник — scripts/accept_task_commit.sh
# (реальный, этим предметом не меняется). Модели-эталоны: ceremony —
# priem_izolyacii_037/model/orchestrator_ceremony_m3.md (эта пачка); блоки и
# сверка — fixtures/workshop_project/sol_v_izolyacii_199/model/ (единый
# источник байтов 199, этой батареей не дублируются).
#
# РЕЖИМЫ:
#   (без флага)  — субъекты дерева; до реализации красное (rc 1);
#   <корень>/--repo <R> — корень дерева субъектов (CI/станция);
#   --model      — модели-эталоны целевой семантики; зелёное;
#   --stabs      — контроль над моделями + обманные заглушки stabs/;
#                  зелёное означает: каждая заглушка различима хотя бы одним
#                  своим прогоном.
#
# КОДЫ: 0 — зелено; 1 — красная клетка либо живая заглушка; 2 — нечем проверить.
set -u

MODE='osn'; ROOT_ARG=''
while [ "$#" -gt 0 ]; do
  case "$1" in
    --model) MODE='model' ;;
    --stabs) MODE='stabs' ;;
    --repo)  ROOT_ARG="${2:?использование: [<корень>] [--model|--stabs] [--repo R]}"; shift ;;
    -*) printf 'использование: %s [<корень>] [--model|--stabs] [--repo R]\n' "$0" >&2; exit 2 ;;
    *)  ROOT_ARG="$1" ;;
  esac
  shift
done
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
if [ -n "$ROOT_ARG" ]; then
  ROOT="$(cd "$ROOT_ARG" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень --repo не читается: %s\n' "$ROOT_ARG" >&2; exit 2; }
else
  ROOT="$(cd "$HERE/../.." && pwd -P)"
fi

command -v bash >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет bash\n' >&2; exit 2; }
command -v git  >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n'  >&2; exit 2; }
command -v jq   >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет jq\n'   >&2; exit 2; }

# Гигиена Н-85: снять git-подсказки окружения.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

# ── субъекты (env-швы заглушек; модели — режим --model) ──────────────────────
cerem() { printf '%s' "${S037V_CEREM:-$ROOT/roles/orchestrator.md}"; }
bloki() { printf '%s' "${S037V_BLOKI:-$ROOT/roles/orchestrator.md}"; }
priv()  { printf '%s' "${S037V_PRIV:-$ROOT/scripts/privjazka_sdachi.sh}"; }
ACCEPT="$ROOT/scripts/accept_task_commit.sh"
MODEL_CEREM="$HERE/priem_izolyacii_037/model/orchestrator_ceremony_m3.md"
MODEL_BLOKI="$ROOT/fixtures/workshop_project/sol_v_izolyacii_199/model/orchestrator_vstavka_199.md"
MODEL_PRIV="$ROOT/fixtures/workshop_project/sol_v_izolyacii_199/model/privjazka_sdachi.sh"

if [ "$MODE" = 'model' ] || [ "$MODE" = 'stabs' ]; then
  S037V_CEREM="$MODEL_CEREM"
  S037V_BLOKI="$MODEL_BLOKI"
  S037V_PRIV="$MODEL_PRIV"
  export S037V_CEREM S037V_BLOKI S037V_PRIV
fi
for f in "$MODEL_CEREM" "$MODEL_BLOKI" "$MODEL_PRIV" "$ACCEPT"; do
  [ -f "$f" ] || { printf 'NOT_IMPLEMENTED: нет файла батареи/субъекта: %s\n' "$f" >&2; exit 2; }
done

# Миры СОЗНАТЕЛЬНО вне ${TMPDIR:-/tmp}/dev-harness-verify — иначе pass по
# scratch-allowlist 025 ничего не доказывает (ловушка Н-85/А-122, прецедент
# fixtures/path_guard/red_own_copy_paket_b.sh и батареи 199).
WB="$(mktemp -d /tmp/dev-harness-s037v1.XXXXXX)" || exit 2
trap 'rm -rf "$WB"' EXIT
WBASE="$WB/osn"

# ── построители миров ─────────────────────────────────────────────────────────
mkrepo() {  # <путь> — минимальный репо, .git КАТАЛОГ, 1 коммит
  mkdir -p "$1"
  git -C "$1" init -q -b main
  printf 'x\n' > "$1/f.txt"
  git -C "$1" add f.txt
  git -C "$1" -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false commit -qm init
}
commit_as() {  # <репо> <роль> <msg> — фиксированные даты: детерминизм sha миров
  git -C "$1" add -A
  GIT_AUTHOR_DATE='2005-04-07T22:13:13+00:00' GIT_COMMITTER_DATE='2005-04-07T22:13:14+00:00' \
    git -C "$1" -c user.name="$2" -c user.email="$2@dev-harness.local" \
    -c commit.gpgsign=false commit -qm "$3"
}
izvlek() {  # <файл> <маркер-начало> <маркер-конец> <out> — блок между маркерами
  grep -Fqx "$2" "$1" || return 1
  grep -Fqx "$3" "$1" || return 1
  awk -v a="$2" -v b="$3" '$0 == a { f = 1; next } $0 == b { f = 0 } f' "$1" > "$4"
  [ -s "$4" ] || return 1
}
m3_razdel() {  # <файл> <out> — раздел М3 (от заголовка до следующего '^## ')
  grep -Fqx '## Ceremony кодового `_task`-дозвона (контракт 037)' "$1" || return 1
  awk 'index($0, "## Ceremony кодового `_task`-дозвона (контракт 037)") == 1 { f = 1; next } f && /^## / { exit } f' "$1" > "$2"
  [ -s "$2" ] || return 1
}

# Мир предмета: main-репо + носитель (worktree wip/037/architect) + копия
# работника (клон; снимок ДО продвижения носителя при advance=1) + учёт с
# фактом START держателя Arch037V (klass=rabochij, isolated:true).
mk_mir() {  # <dir> <advance 1|0>
  local d="$1"
  M_MAIN="$d/main"; M_CAR="$d/carrier"; M_SOST="$d/sost"; M_KOP="$d/kop/m"
  mkdir -p "$M_SOST" "$d/kop"
  mkrepo "$M_MAIN"
  git -C "$M_MAIN" remote add origin "$d/toyrepo.git"
  git -C "$M_MAIN" worktree add -q -b wip/037/architect "$M_CAR" >/dev/null 2>&1
  printf 'b1\n' > "$M_CAR/b1.txt"
  commit_as "$M_CAR" architect 'avtor b1'
  M_A1="$(git -C "$M_MAIN" rev-parse wip/037/architect)"
  M_MAIN0="$(git -C "$M_MAIN" rev-parse main)"
  git clone -q --no-hardlinks "$M_MAIN" "$M_KOP"
  printf '{"pid":1,"id":"Arch037V","startToken":"1"}' > "$d/kop/.omp-isolation-owner.json"
  if [ "$2" = '1' ]; then
    printf 'b2\n' > "$M_CAR/b2.txt"
    commit_as "$M_CAR" architect 'avtor b2'
    M_A2="$(git -C "$M_MAIN" rev-parse wip/037/architect)"
  else
    M_A2="$M_A1"
  fi
  jq -nc --arg r toyrepo --arg s 037 --arg h Arch037V --arg ro architect \
        --arg o - --arg w "$M_CAR" --arg b wip/037/architect --argjson iso true \
    '{t:"START",repoId:$r,subjectId:$s,group:"-",holder:$h,klass:"rabochij",rol:$ro,object:$o,worktree:$w,branch:$b,at:"2026-11-18T00:00:00Z",isolated:$iso}' \
    >> "$M_SOST/uchet.jsonl"
}

# Подъём копии каноническим блоком 199-baza + один честный коммит работника.
podnjat_i_porabotat() {  # <w>
  izvlek "$(bloki)" '# 199-baza-nachalo' '# 199-baza-konec' "$1/blk.sh" \
    || { printf 'подъём: канонический блок синхробазы отсутствует в субъекте\n' >&2; return 1; }
  ( cd "$M_KOP" && WORKTREE="$M_CAR" BRANCH=wip/037/architect bash "$1/blk.sh" ) >/dev/null 2>&1 \
    || { printf 'подъём: блок синхробазы отказал\n' >&2; return 1; }
  [ "$(git -C "$M_KOP" rev-parse HEAD)" = "$M_A2" ] \
    || { printf 'подъём: копия не на авторском tip носителя\n' >&2; return 1; }
  printf 'rab\n' > "$M_KOP/rab.txt"
  commit_as "$M_KOP" architect 'rabota 037v1'
  return 0
}
# Сверка → (rc 0) → блок приёма; ROOT блока — из stdout сверки (не выбирается
# вызывающим). Порядок ceremony: сверка ДО приёма (заявка 199:20).
svjerja_i_prinimaj() {  # <w> <source> <tip>
  local out rc ROOT_PR
  out="$(bash "$(priv)" --sostojanie "$M_SOST" --repo "$M_MAIN" --subject 037 \
    --source "$2" --branch wip/037/architect --author architect --tip "$3" 2>"$1/pe")"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'приём: сверка rc=%s %s\n' "$rc" "$(tail -1 "$1/pe")" >&2; return 1; }
  ROOT_PR="$(printf '%s' "$out" | sed -n 's/^root=\(.*\)$/\1/p')"
  [ -n "$ROOT_PR" ] || { printf 'приём: сверка без root=\n' >&2; return 1; }
  izvlek "$(bloki)" '# 199-nositel-nachalo' '# 199-nositel-konec' "$1/nos.sh" \
    || { printf 'приём: канонический блок приёма отсутствует в субъекте\n' >&2; return 1; }
  ( WORKTREE="$M_CAR" SOURCE="$2" BRANCH=wip/037/architect AUTHOR=architect \
    ACCEPT="$ACCEPT" ROOT="$ROOT_PR" bash "$1/nos.sh" ) >"$1/no" 2>"$1/ne"
  return $?
}

# ── клетки ───────────────────────────────────────────────────────────────────
c0() {
  local w="$WBASE/c0"; mkdir -p "$w"
  m3_razdel "$(cerem)" "$w/m3.md" || { printf 'ц0: раздел М3 не найден в субъекте\n' >&2; return 1; }
  local a
  for a in 'privjazka_sdachi.sh' '199-baza-' '199-nositel-' 'ПРИНЯТОГО tip'; do
    grep -Fq "$a" "$w/m3.md" || { printf 'ц0: раздел М3 без якоря «%s»\n' "$a" >&2; return 1; }
  done
}
c1() {
  local w="$WBASE/c1"; mkdir -p "$w"; mk_mir "$w" 1
  local rc
  izvlek "$(bloki)" '# 199-baza-nachalo' '# 199-baza-konec' "$w/blk.sh" \
    || { printf 'ц1: канонический блок синхробазы отсутствует в субъекте\n' >&2; return 1; }
  ( cd "$M_KOP" && WORKTREE="$M_CAR" BRANCH=wip/037/architect bash "$w/blk.sh" ) >"$w/out" 2>"$w/err"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'ц1: блок синхробазы rc=%s %s\n' "$rc" "$(tail -1 "$w/err")" >&2; return 1; }
  [ "$(git -C "$M_KOP" rev-parse HEAD)" = "$M_A2" ] || { printf 'ц1: копия не на авторском tip носителя\n' >&2; return 1; }
  [ "$(git -C "$M_KOP" rev-parse --abbrev-ref HEAD)" = 'wip/037/architect' ] || { printf 'ц1: ветка в копии не переключена\n' >&2; return 1; }
  [ -z "$(git -C "$M_CAR" status --porcelain)" ] || { printf 'ц1: носитель загрязнён\n' >&2; return 1; }
  [ "$(git -C "$M_MAIN" rev-parse main)" = "$M_MAIN0" ] || { printf 'ц1: main изменён\n' >&2; return 1; }
}
c2() {
  local w="$WBASE/c2"; mkdir -p "$w"; mk_mir "$w" 0
  podnjat_i_porabotat "$w" || { printf 'ц2: копия не поднята/не закоммичена\n' >&2; return 1; }
  local W rc
  W="$(git -C "$M_KOP" rev-parse HEAD)"
  # (а) чужая копия: owner.json ≠ держателю START — отказ ДО приёма.
  mkdir -p "$w/chp"
  git clone -q --no-hardlinks "$M_MAIN" "$w/chp/m"
  git -C "$w/chp/m" switch -q -C wip/037/architect "$M_A1"
  printf 'chuzhoe\n' > "$w/chp/m/chp.txt"
  commit_as "$w/chp/m" architect 'chuzhaja sdacha'
  printf '{"pid":1,"id":"Chuzhoj","startToken":"1"}' > "$w/chp/.omp-isolation-owner.json"
  local CHW; CHW="$(git -C "$w/chp/m" rev-parse HEAD)"
  bash "$(priv)" --sostojanie "$M_SOST" --repo "$M_MAIN" --subject 037 \
    --source "$w/chp/m" --branch wip/037/architect --author architect --tip "$CHW" \
    >"$w/p1" 2>"$w/pe1"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'ц2: чужая копия rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'KOPIJA_CHUZHAYA' "$w/pe1" || { printf 'ц2: нет KOPIJA_CHUZHAYA\n' >&2; return 1; }
  [ "$(git -C "$M_MAIN" rev-parse wip/037/architect)" = "$M_A1" ] || { printf 'ц2: ветка двинута вопреки отказу сверы\n' >&2; return 1; }
  # (б) честная сдача: сверка rc 0 → приём → ветка продвинута.
  svjerja_i_prinimaj "$w" "$M_KOP" "$W" || { printf 'ц2: честная сдача не принята (%s)\n' "$(tail -1 "$w/ne" 2>/dev/null || tail -1 "$w/pe")" >&2; return 1; }
  local T; T="$(git -C "$M_MAIN" rev-parse wip/037/architect)"
  [ "$T" != "$M_A1" ] || { printf 'ц2: ветка не продвинута приёмом\n' >&2; return 1; }
}
c3() {
  local w="$WBASE/c3"; mkdir -p "$w"; mk_mir "$w" 0
  podnjat_i_porabotat "$w" || { printf 'ц3: копия не поднята/не закоммичена\n' >&2; return 1; }
  local W rc sum0
  W="$(git -C "$M_KOP" rev-parse HEAD)"
  printf 'dirty\n' >> "$M_CAR/f.txt"
  sum0="$(sha256sum "$M_CAR/f.txt" | cut -d' ' -f1)"
  izvlek "$(bloki)" '# 199-nositel-nachalo' '# 199-nositel-konec' "$w/nos.sh" \
    || { printf 'ц3: канонический блок приёма отсутствует в субъекте\n' >&2; return 1; }
  ( WORKTREE="$M_CAR" SOURCE="$M_KOP" BRANCH=wip/037/architect AUTHOR=architect \
    ACCEPT="$ACCEPT" ROOT="$M_MAIN" bash "$w/nos.sh" ) >"$w/no" 2>"$w/ne"; rc=$?
  [ "$rc" -ne 0 ] || { printf 'ц3: грязный носитель «вылечен» без отказа\n' >&2; return 1; }
  [ "$(sha256sum "$M_CAR/f.txt" | cut -d' ' -f1)" = "$sum0" ] || { printf 'ц3: грязные байты носителя потеряны\n' >&2; return 1; }
  [ "$(git -C "$M_MAIN" rev-parse wip/037/architect)" = "$M_A1" ] || { printf 'ц3: приём исполнился вопреки стопу\n' >&2; return 1; }
}
c4() {
  local w="$WBASE/c4"; mkdir -p "$w"; mk_mir "$w" 0
  podnjat_i_porabotat "$w" || { printf 'ц4: копия не поднята/не закоммичена\n' >&2; return 1; }
  local W T
  W="$(git -C "$M_KOP" rev-parse HEAD)"
  svjerja_i_prinimaj "$w" "$M_KOP" "$W" || { printf 'ц4: честная сдача не принята (%s)\n' "$(tail -1 "$w/ne" 2>/dev/null || tail -1 "$w/pe")" >&2; return 1; }
  T="$(git -C "$M_MAIN" rev-parse wip/037/architect)"
  [ "$T" != "$M_A1" ] || { printf 'ц4: ветка не двинута — приём не исполнен\n' >&2; return 1; }
  [ "$T" != "$W" ] || { printf 'ц4: tip ветки == sha источника — cherry-pick не менял sha (фиксации нет)\n' >&2; return 1; }
  [ "$(git -C "$M_CAR" rev-parse HEAD)" = "$T" ] || { printf 'ц4: HEAD носителя ≠ принятому tip\n' >&2; return 1; }
  [ -z "$(git -C "$M_CAR" status --porcelain)" ] || { printf 'ц4: носитель не синхронизирован с принятым tip\n' >&2; return 1; }
  [ "$(git -C "$M_MAIN" rev-parse main)" = "$M_MAIN0" ] || { printf 'ц4: main изменён\n' >&2; return 1; }
  [ -z "$(git -C "$M_MAIN" status --porcelain)" ] || { printf 'ц4: main загрязнён\n' >&2; return 1; }
}
c5() {
  local w="$WBASE/c5"; mkdir -p "$w"; mk_mir "$w" 0
  podnjat_i_porabotat "$w" || { printf 'ц5: копия не поднята/не закоммичена\n' >&2; return 1; }
  local W T rc
  W="$(git -C "$M_KOP" rev-parse HEAD)"
  svjerja_i_prinimaj "$w" "$M_KOP" "$W" || { printf 'ц5: честная сдача не принята (%s)\n' "$(tail -1 "$w/ne" 2>/dev/null || tail -1 "$w/pe")" >&2; return 1; }
  T="$(git -C "$M_MAIN" rev-parse wip/037/architect)"
  [ "$T" != "$W" ] || { printf 'ц5: принятый tip == sha источника\n' >&2; return 1; }
  # следующий дозвон: СВЕЖАЯ копия, подъём тем же каноническим блоком от носителя
  mkdir -p "$w/kop2"
  git clone -q --no-hardlinks "$M_MAIN" "$w/kop2/m"
  printf '{"pid":1,"id":"Arch037V2","startToken":"1"}' > "$w/kop2/.omp-isolation-owner.json"
  izvlek "$(bloki)" '# 199-baza-nachalo' '# 199-baza-konec' "$w/blk2.sh" \
    || { printf 'ц5: канонический блок синхробазы отсутствует в субъекте\n' >&2; return 1; }
  ( cd "$w/kop2/m" && WORKTREE="$M_CAR" BRANCH=wip/037/architect bash "$w/blk2.sh" ) >"$w/o2" 2>"$w/e2"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'ц5: блок синхробазы следующего дозвона rc=%s %s\n' "$rc" "$(tail -1 "$w/e2")" >&2; return 1; }
  [ "$(git -C "$w/kop2/m" rev-parse HEAD)" = "$T" ] || { printf 'ц5: свежая копия не на принятом tip\n' >&2; return 1; }
  [ "$(git -C "$w/kop2/m" rev-parse HEAD)" != "$W" ] || { printf 'ц5: свежая копия на sha источника, не на принятом tip\n' >&2; return 1; }
}

# ── учёт клеток ──────────────────────────────────────────────────────────────
ALL_KLETKI='c0 c1 c2 c3 c4 c5'
CELL_TOTAL=0; CELL_RED=0
kletka() {  # <id> — ОДИН прогон; диагностика — в файл мира
  local id="$1" dg
  dg="$WB/${S037V_TAG:-osn}.diag-$id"
  CELL_TOTAL=$((CELL_TOTAL + 1))
  WBASE="$WB/${S037V_TAG:-osn}"
  mkdir -p "$WBASE"
  if "$id" >/dev/null 2>"$dg"; then
    printf 'ok   %s\n' "$id"
  else
    CELL_RED=$((CELL_RED + 1))
    printf 'FAIL %s — %s\n' "$id" "$(grep -aE '^(ц[0-9]|подъём|приём): ' "$dg" | sed -n '1p')"
  fi
}
run_cells() {
  local id
  for id in "$@"; do
    kletka "$id"
  done
}

# ── заглушки: привязка к различающим прогонам — КОДОМ (Н-39) ────────────────
STABI=(s01 s02 s03 s04 s05 s06 s07)
stab_fajl() {
  case "$1" in
    s01) printf 'priem_izolyacii_037/stabs/s01_ceremon_main.md' ;;
    s02) printf 'priem_izolyacii_037/stabs/s02_ceremon_bez_prinjatogo_tipa.md' ;;
    s03) printf 'priem_izolyacii_037/stabs/s03_baza_bez_fetcha.md' ;;
    s04) printf 'priem_izolyacii_037/stabs/s04_priv_tolko_rol.sh' ;;
    s05) printf 'priem_izolyacii_037/stabs/s05_nositel_bez_chistoty.md' ;;
    s06) printf 'priem_izolyacii_037/stabs/s06_nositel_bez_sinhronizacii.md' ;;
    s07) printf 'priem_izolyacii_037/stabs/s07_nositel_bez_priema.md' ;;
  esac
}
stub_sreda() {
  case "$1" in
    s01|s02) printf 'S037V_CEREM' ;;
    s03|s05|s06|s07) printf 'S037V_BLOKI' ;;
    s04)     printf 'S037V_PRIV' ;;
  esac
}
stab_kletki() {
  case "$1" in
    s01) printf 'c0' ;;
    s02) printf 'c0' ;;
    s03) printf 'c1 c5' ;;
    s04) printf 'c2' ;;
    s05) printf 'c3' ;;
    s06) printf 'c4' ;;
    s07) printf 'c2 c4 c5' ;;
  esac
}

itog() {
  printf 'ИТОГ 037-М3 (%s): клеток %d, красных %d, зелёных %d\n' \
    "$1" "$CELL_TOTAL" "$CELL_RED" "$((CELL_TOTAL - CELL_RED))"
}

case "$MODE" in
  osn)
    run_cells $ALL_KLETKI
    itog 'субъекты дерева'
    if [ "$CELL_RED" -gt 0 ]; then
      printf 'КРАСНОЕ 037-М3: красных %d из %d (до реализации ожидаемо; после — дефект)\n' "$CELL_RED" "$CELL_TOTAL"
      exit 1
    fi
    printf 'ЗЕЛЕНОЕ 037-М3\n'
    exit 0
    ;;
  model)
    run_cells $ALL_KLETKI
    itog 'модели-эталоны'
    if [ "$CELL_RED" -gt 0 ]; then
      printf 'КРАСНОЕ 037-М3-model: модели не покрывают клетки: красных %d из %d\n' "$CELL_RED" "$CELL_TOTAL"
      exit 1
    fi
    printf 'ЗЕЛЕНОЕ 037-М3-model\n'
    exit 0
    ;;
  stabs)
    run_cells $ALL_KLETKI >/dev/null
    if [ "$CELL_RED" -gt 0 ]; then
      printf 'NOT_IMPLEMENTED: контроль над моделями красный (%d клеток) — оракул не зелён, заглушки не судятся\n' "$CELL_RED" >&2
      exit 2
    fi
    CELL_TOTAL=0; CELL_RED=0
    POJMANO=0; ZHIVYH=0
    for s in "${STABI[@]}"; do
      sf="$HERE/$(stab_fajl "$s")"
      [ -f "$sf" ] || { printf 'NOT_IMPLEMENTED: заглушка отсутствует: %s\n' "$sf" >&2; exit 2; }
      sr="$(stub_sreda "$s")"
      sk="$(stab_kletki "$s")"
      export "$sr=$sf" S037V_TAG="$s"
      run_cells $sk >/dev/null
      if [ "$CELL_RED" -gt 0 ]; then
        POJMANO=$((POJMANO + 1))
        printf 'СТАБ 037-М3: %s ПОЙМАН (клеток %d, красных %d)\n' "$s" "$CELL_TOTAL" "$CELL_RED"
      else
        ZHIVYH=$((ZHIVYH + 1))
        printf 'СТАБ 037-М3: %s ЖИВ — все клетки зелёны (клеток %d)\n' "$s" "$CELL_TOTAL"
      fi
      unset "$sr" S037V_TAG
      CELL_TOTAL=0; CELL_RED=0
    done
    printf 'СТАБЫ 037-М3: всего %d, поймано %d, живых %d\n' "${#STABI[@]}" "$POJMANO" "$ZHIVYH"
    if [ "$ZHIVYH" -gt 0 ]; then
      printf 'КРАСНОЕ 037-М3-stabs: живая заглушка не различима клетками: %d\n' "$ZHIVYH"
      exit 1
    fi
    printf 'ЗЕЛЕНОЕ 037-М3-stabs\n'
    exit 0
    ;;
esac
printf 'NOT_IMPLEMENTED: неизвестный режим %s\n' "$MODE" >&2
exit 2
