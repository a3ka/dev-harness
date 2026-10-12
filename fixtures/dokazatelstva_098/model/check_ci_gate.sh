#!/usr/bin/env bash
# Честная модель CI-писателя (контракт 098) — носитель ГРАММАТИКИ субъекта
# scripts/check_ci_gate.sh: без флага — семантика 4б/087 (sha на origin/main ∧
# прогонов ≥ 1 ∧ все conclusion success); --check-row — писатель строки check
# журнала принятой стороны <корень>/registry/candidates.tsv.
# Модель — не продукт: живёт в семье батареи, используется режимом --model
# раннера и стаб-паком battery_stubs.sh (маркеры # t98-mCN — единственные
# строки-носители инвариантов, НЕ удалять и НЕ переименовывать без синхронной
# правки стаб-пака).
#
# CLI (решение 2 контракта 098; Р4-3б–г гасятся; блокер критика круга 2 —
# происхождение одноимённого прогона):
#   check_ci_gate.sh <корень> <M-sha> --check-row <object_id> <ключ>
#       дерево = M-sha^{tree} ИЗ АРГУМЕНТА — требования «M на origin/main»
#       НЕТ (доказательство ДО публикации); сопоставление СТРУКТУРНОЕ: имя
#       прогона ЛИТЕРАЛЬНО == <ключ>, прогон обязан стоять на коммите M-sha
#       (head_sha); ПРОИСХОЖДЕНИЕ — из ОТВЕТА CI, не из локальной доски:
#       исполнитель прогона (поле app.slug ответа) сверяется литерально с
#       пином ciApp= принятой политики, sha256 ИСПОЛНЕННОГО определения
#       (поле wfsha ответа) — с sha256 принятого файла harness/checks/<ключ>
#       .cmd; чужая обвязка/версия — именованный отказ, строка не пишется;
#       отбор — последний одноимённый прогон по id (исход прогона НЕ
#       влияет на выбор; перебор до подходящего — обход); порядок сверок
#       head_sha → исполнитель → версия → заключение → запись (чужой
#       красный прогон не порождает ни ok, ни fail); последний доверенный
#       прогон записывается В ОБЕ СТОРОНЫ (арбитраж 098
#       contracts-098-provenance-v1): success → строка ok, rc 0;
#       завершённый с иным заключением → строка fail и rc 1 —
#       отрицательный результат есть факт журнала, прежний ok с меньшим
#       run им перекрывается; не завершён — именованный отказ без строки
#       (Н-204); ключ — из mandatory политики принятой стороны; непокрытый
#       ключ — именованный отказ (не молчание); лишние аргументы —
#       именованный отказ rc 1 (не 127, Р4-3г).
#   check_ci_gate.sh [корень] [sha] — семантика 087 (не ослабляется).
# Отказы rc 1 — именованные «ОТКАЗ: …»; rc 2 — NOT_IMPLEMENTED.
set -uo pipefail
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DATABASE \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES

die() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
ni()  { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }
command -v git  >/dev/null 2>&1 || ni "нет git — историю прочитать нечем"
command -v curl >/dev/null 2>&1 || ni "нет curl — ответ CI не получить"
command -v jq   >/dev/null 2>&1 || ni "нет jq — ответ CI не разобрать"

ROOT="${1:-}"; MSHA="${2:-HEAD}"
if [ "${3:-}" = "--check-row" ]; then MODE=writer; else MODE=g087; fi

case "$MODE" in
g087)
  # ── семантика 4б/087: гейт по ЗАПУШЕННОМУ HEAD (не ослабляется) ────────────
  [ $# -le 2 ] || die "лишние аргументы: семантика 087 — [корень] [sha]"
  SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  ROOT="${ROOT:-$(cd "$SELF_DIR/.." && pwd)}"
  [ -d "$ROOT" ] || die "корня нет: $ROOT"
  ROOT="$(cd "$ROOT" && pwd)"
  git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 || die "$ROOT не репозиторий git"
  sha="$(git -C "$ROOT" rev-parse --verify --quiet "${MSHA}^{commit}" || true)"
  [ -n "$sha" ] || die "коммит не разрешается: $MSHA"
  short="$(printf '%s' "$sha" | head -c 12)"
  git -C "$ROOT" rev-parse --verify --quiet refs/remotes/origin/main >/dev/null 2>&1 \
    || die "ветки origin/main нет локально — прогон CI по $short не существует; сделай fetch"
  git -C "$ROOT" merge-base --is-ancestor "$sha" refs/remotes/origin/main \
    || die "коммит $short не на origin/main — CI по нему не запускался; запушь и дождись прогона"
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
        "https://api.github.com/repos/${repo}/commits/${sha}/check-runs?per_page=100" 2>&1)"; then
    die "CI не ответил по $short (curl): $(printf '%s' "$body" | head -2 | tr '\n' ' ')"
  fi
  total="$(printf '%s' "$body" | jq -r '.total_count // -1' 2>/dev/null)" || total=-1
  [ "$total" -ge 0 ] || die "ответ CI не разобран: total_count нет — $(printf '%s' "$body" | head -c 200)"
  [ "$total" -gt 0 ] || die "прогонов CI по $short нет: чек-раны пусты — workflow не запускался"
  bad_run="$(printf '%s' "$body" | jq -r '[.check_runs[] | select((.conclusion // "") != "success")][0] | if . then (.name + " → " + (.conclusion // "без завершения")) else "" end' 2>/dev/null)"
  if [ -n "$bad_run" ]; then
    die "CI не зелёный по $short: $bad_run — судью не звать, чинить пачку"
  fi
  printf '  ok   CI зелёный: проверок %s, все success, по %s (%s)\n' "$total" "$short" "$repo" >&2
  exit 0
  ;;
