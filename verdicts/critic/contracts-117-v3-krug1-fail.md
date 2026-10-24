FAIL

OBJECT=dde2ac0cee94ac0c1bf04a8a788d13561b83dc5c

# Критик 117 v3 — один scoped-круг

Блокеров: **2**. Судится закоммиченная дельта `ba3c5fb3~1..dde2ac0c`, не прежние споры 117/2 и не реализация 118. Собственная копия H: `/tmp/dev-harness-verify/Critic117v3/repo`; R/Rattack/Rwitness — независимые disposable-копии B. На одном R прогоны последовательны. Контракт и батарея не исправлялись. Коммит/push не выполнялись: адресная инструкция этого круга требует только файл вердикта.

## Блокирующие находки

БЛОКИРУЕТ contracts/117-cmp-mob-vkhod-splash.md:135–145,324–335,436–438 — критерий допуска пропускает законные входы без admission/current. Новые четыре клетки проверяют только W0×current, W1A×null, W1A×stale, W1A×current и только dark. Отсутствующие поля admission/gate не проверяются; в предъявленной модели оба поля OPTIONAL (`fixtures/workshop_project/vkhod_117/model/bootstrap.pilot-app.tsx:48–51`), это не атака вне алфавита. Прежние 30 клеток не подают onboarding.

ОБХОД: в модели заменить `const onboardingAdmission = onboarding?.admission ?? 'W0';` на `const onboardingAdmission = onboarding?.admission ?? 'W1A';`. Внешняя сессия подаёт только `{gate:'current'}`: admission отсутствует, но First-Run → demo → Erstinformation → continue → Start разрешён литералом. Обе неизменённые пробы принимают дерево: **34/34 и 43/43, rc 0**; 995 **14/14**, 111 **23/23**, rc 0. Собственный живой RNTL-свидетель дошёл до Start и напечатал `BYPASS_OBSERVED: Start reached`. Аналогичный независимый обход — `onboarding?.gate ?? 'current'` при `{admission:'W1A'}`: Start без current из внешнего источника, те же зелёные пробы.

ОБХОД: для полностью заданных полей достаточно расширить условие маршрута на `|| (onboardingAdmission === 'W0' && onboardingGate === 'stale')` — W0×stale также достигает Start при **34/34 + 43/43**, rc 0. Ещё один конформный вариант — `|| (onboarding && scheme === 'light')`: в светлой теме W0×null достигает Start, обе пробы и старые 995/111 зелёные. Это четыре собственных мутанта допуска, не повтор четырёх стабов автора. Блокер не зависит от спора об отсутствующем поле.

Закрытие до freeze: добавить красные входы отсутствующего admission/current, непокрытых сочетаний и светлой темы на том же шве; каждый приведённый мутант обязан стать красным, честная модель — остаться зелёной. Источник admission из production-сессии остаётся обязанностью композиции 118; находка не предлагает второй gate и не снимает эту обязанность.

БЛОКИРУЕТ contracts/117-cmp-mob-vkhod-splash.md:141–145,324–335,436–438 — Г0 не проверяется при новом подключённом onboarding. Старые Г0 тестируют экземпляры без onboarding; MIGRACIYA_* наблюдают достижимость auth-code, но не фактическую поверхность его корня. Сохранение всех прежних клеток поимённо не доказывает сохранность Г0 на новом входе.

ОБХОД: только в корневом style pilot-app заменить ветвь `: styles.root` на `: [styles.root, onboarding ? { backgroundColor: '#000000', paddingTop: 0, paddingHorizontal: 0, paddingBottom: 0 } : null]`. Сессия `{admission:'W0',gate:'current'}` идёт прежним маршрутом в F03.02, но корень уже чёрный и с нулевыми отступами вместо #FFFFFF/48/16/16. Пробы всё равно **34/34 + 43/43, rc 0**; старые 995 **14/14**, 111 **23/23**, rc 0. Собственный RNTL-свидетель прошёл от First-Run через demo к auth-code, обнаружил изменённый стиль предка и напечатал `BYPASS_OBSERVED: F03 black root paddingTop=0`. Splash, иконка и файлы auth этим мутантом не меняются.

