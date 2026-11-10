# Контракт 185 — pre_judge prepare: детектор харнесса судит корень проекта

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: обычный — меняется источник существующего детектора в преддверии судьи, но не полномочия, авторизация, деньги, ПД/health-данные, согласия или юридически значимые действия.
КОНТЕКСТ: Н-441, слово владельца 10.11.2026 ~15:46 UTC «да» через консультанта: backend-судьи были блокированы с ~15:40. В проектном `R` нет `scripts/check_no_leak.sh`; до owner-хотфикса #708 `pre_judge prepare` отвечал rc 2 «нет детектора утечки». Хотфикс снял блокировку, но оставил локальную подмену детектора.

## Существующее

- Дверь `scripts/pre_judge.sh` (prepare, строки 197–260) проверяет опубликованный tip ветки, внешний каталог состояния и манифесты. Owner-хотфикс #708 уже в main: сначала выбирается `$R/scripts/check_no_leak.sh`, при его отсутствии — детектор из каталога запущенного `pre_judge.sh`; лишь при отсутствии обоих rc 2 «нет детектора утечки». Действующий проект без локального скрипта уже проходит `prepare`; проектный фейк `exit 0` при наличии подменяет доверенный детектор. **Дельта 185:** всегда детектор установки к R, даже если локальный файл существует; отсутствие установочного детектора не допускает fallback в R. Проверки публикации/состояния/манифестов, `--check "$R"`, rc 1 красного детектора и остальные три режима остаются от хотфикса и frozen 172.
- Детектор `scripts/check_no_leak.sh` (024/031/044/056) принимает абсолютный корень как отдельный argv для `--snapshot`, `--check`, `--retake*`; профильный `996` использует независимый проектный клон, `125` — сессии проектов, `161` — проектную раскладку. Новый детектор или копия в проекте не нужны. Снимок и переснятие проектного корня остаются за существующим детектором и вызывающим; 185 меняет **только источник исполняемого детектора в prepare**, не переписывает snapshot/retake, правила снимка или проектный профиль. Необходимость действующего снимка у R остаётся прежней.
- Семьи `fixtures/check_judge_gate/`, `fixtures/check_no_leak/` уже проверяют сам детектор и его снятие/переснятие; `fixtures/workshop_project/pre_judge_leak_185/` проверяет связь установленных скриптов с отдельным Git-корнем проекта без мутации установки. Frozen 172 фиксирует отдельную дверь и семью `fixtures/dver_pered_kritikom/predverie_172/`: её `published` создаёт локальный фейковый детектор и не создаёт снимка для настоящего детектора установки; после дельты 185 этот старый вход краснеет, хотя остальные ветви 172 сохраняются. Н-193 — опасность общей `.git` у worktree: toy создаёт независимые `.git`; Н-301 — bootstrap-петля, не поведение двери. Н-441 записан в `NABLIUDENIA.md`; Н-152 (сырой bash/git вне write-guard) остаётся ОТКРЫТЫМ.

## Предмет и frontier

Один результат: `bash <установка>/scripts/pre_judge.sh prepare --repo R --branch B --sostojanie S --timeout 0` берёт исполняемый `check_no_leak.sh` из каталога **этого** `pre_judge.sh` и запускает `bash "$DETECTOR" --check "$R"`; корень `R` остаётся каноническим Git-корнем, переданным через `--repo`, а не подменяется корнем установки. В self-режиме, где установка и R совпадают, результат прежний. Детектор локального проекта, даже при наличии, НЕ участвует в выборе. Если детектора установки нет, rc 2 `NOT_IMPLEMENTED: нет детектора утечки харнесса: scripts/check_no_leak.sh`; rc≠0 действующего детектора — rc 1 `CHECK_NO_LEAK_KRASEN`, без `OBJECT`/`SOSTOJANIE`. Остальные проверки и четыре режима двери 172 не меняются. Копия в проект и запасной поиск в R запрещены.

Frontier: (а) всегда детектор установки к R; (б) проектный детектор при наличии, иначе установочный. Выбран (а): измеренная причина — отсутствие файла в R, а (б) делает безопасность зависимой от файлов проекта и позволяет локальному `exit 0` подменить защиту перед судьёй. При отсутствии установочного детектора отказ, не зелёный fallback.

Конформный вход: самостоятельные Git-деревья установки и проекта, опубликованный локальный `origin/B` равный B, существующий внешний S, `--snapshot R` снят настоящим установочным детектором до `prepare`; отсутствие файла детектора установки — отдельно названный неконформный отказ окружения. Снимок установки существует только для отрицательной пробы неверного корня. Валидный контрпример на конформном входе инвариантен к Git OID, именам/путям деревьев и значениям отслеживаемого файла, но расходится по rc или содержимому вывода; один только rc2 на отсутствующем снимке без подготовки не является контрпримером. Оракул OID, S и ожидаемого rc задаётся в памяти до вызова, не читается из дерева проверяемого после вызова.

## Модель угроз

