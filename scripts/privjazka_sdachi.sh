#!/usr/bin/env bash
# ПРИВЯЗКА СДАЧИ (контракт 199 «Sol в изоляции», инвариант 2) — сверка
# фактов сдачи изолированного рабочего с ПОСЛЕДНИМ РАБОЧИМ фактом START
# двери замка (scripts/zamok_predmeta.sh) ДО штатного приёма
# (scripts/accept_task_commit.sh). Копи приёма и корень приёма выводятся из
# ФАКТА, а не выбираются свободным текстом доклада ребёнка.
#
# ЗАЧЕМ. До предмета 199 приём из копии не был связан с фактом назначения:
# accept_task_commit.sh судит identity каждого коммита и линейность диапазона,
# но источник/ветка/роль/предмет/корень — свободный текст доклада ребёнка, а
# --root выбирает вызывающий. Проба границ разбора показала: сдача с
# same-role источника чужого предмета принималась в чужую ветку. Здесь сдача
# привязывается к факту START рабочего: роль, ветка, предмет, репозиторий,
# владелец копии и tip сверяются с записью учёта, а корень приёма ВЫВОДИТСЯ
# из факта (носитель → общий git-каталог), а не выбирается вызывающим.
#
# КОНТРАКТ CLI:
#   scripts/privjazka_sdachi.sh --sostojanie D --repo R --subject NNN \
#     --source <копия> --branch wip/NNN/<автор> --author <роль> [--tip <40hex>]
#
# Коды возврата:
#   0 — факты связаны; stdout РОВНО одна строка «root=<корень основного
#       репозитория>» (корень выведен из факта START, не из --repo);
#   1 — именованный отказ (stderr «ОТКАЗ: <ИМЯ>: <детали>»);
#   2 — нечем проверить (нет jq/git, нет обязательного аргумента, нет учёта,
#       --repo не репозиторий) — ДО любых сверок.
#
# ПРЕДУСЛОВИЯ (rc 2 до любых сверок): обязательные аргументы, читаемость
# учёта D/uchet.jsonl, git-репозиторийность --repo. Флаг, переданный
# ПОСЛЕДНИМ аргументом без значения (любой из обязательных и --tip), —
# именованный отказ rc 2 «нет значения: <флаг>» (не bash-диагностика).
#
# ОТКАЗЫ rc 1 (именованные; первая причина):
#   SDACHA_NET_START   — в учёте нет строки START рабочего по предмету;
#   ROL_RASHODITSJA    — роль сдающего ≠ роли START;
#   VETKA_RASHODITSJA  — ветка сдачи ≠ ветке START;
#   SUBEKT_VETKI       — ветка вне грамматики wip/<NNN>/<автор>;
#   NE_IZOLIROVAN      — START без факта isolated:true (приём из копии не
#                        связан с изолированным спавном);
#   REPO_RASHODITSJA   — repoId реестра ≠ repoId факта START;
#   NE_REPO            — источник не git-репозиторий / tip не читается;
#   KOPIJA_CHUZHAYA    — копия принадлежит не держателю факта START (нет
#                        .omp-isolation-owner.json рядом или чужой id);
#   TIP_RASHODITSJA    — HEAD источника ≠ заявленному tip;
#   NOSITEL_NEDOSTUPEN — носитель факта START не читается.
#
# ПОРЯДОК ДЕЙСТВИЙ. Сначала — последний РАБОЧИЙ START предмета (klass=rabochij)
# из учёта: строка START судей того же предмета, лежащая в учёте ПОЗЖЕ
# рабочей (штатный порядок: судья приходит по предмету после рабочего), сверку
# не смещает. repoId при выборке НЕ фильтруется: расхождение репозитория
# получает собственное имя REPO_RASHODITSJA, а не «START нет».
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

usage() {
  cat >&2 <<USAGE
использование:
  $0 --sostojanie D --repo R --subject NNN --source M --branch B --author A [--tip T]
rc 0 — факты связаны (stdout: root=<корень>); rc 1 — именованный отказ;
rc 2 — нечем проверить.
USAGE
  exit 2
}

# [Adv199-impl-1, находка 3] обязательный (и факультативный --tip) флаг
# ПОСЛЕДНИМ аргументом без значения — rc 2 с именем флага ДО любых сверок.
# bash-диагностика «parameter null or not set» (rc 1) недопустима: это не
# именованный отказ и не «нечем проверить».
flag_no_value() {
  printf 'использование: --sostojanie D --repo R --subject NNN --source M --branch B --author A [--tip T] (нет значения: %s)\n' "$1" >&2
  exit 2
}

otp()  { printf 'ОТКАЗ: %s: %s\n' "$1" "$2" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$1" >&2; exit 2; }

command -v jq >/dev/null 2>&1 || skip 'нет jq'
command -v git >/dev/null 2>&1 || skip 'нет git'

SOST=''; REPO=''; SUBJ=''; SRC=''; BR=''; AUT=''; TIP=''
while [ "$#" -gt 0 ]; do
  # [Adv199-impl-1, находка 3] значение флага обязательно: флаг ПОСЛЕДНИМ
  # аргументом без значения — rc 2 с именем флага (flag_no_value) ДО любых
  # сверок; ${2:?} здесь недопустим (bash-шум «parameter null or not set»).
  case "$1" in
    --sostojanie|--repo|--subject|--source|--branch|--author|--tip)
      [ "$#" -ge 2 ] || flag_no_value "$1" ;;
  esac
  case "$1" in
    --sostojanie) SOST="${2-}"; shift ;;
    --repo)       REPO="${2-}"; shift ;;
    --subject)    SUBJ="${2-}"; shift ;;
    --source)     SRC="${2-}"; shift ;;
    --branch)     BR="${2-}"; shift ;;
    --author)     AUT="${2-}"; shift ;;
    --tip)        TIP="${2-}"; shift ;;
    -h|--help)    usage ;;
    *) usage ;;
  esac
  shift
