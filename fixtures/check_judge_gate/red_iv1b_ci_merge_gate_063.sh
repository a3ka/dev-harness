#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Красная батарея контракта 063 — IV-1б: CI проекта из профиля + ворота
# слияния (боли Б-3/Б-8 пилота Н-167, дыры Д3/Д4). Три механизма:
# scripts/check_merge_gate.sh (accept ∧ нет .review ready|partial),
# scripts/gen_ci_workflow.sh (команды/барьеры профиля → workflow-джоба),
# scripts/land_project.sh (гейт впереди, merge только --no-ff).
#
# ЧЕСТНЫЕ КЛЕТКИ (живые новые скрипты этого дерева; игрушки — двухслойный
# профиль через РЕАЛЬНЫЙ scripts/profile_resolver.sh, слой проекта в скретче,
# env HARNESS_PROJECT_LAYER_ROOT; ci.workflow-цель существует в дереве —
# иначе резолвер 059 отказал бы раньше предмета):
#   к1  accept закоммичен, .review нет → rc 0;
#   к2  .review ready → rc 1, фраза ready дословно;
#   к3  .review partial → rc 1, фраза partial;
#   к4  вердикт не в HEAD → rc 1 «нет закоммиченного accept-вердикта»;
#   к5  .review status: done → не блокирует, rc 0;
#   к6  4 команды + барьер → rc 0 ∧ маркеры шагов ∧ строки команд (отступ 10);
#   к7  vacuous (цель есть, команд/барьеров нет) → rc 0, фраза, байты целы;
#   к8  ленд зелёного входа → rc 0 ∧ merge-коммит (2 родителя) ∧ subject;
#   к9  ленд красного входа → rc 1, фраза гейта, HEAD неизменен;
#   к10 барьер без файла → rc 1, фраза отсутствия барьера, цель не тронута.
#   к11 исполнимость: маркерные команды (СЛУЧАЙНЫЕ значения) + барьер
#       (случайное имя) → генератор rc 0 ∧ cmp -s с эталоном И-10 ∧
#       локальное исполнение джобы rc 0 ∧ лог эффектов байт-в-байт
#       m-test/m-build/m-tc/m-lint/m-bar-<rand> в порядке И-4 (И-9а+И-10);
#   к12 распространение отказа: команда test падает exit 9 → локальное
#       исполнение rc 9 ∧ в логе эффектов ТОЛЬКО маркер m-test-<rand> —
#       шаги после упавшего не исполняются (И-9б);
#   к13 tracked-вердикт с первой строкой FAIL в HEAD, рабочая копия
#       переписана на accept → rc 1 «нет закоммиченного accept-вердикта»:
#       судится блоб HEAD, не рабочая копия (И-2).
#   к14 семантика GitHub тела (арбитраж 063-Б4, замер 6): команда test —
#       «false; echo after-<rand> >> лог» → локальное исполнение rc 1 ∧
#       after в логе нет (-e) ∧ поздние шаги эффектов не дают (И-9ii);
#   КРАСНЫЕ до реализации: скриптов нет → bash rc 127 (034-паттерн:
#   отсутствие барьера и есть честный красный).
#
# СТАБ-ПАК (Н-39: обман ровно одной ручкой; привязка стабов к клеткам —
# ЭТОТ код, не проза контракта; стаб-пак зелёный ДО и ПОСЛЕ реализации —
# различимость не зависит от честного кода; резолвер профиля — стабам
# разрешён: он НЕ предмет 063):
#   s1 «гейт-слепец к ready-файлам» — гейт, игнорирующий .review/ целиком;
#       смерть к2 (пропускает блокирующий вход), честен на к1 (диффпробы);
#   s2 «генератор-заглушка без команд» — пишет шаблон джобы БЕЗ шагов
#       команд/барьеров; смерть к6, честен на к7 — vacuous-вход (диффпробы);
#   s3 «--no-ff-обходчик» — ленд с честным встроенным гейтом, но merge БЕЗ
#       --no-ff; смерть к8 (ff: HEAD с одним родителем), честен на к9
#       (красный вход отказывает — диффпробы);
#   s4 «heredoc-транспорт» — резолв/vacuous/отсутствие барьера честны, все
#       маркеры шагов и строки команд на месте, но команды/барьеры — ДАННЫЕ
#       no-op-шага `: <<'COMMANDS'`: не исполняется ни одна; смерть к11
#       (эффектов нет), честен на к6 — маркеры и строки на месте
#       (диффпробы); после фикса И-9(i) «поймано» — НЕ-vacuous: раннер
#       читает файл-аргумент, вердикт не зависит от stdin батареи;
#   s5 «грязная копия вердикта» — .review и перечисление tracked-файлов
#       честны, но первая строка вердикта читается из РАБОЧЕГО файла, не
#       из блоба HEAD; смерть к13 (ворота открыты без accept в HEAD),
#       честен на к1 — чистый закоммиченный accept (диффпробы);
#   s6 «выключатель контура» (обход Б4, арбитраж dea4268) — резолв/vacuous/
#       отсутствие барьера/маркеры к6/тела шагов и их эффекты ЧЕСТНЫ, но
#       файл-цель несёт ключ джобы сверх контура И-10 (`if: ${{ false }}`):
#       в GitHub джоба выключена; смерть к11 (cmp с эталоном И-10 при
#       наблюдаемых эффектах И-9), честен по И-9 — лог эффектов идентичен
#       честному (диффпроба: И-9 без И-10 обход не ловит).
#
# rc: 0 ⟺ стаб-пак пойман весь ∧ диффпробы чисты ∧ честные клетки зелёные
# ∧ выборки непусты; на HEAD ожидается rc 1 (красная — предмет не реализован).
# Скрипт не печатает PASS — только счёт просмотренного (правило роли).
# ─────────────────────────────────────────────────────────────────────────────
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$(cd "$HERE/../.." && pwd)}"
GATE="$REPO_ROOT/scripts/check_merge_gate.sh"
GEN="$REPO_ROOT/scripts/gen_ci_workflow.sh"
LAND="$REPO_ROOT/scripts/land_project.sh"
RESOLVER="$REPO_ROOT/scripts/profile_resolver.sh"
export RESOLVER

