# Пилот: новый Complior, мобильный фронт, Android-first (Astra, 2026-10-14)

Решения владельца 2026-10-14: пилот — новый проект Complior (новый репозиторий, создаёт владелец; старый Complior не трогаем); пилотом берём мобильный фронт (Expo/React Native/TypeScript); бэкенд Fastify+TypeScript+PostgreSQL — позже. Исходный план владельца — BrokerOS_AI_UX_UI_Mobile_Workflow_RU.pdf (2026-10-10).

# Решение: новый Complior, один мобильный маршрут, Android-first

**Монорепозиторий с `mobile/` сейчас; `backend/` и общий API-контракт — только при появлении бэкенда. Пилот запускается после Э0 + Э1 + узкого мобильного допуска Э1м, не после одного зелёного Jest.**

Здесь **«предлагаю» — проектное решение**, **[INFERENCE] — оценка или непроверенное поведение**. Старый Complior и `standard-v1.md` не использовались как основание нового проекта. Файлы не меняла.

## 1. Условия старта и реальные возможности харнеса

| Условие | Решение и поправка |
|---|---|
| **1. Дизайн подготовлен владельцем** | **Подтверждаю для выбранного маршрута**, не для всего приложения. Нужны brief, `design/tokens.json`, каталог используемых компонентов, состояния и переходы, экспорт/снимок прототипа Claude Design. Одной ссылки в закрытый редактор недостаточно: агенту нужны доступные файлы. Веб-прототип — спецификация поведения и оформления, **не эталон нативного рендеринга**. |
| **2. Владелец создаёт Expo-каркас** | **Подтверждаю, усиливаю:** открывается на телефоне; Jest/RNTL проверяет реальное поведение; собственный APK устанавливается на эмулятор, проходит один Maestro-flow и сохраняет PNG. Expo Go годится для знакомства, но не как единственная среда приёмки. Нужен повторяемый CI из чистого checkout. |
| **3. Первая задача узкая** | **Подтверждаю:** один законченный маршрут на синтетических данных, Android-эмулятор. Без Fastify/PostgreSQL, настоящего AI/OCR, авторизации, платежей, push и магазинов. Точный маршрут берётся из **нового** brief; F/W из BrokerOS не переносить автоматически. |
| **4. Проверки и утверждение экранов** | **Подтверждаю с разделением:** Jest/RNTL — логика и взаимодействия; Maestro — установленное приложение; PNG — визуальное свидетельство; владелец — продуктовый/визуальный accept новых экранов. Одобрение относится к конкретным SHA и снимкам. Утверждённый **нативный** снимок становится baseline; автоматическое сравнение надо отдельно подключить — `takeScreenshot` само регрессию не проверяет. |
| **Учёт вмешательства** | Записывать каждое утверждение экранов, минуты работы и ожидания. Выбор дизайна — класс «воля владельца»; ручное добывание PNG, перезапуск CI, Merge — технические вмешательства. Дополнительно показывать число обязательных ручных UI-accept: нельзя назвать визуальную приёмку автономной, спрятав её в продуктовые решения. |
| **Структура** | Один Git-репозиторий, один профиль, один CI и один PR на маршрут. Пока **один npm-пакет в `mobile/`**, без Nx/Turborepo и даже без обязательного workspace. При появлении второго пакета — npm workspaces и общий root-lockfile отдельным ADR. Это монорепо по размещению кода, не обещание готового affected-графа. |

### Что проверено в `./repo`

