РЕШЕНИЕ
OBJECT=087e4ee00a705c9b6727a784613229d88444f650
СУД: repo=dev-harness; предмет=117 (v4); фаза=контракт; роль=arbiter; вызов=арбитраж контракта v4; модель-план=anthropic/claude-fable (роль arbiter, config/agent_models.json:73 «arbiter — Fable; не модель автора»); сессия=Arbiter117; модель-факт=anthropic/claude-fable-5-1; SHA=087e4ee00a705c9b6727a784613229d88444f650; предыдущий=verdicts/critic/contracts-117-v4-krug1.md (FAIL 1/2), verdicts/critic/contracts-117-v4-krug2.md (FAIL 2/2); исключение=нет

Арбитраж по маршруту §Быстрый-процесс (`roles/critic.md` §Остановка; слово владельца
2026-10-25 по 117). Автор конструкции — Architect117v4a–f (GLM) — сторона; критик —
Critic117g/h (gpt-6-sol). Семейного совпадения арбитра ни с одной стороной нет.
Вердикт написан в рабочем каталоге арбитра и НЕ закоммичен — по заданию
(push/commit запрещены); коммит под `user.name=arbiter` делает оркестратор.

## Предмет спора

Критик 2/2 (единственный новый блокер): клетка `MAESTRO_HOLD_COLD_START` и зависимый
`REPLAY_SPLASH_WHILE_OVERLAY` краснят допустимую цепочку с добавочным НЕ запускающим шагом до
`stopApp`: `launchApp{clearState} → extendedWaitUntil(visible splash-overlay) → stopApp →
openLink(литерал) → extendedWaitUntil(visible splash-overlay) → takeScreenshot`. Причина —
`_maestro_hold_cold_start_verdict` берёт ПЕРВОЕ ожидание visible по всему YAML, а не ожидание
ПОСЛЕ hold-`openLink`.

Вопрос арбитру: это нарушение названного обязательства на достижимом состоянии (контракт
запрещает больше, чем объявляет) или принятая граница (эталонная цепочка зафиксирована,
добавочные шаги до `stopApp` контракт разрешать не обязан)?

## Первоисточники и замеры

Прочитано: контракт `contracts/117-cmp-mob-vkhod-splash.md` @OBJECT (инварианты 10–12
:622–697, описание клетки :892–907, §Приёмочный критерий :1279–1343, КЛАСС РИСКА :87,
§НЕ ЗАЩИЩАЕТ v4 :1612–1641), эталон `fixtures/workshop_project/vkhod_117/model/vkhod-117-splash-vhod.yaml`,
`vkhod_static_probe.py` (`_cold_start_state` :1422–1455, `_maestro_hold_cold_start_verdict`
:1458–1498, `porjadok_cells` :1500–1556, стабы Maestro :2405–2470, `replay_117_cells` :1710,
взвод окна :1805), оба вердикта критика v4 в main (00eeb4cd3), `roles/critic.md`
§Быстрый-процесс, `roles/arbiter.md`.

Клон предмета: `git clone /tmp/dev-harness-verify/Architect117v4/repo …/Arbiter117/repo`;
`git cat-file -t 087e4ee00a705c9b6727a784613229d88444f650` → `commit`; `git checkout -q` →
HEAD = OBJECT, родитель `039db92b4` (origin/main). Продукт: клон Complior-mob @
`c617f6fb236d11574df75fb09ae41870bf8c29d6` в `…/Arbiter117/mob`, `mobile/node_modules` —
симлинк на `/tmp/dev-harness-verify/consultant-expo/mobile/node_modules` (тот же, что у критика
через C124clean). Среда всех прогонов: `env -i PATH=/home/harness/.local/bin:/usr/bin:/bin
TMPDIR=/tmp/dev-harness-verify/Arbiter117`; раннеры/`gh run` не запускались.

### Замер 1 — база: проба OBJECT на эталоне

```text
$ python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --model --repo …/Arbiter117/mob
… static 64/64
rc=0
```

### Замер 2 — атака критика и обе честные цепочки на пробе OBJECT

Одноразовый скрипт `…/Arbiter117/arb_attack.py` (не входит в предмет): устанавливает байты
модели с мутацией сценария через `probe_lib.installed(model_bytes(...))` в `mob` и гонит
`vkhod_static_probe.py --repo mob`; печатаются только RED/итог/rc дочерней пробы; после
каждого прогона `git -C mob status --porcelain --untracked-files=no` пуст.

