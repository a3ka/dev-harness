#!/usr/bin/env bash
# Барьер приёмки ГИГИЕНЫ РАННЕРА verify_antiplacebo + ФОРМЫ НОРМЫ приёмки судьи
# (контракт 011, тир-1). Предмет — решение грилинга 2026-08-24 V3=(а) по Н-48: приёмка
# «полный verify_antiplacebo → 0» стоила 3+ часа на закрытии 010 (ревьюер 1h49m, ~6
# перепрогонов, взаимные kill), потому что раннер недостижим судьёй и не изолирован.
#
# Гоняет ПРЕДМЕТ `<корень>/scripts/verify_antiplacebo.sh` на ПОРОЖДЁННЫХ игрушечных деревьях
# (как check_scoped_run) и УТВЕРЖДАЕТ дисциплину, а не вывод:
#   (lock)    живой lock → второй прогон отказывает РОВНО кодом 3 со словом «занят»,
#             lock-файл — ровно `<pid> <pgid> <epoch>` (три числовых поля; pid —
#             владелец-раннер, pgid — его группа), отказ НЕ перезаписывает чужой lock
#             (байт-в-байт до/после); первый прогон НЕ тронут (rc=0) — Н-48-3/4.
#             Одновременную гонку барьер не инсценирует (недетерминирована):
#             наблюдаемое следствие атомарного set -C-захвата — отказ без перезаписи;
#   (scratch) за время прогона (с явной VERIFY_ANTIPLACEBO_SCRATCH) в стерегомом дереве
#             НЕ появляется новых путей — ни во время (зонд каждые 0.1с, ловит и
#             «подметание trap'ом»), ни после (слепок) — Н-48-2/5;
#   (scratchdef) ПУСТАЯ VERIFY_ANTIPLACEBO_SCRATCH → скратч обязан появиться под
#             подставным ${TMPDIR:-/tmp} и НЕ в дереве (in-tree ./tmp — обход круга 1
#             критика: «оставить при пустой переменной нынешний in-tree ./tmp»);
#   (chistka) старт нового прогона убирает артефакты МЁРТВЫХ владельцев (stale lock,
#             run-<мёртвый pid>, base64-мусор) и НЕ трогает чужой live lock другого дерева;
#   (pgid)    раннер не убивает чужие процессы по имени: decoy с «verify_antiplacebo» в
#             cmdline переживает и полный прогон, и отказ по lock — Н-48-4. ОХРАНА: на
#             текущем дереве зелена (раннер pkill не делает); красное предъявляется обманкой;
#   (norma)   AGENTS.md несёт ПОЛНЫЙ текст приёмки судьи v2 — три строки ДОСЛОВНО из
#             §Предмет А.1 контракта 011 (две подстроки проходили противоположную по
#             смыслу норму — обход круга 1 критика) — Н-48-1;
#   (carveout)AGENTS.md несёт carve-out правила 16 («ИСКЛЮЧЕНИЕ (carve-out» +
#             «VERIFY_ANTIPLACEBO_SCRATCH», коммит 1737953). ОХРАНА: на текущем дереве
#             зелена; красное предъявляется обманкой;
#   (a010)    contracts/010-*.md несёт у §Приёмка п.8 пометку «отменено грилингом
#             2026-08-24» — замороженный текст требовал от судьи полный прогон.
#
# Образец — check_scoped_run/check_judge_gate: предмет пишет ИСПОЛНИТЕЛЬ по зоне; этот
# барьер, `fixtures/check_runner_hygiene/` (case_*.sh + эталон `_ref_runner.sh`) — АРХИТЕКТОРА.
# Фикстуры предъявляют барьер красным, подавая сломанные раннеры/нормы в подставной корень
# (green-root → red-root). КРАСНОЕ ПРОТИВ ТЕКУЩЕГО ДЕРЕВА: lock/scratch/scratchdef/
# chistka/norma/a010 красны (предмет не реализован), pgid/carveout зелены как охрана.
#
#   bash scripts/check_runner_hygiene.sh [<корень>] [<ветвь>]
#     <корень> — где лежит scripts/verify_antiplacebo.sh, AGENTS.md, contracts/
#                (умолчание — корень репозитория);
#     <ветвь>  — одна из: lock scratch scratchdef chistka pgid norma carveout a010 (умолчание — все).
#
# Коды возврата: 0 — запрошенные ветви зелены, 1 — ветвь провалена, 2 — нечем проверить.
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null LC_ALL="${LC_ALL:-C.UTF-8}"

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SELF_DIR/.." && pwd)"
ROOT="${1:-$REPO}"
ROOT="$(cd "$ROOT" 2>/dev/null && pwd || echo "$ROOT")"
VA="$ROOT/scripts/verify_antiplacebo.sh"
WANT="${2:-all}"

