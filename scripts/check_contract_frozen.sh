#!/usr/bin/env bash
# Замороженный план или контракт НЕИЗМЕНЕН: блоб на HEAD побайтово равен блобу высшей заморозки.
#
# Инвариант от РЕЗУЛЬТАТА, а не от способа — как у `check_protected.sh`. Способов изменить
# утверждённый текст больше, чем можно перечислить: правка, переименование с восстановлением,
# слияние, «мелкое уточнение по ходу». Результат один: то, по чему раздали работу, больше не то,
# что лежит в дереве. Именно этот результат и стоил семи кругов на шаге 5, когда спека и красные
# критерии менялись во время исполнения.
#
# ЧЕРНОВИК ЗАКОНЕН. Файл без тегов `frozen/*` — черновик, и барьер печатает про него `ok`. Запрет
# раздавать работу по черновику держит не этот барьер, а роль исполнителя: его первое действие —
# убедиться, что контракт заморожен. Здесь запрещать нечего: план в работе пишется правками, и
# гейт, краснеющий на черновике, заставил бы морозить недописанное.
#
# ВЕРДИКТ КРИТИКА ПРОВЕРЯЕТСЯ НА КАЖДУЮ ВЕРСИЮ, а не только на высшую: тег, поставленный рукой
# мимо `freeze_contract.sh`, иначе прошёл бы незамеченным. Диагноз здесь ОДИН на все значения,
# отличные от `accept` («заморозка лежит поверх вердикта, который её не разрешил»), и это
# осознанно: разводить `FAIL`, `ESCALATE` и мусор обязан ПИСАТЕЛЬ, который решает, ставить ли тег.
# Читателю тег уже дан, и его предмет — что этот тег не имел права появиться, а не почему судья
# отказал.
#
# ЭТО ЧИТАТЕЛЬ реестра, поэтому `unknown-remote` (origin объявлен, но недоступен) годится как
# `full`: предмет барьера — совпадение блобов и наличие вердиктов, и от доступности сети он не
# зависит. Барьер, краснеющий от обрыва связи, выключают, а выключенный барьер не проверяет
# ничего. Писателю (`freeze_contract.sh`) то же слово означает отказ, и там это обосновано:
# выдача идентификатора необратима.
#
#   bash scripts/check_contract_frozen.sh            проверить это дерево
#   bash scripts/check_contract_frozen.sh <корень>   проверить другое (так предъявляется красным)
#
# Коды возврата: 0 — замороженное не изменено, 1 — изменено либо объявление вне грамматики,
# 2 — нечем проверить.
set -euo pipefail

# Унаследованные git-переменные подменяют предмет до первой команды: адверсарий предъявил ложное
# ЗЕЛЁНОЕ через `GIT_DIR` и `GIT_WORK_TREE` на механизме 2.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Библиотеки — от СВОЕГО каталога, а не от проверяемого дерева: иначе код барьера приходил бы из
# предмета проверки.
NEXT_ID_LIB=1
# shellcheck disable=SC1091
. "$SELF_DIR/next_id.sh"
# shellcheck disable=SC1091
. "$SELF_DIR/lib_registry.sh"

ROOT="$(cd "${1:-"$SELF_DIR/.."}" && pwd)"

fails=0
ok()   { printf '  ok   %s\n' "$*" >&2; }
bad()  { fails=$((fails + 1)); printf '  FAIL %s\n' "$*" >&2; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

command -v git >/dev/null 2>&1 || skip "нет git — реестр заморозок прочитать нечем"
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 || skip "$ROOT не репозиторий git — реестра заморозок нет"
git -C "$ROOT" rev-parse --verify HEAD >/dev/null 2>&1 || skip "в $ROOT нет ни одного коммита"

g() { git -C "$ROOT" "$@"; }

# ── реестр ────────────────────────────────────────────────────────────────────
state="$(registry_state "$ROOT" 'frozen/')"
case "$state" in
  full|unknown-remote) ;;
  *)
    printf 'ОТКАЗ: реестр заморозок (refs/tags/frozen/*) недоступен: %s\n' "$state" >&2
    printf 'Лечится: %s\n' "$(registry_cure "$state")" >&2
    exit 1
    ;;
esac

# ── предмет: планы и контракты на HEAD ────────────────────────────────────────
mkdir -p "$ROOT/tmp"
TMP="$(mktemp -d "$ROOT/tmp/frozen.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

g ls-tree -r --name-only HEAD -- ':(literal)plans/' ':(literal)contracts/' 2>/dev/null \
  | awk '/\.md$/' | sort > "$TMP/files" || true

# Все теги заморозок — один раз, а не по файлу: иначе N обращений к реестру там, где хватает
# одного, и вердикт зависел бы от того, сколько файлов в дереве.
g for-each-ref --format='%(refname)' 'refs/tags/frozen/' 2>/dev/null | sort > "$TMP/tags" || true

