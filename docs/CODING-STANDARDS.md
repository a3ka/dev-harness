# CODING-STANDARDS.md — как писать код мобильного клиента Complior

**Статус: действует (2026-11-04).** Правила для кода в `mobile/` (Expo SDK 57 · React Native 0.86 · TypeScript · Expo Router, Android-first). Стандарт **фиксирует** соглашения кода `mobile/src`; места, где код правилу ещё не следует, помечены `ЦЕЛЬ (код не соответствует: файлы)` — новый код пишется по правилу сразу.

## 1. Область и приоритет источников

При расхождении побеждает источник выше:

1. Замороженный контракт задачи (`contracts/NNN-*.md`).
2. `AGENTS.md` (корень) — источники истины, данные, окружение, как работаем.
3. `STRUCTURE.md` + `mobile/structure-policy.json` — куда класть код (таблицу доменов и дерево стандарт не повторяет).
4. `mobile/AGENTS.md` — правила Expo: пакеты только `npx expo install`, документация версии текущего SDK, CNG.
5. Этот стандарт — как писать.

Стандарт не дублирует карту доменов, контекст агентов (`docs/context/CONTEXT-POLICY.md`), UX/API-источники и CI-job'ы. Если правило здесь молчит — действует STRUCTURE.md.

## 2. Слои и домены

Место файла — только по `STRUCTURE.md`; машинный инвентарь — `mobile/structure-policy.json`, проверяет `node scripts/check-structure.cjs` (входит в `npm run lint`). Направления импортов проверяет ESLint `import/no-restricted-paths` (`mobile/eslint.config.js`):

- `features/<домен>` не импортирует другой домен (включая `import type`/реэкспорт) — «Cross-feature import: compose in app or pass a typed interface/props»;
- `features` не импортирует `app`/`bootstrap`; `app`/`features` не импортируют `api/http` — только инъектированный ApiClient;
- нижние слои (`api`, `auth`, `ui`, `theme`, `lib`, `i18n`, `analytics`, `navigation`, `mocks`) не зависят от экранов/composition;
- `ui` — props-only (без `api`/`auth`/`analytics`); `api` принимает credentials портом; `theme`/`lib`/`i18n` не зависят от верхних слоёв;
- production-код не импортирует `src/mocks` и тесты.

Междоменный обмен — типизированный intent/порт/props, не импорт: `start-section-host.tsx` получает `missions` через props, композиция — в `app/(tabs)/[section].tsx`. Внутри домена технические папки только из `featureFolders` (`components`, `hooks`, `model`, `adapters`, `__tests__`). Не создавать `screens/`, `services/`, `shared/`, `utils/`, второй `app/`. Малый чистый хелпер может дублироваться между доменами (`artboard.ts` есть и в `features/auth/`, и в `features/onboarding/`): граница важнее DRY; вынос в `lib/` — когда нужен третьему. В `src/app/` только маршруты: route-wrapper реэкспортирует готовый экран (`app/index.tsx`), сам не запрашивает данные.

## 3. Формат модулей и экспортов

- **`.tsx`** — всё с JSX; **`.ts`** — логика, типы, порты, данные; **`.json`** — данные (импортируется с расширением); **`.d.ts`** — швы-объявления (`bootstrap/runtime-contract.d.ts`).
- **Именованные экспорты везде; `export default` — только маршруты `src/app/`** (требование Expo Router). Модуль без маршрута default-экспорта не имеет (`app/onboarding-session.tsx`).
- Путь импорта — без расширения (кроме `.json` и двух канон-артефактов батареи 145: `src/lib/faden/__tests__/faden-{motion.test.ts,sign.test.tsx}`).
- Barrel `index.ts` — только для слайса из нескольких файлов с одним публичным лицом (`lib/faden/index.ts`, `lib/otdacha/index.ts`).
- Порты лежат у владельца слоя: `api/api-client.ts` (ApiClient), `auth/auth-provider.ts`, `bootstrap/runtime-contract.d.ts` (`@pilot/runtime`).
- Файлы домена по ролям: экран (`auth-screen.tsx`), части (`auth-parts.tsx`), токены (`auth-tokens.ts`), артборд (`artboard.ts`).

