#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ s12 «привязка сдачи без привязки репозитория»: repoId START не
# сверяется с --repo (корень приёма выбирается вызывающим свободно).
# Различающий вход батареи: p7 — репозиторий с чужим repoId; стаб пропускает.
set -u
SOST=''; REPO=''; SUBJ=''; SRC=''; BR=''; AUT=''; TIP=''
while [ "$#" -gt 0 ]; do
  case "$1" in
    --sostojanie) SOST="${2:?}"; shift ;;
    --repo)       REPO="${2:?}"; shift ;;
    --subject)    SUBJ="${2:?}"; shift ;;
    --source)     SRC="${2:?}"; shift ;;
    --branch)     BR="${2:?}"; shift ;;
    --author)     AUT="${2:?}"; shift ;;
    --tip)        TIP="${2:?}"; shift ;;
    *) printf 'использование\n' >&2; exit 2 ;;
  esac
  shift
done
command -v jq >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет jq\n' >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
LEDGER="$SOST/uchet.jsonl"
[ -r "$LEDGER" ] || { printf 'NOT_IMPLEMENTED: учёта нет\n' >&2; exit 2; }
START="$(jq -rs --arg n "$SUBJ" '[ .[] | select(.t == "START" and .subjectId == $n and .klass == "rabochij") ] | last // empty' "$LEDGER" 2>/dev/null)"
[ -n "$START" ] || { printf 'ОТКАЗ: SDACHA_NET_START: строки START нет\n' >&2; exit 1; }
s_rol="$(jq -r '.rol // ""' <<<"$START")"
s_br="$(jq -r '.branch // ""' <<<"$START")"
s_iso="$(jq -r '.isolated // false' <<<"$START")"
s_wt="$(jq -r '.worktree // ""' <<<"$START")"
s_holder="$(jq -r '.holder // ""' <<<"$START")"
[ "$s_rol" = "$AUT" ] || { printf 'ОТКАЗ: ROL_RASHODITSJA: роль ≠ START\n' >&2; exit 1; }
[ "$s_br" = "$BR" ] || { printf 'ОТКАЗ: VETKA_RASHODITSJA: ветка ≠ START\n' >&2; exit 1; }
case "$BR" in wip/"$SUBJ"/*) : ;; *) printf 'ОТКАЗ: SUBEKT_VETKI: ветка вне грамматики\n' >&2; exit 1 ;; esac
[ "$s_iso" = 'true' ] || { printf 'ОТКАЗ: NE_IZOLIROVAN: START без isolated:true\n' >&2; exit 1; }
# ДЕФЕКТ СТАБА: repoId START не сверяется с --repo.
[ -d "$SRC" ] || { printf 'ОТКАЗ: NE_REPO: источника нет\n' >&2; exit 1; }
git -C "$SRC" rev-parse --git-dir >/dev/null 2>&1 || { printf 'ОТКАЗ: NE_REPO: не репозиторий\n' >&2; exit 1; }
OJ="$(dirname "$SRC")/.omp-isolation-owner.json"
[ -r "$OJ" ] || { printf 'ОТКАЗ: KOPIJA_CHUZHAYA: нет owner.json\n' >&2; exit 1; }
oid="$(jq -r '.id // ""' "$OJ" 2>/dev/null)"
[ "$oid" = "$s_holder" ] || { printf 'ОТКАЗ: KOPIJA_CHUZHAYA: копия чужая\n' >&2; exit 1; }
if [ -n "$TIP" ]; then
  h="$(git -C "$SRC" rev-parse HEAD 2>/dev/null)" || { printf 'ОТКАЗ: NE_REPO: HEAD не читается\n' >&2; exit 1; }
  [ "$h" = "$TIP" ] || { printf 'ОТКАЗ: TIP_RASHODITSJA: HEAD ≠ tip\n' >&2; exit 1; }
fi
gd="$(git -C "$s_wt" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" || { printf 'ОТКАЗ: NOSITEL_NEDOSTUPEN\n' >&2; exit 1; }
case "$gd" in */.git) ROOT_PR="${gd%/.git}" ;; *) ROOT_PR="$gd" ;; esac
printf 'root=%s\n' "$ROOT_PR"
exit 0
