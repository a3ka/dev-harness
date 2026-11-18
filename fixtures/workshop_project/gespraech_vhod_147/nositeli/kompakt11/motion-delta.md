# Complior · Gespräch · D 2.4 Kompakt — motion-delta

Сборка **D24-Kompakt-1.1**. Против 1.0 движение не изменилось: в 1.1 расширены только зоны касания Button sm и строки «Zugehöriger Vorgang» в Post, а в переходах их нет. Промежуточные кадры те же, что в 1.0. Основа — спецификация движения финала 2 (`motion-spec-gespraech.json`, MOTION-GESPRAECH.md, 20 переходов + эталоны GA-R2/GA-R3). Видео и ключевые кадры финала 2 не пересняты.

## Что сохранено для всех переходов

- Длительности, задержки, порядок, кривые: `motion-fast` 150, `motion-base` 250, `motion-slow` 400, `motion-morph` 450 мс; `ease-standard` cubic-bezier(0.2, 0.7, 0.2, 1), `ease-morph` cubic-bezier(0.32, 0.72, 0, 1); без пружин.
- Прерывание: повторный триггер разворачивает от текущего значения; новая цель на лету — от текущего значения (`CompliorFaden.morph` от последнего прямоугольника); уход с экрана — сразу конечное состояние.
- «Уменьшить движение»: перемещение, масштаб, размер, высота, поворот, morph — 0 мс; opacity и цвет ≤ `motion-fast`; живые входы статичны; петли знака выключены.
- Позы Dynamic Faden 1.3, тактильный отклик, звуки — без изменений.

## Что изменилось

Kompakt меняет только **размеры**, между которыми идёт движение. Треки общих элементов в спецификации заданы через прямоугольники (`{rect: …}`), поэтому они сами берут новые размеры; в таблицах ниже — новые конечные значения. Числа, которые были записаны в треках жёстко, заменены:

| Параметр | Final 2 | Kompakt |
|---|---|---|
| Таб-бар при переходе к голосу, ty (GA-T08, GA-T37, GA-R3) | 84 (393: 118) | **49** (393: 49 + 18 + полоса Home) |
| Адаптивная сцена: потолки cap | 288 / 232 / 160 / 96 | **232 / 184 / 128 / 80** |
| Адаптивная сцена: минимум S = max(min, …) и порог дока P − 64 < min | 96 | **80** (`--size-presence-compact`) |
| Адаптивная сцена: высота шапки T | 60 | **52** |
| Знак в камешке / над вопросом | 28 / 40 | **20 / 32** |
| Sprechleiste | 68 | **60** |

### Сохранено (без изменений в числах и геометрии)

| Переход | Почему |
|---|---|
| GA-T18 · Tastatur wechselt die Höhe (iOS Emoji +48) → der Verlauf rückt mit | высота клавиатуры 336 → 384 — кадр платформы |
| GA-T19 · Mikrofon nicht erlaubt → die Leiste öffnet sich nicht, Systemzeile, so | подъём клавиатуры и системной строки — анимация платформы и сдвиги 8 px |
| GA-T20 · working → needs_action · «In Arbeit» → «Ihre Rückmeldung nötig» in der | только opacity и подъёмы 12/16 px внутри чата |
| GA-T22 · working → done (positive) · Umzug | только opacity, подъём 12 px и галочка знака |
| GA-T23 · waiting → uncertain (careful) · «Warten auf Antwort» → «Unklar», «… st | только opacity и подъём 12 px |
| GA-T24 · error · offline | только opacity, подъём строки 8 px и заголовка 9 px |
| GA-T32 · Plakette «Neues Auto» → «Thema | нажатие плашки (scale 0,97), подъёмы 8/12 px; размер плашки меньше, но треки от него не зависят |
| GA-R2, GA-R2-393, GA-R3, GA-R3-393 (эталоны) | собраны из GA-T16/T17/T08/T20–T24; меняются только вместе с ними, отдельно не пересняты |

### Изменено

Промежуточные кадры 25 / 50 / 75 % окна перехода — `motion-delta-frames/<ID>_<slug>_<025|050|075>_light_390x844.png` (светлая тема, 390 × 844). Они отрисованы той же лабораторией, что и видео финала 2 (`MotionLab`, детерминированно, 60 fps), со слоем `ds/kompakt.css` этого пакета и заменёнными числами из таблицы выше.