## 4. Именование

| Что | Как | Пример |
|---|---|---|
| Файлы/каталоги | `kebab-case` | `start-section-host.tsx`, `agent-presence/` |
| Компоненты | `PascalCase` | `Button`, `TabShell`, `StartScreen`, `FadenSign` |
| Хуки | `use*` | `useTheme`, `useArtboard`, `useOnboardingSession` |
| Типы/интерфейсы | `PascalCase` | `ThemeTokens`, `ApiClient`, `PilotAppPorts` |
| Константы-литералы | `UPPER_SNAKE_CASE` | `TAB_ORDER`, `PILOT_DEMO_CODE`, `HAPTIC_SCENES` |
| Экспортируемые проекции значений | `camelCase` (API-поверхность, не литерал) | `themeTokens`, `uiCopyDe` |
| Функции | `camelCase` | `allowsStart`, `playHaptic` |
| testID (новые) | `kebab-case` | `auth-email`, `start-composer-input` |
| Сценарии Maestro | `cmp-mob-NNN-<scenario>.yaml` | `cmp-mob-004-start.yaml` |

Исторические имена не переименовываются ради косметики: `FadenSign.tsx` (порт 145), `start.yaml` (семья 995), snake_case testID пачек (`erstinfo_*`, `f03_01_email`) и ID кадров (`F02.01`) привязаны к манифестам пачек; **новые** testID — kebab-case. Имя файла компонента повторяет каталог-слайс: `ui/agent-presence/agent-presence.tsx`.

## 5. Стиль

- TypeScript **strict** (`tsconfig.json` `compilerOptions.strict=true`, база `expo/tsconfig.base`). `any` не вводить: union-литералы (`type UiState = 'CALM' | 'INPUT' | 'LISTENING'`), `unknown` + предикат на границе (`isSessionPayload` в `app/onboarding-session.tsx`). Enum'ов нет — строковые union'ы.
- Алиасы: `@/* → src/*`, `@/assets/*`, `@pilot/runtime`. Правило импортов: **внутри каталога — `./`; через каталоги/слои — `@/…`**. Так: `auth-screen.tsx` → `./auth-parts` и `@/theme/context`. Не так: `from '../../theme/context'` сквозь слои.
  - ЦЕЛЬ (код не соответствует): сквозные относительные импорты в `bootstrap/tab-shell.tsx`, `app/index.tsx`, `app/(tabs)/[section].tsx`, `app/onboarding-session.tsx`, `app/start-destination.tsx`, `bootstrap/pilot-app.tsx`, `features/start/start-screen.tsx`, `src/ui/*`; меняются при правке файла.
- ESLint (`eslint-config-expo`, flat): `import/no-unresolved`; запрет динамического импорта; запрет сети вне `api/http` (`fetch`/`XMLHttpRequest`/`WebSocket`, `axios`, `ky`, `undici`, `expo/fetch`). `noInlineConfig: true` — **inline `eslint-disable` запрещены**. Порог: `eslint . --max-warnings=0`. Форматирование — как в дереве (2 пробела, одинарные кавычки, точка с запятой).
- Комментарии — по-русски, объясняют **почему** (решение, замер, предмет); первый комментарий файла называет предмет (`// 118 (Erstinformation): …`). Английский остался в исторических портах 995 (`api-client.ts`); новые файлы — по-русски. `console.*` в production-файлах не используется (единственный случай — отладочные логи одного теста) и не добавляется; пустой `catch` не вводится. Литеральные словари — `as const`; пропсы интерфейсов — `readonly`.

## 6. Компоненты и хуки

