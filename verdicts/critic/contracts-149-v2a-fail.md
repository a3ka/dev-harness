FAIL
OBJECT=971a19666e04667969564037e8fffd3826afecef
СУД: repo=dev-harness; предмет=149; фаза=контракт v+1 (+красная батарея); цикл 2, вызов 1/5; модель-план=openai-codex/gpt-6-sol; сессия=Crit149k2a; модель-факт=openai-codex/gpt-6-sol; SHA=971a19666e04667969564037e8fffd3826afecef; предыдущий=frozen/contracts/149/1; исключение=нет. Автор конструкции Arch149q — zai/glm-5.3; независимость подтверждена. HEAD изолированного клона = OBJECT, `git cat-file -t OBJECT` → `commit`; вторая часть commit message содержит дословное РАЗРЕШИЛ-ВЛАДЕЛЕЦ. Суд контракта, не реализации.

## БЛОКИРУЕТ

БЛОКИРУЕТ contracts/149-gespraech-tekst-chat.md:59,72,77 — класс РЕАЛЬНАЯ_ЗОНА_КАСАНИЯ: зелень допускает настоящий компонент с зоной < `touch-target.min`.
ОБЯЗАТЕЛЬСТВО: И-5 требует для каждой обязательной кнопки настоящую hit-area ≥ токена, а не одни координаты из `forma-ekrana.json` или testID; допустима видимая рамка <44, но НЕ зона <44.
СОСТОЯНИЕ: допустимое R с полной пачкой, машиной и jest-средой; в отдельной копии зелёного A-дерева у `Pressable` чат-хоста и композера изменены `minHeight: 44 → 12`, `minWidth: 44 → 12`, без hitSlop. У однострочных кнопок «erzählen»/микрофона высота теперь определяется текстом, меньше 44.
НАБЛЮДЕНИЕ: `W --repo /tmp/dev-harness-verify/Crit149k2a/mut-hit` rc 0, 93/93, настоящий jest suites=1 tests=10. `d-paket-zony` проверяет форму и манифест, `s-ekran-ispolnim` — testID/реакцию, но ни один не проверяет настоящую hit-area.
ОБХОД: уменьшить реальные зоны кнопок, оставив корректными пины макетов и синтетическую карту целей — критерий полностью зеленеет вопреки И-5.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: приёмка отличает на реальном компоненте R зону нажатия от видимой рамки, на обоих профилях проверяет ≥ `touch-target.min`; уменьшение зоны при неизменной форме пачки красно.

БЛОКИРУЕТ contracts/149-gespraech-tekst-chat.md:58,72,73,77 — класс РЕАЛЬНЫЙ_ТОКЕН_ПОЛЯ: пин токенов 1.1 не обеспечивает их потребление реальным композером.
ОБЯЗАТЕЛЬСТВО: И-4 и сценарий 6 требуют потолок настоящего поля из токена пакета `calc(6 * 21px)` (lineHeight(body)=21px), без старого числа Final 2.
СОСТОЯНИЕ: допустимое R с неизменёнными корректными пинами, но `VYSOTA_STROKI = 24` в `mobile/src/ui/conversation-composer/conversation-composer.tsx`; даже исходная референс-раскладка уже имеет литерал `20`, а не 21.
НАБЛЮДЕНИЕ: `W --repo /tmp/dev-harness-verify/Crit149k2a/mut-token` rc 0 93/93, suites=1 tests=10. `d-pole-rastjot` сравнивает два значения пиннованного JSON, `s-ekran-ispolnim` проверяет число строк и флаг прокрутки, но 6×24 реального maxHeight пропускается.
ОБХОД: оставить JSON пакета 1.1 неизменным, а компонент считать высоту по старому литералу — зелень без компактной геометрии поля.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: команды приёмки различают высоту, использованную реальным компонентом, и значение токена; литерал 24 (равно как и 20) вместо 21 красен.

БЛОКИРУЕТ contracts/149-gespraech-tekst-chat.md:74,94 — класс ПОРЯДОК_AVD_393: рецепт и зелёный контроль принимают параллельную работу AVD, хотя решение владельца 31.10 требует запустить 393 ПОСЛЕ остановки первого.
ОБЯЗАТЕЛЬСТВО: второй AVD запускается только после завершения первого, не одновременно с ним.
СОСТОЯНИЕ: `probe.py:1485-1493` порождает зелёный job (`a-derevo2/.github/workflows/mobile.yml:1161-1166`): первый `if ! boot`, сохранение `SERIAL_GL`, переключение на `PORT393`, второй `if ! boot`, экспорт обоих серийников. Между двумя boot нет остановки первого, `cleanup` — только по EXIT.
НАБЛЮДЕНИЕ: `W --repo` на копии именно этого job даёт 93/93; в отчёте автора решение ошибочно обозначено «СОХРАНЕНО». Клетка проверяет количество boot/порт/экспорт, но не порядок остановки и запуска.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: до старта 393 первый AVD гарантированно остановлен, а зелёная команда проверяет это свойство на допустимом job (параллельный job красен).

