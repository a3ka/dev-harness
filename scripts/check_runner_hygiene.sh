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
#             (байт-в-байт до/после); первый прогон НЕ тронут (rc=0) — Н-48-3/4;
#   (race)    два ОДНОВРЕМЕННЫХ старта над одним деревом и одним scratch: ровно один
#             rc=3 «занят» и один rc=0, и lock НИКОГДА не наблюдается пустым — захват
#             обязан создавать файл УЖЕ заполненным (create-с-содержимым: `ln` темпа;
#             `set -C` с отдельной записью полей открывает пустое окно). Окно «создан
#             пустой — заполняется» позволяет второму старту счесть владельца
#             неназванным, удалить lock и захватить его: два rc=0 — обход круга 2 (Н-48-3);
#   (scratch) за время прогона (с явной VERIFY_ANTIPLACEBO_SCRATCH) в стерегомом дереве
#             НЕ появляется новых путей и НЕ меняется содержимое существующих — ни во
#             время (РЕКУРСИВНЫЙ зонд каждые 0.1с: слепок состава путей + тип + размер
#             и байтовый слепок; ловит и «подметание trap'ом», и работу во ВЛОЖЕННОМ
#             подкаталоге существующего поддерева с уборкой до выхода — РЕШЕНИЕ арбитра
#             по контракту 011, часть 2а), ни после (метаданные + байты) — Н-48-2/5;
#   (scratchdef) ПУСТАЯ VERIFY_ANTIPLACEBO_SCRATCH → под подставным ${TMPDIR:-/tmp}
#             обязан появиться скратч, НЕСУЩИЙ пиннованный lock
#             `verify_antiplacebo-<hash8>.lock` этого дерева (найденный путь связан
#             с работой раннера, а не пустая приманка), и стерегомое дерево чисто
#             И ВО ВРЕМЯ прогона (тот же РЕКУРСИВНЫЙ зонд: «поработал в дереве —
#             подмёл trap'ом или rm до выхода», в т.ч. во вложенном подкаталоге), и
#             после (байтовый слепок) — обходы кругов 1–3 критика (Н-48-2);
#   (scratchexpl) ЯВНЫЙ VERIFY_ANTIPLACEBO_SCRATCH, разрешающийся ВНУТРИ дерева, —
#             дерево чисто и во время, и после (тот же рекурсивный зонд): честны ОБА
#             лекарства — именованный отказ (канонизация pwd -P + сравнение с корнем
#             по границе пути) и вынос скратча наружу; код предмета не пинуется —
#             «в любом режиме» §Предмет Б.1 (находка 1 адверсария, круг 1: ветви
#             scratch/scratchdef подают только внешний скратч и дефект не наблюдали);
#   (sostav)  гигиена проявляется на НЕПРЕДСКАЗУЕМОМ составе дерева (3 барьера ×
#             2 честные фикстуры, одноразовые имена — НЕ сводимо к build_toy
#             check_a/case_a): lock этого дерева и run-каталог в явном скратче,
#             дерево чисто и во время, и после; ловит обманку «для известной
#             игрушки — эталон, иначе успех» (находка 2 адверсария, круг 1);
#             поведенческий цикл фикстур — зона check_scoped_run (заморожен 006);
#   (chistka) старт нового прогона убирает артефакты МЁРТВЫХ владельцев (stale lock,
#             run-<мёртвый pid>, base64-мусор) и НЕ трогает чужой live lock другого дерева;
#   (pgid)    раннер не убивает чужие процессы по имени: decoy с «verify_antiplacebo» в
#             cmdline переживает и полный прогон, и отказ по lock — Н-48-4. ОХРАНА: на
#             текущем дереве зелена (раннер pkill не делает); красное предъявляется обманкой;
#   (norma)   AGENTS.md несёт ПОЛНЫЙ текст приёмки судьи v2 — три строки ДОСЛОВНО из
#             §Предмет А.1 контракта 011 — ВНУТРИ раздела «Воркфлоу майлстоуна», причём
#             разделом является только текст ВНЕ code fence (строки ```/~~~ в первой
#             колонке переключают fence-состояние; строка «## …» внутри fence заголовком
#             в Markdown не является — обход круга 3, РЕШЕНИЕ арбитра), и маркеры
#             «ПРИЁМКА-СУДЬИ (v2» / «полный прогон — только CI» ЕДИНСТВЕННЫ во всём файле
#             (блок в архиве отклонённых + противоположное правило в разделе; второе
#             вхождение маркера рядом с нормой — обходы кругов 1–2 критика) — Н-48-1;
#   (carveout)AGENTS.md несёт carve-out правила 16 («ИСКЛЮЧЕНИЕ (carve-out» +
#             «VERIFY_ANTIPLACEBO_SCRATCH», коммит 1737953). ОХРАНА: на текущем дереве
#             зелена; красное предъявляется обманкой;
#   (a010)    contracts/010-*.md несёт у §Приёмка п.8 пометку «отменено грилингом
#             2026-08-24» — замороженный текст требовал от судьи полный прогон;
#   (porjadok) акты 010-v2 разведены по ИСТОРИИ коммитов: последний коммит, тронувший
#             contracts/010-*.md (аннотация, акт (i)), — ДРУГОЙ и БОЛЕЕ РАННИЙ коммит,
#             чем добавивший verdicts/critic/contracts-010-v2.md с первой строкой
#             accept (акт (ii)); И состав того же коммита A несёт contracts/010-*.md,
#             AGENTS.md и scripts/verify_antiplacebo.sh, а A:AGENTS.md — маркер
#             «ПРИЁМКА-СУДЬИ (v2» («всё одним коммитом», «вердикт раньше аннотации» —
#             обходы круга 2; «пачка доехала после вердикта» — обход круга 3, РЕШЕНИЕ
#             арбитра по контракту 011).
#
# Образец — check_scoped_run/check_judge_gate: предмет пишет ИСПОЛНИТЕЛЬ по зоне; этот
# барьер, `fixtures/check_runner_hygiene/` (case_*.sh + эталон `_ref_runner.sh`) — АРХИТЕКТОРА.
# Фикстуры предъявляют барьер красным, подавая сломанные раннеры/нормы в подставной корень
# (green-root → red-root). КРАСНОЕ ПРОТИВ ТЕКУЩЕГО ДЕРЕВА (до правки implementer по
# находке 1 адверсария, круг 1): scratchexpl красна — раннер принимает явный in-tree
# scratch буквально; остальные ветви зелены (предмет реализован), их красное предъявлено
# обманками в фикстурах.
#
#   bash scripts/check_runner_hygiene.sh [<корень>] [<ветвь>]
#     <корень> — где лежит scripts/verify_antiplacebo.sh, AGENTS.md, contracts/
#                (умолчание — корень репозитория); ветвь porjadok дополнительно требует,
#                чтобы корень был git-репозиторием (порядок коммитов читается из истории);
#     <ветвь>  — одна из: lock race scratch scratchdef scratchexpl sostav chistka pgid
#                norma carveout a010 porjadok (умолчание — все).
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

