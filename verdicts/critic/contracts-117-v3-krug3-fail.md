FAIL
OBJECT=6b6e55c1cabaa7f28b5d89903fa8652ae8d65b34

# Критик 117 v3 — круг 3, последний

Блокеров: **3** (допуск из другого состояния/источника, Г0 после смены темы, порядок Start после смены темы). Три причины — не восемь зелёных файлов: семь новых мутаций нарушают предмет, восьмая меняет исключённую поверхность Erstinformation и НЕ блокирует.

Судится закоммиченная дельта `ba3c5fb3~1..6b6e55c1`, база — frozen/contracts/117/2. Собственная копия H: `/tmp/dev-harness-verify/Critic117v3c/repo`. HEAD совпал с OBJECT, рабочей дельты предмета не было. Предмет, команды критерия, именованные исполнители и ЗОНА-строки есть; неполного набора нет. Оба прежних вердикта прочитаны. Старые закрытые споры не пересуждаются.

**Таблица действительно полна по объявленным нормализованным неизменным входам: 26 строк × 2 темы = 52. Все 10 прежних мутантов критика и все стабы автора красны. Однако полнота таблицы снимков не закрывает допуск через соседние поля/сохранённое состояние и переходы во время жизни приложения.** Новые обходы ниже предъявлены настоящим Jest/RNTL, а не одним чтением. Штатные пробы на каждом из семи блокирующих мутантов дают **96/96 и 43/43, rc 0**; 995/111 также зелёные. Честные контроли на тех же входах нарушение не воспроизводят.

## Блокирующие находки

БЛОКИРУЕТ contracts/117-cmp-mob-vkhod-splash.md:147–175,593–599 — критерий допуска наблюдает только неизменный onboarding при одном неизменном entry. Он пропускает подмену admission/gate соседним источником, альтернативным флагом и старым admission из кэша. Это тот же обещанный допуск «ТОЛЬКО W1A из сессии ∧ current», не требование второго gate.

ОБХОД: `r3-extra-authenticated` расширяет условие demo на `|| onboarding.authenticated === true`. Сессия `{admission:'W0',gate:'stale',authenticated:true}` проходит First-Run → email → demo → Erstinformation → continue → Start. Текущая батарея принимает **behavioral 96/96, static 43/43**, обе rc0. Дополнительное поле не даёт права заменить обязательную пару admission/gate.

ОБХОД: `r3-gate-from-entry` берёт gate из `entry.gate` раньше сессии. При сессии `{admission:'W1A',gate:'stale'}` и `entry.gate='current'` Start достигается; обе пробы 96/96 + 43/43, rc0. `r3-admission-literal-completed` ставит литерал `'W1A'` при `entry.onboarding==='complete'`: фактические `{admission:'W0',gate:'current'}` также допускаются, обе пробы rc0.

ОБХОД: `r3-cached-admission` заменяет чтение admission на `useMemo(() => onboarding?.admission ?? 'W0', [])`. В одном живом экземпляре после First-Run admission сессии меняется W1A → W0 до нажатия demo, gate остаётся current; старый W1A в кэше открывает Erstinformation/Start. 96/96 + 43/43, rc0. Честная модель на том же rerender ведёт к auth-code, Start отсутствует.

ОБХОД: `r3-restart-completed-start` выбирает начальный frame='start' при сохранённом `entry.onboarding==='complete'`. Свидетель размонтирует и заново монтирует приложение с сохранённым `{admission:'W0',gate:'stale'}` и completed-entry: Start виден сразу, First-Run/допуск/continue обойдены. 96/96 + 43/43, rc0. Нарушено также явно сохранённое начальное frame='first-run' (:165–166); честный контроль начинает с First-Run. Это remount/restart React-приложения с повторно поданным сохранённым состоянием, не заявленный тест перезапуска процесса Android.

БЛОКИРУЕТ contracts/117-cmp-mob-vkhod-splash.md:155–160,194–205,593–599 — Г0 «при ЛЮБОМ недопуске, обе темы» проверяется только при начальном выборе темы, но не после её смены на подключённом onboarding.

ОБХОД: `r3-g0-theme-change` запоминает начальную схему в useRef и при `onboarding && initialScheme.current !== scheme` добавляет корню `{backgroundColor:'#000000',paddingTop:0,paddingHorizontal:0,paddingBottom:0}`. На W1A×stale после First-Run достигается email, затем тема переключается dark → light; корень email и последующего code чёрный/нулевой, Start по-прежнему закрыт. Штатные пробы **96/96 + 43/43, rc0**, 995/111 зелёные; живой свидетель наблюдает #000000/0 на обоих кадрах, честный контроль — #FFFFFF/48. Это рестайл bootstrap-корня, не разрешённый тёмный auth-слой 135.

БЛОКИРУЕТ contracts/117-cmp-mob-vkhod-splash.md:162–166,593–599 — критерий порядка видит отсутствие Start сразу после demo, но не удерживает требование «ТОЛЬКО continue» при изменении темы на Erstinformation.

ОБХОД: `r3-order-theme-autostart` добавляет effect: если frame='erstinformation' и схема отличается от начальной, `setFrame('start')`. На честном W1A×current свидетель доходит до Erstinformation и меняет тему dark → light **без нажатия continue**; появляется Start. Обе неизменённые пробы **96/96 + 43/43, rc0**; старые 995/111 зелёные. Честная модель остаётся на Erstinformation. Этот обход касается порядка перехода, не состава/пикселей экрана 118.

Закрытие инженерной причины — красные наблюдения этих классов на шве до заморозки, а не добавление ещё одной фразы о полной таблице. Но этот круг последний: **freeze 117/3 не разрешён, четвёртого круга нет; СТОП и пересмотр нарезки по слову владельца 15:25 UTC.**

АРБИТР: arbiter — повтор общей причины FAIL (полнота критерия допуска/Г0 против зелёных контрпримеров). Предмет: статическая полнота 26-строчной таблицы не равна инвариантности допуска/Г0 по соседним источникам и переходам состояния. Арбитр назван; спавн не выполнен — инструмента спавна в роли нет. Автор — сторона, не судья. Это не разрешение четвёртого круга; кап и пересмотр нарезки сохраняются.

## Пять вопросов

1. Критерий слабее предмета: три названных класса обхода выше, с конкретными деревьями и живыми свидетелями.
2. Команды и rc названы и исполнены; проблема не в отсутствии команд, а в ненаблюдаемых состояниях. Green матриц автора не объявляется доказательством полной защиты.
3. Допуск, единственный gate 107/118, запрет литерала, старый путь B и continue названы. Production-композиция и полный CURRENT_CONFIRMED остаются 118; новый gate/новая архитектура этим вердиктом не навязываются.
4. Зоны/исполнители (:659–703) существуют. Bootstrap для 118 выдаётся только после frozen 117/3; 117 остаётся splash/тема/StatusBar. Замороженные семьи и auth-слой не переписаны.
5. Нормы и границы проверены: committed предмет, независимый счёт, owner-строки, ПРОВОДКА, исполняемые матрицы и precision/pre_critic. Визуальные споры v2 и внепредметная проза не становятся новыми блокерами.

## Независимая полнота таблицы и сохранность v2

Команды: `node /tmp/dev-harness-verify/Critic117v3c/table.cjs`, `python3 /tmp/dev-harness-verify/Critic117v3c/table_mirror.py`, `python3 /tmp/dev-harness-verify/Critic117v3c/inventory.py`, `python3 /tmp/dev-harness-verify/Critic117v3c/static_compare.py`.

TypeScript AST выделяет реальный построитель VHOD_TABLICA; отдельное перечисление декартовых осей с ограничением формы даёт те же строки. Не просто повторён вывод пробы. Без связи формы произведение 5×5×2×4 = 200; после объявленного ограничения выразимости — 1 неподключённый + 1 пустой + 4+4 частичных + 16 полных = 26 строк, обе темы дают 52 клетки. Missing=[], extra=[], unique=26. Python AST зеркала _TABL_ROWS совпал с TS-таблицей. Единственная разрешённая строка POLNYJ/W1A/CURRENT; на остальных 50 theme-клетках наблюдаются email и code, отсутствие Erstinformation/Start, Г0 #FFFFFF/48/16/16. На двух разрешённых клетках — email Г0, Erstinformation, затем явный continue, Start. Неизвестные представлены объявленными W2/future, absence — отсутствующим ключом; это проверка объявленной нормализации, не всех произвольных JavaScript-объектов.

