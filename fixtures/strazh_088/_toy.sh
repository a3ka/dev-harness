#!/usr/bin/env bash
# Каркас семьи 088 (НЕ case-файл, сам не прогоняется): подключается `. _toy.sh` из
# файлов семьи ПОСЛЕ присваивания ROOT (корень судимого дерева).
#
# Оракул — в ПАМЯТИ батареи (правило 8), ДО вызова субъекта, и в env субъекта НЕ попадает
# (не экспортируется; одноимённые переменные вызывающего сняты — иначе унаследованный
# атрибут export вынес бы оракул субъекту; adversary 088: экспорт PTR_088 маскировал
# обход И-5 «строка-указатель из env коммитёра»):
#   PTR_088   — строка-указатель. Единый источник тестового слоя — присваивание
#               HANDOFF_PTR в fixtures/ops_server/red_server_obvjazka_074.sh (клетка k7);
#               берётся оттуда побайтово, РОВНО одно совпадение `^HANDOFF_PTR='…'$`,
#               иначе rc 2 (второй копии строки в семье 088 нет). Субъект берёт k7 из
#               своего дерева: тоу-репо хука несёт закоммиченную побайтовую копию этого
#               файла (ukazatel_mir).
#   OTKAZ_088 — строка отказа хука (инвариант Б3 контракта 088), сверка `grep -Fxq`.
#   ATAKA_088 — строка коммитёра, не k7 (клетка B14: она же — в env PTR_088 коммита).
#   Ожидания клеток — константы клеток (вход строится известным конформным/неконформным).
# Сверка структурна: строка отказа — самостоятельной строкой stderr (`grep -Fxq`), HEAD до/
# после коммита — по rev-parse, маркер двери — по существованию файла шва.
set -uo pipefail
: "${ROOT:?ROOT не задан до подключения _toy.sh}"
# Н-NEW-7/Н-85: окружение вызывающего не протекает в тоу-миры.
unset GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL \
      GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_CONFIG_COUNT GIT_CEILING_DIRECTORIES \
      PTR_088 OTKAZ_088 ATAKA_088

SRC074="$ROOT/fixtures/ops_server/red_server_obvjazka_074.sh"
[ -f "$SRC074" ] || { printf 'NOT_IMPLEMENTED: нет источника строки-указателя %s\n' "$SRC074" >&2; exit 2; }
mapfile -t _ptr074 < <(sed -n "s/^HANDOFF_PTR='\(.*\)'\$/\1/p" "$SRC074")
if [ "${#_ptr074[@]}" -ne 1 ] || [ -z "${_ptr074[0]}" ]; then
  printf 'NOT_IMPLEMENTED: присваивание HANDOFF_PTR в %s не единственно (%s совпадений)\n' "$SRC074" "${#_ptr074[@]}" >&2
  exit 2
fi
PTR_088="${_ptr074[0]}"
OTKAZ_088='ОТКАЗ: HANDOFF.md — в первой секции «## ГДЕ МЫ» нет строки-указателя (контракт 088)'
ATAKA_088='attacker'
[ "$ATAKA_088" != "$PTR_088" ] || { printf 'NOT_IMPLEMENTED: строка коммитёра совпала с k7\n' >&2; exit 2; }

SCR="$(mktemp -d "${TMPDIR:-/tmp}/strazh088.XXXXXX")" || { printf 'NOT_IMPLEMENTED: нет скратча\n' >&2; exit 2; }
trap 'rm -rf -- "$SCR"' EXIT

KRASNYH=0
ZELENYH=0
PROPUSK=0
zeleno() { printf 'ЗЕЛЕНО: %s\n' "$1"; ZELENYH=$((ZELENYH + 1)); }
krasno() { printf 'КРАСНО: %s\n' "$1"; KRASNYH=$((KRASNYH + 1)); }
propusk() { printf 'ПРОПУСК (не зелёное): %s\n' "$1"; PROPUSK=$((PROPUSK + 1)); }

# Выбор клеток аргументами: пусто — все; иначе только названные.
VYBOR=" ${*:-} "
nado() { [ "$VYBOR" = "  " ] || case "$VYBOR" in *" $1 "*) return 0 ;; *) return 1 ;; esac; }

