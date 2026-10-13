#!/usr/bin/env bash
# Дверь допуска PR к серверному слиянию (контракт 099, Решение 1/2; З-2..З-6).
# ЕДИНЫЙ субъект защищённого переходного маршрута в main (doc §2/§3, решение
# владельца 2026-10-12: «доверенный PR-допуск до main, без обхода через
# workflow, теги и непроверенный финальный merge; 094 не отменять»).
#
# ВЫЗОВ: pr_dopusk.sh <корень> --pr <N>
#   Коды возврата:
#     0 — «ДОПУСК: <pr> <объект>» — серверное слияние разрешено;
#     1 — именованный отказ (гварды базы, теги/реестр, checks, merge);
#     2 — fail-closed (битый вход, нет инструмента, API недоступен).
#   Ручка API: PR_DOPUSK_API (base URL; без — https://api.github.com,
#   конвенция 071/087). Если base уже содержит /repos/<owner>/<repo> —
#   используется как есть; иначе owner/repo парсится из remote origin
#   (github-грамматика 071), а непарсируемый remote (локальный путь toy-API)
#   даёт условные o/r — та же конвенция, что в стаб-батарее семьи.
#
# ЧТО СУДИТСЯ (порядок несут клетки fixtures/zashchita_main_099/):
#   (0) реестр перехода и байт-минимум — ГВАРДЫ БАЗЫ прежде семантики merge:
#       реестр читается по ПЕРВОМУ РОДИТЕЛЮ объекта M^1 (main-сторона), дельта
#       кандидатом → «база исключений изменена кандидатом»; байт-минимум
#       (минимум, исполняемый платформой из M: `.github/workflows/` +
#       `package.json`; scripts/ и fixtures/ ИСКЛЮЧЕНЫ — замер 5 арбитража 099:
#       заморозка поверхности отказывала 20/40 легитимных лендов) → «проверки
#       изменены кандидатом: <путь>». Прежде маркера: кандидат без land:-строки
#       обязан ловиться гвардом базы, если он же правит базу (клетки е/з);
#       эволюция проверок легитимна — добавление кандидатом НОВЫХ клеток/скриптов
#       вне минимума допускается (клетка к).
#   (а) merge-объект PR: merge_commit_sha из ответа API + локальная сверка:
#       объект разрешается локально; объект слияния = сам объект, если он merge,
#       иначе первый merge в first-parent цепи (кандидатские коммиты поверх
#       merge на интеграционной ветке не прячут субъект суждения). Head PR из
#       ответа обязан быть ВТОРЫМ родителем объекта слияния — иначе «база
#       двинулась» (судится результат слияния, не head — З-4).
#   (б) сообщение и identity финального merge: land:-маркер в первой строке;
#       committer — доверенный компонент (orchestrator).
#   (в) теги/реестр: каждый локальный frozen/*|done/*|id/* — на origin тем же
#       объектом («локальный тег не на origin: <тег>»; ДО слияния — З-2);
#       каждая строка реестра registry/contracts.tsv дерева ОБЪЕКТА
#       «NNN → <sha>» — sha есть тег NNN на origin (membership 023-2в:
#       frozen/contracts/<NNN>/[0-9]*, done/contracts/<NNN>/[0-9]*,
#       id/CONTRACT/<NNN>) — «реестр: тег не выдан авторитетом: <NNN>» (З-5).
#   (г) обязательный набор checks на PR — структурно per-name (098 дословно),
#       фактическое выполнение: каждое имя реестра перехода присутствует со
#       статусом completed (иначе «нет результата: <имя>» — skipped/neutral/
#       отсутствие ≠ success, раннее прерывание job оставляет составляющие
#       без результата); conclusion success — зелено; failure — ТОЛЬКО при
#       точном совпадении sha256 отсортированных (LC_ALL=C) строк отказа
#       (каждая с завершающим \n; строки из ответа CI, не из локальной
#       доски — А-401) с записью реестра, иначе «неизвестный отказ: <имя>».
#       Требования «sha ∈ origin/main» (087) и «хотя бы один зелёный
#       PR-workflow» (071-чек-3) в допуске НЕ существует — ЗАМЕНЕНЫ объектом
#       вне main + серверными обязательными checks (Пять правил §2: замена,
#       не наслаивание; док §2 «Красный main сам по себе не блокирует
#       исправляющий PR»).
#       Производитель составляющих (Решение 2, Р1-6 reviewer 099 круг 1):
#       config/transition_producers_099.tsv по M^1 — пустой/отсутствующий файл
#       есть именованный отказ (выключателя у ноги нет); непустой — КАЖДОЕ имя
#       покрыто строкой <check-run> TAB <файл workflow> TAB <команда>,
#       файл существует в дереве M^1 и несёт команду дословно.
#   (д) содержательные чеки дерева 071 — переиспользованием
#       scripts/gitw_preflight_071.sh в режиме объекта (--object <sha>), где
#       чек 3 (зелёный-PR-workflow) заменён серверными обязательными checks.
#
# Реестр перехода — config/transition_defects_099.tsv (Решение 2): строки
# «<имя составляющей> TAB <sha256|->» в шаг-гранулярности (l7a/l7b, не
# job-агрегат). `-` — составляющая обязана быть зелёной; sha256 — точная
# запись известного дефекта (записи вносятся ТОЛЬКО по санкции владельца,
# обновление — доверенная сторона, дельта базы кандидатом запрещена). После
# чинки l7/ap2 хеши заменяются на `-`, дверь и маршрут удаляются (doc §3).
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat >&2 <<USAGE
использование: pr_dopusk.sh <корень> --pr <N>
USAGE
  exit 2
}

