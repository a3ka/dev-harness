FAIL

# Ревью 993: CMP-BCK-121, валидатор и erratum 5.8.3 — a3ka/Complior-back PR#146, круг 1

OBJECT=19d40691da9a43f83bb5ebe938e0b05c30fcdefc
Ветка: `cmp-bck-121/validator-5-8-3`; B=`842f4e99d6024ab62336a6a0be787ae667fb555b`; merge-base с
origin/main = `f7b972913ec2af0df83ce58ea34dd688870fb0e9`. Собственные коммиты 993: 821d364, 75a2ab3,
232f805, e1f9314, 19d4069, автор `implementer`.
H: `frozen/contracts/993/1`. `git diff frozen/contracts/993/1 HEAD -- fixtures/workshop_project/validator_993/ contracts/993-*.md`
пуст: батарея не тронута.
Роль: reviewer (Reviewer993), 2026-10-17. Свежий клон `/tmp/dev-harness-verify/rv993/cback`, собственный
venv `/tmp/dev-harness-verify/rv993/venv` (jsonschema 4.26.0, PyYAML 6.0.3 по requirements-validation.txt).
Находки (reslop): `.review/2026-10-17-06.md`.

Предмет суда — только вторая ЗОНА implementer 993. `backend/` не судился. Красный lane `backend`
на #146 — не предмет этого суда (PR#147).

## Итог

| # | Находка | Класс | Блокирует |
|---|---|---|---|
| Рв993-1 | `validate_contract_v3_9.py:239/:267`: непустая строка `x-conditional-policy` заменяет If-Match у VERSIONED_TARGET_CAS. Живой мутант проходит, revokePartnerGrant без If-Match зелёный | дефект барьера (обход) | да |
| Рв993-2 | getInsuredAsset ложно в блокере: source `screen_rows[PROFILE].later_reads` не восстанавливается (§2 называет её поимённо) | семантический FAIL §2 | да |
| Рв993-3 | 9 исключений CAS обоснованы «no target ETag declared»; у revokeApproval и acknowledgeDisclosure есть versioned target | семантический FAIL §3, п.5 приёмки | да |
| Рв993-4 | `evidence/ux175/20261017T194538.144999Z/results.json` вне ЗОНА implementer | превышение зоны | да |
| Рв993-5 | README_RU.md:49 и VALIDATION.json:108–118 по-прежнему пишут о `KeyError: 'requestBody'` | ложный диагноз, п.4 приёмки | да |
| В-1 | п.2 приёмки (rc0) не выполнен: 52 `*_source_consumers`, нужно решение владельца | блокер владельца | держит слияние, implementer не виноват |
| А-1…А-5 | см. reslop | советы | нет |

Пять пунктов брифа сами по себе подтверждены живьём (ниже). FAIL вынесен не из-за них, а из-за
находок 1–5, которые эти пункты не покрывают.

## 1. Обход OpenAPI: 163 операции — своя мера

Собственный скрипт (`/tmp/dev-harness-verify/rv993/count_ops.py`): прямой обход `paths` × методов
YAML против `contracts/operation-index.json`. Валидатор не использовался.

```
## B 842f4e99d
openapi_sha256 f89b4a048f0aa405ed636bbddea4c63730d8d7607f15729f97990b6490e86e16 version 5.8.2
ops 163 unique_oid 163 missing_oid 0 deprecated 19
index source_sha256 f89b4a04… api_version 5.8.2 operation_count 163 dep_count 19
openapi-index [] index-openapi []  dep_ids_match True  method/path/deprecated/wave mismatches 0
## C 19d40691
openapi_sha256 3648853af1a2049a422254746fd4fc1416c06eee0cee6429f124d4ba835ffefa version 5.8.3
ops 163 unique_oid 163 missing_oid 0 deprecated 19
index source_sha256 3648853a… api_version 5.8.3 operation_count 163 dep_count 19
index_rows 163 index_unique 163  openapi-index [] index-openapi []  dep_ids_match True
method/path/deprecated/wave mismatches 0
```

Пересчёт на C: 163 операции, 19 deprecated. Index совпадает по множеству, method, path, deprecated,
wave и source hash. Повторный `tools/generate_derived.py` на чистом worktree C: rc0, `git status`
пуст. Значит, derived index не правлен руками и воспроизводится из canonical bindings, а сами
bindings веткой не менялись.

## 2. Валидатор живьём: счётчики и append-only

```
PY tests/validate_contract_v3_9.py --out /tmp/dev-harness-verify/rv993/out-validator
{"status": "FAIL_STATIC", "checks": 1491, "negative_cases": 28, "examples": 250, "failures": [52 × *_source_consumers], …}
rc=1
```

