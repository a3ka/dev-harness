FAIL
OBJECT=50837d4eaad406f212f433ab95448debb0b5e753
СУД: репо=dev-harness; предмет=224; фаза=реализация; роль=adversary; вызов=2 (узкий, дельта ремонта; предыдущий=archive/224/adversary-v1-fail-0968979ed5); сессия=Adv224b; модель-факт=openai-codex/gpt-6.1-terra; автор implementer — MiniMax, автор ремонта батареи Architect224d; класс=рисковый

## Блок: непокрытая ширина явного вызова

БЛОКИРУЕТ К-08, `contracts/224-svezhest-verdikta-done.md:45-48`, `scripts/done_contract.sh:164`, `fixtures/workshop_project/svezhest_verdikta_done_224/probe.py:249-260`. ПРОИСХОЖДЕНИЕ: узкое-закрытие. КЛАСС: К-08.

ОБЯЗАТЕЛЬСТВО: независимо поддерживать канонические V и K до девяти десятичных цифр, в том числе `-impl-vV-vyzovK`, сохраняя допуск свежего accept. Различающая клетка обязательна для каждой проверки границы. Источник входа — не только грамматика: явная форма vyzov уже используется в frozen 186 и названа контрактом; задание на этот вызов отдельно утверждает сценарий «9 vs 10 цифр в -vyzovK». Источник ошибочного механизма — замена существующей операции `[ "${#number}" -le 9 ]` на `[ "${#number}" -le 8 ]`, а не придуманная условная блокировка фикстуры.

СОСТОЯНИЕ: два реальных Git-носителя одной роли, несравнимых до merge, затем приземлены; старый FAIL переименован в `impl-v1-vyzov999999998`, новый accept — в `impl-v1-vyzov999999999`; согласованные `фаза=реализация v1`, вызовы и даты, единый настоящий OBJECT. Аналогично для review и adversary. Старые ветви в независимом мире созданы батареей; переименование и согласование метаданных закоммичены после merge.

НАБЛЮДЕНИЕ: честная production: `HONEST review-adjacent GREEN`, `HONEST adversary-adjacent GREEN`, `HONEST RED 0`. Мутант: обе адресные клетки `RED RC,TAG_TARGET,STDERR`, rc 1, `VERDICT_ROUND_INVALID` на `...vyzov999999998.md`; `WIDTH_NUMBER RED 2`. При этом полный ровно тот же `suite`, что исполняет `W --repo .`, на мутированной production и всех 100 обычных клетках: `WIDTH_NUMBER_FULL RED 0` (все 100 GREEN). Это ложная зелень батареи, а не утверждение о неисправности честной production.

ОБХОД и воспроизведение: чистый одноразовый клон OBJECT с origin; TMPDIR внутри своей копии, вне клона. `python3 width224b.py`, содержимое ниже; `probe.py` не правится, `suite` устанавливает по одному байтовому carrier в отдельную копию tools и вызывает полный done CLI. Проверяются rc, обе трубы, HEAD и цель тега:

```python
import importlib.util, os, pathlib
p = pathlib.Path(os.environ['CLONE']).resolve()
os.environ['TMPDIR'] = str(p.parent / 'scratch-adv224b')
spec = importlib.util.spec_from_file_location('probe', p / 'fixtures/workshop_project/svezhest_verdikta_done_224/probe.py')
x = importlib.util.module_from_spec(spec); spec.loader.exec_module(x)
s = (p / 'scripts/done_contract.sh').read_bytes()
base = (p / 'fixtures/workshop_project/svezhest_verdikta_done_224/model/station.sh').read_bytes()
old = b'[ "${#number}" -le 9 ]'; new = b'[ "${#number}" -le 8 ]'
assert s.count(old) == 1
mutant = s.replace(old, new)
orig = x.make_world
def world(work, case):
    role = case.split('-')[0]
    root, target, reason, rc, marker, tag, head = orig(work, role + '-nine-ten-accept')
    d = root / 'verdicts' / role
    for n, k in [(9,999999998), (10,999999999)]:
        f = d / f'contracts-777-impl-v{n}.md'
        text = f.read_text().replace('фаза=реализация;', 'фаза=реализация v1;').replace(f'вызов={n}/10', f'вызов={k}/999999999')
        f.rename(d / f'contracts-777-impl-v1-vyzov{k}.md')
        (d / f'contracts-777-impl-v1-vyzov{k}.md').write_text(text)
    head = x.commit(root, 'explicit nine digit calls')
    return root, target, reason, 0, b'', tag, head
x.make_world = world
for label, carrier in [('HONEST',s),('WIDTH_NUMBER',mutant)]:
    print(label, 'RED', x.suite(carrier,base,['review-adjacent','adversary-adjacent'],label,p))
x.make_world = orig
print('WIDTH_NUMBER_FULL RED',x.suite(mutant,base,x.CASES,'WIDTH_NUMBER_FULL',p))
```

Закрывающее свойство: различать отдельное ограничение K от ограничения V на конформном явном вызове в обеих ролях; вторая сторона должна сохранять отказ десятизначного K. Н-39: адресные стабы к ветвям привязывает architect по коду, не этот вердикт.

Из доказанного остался только К-08 при честной production. Второй вызов исчерпан; требуется маршрут reviewer + owner-аттестат консультанта по правилу остановки, слово владельца для 224 пока не предъявлено. Дополнительно арбитр: повтор той же причины, конечная граница К-08. FAIL — не доказательство неисправности честной двери.

## Область

