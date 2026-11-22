# Контракт 207 — `check_zones.sh --incr`: суд окна один раз

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: обычный — инфраструктура проверки зон (дверь аудита истории); права/роли БД, авторизация, безопасность, деньги, ПД/health-данные и юридически значимые действия не затронуты.
КОНТЕКСТ: номер выдан механизмом (тег id/CONTRACT/207, строка registry/contracts.tsv на origin/main 25b66070f); owner-затравка влита (PR #1232, слово владельца 22.11 ~14:05: «Да: новый предмет станции — ускорение check_zones --incr (суд окна один раз); таймаут не поднимать») и заменяется этим текстом целиком. Один PR, architect → implementer → reviewer; бюджет судов не меняется.
СДАЧА: fixtures/workshop_project/check_zones_incr_207/SDACHA.md

## Боль и обещание

Измерено Diag083 (implementer-glm, носитель 187, 22.11 13:20): `bash scripts/check_zones.sh --incr` на окне PR #1219/#1231 (22–26 коммитов, 605 путей `fixtures/workshop_project/odin_agent_140/…`; форма CI: HEAD=head PR, HEAD~1=merge-base) завершается rc 0 за 662–703 с на этом сервере при `timeout 300` клетки И0б батареи 083 → rc 124, красный `obshchij` у PR. Причина по коду: `--incr` сужает только диапазон коммитов (scripts/check_zones.sh:687-690), а суд окна повторяется на КАЖДЫЙ контракт с зонами (:677 × :1035, :1041) — в объединении 181 контракт с зонами; множество зон автора (`mine`, :1051) от контракта не зависит, и на каждый путь линейно читается объединение зон (:1597-1602). Формула замера: `T ≈ 42 с + Σ_коммитов N_zone(автор) × (22–30 мс + 5.0 мс × путей)`; what-if «судить окно один раз» — 30.0 с, rc 0.

Один результат: в incr-режиме данные окна (список коммитов, merge-исключения, batched-авторы, batched-пути, решения по путям) готовятся ОДНИМ проходом до цикла по контрактам, а цикл по контрактам воспроизводит только пер-контрактные решения (счётчики, СПАСЕНО, сообщения) из готовых данных. Наблюдение — rc, полный вывод, маркер `incr: check_zones судит … (N коммит…)`, запись кеша HEAD и счётчик судов окна (execve-счёт git-вызовов под strace — тот же канал измерения, что красное 040 fixtures/check_zones/red_predel_git_vyzovov.sh). Затронутые frozen-обязательства — инвариант 6 контракта 083 (грамматика `--incr` lib_incr.sh, маркер, кеш) и эквивалентность вывода семьи 040: не сужаются, судятся клетками эквивалентности ниже.

## Существующее

- scripts/check_zones.sh — действующая дверь; полный режим не трогается (байт-в-байт), меняется только incr-ветвь. Файл в union: implementer по 013/016/021/023/031/040/049/073/083/086/184/996, architect по 002/003/047 — реализация за implementer, ПЕРЕСЕЧЕНИЕ ниже.
- scripts/lib_incr.sh (контракт 083, инв. 6) уже несёт грамматику `--incr <кеш>`, маркер с истинным числом коммитов окна и атомарную запись INCR_HEAD при rc 0 — переиспользуется без правок.
- Контракт 040 уже батчит git-вызовы ВНУТРИ окна (batched author lookup, batched diff-tree, completeness-гарды, структурный разбор) — 207 выносит этот батчинг из цикла по контрактам: те же вызовы и гарды, один раз на прогон.
- Merge-исключения `land: wip/<NNN>/…` (контракт 021), draft-признание 023(iv), минт-признание 031(ii)/049, СПАСЕНО, фильтр процессных файлов, union-семантика зон 033 — сохраняются дословно; их инварианты держит семья fixtures/check_zones/ (регресс без правки текстов клеток) и батарея 083.
- fixtures/workshop_project/sdacha_193/ и karta_vyzova_204 — прецедент режимов --repo/--model/--stabs: раннер + probe.py + model/ + stabs.tsv + SDACHA.md.

## Frontier

1. Кеш готовых данных в `$TMP` между итерациями цикла по контрактам (memo по диапазону). Отвергнут: не убирает повторный линейный суд путей — главный член формулы (5.0 мс × путей × N_zone) остаётся, окно всё ещё судится K раз на уровне решений.
2. Суд окна только для первого контракта, остальные доверяют его результату. Отвергнут: СПАСЕНО, автор-фильтры и счётчики пер-контрактные — доверие теряет пер-контрактные сообщения и сводку, эквивалентность нарушается.
3. Выбрано: один проход данных окна + пер-контрактный replay готовых решений — вывод байт-в-байт, git-вызовы окна = 4 на прогон (rev-list ×2, log --no-walk, diff-tree), не по одному набору на контракт.

## Решение и инварианты

- И1 — ОДИН СУД ОКНА: в incr-режиме git-вызовы окна исполняются один раз за прогон: `rev-list --no-merges --reverse <base>..HEAD` — 1, `rev-list --merges <base>..HEAD` — 1, batched `log --no-walk --stdin` — 1 при непустом окне (0 при пустом), batched `diff-tree --stdin` — 1 при непустом matched (0 иначе); субъекты merge'ей (`log -1 --format=%s`) и принесённые (`rev-list mc^1..mc`) — по одному на merge окна, не на контракт. Число судов окна не зависит от количества контрактов с зонами.
- И2 — ЭКВИВАЛЕНТНОСТЬ: на любом входе incr-режим даёт тот же rc, тот же полный вывод (ok/bad-строки в том же порядке, включая повторы пер-контрактных сообщений), тот же маркер с истинным N, ту же запись кеша HEAD при rc 0 (и тот же отказ записи при rc≠0) и ту же сводку «замороженных контрактов … коммитов в диапазонах … проверено по зонам», что прежняя реализация; полный режим (без `--incr`) — байт-в-байт прежний вывод и rc.
- И3 — ПОВЕДЕНИЕ ПРИЗНАНИЙ СОХРАНЕНО: draft-признание (023 iv, руки А/Б), минт-признание (031 ii, обе формы), СПАСЕНО, процессный фильтр, merge-исключения по `land: wip/<NNN>/…`, union-семантика зон 033 — та же семантика и те же тексты; решения по путям контракт-независимы и потому вычисляются один раз на пару (коммит, путь).
- И4 — БЮДЖЕТ: окно A2-типа (22 коммита, 605 путей, автор architect, 100 путей на коммит, 20 контрактов с зонами) в одноразовом репо: rc 0, маркер «(22 коммита)», кеш перезаписан HEAD, судов окна ровно один (И1); замер секунд — наблюдение, не порог клетки (клетка считает суды, а не секунды, чтобы не флачить под нагрузкой). `timeout 300` клетки И0б батареи 083 не поднимается.
- И5 — FAIL-CLOSED СОХРАНЁН: отказы git-вызовов окна и completeness-гарды 040 остаются именованными отказами rc 1 с теми же текстами; пустое окно — маркер «(0 коммитов)», ноль судов авторов/путей, rc 0.
- И6 — грамматика lib_incr.sh (083, инв. 6) не меняется: `--incr <кеш>`, ветви (а)/(б)/(в′), запись INCR_HEAD, маркер — дословно.

## Модель угроз

ЗАЩИЩАЕТ:
- от повтора суда окна на каждый контракт с зонами: счётчик execve git-вызовов под strace, снятый вне процесса субъекта, сравнивается с 1 на окнах трёх форм (непустое, пустое, только необъявленные авторы) и при K=8 и K=24 контрактах;
- от молчаливой потери поведения: полный вывод байтами (включая повторы пер-контрактных bad-строк), rc, маркер с истинным N, запись кеша и сводка сверяются с производственной дверёй дерева на каждом мире батареи, а полный режим — с полным прогоном той же двери;
- от подмены вердикта, обрезки окна, игнора кеша-базы, пропуска merge-исключений, немоты СПАСЕНО и замороженного счётчика: перечень адресных мутаций в stabs.tsv, ожидаемый результат каждой — отклонение связанной клетки от зелёного (Н-39: привязки данными батареи, не прозой контракта).

НЕ ЗАЩИЩАЕТ:
- полный режим двери: он не меняется вовсе и судится регрессом семьи fixtures/check_zones/ и батареи 083 на производственной двери, не клетками этой батареи; ловец — reviewer регресса;
- блок «ПРЕДСТОЯЩЕЕ v+1» (130), REPLACE-форма минт-признания (049) и исторические гварды-исключения в модели батареи: недостижимы на её мирах (нет accept-вердиктов v+1 и форм замены), их держит регресс семьи на производственной двери; ловец — critic/reviewer регресса;
- тексты fail-closed отказов git-окружения (040): на мирах батареи git здоров, отказы недостижимы и побайтово не сравниваются; ловец — регресс семьи 040;
- секундный бюджет как порог клетки: секунды — наблюдение; порог при нагрузке держит счётчик судов (И1), ловец превышения на живом PR — красная клетка И0б батареи 083.

Конформный контрпример — мир батареи с замороженными контрактами и окном поверх кеша-предка; значения sha, имён авторов и числа коммитов сами по себе критерий не меняют. Он обязан различать честную реализацию и мутацию инвариантов И1–И5. Отсутствующий strace, субъект или мир дают rc 2 NOT_IMPLEMENTED, не поимку.

## Приёмка

W — `bash fixtures/workshop_project/check_zones_incr_207/red_check_zones_incr_207.sh`. `--repo <корень>` судит реальную `scripts/check_zones.sh` выбранного дерева; `--model` заменяет её моделью окна-один-раз в scratch-копии scripts/ и сверяет с базовой дверёй байт-в-байт; `--stabs` прогоняет честный контроль и адресные мутации по stabs.tsv. Привязки мутаций — только stabs.tsv и probe.py.

1. Дано: дверь базы main 25b66070f (до реализации); когда: `W --repo .`; тогда: rc 1, KLETKI=19 ZELENYE=13 KRASNYE=6 (замер пачки); красные клетки — ровно c1-okno-odin-raz, c2-pustoe-okno-schet, c3-fon-okno-schet, c4-byudzhet-a2, c5-nezavisimost-k8, c6-nezavisimost-k24: у базы судов окна столько, сколько контрактов с зонами — rk_rev/rk_merges/ak/dt = 3/3/3/3 на c1 (K=3), 2/2/0/0 на c2 (пустое окно), 2/2/2/0 на c3 (K=2, нет объявленных авторов в окне), 20/20/20/20 на c4 (K=20), 8/8/8/8 на c5 (K=8), 24/24/24/24 на c6 (K=24); все e-клетки эквивалентности на базе зелёные (поведение базы и есть эталон). Замер секунд c4 на базе — 12.4 с (одноразовое репо A2 без strace; наблюдение; на живом дереве станции с 181 контрактом то же окно — 662–703 с, Diag083).
2. Дано: модель окна-один-раз; когда: `W --model`; тогда: rc 0, KLETKI=19 ZELENYE=19 KRASNYE=0 (замер пачки). Клетки e1–e13 — эквивалентность (rc, байты против базовой двери и против полного прогона производственной двери, маркер с истинным N, кеш, сводка, повторы bad-строк по контрактам) на мирах: чистое окно с необъявленным автором, чужая зона, архитектор в зоне implementer, merge-окно (свой и чужой `land: wip/…`), пустое окно, окно из одного коммита, СПАСЕНО-replay, пересечение зон двух контрактов, окно из необъявленных авторов, нарушение в середине окна с до-базовым коммитом вне суда, draft-признание, минт-признание ADD, процессные пути. Клетки c1–c6 — судов окна ровно один (1/1/1/1 на непустом окне; 1/1/0/0 на пустом; 1/1/1/0 без объявленных авторов в окне; 1/1/1/1 при K=8 и K=24); c4 — rc 0, 605 путей, кеш перезаписан HEAD, замер секунд 4.4 с без strace / 21.2 с под strace в клетке (наблюдение).
3. Дано: адресные мутации и обманные файлы-заглушки; когда: `W --stabs`; тогда: rc 0, MUTACII=10 SVJAZI=10 POIMANY=10 ZHIVYH=0 (замер пачки); перед каждым предъявлением честная модель на клетке связи зелёная.
4. Правило сохранения семьи: на дереве базы `npm run check:antiplacebo -- --scope check_zones` → rc 0; после реализации — та же команда rc 0, тексты клеток семьи не переписываются. Затронутая И0/И0б батареи 083: `bash fixtures/_krasnye_083.sh` на дереве базы → rc 0 (замер пачки); после реализации клетка И0б обязана укладываться в прежний `timeout 300` на живых PR (слово владельца: таймаут не поднимается).
5. Правило сдаточного листа: `bash scripts/check_sdacha.sh . contracts/207-check-zones-incr-odin-sud-okna.md --run` → rc 0, двери=5 карта=17/17 дельта=0 (замер пачки); лист несёт rc-стабильные --model/--stabs, красное-до реального субъекта записано прозой.
6. Правило формы: `bash scripts/check_spec_ready.sh . contracts/207-check-zones-incr-odin-sud-okna.md` → rc 0; `bash scripts/check_ids.sh .` → rc 0; `bash scripts/check_ceilings.sh .` → rc 0; `bash scripts/check_provodka.sh --grammar . contracts/207-check-zones-incr-odin-sud-okna.md` → rc 0 (замеры пачки). Полный `bash scripts/check_provodka.sh . contracts/207-check-zones-incr-odin-sud-okna.md` до CI-строки — rc 1 «guard не подключён» (заявленное состояние черновика, не разрешение обходить дверь); после строки orchestrator — rc 0. `bash scripts/pre_critic.sh contracts/207-check-zones-incr-odin-sud-okna.md` → rc 0 «КРИТИК: дверь зелёная»; диагностический `bash scripts/check_precision_gate.sh . contracts/207-check-zones-incr-odin-sud-okna.md` → rc 0.
7. Дано: реализация implementer; когда: `W --repo .`; тогда: rc 0, KLETKI=19 ZELENYE=19 KRASNYE=0 — обязательная послеремонтная приёмка и команда нового CI self-test; артефакты 083 и клетки семьи не переписываются.

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
