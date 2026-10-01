#!/usr/bin/env bash
# КРАСНОЕ 068 (а) — ПОРЯДОК cherry-pick диапазона в scripts/accept_task_commit.sh
# (боль сессии 2026-09-30: RANGE_SHAS собирается rev-list'ом БЕЗ --reverse →
# многокоммитная пачка черри-пикается от НОВЫХ к СТАРЫМ → конфликт; оркестратор
# 4 раза за день вручную делал упорядоченный replay: 065-пачка, 063v2, ovfix,
# roadmap).
#
# ИНВАРИАНТ (контракт 068): cherry-pick диапазона обязан идти ОТ СТАРШЕГО К
# МЛАДШЕМУ; сверка identity по-прежнему накрывает КАЖДЫЙ коммит диапазона
# (М2 п.4 контракта 037 не ослабляется).
#
# ПРИВЯЗКА К КОДУ (Н-39):
#   * в1 (определяющая ветвь) — два последовательных коммита, правящие ОДИН файл
#     seq.txt (младший контекстно опирается на старший): честный приёмник обязан
#     дать rc 0 + ровно 2 коммита на ветке + ПОРЯДОК subjects «seq: старший» →
#     «seq: младший» (git log --reverse) + содержимое seq.txt = base,a,b +
#     committer==author==implementer. Стаб «rev-list без --reverse» (стА)
#     умирает здесь: cherry-pick младшего на базу без старшего = конфликт, rc 1.
#     СЕГОДНЯ (до --reverse) ветвь КРАСНАЯ тем же именем — предъявляемое красное.
#   * в2 (негативная пара в1) — СТАРШИЙ коммит диапазона чужой (critic), младший
#     честный: приёмник обязан отказать rc 1 с именем critic, ветка НЕ сдвинута.
#     Стаб «identity судит только ПОСЛЕДНИЙ коммит диапазона» (стБ) умирает
#     здесь: со старшим-в-начале (--reverse) tip-only-проверка пропускает пачку.
#   * в3 (контроль) — МЛАДШИЙ коммит чужой: отказ rc 1 с именем critic, ветка не
#     сдвинута. Стаб «identity судит только ПЕРВЫЙ коммит диапазона» (стВ) умирает
#     здесь. ЗЕЛЁНАЯ ДО и ПОСЛЕ (в2/в3 — регресс М2 п.4 при новом порядке).
#
# Стабы — мутантные КОПИИ субъекта в скретче (одна sed-ручка на копию; субъект
# автономен — соседство scripts/ не нужно):
#   стА «rev-list без --reverse»  sed 's|rev-list --reverse |rev-list |'
#   стБ «identity только [-1]»    sed 's|for sha in "${RANGE_SHAS[@]}"|for sha in "${RANGE_SHAS[-1]}"|'
#   стВ «identity только [0]»     sed 's|for sha in "${RANGE_SHAS[@]}"|for sha in "${RANGE_SHAS[0]}"|'
# Применение проверяется ДВУМЯ мерами (AGENTS правило 4): копия ОТЛИЧАЕТСЯ от
# субъекта (cmp) ∧ несёт литеральный маркер (grep -F — [-1]/[0] суть литералы,
# НЕ классы символов). Не применилась (честный субъект ещё несёт дефект —
# ДО-состояние) → стаб «не построен», НЕ красная ветвь.
#
# Коды возврата: 0 — все ветви зелёные (после реализации); 1 — есть красная;
# 2 — нечем проверять (нет git / субъекта).
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"
SUBJ="$ROOT/scripts/accept_task_commit.sh"

command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
[ -f "$SUBJ" ] || { printf 'NOT_IMPLEMENTED: нет субъекта: %s\n' "$SUBJ" >&2; exit 2; }

WORK="$(mktemp -d "${TMPDIR:-/tmp}/red068a.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

# env-изоляция identity (068, разблокировка заморозки): переменные окружения
# GIT_AUTHOR_*/GIT_COMMITTER_* БЬЮТ -c user.name — наследованная из freeze-
# окружения (freeze_contract экспортирует GIT_COMMITTER_NAME=orchestrator)
# orchestrator-identity отравляла toy-коммиты и cherry-pick субъекта:
# «identity расхождение» без заявленной причины. Снимаем наследие — identity
# определяется ТОЛЬКО явным -c каждого коммита (фикстура и субъект-ребёнок).
unset GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_AUTHOR_DATE \
      GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL GIT_COMMITTER_DATE

