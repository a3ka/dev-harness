FAIL
OBJECT=906be027380f73023bd2d83ac500f06800ad4a10
СУД: repo=dev-harness; предмет=151; фаза=контракт (+красная батарея), scoped; роль=critic; вызов=2/2 (scoped); модель-план=anthropic/claude-opus-5-5; сессия=Crit151b; модель-факт=anthropic/claude-opus-5-5; SHA=906be027380f73023bd2d83ac500f06800ad4a10; предыдущий=verdicts/critic/contracts-151-v1-fail.md (FAIL, OBJECT 5a31eb661, сессия Crit151, 6 блоков); исключение=нет. Автор OBJECT: architect (Arch151y → fd8611445, Arch151z → 906be0273), openai-codex/gpt-6-sol. Судья из семейства anthropic, автор из openai-codex, независимость соблюдена. КЛАСС РИСКА=обычный, вердикт его не оспаривает.

Итог. Дельта закрыла три класса Crit151 из шести: политику (2), realm/множество имён (4) и зависимость (6). CI-маршрут без секрета согласован с грамматикой зон и с 143. Три класса остались открытыми, и это ПОВТОР причины. Каждый подтверждён исполнением: обманная реализация проходит `CASE 765 GREEN 765 RED 0` с rc 0 и нарушает названное обязательство текста.
- (1) Домен моментов. Дельта удалила клетку `(GA-T35, 0)` круга 1, а обязательство «Ранний `at=0` вместо 500 даёт `null`» осталось в тексте. Мутанты `at===0`, `Math.ceil` и `Math.round` зелёные.
- (3) Завершение SDK. Клетка SETTLES держит промис SDK только две микрозадачи. Мутант с таймаут-гонкой зелёный, а `playHaptic` разрешается при SDK, всё ещё pending через 200 мс.
- (5) Песочница ≠ продукт. Проба кладёт полную матрицу ожиданий (`otdacha.test.js`) в каталог субъекта под предсказуемым именем. Модуль без карты, читающий её через `fs`, проходит `W --repo` с rc 0, а в раскладке продукта падает ENOENT.

Бюджет 2/2 исчерпан, причина повторилась, поэтому созываю арбитра (строка АРБИТР ниже). Расхождений САМООПИСАНИЯ — одно, механическое. Правило 31.10 «FAIL только по самоописанию → форк консультанту» неприменимо: блоки содержательные.

АРБИТР: роль arbiter, тир `plan` из `config/agent_models.json` = Fable (anthropic/claude-fable-5-1). Fallback Astra на этом предмете НЕДОПУСТИМ: openai-codex/gpt-6-astra здесь уже consultant (Consult151c и свидетельство класса форка n-151), а consultant и arbiter одной моделью на одном предмете не совмещаются. При отказе Fable — стоп и вопрос владельцу. Предмет спора: достаточно ли закрытия классов 1/3/5 перечнем точек, который автор вывел из закрывающих свойств Crit151, или требуется свойство над доменом исполнением (урок арбитража 148/153). Сюда же: часть дефекта (1) — недоопределённость моего же закрывающего свойства круга 1 («дробный момент» в единственном числе, `at=0` не назван), и арбитр решает, сколько из неё вменять автору. Решение арбитра не даёт accept и не открывает третий вызов критика (§Остановка).

## Линия коммитов (сверено до разбора)

`git cat-file -t 906be027…` → commit. В истории OBJECT нет коммита дельты `afe421f97` из задания: ветка перебазирована, на OBJECT это `fd8611445` с тем же содержимым путей 151 (`git diff --stat afe421f97 fd8611445` показывает только форк/вердикт базы). `5a31eb661` не предок HEAD. Его дерево по путям 151 равно `65a474ed9` (`git diff --stat 5a31eb661 65a474ed9` пуст). Предмет суда — `git diff 8fa821a25..906be0273` (4 файла: контракт, model.js, otdacha.test.js, probe.py).

## Сырые команды (cwd = клон `/tmp/dev-harness-verify/Crit151b/repo` на OBJECT; R=/tmp/dev-harness-verify/Impl147e/mob, `git -C R status --porcelain | wc -l` → 0; W=fixtures/workshop_project/gespraech_otdacha_151/red_gespraech_otdacha_151.sh)

