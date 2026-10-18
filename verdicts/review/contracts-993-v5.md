FAIL
OBJECT=0230ee068d10047b1be99c26747aef1bd1579bcf

# Ревью 993, круг 5 (последний): CMP-BCK-121 validator 5.8.3, a3ka/Complior-back PR#146

- Роль: reviewer (Reviewer993R5), 2026-10-18. Семейство: не семейство автора.
- C = `0230ee068d10047b1be99c26747aef1bd1579bcf`. `git ls-remote` ветки `cmp-bck-121/validator-5-8-3` = C;
  `gh pr view 146` headRefOid = C, state OPEN.
- Клон: `git clone ssh://git@github.com/a3ka/Complior-back.git /tmp/dev-harness-verify/reviewer993r5/repo`,
  checkout C. Первая попытка дала `ERROR: Repository not found` (rc 128), сразу после этого `ssh -T` ответил
  «Hi a3ka», `git ls-remote` прошёл, повторный clone прошёл. Сбой был разовым.
- venv: `/tmp/dev-harness-verify/rv993/venv` (requirements-validation.txt).
- Мои меры: `m1.py` (обход `sources/`), `mut5.py` (мутанты на копии `work/`, CLI настоящий), копия
  `gen/` для регенерации, worktree `w4` = 5fdac96 для сравнения.
- H: `git diff --stat frozen/contracts/993/1 HEAD -- fixtures/workshop_project/validator_993/
  contracts/993-cmp-bck-121-validator-5-8-3.md` → пусто (rc 0). Батареи не трогали.
- Решение 1 (а)–(в) арбитра не переоткрываю. Новые классы находок не открывал: круг последний.

Вердикт относится только к этому OBJECT. Новый C его не наследует.

## Итог

| # | Находка | Класс | Статус | Блокирует |
|---|---|---|---|---|
| Рв993-9 | A3: `has_response_etag` и комментарий | пункт A3 Решения 1 | ЗАКРЫТО | нет |
| Рв993-11 | 19 строк UNRESOLVED | пункт Решения 3 / правило 7 | ЗАКРЫТО по тексту строк; пересборка FILES.sha256 сломана — см. Рв993-14 | см. Рв993-14 |
| Рв993-12 | OpenAPI:6760 «parent GET…» | ложный факт wire-метаданных | ЗАКРЫТО | нет |
| Рв993-13 | дубль C1–C3 | 050 ACCIDENTAL | ЗАКРЫТО | нет |
| **Рв993-14** | FILES.sha256 ссылается на файл, которого нет в C; `verify_handoff.py` rc1, `handoff_probe.py` rc2 | регрессия пункта v4 §4 и Решения 2 п.1 («FILES.sha256 пересобран»); нарушено условие владельца в §Зоны контракта; заявленное ≠ сделанному | **новое, регрессия круга 5** | **да** |
| В-1 | 57 именованных отказов | блокер владельца | честный остаток, подтверждён | держит слияние, вина не implementer |
| В-2 | CI `backend`/`required` | чужая зона | вне 993 | нет |
| А-6 | churn-коммиты | совет | squash при слиянии | нет |
| Ф-1 | push C через HTTPS-токен | факт процесса | записан | нет (код не затронут) |

## Находки (reslop)

---
status: ready
object: 0230ee068d10047b1be99c26747aef1bd1579bcf
---

- [ ] **Рв993-14 (блокер).** В `FILES.sha256:487` стоит запись
  `28ac87f6…  evidence/ux175/20261018T100915.689049Z/results.json`. В коммите C этого файла нет: он не в
  `git ls-tree`, не в .gitignore (`git check-ignore` rc 1). Поставляемый CLI на свежем клоне C:
  `tools/verify_handoff.py` → rc1, `AssertionError: evidence/ux175/20261018T100915.689049Z/results.json`.
  Замороженная guard-батарея `handoff_probe.py` → rc2 `993 HANDOFF_UNMEASURABLE: BASELINE_NOT_GREEN`.
  На 5fdac96 (круг 4) `verify_handoff.py` давал rc0, то есть регрессию внёс коммит 0230ee0.
  `tools/generate_derived.py` на копии C отрабатывает с rc0, но меняет `FILES.sha256` (-1 строка, ровно эта
  запись), и после этого `verify_handoff` даёт rc0. Значит, закоммиченный FILES.sha256 не является выводом
  генератора на поставленном дереве. Это противоречит фразе коммита «FILES.sha256 regenerated via
  tools/generate_derived.py».
  Нарушены: условие владельца в §Зоны контракта («финальный FILES.sha256 должен ссылаться только на
  поставленные файлы»); пункт Решения 2 п.1 арбитра «Рв993-11: … FILES.sha256 пересобран»; мера v4 §4
  («FILES.sha256 свеж», `sha_rc=0`, `handoff_rc=0`); правило роли 7.
  Источник: файл создан локальным прогоном `verify_ux175` в `/tmp/dev-harness-verify/impl993fix5/repo`.
  Implementer видел эту запись: в его транскрипте, строки 528–570, есть `grep "evidence/ux175/20261018"
  FILES.sha256`. Коммит прошёл без самого файла.
  Починка — одно из двух: (а) пересобрать FILES.sha256 на чистом дереве (`generate_derived.py` без
  локального ux175-прогона); (б) поставить этот файл как evidence по условию владельца.