```text
# honest                                  (эталон дословно)
static 64/64
rc=0
# wait-visible-before-stop                (атака критика 2/2 дословно)
RED MAESTRO_HOLD_COLD_START: сценарий не запускает холодный старт каналом (Г′) по СОСТОЯНИЮ команд — ожидание visible splash-overlay не после openLink (openLink#3, ожидание#1)
RED REPLAY_SPLASH_WHILE_OVERLAY: hold 1200 исходы ['CLASS_B', 'SPLASH']  (канал (Г): True холодный старт: False )
rc=1
# shot-before-stop                        (контроль критика: takeScreenshot до stopApp)
static 64/64
rc=0
# wait-notvisible-before-stop             (мой: extendedWaitUntil notVisible до stopApp)
static 64/64
rc=0
# assert-before-stop                      (мой: assertVisible splash-overlay до stopApp)
static 64/64
rc=0
# relaunch-before-link                    (обход 1 круга 1)
RED MAESTRO_HOLD_COLD_START: … openLink#3: непосредственно перед ссылкой приложение ЗАПУЩЕНО …
RED REPLAY_SPLASH_WHILE_OVERLAY: hold 1200 исходы ['CLASS_B', 'SPLASH']  (канал (Г): True холодный старт: False )
rc=1
# stop-before-launch                      (обход 2 круга 1)
RED MAESTRO_HOLD_COLD_START: … openLink#2: непосредственно перед ссылкой приложение ЗАПУЩЕНО …
RED REPLAY_SPLASH_WHILE_OVERLAY: hold 1200 исходы ['CLASS_B', 'SPLASH']  (канал (Г): True холодный старт: False )
rc=1
# wait-only-before-link                   (мой: ожидание visible ТОЛЬКО до ссылки, после — нет)
RED MAESTRO_SPLASH_FRAME_WAIT: шаг перед vkhod-117-splash — не extendedWaitUntil visible splash-overlay
RED MAESTRO_HOLD_COLD_START: … ожидание visible splash-overlay не после openLink (openLink#3, ожидание#2)
RED REPLAY_SPLASH_WHILE_OVERLAY: hold 1200 исходы ['UNBOUND'] …
rc=1
```

Факт критика воспроизведён дословно. Дополнительный факт, которого нет ни у одной стороны:
граница пробы НЕ равна «добавочные шаги до `stopApp` не допускаются» — снимок, ожидание
`notVisible` и `assertVisible` до `stopApp` зелены, красно ТОЛЬКО ожидание `visible` того же
id. Это артефакт поиска первого совпадения, а не правило, которое можно записать в контракт.

### Замер 3 — цена пути (А): одна строка в одноразовой копии дерева

`cp -a repo repo_fix`; в копии (не в предмете) единственная правка —
`_maestro_hold_cold_start_verdict`, выбор ожидания ПОСЛЕ hold-`openLink`:

```diff
@@ -1468,7 +1468,7 @@ def _maestro_hold_cold_start_verdict(steps, mq, src):
     i_wait = next((i for i, st in enumerate(steps)
-                   if isinstance(st, dict)
+                   if i > i_open and isinstance(st, dict)
                    and isinstance(st.get('extendedWaitUntil'), dict)
```

(sha256 пробы OBJECT `0fdfa867…`, копии `edb13d62…`.) Те же входы на `repo_fix`
(последовательно, дерево `mob` между прогонами чистое):

```text
# honest                      static 64/64  rc=0
# wait-visible-before-stop    static 64/64  rc=0     ← атака критика зелена
# shot-before-stop            static 64/64  rc=0
# wait-notvisible-before-stop static 64/64  rc=0
# relaunch-before-link        RED MAESTRO_HOLD_COLD_START (… openLink#3: … ЗАПУЩЕНО …) + RED REPLAY_SPLASH_WHILE_OVERLAY  rc=1
# stop-before-launch          RED MAESTRO_HOLD_COLD_START (… openLink#2: … ЗАПУЩЕНО …) + RED REPLAY_SPLASH_WHILE_OVERLAY  rc=1
# wait-only-before-link       RED MAESTRO_SPLASH_FRAME_WAIT + RED MAESTRO_HOLD_COLD_START (… ожидание#-1) + RED REPLAY_SPLASH_WHILE_OVERLAY  rc=1
```