BR=wip/210/implementer

# mk_main <каталог>: toy-main с base-коммитом (seq.txt=base) и веткой $BR на base.
mk_main() {
  local m="$1"
  mkdir -p "$m"
  git -C "$m" init -q -b main
  printf 'base\n' > "$m/seq.txt"
  git -C "$m" add seq.txt
  git -C "$m" -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false commit -qm init
  git -C "$m" branch "$BR"
}

# mk_src <каталог> <main> <an-старшего> <an-младшего>: clone main → work; ДВА
# последовательных коммита, ОБА правят seq.txt (добавление строки; контекст
# младшего содержит строку старшего — независимых правок НЕТ, порядок наблюдаем).
mk_src() {
  local s="$1" m="$2" a1="$3" a2="$4"
  git clone -q "$m" "$s" 2>/dev/null
  git -C "$s" checkout -q -b work
  printf 'a\n' >> "$s/seq.txt"
  git -C "$s" add seq.txt
  git -C "$s" -c "user.name=$a1" -c "user.email=${a1}@dev-harness.local" -c commit.gpgsign=false commit -qm 'seq: старший'
  printf 'b\n' >> "$s/seq.txt"
  git -C "$s" add seq.txt
  git -C "$s" -c "user.name=$a2" -c "user.email=${a2}@dev-harness.local" -c commit.gpgsign=false commit -qm 'seq: младший'
}

# probe_v1 <субъект> <main> <src> → rc 0 iff зелёная ветвь в1 (сообщение в stdout).
probe_v1() {
  local sub="$1" m="$2" s="$3" before out rc cnt order an cn content
  before="$(git -C "$m" rev-parse "$BR")"
  out="$("$sub" --root "$m" --source "$s" --branch "$BR" --author implementer 2>&1)"; rc=$?
  cnt="$(git -C "$m" rev-list --count "$before..$BR")"
  order="$(git -C "$m" log --reverse --format=%s "$before..$BR" | paste -sd'|' -)"
  an="$(git -C "$m" log -1 --format=%an "$BR")"
  cn="$(git -C "$m" log -1 --format=%cn "$BR")"
  content="$(git -C "$m" show "$BR:seq.txt" | paste -sd, -)"
  [ "$rc" -eq 0 ] || { printf 'rc=%s вывод: %s' "$rc" "$out"; return 1; }
  [ "$cnt" -eq 2 ] || { printf 'на ветке %s коммитов (ожидалось 2)' "$cnt"; return 1; }
  [ "$order" = 'seq: старший|seq: младший' ] || { printf 'порядок %s (ожидался старший→младший)' "$order"; return 1; }
  [ "$content" = 'base,a,b' ] || { printf 'seq.txt=%s (ожидалось base,a,b)' "$content"; return 1; }
  { [ "$an" = implementer ] && [ "$cn" = implementer ]; } || { printf 'an=%s cn=%s' "$an" "$cn"; return 1; }
  return 0
}

# probe_neg <субъект> <main> <src> → rc 0 iff честный отказ в2/в3.
probe_neg() {
  local sub="$1" m="$2" s="$3" before out rc after
  before="$(git -C "$m" rev-parse "$BR")"
  out="$("$sub" --root "$m" --source "$s" --branch "$BR" --author implementer 2>&1)"; rc=$?
  after="$(git -C "$m" rev-parse "$BR")"
  [ "$rc" -eq 1 ] || { printf 'rc=%s (ожидался 1), вывод: %s' "$rc" "$out"; return 1; }
  [ "$after" = "$before" ] || { printf 'ветка сдвинута на отказе'; return 1; }
  case "$out" in *critic*) ;; *) printf 'reason не называет critic: %s' "$out"; return 1 ;; esac
  return 0
}

RED=0; GRN=0; NORUN=0
declare -a REPS=()

# ── в1: порядок диапазона (КРАСНАЯ ДО, ЗЕЛЁНАЯ ПОСЛЕ) ─────────────────────────
M1="$WORK/m1"; mk_main "$M1"; S1="$WORK/s1"; mk_src "$S1" "$M1" implementer implementer
msg1="$(probe_v1 "$SUBJ" "$M1" "$S1")"; prc=$?
if [ "$prc" -eq 0 ]; then REPS+=("в1: ЗЕЛЁНАЯ"); GRN=$((GRN+1)); else REPS+=("в1: КРАСНАЯ — $msg1"); RED=$((RED+1)); fi

