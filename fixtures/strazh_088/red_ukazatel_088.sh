#!/usr/bin/env bash
# Семья 088, часть Б: pre-commit (.githooks/pre-commit → scripts/check_staged.sh) судит
# staged HANDOFF.md грамматикой клетки k7 (074): первая секция — от первой строки,
# начинающейся «## ГДЕ МЫ», до следующей строки `^## ` (подразделы `### ` внутри),
# строка-указатель — самостоятельной строкой (`grep -Fx`), побайтово PTR_088.
# Судится ИНДЕКС (то, что попадёт в коммит), для любого автора, включая необъявленного
# в заморозках оркестратора. Коммит — ЖИВЫМ способом: `-c user.name=orchestrator`,
# пустой file-config, хук из core.hooksPath.
#
# Использование: bash red_ukazatel_088.sh <корень> [B0 B1 … B30] [--sudja <файл>]
#   --sudja <файл> — подменить scripts/check_staged.sh тоу-репо (стаб-пак/диффпроба).
# Коды: 0 — все судимые клетки зелёные; 1 — есть красная; 2 — нечем проверить.
#
# Клетки (вход → ожидание; ДО 088 красны B1 B2 B3 B4 B6 B7 B11 B14 B15 B16 B17 B18;
# на 6f29c59 — B15 B16 B17 B18; на fb08e98 — B19…B29, B30 там зелёная — пара-негатив Б-2):
#   B0  первая секция несёт строку                          → коммит
#   B1  строки нет нигде                                     → отказ
#   B2  строка укорочена (без хвоста «(инвентарь…)»)         → отказ (измеренный отказ 06.10)
#   B3  строка с посторонним хвостом                          → отказ (Fx, не подстрока)
#   B4  строка только во ВТОРОЙ секции «## ГДЕ МЫ»            → отказ
#   B5  строка в подразделе `###` первой секции               → коммит
#   B6  строка после конца первой секции (в «## Итог»)        → отказ
#   B7  индекс без строки, рабочее дерево — со строкой        → отказ (судится индекс)
#   B8  индекс со строкой, рабочее дерево — без               → коммит
#   B9  HANDOFF.md не staged (в HEAD без строки), staged README → коммит
#   B11 staged удаление HANDOFF.md                             → отказ
#   B13 staged docs/HANDOFF.md без строки (не корневой)        → коммит
#   B14 первая секция несёт только строку ATAKA_088, env      → отказ (k7 — из индекса,
#       коммита PTR_088=ATAKA_088 (обход 8bc5e68, adversary 088)   env не источник)
#   B15 первая секция несёт только ATAKA_088; РАБОЧАЯ копия   → отказ (k7 — из индекса,
#       k7 (не staged) переписана на HANDOFF_PTR=ATAKA_088         не из рабочего дерева;
#       (adversary 088-v2 §1)                                       staged — только HANDOFF.md)
#   B16 строки нет; рабочая копия k7 УДАЛЕНА (не staged)      → отказ (суд не зависит от
#                                                                   рабочего файла k7)
#   B17 как B1, env коммитёра OTKAZ_088=ATAKA_088              → отказ ровно строкой И-7
#       (adversary 088-v2 §3)
#   B18 как B11, env коммитёра OTKAZ_088=ATAKA_088             → отказ ровно строкой И-7
#   — Б-1 арбитража 088 круг 5: k7 — константа судьи, 074 ничем не читается —
#   B19 строки нет; k7 снята с ИНДЕКСА (`git rm --cached`) → отказ (пустой источник ≠ «не судить»)
#   B20 строки нет; в k7 индекса ВТОРОЕ присваивание         → отказ (неоднозначный источник)
#       HANDOFF_PTR=ATAKA_088
#   B21 первая секция несёт ATAKA_088; k7 ИНДЕКСА переписана → отказ (k7 индекса — не источник)
#       на HANDOFF_PTR=ATAKA_088 (staged)
#   B22 дрейф k7: копия корня, где HANDOFF_PTR 074 дополнен   → дочерний прогон B0 этой копии
#       « (дрейф)», судья тот же                                   КРАСЕН (константа судьи ≠ k7;
#                                                                   контракт: Frontier п.6)
#   — Б-2: судится индекс КОММИТА (GIT_INDEX_FILE хука), индекс ≠ рабочее дерево —
#   B23 commit -a: индекс со строкой, рабочее дерево — без   → отказ
#   B24 commit -a: индекс без строки, рабочее дерево — со     → коммит
#   B25 commit -- HANDOFF.md: индекс со строкой, дерево — без → отказ
#   B26 commit -- HANDOFF.md: индекс без строки, дерево — со  → коммит
#   B27 commit -i HANDOFF.md: индекс со строкой, дерево — без → отказ
#   B28 commit -i HANDOFF.md: индекс без строки, дерево — со  → коммит
#   B29 как B23, в СВЯЗАННОМ worktree тоу-репо (.git — gitfile) → отказ (индекс — под
#                                                                   --absolute-git-dir)
#   B30 прямой вызов судьи `check_staged.sh <корень>`: staged → отказ (унаследованный
#       без строки, env GIT_INDEX_FILE — копия индекса того же     GIT_INDEX_FILE вне git-dir
#       HEAD вне git-dir (staged пуст)                             корня не судится; гигиена 016)
#   — замечание круг 9: фиксы 310d467 (readlink -f канонизация GIT_INDEX_FILE) и
#       9893dc5 (захват секции HANDOFF в переменную до grep) различаются двумя
#       клетками; стаб-пак привязан по коду (Н-39): sb25 — `grep -n 'readlink -f'`
#       scripts/check_staged.sh:286-287, sb26 — `grep -n 'printf.*grep'` scripts/check_staged.sh:373.
#   B31 staged HANDOFF.md без указателя в `<r>/.git/index`;             → отказ
#       env GIT_INDEX_FILE=`<r>/.git/../evil-index` (lexical-обход         (канонизация readlink -f
#       к индексу ВНЕ git-dir через `..`; staged в evil-index             против `..`-обхода;
#       пуст); прямой вызов check_staged.sh                               шершава 016: индекс
#                                                                      не под git-dir → не
#                                                                      принимается, откат на
#                                                                      дефолтный `.git/index`,
#                                                                      видит staged HANDOFF.md
#                                                                      без указателя → отказ)
#   B32 честный HANDOFF.md с указателем первой строкой первой          → коммит (захват секции
#       секции; первая секция ~150 Б (PTR + 1 строка), хвост             в переменную снимает
#       ≥70 КиБ (форма Н-214: «первая секция мала, хвост                 SIGPIPE `printf|awk|grep`
#       велик» — `awk` старого суъекта читал весь блоб,                   в OLD: `awk` внутри
#       досрочный `exit` на границе секции 1 рвал pipe →                  `printf|awk|grep` рвёт
#       SIGPIPE 141 → ложный отказ И-7; фикс 9893dc5                       pipe; фикс 9893dc5
#       изолирует чтение секции от grep                                   изолирует через `$(…)`)
# Привязка стабов к клеткам — red_stuby_088.sh (Н-39).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${1:-$HERE/../..}" 2>/dev/null && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
shift || true
SUDJA=""
kletki=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --sudja) SUDJA="${2:-}"; [ -f "$SUDJA" ] || { printf 'NOT_IMPLEMENTED: нет судьи-подмены %s\n' "$SUDJA" >&2; exit 2; }; shift 2 ;;
    *) kletki+=("$1"); shift ;;
  esac
