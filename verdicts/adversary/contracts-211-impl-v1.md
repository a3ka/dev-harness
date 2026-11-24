FAIL
OBJECT=64457a6c0d43d20624adf24a9d9f7ade56eaf2bf
СУД: репо=dev-harness; предмет=211; роль=adversary; вызов=1 (полный); фаза=реализация; модель-план=openai-codex/gpt-6.1-terra; модель-факт=openai-codex/gpt-6.1-terra (метаданные запуска); предыдущий=нет; класс риска=рисковый

## Область
Судится неизменяемый OBJECT, автор implementer; diff к ecaa3f34e: единственный файл scripts/zamok_predmeta.sh (+109/−7). Контракт совпадает с frozen/contracts/211/1. Прогоны двери — в одноразовом клоне и мирах под TMPDIR; состояние станции не использовалось. Б-1 не относится к принятой границе risk_repo=носитель: у владельца и носителя одинаковый origin, владелец — отдельная станция мира.

## Регресс
Запуски в клоне OBJECT; сырые коды:

| Команда (пути от корня клона) | rc | результат |
|---|---:|---|
| `bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --repo .` | 0 | SUBJEKT 211: KLETKI 27 KRASNYH 0 |
| то же `--model` | 0 | MODEL 211: KLETKI 27 KRASNYH 0 |
| то же `--stabs` | 0 | MODEL 27/0; SVJAZI 54 ZHIVYH 0 |
| то же `--sintaksis` | 0 | SINTAKSIS OK |
| то же `--sosed-208` | 0 | SUBJEKT 208: KLETKI 35 KRASNYH 0 |
| то же `--negativ-208` | 0 | KLETKI 35 KRASNYH 2, r31/r32 |
| `bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --repo .` | 0 | 35/0 |
| `bash fixtures/workshop_project/obryv_167/red_obryv_167.sh --repo .` | 0 | CHECKED 8 CASES; FAILURES 0; merge ok |
| `bash fixtures/workshop_project/pre_judge_leak_185/red_pre_judge_leak_185.sh --repo` | 0 | пять случаев ZELENO; внутренние rc 0,1,1,2,2 |
| `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .` | 0 | CELLS=111 STABS=0 FAILURES=0 |
| `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model` | 0 | MODEL_KLETKI 244 KRASNYH 0 |
| `bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta` | 0 | 4/4 классов |
| `bash scripts/gen_ci_steps.sh --check` | 0 | без вывода |
| `bash scripts/pre_critic.sh contracts/211-d52-bootstrap-sudej.md` | 1 | сдаточный лист красен, см. Б-4 |
| `bash scripts/check_sdacha.sh "$PWD" contracts/211-d52-bootstrap-sudej.md --run` | 1 | строка 23: фактический rc=0 ≠ заявленного 1 |
| shellcheck 0.11.0 `-S warning scripts/zamok_predmeta.sh` | 1 | SC1090 ×1, SC2034 ×3; у базы те же четыре, новых нет |
| `bash -n scripts/zamok_predmeta.sh` | 0 | без вывода |

Первый ошибочный запуск 185 с `--repo .` дал rc 1 usage: эта батарея принимает `--repo` без аргумента; выше приведён повтор с поддерживаемым синтаксисом и TMPDIR. Shellcheck базы ecaa3f34e также rc 1, те же SC1090/SC2034. Ни этот унаследованный фон, ни известные якоря 140 не являются блоками.

## Атаки
Независимые миры построены штатными строителями probe211.py. Самодостаточная команда повторения Б-1 и Б-2 из корня одноразового клона OBJECT, с заранее созданным TMPDIR вне состояния станции (каждая итерация автоматически удаляет мир):

```sh
python3 -c '
import importlib.util, os, pathlib, tempfile
r=pathlib.Path.cwd(); f=r/"fixtures/workshop_project/d52_bootstrap_sudej_211/probe211.py"
s=importlib.util.spec_from_file_location("probe211",f); p=importlib.util.module_from_spec(s); s.loader.exec_module(p)
for case in ("unicode", "mode"):
 with tempfile.TemporaryDirectory(dir=os.environ["TMPDIR"]) as d:
  m=p.Mir(d); wt,br,F=p.nositel(m,p.SUBJ,"обычный")
  if case=="unicode":
   (pathlib.Path(wt)/"contracts/211-риск.md").write_text(p.kontrakt_tekst(p.SUBJ,"рисковый"),encoding="utf-8")
  else:
   os.chmod(pathlib.Path(wt)/"contracts/211-fixture.md",0o755)
  W=p.kommit(wt,"rabota/impl.txt","work\n"); p.avtor_sdal(m,p.SUBJ,wt,br); m.stancija_teg(wt,p.SUBJ,F)
  print(case,"F tree:",p.run(["git","-C",wt,"ls-tree",F+":contracts"]).stdout.decode(),"W tree:",p.run(["git","-C",wt,"ls-tree",W+":contracts"]).stdout.decode())
  out=p.sudit(r/"scripts/zamok_predmeta.sh",m,p.vyzov(m,"reviewer","Rev211",W))
  print("rc",out.returncode,"stdout",repr(out.stdout.decode()),"stderr",repr(out.stderr.decode()))
'
```