# Герметичный git для ПОСТРОЕНИЯ миров: хуки выключены, identity технической строкой.
gx() {
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$r" -c user.name=Фикстура -c user.email=fixture@local \
        -c commit.gpgsign=false -c core.hooksPath=/dev/null -c init.defaultBranch=main "$@"
}

# ── Часть Б: тоу-репо хука ───────────────────────────────────────────────────
# handoff_v <файл> <вариант> — HANDOFF.md по варианту (вход клетки; конформность — в клетке).
handoff_v() {
  local f="$1" v="$2" short
  short="${PTR_088%% (*}"
  [ "$short" != "$PTR_088" ] || { printf 'NOT_IMPLEMENTED: укороченная строка совпала с полной\n' >&2; exit 2; }
  case "$v" in
    pervaja)   printf '# HANDOFF\n\n## ГДЕ МЫ (тоу)\n\n%s\n\n### Подраздел\nтекст\n\n## Итог\nхвост\n' "$PTR_088" ;;
    net)       printf '# HANDOFF\n\n## ГДЕ МЫ (тоу)\n\nтекст без указателя\n\n## Итог\nхвост\n' ;;
    ukorochena) printf '# HANDOFF\n\n## ГДЕ МЫ (тоу)\n\n%s\n\n## Итог\nхвост\n' "$short" ;;
    hvost)     printf '# HANDOFF\n\n## ГДЕ МЫ (тоу)\n\n%s см. ниже\n\n## Итог\nхвост\n' "$PTR_088" ;;
    vtoraja)   printf '# HANDOFF\n\n## ГДЕ МЫ (тоу)\n\nтекст без указателя\n\n## ГДЕ МЫ (прошлая сессия)\n\n%s\n' "$PTR_088" ;;
    podrazdel) printf '# HANDOFF\n\n## ГДЕ МЫ (тоу)\n\nтекст\n\n### Подраздел\n\n%s\n\n## Итог\nхвост\n' "$PTR_088" ;;
    posle)     printf '# HANDOFF\n\n## ГДЕ МЫ (тоу)\n\nтекст без указателя\n\n## Итог\n\n%s\n' "$PTR_088" ;;
    chuzhaja)  printf '# HANDOFF\n\n## ГДЕ МЫ (тоу)\n\n%s\n\n## Итог\nхвост\n' "$ATAKA_088" ;;
    *) printf 'NOT_IMPLEMENTED: вариант HANDOFF %s\n' "$v" >&2; exit 2 ;;
  esac > "$f"
}

# ukazatel_mir <каталог> [<судья>] — тоу-репо: scripts/ и .githooks/ судимого дерева
# (судья scripts/check_staged.sh подменяется файлом стаба, если задан), HANDOFF.md с
# указателем и побайтовая копия fixtures/ops_server/red_server_obvjazka_074.sh (k7
# субъекта — из его дерева, не из env) закоммичены, хуки включены локальным
# core.hooksPath (не identity).
ukazatel_mir() {
  local r="$1" sudja="${2:-}"
  mkdir -p "$r/fixtures/ops_server" || exit 2
  cp -R -- "$ROOT/scripts" "$r/scripts" && cp -R -- "$ROOT/.githooks" "$r/.githooks" || exit 2
  cp -- "$SRC074" "$r/fixtures/ops_server/red_server_obvjazka_074.sh" || exit 2
  [ -z "$sudja" ] || cp -- "$sudja" "$r/scripts/check_staged.sh" || exit 2
  handoff_v "$r/HANDOFF.md" pervaja
  printf 'основа мира — любой вариант клетки отличается от HEAD\n' >> "$r/HANDOFF.md"
  printf 'основа\n' > "$r/README.md"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r" || exit 2
  gx "$r" add -A && gx "$r" commit -q -m 'основа' || exit 2
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config core.hooksPath .githooks || exit 2
}

# kommit <репо> [VAR=знач…] — коммит ЖИВЫМ способом оркестратора: identity `-c`,
# file-config пуст, хук активен; VAR=знач — окружение коммитёра (клетка B14). Печатает
# rc git; stderr — в $SCR/kommit.err.
kommit() {
  local r="$1"; shift
  env GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null "$@" \
    git -C "$r" -c user.name=orchestrator -c user.email=orchestrator@dev-harness.local \
        -c commit.gpgsign=false commit -q -m 'проба 088' >/dev/null 2>"$SCR/kommit.err"
}

