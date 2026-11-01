accept
OBJECT=c3fe23d599c771f3d8bca231a16e202a8e5a210c
СУД: repo=dev-harness; предмет=151; фаза=контракт (+красная батарея), scoped по дельте арбитража П1–П6 и зависимому регрессу; роль=critic; вызов=3 (дополнительный, по слову владельца 2026-11-01); модель-план=anthropic/claude-opus-5-5; сессия=Crit151c; модель-факт=anthropic/claude-opus-5-5; SHA=c3fe23d599c771f3d8bca231a16e202a8e5a210c; предыдущий=verdicts/critic/contracts-151-v1-fail.md (FAIL, круг 1), verdicts/critic/contracts-151-v1b-fail.md (FAIL, круг 2), verdicts/arbitration/contracts-151-arbitraz.md (РЕШЕНИЕ, Arb151, anthropic/claude-fable-5-1); исключение=РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/151-*.md — один дополнительный scoped-вызов критика (вызов 3) только по дельте architect по РЕШЕНИЮ арбитража contracts-151-arbitraz.md (П1–П6) и зависимому регрессу; при FAIL — стоп и решение владельца (слово владельца 2026-11-01)

Независимость. Автор OBJECT — architect (Arch151z dca26daa3, Arch151w 740000edd, Arch151v c3fe23d59; `%an = architect`; по отчётам авторов модель-факт openai-codex/gpt-6-sol). Критик — anthropic/claude-opus-5-5, семейства разные. Арбитр Fable из того же семейства Anthropic, что и критик, но это не автор конструкции; так же записано у арбитра. Строку `СУД:` о вызове 3 в HANDOFF.md на main fee477054 я не нашёл (grep `Crit151c`/`предмет=151` пуст). Учёт сверен по заданию и по форку `forks/n-151-vyzov-kritika-3.md`; дописка строки в HANDOFF — дело оркестратора.

Итог. Каждый из П1–П6 выполнен, и его закрывающее свойство закрыто исполнением на OBJECT. Каждый мутант, которого арбитраж назвал внутри домена, красен собственной клеткой. Каждый мутант, которого арбитраж назвал остатком, зелёный и назван в НЕ ЗАЩИЩАЕТ. Свои мутанты внутри трёх доменов (решётка моментов, удержание SDK 1000 мс по методам, предсказуемый путь) я написал сам, 19 форм. Ни одна не прошла зелёной при нарушенном закрывающем свойстве П1–П5. Зависимый регресс не найден. Правка текста c3fe23d59 соответствует слову владельца ~21:00 и не обещает больше. Расхождений САМООПИСАНИЯ в тексте контракта ноль. Блоков нет. Есть одна существенная находка вне П1–П6 (СОВЕТ 1). Её я выношу владельцу на решение, а не прячу.

## Линия и чистота

```
git cat-file -t c3fe23d599c771f3d8bca231a16e202a8e5a210c          → commit
git -C /home/harness/dev-harness rev-parse main wip/151/architect → fee47705495b… / c3fe23d599c7…
git log fee47705495b..HEAD (клон)  → 3084e4303, dca26daa3, 740000edd, c3fe23d59 (все architect)
git diff --stat dca26daa3..740000edd → контракт 22±, otdacha.test.js 40±, probe.py 43±
git diff --stat 740000edd..c3fe23d59 → только contracts/151-gespraech-otdacha.md (6 строк заменены; батарея не менялась)
git diff --check dca26daa3..c3fe23d59 → rc 0
R=/tmp/dev-harness-verify/Impl147e/mob: git status --porcelain | wc -l → 0 (до и после)
bash scripts/check_no_leak.sh --check /home/harness/dev-harness → «основной чекаут чист», rc 0
```
Клон: `/tmp/dev-harness-verify/Crit151c/repo`, checkout OBJECT. GIT_DIR/GIT_WORK_TREE не ставились, push нет, эмуляторы и нативные сборки не запускались. Jest вручную не запускался, только через пробу. Атаки — одноразовые копии в `/tmp/dev-harness-verify/Crit151c/attack/work*`.

## Сырые команды (cwd = клон; W=fixtures/workshop_project/gespraech_otdacha_151/red_gespraech_otdacha_151.sh; R как выше; гейты последовательно)