* `unicode`: заморожен `211-fixture.md` с обычным классом; в OBJECT после заморозки добавлен `211-риск.md` с рисковым. Git ls-tree отображает новое имя в кавычках и octal-escape; rc 0, `PUSCHEM Rev211 dev-harness/211 (sudja/reviewer)`, stderr пуст, в учёте START reviewer без adversary. Ожидается несовпадение перечней и отказ reviewer с KLASS_RISKA_NET + ADVERSARIJ_DO_REVJUERA. Тег annotated у отдельного владельца, F предок W.
* `mode`: в F mode 100644, в W 100755, тот же путь и тот же blob `0b86d5d8f8a54c73426355604f460ba4fd5595fa`. Результат rc 1, KLASS_RISKA_NET и ADVERSARIJ_DO_REVJUERA вместо допуска обычного предмета. Только mode отличается; состав и блобы совпадают.
* Независимые контроли: совпадающий ordinary — rc 0, чистый PUSCHEM; добавленный файл с пробелом, подмена текста, lightweight-тег, боковой коммит с тем же текстом, добавленные симлинк/подкаталог с именем `211-dir.md`, переименованный и удалённый файл — rc 1 с KLASS_RISKA_NET и ADVERSARIJ_DO_REVJUERA. Имена `.MD` и файл внутри обычного подкаталога — rc 0, вне прямого `NNN-*.md`. Незакоммиченная правка контракта носителя — rc 0 без предупреждения: читается OBJECT.
* Версии 009, 1a, v2 поверх /1 игнорируются (rc 0); очень длинная числовая версия и /10 при старом удостоверяющем /1, если новый тег lightweight, выбираются и отказывают (rc 1). Для annotated /9 обычный и /10 рисковый на предках OBJECT выбран /10: rc 1 с ADVERSARIJ_DO_REVJUERA без KLASS_RISKA_NET. critic-sol с живым тегом и отсутствующим pin — rc 0 с KLASS_RISKA_NET, прежний путь.
* Повтор в одном мире: первый adversary rc 0 PUSCHEM и START; повтор без сдачи rc 1 ZAMOK_BROSHEN; после сдачи и RELEASE повтор того же OBJECT rc 1 OBJECT_UZHE_SUZHEN; учёт содержит START автора, START adversary, RELEASE. Отдельную гонку параллельных вызовов не испытывал.
* Отказ-успех: дверь `exit 127`, `exit 1`, `exit 0` по отдельности дали `--repo` rc 1, 27 красных из 27. PATH с bash/python3/dirname без git/jq: `--model` rc 2, `NOT_IMPLEMENTED: нет git`. Положительный контроль — ordinary с annotated /1 и модель 27/0, не только крайние заглушки.

## Мутации
В одноразовом каталоге каждый раз одна копия production `scripts/zamok_predmeta.sh`; команда `bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --repo <каталог-мутант>`, затем удаление копии:

| Удалённая/заменённая операция | rc | Красные клетки |
|---|---:|---|
| проверка annotated | 1 | b15-legkij-teg |
| merge-base --is-ancestor | 1 | b06-chuzoj-tag-object |
| только сравнение списков, непустота сохранена | 1 | b05-podmena-klassa-v-objecte |
| только непустота списка | 1 | b19-net-fajlov-kontrakta |
| сортировка версий лексически | 1 | b20-versii-leksika-ne-chislo |
| 4-й аргумент по умолчанию `$REPO`, не `$wt` | 0 | 27/0, живой мутант |
| D64 также для critic | 1 | b09-critic-ne-menjaetsja |
| `git show "$obj:$kat/$put"` заменить `cat "$wt/$kat/$put"` | 1 | b12-zakreplennyj-frozen-prioritet, b13-frozen-risikovyj-porjadok |

Команда воспроизведения живого мутанта и наблюдаемого D52-входа в одноразовом клоне (миры раздельны):

```sh
python3 -c '
import importlib.util, pathlib, tempfile, os, subprocess
root=pathlib.Path.cwd(); f=root/"fixtures/workshop_project/d52_bootstrap_sudej_211/probe211.py"
s=importlib.util.spec_from_file_location("probe211",f); p=importlib.util.module_from_spec(s); s.loader.exec_module(p)
with tempfile.TemporaryDirectory(dir=os.environ["TMPDIR"]) as d:
 t=pathlib.Path(d); (t/"scripts").mkdir(); door=t/"scripts/zamok_predmeta.sh"
 source=(root/"scripts/zamok_predmeta.sh").read_text(); a="owner=\"${4:-$wt}\""; b="owner=\"${4:-$REPO}\""; assert source.count(a)==1
 door.write_text(source.replace(a,b,1))
 bat=root/"fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh"
 z=subprocess.run(["bash",str(bat),"--repo",str(t)]); print("mutant battery rc",z.returncode,flush=True)
 for label,subject in (("honest",root/"scripts/zamok_predmeta.sh"),("mutant",door)):
  with tempfile.TemporaryDirectory(dir=os.environ["TMPDIR"]) as world:
   m=p.Mir(world); wt,br,F,W=p.mir_bootstrap(m,p.SUBJ,None); p.avtor_sdal(m,p.SUBJ,wt,br); p.legacy_avtora(m,wt,W,p.SUBJ)
   z=p.sudit(subject,m,p.vyzov(m,"critic","Crit211",W)); print(label,"rc",z.returncode,"stdout",repr(z.stdout.decode()),"stderr",repr(z.stderr.decode()),flush=True)
'
```

