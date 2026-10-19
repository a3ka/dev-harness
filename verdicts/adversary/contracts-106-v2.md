FAIL
OBJECT=76f7da435e023543ec6649a7d24f05a4180a953d

## Блокер 1 — смысловая пустота CAS проходит валидатор и все 27 клеток

**Обход.** В disposable-клоне `mut-lexical-empty` я заменил все 25 значений
`x-cas-semantics` пяти CAS-операций на уникальные строки вида
`<operationId> unspecified <key> <n>`; у `requestAction` оставил формальный
`mission_invalidators: [{mission: unspecified}]`; у `revokePermission` оставил
лексические якоря `server_recheck.resource: permission` и
`server_recheck.scope: data_scope`. Следовательно, исчезли требуемые каноном
источник точной версии, политика retry/stale/completed/concurrency, перечень
реальных изменений Mission и реальная серверная перепроверка. При этом
выполнены буквально все новые лексические условия батареи: строка длиннее 8
символов с пробелом, значения пяти операций различны, имеется вложенный
`mission`, а `permission`/`data_scope` присутствуют.

**Наблюдение и rc.** Настоящий валидатор на этом неверном дереве завершился
`rc=0`, `PASS_STATIC`, `failure_ids=[]` (1495 checks). Усиленная батарея на том
же дереве также завершилась `rc=0`: `control_green=true`, `cases=27`,
`rejected=27`, `mismatches=[]`.

Это контрпример канону §CAS и §1 контракта: проверка приняла бессмысленное
заполнение вместо предметного описания каждой операции. Она проверяет
лексические якоря, а не извлечённый смысл.

## Блокер 2 — 51 «подтверждённый потребитель» можно заменить одним шаблоном и пустым источником

**Обход.** В disposable-клоне `mut-consumer-template-stub` для всех 51 записей
`workflow_consumers` заменены `owner` на `confirmed consumer`, `guard` на
`scenario unspecified`, `phase` на `CONFIRMED`, `acceptance_status` на
`ACCEPTED`, а `source_ref` — на новый поставленный пустой файл
`evidence/contracts/106/empty-consumer-source.md`. Волны и типы оставлены,
затем штатно выполнен `generate_derived.py` (включая FILES.sha256).

**Наблюдение и rc.** Валидатор: `rc=0`, `PASS_STATIC`, `failure_ids=[]`
(1495 checks). `verify_handoff.py`: `rc=0`,
`all_manifest_files_and_hashes=PASS`. Усиленная батарея: `rc=0`,
`control_green=true`, `cases=27`, `rejected=27`, `mismatches=[]`.

Это нарушает §2 и канон §Потребители: у записей больше нет конкретного
сценария, роли и подтверждённого источника. Текущая проверка принимает строку
статуса с подстрокой `status` и существование файла, но не содержание,
предметность или различимость сценариев всех 51 потребителя.

## Перепрогон обходов круга 1

Усиленная батарея (27 клеток) теперь отвергает все пять старых входов:

- `cas-gibberish`: `rc=1`, `CAS_SEMANTICS_TRIVIAL:acknowledgeDisclosure:version_source` (и остальные четыре поля);
- `fake-consumer`: `rc=1`, `CONSUMER_SOURCE_UNRESOLVED:streamMissionEvents`, `CONSUMER_WAVE_MISMATCH:streamMissionEvents:x!=W0`;
- `revoke-gibberish`: `rc=1`, `CAS_IDEMPOTENT_RECHECK_TRIVIAL:revokePermission:resource` и `:scope`;
- `files-missing`: `rc=1`, `FILES_MANIFEST_UNRESOLVED:evidence/contracts/106/not-delivered.json`; отдельно `verify_handoff.py` на том же входе `rc=1`, `AssertionError` с этим путём;
- `idempotent-outside`: `rc=1`, `CAS_PROFILE:acknowledgeDisclosure:precondition=IDEMPOTENT_TARGET_REVOKE`, а настоящий валидатор отдельно `rc=1`, `failure_ids=["acknowledgeDisclosure_cas"]`.

