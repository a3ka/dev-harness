FAIL
OBJECT=a4520d9b626457259673bbbe7679051331384596

# Critic107r2 — контракт 107, круг 2

Предмет: закоммиченные `contracts/107-cmp-mob-003-erstinformation.md` и `fixtures/workshop_project/erstinfo_107/` на OBJECT. Клон получен по SSH из GitHub, затем checkout OBJECT; собственный Complior-mob закреплён на B=`76ac10fa`. Набор полный: предмет, команды готовности, исполнители, границы и ЗОНА-строки присутствуют.

**Итог: четыре оси обхода остаются.** Исправление круга 1 действительно улучшило критерий, но не закрыло классы дефектов. Построены НОВЫЕ мутации и входы, не повторяющие обходы первого круга. Совместное дерево с четырьмя новыми дефектами проходит обе обычные пробы, обе матрицы и оба унаследованных свидетеля, но собственный поведенческий свидетель красен: 9 из 13 исполненных клеток. Отдельно воспроизведён пропуск recheck при rejected Promise.

Все пути материалов ниже относительны `/tmp/dev-harness-verify/Critic107r2/`. Контракт/пробы/модель в h не исправлялись; изменения продукта устанавливались и восстанавливались только в собственной disposable-копии mob. Основной чекаут не использовался, commit/push не выполнялись согласно ограничению задания. Этот файл — запрошенный результат, не заявление о закоммиченном вердикте заморозки.

## Независимые положительные и отрицательные контроли

| Контроль | Наблюдение |
|---|---|
| B без предмета | static rc=1 `ERSTINFO_MODULE_ABSENT`; behavioral rc=1 `ERSTINFO_COMPONENT_ABSENT` |
| Авторская модель, обычные пробы | static rc=0, 22/22; behavioral rc=0, 95/95 |
| Обе авторские матрицы | rc=0; 18 и 4 мутанта, defects=0 |
| Другая мера количества | прямой Jest с сохранённым JSON: 95 passed, 95 уникальных имён; AST-обход Python находит 18 и 4 ключа MUTANTS независимо от печати матриц |
| Свидетели круга 1 на модели | собственный запуск: rc=0, 61/61 и 2/2 |
| Новые позитивные свидетели на неизменённой модели | rc=0, 14/14: комбинации evidence, retry, порядок ack/recheck, двойной ack с обратным порядком завершения; отдельная композиция runtime→экран rc=0, 1/1 |
| Совместный НОВЫЙ обход | обе обычные пробы rc=0 (22/22 и 95/95), обе матрицы rc=0, свидетели круга 1 rc=0 (61/61 и 2/2); собственный свидетель rc=1, 9 failed / 4 passed |

`--matrix` действительно замещает субъект моделью: её зелень — самопроверка проб, не контрдоказательство обхода. Это теперь честно написано в контракте :73. Старые свидетели прогнаны только как дополнительная строка приёмки :74, а не вместо новых входов.

## Блокирующие находки

### Б1 — независимые поля evidence: одиночный дефект / совместное отсутствие

БЛОКИРУЕТ contracts/107-cmp-mob-003-erstinformation.md:59 — К5 проверяет каждый patch отдельно, тогда как инвариант :41 требует конъюнкцию свойств при любом их сочетании. Список шести одиночных повреждений не наблюдает совместное отсутствие evidence_ref и checked_at.

ОБХОД: дерево модели с изменённым `evidenceUsable`: обычная проверка ИЛИ `(!snapshot.delivery_evidence_ref && !snapshot.checked_at)` — ошибочный legacy-fallback для полностью отсутствующего доказательства. Варианты `delivery_evidence_ref=null` и `''` вместе с `checked_at=''`, payload/required=4/4, обе admission показывают evidence и разрешают W1A continue. Оба поля отсутствуют, инвариант :41 не выполнен. Обе обычные пробы дают rc=0; новый свидетель даёт rc=1, четыре красные клетки. Контроль тех же комбинаций при required=5 остаётся безопасным; неизменённая модель проходит все восемь клеток.

Точная мутация: `measure.py`, `evidence-coabsent-fallback`. Доказательства: `evidence-coabsent-fallback-{erstinfo_static_probe,erstinfo_probe,witness}.log`. Это ось **совместимости независимых условий**, а не требование добавлять по одному частному null-примеру.