- [x] Рв993-9 закрыт (живьём, ниже).
- [x] Рв993-11 закрыт по содержанию 46 строк (живьём, ниже).
- [x] Рв993-12 закрыт.
- [x] Рв993-13 закрыт.

## 1. Зона по реальному merge-base

```
git merge-base origin/main C = f7b972913ec2af0df83ce58ea34dd688870fb0e9 (= origin/main)
git diff --stat 5fdac96 C → 5 files changed, 72 insertions(+), 92 deletions(-)
  FILES.sha256 | contracts/BrokerOS_Unified_OpenAPI_v3.yaml | contracts/operation-index.json |
  evidence/contracts/993/remaining-source-consumers-blocker.txt | tests/validate_contract_v3_9.py
git diff --name-status --diff-filter=D f7b9729 C → пусто
git diff --name-only f7b9729 C → 25 путей, все во второй ЗОНА implementer; backend/ не тронут
```

Зона чиста. Это круг 5 точечных правок: 5 файлов, как объявлено.

## 2. Валидатор, остаток 57

```
PY tests/validate_contract_v3_9.py --out …/out1 → validator_rc=1
разбор JSON: status FAIL_STATIC runtime NOT_RUN_BY_THIS_VALIDATOR checks 1491 failures 57 unique 57
{'source_consumers': 51, 'cas': 5, 'conditional_policy': 1}
non-consumer: ['acknowledgeDisclosure_cas','requestAction_cas','revokeApproval_cas','revokePartnerGrant_cas',
               'revokePartnerGrant_conditional_policy','revokePermission_cas']
blocker-файл: named 51, равенство множеству *_source_consumers валидатора: True
```

57 = 51 + 5 + 1 подтверждено своей мерой (разбор JSON, а не stdout автора). Остаток честный. Это В-1.

## 3. FILES.sha256 / handoff (Рв993-14)

```
sha256sum -c --quiet FILES.sha256
  sha256sum: evidence/ux175/20261018T100915.689049Z/results.json: No such file or directory
  sha_rc=1
PY tools/verify_handoff.py
  AssertionError: evidence/ux175/20261018T100915.689049Z/results.json
  handoff_rc=1
git ls-tree -r HEAD | wc = 614; FILES.sha256 строк = 614
diff <(ls-tree sorted) <(cut -c67- FILES.sha256 sorted):
  < FILES.sha256
  > evidence/ux175/20261018T100915.689049Z/results.json
git check-ignore -v …results.json → ci_rc=1 (не игнорируется — просто не закоммичен)
git show 5fdac96:FILES.sha256 | grep -c ux175 → 7
w4 (= 5fdac96): PY tools/verify_handoff.py → {"status": "PASS_STATIC", …} handoff_rc_5fdac96=0
gen (копия C): PY tools/generate_derived.py → "Derived consumers, wire and 10-route mock rebuilt",
  "Handoff hashes rebuilt: 613 files", gen_rc=0; git diff --stat → FILES.sha256 | 1 -
  затем PY tools/verify_handoff.py → PASS_STATIC, handoff_after_regen_rc=0
PY H/fixtures/workshop_project/validator_993/handoff_probe.py --repo R(C) --out …/handoff-C
  993 handoff case=corrupt-outside-db rc=1 expected=1 matched=True
  993 handoff case=corrupt-014 rc=1 expected=1 matched=False
  993 handoff case=missing-file-outside-db rc=1 expected=1 matched=True
  993 handoff case=missing-file-014 rc=1 expected=1 matched=False
  993 HANDOFF_UNMEASURABLE: BASELINE_NOT_GREEN
  handoff_probe_rc_C=2
PY H/…/handoff_probe.py --repo w4(=5fdac96) --out …/handoff-5fdac96
  993 handoff case=missing-file-outside-db rc=1 expected=1 matched=True
  993 handoff case=missing-file-014 rc=1 expected=1 matched=True
  993 handoff cases=46 mismatches=0 baseline_green=True
  handoff_probe_rc_5fdac96=0
gh pr checks 146: package (валидаторы комплекта 3.14.2.2) fail; checks/historical/image/postgres pass;
  backend/required fail (В-2). В круге 4 adversary записал package зелёным. Лог package прочитать не удалось:
  gh run view --log → "open /tmp/gh-cli-cache/…zip: permission denied". Связь падения package с Рв993-14 — [INFERENCE].
```

