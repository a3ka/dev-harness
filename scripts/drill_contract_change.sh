#!/usr/bin/env bash
# Дрилл: изменение уставного документа ПО ПРОЦЕДУРЕ действительно принимается.
#
# Заведён потому, что механизм анти-плацебо доказывает только КРАСНОЕ: фикстура обязана завалить
# барьер. Законный путь зелёный по определению, и фикстурой он не выражается. Непроверенное зелёное
# ветвление — это ровно тот случай, когда защита выглядит работающей, а процедура не работает:
# тогда единственный законный способ изменить утверждённый текст закрыт, и правило начнут обходить,
# а не соблюдать. У нас это уже проверено на соседнем предмете — `drill_protected_exception.sh`.
#
# ПРОЦЕДУРА ЦЕЛИКОМ, как она объявлена планом 007:
#
#   1. контракт закоммичен, вердикт критика v1 первой строкой `accept`;
#   2. `freeze_contract.sh` → v1;
#   3. устав введён тегом `ustav/1`;
#   4. правка контракта ОДНИМ коммитом, который несёт и вердикт критика v2, и строку
#      `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: <путь> <причина>` в первой колонке;
#   5. `freeze_contract.sh` → v2;
#   6. `check_contract_frozen.sh` и `check_charter.sh` обязаны вернуть 0.
#
# Шаг 4 умышленно один коммит: разрешение, выданное заранее или задним числом, есть индульгенция
# (урок круга 2 по `ALLOW-ARTIFACT-DELETE`), и оба барьера это ловят. Дрилл проверяет, что
# ПРАВИЛЬНЫЙ порядок при этом проходит, а не только неправильный падает.
#
# Барьеры берутся РЯДОМ С СОБОЙ (`$(dirname $0)/…`) намеренно: так подмена подставного корня
# работает без флагов, и дрилл проверяет те барьеры, которые лежат вместе с ним, а не те, которые
# случайно нашлись в PATH.
#
# ЗЕЛЁНОЕ НАЗЫВАЕТСЯ ПОШАГОВО. Дрилл, печатающий один «ok» в конце, не даёт понять, какой из шести
# шагов процедуры сработал: рецидив «барьер молчит на зелёном» записан в `NABLIUDENIA.md` (Н-15) и
# трижды за одну пачку стоил лишних кругов правка-прогон.
#
#   bash scripts/drill_contract_change.sh
#
# Коды возврата: 0 — процедура принята, 1 — не принята, 2 — нечем проверить.
set -euo pipefail

# Унаследованные git-переменные меняют построение подставной истории ДО запуска проверяемых
# барьеров: адверсарий предъявил `GIT_DIR`, `GIT_INDEX_FILE` и `GIT_WORK_TREE` на механизме 4,
# каждая выводила соседний дрилл в код 2. Заявленный положительный контроль, который выключается
# окружением, контролем не является.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
# Канонический инструментарий для соседей барьера: копия дрилла в чужом
# каталоге (проверка анти-плацебо) берёт счётчик вызовов из него.
export HARNESS_TOOLS_ROOT="${HARNESS_TOOLS_ROOT:-${REPO:-$ROOT}}"

FREEZE="$HERE/freeze_contract.sh"
FROZEN="$HERE/check_contract_frozen.sh"
CHARTER="$HERE/check_charter.sh"

for b in "$FREEZE" "$FROZEN" "$CHARTER"; do
  [ -f "$b" ] || { printf 'NOT_IMPLEMENTED: рядом нет %s — нечего прогонять\n' "$(basename "$b")" >&2; exit 2; }
done
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

mkdir -p "$ROOT/tmp"
W="$(mktemp -d "$ROOT/tmp/drill-charter.XXXXXX")"
# bare-origin (контракт 078, правка вне зон по прямому слову владельца 2026-10-03,
# прецедент 54ff90f): toy-дерево $W без remote origin — lib_active_contracts.sh
# (fail-closed по живому ls-remote, §3-bis freeze_contract.sh) отказывает «авторитет
# недоступен», до предмета дрилла дело не доходит. Свежий пустой bare-origin рядом —
# активных 0 < 2, лимит пропускает, предмет дрилла (устав-процедура) остаётся
# единственным судимым. Тот же приём, что fixtures/freeze_contract/_repo.sh.
W_ORIGIN="$(mktemp -d "$ROOT/tmp/drill-charter-origin.XXXXXX")"
trap 'rm -rf "$W" "$W_ORIGIN"' EXIT

ok() { printf '  ok   %s\n' "$*" >&2; }
otkaz() {  # <шаг> <код> <файл вывода>
  printf 'ОТКАЗ: изменение устава по процедуре не принято на шаге «%s»: код %s\n' "$1" "$2" >&2
  printf 'Законный путь обязан быть зелёным, иначе правило начнут обходить, а не соблюдать.\n' >&2
  sed 's/^/  | /' "$3" >&2 || true
  exit 1
}

