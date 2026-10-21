FAIL
Контракт 117, круг критика 3. OBJECT=a378b15cab34543c1ec2f2a8c9a9de96360a359f.
База продукта B=8748a7a3352c14a6caa5a75b71f869e5d3b8152c. Судился закоммиченный предмет в собственном клоне на OBJECT, не рабочее дерево автора. Набор артефактов полон: предмет, команды готовности, исполнители, зоны, модель угроз присутствуют.

К ВЛАДЕЛЬЦУ через консультанта: после решения арбитра остались невыполненными свойства Б1, Б2 и С2 закрытого перечня. Нового арбитража или ещё одного круга автора этим вердиктом НЕ назначаю. Основание — последний абзац §4 verdicts/arbitration/contracts-117-splash-vhod-krug2.md. Вопросы владельцу о платформенном смещении знака и Expo Go не переоткрываются.

## Блокирующие находки — только закрытый перечень

### Б1. Recall вычисляется не по всей маске эталона

БЛОКИРУЕТ contracts/117-cmp-mob-vkhod-splash.md:165 — требование recall/precision ≥0.98 по ЦЕЛОЙ маске, прямо предписанное арбитражем §3 Б1 и §4 Б1, не выполнено. Уменьшение субъекта уменьшает одновременно и множество проверяемых пикселей эталона.
ОБХОД: оба композита заменить PNG 195×422, выбирая из честного композита пиксель (2x,2y) для каждого пикселя результата. Aspect ТОЧНО 390:844, масштаб 1/2 разрешён формулировкой арбитра. Остальное — честная модель. Обе пробы без --model возвращают rc0: static 33/33, behavioral 20/20. Сама клетка сообщает recall=precision=1.0, но считает только 3876/3853 выбранных пикселя маски вместо полных 15439/15346. Независимый проход по ВСЕМ пикселям E при той же nearest-проекции даёт recall 0.880238/0.881924, precision 0.947110/0.945497 — ниже обоих порогов.

Причина: fixtures/workshop_project/vkhod_117/vkhod_static_probe.py:503–510 — внешний цикл по размеру C; m_op увеличивается только для образцов E, выбранных решёткой C. Это не доля всего M. Свидетели: exact-mask.py, exact-mask.json, halfres-{dark,light}.png, B1-halfres-vkhod_{static_probe,probe}.log. Дополнительный наглядный свидетель 39×84 тоже проходит обе пробы; PNG открыт просмотрщиком, надписи превратились в точки. Для блокировки достаточно ТОЧНОГО aspect 195×422, а не допуска размеров второго свидетеля.

Старые стабы действительно красны: буквальные семь пикселей — rc1; без надписей и сдвиг 9 — красны SPLASH_COMPOSITE_ETALON обеих тем. Это закрывает старые примеры, но не предписанное свойство полной маски.

### Б2. Не выполнено явное условие iOS «enableFullScreenImage_legacy отсутствует»

БЛОКИРУЕТ contracts/117-cmp-mob-vkhod-splash.md:158 — эффективные imageWidth/resizeMode проверяются, но исключение legacy-режима из §3 Б2 арбитража потеряно. Это пункт закрытого перечня, а не новый способ настройки, придуманный вне него.
ОБХОД: в props expo-splash-screen честной модели добавить ios: { enableFullScreenImage_legacy: true }, сохранив эффективные imageWidth=181, resizeMode=contain и оба честных знака. Static rc0, 33/33; behavioral rc0, 20/20. Настоящие getIosSplashConfig + applySplashScreenStoryboard на этом состоянии дают Image frame 414×736 с четырьмя краевыми constraints вместо честного 181×181 с centerX/centerY. Таким образом, проверяемый литерал 181 больше не определяет фактическую рамку картинки.

Причина: vkhod_static_probe.py:809–811 и SPLASH_EFFECTIVE_JS не переносят/не проверяют enableFullScreenImage_legacy. Вызванный настоящий InterfaceBuilder.js выбирает ширину/высоту 414/736 при этом флаге. Свидетели: witness.py (B2-ios-legacy), boundaries.py, B2-ios-legacy-vkhod_static_probe.log, B2-ios-legacy-behavioral.log, ios-legacy.cjs, ios-legacy.json. node ios-legacy.cjs → rc0. Это замер сгенерированного storyboard, НЕ скриншот iOS-устройства.

### С2. Проверенный композит может вообще не показываться оверлеем

БЛОКИРУЕТ contracts/117-cmp-mob-vkhod-splash.md:190 — клетки С2 не связывают Image оверлея с тем композитом, содержимое которого проверено Б1. Арбитраж §2 п.2 и §4 С2 требует именно Image композита кадра окна.
ОБХОД: в PilotApp заменить ОБА require('../../assets/images/splash-composite-{dark,light}.png') внутри Image оверлея на require('../../assets/images/icon.png'); честные композиты оставить лежать на диске. Обе пробы без --model → rc0, static 33/33 и behavioral 20/20. Вместо Splash.png оверлей использует иконку без wordmark/tagline. Это отсутствие обязательного полного кадра, не допуск визуальной точности.

