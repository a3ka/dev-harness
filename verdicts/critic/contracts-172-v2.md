accept
OBJECT=18546455041fc0c8d74b7fc1c35fa23759baab60
СУД: repo=dev-harness; предмет=172; фаза=контракт v2 (v+1 по слову владельца 2026-11-10 ~18:27 UTC «6. да»); роль=critic; вызов=1/2; модель-план=zai/glm-5.3; сессия=Crit172v2; модель-факт=zai/glm-5.3; SHA=18546455041fc0c8d74b7fc1c35fa23759baab60; предыдущий=verdicts/critic/contracts-172-v1.md (accept v1; для v2 суд новый); исключение=нет

# Вердикт критика — контракт 172 v2 «преддверие судейской проводки»

## Учёт, независимость и законность v+1

Кандидат закоммичен: после `git fetch origin wip/172/architect` выполнены `git checkout --detach 18546455041fc0c8d74b7fc1c35fa23759baab60` и `git rev-parse HEAD`; вывод последней команды — ровно `18546455041fc0c8d74b7fc1c35fa23759baab60`. Автор изменяющего коммита — `architect <architect@dev-harness.local>`, судья — отдельная сессия `Crit172v2`, собственную работу не судит.

До вызова строка СУД уже была в `origin/main:HANDOFF.md:3`: вызов `1/2`, тот же OBJECT, план `zai/glm-5.3`, `сессия=ожидается`. Фактическая модель взята из выданного пакета задания: `TRACE role=critic model=zai/glm-5.3`. Назначение роли в `config/agent_models.json:59-63,94` — `apex-sol` → `@glm` → `zai/glm-5.3`; совпадение модели с автором не образует отказ по контракту 166.

Авторизация в теле изменяющего текст коммита дословно совпала с данным заданием:

```
РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/172-predverie-sudejskoj-provodki.md — v2: тесты 172 кладут детектор утечки в установку харнесса, а не в проверяемый корень R (маршрут 185: только детектор установки); семантика 172 не ослабляется; слово владельца 2026-11-10 ~18:27 UTC «6. да» через консультанта
```

`bash scripts/check_charter.sh .` → rc 0. Релевантная сырая строка вывода:

```
  ok   уставной документ изменён с разрешения владельца: contracts/172-predverie-sudejskoj-provodki.md в 18546455
```

## Полнота предмета, границы и шестой вопрос

Предмет и проверяемая приёмка есть в `contracts/172-predverie-sudejskoj-provodki.md:13-32`; исполнители и границы названы в `:39-44`. Четыре пути дельты — сам контракт и три файла `fixtures/dver_pered_kritikom/predverie_172/` — полностью лежат в `ЗОНА architect` на `:39`. Полный `check_zones.sh` намеренно не запускался по прямому ограничению задания; вместо него проведена сверка только этой дельты с объявленной зоной.

`КЛАСС РИСКА: обычный` на `:4` соответствует предмету: меняется подготовка Git/станции и фикстура, а не права, авторизация, деньги, ПД/health или юридически значимое действие. Условия для adversary по классу риска не возникают.

`bash scripts/check_threat_model.sh . contracts/172-predverie-sudejskoj-provodki.md` → rc 0, сырой вывод:

```
модель угроз: секция отсутствует (вне применимости барьера; присутствие — cognitive-only критика)
```

Это не скрывает гард для чужого ввода: как уже установлено принятым v1, поддерживаемые входы здесь приходят от ролей станции; v2 меняет только место установки тестовой внешней зависимости, а не класс входа или границу обязательств. Поэтому норма 041 не срабатывает.

Шестой вопрос архитектуры проверен по `docs/owner/2026-11-10-plan-i-pravila-arhitektury.md:81-94`. v2 не вводит продуктовый модуль, операцию модели, миграцию или зависимость: это узкая правка тестовой установки `pre_judge` в самом харнесе. Она не противоречит контрактам модулей и не требует проверки DRAFT-операции; предмет 187 ещё должен механизировать общую строку `АРХИТЕКТУРА:` для новых кодовых контрактов. У v2 нет архитектурного расхождения.