Своя мера по JSON отчёта (другой скрипт, `cmp52.py`): 1491 check, 1491 уникальных ID, 52 не-PASS
check. 28 negative_cases, все PASS. validated_examples 250. failure_ids 52, уникальных 52, все с
суффиксом `_source_consumers`. Status FAIL_STATIC, runtime NOT_RUN_BY_THIS_VALIDATOR.
Заявление implementer (1491 / 250 / 28 / 52) совпало.

Сохранность 28 старых случаев: множество имён `negative(...)`/`semantic(...)` в исходнике B и C
одинаково (sha256 списка `05862a43…` на обоих), по 26 вызовов; цикл hidden-state даёт ещё 2, итого 28.

Append-only. Запуск без `--out` создал только новый untracked каталог
`evidence/contracts/20261017T205433.749053Z/` (`mkdir(exist_ok=False)`). Сводный sha256 содержимого
всего `evidence/` до прогонов и после удаления моего каталога одинаков:
`3d7b4eea771b19bbb757b9f0b16972a49f4a93af0abc795deeeac17f68c60142`. Ни одна старая запись не
переписана.

Evidence implementer привязано к C: `input_sha256` в `validator-baseline-52-consumers.json` и в
контролях `probe-battery-raw.json` побайтно совпадает с файлами C (0 расхождений из 9).

## 3. Handoff: FILES.sha256 и db/014

```
PY tools/verify_handoff.py
{"status": "PASS_STATIC", "schema_documents": 13, "all_manifest_files_and_hashes": "PASS", "runtime_acceptance": "NOT_ASSERTED"}
rc=0
sha256sum --quiet -c FILES.sha256 → sha256sum_rc=0
wc -l FILES.sha256 → 611; git ls-files → 612; comm: в git, но не в FILES — только FILES.sha256; в FILES, но не в git — ничего
db/ в FILES.sha256: 14 записей (001…013 + 014_api_reads_migration_ledger.sql)
git diff --stat 842f4e99d..C -- db/ → только db/014 (+11; пришёл с main CMP-BCK-126, не из 993)
```

Батарея H, своя прогонка:
`PY H/fixtures/workshop_project/validator_993/handoff_probe.py --repo R --out /tmp/dev-harness-verify/rv993/out-handoff`
→ `993 handoff cases=46 mismatches=0 baseline_green=True`, rc=0. Совпали все клетки: baseline,
add-014, add-014-015, corrupt/missing-file/missing-entry 001–013, corrupt и missing вне db, 014.

Отрицательная пара VS01 (п.4 приёмки): в манифест на копии возвращён старый hash `39f34f29…`,
`generate_derived.py` → rc1, последняя строка stderr
`AssertionError: Frozen VS01 specification changed; do not silently update baseline`, дерево после
восстановления чистое. Новый hash `7d5c893a…` проходит генератор rc0. В
`VERSION_MANIFEST.json.vs01_spec_freeze.re_freeze_provenance` сохранены old_sha256, old_api,
base_commit, authority и прежняя change_policy: старое решение не удалено.

`tools/validate_alignment_11782_31422.py` rc0, `tools/validate_invitation_target_31421.py` rc0 (rc
сняты без pipe). npm test не запускался: это прогон владельца интеграции по п.4.

## 4. backend/

- `git diff --stat 842f4e99d..19d40691 -- backend/` **не пуст**: 287 файлов, +14690. Команда
  брифа дала бы ложное «изменено».
- Причина: ветка перебазирована на `origin/main` f7b9729, merge-base = origin/main. Backend
  пришёл слияниями #136–#145.
- Собственные коммиты 993: `git diff --quiet f7b9729 C -- backend/ infra/ db/ .github/` rc=0,
  `git log f7b9729..C -- backend/` — 0 коммитов.

Вывод: 993 backend не трогал, красный lane backend — не регрессия 993. Не блокирует.

## 5. Блокер-файл 52 против живого прогона

Своя мера: суффикс снят с live failure_ids и сравнен как множество с файлом.

```
live 52 blk 52 52 equal True sorted_file True
active ops с пустыми consumers: B 75, C 52; C == blocker: True
blocker ∩ deprecated: ∅
```

Файл совпадает с живым прогоном, а bindings веткой не менялись, так что ничего не выдумано. Но
одна из 52 строк ложная: getInsuredAsset разрешается реальным source screen metadata — Рв993-2.
Перед вынесением на владельца реальный остаток — 51.

Восстановлены 23 action-read связи, перечисленные в §2: у каждой из 23 consumers на B было 0, на C
от 1 до 17. getProtectionMap не подставлен.

