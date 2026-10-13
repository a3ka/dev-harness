#!/usr/bin/env bash
# fixtures/dokazatelstva_098/_mir.sh — каркас семьи dokazatelstva_098 (контракт 098
# «производственные доказательства до публикации»). НЕ фикстура, source-only.
#
# Субъекты: писатели scripts/judge_gate.sh (--verdict-row/--policy-row),
# scripts/check_ci_gate.sh (--check-row) + проверяющая часть двери
# scripts/accept_publish.sh (object/prepare/publish). Грамматики субъекта —
# model/{judge_gate,check_ci_gate,accept_publish}.sh (честные модели).
# Клетки берут КАТАЛОГ субъектов из D98_SUBJECTS_DIR (раннер ставит real|model,
# стаб-пак — каталог со стабом), корень дерева — из D98_ROOT (умолчание — корень
# репозитория семьи). Миры — ТОЛЬКО /tmp/dev-harness-verify/dokazatelstva-098-**
# (Н-85/А-122), каждая клетка вычищает свой мир за собой (trap).
#
# Топология мира (решения 1/5 контракта 098 — доказательства ДО публикации):
#   $W/repo     — репозиторий кандидата: main=base; ветка kandidat (переход
#                 политики mandatory=ci-a,ci-b → +ci-c); M = prepare двери;
#                 НЕЦЕЛЕВАЯ ссылка refs/heads/cand/<object_id> → M (имя не
#                 конфликтует с веткой kandidat — ref-каталоги не пересекаются);
#   $W/prinyato — принятая сторона (чек-аут оркестратора): клон repo на base,
#                 origin переведён на github-форму (источник ответов CI для
#                 писателя), registry/candidates.tsv — журнал ВНЕ проверяемой
#                 ветки, scripts/ — установленные субъекты (SELF-относительный
#                 журнал писателей: $SELF/../registry/candidates.tsv);
#   $W/bin      — поддельный curl (ответы check-runs по sha) в PATH вызовов;
#   $W/fake     — ответы CI (checkruns/<sha>.json, id-счётчик) и журнал URL.
#
# Оракулы-sha клетки читают в ПАМЯТЬ ДО вызова субъекта (правило 8): wfsha —
# sha256 определения на base в repo (единый источник, дверь сверяет тем же),
# tree — repo <rev>^{tree}, policyVersion — sha256 байтов harness/policy.
set -uo pipefail

d98_ni() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

D98_HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

_d98_root()  { printf '%s\n' "${D98_ROOT:-$(cd "$D98_HERE/../.." && pwd)}"; }
_d98_sdir()  { printf '%s\n' "${D98_SUBJECTS_DIR:-$(_d98_root)/scripts}"; }

# _d98_missing — отсутствующие субъекты через пробел (пусто — все на месте)
_d98_missing() {
  local sd f miss=""
  sd="$(_d98_sdir)"
  for f in accept_publish.sh judge_gate.sh check_ci_gate.sh; do
    [ -f "$sd/$f" ] || miss="$miss scripts/$f"
  done
  printf '%s' "${miss# }"
}

# _d98_world <слаг> — репозиторий кандидата БЕЗ M (base + kandidat с переходом
# политики). Печатает каталог мира.
_d98_world() {
  local slug="$1" d
  d="/tmp/dev-harness-verify/dokazatelstva-098-${slug}-$$-${RANDOM}"
  mkdir -p "$d/repo/harness/checks" "$d/bin" "$d/fake/checkruns" \
    || d98_ni "мир не строится: $d"
  git init -q --initial-branch=main "$d/repo" 2>/dev/null || d98_ni "git init"
  git -C "$d/repo" config user.name orchestrator
  git -C "$d/repo" config user.email orchestrator@dev-harness.local
  printf 'repoId=toy-098\nmandatory=ci-a,ci-b\nciApp=harness-ci\ntargetBranches=main\n' \
    >"$d/repo/harness/policy" || d98_ni "policy base"
  printf 'run ci-a\n' >"$d/repo/harness/checks/ci-a.cmd"
  printf 'run ci-b\n' >"$d/repo/harness/checks/ci-b.cmd"
  printf 'one\n' >"$d/repo/file.txt"
  git -C "$d/repo" add -A || d98_ni "git add base"
  git -C "$d/repo" commit -qm base || d98_ni "git commit base"
  git -C "$d/repo" checkout -qb kandidat || d98_ni "ветка kandidat"
  printf 'repoId=toy-098\nmandatory=ci-a,ci-b,ci-c\nciApp=harness-ci\ntargetBranches=main\n' \
    >"$d/repo/harness/policy" || d98_ni "policy kandidat"
  printf 'run ci-c\n' >"$d/repo/harness/checks/ci-c.cmd"
  printf 'two\n' >>"$d/repo/file.txt"
  git -C "$d/repo" add -A || d98_ni "git add kandidat"
  git -C "$d/repo" commit -qm kandidat || d98_ni "git commit kandidat"
  git -C "$d/repo" checkout -q main || d98_ni "checkout main"
  # поддельный curl: ответы CI по sha из URL, журнал вызовов
  cat >"$d/bin/curl" <<'CURL'
#!/usr/bin/env bash
url="${@: -1}"
printf '%s\n' "$url" >>"${D98_FAKE:?D98_FAKE}/log"
sha="$(printf '%s' "$url" | sed -nE 's#.*/commits/([0-9a-f]{40})/check-runs.*#\1#p')"
if [ -n "$sha" ] && [ -f "${D98_FAKE}/checkruns/$sha.json" ]; then
  cat "${D98_FAKE}/checkruns/$sha.json"
  exit 0
fi
printf '{"total_count":0,"check_runs":[]}\n'
CURL
  chmod +x "$d/bin/curl" || d98_ni "chmod curl"
  printf '0\n' >"$d/fake/idseq"
  printf '%s\n' "$d"
}

