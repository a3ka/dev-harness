FAIL
OBJECT=4841a1a06693e902cdbd919e1fb1e7f510ed12e2
СУД: репо=dev-harness; предмет=224; фаза=реализация; роль=adversary; вызов=1 (полный); сессия=Adv224; модель-факт=openai-codex/gpt-6.1-terra; автор implementer — MiniMax, батарея Architect224c (gpt-6.1-sol); предыдущий=—; класс=рисковый

## Блоки

БЛОКИРУЕТ **К-08 — батарея не различает числовой и лексикографический порядок**, `contracts/224-svezhest-verdikta-done.md:45-48`, `scripts/done_contract.sh:275`, `fixtures/workshop_project/svezhest_verdikta_done_224/probe.py:13-59,391-479`.

ОБЯЗАТЕЛЬСТВО: выбирать единственный максимальный ЧИСЛОВОЙ ключ, включая номера до девяти цифр, и не пропускать поздний FAIL. Критерий отдельно требует различающую клетку для каждого обязательства. Источник входа — прямо названный заданием сценарий `-impl-v9` против `-impl-v10`, с параллельными носителями как в Боли 224, а не только разрешение грамматикой. Источник механизма — замена имеющегося сравнения ключей `if [ "$key" -gt "$best" ]; then` на `if [[ "$key" > "$best" ]]; then` в копии production; более ранний код не удаляется целиком и прочие двери остаются настоящими.

СОСТОЯНИЕ: в настоящем Git-мире 224 параллельные review-носители приземлены merge-коммитами; `v9` = accept, `v10` = FAIL, даты непротиворечивы, OBJECT и заморозка настоящие. Ожидается rc 1, сообщение о `v10`, тега нет. НАБЛЮДЕНИЕ: честный OBJECT прошёл эту отдельную проверку; мутант вернул rc 0, stderr пуст, создал done-тег (`RC,DIAGNOSIS,TAG_ON_REFUSAL`). Тем не менее все 92 существующие клетки `--repo` на том же мутанте зелёные: `LEXICAL_FULL RED 0`. Мутант преднамеренный; это не утверждение, что честный OBJECT уже пропускает этот FAIL. Закрывающее свойство — различать числовой порядок на достижимых разноразрядных кругах с отдельными положительной и отрицательной полярностями; для обоих потребителей порядка.

Вторая живая замена того же класса: `[ "${#version}" -le 9 ]` → `-le 8`, `scripts/done_contract.sh:164`: все 92 клетки зелёные (`MUTANT_FULL RED 0`), но настоящий конформный review `impl-v999999999` с accept честная дверь принимает, мутант отказывает `VERDICT_ROUND_INVALID`. Это отдельно бьёт оговорённый верхний предел, не доказывает дефект честной двери.

**Остановка:** из доказанных блоков остался только К-08 при честной production; слово владельца по правилу остановки 224 не предъявлено. Это FAIL батареи, не разрешение считать честную реализацию неверной и не accept до решения владельца.

### Воспроизведение основного обхода

Чистый одноразовый клон OBJECT с собственной `.git`, окружение `CLONE=<абсолютный путь клона>`, `TMPDIR=<абсолютный каталог внутри своей копии, вне клона>`. Следующий Python-код — содержимое запускавшегося `python3 "$TMPDIR/lexical.py"`; `probe.py` не меняется, а его `suite` исполняет настоящий полный CLI на отдельно построенных Git-мирах и проверяет обе трубы, HEAD и annotated tag:

```python
import importlib.util, os
from pathlib import Path
p = Path(os.environ['CLONE'])
os.environ['TMPDIR'] = str(p.parent / 'scratch-adv224')
spec = importlib.util.spec_from_file_location('probe', p / 'fixtures/workshop_project/svezhest_verdikta_done_224/probe.py')
x = importlib.util.module_from_spec(spec); spec.loader.exec_module(x)
s = (p / 'scripts/done_contract.sh').read_bytes()
base = x.run(['git', '-C', p, 'show', '5fa6b2c294c2dfd677febb200c73dc27467461e6:scripts/done_contract.sh']).stdout
old = b'if [ "$key" -gt "$best" ]; then'
new = b'if [[ "$key" > "$best" ]]; then'
assert s.count(old) == 1
mutant = s.replace(old, new)
orig = x.make_world
def world(work, case):
    root, target, reason, rc, marker, tag, head = orig(work, 'review-late-fail')
    d = root / 'verdicts/review'
    for n, m in [(3, 9), (4, 10)]:
        f = d / f'contracts-777-impl-v{n}.md'
        data = f.read_text().replace(f'вызов={n}/9', f'вызов={m}/10')
        f.rename(d / f'contracts-777-impl-v{m}.md')
        (d / f'contracts-777-impl-v{m}.md').write_text(data)
    head = x.commit(root, 'rounds nine and ten')
    return root, target, reason, 1, 'done: несколько вердиктов, свежий contracts-777-impl-v10.md не accept'.encode(), tag, head
x.make_world = world
for label, carrier in [('HONEST', s), ('LEXICAL', mutant)]:
    print(label, 'RED', x.suite(carrier, base, ['nine-ten'], label, p), flush=True)
x.make_world = orig
print('LEXICAL_FULL RED', x.suite(mutant, base, x.CASES, 'LEXICAL_FULL', p), flush=True)
```

Сырой существенный вывод:

```text
HONEST nine-ten GREEN
HONEST RED 0
LEXICAL nine-ten RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
LEXICAL RED 1
LEXICAL_FULL review-parallel GREEN
LEXICAL_FULL review-late-fail GREEN
...
LEXICAL_FULL record-adversary-date-spaces GREEN
LEXICAL_FULL RED 0
HONEST nine-digit GREEN
HONEST RED 0
MUTANT nine-digit RED RC,TAG_TARGET,STDERR rc=1 stderr=b'done: VERDICT_ROUND_INVALID: review: verdicts/review/contracts-777-impl-v999999999.md\n'
MUTANT RED 1
MUTANT_FULL RED 0
```

Для второй пробы тот же `suite`: носитель `review-no-metadata` v4 переименован в v999999999, HEAD закоммичен, ожидаются rc 0 и тег на нём; затем все `x.CASES` без подмены миров. Оба полных прогона мутантов используют тот же `suite` и `CASES`, что `W --repo`, не режим `--model`.

## Остатки и границы

ОСТАТОК: К-16 — укусил: `python3 "$TMPDIR/residual.py"` заменяет в настоящем мире поздний FAIL на согласованный ложный `accept`, коммитит и вызывает настоящую дверь. Вывод `FORGED forged GREEN; FORGED_ACCEPT 0`: дверь принимает и ставит тег. Это явно исключённая семантическая ложь, не новый блок честной двери; pre_judge/замок/origin не испытывались этой пробой.

ОСТАТОК: К-11 — не укусил в проверенном срезе: `python3 "$TMPDIR/failures.py"`, PATH содержит только `dirname` и `python3`, git отсутствует: `MISSING_GIT rc= 2 stdout= b'' stderr= b'NOT_IMPLEMENTED: missing git\n'`. Произвольная компрометация установки, подмена памяти и распознавание фикстуры не исследованы полностью.

ОСТАТОК: К-03 — не укусил в проверенном срезе: внешние семейства `python3 fixtures/freeze_contract/fail_closed_992.py` → `cases=25 observations=25 failures=0 not_applicable=0`, rc 0, и `bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh --repo .` → `CELLS=62 STABS=0 FAILURES=0`, rc 0. Остальные внешние двери и API не объявляются полностью проверенными.

SourceCanon не объявлен; архитектурная модель 188 к станционному скрипту не применяется (`contracts/224...:6`).

## Регресс

Все команды в отдельном чистом клоне с собственной `.git` и origin, TMPDIR внутри моей копии, пин shellcheck 0.11.0. `W=bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh`.

