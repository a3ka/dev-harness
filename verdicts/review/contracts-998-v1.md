FAIL
OBJECT=9aa86e735c0db07a342053ff2ddab6d90bbd81ef

# Ревью контракта 998 (pravila-modelei), круг 1 — Rev998r1

Сверено с frozen-блобом `git show frozen/contracts/998/1^{commit}:contracts/998-pravila-modelei.md`
(тег → c609c2ef5). Предмет: коммиты implementer 22be79c07, cf7a2cd1b, 165796834, ff1d34213,
9448fec65, 852402f40. Находки reslop — `review.md` рядом.

## Блокирующие находки (у каждой названы обход и rc)

### Р998-1. Рендер не переносит форму цели role↔tier (инв. 3) — класс: дефект предмета
Фрагмент: `scripts/gen-harness.ts` `renderRoutingSection`: `const target = role ?? tier ?? ''`,
строка `` `→ ${target}` `` — какая это форма (role или tier), в строке не сказано.
Обход: в правиле «форк, второй взгляд…» заменить `"role": "consultant"` на `"tier": "consultant"`
(тир `consultant` существует; так же `steward`). Вход конформный, все критерии зелёные, а
`--prompt orchestrator` побайтно тот же — смена формы цели до промпта не дошла. Инв. 3 прямо
требует: «смену формы цели role↔tier». Проба этого не видит (её мутация role→tier берёт другое имя).
```
$ python3 exp.py e1     # одноразовый клон exp/e1
check rc=0 prompt_before rc=0 prompt_after rc=0 identical=True
  строка: class=форк, второй взгляд с проверкой по дереву → consultant
```

### Р998-2. Шаг CI запускает пробу не целиком (ПРОВОДКА, приёмка «Lane исполняет пробу целиком») — класс: проводка/отступ от замороженного текста
По frozen-тексту строка такая: `step	check:pravila-modelei-998	10	bash fixtures/pravila_modelei_998/probe.sh`
(без аргументов `probe.sh` делает `--cases`, затем `--matrix`; потребитель с той же формой
назван и в `.probe-only`). В `registry/ci-steps.tsv:133` (коммит 852402f40) стоит
`step	check:pravila-modelei-998	5	bash fixtures/pravila_modelei_998/probe.sh --cases`, плюс
3 строки комментария (ПЕРЕСЕЧЕНИЕ: «одна step-строка ниже»). Матрица различимости (57 клеток)
в CI не запускается ни одним шагом (grep по `registry/`, `.github/`, `scripts/`).
Обход: дерево, где барьер перестал различать (decoy_hardcoded.ts заменён честной моделью),
даёт lane rc 0, а замороженная команда — rc 1:
```
$ python3 exp.py e4     # одноразовый клон exp/e4
  probe.sh (без аргументов, frozen step) rc=1; lane rc=0
    census cases: исполнено 46, расхождений 0
    census matrix: исполнено 57, расхождений 1
$ bash scripts/run_ci_lane.sh check:pravila-modelei-998   # на OBJECT
+ bash fixtures/pravila_modelei_998/probe.sh --cases
census cases: исполнено 46, расхождений 0
lane_rc=0
```

### Р998-3. Барьер routing изменил режимы, которые 998 не правит (инв. 2, ПЕРЕСЕЧЕНИЕ 054) — класс: превышение области
Фрагмент: `scripts/gen-harness.ts:112-116` — `checkRoutingStrict` стоит на уровне модуля ДО
разбора `--agents-rules` (:184), `--resolve-overlay` (:229) и режима записи/`--into` (:248).
Frozen-текст: «Режимы `--into`, `--resolve-overlay`, `--agents-rules` 998 не правит
(ПЕРЕСЕЧЕНИЕ 054)»; «054 существующие фазы и режимы неизменны; добавляется только рендер
routing в --prompt orchestrator». Обход: на OBJECT все критерии зелёные, но при routing без
секции или с неизвестным ключом все три режима поменяли rc с 0 на 1. Лаунчер `workshop:555`
при этом печатает ложный диагноз («ссылка на семейство, которого нет … (секция models)»).
```
$ python3 exp.py e2     # клоны exp/e2-{pre,obj}-{drop,badkey}; pre = 22be79c07^
  pre drop: resolve-overlay rc=0 agents-rules rc=0 into rc=0 err=''
  pre badkey: resolve-overlay rc=0 agents-rules rc=0 into rc=0 err=''
  obj drop: resolve-overlay rc=1 agents-rules rc=1 into rc=1 err='FAIL routing: routing: секция отсутствует'
  obj badkey: resolve-overlay rc=1 agents-rules rc=1 into rc=1 err='FAIL routing: routing: неизвестный ключ «bogus»'
```

