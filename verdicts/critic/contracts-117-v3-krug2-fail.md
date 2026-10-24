FAIL
OBJECT=485b2c51c8529c02ca69495e6b2cb53567256c9b

# Критик 117 v3 — круг 2, финальный scoped-круг

Блокеров: **2**. Судится закоммиченная дельта `ba3c5fb3~1..485b2c51`, база текста — `frozen/contracts/117/2`. Предмет находится на HEAD собственной копии `/tmp/dev-harness-verify/Critic117v3b/repo`. Предмет, исполняемый критерий, именованные исполнители и зоны есть: неполного набора нет. Вердикт круга 1 прочитан целиком.

**Все пять предъявленных в круге 1 мутантов теперь красны.** Это закрытие конкретных прежних свидетелей, не доказательство полноты шва. Из **пяти новых** собственных мутаций **три остаются зелёными** на обеих неизменённых пробах. Они дают два блокера ниже, строго внутри разрешённых вопросов допуска/Г0. Старые споры 117/2, арбитражи, визуальная приёмка splash и закрытые части круга 1 не пересуждались.

## Блокирующие находки

БЛОКИРУЕТ contracts/117-cmp-mob-vkhod-splash.md:147–167,361–370,502–505 — обновлённый критерий по-прежнему не отличает допуск из внешнего входа от разрешения на непокрытых сочетаниях объявленной матрицы. Отсутствующий gate проверяется только в dark; пустой подключённый onboarding не проверяется.

ОБХОД: `new-light-gate-default` заменяет только `const onboardingGate = onboarding?.gate ?? 'null';` на `const onboardingGate = onboarding?.gate ?? (scheme === 'light' ? 'current' : 'null');`. При внешнем `{admission:'W1A'}` и light реальный RNTL-маршрут достигает Erstinformation и после continue — Start, хотя current снаружи НЕ получен. Неизменённые пробы принимают дерево: **behavioral 44/44, static 43/43, обе rc 0**. Потребители 995 **14/14**, 111 **23/23**, rc 0. Честная модель на том же входе оставляет auth-code и не даёт Start.

ОБХОД: `new-empty-session-demo` расширяет условие допуска на `|| (onboarding && onboarding.admission === undefined && onboarding.gate === undefined)`. Сессия подаёт законный пустой порт `{}`: ни admission, ни current нет, но demo → Erstinformation → continue → Start наблюдается. Обе полные пробы **44/44 + 43/43**, rc 0; 995/111 зелёные. Это соседний вход уже объявленных OPTIONAL-полей, не новый алфавит и не требование нового механизма авторизации.

Закрытие — красные наблюдения на этих входах до заморозки, при зелёной честной модели. Повторить тезис «полная матрица» в прозе недостаточно. Источник production admission и полный CURRENT_CONFIRMED остаются обязанностью 107/118, второй gate не требуется.

БЛОКИРУЕТ contracts/117-cmp-mob-vkhod-splash.md:147–175,371–374,502–505 — новые Г0-клетки наблюдают подключённый onboarding только при gate=current: W0/current и W1A/current. Корень при подключённом, но не допущенном gate остаётся ненаблюдаемым, хотя путь auth-code достижим.

ОБХОД: `new-g0-denied-admission` заменяет ветвь корня `: styles.root` на `: [styles.root, onboarding && onboardingGate !== 'current' ? { backgroundColor: '#000000', paddingTop: 0, paddingHorizontal: 0, paddingBottom: 0 } : null]`. На `{admission:'W1A',gate:'stale'}`, light сохраняется путь First-Run → F03.01 → demo → F03.02, но корень чёрный и paddingTop=0 вместо #FFFFFF/48 (horizontal/bottom также обнулены). Живой RNTL-свидетель наблюдает нарушенную поверхность после достижения auth-code. Обе неизменённые пробы принимают **44/44 + 43/43**, rc 0; 995/111 также зелёные. Честный контроль на том же входе имеет #FFFFFF/48. Это не рестайл auth-слоя 135: изменён именно корень bootstrap.

Закрытие — Г0 наблюдается на отвергнутом gate при подключённом порте, не только на отвергнутом admission с current. Старые клетки не снимать.

АРБИТР: arbiter — повтор причины FAIL: является ли выборка новых MIGRACIYA-клеток достаточным закрытием объявленной матрицы допуска и Г0 при показанных зелёных контрпримерах. Автор — сторона, не арбитр. Новый круг не запускаю: этот scoped-круг финальный по адресному поручению; дальнейшее действие определяет владелец. Арбитр назван здесь; фактический спавн не выполнялся (инструмента спавна в роли нет). Сообщение Main о найденных обходах инструментом write отклонено Н-85/null-allowlist; окончательный канал — этот файл и terminal yield.

## Пять обязательных вопросов

1. **Критерий слабее предмета:** два конкретных воспроизведённых обхода выше. Прежние пять свидетелей пойманы; новые green не замалчиваются.
2. **Доказуемость командами:** обе пробы, модели, матрицы, pre_critic и старые потребители исполнены; проблема не в отсутствии команд, а в отсутствии наблюдений на законных входах.
3. **Оставленные исполнителю решения:** узкая санкция на путь, внешний admission, единственный gate 107/118, порядок continue и сохранение пути B названы. Новых блокеров по конструкции/составу экранов 118 не вводится.
4. **Границы:** `:563–584` называют architect/critic/adversary/reviewer/implementer и передачу pilot-app исполнителю 118 только после тега. Для 117 остаются splash/тема/StatusBar; чужие семьи read-only. Санкции менять production до freeze нет.
5. **Узость/норма:** четыре изменённых пути, owner-строки и ПРОВОДКА проверены независимо. Числа 44/43/38 и красные 24/44 совпали с измерениями. Исторические 26/30/34/35 атрибутированы; их наличие не выдаётся за рассинхрон. Прежние вопросы нормы вне адресного scope не пересуждались.

## Узость и совместимость

- `dde2ac0c` и `485b2c51`: РАЗРЕШИЛ-ВЛАДЕЛЕЦ в теле побайтово совпадает с заданием. `e840be06` контракт не меняет, owner-строка для него по условию задания не требуется.
- ПРОВОДКА равна frozen 117/2 дословно. В дельте только контракт и три файла семьи vkhod_117; модель production не поставляется этим контрактным кандидатом.
- Имена frozen 117/2: поведенческие **26 → 44**, removed=[]; статические **40 → 43**, removed=[]. На базе перед v3 поведенческие **30 → 44**; после первого кандидата **34 → 44** (+10). Пред-v3 assertions сохранены побайтово; старые мутационные преобразования сохранены, расширены named/depends там, где новые клетки наблюдают тот же дефект.
- `git diff --exit-code ba3c5fb3~1 HEAD -- scripts/ fixtures/workshop_project/start_108/ fixtures/workshop_project/first_run_111/ fixtures/workshop_project/pilot_995/ fixtures/workshop_project/erstinformation_118/ fixtures/workshop_project/first_run_ekran_135/ contracts/118-erstinformation.md contracts/135-first-run-ekran.md`: **rc 0, пусто**. Изменённых scripts-барьеров нет, отдельного затронутого ключа verify_antiplacebo нет; полный anti-placebo не запускался.
- 118 `:15–16,39–43,49,66`: тот же prerequisite `frozen/contracts/117/3`, команда `git fetch origin --tags && git rev-parse --quiet --verify refs/tags/frozen/contracts/117/3`; зона bootstrap выдаётся только после тега. В своей копии `git rev-parse --quiet --verify refs/tags/frozen/contracts/117/3` → **rc 1, пусто**. Fetch/publish/freeze не выполнялись. Портовая модель 117 не выдаётся за production-композицию/e2e 118.

СОВЕТ contracts/117-cmp-mob-vkhod-splash.md:189–200,572–588 — сохранить при сборке существующую демаркацию с `contracts/135-first-run-ekran.md:21,31,48,73`: тёмный full-bleed 135 внутри auth-слоя, белый Г0 — корень bootstrap. V3 не разрешает перенос тёмной поверхности в корень. Проверка `auth C ≡ B` относится к поставке 117, не отменяет отдельную поставку auth 135. Новая текстовая коллизия дельтой не внесена; реальное совмещение пикселей на устройстве этим кругом не проверялось.

## Условия исполнения и результат

Все записи — только `/tmp/dev-harness-verify/Critic117v3b/`. H клонирован из предъявленного репозитория; каждый R извлечён `git archive 8748a7a3352c14a6caa5a75b71f869e5d3b8152c` из read-only локального репозитория продукта. Rbehavior, Rstatic, Rattack, Rregression, Rwitness независимы; на каждом R одновременно один замер. node_modules — симлинк существующей инфраструктуры. TMPDIR внутри своей области. Node — штатный shell PATH (v26.5.1), не системный Node22. Только shell-гейты получают `/usr/bin:/bin` перед PATH из-за известного shim sed; Jest/генераторы сохраняют штатный PATH.

Честная модель: behavioral **44/44**, static **43/43**, rc 0. B: **failed 24 of 44**, rc 1 и `VKHOD_SPLASH_OVERLAY_ABSENT`; статическая B rc 1 `VKHOD_SPLASH_COMPOSITE_ABSENT`. B дополнительно измерена прямым Jest-отчётом: 24 failed / 44 total (не повтор итогового счётчика пробы). Количество клеток и стабов независимо получено разбором TSX/Python AST: 44 поведенческих, 43 статических, 43/38 стабов. Матрицы обе rc 0; все авторские стабы красны на объявленных ветвях. Флаг этой семьи — `--matrix`, не `--stabs`.

Регрессии честной полной модели 117: 995 **14/14**, rc 0; 111 **23/23**, rc 0 на объединении модели FirstRun 111 и полной поставки 117. Те же потребители дополнительно зелёные на каждом из трёх пропущенных новых мутантов.

| Мутант | behavioral | static | Итог |
|---|---:|---:|---|
| old-admission-default | rc1, 1/44 red | rc0, 43/43 | красный |
| old-gate-default | rc1, 1/44 red | rc0, 43/43 | красный |
| old-w0-stale-admitted | rc1, 1/44 red | rc0, 43/43 | красный |
| old-light-bypasses-admission-gate | rc1, 3/44 red | rc0, 43/43 | красный |
| old-onboarding-restyles-f03 | rc1, 4/44 red | rc0, 43/43 | красный |
| new-light-gate-default | rc0, 44/44 | rc0, 43/43 | **зелёный — обход** |
| new-light-stale-current | rc1, 1/44 red | rc0, 43/43 | красный |
| new-empty-session-demo | rc0, 44/44 | rc0, 43/43 | **зелёный — обход** |
| new-g0-denied-admission | rc0, 44/44 | rc0, 43/43 | **зелёный — обход** |
| new-light-start-before-continue | rc1, 1/44 red | rc0, 43/43 | красный |

Старые мутанты — дословные файлы из `/tmp/dev-harness-verify/Critic117v3/`, установленные поверх полной модели в СВОЁМ Rattack. Новые пять — собственные преобразования, код `attack.py`, результирующие `<имя>.tsx` рядом. Каждая штатная проба запускается без --model: модель/мутант устанавливает контекстный драйвер и затем восстанавливает дерево.

Живые свидетельства `witness.py` исполняют дополнительный одноразовый RNTL-вход и утверждают именно НАЛИЧИЕ нарушения; их rc0 не значит допустимость поведения. Честные контроли на тех же входах также rc0, но утверждают auth-code/отсутствие Start и белый корень. В свидетельствах 44 штатных теста skipped намеренно; полные 44/44 — отдельные прогоны ниже.

## Сырой вывод замеров

Команды-драйверы: `python3 /tmp/dev-harness-verify/Critic117v3b/{measure,inventory,static_compare,regression,attack,witness,legacy_attack}.py` (каждый запускался отдельно). Ниже дословное содержимое логов с командами/rc, без пересказа статусов.

### inventory

```text
HEAD 485b2c51c8529c02ca69495e6b2cb53567256c9b
delta paths:
contracts/117-cmp-mob-vkhod-splash.md
fixtures/workshop_project/vkhod_117/model/bootstrap.pilot-app.tsx
fixtures/workshop_project/vkhod_117/vkhod.test.tsx
fixtures/workshop_project/vkhod_117/vkhod_probe.py

dde2ac0c contract_changed= True owner_line_exact= True
e840be06 contract_changed= False owner_line_exact= False
485b2c51 contract_changed= True owner_line_exact= True
PROVODKA frozen v2 byte equal True
behavior frozen/contracts/117/2 26 -> 44 removed= [] added= ['MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT', 'MIGRACIYA_G0_F03_DOPUSK_DARK', 'MIGRACIYA_G0_F03_DOPUSK_LIGHT', 'MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT', 'MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT', 'MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT', 'MIGRACIYA_W0_STALE_PREZHNIJ_PUT', 'MIGRACIYA_W1A_CURRENT_MARSHRUT', 'MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT', 'MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT', 'MIGRACIYA_W1A_NULL_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT', 'SPLASH_OVERLAY_GEOMETRY_DARK', 'SPLASH_OVERLAY_GEOMETRY_LIGHT', 'SPLASH_OVERLAY_ZORDER_DARK', 'SPLASH_OVERLAY_ZORDER_LIGHT']
behavior ba3c5fb3~1 30 -> 44 removed= [] added= ['MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT', 'MIGRACIYA_G0_F03_DOPUSK_DARK', 'MIGRACIYA_G0_F03_DOPUSK_LIGHT', 'MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT', 'MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT', 'MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT', 'MIGRACIYA_W0_STALE_PREZHNIJ_PUT', 'MIGRACIYA_W1A_CURRENT_MARSHRUT', 'MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT', 'MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT', 'MIGRACIYA_W1A_NULL_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT']
all pre-v3 behavior assertion bytes retained= True
behavior dde2ac0c 34 -> 44 removed= [] added= ['MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT', 'MIGRACIYA_G0_F03_DOPUSK_DARK', 'MIGRACIYA_G0_F03_DOPUSK_LIGHT', 'MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT', 'MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT', 'MIGRACIYA_W0_STALE_PREZHNIJ_PUT', 'MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT', 'MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT']
vkhod_probe.py stabs 31 -> 43 old mutations identical= True removed= []
vkhod_static_probe.py stabs 38 -> 38 old mutations identical= True removed= []
static probe byte identical pre-v3= True
static cells source inventory= 43
static names= ['ADAPTIVE_BG_SOLID', 'ADAPTIVE_FG_RASTER', 'ADAPTIVE_MONO_RASTER', 'APP_ICON_DERIVATIVES', 'FAVICON_RASTER_WHOLE', 'ICON_ADAPTIVE_BG_DARK', 'ICON_NOT_TEMPLATE_BYTES', 'ICON_PIXELS_MARK', 'ICON_RASTER_WHOLE', 'IOS_ICON_NOT_TEMPLATE', 'MAESTRO_FIRST_RUN_ORDER', 'MAESTRO_SPLASH_FRAME_WAIT', 'SPLASH_BLOCKS_DARK_LIGHT', 'SPLASH_COMPOSITE_ETALON_DARK', 'SPLASH_COMPOSITE_ETALON_LIGHT', 'SPLASH_EFFECTIVE_DARK_LIGHT', 'SPLASH_EFFECTIVE_IOS_DARK', 'SPLASH_EFFECTIVE_IOS_LIGHT', 'SPLASH_FRAME_SVERKA_123_DARK', 'SPLASH_FRAME_SVERKA_123_LIGHT', 'SPLASH_IOS_STORYBOARD', 'SPLASH_NATIVE_GENERATED', 'SPLASH_NATIVE_GENERATED_DARK_HDPI', 'SPLASH_NATIVE_GENERATED_DARK_MDPI', 'SPLASH_NATIVE_GENERATED_DARK_XHDPI', 'SPLASH_NATIVE_GENERATED_DARK_XXHDPI', 'SPLASH_NATIVE_GENERATED_DARK_XXXHDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_HDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_MDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_XHDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_XXHDPI', 'SPLASH_NATIVE_GENERATED_LIGHT_XXXHDPI', 'SPLASH_OVERLAY_CONSUMES_COMPOSITE', 'SPLASH_OVERLAY_NO_LAYOUT_OFFSET', 'SPLASH_OVERLAY_NO_TRANSFORM', 'SPLASH_OVERLAY_ZORDER', 'SPLASH_SIGN_RASTER_DARK', 'SPLASH_SIGN_RASTER_LIGHT', 'STATIC_ORACLE_LITERALS', 'SVERKA_123_HARNESS_PIN', 'SVERKA_123_MANIFEST_CANON', 'SVERKA_123_STEP_UNCONDITIONAL', 'USER_STYLE_AUTOMATIC']
frozen/118/135 delta rc= 0 output= ''
tag117/3 rc= 1 output= ''
```

