#!/usr/bin/env bash
# НЕ БАРЬЕР: эталон ГИГИЕНЫ раннера (контракт 011, тест-актив для check_runner_hygiene).
#
# Реализует ПИННОВАННЫЙ контрактом 011 API гигиены `scripts/verify_antiplacebo.sh` вокруг
# МИНИМАЛЬНОГО наблюдаемого контракта работы (находка 2 адверсария, круг 2): эталон
# ФАКТИЧЕСКИ исполняет каждую фикстуру дерева — честный зелёный вызов барьера (маркер),
# порча (маркер снят), повторный красный вызов, — клиентом $BARRIER, копирующим барьер
# в BARRIER_ROOT (как ap_run настоящего раннера). Настоящий предмет несёт ту же
# дисциплину вокруг полной пачки с учётом вызовов и повтором проверяющего; здесь
# дисциплина выделена в чистом виде, чтобы ЗЕЛЁНЫЙ контроль барьера не зависел от
# предмета (прецедент — `fixtures/check_scoped_run/_ref_va.sh`). Кнопка REF_HOLD (сек)
# держит «работу» на месте, где у настоящего раннера гоняются фикстуры: барьеру нужно
# окно, в котором lock жив.
#
# API дословно из контракта 011 §Предмет:
#   VERIFY_ANTIPLACEBO_SCRATCH — корень scratch; умолчание — mktemp под ${TMPDIR:-/tmp}
#         (carve-out правила 16, РАЗРЕШИЛ-ВЛАДЕЛЕЦ 2026-08-24);
#   lock — $SCRATCH/verify_antiplacebo-<hash8>.lock, где hash8 — первые 8 hex sha256
#         КАНОНИЧЕСКОГО пути корня проверяемого дерева (разные деревья не блокируют друг
#         друга: взаимная порча снапшотов измерена только для одного дерева, Н-48-3);
#   содержимое lock — «<pid> <pgid> <epoch>»; захват атомарен и БЕСШОВЕН —
#         create-с-содержимым: `ln` заполненного темпа (пустого lock не бывает;
#         окно «создан пустой — заполняется» — обход круга 2 критика);
#   живой владелец → rc 3 и stderr «занят: …»; существующий прогон НЕ трогается;
#   стартовая чистка — lock-файлы и run-<pid> каталоги МЁРТВЫХ владельцев плюс файлы,
#         не являющиеся ни lock, ни run-каталогом живого pid (base64-обрывки путей);
#         чужой live lock другого дерева неприкосновенен;
#   раннер не убивает НИЧЕГО, кроме собственных потомков по pgid; pkill -f по имени
#         запрещён (Н-48-4: pkill убивал чужие прогоны).
set -uo pipefail

ROOT_ARG="${1:-}"
[ -n "$ROOT_ARG" ] || { echo 'ОТКАЗ: нужен аргумент — корень проверяемого дерева' >&2; exit 1; }
ROOT="$(cd "$ROOT_ARG" 2>/dev/null && pwd)" || { echo "ОТКАЗ: корня нет: $ROOT_ARG" >&2; exit 1; }

SCRATCH="${VERIFY_ANTIPLACEBO_SCRATCH:-}"
if [ -z "$SCRATCH" ]; then
  SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/verify_antiplacebo.XXXXXX")" || {
    echo 'ОТКАЗ: scratch не создать' >&2; exit 2; }
fi

# Явный scratch обязан разрешаться ВНЕ стерегомого дерева — «в любом режиме»
# (§Предмет Б.1 контракта 011; находка 1 адверсария, круг 1). Канонизация БЕЗ создания:
# спуск до существующего предка + pwd -P — сам mkdir до проверки уже загрязнил бы
# дерево. Внутри корня — именованный отказ (код 2); вынос скратча наружу — равным
# образом честное лекарство, барьерная ветвь scratchexpl пинует только чистоту дерева.
case "$SCRATCH" in /*) ;; *) SCRATCH="$PWD/$SCRATCH" ;; esac
_p="$SCRATCH"; _tail=""
while [ ! -d "$_p" ] && [ -n "$_p" ]; do _tail="/${_p##*/}${_tail}"; _p="${_p%/*}"; done
if [ -n "$_p" ]; then
  _canon="$(cd "$_p" && pwd -P)$_tail"
  _rootp="$(cd "$ROOT" 2>/dev/null && pwd -P)"
  case "$_canon" in
    "$_rootp"|"$_rootp"/*)
      printf 'ОТКАЗ: явный scratch внутри стерегомого дерева: %s (корень %s) — scratch обязан жить вне дерева в любом режиме\n' "$_canon" "$ROOT" >&2
      exit 2 ;;
  esac
  # ЛЕКАРСТВО от symlink-подмены МЕЖДУ канонизацией и созданием (находка 1 адверсария,
  # круг 2): дальше скратч живёт по КАНОНИЧЕСКОМУ физическому пути — создание и все
  # артефакты (lock, run-) идут от уже разрешённого предка и НЕ повторяют обход
  # атакуемого имени. Отдельный `mkdir -p "$SCRATCH"` по исходной строке разрешал бы
  # symlink заново — ветвь tocou предъявляет это красным.
  SCRATCH="$_canon"
fi
mkdir -p "$SCRATCH" 2>/dev/null || { echo "ОТКАЗ: scratch не создать: $SCRATCH" >&2; exit 2; }

hash8="$(printf '%s' "$ROOT" | sha256sum | cut -c1-8)"
LOCK="$SCRATCH/verify_antiplacebo-$hash8.lock"

# ── стартовая чистка: только артефакты МЁРТВЫХ владельцев ──────────────────────
for l in "$SCRATCH"/verify_antiplacebo-*.lock; do
  [ -f "$l" ] || continue
  read -r pid _ < "$l" || true
  if [ -n "${pid:-}" ] && ! kill -0 "$pid" 2>/dev/null; then
    rm -f "$l"
    rm -rf "$SCRATCH/run-$pid" 2>/dev/null || true
  fi
done
for f in "$SCRATCH"/*; do
  [ -e "$f" ] || continue
  b="${f##*/}"
  case "$b" in
    verify_antiplacebo-*.lock) ;;          # lock (в т.ч. чужой live) — не трогаем
    run-*) pid="${b#run-}"
           kill -0 "$pid" 2>/dev/null || rm -rf "$f" ;;
    *) rm -rf "$f" ;;                       # base64-обрывки и прочий мусор убитых прогонов
  esac