| Свидетельство | Вывод для мобильного пилота |
|---|---|
| Checkout `dde57e8c`; его checkpoint сообщает: 093 слит, post-merge CI красный по `check:zones` | Нельзя считать Э0 закрытым только по ленду. Этот CI здесь не перезапускала; установка на станции не подтверждена. |
| `HARNESS_PROJECT_LAYER_ROOT=. bash scripts/profile_resolver.sh --repo .` → **rc=0** | Реальный resolver работает, но текущий профиль выдаёт четыре команды `true` и пустые mandatory barriers. Валидность профиля ≠ готовность проекта. |
| `scripts/profile_resolver.sh:42–119,329–355` | Есть `language: "typescript"`, четыре команды, пути workflow, `contextPack`. Нет специального Expo/Android-профиля. |
| `make_task.sh`, `pre_critic.sh`, `spawn_agent.sh`; сравнение этих файлов с веткой 095 implementer не показало дельты | Механизмы уже в checkout, но остаются привязки к `contracts/`, корню харнеса; `make_task` создаёт placeholder отсутствующего workflow. Это исправляется в Э1, а не обходится шаблоном Complior. |
| `bash scripts/make_task.sh --repo . --role orchestrator --kind brief` → **rc=1**, «нет свидетельства модели» | Нельзя подменить живое свидетельство модели самостоятельно написанным TSV и объявить вход агента доказанным. |
| `spawn-guard.ts` найден в 099, отсутствует в текущем `.omp/extensions/` | Ветка проверяет реальные `task`-вызовы, но читает конфигурацию из `cwd/config/agent_models.json`. Для внешнего проекта нужен доверенный источник из установки харнеса; **не копия конфигурации моделей в Complior**. |
| `gen_ci_workflow.sh:90–125` | Генератор пишет простой Ubuntu-job с командами; не настраивает Node, npm install, JDK, эмулятор, Maestro и артефакты. Готовый мобильный workflow он сейчас не создаёт. |
| `config/agent_models.json:23–27` | `vision → @minimax`, fallback отсутствует; комментарий прямо фиксирует долг по инструменту просмотра изображений. Это **не работающий vision-судья**. |
| Проверка доступных команд и `gh auth status` | В этом shell не обнаружены `adb`, `emulator`, `maestro`; GitHub-авторизации нет. Нативная сборка, станционный KVM и GitHub ruleset здесь не проверены. |

---

## 2. Шаблон нового репозитория: действия владельца

### 2.1. Дерево

```text
complior/
├── AGENTS.md
├── README.md
├── harness.project.json
├── .node-version
├── .github/
│   ├── CODEOWNERS
│   ├── ISSUE_TEMPLATE/screen.md
│   └── workflows/mobile.yml
├── registry/project.json
├── contracts/                       # задачи харнеса; не API-контракт
├── verdicts/
├── fixtures/                        # оболочки обязательных проектных проверок
├── design/
│   ├── tokens.json
│   ├── prototype/                   # экспорт, версия, происхождение
│   └── baselines/android/           # PNG + manifest утверждения
├── docs/
│   ├── product-brief.md
│   ├── DEVELOPMENT.md
│   ├── screen-map.md
│   ├── component-catalog.md
│   ├── test-environment.md
│   └── adr/001-mobile-pilot.md
└── mobile/
    ├── package.json
    ├── package-lock.json
    ├── app.json
    ├── tsconfig.json
    ├── eslint.config.js
    ├── jest.config.js
    ├── src/
    │   ├── app/                    # маршруты Expo Router
    │   ├── features/<route>/
    │   ├── components/
    │   └── fixtures/               # синтетические данные приложения
    ├── assets/fonts/
    ├── __tests__/
    └── .maestro/pilot.yaml
```

`backend/`, `packages/api-contract/` и EAS-конфигурацию пока не создавать «на будущее». `mobile/android/`, `mobile/ios/` при выбранном **CNG/prebuild** — генерируемые, игнорируемые; нативные изменения — через app config/config plugins.

### 2.2. Последовательность и проверка

Команды ниже — **для нового репозитория**, не утверждение, что он уже создан. `$H` — путь к принятой установке харнеса.