### static_compare

```text
static frozen117/2=40 current=43 removed=[] added=['SPLASH_OVERLAY_NO_LAYOUT_OFFSET', 'SPLASH_OVERLAY_NO_TRANSFORM', 'SPLASH_OVERLAY_ZORDER']
```

### precision

```text
$ bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic117v3b/repo contracts/117-cmp-mob-vkhod-splash.md
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
$ python3 fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rbehavior
case RESTYLE_GUARD_995_F03_DARK
case RESTYLE_GUARD_995_F03_LIGHT
case RESTYLE_GUARD_995_WELCOME_DARK
case RESTYLE_GUARD_995_WELCOME_LIGHT
case RESTYLE_GUARD_995_RECOVERY_DARK
case RESTYLE_GUARD_995_RECOVERY_LIGHT
case RESTYLE_GUARD_995_UNAVAILABLE_DARK
case RESTYLE_GUARD_995_UNAVAILABLE_LIGHT
case PROD_ENTRY_OS_THEME_DARK
case PROD_ENTRY_OS_THEME_LIGHT
case STATUS_BAR_STYLE_DARK
case STATUS_BAR_STYLE_LIGHT
case SPLASH_OVERLAY_CONTAIN_DARK
case SPLASH_OVERLAY_CONTAIN_LIGHT
case SPLASH_OVERLAY_GEOMETRY_DARK
case SPLASH_OVERLAY_GEOMETRY_LIGHT
case SPLASH_OVERLAY_ZORDER_DARK
case SPLASH_OVERLAY_ZORDER_LIGHT
case SPLASH_OVERLAY_MOUNTED_DARK
case SPLASH_OVERLAY_MOUNTED_LIGHT
case SPLASH_OVERLAY_COMPOSITE_DARK
case SPLASH_OVERLAY_COMPOSITE_LIGHT
case SPLASH_OVERLAY_VISIBLE_DARK
case SPLASH_OVERLAY_VISIBLE_LIGHT
case SPLASH_OVERLAY_NO_TEXT_DARK
case SPLASH_OVERLAY_NO_TEXT_LIGHT
case SPLASH_HIDEASYNC_ORDER_DARK
case SPLASH_HIDEASYNC_ORDER_LIGHT
case SPLASH_OVERLAY_TIMER_HIDE_DARK
case SPLASH_OVERLAY_TIMER_HIDE_LIGHT
case MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT
case MIGRACIYA_W1A_NULL_PREZHNIJ_PUT
case MIGRACIYA_W1A_STALE_PREZHNIJ_PUT
case MIGRACIYA_W1A_CURRENT_MARSHRUT
case MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT
case MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT
case MIGRACIYA_W0_STALE_PREZHNIJ_PUT
case MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT
case MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT
case MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT
case MIGRACIYA_G0_F03_ONBOARDING_DARK
case MIGRACIYA_G0_F03_ONBOARDING_LIGHT
case MIGRACIYA_G0_F03_DOPUSK_DARK
case MIGRACIYA_G0_F03_DOPUSK_LIGHT
VKHOD_SPLASH_OVERLAY_ABSENT
failed 24 of 44

rc=1
```

### static_B

```text
$ python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rstatic
VKHOD_SPLASH_COMPOSITE_ABSENT

rc=1
```

### behavior_model

```text
$ python3 fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rbehavior --model
case RESTYLE_GUARD_995_F03_DARK
case RESTYLE_GUARD_995_F03_LIGHT
case RESTYLE_GUARD_995_WELCOME_DARK
case RESTYLE_GUARD_995_WELCOME_LIGHT
case RESTYLE_GUARD_995_RECOVERY_DARK
case RESTYLE_GUARD_995_RECOVERY_LIGHT
case RESTYLE_GUARD_995_UNAVAILABLE_DARK
case RESTYLE_GUARD_995_UNAVAILABLE_LIGHT
case PROD_ENTRY_OS_THEME_DARK
case PROD_ENTRY_OS_THEME_LIGHT
case STATUS_BAR_STYLE_DARK
case STATUS_BAR_STYLE_LIGHT
case SPLASH_OVERLAY_CONTAIN_DARK
case SPLASH_OVERLAY_CONTAIN_LIGHT
case SPLASH_OVERLAY_GEOMETRY_DARK
case SPLASH_OVERLAY_GEOMETRY_LIGHT
case SPLASH_OVERLAY_ZORDER_DARK
case SPLASH_OVERLAY_ZORDER_LIGHT
case SPLASH_OVERLAY_MOUNTED_DARK
case SPLASH_OVERLAY_MOUNTED_LIGHT
case SPLASH_OVERLAY_COMPOSITE_DARK
case SPLASH_OVERLAY_COMPOSITE_LIGHT
case SPLASH_OVERLAY_VISIBLE_DARK
case SPLASH_OVERLAY_VISIBLE_LIGHT
case SPLASH_OVERLAY_NO_TEXT_DARK
case SPLASH_OVERLAY_NO_TEXT_LIGHT
case SPLASH_HIDEASYNC_ORDER_DARK
case SPLASH_HIDEASYNC_ORDER_LIGHT
case SPLASH_OVERLAY_TIMER_HIDE_DARK
case SPLASH_OVERLAY_TIMER_HIDE_LIGHT
case MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT
case MIGRACIYA_W1A_NULL_PREZHNIJ_PUT
case MIGRACIYA_W1A_STALE_PREZHNIJ_PUT
case MIGRACIYA_W1A_CURRENT_MARSHRUT
case MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT
case MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT
case MIGRACIYA_W0_STALE_PREZHNIJ_PUT
case MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT
case MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT
case MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT
case MIGRACIYA_G0_F03_ONBOARDING_DARK
case MIGRACIYA_G0_F03_ONBOARDING_LIGHT
case MIGRACIYA_G0_F03_DOPUSK_DARK
case MIGRACIYA_G0_F03_DOPUSK_LIGHT
behavioral 44/44

rc=0
```

### static_model

```text
$ python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rstatic --model
case APP_ICON_DERIVATIVES
case ICON_NOT_TEMPLATE_BYTES
case ICON_ADAPTIVE_BG_DARK
case ICON_PIXELS_MARK
case SPLASH_BLOCKS_DARK_LIGHT
case SPLASH_EFFECTIVE_DARK_LIGHT
case SPLASH_NATIVE_GENERATED_LIGHT_MDPI
case SPLASH_NATIVE_GENERATED_DARK_MDPI
case SPLASH_NATIVE_GENERATED_LIGHT_HDPI
case SPLASH_NATIVE_GENERATED_DARK_HDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XHDPI
case SPLASH_NATIVE_GENERATED_DARK_XHDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XXHDPI
case SPLASH_NATIVE_GENERATED_DARK_XXHDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XXXHDPI
case SPLASH_NATIVE_GENERATED_DARK_XXXHDPI
case SPLASH_NATIVE_GENERATED
case SPLASH_EFFECTIVE_IOS_LIGHT
case SPLASH_EFFECTIVE_IOS_DARK
case SPLASH_IOS_STORYBOARD
case SPLASH_COMPOSITE_ETALON_DARK
case SPLASH_SIGN_RASTER_DARK
case SPLASH_COMPOSITE_ETALON_LIGHT
case SPLASH_SIGN_RASTER_LIGHT
case SPLASH_OVERLAY_CONSUMES_COMPOSITE
case SPLASH_OVERLAY_NO_TRANSFORM
case SPLASH_OVERLAY_NO_LAYOUT_OFFSET
case SPLASH_OVERLAY_ZORDER
case USER_STYLE_AUTOMATIC
case STATIC_ORACLE_LITERALS
case ICON_RASTER_WHOLE
case ADAPTIVE_FG_RASTER
case ADAPTIVE_MONO_RASTER
case ADAPTIVE_BG_SOLID
case FAVICON_RASTER_WHOLE
case IOS_ICON_NOT_TEMPLATE
case MAESTRO_SPLASH_FRAME_WAIT
case MAESTRO_FIRST_RUN_ORDER
case SPLASH_FRAME_SVERKA_123_DARK
case SPLASH_FRAME_SVERKA_123_LIGHT
case SVERKA_123_STEP_UNCONDITIONAL
case SVERKA_123_MANIFEST_CANON
case SVERKA_123_HARNESS_PIN
static 43/43

rc=0
```

### behavior_matrix

```text
$ python3 fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rbehavior --matrix
honest green 44
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
mutant auth-restyled-ground red= ['MIGRACIYA_G0_F03_DOPUSK_DARK', 'MIGRACIYA_G0_F03_DOPUSK_LIGHT', 'MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT', 'RESTYLE_GUARD_995_F03_DARK', 'RESTYLE_GUARD_995_F03_LIGHT']
mutant auth-restyled-code-light red= ['MIGRACIYA_G0_F03_ONBOARDING_LIGHT', 'RESTYLE_GUARD_995_F03_LIGHT']
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
mutant migracija-admission-literal red= ['MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT', 'MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT', 'MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT']
mutant migracija-gate-ignor red= ['MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT', 'MIGRACIYA_W1A_NULL_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT']
mutant migracija-start-pryamo red= ['MIGRACIYA_W1A_CURRENT_MARSHRUT', 'MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT']
mutant migracija-f03-put-udalen red= ['MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT', 'MIGRACIYA_G0_F03_DOPUSK_DARK', 'MIGRACIYA_G0_F03_DOPUSK_LIGHT', 'MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT', 'MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT', 'MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT', 'MIGRACIYA_W0_STALE_PREZHNIJ_PUT', 'MIGRACIYA_W1A_CURRENT_MARSHRUT', 'MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT', 'MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT', 'MIGRACIYA_W1A_NULL_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT', 'RESTYLE_GUARD_995_F03_DARK', 'RESTYLE_GUARD_995_F03_LIGHT', 'RESTYLE_GUARD_995_RECOVERY_DARK', 'RESTYLE_GUARD_995_RECOVERY_LIGHT', 'RESTYLE_GUARD_995_UNAVAILABLE_DARK', 'RESTYLE_GUARD_995_UNAVAILABLE_LIGHT', 'RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT']
mutant migracija-admission-default red= ['MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT']
mutant migracija-gate-default red= ['MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT']
mutant migracija-w0-stale-dopushchen red= ['MIGRACIYA_W0_STALE_PREZHNIJ_PUT']
mutant migracija-svetlui-obhod red= ['MIGRACIYA_G0_F03_ONBOARDING_LIGHT', 'MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT']
mutant migracija-onboarding-restyles-f03 red= ['MIGRACIYA_G0_F03_DOPUSK_DARK', 'MIGRACIYA_G0_F03_DOPUSK_LIGHT', 'MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT']
mutant migracija-marshrut-tolko-temnyi red= ['MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT']
mutant migracija-stale-kak-current red= ['MIGRACIYA_W1A_STALE_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT']
mutant migracija-restyle-pri-dopuske red= ['MIGRACIYA_G0_F03_DOPUSK_DARK', 'MIGRACIYA_G0_F03_DOPUSK_LIGHT']

rc=0
```

### static_matrix

```text
$ python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rstatic --matrix
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
RED SPLASH_OVERLAY_CONSUMES_COMPOSITE: ['/tmp/dev-harness-verify/Critic117v3b/Rstatic/mobile/assets/images/splash-composite-dark.png', '/tmp/dev-harness-verify/Critic117v3b/Rstatic/mobile/assets/images/splash-composite-light.png']
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

### pilot995

```text
PASS src/bootstrap/__tests__/pilot.test.tsx
  995 pilot
    ✓ DIRECT_unknown (190 ms)
    ✓ DIRECT_incomplete (10 ms)
    ✓ INVALID_CODE (10 ms)
    ✓ RESEND_UNCONFIRMED (145 ms)
    ✓ RESEND_CONFIRMED (11 ms)
    ✓ RESEND_COOLDOWN (8 ms)
    ✓ EMAIL_STALE (148 ms)
    ✓ RECOVERY_A07 (10 ms)
    ✓ AUTH_stale (10 ms)
    ✓ AUTH_revoked (9 ms)
    ✓ AUTH_missing_scope (9 ms)
    ✓ SECRET (8 ms)
    ✓ REPLAY (13 ms)
    ✓ DEFAULT_OFFLINE (17 ms)

Test Suites: 1 passed, 1 total
Tests:       14 passed, 14 total
Snapshots:   0 total
Time:        2.119 s
Ran all test suites within paths "/tmp/dev-harness-verify/Critic117v3b/Rregression/mobile/src/bootstrap/__tests__/pilot.test.tsx".
Test results written to: ../../tmp/tmpiuwwjyh4.json

rc=0
```

### first111

```text
$ python3 /tmp/dev-harness-verify/Critic117v3b/repo/fixtures/workshop_project/first_run_111/first_run_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rregression
case CTA_OPENS_F03_01_DARK
case CTA_OPENS_F03_01_LIGHT
case CTA_TEXT_EQUALS_FRAME_TITLE
case DEMO_BADGE_INSET_DARK
case DEMO_BADGE_INSET_LIGHT
case FIRST_RUN_COPY_CLOSED_DARK
case FIRST_RUN_COPY_CLOSED_LIGHT
case FIRST_RUN_GROUND_FULL_SURFACE_DARK
case FIRST_RUN_GROUND_FULL_SURFACE_LIGHT
case FIRST_RUN_STRUCTURE_DARK
case FIRST_RUN_STRUCTURE_LIGHT
case RESTYLE_GUARD_995_F03_01_DARK
case RESTYLE_GUARD_995_F03_01_LIGHT
case RESTYLE_GUARD_995_RECOVERY_DARK
case RESTYLE_GUARD_995_RECOVERY_LIGHT
case RESTYLE_GUARD_995_UNAVAILABLE_DARK
case RESTYLE_GUARD_995_UNAVAILABLE_LIGHT
case RESTYLE_GUARD_995_WELCOME_DARK
case RESTYLE_GUARD_995_WELCOME_LIGHT
case SAFEAREA_EDGES_ACTIVE_DARK
case SAFEAREA_EDGES_ACTIVE_LIGHT
case WORDMARK_SOURCE_BOUND_DARK
case WORDMARK_SOURCE_BOUND_LIGHT
honest 23/23