### Б2 — побочные эффекты действий: retry тоже не бизнес-переход

БЛОКИРУЕТ contracts/107-cmp-mob-003-erstinformation.md:60 — К6 хорошо закрыл open/ack/continue, но действие retry из К2 (:56) проверяет только recheck и отсутствие ack. Требование issue #7 «повторно читать evidence без автоматического продолжения бизнес-процесса» и инвариант :44 остаются шире наблюдения.

ОБХОД: дерево модели, где обработчик `erstinfo-retry` исполняет `onRecheck?.(); onContinue?.();`. FAILED в W0 и W1A реально продолжает бизнес-процесс по нажатию «повторить проверку», не Continue. Стандартная FAILED_RETRY_ACTION не смотрит cont, остальные клетки не нажимают retry. Обе обычные пробы rc=0; собственные `retry-is-read-only W0/W1A` rc=1, два отказа (continue вызван). На модели без мутации эти же клетки rc=0.

Точная мутация: `measure.py`, `retry-business-transition`. Доказательства: одноимённые три `.log`. Ось — **каждое доступное действие × все запрещённые эффекты × admission**, а не повтор прежнего open→continue/ack→continue.

### Б3 — завершение ack: порядок, исход Promise и смена версии

БЛОКИРУЕТ contracts/107-cmp-mob-003-erstinformation.md:61 — слова «ПОСЛЕ завершения Promise» (:43) проверяются итоговым числом recheck, без наблюдения отсутствия recheck до settlement. Кроме того, resolve({accepted:false}) не проверяет rejected Promise операции.

ОБХОД: дерево модели с `Promise.resolve(onAcknowledge(...)); onRecheck?.();` вместо finally-recheck. Gate перечитан сразу после отправки, пока операция ещё не закончилась; после появления версии 5 и завершения ack версии 4 повторного чтения нет. Обе обычные пробы rc=0, в том числе ACK_VERSION_CHANGES; новые свидетели в W0/W1A rc=1: до settlement уже зарегистрирован `recheck`. На неизменённой модели обе клетки rc=0. Контракт требует `ack-start → ack-settled → recheck`, а принимает `ack-start → recheck → ack-settled`.

ОБХОД: отдельное дерево `recheck-success-only`: finally заменён на `.then(() => onRecheck?.(), () => undefined)`. Пока Promise незавершён, required меняется 4→5; затем Promise отклоняется `ACK_OUTCOME_UNKNOWN_NEW_VERSION`. Никакого recheck после окончания операции нет: ожидается 1, получено 0 в обеих admission. Обе обычные пробы rc=0; отдельный собственный свидетель rc=1, два отказа. Это не добавление retry-политики: наблюдается уже объявленное перечитывание после завершения ack при ушедшей версии.

Доказательства: `recheck-before-settlement-*.log`, `recheck-success-only-*.log`. Дополнительный контроль двух одновременно незавершённых ack с обратным порядком завершения на неизменённой модели зелёный в обеих admission; отдельного дефекта двойного ack не заявляю.

Граница доказательства rejection: неизменённая модель действительно вызывает finally/recheck, но оставляет rejected Promise необработанным, поэтому первоначальные два reject-теста падают с самим `ACK_OUTCOME_UNKNOWN_NEW_VERSION`. Положительный reject-контроль выполнен на явном диагностическом варианте модели с терминальным `.catch(() => undefined)` ПОСЛЕ исходного finally; обе клетки rc=0. Это изменение только disposable-модели, не «исправленная авторская модель» и не скрытая правка критерия. Блокер не зависит от этого контроля: обход раннего recheck имеет положительный контроль на совершенно неизменённой модели.

### Б4 — исполняемый runtime: полный пригодный gate и его потребитель

БЛОКИРУЕТ contracts/107-cmp-mob-003-erstinformation.md:63 — К9 теперь исполняет настоящий runtime, но `RUNTIME_GATE_SNAPSHOT` сравнивает лишь подмножество полей. checked_at и responsible_entity_id пропущены; отдельно от этого экран испытывается с другим, полным, снимком из теста. Зелень двух раздельных половин не доказывает заявленный шов :51 и отображение актуального доказательства :33/:41.

