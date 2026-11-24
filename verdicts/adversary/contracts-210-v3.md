FAIL
OBJECT=f974b9c487f7ff2c15d6c6d655b0e9780cdefc92
СУД: репо=dev-harness; предмет=210; роль=adversary; вызов=3 (узкий по слову владельца); фаза=реализация; модель-план=openai-codex/gpt-6.1-terra; модель-факт=openai-codex/gpt-6.1-terra (контекст исполняемого агента); предыдущий=archive/210/adversary-v2-fail-06c6002205 (FAIL); класс риска=рисковый

## Закрытие класса

Реальная батарея `env TMPDIR=/tmp/dev-harness-verify/scratch-adv210c VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --repo .` вернула rc 0, `ИТОГ 210: KLETKI=258 ZELENYE=258 KRASNYE=0`. Среди выполненных клеток fast/oracle/incr/push положительные land/sync и отрицательные edit для кириллицы, NFC/NFD, кавычки, обратной косой, пробелов, дефиса, точки и буквальных escape; для TAB/LF/SOH/SHA — edit, для hook и внешних потребителей — адресные seam-клетки. Это не доказательство полного CLI `check_contract_frozen.sh`: seam-клетка явно изолирует его от построения области (`transport.py`, ветвь `frozen`, комментарий `Hold f ASCII`).

## Полнота миграции

`git grep -n -E 'name-only|ls-tree|diff-tree|log .*--name|ls-files|--stat|show .*--name' -- scripts/check_charter.sh .githooks/pre-push scripts/next_id.sh scripts/check_contract_frozen.sh scripts/check_zones.sh` rc 0. В `charter_diff_paths`, области charter, fast log, четырёх diff исключения 167, owner_docs_paths и next_id HEAD/история присутствует `-z`; `check_charter.sh:753` извлекает только objectname. Два потребителя `charter_diff_paths` действительно читают `read -d ''`. Однако `scripts/check_contract_frozen.sh:86-87` всё ещё получает имена через `ls-tree` без `-z` и построчный `awk`, а `scripts/check_zones.sh:498-499,557-558` тоже построчно получают имена из ls-tree. Достижимое следствие первого подтверждено ниже; второго отдельно не воспроизводил и не объявляю отдельным блоком.

## Мутации

Специальные мутации и их `--repo` прогоны не запускались: по постановке после доказанной находки остановка без расширения области. Здесь дефект наблюдается на неизменённом OBJECT, а не искусственно созданной мутации. Положительный контроль настоящего `check_contract_frozen.sh` и ASCII отрицательный контроль приведены ниже.

## Регресс

Полный прогон `--repo .` rc 0, 258/258/0; отдельный драйвер ниже rc 0, внутренние сырые rc: history/ascii 0, edit/ascii 1, edit/quote 0, edit/backslash 0, edit/кириллица 0. Другие регрессы задания не запускались после находки; их зелёными не объявляю. Драйвер создаёт одноразовые Git-миры с собственными `.git` средствами `probe.World`, настоящие аннотированные frozen-теги и отдельный origin; production CLI — настоящий из OBJECT. В каждом мире к HEAD добавлен accept-вердикт v1, а в edit-мире после тега /1 сделана неразрешённая M-правка. Имя и тип истории — единственные переменные по сравнению с контролями. Временный драйвер был удалён после измерения.

Воспроизведение в корне OBJECT, Python 3 (одноразовый временный каталог внутри `.review`, автоматически удаляется):

```python
import sys, tempfile
from pathlib import Path
sys.dont_write_bytecode = True
repo = Path.cwd()
sys.path.insert(0, str(repo / 'fixtures/workshop_project/charter_tekst_do_tega_210'))
import probe
with tempfile.TemporaryDirectory(dir=repo / '.review', prefix='.adv210c-world-') as d:
    for n, (shape, slug) in enumerate((('history','ascii'), ('edit','ascii'), ('edit','a"quote'), ('edit','a\\slash'), ('edit','кириллица'))):
        sub = Path(d) / str(n)
        sub.mkdir()
        w = probe.World(sub, probe.Cell('check', shape, slug=slug))
        w.commit('verdict', {'verdicts/critic/contracts-810-v1.md': b'accept\n'})
        probe.git(w.root, 'update-ref', 'refs/heads/main', w.commits['verdict'])
        rc, out, err = probe.command(['bash', repo / 'scripts/check_contract_frozen.sh', w.root], cwd=repo, timeout=60)
        print('SHAPE', shape, 'SLUG', repr(slug), 'RC', rc, 'STDOUT', repr(out), 'STDERR', repr(err.decode()), flush=True)
```