Закрытие до freeze: наблюдать Г0 F03.01/F03.02 на экземпляре с новым портом, включая недопуск, в обеих темах. Не снимать старую охрану и не переносить рестайл из 135 в миграцию 117.

## Пять вопросов и граница круга

1. **Критерий слабее предмета:** два воспроизведённых обхода выше. Дополнительный отрицательный контроль `start-before-continue` пойман: поведенческая проба rc 1, `failed 1 of 34`; порядок не объявляю сломанным без основания.
2. **Команды доказательства:** v3 называет обе исполняемые пробы, модель, матрицы, pre_critic, tag prerequisite и прежнюю продуктовую приёмку. Проблема в наблюдаемой неполноте новых входов, не в отсутствии команд. Старые визуальные споры не пересуждались.
3. **Решения исполнителя:** допуск W1A из внешней сессии, единственный gate 107, прежний путь без допуска и порядок continue названы. Production-композиция/полный CURRENT_CONFIRMED-снимок остаются инвариантом 5 frozen 118. Модель 117 не выдается за production-поставку 118.
4. **Границы и исполнители:** предмет, критерий и ЗОНА-строки на HEAD есть; `:506–517` передают миграцию pilot-app исполнителю 118 только после 117/3, а исполнителю 117 оставляют splash/тему/StatusBar. Неполного набора нет.
5. **Узость/норма:** owner-строка в теле `dde2ac0c` побайтово совпала с заданием. Поле ПРОВОДКА побайтово равно frozen 117/2. ПРЕДПОСЫЛКИ `:539–541` не добавляют secrets/settings, фиксируют существующий CI и зависимость. В дельте ровно четыре разрешённых пути. Старые assertions и объявления стабов сохранены. Нового рестайла или санкции менять production до freeze в тексте нет. Эти положительные результаты не устраняют два обхода батареи.

## Совместимость с 118 и 135

`contracts/118-erstinformation.md:15–16,39–43,49,66` прочитан вместе с вердиктом Rev118c. v3 называет тот же `frozen/contracts/117/3`, передачу pilot-app после тега, внешний admission и запрет ослабления 118. На честной модели W1A×current проходит последовательность до Start; это показывает возможность разрешённого перехода, **не** зелёный production-118/e2e и не предъявленный продуктовый `KOMPOZICIJA_W1A_NE_DOPUSHCHEN`. Проверка тега в копии H:

```text
$ git rev-parse --quiet --verify refs/tags/frozen/contracts/117/3
rc=1
```

Вывод пустой. Freeze этим кругом не делался; fetch/publish не выполнялись.

СОВЕТ contracts/117-cmp-mob-vkhod-splash.md:141–145,164–166,518–524 — учитывать существующую границу с 135 при сборке, не расширяя v3. `contracts/135-first-run-ekran.md:21,31,48,73,103` требует тёмный full-bleed внутри auth-слоя при сохранённом белом корне bootstrap. v3 разрешения менять Г0 не даёт; сохранённое требование 117 `auth C ≡ B` относится к поставке 117 и не является санкцией отменить отдельную auth-поставку 135. Известная коллизия стадий отмечена, но не превращена в новый блокер и не пересуждена.

## Инвентарь закоммиченной дельты

Команда: `python3 /tmp/dev-harness-verify/Critic117v3/inventory.py`. Полный сырой вывод — `inventory.log` рядом с драйвером. Первая попытка драйвера остановилась на вложенном AST-словаре статической матрицы (`StopIteration`); обход дерева исправлен на ast.walk. Это ошибка измерительного драйвера, не кандидата. Успешный сырой вывод:

```text
HEAD dde2ac0cee94ac0c1bf04a8a788d13561b83dc5c
owner line exact: True
PROVODKA frozen v2 byte equal: True
old behavior assertions byte equal: True
behavior cells 30 -> 34 removed= [] added= ['MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT', 'MIGRACIYA_W1A_CURRENT_MARSHRUT', 'MIGRACIYA_W1A_NULL_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_PREZHNIJ_PUT']
vkhod_probe.py stabs 31 -> 35 old declarations identical= True added= ['migracija-admission-literal', 'migracija-f03-put-udalen', 'migracija-gate-ignor', 'migracija-start-pryamo']
vkhod_static_probe.py stabs 38 -> 38 old declarations identical= True added= []
static probe byte equal: True
frozen barriers diff:

verify_antiplacebo scoped keys: NONE (no scripts/ barrier changed; 117 family uses its own --matrix)
rc=0
```

