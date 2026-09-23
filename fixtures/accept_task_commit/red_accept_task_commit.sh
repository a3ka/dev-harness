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

ORDER=(п1 п2 п3 п4)
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