# ozhidaj_b <клетка> <репо> prinjat|otkaz [VAR=знач…] — коммит и сверка исхода с ожиданием.
ozhidaj_b() {
  local c="$1" r="$2" ozh="$3" h0 h1 rc
  shift 3
  h0="$(gx "$r" rev-parse HEAD)" || exit 2
  kommit "$r" "$@"; rc=$?
  h1="$(gx "$r" rev-parse HEAD)" || exit 2
  if [ "$ozh" = prinjat ]; then
    if [ "$rc" -eq 0 ] && [ "$h0" != "$h1" ] && ! grep -Fxq -- "$OTKAZ_088" "$SCR/kommit.err"; then
      zeleno "$c"
    else
      krasno "$c: ожидался коммит, получено rc=$rc HEAD $( [ "$h0" = "$h1" ] && echo 'не сдвинут' || echo 'сдвинут'): $(head -c 300 "$SCR/kommit.err" | tr '\n' ' ')"
    fi
  else
    if [ "$rc" -ne 0 ] && [ "$h0" = "$h1" ] && grep -Fxq -- "$OTKAZ_088" "$SCR/kommit.err"; then
      zeleno "$c"
    else
      krasno "$c: ожидался отказ «$OTKAZ_088», получено rc=$rc HEAD $( [ "$h0" = "$h1" ] && echo 'не сдвинут' || echo 'сдвинут'): $(head -c 300 "$SCR/kommit.err" | tr '\n' ' ')"
    fi
  fi
}

# ── Часть А: тоу-мир двери и сессий ──────────────────────────────────────────
TOY_USER="$(id -un)" || { printf 'NOT_IMPLEMENTED: id -un\n' >&2; exit 2; }
TOY_UID="$(id -u)" || { printf 'NOT_IMPLEMENTED: id -u\n' >&2; exit 2; }
export TOY_USER TOY_UID

# Подмена getent (PATH-шим): `getent passwd <имя|uid>` даёт дом TOY_UH для имени/uid
# процесса, /nonexistent — для любого другого. Дверь зовёт настоящий код пути
# «дом из passwd»; подменён только ответ базы пользователей.
SHIM="$SCR/shim"
mkdir -p "$SHIM" || exit 2
cat > "$SHIM/getent" <<'EOF'
#!/usr/bin/env bash
[ "${1:-}" = passwd ] && [ -n "${2:-}" ] || exit 2
if [ "$2" = "$TOY_USER" ] || [ "$2" = "$TOY_UID" ]; then
  printf '%s:x:%s:%s::%s:/bin/bash\n' "$TOY_USER" "$TOY_UID" "$TOY_UID" "$TOY_UH"
else
  printf '%s:x:65534:65534::/nonexistent:/usr/sbin/nologin\n' "$2"
fi
EOF
chmod +x "$SHIM/getent"

