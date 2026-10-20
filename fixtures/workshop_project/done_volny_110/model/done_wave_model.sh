#!/usr/bin/env bash
# Эталон двери done-волны (уровень Б) — fixtures/workshop_project/done_volny_110/model/.
# Контракт 110, круг 2 (закрытие обходов Б1–БД10 вердикта contracts-110-krug1-fail).
# Форма API совпадает с будущим scripts/done_wave.sh:
#   bash done_wave_model.sh <корень> <пара-W> "<причина>"
#   rc 0 — тег done/waves/<W>/<v> поставлен, stdout v<N>;
#   rc 1 — именованный отказ stderr «done_wave: …», refs не мутированы;
#   rc 2 — NOT_IMPLEMENTED.
# Чтение плана/закрытий/манифеста/находок/отката — HEAD-блобы (истина в
# закоммиченном). Грамматика манифеста и все пороги — литералы строк.
# Круг 2: членство и грамматика плана — ТОЛЬКО канонический plan_parse из
# scripts/lib_plan.sh (второго парсера плана нет — Б8); реестр — профильный,
# через project_paths_resolve/LIB_PLAN_REGISTRY (996, Б9); манифест обязан
# нести ≥1 численный NFR (Б1); статус review — trim краёв, внутренние пробелы
# НЕ склеиваются (Б5); e2e исполняется заново каждым вызовом, кеша нет (Б7);
# тег — аннотированный, на коммит HEAD, причина — в аннотации (Б6).
# Круг 2 реализации (Adv110 A1–A4, Rev110 Б1): корень обязан быть корнем репозитория
# (A3); принимаемый HEAD фиксируется ДО всех проверок и команд, источники и тег —
# от него (Б1/Rev110); профиль проекта существует на HEAD и совпадает с рабочим
# деревом (A2); грязное отслеживаемое дерево — именованный отказ до тега (A1/A1b);
# аннотация тега — без cleanup-потерь строк «#» (A4: --cleanup=verbatim).
set -uo pipefail
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

ROOT="${1:-}"; W="${2:-}"; REASON="${3-}"
[ -n "$ROOT" ] && [ -n "$W" ] || { printf 'done_wave: использование: <корень> <пара> "<причина>"\n' >&2; exit 2; }
[ -d "$ROOT/.git" ] || git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: корень не git-репозиторий: %s\n' "$ROOT" >&2; exit 2; }

die() { printf 'done_wave: %s\n' "$*" >&2; exit 1; }

# Причина пуста — отказ ДО всех проверок (И-8)
[ -n "${REASON//[[:space:]]/}" ] || die "причина пуста"

# ── И-1 реестр: профильный project_paths_resolve (996), не корневой деко (Б9) ──
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# Каталог инструментов: от себя вверх (эталон в дереве, 4 уровня); для
# мутант-копий батареи (вне дерева) — env WAVE110_TOOLS от probe.py; иначе отказ.
TOOLS_DIR="$(cd "$HERE/../../../.." 2>/dev/null && pwd -P)"
[ -f "$TOOLS_DIR/scripts/lib_plan.sh" ] || TOOLS_DIR="${WAVE110_TOOLS:-}"
[ -n "$TOOLS_DIR" ] && [ -f "$TOOLS_DIR/scripts/lib_plan.sh" ] \
  || die "каталог инструментов харнесса не найден (scripts/lib_plan.sh)"
NEXT_ID_LIB=1 source "$TOOLS_DIR/scripts/next_id.sh" \
  || die "библиотека next_id.sh недоступна (нет project_paths_resolve)"
command -v jq >/dev/null 2>&1 || die "нет jq (требование project_paths_resolve)"
ROOT_ABS="$(cd "$ROOT" && pwd -P)" || die "корень не читается: $ROOT"
# A3: корень обязан быть корнем репозитория — из подкаталога cat-file-пути
# разрешаются от верхушки репо, и дверь судит чужой реестр.
TOP_ABS="$(git -C "$ROOT" rev-parse --show-toplevel 2>/dev/null)" \
  || die "корень не git-репозиторий: $ROOT"