KNOWN="lock race scratch scratchdef scratchexpl sostav chistka pgid norma carveout a010 porjadok"
if [ "$WANT" != all ]; then
  f=0; for k in $KNOWN; do [ "$WANT" = "$k" ] && f=1; done
  [ "$f" = 1 ] || { printf 'ОТКАЗ диспетчер: неизвестная ветвь «%s» (из: %s)\n' "$WANT" "$KNOWN" >&2; exit 1; }
fi

[ -f "$VA" ] || skip "нет $VA — предмет гигиены отсутствует"
command -v sha256sum >/dev/null 2>&1 || skip "нет sha256sum — hash8 lock-файла не вычислить"
command -v setsid  >/dev/null 2>&1 || skip "нет setsid — decoy-процессы не изолировать"
command -v ln       >/dev/null 2>&1 || skip "нет ln — атомарный create-с-содержимым не предъявить"

# Временное — в ./tmp репозитория (правило 16; carve-out касается ТОЛЬКО раннера).
TMP="$REPO/tmp"; mkdir -p "$TMP" 2>/dev/null || skip "tmp не создать"
WORK="$(mktemp -d "$TMP/check_runner_hygiene.XXXXXX")" || skip "mktemp не смог"
WORK="$(cd "$WORK" && pwd -P)"

RUN1_PID=""; RUN2_PID=""; DECOY_PID=""; FOREIGN_PID=""
cleanup() {
  [ -n "$RUN1_PID" ]    && kill -9 "$RUN1_PID"    2>/dev/null
  [ -n "$RUN2_PID" ]    && kill -9 "$RUN2_PID"    2>/dev/null
  [ -n "$DECOY_PID" ]   && kill -9 -- "-$DECOY_PID" 2>/dev/null
  [ -n "$FOREIGN_PID" ] && kill -9 -- "-$FOREIGN_PID" 2>/dev/null
  rm -rf "$WORK"
}
trap cleanup EXIT

hash8_of()  { printf '%s' "$1" | sha256sum | cut -c1-8; }
lock_path() { printf '%s/verify_antiplacebo-%s.lock' "$1" "$(hash8_of "$2")"; }

# РЕКУРСИВНЫЙ слепок стерегомого дерева (РЕШЕНИЕ арбитра по контракту 011, часть 2а):
# метаданные — состав путей + тип + размер — и байтовый слепок содержимого. Зонды ветвей
# scratch/scratchdef сравнивают ОБЕ меры на каждом тике: работа во ВЛОЖЕННОМ подкаталоге
# существующего поддерева (например scripts/run-work.*) с уборкой до выхода одноуровневым
# списком не видна была вовсе (замер арбитра 3: find -mindepth 1 -maxdepth 1).
# Цена на игрушечном дереве замерена арбитром: метаданные ~25 мс/тик, байты ~79 мс/тик.
snap_meta()  { (cd "$1" && find . -mindepth 1 -printf '%y %p %s\n' | sort); }
snap_bytes() { (cd "$1" && find . -type f -print0 | sort -z | xargs -0 -r sha256sum); }

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

