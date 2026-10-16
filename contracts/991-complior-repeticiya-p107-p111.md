# Контракт 991 — совмещённая репетиция П-107/П-111 на Complior-mob

КЛАСС: КОДОВЫЙ — конечный предмет меняет StartScreen и исполняемые Android workflows; это не doc-only допуск.
Статус: черновик для суда, не разрешение push/freeze/раздачи в Complior-mob или Merge. Номер уже выдан: registry/contracts.tsv, `991 → 24070489099050108e3f3b8cb5bd66712d378ffc`; повторного минта нет.

КОНТЕКСТ: `docs/owner/2026-10-15-suzhenie-dopuska-pilota.md` — минимальный допуск; `forks/n-105-konsultant-i-n300-batch.md:21–25` — принятое Б1; `verdicts/consultant/complior-p107-p111-batch-v1.md` — инженерные И1–И7; `forks/n-complior-mob-8-razvilok-reshenija.md` — прежние решения; `forks/n-complior-mob-pilot-budget-token.md` — лимиты. Архивный ArchitectP107P111Draft.md — источник предложения, не санкция; его одно-PR маршрут и HARNESS_TOOLCHAIN=android сюда не переносятся.

## Существующее

- В dev-harness на исходном `8f3a89e4f` 105 УЖЕ реализован: `workshop:887` размещает роли в профиле; `:906–917` строит argv политики; `:1150` передаёт `--config`/`-e` в настоящий exec. 991 потребляет готовый механизм, не переписывает 105/workshop. Число main в старом HANDOFF (`453d5b8db`) не равно исследованному HEAD; источник этой пачки — дерево.
- 103: `scripts/profile_resolver.sh`, `scripts/make_task.sh --repo`, `scripts/pre_critic.sh --repo`, `scripts/spawn_agent.sh` потребляют профильные пути. `scripts/check_project_standard.sh:85–87` пока проверяет lockfile ТОЛЬКО в корне. Согласованная отдельная monorepo-поправка — предусловие допуска, не обход 991: единственный lockfile остаётся `mobile/package-lock.json`.
- 104: `.omp/extensions/spawn-guard.ts`, `scripts/models_actual.sh --tsv --bind`, `scripts/check_sud_model.sh --verdict`, `scripts/judge_gate.sh --verdict-row --sud` уже дают доверенный канал роль/модель/сессия/объект. Второй канал вердиктов 991 не создаёт.
- Живой клон Complior-mob с origin/main `8a699d175114f82395e019964ee1fec02a6bb200`: `mobile/src/features/start/start-screen.tsx` — временный заголовок без действия; соседний `__tests__/start-screen.test.tsx` использует Jest/React Native Testing Library; `mobile/.maestro/start.yaml` открывает настоящий пакет `com.complior.mobile`.
- `.github/workflows/mobile.yml`: quality = npm ci/test/lint/typecheck/doctor; android-e2e зависит от quality, запускается на `[self-hosted, linux, x64, kvm, complior]`, собирает release x86_64 и зовёт `mobile/scripts/ci-e2e.sh`. Скрипт создаёт API 36 AVD, устанавливает APK и запускает Maestro; повтор предусмотрен только при обрыве транспорта, не assertion.
- `.github/workflows/mobile-cloud-e2e.yml`: существующие weekly schedule/dispatch, expo-versions и android-e2e-cloud; установка Maestro пока плавающая. Оба workflow пока выгружают только maestro-out (`warn` при отсутствии), НЕ APK. Требуемая дельта — отдельный APK artifact и проверка каждого обязательного evidence-файла; новый workflow не нужен.
- `workshop:118–125` сохраняет уже заданные machine env, изолированный HOME не отменяется. П-108/109 и станционную установку 093 повторно не строим. Нативный прогон — только station-complior; агентская CLI-проба не претендует на KVM-допуск.

## Предмет и граница

Один наблюдаемый результат: на принятом пине выполнена и предъявлена цепочка **живой вход агента → исходный ContextPack → stop/resume → quality → release APK → station android-e2e → PR/evidence → независимые суды через 104 → новая cloud-сверка того же объекта → owner Merge → зелёный push-run**. Прежний bootstrap-run не является этой цепочкой.

