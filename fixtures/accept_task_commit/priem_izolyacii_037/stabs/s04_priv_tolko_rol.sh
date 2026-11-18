#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ s04 «сверка проверяет только роль»: rol сверяется со строкой
# START, но ветка/предмет/изоляция/репозиторий/владелец копии/tip — нет;
# чужая копия проходит сверку, корень приёма выводится как ни в чём не
# бывало. Различающий прогон батареи: ц2 — сдача чужой копии (owner.json ≠
# держателю START) обязана получить именованный отказ ДО приёма, ветка не
# двинута.
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
[ "$s_rol" = "$AUT" ] || { printf 'ОТКАЗ: ROL_RASHODITSJA: роль ≠ START\n' >&2; exit 1; }
# ДЕФЕКТ СТАБА: ветка, предмет, изоляция, репозиторий, владелец копии и tip
# не сверяются.
s_wt="$(jq -r '.worktree // ""' <<<"$START")"
gd="$(git -C "$s_wt" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" || { printf 'ОТКАЗ: NOSITEL_NEDOSTUPEN\n' >&2; exit 1; }
case "$gd" in */.git) ROOT_PR="${gd%/.git}" ;; *) ROOT_PR="$gd" ;; esac
printf 'root=%s\n' "$ROOT_PR"
exit 0