# Игрушечное дерево НЕПРЕДСКАЗУЕМОГО состава: три барьера × две честные фикстуры, имена с
# одноразовыми суффиксами ($$/$RANDOM) — форма НЕ сводима к build_toy (check_a/case_a).
# Находка 2 адверсария (круг 1): обманка «если вход — известная игрушка, исполняю эталон,
# иначе печатаю успех и выхожу 0» проходит все поведенческие ветви, потому что build_toy
# строит ровно ту форму, на которую обманка рассчитана. Против неё — состав, которого
# нельзя предсказать на момент написания обманки.
build_pack() {  # <каталог>
  local r="$1" n k u b m
  mkdir -p "$r/scripts"
  for n in 1 2 3; do
    u="$(printf '%x%x' "$$" "$RANDOM")x$n"   # одноразовый суффикс: не угадать заранее
    b="check_$u"; m="mark_$u"
    mkdir -p "$r/fixtures/$b"
    cat > "$r/scripts/$b.sh" <<EOF
#!/usr/bin/env bash
# Коды возврата: 0 — маркер есть, 1 — нет
d="\$(cd "\$(dirname "\$0")/.." && pwd)"
[ -f "\$d/$m" ] || { echo "нет $m ($b)" >&2; exit 1; }
EOF
    chmod +x "$r/scripts/$b.sh"
    for k in 1 2; do
      cat > "$r/fixtures/$b/case_${u}_$k.sh" <<EOF
# ПРИЧИНА: нет $m ($b)
set -euo pipefail
mkdir -p "\$WORK/w"; touch "\$WORK/w/$m"
BARRIER_ROOT="\$WORK/w" "\$BARRIER"
rm -f "\$WORK/w/$m"
BARRIER_ROOT="\$WORK/w" "\$BARRIER"
EOF
    done
  done
}

# ── (lock) живой владелец → отказ ровно код 3 «занят», чужой lock не тронут ─────
if want lock; then
  S="$WORK/s-lock"; T="$WORK/toy-lock"
  mkdir -p "$S"; build_toy "$T" 2; T="$(cd "$T" && pwd)"
  L="$(lock_path "$S" "$T")"
  VERIFY_ANTIPLACEBO_SCRATCH="$S" bash "$VA" "$T" >"$WORK/lock-r1.out" 2>&1 &
  RUN1_PID=$!
  # Ждём не просто файл, а ЗАПОЛНЕННЫЙ тройкой lock: захват создаёт его УЖЕ с полями
  # (create-с-содержимым, эталон — ln темпа) — пустого lock-файла не бывает вовсе.
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
    || die lock "второй прогон перезаписал либо удалил чужой lock (до отказа: «$(printf '%s' "$lock_before" | tr '\n' ' ')», после: «$(printf '%s' "$lock_after" | tr '\n' ' ')») — атомарный захват не затирает существующий файл; одновременную гонку двух стартов инсценирует ветвь race ниже (§Предмет Б.2, обход круга 1 критика)"
  ok '(lock) трёхпольный lock владельца, отказ код 3 «занят», чужой lock байт-в-байт цел, первый прогон цел (rc=0)'
fi

# ── (race) два ОДНОВРЕМЕННЫХ старта: ровно один rc=3, lock без пустого окна ─────
if want race; then
  S="$WORK/s-race"; T="$WORK/toy-race"
  mkdir -p "$S"; build_toy "$T" 2; T="$(cd "$T" && pwd)"
  L="$(lock_path "$S" "$T")"
  VERIFY_ANTIPLACEBO_SCRATCH="$S" bash "$VA" "$T" >"$WORK/race-a.out" 2>&1 &
  RUN1_PID=$!
  VERIFY_ANTIPLACEBO_SCRATCH="$S" bash "$VA" "$T" >"$WORK/race-b.out" 2>&1 &
  RUN2_PID=$!
  # Зонд каждые 0.02с: lock, существующий БЕЗ трёх полей, — окно «создан пустой —
  # заполняется». Дефект наблюдаем только пока оба старта живы (Н-39).
  empty_win=0; i=0
  while { kill -0 "$RUN1_PID" 2>/dev/null || kill -0 "$RUN2_PID" 2>/dev/null; } && [ "$i" -lt 400 ]; do
    # Читаем СОДЕРЖИМОЕ: cat, успевший после удаления lock'а, выходит ≠0 и не
    # считается (TOCTOU между -e и cat на выходе победителя давал ложное окно);
    # успешное чтение без трёх полей — настоящее пустое окно.
    if lc="$(cat "$L" 2>/dev/null)"; then
      printf '%s\n' "$lc" | grep -Eq '^[0-9]+ [0-9]+ [0-9]+$' || empty_win=1
    fi
    sleep 0.02; i=$((i + 1))
  done
  wait "$RUN1_PID"; RA=$?; RUN1_PID=""
  wait "$RUN2_PID"; RB=$?; RUN2_PID=""
  [ "$empty_win" = 0 ] \
    || die race "lock-файл наблюдался существующим БЕЗ трёх полей во время гонки двух стартов — захват обязан создавать его УЖЕ заполненным (create-с-содержимым: ln заполненного темпа); окно «создан пустой — заполняется» позволяет второму старту счесть владельца неназванным, удалить lock и захватить его (§Предмет Б.2, обход круга 2 критика)"
  n3=0; n0=0
  [ "$RA" = 3 ] && n3=$((n3 + 1)); [ "$RB" = 3 ] && n3=$((n3 + 1))
  [ "$RA" = 0 ] && n0=$((n0 + 1)); [ "$RB" = 0 ] && n0=$((n0 + 1))
  { [ "$n3" = 1 ] && [ "$n0" = 1 ]; } \
    || die race "два одновременных старта над одним деревом и одним scratch вышли кодами $RA и $RB — атомарный захват обязан давать ровно один отказ rc=3 («занят») и один рабочий прогон rc=0 (§Предмет Б.2, обход круга 2 критика: неатомарный раннер даёт два rc=0)"
  if [ "$RA" = 3 ]; then r3out="$(cat "$WORK/race-a.out" 2>/dev/null || true)"; r3tail="$WORK/race-a.out"
  else r3out="$(cat "$WORK/race-b.out" 2>/dev/null || true)"; r3tail="$WORK/race-b.out"; fi
  has 'занят' "$r3out" \
    || die race "отказавший в гонке старт не назвал причину словом «занят» — причина обязана называть предмет (правило 7). Хвост вывода отказавшего: $(tail200 "$r3tail")"
  ok '(race) два одновременных старта: ровно один rc=3 «занят», lock никогда не пуст'
