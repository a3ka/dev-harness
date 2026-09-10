#!/usr/bin/env bash
# КРАСНОЕ фикс-раунда №2 контракта 023, ветвь (ii) — ПОСТОЯННЫЙ вход «манифест
# только на origin» для гейта явного номера (вердикт ревьюера da27fab, блокер:
# «scripts/spawn_agent.sh в 2939065 после живых ls-remote тега и refs/heads/main
# выполняет git cat-file -p "${origin_main_sha}:registry/contracts.tsv", но не
# выполняет обязательный контрактом путь „ls-remote шапки → fetch объекта →
# show". Поэтому честный полный резерв отвергается, если актуальный объект
# origin/main ещё не реплицирован локально; отказ ошибочно назван „не выдан
# авторитетом", хотя авторитет доступен и выдал пару»). Существующая spawn-фигура
# (red_gejt_javnogo_nomera.sh в1-в9) НЕ создаёт удалённый объект манифеста,
# отсутствующий локально: везде манифест-объект уже в локальном сторе (toy сам
# пушит церемонию). Этот вход строит ПАРУ toy: authority (церемония mint_rezerv)
# и subject (спавнящийся корень — клон origin ДО церемонии, получивший ТОЛЬКО тег
# моделью общих refs связки worktree): строка манифеста «N → <tag-object-sha>» с
# тем же tag-object-sha есть ТОЛЬКО на origin/main, объект НЕ реплицирован
# локальному. Эталон семантики — check_staged.sh после 94beb17 (fetch origin
# refs/heads/main между ls-remote шапки и cat-file).
#
# Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (А-82, форма red_* + прямой запуск):
# на ветке архитектора гейт ещё не починен (чинит фикс-пачка implementer в
# своей зоне), вход честно КРАСЕН до объединения (красное-до-реализации);
# зелёность докажет
# union-батарея оркестратора на объединённой ветке. Усиление пост-заморозкой —
# законно (прецедент 005/021).
#
# ВХОДЫ (метки м1/м2 локальны для файла; Н-39 — привязка стабов по КОДУ
# spawn_agent.sh, не по прозе):
#   м1 манифест только на origin: полный резерв парой toy (тег локально жив ∧
#      тег на origin ∧ строка манифеста на origin/main с тем же sha ∧ объект
#      манифеста НЕ реплицирован subject). Честный гейт: fetch приносит объект →
#      rc 0, WORKTREE/BRANCH=wip/N/architect напечатаны. Стаб «нет fetch»
#      (нынешний cat-file без fetch, дефект da27fab) умирает ЗДЕСЬ именованной
#      причиной: локальный cat-file не видит объект → ложно «не выдан
#      авторитетом» — честный полный резерв отвергнут. СЕГОДНЯ КРАСНОЕ;
#   м2 отказ fetch при живом ls-remote: та же пара toy, затем объект
#      манифест-коммита в bare-origin делается нечитаемым (chmod 000) — реклама
#      refs жива (ls-remote rc 0), чтение объекта нет (fetch rc ≠ 0). Честный
#      гейт: rc 1 «авторитет недоступен» (fail-closed; имя ОТДЕЛЬНОЕ от «не
#      выдан авторитетом» — da27fab: «отказ fetch обязан зваться „авторитет
#      недоступен"»). Стаб «подменённый fetch» (игнорирует/переименует отказ
#      fetch) умирает ЗДЕСЬ: падает в «не выдан авторитетом» — чужое имя.
#      СЕГОДНЯ КРАСНОЕ тем же классом.
#
# ОРАКУЛ В ПАМЯТИ ДО ВЫЗОВА (правило 8): ожидания (номер, ветка, строка
# манифеста, sha) снимаются с authority/origin в переменные ДО вызова субъекта;
# диск субъекта после вызова как истина не перечитывается (только диагностика
# отказов). Отпечаток входа печатается (NNN, toy-корни, sha) — два прогона
# различимы.
#
# ПАРАМЕТРИЗАЦИЯ (вердикт 57c8141 блокер 2): N1 940-964 · N2 965-999 —
# поддиапазоны вне занятых red_gejt (120-939) / red_dver (120-939) /
# red_priznanie (120-639); basename toy-корней и каталог-копия субъекта случайны
# (BARRIER_ROOT-паттерн); приёмка — ДВА прогона подряд с разными входами.
#
# Коды возврата: 0 — ворота пройдены (гейт с семантикой fetch); 1 — именованный
#               отказ (гейт без fetch / отказ fetch назван чужим именем / вход
#               построен неверно).
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
WORK="$(mktemp -d /tmp/red023-manifest.XXXXXX)"   # А-78: свежий WORK вне дерева
trap 'rm -rf "$WORK"' EXIT