Б1 принят дословно: временный StartScreen «Prüfung starten» → «Prüfung abgeschlossen», сброс при новом запуске. Это синтетическое действие без API, сети и данных пользователя; не UX первого продуктового маршрута. Кнопка имеет accessibilityRole=button и testID=rehearsal-start; completion отсутствует до нажатия, видим после; force-stop/новый запуск БЕЗ очистки данных возвращает начало. Остальные элементы временного StartScreen сохраняются. При замене экрана продуктовым маршрутом временный объект и потерявшие предмет проверки удаляются вместе с ним.

НЕ предмет: Complior-mob V3, Demo/Auth/F02, offline API/mock, Complior-back; рефакторинг продуктовой архитектуры; новая toolchain-опция харнеса; UID станции; настройки GitHub; автоматизация ContextPack/журнала/визуального сравнения вместо согласованной ручной процедуры. `HARNESS_TOOLCHAIN=android` исключён, новый шов — отдельное СОревью.

## Пины, карточка и доверие

Карточка — GitHub issue **a3ka/Complior-mob**, журнал только новыми комментариями (append-only, без переписывания тела/старых комментариев). До действия записать:

- H = принятый полный SHA харнеса с принятыми 103/104/105 и необходимой monorepo-поправкой; P = SHA/хеш эффективного профиля и project-layer; V = реальные версии Node/npm/JDK/SDK/AVD/Maestro. Maestro закрепляется на **2.11.0** и в station-проверке, и в cloud-install; несовпадение — отказ, не тихое обновление.
- B = base SHA, C = PR head SHA, T = фактический checkout SHA/tree CI (для pull_request возможен merge-ref), workflow blob/hash, flow SHA-256, контракт/frozen tag. Не приравнивать T к C без проверки дерева. Изменение B/C/T/H/P/V требует новых соответствующих свидетельств; старый accept не наследуется.
- Фактически выданные task/ContextPack байты и SHA-256, источники brief/design/rules/map/zones/pin, модельная трасса, session-id; reviewer получает ИСХОДНЫЙ task, не пересказ. Настоящий workflow берётся из эффективного профиля; placeholder не принимается.
- Каждое действие: исполнитель, причина, стадия/следующий шаг, время работы/ожидания, run/attempt/PR/artifact и обнаруженный дефект. Stop/resume добавляет новый комментарий со следующим действием, а продолженная сессия действительно выполняет его.
- Общий счёт на всю задачу: ≤4 Merge, ≤8 технических вмешательств, ≤120 минут владельца; смена PR/фазы счёт не обнуляет. Настройка станции/GitHub учитывается отдельно. Превышение любого лимита — стоп и вопрос о сужении; freeze-PR, отрицательная API-проба, добывание PNG и перезапуски учитываются. «Денежный потолок не задан владельцем; консультант докладывает расход ежедневно» — не бесконечная санкция.

Токен владельца и общий uid station-complior — принятый остаточный риск. Агенты/оркестратор НЕ Merge и НЕ меняют настройки обоих repo; доступность токена не разрешение. Владелец с консультантом фиксирует действующие rulesets/required quality+android-e2e/force-delete/bypass перед публикацией. Два судьи — разные вендоры вне семейств architect/implementer, по ФАКТИЧЕСКИМ моделям и fallback, не по пожеланию задания. Sonnet-диспетчер не автор реализации.

## Последовательность без подмены отрицательной пробы