done
[ -n "$SOST" ] && [ -n "$REPO" ] && [ -n "$SUBJ" ] && [ -n "$SRC" ] \
  && [ -n "$BR" ] && [ -n "$AUT" ] || usage
LEDGER="$SOST/uchet.jsonl"
[ -r "$LEDGER" ] || skip "учёта нет: $LEDGER"
REPO="$(cd "$REPO" 2>/dev/null && pwd -P)" || skip "репо нет: $REPO"
git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1 || skip "не репозиторий: $REPO"

# repoId — тот же, что у двери замка: origin → без .git → basename (fallback).
repo_id_iz() {
  local url id
  url="$(git -C "$1" remote get-url origin 2>/dev/null)" || url=''
  id="${url##*/}"; id="${id%.git}"
  [ -n "$id" ] || id="$(basename "$1")"
  printf '%s' "$id"
}

# 1) последний START РАБОЧЕГО предмета (klass=rabochij) — источник всех
#    сверок; строка START судьи, лежащая в учёте позже рабочей, её не смещает.
START="$(jq -rs --arg n "$SUBJ" '
  [ .[] | select(.t == "START" and .subjectId == $n and .klass == "rabochij") ]
  | last // empty' "$LEDGER" 2>/dev/null)"
[ -n "$START" ] || otp SDACHA_NET_START "предмет $SUBJ: строки START рабочего в учёте нет"

s_rol="$(jq -r '.rol // ""' <<<"$START")"
s_br="$(jq -r '.branch // ""' <<<"$START")"
s_iso="$(jq -r '.isolated // false' <<<"$START")"
s_wt="$(jq -r '.worktree // ""' <<<"$START")"
s_holder="$(jq -r '.holder // ""' <<<"$START")"
s_repo="$(jq -r '.repoId // ""' <<<"$START")"

# 2) роль сдающего == роли START.
[ "$s_rol" = "$AUT" ] || otp ROL_RASHODITSJA "роль сдающего $AUT ≠ роли START $s_rol"
# 3) ветка сдачи == ветке START.
[ "$s_br" = "$BR" ] || otp VETKA_RASHODITSJA "ветка сдачи $BR ≠ ветке START $s_br"
# 4) номер ветки == предмет (грамматика wip/<NNN>/<автор>).
case "$BR" in
  wip/"$SUBJ"/*) : ;;
  *) otp SUBEKT_VETKI "ветка $BR вне грамматики wip/$SUBJ/<автор>" ;;
esac
# 5) спавн был изолированным — факт START, записанный дверью из поля события.
[ "$s_iso" = 'true' ] \
  || otp NE_IZOLIROVAN "START предмета $SUBJ без isolated:true — приём из копии не связан"
# 6) репозиторий реестра == repoId факта START.
RID="$(repo_id_iz "$REPO")"
[ "$RID" = "$s_repo" ] || otp REPO_RASHODITSJA "репо сдающего $RID ≠ repoId START $s_repo"
# 7) источник — git-репозиторий.
[ -d "$SRC" ] || otp NE_REPO "источника нет: $SRC"
git -C "$SRC" rev-parse --git-dir >/dev/null 2>&1 || otp NE_REPO "источник не репозиторий: $SRC"
# 8) копия принадлежит держателю факта START: .omp-isolation-owner.json рядом
#    (та же корреляция, что М1 п.5 у path-guard; живой артефакт харнеса).
OJ="$(dirname "$SRC")/.omp-isolation-owner.json"
[ -r "$OJ" ] || otp KOPIJA_CHUZHAYA "нет .omp-isolation-owner.json рядом с копией: $(dirname "$SRC")"
jq -e '(.id | type) == "string"' "$OJ" >/dev/null 2>&1 \
  || otp KOPIJA_CHUZHAYA "owner.json не разбирается: $OJ"
oid="$(jq -r '.id' "$OJ")"
[ "$oid" = "$s_holder" ] || otp KOPIJA_CHUZHAYA "копия принадлежит $oid, держатель START $s_holder"
# 9) tip источника == заявленному (сверка доклада с диском).
if [ -n "$TIP" ]; then
  h="$(git -C "$SRC" rev-parse HEAD 2>/dev/null)" || otp NE_REPO "HEAD источника не читается: $SRC"
  [ "$h" = "$TIP" ] || otp TIP_RASHODITSJA "HEAD источника $h ≠ заявленному tip $TIP"
fi
# 10) корень приёма ВЫВОДИТСЯ из факта START (носитель → общий git-каталог):
#     вызывающий не выбирает корень свободным текстом — даже когда --repo
#     указывает на другую копию того же origin.
[ -n "$s_wt" ] && [ -d "$s_wt" ] || otp NOSITEL_NEDOSTUPEN "worktree START не читается: $s_wt"
gd="$(git -C "$s_wt" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" \
  || otp NOSITEL_NEDOSTUPEN "git-common-dir носителя не читается: $s_wt"
case "$gd" in
  */.git) ROOT_PR="${gd%/.git}" ;;
  *)      ROOT_PR="$gd" ;;
esac
[ -d "$ROOT_PR" ] || otp NOSITEL_NEDOSTUPEN "корень из носителя не каталог: $ROOT_PR"
printf 'root=%s\n' "$ROOT_PR"
exit 0