## 4. Рв993-9: A3

- `has_response_etag` (`:42–51`) теперь вызывается: `:353 versioned_etag=has_response_etag(api,op,status_prefix='200')`.
  Цикл `status!='200'` удалён. `grep ETag` по файлу: других проверок ETag-признака в коде нет, грамматика одна.
  Решение 1 A3 «либо вызывается вместо цикла, либо удаляется» выполнено.
- Эквивалентность: `startswith('200')` против `=='200'`. Все 1784 ключа статусов в OpenAPI в кавычках
  (`^ {8}[0-9]{3}:` без кавычек — 0), так что int-ключей на wire нет.
- Комментарий `:343–352` говорит «only 200», примеры createHandoff 201, postMessage 202, logoutSession 204.
  Своя мера:
  ```
  createHandoff POST /v1/missions/{mission_id}/handoffs CREATE_OR_APPEND_NO_TARGET_CAS {'201': True}
  postMessage   POST /v1/missions/{mission_id}/messages  CREATE_OR_APPEND_NO_TARGET_CAS {'202': True}
  logoutSession POST /v1/session/logout                  CREATE_OR_APPEND_NO_TARGET_CAS {'204': True}
  ```
  Ложных примеров (listPostItems, requestAction) больше нет. Это совпадает с З-3 арбитра.
- Живой красный A3 и его граница (мутанты ниже). `m_revperm_back` (revokePermission →
  CREATE_OR_APPEND, 200 + ETag + `{permission_id}`) остаётся красным. `m_revperm_back_201` (то же, но 200→201)
  `revokePermission_cas` снимает. Ловит именно ветвь has_response_etag('200'), и ровно в объявленной границе
  «only 200» — это допуск (а) арбитра, не обход.

## 5. Рв993-13: C1–C3

`_check_conditional_profile(api,op,headers)` (`:53–76`) — единственное место C1–C3. Вызовы: `_cas`
`:331` и `_conditional_policy` `:376`. Обе прежние копии удалены (дифф −42 строки). Семантика сверена
построчно: `if_match` в старом `_cas` = `headers.get('If-Match')`, как в helper. Ложная фраза «does not
duplicate them» удалена. Новый комментарий `:371–375` верен. Неточность из совета: «only re-validates the
closed profile shape», хотя helper проверяет и wire C2/C3. Все C-мутанты красные в обеих проверках, см. ниже.

## 6. Рв993-12: OpenAPI:6760

```
git grep -n -i "parent GET" C -- contracts/BrokerOS_Unified_OpenAPI_v3.yaml | grep -i permission → rc=1, пусто
C:6760 precondition_basis: "termination of an existing versioned target: the operation targets a concrete
  permission_id and the Permission resource's own 200 carries the strong ETag that must be presented via If-Match; …"
своя мера (все 2xx со schema Permission):
  createPermission POST /v1/permissions 201 Permission ETag=True "Strong current changed/created resource ETag…"
  revokePermission POST /v1/permissions/{permission_id}/revocations 200 Permission ETag=True (то же описание)
  revokePermission params: permission_id, Idempotency-Key, X-Scope-Id, X-Command-Id, X-BrokerOS-Contract,
    X-CSRF-Token, X-BrokerOS-Catalog   (If-Match нет)
```

Ложной фразы о parent GET больше нет. «Permission resource's own 200 carries the strong ETag» верно на wire:
200 со схемой Permission объявляет strong ETag. «must be presented via If-Match» — нормативное требование.
На wire If-Match нет, отсюда честный красный `revokePermission_cas` (остаток). Фраза согласована с :6759.

