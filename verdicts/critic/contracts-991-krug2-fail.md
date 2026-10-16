FAIL
ПРЕДМЕТ: contracts/991-complior-repeticiya-p107-p111.md (+ fixtures/workshop_project/rehearsal_991/.probe-only — правка пути)
OBJECT=78f0509eb64fa2f49b0e39b5c2bb2a5ad37217ad
ВЕТКА: wip/991/architect (= origin/wip/991/architect); main при суде ff2630f2a
КРУГ: 2 (круг 1 — verdicts/critic/contracts-991-v1.md, FAIL, коммит ff2630f2a)
МОДЕЛЬ: anthropic/claude-opus-5-5 (роль apex; architect — чужое семейство)

АРБИТР: arbiter (roles/arbiter.md). Созываю по повтору причины Б2 круга 1, часть (в): «неизменность
существующих проверок (`:44`) — пожелание без команды». Названный в круге 1 обход (пустой тест +
удалённый header assertion) закрыт ровно названной причиной, но та же причина осталась открытой
для существующих проверок внутри зоны implementer (`.github/workflows/mobile.yml` quality,
`mobile/scripts/ci-e2e.sh`). ПРЕДМЕТ АРБИТРАЖА: достаточно ли закрепить байты двух файлов
(`:69`) для гарантии «обычный `npm test` в quality его выполняет» (`:51`) и «прежние проверки не
меняются» (`:44`), когда файлы, несущие эти проверки, сами входят в ЗОНА implementer `:89`; либо
критерий обязан предъявлять исполнение rehearsal-Jest в quality/неизменность quality-job командой.
Это инженерный вопрос, не воля владельца. Мой ВЫХОД круга 1 перечислил именно два файла — автор
закрыл то, что я назвал; неполнота ВЫХОДА — моя, и это тоже предъявляется арбитру.

## Сверка закрытия блокеров круга 1

|блокер v1|чем закрыт в 78f0509eb|той ли причиной|
|---|---|---|
|Б1: новая evidence/version-проверка не предъявлена КРАСНОЙ (правило 3)|`:71` replay реальных `run`-тел обоих workflows `bash --noprofile --norc -eo pipefail STEP` на копиях комплекта: нет/пустой APK, JUnit, каждый PNG → имя файла; дубликат → `DUPLICATE_EVIDENCE`; JUnit failure/error/skipped → `JUNIT_REHEARSAL_INVALID`; Maestro ≠ 2.11.0 → `MAESTRO_VERSION_MISMATCH`; отсутствие/неприменимость шага на C — отказ. `:72` — ровно мои обманки `test -d maestro-out` и `maestro --version \|\| true` обязаны дать `EVIDENCE_CHECK_PLACEBO`/`VERSION_CHECK_PLACEBO` при зелёном Android-run. «Отягчает» закрыт `:43` (freeze-PR проверяет APK/JUnit start-flow, PNG не требует) и `:60` («Включение проверки — явная дельта положительного PR, НЕ условие наличия flow/PNG/каталога»)|**да** — обход v1 теперь даёт FAIL по названной причине|
|Б2(а): байты Jest не закреплены|`:68` `test "$actual" = "$expected"` SHA-256 `C:mobile/src/features/start/__tests__/rehearsal.test.tsx` против фикстуры из H, байты H в памяти до PR-кода, парный негатив — мой пустой `it(...)` → `JEST_BYTES_MISMATCH`; `:51` прямо: probe.py эту сверку не заменяет|**да**|
|Б2(б): нет ЗОНА-строки implementer|`:89` ЗОНА implementer (пути Complior-mob, `:87`), `:69` сверка `diff --name-only B C` ⊆ зоне, `PR_ZONE_VIOLATION`, класс 4 cognitive-only с названным ловцом reviewer до проектного check_zones|**да** — названный механизм есть|
|Б2(в): неизменность существующих проверок без команды|`:69` `git diff --exit-code B C -- …/start-screen.test.tsx mobile/.maestro/start.yaml` → `EXISTING_CHECK_CHANGED`|**частично** — закрыты два файла моего ВЫХОДА; проверки в in-zone файлах — нет (блокер ниже)|

