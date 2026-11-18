FAIL

OBJECT=e585b5c54f75c65d2d26ee77d417ac0ab0ca7251
СУД: repo=dev-harness; предмет=140; фаза=контракт v4; роль=critic; вызов=1/3 по записи HANDOFF; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit140V4; модель-факт=openai-codex/gpt-6.1-terra (allowed, scripts/models_actual.sh --tsv --bind); SHA=e585b5c54f75c65d2d26ee77d417ac0ab0ca7251; предыдущий=accept v3; исключение=слово владельца на адресный v+1, HANDOFF строка 5.

БЛОКИРУЕТ contracts/140-odin-agent-na-predmet.md:64 — запрет поля isolated в судейском START противоречит замороженному контракту 199.
ОБЯЗАТЕЛЬСТВО: contracts/199-sol-v-izolyacii.md:34 требует для судей записывать флаг фактом события, не применяя к ним требование изоляции; заявка 199:19 не разрешает менять это обязательство.
СОСТОЯНИЕ: разрешённый по судейским воротам судья спавнится с item.isolated=true (или false); 140:64 требует, чтобы судейский START не содержал поля, тогда как 199:34 требует записать его фактическое значение.
НАБЛЮДЕНИЕ: одна строка START не может одновременно содержать и не содержать это поле. Модель 140, model/zamok_predmeta.sh:606-618, явно удаляет поле для судей; тест s45 проверяет только отсутствие требования изоляции, не запись факта. Поставить обе реализации одновременно в соответствие frozen 199 и кандидату невозможно.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: контракт и различающая проверка согласуют судейский START с действующей нормой 199, сохраняя неприменимость изоляционного отказа к судьям; при необходимости смены обязательства требуется решение полномочной роли.
КЛАСС: К-03.

БЛОКИРУЕТ contracts/140-odin-agent-na-predmet.md:52 — механическое противоречие числа клеток в предмете и приёмке.
ОБЯЗАТЕЛЬСТВО: предмет должен однозначно определять полный набор проверяемых входов; приёмка contracts/140-odin-agent-na-predmet.md:72-77 требует 83 клетки.
СОСТОЯНИЕ: кандидат одновременно утверждает, что безфлаговый режим гоняет «все 76 клеток», и требует 83 клетки, включая семь новых входов изоляции.
НАБЛЮДЕНИЕ: jq '{kejsy:(.kejsy|length),stabs:(.stab_vhod|length),svjazi:([.stab_vhod[]|length]|add),nositeli:(.nositeli|length)}' fixtures/workshop_project/odin_agent_140/source.json → {"kejsy":83,"stabs":41,"svjazi":80,"nositeli":46}, rc 0; 76 — прежний, а не текущий набор. Других расхождений в пересчитанных числах 83/41/80/46 не обнаружено.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: число полного набора в предмете и приёмке согласовано с реально предъявляемой батареей без сокращения её входов.
КЛАСС: К-15.

## Карта классов

К-01: чисто — сдаточный лист и двери автора предъявлены в задании; повтор не назначен, threat model и проводка прочитаны.
К-02: чисто — вход: заявка contracts/199-sol-v-izolyacii.md:19 и слово владельца в HANDOFF:5.
К-03: блок — судейский START противоречит contracts/199-sol-v-izolyacii.md:34.
К-04: чисто — вход: ЗОНА 140 и frozen/contracts/140/3; implementer несёт оба существующих пути, пронос поля отнесён 199.
К-05: чисто — вход: contracts/140-odin-agent-na-predmet.md:69-80, W и S с rc.
К-06: чисто — вход: probe.py, ORACLE_TAMPERED и проверки инструментов.
К-07: блок — несовместимые требования к судейскому START; честная общая реализация 140 и 199 недостижима.
К-08: чисто — вход: --stabs, контроль модели и привязки s36–s40 красны; rc 1 из-за шести красных клеток поставленной старой двери.
К-09: чисто — вход: w26–w30, s45, b07 в probe.py и source.json.
К-10: блок — судейский факт START не проверяется в s45 при обязательстве 199:34.
К-11: чисто — вход: probe.py, чтение source.json и проверка sha256 до запуска субъекта.
К-12: чисто — вход: модель использует jq для JSON поля и учёта.
К-13: н/п — дельта не обрабатывает секреты.
К-14: чисто — вход: w30 истинное булево значение, w26–w29 отказ, s45 исключение судьи.
К-15: блок — в предмете 76 вместо 83; пересчёт jq: 83/41/80/46.
К-16: чисто — вход: модель угроз contracts/140-odin-agent-na-predmet.md:172-200; изоляция и неприменимость к судьям заявлены.
К-17: н/п — дельта не меняет операции или схемы архитектуры 188.

## Выполненная атака

Команда: `python3 -c 'import importlib.util,tempfile,pathlib; p="fixtures/workshop_project/odin_agent_140/probe.py"; s=importlib.util.spec_from_file_location("probe",p); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); t=m.MODEL.read_text(); a="if . == true then"; assert a in t; f=tempfile.NamedTemporaryFile(mode="w",suffix=".sh"); f.write(t.replace(a,"if . == false then",1)); f.flush(); print("mutation: == true -> == false"); print("w30:",m.progon(pathlib.Path(f.name),"w30-rabochij-start-s-faktom",m.kejsy()["w30-rabochij-start-s-faktom"]["run"])); print("w27:",m.progon(pathlib.Path(f.name),"w27-rabochij-isolated-lozh",m.kejsy()["w27-rabochij-isolated-lozh"]["run"]))'` (rc 0). Сырой вывод:

```text
mutation: == true -> == false
w30: ['rc: rc 1 ≠ 0; stderr=/tmp/tmpxrqpbwo2.sh: line 63: ADVERSARIJ_DO_REVJUERA: command not found\nОТКАЗ: NE_IZOLIROVAN: item 0: рабочий Arch140 без реального isolated === true в ПОЛЕ ite', "выход: в stdout нет 'PUSCHEM Arch140 dev-harness/140 (rabochij/architect)' (есть '')", "start: строки START {'subjectId': '140', 'holder': 'Arch140', 'klass': 'rabochij', 'group': 'harness', 'isolated': True} нет в учёте", 'занятие: занятие 140 не создано']
w27: ['rc: rc 0 ≠ 1; stderr=/tmp/tmpxrqpbwo2.sh: line 63: ADVERSARIJ_DO_REVJUERA: command not found', 'причина: причины NE_IZOLIROVAN нет в stderr: /tmp/tmpxrqpbwo2.sh: line 63: ADVERSARIJ_DO_REVJUERA: command not found', 'учёт: учёт не пуст (1 строк)', "занятие: занятие 140 живо (holder 'Arch140')"]
```
