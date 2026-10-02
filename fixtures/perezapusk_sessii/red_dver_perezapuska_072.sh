#!/usr/bin/env bash
# 072-БАТАРЕЯ — «дверь перезапуска сессии»: scripts/orch_restart.sh —
# ЕДИНСТВЕННЫЙ способ поставить маркер /tmp/dev-harness-verify/orch-restart
# (слово владельца 2026-10-01, дословно в HANDOFF «ГДЕ МЫ»: гейт
# HEAD == origin/main; porcelain пусто; HANDOFF.md изменён коммитом
# ЭТОЙ сессии; check_no_leak rc 0; нет мусорных worktree → иначе именованный
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
# Структура (v2, правка по вердикту критика к1: Б2 стартовый след, Б3 суд
# самого GC + инструментированное делегирование):
#   1. СТАБ-ПАК (16 обманных стабов двери, ручки STUB_*) — зелёный ДО и
#      ПОСЛЕ реализации: каждый стаб умирает на СВОЕЙ клетке; диффпроба —
#      те же стабы БЕЗ ручек проходят те же клетки (ловля предикатом,
#      не случаем).
#   2. г1 «суд самого GC» — ПРЯМОЙ прогон scripts/gc_agent_branches.sh на
#      конформном мире: чистый приземлённый мусорный worktree удаляется
#      САМИМ GC, грязный жив и назван (rc 1 — неудаляемый мусор), неслитый
#      wip жив; г2 — зелёная ветвь того же суда (без неудаляемого мусора:
#      rc 0, чистый приземлённый удалён). Исполняются ДО г0 и КРАСНЫ на
#      нынешнем дереве (расширения ещё нет) — красное предъявление
#      расширения GC как такового (Б3), не только конечного эффекта двери.
#   3. г0 «предмет отсутствует» — fail-fast по НОСИТЕЛЮ: в дереве нет
#      scripts/orch_restart.sh → клетки двери не исполняются, rc 1
#      (ДО-мера пачки: grep -rc orch_restart scripts/ roles/ = 0).
#   4. ЧЕСТНАЯ ЧАСТЬ ДВЕРИ (клетки к1..к18) — зелёная ПОСЛЕ реализации:
#      к1 всё зелёно (неслитый легальный wip-worktree ВЫЖИВАЕТ) → rc 0,
#      маркер, след перезаписан;
#      к2 HEAD впереди origin → отказ «HEAD», маркера нет;
#      к3 porcelain грязен → отказ, маркера нет;
#      к4 HANDOFF.md последним коммитил ЧУЖОЙ автор → отказ (в1), маркера нет;
#      к5 детектор красен (новый untracked после снимка) → отказ, маркера нет;
#      к6 мусорный worktree ГРЯЗНЫЙ → отказ с путём, worktree жив, маркера нет;
#      к7 мусорный worktree ЧИСТЫЙ+ПРИЗЕМЛЁННЫЙ → удалён РАСШИРЕНИЕМ GC
#      (вызов GC зафиксирован внешним логом обёртки-регистратора), rc 0,
#      маркер;
#      к8 мусорный worktree ЧИСТЫЙ+НЕПРИЗЕМЛЁННЫЙ → отказ с путём, worktree
#      жив, маркера нет;
#      к9 ОБХОД Б2: HANDOFF-коммит той же identity, но СТАРЕЕ стартового
#      следа (след новее — «сессия S2 с тем же user.name») → отказ «до
#      стартового следа», маркера нет;
#      к10 первое использование: следа НЕТ → дверь инициализирует след и
#      отказывает по (в2) — инициализация НЕ вакуумна, файл следа создан.
#      к11 клетка ПЕРЕХОДА (арбитраж 072-Б2): S1 зелёная дверь (rc 0,
#      маркер, след := момент завершения) → маркер снят батареей, HANDOFF
#      не менялся → S2 rc 1 «HANDOFF.md изменён до стартового следа
#      сессии», маркера нет → новый HANDOFF-коммит той же identity
#      (sleep 1) → S3 rc 0, маркер.
#      к12 (адверсарий 072-r1, блокер 2): стартовый след МНОГОСТРОЧНЫЙ
#      (мусор\n<валидная ISO>) → отказ fail-closed «не ровно одна
#      строка», маркера нет, след НЕ перезаписан (инвариант 11 требует
#      ровно одну непустую строку, не `tail -n 1` поверх мусора).
#      к13 (ревьюер 072-r1, Б1-П1): родитель МАРКЕРА — обычный файл →
#      отказ записи fail-closed: rc≠0, «ПЕРЕЗАПУСК» НЕ печатается, маркера
#      нет (инварианты 7/8);
#      к14 (Б1-П2): каталог СЛЕДА только для чтения на зелёном завершении
#      → rc≠0 (след не перезаписан — не «успех», инвариант 11), след
#      нетронут; сама к14 маркер НЕ пинит (обе формы двери r2/r3 проходят
#      одним предикатом), фразы инв. 3 пиннуты клетками-парой к17/к18 —
#      «выбор реализации» снят r3 как противоречащий инв. 3 (Б4);
#      к15 (Б1, порядок): инвариант 11 «след СРАЗУ после маркера» — при
#      невозможной записи МАРКЕРА след обязан остаться НЕТРОНУТЫМ (обратный
#      порядок двинул бы границу сессии без маркера);
#      к16 (Б1-П2б, клетка ПЕРЕХОДА): мир П2 → S1 отказ → S2а повтор БЕЗ
#      нового HANDOFF-коммита, ЧУЖОЙ стоящий маркер ПОСТАВЛЕН батареей
#      (r3: честная дверь откатывает СВОЙ маркер при отказе следа — S1
#      его не оставляет; стоящий маркер в мир ставит батарея, как сторож
#      orch-peak) → отказ → S2б маркер снят батареей (форма пробы
#      ревьюера) → отказ: обход арбитража 072-Б2 («та же identity, чужая
#      сессия») не открывается вновь при отказавшей записи следа.
#      к17 (ревьюер 072-r2, Б4): мир к14 (каталог следа RO, маркера до
#      прогона НЕ было) → отказ записи следа + маркер ОТСУТСТВУЕТ (инв. 3
#      фраза 1: при любом отказе маркер не создаётся; orch-loop взводит
#      рестарт по стоящему маркеру — «ОТКАЗ» с маркером обходит гейт).
#      Честная клетка ловит мутант (в) «снят откат» в самой двери, s15 —
#      ту же ветвь стабом.
#      к18 (ревьюер 072-r2, Б5-зеркало): чужой маркер
#      стоит ДО прогона + каталог следа RO → отказ записи следа + ЧУЖОЙ
#      маркер СТОИТ (инв. 3 фраза 2: уже стоящий дверь не удаляет).
#      Честная клетка ловит откат f718434 (дверь r2) в самой двери,
#      s16 — ту же ветвь стабом.
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
#   s7 STUB_NO_DELETE     «не удаляет чистые приземлённые» (ручка съедена
#        стаб-GC) — красен на к7-входе: rc 0 и маркер, НО мусорный worktree
#        ВЫЖИЛ — расширение gc не исполнено.
#   s8 STUB_SKIP_TRACE    «не сверяет дату HANDOFF-коммита со стартовым
#        следом» — красен на к9-входе (след новее коммита, identity та же):
#        маркер поставлен — обход «та же identity, чужая сессия» открыт (Б2).
#   s9 STUB_INLINE_DELETE «удаляет мусорный worktree сама, мимо GC» —
#        красен на к7-входе с обёрткой-регистратором: каталог удалён, НО
#        вызов GC не зафиксирован — расширение GC обойдено дверью (Б3).
#   s10 STUB_TRACE_MOMENT «пишет след = ct(HANDOFF)−1 вместо момента
#        завершения» (выходная сторона, мутант критика к2) — красен на
#        к11-входе, стадия S2: повторный вход без нового HANDOFF-коммита
#        даёт rc 0 и маркер — обход повторного входа открыт (Б2).
#   s11 STUB_MARKER_UNCHECKED «не проверяет запись маркера» — красен на
#        к13-входе (родитель маркера — обычный файл): rc 0 «ПЕРЕЗАПУСК»
#        без маркера — дефект живой двери (Б1-П1).
#   s12 STUB_TRACE_UNCHECKED «не проверяет запись следа» — красен на
#        к14-входе (каталог следа только для чтения): rc 0 «ПЕРЕЗАПУСК»,
#        след не перезаписан (Б1-П2).
#   s13 STUB_TRACE_FIRST «пишет след ДО маркера» — красен на к15-входе
#        (маркер незаписываем, след записываем): отказ корректен, НО след
#        перезаписан — порядок обратен инварианту 11 (Б1).
#   s14 STUB_RETRY_GREEN «стоящий маркер — след не нужен, успех» — красен
#        на к16-входе, стадия S2а: rc 0 «ПЕРЕЗАПУСК» при отказавшей записи
#        следа — обход 072-Б2 открыт вновь (Б1-П2б).
#   s15 STUB_KEEP_MARKER «не откатывает СВОЙ маркер при отказе записи
#        следа» — красен на к17-входе (каталог следа RO, маркера до
#        прогона не было): rc 1 «ОТКАЗ», но маркер СТОИТ — рестарт взведён
#        при отказавшей двери (мутант (в) ревьюера 072-r2; инв. 3 фраза 1).
#   s16 STUB_RM_STANDING «безусловный rm -f маркера при отказе записи
#        следа (форма живой двери r2)» — красен на к18-входе (чужой маркер
#        стоит ДО прогона, каталог следа RO): rc 1 «ОТКАЗ», но ЧУЖОЙ
#        маркер СНЯТ — отложенный сторожем (orch-peak) перезапуск снят
#        молча (ревьюер 072-r2 Б5; инв. 3 фраза 2).
#
# ИНСТРУМЕНТИРОВАНИЕ ДЕЛЕГИРОВАНИЯ: в мирах батареи scripts/gc_agent_branches.sh
# — ОБЁРТКА-РЕГИСТРАТОР: пишет строку «GC-CALLED <argv>» во ВНЕШНИЙ лог
# (путь знает только батарея, субъекту не передаётся) и exec-ит носитель
# gc_real.sh (стаб-GC в мирах стабов; копия настоящего GC в честных мирах).
# Оракул вызова — память батареи, не диск проверяемого (правило 8).
#
# Демаркация контрпримеров (уроки 019): КОНФОРМНЫЕ входы по грамматике
# предмета — toy-репозиторий: ветка main, remote origin (локальный bare,
# origin/main существует), HANDOFF.md закоммичен, субъект (стаб или копия
# реальных скриптов) закоммичен и отправлен в origin, детекторный снимок
# ${TMPDIR}/dev-harness-leak сделан по канону check_no_leak, стартовый
# след — одна ISO-8601 строка (прошлое для зелёных клеток, будущее для
# к9, отсутствие для к10); мусорный worktree = запись git worktree list НЕ
# основного чекаута с веткой вне refs/heads/wip/[0-9][0-9][0-9]/*
# (включая detached); легальный wip в клетках НЕСЛИТ (tip недостижим из
# HEAD) — этого требует сам GC (слитые wip он сносит по 016). Пути toy-миров
# СЛУЧАЙНЫ на каждый прогон (mktemp; инвариантность к путям/именам): стаб
# с зашитым литералом пути пройти клетку не может. Валидный контрпример =
# инвариантность к путям ∧ расхождение честного и стаба на КОНФОРМНОМ входе.
#
# ГИГИЕНА МАРКЕРА И СЛЕДА: батарея НИКОГДА не читает и не пишет живые пути
# /tmp/dev-harness-verify/orch-restart и
# /tmp/dev-harness-verify/orch-session-start — все прогоны идут с
# ORCH_RESTART_MARKER=<toy-путь> ORCH_SESSION_START=<toy-путь> (тест-швы
# предмета); ambient-значения сняты до начала; живой orch-loop не потревожен.
#
# ПОРЯДОК СТРОИТЕЛЬСТВА КЛЕТКИ (атрибуция причин): toy-мир → установка
# субъекта (стаб/копия + обёртка-регистратор GC) → COMMIT+push субъекта
# (porcelain чист, HEAD==origin) → расстановка нарушения (нарушение +
# стартовый след: прошлое/будущее/отсутствие) → детекторный снимок ПОСЛЕ
# расстановки (базлайн включает нарушение → детектор зелёный, отказ
# атрибутируется СВОЕЙ ветвью). Единственное исключение — к5: там нарушение
# и есть «строка ПОСЛЕ снимка», снимок делается до и эта клетка судит
# именно детектор.
#
# Прогон: bash red_dver_perezapuska_072.sh [корень worktree]
#   rc 0 — стаб-пак пойман (16/16) И диффпроба (16/16) И честная часть (20/20).
#   rc 1 — расхождение / предмет отсутствует (г0, ДО реализации двери).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT="${1:-$(cd "$HERE/../.." && pwd -P)}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
die_pack() { printf '072-батарея ОТКАЗ: %s\n' "$*" >&2; exit 1; }
command -v git >/dev/null 2>&1 || die_pack "нет git"