### Р998-4. roles/orchestrator.md: правка больше норма-строки, секция 016 разрезана (ПЕРЕСЕЧЕНИЕ «только норма-строка инварианта 7») — класс: превышение области
Коммит 165796834 вставил новый заголовок `## Выбор роли субагента по routing`, норма-строку
и 3 пустые строки МЕЖДУ заголовком `## Страж staged-коммитов активен (016)` (roles/orchestrator.md:160)
и его телом (:168-171: `core.hooksPath=.githooks` … «Не обходи `--no-verify`»). Теперь секция
016 пуста, а её норма попала под заголовок routing. Та же картина в производной
`.omp/agents/orchestrator.md:163-165`. Обход: `check_provodka` rc 0 и клетка
`orchestrator_role_norm` ok, а норма 016 в роли структурно потеряна.
```
$ git show 165796834 -- roles/orchestrator.md
 ## Страж staged-коммитов активен (016)
 
+## Выбор роли субагента по routing
+
+Выбор роли субагента — по routing … (Н-315).
+
+
+
 `core.hooksPath=.githooks` — pre-commit судит staged-множество …
```

### Р998-5. consultant §Модель противоречит сам себе (инв. 6, смысловой остаток — ловит reviewer) — класс: семантика замены
`roles/consultant.md:261` (§Модель) и сейчас говорит: «(сегодня семейства `@gpt-astra` и
`@opus`; решение владельца 2026-09-18, контракт 029)». Три строки ниже в той же секции стоит
новая норма «замена Astra — только Fable». В конфиге `tiers.consultant = {model: @gpt-astra,
fallback: @fable}`, в раскладке 2026-10-18 строка `consultant | Astra | **Fable**`. Обход: клетка
`consultant_norm` ok (проба судит только удалённый фрагмент и новую строку), а §Модель всё так же
называет фолбеком Opus — до решения норма не доведена.
```
$ sed -n '259,272p' roles/consultant.md
## Модель
Тир `consultant` … (сегодня семейства `@gpt-astra` и `@opus`; решение владельца 2026-09-18, контракт 029).
…
замена Astra — только Fable (см. `docs/owner/2026-10-18-raskladka-modelei.md`).
$ python3 -c "…print(d['tiers']['consultant'])"
{'model': '@gpt-astra', 'fallback': '@fable', …}
```

## Что проверено и зелёно (своей мерой)

