#!/usr/bin/env bash
# Тестер = CI: гейт ПЕРЕД вызовом судей (решение владельца 2026-08-20, D4б).
#
# «Не зелёный — судью не звать»: адверсарий судит пачку только после того, как
# чистый чекаут внешнего CI прошёл по ЗАПУШЕННОМУ HEAD. Прогон на локальном
# дереве ничего не доказывает — «работает на моём» ловится именно actions/checkout.
#
# ПРОВЕРЯЕТСЯ ЖИВОЙ ПРОГОН, поэтому сам в CI не исполняется (круг: текущий прогон
# не завершён, пока идёт) — объявленное исключение паритета с причиной.
#
# Предмет по шагам, каждый отказ называет шаг и факт:
#   1. sha (умолчание HEAD) разрешается в коммит корня;
#   2. sha лежит на origin/main (git merge-base --is-ancestor): незапушенное
#      не имеет прогона CI вовсе — «судить нечего» называется явно;
#   3. GitHub API отдаёт check-runs коммита (curl; GITHUB_TOKEN опционален —
#      публичному репозиторию хватит и без него);
#   4. прогонов ≥ 1 и ВСЕ conclusion == success.
#
#   bash scripts/check_ci_gate.sh [корень] [sha] [--check-row <object_id>]
#
# Коды возврата: 0 — CI зелёный по запушенному коммиту, 1 — отказ с названной
# причиной, 2 — нечем проверять (нет curl/jq/git).
#
# Делегат строк check журнала 094 (контракт 094, Решение 3, ПЕРЕСЕЧЕНИЕ 087/094):
#   bash scripts/check_ci_gate.sh <корень> <merge-sha> --check-row <object_id>
# по зелёному CI-сигналу пишет строку
#   check<TAB><object_id><TAB><имя><TAB><ok|fail><TAB><run><TAB><wfsha><TAB><дерево>
# в append-only журнал registry/candidates.tsv (относительно cwd вызывающего;
# создаётся по требованию — Р2-2: журнал реален). дерево = <sha>^{tree} (Б3:
# обвязка судит подготовленный merge по ДЕРЕВУ объекта, дверь сверяет его
# литерально с MERGE^{tree}); wfsha = sha256 ПОЛНОГО реестра на ПЕРВОМ
# родителе (base; И-4б: единая доверенная версия для всех ключей разом);
# имя/статус — структурное сопоставление check-runs по имени step-строк
# (посторонний зелёный workflow не закрывает обязательное имя, И-4).
# run — монотонный по object_id: max(run строк объекта) + 1.
# Р2-2 круга 3: T094_* env-гейты умерли — вызов аргументом CLI из порядка
# ленда роли (roles/orchestrator.md). Без --check-row семантика 087 неизменна.
# rc гейта НЕ зависит от успеха записи (side-effect журнала).
set -euo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DATABASE \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT=""; SHA_ARG=""; CR_OID=""
while [ $# -gt 0 ]; do
  case "$1" in
    --check-row) CR_OID="${2:?--check-row: object_id}"; shift 2 ;;
    *) if [ -z "$ROOT" ]; then ROOT="$1";
       elif [ -z "$SHA_ARG" ]; then SHA_ARG="$1"
       else die "неизвестный аргумент: $1"; fi
       shift ;;
  esac
done
ROOT="${ROOT:-$(cd "$SELF_DIR/.." && pwd)}"
SHA_ARG="${SHA_ARG:-HEAD}"

