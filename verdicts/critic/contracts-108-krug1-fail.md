FAIL
OBJECT=9b372704440a61bda3c7f9c3b15b66e4c07f399d

# Critic108 — контракт 108, круг 1

Предмет: `contracts/108-cmp-mob-004-start.md` и `fixtures/workshop_project/start_108/` на указанном HEAD. Набор полный: предмет, команды приёмки, исполнители и зоны названы. Рассмотрен контракт, не будущая реализация C. Контракт и пробы не исправлял; основной чекаут не открывал, commit/push не выполнял.

**Итог:** авторские числа воспроизведены, но они не доказывают объявленные инварианты. Найдено **15 проходящих обманных реализаций по 9 осям**: на каждой обычные пробы OBJECT дают **static 21/21 rc=0 и honest 101/101 rc=0**, независимый свидетель — **rc=1** по предметному assertion. Контроль свидетелей на немутированной модели зелёный. Матрицы OBJECT: 18+4 мутанта, defects 0, rc=0; это самопроверка на авторской модели, не опровержение новых обходов.

## Проверенные источники и граница вывода

- Issue `a3ka/Complior-mob#8` прочитан живой командой `gh issue view 8 --repo a3ka/Complior-mob --json body --jq .body`, rc=0; полный вывод — `evidence/issue.log`.
- B клонирован **по SSH** и установлен на `76ac10fac668a1036371c4b392061ce9b3277ebc`; fallback-копия не потребовалась. `npm ci --cache /tmp/dev-harness-verify/Critic108/npm-cache` завершился rc=0.
- На B сверены design data `features/F04` (:1573–1866), screen matrix `CS01` и F04.01–F04.07, consumer bindings F04.A01/A02/A03 (:402–516), OpenAPI `listMissions` (:910–919), `MissionSnapshot.state` (:28362–28375), каталог copy. Navigation не даёт authoritative effect; listMissions фильтруется ACL; десять MissionState действительно замкнуты.
- **Все 8 sha256 в source.json совпали с git-блобами B**, все **13 text/review_status** совпали с каталогом. Проверял именно блобы B, не временно наложенную модель. Полные digest/команды/rc: `evidence/source-audit.log`.
- Независимо построенное множество имён клеток из source.json: **101 ожидаемая, 101 наблюдённая, missing=[], extra=[]**. Арифметика: 12+13+36+9+3+25+3=101. Число мутантов пересчитано через Python AST словарей MUTANTS: 18 и 4. Проблема не в арифметике, а в проекции осей: UI-state, admission=null и mission state не входят в произведение действий; переходы и данные наблюдаются отдельно и не полностью.
- Живой Android/Maestro, полный lint/typecheck/test продукта, PR checks и реальный HTTP **не запускались**: C отсутствует. Не утверждаю, что мутанты прошли эти отложенные двери. Ниже доказана недостаточность предъявленных до заморозки красных проб; маршруты F05/F06/F09 и бэкенд не расширяю.

## Все найденные оси обхода — единый список

В каждой строке ниже пути логов относительны `/tmp/dev-harness-verify/Critic108/`. Полные команды, stdout/stderr и rc сохранены дословно в `evidence/<имя>-static.log`, `evidence/<имя>-behavior.log`, `evidence/witness-<имя>.log`. Патчи — `evidence/*.patch` и точные замены в `experiment.py`, `witnesses.py`, `transition.py`. Общий результат всех перечисленных обходов: **static rc=0; behavior rc=0; witness rc=1**.

### 1. Независимость оракула полного снимка

БЛОКИРУЕТ contracts/108-cmp-mob-004-start.md:54,56,63 — заявленный оракул source.json фактически подменён экспортами субъекта. `start.test.tsx:22,43` импортирует MISSION_ID/UPDATED_AT из `@/mocks/start-mock` и использует их и для входа, и для ожидаемого снимка; сам mock конструирует ответ через те же константы. Полное `toEqual` при таком происхождении expected не независимо.

ОБХОД: `oracle-imported-constants` меняет в продукте MISSION_ID на `MIS-WRONG-99`, UPDATED_AT на `1999-01-01T00:00:00Z`, не меняя source.json/тесты. Обе пробы rc=0, 101/101 сохранены; свидетель с каноническими литералами получает оба неверных поля, rc=1. Нарушается также AGENTS.md, правило 8: истина проверяющего взята у проверяемого. Это не требование ещё одного runtime-сценария, а дефект самого сравнения.