Вход: ноль frozen-тегов, critic, отдельные станция и носитель с одинаковым origin, файл контракта без класса и legacy-строка `обычный` только в носителе. Честная дверь rc 0, `PUSCHEM Crit211 ...`, stderr пуст; мутант rc 0, тот же PUSCHEM, но stderr `KLASS_RISKA_NET: ... класс риска неоднозначно определён (neodnoznachno)`. Иной стаб st50 (`owner` пустой) — не эта замена.

## Блоки

БЛОКИРУЕТ Б-1 (К-09, безопасность): `scripts/zamok_predmeta.sh:823-827`, также `:690-692`. ОБЯЗАТЕЛЬСТВО: инварианты 1б3/2/3 требуют сравнивать весь перечень `NNN-*.md` и не занижать риск. СОСТОЯНИЕ/КОМАНДА: атака unicode выше — достижимая git-операция добавления файла после F, владелец отдельный. НАБЛЮДЕНИЕ: файл не участвует в сравнении, reviewer допущен rc 0 без adversary. ПРИЧИНА: обычный `git ls-tree` цитирует и экранирует не-ASCII имя целиком, поэтому поле имени начинается с `"`, не с `211-`, и awk его отбрасывает. Закрывающее свойство: все действительные имена glob и их блобы участвуют в сравнении и классификации без потерь байтов/границ имени.

БЛОКИРУЕТ Б-2 (К-14): `scripts/zamok_predmeta.sh:823-827`. ОБЯЗАТЕЛЬСТВО: одинаковые перечни имён и blob-ша удостоверяют OBJECT. СОСТОЯНИЕ/КОМАНДА: атака mode выше; единственное отличие — executable bit. НАБЛЮДЕНИЕ: rc 1, неверный KLASS_RISKA_NET, обычный предмет ошибочно рисковый. ПРИЧИНА: сравниваются полные записи ls-tree с mode вместо только имён и blob-ша. Закрывающее свойство: режим не влияет на удостоверение при равных перечнях и blob-ша.

БЛОКИРУЕТ Б-3 (К-08, проверка): `scripts/zamok_predmeta.sh:682`, `fixtures/workshop_project/d52_bootstrap_sudej_211/probe211.py` клетки b09/b27 и матрица стабов. ОБХОД: замена существующего умолчания владельца `$wt` на `$REPO` даёт `--repo` rc 0, 27/0, хотя достижимый critic/D52-вход выше меняет диагностику. Источник входа — поддерживаемая операция D52 и legacy в носителе; источник механизма — замена существующей операции `klass_riska`, не добавленный фильтр. Нужна различающая клетка и адресный стаб к фактическому коду (Н-39), а не только `--stabs` матрицы модели.

БЛОКИРУЕТ Б-4 (К-01, обязательное доказательство): `fixtures/workshop_project/d52_bootstrap_sudej_211/SDACHA.md:23` и `:79`. Команды из регресса `check_sdacha.sh ... --run` и `pre_critic.sh ...` обе rc 1 вопреки требуемому rc 0. Сырой вывод: `ОТКАЗ: строка 23: фактический rc=0 ≠ заявленного 1: bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --repo .`. Лист сам предусматривает адресное изменение двух рядов Red-do после реализации; frozen-контракт не менял. До устранения сдаточное доказательство не проходит.

## НЕ ЗАЩИЩАЕТ
ОСТАТОК: К-16 — укусил, но принят владельцем. Раздельный станционный/авторский мир: файл без класса, незакоммиченный legacy обычный только у автора. При совпадающем origin и владельце-станции reviewer rc 1, неоднозначность и ADVERSARIJ_DO_REVJUERA; при другом origin и выборе носителя владельцем — reviewer rc 0, PUSCHEM. Это граница risk_repo=носитель, не Б-1; ловцы adversary/reviewer и отдельный системный предмет. Незакоммиченные профиль/legacy выбранного владельца — тот же принятый остаток; чтение HEAD — отдельный предмет.

Остальные названные остатки: D52 читает носитель (отдельный предмет), живость origin-тега (оркестратор), свежесть origin-view/преддверие 172 (208/172), байтовая форма учёта (отдельный предмет), профиль проектного реестра (батареи registry-profile), конечность матрицы (adversary/reviewer). Живую станцию не испытывал.

## Советы
Сравнивать имена Git в NUL-разделённом формате и отделять mode от blob-id — возможный способ, не предписание реализации. Держать регрессионные входы с Unicode и отдельно с изменением одного только executable bit. Пустую версию и параллельную гонку не объявляю проверенными.
