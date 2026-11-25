FAIL
OBJECT=b1d400da33875adff8551e4098ccb30fda936718
СУД: репо=dev-harness; предмет=217; фаза=реализация; роль=adversary; вызов=2 (узкий; SANKCIJA); сессия=Adv217c; модель-факт=openai-codex/gpt-6.1-terra; автор Architect217c — gpt-6.1-sol; предыдущий=archive/217/adversary-v1-fail-2b624c289a; класс=рисковый

## Блоки

**БЛОКИРУЕТ К-08 — закрытие сравнения SHA ограничено десятью знаками, а не полным равенством.** ПРОИСХОЖДЕНИЕ: узкое-закрытие предыдущего Б-1. Место: `fixtures/workshop_project/incr_pustoe_okno_217/probe.py:143-144,255-258`, `prefix10.py:21-57`, сравниваемая операция `scripts/check_charter.sh:876`; обязательство И3 и решение контракта 217: строгий предок не равен HEAD, непустое окно судится, отказ не продвигает кеш. Значения SHA не меняют смысл.

ОБХОД: единственная замена `[ "$INCR_BASE" = "$INCR_HEAD" ]` на `[ "${INCR_BASE:0:11}" = "${INCR_HEAD:0:11}" ]` в production; полная W `--repo .` возвращает **rc 0, 41/41/0**. Источник механизма — замена реальной операции равенства, не добавленный посторонний фильтр. Источник входа — реальная поддерживаемая история Git: 200000 обычных последовательных предков от `git init`, запрещённая правка AGENTS.md в потомке, валидный кеш со строгим предком. Git сам записывает и разрешает оба объекта и подтверждает `merge-base --is-ancestor`. Это не строки, подставленные двойником Git. Полная production на том же состоянии rc 1 и кеш остаётся на базе; мутант rc 0 и записывает непроверенный HEAD. Воспроизводимый построитель и сырой вывод ниже. Следовательно предыдущая восьмизначная дыра закрыта примером, но не классом укороченного сравнения. Не утверждается, что честная production ошибочна. Свойство закрытия: отличать допустимое полное сравнение от такого укорочения на достижимом непустом окне, сохраняя разрешённый соседний исход; не предписываю конкретный тест или привязки Н-39.

Арбитраж конечной границы: повтор К-08 о том же классе SHA; действовать по §Остановка после фиксации позиции автора, этот вердикт не даёт согласия на изменение контракта.

## Остатки

Предыдущий Б-2 снят по предъявленному примеру: перенос исходной ранней ветви до `ustav/1` в production дал W rc 1, красные e10/e11; M22 подтверждён также `--production-stabs`. Б-1 именно для 8 и 10 знаков пойман, но более широкое свойство остаётся блоком выше. w16 и w17 используют настоящие объекты Git с одинаковыми первыми десятью символами, не Git-мок. Миры отсутствия тега создаются через `git init` и fast-import, затем созданный шаблоном тег удаляется (`probe.py:151-169,290-291`); не утверждаю, что конструктор ни разу не создавал тег.

## Регресс

Чистый отдельный клон только с сетевым origin, detached OBJECT; `git merge-base --is-ancestor 4576309b967a22818cd7c2ed0738333dd014ca80 HEAD` rc 0. `git diff --name-status b7c5a9807 HEAD`: ровно SDACHA.md, model/empty_window.sh, prefix10.py, probe.py, source.json, stabs.tsv под семьёй 217; `git diff b7c5a9807 HEAD -- scripts contracts registry .github` пуст. Прежние клетки не удалены; изменение якоря модели переносит вставку после стража тега.

