FAIL
OBJECT=704a67d726dc10eb9e4eaa1c980a6199adba2d47
СУД: репо=dev-harness; предмет=223; фаза=реализация; роль=adversary; вызов=1 (полный); сессия=Adv223; модель-факт=openai-codex/gpt-6.1-terra; автор Impl223 — minimax/MiniMax-M3.

Счёт задания: первый полный вызов, предшествующих вызовов adversary и арбитражей нет; соответствует §Счёт роли critic. Модель автора: `bash scripts/models_actual.sh --tsv --bind --session Impl223` → `implementer minimax/MiniMax-M3 allowed Impl223 -`, rc 0. Разные сессии; совпадение моделей само по себе не запрет. SourceCanon и архитектура 188 для этого предмета не объявлены.

Ограничение процесса: на момент запроса `gh run list --repo a3ka/dev-harness --commit 704a67d726dc10eb9e4eaa1c980a6199adba2d47 --limit 10 --json status,conclusion,name,databaseId` вернул rc 0, `[{"conclusion":"","databaseId":45811928943,"name":"ci","status":"in_progress"}]`. Обязательный для рисковой реализации предшествующий зелёный CI на OBJECT этим наблюдением не установлен; данный FAIL не удостоверяет завершение судейского порядка.

## Блоки

БЛОКИРУЕТ `contracts/223-arch-ci-review.md:173`, `registry/ci-steps.tsv:341` — в обязательном собственном CI-шаге 223 отсутствует `--sintaksis`.
ПРОИСХОЖДЕНИЕ: дельта orchestrator на OBJECT.
КЛАСС: К-04.
ОБЯЗАТЕЛЬСТВО: после реализации тот же шаг содержит `--model`, `--stabs`, `--sintaksis` и `--repo .`; пинованный shellcheck доступен.
СОСТОЯНИЕ: настоящая строка реестра запускает `--repo . && --model && --stabs && --catalog`, но не `--sintaksis`; `.github/workflows/ci.yml` выполняет её через `scripts/run_ci_lane.sh`.
НАБЛЮДЕНИЕ: в одноразовом клоне добавлена в конец model/done_contract.sh корректная для bash недостижимая строка `if false; then echo $adv223_unquoted; fi`, хеш носителя в source.json обновлён. Выполнены по отдельности четыре команды реальной строки CI и обязательный пропущенный режим:
```
CI_SHELLCHECK repo rc 0
KLETKI 47 KRASNYH 0
CI_SHELLCHECK model rc 0
KLETKI 47 KRASNYH 0
CI_SHELLCHECK stabs rc 0
ZHIVYH 0 SVJAZI 43
CI_SHELLCHECK catalog rc 0
KLETKI 47 STABY 12 EKVIVALENTY 4 SVJAZI 43
CI_SHELLCHECK sintaksis rc 2
NOT_IMPLEMENTED: ARCH223: COMMAND ['bash', '<clone>/scripts/validate_std.sh', 'bash', '<clone>/fixtures/workshop_project/arch_ci_review_223/model/done_contract.sh']: b''
```
ОБХОД: CI-строка остаётся зелёной без обязательной проверки стандартного shellcheck; намеренно добавленный недостижимый фрагмент — демонстрация отличия проверок, не утверждение о дефекте честной модели. Контроль с невалидным bash, напротив, пойман `--model` и `--stabs` rc 2: ложного обхода синтаксиса bash не заявляю. Закрывающее свойство: CI реально исполняет весь названный контрактом набор с пинованным shellcheck.

БЛОКИРУЕТ `contracts/223-arch-ci-review.md:52-53`, `fixtures/workshop_project/arch_ci_review_223/context.py` — обязательная сдача красна после появления собственного frozen-тега.
ПРОИСХОЖДЕНИЕ: пропущен ранее; существует на базе 1702766a3, не вызван правкой implementer.
КЛАСС: К-01.
ОБЯЗАТЕЛЬСТВО: context.py, check_sdacha --run и pre_critic возвращают rc 0, полный frozen-census и объявления присутствуют.
СОСТОЯНИЕ: на OBJECT доступен frozen/contracts/223/1; census требует собственное пересечение implementer для scripts/done_contract.sh, которого в frozen-контракте нет. В задании и измерении implementer указано то же состояние на базе.
НАБЛЮДЕНИЕ: `python3 -B fixtures/workshop_project/arch_ci_review_223/context.py` → rc 1 `RuntimeError: CONTRACT_OVERLAPS_INCOMPLETE`. После повторного fetch тегов (за время суда на origin появился frozen/contracts/228/1) и отдельного повтора precision → rc 0 `OK`, но:
```
check_sdacha.sh . contracts/223-arch-ci-review.md --run: rc 1
ОТКАЗ: строка 18: фактический rc=1 ≠ заявленного 0: fixtures/workshop_project/arch_ci_review_223/context.py
pre_critic.sh contracts/223-arch-ci-review.md: rc 1
ОТКАЗ: сдаточный лист красен (rc=1): ОТКАЗ: строка 18: фактический rc=1 ≠ заявленного 0: fixtures/workshop_project/arch_ci_review_223/context.py
```
Это не дефект изменения scripts/done_contract.sh и не доказательство ложного done. Это невыполненное явное условие сдачи, а не объявленный в НЕ ЗАЩИЩАЕТ остаток. Закрывающее свойство: census и frozen-объявления согласованы и все три команды проходят при наличии собственного тега; зона architect/нормативный круг, не implementer.

