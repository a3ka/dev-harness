#!/usr/bin/env bash
# КРАСНОЕ ФИКС-РАУНДА №3 контракта 022 (единственный блокер c000ed1, вердикт
# verdicts/adversary/contracts-022-v1.md): база исключения диапазона Н-86(б) —
# локальное зеркало refs/remotes/origin/* — НЕ истина. Stale tracking-ref
# (ветка ghost реально удалена с origin, локальный снимок остался) исключает из
# суда красный коммит, НИКОГДА не попадавший на origin в живом ref'е, — обычный
# live push проходит без суда. Инвариант владельца Н-86(б): «каждый устав-коммит
# судится РАЗ при первом попадании на origin, обхода нет»; законное исключение —
# только коммиты, чьи sha достижимы из ref'ов, РЕАЛЬНО живущих на origin в
# момент пуша.
#
# ВХОД (toy, форма «бэкап-пуш мимо хука + удаление ветки на origin напрямую»):
#   основание BASE (замороженный contracts/001-x.md, добавление свободно);
#   живой красный HIST (дельта M без РАЗРЕШИЛ) на origin/main — ОСТАЁТСЯ жить;
#   ветка ghost с красным RED (дельта M без РАЗРЕШИЛ) пушится на origin мимо
#   хука, затем refs/heads/ghost УДАЛЯЕТСЯ на bare напрямую — локальный
#   refs/remotes/origin/ghost остаётся stale = RED;
#   затем ОБЫЧНЫЕ live push'и существующих ref'ов (ненулевой remote_sha):
#   $BR2 (диапазон BASE..TIP2 несёт RED и HIST) — предмет, $BR3 (несёт ТОЛЬКО
#   HIST, без RED) — охрана. Честный гейт ОБЯЗАН: $BR3 — ПРОПУСТИТЬ (живой
#   origin-ref main=HIST исключает законно, случай (б) не сломан), $BR2 —
#   ОТВЕРГНУТЬ тройкой ref+sha+путь при НЕПОДВИЖНОМ origin-рефе.
#
# СТАБ-ВХОД (Н-39 — привязка КОДОМ): «зеркало refs/remotes — истина» — слабая
# форма (б), текущий код .githooks/pre-push:142 (`--not --remotes=origin/*`):
# исключает всё достижимое из локального снимка, доверяя ему как доказательству
# «уже принято origin». Дефект наблюдаем ИМЕННО на этом входе: stale
# refs/remotes/origin/ghost исключает RED, никогда не живший на origin, —
# стаб-пуш $BR2 уезжает зелёно-ложно (фаза 1 требует это наблюдить и откатывает
# посадку — bare-реф И tracking-реф, А-107). На входе
# red_push_istoricheskij_legit_prohodit.sh стаб ведёт себя честно (HIST реально
# жив на origin/main — исключение законно) — его краснота там не наблюдаема и
# не требуется; на входе probe_push_svezhij_sverh_origin_umiraet.sh также
# честен (свежий красный не достижим из зеркала — стаб его судит и отвергает).
#
# ОХРАНА ВНУТРИ (фаза 2): слабая форма «нет исключения вообще» (плоский суд
# всего достижимого) ОТВЕРГАЕТ и легит-пуш $BR3 — файл умирает на охране
# именованной причиной, поэтому зелёность ПОСЛЕ фикса доказывает ИМЕННО грань
# зеркала, а не потерю исключения целиком. Toy охраны НЕ дублирует вход
# red_push_istoricheskij_legit_prohodit.sh: там вход — чистая живая история
# (легит-пуш один); здесь охрана встроена рядом со stale-гранью, чтобы обе
# слабые формы умирали на ОДНОМ входе разными фазами.
#
# ЗЕЛЁНОСТЬ ДОКАЗЫВАЕТ ОБЪЕДИНЕНИЕ (А-107): реализация (база исключения =
# снимок живого origin через ls-remote на старте хука, fail-closed именованным
# отказом при недоступности) идёт ПАРАЛЛЕЛЬНО в ветке implementer (Impl022fix3);
# на ветке architect хук слаб — файл КРАСЕН именованной причиной «обход жив»
# (зелёно-ложная посадка наблюдена и напечатана).
#
# ДВА прогона подряд с разными входами (детерминизм ∧ инвариантность; прецедент
# red_push_istoricheskij_legit_prohodit): случайны ветки, имена файлов, тексты
# дельт; отпечаток входа печатается строками «вход:» — ряды двух прогонов
# обязаны разойтись, вердикт — совпасть. Имя ВНЕ case_*-глоба раннера —
# НАМЕРЕННО (А-82). Прогон — свежий WORK вне дерева (А-78, Н-74).
#
# Коды возврата: 0 — ворота пройдены (после фикса базы исключения);
#               1 — именованный отказ.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
WORK="$(mktemp -d /tmp/red022-stale.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT

HOOK_SRC="$REPO/.githooks/pre-push"
ORIG="$WORK/origin.git"
T="$WORK/toy"

RAND="r$RANDOM$RANDOM"
GHOST="ghost-$RAND"
BR2="vetka-$RAND"
BR3="ohrana-$RAND"
NEUT2="vetka-tip-$RAND.txt"
NEUT3="ohrana-tip-$RAND.txt"
PATH_C='contracts/001-x.md'

eg() {
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}
jg() {
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -c commit.gpgsign=false "$@"
}
oref2() { git -C "$ORIG" rev-parse --verify -q "refs/heads/$BR2" || echo ПУСТО; }
oref3() { git -C "$ORIG" rev-parse --verify -q "refs/heads/$BR3" || echo ПУСТО; }

printf 'вход: RAND=%s ghost=%s vetka=%s ohrana=%s\n' "$RAND" "$GHOST" "$BR2" "$BR3"

install_hook_from() {  # <файл-источник>
  mkdir -p "$T/.githooks"
  cp "$1" "$T/.githooks/pre-push"
  chmod +x "$T/.githooks/pre-push"
  eg -C "$T" config core.hooksPath "$T/.githooks"
}

# ── toy: основание + живой HIST + ghost-красный RED, ставший stale ────────────
mkdir -p "$T/contracts"
git init -q --bare "$ORIG"
git -C "$ORIG" symbolic-ref HEAD refs/heads/main
eg init -q -b main "$T"
eg -C "$T" config user.name Фикстура
eg -C "$T" config user.email fixture@local
printf '# подставной контракт 001 (уставной с заморозки)\n' > "$T/$PATH_C"
eg -C "$T" add -A
eg -C "$T" commit -q -m 'основание: подставной замороженный контракт'
eg -C "$T" tag -a frozen/contracts/001/1 -m 'заморозка'
BASE="$(eg -C "$T" rev-parse main)"
eg -C "$T" remote add origin "$ORIG"
eg -C "$T" push -q origin main

# Живой красный HIST (охрана (б)): устав-дельта M без РАЗРЕШИЛ, ПРИНЯТАЯ на
# origin/main ДО установки хука и остающаяся жить (черпаки легальных итераций).
printf '\nживая историческая дельта %s без строки\n' "$RAND" >> "$T/$PATH_C"
eg -C "$T" add -A
eg -C "$T" commit -q -m "живой owner-коммит: дельта M без РАЗРЕШИЛ ($RAND)"
HIST="$(eg -C "$T" rev-parse main)"
eg -C "$T" push -q origin main

# Красный RED на ветке ghost: бэкап-пуш мимо хука (форма Н-78), затем ветка
# УДАЛЯЕТСЯ на bare напрямую — локальное зеркало refs/remotes/origin/ghost
# остаётся stale. RED никогда не жил на origin в живом ref'е дольше пуша-мимо.
eg -C "$T" branch -q "$GHOST" main
eg -C "$T" checkout -q "$GHOST"
printf '\nstale-дельта %s без строки\n' "$RAND" >> "$T/$PATH_C"
eg -C "$T" add -A
eg -C "$T" commit -q -m "красный коммит ghost: дельта M без РАЗРЕШИЛ ($RAND)"
RED="$(eg -C "$T" rev-parse "$GHOST")"
eg -C "$T" push -q origin "$GHOST"
git -C "$ORIG" update-ref -d "refs/heads/$GHOST"

# Существующие ref'ы $BR2/$BR3 на BASE (обновления → ненулевой remote_sha —
# «обычный live push», форма блокера c000ed1).
eg -C "$T" branch -q "$BR2" "$BASE"
eg -C "$T" push -q origin "$BR2"
eg -C "$T" branch -q "$BR3" "$BASE"
eg -C "$T" push -q origin "$BR3"

