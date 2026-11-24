FAIL
OBJECT=ab7896812c30e10b815c91b534a40ea1b4f230f3
СУД: репо=dev-harness; предмет=211; роль=adversary; вызов=2 (узкий повтор по SANKCIJA консультанта; бюджет 1 полный + ≤1 scoped); фаза=реализация; модель-план=openai-codex/gpt-6.1-terra; модель-факт=openai-codex/gpt-6.1-terra; предыдущий=verdicts/adversary/contracts-211-impl-v1.md (FAIL, в archive-ref); класс риска=рисковый

## Область

Независимый повтор ремонта 1315a7da8/f633c6b2c на неизменяемом OBJECT, база 1ec47271534b8c468611ce26a7769eaeec298644. Diff к базе — scripts/zamok_predmeta.sh и fixtures/workshop_project/d52_bootstrap_sudej_211/**. Исследуются закрытие Б-1…Б-4, зависимый регресс общей функции klass_riska и соседние мутанты. Состояние станции не использовалось: одноразовый клон и миры — в tmp/adv211b этой копии; TMPDIR внутри копии из-за ограничений изоляции агента, а не указанный внешне /tmp. Реальный git выдаёт tree в каноническом порядке; специально изменённый порядок ниже — только инъекция инструмента, не доказанная достижимость на штатном git.

## Регресс

Команды выполнялись последовательно в одноразовом клоне OBJECT; коды — сырые. `B` = `bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh`.

| Команда | rc | результат |
|---|---:|---|
| `B --repo .` | 0 | 43 клетки, 0 красных |
| `B --model` | 0 | 43/0 |
| `B --stabs` | 0 | 43/0, SVJAZI 61 ZHIVYH 0 |
| `B --sintaksis` | 0 | SINTAKSIS OK |
| `B --sosed-208` | 0 | 35/0 |
| `B --negativ-208` | 0 | 35/2, ровно r31/r32 |
| `bash scripts/pre_critic.sh contracts/211-d52-bootstrap-sudej.md` | 0 | дверь зелёная |
| `bash scripts/check_sdacha.sh "$PWD" contracts/211-d52-bootstrap-sudej.md --run` | 0 | двери=17 карта=17/17 дельта=2 |
| `bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --repo .` | 0 | 35/0 |
| `bash fixtures/workshop_project/obryv_167/red_obryv_167.sh --repo .` | 0 | 8 cases, failures 0, merge ok |
| `bash fixtures/workshop_project/pre_judge_leak_185/red_pre_judge_leak_185.sh --repo` | 0 | 5 ZELENO, внутренние rc 0/1/1/2/2 |
| `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .` | 0 | CELLS=111 STABS=0 FAILURES=0 |
| `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model` | 0 | 244/0 |
| `bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta` | 0 | 4/4 |
| `bash scripts/gen_ci_steps.sh --check` | 0 | без вывода |
| shellcheck 0.11.0 `-S warning scripts/zamok_predmeta.sh` | 1 | SC1090 и SC2034 ×3; на базе те же предупреждения, rc 1 |
| `bash -n scripts/zamok_predmeta.sh` | 0 | без вывода |

Б-3 прежнего вердикта различается b37 (см. мутации), Б-4 — оба сдаточных гейта rc 0.

## Атаки

Повтор команды unicode/mode из §Атаки v1 на новой двери: unicode после F — rc 1, KLASS_RISKA_NET и ADVERSARIJ_DO_REVJUERA; смена только 100644→100755 — rc 0 PUSCHEM, stderr пуст. Б-1 и Б-2 в этих сценариях закрыты. Отдельные миры, тот же builder probe211.Mir/nositel/kommit/avtor_sdal/stancija_teg/sudit:

- Добавление `211-cr\r.md`, `211-\x01.md`, `211-` + 243 x + `.md`, `211--foo.md` после F — каждый rc 1, KLASS_RISKA_NET и ADVERSARIJ_DO_REVJUERA. Прямой basename по грамматике всегда начинается с `211-`; пробовался ведущий дефис после этого обязательного префикса.
- `211-риск.md` с другим классом существует в обоих деревьях наряду с ordinary: rc 1, neodnoznachno и ADVERSARIJ_DO_REVJUERA. Тот же Unicode-файл с ordinary и равным blob в обоих — rc 0, чистый PUSCHEM. Эквивалентный обычный вход — rc 0. Это положительные контроли.
- Добавление `.MD` либо `sub/211-other.md` — rc 0, они вне прямого `NNN-*.md`. Exec-bit плюс изменение blob, удаление и переименование — rc 1 с KLASS_RISKA_NET и ADVERSARIJ_DO_REVJUERA.
- Инъекция git-обёртки, которая переворачивает порядок записей `ls-tree -z` только дерева F, при двух одинаковых обычных файлах в F/OBJECT — rc 1, KLASS_RISKA_NET и ADVERSARIJ_DO_REVJUERA. Это ненормальный git и не самостоятельный блок: у штатного git порядок фиксирован деревом.
- Негативный контроль до ремонта: текущая батарея на production 64457a6c0d43d20624adf24a9d9f7ade56eaf2bf — rc 1, 43 клетки, 13 красных.

## Мутации

Каждая меняла одну копию production, отдельный временный каталог и штатный `bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --repo <каталог>`; копия удалялась до следующей. Сырые rc батареи:

| Мутант | rc | красные клетки |
|---|---:|---|
| ls-tree без -z, фильтр цитированного вывода | 1 | 10, в т.ч. b28/b30–b33, b38/b40–b43 |
| -z, но grep до разбора NUL | 1 | 33, в т.ч. b01/b28/b34 |
| сравнивать mode | 1 | b34 (ровно одна) |
| пустой перечень удостоверяет | 1 | b19 (ровно одна) |
| разрешить 120000 с обеих сторон удостоверения | 1 | b35 (ровно одна; расходится диагностика) |
| разрешить 040000 с обеих сторон удостоверения | 1 | b36 (ровно одна; расходится диагностика) |
| умолчание owner=$REPO | 1 | b37 (ровно одна) |
| читать файл по рабочему пути вместо blob | 1 | b12/b13 |
| D64 для critic | 1 | b09 (ровно одна) |
| жёстко задать номер 211 в выборе тега | 1 | b16/b22/b23/b26 |

Одностороннее ослабление проверки mode только для OBJECT и отдельное удаление только проверки blob-типа дали rc 0, 43/0: другая проверка того же типа оставалась активной, поэтому эти частичные мутации сами по себе не демонстрируют достижимого изменения поведения. Двусторонние мутации выше красны. Двери `exit 127`, `exit 1`, `exit 0` по отдельности: батарея rc 1, 43/43 красных. PATH только с bash/python3/dirname, без git/jq: --model rc 2, `NOT_IMPLEMENTED: нет git`.

## Блоки

БЛОКИРУЕТ Б-1 (К-01, зависимый регресс; `scripts/zamok_predmeta.sh:689-701,718-751`). **ОБЯЗАТЕЛЬСТВО:** инварианты 4 и 8 контракта сохраняют critic/D52 и входы вне D64 байт-в-байт; прежняя `klass_riska` допускала несколько файлов предмета и сообщала несовпадающие классы. **СОСТОЯНИЕ:** два обычных git-файла с допустимыми именами предмета, разные значения класса, ноль frozen-тегов, critic, отдельные станция и носитель с одинаковым origin. Это поддерживаемая операция добавления файлов, не синтетическая подмена инструмента. **НАБЛЮДЕНИЕ:** база и OBJECT возвращают rc 0 и одинаковый PUSCHEM, но в stderr база называет `211-a.md`, а OBJECT — `211-z.md`. База сортировала целую запись ls-tree (mode, type, blob, имя); новая функция перебирает дерево по имени. Какой файл попадает в ploh, зависит от порядка, потому текст диагностики на существующем D52-пути поменялся. Батарея SUBJECT 211 не покрывает это состояние. Закрывающее свойство: сохранить прежнюю байтовую диагностику для прежней области, не возвращая потерю NUL-имен и не сломав D64.

Воспроизведение из корня одноразового клона OBJECT с созданным TMPDIR (все миры отдельные):

```sh
python3 -c '
import importlib.util,pathlib,tempfile,os,subprocess
r=pathlib.Path.cwd(); f=r/"fixtures/workshop_project/d52_bootstrap_sudej_211/probe211.py"
s=importlib.util.spec_from_file_location("p",f); p=importlib.util.module_from_spec(s); s.loader.exec_module(p)
with tempfile.TemporaryDirectory(dir=os.environ["TMPDIR"]) as d:
 base=pathlib.Path(d)/"base.sh"
 base.write_bytes(subprocess.run(["git","show","1ec47271534b8c468611ce26a7769eaeec298644:scripts/zamok_predmeta.sh"],capture_output=True,check=True).stdout)
 for label,door in (("base",base),("subject",r/"scripts/zamok_predmeta.sh")):
  with tempfile.TemporaryDirectory(dir=os.environ["TMPDIR"]) as wd:
   m=p.Mir(wd); wt,br,F=p.nositel(m,p.SUBJ,"обычный"); k=pathlib.Path(wt)/"contracts"
   (k/"211-fixture.md").unlink()
   (k/"211-a.md").write_text(p.kontrakt_tekst(p.SUBJ,"рисковый"))
   (k/"211-z.md").write_text(p.kontrakt_tekst(p.SUBJ,"обычный"))
   W=p.kommit(wt,"rabota/impl.txt","work\n"); p.avtor_sdal(m,p.SUBJ,wt,br)
   out=p.sudit(door,m,p.vyzov(m,"critic","Crit211",W))
   print(label,"rc",out.returncode,"stdout",repr(out.stdout.decode()),"stderr",repr(out.stderr.decode()))
'
```

Результат: оба rc 0, stdout `PUSCHEM Crit211 dev-harness/211 (sudja/critic)\n`; stderr `... (neodnoznachno); файлы: 211-a.md ...` на базе, `... файлы: 211-z.md ...` на OBJECT. Соответствующие blob-id a1c4cd545d2a6e7986318300d87fe49321433b6f и 0b86d5d8f8a54c73426355604f460ba4fd5595fa.

## НЕ ЗАЩИЩАЕТ

ОСТАТОК: К-16 — укусил, граница принята владельцем. `probe211.Mir` + `mir_bootstrap(..., klass_f=None)` + `legacy_avtora`, затем `stancija_teg` и `sudit(... reviewer ...)` в двух мирах: при совпадающем origin владелец — станция, rc 1 neodnoznachno и ADVERSARIJ_DO_REVJUERA; при изменённом origin и теге в носителе владелец — носитель, rc 0 PUSCHEM. Ловцы — adversary/reviewer; исправление выбора владельца — отдельный предмет. Эта граница не объясняет Б-1: там одинаковый origin, critic и D52.

Другие объявленные границы: D52 читает профиль/legacy носителя; живость origin-тега и свежесть origin-view — оркестратор/208; байтовая форма учёта — отдельный предмет; проектный реестр — батареи registry-profile; конечная матрица — судьи. Живую станцию и параллельную гонку не испытывал.

## Советы

Отдельно фиксировать в батарее D52 несколько файлов с различающимися декларациями и заведомо противоположными порядками имён и blob-id; различать специально переставленный вывод подменённого git от достижимого состояния штатного git.
