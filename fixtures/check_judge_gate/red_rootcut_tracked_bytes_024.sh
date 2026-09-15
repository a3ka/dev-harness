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
# РАЗЛИЧЕНИЕ текущее/целевое — контроль 8 (инвариант ПРЕДСТАВЛЕНИЯ с оракулом
# ЗНАЧЕНИЯ, ДВУХСОСТОЯННЫЙ — арбитраж orakul-podsmotrennaya-konstanta-024,
# РЕШЕНИЕ вопрос 1): целевой манифест несёт строку с sha256 байтов КАЖДОГО
# tracked-пути (v6 нога-1: git ls-files -z), В ТОМ ЧИСЛЕ чистого пути без
# флагов и правил — В ОБОИХ состояниях: A (снимок) и B (после перезаписи
# байтов, повторный снимок того же корня). Имя и байты входа — СЛУЧАЙНЫ на
# каждый прогон (подсмотренная константа предсказуема при авторстве
# контрмодели — З1 арбитража); отпечаток сверяется с вычисленным ПРОБОЙ ДО
# вызова субъекта (независимая исходная истина, блокер вердикта 873b81b).
# Форма «какой-то 64-hex» — именованный ОТКАЗ «несовпадение отпечатка»;
# заморозка/эхо между состояниями A и B (строка не меняется вместе с
# байтами) — именованный ОТКАЗ «представление не следит за байтами»; честные
# ноги контрмоделей пробой не краснятся (Н-39/А-147). Текущий код
# (porcelain-формы v5) чистые пути в манифесте не представляет → контроль 8
# умирает в фазе A именованным ОТКАЗом «нога tracked-байтов отсутствует».
# Поведенческие контроли 1-7 ЗЕЛЕНЫ на текущем коде (замер матрицы
# 2026-09-15: rc=1 во всех семи формах; флаговые закрыты Б9-фиксом c46c65a)
# и ОБЯЗАНЫ остаться зелёными после переписывания — регрессионная спека:
# срез не имеет права потерять ни одну закрытую форму. Проба КРАСНА сейчас
# (умирает на контроле 8 с именованной причиной — это и есть краснота
# респека по прецеденту «красные тесты как контракт», red_norma_stroka_024 /
# И-10) и зеленеет после implementer-фикса.
#
# Форма — по прецеденту red_index_flags_024.sh: WORK вне дерева, TMPDIR
# редиректится в WORK (снимки субъекта читаемы пробой для контроля 8), имена
# мусора случайны КАЖДЫЙ прогон, оракулируемый вход (имя И байты tracked-
# объекта атаки) — случаен на КАЖДЫЙ прогон отдельным источником энтропии
# (entropy(), см. ниже), toy только git init (НЕ worktree, грань Н-95 вне
# предмета). Имя ВНЕ case_*-глоба раннера НАМЕРЕННО (И-11).
#
# Коды возврата: 0 — все 8 контролей прошли (цель v6 достигнута); 1 —
#               именованный отказ (форма не ловится / нога отсутствует /
#               представление не следит за байтами / правка физически
#               исчезла с диска).
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

# Оракул независимой исходной истины (блокер вердикта критика 873b81b):
# проба вычисляет ожидаемые отпечатки САМА — пин sha256sum из TRUSTED_PATH
# ровно как в субъекте (/usr/bin /bin /usr/local/bin -> command -v) +
# sanity-хэш пустого ввода (класс S-path-forged-sha256 субъекта).
TP=""
for d in /usr/bin /bin /usr/local/bin; do
  [ -d "$d" ] && TP="${TP:+$TP:}$d"
done
SHA256SUM_PIN="$(PATH="$TP" command -v sha256sum)"
[ -n "$SHA256SUM_PIN" ] && [ -x "$SHA256SUM_PIN" ] \
  || { printf 'ОТКАЗ окружение: пин sha256sum в доверенных путях не найден\n' >&2; exit 1; }