Замечание о чистоте замера: первый прогон обходов на `repo_fix` перекрылся на ~13 с с
ошибочно запущенной параллельно матрицей на том же `mob` и дал `relaunch-before-link`
зелёным; матрица убита (rc 143), `mob` восстановлен `git checkout -- . && git clean -fdq -e
mobile/node_modules`, три обхода прогнаны заново последовательно — результат выше. Грязный
прогон в решении не используется.

Логика правки монотонна по построению: для любого YAML, чьё первое ожидание `visible` стоит
после ссылки (эталон и все стабы матрицы — у них одно такое ожидание), выбранный индекс
не меняется; меняется вердикт только там, где ожидание `visible` есть ДО ссылки — прежде
такие входы были красны всегда, теперь судятся объявленным предикатом по суффиксу от
ссылки. Обе проверки состояния (`running`, `cleared_stop`) от `i_wait` не зависят — оба
обхода круга 1 остаются красны (замер выше). Статическая матрица на `repo_fix` — раздел
«Матрица» в конце.

## Решение по спорным пунктам

### 1. Нарушение или граница — ПРАВ КРИТИК

Это нарушение названного обязательства на достижимом состоянии, не принятая граница.

- Обязательство названо самим контрактом, не критиком: инвариант 10 (:622–654) определяет
  холодный старт как СОСТОЯНИЕ команд и перечисляет ровно три условия (приложение остановлено
  перед ссылкой; `stopApp` после `launchApp{clearState}`; без запуска между ними); описание
  клетки (:898–899) добавляет «ожидание visible splash-overlay — ПОСЛЕ openLink, между ними
  нет launchApp». Цепочка критика удовлетворяет всем четырём условиям — такое ожидание после
  ссылки в ней есть (#4). Проба реализует иной предикат («первое ожидание в файле стоит после
  ссылки»), чем текст контракта. Расхождение текста клетки и её кода — дефект, а не граница.
- Состояние достижимо и инженерно безвредно: ожидание `visible` после `launchApp{clearState}`
  — живой шаг v3-сценария (`live/vkhod-117-splash-vhod.prod-ba5ebbc9.yaml`, 25 прогонов),
  на прод-таймере 1200 оно либо проходит, либо краснит флоу таймаутом — ложной зелени кадра
  оно дать не может; снимок по-прежнему привязан к ожиданию после ссылки
  (`MAESTRO_SPLASH_FRAME_WAIT` не тронут).
