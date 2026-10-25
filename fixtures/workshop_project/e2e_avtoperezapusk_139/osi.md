# Оси батареи 139 (e2e-avtoperezapusk) — полная таблица, v2

Единый источник входов/ожиданий — `source.json` (правило 8: оракул в памяти
ДО вызова субъекта); эта таблица — карта осей для судьи, числа из прогонов.
Каждая красная клетка = обманный стаб (мутация КОДОМ в `probe.py` STAB_MUTACII,
привязка `stab_vhod`), каждый зелёный контроль = честная модель на том же входе.
Замеры v2: кейсы 40 (replay 30 / struktura 9 / derevo 1), стабов 32, связей 36.

## Ось A — событие workflow_run (replay)

| значение | вход | исход | стабы |
|---|---|---|---|
| conclusion≠failure | conclusion-success/-cancelled | SKIP | s-bez-conclusion-guard |
| run_attempt=2 | attempt-2-ofline | SKIP | s-bez-attempt-guard |
| conclusion=failure, attempt=1 | все остальные replay | далее по оси B/C | — |

## Ось B — состав упавших jobs (replay, jq-фильтр канона)

| значение | вход | исход | стабы |
|---|---|---|---|
| упал только quality | upal-quality-tolko | SKIP (нет android-e2e) | s-bez-jobs-filtra |
| упали оба | upali-oba | POVTOR | — |
| много failed android-e2e (20000, генерация при прогоне) | mnogo-jobov-20000 | POVTOR | s-rannij-head (head -n 1 → SIGPIPE 141) |

## Ось C — сигнатура в логе вне эха (replay)

| значение | вход | исход | стабы |
|---|---|---|---|
| 7 сигнатур канона | infra-* (7 входов) | POVTOR | s-signatury-suzheny, s-polnyj-rerun, s-dva-rerun |
| чистый провал | chistyj-proval (E2E_NE_PROSHLA) | SKIP | s-bez-signaturnogo-filtra, s-molchashij-skip |
| ниже порога | nizhe-poroga | SKIP | s-bez-signaturnogo-filtra |
| gradle-lock (Н-409) | gradle-lock | SKIP | s-bez-signaturnogo-filtra |
| fork-PR | fork-pr-bez-sekreta (PILOT_DEMO_CODE_ABSENT) | SKIP | — |
| сигнатуры только в эхе шага | skript-eho-signatury (живой носитель 40198243018) | SKIP | s-bez-eho-zaschity |
| эхо + длинный лог без сигнатуры | dlinnyj-eho-200001 | SKIP | — |

## Ось D — размер/форма лога × положение сигнатуры (replay, v2: блокер 2)

Длинные логи генерируются ВО ВРЕМЯ прогона (в репо не хранятся). Ожидание
на валидной сигнатуре — всегда POVTOR (grep читает ФАЙЛ: ранний выход grep -q
не роняет пайплайн SIGPIPE под pipefail), на чистом логе — SKIP.

| значение | вход | исход | стабы |
|---|---|---|---|
| 101 строка, сигнатура в начале | dlinnyj-log-nachalo-101 | POVTOR | — |
| 20001, в начале | dlinnyj-log-nachalo-20001 | POVTOR | — |
| 200001, в начале | dlinnyj-log-nachalo-200001 | POVTOR | s-rannij-grep-q |
| 200001, в середине | dlinnyj-log-seredina-200001 | POVTOR | — |
| 200001, в конце | dlinnyj-log-konec-200001 | POVTOR | — |
| 2000000, в начале | dlinnyj-log-nachalo-2000000 | POVTOR | s-rannij-grep-q |
| одна строка 10 МБ без переводов | ogromnaja-stroka-10mb | POVTOR | — |
| CRLF-концы строк | crlf-log | POVTOR | — |
| без финального \n | log-bez-konechnogo-perevoda | POVTOR | — |
| NUL + не-UTF-8 байты (байтовая запись) | log-nul-neutf8 | POVTOR | — |
| пустой лог | pustoj-log | SKIP | — |