#### GA-T28 · Mitte antippen → Menü: das Zeichen fliegt zur Frage, die Pillen kommen von oben («Sprechen» zuerst), ≈ 300 ms

- **Изменилось:** знак камешка 28 → **20** px (камешек 48×32 → **40×24**); знак над вопросом 40 → **32** px; пилюли меню 60 → **52** px, круг иконки 48 → **44**; общий элемент (знак) летит между этими прямоугольниками — путь короче, длительность та же.
- **Триггер:** Касание центральной вкладки «Gespräch» (`proposed.action.gespraech.tab.menu`). Удержание `press-long` — сразу голос (GA-T35).
- **Окно:** 0–450 мс, UI ≈ 400 мс.
- **Прерывание:** «×», касание фона, Esc, «назад» — GA-T31 от текущих значений; выбор пункта во время открытия — сразу этот пункт.
- **Уменьшить движение:** Без полёта, поворота и подъёма: фон, «×», вопрос и пилюли появляются сменой opacity за `motion-fast`; знак сразу у вопроса.
- **Кадры:** `GA-T28_mitte-menue-oeffnen_025_light_390x844.png`, `GA-T28_mitte-menue-oeffnen_050_light_390x844.png`, `GA-T28_mitte-menue-oeffnen_075_light_390x844.png`

| Что | Свойство | Откуда → куда | Задержка, мс | Длительность, мс | Кривая | Reduce, мс |
|---|---|---|---|---|---|---|
| камешек: нажатие | scale | 1 → 0.94 | 0 | 150 (motion-fast) | ease-standard | 0 |
| «×»: поворот −45° → 0 | rot | -45 → 0 | 0 | 250 (motion-base) | ease-standard | 0 |
| «×» вырастает из камешка | scale | 0.6 → 1 | 0 | 250 (motion-base) | ease-standard | 0 |
| знак летит из камешка к вопросу (28 → 40): x | left | прямоугольник → прямоугольник | 0 | 250 (motion-base) | ease-morph | 0 |
| y | top | прямоугольник → прямоугольник | 0 | 250 (motion-base) | ease-morph | 0 |
| размер | w | прямоугольник → прямоугольник | 0 | 250 (motion-base) | ease-morph | 0 |
| размер | h | прямоугольник → прямоугольник | 0 | 250 (motion-base) | ease-morph | 0 |
| вопрос «Wie möchten Sie beginnen?» и строка «Sie können jederzeit wechseln.» | ty | 8 → 0 | 30 | 150 (motion-fast) | ease-standard | 0 |
| пилюля 1: подъём 12 → 0 | ty | 12 → 0 | 60 | 250 (motion-base) | ease-standard | 0 |
| пилюля 2: подъём 12 → 0 | ty | 12 → 0 | 90 | 250 (motion-base) | ease-standard | 0 |
| пилюля 3: подъём 12 → 0 | ty | 12 → 0 | 120 | 250 (motion-base) | ease-standard | 0 |
| пилюля 4: подъём 12 → 0 | ty | 12 → 0 | 150 | 250 (motion-base) | ease-standard | 0 |

#### GA-T31 · «×» / Hintergrund / Esc → Menü schließen: das Zeichen fliegt zurück in den Kiesel

- **Изменилось:** обратный путь GA-T28: знак 32 → **20** px в камешек 40×24; пилюли 52 px опускаются на 8 px — как раньше.
- **Триггер:** Касание «×» (`common.close`), касание фона, Esc, жест «назад».
- **Окно:** 0–300 мс, UI ≈ 300 мс.
- **Прерывание:** Касание вкладки во время закрытия — снова GA-T28 от текущих значений.
- **Уменьшить движение:** Сразу: меню и фон гаснут за `motion-fast`, знак сразу в камешке.
- **Кадры:** `GA-T31_mitte-menue-schliessen_025_light_390x844.png`, `GA-T31_mitte-menue-schliessen_050_light_390x844.png`, `GA-T31_mitte-menue-schliessen_075_light_390x844.png`