done
for subj in scripts/check_staged.sh .githooks/pre-commit; do
  [ -f "$ROOT/$subj" ] || { printf 'NOT_IMPLEMENTED: нет %s\n' "$ROOT/$subj" >&2; exit 2; }
done
# shellcheck disable=SC1091
. "$HERE/_toy.sh" "${kletki[@]}"

mir() {  # <клетка> → r=путь тоу-репо (без подоболочки: отказ построения — rc 2 файла)
  ukazatel_mir "$SCR/$1" "$SUDJA"
  r="$SCR/$1"
}

K7=fixtures/ops_server/red_server_obvjazka_074.sh
# tolko_handoff <репо> — вход клеток B15/B16 построен: staged — ровно HANDOFF.md, k7 в
# индексе есть (порча — только в рабочем дереве); иначе rc 2 файла (мир не тот).
tolko_handoff() {
  local s
  s="$(gx "$1" diff --cached --name-only)" || exit 2
  [ "$s" = HANDOFF.md ] || { printf 'NOT_IMPLEMENTED: staged мира — не ровно HANDOFF.md: %s\n' "$s" >&2; exit 2; }
  gx "$1" cat-file -e ":$K7" || { printf 'NOT_IMPLEMENTED: в индексе мира нет %s\n' "$K7" >&2; exit 2; }
}

