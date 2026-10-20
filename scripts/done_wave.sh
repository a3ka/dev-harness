#!/usr/bin/env bash
# scripts/done_wave.sh — дверь done-волны (уровень Б, контракт 110).
# Принимает волну (все строки plan.tsv с данной парой), проверяет уровень Б
# (терминальность каждой строки, манифест с NFR/e2e/review/otkat, сквозной
# прогон, наличие и формат плана отката, закрытость находок владельца) и
# ставит единственный законный релизный тег волны done/waves/<пара>/<v>;
# либо отказывает с именованной причиной, не мутируя refs.
#
# Контракт API:
#   bash scripts/done_wave.sh <корень> <пара> "<причина>"
#   rc 0 — тег поставлен; stdout v<N>;
#   rc 1 — именованный отказ stderr «done_wave: …»;
#   rc 2 — NOT_IMPLEMENTED.
#
# Все источники (план, закрытия, манифест, находки review, план отката) читаются
# из HEAD-блобов: незакоммиченная правка любого источника — не доказательство.
# Членство — канонический plan_parse из scripts/lib_plan.sh (второго парсера нет);
# путь реестра — профильный, через project_paths_resolve (996).
# НЕ БАРЬЕР: субъект контракта 110 — красное и зелёный контроль предъявляет собственная
# батарея fixtures/workshop_project/done_volny_110/ (probe.sh, 71 случай + 50 мутантов
# по замеру run_ci_lane/ci_vesa: «5.8..6.3 с», вес в ci-steps.tsv — 6),
# не case_*.sh-глобом (прецедент scripts/make_task.sh:10, контракт 095).
# Исход: 0 — тег поставлен (stdout «v<N>»), 1 — именованный отказ «done_wave: …»,
# 2 — NOT_IMPLEMENTED (нет git/jq/профиля).
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

die()  { printf 'done_wave: %s\n' "$*" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

ROOT="${1:-}"; W="${2:-}"; REASON="${3-}"
[ -n "$ROOT" ] && [ -n "$W" ] \
  || { printf 'done_wave: использование: <корень> <пара> "<причина>"\n' >&2; exit 2; }

[ -d "$ROOT/.git" ] || git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 \
  || skip "корень не git-репозиторий: $ROOT"

ROOT_ABS="$(cd "$ROOT" && pwd -P)" || die "корень не читается: $ROOT"

# ── A3: корень обязан быть вершиной git-репозитория (не подкаталог) ─────────
TOP_ABS="$(git -C "$ROOT" rev-parse --show-toplevel 2>/dev/null)" \
  || die "корень не git-репозиторий: $ROOT"
[ "$TOP_ABS" = "$ROOT_ABS" ] || die "корень не корень репозитория: $ROOT_ABS"

# ── Б1: HEAD снимается один раз в начале; все блобы и тег — от него ──────────
HEAD_SHA="$(git -C "$ROOT" rev-parse --verify -q "HEAD^{commit}")" \
  || die "HEAD недоступен: $ROOT"

# ── N11b: путь слоя профиля берётся из HEAD-блоба harness.project.json
# (projectLayer.profilePath // "registry/harness-project.json"). Не
# зашитое имя project-layer.json — резолвер читает именно профильный
# слой, и слой проекта из рабочего дерева подменял бы реестр корневым
# деко (adv110 N11b). harness.project.json на HEAD необязателен (миры без
# профиля идут LEGACY-fallback'ом); при наличии — все три источника
# (harness.project.json, projectLayer.profilePath-файл) проверены:
# «есть на HEAD, нет/расходится в дереве → отказ».
PROFILE_PATH=""
if git -C "$ROOT" cat-file -e "${HEAD_SHA}:harness.project.json" 2>/dev/null; then
  # harness.project.json на HEAD: проверить его в рабочем дереве
  if [ -e "$ROOT/harness.project.json" ]; then
    [ -L "$ROOT/harness.project.json" ] \
      && die "символическая ссылка профиля: harness.project.json"
    if [ ! -f "$ROOT/harness.project.json" ]; then
      die "профиль проекта расходится с HEAD: harness.project.json"
    fi
    git -C "$ROOT" diff --quiet "$HEAD_SHA" -- harness.project.json 2>/dev/null \
      || die "профиль проекта расходится с HEAD: harness.project.json"
  else
    die "профиль проекта расходится с HEAD: harness.project.json"
  fi
  # путь слоя — из HEAD-блоба
  HPJ="$(git -C "$ROOT" cat-file -p "${HEAD_SHA}:harness.project.json" 2>/dev/null)"
  PROFILE_PATH="$(printf '%s' "$HPJ" | jq -r '.projectLayer.profilePath // "registry/harness-project.json"')"
  [ -n "$PROFILE_PATH" ] && [ "$PROFILE_PATH" != "null" ] \
    || die "профиль проекта не объявил projectLayer.profilePath"
  case "$PROFILE_PATH" in
    /*|*/../*|*/..|../*|*/./*|*/. ) die "профиль проекта profilePath вне корня: $PROFILE_PATH" ;;
  esac
  # ── И-1: профильный слой — на HEAD и не расходится с рабочим деревом ─────
  if [ -e "$ROOT/$PROFILE_PATH" ]; then
    [ -L "$ROOT/$PROFILE_PATH" ] \
      && die "символическая ссылка профиля: $PROFILE_PATH"
    if [ ! -f "$ROOT/$PROFILE_PATH" ]; then
      die "профиль проекта расходится с HEAD: $PROFILE_PATH"
    fi
    git -C "$ROOT" cat-file -e "${HEAD_SHA}:$PROFILE_PATH" 2>/dev/null \
      || die "профиль проекта не на HEAD: $PROFILE_PATH"
    git -C "$ROOT" diff --quiet "$HEAD_SHA" -- "$PROFILE_PATH" 2>/dev/null \
      || die "профиль проекта расходится с HEAD: $PROFILE_PATH"
  else
    git -C "$ROOT" cat-file -e "${HEAD_SHA}:$PROFILE_PATH" 2>/dev/null \
      && die "профиль проекта расходится с HEAD: $PROFILE_PATH"
  fi