```
env -u MOB_151_RUNTIME bash $W                 → SUBJECT_ABSENT: mobile/src/lib/otdacha/index.ts            rc=1
bash $W --model --runtime $R                   → CASE 805 GREEN 805 RED 0                                    rc=0  real 0m13.550s
bash $W --repo $R                              → SUBJECT_ABSENT: …/Impl147e/mob/mobile/src/lib/otdacha/index.ts rc=1
bash $W --stabs --runtime $R                   → rc=0  real 4m35.417s
  STAB ios-only KRASEN EMIT_ANDROID_GA_T28_0_E1_V1_Q0      STAB android-only KRASEN EMIT_IOS_GA_T28_0_E1_V1_Q0
  STAB weak-long KRASEN EMIT_IOS_GA_T35_500_E1_V1_Q0        STAB early-long KRASEN ABSENT_IOS_GA_T35_499
  STAB late-r2 KRASEN PATTERN_IOS_GA_R2_4820                STAB ignore-quiet KRASEN EMIT_IOS_GA_T28_0_E1_V1_Q1
  STAB ignore-vibration KRASEN EMIT_IOS_GA_T28_0_E1_V0_Q0   STAB ignore-disabled KRASEN EMIT_IOS_GA_T28_0_E0_V1_Q0
  STAB selection-impact KRASEN EMIT_IOS_GA_T30_0_E1_V1_Q0   STAB deferred-disabled KRASEN EMIT_IOS_GA_T28_0_E0_V1_Q0
  STAB double-delayed KRASEN EMIT_IOS_GA_T28_0_E1_V1_Q0     STAB threshold KRASEN ABSENT_IOS_GA_T28_1
  STAB oracle-cache KRASEN PATTERN_IOS_GA_T28_0             STAB global-test KRASEN PATTERN_IOS_GA_T28_0
  STAB no-await KRASEN SETTLES_AFTER_SDK_IOS_GA_T28_0       STAB swallow KRASEN REJECTS_AFTER_SDK_IOS_GA_T28_0
  STAB ceil KRASEN SWEEP_IOS_GA_R2                          STAB round KRASEN SWEEP_IOS_GA_R2
  STAB touchdown-at0 KRASEN SWEEP_IOS_GA_T35                STAB race-timeout-50ms KRASEN SETTLES_AFTER_SDK_IOS_GA_T28_0
  STAB race-captured-real-timer-50ms KRASEN SETTLES_AFTER_SDK_IOS_GA_T28_0
  STAB fs-read-sibling-test KRASEN PRODUCT_MODULE_RESOLUTION
  STAB model-in-product KRASEN PRODUCT_MODULE_RESOLUTION    STAB fake-dependency KRASEN DEPENDENCY_ABSENT
  SVJAZI 24 CASE 805
bash scripts/pre_critic.sh --repo . contracts/151-gespraech-otdacha.md   → PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=6; «КРИТИК: дверь зелёная» rc=0
bash scripts/check_ceilings.sh                                           → «потолки в порядке» rc=0
bash scripts/check_precision_gate.sh . contracts/151-gespraech-otdacha.md → OK rc=0
bash scripts/check_threat_model.sh . contracts/151-gespraech-otdacha.md   → секция валидна (ЗАЩИЩАЕТ 2, НЕ ЗАЩИЩАЕТ 7) rc=0
bash scripts/check_provodka.sh . contracts/151-gespraech-otdacha.md       → rc=0
bash scripts/check_predposylki.sh . contracts/151-gespraech-otdacha.md --freeze → PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=6 rc=0
bash scripts/check_zones.sh --incr /tmp/dev-harness-verify/Crit151c/zones-cache . → полный прогон (кеша не было): замороженных 147, авторов 5, коммитов в диапазонах 41308, проверено по зонам 9827; rc=0 (6 мин 26 с)
```
Мой первый вызов `check_threat_model.sh contracts/…` с одним аргументом дал rc 1 с ошибкой использования; это мой вызов, а не дефект предмета. С правильной формой `<корень> <контракт>` выше — rc 0.

## П1–П6 → выполнено / закрывающее свойство (мутанты: `attack/mutants.py`, режим `--model --runtime R`, проба автора без изменений; X-продукт: `attack/repo_attacks.py`, конструкция Crit151b/Arb151)

