FAIL
OBJECT=5b37a6240ca0d35e2c00278bff949f1a8a0a85ae
СУД: репо=dev-harness; предмет=210; роль=adversary; вызов=1 (полный); фаза=реализация; модель-план=openai-codex/gpt-6.1-terra; модель-факт=openai-codex/gpt-6.1-terra; предыдущий=нет; класс риска=рисковый

## Позитивный контроль

На OBJECT `W=bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh`:
- `W --repo .`: rc 0, KLETKI=36 ZELENYE=36 KRASNYE=0.
- `W --model`: rc 0, KLETKI=36 ZELENYE=36 KRASNYE=0.
- `W --stabs`: rc 0, MUTACII=18 SVJAZI=20 POIMANY=20 ZHIVYH=0.
- `W --syntax`: rc 0, `210 SYNTAX: bash=3 python=1`.

`probe.py` sources читает оба предъявленных production-файла из аргумента --repo, строит миры отдельно, сравнивает rc и оба потока с ожиданием, вычисленным до запуска. Независимые production-мутации ниже подтверждают, что файлы действительно исполняются. Положительный контроль не доказывает полноты клеток: два достижимых контрпримера ниже зелёная батарея не содержит.

## Атака

Мутации по одной в одноразовом `git clone --shared --no-checkout` с собственной .git, checkout OBJECT, затем `W --repo <clone>`; после каждой исходный файл восстанавливался. Сырой rc батареи и красные клетки:

| Мутация production | rc | Клетки KRASNO (rc субъекта) |
|---|---:|---|
| удалить проверку первичности `case "$fb" ...` | 1 | g19(0), g20(0) |
| разрешить lightweight tag | 1 | g3(0) |
| не сравнивать объект origin | 1 | g11(0), g14(0) |
| при отказе ls-remote подставить ожидаемый объект | 1 | g12(0) |
| удалить сравнение блоба результата | 1 | g2(0), v4(0) |
| удалить сравнение блоба второго родителя | 1 | g17(1) |
| убрать проверку связности предков | 1 | g5(1) |
| удалить grandfather 72–74 | 1 | a3(0) |
| нейтрализовать вызов предиката в pre-push | 1 | b5(1), g20(1) |
| сравнивать вместо родительского блоб результата | 1 | g17(1) |
| при несовпадении объекта origin вернуть успех | 1 | g11(0), g14(0) |
| зашить номер 810 | 1 | v6(1) |
| `exit 1` вместо check_charter | 1 | все 36 KRASNO |
| `exit 127` вместо check_charter | 2 | `NOT_IMPLEMENTED: SUBJECT_ENVIRONMENT a1-v-istorii-tega: (127, b'', b'')` |
| отсутствующая команда вместо check_charter | 2 | `NOT_IMPLEMENTED: SUBJECT_ENVIRONMENT ... (127, ... command not found)` |
| пустой check_charter | 2 | a1/a2/a3/b1/b2/b3 KRASNO, `NOT_IMPLEMENTED: CACHE_NOT_HEAD: b4-incr` |
| немедленный успех только для --incr | 2 | `NOT_IMPLEMENTED: CACHE_NOT_HEAD: b4-incr` |

Первая попытка константы встретила якорь дважды и не применялась; отдельная мутация с привязкой к соседней строке применена и измерена в таблице. `rc=2` — отказ среды/некорректный субъект, не засчитывается как пойманная предметная мутация. Имена с пробелом и верхним регистром: отдельные миры land и edit, соответственно rc 0 и 1, точные ожидаемые тройки совпали. Симлинк не предъявлен.

## Блоки

### Б-1: повторная публикация восстанавливает старые байты без разрешения

**БЛОКИРУЕТ** `scripts/check_charter.sh:723-725`, `.githooks/pre-push:423`, `contracts/210-charter-tekst-do-tega.md` И3–И4: первичная публикация не должна освобождать возврат после другой разрешённой правки. Класс причины: предковость T относительно первого родителя используется как эквивалент факта предшествующей публикации, но при разрешённом land Q может быть строгим предком T. Тогда T не попадает в линию первого родителя, хотя frozen-блоб уже публиковался.

