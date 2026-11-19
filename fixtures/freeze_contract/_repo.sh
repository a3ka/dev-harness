# Каркас подставного репозитория для фикстур `freeze_contract`.
#
# Имя НЕ `case_*.sh` намеренно: сам он фикстурой не считается и в прогон не попадает.
#
# `make_repo <каталог>` собирает дерево, на котором барьер обязан быть ЗЕЛЁНЫМ: контракт на HEAD,
# вердикт критика v1 с первой строкой `accept`, реестр заморозок пуст (законное начальное
# состояние). Зелёная основа обязательна — её предъявляет положительный контроль каждой фикстуры,
# иначе вечно-красный барьер неотличим от работающего.
#
# ГЕРМЕТИЧНОСТЬ обязательна: адверсарий предъявил измерением, что глобальная `commit.gpgsign` без
# ключа роняет построение истории кодом 128, а `core.hooksPath` — кодом 1 без текста. Тогда
# фикстура краснела бы от чужого конфига, а не от внесённой поломки, и мера врала бы о предмете.
#
# Локальная идентичность задаётся ФАЙЛОМ конфига дерева, а не только `-c`: сам барьер зовёт
# `git tag -a` без `-c`, и в герметичном окружении без локального `user.name` он падает с
# `empty ident name` — тогда проба валит барьер своим дефектом, а не предметом (запись Н-12).
#
# ПАРИТЕТ CI ВАКУУМНО обязателен по той же причине, что и герметичность выше (контракт 043,
# freeze-time backstop): `freeze_contract.sh` теперь зовёт precision-гейт (`check_precision_gate.sh`)
# на КАЖДОЙ попытке заморозки, включая заморозки НА ЭТОМ toy-дереве, а гейт последней задачей (в)
# зовёт `verify_ci_parity.sh` и трактует ЛЮБОЙ его код возврата, отличный от нуля — в т.ч. rc=2
# «нечем проверить» — как красный (`die`), который `freeze_contract.sh` в свою очередь трактует
# fail-closed (норма 036 §Freeze). Toy-дерево без `.github/`, `package.json` и
# `config/ci_parity_exceptions.txt` получало rc=2 на ПЕРВОЙ же попытке заморозки — до любой
# порчи, внесённой самой фикстурой, — то есть проваливало положительный контроль отсутствием
# постороннего файла, а не предметом фикстуры. Три записи ниже делают сверку ВАКУУМНОЙ (ноль
# workflow-команд, ноль скриптов приёмки, ноль исключений — сверять нечего ни с одной стороны),
# а не ослабляют её: `verify_ci_parity.sh` возвращает rc=0 честно, потому что обеим сторонам
# сверки нечего предъявить друг другу.
g() {
  local r="$1"; shift
  # ТОЛЕРАНТНЫЙ `remote add <имя> <url>` (078): каркас дарит toy-дереву bare-origin
  # (make_repo ниже), а замороженная клетка case_reestr_neizvesten вешает СВОЙ сломанный
  # origin ПОВЕРХ подаренного. Строгий `git remote add` на существующем имени умирает
  # кодом 3, под `set -euo pipefail` клетки — ДО красной пробы, и анти-плацебо видит
  # «красное не предъявлено» вместо предмета. Каркас обязан давать ПЕРЕЗАПИСЫВАТЬ
  # подаренный origin: add на существующем имени = set-url. Семья знает только форму
  # `remote add <имя> <url>` без опций; прочие вызовы проходят без изменений.
  if [ "$1" = remote ] && [ "${2:-}" = add ] && [ "$#" -ge 4 ] \
     && GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
        git -C "$r" remote get-url "$3" >/dev/null 2>&1; then
    set -- remote set-url "$3" "$4"
  fi
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" \
      -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      -c init.defaultBranch=main "$@"
}
commit_all() { g "$1" add -A; g "$1" commit -q -m "$2"; }

# Вердикт критика с заданной первой строкой: три исхода грамматики разводятся отдельными
# фикстурами, потому что у барьера у них РАЗНЫЕ диагнозы.
put_verdict_nnn() {  # <корень> <NNN> <версия> <первая строка>
  local r="$1" nnn="$2" v="$3" first="$4"
  mkdir -p "$r/verdicts/critic"
  printf '%s\nтело вердикта\n' "$first" > "$r/verdicts/critic/contracts-$nnn-v${v}.md"
}

put_verdict() {  # <корень> <версия> <первая строка>
  put_verdict_nnn "$1" 001 "$2" "$3"
}