```
bash W                                   → SUBJECT_ABSENT: mobile/src/lib/otdacha/index.ts            rc=1
bash W --repo R                          → SUBJECT_ABSENT: …/Impl147e/mob/mobile/src/lib/otdacha/index.ts rc=1
bash W --model                           → INFRASTRUCTURE: --runtime R or --repo R …                  rc=2
bash W --model --runtime R               → CASE 765 GREEN 765 RED 0                                    rc=0 (1.6 с)
MOB_151_RUNTIME=R bash W --model         → CASE 765 GREEN 765 RED 0                                    rc=0
bash W --stabs --runtime R               → 18 строк STAB … KRASEN <свидетель>; SVJAZI 18 CASE 765        rc=0 (28 с)
   ios-only EMIT_ANDROID_GA_T28_0_E1_V1_Q0 · android-only EMIT_IOS_GA_T28_0_E1_V1_Q0 · weak-long EMIT_IOS_GA_T35_500_E1_V1_Q0
   early-long ABSENT_IOS_GA_T35_499 · late-r2 PATTERN_IOS_GA_R2_4820 · ignore-quiet …_Q1 · ignore-vibration …_V0_Q0
   ignore-disabled …_E0_V1_Q0 · selection-impact EMIT_IOS_GA_T30_0_E1_V1_Q0 · deferred-disabled · double-delayed
   threshold ABSENT_IOS_GA_T28_1 · oracle-cache PATTERN_IOS_GA_T28_0 · global-test PATTERN_IOS_GA_T28_0
   no-await SETTLES_AFTER_SDK_IOS_GA_T28_0 · swallow REJECTS_AFTER_SDK_IOS_GA_T28_0
   model-in-product PRODUCT_MODULE_RESOLUTION · fake-dependency DEPENDENCY_ABSENT
bash scripts/pre_critic.sh --repo . contracts/151-…        → ok гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=6; КРИТИК: дверь зелёная rc=0
bash scripts/check_ceilings.sh                              → потолки в порядке                        rc=0
bash scripts/check_precision_gate.sh . contracts/151-…      → OK                                       rc=0
bash scripts/check_threat_model.sh . contracts/151-…        → секция валидна (ЗАЩИЩАЕТ 2, НЕ ЗАЩИЩАЕТ 3) rc=0
bash scripts/check_provodka.sh . contracts/151-…            → (пусто)                                  rc=0
   негативный контроль: копия контракта, где фраза 994 «Общий CI dev-harness не получает зависимость от внешнего checkout.»
   заменена на «Общий CI харнесса батарею не исполняет.» → «проводка: guard не подключён: …red_gespraech_otdacha_151.sh» rc=1
bash scripts/check_predposylki.sh . contracts/151-… --freeze → PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=6 rc=0
bash scripts/check_zones.sh --incr /tmp/dev-harness-verify/Crit151b/zones-cache .
   → полный прогон (кеш сторонней линии): замороженных контрактов 147 · авторов 5 · коммитов 41004 · проверено по зонам: 9743   rc=0 (6 мин 17 с); кеш → 906be027…
```
Гейты прогонялись последовательно. Кеш зон — копия моего кеша круга 1 (база 5a31eb66), поэтому прогон полный: «кеш сторонней линии».

Атаки. Одноразовые скрипты лежат в `/tmp/dev-harness-verify/Crit151b/attack/`: `run_attacks.py`, `run_negatives.py`, `observe.js`, `observe_fs.js`. Режим `--model`: копия каталога фикстуры с изменённым `model.js`, запуск `python3 <копия>/probe.py --model --runtime R`, проба автора без изменений. Режим `--repo`: одноразовый продукт X, в котором `mobile/package.json` и `package-lock.json` — это файлы R плюс `expo-haptics` `~57.0.3` (lock: version 57.0.3, resolved https, integrity). Там же `mobile/node_modules/` с symlink на каждый пакет R плюс `expo-haptics/package.json` 57.0.3, а `jest.config.js`/`jest.setup.ts` и designer-copy взяты из R. Наблюдения сняты node-скриптом с управляемым стабом SDK, вне Jest.