## 7. Рв993-11: блокер-файл — сверка каждой строки с источником

Обход `m1.py`: 53 файла `sources/` плюс `contracts/frontend-consumer-bindings.json`, operationId по
границе слова, с JSON-путём каждого вхождения:

```
UNRESOLVED 46 OWNER 5 overlap set()
UNRESOLVED waves-only 27; UNRESOLVED beyond-waves 19
lines citing waves-only reason 27
waves-reason but mention beyond: []
non-waves-reason but no mention beyond: []
bindings mentions: {}
```

**27 строк «только индекс волн»** — acceptImportBatch, acknowledgeDisclosure, createActionPlan, createImportBatch,
createInsuranceMailDraft, createSettlementBatch, createVoiceSession, dispatchInsuranceMailDraft, getAgentProfile,
getCommissionFindings, getGroupMetrics, getInbox, getInsuranceMailDraft, getInsuranceMailMessage,
getInternalAgentRun, getInternalCaseQueue, getMemoryChange, getProviderInvocation, ingestCommissionCash,
listInsuranceMailMessages, reconcileProviderInvocation, registerDevice, requestApplicationSubmission,
revokeApproval, streamMissionEvents, updateAgentProfile, updateInsuredAsset. У каждой `mentions_total=1` —
единственное вхождение в `Complior_OpenAPI_5_8_2_Operation_Waves.json`. В Alignment, Mobile и bindings их
нет ни в каком поле. Причина «wave index, not a calling flow» здесь честная.

**19 переписанных строк** сверены с фактическим JSON-путём (оба снимка 1_17_5 и 1_17_8_2 совпадают):

| строка | op | заявлено | факт (путь, 1_17_8_2) | верно |
|---|---|---|---|---|
| 32 | completeUpload | проза actions_and_binding/data_source, binding нет | nff/0 a&b, nff/19 a&b, nff/19 designer_components/data_source; action_specification нет | да |
| 36 | createMailboxGrant | проза a&b W1b, binding нет | nff/20 a&b «… — W1b.» | да |
| 37 | createPartnerDispute | binding, статус W4_FOLLOWUP_PARTNER_WEB_W2_DEMO_ONLY | nff/16 (PH10) action_specification/1 binding+status точно | да |
| 38 | createPartnerGrant | binding RV07 …EXTENSION_PROPOSED + PH07 …EXACT_LIFECYCLE_EXTENSION_PROPOSED | nff/6 spec/0, nff/13 spec/1 — статусы точно | да |
| 39 | createPartnerSalesIntent | binding W4_FOLLOWUP_PARTNER_WEB_NOT_W2_EFFECT | nff/14 (PH08) spec/0 точно | да |
| 45 | getDataRightsRequest | Mobile automated_scope проза | features/42/designer_integration/automated_scope дословно | да |
| 50 | getInsuranceMailbox | проза a&b W1b | nff/20 a&b | да |
| 53 | getManualLetterDelivery | проза «получить запись → getManualLetterDelivery» | nff/22 a&b дословно | да |
| 55 | getPartnerClient | binding W4_FOLLOWUP_PARTNER_WEB_NOT_EARLY_MOBILE | nff/12 (PH06) spec/1 точно | да |
| 56 | getPartnerStatement | binding W4_FOLLOWUP_PARTNER_WEB_W2_DEMO_ONLY | nff/16 spec/0 точно | да |
| 60 | listMailboxGrants | проза a&b W1b | nff/20 a&b | да |
| 61 | listPartnerGrants | RV07 …EXTENSION_PROPOSED + ADOPTED_READ_EXTENSION_PROPOSED | nff/6 spec/0, nff/13 spec/0 точно | да |
| 62 | logoutSession | только evidence-список «операции getSession/logoutSession» | historical_v3_5_audit/findings/3/evidence/2 (+ historical_source_finding) — других нет | да |
| 63 | proposePartnerProgramme | только evidence-список | historical_v3_5_audit/findings/21/evidence/2 — других нет | да |
| 64 | provisionInsuranceMailbox | проза a&b W1b | nff/20 a&b | да |
| 66 | recordManualLetterDelivery | проза a&b + evidence-список | nff/22 a&b дословно; findings/10/current_evidence/3 | да |
| 67 | recordOutcomeEvidence | проза a&b (две цитаты), binding нет | nff/4 a&b и nff/24 a&b дословно; также nff/22 a&b и findings/10/recommendation — не binding | да (неполный перечень, совет С-2) |
| 71 | revokeMailboxGrant | проза a&b W1b | nff/20 a&b | да |
| 72 | revokePartnerGrant | как createPartnerGrant | nff/6 spec/0, nff/13 spec/1 точно | да |