klet_handoff() {  # <клетка> <вариант индекса> <ожидание>
  mir "$1"
  handoff_v "$r/HANDOFF.md" "$2"
  gx "$r" add -- HANDOFF.md || exit 2
  ozhidaj_b "$1" "$r" "$3"
}

nado B0 && klet_handoff B0 pervaja prinjat
nado B1 && klet_handoff B1 net otkaz
nado B2 && klet_handoff B2 ukorochena otkaz
nado B3 && klet_handoff B3 hvost otkaz
nado B4 && klet_handoff B4 vtoraja otkaz
nado B5 && klet_handoff B5 podrazdel prinjat
nado B6 && klet_handoff B6 posle otkaz

if nado B7; then
  mir B7
  handoff_v "$r/HANDOFF.md" net; gx "$r" add -- HANDOFF.md || exit 2
  handoff_v "$r/HANDOFF.md" pervaja            # рабочее дерево исправлено, индекс — нет
  ozhidaj_b B7 "$r" otkaz
fi

if nado B8; then
  mir B8
  handoff_v "$r/HANDOFF.md" podrazdel; gx "$r" add -- HANDOFF.md || exit 2
  handoff_v "$r/HANDOFF.md" net                # индекс конформен, рабочее дерево — нет
  ozhidaj_b B8 "$r" prinjat
fi

if nado B9; then
  mir B9
  handoff_v "$r/HANDOFF.md" net
  gx "$r" add -- HANDOFF.md && gx "$r" commit -q -m 'HEAD без указателя (построение мира)' || exit 2
  printf 'правка\n' >> "$r/README.md"; gx "$r" add -- README.md || exit 2
  ozhidaj_b B9 "$r" prinjat
fi

if nado B11; then
  mir B11
  gx "$r" rm -q -- HANDOFF.md || exit 2
  ozhidaj_b B11 "$r" otkaz
fi

if nado B13; then
  mir B13
  mkdir -p "$r/docs"; handoff_v "$r/docs/HANDOFF.md" net; gx "$r" add -- docs/HANDOFF.md || exit 2
  ozhidaj_b B13 "$r" prinjat
fi

if nado B14; then
  mir B14
  handoff_v "$r/HANDOFF.md" chuzhaja; gx "$r" add -- HANDOFF.md || exit 2
  ozhidaj_b B14 "$r" otkaz PTR_088="$ATAKA_088"
fi

if nado B15; then
  mir B15
  handoff_v "$r/HANDOFF.md" chuzhaja; gx "$r" add -- HANDOFF.md || exit 2
  sed -i "s/^HANDOFF_PTR='.*'\$/HANDOFF_PTR='$ATAKA_088'/" "$r/$K7" || exit 2
  mapfile -t _p15 < <(sed -n "s/^HANDOFF_PTR='\(.*\)'\$/\1/p" "$r/$K7")
  [ "${#_p15[@]}" -eq 1 ] && [ "${_p15[0]}" = "$ATAKA_088" ] \
    || { printf 'NOT_IMPLEMENTED: рабочая k7 мира B15 не переписана на ATAKA_088\n' >&2; exit 2; }
  tolko_handoff "$r"
  ozhidaj_b B15 "$r" otkaz
