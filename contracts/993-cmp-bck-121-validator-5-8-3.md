# Контракт 993 — CMP-BCK-121: статический валидатор Complior-back и erratum 5.8.3

КЛАСС: КОДОВЫЙ. Статус: черновик; открытые зависимости ниже блокируют заморозку, не ослабляют приёмку. Карточка: a3ka/Complior-back#123. Бутстрап 294128ff4 заменён этим предметом; повторного минта нет.

КОНТЕКСТ: решения владельца — `docs/owner/2026-10-17-resheniya-back-992-993.md`, §3 задаёт семантику, §4 ограничивает зоны и Merge. Анализ отказов — `/tmp/dev-harness-verify/DECISIONS-121.md`, SHA-256 `740278c7c0b551aff67be9d1c56935bf7d55826bceb5f9654f30192eb58cebc2`; при подготовке реализации читать §3–7 целиком. Этот контракт фиксирует требования, не выдаёт предложенный PASS за выполненный.

## Существующее

- Живой внешний клон: `a3ka/Complior-back`, HEAD `842f4e99d6024ab62336a6a0be787ae667fb555b`. OpenAPI SHA-256 `f89b4a048f0aa405ed636bbddea4c63730d8d7607f15729f97990b6490e86e16`. Текущее дерево важнее старых SHA в HANDOFF. Версия API 5.8.2; полный operation-index охватывает 163 операции, deprecated — 19 (измерение анализа; при приёмке пересчитать по OpenAPI).
- `tests/validate_contract_v3_9.py:14–60` уже инспектирует реальные OpenAPI/index/source; `:62–143` валидирует examples, сохраняет append-only JSON evidence и возвращает rc 0/1. Сохранить этот CLI и evidence-формат, не заводить второй production-валидатор. На текущем дереве scope — строка 46, consumers — 48–49, requestBody crash — 53 (в анализе номера местами сдвинуты).
- `contracts/frontend-consumer-bindings.json` — единственный canonical registry; `tools/generate_derived.py:23–47` применяет принятые source overrides, `:94–103` проецирует consumers, но теряет action READ dependencies. Реальные примеры: F01.A01 → previewPartnerInvitation (`bindings:19–36`), F46.A03 → getMission (`:6512–6543`). `screen_reads`, `workflow_consumers` уже существуют, `joint_controls` пуст.
- `generate_derived.py:74–85` обновляет только ранее перечисленные examples, не обнаруживает новые; `:117–139` вычисляет VS01 closure и отказывает при изменении frozen hash. `--freeze-vs01` не перезаписывает существующий freeze. Нельзя удалить запись freeze ради прохождения.
- `OpenAPI:19921–19934` задаёт target AccountSession ETag на `/revocations`; `:20520–20533` содержит две ветви conditional profile. `:21428–21445` задаёт safe POST и его CSRF policy. `:17723–17759,17783–17802` задаёт retained deprecated provider ingress с signature/passport и ограниченным effect. Эти исключения уже являются контрактом, не новой льготой валидатора.
- `OpenAPI:27193–27204` у listPostItems:200 описывает PostPage без example; schema — `:57589–57610`. `Complior_Backend_Architecture_v3_14_RU.md:689–701,764–766` сохраняет источник bindings, gates F35/F36 и NOT_RUN. Архитектурное обобщение `:300` требует уточнения, а не массовой смены wire.
- `README_RU.md:31–44` уже несёт штатные команды поставки; `tools/validate_alignment_11782_31422.py:37,46–54,89` проверяет точную 5.8.2 и исторический source snapshot. Это реальная зависимость смены версии, не зелёная галочка, которую можно опустить.

## Предмет и граница

Один наблюдаемый результат: полный реальный валидатор принимает согласованный пакет **5.8.3** без crash и без ложных универсальных правил, а каждая мутация ниже отвергается своим failure ID при зелёном соответствующем контроле. Генерация, freeze/provenance и existing delivery checks согласованы с тем же source commit. Runtime остаётся NOT_RUN_BY_THIS_VALIDATOR.

### 1. Обход, примеры и errors

Обходить OpenAPI, а не только существующие строки index. Ровно одно вхождение каждого operationId в обоих множествах; совпадают method/path/deprecated/wave/source hash. Удаление строки, duplicate или неизвестный operationId — именованный отказ, не исключение Python и не skip. Полное множество — 163 на исходной базе; число checks само по себе полноту не доказывает. Сохранить существующие 28 schema/semantic negative cases.