- Путь (Б) неисполним честно: записать в §НЕ ЗАЩИЩАЕТ «добавочные шаги до stopApp проба не
  допускает» нельзя — это ложь по замеру 2 (снимок/notVisible/assertVisible до `stopApp`
  зелены). Пришлось бы объявлять границу «ожидание visible splash-overlay до ссылки
  запрещено» — правило без инженерного содержания, с вводящей в заблуждение диагностикой
  («ожидание#1 не после openLink#3» при наличии ожидания #4). Семейство `MAESTRO_HOLD_PORJADOK_*`
  существует именно для того, чтобы судить саму проверку порядка (:1500–1510, «правило 8:
  честная цепочка обязана быть зелёной»); оставлять в ней известную ложную красноту — против
  её собственного назначения.
- Автору в зачёт: семантика состояния (`_cold_start_state`) верна, оба обхода круга 1
  закрыты, дефект локален (один выбор индекса), контракт по тексту уже верен. Довод
  «эталонная цепочка зафиксирована» верен как описание модели, но контракт нигде не объявляет
  эталон единственно допустимым YAML — он объявляет инвариант по состоянию, и проба обязана
  ему соответствовать.

### 2. Путь — (А), минимальная правка, без правки продукта

Обязательно к исполнению автором (Architect117v4):

1. `vkhod_static_probe.py`, `_maestro_hold_cold_start_verdict`: ожидание `visible
   overlay_id` выбирается среди шагов ПОСЛЕ hold-`openLink` (первое после ссылки — замерено
   выше; «последнее» тоже допустимо, выбор за автором по коду). Проверка «нет launchApp
   между ссылкой и ожиданием» сохраняется.
2. Семейство `MAESTRO_HOLD_PORJADOK_*` расширяется клеткой-вставкой с добавочным не
   запускающим шагом ДО `stopApp` и ожиданием `True` — цепочка критика дословно
   (`[launch_clear, wait, stop, open_lit, wait, shot]`); вторая клетка со снимком до
   `stopApp` — на усмотрение автора. Стаб не нужен (Н-39): это не дефект субъекта, а
   честный вход для проверки самой проверки; новых стабов решение не требует.
3. Текст контракта — только литералы счёта, поскольку v4 не заморожен и правится в том же
   коммите: `×9` → фактическое число (:900, :961, :1321, :1550, :1632), `64/64` → новое
   число (:1280, :1304) и перечень имён семьи (:901–905). Инвариант 10 и описание клетки
   по существу не меняются — они уже верны. Строка `РАЗРЕШИЛ-ВЛАДЕЛЕЦ` в теле коммита
   сохраняется дословно.
4. Продуктовые патчи `produktnye-izmenenija3/0001–0002`, модель `model/*`, свидетели
   `live/*`, пины `source.json` — НЕ трогаются; живая проба (Г′) run 40511584004 остаётся
   валидной (байты продукта не меняются), нового живого прогона эта правка не требует.
5. Доказательства в коммите: `--model` rc0 с новым числом (×3), `--matrix` rc0 без
   MUTANT_GREEN/NAMED_MISS/UNEXPECTED_RED, прямая проба трёх входов — цепочка критика
   зелена, оба обхода круга 1 красны.

Цена (А): одна строка пробы + одна порождаемая клетка + 7–8 литералов счёта в контракте;
поведенческая семья, продукт и живые свидетели не затрагиваются. Цена (Б): ложная строка
границы либо правило без содержания, плюс сохранение ошибочной диагностики в инструменте,
который переживёт этот предмет. Отвергнута.

### Сколько кругов и кто проверяет правку — граница нормы

По `roles/critic.md` §Остановка (и `roles/arbiter.md` «исчерпание бюджета суда»): решение
арбитра не даёт accept и не является третьим вызовом; для freeze нужна подпись критика, а
дополнительный вызов — ТОЛЬКО явное решение владельца. Инженерно достаточен ОДИН scoped
повтор критика (не полный проход): предмет повтора — закрытие класса (цепочка критика
зелена; оба обхода и `wait-only-before-link` красны), новая клетка семьи, литералы счёта,
матрица. Полный новый поиск по норме не требуется: новой семантики и нового риска правка не
вносит (предикат по суффиксу от ссылки — тот же инвариант). Ревьюер контракта не заменяет
подпись критика; подмена недопустима по норме — говорю прямо.

К ВЛАДЕЛЬЦУ (только бюджет, не инженерия): разрешить один дополнительный scoped-вызов критика
по предмету 117 v4 для подписи после правки (А). Без этого решения предмет остаётся
незамороженным; инженерного вопроса для владельца нет.

### 3. Конечная граница для следующих судей (на этой фазе больше не поднимается блокером)

- Семантика холодного старта как СОСТОЯНИЯ команд (`_cold_start_state`: launchApp/runFlow/
  openLink запускают, stopApp останавливает; fail-closed до первой команды) — решена; оба
  обхода круга 1 и перестановки/вставки/удаления семьи — закрыты и измерены.
- Выбор ожидания ПОСЛЕ hold-`openLink` — решён этим арбитражем; после правки (А) любые
  добавочные НЕ запускающие шаги до `stopApp` или между ссылкой и ожиданием (снимок,
  assert, notVisible, visible) — не блокер; запускающий шаг (launchApp/runFlow/иной openLink)
  между `stopApp` и ссылкой или между ссылкой и ожиданием — красен и остаётся красным.
- Jest не судит порядок Maestro-команд — объявленная граница §НЕ ЗАЩИЩАЕТ (:1628–1635), не
  блокер. `removed-clear-timeout` — закрыт поведенческим стабом (:1636–1641), не блокер.
  Литерал удержания в прод-бандле — объявлен (:1618–1627), ловец ревьюер, не блокер.
- Порог 0.6 и кадр Splash — воля владельца 2026-10-27, не предмет суда.
- Механизм (Г′) и продуктовые патчи — доказаны живой пробой run 40511584004; правка (А)
  их не меняет; новый живой прогон до freeze не требуется.
- Без решения владельца о scoped-вызове никакой судья не выдаёт accept по этому OBJECT'у
  или его правке — норма, не инженерия.

Порядок после подписи критика: freeze 117/4 → implementer (ровно два файла продукта:
`mobile/src/bootstrap/pilot-app.tsx` + `mobile/.maestro/vkhod-117-splash-vhod.yaml`, патчи
0001–0002 к c617f6fb; `.github/workflows/mobile.yml` не меняется — приёмка `git diff
--exit-code` :1324–1327) → адверсарий НЕ нужен (`КЛАСС РИСКА: обычный` :87, UI-тайминг
e2e-снимка; §Реализация: у обычных предметов adversary не вызывается) → ревьюер один полный
вызов (mobile → vision по кадрам; `СВЕРКА-СТАНДАРТОВ`) и не более одного scoped-повтора.

## Остаток (наблюдения вне спора, не решения)

- Контракт (:1322, :1634) называет живым свидетелем честной цепочки `commands.json` 117
  пробы (Г′) run 40511584004, но в `live/` и `source.json replay_117.live.svideteli`
  припинены только артефакты проб (В) и (Г); `commands-proba-117-dark.json` — цепочка (В)
  (launchApp → wait → shot, `timings_ms.proba_117_dark`). Ссылка верна как указание на CI-
  артефакт (критик круга 1 сверял оригинал), но пина нет. Не блокер и не предмет этого
  арбитража; автор может припинить в той же правке или оставить как есть.
- Независимость арбитража: контекст свежий, стороны не консультировались; счёт по сторонам
  в этом арбитраже — вопрос 1 критику целиком, вопрос 2 — путь критика (А) с ценой,
  уточнённой замером (граница пробы шире, чем описали обе стороны).

## Матрица

Статическая матрица на `repo_fix` (одна, последовательно, без параллельных записей в `mob`):

```text
$ cd …/Arbiter117/repo_fix && python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --matrix --repo …/Arbiter117/mob
… (51 строка `mutant <имя> red= [...]`, в т.ч.:)
mutant maestro-splash-no-wait red= ['MAESTRO_HOLD_COLD_START', 'MAESTRO_SPLASH_FRAME_WAIT', 'REPLAY_SPLASH_WHILE_OVERLAY']
mutant maestro-splash-wait-commented red= ['MAESTRO_HOLD_COLD_START', 'MAESTRO_SPLASH_FRAME_WAIT', 'REPLAY_SPLASH_WHILE_OVERLAY']
mutant maestro-first-run-as-splash red= ['MAESTRO_HOLD_COLD_START', 'MAESTRO_SPLASH_FRAME_WAIT', 'REPLAY_SPLASH_WHILE_OVERLAY']
mutant splash-hold-start-launchapp red= ['MAESTRO_HOLD_ALONE', 'MAESTRO_HOLD_COLD_START', 'REPLAY_SPLASH_WHILE_OVERLAY', 'SPLASH_HOLD_LINK_ROUTE_MOUNT']
mutant splash-hold-start-ne-holodnyj red= ['MAESTRO_HOLD_COLD_START', 'REPLAY_SPLASH_WHILE_OVERLAY']
mutant splash-hold-relaunch-pered-link red= ['MAESTRO_HOLD_COLD_START', 'REPLAY_SPLASH_WHILE_OVERLAY']
mutant splash-hold-porjadok-stop-launch red= ['MAESTRO_HOLD_COLD_START', 'REPLAY_SPLASH_WHILE_OVERLAY']
mutant splash-hold-link-na-marshrut red= ['MAESTRO_HOLD_ALONE', 'MAESTRO_HOLD_COLD_START', 'REPLAY_SPLASH_WHILE_OVERLAY', 'SPLASH_HOLD_LINK_CHANNEL', 'SPLASH_HOLD_LINK_ROUTE_MOUNT']
rc=0
```

Счёт по полному выводу (artifact://4009, 896 с): строк `mutant … red=` — 51 (= 38 v3 + 13 v4,
перечень контракта :1329–1330), строк `MUTANT_GREEN/MUTANT_NAMED_MISS/MUTANT_UNEXPECTED_RED/
MUTANT_INFRASTRUCTURE` — 0, rc 0; `git -C mob status --porcelain --untracked-files=no`
после матрицы пуст. Красные ветви каждого стаба совпадают с перечнем критика 2/2
(`artifact://3753` у критика) и §Стабы v4 контракта — правка (А) матрицу не меняет, как и
следовало из монотонности (ни у одного стаба нет ожидания `visible` ДО ссылки).

Одноразовые артефакты арбитража (не входят в предмет, удаление — оркестратор по завершении):
`…/Arbiter117/arb_attack.py`, `…/Arbiter117/patch_fix.py`, `…/Arbiter117/repo_fix/`,
`…/Arbiter117/mob/`.
