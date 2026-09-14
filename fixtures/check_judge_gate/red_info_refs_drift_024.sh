#!/usr/bin/env bash
# Красный контрпример carve-out k11 (коммит 3c6791d этой ветки, контракт 024):
# emit_dotgit_manifest_walk (scripts/check_no_leak.sh, ~строка 482) пропускает
# РОВНО `.git/info/refs` — git-кэш dumb-HTTP transport, генерируемый
# `git update-server-info` (косвенно: gc/repack/server-side receive-pack).
# Обоснование carve-out'а: содержимое `.git/info/refs` легитимно дрейфует
# между снимком и сверкой из ОБЫЧНЫХ git-операций (новый коммит/новая ветка
# → новый SHA → новая строка) БЕЗ участия враждебной стороны — включение refs
# в манифест давало ложные «основной чекаут загрязнён» на честном входе.
# Carve-out — ИМЕННОЙ (Н-39: стабы к ветвям привязывает architect по коду, не
# проза контракта): матчится ровно `.git/info/refs`, ЛЮБОЙ другой файл
# `.git/info/*` (exclude/attributes/sparse-checkout/grafts/будущие) остаётся
# в обходе — это уже закрыто блокером Б1 ревью v1 и покрыто
# red_dotgit_info_exclude_024.sh; данная фикстура предъявляет СИММЕТРИЧНЫЙ
# контрпример для refs САМОГО и regression-guard на то, что carve-out не
# расползся шире одного файла.
#
# ФИКСТУРА ПРЕДЪЯВЛЯЕТ РОВНО ТРИ КОНТРОЛЯ:
#   * контроль 1 (честный вход) — toy-репо, `.git/info/refs` создан явным
#     `git update-server-info` ДО снимка → --check без правок → rc 0 «чисто».
#     Регрессионная защита: carve-out не должен ломать штатный (без-дрейфа)
#     путь.
#   * контроль 2 (легитимный дрейф refs НЕ красит) — между снимком и сверкой
#     РЕАЛЬНАЯ git-операция (новая ветка + повторный update-server-info)
#     переписывает байты `.git/info/refs` (подтверждено прямым cmp ДО/ПОСЛЕ)
#     → --check → rc 0 «чисто». ПОЛЯРНОСТЬ ОБРАТНАЯ контролям 2/3
#     red_dotgit_info_exclude_024.sh (там правка .git/info/* КРАСИТ rc 1) —
#     здесь refs-дрейф ОБЯЗАН НЕ красить: это и есть предмет carve-out k11,
#     не «обычный rc 1 ожидаем».
#   * контроль 3 (regression guard — exclude по-прежнему красит) — правка
#     `.git/info/exclude` (файл БЕЗ отношения к refs) между снимком и сверкой
#     → --check → rc 1, «основной чекаут загрязнён», имя `.git/info/exclude`
#     в выводе. Доказывает: carve-out k11 точечный на `refs`, НЕ расширился
#     на весь `.git/info/*`.
#
# Форма — по прецеденту red_dotgit_info_exclude_024.sh: собственный WORK вне
# дерева, TMPDIR редиректится в WORK, имена мусора случайны КАЖДЫЙ прогон.
# Имя ВНЕ case_*-глоба раннера НАМЕРЕННО (И-11 контракта 024; тот же
# прецедент).
#
# Коды возврата: 0 — все три контроля прошли (carve-out работает точечно на
#               `.git/info/refs`); 1 — именованный отказ (детектор
#               отсутствует, легитимный refs-дрейф ошибочно красит основной
#               чекаут, ИЛИ carve-out расползся и перестал ловить
#               `.git/info/exclude`).
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

WORK="$(mktemp -d /tmp/red024-k11-refs-drift.XXXXXX)"   # А-78: свежий WORK вне дерева
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

# Живой git-чекаут toy: один tracked-файл + начальный коммит, затем ЯВНЫЙ
# `git update-server-info` — `.git/info/refs` НЕ существует после голого
# `git init` (создаёт его только update-server-info/gc/repack/dumb-HTTP push);
# явный вызов здесь гарантирует, что файл существует УЖЕ на снимке во всех
# трёх контролях — иначе контроль 2 проверял бы «появление», не «дрейф»
# (другая механика carve-out'а: он матчит по ИМЕНИ независимо от истории, но
# заявленный класс — именно дрейф байтового содержимого существующего файла).
mk_main() {  # <каталог>
  mkdir -p "$1"
  printf 'toy content\n' > "$1/toy.txt"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git init -q -b main "$1"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$1" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$1" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      commit -q -m 'toy main'
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$1" update-server-info
  [ -f "$1/.git/info/refs" ] || {
    printf 'ОТКАЗ: окружение непригодно — update-server-info не создал .git/info/refs в %s\n' "$1" >&2
    exit 2
  }
}