[ -f "$RESOLVER" ] || { printf 'ОТКАЗ: нет резолвера профиля (предусловие семьи, не предмет): %s\n' "$RESOLVER" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { printf 'ОТКАЗ: нет jq\n' >&2; exit 1; }
command -v git >/dev/null 2>&1 || { printf 'ОТКАЗ: нет git\n' >&2; exit 1; }

# ── дословные фразы предмета (контракт 063, И-1..И-7; grep -F, байт-в-байт) ──
P_READY='merge gate ОТКАЗ: незакрытая находка ревьюера: .review/2026-09-30-01.md (status: ready)'
P_PARTIAL='merge gate ОТКАЗ: незакрытая находка ревьюера: .review/2026-09-30-02.md (status: partial)'
P_NOVERD='merge gate ОТКАЗ: нет закоммиченного accept-вердикта ревьюера'
P_GENVAC='ci-генератор: профиль не объявляет команд и барьеров — vacuous, файл не тронут'
P_NOBARRIER='ci-генератор ОТКАЗ: объявленный барьер отсутствует в дереве: probe-a (.harness/fixtures/probe-a.sh)'
CW='.github/workflows/harness.yml'
# Случайные значения игрушки исполнимости (демаркация 063, арбитраж 063-Б4):
# эталон И-10 — функция входа, не подсмотренная константа (прецедент 024).
RND="r$RANDOM$RANDOM"

WORK="$(mktemp -d "${TMPDIR:-/tmp}/red063.XXXXXX")"
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

# ── слой проекта игрушек (один на всех; defaults отсутствуют — команды и CI
# несёт репо-слой каждой игрушки сам, чтобы клетки различались СВОЕЙ ветвью) ──
LAYER="$WORK/layer"; mkdir -p "$LAYER/registry"
printf '{"schemaVersion":1,"version":"t1","projectId":"toy63","workspaceId":"ws1"}\n' \
  > "$LAYER/registry/harness-project.json"
export HARNESS_PROJECT_LAYER_ROOT="$LAYER"

g() { git -C "$1" "${@:2}"; }
commit_all() { g "$1" add -A; g "$1" commit -q -m "$2"; }

# repo-слой: gate-вариант (workflowPaths, без commands/ci/barriers)
REPO_JSON_GATE='{
  "schemaVersion": 1,
  "repoId": "toy63",
  "language": "typescript",
  "projectLayer": {"version": "t1", "profilePath": "registry/harness-project.json"},
  "workflowPaths": {"contracts": ".harness/contracts", "verdicts": ".harness/verdicts", "registry": ".harness/registry", "fixtures": ".harness/fixtures"}
}'
# repo-слой: gen-вариант (4 команды + барьер + ci.workflow-цель)
REPO_JSON_GEN='{
  "schemaVersion": 1,
  "repoId": "toy63",
  "language": "typescript",
  "projectLayer": {"version": "t1", "profilePath": "registry/harness-project.json"},
  "workflowPaths": {"contracts": ".harness/contracts", "verdicts": ".harness/verdicts", "registry": ".harness/registry", "fixtures": ".harness/fixtures"},
  "commands": {"test": "npm test", "build": "npm run build", "typecheck": "tsc --noEmit", "lint": "npm run lint"},
  "ci": {"workflow": ".github/workflows/harness.yml"},
  "barriers": {"mandatory": ["probe-a"], "optional": []}
}'
# repo-слой: vacuous-вариант (ci-цель есть, команд/барьеров нет)
REPO_JSON_VAC='{
  "schemaVersion": 1,
  "repoId": "toy63",
  "language": "typescript",
  "projectLayer": {"version": "t1", "profilePath": "registry/harness-project.json"},
  "workflowPaths": {"contracts": ".harness/contracts", "verdicts": ".harness/verdicts", "registry": ".harness/registry", "fixtures": ".harness/fixtures"},
  "ci": {"workflow": ".github/workflows/harness.yml"}
}'
# repo-слой: exec-вариант (команды-маркеры со СЛУЧАЙНЫМИ значениями + барьер
# со случайным именем — эффекты наблюдаемы локальным исполнением И-9;
# клетка от значений не зависит: конформен любой непустой набор)
REPO_JSON_EXEC="$(printf '{
  "schemaVersion": 1,
  "repoId": "toy63",
  "language": "typescript",
  "projectLayer": {"version": "t1", "profilePath": "registry/harness-project.json"},
  "workflowPaths": {"contracts": ".harness/contracts", "verdicts": ".harness/verdicts", "registry": ".harness/registry", "fixtures": ".harness/fixtures"},
  "commands": {"test": "echo m-test-%s >> .harness/toy-ran.log", "build": "echo m-build-%s >> .harness/toy-ran.log", "typecheck": "echo m-tc-%s >> .harness/toy-ran.log", "lint": "echo m-lint-%s >> .harness/toy-ran.log"},
  "ci": {"workflow": ".github/workflows/harness.yml"},
  "barriers": {"mandatory": ["bar-%s"], "optional": []}
}' "$RND" "$RND" "$RND" "$RND" "$RND")"
# repo-слой: execfail-вариант (та же форма; команда test падает exit 9 —
# отказ шага распространяется на джобу, поздние шаги не исполняются)
REPO_JSON_EXECFAIL="$(printf '{
  "schemaVersion": 1,
  "repoId": "toy63",
  "language": "typescript",
  "projectLayer": {"version": "t1", "profilePath": "registry/harness-project.json"},
  "workflowPaths": {"contracts": ".harness/contracts", "verdicts": ".harness/verdicts", "registry": ".harness/registry", "fixtures": ".harness/fixtures"},
  "commands": {"test": "echo m-test-%s >> .harness/toy-ran.log; exit 9", "build": "echo m-build-%s >> .harness/toy-ran.log", "typecheck": "echo m-tc-%s >> .harness/toy-ran.log", "lint": "echo m-lint-%s >> .harness/toy-ran.log"},
  "ci": {"workflow": ".github/workflows/harness.yml"},
  "barriers": {"mandatory": ["bar-%s"], "optional": []}
}' "$RND" "$RND" "$RND" "$RND" "$RND")"
# repo-слой: ghsem-вариант (семантика GitHub тела, замер 6 арбитража 063-Б4:
# false гасит тело, after-эффекта нет, поздние шаги не исполняются)
REPO_JSON_GHSEM="$(printf '{
  "schemaVersion": 1,
  "repoId": "toy63",
  "language": "typescript",
  "projectLayer": {"version": "t1", "profilePath": "registry/harness-project.json"},
  "workflowPaths": {"contracts": ".harness/contracts", "verdicts": ".harness/verdicts", "registry": ".harness/registry", "fixtures": ".harness/fixtures"},
  "commands": {"test": "false; echo after-%s >> .harness/toy-ran.log", "build": "echo m-build-%s >> .harness/toy-ran.log", "typecheck": "echo m-tc-%s >> .harness/toy-ran.log", "lint": "echo m-lint-%s >> .harness/toy-ran.log"},
  "ci": {"workflow": ".github/workflows/harness.yml"},
  "barriers": {"mandatory": ["bar-%s"], "optional": []}
}' "$RND" "$RND" "$RND" "$RND" "$RND")"

mkt() { # <каталог> <repo-json>
  mkdir -p "$1/.harness/verdicts" "$1/.github/workflows"
  printf '%s\n' "$2" > "$1/harness.project.json"
  g "$1" init -q -b main 2>/dev/null || git -C "$1" init -q -b main
  g "$1" config user.name Fixture
  g "$1" config user.email fixture@local
  commit_all "$1" 'osnova toy 063'
}

put_accept() { # <каталог> — закоммиченный accept-вердикт
  printf 'accept\n\n# Суд 063-toy\n\nвердикт toy-ревьюера\n' \
    > "$1/.harness/verdicts/stk-063-review.md"
  commit_all "$1" 'verdikt accept'
}

