FAIL

## Контрпример: константа вместо `next_id_peek`

Слабая реализация `scripts/next_id.sh` оставляет все инварианты И-1…И-7 и охрану И-6 зелёными, но не вычисляет следующий номер CONTRACT: `next_id_peek` всегда печатает `002`. В контрольном эксперименте в одноразовом клоне я заменил только этот интерфейс константой, сохранив остальные экспортируемые функции и CLI-ветку неизвестного класса.

Прогон против такой реализации завершился rc 0 для всех обязательных scoped-приёмок: семи адресных И-1…И-5/И-7, а также `--scope check_staged`, `check_charter`, `spawn_agent`, `next_id` и `check_hooks`. Положительные контроли фикстур также были зелёными.

При этом репозиторий с замороженным `contracts/019-base.md` и staged `contracts/020-draft.md` под автором `architect` получил rc 1 и `ОТКАЗ: вне зоны: contracts/020-draft.md`. Корректное вычисление максимума по истории обязано вернуть `020` и пропустить этот draft-путь без суда зон. Следовательно, ветвь draft-пуска проверена только для единственного значения `002`, а предмет «следующий свободный номер» не доказан.

Команда воспроизведения контрпримера после установки описанной слабой реализации в одноразовом клоне:

```bash
bash /tmp/dev-harness-adv019/repro-constant-peek.sh
```

Наблюдённый вывод:

```text
check_staged rc=1
judged: contracts/020-draft.md
ОТКАЗ: вне зоны: contracts/020-draft.md
```

Команда проверки, которую слабая реализация проходит:

```bash
bash scripts/verify_antiplacebo.sh /tmp/dev-harness-adv019/repo --scope check_staged/case_ustav_bez_razreshenija
bash scripts/verify_antiplacebo.sh /tmp/dev-harness-adv019/repo --scope check_staged/case_ustav_bez_puti
bash scripts/verify_antiplacebo.sh /tmp/dev-harness-adv019/repo --scope check_staged/case_ustav_bez_priciny
bash scripts/verify_antiplacebo.sh /tmp/dev-harness-adv019/repo --scope check_staged/case_draft_sledujushhij_id
bash scripts/verify_antiplacebo.sh /tmp/dev-harness-adv019/repo --scope check_staged/case_ustav_koltso_zamorozki
bash scripts/verify_antiplacebo.sh /tmp/dev-harness-adv019/repo --scope spawn_agent/case_octal_sdvig_znachenija
bash scripts/verify_antiplacebo.sh /tmp/dev-harness-adv019/repo --scope check_charter/case_merge_delta_bez_razreshenija
bash scripts/verify_antiplacebo.sh /tmp/dev-harness-adv019/repo --scope check_staged
bash scripts/verify_antiplacebo.sh /tmp/dev-harness-adv019/repo --scope check_charter
bash scripts/verify_antiplacebo.sh /tmp/dev-harness-adv019/repo --scope spawn_agent
bash scripts/verify_antiplacebo.sh /tmp/dev-harness-adv019/repo --scope next_id
bash scripts/verify_antiplacebo.sh /tmp/dev-harness-adv019/repo --scope check_hooks
```

## Советы

Добавить в `fixtures/check_staged/case_draft_sledujushhij_id.sh` серийный вход с уже занятым CONTRACT-номером выше `001` (например, `019`) и staged `<max+1>` (`020`); сохранить соседний номер как отрицательный вход. Отдельный scoped-case для `next_id_peek` должен проверять минимум два разных максимума и отсутствие нового `id/CONTRACT/*` тега.

## Контрольные прогоны исходной пачки

До контрольного эксперимента обязательные scoped-прогоны и `bash scripts/check_contract_frozen.sh` на исходном клоне завершились rc 0. `git diff 09ad72b..HEAD --stat -- contracts/ plans/` не вывел изменений замороженного текста.

## Круг 2
FAIL

### Контрпример: `next_id_peek` читает только HEAD

Контрпример круга 1 закрыт: константный стаб `next_id_peek() { printf '002\\n'; }` дал `bash scripts/verify_antiplacebo.sh . --scope check_staged/case_draft_sledujushhij_id` код 1 с именованной причиной `барьер остался зелёным на обманном дереве — красное не предъявлено`. Отклонение на единицу (`021`) дало тот же именованный красный результат.