- Только функциональные компоненты; классы не используются.
- `ui/` — props-only: данные и колбэки приходят пропсами, `useTheme()` — единственный «внешний» источник. Так: `Button({label, onPress, variant, disabled, testID})`. Не так: компонент `ui/` зовёт `runtime.api`.
- Переиспользуемые примитивы — `React.memo` (`Button`, `TextField`, `Notice`, `StartScreen`; паттерн `XImpl + export const X = React.memo(XImpl)`); экраны-хосты — memo по необходимости, не ритуал.
- Пропсы — интерфейс `XProps` рядом с компонентом, поля `readonly`, события `on*`, опциональные — умолчание в деструктуризации (`variant = 'primary'`).
- Композиция слотами: `TabShellProps.startScreen` (слот Start), `Notice` принимает `children`; оболочка не знает, что внутри слота.
- Хук механизма экрана живёт в файле экрана, пока он один (`useKeyboardTop` в `auth-screen.tsx`); общий хук слоя — экспорт из одного модуля (`useTheme` — `theme/context.ts`; `useSystemReduceMotion` — `bootstrap/tab-shell.tsx`, без копий).
- Машина состояний экрана — union кадров + switch, не булевы флаги: `type Frame = 'first-run' | 'email' | 'code' | …` в `pilot-app.tsx`.

## 7. Состояние

- Состояние живёт у хозяина сценария: кадры флоу — в composition root (`PilotApp`); черновик композера — в route-файле выше слота (`app/(tabs)/[section].tsx`: слот размонтируется, черновик переживает смену вкладки); локальный UI-стейт — `useState`.
- Тема — React-контекст: провайдер наполняется явной парой `(scheme, tokens)` (`ThemeContext.Provider` в `TabShell`; `PilotApp` — корень темы на `/`); чтение палитры — только `useTheme()`; умолчание — dark. Системный `reduceMotion` и схема читаются одним хостом (`useSystemReduceMotion`, `useSystemColorScheme` в `bootstrap/tab-shell.tsx`), дальше — портами.
- Глобальных стор-библиотек нет и не вводится: контексты + порты композиции. Персистенция запрещена («политика „без персиста“» — `start-section-host.tsx`). Мутабельный модульный сценарий допустим только в `mocks/` (`setScenario` в `start-mock.ts`).

## 8. API и заглушки

- Контракт — `src/api/api-client.ts` (`getSession`, `getDisclosure`, `listMissions`); типы wire — только из `src/api/generated/api-5_8.ts`. Сегодня файл написан руками по `api/mock-5_8.json` (шапка: «minimal hand-written typings»); генератора в репозитории нет. Переход на воспроизводимую генерацию из OpenAPI 5.8.2 — ЦЕЛЬ (после приёмки снимка интерфейса бэкенда; STRUCTURE.md §5). Метода `execute` намеренно нет — бизнес-команды идут отдельными экранами действий.
- Рантайм выбирается **резолвером сборки**, не веткой в коде: alias `@pilot/runtime` → `src/mocks/runtime.ts` (mock, по умолчанию) либо `src/bootstrap/http-runtime.ts` (`EXPO_PUBLIC_API_MODE=http`); `metro.config.js` `resolver.resolveRequest` + `jest.config.js` `moduleNameMapper`. Неподдерживаемое значение режима — ошибка на старте (`PILOT_API_MODE_UNSUPPORTED` в обоих рантаймах).
- `src/mocks/` изолирован: production не импортирует `@/mocks`; Demo-AuthProvider живёт в `mocks/runtime.ts`, не в `src/auth/`. Mock-ответы — только синтетика: `evidence: 'SYNTHETIC'`, демо-код — литерал `PILOT_DEMO_CODE` в `mocks/demo-code.ts` (не из env, не логируется).
- HTTP-рантайм fail-closed: без допущенного бэкенда операция даёт именованный отказ `PILOT_HTTP_UNAVAILABLE` либо статус `unavailable` — «We MUST NOT fake success» (`bootstrap/http-runtime.ts`). Тихая заглушка-нуль вместо отказа запрещена и в mock, и в http.

