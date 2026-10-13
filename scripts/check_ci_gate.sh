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
# Два режима (контракт 098, решение 2; без флага семантика 4б/087 НЕ меняется):
#
# 1. Гейт 4б/087 — «все check-runs»:
# Предмет по шагам, каждый отказ называет шаг и факт:
#   1. sha (умолчание HEAD) разрешается в коммит корня;
#   2. sha лежит на origin/main (git merge-base --is-ancestor): незапушенное
#      не имеет прогона CI вовсе — «судить нечего» называется явно;
#   3. GitHub API отдаёт check-runs коммита (curl; GITHUB_TOKEN опционален —
#      публичному репозиторию хватит и без него);
#   4. прогонов ≥ 1 и ВСЕ conclusion == success.
#
#   bash scripts/check_ci_gate.sh [корень] [sha]
#   bash scripts/check_ci_gate.sh <sha>        # форма 008: один аргумент — sha
#                                              # (так зовёт judge_gate.sh; корень
#                                              # — каталог скрипта)
#
# 2. Писатель строки check (контракт 098, решение 2; Р4-3б–г гасятся):
#
#   bash scripts/check_ci_gate.sh <корень> <M-sha> --check-row <object_id> <ключ>
#
# Регламент владельца 2026-10-13-perehodnyj-reglament.md:85 (подписан):
# «Требование `check_ci_gate.sh` о достижимости кандидата из `origin/main`
# заменяется проверкой опубликованного кандидата на **нецелевой ссылке**. Для
# первого исправляющего PR внешний CI удостоверяется независимо по GitHub API;
# самоподтверждение изменённым кодом кандидата недостаточно.»
# В писателе требования «M на origin/main» НЕТ: дерево исполнения —
# `M-sha^{tree}` ИЗ АРГУМЕНТА (доказательство ДО публикации). Сопоставление
# СТРУКТУРНОЕ: имя прогона ЛИТЕРАЛЬНО == <ключ> (подстрока display-имени больше
# не источник истины — Р4-3в), прогон обязан стоять на коммите M-sha
# (head_sha); ПРОИСХОЖДЕНИЕ — ИЗ ОТВЕТА CI, не из локальной доски писателя
# (блокер критика круга 2): исполнитель прогона (поле app.slug ответа)
# сверяется литерально с пином ciApp= принятой политики, sha256 ИСПОЛНЕННОГО
# определения (поле wfsha ответа) — с sha256 принятого файла
# harness/checks/<ключ>.cmd; неподходящее происхождение — именованный отказ, не
# перебор до подходящего. Отбор — ПОСЛЕДНИЙ одноимённый прогон по id, исход
# прогона НЕ влияет на выбор; порядок сверок head_sha → исполнитель → версия →
# заключение (чужой красный прогон не порождает ни ok, ни fail). Последний
# доверенный прогон записывается В ОБЕ СТОРОНЫ (арбитраж 098): success →
# строка ok, rc 0; завершённый с иным заключением → строка fail и rc 1 —
# отрицательный результат есть факт журнала, прежний ok с меньшим run им
# перекрывается; не завершён — именованный отказ без строки (Н-204: частичный
# прогон ≠ вердикт); нет одноимённого прогона на M — «нет обязательной
# проверки». Журнал — <корень>/registry/candidates.tsv принятой стороны
# (вне проверяемой ветки, Б-6). Лишние аргументы — именованный отказ rc 1,
# не 127 (Р4-3г).
#
# Коды возврата: 0 — CI зелёный по запушенному коммиту / строка check записана,
# 1 — отказ с названной причиной, 2 — нечем проверять (нет curl/jq/git).
set -euo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DATABASE \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

