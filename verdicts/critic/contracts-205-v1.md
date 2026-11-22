FAIL
OBJECT=cdd8e7538bba94546bbe8117dba3b4770b67278d

СУД: repo=dev-harness; предмет=205; фаза=v1; роль=critic; вызов=1/2; модель-план=не установлена по доступной записи; сессия=Crit205V1; модель-факт=openai-codex/gpt-6.1-terra (контекст запуска); SHA=cdd8e7538bba94546bbe8117dba3b4770b67278d; предыдущий=нет; исключение=нет; класс риска=обычный.

Запись по этому вызову в доступных HANDOFF кандидата и станции не найдена; план модели и дополнение записи по трейсу оркестратору необходимо установить до материализации. Автор коммита OBJECT — architect, судья — critic. Это первый полный вызов по заданию, историю прежнего суда по 205 не обнаружено. Вердикт FAIL не разрешает freeze.

## Блоки

**БЛОКИРУЕТ К-09** contracts/205-provodka-gate-profilja.md:30 — обязательная модель теряет границы argv на LF.
ОБЯЗАТЕЛЬСТВО: И1 и И4 сравнивают целые токены эффективного `sourceCanon.gate` буквально; предложено перенести блок модели в дверь (приёмка п.8).
СОСТОЯНИЕ: профиль создаётся поддерживаемым редактированием `harness.project.json`, двухслойный профиль и файл guard как в a1; gate — JSON-массив `['bash', 'not-the-guard\nscripts/red_gate_205.sh']`. Резолвер 996 допускает непустые строки argv без NUL (`scripts/profile_resolver.sh:661-681`); фактический элемент не равен guard и не оканчивается на `/scripts/red_gate_205.sh`.
НАБЛЮДЕНИЕ: модель `model/check_provodka_model.sh:513` использует `jq -r` и `read` по строкам, превращая одну argv-строку в две. Воспроизведение в одноразовом мире через `probe.repo_profile`, `probe.scratch_subject`, `probe.invoke` (`python3 .scratch-crit205v1/attack.py`, rc 0):
```
NEWLINE_INPUT ['bash', 'not-the-guard\nscripts/red_gate_205.sh'] RESULT (0, '')
```
Ожидался rc 1 «guard не подключён», получен ложный rc 0. Это дефект самой обязательной модели, не гипотетический фильтр. Свойство закрытия: сохранять границы всех валидных элементов argv при сравнении; различающая клетка на LF внутри и честный сосед с настоящим токеном должны судить модель и реализацию.

**БЛОКИРУЕТ К-08** contracts/205-provodka-gate-profilja.md:30,33,60 — проверка не отличает буквальное сравнение от подстроки или нечувствительности к регистру.
ОБХОД: на полной батарее замена существующего равенства модели `if [ "$tok" = "$guard" ]` на `if [[ "$tok" == *"$guard"* ]]` и отдельно на `if [ "${tok,,}" = "${guard,,}" ]` даёт 19/19, хотя нарушает И1/И4.
СОСТОЯНИЕ: явно названные в задании сценарии двойника, расширения и регистра; профиль задаётся поддерживаемым редактированием sourceCanon.gate. Файл guard `scripts/red_gate_205.sh` существует; gate соответственно `['bash','scripts/red_gate_205.sh.bak']` и `['bash','scripts/RED_GATE_205.SH']`.
НАБЛЮДЕНИЕ: `python3 .scratch-crit205v1/counter.py` rc 0, сырой вывод:
```
substring 'scripts/red_gate_205.sh.bak' honest= (1, 'проводка: guard не подключён: scripts/red_gate_205.sh не вызывается в .githooks/ или .github/workflows/\n') mutated= (0, '')
case 'scripts/RED_GATE_205.SH' honest= (1, 'проводка: guard не подключён: scripts/red_gate_205.sh не вызывается в .githooks/ или .github/workflows/\n') mutated= (0, '')
```
`python3 .scratch-crit205v1/attack.py` rc 0, сырые итоги: `ATTACK_RESULT substring rc 0 mismatches` и `ATTACK_RESULT case-insensitive rc 0 mismatches`, для обеих `KLETKI=19 ZELENYE=19 KRASNYE=0`. Два примера — один класс сравнения. Свойство закрытия: батарея отличает буквальное чувствительное к регистру сравнение полных токенов от этих замен, сохраняя честные положительные случаи. Привязки стабов — по коду батареи, не в прозе контракта (Н-39).

