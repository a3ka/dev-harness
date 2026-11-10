# Изоляция данных Conversation: ключи модели 2.4.1 против «участников дела» Word v2.5 §10

Ответ Fable на вопрос владельца (2026-11-09 ~11:30). Адресат — Астра (автор модели 2.4.1). Все ссылки — на `Complior-back` main `6b62aa0` (пакет `architecture/` 2.4.1, снимок `baseline/approved.json`, digest `02fbb3cb…`) и на текст Word v2.5 (`CompliorOS_Isolated_Modules_Architecture_RU_v2_5.docx`, §10 «Что создаётся для каждого дела»). Метки: **Факт** — прочитано/измерено (путь:строка); **Предложение**; **Открыто** — решает владелец.

## (а) В чём именно расхождение

### Что говорит модель 2.4.1

**Факт.** `architecture/system/resources.js`:
- `resource.conversation` (36–48): owner/readers/writers `api.conversations`, `classification: 'personal'`, **`isolationKeys: ['tenantId', 'userId', 'conversationId']`**, `caseAssociation: 'Optional; when associated, the case owner must equal the conversation owner. Cross-case context transfer requires explicit admission.'`
- `resource.mission` (14–24): `classification: 'case'`, `isolationKeys: ['tenantId', 'userId', 'caseId']`.
- `resource.run` (95–106): `case`, `['tenantId','userId','caseId','conversationId','runId']`; описание: «standalone conversation runs require a separately admitted scope profile».

`architecture/checks/fitness/policies.js:115-124` (правило `FF-SCOPE-ISOLATION`): обязательные ключи по классификации — `personal: ['tenantId','userId']`, `case: ['tenantId','userId','caseId']`; `resource.conversation` дополнительно требует `conversationId`. `architecture/checks/fitness/system.js:4-9` — тот же словарь ключей (`tenantId, userId, caseId, conversationId, runId`).

Но в системной модели та же архитектура уже говорит на языке владельца-агрегата: `architecture/system/fitness.js:654-663` — `identities.authorizationBinding: ['scopeId', 'ownerKind', 'ownerId', 'conversationId', 'runId', 'generation']`, `actorIsNotOwner: true`, **`participantPolicy: 'EXPLICIT_OWNER_DECISION_REQUIRED_FOR_SCHEMA'`**. То есть модель сама фиксирует: (1) авторизационная привязка runtime — `scope/ownerKind/ownerId`, не `userId`; (2) актор ≠ владелец; (3) вопрос участников — отложенное решение владельца. Требование `runtime.owner-serialization` (`requirements.js:5647-5657`): «Use the complete tuple scope_id, owner_kind, owner_id».

Итого внутри 2.4.1 **два словаря**: ресурсы изолируются по `tenantId/userId(/caseId)`, runtime авторизуется по `scopeId/ownerKind/ownerId`; связь между `userId` и `ownerId`, между `tenantId` и `scopeId` в модели не объявлена.

### Что говорит Word v2.5 §10

**Факт** (текст docx, абзацы 683–690, 698): таблица «Что создаётся для каждого дела»: «Дело и Conversation — … Что изолировано: **scope, владелец, участники**, документы, история и разрешённые связи»; «В стартовой модели мутации одного owner сериализуются по **scope_id, owner_kind, owner_id** и защищены CAS/fence»; «Сервер проверяет связи conversation, owner, run/wait и текущие права; IDs от клиента не создают полномочия». Слово «участники» в §10 — это **люди с правами на дело**, не писатели транзакции (в §9/§11 «участники Tx B» — другой смысл).

Та же линия в 3.17 §18.1 (`docs/architecture/3.17/s018-01.md:34`): ключ сериализации и outbox `(scope_id, owner_kind, owner_id)`; `owner_kind` — вид владеющего агрегата: Conversation, Mission, самостоятельный ресурс, `PERSONAL_ACCOUNT`, `ACCESS_CONTEXT`.

### Что уже в коде бэкенда (измерено)

