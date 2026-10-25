# Контракт 138 — start-ekran: экран Start mob по шаблону 132 (id плана `start-ekran`, после Erstinformation 118)

КЛАСС ЗАДАЧИ: КОДОВЫЙ (красная батарея экрана по шаблону 132). Номер выдан механизмом (тег `id/CONTRACT/138`, строка реестра на origin/main `7b9855338`). ВЕРСИЯ: v1.

КЛАСС РИСКА: обычный — по таблице осей у Start нет собственных прав/денег/auth-решений: экран потребляет допуск W1A ∧ gate current из 118 (frozen), данные миссий — портом 108; все клетки осей (кадр × тема × состояние × источник × допуск × переходы) судятся сверкой и структурой, не новой полномочной логикой.

## Воля владельца (источники)

- `docs/owner/2026-10-22-ochered-ispolzeniya.md` §Mob п.3 (слово 2026-10-24): Start сразу после Erstinformation (118); кадры F04.01 (тёмный Start = F04.01, D-06), F04.07, F04.08, F04.13 — обе темы пакета 3 дизайнера; контекст CMP-MOB-004/011.
- `docs/owner/2026-10-21-ekrany-bystree.md` §Решение п.1–2: один экран — один контракт, сверка кадров с PNG; 132 — форма, 123 — мера/порог; 135 — первый экран по шаблону (образец).
КОНТЕКСТ: измеренная боль (тот же документ §Боль): экраны, поделённые между контрактами и судимые макетом текстом, стоили 12 кругов и 7 форков; 132/135 перевели экраны на машиночитаемую форму и сверку кадров.
КОНТЕКСТ: варианты F04.V03 (ошибка агента) / F04.V04 (уменьшение анимации) — состояния того же экрана (манифест пакета 3: base_frame F04.01), но их копия ещё PROPOSED и в каталог не принята; решение по таблице осей — вне предмета (§Незаполненные требования), не молчаливое сужение.

## Существующее

- Контракт 132 (frozen 132/1): форма ekran.json (17 полей), валидатор — субъект `scripts/ekran_shablon.py` (в main; эталон `fixtures/workshop_project/ekran_shablon_132/model/ekran_shablon.py` — судья батареи, читается не копируется); живые пачки обнаружения — `model/fiktura/pachta_{chuzhogo,tot_zhe}` (fiktura: false).
- Контракт 123 (frozen 123/2): раннер сверки `scripts/sverka_maketa.py`, порог 0.6, элементы/maski/check_pokrytie; мера манифеста наследуется дословно.
- Контракт 135 (frozen 135/1): первый экран по шаблону — форма батареи экрана (source.json/kejsy/stab_vhod, второй субъект происхождения, перекодированные носители); 138 повторяет приёмы, не копируя слепо (расхождения — §Сдача).
- Контракт 118 (frozen 118/1): production путь допуска `/` → First-Run → demo → Erstinformation → continue при current → Start с вкладками (start_tabs + start_tab_{start,vorgaenge,schutz,post}); прямой `/start` без допуска ведёт назад. Реализация и пробы допуска — 118, НЕ 138.
- Контракт 108 (frozen 108/1): `mobile/src/features/start/` (start-screen, слот TabShell), миссии/аватар — listMissions порта @pilot/runtime (OpenAPI MissionPage); `mobile/src/app/`, `mobile/src/mocks/`, `mobile/src/api/api-client.ts`, `mobile/src/bootstrap/tab-shell.tsx` — зоны 108/995.
- Каталог копии: `BrokerOS_UI_Copy_DE.json` (frame.F04.01/07/08/13.title/.body, action.F04.A01–A03, ia115.entry.*, ui.mission.*, resume.*, home.voice, ui.start.no_action_scoped — verbatim, сняты 2026-10-25); токены — `docs/ux/03_Mobility_Slice1/ds/tokens.css`; исправления дизайнера D-01…D-07 — README пакета 3 (D-06: тёмный Start = F04.01).
- Уроки 118 применены с первой редакции: appId из mobile/app.json (com.complior.mobile), исключение флоу пачки из общего прогона каталога (config.yaml), селекторы с носителями, состав Start по вкладкам, запрет deeplink-обхода допуска.

## Нарезка (frontier)

