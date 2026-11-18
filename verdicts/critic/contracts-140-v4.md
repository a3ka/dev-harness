accept

OBJECT=96be455c44e9c189e4263389707b9f40cb77c443
СУД: repo=dev-harness; предмет=140; фаза=контракт v4, узкое исполнение Arb140V4; роль=critic; вызов=1/2 по отдельному счёту ADR, ровно один по санкции Cons140Sign; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit140V4c; модель-факт=openai-codex/gpt-6.1-terra (allowed); SHA=96be455c44e9c189e4263389707b9f40cb77c443; предыдущий=Crit140V4b FAIL и Arb140V4 resolved; исключение=санкция консультанта `/tmp/dev-harness-verify/Cons140Sign/otvet.md`, ADR 17.11 п.1 и слово владельца 18.11 ~18:20 №12.

## Решение

Один блок Crit140V4b закрыт: `probe.py:1432-1455` предъявляет допустимый пакет с рабочим 142 true первым и судьёй 141 false вторым, после действительной сдачи и с OBJECT дерева кандидата; проверяются оба START по subjectId, holder, klass и собственному isolated. Честная модель проходит клетку. Ровно позиционная замена существующей операции [D33] обнаруживается проверкой факта судьи, а не подготовкой мира. `source.json:309-311` привязывает s44 к b08; файл стаба отличается от модели только этой заменой, что сверено кодовым diff. Привязка устанавливается кодом, не прозой (Н-39).

Сохранение ранее закрытых зависимых свойств подтверждено модельной батареей и матрицей: в частности судейские true/false/отсутствие, строгий гейт рабочего и атомарный отказ пакета зелёны на модели, соответствующие привязанные стабы красны. Поставленная дверь до реализации остаётся красной на 10 клетках — это ожидаемое красное-до, не зелёная реализация. Исходный риск проноса поля реальным расширением и живого спавна оставлен в модели угроз с ловцами; чужой факт внутри пакета в остаток не переносится. Дельта ограничена контрактом и батареей; нового полного поиска не проводилось.

## Карта классов

К-01: чисто — вход: сдаточный лист `fixtures/workshop_project/odin_agent_140/sdacha_140_v5.md`, предыдущий вердикт и санкция; повтор дверей и листа заданием исключён.
К-02: чисто — вход: решение `verdicts/arbitration/140-isolated-fakt-start.md`, инвариант 7 `contracts/140-odin-agent-na-predmet.md:64`.
К-03: чисто — вход: 199:34 и судейские s45–s47; `W --model` rc 0.
К-04: чисто — вход: `git diff d610f4171d 96be455c44 --stat`, шесть путей в контракте и батарее.
К-05: чисто — вход: `contracts/140-odin-agent-na-predmet.md:71-80`, команды и rc; остальное без изменений с Crit140V4b.
К-06: чисто — вход: без изменений с Crit140V4b; `--stabs` различил красный субъект, не отказ среды.
К-07: чисто — `W --model` rc 0, все 86 клеток, включая b08.
К-08: чисто — позиционная мутация [D33] красна ровно на b08; `W --stabs` привязку s44/b08 подтвердил.
К-09: чисто — вход: b08, разные предметы и факты true/false, судья вторым; честная модель зелена.
К-10: чисто — вход: наблюдаемые START обоих item в b08; позиционная замена краснит именно факт судьи.
К-11: чисто — вход: `source.json` и проверка носителей в `W --stabs`; rc 1 обусловлен субъектом, не ORACLE_TAMPERED.
К-12: чисто — вход: `probe.py:1997-2008`, существующее jq-индексирование заменено единожды; без изменений с Crit140V4b вне дельты.
К-13: н/п — вход: дельта не обрабатывает секреты.
К-14: чисто — `W --model` rc 0 и отдельный честный b08 `[]`; мутация красна.
К-15: чисто — jq `source.json`: 86 клеток, 45 стабов, 90 связей, 50 носителей, 13 x01; `W --stabs` SVJAZI 90, SUBJEKT_KRASNO 10.
К-16: чисто — вход: инвариант 7 и модель угроз `contracts/140-odin-agent-na-predmet.md:172-197`, решение Arb140V4 об остатке.
К-17: н/п — вход: модель и операции архитектуры 188 этой дельтой не менялись.