# _d98_ci_runs <W> <sha> <имя:заключение[:@обвязка][:~wfsha]>... — JSON-МАССИВ
# НОВЫХ прогонов (общий строитель _d98_ci/_d98_ci_add; head_sha=sha);
# id-счётчик мира монотонный: каждый следующий прогон «новее» предыдущего.
# Каждый прогон несёт ИДЕНТИФИКАТОР ИСПОЛНИТЕЛЯ (app.slug; пин принятой
# стороны — ciApp= политики мира; держать в синхроне с _d98_world) и
# sha256 ИСПОЛНЕННОГО определения (wfsha; умолчание — harness/checks/<имя>.cmd
# дерева исполняемого sha: мир честно исполняет определение своего дерева; у
# прогона без файла определения поля wfsha нет). Переопределения @обвязка/~wfsha
# — клетки подделывают ОДНОИМЕННЫЙ чужой прогон (критик круга 2: чужой workflow
# под тем же display-name) — обвязка и/или определение прогона не совпадают с
# принятыми при том же имени и M.
_d98_ci_runs() {
  local W="$1" sha="$2"; shift 2
  local runs="[" pair name concl slug wf part f id app wjson
  for pair in "$@"; do
    name=""; concl=""; slug="harness-ci"; wf="auto"
    IFS=':' read -r -a f <<<"$pair"
    name="${f[0]}"; concl="${f[1]}"
    for part in "${f[@]:2}"; do
      case "$part" in
        @*) slug="${part#@}" ;;
        '~'*) wf="${part#\~}" ;;
        *) d98_ni "грамматика прогона: $pair" ;;
      esac
    done
    [ -n "$name" ] && [ -n "$concl" ] || d98_ni "грамматика прогона: $pair"
    if [ "$wf" = auto ]; then
      wf="$(git -C "$W/repo" show "$sha:harness/checks/$name.cmd" 2>/dev/null \
        | sha256sum | cut -d' ' -f1)"
    fi
    [ -z "$wf" ] || [ "${#wf}" -eq 64 ] || d98_ni "wfsha прогона не 64 hex: $wf"
    id="$(( $(cat "$W/fake/idseq" 2>/dev/null || printf 0) + 1 ))"
    printf '%s\n' "$id" >"$W/fake/idseq"
    app=1; [ "$slug" = harness-ci ] || app=999999
    wjson=""; [ -z "$wf" ] || wjson=",\"wfsha\":\"$wf\""
    runs="$runs{\"id\":$id,\"name\":\"$name\",\"head_sha\":\"$sha\",\"conclusion\":\"$concl\",\"app\":{\"id\":$app,\"slug\":\"$slug\"}$wjson},"
  done
  printf '%s]\n' "${runs%,}"
}

# _d98_ci <W> <sha> <прогон>... — ответ CI для sha: прогоны ЗАМЕНЯЮТ прежние
# (перезаписывающая операция каркаса)
_d98_ci() {
  local W="$1" sha="$2"; shift 2
  local runs
  runs="$(_d98_ci_runs "$W" "$sha" "$@")"
  printf '{"total_count":%s,"check_runs":%s}\n' "$(printf '%s' "$runs" | jq 'length')" "$runs" \
    >"$W/fake/checkruns/$sha.json"
}