- **А. Пачка экрана в харнессе** — отклонено (мера Ж 132): пачка сопровождает экран в репо продукта (`mobile/e2e-start/`), харнесс несёт только красную батарею.
- **Б. Кадры-носители = байтовые копии макетов** — отклонено: копия кадра = макету байт-в-байт ложно засчитывается проверкой происхождения; выбраны перекодированные кадры (пиксели равны, байты отличны, score 1.000 — замер прогона), как 135.
- **В. Элементы манифеста — по грамматике раннера 123 (выбрано):** полосы чернил считаются импортом самого раннера (единый источник), тёмные кадры несут семантические имена (znak/zagolovok/cta/tabbar/…), светлые — одна полоса ekran (чернила по всей сетке; приём 135); покрытие check_pokrytie зелено по построению.
- **Г. Граница допуска с 118 (выбрано):** батарея судит КЛАСС входов «обход допуска» на флоя пачки (deeplink вместо production пуска, отсутствие пути First-Run → demo → Erstinformation → continue → состав вкладок — FLOW_BEZ_DOPUSKA/FLOW_BEZ_ZAPUSKA), но реализация gate-маршрута остаётся 118: клетки батареи не дублируют пробы композиции 118, а предъявляют флоу пачки.
- **Д. V03/V04 (варианты) — вне предмета (выбрано):** состояния того же экрана (замер пикселей: 9.0% и 1.4% отличий от F04.01), но копия ui.agent.unavailable / ui.a11y.reduced_motion — PROPOSED, каталог её не принял; включение вынудило бы экран нести текст мимо каталога. Ловец — принятие копии → v+1 пачки; молчаливого сужения нет (§Незаполненные требования).

## Предмет и граница

Один наблюдаемый результат: **экранная пачка start-ekran (ekran.json + контракт одной страницы + манифест восьми кадров + файлы батареи, репо продукта `mobile/e2e-start/`) судится валидатором 132 И проверкой доступных свидетельств происхождения: rc 0 — форма верна, кадры не ниже порога, флоу идёт production путём допуска 118, перед каждым кадром переход и assertVisible СВОЕГО селектора состояний, appId равен пакету app.json, флоу исключён из общего прогона каталога, ни один кадр не является байтовой копией макета; нарушения названы по имени с rc 1/2.** Красная батарея харнесса доказывает обе проверки на данных Start до реализации; сам процесс эмулятора шаблон 132 не аттестует (§НЕ ЗАЩИЩАЕТ).
Вне предмета: сам валидатор (132), мера/порог (123), маршрут/gate допуска и его пробы (118), источник данных миссий/аватар (108: listMissions, mocks, api-client), TabShell/корень (108/995), V03/V04 (копия PROPOSED), шаг доводки (133), правка макетов и каталога продукта, проводка self-test батареи в CI харнесса (оркестратор, образец 132).

## Инварианты

1. Форма пачки — шаблон 132 дословно: 17 полей, замкнутые алфавиты, ЗОНА-строки контракта пачки = zony; контракт пачки ≤ 60 строк И ≤ 120 символов И ≤ 4000 байт (замер пачки: 57 строк / 108 символов / 3747 байт).
2. Один экран — один контракт: zamenjaet = null (живого манифеста Start в обоих корнях нет — замер обнаружения), ne_trogaet — живые пачки чужих экранов обоих корней: фиктуры 132, Splash 117, пачки First-Run/F03 (135) и Erstinformation (118) в продукте; пересечение id пусто (живая пачка Start в --repo — красный вход).
3. Кадры: 4 состояния (idle/composer/decision/resume) × dark/light, макеты `docs/ux/03_Mobility_Slice1/screens/F04.0X(.png|-Hell.png)` с пинами sha256 (сняты 2026-10-25), порог 0.6, maski_pt пусты (хром экранирует мера 123); элементы — полосы чернил грамматикой раннера, тёмные кадры — семантические имена, худшая область адресна (derive полосы знака → score 0.000 hudshij=znak — замер).
4. В пачке нет литералов цветов и размеров: единственное место — аудит токенов продукта; ключи копии — verbatim из каталога (25 ключей — замер среза); operacii_api = listMissions (OpenAPI MissionPage, проекция спеки в пачке).
5. Приёмка исполняется фактическим argv: e2e rc 0 и кадры СВЕЖИ (Maestro-раскладка `mobile/maestro-out-start`), сверка — дословный вывод раннера 123 по манифесту пачки.
6. Оракул батареи — source.json в памяти до вызова субъекта; носители (16 PNG) — sha256-пины; несоответствие — ORACLE_TAMPERED rc 2.
7. Проверка происхождения (`batareja/proverka_proiskhozdenija.py`, второй субъект): production путь допуска (launchApp → first-run-continue → auth-demo-entry → erstinfo_gate_current → erstinfo_continue_start → start_tabs + КАЖДАЯ вкладка), перед каждым кадром переход и assertVisible СВОЕГО селектора (`F04.01` → start_sostojanie_idle, `F04.07` → start_sostojanie_composer, `F04.08` → start_sostojanie_decision, `F04.13` → start_sostojanie_resume — testID в `mobile/src/features/start/`); appId флоу == expo.android.package mobile/app.json; исключение флоу в flows конфига `mobile/.maestro/config.yaml`; манифест — ровно 8 кадров (4 snimok × dark/light); кадр байт-идентичный своему PNG-макету — не скриншот.

