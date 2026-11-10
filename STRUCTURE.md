# Complior-mob: структура и границы мобильного клиента

**Статус: действует (решение владельца 2026-10-17).** Путь здесь и ниже отсчитывается от корня Complior-mob. Документ не меняет приоритет замороженного контракта, UX 1.17.8.2, API 5.8.2 и D2.2.5.1. Новый домен или слой — только задачей, явно меняющей этот файл и `mobile/structure-policy.json`.

## 1. Как выбрать место

1. Маршрут/навигатор Expo Router → `mobile/src/app/`.
2. Экран, состояние, бизнес-сценарий конкретного домена → `mobile/src/features/<domain>/`.
3. Повторно используемый **чисто визуальный** компонент → `mobile/src/ui/`; состояние, запросы и бизнес-решения остаются у вызывающего домена.
4. Транспорт/DTO/контракт данных → `mobile/src/api/`; сессия и настоящая IdP-интеграция → `mobile/src/auth/`.
5. Соединение провайдеров и выбор реализаций → `mobile/src/bootstrap/`, не экран и не общий `utils/`.
6. Синтетический runtime → `mobile/src/mocks/`. Тестовая синтетика, нужная после удаления demo, → `mobile/tests/fixtures/`.
7. Новый домен/слой не создаётся по усмотрению исполнителя. Изменение `STRUCTURE.md` и `mobile/structure-policy.json` должно быть явно включено в задачу; затем обновляются зависимые пути/проверки. Разрешённый каталог не расширяет ЗОНУ контракта.

Не создавать второй `app/` в корне `mobile/`, каталоги `screens/`, `services/`, `shared/` или `utils/` как запасной склад. Не создавать заранее пустое дерево: ниже перечислены **разрешённые места**, а не обязательные пустые каталоги.

## 2. Дерево