Батарея H по evidence implementer (своя мера, не счётчик раннера): 40 cases, scenarios 1–17. У всех
40 контроль rc1 и failure_ids контроля = ровно блокер-52. У всех 40 мутант rc1, ожидаемый ID в
мутанте есть, в контроле нет. coverage_failure_ids пуст у всех. Сверх блокера у мутанта 1 лишний ID
в 31 случае и 2 в 9 (парные `_cas`/`_problem` и `_consumer_resolution`/`_source_consumers`).
Полный прогон `probe.py` — круг адверсария, здесь не повторялся.

## Находки — по одной

**Рв993-1 (блокер, обход барьера).**
- Код: `tests/validate_contract_v3_9.py:239`
  `strong_target='If-Match' in headers or (…dict existing_update If-Match…) or (isinstance(conditional,str) and bool(conditional.strip()))`;
  `:267` так же принимает любую непустую строку в `_conditional_policy`.
- Красное предъявлено живьём на копии C (`/tmp/dev-harness-verify/rv993/mutant_cas.py`):

  ```
  revokeAccountSession: removed If-Match params: 1 precondition: VERSIONED_TARGET_CAS
  mode plain rc 1 revokeAccountSession_cas FAIL_STATIC failures beyond 52-blocker: ['revokeAccountSession_cas']
  mode prose rc 1 revokeAccountSession_cas PASS_STATIC failures beyond 52-blocker: []
  ```

- В поставке: `revokePartnerGrant` (OpenAPI:12121) — `VERSIONED_TARGET_CAS`, If-Match нет, `_cas`
  PASS_STATIC через строку `EXPECTED_GRANT_VERSION_AND_CURRENT_PERMISSIONS_VERSION`. Из 47
  versioned операций это единственная без If-Match.
- Нарушены: §3, пункты 3 и 2 (missing target CAS → остановка и compatibility-решение); п.5
  приёмки («regex непустой prose не доказательство»).

**Рв993-2 (блокер, семантика §2).**
- Обязательство §2: «screen producer/refresh/later-read… getInsuredAsset дополнительно
  разрешается через реальные screen metadata».
- Результат: строка `getInsuredAsset` в `evidence/contracts/993/remaining-source-consumers-blocker.txt`;
  `getInsuredAsset_source_consumers` FAIL_STATIC.
- Источник: `sources/frontend-ux1_17_5/BrokerOS_Mobile_Design_Data.json:28986` (PROFILE.later_reads).
- `validate_contract_v3_9.py:70` и `generate_derived.py:122` читают только `bindings.screen_reads`.

**Рв993-3 (блокер, семантика §3).** Обязательства: §3, пункт 1 (CAS не зависит от наличия If-Match),
§3, пункт 2 (basis = эффект + основание create/append; missing target CAS → стоп), п.5 приёмки.

| operationId | Путь | Basis (фрагмент) | Противоречие |
|---|---|---|---|
| revokeApproval | POST /v1/approvals/{approval_id}/revocations (OpenAPI:3397) | «no versioned target ETag is declared on the wire» | возвращает `Approval` с `version`, getApproval отдаёт ETag: versioned target есть |
| acknowledgeDisclosure | POST /v1/disclosures/{disclosure_id}/acknowledgements (OpenAPI:592) | «state transition … no target ETag is declared» | возвращает `Disclosure` с `version` + ETag; basis сам называет эффект переходом |
| revokePermission, postMessage, registerDevice, acceptPartnerInvitation, proposePartnerProgramme, ingestCommissionCash, provisionInsuranceMailbox | — | тот же шаблон «no (versioned) target ETag is declared» | основание — запрещённый признак, а не create/append |

**Рв993-4 (блокер, зона).** `evidence/ux175/20261017T194538.144999Z/results.json` (коммит 821d364) —
вне второй ЗОНА implementer и против условия владельца («новый verification evidence … в
`evidence/contracts/993/`»).

**Рв993-5 (блокер, ложный диагноз).** `README_RU.md:49` («rc 1 (`KeyError: 'requestBody'`, строка 53)
… код tests не изменён») и `VALIDATION.json:108–118` не соответствуют живому C. Нарушены п.4 приёмки
и AGENTS.md, правило 7.

**В-1 (блокер владельца).** п.2 приёмки требует rc0. Живьём rc1 на 52 (реально 51)
`*_source_consumers`. Контракт запрещает invented binding; нужно решение владельца. Это не дефект
implementer.

## Чек-лист роли

