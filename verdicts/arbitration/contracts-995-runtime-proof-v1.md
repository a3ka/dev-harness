РЕШЕНИЕ
OBJECT=a60dfde5370ffd66f0f4faf15aecd956758143af

# Арбитраж 995 — что из Б1–Б3 круга 2 обязано получить механизм

МОДЕЛЬ: `anthropic/claude-opus-5-5`, арбитр (Arbiter995), 2026-10-18. Асимметрия семейства (`roles/arbiter.md`): я делю семейство с автором конструкции (architect). Единственный пункт, где решение не сводится к замеру, — Б3; он помечен ниже.

## Итог

- **Б1 (выбор рантайма в Metro) — БЛОКЕР.** Нужна проба bundle graph: две сборки `expo export`, разбор `sources` в source map. Это не придумка адверсария. Это прямая норма источника, который issue #5 сам указывает: Complior-mob `STRUCTURE.md:171` — «На внедрении runtime seam обязателен отдельный HTTP export/bundle graph check». Дефект невидим при чтении diff, цена — 9 с на режим (З-1).
- **Б2 (оракул demo-кода в env субъекта) — БЛОКЕР.** Это дефект самого харнесса, а не обход субъекта: `runtime_probe.py:99` кладёт ответ в env Jest-процесса, `runtime.test.tsx:18` читает его оттуда. Ещё одна деталь важнее: честная модель автора `runtime-model.ts:16` сама читает `process.env.PILOT_DEMO_CODE`. Исполнитель, который смотрит на тест, получает прямую подсказку сделать так же, и тогда APK примет любой код. Закрывается тремя мелкими правками (З-2) и шагом неверного кода в `pilot.yaml`.
- **Б3 (ApiClient/OpenAPI-типы/AuthProvider/раскладка слоёв) — ПРИНЯТЫЙ ОСТАТОК, cognitive-only, ловец reviewer по закрытому чек-листу.** Это вторая из двух форм, которые критик сам назвал допустимыми. Обязательна сопутствующая правка противоречия «тип в bootstrap ↔ ESLint B» (П5). tsc-проба ApiClient — НЕ условие.
- **Пограничное правило** (оно же ответ на вопрос «где граница»). Механизм обязателен, если неверная реализация проходит все команды и одновременно:
  - (а) выпускает дефект, видимый потребителю (вход без кода, Demo-auth в HTTP-сборке);
  - (б) дефект не виден при чтении diff.

  Если свойство структурное — файлы, слои, объявления типов — и видно в списке файлов и одном-двух файлах diff, то это cognitive-only с ловцом reviewer. Всё, что вне закрытого перечня К1–К8, в круге 3 не блокирует.
- **v+1 не нужна**: контракт не заморожен (тега `frozen/contracts/995/*` нет). Architect правит черновик на `wip/995/architect` по П1–П7. **Нужен круг 3 критика** с закрытым предметом К1–К8. FAIL круга 3 по тому же предмету уходит к владельцу.

## Созыв и первоисточники

Созвал критик строкой вердикта круга 2 (`c8eb5d596:verdicts/critic/contracts-995-krug2-fail.md`, правило 15). Основание: второй FAIL по предмету блокера 1 круга 1 (`7eddbc66b:verdicts/critic/contracts-995-krug1-fail.md`).

Прочитаны полностью:
- оба вердикта;
- контракт и `fixtures/workshop_project/pilot_995/` на OBJECT (собственный ssh-клон `arbiter995/dh`, `rev-parse HEAD` = OBJECT, `git status` пуст);
- тело issue `a3ka/Complior-mob#5`;
- `STRUCTURE.md` §4–5 и `mobile/eslint.config.js` снимка B=f86eb28;
- образцы `contracts-993-cas-narrowing-v1.md` и `contracts-994-closed-class-v1.md`.

Факты по закрытию блокеров круга 1 (п. 1–5 вердикта круга 2) я не оспариваю, они вне спора.

## Замеры

Все замеры — в `/tmp/dev-harness-verify/arbiter995/`.
- `c3/` — `cp -a` дерева C3 критика (`critic995r2/c3`), только пути зоны implementer.
- Пробы H запускались из `dh/` на OBJECT.

**З-1. Б1, bundle graph** (`measure_b1.sh`, sha256 `072433d5…e089e688`; разборщик `bundle_graph.py` = копия критика, `544daea6…44a0`):

