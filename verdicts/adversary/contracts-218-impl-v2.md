FAIL
OBJECT=ca726d350306c7cb4a1e37a1c974cc57ef7c309b
СУД: репо=dev-harness; предмет=218; фаза=реализация; роль=adversary; вызов=2 (scoped); сессия=Adv218b; модель-факт=openai-codex/gpt-6.1-terra; implementer — MiniMax; предыдущий=7c980484af; класс=рисковый.

## Блоки

### Б-1 нового вызова — ошибка чтения HEAD-вердикта превращается в accept из дерева тега

ПРОИСХОЖДЕНИЕ: дельта. КЛАСС: К-09. Контракт И2 запрещает превращать ошибку чтения в чистое окно; И4 требует проверять все версии и accept, а описание дельты прямо требует не заменять существующий HEAD FAIL историческим accept. `scripts/check_contract_frozen.sh:332-342`: `cat-file` с `|| true` не отличает ошибку чтения HEAD от отсутствия файла, после чего новая ветвь читает более старый accept в основании собственной заморозки. Это не вопрос доверия к PATH: инъектор лишь воспроизводит отказ самого Git, явно входящий в И2. Нарушение реально проявляется на честной production при такой ошибке чтения, без мутации кода и без подмены origin/event. Исторический тег и основание допустимы, собственный HEAD-вердикт действительно FAIL.

Воспроизведение из корня OBJECT, scratch внутри копии: `export ROOT="$PWD" TMPDIR="$PWD/tmp/scratch-adv218b"; mkdir -p "$TMPDIR"; python3 "$TMPDIR/catfault.py"`, тело драйвера:

```python
import importlib.util, pathlib, tempfile, os, sys, shutil
root=pathlib.Path(os.environ['ROOT']); p=root/'fixtures/workshop_project/okno_frozen_v_pr_218/probe.py'
s=importlib.util.spec_from_file_location('probe',p); m=importlib.util.module_from_spec(s); sys.modules['probe']=m; s.loader.exec_module(m)
with tempfile.TemporaryDirectory(dir=os.environ['TMPDIR']) as x:
 d=pathlib.Path(x); w=m.World(d,m.Cell('x','clean','frozen'))
 v=f'verdicts/critic/contracts-{w.number:03d}-v2.md'
 anchor=w.commit({v:b'accept\n'},(w.head,),'own accepted freeze')
 m.git(w.root,'tag','-a',f'frozen/contracts/{w.number:03d}/2',anchor,'-m','own v2')
 head=w.commit({v:b'FAIL\n'},(anchor,),'own change to verdict')
 m.git(w.root,'update-ref','HEAD',head); m.git(w.root,'reset','--hard','-q',head)
 real=shutil.which('git'); b=d/'bin'; b.mkdir(); wrapper=b/'git'; marker=d/'fault-hit'
 wrapper.write_text('#!/usr/bin/env bash\nfor a in "$@"; do if [[ "$a" == HEAD:verdicts/critic/contracts-*-v2.md ]]; then touch "'+str(marker)+'"; exit 127; fi; done\nexec "'+real+'" "$@"\n'); wrapper.chmod(0o755)
 for label in ('normal','fault'):
  if label=='fault': os.environ['PATH']=str(b)+os.pathsep+os.environ['PATH']
  t=d/label; t.mkdir(); r=w.run(m.sources(root),t,d/(label+'.trace'))
  print(label,'rc=',r[0], 'hit=',marker.exists(), 'stdout=',repr(r[1]), 'stderr=',r[2].decode())
```

Сырой результат (rc драйвера 0):

```text
normal rc= 1 hit= False stdout= b'' stderr= pr: check_contract_frozen main=db4955b7cf100358a1b50c94e9dc107c6e869c8e base=db4955b7cf100358a1b50c94e9dc107c6e869c8e head=cb3ace784fea993fbe097f77d23a4922d3dbbb1f
  FAIL contracts/701-fixture.md: заморозка v2 лежит поверх вердикта, который её не разрешил: первая строка «FAIL» в verdicts/critic/contracts-701-v2.md
планов и контрактов на HEAD: 1 · черновиков: 0 · заморожено: 1 · реестр: full
fault rc= 0 hit= True stdout= b'' stderr= pr: check_contract_frozen main=db4955b7cf100358a1b50c94e9dc107c6e869c8e base=db4955b7cf100358a1b50c94e9dc107c6e869c8e head=cb3ace784fea993fbe097f77d23a4922d3dbbb1f
  ok   contracts/701-fixture.md — заморожен v2, блоб совпадает побайтово, вердикты v1..v2 разрешают
планов и контрактов на HEAD: 1 · черновиков: 0 · заморожено: 1 · реестр: full
```

Позитивная/негативная пара отличается только принудительным rc 127 при чтении HEAD, hit=True свидетельствует о достижении именно отказа; весь остальной Git настоящий. Следовательно это не только К-08: остаётся доказанное нарушение честной production при отказе чтения.