1. **Подготовка без публикации.** Закрепить H/P/V и карточку, проверить профиль штатными resolver/standard, собрать настоящий ContextPack. `workshop <клон Complior>` запускает реальную сессию: зафиксировать cwd/HOME/пин, полученные роли/расширения, выполнить CLI `adb version`, `maestro --version`, `emulator -list-avds` из родителя, явного task-ребёнка и после resume с тем же изолированным HOME. Список AVD и CLI — не запуск локального эмулятора. Без завершённого допуска публикация не начинается.
2. **Отрицательный PR — ОТДЕЛЬНЫЙ и ПЕРВЫЙ.** После отдельного разрешения подготовки implementer пишет этот PR: прежнее приложение, прежние зелёные Jest, новый валидный `mobile/.maestro/rehearsal.yaml` из этой пачки; единственная workflow-дельта — отдельный upload собранного APK при `always()` с `if-no-files-found: error`. Не добавлять красный Jest в quality: это закроет needs:quality и не предъявит Android. quality действительно зелёный; release APK строится; station android-e2e реально падает на `assertVisible id: rehearsal-start` (не синтаксис YAML, зависимость, offline или отсутствующий APK). Этот PR не чинится в положительный.
3. На неподвижном отрицательном объекте — два независимых **FAIL** через 104, сохранённые JUnit/лог конкретного assertion, run/attempt/checkout/flow и отдельный APK artifact с SHA-256. После подтверждения блокировки владелец лично выполняет реальный merge-API запрос с ожидаемым head SHA; HTTP-отказ/ответ сохраняется. GET mergeability, придуманный rc и агент с owner token это не заменяют. Если объект не заведомо заблокирован — запрос НЕ отправляется. PR закрывается **без merge**; следующий этап начинается только после этого evidence.
4. **Freeze-PR**, отдельный от отрицательного и положительного: оркестратор штатно материализует согласованную раскладку `contracts/registry/verdicts/fixtures`, профиль/пин, замороженный текст и проверочные исходники; implementer — автор workflow-проводки этой подготовительной задачи. Новый красный flow хранится в `fixtures/`, НЕ активируется в `mobile/.maestro`; прежний start-flow реально проходит Android, no-op/path-filter не вводится. Freeze-PR проверяет APK и JUnit прежнего start-flow, закрепляет Maestro и uploads; rehearsal PNG здесь ещё не требуются. Freeze-PR обязан пройти quality+android-e2e ДО раздачи изменения StartScreen; Merge только владельцем, учтён в лимите. Тег/реестр и исходный ContextPack выдаются штатными механизмами, не ручной имитацией freeze.
5. **Положительный PR — отдельно.** Только после допуска freeze-PR implementer получает замороженный контракт, меняет StartScreen, переносит **те же байты** Jest в `mobile/src/features/start/__tests__/rehearsal.test.tsx` и native flow в `mobile/.maestro/rehearsal.yaml`, включает обязательную rehearsal evidence-проверку в обоих workflows. SHA-256 Jest совпадает с замороженной фикстурой харнеса, flow — также с отрицательным PR; прежние проверки не меняются. quality и station android-e2e должны реально исполниться, не skipped/cancelled.
6. На неподвижном C после station-run — **новый workflow_dispatch** существующего cloud workflow на зафиксированной ветке C. Зафиксировать head/checkout/tree/run/attempt каждого job; ветка до окончания не двигается. expo-versions и android-e2e-cloud действительно исполнены и зелёны. Старый run и наличие workflow не evidence. Красный version-drift не скрывается: отдельная явно учтённая работа/решение.
7. Adversary и reviewer получают одинаковые H/P/V/B/C/T, исходный task, artifact ids/хеши, station/cloud evidence; задания несут самостоятельную строку `OBJECT=<полный SHA>`. Трассы только из реальных сессий, `models_actual.sh --tsv --bind`; `check_sud_model.sh --verdict … --object … --session …` и `judge_gate.sh … --verdict-row … --sud …` должны принять свидетельства. Неуместный fallback/чужая сессия/смена объекта → новый суд, не правка TSV. Оба accept и подтверждённая независимость необходимы; одна зелень 104 сама межвендорность не доказывает.
8. Владелец открывает конкретные before/after PNG по хешам и принимает UI на C. Только он Merge **без squash/rebase**. Для merge commit M — отдельный **push-run mobile на main**, quality+android-e2e действительно зелёны, происхождение APK/PNG связывается с M. Красный post-merge блокирует следующую поставку. Карточка закрывается только после сверки всей цепочки; недельная cloud-сверка сохраняется, пересмотр общего uid — перед Э8.

## Исполняемые предъявления и проводка

`fixtures/workshop_project/rehearsal_991/rehearsal.test.tsx` — настоящий Jest/RNTL тест публичного StartScreen: нажатие/результат, reset после unmount/new mount. В положительном Complior PR его место — `mobile/src/features/start/__tests__/rehearsal.test.tsx`; обычный `npm test` в quality его выполняет. Нативный reset отдельно проверяет процесс, не только remount. `probe.py` берёт тест из харнеса, поэтому НЕ заменяет приёмную SHA-256 сверку теста из PR.