**Факт.**
- `owner_kind` / `owner_id`: **0 вхождений** в `migrations/`, `app/`, `server/` (grep). Появляются только в документах `docs/architecture/**`.
- Сообщения привязаны к делу жёстко: `migrations/001_core.sql:190-197` — `app.message(scope_id, id, mission_id uuid NOT NULL, sequence, client_message_id, actor_principal_id, channel, text_body…)`, `UNIQUE(scope_id, mission_id, sequence)`, `FOREIGN KEY(scope_id, mission_id) REFERENCES app.mission`. Таблицы `conversation` нет. Это зафиксировано и в модели: `fitness.js:665-668` `schemaGate.current: 'One mission-bound message stream; no conversation or durable wait tables…'`.
- Арендатор и участники **уже есть в схеме**, но под другими именами:
  - `app.scope` (`001_core.sql:80-87`): `scope_kind ∈ {PERSONAL, COMPANY, CORPORATE}`, `subject_party_id`, `permissions_version` — это `tenantId` модели (для PERSONAL один scope = один человек, `subject_party_id`);
  - `app.scope_party` (`90-95`): `party_id`, `membership_kind`, `valid_from/until` — **участники scope**;
  - `app.access_context` (`115-124`): `principal_id`, `acting_party_id`, `permission_names[]`, `resource_ids[]`, `is_scope_wide`, `basis_grant_ids[]` — контекст доступа актора; актор ≠ субъект уже разведены (`acting_party_id` vs `subject_party_id`);
  - `app.access_grant` + `app.resource.owner_party_id` (`97-103`) — владелец ресурса и основания доступа третьих лиц;
  - RLS (`002_rls.sql:21-45`): `app.has_scope_access(scope_id, permission, resource_id)` — доступ даётся либо «actor = subject party scope» (`acting_party_id = s.subject_party_id`), либо по непустым `basis_grant_ids`, каждый из которых должен быть действующим грантом на ресурс. Политики на `app.message` (`002_rls.sql:213-215`) — `conversation:read/write` через эту функцию.
- `userId` как таковой в схеме `app.*` отсутствует: пользователь — `control.principal` (вход) → `control.party` (субъект) → `app.scope.subject_party_id`.

### Формулировка расхождения

1. **Имена ключей.** Модель: `tenantId/userId`. Код и 3.17/Word §10: `scope_id` + `subject_party_id`/`acting_party_id` + `owner_kind/owner_id`. Для PERSONAL-scope `tenantId ≡ scope_id` и `userId ≡ subject_party_id` — изоморфно; для `COMPANY/CORPORATE` scope `userId` не определён (кто «пользователь» у корпоративного scope?). Модель не объявляет это отображение.
2. **Владелец Conversation.** Модель: владелец — пользователь (`userId`), дело — «optional association, owner must equal». Word/3.17: владелец потока — агрегат (`owner_kind = CONVERSATION | MISSION | …`), и именно по нему сериализуются записи и outbox (Э2.1 ROADMAP: owner-key в outbox вместо `mission_id`). В модели `resource.conversation` нет ключа «владеющий агрегат», а в `resource.run` — есть (`conversationId`, `runId`), но без `ownerKind`.
3. **Участники.** Word §10: «изолировано: … участники». Модель: `participantPolicy: EXPLICIT_OWNER_DECISION_REQUIRED_FOR_SCHEMA` — то есть сознательно не решено. Код: участники реализованы как `scope_party` + `access_grant` + RLS, т. е. **доступ** определяется грантами, а не колонкой `user_id` в строке. Таблица Conversation (её ещё нет) по текущей схеме получила бы `scope_id`, `owner_party_id` (через `app.resource`) и доступ через гранты — без отдельной колонки участников.

Таблицы/ресурсы/операции, которых это касается: `app.message` (сегодня), будущие `app.conversation`, `app.conversation_turn/operation` (Э5), `app.outbox_event`, `app.command_receipt` (owner-key, Э2.1), `app.notification`, `app.snapshot_cursor` (9 RLS-политик, Э4), `app.agent_run`/durable wait (R0/Э5); операции `createHarnessConversation`, `submitHarnessTurn`, `listHarnessTurns`, `streamHarnessEvents`, `promoteHarnessConversation`, `getHarnessResumeBrief` (дельта h317) и модельные `appendMessage`, `readHistory`, `openConversation` (`contract.api.conversations`, все DRAFT).

