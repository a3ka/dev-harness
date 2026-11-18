FAIL

OBJECT=980bcb419dc93f59bb376ad740fd6685ae24404e
СУД: repo=dev-harness; предмет=037; фаза=контракт v3; роль=critic; вызов=первый по v3; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit037V3; модель-факт=openai-codex/gpt-6.1-terra (allowed, models_actual --bind); SHA=980bcb419dc93f59bb376ad740fd6685ae24404e; предыдущий=verdicts/critic/contracts-037-v2.md accept; исключение=нет.

БЛОКИРУЕТ contracts/037-samodostatochnyj-cwd-i-priemnik-task.md:553 — критерий не различает отмену обязательного останова при расхождении ожидаемого tip.
ОБХОД: источник входа — прямо предусмотренное контрактом расхождение полученного и ожидаемого tip при синхробазе; носитель может продвинуться после сообщения ожидаемого tip работнику. Источник механизма — существующая операция в модели `fixtures/accept_task_commit/priem_izolyacii_037/model/orchestrator_ceremony_m3.md:22`: инструкция «расхождение … — СТОП и доклад, не работа». Замена только этой инструкции на «расхождение … — не препятствие для работы» сохраняет четыре якоря ц0 и дословную норму ПРОВОДКА, а блок 199-baza сам не сравнивает tip с ожидаемым. Батарея в честных моделях остальных субъектов остаётся зелёной: ц1 и ц5 сравнивают результат только с актуальным tip, случай расхождения не создают. Так критерий принимает инструкцию работать на неожиданной базе. Закрывающее свойство: приёмка различает сохранение обязательного отказа от его отмены на достижимом расхождении, сохраняя честный контроль.
КЛАСС: К-08.

Выполненная атака (cwd — корень клона, rc 0):
```bash
python3 -c 'from pathlib import Path; p=Path("fixtures/accept_task_commit/priem_izolyacii_037/model/orchestrator_ceremony_m3.md"); s=p.read_text(); a="расхождение полученного на синхробазе tip с ожидаемым — СТОП и доклад, не работа"; assert a in s; Path("/tmp/dev-harness-verify/Crit037V3/ceremony-mut2.md").write_text(s.replace(a,"расхождение полученного на синхробазе tip с ожидаемым — не препятствие для работы"))' && env S037V_CEREM=/tmp/dev-harness-verify/Crit037V3/ceremony-mut2.md S037V_BLOKI=fixtures/workshop_project/sol_v_izolyacii_199/model/orchestrator_vstavka_199.md S037V_PRIV=fixtures/workshop_project/sol_v_izolyacii_199/model/privjazka_sdachi.sh bash fixtures/accept_task_commit/red_priem_izolyacii_037.sh .
```
```text
ok   c0
ok   c1
ok   c2
ok   c3
ok   c4
ok   c5
ИТОГ 037-М3 (субъекты дерева): клеток 6, красных 0, зелёных 6
ЗЕЛЕНОЕ 037-М3
```
Проверено отдельно: новая норма ПРОВОДКА содержится в мутации без изменения; сам механизм проводки требует отдельной строки, что является независимым блоком ниже.

Также выполнена мутация «приём — после сверки» → «приём — без сверки» в той же модели с теми же `S037V_BLOKI` и `S037V_PRIV`, командой безфлаговой батареи с `S037V_CEREM=/tmp/dev-harness-verify/Crit037V3/ceremony-mut.md`; rc 0, сырой вывод:
```text
ok   c0
ok   c1
ok   c2
ok   c3
ok   c4
ok   c5
ИТОГ 037-М3 (субъекты дерева): клеток 6, красных 0, зелёных 6
ЗЕЛЕНОЕ 037-М3
```
Команда создания мутации: `python3 -c 'from pathlib import Path; p=Path("fixtures/accept_task_commit/priem_izolyacii_037/model/orchestrator_ceremony_m3.md"); s=p.read_text(); a="приём — после сверки scripts/privjazka_sdachi.sh"; assert a in s; Path("/tmp/dev-harness-verify/Crit037V3/ceremony-mut.md").write_text(s.replace(a,"приём — без сверки scripts/privjazka_sdachi.sh"))'`; запуск: `env S037V_CEREM=/tmp/dev-harness-verify/Crit037V3/ceremony-mut.md S037V_BLOKI=fixtures/workshop_project/sol_v_izolyacii_199/model/orchestrator_vstavka_199.md S037V_PRIV=fixtures/workshop_project/sol_v_izolyacii_199/model/privjazka_sdachi.sh bash fixtures/accept_task_commit/red_priem_izolyacii_037.sh .`. Эта дополнительная мутация меняет и норму ПРОВОДКА, поэтому отдельно достаточность всей приёмки ей не доказывается.

