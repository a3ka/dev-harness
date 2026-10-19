FAIL
OBJECT=55dac5a0068877d6295dee027b899cccf2d16c42

# Вердикт reviewer — контракт 106 (CMP-BCK-133, Complior-back 5.8.4), круг 3 (последний по капу)

Судья: Rev106r3 (reviewer). База B `0230ee068d10047b1be99c26747aef1bd1579bcf`; предыдущий OBJECT `76f7da435e023543ec6649a7d24f05a4180a953d`.
Контракт: `contracts/106-cmp-bck-133-spec-5-8-4.md` (`frozen/contracts/106/1`, правок после тега нет: `git diff frozen/contracts/106/1 HEAD --stat` пуст).
Батарея: j2 `/tmp/dev-harness-worktrees/c907157c/wip-106-architect-j2/fixtures/workshop_project/spec584_106/probe.py` (sha256 `2b7eac14…9c42`; последний коммит `32997af93` architect-j2 2026-10-19 16:10 — до круга 2, автором реализации не менялась; рабочее дерево чистое).
Находки — reslop: `review.md` (рядом).

## Механика (всё зелёное — мои прогоны на OBJECT)

| команда (cwd=клон OBJECT) | rc | вывод |
|---|---|---|
| `PY tests/validate_contract_v3_9.py --out …/val-out` | 0 | `PASS_STATIC`, checks 1495, negative_cases 28, examples 251, failures [] |
| `PY probe.py --repo R --out …/probe-out` | 0 | `control_green: true, control_reds: [], cases: 27, rejected: 27, mismatches: []` |
| `PY tools/generate_derived.py` → `git status --short` | 0 | пусто (no-op; включая `contracts/wire-5_8.schema.json`) |
| `PY tools/verify_handoff.py` | 0 | `PASS_STATIC`, schema_documents 13 |
| `PY tools/validate_alignment_11782_31422.py` | 0 | operations 163, deprecated 19 |
| `PY tools/validate_invitation_target_31421.py` | 0 | `BACKEND INVITATION TARGET 3.14.2.2 PASS` |
| `sha256sum -c --quiet FILES.sha256` | 0 | — |
| `PY tools/run_backend_ci.py --lane package --out …/lane-out` | 0 | 6 шагов PASS, `validate_contract_v3_9 (живая команда…)` rc=0 |
| мутанты m3/m4/m5 (`mut.py`, копия дерева, правка профиля) | 1/1/1 | `revokePartnerGrant_conditional_policy` ×2, `revokePermission_conditional_policy`; контроль той же сборки rc 0 |

Своя мера счётов: yaml 163/19, operation-index 163/19, `info.version` 5.8.4; 51/51 операций перечня имеют workflow-потребителя с source_ref, лишних нет; ссылок на удалённый `consumers-5_8_4.md` — 0; manifest evidence = фактические sha256 трёх файлов.

## Область правки

20 путей B..OBJECT. 18 — в ЗОНЕ implementer; `tools/validate_invitation_target_31421.py` — ровно 3 строки версии (docstring, проверка manifest, сообщение); `contracts/wire-5_8.schema.json` — 1 строка, повтор генератора no-op (чистое производное). Breach нет.

## Блокирующие находки (обход: OBJECT — валидатор rc 0, батарея 27/27, предмет не сделан)

**R3-F1 (CAS revokeApproval / R2-F1(г) по смыслу).** `x-cas-semantics.completed_action`: «отклоняется 409 с именованной причиной APPROVAL_ACTION_ALREADY_DISPATCHED»; код добавлен в `x-reason-codes` (1093d24). `Problem.code` → `ReasonCode` — закрытый enum из 34 значений, кода в нём нет. Своя мера по всем 163 операциям: единственный `x-reason-code`, который wire `Problem` не принимает.
`PY reason.py <C>` → `UNREPRESENTABLE_REASON ['revokeApproval:APPROVAL_ACTION_ALREADY_DISPATCHED']`, rc 1; тот же скрипт против wire-схемы B → `none`, rc 0. Значит, различающий 409 по поставленному wire отправить нельзя. Простая форма, которая проходит те же строки приёмки: добавить код в `ReasonCode` (прецедент — `ADMISSION_DECISION_ALREADY_RECORDED`) и перегенерировать.