| Что | Свойство | Откуда → куда | Задержка, мс | Длительность, мс | Кривая | Reduce, мс |
|---|---|---|---|---|---|---|
| пилюля опускается 8 | ty | 0 → 8 | 0 | 150 (motion-fast) | ease-standard | 0 |
| пилюля опускается 8 | ty | 0 → 8 | 0 | 150 (motion-fast) | ease-standard | 0 |
| пилюля опускается 8 | ty | 0 → 8 | 0 | 150 (motion-fast) | ease-standard | 0 |
| пилюля опускается 8 | ty | 0 → 8 | 0 | 150 (motion-fast) | ease-standard | 0 |
| «×»: поворот 0 → −45° | rot | 0 → -45 | 0 | 250 (motion-base) | ease-standard | 0 |
| «×» уходит в камешек | scale | 1 → 0.6 | 0 | 250 (motion-base) | ease-standard | 0 |
| знак летит от вопроса обратно в камешек: x | left | прямоугольник → прямоугольник | 0 | 250 (motion-base) | ease-morph | 0 |
| y | top | прямоугольник → прямоугольник | 0 | 250 (motion-base) | ease-morph | 0 |
| размер | w | прямоугольник → прямоугольник | 0 | 250 (motion-base) | ease-morph | 0 |
| размер | h | прямоугольник → прямоугольник | 0 | 250 (motion-base) | ease-morph | 0 |

#### GA-T29 · Menü «Sprechen» → Stimme im leeren Chat: das Zeichen wächst von der Frage in die Bühne, die Leiste sagt «Ich höre zu.»

- **Изменилось:** знак растёт от вопроса (32 px) в сцену; потолок сцены 288 → **232**; Sprechleiste 68 → **60** px (поднимается на 24 px — как раньше).
- **Триггер:** Касание «Sprechen» (`ia115.entry.speak`) в меню центральной кнопки.
- **Окно:** 0–600 мс, UI ≈ 500 мс.
- **Прерывание:** ⌨ во время морфа — обратный морф в шапку (GA-T16 без клавиатуры); микрофон запрещён — GA-T19.
- **Уменьшить движение:** Без морфа: меню гаснет, чат с Sprechleiste появляется (opacity за `motion-fast`); знак сразу на сцене.
- **Кадры:** `GA-T29_menue-sprechen_025_light_390x844.png`, `GA-T29_menue-sprechen_050_light_390x844.png`, `GA-T29_menue-sprechen_075_light_390x844.png`

| Что | Свойство | Откуда → куда | Задержка, мс | Длительность, мс | Кривая | Reduce, мс |
|---|---|---|---|---|---|---|
| «Sprechen»: нажатие | scale | 1 → 0.97 | 0 | 150 (motion-fast) | ease-standard | 0 |
| Sprechleiste поднимается («Ich höre zu.», живая точка) | ty | 24 → 0 | 150 | 250 (motion-base) | ease-standard | 0 |
| подсказка и темы-пилюли как примеры | ty | 12 → 0 | 250 | 250 (motion-base) | ease-standard | 0 |

#### GA-T35 · Mitte gedrückt halten (press-long 500 ms) → sofort Stimme: das Zeichen wächst aus dem Kiesel in die Bühne

- **Изменилось:** знак растёт из камешка (20 px) в сцену; потолок 288 → **232**; камешек при удержании 1 → 1,06 — как раньше, но от 40×24; Sprechleiste 68 → **60**.
- **Триггер:** Удержание центральной вкладки `press-long` (500 мс); подсказка «oder Taste gedrückt halten» в меню учит этому жесту.
- **Окно:** 0–1100 мс, UI ≈ 1000 мс.
- **Прерывание:** Отпускание до 500 мс — это касание: меню (GA-T28). При крупном тексте (Large Content Viewer / подсказки Android) хост выключает ярлык — голос остаётся в меню.
- **Уменьшить движение:** Камешек не растёт; через 500 мс чат с Sprechleiste появляется (opacity за `motion-fast`).
- **Кадры:** `GA-T35_mitte-halten-sprechen_025_light_390x844.png`, `GA-T35_mitte-halten-sprechen_050_light_390x844.png`, `GA-T35_mitte-halten-sprechen_075_light_390x844.png`

