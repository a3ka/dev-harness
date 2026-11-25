accept
OBJECT=d9c266a1f7a0fed046b78f728bf57dd808cbe32c
СУД: repo=dev-harness; предмет=218; фаза=контракт; роль=critic; вызов=2 (исправительный по дельте; SANKCIJA); модель-план=openai-codex/gpt-6.1-terra; сессия=Crit218b; модель-факт=openai-codex/gpt-6.1-terra; SHA=d9c266a1f7a0fed046b78f728bf57dd808cbe32c; предыдущий=archive/218/critic-v1-fail-51c34b2ff3; исключение=нет.

Санкция на этот OBJECT указана в задании R-0085 п.2. Первый вердикт 51c34b2ff3e6cdcd73e8492197058fd2927d4085, кандидат d9c266a1f поверх dcc6f2a9c. `scripts/models_actual.sh --tsv --bind --session Crit218b` и аналогично Architect218b: rc 0, critic openai-codex/gpt-6.1-terra, architect openai-codex/gpt-6.1-sol; автор другой актор. Повтор ограничен закрытием Б-1/Б-2 и последствиями дельты; остальные поверхности заново полностью не судились. Для неизменённых классов приведены прямые статусы и входы вызова 1: его файл отсутствует в истории OBJECT и к тому же имеет имя v1, а механизм раскрывает ссылки только внутри фазы имени v2.

## Карта классов

К-01: чисто — check_sdacha --run rc 0 и pre_critic rc 0
К-02: чисто — без изменений с вызова 1, вход owner-затравка и инварианты 218
К-03: чисто — без изменений с вызова 1, вход зоны и non-PR обязательства 200 207 083 210 217 992 071
К-04: чисто — ЗОНА не изменены и precision-gate rc 0
К-05: чисто — без изменений с вызова 1, вход раздел Приёмочный критерий
К-06: чисто — дельта probe.py и --sintaksis rc 0
К-07: чисто — замена конечного блоба на историю и парные миры --model rc 0
К-08: чисто — --stabs rc 0 включая s13 s14 s15
К-09: чисто — criss-cross и revert для обоих guard --model rc 0
К-10: чисто — без изменений с вызова 1, вход observe проверяет rc диагноз stdout кеш HEAD status и Trace2
К-11: чисто — без изменений с вызова 1, вход World и oracle снимают состояние до subject
К-12: чисто — дельта catalog сравнивает производный TSV с JSON
К-13: н/п — без изменений с вызова 1, секретов и ПД нет
К-14: чисто — разрешённый v+1 новая заморозка code-revert и unique-base --model rc 0
К-15: чисто — --catalog 71 15 32 и --stabs 15 32 32 0
К-16: чисто — без изменений с вызова 1, вход рисковый страж устава и модель угроз
К-17: н/п — без изменений с вызова 1, станционный guard без продуктовой модели 188

## Закрытие блоков

Б-1 закрыт: `fixtures/workshop_project/okno_frozen_v_pr_218/probe.py:126` проверяет собственных носителей и при равных конечных frozen-блобах; миры :342 строят запрещённую правку и отдельный возврат. `--model` для обоих CLI даёт предметный отказ rc 1, разрешённые носители v+1, новая v2 и возврат только кода дают rc 0. s14 и s15 возвращают амнистию конечного состояния и пойманы также на носителе со вторым родителем. Отдельно построены несколько промежуточных коммитов, правка в боковой ветке с merge и возвратом, удаление/восстановление, переименование/возврат и изменение/возврат mode; на каждом оба reference CLI отказали rc 1 с предметной причиной.

Б-2 закрыт: `probe.py:243` проверяет Git-предпосылку двух merge-base, :358 строит criss-cross и потомка, парный unique-base имеет одно основание. `--model` даёт обоим CLI rc 1 `PR_WINDOW_BASE_AMBIGUOUS`; s13 удаляет существующий `--all` и краснеет для обоих CLI и потомка. Отдельно проверены три реальные merge-base и criss-cross во втором родителе merge-носителя: оба CLI отказали rc 1. В последнем мире та же мутация без `--all` даёт rc 0, но адресные клетки батареи её ловят.

Дельта dcc6f2a9c..OBJECT прочитана: существующие клетки и observe не удалены; добавлены 18 клеток, 3 стаба и проверка производного TSV, из признаков окружения закреплён TMPDIR. Baseline a32c577f и база дельты dcc6f2a9c проверены `git merge-base --is-ancestor` как предки OBJECT, rc 0. Зоны контракта не изменены. До реализации `--repo` ожидаемо красный: это не успешный production. После реализации обязательны non-PR регрессы контракта; здесь они не запускались.

## Исполненные проверки

Чистый одноразовый клон внутри копии с единственным remote origin. W — `bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh`. Ниже итоговые строки длинных прогонов и сырые строки соответствующих клеток.

```text
$ SDACHA_TIMEOUT_SEK=600 SDACHA_BUDZHET_SEK=2400 bash scripts/check_sdacha.sh "$PWD" contracts/218-okno-frozen-v-pr.md --run
СДАЧА: лист зелёный (двери=11 карта=17/17 дельта=3)
rc=0
$ bash scripts/pre_critic.sh contracts/218-okno-frozen-v-pr.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
  ok   гейт трека:
  ok   модель угроз красна
  ok   потолки красны
  ok   проводка красна
  ok   сдаточный лист красен
КРИТИК: дверь зелёная
rc=0
$ bash scripts/check_precision_gate.sh "$PWD/tmp/clone-crit218" contracts/218-okno-frozen-v-pr.md
OK
rc=0
$ W --repo .
KLETKI=71 ZELENYE=8 KRASNYE=63
rc=1
$ W --model
KLETKI=71 ZELENYE=71 KRASNYE=0
rc=0
$ W --stabs
STABY=15 SVJAZI=32 POIMANY=32 ZHIVYH=0
rc=0
$ W --sintaksis
SYNTAX rc=0
rc=0
$ W --catalog
CELLS=71 MUTATIONS=15 BINDINGS=32
rc=0
```