ОБХОД: `runtime.api.getDisclosureGate()` возвращает `{...gateMock(), checked_at:'', responsible_entity_id:''}`. Типы, операции, версия, document_id и evidence_ref сохранены; обе обычные пробы rc=0. Но передача ЭТОГО снимка в неизменённый Erstinformation при требуемой версии 2 показывает disclosure.updated вместо CURRENT_CONFIRMED, без evidence/continue и без идентификатора ответственного маклера. Прямой свидетель runtime→экран rc=1 с `Unable to find an element with testID: erstinfo-evidence-checked-at`; тот же свидетель на модели rc=0.

Точная мутация: `measure.py`, `runtime-incomplete-gate`. Окончательное доказательство: `runtime-witness.test.tsx`, `control-runtime.log`, `incomplete-runtime-corrected.log`. Это не прежний бросающий исключение runtime и не константный mock: операции успешно возвращают объект, но он непригоден реальному потребителю.

## Совместный обход и порог FAIL

`python3 /tmp/dev-harness-verify/Critic107r2/combined.py` устанавливает одновременно Б1, Б2, ранний recheck Б3 и Б4. Точные исходные/новые байты хранятся в MUTANTS `measure.py`; тесты, Jest-конфиг и окружение субъекта не подменяются. Обычные пробы и обе матрицы rc=0; `combined-witness.log` — rc=1, 9 failed из 13 исполненных клеток. Затем `inherited.py` независимо подтверждает зелень 61+2 старых клеток на том же новом дереве.

Таким образом, это не пять вкусовых пожеланий к покрытию. Есть конкретное дерево, удовлетворяющее всем предъявленным предметным Python/RNTL-командам, включая унаследованные свидетели, но нарушающее предмет. Будущий C, PR checks и нативный Maestro здесь не объявляются пройденными: это pre-freeze суд критерия. Названный нативный сценарий открыть/увеличить/вернуться не наблюдает эти четыре оси. Обе матрицы не испытывают C по собственной объявленной семантике.

АРБИТР: роль `arbiter`; предмет вызова — повторный FAIL по осям Б1–Б4, достаточность К5–К9 для инвариантов и граница завершения/rejection ack. Вызов фиксирую сам, не назначаю третий обычный круг критика. Попытка передать вызов `agent://Main` отклонена инструментом: `внутренний URI непиннованной сессии запрещён — Н-85 ... null-allowlist = /tmp/dev-harness-verify/**, artifact://; цель agent://Main`. Запуск арбитра не состоялся; доступного peer/tool для его запуска в этой сессии нет. Оркестратору передаётся этот вызов вместе с вердиктом. Несогласие автора в этом круге не измерялось; по AGENTS.md третьему кругу всё равно должен предшествовать арбитр.

## Полная карта осей против issue #7 и source.json

Первичный issue прочитан живой `gh issue view`; route взят непосредственно из B (`BrokerOS_Mobile_Design_Data.json:32347–32480`), также сверены binding F02.A02 и wave getDisclosureGate. Содержимое 16 copy-записей (text + review_status), шесть server delivery, три applicability и пять screen-state совпадают с первичными источниками. Это проверено отдельно от запуска субъекта (`source-audit.py`). Ни зелень pre_critic, ни числа матрицы не заменяли суждение о полноте.