Однако усиленная фикстура не предъявляет максимум ни из одного источника, кроме файлов CONTRACT на HEAD (источник 3 `next_id_max_for_class`). Слабая реализация ниже вычисляет максимум только этим источником, игнорируя теги выдачи, имена ссылок и достижимую историю. Контрольный эксперимент на этой реализации завершился зелёным: scoped-case `case_draft_sledujushhij_id` вернул rc 0.

Команда воспроизведения в одноразовом клоне:

```bash
repo="${TMPDIR:-/tmp}/dev-harness-adv019k2-repro/repo"
rm -rf "${repo%/repo}"
git clone /home/aka/Documents/dev-harness "$repo"
git -C "$repo" checkout 17bf21d
sed -i '/^next_id_peek()/,/^}/c\
next_id_peek() {\
  local root="$1" max=0 path n\
  while IFS= read -r path; do\
    n="${path#contracts/}"; n="${n%%-*}"\
    case "$n" in [0-9][0-9][0-9]) [ "$((10#$n))" -gt "$max" ] && max=$((10#$n)) ;; esac\
  done < <(git -C "$root" ls-tree -r --name-only HEAD -- contracts/)\
  printf "%03d\\n" "$((max + 1))"\
}' "$repo/scripts/next_id.sh"
(
  cd "$repo"
  bash scripts/verify_antiplacebo.sh . --scope check_staged/case_draft_sledujushhij_id
  printf 'RC_SCOPE=%d\n' "$?"
)
rm -rf "${repo%/repo}"
```

Наблюдённый результат: `RC_SCOPE=0`; раннер предъявил зелёный контроль и повторный красный `вне зоны`, но не построил вход с максимумом в другом источнике. Отдельный прямой контроль с `id/CONTRACT/019`, единственным HEAD-контрактом `001` и staged `contracts/020-draft.md` под `architect` дал на этой слабой реализации rc 1 и `ОТКАЗ: вне зоны: contracts/020-draft.md`, хотя корректный peek обязан назвать `020` и пропустить draft-ветвь.

### Охраны

На честной реализации выполнены: `--scope check_staged` — rc 0 (23/23), `--scope next_id` — rc 0 (1/1), `--scope check_nabludenia` — rc 0 (11/11). `git diff 09ad72b..17bf21d --stat -- contracts/ plans/` не вывел строк.

## Круг 3
FAIL

### Обход: жёсткий порог `019` вместо вычисления максимума

Проверка правки 2 строит четыре серийных источника, но во всех занятый номер одинаков: `019`. Слабый `next_id_peek` распознаёт присутствие только `019` в тегах, именах ссылок, HEAD или достижимой истории и печатает `020`; если `019` отсутствует, он печатает `002`. Он не вычисляет максимум и не обрабатывает иной занятый номер.

После замены только `next_id_peek` на такую реализацию scoped-проверка прошла: `bash scripts/verify_antiplacebo.sh . --scope check_staged/case_draft_sledujushhij_id` завершилась rc 0. При прямом входе с `contracts/018-base.md` на HEAD этот же слабый peek напечатал `002`; честная реализация на том же входе напечатала `019`.

Команда воспроизведения в одноразовом клоне `8b9b4d9` после установки описанного стаба:

```bash
cd /tmp/dev-harness-adv019k3
bash scripts/verify_antiplacebo.sh . --scope check_staged/case_draft_sledujushhij_id
printf 'RC_SCOPE=%d\n' "$?"                 # RC_SCOPE=0
bash repro-hardcoded-019.sh                    # PEEK_FOR_HEAD_018=002
```

Стаб, установленный перед этим прогоном:

```bash
next_id_peek() {
  local root="$1"
  if git -C "$root" for-each-ref --format='%(refname:short)' refs/tags refs/heads refs/remotes | grep -q '019' \
     || git -C "$root" ls-tree -r --name-only HEAD -- contracts/ | grep -q '^contracts/019-' \
     || git -C "$root" log --all --diff-filter=A --name-only --format= | grep -q '^contracts/019-'; then
    printf '020\n'
  else
    printf '002\n'
  fi
}
```

Это повтор причины, предмет на арбитра.

### Контроли и охраны

На честной реализации `--scope check_staged` завершился rc 0 (23/23), `--scope next_id` — rc 0 (1/1), `--scope check_nabludenia` — rc 0 (11/11). `git diff 09ad72b..8b9b4d9 --stat -- contracts/ plans/` не вывел строк.

