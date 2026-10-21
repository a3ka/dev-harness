accept
Контракт 117: микро-круг критика 4, только четыре пункта FAIL круга 3 + заданный регресс.
OBJECT=50c28366d615eb8fc9fb18a3e2a9780dc5208c6a
B=8748a7a3352c14a6caa5a75b71f869e5d3b8152c

Судился закоммиченный предмет в собственном клоне на OBJECT. Набор артефактов полон: предмет, критерий с командами, названные исполнители и зоны присутствуют. Четыре блокирующие находки предыдущего круга закрыты. Действительных блокирующих находок в разрешённом перечне не осталось. Предмет за пределы мандата delta-critic-117r4 / n117-krug3 не расширялся; новый круг или арбитраж не назначается.

## Закрытие четырёх пунктов

### Б1 — размер и вся маска

`contracts/117-cmp-mob-vkhod-splash.md:170–177`: размер закреплён литералом 390×844; обход половинным масштабом больше не разрешён критерием. `vkhod_static_probe.py:517–560` перебирает все пиксели артборда, отдельно считает всю маску M и все непрозрачные пиксели C, а не проецирует выборку размера C на E.

Независимый проход Pillow по припиненным PNG базы и композитам модели: dark M=C=15439, light M=C=15346, recall=precision=1.0 для обеих схем; sha256 обоих эталонов совпадают с пинами. Свидетели 195×422 (точный aspect, выбор пикселя (2x,2y)) и 39×84 изготовлены отдельно от авторской функции: оба дают static rc1 с двумя именованными `SPLASH_COMPOSITE_ETALON_*`. Авторский `splash-composite-halfres` также красен в полной матрице. Старые sparse/no-words/shifted остаются красными той же семьёй; уменьшение знаменателя до решётки субъекта устранено.

### Б2 — отсутствие legacy и настоящий storyboard

`contracts/117-cmp-mob-vkhod-splash.md:160–167`: проверяется отсутствие самого ключа в root/ios/dark/ios.dark, а не только его эффективная ложность. Выполнены настоящие `getIosSplashConfig`, `getTemplateAsync`, `applySplashScreenStoryboard` установленного expo-splash-screen.

На модели: legacy_at=[], legacy_eff=false, рамка 181×181, constraints=[centerX,centerY]. При ios.enableFullScreenImage_legacy=true: рамка 414×736, constraints=[bottom,leading,top,trailing], static rc1, красна `SPLASH_IOS_STORYBOARD`; тот же именованный отказ в матрице `ios-legacy`. Дополнительно ключ со значением false по очереди внесён во все четыре разрешаемые конфигурацией позиции: каждый полный статический прогон rc1 именно по `SPLASH_IOS_STORYBOARD`, хотя эффективная рамка остаётся правильной. Следовательно, литерал отсутствия не подменён проверкой truthiness.

### С2-а — Image действительно потребляет проверяемый композит

`contracts/117-cmp-mob-vkhod-splash.md:199–202,267–273`: виртуальные jest.mock-сентинели различают модули dark/light, не схлопывая оба PNG в обычную единицу jest-expo. Проверяется эффективный source единственного Image в оверлее, contain и absoluteFill. Статическая клетка разрешает относительные require от pilot-app.tsx к обоим файлам, судимым Б1.

Подмена обоих источников оверлея на icon.png при сохранённых честных композитах: static rc1 (`SPLASH_OVERLAY_CONSUMES_COMPOSITE`), настоящий Jest rc1 — ровно `SPLASH_OVERLAY_COMPOSITE_DARK/LIGHT` красны, остальные 20 клеток зелёные. Полные матрицы обеих семей также отвергают `overlay-wrong-source` по именованным клеткам.

### С2-б — hide после commit с оверлеем

`contracts/117-cmp-mob-vkhod-splash.md:205–208,274–280`: вместо одного invocationCallOrder наблюдается commit через React.Profiler и контейнер test-renderer. Проверяются первый commit с оверлеем, один hide после него и предшествующий prevent.

Живой выбранный прогон на модели rc0: обе схемы дают журнал `["commit+overlay","hide"]` после модульного prevent. Перенос hide из effect в ленивый useState даёт журнал `["hide","commit+overlay"]`: Jest rc1, красны ровно `SPLASH_HIDEASYNC_ORDER_DARK/LIGHT`, остальные 20 клеток зелёные. Стаб `overlay-hide-before-commit` красен и в полной матрице. Прежнее отождествление render и commit больше не пропускает предъявленный обход.

## Обязательные вопросы гейта в пределах дельты

1. Критерий отличает четыре прежних имитации от честной модели — подтверждено красными свидетелями выше, не наличием файлов.
2. У четырёх свойств есть исполнимые команды и именованные отказы. Таблица ниже фиксирует наблюдённые rc; device-визуал ими не подменяется.
3. Размер, пороги, позиции запрещённого ключа, storyboard-рамка/constraints, source каждого Image и момент lifecycle названы в контракте; эти решения исполнителю не оставлены.
4. Дельта находится в зоне architect. Исполнитель продукта и его границы названы в строках 378–400, включая mobile/.maestro/; frozen-батарея 111 и модель 117 в этой дельте не менялись.
5. В судимой дельте противоречий AGENTS.md не установлено. Счёт проверен другой мерой; precision-гейт исполнен живой bash-командой. Ранее принятые границы платформенного визуала не переоткрываются.