```
[ceil]                 model.js: time === Math.ceil(at)               → CASE 765 GREEN 765 RED 0 rc=0
[round]                model.js: time === Math.round(at)              → CASE 765 GREEN 765 RED 0 rc=0
[touchdown-at0]        model.js: (time === at || at === 0)            → CASE 765 GREEN 765 RED 0 rc=0
[race-timeout-50ms]    SDK-вызов через Promise.race([sdk, setTimeout 50 мс]) → CASE 765 GREEN 765 RED 0 rc=0
[race-20-microticks]   SDK-вызов через Promise.race([sdk, 20 микрозадач])    → CASE 765 GREEN 765 RED 0 rc=0
[sniff-jest]           (typeof jest !== 'undefined' ? time === at : time <= at) → CASE 765 GREEN 765 RED 0 rc=0
[truthy-flags]         !policy.enabled || !policy.vibrationEnabled …  → CASE 765 GREEN 765 RED 0 rc=0
[loose-eq]             time == at                                     → CASE 765 GREEN 765 RED 0 rc=0
[flag-undefined-passes] policy.quietMode === true                     → KRASNO UNKNOWN_FLAG_{IOS,ANDROID}_GA_T28_0_quietMode_{MISSING,NULL}; CASE 765 GREEN 761 RED 4 rc=1
[honest-control-map-inside] W --repo X (model с ./map.json внутри каталога)  → CASE 765 GREEN 765 RED 0 rc=0
[fs-read-probe-test]   W --repo X (index.ts без карты: fs.readFileSync(__dirname/otdacha.test.js), JSON из `const cases = …`)
                                                                      → CASE 765 GREEN 765 RED 0 rc=0
[model-verbatim-M6]    W --repo X                                     → KRASNO PRODUCT_MODULE_RESOLUTION …; CASE 765 GREEN 0 RED 765 rc=1

Наблюдения (observe.js; HONEST = model.js автора):
HONEST         patternFor(GA-T35,0)=null; (GA-T35,499.3)=null; (GA-T35,499.6)=null; (GA-T35,'500')=null; enabled:1 → SDK 0; SDK pending 200 мс → playHaptic finished=false
touchdown-at0  patternFor(GA-T35,0)={"ios":"impactOccurred(.medium)","android":"LONG_PRESS"}
ceil           patternFor(GA-T35,499.3) и (GA-T35,499.6) = {"ios":"impactOccurred(.medium)","android":"LONG_PRESS"}
round          patternFor(GA-T35,499.6) = {"ios":"impactOccurred(.medium)","android":"LONG_PRESS"}
race-timeout-50ms / race-20-microticks   SDK pending 200 мс → playHaptic finished=true
truthy-flags   enabled:1 → SDK вызовов 1
loose-eq       patternFor(GA-T35,'500') = {"ios":"impactOccurred(.medium)",…}
observe_fs.js  fs-read-модуль в раскладке продукта без файла пробы → patternFor(GA-T28,0) THROWS ENOENT … mobile/src/lib/otdacha/otdacha.test.js
probe.case_matrix: моменты ABSENT у GA-T35 = [499, 500.5, 501]; 'ABSENT_IOS_GA_T35_0' в ожидаемом множестве: False;
   сцены без момента 0 и без клетки at=0: GA-R2, GA-R2-393, GA-R3, GA-R3-393, GA-T21, GA-T22, GA-T35
git show 5a31eb661:fixtures/…/otdacha.test.js:60 → for (const [scene, at] of [['GA-UNKNOWN', 0], ['', 0], ['GA-T28', -1], ['GA-T35', 0]])
```

Негативы приёмки (`run_negatives.py`):
```
пустой haptics оракула на диске, --model --runtime R     → ORACLE_DESIGN_DRIFT rc=2
лишняя клетка в шаблоне теста, --model --runtime R        → CASE_SET_MISMATCH expected 765 actual 766; CASE 766 GREEN 766 RED 0 rc=1
M6 (model.js дословно как index.ts), W --repo X           → KRASNO PRODUCT_MODULE_RESOLUTION присутствует; rc=1
expo-haptics "~14.0.0" в package.json, W --repo X        → DEPENDENCY_ABSENT rc=1
expo-haptics не установлен (нет node_modules/expo-haptics) → DEPENDENCY_ABSENT rc=1
designer-copy X изменена (LONG_PRESS→VIRTUAL_KEY)         → ORACLE_DESIGN_DRIFT rc=2
```