Обязательные прежние стабы были пойманы именованно: head-only, константа `002` и off-by-one `021` дали rc 1 с `барьер остался зелёным на обманном дереве — красное не предъявлено`. Две новые вариации по источникам кода — peek только по `refs/tags/id/CONTRACT/*` и только по `refs/heads`/`refs/remotes` — также дали rc 1 с той же причиной. После восстановления честной реализации адресный scoped-case завершился rc 0; на прямом входе `contracts/018-base.md` честный peek напечатал `019`.

## Круг 4
FAIL

### Контрпример: источник 2 без `refs/remotes`

Слабая реализация не читает удалённые ссылки в источнике 2: в единственной строке перечисления `next_id_max_for_class` аргументы `refs/heads refs/remotes` заменены на `refs/heads`. Это не зависит от литералов фикстуры: в подстановках `137` и `482` стаб прошёл адресный scoped-case с rc 0. Следовательно, он константно-инвариантен по критерию арбитража.

При этом в отдельном репозитории единственной занятой записью была `refs/remotes/origin/wip/137/only-remote`. Честный `next_id_peek <repo> CONTRACT` напечатал `138`; стаб напечатал `001` с rc 0. Удалённая ссылка не участвует в вычислении максимума, хотя входит в источник 2 контракта.

Воспроизведение в одноразовом клоне редакции `1cc6b27`:

```bash
cp scripts/next_id.sh /tmp/adv019k4-next_id.sh
sed -i 's/refs\/heads refs\/remotes 2>\/dev\/null || true/refs\/heads 2>\/dev\/null || true/' scripts/next_id.sh
for n in 137 482; do
  CHECK_STAGED_ZANJATYJ_NOMER="$n" \
    bash scripts/verify_antiplacebo.sh . --scope check_staged/case_draft_sledujushhij_id
  printf 'NO_REMOTES_%s_RC=%d\n' "$n" "$?"
done
repo=/tmp/adv019k4-remote-ref
rm -rf "$repo"
git init -q -b main "$repo"
git -C "$repo" -c user.name=fixture -c user.email=fixture@example.invalid commit --allow-empty -qm init
git -C "$repo" update-ref refs/remotes/origin/wip/137/only-remote HEAD
NEXT_ID_LIB=1 bash -c 'source scripts/next_id.sh; next_id_peek "$1" CONTRACT' _ "$repo"
printf 'NO_REMOTES_REMOTE_ONLY_RC=%d\n' "$?"
cp /tmp/adv019k4-next_id.sh scripts/next_id.sh
rm -rf "$repo"
```

Наблюдение: `NO_REMOTES_137_RC=0`, `NO_REMOTES_482_RC=0`, затем `001` и `NO_REMOTES_REMOTE_ONLY_RC=0`. Контроль без подмены на том же удалённом ref напечатал `138`.

### Обязательные контроли

* Честная реализация: адресный scoped-case завершился rc 0 без параметра (`019`) и с `CHECK_STAGED_ZANJATYJ_NOMER=137` и `=482`.
* Константа `002`, head-only и off-by-one (`max+2`) дали rc 1 с именованным результатом раннера `барьер остался зелёным на обманном дереве — красное не предъявлено`.
* Табличный стаб круга 3 на литерале `019` сохранил rc 0 при дефолте и дал тот же именованный rc 1 при `CHECK_STAGED_ZANJATYJ_NOMER=137`. Это зависимый от константы стаб; в FAIL не включён.
* Некорректные значения параметра дали именованный отказ фикстуры до вызова `$BARRIER`: `999` — `занятый номер 999 вне диапазона 002…998`, `1` и `abc` — `занятый номер «…» — не три цифры`. Scoped-раннер соответственно вернул rc 1 как «не вызвала барьер».
* Охраны `--scope check_staged`, `--scope next_id`, `--scope check_nabludenia` завершились rc 0; `git diff 09ad72b..1cc6b27 --stat -- contracts/ plans/` не вывел строк.

### Дополнительные отрицательные пробы

Отказ `next_id_peek` с rc 127, константа `001` для пустого результата и подмена `git`, возвращающая 127 на перечислении ссылок, дали адресному scoped-case rc 1 с тем же именованным результатом. Нейтрализация `refs/heads` при сохранении только `refs/remotes` также дала rc 1. Эти пробы не являются контрпримером.