Независимо получены 44 прежних именованных клетки + 52 = 96; статических 43. Frozen 117/2: behavior 26 → 96, static 40 → 43, removed=[] в обеих семьях. Пред-v3 assertions сохранены побайтово; прежние мутационные преобразования не изменены. В дельте ровно четыре разрешённых пути: контракт, model/bootstrap.pilot-app.tsx, vkhod.test.tsx, vkhod_probe.py. Статическая проба побайтово прежняя.

Коммиты, реально менявшие контракт в диапазоне: dde2ac0c, 485b2c51, 6b6e55c1. У всех РАЗРЕШИЛ-ВЛАДЕЛЕЦ побайтово равна заданной строке; e840be06 и 462b7de2 текст не меняют. ПРОВОДКА frozen 117/2 и HEAD дословно равны. `git diff --exit-code ba3c5fb3~1 HEAD -- scripts/ fixtures/workshop_project/start_108/ fixtures/workshop_project/first_run_111/ fixtures/workshop_project/pilot_995/ fixtures/workshop_project/erstinformation_118/ fixtures/workshop_project/first_run_ekran_135/ contracts/118-erstinformation.md contracts/135-first-run-ekran.md` → rc0, пусто. Нового затронутого scripts-барьера/ключа verify_antiplacebo нет; полный anti-placebo не запускался.

СОВЕТ contracts/117-cmp-mob-vkhod-splash.md:538,550 — две локальные подписи счёта ошибочны: написано «40 truthy-строк … ×2». Независимо по строкам таблицы и named-списку кода: **20 строк ×2 темы =40 клеток**, не 40 строк ×2. Основные числа 26/52/96/53/43/38 и B failed26 совпали с прогонами. Эта описка не даёт обхода и FAIL не определяет.

## Совместимость 118 и коллизия #121/135

118 :15–16,39–43,49,66 прочитан: команда prerequisite `git fetch origin --tags && git rev-parse --quiet --verify refs/tags/frozen/contracts/117/3`, зона bootstrap у implementer118 после тега; приёмка 118 не ослабляется. Локальная неизменяющая проверка тега в своей копии — rc1, вывод пуст; fetch/freeze/publish не делались. Стендовая функция 118 `sud_kompoziciju` на её неизменённой пин-форме исполнила W0/current → start_ne_dopushchen и W1A/current → start_dopushchen, отказов []. Поэтому KOMPOZICIJA_W1A_NE_DOPUSHCHEN не неизбежен на разрешённом пути. Отдельно живая честная модель 117 показывает W1A/current → Erstinformation → continue → Start. **Пин-форма 118 — stand-in, не доказательство production-композиции/e2e 118**; ни она, ни этот вердикт не объявляют продукт118 done.

СОВЕТ contracts/117-cmp-mob-vkhod-splash.md:155–160,680–687 — коллизия стадий с уже влитым 135/#121 остаётся: 135 требует тёмный full-bleed внутри auth-зоны, 117 держит белый bootstrap-корень Г0 и исторический auth C≡B в своей поставке. V3 не разрешает переносить тёмный слой в корень и не отменяет auth-поставку 135. Отмечено по заданию, не пересуждается и не расширяет v3.

СОВЕТ contracts/117-cmp-mob-vkhod-splash.md:203–206 — `r3-g0-erstinformation` зелёный: чёрный/нулевой корень только на Erstinformation. Это **не блокер**: поверхность Erstinformation/Start явно отнесена к118, Г0 этого круга — F03.01/F03.02. Отрицательный контроль `r3-truthy-admission` новая таблица ловит; прямой обход continue также ловится прежними авторскими стабами.

## Условия и замеры

Все записи только в `/tmp/dev-harness-verify/Critic117v3c/`. H скопирован cp -r из предъявленного клона. Продуктовые R извлечены из read-only git-объекта B=8748a7a3352c14a6caa5a75b71f869e5d3b8152c; node_modules — инфраструктурный симлинк. Основные B/model/matrix измерения имеют разные R, атаки — отдельный R на мутанта/пробу; все исполнения последовательны, без одновременных Jest/генераторов. Node штатного shell PATH v26.5.1; только shell-гейты получают /usr/bin:/bin впереди из-за известного sed-shim, Jest PATH не подменяется. TMPDIR внутри собственной области.

Флаг стабов в семье 117 называется **--matrix**, не --stabs. Исполнены обе полные матрицы: 53 поведенческих и 38 статических стаба; все красны на объявленных ветвях, honest green. В том числе все 10 прежних мутантов критика и восемь дополнительных авторских миграционных стабов. Прямой независимый Jest-отчёт B: 26 failed /96 total, а не перепечатка счётчика пробы.

| Измерение | Результат |
|---|---|
| precision / pre_critic | rc0 / rc0 |
| behavior B | rc1, VKHOD_SPLASH_OVERLAY_ABSENT, failed26/96 |
| static B | rc1, VKHOD_SPLASH_COMPOSITE_ABSENT |
| behavior --model | rc0, 96/96 |
| static --model | rc0, 43/43 |
| behavior --matrix | rc0, 53/53 красны |
| static --matrix | rc0, 38/38 красны |
| pilot.test 995 | rc0, 14/14 |
| first_run_111 | rc0, 23/23 на объединении модели111 с полной поставкой117 |
| frozen/118/135 delta | rc0, пусто |
| frozen/contracts/117/3 | rc1, тега нет |

## Таблица собственных мутантов

Драйверы: `python3 /tmp/dev-harness-verify/Critic117v3c/attack.py` (10 прежних), `python3 /tmp/dev-harness-verify/Critic117v3c/new_attack.py` (9 новых). Каждый ставит изменённый blob pilot-app поверх полной модели в СВОЙ R и вызывает **неизменённые** штатные пробы без --model. Изменённые TSX и полный stdout/stderr каждой команды сохранены рядом с драйверами. Красный значит behavioral rc1 (не инфраструктурный сбой); static rc0. Зелёный — обе rc0.

| Мутант | behavioral | static | Итог |
|---|---|---|---|
| old-admission-default | rc1, failed 5 of 96 | rc0, 43/43 | красный |
| old-gate-default | rc1, failed 5 of 96 | rc0, 43/43 | красный |
| old-w0-stale-admitted | rc1, failed 7 of 96 | rc0, 43/43 | красный |
| old-light-bypasses-admission-gate | rc1, failed 27 of 96 | rc0, 43/43 | красный |
| old-onboarding-restyles-f03 | rc1, failed 54 of 96 | rc0, 43/43 | красный |
| new-light-gate-default | rc1, failed 2 of 96 | rc0, 43/43 | красный |
| new-light-stale-current | rc1, failed 2 of 96 | rc0, 43/43 | красный |
| new-empty-session-demo | rc1, failed 2 of 96 | rc0, 43/43 | красный |
| new-g0-denied-admission | rc1, failed 40 of 96 | rc0, 43/43 | красный |
| new-light-start-before-continue | rc1, failed 2 of 96 | rc0, 43/43 | красный |
| r3-extra-authenticated | rc0, behavioral 96/96 | rc0, 43/43 | **зелёный — обход** |
| r3-gate-from-entry | rc0, behavioral 96/96 | rc0, 43/43 | **зелёный — обход** |
| r3-admission-literal-completed | rc0, behavioral 96/96 | rc0, 43/43 | **зелёный — обход** |
| r3-cached-admission | rc0, behavioral 96/96 | rc0, 43/43 | **зелёный — обход** |
| r3-restart-completed-start | rc0, behavioral 96/96 | rc0, 43/43 | **зелёный — обход** |
| r3-g0-theme-change | rc0, behavioral 96/96 | rc0, 43/43 | **зелёный — обход** |
| r3-order-theme-autostart | rc0, behavioral 96/96 | rc0, 43/43 | **зелёный — обход** |
| r3-g0-erstinformation | rc0, behavioral 96/96 | rc0, 43/43 | зелёный; вне предмета Г0 |
| r3-truthy-admission | rc1, failed 12 of 96 | rc0, 43/43 | красный |

## Сырые выводы основных команд

Полные логи лежат рядом с вердиктом в корне Critic117v3c; ниже дословные результаты без 96 повторяющихся строк `case`.

### precision

```text
$ bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic117v3c/repo contracts/117-cmp-mob-vkhod-splash.md
OK

rc=0
```

### pre_critic

```text
$ bash scripts/pre_critic.sh contracts/117-cmp-mob-vkhod-splash.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
КРИТИК: дверь зелёная

rc=0
```

### behavior_B