## Приёмочный критерий

Обозначения: `W` = `bash fixtures/workshop_project/start_ekran_138/red_start_ekran_138.sh`; `P` = `python3 fixtures/workshop_project/start_ekran_138/probe.py`.
1. Дано: дерево без `scripts/ekran_shablon.py`; когда: `W`; тогда: rc 1, строка `SHABLON_ABSENT` и 20 строк `CASE <вход> KRASNO (SHABLON_ABSENT)` — перечень красных предъявлений (замер: 20).
2. Дано: эталон 132 и проверка происхождения пачки; когда: `P --model`; тогда: rc 0, 20 строк `CASE <вход> ok` (замер: 20/20); честный экран: восемь `KADR <кадр> 1.000 0.600 G OK` + `SHABLON start-ekran OK`, зелёный контроль проверки: `proiskhozdenie-chistyj` rc 0 после stand-in e2e (это НЕ свидетельство работающего Android).
3. Дано: модель и 14 обманных стабов; когда: `P --stabs`; тогда: rc 0, контроль 20/20 ok, 16 строк `STAB <стаб> <вход> KRASEN`, финал `SVJAZI 16`, живых стабов 0 (замер: 16/16). Негатив: стаб, прошедший свой вход, — rc 1 `STAB_ZHIV: N`; правка PNG-носителя либо рассинхрон stubs/ ↔ stab_vhod — rc 2 `ORACLE_TAMPERED`.
4. Красные входы (ожидания построчно в kejsy, все — замер прогона): `literal-cveta` → `LITERAL_VNE_AUDITA batareja/red_ekrana.sh:7`; `kadr-nizhe-poroga` → `KADR_NIZHE_POROGA F04.01 dark score=0.000 porog=0.600 hudshij=znak`; `chuzhoj-kadr` → `CHUZHIE_KADRY F02.03-V01 dark`; `zamenjaet-pustoj`/`ne-trogaet-pustoj`/`zhivaja-pachta-v-repo` → `ZAMENJAET_NE_POLON`/`NE_TROGAET_NE_POLON` (по числу живых пачек); `kontrakt-slishkom-dlinnyj`/`kontrakt-shirokij` → `NE_ODNA_STRANICA` (97 строк/5047 байт; ширина 6900/16648 байт); `kadry-ustarevshie` → `KADR_USTAREVSHIJ` на 8 кадров; `e2e-ne-proshla` → `E2E_NE_PROSHLA rc=3`. Восемь входов происхождения: `proiskhozdenie-byte-kopija` → `KADR_BYTE_KOPIJA_MAKETA F04.01 dark`; `proiskhozdenie-flow-bez-perehoda` → `FLOW_BEZ_PEREHODA`/`FLOW_BEZ_DOSTIZHENIJA`/`SELEKTOR_NE_KADRA` по трём кадрам + `FLOW_BEZ_DOPUSKA`; `proiskhozdenie-flow-appid-chuzhoj` → `APPID_NE_PAKETA com.complior.demo != com.complior.mobile`; `proiskhozdenie-config-bez-iskljuchenija` → `CONFIG_BEZ_ISKLJUCHENIJA`; `proiskhozdenie-deeplink` → `FLOW_BEZ_ZAPUSKA launchApp` + `FLOW_BEZ_DOPUSKA`; `proiskhozdenie-selektor-bez-ekrana` → `SELEKTOR_BEZ_EKRANA start_sostojanie_composer`; `proiskhozdenie-selektor-ne-kadra` → `SELEKTOR_NE_KADRA start-ekran-f04-07`; `proiskhozdenie-start-pustoj` → `SELEKTOR_BEZ_EKRANA` на четыре вкладки.
5. Дано: реализация экрана (implementer, репо продукта): пачка `mobile/e2e-start/` (в т.ч. `batareja/proverka_proiskhozdenija.py` побайтово = пин H), экраны start, флоу `mobile/.maestro/start-ekran.yaml`, исключение в `config.yaml`; когда: продуктовый `mobile.yml` вызывает реальный Maestro через `priemka.e2e` в обоих theme-вариантах и оставляет кадры в `kadry_dir`, затем подряд без промежуточной правки кадров валидатор 132, сравнение файла проверки с пином H и сама проверка; тогда: rc 0 каждой команды; кадры ниже порога, подмена файла проверки или кадров — именованный отказ. Живой прогон — после ленда экрана (замер оркестратора), батарея этого пункта не заменяет.

