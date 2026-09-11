#!/usr/bin/env bash
# КРАСНОЕ 025-дыра-B — FAIL-CLOSED непиннованной записи. Слово владельца
# 2026-09-11, дословно: «025 дыра B — FAIL-CLOSED: 'непиннованный ребёнок
# ДЕФОЛТ-ЗАПРЕЩЁН на чекаут-запись (скратч/artifact), НЕ свободные абсолюты
# (fail-open против принципа; свободный абсолют непиннованного = корень А-72).
# Пиннуй зонд-ребёнка'.»
#
# ПЕРЕКРЫВАЕТ предъявление 51ce9f6 (B-025-5): та форма предъявляла границу
# «свободный абсолют у непиннованного разрешён» — ДЕФОЛТ-РАЗРЕШЕНИЕ (fail-open)
# словом владельца запрещено; развилка А-125 закрыта вариантом (а), расширенным
# на ВСЕ цели вне скратч/artifact. Семантика: непиннованная сессия
# (worktree:null — главная ИЛИ непиннованный ребёнок; судья их не различает)
# пишет ТОЛЬКО в allowlist Г3 = ТОЧНО {dev-harness-verify, artifact://}:
# внутренние URI (local:// и прочие) словом владельца НЕ названы → блок
# (URI-дыра критика d141dd9); всякая иная цель — чекаут, чужой каталог,
# свободный абсолют, внутренний URI — block
# Н-85. Судья «чекаутность» цели не различает и не обязан: fail-closed.
# В-пинне allowlist Г3 целиком (внутренние URI легитимны — судит И-5);
# эта граница здесь не судится.
#
# ПРИВЯЗКА К КОДУ (Н-39: стабы к ветвям по коду, НЕ по прозе контракта).
# Субъект .omp/extensions/path-guard.ts, judge-протокол И-1/И-5. Ослабленная
# (сегодняшняя) форма — URI-ветвь БЕЗУСЛОВНОГО pass (judgeEditWrite:
# «if (isAllowedURI(path)) return pass» без проверки пина; pathAllowed:
# isAllowedURI(resolved) → true раньше canonicalWt-ветви): local:// и прочие
# внутренние URI проходят у НЕпинна — шире слова владельца (URI-дыра d141dd9).
# Честная форма: URI-allowlist ПИНН-ЗАВИСИМ — при worktree:null pass ТОЛЬКО
# {dev-harness-verify, artifact://}; local:// и иные схемы — block Н-85;
# в-пинне — полный Г3 (isAllowedURI pass).
#
# ВЕТВИ (8):
#   1 «непиннованный-чекаут-запись»     → block Н-85 (ДЕФОЛТ-ЗАПРЕЩЁН; цель —
#     внутри дерева-субъекта $ROOT, представитель класса «всякая цель вне
#     allowlist»; decoy fail-open — сегодняшняя реализация — умирает здесь);
#   2 «непиннованный-скратч»            → pass (исключение слова владельца:
#     ${TMPDIR}/dev-harness-verify; decoy «всегда block» умирает здесь);
#   3 «непиннованный-artifact»          → pass (исключение слова владельца:
#     artifact://, канал write — URI-allowlist обязан пережить fail-closed-правку);
#   4 «непиннованный-свободный-абсолют» → block Н-85 (НЕ свободные абсолюты;
#     цель вне repo и вне allowlist — корень А-72);
#   5 «относительный-вектор-и-в-непинне» → block Н-85 (A-1: непинн не
#     освобождает относительную запись — «и в главной»);
#   6 «острота-чекаут-под-пинном»       → block Н-85 (тот же вход под пинном:
#     блок ветви 1 — семантика allowlist при null, не blanket-запрет);
#   7 «канарейка-в-пинне»               → pass (запись в пинн легальна);
#   8 «непиннованный-local»             → block Н-85 (внутренние URI словом
#     владельца НЕ названы: null-allowlist = ТОЧНО {скратч, artifact://};
#     decoy «URI pass всегда» — сегодняшняя реализация — умирает здесь;
#     пинн-ребёнок с local:// — по пинну, остаётся за И-5).
# Реальная запись НЕ исполняется (прецедент формы И-1/И-5): предмет — решение
# судьи; живое последствие измеряет зонд И-6, ребёнок которого теперь ПИННОВАН
# (§Дыра B контракта).
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
SUBJ="$ROOT/.omp/extensions/path-guard.ts"

if [ ! -f "$SUBJ" ]; then
  printf 'КРАСНОЕ 025-дыра-B: механизм отсутствует — %s не существует; fail-closed непиннованной записи не предъявлен и не стережётся\n' "$SUBJ" >&2
  exit 1
fi

