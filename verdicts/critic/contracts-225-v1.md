FAIL
OBJECT=acd30e9dd1b13059cebee0b1f75bd3502efc45a5
СУД: репо=dev-harness; предмет=225; фаза=контракт; роль=critic; вызов=4 (единственный по праву консультанта; дельта Architect225d по Arb225b); сессия=Crit225d; модель-факт=openai-codex/gpt-6.1-terra; автор Architect225d=openai-codex/gpt-6.1-sol; предыдущий=archive/225/critic-v3-fail-900148feb2; арбитраж=archive/225/arbiter-forma-421e66e866.

Фактические модели и разные сессии проверены `bash scripts/models_actual.sh --tsv --bind --session Crit225d` и тем же для Architect225d: rc 0. Задание сообщает отдельную санкцию консультанта на этот OBJECT. Это узкое исполнение Arb225b: новый полный поиск по неизменённым поверхностям не проводился. После реализации рискового предмета порядок — adversary → reviewer; живая приёмка принадлежит оператору.

## Блок

БЛОКИРУЕТ fixtures/workshop_project/ci_clean_225/SDACHA.md:61,63,73 — собранный носитель не содержит обязательного исправленного представления вызова 3; зелёная карта проверяет вызов 2 вместо него.
ПРОИСХОЖДЕНИЕ: дельта
КЛАСС: К-01
ОБЯЗАТЕЛЬСТВО: Arb225b, `verdicts/arbitration/contracts-225-forma.md`, решение 5 и «Что делать» пп. 2–5, требует полномочно исправить публичную грамматику карты вызова 3 без изменения его FAIL, OBJECT, номера и фактов, затем собрать однозначную достижимую историю с этим представлением и проверить его карту и обе двери. Зелёный вызов 2 не заменяет исправленный вызов 3. Исходный некорректный blob остаётся в архиве и не должен становиться вторым вариантом того же вызова в достижимой истории.
СОСТОЯНИЕ: на закреплённом OBJECT HEAD-путь, указанный листом как предыдущий, содержит blob `2011000d169737282be2e3c25d927031f9683953` — подлинный вызов 2. `git log --format='%H %an %s' -- verdicts/critic/contracts-225-v1.md` в чистом клоне перечисляет только вызовы 2 и 1. `git merge-base --is-ancestor 900148feb26aeb9529ffa80c1b10be2149aa8756 HEAD` возвращает 1; никакого исправленного представления вызова 3 в достижимой истории пути тоже нет. Лист честно называет эту сборку зоной оркестратора и не утверждает её выполнения; автор не обязан подделывать чужой вердикт.
НАБЛЮДЕНИЕ: `check_verdict_karta.sh` на OBJECT даёт `КАРТА: 17/17 зелёный`, но по строке СУД и blob это проверка вызова 2, а не обязательного исправленного вызова 3. `check_sdacha --run` тоже зелёный на старой истории: механическое прохождение не исполняет решение Arb225b. Проверяемое свойство закрытия — полномочное исправление именно карты Crit225c и однозначный носитель с достижимым исправленным вызовом 3, после чего карта и обе двери исполняются на итоговом закоммиченном носителе. Вызов 3 не исчезает из учёта; данные и подпись не подменяются. При исчерпанной санкции четвёртого суда требуется остановка и передача владельцу, не автоматический пятый вызов.

## Исполнение и замеры

Работа в чистом клоне с единственным origin `ssh://git@github.com/a3ka/dev-harness.git`, HEAD точно OBJECT, TMPDIR внутри своей копии. Живые `/var/lib` и systemd не использовались. `git diff --exit-code 900148feb2 acd30e9dd1 -- fixtures/workshop_project/ci_clean_225/probe.py fixtures/workshop_project/ci_clean_225/env_grid.py fixtures/workshop_project/ci_clean_225/model fixtures/workshop_project/ci_clean_225/build.py` и такой же diff каталога `stabs` дали rc 0 без вывода: дельта листа и носителя вердикта не меняет ENV-модель и сетку. Адресные мутации вызовов 1 и 2 отдельно перечислены в build.py как s55–s59 и сохранены, их реальные связи исполняет `--stabs` в сдаточном листе. Эта проверка не доказывает совместимость всех возможных ENV и не устраняет блок носителя.

Сырые результаты на OBJECT:
```text
SDACHA_TIMEOUT_SEK=1200 SDACHA_BUDZHET_SEK=2400 bash scripts/check_sdacha.sh "$PWD" contracts/225-ci-clean-vremennye-katalogi.md --run
СДАЧА: лист зелёный (двери=16 карта=17/17 дельта=3)
rc=0
bash scripts/pre_critic.sh contracts/225-ci-clean-vremennye-katalogi.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3
  ok   гейт трека:
  ok   модель угроз красна
  ok   потолки красны
  ok   проводка красна
  ok   сдаточный лист красен
КРИТИК: дверь зелёная
rc=0
bash scripts/check_precision_gate.sh "$PWD" contracts/225-ci-clean-vremennye-katalogi.md
OK
rc=0
bash scripts/check_verdict_karta.sh "$PWD" verdicts/critic/contracts-225-v1.md
КАРТА: 17/17 зелёный
rc=0
bash fixtures/workshop_project/ci_clean_225/red_ci_clean_225.sh --catalog
KLETKI=276 STABY=59 SVJAZI=84 NOSITELI=74
rc=0
```
`pre_critic` первоначально запущен в цепочке с precision под общим timeout 600: первая команда завершилась зелёной и по `&&` началась вторая, но общая цепочка прервана таймаутом. Precision повторён отдельно и дал показанный rc 0. `check_sdacha --run` исполнил все 16 строк листа, включая 225 model/stabs/delta/sintaksis/catalog и 196 repo/model/stabs, проверив их rc; отдельные счётчики этих прогонов здесь не заявляются. Карта на OBJECT проверена отдельно до записи настоящего вердикта.

