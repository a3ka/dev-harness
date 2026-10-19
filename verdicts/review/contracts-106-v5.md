accept
OBJECT=36d101af5475d4160042ed1d001752213f04f2cd

# Вердикт reviewer — контракт 106 (CMP-BCK-133, Complior-back 5.8.4), точечная проверка R4-F1

- Судья: Rev106r5 (reviewer).
- Предмет: только R4-F1 и регресс механики, по форку n106-krug4-fail (ОТВЕЧЕНО: да).
- База: `2d7bdf3b69ec99a600129be39ef6f79711c2c3ed`.
- Коммиты: `487a861` (VERSION_MANIFEST.json) и `36d101a` (evidence, FILES.sha256); оба identity `implementer`.
- R3-F1..F3 закрыты прогоном `verdicts/review/contracts-106-v4.md`; accept adversary круга 3 в силе.

Как проверял:
- Клон автора скопирован через `cp -a` в `/tmp/dev-harness-verify/Rev106r5/back`, HEAD = OBJECT.
- Прогоны шли на одноразовых копиях c-val, c-probe, c-gen, c-chk и mut-*; после прогона копии удалены.
- PY = `/tmp/dev-harness-verify/Architect106r3/venv/bin/python`.
- Батарея j2 взята из `32997af93` через `git archive` в `Rev106r5/j2/`. sha256 probe.py `2b7eac14f82fc1557e6a011daf4f7b6b0d393df90e73a3047b2e4f6b052c9c42` равен пину.
- Находки в формате reslop: `review.md` (рядом).

## Итог

**R4-F1 закрыт, регресса механики нет, новых блокеров нет.** Есть три совета (R5-A1..A3), слияние они не блокируют.

## R4-F1 — моя мера

`python3 r4f1.py back 36d101a`, rc 0:
```
head sha256 23c85b3cb4222aebd60b3a0fba5ce09f9e6942f156063163930646443a2600f0 api 5.8.4
history type list
0 CMP-BCK-121-ERRATUM-5-8-3 5.8.2 39f34f297257
1 CMP-BCK-133-5-8-4 5.8.3 7d5c893a9743
2 CMP-BCK-133-5-8-4-R3F1-REASONCODE 5.8.4 09e359d217dc
olds ['39f34f29', '7d5c893a', '09e359d2'] expected ['39f34f29', '7d5c893a', '09e359d2'] match True
top 23c85b3c 23c85b3c
precedent links ['CMP-BCK-121-ERRATUM-5-8-3', 'CMP-BCK-133-5-8-4']
erratum link == 5d6f952 (dict equality, key order too): True True
5-8-4 link == 2d7bdf3 history: True
R3F1 provenance == 2d7bdf3: True
other vs01 keys unchanged: True
rest of manifest unchanged: True
RESULT OK
```
Непрерывность цепи сверена другой мерой — по истории коммитов, а не по самому HEAD. Смотрел `vs01_spec_freeze.sha256` и `re_freeze_provenance` в каждой ревизии, rc 0:
```
821d364 7d5c893a CMP-BCK-121-ERRATUM-5-8-3 39f34f29      (git log -S 7d5c893a… — единственный коммит, ввёдший 5.8.3)
5d6f952 09e359d2 prov.old 7d5c893a prov.id CMP-BCK-133-5-8-4
55dac5a 09e359d2 prov.old 7d5c893a prov.id CMP-BCK-133-5-8-4
2d7bdf3 23c85b3c prov.old 09e359d2 prov.id CMP-BCK-133-5-8-4-R3F1-REASONCODE
36d101a 23c85b3c prov.old 09e359d2 prov.id CMP-BCK-133-5-8-4-R3F1-REASONCODE
```
Получилась цепь 39f34f29 → 7d5c893a → 09e359d2 → 23c85b3c без разрывов. Верхний digest не переписан.

«Байт-в-байт»: `python3 bytes.py .`, rc 0:
```
erratum == 821d364 origin (values+key order): True True
erratum == 5d6f952 history (values+key order): True True
5-8-4 link == 5d6f952 re_freeze_provenance: True True
stripped-line text equal (erratum, 5d6f952 vs HEAD): True 9 9
stripped-line text equal (5-8-4, 5d6f952 prov vs HEAD hist[1]): True
```
Текст звена после снятия отступа совпадает построчно. Отличие от 5d6f952 только в отступе: звено теперь вложено в список.

Потребители истории — `git grep` на 36d101a, rc 0:
- `re_freeze_provenance`, без sources/ и evidence/: только VERSION_MANIFEST.json:49,58 и prose-строки `vs01_refreeze` в двух alignment-файлах.
- `re_freeze|vs01_spec_freeze|provenance_history|vs01_refreeze` по `*.py *.sh *.yml *.yaml *.toml tools tests .github`: нашлись `tools/generate_derived.py:150,151,170,171,172` (наличие ключа и `sha256`) и `tools/validate_alignment_11782_31422.py:120` (`status`).

Историю не читает ни один инструмент. Значит, смена её формы с dict на list никакого потребителя не ломает. В dev-harness `provenance_history` встречается только в `.review/` и `verdicts/`.

## Регресс механики (прогоны на копиях)