# Локальная линия $BR2: принятая история (HIST, RED ff) + нейтральный tip —
# диапазон пуша несёт ОБА красных, из них живой на origin только HIST.
eg -C "$T" checkout -q "$BR2"
eg -C "$T" merge -q --ff-only main
eg -C "$T" merge -q --ff-only "$GHOST"
printf 'нейтральный tip %s\n' "$RAND" > "$T/$NEUT2"
eg -C "$T" add -A
eg -C "$T" commit -q -m "нейтральный tip ($RAND)"
TIP2="$(eg -C "$T" rev-parse "$BR2")"

# Локальная линия $BR3 (охрана): HIST + нейтральный tip, БЕЗ RED — изоляция.
eg -C "$T" checkout -q "$BR3"
eg -C "$T" merge -q --ff-only main
printf 'нейтральный tip охраны %s\n' "$RAND" > "$T/$NEUT3"
eg -C "$T" add -A
eg -C "$T" commit -q -m "нейтральный tip охраны ($RAND)"
TIP3="$(eg -C "$T" rev-parse "$BR3")"
eg -C "$T" checkout -q main

# ── оракул в памяти ДО вызова субъекта (правило 8; пере-проверяется после
# отката стаб-фазы — посадка стаба не должна была изменить предмет). Все
# git-продуцеры — capture'ом в память, сверка через printf|grep (printf —
# builtin, ранний выход grep не гасит продюсера SIGPIPE'ом: прямой пайп при
# раннем матче давал rc 141 сквозь pipefail — замер 200/200, А-111).
snapshot_oracle() {
  local bare_all mirror range2 range3 dR dH lR lH
  bare_all="$(git -C "$ORIG" rev-list --all 2>/dev/null)"
  mirror="$(eg -C "$T" rev-list --remotes 2>/dev/null)"
  range2="$(eg -C "$T" rev-list "$BASE..$TIP2" 2>/dev/null)"
  range3="$(eg -C "$T" rev-list "$BASE..$TIP3" 2>/dev/null)"
  dR="$(eg -C "$T" diff --name-only "$RED^" "$RED" 2>/dev/null)"
  dH="$(eg -C "$T" diff --name-only "$HIST^" "$HIST" 2>/dev/null)"
  lR="$(eg -C "$T" log -1 --format=%B "$RED" 2>/dev/null)"
  lH="$(eg -C "$T" log -1 --format=%B "$HIST" 2>/dev/null)"
  if git -C "$ORIG" rev-parse --verify -q "refs/heads/$GHOST" >/dev/null 2>&1; then
    printf 'ОТКАЗ: подготовка toy сломана — ghost жив на origin (нет stale-грани)\n' >&2; exit 1
  fi
  [ "$(eg -C "$T" rev-parse --verify -q "refs/remotes/origin/$GHOST")" = "$RED" ] || {
    printf 'ОТКАЗ: подготовка toy сломана — локальное зеркало origin/%s не на RED\n' "$GHOST" >&2; exit 1; }
  printf '%s\n' "$bare_all" | grep -qxF "$RED" && {
    printf 'ОТКАЗ: подготовка toy сломана — RED достижим из живых refов origin (не stale)\n' >&2; exit 1; }
  [ "$(git -C "$ORIG" rev-parse refs/heads/main)" = "$HIST" ] || {
    printf 'ОТКАЗ: подготовка toy сломана — HIST не жив на origin/main (охране нечего исключать)\n' >&2; exit 1; }
  [ "$(oref2)" = "$BASE" ] || {
    printf 'ОТКАЗ: подготовка toy сломана — существующий ref %s не на BASE\n' "$BR2" >&2; exit 1; }
  [ "$(oref3)" = "$BASE" ] || {
    printf 'ОТКАЗ: подготовка toy сломана — существующий ref %s не на BASE\n' "$BR3" >&2; exit 1; }
  printf '%s\n' "$mirror" | grep -qxF "$RED" || {
    printf 'ОТКАЗ: подготовка toy сломана — RED не достижим из зеркала (текущему коду нечего исключать — нет различаемой грани)\n' >&2; exit 1; }
  printf '%s\n' "$range2" | grep -qxF "$RED" || {
    printf 'ОТКАЗ: подготовка toy сломана — RED не в пушимом диапазоне %s\n' "$BR2" >&2; exit 1; }
  printf '%s\n' "$range2" | grep -qxF "$HIST" || {
    printf 'ОТКАЗ: подготовка toy сломана — HIST не в пушимом диапазоне %s\n' "$BR2" >&2; exit 1; }
  printf '%s\n' "$range3" | grep -qxF "$HIST" || {
    printf 'ОТКАЗ: подготовка toy сломана — HIST не в диапазоне охраны %s\n' "$BR3" >&2; exit 1; }
  printf '%s\n' "$range3" | grep -qxF "$RED" && {
    printf 'ОТКАЗ: подготовка toy сломана — RED в диапазоне охраны %s (охрана не изолирована)\n' "$BR3" >&2; exit 1; }
  printf '%s\n' "$dR" | grep -qxF "$PATH_C" || {
    printf 'ОТКАЗ: подготовка toy сломана — RED не несёт дельту M уставного пути\n' >&2; exit 1; }
  printf '%s\n' "$dH" | grep -qxF "$PATH_C" || {
    printf 'ОТКАЗ: подготовка toy сломана — HIST не несёт дельту M уставного пути\n' >&2; exit 1; }
  printf '%s\n' "$lR" | grep -q 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ' && {
    printf 'ОТКАЗ: подготовка toy сломана — RED несёт строку РАЗРЕШИЛ (вход не красен)\n' >&2; exit 1; }
  printf '%s\n' "$lH" | grep -q 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ' && {
    printf 'ОТКАЗ: подготовка toy сломана — HIST несёт строку РАЗРЕШИЛ (охрана не красна)\n' >&2; exit 1; }
}
snapshot_oracle
printf 'вход: RED=%s HIST=%s TIP2=%s TIP3=%s\n' "$RED" "$HIST" "$TIP2" "$TIP3"