## Закрытие классов Crit151

|класс|закрывающее свойство круга 1|состояние на OBJECT|
|---|---|---|
|1 домен моментов|тишина на КАЖДОМ моменте вне карты, моменты из оракула, обе платформы|НЕ закрыт: БЛОКИРУЕТ Б1|
|2 политика|эмиссия только при true/true/false; missing/undefined/null подавляет|закрыт: 12 клеток UNKNOWN_FLAG; мутант `quietMode === true` красен 4 клетками; контроль строгий (`model.js:11`)|
|3 завершение SDK|playHaptic pending до разрешения SDK, 4 метода; семантика отказа задана|отказ закрыт (REJECTS ×4, swallow красен); pending НЕ закрыт: БЛОКИРУЕТ Б2|
|4 realm|множество пройденных имён = выведенному вне realm; ожидания неизменяемы; счёт в каждом режиме; M2/M3 красны или сужено|закрыт: `probe.py:175` сверяет имена/длину/дубли во всех режимах (лишняя клетка → rc 1); ожидания впечатаны литералом до импорта; `const register = test` до ленивого `load()`; oracle-cache и global-test красны; подмена ассертов честно в НЕ ЗАЩИЩАЕТ :98|
|5 песочница ≠ продукт|граф субъекта в раскладке R; ни один подложенный пробой файл (оракул, ТЕСТ) не достижим|оракул закрыт (M6 красен PRODUCT_MODULE_RESOLUTION); ТЕСТ с полной матрицей лежит рядом с субъектом: БЛОКИРУЕТ Б3|
|6 зависимость|package.json == bundledNativeModules, lock удовлетворяет, resolved/integrity, установлена|закрыт: `probe.py:91–111`; ~14.0.0, неустановленный пакет и 0.0.1-not-expo → DEPENDENCY_ABSENT|

## БЛОКИРУЕТ

БЛОКИРУЕТ contracts/151-gespraech-otdacha.md:24 («Ранний `at=0` вместо 500 даёт `null`»), :22 («Для каждой сцены вне точного множества её моментов `patternFor` = `null` и вызовов SDK нет»), :33 («неконформные ключи/время — тишина»), :37 («Ключ/момент вне карты на обеих платформах не испускает эффект»). Класс: ложная достаточность критерия. Домен моментов по-прежнему закрыт перечнем точек; это ПОВТОР класса 1 Crit151. Внутри него — регресс дельты: клетка, проверявшая названное обязательство, удалена.
ОБХОД: мутант `touchdown-at0` (`time === at || at === 0`) даёт `W --model --runtime R` → `CASE 765 GREEN 765 RED 0` rc 0, а `patternFor('GA-T35', 0)` = `{ios: impactOccurred(.medium), android: LONG_PRESS}`. Это отдача удержания на touch-down, ровно то, что запрещает И-3. Круг 1 судил `(GA-T35, 0)` (`5a31eb661:…/otdacha.test.js:60`), а генератор дельты (`probe.py:55–61`) порождает только at±1, at+0.5, середины и края. Момент 0 не попадает в домен ни одной из семи сцен без нулевой записи. Тот же класс: `Math.ceil(at)` и `Math.round(at)` зелёные (765/765, rc 0), а `patternFor('GA-T35', 499.3/499.6)` возвращает LONG_PRESS. Хост, передающий прошедшее время удержания с дробной частью, получает раннюю отдачу. Это тот же сценарий, по которому круг 1 блокировал M1-threshold.
ОБЯЗАТЕЛЬСТВО: И-1 :22, И-3 :24, домен :33, критерий 3 :37.
СОСТОЯНИЕ: продукт с таким `patternFor`. Хост вызывает модуль на touch-down (`at=0`) или с недробным/округляемым моментом ≠ записи.
НАБЛЮДЕНИЕ: сырые строки [touchdown-at0], [ceil], [round] и observe.js выше. У честного контроля на тех же входах `null`.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: для каждой сцены S множество проверяемых не-моментов включает (а) `0`, если 0 ∉ моменты(S); (б) каждый момент оракула других сцен, не входящий в моменты(S); (в) для каждого момента `at−0.5` И `at+0.5`, а также недвоичную дробь по обе стороны (например `at±0.25`). Тогда семьи floor/ceil/round/trunc, «|Δ|<0.5» и «0 → первая запись сцены» красны собственной клеткой на обеих платформах. Привязку стабов к ветвям (ceil, round, at0) делает architect по коду (Н-39). Справедливость: моё закрывающее свойство круга 1 перечисляло «дробный момент» в единственном числе и не называло 0. Это часть спора для арбитра. Но удаление клетки `(GA-T35,0)` при сохранённом обязательстве :24 — дефект дельты, а не свойства.

