FAIL

# Ревью 993, круг 3: CMP-BCK-121, валидатор и erratum 5.8.3 — a3ka/Complior-back PR#146

- OBJECT: `31d4b98f159d60ab3e9052135b66241c3f8e410e`. Ветка `cmp-bck-121/validator-5-8-3`; голова origin
  и headRefOid PR#146 совпадают с OBJECT.
- B: `842f4e99d6024ab62336a6a0be787ae667fb555b`. Merge-base с origin/main: `f7b972913ec2af0df83ce58ea34dd688870fb0e9`.
- Коммиты круга 3: 44f061f (исправления) и 8 коммитов c26631f…31d4b98 (backend regen, revert, reapply,
  revert; итог нулевой). Автор всех — `implementer`.
- H: `frozen/contracts/993/1`. `git diff --stat frozen/contracts/993/1 HEAD -- fixtures/workshop_project/validator_993/
  contracts/993-cmp-bck-121-validator-5-8-3.md` пуст: батарея и контракт не тронуты.
- Роль: reviewer (Reviewer993Round3), 2026-10-17. Свежий клон `/tmp/dev-harness-verify/rv993r3/cback`, venv
  `/tmp/dev-harness-verify/rv993/venv` (jsonschema 4.26.0).
- Находки (reslop): `.review/2026-10-17-08.md`. Прошлые круги: `verdicts/review/contracts-993-v{1,2}.md`.

Вердикт привязан к этому OBJECT. Новый C его не наследует.

## Итог

| # | Находка | Класс | Статус | Блокирует |
|---|---|---|---|---|
| Рв993-6 | удаление 21 файла main | превышение зоны | ЗАКРЫТО | нет |
| Рв993-8 | VALIDATION.json:128–129 | ложный диагноз | ЗАКРЫТО в VALIDATION.json | нет |
| Рв993-7 | If-Match не header или отсутствует при VERSIONED_TARGET_CAS | дефект барьера (§3 п.3) | ЧАСТИЧНО: простой If-Match закрыт, обход через conditional-dict жив | **да** |
| Рв993-3 | revokePermission | семантический FAIL §3 п.2 | ЧАСТИЧНО: failure ID честный, ложный факт в OpenAPI:6759 не изменён | **да** |
| **Рв993-9** | ETag-сверка смотрит только 200; комментарий говорит 200/204; helper мёртв | дефект барьера, заявленное ≠ сделанному | новое | **да** |
| **Рв993-10** | README_RU:49 и архитектура `:300` — остаток круга 2 (нет requestAction/revokePermission) | ложный диагноз, п.4 приёмки | новое | **да** |
| **Рв993-11** | блокер-список 51 operationId заменён токеном `51` | регрессия evidence | новое | **да** |
| В-1 | 57 именованных отказов | блокер владельца | честный остаток | держит слияние, не вина implementer |
| В-2 | backend/required: backend/app/contracts ≠ корневой OpenAPI 5.8.3 | чужая зона (консультант) | вне 993 | не блокирует 993 |
| А-2, А-5…А-7 | см. reslop | советы; А-6 — условие слияния (squash) | — | нет |

Четыре находки брифа: Рв993-6 и Рв993-8 закрыты. Рв993-7 и Рв993-3 закрыты частично. Ещё три новых
блокера. Пять пунктов брифа по порядку — ниже.

## 1. Рв993-6 — зона и CI, живьём

```
git diff --name-status f7b9729..31d4b98f            → 25 путей; --diff-filter=D → 0
                                                      все 25 ∈ второй ЗОНА implementer (сверка по списку контракта)
git diff --stat f7b9729..31d4b98f -- tools/ evidence/ → 11 files: evidence/contracts/993/ ×7,
                                                      tools/{generate_derived,validate_alignment_11782_31422,
                                                      validate_invitation_target_31421,verify_handoff}.py
git diff --stat f7b9729 HEAD -- backend/ infra/ db/ .github/ → пусто
git diff --stat 44f061f HEAD                         → пусто (8 churn-коммитов дают нулевой итог)
FILES.sha256: 613 строк; git ls-tree HEAD: 614 (разница — сам FILES.sha256); sha256sum -c --quiet → rc 0
```

