FAIL
OBJECT=dfeb1cb0bdc15c4df1c79295612e5afa620cf87e

# Критик 107 — один круг до заморозки

Предмет — закоммиченный `contracts/107-cmp-mob-003-erstinformation.md` и предъявленные им пробы на OBJECT. Набор артефактов полный: предмет, исполняемый критерий, исполнители и ЗОНА-строки есть. Checkout OBJECT выполнен в собственном клоне. Сверены роль критика, AGENTS.md, issue a3ka/Complior-mob#7, источники UX на B=76ac10fa и уроки 999. Это суд критерия, не ревью ещё не существующей реализации C.

Все собственные материалы — `/tmp/dev-harness-verify/Critic107/`. Контракт, пробы и модель в клоне h не исправлялись. Мутации временно устанавливались только в собственной disposable-копии mob и восстанавливались. В основной репозиторий не писал; коммита и push нет согласно заданию.

## Блокирующие находки — по осям, не по очередному единичному примеру

### Б1. CURRENT_CONFIRMED × доказательство × точное совпадение × admission

БЛОКИРУЕТ contracts/107-cmp-mob-003-erstinformation.md:41 — инвариант требует совпадения версии И наличия evidence, но К1 (:53) всегда подаёт валидное доказательство вместе с CURRENT_CONFIRMED. Независимая ось наличия/пригодности evidence отсутствует. Два значения версии проверяют только `payload < required`, а не заявленное равенство.

ОБХОД: само дерево B с временно установленными MODEL_FILES из OBJECT, без каких-либо исправлений модели. `effective` в `model/features.onboarding.erstinformation.tsx:59–66` зависит только от метки состояния и сравнения `<`; компонент показывает `erstinfo-evidence` при `delivery_evidence_ref=null`, пустом evidence_ref, пустом checked_at, другом required_document_id, applicability=UNKNOWN и даже payload.version=2 при required.version=1. Ни настоящего доказательства, ни точного совпадения для такого показа нет. Обе штатные пробы без `--model` возвращают rc=0, как и исходные матрицы. Независимый RNTL-свидетель на этой же модели возвращает rc=1: красны все 12 клеток `evidence {W0,W1A} × {evidence_null,evidence_empty,checked_at_empty,wrong_document,applicability_unknown,version_not_equal_future_payload}`. Сырой вывод показывает реально отрендеренный evidence-View, включая пустые Text-поля, а не ошибку импорта.

В строгом минимуме для отказа достаточно `CURRENT_CONFIRMED × EQ × evidence_ref=null` в обоих admission: этот вход разрешён объявленным типом `string | null` и прямо противоречит :41. Несовпадение документа/UNKNOWN дополнительно показывает неполноту переноса `erstinformation_route.evidence_rule` и fallback; новые серверные endpoint здесь не требуются.

Доказательства: `reference-{erstinfo_static_probe,erstinfo_probe}.log`, `reference-witness.log`, `summary.json`; воспроизведение — `python3 /tmp/dev-harness-verify/Critic107/measure.py`.

### Б2. Полное произведение delivery_states × versions × admissions и побочные эффекты действий

БЛОКИРУЕТ contracts/107-cmp-mob-003-erstinformation.md:56 — К4 проверяет W1A только на готовом CURRENT_CONFIRMED_EQ, а W0 только отдельным примером; К1 не перемножен с admission. К2 (:54) наблюдает не все запрещённые эффекты после действий. Поэтому :44 о недопуске и отсутствии автоматического продолжения слабее своего исполняемого критерия.

ОБХОД: вариант `admission-all-states` в `measure.py` заменяет единственное условие видимости continue на `admission === 'W1A'`. Обе штатные пробы и обе `--matrix` дают rc=0. Независимый свидетель произведения из 20 клеток даёт rc=1, красны ровно девять запрещённых клеток W1A: CHECKING/PENDING/FAILED/OUTDATED × EQ/STALE и CURRENT_CONFIRMED_STALE. Continue реально присутствует там, где бизнес-шаг должен быть закрыт. На исходной модели все 20 клеток зелёные в положительном контроле.

ОБХОД: вариант `navigation-side-effects` добавляет `onContinue?.()` при открытии документа и `if (!versionStale) onContinue?.()` при подтверждении. Штатные пробы и обе матрицы снова rc=0. Независимый свидетель `{open,ack} × {W0,W1A} × {EQ,STALE}` даёт rc=1: шесть красных клеток из восьми — open в четырёх клетках и ack_EQ в обеих волнах. Это не нажатие Continue: документ открывается/ack отправляется, но вместе с этим исполняется бизнес-переход, в том числе в W0 и при открытии старого документа. Исходная модель проходит все восемь клеток.