die()  { printf 'ОТКАЗ ветвь (%s): %s\n' "$1" "$2" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }
ok()   { printf '  ok   %s\n' "$*" >&2; }

want() { [ "$WANT" = all ] || [ "$WANT" = "$1" ]; }
has()  { case "$2" in *"$1"*) return 0 ;; *) return 1 ;; esac; }
tail200() { tr '\n' ' ' < "$1" | tail -c 200; }

KNOWN="lock scratch scratchdef chistka pgid norma carveout a010"
if [ "$WANT" != all ]; then
  f=0; for k in $KNOWN; do [ "$WANT" = "$k" ] && f=1; done
  [ "$f" = 1 ] || { printf 'ОТКАЗ диспетчер: неизвестная ветвь «%s» (из: %s)\n' "$WANT" "$KNOWN" >&2; exit 1; }
fi

[ -f "$VA" ] || skip "нет $VA — предмет гигиены отсутствует"
command -v sha256sum >/dev/null 2>&1 || skip "нет sha256sum — hash8 lock-файла не вычислить"
command -v setsid  >/dev/null 2>&1 || skip "нет setsid — decoy-процессы не изолировать"

# Временное — в ./tmp репозитория (правило 16; carve-out касается ТОЛЬКО раннера).
TMP="$REPO/tmp"; mkdir -p "$TMP" 2>/dev/null || skip "tmp не создать"
WORK="$(mktemp -d "$TMP/check_runner_hygiene.XXXXXX")" || skip "mktemp не смог"
WORK="$(cd "$WORK" && pwd -P)"

RUN1_PID=""; DECOY_PID=""; FOREIGN_PID=""
cleanup() {
  [ -n "$RUN1_PID" ]    && kill -9 "$RUN1_PID"    2>/dev/null
  [ -n "$DECOY_PID" ]   && kill -9 -- "-$DECOY_PID" 2>/dev/null
  [ -n "$FOREIGN_PID" ] && kill -9 -- "-$FOREIGN_PID" 2>/dev/null
  rm -rf "$WORK"
}
trap cleanup EXIT

hash8_of()  { printf '%s' "$1" | sha256sum | cut -c1-8; }
lock_path() { printf '%s/verify_antiplacebo-%s.lock' "$1" "$(hash8_of "$2")"; }

wait_lock() {  # <lock-файл> <сек-таймаут>
  local i=0 max=$(( $2 * 20 ))
  while [ "$i" -lt "$max" ]; do
    [ -f "$1" ] && return 0
    sleep 0.05; i=$((i + 1))
  done
  return 1
}

wait_alive() {  # <pid> <сек>
  local i=0 max=$(( $2 * 20 ))
  while [ "$i" -lt "$max" ]; do
    kill -0 "$1" 2>/dev/null && return 0
    sleep 0.05; i=$((i + 1))
  done
  kill -0 "$1" 2>/dev/null
}

# Игрушечное дерево данных: один барьер check_a + честная фикстура (зелёный → снять маркер →
# красный), СОН перед первым вызовом — окно, в котором раннер «работает» и держит lock.
build_toy() {  # <каталог> <сон-сек>
  local r="$1" sl="$2"
  mkdir -p "$r/scripts" "$r/fixtures/check_a"
  cat > "$r/scripts/check_a.sh" <<EOF
#!/usr/bin/env bash
# Коды возврата: 0 — маркер есть, 1 — нет
d="\$(cd "\$(dirname "\$0")/.." && pwd)"
[ -f "\$d/mark" ] || { echo "нет mark (check_a)" >&2; exit 1; }
EOF
  chmod +x "$r/scripts/check_a.sh"
  cat > "$r/fixtures/check_a/case_a.sh" <<EOF
# ПРИЧИНА: нет mark (check_a)
set -euo pipefail
sleep $sl
mkdir -p "\$WORK/w"; touch "\$WORK/w/mark"
BARRIER_ROOT="\$WORK/w" "\$BARRIER"
rm -f "\$WORK/w/mark"
BARRIER_ROOT="\$WORK/w" "\$BARRIER"
EOF
}