## Круг 5
FAIL

### Контрпример 1: разбор суффикса тега расширен за грамматику

Слабая реализация `next_id_max_for_class` снимает конечный якорь в разборе тега: вместо `id/[^/]+/([0-9]+)$` использует `id/[^/]+/([0-9]+)`. Она считает `id/CONTRACT/137a` занятым номером 137, хотя честная реализация по коду `scripts/next_id.sh` этот тег не матчится и не учитывает.

Стаб константно-инвариантен: адресный scoped-case остался зелёным с rc 0 при `CHECK_STAGED_ZANJATYJ_NOMER=019`, `137` и `482`. Следовательно, это не литеральный стаб, исключённый критерием ebc57db. В свежем рабочем репозитории с единственным тегом `id/CONTRACT/137a` стаб напечатал `138` (rc 0); честная реализация на том же репозитории напечатала `001` (rc 0).

Воспроизведение в одноразовом клоне `a24ef96`:

```bash
cp scripts/next_id.sh /tmp/adv019k5-next_id.sh
sed -i '252c\    if [[ "$tag" =~ id/[^/]+/([0-9]+) ]]; then' scripts/next_id.sh
for n in 019 137 482; do
  CHECK_STAGED_ZANJATYJ_NOMER="$n" bash scripts/verify_antiplacebo.sh . \
    --scope check_staged/case_draft_sledujushhij_id
  printf 'TAG_SUFFIX_%s_RC=%d\n' "$n" "$?"
done
work=/tmp/dev-harness-adv019k5/tag-suffix
rm -rf "$work"
git init -q -b main "$work"
git -C "$work" -c user.name=fixture -c user.email=fixture@example.invalid commit --allow-empty -qm init
git -C "$work" tag id/CONTRACT/137a
NEXT_ID_LIB=1 bash -c 'source scripts/next_id.sh; next_id_peek "$1" CONTRACT' _ "$work"
cp /tmp/adv019k5-next_id.sh scripts/next_id.sh
NEXT_ID_LIB=1 bash -c 'source scripts/next_id.sh; next_id_peek "$1" CONTRACT' _ "$work"
```

Наблюдение: `TAG_SUFFIX_019_RC=0`, `TAG_SUFFIX_137_RC=0`, `TAG_SUFFIX_482_RC=0`; затем `138` у стаба и `001` у честной реализации.

### Контрпример 2: последняя цепочка цифр ссылки вместо первой

Слабая реализация источника 2 выбирает последнюю, а не первую цепочку цифр имени ссылки: условие заменено на `(^|[^0-9])([0-9]+)[^0-9]*$`, а число берётся из `BASH_REMATCH[2]`. Обычные входы фикстуры содержат одну цепочку цифр, поэтому стаб зелёный с rc 0 при `019`, `137` и `482` и константно-инвариантен.

В свежем рабочем репозитории единственная числовая ссылка — `refs/remotes/origin/wip/137/x/042`. Честная реализация обязана взять первую цепочку `137` и напечатать `138`; стаб взял `042` и напечатал `043`, оба вызова с rc 0. Удалённая ссылка читается стабом, поэтому это не повтор причины круга 4 (`refs/remotes` не пропущен), а отдельная ось грамматики разбора.

Воспроизведение в одноразовом клоне `a24ef96`:

```bash
cp scripts/next_id.sh /tmp/adv019k5-next_id.sh
sed -i '261c\    if [[ "$ref" =~ (^|[^0-9])([0-9]+)[^0-9]*$ ]]; then' scripts/next_id.sh
sed -i '262c\      local n=$((10#${BASH_REMATCH[2]}))' scripts/next_id.sh
for n in 019 137 482; do
  CHECK_STAGED_ZANJATYJ_NOMER="$n" bash scripts/verify_antiplacebo.sh . \
    --scope check_staged/case_draft_sledujushhij_id
  printf 'LAST_CHAIN_%s_RC=%d\n' "$n" "$?"
done
work=/tmp/dev-harness-adv019k5/last-chain
rm -rf "$work"
git init -q -b main "$work"
git -C "$work" -c user.name=fixture -c user.email=fixture@example.invalid commit --allow-empty -qm init
git -C "$work" update-ref refs/remotes/origin/wip/137/x/042 HEAD
NEXT_ID_LIB=1 bash -c 'source scripts/next_id.sh; next_id_peek "$1" CONTRACT' _ "$work"
cp /tmp/adv019k5-next_id.sh scripts/next_id.sh
NEXT_ID_LIB=1 bash -c 'source scripts/next_id.sh; next_id_peek "$1" CONTRACT' _ "$work"
```

