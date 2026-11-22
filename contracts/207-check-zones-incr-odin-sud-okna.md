# Контракт 207 — `check_zones.sh --incr`: суд окна один раз

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: обычный — инфраструктура проверки зон (дверь аудита истории); права/роли БД, авторизация, безопасность, деньги, ПД/health-данные и юридически значимые действия не затронуты.
КОНТЕКСТ: номер выдан механизмом (тег id/CONTRACT/207, строка registry/contracts.tsv на origin/main 25b66070f); owner-затравка влита (PR #1232, слово владельца 22.11 ~14:05: «Да: новый предмет станции — ускорение check_zones --incr (суд окна один раз); таймаут не поднимать») и заменяется этим текстом целиком. Один PR, architect → implementer → reviewer; бюджет судов не меняется.
СДАЧА: fixtures/workshop_project/check_zones_incr_207/SDACHA.md

## Боль и обещание

Измерено Diag083 (implementer-glm, носитель 187, 22.11 13:20): `bash scripts/check_zones.sh --incr` на окне PR #1219/#1231 (22–26 коммитов, 605 путей `fixtures/workshop_project/odin_agent_140/…`; форма CI: HEAD=head PR, HEAD~1=merge-base) завершается rc 0 за 662–703 с на этом сервере при `timeout 300` клетки И0б батареи 083 → rc 124, красный `obshchij` у PR. Причина по коду: `--incr` сужает только диапазон коммитов (scripts/check_zones.sh:687-690), а суд окна повторяется на КАЖДЫЙ контракт с зонами (:677 × :1035, :1041) — в объединении 181 контракт с зонами; множество зон автора (`mine`, :1051) от контракта не зависит, и на каждый путь линейно читается объединение зон (:1597-1602). Формула замера: `T ≈ 42 с + Σ_коммитов N_zone(автор) × (22–30 мс + 5.0 мс × путей)`; what-if «судить окно один раз» — 30.0 с, rc 0.

Один результат: в incr-режиме данные окна (список коммитов, merge-исключения, batched-авторы, batched-пути, решения по путям) готовятся ОДНИМ проходом до цикла по контрактам, а цикл по контрактам воспроизводит только пер-контрактные решения (счётчики, СПАСЕНО, сообщения) из готовых данных. Наблюдение — rc, полный вывод, маркер `incr: check_zones судит … (N коммит…)`, запись кеша HEAD и счётчик судов окна (execve-счёт git-вызовов под strace — тот же канал измерения, что красное 040 fixtures/check_zones/red_predel_git_vyzovov.sh). Затронутые frozen-обязательства — инвариант 6 контракта 083 (грамматика `--incr` lib_incr.sh, маркер, кеш) и эквивалентность вывода семьи 040: не сужаются, судятся клетками эквивалентности ниже.

## Существующее

- scripts/check_zones.sh — действующая дверь; полный режим не трогается (байт-в-байт), меняется только incr-ветвь. Файл в union: implementer по 013/016/021/023/031/040/049/073/083/086/184/996, architect по 002/003/047 — реализация за implementer, ПЕРЕСЕЧЕНИЕ ниже. В базе :614–618 пустое объединение зон завершает дверь ДО суда окна и без `incr_finish`: при K=0 сохраняются нулевые суды, прежний вывод и прежний кеш.
- scripts/lib_incr.sh (контракт 083, инв. 6) уже несёт грамматику `--incr <кеш>`, маркер с истинным числом коммитов окна и атомарную запись INCR_HEAD при вызове `incr_finish 0` — переиспользуется без правок.
- Контракт 040 уже батчит git-вызовы ВНУТРИ окна (batched author lookup, batched diff-tree, completeness-гарды, структурный разбор) — 207 выносит этот батчинг из цикла по контрактам: те же вызовы и гарды, один раз на прогон при K>0.
- Merge-исключения `land: wip/<NNN>/…` (контракт 021), draft-признание 023(iv), минт-признание 031(ii)/049, СПАСЕНО, фильтр процессных файлов, union-семантика зон 033 — сохраняются дословно; их инварианты держит семья fixtures/check_zones/ (регресс без правки текстов клеток) и батарея 083.
- fixtures/workshop_project/sdacha_193/ и karta_vyzova_204 — прецедент режимов --repo/--model/--stabs: раннер + probe.py + model/ + stabs.tsv + SDACHA.md.

## Frontier

1. Кеш готовых данных в `$TMP` между итерациями цикла по контрактам (memo по диапазону). Отвергнут: не убирает повторный линейный суд путей — главный член формулы (5.0 мс × путей × N_zone) остаётся, окно всё ещё судится K раз на уровне решений.
2. Суд окна только для первого контракта, остальные доверяют его результату. Отвергнут: СПАСЕНО, автор-фильтры и счётчики пер-контрактные — доверие теряет пер-контрактные сообщения и сводку, эквивалентность нарушается.
3. Выбрано: один проход данных окна + пер-контрактный replay готовых решений — оба канала вывода байт-в-байт; при K>0 до четырёх git-вызовов окна на прогон (rev-list ×2, log --no-walk, diff-tree), не по набору на контракт; при K=0 прежний ранний выход без судов окна.

## Решение и инварианты

- И1 — ОДИН СУД ОКНА: K — число замороженных контрактов с зонами. При K=0 rk_rev/rk_merges/ak/dt = 0/0/0/0: прежний ранний выход «зон не объявлено — проверять нечего». При K>0 `rev-list --no-merges --reverse <base>..HEAD` — 1, `rev-list --merges <base>..HEAD` — 1, batched author lookup (`log`, `--stdin`, `--no-walk` либо `--no-walk=sorted|unsorted`) — 1 при непустом окне, 0 при пустом; batched `diff-tree --stdin` — 1 при непустом matched, 0 иначе. Субъекты merge'ей и принесённые коммиты — по одному на merge окна, не на контракт. Это запрет повторного суда, не только лимит наблюдаемых процессов.
- И2 — ЭКВИВАЛЕНТНОСТЬ: на любом входе incr-режим даёт тот же rc и отдельно те же полные байты stdout и stderr, что прежняя реализация: порядок различных ok/bad-строк и повторы пер-контрактных сообщений сохраняются. Маркер с истинным N, сводка и состояние кеша — те же: при K>0 и rc 0 записывается HEAD, при rc≠0 кеш не перезаписывается; при K=0 ранний выход не вызывает `incr_finish`, кеш остаётся базой даже при rc 0. Полный режим (без `--incr`) — байт-в-байт прежние stdout/stderr и rc.
- И3 — ПОВЕДЕНИЕ ПРИЗНАНИЙ СОХРАНЕНО: draft-признание (023 iv, руки А/Б), минт-признание (031 ii, обе формы), СПАСЕНО, процессный фильтр, merge-исключения по `land: wip/<NNN>/…`, union-семантика зон 033 — та же семантика и те же тексты; решения по путям контракт-независимы и потому вычисляются один раз на пару (коммит, путь).
- И4 — МЕРА: окно A2-типа (22 коммита, 605 путей, автор architect, 100 путей на коммит, 20 контрактов с зонами) даёт rc 0, маркер «(22 коммита)», кеш HEAD и счёт И1, независимый от K. Считаются успешные execve предметных операций внешним strace, не секунды. Инвентарь доверенного Git снимается до субъекта: основная установка и `git --exec-path` (git, git-log, git-rev-list, git-diff-tree), идентичность по inode/SHA256, не имени; симлинк, жёсткая ссылка, копия того же бинарника, `/bin`/`/usr/bin` и относительный путь из cwd вызывавшего процесса не меняют счёт. Dispatch — basename argv0 `git-<команда>` или команда после глобальных `-C <dir>`, `-c <key=value>`, `--no-pager`, `--paginate`, `--bare`, `--git-dir=`, `--work-tree=`, `--exec-path=` и их сочетаний; значения не сканируются как команды. Отдельные опции нормализуются независимо от порядка/формата с сохранением границы операндов. Обёртки command/env/sh/xargs и функции учитываются по фактическим дочерним execve; алиас — только раскрытый дочерний builtin, не ещё и родитель. GIT_EXEC_PATH/--exec-path не исключают доверенных детей. Неизвестный dispatch, отсутствие раскрытого дочернего dispatch алиаса или неполная/неразобранная трасса — rc 2 NOT_IMPLEMENTED, не поимка и не зелёная приёмка. `timeout 300` клетки И0б батареи 083 не поднимается.
- И5 — FAIL-CLOSED СОХРАНЁН: отказы git-вызовов окна и completeness-гарды 040 остаются именованными отказами rc 1 с теми же текстами; при K>0 пустое окно — маркер «(0 коммитов)», ноль судов авторов/путей, rc 0.
- И6 — грамматика lib_incr.sh (083, инв. 6) не меняется: `--incr <кеш>`, ветви (а)/(б)/(в′), запись INCR_HEAD, маркер — дословно.

## Модель угроз

ЗАЩИЩАЕТ:
- от повтора суда окна на каждый контракт и обхода внешнего счётчика штатными Git-формами из И4: единый нормализатор калибруется честными эквивалентными формами и адресными повторами; принадлежность Git устанавливает предсубъектный инвентарь, не argv0 чужой программы;
- от молчаливой потери поведения: rc и отдельно полные байты stdout/stderr, порядок разных нарушений и повторы по контрактам, маркер, кеш и сводка сверяются с производственной дверью; канон в памяти до субъекта. Для мира с до-базовым нарушением полный канон судит отдельную копию с frozen/1 на кеш-базе; `--model` дополнительно сверяется с прежним incr-прогоном;
- от подмены вердикта, обрезки окна, игнора кеша-базы, пропуска merge-исключений, немоты СПАСЕНО и замороженного счётчика: адресные мутации объявлены в stabs.tsv, различающие предъявления заданы кодом батареи (Н-39), перед каждым предъявлением честный контроль зелёный.

НЕ ЗАЩИЩАЕТ:
- полный режим двери: он не меняется вовсе и судится регрессом семьи fixtures/check_zones/ и батареи 083 на производственной двери; ловец — reviewer регресса;
- блок «ПРЕДСТОЯЩЕЕ v+1» (130), REPLACE-форма минт-признания (049) и исторические гварды-исключения в модели батареи: недостижимы на её мирах; их держит регресс семьи на производственной двери; ловец — critic/reviewer регресса;
- тексты fail-closed отказов git-окружения (040): на мирах батареи git здоров, отказы недостижимы и побайтово не сравниваются; ловец — регресс семьи 040;
- НЕ ЗАЩИЩАЕТ: счётчик 207 не доказывает отсутствие эквивалентного повторного вычисления авторов произвольным кодом вне доверенного Git-dispatch: иной/модифицированный Git, libgit2, ручное чтение objects, Git plumbing с иной семантикой, memfd/fexecve/execveat вне наблюдаемого execve-канала. Это не разрешение повторять суд; обязательство одного суда сохраняется. Ловец — reviewer реализации 207 по изменённому алгоритму; adversary реализации при назначенном вызове предъявляет независимый способ повтора.
- НЕ ЗАЩИЩАЕТ: батарея не доказывает отсутствие распознавания фикстуры, подмены доверенного инструмента/трассы, динамической смены исполняемых файлов и согласованного обхода всех наблюдаемых каналов. Ловцы — reviewer границы доверия и adversary реализации при его назначении; сомнительная трасса не даёт зелёный результат и не считается поимкой.
- НЕ ЗАЩИЩАЕТ: единичный счёт Git-операций не гарантирует секундный бюджет при произвольной нагрузке, стоимости shell-обработки и размерах живой истории. Ловец — неизменённый timeout 300 клетки И0б батареи 083 и CI-замер живого check_zones --incr; reviewer требует этот результат после реализации. Таймаут не поднимать.

Принятие первых двух дословных границ арбитража f803aa2056423f83495331bb36174fe3da878bcc — К ВЛАДЕЛЬЦУ, ожидает слова владельца. И1 не ослаблен; арбитраж не разрешает freeze или ВЫЗОВ-3-207. Санкцию узкого вызова оформляет консультант сессии по ADR 17.11 либо владелец.

Конформный контрпример — поддержанный git-мир с замороженными контрактами и окном поверх кеша-предка, включая K=0 с объявленным отказом от раздачи. Значения sha, имён авторов и числа коммитов сами по себе критерий не меняют. Контрпример обязан различать честную реализацию и мутацию И1–И5. Отсутствующий инструмент, субъект, мир или недостоверная трасса дают rc 2 NOT_IMPLEMENTED, не поимку.

## Приёмка

W — `bash fixtures/workshop_project/check_zones_incr_207/red_check_zones_incr_207.sh`. `--repo <корень>` судит реальную scripts/check_zones.sh, сравнивая rc и отдельно полные stdout/stderr incr с полным производственным прогоном того же окна; `--model` дополнительно сравнивает модель с прежней incr-дверью. `--stabs` предъявляет адресные мутации после честного контроля; связи — только stabs.tsv и probe.py. h-клетки обоих режимов калибруют общий нормализатор на настоящем Git; n-клетки требуют rc 2 непригодного измерителя, не считают его поимкой. Субъект c/e/k0-клеток ими не заменяется.

1. Дано: production до реализации; когда: `W --repo .`; тогда: rc 1, KLETKI=48 ZELENYE=42 KRASNYE=6; красны ровно c1–c6. rk_rev/rk_merges/ak/dt базы: 3/3/3/3, 2/2/0/0, 2/2/2/0, 20/20/20/20, 8/8/8/8, 24/24/24/24 соответственно; остальные клетки зелёные.
2. Дано: честная модель; когда: `W --model`; тогда: rc 0, KLETKI=48 ZELENYE=48 KRASNYE=0. Эквивалентность, K=0, пустое окно, порядки replay/путей, A2 и независимость от K сохраняют байтовые и счётные ожидания И1–И6; калибровка И4 принимает единственный штатный dispatch и не доверяет имени чужого бинарника.
3. Дано: адресные мутации; когда: `W --stabs`; тогда: rc 0, MUTACII=32 SVJAZI=32 POIMANY=32 ZHIVYH=0, каждый честный контроль зелёный. `W --model --mutation <имя-из-PATERNS>` → сырой rc 1 различающей клетки. `W --catalog` → rc 0, независимый пересчёт реестров EQ=16 C=6 H=21 N=4 K0=1 KLETKI=48 STABS=32 PATERNS=30 ANCHORS=1.
4. Правило регресса: `npm run check:antiplacebo -- --scope check_zones` → rc 0 на базе и после реализации, без конкурентных записей дерева, включая scratch; `bash fixtures/_krasnye_083.sh` → rc 0 на базе и после реализации. Тексты семьи и timeout 300 клетки И0б не переписываются.
5. Правило листа: `bash scripts/check_sdacha.sh . contracts/207-check-zones-incr-odin-sud-okna.md --run` → rc 0, бюджет 900 с. Красное-до production записано прозой, лист исполняет rc-стабильные модель/стабы и адресную дельту.
6. Правило формы: `bash scripts/check_spec_ready.sh . contracts/207-check-zones-incr-odin-sud-okna.md`, `bash scripts/check_ids.sh .`, `bash scripts/check_ceilings.sh .`, `bash scripts/check_provodka.sh --grammar . contracts/207-check-zones-incr-odin-sud-okna.md`, `bash scripts/pre_critic.sh contracts/207-check-zones-incr-odin-sud-okna.md`, `bash scripts/check_precision_gate.sh . contracts/207-check-zones-incr-odin-sud-okna.md`, `bash scripts/check_threat_model.sh . contracts/207-check-zones-incr-odin-sud-okna.md` → каждый rc 0. Полный check_provodka до CI-строки — rc 1 «guard не подключён»; после проводки orchestrator — rc 0.
7. Дано: реализация implementer с конечной границей И4; когда: последовательно `W --repo .`, `W --model`, `W --stabs`; тогда: каждый rc 0, production и модель KLETKI=48 ZELENYE=48 KRASNYE=0, стабы ZHIVYH=0. Это обязательная послеремонтная приёмка, `W --repo .` — команда CI self-test; независимые байтовые проверки порядка и stdout, нулевой счёт K=0 и rc 2 непригодной трассы сохраняются.

## Незаполненные требования:
нет

## Зоны и проводка

ЗОНА architect: contracts/207-check-zones-incr-odin-sud-okna.md fixtures/workshop_project/check_zones_incr_207/
ЗОНА implementer: scripts/check_zones.sh
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml

ПЕРЕСЕЧЕНИЕ implementer: scripts/check_zones.sh — 002 файл в union у architect по 002; 207 переставляет только incr-ветвь (данные окна одним проходом, replay пер-контрактных решений), полный режим, тексты ok/bad и признания — дословно
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_zones.sh — 003 файл в union у architect по 003; 207 переставляет только incr-ветвь, метрики и адаптация гейта зон не трогаются
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_zones.sh — 047 файл в union у architect по 047; 207 не трогает признание черновика (руки А/Б) и грамматику basename
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только новая строка self-test 207; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только новая строка self-test 207; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только новая строка self-test 207; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только новая строка self-test 207; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только новая строка self-test 207; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только новая строка self-test 207; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только новая строка self-test 207; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только новая строка self-test 207; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только новая строка self-test 207; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только новая строка self-test 207; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только новая строка self-test 207; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только новая строка self-test 207; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только новая строка self-test 207; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только новая строка self-test 207; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только новая строка self-test 207; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только новая строка self-test 207; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только новая строка self-test 207; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер нового self-test 207; чужие замеры сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только производная материализация генератором `scripts/gen_ci_steps.sh` из `registry/ci-steps.tsv` строки нового self-test 207; чужая проводка сохраняется

ПРЕДПОСЫЛКИ:
- setting CI харнесса уже предоставляет bash, Python 3, git, strace 6.x (счётчик судов окна — тот же канал измерения, что красное 040), awk, sed, grep, sort, tr, wc, mktemp и comm; новых secrets, variables, environments и настроек репозитория нет; одноразовые миры живут под TMPDIR и удаляются пробой.

Порядок: architect (контракт, батарея, модель и мутации одной пачкой; канон прогнан на станции) → двери формы → critic → freeze → implementer (перенос инвариантов И1–И3 в производственную check_zones.sh) → orchestrator (CI-строка self-test 207, замер, `gen_ci_steps.sh --check` rc 0) → reviewer → done. Риск обычный, отдельный adversary для реализации не требуется действующим быстрым процессом.

ПРОВОДКА:
- guard=fixtures/workshop_project/check_zones_incr_207/red_check_zones_incr_207.sh

ПРОВОДКА-ЭНФОРСМЕНТ: 207 ремонтирует чистый энфорсмент (скорость incr-ветви существующей двери при неизменном поведении), поведенческих норм ролей не вводит. Единственный канал — guard, раннер семьи. Строку self-test и её замер коммитит orchestrator в окне freeze..done по норме «Проводка CI — оркестратором» (слово владельца 2026-10-25); до подключения строки полный check_provodka красен, это заявленное состояние черновика, не разрешение обходить дверь.
