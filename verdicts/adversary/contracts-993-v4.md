ACCEPT — круг 4 по C=`5fdac96f2010d76f3729f62aac8e8b0f05bd750e` принят на живом исполнении и строго в закрытых границах арбитражного решения V1–V5/C1–C3/A1–A3.

## Предмет и граница

Проверен свежий detached-клон `a3ka/Complior-back` на точном C. Валидатор запускался отдельным venv, созданным по `requirements-validation.txt` (Python 3.12.3, jsonschema 4.26.0). Системный `python3` не имел `jsonschema`; это не засчитывалось ни как зелёный, ни как красный предметный результат.

Согласно арбитражному решению новые CAS-формы вне V1–V5/C1–C3/A1–A3 не искались и не оценивались. Перенос кода успеха `revokePermission` 200→201 проверен только как неблокирующий сценарий решения 1(а).

## Живой baseline и положительный контроль

```text
/tmp/dev-harness-verify/adversary993round4-venv/bin/python \
  tests/validate_contract_v3_9.py --out /tmp/dev-harness-verify/adversary993round4-baseline
```

Вернул rc=1 и структурный `FAIL_STATIC` с **57** failure ID: 51 `*_source_consumers`, 5 `*_cas` и 1 `*_conditional_policy`. Шесть non-consumer ID в точности:

```text
acknowledgeDisclosure_cas
requestAction_cas
revokeApproval_cas
revokePartnerGrant_cas
revokePartnerGrant_conditional_policy
revokePermission_cas
```

Это честный остаток, а не неисполняемый вход. Положительный control VERSIONED: в отдельной полной копии добавлен настоящий wire `$ref: '#/components/parameters/IfMatch'` к `acknowledgeDisclosure`; синхронизирован `operation-index.source_sha256`. Валидатор вернул rc=1 только из остатка и снял ровно `acknowledgeDisclosure_cas`, без новых ID. Годная ветвь работает, а не является постоянной краснотой.

## Обманные заглушки арбитража З-4

Для каждого сценария создана отдельная полная копия C; после изменения OpenAPI source hash index синхронизирован, поэтому red не мог быть stale-hash ответом. Все запуски дали rc=1; у каждого сохранены исходные 57 ID и указанные новые именованные ID.

| Сценарий | Заглушка | Наблюдённый результат |
|---|---|---|
| `m_cond_query` | `updatePersonalProfile.If-Match.in=query` | `updatePersonalProfile_cas`, `updatePersonalProfile_conditional_policy` |
| `m_cond_drop` | удалить wire `If-Match` у `updatePersonalProfile` | `updatePersonalProfile_cas`, `updatePersonalProfile_conditional_policy` |
| `m_add_cond_drop` | удалить `If-Match` у `revokeAccountSession`, добавить формально полный dict conditional-policy | `revokeAccountSession_cas`, `revokeAccountSession_conditional_policy` |
| `m_wildcard_schema` | `components.parameters.IfMatch.schema={type: string, const: '*'}` | 44 новых `*_cas`, включая `revokeAccountSession_cas` |
| `m_optional` | `components.parameters.IfMatch.required=false` | те же 44 новых `*_cas`, включая `revokeAccountSession_cas` |

Следовательно V1/V2/V3 и C1/C2/C3 ловят именно wire-порчи; корректная conditional-ветвь не легализует query/header-drop.

## Повтор обходов круга 3

1. Фабрикованный structured `x-conditional-policy` с `existing_update.header=If-Match` после удаления настоящего `revokeAccountSession` header добавил ровно `revokeAccountSession_cas` и `revokeAccountSession_conditional_policy`.
2. Wildcard-константа `'*'` в `IfMatch` добавила 44 `*_cas`, включая `revokeAccountSession_cas`.
3. Перенос того же ETag-ответа `revokePermission` с 200 на 201 оставил failure ID точным baseline: rc=1, `added=[]`, `removed=[]`. Это ожидаемое неблокирующее поведение решения 1(а): операция теперь `VERSIONED_TARGET_CAS`, и её `revokePermission_cas` не снимается кодом успеха.

## Регрессии кругов 1–2

- `createIntent.x-operation-class=SAFE_READ_OVER_POST` при неизменённой command-ветви добавил ровно `createIntent_policy_consistency`; placebo больше не проходит.
- В полной копии C удалён только `VERSION_MANIFEST.json.vs01_spec_freeze`. `tools/generate_derived.py` вернул rc=1 и:

  ```text
  VS01_SPEC_FREEZE_MISSING: VERSION_MANIFEST.json carries no vs01_spec_freeze; derived rebuild refused without an explicit --freeze-vs01 re-freeze
  ```

  Парный неизменённый control на новой копии вернул rc=0 (`Derived consumers, wire and 10-route mock rebuilt`; `Handoff hashes rebuilt: 613 files`).
- Зонный регресс: запрещённый round-1 перечень в diff `f7b972913ec2af0df83ce58ea34dd688870fb0e9..C` дал пустой stdout. Собственно diff круга 4 `31d4b98f159d60ab3e9052135b66241c3f8e410e..C` содержит только семь разрешённых путей: архитектура, `FILES.sha256`, README, OpenAPI, operation index, blocker evidence и validator.

## PR checks

`gh pr checks 146 --repo a3ka/Complior-back` показал зелёные `checks`, `historical`, `image`, `package`, `postgres`; красны только исключённые заданием `backend` и `required`.

Следовательно, в закрытом предмете круга 4 проверка ловит все обязательные обманные заглушки, сохраняет работающий положительный control и не регрессирует по перечисленным старым барьерам.