21 путь круга 2 (`tools/run_backend_ci.py` и другие) в диффе отсутствует, значит он байтово равен f7b9729.

```
gh pr view 146: headRefOid 31d4b98f…, base main, MERGEABLE, OPEN
gh pr checks 146 (rc 1):
  backend   fail   job 117516931572
  required  fail   job 117517126367
  checks    pass   historical pass   image pass   package pass   postgres pass
```

Причина красного backend взята из лога job 117516931572 через `gh api …/jobs/…/logs`:

```
[backend] FAIL rc=1 производный контракт = корневой OpenAPI
  gen-contracts --check: openapi.json не совпадает с пересборкой из корневого YAML
  gen-contracts --check: source.json не совпадает (хэш или версия источника)
[backend] FAIL rc=1 npm test … backend/tests/contract/http.test.js:54:3
```

Это `backend/`, зона консультанта; §Зоны 993 её исключает. За это не блокирую. Порядок слияния — В-2.

## 2. Рв993-3 — revokePermission

Своя мера, обход OpenAPI на C:

```
revokePermission post /v1/permissions/{permission_id}/revocations
  If-Match: нет;  precondition CREATE_OR_APPEND_NO_TARGET_CAS
  precondition_target: "…the Permission resource exposes no version property and no ETag on the wire"   (:6759)
  precondition_basis:  "termination of a non-versioned grant: the target entity carries no version or ETag…"
  resp 200 headers: Cache-Control, X-Command-Id, Idempotency-Replayed, ETag, X-BrokerOS-Contract
live failure_ids ∋ revokePermission_cas
```

Сторона валидатора исправлена: результат честно красный. Но **фрагмент семантического FAIL круга 2
не изменён ни на байт**, а 44f061f сам пишет «classified as CREATE_OR_APPEND_NO_TARGET_CAS with the false claim
'no ETag on the wire'». Канонический контракт поставки содержит фразу, которую автор признаёт ложной.

Красная проверка указывает на правильную операцию, но основание остаётся ложным. Это правило 7 AGENTS.md.

- Обязательство: §3 п.2.
- Фрагмент: OpenAPI `:6759` (обе строки).
- Источник: собственный ответ 200 (`:6667–6670`, ETag).
- Противоречие: на wire есть ETag; эффект — termination существующего ресурса, а не create/append.

Выход назван ещё в круге 2: `VERSIONED_TARGET_CAS`, как у revokeApproval, либо основание без ложного факта.
Мой мутант `m_revperm_versioned` (тег VERSIONED_TARGET_CAS, If-Match нет) даёт `revokePermission_cas` FAIL_STATIC.
Значит, честная переклассификация сохраняет тот же failure ID и тот же счёт 57.

## 3. Рв993-7 — живые мутанты

Скрипт `/tmp/dev-harness-verify/rv993r3/mutants.py`. Каждый мутант — отдельная копия C, одна точечная правка
OpenAPI, затем настоящий CLI. `m_noop` — контроль пересериализации YAML: он добавляет только
`index_source_sha256`, потому что меняются байты OpenAPI. Этот ID общий для всех строк.

```
control rc 1 FAIL_STATIC failures 57
m_noop                     revokeAccountSession_cas  PASS_STATIC                          beyond-live ['index_source_sha256']
m_optional   (required:false)  revokeAccountSession_cas FAIL_STATIC                       beyond-live [+revokeAccountSession_cas]
m_query      (in:query)        revokeAccountSession_cas FAIL_STATIC                       beyond-live [+revokeAccountSession_cas]
m_cond_query (updatePersonalProfile If-Match in:query)   _cas PASS_STATIC  _conditional_policy PASS_STATIC  beyond-live []
m_cond_drop  (updatePersonalProfile If-Match удалён)     _cas PASS_STATIC  _conditional_policy PASS_STATIC  beyond-live []
m_add_cond_drop (revokeAccountSession If-Match удалён + корректный x-conditional-policy dict)
                                                         _cas PASS_STATIC  _conditional_policy PASS_STATIC  beyond-live []
m_downgrade_revoke_session (→CREATE_OR_APPEND x/y, If-Match удалён)  _cas PASS_STATIC  beyond-live []
m_downgrade_ack            (acknowledgeDisclosure → CREATE_OR_APPEND x/y)  _cas FAIL_STATIC (сохранён)
m_revperm_204              (revokePermission 200→204, ETag сохранён)  _cas PASS_STATIC  gone ['revokePermission_cas']
m_revperm_versioned        (revokePermission → VERSIONED_TARGET_CAS)  _cas FAIL_STATIC
```

