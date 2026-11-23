FAIL
OBJECT=9f73d265adf442f785f17c9770216f893f002b1f
СУД: репо=dev-harness; предмет=157; роль=adversary; вызов=5 (узкий, дополнительный по слову владельца); фаза=реализация; модель-план=openai-codex/gpt-6.1-terra; модель-факт=openai-codex/gpt-6.1-terra; предыдущий=verdicts/adversary/contracts-157-impl-v4.md (FAIL); класс риска=рисковый

## Позитивный контроль

На неизменённом OBJECT `TMPDIR=/tmp/dev-harness-verify/scratch-adv157s npm run check:spawn-guard-157-family-selftest` → rc=0, `KLETKI subject 59 KRASNYH 0`. В частности, `project-batch-n6`, `project-batch-n7`, `project-batch-n8`, `project-isolated-batch-first`, `-second`, `-last`, `-all` — `OK`. Для N=6 префикс ролей — вход вызова 4 (architect, implementer, critic, adversary, reviewer, orchestrator); проверяются фактическое событие установленного хука и аргументы двери.

Независимый от выбора схемы самой проверкой контроль клетки `project-isolated-batch-first` с принудительным `carries_isolated=True` на том же коде → `honest rc=0`; событие содержит флаги `[true,false,false]`. Использован `case()` с подложной дверью, проверяющей сериализованное событие, а не реальная дверь.

## Атака

На коде OBJECT, не на историческом `cf4054e8e`, по одному создавались временные копии с единственной заменой через `probe.mutation(source, name)` (сама функция проверяет кратность якоря = 1), запускался `probe.run()` и копия удалялась. Команда: `TMPDIR=/tmp/dev-harness-verify/scratch-adv157s PYTHONDONTWRITEBYTECODE=1 python3 /tmp/dev-harness-verify/scratch-adv157s/trials.py`; временный драйвер импортировал `probe.py`, для каждого имени записывал изменённый исходник во временный файл и передавал его содержимое в `run`. Сырые rc ниже — `int(bool(failed_cells))`, rc процесса драйвера 0:

```text
n6-constant-five rc=1: n6,n7,n8
n7-odd-middle rc=1: n7,n8
n8-even-middle rc=1: n8
skip-last-six-plus rc=1: n6,n7,n8
constant-2 rc=1: 25 красных
constant-3 rc=1: 7 красных
constant-4 rc=1: 5 красных
constant-5 rc=1: 3 красных
constant-6 rc=1: 2 красных
constant-7 rc=1: 1 красная
first-only rc=1: 19 красных
last-only rc=1: 19 красных
```

`n6` и подобные сокращения — метки `project-batch-n6` и т. д. Позиционные мутанты краснеют в ожидаемых batch-клетках с `isolated:true`, честные клетки зелёные. `constant-2` также краснит изоляционные тройки. Предыдущие конкретные batch-блоки 3/4 различены.

**БЛОКИРУЕТ — оракул 157 выключает проверку перенесённого isolated по тексту самого проверяемого хука.** `probe.py:275-277,416` решает включение поля в ожидаемое событие по наличию точной строки `type TaskItem` в субъекте; `probe.py:511` по ней же включает стабы изоляции. Это не независимое определение версии испытуемого OBJECT. Замена уже имеющейся нормализации `.omp/extensions/spawn-guard.ts:188-205` старой формой, без объявления и записи `isolated`, становится для W «старой схемой» и проходит все клетки. Это не добавленный фильтр: удалены две части одного перенесённого механизма 199, сохраняя нормализацию остальных полей и вызов двери 140.

ОБЯЗАТЕЛЬСТВО: контракт 157, инвариант 2 — полный нормализованный список каждого принятого batch поступает в дверь; на этом OBJECT состав события включает реальный флаг isolated (контракт 199, инвариант 1; узкое задание прямо требует совместимость после переноса 199/140).

СОСТОЯНИЕ: штатный `input.tasks` из трёх установленных ролей `architect`, `implementer`, `architect`, первое поле `isolated:true`, другие отсутствуют, нормальная проектная сессия. Это явно поддерживаемая клетка `project-isolated-batch-first`. Ошибочный механизм — удаление существующего проноса поля вместе с его типом, а не случайно добавленный искусственный отказ.