**R3-F2 (§2 / канон §Потребители «ручная доставка с точным указанием исполнителя»; R2-F5).** recordManualLetterDelivery: `owner` = «internal worker записи самоотправления (worker-owned immutable artifact)», guard «Worker-процесс записывает…»; alignment `callers.workers`: «manual-letter-delivery: recordManualLetterDelivery, getManualLetterDelivery». Канон не меняли с B: OpenAPI `x-role-policy: ['authenticated_customer']` («Record exact customer-reported self-send»); `contracts/backend-ui-workflows.json` `BUI.LETTER.REPORT_MANUAL_DELIVERY` с `owner: MOBILE_CLIENT`, `mobile_callable: true` и шагом REPORT_MANUAL_DELIVERY в потоке F40.A01–A03; строка Alignment «сообщить о самостоятельной отправке → recordManualLetterDelivery». «worker-owned» в OpenAPI говорит о владельце артефакта, а не о вызывающей стороне. Названный исполнитель — неверный. getManualLetterDelivery в alignment записан под workers, а в собственном потребителе — «scoped self-read клиента»: файл противоречит сам себе.

**R3-F3 (§2 «источник»; канон «запись "используется backend" недостаточна»; R2-F5).** 19/51 source_ref указывают на `sources/frontend-ux1_17_8_2/Complior_OpenAPI_5_8_2_Operation_Waves.json`, а это `derived_read_only: true`, `source: backend 3.14.2.2/contracts/BrokerOS_Unified_OpenAPI_v3.yaml` — таблица волн всех 163 собственных операций бэкенда, включая 19/19 deprecated. Ссылка подтверждает только, что операция существует и имеет волну. Тот же якорь «подтвердил» бы и deprecated `createPlateOrder`, так что потребителя он не различает: источник круговой. Список: getInbox, streamMissionEvents, getMemoryChange, getAgentProfile, updateAgentProfile, registerDevice, createVoiceSession, createActionPlan, ingestCommissionCash, createSettlementBatch, getInternalCaseQueue, getInternalAgentRun, createImportBatch, acceptImportBatch, getCommissionFindings, getGroupMetrics, getProviderInvocation, reconcileProviderInvocation, getInsuranceMailDraft. Для getInbox в дереве B есть настоящий UX-источник: `contracts/widget-catalog.json` scope_note «W1a: Mission/input tasks и сообщения дела через getInbox/…»; guard же утверждает, что у getInbox есть только «строка таблицы волн». Простая форма: сослаться на реальный источник (архитектура v3_14, backend-ui-workflows, widget-catalog, vocabulary-mappings) либо честно указать статус отложения.

## Закрыто по существу (сверка по канону)

- R2-F1 (а) revokePermission: If-Match, 412/428 и PRECONDITION_FAILED сняты; IDEMPOTENT_TARGET_REVOKE с `server_recheck.resource/scope` и `repeat_safe: true`; HEALTH не требуется; профиль без условных заголовков. (б) If-Match-описания: «повтор — идемпотентный 200, изменившийся запрос — 409 IDEMPOTENCY_CONFLICT»; у requestAction объявлен 200. (в) revokePartnerGrant: ETag из 201 createPartnerGrant (заголовок есть), version/permissions_version из item listPartnerGrants (поля есть). Остаток — совет A1. (г) см. R3-F1.
- R2-F2: carve-out `x-if-match-required-except-action-kinds: [pause_work, stop_work]` возвращён на уровень операции, как на B; ActionRequest (OpenAPI/wire/mock): «принимаются при устаревшем snapshot»; mission_invalidators: facts, goal, rights, prepared_inputs плюс not_invalidators.
- R2-F4: ветки V2, IDEMPOTENT и C1–C3 закрыты; ослабляющей ветки нет; m3/m4/m5 → rc 1 с именованной причиной.
- R2-F5, закрытые части: поддоч удалён; getDataRightsRequest — frame F44.05 (designer_integration F44 называет операцию); getVoiceTranscript — виджет W29 (`full_transcript: getVoiceTranscript`); getInbox не назначен источником Post; партнёрские 4 — partner; getGroupMetrics — `deferred_5_8_4`, не deprecated; литерал `mobile lifecycle/service` у 4 операций; волна потребителя = x-delivery-wave у 51/51.

