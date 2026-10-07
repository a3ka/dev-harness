#!/usr/bin/env bash
# Стаб-пак 088 (Н-39: привязка стабов к входам — ЗДЕСЬ, в коде, не в прозе контракта).
#
# Каждый обманный стаб — мини-субъект, подставляемый в тоу-мир вместо судимого файла
# (дверь — `red_dver_088.sh --dver`, судья хука — `red_ukazatel_088.sh --sudja`), и
# прогоняется на ОДНОЙ клетке — входе, где его дефект наблюдаем: клетка обязана быть
# красной (rc 1 файла семьи). Диффпроба: та же клетка на честном мини-субъекте — зелёная
# (rc 0), иначе клетка ловит не дефект, а себя. rc 2 любого прогона — «нечем проверить».
#
# PAK (стаб → клетка; дефект):
#   sa1 → D1   глоб сессий от $HOME сессии omp (поведение ДО 088, измерено 17:53)
#   sa2 → D2   current_session_dir через `ls -t | head -1 || return 0` под pipefail
#              (собственная копия кода ДО 088 — стаб красен на D2 при любой lib_session)
#   sa3 → D3   дом из passwd по $USER, а не по `id -un`
#   sa4 → D4   шов ORCH_SESS_GLOB перетёрт домом из passwd
#   sa5 → D0   любой журнал — «живой» (окно свежести не применено)
#   sa6 → D5   имена с ведущей точкой отброшены (adversary 088, door-dot-ignore)
#   sa7 → D6   вызов current_session_dir без IFS=перевод строки: глоб разбит по пробелам
#              дома (adversary 088-v2 §2)
#   sa8 → D7   дом из passwd в глобе не экранирован (`[ * ? \` — шаблон, а не путь)
#   sa9 → D8   своя current_session_dir двери: «дом» — префикс до первой `/.local/state/`,
#              дом не экранирован, вызов без IFS (форма fb08e98; ревьюер 088 круг 4, Б-3)
#   sa10 → D9  IFS=перевод строки только в ветви дома из passwd: глоб шва разбит пробелами
#   sa11 → D10 IFS=перевод строки только при пробеле в глобе: TAB шва разбивает глоб
#   sb1 → B1   нет проверки (поведение ДО 088)
#   sb2 → B3   подстрока вместо самостоятельной строки
#   sb3 → B6   строка где угодно в файле, не в первой секции
#   sb4 → B4   любая секция «## ГДЕ МЫ», не первая
#   sb5 → B5   секция обрывается на любом заголовке `#`, а не на `^## `
#   sb6 → B7   судится рабочее дерево, а не индекс
#   sb7 → B9   HANDOFF.md судится и не будучи staged
#   sb8 → B11  staged-удаление не судится (фильтр AM)
#   sb9 → B13  судится любой */HANDOFF.md, не только корневой
#   sb10 → B1  отказ без именованной строки 088
#   sb11 → B14 строка-указатель из env PTR_088 коммитёра, константа — запасной (обход 8bc5e68)
#   sb12 → B15 k7 из РАБОЧЕЙ копии фикстуры 074 (adversary 088-v2 §1)
#   sb13 → B16 суд только при наличии рабочего файла 074 (fail-open)
#   sb14 → B17 текст отказа из env OTKAZ_088 коммитёра (adversary 088-v2 §3)
#   sb15 → B18 текст отказа из env OTKAZ_088 — только на ветви staged-удаления HANDOFF.md
#   sb16 → B19 k7 из блоба ИНДЕКСА 074; блоба нет → суд пропущен (форма fb08e98, P1 арбитража)
#   sb17 → B20 k7 из блоба индекса 074; присваиваний ≠ 1 → суд пропущен (P2 арбитража)
#   sb18 → B21 k7 из блоба индекса 074, любая неоднозначность — отказ (чтение 074 «с отказом»)
#   sb19 → B22 k7 из HEAD-блоба 074 (с отказом): дрейф k7 субъект повторяет за оракулом
#   sb20 → B23 GIT_INDEX_FILE хука снят без возврата — судится .git/index (форма fb08e98)
#   sb21 → B24 индекс хука ≠ умолчательного → отказ (fail-closed вместо суда индекса коммита)
#   sb22 → B25 принят только <git-dir>/index.lock: next-index-*.lock частичного коммита — нет
#   sb23 → B29 git-dir как "$R/.git", не --absolute-git-dir: связанный worktree слеп
#   sb24 → B30 GIT_INDEX_FILE принят без проверки «под git-dir корня» (гигиена 016 снята)
#   — круг 9 (adversary Б-2: guard слеп к обоим фиксам) —
#   sb25 → B31 канонизация `readlink -f` снята (310d467): путь `.git/../evil-index`
#                                              принимается лексически как `.git/*`
#                                              (sb* — тело целиком, не porcha: форма
#                                              многострочная, своп shapka невозможен)
#   sb26 → B32 захват секции в переменную снят (9893dc5): возврат `printf|awk|grep`,
#                                              SIGPIPE при awk exit в большой файл
#                                              (sb* — тело целиком, не porcha: фикс
#                                              многострочный, своп одной строки не
#                                              восстанавливает дефект)
#   — круг 11 (reviewer v5/v6 §Б-1, §Б-2): guard слеп к фиксам round10 —
#   sb27 → B34 fail-closed-ветвь readlink канонизации снята (7fa38bf): возврат к
#                                              `|| true` — readlink rc 127 → пустая
#                                              строка rc 0 → «пустая → дефолт» проходит
#                                              → индекс хука = дефолтному (ЧИСТЫЙ в B34)
#                                              → «нечего судить» rc 0 — OTKAZ_READLINK_088
#                                              не возникает (sb* — тело целиком)
#   sb28 → B33 захват секции в переменную откатан (9893dc5) + printf|grep: на
#                                              БОЛЬШОЙ первой секции grep находит
#                                              указатель на байте 1, выходит →
#                                              printf получает SIGPIPE 141 → false-FAIL
#                                              (sb* — тело целиком; форма multi-statement)
#
# Мини-судьи (честный и sb*) несут строку отказа и строку-указатель ЛИТЕРАЛАМИ из памяти
# оракула (OTKAZ_088, PTR_088 — _toy.sh, единый источник; арбитраж 088 круг 5: судья —
# константа, 074 не читает), индекс коммита берут из GIT_INDEX_FILE хука, принятого только
# под --absolute-git-dir корня (иначе .git/index — гигиена 016); оракул в env субъектов не
# передаётся (как и судимому).
#
# Использование: bash red_stuby_088.sh <корень>. Итог: «стаб-пак 088: N/39 поймано,
# диффпроба M/39»; rc 0 ⟺ N = M = 39.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${1:-$HERE/../..}" 2>/dev/null && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
set --
# Оракул в памяти (PTR_088, OTKAZ_088) и скратч — каркас семьи.
# shellcheck disable=SC1091
. "$HERE/_toy.sh"
ST="$SCR"