| № | Что сделать | Как проверить |
|---|---|---|
| **1** | Создать новый private/public repo, `main`; новый Android application ID. Не копировать историю, секреты, зависимости или данные старого Complior. | `git remote -v`; `git log --oneline`; после каркаса — `npm --prefix mobile exec -- expo config --type public`. |
| **2** | Записать brief: пользователь, цель, один маршрут, состояния, вне scope, критерии завершения. Зафиксировать экспорт прототипа и tokens. | `jq -e . design/tokens.json`; `git ls-files docs design`; владелец проходит прототип по acceptance-checklist. Команда не заменяет смысловую проверку дизайна. |
| **3** | Создать Expo-каркас с фиксированным шаблоном: `npx create-expo-app@5.0.0 mobile --template default@57.0.30`. Привести сгенерированный `AGENTS.md` к правилам ниже, не оставлять конфликтующие инструкции. | `npm --prefix mobile ls expo react react-native`; `npm --prefix mobile exec -- expo start` → открыть на телефоне. |
| **4** | Установить совместимые `jest-expo`, Jest, RNTL, типы Jest; настроить preset `jest-expo`. ESLint/TypeScript — по Expo-шаблону, `strict: true`. Один тест должен проверять действие пользователя и результат, не snapshot всего дерева. | Из `mobile/`: `npx expo install jest-expo jest @types/jest @testing-library/react-native --dev`; затем команды таблицы ниже. |
| **5** | Написать `AGENTS.md`, карту экранов, каталог компонентов, ADR. Удалить демонстрационные экраны шаблона, не нужные маршруту. | `git ls-files AGENTS.md docs mobile/src`; проверить, что каждый F/W первого маршрута имеет путь реализации, состояния и проверку. |
| **6** | Заполнить оба слоя профиля; создать **настоящий** `mobile.yml` до проверки профиля. Пин харнеса сохранить в `DEVELOPMENT.md` и настройке запуска; версия project layer — отдельный пин. | `HARNESS_PROJECT_LAYER_ROOT="$PWD" bash "$H/scripts/profile_resolver.sh" --repo "$PWD"`; затем живая репетиция task/reviewer в Э1. |
| **7** | Добавить синтетический маршрут, устойчивые `testID`, Maestro-flow с действиями, assertions и `takeScreenshot`. Сценарий должен сбрасывать состояние. | `adb install -r mobile/android/app/build/outputs/apk/release/app-release.apk`; из `mobile/`: `maestro test .maestro/pilot.yaml`. |
| **8** | Настроить CI, публикацию артефактов, baseline и evidence-index. Нативный APK должен работать **без Metro**. | `gh run view RUN_ID --json conclusion,jobs,headSha`; `gh run download RUN_ID`; открыть PNG и установить APK. |
| **9** | Защитить `main`, workflow, baseline, профиль и правила проверок. Проверить реальные отказы на проверочном репозитории с эквивалентными настройками. | `gh api repos/OWNER/REPO/rulesets`; `gh api repos/OWNER/REPO/branches/main/protection` — если используется branch protection; `gh pr checks PR`. |
| **10** | Выполнить повтор из чистого checkout: установка → проверки → APK → Maestro → снимки → независимый accept → owner approval → Merge → post-merge CI. | Повторить команды без локальных `node_modules`/AVD-состояния; сохранить run ID, SHA, версии и вмешательства. Только после этого — первая агентская продуктовая задача. |

### 2.3. Версии и команды