```text
Complior-mob/
├── AGENTS.md                   # краткие правила, ссылка на STRUCTURE.md
├── STRUCTURE.md                # одна карта для всего репозитория
├── README.md
├── harness.project.json        # профиль, если заведён владельцем
├── package.json                # точка входа приёмки для харнеса; логика в mobile/
├── .node-version
├── .github/workflows/          # mobile.yml: quality и android-e2e
├── .harness/                   # служебная зона харнеса проекта; внешняя
├── api/                        # READ ONLY, импортированный OpenAPI/схемы/примеры
├── docs/                       # READ ONLY, импортированный UX/DS/copy
├── design/reference/           # существующий визуальный эталон; не runtime
├── contracts/                  # служебная зона харнеса
├── registry/                   # служебная зона харнеса
├── verdicts/                   # служебная зона харнеса
├── fixtures/                   # служебная зона харнеса, НЕ mobile fixtures
└── mobile/
    ├── AGENTS.md               # правила Expo SDK 57 и ссылка на корневую карту
    ├── README.md               # запуск, окружение, ссылки на доказательства
    ├── package.json / package-lock.json
    ├── app.json                # Expo app config; native manifests не правим
    ├── tsconfig.json           # @/* → src/*, @/assets/* → assets/*
    ├── eslint.config.js
    ├── structure-policy.json   # закрытый список доменов/слоёв/служебных файлов
    ├── ci-screens.json         # карта владения CI-наборами: экран → pack/флоу/job
    ├── metro.config.js         # только если принят build-time выбор runtime
    ├── assets/                 # изображения, иконки, шрифты и лицензии
    ├── scripts/                # CI, генерация, проверка структуры; не runtime
    │   ├── ci-e2e.sh
    │   ├── check-structure.cjs
    │   ├── select-ci-screens.cjs  # выбор затронутых экранов; --mode inventar — инвентаризация пачек
    │   ├── ci-aggregate.cjs       # агрегат результатов работников в android-e2e
    │   ├── run-ci-screen.cjs      # один child универсального работника e2e-screen: свой AVD/порт, один APK, своё доказательство
    │   └── rehearsal-evidence.sh  # гейт evidence прогона
    ├── e2e-<screen>/           # пачка экрана: пробы/данные/контракт; выносится до lint
    ├── .maestro/               # Android/iOS E2E yaml, вспомогательные данные
    ├── tests/
    │   ├── acceptance/         # междоменные RNTL/интеграционные сценарии
    │   ├── helpers/            # renderWithProviders, test-only утилиты
    │   └── fixtures/           # синтетика, переживающая удаление runtime mock
    ├── evidence/               # компактные отчёты/ссылки/подписи, не код
    │   └── copy-review/        # немецкая редакторская/legal подпись CMP-MOB-089
    └── src/
        ├── app/               # route wrappers, layouts, Router special routes
        │   ├── _layout.tsx    # подключение провайдеров и корневого навигатора
        │   ├── index.tsx      # вход/redirect; текущий стартовый wrapper сохраняется
        │   ├── (entry)/       # auth/onboarding/invitation route wrappers
        │   └── (tabs)/        # Start · Vorgänge · Schutz · Post, именно этот порядок
        ├── bootstrap/         # AppProviders, composition, runtime binding
        ├── navigation/        # route params, pending-intent, чистые link helpers
        ├── api/
        │   ├── generated/     # типы вручную по api/mock-5_8.json; генерация — цель
        │   ├── http/          # единственное место непосредственного HTTP/stream I/O
        │   ├── api-client.ts  # интерфейс ApiClient, не конкретный mock
        │   └── api-provider.tsx # инъекция клиента и доступ к нему
        ├── auth/              # AuthProvider, session port, IdP/secure storage adapter
        ├── analytics/         # consent-aware адаптер; transport через api/http
        ├── theme/             # RN-представление D2.2.5.1, light/dark, typography
        ├── ui/                # props-only компоненты и общие виджеты
        ├── i18n/              # производный UI Copy DE, typed keys, форматирование
        ├── lib/               # малые чистые функции без знаний о приложении
        ├── mocks/             # mock ApiClient + Demo AuthProvider + runtime fixtures
        └── features/
            ├── start/
            ├── auth/account-sessions/
            ├── onboarding/
            ├── invitations/referral/
            ├── missions/{activity,workspace}/
            ├── conversation/{voice,summary}/
            ├── approval/
            ├── profile/insured-assets/
            ├── family/delegation/
            ├── policies/{import,health-admission,service,switch,renewal,withdrawal}/
            ├── protection/{assessment,embedded,life-events}/
            ├── quotes/{requirements,comparison}/
            ├── application/{documents,tracking,signature}/
            ├── vehicle/{capture,evb,plates,service-payment}/
            ├── claims/{intake,case,legal-cover,reconsideration}/
            ├── post/{documents,share}/
            ├── permissions/{service-mandate,partner-review}/
            ├── contexts/
            ├── recovery/
            ├── notifications/
            ├── memory/
            ├── help/handoff/
            └── search/
```

Фигурные скобки — сокращённое изображение нескольких каталогов, не буквальное имя. Например `features/auth/` содержит собственный экран входа и вложенный `account-sessions/`; запись не означает, что всё auth лежит только в подкаталоге.

В каждом домене и именованном поддомене допускаются файлы непосредственно рядом, а при росте — `components/`, `hooks/`, `model/`, `adapters/`, `__tests__/`. Произвольные новые поддомены требуют изменения карты. Глубже технических папок допустима группировка по компоненту; не делать пять пустых слоёв ради одного экрана. Пример существующего паттерна: `features/start/start-screen.tsx` и `features/start/__tests__/start-screen.test.tsx` остаются на месте.

## 3. Владельцы функций F01–F48

Выбраны **домены**, а не F-коды/вкладки. Один F-код иногда имеет несколько локальных веток; общая бизнес-сущность не должна дублироваться ради отдельной папки Fxx. F/action/frame IDs сохраняются в трассировке задач, описаниях тестов и evidence, не превращаются в новый routing API.

