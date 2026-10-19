FAIL
OBJECT=2d7bdf3b69ec99a600129be39ef6f79711c2c3ed

# Вердикт reviewer — контракт 106 (CMP-BCK-133, Complior-back 5.8.4), микро-круг после капа

Судья: Rev106r4 (reviewer). Предмет: R3-F1..R3-F3 + регресс механики; база круга 3 `55dac5a0`; коммиты `570a9ca` (контент) + `2d7bdf3` (evidence/FILES), оба identity `implementer`.
Контракт: `contracts/106-cmp-bck-133-spec-5-8-4.md` из `frozen/contracts/106/1`; `git diff --stat frozen/contracts/106/1 HEAD -- contracts/106-cmp-bck-133-spec-5-8-4.md` пуст, rc 0.
Батарея: j2 из `32997af93` (`git archive` → `Rev106r4/j2/`), probe.py sha256 `2b7eac14f82fc1557e6a011daf4f7b6b0d393df90e73a3047b2e4f6b052c9c42` = пин круга 3.
Все прогоны — на копиях `cp -a` клона в `/tmp/dev-harness-verify/Rev106r4/` (back, c-val, c-probe, c-gen, c-chk, mut-*), HEAD = OBJECT. PY = `/tmp/dev-harness-verify/Architect106r3/venv/bin/python`.
Находки в формате reslop: `review.md` (рядом).

## Итог

Содержательно R3-F1, R3-F2, R3-F3 закрыты, механика зелёная. **FAIL по одной блокирующей находке R4-F1**: при перезаморозке VS01 (часть исправления R3-F1) из `VERSION_MANIFEST.json` пропало звено истории 993. Это регресс этого круга.

## Блокирующая

**R4-F1 (класс: история переписана / регресс R3-F1).** В `VERSION_MANIFEST.json` `vs01_spec_freeze` под историю есть только один слот, `re_freeze_provenance_history`. Коммит 570a9ca сдвинул цепочку на одно звено и затёр звено `CMP-BCK-121-ERRATUM-5-8-3`: old_sha256 `39f34f29…` (5.8.2) → `7d5c893a…` (5.8.3), authority owner b469ca44f, контракт 993 п.4. Прецедент 5d6f952 сохранил цепочку целиком, а здесь из трёх звеньев осталось два.
- Нарушено обязательство frozen 106 ПЕРЕСЕЧЕНИЕ «VERSION_MANIFEST.json — 106 поднимает версию, не переписывает историю».
- Ссылка `contracts/backend-5_8_3-alignment.json` `vs01_refreeze` («See VERSION_MANIFEST.json vs01_spec_freeze.re_freeze_provenance for old/new hashes») больше не находит в манифесте нужных хешей.
- Новая строка `backend-5_8_4-alignment.json` `vs01_refreeze` выдаёт неполную цепочку за полную.

ОБХОД — потерю не видит ни один барьер: валидатор rc 0, verify_handoff rc 0, generate_derived rc 0 (no-op), `sha256sum -c` rc 0. Моя мера:
```
git grep -c 39f34f297257 55dac5a -- VERSION_MANIFEST.json   → 55dac5a:VERSION_MANIFEST.json:1  rc_base=0
git grep -c 39f34f297257 2d7bdf3 -- VERSION_MANIFEST.json   → (пусто)                          rc_head=1
git grep -c CMP-BCK-121-ERRATUM-5-8-3 2d7bdf3 -- VERSION_MANIFEST.json → (пусто)               rc_head_changeid=1
git grep -c 39f34f297257 5d6f952 -- VERSION_MANIFEST.json   → 5d6f952:VERSION_MANIFEST.json:1  rc_5d6f952=0
```
Отсутствует свойство: полная цепочка provenance VS01.

Более простая форма, которая проходит те же строки приёмки: вернуть звено 993, оформив историю списком звеньев или вложенным `previous`. Digest `23c85b3c…` при этом не изменится: VERSION_MANIFEST не входит в VS01-closure.

## R3-F1..R3-F3 — моя мера (`f1.py`, `f3.py` и сканы рядом)

**R3-F1: закрыт по существу.**
- `f1.py . 55dac5a`, rc 0:
  - `ReasonCode yaml/wire/mock 34 34 34`;
  - `x-reason-codes occurrences 938 distinct 24 ops 163`;
  - `UNREPRESENTABLE ['APPROVAL_ACTION_ALREADY_DISPATCHED']`.
- `f1.py . HEAD`, rc 0:
  - `35 35 35 equal True dups 0`;
  - `UNREPRESENTABLE none`;
  - негативный контроль `NOT_A_REAL_CODE_XYZ` отвергнут (accepted False);
  - `cas-semantics UPPER tokens not in ReasonCode []`.
- Представимость проверена по wire через Problem.code для всех 24 различных кодов, не для одного.
- Digest. Моя closure строится по 13 operation_ids манифеста, а не по маршрутам генератора:
  - на 55dac5a — `09e359d2…`, совпадает с манифестом;
  - на HEAD — `23c85b3c…`, совпадает с манифестом;
  - 55dac5a плюс только новый код в ReasonCode → `23c85b3c…`.
  
  Между 55dac5a и HEAD в OpenAPI изменились только `ReasonCode` и `recordManualLetterDelivery`, а последняя не входит в VS01. Digest честный, но история сломана → R4-F1.

