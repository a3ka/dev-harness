# Контракт 106 — CMP-BCK-133: спецификация Complior-back 5.8.4 (CAS, потребители, обязательная проверка)

КЛАСС: КОДОВЫЙ. Статус: черновик. Карточка: a3ka/Complior-back#148. Номер выдан механизмом (тег `id/CONTRACT/106`, строка реестра `2a6d59e27`).

КОНТЕКСТ: решение архитектора бэкенда — `docs/owner/2026-10-18-arhitektor-beka-5-8-4.md` (§Итог, §Порядок, §CAS, §Потребители, §Один реестр, §Ограничения — читать целиком); ROADMAP.md §12 п.2 (слот бэкенда, порядок CMP-BCK-133 → 004 → 003 → 005 → 006 → 002 → 007); `docs/owner/2026-10-18-tri-slota.md` §1 «Этап 2» (бэкенд — третий слот); `docs/owner/2026-10-17-resheniya-2030.md` §3 (требование к БЭКЕНДУ). Прецедент формы и поставки — контракт 993 (CMP-BCK-121, erratum 5.8.3) и его вердикты; этот контракт — следующая поставка того же семейства, не второй формат.

## Существующее

- База B воспроизводима: `a3ka/Complior-back`, коммит `0230ee068d10047b1be99c26747aef1bd1579bcf` («993 implementer fix round 5» — дерево замера; erratum r1: заявленный в первом круге полный sha `0230ee06867d…` не разрешался `git cat-file -e` ни в снимке, ни в свежем клоне origin — короткий префикс `0230ee0` разрешается только в этот коммит; вершина ветки `cmp-bck-121/validator-5-8-3` — `5bdd707e443feb8c3fca8f9e5f24838f87742091`, микро-раунд FILES.sha256 поверх B, замер не меняет). Пин проверен прогоном `git cat-file -e` в свежем клоне origin и в снимке; валидатор на этом дереве — rc 1, `FAIL_STATIC`, 57 отказов. Снимок для работы: `/tmp/dev-harness-verify/c995/back`; одноразовая копия базы — локальный клон снимка. Смена B (в т.ч. после Merge PR #146) требует новых evidence и не проходит молча.
- Замер на B настоящим CLI `tests/validate_contract_v3_9.py` (venv `requirements-validation.txt`): rc 1, `FAIL_STATIC`, `failure_ids` — ровно **57** = **5** суффикса `_cas` (acknowledgeDisclosure, revokeApproval, revokePermission, requestAction, revokePartnerGrant) + **1** `revokePartnerGrant_conditional_policy` + **51** суффикса `_source_consumers`. Полный список 51 операции — рядом с батареей, `fixtures/workshop_project/spec584_106/consumer-ops-51.json`, снят из этого отчёта, не переписан вручную.
- Канонические файлы: OpenAPI — `contracts/BrokerOS_Unified_OpenAPI_v3.yaml` (`info.version: 5.8.3`, строка 4), 163 операции, 19 deprecated (подтверждено и независимым обходом yaml, и полями `contracts/operation-index.json`); производные — `tools/generate_derived.py` (повторная генерация на B — no-op для пары operation-index/frontend-consumer-bindings, замер батареи); `x-command-policy.precondition` с закрытыми значениями `VERSIONED_TARGET_CAS|CREATE_OR_APPEND_NO_TARGET_CAS` уже грамматика 993 (83 вхождения).
- Статусный файл `BACKEND_ADOPTION_PENDING` живёт в `sources/frontend-ux1_17_5/BrokerOS_Alignment_and_Value_Design_Data.json` (и копии ux1_17_8_2) — статус ожидания принятия, не нормативный источник; литеральный типизированный потребитель `mobile lifecycle/service` в дереве отсутствует (замер: 0 вхождений в bindings).
- CI (CMP-BCK-130): команды lanes живут в `tools/run_backend_ci.py`, `.github/workflows/ci.yml` несёт только окружение и агрегат `required` (success лишь если каждый lane зелёный). На B lane-таблица несёт валидатор плейсхолдером: `('static', 'validate_contract_v3_9 — NOT_RUN до CMP-BCK-121 (контракт 993)', '@not-run')`. Требуемое («после устранения отказов проверка становится обязательной») ещё не исполнено — проводка живой команды в lane-таблицу и опустошение базы отказов — часть настоящего предмета; правка workflow-файла не нужна.
- Разрешение владельца зон для внешних путей дал контракт 993 (owner §3–4); ограничения исполнителя — §Ограничения решения архитектора бэкенда: не принимать pending-файл целиком, не менять семантику отзыва разрешений ради валидатора, не скрывать неподтверждённые операции массовым `deprecated`.

## Предмет и граница

Один наблюдаемый результат: согласованный пакет **5.8.4** — CAS-профили пяти операций, подтверждённые потребители 51 операции, regenerated производные, версия, согласование вызывающих сторон — принимается настоящим статическим валидатором без отказов и проводится в CI обязательной проверкой; каждая обманная копия пакета отвергается именованной причиной. Статическая успешность не доказывает работу обработчиков: HTTP и SQL проверяются отдельно (runtime остаётся NOT_RUN_BY_THIS_VALIDATOR). Фиктивные привязки ради зелёного валидатора не добавляются.

### 1. CAS пяти операций — по смыслу каждой

Замкнутая грамматика поверх существующей 993: `x-command-policy.precondition` получает третье закрытое значение `IDEMPOTENT_TARGET_REVOKE`, разрешённое ТОЛЬКО для revokePermission (замкнутый перечень в валидаторе и в батарее).

- **acknowledgeDisclosure, revokeApproval, requestAction, revokePartnerGrant** — `VERSIONED_TARGET_CAS`: обязательный параметр `If-Match` (required, strong target) и объявленные 412/428. Семантика по решению §CAS: acknowledgeDisclosure — подтверждение точной версии раскрытого документа (описан источник ETag); revokeApproval — версионная защита плюс различение отзыва неисполненного согласования и отмены уже отправленного действия; requestAction — If-Match поскольку команда меняет версионное состояние Mission, перечислено, какие изменения Mission делают команду устаревшей; revokePartnerGrant — версия гранта плюс перепроверка актуальных полномочий вызывающего, условный профиль — проверяемая структура (mapping), не строка.
- **revokePermission** — закрытый выбор из двух: (а) `VERSIONED_TARGET_CAS` с корректной обработкой устаревшей версии либо (б) `IDEMPOTENT_TARGET_REVOKE` — явная повторяемая операция отзыва конкретного разрешения с серверной перепроверкой ресурса и scope: в политике обязаны присутствовать `server_recheck.resource`, `server_recheck.scope`, `repeat_safe: true`. Отзыв не требует действующего допуска HEALTH. Переименование в `CREATE_OR_APPEND_NO_TARGET_CAS` запрещено: запись события в append-only журнал не означает, что операция не меняет существующее разрешение.
- **Все пять** несут `x-cas-semantics` (mapping) с непустыми ключами: `version_source`, `retry`, `stale_version`, `completed_action`, `concurrent_execution` — источник ETag или версии, повтор запроса, устаревшая версия, уже завершённое действие, конкурентное исполнение (§CAS «для всех пяти»).
- Семантическая достоверность наполнения (правильность описания гонки, полнота перечня изменений Mission) — предметная сверка судей по канону; структурная полнота — батарея и валидатор.

### 2. Потребители 51 операции

- Каждая операция из замкнутого перечня 51 (`consumer-ops-51.json`) получает подтверждённого потребителя: конкретный сценарий, роль потребителя, источник, волна и статус принятия; запись «используется backend» недостаточна (§Потребители).
- Грамматика валидатора дополняется типизированным потребителем `mobile lifecycle/service` (литерал; подписка SSE без экрана — например streamMissionEvents), чтобы не придумывать фиктивные экраны. Статус `BACKEND_ADOPTION_PENDING` не принимается как потребитель; pending-файл целиком не принимается.
- Статусы различены: `deferred` ≠ `deprecated` — отложенная функция остаётся в плане, устаревшая выводится из использования. Удаление операций и массовое откладывание/обесценивание ради зелёной проверки запрещены: множество операций 163 и deprecated 19 сохраняются (изменение — только поимённо с основанием, вне этого контракта).
- getInbox — отдельно проверенное назначение; источником Post его не назначать (для Post согласован listPostItems).
- Соотношение множеств (erratum r1: прежняя строка «46 операций вне перечня 51» читала источник неверно): перечень 51 из `consumer-ops-51.json` = 4 партнёрские (`createPartnerInvitation`, `getPartnerOverview`, `listPartnerClients`, `listPartnerEarnings`) + `getVoiceTranscript` (W29) + 46 остальных операций того же перечня; поимённое множество 46 = перечень файла минус эти пять названных. Вне перечня 51 остаются 112 операций (163−51): их назначение сохраняется, потребители подтверждаются валидатором на тех же правилах 993 (source_consumers/consumer_resolution), новых послаблений нет.

### 3. Версия, производные, согласование вызывающих сторон

- Версия: `info.version` = 5.8.4; версионные константы, exact-version проверки (`tools/validate_alignment_11782_31422.py` и метаданные) подняты в той же пачке; список изменённых требований к запросам — в новом `contracts/backend-5_8_4-alignment.json` (замкнутая форма: `cas_operations` — ровно пятёрка; `changed_request_requirements` — непусто по каждой из пяти; `callers` — непусто по `mobile`, `web`, `workers`). «Мобильное приложение пока не вызывает» — недостаточно: проверяются все вызывающие стороны.
- Реестр `frontend-consumer-bindings.json` вручную не редактируется: правка нормативных источников, затем `tools/generate_derived.py`; повторная генерация на поставленном дереве — no-op для канонической пары реестров.
- Исторические UX-снимки и прежнее evidence не переписываются; новый evidence — в `evidence/contracts/106/` из disposable прогона; FILES.sha256 ссылается только на поставленные файлы (условие 993 действует).

### 4. Обязательность проверки

После поставки 5.8.4 статический валидатор обязателен: в lane-таблице `tools/run_backend_ci.py` плейсхолдер `@not-run` заменён живой командой `tests/validate_contract_v3_9.py`; агрегат `required` в `.github/workflows/ci.yml` делает её lane обязательным без правки workflow-файла; обход lane (плейсхолдер, skip, понижение до advisory) запрещён; база известных статических отказов пуста (все 57 устранены, «исправленный, но оставшийся в базе — тоже красный» теряет силу вместе с самой базой). Временный неблокирующий режим — только до устранения отказов (§Порядок п.2), в поставленном дереве его нет. Отказ валидатора распространяется через lane: запись lane-таблицы `package` — живая команда `tests/validate_contract_v3_9.py` с описанием, содержащим `validate_contract_v3_9`; красный валидатор делает lane красным (rc≠0 и FAIL-строка валидатора в отчёте раннера) — измеряется клеткой `lane_swallows_validator_red`, а не только подстрокой в тексте раннера.

## Пины и последовательность

H — замороженные bytes этого контракта и `fixtures/workshop_project/spec584_106/` в dev-harness; B — база из §Существующее, полный пин `0230ee068d10047b1be99c26747aef1bd1579bcf` (клетка `version_only` материалит его из объектного магазина R через `git archive`; нерезрешимость пина в R — rc 2 `106 UNMEASURABLE: BASE_UNRESOLVABLE`); C — реализованное дерево Complior-back; V — venv `requirements-validation.txt`. Ожидания батареи сняты из B до исполнения C; смена B/C — новые evidence и суды. Порядок: архитектор (этот контракт и батарея) → критик → заморозка → implementer → CI → adversary → reviewer → owner Merge. Зоны не расширяются во время реализации.

## Приёмочный критерий

Обозначения: `PY` — абсолютный python venv; `H` — принятый checkout dev-harness; `R` — disposable полный checkout Complior-back; `OUT` — новый отсутствующий каталог; команды внешнего проекта с cwd=R; ни один rc не извлекается после подменяющего pipe.

1. Дано: B; когда: `PY tests/validate_contract_v3_9.py --out OUT`; тогда: rc 1, `FAIL_STATIC`, `failure_ids` длины 57 состава 5 `_cas` + 1 `revokePartnerGrant_conditional_policy` + 51 `_source_consumers`. Это исходное красное, не выполненная поставка.
2. Дано: B; когда: `PY H/fixtures/workshop_project/spec584_106/probe.py --repo R --out OUT`; тогда: rc 1, `control_green=false` с 21 именованной причиной контроля (версия 5.8.3; 15 причин неполных CAS-профилей пятёрки — по 3 на операцию: if_match_not_required, CAS_SEMANTICS_MISSING, CAS_CONDITIONAL_NOT_STRUCTURED; `ALIGNMENT_MISSING`; `VALIDATOR_NOT_RUN_PLACEHOLDER`; `VALIDATOR_RC_1`/`VALIDATOR_STATUS_FAIL_STATIC`/`VALIDATOR_FAILURES:57(cas=5,consumers=51,other=1:revokePartnerGrant_conditional_policy)`), все 12 мутантов — `BLOCKED_BY_RED_CONTROL`. Полный сырой вывод — `OUT/raw.json`. Это честный red базового предмета; зелёность контроля на B не заявляется.
3. Дано: реализованное C; когда: та же команда батареи; тогда: rc 0 — контроль зелён (валидатор rc 0/`PASS_STATIC`/`failure_ids=[]`; версия 5.8.4; профили пятёрки полны; операционное множество 163/19; производные no-op; alignment-файл полон; валидатор в lane-таблице раннера живой командой, без плейсхолдера) И каждый мутант из `cases()` (единый источник перечня — код батареи, текущий счёт 12) отвергнут ровно своей точной причиной `REJECTED_EXACT`. Для каждой клетки батарея снимает sha256 всех файлов входа ДО и ПОСЛЕ мутации в память и требует `applied=True` и `byte_equal=False` относительно входа, к которому клетка привязана: побайтно неизменный вход — rc 2 `106 UNMEASURABLE: MUTATION_NOOP` (ошибка батареи, а не «не отклонено»; Н-39 — отрицательный вход обязан отличаться от зелёного контроля). Клетка `version_only` привязана кодом к закреплённому до-предметному входу B (материал `git archive` из R по пину §Пины), не к C; клетка `lane_swallows_validator_red` требует от lane `package` распространения отказа валидатора (rc≠0 и FAIL-строка `validate_contract_v3_9`). Ненулевое расхождение — rc 1; непригодная база, нерезрешимый пин B или пустая выборка `--case` — rc 2 `106 UNMEASURABLE`. Привязка каждой обманной копии к дереву, на котором её дефект наблюдаем, и точная ожидаемая причина — код `cases()`, не проза этого текста.
4. Дано: C; когда: интеграционный прогон владельца по форме 993 п.4 — `PY tools/generate_derived.py`, `PY tools/verify_handoff.py`, `PY tools/validate_alignment_11782_31422.py`, `npm ci && npm test` (cwd=R/server), `PY tests/validate_contract_v3_9.py`, повторный `PY tools/generate_derived.py`; тогда: каждый rc 0, существующие проверки не удалены и не skip. Это прогон владельца после всех пачек, не заявление архитектора об общем CI.
5. Дано: C; когда: adversary и reviewer судят по этому контракту на одном C (батарея H + канон проекта: решение архитектора бэкенда, архитектура v3_14, OpenAPI); тогда: оба accept. Семантическая достоверность CAS-нарративов и потребителей (правильность описаний, реальность сценариев) — предметная сверка судей; regex непустой строки не доказательство.

## Зоны и исполнители

ЗОНА architect: contracts/106-cmp-bck-133-spec-5-8-4.md fixtures/workshop_project/spec584_106/
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/

Внешние пути от корня Complior-back (та же грамматика, что 993):

ЗОНА implementer: contracts/BrokerOS_Unified_OpenAPI_v3.yaml contracts/operation-index.json contracts/frontend-consumer-bindings.json contracts/api-examples.json contracts/backend-5_8_4-alignment.json tests/validate_contract_v3_9.py tools/generate_derived.py tools/run_backend_ci.py tools/validate_alignment_11782_31422.py contracts/dto-ui-mapping.json server/mock-5_8.json VERSION_MANIFEST.json README_RU.md VALIDATION.json FILES.sha256 evidence/contracts/106/ Complior_Backend_Architecture_v3_14_RU.md

ПЕРЕСЕЧЕНИЕ implementer: contracts/BrokerOS_Unified_OpenAPI_v3.yaml — 993 erratum 5.8.3; 106 — следующая поставка 5.8.4 поверх неё, тот же канон
ПЕРЕСЕЧЕНИЕ implementer: contracts/operation-index.json — 993 производный реестр; 106 регенерирует его через generate_derived.py, не руками
ПЕРЕСЕЧЕНИЕ implementer: contracts/frontend-consumer-bindings.json — 993 производный реестр; 106 регенерирует его через generate_derived.py, не руками
ПЕРЕСЕЧЕНИЕ implementer: contracts/api-examples.json — 993 производный реестр; 106 регенерирует его через generate_derived.py, не руками
ПЕРЕСЕЧЕНИЕ implementer: tests/validate_contract_v3_9.py — 993 CLI валидатора; 106 расширяет грамматику (третье значение precondition, типизированный потребитель, пустая база отказов), не заводит второй валидатор
ПЕРЕСЕЧЕНИЕ implementer: tools/generate_derived.py — 993 CLI генератора; 106 расширяет грамматику, не заводит второй генератор
ПЕРЕСЕЧЕНИЕ implementer: VERSION_MANIFEST.json — 993 поставочный артефакт; 106 поднимает версию, не переписывает историю
ПЕРЕСЕЧЕНИЕ implementer: README_RU.md — 993 поставочный артефакт; 106 поднимает версию, не переписывает историю
ПЕРЕСЕЧЕНИЕ implementer: VALIDATION.json — 993 поставочный артефакт; 106 поднимает версию, не переписывает историю
ПЕРЕСЕЧЕНИЕ implementer: FILES.sha256 — 993 поставочный артефакт; 106 поднимает версию, не переписывает историю
ПЕРЕСЕЧЕНИЕ implementer: Complior_Backend_Architecture_v3_14_RU.md — 993 поставочный артефакт; 106 поднимает версию, не переписывает историю
ПЕРЕСЕЧЕНИЕ implementer: tools/validate_alignment_11782_31422.py — 993 exact-version проверка (буквально 5.8.3, строки 37–38); 106 поднимает версию в той же пачке (§Предмет 3), не заводит второй инструмент
ПЕРЕСЕЧЕНИЕ implementer: contracts/dto-ui-mapping.json — 993 производный артефакт (tools/generate_derived.py, поле api = `info.version`, строка 67 генератора); 106 регенерирует его подъёмом версии через генератор, не руками
ПЕРЕСЕЧЕНИЕ implementer: server/mock-5_8.json — 993 производный артефакт (tools/generate_derived.py, поле contract = `info.version`, строка 145 генератора); 106 регенерирует его подъёмом версии через генератор, не руками

Вне предмета: `backend/` (там работает консультант), runtime handlers, ACL/SQL/provider HTTP acceptance, новые product flows, реальные репозитории mob/web (согласование отражается в alignment-файле; правка чужих репозиториев — отдельные решения владельца), зеркала Complior-mob/api. Merge продуктового PR делает владелец.

## ПРОВОДКА

ПРОВОДКА:
- guard=fixtures/workshop_project/spec584_106/probe.py

ПРОВОДКА-ЭНФОРСМЕНТ: батарея потребляется строками 2–3 приёмки и судами; исправляются существующие внешние CLI Complior-back (валидатор, генератор, CI-раннер), вызываемые штатной поставкой README_RU. Общий CI dev-harness не получает зависимость от внешнего checkout; нормы ролей и charter не меняются; архитектор не исполняет реализацию вместо implementer.

## Модель угроз

ЗАЩИЩАЕТ:
- от ложной зелени «номер подняли — пакет готов»: версия без CAS-профилей и потребителей отвергается живым валидатором и структурным оракулом батареи;
- от переименования профиля вместо версионной защиты и от идемпотентного отзыва без серверной перепроверки (закрытая грамматика precondition по операции);
- от массового `deferred`/`deprecated` и удаления операций ради пустого списка отказов (пин 163/19 двумя независимыми мерами);
- от подмены подтверждённого потребителя статусом ожидания (литерал `mobile lifecycle/service` против `BACKEND_ADOPTION_PENDING`);
- от ручной правки производных реестров (no-op повторной генерации, sha до/после в памяти);
- от скрытой красноты обязательной проверки (плейсхолдер `@not-run` в lane-таблице раннера, как и любой обход lane — включая проглатывание отказа валидатора: клетка `lane_swallows_validator_red` требует rc≠0 и FAIL-строку валидатора в отчёте lane `package`).

НЕ ЗАЩИЩАЕТ:
- от правдоподобного, но ложного CAS-нарратива/потребителя без предметной сверки — cognitive-only, ловят независимые судьи по канону;
- от runtime: HTTP-обработка, SQL, конкурентное исполнение в живой базе — вне статического валидатора (§Порядок п.5);
- от злонамеренного кода с тем же OS uid в процессе проверки: disposable копия — не security sandbox;
- от несанкционированной правки чужих репозиториев (mob/web): alignment-файл — заявление, исполнение в чужих деревьях — решения владельца.

## Замер ДО реализации

Выполнено на B (venv `/tmp/dev-harness-verify/architect993-venv`, пин `0230ee068d10047b1be99c26747aef1bd1579bcf`, рабочее дерево `git worktree` свежего клона origin):

1. `PY tests/validate_contract_v3_9.py --out …` → rc 1, `FAIL_STATIC`, `failure_ids` 57 = 5 `_cas` + 1 `revokePartnerGrant_conditional_policy` + 51 `_source_consumers` (состав посчитан из JSON отчёта отдельным обходом, не по счётчику).
2. `PY H/fixtures/workshop_project/spec584_106/probe.py --repo R --out …` → rc 1; контроль красен 21 именованной причиной (перечень в §Приёмка п.2); 12 мутантов `BLOCKED_BY_RED_CONTROL`. Отдельно `--case nonexistent` → rc 2 `106 UNMEASURABLE: EMPTY_SELECTION`.
3. Механизм мутаций проверен на копиях базы напрямую (обход блокировки контроля, текущий код батареи): mass_defer → `OPSET_DEPRECATED_DRIFT_INDEX:49!=19`; delete_op → `OPSET_COUNT_DRIFT_INDEX:162!=163`; runner_placeholder → `VALIDATOR_NOT_RUN_PLACEHOLDER`; cas_key_hollow → `CAS_SEMANTICS_HOLLOW:revokeApproval:completed_action`. Инвариант «мутация меняет вход» (sha256 всех файлов до/после) на копиях B: cas_rename, cas_no_match_header, cas_key_hollow, cas_idempotent_no_recheck, mass_defer, delete_op, manual_derived, runner_placeholder, lane_swallows_validator_red — `applied=True, byte_equal=False`; клетки, привязанные к честному C (consumer_kind_pending — литерала `mobile lifecycle/service` на B нет; alignment_hollow — файла alignment на B нет), на B не применяются (`applied=False`) — это ожидаемо и не заявляется зелёным; их инвариант проверяется на C в п.3 приёмки.
4. Клетка version_only на закреплённом входе B (материал `git archive` пина из объектного магазина рабочего клона): `applied=True, byte_equal=False`; валидатор копии — rc 1, `acknowledgeDisclosure_cas` в `failure_ids`, всего 59 отказов = 57 базы + `current_exact_version` + `index_source_sha256` — подъём версии без остального добавляет именованные версионные отказы, не снимая CAS; вход отличен от C по построению (другой коммит). Сторож батареи: подстановка no-op мутации при фальшиво-зелёном контроле (monkeypatch) даёт rc 2 `106 UNMEASURABLE: MUTATION_NOOP`.
5. Повторная генерация на B — no-op для канонической пары (в контроле нет `DERIVED_DRIFT`).
6. Lane `package` раннера на B: rc 1; шаг валидатора печатается `[package] NOT_RUN rc=None validate_contract_v3_9 — NOT_RUN до CMP-BCK-121 (контракт 993)` — плейсхолдер виден и в lane-отчёте; клетки runner_placeholder (структурно) и lane_swallows_validator_red (прогоном lane) закрывают его с двух сторон.

## Незаполненные требования:
- Зелёные контроли батареи и `REJECTED_EXACT` по всем мутантам — после implementer на C; на B батарея честно красна (п. 2–3 §Замер).
- Семантическая достоверность CAS-описаний и потребителей (реальность сценариев, полнота перечня изменений Mission) — предметная сверка судей; структурная полнота не заменяет её.
- Последовательность с PR #146: 5.8.4 строится поверх поставки 993; Merge #146 — решение владельца. Если Merge происходит до реализации, база B переснимается на main и evidence пересобираются; если 5.8.4 должен уйти раньше Merge — это форк воли владельцу (рекомендация: Merge #146 первым, как в §Порядок решения).
- Смена чисел 163/19 допустима только поимённо с основанием и вне этой пачки; молчаливый дрейф — красное батареи.
