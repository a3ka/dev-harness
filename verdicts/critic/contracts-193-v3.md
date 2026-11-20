accept

OBJECT=6858abb4205368b8a1cf93fad6d5126a04b665a3

СУД: repo=dev-harness; предмет=193; фаза=узкий по К-09; роль=critic; вызов=9; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit193V9; модель-факт=openai-codex/gpt-6.1-terra; SHA=6858abb4205368b8a1cf93fad6d5126a04b665a3; предыдущее=verdicts/critic/contracts-193-v3.md (Crit193V7 FAIL; форма карты исправлена Crit193Karta без суда); исключение=слово владельца 22:32 «193 да» (при FAIL — арбитр).

`bash scripts/models_actual.sh --tsv --bind --session Crit193V9` → rc 0, critic / openai-codex/gpt-6.1-terra / allowed. Слово владельца и запись до вызова доступны в state-коммите `3dfee8b9ba`; запись фактической сессии в HANDOFF и её независимая сверка — обязанность оркестратора.

Область — разрешённая дельта К-09, включая полные исторические карты, обе публичные двери, адресные стабы и зависимый регресс HEAD/index и исторического OBJECT. Дополнительная атака связана с новой очередью обхода: замена её операции проверяет, различают ли новые клетки обход на произвольной глубине, а не только на первом уровне. Неизменённые поверхности без нового свидетельства риска повторно не исследовались.

Блок Crit193V7 закрыт: исходный случай другого класса воспроизведён в r50 обеих дверей, глубинный сосед — r51, честные аналоги — r52/r53, цикл и неоднозначность — r54/r55, честные встречные карты — r56. При каждом переходе очередь посещает всю достигнутую карту; разрешение пары вызов/класс отдельно различает настоящий цикл. Сравнение байтов вердиктов, HEAD и индекса до и после публичных дверей остаётся в оракуле клетки; существующие r10–r13 и остальные клетки не удалены.

## Карта классов

К-01: чисто — вход: лист и его дельта; `check_sdacha --run` rc 0.
К-02: чисто — без изменений с вызова 7.
К-03: чисто — без изменений с вызова 7.
К-04: чисто — без изменений с вызова 7.
К-05: чисто — вход: машинные ряды листа и команды предыдущей приёмки без разрыва.
К-06: н/п — без изменений с вызова 7.
К-07: чисто — вход: предыдущие клетки модели и отдельное красное-до без rc-нестабильной команды в листе.
К-08: чисто — вход: адресные привязки r50/r51/r54 и соседняя мутация очереди ниже.
К-09: чисто — вход: r50–r56 обеих дверей и собственная глубокая мутация ниже.
К-10: чисто — вход: публичные двери и снимки байтов/HEAD/index в r50–r56.
К-11: чисто — вход: сохранённые r10–r13, публичные двери и сравнение неизменности исторических артефактов.
К-12: чисто — без изменений с вызова 7.
К-13: н/п — без изменений с вызова 7.
К-14: чисто — вход: r52/r53/r56 и честный контроль соседней мутации.
К-15: чисто — вход: итоги реально выполненных проверок ниже.
К-16: чисто — без изменений с вызова 7.
К-17: н/п — без изменений с вызова 7.

## Собственные атаки

`python3 critic193_probe_tmp.py` — одноразовые git-миры через `postroit_mir`: 04/К-02 → 03, 03/К-03 → 02, 02/К-05 → 01. В первом мире вызов 01 отсутствует, во втором присутствует, в третьем отсутствует и единственная операция `ochered+=("$sledujushchie")` заменена на `:`. Скрипт и миры удалены. Сырой вывод:

```text
missing-deep rc=1
ОТКАЗ: verdicts/critic/contracts-777-v1.md: отсутствует вызов 1 (К-05)
honest-deep rc=0
КАРТА: 17/17 зелёный
queue-removed rc=0
КАРТА: 17/17 зелёный
```

Повтор с иной собственной мутацией: та же операция заменена на `if [ "$i" -eq 1 ]; then ochered+=("$sledujushchie"); fi` — очередь ограничена первым уровнем. `python3 critic193_probe_tmp.py`:

```text
missing-deep rc=1
ОТКАЗ: verdicts/critic/contracts-777-v1.md: отсутствует вызов 1 (К-05)
honest-deep rc=0
КАРТА: 17/17 зелёный
one-level-only rc=0
КАРТА: 17/17 зелёный
```

Та же мутация предъявлена непосредственно новым клеткам обеих дверей; реализация пробы (скрипт после запуска удалён):

```python
import importlib.util, tempfile
from pathlib import Path
p=Path('fixtures/workshop_project/sdacha_193/probe.py').resolve()
spec=importlib.util.spec_from_file_location('probe193',p); m=importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
with tempfile.TemporaryDirectory(dir='.') as tmp:
    tempfile.tempdir=str(Path(tmp).resolve())
    m.MUTACII_LIB['PATERN:REF-CRITIC-DEPTH']=('ochered+=("$sledujushchie")','if [ "$i" -eq 1 ]; then ochered+=("$sledujushchie"); fi')
    for mutant in (False,True):
        ist=m.Istochniki(m.MODEL,lib_mutacija='PATERN:REF-CRITIC-DEPTH' if mutant else None,dostroat_nogi=True)
        miry=m.Miry(Path(tmp).resolve()/('mutant' if mutant else 'honest'),ist)
        cells=[k for k in m.kletki_ssylok(miry) if k.imja.startswith('r51-') or k.imja.startswith('r53-')]
        print('mutant='+str(mutant))
        for cell in cells: m.sudit(cell)
```

`python3 critic193_cell_tmp.py` — сырой вывод (`KRASNO` здесь означает, что батарея поймала обманку):

```text
mutant=False
193 r51-drugoj-klass-glubzhe-sdacha ok rc=1 ОТКАЗ: предыдущий вердикт: отсутствует вызов 1 (К-01)
193 r51-drugoj-klass-glubzhe-karta ok rc=1 ОТКАЗ: verdicts/critic/contracts-777-v1.md: отсутствует вызов 1 (К-01)
193 r53-drugoj-klass-glubzhe-chestnyj-sdacha ok rc=0 СДАЧА: лист зелёный (двери=2 карта=17/17 дельта=0)
193 r53-drugoj-klass-glubzhe-chestnyj-karta ok rc=0 КАРТА: 17/17 зелёный
mutant=True
193 r51-drugoj-klass-glubzhe-sdacha KRASNO rc=0 СДАЧА: лист зелёный (двери=2 карта=17/17 дельта=0)
193 r51-drugoj-klass-glubzhe-karta KRASNO rc=0 КАРТА: 17/17 зелёный
193 r53-drugoj-klass-glubzhe-chestnyj-sdacha ok rc=0 СДАЧА: лист зелёный (двери=2 карта=17/17 дельта=0)
193 r53-drugoj-klass-glubzhe-chestnyj-karta ok rc=0 КАРТА: 17/17 зелёный
```

## Исполненные проверки

- `bash scripts/check_sdacha.sh "$PWD" contracts/193-svyazka-sdatochnyj-list.md --run` → rc 0, `СДАЧА: лист зелёный (двери=2 карта=17/17 дельта=3)`. Первый запуск прерван внешним лимитом инструмента 300 с; повтор с лимитом 1200 с завершён.
- `bash fixtures/workshop_project/sdacha_193/red_sdacha_193.sh --model` → rc 0, `ИТОГ 193: rc=0 KLETKI=151 ZELENYE=151 KRASNYE=0`.