die()  { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

command -v git  >/dev/null 2>&1 || skip "нет git — историю прочитать нечем"
command -v curl >/dev/null 2>&1 || skip "нет curl — ответ CI не получить"
command -v jq   >/dev/null 2>&1 || skip "нет jq — ответ CI не разобрать"
[ -d "$ROOT" ] || die "корня нет: $ROOT"
ROOT="$(cd "$ROOT" && pwd)"
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 || die "$ROOT не репозиторий git"

g() { git -C "$ROOT" "$@"; }

# 1. sha
sha="$(g rev-parse --verify --quiet "${SHA_ARG}^{commit}" || true)"
[ -n "$sha" ] || die "коммит не разрешается: $SHA_ARG"
short="$(printf '%s' "$sha" | head -c 12)"

# 2. запушен ли: sha обязан быть достижим от origin/main
g rev-parse --verify --quiet refs/remotes/origin/main >/dev/null 2>&1 \
  || die "ветки origin/main нет локально — прогон CI по $short не существует; сделай fetch"
g merge-base --is-ancestor "$sha" refs/remotes/origin/main \
  || die "коммит $short не на origin/main — CI по нему не запускался; запушь и дождись прогона"

# 3. репозиторий из remote origin (ssh и https формы), токен опционален
remote_url="$(g remote get-url origin 2>/dev/null || true)"
[ -n "$remote_url" ] || die "remote origin не объявлен — репозиторий CI не узнать"
repo="$(printf '%s' "$remote_url" \
  | sed -nE 's#^(ssh://git@github\.com/|git@github\.com:|https://github\.com/)([^/]+)/(.+?)(\.git)?$#\2/\3#p' | head -1)"
repo="$(printf '%s' "$repo" | sed -E 's/\.git$//')"
[ -n "$repo" ] || die "из «$remote_url» не извлекается OWNER/REPO github — гейт понимает ssh://git@github.com/, git@github.com: и https://github.com/ формы"

auth=()
if [ -n "${GITHUB_TOKEN:-}" ]; then
  auth=(-H "Authorization: Bearer $GITHUB_TOKEN")
fi

# 4. check-runs: любой сбой сети/HTTP — «не ответил», не молчание
if ! body="$(curl -fsS -m 20 \
        -H 'Accept: application/vnd.github+json' \
        -H 'X-GitHub-Api-Version: 2022-11-28' \
        "${auth[@]}" \
        "https://api.github.com/repos/${repo}/commits/${sha}/check-runs?per_page=100" 2>&1)"; then
  die "CI не ответил по $short (curl): $(printf '%s' "$body" | head -2 | tr '\n' ' ')"
fi
total="$(printf '%s' "$body" | jq -r '.total_count // -1' 2>/dev/null)" || total=-1
[ "$total" -ge 0 ] || die "ответ CI не разобран: total_count нет — $(printf '%s' "$body" | head -c 200)"
[ "$total" -gt 0 ] || die "прогонов CI по $short нет: чек-раны пусты — workflow не запускался"

bad_run="$(printf '%s' "$body" | jq -r '[.check_runs[] | select((.conclusion // "") != "success")][0] | if . then (.name + " → " + (.conclusion // "без завершения")) else "" end')"
if [ -n "$bad_run" ]; then
  die "CI не зелёный по $short: $bad_run — судью не звать, чинить пачку"
fi

printf '  ok   CI зелёный: проверок %s, все success, по %s (%s)\n' "$total" "$short" "$repo" >&2

# ── поставка строк check журнала 094 (после зелёного CI; Р2-2) ───────────────
if [ -n "$CR_OID" ]; then
  _t94_journal="registry/candidates.tsv"
  printf '%s' "$CR_OID" | grep -qE '^[0-9a-f]{64}$' || _t94_journal=""
  if [ -n "$_t94_journal" ]; then
    # дерево ИСПОЛНЕННОГО: судит подготовленный merge — sha^{tree} (Б3)
    _t94_tree="$(g rev-parse --verify --quiet "${sha}^{tree}" 2>/dev/null || true)"
    # доверенная версия определений: ПОЛНЫЙ реестр на ПЕРВОМ родителе (base; И-4б)
    _t94_base="$(g rev-parse --verify --quiet "${sha}^1" 2>/dev/null || true)"
    _t94_wfsha="$(g show "${_t94_base}:registry/ci-steps.tsv" 2>/dev/null | sha256sum | cut -d' ' -f1)"
    if [ -n "$_t94_tree" ] && [ -n "$_t94_wfsha" ]; then
      # имена обязательных проверок — step-строки реестра на base (И-0 083)
      _t94_names="$(g show "${_t94_base}:registry/ci-steps.tsv" 2>/dev/null \
        | sed -nE 's/^step[ \t]+([A-Za-z0-9._:-]+)[ \t]+[0-9]+.*/\1/p' || true)"
      _t94_pass="$(printf '%s' "$body" | jq -r '.check_runs[] | select((.conclusion // "") == "success") | .name' 2>/dev/null || true)"
      mkdir -p "$(dirname "$_t94_journal")" 2>/dev/null || true
      # Журнал создаётся по требованию (Р2-2): писатель — первый, кто его коснулся.
      [ -f "$_t94_journal" ] || : >"$_t94_journal"
      # run — монотонный по object_id: max(run строк объекта) + 1
      _t94_run=0
      while IFS=$'\t' read -r _k _o _n _s _rn _w _t; do
        [ "$_k" = "check" ] && [ "$_o" = "$CR_OID" ] || continue
        case "$_rn" in ''|*[!0-9]*) continue ;; esac
        [ "$_rn" -gt "$_t94_run" ] 2>/dev/null && _t94_run="$_rn" || true
      done <"$_t94_journal"
      _t94_run=$((_t94_run + 1))
      for _t94_name in $_t94_names; do
        _t94_status="fail"
        case " $_t94_pass " in *" $_t94_name "*) _t94_status="ok" ;; esac
        # Если журнал не оканчивается \n — разделитель, иначе строка склеится
        # с хвостом и потребители (дверь/done_contract) её не отделят.
        if [ -s "$_t94_journal" ] && [ "$(tail -c 1 "$_t94_journal" | wc -l)" -eq 0 ]; then
          printf '\n' >>"$_t94_journal" || true
        fi
        printf 'check\t%s\t%s\t%s\t%s\t%s\t%s\n' \
          "$CR_OID" "$_t94_name" "$_t94_status" "$_t94_run" "$_t94_wfsha" "$_t94_tree" \
          >>"$_t94_journal" \
          || printf 'ОТКАЗ: check-строка не дописана: %s %s\n' "$_t94_journal" "$_t94_name" >&2
      done
      unset _t94_names _t94_pass _t94_name _t94_status _t94_run _t94_wfsha _t94_tree _t94_base
    fi
  fi
  unset _t94_journal
fi
