#!/usr/bin/env bash
# КРАСНАЯ ПРОБА-ПРЕДЪЯВЛЕНИЕ контракта 069 — мутант «кнопка Merge в UI GitHub».
#
# Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (прецедент А-82 / red_push_net_avtopusha,
# 022): прогон прямой, CI-раннер семьи это имя не подбирает. Файл — probe-only
# доказательство нормы 069 (роль, не код): слияние ВСЕГДА scripts/land_agent.sh,
# кнопка UI запрещена. Предъявляет ДВЕ красные стороны мутанта + зелёный контроль:
#
#   мутант А «кнопка на main»: merge --no-ff коммиттером GitHub <noreply@github.com>,
#     subject «Merge pull request #N …» БЕЗ маркера «land:» — уже посажен на main;
#     land_agent обязан ОТКАЗАТЬ пост-фактум легитимации: rc 1, именованный отказ
#     «не несёт коммитов относительно main» (И-1, правая ветвь — та же клетка класса,
#     что case_merzh_ne_orkestrator, с точной сигнатурой кнопки), main НЕ двинут;
#   мутант Б «Update branch кнопкой»: merge-коммит коммиттера GitHub В ДИАПАЗОНЕ
#     ветки (main..tip) — land_agent обязан отказать до merge: rc 1, именованный
#     отказ «имя вне реестра ролей: … committer GitHub …» (И-9: committer каждого
#     коммита диапазона обязан быть в реестре ЗОНА-строк замороженных контрактов),
#     main НЕ двинут;
#   зелёный контроль: честная ветка wip/001/implementer тем же вызовом — LANDED,
#     merge-коммит коммиттером orchestrator с маркером «land:» (assert_landed) —
#     барьер жив, предъявление не вечно-красное.
#
# Ожидание снято в память ДО вызова субъекта (правило 8): main_before; диск
# проверяемого как истина не перечитывается. Серийные вызовы — `|| true` (А-32).
# Identity-окружение чистое (урок 068): явные пары author/committer у КАЖДОГО
# коммита, наследуемых GIT_AUTHOR_*/GIT_COMMITTER_* нет.
#
# Коды возврата: 0 — обе красные стороны предъявлены, зелёный контроль жив;
# 1 — именованный отказ (мутант ушёл мимо барьера / игрушка сломана).
set -uo pipefail
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
BARRIER="$REPO/scripts/land_agent.sh"
WORK="$(mktemp -d /tmp/red069-knopka.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT

R="$WORK/repo"
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"
make_repo "$R"

kr=0; zl=0; otkaz=0

# ── Зелёный контроль: честный land той же формы ветки ───────────────────────
mk_wip "$R" wip/001/implementer "$WORK/wt-green"
commit_in "$WORK/wt-green" implementer implementer@dev-harness.local 'предмет в зоне'
mb="$(git -C "$R" rev-parse main)"
tip="$(git -C "$R" rev-parse refs/heads/wip/001/implementer)"
"$BARRIER" --branch wip/001/implementer --worktree "$WORK/wt-green" --root "$R" >/dev/null 2>&1 || true
assert_landed "$R" "$mb" "$tip" wip/001/implementer
zl=1

# ── Мутант А: кнопка «Merge pull request» УЖЕ посадила ветку на main ─────────
mk_wip "$R" wip/069/implementer "$WORK/wt-knopka"
commit_in "$WORK/wt-knopka" implementer implementer@dev-harness.local 'предмет PR'
GIT_AUTHOR_NAME=github-merge[bot] GIT_AUTHOR_EMAIL=noreply@github.com \
GIT_COMMITTER_NAME=GitHub GIT_COMMITTER_EMAIL=noreply@github.com \
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
git -C "$R" -c commit.gpgsign=false -c core.hooksPath=/dev/null \
  merge --no-ff -m 'Merge pull request #69 from a3ka/wip-069-implementer' wip/069/implementer >/dev/null 2>&1
# сигнатура кнопки обязана наблюдаться ДО пробы (вход построен, иначе игрушка сломана)
sig="$(git -C "$R" log -1 --format='%cn|%s' main)"
case "$sig" in
  'GitHub|Merge pull request #'*) ;;
  *) printf 'ОТКАЗ: сигнатура кнопки не построена на main: %s\n' "$sig" >&2; exit 1 ;;
esac
main_before="$(git -C "$R" rev-parse main)"
out_a="$("$BARRIER" --branch wip/069/implementer --worktree "$WORK/wt-knopka" --root "$R" 2>&1 || true)"
if printf '%s\n' "$out_a" | grep -qF 'не несёт коммитов относительно main' \
   && [ "$(git -C "$R" rev-parse main)" = "$main_before" ]; then
  kr=$((kr+1))
else
  printf 'ОТКАЗ: мутант А — land_agent не отказал кнопке пост-фактум: %s\n' "$out_a" >&2
  otkaz=1
fi

# ── Мутант Б: «Update branch» кнопкой — GitHub-merge В ДИАПАЗОНЕ ветки ───────
mk_wip "$R" wip/070/implementer "$WORK/wt-upd"
commit_in "$WORK/wt-upd" implementer implementer@dev-harness.local 'предмет второй ветки'
commit_in "$R" implementer implementer@dev-harness.local 'движение main'
GIT_AUTHOR_NAME=GitHub GIT_AUTHOR_EMAIL=noreply@github.com \
GIT_COMMITTER_NAME=GitHub GIT_COMMITTER_EMAIL=noreply@github.com \
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
git -C "$WORK/wt-upd" -c commit.gpgsign=false -c core.hooksPath=/dev/null \
  merge --no-ff -m 'Merge branch main into wip-070-implementer' main >/dev/null 2>&1
git -C "$R" log --format=%cn main..wip/070/implementer | grep -qxF 'GitHub' \
  || { printf 'ОТКАЗ: мутант Б — GitHub-committer не в диапазоне ветки, вход не построен\n' >&2; exit 1; }
main_before="$(git -C "$R" rev-parse main)"
out_b="$("$BARRIER" --branch wip/070/implementer --worktree "$WORK/wt-upd" --root "$R" 2>&1 || true)"
if printf '%s\n' "$out_b" | grep -qF 'имя вне реестра ролей' \
   && printf '%s\n' "$out_b" | grep -qF 'GitHub' \
   && [ "$(git -C "$R" rev-parse main)" = "$main_before" ]; then
  kr=$((kr+1))
else
  printf 'ОТКАЗ: мутант Б — land_agent не назвал GitHub вне реестра (И-9): %s\n' "$out_b" >&2
  otkaz=1
fi

printf 'ИТОГ 069-кнопка: красных предъявлено %s из 2, зелёных контролей %s из 1\n' "$kr" "$zl"
[ "$otkaz" = 0 ] && [ "$kr" = 2 ] && [ "$zl" = 1 ]