1. Область правки. 23 файла `f7b9729..C`, 22 в зоне. Превышение — evidence/ux175 (Рв993-4).
2. Сырой вывод. Всё выше — живые прогоны ревьюера с rc. Evidence implementer привязано к байтам C.
3. Проверка не подогнана. Батарея H с freeze не тронута. 28 старых negative cases сохранены
   поимённо. Сам валидатор в зоне implementer — это реализация, а не чужой барьер. Его ослабление
   найдено отдельно: Рв993-1.
4. Красное. Мутанты H: 40/40 с точным ID (evidence, своя мера). Мой мутант Рв993-1 показывает
   красный без прозы и ложный зелёный с прозой.
5. Атомарность. 5 коммитов одного предмета, каждый с CMP-BCK-121 (совет А-5).
6. Норма. Нормативных документов Complior-back вне зоны ветка не трогает. Правка
   `Complior_Backend_Architecture_v3_14_RU.md:300` (§18) разрешена владельцем.
7. Счётные утверждения своей мерой:
   - 163/19 операций — свой обход;
   - 1491/28/250/52 — разбор JSON;
   - 611 записей FILES.sha256 — `sha256sum -c` и сравнение с git ls-files;
   - 46/0 handoff — свой прогон H;
   - 40/17 мутантов — разбор raw.json.

   Всё совпало, кроме смысла одной строки блокера (Рв993-2).

## Паразитная сложность (контракт 050) — пять вопросов

- **`tests/validate_contract_v3_9.py` (переписан, +~260).**
  1. Свойства §1–3 и п.2–3 приёмки.
  2. Новое состояние — только evidence-каталог, явно через `--out`/stdout.
  3. Свойство consumers живёт в 2 файлах (валидатор + `generate_derived.py`); этого требует
     контракт («сравнить с derived graph»).
  4. Интерфейс не вырос: один флаг `--out`, rc 0/1.
  5. Потребитель — README и `probe.py`.

  ESSENTIAL. Исключение — строковая ветвь `:239/:267`: ACCIDENTAL и обход (Рв993-1). Более
  простая форма без неё проходит те же строки.
- **`tools/generate_derived.py` (+26).**
  1. §2 (READ-связи) и §4 (обнаружение новых examples полным обходом).
  2. Новых состояний нет.
  3. Число связанных файлов прежнее.
  4. Интерфейс без изменений.
  5. README.

  ESSENTIAL.
- **`tools/verify_handoff.py` (+6/−1).**
  1. §5.
  2. Новых состояний нет.
  3. 1 файл.
  4. Интерфейс прежний.
  5. Handoff-батарея и README.

  ESSENTIAL.
- **`contracts/backend-5_8_3-alignment.json` (новый).**
  1. Допуск владельца «проверяемый accepted alignment».
  2. Явный JSON.
  3. Связан с `validate_alignment_11782_31422.py`.
  4. Интерфейса нет.
  5. Потребитель — `validate_alignment` (rc0).

  ESSENTIAL.
- **`VERSION_MANIFEST.json.re_freeze_provenance`.**
  1. §4: old/new/source/основание.
  2. Явное поле.
  3. Свойство в 1 файле.
  4. Интерфейса нет.
  5. Генератор (assert freeze).

  ESSENTIAL.
- **`x-command-policy.precondition*` в OpenAPI (82 операции).**
  1. §3, пункт 2.
  2. Явная metadata.
  3. Свойство в OpenAPI и валидаторе.
  4. Интерфейса нет.
  5. Валидатор.

  ESSENTIAL по форме. Содержание 9 basis — Рв993-3.
- **Семья evidence `evidence/contracts/993/*` (4 файла).**
  1. Условие владельца про evidence.
  2. Явные файлы.
  3. Обновляются вместе с FILES.sha256.
  4. Интерфейса нет.
  5. Потребитель — суд.

  ESSENTIAL. `probe-battery-raw.json` в 550 635 строк велик, но это сырой вывод, а не логика.
- **`evidence/ux175/20261017T194538…/results.json`.**
  1. Свойство не названо.
  2. Побочный эффект `verify_ux175.py`.
  3. Новых связанных файлов нет.
  4. Интерфейса нет.
  5. Потребителя в зоне нет.

  ACCIDENTAL и вне зоны (Рв993-4).

## Что нужно для ACCEPT

1. Закрыть Рв993-1…5 по `.review/2026-10-17-06.md`.
2. Перегенерировать FILES.sha256 и evidence на новом C.
3. Прогнать батарею H на том же C адверсарием.
4. Получить решение владельца по В-1 (51 операция) и по compatibility revokePartnerGrant и
   versioned-целям Рв993-3.

Новый C не наследует этот вердикт: нужен новый круг на новом OBJECT.
