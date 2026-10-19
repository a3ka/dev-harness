FAIL
OBJECT=92e0d99980b07864e65eb1e5e8007dbc08c8f7ee

## Блокирующая находка: канон для requestAction не поставлен

**Обход / наблюдаемый контрпример.** Канон (`h/docs/owner/2026-10-18-arhitektor-beka-5-8-4.md`, §CAS) требует для `requestAction` уточнить, *какие изменения Mission* делают команду устаревшей, чтобы фоновые события не создавали бессмысленный конфликт. В C у `requestAction` (`contracts/BrokerOS_Unified_OpenAPI_v3.yaml:2570-2585`) есть обязательный `If-Match`, исключение только для `pause_work`/`stop_work` и общий для всех пяти шаблон `x-cas-semantics`; перечня изменений Mission там нет. Общая строка `stale_version: "412 ..."` не отвечает на вопрос канона, какие изменения являются конфликтом.

Это требование канона пропущено картой: валидатор проверяет wire-профиль CAS, а батарея — только непустые ключи `x-cas-semantics`. Поэтому C получает зелёный структурный контроль, хотя обязательная предметная часть `requestAction` отсутствует.

**Наблюдение/rc.** В C: `tests/validate_contract_v3_9.py --out /tmp/dev-harness-verify/Adv106r1/out-validator-positive` — rc 0, `PASS_STATIC`, `failure_ids=[]`; полный `probe.py` вывел `control_green=true`, 12/12 `REJECTED_EXACT`. См. также позитивный контроль ниже.

## Блокирующая находка: фиктивные смыслы CAS проходят обе проверки

**Обход.** В отдельном клоне `mut-cas-gibberish` заменены все пять значений `acknowledgeDisclosure.x-cas-semantics` на строку `x`, затем выполнен штатный `tools/generate_derived.py`. Это уничтожает требуемые каноном источник версии, retry, stale-version, completed-action и concurrency-нарративы, но сохраняет непустые строки.

**Наблюдение/rc.** Полный `probe.py` на клоне: `control_green=true`, 12/12 `REJECTED_EXACT`; сохранённый `out-cas-gibberish/raw.json` фиксирует контрольный валидатор `rc: 0`, `PASS_STATIC`, `failure_ids: []`. Повторяемая клетка:
```
/tmp/dev-harness-verify/architect993-venv/bin/python /tmp/dev-harness-verify/Adv106r1/h/fixtures/workshop_project/spec584_106/probe.py --repo /tmp/dev-harness-verify/Adv106r1/mut-cas-gibberish --out /tmp/dev-harness-verify/Adv106r1/out-cas-gibberish-single --py /tmp/dev-harness-verify/architect993-venv/bin/python --case cas_key_hollow
```
вывела `control_green=true`, `rejected=1`, `mismatches=[]`, rc 0. Значит текущая проверка отличает `""`, но не бессодержательный CAS-нарратив. Это ровно заявленный cognitive-only предел, поэтому обязан быть закрыт предметной сверкой; первая находка показывает, что на C она не пройдена.

## Блокирующая находка: фиктивный потребитель принимается как подтверждённый

**Обход.** В отдельном клоне `mut-fake-consumer` для единственного потребителя `streamMissionEvents` заменены `owner`, `source_ref`, `guard`, `phase`, `wave` на `x`; тип остался `mobile lifecycle/service`; затем выполнен штатный генератор. Это не конкретный сценарий, роль, источник, волна или статус принятия, требуемые каноном §Потребители.

**Наблюдение/rc.** Полный `probe.py`: `control_green=true`, все 12 мутантов отвергнуты, а его `raw.json` фиксирует валидатор `rc: 0`, `failure_ids=[]`. Воспроизводимая клетка:
```
/tmp/dev-harness-verify/architect993-venv/bin/python /tmp/dev-harness-verify/Adv106r1/h/fixtures/workshop_project/spec584_106/probe.py --repo /tmp/dev-harness-verify/Adv106r1/mut-fake-consumer --out /tmp/dev-harness-verify/Adv106r1/out-fake-consumer-single --py /tmp/dev-harness-verify/architect993-venv/bin/python --case consumer_kind_pending
```
— rc 0, `control_green=true`, `rejected=1`, `mismatches=[]`. Валидатор проверяет у non-mobile kind лишь непустые `owner`, `source_ref`, `guard`, а батарея — литерал типа; ни один не разрешает источник и не проверяет конкретность сценария/волны/статуса. Это запрещённая каноном фиктивная привязка.

