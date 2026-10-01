#!/usr/bin/env bash
# 072-БАТАРЕЯ — «дверь перезапуска сессии»: scripts/orch_restart.sh —
# ЕДИНСТВЕННЫЙ способ поставить маркер /tmp/dev-harness-verify/orch-restart
# (слово владельца 2026-10-01, дословно в HANDOFF «ГДЕ МЫ»: гейт
# HEAD == origin/main; porcelain пусто; HANDOFF.md изменён коммитом ЭТОЙ
# сессии; check_no_leak rc 0; нет мусорных worktree → иначе именованный
# отказ; мусорные worktree чистые и приземлённые — удалить (расширение
# gc_agent_branches), прочие — назвать; строка роли «touch …» →
# «bash scripts/orch_restart.sh»; до done 072 маркер — прежним touch по
# чеклисту).
#
# Дом семьи — fixtures/perezapusk_sessii/ (probe-only, 034: МНОГОсубъектная
# проба — субъекты scripts/orch_restart.sh (новый) И расширение
# scripts/gc_agent_branches.sh И строка roles/orchestrator.md:387; барьерный
# ключ scripts/perezapusk_sessii.sh не существует и не появится), раннер —
# fixtures/_krasnye_072.sh. До-заморозочный носитель закоммичен АРХИТЕКТОРОМ
# (красные предъявления ДО круга критика; прецеденты 058/070).
#
# Структура (070-прецедент):
#   1. СТАБ-ПАК (7 обманных стабов двери, ручки STUB_*) — зелёный ДО и
#      ПОСЛЕ реализации: каждый стаб умирает на СВОЕЙ клетке; диффпроба —
#      те же стабы БЕЗ ручек проходят те же клетки (ловля предикатом,
#      не случаем).
#   2. г0 «предмет отсутствует» — fail-fast по НОСИТЕЛЮ: в дереве нет
#      scripts/orch_restart.sh → честная часть не исполняется, rc 1
#      (ДО-мера пачки: на 04b55b3 grep -c orch_restart scripts/ = 0).
#   3. ЧЕСТНАЯ ЧАСТЬ (клетки к1..к8) — зелёная ПОСЛЕ реализации:
#      к1 всё зелёно (легальный wip-worktree ВЫЖИВАЕТ) → rc 0, маркер;
#      к2 HEAD впереди origin → отказ «HEAD», маркера нет;
#      к3 porcelain грязен → отказ, маркера нет;
#      к4 HANDOFF.md последним коммитил ЧУЖОЙ автор → отказ, маркера нет;
#      к5 детектор красен (новый untracked после снимка) → отказ, маркера нет;
#      к6 мусорный worktree ГРЯЗНЫЙ → отказ с путём, worktree жив, маркера нет;
#      к7 мусорный worktree ЧИСТЫЙ+ПРИЗЕМЛЁННЫЙ → удалён (расширение gc),
#      rc 0, маркер;
#      к8 мусорный worktree ЧИСТЫЙ+НЕПРИЗЕМЛЁННЫЙ → отказ с путём, worktree
#      жив, маркера нет.
#
# Привязки обманных стабов к входам (Н-39 — живут ЗДЕСЬ, в коде батареи,
# не в прозе контракта; каждый стаб красен на входе, где его дефект
# НАБЛЮДАЕМ, и честен без ручки на том же входе):
#   s1 STUB_SKIP_HEAD     «не сверяет HEAD с origin/main» — красен на к2-входе
#        (локальный коммит впереди origin): маркер поставлен при расхождении.
#   s2 STUB_SKIP_PORCELAIN «не сверяет porcelain» — красен на к3-входе
#        (грязный рабочий файл): маркер поставлен на грязном дереве.
#   s3 STUB_SKIP_HANDOFF  «не сверяет автора HANDOFF-коммита» — красен на
#        к4-входе (последний коммит HANDOFF.md — автор chuzhoj): маркер
#        поставлен, финальный долг сессии не сверен.
#   s4 STUB_SKIP_DETECTOR «игнорирует rc детектора» — красен на к5-входе
#        (check_no_leak --check rc 1): маркер поставлен при утечке.
#   s5 STUB_SKIP_WORKTREE «не судит мусорные worktree» — красен на к6-входе
#        (грязный мусорный worktree): маркер поставлен, мусор не назван.
#   s6 STUB_EAGER_MARKER  «ставит маркер ДО проверок» — красен на к3-входе:
#        отказ правильный (rc 1, причина porcelain), НО МАРКЕР СТОИТ —
#        рестарт запущен бы при отказавшей двери (неатомарность порядка).
#   s7 STUB_NO_DELETE     «не удаляет чистые приземлённые» — красен на
#        к7-входе: rc 0 и маркер, НО мусорный worktree ВЫЖИЛ — расширение
#        gc не исполнено дверью.
#
# Демаркация контрпримеров (уроки 019): КОНФОРМНЫЕ входы по грамматике
# предмета — toy-репозиторий: ветка main, remote origin (локальный bare,
# origin/main существует), HANDOFF.md закоммичен, субъект (стаб или копия
# реальных скриптов) закоммичен и отправлен в origin, детекторный снимок
# ${TMPDIR}/dev-harness-leak сделан по канону check_no_leak; мусорный
# worktree = запись git worktree list НЕ основного чекаута с веткой вне
# refs/heads/wip/[0-9][0-9][0-9]/* (включая detached) либо с чужим
# состоянием (грязь/неприземлённость). Пути toy-миров СЛУЧАЙНЫ на каждый
# прогон (mktemp; инвариантность к путям/именам): стаб с зашитым литералом
# пути пройти клетку не может. Валидный контрпример = инвариантность к
# путям ∧ расхождение честного и стаба на КОНФОРМНОМ входе.
#
# ГИГИЕНА МАРКЕРА: батарея НИКОГДА не читает и не пишет живой путь
# /tmp/dev-harness-verify/orch-restart — все прогоны идут с
# ORCH_RESTART_MARKER=<toy-путь> (тест-шов предмета); ambient-значение
# снято до начала; живой orch-loop не потревожен.
#
# ПОРЯДОК СТРОИТЕЛЬСТВА КЛЕТКИ (атрибуция причин): toy-мир → установка
# субъекта (стаб/копия) → COMMIT+push субъекта (porcelain чист, HEAD==origin)
# → расстановка нарушения → детекторный снимок ПОСЛЕ расстановки (базлайн
# включает нарушение → детектор зелёный, отказ атрибутируется СВОЕЙ
# ветвью). Единственное исключение — к5: там нарушение и есть «строка
# ПОСЛЕ снимка», снимок делается до и эта клетка судит именно детектор.
#
# Прогон: bash red_dver_perezapuska_072.sh [корень worktree]
#   rc 0 — стаб-пак пойман (7/7) И диффпроба (7/7) И честная часть (8/8).
#   rc 1 — расхождение / предмет отсутствует (г0, ДО реализации).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT="${1:-$(cd "$HERE/../.." && pwd -P)}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
die_pack() { printf '072-батарея ОТКАЗ: %s\n' "$*" >&2; exit 1; }
command -v git >/dev/null 2>&1 || die_pack "нет git"

