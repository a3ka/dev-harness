#!/usr/bin/env bash
# Исполнитель коммитит только в свою зону. Зона объявляется в ЗАМОРОЖЕННОМ контракте, а не в
# задании и не в переписке.
#
# Зачем вообще: `implementer` существует для параллелизма и границ, а не для ловли дефектов
# (измерено: на барьере в 200 строк разделение «спека отдельно, реализация отдельно» дефектов не
# ловит). Границу без механизма исполнитель расширяет молча — «попутно поправил, что попалось», — и
# остаётся дифф, который нечем ревьюить.
#
# ГРАММАТИКА, литерал, первая колонка строки в контракте:
#
#   ЗОНА <имя-автора>: <путь> [<путь>…]
#   РАБОТА НЕ РАЗДАЁТСЯ: <непустая причина>
#
# `<имя-автора>` — git `user.name` агента: агенты коммитят под своими именами (измерено в истории:
# `parity-fixes2`, `IdsFixes2`, `critic`). `<путь>` — каталог с завершающим `/` либо точный файл;
# относительный, без `* ? [`, без `..`, без ведущего `/`. Проверка пути — ЕДИНСТВЕННОЙ реализацией
# `path_prefix_valid` в `lib_roles.sh`, той же, что проверяет `verdict:` у ролей.
#
# ОДНО ИЗ ДВУХ ОБЪЯВЛЕНИЙ ОБЯЗАТЕЛЬНО, И МОЛЧАНИЕ НЕ ГОДИТСЯ. Контракт, который раздаётся, несёт
# `ЗОНА`-строки; контракт, который кодифицирует уже действующее соглашение, несёт
# `РАБОТА НЕ РАЗДАЁТСЯ:` с причиной. Отсутствие обеих — отказ: иначе «зон нет» и «зоны забыли»
# выглядят одинаково, а это разные предметы (правило 7 нормы). Так требование, которое у критика
# было когнитивным, стало механическим.
#
# ЗОНЫ ЧИТАЮТСЯ ИЗ БЛОБА ВЫСШЕЙ ЗАМОРОЗКИ, а не из рабочего дерева: иначе правка файла расширяла бы
# зону без заморозки, то есть исполнитель выдавал бы себе права сам. Черновик зон не даёт.
#
# ДИАПАЗОН — от ПЕРВОЙ заморозки контракта (`frozen/contracts/<NNN>/1..HEAD`), не от высшей: правка
# контракта версией v2 иначе стирала бы зону задним числом вместе с уже проверенными коммитами.
# Зона автора — ОБЪЕДИНЕНИЕ путей, объявленных этому имени во ВСЕХ замороженных контрактах:
# пересечение было бы бессмыслицей, два контракта дают человеку две работы, а не одну общую.
#
# НЕОБЪЯВЛЕННЫЕ АВТОРЫ НЕ ПРОВЕРЯЮТСЯ — владелец и прошлые сессии. Это цена того, чтобы гейт не
# краснел на истории, которую уже нельзя исправить.
#
# ОСТАТОЧНЫЙ РИСК, помечен `cognitive-only`: `user.name` — не удостоверение. Объявленный исполнитель
# может выйти из зоны, назвавшись новым именем, и барьер этого не увидит по построению. Держится
# тремя вещами: имя в `ЗОНА`-строке пишет АРХИТЕКТОР в контракте, а не исполнитель себе; смена имени
# видна в `git log --format='%an %s'` и входит в область ревьюера; исполнитель коммитит в основной
# репозиторий, то есть его коммиты пересматриваются на приёмке пачки. Ужесточение — подписанные
# коммиты со сверкой ключа и имени — включается словом владельца.
#
# Merge-коммиты пропускаются; их содержимое — предмет ревью.
#
# РЕФАКТОРИНГ (контракт 016, срез 1): чтение замороженных контрактов и ЗОНА-строк ВЫНЕСЕНО в
# `scripts/lib_zones.sh` — единый читатель формата (прецедент lib_roles/lib_registry). Этот
# барьер остаётся ЗАКОММИЧЕННЫМ по поведению: тексты bad()/ok() — те же, логика СПАСЕНО, фильтр
# процессных файлов и финальный отчёт — на месте; меняется только способ получения zones_scoped.
#
#   bash scripts/check_zones.sh            проверить это дерево
#   bash scripts/check_zones.sh <корень>   проверить другое (так предъявляется красным)
#
# Коды возврата: 0 — выходов за зону нет либо зон не объявлено, 1 — выход за зону или объявление
# вне грамматики, 2 — нечем проверить.
set -euo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEXT_ID_LIB=1
# shellcheck disable=SC1091
. "$SELF_DIR/next_id.sh"
# shellcheck disable=SC1091
. "$SELF_DIR/lib_roles.sh"
# shellcheck disable=SC1091
. "$SELF_DIR/lib_zones.sh"

