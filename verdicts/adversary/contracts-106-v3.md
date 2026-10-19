accept
OBJECT=55dac5a0068877d6295dee027b899cccf2d16c42

## Механические пробы валидатора

Обходов в заданной рамке m3/m4/m5 не найдено. Каждая мутация была применена к отдельной копии OBJECT (OpenAPI фактически изменён), после чего штатный `tools/generate_derived.py` завершился с rc=0 и настоящий `tests/validate_contract_v3_9.py` был запущен по этой копии.

- m3 — пустой `x-conditional-policy` у `revokePartnerGrant` (`initial_create={}`, `existing_update={}`, `exactly_one_conditional_header=true`): генератор rc=0; валидатор rc=1, `FAIL_STATIC`, `failure_ids=["revokePartnerGrant_conditional_policy"]`.
- m4 — лишний `If-None-Match` в `initial_create` профиля `revokePartnerGrant`: генератор rc=0; валидатор rc=1, `FAIL_STATIC`, `failure_ids=["revokePartnerGrant_conditional_policy"]`.
- m5 — чужой заголовок `X-Bogus` в `existing_update` профиля `revokePermission`: генератор rc=0; валидатор rc=1, `FAIL_STATIC`, `failure_ids=["revokePermission_conditional_policy"]`.

## Позитивный контроль

Немутированный OBJECT: `tests/validate_contract_v3_9.py --out /tmp/dev-harness-verify/Adv106r3/val-control` завершился с rc=0; отчёт `PASS_STATIC`, `checks=1495`, `negative_cases=28`, `failure_ids=[]`.

## Сырые команды

```sh
/tmp/dev-harness-verify/Adv106r3/venv/bin/python tests/validate_contract_v3_9.py --out /tmp/dev-harness-verify/Adv106r3/val-control
/tmp/dev-harness-verify/Adv106r3/venv/bin/python /tmp/dev-harness-verify/Adv106r3/run_mutants.py
```

## Совет

Для трёх предписанных механических форм дополнительной правки не требуется: закрытые проверки профиля распознают пустой профиль, лишний `If-None-Match` и чужой заголовок точными идентификаторами отказа.