```text
$ python3 fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/R_behavior_B
VKHOD_SPLASH_OVERLAY_ABSENT
failed 26 of 96

rc=1
```

### static_B

```text
$ python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/R_static_B
VKHOD_SPLASH_COMPOSITE_ABSENT

rc=1
```

### behavior_model

```text
$ python3 fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/R_behavior_model --model
behavioral 96/96

rc=0
```

### static_model

```text
$ python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/R_static_model --model
static 43/43

rc=0
```

### pilot995

```text
PASS src/bootstrap/__tests__/pilot.test.tsx
  995 pilot
    ✓ DIRECT_unknown (1019 ms)
    ✓ DIRECT_incomplete (6 ms)
    ✓ INVALID_CODE (6 ms)
    ✓ RESEND_UNCONFIRMED (142 ms)
    ✓ RESEND_CONFIRMED (10 ms)
    ✓ RESEND_COOLDOWN (6 ms)
    ✓ EMAIL_STALE (143 ms)
    ✓ RECOVERY_A07 (6 ms)
    ✓ AUTH_stale (6 ms)
    ✓ AUTH_revoked (7 ms)
    ✓ AUTH_missing_scope (6 ms)
    ✓ SECRET (8 ms)
    ✓ REPLAY (7 ms)
    ✓ DEFAULT_OFFLINE (96 ms)

Test Suites: 1 passed, 1 total
Tests:       14 passed, 14 total
Snapshots:   0 total
Time:        3.806 s
Ran all test suites within paths "/tmp/dev-harness-verify/Critic117v3c/Rpilot995/mobile/src/bootstrap/__tests__/pilot.test.tsx".
Test results written to: ../../tmp/tmpmfby14ka.json

rc=0
```

### first111

```text
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/first_run_111/first_run_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/Rfirst111
honest 23/23

rc=0
```

### compatibility118

```text
$ bash /tmp/dev-harness-verify/Critic117v3c/R_compat118/mobile/src/bootstrap/__tests__/kompozicija.stand-in.sh W0 current
start_ne_dopushchen
rc=0
$ bash /tmp/dev-harness-verify/Critic117v3c/R_compat118/mobile/src/bootstrap/__tests__/kompozicija.stand-in.sh W1A current
start_dopushchen
rc=0
sud_kompoziciju=[]
rc=0
```

### count_named

```text
migracija-g0-nedopusk-restail: connected rows with gate!=current: 20; x2 themes=40; actual named table cells=40; prose lines 538/550 says 40 rows x2
migracija-g0-restail-nedopusk-admission: connected rows with admission!=W1A: 20; x2 themes=40; actual named table cells=40; prose lines 538/550 says 40 rows x2
```

### Матрицы автора — сырой stdout

