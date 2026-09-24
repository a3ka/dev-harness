#!/usr/bin/env bash
# КРАСНОЕ 037 (М2, scripts/accept_task_commit.sh): скрипт-приёмник ещё не
# существует — механический fetch+cherry-pick из скретч-клона субагента на
# целевую wip/<NNN>/<автор>-ветку с проверкой identity ДО принятия (по
# строгости land_agent.sh — И-9-класс: committer==author==ожидаемая роль).
#
# ПРИВЯЗКА К КОДУ (Н-39):
#   * п1 — отсутствует СЕГОДНЯ (Н-39: живой NOT_IMPLEMENTED, не имитация
#     существующего инструмента);
#   * п2 (позитив, правильный автор) — стаб «принимает без сверки identity»
#     умирает здесь на ЛЮБОМ честном входе тоже (даёт pass, что совпадает —
#     различающая пара с п3);
#   * п3 (негатив, неправильный автор) — стаб «принимает без сверки
#     identity» умирает здесь: ожидание rc≠0 и ветка НЕ сдвинута, стаб даёт
#     rc0 и сдвиг — класс дня 029-031 (критик закоммитил в чужую ветку);
#   * п4 (несуществующая целевая ветка) — стаб «создаёт ветку сам, если её
#     нет» умирает здесь: ожидание именованный отказ, стаб — молчаливое
#     создание.
#   * п5 (Б3 критика contracts-037-v1.md: смешанный диапазон, ВНУТРЕННИЙ
#     коммит чужой, tip корректен) — стаб «проверяет автора только
#     FETCH_HEAD/tip, не каждый коммит диапазона» умирает здесь: ожидание
#     rc≠0 и ветка НЕ сдвинута ЦЕЛИКОМ (М2:225-228 «КАЖДЫЙ»), стаб — rc0 и
#     весь диапазон (включая чужой внутренний коммит) cherry-pick-нут, ровно
#     класс дня 029-031 внутри range вместо tip.
#   * п6 (ЧЕРЕЗ диапазон: линейный диапазон из ДВУХ честных коммитов —
#     блокер M2 того же вердикта, argv-баг RANGE_SHAS против ЗАМОРОЖЕННОГО
#     М2 п.5 «cherry-pick-нуть ВЕСЬ диапазон») — стаб «принимает только
#     одно-коммитный частный случай (многострочная строка == один argv)»
#     умирает здесь: ожидание rc0 + на ветке РОВНО оба коммита +
#     committer==author==implementer; сегодня rc1 «cherry-pick отказал»,
#     ветка не сдвинута (живой прогон этой пачки это подтвердил).
#   * п7 (мерж-политика М2 4а v2) — стаб «мерж не требует именованной
#     политики, сойдёт безымянный отказ cherry-pick» умирает здесь:
#     честный merge (оба родителя + сам мерж — %an/%ae честные) — ожидание
#     rc1 ИМЕНОВАННЫЙ «мерж-коммит в диапазоне» + ветка не сдвинута +
#     временный worktree не протёк; сегодня rc1 БЕЗЫМЯННЫЙ «cherry-pick
#     отказал (конфликт или иная ошибка)» — ни политики, ни имени причины
#     (живой прогон этой пачки это подтвердил).
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"
SUBJ="$ROOT/scripts/accept_task_commit.sh"

command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

NS="/tmp/dev-harness-worktrees"
mkdir -p "$NS"
TOY="$(mktemp -d "$NS/pg037acc.XXXXXX")"
trap 'rm -rf "$TOY"' EXIT
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

MAIN="$TOY/main"
mkdir -p "$MAIN"
git -C "$MAIN" init -q -b main
printf 'x\n' > "$MAIN/f.txt"
git -C "$MAIN" add f.txt
git -C "$MAIN" -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false commit -qm init
git -C "$MAIN" branch wip/201/implementer

SRC_OK="$TOY/src-ok"
git clone -q "$MAIN" "$SRC_OK" 2>/dev/null
git -C "$SRC_OK" checkout -q -b work
printf 'y\n' > "$SRC_OK/g.txt"
git -C "$SRC_OK" add g.txt
git -C "$SRC_OK" -c user.name=implementer -c user.email=implementer@dev-harness.local -c commit.gpgsign=false commit -qm 'work by implementer'