Исполнение rehearsal-Jest в quality доказывают вместе П2(3) (job `quality` равен B, `npm test` = `jest --ci --runInBand` из `mobile/package.json` вне зоны) и П2(4) (байты теста). Второй, независимой мерой reviewer скачивает лог job quality положительного run и push-run M (`gh run view RUN --repo a3ka/Complior-mob --job JOB --log`). В логе обязаны быть строка `PASS src/features/start/__tests__/rehearsal.test.tsx` и итог `Tests:` с числом пройденных не меньше числа базы плюс 2, иначе `REHEARSAL_JEST_NOT_RUN`. Строка лога печатается кодом из зоны, поэтому одна она, без П2, ничего не доказывает.

`fixtures/workshop_project/rehearsal_991/rehearsal.yaml` — настоящий Maestro flow пакета com.complior.mobile: начало → действие → результат → stopApp/launchApp без очистки. В отрицательном/положительном PR его место одинаково: `mobile/.maestro/rehearsal.yaml`; существующие station/cloud вызовы `maestro test … .maestro` его выполняют.

`fixtures/workshop_project/rehearsal_991/probe.py --repo <одноразовый клон>` запускает реальный Jest с реальным StartScreen (не текстовый grep); rc 0 только при пройденных обеих поведенческих проверках, rc 1 при их провале, rc 2 при неисполнимом измерении/пустой выборке. `--matrix` исполняет честную модель и обманные реализации; привязки контрмоделей к наблюдаемым входам находятся ТОЛЬКО В КОДЕ. Исходные байты до запуска сохраняются в памяти; scratch восстанавливается finally. Модель не является продуктовой реализацией и в Complior delivery не переносится.

Workflow-код всех фаз пишет implementer; оркестратор выдаёт отдельные подготовительную и продуктовую задачи только после их допуска. Сохраняются существующие npm/Gradle/AVD/Maestro команды; в cloud плавающая установка заменяется установкой Maestro 2.11.0 с явной проверкой версии. В обоих workflows:

- release APK `mobile/android/app/build/outputs/apk/release/app-release.apk` выгружается **отдельным** artifact `apk-<checkoutSHA>-<run_id>-<run_attempt>`; Maestro bundle — отдельным `maestro-<checkoutSHA>-<run_id>-<run_attempt>`;
- начиная с положительного PR, включая cloud и post-merge, успешный нативный шаг безусловно проверяет APK, JUnit и **каждый** `rehearsal-before.png`/`rehearsal-after.png` отдельно: непустой ровно один файл каждого имени в текущем чистом maestro-out; копирует их в канонический evidence-каталог с этими именами, сохраняет реальные исходные пути. Не зашивать неподтверждённую раскладку screenshot-подкаталогов Maestro. Включение проверки — явная дельта положительного PR, НЕ условие наличия flow/PNG/каталога;
- JUnit должен нести выполненный требуемый flow без failures/errors/skipped, не просто существовать. `if-no-files-found: error` ставится на оба uploads, но не заменяет индивидуальные проверки файлов. SHA-256 APK/flow/JUnit/PNG, checkout SHA/tree, run/attempt, workflow blob, Maestro version сохраняются рядом; reviewer скачивает artifact по ID и пересчитывает хеши, не доверяет только строкам PR;
- диагностика отрицательного прогона и собранный APK выгружаются при `always()`; отсутствие after PNG у прерванного flow НЕ выдаётся за положительный комплект. Отрицательный сценарий судится по JUnit/assertion и APK, отсутствие позитивного комплекта не скрывает первичную причину.

## Приёмочный критерий