# ─── контроль 1: честный вход (refs существует на снимке, без правок) ─────────
# Регрессионная защита: carve-out НЕ должен ломать штатный путь без дрейфа.
K1="$WORK/v1_chestnyj_${RANDOM}"
mk_main "$K1"
run_subj "$K1" --snapshot "$K1"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-1 "снимок" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
run_subj "$K1" --check "$K1"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-1 "честный вход" \
  "rc=$SUBJ_RC (ожидался 0). Вывод: $SUBJ_OUT"
has "$P_CHISTO" || fail контроль-1 "честный вход" \
  "нет маркера «$P_CHISTO». Вывод: $SUBJ_OUT"
ok контроль-1 "честный вход, .git/info/refs существует на снимке без правок: rc 0 «чисто»"

# ─── контроль 2: легитимный дрейф .git/info/refs НЕ красит (ПОЛЯРНОСТЬ ОБРАТНАЯ) ─
# МЕХАНИКА. После снимка: новая ветка (без checkout, без изменений рабочего
# дерева — `git status --porcelain -uall` остаётся пуст) + повторный
# update-server-info переписывает байты .git/info/refs новой строкой.
# ОЖИДАНИЕ — ОБРАТНОЕ контролям 2/3 red_dotgit_info_exclude_024.sh: там
# правка `.git/info/*` красит (rc 1); здесь refs-дрейф ОБЯЗАН давать rc 0 —
# carve-out k11 существует ИМЕННО для того, чтобы этот сценарий не красил.
K2="$WORK/v2_refs_drift_${RANDOM}"
mk_main "$K2"
run_subj "$K2" --snapshot "$K2"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-2 "снимок" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
REFS_BEFORE="$WORK/refs_before_${RANDOM}"
cp "$K2/.git/info/refs" "$REFS_BEFORE"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$K2" branch feature-drift
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$K2" update-server-info
REFS_AFTER="$WORK/refs_after_${RANDOM}"
cp "$K2/.git/info/refs" "$REFS_AFTER"
# Sanity: байты ДЕЙСТВИТЕЛЬНО разные — иначе контроль не воспроизводит дрейф
# и ничего не проверяет (требование задания).
if cmp -s "$REFS_BEFORE" "$REFS_AFTER"; then
  fail контроль-2 "sanity дрейфа" \
    "содержимое .git/info/refs НЕ изменилось после branch+update-server-info — контроль не воспроизводит заявленную механику дрейфа"
fi
run_subj "$K2" --check "$K2"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-2 "легитимный дрейф refs" \
  "rc=$SUBJ_RC (ожидался 0 — ПОЛЯРНОСТЬ ОБРАТНАЯ: обычный git-дрейф .git/info/refs НЕ утечка, carve-out k11 3c6791d обязан молчать). Вывод: $SUBJ_OUT"
if has "$P_ZAGR"; then
  fail контроль-2 "легитимный дрейф refs" \
    "маркер «$P_ZAGR» присутствует — carve-out k11 не держит: обычный git-дрейф .git/info/refs ложно красит основной чекаут. Вывод: $SUBJ_OUT"
fi
has "$P_CHISTO" || fail контроль-2 "легитимный дрейф refs" \
  "нет маркера «$P_CHISTO» при rc=0 — противоречивый вывод детектора. Вывод: $SUBJ_OUT"
ok контроль-2 "новая ветка + update-server-info переписывает байты .git/info/refs (подтверждено cmp), --check: rc 0 «чисто»"

# ─── контроль 3: regression guard — .git/info/exclude по-прежнему красит ─────
# Доказывает, что carve-out k11 НЕ расширился на весь .git/info/*, а точечно
# на `refs`: та же механика, что контроль 3 red_dotgit_info_exclude_024.sh.
K3="$WORK/v3_exclude_still_red_${RANDOM}"
mk_main "$K3"
run_subj "$K3" --snapshot "$K3"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-3 "снимок" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
printf '# добавлено фикстурой: %s\n' "marker_${RANDOM}" >> "$K3/.git/info/exclude"
run_subj "$K3" --check "$K3"
[ "$SUBJ_RC" -eq 1 ] || fail контроль-3 "regression guard exclude" \
  "rc=$SUBJ_RC (ожидался 1) — carve-out k11 расширился за пределы .git/info/refs и перестал ловить правку .git/info/exclude (регрессия блокера Б1 ревью v1). Вывод: $SUBJ_OUT"
has "$P_ZAGR" || fail контроль-3 "regression guard exclude" \
  "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
has ".git/info/exclude" || fail контроль-3 "regression guard exclude" \
  "имя .git/info/exclude не названо. Вывод: $SUBJ_OUT"
ok контроль-3 "правка .git/info/exclude по-прежнему красит: rc 1, .git/info/exclude назван — carve-out k11 точечный на refs"

printf 'red_info_refs_drift_024: 3 контроля зелены (carve-out k11 3c6791d — refs-дрейф не красит, .git/info/exclude по-прежнему красит)\n' >&2
exit 0