# _d98_ci_add <W> <sha> <прогон>... — ДОБАВИТЬ прогоны к УЖЕ собранному ответу
# CI для sha (арбитраж 098 contracts-098-provenance-v1: смешанная история —
# несколько одноимённых прогонов в ОДНОМ ответе; id-счётчик монотонен,
# добавленный прогон «новее» всех прежних). Грамматика прогона — общая с
# _d98_ci_runs, единый источник.
_d98_ci_add() {
  local W="$1" sha="$2"; shift 2
  local f="$W/fake/checkruns/$sha.json" runs old
  [ -s "$f" ] || d98_ni "ответа CI для sha ещё нет — добавлять не к чему: $sha"
  runs="$(_d98_ci_runs "$W" "$sha" "$@")"
  old="$(jq -c '.check_runs // []' "$f")"
  jq -cn --argjson o "$old" --argjson a "$runs" \
    '{total_count:(($o|length)+($a|length)),check_runs:($o+$a)}' >"$f"
}

# _d98_ci_chuzhoj_head <W> <ответ-sha> <head-sha> <прогон>... — ответ CI,
# ЗАПРАШИВАЕМЫЙ для <ответ-sha>, чьи прогоны несут head_sha=<head-sha> (чужой
# коммит): адверсарий 098 A-098-1 — доверенный зелёный прогон с верными
# name/app.slug/wfsha, исполненный на B, лежит в ответе для M. wfsha — по
# определению дерева <head-sha> (единый строитель _d98_ci_runs, не переизобретать).
# Прогоны ЗАМЕНЯЮТ прежние; честные прогоны на <ответ-sha> добавляются _d98_ci_add.
_d98_ci_chuzhoj_head() {
  local W="$1" sha="$2" head="$3"; shift 3
  local runs
  [ "$sha" != "$head" ] || d98_ni "чужой head совпал с запрашиваемым sha: $sha"
  runs="$(_d98_ci_runs "$W" "$head" "$@")"
  printf '{"total_count":%s,"check_runs":%s}\n' "$(printf '%s' "$runs" | jq 'length')" "$runs" \
    >"$W/fake/checkruns/$sha.json"
}

# _d98_zov <W> <команда...> — вызов субъекта с PATH поддельного curl
_d98_zov() { local W="$1"; shift; D98_FAKE="$W/fake" PATH="$W/bin:$PATH" bash "$@"; }

# оракулы-sha (в память ДО вызова субъекта — правило 8)
_d98_tree()  { git -C "$1" rev-parse "$2^{tree}" 2>/dev/null; }
_d98_wfsha() { git -C "$1" show "$2:harness/checks/$3.cmd" 2>/dev/null | sha256sum | cut -d' ' -f1; }
# пин исполнителя CI — из политики мира (единый источник, клетки не переизобретают)
_d98_ciapp() { git -C "$1" show "$2:harness/policy" 2>/dev/null | sed -nE 's/^ciApp=//p' | head -1; }
# policyVersion — в семантике СУБЪЕКТА: sha256 байтов политики ПОСЛЕ $()-усечения
# завершающих переводов строки (дверь: policy_bytes="$(git show …)" → printf %s) —
# единый источник грамматики, клетки не переизобретают
_d98_pv()    { printf '%s' "$(git -C "$1" show "$2:harness/policy" 2>/dev/null)" | sha256sum | cut -d' ' -f1; }

# _d98_cand_commit <repo> <файл> <строка> — коммит в ветку kandidat (клетки
# двигают кандидата: чужой объект, закрытие находки). Печатает новый sha.
_d98_cand_commit() {
  local R="$1" f="$2" line="$3"
  mkdir -p "$R/$(dirname "$f")"
  git -C "$R" checkout -q kandidat || d98_ni "checkout kandidat"
  printf '%s\n' "$line" >>"$R/$f"
  git -C "$R" add -A || d98_ni "git add cand"
  git -C "$R" commit -qm "cand+ $f" || d98_ni "git commit cand"
  local s; s="$(git -C "$R" rev-parse kandidat)"
  git -C "$R" checkout -q main || d98_ni "checkout main"
  printf '%s\n' "$s"
}

# _d98_cand_rewrite <repo> <файл> <строка> — коммит в ветку kandidat, файл
# ПЕРЕЗАПИСАН строкой (закрытие находки: 'status: ready' обязан исчезнуть).
# Печатает новый sha.
_d98_cand_rewrite() {
  local R="$1" f="$2" line="$3"
  mkdir -p "$R/$(dirname "$f")"
  git -C "$R" checkout -q kandidat || d98_ni "checkout kandidat"
  printf '%s\n' "$line" | tee "$R/$f" >/dev/null
  git -C "$R" add -A || d98_ni "git add cand"
  git -C "$R" commit -qm "cand= $f" || d98_ni "git commit cand"
  local s; s="$(git -C "$R" rev-parse kandidat)"
  git -C "$R" checkout -q main || d98_ni "checkout main"
  printf '%s\n' "$s"
}

