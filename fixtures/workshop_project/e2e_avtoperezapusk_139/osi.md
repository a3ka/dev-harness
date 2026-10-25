# Оси батареи 139 (e2e-avtoperezapusk) — полная таблица, v3

Единый источник входов/ожиданий — `source.json` (правило 8: оракул в памяти
ДО вызова субъекта); эта таблица — карта осей для судьи, числа из прогонов.
Каждая красная клетка = обманный стаб (мутация КОДОМ в `probe.py` STAB_MUTACII,
привязка `stab_vhod`), каждый зелёный контроль = честная модель на том же входе.
Замеры v3: кейсы 42 (replay 30 / struktura 11 / derevo 1), стабов 41, связей 60.

## Ось A — событие workflow_run (replay, два окружения CHISTYJ+ACTIONS)

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
| чистый провал | chistyj-proval (E2E_NE_PROSHLA) | SKIP | s-bez-signaturnogo-filtra, s-molchashij-skip, s-skrytaja-vetv-github-actions, s-skrytaja-vetv-ci, s-api-f-post, s-workflow-run, s-api-jobs-f, s-setevoj-python |
| ниже порога | nizhe-poroga | SKIP | s-bez-signaturnogo-filtra |
| gradle-lock (Н-409) | gradle-lock | SKIP | s-bez-signaturnogo-filtra |
| fork-PR | fork-pr-bez-sekreta (PILOT_DEMO_CODE_ABSENT) | SKIP | — |
| сигнатуры только в эхе шага | skript-eho-signatury (живой носитель 40198243018) | SKIP | s-bez-eho-zaschity |
| эхо + длинный лог без сигнатуры | dlinnyj-eho-200001 | SKIP | — |

## Ось D — размер/форма лога × положение сигнатуры (replay)