## Б-1 предыдущего вызова

Дословный драйвер `own_tag_delete.py` из `7c980484af:verdicts/adversary/contracts-218-impl-v1.md` выполнен на OBJECT: before rc 1, after rc 1; оба содержат «заморозка v2 лежит поверх вердикта, который её не разрешил», после также отказ из-за удалённого блоба. Прежняя комбинация закрыта. Положительный `W --repo .` на чистом клоне: rc 0, `KLETKI=108 ZELENYE=108 KRASNYE=0`; внутри есть отдельные варианты удаления контракта/вердикта/обоих, до и после, обоих CLI, FAIL/accept v1/v2/v3, shallow, forged, чужой поздний тег.

## Область

`git diff --name-status 682fb9881c94cf674b107d99238102b0313eb18d HEAD` — только батарея 218 и два production-файла `scripts/check_charter.sh`, `scripts/check_contract_frozen.sh`; `git diff 682fb9881 HEAD -- contracts roles registry .github scripts/lib_incr.sh` пуст. Дельта старого probe добавляет клетки/наблюдение fault, удалённых старых клеток нет. Не обнаружено изменения non-PR веток или правил v+1, публикации, grandfather, кеша и NUL в diff production.

## Остатки и границы

ОСТАТОК: К-16 — укусил в полном вызове (CHARTER_LIB=1, прежний вердикт); подмена доверенной среды вне модели угроз и не самостоятельный блок. ОСТАТОК: К-08 — итог повторных мутаций ниже; универсальная асимптотика не доказывается Trace2. SourceCanon не объявлен, архитектура 188 неприменима. Независимые публикация/предполёт/Д4 остаются вне защиты.

## Проверки и К-08

`W --model`: rc 0, 108/108; `W --stabs`: rc 0, STABY=28 SVJAZI=53 POIMANY=53 ZHIVYH=0; `W --sintaksis`: SYNTAX rc=0; `W --catalog`: 108/28/53; `context.py`: INTERSECTIONS=88. Позитивная production — 108/108.

Три старых мутанта воспроизведены отдельно на ca726d350: вызов `PYTHONPATH=fixtures/workshop_project/okno_frozen_v_pr_218 python3 -c 'import production_mutants as p; p.OBJECT="ca726d350306c7cb4a1e37a1c974cc57ef7c309b"; raise SystemExit(p.main())'`. Переопределение необходимо: сам файл `production_mutants.py` жёстко закреплён на старый OBJECT 682fb988, поэтому буквальный вызов сам по себе НЕ проверяет мутантов отремонтированной production. В каждом случае честный адресный контроль зелёный, мутант красный и полный --repo красный именно новой клеткой:

| Мутант | witness | --repo |
|---|---|---|
| verdict-v1-only | frozen-verdict-contracts-v2-fail | rc 1, 104/108 |
| hide-roadmap | charter-two-documents-agents | rc 1, 106/108 |
| delta-errors-clean | charter-git-fault-diff-all | rc 1, 104/108 |

`PRODUCTION_MUTANTS=3`; эти три К-08 прежнего вызова закрыты; для ошибки чтения HEAD в новом блоке различающей клетки нет. `git check-ref-format` допускает компоненты `;touch`, `$(id)`, `-x`, отвергает пробел, NUL невозможен в argv; это проверка грамматики, не доказательство отсутствия инъекции в guard.

## Регресс и дополнительные атаки

Чистый клон с origin, последовательно: семейство 200 rc 0 (11/11), 217 rc 0 (41/41), 210 rc 0 (342/342), `fail_closed_992.py` rc 0 (cases=25 failures=0), `verify_antiplacebo.sh --scope check_charter` rc 0 (13/13). 083 первый прогон rc 1, ok=117 FAIL=3: И0б/check_charter (rc guard 0, текст маркера есть), И0/check_zones (rc 141), И0б/check_zones (rc guard 0, текст маркера есть); это наблюдения теста, не доказанный новый регресс. До ранее наблюдался SIGPIPE у проверяющей трубы; адресный изолированный повтор обязателен.

Проба собственного тега v2 на переименованном пути `contracts/701-$(touch sentinel); test.md` с FAIL: rc 1, `sentinel=False`, в stderr название осталось буквальным и `заморозка v2 лежит поверх вердикта, который её не разрешил`. Это проверка одного имени и не доказательство безопасности произвольных имён. Батарея также проверила пустой scope, чужой поздний тег, shallow/forged base, оба guard и несколько версий. Полный перебор подмены основания и имён тегов отдельно не выполнен.

083 изолированный повтор дал тот же результат rc 1, ok=117 FAIL=3; И0/check_charter зелёная, И0б/check_charter rc guard 0 с маркером, И0/check_zones rc 141, И0б/check_zones rc guard 0 с маркером. Сравнение множества с базой проверяется отдельно; эти наблюдения сами по себе не дают делать вывод об исправности батареи.

### Б-2 нового вызова — К-08: HEAD FAIL заменяется accept основания