## Ограничения исполнителя
Pending-файл целиком не принят: 17 ссылок на строки, а не на файл (совет A4). Семантика отзыва не подогнана под валидатор. Массового deprecated нет (19/19).

## ПРОВОДКА / 050 / атомарность
- guard `probe.py` существует, это барьер именно этого предмета, прогон rc 0.
- 050: `_collect_profile_headers`, `_check_conditional_profile_v2`, `_check_conditional_profile_idempotent` — ESSENTIAL (§1 «условный профиль — проверяемая структура»; m3/m4/m5 без них не ловятся; состояние явно — failure_id; потребитель — строка приёмки 1/3 и lane package). `@validate-out` — ESSENTIAL (§4 «живая команда»; свежий --out виден в выводе lane; потребитель — lane package). `backend-5_8_4-alignment.json` — ESSENTIAL (§3); новых флагов и env нет.
- Атомарность: круг 3 разбит по находкам на 5 коммитов (1093d24 связывает R2-F1 и R2-F2 — приемлемо, общий предмет CAS).

## Советы (не блокируют)
- A1: revokePartnerGrant `x-grant-conditional-prose.expected_version` — «(например, getPartnerGrant)»: такой операции в 163 нет; это противоречит исправленному version_source (остаток R2-F1(в)).
- A2: requestAction `x-conditional-policy` («exactly_one_conditional_header: true», «missing → 428») не отражает carve-out; `version_source` «обязан совпадать с текущей версией миссии» спорит с `not_invalidators` о смене snapshot_version.
- A3: alignment — revokePermission `changed_request_requirements` повторяет закрытый выбор и не называет выбранный (б); `callers.mobile` подаёт 16 операций как литерал, а в реестре их 4; getGroupMetrics «W5», а x-delivery-wave W4; `vs01_refreeze` «hash не менялся», а VERSION_MANIFEST 7d5c…→09e3…; `baseline_openapi` 5.8.2; вызывающие requestAction (6 мобильных action) не названы.
- A4: 17 потребителей ссылаются на строки файла со статусом `UX1_15_…_BACKEND_ADOPTION_PENDING`: построчно, не целиком, но подтверждение — сама pending-строка.
- A5 (R2-A2): `run_backend_ci.py` `rc not in (0, None)`: rc None проходит lane молча; сейчас None не возвращает ни один builtin.
- A6 (R2-A1): workflow_consumers — ручная секция производного bindings; вопрос архитектору о нормативном источнике.

## Сырые команды
```
git clone /tmp/dev-harness-verify/Architect106r3/back back && git checkout 55dac5a0068877d6295dee027b899cccf2d16c42
PY=/tmp/dev-harness-verify/Rev106r2/venv/bin/python
$PY tests/validate_contract_v3_9.py --out /tmp/dev-harness-verify/Rev106r3/val-out            # rc 0
$PY <j2>/probe.py --repo /tmp/dev-harness-verify/Rev106r3/R --out /tmp/dev-harness-verify/Rev106r3/probe-out   # RC=0
$PY tools/generate_derived.py; git status --short                                             # rc 0, пусто
$PY tools/verify_handoff.py; $PY tools/validate_alignment_11782_31422.py; $PY tools/validate_invitation_target_31421.py  # 0/0/0
sha256sum -c --quiet FILES.sha256                                                              # 0
$PY tools/run_backend_ci.py --lane package --out /tmp/dev-harness-verify/Rev106r3/lane-out    # 0
$PY -W ignore /tmp/dev-harness-verify/Rev106r3/mut.py                                          # ctrl 0; m3/m4/m5 rc 1
$PY -W ignore /tmp/dev-harness-verify/Rev106r3/reason.py <C>                                   # rc 1 (R3-F1)
$PY -W ignore /tmp/dev-harness-verify/Rev106r3/reason.py <B wire>                              # rc 0
$PY /tmp/dev-harness-verify/Rev106r3/anchors.py <C>                                            # 51 якорей есть на B
```