# ── в2: старший чужой → отказ (ЗЕЛЁНАЯ ДО и ПОСЛЕ; регресс М2 п.4) ────────────
M2T="$WORK/m2"; mk_main "$M2T"; S2="$WORK/s2"; mk_src "$S2" "$M2T" critic implementer
if probe_neg "$SUBJ" "$M2T" "$S2"; then REPS+=("в2: ЗЕЛЁНАЯ"); GRN=$((GRN+1)); else REPS+=("в2: КРАСНАЯ"); RED=$((RED+1)); fi

# ── в3: младший чужой → отказ (контроль) ──────────────────────────────────────
M3T="$WORK/m3"; mk_main "$M3T"; S3="$WORK/s3"; mk_src "$S3" "$M3T" implementer critic
if probe_neg "$SUBJ" "$M3T" "$S3"; then REPS+=("в3: ЗЕЛЁНАЯ"); GRN=$((GRN+1)); else REPS+=("в3: КРАСНАЯ"); RED=$((RED+1)); fi

# ── стабы: мутантные копии субъекта; каждая обязана ДАТЬ красную на своей ветви ─
mk_stub() { # <копия> <sed-выражение> <литеральный grep -F маркер>
  cp "$SUBJ" "$1"
  sed -i "$2" "$1"
  chmod +x "$1"
  cmp -s "$SUBJ" "$1" && return 1
  grep -qF -- "$3" "$1" || return 1
  return 0
}

MA="$WORK/ma"; mk_main "$MA"; SA="$WORK/sa"; mk_src "$SA" "$MA" implementer implementer
if ! mk_stub "$WORK/atc-stA.sh" 's|rev-list --reverse |rev-list |' 'rev-list "$BRANCH_ARG'; then
  NORUN=$((NORUN+1)); REPS+=("стА: не построен — честный субъект ещё БЕЗ --reverse (ДО-состояние)")
elif probe_v1 "$WORK/atc-stA.sh" "$MA" "$SA" >/dev/null 2>&1; then REPS+=("стА: ПРОШЁЛ (дефект жив)"); RED=$((RED+1)); else REPS+=("стА: мёртв"); GRN=$((GRN+1)); fi

MB="$WORK/mb"; mk_main "$MB"; SB="$WORK/sb"; mk_src "$SB" "$MB" critic implementer
if ! mk_stub "$WORK/atc-stB.sh" 's|for sha in "${RANGE_SHAS\[@\]}"|for sha in "${RANGE_SHAS[-1]}"|' 'RANGE_SHAS[-1]'; then
  NORUN=$((NORUN+1)); REPS+=("стБ: не построен (sed-ручка не применилась)")
elif probe_neg "$WORK/atc-stB.sh" "$MB" "$SB" >/dev/null 2>&1; then REPS+=("стБ: ПРОШЁЛ (дефект жив)"); RED=$((RED+1)); else REPS+=("стБ: мёртв"); GRN=$((GRN+1)); fi

MV="$WORK/mv"; mk_main "$MV"; SV="$WORK/sv"; mk_src "$SV" "$MV" implementer critic
if ! mk_stub "$WORK/atc-stV.sh" 's|for sha in "${RANGE_SHAS\[@\]}"|for sha in "${RANGE_SHAS[0]}"|' 'RANGE_SHAS[0]'; then
  NORUN=$((NORUN+1)); REPS+=("стВ: не построен (sed-ручка не применилась)")
elif probe_neg "$WORK/atc-stV.sh" "$MV" "$SV" >/dev/null 2>&1; then REPS+=("стВ: ПРОШЁЛ (дефект жив)"); RED=$((RED+1)); else REPS+=("стВ: мёртв"); GRN=$((GRN+1)); fi

for r in "${REPS[@]}"; do printf 'КРАСНОЕ 068a: %s\n' "$r" >&2; done
printf 'ИТОГ 068a (порядок диапазона): ветвей 3, стабов 3, красных %d, зелёных %d, не построено %d\n' "$RED" "$GRN" "$NORUN"
[ "$RED" -eq 0 ] || exit 1
exit 0
