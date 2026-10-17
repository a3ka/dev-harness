accept

# Критик — контракт 993 (CMP-BCK-121), круг 2

Предмет: `contracts/993-cmp-bck-121-validator-5-8-3.md` на `wip/993/architect` @ `513b65ec5c500560d7a371ad7c38105665ce79a5`. Дельта против круга 1 (`0de60626`): контракт +23/−5, `coverage_models.py` (новый), `handoff_models.py`, `handoff_probe.py`, `probe.py`.
Свой клон: `/tmp/dev-harness-verify/critic993r2-1792264135-3811072/repo`. B = Complior-back `842f4e99d6024ab62336a6a0be787ae667fb555b` в `/tmp/dev-harness-verify/critic993-1792262860-3811072/cback` (артефакты круга 1, использованы только на чтение; батареи копируют дерево во временный каталог). PY = `/tmp/dev-harness-verify/architect993-venv/bin/python`.

Набор артефактов полон: предмет закоммичен, у каждого пункта критерия есть команда, исполнители и ЗОНА-строки названы. Door `scripts/make_task.sh --repo <клон> --role critic --contract 993 --model-trace /tmp/dev-harness-verify/orchbrief/full_trace.tsv` перечитан: rc0, ZONES совпадают с :122–134.

## Блокеры круга 1 — закрыты живым прогоном на тех же артефактах

Закрыт блокер 1 (handoff: сужение FILES.sha256 до db/001–013), :115, :117.
Субъектом взят неизменённый `narrowed.py` круга 1 (sha256 `9b71e1770435866e7dd92c0be16b06afdd9da0447003853bcc9e5deafb8333c0`). Команда `PY H/…/handoff_probe.py --repo B --out … --subject narrowed.py` даёт `cases=46 mismatches=4 baseline_green=True` и rc1. В круге 1 было `cases=42 mismatches=0` и rc0. Красные ровно четыре новые клетки `corrupt-outside-db`, `corrupt-014`, `missing-file-outside-db`, `missing-file-014`: суженный CLI на них отвечает rc0 при ожидаемом rc1. Значит обход круга 1 теперь ловится. Исходный CLI B на той же батарее даёт `cases=46 mismatches=15` и rc1 (`add-014`, `add-014-015`, 13×`missing-entry`), то есть старый CLI по-прежнему отличается от исправленного. Результат `handoff_models.py` записан в §Сверено.

Закрыт блокер 2 (охват operationId не измерялся), :105–111.
`probe.py:required_checks()` вычисляет ожидаемое множество из OpenAPI. Источником служат не index, не `cases()` и не отчёт субъекта. `coverage_failures()` сверяет это множество с `report.checks[].id` у каждого контроля, а `control_ok` теперь требует `not coverage`. Именно это я назвал закрытием в круге 1. Команда `PY H/…/coverage_models.py --repo B --out …` даёт rc0, в выводе: `full_existing_coverage_rc=0`, `cases_only_coverage_rc=1`, `reason=["CHECK_COVERAGE_MISSING:getSession_source_consumers"]`, `existing_required_checks=714`, `literal_complete_coverage_rc=0`, `individual_omissions_rejected=20`. Значит CLI, который обходит только operationId из `cases()`, получает именованную нехватку по операции вне `cases()`. Ключи расширений, от которых зависит применимость, в OpenAPI B есть: `x-authentication-policy` 1, `x-command-policy` 83, `mutation: false` 1, `x-conditional-policy` 2, `requestBody:` 82. Значит ни одно правило покрытия не выключено вхолостую из-за несуществующего ключа.

## `CHECK_COVERAGE_INVALID_REPORT` на `request-example-createIntent` — штатно, не третий блокер