## 9. Ошибки и пустые состояния

- Недоступная операция — **именованный отказ**, не пустой успех: `PILOT_HTTP_UNAVAILABLE`, `PILOT_API_MODE_UNSUPPORTED`; отказ обрабатывает хозяин сцены (композиция ловит и подаёт `missions=null`), экран не знает транспорта. Ошибки не глотаются: промис SDK передаётся хосту (`playHaptic`).
- `unavailable` показывается честно: состояние «недоступно» не изображает работу (F04.V03; `auth-unavailable` — `accessibilityRole="alert"`).
- Пустое состояние — минимальная честная поверхность: пустой Start показывает присутствие агента и **один** композер, не список пустых групп (`start-screen.tsx`); `missions=null` → безопасный fallback. Сообщения — `Notice`/кадр с ролью `alert`; ошибка ввода — именованный testID (`auth-invalid`), сбрасывается при изменении ввода.

## 10. Токены темы

- Цвет/движение — только токены; литеральные hex допустимы **исключительно в токен-модулях-проекциях**: `theme/tokens.ts` (8 базовых D2.2.5.1: ground/ink/panel/card/on-card/primary/on-primary/accent, dark+light), расширение домена (`features/auth/auth-tokens.ts`, `features/onboarding/erstinformation-tokens.ts` — с картой `CSS_TOKENS`), движение (`theme/motion-tokens.ts`, `lib/faden/faden-motion.ts` — дословный порт дизайнера).
- Чтение — `useTheme()` (+ файл расширения домена): статичная геометрия в `StyleSheet`, цвет из токенов.
- Новый токен: значение **побайтово из дизайн-источника** экрана (D2.2.5.1 `tokens.css`; Kompakt D24 — `docs/ux/05_Kompakt_D24/source/tokens.json`; движение — `motion-spec-gespraech.json`), оба режима dark/light, комментарий источника, для нового экрана — карта имён CSS-токенов и тест сверки (прецедент `__tests__/erstinformation-colors.test.tsx`). Второй вручную изобретённый набор имён запрещён (STRUCTURE.md §6).
- Порядок вкладок — `TAB_ORDER` в `theme/tokens.ts`. Раскладочные значения (`flex: 1`) токенами не становятся. Раскладка макетных экранов — по артборду 390×844 (`useArtboard`), координаты из манифеста кадров; размеры/зоны экранов Kompakt — из `tokens.json` пакета (`touch-target.min=44px`).
- ЦЕЛЬ (код не соответствует): литеральные цвета вне токен-модулей — `bootstrap/pilot-app.tsx` (3 hex в стилях, ещё 5 в комментариях; корень 995 под охраной замороженных кадров), `features/auth/auth-screen.tsx` (6 hex), `features/onboarding/welcome-screen.tsx` (2 hex) — снимается задачами миграции, новые строки не добавлять. Размерный ряд (spacing/radius/типографика) не спроецирован — `ui/`-примитивы несут числовые литералы (`borderRadius: 999`).

## 11. Доступность

Правила из продуктовых находок критиков (147/148/149) и токенов Kompakt:

- **Зона касания ≥ 44 px, считается на интерактивном хозяине С УЧЁТОМ padding**: визуальный размер + `padding*` хозяина (+ `hitSlop`, если элемент визуально меньше). Kompakt: `touch-target.min=44px`, видимо меньшие элементы расширяют площадь незаметно (`extend.button-sm=4px`); зона, набранная только padding-ом, — честная (прецедент 149). Не так: зона на декоративной обёртке, не ловящей нажатие.
- **Цель включена, когда сценарий её допускает**: цель в кадре обязана действовать; `disabled` — только по состоянию и синхронно с `accessibilityState={{ disabled }}` (`ui/button.tsx`). Молча выключенная цель — дефект.
- **Одна функция — одна цель**: у каждого Pressable свой `onPress`; один обработчик на две цели, отправляющий ответ одной из них, — дефект (находка 149: оба чипа GA-19 → один обработчик → чужой ответ).
- **Надпись цели = её действие**: ожидание/тест читает видимую надпись нажатого элемента; невидимый текст (`display: 'none'`) не подменяет её (находка 149).
- Роли на хозяине: `accessibilityRole` `button`/`link`/`tab` (`tablist` — `tab-shell.tsx`), `alert` для сообщений, `summary`, `header`; `accessibilityLabel` — из копии каталога, не сочиняется.
- `testID` — на интерактивном хозяине (`Pressable`/`TextInput`), не на обёртке. Системный reduce motion гасит декоративное движение везде (один источник `useSystemReduceMotion`).

