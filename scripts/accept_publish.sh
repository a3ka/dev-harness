#!/usr/bin/env bash
# Честная модель двери приёмки+публикации (контракт 094) — носитель ГРАММАТИКИ
# субъекта scripts/accept_publish.sh: субъект обязан принимать этот CLI и эти
# коды/фразы дословно. Модель — не продукт: живёт в семье батареи, используется
# режимом --model раннера и стаб-паком battery_stubs.sh (порчи строятся ИЗ этого
# файла; маркеры # t94-mN отмечают единственные строки-носители инвариантов —
# НЕ удалять и НЕ переименовывать без синхронной правки стаб-пака).
#
# Глаголы (TAB-поля id = каноническая строка объекта):
#   object  --repo R --task T --target B --base SHA --candidate SHA --merge SHA
#   prepare --repo R --task T --base SHA --candidate SHA
#   publish --repo R --task T --target B --base SHA --candidate SHA --merge SHA
#           --candidate-ref ИМЯ --journal J        (candidate-ref ОБЯЗАТЕЛЕН, И-5в)
#
# Отказы: rc 1 с именованной фразой «ОТКАЗ: …» (якоря клеток, grep -F);
# rc 2 — NOT_IMPLEMENTED. Успех: «PUBLISHED target=<имя> merge=<sha>» либо
# «УЖЕ ОПУБЛИКОВАНО object=<id> merge=<sha>» (идемпотентность И-9).
#
# Инварианты контракта 094: И-0 грамматики, И-1 привязка вердикта к объекту
# (И-1б: различимость состава), И-2 последний применимый исход, И-3 находка
# привязана к объекту (И-3в: открытая находка в ДЕРЕВЕ кандидата), И-4
# обязательные проверки из доверенной политики (И-4б: wfsha доверенной версии
# + поле дерева строки check, сверяемое с M^{tree} — «проверили C, записали
# для M» отказывается),
# И-5 неизменность базы/кандидата (+обязательный candidate-ref), И-6 политика
# из ПРИНЯТОЙ версии (+И-6б: переход политики — отдельная санкция policy-строки),
# И-7 целевая ветка из allowlist, И-8 отказ не двигает ветку, И-9 повтор не
# создаёт второй merge.
set -uo pipefail
POLICY_PATH="harness/policy"

die() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
ni()  { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

command -v git >/dev/null 2>&1      || ni "нет git"
command -v sha256sum >/dev/null 2>&1 || ni "нет sha256sum"

usage() { printf 'usage: accept_publish.sh object|prepare|publish --repo R --task T [--target B] --base SHA --candidate SHA [--merge SHA] [--candidate-ref ИМЯ] [--journal J]\n' >&2; exit 1; }

VERB="${1:-}"; [ $# -ge 1 ] && shift || usage
case "$VERB" in object|prepare|publish) ;; *) usage ;; esac
REPO=""; TASK=""; TARGET=""; BASE=""; CAND=""; MERGE=""; CREF=""; JOURNAL=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:?}"; shift 2 ;;
    --task) TASK="${2:?}"; shift 2 ;;
    --target) TARGET="${2:?}"; shift 2 ;;
    --base) BASE="${2:?}"; shift 2 ;;
    --candidate) CAND="${2:?}"; shift 2 ;;
    --merge) MERGE="${2:?}"; shift 2 ;;
    --candidate-ref) CREF="${2:?}"; shift 2 ;;
    --journal) JOURNAL="${2:?}"; shift 2 ;;
    *) usage ;;
  esac
done
[ -n "$REPO" ] && [ -n "$TASK" ] && [ -n "$BASE" ] && [ -n "$CAND" ] || usage
[ -d "$REPO" ] || die "репозитория нет: $REPO"
for s in "$BASE" "$CAND" "$MERGE"; do
  [ -z "$s" ] && continue
  case "$s" in *[!0-9a-f]*|'') die "sha не 40 hex: $s" ;; esac
  [ "${#s}" -eq 40 ] || die "sha не 40 hex: $s"
done
case "$TASK" in ''|*[!A-Za-z0-9._/-]*) die "задача вне алфавита: $TASK" ;; esac

# ── политика из ПРИНЯТОЙ версии: base SHA (И-6; stub-точка t94-m6) ────────────
policy_bytes="$(git -C "$REPO" show "$BASE:$POLICY_PATH" 2>/dev/null)" # t94-m6
[ -n "$policy_bytes" ] || die "политика: нет $POLICY_PATH на base"
repoId=""; mandatory=""; branches=""
while IFS= read -r line; do
  [ -z "$line" ] && continue
  case "$line" in
    repoId=*) v="${line#repoId=}"; case "$v" in ''|*[!A-Za-z0-9._-]*) die "политика: грамматика" ;; esac; repoId="$v" ;;
    mandatory=*) v="${line#mandatory=}"; case "$v" in ''|*[!A-Za-z0-9._,:-]*) die "политика: грамматика" ;; esac; mandatory="$v" ;;
    targetBranches=*) v="${line#targetBranches=}"; case "$v" in ''|*[!A-Za-z0-9._/,:-]*) die "политика: грамматика" ;; esac; branches="$v" ;;
    *) die "политика: грамматика" ;;
  esac
