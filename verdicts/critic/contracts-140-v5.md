accept

СУД: repo=dev-harness; предмет=140; фаза=исправительный (круг после FAIL Crit140Fix6); роль=critic; вызов=7; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit140Fix7; модель-факт=openai-codex/gpt-6.1-terra; SHA=3d82fe0f8ecc9f3a8dcbb9b3785192dac939d880; предыдущее=verdicts/critic/contracts-140-v5-r2.md; исключение=слово владельца 22:32 «140 ещё круг».

Основание scoped-поиска: слово владельца разрешает закрытие legacy-источника обоих путей, зависимый регресс и мутации новых клеток. `bash scripts/models_actual.sh --tsv --bind --session Crit140Fix7` rc 0: две строки `critic openai-codex/gpt-6.1-terra allowed Crit140Fix7 3d82fe0f8ecc9f3a8dcbb9b3785192dac939d880`. Автор кандидата — architect, не этот судья.

Предыдущий блок закрыт: в `klass_riska` и проверка наличия, и чтение legacy-реестра используют переданный репозиторий владельца. Путь прямого и переданного продукта предъявлен отдельно, при противоположной станции и без станционной записи; контроль станции — отдельно. Отсутствие файла продукта по-прежнему закрывает допуск даже при наличии записи станции: p44/p45 различают полную подмену двух корней. Удаление связей read-only мутации с этими входами корректно: операция чтения при отсутствующем файле владельца недостижима; s81 остаётся привязан к конфликтующим реестрам p39/p40/p42/p43, а s79 — к p44/p45.

## Карта классов

К-01: чисто — `check_sdacha --run` rc 0, двери=14 карта=17/17 дельта=3.
К-02: чисто — вход: слово владельца 22:32, p38–p47 и собственная проба прежнего p01 ниже; источник реестра — владелец.
К-03: чисто — без изменений с вызова 6.
К-04: чисто — без изменений с вызова 6.
К-05: чисто — без изменений с вызова 6.
К-06: чисто — без изменений с вызова 6.
К-07: чисто — вход: честный p01 и новые p38–p47; реальная production до реализации не заявлена зелёной.
К-08: чисто — вход: s79–s81 и собственные мутации ниже; прежние связи проверяются `--stabs`.
К-09: чисто — вход: p38–p47, оба пути, две полярности, отсутствие и конфликт станции, отсутствие файла владельца и станционные контроли.
К-10: чисто — без изменений с вызова 6.
К-11: чисто — без изменений с вызова 6.
К-12: чисто — без изменений с вызова 6.
К-13: н/п — без изменений с вызова 6.
К-14: чисто — вход: честная проба p01, p38/p41 при отсутствии записи станции, p39/p42 при противоположной станции и p46/p47 как станционный контроль.
К-15: чисто — `jq` по source.json: cases=172 mutants=82 bindings=159 carriers=87 legacy_cases=10.
К-16: чисто — вход: инвариант 6, `klass_riska` и p38–p47; при отсутствии привязки владельца допуск закрыт.
К-17: н/п — без изменений с вызова 6.

## Прогоны

Первой после checkout OBJECT выполнена `bash scripts/check_sdacha.sh "$PWD" contracts/140-odin-agent-na-predmet.md --run`, rc 0:
```text
СДАЧА: лист зелёный (двери=14 карта=17/17 дельта=3)
```
Команда исполнила все 14 дверей листа, включая `--owner-before`, `--owner-check`, `--model`, `--stabs` и precision. Станционный S и реальный pre_judge runtime не исполнялись: это приёмка после реализации.

Независимый счёт `jq '{cases:(.kejsy|length), mutants:(.stab_vhod|length), bindings:([.stab_vhod[]|length]|add), carriers:(.nositeli|length), legacy_cases:([.kejsy|keys[]|select(startswith("p3") or startswith("p4"))|select(contains("legacy"))]|length)}' fixtures/workshop_project/odin_agent_140/source.json` rc 0: 172, 82, 159, 87, 10 соответственно.

## Собственная проба и мутации