# _d98_podgotovka <W> <task> — штатная цепочка до писателей: prepare → object →
# нецелевая ссылка cand/<oid> → зелёный CI → принятая сторона (клон на base при
# первом вызове, иначе fetch новых объектов). Печатает "<B> <C> <M> <oid>".
_d98_podgotovka() {
  local W="$1" task="$2" sd R B C M oid
  sd="$(_d98_sdir)"; R="$W/repo"
  B="$(git -C "$R" rev-parse main)" || d98_ni "rev-parse main"
  C="$(git -C "$R" rev-parse kandidat)" || d98_ni "rev-parse kandidat"
  M="$(bash "$sd/accept_publish.sh" prepare --repo "$R" --task "$task" \
       --base "$B" --candidate "$C")" || d98_ni "prepare двери"
  oid="$(bash "$sd/accept_publish.sh" object --repo "$R" --task "$task" --target main \
       --base "$B" --candidate "$C" --merge "$M")" || d98_ni "object двери"
  git -C "$R" update-ref "refs/heads/cand/$oid" "$M" || d98_ni "нецелевая ссылка"
  _d98_ci "$W" "$M" ci-a:success ci-b:success
  if [ ! -d "$W/prinyato" ]; then
    git clone -q "$R" "$W/prinyato" || d98_ni "клон принятой стороны"
    git -C "$W/prinyato" remote set-url origin https://github.com/toy-098/repo.git \
      || d98_ni "origin github-форма"
    mkdir -p "$W/prinyato/registry" "$W/prinyato/scripts" || d98_ni "prinyato каталоги"
    : >"$W/prinyato/registry/candidates.tsv" || d98_ni "журнал"
    cp "$sd/judge_gate.sh" "$sd/check_ci_gate.sh" "$sd/accept_publish.sh" \
      "$W/prinyato/scripts/" || d98_ni "установка субъектов"
  else
    git -C "$W/prinyato" fetch -q "$R" "+refs/heads/*:refs/remotes/origin/*" \
      || d98_ni "fetch новых объектов"
  fi
  printf '%s %s %s %s\n' "$B" "$C" "$M" "$oid"
}

# _d98_dokazatelstva <W> <task> <B> <C> <M> <oid> [кроме] — полный применимый
# набор строк штатными вызовами писателей: check ci-a,ci-b + verdict accept +
# policy (переход base→kandidat). «кроме» = verdict|check|policy — отключение
# ОДНОГО писателя (Б-4). Отказ писателя — rc 1 клетки (именованный, наверх).
_d98_dokazatelstva() {
  local W="$1" task="$2" B="$3" C="$4" M="$5" oid="$6" except="${7:-}"
  local P="$W/prinyato" k
  printf 'accept\n' >"$W/verdikt-$oid.md"
  printf 'accept\n' >"$W/sankcia-$oid.md"
  if [ "$except" != check ]; then
    for k in ci-a ci-b; do
      _d98_zov "$W" "$P/scripts/check_ci_gate.sh" "$P" "$M" --check-row "$oid" "$k" \
        || return 1
    done
  fi
  if [ "$except" != verdict ]; then
    _d98_zov "$W" "$P/scripts/judge_gate.sh" "$M" --verdict-row "$task" "$oid" \
      "$W/verdikt-$oid.md" || return 1
  fi
  if [ "$except" != policy ]; then
    _d98_zov "$W" "$P/scripts/judge_gate.sh" "$M" --policy-row "$oid" \
      "$(_d98_pv "$W/repo" "$B")" "$(_d98_pv "$W/repo" "$C")" \
      "$W/sankcia-$oid.md" || return 1
  fi
  return 0
}

# _d98_check_stroka <журнал> <oid> <имя> <ok|fail> <wfsha> <tree> — РОВНО ОДНА
# строка check этого объекта с этими полями (run — положительное целое)
_d98_check_stroka() {
  local n
  n="$(awk -F'\t' -v o="$2" -v nm="$3" -v st="$4" -v wf="$5" -v tr="$6" '
    $1=="check" && $2==o && $3==nm && $4==st && $6==wf && $7==tr \
      && $5 ~ /^[0-9]+$/ && $5+0 > 0' "$1" | wc -l)"
  [ "$n" -eq 1 ]
}

_d98_cleanup() { rm -rf "$1" 2>/dev/null || true; }
