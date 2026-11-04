FAIL
OBJECT=92a50b123f07a04eeb40126b847c4a31eac09901
СУД: repo=dev-harness; предмет=154; фаза=контракт (+красная батарея/спецификация); роль=critic; вызов=5/5; модель-план=openai-codex/gpt-6-sol; сессия=Crit154e; модель-факт=openai-codex/gpt-6-sol; SHA=92a50b123f07a04eeb40126b847c4a31eac09901; предыдущий=FAIL (contracts-154-v1d-fail.md, Б8); исключение=нет; автор — Arch154f (GLM zai/glm-5.3): независимость есть.

`git cat-file -t OBJECT` → `commit`. Судимое дерево извлечено `git archive OBJECT` в отдельный каталог; Git-история и refs добавлены только в этом каталоге. Вызовы 1–4 сверены с HANDOFF и `contracts-154-v1-fail.md`, `contracts-154-v1b-fail.md`, `contracts-154-v1c-fail.md`, `contracts-154-v1d-fail.md`. Дельта OBJECT — только контракт 154 и `probe.py`/`probe.sh` семьи 154. КЛАСС РИСКА «рисковый — деньги», предмет, rc-критерии, исполнители/ЗОНА, ПРОВОДКА, раздел модели угроз с обоими списками и «Незаполненные требования: нет» имеются; сопоставлены с frozen/contracts/140/1. Самоописательные числа не являются блокерами (слово владельца 03.11).

## БЛОКИРУЕТ

**Б8, повтор — текущие выданные номера не исчерпывают допустимых новых номеров. БЛОКИРУЕТ contracts/154-schet-vyzovov-kritika.md:35, :39, :44, :49, :186; fixtures/workshop_project/schet_vyzovov_154/probe.py:747–765, :777, :833–863.**
ОБЯЗАТЕЛЬСТВО: И-1, И-2, И-5, ЗАЩИЩАЕТ :186: одинаковый кап на двери и freeze для ЛЮБОГО нового номера, в том числе БЕЗ тега (строгий дефолт). Класс причины — режим `--subjects` проверяет только снимок текущих `id/CONTRACT/*` (167), хотя грамматика допускает другие трёхзначные номера. Утверждение :49 «любое конечное зашитое подмножество» ошибочно для подмножества всех существующих тегов, исключающего будущий номер.
СОСТОЯНИЕ: тег `id/CONTRACT/160` отсутствует (команда `git tag -l 'id/CONTRACT/160'` вернула пусто), но toy с `contracts/160-x.md`, accept, origin, веткой и 5/6 START конформен; по И-5 160 — НОВЫЙ. В отдельном архиве в поставленные скрипты вставлена честная модель (`probe.prepare_scripts(...,'model')`), затем только вызов бюджета на двери обрамлён `[ "$sv" != 160 ]`, на freeze — `[ "$NNN" != 160 ]`. Остальная механика, ledger и теги неизменны.
ОБХОД: W и `W --subjects` по всем текущим тегам зелёны, но шестой START предмета 160 записывается и после шести START freeze создаёт тег/реестр. Вне объявленной границы угроз это не находится.
НАБЛЮДЕНИЕ (дословные выполненные команды и сырые результаты; все из корня одноразового `ins`; фильтр выводит негриновые строки и число GREEN, `pipefail` сохраняет rc):
```
$ python3 /tmp/dev-harness-verify/Crit154e/witness154.py negative
HONEST_INSERTION=installed
NEGATIVE_WITNESS=subject 160 excluded on both checks; 160 not in tagged domain
[exit=0]
$ bash -o pipefail -c 'bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh | python3 -c "import sys; x=sys.stdin.read().splitlines(); print(chr(10).join(s for s in x if not s.startswith(\"GREEN \") )); print(\"GREEN_ROWS=\",sum(s.startswith(\"GREEN \") for s in x))"'
CELLS=51 GREEN=51
GREEN_ROWS= 51
[exit=0]
$ bash -o pipefail -c 'bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --subjects | python3 -c "import sys; x=sys.stdin.read().splitlines(); print(chr(10).join(s for s in x if not s.startswith(\"GREEN \") )); print(\"GREEN_ROWS=\",sum(s.startswith(\"GREEN \") for s in x))"'
SUBJECTS=167 CELLS=334 GREEN=334
GREEN_ROWS= 334
[exit=0]
$ PYTHONPATH=fixtures/workshop_project/schet_vyzovov_154 python3 -c "import probe; print(probe.scenario('future160-door-sixth',5,'spawn',subject='160')); print(probe.scenario('future160-freeze-six',6,'freeze',subject='160'))"
future160-door-sixth: expected KAP_VYZOVOV_KRITIKA, actual rc 0:
future160-freeze-six: expected KAP_VYZOVOV_KRITIKA, actual rc 0: OK secrets=0 variables=0 environments=0 settings=0
  ok   заморожено: contracts/160-x.md → frozen/contracts/160/1 («criterion accepted»)
  ok   реестр закоммичен: 160 → 9ecfa19e7496f6f1e2a4aa95ba9977d34f419226
  ok   реестр записан: 160 → 9ecfa19e7496f6f1e2a4aa95ba9977d34f419226
[exit=0]
$ PYTHONPATH=fixtures/workshop_project/schet_vyzovov_154 python3 -c "import probe; print('honest door:',probe.scenario('future160-door-sixth',5,'spawn',mode='model',subject='160') or 'GREEN'); print('honest freeze:',probe.scenario('future160-freeze-six',6,'freeze',mode='model',subject='160') or 'GREEN')"
honest door: GREEN
honest freeze: GREEN
[exit=0]
```
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: приёмка отказывает в шестом START и freeze для произвольного допустимого нового номера, включая номер, которого нет среди тегов на момент запуска теста; честная вставка остаётся зелёной. Очередной фиксированный список свидетелей не закрывает класс.