```text
$ python3 fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/R_behavior_matrix --matrix
honest green 96
mutant restyle-welcome-vkhod red= ['RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT']
mutant restyle-recovery-vkhod red= ['RESTYLE_GUARD_995_RECOVERY_DARK', 'RESTYLE_GUARD_995_RECOVERY_LIGHT']
mutant restyle-unavailable-vkhod red= ['RESTYLE_GUARD_995_UNAVAILABLE_DARK', 'RESTYLE_GUARD_995_UNAVAILABLE_LIGHT']
mutant restyle-recovery-light-vkhod red= ['RESTYLE_GUARD_995_RECOVERY_LIGHT']
mutant overlay-absent-first-commit red= ['PROD_ENTRY_OS_THEME_DARK', 'PROD_ENTRY_OS_THEME_LIGHT', 'SPLASH_HIDEASYNC_ORDER_DARK', 'SPLASH_HIDEASYNC_ORDER_LIGHT', 'SPLASH_OVERLAY_COMPOSITE_DARK', 'SPLASH_OVERLAY_COMPOSITE_LIGHT', 'SPLASH_OVERLAY_CONTAIN_DARK', 'SPLASH_OVERLAY_CONTAIN_LIGHT', 'SPLASH_OVERLAY_GEOMETRY_DARK', 'SPLASH_OVERLAY_GEOMETRY_LIGHT', 'SPLASH_OVERLAY_MOUNTED_DARK', 'SPLASH_OVERLAY_MOUNTED_LIGHT', 'SPLASH_OVERLAY_NO_TEXT_DARK', 'SPLASH_OVERLAY_NO_TEXT_LIGHT', 'SPLASH_OVERLAY_TIMER_HIDE_DARK', 'SPLASH_OVERLAY_TIMER_HIDE_LIGHT', 'SPLASH_OVERLAY_VISIBLE_DARK', 'SPLASH_OVERLAY_VISIBLE_LIGHT', 'SPLASH_OVERLAY_ZORDER_DARK', 'SPLASH_OVERLAY_ZORDER_LIGHT']
mutant overlay-text-words red= ['SPLASH_OVERLAY_NO_TEXT_DARK', 'SPLASH_OVERLAY_NO_TEXT_LIGHT']
mutant overlay-hideasync-skip red= ['SPLASH_HIDEASYNC_ORDER_DARK', 'SPLASH_HIDEASYNC_ORDER_LIGHT']
mutant overlay-hideasync-module-scope red= ['SPLASH_HIDEASYNC_ORDER_DARK', 'SPLASH_HIDEASYNC_ORDER_LIGHT']
mutant overlay-timer-none red= ['SPLASH_OVERLAY_TIMER_HIDE_DARK', 'SPLASH_OVERLAY_TIMER_HIDE_LIGHT', 'STATUS_BAR_STYLE_DARK', 'STATUS_BAR_STYLE_LIGHT']
mutant overlay-wrong-source red= ['SPLASH_OVERLAY_COMPOSITE_DARK', 'SPLASH_OVERLAY_COMPOSITE_LIGHT']
mutant overlay-hide-before-commit red= ['SPLASH_HIDEASYNC_ORDER_DARK', 'SPLASH_HIDEASYNC_ORDER_LIGHT']
mutant prod-theme-os-ignored red= ['PROD_ENTRY_OS_THEME_LIGHT', 'STATUS_BAR_STYLE_LIGHT']
mutant prod-theme-light-hardcode red= ['PROD_ENTRY_OS_THEME_DARK', 'SPLASH_OVERLAY_COMPOSITE_DARK', 'SPLASH_OVERLAY_MOUNTED_DARK', 'STATUS_BAR_STYLE_DARK']
mutant auth-restyled-ground red= ['MIGRACIYA_G0_F03_DOPUSK_DARK', 'MIGRACIYA_G0_F03_DOPUSK_LIGHT', 'MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_NEIZVESTNOE_OTSUT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_NEIZVESTNOE_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_NULL_OTSUT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_NULL_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_CURRENT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_NULL_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_NULL_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_STALE_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_STALE_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W0_OTSUT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W0_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W1A_OTSUT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W1A_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_NEPODKLYUCHEN_OTSUT_OTSUT_DARK', 'MIGRACIYA_TABLICA_NEPODKLYUCHEN_OTSUT_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_NULL_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_STALE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_STALE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NULL_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NULL_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_NULL_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NULL_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_STALE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NULL_STALE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W0_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W0_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_NULL_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W0_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_STALE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W0_STALE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NULL_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_STALE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_STALE_LIGHT', 'MIGRACIYA_TABLICA_PUSTOJ_OTSUT_OTSUT_DARK', 'MIGRACIYA_TABLICA_PUSTOJ_OTSUT_OTSUT_LIGHT', 'RESTYLE_GUARD_995_F03_DARK', 'RESTYLE_GUARD_995_F03_LIGHT']
mutant auth-restyled-code-light red= ['MIGRACIYA_G0_F03_ONBOARDING_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_NEIZVESTNOE_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_NULL_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_NULL_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_STALE_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W0_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W1A_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_NEPODKLYUCHEN_OTSUT_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_STALE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_STALE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_STALE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_STALE_LIGHT', 'MIGRACIYA_TABLICA_PUSTOJ_OTSUT_OTSUT_LIGHT', 'RESTYLE_GUARD_995_F03_LIGHT']
mutant overlay-intrinsic-size red= ['SPLASH_OVERLAY_CONTAIN_DARK', 'SPLASH_OVERLAY_CONTAIN_LIGHT']
mutant overlay-opacity-zero red= ['SPLASH_OVERLAY_VISIBLE_DARK', 'SPLASH_OVERLAY_VISIBLE_LIGHT']
mutant overlay-display-none red= ['PROD_ENTRY_OS_THEME_DARK', 'PROD_ENTRY_OS_THEME_LIGHT', 'SPLASH_OVERLAY_MOUNTED_DARK', 'SPLASH_OVERLAY_MOUNTED_LIGHT', 'SPLASH_OVERLAY_TIMER_HIDE_DARK', 'SPLASH_OVERLAY_TIMER_HIDE_LIGHT', 'SPLASH_OVERLAY_VISIBLE_DARK', 'SPLASH_OVERLAY_VISIBLE_LIGHT']
mutant root-opacity-zero red= ['SPLASH_OVERLAY_VISIBLE_DARK', 'SPLASH_OVERLAY_VISIBLE_LIGHT']
mutant overlay-zero-size red= ['SPLASH_OVERLAY_CONTAIN_DARK', 'SPLASH_OVERLAY_CONTAIN_LIGHT']
mutant overlay-transform-translatex red= ['SPLASH_OVERLAY_GEOMETRY_DARK', 'SPLASH_OVERLAY_GEOMETRY_LIGHT']
mutant overlay-transform-translatey red= ['SPLASH_OVERLAY_GEOMETRY_DARK', 'SPLASH_OVERLAY_GEOMETRY_LIGHT']
mutant overlay-transform-scale red= ['SPLASH_OVERLAY_GEOMETRY_DARK', 'SPLASH_OVERLAY_GEOMETRY_LIGHT']
mutant overlay-margin-offset red= ['SPLASH_OVERLAY_GEOMETRY_DARK', 'SPLASH_OVERLAY_GEOMETRY_LIGHT']
mutant overlay-zindex-minus red= ['SPLASH_OVERLAY_ZORDER_DARK', 'SPLASH_OVERLAY_ZORDER_LIGHT']
mutant overlay-zindex-zero red= ['SPLASH_OVERLAY_ZORDER_DARK', 'SPLASH_OVERLAY_ZORDER_LIGHT']
mutant overlay-before-firstrun red= ['SPLASH_OVERLAY_ZORDER_DARK', 'SPLASH_OVERLAY_ZORDER_LIGHT']
mutant statusbar-absent red= ['STATUS_BAR_STYLE_DARK', 'STATUS_BAR_STYLE_LIGHT']
mutant statusbar-light-both red= ['STATUS_BAR_STYLE_LIGHT']
mutant statusbar-dark-both red= ['STATUS_BAR_STYLE_DARK']
mutant statusbar-in-overlay red= ['STATUS_BAR_STYLE_DARK', 'STATUS_BAR_STYLE_LIGHT']
mutant migracija-admission-literal red= ['MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT', 'MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_CURRENT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NULL_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W0_CURRENT_LIGHT', 'MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT']
mutant migracija-gate-ignor red= ['MIGRACIYA_TABLICA_CHASTICHNYJ_W1A_OTSUT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W1A_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NULL_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_STALE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_STALE_LIGHT', 'MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT', 'MIGRACIYA_W1A_NULL_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT']
mutant migracija-start-pryamo red= ['MIGRACIYA_TABLICA_POLNYJ_W1A_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_CURRENT_LIGHT', 'MIGRACIYA_W1A_CURRENT_MARSHRUT', 'MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT']
mutant migracija-f03-put-udalen red= ['MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT', 'MIGRACIYA_G0_F03_DOPUSK_DARK', 'MIGRACIYA_G0_F03_DOPUSK_LIGHT', 'MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_NEIZVESTNOE_OTSUT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_NEIZVESTNOE_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_NULL_OTSUT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_NULL_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_CURRENT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_NULL_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_NULL_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_STALE_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_STALE_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W0_OTSUT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W0_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W1A_OTSUT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W1A_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_NEPODKLYUCHEN_OTSUT_OTSUT_DARK', 'MIGRACIYA_TABLICA_NEPODKLYUCHEN_OTSUT_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_NULL_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_STALE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_STALE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NULL_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NULL_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_NULL_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NULL_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_STALE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NULL_STALE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W0_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W0_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_NULL_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W0_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_STALE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W0_STALE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NULL_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_STALE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_STALE_LIGHT', 'MIGRACIYA_TABLICA_PUSTOJ_OTSUT_OTSUT_DARK', 'MIGRACIYA_TABLICA_PUSTOJ_OTSUT_OTSUT_LIGHT', 'MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT', 'MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT', 'MIGRACIYA_W0_STALE_PREZHNIJ_PUT', 'MIGRACIYA_W1A_CURRENT_MARSHRUT', 'MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT', 'MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT', 'MIGRACIYA_W1A_NULL_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT', 'RESTYLE_GUARD_995_F03_DARK', 'RESTYLE_GUARD_995_F03_LIGHT', 'RESTYLE_GUARD_995_RECOVERY_DARK', 'RESTYLE_GUARD_995_RECOVERY_LIGHT', 'RESTYLE_GUARD_995_UNAVAILABLE_DARK', 'RESTYLE_GUARD_995_UNAVAILABLE_LIGHT', 'RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT']
mutant migracija-admission-default red= ['MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_CURRENT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NULL_CURRENT_LIGHT']
mutant migracija-gate-default red= ['MIGRACIYA_TABLICA_CHASTICHNYJ_W1A_OTSUT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W1A_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NULL_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NULL_LIGHT', 'MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT']
mutant migracija-w0-stale-dopushchen red= ['MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_STALE_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_STALE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_STALE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NULL_STALE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_STALE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W0_STALE_LIGHT', 'MIGRACIYA_W0_STALE_PREZHNIJ_PUT']
mutant migracija-svetlui-obhod red= ['MIGRACIYA_G0_F03_ONBOARDING_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_NEIZVESTNOE_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_NULL_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_NULL_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_STALE_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W0_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W1A_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_STALE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_STALE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_STALE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_STALE_LIGHT', 'MIGRACIYA_TABLICA_PUSTOJ_OTSUT_OTSUT_LIGHT', 'MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT']
mutant migracija-onboarding-restyles-f03 red= ['MIGRACIYA_G0_F03_DOPUSK_DARK', 'MIGRACIYA_G0_F03_DOPUSK_LIGHT', 'MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_NEIZVESTNOE_OTSUT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_NEIZVESTNOE_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_NULL_OTSUT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_NULL_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_CURRENT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_NULL_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_NULL_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_STALE_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_STALE_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W0_OTSUT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W0_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W1A_OTSUT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W1A_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_NULL_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_STALE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_STALE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NULL_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NULL_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_NULL_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NULL_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_STALE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NULL_STALE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W0_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W0_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_NULL_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W0_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_STALE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W0_STALE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NULL_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_STALE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_STALE_LIGHT', 'MIGRACIYA_TABLICA_PUSTOJ_OTSUT_OTSUT_DARK', 'MIGRACIYA_TABLICA_PUSTOJ_OTSUT_OTSUT_LIGHT']
mutant migracija-marshrut-tolko-temnyi red= ['MIGRACIYA_TABLICA_POLNYJ_W1A_CURRENT_LIGHT', 'MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT']
mutant migracija-stale-kak-current red= ['MIGRACIYA_TABLICA_POLNYJ_W1A_STALE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_STALE_LIGHT', 'MIGRACIYA_W1A_STALE_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT']
mutant migracija-restyle-pri-dopuske red= ['MIGRACIYA_G0_F03_DOPUSK_DARK', 'MIGRACIYA_G0_F03_DOPUSK_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_CURRENT_LIGHT']
mutant migracija-light-gate-default red= ['MIGRACIYA_TABLICA_CHASTICHNYJ_W1A_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NULL_LIGHT']
mutant migracija-light-stale-current red= ['MIGRACIYA_TABLICA_POLNYJ_W1A_STALE_LIGHT', 'MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT']
mutant migracija-pustaya-sessiya-demo red= ['MIGRACIYA_TABLICA_PUSTOJ_OTSUT_OTSUT_DARK', 'MIGRACIYA_TABLICA_PUSTOJ_OTSUT_OTSUT_LIGHT']
mutant migracija-g0-nedopusk-restail red= ['MIGRACIYA_TABLICA_CHASTICHNYJ_NEIZVESTNOE_OTSUT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_NEIZVESTNOE_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_NULL_OTSUT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_NULL_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_NULL_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_NULL_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_STALE_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_STALE_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W0_OTSUT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W0_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W1A_OTSUT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W1A_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_NULL_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_STALE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_STALE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NULL_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_NULL_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NULL_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_STALE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NULL_STALE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W0_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_NULL_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W0_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_STALE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W0_STALE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NULL_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_STALE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_STALE_LIGHT', 'MIGRACIYA_TABLICA_PUSTOJ_OTSUT_OTSUT_DARK', 'MIGRACIYA_TABLICA_PUSTOJ_OTSUT_OTSUT_LIGHT']
mutant migracija-light-start-do-continue red= ['MIGRACIYA_TABLICA_POLNYJ_W1A_CURRENT_LIGHT', 'MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT']
mutant migracija-null-kak-current red= ['MIGRACIYA_TABLICA_CHASTICHNYJ_W1A_OTSUT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W1A_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NULL_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NULL_LIGHT', 'MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT', 'MIGRACIYA_W1A_NULL_PREZHNIJ_PUT']
mutant migracija-or-uslovie red= ['MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT', 'MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_CURRENT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W1A_OTSUT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W1A_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NULL_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W0_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NULL_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W1A_STALE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W1A_STALE_LIGHT', 'MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT', 'MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT', 'MIGRACIYA_W1A_NULL_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT']
mutant migracija-port-est-dopusk red= ['MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_CURRENT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NULL_CURRENT_LIGHT']
mutant migracija-g0-restail-nedopusk-admission red= ['MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_NEIZVESTNOE_OTSUT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_NEIZVESTNOE_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_NULL_OTSUT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_NULL_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_CURRENT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_NULL_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_NULL_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_STALE_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_OTSUT_STALE_LIGHT', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W0_OTSUT_DARK', 'MIGRACIYA_TABLICA_CHASTICHNYJ_W0_OTSUT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_NULL_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_STALE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NEIZVESTNOE_STALE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NULL_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NULL_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_NULL_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NULL_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_NULL_STALE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_NULL_STALE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_CURRENT_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W0_CURRENT_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_NEIZVESTNOE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W0_NEIZVESTNOE_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_NULL_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W0_NULL_LIGHT', 'MIGRACIYA_TABLICA_POLNYJ_W0_STALE_DARK', 'MIGRACIYA_TABLICA_POLNYJ_W0_STALE_LIGHT', 'MIGRACIYA_TABLICA_PUSTOJ_OTSUT_OTSUT_DARK', 'MIGRACIYA_TABLICA_PUSTOJ_OTSUT_OTSUT_LIGHT']
mutant migracija-temnyi-start-do-continue red= ['MIGRACIYA_TABLICA_POLNYJ_W1A_CURRENT_DARK', 'MIGRACIYA_W1A_CURRENT_MARSHRUT']

rc=0
```