Request examples проверяются iff после разрешения `$ref` существует requestBody, для каждого media type, независимо от глагола. Bodyless logoutSession/revokeMailboxGrant законны: request-example N/A, command/security/error checks продолжаются. Поддержать OAS `example` и `examples`, разрешать локальные Example `$ref`; неразрешимый ref или непроверенный externalValue не считается примером. Любое описанное success body имеет schema-valid example; 204 без content законен. Проверяется canonical example и его включение в derived inventory, а не только `not_generated: []`.

Для требуемой ошибки выбрать **exact status → 4XX/5XX → default**, разрешая response `$ref`. Выбранная ошибка и все объявленные error/default ветви используют canonical Problem. Ошибочный explicit 409 нельзя скрыть хорошим default. Semantic coverage требует `409 IDEMPOTENCY_CONFLICT` в command policy/reason metadata. 412/428 нужны для CAS-ветви, а не каждого POST. provisionInsuranceMailbox/createMailboxGrant/createInsuranceMailDraft/recordOutcomeEvidence сохраняют 202 + default Problem без обязательных новых explicit 409/412/428.

### 2. Consumers без role-based bypass

Независимо восстановить graph из canonical bindings + accepted source overrides: action variants, `current_source_read_operation_ids`, `execution_semantics.reads.existing_operation_ids`, screen producer/refresh/later-read, programme и workflow. Сравнить с derived graph целиком. Action ID проверять по source action_rows, не по самому bindings; frame/programme IDs — в собственных namespaces. READ не становится COMMAND и не создаёт UI action ID. `pending_control` не является принятой командой. Availability, release gates и NOT_RUN сохраняются.

Восстановить доказанные action-read связи для операций: previewPartnerInvitation, listAccountSessions, listMissions, listMessages, listDocuments, getVoiceSession, getConsultationSummary, getWorkspace, getMissionEvents, getApproval, getPersonalProfile, listInsuredAssets, listPolicies, listContexts, listMemory, getProtectionProfile, getQuoteRequirements, getPlacementQuotes, getAdviser, getHandoff, getNotificationSnapshot, getPreferences, getMission. Это список из анализа, не весь допустимый graph: getInsuredAsset дополнительно разрешается через реальные screen metadata. getProtectionMap не возвращается вместо getProtectionProfile.

Каждая active операция требует разрешимого consumer. Non-mobile — типизированная связь существующего workflow/service/web/partner/staff/internal surface в **существующем workflow-разделе bindings**, с owner, source_ref и guard. Source_ref должен разрешаться в настоящий источник вызывающего flow, а не в скопированную роль самой операции. Закрытый namespace kind фиксируется schema/проверкой вместе с генератором; неизвестный kind — FAIL. Удаление связи и из index, и из bindings при сохранённой role всё равно FAIL независимой source-сверки либо missing-consumer. Нет allowlist прежних 73, исключения для staff/internal или фиктивных mobile IDs. Неразрешимый реальный остаток — блокер, не invented binding.

Deprecated выводится из OpenAPI, сверяется с index и не исключается из обхода. Новый active consumer не требуется, но ref/schema/auth/Problem/применимые idempotency/CAS остаются. F35/F36 — W5/NOT_YET_AVAILABLE/FOUNDER_DECIDED_W5_GATED, не executable flow; сохранённый staff/provider transport не получает прав от deprecated.

### 3. Независимые закрытые профили