Положительный контроль групп admission/actions/mock: `controls.py` → rc=0, `total=39 failed=0`. Контрпримеры не меняют тесты, testID, конфигурацию Jest или окружение субъекта.

Доказательства: `admission-all-states-*.log`, `navigation-side-effects-*.log`, `controls-witness.log`; точные побайтовые замены — в `measure.py`.

### Б3. Время появления новой версии: до ack / во время незавершённого ack

БЛОКИРУЕТ contracts/107-cmp-mob-003-erstinformation.md:54 — `ACK_STALE_NO_CONTINUE` начинается УЖЕ со stale snapshot и синхронным callback-счётчиком. Это не критерий issue #7 «ack версии N после появления N+1 … после ack перечитать текущее evidence». Порт (:49) и критерий не наблюдают завершение Promise операции из ApiClient (:39).

ОБХОД: та же немодифицированная модель с зелёными штатными пробами. Смонтировать текущую версию 2, нажать confirm, оставить ответ onAcknowledge незавершённым, подать новый gate с required.version=3, затем завершить ack результатом `{accepted:false, version:2, evidence_ref:null}`. Модель решает `if (versionStale)` в старом синхронном обработчике и ни после смены gate, ни после завершения ack не перечитывает evidence. Независимые клетки `transition ack_version_changes W0/W1A` красны, rc свидетеля=1: `Expected number of calls: 1; Received number of calls: 0`. Статическая и поведенческая штатные пробы на этом дереве — rc=0. Дополнительно красны обе клетки `action ack_rechecks {W0,W1A} EQ`: обычный успешный current-ack тоже не инициирует перечитывание, хотя issue требует его после ack.

Наличие заранее stale-примера не закрывает временную ось. Положительный контроль уже существующего stale-пути в независимом прогоне зелёный: `action ack_rechecks W0 STALE` и `W1A STALE`. Требуется определить владельца и наблюдение асинхронного результата/recheck на публичном шве, а не переименовать синхронный пример.

Доказательства: `reference-witness.log` (именные отказы и фактическое число вызовов), `reference-erstinfo_probe.log`, `reference-erstinfo_static_probe.log`; сценарий с управляемым Promise — в `witness.test.tsx`.

### Б4. Реальный ApiClient/mock и его сценарии, а не текст интерфейса и локальные счётчики

БЛОКИРУЕТ contracts/107-cmp-mob-003-erstinformation.md:49 — предмет требует расширенного mock ApiClient и сценариев состояний × версий, но статическая семья (:57) ищет подстроки, а RNTL подставляет собственные callback-счётчики (`erstinfo.test.tsx:67–90`). Реальные методы новой части ApiClient вообще не исполняются при приёмке.

ОБХОД: вариант `runtime-unimplemented` оставляет все объявления интерфейса и имена свойств runtime, но `acknowledgeDisclosure` возвращает rejected Promise `ACK_NOT_IMPLEMENTED`, а `getDisclosureGate` бросает `GATE_NOT_IMPLEMENTED`. Обе обычные пробы и обе `--matrix` дают rc=0. Независимый тест импортирует НАСТОЯЩИЙ `@/mocks/runtime`, без mock-подмены его методов: на исходной модели rc=0, обе клетки passed; на обходе rc=1, обе клетки failed с указанными исключениями. Пользовательский ack и получение gate отсутствуют, а предъявленный критерий принимает дерево.

ОБХОД: вариант `mock-constant-no-ack` оставляет `gateFor`, CURRENT_CONFIRMED и имена runtime-свойств в тексте, но возвращает только CURRENT_CONFIRMED с required.version=2 независимо от аргументов и не записывает ack. Обе обычные пробы и обе матрицы rc=0. Независимый прогон mock даёт rc=1: девять неверных клеток состояний × версий и отдельный отказ записи подтверждённой версии; исходная модель проходит все 11 клеток. Для блокирования достаточно отсутствия девяти объявленных сценариев, независимо от выбора способа хранения ack.

Доказательства: `runtime-reference-witness.log`, `runtime-unimplemented-*.log`, `mock-constant-no-ack-*.log`; точный воспроизводитель — `measure-api.py`, отдельный настоящий runtime-свидетель — `api-witness.test.tsx`.

## Перечень осей против первичного источника