```
# metro.config.js из C3 (всегда mocks/runtime.ts)
bad http export rc=0 t=9s   src/mocks/demo-code.ts src/mocks/runtime.ts   mocks-in-graph=2 http-runtime-in-graph=0
bad mock export rc=0 t=8s   src/mocks/demo-code.ts src/mocks/runtime.ts   mocks-in-graph=2 http-runtime-in-graph=0
# тот же C3 + critic995r2/honest_metro.js (277e6e50…dc4d)
honest http export rc=0 t=9s  src/bootstrap/http-runtime.ts               mocks-in-graph=0 http-runtime-in-graph=1
honest mock export rc=0 t=8s  src/mocks/demo-code.ts src/mocks/runtime.ts mocks-in-graph=2 http-runtime-in-graph=0
```

Факт критика подтверждён. HTTP-сборка C3 несёт Demo AuthProvider при зелёных пробах H. Признак различает честный и ложный metro одной парой сборок без эмулятора.

**З-2. Б2, канал env** (`make_probe_mod.py`, `2ac28e34…26a8`, делает одноразовую копию `probe_mod/` с двумя правками: `runtime.test.tsx:18` → литерал, `runtime_probe.py:99` → без `PILOT_DEMO_CODE`):

```
H runtime_probe        на C3 (demo-code.ts = process.env.PILOT_DEMO_CODE)  → 6/6 rc=0, RC=0
probe_mod runtime_probe на C3                                              → SHIPPED_INVALID rc=1 «Unable to find … auth-invalid», F02.01 на экране; RC=1
probe_mod runtime_probe на C3 с demo-code.ts = 'synthetic-verification-value' → 6/6 rc=0, RC=0
probe_mod --model honest --case SHIPPED_VALID                              → rc=1  (runtime-model.ts:16 сам читает env)
```

Без канала env обход C3 красен, честный литерал зелён. Последняя строка показывает другое: авторская честная модель зависит от того же оракула, значит правка обязана тронуть и `runtime-model.ts`.

**З-3. Совет «тип в bootstrap».** Замер чтением конфигурации снимка B, `mobile/eslint.config.js:17–18`: `./src/mocks` входит в target зоны «Lower layers cannot depend on screens/composition» с from `./src/bootstrap`. Эта зона в `baseZones` и действует на все `src/**` (`:44–46`). Значит `mocks/runtime.ts` не может импортировать тип из `src/bootstrap/runtime-contract.d.ts`. Импорт из `src/api`/`src/auth` этой зоной не запрещён (`STRUCTURE.md:167`: «Mock может импортировать общие API/auth-типы»). Формулировка `:42` контракта толкает исполнителя к нетипизированному mock — ровно то, что показал C3 (`Promise<unknown>`).

**З-4. Совет `global`.** C3 с `types: ["jest"]` как в B (`tsc --noEmit`, одноразовый сниппет удалён):

```
arb-global.test.ts(4,19)/(5,1): TS2304 Cannot find name 'global'   (globalThis.fetch — без ошибок)
pilot.test.tsx(127,22)/(129,5)/(136,14)/(138,7): TS2304 Cannot find name 'global'   RC=2
```

Frozen-байты, которые исполнитель менять не вправе, ломают обязательный typecheck CI на tsconfig B. `globalThis` проходит.

**З-5. Генератор OpenAPI-типов.** В `node_modules` C3/B нет генератора: из подходящих пакетов только `typescript` и `eslint-import-resolver-typescript`. `:90` контракта запрещает добавлять зависимости. «Типы OpenAPI» в Работе 1 исполнимы только скриптом без зависимостей или ручными типами двух операций. Контракт это не называет.

## Решение по пунктам

### Б1 — БЛОКЕР (отдан критику)

Jest-путь (`runtime_probe`) проверяет `jest.config.js`, а не Metro. Две конфигурации выбора независимы, и C3 расходит их без единой красной команды (З-1). Признаки обоих условий пограничного правила:
- (а) HTTP-сборка с Demo-auth, принимающим вход;
- (б) `metro.config.js` из C3 выглядит правдоподобно, а бандл reviewer не видит.