- Обычная mutation: X-Command-Id, Idempotency-Key, durable receipt, current-auth replay, admission и error semantics остаются обязательными. Классификация CAS не зависит от HTTP non-GET, URL-суффикса, наличия If-Match или nullable CommandEnvelope.expected_version.
- Каждая mutation явно объявляет `x-command-policy.precondition`: закрытые значения `VERSIONED_TARGET_CAS` либо `CREATE_OR_APPEND_NO_TARGET_CAS`. Отсутствующее/пустое/неизвестное значение — FAIL. Для exemption также обязательны `precondition_target`, `precondition_basis` — описание конкретного эффекта и проверяемое основание create/append, не перечень operationId внутри валидатора. Провести смысловую классификацию всех 36 mutating без If-Match из исходного анализа; исключённые safe preview и provider — собственные профили. CREATE_OR_APPEND_NO_TARGET_CAS ставится везде, где действительно нет versioned target. Нельзя предположить это обо всех 36: logout/current session и selective revocation сверяются отдельно. Если обнаружен настоящий missing target CAS, новый required wire header не маскируется patch-версией: остановить поставку и получить compatibility-решение.
- VERSIONED_TARGET_CAS требует required strong target If-Match + 412/428. Уже существующий `x-conditional-policy` допускает initial create (expected_version=0, If-None-Match:*) и existing update (expected_version>=1, exact strong target ETag), строго одну conditional header; проверить обе ветви, запрет обеих/отсутствующей. Объявленный If-Match проверяется независимо от exemption. revokeAccountSession остаётся versioned target, несмотря на `/revocations`.
- SAFE_READ_OVER_POST признаётся только совместно с mutation=false, durable_receipt=false, body_only_secret_input и отсутствием domain/outbox admission. previewPartnerInvitation не требует command receipt/CAS, но сохраняет body examples, auth/scope, response и собственную CSRF-policy. Одного mutation=false недостаточно.
- Effective security учитывает наследование и operation override. Каждая cookie-альтернатива mutation — sessionCookie AND csrfToken с корректным X-CSRF-Token scheme/parameter. Bearer-only не обязан иметь CSRF/cookie. Хорошая cookie-ветвь не легализует соседнюю незащищённую; security:[] не универсальный bypass.
- Scope dispatch: SERVER_RESOLVED_SCOPE_AND_RESOURCE_ACL различает optional/RequiredScopeHeader и server-resolved resource ACL; OWN_PRINCIPAL_IDP_SESSION требует ContractVersion/current auth/own session/IdP gate, target-version и step-up revocation без обязательного domain scope; PERSONAL_SCOPE_CURRENT_HUMAN_SELF_ONLY требует RequiredScopeHeader + ContractVersion и own HUMAN/PERSONAL role/storage/context, исключая foreign/family/partner/service scope. Неизвестная policy — FAIL, известное имя без её инвариантов тоже FAIL.
- Provider ingress проверяет весь профиль: signature required, EXACT_RAW_BYTES_AND_PROVIDER_HEADERS, anonymous=false, unknown/unapproved passport FAIL_CLOSED_NO_DOMAIN_MUTATION, запрет cookie/bearer substitution, CONNECTION_PASSPORT_REQUIRED, normalized event schema и OBSERVE_RECORDED_INVOKED_EFFECT_ONLY. Ни путь `/webhooks`, ни security:[], ни deprecated не заменяют эти условия. Client scope/command key/ETag/CSRF ему не добавляются; provider dedup не равен Idempotency-Key.

### 4. Erratum и поставка

Добавить к canonical listPostItems:200 schema-valid synthetic example:

```json
{"items": [], "next_cursor": null, "as_of": "2026-10-17T00:00:00Z"}
```

Это illustration, не HTTP evidence, pagination proof или runtime fallback. Генератор должен обнаруживать новые canonical examples полным обходом, а не только обновлять прежние inventory rows. Включить PostPage в api-examples и schema validation.

Поднять info.version, response version constants, exact-version checks и metadata до 5.8.3; regex совместимости 5.8.x сохранить при неизменённом wire. Восстановить canonical bindings/генерацию, derived index не править руками. Действующий VS01 hash `39f34f297257cc2cc8d9ce80d9c4f2e98708f50b823d30bbdc95902013571db1` сохраняется как old evidence; новый hash вычисляется по окончательным bytes/closure. Не брать диагностический hash от одного example как финальный. Owner §3а разрешил re-freeze; сохранить old/new/source/основание erratum, без удаления старого решения и без автоматического blessing любого drift. Исторические UX source snapshots не переписываются как будто всегда были 5.8.3; новый accepted snapshot имеет provenance. Производные и FILES.sha256 регенерируются согласованно.

Вне предмета: `backend/`, runtime handlers, ACL/SQL/provider HTTP acceptance, новые product flows, массовый If-Match на коллекции, CSRF bearer-only, client headers webhook, выдуманные consumers; зеркало Complior-mob/api — отдельный PR после принятого back commit.

## Пины и последовательность

H — замороженные bytes этого контракта и probe.py в dev-harness; B/C — полный base/head Complior-back, зарегистрированные в issue #123; V — Python и зависимости из requirements-validation.txt. Исходная воспроизводимая база B указана в §Существующее. Смена B/C требует новых evidence и судов. Fixture ожидания снимаются из H до исполнения C.

Архитектор пишет контракт и красную батарею → критик → заморозка → implementer → CI владельца интеграции → adversary → reviewer → owner Merge → done. Зоны не расширяются во время реализации. **Н-39: стабы/пробы привязываются к коду, где дефект наблюдаем, не к прозе.** Если положительная фикстура падает, её парный rc1 не засчитывается обнаруженным мутантом.