done

# ── захват lock: create-с-содержимым (ln темпа) — пустого lock не бывает ────────
# ln(2) атомарен: lock становится видимым УЖЕ с тремя полями, и параллельный старт
# никогда не наблюдает пустой lock, который можно счесть «владелец неназван»,
# удалить и захватить повторно (обход круга 2: два одновременных старта — оба rc=0).
# Темп — БЕЗ ведущей точки: стартовая чистка убирает его как мусор, если владелец
# убит посреди захвата.
LOCKTMP="$SCRATCH/locknew-$$"
grabbed=0
try=0
while [ "$try" -lt 40 ]; do
  try=$((try + 1))
  printf '%s %s %s\n' "$$" "$(ps -o pgid= -p "$$" | tr -d ' ')" "$(date +%s)" > "$LOCKTMP"
  if ln "$LOCKTMP" "$LOCK" 2>/dev/null; then
    grabbed=1
    break
  fi
  # lock существует: живой владелец → именованный отказ, существующий не трогаем
  pid=""
  read -r pid _ < "$LOCK" 2>/dev/null || true
  if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
    printf 'занят: verify_antiplacebo уже идёт над этим деревом (pid %s, корень %s) — второй прогон не запускается\n' \
      "$pid" "$ROOT" >&2
    exit 3
  fi
  if [ -z "$pid" ]; then
    # пустой lock собственным захватом не создаётся (ln бесшовен) — это чужой
    # обрывок; короткое ожидание и повтор закрывают гонку с медленным писателем
    sleep 0.1
    continue
  fi
  rm -f "$LOCK"    # владелец мёртв — чистка выше не знала формата, добираем здесь
  rm -rf "$SCRATCH/run-$pid" 2>/dev/null || true
done
rm -f "$LOCKTMP"
if [ "$grabbed" != 1 ]; then
  printf 'занят: lock %s не удалось захватить — параллельный прогон или нечитаемый lock\n' "$LOCK" >&2
  exit 3
fi

RUN="$SCRATCH/run-$$"
mkdir -p "$RUN"
release() { rm -rf "$RUN"; rm -f "$LOCK"; }
trap release EXIT
printf 'run %s: работа раннера\n' "$RUN" > "$RUN/log"

# ── минимальный наблюдаемый контракт (находка 2 адверсария, круг 2) ──────────────
# ФАКТИЧЕСКИ исполняем каждую фикстуру дерева: честный ЗЕЛЁНЫЙ вызов барьера (маркер
# есть) → порча (маркер снят фикстурой) → повторный КРАСНЫЙ вызов. Свидетельства пишут
# сами барьеры/фикстуры состава (внешние журналы, вшитые в их текст при сборке).
# Учёт вызовов и повтор проверяющего — дисциплина НАСТОЯЩЕГО раннера; эталону
# достаточно самого цикла. Группу фикстуры гасим после wait — как настоящий раннер.
for b in "$ROOT"/scripts/check_*.sh; do
  [ -e "$b" ] || continue
  rb="$(basename "$b")"; bk="$(basename "$b" .sh)"
  for c in "$ROOT/fixtures/$bk"/case_*.sh; do
    [ -e "$c" ] || continue
    d="$RUN/fix-$bk-$(basename "$c" .sh)"
    mkdir -p "$d/w"
    cp "$b" "$d/real-$rb"
    cat > "$d/barrier" <<EOF
#!/usr/bin/env bash
# клиент \$BARRIER эталона: копия настоящего барьера в BARRIER_ROOT (как ap_run)
[ -n "\${BARRIER_ROOT:-}" ] || { echo 'ОТКАЗ: нужен BARRIER_ROOT' >&2; exit 125; }
mkdir -p "\$BARRIER_ROOT/scripts"
cp '$d/real-$rb' "\$BARRIER_ROOT/scripts/$rb"
exec bash "\$BARRIER_ROOT/scripts/$rb" "\$@"
EOF
    chmod +x "$d/barrier"
    setsid env -u BARRIER_ROOT BARRIER="$d/barrier" WORK="$d/w" REPO="$ROOT" \
      HOME="$d/w" TMPDIR="$d/w" PATH="$PATH" bash "$c" > "$d/case.out" 2>&1 & fpid=$!
    wait "$fpid" || true
    kill -- "-$fpid" 2>/dev/null || true
  done
done

sleep "${REF_HOLD:-2}"
exit 0
