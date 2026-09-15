#!/usr/bin/env bash
# Красный контрпример блокера Б6 адверсария к9 contracts-024-k9.md
# (фикс-круг после 719b7cb, контракт 024):
#
#   Второй носитель ослепления источника манифеста, ВНЕ `.git`: субагент
#   кладёт НОВЫЙ каталог с `.gitignore`, первая строка которого игнорирует
#   сам `.gitignore`, вторая — файл утечки. Оба пути исчезают из
#   `git status --porcelain -uall` (каждый под собственным правилом), каталог
#   не показывается даже с -uall (внутри нет ничего неисключённого),
#   dot-git-обход к рабочему дереву не относится: до фикса детектор не видел
#   НИ сам `.gitignore`, НИ утечку ⇒ rc 0 «основной чекаут чист» при живой
#   утечке на диске. Тот же класс, что Б1 ревью v1 (`.git/info/exclude`):
#   ignore-правило приносит сама утечка. Репро адверсария:
#   /tmp/dev-harness-verify/k9_blind_porcelain.py (игрушка B).
#
# ФИКСТУРА ПРЕДЪЯВЛЯЕТ ТРИ КОНТРОЛЯ:
#   * контроль 1 (честный вход: закоммиченный корневой `.gitignore`, как у
#     реального проекта, НЕ меняется между снимком и сверкой) — rc 0 «чисто»:
#     walk не даёт ложных тревог на легитимном `.gitignore` (строка WTIGNORE
#     присутствует в ОБОИХ манифестах и не даёт дельты).
#   * контроль 2 (НОВЫЙ подкаталог с самоигнорирующимся `.gitignore` +
#     файл утечки рядом) — rc 1, путь `.gitignore` назван: новая строка
#     WTIGNORE от нового файла ⇒ дельта; утечка физически жива на диске.
#   * контроль 3 (мутация СУЩЕСТВУЮЩЕГО на снимке самоигнорирующегося
#     `.gitignore` — правка байтов, БЕЗ новой утечки) — rc 1, путь назван:
#     смена sha256 содержимого ⇒ новая строка WTIGNORE ⇒ дельта. Аналог
#     контроля 3 red_dotgit_info_exclude_024.sh (правка самого rules-файла
#     детектируется и без новой утечки; porcelain её по-прежнему не видит).
#
# ЗАКРЫТИЕ КЛАССА (что делает контроли 2/3 зелёными): producer
# emit_gitignore_walk в scripts/check_no_leak.sh (коммит 6a94f76,
# landed 719b7cb): функция — строки 642-658, строка манифеста
# `WTIGNORE:<sha>\t<отн-путь>` — строка 656, обход `find <root> -name
# .gitignore -type f -not-path "<root>/.git/*"` — строка 657 (find пинован
# через $FIND/TRUSTED_PATH — строки 344-350); подключение в manifest() —
# строка 684 (out_d). НОВЫЙ `.gitignore` (отсутствовавший на снимке) ИЛИ
# правка байтов существующего — новая строка манифеста ⇒ дельта ⇒ rc 1
# именованный. Сама утечка под правилом остаётся невидимой (вне 024) —
# но факт появления/изменения носителя правила детектируется, симметрично
# `.git/info/exclude` (Б1 ревью v1).
#
# При откате фикса (producer удалён из manifest()): porcelain пуст,
# dot-git неизменен ⇒ rc 0 «чисто» при живой утечке ⇒ контроли 2/3 КРАСНЫ
# (фикстура rc 1) — регрессия ловится. Проверено прогоном на пред-фикс
# блобе d0bae82:scripts/check_no_leak.sh (1837d4b1) git-plumbing swap/restore
# по прецеденту А-142.
#
# Форма — по прецеденту red_toctou_manifest_024.sh и
# red_dotgit_info_exclude_024.sh: собственный WORK вне дерева, TMPDIR
# редиректится в WORK, имена мусора случайны КАЖДЫЙ прогон, toy-репозиторий
# только `git init` (каталог .git — НЕ worktree-чекаут, узкая грань Н-95
# вне предмета). Имя ВНЕ case_*-глоба раннера НАМЕРЕННО (И-11 контракта 024).
#
# Коды возврата: 0 — все три контроля прошли (фикс работает); 1 — именованный
#               отказ (детектор отсутствует, ложное «чисто» при живой
#               утечке, путь `.gitignore` не назван, ИЛИ файлы утечки
#               физически исчезли с диска).
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

WORK="$(mktemp -d /tmp/red024-k9-b6-gitignore-selfhide.XXXXXX)"   # А-78: свежий WORK вне дерева
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/snaps"
export TMPDIR="$WORK/snaps"                       # снимки субъекта — в скратч прогона