```text
$ python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/R_static_matrix --matrix
RED ICON_RASTER_WHOLE: 0.0264 {4: 1004453, 2: 44123}
mutant icon-template-bytes red= ['ICON_NOT_TEMPLATE_BYTES', 'ICON_PIXELS_MARK', 'ICON_RASTER_WHOLE']
mutant adaptive-expo-blue red= ['ICON_ADAPTIVE_BG_DARK']
RED SPLASH_NATIVE_GENERATED_DARK_MDPI: ['знак 181x169 != 181.0x173.0±3'] (0.7958, {0: 70348, 4: 617, 2: 11979})
RED SPLASH_NATIVE_GENERATED_DARK_HDPI: ['знак 272x254 != 271.5x259.5±3'] (0.7939, {0: 158219, 4: 1281, 2: 27124})
RED SPLASH_NATIVE_GENERATED_DARK_XHDPI: ['знак 362x338 != 362.0x346.0±3'] (0.7927, {0: 281508, 4: 2217, 2: 48051})
RED SPLASH_NATIVE_GENERATED_DARK_XXHDPI: ['знак 543x507 != 543.0x519.0±3'] (0.7909, {0: 633357, 4: 5013, 2: 108126})
RED SPLASH_NATIVE_GENERATED_DARK_XXXHDPI: ['знак 724x676 != 724.0x692.0±3'] (0.7906, {0: 1126010, 4: 8911, 2: 192183})
RED SPLASH_EFFECTIVE_IOS_DARK: {'ratio': 0.5293, 'asset': {0: 28778, 2: 19786}, 'expected': {0: 36174, 2: 10297, 3: 2093}}
RED SPLASH_SIGN_RASTER_DARK: 0.5293 {0: 28778, 2: 19786}
mutant splash-image-forgery red= ['SPLASH_BLOCKS_DARK_LIGHT', 'SPLASH_EFFECTIVE_IOS_DARK', 'SPLASH_NATIVE_GENERATED', 'SPLASH_NATIVE_GENERATED_DARK_HDPI', 'SPLASH_NATIVE_GENERATED_DARK_MDPI', 'SPLASH_NATIVE_GENERATED_DARK_XHDPI', 'SPLASH_NATIVE_GENERATED_DARK_XXHDPI', 'SPLASH_NATIVE_GENERATED_DARK_XXXHDPI', 'SPLASH_SIGN_RASTER_DARK']
RED ICON_RASTER_WHOLE: 0.0475 {0: 1048573, 1: 1, 2: 1, 3: 1}
mutant icon-twin-three-pixels red= ['ICON_RASTER_WHOLE']
RED SPLASH_COMPOSITE_ETALON_DARK: {'recall': 0.0004, 'precision': 1.0, 'm_total': 15439, 'c_op': 6}
RED SPLASH_COMPOSITE_ETALON_LIGHT: {'recall': 0.0004, 'precision': 1.0, 'm_total': 15346, 'c_op': 6}
mutant splash-composite-twin red= ['SPLASH_COMPOSITE_ETALON_DARK', 'SPLASH_COMPOSITE_ETALON_LIGHT']
RED SPLASH_COMPOSITE_ETALON_DARK: {'recall': 0.8116, 'precision': 1.0, 'm_total': 15439, 'c_op': 12530}
RED SPLASH_COMPOSITE_ETALON_LIGHT: {'recall': 0.8152, 'precision': 1.0, 'm_total': 15346, 'c_op': 12510}
mutant splash-composite-no-words red= ['SPLASH_COMPOSITE_ETALON_DARK', 'SPLASH_COMPOSITE_ETALON_LIGHT']
RED SPLASH_COMPOSITE_ETALON_DARK: {'recall': 0.6297, 'precision': 0.6297, 'm_total': 15439, 'c_op': 15439}
RED SPLASH_COMPOSITE_ETALON_LIGHT: {'recall': 0.6337, 'precision': 0.6337, 'm_total': 15346, 'c_op': 15346}
mutant splash-composite-shifted red= ['SPLASH_COMPOSITE_ETALON_DARK', 'SPLASH_COMPOSITE_ETALON_LIGHT']
RED SPLASH_COMPOSITE_ETALON_DARK: размер 195x422 != эталон 390x844 (масштаб теряет маску)
RED SPLASH_COMPOSITE_ETALON_LIGHT: размер 195x422 != эталон 390x844 (масштаб теряет маску)
mutant splash-composite-halfres red= ['SPLASH_COMPOSITE_ETALON_DARK', 'SPLASH_COMPOSITE_ETALON_LIGHT']
RED SPLASH_NATIVE_GENERATED_LIGHT_MDPI: ['знак 76x73 != 181.0x173.0±3'] (0.8319, {0: 80574, 2: 1766, 4: 226, 3: 378})
RED SPLASH_NATIVE_GENERATED_DARK_MDPI: ['знак 76x73 != 181.0x173.0±3'] (0.8319, {0: 80577, 4: 343, 2: 1656, 3: 368})
RED SPLASH_NATIVE_GENERATED_LIGHT_HDPI: ['знак 114x109 != 271.5x259.5±3'] (0.8293, {0: 181394, 4: 447, 2: 3925, 3: 858})
RED SPLASH_NATIVE_GENERATED_DARK_HDPI: ['знак 114x109 != 271.5x259.5±3'] (0.8293, {0: 181392, 4: 609, 2: 3779, 3: 844})
RED SPLASH_NATIVE_GENERATED_LIGHT_XHDPI: ['знак 152x145 != 362.0x346.0±3'] (0.8279, {0: 322558, 2: 7002, 4: 685, 3: 1531})
RED SPLASH_NATIVE_GENERATED_DARK_XHDPI: ['знак 152x145 != 362.0x346.0±3'] (0.8279, {0: 322558, 4: 934, 2: 6773, 3: 1511})
RED SPLASH_NATIVE_GENERATED_LIGHT_XXHDPI: ['знак 228x218 != 543.0x519.0±3'] (0.8263, {0: 725819, 4: 1124, 2: 16102, 3: 3451})
RED SPLASH_NATIVE_GENERATED_DARK_XXHDPI: ['знак 228x218 != 543.0x519.0±3'] (0.8263, {0: 725825, 4: 1949, 2: 15322, 3: 3400})
RED SPLASH_NATIVE_GENERATED_LIGHT_XXXHDPI: ['знак 304x291 != 724.0x692.0±3'] (0.8254, {0: 1290403, 2: 28519, 4: 2037, 3: 6145})
RED SPLASH_NATIVE_GENERATED_DARK_XXXHDPI: ['знак 304x291 != 724.0x692.0±3'] (0.8254, {0: 1290404, 4: 3430, 2: 27231, 3: 6039})
RED SPLASH_EFFECTIVE_IOS_LIGHT: {'ratio': 0.978, 'asset': {0: 18662, 4: 643, 2: 9808, 3: 2200}, 'expected': {0: 18931, 2: 10289, 3: 2093}}
RED SPLASH_EFFECTIVE_IOS_DARK: {'ratio': 0.9777, 'asset': {0: 18664, 4: 672, 2: 9816, 3: 2161}, 'expected': {0: 18931, 2: 10289, 3: 2093}}
RED SPLASH_IOS_STORYBOARD: [] False {'width': 76, 'height': 76, 'constraints': ['centerX', 'centerY']}
mutant splash-imagewidth-76 red= ['SPLASH_BLOCKS_DARK_LIGHT', 'SPLASH_EFFECTIVE_IOS_DARK', 'SPLASH_EFFECTIVE_IOS_LIGHT', 'SPLASH_IOS_STORYBOARD', 'SPLASH_NATIVE_GENERATED', 'SPLASH_NATIVE_GENERATED_DARK_HDPI', 'SPLASH_NATIVE_GENERATED_DARK_MDPI', 'SPLASH_NATIVE_GENERATED_DARK_XHDPI', 'SPLASH_NATIVE_GENERATED_DARK_XXHDPI', 'SPLASH_NATIVE_GENERATED_DARK_XXXHDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_HDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_MDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_XHDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_XXHDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_XXXHDPI']
RED ADAPTIVE_FG_RASTER: 0.8643 {0: 242577, 4: 19567}
RED ADAPTIVE_MONO_RASTER: 0.9052 {0: 172617, 4: 14007}
RED FAVICON_RASTER_WHOLE: 0.1866 {0: 164, 2: 1821, 4: 319}
mutant adaptive-favicon-template red= ['ADAPTIVE_BG_SOLID', 'ADAPTIVE_FG_RASTER', 'ADAPTIVE_MONO_RASTER', 'FAVICON_RASTER_WHOLE']
RED SPLASH_NATIVE_GENERATED_LIGHT_MDPI: ['знак 181x169 != 181.0x173.0±3'] (0.7609, {0: 70348, 4: 12498, 2: 98})
RED SPLASH_NATIVE_GENERATED_DARK_MDPI: ['знак 181x169 != 181.0x173.0±3'] (0.7958, {0: 70348, 4: 617, 2: 11979})
RED SPLASH_NATIVE_GENERATED_LIGHT_HDPI: ['знак 272x254 != 271.5x259.5±3'] (0.7593, {0: 158219, 2: 372, 4: 28033})
RED SPLASH_NATIVE_GENERATED_DARK_HDPI: ['знак 272x254 != 271.5x259.5±3'] (0.7939, {0: 158219, 4: 1281, 2: 27124})
RED SPLASH_NATIVE_GENERATED_LIGHT_XHDPI: ['знак 362x338 != 362.0x346.0±3'] (0.7585, {0: 281508, 4: 49651, 2: 617})
RED SPLASH_NATIVE_GENERATED_DARK_XHDPI: ['знак 362x338 != 362.0x346.0±3'] (0.7927, {0: 281508, 4: 2217, 2: 48051})
RED SPLASH_NATIVE_GENERATED_LIGHT_XXHDPI: ['знак 543x507 != 543.0x519.0±3'] (0.7572, {0: 633357, 2: 1416, 4: 111723})
RED SPLASH_NATIVE_GENERATED_DARK_XXHDPI: ['знак 543x507 != 543.0x519.0±3'] (0.7909, {0: 633357, 4: 5013, 2: 108126})
RED SPLASH_NATIVE_GENERATED_LIGHT_XXXHDPI: ['знак 724x676 != 724.0x692.0±3'] (0.7569, {0: 1126010, 2: 2511, 4: 198583})
RED SPLASH_NATIVE_GENERATED_DARK_XXXHDPI: ['знак 724x676 != 724.0x692.0±3'] (0.7906, {0: 1126010, 4: 8911, 2: 192183})
mutant platform-image-template-override red= ['SPLASH_NATIVE_GENERATED', 'SPLASH_NATIVE_GENERATED_DARK_HDPI', 'SPLASH_NATIVE_GENERATED_DARK_MDPI', 'SPLASH_NATIVE_GENERATED_DARK_XHDPI', 'SPLASH_NATIVE_GENERATED_DARK_XXHDPI', 'SPLASH_NATIVE_GENERATED_DARK_XXXHDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_HDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_MDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_XHDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_XXHDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_XXXHDPI']
RED SPLASH_NATIVE_GENERATED_LIGHT_MDPI: ['знак 60x70 != 181.0x173.0±3'] (0.8494, {0: 82032, 2: 728, 4: 89, 3: 95})
RED SPLASH_NATIVE_GENERATED_LIGHT_HDPI: ['знак 89x105 != 271.5x259.5±3'] (0.8472, {0: 184734, 2: 1429, 4: 241, 3: 220})
RED SPLASH_NATIVE_GENERATED_LIGHT_XHDPI: ['знак 119x140 != 362.0x346.0±3'] (0.8458, {0: 328523, 2: 2376, 4: 492, 3: 385})
RED SPLASH_NATIVE_GENERATED_LIGHT_XXHDPI: ['знак 179x210 != 543.0x519.0±3'] (0.8446, {0: 739500, 4: 1066, 2: 5038, 3: 892})
RED SPLASH_NATIVE_GENERATED_LIGHT_XXXHDPI: ['знак 237x280 != 724.0x692.0±3'] (0.8439, {0: 1314841, 2: 8922, 4: 1753, 3: 1588})
mutant platform-same-basename red= ['SPLASH_NATIVE_GENERATED', 'SPLASH_NATIVE_GENERATED_LIGHT_HDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_MDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_XHDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_XXHDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_XXXHDPI']
RED SPLASH_NATIVE_GENERATED_LIGHT_MDPI: ['знак 181x169 != 181.0x173.0±3'] (0.7609, {0: 70348, 4: 12498, 2: 98})
RED SPLASH_NATIVE_GENERATED_LIGHT_HDPI: ['знак 272x254 != 271.5x259.5±3'] (0.7593, {0: 158219, 2: 372, 4: 28033})
RED SPLASH_NATIVE_GENERATED_LIGHT_XHDPI: ['знак 362x338 != 362.0x346.0±3'] (0.7585, {0: 281508, 4: 49651, 2: 617})
RED SPLASH_NATIVE_GENERATED_LIGHT_XXHDPI: ['знак 543x507 != 543.0x519.0±3'] (0.7572, {0: 633357, 2: 1416, 4: 111723})
RED SPLASH_NATIVE_GENERATED_LIGHT_XXXHDPI: ['знак 724x676 != 724.0x692.0±3'] (0.7569, {0: 1126010, 2: 2511, 4: 198583})
mutant platform-density-template red= ['SPLASH_NATIVE_GENERATED', 'SPLASH_NATIVE_GENERATED_LIGHT_HDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_MDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_XHDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_XXHDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_XXXHDPI']
RED SPLASH_NATIVE_GENERATED_DARK_MDPI: нет файла
RED SPLASH_NATIVE_GENERATED_DARK_HDPI: нет файла
RED SPLASH_NATIVE_GENERATED_DARK_XHDPI: нет файла
RED SPLASH_NATIVE_GENERATED_DARK_XXHDPI: нет файла
RED SPLASH_NATIVE_GENERATED_DARK_XXXHDPI: нет файла
RED SPLASH_EFFECTIVE_IOS_DARK: нет файла по эффективному пути: 
RED SPLASH_SIGN_RASTER_DARK: нет файла 
mutant splash-dark-block-missing red= ['SPLASH_BLOCKS_DARK_LIGHT', 'SPLASH_EFFECTIVE_DARK_LIGHT', 'SPLASH_EFFECTIVE_IOS_DARK', 'SPLASH_NATIVE_GENERATED', 'SPLASH_NATIVE_GENERATED_DARK_HDPI', 'SPLASH_NATIVE_GENERATED_DARK_MDPI', 'SPLASH_NATIVE_GENERATED_DARK_XHDPI', 'SPLASH_NATIVE_GENERATED_DARK_XXHDPI', 'SPLASH_NATIVE_GENERATED_DARK_XXXHDPI', 'SPLASH_SIGN_RASTER_DARK']
mutant splash-light-missing red= ['SPLASH_BLOCKS_DARK_LIGHT', 'SPLASH_EFFECTIVE_DARK_LIGHT']
mutant user-style-light-stays red= ['USER_STYLE_AUTOMATIC']
RED SPLASH_IOS_STORYBOARD: ['ios'] True {'width': 414, 'height': 736, 'constraints': ['bottom', 'leading', 'top', 'trailing']}
mutant ios-legacy red= ['SPLASH_IOS_STORYBOARD']
RED SPLASH_OVERLAY_CONSUMES_COMPOSITE: ['/tmp/dev-harness-verify/Critic117v3c/R_static_matrix/mobile/assets/images/splash-composite-dark.png', '/tmp/dev-harness-verify/Critic117v3c/R_static_matrix/mobile/assets/images/splash-composite-light.png']
mutant overlay-wrong-source red= ['SPLASH_OVERLAY_CONSUMES_COMPOSITE']
RED SPLASH_OVERLAY_NO_TRANSFORM: ['transform', 'translateX']
mutant overlay-transform-translatex red= ['SPLASH_OVERLAY_NO_TRANSFORM']
RED SPLASH_OVERLAY_NO_TRANSFORM: ['transform', 'translateY']
mutant overlay-transform-translatey red= ['SPLASH_OVERLAY_NO_TRANSFORM']
RED SPLASH_OVERLAY_NO_TRANSFORM: ['scale', 'transform']
mutant overlay-transform-scale red= ['SPLASH_OVERLAY_NO_TRANSFORM']
RED SPLASH_OVERLAY_NO_LAYOUT_OFFSET: ['marginLeft']
mutant overlay-margin-offset red= ['SPLASH_OVERLAY_NO_LAYOUT_OFFSET']
RED SPLASH_OVERLAY_ZORDER: ['zIndex -1']
mutant overlay-zindex-minus red= ['SPLASH_OVERLAY_ZORDER']
RED SPLASH_OVERLAY_ZORDER: ['zIndex 0']
mutant overlay-zindex-zero red= ['SPLASH_OVERLAY_ZORDER']
RED SPLASH_OVERLAY_ZORDER: ['zIndex отсутствует/не литерал', 'оверлей раньше <FirstRunScreen']
mutant overlay-before-firstrun red= ['SPLASH_OVERLAY_ZORDER']
RED MAESTRO_SPLASH_FRAME_WAIT: шаг перед vkhod-117-splash — не extendedWaitUntil visible splash-overlay
mutant maestro-splash-no-wait red= ['MAESTRO_SPLASH_FRAME_WAIT']
RED MAESTRO_SPLASH_FRAME_WAIT: шаг перед vkhod-117-splash — не extendedWaitUntil visible splash-overlay
mutant maestro-splash-wait-commented red= ['MAESTRO_SPLASH_FRAME_WAIT']
RED MAESTRO_SPLASH_FRAME_WAIT: шаг перед vkhod-117-splash — не extendedWaitUntil visible splash-overlay
mutant maestro-splash-wait-after-shot red= ['MAESTRO_SPLASH_FRAME_WAIT']
RED MAESTRO_FIRST_RUN_ORDER: между vkhod-117-splash и vkhod-117-first-run нет notVisible splash-overlay
mutant maestro-first-run-overlay-kept red= ['MAESTRO_FIRST_RUN_ORDER']
RED MAESTRO_SPLASH_FRAME_WAIT: шаг перед vkhod-117-splash — не extendedWaitUntil visible splash-overlay
mutant maestro-first-run-as-splash red= ['MAESTRO_SPLASH_FRAME_WAIT']
RED MAESTRO_SPLASH_FRAME_WAIT: шаг перед vkhod-117-splash — не extendedWaitUntil visible splash-overlay
mutant maestro-splash-overlay-gone-before-shot red= ['MAESTRO_SPLASH_FRAME_WAIT']
RED MAESTRO_SPLASH_FRAME_WAIT: шаг перед vkhod-117-splash — не extendedWaitUntil visible splash-overlay
RED MAESTRO_FIRST_RUN_ORDER: между vkhod-117-splash и vkhod-117-first-run нет notVisible splash-overlay
RED SPLASH_FRAME_SVERKA_123_DARK: манифест fixtures/workshop_project/mob_sverka_123/kadry_117.json строк темы 1 кадр Splash dark снимок vkhod-117-splash порог 0.6 снят сценарием False
RED SPLASH_FRAME_SVERKA_123_LIGHT: манифест fixtures/workshop_project/mob_sverka_123/kadry_117.json строк темы 1 кадр Splash light снимок vkhod-117-splash порог 0.6 снят сценарием False
mutant maestro-splash-shot-renamed red= ['MAESTRO_FIRST_RUN_ORDER', 'MAESTRO_SPLASH_FRAME_WAIT', 'SPLASH_FRAME_SVERKA_123_DARK', 'SPLASH_FRAME_SVERKA_123_LIGHT']
RED SVERKA_123_STEP_UNCONDITIONAL: шагов с .harness123/scripts/sverka_maketa.py 0 ключи шага None
RED SVERKA_123_MANIFEST_CANON: токены [] кадры в git []
RED SVERKA_123_HARNESS_PIN: checkout .harness123 0 шаг сверки [] checkout []
mutant sverka-step-absent red= ['SVERKA_123_HARNESS_PIN', 'SVERKA_123_MANIFEST_CANON', 'SVERKA_123_STEP_UNCONDITIONAL']
RED SVERKA_123_STEP_UNCONDITIONAL: шагов с .harness123/scripts/sverka_maketa.py 1 ключи шага ['continue-on-error', 'name', 'run', 'working-directory']
mutant sverka-continue-on-error red= ['SVERKA_123_STEP_UNCONDITIONAL']
RED SVERKA_123_STEP_UNCONDITIONAL: шагов с .harness123/scripts/sverka_maketa.py 1 ключи шага ['if', 'name', 'run', 'working-directory']
mutant sverka-if-conditional red= ['SVERKA_123_STEP_UNCONDITIONAL']
RED SVERKA_123_MANIFEST_CANON: токены ['python3', '.harness123/scripts/sverka_maketa.py', '--manifest', 'mobile/.maestro/compare-117.json', '--kadry', 'mobile/maestro-out-117', '--repo', '.'] кадры в git []
mutant sverka-local-manifest red= ['SVERKA_123_MANIFEST_CANON']
RED SVERKA_123_MANIFEST_CANON: токены ['python3', '.harness123/scripts/sverka_maketa.py', '--manifest', '.harness123/fixtures/workshop_project/mob_sverka_123/kadry_117.json', '--kadry', 'mobile/maestro-out', '--repo', '.'] кадры в git []
mutant sverka-kadry-other red= ['SVERKA_123_MANIFEST_CANON']
RED SVERKA_123_HARNESS_PIN: checkout .harness123 1 шаг сверки [12] checkout [11]
mutant sverka-ref-branch red= ['SVERKA_123_HARNESS_PIN']

rc=0
```

