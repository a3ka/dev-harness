#!/usr/bin/env bash
# ПРОБА-ОХРАНА ФИКС-РАУНДА 022-Н-86 (решение владельца (б), 2026-09-10): гейт
# судит только коммиты СВЕРХ origin — но НЕ ПЕРЕСТАЁТ СУДИТЬ. Слабая форма
# решения (б): «судимое множество пусто на любом входе» (диапазон вычисляется,
# исключения съедают всё, гейт exit 0) — свежий нарушающий коммит сверх origin
# уезжает на origin свободно. Эта проба — прямой прогон против живого хука из
# дерева, зелёная И ДО сведения (старый хук судит весь rsha..lsha — свежий
# красный в нём есть), И ПОСЛЕ (судимое множество = сверх origin — свежий
# красный в нём); красная проба означала бы потерю гейта целиком.
#
# ВХОД: тот же toy, что у red_push_istoricheskij_legit_prohodit.sh (существующий
# ref на BASE; диапазон несёт ПРИНЯТУЮ историю HIST — устав-дельта M без РАЗРЕШИЛ,
# уже на origin/main — и нейтральный tip), ПЛЮС один НОВЫЙ коммит с устав-дельтой
# M без строки, НЕ достижимый ни из одного remote-ref (сверх origin). Живой пуш
# существующего ref. Честная реализация (обе семантики) ОТВЕРГАЕТ с полным
# диагнозом: ref (полный refs/heads/…), коммит (полный sha СВЕЖЕГО красного),
# путь (тройка равномерно, арбитраж b43d7a0).
#
# СТАБ-ВХОД (Н-39 — привязка КОДОМ): «судимое множество пусто» — слабая форма
# решения (б): читает stdin, вычисляет диапазон с ДВОЙНЫМ исключением
# ($lsha --not --remotes --not $lsha — всегда пусто), не судит ничего. Дефект
# наблюдаем ИМЕННО на этом входе: свежий красный сверх origin уезжает свободно.
# На входе red_push_istoricheskij_legit_prohodit.sh (легит-пуш) стаб ведёт себя
# честно (пропускает то, что обязан пропускать) — его краснота там не наблюдаема
# и не требуется.
#
# ДВА прогона подряд с разными входами (детерминизм ∧ инвариантность; прецедент
# red_dver_po_tegu, 023): случайны ветка, имена файлов, тексты дельт; отпечаток
# входа печатается строкой «вход:» — ряды двух прогонов обязаны разойтись,
# вердикт — совпасть. Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (А-82, форма
# measure-probe — прямой запуск, прецедент А-105). Прогон — свежий WORK вне
# дерева (А-78, Н-74).
#
# Коды возврата: 0 — гейт судит свежее сверх origin (ДО и ПОСЛЕ сведения (б));
#               1 — именованный отказ (гейт перестал судить / диагноз неполон).
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
WORK="$(mktemp -d /tmp/probe022-fr.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT

HOOK_SRC="$REPO/.githooks/pre-push"
ORIG="$WORK/origin.git"
T="$WORK/toy"

RAND="r$RANDOM$RANDOM"
BR="feat-$RAND"
NEUT="ner-$RAND.txt"
PATH_C='contracts/001-x.md'

eg() {
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}
jg() {
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -c commit.gpgsign=false "$@"
}
oref() { git -C "$ORIG" rev-parse --verify -q "refs/heads/$BR" || echo ПУСТО; }

printf 'вход: RAND=%s ветка=%s\n' "$RAND" "$BR"

install_hook_from() {  # <файл-источник>
  mkdir -p "$T/.githooks"
  cp "$1" "$T/.githooks/pre-push"
  chmod +x "$T/.githooks/pre-push"
  eg -C "$T" config core.hooksPath "$T/.githooks"
}

# ── toy: основание с замороженным контрактом + bare-origin ────────────────────
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

# Исторический легит-коммит (как в red_push_istoricheskij_legit_prohodit.sh):
# принятая origin'ом устав-дельта M без строки — фон, который решение (б) не
# судит, а слабая форма «не судит ничего» прячется за ним.
printf '\nисторическая дельта %s без строки\n' "$RAND" >> "$T/$PATH_C"
eg -C "$T" add -A
eg -C "$T" commit -q -m "исторический owner-коммит: дельта M без РАЗРЕШИЛ ($RAND)"
HIST="$(eg -C "$T" rev-parse main)"
eg -C "$T" push -q origin main

# Существующий ref $BR на BASE; локальная линия: HIST (ff из main) + нейтральный
# tip + СВЕЖИЙ красный сверх origin.
eg -C "$T" branch -q "$BR" "$BASE"
eg -C "$T" push -q origin "$BR"
eg -C "$T" checkout -q "$BR"
eg -C "$T" merge -q --ff-only main
printf 'нейтральный tip %s\n' "$RAND" > "$T/$NEUT"
eg -C "$T" add -A
eg -C "$T" commit -q -m "нейтральный tip ($RAND)"
printf '\nсвежая дельта сверх origin %s без строки\n' "$RAND" >> "$T/$PATH_C"
eg -C "$T" add -A
eg -C "$T" commit -q -m "свежий красной сверх origin: дельта M без РАЗРЕШИЛ ($RAND)"
FR="$(eg -C "$T" rev-parse "$BR")"