Пункт брифа выполнен для простого If-Match: required:false и in:query теперь FAIL.
`requestAction_cas` есть в живых failure_ids: requestAction имеет If-Match `in:header, required:false`, conditional нет.

**Обход не закрыт.** Ветвь `conditional_carries` (`tests/validate_contract_v3_9.py:267–270`) — альтернатива
`in=header ∧ required=true`, и она истинна от одного metadata-dict `existing_update.header=='If-Match'`. Три
мутанта выше ложно зелёные. `m_add_cond_drop` — класс Рв993-1: проза metadata подменяет wire, только теперь
в форме dict. Адверсарий нашёл то же независимо (`verdicts/adversary/contracts-993-v3.md`, A993-3-1).

Простая форма описана в reslop: потребовать ещё `in=='header'` у обоих conditional-параметров. Она проходит
те же строки приёмки: updatePersonalProfile на C объявляет If-Match и If-None-Match как header.

Своя мера по всем 82 операциям с `x-command-policy.precondition`:

```
32 CREATE_OR_APPEND  без If-Match, без 200-ETag на {id}
 1 CREATE_OR_APPEND  без If-Match, 200-ETag на {id}            (revokePermission — FAIL)
32 VERSIONED  If-Match header required=True, без 200-ETag на {id}
12 VERSIONED  If-Match header required=True, 200-ETag на {id}
 1 VERSIONED  If-Match header required=False + conditional dict (updatePersonalProfile)
 1 VERSIONED  If-Match header required=False                    (requestAction — FAIL)
 3 VERSIONED  без If-Match                                       (revokeApproval, acknowledgeDisclosure, revokePartnerGrant — FAIL)
operations 163, deprecated 19, info.version 5.8.3
```

## 4. Рв993-8 — VALIDATION.json

```
:128 "normative_openapi_and_bindings": "OPENAPI_ERRATUM_5.8.3_APPLIED_VS_OWNER_BACKEND_3.14.2.2_BASELINE_SHA_BE28C585_BEATS_F89B4A04"
:129 "vs01_freeze": "RE_FROZEN_FOR_ERRATUM_5_8_3_OLD_39F34F29_TO_NEW_7D5C893A_RE_FREEZE_PROVENANCE_RECORDED"
sha256 OpenAPI: C be28c585…; f7b9729 f89b4a04…; B f89b4a04…
VERSION_MANIFEST.vs01_spec_freeze.sha256 = 7d5c893a… (api 5.8.3)
```

BYTE_IDENTICAL и UNCHANGED из текущего блока ушли, ложного утверждения там нет. Оставшиеся вхождения `BYTE_IDENTICAL` относятся к UX-источникам и миграциям. `"openapi": "5.8.2_UNCHANGED"` на `:89` стоит в историческом блоке `invitation_first_open_3142`. Ни то ни другое не утверждение о текущем пакете.

Закрыто. Совет по формулировке — А-5: в ней be28c585 назван «BASELINE», это неверно.

**Однако соседние документы того же п.4 не обновлены (Рв993-10).**

- README_RU.md:49 перечисляет «именованный честный остаток» круга 2: 51 + revokePartnerGrant_cas/_conditional_policy + revokeApproval_cas + acknowledgeDisclosure_cas. Своя мера по строке: `requestAction` — 0 вхождений, `revokePermission` — 0.
- Архитектура `:300`, «Честные именованные пробелы поставки», тоже называет только revokePartnerGrant, revokeApproval и acknowledgeDisclosure.

Живой результат — 57.

## 5. Живой валидатор — 57, своей мерой

```
PY tests/validate_contract_v3_9.py --out /tmp/dev-harness-verify/rv993r3/out-validator   → rc 1
```

Разбор `contract-validation.json` моим скриптом, без stdout раннера:

```
status FAIL_STATIC  runtime NOT_RUN_BY_THIS_VALIDATOR
checks 1491 unique 1491; negative_cases 28 (все PASS_STATIC); examples 250
failures 57 unique 57 → {_source_consumers: 51, _cas: 5, _conditional_policy: 1}
non-consumer: acknowledgeDisclosure_cas, requestAction_cas, revokeApproval_cas, revokePartnerGrant_cas,
              revokePartnerGrant_conditional_policy, revokePermission_cas
```

Заявление «57 = 51 + 5 + 1» совпало, и состав 5 + 1 совпал поимённо.

`evidence/contracts/993/validator-baseline-honest-remainder.json`: 9 из 9 `input_sha256` совпадают с байтами C. Его failure_ids равны живому множеству.

**Рв993-11.** `remaining-source-consumers-blocker.txt` на C содержит один токен `51`: имён в нём 0 при 51 живом.

- В b845645 там было 51 строка, и множество было равно живому.
- 44f061f затёр файл: `git diff --stat b845645 HEAD` даёт −52/+1.
- FILES.sha256:380 хэширует уже испорченный файл.

## Поставка и handoff на C — живьём (подтверждено)

Копия `/tmp/dev-harness-verify/rv993r3/d`; каждый rc снят через `${PIPESTATUS[0]}`:

```
generate_derived: rc 0 "Handoff hashes rebuilt: 613 files"; git status после — 0 строк (производные воспроизводятся)
verify_handoff:   rc 0 {"status":"PASS_STATIC","schema_documents":13,"all_manifest_files_and_hashes":"PASS","runtime_acceptance":"NOT_ASSERTED"}
alignment:        rc 0 PASS_STATIC operations 163 deprecated 19
invitation:       rc 0 BACKEND INVITATION TARGET 3.14.2.2 PASS
verify_ux175:     rc 0 PASS_STATIC checks 934
```

Батарея H:

```
PY H/fixtures/workshop_project/validator_993/handoff_probe.py --repo R --out /tmp/dev-harness-verify/rv993r3/out-handoff
→ 993 handoff cases=46 mismatches=0 baseline_green=True, rc 0
```

Основную батарею `probe.py` гоняет адверсарий; здесь я её не повторял. Пока не решён В-1, её контроли не могут дать rc0 (п.3).

## Арбитр и предел кругов

Это третий круг ревьюера по предмету 993. Рв993-3 и Рв993-7 отказаны второй раз по той же причине. Автор с причиной согласен: в 44f061f он сам называет основание ложным. Но правило «три круга по одному предмету» из AGENTS.md §«Арбитр — когда и зачем» срабатывает механически. По правилу 15 **называю арбитра**: он созывается без согласия автора. Предмет арбитра:

- нарезка, при которой каждый круг закрывает обход одной формы и открывает соседнюю — проза → dict, required → conditional, 200 → 204/201;
- нужен ли закрытый перечень проверяемых wire-признаков CAS-профиля вместо metadata.

Регламент даёт ревьюеру один круг. Следующий круг — только решением владельца (правило 12).

## Чек-лист роли

1. **Область правки.** Дифф PR: 25 путей, все в зоне, удалений 0. В истории 4 коммита правят `backend/app` и сами себя откатывают, итог нулевой. Это А-6: условие слияния squash.
2. **Сырой вывод.** Все цифры выше — мои прогоны с rc. Evidence implementer привязано к C: honest-remainder 9/9. Исключение — испорченный блокер-файл (Рв993-11).
3. **Проверка не подогнана.** Батарея H и контракт равны freeze. 28 negative cases все PASS_STATIC. Ослабление валидатора найдено отдельно: Рв993-7 и Рв993-9.
4. **Красное.** Новые барьеры круга имеют красное на прямой форме: required:false, in:query, downgrade acknowledgeDisclosure, revokePermission 200-ETag. На соседней форме они ложно зелёные: conditional-dict ×3, 204.
5. **Атомарность.** 44f061f связывает 5 исправлений одной задачи CMP-BCK-121. По норме это не отказ, но откатить по частям нельзя. Восемь churn-коммитов без ссылки на находку — шум истории (А-6).
6. **Норма.** Нормативные документы dev-harness не тронуты. Правка §18 архитектуры Complior-back в зоне владельца.
7. **Счётные утверждения своей мерой:**
   - 57 = 51 + 5 + 1 — разбор JSON;
   - 1491 / 28 / 250 — разбор JSON;
   - 613 файлов — `sha256sum -c` и `git ls-tree`;
   - 46/0 — свой прогон H;
   - 25 путей, 0 D — `--diff-filter=D`;
   - 82 precondition — свой обход OpenAPI;
   - «21 restored byte-identical» — их отсутствие в диффе против f7b9729.

   Заявление 44f061f «all delivery checks pass» верно для пяти delivery-команд, проверено. Заявления «Рв993-3/7 closed» шире сделанного (см. выше).