Хэши всех семи исходников из source.json совпали с B по независимому `source-check.py` (rc=0). Проблема не в подменённом snapshot, а в его сужении при переносе в критерий.

| Ось / переход | Что предъявлено | Суд этого круга |
|---|---|---|
| Пять экранных состояний × EQ/STALE | К1 действительно исполняет десять отображений | Базовое красное/зелёное подтверждено; не заменяет следующие оси |
| Те же состояния × обе admission | W1A проверен только на CURRENT_CONFIRMED_EQ | Доказанный обход Б2 |
| CURRENT_CONFIRMED × evidence отсутствует/непригодно × версии не равны | В тестовых входах состояние и валидное evidence связаны | Доказанный обход Б1 |
| open/ack/continue × волна × версия | Эффекты наблюдаются выборочно | Доказанный обход Б2 |
| EQ → STALE во время ack; успешный current-ack → recheck | Только заранее stale-снимок и синхронный счётчик | Доказанный обход Б3 |
| Реальные операции ApiClient и mock-сценарии | Поиск строк + callbacks из теста | Доказанные обходы Б4 |
| Snapshot absent; UNKNOWN/MISSING; applicability REQUIRED/NOT_REQUIRED/UNKNOWN | Грамматика взята только из `screen_flow.F02.08.states` | Совет С3: определить преобразование/fallback на композиции; не выдавать полноту display-состояний за полноту gate |
| Офлайн/ошибка API, повторная выдача, unknown outcome/reconcile, revoked/replay | Нет поведенческих клеток композиции; trace отложен | Совет С3: не снимать клиентскую часть требований ссылкой на будущий backend |
| Смена версии во время чтения | Только фиксированный payload=2 до открытия | Совет С4 с измеренным наблюдением |
| Dark/Light, Accessibility, reduced motion, доступный viewer | Нового произведения этих режимов нет; предусмотрено увеличение текста в будущем Maestro | Совет С4; нативной зелени не заявляю, требования всего 999 заново не открываю |
| Нативная доставка/реальная выдача backend | Maestro до C — NOT_RUN; backend evidence отдельно | Честная граница, не самостоятельный блокер |

## Советы — не дополнительные условия FAIL

СОВЕТ contracts/107-cmp-mob-003-erstinformation.md:86 — зона недостаточна для явно названной интеграции без дополнительного решения. В :124 разрешение «существующих app-маршрутов» не подкреплено ЗОНА: весь `mobile/src/app/` отсутствует и для новых, и для существующих файлов. На B `app/index.tsx` экспортирует PilotApp, а `(tabs)/[section].tsx` ведёт таб-shell; путь/параметры входа в Erstinformation и владелец композиции с ApiClient не зафиксированы. Кроме того, расширение обязательного `ApiClient` затрагивает существующий `mobile/src/bootstrap/http-runtime.ts:64` с объектом только из getSession/getDisclosure; этот потребитель тоже вне зоны. Назвать точные композиционные/совместимые пути и владельца, не расширять зону устно. Это инженерное затруднение, но обход полного критерия, включая CI/native, на нём не предъявлен, поэтому не дополнительный блокер. Внутри 107 зоны разных ролей не пересекаются; ПЕРЕСЕЧЕНИЕ-строк нет, доказанного необходимого пересечения именно этих ролей тоже нет. Precision-гейт зелёный не доказывает достаточность зоны для интеграции.

СОВЕТ contracts/107-cmp-mob-003-erstinformation.md:66 — матрицы не испытывают реализацию C: `erstinfo_probe.py:87,146` и `erstinfo_static_probe.py:62,103` берут `model_bytes()`, временно замещая файлы продукта эталоном. Поэтому даже `--matrix` на совершенно отсутствующем предмете B имеет rc=0; это честно воспроизведено. Уточнить смысл команды как самопроверки набора проб/модели, не свидетельства честности C. Отдельно не блокирует: обычные пробы C всё же предусмотрены; конкретные их обходы перечислены выше.

СОВЕТ contracts/107-cmp-mob-003-erstinformation.md:51 — source.json не содержит полную грамматику `erstinformation_route`: исходные delivery_values включают MISSING и UNKNOWN, applicability имеет три значения, snapshot_required несёт actor/subject/scope/policy и другие поля. `screen_flow.F02.08.states` — другой, экранный перечень. Канон также требует `resume_rechecks_gate=true`, `on_unknown=stay_and_reconcile`, повторного использования пригодного evidence и сохранения intent при outage. Назвать отображение серверных состояний в экранные, владельца проверки snapshot и клиентскую семантику unknown/retry/replay. Обычный отсутствующий snapshot на модели дал TypeError в обеих волнах; это НЕ доказательство открытия home и не самостоятельный блокер. Передача требований настоящей серверной доставки CMP-BCK-008/024 допустима, но не доказывает выполненную клиентскую часть. Копии STATES/AXES/TEXTS в TS вручную дублируют source.json; статическая проба не сверяет заявленную в :98 единственность DeliveryState/Applicability/Admission. Это совет о границе и механизме, а не требование пересчитать все произведения без отношения к предмету.