| Что | Свойство | Откуда → куда | Задержка, мс | Длительность, мс | Кривая | Reduce, мс |
|---|---|---|---|---|---|---|
| камешек растёт, пока палец держит (press-long) | scale | 1 → 1.06 | 0 | 500 (press-long) | linear | 0 |
| Sprechleiste | ty | 24 → 0 | 650 | 250 (motion-base) | ease-standard | 0 |
| подсказка и темы-пилюли | ty | 12 → 0 | 750 | 250 (motion-base) | ease-standard | 0 |

#### GA-T30 · Menü «Schreiben» → das Feld hat den Fokus, die Tastatur kommt, die Themen als Zeile darüber (ohne Doppelbild)

- **Изменилось:** пилюля «Schreiben» 60 → **52** px превращается в поле: поле мин. 48, отступы 14/16 → **10/14**, скругление 28 → **22**.
- **Триггер:** Касание «Schreiben» (`ia115.entry.write`) в меню центральной кнопки: фокус сразу в поле.
- **Окно:** 0–800 мс, UI ≈ 700 мс.
- **Прерывание:** Касание вне поля — клавиатура уходит, видны плашки (GA-11); касание темы-пилюли — GA-T32.
- **Уменьшить движение:** Без морфа: фон закрывает меню, чат появляется (opacity за `motion-fast`); клавиатура — системная.
- **Кадры:** `GA-T30_menue-schreiben-tastatur_025_light_390x844.png`, `GA-T30_menue-schreiben-tastatur_050_light_390x844.png`, `GA-T30_menue-schreiben-tastatur_075_light_390x844.png`

| Что | Свойство | Откуда → куда | Задержка, мс | Длительность, мс | Кривая | Reduce, мс |
|---|---|---|---|---|---|---|
| «Schreiben»: нажатие | scale | 1 → 0.97 | 0 | 150 (motion-fast) | ease-standard | 0 |
| пилюля «Schreiben» → поле: x | left | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| y | top | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| ширина | w | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| высота | h | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| panel → panel | bg | --panel → --panel | 0 | 450 (motion-morph) | ease-morph | 150 |
| знак и вопрос: подъём | ty | 12 → 0 | 150 | 250 (motion-base) | ease-standard | 0 |
| клавиатура + поле поднимаются из-за края (анимация платформы) | ty | 496 → 0 | 150 | 250 (motion-base) | ease-standard | 0 |

#### GA-T33 · Ein Vorgang braucht Sie: Menü → «Ansehen» → direkt zur Freigabe (die Zeile wird zur Karte, die Bühne verdeckt nichts)

- **Изменилось:** строка дела в меню 64 → **56** px превращается в карточку Freigabe: отступ 20 → **16**, скругление 28 → **20**.
- **Триггер:** Касание строки ждущего Vorgang (или «Ansehen») в меню центральной кнопки (`proposed.action.gespraech.menu.pending`).
- **Окно:** 0–800 мс, UI ≈ 450 мс.
- **Прерывание:** «Noch nicht senden» — карточка остаётся в разговоре, точка вкладки остаётся; «Oder etwas Neues beginnen» — пункты ниже начинают новый Vorgang.
- **Уменьшить движение:** Без морфа: меню гаснет, разговор открывается на карточке (opacity за `motion-fast`).
- **Кадры:** `GA-T33_vorgang-ansehen_025_light_390x844.png`, `GA-T33_vorgang-ansehen_050_light_390x844.png`, `GA-T33_vorgang-ansehen_075_light_390x844.png`

| Что | Свойство | Откуда → куда | Задержка, мс | Длительность, мс | Кривая | Reduce, мс |
|---|---|---|---|---|---|---|
| строка Vorgang: нажатие | scale | 1 → 0.98 | 0 | 150 (motion-fast) | ease-standard | 0 |
| строка → карточка Freigabe: x | left | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| y | top | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| ширина | w | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| высота | h | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| card → card | bg | --card → --card | 0 | 450 (motion-morph) | ease-morph | 150 |

