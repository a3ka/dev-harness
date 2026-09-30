# ПРИЧИНА: изменён без разрешения владельца
#
# Контракт 065, инвариант 2 (полнота + дедуп ТОЛЬКО точных повторов). Различающий вход
# против стаба «дедуп по первому слову» (вердикт d1b6c22, F-065-1: `awk '!seen[$1]++'`
# проходил scoped-набор 11/11 зелёно): ДВЕ РАЗНЫЕ строки одного маркера
# РАЗРЕШИЛ-ВЛАДЕЛЕЦ: — одинаковое ПЕРВОЕ слово, РАЗНЫЕ пути и причины — обе обязаны
# попасть в тело merge. У всех РАЗРЕШИЛ-строк $1 один и тот же («РАЗРЕШИЛ-ВЛАДЕЛЕЦ:»),
# поэтому стаб теряет вторую молча: merge краснеет в CI уже после приземления.
# Однострочные входы приёмки (case_land_sankcija_ne_perenesena_v_merge.sh) этот стаб
# не различают — вторая строка маркера нужна ОБЯЗАТЕЛЬНО.
#
# Дополнительный повод входа: ТОЧНЫЙ повтор первой строки в теле коммита. Честный
# дедуп сворачивает его в одну строку (инвариант 2: «дедуп точных повторов»), поэтому
# merge-тело несёт каждую строку РОВНО один раз — проверяется grep -cFx == 1. Это
# различает и обратный стаб «дедупа нет вовсе» (вторая копия попала бы в merge).
#
#   * зелёный контроль: ленд исполняет НАСТОЯЩИЙ land_agent.sh; фикстура требует ОБЕ
#     строки в merge-теле (grep -cFx: ровно 1 каждая) ДО $BARRIER — стаб «дедуп по $1»
#     ловится этим ОТКАЗом сверки ещё до вызова барьера; затем $BARRIER → rc 0;
#   * красное: merge построен так, как его строит стаб дедупа — перенесена ТОЛЬКО
#     первая строка маркера, вторая потеряна (`git merge --no-ff -F -`) → $BARRIER
#     rc 1: AGENTS.md в дельте merge без строки «изменён без разрешения владельца».
#
# ВАЛИДНОСТЬ входа (демаркация, 019): до ленда фикстура сверяет, что ОБЕ разные строки
# лежат в теле коммита ветки (grep -F) — иначе вход не различает стаб, и ОТКАЗ фикстуры
# был бы ложью о входе, а не находкой.
#
# Серийные вызовы — `|| true` (А-32). Положительный контроль — до красного (А-73).
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"

R="$WORK/repo"
make_repo "$R"

# land-предпосылки — как в case_land_sankcija_ne_perenesena_v_merge.sh: замороженный
# контракт 900 с ЗОНА implementer — реестр ролей для И-9 land_agent.
mkdir -p "$R/verdicts/critic"
{
  printf '# контракт 900 (подставной, реестр ролей для land-фикстур 065)\n'
  printf '\n## Исполнители и зоны\n'
  printf 'ЗОНА implementer: scripts/\n'
} > "$R/contracts/900-fake.md"
printf 'accept\nвердикт критика\n' > "$R/verdicts/critic/contracts-900-v1.md"
g "$R" add -A
commit_all "$R" 'основание: контракт 900 с implementer в реестре'
g "$R" tag -a frozen/contracts/900/1 -m 'заморозка 900 для land-фикстур 065'

L1='РАЗРЕШИЛ-ВЛАДЕЛЕЦ: plans/001-p.md причина первой строки двухстрочного входа'
L2='РАЗРЕШИЛ-ВЛАДЕЛЕЦ: AGENTS.md причина второй строки другого пути того же маркера'

# ── зелёный контроль: две РАЗНЫЕ строки одного маркера + точный повтор первой ───
g "$R" branch wip/030/implementer main
g "$R" worktree add -q "$WORK/wt-green" wip/030/implementer
printf 'правка frozen-плана в двухстрочном входе\n' >> "$WORK/wt-green/plans/001-p.md"
printf 'правило 2: мера не должна врать о предмете\n' >> "$WORK/wt-green/AGENTS.md"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-green" -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
GIT_AUTHOR_NAME=implementer GIT_AUTHOR_EMAIL=implementer@dev-harness.local \
GIT_COMMITTER_NAME=implementer GIT_COMMITTER_EMAIL=implementer@dev-harness.local \
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-green" -c commit.gpgsign=false -c core.hooksPath=/dev/null \
  commit -q -F - <<MSG
