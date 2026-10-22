# 118 — Erstinformation (экран по шаблону 132)
КЛАСС ЗАДАЧИ: КОДОВЫЙ. id/CONTRACT/118; до V-2.
КОНТЕКСТ: docs/owner/2026-10-20-mob-po-maketu.md §Решение Б,В: путь от First-Run до Start, каждый кадр по PNG.

## Существующее
Слово владельца: First-Run → вход/демо (135) → Erstinformation (118) → Start с вкладками; dark/light.
107/erstinfo_107: gate, ack/version, F02.03/05/08; портовое испытание 107 НЕ доказывает production-композицию.
135-first-run-ekran: First-Run/F03, селектор demo; 123: scripts/sverka_maketa.py и check_pokrytie; 132/1: форма, кадры, зоны.
117/2 frozen: `mobile/src/bootstrap/pilot-app.tsx` — действительный вход `/`, frame/handleDemoEntry/handleVerify, Г0 белого корня F03; экран 135 оставляет этот файл вне своей зоны. 995/111 и пробы 117/2 сохраняются. Макеты: docs/ux/03_Mobility_Slice1/screens/F02.03*,F02.08*; макета Start в docs/ux НЕТ (инвентарь тёмных кадров: B01–B13, F02.03/F02.08, F03.01/02, MOB-*, без Start).

## Предмет и граница
Одна пачка mobile/e2e-erstinformation/ + UI F02.03/F02.08; F02.05, ack и gate-предикат остаются 107. 16 кадров: F02.03 V01/V02 MISSING/OUTDATED (full+V0) и F02.08 V01–V04 CHECKING/PENDING/CURRENT_CONFIRMED/FAILED × dark/light. Copy/review_status: BrokerOS_UI_Copy_DE.json; API: getDisclosureGate.
Принимается СВЯЗНЫЙ пользовательский путь: запуск production `/` → First-Run → нажатие demo → F02.03 → F02.08 → нажатие continue при current gate → Start с вкладками Start · Vorgänge · Schutz · Post, наблюдаемыми КАЖДАЯ своим testID; при null и stale gate Start недоступен. Отдельный deep link на Erstinformation НЕ заменяет путь. Кадр Start по PNG-макету вне пачки: макета Start нет (Незаполненные требования).

## Зависимость замороженного корня (выбор границы)
Выбрана миграция 117 v+1 как ПРЕДПОСЫЛКА, а не фиктивный обход bootstrap через `mobile/src/app/`. До раздачи правки production-маршрута: отдельный согласованный и замороженный v+1 текста/охран 117 объявляет узкую смену `pilot-app.tsx` для demo → Erstinformation и допуска current → Start, сохраняя Г0 F03 и остальные 117-пробы; новый вердикт миграции обязателен. Без такого frozen-тега 118 НЕ РАЗРЕШАЕТ править bootstrap и НЕ МОЖЕТ быть объявлен продуктово done. Команда проверки тега (rc 0 = миграция заморожена): `git fetch origin --tags && git rev-parse --quiet --verify refs/tags/frozen/contracts/117/3 >/dev/null`; на дереве круга 2 rc 1 — тега нет. Санкция владельца на изменение frozen 117/2 — отдельный форк до правки, не молча. После миграции исполнитель 118 получает этот путь явно и меняет только композицию переходов; белый корень F03 остаётся под Г0 (прогон обеих тем). Риск до миграции: экранная пачка может быть зелёной, пользовательский путь всё ещё оборван; это НЕ принятая поставка 118.

## Инварианты
1. ekran.json: 17 полей 132, ekran=erstinformation; 16 кадров, PNG/sha256 из source.json; zamenjaet=null (живого манифеста этого экрана нет), ne_trogaet — обе чужие пачки 132.
2. Цвет/размер только в docs/ux/03_Mobility_Slice1/ds/tokens.css, не пачке.
3. Манифест каждого кадра выделяет самостоятельные bbox_pt значимых элементов по сетке 123: бренд, состояние, заголовок, описание, карточка, статус, действия; у «Dokument öffnen» нижняя область НЕ сливается с экраном/верхней кнопкой. check_pokrytie покрывает чернила; `score_frame` берёт худшую область, каждый KADR ≥ 0.600. Для длинных F02.03 bbox в координатах 390×844 раннера 123, не нативной высоты PNG.
4. Маэстро запускает production `/` (никакого openLink/startApp), наблюдает First-Run, нажимает demo, assertVisible СВОЕГО кадра перед каждым takeScreenshot, заканчивает нажатием continue после confirmed gate и наблюдением СОСТАВА назначения: assertVisible узла start_tabs и КАЖДОЙ из четырёх вкладок своим testID — start_tab_start, start_tab_vorgaenge, start_tab_schutz, start_tab_post; голый `testID="start_tabs"` без вкладок — не Start. Отдельно на null и stale видит маркер gate и assertNotVisible Start до current; при null/stale нажатие continue НЕ даёт перехода. Контракт 107 остаётся источником допуска: W1A ∧ CURRENT_CONFIRMED ∧ точная версия/evidence; 118 не вводит второй gate.
5. Android e2e оставляет свежие кадры обеих тем, не byte-copy PNG. Product CI запускает реальный Maestro, сверку 123, pinned H файл проверки происхождения БЕЗ промежуточной замены кадров; интеграционная проба production-композиции `pilot-app` инъецирует gate=null и stale и отвергает переход к Start после действия continue; на current допускает переход только при ФАКТИЧЕСКОМ admission пользователя — источник admission внешний по отношению к пробе (сессия/проверяющий), W0 с полным current-снимком НЕ допускается, W1A — допускается; захардкоженный в pilot-app admission="W1A" — обход. Это другой шов, нежели портовые пробы 107.

