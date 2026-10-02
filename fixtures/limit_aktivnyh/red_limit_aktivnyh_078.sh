#!/usr/bin/env bash
# КРАСНОЕ 078 — «лимит активных контрактов»: отказ номера (next_id.sh CONTRACT),
# строки реестра (mint_line.sh) и заморозки (freeze_contract.sh contracts/NNN-*.md)
# при ≥2 активных на origin (слово владельца 2026-10-02, ТРЕТЬЯ РЕДАКЦИЯ).
#
# ДОГОВОР (контракт 078 §Инварианты): активный N = (frozen/contracts/N/* на origin ∨
# wip/N/* на origin) ∧ без done/contracts/N/* на origin; ≥2 активных → именованный отказ
# «лимит активных» ДО первой мутации; freeze не считает замораживаемого; исключение —
# ТОЛЬКО литеральная подстрока «РАЗРЕШИЛ-ВЛАДЕЛЕЦ: сверх лимита» в причине; счёт — живой
# ls-remote origin, отказ сети — fail-closed «авторитет недоступен».
#
# ПРИВЯЗКА К КОДУ (Н-39; стабы — к ветвям по фактическому коду, не проза):
#   л0 fail-fast (п1-класс 037): на л1/л7/л10-входах все три субъекта МОЛЧАТ (номер
#     выдан / MINTED / заморожено v1) → rc 1 «предмет отсутствует», честные клетки
#     не исполняются; после реализации л0 зелёная, идут все;
#   л1–л6, л15 — next_id (л1: 2 frozen → rc 1, тег не создан; л2: 1 → rc 0; л3:
#     строка владельца → rc 0; л3б: «РАЗРЕШИЛ-ВЛАДЕЛЕЦ:» без « сверх лимита» → rc 1;
#     л4: done закрывает; л5: 2 wip; л6: резерв id-тегом не активен; л15: мёртвый
#     origin → fail-closed);
#   л7–л9 — mint_line (л7: 2 frozen → rc 1, HEAD не двинут; л7б: минтимый NNN сам
#     активен + ещё один frozen → rc 1 — ошибочный вычет --nnn из активных ловится;
#     л8: 1 → MINTED; л9: строка владельца → MINTED; л9б: «РАЗРЕШИЛ-ВЛАДЕЛЕЦ:» без
#     « сверх лимита» → rc 1);
#   л10–л14 — freeze (л10: 2 frozen ≠001 → rc 1, тега нет; л11: 1 → v1; л12: строка
#     владельца → v1; л12б: причина «РАЗРЕШИЛ-ВЛАДЕЛЕЦ:» без « сверх лимита» → rc 1,
#     тега нет; л13: активен только сам 001 (wip/001 на origin) → v1; л14: сам 001 +
#     2 frozen → rc 1 — вычтен только замораживаемый; л14б: сам 001 + ОДИН frozen →
#     v1 — пограничная различает вычет субъекта: невычитающая реализация даёт rc 1);
#   стаб-пак стА–стЕ — мутантные копии мини-ядра mini_core_078.sh (одна замена одной
#     строки по маркеру «# ВЕТВЬ:…»; применение — двумя мерами: cmp ∧ grep -F):
#     стА ls-remote→локальные refs (И-2) · стБ done не вычитает (И-6) · стВ wip не
#     видит (И-6) · стГ широкий матчинг строки владельца (И-5) · стД замораживаемый
#     не вычтен (И-4) · стЕ сеть=пропуск (И-2). Каждый стаб: (а) диффпроба на чистом
#     мире rc 0 (не параноик), (б) НАРУШЕНИЕ — расходится с честным ядром ровно на
#     входе наблюдаемости дефекта; стаб-пак зелен ДО и ПОСЛЕ реализации субъекта.
#
# Активные создаются ПРЯМО В BARE origin (тег/ветка на уже запушенный main — порядок
# Н-160 коммиты→тег соблюдён), локальные refs клона остаются пустыми: счёт по origin
# наблюдаем в каждой клетке, отложенный fetch ничего не прячет. Значения случайны на
# прогон (985–999, внутрибатарейная уникальность; toy-миры изолированы mktemp+bare,
# пересечение с заявками соседних семей безопасно — worlds не пересекаются).
#
# Коды возврата: 0 — все ветви зелёные; 1 — есть красная (в т.ч. «предмет отсутствует»
# — предъявляемое красное ДО, прецедент п1 батареи 037); 2 — нечем проверять.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${1:-$(cd "$HERE/../.." && pwd)}"
SUBJ_NEXT="$ROOT/scripts/next_id.sh"
SUBJ_MINT="$ROOT/scripts/mint_line.sh"
SUBJ_FREEZE="$ROOT/scripts/freeze_contract.sh"
CORE="$HERE/mini_core_078.sh"