g() {
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$W" \
      -c user.name=Дрилл -c user.email=drill@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}

# Провал ПОСТРОЕНИЯ основания — это «нечем проверить», а не «процедура не работает». Иначе дефект
# окружения читался бы как дефект предмета, а ложная мера дороже отсутствующей.
base_or_skip() {
  "$@" && return 0
  printf 'NOT_IMPLEMENTED: не удалось построить подставную историю (%s) — окружение git мешает\n' "$1" >&2
  exit 2
}

out="$W/out.txt"

# ── 1. основание: контракт и вердикт критика v1 ───────────────────────────────
mkdir -p "$W/contracts" "$W/verdicts/critic" "$W/tmp"
printf '# контракт 001\n\nРАБОТА НЕ РАЗДАЁТСЯ: подставной контракт дрилла\n' > "$W/contracts/001-x.md"
printf 'accept\nвердикт критика v1\n' > "$W/verdicts/critic/contracts-001-v1.md"
printf '# норма\n'   > "$W/AGENTS.md"
printf '# роадмап\n' > "$W/ROADMAP.md"
# ВАКУУМНЫЙ CI-ПАРИТЕТ обязателен по той же причине, что и в fixtures/freeze_contract/
# _repo.sh (контракт 043, freeze-time backstop через check_precision_gate.sh →
# verify_ci_parity.sh): `freeze_contract.sh` на КАЖДОЙ попытке заморозки зовёт precision-гейт,
# а гейт последней задачей (в) зовёт `verify_ci_parity.sh`. На toy-дереве без `.github/`,
# `package.json` и `config/ci_parity_exceptions.txt` verify_ci_parity.sh даёт rc=2 «нечем
# проверить», гейт — rc=1 (это была ЛОЖНАЯ краснота: паритет не нарушен, его нельзя
# проверить), freeze — die. Три файла ниже делают сверку ВАКУУМНОЙ (ноль workflow-команд,
# ноль скриптов приёмки, ноль исключений — сверять нечего ни с одной стороны), а не ослабляют
# её: verify_ci_parity.sh возвращает rc=0 честно, потому что обеим сторонам сверки нечего
# предъявить друг другу. Прецедент architect: fixtures/freeze_contract/_repo.sh (f36eead) и
# fixtures/check_check_contract_ready/_doc027.py (c9d319d) — здесь для 4-го независимого
# toy-repo конструктора (drill_charter, tmp/drill-charter.*).
mkdir -p "$W/.github/workflows" "$W/config"
printf 'name: ci\non: push\njobs: {}\n' > "$W/.github/workflows/ci.yml"
printf '{"scripts": {}}\n' > "$W/package.json"
: > "$W/config/ci_parity_exceptions.txt"
base_or_skip env GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$W"
# Локальная идентичность нужна потому, что `freeze_contract.sh` зовёт `git tag -a` без `-c`: в
# герметичном окружении он иначе падает с `empty ident name`, и дрилл валил бы себя своей же пробой.
base_or_skip env GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$W" config user.name Дрилл
base_or_skip env GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$W" config user.email drill@local
base_or_skip env GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q --bare "$W_ORIGIN"
base_or_skip env GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$W" remote add origin "$W_ORIGIN"
base_or_skip g add -A
base_or_skip g commit -q -m 'основание: контракт, вердикт критика, норма и роадмап'
# [154] Старый предмет (след заморозки СТАРШЕ границы новых предметов): прежний §6в
# дословно. «Старым» предмет делает ДОСТУПНЫЙ снимок границы, а след предмета —
# его доказуемый предок. Снимок доставляется в мир ДРИЛЛА: настоящий коммит
# «доставленный снимок границы 154» (пустой коммит — содержимое явно доставленного
# снимка), а след предмета — тег id/CONTRACT/001 на его ПРЕДКЕ. Приватные копии
# замка и freeze получают SHA этого снимка ЯВНО: каноническая константа границы в
# production не подменяется молча. Пустой коммит после тега снимком границы НЕ
# является (контракт 154, И-7) — прежний маркерный путь снят.
#
# Почему приватные копии, а не pack-снимок канонической границы: копия дрилла в
# чужом каталоге (проверка анти-плацебо) лежит рядом с барьерами, а не в дереве
# харнесса, — артефакт снимка из дерева ей недоступен. Способ доставки — тот же,
# что в батарее 154 (probe.py: prepare_scripts) и в ремонте 187.
base_or_skip g tag id/CONTRACT/001
base_or_skip g commit -q --allow-empty -m 'доставленный снимок границы 154'
GRANICA154_SHA="$(git -C "$W" rev-parse HEAD)"
base_or_skip g tag toy/boundary154 "$GRANICA154_SHA"
# Приватный инструментарий дрилла: соседи — симлинки на соседей рядом, замок и
# freeze — копии с подставленным SHA доставленного снимка.
TOOLS154="$W/tools154"
mkdir -p "$TOOLS154/scripts"
for f in "$HERE"/*.sh; do
  b="$(basename "$f")"
  case "$b" in
    zamok_predmeta.sh|freeze_contract.sh) continue ;;
  esac
  ln -sf "$f" "$TOOLS154/scripts/$b"
done
for b in zamok_predmeta.sh freeze_contract.sh; do
  [ -f "$HERE/$b" ] || continue   # сосед-счётчик рядом может отсутствовать (копия дрилла в чужом каталоге)
  sed "s/5ca237e4e6bc980c460ede8ee6d85af8a33d0601/$GRANICA154_SHA/g" "$HERE/$b" > "$TOOLS154/scripts/$b"
  chmod +x "$TOOLS154/scripts/$b"
  grep -q "$GRANICA154_SHA" "$TOOLS154/scripts/$b" \
    || { printf 'NOT_IMPLEMENTED: в %s нет закреплённого SHA границы — нечем доставить снимок\n' "$b" >&2; exit 2; }
done
[ -f "$TOOLS154/scripts/freeze_contract.sh" ] \
  || { printf 'NOT_IMPLEMENTED: рядом нет freeze_contract.sh — нечем доставить границу\n' >&2; exit 2; }
# Барьер заморозки — приватная копия (граница доставлена); читатели устава и
# барьеров — НАСТОЯЩИЕ, рядом: их подмена проверяющим обязана быть видна дриллу.
FREEZE="$TOOLS154/scripts/freeze_contract.sh"
FROZEN="$HERE/check_contract_frozen.sh"
CHARTER="$HERE/check_charter.sh"
ok 'шаг 1: контракт и вердикт критика v1 закоммичены'

# ── 1б. toy-корень состояния станции (контракт 154) ───────────────────────────
# Заморозка пересчитывает платные START роли критика по журналу станции (тот же
# state, что и у фазы спавна). Подставной журнал дрилла: одна сессия критика по
# предмету 001 — позиция 1 свободна, расхода нет. Ключ журнала — тот же
# (repoId,subjectId), что считает замок: repoId — basename origin.
STATE="$W/state154"
mkdir -p "$STATE"
RID="$(basename "$(git -C "$W" remote get-url origin 2>/dev/null || printf '%s' "$W")")"
RID="${RID%.git}"
printf '{"t":"START","repoId":"%s","subjectId":"001","group":"harness","holder":"Crit001","klass":"sudja","rol":"critic","object":"%s","worktree":"-","branch":"-","at":"2020-01-01T00:00:00Z"}\n' \
  "$RID" "0000000000000000000000000000000000000001" > "$STATE/uchet.jsonl"

# ── 2. заморозка v1 ───────────────────────────────────────────────────────────
if ! bash "$FREEZE" contracts/001-x.md "контракт стабилен" "$W" "$STATE" > "$out" 2>&1; then
  otkaz 'заморозка v1' "$?" "$out"
fi
grep -qx 'v1' "$out" || otkaz 'заморозка v1 напечатала не v1' 0 "$out"
ok 'шаг 2: freeze_contract.sh выдал v1'

# ── 3. устав введён ───────────────────────────────────────────────────────────
base_or_skip g tag -a ustav/1 -m 'устав действует'
ok 'шаг 3: устав введён тегом ustav/1'

# ── 4. правка ОДНИМ коммитом: вердикт v2 и строка владельца ───────────────────
printf 'критерий уточнён по решению владельца\n' >> "$W/contracts/001-x.md"
printf 'accept\nвердикт критика v2\n' > "$W/verdicts/critic/contracts-001-v2.md"
base_or_skip g add -A
g commit -q -F - <<'MSG' || otkaz 'коммит правки со строкой владельца' "$?" "$out"
Контракт уточнён по решению владельца

РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/001-x.md критерий готовности расширен по прямому слову владельца
MSG
ok 'шаг 4: правка, вердикт v2 и строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ в ОДНОМ коммите'

# ── 5. заморозка v2 ───────────────────────────────────────────────────────────
if ! bash "$FREEZE" contracts/001-x.md "вторая версия по решению владельца" "$W" "$STATE" > "$out" 2>&1; then
  otkaz 'заморозка v2' "$?" "$out"
fi
grep -qx 'v2' "$out" || otkaz 'заморозка v2 напечатала не v2' 0 "$out"
ok 'шаг 5: freeze_contract.sh выдал v2'

# ── 6. оба барьера обязаны вернуть 0 ──────────────────────────────────────────
if ! bash "$FROZEN" "$W" > "$out" 2>&1; then
  otkaz 'check_contract_frozen.sh на законно изменённом контракте' "$?" "$out"
fi
grep -q 'заморожен v2' "$out" \
  || otkaz 'check_contract_frozen.sh вернул ноль, но не назвал проверенную версию' 0 "$out"
ok 'шаг 6а: check_contract_frozen.sh принял v2 и назвал её'

if ! bash "$CHARTER" "$W" > "$out" 2>&1; then
  otkaz 'check_charter.sh на правке с разрешением владельца' "$?" "$out"
fi
grep -q 'изменён с разрешения владельца: contracts/001-x.md' "$out" \
  || otkaz 'check_charter.sh вернул ноль, но разрешение в отчёте не названо — молчаливое принятие неотличимо от того, что барьер правки не заметил' 0 "$out"
ok 'шаг 6б: check_charter.sh принял правку и назвал разрешение'

printf '\nпроцедура принята целиком: шесть шагов, оба барьера зелёные и оба назвали предмет\n' >&2