| Функции | Владелец в `src/features/` | Смысл |
|---|---|---|
| F01 | `invitations/`, `invitations/referral/` | preview/claim, приглашения, программа и reward progress |
| F02 | `onboarding/` | disclosure, приветствие, выбор услуги |
| F03 | `auth/`, `auth/account-sessions/` | вход и экран устройств; инфраструктура сессии отдельно в `src/auth/` |
| F04 | `start/` | Start и композиция представлений общего агента |
| F05–F07 | `conversation/`, `voice/`, `summary/` внутри него | одна Mission, текст/голос/итог, не три независимых чата |
| F08–F10 | `missions/`, `workspace/`, `activity/` внутри него | Vorgänge, ограничения/цели, квитанции и статусы |
| F11 | `approval/` | точная версия пакета согласования; approval не равно исполнение |
| F12 | `profile/`, `profile/insured-assets/` | собственные данные и объекты |
| F13 | `family/`, `family/delegation/` | семья и отдельный допуск делегирования |
| F14–F15 | `policies/import/`, `policies/health-admission/`, `policies/` | импорт, health consent, кошелёк полисов |
| F16 | `post/documents/`, `post/share/` | оригиналы/версии/разрешённые копии, не второй документооборот |
| F17 | `memory/` | HIDE/RESTORE/REQUEST_CORRECTION, не локальная подмена факта |
| F18 | `permissions/service-mandate/`, `permissions/partner-review/` | обслуживание, ограниченные поручения и видимость |
| F19–F22 | `protection/`, `assessment/`, `embedded/`, `life-events/` внутри него | карта защиты и источники оценок |
| F23–F25 | `quotes/requirements/`, `quotes/`, `quotes/comparison/` | анкета, предложения, выбор/KEEP_CURRENT |
| F26–F28 | `application/`, `documents/`, `signature/`, `tracking/` внутри него | заявление, документы, подпись, наблюдаемый исход |
| F29–F31 | `policies/switch/`, `renewal/`, `service/`, `withdrawal/` внутри него | смена, продление, сервис и отдельный Widerruf |
| F32–F33 | `vehicle/`, `vehicle/capture/`, `vehicle/evb/` | автомобиль и только реально выданная eVB |
| F34 | **не заводить** | текущий пакет UX имеет 47 активных функций; этот номер не восстанавливаем догадкой |
| F35–F36 | `vehicle/plates/`, `vehicle/service-payment/` | самостоятельные допуски услуги/оплаты, не обещание доступности W5 |
| F37–F39 | `claims/intake/`, `claims/case/`, `claims/legal-cover/` | помощь, страховой случай, покрытие адвоката |
| F40 | `post/` | письма, insurance inbox и исход отправки; документы принадлежат тому же домену |
| F41 | `claims/reconsideration/` | разбор отказа и отдельный пересмотр |
| F42 | `help/`, `help/handoff/` | специалист и граница передачи, НЕ invitation handoff |
| F43 | `notifications/` | push registration, тишина, возврат в актуальное дело |
| F44 | `profile/` + инфраструктура `src/analytics/` | privacy entry и согласия; analytics не владеет экраном |
| F45 | `permissions/` | самостоятельность агента, точные разрешения и отзыв |
| F46 | `search/` | разрешённые метаданные разных доменов; не привязка только к Post |
| F47 | `contexts/` | личный/корпоративный контекст и сброс scoped состояния |
| F48 | `recovery/` | resume/offline/неизвестный исход без повторного commit |

## 4. Маршруты и зависимости

