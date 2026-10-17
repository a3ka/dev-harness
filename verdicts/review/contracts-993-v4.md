FAIL

# Ревью 993, круг 4: CMP-BCK-121, валидатор и erratum 5.8.3 — a3ka/Complior-back PR#146

- OBJECT (C): `5fdac96f2010d76f3729f62aac8e8b0f05bd750e`. `git ls-remote` ветки `cmp-bck-121/validator-5-8-3` и
  headRefOid PR#146 совпадают с C.
- Коммиты круга 4: `1d252c0` (починка) и `5fdac96` (чистка FILES.sha256). Автор обоих — `implementer`.
- H: `frozen/contracts/993/1`. `git diff --stat frozen/contracts/993/1 HEAD -- fixtures/workshop_project/validator_993/
  contracts/993-cmp-bck-121-validator-5-8-3.md` пуст.
- Круг 4 открыт словом владельца (ночной план, 2026-10-17 ~23:20 UTC, кап — 5 кругов). Предмет закрыт
  Решением 2 п.2 арбитра `verdicts/arbitration/contracts-993-cas-narrowing-v1.md`: перечень V1–V5/C1–C3/A1–A3
  и пять обязательных пунктов Решения 2 п.1. Решение 1 (а)–(в) не переоткрывается, новые формы обхода вне
  перечня не искались.
- Роль: reviewer (Reviewer993Round4), 2026-10-17. Свежий клон `/tmp/dev-harness-verify/rv993r4/cback`, venv
  `/tmp/dev-harness-verify/rv993/venv`. Мои меры — `/tmp/dev-harness-verify/rv993r4/m{1..7}.py`, мутанты —
  `mut.py` на копии `work/`.
- Находки (reslop): `.review/2026-10-17-09.md`.

Вердикт привязан к этому OBJECT. Новый C его не наследует.

## Итог

| # | Находка | Класс | Статус | Блокирует |
|---|---|---|---|---|
| Рв993-7 | V1–V5, C1–C3 | дефект барьера | ЗАКРЫТО: 12 мутантов красные, каждый своим ID | нет |
| Рв993-10 | README_RU:49, §18 :306 | ложный диагноз | ЗАКРЫТО: все 6 ID в обеих строках | нет |
| Рв993-3 | revokePermission | семантический FAIL §3 п.2 | классификация и удаление старой фразы ЗАКРЫТЫ; новая ложная фраза — Рв993-12 | см. Рв993-12 |
| **Рв993-9** | A3: `has_response_etag` жив и не вызывается; комментарий с двумя ложными примерами | невыполненный пункт A3 Решения 1, заявленное ≠ сделанному | ОТКРЫТО | **да** |
| **Рв993-11** | 19 из 46 строк UNRESOLVED: ложный источник и причина | невыполненный пункт Решения 3, правило 7 | ЧАСТИЧНО: структура 46+5=51 верна | **да** |
| **Рв993-12** | OpenAPI:6760 «parent GET returns a strong ETag…» | ложный факт на wire-метаданных, правило 7 | новое | **да** |
| **Рв993-13** | C1–C3 дважды (`:309–321`, `:378–396`); комментарий `:371–374` это отрицает | 050 ACCIDENTAL (три части есть), заявленное ≠ сделанному | новое | **да** |
| В-1 | 57 именованных отказов | блокер владельца | честный остаток | держит слияние, не вина implementer |
| В-2 | CI backend/required fail | чужая зона (консультант) | вне 993 | нет |
| А-6 | churn-коммиты | совет | условие слияния — squash | нет |

Адверсарий принял круг 4 (`8ea271fc1`). Его предмет — батарея и CAS-мутанты. Мои четыре блокера лежат в
пунктах, которые он не судил: A3-helper, тексты блокер-файла, основание revokePermission и дубль C1–C3.
Каждый из них — пункт Решения 2 п.1 либо норма 050 внутри перечня.

## 1. revokePermission живьём (OpenAPI ≈ :6759)