Длинные логи генерируются ВО ВРЕМЯ прогона (в репо не хранятся). Ожидание
на валидной сигнатуре — всегда POVTOR (grep читает ФАЙЛ: ранний выход grep -q
не роняет пайплайн SIGPIPE под pipefail), на чистом логе — SKIP. Env иррелевантен
для содержания лога, но каждый вход оси D прогоняется и в @ACTIONS (модель
env-инвариантна; время ≤ 60 с держится: 42 входа ≈ 16 с).

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
| канон вызова (СТУПЕНЬ диагностики): литерал gh run rerun ровно 1 в теле И в файле, слово rerun 1 раз в файле, дословно --failed "$RUN_ID"; без while/until/for, оболочка -c/eval/xargs/$()/curl вне алфавита | struktura-rerun | s-dva-rerun, s-svertyvanie-dva-rerun (свёртка >- не укрывает: счёт по разобранному значению), s-env-podmena, s-skrytyj-bash-c, s-skrytyj-eval, s-skrytyj-xargs, s-skrytyj-podstanovka, s-setevoj-curl, s-cikl-for |
| **КАНОН СКРИПТА (v3, главная ось, блокер 2/2)**: нормализованное тело `run:` (strip, без пустых/#-строк) построчно равно нормализованному телу модели; первая разница — `SKRIPT_RASHOZHDENIE: строка N: <строка>`, разная длина — `+ (строк M, в каноне K)` | struktura-skript | 18 связей: s-skrytaja-vetv-github-actions, s-skrytaja-vetv-ci, s-api-f-post, s-pesochnica-scenarij, s-run-id-vne-batarei, s-pesochnica-gh-bin, s-workflow-run, s-api-jobs-f, s-setevoj-python + допсвязи s-skrytyj-bash-c, s-skrytyj-eval, s-skrytyj-xargs, s-skrytyj-podstanovka, s-setevoj-curl, s-env-podmena, s-svertyvanie-dva-rerun, s-dva-rerun, s-cikl-for |
| зелёный контроль канона: переформат модели КОДОМ (замена всех комментариев, вставка пустых строк, хвостовые пробелы) — ожидание пусто, ложный красный на честной реализации недопустим | struktura-skript-pereformat | — (зелёная клетка) |
| секреты/литеральные токены | struktura-sekrety | s-sekret-v-tekste |
| ${{ }}-выражения закрыты | struktura-vyrazhenija | s-vyrazhenie-vne-alfavita |
| канон сигнатур побайтово | struktura-signatury | s-signatury-suzheny |
| ЗАМКНУТОСТЬ (v2, блокер 1): ровно один job retry, ровно один шаг run; ключи верха {name,on,permissions,jobs}, job {if,runs-on,timeout-minutes,steps}, шаг {name,env,run}; триггеры только workflow_run; timeout-minutes ≤ 10; якоря/алиасы/merge-ключи/теги/defaults — отказ | struktura-zamknutost | s-dop-shag-run, s-dop-shag-uses, s-dop-job-ubuntu, s-dop-job-selfhosted, s-dopolnitelnyj-trigger, s-jakor-merge, s-defaults-run-shell |

Свёртка блок-скаляров |/>/>- не укрывает вызов: канон вызова и замкнутость
судятся по РАЗОБРАННОМУ значению (два вызова в свёртке → счёт 2), а сырой
текст несёт литералы для счётчиков файла. Любой доп. job/шаг/скриптовый путь,
способный повторить прогон, отвергается статикой до replay (свидетели критика
extra-step/extra-job: --repo rc 1, ZAMKNUTOST именована).

## Ось OKRUZHENIE — replay в двух окружениях (v3, арбитраж 139)

Каждый replay-вход судится ДВАЖДЫ против ОДНОГО оракула: `CHISTYJ` (как в v2)
и `ACTIONS` — поверх env replay живое окружение Actions (константа
`OKRUZHENIE_ACTIONS` в probe.py: GITHUB_ACTIONS/CI=true, GITHUB_RUN_ID события
кейса, GITHUB_RUN_ATTEMPT/RUN_NUMBER/WORKFLOW/JOB/EVENT_NAME/EVENT_PATH — файл
с JSON события кейса, GITHUB_SHA/REF/ACTOR/API_URL/SERVER_URL/WORKSPACE,
GITHUB_TOKEN=тест-токен, RUNNER_OS/ARCH/NAME/TEMP, ACTIONS_RUNTIME_TOKEN).
Отказ — `CASE <вход> KRASNO: @ACTIONS …` одной строкой на вход.

Назначение оси — честно названное: (i) доказывает env-ИНВАРИАНТНОСТЬ самой
модели (канон, который скопирует implementer, проверен в окружении, где будет
жить); (ii) даёт ПОВЕДЕНЧЕСКИЙ красный свидетель скрытых env-ветвей
(s-skrytaja-vetv-github-actions/-ci, s-api-f-post красны `@ACTIONS
RC_RASHOZHDENIE 127` + VNE_ALFAVITA в вызовах). Ось ЗАМЫКАНИЕМ класса «ветвь,
различающая песочницу» НЕ является (замер арбитража 139: 3 из 6 форм зелёные
в обоих окружениях — s-pesochnica-scenarij, s-run-id-vne-batarei,
s-pesochnica-gh-bin честны в replay ПО ПОСТРОЕНИЮ, их ловит только канон
скрипта; replay слеп к тэллам песочницы, которых у него бесконечно много).

## Ось VYZOVY — замкнутые argv подложного gh и PATH (v3)

Подложный `gh` принимает РОВНО три формы argv: `api <jobs-путь> --jq <фильтр
из алфавита>`, `api <logs-путь>`, `run rerun --failed <id>`; всё иное (-X/
--method/-f/-F/--field/--raw-field/--input/-H/--paginate, лишние позиционные,
rerun без --failed) — запись `VNE_ALFAVITA …` rc 127 (s-api-jobs-f красен в
ОБОИХ окружениях — argv замкнут даже на конформном GET-пути). PATH replay —
только bindir: gh-шим (shebang — абсолютный python3 батареи) + симлинки
{bash, sed, grep, tr, mktemp, rm}; python3/curl/wget/env/xargs/sh недоступны →
rc 127 (s-setevoj-python красен: `python3 - <<EOF … urllib POST` умирает
command not found). Утечка SCENARIJ_* в env скрипта не устраняется: после
канона скрипта тэллы песочницы бессмысленны (пример в §НЕ ЗАЩИЩАЕТ
контракта — почему ось окружения не замыкает класс).

## Ось F — дерево (пин байтов mobile.yml)

| значение | вход | стабы |
|---|---|---|
| mobile.yml изменён | pravka-mobile-yml | — (дерево мутирует сам движок) |

## Свидетели (v3): `--svideteli <dir>` строит деревья из STAB_MUTACII

kritik-hidden-api (свидетель критика 2/2 дословно), env-ci, env-f-post,
sandbox-tell-scenarij, run-id-vne-batarei, sandbox-tell-gh-bin (мутанты 1-6
арбитража 139): живой `--repo <dir>/<имя>` → rc 1,
`CASE struktura-skript KRASNO: SKRIPT_RASHOZHDENIE: строка 27: <первая чужая
строка>`.

## Остатки вне батареи (ловцы)

- реальный gh/GitHub API, наличие gh на раннере, политика прав, default-branch
  платформа — живой прогон после merge (первый флейк → ровно один rerun);
- сигнатура в УСПЕШНОМ предыдущем шаге при последующем падении только на
  E2E_NE_PROSHLA → повтор (нарезка В: сигнатура вне эха = свидетельство обрыва
  транспорта в прогоне) — ловец история прогонов (не более одного rerun на run);
- одновременные повторы двух разных упавших прогонов допустимы (attempt-гейт
  на прогон; два раннера станции).
