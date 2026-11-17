accept
OBJECT=350afbb76ae8d88228f072167eff029ee4931127

СУД: repo=dev-harness; предмет=201; фаза=контракт, узкий четвёртый вызов по слову владельца №46; роль=critic; вызов=4 сверх базового бюджета; модель-план=apex-sol → @gpt-terra; сессия=Crit201V4; модель-факт=openai-codex/gpt-6.1-terra; SHA=350afbb76ae8d88228f072167eff029ee4931127; предыдущие=Crit201V1 FAIL, Crit201V2 FAIL, Arb201V1 resolved 74fcd2c784, Crit201V3 FAIL d41c6f6a42; исключение=адресная санкция владельца №46. `bash scripts/models_actual.sh --tsv --bind --session Crit201V4` rc 0: `critic openai-codex/gpt-6.1-terra allowed Crit201V4 350afbb76ae8d88228f072167eff029ee4931127`. HANDOFF на момент чтения содержит предвызовную запись с `сессия=ожидается`; фактическая модель и SHA подтверждены трассой. Автор Arch201Fix3 — zai/glm-5.3 по заданию.

## Решение

Блок К-10 Crit201V3 закрыт: contracts/201-done-dver-soderzhatelnaja-sverka.md:55,61 и fixtures/workshop_project/done_dver_soderzhatelnaja_201/dver_probe.py:491-505,609-624. Источник места и риска — HEAD; незакоммиченные изменения не стали свидетельством, положительные закоммиченные контроли проходят. Повтор ограничен блоком и последствиями дельты согласно №46, это не новый полный поиск. Решение 1 арбитра по тождеству деревьев сохранено; все 13 тегов и blob миграции совпали с актуальными тегами (классификация источников ранее проверена Crit201V3). Блокирующих находок в области вызова нет.

СОВЕТ contracts/201-done-dver-soderzhatelnaja-sverka.md:109 — `scripts/check_sdacha.sh` недоступен в заявленном окне до 193; автоматический повтор сдаточного листа не выполнен, отдельные заявленные команды запущены ниже.

## Адресные атаки

Все прогоны без ambient GIT_AUTHOR_NAME/EMAIL/DATE и GIT_COMMITTER_NAME/EMAIL/DATE (`env -u` каждого); скрипты только в одноразовом каталоге Crit201V4. `PYTHONDONTWRITEBYTECODE=1 python3 /tmp/dev-harness-verify/Crit201V4/attack.py` rc 0, сырой результат (SHA одноразовых миров опущены только в двух строках tree):

```text
mesto initial (1, 'done: место реализации предмета 777 не установлено — нет объявления ПРОДУКТ: и нет применимой записи registry/mesto-legacy.tsv')
b-legacy-chuzhoj-blob worktree (1, 'done: место реализации предмета 777 не установлено — нет объявления ПРОДУКТ: и нет применимой записи registry/mesto-legacy.tsv')
b-legacy-chuzhoj-blob staged (1, 'done: место реализации предмета 777 не установлено — нет объявления ПРОДУКТ: и нет применимой записи registry/mesto-legacy.tsv')
b-legacy-chuzhoj-blob committed (0, '')
v-legacy-rabochaja-zapis worktree (1, 'done: предмет рисковый, accept адверсария не найден: verdicts/review/contracts-777-*.md')
v-legacy-rabochaja-zapis staged (1, 'done: предмет рисковый, accept адверсария не найден: verdicts/review/contracts-777-*.md')
v-legacy-rabochaja-zapis committed (0, '')
a-ravenstvo-frozen-verdikt (0, '')
a-drevo-object-do-realizacii (1, 'done: OBJECT 61b47518c988c60a059e07545940574288d57570 не связан с последней заморозкой frozen/contracts/777/1 — вердикт судит объект старой версии')
a-drevo-realizacija-v-f (1, 'done: OBJECT 4fea8d4a957c6e2659ac971c91ffb50cd92ea0bc не связан с последней заморозкой frozen/contracts/777/1 — вердикт судит объект старой версии')
b-legacy-rabochaja-zapis honest (1, 'done: место реализации предмета 777 не установлено — нет объявления ПРОДУКТ: и нет применимой записи registry/mesto-legacy.tsv') mutant (0, '')
b-legacy-staged-zapis honest (1, 'done: место реализации предмета 777 не установлено — нет объявления ПРОДУКТ: и нет применимой записи registry/mesto-legacy.tsv') mutant (0, '')
v-legacy-rabochaja-zapis honest (1, 'done: предмет рисковый, accept адверсария не найден: verdicts/review/contracts-777-*.md') mutant (0, '')
```

Первый запуск attack.py rc 1 после успешных первых контролей: повторно создано имя временного мира; исправлено уникальным именем и повторено выше.