СОВЕТ contracts/107-cmp-mob-003-erstinformation.md:55 — указать поведение exact-version viewer при обновлении payload во время чтения. Измерено: open версии 2 → rerender с payload/gate версии 3 меняет надпись на Version 3 без нового onOpenDocument; независимые `document_pins_version W0/W1A` красны. Свидетель требует сохранённую версию 2, тогда как канон также допускает/требует возврат F02.03 при смене версии; поэтому этот частный oracle НЕ используется как блокер. В модели F02.05 содержит метаданные/инструкцию, а не доказательство чтения содержимого документа. На C нужно увидеть доступный viewer и font scaling на реальном маршруте. Отсутствие в 107 отдельных dark/light/reduced-motion клеток не превращаю автоматически в невыполненное требование issue; обязательный native-сценарий с увеличением текста до C остаётся NOT_RUN.

СОВЕТ contracts/107-cmp-mob-003-erstinformation.md:123 — источник F02.V02/F02.V04 достижим без владельца: `docs/ux/01_UX_Source_of_Truth/BrokerOS_Mobile_Design_Data.json:860–880` содержит variants с document_version/accepted_at и delivered/accepted_at; развёрнутые datasets — :1037 и :1097. Сослаться на них вместо вопроса «где живут правила». Copy-разрыв :122 может оставаться явно обозначенным PRODUCT_COPY_REVIEW_REQUIRED/CMP-MOB-089: семантика ack проверяется отдельно, signoff не заявлен. Не выдавать временное `acknowledge` за разрешённую production-copy. Ни этот вопрос, ни найденный путь V-правил сами по себе не блокируют заморозку.

СОВЕТ contracts/107-cmp-mob-003-erstinformation.md:73 — H-пин и quality-подключение описаны достаточно для раздачи, но при реализации нужны полный SHA нового checkout и исполнение именно его проб; старые шаги 995/999 не переписывать под код. В существующем mobile.yml H ещё относится к 999; это ожидаемое B, не дефект 107. Отложенный Maestro :68/:116 оформлен честно; на C предъявить фактический прогон нового flow, а не один `gh pr checks`. Настоящие cold-start/openLink, системные настройки и font scaling RNTL не доказывает. Полный CI, native и frozen-пробы 995/999 на будущем C в этом круге не запускались.

## Формальные двери, Н-39 и пять вопросов роли

- Критерий слабее предмета: четыре группы воспроизведённых обходов выше. Перечень построен по состояниям, волнам, доказательству, времени и исполнению API, а не по одному следующему декою.
- Команды названы и исполняются; недостаточность — в наблюдаемой семантике. Будущий `gh pr checks`/Maestro не объявляется уже зелёным.
- Решения, оставленные исполнителю: композиция/route, завершение async ack и ownership recheck, преобразование полной gate-грамматики. Последствия разделены на доказанные блокеры и советы.
- Исполнители названы. ЗОНА-грамматика принята precision-гейтом; достаточность продуктовой зоны — С1. Один автор на всё дерево не назначен.
- Норма AGENTS.md о красном кодовом критерии применена исполнением. Самостоятельного нормативного отказа сверх доказанных обходов не заявляю. Контракт НЕ утверждает конкретные пары «имя обманного стаба ↔ ветвь»: такие пары находятся в коде MUTANTS, как требует Н-39.
- `bash scripts/check_precision_gate.sh <h> contracts/107-cmp-mob-003-erstinformation.md` → rc=0, `OK`.
- `bash scripts/check_threat_model.sh <h> contracts/107-cmp-mob-003-erstinformation.md` → rc=0, секция валидна: ЗАЩИЩАЕТ 7, НЕ ЗАЩИЩАЕТ 4 буллета. Это форма, не доказательство заявленных защит.
- `bash scripts/check_provodka.sh <h> contracts/107-cmp-mob-003-erstinformation.md` → rc=0. Строка role-канала дословно существует в `roles/orchestrator.md:391`. ПРОВОДКА-ЭНФОРСМЕНТ обосновывает потребление действующей нормы закрытия, а не притворяется новым guard; нового поведения роли не вводится.
- Предъявленный pre_critic rc=0 не использовался вместо предметных прогонов и повторно не запускался. Новый обычный круг этим вердиктом не назначается; повтор причины/спора с автором в рамках этого задания не было, оснований самовольно созывать арбитра нет.

