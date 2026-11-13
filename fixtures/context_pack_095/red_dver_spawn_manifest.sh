#!/usr/bin/env bash
# Клетка И-15 «обязательность пака на двери spawn_agent» (контракт 095,
# Решение 5, круг 2; закрытие Б1 вердикта критика круга 1; II-3 дословно:
# spawn_agent отказывает без манифеста make_task; cutover-1113 — манифест
# ТОЛЬКО во внешнем state по формуле 161a). Ветви:
# (а) спавн без манифеста — rc 1 «ОТКАЗ: нет манифеста make_task: <NNN>»
#     (нога стоит РАНЬШЕ сверок реестра/тегов 023);
# (б) make_task построил пак → манифест-файл
#     <канонический TMPDIR>/dev-harness-project-state/<первые 16 hex
#     sha256(общий .git)>/context/<NNN>.tsv непуст и несёт секцию манифеста;
#     дверь НЕ отказывает этой причиной; чекаут и .git неизменны по снимку
#     ДО (статус пуст, HEAD/refs те же, каталог .omp не возникает);
# (в) авто-режим без --nnn (адверсарий круга 1): номер авторазрешается
#     дверью, отказ несёт «make_task: <авто-NNN>» — номер снят из вывода
#     первого вызова, не хардкод; без wip/*-веток и worktree; с построенным
#     паком авто-номера — rc 0 и созданный worktree, зачищаемый в клетке;
# (г) устаревший <root>/.omp/context/<NNN>.tsv внутри чекаута при
#     отсутствии внешнего манифеста — тот же именованный отказ: legacy
#     fallback НЕТ (cutover: старое размещение дверью не читается);
# (д) main checkout и linked WT с общим .git — ОДИН внешний каталог:
#     пак из linked WT обновляет тот же context/777.tsv (счёт 777.tsv по
#     всем ключам state = 1 — второй путь не заводится), чекаут WT чист,
#     дверь из main видит манифест, записанный из WT.
# (е) небезопасный TMPDIR — именованный отказ TMPDIR_INSIDE_MAIN ДО
#     побочных эффектов, по разным формам Git (runtime-файлы state — вне
#     чекаутов проекта И вне общего .git): е1 TMPDIR внутри общего .git,
#     вход main (дверь и сборщик); е2 вход linked WT (дверь — WT на ветке
#     main, единственная WT-форма за HEAD-гейтом живой двери; сборщик —
#     detached linked WT), TMPDIR внутри ОБЩЕГО .git; е3 TMPDIR внутри
#     ДРУГОГО связанного чекаута (worktree list), вход main; е4 отдельный
#     несвязанный клон: общий .git — он сам, ключ клона отличен от main.
# Путь state клетка считает САМА по формуле 161a (независимый оракул),
# ожидания снимаются в память ДО вызова субъекта (правило 8). Реальная
# дверь судится до/после landing; в режиме --model грамматику ноги несёт
# model/dver_spawn.sh. Обман (s15: нога снята с двери) → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: dver-spawn-manifest: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }
DOOR="$(_t95_door)"
[ -f "$DOOR" ] || { printf 'КРАСНО: dver-spawn-manifest: предмет отсутствует: scripts/spawn_agent.sh\n' >&2; exit 1; }
command -v sha256sum >/dev/null 2>&1 || { printf 'КРАСНО: dver-spawn-manifest: нет sha256sum\n' >&2; exit 1; }