```
git grep -n -i -E "no version property|no ETag on the wire" 5fdac96f -- contracts/BrokerOS_Unified_OpenAPI_v3.yaml → rc=1, пусто
то же на 31d4b98 → :6759 precondition_target: "…exposes no version property and no ETag on the wire"
C:6758  precondition: VERSIONED_TARGET_CAS
C:6759  precondition_target: "existing caller-scoped Permission grant identified by path id; the Permission resource's own 200 declares a strong resource ETag"
C:6760  precondition_basis: "termination of an existing versioned target: parent GET returns a strong ETag of the current Permission revision; …"
```

Своя мера wire (`m4.py`, `m5.py`):

```
revokePermission POST /v1/permissions/{permission_id}/revocations   params: If-Match нет
  200 headers [Cache-Control, X-Command-Id, Idempotency-Replayed, ETag, X-BrokerOS-Contract]
  200 ETag: "Strong current changed/created resource ETag если resource существует."  schema Permission
paths под /v1/permissions: /v1/permissions [get listPermissions, post createPermission];
                           /v1/permissions/{permission_id}/revocations [post revokePermission]
listPermissions 200 ETag: "Strong scoped resource/version tag…"   schema PermissionList (коллекция)
Permission props: permission_id, context_ref, category, resource_refs, purpose, valid_until, state, data_scope
```

Классификация VERSIONED_TARGET_CAS верна, старой фразы нет. Утверждение :6760 «parent GET returns a strong ETag
of the current Permission revision» ложно: GET единичного Permission на wire нет, а у коллекции свой тег
PermissionList. Арбитр (З-3) замерил то же: «revokePermission 200 (parent GET отсутствует)». Арбитр отверг
«ID и так красный» как основание: «красное с ложным диагнозом — дефект той же тяжести (правило 7)». Поэтому
ложное основание — блокер **Рв993-12**, хотя ID честный. Починка — одна фраза.

## 2. Блокер-файл живьём

`m1.py` — свой регекс по началу строки, а не подсчёт токена:

```
UNRESOLVED lines 46 unique 46   OWNER lines 5 unique 5   overlap un/owner set()
owner ['createPartnerInvitation','getPartnerOverview','listPartnerClients','listPartnerEarnings','getVoiceTranscript']
named 51 equal_to_validator_set True   validator-not-named []   named-not-validator []   empty reasons []
section headers [(27,'## Per-operation classification'), (76,'## OWNER_DECISION_NEEDED: is BACKEND_ADOPTION_PENDING an accepted source?')]
UNRESOLVED line range 29..74 (0-based)   OWNER line range 84..88 (0-based)
distinct (sources,reason) among UNRESOLVED 1
```

Пять OWNER-операций стоят отдельным разделом, вне общего списка, как требует Решение 3. Состав совпадает
с брифом.

У всех 46 строк UNRESOLVED одна и та же пара: «`…/Complior_OpenAPI_5_8_2_Operation_Waves.json` — operation
wave index, not a calling flow». Свой обход 53 файлов `sources/` по границе слова (`m1.py`, контексты —
`m2.py`, `binding`/status — `m3.py`):

```
waves_only 27 (из 51)
UNRESOLVED lines whose op is mentioned beyond waves (19):
 completeUpload createMailboxGrant createPartnerDispute createPartnerGrant createPartnerSalesIntent
 getDataRightsRequest getInsuranceMailbox getManualLetterDelivery getPartnerClient getPartnerStatement
 listMailboxGrants listPartnerGrants logoutSession proposePartnerProgramme provisionInsuranceMailbox
 recordManualLetterDelivery recordOutcomeEvidence revokeMailboxGrant revokePartnerGrant
action_specification[].binding в Alignment (ux1_17_5 и ux1_17_8_2, статус файла …BACKEND_ADOPTION_PENDING):
 createPartnerDispute  PH10 W4_FOLLOWUP_PARTNER_WEB_W2_DEMO_ONLY
 createPartnerGrant    RV07 ADOPTED_OPERATIONS_EXTENSION_PROPOSED; PH07 ADOPTED_OPERATIONS_EXACT_LIFECYCLE_EXTENSION_PROPOSED
 createPartnerSalesIntent PH08 W4_FOLLOWUP_PARTNER_WEB_NOT_W2_EFFECT
 getPartnerClient      PH06 W4_FOLLOWUP_PARTNER_WEB_NOT_EARLY_MOBILE
 getPartnerStatement   PH10 W4_FOLLOWUP_PARTNER_WEB_W2_DEMO_ONLY
 listPartnerGrants     RV07 ADOPTED_OPERATIONS_EXTENSION_PROPOSED; PH07 ADOPTED_READ_EXTENSION_PROPOSED
 revokePartnerGrant    RV07 ADOPTED_OPERATIONS_EXTENSION_PROPOSED; PH07 ADOPTED_OPERATIONS_EXACT_LIFECYCLE_EXTENSION_PROPOSED
остальные 12 — проза actions_and_binding/data_source/refs, напр.:
 completeUpload  "actions_and_binding": "Загрузить письмо → createUpload/completeUpload; …"
 getDataRightsRequest (Mobile_Design_Data, канонический) "automated_scope": "W2 createDataRightsRequest/getDataRightsRequest after handler/security admission."
```