SRC_BAD="$TOY/src-bad"
git clone -q "$MAIN" "$SRC_BAD" 2>/dev/null
git -C "$SRC_BAD" checkout -q -b work
printf 'z\n' > "$SRC_BAD/h.txt"
git -C "$SRC_BAD" add h.txt
git -C "$SRC_BAD" -c user.name=critic -c user.email=critic@dev-harness.local -c commit.gpgsign=false commit -qm 'wrong author'

# ── SRC_MIXED: смешанный диапазон — ВНУТРЕННИЙ коммит чужой, tip корректен ──
# (Б3 критика contracts-037-v1.md: доказывает М2:225-228 «КАЖДЫЙ коммит
# диапазона», не только FETCH_HEAD/tip — критик: «источник base ->
# commit(critic) -> commit(implementer) принимается целиком при
# --author implementer» на tip-only проверке).
SRC_MIXED="$TOY/src-mixed"
git clone -q "$MAIN" "$SRC_MIXED" 2>/dev/null
git -C "$SRC_MIXED" checkout -q -b work
printf 'p\n' > "$SRC_MIXED/p.txt"
git -C "$SRC_MIXED" add p.txt
git -C "$SRC_MIXED" -c user.name=critic -c user.email=critic@dev-harness.local -c commit.gpgsign=false commit -qm 'internal wrong author'
printf 'q\n' > "$SRC_MIXED/q.txt"
git -C "$SRC_MIXED" add q.txt
git -C "$SRC_MIXED" -c user.name=implementer -c user.email=implementer@dev-harness.local -c commit.gpgsign=false commit -qm 'tip correct author'

# ── SRC_TWO: ЧЕСТНЫЙ ЛИНЕЙНЫЙ диапазон из ДВУХ коммитов (оба %an/%ae
# честные) — различает «принимает весь диапазон» (М2 п.5) от
# одно-коммитного частного случая: argv-баг RANGE_SHAS (одна строка с
# переводами строк == ОДИН argv cherry-pick) — блокер M2 вердикта
# адверсария; диапазон branch..FETCH_HEAD = ровно {two:1, two:2}.
SRC_TWO="$TOY/src-two"
git clone -q "$MAIN" "$SRC_TWO" 2>/dev/null
git -C "$SRC_TWO" checkout -q -b work
printf 'a\n' > "$SRC_TWO/a.txt"
git -C "$SRC_TWO" add a.txt
git -C "$SRC_TWO" -c user.name=implementer -c user.email=implementer@dev-harness.local -c commit.gpgsign=false commit -qm 'two honest: first'
printf 'b\n' > "$SRC_TWO/b.txt"
git -C "$SRC_TWO" add b.txt
git -C "$SRC_TWO" -c user.name=implementer -c user.email=implementer@dev-harness.local -c commit.gpgsign=false commit -qm 'two honest: second'

# ── SRC_MERGE: ЧЕСТНЫЙ merge в диапазоне (c1, c2 и сам мерж — все %an/%ae
# честные) — направление «явная политика merge» (М2 4а v2): identity
# проходит, cherry-pick мержа без политики невозможен.
SRC_MERGE="$TOY/src-merge"
git clone -q "$MAIN" "$SRC_MERGE" 2>/dev/null
git -C "$SRC_MERGE" checkout -q -b work
printf 'm1\n' > "$SRC_MERGE/m1.txt"
git -C "$SRC_MERGE" add m1.txt
git -C "$SRC_MERGE" -c user.name=implementer -c user.email=implementer@dev-harness.local -c commit.gpgsign=false commit -qm 'merge case: c1'
git -C "$SRC_MERGE" checkout -q -b side main
printf 's\n' > "$SRC_MERGE/s.txt"
git -C "$SRC_MERGE" add s.txt
git -C "$SRC_MERGE" -c user.name=implementer -c user.email=implementer@dev-harness.local -c commit.gpgsign=false commit -qm 'merge case: c2'
git -C "$SRC_MERGE" checkout -q work
git -C "$SRC_MERGE" -c user.name=implementer -c user.email=implementer@dev-harness.local -c commit.gpgsign=false merge -q --no-edit side

