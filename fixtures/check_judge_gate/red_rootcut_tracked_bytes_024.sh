#!/usr/bin/env bash
# Респек-проба v6 контракта 024 — НОГА-1 «tracked-байты» корневого среза
# манифеста (РАЗРЕШИЛ владелец 2026-09-15, путь 1 из трёх; Н-89 — порочность
# перечисления носителей ослепления: 8 классов / 8 адверсарий-кругов).
#
# СПЕКА ЦЕЛЕВОГО, не текущего: мутация байтов tracked-файла при ЛЮБОМ
# состоянии даёт rc 1 с именем пути:
#   контроль 1 — чистый tracked (простая мутация после снимка);
#   контроль 2 — assume-unchanged ДО снимка (стабильный флаг) + мутация;
#   контроль 3 — skip-worktree ДО снимка (стабильный флаг) + мутация;
#   контроль 4 — правило .git/info/exclude на путь + мутация;
#   контроль 5 — правило .gitignore (committed) на путь + мутация;
#   контроль 6 — внешний core.excludesFile (правило до снимка) + мутация;
#   контроль 7 — индексная подсадка (update-index --cacheinfo, байты не
#               тронуты) — детализация ноги-1: строка несёт и sha256 байтов,
#               и sha1 staged-блоба (сегодня ловится XY-porcelain, срез
#               обязан сохранить закрытый класс; замер E8 матрицы 2026-09-15).
#
# РАЗЛИЧЕНИЕ текущее/целевое — контроль 8 (инвариант ПРЕДСТАВЛЕНИЯ, в
# артефакте-снимке): целевой манифест несёт строку с sha256 байтов КАЖДОГО
# tracked-пути (v6 нога-1: git ls-files -z), В ТОМ ЧИСЛЕ чистого пути без
# флагов и правил. Текущий код (porcelain-формы v5, HEAD 492ac4d) чистые
# пути в манифесте не представляет → контроль 8 умирает именованным ОТКАЗом
# «нога tracked-байтов отсутствует». Поведенческие контроли 1-7 ЗЕЛЕНЫ на
# текущем коде (замер матрицы 2026-09-15: rc=1 во всех семи формах; флаговые
# закрыты Б9-фиксом c46c65a) и ОБЯЗАНЫ остаться зелёными после
# переписывания — регрессионная спека: срез не имеет права потерять ни одну
# закрытую форму. Проба КРАСНА сейчас (умирает на контроле 8 с именованной
# причиной — это и есть краснота респека по прецеденту «красные тесты как
# контракт», red_norma_stroka_024 / И-10) и зеленеет после implementer-фикса.
#
# Форма — по прецеденту red_index_flags_024.sh: WORK вне дерева, TMPDIR
# редиректится в WORK (снимки субъекта читаемы пробой для контроля 8), имена
# мусора случайны КАЖДЫЙ прогон, toy только git init (НЕ worktree, грань
# Н-95 вне предмета). Имя ВНЕ case_*-глоба раннера НАМЕРЕННО (И-11).
#
# Коды возврата: 0 — все 8 контролей прошли (цель v6 достигнута); 1 —
#               именованный отказ (форма не ловится / нога отсутствует /
#               правка физически исчезла с диска).
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
SUBJ="$REPO/scripts/check_no_leak.sh"

[ -f "$SUBJ" ] || {
  printf 'ОТКАЗ: детектор отсутствует — scripts/check_no_leak.sh\n' >&2
  exit 1
}

# ЕДИНЫЙ источник фраз (Демаркация 024) — побайтово во всех проверках ниже.
P_ZAGR='основной чекаут загрязнён'
P_CHISTO='основной чекаут чист'

WORK="$(mktemp -d /tmp/red024-v6-tracked-bytes.XXXXXX)"   # А-78: свежий WORK вне дерева
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

# git для toy-репозиториев пробы: без глобального/системного конфига
# пользователя (воспроизводимость), hooks отключены, identity пробы.
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

