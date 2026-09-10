#!/usr/bin/env bash
# КРАСНОЕ ФИКС-РАУНДА 022-Н-86 (решение владельца (б), 2026-09-10): гейт судит
# только коммиты СВЕРХ origin (не достижимые ни из одного origin-ref), не весь
# диапазон remote_sha..local_sha — исторические owner-коммиты легитимны (черновики
# до freeze, санкции+блобы сверены), пере-суд принятой истории = класс «краснеет
# на неисправимом прошлом» (11 отказов Н-86 — боль замерена). НЕ blanket-РАЗРЕШИЛ,
# НЕ marker.
#
# ВХОД: пуш СУЩЕСТВУЮЩЕГО ref (ненулевой remote_sha; на ветке architect хук ещё
# старый — судит ВЕСЬ диапазон rsha..lsha, код .githooks/pre-push:129-133):
# диапазон несёт (а) исторический легит-коммит HIST — устав-дельта M замороженного
# contracts/001-x.md без РАЗРЕШИЛ, УЖЕ принятый на origin (origin/main = HIST,
# пуш эпохи до хука), и (б) нейтральный tip. Честная реализация ПО РЕШЕНИЮ (б)
# ПРОПУСКАЕТ пуш: HIST достижим из refs/remotes/origin/main → вне судимого
# множества; свежих нарушений в диапазоне нет. Старый хук ОТКАЗЫВАЕТ на HIST —
# это и есть предъявляемое красное (ровно форма 11 отказов Н-86: пуш ветки, чей
# диапазон несёт уже принятую origin'ом историю).
#
# СТАБ-ВХОД (Н-39 — привязка КОДОМ): «весь диапазон» — старая семантика выбора
# диапазона (rsha..lsha без исключения принятого origin'ом; код-ветка ненулевого
# remote_sha). Дефект наблюдаем ИМЕННО на этом входе: легит-коммит, уже достижимый
# из origin/main, валит пуш, который договор обязан пропустить. На входе
# пробы-охраны (probe_push_svezhij_sverh_origin_umiraet.sh — свежий красный сверх
# origin) стаб ведёт себя честно (свежий коммит в его диапазоне есть) — его
# краснота там не наблюдаема и не требуется.
#
# ЗЕЛЁНОСТЬ ДОКАЗЫВАЕТ ОБЪЕДИНЕНИЕ: реализация (б) идёт ПАРАЛЛЕЛЬНО в ветке
# implementer от свежего main; на ветке architect хук старый — файл КРАСЕН
# именованной причиной класса Н-86; после сведения (б) — rc 0 (union-батарея
# оркестратора). Проба инвариантна к форме исключения (--not --remotes против
# --not --remotes=origin/*): HIST публикуется на origin/main — достижим из
# refs/remotes/origin/* в обеих формах.
#
# ДВА прогона подряд с разными входами (детерминизм ∧ инвариантность; прецедент
# red_dver_po_tegu, 023): случайны ветка, имена файлов, тексты дельт; отпечаток
# входа печатается строкой «вход:» — ряды двух прогонов обязаны разойтись,
# вердикт — совпасть. Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (А-82). Прогон —
# свежий WORK вне дерева (А-78, Н-74).
#
# Коды возврата: 0 — ворота пройдены (после сведения (б)); 1 — именованный отказ.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
WORK="$(mktemp -d /tmp/red022-ist.XXXXXX)"
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

# Исторический легит-коммит: устав-дельта M без РАЗРЕШИЛ, принятая на origin
# ДО установки хука (черновики легальных итераций; санкции+блобы сверены — Н-86).
printf '\nисторическая дельта %s без строки\n' "$RAND" >> "$T/$PATH_C"
eg -C "$T" add -A
eg -C "$T" commit -q -m "исторический owner-коммит: дельта M без РАЗРЕШИЛ ($RAND)"
HIST="$(eg -C "$T" rev-parse main)"
eg -C "$T" push -q origin main

# Существующий ref $BR: origin знает его на BASE (обновление → ненулевой
# remote_sha → старый хук судит ВЕСЬ диапазон rsha..lsha).
eg -C "$T" branch -q "$BR" "$BASE"
eg -C "$T" push -q origin "$BR"

# Локальная линия $BR: принятая origin'ом история (HIST через ff из main) +
# нейтральный tip.
eg -C "$T" checkout -q "$BR"
eg -C "$T" merge -q --ff-only main
printf 'нейтральный tip %s\n' "$RAND" > "$T/$NEUT"
eg -C "$T" add -A
eg -C "$T" commit -q -m "нейтральный tip ($RAND)"
TIP="$(eg -C "$T" rev-parse "$BR")"