# Гигиена: ambient-швы сняты; живые пути не читаются и не пишутся.
unset ORCH_RESTART_MARKER ORCH_SESSION_START

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
# Делегирование: честный путь запускает обёртку-регистратор GC своего
# корня (та же команда, что предписана настоящей двери), ручка
# STUB_INLINE_DELETE удаляет сама, мимо GC.
write_stub() { # $1=toy-root
  cat > "$1/scripts/orch_restart.sh" <<'STUB'
#!/usr/bin/env bash
# СТАБ-ДВЕРЬ (обманный предмет 072; ручки STUB_* — по одной на ветвь)
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
MARKER="${ORCH_RESTART_MARKER:-/tmp/dev-harness-verify/orch-restart}"
TRACE="${ORCH_SESSION_START:-/tmp/dev-harness-verify/orch-session-start}"
refuse() { printf 'ОТКАЗ: %s\n' "$1" >&2; exit 1; }
trace_write() { # атомарная замена одной ISO-строкой
  mkdir -p "$(dirname "$TRACE")"
  if [ "${STUB_TRACE_MOMENT:-}" = 1 ]; then
    # ОБМАНА выходной стороны (критик к2, арбитраж 072-Б2): след :=
    # ct(HANDOFF)−1с вместо момента завершения — повторный вход без
    # нового HANDOFF-коммита проходит ногу (в2), обход открыт.
    local m_ep
    m_ep="$(git -C "$ROOT" log -1 --format=%ct -- HANDOFF.md 2>/dev/null)" \
      || m_ep="$(date +%s)"
    printf '%s\n' "$(date -Is -d "@$((m_ep-1))")" > "$TRACE.tmp.$$" \
      && mv -f "$TRACE.tmp.$$" "$TRACE"
    return
  fi
  printf '%s\n' "$(date -Is)" > "$TRACE.tmp.$$" && mv -f "$TRACE.tmp.$$" "$TRACE"
}
wt_pairs() { git -C "$ROOT" worktree list --porcelain | awk '
  /^worktree / { if (p != "") print p "|" h "|" b; p=substr($0,10); h=""; b="detached" }
  /^HEAD /     { h=substr($0,6) }
  /^branch /   { b=substr($0,8) }
  /^bare$/     { b="bare" }
  END { if (p != "") print p "|" h "|" b; }
'; }
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
  if [ "${STUB_SKIP_TRACE:-}" != 1 ]; then
    [ -f "$TRACE" ] || trace_write
    t_line="$(tail -n 1 "$TRACE" 2>/dev/null)" || refuse 'NOT_IMPLEMENTED: стартовый след нечитаем'
    [ -n "$t_line" ] || refuse 'NOT_IMPLEMENTED: стартовый след нечитаем'
    t_ep="$(date -d "$t_line" +%s 2>/dev/null)" || refuse 'NOT_IMPLEMENTED: стартовый след нечитаем'
    c_ep="$(git -C "$ROOT" log -1 --format=%ct -- HANDOFF.md 2>/dev/null)" \
      || refuse 'NOT_IMPLEMENTED: нет HANDOFF.md'
    [ "$c_ep" -gt "$t_ep" ] || refuse 'HANDOFF.md изменён до стартового следа сессии'
  fi
fi
if [ "${STUB_SKIP_DETECTOR:-}" != 1 ]; then
  dout="$(bash "$ROOT/scripts/check_no_leak.sh" --check "$ROOT" 2>&1)"; drc=$?
  [ "$drc" -eq 0 ] || refuse "детектор красен: $dout"
fi
if [ "${STUB_SKIP_WORKTREE:-}" != 1 ]; then
  if [ "${STUB_INLINE_DELETE:-}" = 1 ]; then
    # ОБМАН (Б3): дверь удаляет мусор сама, минуя GC
    while IFS='|' read -r wt_path wt_head wt_branch; do
      [ -n "$wt_path" ] || continue
      [ "$wt_path" = "$ROOT" ] && continue
      case "$wt_branch" in refs/heads/wip/[0-9][0-9][0-9]/*) continue ;; esac
      landed=0
      git -C "$ROOT" merge-base --is-ancestor "$wt_head" HEAD 2>/dev/null && landed=1
      wt_dirty="$(git -C "$wt_path" status --porcelain 2>/dev/null)"
      if [ "$landed" -eq 1 ] && [ -z "$wt_dirty" ]; then
        git -C "$ROOT" worktree remove "$wt_path" \
          || refuse "не смог удалить мусорный worktree: $wt_path"
      else
        refuse "мусорный worktree: $wt_path"
      fi
    done < <(wt_pairs)
  else
    # честный путь стаба: делегирование GC обёрткой-регистратором + переснятие
    bash "$ROOT/scripts/gc_agent_branches.sh" --root "$ROOT" >/dev/null 2>&1 || true
    while IFS='|' read -r wt_path wt_head wt_branch; do
      [ -n "$wt_path" ] || continue
      [ "$wt_path" = "$ROOT" ] && continue
      case "$wt_branch" in refs/heads/wip/[0-9][0-9][0-9]/*) continue ;; esac
      refuse "мусорный worktree: $wt_path"
    done < <(wt_pairs)
  fi
fi
# ── выход предмета — семантика ПОСЛЕ фикса Б1 (ревьюер 072-r1): МАРКЕР
# пишется ПЕРВЫМ, запись ПРОВЕРЯЕТСЯ; след — СРАЗУ ПОСЛЕ маркера, запись
# тоже проверяется; отказ любой записи → rc 1 БЕЗ «ПЕРЕЗАПУСК» (инв. 7/8/11).
marker_write() {
  mkdir -p "$(dirname "$MARKER")" 2>/dev/null || return 1
  : > "$MARKER.tmp.$$" 2>/dev/null || return 1
  mv -f "$MARKER.tmp.$$" "$MARKER" 2>/dev/null || return 1
  return 0
}
finish_ok() { printf 'ПЕРЕЗАПУСК: маркер поставлен\n'; exit 0; }
if [ "${STUB_RETRY_GREEN:-}" = 1 ] && [ -e "$MARKER" ]; then
  # ОБМАН (П2б, обход 072-Б2): повторный вход при стоящем маркере —
  # «след уже не нужен»: успех без записи следа.
  finish_ok
fi
if [ "${STUB_TRACE_FIRST:-}" = 1 ]; then
  # ОБМАН порядка (инвариант 11, Б1): след ДО маркера — при отказе записи
  # маркера граница сессии уже двинута.
  trace_write || { [ "${STUB_TRACE_UNCHECKED:-}" = 1 ] || refuse 'запись следа не удалась'; }
  marker_write || { [ "${STUB_MARKER_UNCHECKED:-}" = 1 ] || refuse 'запись маркера не удалась'; }
  finish_ok
fi
# инв. 3 на пути отказа следа (ревьюер 072-r2 Б4/Б5): откатывается ТОЛЬКО
# маркер этого прогона (не стоял до постановки — stood); чужой стоящий
# маркер дверь не удаляет — не её состояние.
stood=0; [ -e "$MARKER" ] && stood=1
marker_write || { [ "${STUB_MARKER_UNCHECKED:-}" = 1 ] || refuse 'запись маркера не удалась'; }
trace_write || {
  if [ "${STUB_TRACE_UNCHECKED:-}" != 1 ]; then
    if [ "${STUB_RM_STANDING:-}" = 1 ]; then
      # ОБМАН (Б5): безусловный rm -f — сносит и ЧУЖОЙ стоящий маркер
      # (форма живой двери r2: отложенный сторожем перезапуск снят молча).
      rm -f "$MARKER" 2>/dev/null || true
    elif [ "${STUB_KEEP_MARKER:-}" != 1 ] && [ "$stood" -eq 0 ]; then
      # честный откат: ТОЛЬКО маркер этого прогона (инв. 3, обе фразы)
      rm -f "$MARKER" 2>/dev/null || true
    fi
    refuse 'запись следа не удалась'
  fi
}
finish_ok
STUB
}

# СТАБ-GC: обманное «расширение GC» для миров стабов — только ветвь мусорных
# worktree; реестр wip не трогает. Ручка STUB_NO_DELETE выкрашивает удаление.
write_gc_stub() { # $1=toy-root
  cat > "$1/scripts/gc_real.sh" <<'GSTUB'
#!/usr/bin/env bash
# СТАБ-GC (обманное расширение GC; ручка STUB_NO_DELETE)
set -uo pipefail
ROOT=""; while [ $# -gt 0 ]; do case "$1" in --root) ROOT="$2"; shift 2 ;; *) shift ;; esac; done
ROOT="${ROOT:?СТАБ-GC: нет --root}"
fail=0
while IFS='|' read -r wt_path wt_head wt_branch; do
  [ -n "$wt_path" ] || continue
  [ "$wt_path" = "$ROOT" ] && continue
  case "$wt_branch" in refs/heads/wip/[0-9][0-9][0-9]/*) continue ;; esac
  landed=0
  git -C "$ROOT" merge-base --is-ancestor "$wt_head" HEAD 2>/dev/null && landed=1
  wt_dirty="$(git -C "$wt_path" status --porcelain 2>/dev/null)"
  if [ "$landed" -eq 1 ] && [ -z "$wt_dirty" ]; then
    if [ "${STUB_NO_DELETE:-}" = 1 ]; then
      printf 'СТАБ-GC: пропуск удаления: %s\n' "$wt_path" >&2
    else
      git -C "$ROOT" worktree remove "$wt_path" || fail=1
    fi
  else
    printf 'мусорный worktree: %s\n' "$wt_path" >&2
    fail=1
  fi
done < <(git -C "$ROOT" worktree list --porcelain | awk '
  /^worktree / { if (p != "") print p "|" h "|" b; p=substr($0,10); h=""; b="detached" }
  /^HEAD /     { h=substr($0,6) }
  /^branch /   { b=substr($0,8) }
  /^bare$/     { b="bare" }
  END { if (p != "") print p "|" h "|" b; }
')
exit "$fail"
GSTUB
}

# ОБЁРТКА-РЕГИСТРАТОР GC: фиксирует вызов внешним логом (оракул батареи,
# субъекту путь не передаётся), затем exec-ит носитель gc_real.sh.
write_gc_shim() { # $1=toy-root $2=абс-путь лога вызовов
  cat > "$1/scripts/gc_agent_branches.sh" <<SHIM
#!/usr/bin/env bash
printf '%s\n' "GC-CALLED \$*" >> '$2'
exec bash "\$(dirname "\$0")/gc_real.sh" "\$@"
SHIM
}

# stub_install: субъект-стаб + стаб-GC + обёртка-регистратор.
stub_install() { # глобали T/TRACE/GCLOG уже выставлены (прецедент write_stub_alias v1)
  write_stub "$T"
  write_gc_stub "$T"
  write_gc_shim "$T" "$GCLOG"
}

# gc_only_install: носитель gc_real.sh — копия НАСТОЯЩЕГО GC дерева.
gc_only_install() {
  [ -f "$ROOT/scripts/gc_agent_branches.sh" ] || return 1
  cp "$ROOT/scripts/gc_agent_branches.sh" "$T/scripts/gc_real.sh"
  write_gc_shim "$T" "$GCLOG"
  return 0
}

# honest_install: субъект честной части — копии реальных скриптов дерева.
honest_install() {
  [ -f "$ROOT/scripts/orch_restart.sh" ] || return 1
  cp "$ROOT/scripts/orch_restart.sh" "$T/scripts/orch_restart.sh"
  gc_only_install || return 1
  return 0
}

# subject_commit: закоммитить и отправить субъект клетки (porcelain чист,
# HEAD == origin/main ДО расстановки нарушения).
subject_commit() {
  git -C "$T" add scripts/
  git -C "$T" commit -qm 'toy: дверь'
  git -C "$T" push -q origin main
}

# ── стартовый след: прошлое / будущее / отсутствие ───────────────────────────
trace_past()   { printf '%s\n' "$(date -Is -d '1 hour ago')" > "$TRACE"; }
trace_future() { printf '%s\n' "$(date -Is -d '+1 hour')" > "$TRACE"; }
trace_absent() { rm -f "$TRACE"; }

# ── расстановка нарушений (после commit субъекта) ────────────────────────────
# Каждая violate_* ЗАКАНЧИВАЕТСЯ стартовым следом (кроме к9/к10 — их след и
# есть нарушение) и детекторным снимком по канону (базлайн включает
# нарушение); исключение violate_E — снимок ДО игнор-файла; violate_GC —
# мир прямого суда GC (дверь не зовётся, снимок/след не нужны).
violate_A() { # всё зелёно + НЕСЛИТЫЙ легальный wip-worktree жив
  git -C "$T" worktree add -q -b wip/072/architect "$T-wip" main
  git -C "$T-wip" -c user.name=orchestrator -c user.email=orchestrator@dev-harness.local \
    commit -q --allow-empty -m 'toy: живой неслитый wip'
  trace_past
  bash "$T/scripts/check_no_leak.sh" --snapshot "$T" >/dev/null 2>&1
}
violate_B() { # HEAD впереди origin/main
  printf 'x\n' >> "$T/HANDOFF.md"
  git -C "$T" add HANDOFF.md && git -C "$T" commit -qm 'toy: вперёд origin'
  trace_past
  bash "$T/scripts/check_no_leak.sh" --snapshot "$T" >/dev/null 2>&1
}
violate_C() { # porcelain грязен (untracked)
  printf 'мусор\n' > "$T/leak.txt"
  trace_past
  bash "$T/scripts/check_no_leak.sh" --snapshot "$T" >/dev/null 2>&1
}
violate_D() { # HANDOFF.md последним коммитил чужой автор
  printf '## ГДЕ МЫ (toy, правка)\n' > "$T/HANDOFF.md"
  git -C "$T" add HANDOFF.md
  git -C "$T" -c user.name=chuzhoj -c user.email=chuzhoj@x commit -qm 'toy: чужой HANDOFF'
  git -C "$T" push -q origin main
  trace_past
  bash "$T/scripts/check_no_leak.sh" --snapshot "$T" >/dev/null 2>&1
}
violate_E() { # детектор красен: новый IGNORED-файл ПОСЛЕ снимка (porcelain
  # слеп к ignored, UNTRACKED-нога детектора видит мимо ignore — разделение
  # ветвей: отказ атрибутируется детектору, не porcelain)
  trace_past
  bash "$T/scripts/check_no_leak.sh" --snapshot "$T" >/dev/null 2>&1
  printf 'утечка\n' > "$T/ignored-leak.txt"
}
violate_F() { # мусорный worktree ГРЯЗНЫЙ → выживает, называется
  git -C "$T" worktree add -q -b garbage-dirty "$T-gwt" main
  printf 'грязь\n' > "$T-gwt/dirty.txt"
  trace_past
  bash "$T/scripts/check_no_leak.sh" --snapshot "$T" >/dev/null 2>&1
}
violate_G() { # мусорный worktree ЧИСТЫЙ+ПРИЗЕМЛЁННЫЙ (tip == main) → удалить
  git -C "$T" worktree add -q -b garbage-clean "$T-gwt" main
  trace_past
  bash "$T/scripts/check_no_leak.sh" --snapshot "$T" >/dev/null 2>&1
}
violate_H() { # мусорный worktree ЧИСТЫЙ+НЕПРИЗЕМЛЁННЫЙ → назвать
  git -C "$T" worktree add -q -b garbage-unlanded "$T-gwt" main
  git -C "$T-gwt" -c user.name=orchestrator -c user.email=orchestrator@dev-harness.local \
    commit -q --allow-empty -m 'toy: неприземлённый'
  trace_past
  bash "$T/scripts/check_no_leak.sh" --snapshot "$T" >/dev/null 2>&1
}
violate_I() { # к9, ОБХОД Б2: след НОВЕЕ HANDOFF-коммита той же identity
  # (последний HANDOFF-коммит — orchestrator, совершён ДО границы сессии)
  trace_future
  bash "$T/scripts/check_no_leak.sh" --snapshot "$T" >/dev/null 2>&1
}
violate_J() { # к10, первое использование: следа НЕТ (инициализация не вакуумна)
  trace_absent
  bash "$T/scripts/check_no_leak.sh" --snapshot "$T" >/dev/null 2>&1
}
violate_K() { # к11, клетка ПЕРЕХОДА (арбитраж 072-Б2): ЗЕЛЁНЫЙ мир — та
  # же расстановка, что violate_A (живой неслитый wip, след в прошлом,
  # снимок); «нарушение» порождается САМОЙ последовательностью прогонов:
  # повторный вход без нового HANDOFF-коммита обязан отказывать ногой (в2)
  violate_A
}
violate_L() { # к12 (адверсарий 072-r1, блокер 2): стартовый след —
  # МНОГОСТРОЧНЫЙ (мусорная первая строка + валидная ISO вторая строка).
  # Инвариант 11 требует РОВНО одну непустую строку — лишняя строка перед
  # валидным хвостом не имеет права судиться как «ISO в прошлом» через
  # `tail -n 1`. Мир иначе зелёный (как violate_A, БЕЗ неслитого wip).
  printf 'не ISO-8601\n%s\n' "$(date -Is -d '1 hour ago')" > "$TRACE"
  bash "$T/scripts/check_no_leak.sh" --snapshot "$T" >/dev/null 2>&1
}
violate_M() { # к13(П1)/к15(порядок) — ревьюер 072-r1 Б1: родитель МАРКЕРА —
  # ОБЫЧНЫЙ ФАЙЛ (путь MARKER_DIR выставлен клеткой ДО build_cell): запись
  # маркера невозможна; мир иначе зелёный, след — прошлое.
  mkdir -p "$(dirname "$TRACE")"
  trace_past
  bash "$T/scripts/check_no_leak.sh" --snapshot "$T" >/dev/null 2>&1
  rm -rf "$MARKER_DIR"
  printf 'родитель маркера — обычный файл\n' > "$MARKER_DIR"
}
violate_T() { # к14(П2)/к16(П2б) — ревьюер 072-r1 Б1: каталог СЛЕДА только
  # для чтения (перезаписать след на зелёном завершении невозможно); снимок
  # детектора пишется ВНЕ каталога следа, chmod — ПОСЛЕ снимка; клетка
  # возвращает право записи себе до выхода (гигиена trap).
  mkdir -p "$(dirname "$TRACE")"
  trace_past
  bash "$T/scripts/check_no_leak.sh" --snapshot "$T" >/dev/null 2>&1
  chmod a-w "$(dirname "$TRACE")"
}
violate_TS() { # к18/s16 — ревьюер 072-r2 Б5: мир violate_T ПЛЮС чужой
  # стоящий маркер (ставится ДО прогона — как сторож orch-peak: маркер —
  # флаг, содержимое не важно): отложенный чужой перезапуск — НЕ
  # состояние этой двери.
  violate_T
  mkdir -p "$MARKER_DIR"
  printf 'chuzhoj-stoyashchij\n' > "$MARKER_PATH"
}
violate_GC() { # мир г1 (прямой суд GC): неслитый wip + чистый приземлённый
  # мусор + грязный мусор; дверь не зовётся — снимок/след не нужны
  git -C "$T" worktree add -q -b wip/072/architect "$T-wip" main
  git -C "$T-wip" -c user.name=orchestrator -c user.email=orchestrator@dev-harness.local \
    commit -q --allow-empty -m 'toy: живой неслитый wip'
  git -C "$T" worktree add -q -b garbage-clean "$T-gwt" main
  git -C "$T" worktree add -q -b garbage-dirty "$T-dirty" main
  printf 'грязь\n' > "$T-dirty/dirty.txt"
}
violate_GC2() { # мир г2 (прямой суд GC, зелёная ветвь): неслитый wip +
  # чистый приземлённый мусор; неудаляемого мусора нет — GC обязан rc 0
  git -C "$T" worktree add -q -b wip/072/architect "$T-wip" main
  git -C "$T-wip" -c user.name=orchestrator -c user.email=orchestrator@dev-harness.local \
    commit -q --allow-empty -m 'toy: живой неслитый wip'
  git -C "$T" worktree add -q -b garbage-clean "$T-gwt" main
}

# run_subject <toy> <marker> [VAR=1 …]: прогон субъекта клетки.
run_subject() {
  local t="$1" m="$2"; shift 2
  rm -f "$m"
  mkdir -p "$(dirname "$m")"
  ( cd / && env ORCH_RESTART_MARKER="$m" ORCH_SESSION_START="$TRACE" "$@" bash "$t/scripts/orch_restart.sh" ) \
    > "$m.out" 2> "$m.err"
  S_RC=$?
}

# ── предикаты клеток: честное поведение, пиннутые маркеры ───────────────────
# Позиции: $1=имя $2=маркер $3=rc $4=stderr-файл $5=stdout-файл.
fail_cell() { printf 'клетка %s: %s\n' "$1" "$2" >&2; CELL_FAIL=1; }
p_A() { # rc 0, маркер стоит, stdout ПЕРЕЗАПУСК, легальный wip-worktree жив,
  # стартовый след ПЕРЕЗАПИСАН моментом завершения (зелёная пара А4)
  [ "$3" -eq 0 ] || { fail_cell "$1" "ожидался rc 0, получен $3: $(cat "$4")"; return 1; }
  [ -e "$2" ] || { fail_cell "$1" "маркер не поставлен"; return 1; }
  grep -Fq 'ПЕРЕЗАПУСК' "$5" || { fail_cell "$1" "нет строки ПЕРЕЗАПУСК в stdout"; return 1; }
  [ -d "$T-wip" ] || { fail_cell "$1" "легальный wip-worktree удалён"; return 1; }
  [ "$(cat "$TRACE" 2>/dev/null)" != "$(cat "$TRACE.pre" 2>/dev/null)" ] \
    || { fail_cell "$1" "стартовый след не перезаписан зелёным завершением"; return 1; }
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
p_I() { # отказ (в2): HANDOFF-коммит старее стартового следа
  p_refuse "$1" "$2" "$3" "$4" "$5" 'HANDOFF.md изменён до стартового следа сессии'
}
p_J() { # первое использование: отказ (в2) + след СОЗДАН (инициализация не вакуумна)
  p_refuse "$1" "$2" "$3" "$4" "$5" 'HANDOFF.md изменён до стартового следа сессии' || return 1
  [ -f "$TRACE" ] || { fail_cell "$1" "стартовый след не инициализирован"; return 1; }
  return 0
}
p_L() { # к12 (адверсарий 072-r1, блокер 2): fail-closed на многострочном
  # следе — маркера нет (p_refuse), причина названа, И след НЕ
  # перезаписан (инвариант 11 нарушен — дверь не имеет права читать его
  # частично через tail -n 1 и продолжать).
  p_refuse "$1" "$2" "$3" "$4" "$5" 'не ровно одна строка' || return 1
  [ "$(cat "$TRACE" 2>/dev/null)" = "$(cat "$TRACE.pre" 2>/dev/null)" ] \
    || { fail_cell "$1" "стартовый след перезаписан при отказе"; return 1; }
  return 0
}
p_M() { # к13 = П1 (ревьюер 072-r1 Б1): родитель маркера — обычный файл →
  # отказ записи МАРКЕРА fail-closed: rc≠0, «ПЕРЕЗАПУСК» НЕ печатается,
  # маркера нет (инварианты 7/8).
  [ "$3" -ne 0 ] || { fail_cell "$1" "ожидался отказ записи маркера, получен rc 0"; return 1; }
  grep -Fq 'ПЕРЕЗАПУСК' "$5" && { fail_cell "$1" "«ПЕРЕЗАПУСК» напечатан при отказе записи маркера"; return 1; }
  [ -e "$2" ] && { fail_cell "$1" "маркер стоит при отказе записи маркера"; return 1; }
  return 0
}
p_T() { # к14 = П2 (ревьюер 072-r1 Б1): каталог следа только для чтения на
  # зелёном завершении → rc≠0 (след не перезаписан — не «успех», инвариант
  # 11); «ПЕРЕЗАПУСК» НЕ печатается; след байт-в-байт равен ожиданию из
  # ПАМЯТИ батареи (правило 8). Состояние маркера в самих к14/к16 НЕ
  # пиннуто (обе формы двери r2/r3 проходят одним предикатом); фразы
  # инв. 3 пиннуты клетками-парой к17 (p_T_CLEAN) / к18 (p_T_STAND) —
  # ревьюер 072-r2 Б4: «выбор реализации» противоречил инв. 3, снято r3.
  [ "$3" -ne 0 ] || { fail_cell "$1" "ожидался отказ записи следа, получен rc 0"; return 1; }
  grep -Fq 'ПЕРЕЗАПУСК' "$5" && { fail_cell "$1" "«ПЕРЕЗАПУСК» напечатан при отказе записи следа"; return 1; }
  [ "$(cat "$TRACE" 2>/dev/null)" = "$TRACE_SNAP" ] \
    || { fail_cell "$1" "след изменён при незаписываемом каталоге следа"; return 1; }
  return 0
}
p_T_CLEAN() { # к17/s15 = Б4 (ревьюер 072-r2): отказ записи следа при
  # успешно поставленном маркере, до прогона маркера НЕ было → маркер
  # обязан ОТСУТСТВОВАТЬ (инв. 3 фраза 1: при любом отказе маркер не
  # создаётся; orch-loop взводит рестарт по стоящему маркеру — «ОТКАЗ»
  # с маркером обходит гейт).
  p_T "$1" "$2" "$3" "$4" "$5" || return 1
  [ -e "$2" ] && { fail_cell "$1" "маркер стоит при отказе записи следа"; return 1; }
  return 0
}
p_T_STAND() { # к18/s16 = Б5-зеркало (ревьюер 072-r2): ЧУЖОЙ маркер стоял
  # ДО прогона + отказ записи следа → маркер обязан СТОЯТЬ (инв. 3 фраза
  # 2: уже стоящий маркер дверь не удаляет — не её состояние; снос =
  # молча снятый отложенный перезапуск сторожа orch-peak).
  p_T "$1" "$2" "$3" "$4" "$5" || return 1
  [ -e "$2" ] || { fail_cell "$1" "чужой стоящий маркер снят при отказе записи следа"; return 1; }
  return 0
}
p_ORDER() { # к15 = порядок (инвариант 11 «след СРАЗУ после маркера»): при
  # невозможной записи МАРКЕРА след обязан остаться НЕТРОНУТЫМ — обратный
  # порядок (след до маркера) двинул бы границу сессии без маркера.
  p_M "$1" "$2" "$3" "$4" "$5" || return 1
  [ "$(cat "$TRACE" 2>/dev/null)" = "$TRACE_SNAP" ] \
    || { fail_cell "$1" "след перезаписан при отказе записи маркера — порядок обратен инварианту 11"; return 1; }
  return 0
}
p_F() { # отказ «мусорный worktree» с путём, worktree жив
  p_refuse "$1" "$2" "$3" "$4" "$5" 'мусорный worktree' || return 1
  grep -Fq "$T-gwt" "$4" || { fail_cell "$1" "путь мусорного worktree не назван"; return 1; }
  [ -d "$T-gwt" ] || { fail_cell "$1" "грязный worktree удалён (запрещено)"; return 1; }
  return 0
}
p_G2() { # rc 0, маркер, мусорный worktree УДАЛЁН, вызов GC зафиксирован внешним логом
  [ "$3" -eq 0 ] || { fail_cell "$1" "ожидался rc 0, получен $3: $(cat "$4")"; return 1; }
  [ -e "$2" ] || { fail_cell "$1" "маркер не поставлен"; return 1; }
  [ -d "$T-gwt" ] && { fail_cell "$1" "чистый приземлённый worktree не удалён"; return 1; }
  grep -Fq "GC-CALLED --root $T" "$GCLOG" 2>/dev/null \
    || { fail_cell "$1" "вызов GC не зафиксирован внешним логом (удаление мимо GC?)"; return 1; }
  return 0
}
p_H() { # отказ с путём, worktree жив
  p_refuse "$1" "$2" "$3" "$4" "$5" 'мусорный worktree' || return 1
  grep -Fq "$T-gwt" "$4" || { fail_cell "$1" "путь мусорного worktree не назван"; return 1; }
  [ -d "$T-gwt" ] || { fail_cell "$1" "неприземлённый worktree удалён (запрещено)"; return 1; }
  return 0
}
p_gc() { # г1 (ветвь отказа): rc 1; чистый приземлённый УДАЛЁН самим GC; грязный
  # жив и назван фразой с путём; неслитый wip жив (расширение наблюдаемо
  # само по себе — Б3; неудаляемый мусор по инварианту 4 даёт rc 1)
  [ -d "$T-gwt" ] && { fail_cell "$1" "чистый приземлённый мусорный worktree не удалён самим GC"; return 1; }
  [ "$3" -eq 1 ] || { fail_cell "$1" "ожидался rc 1 GC (неудаляемый мусор), получен $3"; return 1; }
  [ -d "$T-dirty" ] || { fail_cell "$1" "грязный мусорный worktree удалён GC (запрещено)"; return 1; }
  grep -Fq 'мусорный worktree' "$4" || { fail_cell "$1" "нет фразы «мусорный worktree» в stderr GC"; return 1; }
  grep -Fq "$T-dirty" "$4" || { fail_cell "$1" "грязный мусорный worktree не назван в stderr GC"; return 1; }
  [ -d "$T-wip" ] || { fail_cell "$1" "легальный wip-worktree удалён GC (запрещено)"; return 1; }
  return 0
}
p_gc2() { # г2 (зелёная ветвь): rc 0; чистый приземлённый УДАЛЁН самим GC; wip жив
  [ "$3" -eq 0 ] || { fail_cell "$1" "ожидался rc 0 GC, получен $3: $(cat "$4")"; return 1; }
  [ -d "$T-gwt" ] && { fail_cell "$1" "чистый приземлённый мусорный worktree не удалён самим GC"; return 1; }
  [ -d "$T-wip" ] || { fail_cell "$1" "легальный wip-worktree удалён GC (запрещено)"; return 1; }
  return 0
}

# build_cell <toy> <нарушение> <установка-субъекта>
build_cell() {
  local t="$1" v="$2" inst="$3"
  rm -rf "$t" "$t-origin.git" "$t-wip" "$t-gwt" "$t-dirty"
  toy_make "$t"
  "$inst"
  subject_commit
  "$v"
}

# run_seq_cell <метка> <строитель> <установка> [ENV=1 …]: клетка ПЕРЕХОДА
# к11 (арбитраж 072-Б2, различающий вход (i)): S1 зелёная дверь (rc 0,
# маркер, след := момент завершения) → батарея снимает маркер, HANDOFF
# не менялся → S2 обязан rc 1 «HANDOFF.md изменён до стартового следа
# сессии», маркера нет → новый HANDOFF-коммит той же identity (sleep 1:
# committer-дата строго новее следа S1) → S3 rc 0, маркер. Любая
# упавшая стадия краснит клетку целиком (SEQ_FAIL).
run_seq_cell() {
  local tag="$1" v="$2" inst="$3"; shift 3
  local M="$WORK/seq-$tag"
  T="$WORK/st-$tag"; TRACE="$M-trace"; GCLOG="$M-gclog"
  build_cell "$T" "$v" "$inst"
  rm -f "$GCLOG"
  SEQ_FAIL=0
  # S1: зелёная дверь (след в прошлом относительно HANDOFF-коммита)
  cp "$TRACE" "$TRACE.pre"
  run_subject "$T" "$M-s1" "$@"
  CELL_FAIL=0; p_A "$tag-S1" "$M-s1" "$S_RC" "$M-s1.err" "$M-s1.out"
  [ "$CELL_FAIL" -eq 0 ] || SEQ_FAIL=1
  # батарея снимает маркер; HANDOFF-коммит НЕ менялся
  rm -f "$M-s1"
  run_subject "$T" "$M-s2" "$@"
  CELL_FAIL=0; p_I "$tag-S2" "$M-s2" "$S_RC" "$M-s2.err" "$M-s2.out"
  [ "$CELL_FAIL" -eq 0 ] || SEQ_FAIL=1
  # новый HANDOFF-коммит той же identity; sleep 1 — committer-дата строго
  # новее следа, которым завершилась S1 (git %ct — секундное разрешение)
  sleep 1
  printf '## ГДЕ МЫ (toy, переход)\n' > "$T/HANDOFF.md"
  git -C "$T" add HANDOFF.md
  git -C "$T" commit -qm 'toy: новый HANDOFF (клетка перехода)'
  git -C "$T" push -q origin main
  # пересъём детекторного базлайна ПОСЛЕ нового коммита (канон violate_D:
  # HANDOFF-коммит сессии — легальная дельта, входит в базлайн; детектор
  # судит МУСОР ПОСЛЕ базлайна, не правку HANDOFF)
  bash "$T/scripts/check_no_leak.sh" --snapshot "$T" >/dev/null 2>&1
  # S3: зелёная дверь на новом HANDOFF-коммите
  cp "$TRACE" "$TRACE.pre"
  run_subject "$T" "$M-s3" "$@"
  CELL_FAIL=0; p_A "$tag-S3" "$M-s3" "$S_RC" "$M-s3.err" "$M-s3.out"
  [ "$CELL_FAIL" -eq 0 ] || SEQ_FAIL=1
}

# ── СТАБ-ПАК: 16 стабов × (ручка=дефект ловится, ручки нет — диффпроба) ─────
stab_caught=0; diff_green=0
run_cell_pair() { # $1=метка $2=нарушение $3=предикат $4=ручка
  local tag="$1" v="$2" pred="$3" knob="$4"
  local M="$WORK/m-$tag"
  # проход с ручкой: дефект ОБЯЗАН быть пойман (предикат честного поведения падает)
  T="$WORK/t-$tag-on"; TRACE="$M-on-trace"; GCLOG="$M-on-gclog"
  build_cell "$T" "$v" stub_install
  rm -f "$GCLOG"
  run_subject "$T" "$M-on" "STUB_$knob=1"
  CELL_FAIL=0
  "$pred" "$tag(ручка)" "$M-on" "$S_RC" "$M-on.err" "$M-on.out"
  if [ "$CELL_FAIL" -ne 0 ]; then stab_caught=$((stab_caught+1)); else
    printf 'стаб-пак ОТКАЗ: стаб %s с ручкой ПРОШЁЛ клетку (%s)\n' "$knob" "$tag" >&2
    exit 1
  fi
  # диффпроба: та же клетка БЕЗ ручки — честное поведение держится
  T="$WORK/t-$tag-off"; TRACE="$M-off-trace"; GCLOG="$M-off-gclog"
  build_cell "$T" "$v" stub_install
  rm -f "$GCLOG"
  run_subject "$T" "$M-off"
  CELL_FAIL=0
  "$pred" "$tag(дифф)" "$M-off" "$S_RC" "$M-off.err" "$M-off.out"
  if [ "$CELL_FAIL" -eq 0 ]; then diff_green=$((diff_green+1)); else
    printf 'стаб-пак ОТКАЗ: диффпроба %s упала без ручки\n' "$tag" >&2
    exit 1
  fi
}

# s10 — стаб ВЫХОДНОЙ СТОРОНЫ (арбитраж 072-Б2): клетка перехода к11 на
# обеих сторонах: с ручкой (мутант критика к2 «след = ct(HANDOFF)−1»)
# стадия S2 даёт rc 0 и маркер — предикат честного поведения падает,
# дефект пойман; без ручки та же последовательность зелёна (диффпроба).
run_seq_pair() { # $1=метка $2=строитель $3=ручка
  run_seq_cell "$1(ручка)" "$2" stub_install "STUB_$3=1"
  if [ "$SEQ_FAIL" -ne 0 ]; then stab_caught=$((stab_caught+1)); else
    printf 'стаб-пак ОТКАЗ: стаб %s с ручкой ПРОШЁЛ клетку перехода (%s)\n' "$3" "$1" >&2
    exit 1
  fi
  run_seq_cell "$1(дифф)" "$2" stub_install
  if [ "$SEQ_FAIL" -eq 0 ]; then diff_green=$((diff_green+1)); else
    printf 'стаб-пак ОТКАЗ: диффпроба перехода %s упала без ручки\n' "$1" >&2
    exit 1
  fi
}

# ── клетки несводимого ВЫХОДА (Б1): маркер — в собственном подкаталоге
# клетки (родитель может быть обычным файлом), след — в собственном
# подкаталоге (может быть только для чтения); stdout/stderr клетки — НЕ под
# битым родителем; ожидание следа — в ПАМЯТИ батареи (правило 8). ─────────
run_exit_subject() { # $1=toy $2=marker $3=stdout $4=stderr [ENV=1 …]
  local t="$1" m="$2" o="$3" e="$4"; shift 4
  ( cd / && env ORCH_RESTART_MARKER="$m" ORCH_SESSION_START="$TRACE" "$@" \
      bash "$t/scripts/orch_restart.sh" ) > "$o" 2> "$e"
  S_RC=$?
}
trace_restore() { chmod u+w "$(dirname "$TRACE")" 2>/dev/null || :; }

run_exit_pair() { # $1=метка $2=мир $3=предикат $4=ручка (стаб-пак Б1)
  local tag="$1" world="$2" pred="$3" knob="$4" side
  for side in on off; do
    local M="$WORK/x-$tag-$side" envargs=()
    T="$WORK/xt-$tag-$side"; TRACE="$WORK/x-trace-$tag-$side/trace"; GCLOG="$M-gclog"
    MARKER_DIR="$M.d"; MARKER_PATH="$MARKER_DIR/mark"
    build_cell "$T" "$world" stub_install
    rm -f "$GCLOG"
    TRACE_SNAP="$(cat "$TRACE" 2>/dev/null || printf '')"
    [ "$side" = on ] && envargs=("STUB_$knob=1")
    run_exit_subject "$T" "$MARKER_PATH" "$M.out" "$M.err" ${envargs[@]+"${envargs[@]}"}
    trace_restore
    CELL_FAIL=0
    "$pred" "$tag($side)" "$MARKER_PATH" "$S_RC" "$M.err" "$M.out"
    if [ "$side" = on ]; then
      if [ "$CELL_FAIL" -ne 0 ]; then stab_caught=$((stab_caught+1)); else
        printf 'стаб-пак ОТКАЗ: стаб %s с ручкой ПРОШЁЛ клетку (%s)\n' "$knob" "$tag" >&2
        exit 1
      fi
    else
      if [ "$CELL_FAIL" -eq 0 ]; then diff_green=$((diff_green+1)); else
        printf 'стаб-пак ОТКАЗ: диффпроба %s упала без ручки\n' "$tag" >&2
        exit 1
      fi
    fi
  done
}

run_seq_exit_cell() { # к16 = П2б (ревьюер 072-r1 Б1): мир violate_T →
  # S1 отказ → S2а повтор БЕЗ нового HANDOFF-коммита, ЧУЖОЙ стоящий
  # маркер ПОСТАВЛЕН батареей до S2а (r3: честная дверь/стаб откатывают
  # СВОЙ маркер при отказе следа — S1 его не оставляет; стоящий маркер в
  # мир ставит батарея — не «короткий путь успеха», форма сторожа
  # orch-peak) → S2б маркер снят батареей (форма пробы ревьюера) — все
  # стадии обязаны отказывать:
  # обход арбитража 072-Б2 не открывается вновь при отказавшей записи
  # следа. Любая упавшая стадия краснит клетку целиком (EXIT_SEQ_FAIL).
  local tag="$1" world="$2" inst="$3"; shift 3
  local M="$WORK/xq-$tag"
  T="$WORK/xqt-$tag"; TRACE="$WORK/xq-trace-$tag/trace"; GCLOG="$M-gclog"
  MARKER_DIR="$M.d"; MARKER_PATH="$MARKER_DIR/mark"
  build_cell "$T" "$world" "$inst"
  rm -f "$GCLOG"
  EXIT_SEQ_FAIL=0
  TRACE_SNAP="$(cat "$TRACE" 2>/dev/null || printf '')"
  local st
  for st in s1 s2a s2b; do
    [ "$st" = s2a ] && { mkdir -p "$MARKER_DIR"; : > "$MARKER_PATH"; }
    [ "$st" = s2b ] && rm -f "$MARKER_PATH"
    run_exit_subject "$T" "$MARKER_PATH" "$M-$st.out" "$M-$st.err" "$@"
    CELL_FAIL=0
    p_T "$tag-$st" "$MARKER_PATH" "$S_RC" "$M-$st.err" "$M-$st.out"
    [ "$CELL_FAIL" -eq 0 ] || EXIT_SEQ_FAIL=1
  done
  trace_restore
}

run_seq_exit_pair() { # $1=метка $2=мир $3=ручка (стаб-пак Б1, клетка П2б)
  run_seq_exit_cell "$1(ручка)" "$2" stub_install "STUB_$3=1"
  if [ "$EXIT_SEQ_FAIL" -ne 0 ]; then stab_caught=$((stab_caught+1)); else
    printf 'стаб-пак ОТКАЗ: стаб %s с ручкой ПРОШЁЛ клетку П2б (%s)\n' "$3" "$1" >&2
    exit 1
  fi
  run_seq_exit_cell "$1(дифф)" "$2" stub_install
  if [ "$EXIT_SEQ_FAIL" -eq 0 ]; then diff_green=$((diff_green+1)); else
    printf 'стаб-пак ОТКАЗ: диффпроба П2б %s упала без ручки\n' "$1" >&2
    exit 1
  fi
}

run_exit_honest() { # $1=метка $2=мир $3=предикат (честная часть, Б1)
  local tag="$1" world="$2" pred="$3"
  honest_total=$((honest_total+1))
  local M="$WORK/xh-$tag"
  T="$WORK/xht-$tag"; TRACE="$WORK/xh-trace-$tag/trace"; GCLOG="$M-gclog"
  MARKER_DIR="$M.d"; MARKER_PATH="$MARKER_DIR/mark"
  build_cell "$T" "$world" honest_install
  rm -f "$GCLOG"
  TRACE_SNAP="$(cat "$TRACE" 2>/dev/null || printf '')"
  run_exit_subject "$T" "$MARKER_PATH" "$M.out" "$M.err"
  trace_restore
  CELL_FAIL=0
  "$pred" "$tag" "$MARKER_PATH" "$S_RC" "$M.err" "$M.out"
  if [ "$CELL_FAIL" -eq 0 ]; then honest_green=$((honest_green+1)); fi
}

run_cell_pair s1 violate_B p_B SKIP_HEAD
run_cell_pair s2 violate_C p_C SKIP_PORCELAIN
run_cell_pair s3 violate_D p_D SKIP_HANDOFF
run_cell_pair s4 violate_E p_E SKIP_DETECTOR
run_cell_pair s5 violate_F p_F SKIP_WORKTREE
run_cell_pair s6 violate_C p_C EAGER_MARKER
run_cell_pair s7 violate_G p_G2 NO_DELETE
run_cell_pair s8 violate_I p_I SKIP_TRACE
run_cell_pair s9 violate_G p_G2 INLINE_DELETE
run_seq_pair s10 violate_K TRACE_MOMENT
run_exit_pair s11 violate_M p_M MARKER_UNCHECKED
run_exit_pair s12 violate_T p_T TRACE_UNCHECKED
run_exit_pair s13 violate_M p_ORDER TRACE_FIRST
run_seq_exit_pair s14 violate_T RETRY_GREEN
run_exit_pair s15 violate_T p_T_CLEAN KEEP_MARKER
run_exit_pair s16 violate_TS p_T_STAND RM_STANDING
printf 'стаб-пак: %d/16 поймано, диффпроба %d/16\n' "$stab_caught" "$diff_green"
[ "$stab_caught" -eq 16 ] && [ "$diff_green" -eq 16 ] \
  || die_pack "счёт стаб-пака не сошёлся (поймано $stab_caught, дифф $diff_green)"

# ── ЧЕСТНАЯ ЧАСТЬ ────────────────────────────────────────────────────────────
honest_green=0; honest_total=0

# г1: ПРЯМОЙ суд самого GC (до г0: расширение красно уже на нынешнем дереве)
run_gc_cell() { # $1=метка $2=строитель мира $3=предикат
  local tag="$1" v="$2" pred="$3"
  honest_total=$((honest_total+1))
  T="$WORK/ht-$tag"; TRACE="$WORK/ht-$tag-trace"; GCLOG="$WORK/ht-$tag-gclog"
  build_cell "$T" "$v" gc_only_install
  rm -f "$GCLOG" "$TRACE"
  ( cd / && bash "$T/scripts/gc_agent_branches.sh" --root "$T" ) \
    > "$WORK/g-$tag.out" 2> "$WORK/g-$tag.err"
  S_RC=$?
  CELL_FAIL=0
  "$pred" "$tag" "$WORK/g-$tag" "$S_RC" "$WORK/g-$tag.err" "$WORK/g-$tag.out"
  if [ "$CELL_FAIL" -eq 0 ]; then honest_green=$((honest_green+1)); fi
}
run_gc_cell г1 violate_GC p_gc
run_gc_cell г2 violate_GC2 p_gc2

# г0: носитель предмета (двери)
if [ ! -f "$ROOT/scripts/orch_restart.sh" ]; then
  printf 'ОТКАЗ: предмет отсутствует — в дереве нет scripts/orch_restart.sh\n' >&2
  exit 1
fi

# ── ЧЕСТНАЯ ЧАСТЬ ДВЕРИ: к1..к18 против реальных скриптов дерева ────────────
run_honest() { # $1=метка $2=нарушение $3=предикат
  local tag="$1" v="$2" pred="$3"
  honest_total=$((honest_total+1))
  local M="$WORK/h-$tag"
  T="$WORK/ht-$tag"; TRACE="$M-trace"; GCLOG="$M-gclog"
  build_cell "$T" "$v" honest_install
  cp "$TRACE" "$TRACE.pre" 2>/dev/null || : > "$TRACE.pre"
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
run_honest к7 violate_G p_G2
run_honest к8 violate_H p_H
run_honest к9 violate_I p_I
run_honest к10 violate_J p_J
# к11 — клетка ПЕРЕХОДА против реальной двери (арбитраж 072-Б2):
# последовательный вход без нового HANDOFF-коммита обязан отказывать
honest_total=$((honest_total+1))
run_seq_cell к11 violate_K honest_install
if [ "$SEQ_FAIL" -eq 0 ]; then honest_green=$((honest_green+1)); fi
# к12 (адверсарий 072-r1, блокер 2): стартовый след многострочный
# (мусор\n<ISO>) — инвариант 11 требует ровно одну непустую строку.
run_honest к12 violate_L p_L
# к13..к16 — ревьюер 072-r1 Б1: запись маркера/следа не проверяется,
# порядок обратен инварианту 11, обход 072-Б2 при отказавшей записи следа.
run_exit_honest к13 violate_M p_M
run_exit_honest к14 violate_T p_T
run_exit_honest к15 violate_M p_ORDER
# к16 = П2б — клетка ПЕРЕХОДА против реальной двери: повторный вход без
# нового HANDOFF-коммита при отказавшей записи следа обязан отказывать.
honest_total=$((honest_total+1))
run_seq_exit_cell к16 violate_T honest_install
if [ "$EXIT_SEQ_FAIL" -eq 0 ]; then honest_green=$((honest_green+1)); fi
# к17 — ревьюер 072-r2 Б4 (пост-freeze усиление, прецедент 005): отказ
# записи следа при УСПЕШНО поставленном маркере (до прогона маркера НЕ
# было) → маркер обязан ОТСУТСТВОВАТЬ. Зелёна обеим формам двери (r2
# безусловный rm и r3 условный откат свой маркер откатывают одинаково);
# ловит живой мутант (в) «снят откат» в самой двери.
run_exit_honest к17 violate_T p_T_CLEAN
run_exit_honest к18 violate_TS p_T_STAND
printf 'честная часть: %d/%d зелёная\n' "$honest_green" "$honest_total"
[ "$honest_green" -eq "$honest_total" ] \
  || die_pack "честная часть красна ($honest_green/$honest_total)"
printf 'итог 072-батареи: предъявлений стабы %d/16 + дифф %d/16 + честные %d/%d\n' \
  "$stab_caught" "$diff_green" "$honest_green" "$honest_total"
exit 0