| Проверка | Команда | Результат |
|---|---|---|
| Проба на OBJECT | `bash fixtures/pravila_modelei_998/probe.sh --cases` | `census cases: исполнено 46, расхождений 0`, rc 0 |
| Матрица | `bash fixtures/pravila_modelei_998/probe.sh --matrix` | `census matrix: исполнено 57, расхождений 0`, rc 0 |
| Красное до предмета | дерево 22be79c07^ + проба OBJECT, `--cases` | `исполнено 46, расхождений 39`, rc 1 (совпадает с frozen 46/39) |
| Lane | `bash scripts/run_ci_lane.sh check:pravila-modelei-998` | rc 0 (только `--cases`, см. Р998-2) |
| Генератор | `npm run --silent check:gen` | `харнес соответствует roles/ (10 ролей)`, rc 0 |
| Реестр↔workflow | `bash scripts/gen_ci_steps.sh --check` | rc 0 |
| ПРОВОДКА | `bash scripts/check_provodka.sh "$PWD" contracts/998-pravila-modelei.md` | rc 0 |
| Соседи | `npm run --silent check:antiplacebo -- --scope check_provodka` | `барьеров: 1 · фикстур: 28 · предъявлено красным повторным прогоном: 28`, rc 0 |
| Проба не переписана | `git diff --stat frozen/contracts/998/1 HEAD -- fixtures/pravila_modelei_998 contracts/998-pravila-modelei.md` | пусто, rc 0 |
| Frozen-барьеры | `git diff --stat 22be79c07^ 9aa86e73 -- scripts/check_*.sh scripts/verify_antiplacebo* fixtures/gen-harness fixtures/check_provodka` | только `fixtures/check_provodka/external_ci_994/probe.py`, это коммит 1e335460 architect по 087/994, к предмету не относится |
| Зоны | `git diff --name-only 22be79c07^ 852402f40` | 14 путей, все входят в ЗОНУ implementer (в ней 14 путей); автор всех 6 коммитов — `implementer <implementer@dev-harness.local>` |
| РАЗРЕШИЛ-ВЛАДЕЛЕЦ | `git log -1 --format=%B ff1d34213 \| sed -n 1p \| cmp - <(строка из контракта)` | cmp rc 0: первая строка сообщения дословна; строка перенесена в тело merge 9aa86e73 (строка 2) |
| AGENTS.md | `git show ff1d34213 -- AGENTS.md` | тронуты ровно два названных абзаца; старый абзац заменён на месте; `перевёрнуто`/`на MiniMax` отсутствуют |
| decisions/002, 005 | тот же diff | в каждом изменена только строка `решение:`; ссылка на `config/agent_models.json` §routing есть |
| implementer-glm | `diff roles/implementer.md roles/implementer-glm.md` | отличие только `role:` (rc 1, одна строка); производные отличаются только name/model/banner |
| Пара task-glm | конфиг | `@glm`=zai/glm-5.3, `@sonnet`=claude-sonnet-5-5, autoFallback true — совпадает с раскладкой (GLM-5.3 / Sonnet 5-5) |
| Норма-строка роли | `grep -cF '<строка инв. 7>' roles/orchestrator.md` | 1 — дословно |
| Смысл ссылок AGENTS.md/002/005 | ручная сверка с routing | убранное «тир `@vision` несёт кадры» покрыто правилом `кадры и картинки → tier vision`; «критик … своя роль модели» → в routing есть правило critic со ссылкой на decisions/005; «implementer на MiniMax» → правила implementer/implementer-glm. Смысловой потери нет |

ПРОВОДКА-каналы: role-канал на месте и дословен (grep 1, `check_provodka` rc 0). Guard
`probe.sh` подключён через `registry/ci-steps.tsv:133` и `.github/workflows/ci.yml:282`
(ключ в shard keys), но только с `--cases` (Р998-2). Поведенческая норма идёт role-каналом,
ПРОВОДКА-ЭНФОРСМЕНТ обоснован честно.

Предмет реализован, а не только оттестирован: рендер доходит до живой сессии через
`workshop:613/873` (`--prompt "$SESSION_ROLE"`), омп-агент `implementer-glm` порождён с
`model: ["@task-glm"]`, modelRoles/fallbackChains несут `task-glm`. Исключения — Р998-1..5.

## Паразитная сложность (контракт 050)

| Артефакт | (1) свойство | (2) состояние | (3) сколько файлов меняется вместе | (4) глубина | (5) потребитель | Класс |
|---|---|---|---|---|---|---|
| `roles/implementer-glm.md` + `.omp/agents/implementer-glm.md` | инв. 4 | нет | 2, как у любой роли | копия тела, интерфейса нет | modelRoles, routing | ESSENTIAL |
| тир `task-glm`, `roles.implementer-glm` | инв. 4 | конфиг, явно | 1 (+ производные генератором) | — | генератор, проба | ESSENTIAL |
| `validateRouting` (roles.ts) | инв. 1–2 | нет; результат — массив | 1 | интерфейс (am, ctx) ≪ работа | `checkRoutingStrict` | ESSENTIAL |
| `checkRoutingStrict` | инв. 1 «конфиг ⇒ routing» | нет | 1 | тонкая обёртка | gen-harness:112 | ESSENTIAL |
| `checkRouting` (roles.ts:213-218) + импорт gen-harness.ts:37 | нет — в дереве не вызывается ни разу | нет | +1 функция при каждой правке сигнатуры | мелкий дубль strict-версии | нет | **ACCIDENTAL** (Р998-6) |
| `RoutingProblem.path` | нет — читается только `message` | нет | — | поле без читателя | нет | ACCIDENTAL, совет |
| `renderRoutingSection` + `ROUTING_HEADER` | инв. 3 | нет | 1 | приемлемо | `--prompt orchestrator` | ESSENTIAL (дефект — Р998-1) |
| step-строка `check:pravila-modelei-998` + 3 строки комментария | ПРОВОДКА guard | нет | 2 (tsv + ci.yml) | — | CI | ESSENTIAL по факту, форма отступает от frozen (Р998-2) |

