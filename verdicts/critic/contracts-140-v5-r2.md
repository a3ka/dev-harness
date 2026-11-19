FAIL

СУД: repo=dev-harness; предмет=140; фаза=исправительный; роль=critic; вызов=6/2; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit140Fix6; модель-факт=openai-codex/gpt-6.1-terra; SHA=1ab36e58722a9b170cd2c26c4128e01aa13bdb93; предыдущий=verdicts/critic/contracts-140-v5.md; исключение=слово владельца 18:54 и 19:49.

Основание дополнительного поиска: слово владельца разрешает проверку блока К-02/К-16, зависимого регресса, мутации и полную карту. Фактическая модель и OBJECT сверены `bash scripts/models_actual.sh --tsv --bind --session Crit140Fix6`, rc 0; две строки `critic openai-codex/gpt-6.1-terra allowed Crit140Fix6 1ab36e58722a9b170cd2c26c4128e01aa13bdb93`. Автор последней правки architect, не этот судья. `pre_judge prepare` rc 0 — запись оркестратора в history://Main, не собственный прогон.

БЛОКИРУЕТ contracts/140-odin-agent-na-predmet.md:68 — источник legacy-класса у продуктового владельца не перенесён вместе с источником frozen.
ОБЯЗАТЕЛЬСТВО: старый frozen без декларации допускает blob-привязку только `registry/risk-legacy.tsv` владельца; риск обоих владельцев определяется из закреплённого frozen, не из другого репозитория.
СОСТОЯНИЕ: поддержанный прямой продуктовый START и корректный собственный annotated frozen/pin продукта; frozen-файл старый, без декларации, его blob записан как обычный в `registry/risk-legacy.tsv` продукта. В станции такой записи нет. Это соседняя ветвь обязательной операции `klass_riska` при изменённом корне владельца, а не добавленный запрет.
НАБЛЮДЕНИЕ: `fixtures/workshop_project/odin_agent_140/model/zamok_predmeta.sh:321-322` читает legacy-файл через `$REPO` станции, хотя frozen и blob читает через `$wt` владельца. Собственная проба ниже на неизменённой модели даёт `KLASS_RISKA_NET` вместо допуска; при конфликтующей записи станции возможна подмена источника класса. Последнее — [INFERENCE] из вызова awk, отдельно не прогонялось. `W --model` при этом зелён: продуктивный legacy-мир не предъявлен. Прежний блок закрыт для обычных деклараций и обеих полярностей, но не для обязательной blob-ветви.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: при обоих путях, прямом и переданном, источником blob-привязки является реестр соответствующего владельца; различающие клетки предъявляют продуктовый legacy-класс и отдельный станционный контроль, не ослабляя fail-closed.
ПРОИСХОЖДЕНИЕ: узкое-закрытие
КЛАСС: К-02 / К-16

Арбитр: повтор причины Crit140Combined — выбор владельца источника риска; предмет спора — legacy-ветвь после переноса frozen. По адресному слову владельца 18:54 при новом FAIL — к владельцу; новых вызовов не назначаю.

## Карта классов

К-01: чисто — `check_sdacha --run` rc 0, двери=14, карта=17/17, дельта=2; precision и pre_critic входят в исполненные двери.
К-02: блок — legacy-реестр не владельца.
К-03: чисто — вход: прежние 104/167/197/199 и инварианты 140 сохранены в контракте; `--model` 162/162.
К-04: чисто — вход: зоны contracts/140:90–96, дельта последнего автора только сдаточный лист architect.
К-05: чисто — вход: критерии contracts/140:78–86 связывают утверждения с W/S и rc; 14 дверей листа исполнены.
К-06: чисто — вход: contracts/140:77–84 различает rc 1 предметной красноты и rc 2 среды; `--stabs` rc 1, не ошибка оракула.
К-07: чисто — `--model` rc 0, 162 клетки; production и станция до реализации не заявляются зелёными.
К-08: чисто — `--stabs` SVJAZI 143, MODEL_ZHIVYH 0; собственные три мутации ниже пойманы адресными клетками.
К-09: блок — отсутствует различающая продуктовая legacy-ветвь владельца.
К-10: чисто — вход: p03 проверяет фактическую запись PEREDACHA, сохранность START и веток; q21–q23 судят runtime-эффект.
К-11: чисто — вход: probe.py фиксирует пины и ожидания до вызова субъекта, p03 сравнивает внешнее состояние.
К-12: чисто — вход: Git plumbing для frozen и JSON Schema для receipt; скрипты модели используют Git blob/ref.
К-13: н/п — секретные входы и выдача секретов предметом не заявлены.
К-14: чисто — `--model` rc 0: p34/p35 обе полярности, q23 честный эквивалент runtime, q29/q30 отдельная станция.
К-15: чисто — собственные прогоны: MODEL_KLETKI 162 KRASNYH 0; SVJAZI 143; MODEL_ZHIVYH 0; SUBJEKT_KRASNO 62.
К-16: блок — legacy-реестр не владельца.
К-17: н/п — дельта не меняет схему операций/writers архитектуры 188; вход: лист сдачи и контракт 140.

## Прогоны

Первым после checkout OBJECT: `bash scripts/check_sdacha.sh "$PWD" contracts/140-odin-agent-na-predmet.md --run` → rc 0:
```
СДАЧА: лист зелёный (двери=14 карта=17/17 дельта=2)
```
Отдельный прогон W `--model` rc 0: `MODEL_KLETKI 162 KRASNYH 0`; W `--owner-check` rc 0: `OWNER140_FAILURES 0`; W `--stabs` rc 1: `SVJAZI 143`, `MODEL_ZHIVYH 0`, `SUBJEKT_KRASNO: 62` — ожидаемо красная ещё не реализованная дверь. Матрица s77/s78 ловит обе полярности, но не D30. Станция и реальный pre_judge runtime после реализации не выполнялись.