review_file() { # <каталог> <имя> <status>
  mkdir -p "$1/.review"
  printf -- '---\nstatus: %s\n---\n\n- [ ] nakhodka 1\n' "$3" > "$1/.review/$2"
}

mk_probe_ok() { # <каталог> — барьер-маркер bar-$RND (эффект — строка в лог)
  mkdir -p "$1/.harness/fixtures"
  printf '#!/usr/bin/env bash\necho m-bar-%s >> .harness/toy-ran.log\n' "$RND" \
    > "$1/.harness/fixtures/bar-$RND.sh"
}

# ── незавершающие проверки (батарея считает, не умирает на первой) ───────────
LAST_OUT=''; LAST_RC=0
run_gate() { LAST_OUT="$(bash "$GATE" --repo "$1" 2>&1)"; LAST_RC=$?; }
run_gen()  { LAST_OUT="$(bash "$GEN" --repo "$1" 2>&1)";  LAST_RC=$?; }
run_land() { LAST_OUT="$(bash "$LAND" --repo "$1" --branch "$2" 2>&1)"; LAST_RC=$?; }

# ── локальное исполнение джобы harness (предъявление И-9 по РЕШЕНИЮ
# арбитража 063-Б4): раннер читает ФАЙЛ-АРГУМЕНТ — результат инвариантен к
# stdin батареи (не блокируется и не подъедает его); шаги извлекаются по
# фиксированному лейауту И-4 — «        run: |» открывает тело, строки с
# отступом ровно 10 — тело (шаги без run:, например uses:, пропускаются);
# тела исполняются ПОДРЯД, каждое отдельным `bash --noprofile --norc -eo
# pipefail -c` в корне репо (форма `shell: bash` GitHub по умолчанию —
# ненулевая команда тела гасит тело); отказ шага = отказ джобы (rc шага),
# поздние шаги не исполняются ──
wf_run() { # <repo> <wf-файл>; rc = rc первого упавшего шага, 0 = все зелёные
  local repo="$1" wf="$2" line body='' have=0
  while IFS= read -r line || [ -n "$line" ]; do
    if [ "$have" -eq 1 ]; then
      case "$line" in
        '          '*) body+="${line:10}"$'\n'; continue ;;
      esac
      ( cd "$repo" && bash --noprofile --norc -eo pipefail -c "$body" ) || return $?
      have=0; body=''
    fi
    if [ "$line" = '        run: |' ]; then have=1; body=''; fi
  done < "$wf"
  if [ "$have" -eq 1 ]; then ( cd "$repo" && bash --noprofile --norc -eo pipefail -c "$body" ) || return $?; fi
  return 0
}

# эталон И-10 (закрытая форма файла-цели): контур — ЛИТЕРАЛ контракта 063,
# шаги — по правилу И-4 из резолва профиля игрушки; случайные значения
# делают эталон функцией входа, не подсмотренной константой (прецедент 024)
wf_etalon() { # <repo>; эталон файла-цели на stdout
  local repo="$1" M k v b FIX
  M="$(bash "$RESOLVER" --repo "$repo" 2>/dev/null)"
  FIX="$(printf '%s' "$M" | jq -r '.workflowPaths.fixtures.value // empty')"
  printf '# GENERATED by dev-harness gen_ci_workflow — не править руками; источник — harness.project.json\n'
  printf 'name: harness\non: [push, pull_request]\njobs:\n  harness:\n    runs-on: ubuntu-latest\n    steps:\n      - uses: actions/checkout@v4\n'
  for k in test build typecheck lint; do
    v="$(printf '%s' "$M" | jq -r --arg k "$k" '.commands[$k].value // empty')"
    [ -n "$v" ] || continue
    printf '      - name: commands.%s\n        run: |\n' "$k"
    while IFS= read -r l; do printf '          %s\n' "$l"; done <<< "$v"
  done
  while IFS= read -r b; do
    [ -n "$b" ] || continue
    printf '      - name: barriers.%s\n        run: |\n          bash %s/%s.sh\n' "$b" "$FIX" "$b"
  done < <(printf '%s' "$M" | jq -r '.barriers.mandatory.value[]?')
}

# ожидаемый лог эффектов игрушки исполнимости (маркеры случайны — RND)
exp_full_log() {
  printf 'm-test-%s\nm-build-%s\nm-tc-%s\nm-lint-%s\nm-bar-%s\n' "$RND" "$RND" "$RND" "$RND" "$RND"
}

chk_rc0() {
  if [ "$LAST_RC" -eq 0 ]; then printf '  ok   %s\n' "$1" >&2; return 0; fi
  printf '  FAIL %s: rc %s, ожидался 0\nвывод:\n%s\n' "$1" "$LAST_RC" "$LAST_OUT" >&2
  return 1
}
chk_refuse() { # <имя> <фраза>
  if [ "$LAST_RC" -eq 1 ] && printf '%s\n' "$LAST_OUT" | grep -Fq "$2"; then
    printf '  ok   %s: отказ rc 1, причина названа дословно\n' "$1" >&2; return 0
  fi
  printf '  FAIL %s: rc %s, ожидался отказ 1 с дословной причиной «%s»\nвывод:\n%s\n' "$1" "$LAST_RC" "$2" "$LAST_OUT" >&2
  return 1
}

