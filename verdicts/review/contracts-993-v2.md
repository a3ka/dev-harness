FAIL

# Ревью 993, круг 2: CMP-BCK-121, валидатор и erratum 5.8.3 — a3ka/Complior-back PR#146

- OBJECT: `b84564557d84ad80fab4f86e3d2dad5bdc93ca9c`. Ветка `cmp-bck-121/validator-5-8-3`, голова
  origin совпадает с OBJECT.
- B: `842f4e99d6024ab62336a6a0be787ae667fb555b`. Merge-base с origin/main:
  `f7b972913ec2af0df83ce58ea34dd688870fb0e9`.
- Новые коммиты круга 2: 3d4651e, 8584f00, b845645, автор `implementer`.
- H: `frozen/contracts/993/1`. `git diff --stat frozen/contracts/993/1 HEAD --
  fixtures/workshop_project/validator_993/ contracts/993-*.md` пуст: батарея и контракт не тронуты.
- Роль: reviewer (Reviewer993Round2), 2026-10-17.
- Свежий клон: `/tmp/dev-harness-verify/rv993r2/cback`. venv:
  `/tmp/dev-harness-verify/rv993/venv` (jsonschema 4.26.0, по requirements-validation.txt).
- Находки (reslop): `.review/2026-10-17-07.md`. Предыдущий круг:
  `verdicts/review/contracts-993-v1.md`, `.review/2026-10-17-06.md`.

Вердикт привязан к этому OBJECT. Новый C его не наследует.

## Итог

| # | Находка | Класс | Статус круга 2 | Блокирует |
|---|---|---|---|---|
| Рв993-1 | CAS-обход прозой `x-conditional-policy` | дефект барьера | ЗАКРЫТО, живой мутант | нет |
| Рв993-2 | getInsuredAsset ложно в блокере | семантический FAIL §2 | ЗАКРЫТО, живые красные 3/3 | нет |
| Рв993-3 | CAS-основания «no ETag declared» | семантический FAIL §3 | ЧАСТИЧНО: revokePermission — ложный факт в основании | да |
| Рв993-4 | evidence/ux175 вне зоны | превышение зоны | ЗАКРЫТО в узком смысле, исправление дало Рв993-6 | нет |
| Рв993-5 | ложный диагноз KeyError в README/VALIDATION | ложный диагноз, п.4 приёмки | ЗАКРЫТО | нет |
| **Рв993-6** | PR удаляет 21 файл main (CI-оркестратор и прежнее evidence); CI PR#146 на C красный во всех 7 lanes | превышение зоны, регрессия main | новое | **да** |
| **Рв993-7** | `VERSIONED_TARGET_CAS` принимает необязательный и не-header If-Match; requestAction в поставке ложно зелёный | дефект барьера (обход §3 п.3) | новое | **да** |
| **Рв993-8** | VALIDATION.json:128–129 «BYTE_IDENTICAL…3.14.2.2» и «vs01_freeze UNCHANGED» ложны на C | ложный диагноз, п.4 приёмки | новое | **да** |
| В-1 | 55 именованных отказов (51 consumers + 3 CAS + 1 conditional) | блокер владельца | честный остаток, не регрессия | держит слияние, implementer не виноват |
| А-1…А-4 | см. reslop | советы | — | нет |

Все пять находок круга 1 по существу закрыты, кроме одного основания в Рв993-3. FAIL вынесен из-за
трёх новых блокеров. Самый тяжёлый — Рв993-6: в нынешнем виде merge ломает CI main.

## 1. Рв993-1 — живой мутант (своя мера)

Скрипт круга 1 `/tmp/dev-harness-verify/rv993/mutant_cas.py` на копии C. В колонке «сверх» —
failure_ids сверх старого 51-блокера.

```
removed If-Match params: 1 precondition: VERSIONED_TARGET_CAS prior conditional: None
mode plain rc 1 revokeAccountSession_cas FAIL_STATIC сверх: [acknowledgeDisclosure_cas, revokeAccountSession_cas, revokeApproval_cas, revokePartnerGrant_cas, revokePartnerGrant_conditional_policy]
mode prose rc 1 revokeAccountSession_cas FAIL_STATIC сверх: [acknowledgeDisclosure_cas, revokeAccountSession_cas, revokeAccountSession_conditional_policy, revokeApproval_cas, revokePartnerGrant_cas, revokePartnerGrant_conditional_policy]
```

В круге 1 prose давал PASS_STATIC, теперь FAIL_STATIC. `revokePartnerGrant_cas` и
`revokePartnerGrant_conditional_policy` стоят в живых failure_ids поставки (§2 ниже). Код: строковая
ветвь удалена из `validate_contract_v3_9.py:246`. `_conditional_policy` (`:266–271`) требует dict.