| Команда | main a32c577f | OBJECT |
|---|---|---|
| `W --repo .` | rc 1, `KLETKI 92 KRASNYH 53` | rc 0, `KLETKI 92 KRASNYH 0` |
| `W --model` | не повторялся | rc 0, 92/0 |
| `W --sintaksis` | не повторялся | rc 0, `SINTAKSIS 24 SHELLCHECK 2` |
| `W --catalog` | не повторялся | rc 0, 92 клеток, 21 стаб, 56 связей |
| `W --compatibility` | не повторялся | rc 0, world201.live и historic186/129/190 GREEN |
| `W --independent-mutants` | не повторялся | rc 0, `INDEPENDENT_MUTANTS 4 ZHIVYH 0` |
| `W --stabs` | не повторялся | rc 0, `STABY 21 SVJAZI 56 ZHIVYH 0` |
| `python3 fixtures/freeze_contract/fail_closed_992.py` | rc 0, 25/25 | rc 0, 25/25 |
| `bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh --repo .` | rc 0, 62/0 | rc 0, 62/0 |
| `bash fixtures/check_consumers/red_C6_pisateli_minimum_net.sh` | rc 0 | rc 0 |
| `bash fixtures/freeze_contract/red_consumers_gejt_038.sh` | rc 0 | rc 0 |
| `bash fixtures/workshop_project/potrebiteli_116_195/red_potrebiteli_116_195.sh` | rc 0, 14/14 | rc 0, 14/14 |
| `bash -n scripts/done_contract.sh` | rc 0 | rc 0 |
| `bash scripts/gen_ci_steps.sh --check` | rc 0 | rc 0 |
| `bash scripts/check_provodka.sh . contracts/224-svezhest-verdikta-done.md` | rc 1, guard ещё не подключён | rc 0 |

Дифф `a32c577f..OBJECT`: только `.github/workflows/ci.yml`, `registry/ci-steps.tsv`, `registry/ci-zamery.tsv`, `scripts/done_contract.sh`. Строка CI несёт последовательно `--repo .`, `--model`, `--stabs`. Коммит батареи `20cf3d7969aab889023bb17f525eb38c1c1a1b5c` — предок `fc7e7ed3a33eb4210536100f5355e3509a55c9ff`, коммита реализации. В построителе `probe.py` параллельность проверяется `merge-base --is-ancestor` в обе стороны до двух merge; честные `review-parallel` и `adversary-parallel` зелёные. Это реальная реконструкция Боли, не проверка текстовых строк скрипта.

## Мутации

`python3 "$TMPDIR/mutations.py"`: по одному замена операции в production-копии и адресные клетки обеих ролей. Сырой счёт: duplicate → `RED 2`; первый вместо максимума → `RED 2`; снятие проверки порядка дат → `RED 2`; допуск безномерного → `RED 2` по диагнозу (отказ наступил позднее по date-order, не считать это доказательством отказа самой ветви); повтор фазы → `RED 2`; повтор вызова → `RED 2`. Снятие проверки ошибки `merge-base` прошло только выбранные обычные parallel-клетки (`RED 0`): они не инъецируют сбой истории; полного прогона этого мутанта батареей 224 я не делал. Независимый сосед 992 действительно инъецирует отказ `merge-base` и на честной двери отказывает.

`python3 "$TMPDIR/failures.py"`: `exit 1` вместо двери → две клетки красные (`EXIT 1 RED 2`); `exit 127` → `NOT_IMPLEMENTED: subject environment failure`, а не зелень. Ноль review-файлов: `EMPTY empty GREEN; EMPTY RED 0` — честная дверь отказывает без тега, как ожидалось. Отдельная проба неконформных объявлений фазы `v02`/`v0`: review отказал, adversary принял; это неконформный ввод, не предъявляю как достижимый блок без источника такого ввода. `v1000000000` отказал в обеих ролях. Прочие перечисленные в задании формы не подменяются утверждением о полном собственном покрытии: они включены в catalog/stabs или соседние семейства, но отдельные новые мутации на каждую здесь не предъявлены.

## НЕ ЗАЩИЩАЕТ и советы

Ложный согласованный суд и компрометация доверенного окружения остаются за объявленной границей угроз. Добавить адресные клетки на разноразрядный числовой порядок и верхнюю границу в обеих ролях, сохранив реальные Git-миры, late-FAIL и честный контроль. Клетка на неконформный безномерной носитель должна проверять именно `VERDICT_ROUND_MISSING`, а не зачесть иной отказ. Н-39: привязки стабов к ветвям устанавливает architect по коду, не этот вердикт и не проза контракта.