**Рв993-11 (блокер, частично).** Решение 3 требует «UNRESOLVED: <какие источники проверены> — <почему
упоминание не consumer>» и приводит в пример «кадр W4/PROPOSED». В 19 строках (:32, 36–39, 45, 50, 53, 55, 56,
60–64, 66, 67, 71, 72) названный источник и причина объясняют только упоминание в индексе волн. Реальное
упоминание в кадре или в прозе Alignment/Mobile строка не объясняет. Семь из этих операций — кадры
W4/PROPOSED, которые арбитр назвал в З-5 поимённо. Правило 7: отказ обязан говорить правду о своём основании.
Это не новый замысел: формат строки задан арбитром. Починка — переписать 19 строк (или перенести их в
OWNER-раздел) и пересобрать FILES.sha256. Логика валидатора и счёт 51 не меняются.

## 3. README_RU и архитектура §18 — все 6 ID

`m6.py`, регекс по границе слова для каждого из шести ID:

```
README_RU.md                               line 49  ids 6 missing []
Complior_Backend_Architecture_v3_14_RU.md  line 306 ids 6 missing []
section headers [(296,'## 18 Единый транспорт команд'), (307,'## 19 Физические владельцы и события')]
```

Рв993-10 закрыт.

## 4. Валидатор 57, FILES.sha256, verify_handoff

```
PY tests/validate_contract_v3_9.py --out …/out1                        → rc=1
разбор JSON (m1.py): status FAIL_STATIC checks 1491 failures 57 unique 57
by_suffix {'source_consumers': 51, 'cas': 5, 'conditional_policy': 1}
non_consumer ['acknowledgeDisclosure_cas','requestAction_cas','revokeApproval_cas','revokePartnerGrant_cas',
              'revokePartnerGrant_conditional_policy','revokePermission_cas']
sha256sum -c --quiet FILES.sha256                                      → sha_rc=0
wc -l FILES.sha256 = 613; git ls-tree -r HEAD = 614
diff <(git ls-tree -r --name-only HEAD|sort) <(cut -c67- FILES.sha256|sort) → "< FILES.sha256" (единственная разница)
PY tools/verify_handoff.py → {"status": "PASS_STATIC", "schema_documents": 13, "all_manifest_files_and_hashes": "PASS",
                              "runtime_acceptance": "NOT_ASSERTED"}  handoff_rc=0
PY tools/generate_derived.py (копия work/) → gen_rc=0; diff -rq --exclude=.git cback work → пусто (diff_rc=0)
```

57 = 51 + 5 + 1 подтверждено своей мерой. FILES.sha256 свеж. Производные не правлены руками:
`operation-index.json` в круге 4 изменил только `source_sha256`, и регенерация даёт те же байты.

## 5. Зона

```
git diff --stat f7b9729..5fdac96f -- tools/ evidence/ → 11 files changed, 563727 insertions(+), 7 deletions(-)
  evidence/contracts/993/{fix2-mutant-controls.json, handoff-battery-raw.json, probe-battery-raw.json,
    remaining-source-consumers-blocker.txt, validator-baseline-52-consumers.json,
    validator-baseline-honest-remainder.json, validator-baseline-honest-remainder.manifest.json}
  tools/{generate_derived.py, validate_alignment_11782_31422.py, validate_invitation_target_31421.py, verify_handoff.py}
git diff --name-status --diff-filter=D f7b9729..5fdac96f → пусто
git diff --name-status f7b9729..5fdac96f → 25 путей, все во второй ЗОНА implementer контракта
git diff --name-status 31d4b98..5fdac96f → 7 путей (Architecture, FILES.sha256, README_RU, OpenAPI,
  operation-index, blocker.txt, tests/validate_contract_v3_9.py), все в зоне
```

