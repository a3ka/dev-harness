# Контракт 205 — `check_provodka.sh` признаёт четвёртую локацию guard: гейт профиля проекта

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: обычный — инфраструктура двери проводки контрактов; права/роли БД, авторизация, деньги, ПД/health-данные и юридически значимые действия не затронуты.
КОНТЕКСТ: номер выдан механизмом `next_id` (тег `id/CONTRACT/205`, строка `registry/contracts.tsv` на origin/main `613b60cf9`); owner-затравка влита PR #1230 `8f53bab1bc` с `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` (стартовые затравки 205/206) и заменена этим контрактом целиком. Слово консультанта 22.11 02:34 и 10:55: старт разрешён, номер — по носителю зоны скрипта. Путь А: один PR, architect → implementer → reviewer.
СДАЧА: fixtures/workshop_project/provodka_gate_205/SDACHA.md

## Боль и обещание

`scripts/check_provodka.sh` (`:428-487`, функция `guard_is_wired`) признаёт подключение guard только в `.githooks/*`, `.github/workflows/*.yml|*.yaml` и `registry/ci-steps.tsv`. В проектах guard подключается gate'ом профиля: `harness.project.json` → `sourceCanon.gate` → `scripts/check_project_sources.sh` со stage=pre_critic|done (нога (д) `scripts/pre_critic.sh`, `scripts/done_contract.sh`, контракт 996 «режим проекта»). Дверь эту локацию не видит: полный `check_provodka` на проектном контракте краснеет «проводка: guard не подключён» при честно подключённом gate — измерено у моба 207 (`mobile/scripts/check-context-sources.py`, держит done 207 и 164) и то же у 198–204; на самой станции так же красен полный `check_provodka` на контракте 204 до CI-строки (заявленное состояние).

Один результат: полный `bash scripts/check_provodka.sh <корень проекта> <контракт>` перестаёт краснеть на guard, подключённом gate'ем профиля (клетки a1–a5), при неизменных прежних вердиктах, фразах и порядке диагностики (клетки b1–b3, c1–c3, d1, f1–f4 и зелёная семья 038/994). Тип доказательства — поведение: реальные rc и полные строки CLI на чистых входах батареи; происхождение (что gate профиля реально проверяет источники) — предмет 996, не этой двери. Затронутые frozen-обязательства — 038/2 (грамматика поля, фразы, порядок каналов: не меняются, добавляется локация и одна новая фраза отказа), 191 (режим `--grammar`: не меняется), 994 (оговорка внешнего CI и фраза «guard не подключён»: сохраняются дословно).

## Существующее

- Дверь `scripts/check_provodka.sh` уже судит подключение guard тремя локациями в `guard_is_wired` (`:428-487`); носитель зоны и грамматики поля — контракт 038 (frozen 2, ЗОНА implementer: `scripts/check_provodka.sh`). Прецедент расширения уже есть: 083 добавил третью локацию (`registry/ci-steps.tsv`) без смены сообщения и фраз — 205 повторяет приём для четвёртой.
- Единый источник грамматики профиля и слияния слоёв уже существует: `scripts/profile_resolver.sh` (054/184/996) — закрытый алфавит `sourceCanon={sources,gate}`, обязательные поля слоёв, канонизация profilePath, P1..P7 с именованными местами. Исполнитель gate — `scripts/check_project_sources.sh` (996), вызываемый с stage=pre_critic|done из `scripts/pre_critic.sh` (нога (д)) и `scripts/done_contract.sh`; оба вооружаются только при наличии `harness.project.json` в корне. Второго парсера профиля дверь не заводит: вызывает резолвер и читает эффективный профиль.
- Живой профиль станции (`harness.project.json` + `registry/harness-project.json`, без `sourceCanon`) резолвером разбирается rc 0 — после реализации полный `check_provodka` на контрактах станции ведёт себя как прежде (замер пачки, живой вызов).
- Фикстуры-потребители фразы: `fixtures/check_provodka/red_R4_guard_osirotel.sh:23` и `case_27_guard_ere_metachars.sh:68` сверяют «проводка: guard не подключён: … не вызывается в .githooks/ или .github/workflows/» grep -F; `fixtures/check_provodka/external_ci_994/` (baseline_038.sh с pinned digest, probe.py `refusal()`) — замороженный снимок двери и регрессия семьи; всё это не правится и остаётся зелёным (приёмка п.4).
- Форма батареи — прецеденты `fixtures/workshop_project/sdacha_193/` и `fixtures/workshop_project/karta_vyzova_204/` (раннер + probe.py + model/ + stabs.tsv + SDACHA.md, режимы `--repo`/`--model`/`--stabs`); здесь воспроизведена для монолитной двери: модель — полная копия двери с единственным вставленным блоком четвёртой локации (diff — ровно этот блок, замер пачки).