rc=0
```

## Сырой вывод каждой собственной мутации

### old-admission-default

```text
$ python3 /tmp/dev-harness-verify/Critic117v3b/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rattack
case RESTYLE_GUARD_995_F03_DARK
case RESTYLE_GUARD_995_F03_LIGHT
case RESTYLE_GUARD_995_WELCOME_DARK
case RESTYLE_GUARD_995_WELCOME_LIGHT
case RESTYLE_GUARD_995_RECOVERY_DARK
case RESTYLE_GUARD_995_RECOVERY_LIGHT
case RESTYLE_GUARD_995_UNAVAILABLE_DARK
case RESTYLE_GUARD_995_UNAVAILABLE_LIGHT
case PROD_ENTRY_OS_THEME_DARK
case PROD_ENTRY_OS_THEME_LIGHT
case STATUS_BAR_STYLE_DARK
case STATUS_BAR_STYLE_LIGHT
case SPLASH_OVERLAY_CONTAIN_DARK
case SPLASH_OVERLAY_CONTAIN_LIGHT
case SPLASH_OVERLAY_GEOMETRY_DARK
case SPLASH_OVERLAY_GEOMETRY_LIGHT
case SPLASH_OVERLAY_ZORDER_DARK
case SPLASH_OVERLAY_ZORDER_LIGHT
case SPLASH_OVERLAY_MOUNTED_DARK
case SPLASH_OVERLAY_MOUNTED_LIGHT
case SPLASH_OVERLAY_COMPOSITE_DARK
case SPLASH_OVERLAY_COMPOSITE_LIGHT
case SPLASH_OVERLAY_VISIBLE_DARK
case SPLASH_OVERLAY_VISIBLE_LIGHT
case SPLASH_OVERLAY_NO_TEXT_DARK
case SPLASH_OVERLAY_NO_TEXT_LIGHT
case SPLASH_HIDEASYNC_ORDER_DARK
case SPLASH_HIDEASYNC_ORDER_LIGHT
case SPLASH_OVERLAY_TIMER_HIDE_DARK
case SPLASH_OVERLAY_TIMER_HIDE_LIGHT
case MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT
case MIGRACIYA_W1A_NULL_PREZHNIJ_PUT
case MIGRACIYA_W1A_STALE_PREZHNIJ_PUT
case MIGRACIYA_W1A_CURRENT_MARSHRUT
case MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT
case MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT
case MIGRACIYA_W0_STALE_PREZHNIJ_PUT
case MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT
case MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT
case MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT
case MIGRACIYA_G0_F03_ONBOARDING_DARK
case MIGRACIYA_G0_F03_ONBOARDING_LIGHT
case MIGRACIYA_G0_F03_DOPUSK_DARK
case MIGRACIYA_G0_F03_DOPUSK_LIGHT
failed 1 of 44

rc=1
```

```text
$ python3 /tmp/dev-harness-verify/Critic117v3b/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rattack
case APP_ICON_DERIVATIVES
case ICON_NOT_TEMPLATE_BYTES
case ICON_ADAPTIVE_BG_DARK
case ICON_PIXELS_MARK
case SPLASH_BLOCKS_DARK_LIGHT
case SPLASH_EFFECTIVE_DARK_LIGHT
case SPLASH_NATIVE_GENERATED_LIGHT_MDPI
case SPLASH_NATIVE_GENERATED_DARK_MDPI
case SPLASH_NATIVE_GENERATED_LIGHT_HDPI
case SPLASH_NATIVE_GENERATED_DARK_HDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XHDPI
case SPLASH_NATIVE_GENERATED_DARK_XHDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XXHDPI
case SPLASH_NATIVE_GENERATED_DARK_XXHDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XXXHDPI
case SPLASH_NATIVE_GENERATED_DARK_XXXHDPI
case SPLASH_NATIVE_GENERATED
case SPLASH_EFFECTIVE_IOS_LIGHT
case SPLASH_EFFECTIVE_IOS_DARK
case SPLASH_IOS_STORYBOARD
case SPLASH_COMPOSITE_ETALON_DARK
case SPLASH_SIGN_RASTER_DARK
case SPLASH_COMPOSITE_ETALON_LIGHT
case SPLASH_SIGN_RASTER_LIGHT
case SPLASH_OVERLAY_CONSUMES_COMPOSITE
case SPLASH_OVERLAY_NO_TRANSFORM
case SPLASH_OVERLAY_NO_LAYOUT_OFFSET
case SPLASH_OVERLAY_ZORDER
case USER_STYLE_AUTOMATIC
case STATIC_ORACLE_LITERALS
case ICON_RASTER_WHOLE
case ADAPTIVE_FG_RASTER
case ADAPTIVE_MONO_RASTER
case ADAPTIVE_BG_SOLID
case FAVICON_RASTER_WHOLE
case IOS_ICON_NOT_TEMPLATE
case MAESTRO_SPLASH_FRAME_WAIT
case MAESTRO_FIRST_RUN_ORDER
case SPLASH_FRAME_SVERKA_123_DARK
case SPLASH_FRAME_SVERKA_123_LIGHT
case SVERKA_123_STEP_UNCONDITIONAL
case SVERKA_123_MANIFEST_CANON
case SVERKA_123_HARNESS_PIN
static 43/43

rc=0
```

### old-gate-default

```text
$ python3 /tmp/dev-harness-verify/Critic117v3b/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rattack
case RESTYLE_GUARD_995_F03_DARK
case RESTYLE_GUARD_995_F03_LIGHT
case RESTYLE_GUARD_995_WELCOME_DARK
case RESTYLE_GUARD_995_WELCOME_LIGHT
case RESTYLE_GUARD_995_RECOVERY_DARK
case RESTYLE_GUARD_995_RECOVERY_LIGHT
case RESTYLE_GUARD_995_UNAVAILABLE_DARK
case RESTYLE_GUARD_995_UNAVAILABLE_LIGHT
case PROD_ENTRY_OS_THEME_DARK
case PROD_ENTRY_OS_THEME_LIGHT
case STATUS_BAR_STYLE_DARK
case STATUS_BAR_STYLE_LIGHT
case SPLASH_OVERLAY_CONTAIN_DARK
case SPLASH_OVERLAY_CONTAIN_LIGHT
case SPLASH_OVERLAY_GEOMETRY_DARK
case SPLASH_OVERLAY_GEOMETRY_LIGHT
case SPLASH_OVERLAY_ZORDER_DARK
case SPLASH_OVERLAY_ZORDER_LIGHT
case SPLASH_OVERLAY_MOUNTED_DARK
case SPLASH_OVERLAY_MOUNTED_LIGHT
case SPLASH_OVERLAY_COMPOSITE_DARK
case SPLASH_OVERLAY_COMPOSITE_LIGHT
case SPLASH_OVERLAY_VISIBLE_DARK
case SPLASH_OVERLAY_VISIBLE_LIGHT
case SPLASH_OVERLAY_NO_TEXT_DARK
case SPLASH_OVERLAY_NO_TEXT_LIGHT
case SPLASH_HIDEASYNC_ORDER_DARK
case SPLASH_HIDEASYNC_ORDER_LIGHT
case SPLASH_OVERLAY_TIMER_HIDE_DARK
case SPLASH_OVERLAY_TIMER_HIDE_LIGHT
case MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT
case MIGRACIYA_W1A_NULL_PREZHNIJ_PUT
case MIGRACIYA_W1A_STALE_PREZHNIJ_PUT
case MIGRACIYA_W1A_CURRENT_MARSHRUT
case MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT
case MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT
case MIGRACIYA_W0_STALE_PREZHNIJ_PUT
case MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT
case MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT
case MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT
case MIGRACIYA_G0_F03_ONBOARDING_DARK
case MIGRACIYA_G0_F03_ONBOARDING_LIGHT
case MIGRACIYA_G0_F03_DOPUSK_DARK
case MIGRACIYA_G0_F03_DOPUSK_LIGHT
failed 1 of 44

rc=1
```

```text
$ python3 /tmp/dev-harness-verify/Critic117v3b/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rattack
case APP_ICON_DERIVATIVES
case ICON_NOT_TEMPLATE_BYTES
case ICON_ADAPTIVE_BG_DARK
case ICON_PIXELS_MARK
case SPLASH_BLOCKS_DARK_LIGHT
case SPLASH_EFFECTIVE_DARK_LIGHT
case SPLASH_NATIVE_GENERATED_LIGHT_MDPI
case SPLASH_NATIVE_GENERATED_DARK_MDPI
case SPLASH_NATIVE_GENERATED_LIGHT_HDPI
case SPLASH_NATIVE_GENERATED_DARK_HDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XHDPI
case SPLASH_NATIVE_GENERATED_DARK_XHDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XXHDPI
case SPLASH_NATIVE_GENERATED_DARK_XXHDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XXXHDPI
case SPLASH_NATIVE_GENERATED_DARK_XXXHDPI
case SPLASH_NATIVE_GENERATED
case SPLASH_EFFECTIVE_IOS_LIGHT
case SPLASH_EFFECTIVE_IOS_DARK
case SPLASH_IOS_STORYBOARD
case SPLASH_COMPOSITE_ETALON_DARK
case SPLASH_SIGN_RASTER_DARK
case SPLASH_COMPOSITE_ETALON_LIGHT
case SPLASH_SIGN_RASTER_LIGHT
case SPLASH_OVERLAY_CONSUMES_COMPOSITE
case SPLASH_OVERLAY_NO_TRANSFORM
case SPLASH_OVERLAY_NO_LAYOUT_OFFSET
case SPLASH_OVERLAY_ZORDER
case USER_STYLE_AUTOMATIC
case STATIC_ORACLE_LITERALS
case ICON_RASTER_WHOLE
case ADAPTIVE_FG_RASTER
case ADAPTIVE_MONO_RASTER
case ADAPTIVE_BG_SOLID
case FAVICON_RASTER_WHOLE
case IOS_ICON_NOT_TEMPLATE
case MAESTRO_SPLASH_FRAME_WAIT
case MAESTRO_FIRST_RUN_ORDER
case SPLASH_FRAME_SVERKA_123_DARK
case SPLASH_FRAME_SVERKA_123_LIGHT
case SVERKA_123_STEP_UNCONDITIONAL
case SVERKA_123_MANIFEST_CANON
case SVERKA_123_HARNESS_PIN
static 43/43

rc=0
```

### old-w0-stale-admitted

```text
$ python3 /tmp/dev-harness-verify/Critic117v3b/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rattack
case RESTYLE_GUARD_995_F03_DARK
case RESTYLE_GUARD_995_F03_LIGHT
case RESTYLE_GUARD_995_WELCOME_DARK
case RESTYLE_GUARD_995_WELCOME_LIGHT
case RESTYLE_GUARD_995_RECOVERY_DARK
case RESTYLE_GUARD_995_RECOVERY_LIGHT
case RESTYLE_GUARD_995_UNAVAILABLE_DARK
case RESTYLE_GUARD_995_UNAVAILABLE_LIGHT
case PROD_ENTRY_OS_THEME_DARK
case PROD_ENTRY_OS_THEME_LIGHT
case STATUS_BAR_STYLE_DARK
case STATUS_BAR_STYLE_LIGHT
case SPLASH_OVERLAY_CONTAIN_DARK
case SPLASH_OVERLAY_CONTAIN_LIGHT
case SPLASH_OVERLAY_GEOMETRY_DARK
case SPLASH_OVERLAY_GEOMETRY_LIGHT
case SPLASH_OVERLAY_ZORDER_DARK
case SPLASH_OVERLAY_ZORDER_LIGHT
case SPLASH_OVERLAY_MOUNTED_DARK
case SPLASH_OVERLAY_MOUNTED_LIGHT
case SPLASH_OVERLAY_COMPOSITE_DARK
case SPLASH_OVERLAY_COMPOSITE_LIGHT
case SPLASH_OVERLAY_VISIBLE_DARK
case SPLASH_OVERLAY_VISIBLE_LIGHT
case SPLASH_OVERLAY_NO_TEXT_DARK
case SPLASH_OVERLAY_NO_TEXT_LIGHT
case SPLASH_HIDEASYNC_ORDER_DARK
case SPLASH_HIDEASYNC_ORDER_LIGHT
case SPLASH_OVERLAY_TIMER_HIDE_DARK
case SPLASH_OVERLAY_TIMER_HIDE_LIGHT
case MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT
case MIGRACIYA_W1A_NULL_PREZHNIJ_PUT
case MIGRACIYA_W1A_STALE_PREZHNIJ_PUT
case MIGRACIYA_W1A_CURRENT_MARSHRUT
case MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT
case MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT
case MIGRACIYA_W0_STALE_PREZHNIJ_PUT
case MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT
case MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT
case MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT
case MIGRACIYA_G0_F03_ONBOARDING_DARK
case MIGRACIYA_G0_F03_ONBOARDING_LIGHT
case MIGRACIYA_G0_F03_DOPUSK_DARK
case MIGRACIYA_G0_F03_DOPUSK_LIGHT
failed 1 of 44

rc=1
```

```text
$ python3 /tmp/dev-harness-verify/Critic117v3b/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rattack
case APP_ICON_DERIVATIVES
case ICON_NOT_TEMPLATE_BYTES
case ICON_ADAPTIVE_BG_DARK
case ICON_PIXELS_MARK
case SPLASH_BLOCKS_DARK_LIGHT
case SPLASH_EFFECTIVE_DARK_LIGHT
case SPLASH_NATIVE_GENERATED_LIGHT_MDPI
case SPLASH_NATIVE_GENERATED_DARK_MDPI
case SPLASH_NATIVE_GENERATED_LIGHT_HDPI
case SPLASH_NATIVE_GENERATED_DARK_HDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XHDPI
case SPLASH_NATIVE_GENERATED_DARK_XHDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XXHDPI
case SPLASH_NATIVE_GENERATED_DARK_XXHDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XXXHDPI
case SPLASH_NATIVE_GENERATED_DARK_XXXHDPI
case SPLASH_NATIVE_GENERATED
case SPLASH_EFFECTIVE_IOS_LIGHT
case SPLASH_EFFECTIVE_IOS_DARK
case SPLASH_IOS_STORYBOARD
case SPLASH_COMPOSITE_ETALON_DARK
case SPLASH_SIGN_RASTER_DARK
case SPLASH_COMPOSITE_ETALON_LIGHT
case SPLASH_SIGN_RASTER_LIGHT
case SPLASH_OVERLAY_CONSUMES_COMPOSITE
case SPLASH_OVERLAY_NO_TRANSFORM
case SPLASH_OVERLAY_NO_LAYOUT_OFFSET
case SPLASH_OVERLAY_ZORDER
case USER_STYLE_AUTOMATIC
case STATIC_ORACLE_LITERALS
case ICON_RASTER_WHOLE
case ADAPTIVE_FG_RASTER
case ADAPTIVE_MONO_RASTER
case ADAPTIVE_BG_SOLID
case FAVICON_RASTER_WHOLE
case IOS_ICON_NOT_TEMPLATE
case MAESTRO_SPLASH_FRAME_WAIT
case MAESTRO_FIRST_RUN_ORDER
case SPLASH_FRAME_SVERKA_123_DARK
case SPLASH_FRAME_SVERKA_123_LIGHT
case SVERKA_123_STEP_UNCONDITIONAL
case SVERKA_123_MANIFEST_CANON
case SVERKA_123_HARNESS_PIN
static 43/43