# ── ЧЕСТНЫЕ КЛЕТКИ ────────────────────────────────────────────────────────────
k1() { # accept закоммичен, .review нет → rc 0
  local T="$WORK/k1"; mkt "$T" "$REPO_JSON_GATE"; put_accept "$T"
  run_gate "$T"
  chk_rc0 'к1: accept ∧ нет .review — ворота открыты'
}
k2() { # .review ready → rc 1 дословно
  local T="$WORK/k2"; mkt "$T" "$REPO_JSON_GATE"; put_accept "$T"
  review_file "$T" 2026-09-30-01.md ready
  run_gate "$T"
  chk_refuse 'к2: ready-файл блокирует' "$P_READY"
}
k3() { # .review partial → rc 1 дословно
  local T="$WORK/k3"; mkt "$T" "$REPO_JSON_GATE"; put_accept "$T"
  review_file "$T" 2026-09-30-02.md partial
  run_gate "$T"
  chk_refuse 'к3: partial-файл блокирует' "$P_PARTIAL"
}
k4() { # вердикт есть, но НЕ в HEAD → rc 1
  local T="$WORK/k4"; mkt "$T" "$REPO_JSON_GATE"
  printf 'accept\n' > "$T/.harness/verdicts/novyi.md" # незакоммиченный
  run_gate "$T"
  chk_refuse 'к4: незакоммиченный вердикт не считается' "$P_NOVERD"
}
k5() { # .review status: done → не блокирует
  local T="$WORK/k5"; mkt "$T" "$REPO_JSON_GATE"; put_accept "$T"
  review_file "$T" 2026-09-30-03.md done
  run_gate "$T"
  chk_rc0 'к5: закрытая находка (done) не блокирует'
}
k6() { # генератор: команды+барьер перенесены в джобу; файл = эталон И-10
  local T="$WORK/k6"; mkt "$T" "$REPO_JSON_GEN"
  mkdir -p "$T/.harness/fixtures"
  printf '# stub barrier\nprintf barrier-ok\n' > "$T/.harness/fixtures/probe-a.sh"
  printf '# цель существует (059)\n' > "$T/$CW"
  commit_all "$T" 'barrier i tsel CI'
  run_gen "$T"
  chk_rc0 'к6: генератор rc 0' || return 1
  local F="$T/$CW" ok=1
  local m
  for m in 'commands.test' 'commands.build' 'commands.typecheck' 'commands.lint' 'barriers.probe-a'; do
    grep -Fq -- "- name: $m" "$F" || { printf '  FAIL к6: нет маркера шага %s\n' "$m" >&2; ok=0; }
  done
  local c
  for c in 'npm test' 'npm run build' 'tsc --noEmit' 'npm run lint'; do
    grep -Fxq "          $c" "$F" || { printf '  FAIL к6: команда не своей строкой (отступ 10): %s\n' "$c" >&2; ok=0; }
  done
  grep -Fxq '          bash .harness/fixtures/probe-a.sh' "$F" || { printf '  FAIL к6: нет строки барьера\n' >&2; ok=0; }
  wf_etalon "$T" > "$WORK/k6-etalon"
  cmp -s "$F" "$WORK/k6-etalon" || {
    printf '  FAIL к6: файл-цель ≠ эталону И-10 (закрытая форма)\n' >&2
    diff -u "$WORK/k6-etalon" "$F" >&2 || true
    ok=0
  }
  [ "$ok" -eq 1 ]
}
k7() { # vacuous: команд/барьеров нет → rc 0, фраза, байты цели неизменны
  local T="$WORK/k7"; mkt "$T" "$REPO_JSON_VAC"
  printf '# suzdhet toy 063\n' > "$T/$CW"
  commit_all "$T" 'tol tsel CI'
  local before; before="$(g "$T" show "HEAD:$CW" 2>/dev/null | sha256sum | cut -d' ' -f1)"
  run_gen "$T"
  chk_rc0 'к7: vacuous rc 0' || return 1
  printf '%s\n' "$LAST_OUT" | grep -Fq "$P_GENVAC" || { printf '  FAIL к7: нет дословной vacuous-фразы\nвывод:\n%s\n' "$LAST_OUT" >&2; return 1; }
  local after; after="$(sha256sum "$T/$CW" | cut -d' ' -f1)"
  [ "$before" = "$after" ] || { printf '  FAIL к7: файл-цель тронут (sha разошлись)\n' >&2; return 1; }
  return 0
}
k8() { # ленд зелёного входа: merge --no-ff (два родителя), subject land:
  local T="$WORK/k8"; mkt "$T" "$REPO_JSON_GATE"; put_accept "$T"
  g "$T" checkout -q -b feat-x
  printf 'izmenenie vetki\n' > "$T/feature.txt"
  commit_all "$T" 'rabota vetki feat-x'
  g "$T" checkout -q main
  run_land "$T" feat-x
  chk_rc0 'к8: ленд зелёного входа rc 0' || return 1
  local np; np="$(g "$T" rev-list --parents -n1 HEAD | wc -w)"
  [ "$np" -eq 3 ] || { printf '  FAIL к8: у HEAD %s полей родителя (ожидалось 3 = два родителя) — ff-слияние?\n' "$np" >&2; return 1; }
  local subj; subj="$(g "$T" log -1 --format=%s)"
  [ "$subj" = "land: feat-x" ] || { printf '  FAIL к8: subject «%s» ≠ «land: feat-x»\n' "$subj" >&2; return 1; }
  return 0
}
k9() { # ленд красного входа: rc 1, фраза гейта, HEAD неизменен
  local T="$WORK/k9"; mkt "$T" "$REPO_JSON_GATE"; put_accept "$T"
  g "$T" checkout -q -b feat-y
  printf 'izmenenie vetki y\n' > "$T/feature-y.txt"
  commit_all "$T" 'rabota vetki feat-y'
  g "$T" checkout -q main
  review_file "$T" 2026-09-30-01.md ready
  local head_before; head_before="$(g "$T" rev-parse HEAD)"
  run_land "$T" feat-y
  chk_refuse 'к9: ленд красного входа отказывает фразой гейта' "$P_READY" || return 1
  local head_after; head_after="$(g "$T" rev-parse HEAD)"
  [ "$head_before" = "$head_after" ] || { printf '  FAIL к9: HEAD изменился при красном входе\n' >&2; return 1; }
  return 0
}
k10() { # барьер объявлен, файла нет → rc 1 дословно, цель не тронута
  local T="$WORK/k10"; mkt "$T" "$REPO_JSON_GEN"
  printf '# tsel bez bariera\n' > "$T/$CW"
  commit_all "$T" 'tol tsel CI'
  run_gen "$T"
  chk_refuse 'к10: несуществующий барьер — именованный отказ' "$P_NOBARRIER" || return 1
  grep -Fxq '# tsel bez bariera' "$T/$CW" || { printf '  FAIL к10: файл-цель тронут при отказе\n' >&2; return 1; }
  return 0
}
k11() { # исполнимость: каждый шаг переноса производит свой эффект (И-9а+И-10)
  local T="$WORK/k11"; mkt "$T" "$REPO_JSON_EXEC"
  mk_probe_ok "$T"
  printf '# tsel\n' > "$T/$CW"; commit_all "$T" 'exec toy'
  run_gen "$T"
  chk_rc0 'к11: генератор rc 0' || return 1
  wf_etalon "$T" > "$WORK/k11-etalon"
  cmp -s "$T/$CW" "$WORK/k11-etalon" || {
    printf '  FAIL к11: файл-цель ≠ эталону И-10 (закрытая форма)\n' >&2
    diff -u "$WORK/k11-etalon" "$T/$CW" >&2 || true
    return 1
  }
  local wrc=0; wf_run "$T" "$T/$CW" || wrc=$?
  [ "$wrc" -eq 0 ] || { printf '  FAIL к11: локальное исполнение джобы rc %s, ожидался 0\n' "$wrc" >&2; return 1; }
  exp_full_log > "$WORK/k11-expected"
  cmp -s "$WORK/k11-expected" "$T/.harness/toy-ran.log" || {
    printf '  FAIL к11: эффекты шагов не совпали байт-в-байт (команды как данные не исполняются?)\n' >&2
    cat "$T/.harness/toy-ran.log" >&2 2>/dev/null
    return 1
  }
  return 0
}
k12() { # распространение отказа: rc команды = rc джобы, поздние шаги не исполняются (И-9б)
  local T="$WORK/k12"; mkt "$T" "$REPO_JSON_EXECFAIL"
  mk_probe_ok "$T"
  printf '# tsel\n' > "$T/$CW"; commit_all "$T" 'execfail toy'
  run_gen "$T"
  chk_rc0 'к12: генератор rc 0' || return 1
  local wrc=0; wf_run "$T" "$T/$CW" || wrc=$?
  [ "$wrc" -eq 9 ] || { printf '  FAIL к12: rc локального исполнения %s, ожидался 9 (отказ шага не распространён)\n' "$wrc" >&2; return 1; }
  printf 'm-test-%s\n' "$RND" > "$WORK/k12-expected"
  cmp -s "$WORK/k12-expected" "$T/.harness/toy-ran.log" || {
    printf '  FAIL к12: после упавшего шага исполнены поздние (лог ≠ ровно маркер test)\n' >&2
    cat "$T/.harness/toy-ran.log" >&2 2>/dev/null
    return 1
  }
  return 0
}
k13() { # tracked-вердикт FAIL в HEAD, рабочая копия переписана на accept → rc 1 (И-2)
  local T="$WORK/k13"; mkt "$T" "$REPO_JSON_GATE"
  printf 'FAIL\n\ntoy verdikt revju\n' > "$T/.harness/verdicts/stk-063-review.md"
  commit_all "$T" 'verdikt FAIL'
  printf 'accept\n' > "$T/.harness/verdicts/stk-063-review.md" # грязная рабочая копия
  run_gate "$T"
  chk_refuse 'к13: грязная рабочая копия вердикта не считается — судится блоб HEAD' "$P_NOVERD"
}
k14() { # семантика GitHub тела (замер 6 арбитража 063-Б4): false гасит тело
        # (-e), after-эффекта нет, поздние шаги не исполняются (И-9ii)
  local T="$WORK/k14"; mkt "$T" "$REPO_JSON_GHSEM"
  mk_probe_ok "$T"
  printf '# tsel\n' > "$T/$CW"; commit_all "$T" 'ghsem toy'
  run_gen "$T"
  chk_rc0 'к14: генератор rc 0' || return 1
  local wrc=0; wf_run "$T" "$T/$CW" || wrc=$?
  [ "$wrc" -eq 1 ] || { printf '  FAIL к14: rc локального исполнения %s, ожидался 1 (семантика -e)\n' "$wrc" >&2; return 1; }
  if [ -f "$T/.harness/toy-ran.log" ] && grep -Fq "after-$RND" "$T/.harness/toy-ran.log"; then
    printf '  FAIL к14: after-эффект в логе — тело не погашено -e\n' >&2; return 1
  fi
  if [ -f "$T/.harness/toy-ran.log" ] && grep -Fq "m-build-$RND" "$T/.harness/toy-ran.log"; then
    printf '  FAIL к14: поздние шаги исполнились после упавшего\n' >&2; return 1
  fi
  return 0
}