[ "$(cd "$TOP_ABS" 2>/dev/null && pwd -P)" = "$ROOT_ABS" ] \
  || die "корень не корень репозитория: $ROOT_ABS"
# Б1: принимаемый HEAD фиксируется ДО всех проверок и команд; все HEAD-чтения
# и тег — от этого sha, а не от движущегося HEAD.
HEAD_SHA="$(git -C "$ROOT" rev-parse "HEAD^{commit}")" \
  || die "HEAD не разрешается: $ROOT"
# A2: профиль проекта обязан существовать на HEAD и совпадать с рабочим
# деревом — удалённый/расходящийся/неотслеживаемый профиль подменяет
# реестр корневым деко (резолвер читает рабочее дерево).
for pf in harness.project.json project-layer.json; do
  if [ -f "$ROOT/$pf" ]; then
    git -C "$ROOT" cat-file -e "$HEAD_SHA:$pf" 2>/dev/null \
      || die "профиль проекта не на HEAD: $pf"
    git -C "$ROOT" diff --quiet "$HEAD_SHA" -- "$pf" 2>/dev/null \
      || die "профиль проекта расходится с HEAD: $pf"
  else
    git -C "$ROOT" cat-file -e "$HEAD_SHA:$pf" 2>/dev/null \
      && die "профиль проекта расходится с HEAD: $pf"
  fi
done
PPR_JSON="$(project_paths_resolve "$ROOT")" \
  || die "профиль проекта не разрешается: $ROOT"
REG_ABS="$(printf '%s' "$PPR_JSON" | jq -r '.registry')"
[ -n "$REG_ABS" ] || die "профиль проекта не объявил registry"
REG_REL="${REG_ABS#"$ROOT_ABS"/}"
[ "$REG_ABS" != "$REG_REL" ] || die "registry профиля вне корня: $REG_ABS"
export LIB_PLAN_REGISTRY="$REG_REL"   # MUT-REG (Б9: корневой деко вместо профиля)

# ── И-1 членство: строки плана пары W из HEAD-блоба, канонический plan_parse ──
PLAN_TMP="$(mktemp)"
git -C "$ROOT" cat-file blob "${HEAD_SHA}:${REG_REL}/plan.tsv" >"$PLAN_TMP" 2>/dev/null \
  || { rm -f "$PLAN_TMP"; die "план недоступен на HEAD: ${REG_REL}/plan.tsv"; }
source "$TOOLS_DIR/scripts/lib_plan.sh"
plan_parse "$PLAN_TMP" || { rm -f "$PLAN_TMP"; die "$P84_PLAN_ERR"; }   # MUT-PARSE (Б8: второй парсер)
rm -f "$PLAN_TMP"
ROWS=""
wave_n=0
for i in "${!P84_ID[@]}"; do
  [ "${P84_PAIR[$i]}" = "$W" ] || continue
  ROWS+="${P84_ID[$i]}"$'\n'
  wave_n=$((wave_n + 1))
done
[ "$wave_n" -gt 0 ] || die "волна $W пуста: нет строк плана с этой парой"   # MUT-EMPTY

# ── И-2 терминальность КАЖДОЙ строки (закрытия — HEAD-блоб реестра) ───────────
CLOSED="$(git -C "$ROOT" cat-file -p "${HEAD_SHA}:${REG_REL}/closed-without-done.tsv" 2>/dev/null || true)"
while IFS= read -r id; do
  [ -n "$id" ] || continue
  if [ -n "${id//[0-9]/}" ]; then
    # символьный id: терминален только закрытием владельца
    printf '%s\n' "$CLOSED" | awk -F'\t' -v x="$id" '$1==x {f=1} END {exit !f}' \
      || die "строка волны не терминальна: $id не начат (символьная строка без закрытия владельца)"   # MUT-SYM
  else
    git -C "$ROOT" for-each-ref --format='%(refname)' "refs/tags/done/contracts/${id}/" 2>/dev/null | grep -q . \
      || die "строка волны не терминальна: $id (нет done-тега)"   # MUT-NUM
  fi