правка двух уставных документов одной пачкой

$L1
$L2
$L1
MSG

# ДЕМАРКАЦИЯ: обе разные строки — и ТОЧНЫЙ повтор первой (ровно 2 вхождения) — обязаны
# лежать в теле коммита ветки: иначе вход не различает стаб, и ОТКАЗ фикстуры
# был бы ложью о входе, а не находкой.
bt="$(git -C "$R" log -1 --format=%B wip/030/implementer)"
printf '%s\n' "$bt" | grep -qF "$L1" || {
  printf 'ОТКАЗ: вход неконформен — первой строки нет в теле коммита ветки\n' >&2
  exit 1
}
printf '%s\n' "$bt" | grep -qF "$L2" || {
  printf 'ОТКАЗ: вход неконформен — второй строки (другой путь) нет в теле коммита ветки\n' >&2
  exit 1
}
rep="$(printf '%s\n' "$bt" | grep -cFx "$L1")"
[ "$rep" -eq 2 ] || {
  printf 'ОТКАЗ: вход неконформен — точного повтора первой строки в теле коммита ветки %s раз, ожидалось 2\n' "$rep" >&2
  exit 1
}

bash "$REPO/scripts/land_agent.sh" --branch wip/030/implementer --worktree "$WORK/wt-green" --root "$R" || true
mb="$(git -C "$R" log -1 --format=%B main)"
printf '%s\n' "$mb" | grep -qFx 'land: wip/030/implementer' || {
  printf 'ОТКАЗ: первый абзац merge-сообщения не «land: wip/030/implementer»: %s\n' "$mb" >&2
  exit 1
}
n1="$(printf '%s\n' "$mb" | grep -cFx "$L1")"
n2="$(printf '%s\n' "$mb" | grep -cFx "$L2")"
[ "$n1" -eq 1 ] || {
  printf 'ОТКАЗ: первая строка маркера в merge-теле %s раз (ожидалась ровно 1: точный повтор дедуплицируется, отсутствие — потеря): %s\n' "$n1" "$mb" >&2
  exit 1
}
[ "$n2" -eq 1 ] || {
  printf 'ОТКАЗ: вторая РАЗРЕШИЛ-строка другого пути в merge-теле %s раз, ожидалась 1 — дедуп обязан сравнивать ПОЛНЫЕ строки, не первое слово: %s\n' "$n2" "$mb" >&2
  exit 1
}
"$BARRIER" "$R" || true   # ожидание: rc 0 — merge несёт ОБЕ перенесённые строки


# ── красное: merge-тело стаба дедупа — ТОЛЬКО первая строка маркера ────────────
g "$R" branch wip/031/implementer main
g "$R" worktree add -q "$WORK/wt-red" wip/031/implementer
printf 'правка frozen-плана во втором входе двухстрочной пробы\n' >> "$WORK/wt-red/plans/001-p.md"
printf 'правило 3: область проверки важнее её порога\n' >> "$WORK/wt-red/AGENTS.md"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-red" -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
GIT_AUTHOR_NAME=implementer GIT_AUTHOR_EMAIL=implementer@dev-harness.local \
GIT_COMMITTER_NAME=implementer GIT_COMMITTER_EMAIL=implementer@dev-harness.local \
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-red" -c commit.gpgsign=false -c core.hooksPath=/dev/null \
  commit -q -F - <<MSG
правка двух уставных документов второй пробой

$L1
$L2
MSG
# merge-тело = то, что выдаёт стаб «дедуп по $1»: вторая строка маркера потеряна
{ printf 'land: wip/031/implementer\n'; printf '%s\n' "$L1"; } > "$WORK/red_merge_msg.txt"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" -c user.name=orchestrator -c user.email=orchestrator@dev-harness.local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      merge --no-ff --cleanup=verbatim -F "$WORK/red_merge_msg.txt" wip/031/implementer >/dev/null 2>&1
"$BARRIER" "$R"