БЛОКИРУЕТ contracts/037-samodostatochnyj-cwd-i-priemnik-task.md:564 — дословный перенос модели не удовлетворяет обязательной проводке.
ОБЯЗАТЕЛЬСТВО: п.5 требует дословно перенести тело модели; :739 требует зелёной регрессии Р7, а :829 задаёт точную норму role-канала.
СОСТОЯНИЕ: implementer дословно переносит `fixtures/accept_task_commit/priem_izolyacii_037/model/orchestrator_ceremony_m3.md:22` в раздел М3 и вносит блоки 199 по их модели, не меняя остальные разделы. Норма :829 в модели есть только внутри длинной строки, с текстом и до, и после неё; в текущей роли и модели блоков 199 отдельной строки нет.
НАБЛЮДЕНИЕ: `scripts/check_provodka.sh:694` использует `grep -Fxq`, требующий отдельную точную строку. Поэтому Р7 не может стать rc 0 от предписанного переноса; одновременная дословность модели и зелёная проводка не доказаны и в описанном честном состоянии несовместимы. Закрывающее свойство: модель переноса и норма role-канала согласованы так, чтобы честный перенос давал отдельную точную норму и Р7 rc 0 без изменения иных обязательств.
КЛАСС: К-07.

## Карта классов

К-01: чисто — `bash scripts/check_sdacha.sh . contracts/037-samodostatochnyj-cwd-i-priemnik-task.md --run` rc 0, двери 11; `bash scripts/check_precision_gate.sh . contracts/037-samodostatochnyj-cwd-i-priemnik-task.md` rc 0.
К-02: чисто — вход: заявка `contracts/199-sol-v-izolyacii.md:20` и дельта М3 п.5.
К-03: чисто — вход: М1/М2 неизменны, заявка 199 и frozen 037/2.
К-04: чисто — вход: зоны v+1 и 19 строк пересечений; precision-gate rc 0.
К-05: чисто — вход: критерии Р1–Р9 и сдаточный лист, команды с rc.
К-06: чисто — вход: проверки bash/git/jq и файлов батареи с rc 2.
К-07: блок — дословный перенос модели не удовлетворяет обязательной проводке.
К-08: блок — критерий не различает отмену останова при расхождении tip.
К-09: чисто — вход: объявленные шесть клеток ц0–ц5 и поддерживаемые сценарии 199:20; дефект отличимости К-08 указан отдельно.
К-10: чисто — вход: проверки git tip и состояния носителя в ц1–ц5; ограничение текстового контроля указано в К-08.
К-11: чисто — вход: ожидаемые и фактические git SHA сохраняются отдельно до и после исполнения блоков.
К-12: чисто — вход: блоки и сверка из модели 199, git как свидетель состояния.
К-13: н/п — секреты не входят в предмет.
К-14: чисто — `bash scripts/check_sdacha.sh . contracts/037-samodostatochnyj-cwd-i-priemnik-task.md --run` rc 0, включает контроль модели.
К-15: чисто — `git diff --unified=0 662d6a7442 980bcb419d -- contracts/037-samodostatochnyj-cwd-i-priemnik-task.md` и подсчёт добавленных `ПЕРЕСЕЧЕНИЕ implementer:`: 19; `--stabs` rc 0, поймано 7/7.
К-16: чисто — вход: рисковый класс и модель угроз контракта :3, :117–137.
К-17: н/п — бриф архитектуры 188 и tooling/checks/cli.js в задании и дереве предмета не заявлены.