# ── (lock) живой владелец → отказ ровно код 3 «занят», чужой lock не тронут ─────
if want lock; then
  S="$WORK/s-lock"; T="$WORK/toy-lock"
  mkdir -p "$S"; build_toy "$T" 2; T="$(cd "$T" && pwd)"
  L="$(lock_path "$S" "$T")"
  VERIFY_ANTIPLACEBO_SCRATCH="$S" bash "$VA" "$T" >"$WORK/lock-r1.out" 2>&1 &
  RUN1_PID=$!
  # Ждём не просто файл, а ЗАПОЛНЕННЫЙ тройкой lock: эталон создаёт его noclobber'ом
  # и пишет поля следом — окно «файл есть, полей нет» законно и коротко (до 8с).
  lock_before=""; got=0; i=0
  while [ "$i" -lt 160 ]; do
    lock_before="$(cat "$L" 2>/dev/null || true)"
    if printf '%s\n' "$lock_before" | grep -Eq '^[0-9]+ [0-9]+ [0-9]+$'; then got=1; break; fi
    sleep 0.05; i=$((i + 1))
  done
  if [ "$got" != 1 ]; then
    if [ -f "$L" ]; then
      die lock "lock-файл не в формате «<pid> <pgid> <epoch>» (три числовых поля), в нём: «$(printf '%s' "$lock_before" | tr '\n' ' ')» — пинованный API §Предмет Б.2 контракта 011 (обход круга 1 критика)"
    fi
    die lock "lock-файл не появился за 8с — раннер не захватывает lock вовсе, параллельные прогоны не разведены (Н-48-3)"
  fi
  read -r l_pid l_pgid l_epoch <<< "$lock_before"
  [ "$l_pid" = "$RUN1_PID" ] \
    || die lock "первое поле lock ($l_pid) — не pid владельца-раннера ($RUN1_PID): поле обязано называть живого владельца, иначе проверка живости и чистка врут (§Предмет Б.2)"
  pg_now="$(ps -o pgid= -p "$RUN1_PID" 2>/dev/null | tr -d ' ')"
  { [ -n "$pg_now" ] && [ "$l_pgid" = "$pg_now" ]; } \
    || die lock "второе поле lock ($l_pgid) — не pgid владельца ($pg_now): pgid нужна диагностике чистки мёртвых прогонов (§Предмет Б.2)"
  VERIFY_ANTIPLACEBO_SCRATCH="$S" bash "$VA" "$T" >"$WORK/lock-r2.out" 2>&1
  R2=$?
  lock_after="$(cat "$L" 2>/dev/null || true)"
  wait "$RUN1_PID"; R1=$?; RUN1_PID=""
  [ "$R1" = 0 ] || die lock "первый прогон убит или испорчен (rc=$R1) — второй обязан НЕ трогать существующий прогон и его дерево (Н-48-3/4). Хвост вывода первого: $(tail200 "$WORK/lock-r1.out")"
  [ "$R2" = 3 ] || die lock "второй прогон при живом владельце вышел кодом $R2 — отказ обязан быть ровно кодом 3 (шапка раннера «3 — занят другим прогоном», §Предмет Б.2; обход круга 1 критика)"
  has 'занят' "$(cat "$WORK/lock-r2.out")" || die lock "отказ второго прогона не назван словом «занят» — причина обязана называть предмет (правило 7). Хвост вывода второго: $(tail200 "$WORK/lock-r2.out")"
  [ "$lock_after" = "$lock_before" ] \
    || die lock "второй прогон перезаписал либо удалил чужой lock (до отказа: «$(printf '%s' "$lock_before" | tr '\n' ' ')», после: «$(printf '%s' "$lock_after" | tr '\n' ' ')») — атомарный захват (set -C) не затирает существующий файл; одновременную гонку барьер не инсценирует (недетерминирована), наблюдаемое — отказ без перезаписи (§Предмет Б.2, обход круга 1 критика)"
  ok '(lock) трёхпольный lock владельца, отказ код 3 «занят», чужой lock байт-в-байт цел, первый прогон цел (rc=0)'