done <<< "$ROWS"

# ── И-3 манифест <реестр>/waves/<W>.tsv: закрытый алфавит, nfr ≥ 1 (Б1) ────────
MANIFEST="$(git -C "$ROOT" cat-file -p "${HEAD_SHA}:${REG_REL}/waves/${W}.tsv" 2>/dev/null)" \
  || die "манифест волны отсутствует: ${REG_REL}/waves/${W}.tsv"   # MUT-NOMAN
NFR_ROWS=""; E2E_CMD=""; OTKAT_PATH=""; REVIEW_PATHS=""
e2e_n=0; otkat_n=0; nfr_n=0; row_n=0
while IFS= read -r line; do
  case "$line" in ''|'#'*) continue ;; esac
  row_n=$((row_n + 1))
  IFS=$'\t' read -r kind f2 f3 f4 f5 f6 <<< "$line"
  case "$kind" in
    nfr)
      [ -n "$f2" ] && [ -n "$f3" ] && [ -n "$f4" ] \
        || die "строка манифеста неполна: nfr без имени/команды/регекса"
      case "$f5" in le|ge) ;; *) die "NFR $f2: оператор вне алфавита: $f5" ;; esac
      case "$f6" in ''|*[!0-9.]*) die "NFR $f2: порог не число: $f6" ;; esac
      NFR_ROWS+="$line"$'\n'
      nfr_n=$((nfr_n + 1))
      ;;
    e2e)
      e2e_n=$((e2e_n + 1))
      [ "$e2e_n" -le 1 ] || die "e2e строка не одна"   # MUT-DUPE2E
      [ -n "$f2" ] || die "строка манифеста неполна: e2e без команды"
      E2E_CMD="$f2"
      ;;
    review)
      [ -n "$f2" ] || die "строка манифеста неполна: review без пути"
      REVIEW_PATHS+="$f2"$'\n'
      ;;
    otkat)
      otkat_n=$((otkat_n + 1))
      [ "$otkat_n" -le 1 ] || die "otkat строка не одна"
      [ -n "$f2" ] || die "строка манифеста неполна: otkat без пути"
      OTKAT_PATH="$f2"
      ;;
    *) die "строка манифеста вне алфавита: $kind"   # MUT-UNKNOWN
      ;;
  esac
done <<< "$MANIFEST"
[ "$row_n" -gt 0 ] || die "манифест волны пуст"
[ "$nfr_n" -ge 1 ] || die "манифест волны не объявил численных NFR: нет nfr строк"   # MUT-NFR0 (Б1)
[ -n "$E2E_CMD" ] || die "манифест волны не объявил сквозной запуск: нет e2e строки"   # MUT-NOE2E
[ -n "$OTKAT_PATH" ] || die "манифест волны не объявил план отката: нет otkat строки"

# ── И-4 NFR: КАЖДАЯ строка, число из вывода, порог — литерал строки ───────────
while IFS= read -r nfr; do
  [ -n "$nfr" ] || continue
  IFS=$'\t' read -r kind name cmd regex op porog <<< "$nfr"
  out_rc=0
  out="$( cd "$ROOT" && timeout 60 bash -c "$cmd" 2>&1 )" || out_rc=$?
  [ "$out_rc" -eq 0 ] || die "NFR $name: команда rc=$out_rc"   # MUT-CMDRC
  num=""
  while IFS= read -r l; do
    if [[ "$l" =~ $regex ]] && [ -n "${BASH_REMATCH[1]:-}" ]; then num="${BASH_REMATCH[1]}"; break; fi
  done <<< "$out"
  [ -n "$num" ] || die "NFR $name: метрика не найдена"   # MUT-NOMETRIC
  case "$num" in ''|*[!0-9.]*) die "NFR $name: метрика не число: $num" ;; esac
  ok="$(awk -v a="$num" -v b="$porog" -v o="$op" 'BEGIN { print (o=="le" ? (a<=b) : (a>=b)) }')"   # MUT-INVERT
  [ "$ok" = "1" ] || die "NFR $name: $num не $op $porog"