## Команда и сырой результат каждой собственной мутации

### old-admission-default

```text
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/Rattack_old-admission-default
failed 5 of 96

rc=1
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/Rattack_old-admission-default
static 43/43

rc=0
```

### old-gate-default

```text
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/Rattack_old-gate-default
failed 5 of 96

rc=1
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/Rattack_old-gate-default
static 43/43

rc=0
```

### old-w0-stale-admitted

```text
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/Rattack_old-w0-stale-admitted
failed 7 of 96

rc=1
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/Rattack_old-w0-stale-admitted
static 43/43

rc=0
```

### old-light-bypasses-admission-gate

```text
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/Rattack_old-light-bypasses-admission-gate
failed 27 of 96

rc=1
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/Rattack_old-light-bypasses-admission-gate
static 43/43

rc=0
```

### old-onboarding-restyles-f03

```text
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/Rattack_old-onboarding-restyles-f03
failed 54 of 96

rc=1
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/Rattack_old-onboarding-restyles-f03
static 43/43

rc=0
```

### new-light-gate-default

```text
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/Rattack_new-light-gate-default
failed 2 of 96

rc=1
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/Rattack_new-light-gate-default
static 43/43

rc=0
```

### new-light-stale-current

```text
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/Rattack_new-light-stale-current
failed 2 of 96

rc=1
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/Rattack_new-light-stale-current
static 43/43

rc=0
```