## Живые замеры этого круга

`<wt>` = /tmp/dev-harness-worktrees/c907157c/wip-991-architect, HEAD 78f0509eb, грязь только `?? .omp/context/`.

|команда|rc|вывод|
|---|---|---|
|`bash scripts/check_precision_gate.sh <wt> contracts/991-…md`|0|`OK`|
|`bash scripts/check_spec_ready.sh <wt> contracts/991-…md`|0|`OK`|
|`bash scripts/pre_critic.sh --repo <wt> contracts/991-…md`|0|`КРИТИК: дверь зелёная`|
|`bash scripts/check_threat_model.sh <wt> contracts/991-…md`|0|ЗАЩИЩАЕТ 3, НЕ ЗАЩИЩАЕТ 3|
|`bash <wt>/scripts/check_ceilings.sh <wt>`|**0**|`потолки в порядке` (в v1 rc 1 — СОВЕТ 1 v1 закрыт `:120-123`)|
|`probe.py --repo …/critic991c1/complior-mob` (HEAD 8a699d175, чисто)|1|`actual/R1 rc=1`, `actual/R2 rc=1`, `executed=2`|
|`probe.py --repo … --matrix`|0|honest/R1,R2 0; noop/R1 1; premature/R1 1; sticky/R2 1; sticky/R1 0; `executed=6`|

Файлы пробы между b7c9f9008 и 78f0509eb не менялись (дифф: контракт + `.probe-only:2`); перепрогон —
подтверждение, не новое измерение. Клон после прогонов чист.

Предъявление обхода (ниже), тот же клон, `mobile/`: фикстура `rehearsal.test.tsx` положена в
`src/features/start/__tests__/rehearsal.test.tsx`, sha256 `eb540c96…54879` = sha256 блоба
`78f0509eb:fixtures/workshop_project/rehearsal_991/rehearsal.test.tsx` (то есть `:68` зелёный),
StartScreen — неизменённый базовый (заведомо красный):

|команда|rc|вывод|
|---|---|---|
|`npm test` (= `jest --ci --runInBand`, `mobile/package.json`)|1|`FAIL …/rehearsal.test.tsx`, `Tests: 2 failed, 1 passed`|
|`npm test -- --testPathIgnorePatterns=rehearsal`|**0**|`PASS …/start-screen.test.tsx`, `Tests: 1 passed, 1 total`|

Файл удалён, `git status --porcelain` клона пуст.

## Находки

БЛОКИРУЕТ contracts/991-complior-repeticiya-p107-p111.md:44,51,69,89 — гарантия «обычный `npm test` в
quality его выполняет» (`:51`) и «прежние проверки не меняются» (`:44`) не предъявляются ни одним
пунктом `:66-77`. `:69` закрепляет только `start-screen.test.tsx` и `start.yaml`, а сами проверки
quality живут в `.github/workflows/mobile.yml` (`jobs.quality`: `npm test`/`lint`/`typecheck`/`doctor`),
который входит в ЗОНА implementer `:89` и правится в этом PR по необходимости (APK upload, evidence) —
`diff --name-only ⊆ зоне` его пропускает по построению. Это повтор причины Б2(в) круга 1.
ОБХОД: положительный C честно меняет StartScreen, кладёт байт-в-байт фикстуру Jest (`:68` rc 0),
не трогает `start-screen.test.tsx`/`start.yaml` (`:69` rc 0, все пути в зоне), пишет честные
evidence/version-шаги (`:71`/`:72` зелёны) — и попутно заменяет в `jobs.quality` строку
`- run: npm test` на `- run: npm test -- --testPathIgnorePatterns=rehearsal`. quality success,
`gh pr checks` (`:73`) и push-run M (`:77`) зелёны, все пункты выполнены; а rehearsal-Jest на main не
исполняется никогда — живьём выше: с красным StartScreen такая строка даёт rc 0. ЗАЩИЩАЕТ `:98`
(«настоящий Jest … судят действие, результат и reset») и смысл Б2 круга 1 («quality на main
поведение не судит») не сделаны. Тот же класс в зоне — `mobile/scripts/ci-e2e.sh`: `run_flows`
вместо `.maestro` запускает только `.maestro/rehearsal.yaml` (прежний start-flow выпадает) либо
повтор по assertion `:14` [INFERENCE: чтением `ci-e2e.sh:67-84`, не исполнено — станции нет].
ВЫХОД (совет формы): (1) поведенческий пункт приёмки — reviewer берёт лог quality-job положительного
run и push-run M (`gh run view RUN --repo a3ka/Complior-mob --job QUALITY_JOB --log`) и требует
строку `PASS src/features/start/__tests__/rehearsal.test.tsx` и итог `Tests:` с числом тестов ≥ числа
базы + 2; парный негатив — показанная выше строка с `--testPathIgnorePatterns` → отказ
`REHEARSAL_JEST_NOT_RUN`. Этот пункт ловит любой путь ослабления (workflow, package.json, jest-конфиг).
(2) структурный — `jobs.quality` в B и C равны (quality в этом предмете меняться не обязан),
например `diff <(git -C R show B:.github/workflows/mobile.yml | yq -o=json '.jobs.quality') <(… C …)`
rc 0 → иначе `EXISTING_CHECK_CHANGED`; и для `ci-e2e.sh` — либо `diff --exit-code B C`, если evidence-проверка
выносится в новый файл `mobile/scripts/`, либо названная неизменность `run_flows` (каталог `.maestro`)
и ветки повтора.