## 2. Валидатор живьём на C

```
PY tests/validate_contract_v3_9.py --out /tmp/dev-harness-verify/rv993r2/out-validator   → rc 1
status FAIL_STATIC  runtime NOT_RUN_BY_THIS_VALIDATOR
checks 1491 unique 1491; negative_cases 28 (все PASS_STATIC); examples 250
failure_ids 55 unique 55 → {_source_consumers: 51, acknowledgeDisclosure_cas, revokeApproval_cas, revokePartnerGrant_cas, revokePartnerGrant_conditional_policy}
```

Отчёт разбирал свой скрипт `run_val.py` по JSON, счётчики раннера не использовались. Заявление
implementer «55 = 51 + 3 + 1» совпало. Имена `negative(...)`/`semantic(...)` в исходнике B и C
одинаковы: 26 = 26, равенство True. Вместе с циклом hidden-state получается 28.

`evidence/contracts/993/validator-baseline-honest-remainder.json`: 9 из 9 `input_sha256` совпадают
с байтами C, failures 55.

## 3. Рв993-2 — getInsuredAsset

```
blocker-file 51 строк, отсортирован; live _source_consumers 51; множества равны: True
getInsuredAsset ∈ blocker: False; ∈ live failures: False
```

Источник реальный, своим обходом JSON: в `sources/frontend-ux1_17_5/BrokerOS_Mobile_Design_Data.json`
`designer_integration_matrix.screen_rows[3]` (route PROFILE) `.later_reads` = listMemory,
listInsuredAssets, getInsuredAsset. Это строки 28976–28990, getInsuredAsset на 28986–28988.

Изменения consumers в index между 19d4069 и C — ровно 5 операций, все добавлением screen-READ из
later_reads:
- getInsuredAsset, listInsuredAssets, listMemory — PROFILE;
- getProtectionProfile, getProtectionMap — PROTECTION.

Других изменений строк index нет.

getProtectionMap не подменяет getProtectionProfile: у Profile остаются action READ F19.A01/F19.A02.
У Map (deprecated) только screen-проекция реального источника (совет А-1).

Красное, мои мутанты (`mutant_screen.py`):

```
index-unknown-screen   rc 1  getInsuredAsset_source_consumers FAIL_STATIC  getInsuredAsset_consumer_resolution FAIL_STATIC
index-drop-screen      rc 1  getInsuredAsset_source_consumers FAIL_STATIC
source-drop-later-read rc 1  getInsuredAsset_source_consumers FAIL_STATIC
```

## 4. Рв993-3 — CAS-классификация

| operationId | precondition на C | `_cas` | Суд |
|---|---|---|---|
| revokeApproval | VERSIONED_TARGET_CAS | FAIL_STATIC | закрыто: versioned Approval честно красный |
| acknowledgeDisclosure | VERSIONED_TARGET_CAS | FAIL_STATIC | закрыто |
| postMessage | CREATE_OR_APPEND | PASS | основание append в thread — принято |
| registerDevice | CREATE_OR_APPEND | PASS | принято, уточнение А-4 |
| acceptPartnerInvitation | CREATE_OR_APPEND | PASS | 201 PartnerAttribution — принято, уточнение А-4 |
| proposePartnerProgramme | CREATE_OR_APPEND | PASS | новый агрегат — принято |
| ingestCommissionCash | CREATE_OR_APPEND | PASS | immutable event row — принято |
| provisionInsuranceMailbox | CREATE_OR_APPEND | PASS | новый агрегат, 202 — принято |
| **revokePermission** | CREATE_OR_APPEND | PASS | **FAIL**, см. ниже |

**Семантический FAIL, revokePermission.**
- Обязательство: §3 п.2 («precondition_basis — описание конкретного эффекта и проверяемое
  основание create/append»; «selective revocation сверяются отдельно»), п.5 приёмки.
- Фрагмент результата, OpenAPI `:6759–6760`: «the Permission resource exposes no version property and
  no ETag on the wire» и «termination of a non-versioned grant: the target entity carries no version
  or ETag».
- Источник: тот же ответ revokePermission:200 (`:6667–6670`) объявляет
  `ETag — Strong current changed/created resource ETag если resource существует`. listPermissions:200
  отдаёт `ETag — Strong scoped resource/version tag`.
- Противоречие: основание опирается на ложный факт об отсутствии ETag на wire. Эффект — termination
  существующего ресурса (`Permission.state`), а не create/append.

