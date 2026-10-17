FAIL — на C=31d4b98f159d60ab3e9052135b66241c3f8e410e найдены три обхода CAS-проверки; backend/required CI не являются основанием этого FAIL.

## Предмет и чистота поставки

- `git diff --name-status f7b972913ec2af0df83ce58ea34dd688870fb0e9..31d4b98f159d60ab3e9052135b66241c3f8e410e -- tools/ evidence/` показал только четыре разрешённых implementer-изменения в `tools/` и семь записей в `evidence/contracts/993/`; иных `tools/`/`evidence/` путей нет.
- Из 27 файлов ошибочной пачки `44f061f` 21 восстановленный upstream-путь снова побайтно совпадает с `f7b972913ec2af0df83ce58ea34dd688870fb0e9`. Единственные шесть отличий — `FILES.sha256`, `VALIDATION.json`, три разрешённых evidence/993-файла и `tests/validate_contract_v3_9.py`.
- `gh pr checks 146 --repo a3ka/Complior-back`: зелёны `checks`, `historical`, `image`, `package`, `postgres`; красны только исключённые контрактом `backend` и `required`.

## Живой baseline и положительный контроль

Точный `python3 tests/validate_contract_v3_9.py` в данном runner остановился до предмета на `ModuleNotFoundError: jsonschema`. После запуска того же CLI предоставленным окружением `requirements-validation.txt` (`/tmp/dev-harness-verify/architect993-venv/bin/python ... --out ...`) получен структурный отчёт: rc=1, `FAIL_STATIC`, 57 failure IDs — ровно 51 `*_source_consumers`, пять `*_cas` (`acknowledgeDisclosure`, `requestAction`, `revokeApproval`, `revokePermission`, `revokePartnerGrant`) и `revokePartnerGrant_conditional_policy`.

Изолированный положительный контроль для versioned-ветви: добавление настоящего `$ref: '#/components/parameters/IfMatch'` к `acknowledgeDisclosure` устраняет ровно `acknowledgeDisclosure_cas` и не добавляет иных отказов (56 остаточных ID). Поэтому дальнейшие мутанты измерялись относительно работающей ветви, а не только относительно постоянно-красного baseline.

Сохранённые регрессии пойманы:

- `createIntent.x-operation-class=SAFE_READ_OVER_POST` при `mutation=true` добавляет `createIntent_policy_consistency`;
- удаление `If-Match` у `revokeAccountSession` с непустым prose `x-conditional-policy` добавляет `revokeAccountSession_cas` и `revokeAccountSession_conditional_policy`;
- удаление `vs01_spec_freeze` даёт rc=1 и точное `VS01_SPEC_FREEZE_MISSING`.

Прямой мутант круга 2 также пойман: на положительном `acknowledgeDisclosure` подмена на `CREATE_OR_APPEND_NO_TARGET_CAS` с произвольными `precondition_target`/`precondition_basis` возвращает именованный `acknowledgeDisclosure_cas` (вновь 57 ID).

## Новые обходы — блокеры

### A993-3-1: выдуманный conditional profile заменяет реальный обязательный If-Match

В disposable-копии у исправного `revokeAccountSession` удалён единственный параметр `$ref: '#/components/parameters/IfMatch'`. Вместо него добавлен полностью корректный по форме `x-conditional-policy` с `initial_create` и `existing_update.header: If-Match`. Результат: rc=1, но множество 57 baseline ID не изменилось; в частности, `revokeAccountSession_cas` отсутствует.

Причина в `tests/validate_contract_v3_9.py`: `conditional_carries` проверяет только текст metadata `existing_update.header == 'If-Match'` и становится альтернативой `in=header && required=true`, не сверяя существование, `in`, `required` или schema фактического параметра. Это непосредственно обходит закрытую Рв993-7 норму.

### A993-3-2: wildcard/weak If-Match проходит как strong target ETag

В disposable-копии у `components.parameters.IfMatch` заменена schema на `{type: string, const: '*'}` при сохранённых `name`, `in: header`, `required: true`. Результат снова rc=1 с неизменёнными 57 baseline ID; `revokeAccountSession_cas` не появился. Проверка различает только местоположение и обязательность, но вовсе не проверяет strong-target schema/value, хотя requirement требует strong target If-Match.

### A993-3-3: классификатор revokePermission доверяет коду 200 вместо реального ETag

В disposable-копии изменён только статус успеха `revokePermission`: response с тем же path `{permission_id}`, тем же ETag и тем же body перенесён из `200` в `201`. Результат: rc=1, 56 ID, `revokePermission_cas` исчез. Следовательно, `CREATE_OR_APPEND_NO_TARGET_CAS` проходит, хотя операция всё ещё объявляет ETag существующей versioned-цели.

Причина: классификатор просматривает исключительно `status == '200'`; helper `has_response_etag()` уже умеет смотреть весь 2xx-диапазон, но не используется. Подмена `200` на другой 2xx является зашитой константой вместо проверки факта target ETag и нейтрализует ровно проверяемую классификацию.

## Дополнительная проба пустого входа

Пустой `paths: {}` не был принят как успешный результат: CLI завершился rc=1 до отчёта с `KeyError: '/v1/session'`. Это не ложная зелень, однако также не структурный именованный `FAIL_STATIC`.

## Требуемая правка автора

Убрать metadata-исключение из проверки фактического required strong `If-Match`; валидировать его schema против strong target ETag; для CREATE/APPEND определять versioned-цель по ETag на wire независимо от конкретного 2xx-кода (либо строго доказать семантику create отдельным проверяемым признаком). После этого повторить положительный control и три указанных мутанта.