## Приёмочный критерий

Обозначения команд: `PY` — абсолютный Python venv с `requirements-validation.txt`; `H` — абсолютный путь принятого checkout dev-harness; `R` — disposable полный checkout Complior-back C; `OUT` — новый отсутствующий evidence-каталог. Команды внешнего проекта запускаются с cwd=R. Ни один rc не извлекается после подменяющего его echo/pipe.

1. Дано: исходный B; когда: `PY tests/validate_contract_v3_9.py`; тогда: rc1, `KeyError: 'requestBody'`, счётчики не напечатаны. Это исходный красный crash, НЕ 187 доказанных отказов. Отдельная команда `PY H/fixtures/workshop_project/validator_993/probe.py --repo R --out OUT --diagnostic` меняет только bodyless expression в временной копии, не реализацию, и печатает фактические диагностические счётчики ниже; rc1. Этот режим не принимается вместо обычного CLI.
2. Дано: реализованный C, полный canonical/derived пакет; когда: `PY tests/validate_contract_v3_9.py --out OUT`; тогда: rc0, JSON status=PASS_STATIC, failure_ids=[], runtime_status=NOT_RUN_BY_THIS_VALIDATOR, все исходные operationId проверены и сохранены schema/semantic cases. Парные негативы — следующая команда, не краснота от любого crash.
3. Дано: C и неизменённая батарея H; когда: `PY H/fixtures/workshop_project/validator_993/probe.py --repo R --out OUT`; тогда: rc0, каждый control rc0/PASS_STATIC/пустые failure_ids и каждый mutant rc1/FAIL_STATIC с **точным** ожидаемым failure ID. Неисполняемый вход/пустая выборка → rc2 `993 UNMEASURABLE`; ненулевой mismatch → rc1. Каждый сценарий §7 анализа имеет свой номер в коде, сложные строки раскрыты в отдельные mutations. Список ID, операция и точечная порча — функция `cases()`, единый источник; любой кейс отдельно: та же команда с `--case NAME`.

| §7 | Реальный вход / отрицательное предъявление | Требуемая причина (суффикс operationId) |
|---|---|---|
| 1 | createIntent, updatePersonalProfile, previewPartnerInvitation: удалить media examples | request_example |
| 2 | bodyless logoutSession/revokeMailboxGrant зелены; удалить CommandId | command_identity |
| 3 | ordinary revocation, createIntent, bodyless logout: удалить Idempotency-Key | command_idempotency |
| 4 | createIntent: пустой consumer, удалённая index row, удаление связи также из bindings; role сохранена | source_consumers |
| 5 | действительный action ID как frame, неизвестный kind | consumer_resolution |
| 6 | bearer-only createIntent без CSRF зелён; idempotency всё ещё обязательна | command_idempotency |
| 7 | добавить незащищённую cookie alternative рядом с хорошей | csrf |
| 8 | fake mutation=false; safe preview с domain admission | policy_consistency |
| 9 | revokeAccountSession: удалить target If-Match | cas |
| 10 | updatePersonalProfile: удалить каждую conditional ветвь отдельно / разрешить обе headers | conditional_policy |
| 11 | четыре 202/default команды зелены; удалить default у каждой / испортить Problem | problem |
| 12 | хороший default, плохой explicit 409 | problem |
| 13 | неизвестная scope policy / personal без required scope / без HUMAN role | contract_scope_policy |
| 14 | webhook: signature mode, fail-closed passport, anonymous flag, отсутствие auth policy | provider_auth |
| 15 | deprecated createPlateCheck с gated историей зелён; испортить error transport | problem |
| 16 | активировать F35 и F36 отдельно / удалить deprecated Idempotency-Key | consumer_availability / command_idempotency |
| 17 | listPostItems: удалить example / испортить items | response_example |