Сырой результат (stdout каждого CLI пуст):

```text
SHAPE history SLUG 'ascii' RC 0 STDERR '  ok   contracts/810-ascii.md — заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают\n\nпланов и контрактов на HEAD: 1 · черновиков: 0 · заморожено: 1 · реестр: full\n'
SHAPE edit SLUG 'ascii' RC 1 STDERR '  FAIL contracts/810-ascii.md изменён без новой заморозки: на HEAD блоб 3ff09c3c0d5c8ef8976bec200a704e6005aa624b, в заморозке v1 — 63e698433650346cb554da7d73604c5ea6aa54d9. Выход: новый вердикт критика v2, freeze_contract.sh и строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ: в изменяющем коммите\n\nпланов и контрактов на HEAD: 1 · черновиков: 0 · заморожено: 1 · реестр: full\n'
SHAPE edit SLUG 'a"quote' RC 0 STDERR '\nпланов и контрактов на HEAD: 0 · черновиков: 0 · заморожено: 0 · реестр: full\n'
SHAPE edit SLUG 'a\\slash' RC 0 STDERR '\nпланов и контрактов на HEAD: 0 · черновиков: 0 · заморожено: 0 · реестр: full\n'
SHAPE edit SLUG 'кириллица' RC 0 STDERR '\nпланов и контрактов на HEAD: 0 · черновиков: 0 · заморожено: 0 · реестр: full\n'
```

## Блоки

БЛОКИРУЕТ `scripts/check_contract_frozen.sh:86-87` — цитируемый Git путь исчезает из области внешнего потребителя до его окна v+1. КЛАСС: К-09/К-14; ПРОИСХОЖДЕНИЕ: узкое-закрытие, зависимый регресс.

ОБЯЗАТЕЛЬСТВО: постановка требует найти оставшееся строковое чтение имён в пяти файлах и сохранить решения внешнего потребителя; арбитраж 210 требует сохранять байты пути и публичный смысл окон v+1, не объявлять нечитаемый документ пустой областью. Не заявляю, что это место перечислено среди 11 изменяемых мест арбитража: это обнаруженный соседний путь в прямо названном внешнем потребителе.

СОСТОЯНИЕ: поддерживаемый штатной грамматикой `contracts/810-a"quote.md`, опубликованный аннотированный /1 и последующая обычная M-правка без разрешения. Достижимость имен кавычки/backslash штатным next_id → mint → commit измерена арбитражем 210 и `wire-route-quote`, `wire-route-slash` в данном прогоне. Синтетическая история выше имеет реальный Git и не подменяет guard.

НАБЛЮДЕНИЕ: guard rc 0, `на HEAD: 0`, при том что на идентичном ASCII-входе rc 1, один замороженный документ и отказ по несовпадающему блобу. Кавычка и обратная косая независимо воспроизводят тот же класс; кириллица также теряется при стандартном core.quotePath. Причина — Git C-цитирует всю строку, поэтому `awk '/\.md$/'` отбрасывает её из-за завершающей кавычки. Свойство закрытия: реальное имя обязано целиком достигать областного цикла и сравнений блобов, без изменения правил v+1 и с положительным/отрицательным контролем полного CLI. Чистый ASCII rc 0 исключает вечно-красный контроль; этот блок не утверждает, что основной check_charter пропускает данные имена.

## НЕ ЗАЩИЩАЕТ

Не судил подлинность воли и администрирования origin, криптоподписи, новые освобождения, полноту HEAD-only поиска удалённых документов и все будущие дефекты конечной батареи. Находка не опирается на перечисленные остатки: файл присутствует на HEAD, origin настоящий локальный, тег аннотирован. Контракт не маркирует эти строки номерами К-NN, поэтому выдуманных номеров остатка нет.

## Советы

Нет. Не выполнял push. `du -sh` рабочей копии: 154M. Предписанный внешний `/tmp/dev-harness-verify/scratch-adv210c` не удалял: изоляция этой сессии запрещает изменять файлы вне своей копии; миры адресного драйвера в копии удалены автоматически.
