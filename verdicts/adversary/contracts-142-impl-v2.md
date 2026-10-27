FAIL
OBJECT=5f7649de1db2801eb7f6de221f5d62d03dfa5755
СУД: repo=dev-harness; предмет=142; фаза=реализация; роль=adversary; вызов=2/2; модель-план=роль adversary по config/agent_models.json; сессия=Adv142b; модель-факт=openai-codex/gpt-5.6-terra; SHA=5f7649de1db2801eb7f6de221f5d62d03dfa5755; предыдущий=adversary 142 вызов 1/2 FAIL (`verdicts/adversary/contracts-142-impl-v1.md`, OBJECT `f7eee4bae373`); исключение=нет

# БЛОКИРУЕТ

БЛОКИРУЕТ И-4 и И-5 (`contracts/142-skaner-sekretov.md`, «единственное разрешённое сужение — класс И-3», «fail-closed … парсер KEY=VALUE … не ослабляются») — байт NUL в имени дома секретов отбрасывается `bash read` до проверки `IMYA_RE`; неконформное сырое имя тем самым превращается в конформное `FOO_URL` и получает исключение И-3. Это сужение множества судимых значений, которого у двери main не было.

Класс причины: дельта 142 добавила исключение по имени ПОСЛЕ `read -r k v`. Bash читает строку `FOO_URL\0=<значение>` как `k=FOO_URL`, поэтому `printf '%s' "$k" | grep -Eqx -- "$IMYA_RE"` проверяет уже нормализованное, а не исходное имя. Затем `adresnyj_suffiks` возвращает истину и ветвь `continue` не записывает значение в `ZNACH`.

СОСТОЯНИЕ: чистый временный git-проект, поддельный HOME и двойник `workshop`; `~/.config/dev-harness/secrets.env` содержит ровно байты `FOO_URL\0=probe-nul-value\n`, индексируемый `leak.txt` содержит `probe-nul-value`. Реальный дом секретов станции не читался. Состояние достижимо файловым содержимым, а не аргументом shell.

НАБЛЮДЕНИЕ (один и тот же мир-генератор, обе двери):

```text
$ cd /tmp/dev-harness-verify/Adv142b && bash probe_nul.sh
subject=object bytes=FOO_URL\0=probe-nul-value rc=0 workshop=1 err=
subject=main bytes=FOO_URL\0=probe-nul-value rc=1 workshop=0 err=connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «leak.txt», который git может проиндексировать — сессия не запускается
```

То есть новая дверь запускает сессию при значении дома секретов в индексируемом файле; главная дверь его останавливает до сессии. Батарея тоже не ловит этот обход: на самом OBJECT её позитивный прогон зелёный.

ЗАКРЫВАЮЩЕЕ СВОЙСТВО: никакая строка дома с NUL (и вообще неконформным исходным именем) не может нормализацией получить исключение И-3; при непустом совпавшем значении дверь отказывает `sekret-v-dereve` с rc 1 до `workshop`.

# СОВЕТ

Нет.

# Проверенные классы и сырые результаты

* Позитивный контроль и фактический субъект:

```text
$ bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh
s142 subjekt: клеток 119, зелёных 119, красных 0
# rc=0
$ bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --repo /tmp/dev-harness-verify/Adv142b/repo
s142 repo: клеток 119, зелёных 119, красных 0
# rc=0
$ bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --model
s142 model: клеток 119, зелёных 119, красных 0
# rc=0
$ bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --stabs
s142 model-opora-stabov: клеток 119, зелёных 119, красных 0
s142 stabs: стабов 26, привязок 174, непойманных 0
# rc=0
```

  Нейтрализация поймана: среди 26 стабов `stab_skaner-vykljuchen`; константные/белые списки пойманы `stab_belyj-spisok-pyati-imen` и `stab_belyj-spisok-17-imen`; все их объявленные клетки напечатаны `ПОЙМАН`.

* Порча оракула в одноразовом локальном клоне:

```text
$ truncate -s 0 tamper/fixtures/workshop_project/skaner_sekretov_142/model/connect_project.sh
$ bash tamper/fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --model
s142: ORACLE_TAMPERED: sha256 модели ≠ source.json:.model_sha256
# rc=2
```

