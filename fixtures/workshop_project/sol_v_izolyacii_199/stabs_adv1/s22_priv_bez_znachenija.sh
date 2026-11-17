#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ s22 «флаг без значения → rc 1 bash-шум» — модель-эталон
# привязки 199 с единственной заменой: rc 2-гард «флаг последним без
# значения» удалён, парсер возвращает ${2:?} (дефект субъекта по находке 3
# Adv199Impl: bash-диагностика «parameter null or not set», rc 1 вместо
# контрактного rc 2 «нет обязательного аргумента» ДО любых сверок).
# Различающий вход батареи: p14 (каждый обязательный флаг и --tip последним
# без значения) — честная привязка даёт rc 2 с причиной, стаб — rc 1.
# На полных вызовах стаб побайтово честен — привязка КОДОМ движка
# (stab_kletki), не прозой контракта (Н-39).
#
# Использование:
#   privjazka_sdachi.sh --sostojanie D --repo R --subject NNN \
#     --source <копия> --branch wip/NNN/<автор> --author <роль> [--tip <40hex>]
# rc 0 — факты связаны, stdout ровно одна строка root=<корень основного репо>;
# rc 1 — именованный отказ; rc 2 — нечем проверить.
set -u
SOST=''; REPO=''; SUBJ=''; SRC=''; BR=''; AUT=''; TIP=''
while [ "$#" -gt 0 ]; do
  # ДЕФЕКТ СТАБА s22: гард значения флага удалён — ${2:?} при флаге
  # последним аргументом даёт bash-диагностику и rc 1 (не rc 2).
  case "$1" in
    --sostojanie) SOST="${2:?}"; shift ;;
    --repo)       REPO="${2:?}"; shift ;;
    --subject)    SUBJ="${2:?}"; shift ;;
    --source)     SRC="${2:?}"; shift ;;
    --branch)     BR="${2:?}"; shift ;;
    --author)     AUT="${2:?}"; shift ;;
    --tip)        TIP="${2:?}"; shift ;;
    *) printf 'использование: --sostojanie D --repo R --subject NNN --source M --branch B --author A [--tip T]\n' >&2; exit 2 ;;
  esac
  shift
done
[ -n "$SOST" ] && [ -n "$REPO" ] && [ -n "$SUBJ" ] && [ -n "$SRC" ] && [ -n "$BR" ] && [ -n "$AUT" ] || {
  printf 'использование: --sostojanie D --repo R --subject NNN --source M --branch B --author A [--tip T]\n' >&2; exit 2; }
command -v jq  >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет jq\n'  >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
LEDGER="$SOST/uchet.jsonl"
[ -r "$LEDGER" ] || { printf 'NOT_IMPLEMENTED: учёта нет: %s\n' "$LEDGER" >&2; exit 2; }
REPO="$(cd "$REPO" 2>/dev/null && pwd -P)" || { printf 'NOT_IMPLEMENTED: репо нет: %s\n' "$REPO" >&2; exit 2; }
git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: не репозиторий: %s\n' "$REPO" >&2; exit 2; }
otp() { printf 'ОТКАЗ: %s: %s\n' "$1" "$2" >&2; exit 1; }

repo_id_iz() {
  local url id
  url="$(git -C "$1" remote get-url origin 2>/dev/null)" || url=''
  id="${url##*/}"; id="${id%.git}"
  [ -n "$id" ] || id="$(basename "$1")"
  printf '%s' "$id"
}

# 1) последний START рабочего предмета (repoId НЕ фильтруется — расхождение
#    репозитория получает собственное имя REPO_RASHODITSJA, а не «START нет»).
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

# 2) роль сдающего == роль START.
[ "$s_rol" = "$AUT" ] || otp ROL_RASHODITSJA "роль сдающего $AUT ≠ роли START $s_rol"
# 3) ветка сдачи == ветка START.
[ "$s_br" = "$BR" ] || otp VETKA_RASHODITSJA "ветка сдачи $BR ≠ ветке START $s_br"
# 4) номер ветки == предмет (грамматика wip/<NNN>/<автор>, литерально).
case "$BR" in
  wip/"$SUBJ"/*) : ;;
  *) otp SUBEKT_VETKI "ветка $BR вне грамматики wip/$SUBJ/<автор>" ;;
esac
# 5) спавн был изолированным (факт START, записан дверью из события).
[ "$s_iso" = 'true' ] || otp NE_IZOLIROVAN "START предмета $SUBJ без isolated:true — приём из копии не связан"
# 6) репозиторий реестра == repoId START.
RID="$(repo_id_iz "$REPO")"
[ "$RID" = "$s_repo" ] || otp REPO_RASHODITSJA "репо сдающего $RID ≠ repoId START $s_repo"
# 7) источник — git-репозиторий.
[ -d "$SRC" ] || otp NE_REPO "источника нет: $SRC"
git -C "$SRC" rev-parse --git-dir >/dev/null 2>&1 || otp NE_REPO "источник не репозиторий: $SRC"
# 8) копия принадлежит держателю: owner.json рядом, id == holder START
#    (та же корреляция, что М1 п.5 у path-guard; живой артефакт харнеса).
OJ="$(dirname "$SRC")/.omp-isolation-owner.json"
[ -r "$OJ" ] || otp KOPIJA_CHUZHAYA "нет .omp-isolation-owner.json рядом с копией: $(dirname "$SRC")"
jq -e '(.id | type) == "string"' "$OJ" >/dev/null 2>&1 || otp KOPIJA_CHUZHAYA "owner.json не разбирается: $OJ"
oid="$(jq -r '.id' "$OJ")"
[ "$oid" = "$s_holder" ] || otp KOPIJA_CHUZHAYA "копия принадлежит $oid, держатель START $s_holder"
# 9) tip источника == заявленному (сверка доклада с диском).
if [ -n "$TIP" ]; then
  h="$(git -C "$SRC" rev-parse HEAD 2>/dev/null)" || otp NE_REPO "HEAD источника не читается: $SRC"
  [ "$h" = "$TIP" ] || otp TIP_RASHODITSJA "HEAD источника $h ≠ заявленному tip $TIP"
fi
# 10) корень приёма выводится из факта START (носитель → общий git-каталог),
#     вызывающий не выбирает --root свободным текстом.
[ -n "$s_wt" ] && [ -d "$s_wt" ] || otp NOSITEL_NEDOSTUPEN "worktree START не читается: $s_wt"
gd="$(git -C "$s_wt" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" \
  || otp NOSITEL_NEDOSTUPEN "git-common-dir носителя не читается: $s_wt"
case "$gd" in
  */.git) ROOT_PR="${gd%/.git}" ;;
  *) ROOT_PR="$gd" ;;
esac
[ -d "$ROOT_PR" ] || otp NOSITEL_NEDOSTUPEN "корень из носителя не каталог: $ROOT_PR"
printf 'root=%s\n' "$ROOT_PR"
exit 0