| команда | rc | вывод |
|---|---|---|
| `reslop t -- PY tests/validate_contract_v3_9.py --out Rev106r5/out-val` (cwd c-val) | 0 | `exit: 0`; отчёт: `PASS_STATIC [] 251 1495` (status, failure_ids, examples, checks); `input_sha256` равен evidence 36d101a: True |
| `reslop t -- PY Rev106r5/j2/…/probe.py --repo Rev106r5/c-probe --out Rev106r5/out-probe` | 0 | `106 battery {"control_green": true, "control_reds": [], "cases": 27, "rejected": 27, "mismatches": []}` |
| `python3 count.py out-probe` (мой подсчёт) | 0 | `results {'REJECTED_EXACT': 27}`, `case dirs 27`; `cmp out-probe/summary.json back/evidence/contracts/106/probe-summary.json` rc 0; c-probe после прогона: 0 строк status |
| `PY mut.py` | 0 | `ctrl rc 0 PASS_STATIC n 0`; `m3 rc 1 FAIL_STATIC ['revokePartnerGrant_conditional_policy']`; `m4 rc 1 FAIL_STATIC ['revokePartnerGrant_conditional_policy']`; `m5 rc 1 FAIL_STATIC ['revokePermission_conditional_policy']` (у каждого дополнительно `index_source_sha256`) |
| `PY tools/generate_derived.py` ×2 (cwd c-gen) | 0, 0 | `Handoff hashes rebuilt: 618 files`; `git status --short` после каждого прогона — 0 строк (no-op) |
| `PY tools/verify_handoff.py` (cwd c-chk) | 0 | `PASS_STATIC`, schema_documents 13, all_manifest_files_and_hashes PASS |
| `PY tools/validate_alignment_11782_31422.py` | 0 | `PASS_STATIC`, operations 163, deprecated 19 |
| `PY tools/validate_invitation_target_31421.py` | 0 | `BACKEND INVITATION TARGET 3.14.2.2 PASS`, все строки PASS |
| `sha256sum -c --quiet FILES.sha256` | 0 | 618 строк |
| `python3 zone.py` | 0 | evidence manifest = фактические sha256 (85d17f02, 3ba3f645, 2fc07fd8): True ×3 |

## Зона и атомарность

- `git diff --name-only 2d7bdf3..36d101a` даёт 5 путей: FILES.sha256, VERSION_MANIFEST.json и `evidence/contracts/106/` {contract-validation, manifest, probe-raw}.
- ЗОНА implementer прочитана из frozen-блоба `frozen/contracts/106/1^{commit}:contracts/106-cmp-bck-133-spec-5-8-4.md` (путь найден через `ls-tree`). Все 5 путей в ней: IN ×5.
- Контракт в основном чекауте не тронут: `git diff --stat frozen/contracts/106/1 HEAD -- contracts/106-…md` пуст, rc 0; sha256 блоба и файла одинаковы — 36a0bf5c….
- 487a861 меняет только VERSION_MANIFEST.json, 36d101a — только evidence и FILES.sha256. Задача одна, разбита на контент и evidence, как в прошлых кругах.

## 050 — паразитная сложность

Новых скриптов, флагов, env, файлов и каталогов состояния нет. Раздут один артефакт — `re_freeze_provenance_history` (dict → list):
1. Свойство: ПЕРЕСЕЧЕНИЕ «VERSION_MANIFEST.json — 106 поднимает версию, не переписывает историю».
2. Состояние явное — ключи JSON.
3. При следующей перезаморозке меняются те же 2 файла (манифест и alignment), теперь добавлением без потерь. Число не выросло.
4. Интерфейс не вырос.
5. Потребитель — prose-ссылки alignment.

Класс ESSENTIAL: форма с одним слотом и стала причиной R4-F1. Предложенная в круге 4 более простая форма — ровно эта.

## Советы (не блокируют)

- R5-A1: `backend-5_8_3-alignment.json` `vs01_refreeze` отсылает к ключу `re_freeze_provenance`, а хеши 39f34f29 и 7d5c893a лежат теперь в `re_freeze_provenance_history[0]`. Так было уже в прецеденте 5d6f952; файл исторический и вне ЗОНА implementer. Хеши в манифесте есть, поэтому это не регресс правки.
- R5-A2: у звена хранится только `old_sha256`, «new» выводится из следующего звена или из верхнего `sha256`. Форма унаследована от 993; архитектору следующего контракта стоит хранить пару old/new.
- R5-A3: в докладе автора (п.3) сказано, что ссылка 5.8.3 alignment «находит old+new». Это так только при поиске по всему манифесту, а не по названному ключу.
- R4-A1..R4-A4 и R3-A1..R3-A6 вне предмета и переносятся без изменений. R4-A3 (authority перезаморозки R3F1 не от владельца) по-прежнему остаётся вопросом к консультанту и владельцу.

## Ограничение размещения

По заданию я пишу только в `/tmp/dev-harness-verify/Rev106r5/`, основной чекаут dev-harness не трогаю. Поэтому вердикт не закоммичен в `verdicts/review/` под именем reviewer. Перенос (`contracts-106-v5.md` и `.review/`) — за оркестратором. ОБХОД: файлы лежат здесь; rc записи — 0.