## Frontier

1. Строчный скан `harness.project.json` по образцу прежних локаций (имя как слово в строке). Отвергнут: профиль — структурированный JSON двух слоёв; скан не видит gate в defaults-слоя, принимает битый JSON молча и падает на двойниках имени — различается клетками c1/c2 (двойники) и e1–e3 (битый профиль); мутации PODSTROKA-BAZY и SLOVO-ERE — те самые обманки в коде модели.
2. Прямой jq-разбор `.sourceCanon.gate` внутри двери, без резолвера. Отвергнут: второй источник грамматики (алфавит канона, слияние слоёв, P-фразы) рядом с замороженным резолвером; мутация SYROJ-JSON показывает наблюдаемое расхождение на a2 (defaults-слой) и e3 (алфавит).
3. Выбран резолвер как единый источник: дверь вызывает `scripts/profile_resolver.sh` с `HARNESS_PROJECT_LAYER_ROOT=<корень>`, читает эффективный `sourceCanon.gate`, отказ резолвера проксирует именованным отказом (правило 7 AGENS «неразобранное — отказ»).

## Решение и инварианты

- И1 — четвёртая локация: guard считается подключённым, если в эффективном профиле судимого корня объявлен `sourceCanon.gate` и хотя бы один токен его argv равен `<guard>` либо оканчивается на `/<guard>` — литеральное сравнение путей, без regex/glob (норма 041); форма «абсолютный токен, оканчивающийся на `/<guard>`», легитимна тем же правилом. Профиль — эффективный: слияние репо-слоя (`$ROOT/harness.project.json`) и слоя проекта (`projectLayer.profilePath`, умолчание `registry/harness-project.json`) делает ТОЛЬКО `scripts/profile_resolver.sh`; дверь не парсит слои сама. Путь guard — тот же токен, что в строке `- guard=` поля ПРОВОДКА (ROOT-относительный).
- И2 — порядок локаций: прежние три локации признаются как прежде — дословно (дисциплина слова, ERE-экранирование bname, исключение `#`-комментариев, третья локация реестра); четвёртая опрашивается последней и только если прежние не нашли подключение. Вход без `harness.project.json` ведёт себя байт-в-байт как до предмета.
- И3 — нераспознанный профиль: при существующем `$ROOT/harness.project.json` отказ резолвера даёт rc 1 `проводка: профиль проекта не распознан: <первая строка отказа резолвера без префикса «profile ОТКАЗ: »>` — место называет сама фраза резолвера («файл не JSON: <путь>», «нет файла слоя проекта: <путь>», «SOURCE_CANON_INVALID: …»). Молчаливый пропуск нераспознанного профиля запрещён. Канон не объявлен ни в одном слое (К6 996) — локация ничего не подключает и не отказывает; отсутствие `harness.project.json` — локация молчит, как отсутствие `.githooks`. Новых причин rc 2 не вводится.
- И4 — двойники не считаются: подстрока имени (`xred_…`), суффикс-двойник (`…-old`), имя в прочих полях профиля (`sourceCanon.sources[].path`, `contextPack`, комментарии) подключением не считаются; сравнение — только с токенами gate по И1. Комментарий-класс прежних локаций (`#`-строки) в JSON неприменим: битый JSON закрыт И3.
- И5 — существование прежде подключения: прежний порядок диагностик сохраняется — «проводка: guard-файл не существует: <guard>» судится ДО подключения (инвариант 4 контракта 038); имя в gate при отсутствующем файле даёт «guard-файл не существует», не «не подключён».
- И6 — замороженные фразы и режимы: сообщение `проводка: guard не подключён: <guard> не вызывается в .githooks/ или .github/workflows/` сохраняется байт-в-байт; rc 0/1/2 и порядок г0 → г0-доп → г1..г6 — прежние; режим `--grammar` не судит подключение; фраза И3 — единственная новая. Семья 038 (red_R4, case_27, green_G*) и батарея 994 (baseline с digest) не правятся и остаются зелёными до и после реализации.
- И7 — оговорка внешнего CI (994): закрытое per-guard исключение (первый последующий абзац `ПРОВОДКА-ЭНФОРСМЕНТ:` с одной из двух закрытых фраз) снимает требование подключения в целом — проверка подключения не вызывается, значит не вызывается и опрос четвёртой локации; семантика 994 не меняется.