fi

# Причина пуста — отказ ДО всех проверок (И-8).
[ -n "${REASON//[[:space:]]/}" ] || die "причина пуста"

# ── И-1 реестр: профильный project_paths_resolve (996), не корневой деко ──────
NEXT_ID_LIB=1 source "$SELF_DIR/next_id.sh" \
  || skip "библиотека next_id.sh недоступна (нет project_paths_resolve)"
command -v jq >/dev/null 2>&1 || skip "нет jq (требование project_paths_resolve)"

PPR_JSON="$(project_paths_resolve "$ROOT")" \
  || die "профиль проекта не разрешается: $ROOT"
REG_ABS="$(printf '%s' "$PPR_JSON" | jq -r '.registry')"
[ -n "$REG_ABS" ] || die "профиль проекта не объявил registry"
REG_REL="${REG_ABS#"$ROOT_ABS"/}"
[ "$REG_ABS" != "$REG_REL" ] || die "registry профиля вне корня: $REG_ABS"
export LIB_PLAN_REGISTRY="$REG_REL"

# ── И-1 членство: HEAD-блоб плана, канонический plan_parse ──────────────────
PLAN_TMP="$(mktemp)"
git -C "$ROOT" cat-file blob "${HEAD_SHA}:${REG_REL}/plan.tsv" >"$PLAN_TMP" 2>/dev/null \
  || { rm -f "$PLAN_TMP"; die "план недоступен на HEAD: ${REG_REL}/plan.tsv"; }
source "$SELF_DIR/lib_plan.sh"
plan_parse "$PLAN_TMP" || { rm -f "$PLAN_TMP"; die "$P84_PLAN_ERR"; }
rm -f "$PLAN_TMP"

declare -a WAVE_IDS=()
for i in "${!P84_ID[@]}"; do
  [ "${P84_PAIR[$i]}" = "$W" ] || continue
  WAVE_IDS+=("${P84_ID[$i]}")
done
[ "${#WAVE_IDS[@]}" -gt 0 ] || die "волна $W пуста: нет строк плана с этой парой"

# ── И-2 терминальность КАЖДОЙ строки (закрытия — HEAD-блоб реестра) ──────────
CLOSED="$(git -C "$ROOT" cat-file -p "${HEAD_SHA}:${REG_REL}/closed-without-done.tsv" 2>/dev/null || true)"
for id in "${WAVE_IDS[@]}"; do
  if [ -n "${id//[0-9]/}" ]; then
    # символьный id — терминален только закрытием владельца
    printf '%s\n' "$CLOSED" | awk -F'\t' -v x="$id" '$1==x {f=1} END {exit !f}' \
      || die "строка волны не терминальна: $id не начат (символьная строка без закрытия владельца)"
  else
    # числовой id — терминален тегом done/contracts/<id>/*
    git -C "$ROOT" for-each-ref --format='%(refname)' \
      "refs/tags/done/contracts/${id}/" 2>/dev/null | grep -q . \
      || die "строка волны не терминальна: $id (нет done-тега)"
  fi
done