die()  { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

command -v git  >/dev/null 2>&1 || skip "нет git — историю прочитать нечем"
command -v curl >/dev/null 2>&1 || skip "нет curl — ответ CI не получить"
command -v jq   >/dev/null 2>&1 || skip "нет jq — ответ CI не разобрать"

MODE=g087
if [ "${3:-}" = "--check-row" ]; then MODE=writer; fi

if [ "$MODE" = writer ]; then
  # ── писатель строки check (контракт 098, решение 2; см. шапку) ────────────
  [ $# -eq 5 ] || die "check-row: <корень> <M-sha> --check-row <object_id> <ключ> — аргументов $# , нужно 5 (лишние аргументы отвергаются именованным отказом, не 127)"
  ROOT="$1"; MSHA="$2"; OID="$4"; KEY="$5"
  case "$OID" in ''|*[!0-9a-f]*) die "object_id не 64 hex: $OID" ;; esac
  [ "${#OID}" -eq 64 ] || die "object_id не 64 hex: $OID"
  case "$MSHA" in ''|*[!0-9a-f]*) die "sha не 40 hex: $MSHA" ;; esac
  [ "${#MSHA}" -eq 40 ] || die "sha не 40 hex: $MSHA"
  case "$KEY" in ''|*[!A-Za-z0-9._-]*) die "ключ вне алфавита: $KEY" ;; esac
  [ -d "$ROOT" ] || die "корня нет: $ROOT"
  ROOT="$(cd "$ROOT" && pwd)"
  git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 || die "$ROOT не репозиторий git"
  JOURNAL="$ROOT/registry/candidates.tsv"
  [ -f "$JOURNAL" ] || die "журнал: нет файла: $JOURNAL"
  mand="$(sed -nE 's/^mandatory=//p' "$ROOT/harness/policy" | head -1)"
  [ -n "$mand" ] || die "политика принятой стороны: нет mandatory"
  case ",$mand," in *",$KEY,"*) ;; *) die "ключ вне обязательных: $KEY" ;; esac
  ciapp="$(sed -nE 's/^ciApp=//p' "$ROOT/harness/policy" | head -1)"
  [ -n "$ciapp" ] || die "политика принятой стороны: нет ciApp"
  DEFF="$ROOT/harness/checks/$KEY.cmd"
  [ -f "$DEFF" ] || die "нет доверенного определения: $KEY"
  wfsha="$(sha256sum <"$DEFF" | cut -d' ' -f1)"
  # дерево ИСПОЛНЕНИЯ — из аргумента: требования «на origin/main» НЕТ (098)
  mtree="$(git -C "$ROOT" rev-parse --verify --quiet "$MSHA^{tree}" 2>/dev/null || true)"
  [ -n "$mtree" ] || die "коммит не разрешается: $MSHA"
  remote_url="$(git -C "$ROOT" remote get-url origin 2>/dev/null || true)"
  [ -n "$remote_url" ] || die "remote origin не объявлен — репозиторий CI не узнать"
  repo="$(printf '%s' "$remote_url" \
    | sed -nE 's#^(ssh://git@github\.com/|git@github\.com:|https://github\.com/)([^/]+)/(.+?)(\.git)?$#\2/\3#p' | head -1)"
  repo="$(printf '%s' "$repo" | sed -E 's/\.git$//')"
  [ -n "$repo" ] || die "из «$remote_url» не извлекается OWNER/REPO github — гейт понимает ssh://git@github.com/, git@github.com: и https://github.com/ формы"
  auth=()
  if [ -n "${GITHUB_TOKEN:-}" ]; then auth=(-H "Authorization: Bearer $GITHUB_TOKEN"); fi
  if ! body="$(curl -fsS -m 20 -H 'Accept: application/vnd.github+json' \
        -H 'X-GitHub-Api-Version: 2022-11-28' "${auth[@]}" \
        "https://api.github.com/repos/${repo}/commits/${MSHA}/check-runs?per_page=100" 2>&1)"; then
    die "CI не ответил по $MSHA (curl): $(printf '%s' "$body" | head -2 | tr '\n' ' ')"
  fi
  total="$(printf '%s' "$body" | jq -r '.total_count // -1' 2>/dev/null)" || total=-1
  [ "$total" -ge 0 ] || die "ответ CI не разобран: total_count нет — $(printf '%s' "$body" | head -c 200)"
  # имя — ЛИТЕРАЛЬНОЕ равенство (не подстрока); отбор — ПОСЛЕДНИЙ одноимённый
  # прогон по id, исход прогона НЕ влияет на выбор (арбитраж 098)
  best="$(printf '%s' "$body" | jq -c --arg k "$KEY" '[.check_runs[] | select(.name == $k)] | sort_by(.id) | last' 2>/dev/null || true)"
  { [ -n "$best" ] && [ "$best" != "null" ]; } || die "нет обязательной проверки: $KEY"
  rid="$(printf '%s' "$best" | jq -r '.id' 2>/dev/null || true)"
  concl="$(printf '%s' "$best" | jq -r '.conclusion // ""' 2>/dev/null || true)"
  hsha="$(printf '%s' "$best" | jq -r '.head_sha // ""' 2>/dev/null || true)"
  case "$rid" in ''|*[!0-9]*) die "ответ CI: id прогона не разобран: $KEY" ;; esac
  [ "$hsha" = "$MSHA" ] || die "прогон не того коммита: $KEY"
  aslg="$(printf '%s' "$best" | jq -r '.app.slug // ""' 2>/dev/null || true)"
  # исполнитель прогона — пин ciApp политики; происхождение РАНЬШЕ заключения
  # (чужой красный прогон не пишет fail — арбитраж 098, порядок сверок)
  [ "$aslg" = "$ciapp" ] || die "проверка чужой обвязки: $KEY"
  wfr="$(printf '%s' "$best" | jq -r '.wfsha // ""' 2>/dev/null || true)"
  # происхождение — поле wfsha ОТВЕТА CI; локально вычисленный хеш источником
  # строки не является (блокер критика круга 2)
  [ "$wfr" = "$wfsha" ] || die "проверка не доверенной версии: $KEY"
  [ -n "$concl" ] || die "прогон не завершён: $KEY (Н-204: частичный прогон ≠ вердикт)"
  if [ "$concl" != "success" ]; then
    # отрицательный результат — ФАКТ журнала: прежний ok с меньшим run
    # перекрывается (арбитраж 098); дверь судит по последней строке по run
    printf 'check\t%s\t%s\tfail\t%s\t%s\t%s\n' "$OID" "$KEY" "$rid" "$wfsha" "$mtree" >>"$JOURNAL"
    die "обязательная проверка красна: $KEY"
  fi
  printf 'check\t%s\t%s\tok\t%s\t%s\t%s\n' "$OID" "$KEY" "$rid" "$wfsha" "$mtree" >>"$JOURNAL"
  printf 'check-строка записана: %s %s run=%s дерево=%s\n' "$OID" "$KEY" "$rid" "$mtree"
  exit 0
fi

# ── гейт 4б/087 (семантика НЕ ослабляется; батарея fixtures/ci_b_087/ зелёная) ─
[ $# -le 2 ] || die "лишние аргументы: семантика 087 — [корень] [sha]"
ROOT="${1:-$(cd "$SELF_DIR/.." && pwd)}"
if [ ! -d "$ROOT" ]; then
  # форма 008 «sha первым» (judge_gate передаёт один <sha> — пин
  # check_judge_gate.sh): не-каталог в $1 — это sha, корень — каталог скрипта
  # (гашение Р4-3а: живой вызов больше не умирает «корня нет: <sha>»)
  SHA_ARG="$ROOT"
  ROOT="$(cd "$SELF_DIR/.." && pwd)"
else
  SHA_ARG="${2:-HEAD}"
fi
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