|П|что требует арбитраж|на OBJECT|свойство|
|---|---|---|---|
|П1|`sweeps` на (сцена, платформа): lo=−1, hi=max+1, flo=first−1, fhi=last+1, step=0.25, moments; имя `SWEEP_<PLATFORM>_<SCENE>`; `SWEEP_STEP` — именованная константа|`probe.py:16` `SWEEP_STEP = 0.25`; `:61` `last_oracle_moment`; `:86–93` запись и имя; 40 записей; ABSENT 204 оставлены свидетелями (выбор, разрешённый арбитражем)|закрыто: ceil, round, tol-lt-0.5, tol-le-0.25, quarter-after, play-round, memo-round, cross-scene-any-int → RED 40 (все 40 SWEEP, обе платформы); floor, trunc, tol-le-0.5 → RED 100 (60 ABSENT + 40 SWEEP); threshold-le → RED 232; touchdown-at0 → RED 14 (7 сцен без нулевой записи × 2); cross-scene-GAT → RED 32; between-r3 → RED 2 (SWEEP_*_GA_R3); at-minus-1 → RED 66; at-last-plus-1 → RED 44|
|П2|SWEEP-клетка: фейковые таймеры, reset, обход целой и дробной решётки с пропуском моментов, `patternFor === null` и ноль вызовов SDK на каждой точке, `runOnlyPendingTimersAsync`, `getTimerCount()===0`, `calls()` пуст, первая нарушившая `at` в отказе, явный таймаут|`otdacha.test.js:79–107`, таймаут 60000; `hasCalls()` проверяется после каждого `playHaptic`|закрыто: play-round (только `playHaptic` округляет, `patternFor` честный) → RED 40; memo-round (кэш по `Math.round(at)`) → RED 40; deferred-nonmoment-real-0ms (SDK через захваченный реальный `setTimeout(…,0)` на не-моменте) → RED 98. Диагностика `at` уходит только в failureMessage Jest, проба печатает имя клетки (СОВЕТ 5)|
|П3|SETTLES: реальные таймеры, `setTimeout(holdMs)`, затем `toHaveBeenCalledTimes(1)`, `finished===false`, release, `finished===true`; таймаут `holdMs+5000`; `HOLD_MS=1000` в `probe.py` передаётся матрицей; без фейковых таймеров|`probe.py:17` `HOLD_MS = 1000`; `:114–115` `holdMs`; `otdacha.test.js:121–135` дословно по форме П3; в клетке нет `useFakeTimers`, предыдущие клетки восстанавливают реальные в `finally`|закрыто: race-timeout-50ms, race-timeout-900ms, race-20-microticks, race-500-microticks, race-captured-real-timer-50ms, race-captured-real-timer-990ms, race-setImmediate-captured → RED 4 `SETTLES_AFTER_SDK_*` (все 4 метода); стабы no-await и swallow красны своими клетками. Остаток race-timeout-2000ms → rc 0 (назван :99)|
|П4|тест и results.json в `mkdtemp(prefix, dir=<temp>)`; `--runTestsByPath` на него; `require(<абс. путь target/index>)` через плейсхолдер; в `target` только копия модуля; лишние и дубли → `KRASNO LISHNJAJA_<имя>`|`probe.py:189–196`: `observer-XXXX` под корнем песочницы (не каталог субъекта и не его предок); `__SUBJECT_PLACEHOLDER__` ← `json.dumps(str(target/'index'))`; `:206–207` LISHNJAJA|закрыто: `--repo X`: честный контроль с `./map.json` → rc 0 805/805; fs-read-sibling-test → rc 1 `CASE 805 GREEN 433 RED 372`; model-verbatim-M6 → rc 1 RED 805. `--model`: fs-read-sibling-test → rc 1 RED 805 (ENOENT при импорте). Негатив :36: лишняя клетка → rc 1 `KRASNO LISHNJAJA_UNDECLARED_151C`; дубль → rc 1 `KRASNO LISHNJAJA_PRODUCT_MODULE_RESOLUTION` (`attack/extra_cells.py`). Остаток (скан, argv, realm) зелёный, назван :100|
|П5|6 стабов с дословными мутантами спора, свидетели — по коду (Н-39); SVJAZI по живому прогону|`probe.py:40–54`: ceil, round, touchdown-at0, race-timeout-50ms, race-captured-real-timer-50ms, fs-read-sibling-test; живой `--stabs` → 24 строки KRASEN, `SVJAZI 24 CASE 805`|закрыто. Привязку свидетелей к ветвям судит architect по коду (Н-39); я проверил только, что каждый стаб красен названным свидетелем при полном множестве имён|
|П6|текст И-1 :22, И-3 :24, :20/:33/:96, :36–:38 числа, НЕ ЗАЩИЩАЕТ Б1/Б2/Б3/Metro + sniff-jest, ЗАЩИЩАЕТ :95 с 1000 мс; подключение, зоны, CI, ПРЕДПОСЫЛКИ, ПРОВОДКА без изменений|:22 свойство решётки дословно по смыслу; :24 «Ранний `at=0` вместо 500 даёт `null`» сохранён и имеет клетку `SWEEP_*_GA_T35` (touchdown-at0 красен); :24 HOLD_MS=1000, все четыре метода; :20/:33/:96 «вне каталога субъекта под случайным именем … недостижимы по предсказуемому относительному пути; модельный oracle.json в --repo отсутствует»; фраз «оракул харнесса рядом отсутствует» и «без подложенного оракула» больше нет (grep пуст); :33 «точным числовым scene+at» закрывает loose-eq фразой, как разрешил арбитраж; :36–:38 805/24; :95 «1000 мс реального времени»; :98–:101 добавлены, sniff-jest в :100. Дельта П6 не трогает :40–:77 и :88–:90 (хунки только @@-17, -75, -83, -92)|выполнено|