ok()   { printf '  ok   %s (%s)\n' "$1" "$2" >&2; }
fail() { printf 'ОТКАЗ %s (%s): %s\n' "$1" "$2" "$3" >&2; exit 1; }

# Запуск субъекта: cwd=arg1, аргументы дальше — rc без пайпов (Н-84/Н-85).
run_subj() {
  local cwd="$1"; shift
  SUBJ_OUT="$( cd "$cwd" && bash "$SUBJ" "$@" 2>&1 )" && SUBJ_RC=0 || SUBJ_RC=$?
}
has() { printf '%s\n' "$SUBJ_OUT" | grep -qF -- "$1"; }

# git для toy-репозиториев фикстуры: без глобального/системного конфига
# пользователя (воспроизводимость), hooks отключены, identity фикстуры.
tgit() {
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}

# Живой git-чекаут toy: tracked.txt + ЗАКОММИЧЕННЫЙ корневой `.gitignore`
# («# root rules» — зеркало корневого `.gitignore` реального проекта:
# легитимный носитель правил, присутствующий в ОБОИХ манифестах).
mk_main() {  # <каталог>
  mkdir -p "$1"
  printf 'original\n' > "$1/tracked.txt"
  printf '# root rules\n' > "$1/.gitignore"
  tgit init -q -b main "$1"
  tgit -C "$1" add -A
  tgit -C "$1" commit -q -m 'toy main'
}

# ─── контроль 1: честный вход (корневой .gitignore не меняется) → rc 0 ────────
# До фикса этот контроль тоже rc 0. Стоит здесь, чтобы при РЕГРЕССИИ фикса
# (walk удалён/сломан) контроль 1 продолжал проходить, а контроли 2/3 —
# падали: контроль 1 защищает «фикс не сломал существующее» (walk видит
# легитимный `.gitignore` в обоих манифестах и НЕ красит), контроли 2/3 —
# «фикс закрывает класс Б6».
K1="$WORK/v1_chestnyj_${RANDOM}"
mk_main "$K1"
run_subj "$K1" --snapshot "$K1"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-1 "честный снимок" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
run_subj "$K1" --check "$K1"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-1 "честный вход" \
  "rc=$SUBJ_RC (ожидался 0) — walk WTIGNORE дал ложную тревогу на неменяющемся закоммиченном .gitignore. Вывод: $SUBJ_OUT"
has "$P_CHISTO" || fail контроль-1 "честный вход" \
  "нет маркера «$P_CHISTO». Вывод: $SUBJ_OUT"
ok контроль-1 "честный вход с закоммиченным корневым .gitignore: rc 0 «чисто»"

# ─── контроль 2: новый подкаталог с самоигнорирующимся .gitignore → rc 1 ──────
# МЕХАНИКА. После снимка создаётся подкаталог: `.gitignore` с ПЕРВОЙ строкой
# `.gitignore` (правило игнорирует сам файл) и второй — имя утечки; утечка
# лежит рядом. Porcelain не показывает ни `.gitignore`, ни утечку, ни каталог
# (внутри всё исключено); единственный сигнал — НОВАЯ строка WTIGNORE от
# нового `.gitignore`. Без walk'а (пред-фикс d0bae82) дельта пуста ⇒
# rc 0 «чисто» при живой утечке на диске — это и есть блокер Б6 к9.
K2="$WORK/v2_selfhide_${RANDOM}"
SUB="subagent_out_${RANDOM}"
mk_main "$K2"
run_subj "$K2" --snapshot "$K2"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-2 "снимок" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
mkdir -p "$K2/$SUB"
printf '.gitignore\nleak.txt\n' > "$K2/$SUB/.gitignore"
printf 'LEAKED BY SUBAGENT\n' > "$K2/$SUB/leak.txt"
# Sanity: ни .gitignore, ни утечка, ни каталог НЕ отражаются в porcelain
# (иначе это не механика Б6, а обычная ??-запись, которую ловил и старый код).
PORCELAIN="$(tgit -C "$K2" status --porcelain -uall --no-renames --ignore-submodules=none 2>/dev/null)"
if printf '%s' "$PORCELAIN" | grep -qF "$SUB"; then
  fail контроль-2 "sanity porcelain" \
    "подкаталог $SUB виден в porcelain («$PORCELAIN») — механика Б6 не воспроизведена"
fi
run_subj "$K2" --check "$K2"
[ "$SUBJ_RC" -eq 1 ] || fail контроль-2 "самоигнорирующий .gitignore прячет утечку" \
  "rc=$SUBJ_RC (ожидался 1) — новый самоигнорирующий .gitignore и утечка под ним невидимы, дельта пуста ⇒ ложный «чисто» при живой утечке (блокер Б6 к9). Вывод: $SUBJ_OUT"
has "$P_ZAGR" || fail контроль-2 "самоигнорирующий .gitignore прячет утечку" \
  "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
