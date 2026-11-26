accept
OBJECT=1ab6f19bda3ac01d15f0e9adce9f24e542400da2

СУД: repo=dev-harness; предмет=226; фаза=контракт; роль=critic; вызов=2/2 (исправительный; дельта Architect226b); модель-план=openai-codex/gpt-6.1-terra; сессия=Crit226b; модель-факт=openai-codex/gpt-6.1-terra; SHA=1ab6f19bda3ac01d15f0e9adce9f24e542400da2; автор Architect226b — openai-codex/gpt-6.1-sol, отдельная сессия; предыдущий=archive/226/critic-v1-fail-1747cff791; исключение=нет. `models_actual.sh --tsv --bind --session Crit226b` и для Architect226b rc 0. Основание повтора — исправление Б-1 и его семантические последствия, не новый полный поиск; санкция на OBJECT названа в задании.

## Карта классов

К-01: чисто — check_sdacha --run rc 0 двери=15 карта=17/17 дельта=3 и pre_critic rc 0
К-02: чисто — Б-1 закрыт contracts/226-arch-door-profile-key.md:37-45 и адресными мирами ниже
К-03: чисто — без изменений с вызова 1 кроме регресса --regression 203 и pin186 rc 0
К-04: чисто — зона implementer без изменений с вызова 1 и context.py MISSING 0
К-05: чисто — без изменений с вызова 1 кроме rc-команд дополненной батареи
К-06: чисто — без изменений с вызова 1 в предикате INVALID_MUTANT
К-07: чисто — --model rc 0 KLETKI 56 KRASNYH 0
К-08: чисто — --stabs rc 0 SVJAZI 25 ZHIVYH 0 и соседняя мутация поймана
К-09: чисто — missing-profile-door и layer-cannot-enable на модели rc 0 при rc субъекта 1
К-10: чисто — без изменений с вызова 1 в judge и проверках HEAD и TAG
К-11: чисто — без изменений с вызова 1 в независимом оракуле probe.py
К-12: чисто — без изменений с вызова 1 в использовании существующего resolver
К-13: н/п — без изменений с вызова 1 новых секретов нет
К-14: чисто — честные other-absent explicit-false и unknown-layer-sibling зелёны на --model
К-15: чисто — catalog 56 18 25 и --repo 56 45 и --model 56 0
К-16: чисто — Б-1 закрыт различением файла и листа и неверного слоя
К-17: н/п — без изменений с вызова 1 продуктовая архитектурная модель не меняется

## Решение по Б-1

`contracts/226-arch-door-profile-key.md:37-45` различает отсутствие файла при lock и без lock, подтверждённое отсутствие листа, повреждённый слой и лист в defaults. `probe.py:69,79-89,193-218` добавляет реальные входы; заменённое прежнее ожидание layer-cannot-enable усилено с успеха до отказа. `build.py:20-46,53-67,198-210` добавляет модель и адресные стабы. Старые клетки не удалены; diff probe.py содержит только это усиление и добавления. Б-1 закрыт: это проверено не одним текстом, а публичными вызовами ниже. Выключение при корректном профиле без листа или false соответствует названному Frontier; наличие lock само по себе не включает политику. Проверка scope использует прежний признак `-f architecture.lock.json`; содержимое пина проверяют прежние двери. Пустой/повреждённый профиль и ошибка слоя предписаны отказом; существующий resolver отвечает за канонизацию симлинков и чтение. Каталог на месте профиля без lock наблюдался как отсутствие регулярного файла и прежний skip; это не обход защиты при наличии lock и не доказательство нарушения заявленной границы.

## Доказательства

Чистый сетевой клон с единственным origin на OBJECT, свежие теги, TMPDIR внутри собственной копии. Обозначим W=`bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh`.