## (б) Варианты

| | 1. `userId` для M1 (как в модели) | 2. Участники сразу | 3. Гибрид: ключи модели + явное поле участия без логики |
|---|---|---|---|
| **Суть** | Conversation изолируется по `tenantId, userId, conversationId`; владелец = один человек; «участники» — отложены | Conversation имеет список участников с ролями (owner/participant/observer), доступ и видимость — по нему; `owner_kind/owner_id` — владелец-агрегат | Ключи модели сохраняются, добавляется декларация `ownerBinding: {scopeKey, ownerKind, ownerId}` и `participants: DEFERRED_TO_GRANTS` — участие выражено существующими `scope_party`/`access_grant`, без новой таблицы и без логики ролей участников |
| **Что меняется в модели** | ничего по ключам; **L1**: объявить отображение `tenantId→scope_id`, `userId→subject_party_id` (поле `keyMapping` у ресурсов или одна строка в `DECISIONS.md`) | **L3**: `resources.conversation.isolationKeys` → `['scopeId','ownerKind','ownerId','conversationId']`; классификация `personal`→ новая `shared`/`case`; новый ресурс `resource.participation`; `policies.js` требуемые ключи; `fitness.js identities.participantPolicy` → решение; `FF-SCOPE-ISOLATION` переписать | **L3 один раз, узко**: у `resource.conversation`, `resource.run`, `resource.mission` добавить `ownerBinding` (вид и ключ владельца-агрегата) и `participantPolicy: 'GRANTS'`; `isolationKeys` не трогать; `policies.js`: `ownerBinding` обязателен для `case` и для `conversation` |
| **Что меняется в коде и миграциях** | Conversation-таблица с `scope_id`, `owner_party_id` (через `app.resource`), доступ по RLS как сегодня; `mission_id` на `message` остаётся или становится nullable (Э4 — всё равно cutover) | таблица участников `app.conversation_participant(scope_id, conversation_id, party_id, role, valid_*)`, RLS по ней вместо/поверх грантов; дескрипторы с ролями; **второй механизм доступа рядом с `access_grant`** | то, что уже запланировано в 3.17 §18.1 и ROADMAP Э2.1/Э4: `owner_kind/owner_id` в outbox/receipt/stream; Conversation-таблица + `app.resource` с `owner_party_id`; участие — через `scope_party`/`access_grant` (уже есть); новых таблиц ролей нет |
| **Цена перехода позже** | к участникам: **средняя** — нужно добавлять `owner_kind` в stream/outbox (всё равно делается в Э2.1) и переводить RLS; к гибриду — дёшево (объявление) | назад к простому: **высокая** — удалять таблицу и роли; вперёд: ноль | к полным участникам с ролями: **низкая** — `participantPolicy: GRANTS → ROLES`, таблица ролей добавляется поверх грантов; данные не мигрируют |
| **Риск** | модель продолжает говорить `userId`, код — `scope/party/owner` → проверка «код ↔ архитектура» по ключам невозможна без отображения; COMPANY-scope не выразим | преждевременное решение продукта (маклер/семья отложены, ROADMAP §4); две системы доступа | требует одного снимка владельца (секция `resources` защищена) |
| **Цена сейчас** | 0,5 ч (L1) | 3–5 дней модели + миграции + RLS + проверки | 2–4 ч модели (Астра) + снимок владельца; код — без дополнительной цены к Э2.1/Э4 |

## (в) Рекомендация

**Предложение: вариант 3 (гибрид).** Обоснование:
1. Код уже устроен так: арендатор = `scope`, владелец строки = `owner_party_id`, доступ третьих лиц = гранты. Вариант 1 заставляет модель и дальше называть `userId` то, чего в схеме нет, и делает невозможной механическую проверку ключей; вариант 2 заводит второй механизм доступа при отложенных маклере/семье/CRM.
2. 3.17 §18.1 и ROADMAP Э2.1 уже вводят `owner_kind/owner_id` как ключ сериализации; если модель это не объявит, Э2.1 пойдёт против `FF-SCOPE-ISOLATION` по букве («personal: tenantId,userId») при полном соответствии по смыслу — проверка начнёт лгать.
3. Гибрид фиксирует ровно то, что модель сама назвала отложенным (`participantPolicy`), минимальным решением: «участие = гранты», и оставляет дорогу к ролям участников без миграции данных.
4. Для M1 (один человек, PERSONAL-scope) поведение всех трёх вариантов совпадает; различие — только в том, что записано в модели и что проверяемо.

