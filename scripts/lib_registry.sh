# НЕ БАРЬЕР: библиотека, а не гейт. Вердикт кодом возврата выносит тот, кто её подключил;
# сама она только РАЗЛИЧАЕТ состояние реестра тегов и печатает одно слово. Классификация
# объявлена явно, потому что `scripts/verify_antiplacebo.sh` требует фикстуру от каждого барьера
# и не догадывается: файл без объявленной роли — отказ.
#
# ЕДИНСТВЕННАЯ реализация вопроса «полон ли реестр тегов». Заведена по плану 007: у реестра
# ПЯТЬ потребителей, и они называются поимённо, а не числом — `check_ids.sh`,
# `freeze_contract.sh` (единственный ПИСАТЕЛЬ), `check_contract_frozen.sh`, `check_charter.sh`,
# `check_zones.sh`. Прежняя редакция плана писала «четыре потребителя», склеивая писателя и
# читателя заморозки в один пункт, — и ровно на этой склейке жил дефект «два смысла v1».
#
# Второй разбор одного предмета расходится молча: в этом репозитории измерено трижды (разбор
# имени артефакта, грамматика поля `verdict:`, теперь реестр).
#
#   registry_state <корень> <префикс>
#
# Префикс — `id/`, `frozen/` либо `ustav/` (без `refs/tags/`). Печатает ровно одно слово:
#
#   full            сравнили и локальное включает удалённое, либо сравнивать не с чем
#   shallow         история усечена: обход по тегам подтверждал бы инвариант сам собой
#   missing-remote  на origin есть имена, которых нет локально — клон был без --tags
#   unknown-remote  origin объявлен, но недоступен: сравнить НЕ УДАЛОСЬ
#
# ЧЕТВЁРТОЕ СЛОВО ЗАВЕДЕНО НАХОДКОЙ КРИТИКА (круг 4). Прежняя редакция выдавала недоступный
# origin за `full`, и тогда `freeze_contract.sh` в клоне без тегов при существующем удалённом
# `frozen/<каталог>/<NNN>/1` вычислял ЛОКАЛЬНЫЙ `v1` — второй смысл одного идентификатора,
# вопреки правилу 5 нормы. Библиотека обязана различать «сравнили и совпало» от «сравнить не
# смогли», потому что решают по-разному:
#
#   читатели  → `unknown-remote` годится как `full`: барьер, краснеющий от обрыва связи, будет
#               выключен, а его предмет (совпадение блобов, наличие вердиктов) от сети не зависит;
#   ПИСАТЕЛЬ  → отказ: выдача идентификатора необратима. Ошибившийся читатель краснеет повторно,
#               ошибившийся писатель оставляет в истории два `v1`, и развести их уже нечем.
#
# СРАВНИВАЮТСЯ МНОЖЕСТВА, А НЕ ИХ МОЩНОСТИ. Тоже находка критика (круг 3) с контрпримером:
# `origin = {1,2}`, локально `{1,3,4}` — удалённого тега `2` локально нет, но количество больше,
# и прежняя мера (унаследованная из `is_registry_complete()` в `check_ids.sh`) объявляла реестр
# полным. Мера считала объём, а предмет — включение. Здесь `comm -23`.
#
# Аннотированные теги приходят от `ls-remote` двумя строками — сам тег и `^{}` для peeled;
# суффикс снимается, иначе сравнение двух множеств врёт вдвое.
#
# ОСТАТОЧНЫЙ РИСК ПИСАТЕЛЯ, помечен `cognitive-only`: состояние «origin нет вовсе» отдаётся
# словом `full`, значит `git remote remove origin` — способ обойти отказ по реестру. Механизмом
# не закрывается: дерево без remote — штатное состояние фикстуры и первого клона, и требовать
# remote значило бы запретить работу в них. Ловец — ревьюер: удаление remote видно в истории
# команд и в штатном воркфлоу немыслимо.

# Герметичность нужна и библиотеке: она зовёт git, а унаследованные переменные подменяют предмет
# до первой команды. Снимается здесь, а не у вызывающего, чтобы не зависеть от его аккуратности.
registry_state() {
  local root="$1" prefix="$2"
  local shallow remote_ok
  local tmp

  [ -n "$root" ] && [ -n "$prefix" ] || { printf 'full\n'; return 0; }

  shallow="$(
    env -u GIT_DIR -u GIT_WORK_TREE -u GIT_INDEX_FILE -u GIT_OBJECT_DIRECTORY \
        -u GIT_ALTERNATE_OBJECT_DIRECTORIES -u GIT_TEMPLATE_DIR \
        GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
        git -C "$root" rev-parse --is-shallow-repository 2>/dev/null || echo false
  )"
  if [ "$shallow" = "true" ]; then
    printf 'shallow\n'
    return 0
  fi

  # Нет origin — сравнивать не с чем, и это законно.
  env -u GIT_DIR -u GIT_WORK_TREE -u GIT_INDEX_FILE -u GIT_OBJECT_DIRECTORY \
      -u GIT_ALTERNATE_OBJECT_DIRECTORIES -u GIT_TEMPLATE_DIR \
      GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
      git -C "$root" remote get-url origin >/dev/null 2>&1 || { printf 'full\n'; return 0; }

  tmp="$(mktemp -d 2>/dev/null)" || { printf 'full\n'; return 0; }

  remote_ok=0
  if env -u GIT_DIR -u GIT_WORK_TREE -u GIT_INDEX_FILE -u GIT_OBJECT_DIRECTORY \
         -u GIT_ALTERNATE_OBJECT_DIRECTORIES -u GIT_TEMPLATE_DIR \
         GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
         git -C "$root" ls-remote --tags origin "refs/tags/${prefix}*" > "$tmp/remote.raw" 2>/dev/null
  then
    remote_ok=1
  fi

  if [ "$remote_ok" -eq 0 ]; then
    rm -rf "$tmp"
    printf 'unknown-remote\n'
    return 0
  fi

  awk '{ print $2 }' "$tmp/remote.raw" | sed 's/\^{}$//' | sort -u > "$tmp/remote"
  env -u GIT_DIR -u GIT_WORK_TREE -u GIT_INDEX_FILE -u GIT_OBJECT_DIRECTORY \
      -u GIT_ALTERNATE_OBJECT_DIRECTORIES -u GIT_TEMPLATE_DIR \
      GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
      git -C "$root" for-each-ref --format='%(refname)' "refs/tags/$prefix" 2>/dev/null \
    | sort -u > "$tmp/local"

  # Включение, а не мощность: непустой остаток `comm -23` и есть недостающее локально.
  if [ -s "$tmp/remote" ] && [ -n "$(comm -23 "$tmp/remote" "$tmp/local")" ]; then
    rm -rf "$tmp"
    printf 'missing-remote\n'
    return 0
  fi

  rm -rf "$tmp"
  printf 'full\n'
}

# Лечение печатает ПОТРЕБИТЕЛЬ, но текст один на всех — иначе четыре разных текста об одном
# предмете, и читатель отчёта не поймёт, одно ли это состояние.
registry_cure() {  # <слово> → строка лечения в stdout
  case "$1" in
    shallow)        printf 'выполни fetch --tags --unshallow либо задай fetch-depth: 0 в checkout\n' ;;
    missing-remote) printf 'выполни fetch --tags: clone был без --tags\n' ;;
    unknown-remote) printf 'origin объявлен, но недоступен: проверь сеть и права, затем повтори\n' ;;
    *)              printf 'реестр полон — лечения не требуется\n' ;;
  esac
}