## Карта классов
К-01: блок — красная обязательная сдача и context.py после собственного frozen.
К-02: чисто — вход: задание, контракт 223, SDACHA; sourceCanon не объявлен.
К-03: чисто — 187 rc 0 CELLS=111; 201 rc 0 CELLS=62; 224 rc 0 100/0.
К-04: блок — CI-шаг не запускает обязательный --sintaksis.
К-05: чисто — вход: команды и rc заданы в приёмке; фактические расхождения отмечены блоками.
К-06: чисто — exit 1 и 127 носителя и отсутствие git дали батарее rc 2, не ложную поимку.
К-07: чисто — --repo . и --model rc 0, каждый KLETKI 47 KRASNYH 0.
К-08: чисто — основные предикаты пойманы; три искусственных специальных расширения остаются зелёными и приведены как совет ниже, с пределом §Порог.
К-09: чисто — входы rename, удаление, mode, symlink, type-change, пустота, octopus и смешанные дельты в 47 зелёных клетках.
К-10: чисто — вход: probe.py проверяет rc, SHA-запрос, диагностику, annotated tag и HEAD; воспроизведены красные мутанты.
К-11: чисто — вход: probe.py, CASES и SHA вне мира субъекта, реальный Git.
К-12: чисто — --sintaksis rc 0, SINTAKSIS 17 SHELLCHECK 2; сбор Git-дельты с -z и --no-renames.
К-13: н/п — новых секретных входов 223 не вводит.
К-14: чисто — --stabs rc 0, 43 связи, честные эквиваленты зелены.
К-15: чисто — --catalog rc 0: 47 клеток, 12 стабов, 4 эквивалента, 43 связи.
К-16: чисто — риск авторизации и исключения доверенной среды названы; проверены отдельные отрицательные миры и отсутствие инструмента.
К-17: н/п — станционный механизм, продуктовая архитектурная модель 188 не объявлена.

## Мутации и контроли

Все изменения выполнялись по одной в клоне origin на OBJECT; после каждого теста исходный носитель восстановлен. `B` — `bash fixtures/workshop_project/arch_ci_review_223/red_arch_ci_review_223.sh`. Честный `B --repo .`: rc 0 `KLETKI 47 KRASNYH 0`; `B --model`: rc 0 `KLETKI 47 KRASNYH 0`; `B --stabs`: rc 0 `ZHIVYH 0 SVJAZI 43`.

СОВЕТ `scripts/done_contract.sh:295-298`, К-08: три соседних специальных расширения функции, которых нет в stabs.tsv, прошли всю батарею `B --repo .`:
```
.harness/*|.review/*|.review.bak/*    rc 0 KLETKI 47 KRASNYH 0
.harness/*|.review/*|.Review/*        rc 0 KLETKI 47 KRASNYH 0
.harness/*|.review/*|other/.review/*  rc 0 KLETKI 47 KRASNYH 0
```
Дополнительные настоящие Git-миры `.review.bak/x`, `.Review/x`, `other/.review/x` с success только на продуктовом предке: каждый честный носитель `GREEN rc=1`; каждый соответствующий мутант `RED RC,QUERY_SHA,SHA_DIAGNOSIS,TAG_ON_REFUSAL rc=0`. Эти имена доступны через обычное добавление Git-файлов. Ошибочные механизмы здесь специально вставлены, а не показаны как замена существующей предметной операции; по общему §Порог зелёные специально внесённые исключения сами по себе не доказывают дефект честной production. Рекомендуется добавить данные парные входы, не приписывая им самостоятельную блокирующую силу.