# shapka — голова мини-судьи: литералы оракула; индекс коммита — GIT_INDEX_FILE хука,
# если он лежит под --absolute-git-dir корня, иначе .git/index.
shapka() {
  printf '#!/usr/bin/env bash\nset -uo pipefail\nR="$1"\nOTKAZ_088=%q\n_lit_ptr=%q\n' "$OTKAZ_088" "$PTR_088"
  cat <<'EOF'
_idx="${GIT_INDEX_FILE:-}"
unset GIT_INDEX_FILE
gd="$(git -C "$R" rev-parse --absolute-git-dir 2>/dev/null)" || { printf 'NOT_IMPLEMENTED: нет git-dir\n' >&2; exit 2; }
case "$_idx" in "$gd"/*) [ -f "$_idx" ] && export GIT_INDEX_FILE="$_idx" ;; esac
PTR_088="$_lit_ptr"
EOF
}

# ── честные мини-субъекты (только для диффпробы) ─────────────────────────────
cat > "$ST/dver_chestnaja.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
glob_lit() { printf '%s' "$1" | sed 's/[][\\*?]/\\&/g'; }
nl=$'\n'
if [ -z "${ORCH_SESS_GLOB:-}" ] && [ -z "${ORCH_SESS_DIR:-}" ]; then
  uh="$(getent passwd "$(id -un)" | cut -d: -f6)"
  [ -n "$uh" ] || { printf 'NOT_IMPLEMENTED: нет дома в passwd\n' >&2; exit 2; }
  uh="$(glob_lit "$uh")"
  HOME="$uh" . "$ROOT/scripts/lib_session.sh"
else
  . "$ROOT/scripts/lib_session.sh"
fi
d="${ORCH_SESS_DIR:-$(set +o pipefail; IFS="$nl"; current_session_dir)}"
n="$(live_subagents_in "$d")" || exit 2
[ -z "$n" ] || { printf 'ОТКАЗ: живые субагенты: %s\n' "$n" >&2; exit 1; }
[ "$(git -C "$ROOT" rev-parse HEAD)" = "$(git -C "$ROOT" rev-parse origin/main)" ] \
  || { printf 'ОТКАЗ: HEAD расходится с origin/main\n' >&2; exit 1; }
exit 0
EOF

{ shapka; cat <<'EOF'
sekcija() { awk '!d && index($0,"## ГДЕ МЫ")==1{f=1;d=1;next} f && /^## /{exit} f'; }
if git -C "$R" diff --cached --name-only --no-renames -z | grep -zFxq -- HANDOFF.md; then
  git -C "$R" show :HANDOFF.md 2>/dev/null | sekcija | grep -Fxq -- "$PTR_088" \
    || { printf '%s\n' "$OTKAZ_088" >&2; exit 1; }
fi
exit 0
EOF
} > "$ST/sudja_chestnyj.sh"

# porcha <откуда> <куда> <старое> <новое> — побайтовая подмена ровно одного вхождения;
# ноль или больше одного вхождения — rc 2 (стаб не построен = нечем проверить).
porcha() {
  python3 - "$1" "$2" "$3" "$4" <<'PY' || { printf 'NOT_IMPLEMENTED: порча %s не построена\n' "$2" >&2; exit 2; }
import sys
src, dst, old, new = sys.argv[1:5]
t = open(src, encoding='utf-8').read()
if t.count(old) != 1:
    sys.exit(1)
open(dst, 'w', encoding='utf-8').write(t.replace(old, new))
PY
}

# ── стабы двери: честная мини-дверь с ОДНОЙ порчей ───────────────────────────
D="$ST/dver_chestnaja.sh"
VYZOV_D='d="${ORCH_SESS_DIR:-$(set +o pipefail; IFS="$nl"; current_session_dir)}"'
IFS= read -r -d '' PEREBIVKA_FB08E98 <<'EOF'
current_session_dir() {
  local glob_home glob_rest f
  glob_home="${ORCH_SESS_GLOB%%/.local/state/*}"
  if [ "$glob_home" = "$ORCH_SESS_GLOB" ]; then
    f="$(ls -t $ORCH_SESS_GLOB 2>/dev/null | head -1)" || return 0
  else
    glob_rest="${ORCH_SESS_GLOB#"$glob_home"/}"
    set +o pipefail
    f="$(cd "$glob_home" && ls -t $glob_rest 2>/dev/null | head -1)" || return 0
  fi
  [ -n "$f" ] || return 0
  case "$f" in /*) ;; *) f="$glob_home/$f" ;; esac
  printf '%s/%s' "$(dirname -- "$f")" "$(basename -- "$f" .jsonl)"
}
d="${ORCH_SESS_DIR:-$(set +o pipefail; current_session_dir 2>/dev/null || true)}"
EOF
porcha "$D" "$ST/sa1.sh" 'HOME="$uh" . "$ROOT/scripts/lib_session.sh"' '. "$ROOT/scripts/lib_session.sh"'
porcha "$D" "$ST/sa2.sh" "$VYZOV_D" 'current_session_dir() { local f; f="$(ls -t $ORCH_SESS_GLOB 2>/dev/null | head -1)" || return 0; [ -n "$f" ] || return 0; printf "%s/%s" "$(dirname -- "$f")" "$(basename -- "$f" .jsonl)"; }; d="${ORCH_SESS_DIR:-$(current_session_dir)}"'
porcha "$D" "$ST/sa3.sh" 'getent passwd "$(id -un)"' 'getent passwd "${USER:-$(id -un)}"'
porcha "$D" "$ST/sa4.sh" 'if [ -z "${ORCH_SESS_GLOB:-}" ] && [ -z "${ORCH_SESS_DIR:-}" ]; then' 'unset ORCH_SESS_GLOB; if [ -z "${ORCH_SESS_DIR:-}" ]; then'
porcha "$D" "$ST/sa5.sh" 'n="$(live_subagents_in "$d")" || exit 2' 'n="$(cd "$d" 2>/dev/null && ls -- *.jsonl 2>/dev/null | sed "s/\.jsonl\$//" | LC_ALL=C sort | paste -sd, -)"'
porcha "$D" "$ST/sa6.sh" 'n="$(live_subagents_in "$d")" || exit 2' 'n="$(live_subagents_in "$d")" || exit 2; k=(); IFS=, read -r -a l <<< "$n"; for x in "${l[@]}"; do case "$x" in .*) ;; *) k+=("$x") ;; esac; done; n="$(IFS=,; printf "%s" "${k[*]}")"'
porcha "$D" "$ST/sa7.sh" 'set +o pipefail; IFS="$nl"; current_session_dir' 'set +o pipefail; current_session_dir'
porcha "$D" "$ST/sa8.sh" 'uh="$(glob_lit "$uh")"' 'uh="$uh"'
porcha "$D" "$ST/sa9.tmp" 'uh="$(glob_lit "$uh")"' 'uh="$uh"'
porcha "$ST/sa9.tmp" "$ST/sa9.sh" "$VYZOV_D" "$PEREBIVKA_FB08E98"
porcha "$D" "$ST/sa10.sh" 'set +o pipefail; IFS="$nl"; current_session_dir' 'set +o pipefail; [ -z "${uh:-}" ] || IFS="$nl"; current_session_dir'
porcha "$D" "$ST/sa11.sh" 'set +o pipefail; IFS="$nl"; current_session_dir' 'set +o pipefail; [[ "$ORCH_SESS_GLOB" != *" "* ]] || IFS="$nl"; current_session_dir'

# ── стабы судьи: честный мини-судья с ОДНОЙ порчей (sb1, sb9 — свои тела) ────
S="$ST/sudja_chestnyj.sh"
STROKA_PTR='PTR_088="$_lit_ptr"'
VOZVRAT_IDX='case "$_idx" in "$gd"/*) [ -f "$_idx" ] && export GIT_INDEX_FILE="$_idx" ;; esac'
cat > "$ST/sb1.sh" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
porcha "$S" "$ST/sb2.sh" '| sekcija | grep -Fxq -- "$PTR_088"' '| sekcija | grep -Fq -- "$PTR_088"'
porcha "$S" "$ST/sb3.sh" '| sekcija | grep -Fxq -- "$PTR_088"' '| grep -Fxq -- "$PTR_088"'
porcha "$S" "$ST/sb4.sh" "awk '!d && index(\$0,\"## ГДЕ МЫ\")==1{f=1;d=1;next} f && /^## /{exit} f'" "awk 'index(\$0,\"## ГДЕ МЫ\")==1{f=1;next} f && /^## /{f=0} f'"
porcha "$S" "$ST/sb5.sh" 'f && /^## /{exit} f' 'f && /^#/{exit} f'
porcha "$S" "$ST/sb6.sh" 'git -C "$R" show :HANDOFF.md 2>/dev/null |' 'cat -- "$R/HANDOFF.md" 2>/dev/null |'
porcha "$S" "$ST/sb7.sh" 'if git -C "$R" diff --cached --name-only --no-renames -z | grep -zFxq -- HANDOFF.md; then' 'if true; then'
porcha "$S" "$ST/sb8.sh" 'diff --cached --name-only --no-renames -z' 'diff --cached --name-only --no-renames --diff-filter=AM -z'
{ shapka; cat <<'EOF'
sekcija() { awk '!d && index($0,"## ГДЕ МЫ")==1{f=1;d=1;next} f && /^## /{exit} f'; }
while IFS= read -r -d '' p; do
  case "$p" in HANDOFF.md|*/HANDOFF.md)
    git -C "$R" show ":$p" 2>/dev/null | sekcija | grep -Fxq -- "$PTR_088" \
      || { printf '%s\n' "$OTKAZ_088" >&2; exit 1; } ;;
  esac