## Зоны и исполнители

ЗОНА architect: contracts/138-start-ekran.md fixtures/workshop_project/start_ekran_138/
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/

ЗОНА implementer: mobile/src/features/start/ mobile/.maestro/ mobile/e2e-start/ .github/workflows/mobile.yml

ПЕРЕСЕЧЕНИЕ implementer: mobile/src/features/start/ — 108 зона экрана Start на этом пути; 138 владеет путём как наследник экрана по слову владельца 2026-10-24 (порядок экранов §Mob п.3), правки 108 не трогает
ПЕРЕСЕЧЕНИЕ implementer: mobile/.maestro/ — 118 зона флоу e2e (также владельцы 107/117/135); 138 добавляет start-ekran.yaml и строку исключения в config.yaml, чужие флоу не правит
ПЕРЕСЕЧЕНИЕ implementer: .github/workflows/mobile.yml — 117 зона пина H; 138 переставляет пин на пачку экрана по образцу 123/135, чужие шаги не правит

`mobile/src/app/` — НЕ зона 138: сверено по `frozen/contracts/118/1^{commit}:contracts/118-erstinformation.md` (ЗОНА implementer 118 включает путь: маршрут и gate монтирования `/start` — реализация 118). `mobile/src/mocks/`, `mobile/src/api/api-client.ts`, `mobile/src/bootstrap/tab-shell.tsx` — НЕ зона: сверено по `frozen/contracts/108/1^{commit}:contracts/108-cmp-mob-004-start.md` (зоны 108/995). Исполнитель 138 меняет только слой отображения start; источник данных (listMissions, моки) и корень не трогает.

Записей-пересечений у зон architect нет: батарея и контракт новые; батареи 108/118/123/132/135 читаются, не меняются (регресс соседей — §Сдача). Проводка self-test батареи в CI харнесса кладёт ОРКЕСТРАТОР интеграционным коммитом (образец 132). Работа implementer раздаётся после accept критика и freeze v1.

ПРЕДПОСЫЛКИ:
- setting батарея работает без сети, gh, секретов и переменных окружения (16 PNG-носителей с пинами sha256; кадры перекодированы, макеты — байтовые копии продукта).
- setting раннер 123 и эталон 132 в дереве харнесса — их отсутствие rc 2 SVERKA_123_ABSENT, не зелень.
- setting продуктовый CI имеет Android-эмулятор, Maestro CLI, checkout принятого H-пина с файлом проверки 138; новых секретов, variables, environments и настроек репозитория не требуется; пробы Г0/допуска 118 в том же quality-job остаются зелёными ДО признания экрана.

## ПРОВОДКА

ПРОВОДКА:
- guard=fixtures/workshop_project/start_ekran_138/red_start_ekran_138.sh

ПРОВОДКА-ЭНФОРСМЕНТ: норма владельца «Start сразу после Erstinformation, кадры по PNG, один экран — один контракт» получает механический гейт: батарея красна по 20 входам валидатора 132 и проверки происхождения пачки, 16 связей стабов; self-test CI харнесса `bash fixtures/workshop_project/start_ekran_138/red_start_ekran_138.sh --stabs` (до ленда экрана, после — безфлаговый red-режим). Продуктовый quality-job запускает валидатор 132 (e2e + сверка 123), сравнение файла проверки с H-пином, саму проверку кадров/flow и прежние пробы 118; отдельный rc 0 валидатора не означает приёмку экрана.

## Модель угроз

Субъекты батареи — валидатор 132 (грамматика 041 уже его) и файл проверки происхождения из пачки; второй получает пачку и repo ПОСЛЕ суда формы 132 в продукте. Имена кадров/тем и пути заданы принятой грамматикой манифеста 123/формы 132; шаги flow сопоставляются литерально (launchApp/tapOn/assertVisible/takeScreenshot/testID), имена — точным равенством строк, не подстрокой; appId читается из app.json продукта, не из литерала батареи; исключение конфига — литеральная строка элемента списка flows. Оракул 138 — source.json в памяти до вызова субъектов и sha256 носителей.