Файловых удалений 0. «7 deletions» — строки внутри правок `tools/` прежних кругов, круг 4 `tools/` не трогает.
Зона чиста.

## Перечень Решения 1 — сверка

`mut.py`: точечная текстовая правка OpenAPI на копии, затем настоящий CLI. Сравнение идёт с контролем 57.
`index_source_sha256` — шум от смены хеша OpenAPI, отфильтрован.

```
control                  rc=1 FAIL_STATIC n=57 +0
m_cond_query             +updatePersonalProfile_cas +updatePersonalProfile_conditional_policy      (V1/C2)
m_cond_drop              +updatePersonalProfile_cas +updatePersonalProfile_conditional_policy      (V1/C2)
m_cond_inm_rejects_star  +updatePersonalProfile_cas +updatePersonalProfile_conditional_policy      (C3)
m_cond_ifm_weakstar      +updatePersonalProfile_cas +updatePersonalProfile_conditional_policy      (V3/C3)
m_add_cond_drop          +revokeAccountSession_cas +revokeAccountSession_conditional_policy        (C2, metadata-dict)
m_prose_drop             +revokeAccountSession_cas +revokeAccountSession_conditional_policy        (Рв993-1 prose)
m_query                  +revokeAccountSession_cas                                                  (V1)
m_ras_optional_inline    +revokeAccountSession_cas                                                  (V2)
m_ras_downgrade          +revokeAccountSession_cas                                                  (A2)
m_wildcard_schema        +44 _cas                                                                   (V3)
m_optional               +44 _cas                                                                   (V2)
m_v4_412_not_problem     +revokeAccountSession_cas +revokeAccountSession_problem                    (V4)
m_revperm_back           n=57 -0: revokePermission_cas остаётся красным                             (A3-ловушка 200)
```

V1–V5 и C1–C3 выполнены. Вариант, где metadata подменяет wire, удалён. A1 и A2 выполнены. A3 не выполнен
(**Рв993-9**):
- `tests/validate_contract_v3_9.py:42–50` — `has_response_etag` определён и не вызывается: имя встречается в
  файле один раз, в `def`. Решение 1 A3: «либо вызывается вместо цикла, либо удаляется. Две грамматики одного
  признака не остаются». Его docstring («2xx… classifier cannot hide a state-transition ETag») расходится с
  циклом `:345–351` (только `'200'`);
- комментарий `:339–340` называет «201 (createHandoff, listPostItems)» и «202 (postMessage, requestAction)».
  Своя мера (`m7.py`): `listPostItems GET /v1/post precondition=None 2xx={'200': False}`,
  `requestAction … precondition=VERSIONED_TARGET_CAS`. Оба примера ложны. Верные примеры — createHandoff 201,
  postMessage 202, logoutSession 204 — в комментарии есть.

## Контракт 050 — паразитная сложность (артефакты круга 4)

- `_resolve_schema` (`:52–59`): (1) V3/C3 требуют разрешения локального `$ref` схемы; (2) состояния нет;
  (3) 1 файл, число не выросло; (4) 2 аргумента, работа — разрешение с None при ошибке; (5) потребители V3/C3.
  Поверх существующего `resolve` добавлен только fail-closed. ESSENTIAL.
- `_schema_rejects_star` / `_schema_accepts_star` (`:61–81`): (1) V3 и C3; (2) состояния нет; (3) 1 файл; (4) при
  ошибке или неразрешимой схеме обе дают False, то есть fail-closed в обе стороны — это не простое отрицание;
  (5) потребители `_cas`, `_conditional_policy`. ESSENTIAL.