Однако заявление, что первые три барьера перенесены именно в валидатор,
не подтверждено: старые `cas-gibberish`, `fake-consumer` и `revoke-gibberish`
дают валидатору соответственно `rc=0`, `PASS_STATIC`, `failure_ids=[]`.
Их ловит только внешняя батарея.

## Проверенные неуспешные направления

- Замена deprecated `getProtectionMap` на другой operationId при сохранении
  чисел 163/19 не проходит: генератор `rc=1` (`KeyError: getProtectionMap`),
  а до генерации валидатор `rc=1` с `getProtectionMap_index_row_resolvable`,
  `index_source_sha256`, `getProtectionMapReplacement_source_consumers`.
- Подмена `@validate-out` на `true` делает шаг проверки в package-логе зелёным
  за `0.0 s`, но весь `package` не является зелёным (`rc=1`) из-за неизменённого
  FILES.sha256 и отсутствующего системного модуля `pypdf`; поэтому это не
  предъявляется как сквозной обход.

## Scoped-прогоны OBJECT

- `python3 tests/validate_contract_v3_9.py --out …` — `rc=0`, `PASS_STATIC`,
  1495 checks, `failure_ids=[]`.
- `python3 tools/generate_derived.py` — `rc=0`; затем
  `git diff --exit-code` — `rc=0`.
- `python3 tools/verify_handoff.py` — `rc=0`,
  `all_manifest_files_and_hashes=PASS`.
- `python3 tools/validate_alignment_11782_31422.py` — `rc=0`,
  `operations=163`, `deprecated=19`.
- `sha256sum -c FILES.sha256` — `rc=0`.
- `python3 tools/validate_invitation_target_31421.py` — `rc=1` до предмета:
  в системном Python нет `pypdf` (`ModuleNotFoundError`). Указанный в задании
  venv `/tmp/dev-harness-verify/architect993-venv/bin/python` исчез во время
  прогона (`ENOENT`); этот инфраструктурный отказ не является находкой по C.

ЗОНА: `wire-5_8.schema.json` — ожидает решения консультанта. Блокером не
считаю: на OBJECT повторная генерация — no-op; если вернуть этот файл к байтам
B, `generate_derived.py` меняет именно его (дифф 1 insertion/1 deletion), то
есть это производный вывод in-zone правки.

## Сырые команды

```sh
python3 /tmp/dev-harness-worktrees/c907157c/wip-106-architect-j2/fixtures/workshop_project/spec584_106/probe.py \
  --repo /tmp/dev-harness-verify/Adv106r2/mut-lexical-empty \
  --out /tmp/dev-harness-verify/Adv106r2/probe-lexical-empty --py /usr/bin/python3
python3 /tmp/dev-harness-worktrees/c907157c/wip-106-architect-j2/fixtures/workshop_project/spec584_106/probe.py \
  --repo /tmp/dev-harness-verify/Adv106r2/mut-consumer-template-stub \
  --out /tmp/dev-harness-verify/Adv106r2/probe-consumer-template --py /usr/bin/python3
python3 tests/validate_contract_v3_9.py --out /tmp/dev-harness-verify/Adv106r2/out-object-validator
python3 tools/generate_derived.py && git diff --exit-code
python3 tools/verify_handoff.py
python3 tools/validate_alignment_11782_31422.py
sha256sum -c FILES.sha256
```

## Совет автору

Сверяйте CAS-семантику с закрытым, предметным словарём по каждой операции
(включая допустимые Mission invalidators и типы target/scope), а не по длине и
ключевым подстрокам. Для 51 потребителя предъявляйте разрешимый нормативный
источник с непустым подтверждающим содержимым и проверяйте соответствие
конкретного сценария/роли, а не существование файла и поле `*status`.
