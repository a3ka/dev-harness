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