## Остаток арбитража — зелёный и назван (не блок; прецедент spaseno-konechnost / 153)

```
tol-lt-0.25                     rc=0 CASE 805 GREEN 805 RED 0     (:98)
tol-lt-0.1                      rc=0 CASE 805 GREEN 805 RED 0     (:98)
far-late (at > 30000)           rc=0 CASE 805 GREEN 805 RED 0     (:98)
loose-eq (time == at)           rc=0 CASE 805 GREEN 805 RED 0     (:98, :33)
race-timeout-2000ms             rc=0 CASE 805 GREEN 805 RED 0     (:99)
fs-read-expect-testpath --model rc=0 CASE 805 GREEN 805 RED 0     (:100)
--repo X: fs-read-ancestor-observer (readdir корня песочницы, префикс observer-) rc=0 805/805 — форма «скан ФС» (:100)
--repo X: fs-read-process-argv  rc=0 805/805                      (:100)
--repo X: fs-read-expect-testpath rc=0 805/805                    (:100)
--repo X: module-parent-filename rc=0 805/805; require-main-filename rc=0 805/805 — формы Jest-realm (:100; см. СОВЕТ 3)
```

## Зависимый регресс

- Классы 2/4/6 Crit151b не ослаблены. Политика: ignore-quiet, ignore-vibration, ignore-disabled и deferred-disabled красны, 12 клеток UNKNOWN_FLAG на месте. Realm и множество имён: oracle-cache и global-test красны. Сверка имён строже, чем была: лишнее и дубль теперь именуются. Зависимость: fake-dependency → DEPENDENCY_ABSENT.
- Перенос теста в `observer-*` и абсолютный `require` не сломали ни раскладку `--model`, ни раскладку `--repo`. Честные контроли зелёные в обоих режимах: 805/805.
- CI-маршрут без секрета: `PREDPOSYLKI_OK secrets=0` (pre_critic и `--freeze`). Строки :40–:77 и :88–:90 дельтой не тронуты. 17 ПЕРЕСЕЧЕНИЙ orchestrator совпадают с живым union замороженных владельцев `.github/workflows/mobile.yml` на текущем HEAD (`attack/union_mobile_yml.sh`): `107 108 111 116 117 118 123 135 138 141 143 147 148 149 991 995 999` = 17. precision-gate rc 0.
- check_provodka rc 0 по оговорке 994: :84, :90 и :104 не изменены. Признание Crit151b «не ложный» остаётся в силе.
- Цена прогона выросла: `--model` 1.6 → 13.6 с, `--stabs` 28 с → 4 мин 35 с. Это решение владельца о цене (арбитраж, замер 6), не блок.

## Правка ТЕКСТА c3fe23d59 по слову владельца ~21:00 (форк n-151-tolkovanie…, ответ в 8f02eb11c)