**R3-F2: закрыт.** Исполнитель — customer/MOBILE_CLIENT:
- OpenAPI: x-role-policy `authenticated_customer` у обеих операций, описание record;
- bindings: workflow_consumers обеих операций;
- operation-index: consumers обеих операций;
- alignment: `callers.mobile` содержит обе, в `callers.workers` их нет, другие поля alignment manual-letter не упоминают.

Скан окна ±300 символов вокруг каждого упоминания manual-letter (13 файлов дерева без sources/ и evidence/993) нашёл «worker» только в описании схемы запроса: «Command invokes worker internal-record persistence…». Это канон владельца 057331c о механизме хранения, а не об исполнителе; та же фраза — в производных wire/mock. Реестр подтверждает: у BUI.LETTER.REPORT/READ_MANUAL_DELIVERY owner MOBILE_CLIENT и mobile_callable true, LETTER_ASSISTED_W1A — F40.A01–A03.

**R3-F3: закрыт.** `f3.py .`, rc 0:
- ops with workflows source_ref 21 (19 + 2);
- refs to Operation_Waves 0 (на 55dac5a — 19);
- `UNRESOLVED/MISMATCH none`: 8 якорей BUI (`operation_id` = операция потребителя) и 13 `operation_routes` той же операции;
- bindings и index согласны.

Круговости нет:
- реестр не упоминает таблицу волн;
- это не копия OpenAPI: 150 маршрутов против 163 операций, 19 маршрутов вне OpenAPI, 32 операции вне реестра;
- генератора `operation_routes` в tools/tests/docs нет;
- у файла один коммит — владельца, 057331c.

## Регресс механики (прогоны на копиях)

| команда | rc | вывод |
|---|---|---|
| `reslop t -- PY tests/validate_contract_v3_9.py --out Rev106r4/out-val` (cwd c-val) | 0 | `PASS_STATIC`, failure_ids `[]`, validated_examples 251 |
| `reslop t -- PY Rev106r4/j2/…/probe.py --repo Rev106r4/c-probe --out Rev106r4/out-probe` | 0 | `106 battery {"control_green": true, "control_reds": [], "cases": 27, "rejected": 27, "mismatches": []}`; мой подсчёт raw.json: `Counter({"result": "REJECTED_EXACT"}: 27)`, 27 каталогов case-*; c-probe после прогона чистая (0 строк status) |
| `PY Rev106r4/mut.py` (мутанты ревьюера из круга 3, источник переключён на OBJECT) | 0 | ctrl rc 0 PASS_STATIC n 0; m3 rc 1 FAIL_STATIC `revokePartnerGrant_conditional_policy`; m4 rc 1 то же; m5 rc 1 `revokePermission_conditional_policy` (дополнительно в каждом `index_source_sha256`) |
| `PY c-gen/tools/generate_derived.py` ×2 | 0, 0 | `Handoff hashes rebuilt: 618 files`; `git status --short` после каждого — 0 строк (no-op, идемпотентен) |
| `PY c-chk/tools/verify_handoff.py` | 0 | `PASS_STATIC`, schema_documents 13 |
| `PY c-chk/tools/validate_alignment_11782_31422.py` | 0 | `PASS_STATIC`, operations 163, deprecated 19 |
| `PY c-chk/tools/validate_invitation_target_31421.py` | 0 | PASS по всем строкам, включая «OpenAPI 5.8.4 source and derived operation index agree» |
| `sha256sum -c --quiet FILES.sha256` (cwd c-chk) | 0 | 618 строк |

Evidence: sha256 в `evidence/contracts/106/manifest.json` совпадают с фактическими: ed7aad81…, a92c9e7e…, 2fc07fd8…. `probe-summary.json` не менялся и совпадает с моим прогоном (27/27).

## Зона

`git diff --name-only 55dac5a..2d7bdf3` — 11 путей. Каждый сверен с frozen ЗОНА implementer: 10 из 11 входят в неё буквально. `contracts/wire-5_8.schema.json` в ЗОНА нет; это выход генератора (generate_derived.py:140), повторная генерация — no-op, поэтому принят как производный (совет R4-A1). Контракт 106 и батарея не тронуты.

## 050 — паразитная сложность

Новых скриптов, флагов, env, файлов и каталогов состояния в диффе нет. Раздут один артефакт — ключ `vs01_spec_freeze`:
1. Свойство — provenance VS01 (ПЕРЕСЕЧЕНИЕ VERSION_MANIFEST).
2. Состояние явно, ключи в JSON.
3. При следующей перезаморозке меняются те же 2 файла (manifest и alignment). Число не выросло, но форма с одним слотом заставляет терять звено.
4. Интерфейс не вырос.
5. Потребитель — ссылки alignment-файлов.

Класс ESSENTIAL. Дефект формы оформлен как R4-F1, а не как сложность.

## Советы (не блокируют)

- R4-A1: внести wire-5_8.schema.json в ЗОНА следующего контракта.
- R4-A2: правка канонной фразы «worker-owned» шире, чем требовала находка.
- R4-A3: вопрос консультанту/владельцу — `change_policy` требует решения владельца, а authority нового звена — ревьюер и форк.
- R4-A4: три находки сделаны одним коммитом 570a9ca.
- R3-A1..A6 переносятся без изменений.

Решение по 106 (FAIL → стоп) — за консультантом.