make_repo() {
  local r="$1"
  mkdir -p "$r/contracts" "$r/verdicts/critic" "$r/tmp" "$r/.github/workflows" "$r/config"
  printf 'предмет, критерий готовности, РАБОТА НЕ РАЗДАЁТСЯ: кодификация\n' > "$r/contracts/001-x.md"
  put_verdict "$r" 1 accept
  printf 'name: ci\non: push\njobs: {}\n' > "$r/.github/workflows/ci.yml"
  printf '{"scripts": {}}\n' > "$r/package.json"
  : > "$r/config/ci_parity_exceptions.txt"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.name Фикстура
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.email fixture@local
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config commit.gpgsign false
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config core.hooksPath /dev/null
  commit_all "$r" 'основание'
  # bare-origin (контракт 078): лимит активных контрактов в freeze_contract.sh судит
  # по живому ls-remote origin, НЕ настроенный remote — fail-closed отказ «авторитет
  # недоступен»; toy без origin падал бы на ПЕРВОЙ заморозке отсутствием окружения,
  # а не предметом фикстуры — тот же класс, что вакуумный CI-паритет 043 выше: каркас
  # догоняет гейт-зависимость, суждения не меняются (активных на origin нет — 0 < 2).
  # Подаренный origin клетка обязана мочь ПЕРЕЗАПИСАТЬ своим сломанным (наблюдает
  # unknown-remote) — потому g() выше делает `remote add` толерантным (set-url).
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q --bare "${r%/}-origin.git"
  git -C "${r%/}-origin.git" symbolic-ref HEAD refs/heads/main
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" remote add origin "${r%/}-origin.git"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" -c commit.gpgsign=false push -q origin main
}

# [154] Старый предмет: тег id/CONTRACT/<NNN> на старте предмета и маркер
# границы (пустой коммит после него) — прежний §6в действует дословно.
old_subject() { # <репо> <NNN>
  local r="$1" nnn="$2"
  if ! git -C "$r" rev-parse --verify --quiet "refs/tags/id/CONTRACT/$nnn" >/dev/null; then
    git -C "$r" tag "id/CONTRACT/$nnn"
    g "$r" commit -q --allow-empty -m 'граница 154'
  fi
}

# [154] Счётчик платных вызовов — сосед двери (scripts/zamok_predmeta.sh).
# Проверка анти-плацебо запускает КОПИЮ барьера в своём каталоге, поэтому соседа
# копирует фикстура; прямая копия барьера уже лежит рядом с ним.
lock154() {
  [ -n "${REPO:-}" ] || return 0
  [ -f "$REPO/scripts/zamok_predmeta.sh" ] || return 0
  mkdir -p "$WORK/scripts"
  cp "$REPO/scripts/zamok_predmeta.sh" "$WORK/scripts/zamok_predmeta.sh"
}