ROOT="$(cd "${1:-"$SELF_DIR/.."}" && pwd)"

fails=0
ok()   { printf '  ok   %s\n' "$*" >&2; }
bad()  { fails=$((fails + 1)); printf '  FAIL %s\n' "$*" >&2; }
# shellcheck disable=SC1091
. "$SELF_DIR/lib_registry.sh"

command -v git >/dev/null 2>&1 || skip "нет git — историю коммитов прочитать нечем"
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 || skip "$ROOT не репозиторий git"
git -C "$ROOT" rev-parse --verify HEAD >/dev/null 2>&1 || skip "в $ROOT нет ни одного коммита"

g() { git -C "$ROOT" "$@"; }

# Чтение зон через ЕДИНСТВЕННУЮ реализацию lib_zones.sh (контракт 016, срез 1).
# registry_state уже проверен внутри zones_load; здесь его повторять не нужно.
mkdir -p "$ROOT/tmp"
TMP="$(mktemp -d "$ROOT/tmp/zones.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

# Реестр заморозок проверяется ДО zones_load: на shallow/missing-клоне выдаём rc=1
# с НАЗВАННОЙ причиной (замороженная ветвь), а не rc=2 NOT_IMPLEMENTED — пусто-зелёный
# гейт хуже красного (прецедент case_reestr_nedostupen).
state="$(registry_state "$ROOT" 'frozen/')"
case "$state" in
  full|unknown-remote) ;;
  *)
    printf 'ОТКАЗ: реестр заморозок (refs/tags/frozen/*) недоступен: %s\n' "$state" >&2
    printf 'Лечится: %s\n' "$(registry_cure "$state")" >&2
    printf 'Без реестра зоны не читаются, и барьер стал бы пусто-зелёным.\n' >&2
    exit 1
    ;;
esac

# Чтение зон через ЕДИНСТВЕННУЮ реализацию lib_zones.sh (контракт 016, срез 1).
out="$(zones_load "$ROOT" 2>/dev/null)" || {
  printf 'NOT_IMPLEMENTED: реестр заморозок недоступен\n' >&2; exit 2; }
cp "$out/zones_scoped"    "$TMP/zones_scoped"
cp "$out/zones_violations" "$TMP/zones_violations"
cp "$out/ranges"          "$TMP/ranges"
cp "$out/contracts_list"  "$TMP/contracts_list"
contracts=$(wc -l < "$TMP/contracts_list" | tr -d ' ')
: > "$TMP/saved"
: > "$TMP/process_excluded"
# Список тегов refs/tags/frozen/contracts/ — для СПАСЕНО-логики ниже.
g for-each-ref --format='%(refname)' 'refs/tags/frozen/contracts/' 2>/dev/null | sort > "$TMP/tags" || true
# контракт, файл, причина, автор, путь, сырая_строка. awk парсит с FS=\0
# (внутри строки табуляция не рвёт поле, как и в `read -d '' nnn file ...`).
# Чтение NUL-разделённых нарушений ЗОНА. Каждая запись — 6 полей, разделённых \0:
# контракт, файл, причина, автор, путь, сырая_строка. awk парсит с FS=\0
# (внутри строки табуляция не рвёт поле, как и в `read -d '' nnn file ...`).
awk -v FS='\0' 'NF >= 3 {
  reason = $3
  file = $2; author = $4; path = $5; raw_line = $6
  if (reason == "bad_author")
    printf("строка ЗОНА вне объявленной грамматики в %s: «%s» — нужно «ЗОНА <имя-автора>: <путь> [<путь>…]»\n", file, raw_line)
  else if (reason == "tab_in_author")
    printf("строка ЗОНА вне объявленной грамматики в %s: имя автора «%s» содержит табуляцию — имя сериализуется как TSV-поле и разделитель в нём не живёт\n", file, author)
  else if (reason == "no_paths")
    printf("строка ЗОНА вне объявленной грамматики в %s: «%s» — у автора «%s» не назван ни один путь\n", file, raw_line, author)
  else if (reason == "quote_in_path")
    printf("строка ЗОНА вне объявленной грамматики в %s: путь «%s» у автора «%s» содержит кавычку — пути разделены пробелами, кавычек грамматика не несёт\n", file, path, author)
  else if (reason == "bad_prefix")
    printf("строка ЗОНА вне объявленной грамматики в %s: путь «%s» у автора «%s» — путь обязан быть относительным, без шаблонов, .. и пробелов; каталог завершается /\n", file, path, author)
}' "$TMP/zones_violations" | while IFS= read -r line; do bad "$line"; done
# Зелёное НАЗЫВАЕТСЯ. Сводка зон по контрактам с правильным $file — для отчёта. Замороженная
# ветвь: зелёное должно быть названо, иначе молчаливый барьер неотличим от не видящего файл.
if [ "$fails" -eq 0 ]; then
  while IFS=$'\t' read -r nnn since; do
    [ -n "$nnn" ] || continue
    vmax="$(printf '%s' "$since" | sed -E 's@.*frozen/contracts/[0-9]+/([0-9]+).*@\1@')"
    vmax_tag="refs/tags/frozen/contracts/$nnn/$vmax"
    file="$(g ls-tree -r --name-only "${vmax_tag}^{commit}" -- ':(literal)contracts/' 2>/dev/null \
            | awk -v n="$nnn" 'index($0, "contracts/" n "-") == 1 { print; exit }')"
    [ -n "$file" ] || continue
    awk -F'\t' -v n="$nnn" '$3 == n' "$TMP/zones_scoped" | sort -u \
    | while IFS=$'\t' read -r a p; do
        printf '  ok   %s — зона: %s → %s\n' "$file" "$a" "$p" >&2
      done
  done < "$TMP/ranges"