| Ось первичного источника / переход | Перенос и результат круга 2 |
|---|---|
| F02.03: responsible_entity, document/version, разрешённый источник; getSession/getDisclosure | Отображение и объявления операций есть; авторизация источника/подключение реальных данных — композиция C, не доказана автономным RNTL. Неполный runtime — Б4 |
| F02.05: exact-version, открытие ≠ ack/mandate, возврат | К2/К3 наблюдают действия и поля; pin при обновлении добавлен. Реальное чтение/доступный viewer — будущий C/Maestro |
| F02.08: CHECKING/PENDING/FAILED/OUTDATED/CURRENT_CONFIRMED | Все пять состояний × EQ/STALE проверяются; зелёный контроль подтверждён |
| Те же состояния × W0/W1A | Все 20 клеток continue теперь есть; прежний пробел закрыт. Независимая ось retry-эффекта всё ещё Б2 |
| Версия меньше / равна / больше required | EQ/STALE и отдельное VERSION_NOT_EQUAL=1 закрывают прежнее сравнение `<`; новые 4/4 и 4/5 использованы независимо |
| Полнота evidence: ссылка, время, документ, applicability, комбинации отсутствия | Одиночные повреждения покрыты; совместное отсутствие пропускается — Б1 |
| Evidence authority: actor/subject/entity/scope/policy | Полная route-грамматика имеет больше полей, чем клиентский snapshot. Mapping/владелец серверной валидации остаются отдельной границей; С3 не закрыт полностью |
| MISSING/UNKNOWN delivery; REQUIRED/NOT_REQUIRED/UNKNOWN applicability; absent snapshot | Новая К8 и К5 покрывают выбранные fallback. Это не вся route: NOT_REQUIRED branch, snapshot_valid и return_target остаются вопросами композиции |
| Open / ack / continue / retry × запрещённые эффекты | Первые три усилены; retry → continue проходит критерий — Б2 |
| Ack: версия устарела заранее / во время операции; resolve accepted true/false / reject | Управляемый Promise добавлен, но нет временного наблюдения до settlement и rejection — Б3 |
| Два ack, обратный порядок завершения, поздний старый ответ | Собственный контроль обеих admission зелёный; отдельного обхода не найдено |
| V02/V04: сброс принятия новой версии; delivered без accepted_at не подпись | Источник :860–880 теперь назван; legacy delivered не используется как evidence. Нативное отображение подписи не проверялось |
| Mock-сценарии × версии; запись ack; настоящий runtime | К9 закрывает прежнюю декларативность; неполнота snapshot между runtime и экраном — Б4 |
| Resume rechecks gate; reuse evidence; unknown outcome/reconcile; outage сохраняет intent; отказ/возврат | Полная route содержит эти оси; source.json их не переносит. Continue→onContinue может делегировать recheck композиции: без отдельного воспроизведения это совет, не новый блокер |
| W0 против W1a; admission операций | getDisclosureGate действительно W1a в Operation_Waves; отсутствие continue в W0 проверено. Вызов gate только на нужной волне — ответственность композиции C |
| Трассировка UX175-F02.A02: intent, stale/revoked, replay, no navigation commit | Контракт :131 откладывает трассировку на backend; это не доказательство клиентских частей. Совет С3; реальные HTTP/SQL/provider evidence не заявлены |
| Copy / review status; accessibility, увеличение текста; Light/Dark | 16 copy-записей совпадают; signoff явно не завершён. Native/visual/accessibility не прогонялись, остаются отложенной приёмкой C |
| Реальная выдача backend / ServiceMandate / завершение onboarding | Backend CMP-BCK-008/024 и onboarding вне предмета; SYNTHETIC не повышен до реального evidence |

## Советы круга 1 и дополнительные наблюдения — не условия FAIL

СОВЕТ contracts/107-cmp-mob-003-erstinformation.md:94 — С1 **учтён**: implementer получил `mobile/src/app/` и `bootstrap/http-runtime.ts`; :96 назначает владельца композиции и ограничивает route-правки. Конкретный route/параметры и связывание runtime с данными ещё выбирает исполнитель; сверх измеренного Б4 этим не блокирую.

СОВЕТ contracts/107-cmp-mob-003-erstinformation.md:73 — С2 **учтён полностью по смыслу команды**: --matrix явно назван самопроверкой модели/проб, не приёмкой C. Прогон на B и совместном обходе подтверждает именно эту семантику.

СОВЕТ contracts/107-cmp-mob-003-erstinformation.md:53 — С3 **учтён частично**: добавлены server_grammar, MISSING/UNKNOWN/NOT_REQUIRED и snapshot_absent. Полные snapshot_required, scope/entity/subject matching, сохранение intent, resume/reconcile/replay не сведены в карту владельцев/проверок. Наличие серверных read-операций TARGET_SPEC_ONLY не отменяет необходимость назвать клиентскую границу. Не объявляю непроверенный источник/route новым обходом.