# ── И-3 манифест: HEAD-блоб, закрытый алфавит, nfr≥1, e2e/otkat ровно 1 ────
MANIFEST="$(git -C "$ROOT" cat-file -p "${HEAD_SHA}:${REG_REL}/waves/${W}.tsv" 2>/dev/null)" \
  || die "манифест волны отсутствует: ${REG_REL}/waves/${W}.tsv"

declare -a NFR_ROWS=()
E2E_CMD=""
OTKAT_PATH=""
declare -a REVIEW_PATHS=()
nfr_n=0; e2e_n=0; otkat_n=0; row_n=0
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in ''|'#'*) continue ;; esac
  row_n=$((row_n + 1))
  IFS=$'\t' read -r kind f2 f3 f4 f5 f6 <<< "$line"
  case "$kind" in
    nfr)
      [ -n "$f2" ] && [ -n "$f3" ] && [ -n "$f4" ] \
        || die "строка манифеста неполна: nfr без имени/команды/регекса"
      case "$f5" in le|ge) ;; *) die "NFR $f2: оператор вне алфавита: $f5" ;; esac
      case "$f6" in ''|*[!0-9.]*) die "NFR $f2: порог не число: $f6" ;; esac
      NFR_ROWS+=("$line")
      nfr_n=$((nfr_n + 1))
      ;;
    e2e)
      e2e_n=$((e2e_n + 1))
      [ "$e2e_n" -le 1 ] || die "e2e строка не одна"
      [ -n "$f2" ] || die "строка манифеста неполна: e2e без команды"
      E2E_CMD="$f2"
      ;;
    review)
      [ -n "$f2" ] || die "строка манифеста неполна: review без пути"
      REVIEW_PATHS+=("$f2")
      ;;
    otkat)
      otkat_n=$((otkat_n + 1))
      [ "$otkat_n" -le 1 ] || die "otkat строка не одна"
      [ -n "$f2" ] || die "строка манифеста неполна: otkat без пути"
      OTKAT_PATH="$f2"
      ;;
    *) die "строка манифеста вне алфавита: $kind" ;;
  esac
done <<< "$MANIFEST"
[ "$row_n" -gt 0 ] || die "манифест волны пуст"
[ "$nfr_n" -ge 1 ] || die "манифест волны не объявил численных NFR: нет nfr строк"
[ -n "$E2E_CMD" ] || die "манифест волны не объявил сквозной запуск: нет e2e строки"
[ -n "$OTKAT_PATH" ] || die "манифест волны не объявил план отката: нет otkat строки"

# ── A1/A1b: грязное отслеживаемое дерево вне пяти HEAD-источников — отказ ────
# Пять источников (план, закрытия, манифест, находки, откат) прочитаны как
# HEAD-блобы (правило H); их расхождение с HEAD не доказывает обхода, отказ
# уже выставлен по HEAD-блобу. Здесь — только прочий код (e2e.sh, nfr.sh и т.п.),
# который команда манифеста исполняет в рабочем дереве.
HEAD_SOURCES="${REG_REL}/plan.tsv
${REG_REL}/closed-without-done.tsv
${REG_REL}/waves/${W}.tsv
${OTKAT_PATH}"
for p in "${REVIEW_PATHS[@]}"; do
  HEAD_SOURCES="$HEAD_SOURCES
$p"
done
# ── N2/N3: читаем грязное дерево через -z (rev110 С8: пути с пробелами и
# кириллицей без кавычек; N3: индекс путей — NUL-байт, не пробел). rc
# `git status` теряется в $() при пайпе, поэтому снимаем его явно через
# out-файл: в `if !` после `!` $? уже не равен rc команды, поэтому
# запоминаем rc ДО проверки.
DIRTY_OUT="$(mktemp)"
git -C "$ROOT" status --porcelain=v1 -z --no-renames \
                      --untracked-files=no >"$DIRTY_OUT" 2>&1
rc_git=$?
if [ "$rc_git" -ne 0 ]; then
  msg="$(head -n1 "$DIRTY_OUT" 2>/dev/null | tr '\n' ' ')"
  rm -f "$DIRTY_OUT"
  die "не удалось определить состояние рабочего дерева: $msg"
fi
DIRTY=""
while IFS= read -r -d '' entry; do
  DIRTY="${DIRTY}
${entry:3}"
done <"$DIRTY_OUT"
rm -f "$DIRTY_OUT"
DIRTY="$(printf '%s\n' "$DIRTY" | sort -u)"
for d in $DIRTY; do
  [ -z "$d" ] && continue
  case "
$HEAD_SOURCES
" in
    *"