Причина: vkhod.test.tsx:449–457 проверяет наличие произвольного Image, не его source/режим/геометрию; статическая проба читает отдельные файлы композитов независимо от их потребления. Свидетели: witness.py, overlay-wrong-source.tsx, C2-overlay-wrong-source-vkhod_{static_probe,probe}.log.

### С2. «После prevent» не означает «после первого commit»

БЛОКИРУЕТ contracts/117-cmp-mob-vkhod-splash.md:194 — требование hideAsync ПОСЛЕ монтирования оверлея из §2 п.2 и §4 С2 арбитража заменено отношением вызовов hide/prevent. Объявление остаточного риска в строках 428–431 не отменяет этот пункт решения арбитра.
ОБХОД: убрать hideAsync из effect и вызвать его один раз в ленивом инициализаторе useState при render PilotApp. Оверлей, таймер и prevent на модуле остаются честными. Обе пробы → rc0, static 33/33, behavioral 20/20, включая SPLASH_HIDEASYNC_ORDER обеих тем, хотя hide уже произошёл ДО первого commit.

Порядок измерен независимо React.Profiler, а не угадан: временная commit-order.test.tsx на честной модели → rc0, журнал ["prevent","commit","hide"]; на мутанте → rc1, журнал ["prevent","hide","commit"]. Причина: vkhod.test.tsx:481–488 проверяет +1 hide за render и hide>prevent, но не наблюдает commit. Свидетели: overlay-hide-before-commit.tsx, C2-hide-before-commit-vkhod_{static_probe,probe}.log, commit-order-{honest,before-commit}.log, integration.py. Мигание на телефоне не измерялось и не выдаётся за наблюдение; нарушен непосредственно предписанный порядок жизненного цикла.

## Что закрыто и повторно не блокируется

- Б1: sha256-литералы обоих Splash-эталонов совпали с read-only docs/ базы. Подмена эталона → rc2 ORACLE_TAMPERED. На честной модели независимый Pillow-проход даёт recall/precision 1.0/1.0 для обеих тем. Семипиксельный/без-надписей/сдвиг-9 стабы красны одной семьёй SPLASH_COMPOSITE_ETALON. Открытым осталось свойство ВСЕЙ маски при масштабе субъекта — находка выше.
- Б2: вызываются настоящие getAndroidSplashConfig и setSplashImageDrawablesAsync; проверяются содержимое, размеры и обе темы всех пяти плотностей. Буквальный прежний обход с одинаковыми basename и шаблонными байтами в override/ → rc1, все десять generated-клеток красны. android.imageWidth=76 → rc1. Density overrides шаблоном сразу обеих тем/всех плотностей → rc1. iOS эффективный image, imageWidth=76, resizeMode=cover по отдельности → rc1. Басename больше не является критерием эффективного платформенного изображения. Открыт только явно запрещённый арбитром legacy-режим.
- Б3: в критерии названы release APK/android-e2e, assertVisible всех девяти строк состава × тема, gh pr checks; путь зоны implementer исправлен на mobile/.maestro/. Jest честно назван первой линией, «layout в Jest не вычисляется» записано в НЕ ЗАЩИЩАЕТ. translateX:1000 красит обе В3 в матрице; независимый marginLeft:1000 → behavioral rc1, failed 2 of 20. Реальный Maestro-сценарий раздаётся ПОСЛЕ freeze — его отсутствие в авторской батарее не превращено в блокер.
- С1: среды разведены: Expo Go = иконка + JS-оверлей, нативный знак = release/dev-client, визуальная сверка = android-e2e release APK.
- С2/конструкция: модель использует нативный одиночный знак с imageWidth=181, dark-блок, оверлей sibling над деревом, без Text, таймер 1200 мс с cleanup; Frame не расширен. «Вне предмета: JS-КАДР state-machine» корректно. Стабы отсутствия оверлея/Text/пропущенного hide/таймера красны. Недостаточность связи Image и наблюдения commit — ровно две находки С2 выше.
- Регресс старых Б4: welcome/recovery/unavailable в обеих схемах наблюдаются; соответствующие стабы, включая recovery-light, красны. Подложные иконка/splash и ручные DS-подмены красны. Дословное слово владельца ~19:28 и реальные @/ui/button, @/ui/text-field сохранены.
- Советы прошлого круга исправлены: mobile/.maestro/, «RUN, ожидаемо rc1 ровно по К8», состав = таблица (маршруты UX-JSON + поверхность 995 + каталог). Миграция 111 v2 остаётся отдельной работой; её не требую в зоне 117.

## Совет, не влияющий на FAIL

СОВЕТ contracts/117-cmp-mob-vkhod-splash.md:288 — название авторского стаба platform-same-basename не описывает его мутацию: в vkhod_static_probe.py:1109–1111 меняется splash-sign-light.png на splash-composite-light.png, то есть basename различаются. Это не дополнительный блокер: мой независимый настоящий same-basename красен; свойство проверено. Желательно не предъявлять имя стаба как доказательство выполненной мутации.