### 2. Экранное состояние × admission × состояние дела × действие × полный вектор эффектов

БЛОКИРУЕТ contracts/108-cmp-mob-004-start.md:46,60–61,64 — «полный вектор» измерен лишь для первого действия из CALM с missions=[] либо WORKING. FRAME_LISTENING проверяет mic до выхода write, но не после; MISSIONS_NULL вообще не нажимает действия. BRIEF_STATE проверяет state отдельно от действий и reduced motion.

ОБХОД: четыре независимые реализации проходят обе пробы rc=0:
- `write-after-listening-mic`: write из LISTENING вызывает свой onWrite **и onMicrophoneRequested**. Свидетель talk→write: `{write:1,talk:1,resume:[],mic:1}` вместо mic=0, rc=1.
- `focus-then-talk-mic`: talk запрашивает микрофон только из INPUT. Свидетель focus→talk, rc=1.
- `null-talk-mic`: talk запрашивает микрофон только при missions=null. Свидетель null→talk, rc=1.
- `blocked-reduced-resume`: resume при state=BLOCKED и reducedMotion=true передаёт `MIS-WRONG-99`. Оба значения уже объявлены контрактом; независимый полный вектор с ожидаемым MIS-CAR-01 красен, rc=1.

Это одна ось замыкания произведения, а не четыре отдельных новых требования. Порядок событий важен: snapshot счётчиков до последнего действия не доказывает отсутствие эффекта после него.

### 3. ACL/fallback и обновление снимка — переходы, не только начальный render

БЛОКИРУЕТ contracts/108-cmp-mob-004-start.md:43,45,59,64 — PRESENT→EMPTY проверен только в CALM; null — только при первом render; смена данных при прежней PRESENT-кардинальности не наблюдается.

ОБХОД: три реализации проходят обе пробы rc=0:
- `listening-revoked-acl`: сохраняет последнее непустое missions в useRef, пока UI=LISTENING. talk→missions=[] оставляет старый mission_id и доступный resume. Свидетель rc=1.
- `null-transition-stale`: при missions=null использует последний успешный массив вместо безопасного отсутствия brief/resume. Начальный null остаётся честным, поэтому К8 зелёный; PRESENT→null сохраняет приватную карточку. Свидетель rc=1.
- `same-presence-stale-snapshot`: `useMemo(() => missions ?? [], [missions?.length])` удерживает старый снимок при WORKING→BLOCKED той же Mission. Число элементов не меняется; все статические BRIEF_STATE зелёные, живой переход отображает WORKING вместо BLOCKED. Свидетель rc=1.

Fallback здесь исследован в объявленном домене: отсутствует весь снимок (`null`). Не навязываю политику для произвольных невалидных объектов, которых нет в типе MissionBrief.

### 4. Присутствие и запрещённые элементы после смены UI-state

БЛОКИРУЕТ contracts/108-cmp-mob-004-start.md:44,48,58,61 — К1 наблюдает структуру только до взаимодействия. К4 наблюдает тексты и brief, но не присутствие/запрещённые элементы; К3 после talk проверяет voice-session, но не KPI/empty-groups.

ОБХОД: `listening-presence-gone` убирает AgentPresence при LISTENING; `listening-kpi-groups` после talk показывает KPI dashboard и пустые группы с теми же testID, которые запрещает К1. Каждый: обе пробы rc=0, независимое наблюдение поверхности после talk rc=1. Не использованы переименование testID или test-env: это обычное состояние экрана из контракта.

### 5. Зависимость полей brief от переданного снимка

БЛОКИРУЕТ contracts/108-cmp-mob-004-start.md:45,59,63 — утверждение «бриф показывает mission_id, state, updated_at» не доказано одной фиксированной парой строк. Наличие на экране ожидаемой константы не доказывает чтение переданного поля.

ОБХОД: `brief-hardcoded-fields` заменяет чтение mission_id и updated_at литералами MIS-CAR-01 / 2026-10-09T12:00:00Z, оставляя state и resume корректными. Обе пробы rc=0. При разрешённом портом MissionBrief с `MIS-OTHER-02`, `BLOCKED`, `2026-10-19T10:11:12Z` экран показывает чужие id/время; свидетель rc=1. Не требуется перебирать строки или расширять бизнес-правила: конечная различающая пара входов устанавливает зависимость отображения от данных.

### 6. Настоящий runtime × сценарий, не только отдельный mock helper