has "$SUB/.gitignore" || fail контроль-2 "самоигнорирующий .gitignore прячет утечку" \
  "путь $SUB/.gitignore не назван. Вывод: $SUBJ_OUT"
if has "$P_CHISTO"; then
  fail контроль-2 "самоигнорирующий .gitignore прячет утечку" \
    "ложный маркер «$P_CHISTO» при живой утечке на диске. Вывод: $SUBJ_OUT"
fi
# Утечка и её носитель физически живы на диске (сверка не удаляет чужие файлы):
[ -f "$K2/$SUB/.gitignore" ] || fail контроль-2 "диск" \
  "$SUB/.gitignore физически исчез с диска — сверка тронула чужой файл"
grep -qF 'LEAKED BY SUBAGENT' "$K2/$SUB/leak.txt" || fail контроль-2 "диск" \
  "утечка $SUB/leak.txt физически исчезла с диска — сверка тронула чужой файл"
ok контроль-2 "новый подкаталог с самоигнорирующим .gitignore + утечка: rc 1, $SUB/.gitignore назван, файлы живы на диске"

# ─── контроль 3: правка СУЩЕСТВУЮЩЕГО на снимке .gitignore → rc 1 ─────────────
# МЕХАНИКА. ДО снимка в toy существует подкаталог с самоигнорирующимся
# `.gitignore` (правка-носитель уже на снимке — walk фиксирует его sha).
# После снимка правятся БАЙТЫ этого `.gitignore` (дописывается строка-
# комментарий), НОВАЯ утечка не создаётся. Porcelain по-прежнему пуст
# (файл под собственным правилом), новая утечка не нужна: сама правка
# носителя правил — дельта (смена sha ⇒ новая строка WTIGNORE), ровно как
# правка `.git/info/exclude` в контроле 3 red_dotgit_info_exclude_024.sh.
# Без walk'а (пред-фикс) файл не входил ни в один манифест ⇒ rc 0 «чисто».
K3="$WORK/v3_mutacija_${RANDOM}"
SUB3="suwestvujushhij_${RANDOM}"
mk_main "$K3"
mkdir -p "$K3/$SUB3"
printf '.gitignore\nskryvaem_%s.tmp\n' "${RANDOM}" > "$K3/$SUB3/.gitignore"
# Sanity ДО снимка: самоигнорирующийся .gitignore не виден в porcelain —
# иначе на снимке появилась бы ??-запись и механика контроля была бы другой.
PORCELAIN="$(tgit -C "$K3" status --porcelain -uall --no-renames --ignore-submodules=none 2>/dev/null)"
if printf '%s' "$PORCELAIN" | grep -qF "$SUB3"; then
  fail контроль-3 "sanity porcelain до снимка" \
    "подкаталог $SUB3 виден в porcelain ДО снимка («$PORCELAIN») — механика Б6 не воспроизведена"
fi
run_subj "$K3" --snapshot "$K3"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-3 "снимок" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
printf '# dobavleno fijsturoj: marker_%s\n' "${RANDOM}" >> "$K3/$SUB3/.gitignore"
PORCELAIN="$(tgit -C "$K3" status --porcelain -uall --no-renames --ignore-submodules=none 2>/dev/null)"
if printf '%s' "$PORCELAIN" | grep -qF "$SUB3"; then
  fail контроль-3 "sanity porcelain" \
    "правка $SUB3/.gitignore видна в porcelain («$PORCELAIN») — механика Б6 не воспроизведена"
fi
run_subj "$K3" --check "$K3"
[ "$SUBJ_RC" -eq 1 ] || fail контроль-3 "правка существующего .gitignore без утечки" \
  "rc=$SUBJ_RC (ожидался 1) — правка байтов существующего самоигнорирующегося .gitignore не детектируется (файл был на снимке, porcelain его не видит, walk не ловит смену sha). Вывод: $SUBJ_OUT"
has "$P_ZAGR" || fail контроль-3 "правка существующего .gitignore без утечки" \
  "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
has "$SUB3/.gitignore" || fail контроль-3 "правка существующего .gitignore без утечки" \
  "путь $SUB3/.gitignore не назван. Вывод: $SUBJ_OUT"
if has "$P_CHISTO"; then
  fail контроль-3 "правка существующего .gitignore без утечки" \
    "ложный маркер «$P_CHISTO» при правке носителя правил. Вывод: $SUBJ_OUT"
fi
ok контроль-3 "правка существующего на снимке .gitignore без новой утечки: rc 1, $SUB3/.gitignore назван"

printf 'red_gitignore_selfhide_024: 3 контроля зелены (блокер Б6 к9 — самоигнорирующий worktree .gitignore ловится walk-ом WTIGNORE: новый файл и правка существующего)\n' >&2
exit 0