W = `bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh`:
```
W --repo .             rc=0 KLETKI=41 ZELENYE=41 KRASNYE=0
W --model              rc=0 KLETKI=41 ZELENYE=41 KRASNYE=0
W --stabs              rc=0 MUTACII=23 SVJAZI=29 POIMANY=29 ZHIVYH=0
W --repo . --production-stabs rc=0 MUTACII=8 SVJAZI=10 POIMANY=10 ZHIVYH=0
W --repo . --independent-mutants rc=0 prefix10=POIMAN before-cache=POIMAN
W --model --live       rc=0 LIVE commits=9175 seconds=0.026 rc=0
W --catalog            rc=0 KLETKI=41 MUTACII=23 SVJAZI=29
W --syntax             rc=0 SYNTAX bash=2 python=2 rc=0
210 --repo .           rc=0 KLETKI=342 ZELENYE=342 KRASNYE=0
bash fixtures/charter_fast_113/red_113.sh rc=0 клеток: 28 · красных: 0
bash scripts/gen_ci_steps.sh --check rc=0
bash scripts/check_provodka.sh . 217 rc=2 NOT_IMPLEMENTED: контракта нет: .../217
bash scripts/check_provodka.sh . contracts/217-incr-pustoe-okno.md rc=0
```
Полные pre_critic, check_sdacha и 083 не запускались: вложенный check_zones сбрасывает TMPDIR и пишет за пределами разрешённого дерева. Следовательно их исход не заявляется. Отдельные 210 --model/--stabs и 207/200 в этом вызове не выполнялись; результаты вызова 1 не подменяют новый запуск. TMPDIR был в разрешённой копии, а не в запретном внешнем /tmp; нагрузка станции измерялась `uptime` (8.83, 10.65, 17.16).

## Мутации

Каждая отдельно в другом одноразовом клоне, полный W `--repo .`, исходные байты возвращались до следующей. Позитивный production и модель выше. Сырые итоги:
```
prefix8             rc=1 KLETKI=41 ZELENYE=39 KRASNYE=2 (w16,w17)
prefix9             rc=1 KLETKI=41 ZELENYE=39 KRASNYE=2 (w16,w17)
prefix11            rc=0 KLETKI=41 ZELENYE=41 KRASNYE=0
prefix12            rc=0 KLETKI=41 ZELENYE=41 KRASNYE=0
base8 versus head40 rc=1 KLETKI=41 ZELENYE=32 KRASNYE=9 (e1..e9)
nonempty && prefix8 rc=1 KLETKI=41 ZELENYE=39 KRASNYE=2 (w16,w17)
exit before cache   rc=1 KLETKI=41 ZELENYE=6 KRASNYE=35 (включая c9)
skip ustav при base=head rc=1 KLETKI=41 ZELENYE=39 KRASNYE=2 (e10,e11)
incr_finish пишет при rc!=0 rc=1 KLETKI=41 ZELENYE=31 KRASNYE=10
перенос пустой ветви до ustav rc=1 KLETKI=41 ZELENYE=39 KRASNYE=2 (e10,e11)
```
12-значная мутация жива в батарее; отдельная настоящая 12-значная коллизия не строилась и второй блок не заявляется. 11-значная предъявлена отдельно ниже. Оба новых prefix10-мира проверяют не только rc, но и полный вывод/кеш: w17 краснеет даже при rc 0, поскольку теряется настоящий вывод суда.

Сырой адресный production-контроль:
```
M21_PREFIX8 -> w16-prefix10-denied: POIMAN
M22_BEFORE_USTAV -> e10-no-ustav: POIMAN
M22_BEFORE_USTAV -> e11-no-ustav-oracle-no-lf: POIMAN
M23_NO_USTAV -> e10-no-ustav: POIMAN
PREFIX10 ... allowed=False base=24b196d23630c5c795520c13ccbb6fdaa2606ae0 head=24b196d236f633ddec9ecde743e822f6ab25442f window=6498
PREFIX10 ... allowed=True base=137d4b03f733c91ac1e5f774a650c4e1d30a2918 head=137d4b03f7ed9b8918756bc73eaffde3128d20c7 window=18941
```

## НЕ ЗАЩИЩАЕТ

- ОСТАТОК: К-16 — укусил: `W --repo . --cell e5-empty-old-violation` rc 0, `KLETKI=1 ZELENYE=1 KRASNYE=0`; кеш HEAD доверяется, старое нарушение не пересуживается. Это явная граница, не блок.
- ОСТАТОК: К-10 — укусил: вставить `git -C "$ROOT" rev-list HEAD >/dev/null` перед `incr_finish 0`, `W --repo . --cell e2-empty-5000`: rc 0, `seconds=0.042 git=7 discovery=0 GREEN`, 1/1/0. Полный rev-list вне набора запрещённых Trace2-команд прямо назван остатком.
- ОСТАТОК: К-06 — не укусил: отдельного отказа железа или искусственной внешней нагрузки не создавалось; измеренный штатный e2 выше не доказывает устойчивость к произвольной нагрузке.
- ОСТАТОК: К-03 — не укусил: новый нелинейный мир публикации не создавался; указанная production 210 прошла 342/342, что не является доказательством всех merge-миров.