**БЛОКИРУЕТ К-10** contracts/205-provodka-gate-profilja.md:57 — заявленное сравнение полного выхода фактически не производится.
ОБЯЗАТЕЛЬСТВО: сравниваются rc и полная строка результата; И3 задаёт единственную именованную диагностику, И6 сохраняет порядок и прежние фразы.
СОСТОЯНИЕ: исходная операция выдачи именованного отказа в модели заменена на `printf 'extraneous diagnostic\n' >&2; die ...`; входы e1–e3 — уже заявленные ошибочные профили.
НАБЛЮДЕНИЕ: `probe.py:248` принимает `want_line in output.splitlines()`, а при rc 0 даже не сравнивает вывод. `python3 .scratch-crit205v1/counter.py` rc 0 вывел, например:
```
CELL {"name": "e3-kanon-vne-alfavita", "rc": 1, "expected": 1, "matched": true, "output": "extraneous diagnostic\nпроводка: профиль проекта не распознан: SOURCE_CANON_INVALID: репо-слой.sourceCanon: неизвестный ключ: extra"}
KLETKI=19 ZELENYE=19 KRASNYE=0
extra-output rc 0
```
ОБХОД: лишняя диагностическая строка проходит зелёной, в том числе перед ожидаемой, несмотря на заявленное сравнение полного результата. Свойство закрытия: сравнить весь наблюдаемый вывод и rc, включая отсутствие лишних строк и успешный пустой выход, а не принадлежность одной строки.

## Прогоны и атаки

`bash scripts/check_sdacha.sh "$PWD" contracts/205-provodka-gate-profilja.md --run`: rc 0, `СДАЧА: лист зелёный (двери=7 карта=17/17 дельта=0)`.

W=`bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh`: W --repo . rc 1 `KLETKI=19 ZELENYE=11 KRASNYE=8`; W --model rc 0 `KLETKI=19 ZELENYE=19 KRASNYE=0`; W --stabs rc 0 `MUTACII=6 SVJAZI=7 POIMANY=7 ZHIVYH=0`. `bash fixtures/check_provodka/external_ci_994/probe.sh` rc 0. Все эти команды исполнены заново, как и отдельные двери: `pre_critic.sh contracts/205-provodka-gate-profilja.md`, `check_spec_ready.sh . contracts/205-provodka-gate-profilja.md`, `check_ids.sh .`, `check_ceilings.sh .`, `check_provodka.sh --grammar . contracts/205-provodka-gate-profilja.md`, `check_precision_gate.sh . contracts/205-provodka-gate-profilja.md`, `check_threat_model.sh . contracts/205-provodka-gate-profilja.md`: каждая через bash rc 0.

Свои мутации запускались одноразовой копией модели в scratch командой `python3 .scratch-crit205v1/attack.py`; ниже сырые итоговые строки (rc — именно результат батареи мутанта, не процесс скрипта):
```
ATTACK_RESULT substring rc 0 mismatches
ATTACK_RESULT any-field rc 1 mismatches c3-imja-vne-gate
ATTACK_RESULT case-insensitive rc 0 mismatches
ATTACK_RESULT strip-relative rc 0 mismatches
ATTACK_RESULT strip-dotdot rc 0 mismatches
ATTACK_RESULT ignore-errors rc 1 mismatches e1-ne-json,e2-sloj-net,e3-kanon-vne-alfavita
ATTACK_RESULT gate-first rc 1 mismatches a1-gate-profilja,a2-gate-v-defoltsah,a5-gate-py
ATTACK_RESULT omit-suffix rc 1 mismatches a3-absoljutnyj-token
ATTACK ignore-guard-existence
ANCHOR COUNT 0
```
`strip-relative` и `strip-dotdot` — замены равенства на сравнение после удаления префикса `./` или `../`; сами по себе не блоки: суффиксное правило И1 и так принимает эти токены. Неудачный якорь не является атакой. Отсутствие guard отдельно покрыто d1; отсутствие профиля b3; некорректные gate объект/пустой массив не атакованы отдельно. Сырой jq без резолвера — авторский стаб SYROJ-JSON, пройден --stabs; отдельной своей мутации для него не запускалось. Имена мутаций, замены операций и выходы для блокирующих случаев приведены выше; scratch удалён после исследования.

## Карта классов

К-01: чисто — check_sdacha --run rc 0, pre_critic и precision rc 0.
К-02: чисто — вход: задание 205 и боль 207, И1–И7.
К-03: чисто — вход: frozen 038/191/994, probe 994 rc 0.
К-04: чисто — precision rc 0; ЗОНА architect/implementer/orchestrator в контракте.
К-05: чисто — вход: команды приёмки 1–8.
К-06: чисто — вход: probe.py Prerequisite и обработка rc 2; отдельно условия среды не мутировались.
К-07: блок — модель теряет границы argv (К-09).
К-08: блок — буквальное сравнение против подстроки и регистра.
К-09: блок — модель теряет границы argv на LF.
К-10: блок — полный выход не сравнивается.
К-11: чисто — вход: probe.py строит ожидания до запуска субъекта.
К-12: чисто — вход: модель вызывает настоящий profile_resolver; SYROJ-JSON пойман --stabs.
К-13: н/п — секреты не входят в предмет.
К-14: чисто — вход: a1–a5 и честный контроль --stabs; ложный красный отдельных новых предикатов не установлен.
К-15: чисто — W --repo/--model/--stabs и 994 rc как выше; diff модели и двери — добавленный блок 30 строк.
К-16: чисто — вход: класс обычный и границы модели угроз; check_threat_model rc 0.
К-17: н/п — изменение инфраструктурной двери, архитектурная модель проекта не заявлена.