Наблюдение: `LAST_CHAIN_019_RC=0`, `LAST_CHAIN_137_RC=0`, `LAST_CHAIN_482_RC=0`; затем `043` у стаба и `138` у честной реализации.

### Обязательные контроли

* Честная реализация `a24ef96` дала rc 0 адресному scoped-case при дефолте, `137` и `482`; также `--scope check_staged`, `--scope next_id` и `--scope check_nabludenia` дали rc 0.
* Стаб круга 4 без `refs/remotes` дал rc 1 с именованной причиной `барьер остался зелёным на обманном дереве — красное не предъявлено` при дефолте и `137`.
* Константа `002`, head-only и off-by-one (`max+2`) дали тот же именованный rc 1. Класс-осведомлённый табличный стаб на `019` дал rc 0 на дефолте и именованный rc 1 на `137`; по ebc57db он константно-зависим и FAIL не образует.
* Стабы фильтров классов дали именованный rc 1 каждый: K1 — теги без класса, K3 — `ls-tree` без pathspec, K4 — история всех путей. Нейтрализация каждого затронула соответствующий вход CHUZHSRC.
* Стабы `next_id_peek` с rc 127, пустым успешным выводом и отсутствующим `git` в PATH дали именованный rc 1. Они не являются контрпримерами.
* `git diff 09ad72b..a24ef96 --stat -- contracts/ plans/` не вывел строк. Диапазон `f6c90c4..a24ef96` затрагивает только две фикстуры: `+117/-3` строк.


## Круг 6
FAIL

### Контрпример: цифры внутри компонента имени ссылки

Слабая реализация источника 2 учитывает числовую цепочку только как самостоятельный компонент пути ссылки: `(^|/)([0-9]+)(/|$)` с `BASH_REMATCH[2]` вместо честного `([0-9]+)` с `BASH_REMATCH[1]`. Литералов фикстуры в стабе нет. Все входы решётки для ссылок содержат занятую цепочку отдельным компонентом (`wip/<номер>/...`), поэтому адресный scoped-case остаётся зелёным: rc 0 при дефолте 019, а также при подстановках 137 и 482. Стаб константно-инвариантен.

На свежем WORK с единственным числом в `refs/remotes/origin/wip/x137x/only` честный `next_id_peek` печатает `138` (rc 0), поскольку кодовая грамматика `([0-9]+)` находит 137 внутри компонента. Стаб печатает `002` (rc 0): он не учитывает тот же занятый номер. Значит, ось грамматики источника 2 «граница числовой цепочки внутри компонента» не закреплена; заявление о полном закрытии решётки не подтверждено.

Воспроизведение в одноразовом клоне `6b789b8`:

```bash
cp scripts/next_id.sh /tmp/adv019k6-next_id.sh
sed -i '261c\    if [[ "$ref" =~ (^|/)([0-9]+)(/|$) ]]; then' scripts/next_id.sh
sed -i '262c\      local n=$((10#${BASH_REMATCH[2]}))' scripts/next_id.sh
for n in 019 137 482; do
  CHECK_STAGED_ZANJATYJ_NOMER="$n" bash scripts/verify_antiplacebo.sh . --scope check_staged/case_draft_sledujushhij_id
  printf "REF_COMPONENT_STUB_%s_RC=%d\n" "$n" "$?"
done
# Наблюдение: все три scoped-прогона дают rc 0.
work=/tmp/dev-harness-adv019k6/stub-embedded-ref
rm -rf "$work"
git init -q -b main "$work"
mkdir -p "$work/contracts" && touch "$work/contracts/001-x.md"
git -C "$work" -c user.name=fixture -c user.email=fixture@example.invalid add contracts/001-x.md
git -C "$work" -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit -qm init
git -C "$work" update-ref refs/remotes/origin/wip/x137x/only HEAD
NEXT_ID_LIB=1 bash -c 'source scripts/next_id.sh; next_id_peek "$1" CONTRACT' _ "$work"
# Стаб: 002, rc 0. После cp /tmp/adv019k6-next_id.sh scripts/next_id.sh честная реализация: 138, rc 0.
```

Это повтор причины, предмет на арбитра.