`src/app/` содержит только маршруты, layouts, redirect/параметры навигации и связывание уже готовых экранов. Не хранить там fixtures, тесты, UI-примитивы, hooks и DTO. Route-wrapper может реэкспортировать экран, как текущий `app/index.tsx`; он не делает запросы и не реализует бизнес-переходы. Группы `(entry)`/`(tabs)` — предложение организации, не разрешение придумать новые URL/action ID. Профиль, поиск, помощь, настройки — вторичные маршруты, не дополнительные основные вкладки.

Разрешённое направление:

```text
app → bootstrap / features / navigation / ui
bootstrap → auth / api / выбранная runtime-реализация
features/<domain> → свой домен / api interface / auth interface / ui / theme / i18n / lib / navigation / analytics
ui → theme / i18n / lib
api/http → api/generated / api interface / lib
```

**Запрещено:** один feature импортирует другой напрямую, включая `import type`, реэкспорт, относительный путь и `@/features/...`. `src/ui/`, `src/auth/`, `src/api/`, foundations не импортируют features/app/bootstrap. `ui` не получает ApiClient/AuthProvider/analytics через импорт; ему передают данные и callback. `api` не зависит от AuthProvider: токен/credentials передаются через узкий интерфейс. Файл в `lib/` не может стать обратным входом в feature.

Междоменный переход — навигационный intent с типизированными параметрами/ID, общий порт данных или composition в route/bootstrap. Например application передаёт ID точного пакета на F11 через маршрут; он не импортирует внутренний hook approval. Если Start должен показать MissionRoadmap, визуальная часть живёт в `ui/mission-roadmap/` и получает view model; Start не импортирует `features/missions/`. Не переносить бизнес-сценарий в `ui/` только ради обхода границы.

## 5. API, авторизация и удаление mock

- `src/api/api-client.ts` — публичный интерфейс операций на основе OpenAPI 5.8.2. `generated/` хранит типы, написанные вручную по read-only `api/mock-5_8.json`; генератора в репозитории нет. Воспроизводимая генерация из OpenAPI 5.8.2 — цель после приёмки снимка интерфейса бэкенда. Это **версия контракта**, не название/версия npm-пакета генерации.
- `api/http/` владеет fetch, streaming/WebSocket при наличии контракта, сериализацией, credentials injection, нормализацией ошибок. Прямой fetch запрещён не только в маршруте, но и во всех production-слоях вне транспорта. Экран использует ApiClient через provider/доменный hook. Не выдумывать endpoint для IdP_FLOW.
- `src/auth/` — AuthProvider/контракт сессии, интеграция IdP и безопасное хранение. `features/auth/` — только пользовательские сценарии. Demo-реализация AuthProvider не попадает в `src/auth/`.
- В dev/тестах/демо-CI `EXPO_PUBLIC_API_MODE=mock`; HTTP job указывает `http` явно. Неподдерживаемое значение должно быть ошибкой configuration bootstrap; production/release не должен молча принимать dev-default. Это публичная переменная: в ней и соседних `EXPO_PUBLIC_*` нет секретов.
- Runtime mock ApiClient, Demo AuthProvider и runtime synthetic datasets находятся **целиком в `src/mocks/`**. Видимая метка Demo — часть mock composition, состояние demo можно передать UI через props/context. Строки SYNTHETIC и PRODUCT_COPY_REVIEW_REQUIRED не превращаются в backend evidence.
- **Предлагаемый build seam:** один runtime alias, разрешаемый Metro в `src/mocks/runtime.ts` для mock и в `src/bootstrap/http-runtime.ts` для http. Общий тип runtime располагается вне mock; TypeScript видит контракт, а не условный импорт двух реализаций. Никакого `if (mode) require('../mocks')` в production исходниках: Metro может включить обе статические зависимости. Поддерживаемый Expo механизм — `resolver.resolveRequest` с делегированием `context.resolveRequest`; конкретное внедрение относится к ApiClient-задаче, не выполнено этим документом.
- Статическая проверка поставлена строже: **никакой production source не импортирует `src/mocks/` в обоих режимах**; вход в demo — только resolver composition. Mock может импортировать общие API/auth-типы, но не экраны. Тесты могут пользоваться mock, не создавая runtime-ребро.
- CMP-MOB-075 — один согласованный cutover: удалить `src/mocks/`, переключатель/alias mock-ветки, Demo binding/метку/переменную; оставить единственную HTTP composition. Это не обещание буквально одного `rm`: вместе удаляются все интеграционные ссылки. Боевые экраны и домены менять ради удаления mock не требуется. Постоянную тестовую синтетику до cutover разместить в `tests/fixtures/`.
- `api/mock-5_8.json` — read-only входной пример контракта, не runtime-код приложения. Его не удаляют в CMP-MOB-075. В mock-сборку берутся только необходимые синтетические срезы; production не импортирует весь read-only пакет.