- «Уважение системных настроек» = «ОС гасит сама + явные прикладные флаги политики; неизвестное состояние не разрешение (fail-closed)». Это записано в :23, :86 и :102. Совпадает с ответом владельца.
- Silent switch не обнаруживается: :23 «модуль не обнаруживает silent switch iOS или состояние системной вибрации (Expo SDK 57 не предоставляет JS-геттера)», :102 — в НЕ ЗАЩИЩАЕТ.
- done = модуль + зависимость + карта 16 сцен: :20, :78, :86.
- Подключение — v+1 после снятия паузы: :29 — «к точкам 147/148/149 … после снятия паузы всех трёх». Это консервативнее слова владельца («к точкам 147 … после снятия паузы D 2.4»): пауза 147/148/149 действует по `registry/pauzy.tsv` (строки есть). Шесть имён будущих красных клеток подключения сняты, сказано «в done 151 нет подключения к экранам и красных клеток подключения».
- Лишних обещаний текст не даёт. Grep `уважа|переключател` находит только формулу владельца (:23, :86) и отрицание обнаружения (:102). Нет «уважает переключатель», нет обещания обнаружения.
- Формулировки «до слова владельца … условным» и «вопросы … остаются открытыми» заменены (grep `до слова|остаются открыт|условн` → только «условного пропуска» в :83, CI). Батарея в c3fe23d59 не менялась.

## БЛОКИРУЕТ

Нет. Ни одного нарушения закрывающего свойства П1–П6 на достижимом состоянии в зоне дельты я не нашёл. Арбитражный регресс тоже не найден.

## САМООПИСАНИЕ — «число в тексте → живое число» (полный список)

|место|в тексте|живое|источник|совпадает|
|---|---|---|---|---|
|:36, :37, :38 (×10)|`CASE 805 GREEN 805 RED 0`|805 = 60 PATTERN + 480 EMIT + 204 ABSENT + 40 SWEEP + 12 UNKNOWN_FLAG + 4 SETTLES + 4 REJECTS + 1 PRODUCT_MODULE_RESOLUTION; `--model` 805/805/0; `--repo X` честный 805/805/0|прогон + `attack/counts.py`|да|
|:36|~13 с|13.55 с (мутанты 12–15 с)|`time`|да|
|:36, :38|`SVJAZI 24 CASE 805`|24 = 22 ключа `STABS` + model-in-product + fake-dependency; 24 строки KRASEN|прогон|да|
|:36|~4.5 мин|4 мин 35 с|`time`|да|
|:36|лишние и повторяющиеся имена → `KRASNO LISHNJAJA_<имя>`, rc 1|`KRASNO LISHNJAJA_UNDECLARED_151C` / `KRASNO LISHNJAJA_PRODUCT_MODULE_RESOLUTION`, rc 1|`attack/extra_cells.py`|да|
|:36|порог `time <= at` → rc 1 с клеткой|стаб threshold → ABSENT_IOS_GA_T28_1; мутант threshold-le RED 232|`--stabs`, мутант|да|
|:35|rc 1 SUBJECT_ABSENT без R и при `--repo R`|1 / 1|прогон|да|
|:20, :22, :78, :86, :9|16 основных сцен GA-T (в :9 перечислены 16 имён)|16 уникальных GA-T, 16 записей GA-T|оракул|да|
|:22|решётка: целые от −1 до последнего момента +1, четверти в собственном диапазоне ±1|`lo=-1`, `hi=24211` (последний момент 24210), `flo=min−1`, `fhi=max+1`, `step=0.25`; 40 SWEEP-клеток = 20 сцен × 2 платформы|`probe.py`, counts.py|да|
|— (отчёт Arch151w)|1 278 720 точек SWEEP|1 278 720 точек решётки, включая моменты; на 60 точках-моментах (30 записей × 2) тест сам пропускает, проверяются 1 278 660|counts.py|да как размер решётки; в тексте контракта числа нет|
|:24|GA-T35 `at=500`; `HOLD_MS=1000`; все четыре метода SDK|500; `probe.HOLD_MS=1000`; 4 settlements: impactAsync, selectionAsync, notificationAsync, performAndroidHapticsAsync|оракул, `case_matrix`|да|
|:95, :99|1000 мс|`HOLD_MS = 1000`|`probe.py:17`|да|
|:98|tol-lt-0.25, tol-lt-0.1, far-late (`at > 30000`), loose-eq — зелёные|все четыре rc 0 805/805|мутанты|да|
|:99|race-timeout-2000ms зелёный|rc 0 805/805|мутант|да|
|:100|три формы Б3 зелёные (скан, argv, `expect.getState().testPath`)|ancestor-observer rc 0, argv rc 0, expect rc 0 (`--repo X`); expect rc 0 (`--model`)|repo_attacks / mutants|да|
|:101|ENOENT в Node-раскладке продукта измерен|fs-read-sibling-test `--repo X` rc 1 RED 372, `--model` RED 805|атаки|да|
|:25, :81|диапазон `bundledNativeModules.json`; Expo SDK 57; Python 3.12|`~57.0.3`; expo 57.0.30 (`~57.0.30` в package.json R); `python3 --version` → 3.12.3|R, станция|да|
|:44–:45, :47–:63|2 ПЕРЕСЕЧЕНИЯ implementer, 17 ПЕРЕСЕЧЕНИЙ orchestrator|grep: 2 / 17; union frozen-владельцев mobile.yml = 17 (список выше)|grep + union_mobile_yml.sh|да|
|:42–:46|3 ЗОНА-строки|3|grep|да|
|:72–:74, :78, :83, :90|три обязательных запуска|3 строки `bash "$W"`|текст|да|
|:80–:86|ПРЕДПОСЫЛКИ: 6 setting, 0 secret/variable/environment|`settings=6 secrets=0 variables=0 environments=0`|pre_critic, `--freeze`|да|
|:10–:11|frozen 145/4, 146/1, 147/1; 148/149 frozen|теги `frozen/contracts/145/4`, `146/1`, `147/1`, `148/1`, `149/1`|`git tag -l`|да|
|probe.py:18|DESIGN_SHA256 02fc041a…bbf|sha256 designer-copy R = 02fc041ab9d482a10571a096d0175cc8a6c60205bfc168e06fc1de07515debbf|sha256sum|да|
|адреса `файл:строка` в тексте|нет|0 вхождений|grep|да|
|:11|PR #147/#148 экраны, #149/#150 демо|не перемерено: строка вне дельты, замер круга 1 действует|—|не перемерено|