fi

# ── (scratch) стерегомое дерево не меняется ни во время, ни после ──────────────
if want scratch; then
  S="$WORK/s-scratch"; T="$WORK/toy-scratch"
  mkdir -p "$S"; build_toy "$T" 2; T="$(cd "$T" && pwd)"
  base_list="$(cd "$T" && find . -mindepth 1 -maxdepth 1 | sort)"
  snap_before="$(cd "$T" && find . -type f -print0 | sort -z | xargs -0 -r sha256sum)"
  VERIFY_ANTIPLACEBO_SCRATCH="$S" bash "$VA" "$T" >"$WORK/scr-r1.out" 2>&1 &
  RUN1_PID=$!
  violation=""; i=0
  while kill -0 "$RUN1_PID" 2>/dev/null && [ "$i" -lt 100 ]; do
    cur="$(cd "$T" && find . -mindepth 1 -maxdepth 1 | sort)"
    if [ "$cur" != "$base_list" ]; then
      violation="$(comm -13 <(printf '%s\n' "$base_list") <(printf '%s\n' "$cur") | tr '\n' ' ')"
      break
    fi
    sleep 0.1; i=$((i + 1))
  done
  wait "$RUN1_PID"; R1=$?; RUN1_PID=""
  [ "$R1" = 0 ] || die scratch "прогон упал (rc=$R1) — ветвь про чистоту дерева, а не про отказ предмета. Хвост: $(tail200 "$WORK/scr-r1.out")"
  [ -z "$violation" ] || die scratch "во время прогона в стерегомом дереве появились новые пути (${violation% }) — scratch раннера обязан жить вне стерегомого дерева (Н-48-2, carve-out правила 16)"
  [ ! -e "$T/tmp" ] || die scratch "после прогона в корне дерева остался $T/tmp — артефакты раннера обязаны уходить в \$VERIFY_ANTIPLACEBO_SCRATCH (Н-48-2/5)"
  snap_after="$(cd "$T" && find . -type f -print0 | sort -z | xargs -0 -r sha256sum)"
  [ "$snap_before" = "$snap_after" ] || die scratch "слепок дерева изменился после прогона — раннер обязан оставить дерево байт-в-байт (Н-48-2)"
  ok '(scratch) дерево нетронуто ни во время прогона, ни после'
fi