БЛОКИРУЕТ contracts/151-gespraech-otdacha.md:24 («Промис `playHaptic` остаётся pending, пока промис Expo не разрешится … проверяются все четыре метода SDK») и :95 (ЗАЩИЩАЕТ «раннее завершение … SDK»). Класс: ложная достаточность критерия. Окно наблюдения pending — две микрозадачи; это ПОВТОР класса 3 Crit151.
ОБХОД: мутант `race-timeout-50ms` (каждый вызов SDK обёрнут в `Promise.race([sdk, new Promise(r => setTimeout(r, 50))])`, это обычный «защитный таймаут» нативного вызова) даёт `W --model --runtime R` → `CASE 765 GREEN 765 RED 0` rc 0. `race-20-microticks` (гонка с 20 микрозадачами, без таймера) тоже rc 0. Клетка `SETTLES_AFTER_SDK_*` (`otdacha.test.js:89–103`) проверяет `finished === false` после двух `await Promise.resolve()` и сразу отпускает SDK. Гонка, проигрывающая позже, в это окно не попадает. EMIT-клетки таймер не ловят: `runOnlyPendingTimersAsync()` исполняет его до проверки `getTimerCount()`.
ОБЯЗАТЕЛЬСТВО: И-3 :24, ЗАЩИЩАЕТ :95.
СОСТОЯНИЕ: SDK-промис разрешается дольше гонки (нативный вызов занят), хост ждёт `playHaptic`.
НАБЛЮДЕНИЕ: observe.js — SDK pending 200 мс, `playHaptic` уже разрешён (`finished=true`) у обоих мутантов. У честного контроля `finished=false`.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: для каждого из 4 методов SDK промис `playHaptic` не разрешён, пока SDK-промис удерживается через границы макрозадач и продвижение таймеров. Например, перед проверкой pending: продвинуть фейковые таймеры на величину больше любой разумной гонки (или `runAllTimers`), сбросить `setImmediate`/микрозадачи, затем проверить `finished === false`, отпустить SDK и проверить `finished === true`. Мутанты race-timeout и race-ticks красны своей клеткой. Привязка — architect (Н-39).

БЛОКИРУЕТ contracts/151-gespraech-otdacha.md:20 («Карта — внутри `mobile/src/lib/otdacha/`, без импорта файлов батареи»), :25 (И-4 «Модель батареи не переносится в продукт: в `--repo` … без файлов оракула харнесса на пути импорта»), :33 («оракул харнесса рядом с ним отсутствует»), :96 (ЗАЩИЩАЕТ «импорт продукта проверяется без подложенного оракула харнесса»), :37 (критерий 3 rc 0). Класс: раскладка песочницы ≠ продукт. Проба кладёт полную матрицу ожиданий в каталог субъекта; это ПОВТОР класса 5 Crit151, закрывающее свойство которого прямо называло «оракул, ТЕСТ».
ОБХОД: `probe.py:161–162` пишет `otdacha.test.js` с впечатанной матрицей (`const cases = {...}`: scene, at, iosPattern, androidPattern каждой записи) в `<temp>/src/lib/otdacha/`, рядом с `index.ts`, под фиксированным именем. Модуль `fs-read-probe-test` не несёт карты. Он читает `path.join(__dirname, 'otdacha.test.js')` и строит таблицу из `cases.rows`. `W --repo X` → `CASE 765 GREEN 765 RED 0` rc 0. В продукте этого файла нет, и в RN-рантайме нет `fs` [INFERENCE для Metro; для Node измерено]: `observe_fs.js` → `THROWS ENOENT … mobile/src/lib/otdacha/otdacha.test.js`. Подмены ассертов и результата раннера здесь нет: мутант читает подложенные ожидания. Значит, это вне строки НЕ ЗАЩИЩАЕТ :98.
ОБЯЗАТЕЛЬСТВО: :20, И-4 :25, :33, ЗАЩИЩАЕТ :96, критерий 3 :37.
СОСТОЯНИЕ: имплементер поставляет модуль без собственной карты, который читает файл пробы. `W --repo R` в quality продукта зелёный, приложение падает при первом вызове.
НАБЛЮДЕНИЕ: сырые строки [fs-read-probe-test] и observe_fs.js выше. Честный контроль с картой внутри каталога (`./map.json`) тоже 765/765. Каталог мутанта в X содержит только `index.ts`.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО (выбор автора): либо (а) в `--repo` ни один файл, содержащий ожидания оракула, не лежит в каталоге субъекта или в цепочке его предков под предсказуемым именем, и субъект, читающий файлы, подложенные пробой (тест, матрица, результаты), красен собственной клеткой или стабом; либо (б) честное сужение: строка :96 перестаёт утверждать «без подложенного оракула» (матрица подложена), :33 «оракул харнесса рядом с ним отсутствует» уточняется. Во втором случае в НЕ ЗАЩИЩАЕТ вносится «субъект, читающий файлы песочницы пробы (тест/матрицу/результаты) через fs или иной путь вне графа импорта; ловец — diff-review модуля». Вариант (б) дешевле, и он честен. Полное (а) недостижимо внутри одного процесса: `fs` может сканировать и temp.