# Постановка бита ДО снимка с подтверждением по ls-files -v (h/S реально встал).
settle_flag() {  # <каталог> <опция-update-index> <ожидаемый-флаг>
  local dir="$1" opt="$2" want="$3" got
  tgit -C "$dir" update-index "$opt" tracked.txt
  got="$(tgit -C "$dir" ls-files -v -- tracked.txt)"
  case "$got" in
    "$want"*) return 0 ;;
  esac
  printf 'sanity: флаг не встал (%s -> «%s», ожидался «%s …»)\n' \
    "$opt" "$got" "$want" >&2
  return 1
}

# Общие ассерты «мутация поймана»: rc 1, фраза, имя пути, байты живы на диске.
assert_caught() {  # <метка-контроля> <сценарий> <путь-в-toy> <файл-на-диске> <маркер-байтов>
  local meta="$1" scen="$2" path="$3" disk="$4" marker="$5"
  [ "$SUBJ_RC" -eq 1 ] || fail "$meta" "$scen" \
    "rc=$SUBJ_RC (ожидался 1) — мутация байтов tracked-пути не поймана. Вывод: $SUBJ_OUT"
  has "$P_ZAGR" || fail "$meta" "$scen" "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
  has "$path" || fail "$meta" "$scen" "имя $path не названо. Вывод: $SUBJ_OUT"
  if has "$P_CHISTO"; then
    fail "$meta" "$scen" "ложное «$P_CHISTO» при живой мутации. Вывод: $SUBJ_OUT"
  fi
  grep -qF "$marker" "$disk" || fail "$meta" "$scen" \
    "мутация физически исчезла с диска — сверка тронула чужой файл"
  ok "$meta" "$scen: rc 1, $path назван, байты живы на диске"
}

# ─── контроль 1: чистый tracked, простая мутация → rc 1 ─────────────────────────
K1="$WORK/k1_chistyj_${RANDOM}"
mk_main "$K1"
run_subj "$K1" --snapshot "$K1"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-1 "снимок" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
printf 'MUTATED CLEAN\n' >> "$K1/tracked.txt"
run_subj "$K1" --check "$K1"
assert_caught контроль-1 "чистый tracked, мутация" tracked.txt "$K1/tracked.txt" 'MUTATED CLEAN'

# ─── контроль 2: assume-unchanged ДО снимка, стабильный флаг, мутация → rc 1 ───
K2="$WORK/k2_assume_${RANDOM}"
mk_main "$K2"
settle_flag "$K2" --assume-unchanged h \
  || fail контроль-2 "постановка бита" "sanity выше — флаг assume-unchanged не встал"
run_subj "$K2" --snapshot "$K2"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-2 "снимок" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
printf 'MUTATED AU\n' >> "$K2/tracked.txt"
# Sanity: правка НЕ отражается в porcelain (иначе механика не флаговая).
PORC="$(tgit -C "$K2" status --porcelain -uall --no-renames --ignore-submodules=none 2>/dev/null)"
if printf '%s' "$PORC" | grep -qF 'tracked.txt'; then
  fail контроль-2 "sanity porcelain" "porcelain видит правку — флаг не ослепляет, механика контроля не та"
fi
run_subj "$K2" --check "$K2"
assert_caught контроль-2 "assume-unchanged до снимка + мутация" tracked.txt "$K2/tracked.txt" 'MUTATED AU'

# ─── контроль 3: skip-worktree ДО снимка, стабильный флаг, мутация → rc 1 ──────
K3="$WORK/k3_skip_${RANDOM}"
mk_main "$K3"
settle_flag "$K3" --skip-worktree S \
  || fail контроль-3 "постановка бита" "sanity выше — флаг skip-worktree не встал"