Расхождений ноль.

## СОВЕТ (вне П1–П6 и зависимого регресса; не блок по слову владельца для этого вызова, но реальное и измерено)

СОВЕТ 1 — ВЛАДЕЛЬЦУ НА ЗАМЕТКУ. contracts/151-gespraech-otdacha.md:24 (И-3 «Промис `playHaptic` остаётся pending, пока промис Expo удерживается … передаёт его отказ хосту без проглатывания») и :95 (ЗАЩИЩАЕТ). Удержание и отказ проверяются ровно в одной точке на метод: iOS impactAsync — только Light (GA-T28), notificationAsync — только Warning (GA-T19), Android — только VIRTUAL_KEY (GA-T28) (`probe.py:106–113`). Ветвь, у которой нет своей клетки SETTLES/REJECTS, нарушает И-3, а батарея зелёная:
```
no-await-medium   (void Haptics.impactAsync(Medium) в ветви medium)            rc=0 CASE 805 GREEN 805 RED 0
swallow-medium    (try { await impactAsync(Medium) } catch {} в ветви medium)   rc=0 CASE 805 GREEN 805 RED 0
race-only-android-confirm (гонка 50 мс только для performAndroidHapticsAsync('confirm')) rc=0 CASE 805 GREEN 805 RED 0
```
Достижимое состояние: продукт с отдельной ветвью на каждый паттерн, как в `model.js`. Тогда iOS GA-T29/T34/T35 (удержание GA-T35 — центральная сцена) отпускает хост до конца SDK или глотает отказ. Почему это не блок здесь. Ось «паттерн внутри метода» не была предметом кругов 1–2 и арбитража. П3 арбитража сам задал домен как «все четыре метода», по одной точке на метод, и architect выполнил его дословно. Класс существует с 3084e4303 и дельтой не внесён и не ослаблен. Слово владельца для этого вызова: «новое вне П1–П6 и вне зависимого регресса — СОВЕТ». Закрывающее свойство, если владелец сочтёт нужным: SETTLES и REJECTS на каждый различный вызов SDK оракула. Это iOS light, medium, selection, warning, success, error и Android шесть типов — 12 + 12 клеток вместо 4 + 4, цена около +8 с на прогон (HOLD_MS). Мутанты выше обязаны стать красными. Дешёвый ловец до этого — ревьюер реализации: в модуле должна быть одна точка `await` вызова SDK без ветвей на паттерн.

