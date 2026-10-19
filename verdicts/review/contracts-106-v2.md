FAIL
OBJECT=76f7da435e023543ec6649a7d24f05a4180a953d

# Reviewer, круг 2 — контракт 106 (CMP-BCK-133, 5.8.4)

Судья: Rev106r2 (reviewer). B=0230ee068d10047b1be99c26747aef1bd1579bcf; предыдущий OBJECT — 92e0d999.
H: frozen `frozen/contracts/106/1`; батарея j2 (`/tmp/dev-harness-worktrees/c907157c/wip-106-architect-j2`,
HEAD 32997af93): `git diff --numstat frozen/contracts/106/1 HEAD -- fixtures/workshop_project/spec584_106` → `442 0 probe.py`,
контракт не тронут — только добавления. Находки — `review.md` (reslop, status: ready; копия
`h/.review/2026-10-19-11.md`); чекбоксы круга 1 отмечены в `h/.review/2026-10-19-10.md`.

## Итог

Машинная часть зелёная, и F3 закрыт: мутант даёт красное. Но §1/§2 по существу не реализованы.
CAS-описания различаются, однако противоречат wire своих же операций. Безопасная остановка
requestAction потеряла carve-out. Ослабленная проверка условного профиля осталась. У потребителей 51
единственный источник — файл исполнителя, который противоречит реестру; экранные потребители спрятаны
под `workflow`. §Предмет «РЕАЛИЗОВАН» — НЕТ (крит. 5 не выполнен).

ЗОНА: wire-5_8.schema.json — ожидает решения консультанта. По существу это чистое производное:
откат файла к B с последующим `generate_derived` (rc 0) даёт worktree, побайтно равный OBJECT (`git diff HEAD --stat` пуст),
а относительно содержимого B — дифф `1 file changed, 1+/1-`. Регенерация на OBJECT — no-op (porcelain 0). Блокером не считаю.

## Своя мера (сходится)

| Проверка | Результат |
|---|---|
| Область правки `git diff --stat B..OBJECT` | 20 путей: 18 в ЗОНЕ implementer; `tools/validate_invitation_target_31421.py` numstat `3 3` (допущен); `contracts/wire-5_8.schema.json` — см. ЗОНА |
| Крит. 1 (B) | rc 1 FAIL_STATIC; мой обход JSON: 57 = 5 `_cas` + 51 `_source_consumers` + `revokePartnerGrant_conditional_policy` |
| Валидатор на OBJECT | VAL_RC=0 PASS_STATIC, checks 1495 (B 1491; удалённых 0, добавлено 4 `_conditional_policy`), negative 28=28, failures [] |
| База отказов пуста без скрытия | в валидаторе и раннере нет allowlist/known-failures (`git grep -i known_fail\|allowlist\|xfail` → только посторонние строки); проверки не удалены |
| Батарея j2 полная | PROBE_RC=0 `{"control_green": true, "cases": 27, "rejected": 27, "mismatches": []}`; мой подсчёт raw.json: 27× REJECTED_EXACT, byte_equal False 27/27 |
| Крит. 4 (без npm) | GEN_RC=0 (porcelain 0), HANDOFF_RC=0, ALIGN_RC=0 (163/19), INV_RC=0, GEN2_RC=0 (porcelain 0), `sha256sum -c FILES.sha256` SHA_RC=0, 619 строк, неотслеживаемых 0 |
| §4 lane `package` | LANE_RC=0, `[package] PASS rc=0 validate_contract_v3_9 (живая команда…)`; `@not-run` нет |
| 163/19, deferred≠deprecated | множество операций B=OBJECT (163), набор deprecated тот же (19), волна/scheduling ни у одной не сдвинуты |
| pending-файл | литерал вне `BACKEND_ADOPTION_PENDING`; клетка consumer_kind_pending REJECTED_EXACT |
| F3 (r1) | мутант m1 (revokeApproval→IDEMPOTENT): validator **rc 1** `["revokeApproval_cas"]`, батарея `CAS_PROFILE:revokeApproval:precondition=IDEMPOTENT_TARGET_REVOKE` — ЗАКРЫТ |
| ПРОВОДКА | guard `fixtures/workshop_project/spec584_106/probe.py` существует, потребляется крит. 2–3, это барьер именно этого предмета; ПРОВОДКА-ЭНФОРСМЕНТ обоснован (внешний CLI, CI dev-harness без внешнего checkout) — принимаю |

## Находки (блокирующие)

