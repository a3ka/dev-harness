accept
OBJECT=99ba0835f8e76e689e855e01114d7a7c09210a96
СУД: repo=dev-harness; предмет=122; фаза=контракт v6; роль=critic; вызов=один узкий по слову владельца 2026-11-19 через консультанта 10:26 UTC; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit122V6e; модель-факт=openai-codex/gpt-6.1-terra; SHA=99ba0835f8e76e689e855e01114d7a7c09210a96; предыдущий=Crit122V6c FAIL; исключение=адресное слово владельца, при FAIL к владельцу.

Слово владельца: «122: ещё один узкий критик на 5928d58b63; скоуп — только блок К-02 Crit122V6c в границах contracts/122:153 (повреждение разделителя или регистра маркера, единственность кандидатов) и зависимый регресс до конца; маркер внутри код-блока — вне предмета, FAIL Crit122V6d по этому основанию не исполняется; задание критику — с дословным скоупом слова, без добавленных примеров; при FAIL — ко мне.»

Предмет содержимого — 5928d58b63a261be0d1a7c379e57b1007070cb44: `git diff --stat 5928d58b63 99ba0835f8` rc 0, единственный файл `verdicts/critic/contracts-122-v6.md`; контракт и батарея идентичны OBJECT. `git diff --stat 2de882ec83 5928d58b63 -- contracts/122-ci-proekta.md fixtures/workshop_project/ci_proekta_122` rc 0: 5 файлов, +103/−50. Маркер внутри код-блока не судился. Н-39: привязки стаба к клетке — исполняемый словарь STABS в коде, не проза контракта.

## Исполненные проверки

Рабочий каталог `/tmp/dev-harness-verify/Crit122V6e/repo`, SUBJECT=122. Все приведённые rc — фактические; реальные gh/продукт не вызывались.

- `bash scripts/check_sdacha.sh . contracts/122-ci-proekta.md --run` → rc 0, сырой итог `СДАЧА: лист зелёный (двери=11 карта=17/17 дельта=7)`. Дверь исполнила команды листа и сверила заявленные rc, собственный вывод подкоманд она скрывает.
- `bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model` → rc 0: `ИТОГ 122 (model): клеток 74, зелёных 74, красных 0`; `ROOTS122 TOTAL=37 GREEN=37 RED=0`.
- `bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --stabs` → rc 0: `ROOTS122 STABS=22 CAUGHT=22`.
- `bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --repo .` → rc 1: `ИТОГ 122 (red): клеток 74, зелёных 54, красных 20`; `ROOTS122 TOTAL=37 GREEN=4 RED=33`. Это именованное honest-red до реализации, не отказ сдатчика.
- `bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --repo . --cell r13` → rc 1: `ROOTS122 TOTAL=10 GREEN=0 RED=10`; например исходные атаки без пробела на mono и станции дали субъект rc 0, вызов gh и тег, вместо `project-workflow-rashozhdenie` — ожидаемое красное до реализации.
- `bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r13` → rc 0: `ROOTS122 TOTAL=10 GREEN=10 RED=0`. Для каждой из десяти клеток сырой `EVIDENCE`: `subject_rc=1 gh=[] tag_rc=128 unchanged=True`; раннер отдельно проверяет причину `project-workflow-rashozhdenie`.
- `bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p11` → rc 0, `ИТОГ 122 (--cell p11): зелёных 9, красных 0`; включая `p11-station-sekret-ne-perechislen: rc=1 want=1 причина=sekrety-ne-perechisleny: PILOT_DEMO_CODE ЗЕЛЁНАЯ`. Фабрика `red_ci_proekta_122.sh:77-91` сохраняет машинную строку `- secret PILOT_DEMO_CODE`.
- Дополнительно существующий честный мир `mono-declared` с повреждением того же разделителя, что у Crit122V6c, запущен без аргумента контекста через настоящую модель и фабрику: команда ниже rc 0, сырой вывод `subject_rc: 1 output: ОТКАЗ: project-workflow-rashozhdenie`, `gh: [] unchanged: True`.