Н-39: s-rannij-grep-q (возврат к `printf | … | grep -qE` под pipefail)
привязан ТОЛЬКО к длинным входам с ранней сигнатурой (200001/2000000), где
SIGPIPE наблюдаем; на коротких входах (< буфера пайпа) стаб честен — краснота
там требовала бы лжи. s-rannij-head — к mnogo-jobov-20000 (20000 id ≈ 280 КБ
> 64 КБ буфера: head выходит рано, printf получает SIGPIPE, rc 141).

## Ось E — структура workflow (статика YAML)

| значение | вход (os) | стабы |
|---|---|---|
| триггер workflow_run [mobile]/completed | struktura-trigger | s-chuzhoj-trigger, s-dopolnitelnyj-trigger (workflow_dispatch) |
| права ровно {actions: write, contents: read} | struktura-prava | s-shirokie-prava |
| runs-on [self-hosted, linux, x64, complior] | struktura-runner | s-runner-ubuntu |
| if несёт три условия | struktura-if | s-if-bez-uslovij |
| канон вызова: литерал gh run rerun ровно 1 в теле И в файле, слово rerun 1 раз в файле, дословно --failed "$RUN_ID"; без while/until/for, оболочка -c/eval/xargs/$()/curl вне алфавита | struktura-rerun | s-dva-rerun, s-svertyvanie-dva-rerun (свёртка >- не укрывает: счёт по разобранному значению), s-env-podmena, s-skrytyj-bash-c, s-skrytyj-eval, s-skrytyj-xargs, s-skrytyj-podstanovka, s-setevoj-curl, s-cikl-for |
| секреты/литеральные токены | struktura-sekrety | s-sekret-v-tekste |
| ${{ }}-выражения закрыты | struktura-vyrazhenija | s-vyrazhenie-vne-alfavita |
| канон сигнатур побайтово | struktura-signatury | s-signatury-suzheny |
| ЗАМКНУТОСТЬ (v2, блокер 1): ровно один job retry, ровно один шаг run; ключи верха {name,on,permissions,jobs}, job {if,runs-on,timeout-minutes,steps}, шаг {name,env,run}; триггеры только workflow_run; timeout-minutes ≤ 10; якоря/алиасы/merge-ключи/теги/defaults — отказ | struktura-zamknutost | s-dop-shag-run, s-dop-shag-uses, s-dop-job-ubuntu, s-dop-job-selfhosted, s-dopolnitelnyj-trigger, s-jakor-merge, s-defaults-run-shell |

Свёртка блок-скаляров |/>/>- не укрывает вызов: канон вызова и замкнутость
судятся по РАЗОБРАННОМУ значению (два вызова в свёртке → счёт 2), а сырой
текст несёт литералы для счётчиков файла. Любой доп. job/шаг/скриптовый путь,
способный повторить прогон, отвергается статикой до replay (свидетели критика
extra-step/extra-job: --repo rc 1, ZAMKNUTOST именована).

## Ось F — дерево (пин байтов mobile.yml)

| значение | вход | стабы |
|---|---|---|
| mobile.yml изменён | pravka-mobile-yml | — (дерево мутирует сам движок) |

## Остатки вне батареи (ловцы)

- реальный gh/GitHub API, наличие gh на раннере, политика прав, default-branch
  платформа — живой прогон после merge (первый флейк → ровно один rerun);
- сигнатура в УСПЕШНОМ предыдущем шаге при последующем падении только на
  E2E_NE_PROSHLA → повтор (нарезка В: сигнатура вне эха = свидетельство обрыва
  транспорта в прогоне) — ловец история прогонов (не более одного rerun на run);
- одновременные повторы двух разных упавших прогонов допустимы (attempt-гейт
  на прогон; два раннера станции).