### Обязательные контроли

* Честная реализация `6b789b8`: адресный scoped-case дал rc 0 при дефолте, 137 и 482. Охраны `--scope check_staged`, `--scope next_id` и `--scope check_nabludenia` дали rc 0 (соответственно 23/23, 1/1 и 11/11).
* Стабы круга 5 пойманы именованно на всех трёх значениях: TEGSUFF и PERVAJA дали rc 1 с `барьер остался зелёным на обманном дереве — красное не предъявлено`.
* Именованно красные (rc 1) прежние: константа 002, head-only, off-by-one, отсутствие `refs/remotes`, K1 (теги без фильтра класса), K3 (HEAD без фильтра класса), K4 (история без фильтра класса), а также rc 127 и пустой успешный вывод peek. Табличный стаб на 019 дал rc 1 и при подстановке 137; он константно-зависим и новый FAIL не образует.
* `git diff 09ad72b..6b789b8 --stat -- contracts/ plans/` вывел пустой результат (rc 0).


## Круг 7
FAIL

### Двухусловный контрпример: числовое имя remote перед `wip/<NNN>/<роль>`

Стаб источника 2 извлекает номер только из компонента после `wip/`:
`(^|/)wip/([0-9]+)(/|$)` с `BASH_REMATCH[2]`. Литералов значений
фикстуры в нём нет. Адресный scoped-case на этой реализации завершился rc 0
при `CHECK_STAGED_ZANJATYJ_NOMER=019`, `137` и `482`; константная
инвариантность выполнена.

Свежий WORK содержит единственную ссылку
`refs/remotes/007/wip/137/only`. Это зеркало ссылки
`wip/137/only`: номер имеет формат `%03d`, роль `only` нечисловая, а
`007` находится в документированном пространстве remote `refs/remotes/*`.
Следовательно, вход конформен правилу fa0d354. На нём стаб печатает `138`
(rc 0), извлекая номер ветки `137`. Редакция M-1 с компонентной грамматикой
`(^|/)([0-9]+)(/|$)` печатает `008` (rc 0), потому что первым числовым
компонентом короткого имени `007/wip/137/only` становится имя remote.
Расхождение наблюдается на конформном входе.

Воспроизведение в одноразовом клоне `b2c0343`:

```bash
cp scripts/next_id.sh /tmp/dev-harness-adv019k7/next_id.honest
sed -i '269c\    if [[ "$ref" =~ (^|/)wip/([0-9]+)(/|$) ]]; then' scripts/next_id.sh
for n in 019 137 482; do
  CHECK_STAGED_ZANJATYJ_NOMER="$n" \
    bash scripts/verify_antiplacebo.sh . --scope check_staged/case_draft_sledujushhij_id
done
work=/tmp/dev-harness-adv019k7/remote-numeric
rm -rf "$work" && mkdir "$work"
git -C "$work" init -q -b main
git -C "$work" -c user.name=fixture -c user.email=fixture@local commit --allow-empty -qm base
git -C "$work" update-ref refs/remotes/007/wip/137/only HEAD
NEXT_ID_LIB=1 bash -c 'source scripts/next_id.sh; next_id_peek "$1" CONTRACT' _ "$work"
cp /tmp/dev-harness-adv019k7/next_id.honest scripts/next_id.sh
NEXT_ID_LIB=1 bash -c 'source scripts/next_id.sh; next_id_peek "$1" CONTRACT' _ "$work"
```

Наблюдение: три scoped-прогона стаба дали rc 0; затем стаб напечатал `138`,
а редакция M-1 — `008`.

### Обязательные контроли

* Честная редакция `b2c0343`: адресный scoped-case завершился rc 0 при
  дефолте, `137` и `482`.
* Латентный дефект M-1 устранён: на свежем WORK с
  `refs/heads/exp/backup-2026` и `contracts/001-base.md` на HEAD
  `next_id_peek` напечатал `002`, rc 0.
* Конформные контроли источника 2: единственная
  `refs/remotes/origin/wip/137/only` дала `138`, а единственная
  `refs/heads/wip/042/implementer` — `043`; оба вызова rc 0.
* Прежние стабы завершились rc 1 с именованным результатом раннера:
  константа, head-only, off-by-one, отсутствие `refs/remotes`, K1, K3, K4,
  TEGSUFF и PERVAJA. Отказ peek rc 127, пустой успешный вывод и git первым
  в PATH с rc 127 также завершились rc 1.