rc=0
```

### old-light-bypasses-admission-gate

```text
$ python3 /tmp/dev-harness-verify/Critic117v3b/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rattack
case RESTYLE_GUARD_995_F03_DARK
case RESTYLE_GUARD_995_F03_LIGHT
case RESTYLE_GUARD_995_WELCOME_DARK
case RESTYLE_GUARD_995_WELCOME_LIGHT
case RESTYLE_GUARD_995_RECOVERY_DARK
case RESTYLE_GUARD_995_RECOVERY_LIGHT
case RESTYLE_GUARD_995_UNAVAILABLE_DARK
case RESTYLE_GUARD_995_UNAVAILABLE_LIGHT
case PROD_ENTRY_OS_THEME_DARK
case PROD_ENTRY_OS_THEME_LIGHT
case STATUS_BAR_STYLE_DARK
case STATUS_BAR_STYLE_LIGHT
case SPLASH_OVERLAY_CONTAIN_DARK
case SPLASH_OVERLAY_CONTAIN_LIGHT
case SPLASH_OVERLAY_GEOMETRY_DARK
case SPLASH_OVERLAY_GEOMETRY_LIGHT
case SPLASH_OVERLAY_ZORDER_DARK
case SPLASH_OVERLAY_ZORDER_LIGHT
case SPLASH_OVERLAY_MOUNTED_DARK
case SPLASH_OVERLAY_MOUNTED_LIGHT
case SPLASH_OVERLAY_COMPOSITE_DARK
case SPLASH_OVERLAY_COMPOSITE_LIGHT
case SPLASH_OVERLAY_VISIBLE_DARK
case SPLASH_OVERLAY_VISIBLE_LIGHT
case SPLASH_OVERLAY_NO_TEXT_DARK
case SPLASH_OVERLAY_NO_TEXT_LIGHT
case SPLASH_HIDEASYNC_ORDER_DARK
case SPLASH_HIDEASYNC_ORDER_LIGHT
case SPLASH_OVERLAY_TIMER_HIDE_DARK
case SPLASH_OVERLAY_TIMER_HIDE_LIGHT
case MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT
case MIGRACIYA_W1A_NULL_PREZHNIJ_PUT
case MIGRACIYA_W1A_STALE_PREZHNIJ_PUT
case MIGRACIYA_W1A_CURRENT_MARSHRUT
case MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT
case MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT
case MIGRACIYA_W0_STALE_PREZHNIJ_PUT
case MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT
case MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT
case MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT
case MIGRACIYA_G0_F03_ONBOARDING_DARK
case MIGRACIYA_G0_F03_ONBOARDING_LIGHT
case MIGRACIYA_G0_F03_DOPUSK_DARK
case MIGRACIYA_G0_F03_DOPUSK_LIGHT
failed 3 of 44

rc=1
```

```text
$ python3 /tmp/dev-harness-verify/Critic117v3b/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rattack
case APP_ICON_DERIVATIVES
case ICON_NOT_TEMPLATE_BYTES
case ICON_ADAPTIVE_BG_DARK
case ICON_PIXELS_MARK
case SPLASH_BLOCKS_DARK_LIGHT
case SPLASH_EFFECTIVE_DARK_LIGHT
case SPLASH_NATIVE_GENERATED_LIGHT_MDPI
case SPLASH_NATIVE_GENERATED_DARK_MDPI
case SPLASH_NATIVE_GENERATED_LIGHT_HDPI
case SPLASH_NATIVE_GENERATED_DARK_HDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XHDPI
case SPLASH_NATIVE_GENERATED_DARK_XHDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XXHDPI
case SPLASH_NATIVE_GENERATED_DARK_XXHDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XXXHDPI
case SPLASH_NATIVE_GENERATED_DARK_XXXHDPI
case SPLASH_NATIVE_GENERATED
case SPLASH_EFFECTIVE_IOS_LIGHT
case SPLASH_EFFECTIVE_IOS_DARK
case SPLASH_IOS_STORYBOARD
case SPLASH_COMPOSITE_ETALON_DARK
case SPLASH_SIGN_RASTER_DARK
case SPLASH_COMPOSITE_ETALON_LIGHT
case SPLASH_SIGN_RASTER_LIGHT
case SPLASH_OVERLAY_CONSUMES_COMPOSITE
case SPLASH_OVERLAY_NO_TRANSFORM
case SPLASH_OVERLAY_NO_LAYOUT_OFFSET
case SPLASH_OVERLAY_ZORDER
case USER_STYLE_AUTOMATIC
case STATIC_ORACLE_LITERALS
case ICON_RASTER_WHOLE
case ADAPTIVE_FG_RASTER
case ADAPTIVE_MONO_RASTER
case ADAPTIVE_BG_SOLID
case FAVICON_RASTER_WHOLE
case IOS_ICON_NOT_TEMPLATE
case MAESTRO_SPLASH_FRAME_WAIT
case MAESTRO_FIRST_RUN_ORDER
case SPLASH_FRAME_SVERKA_123_DARK
case SPLASH_FRAME_SVERKA_123_LIGHT
case SVERKA_123_STEP_UNCONDITIONAL
case SVERKA_123_MANIFEST_CANON
case SVERKA_123_HARNESS_PIN
static 43/43

rc=0
```

### old-onboarding-restyles-f03

```text
$ python3 /tmp/dev-harness-verify/Critic117v3b/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rattack
case RESTYLE_GUARD_995_F03_DARK
case RESTYLE_GUARD_995_F03_LIGHT
case RESTYLE_GUARD_995_WELCOME_DARK
case RESTYLE_GUARD_995_WELCOME_LIGHT
case RESTYLE_GUARD_995_RECOVERY_DARK
case RESTYLE_GUARD_995_RECOVERY_LIGHT
case RESTYLE_GUARD_995_UNAVAILABLE_DARK
case RESTYLE_GUARD_995_UNAVAILABLE_LIGHT
case PROD_ENTRY_OS_THEME_DARK
case PROD_ENTRY_OS_THEME_LIGHT
case STATUS_BAR_STYLE_DARK
case STATUS_BAR_STYLE_LIGHT
case SPLASH_OVERLAY_CONTAIN_DARK
case SPLASH_OVERLAY_CONTAIN_LIGHT
case SPLASH_OVERLAY_GEOMETRY_DARK
case SPLASH_OVERLAY_GEOMETRY_LIGHT
case SPLASH_OVERLAY_ZORDER_DARK
case SPLASH_OVERLAY_ZORDER_LIGHT
case SPLASH_OVERLAY_MOUNTED_DARK
case SPLASH_OVERLAY_MOUNTED_LIGHT
case SPLASH_OVERLAY_COMPOSITE_DARK
case SPLASH_OVERLAY_COMPOSITE_LIGHT
case SPLASH_OVERLAY_VISIBLE_DARK
case SPLASH_OVERLAY_VISIBLE_LIGHT
case SPLASH_OVERLAY_NO_TEXT_DARK
case SPLASH_OVERLAY_NO_TEXT_LIGHT
case SPLASH_HIDEASYNC_ORDER_DARK
case SPLASH_HIDEASYNC_ORDER_LIGHT
case SPLASH_OVERLAY_TIMER_HIDE_DARK
case SPLASH_OVERLAY_TIMER_HIDE_LIGHT
case MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT
case MIGRACIYA_W1A_NULL_PREZHNIJ_PUT
case MIGRACIYA_W1A_STALE_PREZHNIJ_PUT
case MIGRACIYA_W1A_CURRENT_MARSHRUT
case MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT
case MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT
case MIGRACIYA_W0_STALE_PREZHNIJ_PUT
case MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT
case MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT
case MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT
case MIGRACIYA_G0_F03_ONBOARDING_DARK
case MIGRACIYA_G0_F03_ONBOARDING_LIGHT
case MIGRACIYA_G0_F03_DOPUSK_DARK
case MIGRACIYA_G0_F03_DOPUSK_LIGHT
failed 4 of 44

rc=1
```

```text
$ python3 /tmp/dev-harness-verify/Critic117v3b/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rattack
case APP_ICON_DERIVATIVES
case ICON_NOT_TEMPLATE_BYTES
case ICON_ADAPTIVE_BG_DARK
case ICON_PIXELS_MARK
case SPLASH_BLOCKS_DARK_LIGHT
case SPLASH_EFFECTIVE_DARK_LIGHT
case SPLASH_NATIVE_GENERATED_LIGHT_MDPI
case SPLASH_NATIVE_GENERATED_DARK_MDPI
case SPLASH_NATIVE_GENERATED_LIGHT_HDPI
case SPLASH_NATIVE_GENERATED_DARK_HDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XHDPI
case SPLASH_NATIVE_GENERATED_DARK_XHDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XXHDPI
case SPLASH_NATIVE_GENERATED_DARK_XXHDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XXXHDPI
case SPLASH_NATIVE_GENERATED_DARK_XXXHDPI
case SPLASH_NATIVE_GENERATED
case SPLASH_EFFECTIVE_IOS_LIGHT
case SPLASH_EFFECTIVE_IOS_DARK
case SPLASH_IOS_STORYBOARD
case SPLASH_COMPOSITE_ETALON_DARK
case SPLASH_SIGN_RASTER_DARK
case SPLASH_COMPOSITE_ETALON_LIGHT
case SPLASH_SIGN_RASTER_LIGHT
case SPLASH_OVERLAY_CONSUMES_COMPOSITE
case SPLASH_OVERLAY_NO_TRANSFORM
case SPLASH_OVERLAY_NO_LAYOUT_OFFSET
case SPLASH_OVERLAY_ZORDER
case USER_STYLE_AUTOMATIC
case STATIC_ORACLE_LITERALS
case ICON_RASTER_WHOLE
case ADAPTIVE_FG_RASTER
case ADAPTIVE_MONO_RASTER
case ADAPTIVE_BG_SOLID
case FAVICON_RASTER_WHOLE
case IOS_ICON_NOT_TEMPLATE
case MAESTRO_SPLASH_FRAME_WAIT
case MAESTRO_FIRST_RUN_ORDER
case SPLASH_FRAME_SVERKA_123_DARK
case SPLASH_FRAME_SVERKA_123_LIGHT
case SVERKA_123_STEP_UNCONDITIONAL
case SVERKA_123_MANIFEST_CANON
case SVERKA_123_HARNESS_PIN
static 43/43

rc=0
```

### new-light-gate-default

```text
$ python3 /tmp/dev-harness-verify/Critic117v3b/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rattack
case RESTYLE_GUARD_995_F03_DARK
case RESTYLE_GUARD_995_F03_LIGHT
case RESTYLE_GUARD_995_WELCOME_DARK
case RESTYLE_GUARD_995_WELCOME_LIGHT
case RESTYLE_GUARD_995_RECOVERY_DARK
case RESTYLE_GUARD_995_RECOVERY_LIGHT
case RESTYLE_GUARD_995_UNAVAILABLE_DARK
case RESTYLE_GUARD_995_UNAVAILABLE_LIGHT
case PROD_ENTRY_OS_THEME_DARK
case PROD_ENTRY_OS_THEME_LIGHT
case STATUS_BAR_STYLE_DARK
case STATUS_BAR_STYLE_LIGHT
case SPLASH_OVERLAY_CONTAIN_DARK
case SPLASH_OVERLAY_CONTAIN_LIGHT
case SPLASH_OVERLAY_GEOMETRY_DARK
case SPLASH_OVERLAY_GEOMETRY_LIGHT
case SPLASH_OVERLAY_ZORDER_DARK
case SPLASH_OVERLAY_ZORDER_LIGHT
case SPLASH_OVERLAY_MOUNTED_DARK
case SPLASH_OVERLAY_MOUNTED_LIGHT
case SPLASH_OVERLAY_COMPOSITE_DARK
case SPLASH_OVERLAY_COMPOSITE_LIGHT
case SPLASH_OVERLAY_VISIBLE_DARK
case SPLASH_OVERLAY_VISIBLE_LIGHT
case SPLASH_OVERLAY_NO_TEXT_DARK
case SPLASH_OVERLAY_NO_TEXT_LIGHT
case SPLASH_HIDEASYNC_ORDER_DARK
case SPLASH_HIDEASYNC_ORDER_LIGHT
case SPLASH_OVERLAY_TIMER_HIDE_DARK
case SPLASH_OVERLAY_TIMER_HIDE_LIGHT
case MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT
case MIGRACIYA_W1A_NULL_PREZHNIJ_PUT
case MIGRACIYA_W1A_STALE_PREZHNIJ_PUT
case MIGRACIYA_W1A_CURRENT_MARSHRUT
case MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT
case MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT
case MIGRACIYA_W0_STALE_PREZHNIJ_PUT
case MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT
case MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT
case MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT
case MIGRACIYA_G0_F03_ONBOARDING_DARK
case MIGRACIYA_G0_F03_ONBOARDING_LIGHT
case MIGRACIYA_G0_F03_DOPUSK_DARK
case MIGRACIYA_G0_F03_DOPUSK_LIGHT
behavioral 44/44

rc=0
```

```text
$ python3 /tmp/dev-harness-verify/Critic117v3b/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rattack
case APP_ICON_DERIVATIVES
case ICON_NOT_TEMPLATE_BYTES
case ICON_ADAPTIVE_BG_DARK
case ICON_PIXELS_MARK
case SPLASH_BLOCKS_DARK_LIGHT
case SPLASH_EFFECTIVE_DARK_LIGHT
case SPLASH_NATIVE_GENERATED_LIGHT_MDPI
case SPLASH_NATIVE_GENERATED_DARK_MDPI
case SPLASH_NATIVE_GENERATED_LIGHT_HDPI
case SPLASH_NATIVE_GENERATED_DARK_HDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XHDPI
case SPLASH_NATIVE_GENERATED_DARK_XHDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XXHDPI
case SPLASH_NATIVE_GENERATED_DARK_XXHDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XXXHDPI
case SPLASH_NATIVE_GENERATED_DARK_XXXHDPI
case SPLASH_NATIVE_GENERATED
case SPLASH_EFFECTIVE_IOS_LIGHT
case SPLASH_EFFECTIVE_IOS_DARK
case SPLASH_IOS_STORYBOARD
case SPLASH_COMPOSITE_ETALON_DARK
case SPLASH_SIGN_RASTER_DARK
case SPLASH_COMPOSITE_ETALON_LIGHT
case SPLASH_SIGN_RASTER_LIGHT
case SPLASH_OVERLAY_CONSUMES_COMPOSITE
case SPLASH_OVERLAY_NO_TRANSFORM
case SPLASH_OVERLAY_NO_LAYOUT_OFFSET
case SPLASH_OVERLAY_ZORDER
case USER_STYLE_AUTOMATIC
case STATIC_ORACLE_LITERALS
case ICON_RASTER_WHOLE
case ADAPTIVE_FG_RASTER
case ADAPTIVE_MONO_RASTER
case ADAPTIVE_BG_SOLID
case FAVICON_RASTER_WHOLE
case IOS_ICON_NOT_TEMPLATE
case MAESTRO_SPLASH_FRAME_WAIT
case MAESTRO_FIRST_RUN_ORDER
case SPLASH_FRAME_SVERKA_123_DARK
case SPLASH_FRAME_SVERKA_123_LIGHT
case SVERKA_123_STEP_UNCONDITIONAL
case SVERKA_123_MANIFEST_CANON
case SVERKA_123_HARNESS_PIN
static 43/43