```
$ SDACHA_TIMEOUT_SEK=600 SDACHA_BUDZHET_SEK=2400 bash scripts/check_sdacha.sh "$PWD" contracts/226-arch-door-profile-key.md --run
СДАЧА: лист зелёный (двери=15 карта=17/17 дельта=3)
rc=0
$ bash scripts/pre_critic.sh contracts/226-arch-door-profile-key.md
КРИТИК: дверь зелёная
rc=0
$ bash scripts/check_precision_gate.sh "$PWD" contracts/226-arch-door-profile-key.md
OK
rc=0
$ python3 fixtures/workshop_project/arch_door_profile_key_226/context.py
FROZEN 199 BLOBS 199 OVERLAPS 123 MISSING 0
rc=0
$ W --repo .
KLETKI 56 KRASNYH 45 SVJAZI 0 ZHIVYH 0
rc=1
$ W --model
KLETKI 56 KRASNYH 0 SVJAZI 0 ZHIVYH 0
rc=0
$ W --stabs
KLETKI 56 KRASNYH 0 SVJAZI 25 ZHIVYH 0
rc=0
$ W --sintaksis
SINTAKSIS 25 SHELLCHECK_DIFFERENTIAL 6 BASELINE_DIAGNOSTICS 30
rc=0
$ W --catalog
KLETKI 56 STABY 18 SVJAZI 25
rc=0
$ W --regression
CELLS=21 STABS=0 FAILURES=0 ZHIVYH=0
186 pin pin_merged ok: rc=0
186 pin lock_missing ok: rc=1
186 pin pin_missing ok: rc=1
186 pin pin_wrong ok: rc=1
186 pin pin_arch_head ok: rc=1
REGRESSION 203 PIN186 rc=0
rc=0
```

Приведены итоговые строки прогонов; у пяти pin-проб выше опущен вывод после `rc`, а не подменены их результаты. Стабы содержат отдельные связи `CAUGHT st18-missing-profile-off missing-profile-door`, `CAUGHT st19-wrong-layer-off layer-cannot-enable`, `layer-conflict`, `layer-false` и три связи st20 на повреждение/недоступность. Результаты субъектов в скобках, rc самой адресной батареи указан отдельно:

```
$ W --model --cell missing-profile-door
GREEN missing-profile-door  (1, b'', b'ARCH_PROFILE_MISSING: harness.project.json\n')
KLETKI 1 KRASNYH 0 SVJAZI 0 ZHIVYH 0
rc=0
$ W --repo . --cell missing-profile-door
RED missing-profile-door RC,DIAGNOSIS,PARTIAL_OUTPUT (0, b'ARCH_187A_SKIP: ...', b'')
KLETKI 1 KRASNYH 1 SVJAZI 0 ZHIVYH 0
rc=1
$ W --repo . --cell layer-cannot-enable
RED layer-cannot-enable RC,DIAGNOSIS,PARTIAL_OUTPUT (0, b'=== make_task contract=777 role=architect kind=task ===\n=== TRACE ===\nTRACE: role=architect model=za', b'')
KLETKI 1 KRASNYH 1 SVJAZI 0 ZHIVYH 0
rc=1
```

В модели `layer-cannot-enable` и `layer-conflict` зелёные с rc субъекта 1, пустым stdout и `ARCH_PROFILE_LAYER`; `missing-profile-no-lock` зелёный с rc субъекта 0 и `ARCH_187A_SKIP`. Самостоятельная соседняя мутация в отдельной временной копии модели заменила уже существующий `has("archBrief")` на проверку значения, игнорирующую false. `W --repo <временная-копия> --cell layer-false`: rc 1, строки `RED layer-false RC,DIAGNOSIS,PARTIAL_OUTPUT` и `KLETKI 1 KRASNYH 1 SVJAZI 0 ZHIVYH 0`; честный `W --model --cell unknown-layer-sibling`: rc 0, `KLETKI 1 KRASNYH 0 SVJAZI 0 ZHIVYH 0`. Это проверка двусторонности изменённого предиката, не новый запрет значения.

## НЕ ЗАЩИЩАЕТ

Остатки contracts/226-arch-door-profile-key.md:79-82: санкционированное отсутствие листа/false, неизвестное имя, отсутствующий lock, TOCTOU и доверенная установка, содержание модели; ловцы названы там. Backend PR и живая проверка проекта до cutover остаются за orchestrator и reviewer, а не доказаны этой батареей.

## Советы

СОВЕТ contracts/226-arch-door-profile-key.md:70 — при передаче на done сохранить SHA backend-профиля и живую команду с rc; тест backend-equivalent не заменяет доставку отдельного PR.