Норма источника `STRUCTURE.md:171` делает проверку обязательной при внедрении seam. Контракт ссылается на `:163–167` и обходит её. Минимальная проба: две сборки по ~9 с и разбор source map. Проверка байтов APK, HTTP-сценарий на устройстве и Metro для неизвестного mode **не требуются**:
- байты APK — тот же Metro-граф;
- HTTP-поведение уже проверяет `runtime_probe` HTTP_UNAVAILABLE, а граф доказывает, что в HTTP-сборке исполняется именно `http-runtime.ts`;
- неизвестный mode отвергает bootstrap в рантайме, то есть отказ закрытый.

### Б2 — БЛОКЕР (отдан критику)

`:44` утверждает «runtime_probe передаёт его только тесту», а это ложно (`runtime_probe.py:99`, З-2). ЗАЩИЩАЕТ `:100` («от подмены ожиданий диском субъекта») нарушен каналом, который открыл сам харнесс. Это не адверсариальная выдумка, а реалистичная ошибка честного исполнителя по образцу теста и модели. На отгружаемом APK она означает: неверный код создаёт сессию (issue: «Неверный код… доступны без сервера»). Механизм дешёв:
1. литерал в тесте;
2. env очищен, включая унаследованный;
3. литерал в модели;
4. мутант env-code в матрице.

Шаг неверного кода в `pilot.yaml` обязателен как ловец на устройстве для остатка «ветвление по test-env», уже объявленного cognitive-only в `:48`. Это четыре строки frozen flow, и они проверяют центральное отрицательное свойство на самом артефакте. Иные test-env ветвления (`NODE_ENV`, `JEST_WORKER_ID` и т.п.) в Jest — НЕ блокер круга 3: их держат `:48` (reviewer) и этот device-шаг.

### Б3 — ПРИНЯТЫЙ ОСТАТОК, cognitive-only (форма, названная самим критиком)

Решение не сводится к замеру — здесь действует асимметрия семейства, записываю явно.

Доводы:
- Отсутствие `src/api/`, `src/auth/`, `features/auth/`, `features/onboarding/` и тип `Promise<unknown>` видны в списке файлов PR и в одном файле интерфейса. Условие (б) пограничного правила не выполнено.
- Видимое потребителю поведение данных уже механически держат `schema_probe` (значения по схемам OpenAPI в живом runtime) и `runtime_probe` (вызовы runtime.auth/api).
- tsc-проба доказала бы лишь «тип не `unknown`», но не «тип из OpenAPI»: ручной DTO с `principal_ref: string` её проходит. А происхождение типов при запрете зависимостей (З-5) всё равно остаётся чтением reviewer. Вывод: механизм дал бы частичное доказательство ценой нового пина имён экспорта.
- Правило триажа владельца (2026-09-24) относит такой случай к принятому остатку.

Решающий довод — критик сам предложил эту форму как достаточную альтернативу («либо явная cognitive-only пометка… ловцом reviewer»). Предпочтение автора здесь не решало.

Обязательная сопутствующая правка — П5. Без неё reviewer не может проверить «mock типизирован интерфейсами», а исполнитель упирается в ESLint B (З-3).

### Советы круга 2, поднятые до обязательных

Оба — правила триажа «портит реальную работу»:
- «тип в bootstrap» → П5 (З-3);
- «`global` в frozen-тесте» → П6 (З-4).

Совет «synthetic-код записан трижды» остаётся советом. «Ссылка `:163–167` короче нормы» поглощается П1.

Счёт по сторонам:
- Б1 и Б2 — критику целиком;
- Б3 — в форме, которую назвал сам критик; от механизма автор освобождён;
- два совета критика стали обязательными.

## Пункты правки для architect (П1–П7)