СОСТОЯНИЕ: настоящий git commit-tree; базовый P=draft; Q=freeze с frozen-блобом; land имеет родителей base-line и Q и публикует этот блоб. На другой линии `branch2` является потомком Q, а T — потомком branch2; аннотированный /1 на T опубликован на реальном bare origin. Далее первый родитель нового merge — land с разрешённой правкой P; второй — branch2 с замороженным P. Merge без разрешения возвращает frozen-байты. Q второго merge — предок T, T не предок первого родителя; история разрешена Git и прямо попадает в land-форму контракта. Обычная правка и сам возврат происходят после публикации тега как операции; их commit-граф не обязан содержать коммит тега.

НАБЛЮДЕНИЕ: production check_charter rc 0, stdout пуст, stderr включает:
```
  ok   уставной документ внесён публикацией заморозки: contracts/810-publication.md в 9c305896
  ok   уставной документ изменён с разрешения владельца: contracts/810-publication.md в 273e1daf
  ok   уставной документ внесён публикацией заморозки: contracts/810-publication.md в bd0c24f5
уставных документов: 2 · изменений в них: 3 · с разрешения: 3
```
Production pre-push на refs/heads/main с живым origin/main на base: rc 0, stdout/stderr пусты. Повтор с обязательной моделью: те же rc 0 и решения. Необходимое свойство: ранее опубликованный по линии первого родителя frozen-блоб с последующей отличной разрешённой версией не может быть принят как первичная публикация независимо от того, вошёл ли сам T в эту линию.

Воспроизведение на OBJECT, используя конструктор настоящих Git-миров батареи (не подменяет git и не меняет файлы OBJECT):
```python
import importlib.util, sys, pathlib, tempfile, os, subprocess
root = pathlib.Path.cwd()
f = root/'fixtures/workshop_project/charter_tekst_do_tega_210/probe.py'
spec = importlib.util.spec_from_file_location('p210', f)
m = importlib.util.module_from_spec(spec); sys.modules[spec.name] = m; spec.loader.exec_module(m)
with tempfile.TemporaryDirectory() as d:
    w = m.World(d, m.Cell('counter', 'land')); p = w.path
    w.commit('branch2', {'side.txt': b'side\n'}, ['freeze'])
    w.commit('tagchild', {'tag.txt': b'tag child\n'}, ['branch2']); w.tick += 1
    m.git(w.root, 'tag', '-f', '-a', w.tag.removeprefix('refs/tags/'), w.commits['tagchild'], '-m', 'published', tick=w.tick)
    w.commit('edit2', {p: b'authorized new version\n'}, ['land'], message=f'РАЗРЕШИЛ-ВЛАДЕЛЕЦ: {p} authorized\n')
    w.commit('return2', {p: w.cell.value, 'side.txt': b'side\n'}, ['edit2', 'branch2'])
    m.git(w.root, 'update-ref', 'refs/heads/main', w.commits['return2'])
    m.git(w.origin, 'fetch', '-f', str(w.root), w.tag+':'+w.tag)
    m.git(w.origin, 'update-ref', 'refs/heads/main', w.commits['base'])
    for model in (False, True):
        for name, data in m.sources(root, model).items():
            dest = w.root/name; dest.parent.mkdir(parents=True, exist_ok=True); dest.write_bytes(data)
        commands = [(['bash', str(w.root/'scripts/check_charter.sh'), str(w.root)], None),
                    (['bash', str(w.root/'.githooks/pre-push'), 'origin', str(w.origin)],
                     f'refs/heads/main {w.commits["return2"]} refs/heads/main {w.commits["base"]}\n')]
        for cmd, data in commands:
            r = subprocess.run(cmd, cwd=w.root, input=data, capture_output=True, text=True)
            print('model=', model, 'command=', cmd[1], 'rc=', r.returncode, 'stdout=', repr(r.stdout), 'stderr=', repr(r.stderr))
```
Команда измерения: `python3 /tmp/dev-harness-verify/scratch-adv210/counter.py` rc 0; четыре вызова субъекта по rc 0. Случай отличается от g19/g20 тем, что в land второй родитель — строгий предок T, а не сам T: батарея поймала удаление предиката, но не его ложную достаточность.

### Б-2: поддерживаемое кириллическое имя исключается из области