rc=0
```

### new-light-stale-current

```text
$ python3 /tmp/dev-harness-verify/Critic117v3b/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rattack
case RESTYLE_GUARD_995_F03_DARK
case RESTYLE_GUARD_995_F03_LIGHT
case RESTYLE_GUARD_995_WELCOME_DARK
case RESTYLE_GUARD_995_WELCOME_LIGHT
case RESTYLE_GUARD_995_RECOVERY_DARK
case RESTYLE_GUARD_995_RECOVERY_LIGHT
case RESTYLE_GUARD_995_UNAVAILABLE_DARK
case RESTYLE_GUARD_995_UNAVAILABLE_LIGHT
case PROD_ENTRY_OS_THEME_DARK
case PROD_ENTRY_OS_THEME_LIGHT
case STATUS_BAR_STYLE_DARK
case STATUS_BAR_STYLE_LIGHT
case SPLASH_OVERLAY_CONTAIN_DARK
case SPLASH_OVERLAY_CONTAIN_LIGHT
case SPLASH_OVERLAY_GEOMETRY_DARK
case SPLASH_OVERLAY_GEOMETRY_LIGHT
case SPLASH_OVERLAY_ZORDER_DARK
case SPLASH_OVERLAY_ZORDER_LIGHT
case SPLASH_OVERLAY_MOUNTED_DARK
case SPLASH_OVERLAY_MOUNTED_LIGHT
case SPLASH_OVERLAY_COMPOSITE_DARK
case SPLASH_OVERLAY_COMPOSITE_LIGHT
case SPLASH_OVERLAY_VISIBLE_DARK
case SPLASH_OVERLAY_VISIBLE_LIGHT
case SPLASH_OVERLAY_NO_TEXT_DARK
case SPLASH_OVERLAY_NO_TEXT_LIGHT
case SPLASH_HIDEASYNC_ORDER_DARK
case SPLASH_HIDEASYNC_ORDER_LIGHT
case SPLASH_OVERLAY_TIMER_HIDE_DARK
case SPLASH_OVERLAY_TIMER_HIDE_LIGHT
case MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT
case MIGRACIYA_W1A_NULL_PREZHNIJ_PUT
case MIGRACIYA_W1A_STALE_PREZHNIJ_PUT
case MIGRACIYA_W1A_CURRENT_MARSHRUT
case MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT
case MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT
case MIGRACIYA_W0_STALE_PREZHNIJ_PUT
case MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT
case MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT
case MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT
case MIGRACIYA_G0_F03_ONBOARDING_DARK
case MIGRACIYA_G0_F03_ONBOARDING_LIGHT
case MIGRACIYA_G0_F03_DOPUSK_DARK
case MIGRACIYA_G0_F03_DOPUSK_LIGHT
failed 1 of 44

rc=1
```

```text
$ python3 /tmp/dev-harness-verify/Critic117v3b/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rattack
case APP_ICON_DERIVATIVES
case ICON_NOT_TEMPLATE_BYTES
case ICON_ADAPTIVE_BG_DARK
case ICON_PIXELS_MARK
case SPLASH_BLOCKS_DARK_LIGHT
case SPLASH_EFFECTIVE_DARK_LIGHT
case SPLASH_NATIVE_GENERATED_LIGHT_MDPI
case SPLASH_NATIVE_GENERATED_DARK_MDPI
case SPLASH_NATIVE_GENERATED_LIGHT_HDPI
case SPLASH_NATIVE_GENERATED_DARK_HDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XHDPI
case SPLASH_NATIVE_GENERATED_DARK_XHDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XXHDPI
case SPLASH_NATIVE_GENERATED_DARK_XXHDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XXXHDPI
case SPLASH_NATIVE_GENERATED_DARK_XXXHDPI
case SPLASH_NATIVE_GENERATED
case SPLASH_EFFECTIVE_IOS_LIGHT
case SPLASH_EFFECTIVE_IOS_DARK
case SPLASH_IOS_STORYBOARD
case SPLASH_COMPOSITE_ETALON_DARK
case SPLASH_SIGN_RASTER_DARK
case SPLASH_COMPOSITE_ETALON_LIGHT
case SPLASH_SIGN_RASTER_LIGHT
case SPLASH_OVERLAY_CONSUMES_COMPOSITE
case SPLASH_OVERLAY_NO_TRANSFORM
case SPLASH_OVERLAY_NO_LAYOUT_OFFSET
case SPLASH_OVERLAY_ZORDER
case USER_STYLE_AUTOMATIC
case STATIC_ORACLE_LITERALS
case ICON_RASTER_WHOLE
case ADAPTIVE_FG_RASTER
case ADAPTIVE_MONO_RASTER
case ADAPTIVE_BG_SOLID
case FAVICON_RASTER_WHOLE
case IOS_ICON_NOT_TEMPLATE
case MAESTRO_SPLASH_FRAME_WAIT
case MAESTRO_FIRST_RUN_ORDER
case SPLASH_FRAME_SVERKA_123_DARK
case SPLASH_FRAME_SVERKA_123_LIGHT
case SVERKA_123_STEP_UNCONDITIONAL
case SVERKA_123_MANIFEST_CANON
case SVERKA_123_HARNESS_PIN
static 43/43

rc=0
```

### new-empty-session-demo

```text
$ python3 /tmp/dev-harness-verify/Critic117v3b/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rattack
case RESTYLE_GUARD_995_F03_DARK
case RESTYLE_GUARD_995_F03_LIGHT
case RESTYLE_GUARD_995_WELCOME_DARK
case RESTYLE_GUARD_995_WELCOME_LIGHT
case RESTYLE_GUARD_995_RECOVERY_DARK
case RESTYLE_GUARD_995_RECOVERY_LIGHT
case RESTYLE_GUARD_995_UNAVAILABLE_DARK
case RESTYLE_GUARD_995_UNAVAILABLE_LIGHT
case PROD_ENTRY_OS_THEME_DARK
case PROD_ENTRY_OS_THEME_LIGHT
case STATUS_BAR_STYLE_DARK
case STATUS_BAR_STYLE_LIGHT
case SPLASH_OVERLAY_CONTAIN_DARK
case SPLASH_OVERLAY_CONTAIN_LIGHT
case SPLASH_OVERLAY_GEOMETRY_DARK
case SPLASH_OVERLAY_GEOMETRY_LIGHT
case SPLASH_OVERLAY_ZORDER_DARK
case SPLASH_OVERLAY_ZORDER_LIGHT
case SPLASH_OVERLAY_MOUNTED_DARK
case SPLASH_OVERLAY_MOUNTED_LIGHT
case SPLASH_OVERLAY_COMPOSITE_DARK
case SPLASH_OVERLAY_COMPOSITE_LIGHT
case SPLASH_OVERLAY_VISIBLE_DARK
case SPLASH_OVERLAY_VISIBLE_LIGHT
case SPLASH_OVERLAY_NO_TEXT_DARK
case SPLASH_OVERLAY_NO_TEXT_LIGHT
case SPLASH_HIDEASYNC_ORDER_DARK
case SPLASH_HIDEASYNC_ORDER_LIGHT
case SPLASH_OVERLAY_TIMER_HIDE_DARK
case SPLASH_OVERLAY_TIMER_HIDE_LIGHT
case MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT
case MIGRACIYA_W1A_NULL_PREZHNIJ_PUT
case MIGRACIYA_W1A_STALE_PREZHNIJ_PUT
case MIGRACIYA_W1A_CURRENT_MARSHRUT
case MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT
case MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT
case MIGRACIYA_W0_STALE_PREZHNIJ_PUT
case MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT
case MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT
case MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT
case MIGRACIYA_G0_F03_ONBOARDING_DARK
case MIGRACIYA_G0_F03_ONBOARDING_LIGHT
case MIGRACIYA_G0_F03_DOPUSK_DARK
case MIGRACIYA_G0_F03_DOPUSK_LIGHT
behavioral 44/44

rc=0
```

```text
$ python3 /tmp/dev-harness-verify/Critic117v3b/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rattack
case APP_ICON_DERIVATIVES
case ICON_NOT_TEMPLATE_BYTES
case ICON_ADAPTIVE_BG_DARK
case ICON_PIXELS_MARK
case SPLASH_BLOCKS_DARK_LIGHT
case SPLASH_EFFECTIVE_DARK_LIGHT
case SPLASH_NATIVE_GENERATED_LIGHT_MDPI
case SPLASH_NATIVE_GENERATED_DARK_MDPI
case SPLASH_NATIVE_GENERATED_LIGHT_HDPI
case SPLASH_NATIVE_GENERATED_DARK_HDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XHDPI
case SPLASH_NATIVE_GENERATED_DARK_XHDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XXHDPI
case SPLASH_NATIVE_GENERATED_DARK_XXHDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XXXHDPI
case SPLASH_NATIVE_GENERATED_DARK_XXXHDPI
case SPLASH_NATIVE_GENERATED
case SPLASH_EFFECTIVE_IOS_LIGHT
case SPLASH_EFFECTIVE_IOS_DARK
case SPLASH_IOS_STORYBOARD
case SPLASH_COMPOSITE_ETALON_DARK
case SPLASH_SIGN_RASTER_DARK
case SPLASH_COMPOSITE_ETALON_LIGHT
case SPLASH_SIGN_RASTER_LIGHT
case SPLASH_OVERLAY_CONSUMES_COMPOSITE
case SPLASH_OVERLAY_NO_TRANSFORM
case SPLASH_OVERLAY_NO_LAYOUT_OFFSET
case SPLASH_OVERLAY_ZORDER
case USER_STYLE_AUTOMATIC
case STATIC_ORACLE_LITERALS
case ICON_RASTER_WHOLE
case ADAPTIVE_FG_RASTER
case ADAPTIVE_MONO_RASTER
case ADAPTIVE_BG_SOLID
case FAVICON_RASTER_WHOLE
case IOS_ICON_NOT_TEMPLATE
case MAESTRO_SPLASH_FRAME_WAIT
case MAESTRO_FIRST_RUN_ORDER
case SPLASH_FRAME_SVERKA_123_DARK
case SPLASH_FRAME_SVERKA_123_LIGHT
case SVERKA_123_STEP_UNCONDITIONAL
case SVERKA_123_MANIFEST_CANON
case SVERKA_123_HARNESS_PIN
static 43/43

rc=0
```

### new-g0-denied-admission

```text
$ python3 /tmp/dev-harness-verify/Critic117v3b/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rattack
case RESTYLE_GUARD_995_F03_DARK
case RESTYLE_GUARD_995_F03_LIGHT
case RESTYLE_GUARD_995_WELCOME_DARK
case RESTYLE_GUARD_995_WELCOME_LIGHT
case RESTYLE_GUARD_995_RECOVERY_DARK
case RESTYLE_GUARD_995_RECOVERY_LIGHT
case RESTYLE_GUARD_995_UNAVAILABLE_DARK
case RESTYLE_GUARD_995_UNAVAILABLE_LIGHT
case PROD_ENTRY_OS_THEME_DARK
case PROD_ENTRY_OS_THEME_LIGHT
case STATUS_BAR_STYLE_DARK
case STATUS_BAR_STYLE_LIGHT
case SPLASH_OVERLAY_CONTAIN_DARK
case SPLASH_OVERLAY_CONTAIN_LIGHT
case SPLASH_OVERLAY_GEOMETRY_DARK
case SPLASH_OVERLAY_GEOMETRY_LIGHT
case SPLASH_OVERLAY_ZORDER_DARK
case SPLASH_OVERLAY_ZORDER_LIGHT
case SPLASH_OVERLAY_MOUNTED_DARK
case SPLASH_OVERLAY_MOUNTED_LIGHT
case SPLASH_OVERLAY_COMPOSITE_DARK
case SPLASH_OVERLAY_COMPOSITE_LIGHT
case SPLASH_OVERLAY_VISIBLE_DARK
case SPLASH_OVERLAY_VISIBLE_LIGHT
case SPLASH_OVERLAY_NO_TEXT_DARK
case SPLASH_OVERLAY_NO_TEXT_LIGHT
case SPLASH_HIDEASYNC_ORDER_DARK
case SPLASH_HIDEASYNC_ORDER_LIGHT
case SPLASH_OVERLAY_TIMER_HIDE_DARK
case SPLASH_OVERLAY_TIMER_HIDE_LIGHT
case MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT
case MIGRACIYA_W1A_NULL_PREZHNIJ_PUT
case MIGRACIYA_W1A_STALE_PREZHNIJ_PUT
case MIGRACIYA_W1A_CURRENT_MARSHRUT
case MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT
case MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT
case MIGRACIYA_W0_STALE_PREZHNIJ_PUT
case MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT
case MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT
case MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT
case MIGRACIYA_G0_F03_ONBOARDING_DARK
case MIGRACIYA_G0_F03_ONBOARDING_LIGHT
case MIGRACIYA_G0_F03_DOPUSK_DARK
case MIGRACIYA_G0_F03_DOPUSK_LIGHT
behavioral 44/44

rc=0
```

```text
$ python3 /tmp/dev-harness-verify/Critic117v3b/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rattack
case APP_ICON_DERIVATIVES
case ICON_NOT_TEMPLATE_BYTES
case ICON_ADAPTIVE_BG_DARK
case ICON_PIXELS_MARK
case SPLASH_BLOCKS_DARK_LIGHT
case SPLASH_EFFECTIVE_DARK_LIGHT
case SPLASH_NATIVE_GENERATED_LIGHT_MDPI
case SPLASH_NATIVE_GENERATED_DARK_MDPI
case SPLASH_NATIVE_GENERATED_LIGHT_HDPI
case SPLASH_NATIVE_GENERATED_DARK_HDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XHDPI
case SPLASH_NATIVE_GENERATED_DARK_XHDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XXHDPI
case SPLASH_NATIVE_GENERATED_DARK_XXHDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XXXHDPI
case SPLASH_NATIVE_GENERATED_DARK_XXXHDPI
case SPLASH_NATIVE_GENERATED
case SPLASH_EFFECTIVE_IOS_LIGHT
case SPLASH_EFFECTIVE_IOS_DARK
case SPLASH_IOS_STORYBOARD
case SPLASH_COMPOSITE_ETALON_DARK
case SPLASH_SIGN_RASTER_DARK
case SPLASH_COMPOSITE_ETALON_LIGHT
case SPLASH_SIGN_RASTER_LIGHT
case SPLASH_OVERLAY_CONSUMES_COMPOSITE
case SPLASH_OVERLAY_NO_TRANSFORM
case SPLASH_OVERLAY_NO_LAYOUT_OFFSET
case SPLASH_OVERLAY_ZORDER
case USER_STYLE_AUTOMATIC
case STATIC_ORACLE_LITERALS
case ICON_RASTER_WHOLE
case ADAPTIVE_FG_RASTER
case ADAPTIVE_MONO_RASTER
case ADAPTIVE_BG_SOLID
case FAVICON_RASTER_WHOLE
case IOS_ICON_NOT_TEMPLATE
case MAESTRO_SPLASH_FRAME_WAIT
case MAESTRO_FIRST_RUN_ORDER
case SPLASH_FRAME_SVERKA_123_DARK
case SPLASH_FRAME_SVERKA_123_LIGHT
case SVERKA_123_STEP_UNCONDITIONAL
case SVERKA_123_MANIFEST_CANON
case SVERKA_123_HARNESS_PIN
static 43/43