done <<EOF
$policy_bytes
EOF
[ -n "$repoId" ] && [ -n "$mandatory" ] && [ -n "$branches" ] || die "политика: грамматика"
policyVersion="$(printf '%s' "$policy_bytes" | sha256sum | cut -d' ' -f1)"

object_id() {  # id объекта выдаёт МЕХАНИЗМ (Решение 2); состав — ВСЕ семь полей (И-1б)
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$repoId" "$TASK" "$TARGET" "$BASE" "$CAND" "$MERGE" "$policyVersion" | sha256sum | cut -d' ' -f1 # t94-m10
}

case "$VERB" in
object)
  [ -n "$TARGET" ] && [ -n "$MERGE" ] || usage
  object_id
  exit 0
  ;;
prepare)
  tree="$(git -C "$REPO" merge-tree --write-tree --no-messages "$BASE" "$CAND" 2>/dev/null)" \
    || die "merge конфликт: base candidate"
  m="$(GIT_AUTHOR_NAME=orchestrator GIT_AUTHOR_EMAIL=orchestrator@dev-harness.local \
       GIT_COMMITTER_NAME=orchestrator GIT_COMMITTER_EMAIL=orchestrator@dev-harness.local \
       git -C "$REPO" commit-tree "$tree" -p "$BASE" -p "$CAND" -m "land: $TASK")" \
    || die "merge-коммит не строится"
  printf '%s\n' "$m"
  exit 0
  ;;
esac

# ── publish ───────────────────────────────────────────────────────────────────
[ -n "$TARGET" ] && [ -n "$MERGE" ] && [ -n "$JOURNAL" ] || usage
[ -f "$JOURNAL" ] || die "журнал: нет файла: $JOURNAL"
oid="$(object_id)"

# И-7: целевая ветка из allowlist ДО любых движений refs (stub-точка t94-m7)
case ",$branches," in
  *",$TARGET,"*) : ;;
  *) die "недопустимая целевая ветка: $TARGET" ;; # t94-m7
esac

# И-1/И-2/И-3а: последний применимый вердикт задачи (привязка к объекту)
best_seq=-1; best_out=""; best_obj=""
while IFS=$'\t' read -r k t obj out seq; do
  [ "$k" = "verdict" ] || continue
  [ "$t" = "$TASK" ] || continue # t94-m1a: фильтр по задаче (ослабление = чужие accept/отказы)
  case "$out" in accept|fail) ;; *) die "журнал: грамматика: outcome" ;; esac
  case "$seq" in ''|*[!0-9]*) die "журнал: грамматика: seq" ;; esac
  if [ "$seq" -gt "$best_seq" ]; then best_seq="$seq"; best_out="$out"; best_obj="$obj"; fi
done <"$JOURNAL"
[ "$best_seq" -ge 0 ] || die "нет применимого accept для задачи: $TASK"
[ "$best_out" = "accept" ] || die "более новый отказ по предмету: $TASK" # t94-m2: последний исход
[ "$best_obj" = "$oid" ] || die "accept не этого объекта: $TASK" # t94-m1b/m8: accept ровно этого объекта

# И-4: КАЖДОЕ обязательное имя — своя зелёная строка check ЭТОГО объекта,
# исполненная ДОВЕРЕННОЙ версией определения (И-4б: wfsha = sha256 байтов
# harness/checks/<имя>.cmd на base SHA; одноимённый подменённый workflow ≠)
# на ДЕРЕВЕ подготовленного merge: строка check несёт tree sha ИСПОЛНЕННОГО
# дерева, дверь сверяет его литерально с MERGE^{tree} — «обязательная проверка
# исполнена на дереве C, строка записана под object_id M» отказывается (Б3,
# путь (а) арбитража 094; лгущий поставщик — доверенная сторона, НЕ ЗАЩИЩАЕТ)
mtree="$(git -C "$REPO" rev-parse --verify --quiet "$MERGE^{tree}" 2>/dev/null)" \
  || die "merge не этого объекта: коммита нет"