# ── случайные входы: ОДИН процесс awk (srand от времени; числа черпаются разом).
mapfile -t RD < <(awk 'BEGIN{srand();
  printf "%03d\n", 940+int(rand()*25);
  printf "%03d\n", 965+int(rand()*35);
  for (i=0;i<3;i++) printf "%d\n", 10000000+int(rand()*89999999)}')
N1="${RD[0]}"; N2="${RD[1]}"

# Субъект — копия scripts/ под случайным именем (BARRIER_ROOT-паттерн).
SPAWN="$WORK/subj-${RD[2]}/spawn_agent.sh"
cp -r "$REPO/scripts" "$WORK/subj-${RD[2]}"
# shellcheck disable=SC1091
. "$HERE/_repo.sh"

# run_spawn <toy> <аргументы spawn>… → $out/$rc, worktree убран
run_spawn() {
  local toy="$1"; shift
  out="$(bash "$SPAWN" --root "$toy" "$@" 2>"$WORK/err")" && rc=0 || rc=$?
  local wt
  wt="$(printf '%s\n' "$out" | sed -n 's/^WORKTREE=//p' | head -1)"
  if [ -n "$wt" ] && [ -d "$wt" ]; then rm -rf "$wt"; fi
}

# build_pair <база-путём> <NNN>: ПАРА toy на общем bare-origin — authority
# (церемония) и subject (клон ДО церемонии + только тег после). Ставит
# ORIG/AUTH/SUBJ и оракул в память: TAGSHA (объект тега), ORIGIN_MAIN_SHA
# (живая шапка origin/main), MANIFEST_LINE («NNN → sha», грамматика — контракт
# 023 Демаркация: разделитель U+2192, sha — ША ОБЪЕКТА тега).
build_pair() {
  local base="$1" n="$2"
  AUTH="$base-auth"
  make_repo "$AUTH"
  ORIG="$(toy_origin "$AUTH")"
  SUBJ="$base-subj"
  # Клон ДО церемонии: subject разделяет историю с origin только по основанию —
  # объекты манифеста НЕ реплицированы (главное свойство входа).
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git clone -q "$ORIG" "$SUBJ"
  # Церемония ветви (i) ЦЕЛИКОМ в authority: тег + строка манифеста + оба пуша.
  mint_rezerv "$AUTH" "$n"
  # Subject получает ТОЛЬКО тег (модель общих refs связки worktree): тег жив
  # локально (шаг 1 гейта), манифест-объект остаётся только на origin.
  g "$SUBJ" fetch -q origin "refs/tags/id/CONTRACT/$n:refs/tags/id/CONTRACT/$n"
  TAGSHA="$(git -C "$AUTH" rev-parse "refs/tags/id/CONTRACT/$n")"
  ORIGIN_MAIN_SHA="$(git -C "$ORIG" rev-parse refs/heads/main)"
  MANIFEST_LINE="$n → $TAGSHA"
}

# ── м1: манифест только на origin — честный полный резерв обязан проходить ─────
build_pair "$WORK/kor-${RD[2]}-m1" "$N1"
# Свойства входа (ДО субъекта; неверно собранный вход — именованный отказ, а не
# молчаливая зелёность):
git -C "$SUBJ" show-ref --verify --quiet "refs/tags/id/CONTRACT/$N1" \
  || { printf 'ОТКАЗ: вход м1 построен неверно: тег id/CONTRACT/%s не жив локально в subject\n' "$N1" >&2; exit 1; }
if git -C "$SUBJ" cat-file -e "$ORIGIN_MAIN_SHA" 2>/dev/null; then
  printf 'ОТКАЗ: вход м1 построен неверно: объект origin/main %s УЖЕ реплицирован subject — вход не «манифест только на origin»\n' "$ORIGIN_MAIN_SHA" >&2
  exit 1
