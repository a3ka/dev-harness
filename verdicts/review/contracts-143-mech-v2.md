accept
OBJECT=04a80b5a2bb0610a48061d54cbaebf185ac81e21
СУД: repo=Complior-mob (PR #145, ветка wip/143/implementer-v2, head 04a80b5a); предмет=143 mob-ci-razdelenie v2; фаза=суд реализации перед лендом (после Impl143v2 и Adv143v2 accept 566d006f); роль=reviewer; вызов=1/1 (полный); сессия=Rev143v2; модель-факт=anthropic/claude-opus-5-5 (семья автора — implementer; адверсарий — openai-codex); харнесс=frozen/contracts/143/2 (тег 3ca9d92f → c19c5abb0f4b814a4ed3c3f41a1c9d54591911c9); база дельты=2dbdf618950ed62b05a1af98de0febd38d6967ea.
Находки reslop: продукт `.review/2026-10-30-02.md` (status: ready), коммит `9e6c5db04e960318b832b5bbc3430a038bd21bea` (author reviewer) на ветке `wip/143/reviewer-v2` клона `/tmp/dev-harness-verify/Rev143v2/product`. Блокеров 0, советов 3 (С-1…С-3).

## Итог

Принимаю. Дельта — один коммит implementer из четырёх файлов зоны. Три кодовых файла совпадают с замороженными
моделями байт-в-байт: sha256 равны пинам `source.json`. Тела всех девяти job, кроме quality, побайтно равны базе.
Инвентарь отказывает именованно на каждом классе обхода. Красное-до воспроизведено моей мерой.
Мутанты, которые ломают механизм, краснеют. Живой CI #145 по составу сходится с картой.

## 1. Область правки

`git diff --numstat 2dbdf618..04a80b5a` → ровно 4 файла: `.github/workflows/mobile.yml` (+24/−8),
`STRUCTURE.md` (+29/−1), `mobile/ci-screens.json` (+2/−1), `mobile/scripts/select-ci-screens.cjs` (+106/−6).
`git rev-list --count` = 1 коммит. Автор `implementer <implementer@dev-harness.local>`, родитель `2dbdf618`.
Все четыре файла входят в `ЗОНА implementer` frozen 143/2 (контракт :166).
Пины не тронуты: `git diff --quiet 2dbdf618 04a80b5a -- mobile/scripts/ci-aggregate.cjs mobile/structure-policy.json`
→ rc 0. `mobile-e2e-retry.yml` отсутствует (`test -e` → 1).
Байт-в-байт с моделью — sha256 продукта против `source.json piny` (`model/…`):
- `mobile.yml` `6137aa57…0405e`;
- карта `85c23e1c…09e3`;
- селектор `866e9c1a…cefb7`;
- агрегат `83118c92…9ede1` (он же на базе).

Все четыре равны.

## 2. mobile.yml: legacy-тела и quality

Разбор YAML базы и OBJECT:
- верхние ключи (`name`, `on`, `permissions`, `concurrency`, `defaults`) равны;
- состав и порядок job одинаковы, 10 job;
- EQUAL по разбору и BYTE-EQUAL по сырому срезу текста каждого job: `select-screens`, `build-apk`,
  `e2e-splash`, `e2e-first-run`, `e2e-erstinformation`, `e2e-start`, `e2e-pilot`, `android-e2e`,
  `mobile-regression-signal`.

Пересечения 117/995/118/116/138/111/141/135/123/139 по байтам целы.

В quality из 21 шага изменён ровно один, шаг 16. Новое имя шага — «Инвентаризация пачек по карте и вынос H, батареи 117,
пачек экранов из дерева до lint». Что в нём:
- `node mobile/scripts/select-ci-screens.cjs --mode inventar --repo .` → `.json` и `.out` в namespace прогона;
- цикл `while read` по строкам `PACHKA *` с `test -n`/`test -d` → `mv` в
  `impl-pack-<basename>-<run_id>-<attempt>`;
- явные выносы H: `.harness`, `.harness117`, `.harness117b` и проба композиции 118.

Персональные `mv mobile/e2e-first-run` / `mv mobile/e2e-erstinformation` удалены. `npm test`/`lint`/`typecheck`/`doctor`
(шаги 17–20) стоят после выноса. Отказ селектора (rc 1) обрывает шаг через `set -e` ДО любого `mv`.

## 3. Селектор: именованные отказы `--mode inventar`

Моя мера: `inv_probes.py`, 13 одноразовых копий OBJECT, селектор исполнен на каждой.

| Проба | Итог |
|---|---|
| контроль | rc 0 `INVENTAR OK pachek=2 rabotnikov=5`; PACHKA: `mobile/e2e-erstinformation/`, `mobile/e2e-first-run/` |
| пачка без записи | rc 1 `PACHKA_BEZ_REGISTRACII` |
| флоу без записи | rc 1 `POTOK_BEZ_REGISTRACII` |
| снят `sluzhebnye_potoki` | rc 1 `POTOK_BEZ_REGISTRACII: mobile/.maestro/config.yaml` |
| symlink-пачка (с записью карты) | rc 1 `SYMLINK_PACHKI` |
| удалён pack | rc 1 `ZAPIS_BEZ_VHODA` |
| удалён флоу | rc 1 `ZAPIS_BEZ_VHODA` |
| отсутствует `legacy_entrypoint` | rc 1 `ZAPIS_BEZ_VHODA` |
| дубль job | rc 1 `DUPL_JOB` (адрес теряется — совет С-2) |
| pack карты вне грамматики | rc 1 `SKHEMA_PACHKI` (адрес теряется — совет С-2) |
| имя пачки на дереве вне алфавита | rc 1 `SKHEMA_PACHKI` |
| флоу двух владельцев | rc 1 `DUPL_VLADENIJA` |
| пустой реестр | rc 1 `PUSTOJ_REESTR` |

Итог: 13/13 по ожиданию.

Перечней в коде нет. `grep 'e2e-(splash|first-run|erstinformation|start|pilot)|first-run|erstinformation|splash'` по
`select-ci-screens.cjs` и `ci-aggregate.cjs` → 0 совпадений. Канон работников, пачек и флоу целиком выводится из карты.
Rev143 С-5 закрыт по построению.

## 4. Мутационные пробы (одноразовые копии, `mut.py`/`mut2.py`)

| Мутант | `W --repo` | Прочее |
|---|---|---|
| сужение P (убран `rehearsal.yaml` из `fiksirovannyj_nabor`) | rc 1, 78/80: `f01-fiksirovannyj-nabor-P`, `p01-P-nabor` КРАСНЫ | inventar rc 1 `POTOK_BEZ_REGISTRACII` |
| ручной вынос (inventar+цикл → два персональных `mv`) | rc 1, 79/80: `i05` `НЕТ_ИНВЕНТАРИЗАЦИИ` | — |
| вынос после lint (шаг переставлен за `npm test`/`lint`) | rc 1, 79/80: `i05` `LINT_UREZAN` | — |
| селектор без отказа `PACHKA_BEZ_REGISTRACII` | rc 1, 79/80: `i01` «пачка без регистрации: rc=0» | — |
| legacy `e2e-pilot` `timeout-minutes: 99` | rc 1, 79/80: `y08-tajmauty` | — |
| тело шага 995 (`e2e-pilot`, вставка `true`) | rc 0 | 141 `--repo` rc 1 `struktura-shag995 KRASNO (SKRIPT_RASHOZHDENIE…)` |
| тело шага 135 (`e2e-first-run`) | rc 0 | 141 `--repo` rc 1 |
| тело шага 118 (`e2e-erstinformation`) | rc 0 | 141 `--repo` rc 1 |
| тело `e2e-splash`: шаг digest и шаг 117 (нейтральная вставка `true`) | rc 0 | 141 rc 0 — **не пойман ни одним барьером**, совет С-1 |
| байт в `structure-policy.json` (хвостовой пробел) | rc 0 | пина нет; семантика не расширена — к критерию не относится |

Контроль OBJECT в том же прогоне: 143 rc 0 80/80, 141 rc 0.
Статическую пробу 117 (`.harness117` @4ac99af9) локально исполнить нельзя: без `node_modules` она падает
`UnboundLocalError: sign` — это среда, а не субъект. В CI она зелёная (quality success).

## 5. Батарея — своей мерой

- `W --repo <OBJECT>` → rc 0 «клеток 80, зелёных 80, красных 0». Число клеток моей мерой (`len(source.json.kletki)`) = 80.
- `W --model` → rc 0 80/80.
- `W --stabs` → rc 0 80/80, «стабов 62, привязок 78, непойманных 0». Моя мера: `len(stab_vhod)` = 62,
  сумма привязок = 78.
- Красное-до: `W --repo <worktree 2dbdf618>` → rc 1, 76/80; красны `i01` (`REZHIM: mode=inventar`),
  `i05` (`НЕТ_ИНВЕНТАРИЗАЦИИ`), `i08` (`INVENTAR_KARTY` на child-flow), `i09` (`policy_change` не поднят).
  Совпадает с докладом Impl143v2 (76/80, 4 именованных).
- Сосед, зависящий от продукта: 141 `--repo <OBJECT>` → rc 0.
- Батарея оставляет дерево чистым: `git status --porcelain` → 0 строк.

## 6. Живой CI #145

`gh pr view 145`: head `wip/143/implementer-v2` @ `04a80b5a…` = OBJECT, state OPEN.
Run 41092734429 (`mobile`, pull_request, headSha = OBJECT, run_attempt=1, единственный run ветки) → success:
- `select-screens`, `quality`, `build-apk` — success;
- `e2e-splash`, `e2e-first-run`, `e2e-erstinformation`, `e2e-start`, `e2e-pilot` — success;
- `android-e2e` — success;
- `mobile-regression-signal` — skipped (тело и `if:` побайтно равны базе; условие schedule/dispatch).

Лог `select-screens`: `VYBOROK 5 iz 5` — PR трогает общий слой, полный набор. Пять работников карты
(`ekrany[].job` ∪ `integracija.job`) = пять зелёных работников DAG. Сходится.
Лог quality: шаг инвентаризации исполнен, далее `Run npm run lint` — success. Ручного re-run нет.

## Проверки роли

1. Область — ровно зона, пины не тронуты (§1).
2. Сырой вывод — у меня есть по каждому числу (§1–§6). Доклад implementer пересказом не принимался: каждое его число
   перепроверено другой командой.
3. Проверки не подогнаны. Дельта не трогает ни одного теста или фикстуры. Батарея и модели исполнены с замороженного
   тега, а не из дерева автора.
4. Красное предъявлено: на базе 76/80 (§5), 6 мутантов механизма красны (§4).
5. Атомарность: один коммит на предмет 143 v2.
6. Норма не тронута. `STRUCTURE.md` — адресная зона implementer (контракт :158, закрывает Rev143 С-6), не
   нормативный документ харнесса. `structure-policy.json` blanket-исключением не расширен (файл не тронут).
7. Заявленное = сделанное:
   - 80/80, 62/78/0, 76/80 — моей мерой;
   - «4 файла» — `--stat`;
   - «тела legacy побайтово» — сырые срезы.

ПРОВОДКА (038): `guard=fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh` существует. Он подключён строкой
`registry/ci-steps.tsv:139 check:mob-ci-razdelenie-143-family-selftest … --stabs` и замером `ci-zamery.tsv:86`.
Guard — барьер именно предмета 143: его клетки судят субъект, это видно по мутантам §4. Энфорсмент-обоснование
честное, с оговоркой совета С-1: И-15 в замороженной формулировке — присутствие, байтовую дословность legacy guard не
держит.

СВЕРКА-СТАНДАРТОВ (`AGENTS.md:24` объявляет стандартом размещения `STRUCTURE.md`; ARCHITECTURE/CODING-STANDARDS не
объявлены):
- `STRUCTURE.md` §дерево `mobile/` — соответствует. `ci-screens.json`, `scripts/{select-ci-screens.cjs,ci-aggregate.cjs,rehearsal-evidence.sh}`
  существуют; `e2e-<screen>/` описан как выносимая пачка, не layout-зона.
- `STRUCTURE.md` §7.1 — соответствует:
  - поля карты есть в каждой записи (`child_flows`, `h_checkout`, `output_namespace`, `legacy_entrypoint` у start), `sluzhebnye_potoki` — на верхнем уровне;
  - имена отказов совпадают с кодом;
  - порядок «inventar до перемещения → lint после» совпадает с `mobile.yml` (шаги 16→17–20).
- `AGENTS.md:24` «новый слой — только с правкой `structure-policy.json`» — соответствует. Пачка не слой: она выносится
  до lint, policy не расширена (запрет контракта :158).
- Мобильный экран не затронут: сверка с макетом неприменима. `sourceCanon` (996) не объявлен.

Паразитная сложность (050) — по каждому новому или раздутому артефакту:
- **`--mode inventar` + `args_mode_vyhod` + `inventar.json`** (селектор).
  1. Свойство: И-13 (инвентаризация до выноса, адресные отказы).
  2. Состояние явно: аргументы `--mode/--repo/--out`, вывод — stdout `PACHKA`/`INVENTAR OK` + json, rc 0/1.
  3. При следующем экране меняется 0 файлов кода — только запись карты; было 2 (карта + персональный `mv`), стало меньше.
  4. Интерфейс: +1 значение `--mode`, тот же флаг `--out`. Работа: сверка дерева и карты по 4 классам. Модуль глубокий.
  5. Потребители: шаг 16 quality (stdout) и клетка i01 (json, `probe.py:2111-2138`). Логика разбора карты общая с
     выборочными режимами (`razberiKartu`), не дублирована.

  ESSENTIAL.
- **`sluzhebnye_potoki`** (карта).
  1. И-1 v2: служебный флоу без экранного владельца перечисляется явно.
  2. Явное поле карты.
  3. 1 файл.
  4. Одно поле.
  5. Потребитель — инвентарь `POTOK_BEZ_REGISTRACII` (проба «снят» → rc 1).

  ESSENTIAL.
- **Цикл выноса в quality** (`mobile.yml`).
  1. И-13 / Astra §2.2: обобщённый вынос.
  2. Явно: вход — `.out` селектора, выход — каталоги в namespace прогона.
  3. Следующий экран — 0 строк workflow на вынос (было +1 `mv`).
  4. 13 строк shell без новых флагов/env.
  5. Потребители — клетка i05 и lint. Грамматику не повторяет: имя пачки валидирует селектор.

  ESSENTIAL.
- **`child_flows` во владении, подписи и union + `DUPL_JOB`** (селектор).
  1. Сценарии 11/12 (i08/i09), И-1 v2.
  2. Явное поле карты.
  3. 1 файл.
  4. Интерфейс не вырос.
  5. Потребители — i08/i09/i01.

  ESSENTIAL.
- **`STRUCTURE.md` §7.1**.
  1. Контракт :158 (назначение pack и механизм выноса, Rev143 С-6).
  2. Состояния нет.
  3. 1 документ.
  4. —
  5. Читатель — автор следующего экрана. Повторяет таблицу владения из контракта в форме продукта: это допустимый
     перевод нормы в правило размещения, а не второй источник логики.

  ESSENTIAL.

Найденные упрощения: нет. Каждый артефакт пинован байт-в-байт моделью, более простая форма не проходит пин.

## Находки

Блокеров нет. Советы (`.review/2026-10-30-02.md`):
- **С-1 (совет → architect/владелец, 143 v+1).** Батарея 143 не держит байтовую дословность тел legacy-работников:
  нейтральная правка `e2e-splash` (digest, 117) зелена в 143 и в 141. Тела 135/118/995 держит 141.
  На OBJECT байты целы прямым сравнением. На freeze такой меры не было, поэтому это не FAIL.
- **С-2 (совет → architect, модель селектора).** `DUPL_JOB`/`SKHEMA_PACHKI` из разбора карты печатают `map head: head`
  без job/pack (`select-ci-screens.cjs:105`).
- **С-3 (совет → orchestrator, ленд).** Путь `verdicts/review/contracts-143-impl-v2.md` (и adversary-аналог) в харнессе
  уже занят вердиктом 143/1 cutover (`4fd9f5cf1`). Коммит на `wip/143/reviewer-v2` харнесса его перезаписывает —
  при ленде переименовать, если 143/1 должен остаться по своему пути.