fi

if nado B16; then
  mir B16
  handoff_v "$r/HANDOFF.md" net; gx "$r" add -- HANDOFF.md || exit 2
  rm -f -- "$r/$K7" && [ ! -e "$r/$K7" ] || exit 2
  tolko_handoff "$r"
  ozhidaj_b B16 "$r" otkaz
fi

if nado B17; then
  mir B17
  handoff_v "$r/HANDOFF.md" net; gx "$r" add -- HANDOFF.md || exit 2
  ozhidaj_b B17 "$r" otkaz OTKAZ_088="$ATAKA_088"
fi

if nado B18; then
  mir B18
  gx "$r" rm -q -- HANDOFF.md || exit 2
  ozhidaj_b B18 "$r" otkaz OTKAZ_088="$ATAKA_088"
fi

if nado B19; then
  mir B19
  handoff_v "$r/HANDOFF.md" net; gx "$r" add -- HANDOFF.md || exit 2
  gx "$r" rm -q --cached -- "$K7" || exit 2
  if gx "$r" cat-file -e ":$K7" 2>/dev/null || [ ! -f "$r/$K7" ]; then
    printf 'NOT_IMPLEMENTED: мир B19 — k7 не снята с индекса либо пропала из дерева\n' >&2; exit 2
  fi
  ozhidaj_b B19 "$r" otkaz
fi

if nado B20; then
  mir B20
  handoff_v "$r/HANDOFF.md" net; gx "$r" add -- HANDOFF.md || exit 2
  printf "HANDOFF_PTR='%s'\n" "$ATAKA_088" >> "$r/$K7" && gx "$r" add -- "$K7" || exit 2
  mapfile -t _p20 < <(gx "$r" show ":$K7" | sed -n "s/^HANDOFF_PTR='\(.*\)'\$/\1/p")
  [ "${#_p20[@]}" -eq 2 ] || { printf 'NOT_IMPLEMENTED: k7 индекса мира B20 — не два присваивания\n' >&2; exit 2; }
  ozhidaj_b B20 "$r" otkaz
fi

if nado B21; then
  mir B21
  handoff_v "$r/HANDOFF.md" chuzhaja; gx "$r" add -- HANDOFF.md || exit 2
  sed -i "s/^HANDOFF_PTR='.*'\$/HANDOFF_PTR='$ATAKA_088'/" "$r/$K7" && gx "$r" add -- "$K7" || exit 2
  mapfile -t _p21 < <(gx "$r" show ":$K7" | sed -n "s/^HANDOFF_PTR='\(.*\)'\$/\1/p")
  [ "${#_p21[@]}" -eq 1 ] && [ "${_p21[0]}" = "$ATAKA_088" ] \
    || { printf 'NOT_IMPLEMENTED: k7 индекса мира B21 не переписана на ATAKA_088\n' >&2; exit 2; }
  ozhidaj_b B21 "$r" otkaz
fi

if nado B22; then
  k22="$SCR/B22-koren"
  mkdir -p "$k22/fixtures/ops_server" || exit 2
  cp -R -- "$ROOT/scripts" "$k22/scripts" && cp -R -- "$ROOT/.githooks" "$k22/.githooks" || exit 2
  python3 - "$SRC074" "$k22/$K7" "HANDOFF_PTR='$PTR_088'" "HANDOFF_PTR='$PTR_088 (дрейф)'" <<'PY' \
    || { printf 'NOT_IMPLEMENTED: дрейф k7 мира B22 не построен\n' >&2; exit 2; }
import sys
src, dst, old, new = sys.argv[1:5]
stroki = open(src, encoding='utf-8').read().split('\n')
if stroki.count(old) != 1:
    sys.exit(1)