## 12. Копия и i18n

- Язык интерфейса — немецкий, обращение **Sie**. Пользовательский текст — только из каталога копии: производные ключи — `src/i18n/ui-copy.ts` (`uiCopyDe`: тексты и `review_status` verbatim из `BrokerOS_UI_Copy_DE.json`), экранная пачка — её `katalog_kopii.json`. Ключи-карты для повторяющихся наборов: `TAB_LABEL_KEYS`, `SECTION_TITLE_KEYS`.
- Формулировки, которых в каталоге нет, — в локальном словаре экрана (`const COPY = {…} as const` в `auth-screen.tsx`) с меткой **PROPOSED**; они ждут решения о каталоге, а не выдаются за signoff; наличие ключа ≠ signoff (CMP-MOB-089).
- Не рассыпать немецкие строки по JSX: словарь `COPY` вверху файла или ключи `uiCopyDe`; новая формулировка — через product/legal review.
- **Юридические тексты**: на экранах Erstinformation/Datenschutz/согласий текст юридического документа НЕ рендерится — вместо него заглушка с названием документа («Здесь будет: <название документа>»). Экран, навигация и показ строятся по-настоящему; заглушка — не пропуск экрана. Ключи и текст заглушки — обычная копия по правилам этого раздела (каталог/словарь экрана), не литерал в JSX.
- ЦЕЛЬ (код не соответствует): `welcome-screen.tsx` дублирует текст каталога константой `COPY_BODY` — ключ `frame.F02.01.body` не заведён в `uiCopyDe`.

## 13. Тесты

**Jest/RNTL** (`jest-expo`, `@testing-library/react-native`; `npm run check` = test + lint + typecheck + doctor):

- Colocated: `__tests__/<subject>.test.ts(x)` у домена/слоя (`features/auth/__tests__/auth-code-input.test.tsx`); междоменное — `mobile/tests/acceptance/` (разрешено, пока пусто).
- Имя судит поведение, не реализацию: `INVALID_CODE`, `RESEND_UNCONFIRMED` (`pilot.test.tsx`); комментарий файла несёт замер, если тест снимает живой дефект.
- Мок — на внешней границе (порт `auth`/`api`; `jest.mock('expo-haptics')`), субъект не подменяется; `render` RNTL v14 — await.
- Запрещены: tautological-тесты, snapshot всей иерархии, мок тестируемого, «просто не падает», ожидания из невидимого дерева. Должная краснеть проверка предъявляется красной на нарушающем входе (прецедент: `execute` порта теста бросает `BUSINESS_COMMAND_FORBIDDEN`). Только синтетика.
- Среда: `jest.setup.ts` ставит кадровые часы rAF 16 мс (канон 145), RN не мокается.

**Maestro** (`mobile/.maestro/`):