### Р998-6. ACCIDENTAL: `checkRouting` без потребителя — блокирует по норме 050
Фрагмент: `scripts/roles.ts:213-218` `export function checkRouting(...)` и `checkRouting` в
импорте `scripts/gen-harness.ts:37`. Отсутствующее свойство: ни один инвариант 998
нестрогого варианта не требует; вызывают только `checkRoutingStrict`. Форма проще: удалить
функцию и импорт — строки приёмки (проба, `check:gen`) их не трогают (grep по `fixtures`,
`scripts`, `workshop`: потребителей 0). Все три части названы, поэтому по норме 050 находка
блокирует. Вердикт FAIL держится на Р998-1..5 и без неё.

## Советы (не блокируют)

- Атомарность: 165796834 закрывает в одном коммите инв. 6 (consultant) и инв. 7 (orchestrator),
  22be79c07 — инв. 1–2 и инв. 4. Откатить по частям нельзя.
- Тело коммита 22be79c07 повреждено: «в scripts/roles.ts (//); вызывается…».
- Комментарий `gen-harness.ts:161-163` говорит «секция добавляется к телу отдельной пустой
  строкой». На деле пустой строки нет: `…строк СТОИТ нет.\n## Правила выбора роли…` (exp.py e3).
- Рендер проглатывает пустые строковые `constraint`/`until`/`conditional`/`emergency`
  (`if (c)`), хотя грамматика их принимает. Сверка ссылок делает `trim()`, рендер печатает
  значение как есть.
- `roles/consultant.md`: у `## Модель` пропала пустая строка после заголовка, и в конце файла
  добавлена лишняя пустая строка.
- Вес шага 5 против 10 по frozen. Это замер implementer (~5 с на `--cases`); с `--matrix`
  выходит ~7 с — пересчитать заодно с Р998-2.

## Сырые команды

```
git clone -q ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/Rev998r1/clone
git checkout -q 9aa86e735c0db07a342053ff2ddab6d90bbd81ef
git show 'frozen/contracts/998/1^{commit}:contracts/998-pravila-modelei.md'
bash fixtures/pravila_modelei_998/probe.sh --cases            # rc 0, 46/0
bash fixtures/pravila_modelei_998/probe.sh --matrix           # rc 0, 57/0
bash scripts/run_ci_lane.sh check:pravila-modelei-998         # rc 0
npm run --silent check:gen                                    # rc 0
bash scripts/gen_ci_steps.sh --check                          # rc 0
bash scripts/check_provodka.sh "$PWD" contracts/998-pravila-modelei.md   # rc 0
npm run --silent check:antiplacebo -- --scope check_provodka  # rc 0, 28/28
git diff --stat frozen/contracts/998/1 HEAD -- fixtures/pravila_modelei_998 contracts/998-pravila-modelei.md  # пусто
python3 /tmp/dev-harness-verify/Rev998r1/exp.py e1 e2 e3 e4    # репро Р998-1..3, только одноразовые клоны exp/
(exp/pre: 22be79c07^ + проба OBJECT) probe.sh --cases          # rc 1, 46/39
```
Скрипт репро: `/tmp/dev-harness-verify/Rev998r1/exp.py`. Мутации делались только в клонах
`/tmp/dev-harness-verify/Rev998r1/exp/*`.