## 5. Рв993-4 и новый Рв993-6 — зона

```
git diff --stat 842f4e99d..b8456455 -- evidence/ux175   → пусто (команда брифа)
```

В узком смысле закрыто. Но правильная база PR — merge-base f7b9729, а не B. Своя мера, путь против
второй ЗОНА implementer:

```
f7b9729..C: changed 46, out_of_zone 21, statuses {D}
  D tools/run_backend_ci.py, tools/check_backend_provenance.py, tools/check_backend_standards.py,
    tools/check_backend_structure.py, tools/requirements-backend-checks.txt
  D evidence/ci/2026-10-17-local-and-negatives.md, evidence/ddl/…, evidence/ddl013/…, evidence/mock/… ×2,
    evidence/policy/…, evidence/runs/vs01-…/ ×7, evidence/runs/vs02-policy-…/ ×2,
    evidence/ux175/20261017T185158.302513Z/results.json
```

Все 21 файл существуют в f7b9729 (`git cat-file -e`) и отсутствуют в B. Их добавили коммиты main
dc35690, 5b14629, d0bb7d0 (Alex K, CMP-BCK-127/130). Удалил их 3d4651e: «remove out-of-zone
files…».

Последствие проверено живьём. `.github/workflows/ci.yml` (не изменён) вызывает
`tools/run_backend_ci.py` в 7 местах и `tools/requirements-backend-checks.txt`. CI PR#146 на C:

```
gh pr view 146: head b84564557d84…, base main, MERGEABLE, deleted-only files 21
gh pr checks 146: backend fail, checks fail, historical fail, image fail, package fail, postgres fail, required fail
job 117508104505: ERROR: Could not open requirements file: [Errno 2] No such file or directory: 'tools/requirements-backend-checks.txt'
job 117508104624: python3: can't open file '…/tools/run_backend_ci.py': [Errno 2] No such file or directory
job 117508104558: python3: can't open file '…/tools/run_backend_ci.py': [Errno 2] No such file or directory
```

Класс: превышение зоны (удаление чужих путей) и регрессия main. Нарушено условие владельца: «прежнее
evidence не переписывать». Merge в нынешнем виде удаляет CI-оркестратор main. Исправление —
вернуть 21 путь байтово из f7b9729 и пересобрать FILES.sha256.

## 6. Рв993-5 — диагноз

- README_RU.md:49: KeyError упомянут только в отрицании: «rc 1 — это не KeyError и не crash, а
  именованный честный остаток: 51 … revokePartnerGrant_cas + …_conditional_policy, revokeApproval_cas
  и acknowledgeDisclosure_cas».
- VALIDATION.json:118: «The historical KeyError 'requestBody' diagnosis is obsolete».
- «код tests не изменён» — фразы нет ни в README_RU.md, ни в VALIDATION.json.

Своя мера: обход всех строк VALIDATION.json на `KeyError|requestBody|unchanged`.

Закрыто. Остаток того же класса в соседних строках — Рв993-8.

## 7. Новый Рв993-7 — If-Match без required

- Код: `:246` `strong_target='If-Match' in headers or (dict existing_update If-Match)`. Здесь
  `headers=named_params(api,op)` (`:35–41`) — словарь по `name`, `in` и `required` не проверяются.
- Обязательство §3 п.3: «VERSIONED_TARGET_CAS требует required strong target If-Match + 412/428».

Живые мутанты на копии C (`mutant_optional.py`), сравнение с живым набором 55:

```
If-Match before: {'in': 'header', 'required': True} after: {'in': 'header', 'required': False}
mode optional rc 1 revokeAccountSession_cas PASS_STATIC failures beyond live C baseline (55): []
If-Match before: {'in': 'header', 'required': True} after: {'in': 'query', 'required': True}
mode query rc 1 revokeAccountSession_cas PASS_STATIC failures beyond live C baseline (55): []
```

В поставке своя мера по всем операциям с `x-command-policy.precondition`:

```
33 CREATE_OR_APPEND_NO_TARGET_CAS (без If-Match)
44 VERSIONED_TARGET_CAS  If-Match header required=True
 1 VERSIONED_TARGET_CAS  If-Match/If-None-Match header required=False + conditional dict  (updatePersonalProfile — законный профиль)
 1 VERSIONED_TARGET_CAS  If-Match header required=False, без conditional                   (requestAction — PASS_STATIC)
 3 VERSIONED_TARGET_CAS  без If-Match                                                       (честно FAIL)
```

requestAction (OpenAPI:2385) объявляет `x-if-match-required-except-action-kinds: [pause_work,
stop_work]` (`:2550`). Это kind-зависимое исключение, которого нет среди перечисленных в §Существующее
и §3. Валидатор его не читает: requestAction зелёный лишь потому, что параметр называется
`If-Match`.