Официальная [матрица Expo](https://docs.expo.dev/versions/latest/) сейчас содержит SDK 57: RN 0.86, React 19.2.3, Node ≥22.13, Android compile/target API 36. Дополнительно запросами `npm view` проверены: **Expo 57.0.28**, шаблон **57.0.30**, `create-expo-app` **5.0.0**, `expo-doctor` **1.20.4**.

| Компонент | Пин / правило | Проверка владельца |
|---|---|---|
| Node/npm | **Предлагаю Node 24 LTS**, конкретный доступный patch, например проверенный в registry **24.21.0**. Точный Node — `.node-version`; npm — точная версия в `packageManager`. Не Arch `nodejs` с плавающим major. | `node --version`; `npm --version`. |
| Expo/RN | SDK **57**, исходный шаблон выше; RN **0.86.3**, React **19.2.3** из его зависимостей. Не обновлять RN независимо от Expo. | `npm --prefix mobile ls expo react react-native`; `npx expo install --check` из `mobile/`. |
| JDK | **17**, точный vendor/patch записать после установки; согласовать `JAVA_HOME` локально и в CI. Это рекомендованный Expo Android toolchain. | `java -version`; `mobile/android/gradlew -p mobile/android --version`. |
| Android | Platform **36**; image **`system-images;android-36;google_apis;x86_64`**; Build Tools/NDK/CMake — версии, требуемые сгенерированным SDK 57 проектом, не «самые новые». | `sdkmanager --list_installed`; `emulator -version`; `adb version`. |
| Maestro | Зафиксировать конкретный релиз CLI после smoke, не `latest` на каждом CI. JDK 17+ поддерживается [инструкцией Maestro](https://docs.maestro.dev/maestro-cli/how-to-install-maestro-cli). | `maestro --version`; повтор одного flow. |
| Lockfile | Пока **только `mobile/package-lock.json`**, устанавливать через `npm ci`. Нет параллельных yarn/pnpm-lock. | `npm --prefix mobile ci`; `git diff --exit-code -- mobile/package-lock.json`. |

В `mobile/package.json` определить:

| Script | Значение |
|---|---|
| `test` | `jest --ci --runInBand` |
| `lint` | `eslint . --max-warnings=0` |
| `typecheck` | `tsc --noEmit` |
| `doctor` | `expo-doctor` — пакет `expo-doctor@1.20.4` закрепить devDependency |
| `build` | `expo prebuild --platform android --no-install && cd android && ./gradlew :app:assembleRelease --no-daemon -PreactNativeArchitectures=x86_64` |

**[INFERENCE] Конкретную сборку SDK 57 здесь не выполняла.** Это рецепт для эмуляторного APK: на bootstrap проверить debug/test-подпись release-варианта, отсутствие обращения к production-keystore и успешную установку. Не объявлять такой APK магазинным релизом. `expo export --platform android` можно добавить как быструю проверку bundle, но **это не нативная сборка**. Телефон ARM64 — отдельная сборка, не приведённый x86_64 APK.

### 2.4. `harness.project.json` по существующей схеме

Заменить `OWNER` на реального владельца. `barriers: []` ниже означает **ещё не подключённые профильные барьеры**, а не разрешение пропустить обязательный Android CI.

```json
{
  "schemaVersion": 1,
  "repoId": "complior",
  "language": "typescript",
  "projectLayer": {
    "version": "1",
    "profilePath": "registry/project.json"
  },
  "workflowPaths": {
    "contracts": "contracts",
    "verdicts": "verdicts",
    "registry": "registry",
    "fixtures": "fixtures"
  },
  "commands": {
    "test": "npm --prefix mobile test",
    "build": "npm --prefix mobile run build",
    "typecheck": "npm --prefix mobile run typecheck",
    "lint": "npm --prefix mobile run lint"
  },
  "git": {
    "canonicalRemote": "https://github.com/OWNER/complior.git"
  },
  "ci": {
    "workflow": ".github/workflows/mobile.yml"
  },
  "barriers": {
    "mandatory": [],
    "optional": []
  },
  "contextPack": {
    "rows": [
      {
        "kind": "rules",
        "path": "AGENTS.md",
        "roles": "orchestrator,architect,critic,implementer,adversary,reviewer,arbiter",
        "mandatory": true,
        "why": "границы и правила нового проекта"
      },
      {
        "kind": "rules",
        "path": "docs/DEVELOPMENT.md",
        "roles": "architect,critic,implementer,adversary,reviewer",
        "mandatory": true,
        "why": "команды и среда"
      },
      {
        "kind": "map",
        "path": "docs/screen-map.md",
        "roles": "orchestrator,architect,critic,implementer,adversary,reviewer",
        "mandatory": true,
        "why": "маршруты, модули и источники"
      },
      {
        "kind": "reuse",
        "path": "docs/component-catalog.md",
        "roles": "architect,critic,implementer,reviewer",
        "mandatory": true,
        "why": "переиспользование W-компонентов"
      }
    ],
    "adrPath": "docs/adr"
  }
}
```

Второй слой — `registry/project.json`:

```json
{
  "schemaVersion": 1,
  "version": "1",
  "projectId": "complior",
  "workspaceId": "complior-mobile"
}
```

| Можно сейчас | Нельзя приписывать текущей схеме |
|---|---|
| Указывать конкретные файлы через `contextPack.rows`; добавить отдельные строки для brief, tokens, test-environment. `rows` заменяется целиком, не дополняется поэлементно. | Поля `framework`, `platforms`, `screenshots`, `device`, `commands.e2e`, `commands.doctor`, `ci.jobs`, `affected`, `full`, `maxAgeHours`, `harnessVersion` — отсутствуют в закрытом словаре. |
| После реализации проектных оболочек объявить их имена в `barriers.mandatory`; генератор ожидает `fixtures/<имя>.sh`. | Нельзя записать `"maestro"` и получить автоматически SDK, загрузку AVD и сбор PNG. Не копировать 12 jobs харнеса. |
| `packs` синтаксически допустим. | Не объявлять выдуманный `expo` pack установленным. Пока правила Expo/TS — проектные документы. |
| Держать оба слоя в одном repo, передавая его корень через `HARNESS_PROJECT_LAYER_ROOT`. | Совпадение строк `version` не является криптографическим пином проверяющей политики. В гибриде доверенная редакция проверок фиксируется отдельно до кандидата. |

### 2.5. Документы и issue

| Файл | Обязательное содержание |
|---|---|
| `AGENTS.md` | 1) Новый проект и границы пилота. 2) Карта и приоритет источников. 3) Команды из корня. 4) Зоны изменений и reuse. 5) TS/React Native conventions. 6) Tokens, локализация, accessibility/testID. 7) Синтетические данные и детерминизм. 8) Доказательства и baseline-policy. 9) Запрет секретов, публикации и самостоятельного ослабления проверок. 10) Когда нужен ADR/решение владельца. |
| `screen-map.md` | `F ID → маршрут/состояние → W ID → файл реализации → данные → Maestro-flow → screenshot`. Добавить связи с brief/prototype и владельца модуля. ID из новых требований; стабильные, не перенумеровывать вслед за файлом. |
| `component-catalog.md` | `W ID`, назначение, props, состояния, accessibility, tokens, реализация, потребители. Один компонент — один хозяин. |
| ADR | `001-…md`; для текущего selector строки **`статус: принято`**, **`область: mobile/*`**, **`решение: …`**. Затем контекст, альтернативы, последствия, проверка. Отдельные решения: Android-first, CNG, fixtures вместо API, baseline-policy. |

