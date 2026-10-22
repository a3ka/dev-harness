# 118 — Erstinformation (экран по шаблону 132)
КЛАСС ЗАДАЧИ: КОДОВЫЙ. id/CONTRACT/118; до V-2.
КОНТЕКСТ: docs/owner/2026-10-20-mob-po-maketu.md §Решение Б,В: путь от First-Run до Start, каждый кадр по PNG.

## Существующее
Слово владельца: First-Run → вход/демо (135) → Erstinformation (118) → Start с вкладками; dark/light.
107/erstinfo_107: gate, ack/version, F02.03/05/08; портовое испытание 107 НЕ доказывает production-композицию.
135-first-run-ekran: First-Run/F03, селектор demo; 123: scripts/sverka_maketa.py и check_pokrytie; 132/1: форма, кадры, зоны.
117/2 frozen: `mobile/src/bootstrap/pilot-app.tsx` — действительный вход `/`, frame/handleDemoEntry/handleVerify, Г0 белого корня F03; экран 135 оставляет этот файл вне своей зоны. 995/111 и пробы 117/2 сохраняются. Макеты: docs/ux/03_Mobility_Slice1/screens/F02.03*,F02.08*.

## Предмет и граница
Одна пачка mobile/e2e-erstinformation/ + UI F02.03/F02.08; F02.05, ack и gate-предикат остаются 107. 16 кадров: F02.03 V01/V02 MISSING/OUTDATED (full+V0) и F02.08 V01–V04 CHECKING/PENDING/CURRENT_CONFIRMED/FAILED × dark/light. Copy/review_status: BrokerOS_UI_Copy_DE.json; API: getDisclosureGate.
Принимается СВЯЗНЫЙ пользовательский путь: запуск production `/` → First-Run → нажатие demo → F02.03 → F02.08 → нажатие continue при current gate → Start; при null и stale gate Start недоступен. Отдельный deep link на Erstinformation НЕ заменяет путь.

## Зависимость замороженного корня (выбор границы)
Выбрана миграция 117 v+1 как ПРЕДПОСЫЛКА, а не фиктивный обход bootstrap через `mobile/src/app/`. До раздачи правки production-маршрута: отдельный согласованный и замороженный v+1 текста/охран 117 объявляет узкую смену `pilot-app.tsx` для demo → Erstinformation и допуска current → Start, сохраняя Г0 F03 и остальные 117-пробы; новый вердикт миграции обязателен. Без такого frozen-тега 118 НЕ РАЗРЕШАЕТ править bootstrap и НЕ МОЖЕТ быть объявлен продуктово done. После миграции исполнитель 118 получает этот путь явно и меняет только композицию переходов; белый корень F03 остаётся под Г0 (прогон обеих тем). Риск до миграции: экранная пачка может быть зелёной, пользовательский путь всё ещё оборван; это НЕ принятая поставка 118.

## Инварианты
1. ekran.json: 17 полей 132, ekran=erstinformation; 16 кадров, PNG/sha256 из source.json; zamenjaet=null (живого манифеста этого экрана нет), ne_trogaet — обе чужие пачки 132.
2. Цвет/размер только в docs/ux/03_Mobility_Slice1/ds/tokens.css, не пачке.
3. Манифест каждого кадра выделяет самостоятельные bbox_pt значимых элементов по сетке 123: бренд, состояние, заголовок, описание, карточка, статус, действия; у «Dokument öffnen» нижняя область НЕ сливается с экраном/верхней кнопкой. check_pokrytie покрывает чернила; `score_frame` берёт худшую область, каждый KADR ≥ 0.600. Для длинных F02.03 bbox в координатах 390×844 раннера 123, не нативной высоты PNG.
4. Маэстро запускает production `/` (никакого openLink/startApp), наблюдает First-Run, нажимает demo, assertVisible СВОЕГО кадра перед каждым takeScreenshot, заканчивает нажатием continue после confirmed gate и assertVisible вкладок Start. Отдельно на null и stale видит маркер gate и assertNotVisible Start до current; при null/stale нажатие continue НЕ даёт перехода. Контракт 107 остаётся источником допуска: W1A ∧ CURRENT_CONFIRMED ∧ точная версия/evidence; 118 не вводит второй gate.
5. Android e2e оставляет свежие кадры обеих тем, не byte-copy PNG. Product CI запускает реальный Maestro, сверку 123, pinned H файл проверки происхождения БЕЗ промежуточной замены кадров; интеграционная проба production-композиции `pilot-app` инъецирует gate=null и stale и отвергает переход к Start после действия continue; на current допускает переход. Это другой шов, нежели портовые пробы 107.