Более простая форма проходит те же строки приёмки:
`p.get('in')=='header' and p.get('required') is True`. После этого requestAction становится
именованным отказом к владельцу, если владелец не признает kind-профиль контрактом с проверкой
закрытого списка kinds. В круге 1 эта находка пропущена.

## 8. Новый Рв993-8 — VALIDATION.json:128–129

```
"normative_openapi_and_bindings": "BYTE_IDENTICAL_TO_OWNER_BACKEND_3.14.2.2"   ← OpenAPI C be28c585… ≠ main f89b4a04…
"vs01_freeze": "UNCHANGED_AND_CHECKED_BY_GENERATOR"                         ← VERSION_MANIFEST.vs01_spec_freeze.sha256 7d5c893a…, re_freeze_provenance.old_sha256 39f34f29…
```

Блок `current_checkout_validation` implementer обновил в этом круге: status
`PASS_STATIC_WITH_NAMED_VALIDATOR_BLOCKERS`, новые reason и named_failure_ids. Две строки того же
блока по-прежнему описывают пакет до 993. Нарушены п.4 приёмки («в README_RU/VALIDATION сохранены
реальные результаты») и AGENTS.md, правило 7. Класс тот же, что у Рв993-5.

## 9. Поставка и handoff на C — живьём (подтверждено, не блокирует)

Скрипт `/tmp/dev-harness-verify/rv993r2/delivery.py`, копия C, каждый rc снят напрямую:

```
generate_derived#1: rc=0 'Handoff hashes rebuilt: 592 files'; git status clean (derived воспроизводятся)
alignment: rc=0 PASS_STATIC operations 163 deprecated 19
invitation: rc=0 BACKEND INVITATION TARGET 3.14.2.2 PASS
verify_handoff: rc=0 {"status":"PASS_STATIC","all_manifest_files_and_hashes":"PASS","runtime_acceptance":"NOT_ASSERTED"}
sha256sum -c FILES.sha256: rc=0; FILES 592, git 593, разница только FILES.sha256 сам
vs01 current api 5.8.3 sha256 7d5c893a…; re_freeze_provenance old_sha256 39f34f29… old_api 5.8.2 base_commit 842f4e99d authority owner 1810 §3а
NEG freeze-key-removed: rc=1 'VS01_SPEC_FREEZE_MISSING: … derived rebuild refused without an explicit --freeze-vs01 re-freeze'
NEG old-hash:           rc=1 'AssertionError: Frozen VS01 specification changed; do not silently update baseline'
final: git status clean
```

Батарея H, своя прогонка:
`PY H/fixtures/workshop_project/validator_993/handoff_probe.py --repo R --out /tmp/dev-harness-verify/rv993r2/out-handoff`
→ `993 handoff cases=46 mismatches=0 baseline_green=True`, rc=0.

`backend/`: `git diff --quiet f7b9729 C -- backend/ infra/ db/ .github/` rc=0. 993 backend не трогал.
Красные lanes CI вызваны Рв993-6, а не backend.

Основная батарея `probe.py` — круг адверсария, здесь не повторялась. При 55 честных отказах её
контроли не могут быть rc0 (п.3), пока не решён В-1.

## 10. Блокер владельца В-1

п.2 приёмки (rc0) недостижим без решений владельца:
- 51 `*_source_consumers` — контракт запрещает invented binding;
- compatibility по revokePartnerGrant, revokeApproval и acknowledgeDisclosure — missing target CAS,
  §3 п.2.

Это честный результат, не регрессия и не вина implementer. После Рв993-3 и Рв993-7 к нему,
вероятно, добавятся revokePermission и requestAction.

## Чек-лист роли

1. **Область правки.** 46 путей `f7b9729..C`, 25 в зоне, 21 удаление чужих путей main (Рв993-6).
2. **Сырой вывод.** Всё выше — живые прогоны ревьюера с rc. Evidence implementer привязано к C:
   honest-remainder 9/9. Старое evidence круга 1 не привязано (А-2).
3. **Проверка не подогнана.** Батарея H с freeze не тронута. 28 negative cases сохранены поимённо.
   Ослабление валидатора найдено отдельно: Рв993-7.
4. **Красное.** У каждого исправления круга 2 есть мой красный:
   - CAS-проза: prose FAIL;
   - later_reads: 3/3;
   - VS01 freeze absent: rc1 с именем;
   - old hash: rc1.

   Мутанты implementer (`fix2-mutant-controls.json`, 4 шт.) совпали по смыслу. Новый барьер
   «required If-Match» отсутствует: два моих мутанта ложно зелёные (Рв993-7).
