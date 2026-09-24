FAIL

# Контракт 043 — третий круг критика

Предмет: `contracts/043-precizionnyj-prefriz-gejt.md`, прочитан целиком на
закоммиченном HEAD `56d6c67d4b870d0f6c18b07cc8c6e7668fcf48c2` свежего SSH-клона
`ssh://git@github.com/a3ka/dev-harness.git`. Перед коммитом выполнен fetch и
fast-forward до `615d446`: добавлен только HANDOFF.md, предмет и проверенные
барьеры не менялись. Автор вердикта — critic.

Первым действием целиком прочитан
`verdicts/arbitration/043-b4-ci-family-coverage.md`. Круг легитимен по его
§Граница круга 3. Судятся исполнение предписания арбитра, отдельно исходный
Б5 второго круга и действительно новая регрессия нынешней правки. Б4 не
переоткрывается. Старые советы v2 не превращаются в блокеры.

Набор артефактов полный: предмет, команды готовности, architect/implementer,
ЗОНА-строки и механизм check_zones названы. Модель угроз присутствует.

## Исполнение решения арбитра: соответствует

Все четыре предписания исполнены как предписано:

1. `package.json:66–67`: статичные ключи `check:precision-family-selftest`
   и `check:precision-battery`; значения побайтово равны командам Р10 и Р11:
   `bash fixtures/_krasnye_043.sh` и
   `bash fixtures/parsing_hygiene_battery/run_battery.sh check_precision_gate`.
2. `.github/workflows/ci.yml:215–246`: два прямых шага job `ci`, вне
   antiplacebo-матрицы, с `run: npm run check:precision-family-selftest`
   и `run: npm run check:precision-battery`. В keys шардов семья не добавлена;
   прежний self-gate сохранён в :213.
3. `contracts/043-precizionnyj-prefriz-gejt.md:347`: добавлен Р14 с четырьмя
   `grep -Fq`-командами, проверяющими именно обе строки вызова и оба ключа
   вместе со значениями. Это ровно назначенная арбитром форма доказательства;
   её достаточность повторно не оспаривается. Строки и значения сверены
   чтением и поиском; отдельного shell-прогона этих четырёх grep не заявляю.
4. `.github/workflows/ci.yml:211–212`: комментарий теперь ссылается на два
   реально присутствующих прямых шага, а не на якобы уже исполненные фикстуры.

## Живые scoped-прогоны

Полный verify_antiplacebo, полный CI, линтеры и форматтеры не запускались.
Предъявленные оркестратором результаты паритета и check_zones приняты как факт,
не выдаются здесь за собственные прогоны.

- `bash fixtures/check_precision_gate/green_17_honest_live_barrier.sh`
  → **rc 0**, `case_17 (честный живой вызов барьера, Б5 fix — /proc-наблюдение должно ловить): rc 0`.
- `bash fixtures/_krasnye_043.sh` → **rc 0**, `итог: 14 файлов, провалов 0`.
  Все прежние 13 файлов зелёные, включая red_07, red_08, red_15 и red_16;
  четырнадцатый — green_17.
- `npm run check:precision-battery` → **rc 0**, `итог 4/4 классов закрыто`.
  В stderr сохранён прежний `fatal: tag 'frozen/contracts/991/1' already exists`;
  чистый stderr не заявляется, арбитраж уже квалифицировал этот шум.
- `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/critic043-v3 contracts/043-precizionnyj-prefriz-gejt.md`
  → **rc 0**, `OK`. Stderr именует пропуск собственной семьи задачей (б).

## Исходный Б5: воспроизведение закрыто, регресс не плацебо

Поскольку 19d9d88 уже закоммичен, простой stash на чистом HEAD не убрал бы
фикс. Для честного дифференциала создан отдельный worktree из того же
SSH-клона на `19d9d88^` (`8bf084e`), в него из `56d6c67` восстановлены
ТОЛЬКО `scripts/check_precision_gate.sh` и новый green_17. Затем:

```
git stash push -m critic043-v3-b5-differential -- scripts/check_precision_gate.sh
bash fixtures/check_precision_gate/green_17_honest_live_barrier.sh
```

Stash убрал именно фикс барьера, оставив тот же green_17. Получен **rc 1**:

```
ОТКАЗ: case_17 (честный живой вызов барьера, Б5 fix — /proc-наблюдение должно ловить): rc 1 (ожидался 0)
ACTUAL_BARRIER_EXEC pid=1707297
ACTUAL_BARRIER_EXEC pid=1707310
precision-гейт 043: fixtures/check_dummy/green_live.sh: барьер dummy не вызван живьём (/proc-наблюдение не нашло exec)
```

`git stash pop` вернул фикс; повтор того же green_17 → **rc 0**. Исходный
ложный отказ безаргументному вызову с `sleep 1` исправлен и действительно
различается новой регрессией. Сам по себе green_17 принят; Б5 в первоначальной
форме не оставляется открытым по инерции.

## Новый блокер Б6: аргумент честного вызова принят за имя барьера

БЛОКИРУЕТ contracts/043-precizionnyj-prefriz-gejt.md:332 — критерий Р10 с новым green_17 остаётся зелёным на внесённой в этом круге регрессии: обещанный в :35–45 и :177–183 живой вызов барьера с аргументами отвергается как несуществовавший. Green_17 проверяет только безаргументный вызов и этой потери контракта не различает.
ОБХОД: дерево 56d6c67 проходит 14/14, 4/4 и Р13, но новый честный green_live.sh буквально исполняет абсолютный `scripts/check_dummy.sh` с одним аргументом корня. Dummy печатает PID и аргумент, держится `sleep 10`, возвращает 0. Прямой case зелёный; оба запуска внутри гейта действительно вызывают dummy; текущий гейт даёт rc1 «барьер dummy не вызван живьём». Тот же вход на барьере до 19d9d88 даёт rc0. Приёмка выполнена, предмет подтверждения честного живого вызова нет.

Это НОВЫЙ дефект изменения `scripts/check_precision_gate.sh:428–436`, а не
пересмотр старого механизма или предписаний арбитра. Старый код извлекал второе
NUL-поле cmdline. Новый цикл читает ВСЕ поля, каждый раз присваивая `_argv1`,
и после EOF сравнивает ПОСЛЕДНИЙ аргумент с путём барьера. Для
`bash /abs/scripts/check_dummy.sh /abs/root` сравнивается `/abs/root`,
а не имя исполняемого скрипта. Ускорение /proc само по себе этот логический
дефект не устраняет. Более длинный sleep отделяет его от прежней гонки.

Живой дифференциал одной пробы (в обоих случаях dummy с `sleep 10`):

```
# До фикса 19d9d88, пока scripts/check_precision_gate.sh убран stash:
ACTUAL_BARRIER_EXEC pid=1721008 arg=/tmp/dev-harness-verify/critic043-v3-args.ViHQzx
HONEST_ARGUMENT plain_rc=0
HONEST_ARGUMENT gate_rc=0
ACTUAL_BARRIER_EXEC pid=1721126 arg=/tmp/dev-harness-verify/critic043-v3-args.ViHQzx
ACTUAL_BARRIER_EXEC pid=1721186 arg=/tmp/dev-harness-verify/critic043-v3-args.ViHQzx
OK

# Текущий 56d6c67:
ACTUAL_BARRIER_EXEC pid=1722490 arg=/tmp/dev-harness-verify/critic043-v3-args.MH8RQT
HONEST_ARGUMENT plain_rc=0
HONEST_ARGUMENT gate_rc=1
ACTUAL_BARRIER_EXEC pid=1722624 arg=/tmp/dev-harness-verify/critic043-v3-args.MH8RQT
ACTUAL_BARRIER_EXEC pid=1722690 arg=/tmp/dev-harness-verify/critic043-v3-args.MH8RQT
precision-гейт 043: fixtures/check_dummy/green_live.sh: барьер dummy не вызван живьём (/proc-наблюдение не нашло exec)
```