Ложного источника и ложной причины нет ни в одной из 19 строк. Семь кадров W4/PROPOSED из З-5 арбитра
названы поимённо с точным статусом. Структура 46 + 5 = 51 и раздел OWNER (`:77–98`) не изменились. Текстовая
часть Рв993-11 закрыта. Пункт «FILES.sha256 пересобран» не выполнен (Рв993-14).

## 8. Мутанты (регресс CAS/A3 круга 4, adversary-набор З-4 и обходы круга 3)

`mut5.py` (= `rv993r4/mut.py` на этом C плюс 3 сценария). Каждый — настоящий CLI на копии; сравнение с
control; `index_source_sha256` отфильтрован как шум хеша.

```
control                  rc=1 status=FAIL_STATIC n=57 +0 -0 [] []
m_cond_query             rc=1 n=59 +2 ['updatePersonalProfile_cas','updatePersonalProfile_conditional_policy']
m_cond_drop              rc=1 n=59 +2 ['updatePersonalProfile_cas','updatePersonalProfile_conditional_policy']
m_cond_inm_rejects_star  rc=1 n=59 +2 ['updatePersonalProfile_cas','updatePersonalProfile_conditional_policy']
m_cond_ifm_weakstar      rc=1 n=59 +2 ['updatePersonalProfile_cas','updatePersonalProfile_conditional_policy']
m_add_cond_drop          rc=1 n=59 +2 ['revokeAccountSession_cas','revokeAccountSession_conditional_policy']
m_prose_drop             rc=1 n=59 +2 ['revokeAccountSession_cas','revokeAccountSession_conditional_policy']
m_query                  rc=1 n=58 +1 ['revokeAccountSession_cas']
m_ras_optional_inline    rc=1 n=58 +1 ['revokeAccountSession_cas']
m_ras_downgrade          rc=1 n=58 +1 ['revokeAccountSession_cas']
m_wildcard_schema        rc=1 n=101 +44 {suffixes:['cas']}
m_optional               rc=1 n=101 +44 {suffixes:['cas']}
m_revperm_back           rc=1 n=57 +0 -0      (A3-ловушка 200 держит revokePermission_cas)
m_v4_412_not_problem     rc=1 n=59 +2 ['revokeAccountSession_cas','revokeAccountSession_problem']
pos_ack_ifmatch          rc=1 n=56 -1 ['acknowledgeDisclosure_cas']   (положительный control adversary)
m_revperm_200_to_201     rc=1 n=57 +0 -0      (обход 3 круга 3: не снимает, Решение 1(а))
m_revperm_back_201       rc=1 n=56 -1 ['revokePermission_cas']        (граница «only 200», допуск (а))
```

Все 5 мутантов З-4 adversary (cond_query, cond_drop, add_cond_drop, wildcard_schema, optional) и 3 обхода
круга 3 (структурный dict, wildcard `'*'`, 200→201) дают тот же результат, что в круге 4. Положительная
ветвь VERSIONED живая. Рефакторинг C1–C3 и A3 не позеленил ни один красный.

Scoped `probe.py --case revocations-target-cas`:
```
993 scenario=9 case=revocations-target-cas control_rc=1 mutant_rc=1 expected=revokeAccountSession_cas observed=True control_green=False
993 scenarios=1 mutations=1 validator_runs=2 mismatches=1   probe_rc=1
```
Мутант ловится своим ID. Mismatch — только из-за незелёного control (В-1). Это не дефект C.

## Контракт 050 — артефакты круга 5

- `_check_conditional_profile` (`:53–76`): (1) Решение 1 — «`_conditional_policy` проверяет те же C2–C3»,
  то есть один источник C1–C3; (2) состояния нет; (3) правка свойства — теперь 1 место, было 2, дифф число
  уменьшил; (4) 3 аргумента → bool, работа — C1 dict, C2/C3 wire; (5) потребители `_cas :331`,
  `_conditional_policy :376`, мутанты C. **ESSENTIAL.**