- Новый/изменённый экран — со сценарием и скриншотом; в PR — связка «критерий → сценарий → артефакт → коммит» (AGENTS.md). Имя нового файла — `cmp-mob-NNN-<scenario>.yaml`; исторические `start.yaml`, `rehearsal.yaml` не переименовываются.
- Сценарий: `appId: com.complior.mobile`, `launchApp clearState: true`, **`assertVisible` по testID до действия — защита от гонки холодного старта (Н8)**: цель каждого тапа подтверждается ожиданием прежде, чем по ней `tapOn`; шаги по testID (не по координатам), `takeScreenshot` на значимых кадрах.
  - ЦЕЛЬ (код не соответствует): `cmp-mob-004-start.yaml` — тапы `start-composer-input` и `shell-tab-vorgaenge` не предварены `assertVisible` по своей цели; новые сценарии пишутся по правилу сразу.
- Флоу экранных пачек — отдельно от обхода каталога (`.maestro/config.yaml` исключает `erstinformation.yaml`); карта экран → флоу → пути — `mobile/ci-screens.json`, правится автором экранной задачи.

## 14. Ветки, коммиты, PR

- Одна задача — одна ветка и один PR в `main`. Имена веток в дереве: `wip/NNN/<слог>`, `cmp-mob-NNN/<слог>`, `feat/<NNN>-<слог>`, `docs/<слог>`.
- Коммит — предмет и суть в первой строке: `151: модуль отдачи mobile/src/lib/otdacha …`, `docs(ux): D 2.4 Kompakt …`. Строгий Conventional Commits не введён — не выдумывать `type(scope):` там, где дерево пишет `NNN: …`.
- В `main` — только через PR; обязательные проверки `quality` и `android-e2e`; **merge нажимает владелец**. `EXPO_PUBLIC_*` публичны (секретов там нет); секреты и реальные данные в репозиторий не попадают.

## 15. Запрещённое (сводно)

| Что | Вместо |
|---|---|
| Fetch/`XMLHttpRequest`/`WebSocket`, `axios`/`ky`/`undici`/`expo/fetch` вне `src/api/http/`; `import()` с неписаным путём; inline `eslint-disable` | ApiClient через порт; литеральный путь; чинить причину |
| Cross-feature import (включая `import type`) | intent-переход, порт, композиция |
| `features` → `app`/`bootstrap`; нижние слои → экраны; `ui` → `api`/`auth`/`analytics` | §2, слоты и порты |
| Production-импорт `src/mocks`/тестов; правка `api/generated/`, `api/`, `docs/` локально; `export default` вне маршрутов | шов `@pilot/runtime`; апстрим; именованный экспорт |
| Литеральный цвет/размер/отступ в компонентах | токены §10 |
| Тихая заглушка-нуль/поддельный успех вместо отказа | именованный отказ §9 |
| Один обработчик на две цели; зона касания < 44 px на хозяине | §11 |
| Немецкая строка в JSX мимо словаря/ключа | §12 |
| `any`, `console.*`, пустой `catch` | точные типы, именованное состояние |
| Global store, персист, `screens/`/`services/`/`shared/`/`utils/`, новый домен/слой «по усмотрению» | §7; STRUCTURE.md — только задачей |
| Секреты, реальные персональные данные, eVB, e-mail реальных людей | только синтетика |

## 16. Чеклист ревью

- Структура: `npm run lint` зелёный (check-structure + `--max-warnings=0`); место и импорты по §2; новый каталог — только задачей, меняющей STRUCTURE.md + policy.
- Модуль/типы: именованные экспорты (default только маршрут); `./` внутри каталога, `@/` через слои; strict без `any`; пропсы `readonly`; union-кадры вместо флагов.
- UI: токены (`useTheme`); testID/роль/label на хозяине; зона касания ≥ 44 px с учётом padding; один обработчик на цель.
- Данные/копия: ApiClient/порт; отказ именованный; SYNTHETIC в mock; без персиста; ключи `uiCopyDe`/`COPY` verbatim; PROPOSED помечен; Sie.
- Тесты: colocated, поведение на портах, красный вход предъявлен; Maestro-сценарий + скриншоты; `npm run check` зелёный; `ci-screens.json` обновлён при перемещении экрана.
- PR: связка «критерий → сценарий → артефакт → коммит»; commit `NNN: …`; merge — владелец.