done < <(git -C "$R" diff --cached --name-only --no-renames -z)
exit 0
EOF
} > "$ST/sb9.sh"
porcha "$S" "$ST/sb10.sh" "{ printf '%s\\n' \"\$OTKAZ_088\" >&2; exit 1; }" "{ printf 'ОТКАЗ: нет указателя\\n' >&2; exit 1; }"
porcha "$S" "$ST/sb11.sh" "$STROKA_PTR" 'PTR_088="${PTR_088:-$_lit_ptr}"'
# Источники k7 из фикстуры 074 — замены строки-константы (sb12, sb16-sb19).
IFS= read -r -d '' K7_RABOCHAJA <<'EOF'
mapfile -t _p < <(sed -n "s/^HANDOFF_PTR='\(.*\)'\$/\1/p" "$R/fixtures/ops_server/red_server_obvjazka_074.sh" 2>/dev/null)
[ "${#_p[@]}" -eq 1 ] && [ -n "${_p[0]}" ] || { printf 'NOT_IMPLEMENTED: в рабочей k7 нет единственного HANDOFF_PTR\n' >&2; exit 2; }
PTR_088="${_p[0]}"
EOF
IFS= read -r -d '' K7_INDEKS_BEZ_BLOBA_PROPUSK <<'EOF'
_b="$(git -C "$R" show :fixtures/ops_server/red_server_obvjazka_074.sh 2>/dev/null)" || exit 0
mapfile -t _p < <(printf '%s\n' "$_b" | sed -n "s/^HANDOFF_PTR='\(.*\)'\$/\1/p")
[ "${#_p[@]}" -eq 1 ] && [ -n "${_p[0]}" ] || { printf '%s\n' "$OTKAZ_088" >&2; exit 1; }
PTR_088="${_p[0]}"
EOF
IFS= read -r -d '' K7_INDEKS_NEODNOZNACHNO_PROPUSK <<'EOF'
_b="$(git -C "$R" show :fixtures/ops_server/red_server_obvjazka_074.sh 2>/dev/null)" || { printf '%s\n' "$OTKAZ_088" >&2; exit 1; }
mapfile -t _p < <(printf '%s\n' "$_b" | sed -n "s/^HANDOFF_PTR='\(.*\)'\$/\1/p")
[ "${#_p[@]}" -eq 1 ] && [ -n "${_p[0]}" ] || exit 0
PTR_088="${_p[0]}"
EOF
IFS= read -r -d '' K7_INDEKS_S_OTKAZOM <<'EOF'
_b="$(git -C "$R" show :fixtures/ops_server/red_server_obvjazka_074.sh 2>/dev/null)" || { printf '%s\n' "$OTKAZ_088" >&2; exit 1; }
mapfile -t _p < <(printf '%s\n' "$_b" | sed -n "s/^HANDOFF_PTR='\(.*\)'\$/\1/p")
[ "${#_p[@]}" -eq 1 ] && [ -n "${_p[0]}" ] || { printf '%s\n' "$OTKAZ_088" >&2; exit 1; }
PTR_088="${_p[0]}"
EOF
IFS= read -r -d '' K7_HEAD_S_OTKAZOM <<'EOF'
_b="$(git -C "$R" show HEAD:fixtures/ops_server/red_server_obvjazka_074.sh 2>/dev/null)" || { printf '%s\n' "$OTKAZ_088" >&2; exit 1; }
mapfile -t _p < <(printf '%s\n' "$_b" | sed -n "s/^HANDOFF_PTR='\(.*\)'\$/\1/p")
[ "${#_p[@]}" -eq 1 ] && [ -n "${_p[0]}" ] || { printf '%s\n' "$OTKAZ_088" >&2; exit 1; }
PTR_088="${_p[0]}"
EOF
porcha "$S" "$ST/sb12.sh" "$STROKA_PTR" "$K7_RABOCHAJA"
porcha "$S" "$ST/sb13.sh" 'R="$1"' 'R="$1"; [ -f "$R/fixtures/ops_server/red_server_obvjazka_074.sh" ] || exit 0'
# sb14/sb15 — две порчи: env OTKAZ_088 снят ДО присваивания литерала шапкой, затем печать.
porcha "$S" "$ST/sb14.tmp" 'R="$1"' 'R="$1"; _sreda_otkaz="${OTKAZ_088:-}"'
porcha "$ST/sb14.tmp" "$ST/sb14.sh" "{ printf '%s\\n' \"\$OTKAZ_088\" >&2; exit 1; }" "{ printf '%s\\n' \"\${_sreda_otkaz:-\$OTKAZ_088}\" >&2; exit 1; }"
porcha "$S" "$ST/sb15.tmp" 'R="$1"' 'R="$1"; _sreda_otkaz="${OTKAZ_088:-}"'
porcha "$ST/sb15.tmp" "$ST/sb15.sh" 'if git -C "$R" diff --cached --name-only --no-renames -z | grep -zFxq -- HANDOFF.md; then' 'if git -C "$R" diff --cached --name-only --no-renames -z | grep -zFxq -- HANDOFF.md; then git -C "$R" cat-file -e :HANDOFF.md 2>/dev/null || { printf "%s\n" "${_sreda_otkaz:-$OTKAZ_088}" >&2; exit 1; }'
porcha "$S" "$ST/sb16.sh" "$STROKA_PTR" "$K7_INDEKS_BEZ_BLOBA_PROPUSK"
porcha "$S" "$ST/sb17.sh" "$STROKA_PTR" "$K7_INDEKS_NEODNOZNACHNO_PROPUSK"
porcha "$S" "$ST/sb18.sh" "$STROKA_PTR" "$K7_INDEKS_S_OTKAZOM"
porcha "$S" "$ST/sb19.sh" "$STROKA_PTR" "$K7_HEAD_S_OTKAZOM"
# Источник индекса коммита (Б-2) — порча строки возврата GIT_INDEX_FILE хука (sb20-sb24).
porcha "$S" "$ST/sb20.sh" "$VOZVRAT_IDX" ':'
porcha "$S" "$ST/sb21.sh" "$VOZVRAT_IDX" "case \"\$_idx\" in \"\"|.git/index|\"\$gd\"/index) ;; *) printf '%s\\n' \"\$OTKAZ_088\" >&2; exit 1 ;; esac"
porcha "$S" "$ST/sb22.sh" '"$gd"/*)' '"$gd"/index.lock)'
porcha "$S" "$ST/sb23.sh" 'gd="$(git -C "$R" rev-parse --absolute-git-dir 2>/dev/null)"' 'gd="$R/.git"'
porcha "$S" "$ST/sb24.sh" "$VOZVRAT_IDX" '[ -z "$_idx" ] || export GIT_INDEX_FILE="$_idx"'