# [154] toy-корень состояния станции: журнал учёта платных START роли critic.
# state154 <репо> <NNN> <число платных сессий> [санкция-на-3] [арбитраж-на-4] [слово-владельца-на-4]
# Печатает путь корня состояния. Позиции 1–2 свободны; позиция 3+ требует
# адресного основания, доказанного ЗАКОММИЧЕННОЙ строкой «БЮДЖЕТ-154: …»
# в basisCommit:basisPath: санкции — в HANDOFF.md, арбитраж — в
# verdicts/arbitration/budget154.md. Выбранный источник по позиции — отдельный
# факт журнала (ISPOLZOVANO); сам по себе он позицию не открывает.
state154() {
  local r="$1" nnn="$2" n="$3" third="${4:-0}" arb="${5:-0}" owner4="${6:-0}"
  local st rid obj i pos src dokaz
  st="$(dirname "$r")/state154-$nnn"
  mkdir -p "$st"
  rid="$(basename "$(git -C "$r" remote get-url origin 2>/dev/null || printf '%s' "$r")")"
  rid="${rid%.git}"
  : > "$st/uchet.jsonl"
  i=1
  while [ "$i" -le "$n" ]; do
    obj="$(printf '%040x' "$i")"
    printf '{"t":"START","repoId":"%s","subjectId":"%s","group":"harness","holder":"Crit%d","klass":"sudja","rol":"critic","object":"%s","worktree":"-","branch":"-","at":"2020-01-01T00:00:00Z"}\n' \
      "$rid" "$nnn" "$i" "$obj" >> "$st/uchet.jsonl"
    i=$((i + 1))
  done
  dokaz=""
  pos=3
  while [ "$pos" -le "$n" ]; do
    src=vladelec
    [ "$pos" = 3 ] && src=orchestrator
    if [ "$pos" = 4 ]; then
      [ "$arb" = 1 ] && src=arbitrazh
      [ "$owner4" = 1 ] && src=vladelec
    fi
    obj="$(printf '%040x' "$pos")"
    printf '{"t":"ISPOLZOVANO","repoId":"%s","subjectId":"%s","object":"%s","nomer":%s,"istochnik":"%s","at":"2020-01-01T00:00:00Z"}\n' \
      "$rid" "$nnn" "$obj" "$pos" "$src" >> "$st/uchet.jsonl"
    dokaz="${dokaz}БЮДЖЕТ-154: {\"istochnik\":\"$src\",\"nomer\":$pos,\"object\":\"$obj\",\"repoId\":\"$rid\",\"subjectId\":\"$nnn\",\"t\":\"ISPOLZOVANO\"}
"
    if [ "$pos" = 3 ] && [ "$third" = 1 ]; then
      printf '{"t":"SANKTSIYA","repoId":"%s","subjectId":"%s","object":"%s","nomer":3,"istochnik":"orchestrator","at":"2020-01-01T00:00:00Z"}\n' \
        "$rid" "$nnn" "$obj" >> "$st/uchet.jsonl"
      dokaz="${dokaz}БЮДЖЕТ-154: {\"istochnik\":\"orchestrator\",\"nomer\":3,\"object\":\"$obj\",\"repoId\":\"$rid\",\"subjectId\":\"$nnn\",\"t\":\"SANKTSIYA\"}
"
    fi
    if [ "$pos" = 4 ] && [ "$owner4" = 1 ]; then
      printf '{"t":"SANKTSIYA","repoId":"%s","subjectId":"%s","object":"%s","nomer":4,"istochnik":"vladelec","at":"2020-01-01T00:00:00Z"}\n' \
        "$rid" "$nnn" "$obj" >> "$st/uchet.jsonl"
      dokaz="${dokaz}БЮДЖЕТ-154: {\"istochnik\":\"vladelec\",\"nomer\":4,\"object\":\"$obj\",\"repoId\":\"$rid\",\"subjectId\":\"$nnn\",\"t\":\"SANKTSIYA\"}
"
    fi
    pos=$((pos + 1))
  done
  # Основание — закоммиченные строки: документ санкций HANDOFF.md, документ
  # арбитража — verdicts/arbitration/budget154.md.
  if [ -n "$dokaz" ]; then
    printf '%s' "$dokaz" >> "$r/HANDOFF.md"
    commit_all "$r" 'основание бюджета критика: санкции'
  fi
  local sha_sank=""
  [ -n "$dokaz" ] && sha_sank="$(git -C "$r" rev-parse HEAD)"
  if [ "$arb" = 1 ]; then
    mkdir -p "$r/verdicts/arbitration"
    printf 'РЕШЕНИЕ (контракт %s)\nБЮДЖЕТ-154: {"repoId":"%s","subjectId":"%s","t":"ARBITRAZH"}\n' \
      "$nnn" "$rid" "$nnn" > "$r/verdicts/arbitration/budget154.md"
    commit_all "$r" 'основание бюджета критика: арбитраж'
    printf '{"t":"ARBITRAZH","repoId":"%s","subjectId":"%s","at":"2020-01-01T00:00:00Z"}\n' \
      "$rid" "$nnn" >> "$st/uchet.jsonl"
  fi
  local sha_arb=""
  [ "$arb" = 1 ] && sha_arb="$(git -C "$r" rev-parse HEAD)"
  # проставить основание в строки журнала
  local tmp="$st/uchet.jsonl.tmp"
  while IFS= read -r line; do
    case "$line" in
      *'"t":"SANKTSIYA"'*|*'"t":"ISPOLZOVANO"'*)
        printf '%s,"basisCommit":"%s","basisPath":"HANDOFF.md"}\n' "${line%?}" "$sha_sank" >> "$tmp" ;;
      *'"t":"ARBITRAZH"'*)
        printf '%s,"basisCommit":"%s","basisPath":"verdicts/arbitration/budget154.md"}\n' "${line%?}" "$sha_arb" >> "$tmp" ;;
      *) printf '%s\n' "$line" >> "$tmp" ;;
    esac
  done < "$st/uchet.jsonl"
  mv "$tmp" "$st/uchet.jsonl"
  printf '%s' "$st"
}