* Охраны завершились rc 0: `check_staged` 23/23, `next_id` 1/1,
  `check_nabludenia` 11/11, `check_charter` 8/8, `spawn_agent` 2/2,
  `check_hooks` 7/7.
* `git diff 09ad72b..b2c0343 --stat -- contracts/ plans/` не вывел строк.

## Круг 8
accept

Судимый диапазон: `b2c0343..71bda60`; воспроизведение выполнено только в одноразовом клоне `/tmp/dev-harness-adv019k8/repo` на `71bda60`. Ручные пробы выполнялись отдельными вызовами `verify_antiplacebo` с отдельным `VERIFY_ANTIPLACEBO_SCRATCH`, следовательно у каждой был свежий `WORK`.

### Двухусловная граница и правка 5

Новой оси нет. Критерий `fa0d354` применён совместно: проверялись только константно-инвариантные подстановки и расхождения на конформных зеркалах `refs/remotes/<NNN>/wip/<NNN>/<нечисловая-роль>`. Для пространства максимум с двумя числовыми компонентами KOMP1/KOMP2 различают first от last, max, min, after-wip и N=2. Для N>=3 конформного входа нет, поэтому контрпример по нему не образуется.

Честная реализация, адресный scoped-case:

```text
$ for n in 019 137 482; do CHECK_STAGED_ZANJATYJ_NOMER=$n bash scripts/verify_antiplacebo.sh . --scope check_staged/case_draft_sledujushhij_id; printf "HONEST_%s_RC=%d\n" "$n" "$?"; done
HONEST_019_RC=0
HONEST_137_RC=0
HONEST_482_RC=0
```

Для каждого стаба выполнялась отдельная подстановка в `scripts/next_id.sh`, затем та же команда на свежем `WORK`; сырой итог раннера для каждого был `FAIL ... барьер остался зелёным на обманном дереве — красное не предъявлено` и rc 1. Команды воспроизведения — адресный scoped-case выше с соответствующей заменой выбора компоненты в цикле источника 2:

```text
$ after-wip:  (^|/)wip/([0-9]+)(/|$), BASH_REMATCH[2]
AFTER_WIP_019_RC=1  AFTER_WIP_137_RC=1  AFTER_WIP_482_RC=1
$ last: ([0-9]+)(/[^0-9/]+)?$, BASH_REMATCH[1]
LAST_019_RC=1       LAST_137_RC=1       LAST_482_RC=1
$ N=2: ^([0-9]+)/wip/([0-9]+)/, BASH_REMATCH[2]; иначе first
NTH2_019_RC=1       NTH2_137_RC=1       NTH2_482_RC=1
$ max(first, after-wip); иначе first
MAX_019_RC=1        MAX_137_RC=1        MAX_482_RC=1
$ min(first, after-wip); иначе first
MIN_019_RC=1        MIN_137_RC=1        MIN_482_RC=1
```

Во всех пяти строках ненулевой rc относится к стабу, а не к отсутствующему инструменту: раннер назвал именно отсутствие предъявленного красного, а не `NOT_IMPLEMENTED`. Тем самым KOMP1/KOMP2 нейтрализуют ровно проверяемый выбор компоненты; это не новый контрпример.

### Прежние обманные реализации

Каждая проба — отдельная подстановка и свежий `WORK`; команды воспроизведения: `CHECK_STAGED_ZANJATYJ_NOMER=019 bash scripts/verify_antiplacebo.sh . --scope check_staged/case_draft_sledujushhij_id` после указанной замены. Сырой результат всех ниже — rc 1; кроме отмеченного rc127-канала раннер сообщил `барьер остался зелёным на обманном дереве — красное не предъявлено`.

```text
CONSTANT_RC=1              # next_id_peek печатает 002
HEAD_ONLY_RC=1             # peek читает только contracts/ на HEAD
OFF_BY_ONE_RC=1            # next=max+2
K4_NO_REMOTES_RC=1         # источник 2: только refs/heads
K1_TAG_CLASS_RC=1          # теги без фильтра класса
K3_HEAD_CLASS_RC=1         # HEAD читает contracts и plans
K4_HISTORY_CLASS_RC=1      # история читает contracts и plans
TEGSUFF_019_RC=1  TEGSUFF_137_RC=1  TEGSUFF_482_RC=1
LAST_019_RC=1     LAST_137_RC=1     LAST_482_RC=1   # PERVAJA / к5
K7_AFTER_WIP_RC=1
PEEK_RC127_RC=1            # раннер назвал отсутствие предъявленного красного
PEEK_EMPTY_RC=1            # успешный пустой stdout
```