## САМООПИСАНИЕ — «число/утверждение в тексте → живое» (полный список)

|место|в тексте|живое|источник замера|совпадает|
|---|---|---|---|---|
|:9, :22|16 сцен GA-T (перечислены 16)|16|оракул: уникальные `GA-T*`|да|
|:9|GA-R2/R3 (включая 393) с повторными записями|GA-R2 2, GA-R2-393 2, GA-R3 5, GA-R3-393 5; всего 30 записей, 20 сцен|оракул|да|
|:24|GA-T35 `at=500`|500|оракул|да|
|:24|«все четыре метода SDK»|4 метода × (SETTLES, REJECTS) = 8 клеток|`probe.case_matrix`|да|
|:22|«at±1, середины, после последнего, дробный момент, обе платформы»|генератор `probe.py:55–61`: ±1, +0.5, середины, first−1, last+1; 100 кандидатов × 2 + 4 неизвестных ключа = 204|независимый пересчёт по JSON|да (полнота — Б1, не самоописание)|
|:36–38|`CASE 765 GREEN 765 RED 0`|765 = 60 PATTERN + 480 EMIT + 204 ABSENT + 12 UNKNOWN_FLAG + 8 SETTLES/REJECTS + 1 PRODUCT_MODULE_RESOLUTION; живой `--model` 765/765/0|прогон + `case_matrix`|да|
|:36, :38|`SVJAZI 18 CASE 765`|18 = 16 ключей `STABS` + model-in-product + fake-dependency; живой вывод 18 строк STAB|прогон + `len(probe.STABS)`|да|
|:35|rc 1 SUBJECT_ABSENT (без R; `--repo R`); rc 2 INFRASTRUCTURE|1 / 1 / 2|прогон|да|
|:36|«порог `time <= at` … → rc 1 с именованной клеткой»|стаб threshold → ABSENT_IOS_GA_T28_1|`--stabs`|да|
|:36|«отсутствующий флаг → rc 1 с именованной клеткой»|rc 1, KRASNO UNKNOWN_FLAG_*_quietMode_{MISSING,NULL}|мутант flag-undefined-passes|да|
|:36|«проглоченный отказ → rc 1 с именованной клеткой»|стаб swallow → REJECTS_AFTER_SDK_IOS_GA_T28_0|`--stabs`|да|
|:36|«несовпавшее множество имён → rc 1 **с именованной клеткой**»|лишняя клетка: rc 1, но имя не выводится. Вывод `CASE_SET_MISMATCH expected 765 actual 766` и итог `CASE 766 GREEN 766 RED 0` (ни одной KRASNO). Недостающая клетка именуется (`failures |= expected − names`)|негатив «лишняя клетка»|**НЕТ**|
|:36|пустая исходная матрица → rc 2|ORACLE_DESIGN_DRIFT rc 2|негатив|да|
|:37|DEPENDENCY_ABSENT rc 1 (отсутствует/несовместима/не установлена)|~14.0.0 → rc 1; не установлен → rc 1; 0.0.1-not-expo → стаб красен|негативы|да|
|:37|SUBJECT_ABSENT rc 1; ORACLE_DESIGN_DRIFT rc 2; модель с `../../../oracle.json` → rc 1 `KRASNO PRODUCT_MODULE_RESOLUTION`|1 / 2 / 1 (строка присутствует)|негативы|да|
|:38|pre_critic / ceilings / precision_gate / check_zones rc 0|0 / 0 / 0 / 0 (проверено по зонам 9743)|прогон|да|
|:38|check_provodka rc 0 при guard и точной оговорке 994|rc 0; без фразы 994 → rc 1 «guard не подключён»|прогон + негативный контроль|да|
|ПРЕДПОСЫЛКИ :80–86|6 setting, 0 secret|`PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=6`, `--freeze` rc 0|прогон|да|
|:81|Expo SDK 57; Python 3.12; `npm ci --no-audit --no-fund`|R: `expo ~57.0.30`, установлен 57.0.30; product quality: `setup-python` '3.12', `npm ci --no-audit --no-fund` (`product-mobile.yml:196`)|R, снимок консультанта (blob d97142d7)|да|
|:25|диапазон `bundledNativeModules.json`|`~57.0.3`|`R/mobile/node_modules/expo/bundledNativeModules.json`|да|
|:47–63|17 ПЕРЕСЕЧЕНИЙ orchestrator по `.github/workflows/mobile.yml`|union замороженных владельцев пути: 107, 108, 111, 116, 117, 118, 123, 135, 138, 141, 143, 147, 148, 149, 991, 995, 999 = 17. У 150 ЗОНА есть, но тега frozen нет. 139 v3 снял байтовый пин (`contracts/139…:44`)|grep ЗОНА-строк + `git tag -l frozen/contracts/*`|да|
|:43–45|ЗОНА implementer, 2 ПЕРЕСЕЧЕНИЯ (145 package.json/lock)|2|текст; frozen 145/4|да|
|:72–74, :90|три обязательных запуска|3 команды|текст тела шага|да|
|:29|шесть имён будущих клеток, не в батарее|6 имён; в каталоге фикстуры 0 вхождений|grep|да|
|:10–11|frozen 145/4, 146/1, 147/1; 148/149 frozen|теги есть|`git tag -l`|да|
|:11|PR #147/#148 экраны, #149/#150 демо|дельта строку не меняла; замер круга 1 действует|`git diff` по строке пуст|не перемерено (не в дельте)|
|probe.py:16|DESIGN_SHA256 02fc041a…|совпадает с designer-copy R|sha256|да|
|адреса `файл:строка` в тексте|нет|0 вхождений|grep|да|

