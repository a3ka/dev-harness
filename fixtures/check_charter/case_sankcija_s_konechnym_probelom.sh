# ПРИЧИНА: изменён без разрешения владельца
#
# Контракт 065, инвариант 1 (дословность, побайтово). Различающий вход против стаба
# «зачистка конечных пробелов» (вердикт d1b6c22, F-065-2: `sed 's/[[:space:]]*$//'`
# после дедупа проходил scoped-набор 11/11 зелёно): строка-санкция с КОНЕЧНЫМ
# ПРОБЕЛОМ в теле коммита ветки обязана попасть в тело merge БАЙТ-В-БАЙТ —
# нормализация пробелов запрещена (инвариант 1: «побайтовно равна», --cleanup=verbatim).
#
# ГДЕ ЖИВЁТ КРАСНОТА (Н-39): грамматика razreshil() строку без конечного пробела
# принимает (путь + непустая причина), поэтому БАРЬЕР такой стаб не ловит — на
# входе барьера обрезанная строка ведёт себя честно, требовать там красноту значило
# бы требовать ЛЖИ в диагнозе. Дефект стаба НАБЛЮДАЕМ на сверке байтов merge-тела,
# которую несёт сама фикстура ДО $BARRIER: cmp строки с конечным пробелом против
# извлечённой строки merge-тела. Стаб умирает ОТКАЗом этой сверки — фикстура не
# доходит до зелёного вызова барьера, и verify_antiplacebo даёт rc 1.
#
#   * зелёный контроль: коммит ветки создан `--cleanup=verbatim` (иначе git сам
#     стрипнул бы пробел при СОЗДАНИИ коммита — вход стал бы пустым); ленд
#     исполняет НАСТОЯЩИЙ land_agent.sh; фикстура сверяет байты (cmp) строки
#     с конечным пробелом в merge-теле; затем $BARRIER → rc 0;
#   * красное: merge построен `git merge --no-ff -m 'land: …'` БЕЗ переноса
#     строки → $BARRIER rc 1 «изменён без разрешения владельца» — перенос не
#     индульгенция, санкция действует только из ТЕЛА merge (инвариант 3).
#
# ДЕМАРКАЦИЯ (019): до ленда фикстура сверяет (cmp), что конечный пробел пережил
# создание коммита ВЕТКИ — иначе вход не различает стаб, и ОТКАЗ был бы ложью
# о входе, а не находкой.
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

# Эталон строки: конечный пробел перед \n — литеральный байт, виден в printf.
printf 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ: plans/001-p.md санкция с конечным пробелом \n' > "$WORK/expected_line"

# ── зелёный контроль: санкция с конечным пробелом перенесена байт-в-байт ───────
g "$R" branch wip/040/implementer main
g "$R" worktree add -q "$WORK/wt-green" wip/040/implementer
printf 'правка frozen-плана под санкцией с конечным пробелом\n' >> "$WORK/wt-green/plans/001-p.md"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-green" -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
# Тело коммита — из файла, --cleanup=verbatim: дефолтная зачистка strip срезала бы
# конечный пробел ещё при создании коммита, и вход перестал бы различать стаб.
{
  printf 'правка frozen-плана под санкцией с конечным пробелом\n'
  printf '\n'
  cat "$WORK/expected_line"
} > "$WORK/branch_msg.txt"
GIT_AUTHOR_NAME=implementer GIT_AUTHOR_EMAIL=implementer@dev-harness.local \
GIT_COMMITTER_NAME=implementer GIT_COMMITTER_EMAIL=implementer@dev-harness.local \
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-green" -c commit.gpgsign=false -c core.hooksPath=/dev/null \
  commit -q --cleanup=verbatim -F "$WORK/branch_msg.txt"

# ДЕМАРКАЦИЯ: конечный пробел обязан лежать в теле коммита ВЕТКИ — cmp байт-в-байт.
git -C "$R" log -1 --format=%B wip/040/implementer > "$WORK/branch_body"
grep -F 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ: plans/001-p.md' "$WORK/branch_body" | sed -n '1p' > "$WORK/branch_line"
cmp -s "$WORK/expected_line" "$WORK/branch_line" || {
  printf 'ОТКАЗ: вход неконформен — конечный пробел не пережил создание коммита ветки (нет --cleanup=verbatim у фикстуры)\n' >&2
  exit 1
}

bash "$REPO/scripts/land_agent.sh" --branch wip/040/implementer --worktree "$WORK/wt-green" --root "$R" || true
# СВЕРКА БАЙТОВ (предмет клетки): строка-санкция в merge-теле байт-в-байт равна
# строке из тела ветки, включая конечный пробел. grep -cF == 1: строка ровно одна;
# cmp: байты совпадают. sed-зачистка ловится здесь, ДО вызова барьера.
git -C "$R" log -1 --format=%B main > "$WORK/merge_body"
grep -qFx 'land: wip/040/implementer' "$WORK/merge_body" || {
  printf 'ОТКАЗ: первый абзац merge-сообщения не «land: wip/040/implementer»: %s\n' "$(cat "$WORK/merge_body")" >&2
  exit 1
}
[ "$(grep -cF 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ: plans/001-p.md' "$WORK/merge_body")" -eq 1 ] || {
  printf 'ОТКАЗ: строка-санкция в merge-теле не ровно одна: %s\n' "$(cat "$WORK/merge_body")" >&2
  exit 1
}
grep -F 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ: plans/001-p.md' "$WORK/merge_body" | sed -n '1p' > "$WORK/merge_line"
cmp -s "$WORK/expected_line" "$WORK/merge_line" || {
  printf 'ОТКАЗ: санкция перенесена НЕ байт-в-байт — конечный пробел срезан или изменён. ожидание: %s ; факт: %s\n' \
    "$(cat "$WORK/expected_line")" "$(cat "$WORK/merge_line")" >&2
  exit 1
}
"$BARRIER" "$R" || true   # ожидание: rc 0 — merge несёт дословную санкцию


# ── красное: merge без переноса строки-санкции ─────────────────────────────────
g "$R" branch wip/041/implementer main
g "$R" worktree add -q "$WORK/wt-red" wip/041/implementer
printf 'правка frozen-плана во втором входе пробы конечного пробела\n' >> "$WORK/wt-red/plans/001-p.md"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-red" -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
{
  printf 'правка frozen-плана во втором входе пробы конечного пробела\n'
  printf '\n'
  cat "$WORK/expected_line"
} > "$WORK/red_msg.txt"
GIT_AUTHOR_NAME=implementer GIT_AUTHOR_EMAIL=implementer@dev-harness.local \
GIT_COMMITTER_NAME=implementer GIT_COMMITTER_EMAIL=implementer@dev-harness.local \
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-red" -c commit.gpgsign=false -c core.hooksPath=/dev/null \
  commit -q --cleanup=verbatim -F "$WORK/red_msg.txt"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" -c user.name=orchestrator -c user.email=orchestrator@dev-harness.local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      merge --no-ff -m 'land: wip/041/implementer' wip/041/implementer >/dev/null 2>&1
"$BARRIER" "$R"
