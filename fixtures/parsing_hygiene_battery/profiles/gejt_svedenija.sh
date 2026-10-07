#!/usr/bin/env bash
# Профиль батареи гигиены парсинга для scripts/gejt_svedenija.sh и
# .githooks/pre-merge-commit (контракт 086 «Гейты сведения интеграции»,
# А7 — зона architect). Домен — ИМЕННО разбор АРГУМЕНТОВ гейта (okno/hook)
# и GIT_REFLOG_ACTION хука; не разбор NUL-потока судей (у check_zones и
# check_charter своя батарея, дублировать здесь — тавтология).
#
# Содержательные источники (живые ссылки 4 игрового арбитража):
#   - verdicts/arbitration/086-gejty-svedenija-krug3.md §З5
#     GIT_REFLOG_ACTION формы `merge <имя>…`, октопус, `pull …`, неразрешимое
#     имя — каждое проверяется отдельным плечом (Б-4' ревьюера круг 2 +
#     пересекающийся с Б-7 круг 4);
#   - §З1 там же: `diff-tree -z LF-разрез имени файла` — ИСПРАВЛЕНО переходом
#     на судей, но синтаксический обход (предикат (б) в самом гейте) — это
#     октопус-разбор, отдельное плечо delimiter_collision;
#   - контракт 086 И-8: `[0-9a-f]{40}$` грамматика sha в okno-режиме;
#     не-40-hex обязан отклоняться NAMED refusal rc=1 «база окна вне
#     грамматики sha», НЕ rc=2 NOT_IMPLEMENTED от падения `git rev-list`
#     дальше по pipeline.
#   - Frontier 5: «иная форма» (включая `pull …` и пустую) — отказ rc=1.
GEJT_REPO="$(cd "$HERE/../.." && pwd -P)"
GEJT_SUBJ="$GEJT_REPO/scripts/gejt_svedenija.sh"
GEJT_HOOK="$GEJT_REPO/.githooks/pre-merge-commit"

# Toy-мир для плеч (а)/(б)/(в) (delimiter_collision, regex_injection,
# silent_drop): main + wip, без merge-коммитов.
# Топология:
#   M0 (root, общий)
#   ├── M1 (main head)           — НЕ предок W1_a2 (W1_a2 branched from M0)
#   ├── W1_a, W1_a2 (wip-a)
#   └── W1_b, W1_b2 (wip-b)
# Печатает 4 sha через пробел: M0 M1 W1_a2 W1_b2.
_gejt_world() {
  local r="$1"
  mkdir -p "$r"
  git -C "$r" init -q -b main >/dev/null 2>&1
  git -C "$r" -c user.name=test -c user.email=t@local commit -q --allow-empty -m M0 >/dev/null
  local M0 M1 W1a2 W1b2
  M0="$(git -C "$r" rev-parse HEAD)"
  # main tip M1
  git -C "$r" -c user.name=test -c user.email=t@local commit -q --allow-empty -m M1 >/dev/null
  M1="$(git -C "$r" rev-parse HEAD)"
  # wip-a from M0
  git -C "$r" checkout -q -b wip-a "$M0" >/dev/null 2>&1
  git -C "$r" -c user.name=test -c user.email=t@local commit -q --allow-empty -m W1a >/dev/null
  git -C "$r" -c user.name=test -c user.email=t@local commit -q --allow-empty -m W1a2 >/dev/null
  W1a2="$(git -C "$r" rev-parse HEAD)"
  # wip-b from M0
  git -C "$r" checkout -q -b wip-b "$M0" >/dev/null 2>&1
  git -C "$r" -c user.name=test -c user.email=t@local commit -q --allow-empty -m W1b >/dev/null
  git -C "$r" -c user.name=test -c user.email=t@local commit -q --allow-empty -m W1b2 >/dev/null
  W1b2="$(git -C "$r" rev-parse HEAD)"
  git -C "$r" checkout -q main >/dev/null 2>&1 || true
  printf '%s %s %s %s\n' "$M0" "$M1" "$W1a2" "$W1b2"
}