Обход для R2-F1, R2-F2 и R2-F5 — **сам OBJECT**: батарея RC=0, валидатор rc 0, lane rc 0, а обязательства
§1/§2 по смыслу нарушены. Это класс «правдоподобного, но ложного нарратива» (§Модель угроз, НЕ ЗАЩИЩАЕТ;
крит. 5), который контракт отдал судьям. Все ниже — семантические FAIL: обязательство, фрагмент, источник, противоречие.

### R2-F1 [§1 «по смыслу каждой» + канон §CAS] — wire операции противоречит её x-cas-semantics
- **revokePermission**, выбор (б) `IDEMPOTENT_TARGET_REVOKE`, `repeat_safe: true`. На B заголовка If-Match нет (мой дамп B: у пятёрки If-Match был только у requestAction). На OBJECT добавлен inline `If-Match required: true`: «false=>412 PRECONDITION_FAILED; already-completed action=>409 IDEMPOTENCY_CONFLICT». Там же `x-conditional-policy`: `existing_update.header: If-Match`, `missing_or_both: 428`, `stale_or_existing_initial_target: 412`. А `x-cas-semantics` говорит: `stale_version` «отдельная версия не блокирует отзыв», `completed_action` «без конфликта». Канон: «без механического ужесточения». Клиент по wire получит 428/412/409 там, где семантика обещает безопасный повтор. Отдельного GET Permission нет (`/v1/permissions/{permission_id}` → `{}`).
- **completed_action vs wire.** У acknowledgeDisclosure, requestAction, revokePartnerGrant и revokePermission стоит «идемпотентный 200 / прежний результат без конфликта». If-Match тех же операций: «already-completed action=>409». У requestAction ответа 200 нет вовсе: responses `202,400,…`.
- **revokePartnerGrant** `version_source`: «Сильный ETag PartnerGrant из ответа GET партнёрского гранта». Grant-операции в 163: `createMailboxGrant, createPartnerGrant, listMailboxGrants, listPartnerGrants, revokeMailboxGrant, revokePartnerGrant` — GET одного гранта нет, а у `listPartnerGrants 200` заголовки `['Cache-Control','X-BrokerOS-Contract']`, без ETag.
- **revokeApproval** `completed_action`: «отмена УЖЕ ОТПРАВЛЕННОГО действия… здесь именованной причиной отклоняется» — причина не названа. При этом описание операции: «После dispatch прекращаются только дальнейшие вызовы. In-flight обязательно показан» (отзыв после dispatch принимается).
- rc: validator VAL_RC=0, PROBE_RC=0.

### R2-F2 [§1 requestAction; канон «чтобы фоновые события не создавали бессмысленных конфликтов»] — F2 не закрыт, а перевёрнут
- На B: `x-if-match-required-except-action-kinds: ['pause_work','stop_work']` и If-Match «Для безопасного pause_work/stop_work можно без ETag». На OBJECT ключ удалён (`{}`). ActionRequest (OpenAPI → wire/mock) теперь: «pause_work/stop_work … требуют актуальный strong Mission ETag в If-Match; устаревший snapshot даёт 412».
- `mission_invalidators.snapshot_version`: «новая версия snapshot миссии (Mission.snapshot_version)» — любая смена snapshot. `version_source`: «If-Match обязан совпадать с текущей версией миссии». Перечень ничего не сужает: каждая смена ETag даёт 412, в том числе для остановки. Канон требовал обратного.
- Более простая форма, сохраняющая обязательство: If-Match required (V2) плюс существующий структурный carve-out B и ActionRequest без «даёт 412». [INFERENCE] Клетка `prose_carveout_contradiction` по её `why` допускает «структурный carve-out»; прогоном не проверял.
- rc: VAL_RC=0, PROBE_RC=0.

### R2-F4 [ревью п.3; §1 revokePartnerGrant «условный профиль — проверяемая структура»] — ослабляющая ветка валидатора осталась
- `tests/validate_contract_v3_9.py:389–398`: при `If-Match required is True` проверяется только `isinstance(initial_create, dict)`, `isinstance(existing_update, dict)` и `exactly_one_conditional_header is True`. Проверку 993 C1–C3 ветка подменяет и с wire не сверяет.
- Обход, мутанты судьи (`mut.py`; копия OBJECT → `generate_derived` rc 0 → валидатор → `structural_reds` батареи):
  - m3: revokePartnerGrant `x-conditional-policy = {initial_create:{}, existing_update:{}, exactly_one_conditional_header:true}` → applied True, **validator rc 0 PASS_STATIC failures []**, **батарея structural_reds []**.
  - m4: призрачный `initial_create.header: If-None-Match` (форма круга 1) → **validator rc 0**; батарея `CAS_CONDITIONAL_WIRE_MISMATCH:revokePartnerGrant:If-None-Match`.
  - m5: revokePermission `existing_update: {header: X-Bogus}` → **validator rc 0**; батарея `CAS_CONDITIONAL_WIRE_MISMATCH:revokePermission:X-Bogus`.
