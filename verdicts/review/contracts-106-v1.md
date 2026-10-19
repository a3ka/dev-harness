FAIL
OBJECT=92e0d99980b07864e65eb1e5e8007dbc08c8f7ee

# Reviewer, круг 1 — контракт 106 (CMP-BCK-133, 5.8.4)

Судья: Rev106r1 (reviewer). База B=0230ee068d10047b1be99c26747aef1bd1579bcf. H: frozen-блоб
`frozen/contracts/106/1` — `git diff frozen/contracts/106/1^{commit} HEAD -- contracts/106-*.md fixtures/workshop_project/spec584_106` пуст
(батарея и контракт после заморозки не менялись). Находки в формате reslop: `review.md` (рядом).

## Итог одной строкой

Машинная часть зелёная (батарея rc 0, 12/12, валидатор PASS_STATIC, lane `package` rc 0), но предмет
§1/§2 «по смыслу каждой операции» и «подтверждённый потребитель» НЕ реализован: CAS-нарративы — один
шаблон на пять операций, условный профиль ложен относительно wire и принят только ослабленным
валидатором, закрытого перечня IDEMPOTENT_TARGET_REVOKE в валидаторе нет, 33 из 51 потребителя
противоречат волне собственной операции, у всех 51 источник — отсутствующий в репозитории файл и нет
статуса принятия.

## Что сходится (своя мера)

| Проверка | Команда | Результат |
|---|---|---|
| Область правки | `git diff --name-only B..OBJECT` | 18 путей; 17 в ЗОНЕ implementer frozen-блоба, 18-й — `tools/validate_invitation_target_31421.py` (допущен консультантом); `git diff --numstat B HEAD -- tools/validate_invitation_target_31421.py` → `3 3` |
| Исходное красное B (крит. 1) | `PY tests/validate_contract_v3_9.py --out bB-out` на B | rc 1, FAIL_STATIC; мой обход JSON: 57 = 5 `_cas` + 51 `_source_consumers` + `revokePartnerGrant_conditional_policy` |
| Батарея на OBJECT (крит. 3) | `PY h/.../probe.py --repo back --out probe-out` | RC=0, `control_green: true, cases 12, rejected 12, mismatches []` |
| Владельческий прогон (крит. 4, без npm) | validate → generate_derived → verify_handoff → validate_alignment → validate_invitation_target → generate_derived | VAL_RC=0 (PASS_STATIC, 1495 checks), GEN_RC=0, `git status --porcelain` = 0 строк, HANDOFF_RC=0, ALIGN_RC=0 (163/19), INV_RC=0, GEN2_RC=0 |
| Lane `package` | `PY tools/run_backend_ci.py --lane package` (одноразовая копия m3) | LANE_RC=0, строка `[package] PASS rc=0 validate_contract_v3_9 (живая команда…)` |
| 163/19 | обход yaml | 163 операции, 19 deprecated; precondition: VERSIONED 49, CREATE_OR_APPEND 32, IDEMPOTENT 1, None 81 |
| FILES.sha256 | свой скрипт: каждая строка ∈ `git ls-tree HEAD` и sha256 совпадает | entries 618, untracked 0, badhash 0; удалённая строка `evidence/ux175/20261018T100915…` на B не существовала в дереве (висячая) — удаление корректно |
| ПРОВОДКА | контракт §ПРОВОДКА | guard `fixtures/workshop_project/spec584_106/probe.py` существует, потребляется крит. 2–3; ПРОВОДКА-ЭНФОРСМЕНТ обоснован (внешний CLI, CI dev-harness без внешнего checkout) — принимаю |

## Находки (блокирующие — с обходом и rc)

Общий обход для F1, F2, F4, F5: **состояние дерева = сам OBJECT**. На нём крит. 1–4 выполнены
(батарея RC=0, валидатор VAL_RC=0, lane LANE_RC=0), а обязательства §1/§2 по смыслу не выполнены —
ровно класс «правдоподобного, но ложного нарратива», который контракт (§Модель угроз, НЕ ЗАЩИЩАЕТ;
крит. 5) отдал судьям.

