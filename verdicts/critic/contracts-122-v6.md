FAIL
OBJECT=5928d58b63a261be0d1a7c379e57b1007070cb44
СУД: repo=dev-harness; предмет=122; фаза=контракт v6; роль=critic; вызов=один узкий по слову владельца 2026-11-19 ~10:07 UTC; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit122V6d; модель-факт=openai-codex/gpt-6.1-terra; SHA=5928d58b63a261be0d1a7c379e57b1007070cb44; предыдущий=Crit122V6c FAIL; исключение=адресное слово владельца, при FAIL — к владельцу.

БЛОКИРУЕТ contracts/122-ci-proekta.md:153, fixtures/workshop_project/ci_proekta_122/roots_model.py:90-111 — строка декларации внутри ограждённого код-блока принимается как самостоятельная декларация.
ПРОИСХОЖДЕНИЕ: узкое-закрытие
КЛАСС: К-02
ОБЯЗАТЕЛЬСТВО: декларация — самостоятельная строка замкнутой грамматики; по заданию данного узкого суда вложенный в код-блок маркер не является допустимой декларацией и должен вызвать именованный отказ до gh и записей при любом корне.
СОСТОЯНИЕ: честный мир фабрики `mono-declared-explicit`, собственные профиль, origin, секрет и явный контекст; единственная исходная корректная декларация в HEAD обёрнута строками ``` до и после, subject.blob обновлён настоящим HEAD. Контекст и identity не подменены. Источник входа — явно утверждённый сценарием суда вложенный в код-блок маркер. Механизм — предметная операция `subject.split('\n')` и `line.casefold().startswith(...)`: она не учитывает границы код-блока и принимает строку внутри него за самостоятельную.
НАБЛЮДЕНИЕ: модель возвращает rc 0, вызывает gh на origin станции и создаёт тег вместо rc 1 `project-workflow-rashozhdenie` до gh/записей. Закрывающее свойство: отличать самостоятельную декларацию от вложенной, отказывать на вложенном кандидате независимо от выбранного корня и сохранять честные независимые декларации и отсутствие декларации в допустимом mono.

## Исполненная проверка

Рабочий каталог `/tmp/dev-harness-verify/Crit122V6d/repo`; временный мир удалён фабрикой Python. Команда:

```sh
python3 -c 'import importlib.util,pathlib,tempfile,json,os; p=pathlib.Path("fixtures/workshop_project/ci_proekta_122/roots_probe.py").resolve(); s=importlib.util.spec_from_file_location("probe",p); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); t=tempfile.TemporaryDirectory(prefix="critic122-"); b=pathlib.Path(t.name); station,product,ctx,origin=m.world(b,m.TREE,"mono-declared-explicit"); target=station/m.TARGET; text=target.read_text(); lines=text.splitlines(); lines=["```\n"+line+"\n```" if line.startswith("ПРОЕКТ-ПРЕДПОСЫЛОК: ") else line for line in lines]; target.write_text("\n".join(lines)+"\n"); m.commit(station); c=json.loads(ctx.read_text()); c["subject"]["blob"]=m.git(station,"rev-parse","HEAD:"+m.TARGET); ctx.write_text(json.dumps(c)); env=dict(os.environ,PATH=str(b/"bin")+":"+os.environ["PATH"]); env.pop("HARNESS_PROJECT_LAYER_ROOT",None); r=m.run(["python3",m.HERE/"roots_model.py",station,m.TARGET,ctx],env=env); calls=b/"calls.jsonl"; tag=m.run(["git","-C",station,"rev-parse","--verify",m.TAG]); print("subject_rc:",r.returncode,"output:",r.stdout+r.stderr,"gh:",calls.read_text() if calls.exists() else "[]","tag_rc:",tag.returncode)'
```

Сырой вывод, rc команды 0:

```text
subject_rc: 0 output: PREDPOSYLKI_OK secrets=1 variables=0 environments=0 settings=0
v1
 gh: ["secret", "list", "-R", "/tmp/critic122-740fz3io/station-origin.git"]
 tag_rc: 0
```

Повторный поиск связан с дельтой распознавания кандидата маркера: новый предикат считает каждую строку по отдельности, включая вложенную. К ВЛАДЕЛЬЦУ: FAIL по единственному разрешённому узкому вызову; следующая санкция этим вердиктом не даётся.

## Карта классов

К-01: н/п — сдаточная команда запущена, результат к моменту установленного блокера не предъявлен.
К-02: блок — вложенная декларация принята самостоятельной; команда выше.
К-03: н/п — без изменений с Crit122V6c, вне узкого поиска.
К-04: н/п — без изменений с Crit122V6c, вне узкого поиска.
К-05: н/п — зависимый регресс не завершён после доказанного блокера.
К-06: н/п — зависимый регресс не завершён после доказанного блокера.
К-07: блок — модель принимает вложенную декларацию, исполненная проверка выше.
К-08: н/п — отдельная мутация не проводилась; нарушение самой модели исполнено выше.
К-09: блок — вложенный маркер принят, исполненная проверка выше.
К-10: блок — наблюдены вызов gh и тег, исполненная проверка выше.
К-11: блок — чтение HEAD не различает код-блок, roots_model.py:90-111.
К-12: н/п — общий JSON-канон не менялся, вне узкого поиска.
К-13: н/п — зависимый регресс не завершён после доказанного блокера.
К-14: н/п — зависимый регресс не завершён после доказанного блокера.
К-15: н/п — зависимый регресс не завершён после доказанного блокера.
К-16: блок — до инвентаря принят вложенный источник связи, исполненная проверка выше.
К-17: н/п — продуктовый бриф архитектуры 188 не заявлен.