Статические клетки: **43 → 43**, не 38 → 43; 38 — число статических стабов. Число старых/новых поведенческих имён проверено разбором исходника, отдельно от прогона. Изменены только контракт, `model/bootstrap.pilot-app.tsx`, `vkhod.test.tsx`, `vkhod_probe.py`.

Дополнительный `git diff --exit-code ba3c5fb3~1 dde2ac0c -- scripts/ fixtures/workshop_project/start_108/ fixtures/workshop_project/first_run_111/ fixtures/workshop_project/pilot_995/ fixtures/workshop_project/erstinformation_118/ contracts/118-erstinformation.md contracts/135-first-run-ekran.md` → rc 0, пустой вывод. Затронутого ключа `verify_antiplacebo --scope` нет; полный anti-placebo не запускался.

## Приёмочные замеры на своей копии

Драйверы: `python3 /tmp/dev-harness-verify/Critic117v3/measure.py`, затем `python3 /tmp/dev-harness-verify/Critic117v3/behavior_runtime.py`. Команды внутри — штатные, без правок проб. H = `/tmp/dev-harness-verify/Critic117v3/repo`; семейство = `fixtures/workshop_project/vkhod_117/`. Каждый лог содержит команду, полный stdout/stderr и rc; все логи ниже лежат в `/tmp/dev-harness-verify/Critic117v3/`.

| Команда из H | Результат | Сырой лог |
|---|---|---|
| `bash scripts/check_precision_gate.sh "$H" contracts/117-cmp-mob-vkhod-splash.md` | rc 0, `OK` | precision.log |
| `bash scripts/pre_critic.sh contracts/117-cmp-mob-vkhod-splash.md` | rc 0, `PREDPOSYLKI_OK ... settings=2`, дверь зелёная | pre_critic.log |
| `python3 fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo ../R` | rc 1, `VKHOD_SPLASH_OVERLAY_ABSENT`, failed 23 of 34 | behavior_B.log |
| `python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo ../R` | rc 1, `VKHOD_SPLASH_COMPOSITE_ABSENT` | static_B.log |
| `python3 fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo ../Rwitness --model` | rc 0, behavioral 34/34 | behavior_node26_model.log |
| `python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo ../R --model` | rc 0, static 43/43 | static_model.log |
| `python3 fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo ../Rwitness --matrix` | rc 0, honest green 34; все 35 стабов красны на объявленных ветвях | behavior_node26_matrix.log |
| `python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo ../R --matrix` | rc 0; все 38 стабов красны на объявленных ветвях | static_matrix.log |

У этих проб флаг стабов называется `--matrix`, не `--stabs`. Обе полные матрицы исполнены. MUTANT_GREEN/NAMED_MISS/UNEXPECTED_RED в успешных матрицах нет.

### Условия runtime и неудачная первая попытка

Для shell-гейтов применён PATH с `/usr/bin:/bin` впереди, чтобы не использовать shim sed (грабля архитектора). В первом драйвере этот PATH ошибочно унаследовали и Jest-команды: вместо штатного станционного `/home/harness/.local/bin/node` **v26.5.1** выбрался `/usr/bin/node` **v22.22.0**. Наблюдённые результаты сохранены, не затёрты:

```text
behavior_model rc=1: failed 6 of 34
behavior_matrix rc=2: MUTATION_MATRIX_HONEST_NOT_GREEN
```

В словаре первой матрицы failed — `SPLASH_OVERLAY_TIMER_HIDE_DARK`, `SPLASH_OVERLAY_TIMER_HIDE_LIGHT` и четыре MIGRACIYA_*; остальные passed. Полные данные: `behavior_model.log`, `behavior_matrix.log`. После отделения shell-PATH от Jest на штатном Node26: модель 34/34 и матрица rc 0. Это ограничение воспроизведения, не третий scoped-блокер. Точную внутреннюю причину несовместимости Node22 не устанавливал. `.node-version` продукта — 24.21.0; на Node24 этот круг не прогонялся. Собственные мутанты, свидетели и legacy-прогоны ниже исполнялись на Node26.