## Дополнительные результаты обмана проверки

1. `mut-revoke-gibberish`: у `revokePermission` сохранены `IDEMPOTENT_TARGET_REVOKE` и `repeat_safe=true`, но `server_recheck.resource` и `.scope` заменены на `x`. Полный контроль зелёный (`raw.json`: валидатор rc 0, без отказов); выборочная команда с `--case cas_idempotent_no_recheck` завершилась rc 0, `control_green=true`, `mismatches=[]`. Следовательно, батарея ловит отсутствие полей, не бессодержательную перепроверку ресурса/scope. Это тот же предметный дефект отзыва, который суд обязан оценить по канону.
2. `mut-files-missing`: в `FILES.sha256` добавлена строка для не поставленного `evidence/contracts/106/not-delivered.json`. Полный контроль зелёный; `raw.json` фиксирует валидатор rc 0. Выборочный `probe.py --case manual_derived` — rc 0, `control_green=true`, `mismatches=[]`. Отдельный обязательный `tools/verify_handoff.py` правильно отверг именно этот клон: rc 1, `AssertionError: evidence/contracts/106/not-delivered.json`. Это не обход полного owner-прогона, но батарея сама не покрывает FILES.
3. Негативный контроль закрытой грамматики успешен: в `mut-idempotent-outside` `acknowledgeDisclosure` получил `IDEMPOTENT_TARGET_REVOKE` с заполненной фиктивной перепроверкой. Один валидатор ошибочно зелёный (rc 0, `PASS_STATIC`), но батарея отвергла дерево: rc 1, `CAS_PROFILE:acknowledgeDisclosure:precondition=IDEMPOTENT_TARGET_REVOKE`. Значит этот класс прикрыт именно независимым структурным оракулом; не основание для FAIL сверх найденных выше.

## Позитивный контроль C и выполненные scoped-прогоны

- Полный `probe.py` на C: `control_green=true`, `cases=12`, `rejected=12`, `mismatches=[]`; отдельный штатный запуск валидатора — rc 0, `PASS_STATIC`, `failure_ids=[]`.
- `tools/generate_derived.py` — rc 0; затем `git diff --exit-code` — rc 0 (повторная генерация не изменила C).
- `tools/verify_handoff.py` — rc 0, `all_manifest_files_and_hashes=PASS`.
- `tools/validate_alignment_11782_31422.py` — rc 0, `PASS_STATIC`, operations=163, deprecated=19.
- `tools/validate_invitation_target_31421.py` — rc 0, `BACKEND INVITATION TARGET 3.14.2.2 PASS`.

## Сырые команды

Позитивный валидатор:
```
cd /tmp/dev-harness-verify/Adv106r1/back && /tmp/dev-harness-verify/architect993-venv/bin/python tests/validate_contract_v3_9.py --out /tmp/dev-harness-verify/Adv106r1/out-validator-positive
```

Позитивная батарея:
```
/tmp/dev-harness-verify/architect993-venv/bin/python /tmp/dev-harness-verify/Adv106r1/h/fixtures/workshop_project/spec584_106/probe.py --repo /tmp/dev-harness-verify/Adv106r1/back --out /tmp/dev-harness-verify/Adv106r1/out-positive --py /tmp/dev-harness-verify/architect993-venv/bin/python
```

CAS/consumer/revoke/FILES мутанты строились в одноимённых клонах `mut-*` скриптом `/tmp/dev-harness-verify/Adv106r1/mutate_spec584.py`, после нормативных изменений запускался `tools/generate_derived.py`; полные результаты лежат в `out-cas-gibberish/`, `out-fake-consumer/`, `out-revoke-gibberish/`, `out-files-missing/`.

## Советы автору

1. Дописать в `requestAction` конкретный, предметно верный перечень изменений Mission, которые инвалидируют действие; не заменять его общим шаблоном 412.
2. Принять предметный источник для каждого из 51 потребителя: разрешимый `source_ref`, конкретный scenario/role/wave/status; затем расширить валидатор и независимую батарею негативными мутантами `x`/несуществующий source, а не только `BACKEND_ADOPTION_PENDING`.
3. Для `x-cas-semantics` и `server_recheck` проверять не просто строку: закрытый тип ресурса/области, привязка к operationId и предметные инварианты; добавить отрицательные клетки для бессодержательных строк.
4. При изменении батареи сохранить отдельную проверку `verify_handoff.py`: она уже ловит несуществующий файл инвентаря.