W="$(_t95_world i15)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_freeze "$R" 'scripts/toy.sh' >/dev/null
_t95_trace "$W/trace.tsv" implementer glm-4.7 allowed
# Независимый оракул размещения (161a): база — канонический TMPDIR, ключ —
# первые 16 hex sha256 ОБЩЕГО .git проекта; main и linked WT сходятся в один
# каталог (общий .git — общий ключ). Считается ДО вызова субъекта.
base="${TMPDIR:-/tmp}"
base="$(cd "$base" && pwd -P)" || { printf 'КРАСНО: i15: TMPDIR не канонизируется: %s\n' "${TMPDIR:-/tmp}" >&2; exit 1; }
common="$(git -C "$R" rev-parse --git-common-dir)"
case "$common" in /*) ;; *) common="$R/$common" ;; esac
common="$(cd "$common" && pwd -P)" \
  || { printf 'КРАСНО: i15: общий .git не канонизируется: %s\n' "$common" >&2; exit 1; }
# Канонический оракул 161a (cutover-1113): живой _git_common_dir починен
# родителем — вывод канонизации ЗАХВАЧЕН (c="$(cd … pwd -P)"), общий .git
# печатается ОДИН раз, ключ = первые 16 hex sha256("<common>") без перевода
# строки (printf '%s', как _hash_sha256_text живого кода). Оракул хеширует
# один канонический общий путь независимо от субъекта; двойная печать pwd —
# измеренная случайность deployed-кода ДО починки, контрактом не является и
# здесь не закрепляется (095-manifest-contract-delta-canonical.md).
key="$(printf '%s' "$common" | sha256sum | cut -c1-16)"
SCTX="$base/dev-harness-project-state/$key/context"

# (а) внешнего манифеста нет — дверь отказывает именем ДО сверок 023;
# legacy-каталога в чекауте тоже нет (источник его не создаёт)
[ ! -e "$R/.omp" ] || { printf 'КРАСНО: i15: до пака в чекауте уже есть .omp\n' >&2; exit 1; }
[ ! -e "$SCTX/777.tsv" ] || { printf 'КРАСНО: i15: до пака внешний манифест уже существует: %s\n' "$SCTX/777.tsv" >&2; exit 1; }
out="$(bash "$DOOR" --author implementer --nnn 777 --root "$R" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s\n' "$out" | grep -Fq 'нет манифеста make_task: 777'; then
  printf 'КРАСНО: i15: спавн без пака не отказан «нет манифеста make_task» (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi

# (б) субъект построил пак: снимок ДО → пак → манифест во внешнем state,
# чекаут и .git неизменны, дверь не отказывает этой причиной
snap_stat="$(git -C "$R" status --porcelain)"
snap_head="$(git -C "$R" rev-parse HEAD)"
snap_refs="$(git -C "$R" for-each-ref | sha256sum)"
[ -z "$snap_stat" ] || { printf 'КРАСНО: i15: мир до пака грязен: %s\n' "$snap_stat" >&2; exit 1; }
outp="$(bash "$SUBJ" --repo "$R" --role implementer --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rcp=$?
if [ "$rcp" -ne 0 ]; then
  printf 'КРАСНО: i15: пак для двери не строится (rc=%s, вывод: %s)\n' "$rcp" "$outp" >&2; exit 1
fi
MAN="$SCTX/777.tsv"
[ -s "$MAN" ] || { printf 'КРАСНО: i15: субъект не оставил внешний манифест-файл пака: %s\n' "$MAN" >&2; exit 1; }
grep -Fq '=== MANIFEST ===' "$MAN" || { printf 'КРАСНО: i15: манифест-файл без секции манифеста\n' >&2; exit 1; }
[ ! -e "$R/.omp" ] || { printf 'КРАСНО: i15: пак загрязнил чекаут каталогом .omp (снимок ДО его не нёс)\n' >&2; exit 1; }
[ "$(git -C "$R" status --porcelain)" = "$snap_stat" ] || { printf 'КРАСНО: i15: пак изменил статус чекаута\n' >&2; exit 1; }
[ "$(git -C "$R" rev-parse HEAD)" = "$snap_head" ] || { printf 'КРАСНО: i15: пак сдвинул HEAD\n' >&2; exit 1; }
[ "$(git -C "$R" for-each-ref | sha256sum)" = "$snap_refs" ] || { printf 'КРАСНО: i15: пак изменил refs\n' >&2; exit 1; }
out2="$(bash "$DOOR" --author implementer --nnn 777 --root "$R" 2>&1)"; rc2=$?
if printf '%s\n' "$out2" | grep -Fq 'нет манифеста make_task'; then
  printf 'КРАСНО: i15: дверь отказала «нет манифеста» при построенном паке (rc=%s, вывод: %s)\n' "$rc2" "$out2" >&2; exit 1
fi

# (в) авто-режим: без --nnn дверь авторазрешает номер (следующий свободный
# wip/<NNN>) — нога И-15 обязана требовать манифест и здесь (адверсарий
# круга 1: на двери круга 1 проверка сидела только в явной --nnn-ветке,
# авто-спавн молча проходил rc 0). Авто-номер НЕ хардкодится: снимается из
# вывода первого вызова (отказ несёт «make_task: <NNN>»; дефектная дверь —
# «BRANCH=wip/<NNN>/<автор>»).
outv="$(bash "$DOOR" --author implementer --root "$R" 2>&1)"; rcv=$?
auto="$(printf '%s\n' "$outv" | grep -o 'make_task: [0-9][0-9][0-9]*' | head -n 1 | grep -o '[0-9][0-9][0-9]*')"
[ -n "$auto" ] || auto="$(printf '%s\n' "$outv" | grep -o 'BRANCH=wip/[0-9][0-9][0-9]*/' | head -n 1 | grep -o '[0-9][0-9][0-9]*')"
if [ "$rcv" -ne 1 ] || [ -z "$auto" ] || ! printf '%s\n' "$outv" | grep -Fq "нет манифеста make_task: $auto"; then
  printf 'КРАСНО: i15: авто-спавн без --nnn не отказан «нет манифеста make_task» (rc=%s, авто-номер=%s, вывод: %s)\n' "$rcv" "${auto:-?}" "$outv" >&2; exit 1