### F1 [семантика, §1 «Все пять несут x-cas-semantics… по смыслу каждой»; канон §CAS] — шаблон вместо смысла
- Своя мера: `distinct x-cas-semantics among 5: 1` — все пять операций несут побайтно одинаковый mapping.
- `version_source: "ETag или версия из get<Resource> того же scope/principal…"` — буквальный шаблонный плейсхолдер `get<Resource>`.
- Нет ни одного операционного обязательства канона: revokeApproval — различение отзыва неисполненного согласования и отмены уже отправленного действия (нет); requestAction — перечень изменений Mission, делающих команду устаревшей (нет); revokePartnerGrant — перепроверка актуальных полномочий в x-cas-semantics (нет; есть лишь отдельный `x-grant-conditional-prose`).
- revokePermission (IDEMPOTENT_TARGET_REVOKE, `repeat_safe: true`): `stale_version: "412 … при несовпадении If-Match"` и `completed_action: "… 409 IDEMPOTENCY_CONFLICT"` — противоречат выбранной идемпотентной семантике отзыва (повтор отзыва уже отозванного обязан быть безопасным, а не конфликтом).
- `precondition_basis` acknowledgeDisclosure/revokeApproval оставлен: «the required strong target If-Match is not declared on the wire – honest missing target CAS» при `If-Match required: true` — текст противоречит wire.
- `contracts/backend-5_8_4-alignment.json` заявляет для requestAction «уточнён перечень изменений Mission, делающих команду устаревшей» — такого перечня в дереве нет: ложное заявление поставки.
- rc на OBJECT: probe RC=0, VAL_RC=0.

### F2 [семантика, §1 requestAction; канон «чтобы фоновые события не создавали бессмысленных конфликтов»] — снят carve-out безопасной остановки
- Diff OpenAPI requestAction: `If-Match required: false → true`; удалено описание «Для безопасного pause_work/stop_work можно без ETag; snapshot не блокирует немедленную остановку новых dispatch», заменено общим «false=>412».
- Та же спецификация, `ActionRequest` (строки 28845–28846 OBJECT): «pause_work/stop_work монотонно запрещают новые эффекты и принимаются даже при устаревшем snapshot» — прямое внутреннее противоречие: wire теперь требует If-Match и обещает 412 на устаревшую версию для stop_work.
- Это смена семантики остановки ради зелёного `_cas`, без перечня «какие изменения Mission делают команду устаревшей».
- rc на OBJECT: probe RC=0, VAL_RC=0.

### F3 [§1 «IDEMPOTENT_TARGET_REVOKE разрешено ТОЛЬКО для revokePermission (замкнутый перечень в валидаторе и в батарее)»] — в валидаторе перечня нет
- Код: `PRECONDITIONS` дополнен значением, ветка `elif precondition=='IDEMPOTENT_TARGET_REVOKE'` не проверяет operationId.
- Обход (мутант судьи m1, `mut_idem.py`): копия OBJECT, revokeApproval `precondition: VERSIONED_TARGET_CAS → IDEMPOTENT_TARGET_REVOKE` + `server_recheck{resource,scope}` + `repeat_safe: true`, `generate_derived` rc 0 (applied True). Валидатор: **rc 0, PASS_STATIC, failures []**. Обязательный lane `package` на m1: **LANE_M1_RC=0**. Батарея на m1: RC=1 (`CAS_PROFILE:revokeApproval:precondition=IDEMPOTENT_TARGET_REVOKE`).
- Т.е. единственный постоянный барьер в Complior-back (обязательный CI, §4) пропускает снятие CAS с любой операции; ловит только батарея dev-harness, которой в CI нет (ПРОВОДКА-ЭНФОРСМЕНТ). Обязательство «перечень в валидаторе» не исполнено.

