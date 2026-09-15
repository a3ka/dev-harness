#!/usr/bin/env bash
# Красный контрпример блокера Б5 адверсария к9 contracts-024-k9.md
# (фикс-круг после 719b7cb, контракт 024):
#
#   Биты `git update-index --assume-unchanged` / `--skip-worktree` живут в
#   `.git/index` и заставляют git не сравнивать рабочие байты tracked-файла
#   с индексом: `git status --porcelain -uall` пуст ПРИ ЖИВОЙ правке байтов
#   tracked-файла. До фикса `.git/index` не входил ни в porcelain-манифест
#   (emit_manifest), ни в dot-git-обход (emit_dotgit_manifest); состояние
#   СТАБИЛЬНО (гонки нет — двойное чтение Б4 не помогает), обе половины
#   манифеста согласованы со снимком ⇒ дельта пуста ⇒ rc 0 «основной чекаут
#   чист» при физически изменённом tracked-файле. Репро адверсария:
#   /tmp/dev-harness-verify/k9_blind_porcelain.py (игрушка A) и
#   /tmp/dev-harness-verify/k9_final.py (часть J — на самом судимом клоне,
#   tracked ROADMAP.md, disk_differs=True при «чисто»).
#
# ФИКСТУРА ПРЕДЪЯВЛЯЕТ ТРИ КОНТРОЛЯ:
#   * контроль 1 (честный вход, биты не ставятся) — rc 0 «чисто»: новый
#     producer не даёт ложных тревог на дефолтном all-H индексе.
#   * контроль 2 (assume-unchanged ПОСЛЕ снимка, затем правка байтов
#     tracked-файла) — rc 1, имя файла в выводе: бит ставится МЕЖДУ снимком
#     и правкой, переход флага H→h обязан быть виден в дельте как НОВАЯ
#     строка INDEXFLAG (porcelain при этом пуст — механика именно Б5,
#     а не обычная M-запись, которую ловил и старый код).
#   * контроль 3 (skip-worktree аналогично, переход H→S) — rc 1, имя файла.
#
# ЗАКРЫТИЕ КЛАССА (что делает контроли 2/3 зелёными): producer
# emit_index_flags_manifest в scripts/check_no_leak.sh (коммит 6a94f76,
# landed 719b7cb): функция — строки 596-619, чтение `git ls-files -v` —
# строка 603, пропуск дефолтного флага H — строки 612-614, строка манифеста
# `INDEXFLAG:<flag>\t<path>` — строка 616; подключение в manifest() — строка
# 681 (out_c). Наблюдаемая величина — флаги `git ls-files -v` (H/h/S/s),
# меняющиеся РОВНО при постановке/снятии бита: побайтовый хеш `.git/index`
# непригоден (индекс легитимно переписывается самим `git status` при
# refresh stat-кэша — направление нащупано адверсарием к9). Постановка бита
# ПОСЛЕ снимка ⇒ новая строка манифеста ⇒ дельта ⇒ rc 1 именованный.
#
# При откате фикса (producer удалён из manifest()): porcelain пуст,
# dot-git неизменен ⇒ rc 0 «чисто» при живой правке ⇒ контроли 2/3 КРАСНЫ
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
#               отказ (детектор отсутствует, бит не поставился, ложное
#               «чисто» при живой правке, имя файла не названо, ИЛИ правка
#               физически исчезла с диска).
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

WORK="$(mktemp -d /tmp/red024-k9-b5-index-flags.XXXXXX)"   # А-78: свежий WORK вне дерева
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

# Живой git-чекаут toy: tracked.txt закоммичен (объект атаки всех контролей).
mk_main() {  # <каталог>
  mkdir -p "$1"
  printf 'original\n' > "$1/tracked.txt"
  tgit init -q -b main "$1"
  tgit -C "$1" add -A
  tgit -C "$1" commit -q -m 'toy main'
}

# Постановка бита с подтверждением по ls-files -v, что флаг РЕАЛЬНО встал
# (h = assume-unchanged, S = skip-worktree) — иначе атака не приземлилась
# и красный контроль ничего не доказывает.
settle_flag() {  # <каталог> <опция-update-index> <ожидаемый-флаг>
  local dir="$1" opt="$2" want="$3" got
  tgit -C "$dir" update-index "$opt" tracked.txt
  got="$(tgit -C "$dir" ls-files -v -- tracked.txt)"
  case "$got" in
    "$want"*) return 0 ;;
  esac
  printf 'sanity: флаг не встал (%s → «%s», ожидался «%s …») — механика Б5 не воспроизведена\n' \
    "$opt" "$got" "$want" >&2
  return 1
}

# ─── контроль 1: честный вход (биты не ставятся) → rc 0 «чисто» ────────────────
# До фикса этот контроль тоже rc 0 (битов нет). Стоит здесь, чтобы при
# РЕГРЕССИИ фикса (producer удалён/сломан) контроль 1 продолжал проходить,
# а контроли 2/3 — падали: контроль 1 защищает «фикс не сломал существующее»,
# контроли 2/3 — «фикс закрывает класс Б5».
K1="$WORK/v1_chestnyj_${RANDOM}"
mk_main "$K1"
run_subj "$K1" --snapshot "$K1"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-1 "честный снимок" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
run_subj "$K1" --check "$K1"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-1 "честный вход" \
  "rc=$SUBJ_RC (ожидался 0) — producer INDEXFLAG дал ложную тревогу на дефолтном all-H индексе. Вывод: $SUBJ_OUT"
has "$P_CHISTO" || fail контроль-1 "честный вход" \
  "нет маркера «$P_CHISTO». Вывод: $SUBJ_OUT"