GOT_EMPTY_PIN="$("$SHA256SUM_PIN" </dev/null)"
[ "${GOT_EMPTY_PIN%% *}" = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855' ] \
  || { printf 'ОТКАЗ окружение: sha256sum не прошёл sanity-хэш пустого ввода\n' >&2; exit 1; }

# Энтропия оракулируемых входов (арбитраж orakul-podsmotrennaya-konstanta-024,
# РЕШЕНИЕ вопрос 1, п.1): каждый файл, чей отпечаток сверяет оракул значений,
# получает СЛУЧАЙНЫЕ имя и байты на КАЖДЫЙ прогон — ≥64 бит свежей энтропии
# из /dev/urandom через пин od из тех же TRUSTED_PATH; словарные байтовые
# литералы запрещены (З1: константа предсказуема при авторстве контрмодели).
OD_PIN="$(PATH="$TP" command -v od)"
[ -n "$OD_PIN" ] && [ -x "$OD_PIN" ] \
  || { printf 'ОТКАЗ окружение: пин od в доверенных путях не найден\n' >&2; exit 1; }
[ -r /dev/urandom ] \
  || { printf 'ОТКАЗ окружение: /dev/urandom не читается\n' >&2; exit 1; }
entropy() {  # stdout: 128 бит свежих байтов как 32 hex-символа (без внешнего tr)
  local e
  e="$("$OD_PIN" -An -N16 -tx1 /dev/urandom)"
  e="${e// /}"
  [[ "$e" =~ ^[0-9a-f]{32}$ ]] \
    || { printf 'ОТКАЗ окружение: od не вернул 32 hex-символа из /dev/urandom (получено: %s)\n' "$e" >&2; exit 1; }
  printf '%s' "$e"
}

# Живой git-чекаут toy: tracked-объект атаки — СЛУЧАЙНЫЕ имя и байты на
# каждый прогон (РЕШЕНИЕ арбитража: tracked_<энтропия> закрывает диспетчеризацию
# контрмодели по известному имени tracked.txt; байты = неизменный
# sanity-префикс "original " + 128 бит энтропии — словарный литерал байтов
# запрещён, sha непредсказуем при авторстве контрмодели, префикс держит
# sanity-grep'ы контролей 1-7, З3 арбитража). Имя/байты — глобально в
# TNAME/BYTES_MAIN (используются вызывающими контролями).
mk_main() {  # <каталог>
  mkdir -p "$1"
  TNAME="tracked_$(entropy).txt"
  BYTES_MAIN="original $(entropy)"
  printf '%s\n' "$BYTES_MAIN" > "$1/$TNAME"
  tgit init -q -b main "$1"
  tgit -C "$1" add -A
  tgit -C "$1" commit -q -m 'toy main'
}

# Постановка бита ДО снимка с подтверждением по ls-files -v (h/S реально встал).
settle_flag() {  # <каталог> <опция-update-index> <ожидаемый-флаг>
  local dir="$1" opt="$2" want="$3" got
  tgit -C "$dir" update-index "$opt" "$TNAME"
  got="$(tgit -C "$dir" ls-files -v -- "$TNAME")"
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
printf 'MUTATED CLEAN\n' >> "$K1/$TNAME"
run_subj "$K1" --check "$K1"
assert_caught контроль-1 "чистый tracked, мутация" "$TNAME" "$K1/$TNAME" 'MUTATED CLEAN'

# ─── контроль 2: assume-unchanged ДО снимка, стабильный флаг, мутация → rc 1 ───
K2="$WORK/k2_assume_${RANDOM}"
mk_main "$K2"
settle_flag "$K2" --assume-unchanged h \
  || fail контроль-2 "постановка бита" "sanity выше — флаг assume-unchanged не встал"
run_subj "$K2" --snapshot "$K2"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-2 "снимок" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
printf 'MUTATED AU\n' >> "$K2/$TNAME"
# Sanity: правка НЕ отражается в porcelain (иначе механика не флаговая).
PORC="$(tgit -C "$K2" status --porcelain -uall --no-renames --ignore-submodules=none 2>/dev/null)"
if printf '%s' "$PORC" | grep -qF "$TNAME"; then
  fail контроль-2 "sanity porcelain" "porcelain видит правку — флаг не ослепляет, механика контроля не та"
fi
run_subj "$K2" --check "$K2"
assert_caught контроль-2 "assume-unchanged до снимка + мутация" "$TNAME" "$K2/$TNAME" 'MUTATED AU'

# ─── контроль 3: skip-worktree ДО снимка, стабильный флаг, мутация → rc 1 ──────
K3="$WORK/k3_skip_${RANDOM}"
mk_main "$K3"
settle_flag "$K3" --skip-worktree S \
  || fail контроль-3 "постановка бита" "sanity выше — флаг skip-worktree не встал"
run_subj "$K3" --snapshot "$K3"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-3 "снимок" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
printf 'MUTATED SW\n' >> "$K3/$TNAME"
PORC="$(tgit -C "$K3" status --porcelain -uall --no-renames --ignore-submodules=none 2>/dev/null)"
if printf '%s' "$PORC" | grep -qF "$TNAME"; then
  fail контроль-3 "sanity porcelain" "porcelain видит правку — флаг не ослепляет, механика контроля не та"
fi
run_subj "$K3" --check "$K3"
assert_caught контроль-3 "skip-worktree до снимка + мутация" "$TNAME" "$K3/$TNAME" 'MUTATED SW'

# ─── контроль 4: правило .git/info/exclude на путь + мутация → rc 1 ────────────
# Механика: ignore-правила на TRACKED-путь porcelain не ослепляют (sanity это
# проверяет) — контроль специфицирует, что целевая нога-1 судит байты, не
# спрашивая ignore-правил вовсе (в v6 источник — ls-files, а не porcelain).
K4="$WORK/k4_exclude_${RANDOM}"
mk_main "$K4"
printf 'tracked*\n' >> "$K4/.git/info/exclude"
run_subj "$K4" --snapshot "$K4"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-4 "снимок" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
printf 'MUTATED EX\n' >> "$K4/$TNAME"
PORC="$(tgit -C "$K4" status --porcelain -uall --no-renames --ignore-submodules=none 2>/dev/null)"
printf '%s' "$PORC" | grep -qF "$TNAME" \
  || fail контроль-4 "sanity porcelain" "porcelain НЕ видит правку tracked-пути под exclude-правилом — механика контроля не та"
run_subj "$K4" --check "$K4"
assert_caught контроль-4 "exclude-правило + мутация tracked" "$TNAME" "$K4/$TNAME" 'MUTATED EX'

# ─── контроль 5: правило .gitignore (committed) на путь + мутация → rc 1 ───────
K5="$WORK/k5_gitignore_${RANDOM}"
mk_main "$K5"
printf 'tracked*\n' > "$K5/.gitignore"
tgit -C "$K5" add -A
tgit -C "$K5" commit -q -m 'toy gitignore'
run_subj "$K5" --snapshot "$K5"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-5 "снимок" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
printf 'MUTATED GI\n' >> "$K5/$TNAME"
PORC="$(tgit -C "$K5" status --porcelain -uall --no-renames --ignore-submodules=none 2>/dev/null)"
printf '%s' "$PORC" | grep -qF "$TNAME" \
  || fail контроль-5 "sanity porcelain" "porcelain НЕ видит правку tracked-пути под .gitignore-правилом — механика контроля не та"
run_subj "$K5" --check "$K5"
assert_caught контроль-5 "gitignore-правило + мутация tracked" "$TNAME" "$K5/$TNAME" 'MUTATED GI'

# ─── контроль 6: внешний core.excludesFile (правило до снимка) + мутация ───────
K6="$WORK/k6_extexc_${RANDOM}"
mk_main "$K6"
EXTRULES="$WORK/ext_rules_${RANDOM}.txt"
printf 'tracked*\n' > "$EXTRULES"
tgit -C "$K6" config core.excludesFile "$EXTRULES"
run_subj "$K6" --snapshot "$K6"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-6 "снимок" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
printf 'MUTATED EF\n' >> "$K6/$TNAME"
PORC="$(tgit -C "$K6" status --porcelain -uall --no-renames --ignore-submodules=none 2>/dev/null)"
printf '%s' "$PORC" | grep -qF "$TNAME" \
  || fail контроль-6 "sanity porcelain" "porcelain НЕ видит правку tracked-пути под внешним правилом — механика контроля не та"
run_subj "$K6" --check "$K6"
assert_caught контроль-6 "внешний excludesFile + мутация tracked" "$TNAME" "$K6/$TNAME" 'MUTATED EF'

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
tgit -C "$K7" update-index --cacheinfo 100644,"$BLOB","$TNAME"
# Sanity: байты рабочего файла не тронуты (мутация ТОЛЬКО индексная).
grep -qF 'original' "$K7/$TNAME" \
  || fail контроль-7 "sanity байтов" "рабочие байты изменились — это не индексная подсадка"
run_subj "$K7" --check "$K7"
assert_caught контроль-7 "индексная подсадка без правки байтов" "$TNAME" "$K7/$TNAME" 'original'

# ─── контроль 8: инвариант ПРЕДСТАВЛЕНИЯ, оракул ЗНАЧЕНИЯ, ДВЕ ФАЗЫ ────────────
# Целевой манифест (v6 нога-1) обязан представлять КАЖДЫЙ tracked-путь строкой,
# несущей sha256 БАЙТОВ рабочего файла — на ЧИСТОМ дереве, без флагов и правил,
# И СЛЕДИТЬ за изменением байтов между двумя снимками (арбитраж
# orakul-podsmotrennaya-konstanta-024, РЕШЕНИЕ вопрос 1, п.2). Оракул —
# НЕЗАВИСИМАЯ исходная истина (блокер вердикта критика 873b81b): проба САМА
# вычисляет отпечаток байтов ДО каждого вызова субъекта (правило 8: ожидания
# в памяти пробы, снимок не источник ожиданий) и требует СОВПАДЕНИЯ вычисленного
# значения в строке манифеста как САМОСТОЯТЕЛЬНОГО токена (границы — не-hex
# символы). ФОРМА БЕЗ ЗНАЧЕНИЯ ЗАПРЕЩЕНА: любой 64-hex, не равный вычисленному
# отпечатку, — именованный ОТКАЗ «несовпадение отпечатка» (фаза A). ЗАМОРОЗКА/
# ЭХО первого снимка (строка фазы B несёт тот же отпечаток, что и фаза A, при
# изменённых байтах, либо строка вовсе пропала) — именованный ОТКАЗ
# «представление не следит за байтами» (фаза B). Текущий код чистые пути не
# представляет вовсе → именованный ОТКАЗ «нога tracked-байтов отсутствует»
# (краснота респека: проба различает текущее и целевое представление).
K8="$WORK/k8_invariant_${RANDOM}"
mk_main "$K8"                       # случайные имя ($TNAME) и байты состояния A ($BYTES_MAIN)
OCT8="$TNAME"
BYTES_A8="$BYTES_MAIN"
# Toy несёт РОВНО ОДИН tracked-путь — запрет sha(A) в фазе B ниже относится
# именно к переписанному пути (без этого условия он был бы неполным).
[ "$(tgit -C "$K8" ls-files | wc -l)" -eq 1 ] \
  || { printf 'ОТКАЗ контроль-8 (оракул): toy обязан нести ровно один tracked-путь, получено: %s\n' "$(tgit -C "$K8" ls-files | wc -l)" >&2; exit 1; }
# Ожидание ДО вызова субъекта (правило 8): отпечаток состояния A.
WANT_A8="$("$SHA256SUM_PIN" -- "$K8/$OCT8")" \
  || { printf 'ОТКАЗ контроль-8 (оракул): sha256sum не смог прочитать %s\n' "$K8/$OCT8" >&2; exit 1; }
WANT_A8="${WANT_A8%% *}"
# Путь снимка — ровно как считает субъект: hash8 от канонического корня K8
# (контроли 1-7 снимают ДРУГИЕ корни в тот же TMPDIR — glob '*/*/porcelain'
# взял бы чужой снимок, выбираем свой по hash8).
CANON8="$(cd "$K8" && pwd -P)"
H8="$(printf '%s' "$CANON8" | "$SHA256SUM_PIN")"
H8="${H8%% *}"; H8="${H8:0:8}"
SNAP="$WORK/snaps/dev-harness-leak/$H8/porcelain"
# ── фаза A: состояние A → снимок → строка несёт sha(A) ─────────────────────────
run_subj "$K8" --snapshot "$K8"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-8 "снимок" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
[ -f "$SNAP" ] || fail контроль-8 "снимок-файл" "файл снимка K8 не найден: $SNAP"
LINE_A8=""
while IFS= read -r l8; do
  [ "${l8##*$'\t'}" = "$OCT8" ] && LINE_A8="$l8"
done < "$SNAP"
[ -n "$LINE_A8" ] || fail контроль-8 "нога tracked-байтов отсутствует" \
  "024-v6: чистый tracked-путь $OCT8 НЕ представлен в манифесте снимка (цель: git ls-files -z -> sha256 байтов КАЖДОГО tracked-пути; текущее: porcelain-формы v5 представляют только изменённые пути) — корневой срез не реализован"
printf '%s\n' "$LINE_A8" | grep -qE "(^|[^0-9a-f])${WANT_A8}([^0-9a-f]|$)" \
  || fail контроль-8 "несовпадение отпечатка" \
    "024-v6 (фаза A): строка $OCT8 не несёт ВЫЧИСЛЕННОГО пробой отпечатка $WANT_A8 (форма без значения: 64-hex отсутствует либо не равен sha256 байтов файла; строка: $LINE_A8) — корневой срез не реализован"
# ── фаза B: перезапись на случайное B≠A → повторный снимок того же корня ───────
# (замер З4 арбитража: субъект допускает повторный --snapshot, манифест
# перезаписывается; ожидание вычисляется ДО второго вызова — правило 8).
BYTES_B8="original $(entropy)"
[ "$BYTES_B8" != "$BYTES_A8" ] \
  || { printf 'ОТКАЗ контроль-8 (энтропия): состояние B совпало с A — свежая выборка обязана отличаться\n' >&2; exit 1; }
printf '%s\n' "$BYTES_B8" > "$K8/$OCT8"
WANT_B8="$("$SHA256SUM_PIN" -- "$K8/$OCT8")" \
  || { printf 'ОТКАЗ контроль-8 (оракул): sha256sum не смог прочитать %s\n' "$K8/$OCT8" >&2; exit 1; }
WANT_B8="${WANT_B8%% *}"
[ "$WANT_B8" != "$WANT_A8" ] \
  || { printf 'ОТКАЗ контроль-8 (энтропия): sha(B)=sha(A) при разных байтах — коллизия окружения\n' >&2; exit 1; }
run_subj "$K8" --snapshot "$K8"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-8 "повторный снимок" "повторный снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
[ -f "$SNAP" ] || fail контроль-8 "повторный снимок" "файл снимка исчез после повторного снимка: $SNAP"
LINE_B8=""
while IFS= read -r l8; do
  [ "${l8##*$'\t'}" = "$OCT8" ] && LINE_B8="$l8"
done < "$SNAP"
[ -n "$LINE_B8" ] || fail контроль-8 "представление не следит за байтами" \
  "024-v6 (фаза B): после перезаписи $OCT8 на состояние B строка пути исчезла из манифеста — sha(B) не появился (замороженное представление первого снимка) — корневой срез не реализован"
printf '%s\n' "$LINE_B8" | grep -qE "(^|[^0-9a-f])${WANT_B8}([^0-9a-f]|$)" \
  || fail контроль-8 "представление не следит за байтами" \
    "024-v6 (фаза B): строка $OCT8 не несёт ПЕРЕВЫЧИСЛЕННОГО отпечатка $WANT_B8 после перезаписи байтов (эхо/заморозка первого снимка; строка: $LINE_B8) — корневой срез не реализован"
printf '%s\n' "$LINE_B8" | grep -qE "(^|[^0-9a-f])${WANT_A8}([^0-9a-f]|$)" \
  && fail контроль-8 "представление не следит за байтами" \
    "024-v6 (фаза B): строка $OCT8 всё ещё несёт отпечаток состояния A $WANT_A8 (замороженное представление; обязан появиться sha(B)=$WANT_B8, исчезнуть sha(A); строка: $LINE_B8) — корневой срез не реализован"
ok контроль-8 "инвариант представления, две фазы: путь несёт sha(A) на снимке A и ПЕРЕВЫЧИСЛЕННЫЙ sha(B)≠sha(A) после перезаписи — представление следит за байтами"

printf 'red_rootcut_tracked_bytes_024: 8 контролей зелены (v6 нога-1: мутация байтов tracked-пути при любом состоянии/флаге/правиле/подсадке даёт rc 1 с именем; каждый tracked-путь представлен байтами в манифесте и следит за их изменением между снимками — двухсостоянная сверка, оракулируемый вход случаен каждый прогон)\n' >&2
exit 0