fi

# РАБОТА НЕ РАЗДАЁТСЯ + СПАСЕНО — замороженная ветвь, остаётся в check_zones. Чтение тела
# контракта остаётся здесь (для сообщений ok() с привязкой к файлу).
while IFS= read -r nnn; do
  [ -n "$nnn" ] || continue
  vmax=0
  while IFS= read -r t; do
    if [[ "$t" =~ ^refs/tags/frozen/contracts/${nnn}/([0-9]+)$ ]]; then
      k=$((10#${BASH_REMATCH[1]}))
      [ "$k" -gt "$vmax" ] && vmax="$k"
    fi
  done < "$TMP/tags"
  [ "$vmax" -gt 0 ] || continue
  file="$(g ls-tree -r --name-only "refs/tags/frozen/contracts/$nnn/$vmax^{commit}" -- ':(literal)contracts/' 2>/dev/null \
          | awk -v n="$nnn" 'index($0, "contracts/" n "-") == 1 { print; exit }')"
  [ -n "$file" ] || continue
  body="$(g cat-file -p "refs/tags/frozen/contracts/$nnn/$vmax^{commit}:$file" 2>/dev/null || true)"

  declared=0
  # Объявлен ли вообще хоть один ЗОНА для этого контракта?
  if awk -F'\t' -v n="$nnn" '$3 == n' "$TMP/zones_scoped" | grep -q .; then declared=1; fi
  # РАБОТА НЕ РАЗДАЁТСЯ
  while IFS= read -r line; do
    declared=1
    reason="${line#РАБОТА НЕ РАЗДАЁТСЯ:}"
    if [ -z "${reason//[[:space:]]/}" ]; then
      bad "строка РАБОТА НЕ РАЗДАЁТСЯ вне объявленной грамматики в $file: причина пуста — объявление без причины неотличимо от опечатки"
    else
      ok "$file — работа не раздаётся:${reason}"
    fi
  done < <(printf '%s\n' "$body" | grep '^РАБОТА НЕ РАЗДАЁТСЯ:' || true)

  # СПАСЕНО — замороженная ветвь. Грамматика контракта 003 v3 (решение арбитража):
  # «СПАСЕНО <автор>: <полные 40-символьные хеши через пробел> — <непустая причина>».
  s_until="HEAD"
  if g rev-parse --verify --quiet "refs/tags/done/contracts/$nnn/1" >/dev/null 2>&1; then
    s_until="refs/tags/done/contracts/$nnn/1"
  fi
  while IFS= read -r line; do
    rest="${line#СПАСЕНО }"
    s_author="${rest%%:*}"
    s_tail="${rest#*:}"
    if [ "$s_author" = "$rest" ] || [ -z "${s_author//[[:space:]]/}" ] || [[ "$s_author" == *$'\t'* ]]; then
      bad "строка СПАСЕНО вне объявленной грамматики в $file: «$line» — нужно «СПАСЕНО <автор>: <полные хеши> — <причина>»"
      continue
    fi
    if ! awk -F'\t' -v a="$s_author" -v n="$nnn" '$1 == a && $3 == n { f=1 } END { exit(f ? 0 : 1) }' "$TMP/zones_scoped"; then
      bad "строка СПАСЕНО вне объявленной грамматики в $file: автор «$s_author» не объявлен ЗОНА-строкой этого контракта"
      continue
    fi
    case "$s_tail" in
      *—*) s_hashes="${s_tail%%—*}"; s_reason="${s_tail#*—}" ;;
      *)   bad "строка СПАСЕНО вне объявленной грамматики в $file: «$line» — нет «— <причина>»"; continue ;;
    esac
    if [ -z "${s_reason//[[:space:]]/}" ]; then
      bad "строка СПАСЕНО вне объявленной грамматики в $file: причина пуста — объявление без причины неотличимо от опечатки"
      continue
    fi
    set -f
    for h in $s_hashes; do
      case "$h" in
        *'"'*) bad "строка СПАСЕНО вне объявленной грамматики в $file: хеш «$h» содержит кавычку" ;;
      esac
      if ! [[ "$h" =~ ^[0-9a-f]{40}$ ]]; then
        bad "строка СПАСЕНО вне объявленной грамматики в $file: «$h» — не полный 40-символьный hex"
        continue
      fi
      if ! g cat-file -e "$h^{commit}" 2>/dev/null; then
        bad "строка СПАСЕНО в $file называет несуществующий коммит «$h»"
        continue
      fi
      g merge-base --is-ancestor "refs/tags/frozen/contracts/$nnn/1" "$h" 2>/dev/null \
        && g merge-base --is-ancestor "$h" "$s_until" 2>/dev/null || {
          bad "строка СПАСЕНО в $file называет коммит «$h» вне диапазона контракта (frozen/contracts/$nnn/1..$s_until)"
          continue
        }
      printf '%s\t%s\t%s\n' "$s_author" "$h" "$nnn" >> "$TMP/saved"
    done
    set +f
  done < <(printf '%s\n' "$body" | grep '^СПАСЕНО ' || true)
  if [ "$declared" -eq 0 ]; then
    bad "$file: контракт не объявил ни зон, ни отказа от раздачи — нужна строка «ЗОНА <автор>: <путь>» либо «РАБОТА НЕ РАЗДАЁТСЯ: <причина>». Молчание не годится: «зон нет» и «зоны забыли» выглядят одинаково"
  fi
