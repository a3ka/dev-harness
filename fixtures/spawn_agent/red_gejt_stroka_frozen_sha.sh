#!/usr/bin/env bash
# КРАСНОЕ регресса 036-г5б (8575353, owner-канал 56ec133): freeze_contract.sh на успехе
# пишет строку реестра «NNN → <sha>» с FROZEN tag-object-sha (frozen/contracts/<NNN>/<v>),
# ПЕРЕЗАПИСЫВАЯ минт-строку (freeze_contract.sh:337-341). Страж 3в spawn_agent.sh свери-
# вает строку ТОЛЬКО с минт-тегом id/CONTRACT/<NNN> (:148,:176-181) → после заморозки
# честная frozen-строка даёт MISMATCH «sha манифеста ≠ sha тега на origin (3в)» → спавн по
# --nnn <замороженный> НЕВОЗМОЖЕН. Живой свидетель (2026-09-21): `spawn_agent.sh --author
# architect --nnn 036` → ОТКАЗ 3в при живых тегах id/CONTRACT/036 и frozen/contracts/036/4.
# Корень — столкновение семантик одной строки (правило 5): 023 пиннил минт-sha, 036-г5б
# пишет frozen-sha; реестр ЖИВОЙ смешанный (001–035 минт, 036+ frozen).
#
# ДОГОВОР ЧЕСТНОГО ГЕЙТА (дизайн «а» из направления владельца 2026-09-21 «spawn принимает
# frozen-sha / реестр несёт оба»; выбор — отчёт architect): строка NNN санкционирована,
# если её sha = tag-object-sha ЛЮБОГО тега НОМЕРА NNN на origin: id/CONTRACT/<NNN> (минт,
# 023) ∪ frozen/contracts/<NNN>/* (заморозка, 036-г5б). Посторонний 40-hex — даже насто-
#ящий тег-объект ДРУГОГО номера на origin — санкцией НЕ является. Повторный минт после
# frozen-строки сходится: переминт id/CONTRACT/<NNN> не меняет строку и не трогает frozen-
# тег → строка остаётся во множестве тегов NNN.
#
# Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (А-82, прецедент red_gejt_*): до реализации
# предмет предъявляется ПРЯМЫМ запуском; конверсия в case_* — пачка architect ПОСЛЕ
# реализации. Порядок проб: зелёные контроли (ф1, ф2) ДО красного предъявления (ф3) —
# один прогон на сегодняшнем дереве показывает все три поведения.
#
# ВХОДЫ (метки ф1/ф2/ф3 локальны для файла; Н-39 — привязка стабов по КОДУ
# spawn_agent.sh, не по прозе контракта):
#   ф1 минт-строка (положительный контроль, регресс-контроль 023): полный резерв
#      mint_rezerv N3 (тег + строка «N3 → <минт-sha>» на origin/main) → rc 0,
#      WORKTREE/BRANCH=wip/N3/architect. ЗЕЛЁНОЕ ДО и ПОСЛЕ (гейт не свёрхблокирующий:
#      минт-семантика незамороженных строк жива). Стаб «гейт требует frozen-строку
#      всегда» умирает здесь;
#   ф2 подмена чужим sha (дверь dual-control не ослаблена): резерв N1 и N2, затем строка
#      N1 перезаписана НАСТОЯЩИМ tag-object-sha тега id/CONTRACT/N2 (жив на origin, но —
#      ДРУГОЙ номер; frozen-тегов N1 на origin нет). Честный гейт: rc 1 «не выдан
#      авторитетом» (3в: sha ∉ {id/CONTRACT/N1} ∪ {frozen/contracts/N1/*}). ЗЕЛЁНОЕ ДО и
#      ПОСЛЕ. Стабы «строка совпала с любым тег-объектом origin (без фильтра номера)» и
#      «frozen-строка = безусловный пуск» умирают здесь;
#   ф3 frozen-строка (ПРЕДЪЯВЛЯЕМОЕ КРАСНОЕ, регресс 036-г5б): резерв N1, затем церемония
#      заморозки ПО КОДУ ПИСАТЕЛЯ freeze_contract.sh:314-341 — annotated тег
#      frozen/contracts/N1/1, строка N1 перезаписана его tag-object-sha, оба пуша.
#      Честный гейт: rc 0, WORKTREE/BRANCH=wip/N1/architect (строка = живой frozen-тег NNN
#      на origin = санкция). СЕГОДНЯ стаб «сверка только с минт-тегом» (:178 одно-
#      sha-сравнение) умирает здесь именованной причиной 3в — спавн отказал честной
#      заморозке. КРАСНОЕ.
#
# ДЕМАРКАЦИЯ КОНФОРМНОСТИ (урок 019): все три строки грамматически конформны —
# `^[0-9]{3} → [0-9a-f]{40}$` (031, db3936c), разделитель U+2192, sha — ША ОБЪЕКТА
# аннотированного тега. Валидный контрпример = грамматика соблюдена ∧ вход — легити-
# людное состояние авторитета (церемония 023/036-г5б) ∧ честный гейт и стаб расходятся:
# ф3 расходится на легитимной заморозке, ф2 — на подмене, где расходиться НЕЛЬЗЯ.
#
# ОРАКУЛ В ПАМЯТИ ДО ВЫЗОВА (правило 8): MINT_SHA/FROZEN_SHA/FOREIGN_SHA/ORIGIN_MAIN_SHA/
# MANIFEST_LINE снимаются с authority/origin ДО вызова субъекта; свойства входа проверя-
# ются ДО субъекта (неверно собранный вход — именованный отказ, не молчаливая зелёность);
# диск субъекта после вызова как истина не перечитывается (err — только диагностика).
# Отпечаток входа печатается — два прогона различимы.
#
# ПАРАМЕТРИЗАЦИЯ (вердикт 57c8141 блокер 2; А-88): N1 270-299 · N2 370-399 · N3 400-429 —
# поддиапазоны, свободные ВНУТРИ семьи spawn_agent (red_gejt_javnogo_nomera: 120-269,
# 300-369, 500-939; red_gejt_manifest_tolko_na_origin: 940-999); basename toy-корней и
# каталог-копия субъекта случайны (BARRIER_ROOT-паттерн); приёмка — ДВА прогона подряд
# с разными входами.
#
# Коды возврата: 0 — ворота пройдены (гейт знает frozen-семантику строки); 1 — имено-
#               ванный отказ (вход построен неверно / гейт нарушил договор на пробах).
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
WORK="$(mktemp -d /tmp/red016-frozen.XXXXXX)"   # А-78: свежий WORK вне дерева
trap 'rm -rf "$WORK"' EXIT