СОВЕТ contracts/107-cmp-mob-003-erstinformation.md:42 — С4 **учтён для обновления viewer**: версия открытия явно закреплена; оба прежних pin-свидетеля теперь зелёные. Это не свидетельство доступного PDF-viewer на устройстве; :76/:130 корректно откладывают реальный flow до C.

СОВЕТ contracts/107-cmp-mob-003-erstinformation.md:47 — дополнительное замечание первого круга про источник V02/V04 учтено. Placeholder acknowledge и copy signoff остаются честно обозначенными ограничениями :45/:136.

СОВЕТ fixtures/workshop_project/erstinfo_107/source.json:10 — `ui_copy_b` содержит 63 символа вместо SHA-256: записано `...fbfe55a7646a1`, фактически на B `...fbfe955a7646a1`. Остальные шесть хэшей совпали. `controls.py` остановился здесь с rc=1; отдельный `inventory.py` сохранил все значения в `source-hashes.json`. Независимое сравнение 16 text/review_status и трёх перечней грамматики зелёное; обхода поведения из этой опечатки не предъявляю.

СОВЕТ contracts/107-cmp-mob-003-erstinformation.md:43 — авторская модель при rejection оставляет необработанный Promise. Это отдельное наблюдение над эталоном, не просьба судить ещё не написанную реализацию; Б3 обоснован пропуском требуемого recheck и его неправильным порядком. Первая версия собственного runtime-свидетеля тоже имела ошибку: matcher сравнивал весь агрегированный текст View со строкой `re-001`. Она исключена из доказательства и заменена отдельным `runtime-witness.test.tsx` с положительным контролем. Первоначальные логи сохранены, за валидные отказы не выдаются.

## Пять вопросов и формальные двери

1. Критерий слабее предмета — да, четыре измеренные оси выше; это основания FAIL.
2. Команды и коды возврата названы; недостаточна их наблюдаемая семантика, не наличие названий. Неисполненные будущие PR/native-команды не объявляются зелёными.
3. Молчаливые решения — route-композиция, полная серверная грамматика, error/reconcile ownership. Без измеренного обхода они перечислены советами, не дополнительными условиями.
4. Исполнители и зоны названы; прежнее отсутствие app/http-runtime исправлено. Границы держатся зонами плюс явными read-only-оговорками :98.
5. Н-39 соблюдена: контракт не утверждает конкретных пар «стаб ↔ ветвь»; привязки только в коде. Нового самостоятельного нормативного блокера не заявляю.

Собственные живые команды на клоне OBJECT (cwd=h):

```text
bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic107r2/h contracts/107-cmp-mob-003-erstinformation.md
OK
rc=0

bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Critic107r2/h contracts/107-cmp-mob-003-erstinformation.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 11 буллет(ов), НЕ ЗАЩИЩАЕТ 4 буллет(ов))
rc=0

bash scripts/check_provodka.sh /tmp/dev-harness-verify/Critic107r2/h contracts/107-cmp-mob-003-erstinformation.md
[вывод пуст]
rc=0
```

Авторский pre_critic не использовался как доказательство и повторно не запускался. Формально валидная модель угроз не доказывает заявленную защиту.

## Сырые команды, rc и воспроизведение

Каждый `*.log` содержит полную реально исполненную команду, cwd, stdout/stderr и отдельную строку `rc=`. Jest JSON сохранены. Скрипты не требуют изменения h и восстанавливают продуктовые файлы через installed; TMPDIR и npm-cache лежат внутри своей области.