command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет python3 (генератор стабов)\n' >&2; exit 2; }
[ -f "$CORE" ] || { printf 'NOT_IMPLEMENTED: нет мини-ядра: %s\n' "$CORE" >&2; exit 2; }

WORK="$(mktemp -d "${TMPDIR:-/tmp}/red078.XXXXXX")"
[ "${KEEP078:-}" = "1" ] || trap 'rm -rf "$WORK"' EXIT # KEEP078=1 — диагностика: мир остаётся для вскрытия
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
unset GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_AUTHOR_DATE \
      GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL GIT_COMMITTER_DATE

g() { # явная identity на каждом вызове (env-изоляция 068)
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" -c commit.gpgsign=false -c core.hooksPath=/dev/null \
     -c user.name=Фикстура -c user.email=fixture@local "$@"
}

# Случайные значения: SEED — локальный артефакт toy (выдача = SEED+1), ACT* — активные
# соседи на origin, RES — резерв, R — хвосты причин (инвариантность к значениям).
mapfile -t RD < <(python3 - <<'PY'
import random
pool = random.sample(range(985, 1000), 8)
print("%03d" % pool[0]); print("%03d" % pool[1]); print("%03d" % pool[2])
print("%03d" % pool[3]); print("%03d" % pool[4]); print("%03d" % pool[5])
print("%d" % random.randint(10000000, 99999999)); print("%d" % random.randint(10000000, 99999999))
PY
)
SEED="${RD[0]}"; ACT1="${RD[1]}"; ACT2="${RD[2]}"; ACT3="${RD[3]}"; EXC="${RD[4]}"; RES="${RD[5]}"
RH1="${RD[6]}"; RH2="${RD[7]}"
REASON_OK="РАЗРЕШИЛ-ВЛАДЕЛЕЦ: сверх лимита — слово владельца 2026-10-02/${RH1}"
REASON_NO="РАЗРЕШИЛ-ВЛАДЕЛЕЦ: иная причина ${RH2}"

RED=0; GRN=0; NORUN=0
declare -a REPS=()
fail()   { RED=$((RED+1));   REPS+=("$1: КРАСНАЯ — $2"); }
pass()   { GRN=$((GRN+1));   REPS+=("$1: ЗЕЛЁНАЯ"); }
norun()  { NORUN=$((NORUN+1)); REPS+=("$1: НЕ ИСПОЛНЯЛАСЬ (л0 красная — предмет отсутствует)"); }

# ── конструкторы миров ─────────────────────────────────────────────────────────
bare_of() { printf '%s-origin.git' "${1%/}"; }

# mk_next_toy <каталог>: рабочий клон с seed-артефактом <SEED> (локальный тег
# id/CONTRACT/<SEED>) и ПУСТЫМ bare-origin (push main; тег не пушится).
mk_next_toy() {
  local t="$1" b
  b="$(bare_of "$t")"
  mkdir -p "$t/contracts"
  printf '# seed-артефакт фикстуры\n' > "$t/contracts/${SEED}-seed.md"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$t"
  # Локальная identity ФАЙЛОМ конфига (Н-12): субъект next_id.sh зовёт `git tag` БЕЗ -c —
  # в герметичном окружении без user.name он падает «empty ident name», и клетка краснела
  # бы дефектом окружения, а не предметом.
  git -C "$t" config user.name Фикстура
  git -C "$t" config user.email fixture@local
  g "$t" add -A
  g "$t" commit -q -m 'основание: seed-артефакт'
  g "$t" tag -a "id/CONTRACT/$SEED" -m 'выдача механизмом (фикстура: seed)'
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q --bare "$b"
  git -C "$b" symbolic-ref HEAD refs/heads/main
  g "$t" remote add origin "$b"
  g "$t" push -q origin main
}

# Активные — ПРЯМО В BARE (локальные refs клона не знают их без fetch): Н-160 —
# теги/ветки вешаются на УЖЕ запушенные коммиты (коммиты → тег).
bare_frozen() { g "$(bare_of "$1")" tag -a "frozen/contracts/$2/1" -m "фикстура: активный $2" "$(git -C "$(bare_of "$1")" rev-parse refs/heads/main)"; }
bare_done()   { g "$(bare_of "$1")" tag -a "done/contracts/$2/1" -m "фикстура: закрыт $2" "$(git -C "$(bare_of "$1")" rev-parse refs/heads/main)"; }
bare_wip()    { g "$(bare_of "$1")" branch "wip/$2/fixture$RH1" refs/heads/main; }
bare_id()     { g "$(bare_of "$1")" tag -a "id/CONTRACT/$2" -m 'выдача механизмом (фикстура: резерв на origin)' "$(git -C "$(bare_of "$1")" rev-parse refs/heads/main)"; }