## Модель угроз

ЗАЩИЩАЕТ:
- от ложного «guard не подключён» на честно подключённом gate профиля — клетки a1–a5 (репо-слой, defaults-слой, абсолютный токен, голый argv0, python-расширение) дают rc 0 на модели и rc 1 на текущей двери;
- от ложного зелёного на двойниках имени и имени вне gate — клетки c1/c2/c3: литеральное сравнение путей отклоняет `xred_…`, `…-old`, `sources[].path`;
- от молчаливого пропуска нераспознанного профиля — клетки e1/e2/e3: именованный отказ с местом из фразы резолвера;
- от второго парсера профиля в двери — грамматика и слияние слоёв берутся только у `profile_resolver.sh`, отказ проксируется; мутация SYROJ-JSON (сырой jq в двери) наблюдаемо различается клетками a2 и e3;
- от регресса прежних локаций, порядка диагностик и замороженных фраз — клетки b1–b3, d1, f1–f4 и зелёная семья 038/994 до и после реализации.

НЕ ЗАЩИЩАЕТ:
- содержательную правдивость самого gate профиля (проверяет ли он источники и как) — предмет 996 и `check_project_sources.sh`; дверь судит только факт подключения guard токеном gate;
- слой проекта, лежащий вне судимого корня (живой `HARNESS_PROJECT_LAYER_ROOT`, отличный от корня): дверь детерминированно судит слой внутри корня; внешний слой — вне границы, ловец — ревьюер проводки проекта;
- злонамеренного владельца профиля: профиль задаёт исполняемый argv, это не sandbox (граница 996 «злонамеренного доверенного владельца профиля/исполняемого gate»);
- sourced-исполнение и враждебное состояние интерпретатора до первой строки двери — граница арбитража `verdicts/arbitration/038-sourced-ispolnenie-granica.md` §3, без изменений.

Конформный контрпример — дерево с валидным двухслойным профилем, guard-файлом и живым role-каналом; значения имени guard, путей слоёв и приоритетов сами по себе критерий не меняют. Валидная контрпример-мутация обязана инвариантностью к значениям (клетки b/d/f не меняются) и расхождением на конформном входе (клетки a/e). Отсутствующий субъект, невыполняющийся резолвер, таймаут и пустая выборка дают rc 2 NOT_IMPLEMENTED, не зачёт поимки.

## Приёмка

W — `bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh`. Голый вызов и `--repo <ROOT>` судят реальную дверь выбранного дерева (умолчание — дерево батареи); `--model` заменяет только дверь моделью (скретч: модель + настоящий `profile_resolver.sh`); `--stabs` прогоняет адресные мутации модели по привязкам `stabs.tsv` (Н-39: привязки — только там и в probe.py). Сравниваются rc и полная строка результата; ожидания — в памяти probe.py до вызова субъекта.