Проба с sleep 3 тоже дала отказ на текущем барьере, но отказала и на старом
из-за прежней гонки; этот замер НЕ используется как доказательство новизны.
Новизна доказана парой sleep 10 выше. Это обычный абсолютный вызов скрипта
с аргументом, не подделка argv постороннего процесса, не ENV TRUST и не
проверка исключённого моделью угроз обхода.

### Воспроизведение Б6

Из корня проверяемого клона сохранить и запустить следующий одноразовый
bash-скрипт; он пользуется уже существующим каркасом семьи и возвращает 0
только при принятии честного вызова. На текущем дереве возвращает 1.

```bash
#!/usr/bin/env bash
set -uo pipefail
HERE="$PWD/fixtures/check_precision_gate"
. "$HERE/_toy.sh"
BARRIER="$SUBJ"
WORK="$(mktemp -d /tmp/dev-harness-verify/critic043-v3-args.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT
mk_toy_repo "$WORK"
mk_mint "$WORK" 043
mkdir -p "$WORK/scripts"
printf '%s\n' '#!/usr/bin/env bash' \
  'printf "ACTUAL_BARRIER_EXEC pid=%d arg=%s\n" "$$" "${1:-none}"' \
  'sleep 10' 'exit 0' > "$WORK/scripts/check_dummy.sh"
chmod +x "$WORK/scripts/check_dummy.sh"
mk_family_case "$WORK" dummy green_live.sh "#!/usr/bin/env bash
\"$WORK/scripts/check_dummy.sh\" \"$WORK\"
"
put_draft "$WORK/contracts/043-toy-draft.md" '# Контракт 043

## Предмет
Честный живой вызов с аргументом корня.

## Зоны
ЗОНА architect: contracts/043-toy-draft.md fixtures/check_dummy/'
plain_rc=0
bash "$WORK/fixtures/check_dummy/green_live.sh" || plain_rc=$?
printf 'HONEST_ARGUMENT plain_rc=%s\n' "$plain_rc"
run_barrier "$WORK" contracts/043-toy-draft.md
printf 'HONEST_ARGUMENT gate_rc=%s\n%s\n' "$LAST_RC" "$LAST_OUT"
[ "$plain_rc" -eq 0 ] && [ "$LAST_RC" -eq 0 ]
```

## Пять вопросов в границах этого круга

1. **Критерий слабее предмета?** Новый Б6 предъявляет конкретное зелёное по
   приёмке дерево с потерей честного вызова с аргументом.
2. **Готовность доказуема командами?** Предписание Б4 теперь выражено ровно
   назначенными командами Р14; исходный Б5 доказан red/green-дифференциалом.
   Полная семья ещё не различает новый Б6.
3. **Решение оставлено исполнителю?** По предмету арбитража нет: ключи,
   шаги, доказательство и комментарий уже определены и исполнены. Для Б6
   требуется сохранить командную позицию при наличии аргументов, а не
   менять предмет или исключать честные вызовы.
4. **Границы?** Новые ключи и CI находятся в implementer-зоне :277;
   барьер и green_17 — в совместно названных зонах :275–277, механизм
   check_zones назван. Расширения зон этой правкой не требуется.
5. **Старшая норма?** Б6 — также ложный диагноз честному вызову, запрещённый
   правилом 7 AGENTS.md. Проверка обязательного precision-гейта выполнена.
   Решение арбитра по Б4 окончательно и соблюдено.

Блокер один, новый Б6. Повторного несогласия по Б4 нет; нового арбитража по
закрытому вопросу не созываю. Единственная постоянная правка критика — этот
вердикт. Контракт, код, роли, CI и постоянные фикстуры критиком не изменены.