```sh
python3 -c 'import importlib.util,pathlib,tempfile,os; p=pathlib.Path("fixtures/workshop_project/ci_proekta_122/roots_probe.py").resolve(); s=importlib.util.spec_from_file_location("probe",p); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); t=tempfile.TemporaryDirectory(prefix="crit122-"); b=pathlib.Path(t.name); station,product,ctx,origin=m.world(b,m.TREE,"mono-declared"); target=station/m.TARGET; target.write_text(target.read_text().replace("ПРОЕКТ-ПРЕДПОСЫЛОК: ","ПРОЕКТ-ПРЕДПОСЫЛОК:")); m.commit(station); before=m.snapshot(station); env=dict(os.environ,PATH=str(b/"bin")+":"+os.environ["PATH"]); env.pop("HARNESS_PROJECT_LAYER_ROOT",None); r=m.run(["python3",m.HERE/"roots_model.py",station,m.TARGET],env=env); calls=b/"calls.jsonl"; print("subject_rc:",r.returncode,"output:",r.stdout+r.stderr,"gh:",calls.read_text() if calls.exists() else "[]","unchanged:",before==m.snapshot(station))'
```

`git show -s --format=%B 5928d58b63` → rc 0: строка `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/122-ci-proekta.md — слово владельца 2026-11-18 ~21:58 UTC: v+1 122 узко — в ноге заморозки проверка предпосылок получает корень проекта (из project_workflow-контекста предмета, с проверкой соответствия проекту), запись тега/вердикта/реестра остаётся в корне станции; секрет PILOT_DEMO_CODE не копировать, `- secret` в 149 не заменять; суд по общему порядку; затем freeze 149 со словом №16`. Сверена с `scripts/check_charter.sh:23-36`: первая колонка, путь, непустая причина, тот же коммит; по содержанию не шире указанного слова.

## Карта классов

К-01: чисто — `bash scripts/check_sdacha.sh . contracts/122-ci-proekta.md --run`, rc 0; Н-39, STABS в коде.
К-02: чисто — вход `contracts/122-ci-proekta.md:153`, r13 model rc 0 и неявный корень выше; класс Crit122V6c закрыт в указанной границе.
К-03: н/п — без изменений с Crit122V6c, вне узкого поиска.
К-04: н/п — без изменений с Crit122V6c, вне узкого поиска.
К-05: чисто — вход приёмка `contracts/122-ci-proekta.md:161-170`, сдаточная команда rc 0.
К-06: чисто — вход `station-unresolved`, `gh-error` в ROOTS122, полный `--model` rc 0; невалидный контроль стаба определяется кодом `roots_probe.py`.
К-07: чисто — полный `--model` rc 0, 74/74 и ROOTS122 37/37; repo до реализации rc 1.
К-08: чисто — `--stabs` rc 0, 22/22; привязки STABS в `roots_probe.py`.
К-09: чисто — вход r13: разделитель, регистр, смешанный повтор; `--model --cell r13` rc 0.
К-10: чисто — вход наблюдение r13: rc, причина, gh, тег и snapshots, `--model --cell r13` rc 0.
К-11: чисто — вход `roots_probe.py:145-161`: настоящий HEAD и обновлённый subject.blob, `--model --cell r13` rc 0.
К-12: н/п — существующий JSON-канон не менялся, вне узкого поиска.
К-13: чисто — вход `roots_probe.py:185-201,271-278`: gh-журнал несёт аргументы и имена, не значения; полный `--model` rc 0.
К-14: чисто — вход `mono`, `mono-explicit`, `mono-declared`, `mono-declared-explicit` в ROOTS122; полный `--model` rc 0.
К-15: чисто — полный `--model` rc 0: 74/74 и 37/37; `--stabs` rc 0: 22/22; `--model --cell r13` rc 0: 10/10.
К-16: чисто — вход `contracts/122-ci-proekta.md:153`, проверка отказа до gh и записи в r13; `--model --cell r13` rc 0.
К-17: н/п — продуктовый бриф архитектуры 188 не заявлен; вне узкого поиска.