## Живые прогоны и rc

H=/tmp/dev-harness-verify/Critic117r4/repo, R=mob либо witness-mob под тем же корнем. Пробы — H/fixtures/workshop_project/vkhod_117/. На время прогонов модель установлена по путям поставки, затем файлы восстановлены; node_modules подключён симлинком из consultant-expo.

| Команда / состояние | Наблюдение |
| --- | --- |
| python3 …/vkhod_static_probe.py --repo R на B | rc1, VKHOD_SPLASH_COMPOSITE_ABSENT |
| python3 …/vkhod_probe.py --repo R на B | rc1, VKHOD_AUTH_DS_ABSENT |
| static --model | rc0, 35/35 |
| behavioral --model | rc0, 22/22 |
| static --matrix | rc0, все 20 стабов именованно красны |
| behavioral --matrix | rc0, все 20 стабов именованно красны |
| независимые 195×422 / 39×84 | static rc1 / rc1 |
| ios legacy=true | static rc1; настоящий storyboard 414×736 |
| legacy=false в root / ios / dark / ios.dark | static rc1 каждый |
| overlay-wrong-source | static rc1; Jest rc1, ровно две composite-клетки |
| hide-в-render | Jest rc1, ровно две order-клетки |
| честный SPLASH_HIDEASYNC_ORDER, выбранный Jest-прогон | rc0, 2/2 |
| node node_modules/jest/bin/jest.js src/bootstrap/__tests__/pilot.test.tsx --runInBand | rc0, 14/14 |
| python3 …/first_run_111/first_run_probe.py --repo R | rc1, 17/19 |
| отдельный сырой Jest-отчёт first_run_111 | rc1, красны РОВНО RESTYLE_GUARD_995_F03_01_DARK/LIGHT (К8) |
| npm run typecheck / npm run lint | rc0 / rc0 |
| bash scripts/check_provodka.sh H contracts/117-cmp-mob-vkhod-splash.md | rc0 |
| bash scripts/check_threat_model.sh H contracts/117-cmp-mob-vkhod-splash.md | rc0 |
| bash scripts/check_precision_gate.sh H contracts/117-cmp-mob-vkhod-splash.md | rc0, OK, последовательный прогон |
| bash scripts/pre_critic.sh --repo H contracts/117-cmp-mob-vkhod-splash.md | rc0, КРИТИК: дверь зелёная |
| git diff --exit-code a378b15c OBJECT -- fixtures/workshop_project/first_run_111/ fixtures/workshop_project/vkhod_117/model/ | rc0 |
| python3 witness.py / python3 boundaries.py | rc0 / rc0; ожидаемые красные дочерние команды проверены assertions |

Первый precision-прогон был запущен параллельно pre_critic и вернул rc0 с ошибками отсутствующего scratch lib_zones. Прочитан механизм self-GC общего для корня scratch; повторный последовательный precision-прогон дал чистый `OK`, rc0. Шум первого запуска не выдан за чистое доказательство; контракт или гейт не менялись.

Н-38, независимая мера: AST словарей MUTANTS = 20+20. Статические клетки: 19 литеральных check/raster_case + 2×5 generated + 2 iOS + 2 composite + 2 sign = 35. Поведенческие: 10 scheme-пар + 2 одиночных recovery = 22. Frozen pilot: 9 одиночных + DIRECT(2) + AUTH(3) = 14; first_run: 1 одиночная + 9 пар = 19. Это счёт исходных объявлений, не повтор stdout проверяемой команды. Pillow отдельно подтвердил числа масок. SHA256 pilot.test.tsx совпал с B: dee6de0bd22a36d7e65711cc436796f4d056f6bdca46441253348df1b7543d17.

## Предел доказательства и доставка

Это accept пригодности контракта к заморозке в разрешённом микро-круге, НЕ приёмка будущей реализации. First-run 111 не объявлен целиком зелёным: до отдельной миграции 111 v2 ожидаемо красны ровно К8. Release APK, Maestro, gh pr checks, Expo Go и iOS-устройство здесь не запускались; совпадение скриншотов с макетами не объявлено доказанным. Эти обязанности приёмки продукта сохранены.

Сырые логи, PNG-свидетели, results.json, independent-evidence.json, boundaries.json, gates.json, Jest JSON-отчёты и скрипты воспроизведения сохранены рядом с verdict.md. Одноразовые клоны удаляются по дисковой политике задания.

Доставка: /tmp/dev-harness-verify/Critic117r4/verdict.md. По явному заданию запись в основной checkout и worktree architect запрещена; этот файл НЕ закоммичен мной. Оркестратор материализует его на ветке предмета под identity critic в workflowPaths.verdicts/critic (например contracts-117-v4.md). До этого нельзя считать вердикт присутствующим на HEAD для freeze. Push не выполнялся.