# ── случайные входы: ОДИН процесс awk; поддиапазоны см. шапку.
mapfile -t RD < <(awk 'BEGIN{srand();
  printf "%03d\n", 270+int(rand()*30);
  printf "%03d\n", 370+int(rand()*30);
  printf "%03d\n", 400+int(rand()*30);
  for (i=0;i<4;i++) printf "%d\n", 10000000+int(rand()*89999999)}')
N1="${RD[0]}"; N2="${RD[1]}"; N3="${RD[2]}"

# Субъект — копия scripts/ под случайным именем (BARRIER_ROOT-паттерн).
SPAWN="$WORK/subj-${RD[3]}/spawn_agent.sh"
cp -r "$REPO/scripts" "$WORK/subj-${RD[3]}"
# shellcheck disable=SC1091
. "$HERE/_repo.sh"

# run_spawn <toy> <аргументы spawn>… → $out/$rc, worktree убран
run_spawn() {
  local toy="$1"; shift
  out="$(bash "$SPAWN" --root "$toy" "$@" 2>"$WORK/err")" && rc=0 || rc=$?
  local wt
  wt="$(printf '%s\n' "$out" | sed -n 's/^WORKTREE=//p' | head -1)"
  if [ -n "$wt" ] && [ -d "$wt" ]; then rm -rf "$wt"; fi
}

# perezapis_stroki <toy> <NNN> <sha> — перезапись строки NNN в манифесте toy ПО КОДУ
# писателя (freeze_contract.sh:337-341): grep -v старой строки → append новой → mv.
# Идемпотентность та же: одна строка на NNN, дублей нет.
perezapis_stroki() {
  local r="$1" n="$2" sha="$3" tmp
  tmp="$(mktemp)"
  grep -v "^$n → " "$r/registry/contracts.tsv" > "$tmp" 2>/dev/null || true
  printf '%s → %s\n' "$n" "$sha" >> "$tmp"
  mv "$tmp" "$r/registry/contracts.tsv"
  g "$r" add -A
  g "$r" commit -q -m "реестр: строка $n → $sha (фикстура: церемония писателя)"
  g "$r" push -q origin main
}