- Блок C1–C3 в `_cas` (`:307–321`) и в `_conditional_policy` (`:375–396`): (1) свойство «одни и те же C2–C3 в обеих
  проверках» (Решение 1); (2) состояния нет; (3) правка свойства меняет 2 места, дифф число увеличил с 1 на 2
  (раньше в `_cas` стояло одно условие metadata); (4) интерфейс тот же, работа скопирована; (5) логика
  повторяет соседнюю. **ACCIDENTAL, блокер Рв993-13**: фрагмент назван, отсутствующее свойство — «единый
  источник C1–C3», простая форма — один helper на оба вызова, проходит те же строки приёмки и мутанты.
  Комментарий `:371–374` («`_conditional_policy` does not duplicate them») ложен: `:389–395` проверяют wire C2/C3.
- `has_response_etag` (`:42–50`, раздут удержанием): (1) свойства нет, он не вызывается; (2) нет; (3) вторая
  грамматика признака ETag; (4) интерфейс без работы; (5) потребителя нет. ACCIDENTAL, блокер в составе Рв993-9.
- `remaining-source-consumers-blocker.txt`: (1) Решение 3, Рв993-11; (2) состояние — текст evidence, явное;
  (3) 1 файл + FILES.sha256; (4) н/п; (5) потребитель — владелец (В-1). ESSENTIAL по форме, содержание — Рв993-11.
- Новых флагов, env-переменных и каталогов состояния нет.

## ПРОВОДКА (контракт 038)

Четыре guard-канала (`probe.py`, `handoff_probe.py`, `handoff_models.py`, `coverage_models.py`) существуют в
`fixtures/workshop_project/validator_993/` и байтово равны `frozen/contracts/993/1`. Это барьеры этого
предмета: их потребляют приёмка п.3 и подразделы «Полнота report.checks» и «Handoff CLI».
ПРОВОДКА-ЭНФОРСМЕНТ обоснована: внешний CLI, нормы ролей не меняются. Канал в порядке. Готовность приёмки
п.2/п.3 упирается в В-1.

## Семь пунктов роли

1. **Область.** Зона чиста, см. §5.
2. **Сырой вывод.** Всё выше снято моими командами на C. Implementer приложил в коммите `1d252c0` пересказ
   мутантов. Мои 13 прогонов его подтверждают по V/C.
3. **Проверка не переписана под код.** Батарея H байтово равна тегу. Правки валидатора в круге 4 только
   усиливают его: вариант через metadata удалён, добавлены V3/C2/C3. Ни один прежний красный не позеленел
   (`m_query`, `m_prose_drop`, `m_ras_downgrade`, `m_add_cond_drop`).
4. **Красное предъявлено.** У каждого нового условия V1/V2/V3/V4/C2/C3 есть мой красный мутант (таблица выше).
5. **Атомарность.** Круг 4 — два коммита одной задачи. `5fdac96` удаляет 29 записей FILES.sha256, внесённых в
   `1d252c0`, — churn (А-6, squash при слиянии).
6. **Норма.** Нормативные документы dev-harness не тронуты. §18 архитектуры Complior-back — в зоне владельца.
7. **Счётные утверждения своей мерой:**
   - 57 = 51 + 5 + 1 и 1491 checks — разбор JSON;
   - 46 + 5 = 51 и равенство множеств — регекс по началу строки блокер-файла против failure_ids;
   - 613 + 1 = 614 — diff tracked/manifest;
   - «+44» — разность множеств ID;
   - «19 строк с ложным источником» — независимый обход `sources/`, а не чтение блокер-файла.

## Что нужно для ACCEPT на новом C

Четыре правки в тексте и коде. Счёт 57 и wire не меняются:
- Рв993-9 — удалить `has_response_etag` (или вызвать его вместо цикла), убрать из комментария A3 listPostItems и requestAction;
- Рв993-11 — переписать 19 строк UNRESOLVED фактическим источником и причиной (или перенести их в OWNER), пересобрать FILES.sha256;
- Рв993-12 — убрать «parent GET returns a strong ETag…» из `precondition_basis` revokePermission;
- Рв993-13 — один helper C1–C3 на `_cas` и `_conditional_policy`, исправить комментарий `:371–374`.

После правок приёмки п.2/п.3 всё равно недостижимы без В-1 (Решение 2 п.3). Это 4-й круг из 5: если 5-й
круг даст FAIL, по слову владельца 993 останавливается.