1. Дано: текущая дверь (до реализации); когда: `bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --repo .`; тогда: rc 1, `KLETKI=19 ZELENYE=11 KRASNYE=8` (замер пачки). Красные клетки: a1-gate-profilja, a2-gate-v-defoltsah, a3-absoljutnyj-token, a4-gate-argv0, a5-gate-py — ложное «guard не подключён» на честном gate; e1-ne-json, e2-sloj-net, e3-kanon-vne-alfavita — старая фраза вместо именованного отказа профиля. `scripts/check_provodka.sh` базы не менялся (заявленное состояние, замер пачки).
2. Дано: модель с четвёртой локацией; когда: `bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --model`; тогда: rc 0, `KLETKI=19 ZELENYE=19 KRASNYE=0` (замер пачки).
3. Дано: адресные мутации модели; когда: `bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --stabs`; тогда: rc 0, `MUTACII=6 SVJAZI=7 POIMANY=7 ZHIVYH=0` (замер пачки); перед каждым предъявлением та же клетка прогнана с честной моделью.
4. Правило семьи 038/994: `bash fixtures/check_provodka/external_ci_994/probe.sh` → rc 0 на базе до реализации (замер пачки: CASES executed=76 mismatches=0, LEGACY executed=18 mismatches=0); та же команда после реализации implementer — rc 0; это регресс замороженных фраз, не замена п.8.
5. Правило формы: `bash scripts/check_spec_ready.sh . contracts/205-provodka-gate-profilja.md` → rc 0; `bash scripts/check_ids.sh .` → rc 0; `bash scripts/check_ceilings.sh .` → rc 0; `bash scripts/check_threat_model.sh . contracts/205-provodka-gate-profilja.md` → rc 0; `bash scripts/check_provodka.sh --grammar . contracts/205-provodka-gate-profilja.md` → rc 0 (замеры пачки).
6. Правило проводки черновика: полный `bash scripts/check_provodka.sh . contracts/205-provodka-gate-profilja.md` до CI-строки → rc 1 «guard не подключён» (заявленное состояние); после CI-строки orchestrator → rc 0. `bash scripts/pre_critic.sh contracts/205-provodka-gate-profilja.md` → rc 0 «КРИТИК: дверь зелёная» ДО сдачи; `bash scripts/check_precision_gate.sh . contracts/205-provodka-gate-profilja.md` → rc 0; `bash scripts/check_sdacha.sh . contracts/205-provodka-gate-profilja.md --run` → rc 0 (замеры пачки).
7. Правило живого профиля станции: `HARNESS_PROJECT_LAYER_ROOT="$PWD" bash scripts/profile_resolver.sh --repo "$PWD"` → rc 0, `sourceCanon` не объявлен — полный `check_provodka` на контрактах станции после реализации ведёт себя как прежде (живой прогон, не предпосылка).
8. Дано: реализация implementer (перенос блока модели в `scripts/check_provodka.sh`); когда: `bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --repo .`; тогда: rc 0, `KRASNYE=0`; это обязательная послеремонтная приёмка и команда нового CI self-test. Дверь после переноса байт-в-байт содержит блок модели (diff модели и двери — только шапка-комментарий блока, как в п. «Существующее»).

## Незаполненные требования:
нет

## Зоны и проводка

ЗОНА architect: contracts/205-provodka-gate-profilja.md fixtures/workshop_project/provodka_gate_205/
ЗОНА implementer: scripts/check_provodka.sh
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml

ПЕРЕСЕЧЕНИЕ implementer: scripts/check_provodka.sh — 038 носитель зоны и грамматики поля; 205 добавляет четвёртую локацию в guard_is_wired и одну новую фразу отказа (И3); фразы, порядок каналов и rc-семантика 038 не меняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_provodka.sh — 191 режим --grammar не судит подключение guard; 205 его не трогает
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_provodka.sh — 994 парная оговорка внешнего CI и фраза «guard не подключён» сохраняются дословно; baseline_038.sh и probe.py батареи 994 не правятся
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только новая строка self-test 205; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только новая строка self-test 205; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только новая строка self-test 205; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только новая строка self-test 205; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только новая строка self-test 205; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только новая строка self-test 205; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только новая строка self-test 205; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только новая строка self-test 205; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только новая строка self-test 205; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только новая строка self-test 205; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только новая строка self-test 205; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только новая строка self-test 205; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только новая строка self-test 205; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только новая строка self-test 205; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только новая строка self-test 205; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только новая строка self-test 205; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только новая строка self-test 205; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер нового self-test 205; чужие замеры сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только производная материализация генератором (`gen_ci_steps.sh`) строки нового self-test 205 из `registry/ci-steps.tsv`; чужая проводка сохраняется

ПРЕДПОСЫЛКИ:
- setting CI харнесса уже предоставляет bash, Python 3, git, jq и timeout; новых secrets, variables, environments и настроек репозитория нет; батарея строит одноразовые миры под TMPDIR, без сети, удаляет их после каждого предъявления.

Порядок: architect (контракт, батарея, модель и мутации одной пачкой; канон прогнан на станции живьём) → двери формы → critic → freeze → implementer (перенос блока модели в `scripts/check_provodka.sh`, приёмка п.8) → orchestrator (CI-строка self-test 205 и замер, `gen_ci_steps.sh --check` rc 0) → reviewer → done. Риск обычный; отдельный adversary для реализации не требуется действующим быстрым процессом.

ПРОВОДКА:
- guard=fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh

ПРОВОДКА-ЭНФОРСМЕНТ: 205 ремонтирует чистый энфорсмент существующей двери 038 (четвёртая признанная локация guard), поведенческих норм ролей не вводит. Единственный канал — guard, раннер батареи. Строку self-test и её замер коммитит orchestrator в окне freeze..done по норме «Проводка CI — оркестратором» (слово владельца 2026-10-25); до подключения строки полный check_provodka красен — это заявленное состояние черновика, не разрешение обходить дверь.