# ── ф1: минт-строка — прежнее поведение зелёное (регресс-контроль 023) ─────────
T1="$WORK/kor-${RD[3]}"
make_repo "$T1"
ORIG1="$(toy_origin "$T1")"
mint_rezerv "$T1" "$N3"
# оракул в память ДО субъекта (правило 8)
MINT3_SHA="$(git -C "$ORIG1" rev-parse "refs/tags/id/CONTRACT/$N3")"
ORIGIN_MAIN1="$(git -C "$ORIG1" rev-parse refs/heads/main)"
# свойства входа (ДО субъекта): строка на origin/main — СТРУКТУРНО, грамматика 023/031
git -C "$ORIG1" show 'refs/heads/main:registry/contracts.tsv' | grep -Fqx "$N3 → $MINT3_SHA" \
  || { printf 'ОТКАЗ: вход ф1 построен неверно: строки «%s → %s» нет на origin/main\n' "$N3" "$MINT3_SHA" >&2; exit 1; }
fz="$(git -C "$T1" ls-remote origin "refs/tags/frozen/contracts/$N3/*" 2>/dev/null)" && fzrc=0 || fzrc=$?
[ "$fzrc" -eq 0 ] || { printf 'ОТКАЗ: вход ф1 построен неверно: ls-remote origin отказал (rc %s) — пустота ошибки не равна «нет тегов»\n' "$fzrc" >&2; exit 1; }
[ -z "$(printf '%s\n' "$fz" | awk '{print $1}')" ] \
  || { printf 'ОТКАЗ: вход ф1 построен неверно: у N3 есть frozen-теги — вход не минт-чистый\n' >&2; exit 1; }
printf 'отпечаток ф1: N3=%s toy=%s origin=%s origin_main=%s минт=%s\n' \
  "$N3" "$T1" "$ORIG1" "$ORIGIN_MAIN1" "$MINT3_SHA"
run_spawn "$T1" --author architect --nnn "$N3"
if [ "$rc" -ne 0 ] \
   || ! printf '%s\n' "$out" | grep -qF 'WORKTREE=' \
   || ! printf '%s\n' "$out" | grep -qF "BRANCH=wip/$N3/architect"; then
  printf 'ОТКАЗ: ф1 минт-строка обязана пускать (023-семантика незамороженных строк): спавн --nnn %s отказал (rc %s): %s\n' "$N3" "$rc" "$(cat "$WORK/err")" >&2
  exit 1
fi

# ── ф2: подмена чужим sha (дверь dual-control не ослаблена) ────────────────────
# Строка N1 несёт НАСТОЯЩИЙ tag-object-sha — но тега ДРУГОГО номера (id/CONTRACT/N2).
T2="$WORK/kor-$((RD[3]+1))"
make_repo "$T2"
ORIG2="$(toy_origin "$T2")"
mint_rezerv "$T2" "$N1"
mint_rezerv "$T2" "$N2"
FOREIGN_SHA="$(git -C "$ORIG2" rev-parse "refs/tags/id/CONTRACT/$N2")"
perezapis_stroki "$T2" "$N1" "$FOREIGN_SHA"
# свойства входа (ДО субъекта): подменённый sha — живой тег-объект, но НЕ N1; frozen-тегов N1 нет
[ "$FOREIGN_SHA" != "$(git -C "$ORIG2" rev-parse "refs/tags/id/CONTRACT/$N1")" ] \
  || { printf 'ОТКАЗ: вход ф2 построен неверно: «чужой» sha совпал с минт-тегом N1\n' >&2; exit 1; }
fz="$(git -C "$T2" ls-remote origin "refs/tags/frozen/contracts/$N1/*" 2>/dev/null)" && fzrc=0 || fzrc=$?
[ "$fzrc" -eq 0 ] || { printf 'ОТКАЗ: вход ф2 построен неверно: ls-remote origin отказал (rc %s) — пустота ошибки не равна «нет тегов»\n' "$fzrc" >&2; exit 1; }
[ -z "$(printf '%s\n' "$fz" | awk '{print $1}')" ] \
  || { printf 'ОТКАЗ: вход ф2 построен неверно: у N1 есть frozen-теги — подмена не чистая\n' >&2; exit 1; }
git -C "$ORIG2" show 'refs/heads/main:registry/contracts.tsv' | grep -Fqx "$N1 → $FOREIGN_SHA" \
  || { printf 'ОТКАЗ: вход ф2 построен неверно: подменённой строки «%s → %s» нет на origin/main\n' "$N1" "$FOREIGN_SHA" >&2; exit 1; }
[ "$(git -C "$ORIG2" show 'refs/heads/main:registry/contracts.tsv' | grep -c "^$N1 → ")" -eq 1 ] \
  || { printf 'ОТКАЗ: вход ф2 построен неверно: строк N1 в манифесте не одна\n' >&2; exit 1; }
printf 'отпечаток ф2: N1=%s N2=%s toy=%s origin=%s подменённый-sha=%s (тег-объект id/CONTRACT/%s)\n' \
  "$N1" "$N2" "$T2" "$ORIG2" "$FOREIGN_SHA" "$N2"
run_spawn "$T2" --author architect --nnn "$N1"
if [ "$rc" -ne 1 ] || ! grep -qF 'не выдан авторитетом' "$WORK/err"; then
  printf 'ОТКАЗ: ф2 подмена чужим sha обязана отказывать: спавн --nnn %s по строке с тег-объектом ДРУГОГО номера %s ПРОШЁЛ (rc %s, ожидан rc 1 «не выдан авторитетом»): %s\n' "$N1" "$N2" "$rc" "$(cat "$WORK/err")" >&2
  exit 1
fi

# ── ф3: frozen-строка — ПРЕДЪЯВЛЯЕМОЕ КРАСНОЕ (регресс 036-г5б) ────────────────
# Полный резерв N1, затем церемония заморозки ПО КОДУ freeze_contract.sh:314-341:
# annotated тег frozen/contracts/N1/1 + перезапись строки его tag-object-sha + оба пуша.
T3="$WORK/kor-$((RD[3]+2))"
make_repo "$T3"
ORIG3="$(toy_origin "$T3")"
mint_rezerv "$T3" "$N1"
MINT1_SHA="$(git -C "$ORIG3" rev-parse "refs/tags/id/CONTRACT/$N1")"
g "$T3" tag -a "frozen/contracts/$N1/1" -m 'заморозка (фикстура: г5б — строка реестра = frozen tag-object-sha)'
g "$T3" push -q origin "refs/tags/frozen/contracts/$N1/1"
# оракул в память ДО субъекта (правило 8)
FROZEN_SHA="$(git -C "$ORIG3" rev-parse "refs/tags/frozen/contracts/$N1/1")"
perezapis_stroki "$T3" "$N1" "$FROZEN_SHA"
[ "$(git -C "$T3" ls-remote origin "refs/tags/id/CONTRACT/$N1" 2>/dev/null | awk '{print $1}' | head -1)" = "$MINT1_SHA" ] \
  || { printf 'ОТКАЗ: вход ф3 построен неверно: минт-тег N1 не на origin с ожидаемым sha\n' >&2; exit 1; }
[ "$(git -C "$T3" ls-remote origin "refs/tags/frozen/contracts/$N1/1" 2>/dev/null | awk '{print $1}' | head -1)" = "$FROZEN_SHA" ] \
  || { printf 'ОТКАЗ: вход ф3 построен неверно: frozen-тег N1 не на origin с ожидаемым sha\n' >&2; exit 1; }
git -C "$T3" show-ref --verify --quiet "refs/tags/id/CONTRACT/$N1" \
  || { printf 'ОТКАЗ: вход ф3 построен неверно: тег id/CONTRACT/%s не жив локально (шаг 1 гейта)\n' "$N1" >&2; exit 1; }
git -C "$ORIG3" show 'refs/heads/main:registry/contracts.tsv' | grep -Fqx "$N1 → $FROZEN_SHA" \
  || { printf 'ОТКАЗ: вход ф3 построен неверно: frozen-строки «%s → %s» нет на origin/main\n' "$N1" "$FROZEN_SHA" >&2; exit 1; }
[ "$(git -C "$ORIG3" show 'refs/heads/main:registry/contracts.tsv' | grep -c "^$N1 → ")" -eq 1 ] \
  || { printf 'ОТКАЗ: вход ф3 построен неверно: строк N1 в манифесте не одна (перезапись, не дубль)\n' >&2; exit 1; }
printf 'отпечаток ф3: N1=%s toy=%s origin=%s минт=%s frozen=%s\n' \
  "$N1" "$T3" "$ORIG3" "$MINT1_SHA" "$FROZEN_SHA"
run_spawn "$T3" --author architect --nnn "$N1"
if [ "$rc" -ne 0 ] \
   || ! printf '%s\n' "$out" | grep -qF 'WORKTREE=' \
   || ! printf '%s\n' "$out" | grep -qF "BRANCH=wip/$N1/architect"; then
  printf 'ОТКАЗ: ф3 frozen-строка обязана пускать (036-г5б: строка = живой frozen-тег NNN на origin): спавн --nnn %s отказал честной заморозке (rc %s) — регресс 3в: %s\n' "$N1" "$rc" "$(cat "$WORK/err")" >&2
  exit 1
fi

exit 0