ЗАЩИЩАЕТ:
- от подмены данных экрана: пины sha256 всех 16 носителей (макеты F04 и перекодированные кадры) — правка файла rc 2 ORACLE_TAMPERED; рассинхрон stubs/ ↔ stab_vhod — rc 2;
- от зелени без реализации: безфлаговый режим без `scripts/ekran_shablon.py` — rc 1 SHABLON_ABSENT с перечнем 20 входов;
- от слабого судьи и слабой проверки происхождения: 14 обманных стабов, 16 связей; входы byte-kopija/flow-bez-perehoda/appid/config/deeplink/selektor-bez-ekrana/selektor-ne-kadra/start-pustoj по коду краснят удаление соответствующей ветви по отдельности (Н-39: привязка — stab_vhod source.json);
- от прямого replay макета вместо скриншота продукта: каждый кадр сравнивается по sha256 со своим макетом (KADR_BYTE_KOPIJA_MAKETA rc 1);
- от обхода допуска в флоя пачки: deeplink и отсутствие production пути (First-Run → demo → Erstinformation → continue → состав вкладок) — FLOW_BEZ_ZAPUSKA/FLOW_BEZ_DOPUSKA;

НЕ ЗАЩИЩАЕТ:
- семантику процесса эмулятора и связь файлов с Maestro: перекодированная копия PNG (байты ≠, пиксели =) пройдёт байтовые условия; ловец — живой Maestro в CI, шаги tapOn/assertVisible и ревью; остаток шаблона 132 → 132 v+1, не правка 138;
- реализацию gate-маршрута `/start` (просроченная/пустая сессия, W0): предмет 118 (frozen), его пробы композиции; батарея 138 судит только флоу пачки;
- источник данных состояний (моки, api-client): зоны 108/995; флоя пользуется портом, подмена данных поймается сверкой кадров, не батареей;
- кадры V03/V04 (копия PROPOSED) и светлые макеты будущих состояний: ловец — принятие копии в каталог → v+1 пачки;
- смысл копии и качество макета (суд каталога и ревью) — тот же остаток, что у 123/132/135.

## Демаркация

Конформные входы (грамматика шаблона 132): пачки, чья ekran.json удовлетворяет замкнутым алфавитам, с существующими файлами; для происхождения — Maestro-flow с именами snimok манифеста, принятого 132, деревом исходников start/onboarding/auth/app и app.json продукта. Валидный контрпример = инвариантность к значениям ∧ расхождение на конформном входе: литерал hex в файле пачки; кадр с залитой полосой знака (score 0.000 < 0.600); id чужого кадра Erstinformation в манифесте при покрытом сценарии; живая пачка start-ekran в --repo; контракт 97 строк либо шириной 6900; кадры дозапусковой ревизии при повторном e2e; e2e rc 3; байтовая копия PNG-макета; openLink вместо launchApp; чужой appId; конфиг каталога без исключения; селектор состояния без носителя; селектор чужого состояния при корректном testID; вкладки состава без носителей при голом start_tabs. Неконформные входы (битый PNG, пустой flow, отсутствие app.json) — PROVERKA_NECHITAEM rc 2, не контрпримеры.

## Незаполненные требования:

- кадры F04.V03 (avatar_state=unavailable) и F04.V04 (reduce_motion): состояния того же экрана (замер отличий 9.0%/1.4% пикселей), копия ui.agent.unavailable/ui.a11y.reduced_motion — PROPOSED, каталог не принял; включение по принятию — v+1 пачки.

## Сдача

- Батарея (замеры прогонов этой пачки, числа из вывода): red-режим без субъекта → rc 1 `SHABLON_ABSENT` + 20 KRASNO; `P --model` → rc 0, 20/20 ok (восемь `KADR … 1.000 … OK` у честного экрана; `proiskhozdenie-chistyj` rc 0); `P --stabs` → rc 0, контроль 20/20, 16 строк `STAB … KRASEN`, `SVJAZI 16`, живых 0. Вторая мера: source.json — kejsy 20, stab_vhod 14 стабов, связей 16, носителей 16, кадров 8.
- Контракт пачки: 57 строк / 108 символов / 3747 байт — «на одну страницу» тремя мерами 132.
- Регресс соседей не изменён: 135 `--stabs` rc 0 (SVJAZI 13), 118 батарея rc 0 (SVJAZI 37), 132 `--stabs` rc 0 (SVJAZI 38) — замеры прогонов этой пачки.
- Расхождения с 135 и причины — в докладе архитектора; полная таблица осей — в докладе (оси: кадр × тема × состояние × источник данных × допуск/сессия × переходы).
- Дальше: критик → freeze v1 → implementer (экран + пачка в репо продукта по ЗОНА implementer) → судьи (обычный класс: ревьюер); проводка self-test — оркестратор.