rc=0
```

### new-light-start-before-continue

```text
$ python3 /tmp/dev-harness-verify/Critic117v3b/repo/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rattack
case RESTYLE_GUARD_995_F03_DARK
case RESTYLE_GUARD_995_F03_LIGHT
case RESTYLE_GUARD_995_WELCOME_DARK
case RESTYLE_GUARD_995_WELCOME_LIGHT
case RESTYLE_GUARD_995_RECOVERY_DARK
case RESTYLE_GUARD_995_RECOVERY_LIGHT
case RESTYLE_GUARD_995_UNAVAILABLE_DARK
case RESTYLE_GUARD_995_UNAVAILABLE_LIGHT
case PROD_ENTRY_OS_THEME_DARK
case PROD_ENTRY_OS_THEME_LIGHT
case STATUS_BAR_STYLE_DARK
case STATUS_BAR_STYLE_LIGHT
case SPLASH_OVERLAY_CONTAIN_DARK
case SPLASH_OVERLAY_CONTAIN_LIGHT
case SPLASH_OVERLAY_GEOMETRY_DARK
case SPLASH_OVERLAY_GEOMETRY_LIGHT
case SPLASH_OVERLAY_ZORDER_DARK
case SPLASH_OVERLAY_ZORDER_LIGHT
case SPLASH_OVERLAY_MOUNTED_DARK
case SPLASH_OVERLAY_MOUNTED_LIGHT
case SPLASH_OVERLAY_COMPOSITE_DARK
case SPLASH_OVERLAY_COMPOSITE_LIGHT
case SPLASH_OVERLAY_VISIBLE_DARK
case SPLASH_OVERLAY_VISIBLE_LIGHT
case SPLASH_OVERLAY_NO_TEXT_DARK
case SPLASH_OVERLAY_NO_TEXT_LIGHT
case SPLASH_HIDEASYNC_ORDER_DARK
case SPLASH_HIDEASYNC_ORDER_LIGHT
case SPLASH_OVERLAY_TIMER_HIDE_DARK
case SPLASH_OVERLAY_TIMER_HIDE_LIGHT
case MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT
case MIGRACIYA_W1A_NULL_PREZHNIJ_PUT
case MIGRACIYA_W1A_STALE_PREZHNIJ_PUT
case MIGRACIYA_W1A_CURRENT_MARSHRUT
case MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT
case MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT
case MIGRACIYA_W0_STALE_PREZHNIJ_PUT
case MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT
case MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT
case MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT
case MIGRACIYA_G0_F03_ONBOARDING_DARK
case MIGRACIYA_G0_F03_ONBOARDING_LIGHT
case MIGRACIYA_G0_F03_DOPUSK_DARK
case MIGRACIYA_G0_F03_DOPUSK_LIGHT
failed 1 of 44

rc=1
```

```text
$ python3 /tmp/dev-harness-verify/Critic117v3b/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rattack
case APP_ICON_DERIVATIVES
case ICON_NOT_TEMPLATE_BYTES
case ICON_ADAPTIVE_BG_DARK
case ICON_PIXELS_MARK
case SPLASH_BLOCKS_DARK_LIGHT
case SPLASH_EFFECTIVE_DARK_LIGHT
case SPLASH_NATIVE_GENERATED_LIGHT_MDPI
case SPLASH_NATIVE_GENERATED_DARK_MDPI
case SPLASH_NATIVE_GENERATED_LIGHT_HDPI
case SPLASH_NATIVE_GENERATED_DARK_HDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XHDPI
case SPLASH_NATIVE_GENERATED_DARK_XHDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XXHDPI
case SPLASH_NATIVE_GENERATED_DARK_XXHDPI
case SPLASH_NATIVE_GENERATED_LIGHT_XXXHDPI
case SPLASH_NATIVE_GENERATED_DARK_XXXHDPI
case SPLASH_NATIVE_GENERATED
case SPLASH_EFFECTIVE_IOS_LIGHT
case SPLASH_EFFECTIVE_IOS_DARK
case SPLASH_IOS_STORYBOARD
case SPLASH_COMPOSITE_ETALON_DARK
case SPLASH_SIGN_RASTER_DARK
case SPLASH_COMPOSITE_ETALON_LIGHT
case SPLASH_SIGN_RASTER_LIGHT
case SPLASH_OVERLAY_CONSUMES_COMPOSITE
case SPLASH_OVERLAY_NO_TRANSFORM
case SPLASH_OVERLAY_NO_LAYOUT_OFFSET
case SPLASH_OVERLAY_ZORDER
case USER_STYLE_AUTOMATIC
case STATIC_ORACLE_LITERALS
case ICON_RASTER_WHOLE
case ADAPTIVE_FG_RASTER
case ADAPTIVE_MONO_RASTER
case ADAPTIVE_BG_SOLID
case FAVICON_RASTER_WHOLE
case IOS_ICON_NOT_TEMPLATE
case MAESTRO_SPLASH_FRAME_WAIT
case MAESTRO_FIRST_RUN_ORDER
case SPLASH_FRAME_SVERKA_123_DARK
case SPLASH_FRAME_SVERKA_123_LIGHT
case SVERKA_123_STEP_UNCONDITIONAL
case SVERKA_123_MANIFEST_CANON
case SVERKA_123_HARNESS_PIN
static 43/43

rc=0
```

## Живые свидетели и честные контроли

### new-light-gate-default-control

```text
$ python3 witness.py # new-light-gate-default-control
  console.log
    HONEST_CONTROL: denied path reaches auth-code; Start absent

      at Object.log (src/bootstrap/__tests__/vkhod-117.probe.test.tsx:921:267)

PASS src/bootstrap/__tests__/vkhod-117.probe.test.tsx
  117 vkhod
    ✓ CRITIC_WITNESS (1238 ms)
    ○ skipped RESTYLE_GUARD_995_F03_DARK
    ○ skipped RESTYLE_GUARD_995_F03_LIGHT
    ○ skipped RESTYLE_GUARD_995_WELCOME_DARK
    ○ skipped RESTYLE_GUARD_995_WELCOME_LIGHT
    ○ skipped RESTYLE_GUARD_995_RECOVERY_DARK
    ○ skipped RESTYLE_GUARD_995_RECOVERY_LIGHT
    ○ skipped RESTYLE_GUARD_995_UNAVAILABLE_DARK
    ○ skipped RESTYLE_GUARD_995_UNAVAILABLE_LIGHT
    ○ skipped PROD_ENTRY_OS_THEME_DARK
    ○ skipped PROD_ENTRY_OS_THEME_LIGHT
    ○ skipped STATUS_BAR_STYLE_DARK
    ○ skipped STATUS_BAR_STYLE_LIGHT
    ○ skipped SPLASH_OVERLAY_CONTAIN_DARK
    ○ skipped SPLASH_OVERLAY_CONTAIN_LIGHT
    ○ skipped SPLASH_OVERLAY_GEOMETRY_DARK
    ○ skipped SPLASH_OVERLAY_GEOMETRY_LIGHT
    ○ skipped SPLASH_OVERLAY_ZORDER_DARK
    ○ skipped SPLASH_OVERLAY_ZORDER_LIGHT
    ○ skipped SPLASH_OVERLAY_MOUNTED_DARK
    ○ skipped SPLASH_OVERLAY_MOUNTED_LIGHT
    ○ skipped SPLASH_OVERLAY_COMPOSITE_DARK
    ○ skipped SPLASH_OVERLAY_COMPOSITE_LIGHT
    ○ skipped SPLASH_OVERLAY_VISIBLE_DARK
    ○ skipped SPLASH_OVERLAY_VISIBLE_LIGHT
    ○ skipped SPLASH_OVERLAY_NO_TEXT_DARK
    ○ skipped SPLASH_OVERLAY_NO_TEXT_LIGHT
    ○ skipped SPLASH_HIDEASYNC_ORDER_DARK
    ○ skipped SPLASH_HIDEASYNC_ORDER_LIGHT
    ○ skipped SPLASH_OVERLAY_TIMER_HIDE_DARK
    ○ skipped SPLASH_OVERLAY_TIMER_HIDE_LIGHT
    ○ skipped MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_NULL_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_STALE_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_CURRENT_MARSHRUT
    ○ skipped MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W0_STALE_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT
    ○ skipped MIGRACIYA_G0_F03_ONBOARDING_DARK
    ○ skipped MIGRACIYA_G0_F03_ONBOARDING_LIGHT
    ○ skipped MIGRACIYA_G0_F03_DOPUSK_DARK
    ○ skipped MIGRACIYA_G0_F03_DOPUSK_LIGHT

Test Suites: 1 passed, 1 total
Tests:       44 skipped, 1 passed, 45 total
Snapshots:   0 total
Time:        3.26 s
Ran all test suites within paths "/tmp/dev-harness-verify/Critic117v3b/Rwitness/mobile/src/bootstrap/__tests__/vkhod-117.probe.test.tsx".
Test results written to: ../../tmp/tmpfjsxpfx1.json

rc=0
```

### new-light-gate-default-witness

```text
$ python3 witness.py # new-light-gate-default-witness
  console.log
    BYPASS_OBSERVED: Start reached without admission/current

      at Object.log (src/bootstrap/__tests__/vkhod-117.probe.test.tsx:921:333)

PASS src/bootstrap/__tests__/vkhod-117.probe.test.tsx
  117 vkhod
    ✓ CRITIC_WITNESS (118 ms)
    ○ skipped RESTYLE_GUARD_995_F03_DARK
    ○ skipped RESTYLE_GUARD_995_F03_LIGHT
    ○ skipped RESTYLE_GUARD_995_WELCOME_DARK
    ○ skipped RESTYLE_GUARD_995_WELCOME_LIGHT
    ○ skipped RESTYLE_GUARD_995_RECOVERY_DARK
    ○ skipped RESTYLE_GUARD_995_RECOVERY_LIGHT
    ○ skipped RESTYLE_GUARD_995_UNAVAILABLE_DARK
    ○ skipped RESTYLE_GUARD_995_UNAVAILABLE_LIGHT
    ○ skipped PROD_ENTRY_OS_THEME_DARK
    ○ skipped PROD_ENTRY_OS_THEME_LIGHT
    ○ skipped STATUS_BAR_STYLE_DARK
    ○ skipped STATUS_BAR_STYLE_LIGHT
    ○ skipped SPLASH_OVERLAY_CONTAIN_DARK
    ○ skipped SPLASH_OVERLAY_CONTAIN_LIGHT
    ○ skipped SPLASH_OVERLAY_GEOMETRY_DARK
    ○ skipped SPLASH_OVERLAY_GEOMETRY_LIGHT
    ○ skipped SPLASH_OVERLAY_ZORDER_DARK
    ○ skipped SPLASH_OVERLAY_ZORDER_LIGHT
    ○ skipped SPLASH_OVERLAY_MOUNTED_DARK
    ○ skipped SPLASH_OVERLAY_MOUNTED_LIGHT
    ○ skipped SPLASH_OVERLAY_COMPOSITE_DARK
    ○ skipped SPLASH_OVERLAY_COMPOSITE_LIGHT
    ○ skipped SPLASH_OVERLAY_VISIBLE_DARK
    ○ skipped SPLASH_OVERLAY_VISIBLE_LIGHT
    ○ skipped SPLASH_OVERLAY_NO_TEXT_DARK
    ○ skipped SPLASH_OVERLAY_NO_TEXT_LIGHT
    ○ skipped SPLASH_HIDEASYNC_ORDER_DARK
    ○ skipped SPLASH_HIDEASYNC_ORDER_LIGHT
    ○ skipped SPLASH_OVERLAY_TIMER_HIDE_DARK
    ○ skipped SPLASH_OVERLAY_TIMER_HIDE_LIGHT
    ○ skipped MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_NULL_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_STALE_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_CURRENT_MARSHRUT
    ○ skipped MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W0_STALE_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT
    ○ skipped MIGRACIYA_G0_F03_ONBOARDING_DARK
    ○ skipped MIGRACIYA_G0_F03_ONBOARDING_LIGHT
    ○ skipped MIGRACIYA_G0_F03_DOPUSK_DARK
    ○ skipped MIGRACIYA_G0_F03_DOPUSK_LIGHT

Test Suites: 1 passed, 1 total
Tests:       44 skipped, 1 passed, 45 total
Snapshots:   0 total
Time:        0.982 s, estimated 3 s
Ran all test suites within paths "/tmp/dev-harness-verify/Critic117v3b/Rwitness/mobile/src/bootstrap/__tests__/vkhod-117.probe.test.tsx".
Test results written to: ../../tmp/tmpoxac1nc6.json

rc=0
```

### new-light-gate-default-legacy

```text
$ node <R>/mobile/node_modules/jest/bin/jest.js --ci --runInBand --runTestsByPath <R>/mobile/src/bootstrap/__tests__/pilot.test.tsx --json
PASS src/bootstrap/__tests__/pilot.test.tsx
  995 pilot
    ✓ DIRECT_unknown (95 ms)
    ✓ DIRECT_incomplete (9 ms)
    ✓ INVALID_CODE (14 ms)
    ✓ RESEND_UNCONFIRMED (144 ms)
    ✓ RESEND_CONFIRMED (6 ms)
    ✓ RESEND_COOLDOWN (5 ms)
    ✓ EMAIL_STALE (149 ms)
    ✓ RECOVERY_A07 (10 ms)
    ✓ AUTH_stale (9 ms)
    ✓ AUTH_revoked (9 ms)
    ✓ AUTH_missing_scope (8 ms)
    ✓ SECRET (5 ms)
    ✓ REPLAY (6 ms)
    ✓ DEFAULT_OFFLINE (14 ms)

Test Suites: 1 passed, 1 total
Tests:       14 passed, 14 total
Snapshots:   0 total
Time:        1.246 s, estimated 3 s
Ran all test suites within paths "/tmp/dev-harness-verify/Critic117v3b/Rregression/mobile/src/bootstrap/__tests__/pilot.test.tsx".
Test results written to: ../../tmp/tmpuxuncg9d.json

rc=0
$ python3 /tmp/dev-harness-verify/Critic117v3b/repo/fixtures/workshop_project/first_run_111/first_run_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rregression
case CTA_OPENS_F03_01_DARK
case CTA_OPENS_F03_01_LIGHT
case CTA_TEXT_EQUALS_FRAME_TITLE
case DEMO_BADGE_INSET_DARK
case DEMO_BADGE_INSET_LIGHT
case FIRST_RUN_COPY_CLOSED_DARK
case FIRST_RUN_COPY_CLOSED_LIGHT
case FIRST_RUN_GROUND_FULL_SURFACE_DARK
case FIRST_RUN_GROUND_FULL_SURFACE_LIGHT
case FIRST_RUN_STRUCTURE_DARK
case FIRST_RUN_STRUCTURE_LIGHT
case RESTYLE_GUARD_995_F03_01_DARK
case RESTYLE_GUARD_995_F03_01_LIGHT
case RESTYLE_GUARD_995_RECOVERY_DARK
case RESTYLE_GUARD_995_RECOVERY_LIGHT
case RESTYLE_GUARD_995_UNAVAILABLE_DARK
case RESTYLE_GUARD_995_UNAVAILABLE_LIGHT
case RESTYLE_GUARD_995_WELCOME_DARK
case RESTYLE_GUARD_995_WELCOME_LIGHT
case SAFEAREA_EDGES_ACTIVE_DARK
case SAFEAREA_EDGES_ACTIVE_LIGHT
case WORDMARK_SOURCE_BOUND_DARK
case WORDMARK_SOURCE_BOUND_LIGHT
honest 23/23