## ПРОВОДКА (контракт 038)

Guards ПРОВОДКА — четыре файла `fixtures/workshop_project/validator_993/`:

- они существуют, байты равны freeze (frozen diff пуст);
- `handoff_probe.py` исполнен мной, rc 0;
- это барьеры именно этого предмета: вызывают внешние CLI поставки 993.

ПРОВОДКА-ЭНФОРСМЕНТ обоснована честно: норма механическая, не поведенческая 029-класса. Дефектов проводки нет.

## Паразитная сложность (контракт 050) — пять вопросов по артефактам диффа круга 3

- **`tests/validate_contract_v3_9.py`: ветвь VERSIONED (`in/required` + `conditional_carries`).**
  1. Свойство: §3 п.3.
  2. Нового состояния нет.
  3. Затрагивает 1 файл, рост 0.
  4. Интерфейс прежний (`--out`, rc 0/1).
  5. Потребители — README и батарея H.

  ESSENTIAL. Неполнота `conditional_carries` — отсутствующее свойство (Рв993-7), а не лишняя сложность.
- **Ветвь CREATE_OR_APPEND: ETag-сверка и `has_path_id`.**
  1. Свойство: §3 п.2 «проверяемое основание».
  2. Нового состояния нет.
  3. Затрагивает 1 файл.
  4. Интерфейс прежний.
  5. Потребитель — суд и failure ID.

  ESSENTIAL по свойству, неполнота — Рв993-9.
- **`has_response_etag` (`:42–50`).**
  1. Свойство: никакое, функция не вызывается.
  2. Состояния нет.
  3. Создаёт вторую грамматику «2xx-ETag» рядом с inline-циклом `:288–295`, теперь их 2 места.
  4. Интерфейс без работы.
  5. Потребителя нет.

  **ACCIDENTAL.** Фрагмент `:42–50`; отсутствующее свойство — любое; простая форма, проходящая те же строки приёмки: удалить функцию либо вызывать её вместо inline-цикла. Блокирует в составе Рв993-9.
- **Восстановленные 21 путь.** Это не новый артефакт: возврат байтов main, потребитель — `.github/workflows/ci.yml`. ESSENTIAL.
- **VALIDATION.json `named_failure_ids`.**
  1. Свойство: п.4 приёмки.
  2. Состояние явное, в JSON.
  3. Должен меняться вместе с README_RU:49 и §18 `:300`. Их не обновили — Рв993-10.
  4. Интерфейса нет.
  5. Потребитель — владелец.

  ESSENTIAL.
- **`remaining-source-consumers-blocker.txt` (51 строка → `51`).** Свойство §2 «реальный остаток — блокер» после правки не выполняется. Это регрессия (Рв993-11), не сложность.

## Что нужно для ACCEPT

1. Рв993-7: `conditional_carries` обязан сверять wire-параметры. Красное — три моих conditional-мутанта.
2. Рв993-3: переклассифицировать revokePermission либо убрать ложный факт из OpenAPI `:6759`.
3. Рв993-9: ETag-сверка не должна зависеть от одного кода статуса либо должна совпадать со своим комментарием; мёртвый helper убрать. Красное — `m_revperm_204`.
4. Рв993-10: README_RU:49 и §18 `:300` привести к 57.
5. Рв993-11: восстановить список из 51 operationId, пересобрать FILES.sha256.
6. Арбитр (третий круг) и решение владельца по В-1 и порядку В-2.

Новый C не наследует этот вердикт.