Ещё четыре новых отдельных изменения, отсутствующих в stabs.tsv, и сырой итог `B --repo .`:
```
.review/[a-z]* вместо .review/*: rc 1 KLETKI 47 KRASNYH 3
.review/*.md вместо .review/*: rc 1 KLETKI 47 KRASNYH 1 (review-symlink)
[ "$_a187_only" -ge 1 ] вместо -ne 1: rc 1 KLETKI 47 KRASNYH 42
_a187_only=2 вместо 1: rc 1 KLETKI 47 KRASNYH 25
```
Дополнительные отдельные контрольные мутации: удаление `-z` → rc 1, 25 красных; `--find-renames` вместо `--no-renames` → rc 1, `product-rename-in RED ... TAG_ON_REFUSAL rc=0`, одна красная; удаление проверки пустоты → rc 1, две красных empty-first; удаление .harness → rc 1, четыре красных; все пути служебные → rc 1, 42 красных. Последние три предметные операции также представлены в авторском реестре, поэтому не выдаются за новые семь.

Дверь действительно использует `git diff --no-renames --ignore-submodules=none --name-only -z` и `read -r -d ''` (`scripts/done_contract.sh:542-547`): `B` зелёная на newline, пробеле, Unicode, rename в обе стороны, удалении, mode, symlink, type-change, review-only цепочке 177, failure/skipped/missing и пустой дельте/octopus. Дополнительный однобайтовый Git-путь с переводом строки `.review/x\nscripts/y` и путь с кавычкой вернули ожидаемый service rc 0; это один Git-путь, не два пути. `./` и `..` как компоненты не являются реальными Git-путями; normalized-escape в батарее rc 1. Предел 50/root охвачен 187: rc 0 CELLS=111 FAILURES=0.

Отказ как успех: полный носитель `exit 1` → батарея rc 2 `NOT_IMPLEMENTED: ARCH223: UNRELATED_REFUSAL review-merge b''`; `exit 127` → rc 2 `SUBJECT_ENVIRONMENT`. При PATH с bash/python/dirname, но без git: rc 2 `NOT_IMPLEMENTED: ARCH223: [Errno 2] No such file or directory: 'git'`. Пустота: empty-first отдельно различает неверный выбор родителя при success на p1 и при success на HEAD; octopus отказывает до API. Чужой вопрос: rename source/destination и first-vs-second parent пойманы; отдельная мутация обнаруживает неверную обработку p1. Нейтрализация .harness красит свой harness-merge и связанные четыре клетки, а не всю батарею.

## Регрессы и среда

Область `git diff --name-status 1702766a3b3c32e4f06c948e0f7aeabd00297f45 OBJECT`: только `.github/workflows/ci.yml`, `registry/ci-steps.tsv`, `registry/ci-zamery.tsv`, `scripts/done_contract.sh`; diff contracts и fixtures 223 пуст. `B --sintaksis` rc 0 `SINTAKSIS 17 SHELLCHECK 2`; `B --catalog` rc 0 `KLETKI 47 STABY 12 EKVIVALENTY 4 SVJAZI 43`; `gen_ci_steps.sh --check` rc 0; `check_precision_gate.sh <absolute clone> contracts/223-arch-ci-review.md` rc 0, после обновления тегов команда с `.` также rc 0 `OK`.

Регрессы в origin-клоне: 224 rc 0 `KLETKI 100 KRASNYH 0`; 187 rc 0 `CELLS=111 STABS=0 FAILURES=0`; 201 rc 0 `CELLS=62 STABS=0 FAILURES=0`; 205 rc 0 `KLETKI=24 ZELENYE=24 KRASNYE=0`; 992 rc 0 `cases=25 observations=25 failures=0`; 996 rc 0 `examined=111 mutants=0 mismatches=0`; 038 и C6 rc 0. 116/195 после обновления тегов rc 1: `195: честных клеток 14, зелёных 13, красных: k187a-okno-187-s-probami-r0`, причина `потребители 116: замер маппинга отсутствует (контракт правит писателя scripts/done_contract.sh)`. Сравнительный запуск этой клетки на базе в данном суде не выполнялся; регрессией OBJECT это не объявляется. Первый прогон pre_critic/116 столкнулся с `missing-remote` из-за появившегося во время суда тега 228; после fetch и отдельных повторов причина уточнена выше.

## НЕ ЗАЩИЩАЕТ

ОСТАТОК: К-16 — не укусил: `PATH semantic-product-in-service GREEN rc=0` на `.review/product.js`; классификация по имени внутри служебного каталога намеренная, содержательный продукт там вне обещания, независимые ловцы и владельцы каталога названы контрактом.
ОСТАТОК: К-13 — не укусил: отсутствие git в PATH даёт NOT_IMPLEMENTED rc 2, а согласованная подмена Git/PATH/UID/API исключена моделью угроз; ложный API вне границы не выдан за блок.
ОСТАТОК: К-03 — не укусил: независимые done-ноги не заменены 223; перечисленные регрессы исполнены, 116/195 с названным ограничением сравнения. Строки НЕ ЗАЩИЩАЕТ контракта не содержат собственных номеров К-NN; номера здесь отражают общий каталог классов.