command -v git  >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v curl >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет curl\n' >&2; exit 2; }
command -v jq   >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет jq\n' >&2; exit 2; }
command -v sha256sum >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет sha256sum\n' >&2; exit 2; }

root=""
pr=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --pr) pr="${2:-}"; shift 2 ;;
    --help|-h) usage ;;
    -*) printf 'pr_dopusk: неизвестный аргумент: %s\n' "$1" >&2; usage ;;
    *)  if [ -z "$root" ]; then root="$1"; shift
        else printf 'pr_dopusk: лишний аргумент: %s\n' "$1" >&2; usage; fi ;;
  esac
done
[ -n "$root" ] || usage
case "$pr" in
  ''|*[!0-9]*) printf 'pr_dopusk: --pr <N> обязателен (число)\n' >&2; usage ;;
esac
ROOT="$(cd "$root" 2>/dev/null && pwd -P)" || {
  printf 'NOT_IMPLEMENTED: %s не каталог\n' "$root" >&2; exit 2; }
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: %s не репозиторий git\n' "$ROOT" >&2; exit 2; }
ORIGIN="$(git -C "$ROOT" remote get-url origin 2>/dev/null || true)"
[ -n "$ORIGIN" ] || {
  printf 'ОТКАЗ: remote origin не объявлен — сверка тегов с origin невозможна\n' >&2
  exit 1
}