СОВЕТ 2. contracts/151-gespraech-otdacha.md:95 («тишину на каждой точке решётки И-1 у … `playHaptic`»). Вызов SDK на не-моменте, отложенный захваченным реальным таймером дальше конца прогона, не наблюдается. `deferred-nonmoment-real-30s` (`realSetTimeout(() => selectionAsync(), 30000)` на дробных не-моментах) → rc 0 805/805, прогон 39 с: Jest дождался таймеров и вышел с 0. Короткая отсрочка ловится: 0 мс → RED 98. Это тот же класс, что остаток Б2 («позже окна наблюдения»): конечный прогон его не закроет. Предлагаю назвать форму в НЕ ЗАЩИЩАЕТ рядом с Б2 («отложенный реальным таймером вызов SDK позже конца прогона; ловец — diff-review: таймеры в модуле недопустимы»). Признак у ревьюера — удлинение прогона.

СОВЕТ 3. contracts/151-gespraech-otdacha.md:100. Jest-realm назван одним примером `expect.getState().testPath`. Ещё две формы зелёные в `--repo X`: `module.parent.filename` (jest-runtime 29.7.0 определяет геттер `parent`, `build/index.js:1384`) и `require.main.filename`. Они того же класса (cognitive-only, правило 8). Стоит дописать их в перечень ловца diff-review: в модуле отдачи недопустимы `module.parent` и `require.main`.

СОВЕТ 4. `probe.py:189`. Каталог наблюдателя имеет фиксированный префикс `observer-` и лежит прямо в корне песочницы, то есть в `../../..` от субъекта. Один `readdirSync` находит его (fs-read-ancestor-observer зелёный). Арбитраж относит это к остатку «скан ФС», текст :100 его называет. Вынос в отдельный `mkdtemp()` вне корня песочницы (sibling root) убрал бы и эту короткую форму. Цена ≈0, по усмотрению автора.

СОВЕТ 5. `otdacha.test.js:91,93` и `probe.py:263–264`. Первую нарушившую `at` клетка SWEEP бросает в failureMessage Jest, а проба печатает только `KRASNO <имя>` и удаляет results.json вместе с temp. Для отказа SDK, пришедшего асинхронно (после `await`), точка не диагностируется вообще: срабатывает итоговый `calls()`. Форма совпадает с вариантом арбитра, свойство «с диагностикой точки» выполнено на уровне Jest. Печать первой строки failureMessage для SWEEP_* ускорила бы разбор.

СОВЕТ 6 (процесс). На main fee477054 в HANDOFF.md нет строки `СУД:` для вызова 3 (Crit151c). Оркестратору — дописать с `сессия=Crit151c; модель-факт=anthropic/claude-opus-5-5`.

Прежние советы Crit151b (`truthy-flags`, `--repo X --runtime Y`, перепин DESIGN_SHA256) остаются советами, этим вызовом не перемерялись.

## Что НЕ проверено

- Живой GitHub-run quality продукта и продуктовый diff mobile.yml: их ещё нет. Цена `--stabs` на раннере GitHub (у меня 4 мин 35 с локально) не измерена.
- Metro/RN-поведение `require('fs')`, `module.parent` и `require.main` — [INFERENCE]. Измерена только Node-раскладка.
- Рекурсивный скан ФС арбитра (`fs-read-scan-sandbox-root`) я не повторял, вместо него измерил более короткую форму readdir.
- tsc продукта на будущем `index.ts`; эмулятор, устройство, нативная сборка — запрещены правилом станции.
- PR-номера :11 (вне дельты).
- Привязка стабов к ветвям по коду — зона architect (Н-39). Я проверил только красноту названным свидетелем.

Скрипты атак: `/tmp/dev-harness-verify/Crit151c/attack/{mutants.py,repo_attacks.py,extra_cells.py,counts.py,union_mobile_yml.sh}`; одноразовые копии — `attack/work*`. В репо автора правок нет.