fi
[ -f "$SUBJ/registry/contracts.tsv" ] \
  && { printf 'ОТКАЗ: вход м1 построен неверно: манифест есть в рабочей копии subject\n' >&2; exit 1; }
[ "$(git -C "$AUTH" rev-parse HEAD)" = "$ORIGIN_MAIN_SHA" ] \
  || { printf 'ОТКАЗ: вход м1 построен неверно: authority HEAD ≠ шапке origin/main\n' >&2; exit 1; }
git -C "$AUTH" show 'HEAD:registry/contracts.tsv' | grep -Fqx "$MANIFEST_LINE" \
  || { printf 'ОТКАЗ: вход м1 построен неверно: строки манифеста «%s» нет на origin/main\n' "$MANIFEST_LINE" >&2; exit 1; }
printf 'отпечаток м1: N=%s subject=%s subj-copy=%s origin=%s origin_main=%s tag=%s\n' \
  "$N1" "$SUBJ" "$WORK/subj-${RD[2]}" "$ORIG" "$ORIGIN_MAIN_SHA" "$TAGSHA"
run_spawn "$SUBJ" --author architect --nnn "$N1"
if [ "$rc" -ne 0 ] \
   || ! printf '%s\n' "$out" | grep -qF 'WORKTREE=' \
   || ! printf '%s\n' "$out" | grep -qxF "BRANCH=wip/$N1/architect"; then
  printf 'ОТКАЗ (da27fab): гейт (ii) без fetch — честный полный резерв (манифест «%s» только на origin, объект не реплицирован) отвергнут/не завершён (rc %s, ожидан rc 0, BRANCH=wip/%s/architect): %s\n' \
    "$MANIFEST_LINE" "$rc" "$N1" "$(cat "$WORK/err")" >&2
  exit 1
fi

# ── м2: отказ fetch при живом ls-remote — имя «авторитет недоступен» ───────────
build_pair "$WORK/kor-$((RD[2]+1))-m2" "$N2"
OBJ="$ORIG/objects/${ORIGIN_MAIN_SHA:0:2}/${ORIGIN_MAIN_SHA:2}"
[ -f "$OBJ" ] \
  || { printf 'ОТКАЗ: вход м2 построен неверно: объект манифест-коммита %s не loose в origin (%s)\n' "$ORIGIN_MAIN_SHA" "$OBJ" >&2; exit 1; }
chmod 000 "$OBJ"
# Свойства входа (ДО субъекта): реклама refs жива, чтение объекта нет.
lsr="$(git -C "$SUBJ" ls-remote origin refs/heads/main 2>/dev/null)" && lsrc=0 || lsrc=$?
[ "$lsrc" -eq 0 ] && [ -n "$lsr" ] \
  || { printf 'ОТКАЗ: вход м2 построен неверно: ls-remote origin/main не отвечает после порчи объекта (rc %s)\n' "$lsrc" >&2; exit 1; }
git -C "$SUBJ" fetch -q origin refs/heads/main >/dev/null 2>&1 && frc=0 || frc=$?
[ "$frc" -ne 0 ] \
  || { printf 'ОТКАЗ: вход м2 построен неверно: fetch прошёл после порчи объекта — отказ не смоделирован\n' >&2; exit 1; }
if git -C "$SUBJ" cat-file -e "$ORIGIN_MAIN_SHA" 2>/dev/null; then
  printf 'ОТКАЗ: вход м2 построен неверно: объект %s реплицирован subject несмотря на отказ fetch\n' "$ORIGIN_MAIN_SHA" >&2
  exit 1
fi
printf 'отпечаток м2: N=%s subject=%s subj-copy=%s origin=%s origin_main=%s(объект нечитаем) tag=%s fetch_rc=%s\n' \
  "$N2" "$SUBJ" "$WORK/subj-${RD[2]}" "$ORIG" "$ORIGIN_MAIN_SHA" "$TAGSHA" "$frc"
run_spawn "$SUBJ" --author architect --nnn "$N2"
if [ "$rc" -ne 1 ] || ! grep -qF 'авторитет недоступен' "$WORK/err"; then
  printf 'ОТКАЗ (da27fab): отказ fetch обязан зваться «авторитет недоступен» — гейт назвал иначе/пустил (rc %s, ожидан rc 1 «авторитет недоступен»): %s\n' \
    "$rc" "$(cat "$WORK/err")" >&2
  exit 1
fi

exit 0