## Советы

После исправления сохранить независимый позитивный контроль и обе полярности; адресные связи стабов устанавливает architect по коду, не проза контракта. Ограничения среды передать оркестратору для полных дверей.

## Воспроизведение реальной 11-hex коллизии

Запущен `python3 reproduce.py <путь-к-чистому-клону-OBJECT>` с TMPDIR внутри разрешённой копии. Выигрышная соль 84888581 найдена отдельным перебором SHA-1 на 200001 предке; повторный скрипт ниже её воспроизводит без перебора. Сырой вывод повторного запуска (rc 0):
```
HISTORY commits=1 documents=3
GIT 31bf0f645b89bcb246a8bcf6eae99b0086442254 31bf0f645b8bc856b1be5485989ce03cc2b47ad9
honest rc= 1 cache= 31bf0f645b89bcb246a8bcf6eae99b0086442254
prefix11 rc= 0 cache= 31bf0f645b8bc856b1be5485989ce03cc2b47ad9
```
В первом запуске дополнительно наблюдался маркер `(193933 коммита)` и честный диагноз `FAIL уставной документ изменён без разрешения владельца`; мутант напечатал только маркер. Скрипт импортирует именно существующие конструктор/исполнитель семьи, но объекты строит настоящим Git и не меняет проверку или production клона.

```python
from pathlib import Path
import sys, tempfile
repo=Path(sys.argv[1]).resolve()
sys.path.insert(0,str(repo/'fixtures/workshop_project/incr_pustoe_okno_217'))
import probe
with tempfile.TemporaryDirectory() as t:
 d=Path(t); template=d/'template'; probe.seed(template,1,1)
 w=probe.World(d,template,probe.Cell('attack',empty=True))
 ident=b'architect <architect@dev-harness.local> 1700000000 +0000\n'
 stream=bytearray()
 for n in range(200000):
  msg=f'collision11 ancestor {n}\n'.encode()
  stream+=b'commit refs/heads/main\ncommitter '+ident+f'data {len(msg)}\n'.encode()+msg
  if n==0: stream+=f'from {w.base}\n'.encode()
  stream+=b'\n'
 probe.git(w.root,'fast-import','--quiet',data=bytes(stream))
 parent=probe.git(w.root,'rev-parse','HEAD').decode().strip()
 target='31bf0f645b89bcb246a8bcf6eae99b0086442254'
 (w.root/'AGENTS.md').write_text('forbidden attack\n'); probe.git(w.root,'add','--','AGENTS.md')
 tree=probe.git(w.root,'write-tree').decode().strip()
 body=f'tree {tree}\nparent {parent}\n'.encode()+b'author '+ident+b'committer '+ident+b'\nprefix11 attack 84888581\n'
 head=probe.git(w.root,'hash-object','-t','commit','-w','--stdin',data=body).decode().strip()
 probe.git(w.root,'reset','--hard','-q',head)
 print('GIT',probe.git(w.root,'rev-parse',target,'HEAD').decode().strip().replace('\n',' '))
 assert target!=head and target[:11]==head[:11]
 probe.git(w.root,'merge-base','--is-ancestor',target,head)
 selected=probe.sources(repo)
 for name,mutate in [('honest',False),('prefix11',True)]:
  w.cache.write_text(target+'\n'); variant=dict(selected)
  if mutate:
   p=probe.FILES[0]; variant[p]=probe.replace(variant[p],b'[ "$INCR_BASE" = "$INCR_HEAD" ]',b'[ "${INCR_BASE:0:11}" = "${INCR_HEAD:0:11}" ]')
  result,_=w.run(variant,limit=120)
  print(name,'rc=',result[0],'cache=',w.cache.read_text().strip(),flush=True)
```