### Сырой вывод двери и красного режима

```text
$ bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic117v3/repo contracts/117-cmp-mob-vkhod-splash.md
OK
rc=0

$ bash scripts/pre_critic.sh contracts/117-cmp-mob-vkhod-splash.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
КРИТИК: дверь зелёная
rc=0

VKHOD_SPLASH_OVERLAY_ABSENT
failed 23 of 34
rc=1

VKHOD_SPLASH_COMPOSITE_ABSENT
rc=1

behavioral 34/34
rc=0

static 43/43
rc=0
```

Отдельная команда `python3 /tmp/dev-harness-verify/Critic117v3/baseline_detail.py` раскрыла статусы каждой клетки, а не только итоговое число (`baseline_detail.log`): Г0–Г3 ×2 и три MIGRACIYA_*_PREZHNIJ_PUT — passed; 22 клетки splash/темы/статус-бара и MIGRACIYA_W1A_CURRENT_MARSHRUT — failed; `failed=23 total=34`. Это именно ожидаемый B, а не модель, случайно оставленная конкурентным прогоном.

### Сырые строки новых стабов автора

Команда: `python3 fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3/Rwitness --matrix`. Весь вывод 35 стабов — `behavior_node26_matrix.log`; здесь дословные строки дельты:

```text
honest green 34
mutant migracija-admission-literal red= ['MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT']
mutant migracija-gate-ignor red= ['MIGRACIYA_W1A_NULL_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_PREZHNIJ_PUT']
mutant migracija-start-pryamo red= ['MIGRACIYA_W1A_CURRENT_MARSHRUT']
mutant migracija-f03-put-udalen red= ['MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT', 'MIGRACIYA_W1A_CURRENT_MARSHRUT', 'MIGRACIYA_W1A_NULL_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_PREZHNIJ_PUT', 'RESTYLE_GUARD_995_F03_DARK', 'RESTYLE_GUARD_995_F03_LIGHT', 'RESTYLE_GUARD_995_RECOVERY_DARK', 'RESTYLE_GUARD_995_RECOVERY_LIGHT', 'RESTYLE_GUARD_995_UNAVAILABLE_DARK', 'RESTYLE_GUARD_995_UNAVAILABLE_LIGHT', 'RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT']
rc=0
```

Статическая матрица: `python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3/R --matrix` → rc 0. Полный сырой вывод с именем и red-набором каждого из 38 стабов — `static_matrix.log`; статическая семья в дельте не менялась.

## Собственные мутации: команды и сырой вывод каждой

Команда: `python3 /tmp/dev-harness-verify/Critic117v3/attack.py`. Драйвер ставит каждый изменённый model blob в **свой** Rattack, затем вызывает обе штатные пробы **без --model**. Полные stdout/stderr и rc каждой команды сохранены в `<имя>-vkhod_probe.log` и `<имя>-vkhod_static_probe.log`; изменённые TSX — `<имя>.tsx`. Путь всех файлов: `/tmp/dev-harness-verify/Critic117v3/`.

Внутренние команды для каждого мутанта:

```text
python3 /tmp/dev-harness-verify/Critic117v3/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3/Rattack
python3 /tmp/dev-harness-verify/Critic117v3/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3/Rattack
```

Сырой stdout драйвера (он печатает rc и последнюю строку каждой пробы):

