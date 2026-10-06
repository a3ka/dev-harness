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
#
# Использование: bash red_stuby_088.sh <корень>. Итог: «стаб-пак 088: N/15 поймано,
# диффпроба M/15»; rc 0 ⟺ N = M = 15.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${1:-$HERE/../..}" 2>/dev/null && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
ST="$(mktemp -d "${TMPDIR:-/tmp}/stuby088.XXXXXX")" || { printf 'NOT_IMPLEMENTED: нет скратча\n' >&2; exit 2; }
trap 'rm -rf -- "$ST"' EXIT

# ── честные мини-субъекты (только для диффпробы) ─────────────────────────────
cat > "$ST/dver_chestnaja.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
if [ -z "${ORCH_SESS_GLOB:-}" ] && [ -z "${ORCH_SESS_DIR:-}" ]; then
  uh="$(getent passwd "$(id -un)" | cut -d: -f6)"
  [ -n "$uh" ] || { printf 'NOT_IMPLEMENTED: нет дома в passwd\n' >&2; exit 2; }
  HOME="$uh" . "$ROOT/scripts/lib_session.sh"
else
  . "$ROOT/scripts/lib_session.sh"
fi
d="${ORCH_SESS_DIR:-$(set +o pipefail; current_session_dir)}"
n="$(live_subagents_in "$d")" || exit 2
[ -z "$n" ] || { printf 'ОТКАЗ: живые субагенты: %s\n' "$n" >&2; exit 1; }
[ "$(git -C "$ROOT" rev-parse HEAD)" = "$(git -C "$ROOT" rev-parse origin/main)" ] \
  || { printf 'ОТКАЗ: HEAD расходится с origin/main\n' >&2; exit 1; }
exit 0
EOF

cat > "$ST/sudja_chestnyj.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
R="$1"
sekcija() { awk '!d && index($0,"## ГДЕ МЫ")==1{f=1;d=1;next} f && /^## /{exit} f'; }
if git -C "$R" diff --cached --name-only --no-renames -z | grep -zFxq -- HANDOFF.md; then
  git -C "$R" show :HANDOFF.md 2>/dev/null | sekcija | grep -Fxq -- "$PTR_088" \
    || { printf '%s\n' "$OTKAZ_088" >&2; exit 1; }
fi
exit 0
EOF

# ── стабы двери: честная мини-дверь с ОДНОЙ порчей ───────────────────────────
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
D="$ST/dver_chestnaja.sh"
porcha "$D" "$ST/sa1.sh" 'HOME="$uh" . "$ROOT/scripts/lib_session.sh"' '. "$ROOT/scripts/lib_session.sh"'
porcha "$D" "$ST/sa2.sh" 'd="${ORCH_SESS_DIR:-$(set +o pipefail; current_session_dir)}"' 'current_session_dir() { local f; f="$(ls -t $ORCH_SESS_GLOB 2>/dev/null | head -1)" || return 0; [ -n "$f" ] || return 0; printf "%s/%s" "$(dirname -- "$f")" "$(basename -- "$f" .jsonl)"; }; d="${ORCH_SESS_DIR:-$(current_session_dir)}"'
porcha "$D" "$ST/sa3.sh" 'getent passwd "$(id -un)"' 'getent passwd "${USER:-$(id -un)}"'
porcha "$D" "$ST/sa4.sh" 'if [ -z "${ORCH_SESS_GLOB:-}" ] && [ -z "${ORCH_SESS_DIR:-}" ]; then' 'unset ORCH_SESS_GLOB; if [ -z "${ORCH_SESS_DIR:-}" ]; then'
porcha "$D" "$ST/sa5.sh" 'n="$(live_subagents_in "$d")" || exit 2' 'n="$(cd "$d" 2>/dev/null && ls -- *.jsonl 2>/dev/null | sed "s/\.jsonl\$//" | LC_ALL=C sort | paste -sd, -)"'

S="$ST/sudja_chestnyj.sh"
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
cat > "$ST/sb9.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
R="$1"
sekcija() { awk '!d && index($0,"## ГДЕ МЫ")==1{f=1;d=1;next} f && /^## /{exit} f'; }
while IFS= read -r -d '' p; do
  case "$p" in HANDOFF.md|*/HANDOFF.md)
    git -C "$R" show ":$p" 2>/dev/null | sekcija | grep -Fxq -- "$PTR_088" \
      || { printf '%s\n' "$OTKAZ_088" >&2; exit 1; } ;;
  esac
done < <(git -C "$R" diff --cached --name-only --no-renames -z)
exit 0
EOF
porcha "$S" "$ST/sb10.sh" "{ printf '%s\\n' \"\$OTKAZ_088\" >&2; exit 1; }" "{ printf 'ОТКАЗ: нет указателя\\n' >&2; exit 1; }"

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
printf 'стаб-пак 088: %d/%d поймано, диффпроба %d/%d\n' "$pojmano" "$vsego" "$diff_ok" "$vsego"
[ "$vsego" -eq 15 ] || { printf 'NOT_IMPLEMENTED: в паке %d стабов, ожидалось 15\n' "$vsego" >&2; exit 2; }
exit "$itog"
