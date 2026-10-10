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
# Коды возврата:
#   0 — успех: «PUBLISHED target=<имя> merge=<sha>» либо «УЖЕ ОПУБЛИКОВАНО object=<id> merge=<sha>» (И-9)
#   1 — отказ с именованной фразой «ОТКАЗ: …» (якоря клеток, grep -F)
#   2 — NOT_IMPLEMENTED: нет инструмента или предмет отсутствует
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
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$SELF_DIR/lib_zones.sh"

die() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
ni()  { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

# ── identity-check 016 И-7/И-9 (Б-2 ревью): committer==author ∧ committer ∈ реестр зон.
# Проверяет ВСЕ коммиты диапазона BASE..CAND на реальной (не toy) ветке. Использует
# ЕДИНСТВЕННЫЙ читатель зон lib_zones.sh (НЕ дублирует логику — прецедент
# check_zones.sh). Toy-мир батареи 094 без frozen-контрактов пропускает проверку
# (zones_scoped пуст → реестра нет → committer не проверяется): фикстуры клеток
# используют _t94_world без заморозок и не должны ломаться этим наследством 016.
# Допустимый красный критерий контрпроверки: коммит с committer, не входящим в
# реестр зон, на ветке С frozen-контрактами — prepare/publish ОБЯЗАНЫ отказать.
_t94_identity_check() {  # repo, base, candidate → die с «identity: …»
  local r="$1" b="$2" c="$3" zones_dir n_contracts cmt author committer seen
  seen=""
  zones_dir="$(zones_load "$r" 2>/dev/null)" || {
    ni "identity: реестр заморозок недоступен"; }
  n_contracts="$(wc -l < "$zones_dir/contracts_list" | tr -d ' ')"
  if [ "${n_contracts:-0}" -eq 0 ]; then
    __lib_zones_cleanup 2>/dev/null || true
    return 0  # toy-мир: реестра зон нет — committer не проверяется
  fi
  while IFS= read -r cmt; do
    [ -n "$cmt" ] || continue
    author="$(git -C "$r" log -1 --format='%an' "$cmt" 2>/dev/null)"
    committer="$(git -C "$r" log -1 --format='%cn' "$cmt" 2>/dev/null)"
    case "$seen" in *"|$committer|"*) continue ;; esac
    seen="$seen|$committer|"
    [ "$author" = "$committer" ] || die "identity: committer!=author в $cmt: $committer vs $author"
    grep -qF "$committer"$'\t' "$zones_dir/zones_scoped" \
      || die "identity: committer не в реестре зон: $committer ($cmt)"
  done < <(git -C "$r" rev-list "$b..$c" 2>/dev/null)
  __lib_zones_cleanup 2>/dev/null || true
  return 0
}

command -v git >/dev/null 2>&1      || ni "нет git"
command -v sha256sum >/dev/null 2>&1 || ni "нет sha256sum"

usage() { printf 'usage: accept_publish.sh object|prepare|publish --repo R --task T [--target B] --base SHA --candidate SHA [--merge SHA] [--candidate-ref ИМЯ] [--journal J]\n' >&2; exit 1; }

VERB="${1:-}"; [ $# -ge 1 ] && shift || usage
case "$VERB" in object|prepare|publish) ;; *) usage ;; esac
REPO=""; TASK=""; TARGET=""; BASE=""; CAND=""; MERGE=""; CREF=""; JOURNAL=""; POLICY_DIR=""
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
    --policy-dir) POLICY_DIR="${2:?}"; shift 2 ;;
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

# ── политика из ПРИНЯТОЙ версии — ИНВАРИАНТ carrier-симметрии (Б-5-R5) ────────
# И-6/И-6б (контракт 094). Закрытый алфавит carrier'ов:
#   registry/ci-steps.tsv   — production-харнес (профиль 2.1 контракта 094)
#   harness/policy          — toy-мир (контракт 094 §Решения п.(в))
# ИНВАРИАНТ: присутствие carrier'а симметрично на ОБЕИХ сторонах. Любая асимметрия
# (BASE toy, CAND добавлен registry — или наоборот) — самостоятельный carrier-
# переход и отдельная санкция policy-строкой (И-6б). До этого выбора POLICY_SOURCE
# НЕТ: тихий выбор по одной стороне (как было в Б-4-R4) открывал сценарий
# «toy→production-bypass»: BASE toy → CAND тихо проносит ослабленный registry,
# после publish'а следующая операция видела уже BASE с registry и принимала
# урезанную политику как доверенную. Теперь — отказ «смешение carrier'ов»
# ДО движения refs (И-8) и ДО формирования object_id (И-1б).
policy_bytes=""
POLICY_SOURCE=""
registry_wfsha=""