done < "$TMP/contracts_list"

if [ ! -s "$TMP/zones_scoped" ]; then
  printf '\nзамороженных контрактов: %d · зон не объявлено — проверять нечего\n' "$contracts" >&2
  [ "$fails" -eq 0 ] || exit 1
  exit 0
fi

# ── фильтр процессных артефактов (Н-53, контракт 013 §А) ────────────────────────
is_process_file() {
  case "$1" in
    verdicts/*) return 0 ;;
    HANDOFF.md) return 0 ;;
    NABLIUDENIA*.md)
      case "$1" in */*) return 1 ;; esac
      return 0
      ;;
  esac
  return 1
}

# ── обход коммитов в диапазонах ───────────────────────────────────────────────
# Семантика ОТКРЫТОГО окна контракта (контракт 021, ветвь А):
#   судимое множество = прямые не-merge первого-родителя в диапазоне
#   ∪ коммиты, принесённые merge'ями с маркером `land: wip/<NNN>/<author>`
#     в первой строке (%s) — `rev-list <merge>^1..<merge> --no-merges`
#     (тот же родительский примитив, что charter И-7).
#   merge'и с чужим маркером (`wip/<OTHER>/…`) НЕ приносят коммиты в
#   окно N — линейный rev-list --no-merges --reverse уходит (захватывал
#   чужие merge-принесённые, измеренная боль Н-66).
#   Прочие правки логики суда (авторы → зоны → дельта путей) — НЕ здесь.
# draft-признание (контракт 021, ветвь Б / Н-77(б)): коммит с дельтой
#   contracts/<NNN>-<slug>.md и тегом id/CONTRACT/<NNN> на САМОМ коммите —
#   этот путь из суда выводится. Прочие пути того же коммита судятся
#   обычным порядком (тег — не индульгенция на весь коммит).
commits=0; checked=0
while IFS=$'\t' read -r nnn since; do
  [ -n "$nnn" ] || continue
  until="${since#*..}"
  [ "$until" = "$since" ] && until=""
  since="${since%%..*}"
  awk -F'\t' -v n="$nnn" '$3 == n { print $1 }' "$TMP/zones_scoped" | sort -u > "$TMP/authors"
  [ -s "$TMP/authors" ] || continue
  range="$since..HEAD"
  [ -n "$until" ] && range="$since..$until"
  # Линейный rev-list (как раньше) — для контрактов с ЗАКРЫТЫМИ окнами и
  # без чужих wip/<OTHER>/… merge'ей даёт ту же сводку (регресс-инвариант
  # ветви Г; для 017/019 merge'и без `land:` маркера тоже остаются).
  g rev-list --no-merges --reverse "$range" > "$TMP/commits" 2>/dev/null || : > "$TMP/commits"
  # Исключаем коммиты, принесённые ЧУЖИМИ wip-merge'ями (`land: wip/<OTHER>/…`):
  # в последовательной истории таких нет, регресс закрытых контрактов
  # держится; в открытом окне с cross-track касанием они уходят. Merge'и
  # БЕЗ `land:` маркера (admin merge, intra-wip сведение) трактуются как
  # внутренние — НЕ исключаются (та же семантика, что в линейной модели).
  : > "$TMP/exclude"
  g rev-list --merges "$range" 2>/dev/null | while IFS= read -r mc; do
    [ -n "$mc" ] || continue
    msg="$(g log -1 --format=%s "$mc" 2>/dev/null)"
    case "$msg" in
      "land: wip/${nnn}/"*) ;;  # свой merge — НЕ исключаем
      "land: wip/"*) g rev-list --no-merges "${mc}^1..${mc}" 2>/dev/null >> "$TMP/exclude" ;;
    esac
  done
  sort -u "$TMP/exclude" -o "$TMP/exclude"
  if [ -s "$TMP/exclude" ]; then
    comm -23 "$TMP/commits" "$TMP/exclude" > "$TMP/judged"
    mv "$TMP/judged" "$TMP/commits"
  fi
  while IFS= read -r c; do
    [ -n "$c" ] || continue
    commits=$((commits + 1))
    an="$(g log -1 --format='%an' "$c")"
    grep -qxF -- "$an" "$TMP/authors" || continue
    if grep -qxF "$(printf '%s\t%s\t%s' "$an" "$c" "$nnn")" "$TMP/saved"; then
      printf '  ok   контракт %s: коммит %s (%s) — СПАСЕНО, из суда зон выведен\n' "$nnn" "${c:0:8}" "$an" >&2
      continue
    fi
    checked=$((checked + 1))
    # draft-признание (Н-77(б)): коммит с дельтой contracts/<NNN>-<slug>.md
    # и тегом id/CONTRACT/<NNN> на САМОМ коммите — этот путь из суда
    # выводится. Прочие пути того же коммита судятся обычным порядком.
    has_draft_tag=0
    if g tag --points-at "$c" "id/CONTRACT/$nnn" 2>/dev/null \
         | grep -qxF -- "id/CONTRACT/$nnn"; then
      has_draft_tag=1
    fi
    awk -F'\t' -v a="$an" -v n="$nnn" '$1 == a && $3 == n { print $2 }' "$TMP/zones_scoped" | sort -u > "$TMP/mine"
    while IFS= read -r f; do
      [ -n "$f" ] || continue
      # draft-признание (Н-77(б)): исключаем contracts/<NNN>-<slug>.md
      # если на коммите стоит тег id/CONTRACT/<NNN>. Прочие пути того же
      # коммита идут обычным порядком — тег не индульгенция на весь коммит.
      if [ "$has_draft_tag" -eq 1 ] && [ "${f%%/*}" = "contracts" ] \
         && [ "${f#contracts/$nnn-}" != "$f" ]; then
        continue
      fi
      if is_process_file "$f"; then
        printf '%s\n' "$f" >> "$TMP/process_excluded"
        continue
      fi
      inside=1
      while IFS= read -r p; do
        case "$p" in
          */) case "$f" in "$p"*) inside=0; break ;; esac ;;
          *)  [ "$f" = "$p" ] && { inside=0; break; } ;;
        esac
      done < "$TMP/mine"
      [ "$inside" -eq 0 ] || bad "коммит вне зоны: $an ${c:0:8} $f — зона контракта $nnn: $(tr '\n' ' ' < "$TMP/mine")"
    done < <(g diff-tree -r --no-commit-id --name-only --no-renames "$c")
  done < "$TMP/commits"
done < "$TMP/ranges"

# Н-53: сводная строка называет исключённое СПИСКОМ.
process_list="$(tr '\n' ' ' < "$TMP/process_excluded" | sed 's/[[:space:]]*$//')"
printf '\nпроцессных вне суда:%s\n' "${process_list:+ $process_list}" >&2

printf '\nзамороженных контрактов: %d · объявленных авторов: %d · коммитов в диапазонах: %d · проверено по зонам: %d\n' \
  "$contracts" "$(wc -l < "$TMP/authors" 2>/dev/null | tr -d ' ')" "$commits" "$checked" >&2

[ "$fails" -eq 0 ] || exit 1