### F4 [§1 «условный профиль — проверяемая структура»; ревью п.3 «проверка не переписана под реализацию»] — ложный профиль, принятый ослабленным валидатором
- Все 5 операций получили `x-conditional-policy` с `initial_create: {header: If-None-Match, value: '*', precondition: TARGET_ABSENT|GRANT_ABSENT}`, `missing_or_both: 428`, `exactly_one_conditional_header: true`; своя мера: 4 из них (кроме revokePartnerGrant) побайтно одинаковы (`distinct … 1`). На wire ни у одной из пяти нет If-None-Match (замер: `{'If-Match': True}`); у отзыва/ознакомления/requestAction нет «initial create» вообще.
- Валидатор: новая ветка для `If-Match required=true` заменяет проверку 993 C1–C3 (`_check_conditional_profile`, арбитраж Decision 1) проверкой наличия ключей. Мутант судьи m2 (`mut_relax.py`: ветка отключена) → **validator rc 1**, `acknowledgeDisclosure/requestAction/revokeApproval/revokePermission/revokePartnerGrant_conditional_policy`. Профиль принят только потому, что проверку подогнали под реализацию; «проверяемая структура» описывает несуществующий wire-контракт.
- rc на OBJECT: VAL_RC=0.

### F5 [семантика, §2 «конкретный сценарий, роль, источник, волна и статус принятия»; канон §Потребители] — потребители не подтверждены
- Своя мера по `workflow_consumers` для 51 операции: 51 запись, ключи у всех = `automatic_on_entry, guard, kind, operation_id, owner, phase, source_ref, wave` — **поля статуса принятия нет ни у одной**.
- `source_ref` у всех 51 = `docs/owner/2026-10-18-arhitektor-beka-5-8-4.md#Потребители`; в Complior-back `docs/owner` отсутствует (`ls: cannot access 'docs/owner'`), а сам документ — указание «где искать», не подтверждение.
- Волна: **33 из 51** `wave` противоречат `x-delivery-wave` собственной операции. Партнёрские (канон: «волны и статус доступности сохраняются»): getPartnerOverview W1a против W2, listPartnerEarnings W1a против W2; getVoiceTranscript `wave: "W29"` — это id виджета, волна операции W2; getGroupMetrics W5 против W4; почтовые 10 — W1a против W1b; finance/import — W1a против W4.
- Литерал `mobile lifecycle/service` (канон: «подписка SSE без экрана») назначен 16 операциям, включая экранные пользовательские сценарии: getDataRightsRequest (guard сам говорит «экран»), acknowledgeDisclosure, revokeApproval, updateAgentProfile, requestApplicationSubmission (канон: «оркестрация и workflow подачи»), createActionPlan — литерал использован ровно для того, чтобы не находить экраны/действия.
- recordManualLetterDelivery: канон «с точным указанием исполнителя» — guard переписывает фразу канона, исполнитель не назван (owner `manual-letter-delivery`).
- getInbox: не назначен источником Post — соблюдено; партнёрские 4 и getVoiceTranscript — запись есть, но с волнами/источником выше.
- rc на OBJECT: probe RC=0, VAL_RC=0.

## Советы (не блокируют)

- A1. `workflow_consumers` 51 запись вписаны руками прямо в `contracts/frontend-consumer-bindings.json` (генератор читает секцию из самого файла, `tools/generate_derived.py:8,131`). Совместимо с грамматикой 993, но буквально расходится с §3 «реестр вручную не редактируется» — вопрос архитектору/владельцу, где нормативный источник этой секции.
- A2. `tools/run_backend_ci.py`: после замены плейсхолдера ни один builtin не возвращает `rc=None`, ветка `'SKIPPED'` и условие `rc not in (0, None)` — мёртвая форма, в которой будущий `None` молча зелёный. Проще: убрать None-ветку (None → FAIL).
- A3. Атомарность: 808f2b4 смешивает §1 (x-conditional-policy), §4 (статус раннера) и evidence; 1632e79 смешивает версию и CAS.
- A4. VERSION_MANIFEST: VS01 переморожен (sha 7d5c…→09e3…) с переименованием прежнего ключа `re_freeze_provenance` → `re_freeze_provenance_history` — история переразмечена; подтвердить у владельца (change_policy VS01).
- A5. Evidence `evidence/contracts/106/probe-raw.json` снят на более раннем дереве («Handoff hashes rebuilt: 617 files» против 618 на OBJECT); к финальному SHA не привязан — переснять на итоговом C.
- A6. `backend-5_8_4-alignment.json`: `baseline_openapi: "5.8.2"`, `authority` — путь, которого нет в репозитории; `callers.web` относит почтовый workflow к web, а bindings — к `workflow`.