- Обязательный CI-барьер (§4) принимает профиль, не описывающий wire; пустой профиль не ловит никто. 050: фрагмент — строки 389–398; отсутствующее свойство — «проверяемая структура», сверка с wire; более простая форма — для V2 требовать `existing_update.header=='If-Match'`, `value=='EXACT_STRONG_TARGET_ETAG'`, `initial_create.applicable is False` и отсутствие If-None-Match на wire. Строки приёмки она проходит: OBJECT этой форме удовлетворяет, по дампу у всех пяти. ACCIDENTAL, блокирует.

### R2-F5 [§2 «конкретный сценарий, роль потребителя, источник, волна и статус принятия»; канон §Потребители, «Фиктивные привязки… не добавляются»]
- `source_ref` у 51/51 — `evidence/contracts/106/consumers-5_8_4.md`, который создан в том же коммите 76f7da4 (stat `55 +`). Это пересказ (kind/волна/статус) без сценария и без внешнего источника. И он **противоречит реестру у 12 операций**: md `mobile lifecycle/service`, реестр `workflow` — acknowledgeDisclosure, getInbox, revokeApproval, getMemoryChange, getAgentProfile, updateAgentProfile, getDataRightsRequest, createVoiceSession, getVoiceTranscript, requestApplicationSubmission, createActionPlan, updateInsuredAsset.
- Экранные потребители записаны как `workflow`. Валидатор (`:248`) для nonmobile kind требует лишь непустые owner/source_ref/guard, а для `screen` — id кадра. getInbox: guard «Inbox-экран мобильного клиента: пять зон»; вхождений в `sources/` вне таблицы волн — 0, то есть экран не подтверждён. getDataRightsRequest: guard «экран»; в `BrokerOS_Mobile_Design_Data.json` есть `action_binding_ids F44.A01–A03`, но привязка к ним не сделана. getVoiceTranscript: канон «к W29 после проверки, что виджет читает этот ответ»; в Mobile_Design_Data есть `designer_data_contract.full_transcript: getVoiceTranscript`, а в реестре — `workflow` без виджета.
- `adoption_status: confirmed_5_8_4` стоит у 51/51 одинаково. У getGroupMetrics в той же строке guard: «Будущий внутренний управленческий раздел; вне текущего запуска» — подтверждение противоречит собственной строке и канону.
- recordManualLetterDelivery: guard «Ручная доставка письма: точное указание исполнителя» пересказывает канон, исполнитель не назван (owner `manual-letter-delivery`).
- Закрыто из F5 r1: волны — 0/51 расхождений; поле статуса у 51; литерал только у logoutSession, registerDevice, streamMissionEvents и completeUpload; getInbox не назначен источником Post.
- rc: VAL_RC=0, PROBE_RC=0.

## Советы (не блокируют)

- A1 (r1, открыт): workflow_consumers — ручная секция производного bindings.
- A2 (r1, открыт): `run_backend_ci.py:212` `'SKIPPED' if rc is None` — мёртвая ветка, будущий None молча не-FAIL.
- A3: 76f7da4 связывает §1, §2, валидатор и evidence в один коммит.
- A4: alignment `vs01_refreeze` «VS01 frozen spec hash не менялся» против VERSION_MANIFEST `7d5c…→09e3…`; `baseline_openapi: 5.8.2`; `callers.mobile` перечисляет 16 операций литералом при 4 в реестре; getGroupMetrics «W5» при W4.
- A5: `evidence/contracts/106/manifest.json` заявляет sha `efd566…`, у файла — `bfc02e…`. Входы contract-validation.json совпадают с OBJECT (9/9 — A5 r1 закрыт в этой части).
- A6 (архитектору): батарея требует `if_match_not_required` и `CAS_CONDITIONAL_NOT_STRUCTURED` у всех пяти, в том числе у revokePermission при выборе (б). m6 (revokePermission без If-Match и профиля, как B): validator rc 0, батарея `CAS_CONDITIONAL_NOT_STRUCTURED:revokePermission`. Ужесточение wire в R2-F1(а) отчасти навязано формой клеток; это вопрос формы батареи. Противоречие описаний внутри операции — вина исполнителя.

