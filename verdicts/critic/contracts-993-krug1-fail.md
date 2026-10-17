FAIL

# Критик — контракт 993 (CMP-BCK-121), круг 1

Предмет: `contracts/993-cmp-bck-121-validator-5-8-3.md` на `wip/993/architect` @ `0de6062605e3646e4471b24fbb92130799362263`.
Модель: critic, круг 1. Свой клон: `/tmp/dev-harness-verify/critic993-1792262860-3811072/repo`; Complior-back B = `842f4e99d6024ab62336a6a0be787ae667fb555b` в `…/cback`; PY = `/tmp/dev-harness-verify/architect993-venv/bin/python` (jsonschema 4.26.0).

Набор артефактов полон: предмет закоммичен, критерий с командами есть, исполнители и ЗОНА-строки названы.

## Блокирующие находки

БЛОКИРУЕТ contracts/993-cmp-bck-121-validator-5-8-3.md:107 (с :66, :109) — handoff-батарея не отличает реализацию, которая выбросила общую проверку всех записей FILES.sha256, хотя :66 прямо требует её сохранить («одного удаления assert количества недостаточно»), а owner §3 разрешает только снять «ровно 13». Все 42 клетки `handoff_probe.py:cases()` портят только db/001–013; ни одна не трогает запись вне db/ и ни одна не трогает 014+ («с той же проверкой записанных файлов», :66). Модели `handoff_models.py` ловят лишь `deleted-count-only` и `skipped-hash`, сужение они не моделируют.
ОБХОД (живой прогон, не вывод): `tools/verify_handoff.py`, в котором assert `==13` удалён, а цикл `for line in FILES.sha256: … is_file … sha256==sha` заменён проверкой только записей db/001–013 (существование, запись, sha256). `PY handoff_probe.py --repo <B> --out … --subject narrowed.py` → `993 handoff cases=42 mismatches=0 baseline_green=True`, rc0. На копии B с одним байтом, дописанным в `README_RU.md` (одна из 268 записей FILES.sha256): исходный CLI → rc1 `AssertionError: README_RU.md`, суженный CLI → rc0 `{"status": "PASS_STATIC", …, "all_manifest_files_and_hashes": "PASS", …}`. Критерий 4 (`PY tools/verify_handoff.py` rc0) этот обход тоже пропускает. Закрытие: клетки corrupt/missing-file/missing-entry хотя бы для одной записи вне `db/` и для добавленного db/014 с ожиданием `AssertionError: <путь>`, плюс модель «сужение до 001–013» в `handoff_models.py`, которая обязана краснеть.

БЛОКИРУЕТ contracts/993-cmp-bck-121-validator-5-8-3.md:79 (с :80, :103) — пункт «все исходные operationId проверены» не измеряется ни одной названной командой. `probe.py` портит только перечисленные в `cases()` операции, а у контроля проверяет лишь `rc0/PASS_STATIC/failure_ids==[]` (`probe.py:229–231`). Охват каждого правила по всем применимым операциям нигде не сверяется.
ОБХОД: `tests/validate_contract_v3_9.py`, в котором правила `source_consumers`, `request_example`, `cas`, `csrf`, `problem`, `contract_scope_policy`, `provider_auth` и т. д. исполняются только для operationId из `probe.py:cases()` (createIntent, updatePersonalProfile, previewPartnerInvitation, logoutSession, revokeMailboxGrant, revokeAccountSession, createPlateCheck, listPostItems, …). Каждый контроль зелёный, каждый мутант получает точный `<oid>_<suffix>`, критерий 2 даёт rc0 и `failure_ids=[]`, критерий 4 зелёный тем же валидатором. При этом 75 активных операций с пустыми consumers (на B — `source_consumers`=132) и CAS dispositions 36 команд остаются нетронутыми. Критерий 5 когнитивный и охват правил не предписывает. Закрытие: у каждого контроля `probe.py` сверяет `report['checks']` (id имеют форму `<oid>_<rule>`, см. `check()` в CLI) с множеством, которое независимо вычисляет `probe.py:operations()`. Например, `<oid>_source_consumers` для каждой активной операции, `<oid>_request_example` для каждой операции с requestBody, policy/CAS-проверка для каждой mutation. Нехватка → rc1 с именем.