run_subj "$K3" --snapshot "$K3"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-3 "снимок" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
printf 'MUTATED SW\n' >> "$K3/tracked.txt"
PORC="$(tgit -C "$K3" status --porcelain -uall --no-renames --ignore-submodules=none 2>/dev/null)"
if printf '%s' "$PORC" | grep -qF 'tracked.txt'; then
  fail контроль-3 "sanity porcelain" "porcelain видит правку — флаг не ослепляет, механика контроля не та"
fi
run_subj "$K3" --check "$K3"
assert_caught контроль-3 "skip-worktree до снимка + мутация" tracked.txt "$K3/tracked.txt" 'MUTATED SW'

# ─── контроль 4: правило .git/info/exclude на путь + мутация → rc 1 ────────────
# Механика: ignore-правила на TRACKED-путь porcelain не ослепляют (sanity это
# проверяет) — контроль специфицирует, что целевая нога-1 судит байты, не
# спрашивая ignore-правил вовсе (в v6 источник — ls-files, а не porcelain).
K4="$WORK/k4_exclude_${RANDOM}"
mk_main "$K4"
printf 'tracked*\n' >> "$K4/.git/info/exclude"
run_subj "$K4" --snapshot "$K4"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-4 "снимок" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
printf 'MUTATED EX\n' >> "$K4/tracked.txt"
PORC="$(tgit -C "$K4" status --porcelain -uall --no-renames --ignore-submodules=none 2>/dev/null)"
printf '%s' "$PORC" | grep -qF 'tracked.txt' \
  || fail контроль-4 "sanity porcelain" "porcelain НЕ видит правку tracked-пути под exclude-правилом — механика контроля не та"
run_subj "$K4" --check "$K4"
assert_caught контроль-4 "exclude-правило + мутация tracked" tracked.txt "$K4/tracked.txt" 'MUTATED EX'

# ─── контроль 5: правило .gitignore (committed) на путь + мутация → rc 1 ───────
K5="$WORK/k5_gitignore_${RANDOM}"
mk_main "$K5"
printf 'tracked*\n' > "$K5/.gitignore"
tgit -C "$K5" add -A
tgit -C "$K5" commit -q -m 'toy gitignore'
run_subj "$K5" --snapshot "$K5"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-5 "снимок" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
printf 'MUTATED GI\n' >> "$K5/tracked.txt"
PORC="$(tgit -C "$K5" status --porcelain -uall --no-renames --ignore-submodules=none 2>/dev/null)"
printf '%s' "$PORC" | grep -qF 'tracked.txt' \
  || fail контроль-5 "sanity porcelain" "porcelain НЕ видит правку tracked-пути под .gitignore-правилом — механика контроля не та"
run_subj "$K5" --check "$K5"
assert_caught контроль-5 "gitignore-правило + мутация tracked" tracked.txt "$K5/tracked.txt" 'MUTATED GI'

# ─── контроль 6: внешний core.excludesFile (правило до снимка) + мутация ───────
K6="$WORK/k6_extexc_${RANDOM}"
mk_main "$K6"
EXTRULES="$WORK/ext_rules_${RANDOM}.txt"
printf 'tracked*\n' > "$EXTRULES"
tgit -C "$K6" config core.excludesFile "$EXTRULES"
run_subj "$K6" --snapshot "$K6"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-6 "снимок" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
printf 'MUTATED EF\n' >> "$K6/tracked.txt"
PORC="$(tgit -C "$K6" status --porcelain -uall --no-renames --ignore-submodules=none 2>/dev/null)"
printf '%s' "$PORC" | grep -qF 'tracked.txt' \
  || fail контроль-6 "sanity porcelain" "porcelain НЕ видит правку tracked-пути под внешним правилом — механика контроля не та"
run_subj "$K6" --check "$K6"
assert_caught контроль-6 "внешний excludesFile + мутация tracked" tracked.txt "$K6/tracked.txt" 'MUTATED EF'