# ── база для новых клеток круга 9 (310d467 readlink + 9893dc5 захват секции) ──
# SC: мини-судья, НЕСУЩИЙ ОБЕ фиксы круг 9 + fail-closed-ветвь readlink round10 —
# диффпроба B31/B32/B33/B34 (положительный контроль). Канонизация `readlink -f`
# для GIT_INDEX_FILE (310d467), секция HANDOFF захватывается в переменную
# (9893dc5), fail-closed-ветвь readlink при rc≠0 или пустой канонизации (7fa38bf).
# В остальном — структура и орáкул (OTKAZ_088/PTR_088 в env) как у chestnyj.
SC="$ST/sudja_chestnyj_canon.sh"
cat > "$SC" <<EOF
#!/usr/bin/env bash
set -uo pipefail
R="\$1"
OTKAZ_088=${OTKAZ_088@Q}
_lit_ptr=${PTR_088@Q}
_idx="\${GIT_INDEX_FILE:-}"
unset GIT_INDEX_FILE
gd="\$(git -C "\$R" rev-parse --absolute-git-dir 2>/dev/null)" || { printf 'NOT_IMPLEMENTED: нет git-dir\\n' >&2; exit 2; }
case "\$_idx" in
  /*)
    if [ -f "\$_idx" ]; then
      _o="\$(readlink -f -- "\$_idx" 2>/dev/null)"; _rl_orig=\$?
      _g="\$(readlink -f -- "\$gd" 2>/dev/null)"; _rl_dir=\$?
      if [ "\$_rl_orig" -ne 0 ] || [ "\$_rl_dir" -ne 0 ] \\
         || [ -z "\$_o" ] || [ -z "\$_g" ]; then
        printf 'ОТКАЗ: канонизация путей не удалась — readlink rc=%s для индекса «%s», rc=%s для git-dir «%s»; индекс коммита не может быть принят без подтверждения «под git-dir», отказ (контракт 088)\\n' \\
          "\$_rl_orig" "\$_idx" "\$_rl_dir" "\$gd" >&2
        exit 1
      fi
      if case "\$_o" in "\$_g"/*) export GIT_INDEX_FILE="\$_o" ;; esac; then :; fi
    fi
    ;;
esac
PTR_088="\$_lit_ptr"
sekcija() { awk '!d && index(\$0,"## ГДЕ МЫ")==1{f=1;d=1;next} f && /^## /{exit} f'; }
if git -C "\$R" diff --cached --name-only --no-renames -z | grep -zFxq -- HANDOFF.md; then
  _section="\$(git -C "\$R" show :HANDOFF.md 2>/dev/null | sekcija)"
  if ! grep -Fxq -- "\$PTR_088" <<<"\$_section"; then
    printf '%s\\n' "\$OTKAZ_088" >&2; exit 1
  fi
fi
exit 0
EOF
chmod +x "$SC"

# sb25 → B31: канонизация `readlink -f` снята, остаётся прежнее лексическое
# принятие `<git-dir>/<anything-including-..>`. Через `..` судья принимает
# путь ВНЕ git-dir, не судит его → обход. Полное тело (не porcha):
# отличия от chestnyj минимальные, и свопать одну строку в shapka
# нельзя — форма многострочная. Поэтому sb25 — отдельный мини-судья.
cat > "$ST/sb25.sh" <<EOF
#!/usr/bin/env bash
set -uo pipefail
R="\$1"
OTKAZ_088=${OTKAZ_088@Q}
_lit_ptr=${PTR_088@Q}
_idx="\${GIT_INDEX_FILE:-}"
unset GIT_INDEX_FILE
gd="\$(git -C "\$R" rev-parse --absolute-git-dir 2>/dev/null)" || { printf 'NOT_IMPLEMENTED: нет git-dir\\n' >&2; exit 2; }
case "\$_idx" in "\$gd"/*) [ -f "\$_idx" ] && export GIT_INDEX_FILE="\$_idx" ;; esac
PTR_088="\$_lit_ptr"
sekcija() { awk '!d && index(\$0,"## ГДЕ МЫ")==1{f=1;d=1;next} f && /^## /{exit} f'; }
if git -C "\$R" diff --cached --name-only --no-renames -z | grep -zFxq -- HANDOFF.md; then
  _section="\$(git -C "\$R" show :HANDOFF.md 2>/dev/null | sekcija)"
  if ! grep -Fxq -- "\$PTR_088" <<<"\$_section"; then
    printf '%s\\n' "\$OTKAZ_088" >&2; exit 1
  fi
fi
exit 0
EOF
chmod +x "$ST/sb25.sh"

# sb26 → B32: захват секции в переменную снят, возврат к старому
# `printf|awk|grep` (pre-9893dc5). При форме Н-214 (малая секция, большой
# хвост) awk рвёт pipe на границе секции 1 → SIGPIPE 141 → ложный отказ.
# Канонизация GIT_INDEX_FILE сохранена (310d467 не предмет B32).
cat > "$ST/sb26.sh" <<EOF
#!/usr/bin/env bash
set -uo pipefail
R="\$1"
OTKAZ_088=${OTKAZ_088@Q}
_lit_ptr=${PTR_088@Q}
_idx="\${GIT_INDEX_FILE:-}"
unset GIT_INDEX_FILE
gd="\$(git -C "\$R" rev-parse --absolute-git-dir 2>/dev/null)" || { printf 'NOT_IMPLEMENTED: нет git-dir\\n' >&2; exit 2; }
case "\$_idx" in
  /*)
    if [ -f "\$_idx" ]; then
      _o="\$(readlink -f -- "\$_idx" 2>/dev/null)"; _rl_orig=\$?
      _g="\$(readlink -f -- "\$gd" 2>/dev/null)"; _rl_dir=\$?
      if [ "\$_rl_orig" -ne 0 ] || [ "\$_rl_dir" -ne 0 ] \\
         || [ -z "\$_o" ] || [ -z "\$_g" ]; then
        printf 'ОТКАЗ: канонизация путей не удалась — readlink rc=%s для индекса «%s», rc=%s для git-dir «%s»; индекс коммита не может быть принят без подтверждения «под git-dir», отказ (контракт 088)\\n' \\
          "\$_rl_orig" "\$_idx" "\$_rl_dir" "\$gd" >&2
        exit 1
      fi
      if case "\$_o" in "\$_g"/*) export GIT_INDEX_FILE="\$_o" ;; esac; then :; fi
    fi
    ;;
esac
PTR_088="\$_lit_ptr"
if git -C "\$R" diff --cached --name-only --no-renames -z | grep -zFxq -- HANDOFF.md; then
  if ! git -C "\$R" show :HANDOFF.md 2>/dev/null \\
       | awk '!d && index(\$0,"## ГДЕ МЫ")==1{f=1;d=1;next} f && /^## /{exit} f' \\
       | grep -Fxq -- "\$PTR_088"; then
    printf '%s\\n' "\$OTKAZ_088" >&2; exit 1
  fi
fi
exit 0
EOF
chmod +x "$ST/sb26.sh"

# sb27 → B34: fail-closed-ветвь readlink канонизации снята (откат round10 7fa38bf
# к `|| true`). При шиме `readlink rc 127` readlink -f возвращает пустую строку
# rc 0 → проверка «пустая → дефолт» проходит → GIT_INDEX_FILE = дефолтному
# (ЧИСТЫЙ в B34) → `git diff --cached` пуст → rc 0 «нечего судить» — OTKAZ_READLINK_088
# НЕ возникает → B34 красная на sb27. Канонизация readlink -f и секция в
# переменную (9893dc5) сохранены (предмет B34 — fail-closed, не SIGPIPE).
# Тело строится одним вызовом porcha от $SC: 9-строчный блок (readlink
# с захватом rc + fail-closed-ветвь) свопнут на 3-строчный открытый вариант
# (readlink с `|| true` + простое условие «оба непусты и путь под git-dir»).
IFS= read -r -d '' SB27_OLD <<'EOF'
      _o="$(readlink -f -- "$_idx" 2>/dev/null)"; _rl_orig=$?
      _g="$(readlink -f -- "$gd" 2>/dev/null)"; _rl_dir=$?
      if [ "$_rl_orig" -ne 0 ] || [ "$_rl_dir" -ne 0 ] \
         || [ -z "$_o" ] || [ -z "$_g" ]; then
        printf 'ОТКАЗ: канонизация путей не удалась — readlink rc=%s для индекса «%s», rc=%s для git-dir «%s»; индекс коммита не может быть принят без подтверждения «под git-dir», отказ (контракт 088)\n' \
          "$_rl_orig" "$_idx" "$_rl_dir" "$gd" >&2
        exit 1
      fi
      if case "$_o" in "$_g"/*) export GIT_INDEX_FILE="$_o" ;; esac; then :; fi
EOF
IFS= read -r -d '' SB27_NEW <<'EOF'
      _o="$(readlink -f -- "$_idx" 2>/dev/null || true)"
      _g="$(readlink -f -- "$gd" 2>/dev/null || true)"
      if [ -n "$_o" ] && [ -n "$_g" ] && case "$_o" in "$_g"/*) export GIT_INDEX_FILE="$_o" ;; esac; then :; fi
EOF
porcha "$SC" "$ST/sb27.sh" "$SB27_OLD" "$SB27_NEW"
chmod +x "$ST/sb27.sh"

# sb28 → B33: захват секции в переменную (9893dc5) снят, возврат к OLD
# `printf '%s\n' "$section" | grep -Fxq`. На форме v5 §(б) (БОЛЬШАЯ первая секция,
# указатель строкой №1) grep -Fxq находит указатель на байте 1, выходит →
# printf получает SIGPIPE 141 → `if ! pipeline` под pipefail уходит в ОТКАЗ И-7
# — false-FAIL. Канонизация readlink + fail-closed (7fa38bf) сохранена.
# Тело строится одним вызовом porcha от $SC: одна строка свопа
# `<<<"$_section"` (9893dc5) на `printf '%s\n' "$_section" |` (pre-9893dc5).
IFS= read -r -d '' SB28_OLD <<'EOF'
  if ! grep -Fxq -- "$PTR_088" <<<"$_section"; then
EOF
IFS= read -r -d '' SB28_NEW <<'EOF'
  if ! printf '%s\n' "$_section" | grep -Fxq -- "$PTR_088"; then
EOF
porcha "$SC" "$ST/sb28.sh" "$SB28_OLD" "$SB28_NEW"
chmod +x "$ST/sb28.sh"

# ── прогон: стаб на своей клетке (красная), честный мини-субъект там же (зелёная) ──
pojmano=0; diff_ok=0; vsego=0; itog=0
para() {  # <стаб> <файл семьи> <флаг подмены> <честный> <клетка>
  local stub="$1" fam="$2" flag="$3" honest="$4" c="$5" rc_s rc_h
  vsego=$((vsego + 1))
  bash "$HERE/$fam" "$ROOT" "$c" "$flag" "$ST/$stub.sh" >/dev/null 2>&1; rc_s=$?
  bash "$HERE/$fam" "$ROOT" "$c" "$flag" "$honest" >/dev/null 2>&1; rc_h=$?
  if [ "$rc_s" -eq 1 ]; then pojmano=$((pojmano + 1)); printf '  стаб %s пойман (вход %s)\n' "$stub" "$c"
  elif [ "$rc_s" -eq 2 ]; then printf 'NOT_IMPLEMENTED: стаб %s на %s — rc 2\n' "$stub" "$c" >&2; [ "$itog" -ne 0 ] || itog=2
  else printf 'КРАСНО: стаб %s жив на %s (клетка зелёная на дефекте)\n' "$stub" "$c"; itog=1
  fi
  if [ "$rc_h" -eq 0 ]; then diff_ok=$((diff_ok + 1))
  elif [ "$rc_h" -eq 2 ]; then printf 'NOT_IMPLEMENTED: диффпроба %s — rc 2\n' "$c" >&2; [ "$itog" -ne 0 ] || itog=2
  else printf 'КРАСНО: диффпроба %s — честный мини-субъект красен (клетка ловит себя)\n' "$c"; itog=1
  fi
}
para sa1 red_dver_088.sh --dver "$D" D1
para sa2 red_dver_088.sh --dver "$D" D2
para sa3 red_dver_088.sh --dver "$D" D3
para sa4 red_dver_088.sh --dver "$D" D4
para sa5 red_dver_088.sh --dver "$D" D0
para sa6 red_dver_088.sh --dver "$D" D5
para sa7 red_dver_088.sh --dver "$D" D6
para sa8 red_dver_088.sh --dver "$D" D7
para sa9 red_dver_088.sh --dver "$D" D8
para sa10 red_dver_088.sh --dver "$D" D9
para sa11 red_dver_088.sh --dver "$D" D10
para sb1 red_ukazatel_088.sh --sudja "$S" B1
para sb2 red_ukazatel_088.sh --sudja "$S" B3
para sb3 red_ukazatel_088.sh --sudja "$S" B6
para sb4 red_ukazatel_088.sh --sudja "$S" B4
para sb5 red_ukazatel_088.sh --sudja "$S" B5
para sb6 red_ukazatel_088.sh --sudja "$S" B7
para sb7 red_ukazatel_088.sh --sudja "$S" B9
para sb8 red_ukazatel_088.sh --sudja "$S" B11
para sb9 red_ukazatel_088.sh --sudja "$S" B13
para sb10 red_ukazatel_088.sh --sudja "$S" B1
para sb11 red_ukazatel_088.sh --sudja "$S" B14
para sb12 red_ukazatel_088.sh --sudja "$S" B15
para sb13 red_ukazatel_088.sh --sudja "$S" B16
para sb14 red_ukazatel_088.sh --sudja "$S" B17
para sb15 red_ukazatel_088.sh --sudja "$S" B18
para sb16 red_ukazatel_088.sh --sudja "$S" B19
para sb17 red_ukazatel_088.sh --sudja "$S" B20
para sb18 red_ukazatel_088.sh --sudja "$S" B21
para sb19 red_ukazatel_088.sh --sudja "$S" B22
para sb20 red_ukazatel_088.sh --sudja "$S" B23
para sb21 red_ukazatel_088.sh --sudja "$S" B24
para sb22 red_ukazatel_088.sh --sudja "$S" B25
para sb23 red_ukazatel_088.sh --sudja "$S" B29
para sb24 red_ukazatel_088.sh --sudja "$S" B30
# Круг 9: новые клетки под новый честный мини-судья ($SC — с обоими фиксами).
para sb25 red_ukazatel_088.sh --sudja "$SC" B31
para sb26 red_ukazatel_088.sh --sudja "$SC" B32
# Круг 11: новые клетки под $SC (fail-closed добавлен в Н-2) — диффпроба.
para sb27 red_ukazatel_088.sh --sudja "$SC" B34
para sb28 red_ukazatel_088.sh --sudja "$SC" B33
printf 'стаб-пак 088: %d/%d поймано, диффпроба %d/%d\n' "$pojmano" "$vsego" "$diff_ok" "$vsego"
[ "$vsego" -eq 39 ] || { printf 'NOT_IMPLEMENTED: в паке %d стабов, ожидалось 39\n' "$vsego" >&2; exit 2; }
exit "$itog"