## Приёмочный критерий
W = `bash fixtures/workshop_project/erstinformation_118/red_erstinformation_118.sh`.
Дано: нет scripts/ekran_shablon.py; когда: W; тогда: rc 1, SHABLON_ABSENT и CASE KRASNO по каждому входу (25).
Дано: эталон 132 и пинованные макеты; когда: W --model; тогда: rc 0, все CASE ok, 16 KADR 1.000 0.600 (худшая самостоятельная область или G).
Дано: эталон и адресные стабы; когда: W --stabs; тогда: rc 0, все CASE ok, по каждой связи `STAB ... KRASEN`, непойманных 0, SVJAZI 22; подмена oracle/носителя → rc 2 ORACLE_TAMPERED.
Красные входы маршрута: `proiskhozdenie-bez-demo` → FLOW_BEZ_DEMO_VHODA; `proiskhozdenie-deeplink` (экран через openLink вместо demo) → FLOW_BEZ_ZAPUSKA и FLOW_BEZ_DEMO_VHODA; `proiskhozdenie-gate-null-propusk` и `proiskhozdenie-gate-stale-propusk` каждый → свой FLOW_GATE_NE_PROVEREN; `proiskhozdenie-bez-start` → FLOW_BEZ_START; `proiskhozdenie-start-pustoj` (production рендерит после continue голый `testID="start_tabs"` вместо TabShell) → SELEKTOR_BEZ_EKRANA по каждой из четырёх вкладок; `kompozicija-admission-w0-propusk` (pilot-app всегда подаёт admission="W1A" при полном current-снимке) → KOMPOZICIJA_W0_PROPUSHCHEN. Адресные стабы s23–s29 и связи — в коде probe.py/source.json (Н-39). `proiskhozdenie-flow-bez-perehoda` продолжает требовать движение между кадрами.
Красный вход кнопки: `kadr-cta-skryt` закрашивает нижнюю кнопку на F02.08-V01 dark, ожидает rc 1 KADR_NIZHE_POROGA `hudshij=dokument-oeffnen`; глобальный скор 0.600 пропустил бы эту порчу. Адресный стаб судится кодом батареи. Большой удалённый участок `kadr-nizhe-poroga` остаётся самостоятельным входом.
Дано: продукт с замороженной миграцией 117 v+1 (команда проверки тега — раздел «Зависимость замороженного корня», rc 0) и реализацией 118; когда: W, затем `bash mobile/e2e-erstinformation/e2e.sh erstinformation` → rc 0 (свежие кадры обеих тем), `python3 mobile/e2e-erstinformation/batareja/proverka_proiskhozdenija.py --pack mobile/e2e-erstinformation --repo . --harness "$HARNESS_ROOT"` → rc 0 (pinned H, происхождение без промежуточной замены кадров), проба bootstrap-композиции `cd mobile && npx jest src/bootstrap/__tests__` → rc 0 (gate=null/stale → Start не допущен; admission=W0 при полном current-снимке → не допущен; admission=W1A из внешнего источника → допущен), Г0 dark/light; тогда: каждый rc 0, снимки совпадают с макетом по составу, раскладке, отступам, шрифтам, цветам; отрицательный gate без перехода и положительный Start с четырьмя вкладками доступны на production `/`. Гейт, запущенный без входа `/` либо без проб null/stale/W0, НЕ является приёмкой.

