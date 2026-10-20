FAIL
OBJECT=cec116cd42f4f927ace694180134ef16a51e67a7

# Adversary verdict — CMP-MOB-005 / contract 111

## Диагноз

Найдены два воспроизводимых обхода батареи. Оба дают зелёные 14/14
статические и 11/11 поведенческие клетки при неверном продукте. Поэтому
батарея не доказывает предмет «полный First-Run по D2.2.5.1», а объект уже
содержит один из дефектов (недействительный wordmark PNG) и второй
(белая внешняя рамка) по коду.

| Инвариант контракта | Замер на OBJECT | Вердикт |
|---|---|---|
| 1. props-only, theme, настоящая SafeArea и четыре края | static 14/14; K3 DARK/LIGHT зелёны; матрицы `safearea-edges-empty` и `light-edges-top-bottom` краснеют на нужных K3 | PASS |
| 2. CTA `first-run-continue` → F03.01 в dark/light | K2 DARK/LIGHT и K2′ зелёны; `light-cta-noop` красит только K2 LIGHT | PASS |
| 3. Verbatim promise/CTA и замкнутая copy | K1/K5 DARK/LIGHT зелёны; `extra-unreviewed-copy` и `light-extra-copy` ловятся | PASS |
| 4. Ровно два ключа каталога | static `COPY_KEY_ui_first_run_*` зелёны | PASS |
| 5. root/effective Android+iOS splash `#0A0A0A` | static `SPLASH_*` зелёны; `android-splash-blue` ловится effective-клеткой | PASS |
| 6. Реальный растровый wordmark из logo/ и привязанный Image.source | Image.source и имя пути проверяются, но содержимое не проверяется. Текущий 82-байтный файл имеет PNG-заголовок 8×44, однако inflated scan data 1100 B при обязательных 396 B: это не декодируемый PNG; канонический SVG имеет viewBox 143×52.08. Корректный путь не превращает его в wordmark. | FAIL |
| 7. Один Demo-бейдж | K1 DARK/LIGHT зелёны; `demo-badge-scope` ловится | PASS |
| 8. Полная поверхность First-Run на ground обеих схем | K1 видит только внутренний SafeAreaView. Внешний `PilotApp` root остаётся с `paddingTop: 48`, горизонтальными/нижними отступами и `backgroundColor: '#FFFFFF'`; вокруг First-Run наблюдаем белую рамку, т.е. экран не полный и не целиком ground. Мутант с magenta вместо white проходит обе пробы. | FAIL |

## Блокирующие обходы

### A1 — `BLANK_WORDMARK_ASSET`

**Обход.** В копии объекта заменён только
`mobile/assets/images/wordmark-dark.png` на созданный stdlib-скриптом
корректный 67-байтный 1×1 grayscale PNG с единственным чёрным пикселем.
`Image.source`, testID, accessibility label/role и всё TS остаются прежними.
Это не растеризованный wordmark D2.2.5.1, но проходит обе семьи.

**Воспроизведение.** Мутант:
`/tmp/dev-harness-verify/Adv111/mutant-blank-wordmark`.

```text
$ python3 .../first_run_static_probe.py --repo .../mutant-blank-wordmark
static 14/14
$ python3 .../first_run_probe.py --repo .../mutant-blank-wordmark
honest 11/11
$ python3 .../inspect_wordmark.py .../mutant-blank-wordmark/.../wordmark-dark.png
bytes=67 width=1 height=1 bit_depth=8 colour_type=0
inflated_scan_bytes=2 expected_noninterlaced_scan_bytes=2
VALID_SCAN_LENGTH
```

**Почему это блокирует объект.** OBJECT уже хуже этого контрпримера:
его связанный ассет — 82 B, header 8×44, однако он не является валидным
PNG-растром. Следовательно, требование «wordmark — растровый ассет,
растеризованный из семьи logo/» не выполнено даже до визуальной оценки.

### A2 — `WRAPPER_GROUND_BYPASS`

**Обход.** В копии объекта заменён ровно один литерал в
`mobile/src/bootstrap/pilot-app.tsx`: внешний `styles.root.backgroundColor`
`'#FFFFFF'` → `'#ff00ff'`. Его существующие `paddingTop: 48`,
`paddingHorizontal: 16`, `paddingBottom: 16` не менялись. Внутренний
`first-run-safe-area` всё ещё имеет `tokens.ground`, поэтому K1 остаётся
зелёной, хотя по краям экрана видна magenta-рамка. Это доказывает, что
батарея проверяет не полный экран, а только вложенный контейнер.