## Сверено и подтверждено

- Зона (:126) против owner. База `docs/owner/2026-10-17-resheniya-back-992-993.md` §4 — 7 путей; `docs/owner/2026-10-17-resheniya-1810.md` §3 (`b469ca44f`) добавляет 9 путей и `tools/verify_handoff.py`. Строка :126 совпадает с ними ровно. `contracts/backend-5_8_3-alignment.json` ⊂ `contracts/`, `evidence/contracts/993/` ⊂ `evidence/contracts/`: оба названы owner-текстом, лишнего пути нет. `backend/` исключён.
- Инвариант :66 против owner §2/§3 («db/001–013 обязаны побайтно совпадать с FILES.sha256, 014+ допускаются»): по смыслу совпадает. Существование и запись следуют из побайтного совпадения с FILES.sha256.
- Живой прогон `PY handoff_models.py --repo <B> --out …/models-out` → rc0. Результаты: `old` rc1 cases=42 mismatches=15 (witness add-014); `corrected` rc0 42/0; `deleted-count-only` rc1 2/1 (missing-entry-001); `skipped-hash` rc1 2/1 (corrupt-001). Числа прогона архитектора (:214) воспроизведены, старый и новый CLI батарея различает. Но различимость доказана только для двух смоделированных обманов, см. блокер 1.
- `bash scripts/check_precision_gate.sh <клон> contracts/993-…md` → `OK`, rc0. `bash scripts/check_threat_model.sh <клон> contracts/993-…md` → секция валидна (3/4 буллетов), rc0. `bash scripts/check_zones.sh` → rc0. Мой вызов `scripts/pre_critic.sh 993` дал rc2 `NOT_IMPLEMENTED: контракт не найден: 993`. Вероятно, я передал аргумент не в той форме; в зачёт идёт зелёный прогон оркестратора на этом же sha.

## Советы

СОВЕТ contracts/993-cmp-bck-121-validator-5-8-3.md:3 — «открытые зависимости ниже блокируют заморозку». После снятия зонного блокера в :220–221 остались поставки implementer'а, а не условия заморозки. В замороженном тексте строка будет противоречить самому факту заморозки, её стоит переформулировать.

СОВЕТ contracts/993-cmp-bck-121-validator-5-8-3.md:122 — `ЗОНА implementer: fixtures/workshop_project/validator_993/` механически разрешает implementer'у править батарею, а :120 эту правку запрещает. Обхода нет: критерий 3 исполняет замороженные bytes H. Но зона либо лишняя, либо стоит назвать, что именно implementer туда пишет.

СОВЕТ contracts/993-cmp-bck-121-validator-5-8-3.md:9 / :70 — Complior-back main ушёл от B: `origin/main` = `89246c8`, в `db/` уже лежит `014_api_reads_migration_ledger.sql`, а значит исходный CLI на main уже красный. Если C ответвляется от main, то B меняется, и по :70 это новые evidence. Лучше зафиксировать это до раздачи. Попутно (вопрос 3): на таком C клетка `add-014` даёт два файла `014_*`. Контракт не говорит, что CLI не вправе требовать уникальность номера для 014+.

СОВЕТ contracts/993-cmp-bck-121-validator-5-8-3.md:80 — «с **точным** ожидаемым failure ID»: код проверяет `expected in actual_ids` (`probe.py:234`), то есть допускает и посторонние ID у мутанта. Стоит выровнять прозу по коду или код по прозе.

СОВЕТ contracts/993-cmp-bck-121-validator-5-8-3.md:220 — у основной батареи 40/40 клеток красные исходным crash, а у handoff-батареи доказательство различимости есть (`handoff_models.py`). Без хотя бы точечной модели исправленного валидатора на части клеток остаётся риск недостижимого ожидаемого ID, а он лечится переписыванием фикстур после раздачи.

## Арбитр

Не созывается: круг 1, повтора причины нет.