4. Дано: исправленный C после разрешённого re-freeze; когда: `PY tools/generate_derived.py`, затем `PY tools/verify_ux175.py`, `PY tools/validate_alignment_11782_31422.py`, `PY tools/validate_invitation_target_31421.py`, `npm ci && npm test` с cwd=R/server, `PY tests/validate_contract_v3_9.py`, повторный `PY tools/generate_derived.py`, `PY tools/verify_handoff.py`; тогда: каждый rc0, существующие проверки не удалены/не skip, в README_RU/VALIDATION сохранены реальные результаты. Это прогон владельца интеграции после всех пачек, не заявление архитектора о выполненном общем CI. Парный негатив: неразрешённая смена VS01 operation example при старом manifest → generate_derived rc≠0 `Frozen VS01 specification changed; do not silently update baseline`.
5. Дано: C; когда: reviewer сверяет old/new VS01 hash, version constants, source/index/example inventory и canonical non-mobile source_ref по исходным артефактам B/C, а adversary прогоняет батарею H; тогда: оба accept на одном C. Отсутствующее основание CAS exemption, неразрешимый consumer source_ref или несовпавший closure → FAIL с operationId/путём. Семантическая достоверность основания — cognitive-only, остаточный риск ложного metadata-обоснования ловят независимые судьи; regex непустой prose не доказательство.

## Зоны и исполнители

ЗОНА architect: contracts/993-cmp-bck-121-validator-5-8-3.md fixtures/workshop_project/validator_993/
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/validator_993/ — новая подсемья существующей frozen architect-зоны 105; прежние файлы/семантика 105 не меняются.

Следующая зона — **dev-harness-сторона**, только интеграционный запуск принятых красных тестов; probe.py — ПИН H, ослабление/подмена ожиданий запрещены.

ЗОНА implementer: fixtures/workshop_project/validator_993/

Следующая зона — **пути от корня Complior-back для его проектного check_zones**, дословно предел owner §4; это не разрешение менять одноимённые пути dev-harness.

ЗОНА implementer: tests/validate_contract_v3_9.py contracts/ tools/generate_derived.py evidence/contracts/ README_RU.md VALIDATION.json FILES.sha256

`backend/` исключён: там работает консультант. Merge PR 993 в Complior-back делает владелец; разрешение консультанту мержить свою подготовительную фазу на этот PR не распространяется. `VERSION_MANIFEST.json` и прочие зависимости ниже пока НЕ включены в разрешённую зону.

## ПРОВОДКА

ПРОВОДКА:
- guard=fixtures/workshop_project/validator_993/probe.py

ПРОВОДКА-ЭНФОРСМЕНТ: исправляется существующий внешний validator CLI, вызываемый штатной поставкой README_RU и scoped приёмкой/судами 993. Батарея потребляется строкой 3 приёмки. Общий CI dev-harness не получает зависимость от внешнего checkout; существующие нормы ролей/charter не меняются. Архитектор не исполняет implementation вместо implementer.

## Модель угроз

ЗАЩИЩАЕТ:
- от ложной static-зелени через bodyless crash/skip, неполный обход index, role-as-consumer, потерю READ-связей, blanket deprecated exemption;
- от смешения CAS, command durability, cookie-CSRF, scope и provider transport, и от vacuous error coverage;
- от ложного обнаружения мутанта по постороннему rc1: полный зелёный контроль плюс конкретный failure ID из структурного JSON; исходные ожидания/байты в памяти до вызова, каждый mutant отдельно.

НЕ ЗАЩИЩАЕТ:
- от поддельной реальности source_ref/CAS narrative без предметной сверки: cognitive-only суд по canonical sources;
- от malicious кода с тем же OS uid, изменяющего проверяющий процесс: disposable clone не security sandbox;
- от runtime ACL/SQL receipt/provider signature verification/no-repeat effects/пагинации. Static examples и 28 старых cases не становятся HTTP evidence;
- от санкционирования файлов вне owner-зоны: это явный блокер, не implicit allowlist.

## Замер ДО реализации

Зависимости установлены в `/tmp/dev-harness-verify/architect993-venv` по `requirements-validation.txt`. До установки системный python дал `ModuleNotFoundError: No module named 'jsonschema'`; это infrastructure, не продуктовый red. С установленными зависимостями настоящая команда `PY tests/validate_contract_v3_9.py` вернула rc1:

```text
  File "/tmp/dev-harness-verify/architect993-cback/tests/validate_contract_v3_9.py", line 143, in <module>
    if __name__=='__main__':sys.exit(main())
                                     ^^^^^^
  File "/tmp/dev-harness-verify/architect993-cback/tests/validate_contract_v3_9.py", line 66, in main
    checks,failures=inspect(api,index,source,programme,vocab)
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/tmp/dev-harness-verify/architect993-cback/tests/validate_contract_v3_9.py", line 53, in inspect
    check(oid+'_request_example',bool(op['requestBody']['content']['application/json'].get('examples')))
                                      ~~^^^^^^^^^^^^^^^
KeyError: 'requestBody'
```