**Шаблон экранной issue:**

```text
Название: [Fxx / маршрут] наблюдаемый пользовательский результат
Цель / не входит:
Источники: brief, prototype revision, tokens revision, Fxx/Wxx
КОНТЕКСТ: конкретные файлы и ADR
Зона: mobile/..., docs/..., flow; защищённые файлы — отдельно

Существующее:
  Поиск:
  Исход: использовать | расширить | создать
  Владелец:
  Причина:

Приёмка:
  AC1: исходное состояние → действие → наблюдаемый результат
  AC2: назад / отмена / повторный вход → ожидаемое состояние
  AC3: указанные empty/error/long-text состояния
  AC4: DE и RU; 320 dp; font scale 2.0 — доступен весь текст и CTA
  AC5: Jest/RNTL + установленный APK + Maestro; PNG каждого состояния
  AC6: owner approval новых экранов для точного SHA и PNG-хешей

Доказательства: AC → тест/flow → run ID → artifact → SHA
Бюджет: модели, CI, инженерные часы, owner T/W
```

GitHub issue **не заменяет автоматически** замороженный контракт 095: перевод issue в `contracts/NNN-…md`, выдача номера и запуск — ответственность входного процесса Э1.

---

## 3. CI, скриншоты, детерминизм и секреты

### GitHub Actions: спецификация `.github/workflows/mobile.yml`

Это workflow нового проекта, подготовленный владельцем; **не запускать поверх него нынешний `gen_ci_workflow.sh` — он перезапишет файл упрощённым вариантом**.