Расхождений — одно: «несовпавшее множество имён → rc 1 с именованной клеткой» для лишнего имени. Код верен по rc, но имя не выводит, а итоговая строка `GREEN 766 RED 0` вводит в заблуждение. Закрытие: печатать `KRASNO <имя>` для `names − expected` и для дублей. Либо текст :36 говорит «rc 1 с `CASE_SET_MISMATCH`».

## Ответы по пунктам задания

- check_provodka rc 0 по 994: зелень не ложная. Механизм общий и уже заморожен в 994/1: закрытый перечень из двух фраз, освобождение per-guard. Его остаточный риск («автор написал точную оговорку о фактически локальном guard») принят в НЕ ЗАЩИЩАЕТ 994 как cognitive-only для reviewer. Значит, 151 новой дыры не открывает и общий механизм не меняет. Для 151 оговорка содержательно верна: батарея требует `node_modules` и designer-copy приватного продукта, harness-CI исполнить её не может. Полярность подтверждена: без фразы rc 1. Текст честно не выдаёт rc 0 за проводку (:38, :84, :90, :100) и требует product SHA, H SHA и run URL в свидетельстве интеграции.
- CI-маршрут. (а) ЗОНА orchestrator `.github/workflows/mobile.yml` и 17 ПЕРЕСЕЧЕНИЙ равны union замороженных владельцев пути, precision-gate rc 0. Корень зоны назван как a3ka/Complior-mob (:65). Устаревшие пути ci.yml/ci-steps.tsv из зоны orchestrator удалены, и это согласовано с :84. (б) НЕ ЗАЩИЩАЕТ :99 честно называет, что harness-CI батарею не гоняет, а дрейф виден только при перепине; :100 честно ограничивает check_provodka. (в) ПРОВОДКА: `- guard=…` плюс ЭНФОРСМЕНТ, первое предложение которого — точная фраза 994; предметный энфорсмент — три запуска в quality. (г) Инвентарь 143 не нарушен: шаги добавляются в существующий `quality` (в снимке есть setup-python 3.12, setup-node и `npm ci` на :196 перед `probe.py --check-frozen`, копирующим workspace), новой job нет, а карта, selector, aggregate и needs названы неизменными (:85).
- Воля владельца. Текст не выдаёт её за решённую. :78 и :86 называют вопросы о флагах и границе done открытыми. :98 — «До слова владельца … считается условным, не утверждённым сокращением». Это условие заморозки, не блок.
- Закрытые классы 2/4/6 — см. таблицу. Мутант `flag-undefined-passes` красен 4 клетками. Лишняя клетка даёт rc 1. Версия ~14.0.0 и неустановленный пакет дают DEPENDENCY_ABSENT.