# sess_kat <дом> — каталог session-уровня журналов по ЕДИНОМУ источнику глоба
# (умолчание ORCH_SESS_GLOB в scripts/lib_session.sh судимого дерева, вычисленное от
# <дом>): зона `*` → toyzone, хвост `/*.jsonl` снят. Второй копии глоба в семье нет.
sess_kat() {
  local glob
  glob="$(HOME="$1" bash -c 'unset ORCH_SESS_GLOB; . "$1" && printf %s "$ORCH_SESS_GLOB"' _ "$ROOT/scripts/lib_session.sh")" \
    || { printf 'NOT_IMPLEMENTED: lib_session.sh не дал ORCH_SESS_GLOB\n' >&2; exit 2; }
  case "$glob" in "$1"/*'/*/'*'/*.jsonl') ;; *) printf 'NOT_IMPLEMENTED: глоб вне ожидаемой формы: %s\n' "$glob" >&2; exit 2 ;; esac
  glob="${glob%/\*.jsonl}"
  printf '%s' "${glob/\/\*\//\/toyzone\/}"
}

# sessija <каталог session-уровня> <живые…> -- <старые…> — один session-журнал + каталог
# субагентов: живые — mtime сейчас, старые — час назад.
sessija() {
  local k="$1" s; shift
  s="$k/2026-10-06T00-00-00-000Z_toy088"
  mkdir -p "$s" || exit 2
  : > "$s.jsonl"
  local starye=0 n
  for n in "$@"; do
    if [ "$n" = -- ]; then starye=1; continue; fi
    : > "$s/$n.jsonl"
    [ "$starye" -eq 0 ] || touch -d '-1 hour' "$s/$n.jsonl"
  done
}

# dver_mir <каталог> [<дверь>] — тоу-корень двери: scripts/orch_restart.sh (судимый или
# стаб) + scripts/lib_session.sh судимого дерева; HEAD впереди origin/main, поэтому
# прошедшая ногу (1) дверь останавливается на (а) «HEAD расходится с origin/main» и
# маркер не ставит ни при каком исходе.
dver_mir() {
  local r="$1" dver="${2:-$ROOT/scripts/orch_restart.sh}"
  mkdir -p "$r/scripts" || exit 2
  cp -- "$dver" "$r/scripts/orch_restart.sh" && cp -- "$ROOT/scripts/lib_session.sh" "$r/scripts/lib_session.sh" || exit 2
  printf '# HANDOFF\n' > "$r/HANDOFF.md"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r" || exit 2
  gx "$r" add -A && gx "$r" commit -q -m 'основа' || exit 2
  gx "$r" update-ref refs/remotes/origin/main HEAD || exit 2
  printf 'вперёд\n' > "$r/vpered.txt"
  gx "$r" add -A && gx "$r" commit -q -m 'вперёд origin/main' || exit 2
}

# dver <корень> <дом-сессии> [VAR=знач…] — запуск двери в тоу-окружении: HOME — дом
# сессии omp (перенаправленный), getent — шим, швы сессии сняты (если не заданы
# аргументами), маркер и след — в скратче. stderr — $SCR/dver.err; печатает rc.
dver() {
  local r="$1" home="$2"; shift 2
  env -u ORCH_SESS_DIR -u ORCH_SESS_GLOB -u PI_CODING_AGENT_DIR \
      HOME="$home" PATH="$SHIM:$PATH" \
      ORCH_RESTART_MARKER="$SCR/marker" ORCH_SESSION_START="$SCR/start" "$@" \
      bash "$r/scripts/orch_restart.sh" --as orchestrator >/dev/null 2>"$SCR/dver.err"
}

# ozhidaj_a <клетка> <rc> zhivye <имена> | proshla — сверка исхода двери.
ozhidaj_a() {
  local c="$1" rc="$2" ozh="$3" imena="${4:-}"
  if [ -e "$SCR/marker" ]; then
    krasno "$c: маркер поставлен"; rm -f -- "$SCR/marker"; return
  fi
  if [ "$ozh" = zhivye ]; then
    if [ "$rc" -eq 1 ] && grep -Fxq -- "ОТКАЗ: живые субагенты: $imena" "$SCR/dver.err"; then
      zeleno "$c"
    else
      krasno "$c: ожидался отказ «живые субагенты: $imena», rc=$rc: $(head -c 300 "$SCR/dver.err" | tr '\n' ' ')"
    fi
  else
    if [ "$rc" -eq 1 ] && ! grep -q '^ОТКАЗ: живые субагенты:' "$SCR/dver.err" \
       && grep -Fxq -- 'ОТКАЗ: HEAD расходится с origin/main' "$SCR/dver.err"; then
      zeleno "$c"
    else
      krasno "$c: ожидался проход ноги (1) до (а), rc=$rc: $(head -c 300 "$SCR/dver.err" | tr '\n' ' ')"
    fi
  fi
}

itog_semji() {  # <имя файла семьи>
  printf '%s: зелёных %d, красных %d, пропусков %d\n' "$1" "$ZELENYH" "$KRASNYH" "$PROPUSK"
  [ "$KRASNYH" -eq 0 ] || exit 1
  [ "$ZELENYH" -gt 0 ] || { printf 'NOT_IMPLEMENTED: ни одной судимой клетки\n' >&2; exit 2; }
  exit 0
}