ПРОИСХОЖДЕНИЕ: дельта. В одноразовом клоне честной production `scripts/check_contract_frozen.sh:333` изменена ровно существующая строка: `if [ "$PR_ACTIVE" -eq 1 ] && [ -z "$body" ]; then` → `if [ "$PR_ACTIVE" -eq 1 ]; then`. Теперь существующий HEAD-вердикт на собственной заморозке безусловно заменяется вердиктом её основания. Воспроизведение: `git clone --no-hardlinks <честный-клон> <одноразовый-клон>`; заменить указанную строку один раз; `W --repo <одноразовый-клон>`. Наблюдение: rc 0, `KLETKI=108 ZELENYE=108 KRASNYE=0`. Парный реальный Git-мир из Б-1 без отказа инструмента: основание собственной v2 имеет accept, следующий собственный commit изменяет тот же вердикт на FAIL. Честная production rc 1 с причиной `первая строка «FAIL»`; мутант rc 0 `вердикты v1..v2 разрешают`. Это существенный обход И4 и прямое нарушение приоритета HEAD, явно заявленного в SDACHA; не выдуманное условие на распознавание фикстуры. ОСТАТОК: К-08 — укусил: указанный полный W зелён на мутанте, хотя честный контроль 108/108 и адресная поведенческая пара различает их. Старые три К-08 закрыты, новая дельта породила собственный живой.

083 базовый 682fb988 из чистого клона: rc 1, ok=118 FAIL=2, И0/check_zones rc 141 и И0б/check_zones rc 141; после: те же два и дополнительно И0б/check_charter с rc guard 0 и видимым маркером. Ранее суд вызова 1 уже получал И0б/check_charter красной на базе и связывал её с SIGPIPE тестовой трубы; текущие прогоны не доказывают её исправность либо новый дефект subject. Не объявляю 083 зелёной или доказанным регрессом.

#### Настоящий отказ Git без PATH-инъектора

Сильнее синтетического rc 127: тот же мир с настоящим Git, после успешного отрицательного контроля удалён ровно loose-объект blob HEAD-вердикта (не тег и не дерево основания). Дальнейшее чтение Git физически невозможно, остальное — прежнее; этот сбой содержимого репозитория и есть отказный случай И2, не подмена среды. Никакой wrapper PATH. Команда: `export ROOT="$PWD" TMPDIR="$PWD/tmp/scratch-adv218b"; python3 "$TMPDIR/missingblob.py"`; тело:

```python
import importlib.util, pathlib, tempfile, os, sys
root=pathlib.Path(os.environ['ROOT']); p=root/'fixtures/workshop_project/okno_frozen_v_pr_218/probe.py'
s=importlib.util.spec_from_file_location('probe',p); m=importlib.util.module_from_spec(s); sys.modules['probe']=m; s.loader.exec_module(m)
with tempfile.TemporaryDirectory(dir=os.environ['TMPDIR']) as x:
 d=pathlib.Path(x); w=m.World(d,m.Cell('x','clean','frozen')); v=f'verdicts/critic/contracts-{w.number:03d}-v2.md'
 anchor=w.commit({v:b'accept\n'},(w.head,),'own accepted freeze'); m.git(w.root,'tag','-a',f'frozen/contracts/{w.number:03d}/2',anchor,'-m','own v2')
 head=w.commit({v:b'FAIL\n'},(anchor,),'own change to verdict'); m.git(w.root,'update-ref','HEAD',head); m.git(w.root,'reset','--hard','-q',head)
 blob=m.git(w.root,'rev-parse',f'HEAD:{v}').decode().strip()
 for label in ('normal','missing'):
  if label=='missing': (w.root/'.git/objects'/blob[:2]/blob[2:]).unlink()
  t=d/label; t.mkdir(); r=w.run(m.sources(root),t,d/(label+'.trace'))
  print(label,'blob=',blob,'rc=',r[0],'stdout=',repr(r[1]),'stderr=',r[2].decode())
```

Сырой вывод: `normal blob=94e1707e853c36f514de3876408c09a0e0ca6fc4 rc=1` и диагноз «первая строка FAIL»; `missing blob=94e1707e853c36f514de3876408c09a0e0ca6fc4 rc=0`, `ok contracts/701-fixture.md — заморожен v2, блоб совпадает побайтово, вердикты v1..v2 разрешают`. В обоих случаях stdout пуст. Это непосредственное достижимое нарушение на честной production, а не только зависимость от имитации инструмента.

Буквальный `python3 fixtures/workshop_project/okno_frozen_v_pr_218/production_mutants.py` на чистом клоне дважды изолированно вернул rc 2 `NOT_IMPLEMENTED: TIMEOUT` на полном --repo первого мутанта; это не поимка и не оценка производственного поведения. Отдельный прогон тех же трёх мутаций с переназначением OBJECT на судимый commit завершился с PRODUCTION_MUTANTS=3, как указано выше. Буквальный драйвер всё равно закреплён на предыдущий OBJECT.