fi

# ── (scratch) стерегомое дерево не меняется ни во время, ни после ──────────────
if want scratch; then
  S="$WORK/s-scratch"; T="$WORK/toy-scratch"
  mkdir -p "$S"; build_toy "$T" 2; T="$(cd "$T" && pwd)"
  base_meta="$(snap_meta "$T")"
  base_bytes="$(snap_bytes "$T")"
  base_paths="$(cd "$T" && find . -mindepth 1 | sort)"
  VERIFY_ANTIPLACEBO_SCRATCH="$S" bash "$VA" "$T" >"$WORK/scr-r1.out" 2>&1 &
  RUN1_PID=$!
  violation=""; i=0
  while kill -0 "$RUN1_PID" 2>/dev/null && [ "$i" -lt 100 ]; do
    if [ "$(snap_meta "$T")" != "$base_meta" ] || [ "$(snap_bytes "$T")" != "$base_bytes" ]; then
      new="$(comm -13 <(printf '%s\n' "$base_paths") \
                     <(printf '%s\n' "$(cd "$T" && find . -mindepth 1 | sort)") | tr '\n' ' ')"
      if [ -n "${new// /}" ]; then violation="${new% }"; else violation="состав путей цел — изменилось содержимое существующих путей"; fi
      break
    fi
    sleep 0.1; i=$((i + 1))
  done
  wait "$RUN1_PID"; R1=$?; RUN1_PID=""
  [ "$R1" = 0 ] || die scratch "прогон упал (rc=$R1) — ветвь про чистоту дерева, а не про отказ предмета. Хвост: $(tail200 "$WORK/scr-r1.out")"
  [ -z "$violation" ] || die scratch "во время прогона в стерегомом дереве появились новые пути ($violation) — scratch раннера обязан жить вне стерегомого дерева (Н-48-2, carve-out правила 16); зонд РЕКУРСИВЕН (состав путей + тип + размер и байты на каждом тике): работа во вложенном подкаталоге существующего поддерева с уборкой до выхода дефект не закрывает — дерево грязно ВО ВРЕМЯ прогона (РЕШЕНИЕ арбитра по контракту 011, часть 2а, обход круга 3)"
  [ ! -e "$T/tmp" ] || die scratch "после прогона в корне дерева остался $T/tmp — артефакты раннера обязаны уходить в \$VERIFY_ANTIPLACEBO_SCRATCH (Н-48-2/5)"
  { [ "$(snap_meta "$T")" = "$base_meta" ] && [ "$(snap_bytes "$T")" = "$base_bytes" ]; } \
    || die scratch "слепок дерева изменился после прогона (рекурсивно: метаданные и байты) — раннер обязан оставить дерево байт-в-байт (Н-48-2)"
  ok '(scratch) дерево нетронуто ни во время прогона, ни после (рекурсивный зонд: состав+тип+размер и байты)'
fi