**Граница доказательства:** имеющаяся проверка доказывает статические зависимости и расположение файлов, не отсутствие байтов mock в release APK. На внедрении runtime seam обязателен отдельный HTTP export/bundle graph check и сценарий HTTP без доступного mock. В текущем коде вообще ещё нет ApiClient/AuthProvider: консультация не выдаёт их за реализованные.

## 6. Дизайн-система, copy и имена

- D2.2.5.1 в `docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/design-system/project/` — единственный источник цветов, spacing, радиусов, typography. `theme/` — нативная проекция этих токенов, не второй вручную изобретённый набор. `ground`, `ink`, `panel`, `card`, `on-card`, `primary`, `on-primary`, `accent` сохраняют семантику light/dark. Раскладочные значения вроде `flex: 1` не становятся визуальными токенами.
- `ui/` использует theme; экран не определяет собственную палитру и размерный ряд. Шрифты DM Sans и OFL — в `assets/fonts/`, не импорт web React bundle из design snapshot.
- Директории и файлы нового кода — `kebab-case`: `approval-card/approval-card.tsx`, `use-session.ts`, `api-client.ts`. React exports — `ApprovalCard`, hook — `useSession`, обычные функции — `camelCase`, константы по существующей TS-конвенции. Expo Router `_layout`, `+not-found`, `[id]`, `(group)` — документированные исключения. Существующие имена assets не переименовываем ради косметики.
- Общие AdaptiveAgentStage/MissionRoadmap/ApprovalCard и другие компоненты из задач сохраняют имена React exports, но пути нормализуются в `ui/adaptive-agent-stage/`, `ui/mission-roadmap/`, `ui/approval-card/` и т.д. Их вид/контракт props общие; мутации и загрузка данных остаются в features.
- UI Copy DE берётся из snapshot в `docs/ux/01_UX_Source_of_Truth/BrokerOS_UI_Copy_DE.json`; `i18n/` может хранить производные runtime keys. Не исправлять скопированный источник локально и не дублировать немецкие строки по экранам. Любая новая формулировка требует product/legal review; наличие ключа не является signoff.

Нынешний `start-screen.tsx` — каркас с literal styles. Миграция на токены входит в CMP-MOB-002/соответствующий UI-срез; структурный зелёный baseline не доказывает уже выполненный D2.2.5.1. Визуальное соответствие проверяется скриншотами и review, не regex по произвольным числам.

## 7. Тесты, артефакты, generated и служебные зоны