```text
git clone ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/Critic107r2/h
rc=0
# cwd=/tmp/dev-harness-verify/Critic107r2/h
git checkout --detach a4520d9b626457259673bbbe7679051331384596
rc=0; HEAD is now at a4520d9b

git clone ssh://git@github.com/a3ka/Complior-mob.git /tmp/dev-harness-verify/Critic107r2/mob
rc=0
# cwd=/tmp/dev-harness-verify/Critic107r2/mob
git checkout --detach 76ac10fa
rc=0; HEAD is now at 76ac10f
# cwd=/tmp/dev-harness-verify/Critic107r2/mob/mobile
npm ci --cache /tmp/dev-harness-verify/Critic107r2/npm-cache
rc=0; added 1100 packages in 7s

gh issue view 7 --repo a3ka/Complior-mob --json body --jq .body
rc=0

python3 /tmp/dev-harness-verify/Critic107r2/measure.py baseline
rc=0
B-erstinfo_static_probe rc=1
B-erstinfo_probe rc=1
model-erstinfo_static_probe rc=0
model-erstinfo_probe rc=0
matrix-erstinfo_static_probe rc=0
matrix-erstinfo_probe rc=0

python3 /tmp/dev-harness-verify/Critic107r2/measure.py mutations
rc=0
control-witness rc=1
 cases 17 failed 3
# Два unhandled-rejection плюс неверный matcher собственного первого runtime-теста;
# эти три отказа НЕ используются как самостоятельные основания FAIL.
evidence-coabsent-fallback-erstinfo_static_probe rc=0
evidence-coabsent-fallback-erstinfo_probe rc=0
evidence-coabsent-fallback-witness rc=1
 cases 8 failed 4
retry-business-transition-erstinfo_static_probe rc=0
retry-business-transition-erstinfo_probe rc=0
retry-business-transition-witness rc=1
 cases 2 failed 2
recheck-before-settlement-erstinfo_static_probe rc=0
recheck-before-settlement-erstinfo_probe rc=0
recheck-before-settlement-witness rc=1
 cases 2 failed 2
recheck-success-only-erstinfo_static_probe rc=0
recheck-success-only-erstinfo_probe rc=0
recheck-success-only-witness rc=1
 cases 2 failed 2
runtime-incomplete-gate-erstinfo_static_probe rc=0
runtime-incomplete-gate-erstinfo_probe rc=0
runtime-incomplete-gate-witness rc=1
 cases 1 failed 1
# Последний исходный witness заменён валидированным контролем ниже.

python3 /tmp/dev-harness-verify/Critic107r2/controls.py
rc=1
control-valid-paths rc=0
 cases 14 failed 0
control-rejection-handled rc=0
 cases 2 failed 0
control-runtime rc=0
incomplete-runtime-corrected rc=1
# Затем SOURCE ui_copy_b equal=False и AssertionError: опечатка хэша в source.json.

python3 /tmp/dev-harness-verify/Critic107r2/source-audit.py
rc=0
SOURCE grammar delivery/applicability/screen states equal=True
# Все 16 COPY text+review_status equal=True; полный вывод измерен отдельно.
primary-issue rc=0
source audit complete: 16 copies and 3 grammar sets checked

python3 /tmp/dev-harness-verify/Critic107r2/combined.py
rc=0
combined-erstinfo_static_probe rc=0
combined-erstinfo_probe rc=0
combined-matrix-erstinfo_static_probe rc=0
combined-matrix-erstinfo_probe rc=0
combined-witness rc=1

python3 /tmp/dev-harness-verify/Critic107r2/inventory.py
rc=0
INDEPENDENT_AST_MUTANTS erstinfo_probe.py 18
INDEPENDENT_AST_MUTANTS erstinfo_static_probe.py 4
direct-model rc=0
INDEPENDENT_JEST_REPORT total=95 passed=95 unique=95
COMBINED_WITNESS total=13 failed=9
restoration-status rc=0
# git status --short --untracked-files=all: вывод пуст.

python3 /tmp/dev-harness-verify/Critic107r2/inherited.py
rc=0
reference-inherited-witness.test.tsx rc=0
reference witness.test.tsx passed=61 failed=0
reference-inherited-api-witness.test.tsx rc=0
reference api-witness.test.tsx passed=2 failed=0
new-combined-inherited-witness.test.tsx rc=0
new-combined witness.test.tsx passed=61 failed=0
new-combined-inherited-api-witness.test.tsx rc=0
new-combined api-witness.test.tsx passed=2 failed=0
```

rc=0 измерителя означает успешное завершение измерения, а не зелень отрицательных свидетелей. Первоначальная диагностическая ошибка matcher и остановка на несовпавшем хэше явно раскрыты; окончательные доказательства Б1–Б4 имеют собственные положительные контроли. Android, визуальная поверхность, HTTP-доставка, полный build/lint/проектный test-suite и CI не запускались и не заявляются проверенными.