#### GA-T34 · Mikrofon der Plakette «Neues Auto» → Stimme mit diesem Thema: die Zeile wird zur Leiste, Complior fragt, dann hört er zu

- **Изменилось:** строка «Erzählen» плашки (44) превращается в Sprechleiste 68 → **60**; потолок сцены 232 → **184**.
- **Триггер:** Касание строки «Erzählen» на плашке (aria-label «Neues Auto erzählen»).
- **Окно:** 0–2650 мс, UI ≈ 2300 мс.
- **Прерывание:** Речь человека во время вопроса — перебивание: TTS затухает (`motion-fast`), Sprechleiste «Sie sprechen»; ⌨ — GA-T16.
- **Уменьшить движение:** Без морфа: старт гаснет, разговор появляется (opacity); знак сразу на сцене; вопрос — целиком.
- **Кадры:** `GA-T34_plakette-mikrofon_025_light_390x844.png`, `GA-T34_plakette-mikrofon_050_light_390x844.png`, `GA-T34_plakette-mikrofon_075_light_390x844.png`

| Что | Свойство | Откуда → куда | Задержка, мс | Длительность, мс | Кривая | Reduce, мс |
|---|---|---|---|---|---|---|
| строка «Erzählen»: нажатие | scale | 1 → 0.94 | 0 | 150 (motion-fast) | ease-standard | 0 |
| строка микрофона → Sprechleiste: x | left | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| y | top | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| ширина | w | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| высота | h | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| panel → voice-surface | bg | --panel → --voice-surface | 0 | 450 (motion-morph) | ease-morph | 150 |
| отметка темы | ty | 8 → 0 | 150 | 250 (motion-base) | ease-standard | 0 |
| вопрос по фразам вместе с голосом | reveal | 0 → 1 | 570 | 250 (motion-base) | ease-standard | 0 |

#### GA-T08 · «Lieber erzählen?» → Stimme im Chat: der Chip wird zur Leiste, Complior kommt aus der Kopfzeile auf die Bühne

- **Изменилось:** чип «Lieber erzählen?» превращается в Sprechleiste 68 → **60**; таб-бар уходит вниз: ty 0 → 84 становится 0 → **49** (высота новой панели); сцена: потолки 96 → **80**, 232 → **184**.
- **Триггер:** Касание «Lieber erzählen?» рядом с чипами (или микрофона поля).
- **Окно:** 0–900 мс, UI ≈ 500 мс.
- **Прерывание:** ⌨ во время морфа — обратный морф (GA-T16 без клавиатуры).
- **Уменьшить движение:** Без морфа: поле гаснет, Sprechleiste появляется; знак сразу на сцене.
- **Кадры:** `GA-T08_einladung-sprechen_025_light_390x844.png`, `GA-T08_einladung-sprechen_050_light_390x844.png`, `GA-T08_einladung-sprechen_075_light_390x844.png`

| Что | Свойство | Откуда → куда | Задержка, мс | Длительность, мс | Кривая | Reduce, мс |
|---|---|---|---|---|---|---|
| «Lieber erzählen?»: нажатие | scale | 1 → 0.95 | 0 | 150 (motion-fast) | ease-standard | 0 |
| таб-бар уходит вниз (голос) | ty | 0 → 84 | 0 | 250 (motion-base) | ease-standard | 0 |
| чип → Sprechleiste: x | left | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| y | top | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| ширина | w | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| высота | h | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| ground → voice-surface | bg | --ground → --voice-surface | 0 | 450 (motion-morph) | ease-morph | 150 |

#### GA-T27 · Der Verlauf wächst → die Bühne wird kleiner (232 → 160) → Complior dockt in die Kopfzeile und bleibt dort; der Titel rückt zur Seite

- **Изменилось:** сцена уменьшается 232 → 160 становится **184 → 128**; док в шапку: высота шапки 60 → **52** (T в правиле адаптивной сцены).
- **Триггер:** Растёт текущая реплика (ответ, «Das habe ich verstanden», новое высказывание); хост меняет cap (ответ 232 → факты 160).
- **Окно:** 0–3700 мс, UI ≈ 2950 мс.
- **Прерывание:** Новая цель — от текущего значения. Сцена только уменьшается: после дока знак остаётся в шапке до конца разговора.
- **Уменьшить движение:** Размеры и положение — сразу; появления — opacity ≤ `motion-fast`.
- **Кадры:** `GA-T27_buehne-schrumpft-dockt_025_light_390x844.png`, `GA-T27_buehne-schrumpft-dockt_050_light_390x844.png`, `GA-T27_buehne-schrumpft-dockt_075_light_390x844.png`