IFS=',' read -ra MAND <<<"$mandatory"
for name in "${MAND[@]}"; do
  git -C "$REPO" cat-file -e "$BASE:harness/checks/$name.cmd" 2>/dev/null \
    || die "нет доверенного определения: $name"
  tsha="$(git -C "$REPO" show "$BASE:harness/checks/$name.cmd" | sha256sum | cut -d' ' -f1)"
  st=""; sseq=-1; swf=""; str=""
  while IFS=$'\t' read -r k o n stt run wf stree; do
    [ "$k" = "check" ] || continue
    [ "$o" = "$oid" ] || continue
    [ "$n" = "$name" ] || continue # t94-m4: структурное сопоставление по имени
    case "$stt" in ok|fail) ;; *) die "журнал: грамматика: статус" ;; esac
    case "$run" in ''|*[!0-9]*) die "журнал: грамматика: run" ;; esac
    case "$wf" in ''|*[!0-9a-f]*) die "журнал: грамматика: wfsha" ;; esac
    [ "${#wf}" -eq 64 ] || die "журнал: грамматика: wfsha"
    case "$stree" in ''|*[!0-9a-f]*) die "журнал: грамматика: дерево" ;; esac
    [ "${#stree}" -eq 40 ] || die "журнал: грамматика: дерево"
    if [ "$run" -gt "$sseq" ]; then sseq="$run"; st="$stt"; swf="$wf"; str="$stree"; fi
  done <"$JOURNAL"
  [ -n "$st" ] || die "нет обязательной проверки: $name"
  [ "$st" = "ok" ] || die "обязательная проверка красна: $name"
  [ "$swf" = "$tsha" ] || die "проверка не доверенной версии: $name" # t94-m12: происхождение прогона
  [ "$str" = "$mtree" ] || die "проверка не того дерева: $name" # t94-m15: исполнено другое дерево
done

# И-3в: открытая находка в ДЕРЕВЕ кандидата (.review/*.md со строкой «status: ready»)
# — дверь читает git-объекты кандидата, не журнал и не checkout main (Б2)
while IFS= read -r rp; do
  git -C "$REPO" show "$CAND:$rp" 2>/dev/null | grep -Fxq 'status: ready' && die "открытая находка в кандидате: $rp" # t94-m11
done < <(git -C "$REPO" ls-tree -r --name-only "$CAND" -- .review 2>/dev/null | grep '\.md$')

# И-6б: переход политики — ОТДЕЛЬНАЯ санкция policy-строкой журнала; обычный
# accept объекта её не заменяет (Б4). К собственному принятию кандидата
# по-прежнему применяется политика base (И-6).
cand_pol="$(git -C "$REPO" show "$CAND:$POLICY_PATH" 2>/dev/null)"
[ -n "$cand_pol" ] || die "политика кандидата удалена"
cand_pv="$(printf '%s' "$cand_pol" | sha256sum | cut -d' ' -f1)"
if [ "$cand_pv" != "$policyVersion" ]; then
  pol_pat="$(printf 'policy\t%s\t%s\t%s\taccept\t' "$oid" "$policyVersion" "$cand_pv")"
  grep -Fq "$pol_pat" "$JOURNAL" || die "неавторизованный переход политики: $policyVersion -> $cand_pv" # t94-m13
fi

# И-9(а): уже опубликовано — строка published
if grep -Fq "published	$oid	" "$JOURNAL"; then # t94-m9: идемпотентность по журналу
  refnow="$(git -C "$REPO" rev-parse "refs/heads/$TARGET")"
  [ "$refnow" = "$MERGE" ] || die "публикация расползлась: ref != merge"
  printf 'УЖЕ ОПУБЛИКОВАНО object=%s merge=%s\n' "$oid" "$MERGE"
  exit 0
fi

# И-9(б): частичный успех — ветка УЖЕ на merge, строки published нет
refnow="$(git -C "$REPO" rev-parse "refs/heads/$TARGET")"
if [ "$refnow" = "$MERGE" ]; then # t94-m9b: завершение частичного успеха
  printf 'published	%s	%s	%s\n' "$oid" "$MERGE" "$((best_seq + 1))" >>"$JOURNAL"
  printf 'УЖЕ ОПУБЛИКОВАНО object=%s merge=%s\n' "$oid" "$MERGE"
  exit 0
fi

# И-5: повторная сверка базы и кандидата В МОМЕНТ публикации (Н-78/Н-185)
[ "$refnow" = "$BASE" ] || die "база изменилась: $BASE != $refnow" # t94-m5a
[ -n "$CREF" ] || die "candidate-ref обязателен для публикации" # t94-m5d: сверка кандидата не выключается молчанием CLI
if [ -n "$CREF" ]; then
  cnow="$(git -C "$REPO" rev-parse "refs/heads/$CREF" 2>/dev/null)" || die "кандидат изменился: $CREF нет"
  [ "$cnow" = "$CAND" ] || die "кандидат изменился: $CREF $CAND != $cnow" # t94-m5b
fi
git -C "$REPO" rev-parse --verify --quiet "$MERGE^{commit}" >/dev/null 2>&1 \
  || die "merge не этого объекта: коммита нет"
pp="$(git -C "$REPO" show -s --format='%P' "$MERGE")"
[ "$pp" = "$BASE $CAND" ] || die "merge не этого объекта: родители $pp"

# И-8/И-9: перенос ИМЕННО проверенного merge, атомарно от base
git -C "$REPO" update-ref "refs/heads/$TARGET" "$MERGE" "$BASE" # t94-m5c: compare-and-swap на base
[ "$(git -C "$REPO" rev-parse "refs/heads/$TARGET")" = "$MERGE" ] || die "база изменилась: гонка, ref не двинулся на merge"
printf 'published	%s	%s	%s\n' "$oid" "$MERGE" "$((best_seq + 1))" >>"$JOURNAL"
printf 'PUBLISHED target=%s merge=%s\n' "$TARGET" "$MERGE"
exit 0