### new-empty-session-demo

```text
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/Rattack_new-empty-session-demo
failed 2 of 96

rc=1
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/Rattack_new-empty-session-demo
static 43/43

rc=0
```

### new-g0-denied-admission

```text
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/Rattack_new-g0-denied-admission
failed 40 of 96

rc=1
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/Rattack_new-g0-denied-admission
static 43/43

rc=0
```

### new-light-start-before-continue

```text
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/Rattack_new-light-start-before-continue
failed 2 of 96

rc=1
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/Rattack_new-light-start-before-continue
static 43/43

rc=0
```

### r3-extra-authenticated

```text
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/R_r3-extra-authenticated_vkhod_probe
behavioral 96/96

rc=0
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/R_r3-extra-authenticated_vkhod_static_probe
static 43/43

rc=0
```

### r3-gate-from-entry

```text
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/R_r3-gate-from-entry_vkhod_probe
behavioral 96/96

rc=0
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/R_r3-gate-from-entry_vkhod_static_probe
static 43/43

rc=0
```

### r3-admission-literal-completed

```text
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/R_r3-admission-literal-completed_vkhod_probe
behavioral 96/96

rc=0
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/R_r3-admission-literal-completed_vkhod_static_probe
static 43/43

rc=0
```

### r3-cached-admission

