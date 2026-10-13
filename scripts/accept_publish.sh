#!/usr/bin/env bash
# Дверь приёмки+публикации: проверяющая часть publish (контракт 098, зона
# implementer; грамматики — И-0 контракта 094). Контракт 098 §Предмет:
# «Чтение доказательств дверью (проверяющая часть `publish`); публикация новой
# дверью — только РЕПЕТИЦИЯ в изолированной копии, без credential публикации» —
# производственное переключение на эту дверь — часть В (094 v3), здесь ленды
# ходят прежними путями. Журнал — ВНЕ проверяемой ветки: запись строки
# доказательства не меняет B/C/M (объект — git-объекты по sha, Б-6).
#
# Глаголы (TAB-поля; id = каноническая строка объекта):
#   object  --repo R --task T --target B --base SHA --candidate SHA --merge SHA
#   prepare --repo R --task T --base SHA --candidate SHA
#   publish --repo R --task T --target B --base SHA --candidate SHA --merge SHA
#           --candidate-ref ИМЯ --journal J   (candidate-ref ОБЯЗАТЕЛЕН, И-5в:
#           сверка кандидата не выключается молчанием CLI)
#
# Коды возврата: 0 — object_id/M напечатан либо PUBLISHED/УЖЕ ОПУБЛИКОВАНО,
# 1 — отказ с именованной фразой «ОТКАЗ: …» (якоря клеток 098, grep -F),
# 2 — NOT_IMPLEMENTED (нечем проверять). Успех: «PUBLISHED target=<имя>
# merge=<sha>» либо «УЖЕ ОПУБЛИКОВАНО object=<id> merge=<sha>» (И-9).
#
# Инварианты (094/098): И-0 грамматики журнала, И-1 привязка вердикта к объекту
# (последний по seq исход ЗАДАЧИ; accept ровно ЭТОГО object_id), И-2 последний
# применимый исход (поздний fail/красный прогон перекрывают ранний accept),
# И-3 открытая находка в ДЕРЕВЕ кандидата (.review/*.md «status: ready»),
# И-4 каждый обязательный ключ — своя строка check ЭТОГО объекта: литеральное
# имя, wfsha ДОВЕРЕННОЙ версии (sha256 harness/checks/<имя>.cmd на base SHA),
# дерево строки == MERGE^{tree} («обязательная проверка красна» судится РАНЬШЕ
# сверок версии/дерева — отрицательный результат есть факт журнала, арбитраж
# 098); дверь судит по BASE, не по локальной доске писателя; И-5 повторная
# сверка базы/кандидата в момент публикации + compare-and-swap на base,
# И-6 политика из ПРИНЯТОЙ версии (переход — отдельная санкция policy-строки),
# И-7 целевая ветка из allowlist targetBranches, И-8 отказ не двигает ветку,
# И-9 повтор не создаёт второй merge. Парсер политики принимает ключ
# ciApp=<slug> (пин исполнителя CI, решение 2/Б-5 контракта 098): дверь ключ
# ПРИНИМАЕТ и им не судит — потребитель check-писатель.
#
# ГЕРМЕТИЧНОЕ ОКРУЖЕНИЕ — RE-EXEC ЧЕРЕЗ `env -i` (та же доктрина, что
# scripts/check_protected.sh / scripts/check_zones.sh: доверенный PATH закрывает
# подмену внешних утилит унаследованным $PATH и весь класс экспортированных
# bash-функций — BASH_FUNC_* не переживает пустое окружение; дверь доверенной
# стороны судит журнал и двигает refs, поэтому гигиена среды максимальная).
# /proc/$$/environ — Linux/procfs, принятый риск того же прецедента.
# PATH наследовать НЕЛЬЗЯ и по второй причине: дверь не зовёт curl — ей не нужен
# ни поддельный, ни живой ответ CI (доказательства уже в журнале).
if ( return 0 2>/dev/null ) || [[ "$(/usr/bin/tr '\0' '\n' < /proc/$$/environ)" != $'PATH=/usr/bin:/bin\nLC_ALL=C.UTF-8' ]]; then
  POSIXLY_CORRECT=1
  exec /usr/bin/env -i PATH=/usr/bin:/bin LC_ALL=C.UTF-8 /usr/bin/bash "${BASH_SOURCE[0]}" "$@"
fi
set -euo pipefail

# Доверенный PATH + нейтрализация унаследованных git-переменных, подменяющих
# предмет: дверь обязана смотреть на репозиторий, названный аргументом --repo.
export PATH=/usr/bin:/bin
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DATABASE \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

POLICY_PATH="harness/policy"

die() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
ni()  { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

command -v dirname   >/dev/null 2>&1 || ni "нет dirname в доверенном PATH — путь скрипта нечем вычислить"
command -v git       >/dev/null 2>&1 || ni "нет git в доверенном PATH — объекты нечем читать"
command -v sha256sum >/dev/null 2>&1 || ni "нет sha256sum в доверенном PATH — политики/определения нечем хешировать"
command -v grep      >/dev/null 2>&1 || ni "нет grep в доверенном PATH — журнал нечем судить"

usage() { printf 'usage: accept_publish.sh object|prepare|publish --repo R --task T [--target B] --base SHA --candidate SHA [--merge SHA] [--candidate-ref ИМЯ] [--journal J]\n' >&2; exit 1; }

VERB="${1:-}"; [ $# -ge 1 ] && shift || usage
case "$VERB" in object|prepare|publish) ;; *) usage ;; esac
REPO=""; TASK=""; TARGET=""; BASE=""; CAND=""; MERGE=""; CREF=""; JOURNAL=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo)          [ $# -ge 2 ] || usage; REPO="$2"; shift 2 ;;
    --task)          [ $# -ge 2 ] || usage; TASK="$2"; shift 2 ;;
    --target)        [ $# -ge 2 ] || usage; TARGET="$2"; shift 2 ;;
    --base)          [ $# -ge 2 ] || usage; BASE="$2"; shift 2 ;;
    --candidate)     [ $# -ge 2 ] || usage; CAND="$2"; shift 2 ;;
    --merge)         [ $# -ge 2 ] || usage; MERGE="$2"; shift 2 ;;
    --candidate-ref) [ $# -ge 2 ] || usage; CREF="$2"; shift 2 ;;
    --journal)       [ $# -ge 2 ] || usage; JOURNAL="$2"; shift 2 ;;
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

# ── политика из ПРИНЯТОЙ версии: base SHA (И-6) ──────────────────────────────
policy_bytes="$(git -C "$REPO" show "$BASE:$POLICY_PATH" 2>/dev/null || true)"
[ -n "$policy_bytes" ] || die "политика: нет $POLICY_PATH на base"
repoId=""; mandatory=""; branches=""
while IFS= read -r line; do
  [ -z "$line" ] && continue
  case "$line" in
    repoId=*) v="${line#repoId=}"; case "$v" in ''|*[!A-Za-z0-9._-]*) die "политика: грамматика" ;; esac; repoId="$v" ;;
    mandatory=*) v="${line#mandatory=}"; case "$v" in ''|*[!A-Za-z0-9._,:-]*) die "политика: грамматика" ;; esac; mandatory="$v" ;;
    ciApp=*) v="${line#ciApp=}"; case "$v" in ''|*[!A-Za-z0-9._-]*) die "политика: грамматика" ;; esac ;; # пин исполнителя CI — принимается, дверью не судится (решение 2/Б-5 098)
    targetBranches=*) v="${line#targetBranches=}"; case "$v" in ''|*[!A-Za-z0-9._/,:-]*) die "политика: грамматика" ;; esac; branches="$v" ;;
    *) die "политика: грамматика" ;;
  esac
done <<EOF
$policy_bytes
EOF
[ -n "$repoId" ] && [ -n "$mandatory" ] && [ -n "$branches" ] || die "политика: грамматика"
policyVersion="$(printf '%s' "$policy_bytes" | sha256sum | cut -d' ' -f1)"

object_id() {  # id объекта выдаёт МЕХАНИЗМ; состав — ВСЕ семь полей (И-1б)
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$repoId" "$TASK" "$TARGET" "$BASE" "$CAND" "$MERGE" "$policyVersion" | sha256sum | cut -d' ' -f1
}

case "$VERB" in
object)
  [ -n "$TARGET" ] && [ -n "$MERGE" ] || usage
  object_id
  exit 0
  ;;
prepare)
  # merge-носитель строится БЕЗ движения refs (Р4-1: перенос обычными
  # коммитами, без подставного носителя; Б-6: prepare не трогает main/ветку
  # кандидата — M это чистый git-объект до самой публикации)
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

# ── publish ──────────────────────────────────────────────────────────────────
[ -n "$TARGET" ] && [ -n "$MERGE" ] && [ -n "$JOURNAL" ] || usage
[ -f "$JOURNAL" ] || die "журнал: нет файла: $JOURNAL"
oid="$(object_id)"

# И-7: целевая ветка из allowlist ДО любых движений refs
case ",$branches," in
  *",$TARGET,"*) : ;;
  *) die "недопустимая целевая ветка: $TARGET" ;;
esac

# И-1/И-2/И-3а: последний применимый вердикт задачи (привязка к объекту)
best_seq=-1; best_out=""; best_obj=""
while IFS=$'\t' read -r k t obj out seq; do
  [ "$k" = "verdict" ] || continue
  [ "$t" = "$TASK" ] || continue  # фильтр по задаче: чужие accept/отказы не считаются
  case "$out" in accept|fail) ;; *) die "журнал: грамматика: outcome" ;; esac
  case "$seq" in ''|*[!0-9]*) die "журнал: грамматика: seq" ;; esac
  if [ "$seq" -gt "$best_seq" ]; then best_seq="$seq"; best_out="$out"; best_obj="$obj"; fi
done <"$JOURNAL"
[ "$best_seq" -ge 0 ] || die "нет применимого accept для задачи: $TASK"
[ "$best_out" = "accept" ] || die "более новый отказ по предмету: $TASK"  # последний исход
[ "$best_obj" = "$oid" ] || die "accept не этого объекта: $TASK"          # accept ровно этого объекта