`PYTHONDONTWRITEBYTECODE=1 python3 /tmp/dev-harness-verify/Crit201V4/missing.py` rc 0, сырой вывод:
```text
b-legacy-rabochaja-zapis no HEAD file, worktree exists (1, 'done: место реализации предмета 777 не установлено — нет объявления ПРОДУКТ: и нет применимой записи registry/mesto-legacy.tsv')
b-legacy-rabochaja-zapis no HEAD file, staged exists (1, 'done: место реализации предмета 777 не установлено — нет объявления ПРОДУКТ: и нет применимой записи registry/mesto-legacy.tsv')
b-legacy-rabochaja-zapis committed (0, '')
v-legacy-rabochaja-zapis no HEAD file, worktree exists (1, 'done: предмет рисковый, accept адверсария не найден: verdicts/review/contracts-777-*.md')
v-legacy-rabochaja-zapis no HEAD file, staged exists (1, 'done: предмет рисковый, accept адверсария не найден: verdicts/review/contracts-777-*.md')
v-legacy-rabochaja-zapis committed (0, '')
```

`PYTHONDONTWRITEBYTECODE=1 python3 /tmp/dev-harness-verify/Crit201V4/source_mutation.py` rc 0: изменение обоих исходниковых условий выбора на `if True` возвращает старое чтение рабочего файла. Сырой вывод:
```text
b-legacy-rabochaja-zapis source mutation (0, '') expected rc 1, caught True
b-legacy-staged-zapis source mutation (0, '') expected rc 1, caught True
v-legacy-rabochaja-zapis source mutation (0, '') expected rc 1, caught True
```
Первый запуск rc 1: путь временного модуля имел недостаточную глубину для `__file__`; после исправления — результат выше. `--stabs` отдельно подтвердил привязки кодом: `STAB s-b-mesto-iz-rabochego-fajla caught @ b-legacy-rabochaja-zapis` и `STAB s-v-risk-iz-rabochego-fajla caught @ v-legacy-rabochaja-zapis`. Аудит `read_text|open\(|git show|HEAD:|risk.legacy|mesto_lookup` в dver_probe.py: чтения рабочего файла относятся к построению миров либо явно включённым мутантам, нормальный lookup использует `git show HEAD:`.

## Проверки

- `bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh --model`: rc 0, CELLS=45 STABS=0 FAILURES=0; `--stabs`: rc 0, 45/15/0; голый и `--repo .`: rc 1, каждый 45/0/30 — ожидаемая краснота до реализации двери.
- `bash scripts/pre_critic.sh --repo . contracts/201-done-dver-soderzhatelnaja-sverka.md` rc 0; `check_spec_ready.sh`, `check_precision_gate.sh`, `check_threat_model.sh`, `check_ceilings.sh` с аргументами `. contracts/201-done-dver-soderzhatelnaja-sverka.md` rc 0; угрозы 9/9. `bash scripts/check_charter.sh` rc 0: 177 документов, 511 изменений, 511 с разрешения.
- `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .`, `--model`, `--stabs`: rc 0, соответственно 54/0/0, 54/0/0, 54/56/0.
- `PYTHONDONTWRITEBYTECODE=1 python3 fixtures/workshop_project/rezhim_996/probe.py --matrix` rc 1, examined=111 mutants=76 mismatches=1 — прежний базлайн Crit201V3, не регресс данной дельты.
- `PYTHONDONTWRITEBYTECODE=1 python3 /tmp/dev-harness-verify/Crit201V4/migration.py` rc 0: все 13 записей, последний тег и blob совпадают. Независимая повторная семантическая классификация всех 13 вне узкой дельты не проводилась.

## Карта классов

К-01: чисто — гейты выше; check_sdacha отсутствует, совет выше.
К-02: чисто — решения арбитра и 13 тегов/blob, адресные проверки выше.
К-03: без изменений с вызова 3.
К-04: без изменений с вызова 3.
К-05: без изменений с вызова 3.
К-06: без изменений с вызова 3.
К-07: чисто — модель, стабы, голый и --repo, результаты выше.
К-08: чисто — две исходниковые мутации и --stabs выше.
К-09: чисто — worktree, staged, отсутствие HEAD-файла и коммит обоих реестров выше.
К-10: чисто — прежний рабочий вход, staged, HEAD и два мутанта выше.
К-11: без изменений с вызова 3.
К-12: без изменений с вызова 3.
К-13: без изменений с вызова 3.
К-14: чисто — оба честных закоммиченных контроля и F==CID выше.
К-15: чисто — 45/15/30, 54/56 и 111/76/1 по фактическим прогонам.
К-16: чисто — граница HEAD и отказ при отсутствии файла, входы выше.
К-17: без изменений с вызова 3.