# Предусловие употребления: корень-субъект ВНЕ allowlist Г3. Внутри
# dev-harness-verify чекаут-цель ветвей 1/6 неотличима от скратч-цели ветви 2
# (честный судья обязан пропускать обе) — фикстура откажется судить (rc 2),
# а не предъявит ложное красное по чужой причине (правило 7; класс А-8).
VERIFY_PRE="${TMPDIR:-/tmp}/dev-harness-verify"
case "$ROOT" in
  "$VERIFY_PRE"|"$VERIFY_PRE"/*)
    printf 'КРАСНОЕ 025-дыра-B: исход не снят — корень-субъект %s внутри allowlist Г3 (%s): чекаут-ветвь неотличима от скратч-ветви; подай корень вне dev-harness-verify\n' "$ROOT" "$VERIFY_PRE" >&2
    exit 2
    ;;
esac

R="$RANDOM"
VERIFY="${TMPDIR:-/tmp}/dev-harness-verify"
PIN="$(mktemp -d "${TMPDIR:-/tmp}/pg025granica.XXXXXX")"
FREE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/pg025free.XXXXXX")"   # вне repo И вне allowlist Г3
trap 'rm -rf "$PIN" "$FREE_DIR"' EXIT
CHECKOUT_TGT="$ROOT/zond-granica-checkout-$R.txt"            # внутри дерева-субъекта (чекаут)
SCRATCH_TGT="$VERIFY/025/granica-scratch-$R.txt"             # внутри allowlist Г3
FREE_TGT="$FREE_DIR/target-$R.txt"                           # свободный абсолют (А-72)

fail() {  # <ветвь> <детали>
  printf 'КРАСНОЕ 025-дыра-B: ветвь «%s» — %s\n' "$1" "$2" >&2
  exit 1
}

# expect <ветвь> <block|pass|refuse> <подстрока reason> <json> — форма И-1/И-5
expect() {
  local vetka="$1" want="$2" substr="$3" evt="$4" out rc dec
  out="$(node "$SUBJ" --judge "$evt")"; rc=$?
  if [ "$rc" -ne 0 ]; then
    fail "$vetka" "субъект не ответил решением (rc $rc, вывод: ${out:-<пусто>}) — декой/сломанный модуль"
  fi
  dec="$(printf '%s' "$out" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{const j=JSON.parse(s);console.log(j.decision??"")}catch(e){console.log("BAD_JSON")}})')"
  if [ -z "$dec" ] || [ "$dec" = "BAD_JSON" ]; then
    fail "$vetka" "субъект не ответил решением-JSON (вывод: ${out:-<пусто>})"
  fi
  if [ "$dec" != "$want" ]; then
    fail "$vetka" "ожидалось $want, получено $dec (вывод: $out)"
  fi
  if [ -n "$substr" ]; then
    case "$out" in
      *"$substr"*) ;;
      *) fail "$vetka" "reason без «$substr»: $out" ;;
    esac
  fi
}

# 1: непиннованная чекаут-запись — ДЕФОЛТ-ЗАПРЕЩЁН (слово владельца 2026-09-11)
expect "непиннованный-чекаут-запись" block "Н-85" \
  "{\"tool\":\"bash\",\"args\":{\"command\":\"printf X | tee $CHECKOUT_TGT\"},\"worktree\":null,\"actual\":null}"

# 2: исключение слова — скратч (dev-harness-verify) непиннованному разрешён
expect "непиннованный-скратч" pass "" \
  "{\"tool\":\"bash\",\"args\":{\"command\":\"printf X | tee $SCRATCH_TGT\"},\"worktree\":null,\"actual\":null}"

# 3: исключение слова — artifact:// (канал write) непиннованному разрешён
expect "непиннованный-artifact" pass "" \
  "{\"tool\":\"write\",\"args\":{\"path\":\"artifact://granica-$R\",\"content\":\"x\"},\"worktree\":null,\"actual\":null}"

# 4: НЕ свободные абсолюты — цель вне repo и вне allowlist тоже блок (А-72)
expect "непиннованный-свободный-абсолют" block "Н-85" \
  "{\"tool\":\"bash\",\"args\":{\"command\":\"printf X | tee $FREE_TGT\"},\"worktree\":null,\"actual\":null}"

# 5: непинн НЕ освобождает относительный вектор (A-1: «и в главной»)
expect "относительный-вектор-и-в-непинне" block "Н-85" \
  "{\"tool\":\"bash\",\"args\":{\"command\":\"printf X | tee rel-granica-$R.txt\"},\"worktree\":null,\"actual\":null}"

# 6: острота — тот же чекаут-вход под пинном блокируется (пин-ветвь C-1)
expect "острота-чекаут-под-пинном" block "Н-85" \
  "{\"tool\":\"bash\",\"args\":{\"command\":\"printf X | tee $CHECKOUT_TGT\"},\"worktree\":\"$PIN\",\"actual\":\"$PIN\"}"

# 7: канарейка — запись ВНУТРИ пинна легальна (дефолт-запрет не blanket)
expect "канарейка-в-пинне" pass "" \
  "{\"tool\":\"bash\",\"args\":{\"command\":\"printf X | tee $PIN/tgt-$R.txt\"},\"worktree\":\"$PIN\",\"actual\":\"$PIN\"}"

# 8: внутренние URI у НЕпинна словом владельца НЕ названы → блок (URI-дыра
# d141dd9; artifact — исключение слова, остаётся pass ветвью 3; пинн-ребёнок —
# по пинну, в-пинне local:// pass судит И-5)
expect "непиннованный-local" block "Н-85" \
  "{\"tool\":\"write\",\"args\":{\"path\":\"local://granica-$R\",\"content\":\"x\"},\"worktree\":null,\"actual\":null}"

printf 'ЗЕЛЁНОЕ 025-дыра-B: fail-closed предъявлен — непиннованная запись block Н-85 на чекаут-цели (1), свободном абсолюте (4) и local:// (8), pass только на скратч (2) и artifact (3); относительный вектор блок (5); под пинном чекаут-цель блок (6), в-пинне pass (7)\n' >&2
exit 0