| Что | Свойство | Откуда → куда | Задержка, мс | Длительность, мс | Кривая | Reduce, мс |
|---|---|---|---|---|---|---|
| предложение по фразам вместе с голосом | reveal | 0 → 1 | 80 | 250 (motion-base) | ease-standard | 0 |
| «Das habe ich verstanden» (Bitte prüfen) | ty | 16 → 0 | 1500 | 250 (motion-base) | ease-standard | 0 |
| вопрос «Fehlt nur noch: Wie viel…» | ty | 12 → 0 | 1560 | 250 (motion-base) | ease-standard | 0 |
| слова | reveal | 0 → 1 | 2700 | 150 (motion-fast) | ease-standard | 0 |
| живой пузырь «Ungefähr zwölftausend im Jahr.» | ty | 12 → 0 | 2700 | 250 (motion-base) | ease-standard | 0 |

#### GA-T37 · «Beenden» → zurück zum Text: die Leiste wird zum Feld, die Tab-Leiste kommt zurück, «Ihr Anliegen bleibt geöffnet»

- **Изменилось:** Sprechleiste 60 превращается в поле (мин. 48, отступы 10/14, скругление 22); таб-бар возвращается: ty 84 → 0 становится **49 → 0**.
- **Триггер:** Касание «Beenden» в шапке (aria-label «Gespräch beenden»).
- **Окно:** 0–900 мс, UI ≈ 700 мс.
- **Прерывание:** Микрофон в поле — снова голос (GA-T08 / GA-T17).
- **Уменьшить движение:** Без морфа: Sprechleiste гаснет, поле и таб-бар появляются (opacity за `motion-fast`).
- **Кадры:** `GA-T37_beenden_025_light_390x844.png`, `GA-T37_beenden_050_light_390x844.png`, `GA-T37_beenden_075_light_390x844.png`

| Что | Свойство | Откуда → куда | Задержка, мс | Длительность, мс | Кривая | Reduce, мс |
|---|---|---|---|---|---|---|
| таб-бар возвращается | ty | 84 → 0 | 0 | 250 (motion-base) | ease-standard | 0 |
| Sprechleiste → поле: x | left | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| y | top | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| ширина | w | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| высота | h | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| voice-surface → panel | bg | --voice-surface → --panel | 0 | 450 (motion-morph) | ease-morph | 150 |
| «Die Sprachaufnahme ist beendet. Ihr Anliegen bleibt geöffnet.» | ty | 8 → 0 | 450 | 250 (motion-base) | ease-standard | 0 |

#### GA-T16 · Stimme → Tastatur (iOS): Mikrofon sofort aus, der angefangene Satz wird Entwurf im Feld, Complior dockt neben den Titel

- **Изменилось:** Sprechleiste 68 → **60** превращается в поле над клавиатурой; потолок сцены 232 → **184**.
- **Триггер:** Касание ⌨ «Zum Text wechseln» в Sprechleiste — во время речи, паузы или ответа Complior.
- **Окно:** 0–1000 мс, UI ≈ 600 мс.
- **Прерывание:** Повторное касание поля — ничего; ↑ до конца — отправка недоговорённого. Если Complior говорил — TTS затухает за `motion-fast`, текст ответа остаётся.
- **Уменьшить движение:** Без морфа: пилюля гаснет, поле появляется (opacity за `motion-fast`); клавиатура — системная; знак сразу в шапке.
- **Кадры:** `GA-T16_stimme-zur-tastatur_025_light_390x844.png`, `GA-T16_stimme-zur-tastatur_050_light_390x844.png`, `GA-T16_stimme-zur-tastatur_075_light_390x844.png`