## Сырые команды и результаты

Корни: `H=/tmp/dev-harness-verify/Critic107/h`, `R=/tmp/dev-harness-verify/Critic107/mob`. Переменные ниже — сокращение полных путей, не ссылки на чужой workspace.

```text
git clone ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/Critic107/h
git -C /tmp/dev-harness-verify/Critic107/h checkout dfeb1cb0bdc15c4df1c79295612e5afa620cf87e
rc=0; HEAD is now at dfeb1cb0

git clone ssh://git@github.com/a3ka/Complior-mob.git /tmp/dev-harness-verify/Critic107/mob
git -C /tmp/dev-harness-verify/Critic107/mob checkout 76ac10fa
rc=0; HEAD is now at 76ac10f

# cwd=R/mobile
npm ci --cache /tmp/dev-harness-verify/Critic107/npm-cache
rc=0; added 1100 packages in 8s

gh issue view 7 -R a3ka/Complior-mob --json body --jq .body
rc=0

python3 /tmp/dev-harness-verify/Critic107/baseline.py
rc=0
B/erstinfo_static_probe: rc=1 ERSTINFO_MODULE_ABSENT
B/erstinfo_probe: rc=1 ERSTINFO_COMPONENT_ABSENT
model/erstinfo_static_probe: rc=0 static 20/20
model/erstinfo_probe: rc=0 honest 25/25
matrix/erstinfo_static_probe: rc=0 mutants 4, defects 0
matrix/erstinfo_probe: rc=0 mutants 13, defects 0

python3 /tmp/dev-harness-verify/Critic107/measure.py
rc=0
reference: static=0, behavioral=0; witness rc=1, 20 failed / 41 passed / 61 total
admission-all-states: static=0, behavioral=0, static-matrix=0, behavioral-matrix=0
  witness rc=1, 9 failed / 20 total
navigation-side-effects: static=0, behavioral=0, static-matrix=0, behavioral-matrix=0
  witness rc=1, 6 failed / 8 total
mock-constant-no-ack: static=0, behavioral=0, static-matrix=0, behavioral-matrix=0
  witness rc=1, 10 failed / 11 total

python3 /tmp/dev-harness-verify/Critic107/controls.py
rc=0 total=39 failed=0

python3 /tmp/dev-harness-verify/Critic107/measure-api.py
rc=0
runtime-reference witness rc=0; explicit_ack_executes=passed, gate_snapshot_available=passed
runtime-unimplemented: static=0, behavioral=0, static-matrix=0, behavioral-matrix=0
runtime-unimplemented witness rc=1; explicit_ack_executes=failed, gate_snapshot_available=failed

python3 /tmp/dev-harness-verify/Critic107/source-check.py
rc=0; все семь source_sha256 equal=True

# cwd=R, после всех проб
git status --short --untracked-files=all
rc=0; вывод пуст
```

Каждый лог обычной пробы/матрицы содержит полную фактически исполненную команду `python3 H/fixtures/workshop_project/erstinfo_107/<probe>.py --repo R [--model|--matrix]`, сырой вывод и rc. baseline.py, measure.py и measure-api.py последовательно вызывают процессы и сохраняют их реальные rc; rc=0 измерителя означает завершение измерения, а НЕ зелень отрицательного свидетеля. RNTL-свидетели запускаются настоящим `node R/mobile/node_modules/jest/bin/jest.js --ci --runInBand --runTestsByPath <временно установленный test> --json --outputFile <scratch-report>`; stdout/stderr Jest сохранены в `*-witness.log`. Полный список красных клеток сохранён в `summary.json`.

Граница результата: доказаны обходы предъявленных предметных проб на моделях/мутантах в собственной копии. Не утверждается, что эти модели — компилируемая завершённая поставка C или что они прошли ещё не существующий PR/native CI. Ни Android, ни визуальный рендер, ни реальная HTTP-доставка в этом круге не проверялись. Это не основание принимать слабый pre-freeze критерий: названный native-сценарий чтения/увеличения/возврата не наблюдает доказанные ложное evidence, запрещённые W1A-переходы, async recheck и отсутствующие ack/gate-операции.