checked=0; drafts=0; frozen=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  dir="${f%%/*}"
  base="${f##*/}"
  # Вложенные пути внутрь plans/ и contracts/ грамматикой не предусмотрены: номер выдаётся на
  # файл, и подкаталог означал бы два артефакта с одним номером.
  if [ "$dir/$base" != "$f" ]; then
    bad "объявление вне грамматики: $f — plans/ и contracts/ не имеют подкаталогов, номер выдаётся на файл"
    continue
  fi
  ARTIFACT_NUMBER=""
  rc=0
  parse_artifact_basename "$base" || rc=$?
  if [ "$rc" -ne 0 ] || [ -z "${ARTIFACT_NUMBER:-}" ]; then
    bad "объявление вне грамматики: $f — имя обязано быть NNN-<slug>.md (ровно три цифры, дефис, не-цифра)"
    continue
  fi
  checked=$((checked + 1))
  NNN="$(printf '%03d' "$ARTIFACT_NUMBER")"

  vmax=0
  while IFS= read -r t; do
    [ -n "$t" ] || continue
    if [[ "$t" =~ ^refs/tags/frozen/${dir}/${NNN}/([0-9]+)$ ]]; then
      k=$((10#${BASH_REMATCH[1]}))
      [ "$k" -gt "$vmax" ] && vmax="$k"
    fi
  done < "$TMP/tags"

  if [ "$vmax" -eq 0 ]; then
    drafts=$((drafts + 1))
    ok "$f — черновик, не заморожен"
    continue
  fi
  frozen=$((frozen + 1))

  # Побайтово: сравниваются ИМЕНА БЛОБОВ, а не текст. Текстовое сравнение зависело бы от локали и
  # переводов строк, а имя блоба есть sha1 содержимого — та же мера, которой пользуется сам git.
  head_blob="$(g rev-parse --verify --quiet "HEAD:$f" || true)"
  tag_blob="$(g rev-parse --verify --quiet "refs/tags/frozen/$dir/$NNN/$vmax^{commit}:$f" || true)"
  if [ -z "$tag_blob" ]; then
    bad "$f заморожен как v$vmax, но в коммите заморозки этого файла нет — тег поставлен не на то состояние"
  elif [ "$head_blob" != "$tag_blob" ]; then
    bad "$f изменён без новой заморозки: на HEAD блоб $head_blob, в заморозке v$vmax — $tag_blob. Выход: новый вердикт критика v$((vmax + 1)), freeze_contract.sh и строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ: в изменяющем коммите"
  fi

  # Каждая версия от 1 до vmax обязана иметь разрешающий вердикт. Пропуск версии — тоже отказ:
  # реестр без v2 при существующем v3 означает тег, поставленный мимо писателя.
  #
  # Счётчик отказов по ЭТОМУ файлу нужен, чтобы зелёное было названо: барьер, молча проходящий по
  # замороженному файлу, не даёт доказательств, ЧТО он проверил. Молчаливое зелёное неотличимо от
  # барьера, который файл вовсе не увидел, — а именно это и есть класс пусто-зелёного.
  local_fails_before="$fails"
  k=1
  while [ "$k" -le "$vmax" ]; do
    if ! grep -qxF "refs/tags/frozen/$dir/$NNN/$k" "$TMP/tags"; then
      bad "$f: версия v$k пропущена в реестре при существующей v$vmax — тег поставлен мимо freeze_contract.sh"
      k=$((k + 1))
      continue
    fi
    verdict="verdicts/critic/${dir}-${NNN}-v${k}.md"
    body="$(g cat-file -p "HEAD:$verdict" 2>/dev/null || true)"
    if [ -z "$body" ]; then
      bad "$f: заморозка v$k без вердикта критика — на HEAD нет $verdict"
    else
      first="$(printf '%s\n' "$body" | sed -n 1p | tr -d '\r')"
      first="${first#"${first%%[![:space:]]*}"}"
      first="${first%"${first##*[![:space:]]}"}"
      if [ "$first" != accept ]; then
        bad "$f: заморозка v$k лежит поверх вердикта, который её не разрешил: первая строка «$first» в $verdict"
      fi
    fi
    k=$((k + 1))
  done
  if [ "$fails" -eq "$local_fails_before" ] && [ "$head_blob" = "$tag_blob" ]; then
    ok "$f — заморожен v$vmax, блоб совпадает побайтово, вердикты v1..v$vmax разрешают"
  fi
done < "$TMP/files"

printf '\nпланов и контрактов на HEAD: %d · черновиков: %d · заморожено: %d · реестр: %s\n' \
  "$checked" "$drafts" "$frozen" "$state" >&2

[ "$fails" -eq 0 ] || exit 1