## Дельта v1 → v2 и неизменность семантики

Предъявленный diff `frozen/contracts/172/1..OBJECT` затрагивает ровно четыре файла: контракт (+4/−0), `red_predverie_172.py` (+22/−8), новый `red_predverie_172.sh` (+10/−0), `reference.py` (+3/−2), итого +39/−10. На `contracts/172-predverie-sudejskoj-provodki.md:21-23` записано ровно новое свойство: детектор устанавливается возле исполняемой двери харнесса вне R, флаг остаётся в R и передаётся как `--check R`.

Ни имена, ни оракулы 16 прежних клеток не ослаблены. Дифф с нулевым контекстом не затрагивает блок `CASES` (`red_predverie_172.py:131-148`), а независимые SHA-256 извлечённого блока v1 и v2 совпали:

```
9ecf7fb4e5898d78188848658d97f0dcdffee2f344ce0da2d83e333c08c3f155  -
9ecf7fb4e5898d78188848658d97f0dcdffee2f344ce0da2d83e333c08c3f155  -
```

На v1 `--model` предъявил те же 16 имён, а `--stabs` — 12 ловушек. На v2 `--model` снова предъявляет все 16, а `--stabs` — 14: прежние 12 плюс `prefer_local` и `ignore_leak_rc`. Отсутствие вызова уже покрыто прежним `ignore_leak`; новая локальная ложная дверь создаётся только на входе `leak_reject` (`red_predverie_172.py:166-173,213-219`). Контрольная модель выбирает установленный детектор и передаёт ему R (`reference.py:50-54`), поэтому подмена локальным детектором и игнорирование его красного rc расходятся на живом входе.

### Собственная мутация критика

Мутация выполнена только в одноразовом клоне и затем восстановлена. В `fixtures/dver_pered_kritikom/predverie_172/reference.py:52` аргумент уже существующей операции детектора был заменён с `--check str(root)` на `--check str(state)`: внешний детектор остаётся честным, но проверяет не поддерживаемый корень R. Это смежный путь ошибки «верный механизм, неверный корень». Команда и сырой вывод:

```text
$ python3 fixtures/dver_pered_kritikom/predverie_172/red_predverie_172.py --model
published ok (rc=0)
prepare_no_state ok (rc=1)
missing_origin ok (rc=1)
stale_origin ok (rc=1)
state_inside ok (rc=1)
manifest_wait ok (rc=1)
leak_reject KRASNO (rc=0)
ff_sync ok (rc=0)
nonff_sync ok (rc=1)
judge_verdict ok (rc=0)
verdict_no_file ok (rc=1)
nonjudge_verdict ok (rc=1)
staged_main_verdict ok (rc=1)
committed_main_verdict ok (rc=1)
archive_free ok (rc=0)
archive_attached ok (rc=1)

[exit=1]
```

После этого выполнены `git checkout -- fixtures/dver_pered_kritikom/predverie_172/reference.py`, `git diff --exit-code -- fixtures/dver_pered_kritikom/predverie_172/reference.py` и `git status --short`; все дали пустой вывод и rc 0. Контрольный `--model` после восстановления снова дал 16/16 `ok`.

## Обязательные прогоны

```text
$ bash scripts/pre_critic.sh contracts/172-predverie-sudejskoj-provodki.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=1
КРИТИК: дверь зелёная

[exit=0]

$ bash scripts/pre_critic.sh --repo . contracts/172-predverie-sudejskoj-provodki.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=1
КРИТИК: дверь зелёная

[exit=0]

$ bash scripts/check_threat_model.sh . contracts/172-predverie-sudejskoj-provodki.md
модель угроз: секция отсутствует (вне применимости барьера; присутствие — cognitive-only критика)

[exit=0]

$ bash scripts/check_provodka.sh . contracts/172-predverie-sudejskoj-provodki.md

[exit=0]

$ bash scripts/check_precision_gate.sh . contracts/172-predverie-sudejskoj-provodki.md
OK

[exit=0]

$ bash scripts/check_project_sources.sh --repo . --contract contracts/172-predverie-sudejskoj-provodki.md --stage done

[exit=0]
```

