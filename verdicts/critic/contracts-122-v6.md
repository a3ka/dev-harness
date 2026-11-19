FAIL
OBJECT=2de882ec83367a742b4d0769dc0aef10a7a5a754
СУД: repo=dev-harness; предмет=122; фаза=контракт v6; роль=critic; вызов=один узкий после арбитража; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit122V6c; модель-факт=openai-codex/gpt-6.1-terra; SHA=2de882ec83367a742b4d0769dc0aef10a7a5a754; предыдущий=Arb122V1 resolved и Crit122V6b FAIL; исключение=адресное слово владельца 2026-11-19 ~00:18 UTC, один узкий вызов после арбитража.

БЛОКИРУЕТ contracts/122-ci-proekta.md:153, fixtures/workshop_project/ci_proekta_122/roots_model.py:90-100 — повреждённый маркер декларации считается отсутствием декларации при выборе станции.
ПРОИСХОЖДЕНИЕ: узкое-закрытие
КЛАСС: К-02
ОБЯЗАТЕЛЬСТВО: грамматика декларации замкнута; невалидная декларация при любом корне даёт rc 1 `project-workflow-rashozhdenie` до gh и записи, а исключение без декларации сохраняет честный однорепозиторный путь. Арбитраж требует не превращать невалидное объявление в отсутствие из-за выбора станции.
СОСТОЯНИЕ: существующий мир `station-explicit` с объявлением внешнего проекта, настоящим профилем и origin станции, отсутствующим секретом у внешнего проекта и одноимённым секретом станции. В закоммиченном HEAD строка декларации повреждена удалением единственного пробела между двоеточием маркера и JSON, subject.blob контекста обновлён на новый настоящий HEAD; выбранный корень и остальные поля мира не подменены. Источник входа — явно установленное арбитражем требование отказа для невалидной декларации при выбранной станции; причина — существующая предметная операция `line.startswith('ПРОЕКТ-ПРЕДПОСЫЛОК: ')` в модели, распознающая только уже правильный разделитель.
НАБЛЮДЕНИЕ: модель считает декларацию отсутствующей, принимает станцию за допустимый mono, возвращает rc 0, вызывает gh на origin станции и создаёт тег. Закрывающее свойство: отличать отсутствие объявления от наличия повреждённого маркера, fail-closed судить грамматику и единственность до gh и любых записей при любом выборе корня, сохранив честные пути без декларации и с корректной декларацией. Нужны различающая клетка и честный парный контроль; привязку стабов к ветвям делает architect по коду (Н-39).

## Исполненные атаки

Рабочий каталог `/tmp/dev-harness-verify/Crit122V6c/repo`. Атаки используют настоящие фабрику миров, git и модель кандидата; каждый мир — временный каталог вне дерева. Команда с повреждением собственной декларации mono:

```sh
python3 -c 'import importlib.util,pathlib,tempfile,json,os; p=pathlib.Path("fixtures/workshop_project/ci_proekta_122/roots_probe.py").resolve(); s=importlib.util.spec_from_file_location("probe",p); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); t=tempfile.TemporaryDirectory(prefix="critic122-",dir="/tmp/dev-harness-verify"); b=pathlib.Path(t.name); station,product,ctx,origin=m.world(b,m.TREE,"mono-declared-explicit"); target=station/m.TARGET; target.write_text(target.read_text().replace("ПРОЕКТ-ПРЕДПОСЫЛОК: ","ПРОЕКТ-ПРЕДПОСЫЛОК:")); m.commit(station); c=json.loads(ctx.read_text()); c["subject"]["blob"]=m.git(station,"rev-parse","HEAD:"+m.TARGET); ctx.write_text(json.dumps(c)); env=dict(os.environ,PATH=str(b/"bin")+":"+os.environ["PATH"]); env.pop("HARNESS_PROJECT_LAYER_ROOT",None); r=m.run(["python3",p.parent/"roots_model.py",station,m.TARGET,ctx],env=env); print("declaration:",next(x for x in target.read_text().splitlines() if x.startswith("ПРОЕКТ-ПРЕДПОСЫЛОК"))); print("rc:",r.returncode,"output:",r.stdout,r.stderr,"gh:",(b/"calls.jsonl").read_text() if (b/"calls.jsonl").exists() else "none","tag:",m.run(["git","-C",station,"rev-parse","--verify",m.TAG]).returncode)'
```

Сырой вывод, команда rc 0:
```text
declaration: ПРОЕКТ-ПРЕДПОСЫЛОК:{"projectId": "toy-project", "repoId": "toy-product", "canonicalRemote": "/tmp/dev-harness-verify/critic122-cax228yj/station-origin.git"}
rc: 0 output: PREDPOSYLKI_OK secrets=1 variables=0 environments=0 settings=0
v1
  gh: ["secret", "list", "-R", "/tmp/dev-harness-verify/critic122-cax228yj/station-origin.git"]
 tag: 0
```

Соседний мир с внешней декларацией и выбором станции:

```sh
python3 -c 'import importlib.util,pathlib,tempfile,json,os; p=pathlib.Path("fixtures/workshop_project/ci_proekta_122/roots_probe.py").resolve(); s=importlib.util.spec_from_file_location("probe",p); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); t=tempfile.TemporaryDirectory(prefix="critic122-",dir="/tmp/dev-harness-verify"); b=pathlib.Path(t.name); station,product,ctx,origin=m.world(b,m.TREE,"station-explicit"); target=station/m.TARGET; target.write_text(target.read_text().replace("ПРОЕКТ-ПРЕДПОСЫЛОК: ","ПРОЕКТ-ПРЕДПОСЫЛОК:")); m.commit(station); c=json.loads(ctx.read_text()); c["subject"]["blob"]=m.git(station,"rev-parse","HEAD:"+m.TARGET); ctx.write_text(json.dumps(c)); env=dict(os.environ,PATH=str(b/"bin")+":"+os.environ["PATH"]); env.pop("HARNESS_PROJECT_LAYER_ROOT",None); r=m.run(["python3",p.parent/"roots_model.py",station,m.TARGET,ctx],env=env); print("declaration:",next(x for x in target.read_text().splitlines() if x.startswith("ПРОЕКТ-ПРЕДПОСЫЛОК"))); print("rc:",r.returncode,"output:",r.stdout,r.stderr,"gh:",(b/"calls.jsonl").read_text() if (b/"calls.jsonl").exists() else "none","tag:",m.run(["git","-C",station,"rev-parse","--verify",m.TAG]).returncode)'
```

Сырой вывод, команда rc 0:
```text
declaration: ПРОЕКТ-ПРЕДПОСЫЛОК:{"projectId": "toy-project", "repoId": "toy-product", "canonicalRemote": "/tmp/dev-harness-verify/critic122-m5nx1zh2/product-origin.git"}
rc: 0 output: PREDPOSYLKI_OK secrets=1 variables=0 environments=0 settings=0
v1
  gh: ["secret", "list", "-R", "/tmp/dev-harness-verify/critic122-m5nx1zh2/station-origin.git"]
 tag: 0
```

Повторный поиск обусловлен дельтой: объявление стало необязательным при ROOT, поэтому ошибочная классификация невалидного объявления как отсутствующего отключает обязательную сверку. Оба наблюдения — один класс причины.

## Проверки и граница

`bash scripts/check_sdacha.sh . contracts/122-ci-proekta.md --run` → rc 0, `СДАЧА: лист зелёный (двери=10 карта=17/17 дельта=5)`. Дверь исполнила указанные в листе команды, включая model, stabs, оба repo honest-red, r12 и pre_critic, и сверила их rc; отдельного сырого вывода этих подкоманд она не печатает. По коду неизменённой батареи Г2 `red_ci_proekta_122.sh:77-78,951-952` строка `- secret` сохраняется и есть клетка необъявленного секрета станции. `git log -1` OBJECT: строка `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/122-ci-proekta.md ...` в первой колонке тела, с путём и причиной; её содержание совпадает с обозначенным в задании словом. Дельта модели угроз не расширяет остаток поставщика/гонки. Живые gh и CI не запускались.

## Карта классов

К-01: чисто — `bash scripts/check_sdacha.sh . contracts/122-ci-proekta.md --run`, rc 0; STABS в `roots_probe.py`, Н-39.
К-02: блок — повреждённый маркер объявленной связи считается отсутствием.
К-03: чисто — без изменений с вызова Crit122V6b; вход `git diff 87986725f1 2de882ec83`.
К-04: чисто — вход дельта `87986725f1..2de882ec83`, зоны `contracts/122-ci-proekta.md`.
К-05: чисто — вход приёмка v6 `contracts/122-ci-proekta.md:161-170`.
К-06: чисто — вход `station-unresolved`, `gh-error` в `roots_probe.py`.
К-07: блок — исполняемая модель принимает невалидную декларацию в мире станции.
К-08: блок — батарея не отличает ошибку распознавания маркера от допустимого отсутствия.
К-09: блок — невалидный разделитель декларации не отвергается.
К-10: блок — наблюдены gh станции и тег при невалидной внешней декларации.
К-11: блок — HEAD-источник прочитан, но его повреждённая декларация отброшена.
К-12: чисто — вход `roots_model.py:100-103`, прежняя схема projectIdentity; блок относится к распознаванию строки до валидатора.
К-13: чисто — вход инвентарь фикстуры `roots_probe.py:144-157,235-247`, только имена.
К-14: чисто — вход `mono`, `mono-explicit`, `mono-declared`, `mono-declared-explicit` в `roots_probe.py`.
К-15: чисто — вход словари CASES и STABS `roots_probe.py:22-70`; отдельных новых счётных расхождений дельты не установлено.
К-16: блок — при невалидной декларации может быть выбран инвентарь другого проекта.
К-17: н/п — механизм харнесса, продуктовый бриф архитектуры 188 не заявлен.