## Собственные атаки

Все временные скрипты и миры — внутри одноразовой копии; ниже полный код для воспроизведения. Команда `TMPDIR="$PWD/tmp/critic140" PYTHONDONTWRITEBYTECODE=1 python3 tmp/critic140/attack.py` rc 0; скрипт:
```python
import sys
from pathlib import Path
sys.path.insert(0, str(Path('fixtures/workshop_project/odin_agent_140').resolve()))
import probe as p
base = p.MODEL.read_text()
attacks = [
 ('direct-owner', 'risk_repo="$r_wt"', 'risk_repo="$REPO"', ['p01-produktovyj-start']),
 ('receipt-commit', '[ "$(git -C "$P_WT" rev-parse --verify "$pobj^{commit}" 2>/dev/null)" = "$pcommit" ]', 'true', ['p36-produkt-frozen-commit-podmenen']),
 ('frozen-not-object', 'kr="$(klass_riska "$sv" "$risk_repo" "$P_FROZEN")"', 'kr="$(klass_riska "$sv" "$risk_repo" "$obj")"', ['p07-kontrakt-kandidata-prioritet', 'p32-frozen-obychnyj-object-riskovyj']),
]
cases = p.kejsy()
for name, old, new, cells in attacks:
 assert base.count(old) == 1, (name, base.count(old))
 door = Path('tmp/critic140') / (name + '.sh')
 door.write_text(base.replace(old, new, 1))
 for cell in cells:
  result = p.progon(door.resolve(), cell, cases[cell]['run'])
  print(name, cell, repr(result), flush=True)
  if not result: sys.exit(1)
print('ATTACKS_CAUGHT', flush=True)
```
Сырой вывод:
```
direct-owner p01-produktovyj-start ['суд: rc 1 ≠ 0; stderr=ОТКАЗ: KLASS_RISKA_NET: предмет 197: закреплённый frozen недоступен']
receipt-commit p36-produkt-frozen-commit-podmenen ['именованный-отказ: rc 0 ≠ 1; stderr=', 'причина: причины KLASS_RISKA_NET нет в stderr: ', 'отказ передачи изменил долговечное состояние']
frozen-not-object p07-kontrakt-kandidata-prioritet ['именованный-отказ: rc 0 ≠ 1; stderr=', 'причина: причины ADVERSARIJ_DO_REVJUERA нет в stderr: ', 'отказ дописал учёт']
frozen-not-object p32-frozen-obychnyj-object-riskovyj ['суд-переданного: rc 1 ≠ 0; stderr=ОТКАЗ: ADVERSARIJ_DO_REVJUERA: предмет 197 рисковый, завершённого адверсария в учёте нет — ревьюер раньше адверсария запрещён', "START-судьи: строки START {'holder': 'Judge197', 'object': '7abf270adc244bf1cae551a991d2f08bf93d93de'} нет в учёте"]
ATTACKS_CAUGHT
```

Проба входа на честной модели: `TMPDIR="$PWD/tmp/critic140" PYTHONDONTWRITEBYTECODE=1 python3 tmp/critic140/legacy.py` rc 0. Только построение мира изменено в памяти, модель не мутирована:
```python
import sys, types
from pathlib import Path
sys.path.insert(0, str(Path('fixtures/workshop_project/odin_agent_140').resolve()))
import probe as p
src = Path('fixtures/workshop_project/odin_agent_140/produkt_140.py').read_text()
old = "(wt / 'contracts/197-product.md').write_text('КЛАСС РИСКА: '+risk+'\\n')"
new = "(wt / 'contracts/197-product.md').write_text('# old frozen without risk declaration\\n')"
assert src.count(old)==1
src=src.replace(old,new,1)
old="        (wt / 'registry/contracts.tsv').write_text('197 → '+git('rev-parse', tag)+'\\n')\n"
new=old+"        (wt / 'registry/risk-legacy.tsv').write_text(git('rev-parse', tag+'^{commit}:contracts/197-product.md')+'\\tобычный\\told\\towner\\n')\n"
assert src.count(old)==1
src=src.replace(old,new,1)
mod=types.ModuleType('legacy_owner_input')
exec(compile(src,'legacy_owner_input','exec'),mod.__dict__)
p.produkt_140=mod
cases=p.kejsy()
name='p01-produktovyj-start'
print(name,repr(p.progon(p.MODEL,name,cases[name]['run'])))
```
Сырой вывод:
```
p01-produktovyj-start ['суд: rc 1 ≠ 0; stderr=ОТКАЗ: KLASS_RISKA_NET: предмет 197: класс риска неоднозначно определён (neodnoznachno); файлы: 197-product.md']
```

Дополнительная проба отсутствия текущего product HEAD pin при историческом опубликованном receipt: `TMPDIR="$PWD/tmp/critic140" PYTHONDONTWRITEBYTECODE=1 python3 tmp/critic140/pin.py` rc 0; в существующем p03/p04 после создания receipt переключён product checkout на отдельную ветку с коммитом удаления `registry/contracts.tsv`, ветка сдачи и receipt не изменялись. Вывод:
```
OWNER_PIN_AT_HEAD 128
p03-peredacha-zapis []
OWNER_PIN_AT_HEAD 128
p04-produkt-bez-kontrakta []
```
Это наблюдение не является отдельным блоком: контракт 5а специально выбирает исторический pin из опубликованного receipt, а не latest.