open(dst, 'w', encoding='utf-8').write('\n'.join(new if s == old else s for s in stroki))
PY
  sud22=()
  [ -z "$SUDJA" ] || sud22=(--sudja "$SUDJA")
  bash "$HERE/red_ukazatel_088.sh" "$k22" B0 "${sud22[@]}" >"$SCR/B22.out" 2>&1; rc22=$?
  if [ "$rc22" -eq 1 ] && grep -q '^КРАСНО: B0: ' "$SCR/B22.out"; then
    zeleno B22
  elif [ "$rc22" -eq 2 ]; then
    printf 'NOT_IMPLEMENTED: дочерний прогон B22 — rc 2: %s\n' "$(head -c 300 "$SCR/B22.out" | tr '\n' ' ')" >&2; exit 2
  else
    krasno "B22: дрейф k7 не виден — HANDOFF_PTR копии корня сдвинут, судья прежний, B0 копии rc=$rc22: $(grep -m1 -F ': B0' "$SCR/B22.out")"
  fi
fi

# klet_forma <клетка> <вариант индекса> <вариант рабочего дерева> <ожидание> <форма commit…>
# — индекс и рабочее дерево расходятся; что попадёт в коммит, решает форма commit.
klet_forma() {
  local c="$1" vi="$2" vd="$3" ozh="$4"
  shift 4
  mir "$c"
  handoff_v "$r/HANDOFF.md" "$vi"; gx "$r" add -- HANDOFF.md || exit 2
  handoff_v "$r/HANDOFF.md" "$vd"
  ozhidaj_b "$c" "$r" "$ozh" -- "$@"
}
nado B23 && klet_forma B23 podrazdel net otkaz -a
nado B24 && klet_forma B24 net pervaja prinjat -a
nado B25 && klet_forma B25 podrazdel net otkaz -- HANDOFF.md
nado B26 && klet_forma B26 net pervaja prinjat -- HANDOFF.md
nado B27 && klet_forma B27 podrazdel net otkaz -i HANDOFF.md
nado B28 && klet_forma B28 net pervaja prinjat -i HANDOFF.md

if nado B29; then
  mir B29
  w="$SCR/B29-wt"
  gx "$r" worktree add -q --detach "$w" || exit 2
  [ -f "$w/.git" ] || { printf 'NOT_IMPLEMENTED: .git связанного worktree мира B29 — не gitfile\n' >&2; exit 2; }
  handoff_v "$w/HANDOFF.md" podrazdel; gx "$w" add -- HANDOFF.md || exit 2
  handoff_v "$w/HANDOFF.md" net
  ozhidaj_b B29 "$w" otkaz -- -a
fi

if nado B30; then
  mir B30
  cp -- "$r/.git/index" "$SCR/B30-chuzhoj.index" || exit 2
  handoff_v "$r/HANDOFF.md" net; gx "$r" add -- HANDOFF.md || exit 2
  s30="$(GIT_INDEX_FILE="$SCR/B30-chuzhoj.index" gx "$r" diff --cached --name-only)" && [ -z "$s30" ] \
    || { printf 'NOT_IMPLEMENTED: чужой индекс мира B30 несёт staged: %s\n' "$s30" >&2; exit 2; }
  env GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null GIT_INDEX_FILE="$SCR/B30-chuzhoj.index" \
      GIT_AUTHOR_NAME=orchestrator GIT_AUTHOR_EMAIL=orchestrator@dev-harness.local \
      bash "$r/scripts/check_staged.sh" "$r" >/dev/null 2>"$SCR/kommit.err"; rc30=$?
  if [ "$rc30" -ne 0 ] && grep -Fxq -- "$OTKAZ_088" "$SCR/kommit.err"; then
    zeleno B30
  else
    krasno "B30: ожидался отказ «$OTKAZ_088» (судится индекс корня), получено rc=$rc30: $(head -c 300 "$SCR/kommit.err" | tr '\n' ' ')"
  fi
fi