# ── симметричное чтение carrier'ов на ОБЕИХ сторонах (И-6б; Б-5-R5)
base_registry="$(git -C "$REPO" show "$BASE:registry/ci-steps.tsv" 2>/dev/null)" || base_registry=""
cand_registry="$(git -C "$REPO" show "$CAND:registry/ci-steps.tsv" 2>/dev/null)" || cand_registry=""

if [ -n "$base_registry" ] && [ -z "$cand_registry" ]; then
  die "carrier: registry/ci-steps.tsv удалён кандидатом (требуется отдельная санкция)"
fi
if [ -z "$base_registry" ] && [ -n "$cand_registry" ]; then
  die "carrier: registry/ci-steps.tsv добавлен кандидатом к toy-base (требуется отдельная санкция)"
fi

# ── POLICY_DIR override (Р2-3 Б-1 фикс): если wrapper передаёт --policy-dir,
# читаем ПОЛИТИКУ и ОПРЕДЕЛЕНИЯ проверок оттуда вместо репо. Это позволяет
# wrapper'у (оркестратор — доверенная сторона) синтезировать политику для
# toy/fixture миров, где её нет в репо. Структура POLICY_DIR:
#   harness/policy                 — файл политики
#   harness/checks/<name>.cmd      — определения проверок (для toy)
# carrier-СИММЕТРИЯ (И-6б/Б-5-R5) остаётся ОБЯЗАТЕЛЬНОЙ через base_registry/
# cand_registry выше — она про carrier-носитель (есть/нет в репо), а не про
# содержимое policy.
if [ -n "$POLICY_DIR" ]; then
  [ -d "$POLICY_DIR" ] || die "policy-dir: нет каталога: $POLICY_DIR"
  [ -f "$POLICY_DIR/harness/policy" ] || die "policy-dir: нет harness/policy в $POLICY_DIR"
fi

if [ -n "$POLICY_DIR" ] && [ -n "$base_registry" ]; then
  # Реестр production-БАЗЫ + policy-dir override: используем байты policy из
  # override, но carrier для base/cand проверки берём из репо.
  POLICY_SOURCE="registry/ci-steps.tsv"
  repoId="dev-harness"
  branches="main"
  registry_wfsha="$(printf '%s' "$base_registry" | sha256sum | cut -d' ' -f1)"
  policy_bytes="$(cat "$POLICY_DIR/harness/policy")"
  mandatory=""
  while IFS=$'\t' read -r kind k _w _cmd; do
    [ "$kind" = "step" ] || continue
    case "$k" in ''|*[!A-Za-z0-9._:-]*) die "политика: грамматика" ;; esac
    if [ -z "$mandatory" ]; then mandatory="$k"; else mandatory="$mandatory,$k"; fi
  done <<EOF
$base_registry
EOF
  [ -n "$mandatory" ] || die "политика: registry/ci-steps.tsv без step-строк на base"
elif [ -n "$POLICY_DIR" ]; then
  # Toy-мир + policy-dir override: используем harness/policy + harness/checks/*.cmd
  POLICY_SOURCE="$POLICY_PATH"
  policy_bytes="$(cat "$POLICY_DIR/harness/policy")"
  repoId=""; mandatory=""; branches=""
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    case "$line" in
      repoId=*) v="${line#repoId=}"; case "$v" in ''|*[!A-Za-z0-9._-]*) die "политика: грамматика" ;; esac; repoId="$v" ;;
      mandatory=*) v="${line#mandatory=}"; case "$v" in ''|*[!A-Za-z0-9._,:-]*) die "политика: грамматика" ;; esac; case "$v" in ''|,*|*,|*,,*) die "политика: грамматика" ;; esac; mandatory="$v" ;;
      targetBranches=*) v="${line#targetBranches=}"; case "$v" in ''|*[!A-Za-z0-9._/,:-]*) die "политика: грамматика" ;; esac; case "$v" in ''|,*|*,|*,,*) die "политика: грамматика" ;; esac; branches="$v" ;;
      *) die "политика: грамматика" ;;
    esac
  done <<EOF
