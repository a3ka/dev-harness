FAIL
OBJECT=8b84c0da1e0c784f0b89a84a2838d06490525685
СУД: репо=dev-harness; предмет=210; роль=adversary; вызов=2 (узкий); фаза=реализация; модель-план=openai-codex/gpt-6.1-terra; модель-факт=openai-codex/gpt-6.1-terra; предыдущий=verdicts/adversary/contracts-210-v1.md (FAIL 08c94f6139, архив archive/210/adversary-v1-fail-08c94f6139); класс риска=рисковый

## Закрытие

`W=bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh`.

- Б-1, исходный контрпример: воспроизведён конструктор из v1 (land, branch2, T потомок branch2, разрешённая edit, merge-возврат). Production check_charter rc 1, именно возврат `9c305896` отказан; land `bd0c24f5` и разрешённая edit `273e1daf` приняты. Production pre-push rc 1, отказ по тому же возврату. Разрешённый возврат с `РАЗРЕШИЛ-ВЛАДЕЛЕЦ` в самом merge: check_charter rc 0, pre-push rc 0; land и обе разрешённые правки названы. Исходный пример закрыт.
- Б-2, исходная кириллица: отдельные реальные миры land и edit, fast/oracle/pre-push: land rc 0, edit rc 1, полный вывод совпал с независимым ожиданием. Однако соседняя форма того же класса остаётся открытой: блок ниже.
- В одноразовом `git clone --shared --no-checkout` с собственным `.git`, checkout OBJECT, по одной мутации `scripts/check_charter.sh`, после каждой восстановление, затем `W --repo <clone>`:

| Мутация | rc батареи | Сырой итог и различающие клетки |
|---|---:|---|
| убрать новый first-parent scan | 1 | g21/g22/g23 `KRASNO rc=0`; 39/42 |
| вернуть quotePath по умолчанию в diff-tree с родителем | 1 | g25 `KRASNO rc=0`; 41/42 |
| вернуть quotePath по умолчанию в root diff-tree | 0 | 42/42 |
| вернуть quotePath по умолчанию в ls-tree области | 1 | v8/g24/g25 `KRASNO rc=0`; 39/42 |
| вернуть quotePath по умолчанию в fast log | 1 | v8/g24 `KRASNO rc=0`; 40/42 |

Живой root-diff мутант не объявляю самостоятельным блоком: эта ветвь вызывается только для корневого коммита, а `--diff-filter=MD` не выдаёт добавления корня, поэтому показанной достижимой предметной M/D-дельты нет. Это ограничение различающей способности батареи, не свидетельство исправности данной строки.

## Атака

- `python3 /tmp/dev-harness-verify/scratch-adv210b/edges.py` (одноразовые Git-миры, прямой библиотечный предикат): land 0; sync 0; ancestor-return 1; unrelated 1; merge-return 1; retag 2; lightweight 1. В `W` дополнительно b1/b2 — позитивные land/sync, g19/g20 и g21/g22/g23 — отрицательные возвраты; эти клетки получили ожидаемые коды. Не утверждаю отдельного исполнения всех возможных топологий, в частности нескольких альтернативных кандидатов T.
- Внешний git-прокси только для отказа чтения `rev-list --first-parent` с rc 127: `charter_frozen_publication` rc 2; настоящий check_charter rc 1 с `FAIL не могу проверить публикацию заморозки`, настоящий pre-push rc 1 с тем же основанием. Отдельный отказ чтения исторического `ls-tree --format='%(objectname)'` — предикат rc 2. Первый ошибочный прогон CLI с унаследованным `CHARTER_LIB=1` не используется как свидетельство; после удаления переменной получены результаты выше.
- NFC `café`, NFD `cafe\u0301`, кириллица и путь с пробелом: land fast/oracle/push rc 0, edit fast/oracle/push rc 1, полные тройки совпали с ожиданиями. Кавычка, обратная косая и табуляция: edit в трёх режимах rc 0 вместо 1; land fast/oracle также теряет документ из полного вывода. Это одна причина, не три блока.
- Инвентарь чтения имён: `scripts/check_charter.sh:415,417` diff-tree, `:852` ls-tree, `:1019` log имеют `core.quotePath=false`, но Git всё равно экранирует кавычку, обратную косую и управляющие байты; `:747` ls-tree возвращает только objectname. В `.githooks/pre-push:215-216,271-272` diff --name-only без этого флага, достижим в проверке 167 для произвольных путей, включая не-ASCII; `:361-363` diff-tree для docs/owner также без флага и достижим для не-ASCII имён канала; уставная дверь использует общий `charter_diff_paths` на `:434`. `log --format=%B/%an` читает тело/автора, не путь; `ls-files` и `show --stat` среди читающих имена вызовов этих двух файлов не обнаружены. Сами побочные двери 167 и owner повторно не судились.
- Замер на настоящей истории `git rev-list --count HEAD` = 8995, аннотированные теги восстановлены fetch из origin. `/usr/bin/time bash scripts/check_charter.sh --incr <cache=OBJECT>`: rc 0, 11.34 s; полный rc 0, 25.72 s. База `5b37a6240ca0d35e2c00278bff949f1a8a0a85ae` в отдельном клоне: cache=собственный HEAD rc 0, 11.28 s; полный rc 0, 24.05 s. Замеры выполнялись при другой работе в системе, не как изолированный бенчмарк; обе величины ниже 60 s, рост полного ~1.07×.

