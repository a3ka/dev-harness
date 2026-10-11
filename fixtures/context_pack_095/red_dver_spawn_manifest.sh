#!/usr/bin/env bash
# Клетка И-15 «обязательность пака на двери spawn_agent» (контракт 095, Решение
# 5, круг 2; закрытие Б1 вердикта критика круга 1; II-3 дословно: spawn_agent
# отказывает без манифеста make_task). (а) спавн исполнительской роли без
# построенного пака — rc 1 «ОТКАЗ: нет манифеста make_task: <NNN>» (нога стоит
# РАНЬШЕ сверок реестра/тегов 023); (б) make_task построил пак → манифест-файл
# .omp/context/<NNN>.tsv непуст и дверь НЕ отказывает этой причиной.
# (в) авто-режим без --nnn (адверсарий круг 1): номер авторазрешается дверью,
# отказ несёт «make_task: <авто-NNN>» — номер снят из вывода первого вызова,
# не хардкод; без wip/*-веток и worktree; с построенным паком авто-номера —
# rc 0 и созданный worktree, зачищенный внутри клетки для повторяемости.
# Реальная дверь судится до/после landing; в режиме --model грамматику ноги
# несёт model/dver_spawn.sh. Обман (s15: нога снята с двери) → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: dver-spawn-manifest: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }
DOOR="$(_t95_door)"
[ -f "$DOOR" ] || { printf 'КРАСНО: dver-spawn-manifest: предмет отсутствует: scripts/spawn_agent.sh\n' >&2; exit 1; }

W="$(_t95_world i15)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_freeze "$R" 'scripts/toy.sh' >/dev/null
_t95_trace "$W/trace.tsv" implementer glm-4.7 allowed

# (а) манифеста нет — дверь отказывает именем ДО сверок 023
out="$(bash "$DOOR" --author implementer --nnn 777 --root "$R" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s\n' "$out" | grep -Fq 'нет манифеста make_task: 777'; then
  printf 'КРАСНО: i15: спавн без пака не отказан «нет манифеста make_task» (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi

# (б) субъект построил пак — манифест-файл непуст, дверь не отказывает этой причиной
outp="$(bash "$SUBJ" --repo "$R" --role implementer --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rcp=$?
if [ "$rcp" -ne 0 ]; then
  printf 'КРАСНО: i15: пак для двери не строится (rc=%s, вывод: %s)\n' "$rcp" "$outp" >&2; exit 1
fi
MAN="$R/.omp/context/777.tsv"
[ -s "$MAN" ] || { printf 'КРАСНО: i15: субъект не оставил манифест-файл пака: %s\n' "$MAN" >&2; exit 1; }
grep -Fq '=== MANIFEST ===' "$MAN" || { printf 'КРАСНО: i15: манифест-файл без секции манифеста\n' >&2; exit 1; }
out2="$(bash "$DOOR" --author implementer --nnn 777 --root "$R" 2>&1)"; rc2=$?
if printf '%s\n' "$out2" | grep -Fq 'нет манифеста make_task'; then
  printf 'КРАСНО: i15: дверь отказала «нет манифеста» при построенном паке (rc=%s, вывод: %s)\n' "$rc2" "$out2" >&2; exit 1
fi

# (в) авто-режим: без --nnn дверь авторазрешает номер (следующий свободный
# wip/<NNN>) — нога И-15 обязана требовать манифест и здесь (адверсарий круг 1:
# на двери круга 1 проверка сидела только в явной --nnn-ветке, авто-спавн молча
# проходил rc 0). Авто-номер НЕ хардкодится: снимается из вывода первого вызова
# (отказ несёт «make_task: <NNN>»; дефектная дверь — «BRANCH=wip/<NNN>/<автор>»).
outv="$(bash "$DOOR" --author implementer --root "$R" 2>&1)"; rcv=$?
auto="$(printf '%s\n' "$outv" | grep -o 'make_task: [0-9][0-9][0-9]*' | head -n 1 | grep -o '[0-9][0-9][0-9]*')"
[ -n "$auto" ] || auto="$(printf '%s\n' "$outv" | grep -o 'BRANCH=wip/[0-9][0-9][0-9]*/' | head -n 1 | grep -o '[0-9][0-9][0-9]*')"
if [ "$rcv" -ne 1 ] || [ -z "$auto" ] || ! printf '%s\n' "$outv" | grep -Fq "нет манифеста make_task: $auto"; then
  printf 'КРАСНО: i15: авто-спавн без --nnn не отказан «нет манифеста make_task» (rc=%s, авто-номер=%s, вывод: %s)\n' "$rcv" "${auto:-?}" "$outv" >&2
  wtv="$(printf '%s\n' "$outv" | sed -n 's/^WORKTREE=//p' | head -n 1)"
  [ -n "$wtv" ] && [ -d "$wtv" ] && git -C "$R" worktree remove --force "$wtv" >/dev/null 2>&1 || true
  [ -n "$auto" ] && git -C "$R" branch -D "wip/${auto}/implementer" >/dev/null 2>&1 || true
  exit 1
