accept

# Ревью контракта 020, круг к4 — предмет `182f6e8` (вершина фикса `7c017a7`)

Судья: reviewer. Дата: 2026-09-18. Предыдущий круг: `verdicts/review/contracts-020-k3.md`
(`05fb544`, FAIL по Б2/Н1). Данный круг — второй по причине Б2/Н1 и прямое продолжение
собственного к3-отказа.

## Предмет и целостность (Н-101)

Одноразовый клон `/tmp/dev-harness-verify/rev-020-k4/repo`, снят после прогона.

```
$ git rev-parse HEAD                     # клон
182f6e879e9f9be5c4accd6d42014586c1e15e30
$ git rev-parse HEAD main                # /home/aka/Documents/dev-harness
182f6e879e9f9be5c4accd6d42014586c1e15e30
182f6e879e9f9be5c4accd6d42014586c1e15e30
```

Блобы файлов предмета — клон и main побитово совпали:

```
100644 blob 38af80961d71289586f04f368359f1301e45de5b	.github/workflows/ci.yml
100644 blob 3b9688e691e0c36b15a13be997d776fae8b1bbd1	config/ci_parity_exceptions.txt
100755 blob 3b717e6439bb77727a87869ba0a2375381db905c	scripts/verify_ci_parity.sh
```

## Зоны и атомарность

```
$ git log --format='%h %an | %s' 182f6e8~2..182f6e8
182f6e8 orchestrator | land: wip/020/implementer
7c017a7 implementer  | 020 implementer: изоляция анти-плацебо-команды в 4b.2 — …(блокер БВ2/Н1, вердикт ревьюера к3)
2f1392d orchestrator | NABLIUDENIA: Н-104 расширение … слово владельца 2026-09-18

$ git diff --stat 2f1392d 182f6e8
 scripts/verify_ci_parity.sh | 52 +++++++++++++++++++++++----------------------
 1 file changed, 27 insertions(+), 25 deletions(-)

$ git show --stat 2f1392d
 NABLIUDENIA.md | 17 +++++++++++++++++
```

Мерж `182f6e8` вносит РОВНО один файл — `scripts/verify_ci_parity.sh`, автор правки
implementer, мерж orchestrator. Превышения зоны нет. `.github/workflows/ci.yml` и
`config/ci_parity_exceptions.txt` этим кругом не трогались вовсе. `2f1392d` —
не часть фикса: запись наблюдения со словом владельца, сделанная orchestrator'ом
до мержа; нормативный документ внутри задачи о механизме НЕ правился.

Атомарность соблюдена: одна задача — один коммит `7c017a7` со ссылкой на предмет
(блокер к3) в сообщении.

## Мера 1 — собственные эксплойты к3 обязаны быть КРАСНЫМИ

Оба внедрены в копию `.github/workflows/ci.yml` в клоне, нешардный шаг в джобе `ci`.

### 1.1 `bypass_comment_only` — комментарий с текстом объявленного исключения

```yaml
      - name: bypass_comment_only
        run: |
          # mkdir -p "$TMP_ROOT/scripts"
          npm run check:antiplacebo
```

```
$ bash scripts/verify_ci_parity.sh .
  FAIL …/ci.yml:132 (ci): запуск анти-плацебо вне шардной matrix (не несёт --scope с ключами): npm run check:antiplacebo

workflow-команд: 37 · скриптов в приёмке: 46 · объявленных исключений: 24 · matrix-ключей: 35 · анти-плацебо-запусков: 3 · расхождений: 1
rc=1
```

КРАСНЫЙ. В к3 этот же вход давал rc=0.

### 1.2 `bypass_executable_line` — соседняя исполняемая строка

```yaml
      - name: bypass_executable_line
        run: |
          npm run check:antiplacebo
          mkdir -p "$TMP_ROOT/scripts"
```

```
$ bash scripts/verify_ci_parity.sh .
  FAIL …/ci.yml:132 (ci): запуск анти-плацебо вне шардной matrix (не несёт --scope с ключами): npm run check:antiplacebo

workflow-команд: 38 · скриптов в приёмке: 46 · объявленных исключений: 24 · matrix-ключей: 35 · анти-плацебо-запусков: 3 · расхождений: 1
rc=1
```

КРАСНЫЙ. В к3 этот же вход давал rc=0.

### 1.3 Довесок судьи — текст `--scope` в СОСЕДНЕЙ команде того же шага

Прямая проверка самой изоляции: оплату инварианта 4 больше нельзя внести чужой частью.

```yaml
      - name: bypass_scope_in_other_part
        run: |
          echo "--scope ${{ matrix.keys }}"
          npm run check:antiplacebo
```

```
  FAIL …/ci.yml:132: команда «echo "--scope ${{ matrix.keys }}"» есть в CI, но нет пункта в приёмке и не объявлена исключением
  FAIL …/ci.yml:132 (ci): запуск анти-плацебо вне шардной matrix (не несёт --scope с ключами): npm run check:antiplacebo
… · расхождений: 2
rc=1
```