fi
wtv="$(printf '%s\n' "$outv" | sed -n 's/^WORKTREE=//p' | head -n 1)"
[ -n "$wtv" ] && [ -d "$wtv" ] && git -C "$R" worktree remove --force "$wtv" >/dev/null 2>&1 || true
[ -n "$auto" ] && git -C "$R" branch -D "wip/${auto}/implementer" >/dev/null 2>&1 || true
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
[ -s "$SCTX/${auto}.tsv" ] || { printf 'КРАСНО: i15: субъект не оставил манифест авто-номера: %s\n' "$SCTX/${auto}.tsv" >&2; exit 1; }

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

# (г) legacy-манифест внутри чекаута при отсутствии внешнего — именованный
# отказ, не fallback: устаревшее размещение дверью больше не читается
rm -f "$SCTX/777.tsv"
mkdir -p "$R/.omp/context"
printf '=== MANIFEST ===\nmap\tPROJECT.md\tmandatory\tprofile\n' >"$R/.omp/context/777.tsv"
outg="$(bash "$DOOR" --author implementer --nnn 777 --root "$R" 2>&1)"; rcg=$?
if [ "$rcg" -ne 1 ] || ! printf '%s\n' "$outg" | grep -Fq 'нет манифеста make_task: 777'; then
  printf 'КРАСНО: i15: дверь приняла legacy .omp/context вместо внешнего манифеста — fallback жив (rc=%s, вывод: %s)\n' "$rcg" "$outg" >&2; exit 1
fi

# (д) linked WT с общим .git — ОДИН внешний каталог, второй путь не заводится.
# База state на машине общая (чужие миры держат свои ключи), поэтому «один
# путь» наблюдается дельтой: манифест 777 перед WT-паком ОТСУТСТВУЕТ (убран
# ветвью г), после WT-пака ЖИВЁТ по тому же пути $SCTX, а НОВЫХ каталогов
# ключей за WT-пак не появилось — WT-пак пишет в общий каталог, не второй.
keys_before="$(ls "$base/dev-harness-project-state" 2>/dev/null | LC_ALL=C sort)"
[ ! -e "$SCTX/777.tsv" ] || { printf 'КРАСНО: i15: ветвь (г) не убрала внешний манифест 777\n' >&2; exit 1; }
git -C "$R" worktree add --detach "$W/wt-linked" main >/dev/null 2>&1 \
  || { printf 'КРАСНО: i15: linked WT не строится\n' >&2; exit 1; }
outd="$(bash "$SUBJ" --repo "$W/wt-linked" --role implementer --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rcd=$?
if [ "$rcd" -ne 0 ]; then
  printf 'КРАСНО: i15: пак из linked WT не строится (rc=%s, вывод: %s)\n' "$rcd" "$outd" >&2; exit 1