Счётчики обычный CLI **не напечатал**. Отдельный диагностический прогон с единственной явно названной bodyless-поправкой в scratch, stdout дословно (rc1):

```text
BODYLESS_DIAGNOSTIC_ONLY {"validator_rc": 1, "status": "FAIL_STATIC", "checks": 1000, "negative_cases": 28, "examples": 249, "failure_ids": 187}
```

Сырой diagnostic stdout/stderr/report: `/tmp/dev-harness-verify/architect993-diagnostic/raw.json`. Этот результат воспроизводит числа анализа, не подменяет непочиненный CLI и не является реализацией.

## Независимая сверка исходных множеств

Отдельный прямой обход OpenAPI + index + объединения двух action-read полей (не подсчёт строк отчёта валидатора) дал rc0 и следующий stdout. Synthetic PostPage отдельно проверен настоящим Draft202012Validator на исходной schema:

```text
{"operations": 163, "deprecated": 19, "active_empty_index": 75, "restorable_action_read_operations": 23, "non_get_without_if_match": 38, "mutating_without_if_match": 36}
READ_OPERATIONS getAdviser,getApproval,getConsultationSummary,getHandoff,getMission,getMissionEvents,getNotificationSnapshot,getPersonalProfile,getPlacementQuotes,getPreferences,getProtectionProfile,getQuoteRequirements,getVoiceSession,getWorkspace,listAccountSessions,listContexts,listDocuments,listInsuredAssets,listMemory,listMessages,listMissions,listPolicies,previewPartnerInvitation
POSTPAGE_SCHEMA errors=0
```

Независимый подсчёт failure_ids диагностического JSON: source_consumers=132, durable_cas_csrf=45, contract_scope_policy=9, response_example=1. Это не сумма отдельных CAS/CSRF признаков: они пересекаются.

## Живой прогон mutation-батареи

Команда на финальных bytes probe.py:

```text
/tmp/dev-harness-verify/architect993-venv/bin/python fixtures/workshop_project/validator_993/probe.py --repo /tmp/dev-harness-verify/architect993-cback --out /tmp/dev-harness-verify/architect993-final-matrix
993 scenarios=17 mutations=40 validator_runs=80 mismatches=40
```

Код батареи **1**. Полный сырой stdout/stderr **каждого** контроля и мутанта, operationId, ожидаемый failure ID и результат сопоставления: `/tmp/dev-harness-verify/architect993-final-matrix/raw.json`. Отдельный подсчёт этого JSON, а не повтор счётчика раннера:

```text
scenarios=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]
cases=40
rc_pairs={(1, 1): 40}
requestBody_crashes=80
matched=0
```

Все точечные мутации применены к копиям настоящего OpenAPI/bindings/index и вызвали настоящий CLI. Но **ни одна не засчитана пойманной**: каждый контроль и каждый мутант остановились исходным bodyless crash; ни одного целевого failure ID не получено. Это честный red базового предмета, не выполненная приёмка различимости и не готовая к заморозке зелёная батарея. Runtime/общий CI не запускались. Дополнительный CLI-smoke с `--case nonexistent` дал rc2, дословно `993 UNMEASURABLE: EMPTY_SELECTION`.

## Незаполненные требования:
- **Зона поставки против зависимости версии:** owner §4 не разрешает VERSION_MANIFEST.json (необходим для re-freeze), tools/validate_alignment_11782_31422.py (exact version/accepted snapshot), новый accepted source snapshot и архитектурное уточнение §18. Генератор также пишет data/client-field-decisions-v3_10.json, tests/acceptance-ux1175.json, server/mock-5_8.json вне зоны. Требуется точное согласование прав на затронутые paths/новый snapshot до раздачи, а не самовольное расширение. Исторические UX snapshots не переписывать. Блокер передан оркестратору.
- **Зелёные контроли:** неизменённый validator падает на bodyless до проверки мутантов. Батарея обязана оставаться красной; зелёные controls + именованные red mutations должны быть предъявлены после implementer. До этого выполнение команды не считается доказательством различимости. Заморозку/готовность red-пачки без этой оговорки не объявлять.
- **Предметная классификация:** полный source-backed non-mobile остаток и семантические CAS dispositions для всех 36 требуют сверки реальных оснований; нет разрешения выдумать потребителя или автоматически exempt каждую команду. При невозможности сохранить wire в 5.8.3 требуется compatibility-решение владельца.