- Дано: неизменённый StartScreen базы `8a699d175114f82395e019964ee1fec02a6bb200`; когда: `python3 fixtures/workshop_project/rehearsal_991/probe.py --repo R`; тогда: rc 1, executed=2, обе проверки красны из-за отсутствующей кнопки. Дано: честный объект после реализации; та же команда → rc 0, executed=2. Пустая/неисполнимая выборка → rc 2, не зелень.
- Дано: одноразовый клон с npm ci; когда: та же команда с `--matrix`; тогда: rc 0, executed=6, честная модель зелена и все кодовые привязки дают ожидаемые исходы. Иначе rc 1; инфраструктурный сбой rc 2. Это измерение силы Jest, не доказательство Android. Reviewer независимо пересчитывает построчные `991 <mode>/<case>: rc=… assertion=…`, а не доверяет только executed.
- Дано: положительный C и замороженные байты Jest из H, снятые reviewer в память ДО запуска PR-кода; когда: reviewer сравнивает SHA-256 вывода `git -C R show C:mobile/src/features/start/__tests__/rehearsal.test.tsx` с SHA-256 `fixtures/workshop_project/rehearsal_991/rehearsal.test.tsx` из H через `test "$actual" = "$expected"` (получение байтов/хешей с `pipefail`, ошибки чтения — отказ); тогда: rc 0. Парный негатив: C подменяет тест пустым `it('R1 starts incomplete and completes only after a press', () => {})` → rc 1, `JEST_BYTES_MISMATCH`; зелёный `probe.py` этого отказа не отменяет.
- Дано: каждый из трёх PR (отрицательный, freeze, положительный) с его base B, head C и фазой F. Байты сравнителя `fixtures/workshop_project/rehearsal_991/compare_carriers.py` reviewer берёт из H, а документы B и C — через `git -C R show`, всё в память ДО запуска кода PR. Когда: `python3 fixtures/workshop_project/rehearsal_991/compare_carriers.py --repo R --base B --head C --phase F`. Тогда: rc 0 только если одновременно:
  (1) каждый путь `git -C R diff --name-only B C` лежит в ЗОНА implementer, иначе `PR_ZONE_VIOLATION: <путь>`;
  (2) `mobile/src/features/start/__tests__/start-screen.test.tsx`, `mobile/.maestro/start.yaml` и каждый файл `mobile/scripts/`, существующий в B, байт-в-байт равны B, иначе `EXISTING_CHECK_CHANGED: <путь>`;
  (3) каждый workflow C как разобранный YAML-объект равен B после изъятия ровно дельт фазы F, иначе `CARRIER_CHANGED: <файл>:<job>:<узел>`;
  (4) присутствующие в C ПИН-файлы равны фикстурам H, иначе `JEST_BYTES_MISMATCH` / `FLOW_BYTES_MISMATCH`.

  Неразбираемый YAML, отсутствующий блоб или нечитаемый объект дают rc 2, не зелень. `--matrix` исполняет честную дельту каждой фазы (rc 0) и обманные C; привязка каждого обмана к узлу и причине — только в коде. Матрица покрывает как минимум следующие классы:
  - аргументы или флаги существующего `run` (`npm test -- --testPathIgnorePatterns=rehearsal`);
  - `continue-on-error` или `if:` на существующем шаге и на уровне job;
  - новый шаг до нативного шага и новый шаг в `quality`;
  - изменённый каталог flows в `ci-e2e.sh` и в `script:` cloud-эмулятора;
  - фильтры в `on`;
  - `continue-on-error` на новом evidence-шаге.

  Сравнитель предъявлен красным до круга критика. Сравнение механическое. Cognitive-only, класс 4, ловец reviewer, остаётся только чтение тела Д3: побочные действия install-шага помимо установки Maestro 2.11.0.
  Значения F: `negative`, `freeze`, `positive`. Грамматика структурных дельт и идентификаторы новых шагов — `compare_carriers.py --help`; тела новых проверок судит отдельный replay ниже. Для красной пробы достаточно `--repo R --base B --matrix`; C-варианты строятся в памяти из настоящего Git-снимка B, без изменения чужого checkout.
