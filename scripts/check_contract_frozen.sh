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
# Грамматика РАЗРЕШИЛ-ВЛАДЕЛЕЦ и разбор дельты коммита — ИЗ УСТАВА, не копия: второй парсер
# разрешения владельца разъехался бы с первым первым же исключением из грамматики razreshil
# (она заморожена, 065/019/074/080). Библиотечный импорт определяет только функции; их `g` и
# `bad` разрешаются в наши — динамическая область bash.
CHARTER_LIB=1
# shellcheck disable=SC1091
. "$SELF_DIR/check_charter.sh"

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

# ТЕГ РЕЕСТРА — АННОТИРОВАННЫЙ (Н-35: судья поставил лёгкий тег руками мимо писателя).
# freeze_contract.sh — единственный писатель — создаёт тег всегда с причиной в сообщении:
# `git tag -a`. Лёгкий тег сообщения не имеет и механизмом заморозки не создаётся;
# его появление в реестре — след мимо процедуры. Различие механическое: тип объекта
# по ссылке — `tag` для аннотированного, `commit` для лёгкого.
while IFS= read -r t; do
  [ -n "$t" ] || continue
  objtype="$(g cat-file -t "$t" 2>/dev/null || true)"
  if [ -n "$objtype" ] && [ "$objtype" != tag ]; then
    bad "тег $t — лёгкий (объект $objtype, без сообщения-причины): реестр заморозок пишет только freeze_contract.sh (Н-35)"
  fi
done < "$TMP/tags"

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
    # ПРЕДСТОЯЩЕЕ v+1 (слово владельца 2026-10-22 ~21:20, пункт 1 — дефект цикла 130 ×
    # contract-frozen): текст следующей версии УЖЕ в дереве, а тег v+1 публикуется ШТАТНО
    # ПОСЛЕ ленда текста (контракт 130: тег — после текста). До публикации тега дерево
    # проходит, когда одновременно:
    #   (а) на HEAD есть accept-вердикт критика версии v+1 — та же грамматика, что и у
    #       freeze_contract (первая строка `accept`);
    #   (б) КАЖДЫЙ коммит, меняющий текст после заморозки v$vmax, несёт валидную строку
    #       РАЗРЕШИЛ-ВЛАДЕЛЕЦ этого пути — грамматика razreshil из check_charter.sh,
    #       переиспользованная, а не скопированная;
    #   (в) блоб на HEAD равен блобу ЛОКАЛЬНОГО удержания v+1 (refs/frozen-hold/… — то, что
    #       gitw_teg_130.sh hold снял с тега писателя); в CI удержание недостижимо — оно не
    #       покидает машину писателя, — и вместо него судится консистентность дельты: коммиты
    #       текста не меняют ни одного другого файла contracts/*.md и plans/*.md.
    # Без (а)∧(б) отказ прежний ДОСЛОВНО: его текст уже называет выход, и вторая формулировка
    # разводила бы один предмет на два имени.
    vnext=$((vmax + 1))
    verdict_next="verdicts/critic/${dir}-${NNN}-v${vnext}.md"
    first_next="$(printf '%s\n' "$(g cat-file -p "HEAD:$verdict_next" 2>/dev/null || true)" \
      | sed -n 1p | tr -d '\r')"
    first_next="${first_next#"${first_next%%[![:space:]]*}"}"
    first_next="${first_next%"${first_next##*[![:space:]]}"}"

    pred_komity=""
    if [ "$first_next" = accept ]; then
      # (б): разрешение обязано лежать в каждом коммите-носителе текста — как у устава,
      # merge несёт строку в теле merge-коммита, а --diff-merges=first-parent предъявляет
      # evil merge, меняющий текст поверх первого родителя.
      pred_komity="$(g log -s --format=%H --no-renames --diff-merges=first-parent \
        "refs/tags/frozen/$dir/$NNN/$vmax"..HEAD -- "$f" 2>/dev/null || true)"
    fi
    razrechen=0
    if [ -n "$pred_komity" ]; then
      razrechen=1
      while IFS= read -r c; do
        [ -n "$c" ] || continue
        razreshil "$c" "$f" || { razrechen=0; break; }
      done <<<"$pred_komity"
    fi

    if [ "$razrechen" -ne 1 ]; then
      bad "$f изменён без новой заморозки: на HEAD блоб $head_blob, в заморозке v$vmax — $tag_blob. Выход: новый вердикт критика v$((vmax + 1)), freeze_contract.sh и строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ: в изменяющем коммите"
    else
      hold="refs/frozen-hold/$dir/$NNN/$vnext"
      hold_blob="$(g rev-parse --verify --quiet "$hold^{commit}:$f" 2>/dev/null || true)"
      if [ -n "$hold_blob" ]; then
        # (в) локально: удержание писателя — точная мера того, что замораживалось.
        if [ "$hold_blob" = "$head_blob" ]; then
          ok "$f — предстоящее v$vnext: accept-вердикт критика на HEAD, разрешение владельца в коммитах текста, блоб равен локальному удержанию $hold; тег v$vnext публикуется после ленда (контракт 130)"
        else
          bad "$f: предстоящее v$vnext не совпадает с локальным удержанием $hold — на HEAD блоб $head_blob, в удержании $hold_blob; текст ушёл от замороженного"
        fi
      else
        # (в) в CI: удержания нет — судим дельту коммитов текста по уставным семьям.
        soglasno=1; chuzhoj=""
        while IFS= read -r c; do
          [ -n "$c" ] || continue
          while IFS= read -r df; do
            [ -n "$df" ] || continue
            if [ "$df" != "$f" ]; then
              case "$df" in
                contracts/*.md|plans/*.md) soglasno=0; chuzhoj="$df"; break ;;
              esac
            fi
          done < <(charter_diff_paths "$c" "$ROOT")
          [ "$soglasno" -eq 1 ] || break
        done <<<"$pred_komity"
        if [ "$soglasno" -eq 1 ]; then
          ok "$f — предстоящее v$vnext: accept-вердикт критика на HEAD, разрешение владельца в коммитах текста, локальное удержание недостижимо (CI), коммиты текста не трогают других файлов contracts/ и plans/; тег v$vnext публикуется после ленда (контракт 130)"
        else
          bad "$f: предстоящее v$vnext судится только по своему контракту и его вердиктам, но коммит текста меняет ещё и $chuzhoj"
        fi
      fi
    fi
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