Четыре соседние мутации старого bash-алгоритма проверены по одной через `probe.cell`, с одноразовым overlay в TMPDIR и без записи в модель: порог срока `-ge 1` → `-ge 0` (`grid-days-5`); снятие проверки ведущего символа имени (`grid-invalid-12`); снятие проверки симлинка ROOT (`grid-root-8`); `find ... -newermt "$cutoff"` → `find ... -mtime -999999` (`artifact-age`). Команда `TMPDIR="$PWD/../scratch-crit225d" PYTHONDONTWRITEBYTECODE=1 PYTHONPATH="$PWD/fixtures/workshop_project/ci_clean_225" python3 "$TMPDIR/attacks_short.py"` в клоне, rc 0; скрипт для каждой пары создаёт временный каталог overlay, заменяет ровно один фрагмент и печатает `green` и первое слово причины. Сырой вывод:
```text
days-zero grid-days-5 green=False reason=GRID_225_LITERAL
repo-leading-hyphen grid-invalid-12 green=False reason=GRID_225_LITERAL
root-symlink grid-root-8 green=False reason=GRID_225_LITERAL
age-always-young artifact-age green=False reason=ARTIFACT_CONFIG_IGNORED
```
Начальная проба четвёртой мутации добавляла `-false` после `-print -quit`: она была инертна и дала `age-check artifact-age green= True reason= ''`, поэтому не засчитана; заменена указанной действительной мутацией. Первые три в том начальном прогоне тоже краснели; сам драйвер тогда вернул rc 1 из-за этой инертной пробы. Для воспроизводимости использован следующий исполнявшийся драйвер:
```python
import pathlib,tempfile
import probe
original=(probe.MODEL/'root/ci-artifacts-clean').read_text()
cases=[('days-zero','[ "$RET_ENV" -ge 1 ]','[ "$RET_ENV" -ge 0 ]','grid-days-5'),('repo-leading-hyphen','[!A-Za-z0-9]*|*[!A-Za-z0-9._-]*)','*[!A-Za-z0-9._-]*)','grid-invalid-12'),('root-symlink','[ -L "$ROOT_ENV" ] || [ ! -d "$ROOT_ENV" ]','[ ! -d "$ROOT_ENV" ]','grid-root-8'),('age-always-young','find "$entry" -newermt "$cutoff" -print -quit','find "$entry" -mtime -999999 -print -quit','artifact-age')]
for name, old, new, cell in cases:
    assert original.count(old)==1
    with tempfile.TemporaryDirectory(dir=str(pathlib.Path(__file__).parent),prefix='mutant-') as d:
        overlay=pathlib.Path(d); p=overlay/'root/ci-artifacts-clean'; p.parent.mkdir(); p.write_text(original.replace(old,new))
        green, reason=probe.cell(probe.MODEL,overlay,cell)
        print(name,cell,'green='+str(green),'reason='+reason.split(' ',1)[0],flush=True)
        assert not green
```
Нагрузка при старте: load average 30.86, 30.34, 20.94; при последующем замере 14.08, 17.78, 19.18. По Н-39 пары стабы↔ветви определяет architect по коду, не проза контракта.

## Карта классов

К-01: блок — не предъявлена исправленная карта вызова 3 и её достижимая история
К-02: без изменений с вызова 2
К-03: чисто — неизменённая модель и --delta в сдаточном листе rc 0
К-04: без изменений с вызова 2
К-05: без изменений с вызова 2
К-06: без изменений с вызова 2
К-07: без изменений с вызова 2
К-08: чисто — четыре соседние мутации красны и --stabs в сдаточном листе rc 0
К-09: чисто — независимая ENV-сетка и literal-опоры исполняются через --delta rc 0
К-10: без изменений с вызова 2
К-11: без изменений с вызова 2
К-12: без изменений с вызова 2
К-13: без изменений с вызова 2
К-14: чисто — честная модель и --delta в сдаточном листе rc 0
К-15: чисто — --catalog rc 0 276/59/84/74
К-16: без изменений с вызова 2
К-17: без изменений с вызова 2

## НЕ ЗАЩИЩАЕТ

Остатки контракта: враждебный root/конкурентная смена FS и cgroup, SIGKILL между freeze и thaw, отличия реального systemd от игрушки. Ловцы — adversary и reviewer production-diff, операторское восстановление и обязательная живая приёмка до done. Формальный блок не разрешает сужение совместимости или риска.

## Советы

СОВЕТ contracts/225-ci-clean-vremennye-katalogi.md:56 — прежний совет о воспроизводимой операторской процедуре сохраняется.