БЛОКИРУЕТ contracts/108-cmp-mob-004-start.md:50,63 — произведение presence×state исполняет missionsFor, а настоящий runtime проверен только на нескольких сценариях. Полный снимок runtime→экран проверен лишь для WORKING.

ОБХОД: `runtime-blocked-normalized` в настоящем runtime.api.listMissions заменяет BLOCKED на WORKING; missionsFor и сценарный setter не меняются. Обе пробы rc=0, несмотря на искажение объявленного сценария на пути к потребителю. Свидетель setScenario(PRESENT,BLOCKED)→runtime.api.listMissions сравнивает полный канонический снимок и возвращает rc=1. Это существующий mock/runtime-шов, не app-композиция или реальный HTTP.

### 7. Черновик × unavailable-переход

БЛОКИРУЕТ contracts/108-cmp-mob-004-start.md:47–48,62 — DRAFT_PRESERVED_AVATAR_CHANGE проверяет только idle→working, хотя сохранение контекста при unavailable явно входит в F04.V03.

ОБХОД: `draft-unavailable-reset` задаёт ConversationComposer key='reset' при unavailable и 'normal' в остальных состояниях. Обе пробы rc=0: все требуемые элементы остаются, idle→working сохраняет черновик. Ввод→unavailable обнуляет текст; независимый свидетель rc=1. Это не новое требование о сохранении между маршрутами.

### 8. Замкнутость wire-enum

БЛОКИРУЕТ contracts/108-cmp-mob-004-start.md:42,65 — STATIC_MISSION_STATE_ENUM проверяет включение десяти значений, не точное равенство множеству; отдельная проверка запрещает только LISTENING.

ОБХОД: `wire-enum-not-closed` добавляет `| 'UNKNOWN'` в MissionState. Обе пробы rc=0, но объявленное «ровно 10» уже неверно. Независимый разбор ровно RHS MissionState выводит 11 значений против канонических 10 и rc=1. Код/тип остаётся синтаксически корректным; это не обход через комментарий или подмену grep.

### 9. Каталог copy ≠ использование copy на поверхности

БЛОКИРУЕТ contracts/108-cmp-mob-004-start.md:36,49,63,65 — наличие frame.F04.06.body в ui-copy.ts не доказывает его отображение. Issue #8, работа 5, прямо требует использовать этот ключ; предмет включает F04.06.

ОБХОД: `brief-body-empty` заменяет выражение `{uiCopyDe['frame.F04.06.body'].text}` в брифе на `{''}`, не меняя каталог. Обе пробы rc=0; на реальном RNTL-дереве виден пустой Text вместо «Sehen Sie den aktuellen Stand und setzen Sie Ihr Anliegen fort.», свидетель rc=1.

Отрицательный контроль: первая попытка `brief-copy-unused` подставляла F04.01.body вместо F04.06.body и была поймана текущими пробами (behavior rc=1: дублирование CALM-текста). **Эта попытка не объявляется обходом**; проходящий обход — именно `brief-body-empty`.

## Сводка измерений

| Дерево / режим | Статика | Поведение | Независимая мера |
|---|---:|---:|---|
| B без предмета | rc=1 START_SEAM_ABSENT | rc=1 START_SEAM_ABSENT | B закреплён полным SHA |
| B + авторская модель | rc=0, 21/21 | rc=0, 101/101 | witness-honest: rc=0, 13/13; transition-honest: rc=0, 1/1 |
| Матрицы OBJECT | rc=0, 4, defects 0 | rc=0, 18, defects 0 | AST: 4 и 18 |
| Каждый из 15 обходов выше | rc=0, 21/21 | rc=0, 101/101 | именованный свидетель rc=1 |
| Источники | 8/8 sha256 | 13/13 copy | source-audit rc=0, case-set 101/101 без разницы |

Формальные двери, живые команды из cwd `/tmp/dev-harness-verify/Critic108/R`:

```text
$ bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic108/R contracts/108-cmp-mob-004-start.md
OK
rc=0
$ bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Critic108/R contracts/108-cmp-mob-004-start.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 11 буллет(ов), НЕ ЗАЩИЩАЕТ 5 буллет(ов))
rc=0
$ bash scripts/check_provodka.sh /tmp/dev-harness-verify/Critic108/R contracts/108-cmp-mob-004-start.md
rc=0
$ bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Critic108/R contracts/108-cmp-mob-004-start.md
```
Последняя команда: rc=0, последняя строка `КРИТИК: дверь зелёная`; **весь** вывод без сокращений — `evidence/pre_critic.log`. Н-39: контракт не привязывает конкретные стабы к ветвям; пары находятся в коде MUTANTS.