* Граница грамматики проверена прямым запуском OBJECT и `origin/main` на одинаковых искусственных мирах, под `LC_ALL=C` и `LC_ALL=C.UTF-8`. Для `FOO.URL`, `FOO-URL`, `FOO URL`, `4FOO_URL`, `_`, `-e`, `-n`, `--`, полноширинного `＿` и греческого префикса OBJECT и main дали `rc=1`, `calls=0`, `sekret-v-dereve`; `API_KEY_URL` также `rc=1`, `calls=0`. Для конформного `FOO_URL`, а также `URL` и `HOST`, OBJECT дал `rc=0` и запуск, main — `rc=1`, `calls=0`: это разрешённое И-3 сужение. Многострочный вход `FOO_URL\nBAD.NAME=<значение>` дал OBJECT/main `rc=1`, `calls=0`; `FOO_URL＝<значение>` и пустое имя дали одинаковое с main отсутствие сканируемой строки (rc 0). Полный вывод для ключевых нормальных границ:

```text
$ bash probe_boundary.sh
subject=object locale=C key=FOO.URL rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «leak.txt», который git может проиндексировать — сессия не запускается
subject=main locale=C key=FOO.URL rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «leak.txt», который git может проиндексировать — сессия не запускается
subject=object locale=C key=FOO-URL rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «leak.txt», который git может проиндексировать — сессия не запускается
subject=main locale=C key=FOO-URL rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «leak.txt», который git может проиндексировать — сессия не запускается
subject=object locale=C key=API_KEY_URL rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «leak.txt», который git может проиндексировать — сессия не запускается
subject=object locale=C key=FOO_URL rc=0 calls=1 err=
subject=main locale=C key=FOO_URL rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «leak.txt», который git может проиндексировать — сессия не запускается
subject=object locale=C.UTF-8 key=FOO.URL rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «leak.txt», который git может проиндексировать — сессия не запускается
subject=main locale=C.UTF-8 key=FOO.URL rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «leak.txt», который git может проиндексировать — сессия не запускается
subject=object locale=C.UTF-8 key=FOO_URL rc=0 calls=1 err=
subject=main locale=C.UTF-8 key=FOO_URL rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «leak.txt», который git может проиндексировать — сессия не запускается
subject=object locale=C key=$'FOO_URL\nBAD.NAME' rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «leak.txt», который git может проиндексировать — сессия не запускается
subject=main locale=C key=$'FOO_URL\nBAD.NAME' rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «leak.txt», который git может проиндексировать — сессия не запускается
# rc=0
```

* NUL отдельно испытан и с `bash -o pipefail`: OBJECT остался `rc=0` (в первом запуске двойник считал exec неверно из-за отсутствия LF, поэтому блокирующее воспроизведение выше повторено отдельным двойником с `touch`; в нём `workshop=1`). Входы с `-e`/`-n`/`--` не интерпретированы `grep`, а были остановлены. При подмене только предикатного `tr 'a-z' 'A-Z'` обёрткой с rc 127 OBJECT для `FOO_URL` дал `rc=1`, `calls=0`, `sekret-v-dereve`: сбой нового инструмента не открыл сессию.

* Наследие:

```text
$ bash fixtures/workshop_project/sessii_125/red_sessii_125.sh
s125 red: зелёных 70, красных 0
# rc=0
$ bash fixtures/workshop_project/sessii_125/red_sessii_125.sh --model
s125 model: зелёных 70, красных 0
# rc=0
$ bash fixtures/workshop_project/sessii_136/red_sessii_136.sh
sessii_136: клеток 87, зелёных 87, красных 0
# rc=0
```

* Граница реализации и неизменённый прежний grep-127 класс:

```text
$ git diff --name-only origin/main..HEAD
scripts/connect_project.sh
$ git diff --numstat origin/main..HEAD
31	12	scripts/connect_project.sh
$ git diff --unified=3 origin/main..HEAD -- scripts/connect_project.sh
# единственная дельта — блок предиката 142, комментарии и unset _ku/_kt;
# строка поиска остаётся дословно:
HIT=$(git ls-files -z --cached --others --exclude-standard | xargs -0r grep -lsF -f "$ZNACH" -- | sed -n 1p)
$ bash scripts/check_charter.sh
уставных документов: 140 · изменений в них: 341 · с разрешения: 341
# rc=0
```

  Поэтому ранее известный `grep -lsF` → `sed` без `pipefail` (включая grep rc 127) дельтой 142 не затронут и повторно блокером не поднимается.

# Не проверено

Не читался и не копировался реальный дом секретов станции. Не проводился полный проектный набор вне предписанных W/P/Q и charter. Одноразовые миры, клоны, обёртки и probe-скрипты удалены; по прямому запрету задания commit/push не выполнялись.
