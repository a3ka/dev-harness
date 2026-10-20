#!/usr/bin/env bash
# Проба проводки контракта 110 — fixtures/workshop_project/done_volny_110/provodka.sh.
# Закрывает БД10 вердикта contracts-110-krug1-fail: зелёный probe.sh + зелёный
# verify_ci_parity + зелёный check_provodka НЕ доказывают, что в CI запускается
# именно батарея 110 (guard_is_wired мерит basename «probe», которому подходит
# посторонний ключ check:measure-probe). Здесь — ТОЧНОЕ соответствие:
#   1) package.json: scripts[KEY] == «bash fixtures/workshop_project/done_volny_110/probe.sh»
#      (полный путь, не basename);
#   2) registry/ci-steps.tsv: строка step<TAB>KEY<TAB><вес><TAB>npm run KEY;
#   3) .github/workflows/ci.yml: ключ KEY присутствует (сгенерированный CI).
# Не-плацебо (самопроверка чекера на синтетике ДО суда живого дерева):
#   - деко: ключ указывает на ЧУЖОЙ probe.sh (тот же basename) — чекер ОБЯЗАН
#     отказать; пропустил деко — сам красен, а не дерево;
#   - положительный контроль: синтетическое дерево с точным значением — чекер
#     обязан пройти.
# rc 0 — батарея 110 подключена своим ключом; rc 1 — именованный отказ;
# rc 2 — NOT_IMPLEMENTED (нет python-дерева проверки/инструментов).
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd -P)"
TOOLS="$(cd "$HERE/../../.." && pwd -P)"

KEY='check:done-volny-110-family-selftest'
BATTERY_CMD='bash fixtures/workshop_project/done_volny_110/probe.sh'

die() { printf 'проводка 110: %s\n' "$*" >&2; exit 1; }

command -v jq >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет jq\n' >&2; exit 2; }
[ -f "$TOOLS/fixtures/workshop_project/done_volny_110/probe.sh" ] \
  || die 'батарея 110 не существует: fixtures/workshop_project/done_volny_110/probe.sh'

# check_tree <корень> → rc: 0 подключено; 1 ключ/путь в package.json не те;
# 2 нет строки в ci-steps; 3 ключа нет в сгенерированном CI.
check_tree() {
  local root="$1" val
  val="$(jq -r --arg k "$KEY" '.scripts[$k] // ""' "$root/package.json" 2>/dev/null || true)"
  [ "$val" = "$BATTERY_CMD" ] || return 1
  awk -F'\t' -v k="$KEY" -v cmd="npm run $KEY" \
    '$1 == "step" && $2 == k && $4 == cmd { found = 1 }
     END { exit !found }' "$root/registry/ci-steps.tsv" 2>/dev/null || return 2
  grep -Fq "$KEY" "$root/.github/workflows/ci.yml" 2>/dev/null || return 3
  return 0
}

# ── самопроверка чекера: синтетика в одноразовом каталоге ─────────────────────
SELF="$(mktemp -d)"
trap 'rm -rf "$SELF"' EXIT
mkdir -p "$SELF/ok/registry" "$SELF/ok/.github/workflows" \
         "$SELF/decoy/registry" "$SELF/decoy/.github/workflows"
printf '{"scripts":{"%s":"%s"}}\n' "$KEY" "$BATTERY_CMD" > "$SELF/ok/package.json"
printf 'step\t%s\t2\tnpm run %s\n' "$KEY" "$KEY" > "$SELF/ok/registry/ci-steps.tsv"
printf 'run: npm run %s\n' "$KEY" > "$SELF/ok/.github/workflows/ci.yml"
check_tree "$SELF/ok" || die 'чекер не проходит положительный контроль (синтетика с точным подключением)'
# деко: тот же basename probe, чужой путь; ключи/строки на месте
printf '{"scripts":{"%s":"bash fixtures/workshop_project/rezhim_996/probe.sh"}}\n' \
  "$KEY" > "$SELF/decoy/package.json"
printf 'step\t%s\t2\tnpm run %s\n' "$KEY" "$KEY" > "$SELF/decoy/registry/ci-steps.tsv"
printf 'run: npm run %s\n' "$KEY" > "$SELF/decoy/.github/workflows/ci.yml"
check_tree "$SELF/decoy" && die 'чекер пропустил деко: чужой probe.sh под ключом 110'

# ── суд живого дерева ─────────────────────────────────────────────────────────
case "$(check_tree "$TOOLS"; printf '%s' "$?")" in
  0) printf 'проводка 110: ключ %s ведёт в батарею 110 (package.json + ci-steps + ci.yml)\n' "$KEY"
     exit 0 ;;
  1) die "npm-ключ $KEY в package.json отсутствует или ведёт не в батарею 110 ($BATTERY_CMD)" ;;
  2) die "строка step/$KEY отсутствует в registry/ci-steps.tsv" ;;
  3) die "ключ $KEY отсутствует в сгенерированном .github/workflows/ci.yml (gen_ci_steps.sh --write)" ;;
  *) die 'неизвестный исход проверки дерева' ;;
esac