done <<< "$NFR_ROWS"

# ── И-5 e2e: один сквозной запуск, СВЕЖИЙ прогон каждого вызова (Б7) ──────────
e2e_rc=0
( cd "$ROOT" && timeout 600 bash -c "$E2E_CMD" ) >/dev/null 2>&1 || e2e_rc=$?   # MUT-CACHE (Б7)
[ "$e2e_rc" -eq 0 ] || die "сквозной запуск волны красный: rc=$e2e_rc"   # MUT-E2E

# ── И-6 review: КАЖДЫЙ файл, статус литерально done, trim только краёв (Б5) ───
while IFS= read -r p; do
  [ -n "$p" ] || continue
  blob="$(git -C "$ROOT" cat-file -p "${HEAD_SHA}:$p" 2>/dev/null)" \
    || die "находка владельца отсутствует на HEAD: $p"   # MUT-NOFILE
  st="$(printf '%s\n' "$blob" | sed -nE 's/^status:[[:space:]]*//p' | sed -n 1p)"
  st="$(printf '%s' "$st" | sed -E 's/[[:space:]]+$//')"   # MUT-SQUASH (Б5: склейка внутренних пробелов)
  [ "$st" = "done" ] || die "находка владельца открыта: $p status=${st:-нет_строки_status}"   # MUT-REVIEW
done <<< "$REVIEW_PATHS"

# ── И-7 otkat: обязательные поля плана отката ────────────────────────────────
oblob="$(git -C "$ROOT" cat-file -p "${HEAD_SHA}:$OTKAT_PATH" 2>/dev/null)" \
  || die "план отката отсутствует: $OTKAT_PATH"   # mut-otkat-file
for fld in риск sha команда-отката команда-проверки; do
  printf '%s\n' "$oblob" | grep -E "^${fld}:[[:space:]]*[^[:space:]]" >/dev/null \
    || die "план отката без поля: $fld"   # mut-otkat-field
done

# A1/A1b: грязное ОТСЛЕЖИВАЕМОЕ дерево не доказывает принятый HEAD — исполняемый
# код e2e/NFR берётся из рабочего дерева; отказ ПОСЛЕ всех источников, но ДО тега.
git -C "$ROOT" diff --quiet "$HEAD_SHA" 2>/dev/null \
  || die "рабочее дерево расходится с HEAD: $HEAD_SHA"

# ── И-8 тег: v=max+1, клапан v>1; аннотированный тег КОММИТА HEAD (Б6) ────────
vmax=0
while IFS= read -r t; do
  [ -n "$t" ] || continue
  vn="${t##*done/waves/${W}/}"
  case "$vn" in ''|*[!0-9]*) continue ;; esac
  [ "$vn" -gt "$vmax" ] && vmax="$vn"
done < <(git -C "$ROOT" for-each-ref --format='%(refname)' "refs/tags/done/waves/${W}/" 2>/dev/null)
v=$((vmax + 1))   # MUT-V1
if [ "$v" -gt 1 ]; then
  printf '%s' "$REASON" | grep -Fq 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ:' \
    || die "v>1 требует строку РАЗРЕШИЛ-ВЛАДЕЛЕЦ: в причине"
fi
tag="done/waves/$W/$v"
if ! git -C "$ROOT" -c user.name=Fixture -c user.email=fixture@local \
     tag --cleanup=verbatim -a "$tag" -m "$REASON" "$HEAD_SHA" >/dev/null 2>&1; then   # MUT-TREE (Б6: lightweight на tree)
  die "тег $tag не создан"
fi
printf '%s\n' "v$v"
exit 0