**Воспроизведение.** Мутант:
`/tmp/dev-harness-verify/Adv111/mutant-wrapper-surface`.

```text
$ python3 .../first_run_static_probe.py --repo .../mutant-wrapper-surface
static 14/14
$ python3 .../first_run_probe.py --repo .../mutant-wrapper-surface
honest 11/11
```

**Почему это блокирует объект.** В OBJECT применяется тот же безусловный
`styles.root`, только белого цвета. Поэтому вместо заявленного полного
First-Run на D2.2.5.1 ground объект показывает белую 48/16/16-px внешнюю
рамку.

## Оценка подозрения о wordmark

Подозрение подтверждено и является блокером, не только cognitive-only
советом. Сам контракт требует именно rasterized wordmark из канонической
семьи, а не просто существование файла с PNG magic и нужным basename.
Канон `complior-wordmark-dark.svg` задаёт 143×52.08; объектный PNG имеет
неверный портретный 8×44 header и недопустимую длину scan data. Проба
`WORDMARK_ASSET` проверяет лишь восемь magic-байтов и ненулевую длину;
`WORDMARK_SOURCE_BOUND_*` проверяет лишь `testUri` basename. A1 показывает,
что даже полностью валидный, но пустой 1×1 PNG остаётся зелёным.

Отсутствие SVG-растеризатора на станции не делает placeholder допустимым.
Допустимым результатом будет проверяемо декодируемый PNG, полученный из
канонического SVG доверенным/зафиксированным рендерером, с естественным
ландшафтным соотношением сторон канона и визуальной сверкой с ним на
реальном First-Run. Если разрешение и рендерер фиксируются, допустим также
проверяемый checksum эталонного PNG; иначе автоматическая проба минимум
должна декодировать PNG и отвергать пустой/несоразмерный raster, а reviewer
должен принять визуальный результат. Пока такой растр не предоставлен,
accept невозможен.

## Советы автору батареи (не являются правкой предмета)

1. Добавить отрицательный мутант, который сохраняет `require(...wordmark-dark.png)`
   и все props, но заменяет файл на валидный 1×1 PNG; он обязан красить
   `WORDMARK_ASSET` или отдельную content/visual клетку. Проверка должна
   использовать настоящий decoder, не magic bytes.
2. Добавить клетку полного first-run surface: она должна наблюдать внешний
   root/снимок рендера, включая отсутствие legacy padding и ground по краям
   в dark/light. Отдельный мутант `root background '#ff00ff'` обязан краснеть.
3. Существующие матрицы полезны, но не покрывают ни bitmap-content, ни
   внешний wrapper; их зелень не должна считаться доказательством этих двух
   свойств.

## Сырой вывод (существенные строки)

```text
$ git -C .../object rev-parse HEAD
cec116cd42f4f927ace694180134ef16a51e67a7

$ first_run_static_probe.py --repo .../object
static 14/14
$ first_run_probe.py --repo .../object
honest 11/11

$ first_run_static_probe.py --repo .../object --matrix
[9 declared mutants each red on the declared static cells; rc=0]
$ first_run_probe.py --repo .../object --matrix
[14 declared mutants each red on the declared dynamic cells; rc=0]

$ inspect_wordmark.py .../object/.../wordmark-dark.png
bytes=82 width=8 height=44 bit_depth=8 colour_type=0
inflated_scan_bytes=1100 expected_noninterlaced_scan_bytes=396
INVALID_SCAN_LENGTH

$ env PATH=/tmp /usr/bin/python3 first_run_static_probe.py --repo .../object
RED SPLASH_EFFECTIVE_GROUND_BOTH
INFRASTRUCTURE: splash resolver не исполнился: FileNotFoundError(2, 'No such file or directory')
[rc=2, therefore missing resolver is not counted green]

$ pilot_995/probe.py --repo .../object --case DIRECT_unknown --check-frozen
995 actual/DIRECT_unknown: rc=0 assertion=passed
995 runs=1 mismatches=0
$ pilot_995/probe.py --repo .../object --case DEFAULT_OFFLINE --check-frozen
995 actual/DEFAULT_OFFLINE: rc=0 assertion=passed
995 runs=1 mismatches=0
$ nav_999/nav_probe.py --repo .../object
[all emitted nav cases rc=0]
$ start_108/start_static_probe.py --repo .../object
static 22/22
$ start_108/start_probe.py --repo .../object
honest 336/336

$ git -C .../object status --short --untracked-files=all
[no output]
```