НАБЛЮДЕНИЕ: в одноразовой копии одного блока `TaskItem`/`taskItems` заменены `; isolated: boolean` на пустоту и строка `      isolated: o.isolated === true,` удалена; кратность блока-якоря 1. Команда `TMPDIR=/tmp/dev-harness-verify/scratch-adv157s PYTHONDONTWRITEBYTECODE=1 python3 /tmp/dev-harness-verify/scratch-adv157s/schema.py` запустила `probe.run(mutant, 'drop-isolated')` → `KLETKI drop-isolated 59 KRASNYH 0`, rc=0. В той же установке независимый от текста субъекта контроль `case(... carries_isolated=True)` → `drop-isolated rc=1 AssertionError(('project-isolated-batch-first', 'door did not judge every batch item'))`: событие мутанта содержит все три `agent/name/task`, но вообще не содержит ни одного `isolated`; честное событие содержит `[true,false,false]`. В реальной двери отсутствие поля рабочего рассматривается как false, поэтому рабочий с реальным isolated:true ошибочно получает отказ вместо разрешения; это следствие правил двери, а не результат исполнения реальной двери в данной клетке.

Минимальное воспроизведение, после установки TMPDIR как выше (временный мир удаляется автоматически):

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -c '
import importlib.util, pathlib, tempfile
f=pathlib.Path("fixtures/workshop_project/spawn_guard_157/probe.py").resolve()
spec=importlib.util.spec_from_file_location("probe",f); p=importlib.util.module_from_spec(spec); spec.loader.exec_module(p)
s=p.SOURCE.read_text(); a=s.index(p.ISOLATED_TYPE); b=s.index("\n// Именованная причина",a); old=s[a:b]; assert s.count(old)==1
new=old.replace("; isolated: boolean","").replace(p.ISOLATED_SEAM+"\n",""); m=s.replace(old,new,1)
print("W_RC",int(bool(p.run(m,"drop-isolated"))))
with tempfile.TemporaryDirectory() as d:
 try:
  p.case(pathlib.Path(d),m,"project-isolated-batch-first",("dev-harness-projects","complior-back","home"),"dev",p.TAIL,("dev-harness-projects","complior-back","state"),"allow",batch_roles=p.WORKERS,isolated=(True,p.OMITTED,p.OMITTED),carries_isolated=True)
  print("INDEPENDENT_RC",0)
 except AssertionError as e: print("INDEPENDENT_RC",1,repr(e))
'
```

КЛАСС ПРИЧИНЫ: зависимость ожидаемой схемы и набора изоляционных стабов от испытуемого текста. ПРОИСХОЖДЕНИЕ: дельта совместимости 199/140. КЛАСС: К-10/К-11. Закрывающее свойство: режим проверки актуального субъекта обязан независимо требовать поле и ловить его удаление; историческая модель может отдельно проверяться по своей схеме. Это блок ложной достаточности проверки, не утверждение, что честный OBJECT уже теряет флаг.

Перенос сверялся по `git show 0c6416bd0 -- .omp/extensions/spawn-guard.ts` и поиском `isolated|ZAMOK140` по `.omp/extensions`: нормализация и блок двери присутствуют в `spawn-guard.ts`, другого совпадения реализации среди расширений не обнаружено.

## Регресс

- `python3 fixtures/workshop_project/spawn_guard_157/probe.py --stabs` → rc=0, `STABY 46 NEPOIMANNYH 0`; включает живой isolation control на честном OBJECT и его позиционные стабы.
- CI-строка 140: `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model` → rc=0, `MODEL_KLETKI 244 KRASNYH 0`. Это модель двери, не проверка установленной двери.
- `bash -n scripts/zamok_predmeta.sh fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh && node --check .omp/extensions/spawn-guard.ts` → rc=0. Node непосредственно исполняет TypeScript в этом репозитории; отдельного tsc-проекта здесь не предъявлено. Это синтаксис, не статическая типизация.
- Шаг 199 в `registry/ci-steps.tsv` не найден. Его standalone-батарея не запускалась: она жёстко создаёт миры в `/tmp/dev-harness-s199.*` и `/tmp/dev-harness-fakehome-s199.*`, а разрешение владельца относится только к названному scratch. CI-строка 140 запущена как записана.

## Блоки

Один блок: самоопределение схемы проверяемым хуком позволяет зелёную потерю isolated на достижимом batch. Блок касается доказательства совместимости, не предыдущих конкретных пропусков N=6–8, которые пойманы.

## НЕ ЗАЩИЩАЕТ

Восемь принятых контрактом остаточных форм путей не атакованы по прямой границе задания; классы остатка с ловцом adversary в контракте не назначены. Диапазон batch N≥9 оставлен reviewer по коду, как указано в `probe.py`; новый полный поиск не проводился. 140-модель и подложная дверь не подтверждают работу реальной двери в этом эксперименте.

## Советы

При исправлении сохранить исторический `--model` отдельно от фиксированного независимого ожидания для живого субъекта и адресно испытать удаление поля и типа на OBJECT; стабы к клеткам привязывает architect кодом (Н-39).