fi
[ -z "$(git -C "$R" for-each-ref --format='%(refname)' 'refs/heads/wip/')" ] || {
  printf 'КРАСНО: i15: авто-отказ оставил wip-ветку\n' >&2; exit 1; }
[ "$(git -C "$R" worktree list --porcelain 2>/dev/null | grep -c '^worktree ')" -eq 1 ] || {
  printf 'КРАСНО: i15: авто-отказ оставил worktree\n' >&2; exit 1; }

# манифест авто-номера: заморозка toy-контракта <auto> (исполнительские роли
# собираются только из заморозки — И-6) + пак субъектом
printf '# Контракт %s — toy (авто)\n\nКОНТЕКСТ: модуль toy, сосед один\n\n## Существующее\n\n- scripts/toy.sh — живой код\n\n## Предмет\n\ntoy-предмет авто.\n\nЗОНА implementer: scripts/toy.sh\n' "$auto" >"$R/contracts/${auto}-toy.md"
git -C "$R" add "contracts/${auto}-toy.md"
git -C "$R" commit -qm "toy-контракт ${auto} (авто-режим И-15)"
git -C "$R" tag frozen/contracts/${auto}/1
outm="$(bash "$SUBJ" --repo "$R" --role implementer --contract "$auto" --model-trace "$W/trace.tsv" 2>&1)"; rcm=$?
if [ "$rcm" -ne 0 ]; then
  printf 'КРАСНО: i15: пак авто-номера %s не строится (rc=%s, вывод: %s)\n' "$auto" "$rcm" "$outm" >&2; exit 1
fi
[ -s "$R/.omp/context/${auto}.tsv" ] || { printf 'КРАСНО: i15: субъект не оставил манифест авто-номера: %s\n' "$R/.omp/context/${auto}.tsv" >&2; exit 1; }

# повтор без --nnn: пак авто-номера построен — авто-спавн проходит (rc 0,
# контракт выхода 016 WORKTREE=/BRANCH=), созданное зачищается для повторяемости
outw="$(bash "$DOOR" --author implementer --root "$R" 2>&1)"; rcw=$?
if [ "$rcw" -ne 0 ]; then
  printf 'КРАСНО: i15: авто-спавн с построенным паком отказал (rc=%s, вывод: %s)\n' "$rcw" "$outw" >&2; exit 1
fi
wtw="$(printf '%s\n' "$outw" | sed -n 's/^WORKTREE=//p' | head -n 1)"
brw="$(printf '%s\n' "$outw" | sed -n 's/^BRANCH=//p' | head -n 1)"
if [ -z "$wtw" ] || [ "$brw" != "wip/${auto}/implementer" ]; then
  printf 'КРАСНО: i15: авто-спавн нарушил контракт выхода 016 (WORKTREE=%s, BRANCH=%s, ждал wip/%s/implementer)\n' "${wtw:-нет}" "${brw:-нет}" "$auto" >&2; exit 1
fi
# Живая дверь создаёт ветку И worktree (атомарная транзакция 016) — тогда оба
# обязаны существовать и зачищаются; дверь-модель несёт только грамматику ноги
# и не создаёт ни того, ни другого. «Ветка без worktree» / «worktree без ветки»
# — нарушение атомарности, красное.
if git -C "$R" show-ref --verify --quiet "refs/heads/$brw" 2>/dev/null; then
  [ -d "$wtw" ] || { printf 'КРАСНО: i15: авто-спавн дал ветку %s без worktree %s (атомарность 016)\n' "$brw" "$wtw" >&2; exit 1; }
  git -C "$R" worktree remove "$wtw" >/dev/null 2>&1 \
    && git -C "$R" branch -D "$brw" >/dev/null 2>&1 || {
      printf 'КРАСНО: i15: зачистка авто-спавна не удалась (wt=%s, ветка=%s)\n' "$wtw" "$brw" >&2; exit 1; }
elif [ -d "$wtw" ]; then
  printf 'КРАСНО: i15: авто-спавн дал worktree %s без ветки %s (атомарность 016)\n' "$wtw" "$brw" >&2; exit 1
fi
exit 0
