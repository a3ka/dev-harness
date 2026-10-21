accept
Круг 3, дельта a294171fb..b726bae8d. Б-3 закрыт: семантика И-5 и И-7 совпадает с frozen/contracts/120/1 дословно, к ней добавлены только комментарии. Б-2 закрыт по существу: локальные ignore и неотслеживаемый `.gitignore` больше не прячут файл вне зоны. С-1 закрыт: sparse-клон даёт rc 2. Зона, контракт и pin_120.json не тронуты. Нового обхода и ложного красного на честной спеке не нашёл. Советы — в review.md, слияние они не блокируют.
OBJECT=0d4647307f3a5a34ce493ba0019f6be6e95db147

Судья: Rev120c (reviewer). Батарея: wip/120/architect @ b726bae8d402119a78183f92ed3b9e177e892649, клон `/tmp/dev-harness-verify/Rev120c/h`. Находки: `/tmp/dev-harness-verify/Rev120c/review.md` (reslop, status: ready). Все советы, блокеров нет.

## 1. Область правки
- `git diff --name-status a294171fb..b726bae8d`: 9 путей, все под `fixtures/workshop_project/mobility_spec_120/`. Из них 3 M, 4 A, 2 D.
- Diff вне этого каталога пуст.
- Один коммит, автор `architect`, тема «120 круг 3: …».
- `git diff frozen/contracts/120/1^{commit} b726bae8d -- contracts/ '*pin_120*'` пуст: контракт и пин как во frozen.
- Норма не тронута.

## 2. Б-3: возврат к frozen
`git diff 37280b8b(frozen) b726bae8d -- mobility_spec_oracle.py`:
- `wunsch_tipizirovany` и ⊇-половины `graf_vneshnie` нет.
- И-5 — прежний цикл `n in allowed ∧ n ∉ deprecated`, в diff против frozen добавлен только комментарий.
- И-7 — строка frozen `need(ext_nodes <= set(pin["external_dependencies"]), "graf-nepolny", …)`, без изменений.
- Против frozen добавлены только `skrytye_indeksom` (круг 2, И-2), `neotslezhivaemye`, `gitignore_neotslezhivaemye` и `sparse_checkout`.

Конформные клоны Adv120b (копии в `probes/adv-*`, оракул b726bae8d):

| Клон | rc | Вывод |
|---|---:|---|
| frozen-conformant-existing-ops | 0 | `MOBILITY120_OK processes=5 new_operations=2 errors=15 nodes=20 pin=real` |
| omit-external | 0 | `MOBILITY120_OK processes=5 new_operations=7 errors=15 nodes=19 pin=real` |
| no-new-operations | 0 | `MOBILITY120_OK … new_operations=0 …` |
| assume-unchanged | 1 | `ОТКАЗ: mobility120: vne-zony (server/src/logger.js)` |
| skip-worktree | 1 | `ОТКАЗ: mobility120: vne-zony (server/src/logger.js)` |

`no-new-operations` — это обход Adv120 (2), остаточный риск Н-397. По заданию его не FAIL-ю.

## 3. Б-2 / С-1: пробы на копиях ОБЪЕКТА (`probes.sh`, `probes2.sh`)

| Проба | rc | Первая строка |
|---|---:|---|
| honest (клон 0d46473) | 0 | `MOBILITY120_OK processes=5 new_operations=7 errors=15 nodes=20 pin=real` |
| контроль: `server/src/evil.js` без сокрытия | 1 | `vne-zony (server/src/evil.js)` |
| evil.js под `.git/info/exclude` | 1 | `vne-zony (server/src/evil.js)` |
| evil.js под `core.excludesFile` | 1 | `vne-zony (server/src/evil.js)` |
| неотслеживаемый самоигнорирующий `server/src/.gitignore` (`*`) | 1 | `vne-zony (server/src/.gitignore)` |
| assume-unchanged `server/src/logger.js` | 1 | `vne-zony (server/src/logger.js)` |
| skip-worktree `server/src/logger.js` | 1 | `vne-zony (server/src/logger.js)` |
| честный: `node_modules/**` с вложенными `.gitignore`, `server/node_modules/b/.gitignore`=`*`, `.env`, `x.log` | 0 | `MOBILITY120_OK … pin=real` |
| живой раннер на `Rev120c/back` | 0 | `ПРОДУКТ …: MOBILITY120_OK processes=5 new_operations=7 errors=15 nodes=20 pin=real`, `ИТОГ 120 (продукт): rc=0` |
| копия `cp -a` рабочего клона Impl120/back @0d46473 | 0 | `MOBILITY120_OK … pin=real` |
| sparse-checkout честного (`--no-cone /docs/ /tests/ /server/`) | 2 | `нечем судить: sparse-checkout: содержимое вне конуса не видно` |

Собственные обходы дельты. Ни один не прошёл:

| Обход | rc | Первая строка |
|---|---:|---|
| самоигнорирующий `.gitignore`, сам спрятанный в `info/exclude` | 1 | `vne-zony (server/src/.gitignore)` |
| `.gitignore` с одной строкой `evil.js` (себя не матчит) | 1 | `vne-zony (server/src/.gitignore)` |
| новый каталог `newdir/` с `*` | 1 | `vne-zony (newdir/.gitignore)` |
| вложенный git-репозиторий `server/src/evilpkg/` (с `*` и без) | 1 | `vne-zony (server/src/evilpkg/)` |
| обман атрибуции `check-ignore`: `core.excludesFile` → ОТСЛЕЖИВАЕМЫЙ `docs/spec/…/notes.txt` (`.gitignore`) | 1 | `vne-zony (server/src/.gitignore)` |
| тот же обман, `notes.txt` только staged | 1 | `vne-zony (server/src/.gitignore)` |
| intent-to-add самоигнорирующего `.gitignore` | 1 | `vne-zony (server/src/.gitignore)` |
| staged `.gitignore` + assume-unchanged | 1 | `vne-zony (server/src/.gitignore)` |
| `core.sparseCheckout=true` + evil.js | 2 | `нечем судить: sparse-checkout…` (зелёным не становится) |
| неотслеживаемый `.gitignore` внутри spec_dir | 0 | в зоне, честно |
| frozen-оракул на обмане атрибуции | 0 | `MOBILITY120_OK` (у frozen этот класс не закрыт) |

Обман атрибуции подробнее. `check-ignore` действительно приписывает покрытие отслеживаемому источнику. Но тот же `.gitignore` остаётся виден в `ls-files --others --exclude-per-directory=.gitignore`. Чтобы спрятаться от этого вызова, `.gitignore` должен совпасть с per-directory шаблоном. Самый глубокий такой шаблон — он сам, а он не отслеживается, поэтому две ветви закрывают друг друга.

## 4. Батарея моей мерой
- `--model` → rc 0, `ИТОГ 120: клеток 52, зелёных 52, красных 0`. Свой подсчёт разбором `CELLS` в python: 52 = d* 49 + g* 1 + m-baza + k-model. У каждой d*/g* есть ветвь `mutate` в модели.
- `--stabs` → rc 0, `ИТОГ 120 стабы: строк 18, расхождений 0`. Разбор `STABS`: 18 строк.
- Двунаправленная ловля:
  - `MOBILITY120_ORACLE=stab_vsegda_zelenyj.sh --model` → rc 1, `клеток 52, зелёных 2, красных 50`;
  - `stab_vsegda_krasnyj.sh` → rc 1, `клеток 52, зелёных 2, красных 50`.
- Красное против сломанной реализации — настоящий оракул круга 2 @a294171 (`r2/`):

| Клетка | rc | Факт |
|---|---:|---|
| d50 | 1 | `MOBILITY120_OK` вместо `vne-zony` |
| d51 | 1 | `MOBILITY120_OK` вместо `vne-zony` |
| d52 | 1 | `vne-zony` вместо rc 2 |
| g01 | 0 | честный дифференциал, зелёный и на старом оракуле |

  Против строгого стаба `stab_gitignore_vse.py` g01 красная (rc 1 в `--stabs`).
- Расхождение со строками 2 и 4 замороженной приёмки (46→52; 1/45 и 2/44 → 2/50 и 2/50) честную спеку не краснит:
  - k-model rc 0, g01 rc 0;
  - живой OBJECT rc 0;
  - конформные клоны Adv120b rc 0.

  Ловля в обе стороны сохранилась. Строки приёмки устарели — это совет С-1 в review.md: их освежает оркестратор или владелец, не задача о механизме.

## 5. Паразитная сложность (050): пять вопросов по артефактам дельты

| Артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель / повтор | Класс |
|---|---|---|---|---|---|---|
| `neotslezhivaemye` | И-2 «+ неотслеживаемые» | нет; пути видны в выводе `vne-zony` | 4: оракул, модель, раннер, стаб (как в круге 2) | 1 вызов git, интерфейс не растёт | d50, `--model`; заменяет строку `--exclude-standard`, не дублирует | ESSENTIAL |
| `gitignore_neotslezhivaemye` | И-2: неотслеживаемый `.gitignore` сам скрывает неотслеживаемое | нет; путь `.gitignore` в выводе | 4 | ~20 строк за неизменным интерфейсом | d51/g01. Форма «любой неотслеживаемый `.gitignore` → red» проще, но краснит честные `node_modules/**/.gitignore` (stab_gitignore_vse × g01 rc 1) | ESSENTIAL |
| `sparse_checkout` | И-2 судится по содержимому; нечем судить → rc 2 | читает `core.sparseCheckout`, строка rc 2 явна | 4 | 1 вызов | d52 | ESSENTIAL (граница — С-3) |
| клетки d50–d52, g01 + `g*` в раннере | И-2; дифференциал g01 — против ложного красного | мутации видны в `mutate` | 2: модель, раннер | +1 ветвь `case` | `--model` (строка приёмки 2) | ESSENTIAL |
| `.gitignore` `node_modules/` в `build_world` | правдоподобие мира для g01 | в базе мира, явно | 1 | — | g01 | ESSENTIAL |
| семья `stab_*.py` (+4/−2) | Н-39, привязка стабов к ветвям по коду | нет | +1 файл на ветку | загрузчик копируется | `--stabs` | ACCIDENTAL — совет С-2 (нет строки приёмки, которую простая форма проходит, а нынешняя нет) |

## Итог прогонов (rc)
| Прогон | rc |
|---|---:|
| `--model` | 0 |
| `--stabs` | 0 |
| vsegda_zelenyj `--model` | 1 |
| vsegda_krasnyj `--model` | 1 |
| живой OBJECT | 0 |
| копия Impl120/back | 0 |
| Adv120b conformant ×3 | 0, 0, 0 |
| Adv120b assume/skip | 1, 1 |
| Б-2 ×3 | 1, 1, 1 |
| assume / skip | 1, 1 |
| node_modules | 0 |
| sparse | 2 |
| собственные обходы | все 1 или 2, не 0 |
| r2-оракул d50 / d51 / d52 / g01 | 1 / 1 / 1 / 0 |