fi
[ -s "$SCTX/777.tsv" ] || { printf 'КРАСНО: i15: пак из linked WT не оставил манифест в общем внешнем state: %s\n' "$SCTX/777.tsv" >&2; exit 1; }
keys_after="$(ls "$base/dev-harness-project-state" 2>/dev/null | LC_ALL=C sort)"
[ "$keys_after" = "$keys_before" ] || {
  printf 'КРАСНО: i15: WT-пак завёл новый каталог ключа state (до: %s / после: %s)\n' "$keys_before" "$keys_after" >&2; exit 1; }
[ ! -e "$W/wt-linked/.omp" ] || { printf 'КРАСНО: i15: пак из WT загрязнил чекаут WT каталогом .omp\n' >&2; exit 1; }
[ -z "$(git -C "$W/wt-linked" status --porcelain)" ] || { printf 'КРАСНО: i15: пак из WT оставил грязь в чекауте WT\n' >&2; exit 1; }
# дверь из main видит тот же манифест (одна точка входа для обоих корней)
outdd="$(bash "$DOOR" --author implementer --nnn 777 --root "$R" 2>&1)"
if printf '%s\n' "$outdd" | grep -Fq 'нет манифеста make_task'; then
  printf 'КРАСНО: i15: дверь из main не увидела манифест, записанный из WT (вывод: %s)\n' "$outdd" >&2; exit 1
fi

# (е) небезопасный TMPDIR — именованный отказ ДО побочных эффектов, по разным
# формам Git (срез boundary-сверки 2026-11-13 на production-кандидате
# repair-sol-1112: все четыре формы дают rc 1 TMPDIR_INSIDE_MAIN, state внутри
# небезопасных TMPDIR не создаётся; см. 095-manifest-contract-delta-canonical.md)
refs_e="$(git -C "$R" for-each-ref | sha256sum)"
mkdir -p "$common/e-tmp" "$W/wt-linked/e-tmp" \
  || { printf 'КРАСНО: i15/е: тестовые TMPDIR не строятся\n' >&2; exit 1; }
# е1: TMPDIR внутри общего .git, вход main — отказ и двери, и сборщика
oute1="$(TMPDIR="$common/e-tmp" bash "$DOOR" --author implementer --nnn 777 --root "$R" 2>&1)"; rce1=$?
if [ "$rce1" -ne 1 ] || ! printf '%s\n' "$oute1" | grep -Fq 'TMPDIR_INSIDE_MAIN'; then
  printf 'КРАСНО: i15/е1: дверь из main приняла TMPDIR внутри общего .git (rc=%s, вывод: %s)\n' "$rce1" "$oute1" >&2; exit 1
fi
outw1="$(TMPDIR="$common/e-tmp" bash "$SUBJ" --repo "$R" --role implementer --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rcw1=$?
if [ "$rcw1" -ne 1 ] || ! printf '%s\n' "$outw1" | grep -Fq 'TMPDIR_INSIDE_MAIN'; then
  printf 'КРАСНО: i15/е1: сборщик принял TMPDIR внутри общего .git (rc=%s, вывод: %s)\n' "$rcw1" "$outw1" >&2; exit 1
fi
# е2: TMPDIR внутри ОБЩЕГО .git, вход linked WT (дверь — WT на ветке main за
# HEAD-гейтом живой двери; сборщик — detached linked WT, штатная 161a-форма)
git -C "$R" worktree add --force "$W/wt-main" main >/dev/null 2>&1 \
  || { printf 'КРАСНО: i15/е2: linked WT на main не строится\n' >&2; exit 1; }
oute2="$(TMPDIR="$common/e-tmp" bash "$DOOR" --author implementer --nnn 777 --root "$W/wt-main" 2>&1)"; rce2=$?
if [ "$rce2" -ne 1 ] || ! printf '%s\n' "$oute2" | grep -Fq 'TMPDIR_INSIDE_MAIN'; then
  printf 'КРАСНО: i15/е2: дверь из linked WT приняла TMPDIR внутри общего .git (rc=%s, вывод: %s)\n' "$rce2" "$oute2" >&2; exit 1