```text
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/R_r3-cached-admission_vkhod_probe
behavioral 96/96

rc=0
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/R_r3-cached-admission_vkhod_static_probe
static 43/43

rc=0
```

### r3-restart-completed-start

```text
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/R_r3-restart-completed-start_vkhod_probe
behavioral 96/96

rc=0
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/R_r3-restart-completed-start_vkhod_static_probe
static 43/43

rc=0
```

### r3-g0-theme-change

```text
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/R_r3-g0-theme-change_vkhod_probe
behavioral 96/96

rc=0
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/R_r3-g0-theme-change_vkhod_static_probe
static 43/43

rc=0
```

### r3-order-theme-autostart

```text
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/R_r3-order-theme-autostart_vkhod_probe
behavioral 96/96

rc=0
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/R_r3-order-theme-autostart_vkhod_static_probe
static 43/43

rc=0
```

### r3-g0-erstinformation

```text
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/R_r3-g0-erstinformation_vkhod_probe
behavioral 96/96

rc=0
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/R_r3-g0-erstinformation_vkhod_static_probe
static 43/43

rc=0
```

### r3-truthy-admission

```text
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/R_r3-truthy-admission_vkhod_probe
failed 12 of 96

rc=1
$ python3 /tmp/dev-harness-verify/Critic117v3c/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3c/R_r3-truthy-admission_vkhod_static_probe
static 43/43

rc=0
```

## Живые свидетели и честные контроли

`python3 /tmp/dev-harness-verify/Critic117v3c/witness.py`: настоящие RNTL-рендеры, press/rerender/remount. Свидетель утверждает НАЛИЧИЕ нарушения; rc0 свидетеля не означает допустимость поведения. В этих отдельных входах 96 штатных клеток skipped намеренно; полные 96/96 исполнены отдельно выше. Честный контроль использует ту же последовательность входов без мутации.

```text
$ python3 witness.py # r3-extra-authenticated-control
    r3-extra-authenticated-control: HONEST_CONTROL
Test Suites: 1 passed, 1 total
Tests:       96 skipped, 1 passed, 97 total
rc=0
```

```text
$ python3 witness.py # r3-extra-authenticated-witness
    r3-extra-authenticated-witness: BYPASS_OBSERVED
Test Suites: 1 passed, 1 total
Tests:       96 skipped, 1 passed, 97 total
rc=0
```

```text
$ python3 witness.py # r3-gate-from-entry-control
    r3-gate-from-entry-control: HONEST_CONTROL
Test Suites: 1 passed, 1 total
Tests:       96 skipped, 1 passed, 97 total
rc=0
```

```text
$ python3 witness.py # r3-gate-from-entry-witness
    r3-gate-from-entry-witness: BYPASS_OBSERVED
Test Suites: 1 passed, 1 total
Tests:       96 skipped, 1 passed, 97 total
rc=0
```

```text
$ python3 witness.py # r3-admission-literal-completed-control
    r3-admission-literal-completed-control: HONEST_CONTROL
Test Suites: 1 passed, 1 total
Tests:       96 skipped, 1 passed, 97 total
rc=0
```

```text
$ python3 witness.py # r3-admission-literal-completed-witness
    r3-admission-literal-completed-witness: BYPASS_OBSERVED
Test Suites: 1 passed, 1 total
Tests:       96 skipped, 1 passed, 97 total
rc=0
```

```text
$ python3 witness.py # r3-cached-admission-control
    r3-cached-admission-control: HONEST_CONTROL
Test Suites: 1 passed, 1 total
Tests:       96 skipped, 1 passed, 97 total
rc=0
```

```text
$ python3 witness.py # r3-cached-admission-witness
    r3-cached-admission-witness: BYPASS_OBSERVED
Test Suites: 1 passed, 1 total
Tests:       96 skipped, 1 passed, 97 total
rc=0
```

```text
$ python3 witness.py # r3-restart-completed-start-control
    r3-restart-completed-start-control: HONEST_CONTROL
Test Suites: 1 passed, 1 total
Tests:       96 skipped, 1 passed, 97 total
rc=0
```

```text
$ python3 witness.py # r3-restart-completed-start-witness
    r3-restart-completed-start-witness: BYPASS_OBSERVED
Test Suites: 1 passed, 1 total
Tests:       96 skipped, 1 passed, 97 total
rc=0
```

```text
$ python3 witness.py # r3-g0-theme-change-control
    r3-g0-theme-change-control: HONEST_CONTROL
Test Suites: 1 passed, 1 total
Tests:       96 skipped, 1 passed, 97 total
rc=0
```

```text
$ python3 witness.py # r3-g0-theme-change-witness
    r3-g0-theme-change-witness: BYPASS_OBSERVED
Test Suites: 1 passed, 1 total
Tests:       96 skipped, 1 passed, 97 total
rc=0
```

```text
$ python3 witness.py # r3-order-theme-autostart-control
    r3-order-theme-autostart-control: HONEST_CONTROL
Test Suites: 1 passed, 1 total
Tests:       96 skipped, 1 passed, 97 total
rc=0
```

```text
$ python3 witness.py # r3-order-theme-autostart-witness
    r3-order-theme-autostart-witness: BYPASS_OBSERVED
Test Suites: 1 passed, 1 total
Tests:       96 skipped, 1 passed, 97 total
rc=0
```

```text
$ python3 witness.py # r3-g0-erstinformation-control
    r3-g0-erstinformation-control: HONEST_CONTROL
Test Suites: 1 passed, 1 total
Tests:       96 skipped, 1 passed, 97 total
rc=0
```

```text
$ python3 witness.py # r3-g0-erstinformation-witness
    r3-g0-erstinformation-witness: BYPASS_OBSERVED
Test Suites: 1 passed, 1 total
Tests:       96 skipped, 1 passed, 97 total
rc=0
```

`python3 /tmp/dev-harness-verify/Critic117v3c/legacy_new.py`: каждый из семи блокирующих новых мутантов также проверен старыми потребителями.

```text
r3-extra-authenticated {'995': 0, '111': 0}
r3-gate-from-entry {'995': 0, '111': 0}
r3-admission-literal-completed {'995': 0, '111': 0}
r3-cached-admission {'995': 0, '111': 0}
r3-restart-completed-start {'995': 0, '111': 0}
r3-g0-theme-change {'995': 0, '111': 0}
r3-order-theme-autostart {'995': 0, '111': 0}
```

## Предел доказательства и доставка

Это суд критерия до заморозки, не ревью production118. Android/PNG/телефон, полный проектный CI, lint/typecheck не запускались; результаты им не приписываются. Допуск, переходы и корень проверены настоящим Jest/RNTL; происхождение сессии полного production118 и реальные кадры — его самостоятельная приёмка. Ни контракты, ни авторская батарея, ни чужие файлы не правились. Коммит/push запрещены адресным поручением и не выполнялись; единственный deliverable — этот файл, оркестратор отвечает за дальнейшее приземление. FAIL запрещает freeze117/3; четвёртый круг этим вердиктом не назначается.