Проверен также отказный канал: `next_id_peek() { return 127; }` дал `PEEK_RC127_RC=1`, а не зелёное. Пустой успешный ответ также не засчитан. Нейтрализации источника 2 (`refs/remotes`), фильтров K1/K3/K4 и выбора после `wip/` дали именно соответствующий адресный красный сценарий, а не общий положительный контроль.

### Лечение рассогласований Н-77

Сырые итоги команд на честной судимой вершине:

```text
$ bash scripts/check_zones.sh
  ok   контракт 019: коммит 8998cd41 (architect) — СПАСЕНО, из суда зон выведен
CHECK_ZONES_SAVED_RC=0

$ bash scripts/check_ids.sh
  ok   номера уникальны и согласованы с регистром выдачи
CHECK_IDS_TAG_RC=0

$ bash scripts/check_ceilings.sh
  ok   раздел требований: 19 черновик(ов) судится, замороженные — по тегам
потолки в порядке
CHECK_CEILINGS_DRAFT_RC=0
```

Для отрицательного контроля строка `СПАСЕНО architect: 8998cd41bfd9622d7634c02e5bd119567b4e17d8 ...` была удалена в клоне, изменение было закоммичено только в нём и tag `frozen/contracts/019/2` был направлен на эту пробную вершину, чтобы `check_zones` читал изменённый frozen blob, а не рабочее дерево. Ровно одна резервация потеряна:

```text
$ bash scripts/check_zones.sh
  FAIL коммит вне зоны: architect 8998cd41 contracts/020-shardirovanie-ci-antiplatsebo.md — зона контракта 019: contracts/019-ustav-draft-klyuchi.md fixtures/check_charter/ fixtures/check_staged/ fixtures/spawn_agent/ NABLIUDENIA_ARCHITECT.md
CHECK_ZONES_FROZEN_WITHOUT_SAVED_RC=1
```

Неизменность заморозки и единственная v1→v2 дельта:

```text
$ git diff frozen/contracts/019/2..HEAD --stat -- contracts/ plans/
FROZEN_V2_HEAD_DIFF_RC=0

$ git diff frozen/contracts/019/1 frozen/contracts/019/2 -- contracts/019-ustav-draft-klyuchi.md
 contracts/019-ustav-draft-klyuchi.md | 1 +
 1 file changed, 1 insertions(+), 0 deletions(-)
+СПАСЕНО architect: 8998cd41bfd9622d7634c02e5bd119567b4e17d8 — draft-пуск ветви 2 контракта 019 ...
FROZEN_V1_TO_V2_DIFF_RC=0
```

### Охраны

```text
$ bash scripts/verify_antiplacebo.sh . --scope check_staged
барьеров: 1 · фикстур: 23 · предъявлено красным повторным прогоном: 23
GUARD_check_staged_RC=0
$ bash scripts/verify_antiplacebo.sh . --scope next_id
барьеров: 1 · фикстур: 1 · предъявлено красным повторным прогоном: 1
GUARD_next_id_RC=0
$ bash scripts/verify_antiplacebo.sh . --scope check_nabludenia
барьеров: 1 · фикстур: 11 · предъявлено красным повторным прогоном: 11
GUARD_check_nabludenia_RC=0
$ bash scripts/verify_antiplacebo.sh . --scope check_charter
барьеров: 1 · фикстур: 8 · предъявлено красным повторным прогоном: 8
GUARD_check_charter_RC=0
$ bash scripts/verify_antiplacebo.sh . --scope spawn_agent
барьеров: 1 · фикстур: 2 · предъявлено красным повторным прогоном: 2
GUARD_spawn_agent_RC=0
$ bash scripts/verify_antiplacebo.sh . --scope check_hooks
барьеров: 1 · фикстур: 7 · предъявлено красным повторным прогоном: 7
GUARD_check_hooks_RC=0
```

Итог: обязательные положительные контроли зелёные; прежние и новые обманные реализации адресно красные; лечение Н-77 и неизменность v2 подтверждены. На конформных входах новой двухусловной оси не обнаружено.