rc=0
```

### new-empty-session-demo-control

```text
$ python3 witness.py # new-empty-session-demo-control
  console.log
    HONEST_CONTROL: denied path reaches auth-code; Start absent

      at Object.log (src/bootstrap/__tests__/vkhod-117.probe.test.tsx:921:251)

PASS src/bootstrap/__tests__/vkhod-117.probe.test.tsx
  117 vkhod
    ✓ CRITIC_WITNESS (118 ms)
    ○ skipped RESTYLE_GUARD_995_F03_DARK
    ○ skipped RESTYLE_GUARD_995_F03_LIGHT
    ○ skipped RESTYLE_GUARD_995_WELCOME_DARK
    ○ skipped RESTYLE_GUARD_995_WELCOME_LIGHT
    ○ skipped RESTYLE_GUARD_995_RECOVERY_DARK
    ○ skipped RESTYLE_GUARD_995_RECOVERY_LIGHT
    ○ skipped RESTYLE_GUARD_995_UNAVAILABLE_DARK
    ○ skipped RESTYLE_GUARD_995_UNAVAILABLE_LIGHT
    ○ skipped PROD_ENTRY_OS_THEME_DARK
    ○ skipped PROD_ENTRY_OS_THEME_LIGHT
    ○ skipped STATUS_BAR_STYLE_DARK
    ○ skipped STATUS_BAR_STYLE_LIGHT
    ○ skipped SPLASH_OVERLAY_CONTAIN_DARK
    ○ skipped SPLASH_OVERLAY_CONTAIN_LIGHT
    ○ skipped SPLASH_OVERLAY_GEOMETRY_DARK
    ○ skipped SPLASH_OVERLAY_GEOMETRY_LIGHT
    ○ skipped SPLASH_OVERLAY_ZORDER_DARK
    ○ skipped SPLASH_OVERLAY_ZORDER_LIGHT
    ○ skipped SPLASH_OVERLAY_MOUNTED_DARK
    ○ skipped SPLASH_OVERLAY_MOUNTED_LIGHT
    ○ skipped SPLASH_OVERLAY_COMPOSITE_DARK
    ○ skipped SPLASH_OVERLAY_COMPOSITE_LIGHT
    ○ skipped SPLASH_OVERLAY_VISIBLE_DARK
    ○ skipped SPLASH_OVERLAY_VISIBLE_LIGHT
    ○ skipped SPLASH_OVERLAY_NO_TEXT_DARK
    ○ skipped SPLASH_OVERLAY_NO_TEXT_LIGHT
    ○ skipped SPLASH_HIDEASYNC_ORDER_DARK
    ○ skipped SPLASH_HIDEASYNC_ORDER_LIGHT
    ○ skipped SPLASH_OVERLAY_TIMER_HIDE_DARK
    ○ skipped SPLASH_OVERLAY_TIMER_HIDE_LIGHT
    ○ skipped MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_NULL_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_STALE_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_CURRENT_MARSHRUT
    ○ skipped MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W0_STALE_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT
    ○ skipped MIGRACIYA_G0_F03_ONBOARDING_DARK
    ○ skipped MIGRACIYA_G0_F03_ONBOARDING_LIGHT
    ○ skipped MIGRACIYA_G0_F03_DOPUSK_DARK
    ○ skipped MIGRACIYA_G0_F03_DOPUSK_LIGHT

Test Suites: 1 passed, 1 total
Tests:       44 skipped, 1 passed, 45 total
Snapshots:   0 total
Time:        0.937 s, estimated 1 s
Ran all test suites within paths "/tmp/dev-harness-verify/Critic117v3b/Rwitness/mobile/src/bootstrap/__tests__/vkhod-117.probe.test.tsx".
Test results written to: ../../tmp/tmp_cqq5s6j.json

rc=0
```

### new-empty-session-demo-witness

```text
$ python3 witness.py # new-empty-session-demo-witness
  console.log
    BYPASS_OBSERVED: Start reached without admission/current

      at Object.log (src/bootstrap/__tests__/vkhod-117.probe.test.tsx:921:317)

PASS src/bootstrap/__tests__/vkhod-117.probe.test.tsx
  117 vkhod
    ✓ CRITIC_WITNESS (97 ms)
    ○ skipped RESTYLE_GUARD_995_F03_DARK
    ○ skipped RESTYLE_GUARD_995_F03_LIGHT
    ○ skipped RESTYLE_GUARD_995_WELCOME_DARK
    ○ skipped RESTYLE_GUARD_995_WELCOME_LIGHT
    ○ skipped RESTYLE_GUARD_995_RECOVERY_DARK
    ○ skipped RESTYLE_GUARD_995_RECOVERY_LIGHT
    ○ skipped RESTYLE_GUARD_995_UNAVAILABLE_DARK
    ○ skipped RESTYLE_GUARD_995_UNAVAILABLE_LIGHT
    ○ skipped PROD_ENTRY_OS_THEME_DARK
    ○ skipped PROD_ENTRY_OS_THEME_LIGHT
    ○ skipped STATUS_BAR_STYLE_DARK
    ○ skipped STATUS_BAR_STYLE_LIGHT
    ○ skipped SPLASH_OVERLAY_CONTAIN_DARK
    ○ skipped SPLASH_OVERLAY_CONTAIN_LIGHT
    ○ skipped SPLASH_OVERLAY_GEOMETRY_DARK
    ○ skipped SPLASH_OVERLAY_GEOMETRY_LIGHT
    ○ skipped SPLASH_OVERLAY_ZORDER_DARK
    ○ skipped SPLASH_OVERLAY_ZORDER_LIGHT
    ○ skipped SPLASH_OVERLAY_MOUNTED_DARK
    ○ skipped SPLASH_OVERLAY_MOUNTED_LIGHT
    ○ skipped SPLASH_OVERLAY_COMPOSITE_DARK
    ○ skipped SPLASH_OVERLAY_COMPOSITE_LIGHT
    ○ skipped SPLASH_OVERLAY_VISIBLE_DARK
    ○ skipped SPLASH_OVERLAY_VISIBLE_LIGHT
    ○ skipped SPLASH_OVERLAY_NO_TEXT_DARK
    ○ skipped SPLASH_OVERLAY_NO_TEXT_LIGHT
    ○ skipped SPLASH_HIDEASYNC_ORDER_DARK
    ○ skipped SPLASH_HIDEASYNC_ORDER_LIGHT
    ○ skipped SPLASH_OVERLAY_TIMER_HIDE_DARK
    ○ skipped SPLASH_OVERLAY_TIMER_HIDE_LIGHT
    ○ skipped MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_NULL_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_STALE_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_CURRENT_MARSHRUT
    ○ skipped MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W0_STALE_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT
    ○ skipped MIGRACIYA_G0_F03_ONBOARDING_DARK
    ○ skipped MIGRACIYA_G0_F03_ONBOARDING_LIGHT
    ○ skipped MIGRACIYA_G0_F03_DOPUSK_DARK
    ○ skipped MIGRACIYA_G0_F03_DOPUSK_LIGHT

Test Suites: 1 passed, 1 total
Tests:       44 skipped, 1 passed, 45 total
Snapshots:   0 total
Time:        0.901 s, estimated 1 s
Ran all test suites within paths "/tmp/dev-harness-verify/Critic117v3b/Rwitness/mobile/src/bootstrap/__tests__/vkhod-117.probe.test.tsx".
Test results written to: ../../tmp/tmpexbjribb.json

rc=0
```

### new-empty-session-demo-legacy

```text
$ node <R>/mobile/node_modules/jest/bin/jest.js --ci --runInBand --runTestsByPath <R>/mobile/src/bootstrap/__tests__/pilot.test.tsx --json
PASS src/bootstrap/__tests__/pilot.test.tsx
  995 pilot
    ✓ DIRECT_unknown (81 ms)
    ✓ DIRECT_incomplete (6 ms)
    ✓ INVALID_CODE (7 ms)
    ✓ RESEND_UNCONFIRMED (142 ms)
    ✓ RESEND_CONFIRMED (5 ms)
    ✓ RESEND_COOLDOWN (6 ms)
    ✓ EMAIL_STALE (144 ms)
    ✓ RECOVERY_A07 (5 ms)
    ✓ AUTH_stale (7 ms)
    ✓ AUTH_revoked (6 ms)
    ✓ AUTH_missing_scope (7 ms)
    ✓ SECRET (6 ms)
    ✓ REPLAY (5 ms)
    ✓ DEFAULT_OFFLINE (13 ms)

Test Suites: 1 passed, 1 total
Tests:       14 passed, 14 total
Snapshots:   0 total
Time:        1.071 s, estimated 2 s
Ran all test suites within paths "/tmp/dev-harness-verify/Critic117v3b/Rregression/mobile/src/bootstrap/__tests__/pilot.test.tsx".
Test results written to: ../../tmp/tmpr9znpgqk.json

rc=0
$ python3 /tmp/dev-harness-verify/Critic117v3b/repo/fixtures/workshop_project/first_run_111/first_run_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rregression
case CTA_OPENS_F03_01_DARK
case CTA_OPENS_F03_01_LIGHT
case CTA_TEXT_EQUALS_FRAME_TITLE
case DEMO_BADGE_INSET_DARK
case DEMO_BADGE_INSET_LIGHT
case FIRST_RUN_COPY_CLOSED_DARK
case FIRST_RUN_COPY_CLOSED_LIGHT
case FIRST_RUN_GROUND_FULL_SURFACE_DARK
case FIRST_RUN_GROUND_FULL_SURFACE_LIGHT
case FIRST_RUN_STRUCTURE_DARK
case FIRST_RUN_STRUCTURE_LIGHT
case RESTYLE_GUARD_995_F03_01_DARK
case RESTYLE_GUARD_995_F03_01_LIGHT
case RESTYLE_GUARD_995_RECOVERY_DARK
case RESTYLE_GUARD_995_RECOVERY_LIGHT
case RESTYLE_GUARD_995_UNAVAILABLE_DARK
case RESTYLE_GUARD_995_UNAVAILABLE_LIGHT
case RESTYLE_GUARD_995_WELCOME_DARK
case RESTYLE_GUARD_995_WELCOME_LIGHT
case SAFEAREA_EDGES_ACTIVE_DARK
case SAFEAREA_EDGES_ACTIVE_LIGHT
case WORDMARK_SOURCE_BOUND_DARK
case WORDMARK_SOURCE_BOUND_LIGHT
honest 23/23

rc=0
```

### new-g0-denied-admission-control

```text
$ python3 witness.py # new-g0-denied-admission-control
  console.log
    HONEST_CONTROL: F03 white root paddingTop=48

      at Object.log (src/bootstrap/__tests__/vkhod-117.probe.test.tsx:921:397)

PASS src/bootstrap/__tests__/vkhod-117.probe.test.tsx
  117 vkhod
    ✓ CRITIC_WITNESS (108 ms)
    ○ skipped RESTYLE_GUARD_995_F03_DARK
    ○ skipped RESTYLE_GUARD_995_F03_LIGHT
    ○ skipped RESTYLE_GUARD_995_WELCOME_DARK
    ○ skipped RESTYLE_GUARD_995_WELCOME_LIGHT
    ○ skipped RESTYLE_GUARD_995_RECOVERY_DARK
    ○ skipped RESTYLE_GUARD_995_RECOVERY_LIGHT
    ○ skipped RESTYLE_GUARD_995_UNAVAILABLE_DARK
    ○ skipped RESTYLE_GUARD_995_UNAVAILABLE_LIGHT
    ○ skipped PROD_ENTRY_OS_THEME_DARK
    ○ skipped PROD_ENTRY_OS_THEME_LIGHT
    ○ skipped STATUS_BAR_STYLE_DARK
    ○ skipped STATUS_BAR_STYLE_LIGHT
    ○ skipped SPLASH_OVERLAY_CONTAIN_DARK
    ○ skipped SPLASH_OVERLAY_CONTAIN_LIGHT
    ○ skipped SPLASH_OVERLAY_GEOMETRY_DARK
    ○ skipped SPLASH_OVERLAY_GEOMETRY_LIGHT
    ○ skipped SPLASH_OVERLAY_ZORDER_DARK
    ○ skipped SPLASH_OVERLAY_ZORDER_LIGHT
    ○ skipped SPLASH_OVERLAY_MOUNTED_DARK
    ○ skipped SPLASH_OVERLAY_MOUNTED_LIGHT
    ○ skipped SPLASH_OVERLAY_COMPOSITE_DARK
    ○ skipped SPLASH_OVERLAY_COMPOSITE_LIGHT
    ○ skipped SPLASH_OVERLAY_VISIBLE_DARK
    ○ skipped SPLASH_OVERLAY_VISIBLE_LIGHT
    ○ skipped SPLASH_OVERLAY_NO_TEXT_DARK
    ○ skipped SPLASH_OVERLAY_NO_TEXT_LIGHT
    ○ skipped SPLASH_HIDEASYNC_ORDER_DARK
    ○ skipped SPLASH_HIDEASYNC_ORDER_LIGHT
    ○ skipped SPLASH_OVERLAY_TIMER_HIDE_DARK
    ○ skipped SPLASH_OVERLAY_TIMER_HIDE_LIGHT
    ○ skipped MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_NULL_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_STALE_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_CURRENT_MARSHRUT
    ○ skipped MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W0_STALE_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT
    ○ skipped MIGRACIYA_G0_F03_ONBOARDING_DARK
    ○ skipped MIGRACIYA_G0_F03_ONBOARDING_LIGHT
    ○ skipped MIGRACIYA_G0_F03_DOPUSK_DARK
    ○ skipped MIGRACIYA_G0_F03_DOPUSK_LIGHT

Test Suites: 1 passed, 1 total
Tests:       44 skipped, 1 passed, 45 total
Snapshots:   0 total
Time:        0.809 s, estimated 1 s
Ran all test suites within paths "/tmp/dev-harness-verify/Critic117v3b/Rwitness/mobile/src/bootstrap/__tests__/vkhod-117.probe.test.tsx".
Test results written to: ../../tmp/tmpaj5_8qdw.json

rc=0
```

### new-g0-denied-admission-witness

```text
$ python3 witness.py # new-g0-denied-admission-witness
  console.log
    BYPASS_OBSERVED: F03 black root paddingTop=0

      at Object.log (src/bootstrap/__tests__/vkhod-117.probe.test.tsx:921:396)