`git diff --name-status 4841a1a06693e902cdbd919e1fb1e7f510ed12e2 HEAD`: изменения только в семье 224 и трёх названных CI-файлах; `git diff 4841a1a06693e902cdbd919e1fb1e7f510ed12e2 HEAD -- scripts contracts` пуст. Дифф `probe.py` сохраняет прежние ветви: изменены только параметризация сценариев и добавленные ветви. Сравнение `source.json`: `OLD_LINKS 56 NEW_LINKS 62 REMOVED []`; шесть добавленных связей — четыре для st22 и две для st23. Суда над иными неизменёнными поверхностями заново не проводилось.

Ожидания новых клеток — литералы `expected_rc`, `marker`, ожидаемый тег/HEAD, до вызова CLI; `probe.py` создаёт разные Git-ветви, проверяет не-предковость в обе стороны и вливает их отдельными merge. Оракул не вычисляется по реализации. SourceCanon не объявлен, архитектура 188 неприменима к станционному скрипту (контракт, строки 6–8).

## Регресс и адресные стабы

В чистом клоне с собственной `.git` и origin, TMPDIR вне клона; `W=bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh`:

- `W --repo .` → rc 0, `KLETKI 100 KRASNYH 0`.
- `W --stabs` → rc 0, `STABY 23 SVJAZI 62 ZHIVYH 0`. Четыре ссылки st22 отдельно красные на v9/v10 обеих полярностей обеих ролей; две ссылки st23 отдельно красные на nine-digit обеих ролей. Положительный контроль модели также зелёный на всех 100 клетках.
- `python3 fixtures/freeze_contract/fail_closed_992.py` → rc 0, `cases=25 observations=25 failures=0 not_applicable=0`.
- `bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh --repo .` → rc 0, `CELLS=62 STABS=0 FAILURES=0`.

## Остальные режимы и повтор двух мутантов вызова 1

Все пять команд выполнялись без лишнего позиционного аргумента; первая моя попытка с лишней точкой давала argparse rc 2 и не является результатом батареи.

- `W --model`: rc 0, `KLETKI 100 KRASNYH 0`.
- `W --sintaksis`: rc 0, `SINTAKSIS 26 SHELLCHECK 2`.
- `W --catalog`: rc 0, `KLETKI 100 STABY 23 SVJAZI 62`.
- `W --compatibility`: rc 0, `world201.live` равно `(0, пустая строка)`, historic186/129/190 GREEN.
- `W --independent-mutants`: rc 0, `INDEPENDENT_MUTANTS 4 ZHIVYH 0`.

`python3 "$PWD/tmp/mutants224b.py"` создал по одному клону с собственной `.git`, поменял только production-операцию и вызвал в нём `W --repo .`. Лексикографическая подмена числового сравнения: rc 1, `KLETKI 100 KRASNYH 4`, красные только новые `review/adversary-nine-ten-late-fail` и `review/adversary-nine-ten-accept`. Замена ограничения длины version с 9 на 8: rc 1, `KLETKI 100 KRASNYH 2`, красные только новые `review/adversary-nine-digit`. Это закрывает два буквально предъявленных в вызове 1 мутанта; соседняя проверка K остаётся живой, как показано выше.

## Остатки

ОСТАТОК: К-16 — укусил: `python3 "$PWD/tmp/residual224b.py"` построил настоящий мир, заменил поздний FAIL согласованным ложным accept и вызвал дверь: `FORGED forged GREEN`, `FORGED RED 0`; исключённая моделью угроз семантическая ложь не дефект честной двери. Ловцы pre_judge/замок/origin отдельно не испытывались.

ОСТАТОК: К-11 — не укусил в проверенном срезе: `env PATH="$PWD/tmp/nogit" /usr/bin/python3 fixtures/workshop_project/svezhest_verdikta_done_224/probe.py --repo .` → `NOT_IMPLEMENTED: missing git`, rc 2. Компрометация PATH/памяти/распознавание фикстуры в целом не доказаны невозможными.

ОСТАТОК: К-03 — не укусил в проверенном срезе: соседние семьи 992 и 201 дали соответственно 25/25 и 62/0, команды и rc выше. Независимые API и остальные двери целиком не проверялись.

## Контроли иных границ

`python3 "$PWD/tmp/coordinates224b.py"`: `review:leading GREEN`, `adversary:leading GREEN`, `adversary:v2v10 GREEN`, `review:call10digits GREEN`, `adversary:call10digits GREEN`, `HONEST_BOUNDARIES RED 0`. Проверялись ведущий ноль, разрядность v2/v10 и отказ десятизначного явного вызова.

`python3 "$PWD/tmp/maxcoords224b.py"`: `MAXIMUM review GREEN`, `MAXIMUM adversary GREEN`, `MAXIMUM RED 0`: соседние поколения 999999998/999999999 и вызов 999999999, максимальный ключ 999999999999999999. Коллизия `V×10^9+K` при конформных K невозможна: 0 ≤ K < 10^9; K=10^9 отдельно отказан предыдущей пробой.

`python3 "$PWD/tmp/controls224b.py"`: выход 1 — обе клетки красные (`EXIT 1 RED 2`); выход 127 — `NOT_IMPLEMENTED: subject environment failure`; пустое множество review — `EMPTY empty GREEN`, `EMPTY RED 0` (ожидаемый отказ без тега). Подстановка `sort -V` для сравнения ключей: четыре клетки v9/v10 зелёные, `SORT_V RED 0`; это не показано дефектом, поскольку для канонических неотрицательных десятичных целых такой порядок на проверенных данных совпадает с арифметическим. Не объявляю это полным доказательством эквивалентности всех программ.