**П1 — Б1, bundle graph.**
- (а) Новая проба в `fixtures/workshop_project/pilot_995/` (имя на выбор architect'а, далее `bundle_probe.py`): `--repo R`. Для каждого mode из {http, mock}:
  - `EXPO_PUBLIC_API_MODE=<mode> npx expo export --platform android --source-maps --clear --output-dir <временный каталог вне отслеживаемых путей R>`;
  - разбор `sources` всех `*.map`, нормализация к `src/…`.

  Ожидания и rc:
  - http: нет ни одного `src/mocks/`, есть `src/bootstrap/http-runtime.ts`;
  - mock: есть `src/mocks/runtime.ts`, нет `src/bootstrap/http-runtime.ts`;
  - нарушение → rc1 с именем (например `BUNDLE_HTTP_HAS_MOCKS`, `BUNDLE_HTTP_RUNTIME_ABSENT`, `BUNDLE_MOCK_HAS_HTTP_RUNTIME`);
  - export rc≠0 или нет source map → rc2 INFRASTRUCTURE;
  - на B, где seam отсутствует, → rc1 с именем.

  После прогона `git status --short` в R пуст: gitignored `.expo/` допустим.
- (б) `--matrix` → rc0. Строки:
  - honest — model-composition, rc0;
  - `metro-always-mock` — красна на http;
  - `metro-always-http` — красна на mock.

  Привязка мутант→причина живёт в коде пробы, как в `runtime_probe.MUTANTS`.
- (в) Буллет критерия после `:56` и та же проба в CI-списке `:68` рядом с `runtime_probe.py`/`schema_probe.py`.
- (г) В `:42` ссылку «STRUCTURE.md:163–167» расширить до `:163–171` и назвать пробу из (а) механизмом утверждения «Metro выбирает…».

**П2 — Б2, оракул.**
- (а) `runtime.test.tsx:18`: demo-код — литерал, как `pilot.test.tsx:8`.
- (б) `runtime_probe.py`: Jest-env субъекта не содержит `PILOT_DEMO_CODE`. Ключ явно удаляется и из унаследованного `os.environ`, а не только не добавляется.
- (в) `runtime-model.ts:16`: honest-модель сверяет с литералом, не с env.
- (г) `MUTANTS` + режим модели `env-code`: verify читает `process.env.PILOT_DEMO_CODE` и принимает при `undefined`. Ожидание: красен на `SHIPPED_INVALID` с причиной `auth-invalid`.
- (д) `:44`: фразу «runtime_probe передаёт его только тесту» заменить истинной: «demo-код в `src/mocks/demo-code.ts` — литерал. Ни runtime_probe, ни CI не передают его субъекту через env. PRIVATE_FILE читает только Maestro-runner».

**П3 — Б2, ловец на устройстве.** В `pilot.yaml` до ввода верного кода:
- ввод заведомо неверного кода → `assertVisible id: auth-invalid` → `assertNotVisible id: F02.01`;
- затем очистка поля и верный `${PILOT_DEMO_CODE}`.

Неверный код — литерал flow, не производный от секрета. Ожидание для APK B в `:59` не меняется (B падает раньше, на `first-run-continue`). В `:59` перечислить этот шаг. Android остаётся NOT_RUN; круг 3 судит шаг по тексту flow и по `native_matrix`, если её ROWS затронуты.

**П4 — Б3, cognitive-only.**
- В `:40` (или отдельным абзацем после `:48`) пометка **cognitive-only**. Остаточный риск: «ApiClient/AuthProvider, происхождение типов и раскладка F03/F02 по слоям механически не проверяются; поведение данных держат schema_probe/runtime_probe». Ловец — reviewer, закрытый чек-лист:
  1. `src/api/api-client.ts` экспортирует интерфейс ApiClient. `getSession`/`getDisclosure` возвращают типы из источника, названного в П5(б); не `unknown`/`any`.
  2. В `src/auth/` лежит интерфейс AuthProvider, Demo-реализации там нет.
  3. `mocks/runtime.ts` и `bootstrap/http-runtime.ts` аннотированы этими интерфейсами.
  4. Экраны F03 — в `features/auth/`, F02 — в `features/onboarding/welcome-screen.tsx`, pending-intent — в `navigation/pending-intent.ts`.
- В НЕ ЗАЩИЩАЕТ (после `:105`) буллет: «от неполного ApiClient/AuthProvider или иной раскладки слоёв при зелёных пробах — принятый остаток арбитража 995, ловец reviewer по чек-листу П4».

**П5 — тип рантайма совместим с ESLint B.**
- (а) В `:42` интерфейсы живут в `src/api/api-client.ts` (ApiClient) и `src/auth/` (AuthProvider). `src/bootstrap/runtime-contract.d.ts` только собирает `runtime: {auth: AuthProvider; api: ApiClient}` из них. `mocks/runtime.ts` типизирует себя импортом из `@/api`/`@/auth`, не из bootstrap.
- (б) Одной фразой назвать источник OpenAPI-типов, совместимый с «зависимости не добавлять» (`:90`). Варианты на выбор architect'а:
  - скрипт без зависимостей, генерирующий `src/api/generated/` из read-only схемы с записью версии/хэша источника;
  - ручные типы двух операций со ссылкой на компоненты `api/mock-5_8.json`.
- (в) В «Фактическом замере» приложить живой прогон ESLint B:
  - файл `src/mocks/…`, импортирующий тип из `@/api/api-client`, — lint rc0;
  - тот же файл с импортом из `../bootstrap/runtime-contract` — rc1 `import/no-restricted-paths`.

  Это свидетельство, а не постоянная проба.

**П6 — frozen-тест проходит typecheck B.** В `pilot.test.tsx:127–138` (и для единообразия `runtime.test.tsx:38–46`) `global` → `globalThis`. Приложить: копия B + frozen `pilot.test.tsx`/`source.json` + model-composition → `tsc --noEmit` без TS2304 из frozen-файлов.

**П7 — предъявление на новом коммите.** Живые rc:
- `bundle_probe --matrix` rc0 и время;
- `bundle_probe` на дереве C3 критика (`critic995r2/make_r2.py`) → rc1 `BUNDLE_HTTP_HAS_MOCKS` (или эквивалентное имя);
- `runtime_probe --matrix` rc0 с новым `env-code`;
- `runtime_probe` на C3 → rc1 на `SHIPPED_INVALID`;
- прежние матрицы `probe`/`schema`/`transport`/`frozen`/`native` — rc0;
- `pre_critic.sh`, `check_threat_model.sh` — rc0;
- свидетельства П5(в), П6.

## Закрытый перечень круга 3 (К1–К8)

Критик круга 3 судит только эти признаки:

- **К1.** Команда bundle-graph в критерии и в CI-списке `:68`. На honest rc0. На C3 http красен с именем. `--matrix` rc0, оба metro-мутанта красны на своих режимах.
- **К2.** Jest-env runtime_probe не содержит `PILOT_DEMO_CODE`, в том числе унаследованного. `runtime.test.tsx` и honest `runtime-model.ts` берут код литералом. C3 красен на `SHIPPED_INVALID`. `env-code` в матрице красен там же.
- **К3.** В `pilot.yaml` шаг неверного кода (`auth-invalid` видим, `F02.01` не видим) стоит до верного. `:59` его называет.
- **К4.** Текст `:44` соответствует П2(д). ЗАЩИЩАЕТ `:100` больше не противоречит харнессу.
- **К5.** Пометка cognitive-only по Б3 с чек-листом П4 и буллетом НЕ ЗАЩИЩАЕТ.
- **К6.** `:42` по П5(а). Источник типов назван (П5(б)). Свидетельство lint П5(в) приложено.
- **К7.** Frozen `pilot.test.tsx` без TS2304 на tsconfig B (П6).
- **К8.** Прежние команды `:54–58`, `:62` сохраняют заявленные rc.

**Не является блокером круга 3** (решено здесь):
- tsc- или existence-проба ApiClient/AuthProvider/слоёв;
- происхождение типов сверх П5(б);
- иные test-env ветвления в Jest (держат `:48` и К3);
- байты mock в APK сверх Metro-графа;
- HTTP-сценарий на устройстве;
- Metro для неизвестного mode;
- единый источник synthetic-кода;
- советы круга 1 и 2, не поднятые здесь до П.

Новый мутант блокирует, только если он нарушает пункт К1–К8 и остаётся зелёным.

## Несогласие сторон

Письменного несогласия architect'а в первоисточниках нет. Факты критика по Б1 и Б2 воспроизведены (З-1, З-2), по советам — тоже (З-3, З-4). Против критика решена только форма закрытия Б3, и то в пределах двух вариантов, которые назвал он сам.

## Артефакты

`/tmp/dev-harness-verify/arbiter995/`:
- `dh/` — ssh-клон на OBJECT, не изменён;
- `c3/` — копия C3 критика. Изменены для замеров: `metro.config.js` = `honest_metro.js` (З-1), `src/mocks/demo-code.ts` = литерал (З-2), `tsconfig.json` types `["jest"]` (З-4);
- `probe_mod/` — одноразовая копия проб с правками З-2;
- `measure_b1.sh`, `make_probe_mod.py`, `bundle_graph.py`;
- `exp-{bad,honest}-{http,mock}/` — экспорты и логи.

Основной чекаут не тронут, push не делался, read-only каталоги критика не изменялись. Вердикт не закоммичен (запрет Н-85 в брифе). Коммит под `user.name=arbiter` в `verdicts/arbitration/` выполняет вызвавшая сторона. Предлагаемое имя: `verdicts/arbitration/contracts-995-runtime-proof-v1.md`.