$d
"*) ;;
    *) die "рабочее дерево расходится с HEAD: $d (не HEAD-источник)" ;;
  esac
done

# ── И-4 NFR: КАЖДАЯ строка, число из вывода, порог — литерал строки ─────────
for nfr in "${NFR_ROWS[@]}"; do
  IFS=$'\t' read -r kind name cmd regex op porog <<< "$nfr"
  out_rc=0
  out="$( cd "$ROOT" && timeout 60 bash -c "$cmd" 2>&1 )" || out_rc=$?
  [ "$out_rc" -eq 0 ] || die "NFR $name: команда rc=$out_rc"
  num=""
  while IFS= read -r l; do
    if [[ "$l" =~ $regex ]] && [ -n "${BASH_REMATCH[1]:-}" ]; then
      num="${BASH_REMATCH[1]}"
      break
    fi
  done <<< "$out"
  [ -n "$num" ] || die "NFR $name: метрика не найдена"
  case "$num" in ''|*[!0-9.]*) die "NFR $name: метрика не число: $num" ;; esac
  ok="$(awk -v a="$num" -v b="$porog" -v o="$op" \
        'BEGIN { print (o=="le" ? (a<=b) : (a>=b)) }')"
  [ "$ok" = "1" ] || die "NFR $name: $num не $op $porog"
done

# ── И-5 e2e: один сквозной запуск, СВЕЖИЙ прогон каждого вызова (Б7) ────────
e2e_rc=0
( cd "$ROOT" && timeout 600 bash -c "$E2E_CMD" ) >/dev/null 2>&1 || e2e_rc=$?
[ "$e2e_rc" -eq 0 ] || die "сквозной запуск волны красный: rc=$e2e_rc"

# ── И-6 review: КАЖДЫЙ файл, статус литерально done, trim только краёв (Б5) ─
for p in "${REVIEW_PATHS[@]}"; do
  [ -n "$p" ] || continue
  blob="$(git -C "$ROOT" cat-file -p "${HEAD_SHA}:$p" 2>/dev/null)" \
    || die "находка владельца отсутствует на HEAD: $p"
  st="$(printf '%s\n' "$blob" | sed -nE 's/^status:[[:space:]]*//p' | sed -n 1p)"
  st="$(printf '%s' "$st" | sed -E 's/[[:space:]]+$//')"
  [ "$st" = "done" ] \
    || die "находка владельца открыта: $p status=${st:-нет_строки_status}"
done

# ── И-7 otkat: обязательные поля плана отката ──────────────────────────────
oblob="$(git -C "$ROOT" cat-file -p "${HEAD_SHA}:$OTKAT_PATH" 2>/dev/null)" \
  || die "план отката отсутствует: $OTKAT_PATH"
for fld in "риск" "sha" "команда-отката" "команда-проверки"; do
  printf '%s\n' "$oblob" | grep -E "^${fld}:[[:space:]]*[^[:space:]]" >/dev/null \
    || die "план отката без поля: $fld"
done

# ── И-8 тег: v=max+1, клапан v>1; аннотированный тег КОММИТА HEAD_SHA ───────
vmax=0
while IFS= read -r t; do
  [ -n "$t" ] || continue
  vn="${t##*done/waves/${W}/}"
  case "$vn" in ''|*[!0-9]*) continue ;; esac
  [ "$vn" -gt "$vmax" ] && vmax="$vn"
done < <(git -C "$ROOT" for-each-ref --format='%(refname)' \
         "refs/tags/done/waves/${W}/" 2>/dev/null)
v=$((vmax + 1))
if [ "$v" -gt 1 ]; then
  printf '%s' "$REASON" | grep -Fq 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ:' \
    || die "v>1 требует строку РАЗРЕШИЛ-ВЛАДЕЛЕЦ: в причине"
fi
# A4: причина — из файла, --cleanup=verbatim сохраняет «# …» (в т.ч.
# «# РАЗРЕШИЛ-ВЛАДЕЛЕЦ:»). Причина пуста отклонена выше, ДО всех проверок;
# здесь причина из одних комментариев ЗАКОННА — НЕ БАРЬЕР: rev110 Б3.
REASON_FILE="$(mktemp)"
trap 'rm -f "$REASON_FILE"' EXIT
printf '%s\n' "$REASON" >"$REASON_FILE"
tag="done/waves/$W/$v"
if ! git -C "$ROOT" -c user.name=Implementer -c user.email=implementer@dev-harness.local \
     tag -F "$REASON_FILE" --cleanup=verbatim -a "$tag" "$HEAD_SHA" >/dev/null 2>&1; then
  die "тег $tag не создан"
fi
printf '%s\n' "v$v"
exit 0