ok контроль-1 "честный вход без битов: rc 0 «чисто»"

# ─── контроль 2: assume-unchanged ПОСЛЕ снимка + правка байтов → rc 1 ─────────
# МЕХАНИКА. Снимок пишется при чистом индексе (все флаги H, строк INDEXFLAG
# нет). Затем ставится бит --assume-unchanged и правятся байты tracked.txt.
# Porcelain пуст (бит ослепляет git status), .git/hooks|info|config не
# тронуты — единственный сигнал это НОВАЯ строка INDEXFLAG:h от перехода
# флага H→h. Без producer'а (пред-фикс d0bae82) обе половины манифеста
# согласованы со снимком ⇒ rc 0 «чисто» при живой правке на диске —
# это и есть блокер Б5 к9.
K2="$WORK/v2_assume_${RANDOM}"
mk_main "$K2"
run_subj "$K2" --snapshot "$K2"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-2 "снимок" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
settle_flag "$K2" --assume-unchanged h \
  || fail контроль-2 "постановка бита" "sanity выше — флаг assume-unchanged не встал"
printf 'LEAKED BY SUBAGENT\n' >> "$K2/tracked.txt"
# Sanity: правка действительно НЕ отражается в porcelain (иначе это не
# механика Б5, а обычная M-запись, которую ловил и старый код).
PORCELAIN="$(tgit -C "$K2" status --porcelain -uall --no-renames --ignore-submodules=none 2>/dev/null)"
if printf '%s' "$PORCELAIN" | grep -qF 'tracked.txt'; then
  fail контроль-2 "sanity porcelain" \
    "правка tracked.txt видна в porcelain («$PORCELAIN») — механика Б5 не воспроизведена"
fi
run_subj "$K2" --check "$K2"
[ "$SUBJ_RC" -eq 1 ] || fail контроль-2 "assume-unchanged прячет правку" \
  "rc=$SUBJ_RC (ожидался 1) — бит ослепил porcelain, дельта пуста ⇒ ложный «чисто» при живой правке tracked.txt (блокер Б5 к9). Вывод: $SUBJ_OUT"
has "$P_ZAGR" || fail контроль-2 "assume-unchanged прячет правку" \
  "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
has 'tracked.txt' || fail контроль-2 "assume-unchanged прячет правку" \
  "имя tracked.txt не названо. Вывод: $SUBJ_OUT"
if has "$P_CHISTO"; then
  fail контроль-2 "assume-unchanged прячет правку" \
    "ложный маркер «$P_CHISTO» при живой правке на диске. Вывод: $SUBJ_OUT"
fi
# Утечка физически жива на диске (сверка не удаляет и не правит чужие байты):
grep -qF 'LEAKED BY SUBAGENT' "$K2/tracked.txt" || fail контроль-2 "диск" \
  "правка tracked.txt физически исчезла с диска — сверка тронула чужой файл"
ok контроль-2 "assume-unchanged после снимка + правка байтов: rc 1, tracked.txt назван, правка жива на диске"

# ─── контроль 3: skip-worktree аналогично (переход H→S) → rc 1 ────────────────
# Тот же класс, второй бит: флаг S в ls-files -v. Отдельный контроль, а не
# параметр контроля 2: у битов РАЗНЫЕ семантики в git (assume-unchanged —
# обещание «файл не менялся», skip-worktree — «рабочую копию не трогаю»),
# закрываются они ОДНИМ условием case ≠ H — регрессия может уронить один
# переход, сохранив другой.
K3="$WORK/v3_skipworktree_${RANDOM}"
mk_main "$K3"
run_subj "$K3" --snapshot "$K3"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-3 "снимок" \
  "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
settle_flag "$K3" --skip-worktree S \
  || fail контроль-3 "постановка бита" "sanity выше — флаг skip-worktree не встал"
printf 'LEAKED BY SUBAGENT\n' >> "$K3/tracked.txt"
PORCELAIN="$(tgit -C "$K3" status --porcelain -uall --no-renames --ignore-submodules=none 2>/dev/null)"
if printf '%s' "$PORCELAIN" | grep -qF 'tracked.txt'; then
  fail контроль-3 "sanity porcelain" \
    "правка tracked.txt видна в porcelain («$PORCELAIN») — механика Б5 не воспроизведена"
fi
run_subj "$K3" --check "$K3"
[ "$SUBJ_RC" -eq 1 ] || fail контроль-3 "skip-worktree прячет правку" \
  "rc=$SUBJ_RC (ожидался 1) — бит ослепил porcelain, дельта пуста ⇒ ложный «чисто» при живой правке tracked.txt (блокер Б5 к9). Вывод: $SUBJ_OUT"
has "$P_ZAGR" || fail контроль-3 "skip-worktree прячет правку" \
  "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
has 'tracked.txt' || fail контроль-3 "skip-worktree прячет правку" \
  "имя tracked.txt не названо. Вывод: $SUBJ_OUT"
if has "$P_CHISTO"; then
  fail контроль-3 "skip-worktree прячет правку" \
    "ложный маркер «$P_CHISTO» при живой правке на диске. Вывод: $SUBJ_OUT"
fi
grep -qF 'LEAKED BY SUBAGENT' "$K3/tracked.txt" || fail контроль-3 "диск" \
  "правка tracked.txt физически исчезла с диска — сверка тронула чужой файл"
ok контроль-3 "skip-worktree после снимка + правка байтов: rc 1, tracked.txt назван, правка жива на диске"

printf 'red_index_flags_024: 3 контроля зелены (блокер Б5 к9 — assume-unchanged/skip-worktree ослепление porcelain ловится переходом флага H→h/S в INDEXFLAG-строке манифеста)\n' >&2
exit 0