## Паразитная сложность (контракт 050)

- `contracts/backend-5_8_4-alignment.json`: (1) §3 alignment-файл; (2) состояние явно, файл; (3) +1 файл при правке версии (заменяет 5_8_3 — ESSENTIAL); (4) данные; (5) потребители — validate_alignment, батарея. ESSENTIAL.
- Ветка `IDEMPOTENT_TARGET_REVOKE` валидатора: (1) §1 третье значение; (2) нет состояния; (3) 1 файл; (4) мелкая, но достаточная; (5) потребитель — lane `package`. ESSENTIAL по наличию, неполна по перечню (F3).
- Ветка ослабленного `_conditional_policy`: (1) свойства контракта не называет — контракт требует проверяемую структуру, а ветка снимает проверку C1–C3; (2) нет; (3) 1; (4) интерфейс без работы; (5) потребитель — только зелень на ложных данных. ACCIDENTAL; блокирует через F4 (фрагмент, отсутствующее свойство, более простая форма — убрать ложный initial_create/If-None-Match из профиля и оставить проверку 993).
- Builtin `@validate-out`: (1) §4 живая команда; (2) каталог `validate-<ts>` в `--out`, явно; (3) 1; (4) норм.; (5) lane `package`, клетка `lane_swallows_validator_red`. ESSENTIAL (проще — список-команда без builtin, совет).
- `evidence/contracts/106/`: (1) §3; (2) файлы; (3) переснимаются целиком; (4) —; (5) FILES.sha256/verify_handoff. ESSENTIAL.

## Сырые команды (cwd, rc)

```
git clone -q /tmp/dev-harness-verify/Impl106/back back && git -C back checkout -q 92e0d999…   # exit=0
git diff --stat B..HEAD (back)                                                                  # 18 files
git diff --numstat B HEAD -- tools/validate_invitation_target_31421.py                          # 3 3
PY h/fixtures/workshop_project/spec584_106/probe.py --repo back --out probe-out                 # RC=0 {"control_green": true, "cases": 12, "rejected": 12, "mismatches": []}
(back) PY tests/validate_contract_v3_9.py --out run-obj/val                                      # VAL_RC=0 PASS_STATIC checks 1495
(back) PY tools/generate_derived.py ; git status --porcelain | wc -l                             # GEN_RC=0 ; 0
(back) PY tools/verify_handoff.py                                                                # HANDOFF_RC=0
(back) PY tools/validate_alignment_11782_31422.py                                                # ALIGN_RC=0 operations 163 deprecated 19
(back) PY tools/validate_invitation_target_31421.py                                              # INV_RC=0
(back) PY tools/generate_derived.py                                                              # GEN2_RC=0
(m3)   PY tools/run_backend_ci.py --lane package --out lane-out                                  # LANE_RC=0
(bB=B) PY tests/validate_contract_v3_9.py --out bB-out                                           # B_RC=1; 57 = 5 _cas + 51 _source_consumers + revokePartnerGrant_conditional_policy
PY mut_idem.py m1 revokeApproval                                                                 # applied True; generate_derived rc 0; validator rc 0 PASS_STATIC
(m1)   PY tools/run_backend_ci.py --lane package --out lane-m1                                   # LANE_M1_RC=0
PY probe.py --repo m1 --out probe-m1                                                             # RC=1 CAS_PROFILE:revokeApproval:precondition=IDEMPOTENT_TARGET_REVOKE
PY mut_relax.py (m2: ослабляющая ветка отключена)                                                # validator rc 1, 5 × *_conditional_policy
```

Скрипты мутантов судьи: `/tmp/dev-harness-verify/Rev106r1/mut_idem.py`, `/tmp/dev-harness-verify/Rev106r1/mut_relax.py`.
npm ci/npm test и Android не гонялись (вне scoped-прогона судьи).