БЛОКИРУЕТ contracts/149-gespraech-tekst-chat.md:55,60,74 — класс МАСКА_ПРОФИЛЯ_393: сравнение кадров профиля 393 оставляет маску шапки 36 pt вопреки обязательным 48 pt по решению владельца 31.10 (урок суда 147 цикла 2).
ОБЯЗАТЕЛЬСТВО: все кадры профиля 393 сравниваются с маской шапки 48 pt.
СОСТОЯНИЕ: `pachka/kadry-393.json:9` содержит `mera.chrome_verh_pt=36`, у всех 12 записей `elementy[0].bbox_pt[1]=36` (первая — `kadry-393.json:27`). Пакет и product R удовлетворяют остальным предпосылкам.
НАБЛЮДЕНИЕ: `W --model` rc 0 93/93 и `W --repo` rc 0 93/93 с этим набором; автор отнёс решение к 147/148, несмотря на 12 кадров 149.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: все 12 профильных кадров сравниваются с утверждённой маской 48 pt, зелень с 36 pt невозможна.

## САМООПИСАНИЕ — полный список числовых и механических расхождений

САМООПИСАНИЕ contracts/149-gespraech-tekst-chat.md:277: родитель единственного коммита v+1 назван `8467a408e`; `git rev-parse 971a19666^` → `efca9deadcc52093bc93434abca7b69d96203145`.
САМООПИСАНИЕ contracts/149-gespraech-tekst-chat.md:281: число коммитов в диапазонах `check_zones.sh` названо 41958 → в живом прогоне этого клона на OBJECT **42433**.
САМООПИСАНИЕ contracts/149-gespraech-tekst-chat.md:281: число проверенных по зонам названо 9969 → **10068**. Эти два значения отражают текущие refs/историю клона, не изменение зоны 149.

Других расхождений в числах v2 при полном пересчёте не обнаружено: 93=a64+d9+m10+s10, корень 77/16, model 149/7 93/93, stabs 17 KRASEN/SVJAZI 17, tamper 126, repo suites=1 tests=10, 11 канон-пинов, 26 pressables. Пакет 1.1: 188 кадров, 46/46 full, SHA256SUMS 190, 699 touch_targets (under_44=0, видимых <44=16), 872 скалярных листа (`$value`=265, `$type`=264, `final2`=84), 24 кадра зоны, 5 старых неотличимых пар; старый набор ниже порога 10/12 на 390 и 9/12 на 393, контроль всех 24 новых пар 1.000. Все пять мета-файлов побайтово равны `git show origin/main:docs/ux/05_Kompakt_D24/...`; отдельно сверен PNG GA-11_normal_dark_390x844.png. `frames.json:_meta.build=D24-Kompakt-1.1`; состояния GA-13/17 keyboard, остальных normal; 147 71/71, 148 44/44; ceiling 12/1/148. Исторические значения v1 не обозначены текущими.

## Выполненные команды и сырой вывод