- Jest/RNTL colocated: `__tests__/<subject>.test.ts[x]` у домена/компонента/слоя. Для нескольких доменов — `mobile/tests/acceptance/`; это не новый runtime слой и не место production-helpers. Tests исключаются из Router. Текущий colocated паттерн сохраняется.
- Maestro — `mobile/.maestro/`, имена сценариев `cmp-mob-NNN-<scenario>.yaml` для новых задач; `start.yaml` сохраняется. Связка AC → сценарий → screenshot/artifact → commit обязательна. Проверка каталога не означает, что сценарий запущен на Android/iOS.
- `mobile/evidence/` — небольшие протоколы, source refs, hashes и ссылки на CI artifacts. Видео/APK/большие скриншоты — в CI artifact storage, не git. Персональные данные/секреты не допустимы ни там, ни в test fixtures.
- `.expo/`, `node_modules/`, `dist/`, `coverage/`, `maestro-out/`, `screen-evidence/`, `android/`, `ios/` в mobile — generated/runtime output, не целевые зоны ручной разработки. Существующий Expo CNG подход сохраняется. Инвентаризатор пропускает их на диске, но запрещает tracked files в этих деревьях при наличии `.git`.
- `api/`, `docs/`, `design/` и `contracts/ registry/ verdicts/ fixtures/` не валидируются как мобильный исходный код и не перемещаются этим решением. Для read-only копий и зон харнеса действуют отдельные правила provenance/зон. Сам структурный инвентаризатор **не** защищает эти деревья от изменения; это ответственность прав доступа, review и зонного контроля.

### 7.1. CI-наборы экранов: карта, пачки и вынос до lint

Экранный CI-набор живёт в перечисленных ниже файлах; карта, CI-скрипты, назначение pack и механизм выноса — адресная зона implementer (контракт 143).

| Файл | Назначение |
|---|---|
| `mobile/ci-screens.json` | карта владения (схема 1): экран → `job`, `pack`, `flows`/`child_flows`/`legacy_entrypoint`, `puti`, `h_checkout`, `output_namespace`; отдельно `integracija` (фиксированный набор P), `shared.puti` (общий слой) и `sluzhebnye_potoki` (флоу без экранного владельца) |
| `mobile/e2e-<screen>/` | пачка экрана: пробы, данные и контракт экрана; исполняемый вход, а не layout-зона |
| `mobile/scripts/select-ci-screens.cjs` | выбор затронутых экранов по карте и diff; `--mode inventar` — инвентаризация пачек и флоу по дереву; выход `matrix` — строки универсального работника из той же фактической выборки |
| `mobile/scripts/ci-aggregate.cjs` | агрегат результатов работников в `android-e2e` (при наличии матричных детей — сверка каждого `screen-evidence-<id>-<run_id>-<run_attempt>`) |
| `mobile/scripts/run-ci-screen.cjs` | один child универсального работника: свой эмулятор на консольном порту `AVD_PORT` (порт эмулятора), один APK той же сборки (digest до установки), один повтор по сигнатуре adb-транспорта, запись `mobile/screen-evidence/<id>/result.json`; отдельный adb-сервер скриптом не настраивается — его порт задаёт job `e2e-screen` экспортом `ANDROID_ADB_SERVER_PORT` |
| `.github/workflows/mobile.yml` | пять legacy jobs (явные, без изменений) + служебные + универсальный работник `e2e-screen` (`strategy.matrix` из карты); `needs` обоих агрегатов |

Правила владения:

- карту правит автор экранной задачи в том же PR, что и его файлы; `approved` — только по принятой поставке, `in-development` — исполняемая разработка;
- пачка или флоу без записи карты — ошибка инвентаря (`PACHKA_BEZ_REGISTRACII`, `POTOK_BEZ_REGISTRACII`), а не «пропущено и не выбрано»;
- запись карты без исполняемого входа на дереве — ошибка (`ZAPIS_BEZ_VHODA`);
- служебные флоу без экранного владельца перечисляются явно, а не молча игнорируются.

Механизм выноса общий, без персональной строки на каждый экран: задача `quality` **до любого перемещения** запускает `node mobile/scripts/select-ci-screens.cjs --mode inventar --repo .` и выносит из дерева ровно перечисленные инвентаризацией pack-каталоги (в namespace прогона), затем — H-checkoutы и пробу композиции 118. `npm test`, `npm run lint`, `npm run typecheck`, `npm run doctor` стоят **после** выноса. Незарегистрированная пачка/флоу останавливает прогон честным отказом; wildcard-вынос (`mobile/e2e-*`) запрещён — он маскировал бы незарегистрированную пачку, поэтому blanket-исключение всех `e2e` в `mobile/structure-policy.json` не вводится.