Что при этом фиксируется как решение владельца (не Астры): (а) «участники Conversation в M1 — через гранты scope, без ролей»; (б) владелец Conversation — агрегат Conversation (`owner_kind = CONVERSATION`), а не Mission и не пользователь; человек-владелец выражается `owner_party_id` ресурса.

## (г) Что Астре решить/поправить в модели при каждом варианте

**Вариант 1 (`userId`):**
- L1: объявить отображение ключей модели на схему (`tenantId ≡ app.scope.id`, `userId ≡ app.scope.subject_party_id` для PERSONAL; для COMPANY/CORPORATE — «не определено до решения владельца») — в `DECISIONS.md` и как `keyMapping` у ресурсов или в `system/fitness.js identities`.
- Оставить `participantPolicy: EXPLICIT_OWNER_DECISION_REQUIRED_FOR_SCHEMA`, но назвать дату/условие возврата (Э4).
- Убрать противоречие `resource.run` (есть `conversationId`, нет `ownerKind`) ↔ `identities.authorizationBinding` (есть `ownerKind`).

**Вариант 2 (участники сразу):**
- L3: новая классификация ресурсов (или расширение `case`) с ключами `scopeId, ownerKind, ownerId, conversationId`; новый `resource.participation` (owner — `api.conversations` или `api.identity`? — решить); `policies.js` `classificationKeys`; переписать `FF-SCOPE-ISOLATION`; `participantPolicy` → `ROLES`.
- Контракты: `contract.api.conversations` — операции `addParticipant/removeParticipant/listParticipants` со схемами; инварианты «участник не владелец», «удаление участника не стирает его сообщения».
- Change scenario «участник присоединяется к делу» в `change-scenarios.js`.

**Вариант 3 (гибрид) — рекомендуемый:**
- L3 (один снимок): у `resource.conversation`, `resource.mission`, `resource.run` (и `resource.document`, `resource.effect` — `case`-ресурсы) добавить поле `ownerBinding: { scopeKey: 'scopeId', ownerKind: 'CONVERSATION' | 'MISSION' | …, ownerKey: 'ownerId' }`; `participantPolicy: 'GRANTS'` у `resource.conversation`; `isolationKeys` не менять.
- `checks/fitness/policies.js`: правило `FF-SCOPE-ISOLATION` требует `ownerBinding` у ресурсов класса `case` и у `resource.conversation`; негативный тест в `checks/test/`.
- `system/fitness.js identities`: `participantPolicy: 'GRANTS_VIA_SCOPE_PARTY_AND_ACCESS_GRANT'` с ссылкой на решение владельца; `authorizationBinding` — без изменений.
- L1: `contract.api.conversations.semanticInvariants` дополнить: «Conversation owner is the conversation aggregate; human ownership is expressed by the resource owner party; access by other parties is granted, not implied by participation lists»; `caseAssociation` переформулировать через `ownerKind` («promotion переводит owner_kind с CONVERSATION на MISSION? — нет: Conversation остаётся владельцем своего потока, дело получает ссылку» — **Открыто**, зависит от Э4 promotion).
- `DECISIONS.md`: запись решения владельца (а)(б) из раздела (в) с датой.
- Отображение имён (`tenantId ≡ scope_id`, `userId ≡ subject_party_id`) объявить и здесь — иначе проверка «код ↔ архитектура» по ключам не сможет сопоставить колонки с ключами.

## Вопрос Астре одной строкой

Согласна ли ты зафиксировать в 2.4.2 вариант 3 — `ownerBinding (scopeId, ownerKind, ownerId)` у case-ресурсов и Conversation, `participantPolicy: GRANTS`, `isolationKeys` без изменений, отображение `tenantId/userId` на `scope_id/subject_party_id` — и что в правиле `FF-SCOPE-ISOLATION` ты изменила бы иначе?