КРАСНЫЙ. `has_scope_keys` читается по ИЗОЛИРОВАННОЙ части, не по всему телу `run:`.

### Контроль зелёного (без внедрений, чистый HEAD клона)

```
$ git status --porcelain            # пусто
$ bash scripts/verify_ci_parity.sh .
workflow-команд: 36 · скриптов в приёмке: 46 · объявленных исключений: 24 · matrix-ключей: 35 · анти-плацебо-запусков: 2 · расхождений: 0
rc=0
```

Точное равенство `EXC_CMD[$cmd]` не убило законную оплату
`команда: npm run check:antiplacebo -- "$TMP_ROOT"`: 24 исключения живы, недостижимых
и мёртвых записей нет.

## Мера 2 — собственные регрессионные фикстуры обязаны быть ЗЕЛЁНЫМИ

```
$ bash scripts/verify_antiplacebo.sh . --scope verify_ci_parity
SCOPED: барьеров 1 из выборки — не для приёмки
  … 26 строк «ok …» …
барьеров: 1 · фикстур: 26 · предъявлено красным повторным прогоном: 26
rc=0
```

Три case, в которых сидела к3-регрессия (резолвленный текст в bad-сообщении вместо
исходного), предъявляют теперь ИСХОДНУЮ форму — корень регрессии закрыт:

```
  ok   verify_ci_parity/case_shard_legacy_shag_peremennoe_imja.sh: … — «запуск анти-плацебо вне шардной matrix (не несёт --scope с ключами): npm run "$ANTI_SCRIPT" -- --changed ${{ github.event.before }}»
  ok   verify_ci_parity/case_shard_legacy_shag_peremennyj_binarnik.sh: … — «запуск анти-плацебо вне шардной matrix (не несёт --scope с ключами): "$NPM_BIN" run check:antiplacebo -- --changed ${{ github.event.before }}»
  ok   verify_ci_parity/case_shard_legacy_shag_psevdonim.sh: … — «запуск анти-плацебо вне шардной matrix (не несёт --scope с ключами): npm run-script check:antiplacebo -- --changed ${{ github.event.before }}»
```

## Мера 3 — арбитражные замеры 5/6 (`verdicts/arbitration/contracts-020-samtesty.md`)

Честный mktemp-корень собран рецептом CI-шага:

```
$ R=$(mktemp -d /tmp/dev-harness-verify/rev-020-k4/z5-XXXXXX)
ROOT=/tmp/dev-harness-verify/rev-020-k4/z5-RocrNv
$ mkdir -p "$R/scripts" "$R/fixtures/verify_antiplacebo"
$ cp scripts/verify_antiplacebo.sh "$R/scripts/verify_antiplacebo.sh"
$ cp -r fixtures/verify_antiplacebo/. "$R/fixtures/verify_antiplacebo/"
```

### Замер 5 — честный раннер в корне

```
$ npm run check:antiplacebo -- "/tmp/dev-harness-verify/rev-020-k4/z5-RocrNv"
  … 23 строки «ok …» …
барьеров: 1 · фикстур: 23 · предъявлено красным повторным прогоном: 23
real	0m50.674s
rc=0
```

Воспроизведён дословно: 23/23, rc=0, 50,7 с стены (арбитраж заявлял 52 с).

### Замер 6 — саботаж ветви `:694` в КОПИИ внутри корня

```
BEFORE:       bad "$cname: барьер остался зелёным на обманном дереве — красное не предъявлено"
AFTER :       ok "$cname: барьер остался зелёным на обманном дереве — красное не предъявлено"

$ npm run check:antiplacebo -- "/tmp/dev-harness-verify/rev-020-k4/z5-RocrNv"
  FAIL verify_antiplacebo/case_barjer_zelen.sh: причина «барьер остался зелёным на обманном дереве» печатается и на ЗЕЛЁНОМ прогоне — она не называет ни отказ, ни предмет
  FAIL verify_antiplacebo/case_neobjavlennoe_okruzhenie.sh: причина «барьер остался зелёным на обманном дереве» печатается и на ЗЕЛЁНОМ прогоне — она не называет ни отказ, ни предмет
  FAIL verify_antiplacebo/case_perepisala_uchet.sh: причина «барьер остался зелёным на обманном дереве» печатается и на ЗЕЛЁНОМ прогоне — она не называет ни отказ, ни предмет
  FAIL verify_antiplacebo/case_tmpdir_raven_koren.sh: причина «барьер остался зелёным на обманном дереве» печатается и на ЗЕЛЁНОМ прогоне — она не называет ни отказ, ни предмет
барьеров: 1 · фикстур: 23 · предъявлено красным повторным прогоном: 19
rc=1
```

rc=1, РОВНО 4 case, именно те, что назвал арбитраж. Воспроизведён дословно.

Заморозка раннера соблюдена — правка жила только в копии:

```
$ md5sum scripts/verify_antiplacebo.sh  .../z5-RocrNv/scripts/verify_antiplacebo.sh
c0c3a2780a4d079185dd7b7a57991768  scripts/verify_antiplacebo.sh
b62ccc89524826bd813f605aafe80f11  .../z5-RocrNv/scripts/verify_antiplacebo.sh
$ git diff -- scripts/verify_antiplacebo.sh      # пусто
$ git status --porcelain                          # пусто
```

## Вердикт по блокерам к3

**Б2/Н1 — ЗАКРЫТ.** Подстрочное сравнение `[[ "$cmd" == *"$c"* ]]` заменено точным
равенством `EXC_CMD[$cmd]`, а тело `run:` разбирается тем же `split_commands`, что и
правило 6; в `cmd`/`has_scope_keys` идёт ИСХОДНЫЙ текст части, резолюция индирекции
служит только детекции. Оба к3-эксплойта красны (мера 1), регрессия трёх legacy-case
устранена в корне — в сообщении снова исходная форма (мера 2).

**Б1 — закрыт в к3, не переоткрывался.**

## Замечания (не блокеры)

**З3 (перенесено из к3, ОТКРЫТО).** Комментарии `.github/workflows/ci.yml:40,44,45`
ссылаются на редакции контракта «v3.1»/«v3.2»:

```
$ git tag -l | grep 020
frozen/contracts/020/1
frozen/contracts/020/2
id/CONTRACT/020
$ grep -rn 'v3\.1\|v3\.2' contracts/     # ничего
```

Редакций v3.1/v3.2 нет ни в документе, ни в тегах. Класс — прослеживаемость.
Этим кругом файл не трогался (правка была бы превышением зоны). Статус: открыто.

**З4 (НОВОЕ, найдено судьёй, ПРЕД-СУЩЕСТВУЮЩЕЕ — не регрессия этого круга).**
`scripts/verify_ci_parity.sh:1271` — `[ "$has_scope" -eq 1 ] && continue` замыкает
инвариант 4 ДО проверки `in_matrix`. Любой шаг вне учтённой шардной matrix проходит
зелёным и неоплаченным, если просто несёт литерал `--scope ${{ matrix.keys }}`.

Замер А — нешардный шаг в джобе `ci`:

```yaml
      - name: bypass_fake_scope
        run: npm run check:antiplacebo -- --scope ${{ matrix.keys }} --changed HEAD~1
```
```
$ bash scripts/verify_ci_parity.sh .
workflow-команд: 37 · … · анти-плацебо-запусков: 3 · расхождений: 0
rc=0
```

Замер Б — джоба с matrix БЕЗ `include[].shard` (`in_matrix=0`, `:823-848`):

```yaml
  ghost:
    strategy:
      matrix:
        keys: [check_ci_parity]
    steps:
      - run: npm run check:antiplacebo -- --scope ${{ matrix.keys }}
```
```
$ bash scripts/verify_ci_parity.sh .
workflow-команд: 37 · … · анти-плацебо-запусков: 3 · расхождений: 0
rc=0
```

Замер В — пред-существование доказано на блобе ДО фикса (`52f0079:scripts/verify_ci_parity.sh`,
редакция, которую судил к3):

```
$ git checkout 52f0079 -- scripts/verify_ci_parity.sh && bash scripts/verify_ci_parity.sh .
workflow-команд: 37 · … · анти-плацебо-запусков: 3 · расхождений: 0
rc=0
```

Замер Г — цена ошибки ограничена, поэтому НЕ блокер: в джобе без matrix шаблон
раскрывается в пустую строку, и раннер краснеет на запуске, а не молчит:

```
$ bash scripts/verify_antiplacebo.sh . --scope
  FAIL scope_select отказал (код 1):
rc=1
```

Итог по З4: замыкание на `has_scope` не даёт ТИХОГО ослабления приёмки (вариант А
краснеет в CI), но вариант Б пропускает анти-плацебо-прогон с произвольным набором
ключей МИМО шардного учёта — мёртвый ключ, дубль и покрытие такого запуска не видят.
Это избыток без объявления, ровно тот остаток, ради объявления которого заведён канал
`команда:`. Дефект пред-существующий, границам `7c017a7` не принадлежит, кругом к4 не
внесён — поэтому назван, а не поставлен блокером. Адресат — владелец/следующий круг
контракта 020.

**З4 НЕ относится к классу Б2/Н1.** Б2/Н1 — подстрочное сравнение текста команды;
З4 — порядок проверок в 4b.2 (замыкание до `in_matrix`). Третьего повтора Б2/Н1 нет,
адрес арбитра по этой причине НЕ назван.

## Итог

`accept`. Фикс `7c017a7` делает ровно то, что заявляет, в объявленных границах;
все три обязательные меры круга предъявлены собственным прогоном судьи. Открытыми
остаются З3 (прослеживаемость) и З4 (пред-существующее замыкание инварианта 4) —
оба не блокируют приземление `182f6e8`.