battery_delimiter_collision() {
  # Октопус с 3+ головами — sync_violation_pairs ОБЯЗАН проверить ВСЕ пары
  # (p1, p2) в декартовом произведении harr × harr, а не только
  # (harr[0], harr[1]). Дыра «первые две головы»: sync между 2-й и 3-й
  # головами прошёл бы тихо, merge создан.
  #
  # Источник: verdicts/arbitration/086-gejty-svedenija-krug3.md §З5
  # (`git merge wip2 main` → октопус 2 головами) + §П1 п.2 Frontier 7
  # (предикат (б) один для гейта и хука, никакого «первая пара»).
  #
  # (а) ПОЗИТИВ: 3 родителя {M0, W1_a2, W1_b2}. M0 — общий корень,
  #     предок всех (W1_a2 и W1_b2 branched from M0). sync_violation_pairs:
  #     p1=M0 IS ancestor of main; is-ancestor M0 W1_a2 → yes; is-ancestor
  #     M0 W1_b2 → yes. NO sync. rc=0.
  # (б) НЕГАТИВ (sync прячем в 3-ю пару — первые 2 wip-коммита НЕ на main,
  #     sync источник M1 — на 3-й позиции): {W1_a2, W1_b2, M1}. M1 IS
  #     ancestor of main, M1 НЕ предок W1_a2 (W1_a2 branched from M0, до M1)
  #     и не предок W1_b2. Bug «первая пара p1 = первые 2 wip-коммита»
  #     проверит (W1_a2, W1_b2), (W1_b2, W1_a2) — оба wip, не на main →
  #     оба пропущены predicate'ом. После 2 итераций break. M1 не проверен,
  #     sync не виден, rc=0. Честный предикат доходит до p1=M1 → (M1, W1_a2)
  #     M1 NOT ancestor of W1_a2 → SYNC, rc=1.
  local w r M0 M1 W1a2 W1b2 out rc
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_gejt_dc.XXXXXX")"; r="$w/toy"
  read -r M0 M1 W1a2 W1b2 <<<"$(_gejt_world "$r")"
  # (а) ПОЗИТИВ
  out="$(bash "$GEJT_SUBJ" hook "$r" pre-merge-commit "$M0" "$W1a2" "$W1b2" 2>&1)"; rc=$?
  if [ "$rc" -ne 0 ] || printf '%s' "$out" | grep -Fq 'ОТКАЗ 086'; then
    printf 'БАТАРЕЯ %s: octopus positive: rc %s (ожидался 0); вывод: %s\n' \
      "${PROFILE_NAME:-gejt_svedenija}" "$rc" "$out" >&2
    rm -rf "$w"; return 1
  fi
  # (б) НЕГАТИВ
  out="$(bash "$GEJT_SUBJ" hook "$r" pre-merge-commit "$W1a2" "$W1b2" "$M1" 2>&1)"; rc=$?
  rm -rf "$w"
  if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'правило (б) sync-merge'; then
    printf 'БАТАРЕЯ %s: octopus negative: rc %s (ожидался 1) без NAMED refusal rule (б); вывод: %s\n' \
      "${PROFILE_NAME:-gejt_svedenija}" "$rc" "$out" >&2
    return 1
  fi
}

battery_regex_injection() {
  # REFLOG_ACTION содержит имя с shell-метасимволами (`$`, `(`, `)`).
  # Хук ОБЯЗАН обработать данные КАК ДАННЫЕ: `for h in $HEADS_LINE`
  # word-splitting по $IFS (пробел/таб/LF), без eval. Имя `wip$(evil)`
  # — ОДИН токен (нет пробела), rev-parse не находит такой ref →
  # UNRESOLVED → rc=1 NAMED refusal `имя не резолвится в коммит`.
  #
  # Источник: verdicts/arbitration/086-gejty-svedenija-krug3.md §З5
  # (замер 1 контракта 086: «имя не резолвится» — fail-open → fail-closed;
  # §П3 п.3 Frontier 5+7 Б-4' ревьюера круг 2 + пересекающийся с Б-7
  # круг 4). Прежняя реализация (`:126` хука 93ae355 `|| continue`)
  # ТИХО ДРОПАЛА нерезолвимое имя — sync-merge проходил в обход accept/land.
  #
  # Ожидание: rc=1, в выводе строка «имя не резолвится в коммит», БЕЗ
  # rc=2 NOT_IMPLEMENTED (аномалия, не грамматика) и БЕЗ rc=0 (silent accept
  # по прежней fail-open форме).
  local w r out rc
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_gejt_ri.XXXXXX")"; r="$w/toy"
  mkdir -p "$r"
  git -C "$r" init -q -b main >/dev/null 2>&1
  git -C "$r" -c user.name=test -c user.email=t@local commit -q --allow-empty -m init >/dev/null
  git -C "$r" checkout -q -b wip >/dev/null
  git -C "$r" -c user.name=test -c user.email=t@local commit -q --allow-empty -m wip >/dev/null
  out="$(cd "$r" && GIT_REFLOG_ACTION='merge wip$(echo evil)' \
            GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
            bash "$GEJT_HOOK" 2>&1)"; rc=$?
  rm -rf "$w"
  if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'имя не резолвится в коммит'; then
    printf 'БАТАРЕЯ %s: shell metachar: rc %s (ожидался 1) без «имя не резолвится»; вывод: %s\n' \
      "${PROFILE_NAME:-gejt_svedenija}" "$rc" "$out" >&2
    return 1
  fi
}