Из `W --model`:

```text
frozen-frozen-revert GREEN rc=1
charter-frozen-revert GREEN rc=1
frozen-ambiguous-base GREEN rc=1
charter-ambiguous-base GREEN rc=1
frozen-frozen-revert-allowed GREEN rc=0
charter-frozen-revert-allowed GREEN rc=0
frozen-frozen-revert-refrozen GREEN rc=0
charter-frozen-revert-refrozen GREEN rc=0
frozen-code-revert GREEN rc=0
charter-code-revert GREEN rc=0
frozen-unique-base GREEN rc=0
charter-unique-base GREEN rc=0
```

Из `W --stabs`:

```text
frozen-ambiguous-base GREEN rc=1
frozen-ambiguous-base RED rc=0 DIAGNOSIS,RC
s13-single-base -> frozen-ambiguous-base: POIMAN
charter-ambiguous-base GREEN rc=1
charter-ambiguous-base RED rc=0 DIAGNOSIS,RC
s13-single-base -> charter-ambiguous-base: POIMAN
s13-single-base -> frozen-ambiguous-base-descendant: POIMAN
s13-single-base -> charter-ambiguous-base-descendant: POIMAN
frozen-frozen-revert GREEN rc=1
frozen-frozen-revert RED rc=0 DIAGNOSIS,RC
s14-final-frozen -> frozen-frozen-revert: POIMAN
s14-final-frozen -> frozen-carrier-main-first-revert: POIMAN
charter-frozen-revert GREEN rc=1
charter-frozen-revert RED rc=0 DIAGNOSIS,RC
s15-final-charter -> charter-frozen-revert: POIMAN
s15-final-charter -> charter-carrier-main-first-revert: POIMAN
```

Соседние миры строились одноразовым драйвером `python3 "$PWD/tmp/neighbor218.py"` в клоне, rc 0: Git commit-tree с настоящими frozen-тегами, запрещённым промежуточным состоянием и восстановлением; для mode — update-index 100755 и следующий commit-tree с 100644; для трёх баз — два merge с тремя переставленными родителями. Для каждого из пяти revert-вариантов каждый CLI вывел `rc= 1 diagnosis= True`; для трёх оснований оба раза `BASES 3`, `rc= 1 diagnosis= True`, stderr `PR_WINDOW_BASE_AMBIGUOUS\n`. Это выдержка, не полный stderr запусков.

Независимая атака `python3 "$PWD/tmp/second218.py"`, rc 0: main=(A,B), собственный второй родитель=(B,A), merge-носитель первым родителем имеет собственную вершину. Исходная операция `g merge-base --all "$base" "$head"` заменена на `g merge-base "$base" "$head"`; честная модель и мутант запускались на одном настоящем DAG. Полный сырой вывод:

```text
BASES 2
frozen HONEST rc=1 stdout=b'' stderr=b'PR_WINDOW_BASE_AMBIGUOUS\n'
frozen MUTANT_NO_ALL rc=0 stdout=b'' stderr=b'pr: check_contract_frozen main=6d3769c000e7085d7aacd9b81e2e87d3591e91cf base=df2bbf4a9d8e1fc706355e8b06248cfc75125134 head=d42b7fe3339ce1d8d7b449c83c830501e38ec6e0\n\n\xd0\xbf\xd0\xbb\xd0\xb0\xd0\xbd\xd0\xbe\xd0\xb2 \xd0\xb8 \xd0\xba\xd0\xbe\xd0\xbd\xd1\x82\xd1\x80\xd0\xb0\xd0\xba\xd1\x82\xd0\xbe\xd0\xb2 \xd0\xbd\xd0\xb0 HEAD: 0 \xc2\xb7 \xd1\x87\xd0\xb5\xd1\x80\xd0\xbd\xd0\xbe\xd0\xb2\xd0\xb8\xd0\xba\xd0\xbe\xd0\xb2: 0 \xc2\xb7 \xd0\xb7\xd0\xb0\xd0\xbc\xd0\xbe\xd1\x80\xd0\xbe\xd0\xb6\xd0\xb5\xd0\xbd\xd0\xbe: 0 \xc2\xb7 \xd1\x80\xd0\xb5\xd0\xb5\xd1\x81\xd1\x82\xd1\x80: full\n'
BASES 2
charter HONEST rc=1 stdout=b'' stderr=b'PR_WINDOW_BASE_AMBIGUOUS\n'
charter MUTANT_NO_ALL rc=0 stdout=b'' stderr=b'pr: check_charter main=6d3769c000e7085d7aacd9b81e2e87d3591e91cf base=df2bbf4a9d8e1fc706355e8b06248cfc75125134 head=d42b7fe3339ce1d8d7b449c83c830501e38ec6e0\n'
```

## НЕ ЗАЩИЩАЕТ

Остатки `contracts/218-okno-frozen-v-pr.md:78`: подмена доверенного origin/CI и универсальная асимптотика не доказываются батареей; ловцы — изоляция и reviewer/adversary реализации. Локальный pre-push и Д4 не входят в предмет.

## Советы

Нет блокирующих находок и дополнительных советов по дельте.