Из изолированного клона, последовательно: `W = bash fixtures/workshop_project/gespraech_tekst_149/red_gespraech_tekst_149.sh`.
- `W` rc 1: `клеток 93, зелёных 77, красных 16; режим koren seed 149`; 10 m-* + 6 s-* с `SUBJECT_ABSENT`.
- `W --model` rc 0: `клеток 93, зелёных 93, красных 0; режим model seed 149`; `W --model --seed 7` rc 0: `клеток 93, зелёных 93, красных 0; режим model seed 7`.
- `W --stabs` rc 0: `STAB pole-bez-potolka KRASEN pole-shest-strok`, `STAB pole-bez-skrolla KRASEN pole-shest-strok`, `STAB lekalo-obhod-kritika KRASEN s-lekalo-instanciirovano`, `STAB ekran-minimalnyj KRASEN s-pachka-validirovana`, `STAB jest-krasnyj KRASEN s-ekran-ispolnim (ISPOLNIMYJ_KONTROL_KRASEN)`, `STAB jest-zelenyj KRASEN s-ekran-ispolnim (ISPOLNIMYJ_MUTANT_ZHIV)`, `SVJAZI 17`, `клеток 93, зелёных 93, красных 0; режим stabs seed 149`; остальные 11 STAB также KRASEN. `W --stabs --seed 7` rc 0: `SVJAZI 17`, `клеток 93, зелёных 93, красных 0; режим stabs seed 7`.
- `W --oracle-tamper` rc 0: `ORACLE_TAMPER_PROVERENO nositelej=126`.
- `python3 /tmp/dev-harness-verify/Arch149p/mera_par.py` rc 0: `NEW < 0.6: 0; OLD >= 0.6 (живые): 5`; GA-11 dark 390 OLD=0.562, GA-18 dark 390 OLD=0.315, GA-17 light 393 OLD=0.656; новые 24 пары score=1.000.
- `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model` rc 0; `bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --model` rc 0: `клеток 71, зелёных 71, красных 0`; `bash fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh --model` rc 0: `клеток 44, зелёных 44, красных 0`.
- `bash scripts/pre_critic.sh contracts/149-gespraech-tekst-chat.md` rc 0: `КРИТИК: дверь зелёная`; `bash scripts/check_ceilings.sh /tmp/dev-harness-verify/Crit149k2a/repo` rc 0: `потолки в порядке`; `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Crit149k2a/repo contracts/149-gespraech-tekst-chat.md` rc 0: `OK`; `bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Crit149k2a/repo contracts/149-gespraech-tekst-chat.md` rc 0: `модель угроз: секция валидна (ЗАЩИЩАЕТ 14 буллет(ов), НЕ ЗАЩИЩАЕТ 10 буллет(ов))`; `bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Crit149k2a/repo contracts/149-gespraech-tekst-chat.md` rc 0 `OK`; `bash scripts/check_provodka.sh /tmp/dev-harness-verify/Crit149k2a/repo contracts/149-gespraech-tekst-chat.md` rc 1: `проводка: guard не подключён: fixtures/workshop_project/gespraech_tekst_149/red_gespraech_tekst_149.sh не вызывается в .githooks/ или .github/workflows/` (до CI-зоны orchestrator ожидается); `bash scripts/check_zones.sh` rc 0: `замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 42433 · проверено по зонам: 10068`.

Атака 1: `cp -a /tmp/dev-harness-verify/Arch149p/a-derevo2 /tmp/dev-harness-verify/Crit149k2a/mut-hit`; `python3 /tmp/dev-harness-verify/Crit149k2a/mutate_hit.py` (44→12, только копия); `W --repo /tmp/dev-harness-verify/Crit149k2a/mut-hit` rc **0**. Сырой вывод, решающие строки (все остальные CASE из 93 также `ok`, полный stdout — в трейсе команды):
```
ISPOLNIMYJ kontrol ZELEN — suites=1 tests=10
ISPOLNIMYJ mutant host-pustoj UBIT — упавших ассертов 6
ISPOLNIMYJ mutant kompozer-ne-izmenen UBIT — упавших ассертов 10
CASE d-paket-zony ok 
CASE d-pole-rastjot ok 
CASE s-lekalo-instanciirovano ok 
CASE s-pachka-validirovana ok 
CASE s-ekran-ispolnim ok 
клеток 93, зелёных 93, красных 0; режим repo seed 149
```
Атака 2: `cp -a /tmp/dev-harness-verify/Arch149p/a-derevo2 /tmp/dev-harness-verify/Crit149k2a/mut-token`; `python3 /tmp/dev-harness-verify/Crit149k2a/mutate_token.py` (20→24, только копия); `W --repo /tmp/dev-harness-verify/Crit149k2a/mut-token` rc **0**. Сырой вывод, решающие строки (остальные CASE из 93 также `ok`, полный stdout — в трейсе команды):
```
ISPOLNIMYJ kontrol ZELEN — suites=1 tests=10
ISPOLNIMYJ mutant host-pustoj UBIT — упавших ассертов 6
ISPOLNIMYJ mutant kompozer-ne-izmenen UBIT — упавших ассертов 10
CASE d-paket-zony ok 
CASE d-pole-rastjot ok 
CASE s-lekalo-instanciirovano ok 
CASE s-pachka-validirovana ok 
CASE s-ekran-ispolnim ok 
клеток 93, зелёных 93, красных 0; режим repo seed 149
```
Третий и четвёртый классы дополнительно доказаны фиксированными данными и зелёным контролем без эмуляторов. Не проверено: Android-эмулятор, нативная сборка, живой CI/диаг-PR продукта по SHA (запрещены заданием/требуют freeze 147/148), реальный экран после implementer. `--repo` запущен на реальном A-дереве продукта с референс-компонентами, два мутанта — только в отдельном одноразовом дереве каждый. Заявленные ограничения на Release-байты и системную клавиатуру оставлены без новых блокеров.