# sync_tags <toy>: подтянуть теги origin в локаль. Мирам ПИСАТЕЛЕЙ (mint_line — живая
# дверь 031, freeze_contract — реестр писателя) нужна полнота registry_state 'frozen/'
# (missing-remote = отказ по ЧУЖОМУ предмету); стаб-миры (мини-ядро + стаб-А «источник
# локальные refs») остаются БЕЗ fetch — локальная пустота и есть наблюдаемость дефекта.
sync_tags() { GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$1" fetch -q --tags origin; }

# mk_freeze_toy <каталог>: каркас семьи freeze_contract (контракт 001 + вердикт
# accept + вакуумный CI-паритет) + bare-origin с запушенным main — заморозка 001
# проходит все гейты 036/038/043, предмет клетки — только лимит.
mk_freeze_toy() {
  local t="$1" b
  b="$(bare_of "$t")"
  mkdir -p "$t/contracts" "$t/verdicts/critic" "$t/.github/workflows" "$t/config"
  printf 'предмет, критерий готовности, РАБОТА НЕ РАЗДАЁТСЯ: кодификация\n' > "$t/contracts/001-x.md"
  printf 'accept\nтело вердикта\n' > "$t/verdicts/critic/contracts-001-v1.md"
  printf 'name: ci\non: push\njobs: {}\n' > "$t/.github/workflows/ci.yml"
  printf '{"scripts": {}}\n' > "$t/package.json"
  : > "$t/config/ci_parity_exceptions.txt"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$t"
  git -C "$t" config user.name Фикстура
  git -C "$t" config user.email fixture@local
  git -C "$t" config commit.gpgsign false
  git -C "$t" config core.hooksPath /dev/null
  g "$t" add -A
  g "$t" commit -q -m 'основание'
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q --bare "$b"
  git -C "$b" symbolic-ref HEAD refs/heads/main
  g "$t" remote add origin "$b"
  g "$t" push -q origin main
}

# mk_mint_toy <каталог>: mk_toy семьи 068 дословно (зона orchestrator через HANDOFF,
# манифест, ЖИВАЯ дверь 031 через копию scripts — каталог хука ВНЕ toy).
BARRIER="$WORK/subj-scripts-mint"
cp -r "$ROOT/scripts" "$BARRIER"
mk_mint_toy() {
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
  orig="$(bare_of "$t")"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q --bare "$orig"
  git -C "$orig" symbolic-ref HEAD refs/heads/main
  g "$t" remote add origin "$orig"
  g "$t" push -q origin main
  hookdir="$WORK/hookdir-$(basename "$t")"
  mkdir -p "$hookdir"
  printf '#!/bin/sh\nexec bash "%s/check_staged.sh" "%s"\n' "$BARRIER" "$t" > "$hookdir/pre-commit"
  chmod +x "$hookdir/pre-commit"
  git -C "$t" config core.hooksPath "$hookdir"
}
authority_tag() { # аннотированный тег + пуш на origin (строку НЕ пишет) — 068
  g "$1" tag -a "id/CONTRACT/$2" -m 'выдача механизмом (фикстура: авторитетная половина)'
  g "$1" push -q origin "refs/tags/id/CONTRACT/$2"
}

# ── л0: предмет присутствует и несёт лимит на всех трёх входах ────────────────
# Инвариант: # ИНВ: И-3, И-4 (fail-fast: молчание = предмет отсутствует)
T1="$WORK/l1-$RH1"; mk_next_toy "$T1"; bare_frozen "$T1" "$ACT1"; bare_frozen "$T1" "$ACT2"
out_ni="$("$SUBJ_NEXT" "$T1" CONTRACT 2>"$WORK/e-ni")"; rc_ni=$?; err_ni="$(cat "$WORK/e-ni")"

T7="$WORK/l7-$RH1"; mk_mint_toy "$T7"; authority_tag "$T7" "$ACT3"; bare_frozen "$T7" "$ACT1"; bare_frozen "$T7" "$ACT2"; sync_tags "$T7"
head7="$(git -C "$T7" rev-parse HEAD)"
out_ml="$("$SUBJ_MINT" --root "$T7" --nnn "$ACT3" 2>"$WORK/e-ml")"; rc_ml=$?; err_ml="$(cat "$WORK/e-ml")"

T10="$WORK/l10-$RH1"; mk_freeze_toy "$T10"; bare_frozen "$T10" "$ACT1"; bare_frozen "$T10" "$ACT2"; sync_tags "$T10"
out_fr="$(cd / && "$SUBJ_FREEZE" contracts/001-x.md "причина фикстуры $RH1" "$T10" 2>"$WORK/e-fr")"; rc_fr=$?; err_fr="$(cat "$WORK/e-fr")"

LIM_NAME='лимит активных'
if [ "$rc_ni" -eq 1 ] && printf '%s' "$err_ni" | grep -qF "$LIM_NAME" \
   && [ "$rc_ml" -eq 1 ] && printf '%s' "$err_ml" | grep -qF "$LIM_NAME" \
   && [ "$rc_fr" -eq 1 ] && printf '%s' "$err_fr" | grep -qF "$LIM_NAME"; then
  pass л0
  PRESENT=1
else
  fail л0 "предмет отсутствует: next_id rc=$rc_ni err=$(printf '%s' "$err_ni" | sed -n 1p); mint rc=$rc_ml err=$(printf '%s' "$err_ml" | sed -n 1p); freeze rc=$rc_fr err=$(printf '%s' "$err_fr" | sed -n 1p) — субъекты молчат на трёх входах лимита"
  PRESENT=0
fi

# ── честные клетки next_id (л1–л6, л15) ───────────────────────────────────────
if [ "$PRESENT" -eq 1 ]; then
  # л1: 2 frozen на origin → отказ, тег не создан, stdout пуст. # ИНВ: И-3
  tags1="$(git -C "$T1" tag -l 'id/CONTRACT/*' | wc -l)"
  if [ "$rc_ni" -eq 1 ] && printf '%s' "$err_ni" | grep -qF "$LIM_NAME" \
     && [ -z "$out_ni" ] && [ "$tags1" -eq 1 ]; then pass л1
  else fail л1 "rc=$rc_ni out=$out_ni тегов id=$tags1 (ожидалось 1 — только seed)"; fi

  # л2: 1 frozen → номер выдан, тег создан. # ИНВ: И-3
  T2="$WORK/l2-$RH2"; mk_next_toy "$T2"; bare_frozen "$T2" "$ACT1"
  want2="$(printf '%03d' $((10#$SEED + 1)))"
  out2="$("$SUBJ_NEXT" "$T2" CONTRACT 2>"$WORK/e2")"; rc2=$?
  tags2="$(git -C "$T2" tag -l 'id/CONTRACT/*' | wc -l)"
  if [ "$rc2" -eq 0 ] && [ "$out2" = "$want2" ] && [ "$tags2" -eq 2 ]; then pass л2
  else fail л2 "rc=$rc2 out=$out2 want=$want2 тегов id=$tags2"; fi

  # л3: 2 frozen + строка владельца → номер выдан, stderr «снято строкой владельца». # ИНВ: И-5
  T3="$WORK/l3-$RH1"; mk_next_toy "$T3"; bare_frozen "$T3" "$ACT1"; bare_frozen "$T3" "$ACT2"
  out3="$("$SUBJ_NEXT" "$T3" CONTRACT --reason "$REASON_OK" 2>"$WORK/e3")"; rc3=$?; err3="$(cat "$WORK/e3")"
  if [ "$rc3" -eq 0 ] && [ "$out3" = "$want2" ] && printf '%s' "$err3" | grep -qF 'снято строкой владельца'; then pass л3
  else fail л3 "rc=$rc3 out=$out3 err=$(printf '%s' "$err3" | sed -n 1p)"; fi

  # л3б (негативная пара л3): «РАЗРЕШИЛ-ВЛАДЕЛЕЦ:» без « сверх лимита» → отказ остаётся. # ИНВ: И-5
  out3b="$("$SUBJ_NEXT" "$T3" CONTRACT --reason "$REASON_NO" 2>"$WORK/e3b")"; rc3b=$?; err3b="$(cat "$WORK/e3b")"
  if [ "$rc3b" -eq 1 ] && printf '%s' "$err3b" | grep -qF "$LIM_NAME" && [ -z "$out3b" ]; then pass л3б
  else fail л3б "rc=$rc3b out=$out3b err=$(printf '%s' "$err3b" | sed -n 1p)"; fi

  # л4: 2 frozen, у одного done → активен 1 → выдача. # ИНВ: И-6
  T4="$WORK/l4-$RH2"; mk_next_toy "$T4"; bare_frozen "$T4" "$ACT1"; bare_frozen "$T4" "$ACT2"; bare_done "$T4" "$ACT2"
  out4="$("$SUBJ_NEXT" "$T4" CONTRACT 2>"$WORK/e4")"; rc4=$?
  if [ "$rc4" -eq 0 ] && [ "$out4" = "$want2" ]; then pass л4
  else fail л4 "rc=$rc4 out=$out4 err=$(sed -n 1p "$WORK/e4")"; fi

  # л5: 2 wip-ветки на origin, frozen нет → отказ. # ИНВ: И-6
  T5="$WORK/l5-$RH1"; mk_next_toy "$T5"; bare_wip "$T5" "$ACT1"; bare_wip "$T5" "$ACT2"
  out5="$("$SUBJ_NEXT" "$T5" CONTRACT 2>"$WORK/e5")"; rc5=$?; err5="$(cat "$WORK/e5")"
  if [ "$rc5" -eq 1 ] && printf '%s' "$err5" | grep -qF "$LIM_NAME" && [ -z "$out5" ]; then pass л5
  else fail л5 "rc=$rc5 out=$out5 err=$(printf '%s' "$err5" | sed -n 1p)"; fi

  # л6: резерв id/CONTRACT/<RES> на origin не активен; 1 frozen → выдача. # ИНВ: И-6
  T6="$WORK/l6-$RH2"; mk_next_toy "$T6"; bare_id "$T6" "$RES"; bare_frozen "$T6" "$ACT1"
  out6="$("$SUBJ_NEXT" "$T6" CONTRACT 2>"$WORK/e6")"; rc6=$?
  if [ "$rc6" -eq 0 ] && [ "$out6" = "$want2" ]; then pass л6
  else fail л6 "rc=$rc6 out=$out6 err=$(sed -n 1p "$WORK/e6")"; fi

  # л15: origin на мёртвом пути → fail-closed «авторитет недоступен», тег не создан. # ИНВ: И-2
  T15="$WORK/l15-$RH1"; mk_next_toy "$T15"
  g "$T15" remote set-url origin "$WORK/mrt-$RH2/repo.git"
  out15="$("$SUBJ_NEXT" "$T15" CONTRACT 2>"$WORK/e15")"; rc15=$?; err15="$(cat "$WORK/e15")"
  tags15="$(git -C "$T15" tag -l 'id/CONTRACT/*' | wc -l)"
  if [ "$rc15" -eq 1 ] && printf '%s' "$err15" | grep -qF "$LIM_NAME" \
     && printf '%s' "$err15" | grep -qF 'авторитет недоступен' && [ "$tags15" -eq 1 ] && [ -z "$out15" ]; then pass л15
  else fail л15 "rc=$rc15 out=$out15 тегов id=$tags15 err=$(printf '%s' "$err15" | sed -n 1p)"; fi

  # ── честные клетки mint_line (л7–л9) ────────────────────────────────────────
  # л7: 2 frozen → отказ, HEAD не двинут, дерево чисто, строки нет. # ИНВ: И-3
  lines7="$(git -C "$T7" cat-file -p HEAD:registry/contracts.tsv | grep -cF "$ACT3 → " || true)"
  dirty7="$(git -C "$T7" status --porcelain)"
  head7b="$(git -C "$T7" rev-parse HEAD)"
  if [ "$rc_ml" -eq 1 ] && printf '%s' "$err_ml" | grep -qF "$LIM_NAME" \
     && [ "$lines7" -eq 0 ] && [ "$head7b" = "$head7" ] && [ -z "$dirty7" ]; then pass л7
  else fail л7 "rc=$rc_ml строк=$lines7 head_двинулся=$([ "$head7b" = "$head7" ] && echo нет || echo да) dirty=${dirty7:-чисто}"; fi

  # л7б: минтимый NNN сам активен (frozen) + ещё один frozen → отказ: вычитать --nnn
  # из активных нельзя (исключение И-4 — только freeze); вычитающая реализация
  # пропустит (1 активный) и станет красной здесь. # ИНВ: И-3
  T7b="$WORK/l7b-$RH2"; mk_mint_toy "$T7b"; authority_tag "$T7b" "$ACT3"; bare_frozen "$T7b" "$ACT3"; bare_frozen "$T7b" "$ACT1"; sync_tags "$T7b"
  h7b="$(git -C "$T7b" rev-parse HEAD)"
  out7b="$("$SUBJ_MINT" --root "$T7b" --nnn "$ACT3" 2>"$WORK/e7b")"; rc7b=$?; err7b="$(cat "$WORK/e7b")"
  lines7b="$(git -C "$T7b" cat-file -p HEAD:registry/contracts.tsv | grep -cF "$ACT3 → " || true)"
  dirty7b="$(git -C "$T7b" status --porcelain)"
  if [ "$rc7b" -eq 1 ] && printf '%s' "$err7b" | grep -qF "$LIM_NAME" && [ -z "$out7b" ] \
     && [ "$lines7b" -eq 0 ] && [ "$(git -C "$T7b" rev-parse HEAD)" = "$h7b" ] && [ -z "$dirty7b" ]; then pass л7б
  else fail л7б "rc=$rc7b out=$out7b err=$(printf '%s' "$err7b" | sed -n 1p)"; fi

  # л8: 1 frozen → MINTED. # ИНВ: И-3
  T8="$WORK/l8-$RH2"; mk_mint_toy "$T8"; authority_tag "$T8" "$ACT3"; bare_frozen "$T8" "$ACT1"; sync_tags "$T8"
  out8="$("$SUBJ_MINT" --root "$T8" --nnn "$ACT3" 2>"$WORK/e8")"; rc8=$?
  if [ "$rc8" -eq 0 ] && printf '%s' "$out8" | grep -qF "MINTED nnn=$ACT3"; then pass л8
  else fail л8 "rc=$rc8 out=$out8 err=$(sed -n 1p "$WORK/e8")"; fi

  # л9: 2 frozen + строка владельца → MINTED. # ИНВ: И-5
  T9="$WORK/l9-$RH1"; mk_mint_toy "$T9"; authority_tag "$T9" "$ACT3"; bare_frozen "$T9" "$ACT1"; bare_frozen "$T9" "$ACT2"; sync_tags "$T9"
  out9="$("$SUBJ_MINT" --root "$T9" --nnn "$ACT3" --reason "$REASON_OK" 2>"$WORK/e9")"; rc9=$?
  if [ "$rc9" -eq 0 ] && printf '%s' "$out9" | grep -qF "MINTED nnn=$ACT3"; then pass л9
  else fail л9 "rc=$rc9 out=$out9 err=$(sed -n 1p "$WORK/e9")"; fi

  # л9б (негативная пара л9, свой чистый мир — л9 уже записала строку): строка
  # владельца без « сверх лимита» → отказ остаётся, stdout пуст. # ИНВ: И-5
  T9b="$WORK/l9b-$RH2"; mk_mint_toy "$T9b"; authority_tag "$T9b" "$ACT3"; bare_frozen "$T9b" "$ACT1"; bare_frozen "$T9b" "$ACT2"; sync_tags "$T9b"
  out9b="$("$SUBJ_MINT" --root "$T9b" --nnn "$ACT3" --reason "$REASON_NO" 2>"$WORK/e9b")"; rc9b=$?; err9b="$(cat "$WORK/e9b")"
  if [ "$rc9b" -eq 1 ] && printf '%s' "$err9b" | grep -qF "$LIM_NAME" && [ -z "$out9b" ]; then pass л9б
  else fail л9б "rc=$rc9b out=$out9b err=$(printf '%s' "$err9b" | sed -n 1p)"; fi

  # ── честные клетки freeze (л10–л14) ─────────────────────────────────────────
  # л10: 2 frozen ≠001 → отказ, тега нет, реестр не тронут. # ИНВ: И-4
  tags10="$(git -C "$T10" tag -l 'frozen/contracts/001/*' | wc -l)"
  reg10="$(git -C "$T10" cat-file -p HEAD:registry/contracts.tsv 2>/dev/null || printf 'нет\n')"
  if [ "$rc_fr" -eq 1 ] && printf '%s' "$err_fr" | grep -qF "$LIM_NAME" && [ "$tags10" -eq 0 ]; then pass л10
  else fail л10 "rc=$rc_fr тегов 001=$tags10 err=$(printf '%s' "$err_fr" | sed -n 1p)"; fi

  # л11: 1 frozen ≠001 → v1. # ИНВ: И-4
  T11="$WORK/l11-$RH2"; mk_freeze_toy "$T11"; bare_frozen "$T11" "$ACT1"; sync_tags "$T11"
  out11="$(cd / && "$SUBJ_FREEZE" contracts/001-x.md "причина фикстуры $RH2" "$T11" 2>"$WORK/e11")"; rc11=$?
  if [ "$rc11" -eq 0 ] && [ "$out11" = 'v1' ]; then pass л11
  else fail л11 "rc=$rc11 out=$out11 err=$(sed -n 1p "$WORK/e11")"; fi

  # л12: 2 frozen + строка владельца в причине → v1. # ИНВ: И-5
  T12="$WORK/l12-$RH1"; mk_freeze_toy "$T12"; bare_frozen "$T12" "$ACT1"; bare_frozen "$T12" "$ACT2"; sync_tags "$T12"
  out12="$(cd / && "$SUBJ_FREEZE" contracts/001-x.md "$REASON_OK" "$T12" 2>"$WORK/e12")"; rc12=$?
  if [ "$rc12" -eq 0 ] && [ "$out12" = 'v1' ]; then pass л12
  else fail л12 "rc=$rc12 out=$out12 err=$(sed -n 1p "$WORK/e12")"; fi

  # л12б (негативная пара л12, свой чистый мир — л12 уже заморозил 001): причина
  # «РАЗРЕШИЛ-ВЛАДЕЛЕЦ:» без « сверх лимита» → отказ остаётся, тега нет. # ИНВ: И-5
  T12b="$WORK/l12b-$RH2"; mk_freeze_toy "$T12b"; bare_frozen "$T12b" "$ACT1"; bare_frozen "$T12b" "$ACT2"; sync_tags "$T12b"
  out12b="$(cd / && "$SUBJ_FREEZE" contracts/001-x.md "$REASON_NO" "$T12b" 2>"$WORK/e12b")"; rc12b=$?; err12b="$(cat "$WORK/e12b")"
  if [ "$rc12b" -eq 1 ] && printf '%s' "$err12b" | grep -qF "$LIM_NAME" && [ -z "$out12b" ] \
     && [ "$(git -C "$T12b" tag -l 'frozen/contracts/001/*' | wc -l)" -eq 0 ]; then pass л12б
  else fail л12б "rc=$rc12b out=$out12b тегов 001=$(git -C "$T12b" tag -l 'frozen/contracts/001/*' | wc -l) err=$(printf '%s' "$err12b" | sed -n 1p)"; fi

  # л13: активен только сам 001 (wip/001 на origin) → v1. # ИНВ: И-4
  T13="$WORK/l13-$RH2"; mk_freeze_toy "$T13"; g "$(bare_of "$T13")" branch 'wip/001/fixture' refs/heads/main
  out13="$(cd / && "$SUBJ_FREEZE" contracts/001-x.md "причина фикстуры $RH2" "$T13" 2>"$WORK/e13")"; rc13=$?
  if [ "$rc13" -eq 0 ] && [ "$out13" = 'v1' ]; then pass л13
  else fail л13 "rc=$rc13 out=$out13 err=$(sed -n 1p "$WORK/e13")"; fi

  # л14: сам 001 (wip) + 2 frozen ≠001 → rc 1 (вычтен только замораживаемый). # ИНВ: И-4
  T14="$WORK/l14-$RH1"; mk_freeze_toy "$T14"; g "$(bare_of "$T14")" branch 'wip/001/fixture' refs/heads/main; bare_frozen "$T14" "$ACT1"; bare_frozen "$T14" "$ACT2"; sync_tags "$T14"
  out14="$(cd / && "$SUBJ_FREEZE" contracts/001-x.md "причина фикстуры $RH2" "$T14" 2>"$WORK/e14")"; rc14=$?; err14="$(cat "$WORK/e14")"
  if [ "$rc14" -eq 1 ] && printf '%s' "$err14" | grep -qF "$LIM_NAME"; then pass л14
  else fail л14 "rc=$rc14 out=$out14 err=$(printf '%s' "$err14" | sed -n 1p)"; fi

  # л14б (пограничная различающая вычет субъекта): сам 001 (wip) + ОДИН frozen →
  # честный вычет сам → 1 активный → v1; невычитающая реализация видит 2 → rc 1. # ИНВ: И-4
  T14b="$WORK/l14b-$RH2"; mk_freeze_toy "$T14b"; g "$(bare_of "$T14b")" branch 'wip/001/fixture' refs/heads/main; bare_frozen "$T14b" "$ACT1"; sync_tags "$T14b"
  out14b="$(cd / && "$SUBJ_FREEZE" contracts/001-x.md "причина фикстуры $RH2" "$T14b" 2>"$WORK/e14b")"; rc14b=$?
  if [ "$rc14b" -eq 0 ] && [ "$out14b" = 'v1' ]; then pass л14б
  else fail л14б "rc=$rc14b out=$out14b err=$(sed -n 1p "$WORK/e14b") — вычет замораживаемого не доказан: невычитающая реализация даёт здесь rc 1"; fi
else
  for c in л1 л2 л3 л3б л4 л5 л6 л7 л7б л8 л9 л9б л10 л11 л12 л12б л13 л14 л14б л15; do norun "$c"; done
fi

# ── стаб-пак: мутантные копии мини-ядра (самодостаточен — не зависит от субъекта) ──
mk_stub() { # mk_stub <А|Б|В|Г|Д|Е> <путь-копии>: одна замена одной строки по маркеру
  python3 - "$1" "$CORE" "$2" <<'PY'
import sys
which, src, dst = sys.argv[1], sys.argv[2], sys.argv[3]
repl = {
 "А": ('ВЕТВЬ:LSREMOTE',
   "refs=\"$(git -C \"$root\" for-each-ref --format='%(objectname) %(refname)' "
   "'refs/tags/frozen/contracts/*' 'refs/tags/done/contracts/*' 'refs/heads/wip/*' "
   "2>/dev/null)\" || ls_rc=$? # ВЕТВЬ:LSREMOTE — СТАБ-А (источник: локальные refs)"),
 "Б": ('ВЕТВЬ:DONE', "    # ВЕТВЬ:DONE — СТАБ-Б (done не вычитается)"),
 "В": ('ВЕТВЬ:WIP',  "    # ВЕТВЬ:WIP — СТАБ-В (wip-ветки не считаются)"),
 "Г": ('ВЕТВЬ:REASON',
   "[ \"$reason\" = \"-\" ] || case \"$reason\" in *'РАЗРЕШИЛ-ВЛАДЕЛЕЦ:'*) "
   "printf '  ok   лимит активных контрактов: активных %s, снято строкой владельца\\n' \"$n\" >&2; exit 0 ;; esac "
   "# ВЕТВЬ:REASON — СТАБ-Г (широкий матчинг любой строки владельца)"),
 "Д": ('ВЕТВЬ:EXCEPT', ": # ВЕТВЬ:EXCEPT — СТАБ-Д (замораживаемый не вычитается)"),
 "Е": ('ВЕТВЬ:NETFAIL', ": # ВЕТВЬ:NETFAIL — СТАБ-Е (сеть = пропуск)"),
}
marker, line = repl[which]
out, hit = [], 0
for l in open(src, encoding='utf-8'):
    if marker in l and ' — СТАБ-' not in l:
        out.append(line + "\n"); hit += 1
    else:
        out.append(l)
assert hit == 1, f"маркер {marker} встречен {hit} раз (ожидался 1)"
open(dst, 'w', encoding='utf-8').write(''.join(out))
PY
}

# ЯДРО-КОНТРОЛЬ: честное мини-ядро на чистом мире — rc 0 (иначе весь стаб-пак нечестен).
TS0="$WORK/ts0-$RH1"; mk_next_toy "$TS0"
core0=0; bash "$CORE" "$TS0" - - >/dev/null 2>&1 || core0=$?
if [ "$core0" -eq 0 ]; then pass ядро0; else fail ядро0 "честное ядро отказало на чистом мире rc=$core0"; fi

# Генерация шести стабов + две меры применения (cmp ∧ grep -F).
declare -A STUB_PATH=()
for s in А Б В Г Д Е; do
  p="$WORK/stub$s.sh"
  if mk_stub "$s" "$p" 2>"$WORK/e-stub$s" \
     && ! cmp -s "$CORE" "$p" \
     && grep -qF "СТАБ-$s" "$p"; then
    STUB_PATH[$s]="$p"; pass "стаб$s-применён"
  else
    fail "стаб$s-применён" "мутация не применилась/не помечена: $(sed -n 1p "$WORK/e-stub$s" 2>/dev/null)"
  fi
done

# Диффпробы: стаб на чистом мире rc 0 (параноик ловится здесь).
for s in А Б В Г Д Е; do
  [ -n "${STUB_PATH[$s]:-}" ] || continue
  rc=0; bash "${STUB_PATH[$s]}" "$TS0" - - 2>"$WORK/d$s" >/dev/null || rc=$?
  if [ "$rc" -eq 0 ]; then pass "дифф$s"
  else fail "дифф$s" "стаб параноик: чистый мир rc=$rc: $(sed -n 1p "$WORK/d$s") [стаб=${STUB_PATH[$s]} мир=$TS0 remote=$(git -C "$TS0" remote get-url origin 2>&1)]"; fi
done

# Нарушения: честное ядро и стаб на входе наблюдаемости дефекта (таблица Н-39 контракта).
viol() { # viol <стаб> <мир> <except> <reason> <ядро-rc> <стаб-rc>
  local s="$1" world="$2" exc="$3" rsn="$4" wrc="$5" swant="$6" crc=0 src=0
  bash "$CORE" "$world" "$exc" "$rsn" >/dev/null 2>&1 || crc=$?
  bash "${STUB_PATH[$s]}" "$world" "$exc" "$rsn" >/dev/null 2>&1 || src=$?
  if [ "$crc" -eq "$wrc" ] && [ "$src" -eq "$swant" ]; then pass "наруш$s"
  else fail "наруш$s" "ядро rc=$crc (хотели $wrc), стаб rc=$src (хотели $swant) — стаб не обманут на своём входе"; fi
}
TA="$WORK/ta-$RH1"; mk_next_toy "$TA"; bare_frozen "$TA" "$ACT1"; bare_frozen "$TA" "$ACT2" # 2 frozen только на origin
TB="$WORK/tb-$RH2"; mk_next_toy "$TB"; bare_frozen "$TB" "$ACT1"; bare_frozen "$TB" "$ACT2"; bare_done "$TB" "$ACT2" # done закрывает одного
TV="$WORK/tv-$RH1"; mk_next_toy "$TV"; bare_wip "$TV" "$ACT1"; bare_wip "$TV" "$ACT2" # 2 wip
TE="$WORK/te-$RH2"; mk_next_toy "$TE"; g "$TE" remote set-url origin "$WORK/mrt2-$RH1/x.git" # мёртвый origin
viol А "$TA" - - 1 0
viol Б "$TB" - - 0 1
viol В "$TV" - - 1 0
viol Г "$TA" - "$REASON_NO" 1 0
viol Д "$TA" "$ACT1" - 0 1 # TA: 2 frozen (ACT1, ACT2), вычтен замораживаемый ACT1 → честно активен 1 → rc 0; стаб-Д не вычтен → видит 2 → rc 1
viol Е "$TE" - - 3 0

for r in "${REPS[@]}"; do printf 'КРАСНОЕ 078: %s\n' "$r" >&2; done
if [ "$PRESENT" -eq 0 ]; then
  printf 'КРАСНОЕ 078: л0: предмет отсутствует — субъекты молчат на трёх входах лимита; предъявляемое красное ДО реализации\n' >&2
fi
printf 'ИТОГ 078 (лимит активных): честных ветвей 22 (л0–л15, включая л3б, л7б, л9б, л12б, л14б, + ядро0), стабов 6, применений 6, диффпроб 6, нарушений 6; красных %d, зелёных %d, не исполнено %d\n' "$RED" "$GRN" "$NORUN" >&2
[ "$RED" -eq 0 ] || exit 1
exit 0