Одноразовая копия; временный скрипт не входит в вердиктный коммит. Команда `TMPDIR="$PWD/tmp/critic140fix7" PYTHONDONTWRITEBYTECODE=1 python3 tmp/critic140fix7/attack.py`, rc 0. Исходный код:
```python
import sys, types, tempfile
from pathlib import Path
sys.path.insert(0, str(Path('fixtures/workshop_project/odin_agent_140').resolve()))
import probe as p
src=Path('fixtures/workshop_project/odin_agent_140/produkt_140.py').read_text()
old="'# old frozen without risk declaration\\n' if legacy else 'КЛАСС РИСКА: '+risk+'\\n'"
assert src.count(old)==1
src=src.replace(old,"'# old frozen without risk declaration\\n'",1)
assert src.count('        if legacy:\n')==1
src=src.replace('        if legacy:\n','        if True:\n',1)
mod=types.ModuleType('critic_legacy_input')
exec(compile(src,'critic_legacy_input','exec'),mod.__dict__)
p.produkt_140=mod
cases=p.kejsy()
print('R2_PROBE p01',repr(p.progon(p.MODEL,'p01-produktovyj-start',cases['p01-produktovyj-start']['run'])),flush=True)
import produkt_140
p.produkt_140=produkt_140
cases=p.kejsy()
base=p.MODEL.read_text()
attacks=[
 ('check-owner','[ -f "$wt/registry/risk-legacy.tsv" ]','[ -f "$REPO/registry/risk-legacy.tsv" ]',['p38-legacy-prjamoj-obychnyj','p41-legacy-peredannyj-obychnyj']),
 ('read-owner',"' \"$wt/registry/risk-legacy.tsv\")","' \"$REPO/registry/risk-legacy.tsv\")",['p39-legacy-prjamoj-konflikt','p42-legacy-peredannyj-konflikt']),
 ('class-swap','обычный)  val=\'obychnyj\' ;;','обычный)  val=\'risikovyj\' ;;',['p39-legacy-prjamoj-konflikt','p42-legacy-peredannyj-konflikt']),
 ('both-roots','[ -f "$wt/registry/risk-legacy.tsv" ]','[ -f "$REPO/registry/risk-legacy.tsv" ]',['p44-legacy-prjamoj-net-zapisi','p45-legacy-peredannyj-net-zapisi']),
]
with tempfile.TemporaryDirectory(dir='tmp/critic140fix7') as d:
 for name,old,new,cells in attacks:
  assert base.count(old)==1,(name,base.count(old))
  text=base.replace(old,new,1)
  if name=='both-roots':
   x="' \"$wt/registry/risk-legacy.tsv\")"; y="' \"$REPO/registry/risk-legacy.tsv\")"
   assert text.count(x)==1
   text=text.replace(x,y,1)
  door=Path(d)/f'{name}.sh'; door.write_text(text)
  for cell in cells:
   result=p.progon(door.resolve(),cell,cases[cell]['run'])
   print(name,cell,repr(result),flush=True)
   if not result: sys.exit(1)
print('ATTACKS_CAUGHT',flush=True)
```
Сырой вывод:
```text
R2_PROBE p01 []
check-owner p38-legacy-prjamoj-obychnyj ['legacy-reviewer: rc 1 ≠ 0; stderr=ОТКАЗ: KLASS_RISKA_NET: предмет 197: класс риска неоднозначно определён (neodnoznachno); файлы: 197-product.md', "legacy-START: строки START {'holder': 'Judge197', 'object': '0cfc6337f2573b1f4f4219f36c8ed5c555e8cd11'} нет в учёте"]
check-owner p41-legacy-peredannyj-obychnyj ['legacy-reviewer: rc 1 ≠ 0; stderr=ОТКАЗ: KLASS_RISKA_NET: предмет 197: класс риска неоднозначно определён (neodnoznachno); файлы: 197-product.md', "legacy-START: строки START {'holder': 'Judge197', 'object': '0cfc6337f2573b1f4f4219f36c8ed5c555e8cd11'} нет в учёте"]
read-owner p39-legacy-prjamoj-konflikt ['legacy-reviewer: rc 1 ≠ 0; stderr=ОТКАЗ: ADVERSARIJ_DO_REVJUERA: предмет 197 рисковый, завершённого адверсария в учёте нет — ревьюер раньше адверсария запрещён', "legacy-START: строки START {'holder': 'Judge197', 'object': 'b30d5507316958219ce58860a288dff9ae20ee31'} нет в учёте"]
read-owner p42-legacy-peredannyj-konflikt ['legacy-reviewer: rc 1 ≠ 0; stderr=ОТКАЗ: ADVERSARIJ_DO_REVJUERA: предмет 197 рисковый, завершённого адверсария в учёте нет — ревьюер раньше адверсария запрещён', "legacy-START: строки START {'holder': 'Judge197', 'object': 'b30d5507316958219ce58860a288dff9ae20ee31'} нет в учёте"]
class-swap p39-legacy-prjamoj-konflikt ['legacy-reviewer: rc 1 ≠ 0; stderr=ОТКАЗ: ADVERSARIJ_DO_REVJUERA: предмет 197 рисковый, завершённого адверсария в учёте нет — ревьюер раньше адверсария запрещён', "legacy-START: строки START {'holder': 'Judge197', 'object': '0cffcd3d638d256707f1c05a58120e2519e5f137'} нет в учёте"]
class-swap p42-legacy-peredannyj-konflikt ['legacy-reviewer: rc 1 ≠ 0; stderr=ОТКАЗ: ADVERSARIJ_DO_REVJUERA: предмет 197 рисковый, завершённого адверсария в учёте нет — ревьюер раньше адверсария запрещён', "legacy-START: строки START {'holder': 'Judge197', 'object': '0cffcd3d638d256707f1c05a58120e2519e5f137'} нет в учёте"]
both-roots p44-legacy-prjamoj-net-zapisi ['именованный-отказ: rc 0 ≠ 1; stderr=', 'причина: причины KLASS_RISKA_NET нет в stderr: ', 'отказ legacy изменил состояние']
both-roots p45-legacy-peredannyj-net-zapisi ['именованный-отказ: rc 0 ≠ 1; stderr=', 'причина: причины KLASS_RISKA_NET нет в stderr: ', 'отказ legacy изменил состояние']
ATTACKS_CAUGHT
```