## Приёмочный критерий
W = `bash fixtures/workshop_project/erstinformation_118/red_erstinformation_118.sh`.
Дано: нет scripts/ekran_shablon.py; когда: W; тогда: rc 1, SHABLON_ABSENT и CASE KRASNO по каждому входу.
Дано: эталон 132 и пинованные макеты; когда: W --model; тогда: rc 0, все CASE ok, 16 KADR 1.000 0.600 (худшая самостоятельная область или G).
Дано: эталон и адресные стабы; когда: W --stabs; тогда: rc 0, все CASE ok, по каждой связи `STAB ... KRASEN`, непойманных 0; подмена oracle/носителя → rc 2 ORACLE_TAMPERED.
Красные входы маршрута: `proiskhozdenie-bez-demo` → FLOW_BEZ_DEMO_VHODA; `proiskhozdenie-deeplink` (экран через openLink вместо demo) → FLOW_BEZ_ZAPUSKA и FLOW_BEZ_DEMO_VHODA; `proiskhozdenie-gate-null-propusk` и `proiskhozdenie-gate-stale-propusk` каждый → свой FLOW_GATE_NE_PROVEREN; `proiskhozdenie-bez-start` → FLOW_BEZ_START. Адресные стабы s23/s24/s25/s27 и связи — в коде probe.py/source.json (Н-39). `proiskhozdenie-flow-bez-perehoda` продолжает требовать движение между кадрами.
Красный вход кнопки: `kadr-cta-skryt` закрашивает нижнюю кнопку на F02.08-V01 dark, ожидает rc 1 KADR_NIZHE_POROGA `hudshij=dokument-oeffnen`; глобальный скор 0.600 пропустил бы эту порчу. Адресный стаб s26_global_cta.py судится кодом батареи. Большой удалённый участок `kadr-nizhe-poroga` остаётся самостоятельным входом.
Дано: продукт с замороженной миграцией 117 v+1 и реализацией 118; когда: W, затем android-e2e и проверка pinned H на ТЕХ ЖЕ кадрах + проба bootstrap-композиции null/stale/current + Г0 dark/light; тогда: каждый rc 0, снимки совпадают с макетом по составу, раскладке, отступам, шрифтам, цветам; отрицательный gate без перехода и положительный Start доступны на production `/`. Гейт, запущенный без входа `/` либо без пробы null/stale, НЕ является приёмкой.

## Зоны и исполнители
ЗОНА architect: contracts/118-erstinformation.md fixtures/workshop_project/erstinformation_118/
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА implementer: mobile/src/features/onboarding/ mobile/src/app/ mobile/.maestro/ mobile/src/bootstrap/pilot-app.tsx mobile/src/bootstrap/__tests__/ mobile/e2e-erstinformation/ .github/workflows/mobile.yml
ПЕРЕСЕЧЕНИЕ implementer: mobile/src/features/onboarding/ — 107 UI; gate/ack не меняются.
ПЕРЕСЕЧЕНИЕ implementer: mobile/src/app/ — 107 route; вход `/` доказывается через bootstrap.
ПЕРЕСЕЧЕНИЕ implementer: mobile/src/bootstrap/pilot-app.tsx — 117 Г0; правка только ПОСЛЕ миграции 117 v+1, сохраняет Г0 и пробы.
ПЕРЕСЕЧЕНИЕ implementer: mobile/src/bootstrap/__tests__/ — 117 пробы; добавляется отдельная проба композиции, старые не ослабляются.
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
ПРОВОДКА-ЭНФОРСМЕНТ: CI --stabs до ленда 132, затем W; mob CI: production flow + отдельная интеграционная проба gate + 123 + H-check + Г0 117.

## Модель угроз
ЗАЩИЩАЕТ:
- От deep-link пути при мёртвом demo/Start: адресные красные входы маршрута + живой Maestro от `/` и bootstrap-интеграция с null/stale/current.
- От удаления малого CTA: худшая самостоятельная область bbox_pt, вход `kadr-cta-skryt`, стаб глобального score.
- От stale/чужого/низкого кадра, literal, неполной замены: батареи 132/123 и собственный оракул 118.
НЕ ЗАЩИЩАЕТ:
- Перекодированный replay кадра без эмулятора: byte-проверка не доказывает процесс, ловец — реальный Maestro и ревью кадров CI (остаточный риск шаблона 132).
- Само выполнение будущей миграции 117 v+1: до frozen-тега 118 не может получить product green; ловец — prerequisite/freeze и reviewer, не самодекларация.
- Семантическую подпись/доставку backend сверх правил 107: ловец — 107 и контракты backend.

## Демаркация
Конформны входы формы 132 и манифеста 123, flow Maestro с именами кадров манифеста, source UI с testID и gate-сценариями 107. Валидный контрпример = инвариантность к частным значениям ∧ расхождение на конформном входе: отсутствие demo/Start или допуска null/stale, отдельный bbox CTA которого нет на скриншоте. Неконформный флоу/другая грамматика раннера не доказывают обход.

## Незаполненные требования:
нет