fi
outw2="$(TMPDIR="$common/e-tmp" bash "$SUBJ" --repo "$W/wt-linked" --role implementer --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rcw2=$?
if [ "$rcw2" -ne 1 ] || ! printf '%s\n' "$outw2" | grep -Fq 'TMPDIR_INSIDE_MAIN'; then
  printf 'КРАСНО: i15/е2: сборщик из linked WT принял TMPDIR внутри общего .git (rc=%s, вывод: %s)\n' "$rcw2" "$outw2" >&2; exit 1
fi
# е3: TMPDIR внутри ДРУГОГО связанного чекаута (worktree list), вход main —
# граница ВСЕХ чекаутов проекта, не только текущего корня
oute3="$(TMPDIR="$W/wt-linked/e-tmp" bash "$DOOR" --author implementer --nnn 777 --root "$R" 2>&1)"; rce3=$?
if [ "$rce3" -ne 1 ] || ! printf '%s\n' "$oute3" | grep -Fq 'TMPDIR_INSIDE_MAIN'; then
  printf 'КРАСНО: i15/е3: дверь не отказала TMPDIR внутри другого связанного чекаута (rc=%s, вывод: %s)\n' "$rce3" "$oute3" >&2; exit 1
fi
outw3="$(TMPDIR="$W/wt-linked/e-tmp" bash "$SUBJ" --repo "$R" --role implementer --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rcw3=$?
if [ "$rcw3" -ne 1 ] || ! printf '%s\n' "$outw3" | grep -Fq 'TMPDIR_INSIDE_MAIN'; then
  printf 'КРАСНО: i15/е3: сборщик не отказал TMPDIR внутри другого связанного чекаута (rc=%s, вывод: %s)\n' "$rcw3" "$outw3" >&2; exit 1
fi
# е4: отдельный несвязанный клон — общий .git он сам; TMPDIR внутри него —
# тот же отказ; ключ клона ОТЛИЧЕН от ключа main (ключ от канонического
# общего пути, не от случайных байтов или cwd)
git clone -q "$R" "$W/own" >/dev/null 2>&1 \
  || { printf 'КРАСНО: i15/е4: отдельный клон не строится\n' >&2; exit 1; }
mkdir -p "$W/own/.git/e-tmp"
oute4="$(TMPDIR="$W/own/.git/e-tmp" bash "$DOOR" --author implementer --nnn 777 --root "$W/own" 2>&1)"; rce4=$?
if [ "$rce4" -ne 1 ] || ! printf '%s\n' "$oute4" | grep -Fq 'TMPDIR_INSIDE_MAIN'; then
  printf 'КРАСНО: i15/е4: дверь из отдельного клона приняла TMPDIR внутри его .git (rc=%s, вывод: %s)\n' "$rce4" "$oute4" >&2; exit 1
fi
own_common="$(cd "$W/own/.git" && pwd -P)"
key_own="$(printf '%s' "$own_common" | sha256sum | cut -c1-16)"
[ "$key_own" != "$key" ] \
  || { printf 'КРАСНО: i15/е4: отдельный .git дал тот же ключ state, что общий .git main — ключ не от канонического общего пути\n' >&2; exit 1; }
# побочных эффектов нет: state внутри небезопасных TMPDIR не создан, refs те же
[ ! -e "$common/e-tmp/dev-harness-project-state" ] || { printf 'КРАСНО: i15/е: создан state внутри общего .git\n' >&2; exit 1; }
[ ! -e "$W/wt-linked/e-tmp/dev-harness-project-state" ] || { printf 'КРАСНО: i15/е: создан state внутри связанного чекаута\n' >&2; exit 1; }
[ ! -e "$W/own/.git/e-tmp/dev-harness-project-state" ] || { printf 'КРАСНО: i15/е: создан state внутри .git клона\n' >&2; exit 1; }
[ "$(git -C "$R" for-each-ref | sha256sum)" = "$refs_e" ] || { printf 'КРАСНО: i15/е: небезопасные вызовы изменили refs\n' >&2; exit 1; }
exit 0