# И-4: КАЖДОЕ обязательное имя — своя зелёная строка check ЭТОГО объекта,
# исполненная ДОВЕРЕННОЙ версией определения (sha256 harness/checks/<имя>.cmd
# на base SHA) на ДЕРЕВЕ подготовленного merge. Суд идёт по ПОСЛЕДНЕЙ строке
# ключа по run (арбитраж 098: поздний fail перекрывает ранний ok); «красна» —
# РАНЬШЕ сверок версии/дерева (отрицательный результат — факт журнала);
# «проверили C, записали для M» отказывается сверкой tree с MERGE^{tree}.
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
    [ "$n" = "$name" ] || continue  # имя литерально (Б-3/Б-5): подстрока не источник истины
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
  [ "$swf" = "$tsha" ] || die "проверка не доверенной версии: $name"   # дверь судит по base, не по доске писателя
  [ "$str" = "$mtree" ] || die "проверка не того дерева: $name"        # исполнено другое дерево
done

# И-3в: открытая находка в ДЕРЕВЕ кандидата — дверь читает git-объекты
# кандидата, не журнал и не checkout main
while IFS= read -r rp; do
  git -C "$REPO" show "$CAND:$rp" 2>/dev/null | grep -Fxq 'status: ready' && die "открытая находка в кандидате: $rp"
done < <(git -C "$REPO" ls-tree -r --name-only "$CAND" -- .review 2>/dev/null | grep '\.md$')

# И-6б: переход политики — ОТДЕЛЬНАЯ санкция policy-строкой журнала; обычный
# accept объекта её не заменяет. К собственному принятию кандидата применяется
# политика base (И-6).
cand_pol="$(git -C "$REPO" show "$CAND:$POLICY_PATH" 2>/dev/null || true)"
[ -n "$cand_pol" ] || die "политика кандидата удалена"
cand_pv="$(printf '%s' "$cand_pol" | sha256sum | cut -d' ' -f1)"
if [ "$cand_pv" != "$policyVersion" ]; then
  pol_pat="$(printf 'policy\t%s\t%s\t%s\taccept\t' "$oid" "$policyVersion" "$cand_pv")"
  grep -Fq "$pol_pat" "$JOURNAL" || die "неавторизованный переход политики: $policyVersion -> $cand_pv"
fi

# И-9(а): уже опубликовано — строка published
if grep -Fq "$(printf 'published\t%s\t' "$oid")" "$JOURNAL"; then
  refnow="$(git -C "$REPO" rev-parse "refs/heads/$TARGET")"
  [ "$refnow" = "$MERGE" ] || die "публикация расползлась: ref != merge"
  printf 'УЖЕ ОПУБЛИКОВАНО object=%s merge=%s\n' "$oid" "$MERGE"
  exit 0
fi

# И-9(б): частичный успех — ветка УЖЕ на merge, строки published нет
refnow="$(git -C "$REPO" rev-parse "refs/heads/$TARGET")"
if [ "$refnow" = "$MERGE" ]; then
  printf 'published\t%s\t%s\t%s\n' "$oid" "$MERGE" "$((best_seq + 1))" >>"$JOURNAL"
  printf 'УЖЕ ОПУБЛИКОВАНО object=%s merge=%s\n' "$oid" "$MERGE"
  exit 0
fi

# И-5: повторная сверка базы и кандидата В МОМЕНТ публикации (Н-78/Н-185)
[ "$refnow" = "$BASE" ] || die "база изменилась: $BASE != $refnow"
[ -n "$CREF" ] || die "candidate-ref обязателен для публикации"  # сверка кандидата не выключается молчанием CLI
if [ -n "$CREF" ]; then
  cnow="$(git -C "$REPO" rev-parse "refs/heads/$CREF" 2>/dev/null || true)"
  [ "$cnow" = "$CAND" ] || die "кандидат изменился: $CREF $CAND != ${cnow:-<refs/heads/$CREF нет>}"
fi
git -C "$REPO" rev-parse --verify --quiet "$MERGE^{commit}" >/dev/null 2>&1 \
  || die "merge не этого объекта: коммита нет"
pp="$(git -C "$REPO" show -s --format='%P' "$MERGE")"
[ "$pp" = "$BASE $CAND" ] || die "merge не этого объекта: родители $pp"

# И-8/И-9: перенос ИМЕННО проверенного merge, атомарно от base
git -C "$REPO" update-ref "refs/heads/$TARGET" "$MERGE" "$BASE" \
  || die "база изменилась: гонка, ref не двинулся на merge"
[ "$(git -C "$REPO" rev-parse "refs/heads/$TARGET")" = "$MERGE" ] \
  || die "база изменилась: гонка, ref не двинулся на merge"
printf 'published\t%s\t%s\t%s\n' "$oid" "$MERGE" "$((best_seq + 1))" >>"$JOURNAL"
printf 'PUBLISHED target=%s merge=%s\n' "$TARGET" "$MERGE"
exit 0
