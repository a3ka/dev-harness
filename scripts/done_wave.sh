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

# Причина пуста — отказ ДО всех проверок (И-8).
[ -n "${REASON//[[:space:]]/}" ] || die "причина пуста"

# ── И-1 реестр: профильный project_paths_resolve (996), не корневой деко ──────
NEXT_ID_LIB=1 source "$SELF_DIR/next_id.sh" \
  || skip "библиотека next_id.sh недоступна (нет project_paths_resolve)"
command -v jq >/dev/null 2>&1 || skip "нет jq (требование project_paths_resolve)"

ROOT_ABS="$(cd "$ROOT" && pwd -P)" || die "корень не читается: $ROOT"
PPR_JSON="$(project_paths_resolve "$ROOT")" \
  || die "профиль проекта не разрешается: $ROOT"
REG_ABS="$(printf '%s' "$PPR_JSON" | jq -r '.registry')"
[ -n "$REG_ABS" ] || die "профиль проекта не объявил registry"
REG_REL="${REG_ABS#"$ROOT_ABS"/}"
[ "$REG_ABS" != "$REG_REL" ] || die "registry профиля вне корня: $REG_ABS"
export LIB_PLAN_REGISTRY="$REG_REL"

# ── И-1 членство: HEAD-блоб плана, канонический plan_parse ──────────────────
PLAN_TMP="$(mktemp)"
git -C "$ROOT" cat-file blob "HEAD:${REG_REL}/plan.tsv" >"$PLAN_TMP" 2>/dev/null \
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
CLOSED="$(git -C "$ROOT" cat-file -p "HEAD:${REG_REL}/closed-without-done.tsv" 2>/dev/null || true)"
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
MANIFEST="$(git -C "$ROOT" cat-file -p "HEAD:${REG_REL}/waves/${W}.tsv" 2>/dev/null)" \
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
  blob="$(git -C "$ROOT" cat-file -p "HEAD:$p" 2>/dev/null)" \
    || die "находка владельца отсутствует на HEAD: $p"
  st="$(printf '%s\n' "$blob" | sed -nE 's/^status:[[:space:]]*//p' | sed -n 1p)"
  st="$(printf '%s' "$st" | sed -E 's/[[:space:]]+$//')"
  [ "$st" = "done" ] \
    || die "находка владельца открыта: $p status=${st:-нет_строки_status}"
done

# ── И-7 otkat: обязательные поля плана отката ──────────────────────────────
oblob="$(git -C "$ROOT" cat-file -p "HEAD:$OTKAT_PATH" 2>/dev/null)" \
  || die "план отката отсутствует: $OTKAT_PATH"
for fld in "риск" "sha" "команда-отката" "команда-проверки"; do
  printf '%s\n' "$oblob" | grep -E "^${fld}:[[:space:]]*[^[:space:]]" >/dev/null \
    || die "план отката без поля: $fld"
done

# ── И-8 тег: v=max+1, клапан v>1; аннотированный тег КОММИТА HEAD ──────────
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
tag="done/waves/$W/$v"
if ! git -C "$ROOT" -c user.name=Fixture -c user.email=fixture@local \
     tag -a "$tag" -m "$REASON" >/dev/null 2>&1; then
  die "тег $tag не создан"
fi
printf '%s\n' "v$v"
exit 0