# ── фаза 1 (стаб-подстановка «зеркало refs/remotes — истина»): зелёно-ложная
# посадка ОБЯЗАНА наблюдаться, затем откат (bare-реф И tracking-реф, А-107) ───
STAB="$WORK/stab_zerkalo_istina.sh"
cat > "$STAB" <<'STAB'
#!/usr/bin/env bash
# стаб «зеркало refs/remotes — истина» (слабая форма (б), текущий код
# .githooks/pre-push:142): исключает всё достижимое из refs/remotes=origin/*,
# доверяя локальному снимку. Мини-судья копирует грамматику судимого
# множества кольца (--diff-filter=MD, добавление свободно — урок А-104).
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
rc=0
while read -r lref lsha rref rsha; do
  [ -n "$lref" ] || continue
  set -- "$lsha" --not --remotes=origin/*
  for c in $(git -C "$ROOT" rev-list "$@" 2>/dev/null); do
    for f in $(git -C "$ROOT" ls-tree -r --name-only HEAD -- contracts/ 2>/dev/null | grep '\.md$'); do
      nnn="$(printf '%s' "$f" | sed -n 's|^contracts/\([0-9][0-9][0-9]\)-.*$|\1|p')"
      [ -n "$nnn" ] || continue
      git -C "$ROOT" rev-parse --verify -q "refs/tags/frozen/contracts/$nnn/1" >/dev/null || continue
      if git -C "$ROOT" diff-tree -r --no-commit-id --name-only --diff-filter=MD "$c^" "$c" 2>/dev/null \
         | grep -qxF -- "$f"; then
        if ! git -C "$ROOT" log -1 --format=%B "$c" | grep -qF "РАЗРЕШИЛ-ВЛАДЕЛЕЦ: $f"; then
          printf 'ОТКАЗ: устав-дельта в диапазоне: %s в %s (ref=%s)\n' "$f" "$c" "$lref" >&2
          rc=1
        fi
      fi
    done
  done
done
exit "$rc"
STAB
install_hook_from "$STAB"
p1="$(jg -C "$T" push origin "$BR2" 2>&1)"; p1_rc=$?
if [ "$p1_rc" -ne 0 ] || [ "$(oref2)" != "$TIP2" ]; then
  printf 'ОТКАЗ: вход не ловит стаб «зеркало — истина» — stale-пуш отклонён стабом либо ref не двинулся (rc=%s, origin=%s): %s\n' \
    "$p1_rc" "$(oref2)" "$p1" >&2
  exit 1
fi
stab_all="$(git -C "$ORIG" rev-list --all 2>/dev/null)"
printf '%s\n' "$stab_all" | grep -qxF "$RED" || {
  printf 'ОТКАЗ: стаб-фаза не посадила RED на живой origin (зелёно-ложное не наблюдено)\n' >&2; exit 1; }

# Откат посадки стаб-фазы: bare-реф И tracking-реф (А-107: новая семантика
# исключает достижимое из refs/remotes/* — забытый tracking-реф оставил бы RED
# «легитимно исключённым» и в честных фазах).
git -C "$ORIG" update-ref "refs/heads/$BR2" "$BASE"
eg -C "$T" update-ref "refs/remotes/origin/$BR2" "$BASE"
snapshot_oracle

# ── фаза 2 (охрана, честный механизм): живой origin-ref ИСКЛЮЧАЕТ — пуш
# легит-диапазона $BR3 (HIST жив на origin/main, RED в диапазоне НЕТ) ПРОХОДИТ ─
if [ ! -f "$HOOK_SRC" ]; then
  printf 'ОТКАЗ: механизм pre-push отсутствует (.githooks/pre-push нет в дереве) — stale-грани некому предъявить\n' >&2
  exit 1
fi
mkdir -p "$T/scripts"
cp "$REPO/scripts/check_charter.sh" "$T/scripts/"
cp "$REPO/scripts/next_id.sh" "$T/scripts/"
cp "$REPO/scripts/lib_registry.sh" "$T/scripts/"
install_hook_from "$HOOK_SRC"
pg="$(jg -C "$T" push origin "$BR3" 2>&1)"; pg_rc=$?
if [ "$pg_rc" -eq 0 ] && [ "$(oref3)" = "$TIP3" ]; then
  :
else
  printf 'ОТКАЗ: охрана — честный случай (б) сломан: легит-пуш %s несёт лишь красный %s, ЖИВОЙ на origin/main, но отвергнут (rc=%s, origin=%s): %s\n' \
    "$BR3" "$HIST" "$pg_rc" "$(oref3)" "$pg" >&2
  exit 1
fi

# ── фаза 3 (stale-грань, честный механизм): красный RED, НИКОГДА не живший на
# origin, ОБЯЗАН умереть до посадки — тройка ref+sha+путь, origin-ref неподвижен ─
ps="$(jg -C "$T" push origin "$BR2" 2>&1)"; ps_rc=$?
if [ "$ps_rc" -eq 0 ]; then
  if [ "$(oref2)" != "$TIP2" ]; then
    printf 'ОТКАЗ: toy сломан — пуш прошёл, но origin/%s не на TIP2 (%s)\n' "$BR2" "$(oref2)" >&2
    exit 1
  fi
  printf 'ОТКАЗ: обход жив (блокер c000ed1, красное-до-реализации по А-107): красный коммит %s (дельта M %s без РАЗРЕШИЛ, НИКОГДА не живший на origin: ветка %s удалена с origin напрямую, локальное зеркало refs/remotes/origin/%s осталось stale) исключён зеркалом refs/remotes=origin/* и уехал на origin обычным live push (rc=0, origin/%s=%s). Честный гейт обязан отвергнуть тройкой ref+sha+путь при неподвижном origin-рефе; зелёность докажет union-батарея после фикса базы исключения (снимок живого origin, Impl022fix3): %s\n' \
    "$RED" "$PATH_C" "$GHOST" "$GHOST" "$BR2" "$TIP2" "$ps" >&2
  exit 1
fi
if [ "$(oref2)" != "$BASE" ]; then
  printf 'ОТКАЗ: пуш отвергнут, но origin-реф ДВИНУЛСЯ (%s != %s) — отказ не до посадки\n' \
    "$(oref2)" "$BASE" >&2
  exit 1
fi
printf '%s\n' "$ps" | grep -qF "refs/heads/$BR2" || {
  printf 'ОТКАЗ: отказ без полного ref (%s): %s\n' "$BR2" "$ps" >&2; exit 1; }
printf '%s\n' "$ps" | grep -qF "$RED" || {
  printf 'ОТКАЗ: отказ без полного sha красного коммита (%s): %s\n' "$RED" "$ps" >&2; exit 1; }
printf '%s\n' "$ps" | grep -qF "$PATH_C" || {
  printf 'ОТКАЗ: отказ без пути уставного файла (%s): %s\n' "$PATH_C" "$ps" >&2; exit 1; }

exit 0