- Дано: старый release APK на station-complior и валидный flow; когда: `maestro --device SERIAL test --format junit --output OUT/report.xml --test-output-dir OUT fixtures/workshop_project/rehearsal_991/rehearsal.yaml`; тогда: ненулевой rc именно на отсутствии rehearsal-start. Дано: новый release APK; та же команда/байты → rc 0, before/after PNG и reset. Ни KVM error, ни parser error не засчитываются красным AC. До этого нативного предъявления критический допуск не объявляется завершённым.
- Дано: эффективные YAML обоих workflows на C и полный положительный evidence-комплект; когда: reviewer извлекает их реальные evidence/version `run`-тела в STEP и исполняет `bash --noprofile --norc -eo pipefail STEP` в scratch с теми же cwd/env и вызываемыми файлами C; тогда: rc 0. На независимых копиях комплекта та же команда обязана дать rc≠0 с причиной: отсутствующий/пустой APK, JUnit или каждый PNG — имя файла; дубликат PNG — `DUPLICATE_EVIDENCE`; JUnit с failure/error/skipped или без выполненного rehearsal — `JUNIT_REHEARSAL_INVALID`; Maestro не 2.11.0 — `MAESTRO_VERSION_MISMATCH`. Ожидания и исходные байты reviewer держит в памяти до вызова; отсутствие шага или его неприменимость на положительном C — отказ, не skip.
- Дано: вместо evidence-проверки YAML-шаг `{name: Check evidence, run: test -d maestro-out}` при существующем maestro-out БЕЗ `rehearsal-after.png`; отдельно вместо version-проверки `{name: Check Maestro, run: maestro --version || true}` при доступной версии НЕ 2.11.0. Когда: reviewer делает предыдущий replay ИМЕННО этих эффективных шагов и проверяет `test "$step_rc" -ne 0`; тогда: эта проверка возвращает rc 1, reviewer пишет FAIL `EVIDENCE_CHECK_PLACEBO: rehearsal-after.png` / `VERSION_CHECK_PLACEBO: Maestro`, даже если оригинальный Android-run зелёный и его artifacts полны. На честных шагах тот же негатив даёт step_rc≠0 с соответствующей причиной, проверка ожидания rc 0. Класс 4, cognitive-only: извлечение шагов и проверка их обязательного вызова в YAML — reviewer; replay не подменяется запуском неиспользуемого helper.
- Дано: положительный PR; когда: `gh pr checks <PR> --repo a3ka/Complior-mob --required`; тогда: rc 0 и API jobs конкретного run подтверждает success обоих quality/android-e2e. Парный негатив — отдельный отрицательный PR: quality success, android-e2e failure, два FAIL и сохранённый HTTP-отказ владельцу, PR closed/unmerged. Проверка только общей зелени списка без jobs/provenance не засчитывается.
  Исполнение rehearsal-Jest в quality доказывают вместе П2(3) (job `quality` равен B, `npm test` = `jest --ci --runInBand` из `mobile/package.json` вне зоны) и П2(4) (байты теста). Второй, независимой мерой reviewer скачивает лог job quality положительного run и push-run M (`gh run view RUN --repo a3ka/Complior-mob --job JOB --log`). В логе обязаны быть строка `PASS src/features/start/__tests__/rehearsal.test.tsx` и итог `Tests:` с числом пройденных не меньше числа базы плюс 2, иначе `REHEARSAL_JEST_NOT_RUN`. Строка лога печатается кодом из зоны, поэтому одна она, без П2, ничего не доказывает.
- Дано: station/cloud artifacts принятого объекта; когда: reviewer скачивает их по run/artifact ID, сверяет SHA-256, JUnit и файлы с сохранённым до проверки объектом; тогда: полный комплект, новый cloud dispatch и одинаковый AC/flow, без требования равенства байтов двух APK/PNG. Парный негатив: отсутствие любого APK/JUnit/PNG или несовпадение объекта → отказ с именем отсутствующего/чужого свидетельства. Класс 4, cognitive-only: ручная сверка API/происхождения, ловец reviewer, затем владелец.
- Дано: две реальные сессии вход/resume и ребёнок; когда: они исполняют следующий шаг карточки и CLI-пробы, а reviewer сравнивает исходный ContextPack, HOME, пины и трассы; тогда: доказан вход именно в Complior, не в dev-harness. Парный негатив — placeholder/чужой pack/лишь баннер probe/прочитанный вместо исполненного resume → отказ допуска. Класс 4, cognitive-only до живой репетиции.
- Дано: реальные суды; когда: штатные команды 104 материализуют verdict; тогда: rc 0 для своих объекта/сессии и допустимых моделей, два независимых accept; чужое свидетельство → ненулевой rc 104 и отсутствие признанного accept. Межвендорность всех фактических fallback — ручная сверка reviewer, не новая гарантия самого 104.
- Дано: owner Merge commit M; когда: `gh run view RUN --repo a3ka/Complior-mob --exit-status` для нового push-run M и сверка jobs/evidence; тогда: rc 0, оба обязательных job success, M соответствует принятому merge без squash/rebase. Парный негатив: failure/skipped/чужой SHA → отказ закрытия репетиции и стоп следующей поставки.

## Зоны и исполнители