5. **Атомарность.** 3 коммита, каждый с CMP-BCK-121. 8584f00 связывает 5 исправлений одной задачи
   (совет А-3).
6. **Норма.** Нормативных документов вне зоны ветка не трогает. §18 архитектуры (`:300`) разрешён
   владельцем.
7. **Счётные утверждения своей мерой:**
   - 55 = 51 + 3 + 1 — разбор JSON;
   - блокер 51 — множество против live;
   - 1491/28/250 — разбор JSON;
   - FILES 592 — `sha256sum -c` и `git ls-files`;
   - 46/0 handoff — свой прогон H;
   - зона 46/21 — свой классификатор по ЗОНА-строке;
   - 49 VERSIONED — свой обход OpenAPI.

   Заявление брифа «вне-зонных ux175-файлов нет» верно только против B. Против merge-base ux175
   теряет файл main (Рв993-6).

## ПРОВОДКА (контракт 038)

Guards ПРОВОДКА — четыре файла `fixtures/workshop_project/validator_993/`. Существуют, байты =
freeze. handoff_probe исполнен мной (rc0). Это барьеры именно этого предмета: они вызывают
внешние CLI поставки 993. Строка ПРОВОДКА-ЭНФОРСМЕНТ обоснована честно: норма механическая
(validator/handoff CLI), не поведенческая 029-класса. Дефектов проводки нет.

## Паразитная сложность (контракт 050) — пять вопросов по артефактам диффа круга 2

- **`tests/validate_contract_v3_9.py`, +later_reads, kind `screen`, ужесточение `_policy_consistency`
  и CAS.**
  1. Свойство: §2 (screen later-read), §3 п.3–4.
  2. Нового состояния нет.
  3. Свойство later_reads живёт в 2 файлах: валидатор и `generate_derived.py`. Так требует
     контракт («сравнить с derived graph»), число файлов не выросло.
  4. Интерфейс прежний: `--out`, rc 0/1.
  5. Потребитель — README, батарея H.

  ESSENTIAL. Неполнота `:246` — Рв993-7: это отсутствующее свойство, а не лишняя сложность.
- **`tools/generate_derived.py`, +later_reads и ветвь `VS01_SPEC_FREEZE_MISSING`.**
  1. Свойство: §2 и §4 («нельзя удалить запись freeze ради прохождения»).
  2. Состояние явное: stderr и rc1.
  3. Свойство в 1 файле.
  4. Интерфейс прежний: флаг `--freeze-vs01` уже был.
  5. Потребитель — генератор в п.4 приёмки.

  ESSENTIAL.
- **`evidence/contracts/993/validator-baseline-honest-remainder.json` и `.manifest.json`.**
  1. Свойство: условие владельца про evidence.
  2. Явные файлы.
  3. Меняются вместе с FILES.sha256.
  4. Интерфейса нет.
  5. Потребитель — VALIDATION.json (`baseline_evidence`) и суд.

  ESSENTIAL.
- **`evidence/contracts/993/fix2-mutant-controls.json`.**
  1. Свойство: красное круга (роль, п.4 чек-листа).
  2. Явный JSON.
  3. 1 файл.
  4. Интерфейса нет.
  5. Потребитель — суд.

  ESSENTIAL, но это сводка, а не сырой вывод. Мои мутанты её подтверждают.
- **`evidence/contracts/993/remaining-source-consumers-blocker.txt` (52→51).**
  1. Свойство: §2, «реальный остаток — блокер».
  2. Явный файл.
  3. 1 файл.
  4. Интерфейса нет.
  5. Потребитель — владелец.

  ESSENTIAL.
- **Удаление 21 пути main (3d4651e).** Свойства контракта, которое требует удаления, нет. Это не
  сложность, а регрессия зоны: Рв993-6.

## Что нужно для ACCEPT

1. Закрыть Рв993-3 (revokePermission), Рв993-6, Рв993-7 и Рв993-8 по `.review/2026-10-17-07.md`.
2. Перегенерировать FILES.sha256 и evidence на новом C. CI PR на новом C должен быть без
   lanes, упавших из-за отсутствующих файлов.
3. Адверсарию — батарея H на том же C.
4. Получить решение владельца по В-1: 51 consumers плюс compatibility по revokePartnerGrant,
   revokeApproval, acknowledgeDisclosure и, после Рв993-3/-7, по revokePermission и requestAction.

Новый C не наследует этот вердикт: нужен новый круг на новом OBJECT.