## Паразитная сложность (050)

- Ветка `IDEMPOTENT_TARGET_REVOKE` + `oid!='revokePermission'`: (1) §1 замкнутый перечень; (2) без состояния; (3) 1 файл; (4) мелкая, достаточная; (5) lane `package`, m1 красный. ESSENTIAL.
- Ветка `_conditional_policy` для V2: (1) свойства не называет: контракт требует проверяемую структуру, ветка снимает сверку; (2) нет; (3) 1; (4) интерфейс без работы; (5) потребитель — только зелень. ACCIDENTAL, блокирует (R2-F4: фрагмент, свойство и форма названы).
- `evidence/contracts/106/consumers-5_8_4.md`: (1) §2 «источник» — но это дубль реестра, а не источник; (2) файл; (3) при правке потребителя меняются 2 файла (bindings + md) вместо 1 — рост, и рассинхрон уже 12/51; (4) —; (5) потребитель — только `source_ref`. ACCIDENTAL, блокирует через R2-F5. Более простая форма: `source_ref` на существующие UX/архитектурные разделы (Mobile_Design_Data F44, designer_data_contract и т.п.); там, где их нет, — честный статус.
- `x-cas-semantics`/`x-conditional-policy` ×5: (1) §1; (2) данные в OpenAPI; (3) 1 файл + регенерация; (4) —; (5) батарея и валидатор. ESSENTIAL, содержание — R2-F1/F4.
- Builtin `@validate-out`: (1) §4; (2) каталог `validate-<ts>` в `--out`, явно; (3) 1; (4) норм.; (5) lane `package`. ESSENTIAL.

## Сырые команды (rc)

```
git clone -q /tmp/dev-harness-verify/Impl106/back back && git -C back checkout -q 76f7da4…            # exit=0
git -C back diff --stat B OBJECT                                                                      # 20 files
(back) PY tests/validate_contract_v3_9.py --out val-out                                               # VAL_RC=0 PASS_STATIC checks 1495
(back) PY tools/generate_derived.py; git status --porcelain | wc -l                                   # GEN_RC=0; 0
(back) PY tools/verify_handoff.py                                                                     # HANDOFF_RC=0
(back) PY tools/validate_alignment_11782_31422.py                                                     # ALIGN_RC=0 operations 163 deprecated 19
(back) PY tools/validate_invitation_target_31421.py                                                   # INV_RC=0
(back) PY tools/generate_derived.py; git status --porcelain | wc -l                                   # GEN2_RC=0; 0
(back) sha256sum -c --quiet FILES.sha256                                                              # SHA_RC=0; 619 lines
(w) git checkout B -- contracts/wire-5_8.schema.json; PY tools/generate_derived.py; git diff HEAD --stat   # GEN_RC=0; пусто (=OBJECT); git diff --stat: 1 file 1+/1-
(B) PY tests/validate_contract_v3_9.py --out valB                                                     # FAIL_STATIC 57 (5/51/1)
TMPDIR=… venv/python j2/probe.py --repo back --out probe-out                                          # PROBE_RC=0 cases 27 rejected 27 mismatches []
(lane) PY tools/run_backend_ci.py --lane package --out lane-out                                       # LANE_RC=0
venv/python mut.py m1 m3 m4 m5 m6                                                                     # m1 val rc1; m3 val rc0+battery []; m4 val rc0; m5 val rc0; m6 val rc0
```

PY в начале — `/tmp/dev-harness-verify/architect993-venv/bin/python`. Его удалили во время сессии (хост
заполнился до 2.2M свободных, первый прогон батареи упал с ENOSPC). Дальнейшие прогоны — на
`/tmp/dev-harness-verify/Rev106r2/venv` (`pip install -r requirements-validation.txt`: jsonschema 4.26.0, PyYAML 6.0.3).
Сырой вывод батареи: `/tmp/dev-harness-verify/Rev106r2/probe-keep/{raw,summary}.json` (копии клеток удалены ради диска). Скрипты судьи: `dump5.py`, `reality.py`, `etag.py`, `cons.py`, `srcx.py`, `mut.py` — в `/tmp/dev-harness-verify/Rev106r2/`.
npm ci/npm test не гонялись (вне scoped-прогона). Вердикт не закоммичен, push не делался.