ЗОНА architect: contracts/991-complior-repeticiya-p107-p111.md fixtures/workshop_project/rehearsal_991/
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/rehearsal_991/ — 105 architect-зона (frozen, done/contracts/105/1): 991 размещает новые красные fixtures/workshop_project/rehearsal_991/ внутри уже-замороженного architect-каталога 105 (прецедент А-114/А-116/А-155 — новая fixture-семья до собственной заморозки 991 коммитится только в существующей frozen-зоне); семантика и файлы 105 не меняются, 991 только добавляет поддиректорию.

Следующая ЗОНА — пути от корня Complior-mob для его проектного check_zones, не раздача реализации в dev-harness. Она вступает в работу только после отдельного допуска: подготовительная задача — отрицательный и freeze-PR; изменение StartScreen/Jest и активация rehearsal evidence — только после принятого freeze-PR. Автор всех workflow-правок — implementer.

ЗОНА implementer: mobile/src/features/start/start-screen.tsx mobile/src/features/start/__tests__/rehearsal.test.tsx mobile/.maestro/rehearsal.yaml .github/workflows/mobile.yml .github/workflows/mobile-cloud-e2e.yml mobile/scripts/

Каждый путь ЗОНА implementer несёт ровно один класс, и класс определяет, чем судится его изменение. ПРОДУКТ — `mobile/src/features/start/start-screen.tsx`: меняется свободно, судится поведением (`probe.py`, Jest в quality, station Maestro, PNG владельца). ПИН — `mobile/src/features/start/__tests__/rehearsal.test.tsx`, `mobile/.maestro/rehearsal.yaml`: байты равны фикстурам H. КАРКАС — `.github/workflows/mobile.yml`, `.github/workflows/mobile-cloud-e2e.yml` и каждый файл `mobile/scripts/`, существующий в B: запрет по умолчанию, всё содержимое B сохраняется, меняются только дельты фазы из закрытого списка ниже. НОВЫЙ — файл `mobile/scripts/`, отсутствующий в B: допустим только как тело evidence/version-проверки и судится replay. Зона даёт право на путь, но не право менять существующие в нём проверки. Узел КАРКАСА, не названный дельтой фазы, не меняется, даже если правка выглядит безобидной.

Закрытый список дельт КАРКАСА:
- Д1 — новый upload-шаг release APK `apk-<checkoutSHA>-<run_id>-<run_attempt>` с `if: always()` и `if-no-files-found: error`;
- Д2 — у существующего шага `Артефакты (скриншоты, отчёт)` меняются только `with.name` (`maestro-<checkoutSHA>-<run_id>-<run_attempt>`) и `with.if-no-files-found: error`;
- Д3 — в `mobile-cloud-e2e.yml` тело шага `Maestro` заменяется установкой 2.11.0; новый шаг проверки версии Maestro в обоих workflows;
- Д4 — новый шаг rehearsal evidence-проверки в обоих workflows.

Фазы:
- отрицательный PR — только Д1 в `mobile.yml`;
- freeze-PR — Д1, Д2, Д3 в обоих workflows;
- положительный PR — только Д4.

Новые шаги стоят только ПОСЛЕ шага `Эмулятор API 36 + сценарии Maestro` своего job, без `continue-on-error`; `if:` допустим только `always()` и только у upload-шагов. Вне дельт меняться не может ничего:
- jobs `quality` и `expo-versions` целиком;
- ключи верхнего уровня (`name`, `on`, `permissions`, `concurrency`, `defaults`, `env`);
- набор jobs;
- каждый ключ job, кроме `steps`;
- каждый существующий шаг и порядок шагов;
- существующие файлы `mobile/scripts/`.

В dev-harness 103/104/105 потребляются без правок roles/charter/registry/workshop. Подготовительные профиль/пин/контрактные каталоги материализует оркестратор штатным маршрутом; это не авторство workflow-кода. Замороженный 991 предъявляется проектной сессии как проверочный контракт харнеса; его номер не минтится второй раз в проекте.

Исключения из предмета и будущих задач: Complior-mob V3 и api/; Complior-back; workshop; scripts/check_project_standard.sh; config/agent_models.json; GitHub settings; настройка станции. Новые отказы вне предмета → наблюдение и отдельный контракт, не рост 991.

## Модель угроз