Новый экран подключается как «пачка + запись карты»: запись карты (с `job: e2e-screen`, уникальными `id`/`pack`/владельцем флоу и собственным `avd_port`) приходит тем же PR, что и пачка/флоу, — отдельный job, отдельный output выбора и отдельная правка `needs` больше не нужны: строки новых экранов собирает универсальный работник `e2e-screen` (`strategy.matrix` из выхода `select-screens`), а оба агрегата сверяют каждого child по его отдельному `screen-evidence-<id>-<run_id>-<run_attempt>`. Пять прежних работников остаются явными jobs без изменений.

## 8. Карта задач и способ применения

`pathmap.json` в пакете консультации содержит 86 точных ключей: все 247 вхождений `target_paths` у 96 задач. Правило преобразования: точное совпадение прежде префикса, затем **самый длинный ключ, оканчивающийся `/`**, с сохранением остатка. Не применять каскадно результат как новый вход, не использовать строковую замену внутри произвольного пути. Identity mappings намеренные.

Есть many-to-one: `invitation/` и `invitations/` становятся одним доменом. Это требует объединить ответственность/конфликты файлов, а не перезаписывать их автоматическим `mv`. В текущем исходнике реально существует лишь `features/start/`; основная перекладка — адреса будущих задач, не массовый перенос готового кода.

**Особый ключ CMP-MOB-089:** исторический target `docs/ux/Complior-back:sources/frontend-ux1_17_8_2/BrokerOS_UI_Copy_DE.json` переводится в `mobile/evidence/copy-review/` как **место результата подписи**, не как перенос/новая writable копия словаря. Source остаётся read-only по реальному пути `docs/ux/01_UX_Source_of_Truth/BrokerOS_UI_Copy_DE.json`. Исправления copy выполняются upstream и приходят обновлением snapshot. Уточнение wording этой задачи обязательно при принятии карты.

Coverage и допустимость каждого целевого места проверены `verify-pathmap.cjs`; отчёт по каждой задаче — `evidence/pathmap-coverage.json`. Он не публикует изменения в GitHub. Старые target_paths в опубликованных задачах обновляются отдельно после решения владельца.

## 9. Доставка агентам и CI

В существующий полный `contextPack.rows` добавляется объект (не заменять остальные строки):

```json
{
  "kind": "map",
  "path": "STRUCTURE.md",
  "roles": "architect,critic,implementer,reviewer,adversary,orchestrator",
  "mandatory": true,
  "why": "Карта мобильных слоёв, разрешённых путей и направлений импортов"
}
```

Форма проверена по доступному снимку стандарта 2026-10-14, §«Точный профиль»: `roles` — CSV; `path` — существующий файл; rows при override заменяются целиком. Список ролей нужно сопоставить реально используемым ролям проекта. Это **фрагмент rows**, не полный профиль/новый ключ схемы. После принятия надо проверить фактический ContextPack вызванного агента: строка в профиле сама по себе не доказательство автодоставки.

ЗОНА каждого контракта содержит реальные ограниченные пути из карты и отдельно необходимые shared-файлы. Не писать «весь mobile по STRUCTURE» вместо конкретной зоны. Новая библиотека/публичная граница требует согласованного изменения карты.

Проверка `quality` уже запускает `npm run lint` из `mobile/`. Предложение: заменить только значение script на `node scripts/check-structure.cjs && eslint . --max-warnings=0`; остальной существующий test/typecheck/doctor pipeline оставить. Конкретные файлы установки, ограничения инструментов и сырые rc — `CHECKS.md` из пакета консультации. Эта структура не является отдельным разрешением внедрять runtime или менять CI без задачи владельца.