ЗАЩИЩАЕТ:
- Детектор установленного харнесса проверяет изменённый проектный корень вместо чистой установки; локальный поддельный скрипт проекта не получает управление при подготовке судьи.
- Отсутствующий детектор установки даёт именованный отказ без допуска судьи, даже если проект предоставляет собственный скрипт с успешным кодом возврата.
НЕ ЗАЩИЩАЕТ:
- Подмену самой установки или доверенного системного PATH проверяет отдельная штатная церемония оркестратора; семантика снимка проектного корня остаётся прежним обязательством детектора 024.
- Необслуженные иные проектные двери, сырой git/bash Н-152 и переснятие снимка поверх опасной дельты Н-165 остаются остаточным риском для ревьюера на живой установке.

## Приёмка

- Дано: отдельный чистый проект R без локального `scripts/check_no_leak.sh`, настоящий установочный детектор и снятый снимок R; когда `python3 fixtures/workshop_project/pre_judge_leak_185/probe.py --repo`; тогда после исправления rc 0, `clean ZELENO` с точными `OBJECT=<origin/B>` и `SOSTOJANIE=<realpath S>`; на owner-хотфиксе #708 эта клетка уже зелёная. Та же команда без аргументов эквивалентна `--repo` и является CI-входом.
- Дано: tracked-файл R изменён после снимка при чистом корне установки; когда та же команда `--repo`; тогда rc 0 пробы только если `dirty ZELENO`: у двери rc 1 `CHECK_NO_LEAK_KRASEN` и нет `OBJECT`. Дано: в грязном R дополнительно есть локальный `scripts/check_no_leak.sh`, отвечающий rc0; та же команда → rc 0 пробы только если `local_fake ZELENO`, у двери rc 1 `CHECK_NO_LEAK_KRASEN`; на хотфиксе #708 `local_fake KRASNO` (ложный допуск).
- Дано: установленный детектор отсутствует при чистом проекте без локального скрипта; когда та же команда `--repo`; тогда rc 0 пробы только если `missing_harness ZELENO`, у двери rc 2 с причиной отсутствия **установочного** детектора и stdout пуст. Дано: тот же опубликованный проект и снятый до удаления детектора снимок R, но в R дополнительно создан локальный `scripts/check_no_leak.sh` с `exit 0`; та же команда → rc 0 пробы только если `missing_harness_local_fake ZELENO`, у двери rc 2 с причиной отсутствия **установочного** детектора и stdout пуст. Честный контроль: `python3 fixtures/workshop_project/pre_judge_leak_185/probe.py --model` → rc 0; `--stabs` → rc 0, каждое отдельное предъявление `STAB ... caught`, ни одного `ZHIV`; привязка варианта к его входу живёт только в коде, включая fallback к локальному фейку на составном входе.
- Правило: `python3 fixtures/dver_pered_kritikom/predverie_172/red_predverie_172.py --repo` на хотфиксе #708 → rc 0, после исправления 185 → rc 1 **только** для устаревшей клетки `published`: её локальный fake без снимка больше не может служить честным контролем. Действительный published-вход с настоящим снимком и без локального fake покрыт `clean` в батарее 185; остальные режимы 172 остаются неизменными. Менять frozen-фикстуру 172 в зоне 185 нельзя: корректировка этой прежней клетки и её CI-приёмки требует отдельного owner-санкционированного 172 v+1 до done 185 (известный конфликт двух frozen/нового обязательств, не выдавать rc 1 за зелёный регресс). `bash scripts/pre_critic.sh contracts/185-pre-judge-proektnyj-rezhim.md` → rc 0 до критика; `bash scripts/check_provodka.sh . contracts/185-pre-judge-proektnyj-rezhim.md` → rc 0 перед done. Для дерева с `harness.project.json`: `bash scripts/check_project_sources.sh --repo . --contract contracts/185-pre-judge-proektnyj-rezhim.md --stage done` → rc 0.

## Незаполненные требования:
нет

## Зоны и проводка

ЗОНА architect: contracts/185-pre-judge-proektnyj-rezhim.md fixtures/workshop_project/pre_judge_leak_185/
ЗОНА implementer: scripts/pre_judge.sh
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_judge.sh — 172 только маршрут детектора внутри prepare; другие режимы и обещания frozen 172 сохраняются, кроме неконформной клетки `published` с локальным fake без снимка: её миграция требует отдельной санкции owner/172 v+1 до done 185, не правки frozen-зоны в этой пачке.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только шаг 185.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только строка 185.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только строка 185.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только строка 185.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только строка 185.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только строка 185.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только строка 185.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только строка 185.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только строка 185.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только строка 185.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только строка 185.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только строка 185.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только строка 185.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только строка 185.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только строка 185.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только строка 185.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только строка 185.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только строка 185.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 083 только замер 185.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер 185.
CI-проводку своего шага в `registry/ci-steps.tsv`/`registry/ci-zamery.tsv` и `.github/workflows/ci.yml` делает orchestrator через `gen_ci_steps.sh --write` и `--check` rc 0, чужие строки не меняются. Команда шага — `python3 fixtures/workshop_project/pre_judge_leak_185/probe.py --repo`; она совпадает с приёмкой.
ПРЕДПОСЫЛКИ:
- setting Существующий CI харнесса имеет bash, git и Python 3; пробы создают временные независимые Git-деревья, без новых secrets/variables/environments.

ПРОВОДКА:
- guard=scripts/pre_judge.sh
ПРОВОДКА-ЭНФОРСМЕНТ: изменён только выбор существующего детектора внутри существующей guard-двери prepare; новой нормы роли или устава нет.