# klet_big_handoff <файл> — HANDOFF.md по форме Н-214: малая первая секция
# (PTR_088 первая строка секции + одна строка), большой хвост ≥70 КиБ.
# OLD подцепочка `printf|awk|grep` рвёт pipe на границе секции 1 (awk exit
# досрочно) → SIGPIPE 141 → ложный отказ И-7; HEAD ловит секцию в
# переменную (9893dc5), grep читает уже захваченное — pipe не живёт.
klet_big_handoff() {
  local f="$1" n
  n=2000
  {
    printf '# HANDOFF\n\n## ГДЕ МЫ (тоу)\n\n%s\n\nодна строка секции\n\n' "$PTR_088"
    printf '## Итог\n'
    python3 -c "import sys; sys.stdout.write('\n'.join('хвостовая строка ' + str(i) + ' padding-padding-padding' for i in range(1, $n+1)) + '\n')"
    printf '\n## Дополнение\n'
  } > "$f"
}

if nado B31; then
  mir B31
  # staged HANDOFF.md без указателя в дефолтном `<r>/.git/index`; внешний
  # индекс — копия чистого состояния индекса (HEAD-уровень), файл-каталог
  # `evil-index` лежит ВНЕ `<r>/.git/` (под `<r>/`), но путь
  # `<r>/.git/../evil-index` лексически под `.git/` — старая схема
  # (sb24: проверка «под git-dir корня» снята) такой путь принимает.
  handoff_v "$r/HANDOFF.md" net; gx "$r" add -- HANDOFF.md || exit 2
  cp -- "$r/.git/index" "$SCR/B31-default.index" || exit 2
  GIT_INDEX_FILE="$SCR/B31-default.index" gx "$r" reset -q HEAD -- . >/dev/null 2>&1 \
    || { printf 'NOT_IMPLEMENTED: чистка индекса-донора B31\n' >&2; exit 2; }
  cp -- "$SCR/B31-default.index" "$r/evil-index" || exit 2
  s31="$(GIT_INDEX_FILE="$r/.git/../evil-index" gx "$r" diff --cached --name-only -z)" \
    && [ -z "$s31" ] \
    || { printf 'NOT_IMPLEMENTED: B31 evil-index несёт staged: %s\n' "$s31" >&2; exit 2; }
  # Грязный staged в дефолтном `<r>/.git/index` остаётся (HEAD судит
  # дефолтный индекс при откате от `<r>/.git/../evil-index` как вне-git-dir)
  gx "$r" read-tree HEAD || exit 2
  handoff_v "$r/HANDOFF.md" net; gx "$r" add -- HANDOFF.md || exit 2
  env GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null GIT_INDEX_FILE="$r/.git/../evil-index" \
      GIT_AUTHOR_NAME=orchestrator GIT_AUTHOR_EMAIL=orchestrator@dev-harness.local \
      bash "$r/scripts/check_staged.sh" "$r" >/dev/null 2>"$SCR/kommit.err"; rc31=$?
  if [ "$rc31" -ne 0 ] && grep -Fxq -- "$OTKAZ_088" "$SCR/kommit.err"; then
    zeleno B31
  else
    krasno "B31: ожидался отказ «$OTKAZ_088» (канонизация '.git/../evil-index' → вне git-dir, откат на дефолтный индекс → staged HANDOFF.md без указателя), получено rc=$rc31: $(head -c 300 "$SCR/kommit.err" | tr '\n' ' ')"
  fi
fi

if nado B32; then
  mir B32
  # Форма Н-214: малая первая секция с указателем, большой хвост.
  # OLD код: `printf|awk|grep` — awk рвёт pipe на границе секции 1,
  # хвост непрочитан → SIGPIPE 141 → отказ И-7. HEAD ловит секцию в
  # переменную (`9893dc5`), grep читает уже захваченное.
  klet_big_handoff "$r/HANDOFF.md"
  sz="$(wc -c < "$r/HANDOFF.md")" || exit 2
  [ "$sz" -ge 70000 ] || { printf 'NOT_IMPLEMENTED: B32 HANDOFF.md %d байт < 70000\n' "$sz" >&2; exit 2; }
  gx "$r" add -- HANDOFF.md || exit 2
  ozhidaj_b B32 "$r" prinjat
fi

itog_semji red_ukazatel_088.sh