# Гигиена: ambient-шов снят; живой путь не читается и не пишется.
unset ORCH_RESTART_MARKER

STAB_SRC="$ROOT/scripts/check_no_leak.sh"
[ -f "$STAB_SRC" ] || die_pack "в дереве нет scripts/check_no_leak.sh — батарея строит toy-мир на нём"

# ── строители toy-мира ───────────────────────────────────────────────────────
# toy_make <dir>: репозиторий main + origin (локальный bare) + HANDOFF.md,
# автор toy-идентичности orchestrator; всё закоммичено и отправлено в origin.
toy_make() { # $1=toy-root
  local t="$1"
  mkdir -p "$t/scripts"
  cp "$STAB_SRC" "$t/scripts/check_no_leak.sh"
  git -C "$t" init -q -b main
  git -C "$t" config user.name orchestrator
  git -C "$t" config user.email orchestrator@dev-harness.local
  printf '## ГДЕ МЫ (toy)\n' > "$t/HANDOFF.md"
  # ignored-файл: porcelain его НЕ видит, UNTRACKED-нога детектора — видит
  # (ls-files --others без --exclude-standard, мимо ignore) — единственный
  # вход, разделяющий ветвь детектора от ветви porcelain.
  printf 'ignored-leak.txt\n' > "$t/.gitignore"
  git init -q --bare -b main "$t-origin.git"
  git -C "$t" remote add origin "$t-origin.git"
  git -C "$t" add -A
  git -C "$t" commit -qm 'toy: init'
  git -C "$t" push -q origin main
}