## Регресс

На OBJECT, `TMPDIR=/tmp/dev-harness-verify/scratch-adv210b`, закреплённый shellcheck 0.11.0:

- `W --repo .` rc 0: `KLETKI=42 ZELENYE=42 KRASNYE=0`.
- `W --model` rc 0: `KLETKI=42 ZELENYE=42 KRASNYE=0` — позитивный контроль честной модели.
- `W --stabs` rc 0: `MUTACII=20 SVJAZI=25 POIMANY=25 ZHIVYH=0`.
- `W --syntax` rc 0: `210 SYNTAX: bash=3 python=1`.
- `bash -n scripts/check_charter.sh .githooks/pre-push` rc 0.
- `bash fixtures/charter_fast_113/red_113.sh` rc 0, `клеток: 28 · красных: 0`; В2 штатно пропущена без RED_113_FULL.
- `bash scripts/pre_critic.sh contracts/210-charter-tekst-do-tega.md` rc 0, `КРИТИК: дверь зелёная`.
- `bash scripts/check_sdacha.sh "$PWD" contracts/210-charter-tekst-do-tega.md --run` rc 0, `СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=6)`.
- `bash scripts/gen_ci_steps.sh --check` rc 0.
- `git log --format='%h %an|%cn' origin/main..OBJECT` rc 0: implementer, architect, orchestrator, implementer как авторы; все изменённые пути принадлежат их объявленным зонам, committer — orchestrator.

## Блоки

### Б-2 повтор: экранированное Git имя пропадает из обеих дверей

БЛОКИРУЕТ `scripts/check_charter.sh:415-417,852-858,1019`, `.githooks/pre-push:410-434`, `scripts/next_id.sh:157-177`, контракт 210 И1/И4. ПРОИСХОЖДЕНИЕ: узкое-закрытие. КЛАСС: К-03/К-09. Это повтор того же класса потери поддерживаемого имени при чтении Git; требуется арбитраж конечной границы по §Быстрый-процесс, поскольку бюджет повторного суда исчерпан.

ОБЯЗАТЕЛЬСТВО: прежняя область и защита замороженных прямых `contracts/NNN-<slug>.md` сохраняются; обычная правка после /1 без разрешения запрещена. `parse_artifact_basename` принимает три цифры, дефис и не-цифру и не запрещает кавычку в остатке имени.

СОСТОЯНИЕ: настоящий Git-мир `contracts/810-a"quote.md`, начальный draft → опубликованный на отдельном настоящем bare origin аннотированный frozen/contracts/810/1 → обычная правка этого файла без строки владельца. Это прямая грамматика next_id и явно поддерживаемая обычная история, а не поломка Git или оракула. Вход получен заменой slug у реального поддерживаемого сценария обычной правки, а механизм — существующие Git name-only чтения, затронутые исправлением Б-2.