Повторил живьём: `PY H/…/probe.py --repo B --out … --case request-example-createIntent` даёт rc1, `control_rc=1 mutant_rc=1 mismatches=1` и строку `993 case=request-example-createIntent CHECK_COVERAGE_INVALID_REPORT`. Разбор по `raw.json` такой. У контроля и у мутанта последняя строка stderr — `KeyError: 'requestBody'`, `report=None`: исходный bodyless crash, `contract-validation.json` не записан. `probe.py:run()` (:201–208) в этом случае возвращает `report=None`. `coverage_failures(None, …)` возвращает `CHECK_COVERAGE_INVALID_REPORT`, как и требует :107 («отсутствующий/неструктурный checks»). Контроль был бы красным и без нового контроля (`rc≠0`). Новая причина только дописывает, почему отчёта нет, и в `raw.json` лежит отдельно от failure_ids, `expected_check_ids` = 1291. Это ожидаемое следствие интеграции на B, где все 40 контролей уже красные исходным crash (§Замер). Архитектор это объяснил: :227, «(исходный bodyless crash)». Обхода здесь нет: на C зелёный контроль требует и отчёт, и полное покрытие.

## Сверено

- `bash scripts/check_precision_gate.sh <клон> contracts/993-…md` даёт `OK`, rc0. Норма 043 выполнена: в контракт добавлен guard `coverage_models.py`.
- `bash scripts/check_threat_model.sh <клон> contracts/993-…md`: секция валидна (ЗАЩИЩАЕТ 3, НЕ ЗАЩИЩАЕТ 4), rc0.
- `bash scripts/check_zones.sh` даёт rc0 (замороженных контрактов 99, проверено по зонам 2925).
- `PY H/…/handoff_models.py --repo B --out …` даёт rc0. По моделям: old — rc1, 46/15 (свидетель add-014); corrected — rc0, 46/0; deleted-count-only — rc1, 2/1 (missing-entry-001); skipped-hash — rc1, 2/1 (corrupt-001); historical-only — rc1, 46/4 (corrupt-outside-db). Числа архитектора на :223 воспроизведены.
- Новые файлы батареи лежат в `fixtures/workshop_project/validator_993/`, это зона architect (:122). Зона implementer в Complior-back не изменилась (:134).

## Советы

СОВЕТ contracts/993-cmp-bck-121-validator-5-8-3.md:107 — проверяется наличие строки `report.checks[].id`, а не то, что правило действительно вычислено. Идиома CLI B `check(name, ok)` (`tests/validate_contract_v3_9.py:16`) создаёт строку только при вычислении предиката. Поэтому естественное сужение («не вызывать правило для операции вне X») пропуск строки даёт, и контроль его ловит. Мимо проходит только намеренный `check(id, True)` для операций вне `cases()`. Это подделка, а не дефект реализации, и её закрывает суд reviewer по пункту 5. Дешёвая страховка: один мутант на операции вне `cases()`, выбираемой в прогоне (например, `getSession` с пустыми consumers и ожиданием `getSession_source_consumers`).

СОВЕТ contracts/993-cmp-bck-121-validator-5-8-3.md:107 — `CHECK_COVERAGE_INVALID_REPORT` сливает в одну причину «отчёта нет (crash)» и «отчёт без структуры checks». На B это мешает с первого взгляда понять, что красный цвет дал crash, а не формат. Стоит развести причины (например, `CHECK_COVERAGE_NO_REPORT`), но это вкус.

СОВЕТ contracts/993-cmp-bck-121-validator-5-8-3.md:115 — в круге 1 я как закрытие просил и `missing-entry` вне db/. Архитектор его справедливо не добавил: исходный CLI сверяет только перечисленные записи, а §5 (:66) требует наличия записи лишь для 001–013. Снимаю это требование. Клетки вне db/ покрывают один путь, `README_RU.md`: CLI, подогнанный под этот путь, батарея не отличит. Это уже подделка, а не правдоподобное сужение.

СОВЕТ contracts/993-cmp-bck-121-validator-5-8-3.md:3, :9/:70, :80, :130, :233 — советы круга 1 (строка «блокируют заморозку» в замороженном тексте; лишняя зона implementer над батареей; дрейф Complior-back main от B; «точный» ID против `expected in actual_ids`; нет модели исправленного валидатора на части клеток основной батареи) остаются на усмотрение автора, accept не отменяют.

## Арбитр

Не созывается: оба блокера круга 1 закрыты, повторного FAIL нет.