ORDER=(п1 п2 п3 п4 п5 п6 п7)
declare -A ST RAN
for m in "${ORDER[@]}"; do ST[$m]=0; RAN[$m]=0; done
fail() { RAN["$1"]=1; ST["$1"]=1; printf 'КРАСНОЕ 037: ветвь «%s» — %s\n' "$1" "$2" >&2; }
ok() { RAN["$1"]=1; }

# ── п1: скрипт отсутствует СЕГОДНЯ — красная ветвь ДО реализации (Н-39) ────────
if [ -x "$SUBJ" ]; then
  ok п1
else
  fail п1 "отсутствует: $SUBJ (NOT_IMPLEMENTED — приёмник не существует)"
fi

if [ -x "$SUBJ" ]; then
  # ── п2: правильный автор ⇒ rc0, ветка advance, committer==author==implementer
  before_tip="$(git -C "$MAIN" rev-parse wip/201/implementer)"
  out="$("$SUBJ" --root "$MAIN" --source "$SRC_OK" --branch wip/201/implementer --author implementer 2>&1)"; rc=$?
  after_tip="$(git -C "$MAIN" rev-parse wip/201/implementer)"
  an="$(git -C "$MAIN" log -1 --format=%an wip/201/implementer)"
  cn="$(git -C "$MAIN" log -1 --format=%cn wip/201/implementer)"
  ok п2
  if [ "$rc" -ne 0 ] || [ "$after_tip" = "$before_tip" ] || [ "$an" != "implementer" ] || [ "$cn" != "implementer" ]; then
    fail п2 "правильный автор не принят (rc=$rc, before=$before_tip, after=$after_tip, an=$an, cn=$cn, вывод: $out)"
  fi

  # ── п3: неправильный автор ⇒ rc1 именованный, ветка НЕ сдвинута ─────────────
  before_tip3="$(git -C "$MAIN" rev-parse wip/201/implementer)"
  out3="$("$SUBJ" --root "$MAIN" --source "$SRC_BAD" --branch wip/201/implementer --author implementer 2>&1)"; rc3=$?
  after_tip3="$(git -C "$MAIN" rev-parse wip/201/implementer)"
  ok п3
  if [ "$rc3" -eq 0 ] || [ "$after_tip3" != "$before_tip3" ]; then
    fail п3 "неправильный автор ошибочно принят (rc=$rc3, before=$before_tip3, after=$after_tip3, вывод: $out3)"
  fi
  case "$out3" in
    *critic*) ;;
    *) fail п3 "reason не называет фактического автора critic: $out3" ;;
  esac

  # ── п4: несуществующая целевая ветка ⇒ rc1 именованный ──────────────────────
  out4="$("$SUBJ" --root "$MAIN" --source "$SRC_OK" --branch wip/999/nikto --author nikto 2>&1)"; rc4=$?
  ok п4
  if [ "$rc4" -eq 0 ]; then
    fail п4 "несуществующая ветка ошибочно принята (вывод: $out4)"
  fi
  case "$out4" in
    *"не существует"*) ;;
    *) fail п4 "reason не называет отсутствие ветки: $out4" ;;
  esac

  # ── п5: СМЕШАННЫЙ диапазон — tip корректен, ВНУТРЕННИЙ коммит чужой ────────
  # (Б3: М2:225-228 требует КАЖДЫЙ коммит диапазона; различает "проверка
  # только tip/FETCH_HEAD" от "проверка каждого коммита диапазона").
  before_tip5="$(git -C "$MAIN" rev-parse wip/201/implementer)"
  out5="$("$SUBJ" --root "$MAIN" --source "$SRC_MIXED" --branch wip/201/implementer --author implementer 2>&1)"; rc5=$?
  after_tip5="$(git -C "$MAIN" rev-parse wip/201/implementer)"
  ok п5
  if [ "$rc5" -eq 0 ] || [ "$after_tip5" != "$before_tip5" ]; then
    fail п5 "смешанный диапазон принят по tip-only проверке (rc=$rc5, before=$before_tip5, after=$after_tip5, вывод: $out5)"
  fi
  case "$out5" in
    *critic*) ;;
    *) fail п5 "reason не называет фактического автора critic внутреннего коммита: $out5" ;;
  esac

  # ── п6: ЧЕРЕЗ диапазон — линейный ДВА честных коммита ⇒ rc0 + на ветке 2
  before6="$(git -C "$MAIN" rev-parse wip/201/implementer)"
  out6="$("$SUBJ" --root "$MAIN" --source "$SRC_TWO" --branch wip/201/implementer --author implementer 2>&1)"; rc6=$?
  after6="$(git -C "$MAIN" rev-parse wip/201/implementer)"
  cnt6=0
  if [ "$after6" != "$before6" ]; then
    cnt6="$(git -C "$MAIN" rev-list --count "$before6..wip/201/implementer")"
  fi
  an6="$(git -C "$MAIN" log -1 --format=%an wip/201/implementer)"
  cn6="$(git -C "$MAIN" log -1 --format=%cn wip/201/implementer)"
  fA=1; git -C "$MAIN" cat-file -e wip/201/implementer:a.txt 2>/dev/null || fA=0
  fB=1; git -C "$MAIN" cat-file -e wip/201/implementer:b.txt 2>/dev/null || fB=0
  ok п6
  if [ "$rc6" -ne 0 ] || [ "$cnt6" -ne 2 ] || [ "$an6" != "implementer" ] || [ "$cn6" != "implementer" ] || [ "$fA" -ne 1 ] || [ "$fB" -ne 1 ]; then
    fail п6 "честный линейный диапазон из двух коммитов не принят (rc=$rc6, на-ветке=$cnt6, an=$an6, cn=$cn6, a.txt=$fA, b.txt=$fB, вывод: $out6)"
  fi

  # ── п7: ЧЕСТНЫЙ merge в диапазоне ⇒ именованный отказ 4а, ветка не тронута
  before7="$(git -C "$MAIN" rev-parse wip/201/implementer)"
  out7="$("$SUBJ" --root "$MAIN" --source "$SRC_MERGE" --branch wip/201/implementer --author implementer 2>&1)"; rc7=$?
  after7="$(git -C "$MAIN" rev-parse wip/201/implementer)"
  ok п7
  if [ "$rc7" -eq 0 ] || [ "$after7" != "$before7" ]; then
    fail п7 "честный merge ошибочно принят или ветка сдвинута (rc=$rc7, before=$before7, after=$after7, вывод: $out7)"
  fi
  case "$out7" in
    *мерж*) ;;
    *) fail п7 "reason не называет мерж-политику 4а (нет слова «мерж»): $out7" ;;
  esac
  if ls -d "${TMPDIR:-/tmp}"/accept_task_commit.* >/dev/null 2>&1; then
    fail п7 "протёк временный worktree: $(ls -d "${TMPDIR:-/tmp}"/accept_task_commit.*)"
  fi
fi

RED=0; GRN=0; NORUN=0
for m in "${ORDER[@]}"; do
  if [ "${RAN[$m]}" -eq 0 ]; then NORUN=$((NORUN+1));
  elif [ "${ST[$m]}" -eq 1 ]; then RED=$((RED+1)); else GRN=$((GRN+1)); fi
done
if [ "$NORUN" -gt 0 ]; then
  printf 'СВЕДЕНИЕ 037: %d/%d ветвей не прогнаны (скрипт отсутствует — легально на п1-only red)\n' "$NORUN" "${#ORDER[@]}" >&2
fi
printf 'ИТОГ 037 (accept_task_commit): ветвей объявлено %d, прогнано %d, красных %d, зелёных %d\n' "${#ORDER[@]}" "$((${#ORDER[@]}-NORUN))" "$RED" "$GRN"
[ "$RED" -eq 0 ] || exit 1
exit 0