НАБЛЮДЕНИЕ: `git -c core.quotePath=false ls-tree -r --name-only HEAD -- contracts/` rc 0 печатает `"contracts/810-a\\"quote.md"` с внешними кавычками; diff-tree тоже. `awk '/\.md$/'` отбрасывает строку, заканчивающуюся кавычкой. check_charter fast и oracle rc 0, stdout пуст, stderr заканчивается `уставных документов: 1 · изменений в них: 0 · с разрешения: 0`, вместо отказа по второму документу. pre-push rc 0 с пустыми stdout/stderr: цитированный путь не проходит `is_charter_path`. Это наблюдение реального субъекта, не только зелёная мутация батареи. Необходимое свойство: разбирать все поддерживаемые имена без потери байтов либо иным способом не допускать пропуска M/D; достаточно отказа по невозможности проверки, а не молчаливого успеха.

Воспроизведение: сохранить следующий текст как одноразовый `quoted.py` под TMPDIR и выполнить `python3 "$TMPDIR/quoted.py"` из OBJECT. Код использует конструктор батареи только для реальных репозиториев и копирует production через её штатный `sources`; вход и ожидание отказа определены выше, не выводятся из субъекта.

```python
import importlib.util, sys, pathlib, tempfile, subprocess
root = pathlib.Path.cwd()
f = root/'fixtures/workshop_project/charter_tekst_do_tega_210/probe.py'
s = importlib.util.spec_from_file_location('p210', f)
m = importlib.util.module_from_spec(s); sys.modules[s.name] = m; s.loader.exec_module(m)
with tempfile.TemporaryDirectory() as d:
    w = m.World(d, m.Cell('quote', 'edit', slug='a"quote', ref='refs/heads/main'))
    for n, b in m.sources(root, False).items():
        target = w.root/n; target.parent.mkdir(parents=True, exist_ok=True); target.write_bytes(b)
    for args in [('ls-tree','-r','--name-only','HEAD','--','contracts/'),
                 ('diff-tree','-r','--no-commit-id','--name-only',w.commits['freeze'],w.commits['edit'])]:
        r = subprocess.run(['git','-C',str(w.root),'-c','core.quotePath=false',*args], capture_output=True, text=True)
        print('GIT', args[0], r.returncode, repr(r.stdout))
    for mode in ['fast','oracle','push']:
        if mode == 'push':
            m.git(w.origin,'update-ref','refs/heads/main',w.commits['freeze'])
            cmd = ['bash',str(w.root/'.githooks/pre-push'),'origin',str(w.origin)]
            data = f'refs/heads/main {w.commits["edit"]} refs/heads/main {w.commits["freeze"]}\n'
        else:
            cmd = ['bash',str(w.root/'scripts/check_charter.sh')] + (['--oracle'] if mode == 'oracle' else []) + [str(w.root)]
            data = None
        r = subprocess.run(cmd,cwd=w.root,input=data,capture_output=True,text=True)
        print('SUBJECT',mode,'rc=',r.returncode,'stdout=',repr(r.stdout),'stderr=',repr(r.stderr))
```

Сырой результат: `GIT ls-tree 0 '"contracts/810-a\\"quote.md"\n'`; `GIT diff-tree 0` с той же строкой; `SUBJECT fast rc= 0`, `SUBJECT oracle rc= 0`, `SUBJECT push rc= 0`, последний с обоими потоками `''`. Команда сценария rc 0. Отсутствие этого соседа в зелёных 42 клетках и зелёных 25 привязках не доказывает закрытие класса Б-2.

## НЕ ЗАЩИЩАЕТ

- ОСТАТОК: К-16 — не укусил: подмена администрирования самого origin и человеческой воли исключены; `W --repo .` rc 0, g11/g12/g13/g14 дают ожидаемые subject rc 1 для отсутствия, недоступности и подмены основания. Ловцы adversary/reviewer и действующие owner/публикационные двери; реальную подмену origin не выполнял.
- ОСТАТОК: К-08 — укусил: конечный список мутаций не универсален; `W --stabs` rc 0, `POIMANY=25 ZHIVYH=0`, одновременно реальный путь с кавычкой даёт ложный rc 0 в двух CLI выше. Ловец независимый adversary. Сговора не утверждаю.
- Остатки новых освобождений plans/AGENTS/ROADMAP, /2+, octopus и окон v+1 отданы reviewer/существующим гардам; вне данного узкого повтора не заявляются проверенными.

## Советы

Нет отдельных советов.
