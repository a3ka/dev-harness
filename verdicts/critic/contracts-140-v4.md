FAIL

OBJECT=cb06ddf8e086bc513e77845d9178b49b2f9efe49
СУД: repo=dev-harness; предмет=140; фаза=контракт v4; роль=critic; вызов=2/3 (второй по v4); модель-план=openai-codex/gpt-6.1-terra; сессия=Crit140V4b; модель-факт=openai-codex/gpt-6.1-terra (allowed, `scripts/models_actual.sh --tsv --bind`); SHA=cb06ddf8e086bc513e77845d9178b49b2f9efe49; предыдущий=Crit140V4 FAIL; исключение=слово владельца на адресный v+1.

БЛОКИРУЕТ contracts/140-odin-agent-na-predmet.md:64 — проверка судейского факта не различает получение поля другого элемента разрешённого пакета.
ОБЯЗАТЕЛЬСТВО: START любой предметной роли несёт нормализованный факт isolated именно своего item; batch допустим (инварианты 1, 3, 7; frozen 199:34). Новые s45–s47 должны различать запись факта судьи, а не только его наличие.
СОСТОЯНИЕ: поддерживаемый смешанный batch: первый item — рабочий другого предмета с isolated=true, второй — судья с isolated=false после сдачи автора и на верном OBJECT. В новой операции модели [D33] замена имеющегося индексирования `[$idx]` на `[0]` берёт поле первого элемента вместо текущего.
НАБЛЮДЕНИЕ: все 85 имеющихся клеток остаются зелёными на этой мутации; отдельный такой batch разрешён с rc 0, но START судьи содержит `isolated:true` вместо false. s45–s47 проверяют отдельные однопозиционные события, а b01/b06 не предъявляют факт каждого START. Это продолжение прежнего блока о недоказанности факта START, выявленное соседней мутацией новой операции дельты, не поиск по неизменённой поверхности.
ОБХОД: реализация с указанной заменой операции проходит все 85 клеток, хотя записывает чужой факт для судьи в штатном смешанном пакете. Команды и фактический вывод ниже.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: проверка различает источник факта каждого item в разрешённом пакете при несовпадающих значениях, включая судью не на первой позиции; честная обработка такого пакета остаётся зелёной. Привязки стабов — по коду, не по прозе (Н-39).
ПРОИСХОЖДЕНИЕ: узкое-закрытие
КЛАСС: К-10

Арбитр: повторный FAIL по классу доказательства судейского факта START; предмет спора — достаточная проверка источника факта в пакетном событии. Исчерпан фазовый бюджет исправительного вызова; дальнейший маршрут — по действующему порядку арбитража.

## Карта классов

К-01: чисто — вход: сдаточный лист и двери автора; повтор дверей, кроме явно заданных model/stabs, не назначен.
К-02: чисто — вход: 199:19,34 и разрешение в коммите кандидата; без изменений с вызова 1 вне дельты.
К-03: чисто — вход: инвариант 7 и 199:34; запрет судейского поля снят.
К-04: чисто — вход: diff 86a77d35a2..cb06ddf8 ограничен контрактом и зоной батареи architect.
К-05: чисто — вход: приёмка 140:71–80; W и S с кодами возврата.
К-06: чисто — вход: без изменений с вызова 1.
К-07: чисто — вход: `W --model` rc 0, 85 отдельных клеток; несовместимость запрета поля снята.
К-08: блок — позиционная замена операции [D33] проходит все клетки.
К-09: блок — смешанный batch с разными фактами обнаруживает неполноту проверки дельты.
К-10: блок — START судьи получает факт другого item пакета.
К-11: чисто — вход: без изменений с вызова 1; носители source.json закреплены.
К-12: чисто — вход: новая операция [D33] использует jq.
К-13: н/п — дельта не обрабатывает секреты.
К-14: чисто — вход: s45/s46/s47, `W --model` rc 0; инверсия требования изоляции судьи ловится s39.
К-15: чисто — вход: jq source.json: 85 клеток, 44 стаба, 89 связей, 49 носителей, 13 привязок x01; предмет 85.
К-16: чисто — вход: 140:189 и 199:34; требование изоляции остаётся только у рабочих.
К-17: н/п — дельта не меняет операции или схемы архитектуры 188.

## Выполненная проверка

`bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model` — rc 0, сырой вывод: 85 строк `CASE <имя> ok`, в том числе `CASE s45-sudja-izolirovan-ne-trebuetsja ok`, `CASE s46-sudja-start-fakt-istina ok`, `CASE s47-sudja-start-fakt-lozh ok`.

`bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --stabs` — rc 1; сырой итог: `SVJAZI 89`, `SUBJEKT_KRASNO: 9 — поставленная дверь красна (свидетель критика пойман)`; s40–s43 на объявленных привязках печатают `KRASEN`. Полный вывод запуска: `artifact://11377`.

Атака на соседнюю позицию новой операции — воспроизводимые команды из корня клона (промежуточная проверка с отсутствующим контрактом кандидата ошибочно дала `KLASS_RISKA_NET`; ниже исправленная подготовка мира):

```sh
python3 -c 'import importlib.util,tempfile,pathlib,json; p="fixtures/workshop_project/odin_agent_140/probe.py"; s=importlib.util.spec_from_file_location("probe",p); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); t=m.MODEL.read_text(); a="(.tasks // [.])[$idx].isolated"; assert t.count(a)==1; d=tempfile.TemporaryDirectory(); f=pathlib.Path(d.name)/"door.sh"; f.write_text(t.replace(a,"(.tasks // [.])[0].isolated")); k=m.kejsy(); bad=[(n,m.progon(f,n,v["run"])) for n,v in k.items()]; print("mutation [D33] [$idx] -> [0]:",len(bad),"cases, failures:",[(n,e) for n,e in bad if e]); w=tempfile.TemporaryDirectory(); mir=m.Mir(w.name); wt,br,sha=mir.worktree("141"); mir.start("141","Avtor141",wt=wt,branch=br); mir.zhurnal("Avtor141",sdal=True); wt2,br2,sha2=mir.worktree("142"); ev=mir.sobytie("e.json",[m.item("architect","Arch142",["SUBJECT=142","WORKTREE="+wt2,"BRANCH="+br2],isolated=True),m.item("critic","Critic141",["SUBJECT=141","OBJECT="+sha],isolated=False)]); r=m.sudit(f,mir,ev); print("batch rc:",r.returncode,"stderr:",r.stderr.strip()); print("batch START:",[(x.get("holder"),x.get("isolated")) for x in map(json.loads,mir.ledger.read_text().splitlines()) if x.get("holder") in ("Arch142","Critic141")])'
```
Сырой вывод, rc 0:
```text
mutation [D33] [$idx] -> [0]: 85 cases, failures: []
batch rc: 1 stderr: ОТКАЗ: KLASS_RISKA_NET: предмет 141: класс риска неоднозначно определён (net_stroki); файлы: ни contracts/, ни .harness/contracts/ в дереве 345d50a391e39f8e9e4bd178befe680f8ddf3eaf нет
batch START: []
```

```sh
python3 -c 'import importlib.util,tempfile,pathlib,json; p="fixtures/workshop_project/odin_agent_140/probe.py"; s=importlib.util.spec_from_file_location("probe",p); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); t=m.MODEL.read_text(); a="(.tasks // [.])[$idx].isolated"; d=tempfile.TemporaryDirectory(); f=pathlib.Path(d.name)/"door.sh"; f.write_text(t.replace(a,"(.tasks // [.])[0].isolated")); w=tempfile.TemporaryDirectory(); mir=m.Mir(w.name); mir.kontrakt("141","обычный"); wt,br,sha=mir.worktree("141",kontrakty=[("fajl","141-stub.md","# К\nКЛАСС РИСКА: обычный\n")]); mir.start("141","Avtor141",wt=wt,branch=br); mir.zhurnal("Avtor141",sdal=True); wt2,br2,sha2=mir.worktree("142"); ev=mir.sobytie("e.json",[m.item("architect","Arch142",["SUBJECT=142","WORKTREE="+wt2,"BRANCH="+br2],isolated=True),m.item("critic","Critic141",["SUBJECT=141","OBJECT="+sha],isolated=False)]); r=m.sudit(f,mir,ev); print("mutation [D33] [$idx] -> [0]"); print("batch rc:",r.returncode,"stderr:",r.stderr.strip()); print("batch START:",[(x.get("holder"),x.get("isolated")) for x in map(json.loads,mir.ledger.read_text().splitlines()) if x.get("holder") in ("Arch142","Critic141")])'
```
Сырой вывод, rc 0:
```text
mutation [D33] [$idx] -> [0]
batch rc: 0 stderr: 
batch START: [('Arch142', True), ('Critic141', True)]
```