# ── оракул в памяти ДО вызова субъекта (правило 8) ────────────────────────────
[ "$(git -C "$ORIG" rev-parse refs/heads/main)" = "$HIST" ] || {
  printf 'ОТКАЗ: подготовка toy сломана — легит-коммит не принят на origin\n' >&2; exit 1; }
[ "$(oref)" = "$BASE" ] || {
  printf 'ОТКАЗ: подготовка toy сломана — существующий ref не на BASE\n' >&2; exit 1; }
eg -C "$T" rev-list --remotes | grep -qxF "$HIST" || {
  printf 'ОТКАЗ: подготовка toy сломана — HIST не достижим из remote-ref\n' >&2; exit 1; }
eg -C "$T" rev-list "$BASE..$TIP" | grep -qxF "$HIST" || {
  printf 'ОТКАЗ: подготовка toy сломана — HIST не в пушимом диапазоне (нет различаемой ветви)\n' >&2; exit 1; }
eg -C "$T" diff --name-only "$HIST^" "$HIST" | grep -qxF "$PATH_C" || {
  printf 'ОТКАЗ: подготовка toy сломана — HIST не несёт дельту M уставного пути\n' >&2; exit 1; }
if eg -C "$T" log -1 --format=%B "$HIST" | grep -q 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ'; then
  printf 'ОТКАЗ: подготовка toy сломана — HIST несёт строку РАЗРЕШИЛ (вход не красен)\n' >&2; exit 1
fi

# ── фаза 1 (стаб-подстановка «весь диапазон»): вход обязан стаб ловить ────────
STAB="$WORK/stab_ves_diapazon.sh"
cat > "$STAB" <<'STAB'
#!/usr/bin/env bash
# стаб «весь диапазон» (старая семантика pre-push на ненулевом remote_sha,
# Н-86): судит КАЖДЫЙ коммит пушимого диапазона rsha..lsha, не исключая
# принятого origin'ом. Мини-судья копирует грамматику судимого множества
# кольца (--diff-filter=MD, добавление свободно — урок А-104).
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
ZERO=0000000000000000000000000000000000000000
rc=0
while read -r lref lsha rref rsha; do
  [ -n "$lref" ] || continue
  if [ "$rsha" = "$ZERO" ] || [ -z "$rsha" ]; then
    set -- "$lsha" --not --remotes
  else
    set -- "$rsha..$lsha"
  fi
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
p1="$(jg -C "$T" push origin "$BR" 2>&1)"; p1_rc=$?
if [ "$p1_rc" -eq 0 ] || [ "$(oref)" != "$BASE" ]; then
  printf 'ОТКАЗ: вход не ловит стаб «весь диапазон» — пуш принятой истории прошёл либо ref двинулся (rc=%s, origin=%s): %s\n' \
    "$p1_rc" "$(oref)" "$p1" >&2
  exit 1
fi
printf '%s\n' "$p1" | grep -qF "$HIST" || {
  printf 'ОТКАЗ: стаб «весь диапазон» не назвал легит-коммит %s — вход не различает пере-суд принятой истории\n' "$HIST" >&2
  exit 1
}

# ── фаза 2 (честный механизм): принятая история ПРОХОДИТ ──────────────────────
if [ ! -f "$HOOK_SRC" ]; then
  printf 'ОТКАЗ: механизм pre-push отсутствует (.githooks/pre-push нет в дереве) — семантику диапазона некому предъявить\n' >&2
  exit 1
fi
mkdir -p "$T/scripts"
cp "$REPO/scripts/check_charter.sh" "$T/scripts/"
cp "$REPO/scripts/next_id.sh" "$T/scripts/"
cp "$REPO/scripts/lib_registry.sh" "$T/scripts/"
install_hook_from "$HOOK_SRC"
p2="$(jg -C "$T" push origin "$BR" 2>&1)"; p2_rc=$?
if [ "$p2_rc" -eq 0 ] && [ "$(oref)" = "$TIP" ]; then
  exit 0
fi
if printf '%s\n' "$p2" | grep -qF "$HIST"; then
  printf 'ОТКАЗ: гейт пере-судит принятую историю — легит-коммит %s (устав-дельта M %s без РАЗРЕШИЛ, УЖЕ достижимый из origin/main) заблокировал пуш существующего ref; решение владельца Н-86(б) 2026-09-10 в этом дереве НЕ реализовано (rc=%s): %s\n' \
    "$HIST" "$PATH_C" "$p2_rc" "$p2" >&2
else
  printf 'ОТКАЗ: пуш отклонён по причине ВНЕ класса Н-86 (легит-коммит не назван; rc=%s): %s\n' "$p2_rc" "$p2" >&2
fi
exit 1