| Что | Свойство | Откуда → куда | Задержка, мс | Длительность, мс | Кривая | Reduce, мс |
|---|---|---|---|---|---|---|
| клавиатура + поле поднимаются (анимация платформы) | ty | 336 → 0 | 0 | 250 (motion-base) | ease-standard | 0 |
| Sprechleiste → поле: x | left | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| y | top | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| ширина | w | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| высота | h | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| voice-surface → panel | bg | --voice-surface → --panel | 0 | 450 (motion-morph) | ease-morph | 150 |

#### GA-T17 · Tastatur → Stimme: das Mikrofon im Feld · der getippte Text bleibt Entwurf über der Leiste, Complior kommt auf die Bühne

- **Изменилось:** поле превращается в Sprechleiste **60**; потолок сцены 160 → **128**.
- **Триггер:** Касание микрофона в поле (видимая кнопка), пока в нём есть текст; без текста — микрофон поля (primary).
- **Окно:** 0–1000 мс, UI ≈ 500 мс.
- **Прерывание:** «Nachricht senden» в строке черновика — отправка текста, голос остаётся открытым; ⌨ — обратно GA-T16, черновик снова в поле.
- **Уменьшить движение:** Клавиатура закрывается системой; пилюля и строка черновика появляются сменой opacity; знак сразу на сцене.
- **Кадры:** `GA-T17_tastatur-zur-stimme_025_light_390x844.png`, `GA-T17_tastatur-zur-stimme_050_light_390x844.png`, `GA-T17_tastatur-zur-stimme_075_light_390x844.png`

| Что | Свойство | Откуда → куда | Задержка, мс | Длительность, мс | Кривая | Reduce, мс |
|---|---|---|---|---|---|---|
| клавиатура закрывается (анимация платформы) | ty | 0 → 336 | 0 | 250 (motion-base) | ease-standard | 0 |
| поле → Sprechleiste: x | left | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| y | top | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| ширина | w | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| высота | h | прямоугольник → прямоугольник | 0 | 450 (motion-morph) | ease-morph | 0 |
| panel → voice-surface | bg | --panel → --voice-surface | 0 | 450 (motion-morph) | ease-morph | 150 |
| черновик поднимается | ty | 12 → 0 | 250 | 250 (motion-base) | ease-standard | 0 |

#### GA-T21 · «Schadenmeldung senden» → die Karte faltet sich zur Quittung (was, an wen, wann) → waiting · die Bühne kommt nicht zurück

- **Изменилось:** карточка Freigabe складывается до квитанции: высота «auto» теперь **406** px вместо прежней (отступы 16, скругление 20), конечная высота квитанции **64** — без изменений.
- **Триггер:** Касание «Schadenmeldung senden» (точная подпись действия, F11); хост подтвердил отправку (с доказательством) — через ~0,8 с.
- **Окно:** 0–2100 мс, UI ≈ 1710 мс.
- **Прерывание:** Повторное касание игнорируется (`aria-busy`); ошибка отправки — строка ошибки в ленте, состояние → needs_action, карточка остаётся.
- **Уменьшить движение:** Сразу: карточка сменяется квитанцией (opacity ≤ `motion-fast`), ответ появляется.
- **Кадры:** `GA-T21_freigabe-quittung_025_light_390x844.png`, `GA-T21_freigabe-quittung_050_light_390x844.png`, `GA-T21_freigabe-quittung_075_light_390x844.png`

| Что | Свойство | Откуда → куда | Задержка, мс | Длительность, мс | Кривая | Reduce, мс |
|---|---|---|---|---|---|---|
| карточка складывается до высоты квитанции | h | auto → 64 | 950 | 450 (motion-morph) | ease-morph | 0 |
| card → panel (квитанция тише ночью) | bg | --card → --panel | 950 | 450 (motion-morph) | ease-morph | 150 |
| ответ «Die Musterversicherung hat den Eingang b…» | ty | 12 → 0 | 1460 | 250 (motion-base) | ease-standard | 0 |

## Как проверять

Знак — численно против `pose()` Faden 1.3 (без изменений). Геометрия — конечные прямоугольники совпадают с кадрами `Complior-D24-Gespraech-Kompakt-Frames` и с `screens/` источника. Тайминг — по таблицам финала 2: он не менялся.