honest_total=0; honest_green=0; honest_fail=""
hcell() { # hcell <имя> <функция>
  local n="$1" f="$2"
  honest_total=$((honest_total + 1))
  if "$f"; then honest_green=$((honest_green + 1)); else honest_fail="$honest_fail $n"; fi
}

hcell к1-accept-bez-review-rc0 k1
hcell к2-review-ready-blokiruet k2
hcell к3-review-partial-blokiruet k3
hcell к4-verdikt-nezakomlichen k4
hcell к5-review-done-ne-blokiruet k5
hcell к6-generator-perenosit-komandy k6
hcell к7-generator-vacuous k7
hcell к8-lend-no-ff-merge-kommit k8
hcell к9-lend-krasnyj-vhod-otkaz k9
hcell к10-barier-bez-fajla k10
hcell к11-ispolnitelnost-shagov k11
hcell к12-rasprostranenie-otkaza k12
hcell к13-griaznaja-kopija-verdikta k13
hcell к14-semantika-github-tela k14

# ── СТАБ-ПАК (обманные реализации; входы честных клеток пересоздаются) ───────
STUBS="$WORK/stubs"; mkdir -p "$STUBS"

# s1 «гейт-слепец к ready-файлам»: вердикт судит, .review/ НЕ читает вовсе.
cat > "$STUBS/s1_slepec_review.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
REPO=""
while [ $# -gt 0 ]; do case "$1" in --repo) REPO="$2"; shift 2;; *) shift;; esac; done
[ -n "$REPO" ] || { printf 'usage: --repo <корень>\n' >&2; exit 1; }
V="$(bash "${RESOLVER:?}" --repo "$REPO" 2>/dev/null | jq -r '.workflowPaths.verdicts.value // empty')"
[ -n "$V" ] || { printf 'merge gate ОТКАЗ: профиль не объявляет workflowPaths.verdicts — вердикты негде искать\n' >&2; exit 1; }
found=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  first="$(git -C "$REPO" show "HEAD:$f" 2>/dev/null | head -n1 || true)"
  if [ "$first" = "accept" ]; then found=1; break; fi
done < <(cd "$REPO" && find "$V" -type f -name '*.md' 2>/dev/null)
[ "$found" -eq 1 ] || { printf 'merge gate ОТКАЗ: нет закоммиченного accept-вердикта ревьюера\n' >&2; exit 1; }
exit 0
EOF

# s2 «генератор-заглушка без команд»: резолв честен, vacuous-ветвь честна,
# но шаги команд/барьеров в джобу НЕ переносит (шаблон без них).
cat > "$STUBS/s2_shablon_bez_komand.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
REPO=""
while [ $# -gt 0 ]; do case "$1" in --repo) REPO="$2"; shift 2;; *) shift;; esac; done
[ -n "$REPO" ] || { printf 'usage: --repo <корень>\n' >&2; exit 1; }
M="$(bash "${RESOLVER:?}" --repo "$REPO" 2>/dev/null)" || { printf '%s\n' "$M" >&2; exit 1; }
CW="$(printf '%s' "$M" | jq -r '.ci.value.workflow // empty')"
NC="$(printf '%s' "$M" | jq -r '[.commands[]?.value] | map(select(. != null)) | length')"
NB="$(printf '%s' "$M" | jq -r '.barriers.mandatory.value // [] | length')"
if [ "$NC" -eq 0 ] && [ "$NB" -eq 0 ]; then
  printf 'ci-генератор: профиль не объявляет команд и барьеров — vacuous, файл не тронут\n' >&2
  exit 0
fi
[ -n "$CW" ] || { printf 'ci-генератор: профиль не объявляет ci.workflow — генерировать некуда\n' >&2; exit 0; }
mkdir -p "$(dirname "$REPO/$CW")"
cat > "$REPO/$CW" <<'YML'
# GENERATED by dev-harness gen_ci_workflow — не править руками; источник — harness.project.json
name: harness
on: [push, pull_request]
jobs:
  harness:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
YML
exit 0
EOF

# s3 «--no-ff-обходчик»: встроенный гейт ЧЕСТЕН (accept ∧ .review), но merge
# идёт БЕЗ --no-ff — ff возможен и HEAD остаётся с одним родителем.
cat > "$STUBS/s3_ff_obhodchik.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
REPO=""; BR=""
while [ $# -gt 0 ]; do case "$1" in --repo) REPO="$2"; shift 2;; --branch) BR="$2"; shift 2;; *) shift;; esac; done
[ -n "$REPO" ] && [ -n "$BR" ] || { printf 'land project ОТКАЗ: usage: bash scripts/land_project.sh --repo <корень> --branch <ветка>\n' >&2; exit 1; }
V="$(bash "${RESOLVER:?}" --repo "$REPO" 2>/dev/null | jq -r '.workflowPaths.verdicts.value // empty')"
blocked=0
while IFS= read -r rf; do
  [ -n "$rf" ] || continue
  [ -f "$REPO/$rf" ] || continue
  st="$(awk 'NR==1{fm=($0=="---")} fm&&NR>1{if($0=="---")exit; if($0~/^status: /){sub(/^status: /,"");print;exit}}' "$REPO/$rf")"
  if [ "$st" = "ready" ] || [ "$st" = "partial" ]; then
    printf 'merge gate ОТКАЗ: незакрытая находка ревьюера: %s (status: %s)\n' "$rf" "$st" >&2
    blocked=1
  fi
done < <(cd "$REPO" && find .review -maxdepth 1 -name '*.md' 2>/dev/null)
[ "$blocked" -eq 0 ] || exit 1
found=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  first="$(git -C "$REPO" show "HEAD:$f" 2>/dev/null | head -n1 || true)"
  if [ "$first" = "accept" ]; then found=1; break; fi
done < <(cd "$REPO" && find "$V" -type f -name '*.md' 2>/dev/null)
[ "$found" -eq 1 ] || { printf 'merge gate ОТКАЗ: нет закоммиченного accept-вердикта ревьюера\n' >&2; exit 1; }
git -C "$REPO" -c user.name=orchestrator -c user.email=orchestrator@dev-harness.local -c commit.gpgsign=false merge -m "land: $BR" "$BR" >/dev/null 2>&1 || {
  printf 'ОТКАЗ: merge отказал\n' >&2; exit 1; }
exit 0
EOF

# s4 «heredoc-транспорт» (обход Б1): резолв/vacuous/отсутствие-барьера
# честны, ВСЕ маркеры шагов и строки команд присутствуют с нужными
# отступами, но команды/барьеры — ДАННЫЕ no-op-шага `: <<'COMMANDS'`:
# ни одна команда профиля не исполняется.
cat > "$STUBS/s4_heredoc_transport.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
REPO=""
while [ $# -gt 0 ]; do case "$1" in --repo) REPO="$2"; shift 2;; *) shift;; esac; done
[ -n "$REPO" ] || { printf 'usage: --repo <корень>\n' >&2; exit 1; }
M="$(bash "${RESOLVER:?}" --repo "$REPO" 2>/dev/null)" || { printf '%s\n' "$M" >&2; exit 1; }
CW="$(printf '%s' "$M" | jq -r '.ci.value.workflow // empty')"
NC="$(printf '%s' "$M" | jq -r '[.commands[]?.value] | map(select(. != null)) | length')"
NB="$(printf '%s' "$M" | jq -r '.barriers.mandatory.value // [] | length')"
if [ "$NC" -eq 0 ] && [ "$NB" -eq 0 ]; then
  printf 'ci-генератор: профиль не объявляет команд и барьеров — vacuous, файл не тронут\n' >&2
  exit 0
fi
[ -n "$CW" ] || { printf 'ci-генератор: профиль не объявляет ci.workflow — генерировать некуда\n' >&2; exit 0; }
FIX="$(printf '%s' "$M" | jq -r '.workflowPaths.fixtures.value // empty')"
while IFS= read -r b; do
  [ -n "$b" ] || continue
  [ -f "$REPO/$FIX/$b.sh" ] || { printf 'ci-генератор ОТКАЗ: объявленный барьер отсутствует в дереве: %s (%s/%s.sh)\n' "$b" "$FIX" "$b" >&2; exit 1; }
done < <(printf '%s' "$M" | jq -r '.barriers.mandatory.value[]?')
mkdir -p "$(dirname "$REPO/$CW")"
{
  printf '# GENERATED by dev-harness gen_ci_workflow — не править руками; источник — harness.project.json\n'
  printf 'name: harness\non: [push, pull_request]\njobs:\n  harness:\n    runs-on: ubuntu-latest\n    steps:\n      - uses: actions/checkout@v4\n'
  printf '      - name: transport\n        run: |\n'
  printf '          : <<%s\n' "'COMMANDS'"
  for k in test build typecheck lint; do
    v="$(printf '%s' "$M" | jq -r --arg k "$k" '.commands[$k].value // empty')"
    [ -n "$v" ] || continue
    printf '          - name: commands.%s\n' "$k"
    while IFS= read -r l; do printf '          %s\n' "$l"; done <<< "$v"
  done
  while IFS= read -r b; do
    [ -n "$b" ] || continue
    printf '          - name: barriers.%s\n' "$b"
    printf '          bash %s/%s.sh\n' "$FIX" "$b"
  done < <(printf '%s' "$M" | jq -r '.barriers.mandatory.value[]?')
  printf '          COMMANDS\n'
} > "$REPO/$CW"
exit 0
EOF

# s5 «грязная копия вердикта» (обход Б2): .review и перечисление
# tracked-файлов честны (незакоммиченный вердикт не виден), но первая
# строка читается из РАБОЧЕГО файла, а не из блоба HEAD.
cat > "$STUBS/s5_griaznaja_kopija.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
REPO=""
while [ $# -gt 0 ]; do case "$1" in --repo) REPO="$2"; shift 2;; *) shift;; esac; done
[ -n "$REPO" ] || { printf 'usage: --repo <корень>\n' >&2; exit 1; }
V="$(bash "${RESOLVER:?}" --repo "$REPO" 2>/dev/null | jq -r '.workflowPaths.verdicts.value // empty')"
[ -n "$V" ] || { printf 'merge gate ОТКАЗ: профиль не объявляет workflowPaths.verdicts — вердикты негде искать\n' >&2; exit 1; }
blocked=0
while IFS= read -r rf; do
  [ -n "$rf" ] || continue
  [ -f "$REPO/$rf" ] || continue
  st="$(awk 'NR==1{fm=($0=="---")} fm&&NR>1{if($0=="---")exit; if($0~/^status: /){sub(/^status: /,"");print;exit}}' "$REPO/$rf")"
  if [ "$st" = "ready" ] || [ "$st" = "partial" ]; then
    printf 'merge gate ОТКАЗ: незакрытая находка ревьюера: %s (status: %s)\n' "$rf" "$st" >&2
    blocked=1
  fi
done < <(cd "$REPO" && find .review -maxdepth 1 -name '*.md' 2>/dev/null)
[ "$blocked" -eq 0 ] || exit 1
found=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  case "$f" in *.md) ;; *) continue ;; esac
  [ -f "$REPO/$f" ] || continue
  first="$(head -n1 "$REPO/$f")" # РУЧКА ОБМАНА: рабочий файл, не HEAD-блоб
  [ "$first" = "accept" ] && { found=1; break; }
done < <(git -C "$REPO" ls-files -c -- "$V")
[ "$found" -eq 1 ] || { printf 'merge gate ОТКАЗ: нет закоммиченного accept-вердикта ревьюера\n' >&2; exit 1; }
exit 0
EOF

# s6 «выключатель контура» (обход Б4, арбитраж dea4268): резолв/vacuous/
# отсутствие барьера/маркеры к6/тела шагов и их эффекты ЧЕСТНЫ — файл
# отличается от эталона И-10 РОВНО одной строкой `if:` джобы, в GitHub
# выключающей джобу целиком; раннер условий не вычисляет (П2) — смерть
# ловит закрытая форма И-10, диффпроба показывает живые эффекты И-9.
cat > "$STUBS/s6_vyklyuchatel_kontura.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
REPO=""
while [ $# -gt 0 ]; do case "$1" in --repo) REPO="$2"; shift 2;; *) shift;; esac; done
[ -n "$REPO" ] || { printf 'usage: --repo <корень>\n' >&2; exit 1; }
M="$(bash "${RESOLVER:?}" --repo "$REPO" 2>/dev/null)" || { printf '%s\n' "$M" >&2; exit 1; }
CW="$(printf '%s' "$M" | jq -r '.ci.value.workflow // empty')"
NC="$(printf '%s' "$M" | jq -r '[.commands[]?.value] | map(select(. != null)) | length')"
NB="$(printf '%s' "$M" | jq -r '.barriers.mandatory.value // [] | length')"
if [ "$NC" -eq 0 ] && [ "$NB" -eq 0 ]; then
  printf 'ci-генератор: профиль не объявляет команд и барьеров — vacuous, файл не тронут\n' >&2
  exit 0
fi
[ -n "$CW" ] || { printf 'ci-генератор: профиль не объявляет ci.workflow — генерировать некуда\n' >&2; exit 0; }
FIX="$(printf '%s' "$M" | jq -r '.workflowPaths.fixtures.value // empty')"
while IFS= read -r b; do
  [ -n "$b" ] || continue
  [ -f "$REPO/$FIX/$b.sh" ] || { printf 'ci-генератор ОТКАЗ: объявленный барьер отсутствует в дереве: %s (%s/%s.sh)\n' "$b" "$FIX" "$b" >&2; exit 1; }
done < <(printf '%s' "$M" | jq -r '.barriers.mandatory.value[]?')
mkdir -p "$(dirname "$REPO/$CW")"
{
  printf '# GENERATED by dev-harness gen_ci_workflow — не править руками; источник — harness.project.json\n'
  printf 'name: harness\non: [push, pull_request]\njobs:\n  harness:\n'
  printf '    if: ${{ false }}\n'
  printf '    runs-on: ubuntu-latest\n    steps:\n      - uses: actions/checkout@v4\n'
  for k in test build typecheck lint; do
    v="$(printf '%s' "$M" | jq -r --arg k "$k" '.commands[$k].value // empty')"
    [ -n "$v" ] || continue
    printf '      - name: commands.%s\n        run: |\n' "$k"
    while IFS= read -r l; do printf '          %s\n' "$l"; done <<< "$v"
  done
  while IFS= read -r b; do
    [ -n "$b" ] || continue
    printf '      - name: barriers.%s\n        run: |\n          bash %s/%s.sh\n' "$b" "$FIX" "$b"
  done < <(printf '%s' "$M" | jq -r '.barriers.mandatory.value[]?')
} > "$REPO/$CW"
exit 0
EOF
chmod +x "$STUBS"/*.sh

stub_total=0; stub_caught=0; stub_esc=""
scell() { # scell <имя> <функция-детекции>; дефект НАБЛЮДЁН = пойман
  local n="$1" f="$2"
  stub_total=$((stub_total + 1))
  if "$f"; then stub_caught=$((stub_caught + 1)); else stub_esc="$stub_esc $n"; fi
}
diff_total=0; diff_green=0; diff_fail=""
dcell() { # dcell <имя> <функция-диффпробы>; rc0 = стаб честен на контроле
  local n="$1" f="$2"
  diff_total=$((diff_total + 1))
  if "$f"; then diff_green=$((diff_green + 1)); else diff_fail="$diff_fail $n"; fi
}

# входы стабов: СВЕЖИЕ игрушки (стабы пишут/мержат — состоянием не делятся)
mk_in_k1() { local T="$1"; mkt "$T" "$REPO_JSON_GATE"; put_accept "$T"; }
mk_in_k2() { local T="$1"; mkt "$T" "$REPO_JSON_GATE"; put_accept "$T"; review_file "$T" 2026-09-30-01.md ready; }
mk_in_k6() { # генераторный вход с барьером и целью
  local T="$1"; mkt "$T" "$REPO_JSON_GEN"
  mkdir -p "$T/.harness/fixtures"
  printf '# stub barrier\nprintf barrier-ok\n' > "$T/.harness/fixtures/probe-a.sh"
  printf '# tsel\n' > "$T/$CW"; commit_all "$T" 'barrier i tsel'
}
mk_in_k7() { local T="$1"; mkt "$T" "$REPO_JSON_VAC"; printf '# tsel\n' > "$T/$CW"; commit_all "$T" 'tol tsel'; }
mk_in_k8() { # ленд-вход зелёный: ветка ahead
  local T="$1"; mkt "$T" "$REPO_JSON_GATE"; put_accept "$T"
  g "$T" checkout -q -b feat-x; printf 'vetka\n' > "$T/f.txt"; commit_all "$T" 'rabota'
  g "$T" checkout -q main
}
mk_in_k9() { # ленд-вход красный: ready-файл + ветка ahead
  local T="$1"; mk_in_k8 "$T"; review_file "$T" 2026-09-30-01.md ready
}
mk_in_k11() { # генераторный вход с маркерными командами и барьером
  local T="$1"; mkt "$T" "$REPO_JSON_EXEC"
  mk_probe_ok "$T"
  printf '# tsel\n' > "$T/$CW"; commit_all "$T" 'exec toy'
}
mk_in_k13() { # tracked FAIL-вердикт, рабочая копия переписана на accept
  local T="$1"; mkt "$T" "$REPO_JSON_GATE"
  printf 'FAIL\n\ntoy verdikt revju\n' > "$T/.harness/verdicts/stk-063-review.md"
  commit_all "$T" 'verdikt FAIL'
  printf 'accept\n' > "$T/.harness/verdicts/stk-063-review.md"
}

s1() { # смерть к2: слепец пропускает блокирующий вход (rc 0 = дефект наблюдён)
  local T="$WORK/s1d"; mk_in_k2 "$T"
  bash "$STUBS/s1_slepec_review.sh" --repo "$T" >/dev/null 2>&1
  [ $? -eq 0 ]
}
s1_diff() { # контроль к1: слепец честен на зелёном входе
  local T="$WORK/s1c"; mk_in_k1 "$T"
  bash "$STUBS/s1_slepec_review.sh" --repo "$T" >/dev/null 2>&1
  [ $? -eq 0 ]
}
s2() { # смерть к6: шаблон без шагов — маркер commands.test отсутствует
  local T="$WORK/s2d"; mk_in_k6 "$T"
  bash "$STUBS/s2_shablon_bez_komand.sh" --repo "$T" >/dev/null 2>&1
  [ $? -eq 0 ] && [ -f "$T/$CW" ] && ! grep -Fq -- '- name: commands.test' "$T/$CW"
}
s2_diff() { # контроль к7: на vacuous-входе заглушка ведёт себя как честная
  local T="$WORK/s2c"; mk_in_k7 "$T"
  local out; out="$(bash "$STUBS/s2_shablon_bez_komand.sh" --repo "$T" 2>&1)"
  local rc=$?
  [ "$rc" -eq 0 ] && printf '%s\n' "$out" | grep -Fq "$P_GENVAC" && grep -Fxq '# tsel' "$T/$CW"
}
s3() { # смерть к8: ff-слияние — у HEAD один родитель
  local T="$WORK/s3d"; mk_in_k8 "$T"
  bash "$STUBS/s3_ff_obhodchik.sh" --repo "$T" --branch feat-x >/dev/null 2>&1
  [ $? -eq 0 ] && [ "$(g "$T" rev-list --parents -n1 HEAD | wc -w)" -eq 2 ]
}
s3_diff() { # контроль к9: красный вход отказывает, HEAD неизменен
  local T="$WORK/s3c"; mk_in_k9 "$T"
  local b; b="$(g "$T" rev-parse HEAD)"
  bash "$STUBS/s3_ff_obhodchik.sh" --repo "$T" --branch feat-x >/dev/null 2>&1
  [ $? -eq 1 ] && [ "$(g "$T" rev-parse HEAD)" = "$b" ]
}
s4() { # смерть к11: команды-данные heredoc не производят эффектов
  local T="$WORK/s4d"; mk_in_k11 "$T"
  bash "$STUBS/s4_heredoc_transport.sh" --repo "$T" >/dev/null 2>&1
  local grc=$? wrc=0
  wf_run "$T" "$T/$CW" || wrc=$?
  [ "$grc" -eq 0 ] && [ "$wrc" -eq 0 ] && ! grep -Fxq 'test' "$T/.harness/toy-ran.log" 2>/dev/null
}
s4_diff() { # контроль к6: все маркеры шагов и строки команд на месте — стаб честен
  local T="$WORK/s4c"; mk_in_k6 "$T"
  bash "$STUBS/s4_heredoc_transport.sh" --repo "$T" >/dev/null 2>&1
  local rc=$? ok=1 m c
  [ "$rc" -eq 0 ] || ok=0
  for m in 'commands.test' 'commands.build' 'commands.typecheck' 'commands.lint' 'barriers.probe-a'; do
    grep -Fq -- "- name: $m" "$T/$CW" || ok=0
  done
  for c in 'npm test' 'npm run build' 'tsc --noEmit' 'npm run lint'; do
    grep -Fxq "          $c" "$T/$CW" || ok=0
  done
  grep -Fxq '          bash .harness/fixtures/probe-a.sh' "$T/$CW" || ok=0
  [ "$ok" -eq 1 ]
}
s5() { # смерть к13: грязная копия tracked-вердикта открывает ворота (rc 0 = дефект наблюдён)
  local T="$WORK/s5d"; mk_in_k13 "$T"
  bash "$STUBS/s5_griaznaja_kopija.sh" --repo "$T" >/dev/null 2>&1
  [ $? -eq 0 ]
}
s5_diff() { # контроль к1: чистый закоммиченный accept — стаб честен
  local T="$WORK/s5c"; mk_in_k1 "$T"
  bash "$STUBS/s5_griaznaja_kopija.sh" --repo "$T" >/dev/null 2>&1
  [ $? -eq 0 ]
}
s6() { # смерть к11 (И-10): файл неконформен — cmp с эталоном расходится —
       # ПРИ наблюдаемых эффектах И-9 (wf_run исполняет все шаги, rc 0)
  local T="$WORK/s6d"; mk_in_k11 "$T"
  bash "$STUBS/s6_vyklyuchatel_kontura.sh" --repo "$T" >/dev/null 2>&1
  local grc=$? wrc=0
  wf_etalon "$T" > "$WORK/s6d-etalon"
  cmp -s "$T/$CW" "$WORK/s6d-etalon" && return 1
  wf_run "$T" "$T/$CW" || wrc=$?
  [ "$grc" -eq 0 ] && [ "$wrc" -eq 0 ]
}
s6_diff() { # контроль: ТОТ ЖЕ стаб на входе исполнимости — лог эффектов
            # идентичен честному (И-9 без И-10 обход не ловит)
  local T="$WORK/s6c"; mk_in_k11 "$T"
  bash "$STUBS/s6_vyklyuchatel_kontura.sh" --repo "$T" >/dev/null 2>&1
  local wrc=0; wf_run "$T" "$T/$CW" || wrc=$?
  exp_full_log > "$WORK/s6c-expected"
  [ "$wrc" -eq 0 ] && cmp -s "$WORK/s6c-expected" "$T/.harness/toy-ran.log"
}

scell s1-гейт-слепец-к-ready s1
scell s2-генератор-без-команд s2
scell s3-no-ff-обходчик s3
scell s4-heredoc-transport s4
scell s5-griaznaja-kopija-verdikta s5
dcell s1-диффпроба s1_diff
dcell s2-диффпроба s2_diff
dcell s3-диффпроба s3_diff
dcell s4-диффпроба s4_diff
dcell s5-диффпроба s5_diff
scell s6-выключатель-контура s6
dcell s6-диффпроба s6_diff

# ── итог: счёт просмотренного; пустая выборка — красное ───────────────────────
printf '063: честных клеток %d, зелёных %d, красных:%s\n' \
  "$honest_total" "$honest_green" "${honest_fail:- нет}"
printf '063: стабов %d, поймано %d, ускользнуло:%s\n' \
  "$stub_total" "$stub_caught" "${stub_esc:- нет}"
printf '063: диффпроб стабов без ручки %d, зелёных %d, провал:%s\n' \
  "$diff_total" "$diff_green" "${diff_fail:- нет}"

[ "$honest_total" -gt 0 ] || { printf '063: ПУСТАЯ выборка честных клеток — красное\n' >&2; exit 1; }
[ "$stub_total" -gt 0 ]   || { printf '063: ПУСТАЯ выборка стабов — красное\n' >&2; exit 1; }
[ "$diff_total" -gt 0 ]   || { printf '063: ПУСТАЯ выборка диффпроб — красное\n' >&2; exit 1; }
[ "$stub_caught" -eq "$stub_total" ] || exit 1
[ "$diff_green" -eq "$diff_total" ] || exit 1
[ "$honest_green" -eq "$honest_total" ] || exit 1
exit 0