## Живые команды и коды возврата

Все изменения и прогоны — в собственных disposable-копиях под /tmp/dev-harness-verify/Critic117r3/. H = harness на OBJECT; R = mob/witness-mob/mask-mob на B; mobile/node_modules — симлинк на установленный consultant-expo. Внешние деревья не менялись.

| Команда / сценарий | Наблюдение |
| --- | --- |
| bash scripts/check_provodka.sh H contracts/117-cmp-mob-vkhod-splash.md | rc0 |
| bash scripts/check_threat_model.sh H contracts/117-cmp-mob-vkhod-splash.md | rc0 |
| bash scripts/check_precision_gate.sh H contracts/117-cmp-mob-vkhod-splash.md | rc0, живой bash |
| bash scripts/pre_critic.sh contracts/117-cmp-mob-vkhod-splash.md | rc0 |
| python3 …/vkhod_static_probe.py --repo R --matrix | rc0, честная модель зелёная, 17 мутантов красны по именам |
| python3 …/vkhod_probe.py --repo R --matrix | rc0, honest green 20, 18 мутантов красны по именам |
| Б1: точные 195×422, обе пробы без --model | rc0 / rc0, 33/33 и 20/20 |
| Б1: дополнительный 39×84, обе пробы | rc0 / rc0 |
| Б1: буквальные семь пикселей | static rc1 |
| Б1: изменённый эталон docs/ | static rc2, ORACLE_TAMPERED |
| Б2: точный same-basename / android.imageWidth=76 / обе темы density-template | каждый static rc1 |
| Б2: iOS effective image / width / mode | каждый static rc1 |
| Б2: ios.enableFullScreenImage_legacy=true | static rc0, behavioral rc0 |
| node ios-legacy.cjs | rc0, 181×181 → 414×736 и иные constraints |
| Б3: marginLeft:1000 | behavioral rc1, 2/20 красных |
| С2: Image оверлея = icon.png | static rc0, behavioral rc0 |
| С2: hide в render до commit | static rc0, behavioral rc0 |
| node node_modules/jest/bin/jest.js …/critic117-commit.probe.test.tsx --runInBand | честная rc0; мутант rc1, журналы порядка выше |
| node node_modules/jest/bin/jest.js src/bootstrap/__tests__/pilot.test.tsx --runInBand на модели | rc0, 14/14 |
| python3 …/first_run_111/first_run_probe.py --repo R на модели | rc1, 17/19; красны РОВНО обе К8 |
| npm run typecheck на модели | rc0 |
| npm run lint на модели | rc0 |
| python3 measure.py | rc0, независимые счёт и маски |
| git diff --exit-code 4e0266278c9250badfe327a112af09ea1eeb31a5 OBJECT -- fixtures/workshop_project/first_run_111/ | rc0, frozen-батарея не менялась |

Н-38: AST даёт 17 статических и 18 поведенческих ключей MUTANTS. Статические клетки другой мерой: 13 фиксированных check + 4 raster_case + 10 generated + 2 iOS + 2 composite + 2 sign = 33. Поведенческие: 2 одиночных it + 9 scheme-пар = 20. Это не повтор stdout матриц. Подробности — independent-measure.json.

Byte-frozen pilot.test.tsx: SHA256 исполненного файла и git-blob B одинаковы — dee6de0bd22a36d7e65711cc436796f4d056f6bdca46441253348df1b7543d17. first_run_111 не назван зелёным: два ожидаемых красных К8 сохранены.

## Граница доказательства и доставка

Судился контракт и пригодность его предъявленных красных проб, не реализация будущего implementer. Найденные обходы — зелень НОВЫХ кодовых критериев при нарушении конкретного пункта арбитража, а не успешная ручная приёмка скриншотов. Release APK, gh pr checks, Maestro, Expo Go и устройство iOS здесь НЕ запускались; совпадение скриншотов с макетами не объявлено доказанным.

Файл доставки: /tmp/dev-harness-verify/Critic117r3/verdict.md. Рядом сохранены скрипты воспроизведения, JSON измерений, PNG и сырые *.log. Копии harness/, mob/, witness-mob/, mask-mob/ и scratch удаляются после прогонов по дисковой политике. Для повторения достаточно клонировать те же OBJECT/B в названные подпути и подключить mobile/node_modules.

Запись в основной checkout/worktree запрещена заданием; поэтому вердикт НЕ закоммичен в ветку предмета и должен быть материализован оркестратором под identity critic в workflowPaths.verdicts, например verdicts/critic/contracts-117-v3.md. Push не выполнялся. Попытка коротко передать решение через agent://Main отклонена Н-85; доставка решения — этим файлом и terminal yield. До материализации нельзя утверждать, что вердикт виден на HEAD основной ветки.
