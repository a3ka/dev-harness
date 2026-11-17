#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ s07 «привязка сдачи проверяет только tip»: заявленный sha
# сверяется с HEAD источника, роль/ветка/репозиторий/владелец копи — нет.
# Различающие входы батареи: p2/p4 — стаб пропускает чужую ветку и чужую копию.
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
[ -n "$TIP" ] || { printf 'NOT_IMPLEMENTED: --tip обязателен\n' >&2; exit 2; }
h="$(git -C "$SRC" rev-parse HEAD 2>/dev/null)" || { printf 'ОТКАЗ: NE_REPO: HEAD не читается\n' >&2; exit 1; }
[ "$h" = "$TIP" ] || { printf 'ОТКАЗ: TIP_RASHODITSJA: HEAD ≠ tip\n' >&2; exit 1; }
# ДЕФЕКТ СТАБА: роль, ветка, репозиторий и владелец копи не сверяются.
s_wt="$(jq -r '.worktree // ""' <<<"$START")"
gd="$(git -C "$s_wt" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" || { printf 'ОТКАЗ: NOSITEL_NEDOSTUPEN\n' >&2; exit 1; }
case "$gd" in */.git) ROOT_PR="${gd%/.git}" ;; *) ROOT_PR="$gd" ;; esac
printf 'root=%s\n' "$ROOT_PR"
exit 0