# ── оракул в памяти ДО вызова субъекта (правило 8) ────────────────────────────
[ "$(git -C "$ORIG" rev-parse refs/heads/main)" = "$HIST" ] || {
  printf 'ОТКАЗ: подготовка toy сломана — легит-коммит не принят на origin\n' >&2; exit 1; }
[ "$(oref)" = "$BASE" ] || {
  printf 'ОТКАЗ: подготовка toy сломана — существующий ref не на BASE\n' >&2; exit 1; }
eg -C "$T" rev-list --remotes | grep -qxF "$HIST" || {
  printf 'ОТКАЗ: подготовка toy сломана — HIST не достижим из remote-ref\n' >&2; exit 1; }
eg -C "$T" diff --name-only "$FR^" "$FR" | grep -qxF "$PATH_C" || {
  printf 'ОТКАЗ: подготовка toy сломана — свежий коммит не несёт дельту M уставного пути\n' >&2; exit 1; }
if eg -C "$T" log -1 --format=%B "$FR" | grep -q 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ'; then
  printf 'ОТКАЗ: подготовка toy сломана — свежий коммит несёт строку РАЗРЕШИЛ (вход не красен)\n' >&2; exit 1
fi

# ── фаза 1 (стаб-подстановка «судимое множество пусто»): вход обязан ловить ───
STAB="$WORK/stab_pustoe_sudimoe.sh"
cat > "$STAB" <<'STAB'
#!/usr/bin/env bash
# стаб «судимое множество пусто» — слабая форма решения Н-86(б): читает stdin,
# вычисляет «диапазон» с двойным исключением ($lsha --not --remotes --not $lsha
# — всегда пуст), кольцо не беспокоит, судит ровно ничего.
set -uo pipefail
while read -r lref lsha rref rsha; do
  [ -n "$lref" ] || continue
  git rev-list "$lsha" --not --remotes --not "$lsha" >/dev/null 2>&1
done
exit 0
STAB
install_hook_from "$STAB"
p1="$(jg -C "$T" push origin "$BR" 2>&1)"; p1_rc=$?
if [ "$p1_rc" -ne 0 ] || [ "$(oref)" != "$FR" ]; then
  printf 'ОТКАЗ: вход не ловит стаб «судимое множество пусто» — красный сверх origin не уехал к стабу (rc=%s, origin=%s): %s\n' \
    "$p1_rc" "$(oref)" "$p1" >&2
  exit 1
fi

# Откат посадки стаб-фазы: И bare-ref, И локальный tracking-ref — новая
# семантика исключает достижимое из refs/remotes/*, стаб-побег оставил бы там
# свежий sha и охрана ложно зелёнелась бы после сведения (б).
git -C "$ORIG" update-ref "refs/heads/$BR" "$BASE"
eg -C "$T" update-ref "refs/remotes/origin/$BR" "$BASE"
[ "$(oref)" = "$BASE" ] || {
  printf 'ОТКАЗ: откат стаб-фазы сломан — существующий ref не вернулся на BASE\n' >&2; exit 1; }
if eg -C "$T" rev-list --remotes | grep -qxF "$FR"; then
  printf 'ОТКАЗ: подготовка toy сломана — свежий красный достижим из remote-ref (не «сверх origin»)\n' >&2; exit 1
fi

# ── фаза 2 (честный механизм): свежий красный сверх origin УМИРАЕТ ────────────
if [ ! -f "$HOOK_SRC" ]; then
  printf 'ОТКАЗ: механизм pre-push отсутствует (.githooks/pre-push нет в дереве) — охране нечего прогонять\n' >&2
  exit 1
fi
mkdir -p "$T/scripts"
cp "$REPO/scripts/check_charter.sh" "$T/scripts/"
cp "$REPO/scripts/next_id.sh" "$T/scripts/"
cp "$REPO/scripts/lib_registry.sh" "$T/scripts/"
install_hook_from "$HOOK_SRC"
p2="$(jg -C "$T" push origin "$BR" 2>&1)"; p2_rc=$?
if [ "$p2_rc" -eq 0 ]; then
  printf 'ОТКАЗ: свежий красный сверх origin прошёл (rc=0) — гейт перестал судить: %s\n' "$p2" >&2
  exit 1
fi
if [ "$(oref)" != "$BASE" ]; then
  printf 'ОТКАЗ: пуш отвергнут, но ref двинулся — отвержение не атомарно\n' >&2
  exit 1
fi
printf '%s\n' "$p2" | grep -qF "$PATH_C" || {
  printf 'ОТКАЗ: отказ без именованной причины (путь уставного файла не назван): %s\n' "$p2" >&2
  exit 1
}
printf '%s\n' "$p2" | grep -qF "$FR" || {
  printf 'ОТКАЗ: причина не называет КОММИТ (полный sha свежего красного %s отсутствует) — диагноз неполон (тройка равномерно, арбитраж b43d7a0): %s\n' "$FR" "$p2" >&2
  exit 1
}
printf '%s\n' "$p2" | grep -qF "refs/heads/$BR" || {
  printf 'ОТКАЗ: причина не называет REF (полный refs/heads/%s отсутствует) — диагноз неполон (тройка равномерно, арбитраж b43d7a0): %s\n' "$BR" "$p2" >&2
  exit 1
}

exit 0
