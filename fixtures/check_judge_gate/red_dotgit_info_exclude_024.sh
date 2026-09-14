#!/usr/bin/env bash
# Красный контрпример блокера Б1 ревью v1 contracts-024-v1.md
# (правка-круг 10, контракт 024):
#
#   Правка `.git/info/exclude` (per-repo носитель игнор-правил) сама по себе
#   невидима для `git status --porcelain -uall` (источник манифеста), и
#   ОДНОВРЕМЕННО ослепляет источник для файлов, попавших под новое правило —
#   файл утечки, подпадающий под новый exclude-паттерн, исчезает из porcelain,
#   детекция идёт по пустому дельте, и `--check` объявляет «чисто» при живой
#   утечке. Это симметричный класс для sparse-checkout/attributes/grafts и
#   любых будущих файлов в `.git/info/`.
#
# ФИКСТУРА ПРЕДЪЯВЛЯЕТ ТРИ КОНТРОЛЯ:
#   * негативный (честный вход, без правок .git/info/*) — rc 0 «чисто»;
#   * положительный (правка exclude с правилом, скрывающим новый untracked) —
#     rc 1, имя `.git/info/exclude` в выводе;
#   * негативный-2 (правка только существующего exclude — без новой утечки) —
#     rc 1, имя `.git/info/exclude` в выводе (правка exclude сама — дельта).
#
# Форма — по прецеденту red_detektor_utechek.sh: собственный WORK вне дерева,
# TMPDIR редиректится в WORK, имена мусора случайны КАЖДЫЙ прогон. Имя
# ВНЕ case_*-глоба раннера НАМЕРЕННО (И-11 контракта 024; прецедент
# red_detektor_utechek.sh — стаб red_* в семейном каталоге).
#
# ЗАКРЫТИЕ КЛАССА: emit_dotgit_manifest ходит по всему .git/info/* (правка-круг
# 10), запись в exclude (или sparse-checkout, или attributes, или grafts, или
# refs, или любой будущий файл в .git/info/) становится дельтой dot-git
# манифеста ⇒ rc 1 именованный. Проверка — обходом walk по .git/info/; см.
# комментарий emit_dotgit_manifest в scripts/check_no_leak.sh.
#
# Коды возврата: 0 — все три контроля прошли (фикс работает); 1 — именованный
#               отказ (детектор отсутствует либо не поймал класс).
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
SUBJ="$REPO/scripts/check_no_leak.sh"

[ -f "$SUBJ" ] || {
  printf 'ОТКАЗ: детектор отсутствует — scripts/check_no_leak.sh (реализация за implementer после заморозки 024)\n' >&2
  exit 1
}

# ЕДИНЫЙ источник фраз (Демаркация 024) — побайтово во всех проверках ниже.
P_ZAGR='основной чекаут загрязнён'
P_CHISTO='основной чекаут чист'

WORK="$(mktemp -d /tmp/red024-b1-dotgit-info-exclude.XXXXXX)"   # А-78: свежий WORK вне дерева
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/snaps"
export TMPDIR="$WORK/snaps"                       # снимки субъекта — в скратч прогона

ok()   { printf '  ok   %s (%s)\n' "$1" "$2" >&2; }
fail() { printf 'ОТКАЗ %s (%s): %s\n' "$1" "$2" "$3" >&2; exit 1; }

# Запуск субъекта: cwd=arg2, аргументы дальше — rc без пайпов (Н-84/Н-85).
run_subj() {
  local cwd="$1"; shift
  SUBJ_OUT="$( cd "$cwd" && bash "$SUBJ" "$@" 2>&1 )" && SUBJ_RC=0 || SUBJ_RC=$?
}
has() { printf '%s\n' "$SUBJ_OUT" | grep -qF -- "$1"; }

# Живой git-чекаут toy: два tracked-файла (каналы ночи). НЕ создаём .git/info/
# до снимка — чтобы первая итерация контроля была действительно «честной».
mk_main() {  # <каталог>
  mkdir -p "$1/.githooks" "$1/scripts"
  printf '# toy hook\n'   > "$1/.githooks/pre-push"
  printf '# toy spawn\n'  > "$1/scripts/spawn_agent.sh"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git init -q -b main "$1"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$1" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$1" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      commit -q -m 'toy main'
}

# ─── контроль 1: честный вход (без правок .git/info/*) → rc 0 «чисто» ─────────
# Это ДОЛЖЕН проходить как не-фикс-кандидат тоже: до правки emit_dotgit_manifest
# этот контроль тоже rc 0 (правок-то нет). Контроль стоит здесь, чтобы при
# РЕГРЕССИИ фикса (если кто-то удалит walk по .git/info/) он продолжал проходить,
# но контроли 2/3 — падали. То есть: контроль 1 защищает «фикс не сломал
# существующее», контроли 2/3 — «фикс закрывает класс».
K1="$WORK/v1_chestnyj_${RANDOM}"
mk_main "$K1"
run_subj "$K1" --snapshot "$K1"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-1 "честный снимок" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
run_subj "$K1" --check "$K1"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-1 "честный вход" \
  "rc=$SUBJ_RC (ожидался 0). Вывод: $SUBJ_OUT"