Команды воспроизведения проведённых экспериментов (cwd `/tmp/dev-harness-verify/Critic108`):

```text
python3 -B /tmp/dev-harness-verify/Critic108/experiment.py
rc=0
python3 -B /tmp/dev-harness-verify/Critic108/witnesses.py
rc=0
python3 -B /tmp/dev-harness-verify/Critic108/transition.py
rc=0
python3 -B /tmp/dev-harness-verify/Critic108/audit.py
rc=0
python3 -B /tmp/dev-harness-verify/Critic108/inventory.py
rc=0
```

Это rc **сборщиков доказательств**, не итогового гейта: они сохраняют реальные rc вложенных команд, в том числе ожидаемые 1 у свидетелей. Например дословно:

```text
$ python3 /tmp/dev-harness-verify/Critic108/R/fixtures/workshop_project/start_108/start_probe.py --repo /tmp/dev-harness-verify/Critic108/B
```
Для `write-after-listening-mic` эта команда дала `honest 101/101`, rc=0 (`evidence/write-after-listening-mic-behavior.log`, содержит весь перечень).

```text
$ node /tmp/dev-harness-verify/Critic108/B/mobile/node_modules/jest/bin/jest.js --ci --runInBand --runTestsByPath /tmp/dev-harness-verify/Critic108/B/mobile/src/features/start/__tests__/critic108-witness.test.tsx --testNamePattern ^write-after-listening-mic$
```
Дала rc=1: expected mic=0, received mic=1 (`evidence/witness-write-after-listening-mic.log`, полный diff assertion). Та же организация логов у всех остальных обходов, без подмены методов runtime.

После экспериментов `git status --short --untracked-files=all` в обоих клонах дал пустой вывод, rc=0 (`evidence/R-restoration.log`, `evidence/B-restoration.log`). HEAD клона H — OBJECT, HEAD B — полный SHA выше. Мутации восстановлены; доказательства остались только под Critic108.

## Ответы на пять вопросов гейта

1. Критерий слабее предмета: **да**, девять осей и исполнимые обходы перечислены выше.
2. Недоказуемые пункты: главная проблема — не отсутствие команд, а ложное зелёное этих команд. Отложенные Maestro/PR проверки явно названы и не выдаются мной за выполненные.
3. Решения исполнителю: выбор элемента при нескольких доступных Mission и правила композиции экранов назначения не определены детально; без доказанного обхода это совет ниже, не дополнительный блокер.
4. Исполнители/границы: architect, implementer, critic/adversary/reviewer названы; нужные пути Start, UI, mocks, API, app, tab-shell/http-runtime, workflow, Maestro покрыты зонами. Конкретного файла необходимой правки вне зон не установлено.
5. AGENTS.md: независимость истины нарушена пунктом 1; численные утверждения перепроверены другой мерой; угрозы/precision/проводка формально зелёные. Н-39 не нарушен.

## Неблокирующие советы и конечная граница исправления

СОВЕТ contracts/108-cmp-mob-004-start.md:56–65 — исправлять не пятнадцать частных условий, а грамматику наблюдений: UI-state × avatar × motion × admission (включая null и declared mission states), действия с полным вектором **после каждого шага**, явно объявленные переходы ACL/недоступности/обновления снимка, настоящий runtime по сценариям; expected брать из независимого source.json. Присутствие, запрещённые элементы, текст брифа и черновик проверять на достигнутом состоянии. Это рекомендация формы закрытия найденных классов; новый произвольный state space и дополнительные бизнес-функции не требуются.

СОВЕТ contracts/108-cmp-mob-004-start.md:45 — при нескольких доступных items не названо правило выбора одного brief. Уточнить при реализации; имеющиеся обходы не зависят от такого выбора.

СОВЕТ contracts/108-cmp-mob-004-start.md:138–140 — F04.04/F04.05 вне среза, трактовка terminal Mission и немецкий unavailable-copy остаются вопросами владельца, как указано в задании. Они **не использованы для FAIL**. Визуальная доля Presence 55–65%, реальный HTTP, W2 voice runtime, copy signoff и device evidence также не превращены в новые блокеры.

Область следующего исправления конечна: устранить перечисленные девять разрывов доказательства, сохранить зелёный честный контроль и именованный красный B. Не требуется повторять спор 107 о бесконечном наращивании поштучных мутантов; здесь все блокеры привязаны к собственным инвариантам 108 и измерены в его публичных швах.