battery_silent_drop() {
  # REFLOG_ACTION = `pull --no-rebase --no-ff -q <R> main` — форма
  # `pull …`, не `merge <имя>…`. Это ТОЧНАЯ форма, которую git создаёт
  # при `git pull --no-rebase <R> main` в wip-worktree с активными хуками
  # (замер 5 арбитража круг 3: ровно такая строка).
  #
  # Прежняя реализация хука (93ae355 до fix5, `:76-80`) делала `exit 0`
  # на форме вне `merge …` — fail-open, нарушение ТИХО ДРОПАЛОСЬ: merge
  # создавался, sync-merge с main шёл в wip-worktree в обход accept/land.
  # Текущий хук проверяет форму и отказывает NAMED refusal rc=1 «форма
  # рефлога вне грамматики «merge <имя>…»» (Frontier 5 + 7, Б-4' ревьюера
  # круг 2 + пересекающийся с Б-7 круг 4). Это грамматика ВХОДА, не
  # содержимое merge — НЕ sync-находка по факту.
  #
  # Ожидание: rc=1, в выводе строка «форма рефлога вне грамматики», а НЕ
  # «правило (б) sync-merge» (sync-находка).
  local w r out rc
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_gejt_sd.XXXXXX")"; r="$w/toy"
  mkdir -p "$r"
  git -C "$r" init -q -b main >/dev/null 2>&1
  git -C "$r" -c user.name=test -c user.email=t@local commit -q --allow-empty -m init >/dev/null
  git -C "$r" checkout -q -b wip >/dev/null
  git -C "$r" -c user.name=test -c user.email=t@local commit -q --allow-empty -m wip >/dev/null
  out="$(cd "$r" && GIT_REFLOG_ACTION="pull --no-rebase --no-ff -q $r main" \
            GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
            bash "$GEJT_HOOK" 2>&1)"; rc=$?
  rm -rf "$w"
  if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'форма рефлога вне грамматики'; then
    printf 'БАТАРЕЯ %s: pull form: rc %s (ожидался 1) без «форма рефлога»; вывод: %s\n' \
      "${PROFILE_NAME:-gejt_svedenija}" "$rc" "$out" >&2
    return 1
  fi
}

battery_self_application_green() {
  # (а) ГРАММАТИКА SHA в okno-режиме: не-40-hex в <база> или <верх>
  #     обязан отклоняться NAMED refusal rc=1 «база окна вне грамматики
  #     sha» (И-8, замкнутый алфавит `[0-9a-f]{40}$`). Без ранней проверки
  #     `git rev-list $BASE..$TIP` дальше по pipeline упал бы с rc=128 →
  #     гейт напечатал бы NOT_IMPLEMENTED rc=2 (аномалия), без экшна.
  #     Без этой проверки гейт отказывал бы с trace вместо NAMED refusal.
  #     Проверяется: rc=1 + строка «база окна вне грамматики sha».
  # (б) САМО-ПРИМЕНЕНИЕ: gejt_svedenija.sh okno на РЕАЛЬНОЙ истории
  #     dev-harness — Р7 (wip/082/architect, известный ЗЕЛЁНЫЙ ленд по
  #     red_istorija_3_086.sh: rc=0). Клон одноразовый, рабочее дерево
  #     architect не трогается (clone --no-hardlinks).
  local w r out rc
  # (а) грамматика
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_gejt_self_a.XXXXXX")"; r="$w/toy"
  mkdir -p "$r"
  git -C "$r" init -q -b main >/dev/null 2>&1
  git -C "$r" -c user.name=test -c user.email=t@local commit -q --allow-empty -m init >/dev/null
  out="$(bash "$GEJT_SUBJ" okno "$r" not-a-sha also-not wip/082/architect land 2>&1)"; rc=$?
  rm -rf "$w"
  if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'база окна вне грамматики sha'; then
    printf 'БАТАРЕЯ %s: sha grammar: rc %s (ожидался 1) без «база окна вне грамматики»; вывод: %s\n' \
      "${PROFILE_NAME:-gejt_svedenija}" "$rc" "$out" >&2
    return 1
  fi

  # (б) self-test на Р7 (wip/082/architect, rc=0)
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_gejt_self_b.XXXXXX")"
  git clone -q --no-hardlinks "$GEJT_REPO" "$w/clone" 2>/dev/null \
    || { printf 'БАТАРЕЯ %s: клон живой истории не построен\n' "${PROFILE_NAME:-gejt_svedenija}" >&2; rm -rf "$w"; return 1; }
  local p1 p2
  p1="$(git -C "$w/clone" rev-parse 939de6ef4f41c6f5811f760359eadc9ea4baf304^1 2>/dev/null)"
  p2="$(git -C "$w/clone" rev-parse 939de6ef4f41c6f5811f760359eadc9ea4baf304^2 2>/dev/null)"
  if [ -z "$p1" ] || [ -z "$p2" ]; then
    printf 'БАТАРЕЯ %s: Р7 sha на клоне не разрешены\n' "${PROFILE_NAME:-gejt_svedenija}" >&2
    rm -rf "$w"; return 1
  fi
  out="$(bash "$GEJT_SUBJ" okno "$w/clone" "$p1" "$p2" wip/082/architect land 2>&1)"; rc=$?
  rm -rf "$w"
  if [ "$rc" -ne 0 ]; then
    printf 'БАТАРЕЯ %s: Р7 self-test пробит: rc %s (ожидался 0); вывод: %s\n' \
      "${PROFILE_NAME:-gejt_svedenija}" "$rc" "$out" >&2
    return 1
  fi
}