# ── (scratchdef) ПУСТАЯ VERIFY_ANTIPLACEBO_SCRATCH → скратч под ${TMPDIR:-/tmp} ──
if want scratchdef; then
  T="$WORK/toy-scratchdef"; SD="$WORK/tmpdir-def"
  build_toy "$T" 2; T="$(cd "$T" && pwd)"; mkdir -p "$SD"
  base_meta="$(snap_meta "$T")"; base_bytes="$(snap_bytes "$T")"
  base_paths="$(cd "$T" && find . -mindepth 1 | sort)"
  VERIFY_ANTIPLACEBO_SCRATCH="" TMPDIR="$SD" bash "$VA" "$T" >"$WORK/sd-r1.out" 2>&1 &
  RUN1_PID=$!
  LH="$(hash8_of "$T")"   # hash8 этого дерева: lock обязан жить ВНУТРИ найденного скратча
  seen=0; locked=0; violation=""; i=0
  while kill -0 "$RUN1_PID" 2>/dev/null && [ "$i" -lt 100 ]; do
    if [ -n "$(find "$SD" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]; then seen=1; fi
    if [ -n "$(find "$SD" -mindepth 2 -maxdepth 2 -name "verify_antiplacebo-$LH.lock" -print -quit 2>/dev/null)" ]; then locked=1; fi
    if [ "$(snap_meta "$T")" != "$base_meta" ] || [ "$(snap_bytes "$T")" != "$base_bytes" ]; then
      new="$(comm -13 <(printf '%s\n' "$base_paths") \
                     <(printf '%s\n' "$(cd "$T" && find . -mindepth 1 | sort)") | tr '\n' ' ')"
      if [ -n "${new// /}" ]; then violation="${new% }"; else violation="состав путей цел — изменилось содержимое существующих путей"; fi
      break
    fi
    sleep 0.1; i=$((i + 1))
  done
  wait "$RUN1_PID"; RC=$?; RUN1_PID=""
  [ "$RC" = 0 ] || die scratchdef "прогон упал (rc=$RC) — ветвь про место default-скратча, а не про отказ предмета. Хвост: $(tail200 "$WORK/sd-r1.out")"
  [ "$seen" = 1 ] || die scratchdef "за время прогона под \$TMPDIR не появился скратч — при пустой VERIFY_ANTIPLACEBO_SCRATCH раннер обязан создавать его mktemp -d под \${TMPDIR:-/tmp} (§Предмет Б.1, обход круга 1 критика). Хвост: $(tail200 "$WORK/sd-r1.out")"
  [ -z "$violation" ] || die scratchdef "во время default-прогона в стерегомом дереве появились новые пути ($violation) — при пустой VERIFY_ANTIPLACEBO_SCRATCH раннер обязан работать вне дерева; зонд РЕКУРСИВЕН (состав путей + тип + размер и байты на каждом тике): подметание trap'ом или rm до выхода И работа во вложенном подкаталоге существующего поддерева (например scripts/run-work.*) дефект не закрывают — дерево грязно ВО ВРЕМЯ прогона, и параллельный слепок его видит (Н-48-2; обходы кругов 2–3; рекурсивный зонд — РЕШЕНИЕ арбитра по контракту 011, часть 2а)"
  [ "$locked" = 1 ] || die scratchdef "найденный под \$TMPDIR путь не связан с работой раннера: за время прогона в нём не появился lock «verify_antiplacebo-$LH.lock» этого дерева — это каталог-приманка, а не скратч (§Предмет Б.1/Б.2, обход круга 2 критика)"
  [ ! -e "$T/tmp" ] || die scratchdef "при пустой VERIFY_ANTIPLACEBO_SCRATCH раннер завёл ./tmp внутри дерева — default обязан уходить под \${TMPDIR:-/tmp}, не в дерево (§Предмет Б.1, Н-48-2)"
  { [ "$(snap_meta "$T")" = "$base_meta" ] && [ "$(snap_bytes "$T")" = "$base_bytes" ]; } \
    || die scratchdef "стерегомое дерево изменилось при default-скратче (рекурсивно: метаданные и байты) — артефакты раннера обязаны уходить вне дерева; финальная проверка — байтовая (РЕШЕНИЕ арбитра по контракту 011, часть 2а)"
  ok '(scratchdef) пустая переменная → скратч с lock под ${TMPDIR:-/tmp}; дерево чисто и во время, и после (рекурсивный зонд)'
fi

# ── (scratchexpl) ЯВНЫЙ scratch, разрешающийся ВНУТРИ дерева, — отказ или вне ────
# Находка 1 адверсария (круг 1 по контракту 011): раннер принимает непустой
# VERIFY_ANTIPLACEBO_SCRATCH буквально — без канонизации и сравнения с корнем, — и
# явный in-tree скратч разводит lock/run-каталоги/журналы ПО стерегомому дереву
# (воспроизведено адверсарием на реальном раннере: rc=0, артефакты в $ROOT/tmp).
# Ветви scratch/scratchdef этого не видят: они подают только внешний скратч.
# Код возврата предмета здесь НЕ пинуется: честны ОБА лекарства — именованный отказ
# до создания (рекомендация адверсария) и вынос скратча наружу; предмет обязан лишь
# не загрязнять дерево НИ во время (рекурсивный зонд), ни после (байтовый слепок).
if want scratchexpl; then
  T="$WORK/toy-scratchexpl"
  build_toy "$T" 2; T="$(cd "$T" && pwd)"
  EXPL="$T/tmp/antiplacebo"          # ЯВНАЯ переменная, разрешающаяся ВНУТРИ дерева
  base_meta="$(snap_meta "$T")"; base_bytes="$(snap_bytes "$T")"
  base_paths="$(cd "$T" && find . -mindepth 1 | sort)"
  VERIFY_ANTIPLACEBO_SCRATCH="$EXPL" bash "$VA" "$T" >"$WORK/se-r1.out" 2>&1 &
  RUN1_PID=$!
  violation=""; i=0
  while kill -0 "$RUN1_PID" 2>/dev/null && [ "$i" -lt 100 ]; do
    if [ "$(snap_meta "$T")" != "$base_meta" ] || [ "$(snap_bytes "$T")" != "$base_bytes" ]; then
      new="$(comm -13 <(printf '%s\n' "$base_paths") \
                     <(printf '%s\n' "$(cd "$T" && find . -mindepth 1 | sort)") | tr '\n' ' ')"
      if [ -n "${new// /}" ]; then violation="${new% }"; else violation="состав путей цел — изменилось содержимое существующих путей"; fi
      break
    fi
    sleep 0.1; i=$((i + 1))
  done
  wait "$RUN1_PID"; R1=$?; RUN1_PID=""
  [ -z "$violation" ] \
    || die scratchexpl "при ЯВНОМ in-tree scratch (\$VERIFY_ANTIPLACEBO_SCRATCH=$EXPL) во время прогона в стерегомом дереве появились новые пути ($violation) — явный scratch внутри стерегомого дерева обязан разрешаться именованным ОТКАЗОМ (канонизация pwd -P + сравнение с корнем по границе пути, ДО любого mkdir) либо выносом скратча наружу: «в любом режиме» — §Предмет Б.1 контракта 011 (находка 1 адверсария, круг 1; воспроизведена на реальном раннере)"
  [ ! -e "$T/tmp" ] \
    || die scratchexpl "после прогона/отказа с явным in-tree scratch в корне дерева остался $T/tmp — даже НАЧАТЬ работать по этому пути нельзя: само mkdir уже загрязнение (Н-48-2)"
  { [ "$(snap_meta "$T")" = "$base_meta" ] && [ "$(snap_bytes "$T")" = "$base_bytes" ]; } \
    || die scratchexpl "слепок дерева изменился после прогона с явным in-tree scratch (рекурсивно: метаданные и байты) — дерево байт-в-байт в любом режиме (§Предмет Б.1, Н-48-2)"
  ok '(scratchexpl) явная переменная с in-tree путём не оставила следов: отказ до создания — эталон, вынос наружу — равным образом честен'
fi

# ── (sostav) гигиена проявляется и на НЕПРЕДСКАЗУЕМОМ составе дерева ────────────
# Находка 2 адверсария (круг 1): раннер-обманка, честный ровно на известной форме
# игрушки (check_a/case_a — делегирует эталону) и печатающий «complete verification
# accepted» + rc=0 на любом другом составе, проходит ветви lock/race/scratch/
# scratchdef/chistka/pgid — все они зовут его только на build_toy. Здесь состав
# НЕПРЕДСКАЗУЕМ (build_pack), и на нём обязаны проявиться признаки честной работы,
# которые пинует scratchdef: lock <hash8> ЭТОГО дерева в скратче и run-каталог.
# Эталон _ref_runner зелён: его гигиена не зависит от формы дерева. Код предмета —
# ровно 0: отказ на честном составе означал бы, что ветвь проверяет не гигиену.
if want sostav; then
  S="$WORK/s-sostav"; T="$WORK/toy-sostav"
  mkdir -p "$S"; build_pack "$T"; T="$(cd "$T" && pwd)"
  L="$(lock_path "$S" "$T")"
  base_meta="$(snap_meta "$T")"; base_bytes="$(snap_bytes "$T")"
  VERIFY_ANTIPLACEBO_SCRATCH="$S" bash "$VA" "$T" >"$WORK/sos-r1.out" 2>&1 &
  RUN1_PID=$!
  seen_lock=0; seen_run=0; violation=""; i=0
  while kill -0 "$RUN1_PID" 2>/dev/null && [ "$i" -lt 200 ]; do
    [ -f "$L" ] && seen_lock=1
    [ -n "$(find "$S" -mindepth 1 -maxdepth 1 -type d -name 'run-*' -print -quit 2>/dev/null)" ] && seen_run=1
    if [ "$(snap_meta "$T")" != "$base_meta" ] || [ "$(snap_bytes "$T")" != "$base_bytes" ]; then
      violation=1
      break
    fi
    sleep 0.05; i=$((i + 1))
  done
  wait "$RUN1_PID"; RC=$?; RUN1_PID=""
  [ "$RC" = 0 ] \
    || die sostav "прогон на непредсказуемом составе упал (rc=$RC) — ветвь про проявление гигиены на любом составе, а не про отказ предмета. Хвост: $(tail200 "$WORK/sos-r1.out")"
  [ "$seen_lock" = 1 ] \
    || die sostav "lock «$(basename "$L")» не наблюдался на непредсказуемом составе в явном скратче за время прогона — гигиена раннера не проявляется вне известных игрушек: обманка «для известного входа — эталон, иначе успех» проходит все ветви на build_toy и именно здесь обязана краснеть (находка 2 адверсария, круг 1)"
  [ "$seen_run" = 1 ] \
    || die sostav "run-каталог не наблюдался в явном скратче за время прогона на непредсказуемом составе — нет признака живой работы раннера (run-<pid> под \$VERIFY_ANTIPLACEBO_SCRATCH, §Предмет Б.1); «успех без работы» — находка 2 адверсария, круг 1"
  [ -z "$violation" ] \
    || die sostav "во время прогона на непредсказуемом составе стерегомое дерево изменилось — гигиена обязана держать дерево чистым на ЛЮБОМ составе, а не только на известной игрушке (§Предмет Б.1, Н-48-2)"
  { [ "$(snap_meta "$T")" = "$base_meta" ] && [ "$(snap_bytes "$T")" = "$base_bytes" ]; } \
    || die sostav "слепок дерева изменился после прогона на непредсказуемом составе (рекурсивно: метаданные и байты) — Н-48-2"
  ok '(sostav) непредсказуемый состав: lock дерева и run-каталог в скратче, дерево нетронуто'
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
  # РАЗДЕЛ (обходы кругов 2–3): дословный блок обязан жить ВНУТРИ раздела «Воркфлоу
  # майлстоуна», и разделом является только текст ВНЕ code fence — строки ```/~~~ в
  # первой колонке переключают fence-состояние, и ни граница раздела, ни содержимое
  # внутри fence не читаются: строка «## Воркфлоу майлстоуна» внутри архивного fence
  # заголовком в Markdown не является (обход круга 3 критика; fence-состояние —
  # РЕШЕНИЕ арбитра по контракту 011, вопрос 1). Границы раздела — от его заголовка
  # до следующего «## » вне fence; «###» внутрь входят. Остаток cognitive-only:
  # экзотика Markdown (fence с отступом 1–3 пробела, fence внутри blockquote/списка,
  # HTML-блоки) гейтом не разбирается — ловец судья, читающий AGENTS.md глазами.
  sect="$(printf '%s\n' "$body" | awk '
    /^(```+|~~~+)/ { fence = !fence; next }
    fence { next }
    /^## Воркфлоу майлстоуна[[:space:]]*$/ { f = 1; next }
    f && /^## / { f = 0 }
    f')"
  has "$norm" "$sect" \
    || die norma "дословный блок нормы лежит ВНЕ раздела «Воркфлоу майлстоуна» — наличие текста в другом месте (архив отклонённых предложений, цитата, а также ЛЮБОЕ его представление внутри code fence: строка «## …» внутри fence заголовком в Markdown не является) не вносит норму в уставный раздел, а сам раздел может нести противоположное правило (обходы кругов 2–3 критика; fence-состояние в извлечении — РЕШЕНИЕ арбитра по контракту 011; Н-48-1)"
  # ЕДИНСТВЕННОСТЬ маркеров (обход круга 2): второе вхождение маркера может
  # отменять смысл нормы («…неверно; судья обязан гонять полный прогон»).
  m1="$(printf '%s\n' "$body" | grep -o 'ПРИЁМКА-СУДЬИ (v2' | wc -l | tr -d ' ')"
  m2="$(printf '%s\n' "$body" | grep -o 'полный прогон — только CI' | wc -l | tr -d ' ')"
  { [ "$m1" = 1 ] && [ "$m2" = 1 ]; } \
    || die norma "маркеры нормы не единственны в AGENTS.md: «ПРИЁМКА-СУДЬИ (v2» — $m1 вхождений, «полный прогон — только CI» — $m2; норма обязана быть ЕДИНСТВЕННЫМ вхождением каждого маркера — второе может отменять её смысл (обход круга 2 критика, Н-48-1)"
  ok '(norma) полный текст в разделе «Воркфлоу майлстоуна»; маркеры единственны во всём файле'
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

# ── (porjadok) акты 010-v2 разведены по истории коммитов ────────────────────────
if want porjadok; then
  command -v git >/dev/null 2>&1 || skip "нет git — порядок актов 010-v2 прочитать нечем"
  top="$(git -C "$ROOT" rev-parse --show-toplevel 2>/dev/null || true)"
  [ -n "$top" ] || skip "$ROOT не git-репозиторий — порядок актов 010-v2 проверить нечем"
  [ "$(cd "$top" 2>/dev/null && pwd -P)" = "$(cd "$ROOT" && pwd -P)" ] \
    || skip "корень $ROOT — подкаталог репозитория $(cd "$top" 2>/dev/null && pwd -P): история актов 010-v2 читается только от корня репозитория"
  f010="$(find "$ROOT/contracts" -maxdepth 1 -name '010-*.md' 2>/dev/null | sort | sed -n 1p)"
  [ -n "$f010" ] || die porjadok "в $ROOT/contracts нет 010-*.md — аннотировать нечего (не то дерево?)"
  VERD="verdicts/critic/contracts-010-v2.md"
  A="$(git -C "$ROOT" log --format=%H -1 -- "${f010#"$ROOT"/}" 2>/dev/null || true)"
  [ -n "$A" ] || die porjadok "контракт 010 не появлялся в истории git — аннотация v+1 не внесена (§Предмет А.2, акт (i))"
  V="$(git -C "$ROOT" log --format=%H -1 --diff-filter=A -- "$VERD" 2>/dev/null || true)"
  [ -n "$V" ] || die porjadok "вердикт 010-v2 не закоммичен — файл $VERD не появлялся в истории (§Предмет А.2, акт (ii): critic ОТДЕЛЬНЫМ кругом судит закоммиченный блоб; обход круга 2: «не создавать вердикт 010-v2»)"
  [ "$A" != "$V" ] \
    || die porjadok "аннотация 010 и вердикт 010-v2 внесены ОДНИМ коммитом (${A:0:8}) — акт (i) implementer и акт (ii) critic обязаны быть РАЗНЫМИ коммитами: критик судит ЗАКОММИЧЕННЫЙ блоб, а не вносит его сам (§Предмет А.2, обход круга 2 критика)"
  git -C "$ROOT" merge-base --is-ancestor "$A" "$V" 2>/dev/null \
    || die porjadok "вердикт 010-v2 (${V:0:8}) закоммичен ДО аннотации 010 (${A:0:8}) — критик судил блоб, которого ещё не было, либо аннотация менялась после вердикта (§Предмет А.2 «тот же круг» — обход кругов 1–2 критика)"
  vf="$ROOT/$VERD"
  [ -f "$vf" ] || die porjadok "файла $VERD нет на дереве — вердикт удалён после коммита, акт (ii) не предъявить"
  first="$(sed -n 1p "$vf" | tr -d '\r')"
  first="${first#"${first%%[![:space:]]*}"}"
  first="${first%"${first##*[![:space:]]}"}"
  [ "$first" = accept ] \
    || die porjadok "первая строка $VERD — «$first», а не accept: вердикт, не разрешающий судить закоммиченный блоб, актом (ii) не является (правило 10)"
  # СОСТАВ ПАЧКИ (РЕШЕНИЕ арбитра по контракту 011, вопрос 3 — обход круга 3 «пачка
  # доехала после вердикта»: аннотация первым коммитом, accept-вердикт вторым, раннер
  # и норма AGENTS.md третьим, уже ПОСЛЕ вердикта): коммит A обязан своим составом
  # нести И contracts/010-*.md, И AGENTS.md, И scripts/verify_antiplacebo.sh, а
  # A:AGENTS.md — маркер «ПРИЁМКА-СУДЬИ (v2»: критик судит УЖЕ закоммиченный полный
  # блоб, а не смотрит, как половина предмета доезжает после его вердикта.
  comp="$(git -C "$ROOT" show --format= --name-only "$A" 2>/dev/null | sort -u || true)"
  miss=""
  for need in "contracts/$(basename "$f010")" AGENTS.md scripts/verify_antiplacebo.sh; do
    printf '%s\n' "$comp" | grep -qxF "$need" || miss="$miss $need"
  done
  [ -z "$miss" ] \
    || die porjadok "состав коммита A (${A:0:8}, последнего, тронувшего contracts/010-*.md) не несёт:$miss — акт (i) обязан вносить аннотацию 010, норму AGENTS.md и раннер ОДНОЙ пачкой ДО круга критика: «пачка доехала после вердикта» — обход круга 3 (РЕШЕНИЕ арбитра по контракту 011, §Предмет А.2 механика-3)"
  agents_A="$(git -C "$ROOT" show "$A:AGENTS.md" 2>/dev/null || true)"
  [ -n "$agents_A" ] \
    || die porjadok "в коммите A (${A:0:8}) нет AGENTS.md — пачка акта (i) обязана везти устав с нормой приёмки судьи v2, а не докладывать его после вердикта (РЕШЕНИЕ арбитра по контракту 011)"
  has 'ПРИЁМКА-СУДЬИ (v2' "$agents_A" \
    || die porjadok "AGENTS.md в коммите A (${A:0:8}) не несёт маркер «ПРИЁМКА-СУДЬИ (v2» — пачка обязана везти НОРМУ, а не касание файла: норма, доехавшая после вердикта критика, судимой не была (РЕШЕНИЕ арбитра по контракту 011)"
  ok '(porjadok) аннотация 010 и вердикт 010-v2 — разные коммиты в верном порядке; состав пачки A полон, маркер в A:AGENTS.md есть; вердикт accept'
fi

kill -9 -- "-$DECOY_PID" 2>/dev/null; DECOY_PID=""
kill -9 -- "-$FOREIGN_PID" 2>/dev/null; FOREIGN_PID=""
printf 'check_runner_hygiene: ветви «%s» зелены\n' "$WANT" >&2
exit 0