ЗАЩИЩАЕТ:
- от декларативного допуска без поведения: настоящий Jest и native flow судят действие, результат и reset, отрицательный PR обязан достигнуть Android;
- от принятия чужого результата: карточка связывает объект, проверку, session/run/attempt и скачанные artifacts, 104 проверяет собственную привязку судьи;
- от зелени при неполном доказательстве: обязательны индивидуальные APK/JUnit/PNG и post-merge run, а не существование каталога upload.
- от ослабления существующих проверок через файлы-носители в зоне implementer: КАРКАС сравнивается с B по закрытому списку дельт фазы, а не по перечню запретов.

НЕ ЗАЩИЩАЕТ:
- от злоумышленника с общим uid/owner token: принятый риск, ручной Merge и недельная независимая cloud-сверка, не мнимая credential isolation;
- от визуального дефекта, который не выразили assertions: владелец принимает конкретные PNG, автоматический pixel-diff не заявлен;
- от пропуска ручной записи/сверки: cognitive-only журнал и проверка reviewer; проба модели не заменяет реальный вход/Android/облако.
- от побочного действия в теле заменённого install-шага Maestro (Д3): ручное чтение reviewer, класс 4.

## ПРОВОДКА

ПРОВОДКА:
- guard=fixtures/workshop_project/rehearsal_991/probe.py
- guard=fixtures/workshop_project/rehearsal_991/compare_carriers.py

ПРОВОДКА-ЭНФОРСМЕНТ: проверочный код 991 потребляется scoped Jest-прогоном до критика и существующими quality/android-e2e/cloud Complior workflows после допуска; не добавлять в CI dev-harness зависимость от чужого checkout/SDK. Поведенческие нормы Merge/пинов/104 уже действуют, новая норма роли не вводится. Ручные этапы — назначенная репетиция с названным ловцом, не новый общий регламент.

## Замер этой пачки и незавершённый допуск

Живой npm ci в свежем разрешённом клоне Complior базы `8a699d175114f82395e019964ee1fec02a6bb200` → rc 0. Scoped `probe.py` → rc 1, executed=2; обе ошибки — `Unable to find an element with role: button, name: Prüfung starten`. `probe.py --matrix` → rc 0, executed=6; вывод каждого прогона несёт отдельный rc и реально исполненный assertion. Число проверок здесь — вывод раннера; строки MATRIX/CASES доступны для независимого пересчёта.

Структурный `compare_carriers.py --repo R --base 8a699d175114f82395e019964ee1fec02a6bb200 --matrix` на живом клоне Complior → rc 0, executed=30, mismatches=0: честные дельты negative/freeze/positive дают rc 0, каждое кодовое красное предъявление — свой именованный отказ; неисполнимые сравнения дают rc 2. Обычный CLI при B=C → rc 0; нечитаемый head → rc 2 `UNREADABLE_INPUT`. Это замер сравнителя, НЕ запуск новых workflow-тел и НЕ свидетельство Android.
Отдельный CLI-smoke через настоящие Git B/C-объекты и `diff --name-only` → executed=5, mismatches=0: дельты каждой фазы rc 0, изменение quality rc 1 `CARRIER_CHANGED`, вне-зонный путь rc 1 `PR_ZONE_VIOLATION`. Объекты созданы во временном изолированном object store поверх живой базы; checkout/refs Complior не менялись, временный store и smoke удалены после прогона.

Native Maestro red/green, настоящий workshop/task/resume, новые PR/runs, merge-API отказ, суды 104, cloud и owner Merge/post-merge — **NOT_RUN**, не выдуманные результаты. Б1 разрешил подготовку, не эти публикации. Replay будущих workflow-проверок и SHA-256 сверка будущего Jest в PR — также **NOT_RUN**; это критерии приёмки implementer, не объявление уже реализованной гарантии. Нативное красное предъявление до критика требует разрешённого scoped запуска на station-complior либо допуска отрицательного PR; без него критерий подготовки native red остаётся открытым. Отдельная monorepo-поправка 103 также не объявляется сделанной этой пачкой.

## Незаполненные требования:
- Живой station Maestro red до критического допуска.
- Разрешение исполнения публикационной репетиции.
- Принятый H с monorepo-поправкой 103. Это условия допуска, не право ослабить приёмку; черновик не объявляет П-107/П-111 закрытыми.