**Б9 — `--subjects` проверяет тег, но не реестр после отклонённой заморозки. БЛОКИРУЕТ contracts/154-schet-vyzovov-kritika.md:36, :43–44, :49; fixtures/workshop_project/schet_vyzovov_154/probe.py:852–859.**
ОБЯЗАТЕЛЬСТВО: И-2 требует отказа `KAP_VYZOVOV_KRITIKA` ДО записи и тега, и реестра. Класс причины: новая freeze-клетка каждого предмета проверяет rc, stderr и отсутствие тега, но не снимок `registry/contracts.tsv`. Старая одиночная клетка `scenario` сверяет реестр, но номера её фиксированы.
СОСТОЯНИЕ: предмет 154 присутствует в домене `--subjects`, новый (`git merge-base --is-ancestor id/CONTRACT/154 5ca237e4e` → rc 1). После честной вставки только для `$NNN=154` перед штатным бюджетом записана строка в `$ROOT/registry/contracts.tsv` (`mkdir -p` и `printf '154\twrong-side-effect\n'`); бюджет затем честно отказывает KAP, тег не создаёт. Ни журнал, ни оракул не менялись.
ОБХОД: W, `W --domain`, `W --live`, `W --subjects` зелёны, включая `subjects-154-freeze`, но отказ изменил реестр. Прямой сценарий 154 замечает побочный эффект; честная модель зелена.
НАБЛЮДЕНИЕ (дословные выполненные команды и результаты в `ins`; фильтр тот же, что выше):
```
$ python3 /tmp/dev-harness-verify/Crit154e/witness154.py && python3 /tmp/dev-harness-verify/Crit154e/witness_registry154.py
HONEST_INSERTION=installed
NEGATIVE_WITNESS=registry changed before KAP on tagged subject 154
[exit=0]
$ PYTHONPATH=fixtures/workshop_project/schet_vyzovov_154 python3 -c "import probe; print(probe.scenario('tagged154-freeze-side-effect',6,'freeze',subject='154'))"
tagged154-freeze-side-effect: declined freeze changed frozen tag or registry
[exit=0]
$ PYTHONPATH=fixtures/workshop_project/schet_vyzovov_154 python3 -c "import probe; print('honest freeze154:',probe.scenario('tagged154-freeze-side-effect',6,'freeze',subject='154',mode='model') or 'GREEN')"
honest freeze154: GREEN
[exit=0]
$ bash -o pipefail -c 'bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --domain | python3 -c "import sys; x=sys.stdin.read().splitlines(); print(chr(10).join(s for s in x if not s.startswith(\"GREEN \") )); print(\"GREEN_ROWS=\",sum(s.startswith(\"GREEN \") for s in x))"'
CELLS=210 GREEN=210
GREEN_ROWS= 210
[exit=0]
$ bash -o pipefail -c 'bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --subjects | python3 -c "import sys; x=sys.stdin.read().splitlines(); print(chr(10).join(s for s in x if not s.startswith(\"GREEN \") )); print(\"GREEN_ROWS=\",sum(s.startswith(\"GREEN \") for s in x))"'
SUBJECTS=167 CELLS=334 GREEN=334
GREEN_ROWS= 334
[exit=0]
```
На том же варианте W без флагов rc 0 `CELLS=51 GREEN=51`, W --live rc 0 `CELLS=9 GREEN=9` (девять именованных GREEN в фактическом выводе). ЗАКРЫВАЮЩЕЕ СВОЙСТВО: при отказе каждого номера домена проверяется неизменность реестра, не только отсутствие тега; данная условная запись 154 краснит свою клетку при зелёной честной модели.