# ── (scratchdef) ПУСТАЯ VERIFY_ANTIPLACEBO_SCRATCH → скратч под ${TMPDIR:-/tmp} ──
if want scratchdef; then
  T="$WORK/toy-scratchdef"; SD="$WORK/tmpdir-def"
  build_toy "$T" 2; T="$(cd "$T" && pwd)"; mkdir -p "$SD"
  base_list="$(cd "$T" && find . -mindepth 1 -maxdepth 1 | sort)"
  VERIFY_ANTIPLACEBO_SCRATCH="" TMPDIR="$SD" bash "$VA" "$T" >"$WORK/sd-r1.out" 2>&1 &
  RUN1_PID=$!
  seen=0; i=0
  while kill -0 "$RUN1_PID" 2>/dev/null && [ "$i" -lt 100 ]; do
    if [ -n "$(find "$SD" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]; then seen=1; break; fi
    sleep 0.1; i=$((i + 1))
  done
  wait "$RUN1_PID"; RC=$?; RUN1_PID=""
  [ "$RC" = 0 ] || die scratchdef "прогон упал (rc=$RC) — ветвь про место default-скратча, а не про отказ предмета. Хвост: $(tail200 "$WORK/sd-r1.out")"
  [ "$seen" = 1 ] || die scratchdef "за время прогона под \$TMPDIR не появился скратч — при пустой VERIFY_ANTIPLACEBO_SCRATCH раннер обязан создавать его mktemp -d под \${TMPDIR:-/tmp} (§Предмет Б.1, обход круга 1 критика). Хвост: $(tail200 "$WORK/sd-r1.out")"
  [ ! -e "$T/tmp" ] || die scratchdef "при пустой VERIFY_ANTIPLACEBO_SCRATCH раннер завёл ./tmp внутри дерева — default обязан уходить под \${TMPDIR:-/tmp}, не в дерево (§Предмет Б.1, Н-48-2)"
  cur="$(cd "$T" && find . -mindepth 1 -maxdepth 1 | sort)"
  [ "$cur" = "$base_list" ] || die scratchdef "стерегомое дерево изменилось при default-скратче — артефакты раннера обязаны уходить вне дерева (Н-48-2)"
  ok '(scratchdef) пустая переменная → скратч под ${TMPDIR:-/tmp}, дерево чисто'
fi

# ── (chistka) старт убирает мусор мёртвых, чужое живое не трогает ──────────────
if want chistka; then
  S="$WORK/s-chistka"; T="$WORK/toy-chistka"
  mkdir -p "$S"; build_toy "$T" 0.4; T="$(cd "$T" && pwd)"
  # мёртвый pid — гарантированно: породили и дождались
  bash -c 'exit 0' & DPID=$!; wait "$DPID"
  mkdir -p "$S/run-$DPID"; printf 'junk\n' > "$S/run-$DPID/log"
  JUNK="$S/cHJ4LW9ib3J2YnZhLXB1dGk"      # base64-обрывок пути убитого прогона (Н-48-5)
  printf 'obryvok\n' > "$JUNK"
  L_T="$(lock_path "$S" "$T")"            # stale lock мёртвого владельца ЭТОГО дерева
  printf '%s %s %s\n' "$DPID" 999999 0 > "$L_T"
  FROOT="$WORK/other-root"; mkdir -p "$FROOT"
  setsid sleep 30 >/dev/null 2>&1 & FOREIGN_PID=$!
  wait_alive "$FOREIGN_PID" 3 || die chistka "decoy-владелец чужого lock не поднялся — тест недостоверен"
  L_F="$(lock_path "$S" "$FROOT")"        # ЧУЖОЙ live lock другого дерева
  printf '%s %s %s\n' "$FOREIGN_PID" "$FOREIGN_PID" 0 > "$L_F"
  VERIFY_ANTIPLACEBO_SCRATCH="$S" bash "$VA" "$T" >"$WORK/chi-r1.out" 2>&1
  RC=$?
  [ "$RC" = 0 ] || die chistka "stale lock мёртвого владельца не должен блокировать новый прогон, а вышел rc=$RC. Хвост: $(tail200 "$WORK/chi-r1.out")"
  [ ! -e "$L_T" ]   || die chistka "stale lock мёртвого владельца не убран при старте нового прогона"
  [ ! -e "$S/run-$DPID" ] || die chistka "мусорный каталог run-<мёртвый pid> не убран при старте"
  [ ! -e "$JUNK" ]  || die chistka "base64-мусор убитого прогона не убран при старте (Н-48-5)"
  [ -e "$L_F" ]     || die chistka "чистка снесла чужой live lock другого дерева — неприкосновенно всё, чей владелец жив"
  ok '(chistka) мусор мёртвых владельцев убран, неприкосновенное цело'
fi

# ── (pgid) чужой процесс с именем раннера переживает прогон и отказ ────────────
if want pgid; then
  D="$WORK/verify_antiplacebo-decoy.sh"
  printf '#!/usr/bin/env bash\nsleep 30\n' > "$D"; chmod +x "$D"
  setsid bash "$D" >/dev/null 2>&1 & DECOY_PID=$!
  wait_alive "$DECOY_PID" 3 || die pgid "decoy-процесс не поднялся — тест недостоверен"
  S="$WORK/s-pgid"; T="$WORK/toy-pgid"
  mkdir -p "$S"; build_toy "$T" 2; T="$(cd "$T" && pwd)"
  L="$(lock_path "$S" "$T")"
  VERIFY_ANTIPLACEBO_SCRATCH="$S" bash "$VA" "$T" >"$WORK/pg-r1.out" 2>&1 &
  RUN1_PID=$!
  wait_lock "$L" 6 || true
  VERIFY_ANTIPLACEBO_SCRATCH="$S" bash "$VA" "$T" >"$WORK/pg-r2.out" 2>&1
  wait "$RUN1_PID" 2>/dev/null; RUN1_PID=""
  kill -0 "$DECOY_PID" 2>/dev/null \
    || die pgid "раннер убил чужой процесс, найденный по имени (decoy «verify_antiplacebo-decoy» мёртв) — kill только по pgid своих потомков, pkill -f запрещён (Н-48-4)"
  ok '(pgid) name-decoy пережил прогон и второй запуск — убийство только по pgid своих'
fi

# ── (norma) полный текст приёмки судьи v2 в AGENTS.md — три строки дословно ─────
if want norma; then
  A="$ROOT/AGENTS.md"
  [ -f "$A" ] || die norma "нет $A — форму нормы проверять не по чему"
  body="$(cat "$A")"
  has 'ПРИЁМКА-СУДЬИ (v2' "$body" \
    || die norma "в AGENTS.md нет маркера приёмки судьи v2 «ПРИЁМКА-СУДЬИ (v2 …» — судье обязан назначаться scoped-регресс затронутых барьеров, полный прогон — CI (Н-48-1)"
  # ПОЛНЫЙ текст (§Предмет А.1) — дословно, тремя строками: две подстроки проходили
  # и противоположную по смыслу норму (обход круга 1 критика).
  norm='ПРИЁМКА-СУДЬИ (v2, Н-48): судья (критик/адверсарий/ревьюер) гоняет ТОЛЬКО scoped-регресс
затронутых барьеров (`verify_antiplacebo --scope <ключ>`) и git-diff неизменности
frozen-барьеров; полный прогон — только CI, от судьи он не требуется.'
  has "$norm" "$body" \
    || die norma "норма приёмки судьи v2 лежит в AGENTS.md НЕ дословно — барьер пинует полный трёхстрочный текст «ПРИЁМКА-СУДЬИ (v2, Н-48) … от судьи он не требуется.» из §Предмет А.1; две подстроки проходили и противоположную норму «судья обязан гонять полный прогон» (обход круга 1 критика, Н-48-1)"
  ok '(norma) AGENTS.md несёт полный текст приёмки судьи v2 (scoped-регресс + git-diff, полный — CI)'
fi

# ── (carveout) правило 16 сохраняет carve-out для scratch раннера ──────────────
if want carveout; then
  A="$ROOT/AGENTS.md"
  [ -f "$A" ] || die carveout "нет $A — форму нормы проверять не по чему"
  has 'ИСКЛЮЧЕНИЕ (carve-out' "$(cat "$A")" \
    || die carveout "в AGENTS.md нет «ИСКЛЮЧЕНИЕ (carve-out» у правила 16 — scratch раннера снова без легального места вне стерегомого дерева (коммит 1737953)"
  has 'VERIFY_ANTIPLACEBO_SCRATCH' "$(cat "$A")" \
    || die carveout "carve-out есть, но переменная VERIFY_ANTIPLACEBO_SCRATCH не названа — норма и предмет расходятся"
  ok '(carveout) правило 16 сохраняет исключение для scratch раннера'
fi
# ── (a010) пометка v+1 у §Приёмка п.8 контракта 010 ────────────────────────────
if want a010; then
  f="$(find "$ROOT/contracts" -maxdepth 1 -name '010-*.md' 2>/dev/null | sort | sed -n 1p)"
  [ -n "$f" ] || die a010 "в $ROOT/contracts нет 010-*.md — аннотировать нечего (не то дерево?)"
  has 'отменено грилингом 2026-08-24' "$(cat "$f")" \
    || die a010 "§Приёмка п.8 контракта 010 не помечен «отменено грилингом 2026-08-24» — замороженный текст требует от судьи полный прогон (Н-48), пометка v+1 не внесена"
  ok '(a010) у п.8 контракта 010 стоит пометка v+1 (грилинг 2026-08-24)'
fi

kill -9 -- "-$DECOY_PID" 2>/dev/null; DECOY_PID=""
kill -9 -- "-$FOREIGN_PID" 2>/dev/null; FOREIGN_PID=""
printf 'check_runner_hygiene: ветви «%s» зелены\n' "$WANT" >&2
exit 0
