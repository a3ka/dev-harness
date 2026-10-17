FAIL

Суд круга 2 предмета 993 на свежем `a3ka/Complior-back` в точном detached
commit `b84564557d84ad80fab4f86e3d2dad5bdc93ca9c`.

## Закрытие находок круга 1

### PR_ZONE_VIOLATION — закрыто

Точная команда из задания:

```sh
git diff --name-only 842f4e99d6024ab62336a6a0be787ae667fb555b..b8456455 -- evidence/ci evidence/ddl evidence/ddl013 evidence/mock evidence/policy evidence/runs evidence/ux175 tools/check_backend_provenance.py tools/check_backend_standards.py tools/check_backend_structure.py tools/requirements-backend-checks.txt tools/run_backend_ci.py
```

дала пустой stdout и rc=0. Запрещённые evidence/CI-пути и пять старых tools
в этой разности больше не изменены.

### `createIntent_policy_consistency` — закрыто

В отдельной полной копии C я заменил (в C ключ отсутствует, поэтому добавил)
`createIntent.x-operation-class` на `SAFE_READ_OVER_POST` и синхронизировал
`contracts/operation-index.json.source_sha256`, чтобы проверялся именно policy,
а не stale-hash. Живой валидатор вернул rc=1 и 56 failure IDs. По сравнению с
неизменённым baseline добавлен ровно
`createIntent_policy_consistency`; удалённых IDs нет. Статусы одного барьера:

```text
baseline:       createIntent_policy_consistency = PASS_STATIC
policy mutant:  createIntent_policy_consistency = FAIL_STATIC
```

То есть это не константная/placebo-ветвь прежнего круга.

### Отсутствующий `vs01_spec_freeze` — закрыто

В другой полной копии C удалил только `VERSION_MANIFEST.json.vs01_spec_freeze`
и запустил `tools/generate_derived.py` без `--freeze-vs01`. Генератор вернул
rc=1 и именованный отказ:

```text
VS01_SPEC_FREEZE_MISSING: VERSION_MANIFEST.json carries no vs01_spec_freeze; derived rebuild refused without an explicit --freeze-vs01 re-freeze
```

Позитивный контроль на отдельной неизменённой копии C: тот же генератор вернул
rc=0, напечатав `Derived consumers, wire and 10-route mock rebuilt` и
`Handoff hashes rebuilt: 592 files`.

## Неизменённый C

Буквальный системный `python3 tests/validate_contract_v3_9.py` не стартует в
данном окружении (`ModuleNotFoundError: No module named 'jsonschema'`). Живой
прогон с предусмотренным контрактом Python
`/tmp/dev-harness-verify/architect993-venv/bin/python3` на неизменённом C дал
rc=1, структурный report: 1491 checks, 28 negative cases, 250 examples.
Сравнение `failure_ids` с
`evidence/contracts/993/validator-baseline-honest-remainder.json` дало точное
равенство: actual=55, expected=55, unexpected=[], missing=[]. Это именно 51
`*_source_consumers`, `revokePartnerGrant_cas`, `revokeApproval_cas`,
`acknowledgeDisclosure_cas` и `revokePartnerGrant_conditional_policy`.

## Новый обход: CAS можно объявить append/create без настоящего If-Match

Это блокирует ACCEPT. Для каждого из двух известных existing-versioned target
в отдельных полных копиях C я сохранил отсутствие параметра `If-Match`, заменил
только `x-command-policy.precondition` с `VERSIONED_TARGET_CAS` на
`CREATE_OR_APPEND_NO_TARGET_CAS` и дал непустые, но ложные:

```text
precondition_target: newly recorded ... event
precondition_basis: append-only event
```

После синхронизации index source SHA валидатор не получил нового именованного
отказа, а наоборот снял ровно исходный CAS blocker:

```text
revokeApproval mutant:       rc=1, 54 IDs, removed=[revokeApproval_cas]
acknowledgeDisclosure mutant: rc=1, 54 IDs, removed=[acknowledgeDisclosure_cas]
```

Добавленных IDs в каждом опыте нет. Обе операции на исходном C прямо описаны
как state transition существующих `Approval`/`Disclosure`, где GET предоставляет
version и strong ETag; они не становятся create/append от замены двух строк
prose. Проверка сейчас требует для exemption только непустые `precondition_target`
и `precondition_basis` (`tests/validate_contract_v3_9.py:257-267`), поэтому
принимает ответ не на предметный вопрос.

Требуемая правка автора: привязать CAS-классификацию для этих операций к
проверяемому реальному target/effect (либо к закрытому source-backed набору),
а не принимать произвольные непустые строки как основания exemption. Нужны
отдельные red mutants для обеих подмен и честный control.

## Проверка `later_reads` / `getInsuredAsset`

В ещё одной полной копии C удалил только projection `screen_rows[].later_reads`
из `tools/generate_derived.py`, затем выполнил generator и валидатор. Validator
вернул rc=1 и добавил пять именованных source-consumer отказов:

```text
getInsuredAsset_source_consumers
getProtectionMap_source_consumers
getProtectionProfile_source_consumers
listInsuredAssets_source_consumers
listMemory_source_consumers
```

В частности, `getInsuredAsset_source_consumers` был `PASS_STATIC` на baseline
и `FAIL_STATIC` после удаления проекции. Этот новый путь не является обходом:
независимый `rebuild_consumers` сохраняет `later_reads` и ловит пропавший
derived consumer.

Итог: оба найденных мной дефекта круга 1 закрыты, но два живых CAS-mutant
обходят новую проверку, поэтому вердикт — FAIL.