Полная обёртка v2 — `bash fixtures/dver_pered_kritikom/predverie_172/red_predverie_172.sh` — завершилась rc 0. Сырой вывод:

```text
published ok (rc=0)
prepare_no_state ok (rc=1)
missing_origin ok (rc=1)
stale_origin ok (rc=1)
state_inside ok (rc=1)
manifest_wait ok (rc=1)
leak_reject ok (rc=1)
ff_sync ok (rc=0)
nonff_sync ok (rc=1)
judge_verdict ok (rc=0)
verdict_no_file ok (rc=1)
nonjudge_verdict ok (rc=1)
staged_main_verdict ok (rc=1)
committed_main_verdict ok (rc=1)
archive_free ok (rc=0)
archive_attached ok (rc=1)
published ok (rc=0)
prepare_no_state ok (rc=1)
missing_origin ok (rc=1)
stale_origin ok (rc=1)
state_inside ok (rc=1)
manifest_wait ok (rc=1)
leak_reject ok (rc=1)
ff_sync ok (rc=0)
nonff_sync ok (rc=1)
judge_verdict ok (rc=0)
verdict_no_file ok (rc=1)
nonjudge_verdict ok (rc=1)
staged_main_verdict ok (rc=1)
committed_main_verdict ok (rc=1)
archive_free ok (rc=0)
archive_attached ok (rc=1)
STAB stale_origin caught on stale_origin
STAB allow_incomplete_prepare caught on prepare_no_state
STAB state_inside caught on state_inside
STAB ignore_manifest caught on manifest_wait
STAB ignore_leak caught on leak_reject
STAB allow_nonff caught on nonff_sync
STAB ref_only_ff caught on ff_sync
STAB allow_main_verdict caught on staged_main_verdict
STAB allow_main_verdict caught on committed_main_verdict
STAB allow_incomplete_verdict caught on verdict_no_file
STAB allow_nonjudge_verdict caught on nonjudge_verdict
STAB allow_archive_worktree caught on archive_attached
STAB prefer_local caught on leak_reject with local fake
STAB ignore_leak_rc caught on leak_reject with local fake

[exit=0]
```

Отдельный повтор `python3 fixtures/dver_pered_kritikom/predverie_172/red_predverie_172.py --stabs` после восстановления также дал rc 0 и те же 14 строк `STAB … caught`, без `ZHIV`.

Для сравнения на отдельном worktree `frozen/contracts/172/1`:

```text
$ python3 fixtures/dver_pered_kritikom/predverie_172/red_predverie_172.py --stabs
STAB stale_origin caught on stale_origin
STAB allow_incomplete_prepare caught on prepare_no_state
STAB state_inside caught on state_inside
STAB ignore_manifest caught on manifest_wait
STAB ignore_leak caught on leak_reject
STAB allow_nonff caught on nonff_sync
STAB ref_only_ff caught on ff_sync
STAB allow_main_verdict caught on staged_main_verdict
STAB allow_main_verdict caught on committed_main_verdict
STAB allow_incomplete_verdict caught on verdict_no_file
STAB allow_nonjudge_verdict caught on nonjudge_verdict
STAB allow_archive_worktree caught on archive_attached

[exit=0]
```

Его `--model` также дал 16/16 `ok`; временный worktree после сравнения удалён.

## Совместимость с 185

Побайтная проверка `git diff --exit-code OBJECT origin/main -- fixtures/dver_pered_kritikom/predverie_172` дала rc 0 и вывод:

```text
v2-fixture-identical-on-main
```

На дереве `origin/main` с этой v2-фикстурой `python3 fixtures/workshop_project/pre_judge_leak_185/probe.py --model` дал rc 0:

```text
185 clean ZELENO rc=0 stdout='OBJECT=f376125b37c59ae3485e82c4f348105679540a31\nSOSTOJANIE=/tmp/pre-judge-185-u45h3u8t/state\n' stderr=''
185 dirty ZELENO rc=1 stdout='' stderr='ОТКАЗ: основной чекаут загрязнён: tracked.txt\nОТКАЗ: CHECK_NO_LEAK_KRASEN\nscripts/check_no_leak.sh --check /tmp/pre-judge-185-37trlh8o/project вернул rc=1\n'
185 local_fake ZELENO rc=1 stdout='' stderr='ОТКАЗ: основной чекаут загрязнён: tracked.txt, scripts/check_no_leak.sh\nОТКАЗ: CHECK_NO_LEAK_KRASEN\nscripts/check_no_leak.sh --check /tmp/pre-judge-185-1ctc5ejm/project вернул rc=1\n'
185 missing_harness ZELENO rc=2 stdout='' stderr='NOT_IMPLEMENTED: нет детектора утечки харнесса: scripts/check_no_leak.sh\n'
185 missing_harness_local_fake ZELENO rc=2 stdout='' stderr='NOT_IMPLEMENTED: нет детектора утечки харнесса: scripts/check_no_leak.sh\n'
```

На отдельном worktree `525e1a2e923e70277a7c39565545fb68ade6e1ea` в него временно положена v2-фикстура (SHA `370569c1edc456a2f22fb93c5577202c38b98c38`), после чего та же модель 185 также завершилась rc 0:

```text
185 clean ZELENO rc=0 stdout='OBJECT=f376125b37c59ae3485e82c4f348105679540a31\nSOSTOJANIE=/tmp/pre-judge-185-7sps5icp/state\n' stderr=''
185 dirty ZELENO rc=1 stdout='' stderr='ОТКАЗ: основной чекаут загрязнён: tracked.txt\nОТКАЗ: CHECK_NO_LEAK_KRASEN\nscripts/check_no_leak.sh --check /tmp/pre-judge-185-_k2dyi6u/project вернул rc=1\n'
185 local_fake ZELENO rc=1 stdout='' stderr='ОТКАЗ: основной чекаут загрязнён: tracked.txt, scripts/check_no_leak.sh\nОТКАЗ: CHECK_NO_LEAK_KRASEN\nscripts/check_no_leak.sh --check /tmp/pre-judge-185-xfpezit8/project вернул rc=1\n'
185 missing_harness ZELENO rc=2 stdout='' stderr='NOT_IMPLEMENTED: нет детектора утечки харнесса: scripts/check_no_leak.sh\n'
185 missing_harness_local_fake ZELENO rc=2 stdout='' stderr='NOT_IMPLEMENTED: нет детектора утечки харнесса: scripts/check_no_leak.sh\n'
```

На обоих деревьях `python3 fixtures/dver_pered_kritikom/predverie_172/red_predverie_172.py --repo` дал rc 0 и одинаковые 16 зелёных клеток; в частности требуемая `published`:

```text
published ok (rc=0)
prepare_no_state ok (rc=1)
missing_origin ok (rc=1)
stale_origin ok (rc=1)
state_inside ok (rc=1)
manifest_wait ok (rc=1)
leak_reject ok (rc=1)
ff_sync ok (rc=0)
nonff_sync ok (rc=1)
judge_verdict ok (rc=0)
verdict_no_file ok (rc=1)
nonjudge_verdict ok (rc=1)
staged_main_verdict ok (rc=1)
committed_main_verdict ok (rc=1)
archive_free ok (rc=0)
archive_attached ok (rc=1)
```

Временные worktree `main-v2`, `impl185` и `v1` удалены после прогонов.

## Итог

Блокирующих находок нет. Вызов 1/2 принимает именно OBJECT выше: внешняя тестовая зависимость вынесена из R, все 16 прежних клеток и их оракулы сохранены, 12 прежних стабов не исчезли, два новых обхода пойманы, а дополнительная мутация критика на неверный корень краснит единственно релевантную клетку. `accept` разрешает freeze 172/2.