# СТАБ-ДВЕРЬ: полная обманная реализация предмета; ручки STUB_* выкрашивают
# ровно одну ветвь. Без ручек — честное поведение всех ветвей (диффпроба).
write_stub() { # $1=toy-root
  cat > "$1/scripts/orch_restart.sh" <<'STUB'
#!/usr/bin/env bash
# СТАБ-ДВЕРЬ (обманный предмет 072; ручки STUB_* — по одной на ветвь)
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
MARKER="${ORCH_RESTART_MARKER:-/tmp/dev-harness-verify/orch-restart}"
refuse() { printf 'ОТКАЗ: %s\n' "$1" >&2; exit 1; }
if [ "${STUB_EAGER_MARKER:-}" = 1 ]; then
  mkdir -p "$(dirname "$MARKER")"; touch "$MARKER"
fi
if [ "${STUB_SKIP_HEAD:-}" != 1 ]; then
  h="$(git -C "$ROOT" rev-parse HEAD 2>/dev/null)" || refuse 'NOT_IMPLEMENTED: нет HEAD'
  o="$(git -C "$ROOT" rev-parse origin/main 2>/dev/null)" || refuse 'NOT_IMPLEMENTED: нет origin/main'
  [ "$h" = "$o" ] || refuse 'HEAD расходится с origin/main'
fi
if [ "${STUB_SKIP_PORCELAIN:-}" != 1 ]; then
  [ -z "$(git -C "$ROOT" status --porcelain)" ] || refuse 'porcelain непуст'
fi
if [ "${STUB_SKIP_HANDOFF:-}" != 1 ]; then
  la="$(git -C "$ROOT" log -1 --format=%an -- HANDOFF.md 2>/dev/null)" \
    || refuse 'NOT_IMPLEMENTED: нет HANDOFF.md'
  me="$(git -C "$ROOT" config user.name)"
  { [ -n "$la" ] && [ "$la" = "$me" ]; } || refuse 'HANDOFF.md изменён не этой сессией'
fi
if [ "${STUB_SKIP_DETECTOR:-}" != 1 ]; then
  dout="$(bash "$ROOT/scripts/check_no_leak.sh" --check "$ROOT" 2>&1)"; drc=$?
  [ "$drc" -eq 0 ] || refuse "детектор красен: $dout"
fi
if [ "${STUB_SKIP_WORKTREE:-}" != 1 ]; then
  wt_list="$(git -C "$ROOT" worktree list --porcelain)"
  while IFS='|' read -r wt_path wt_head wt_branch; do
    [ -n "$wt_path" ] || continue
    [ "$wt_path" = "$ROOT" ] && continue
    case "$wt_branch" in
      refs/heads/wip/[0-9][0-9][0-9]/*) continue ;;
    esac
    landed=0
    git -C "$ROOT" merge-base --is-ancestor "$wt_head" HEAD 2>/dev/null && landed=1
    wt_dirty="$(git -C "$wt_path" status --porcelain 2>/dev/null)"
    if [ "$landed" -eq 1 ] && [ -z "$wt_dirty" ]; then
      if [ "${STUB_NO_DELETE:-}" = 1 ]; then
        printf 'СТАБ: мусорный worktree пропущен без удаления: %s\n' "$wt_path" >&2
      else
        git -C "$ROOT" worktree remove "$wt_path" \
          || refuse "не смог удалить мусорный worktree: $wt_path"
      fi
    else
      refuse "мусорный worktree: $wt_path"
    fi
  done < <(printf '%s\n' "$wt_list" | awk '
    /^worktree / { if (p != "") print p "|" h "|" b; p=substr($0,10); h=""; b="detached" }
    /^HEAD /     { h=substr($0,6) }
    /^branch /   { b=substr($0,8) }
    /^bare$/     { b="bare" }
    END { if (p != "") print p "|" h "|" b; }
  ')
fi
mkdir -p "$(dirname "$MARKER")"
touch "$MARKER"
printf 'ПЕРЕЗАПУСК: маркер поставлен\n'
exit 0
STUB
}

# subject_commit: закоммитить и отправить субъект клетки (porcelain чист,
# HEAD == origin/main ДО расстановки нарушения).
subject_commit() {
  git -C "$T" add scripts/
  git -C "$T" commit -qm 'toy: дверь'
  git -C "$T" push -q origin main
}

# honest_install: субъект честной части — копии реальных скриптов дерева.
honest_install() {
  [ -f "$ROOT/scripts/orch_restart.sh" ] || return 1
  cp "$ROOT/scripts/orch_restart.sh" "$T/scripts/orch_restart.sh"
  cp "$ROOT/scripts/gc_agent_branches.sh" "$T/scripts/gc_agent_branches.sh"
  return 0
}

# ── расстановка нарушений (после commit субъекта) ────────────────────────────
# Каждая violate_* ЗАКАНЧИВАЕТСЯ детекторным снимком по канону (базлайн
# включает нарушение); исключение violate_E — НАЧИНАЕТСЯ со снимка.
violate_A() { # всё зелёно + легальный wip-worktree жив
  git -C "$T" worktree add -q -b wip/072/architect "$T-wip" main
  bash "$T/scripts/check_no_leak.sh" --snapshot "$T" >/dev/null 2>&1
}
violate_B() { # HEAD впереди origin/main
  printf 'x\n' >> "$T/HANDOFF.md"
  git -C "$T" add HANDOFF.md && git -C "$T" commit -qm 'toy: вперёд origin'
  bash "$T/scripts/check_no_leak.sh" --snapshot "$T" >/dev/null 2>&1
}
violate_C() { # porcelain грязен (untracked)
  printf 'мусор\n' > "$T/leak.txt"
  bash "$T/scripts/check_no_leak.sh" --snapshot "$T" >/dev/null 2>&1
}
violate_D() { # HANDOFF.md последним коммитил чужой автор
  printf '## ГДЕ МЫ (toy, правка)\n' > "$T/HANDOFF.md"
  git -C "$T" add HANDOFF.md
  git -C "$T" -c user.name=chuzhoj -c user.email=chuzhoj@x commit -qm 'toy: чужой HANDOFF'
  git -C "$T" push -q origin main
  bash "$T/scripts/check_no_leak.sh" --snapshot "$T" >/dev/null 2>&1
}
violate_E() { # детектор красен: новый IGNORED-файл ПОСЛЕ снимка (porcelain
  # слеп к ignored, UNTRACKED-нога детектора видит мимо ignore — разделение
  # ветвей: отказ атрибутируется детектору, не porcelain)
  bash "$T/scripts/check_no_leak.sh" --snapshot "$T" >/dev/null 2>&1
  printf 'утечка\n' > "$T/ignored-leak.txt"
}
violate_F() { # мусорный worktree ГРЯЗНЫЙ → выживает, называется
  git -C "$T" worktree add -q -b garbage-dirty "$T-gwt" main
  printf 'грязь\n' > "$T-gwt/dirty.txt"
  bash "$T/scripts/check_no_leak.sh" --snapshot "$T" >/dev/null 2>&1
}
violate_G() { # мусорный worktree ЧИСТЫЙ+ПРИЗЕМЛЁННЫЙ (tip == main) → удалить
  git -C "$T" worktree add -q -b garbage-clean "$T-gwt" main
  bash "$T/scripts/check_no_leak.sh" --snapshot "$T" >/dev/null 2>&1
}
violate_H() { # мусорный worktree ЧИСТЫЙ+НЕПРИЗЕМЛЁННЫЙ → назвать
  git -C "$T" worktree add -q -b garbage-unlanded "$T-gwt" main
  git -C "$T-gwt" -c user.name=orchestrator -c user.email=orchestrator@dev-harness.local \
    commit -q --allow-empty -m 'toy: неприземлённый'
  bash "$T/scripts/check_no_leak.sh" --snapshot "$T" >/dev/null 2>&1
}

# run_subject <toy> <marker> [VAR=1 …]: прогон субъекта клетки.
run_subject() {
  local t="$1" m="$2"; shift 2
  rm -f "$m"
  mkdir -p "$(dirname "$m")"
  ( cd / && env ORCH_RESTART_MARKER="$m" "$@" bash "$t/scripts/orch_restart.sh" ) \
    > "$m.out" 2> "$m.err"
  S_RC=$?
}

# ── предикаты клеток: честное поведение, пиннутые маркеры ───────────────────
# Позиции: $1=имя $2=маркер $3=rc $4=stderr-файл $5=stdout-файл.
fail_cell() { printf 'клетка %s: %s\n' "$1" "$2" >&2; CELL_FAIL=1; }
p_A() { # rc 0, маркер стоит, stdout ПЕРЕЗАПУСК, легальный wip-worktree жив
  [ "$3" -eq 0 ] || { fail_cell "$1" "ожидался rc 0, получен $3: $(cat "$4")"; return 1; }
  [ -e "$2" ] || { fail_cell "$1" "маркер не поставлен"; return 1; }
  grep -Fq 'ПЕРЕЗАПУСК' "$5" || { fail_cell "$1" "нет строки ПЕРЕЗАПУСК в stdout"; return 1; }
  [ -d "$T-wip" ] || { fail_cell "$1" "легальный wip-worktree удалён"; return 1; }
  return 0
}
p_refuse() { # $6=подстрока причины; rc≠0, маркера нет, stderr несёт причину
  local sub="$6"
  [ "$3" -ne 0 ] || { fail_cell "$1" "ожидался отказ, получен rc 0"; return 1; }
  [ -e "$2" ] && { fail_cell "$1" "маркер стоит при отказе"; return 1; }
  grep -Fq "$sub" "$4" || { fail_cell "$1" "нет причины «$sub» в stderr: $(cat "$4")"; return 1; }
  return 0
}
p_B() { p_refuse "$1" "$2" "$3" "$4" "$5" 'HEAD расходится с origin/main'; }
p_C() { p_refuse "$1" "$2" "$3" "$4" "$5" 'porcelain непуст'; }
p_D() { p_refuse "$1" "$2" "$3" "$4" "$5" 'HANDOFF.md изменён не этой сессией'; }
p_E() { p_refuse "$1" "$2" "$3" "$4" "$5" 'детектор'; }
p_F() { # отказ «мусорный worktree» с путём, worktree жив
  p_refuse "$1" "$2" "$3" "$4" "$5" 'мусорный worktree' || return 1
  grep -Fq "$T-gwt" "$4" || { fail_cell "$1" "путь мусорного worktree не назван"; return 1; }
  [ -d "$T-gwt" ] || { fail_cell "$1" "грязный worktree удалён (запрещено)"; return 1; }
  return 0
}
p_G() { # rc 0, маркер, мусорный worktree УДАЛЁН расширением gc
  [ "$3" -eq 0 ] || { fail_cell "$1" "ожидался rc 0, получен $3: $(cat "$4")"; return 1; }
  [ -e "$2" ] || { fail_cell "$1" "маркер не поставлен"; return 1; }
  [ -d "$T-gwt" ] && { fail_cell "$1" "чистый приземлённый worktree не удалён"; return 1; }
  return 0
}
p_H() { # отказ с путём, worktree жив
  p_refuse "$1" "$2" "$3" "$4" "$5" 'мусорный worktree' || return 1
  grep -Fq "$T-gwt" "$4" || { fail_cell "$1" "путь мусорного worktree не назван"; return 1; }
  [ -d "$T-gwt" ] || { fail_cell "$1" "неприземлённый worktree удалён (запрещено)"; return 1; }
  return 0
}

# build_cell <toy> <нарушение> <установка-субъекта>
build_cell() {
  local t="$1" v="$2" inst="$3"
  rm -rf "$t" "$t-origin.git" "$t-wip" "$t-gwt"
  toy_make "$t"
  "$inst"
  subject_commit
  "$v"
}

# ── СТАБ-ПАК: 7 стабов × (ручка=дефект ловится, ручки нет — диффпроба) ──────
stab_caught=0; diff_green=0
run_cell_pair() { # $1=метка $2=нарушение $3=предикат $4=ручка
  local tag="$1" v="$2" pred="$3" knob="$4"
  local M="$WORK/m-$tag"
  # проход с ручкой: дефект ОБЯЗАН быть пойман (предикат честного поведения падает)
  T="$WORK/t-$tag-on"
  build_cell "$T" "$v" write_stub_alias
  run_subject "$T" "$M-on" "STUB_$knob=1"
  CELL_FAIL=0
  "$pred" "$tag(ручка)" "$M-on" "$S_RC" "$M-on.err" "$M-on.out"
  if [ "$CELL_FAIL" -ne 0 ]; then stab_caught=$((stab_caught+1)); else
    printf 'стаб-пак ОТКАЗ: стаб %s с ручкой ПРОШЁЛ клетку (%s)\n' "$knob" "$tag" >&2
    exit 1
  fi
  # диффпроба: та же клетка БЕЗ ручки — честное поведение держится
  T="$WORK/t-$tag-off"
  build_cell "$T" "$v" write_stub_alias
  run_subject "$T" "$M-off"
  CELL_FAIL=0
  "$pred" "$tag(дифф)" "$M-off" "$S_RC" "$M-off.err" "$M-off.out"
  if [ "$CELL_FAIL" -eq 0 ]; then diff_green=$((diff_green+1)); else
    printf 'стаб-пак ОТКАЗ: диффпроба %s упала без ручки\n' "$tag" >&2
    exit 1
  fi
}
write_stub_alias() { write_stub "$T"; }

run_cell_pair s1 violate_B p_B SKIP_HEAD
run_cell_pair s2 violate_C p_C SKIP_PORCELAIN
run_cell_pair s3 violate_D p_D SKIP_HANDOFF
run_cell_pair s4 violate_E p_E SKIP_DETECTOR
run_cell_pair s5 violate_F p_F SKIP_WORKTREE
run_cell_pair s6 violate_C p_C EAGER_MARKER
run_cell_pair s7 violate_G p_G NO_DELETE
printf 'стаб-пак: %d/7 поймано, диффпроба %d/7\n' "$stab_caught" "$diff_green"
[ "$stab_caught" -eq 7 ] && [ "$diff_green" -eq 7 ] \
  || die_pack "счёт стаб-пака не сошёлся (поймано $stab_caught, дифф $diff_green)"

# ── г0: носитель предмета ───────────────────────────────────────────────────
if [ ! -f "$ROOT/scripts/orch_restart.sh" ]; then
  printf 'ОТКАЗ: предмет отсутствует — в дереве нет scripts/orch_restart.sh\n' >&2
  exit 1
fi

# ── ЧЕСТНАЯ ЧАСТЬ: к1..к8 против реальных скриптов дерева ───────────────────
honest_green=0; honest_total=0
run_honest() { # $1=метка $2=нарушение $3=предикат
  local tag="$1" v="$2" pred="$3"
  honest_total=$((honest_total+1))
  local M="$WORK/h-$tag"
  T="$WORK/ht-$tag"
  build_cell "$T" "$v" honest_install
  run_subject "$T" "$M"
  CELL_FAIL=0
  "$pred" "$tag" "$M" "$S_RC" "$M.err" "$M.out"
  if [ "$CELL_FAIL" -eq 0 ]; then honest_green=$((honest_green+1)); fi
}
run_honest к1 violate_A p_A
run_honest к2 violate_B p_B
run_honest к3 violate_C p_C
run_honest к4 violate_D p_D
run_honest к5 violate_E p_E
run_honest к6 violate_F p_F
run_honest к7 violate_G p_G
run_honest к8 violate_H p_H
printf 'честная часть: %d/%d зелёная\n' "$honest_green" "$honest_total"
[ "$honest_green" -eq "$honest_total" ] \
  || die_pack "честная часть красна ($honest_green/$honest_total)"
printf 'итог 072-батареи: предъявлений стабы 7/7 + дифф 7/7 + честные 8/8\n'
exit 0