```text
MUTATION admission-default
OLD: const onboardingAdmission = onboarding?.admission ?? 'W0';
NEW: const onboardingAdmission = onboarding?.admission ?? 'W1A';
vkhod_probe rc=0 behavioral 34/34
vkhod_static_probe rc=0 static 43/43

MUTATION gate-default
OLD: const onboardingGate = onboarding?.gate ?? 'null';
NEW: const onboardingGate = onboarding?.gate ?? 'current';
vkhod_probe rc=0 behavioral 34/34
vkhod_static_probe rc=0 static 43/43

MUTATION w0-stale-admitted
OLD: if (onboardingAdmission === 'W1A' && onboardingGate === 'current') {
NEW: if ((onboardingAdmission === 'W1A' && onboardingGate === 'current') || (onboardingAdmission === 'W0' && onboardingGate === 'stale')) {
vkhod_probe rc=0 behavioral 34/34
vkhod_static_probe rc=0 static 43/43

MUTATION light-bypasses-admission-gate
OLD: if (onboardingAdmission === 'W1A' && onboardingGate === 'current') {
NEW: if ((onboardingAdmission === 'W1A' && onboardingGate === 'current') || (onboarding && scheme === 'light')) {
vkhod_probe rc=0 behavioral 34/34
vkhod_static_probe rc=0 static 43/43

MUTATION onboarding-restyles-f03
OLD: : styles.root
      }
NEW: : [styles.root, onboarding ? { backgroundColor: '#000000', paddingTop: 0, paddingHorizontal: 0, paddingBottom: 0 } : null]
      }
vkhod_probe rc=0 behavioral 34/34
vkhod_static_probe rc=0 static 43/43

MUTATION start-before-continue
OLD:       setFrame('erstinformation');
      return;
NEW:       setFrame('start');
      return;
vkhod_probe rc=1 failed 1 of 34
vkhod_static_probe rc=0 static 43/43
```

Итого: четыре собственных мутанта допуска + отдельный мутант Г0 прошли обе пробы; отрицательный контроль обхода continue пойман. Предмет FAIL — новая миграционная охрана, а не исправление старых splash-клеток.

## Наблюдение самих нарушений

Команда: `python3 /tmp/dev-harness-verify/Critic117v3/witness.py`. Дополнительные одноразовые RNTL-входы, не изменения приёмочных клеток. Полный Jest-вывод в `<имя>-witness.log`.

```text
admission-default rc=0 {'CRITIC_WITNESS': 'passed'}
gate-default rc=0 {'CRITIC_WITNESS': 'passed'}
w0-stale-admitted rc=0 {'CRITIC_WITNESS': 'passed'}
light-bypasses-admission-gate rc=0 {'CRITIC_WITNESS': 'passed'}
onboarding-restyles-f03 rc=0 {'CRITIC_WITNESS': 'passed'}
```

В первых четырёх Jest stdout: `BYPASS_OBSERVED: Start reached`; в пятом: `BYPASS_OBSERVED: F03 black root paddingTop=0`. Свидетель зелёный потому, что **утверждает наличие нарушения**, а не потому, что нарушение допустимо. В этих пяти диагностических запусках штатные 34 теста намеренно skipped; отдельные полные 34/34 прогоны приведены выше.

Контроль на честной модели: `python3 /tmp/dev-harness-verify/Critic117v3/witness_control.py`, сырой лог `witness_control.log`:

```text
HONEST_CONTROL: admission absent -> auth-code, no Start
Test Suites: 1 passed, 1 total
Tests:       34 skipped, 1 passed, 35 total
rc=0
```

Честная модель на том же `{gate:'current'}` сохраняет прежний путь. В мутанте с литералом допуска наблюдается именно изменение поведения.

## Старые потребители

`python3 /tmp/dev-harness-verify/Critic117v3/regression.py`: модель 117 v3 → pilot.test.tsx (995), затем объединение модели FirstRun 111 v4 с **полной** поставкой 117 v3 → first_run_probe без --model. Полные логи `pilot995.log`, `first111.log`.

```text
pilot995 14 failed= 0 rc= 0
honest 23/23
rc=0
```

`python3 /tmp/dev-harness-verify/Critic117v3/legacy_attack.py` исполнил эти два потребителя на пяти пропущенных мутантах. Полные логи `<имя>-legacy.log`.

```text
admission-default 995 rc= 0 111 rc= 0
gate-default 995 rc= 0 111 rc= 0
w0-stale-admitted 995 rc= 0 111 rc= 0
light-bypasses-admission-gate 995 rc= 0 111 rc= 0
onboarding-restyles-f03 995 rc= 0 111 rc= 0
```

## Предел доказательства

Это суд текста и предъявленных красных проб, не product-done 118. Android/PNG на телефоне, lint/typecheck и полный проектный CI в этом круге не запускались. Отдельный runtime 108 не запускался, его исходники и frozen-барьеры неизменны. Все названные обходы воспроизведены исполнением RNTL, не выведены из одного чтения кода. Ни зелёные матрицы автора, ни прежние 995/111 не закрывают два новых наблюдаемых обхода; заморозка кандидата с текущей батареей не разрешена.