## СОВЕТ

СОВЕТ contracts/151-gespraech-otdacha.md:98 — мутант `sniff-jest` (`typeof jest !== 'undefined'` → честно, иначе порог) зелёный 765/765. Распознавание тестовой среды не ловится никакой Jest-батареей. Это не «подмена ассертов/результата раннера», поэтому строкой :98 оно не покрыто дословно. Стоит назвать его в НЕ ЗАЩИЩАЕТ («субъект, различающий тестовую среду; ловец — diff-review»).

СОВЕТ contracts/151-gespraech-otdacha.md:23 — `truthy-flags` (`!policy.enabled`) зелёный и при `enabled: 1` вызывает SDK, хотя текст требует «тогда и только тогда, когда `enabled === true`». Хост с настройками 0/1 (SQLite/AsyncStorage) достижим. Либо клетка на не-булев истинный флаг, либо явное «не-булев не-null флаг — неконформный вход без обязательства» в :33.

СОВЕТ contracts/151-gespraech-otdacha.md:33 — `loose-eq` (`time == at`) зелёный: `patternFor('GA-T35','500')` не `null`. В TS-хосте тип недостижим, но :33 обещает тишину на «неконформное время». Достаточно назвать в домене, что `at` — число.

СОВЕТ contracts/151-gespraech-otdacha.md:82–83 — designer-copy продукта пинится `DESIGN_SHA256`, а пауза 147/148/149 ждёт новый пакет D 2.4 с «эталонами движения». После подключения любой продуктовый PR, обновивший `docs/ux/04_Gespraech_D24/motion/haptics.json`, покраснеет в quality (`ORACLE_DESIGN_DRIFT` rc 2) до перепина H. Это верное обнаружение дрейфа, но цену стоит назвать в порядке перепина (:78), чтобы она не стала неожиданностью.

СОВЕТ fixtures/…/probe.py:187–189 — `--repo X --runtime Y` не запрещён. Тогда X судится в среде Y, а `bundledNativeModules` берётся из Y. В CI форма только `--repo`, вреда нет, но комбинацию можно запретить так же, как `--model --repo`.

## ВОПРОС ВЛАДЕЛЬЦУ

Новых нет. Два вопроса круга 1 (толкование «уважения системных настроек» и сужение done до модуля и зависимости) остаются открытыми по форку n-151. Текст контракта держит их условием (:78, :86, :98).

## Что НЕ проверено

- Живой GitHub-run quality продукта и сама продуктовая дельта mobile.yml: её ещё нет, H-пин не опубликован. Порядок шагов сверен по снимку консультанта (`Consult151c/product-mobile.yml`, blob d97142d7), живой main продукта не перечитывался.
- Metro/RN-поведение `require('fs')` в fs-мутанте — [INFERENCE]. Измерен только ENOENT в Node-раскладке продукта.
- PR-номера :11 не перемерялись (строка вне дельты).
- Эмулятор, устройство, нативная сборка, `npx expo install` — запрещены правилом станции или не нужны.
- tsc продукта на будущем `index.ts`.