# ── API base (конвенция 071: полная форма /repos/… — как есть; иначе парсинг
# github-грамматики remote; непарсируемый (toy-API путь) — условные o/r
# из стаб-батареи семьи). ─────────────────────────────────────────────────
API_BASE="${PR_DOPUSK_API:-https://api.github.com}"
case "$API_BASE" in
  */repos/*) ;;
  *)
    repo="$(printf '%s' "$ORIGIN" \
      | sed -nE 's#^(ssh://git@github\.com/|ssh://github\.com/|git@github\.com:|https://github\.com/)([^/]+)/([^/.]+)(\.git)?$#\2/\3#p' | head -1)"
    repo="${repo:-o/r}"
    API_BASE="${API_BASE%/}/repos/${repo}"
    ;;
esac

gh_args=(-H 'Accept: application/vnd.github+json' -H 'X-GitHub-Api-Version: 2022-11-28')
if [ -n "${GITHUB_TOKEN:-}" ]; then
  gh_args+=(-H "Authorization: Bearer $GITHUB_TOKEN")
fi

TMPD="$(mktemp -d "${TMPDIR:-/tmp}/pr_dopusk.XXXXXX")" || {
  printf 'NOT_IMPLEMENTED: mktemp не создал скратч\n' >&2; exit 2; }
trap 'rm -rf "$TMPD"' EXIT

# ── PR: merge-объект и head из ответа API ─────────────────────────────────
if ! curl -fsS -m 20 "${gh_args[@]}" "$API_BASE/pulls/$pr" > "$TMPD/pr.json" 2>/dev/null; then
  printf 'ОТКАЗ: PR не отвечает (curl $API_BASE/pulls/%s) — fail-closed\n' "$pr" >&2
  exit 2
fi
M="$(jq -r '.merge_commit_sha // ""' "$TMPD/pr.json" 2>/dev/null)"
H="$(jq -r '.head.sha // ""' "$TMPD/pr.json" 2>/dev/null)"
case "$M" in
  ''|*[!0-9a-f]*)
    printf 'ОТКАЗ: merge_commit_sha не читается из ответа PR %s — fail-closed\n' "$pr" >&2
    exit 2
    ;;
esac
case "$H" in
  ''|*[!0-9a-f]*)
    printf 'ОТКАЗ: head PR не читается из ответа PR %s — fail-closed\n' "$pr" >&2
    exit 2
    ;;
esac
M="$(git -C "$ROOT" rev-parse --verify --quiet "$M^{commit}" 2>/dev/null || true)"
[ -n "$M" ] || {
  printf 'ОТКАЗ: объект PR %s не разрешается локально в %s — fail-closed\n' \
    "$(jq -r '.merge_commit_sha // ""' "$TMPD/pr.json")" "$ROOT" >&2
  exit 2
}
P1="$(git -C "$ROOT" rev-parse --verify --quiet "$M^1" 2>/dev/null || true)"
[ -n "$P1" ] || {
  printf 'ОТКАЗ: у объекта %s нет первого родителя — реестр перехода нечитаем\n' "$M" >&2
  exit 2
}

# ── (0а) ГВАРД БАЗЫ: реестр перехода по ПЕРВОМУ РОДИТЕЛЮ, дельта кандидатом ──
REG_PATH="config/transition_defects_099.tsv"
reg_p1="$(git -C "$ROOT" show "$P1:$REG_PATH" 2>/dev/null || true)"
reg_obj="$(git -C "$ROOT" show "$M:$REG_PATH" 2>/dev/null || true)"
if [ -z "$reg_p1" ] && ! git -C "$ROOT" cat-file -e "$P1:$REG_PATH" 2>/dev/null; then
  printf 'ОТКАЗ: реестр перехода не читается по первому родителю %s:%s — fail-closed\n' "$P1" "$REG_PATH" >&2
  exit 2
fi
if [ "$reg_p1" != "$reg_obj" ]; then
  printf 'ОТКАЗ: база исключений изменена кандидатом: %s (чтение — по первому родителю %s)\n' \
    "$REG_PATH" "$P1" >&2
  exit 1
fi

# ── (0б) ГВАРД БАЗЫ: байт-минимум, исполняемый платформой из объекта ──────
# `.github/workflows/` (поддерево ЦЕЛИКОМ — ловит и добавление/удаление
# workflow, не только правку) + `package.json` (npm-ключи). scripts/ и
# fixtures/ ИСКЛЮЧЕНЫ (замер 5 арбитража 099: расширение заморозки на них
# отказывало 23/40 легитимных лендов — PR-маршрут становился декорацией).
wm_p1="$(git -C "$ROOT" rev-parse --verify --quiet "$P1:.github/workflows" 2>/dev/null || true)"
wm_m="$(git -C "$ROOT" rev-parse --verify --quiet "$M:.github/workflows" 2>/dev/null || true)"
if [ "$wm_p1" != "$wm_m" ]; then
  first="$(git -C "$ROOT" diff --name-only "$P1" "$M" -- .github/workflows 2>/dev/null | head -1)"
  printf 'ОТКАЗ: проверки изменены кандидатом: %s\n' "${first:-.github/workflows}" >&2
  exit 1
fi
pj_p1="$(git -C "$ROOT" rev-parse --verify --quiet "$P1:package.json" 2>/dev/null || true)"
pj_m="$(git -C "$ROOT" rev-parse --verify --quiet "$M:package.json" 2>/dev/null || true)"
if [ "$pj_p1" != "$pj_m" ]; then
  printf 'ОТКАЗ: проверки изменены кандидатом: package.json\n' >&2
  exit 1
fi

# ── (а/б) объект слияния: маркер и identity финального merge ───────────────
# Объект слияния = сам M, если он merge; иначе первый merge в first-parent
# цепи (кандидатские коммиты поверх merge — часть PR-ветки, не новый субъект).
MC="$M"
for _c in $(git -C "$ROOT" rev-list --first-parent --max-count=200 "$M" 2>/dev/null); do
  np="$(git -C "$ROOT" rev-list --parents -n1 "$_c" 2>/dev/null | wc -w)"
  if [ "$np" -ge 3 ]; then MC="$_c"; break; fi
done
mc_np="$(git -C "$ROOT" rev-list --parents -n1 "$MC" 2>/dev/null | wc -w)"
if [ "$mc_np" -lt 3 ]; then
  printf 'ОТКАЗ: объект слияния без land:-маркера\n' >&2
  exit 1
fi
mc_subject="$(git -C "$ROOT" log -1 --format=%s "$MC")"
case "$mc_subject" in
  land:\ *) ;;
  *)
    printf 'ОТКАЗ: объект слияния без land:-маркера\n' >&2
    exit 1
    ;;
esac
mc_cn="$(git -C "$ROOT" log -1 --format=%cn "$MC")"
if [ "$mc_cn" != "orchestrator" ]; then
  printf 'ОТКАЗ: identity финального merge не доверенного компонента: %s\n' "$mc_cn" >&2
  exit 1
fi

# ── (а) локальная сверка дерева: head PR — второй родитель объекта слияния ──
mc_p2="$(git -C "$ROOT" rev-parse --verify --quiet "$MC^2" 2>/dev/null || true)"
if [ "$mc_p2" != "$H" ]; then
  printf 'ОТКАЗ: база двинулась: head PR %s не второй родитель объекта слияния %s (%s)\n' \
    "$H" "$MC" "${mc_p2:-нет}" >&2
  exit 1
fi

# ── (в1) локальные frozen/*|done/*|id/* — на origin тем же объектом ────────
ls_out="$(git -C "$ROOT" ls-remote --tags "$ORIGIN" 2>/dev/null)" || ls_out=""
declare -A ORSHA
while IFS=$'\t' read -r sha ref; do
  [ -n "${ref:-}" ] || continue
  case "$ref" in
    refs/tags/*) ORSHA["${ref#refs/tags/}"]="$sha" ;;
  esac
done <<< "$ls_out"
while IFS=$'\t' read -r sha name; do
  [ -n "${name:-}" ] || continue
  case "$name" in
    refs/tags/frozen/*|refs/tags/done/*|refs/tags/id/*)
      short="${name#refs/tags/}"
      osha="${ORSHA[$short]:-}"
      if [ "$osha" != "$sha" ]; then
        printf 'ОТКАЗ: локальный тег не на origin: %s (локальный %s, origin %s)\n' \
          "$short" "$sha" "${osha:-нет}" >&2
        exit 1
      fi
      ;;
  esac
done < <(git -C "$ROOT" for-each-ref --format='%(objectname)%09%(refname)' refs/tags 2>/dev/null)
unset ORSHA

# ── (в2) реестр contracts.tsv дерева ОБЪЕКТА: тег NNN выдан авторитетом ────
regc="$(git -C "$ROOT" show "$M:registry/contracts.tsv" 2>/dev/null || true)"
if [ -n "$regc" ]; then
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    nnn="$(printf '%s' "$line" | sed -nE 's/^([0-9]{3}) → ([0-9a-f]{40}|[0-9a-f]{64})$/\1/p')"
    rsha="$(printf '%s' "$line" | sed -nE 's/^([0-9]{3}) → ([0-9a-f]{40}|[0-9a-f]{64})$/\2/p')"
    if [ -z "$nnn" ]; then
      printf 'ОТКАЗ: реестр: строка не разобрана: %s (грамматика «NNN → sha»)\n' "$line" >&2
      exit 2
    fi
    # membership 023-2в: sha строки = tag-object sha живого тега авторитета NNN
    ok_tag=""
    for t in frozen/contracts/$nnn/ done/contracts/$nnn/ id/CONTRACT/$nnn; do
      while IFS=$'\t' read -r sha ref; do
        [ -n "${ref:-}" ] || continue
        case "$ref" in
          refs/tags/$t*) if [ "$sha" = "$rsha" ]; then ok_tag="$ref"; break 2; fi ;;
        esac
      done <<< "$ls_out"
    done
    if [ -z "$ok_tag" ]; then
      printf 'ОТКАЗ: реестр: тег не выдан авторитетом: %s\n' "$nnn" >&2
      exit 1
    fi
  done <<< "$regc"
fi

# ── (г) обязательный набор checks на merge-объекте: per-name, фактическое ──
# выполнение, точно перечисленные дефекты (реестр по M^1, читан выше в reg_p1).
if ! curl -fsS -m 20 "${gh_args[@]}" "$API_BASE/commits/$M/check-runs" > "$TMPD/cr.json" 2>/dev/null; then
  printf 'ОТКАЗ: check-runs не отвечают (curl %s/commits/%s/check-runs) — fail-closed\n' \
    "$API_BASE" "$M" >&2
  exit 2
fi
# Производитель составляющих (Решение 2, Р1-6 reviewer 099 круг 1):
# выключателя у ноги нет — пустая/отсутствующая таблица по M^1 это отказ
# (молчаливая инертность запрещена); непустая связывает КАЖДОЕ имя с кодом
# M^1, его произведшим: файл workflow существует в дереве M^1 и несёт
# команду дословно.
prod_p1="$(git -C "$ROOT" show "$P1:config/transition_producers_099.tsv" 2>/dev/null || true)"
if [ -z "$prod_p1" ]; then
  printf 'ОТКАЗ: таблица производителей пуста или отсутствует (config/transition_producers_099.tsv по M^1 — Решение 2: выключателя у ноги нет)\n' >&2
  exit 1
fi
while IFS=$'\t' read -r pname pfile pcmd; do
  [ -n "$pname" ] || continue
  case "$pfile" in
    .github/workflows/*) ;;
    *) printf 'ОТКАЗ: производитель составляющей вне .github/workflows/: %s → %s\n' "$pname" "$pfile" >&2; exit 1 ;;
  esac
  wf_blob="$(git -C "$ROOT" show "$P1:$pfile" 2>/dev/null || true)"
  if [ -z "$wf_blob" ]; then
    printf 'ОТКАЗ: проверки изменены кандидатом: %s (шаг производителя %s отсутствует в M^1)\n' \
      "$pfile" "$pname" >&2
    exit 1
  fi
  if ! printf '%s\n' "$wf_blob" | grep -Fq -- "$pcmd"; then
    printf 'ОТКАЗ: производитель составляющей не несёт команду дословно: %s → %s\n' \
      "$pname" "$pfile" >&2
    exit 1
  fi
done <<< "$prod_p1"
# КАЖДОЕ имя обязательного набора покрыто строкой производителя.
while IFS= read -r rline; do
  [ -n "$rline" ] || continue
  rname="${rline%%$'\t'*}"
  if ! printf '%s\n' "$prod_p1" | awk -F'\t' -v n="$rname" '$1 == n { f=1 } END { exit f?0:1 }'; then
    printf 'ОТКАЗ: производитель составляющей не объявлен: %s (нет строки в transition_producers_099.tsv)\n' \
      "$rname" >&2
    exit 1
  fi
done <<< "$reg_p1"
while IFS= read -r rline; do
  [ -n "$rline" ] || continue
  rname="${rline%%$'\t'*}"
  rent="${rline#*$'\t'}"
  run_json="$(jq -c --arg n "$rname" '[.check_runs[]? | select(.name == $n)][0]' "$TMPD/cr.json" 2>/dev/null || true)"
  if [ -z "$run_json" ] || [ "$run_json" = "null" ]; then
    printf 'ОТКАЗ: нет результата: %s (имя реестра перехода отсутствует в ответе CI)\n' "$rname" >&2
    exit 1
  fi
  rstatus="$(printf '%s' "$run_json" | jq -r '.status // ""' 2>/dev/null)"
  rconcl="$(printf '%s' "$run_json" | jq -r '.conclusion // ""' 2>/dev/null)"
  if [ "$rstatus" != "completed" ] || [ -z "$rconcl" ]; then
    printf 'ОТКАЗ: нет результата: %s (status=%s, conclusion=%s — skipped/neutral/незавершённость ≠ success)\n' \
      "$rname" "${rstatus:-нет}" "${rconcl:-нет}" >&2
    exit 1
  fi
  if [ "$rconcl" = "success" ]; then
    continue
  fi
  if [ "$rconcl" = "failure" ]; then
    summary="$(printf '%s' "$run_json" | jq -r '.output.summary // ""' 2>/dev/null)"
    # Формула реестра (единый источник — клетка perechen): stdin из
    # отсортированных (LC_ALL=C) строк отказа, каждая с завершающим \n.
    got_sha="$(printf '%s\n' "$summary" | LC_ALL=C sort | sha256sum | awk '{print $1}')"
    if [ "$rent" != "-" ] && [ "$got_sha" = "$rent" ]; then
      continue  # точно перечисленный известный дефект (sha строк совпал)
    fi
    printf 'ОТКАЗ: неизвестный отказ: %s (sha отказов %s, в реестре %s)\n' "$rname" "$got_sha" "$rent" >&2
    exit 1
  fi
  printf 'ОТКАЗ: нет результата: %s (conclusion=%s — фактического выполнения нет)\n' \
    "$rname" "$rconcl" >&2
  exit 1
done <<< "$reg_p1"

# ── (д) содержательные чеки дерева 071 в режиме объекта ───────────────────
# РЕШЕНИЕ 1(д): переиспользование предполёта; чек 3 (зелёный-PR-workflow)
# внутри него в режиме объекта ЗАМЕНЁН серверными обязательными checks,
# судимыми выше; rc и текст наследуются (прецедент делегирования check_charter
# в check_staged 019).
pf_out="$(cd "$ROOT" && bash "$SELF_DIR/gitw_preflight_071.sh" "$ORIGIN" --object "$M" 2>&1)" || pf_rc=$?
pf_rc="${pf_rc:-0}"
printf '%s\n' "$pf_out" >&2
if [ "$pf_rc" -ne 0 ]; then
  exit "$pf_rc"
fi

printf 'ДОПУСК: %s %s\n' "$pr" "$M"
exit 0