**В1 — обязательный зелёный gate не предъявлен на OBJECT. БЛОКИРУЕТ contracts/154-schet-vyzovov-kritika.md:52.**
ОБЯЗАТЕЛЬСТВО: п.6 требует `bash scripts/check_ceilings.sh` rc 0 до заморозки. Класс причины: в базе после rebase чужой незавершённый контракт 125 без обязательного раздела. СОСТОЯНИЕ: зафиксированное дерево OBJECT без правок 125. НАБЛЮДЕНИЕ:
```
$ bash scripts/check_ceilings.sh
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  FAIL контракт /tmp/dev-harness-verify/Crit154e/repo/contracts/125-sessii-proektov.md (46167 байт): нет раздела «Незаполненные требования:»
  ok   раздел требований: 148 черновик(ов) судится, замороженные — по тегам
превышений/нарушений: 1
[exit=1]
```
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: названная команда rc 0 на предъявленном дереве; 125 принадлежит своему законному маршруту, не зоне 154. Красный gate нельзя выдать за зелёный. Не вопрос чисел-самоописания.

## Остальные замеры

Текущее дерево без реализации: W → rc 1 `CELLS=51 GREEN=10`, в т.ч. обе `subject-drugoj-*` RED; `W --model` → rc 0 `CELLS=54 GREEN=54`; `W --domain-model` → rc 0 `CELLS=214 GREEN=214`; `W --stabs` → rc 0 `SVJAZI=25 CAUGHT=25 LIVE=0` (шесть собственных клеток подмножественных стабов пойманы); `W --domain` → rc 1 `CELLS=210 GREEN=82`; `W --live` → rc 1 `CELLS=9 GREEN=5`; `W --subjects` → rc 1 `SUBJECTS=167 CELLS=334 GREEN=0`, все RED именованы. После честной вставки W → rc 0 51/51, `W --live` → rc 0 9/9, `W --subjects` → rc 0 334/334. Все запущенные фоновые матрицы дождались фактического результата.

Ворота: `pre_critic.sh contracts/154-…md` rc 0 «КРИТИК: дверь зелёная»; `check_precision_gate.sh . contracts/154-…md` rc 0 `OK`; `check_threat_model.sh . contracts/154-…md` rc 0, 5 ЗАЩИЩАЕТ/6 НЕ ЗАЩИЩАЕТ; `check_spec_ready.sh . contracts/154-…md` rc 0 `OK`; `check_provodka.sh . contracts/154-…md` rc 1 «guard не подключён» (ожидаемо до CI). Первый `check_zones.sh .` в архиве без frozen/done refs отказал `git rev-list` и не принят за зелень; после fetch refs полный повтор rc 0: `замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 43972 · проверено по зонам: 10452`.

Соседи: 140 до/после вставки → rc 1 `KLETKI 66 KRASNYH 3` (u01/w20/w21); 084 до миграции → rc 1, 59 клеток/6 красных ф2/ф3/ф4/ф6/ф9/ф10 `SCHET_NEIZVESTEN`; 060 → rc 1, 17 клеток/14 зелёных, те же причины отсутствия входа; 996 `--case freeze-cap` → rc 1 `PROJECT_CAP_BYPASSED`, пока вход состояния не мигрирован; 078 до/после одинаково `красных 1, зелёных 22, не исполнено 31`; doc_048 живой контроль → rc 0 «ветви all зелены»; precision case_14 → rc 0 (отказ freeze ожидается); parsing_hygiene zamok_predmeta → rc 0, 4/4. Ожидаемые до миграции красные потребители не выданы за финальную зелень.

НЕ ПРОВЕРЕНО: CI после проводки, весь перенос потребителей и их финальные зелёные команды, живой task-хук станции/реальный платный вызов, внешний trace после сессии, вся семья fixtures/freeze_contract. Модель-факт openai-codex/gpt-6-sol — контекст текущего запуска; дописку trace-id и проверку независимости до материализации вердикта производит оркестратор.

Вызов 5/5 — последний: при FAIL остановка и решение владельца, шестой вызов/ослабление риска не делегированы. Названного письменного спора автора нет, автоматического арбитража из повтора Б8 не следует.