$policy_bytes
EOF
elif registry_bytes="$(git -C "$REPO" show "$BASE:registry/ci-steps.tsv" 2>/dev/null)" && [ -n "$registry_bytes" ]; then
  POLICY_SOURCE="registry/ci-steps.tsv"
  policy_bytes="$registry_bytes"
  # Харнес-репо: repoId/targetBranches — дефолты (targetBranches ВВОДИТСЯ той же
  # пачкой миграцией SCHEMA_LEVELS, до неё — main; repoId — канон имени репо).
  repoId="dev-harness"
  branches="main"
  # mandatory — запятая-объединённые ключи step-строк реестра (закрытый алфавит
  # И-0 контракта 083); определения обязательных проверок — те же байты реестра
  # (доверенная версия по base SHA); wfsha одной строкой (И-4б упрощённо:
  # ПОЛНЫЙ реестр на base — единственная доверенная версия для ВСЕХ проверок;
  # любой дрейф реестра инвалидирует записи check для ВСЕХ ключей разом).
  registry_wfsha="$(printf '%s' "$registry_bytes" | sha256sum | cut -d' ' -f1)"
  mandatory=""
  while IFS=$'\t' read -r kind k _w _cmd; do
    [ "$kind" = "step" ] || continue
    case "$k" in ''|*[!A-Za-z0-9._:-]*) die "политика: грамматика" ;; esac
    if [ -z "$mandatory" ]; then mandatory="$k"; else mandatory="$mandatory,$k"; fi
  done <<EOF
$registry_bytes
EOF
  [ -n "$mandatory" ] || die "политика: registry/ci-steps.tsv без step-строк на base"
else
  POLICY_SOURCE="harness/policy"
  policy_bytes="$(git -C "$REPO" show "$BASE:$POLICY_PATH" 2>/dev/null)" # t94-m6
  [ -n "$policy_bytes" ] || die "политика: нет registry/ci-steps.tsv и $POLICY_PATH на base"
  repoId=""; mandatory=""; branches=""
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    case "$line" in
      repoId=*) v="${line#repoId=}"; case "$v" in ''|*[!A-Za-z0-9._-]*) die "политика: грамматика" ;; esac; repoId="$v" ;;
      mandatory=*) v="${line#mandatory=}"; case "$v" in ''|*[!A-Za-z0-9._,:-]*) die "политика: грамматика" ;; esac; case "$v" in ''|,*|*,|*,,*) die "политика: грамматика" ;; esac; mandatory="$v" ;;
      targetBranches=*) v="${line#targetBranches=}"; case "$v" in ''|*[!A-Za-z0-9._/,:-]*) die "политика: грамматика" ;; esac; case "$v" in ''|,*|*,|*,,*) die "политика: грамматика" ;; esac; branches="$v" ;;
      *) die "политика: грамматика" ;;
    esac
  done <<EOF