# ─── контроль 7: индексная подсадка, байты не тронуты → rc 1 ───────────────────
# Детализация ноги-1 (v6): staged-ша1 в строке манифеста. Сегодня класс закрыт
# XY-porcelain (замер E8: rc=1, «загрязнён: tracked.txt»); байтовая нога без
# staged-ша1 подсадку НЕ видит — срез обязан сохранить класс закрытым.
K7="$WORK/k7_indexplant_${RANDOM}"
mk_main "$K7"
OTHER="$WORK/other_${RANDOM}.txt"
printf 'planted blob content\n' > "$OTHER"
run_subj "$K7" --snapshot "$K7"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-7 "снимок" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
BLOB="$(tgit -C "$K7" hash-object -w "$OTHER")"
tgit -C "$K7" update-index --cacheinfo 100644,"$BLOB",tracked.txt
# Sanity: байты рабочего файла не тронуты (мутация ТОЛЬКО индексная).
grep -qF 'original' "$K7/tracked.txt" \
  || fail контроль-7 "sanity байтов" "рабочие байты изменились — это не индексная подсадка"
run_subj "$K7" --check "$K7"
assert_caught контроль-7 "индексная подсадка без правки байтов" tracked.txt "$K7/tracked.txt" 'original'

# ─── контроль 8: инвариант ПРЕДСТАВЛЕНИЯ (различение текущее/целевое) ──────────
# Целевой манифест (v6 нога-1) обязан представлять КАЖДЫЙ tracked-путь строкой
# с sha256 байтов — на ЧИСТОМ дереве, без флагов и правил. Оракул — в
# артефакте-снимке (правило 8: файл снимка лежит в TMPDIR пробы, дерево
# субъекта не перечитывается как истина). Текущий код чистых путей не
# представляет → именованный ОТКАЗ; это краснота респека: проба различает
# текущее (porcelain-формы) и целевое (ls-files -z → sha256 КАЖДОГО пути).
K8="$WORK/k8_invariant_${RANDOM}"
mk_main "$K8"
run_subj "$K8" --snapshot "$K8"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-8 "снимок" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
# Путь снимка — ровно как считает субъект: hash8 от канонического корня K8
# (контроли 1-7 снимают ДРУГИЕ корни в тот же TMPDIR — glob '*/*/porcelain'
# взял бы чужой снимок, выбираем свой по hash8).
CANON8="$(cd "$K8" && pwd -P)"
H8="$(printf '%s' "$CANON8" | sha256sum)"
H8="${H8%% *}"; H8="${H8:0:8}"
SNAP="$WORK/snaps/dev-harness-leak/$H8/porcelain"
[ -f "$SNAP" ] || fail контроль-8 "снимок-файл" "файл снимка K8 не найден: $SNAP"
SNAPLINE="$(grep -P '\ttracked\.txt$' "$SNAP" 2>/dev/null)"
if [ -z "$SNAPLINE" ]; then
  fail контроль-8 "нога tracked-байтов отсутствует" \
    "024-v6: чистый tracked-путь tracked.txt НЕ представлен в манифесте снимка (цель: git ls-files -z -> sha256 байтов КАЖДОГО tracked-пути; текущее: porcelain-формы v5 представляют только изменённые пути) — корневой срез не реализован"
fi
printf '%s\n' "$SNAPLINE" | grep -qE '[0-9a-f]{64}' \
  || fail контроль-8 "нога tracked-байтов отсутствует" \
    "024-v6: строка tracked.txt есть, но без sha256 байтов (64-hex) — представление не байтовое"
ok контроль-8 "инвариант представления: чистый tracked-путь несёт байтовую строку манифеста"

printf 'red_rootcut_tracked_bytes_024: 8 контролей зелены (v6 нога-1: мутация байтов tracked-пути при любом состоянии/флаге/правиле/подсадке даёт rc 1 с именем; каждый tracked-путь представлен байтами в манифесте)\n' >&2
exit 0