has "$P_CHISTO" || fail контроль-1 "честный вход" \
  "нет маркера «$P_CHISTO». Вывод: $SUBJ_OUT"
ok контроль-1 "честный вход без правок .git/info/*: rc 0 «чисто»"

# ─── контроль 2: правка exclude + новый untracked, скрытый новым правилом ─────
# МЕХАНИКА. После снимка: дописываем в .git/info/exclude правило (имя мусора),
# создаём утечку, которая подпадает под правило.
# `git status --porcelain -uall` НЕ показывает утечку (exclude скрыл);
# детектор, НЕ включающий .git/info/exclude в манифест, объявляет
# «чисто» — ложный зелёный при живой утечке (это и есть блокер Б1).
# ПОСЛЕ ФИКСА: emit_dotgit_manifest ходит по .git/info/, допись в exclude сама
# становится дельтой манифеста ⇒ rc 1, имя `.git/info/exclude` в выводе.
K2="$WORK/v2_exclude_skryvaet_${RANDOM}"
mk_main "$K2"
# Имя мусора И правила совпадают — случайный суффикс один на оба.
UTECHKA_NAME="utechka_${RANDOM}_${RANDOM}_${RANDOM}.tmp"
EXCLUDE_RULE="$UTECHKA_NAME"   # правило исключает ровно наш мусор
run_subj "$K2" --snapshot "$K2"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-2 "снимок" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
# Правка exclude (правило, скрывающее будущий untracked-файл):
printf '%s\n' "$EXCLUDE_RULE" >> "$K2/.git/info/exclude"
# Утечка, подпадающая под новое правило:
: > "$K2/$UTECHKA_NAME"
# Sanity: утечка действительно НЕ отражается в porcelain (иначе это не та механика).
PORCELAIN=$(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$K2" status --porcelain -uall 2>/dev/null)
if printf '%s' "$PORCELAIN" | grep -qF "$UTECHKA_NAME"; then
  fail контроль-2 "sanity" \
    "утечка $UTECHKA_NAME видна в porcelain ДО запуска детектора — механика исключения не воспроизвелась"
fi
run_subj "$K2" --check "$K2"
# Проверка фикса: rc 1 + имя `.git/info/exclude`.
[ "$SUBJ_RC" -eq 1 ] || fail контроль-2 "правка exclude скрывает утечку" \
  "rc=$SUBJ_RC (ожидался 1) — правка .git/info/exclude не поймана: файл утечки скрыт новым правилом, детектор не видит ни exclude, ни утечки ⇒ ложный «чисто» (блокер Б1 ревью v1). Вывод: $SUBJ_OUT"
has "$P_ZAGR" || fail контроль-2 "правка exclude скрывает утечку" \
  "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
has ".git/info/exclude" || fail контроль-2 "правка exclude скрывает утечку" \
  "имя .git/info/exclude не названо. Вывод: $SUBJ_OUT"
if has "$P_CHISTO"; then
  fail контроль-2 "правка exclude скрывает утечку" \
    "сверка при живой правке .git/info/exclude объявила «$P_CHISTO» — ложный зелёный (класс Б1). Вывод: $SUBJ_OUT"
fi
ok контроль-2 "правка .git/info/exclude + утечка скрыта правилом: rc 1, .git/info/exclude назван"

# ─── контроль 3: правка только exclude (без новой утечки) ─────────────────────
# Защита от чтения «правка exclude — это валидно, проверять не надо». Здесь
# exclude правка ДОЛЖНА быть дельтой (она сама по себе — потенциальный класс
# «правка rules-файла в .git/info/», см. аналогию с .git/config — правка
# .git/config тоже ловится без новой утечки). Если rc 0 — фикс покрыл exclude
# ровно для сценария «exclude правит что-то», а не «exclude меняется как файл».
K3="$WORK/v3_exclude_sama_${RANDOM}"
mk_main "$K3"
run_subj "$K3" --snapshot "$K3"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-3 "снимок" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
printf '# добавлено фикстурой: %s\n' "marker_${RANDOM}" >> "$K3/.git/info/exclude"
run_subj "$K3" --check "$K3"
[ "$SUBJ_RC" -eq 1 ] || fail контроль-3 "правка exclude без утечки" \
  "rc=$SUBJ_RC (ожидался 1) — правка .git/info/exclude сама по себе не детектируется (правка невидима porcelain + не детектируется как дельта). Вывод: $SUBJ_OUT"
has ".git/info/exclude" || fail контроль-3 "правка exclude без утечки" \
  "имя .git/info/exclude не названо. Вывод: $SUBJ_OUT"
if has "$P_CHISTO"; then
  fail контроль-3 "правка exclude без утечки" \
    "сверка при правке .git/info/exclude (без новой утечки) объявила «$P_CHISTO» — правка файла-правила В .git/info/ невидима. Вывод: $SUBJ_OUT"
fi
ok контроль-3 "правка .git/info/exclude без утечки: rc 1, .git/info/exclude назван"

printf 'red_dotgit_info_exclude_024: 3 контроля зелены (блокер Б1 ревью v1, правка-круг 10)\n' >&2
exit 0