$policy_bytes
EOF
fi
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
  _t94_identity_check "$REPO" "$BASE" "$CAND"
  tree="$(git -C "$REPO" merge-tree --write-tree --no-messages "$BASE" "$CAND" 2>/dev/null)" \
    || die "merge конфликт: base candidate"
  # И-10 (контракт 065): перенос строк-санкций в тело merge-коммита.
  # Строки РАЗРЕШИЛ-ВЛАДЕЛЕЦ: и ALLOW-ARTIFACT-DELETE: копируются из тел
  # коммитов диапазона BASE..CAND ДОСЛОВНО (байт-в-байт), дедуп ТОЛЬКО точных
  # повторов, синтез запрещён: при пустом множестве строк merge-тело байт-в-байт
  # как «land: <ветка>» одной строкой (И-4 фикстуры: ровно одна строка, без
  # маркеров). Сообщение merge — из ФАЙЛА через -F: дефолтный `git commit-tree
  # -m` НЕ передаёт строки дословно (есть нормализация); -F передаёт байты 1:1.
  # Фикстура 065 И-2 «дедупликация точных повторов» достигается здесь через
  # `awk '!seen[$0]++'` — без awk обратный стаб «дедуп по $1» проходил бы.
  MSGDIR="$(mktemp -d)"
  trap 'rm -rf "$MSGDIR"' EXIT
  : > "$MSGDIR/sanctions_all"
  git -C "$REPO" rev-list "$BASE..$CAND" 2>/dev/null \
    | while IFS= read -r sha; do
        [ -n "$sha" ] || continue
        git -C "$REPO" log -1 --format=%B "$sha"
        printf '\n'
      done > "$MSGDIR/sanctions_all"
  awk '/^РАЗРЕШИЛ-ВЛАДЕЛЕЦ:/ || /^ALLOW-ARTIFACT-DELETE:/ { print }' "$MSGDIR/sanctions_all" \
    | awk '!seen[$0]++' > "$MSGDIR/sanctions"
  { printf 'land: %s\n' "$TASK"; cat "$MSGDIR/sanctions"; } > "$MSGDIR/msg"
  m="$(GIT_AUTHOR_NAME=orchestrator GIT_AUTHOR_EMAIL=orchestrator@dev-harness.local \
       GIT_COMMITTER_NAME=orchestrator GIT_COMMITTER_EMAIL=orchestrator@dev-harness.local \
       git -C "$REPO" commit-tree "$tree" -p "$BASE" -p "$CAND" -F "$MSGDIR/msg")" \
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

# identity-check 016 И-7/И-9 (повторная сверка перед публикацией, И-5):
# коммит с committer вне реестра зон отказывается НЕЗАВИСИМО от статуса
# acceptance (контракт 016: committer == author ∧ ∈ zones — инвариант гейта,
# а не доказательство — он не отменяется accept'ом судьи).
_t94_identity_check "$REPO" "$BASE" "$CAND"

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
  if [ "$POLICY_SOURCE" = "registry/ci-steps.tsv" ]; then
    # Доверенная версия для ВСЕХ проверок харнес-репо — ПОЛНЫЙ реестр на base
    # (И-4б: «определения обязательных проверок — та же доверенная версия»;
    # любой дрейф реестра инвалидирует записи check для ВСЕХ ключей разом).
    git -C "$REPO" cat-file -e "$BASE:registry/ci-steps.tsv" 2>/dev/null \
      || die "нет доверенного определения: $name"
    tsha="$registry_wfsha"
  elif [ -n "$POLICY_DIR" ]; then
    # Toy-мир + policy-dir override: определения проверок — из POLICY_DIR.
    [ -f "$POLICY_DIR/harness/checks/$name.cmd" ] || die "нет доверенного определения: $name"
    tsha="$(sha256sum < "$POLICY_DIR/harness/checks/$name.cmd" | cut -d' ' -f1)"
  else
    # Toy-мир батареи 094: каждая проверка — свой `harness/checks/<имя>.cmd` на base.
    git -C "$REPO" cat-file -e "$BASE:harness/checks/$name.cmd" 2>/dev/null \
      || die "нет доверенного определения: $name"
    tsha="$(git -C "$REPO" show "$BASE:harness/checks/$name.cmd" | sha256sum | cut -d' ' -f1)"
  fi
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
# Б-4-R4 (adversary v4): cand_pol читается по тому же carrier'у, что и
# policy_bytes (POLICY_SOURCE: registry/ci-steps.tsv для production-харнеса,
# harness/policy для toy-мира). Иначе — ложный отказ честного production-кандидата
# и обход И-6б злоумышленником (decoy harness/policy маскирует обнуление production).
# Р2-3 override: при POLICY_DIR cand_pol берётся оттуда (toy/fixture без репо).
if [ -n "$POLICY_DIR" ] && [ "$POLICY_SOURCE" = "$POLICY_PATH" ]; then
  cand_pol="$(cat "$POLICY_DIR/harness/policy")"
else
  cand_pol="$(git -C "$REPO" show "$CAND:$POLICY_SOURCE" 2>/dev/null)"
fi
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