writer)
  # ── писатель строки check (решение 2 контракта 098) ───────────────────────
  [ $# -eq 5 ] || die "check-row: <корень> <M-sha> --check-row <object_id> <ключ> — аргументов $# , нужно 5 (лишние аргументы отвергаются именованным отказом, не 127)"
  OID="$4"; KEY="$5"
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
  mtree="$(git -C "$ROOT" rev-parse --verify --quiet "$MSHA^{tree}")" # t98-mC3: дерево ИСПОЛНЕНИЯ — из аргумента, требования «на origin/main» НЕТ
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
  best="$(printf '%s' "$body" | jq -c --arg k "$KEY" '[.check_runs[] | select(.name == $k)] | sort_by(.id) | last' 2>/dev/null)" # t98-mC2: имя — ЛИТЕРАЛЬНОЕ равенство (не подстрока display-имени) # t98-mC7: отбор — ПОСЛЕДНИЙ одноимённый прогон по id, исход прогона НЕ влияет на выбор (арбитраж 098) # t98-mC0: чужой новейший ЗЕЛЁНЫЙ не отступает к старому валидному — «перебор до подходящего» есть обход (вердикт A-098-2); маркер mC0, а не mC10: маркер s2 — префикс mC10, единственность якоря ломалась бы
  { [ -n "$best" ] && [ "$best" != "null" ]; } || die "нет обязательной проверки: $KEY"
  rid="$(printf '%s' "$best" | jq -r '.id' 2>/dev/null)"
  concl="$(printf '%s' "$best" | jq -r '.conclusion // ""' 2>/dev/null)"
  hsha="$(printf '%s' "$best" | jq -r '.head_sha // ""' 2>/dev/null)"
  case "$rid" in ''|*[!0-9]*) die "ответ CI: id прогона не разобран: $KEY" ;; esac
  [ "$hsha" = "$MSHA" ] || die "прогон не того коммита: $KEY" # t98-mC9: head_sha — ПОЛЕ ОТВЕТА CI, не аргумент CLI: прогон обязан ИСПОЛНЯТЬ коммит M; подмена разбора значением аргумента (вердикт A-098-1) — именованный отказ, строка не пишется
  aslg="$(printf '%s' "$best" | jq -r '.app.slug // ""' 2>/dev/null)"
  [ "$aslg" = "$ciapp" ] || die "проверка чужой обвязки: $KEY" # t98-mC5: исполнитель прогона — пин ciApp политики (одноимённый чужой workflow не проходит по имени) # t98-mC8: порядок сверок (арбитраж 098): происхождение — РАНЬШЕ заключения, чужой красный прогон не пишет fail
  wfr="$(printf '%s' "$best" | jq -r '.wfsha // ""' 2>/dev/null)"
  [ "$wfr" = "$wfsha" ] || die "проверка не доверенной версии: $KEY" # t98-mC4: происхождение — поле wfsha ОТВЕТА CI, локально вычисленный хеш источником не является
  [ -n "$concl" ] || die "прогон не завершён: $KEY (Н-204: частичный прогон ≠ вердикт)"
  if [ "$concl" != "success" ]; then
    printf 'check\t%s\t%s\tfail\t%s\t%s\t%s\n' "$OID" "$KEY" "$rid" "$wfsha" "$mtree" >>"$JOURNAL" # t98-mC6: отрицательный результат — ФАКТ журнала (арбитраж 098): прежний ok с меньшим run перекрывается
    die "обязательная проверка красна: $KEY"
  fi
  printf 'check\t%s\t%s\tok\t%s\t%s\t%s\n' "$OID" "$KEY" "$rid" "$wfsha" "$mtree" >>"$JOURNAL" # t98-mC1
  printf 'check-строка записана: %s %s run=%s дерево=%s\n' "$OID" "$KEY" "$rid" "$mtree"
  exit 0
  ;;
esac
die "неизвестный режим: $MODE"