- `has_response_etag` (`:42–51`): (1) A3, единая грамматика ETag-признака; (2) нет; (3) 1 место; (4) параметр
  `status_prefix` со значением по умолчанию `'2'`, но единственный вызов передаёт `'200'`, так что
  умолчание мёртвое — совет С-1; (5) потребитель `:353`, мутант `m_revperm_back`. **ESSENTIAL.**
- Запись `evidence/ux175/20261018T100915.689049Z/results.json` в FILES.sha256: (1) свойства нет;
  (2) ссылается на состояние, которого нет в поставке; (5) потребитель — `verify_handoff.py`, и он
  ломается. Этот артефакт — дефект Рв993-14, а не вопрос сложности.
- Новых флагов, env-переменных, каталогов состояния нет.

## ПРОВОДКА (контракт 038)

Четыре guard-канала H байтово равны `frozen/contracts/993/1`. Они барьеры этого предмета: приёмка п.3,
«Полнота report.checks», «Handoff CLI». ПРОВОДКА-ЭНФОРСМЕНТ обоснована, как в v4. Канал `handoff_probe.py`
на C даёт rc2 из-за Рв993-14.

## Семь пунктов роли

1. **Область.** Зона чиста (§1).
2. **Сырой вывод.** В коммите 0230ee0 нет ни одного сырого вывода с rc, только пересказ («Failure count 57 …
   preserved», «FILES.sha256 regenerated»). Второй пункт пересказа ложен на поставленном дереве (§3). Всё
   выше снято моими командами.
3. **Проверка не переписана под код.** Батареи H не тронуты. Правка валидатора — рефакторинг без смены
   семантики. 17 мутантов — тот же результат, что в круге 4. Ни один красный не позеленел.
4. **Красное предъявлено.** A3 через has_response_etag: `m_revperm_back` красный, `m_revperm_back_201` —
   граница. C1–C3 через helper: 6 C-мутантов красные в обеих проверках.
5. **Атомарность.** Круг 5 — один коммит, четыре находки одной задачи. Предыдущий churn — А-6 (squash).
6. **Норма.** Нормативные документы dev-harness не тронуты. Контракт и батареи = тег.
7. **Счёт своей мерой:** 57 = 51 + 5 + 1 и 1491 — разбор JSON; 46 + 5 = 51 и равенство множеств — регекс
   блокер-файла против failure_ids; 27 + 19 = 46 — независимый обход `sources/` по JSON-путям; 614 строк
   FILES.sha256 = 613 поставленных + 1 фантом — diff ls-tree/manifest и регенерация (613 files).

## Ф-1. Факт процесса: push implementer

SSH-push implementer в a3ka/Complior-back отклонён (транскрипт Implementer993R5:601–603, `gitpush` exit 128).
После этого C запушен через HTTPS с токеном:
`git -c "url.https://x-access-token:$(gh auth token)@github.com/.insteadOf=…" push` (транскрипт :822–864).
Ветка на origin = C, это проверено `git ls-remote`. Обход SSH-канала токеном gh записываю как факт. Это не
дефект кода и не блокер; решение о допустимости канала — за владельцем.

## Совет (не блокирует)

- С-1. Убрать мёртвое умолчание `status_prefix='2'` у `has_response_etag` или переименовать параметр в точный статус.
- С-2. Строка 67 (recordOutcomeEvidence) — «actions_and_binding only», но есть ещё nff/22 a&b и
  `historical_v3_5_audit/findings/10/recommendation`. Причину это не меняет. Строки partner-grant можно
  дополнить `partner_revision_protocols/PG01 status PROPOSED`.
- С-3. Комментарий `:330` — «single helper below», а helper стоит выше, на `:53`. Комментарий `:375` —
  «only re-validates the closed profile shape», а helper проверяет и wire C2/C3.
- С-4. Строка 45 называет 1_17_8_2 Mobile «canonical», шапка `:20–22` — 1_17_5 (1_17_8_2 «mirrored»). Привести к одному.

## Что нужно для ACCEPT

Только Рв993-14: FILES.sha256 на C должен ссылаться лишь на поставленные файлы, и `verify_handoff.py` на
свежем клоне должен давать rc0. Правка в одну строку. Рв993-9/11/12/13 закрыты. Это 5-й круг из 5: по слову
владельца при FAIL предмет 993 останавливается, решение о продолжении — за владельцем. Приёмки п.2/п.3
недостижимы без В-1 независимо от этой находки.