PASS src/bootstrap/__tests__/vkhod-117.probe.test.tsx
  117 vkhod
    ✓ CRITIC_WITNESS (92 ms)
    ○ skipped RESTYLE_GUARD_995_F03_DARK
    ○ skipped RESTYLE_GUARD_995_F03_LIGHT
    ○ skipped RESTYLE_GUARD_995_WELCOME_DARK
    ○ skipped RESTYLE_GUARD_995_WELCOME_LIGHT
    ○ skipped RESTYLE_GUARD_995_RECOVERY_DARK
    ○ skipped RESTYLE_GUARD_995_RECOVERY_LIGHT
    ○ skipped RESTYLE_GUARD_995_UNAVAILABLE_DARK
    ○ skipped RESTYLE_GUARD_995_UNAVAILABLE_LIGHT
    ○ skipped PROD_ENTRY_OS_THEME_DARK
    ○ skipped PROD_ENTRY_OS_THEME_LIGHT
    ○ skipped STATUS_BAR_STYLE_DARK
    ○ skipped STATUS_BAR_STYLE_LIGHT
    ○ skipped SPLASH_OVERLAY_CONTAIN_DARK
    ○ skipped SPLASH_OVERLAY_CONTAIN_LIGHT
    ○ skipped SPLASH_OVERLAY_GEOMETRY_DARK
    ○ skipped SPLASH_OVERLAY_GEOMETRY_LIGHT
    ○ skipped SPLASH_OVERLAY_ZORDER_DARK
    ○ skipped SPLASH_OVERLAY_ZORDER_LIGHT
    ○ skipped SPLASH_OVERLAY_MOUNTED_DARK
    ○ skipped SPLASH_OVERLAY_MOUNTED_LIGHT
    ○ skipped SPLASH_OVERLAY_COMPOSITE_DARK
    ○ skipped SPLASH_OVERLAY_COMPOSITE_LIGHT
    ○ skipped SPLASH_OVERLAY_VISIBLE_DARK
    ○ skipped SPLASH_OVERLAY_VISIBLE_LIGHT
    ○ skipped SPLASH_OVERLAY_NO_TEXT_DARK
    ○ skipped SPLASH_OVERLAY_NO_TEXT_LIGHT
    ○ skipped SPLASH_HIDEASYNC_ORDER_DARK
    ○ skipped SPLASH_HIDEASYNC_ORDER_LIGHT
    ○ skipped SPLASH_OVERLAY_TIMER_HIDE_DARK
    ○ skipped SPLASH_OVERLAY_TIMER_HIDE_LIGHT
    ○ skipped MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_NULL_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_STALE_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_CURRENT_MARSHRUT
    ○ skipped MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W0_STALE_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT
    ○ skipped MIGRACIYA_G0_F03_ONBOARDING_DARK
    ○ skipped MIGRACIYA_G0_F03_ONBOARDING_LIGHT
    ○ skipped MIGRACIYA_G0_F03_DOPUSK_DARK
    ○ skipped MIGRACIYA_G0_F03_DOPUSK_LIGHT

Test Suites: 1 passed, 1 total
Tests:       44 skipped, 1 passed, 45 total
Snapshots:   0 total
Time:        0.801 s, estimated 1 s
Ran all test suites within paths "/tmp/dev-harness-verify/Critic117v3b/Rwitness/mobile/src/bootstrap/__tests__/vkhod-117.probe.test.tsx".
Test results written to: ../../tmp/tmpu58wr7ct.json

rc=0
```

### new-g0-denied-admission-legacy

```text
$ node <R>/mobile/node_modules/jest/bin/jest.js --ci --runInBand --runTestsByPath <R>/mobile/src/bootstrap/__tests__/pilot.test.tsx --json
PASS src/bootstrap/__tests__/pilot.test.tsx
  995 pilot
    ✓ DIRECT_unknown (83 ms)
    ✓ DIRECT_incomplete (8 ms)
    ✓ INVALID_CODE (7 ms)
    ✓ RESEND_UNCONFIRMED (142 ms)
    ✓ RESEND_CONFIRMED (6 ms)
    ✓ RESEND_COOLDOWN (7 ms)
    ✓ EMAIL_STALE (147 ms)
    ✓ RECOVERY_A07 (7 ms)
    ✓ AUTH_stale (7 ms)
    ✓ AUTH_revoked (6 ms)
    ✓ AUTH_missing_scope (6 ms)
    ✓ SECRET (6 ms)
    ✓ REPLAY (6 ms)
    ✓ DEFAULT_OFFLINE (14 ms)

Test Suites: 1 passed, 1 total
Tests:       14 passed, 14 total
Snapshots:   0 total
Time:        1.074 s
Ran all test suites within paths "/tmp/dev-harness-verify/Critic117v3b/Rregression/mobile/src/bootstrap/__tests__/pilot.test.tsx".
Test results written to: ../../tmp/tmpr8aqe5q6.json

rc=0
$ python3 /tmp/dev-harness-verify/Critic117v3b/repo/fixtures/workshop_project/first_run_111/first_run_probe.py --repo /tmp/dev-harness-verify/Critic117v3b/Rregression
case CTA_OPENS_F03_01_DARK
case CTA_OPENS_F03_01_LIGHT
case CTA_TEXT_EQUALS_FRAME_TITLE
case DEMO_BADGE_INSET_DARK
case DEMO_BADGE_INSET_LIGHT
case FIRST_RUN_COPY_CLOSED_DARK
case FIRST_RUN_COPY_CLOSED_LIGHT
case FIRST_RUN_GROUND_FULL_SURFACE_DARK
case FIRST_RUN_GROUND_FULL_SURFACE_LIGHT
case FIRST_RUN_STRUCTURE_DARK
case FIRST_RUN_STRUCTURE_LIGHT
case RESTYLE_GUARD_995_F03_01_DARK
case RESTYLE_GUARD_995_F03_01_LIGHT
case RESTYLE_GUARD_995_RECOVERY_DARK
case RESTYLE_GUARD_995_RECOVERY_LIGHT
case RESTYLE_GUARD_995_UNAVAILABLE_DARK
case RESTYLE_GUARD_995_UNAVAILABLE_LIGHT
case RESTYLE_GUARD_995_WELCOME_DARK
case RESTYLE_GUARD_995_WELCOME_LIGHT
case SAFEAREA_EDGES_ACTIVE_DARK
case SAFEAREA_EDGES_ACTIVE_LIGHT
case WORDMARK_SOURCE_BOUND_DARK
case WORDMARK_SOURCE_BOUND_LIGHT
honest 23/23

rc=0
```

## Независимый smoke полного шва

Дополнительно к критерию автора исполнен собственный одноразовый RNTL-smoke всех **24** сочетаний объявленного admission × gate × theme. Он наблюдает Г0 на email и на отвергнутом demo/code; на W1A/current — Erstinformation, отсутствие Start до continue и Start после continue. Это не правка батареи автора.

Команда `python3 /tmp/dev-harness-verify/Critic117v3b/admission_matrix_smoke.py` на честной модели: **24/24, rc 0**. Команда `python3 /tmp/dev-harness-verify/Critic117v3b/mutant_matrix_smoke.py` на каждом из трёх пропущенных мутантов: **rc 1**, конкретные красные входы ниже. В отличие от свидетеля наличия дефекта, этот smoke утверждает правильное поведение и именно поэтому краснеет на мутанте. Сырой Jest-вывод каждого — `<имя>-independent-matrix.log` в своей области.

Независимый разбор исходного `vkhod.test.tsx` командой `python3 /tmp/dev-harness-verify/Critic117v3b/input_inventory.py` показывает: лишь **11/24** подключённых сочетаний достигнуты через `toEmailOnboarding`; 13, включая `{}` и W1A×отсутствующий gate×light, отсутствуют. `renderApp` без onboarding не создаёт подключённый пустой порт `{}`, поэтому не заполняет эту дыру. Сырой инвентарь:

```text
Connected onboarding inputs explicitly exercised by toEmailOnboarding: 11/24
covered ('ABSENT', 'current', 'dark')
covered ('W0', 'current', 'dark')
covered ('W0', 'current', 'light')
covered ('W0', 'null', 'light')
covered ('W0', 'stale', 'dark')
covered ('W1A', 'ABSENT', 'dark')
covered ('W1A', 'current', 'dark')
covered ('W1A', 'current', 'light')
covered ('W1A', 'null', 'dark')
covered ('W1A', 'stale', 'dark')
covered ('W1A', 'stale', 'light')
missing ('ABSENT', 'ABSENT', 'dark')
missing ('ABSENT', 'ABSENT', 'light')
missing ('ABSENT', 'current', 'light')
missing ('ABSENT', 'null', 'dark')
missing ('ABSENT', 'null', 'light')
missing ('ABSENT', 'stale', 'dark')
missing ('ABSENT', 'stale', 'light')
missing ('W0', 'ABSENT', 'dark')
missing ('W0', 'ABSENT', 'light')
missing ('W0', 'null', 'dark')
missing ('W0', 'stale', 'light')
missing ('W1A', 'ABSENT', 'light')
missing ('W1A', 'null', 'light')
Legacy renderApp without onboarding is not a connected empty object and does not fill ABSENT/ABSENT.
```

```text
new-light-gate-default: total=24 red=['CRITIC_MATRIX_W1A_None_light'] rc=1
new-empty-session-demo: total=24 red=['CRITIC_MATRIX_None_None_dark', 'CRITIC_MATRIX_None_None_light'] rc=1
new-g0-denied-admission: total=24 red=['CRITIC_MATRIX_None_None_dark', 'CRITIC_MATRIX_None_None_light', 'CRITIC_MATRIX_None_null_dark', 'CRITIC_MATRIX_None_null_light', 'CRITIC_MATRIX_None_stale_dark', 'CRITIC_MATRIX_None_stale_light', 'CRITIC_MATRIX_W0_None_dark', 'CRITIC_MATRIX_W0_None_light', 'CRITIC_MATRIX_W0_null_dark', 'CRITIC_MATRIX_W0_null_light', 'CRITIC_MATRIX_W0_stale_dark', 'CRITIC_MATRIX_W0_stale_light', 'CRITIC_MATRIX_W1A_None_dark', 'CRITIC_MATRIX_W1A_None_light', 'CRITIC_MATRIX_W1A_null_dark', 'CRITIC_MATRIX_W1A_null_light', 'CRITIC_MATRIX_W1A_stale_dark', 'CRITIC_MATRIX_W1A_stale_light'] rc=1
```

Сырой прогон честной матрицы:

```text
$ python3 /tmp/dev-harness-verify/Critic117v3b/admission_matrix_smoke.py
PASS src/bootstrap/__tests__/vkhod-117.probe.test.tsx
  117 vkhod
    ✓ CRITIC_MATRIX_None_None_dark (165 ms)
    ✓ CRITIC_MATRIX_None_None_light (5 ms)
    ✓ CRITIC_MATRIX_None_null_dark (5 ms)
    ✓ CRITIC_MATRIX_None_null_light (5 ms)
    ✓ CRITIC_MATRIX_None_stale_dark (4 ms)
    ✓ CRITIC_MATRIX_None_stale_light (5 ms)
    ✓ CRITIC_MATRIX_None_current_dark (4 ms)
    ✓ CRITIC_MATRIX_None_current_light (4 ms)
    ✓ CRITIC_MATRIX_W0_None_dark (4 ms)
    ✓ CRITIC_MATRIX_W0_None_light (13 ms)
    ✓ CRITIC_MATRIX_W0_null_dark (13 ms)
    ✓ CRITIC_MATRIX_W0_null_light (15 ms)
    ✓ CRITIC_MATRIX_W0_stale_dark (10 ms)
    ✓ CRITIC_MATRIX_W0_stale_light (11 ms)
    ✓ CRITIC_MATRIX_W0_current_dark (5 ms)
    ✓ CRITIC_MATRIX_W0_current_light (3 ms)
    ✓ CRITIC_MATRIX_W1A_None_dark (4 ms)
    ✓ CRITIC_MATRIX_W1A_None_light (4 ms)
    ✓ CRITIC_MATRIX_W1A_null_dark (3 ms)
    ✓ CRITIC_MATRIX_W1A_null_light (4 ms)
    ✓ CRITIC_MATRIX_W1A_stale_dark (4 ms)
    ✓ CRITIC_MATRIX_W1A_stale_light (4 ms)
    ✓ CRITIC_MATRIX_W1A_current_dark (3 ms)
    ✓ CRITIC_MATRIX_W1A_current_light (4 ms)
    ○ skipped RESTYLE_GUARD_995_F03_DARK
    ○ skipped RESTYLE_GUARD_995_F03_LIGHT
    ○ skipped RESTYLE_GUARD_995_WELCOME_DARK
    ○ skipped RESTYLE_GUARD_995_WELCOME_LIGHT
    ○ skipped RESTYLE_GUARD_995_RECOVERY_DARK
    ○ skipped RESTYLE_GUARD_995_RECOVERY_LIGHT
    ○ skipped RESTYLE_GUARD_995_UNAVAILABLE_DARK
    ○ skipped RESTYLE_GUARD_995_UNAVAILABLE_LIGHT
    ○ skipped PROD_ENTRY_OS_THEME_DARK
    ○ skipped PROD_ENTRY_OS_THEME_LIGHT
    ○ skipped STATUS_BAR_STYLE_DARK
    ○ skipped STATUS_BAR_STYLE_LIGHT
    ○ skipped SPLASH_OVERLAY_CONTAIN_DARK
    ○ skipped SPLASH_OVERLAY_CONTAIN_LIGHT
    ○ skipped SPLASH_OVERLAY_GEOMETRY_DARK
    ○ skipped SPLASH_OVERLAY_GEOMETRY_LIGHT
    ○ skipped SPLASH_OVERLAY_ZORDER_DARK
    ○ skipped SPLASH_OVERLAY_ZORDER_LIGHT
    ○ skipped SPLASH_OVERLAY_MOUNTED_DARK
    ○ skipped SPLASH_OVERLAY_MOUNTED_LIGHT
    ○ skipped SPLASH_OVERLAY_COMPOSITE_DARK
    ○ skipped SPLASH_OVERLAY_COMPOSITE_LIGHT
    ○ skipped SPLASH_OVERLAY_VISIBLE_DARK
    ○ skipped SPLASH_OVERLAY_VISIBLE_LIGHT
    ○ skipped SPLASH_OVERLAY_NO_TEXT_DARK
    ○ skipped SPLASH_OVERLAY_NO_TEXT_LIGHT
    ○ skipped SPLASH_HIDEASYNC_ORDER_DARK
    ○ skipped SPLASH_HIDEASYNC_ORDER_LIGHT
    ○ skipped SPLASH_OVERLAY_TIMER_HIDE_DARK
    ○ skipped SPLASH_OVERLAY_TIMER_HIDE_LIGHT
    ○ skipped MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_NULL_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_STALE_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_CURRENT_MARSHRUT
    ○ skipped MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W0_STALE_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT
    ○ skipped MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT
    ○ skipped MIGRACIYA_G0_F03_ONBOARDING_DARK
    ○ skipped MIGRACIYA_G0_F03_ONBOARDING_LIGHT
    ○ skipped MIGRACIYA_G0_F03_DOPUSK_DARK
    ○ skipped MIGRACIYA_G0_F03_DOPUSK_LIGHT

Test Suites: 1 passed, 1 total
Tests:       44 skipped, 24 passed, 68 total
Snapshots:   0 total
Time:        1.52 s
Ran all test suites within paths "/tmp/dev-harness-verify/Critic117v3b/Rwitness/mobile/src/bootstrap/__tests__/vkhod-117.probe.test.tsx".
Test results written to: ../../tmp/tmp4h_yb75f.json

rc=0
```

## Предел доказательства и доставка

Судится текст/красная батарея, не продуктовая готовность 118. Android/PNG на телефоне, полный CI, lint/typecheck не запускались; scoped-регрессии и наблюдение пути/корня через настоящий Jest/RNTL выполнены. Никакого ослабления приёмки 118 этот вердикт не разрешает. Контракт, тесты автора и чужие файлы не редактировались. Коммит/push не выполнялись по адресному запрету задания; для freeze требуется дальнейшее приземление вердикта оркестратором, но этот FAIL заморозку не разрешает.