## Собственные проверки

Рабочий каталог `/tmp/dev-harness-verify/Crit140V4c/repo`, HEAD при суде — OBJECT выше; `git fetch --tags origin` rc 0. Модель определена из `/home/harness/dev-harness` командой `bash scripts/models_actual.sh --tsv --bind --session Crit140V4c | cut -f1-3`, rc 0, сырой вывод:

```text
critic	openai-codex/gpt-6.1-terra	allowed
critic	openai-codex/gpt-6.1-terra	allowed
```

W = `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh`. `W --model` rc 0: 86 строк `CASE ... ok`, в том числе сырая строка `CASE b08-paket-fakt-kazhdogo-itema ok`. `W --stabs` rc 1: сырой полный вывод `artifact://11745`, 86 CASE ok на модели, 90 красных привязок, сырой итог:

```text
STAB s44-fakt-iz-pervogo-itema b08-paket-fakt-kazhdogo-itema KRASEN
SVJAZI 90
SUBJEKT_KRASNO: 10 — поставленная дверь красна (свидетель критика пойман)
```

Независимое воспроизведение указанной позиционной замены во временном файле и проверка всех клеток и честного b08 (команда из корня полного клона):

```sh
env PYTHONDONTWRITEBYTECODE=1 python3 -c 'import importlib.util,tempfile,pathlib; p="fixtures/workshop_project/odin_agent_140/probe.py"; s=importlib.util.spec_from_file_location("probe",p); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); t=m.MODEL.read_text(); a="(.tasks // [.])[$idx].isolated"; assert t.count(a)==1; d=tempfile.TemporaryDirectory(); f=pathlib.Path(d.name)/"door.sh"; f.write_text(t.replace(a,"(.tasks // [.])[0].isolated")); k=m.kejsy(); bad=[(n,m.progon(f,n,v["run"])) for n,v in k.items()]; print("mutation [D33] [$idx] -> [0]:",len(bad),"cases, failures:",[(n,e) for n,e in bad if e]); print("honest b08:",m.progon(m.MODEL,"b08-paket-fakt-kazhdogo-itema",k["b08-paket-fakt-kazhdogo-itema"]["run"]))'
```

rc 0, сырой вывод:

```text
mutation [D33] [$idx] -> [0]: 86 cases, failures: [('b08-paket-fakt-kazhdogo-itema', ["start-судьи: строки START {'subjectId': '141', 'holder': 'Critic141', 'klass': 'sudja', 'isolated': False} нет в учёте"])]
honest b08: []
```

Команда `git diff --no-index fixtures/workshop_project/odin_agent_140/model/zamok_predmeta.sh fixtures/workshop_project/odin_agent_140/stabs/s44-fakt-iz-pervogo-itema/zamok_predmeta.sh` rc 1: единственное отличие — `(.tasks // [.])[$idx].isolated` заменено на `(.tasks // [.])[0].isolated` в [D33]. `jq` по source.json: `kejsy=86`, `stab_vhod=45`, `svjazi=90`, `nositeli=50`, `x01=13`, `s44=["b08-paket-fakt-kazhdogo-itema"]`.

## Развилки

Суд относится только к OBJECT и исполнению решения Arb140V4; accept не является freeze и не разрешает следующий автоматический вызов. Обозначения v4 в задании и v5 в сдаче не меняют предмет и счёт. Предсудебные двери и сдаточный лист повторно не запускались по заданию; проверка живого спавна и станционная интеграция оставлены соответствующему реализационному маршруту.