**БЛОКИРУЕТ** `scripts/check_charter.sh:825-831`, `scripts/next_id.sh:157-177`, контракт И1 и И4: прямой путь `contracts/810-кириллица.md` соответствует существующей грамматике next_id; обычная правка после /1 без разрешения должна быть красной. `git ls-tree --name-only` по умолчанию цитирует не-ASCII имя; awk требует `.md` в конце строки и отбрасывает цитированную строку, оканчивающуюся кавычкой. Это существующий механизм области, а не новый предикат: сохранение области является явно заявленным обязательством 210. Отдельный реальный Git-мир с аннотированным опубликованным /1 и post-tag edit дал production rc 0, пустой stdout, stderr `уставных документов: 1 · изменений в них: 0 · с разрешения: 0`; контрольное ожидание — rc 1 и два уставных документа. Для land то же имя также отсутствует из счётчика. Граница применимости: проверен default Git core.quotePath, явно поддерживаемая кириллица подтверждена next_id; это не предположение о несуществующем пути.

Команда измерения `python3 /tmp/dev-harness-verify/scratch-adv210/paths.py` rc 0; воспроизведение:
```python
import pathlib, types, sys, tempfile
root = pathlib.Path.cwd()
f = root/'fixtures/workshop_project/charter_tekst_do_tega_210/probe.py'
mod = types.ModuleType('probe_paths'); mod.__file__ = str(f); sys.modules[mod.__name__] = mod
src = f.read_text().replace("self.path = f'contracts/{cell.number}-publication.md'", "self.path = f'contracts/{cell.number}-кириллица.md'")
exec(compile(src, str(f), 'exec'), mod.__dict__)
with tempfile.TemporaryDirectory() as d:
    for shape in ('land', 'edit'):
        actual, expected = mod.observe(mod.Cell('case', shape), mod.sources(root, False), d)
        print(shape, 'actual rc', actual[0], 'expected rc', expected[0], 'equal', actual == expected)
        print('actual stderr:', actual[2].decode())
```
Наблюдалось: `land actual rc 0 expected rc 0 equal False`; `edit actual rc 0 expected rc 1 equal False`. Необходимо перечислять и сопоставлять реальные имена Git без потери допустимых байтов и судить изменение этого пути. Форма безопасного исправления не предписывается.

## Регресс

- `bash scripts/check_charter.sh`: rc 1 вместо ожидаемого 0; 8 отказов, в том числе 210/a1654418, 209/11e4aaad и 206/207. В данной копии `git cat-file -t refs/tags/frozen/contracts/{210,209,206,207}/1` по отдельности дал `commit` для каждого: локальные теги peeled, не аннотированные. Контракт специально запрещает считать такой ref настоящим аннотированным основанием; поэтому этот результат отдельно от Б-1/Б-2, не приписываю его доказанному дефекту нового предиката. Замена локальных ref не производилась.
- `bash scripts/check_charter.sh --incr <cache>` при заранее записанном OBJECT: rc 0, маркер `судит 5b37a624..5b37a624 (0 коммитов)`; некоторые несовместимые per-document окна дополнительно судили 12 старых разрешённых изменений.
- `bash -n scripts/check_charter.sh .githooks/pre-push`: rc 0.
- `bash scripts/pre_critic.sh contracts/210-charter-tekst-do-tega.md`: rc 0, `КРИТИК: дверь зелёная`.
- `bash scripts/check_sdacha.sh "$PWD" contracts/210-charter-tekst-do-tega.md --run`: rc 0, `СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=6)`.
- `bash scripts/gen_ci_steps.sh --check`: rc 0.
- `git log --format='%h %an|%cn' origin/main..OBJECT`: rc 0, `5b37a6240 orchestrator|orchestrator`, `109816463 implementer|orchestrator`; авторы соответствуют раздаче.

## НЕ ЗАЩИЩАЕТ

ОСТАТОК: К-16 — не укусил: подмена самого настроенного origin вне штатного процесса когнитивно исключена; `W --repo .` rc 0, g11/g12/g13/g14 дают ожидаемые rc 1 для отсутствующего/недоступного/подменённого локального основания, но не доказывают человеческую волю и целостность администрирования origin.

ОСТАТОК: К-08 — укусил: конечный список мутаций не универсален; `W --stabs` rc 0, 20/20 POIMANY, одновременно независимые воспроизведения Б-1 и Б-2 проходят сквозь реальную реализацию. Это не утверждение сговора.

Остальные объявленные остатки имеют ловца reviewer/существующие гарды; новые освобождения для plans/AGENTS/ROADMAP, третий родитель и окна v+1 данным судом не заявляются проверенными.

## Советы

Нет отдельных неблокирующих советов.