СОВЕТ contracts/991-complior-repeticiya-p107-p111.md:71-72 — replay судит `run`-тело, а YAML-атрибуты
шага вне тела не названы: честное тело с `continue-on-error: true` даёт rc≠0 на всех копиях `:71`, а
job остаётся зелёным при настоящем отсутствии PNG. «Обязательный вызов» `:72` и «несовпадение — отказ»
`:30` это покрывают по смыслу, но reviewer'у стоит назвать запрет `continue-on-error`/`if:` на этих
шагах явной строкой.

СОВЕТ contracts/991-complior-repeticiya-p107-p111.md:87,89 — ЗОНА implementer объявлена путями
Complior-mob, но dev-harness `scripts/check_zones.sh` прочтёт её из блоба заморозки 991 как пути
dev-harness и объединит с зонами implementer из других контрактов (`check_zones.sh:31`, `:930`):
implementer получит в dev-harness право на `.github/workflows/mobile.yml`, `mobile/scripts/` и т.п.
Сейчас таких путей в dev-harness нет и вреда нет; оговорка `:87` механизм не видит.

СОВЕТ contracts/991-complior-repeticiya-p107-p111.md:69 — сверка `diff --name-only B C` ⊆ зоне
остаётся cognitive-only; одна команда (`git -C R diff --name-only B C | grep -vxE '<регексп из :89>'`
→ пусто ⇔ rc 1) сделала бы её механической уже сейчас.

Советы круга 1 закрыты: `.probe-only:2` (путь), `:41`/`:43`/`:57`/`:87` (исполнители двух ранних PR —
implementer, оркестратор — материализация; отрицательный PR несёт ровно APK-upload), `:93`
(`РАБОТА НЕ РАЗДАЁТСЯ:` снята, исключения прозой), `:120-123` (грамматика), `:116` (`MATRIX` латиницей).
`:22` «остальные элементы StartScreen» остался на PNG владельца, как и было.

## Итог

Оба блокера круга 1 по названным обходам закрыты той причиной, что я назвал: evidence/version-проверка
теперь предъявляется красной против моих же обманок, байты Jest закреплены с парным негативом,
зона implementer объявлена с названным ловцом. Остаётся одна блокирующая находка — тот же корень Б2(в):
неизменность существующих проверок закреплена только для двух файлов, а quality-job и ci-e2e.sh лежат
внутри зоны, и подмена `npm test` проходит все пункты (предъявлено живьём). Закрывается одним пунктом
приёмки. Гейты rc 0, ceilings rc 0. Второй FAIL по той же причине — созван арбитр (строка АРБИТР выше).