| Job / шаг | Что выполнить |
|---|---|
| Общие настройки | `pull_request` и `push` в `main`; `permissions: contents: read`; checkout без сохранения credentials. Actions закрепить commit SHA. Нет `pull_request_target` с исполнением кандидатного кода. |
| `quality` | Ubuntu; Node из `.node-version`; `npm --prefix mobile ci`; затем `test`, `lint`, `typecheck`, `doctor`. |
| `android-e2e` | Ubuntu x86_64 с KVM; JDK 17; те же Node/lockfile; фиксированный Maestro; нативный `build`; затем [android-emulator-runner](https://github.com/ReactiveCircus/android-emulator-runner): `api-level: 36`, `target: google_apis`, `arch: x86_64`, фиксированный device profile, headless, без загрузки старого snapshot. |
| Права KVM на hosted runner | Выдать текущему runner узкий ACL на `/dev/kvm`, например `sudo setfacl -m "u:$(id -un):rw" /dev/kvm`; проверить `emulator -accel-check`. Широкое `chmod 666` **не переносить на станцию**. |
| Выполнение | Установить собранный APK; подготовить размер/локаль/font scale; выполнить Maestro-flow. При ошибке assertions job красный. Никакого `continue-on-error` для обязательной проверки. |
| Артефакты, `if: always()` | JUnit, Maestro debug output, PNG, logcat, APK, сведения о среде и проверяемом commit. Путь PNG задавать явно в `takeScreenshot`; проверить фактическое расположение. Для ожидаемых, но отсутствующих снимков — отказ, не зелёная пустая загрузка. |
| Связь с PR | PR содержит таблицу AC → flow → artifact и превью/ссылки на PNG. Для приватного repo владелец скачивает артефакт авторизованно; не публиковать изображения в случайный внешний хостинг. |
| Защита | Required checks: `quality`, `android-e2e`; PR-only, запрет force/delete, отсутствие агентского bypass. CODEOWNERS на workflow, профиль, baseline и правила приёмки; устаревшие approvals сбрасываются. В гибриде Merge без squash/rebase, затем post-merge CI. |

**[INFERENCE] Время одного небольшого проекта:** quality **2–5 мин**, Android cold build + boot + flow **12–25 мин**, с тёплыми кэшами **6–15 мин**; первый bootstrap **20–40 мин**. Поставить Android timeout порядка **40 мин**, затем уточнить по трём чистым прогонам. Обещание «весь CI ≤6 мин» из харнесного роудмапа сюда автоматически не переносится.

### Детерминизм и baseline

| Предмет | Правило и проверка |
|---|---|
| Устройство | Один AVD/API/ABI/GPU backend для baseline; сохранять package revision образа и версию emulator. Одна API-цифра не фиксирует образ навсегда. `sdkmanager --list_installed`, `adb shell getprop ro.build.fingerprint`. |
| **320px** | Для RN формализовать как **320 dp ширины layout**, не 320 физических пикселей. Например `adb shell wm size 640x1280` и `adb shell wm density 320`; подтвердить `useWindowDimensions().width === 320`. |
| **200% текст** | `adb shell settings put system font_scale 2.0`; не обходить через `allowFontScaling={false}`. Проверить перенос, прокрутку, видимость CTA. На Android нелинейное масштабирование — проверяем реальный результат, не арифметику высот. |
| DE/RU | Явные `de-DE`/`ru-RU`, фиксированный timezone; язык приложения и системные диалоги учитывать раздельно. Минимум DE и RU при обычном размере плюс оба при 320 dp/200%. |
| Время/данные | Фиксированное время **в данных/clock приложения**, стабильные ID и порядок; никаких live API, случайных аватаров и PII. Сценарии проходят те же компоненты и state transitions, что продукт, не отдельные «картинки для теста». |
| Шрифты/движение | Шрифты локально, с кириллицей и umlaut; дождаться загрузки. Отключить системные animations через `settings`, а JS/Reanimated — отдельной настройкой тестовой среды. Не оставлять бесконечные skeleton/курсор в снимке. |
| Baseline | `design/baselines/android/<env>/<locale>/<scale>/<F>-<state>.png`; рядом manifest: SHA приложения, image/toolchain, размеры, fixture revision, PNG hash, ссылка на owner approval. |
| Сравнение | Начать с точного diff при фиксированной среде; например `magick compare -metric AE baseline.png current.png diff.png`. Любой допуск/маска — явная политика; нельзя маскировать продуктовый текст и кнопки. |
| Обновление | Новый экран/изменённый дизайн — явный baseline-update с просмотром old/new/diff владельцем. Агент не может «починить красный» массовым обновлением эталонов. Смена образа/шрифта — отдельная миграция baseline. |
| Секреты | В repo — только имена переменных и безопасные примеры. `EXPO_PUBLIC_*` **публичны в bundle**. EAS token, Apple credentials, Google service account/upload key — вне агентского uid, вне PR-CI и вне APK. `.gitignore` сам по себе не граница доступа. |

---

## 4. Добавка к харнесу и календарь

**Существующий Э1 меняется с Odelix на Complior; это замена пилота, а не второй параллельный проект.** Э2 становится мобильным маршрутом; поздние этапы переключения также должны ссылаться на Complior. Ручная визуальная приёмка — явно внесённое изменение прежней матрицы, требовавшей vision-проверки UI.

Все часы ниже — **[INFERENCE]**, сверх переиспользуемой общей работы Э1.

| Работа | Этап / часы | Наблюдаемая готовность |
|---|---:|---|
| Подключить TS/Expo через существующий профиль; обязательные brief/tokens/map/catalog; исправить внешний root, placeholder workflow, связь задания и запуска | **Э1, +4–8 ч** мобильной специфики | Живой агент в новом repo получает источники; reviewer получает реально выданное задание. Неверная роль/модель/чужая трасса отвергаются. Общую работу 095/099 второй раз в эти часы не считать. |
| SDK/JDK/Maestro/AVD на станции, KVM, расположение данных и лимиты | **Э1м, 6–10 ч** | APK → emulator → Maestro под настоящим `orchagent` и штатным scope; после остановки нет потерянных процессов. |
| Android CI и воспроизводимость среды | **Э1м, 6–10 ч** | Чистый checkout, аппаратное ускорение, flow, PNG; намеренно нарушенный AC даёт красный результат. |
| Свидетельства, baseline и owner-accept | **Э1м, 4–6 ч** | Отсутствующий/чужой PNG не принимается; approval связан с SHA/хешами; время владельца записано. |
| Сквозная репетиция, остановка/продолжение | **Э1м, 4–6 ч** | Восстановлены task/base/head/PR/stage; после Merge проверен результат, сбор доказательств не выполняется владельцем вручную. |
| Vision-судья | **После первого принятого маршрута, +8–16 ч** | Судья реально получает пиксели; различает специально повреждённый экран; модель/роль/объект подтверждены. Тир без изображения не засчитывается. |
| iOS cloud smoke | **После Android-Э2, +6–12 ч** | EAS simulator build и один облачный flow, отчёт связан с проверяемым кодом. Не входной билет Android-пилота. |

### Совместимость с 093

| Объект | Размещение / доступ |
|---|---|
| Харнес runtime | `/opt/orch-agent` остаётся root-owned. **Не устанавливать SDK внутрь**: каталог провизионируется зеркалом харнеса. |
| Android SDK | Предлагаю `/opt/android-sdk`, root-owned, чтение/исполнение агенту; версии и лицензии устанавливает оператор. |
| Рабочее состояние | Repo, AVD, `.android`, Gradle/npm cache — под `/var/lib/orch-agent/`, отдельные каталоги. Не HOME владельца. |
| KVM | Оператор: `sudo usermod -aG kvm orchagent`; новые процессы после изменения групп. Сохранить `/dev/kvm` `root:kvm 660`, не добавлять агента в `harness`, `docker` или sudoers. |
| Проверка | `sudo -u orchagent -H id`; `sudo -u orchagent -H /opt/android-sdk/emulator/emulator -accel-check`; затем **тот же прогон через штатный launcher/scope**, а не только `sudo -u`. |
| Граница | Эмулятор, Gradle и Maestro учитываются лимитом вместе с агентом. ADB — локальный, без внешнего `5037`; один активный AVD на пилот, без общего неограниченного daemon/service. |
| Риск | KVM открывает непривилегированному коду дополнительную поверхность ядра. Это совместимо с uid-границей 093, но не превращает её в VM-песочницу. Новая возможность требует проверки adversary. |

Факт наличия KVM на Hetzner и ноутбуке принимаю от владельца. **Он не доказывает доступ `orchagent`, ускорение внутри launcher и достаточный остаток MemoryMax.**

**Срок:** мобильная добавка **24–40 инженерных часов**. При прежней базе 21–22.10 и 35–40 ч/нед на поток Б новый рабочий ориентир — **26–29.10 [INFERENCE]**, если среда и CI частично готовятся параллельно. 21–22.10 остаётся лишь лучшим случаем при уже готовой мобильной репетиции. Точная формула старта:

**`max(готовность Э0+Э1, готовность Э1м, готовность repo/дизайна владельца)`**.

Красный post-merge харнеса и непроверенная станционная установка — отдельные зависимости; мобильная оценка их не поглощает.

---

## 5. iOS без своего Mac: что существует и сколько стоит

| Вариант | Что реально даёт | Цена по официальным источникам / этап |
|---|---|---|
| **EAS Build с Linux** | Облачная сборка iOS на инфраструктуре Expo. Для симулятора `ios.simulator: true`; Apple Developer account для такой сборки не нужен. Локально iOS Simulator на Arch не запускается. | [Expo pricing](https://expo.dev/pricing): Free — **15 Android + 15 iOS builds**, низкоприоритетная очередь; Starter **$19/мес + usage**, $45 build credit. iOS medium **$2/build**, large **$4/build**. Этап после Android-Э2. |
| **EAS Workflows `type: maestro`** | Реально существует: запускает Maestro на Android Emulator/iOS Simulator, принимает `build_id`, сохраняет screenshots/recordings. **В документации отмечен alpha.** Подписка Maestro Cloud для этого типа не нужна. | [Документация](https://docs.expo.dev/eas/workflows/pre-packaged-jobs/#maestro), [тарифы](https://expo.dev/pricing): Maestro jobs на Free недоступны; на платных — **$0.05 + минуты CI/CD**. macOS medium **$0.075/мин**. |
| **Maestro Cloud** | Управляемые iOS-симуляторы; нужен simulator `.app`, не обычный iPhone `.ipa`. Можно загрузить результат EAS. EAS также имеет **другой** тип job — `maestro-cloud`. | [Официальный тариф](https://maestro.dev/pricing): **$250/device/мес**, цена по максимальной конкурентности, hosted runs unlimited. EAS-сборки оплачиваются отдельно. Для одного маршрута пока не покупать. |
| **Реальный iPhone** | Владелец устанавливает EAS device build/TestFlight и проверяет клавиатуру, safe areas, жесты, VoiceOver/Dynamic Type, разрешения, фон/возврат и реальную производительность. Симулятор и Android этого не доказывают. | [Apple Developer Program](https://developer.apple.com/programs/) — **$99/год**, включает TestFlight. До объявления поддержки iOS/завершения мобильной волны, не обязательно до первого Android-пилота. |

Пример экономики: **[INFERENCE]** один iOS medium build и 10 минут Maestro на macOS medium — **$2 + $0.05 + $0.75 = $2.80** до учёта включённого кредита и дополнительных jobs; плюс план Starter. Бесплатная очередь Expo может ждать **90+ минут** — это указано на тарифной странице, не инженерное время.

Владелец запускает EAS из `mobile/`: `eas build -p ios --profile simulator`; профиль содержит `ios.simulator: true`. [Инструкция Expo](https://docs.expo.dev/build-reference/simulators/). Секреты запуска/публикации остаются в доверенном контуре. **Маскировка токена в логах не делает безопасным его выдачу произвольному кандидатному скрипту.**

---

## 6. Риски фронт-пилота и правило сужения

| Против бэкенд-пилота | Мера / что отрезать первым |
|---|---|
| Больше среды: APK, SDK, AVD, KVM, шрифты | Один API/ABI/device profile. Сначала убрать матрицу устройств, Argent/MCP, облака, iOS; оставить обычные CLI + Maestro. |
| Зелёные тесты не доказывают визуальное качество | Owner UI-accept + реальные PNG. Не заменять работающий экран Jest snapshot или макетом Claude Design. |
| Ручная приёмка создаёт ожидание | Согласовать окно просмотра; отдельно считать owner T/W и UI approvals. Новый экран не считается автономно принятым. |
| Flaky E2E и ложная визуальная регрессия | Чистое состояние, фиксированная среда, устойчивые assertions. Не маскировать проблему автоматическим бесконечным retry или массовым обновлением baseline. |
| Дизайн разрастается раньше результата | Не ждать весь каталог приложения: готовить только законченный маршрут и его обязательные состояния. |
| Frontend fixtures расходятся с будущим backend | Fixtures считать локальным продуктовым примером, **не production API**. Общий runtime-контракт добавить при реальном соединении клиента и сервера. |
| CI кандидата «доказывает себя» | Зафиксировать принятую редакцию проверок, связать CI/artifacts/accept с объектом; изменение проверяющих — отдельная приёмка. |

**Правило сужения:** на пятый рабочий день без сквозной репетиции или при превышении бюджета — сначала убрать универсальность, iOS/cloud/Argent, несколько устройств и украшения вне AC; затем **только решением владельца** уменьшить маршрут до одного законченного сценария. Не сокращать изоляцию 093, независимость судьи, нативный запуск, обязательные состояния, доказательства и post-merge CI. Переход на бэкенд — отдельная смена пилота, не скрытый аварийный обход.

**Итог: готовьте новый Complior как простой монорепозиторий с `mobile/`; стартуйте с одного Android-маршрута после Э0+Э1+Э1м, планируя ещё 24–40 часов мобильной подготовки и ориентир 26–29.10, без объявления ручного UI-accept автономностью.**