## Зоны и исполнители
ЗОНА architect: contracts/118-erstinformation.md fixtures/workshop_project/erstinformation_118/
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА implementer: mobile/src/features/onboarding/ mobile/src/app/ mobile/.maestro/ mobile/src/bootstrap/pilot-app.tsx mobile/src/bootstrap/__tests__/ mobile/e2e-erstinformation/ .github/workflows/mobile.yml
ПЕРЕСЕЧЕНИЕ implementer: mobile/src/features/onboarding/ — 107 UI; gate/ack не меняются.
ПЕРЕСЕЧЕНИЕ implementer: mobile/src/app/ — 107 route; вход `/` доказывается через bootstrap.
ПЕРЕСЕЧЕНИЕ implementer: mobile/src/bootstrap/pilot-app.tsx — 117 Г0; правка только ПОСЛЕ миграции 117 v+1, сохраняет Г0 и пробы; admission подаётся из сессии, не литералом.
ПЕРЕСЕЧЕНИЕ implementer: mobile/src/bootstrap/__tests__/ — 117 пробы; добавляется проба композиции (null/stale/W0×current/W1A×current), старые не ослабляются.
ПЕРЕСЕЧЕНИЕ implementer: mobile/.maestro/ — 107 новый flow, старый остаётся.
ПЕРЕСЕЧЕНИЕ implementer: mobile/.maestro/ — 117 новый flow, старый остаётся.
ПЕРЕСЕЧЕНИЕ implementer: .github/workflows/mobile.yml — 107 шаги сохраняются, добавляется 118.
ПЕРЕСЕЧЕНИЕ implementer: .github/workflows/mobile.yml — 117 шаги сохраняются, добавляется 118.
ПРЕДПОСЫЛКИ:
- setting frozen/contracts/117/<v+1> с новым вердиктом ДО правки pilot-app.tsx; без него продуктовая приёмка блокирована.
- setting CI Android emulator, Maestro, H-checkout, пробы 107/117, включая Г0 dark/light; новых secrets/variables/environments нет.

## ПРОВОДКА
ПРОВОДКА:
- guard=fixtures/workshop_project/erstinformation_118/red_erstinformation_118.sh
ПРОВОДКА-ЭНФОРСМЕНТ: CI --stabs до ленда 132, затем W; mob CI: production flow + отдельная интеграционная проба gate/admission + 123 + H-check + Г0 117.

## Модель угроз
ЗАЩИЩАЕТ:
- От deep-link пути при мёртвом demo/Start: адресные красные входы маршрута + живой Maestro от `/` и bootstrap-интеграция с null/stale/current.
- От поддельного СОДЕРЖИМОГО достигнутого Start (пустой start_tabs): assertVisible каждой вкладки своим testID + вход `proiskhozdenie-start-pustoj`.
- От потери оси admission на production-шве (pilot-app всегда W1A): проба композиции с внешним источником admission + вход `kompozicija-admission-w0-propusk`.
- От удаления малого CTA: худшая самостоятельная область bbox_pt, вход `kadr-cta-skryt`, стаб глобального score.
- От stale/чужого/низкого кадра, literal, неполной замены: батареи 132/123 и собственный оракул 118.
НЕ ЗАЩИЩАЕТ:
- Перекодированный replay кадра без эмулятора: byte-проверка не доказывает процесс, ловец — реальный Maestro и ревью кадров CI (остаточный риск шаблона 132).
- Само выполнение будущей миграции 117 v+1: до frozen-тега 118 не может получить product green; ловец — prerequisite/freeze и reviewer, не самодекларация.
- Кадр Start по PNG-макету: макета Start в docs/ux/03_Mobility_Slice1/screens нет; ловец — отдельный предмет «Start с вкладками» после появления макета; в 118 состав вкладок наблюдаем testID, раскладка/цвет вкладок вне сверки (остаточный риск).
- Семантическую подпись/доставку backend сверх правил 107: ловец — 107 и контракты backend.

## Демаркация
Конформны входы формы 132 и манифеста 123, flow Maestro с именами кадров манифеста и testID-селекторами вкладок Start, source UI с testID и gate-сценариями 107, проба композиции с admission из внешнего источника. Валидный контрпример = инвариантность к частным значениям ∧ расхождение на конформном входе: отсутствие demo/Start/вкладок или допуска null/stale/W0×current, отдельный bbox CTA которого нет на скриншоте. Неконформный флоу/другая грамматика раннера не доказывают обход.

## Незаполненные требования:
- кадр Start по PNG-макету: макета Start в docs/ux/03_Mobility_Slice1/screens нет (инвентарь тёмных кадров — B01–B13, F02.03/F02.08, F03.01/02, MOB-*, без Start); отдельный предмет «Start с вкладками», в 118 наблюдается состав вкладок по testID.
