FAIL
OBJECT=f056f52cb239f16a54a9ff90651278cbfe56028c
СУД: repo=dev-harness; предмет=142; фаза=реализация (v3); роль=adversary; вызов=1/2; модель-план=роль adversary по config/agent_models.json; сессия=Adv142c; модель-факт=openai-codex/gpt-5.6-terra; SHA=f056f52cb239f16a54a9ff90651278cbfe56028c; предыдущий=adversary 142 impl v1/v2 (реализация v1) FAIL×2 + арбитраж contracts-142-impl-arbitraz.md + слово владельца 27.10; исключение=нет

# БЛОКИРУЕТ

БЛОКИРУЕТ И-7 и прямое задание adversary 142 v3 («предпроверка ДО цикла `read` и ДО любых действий») — NUL-предпроверка стоит после записи каркаса подключаемого проекта. В `scripts/connect_project.sh` OBJECT предварительно выполняет `mkdir -p .harness/...`, создаёт `.harness/.env`, пишет `.git/info/exclude`, пин, `harness.project.json`, `.harness/project-layer.json`, HANDOFF/NABLIUDENIA/ROADMAP, реестр и `trace.tsv` (строки 180–260); проверка `LC_ALL=C grep -qaP '\x00' -- "$DOM_SEKRETOV"` начинается только на строке 277.

Класс причины: новая обязательная предпроверка И-7 добавлена в правильный страж, но слишком поздно относительно уже выполняемых действий двери. Красная батарея NUL проверяет только rc, текст отказа и отсутствие `workshop`; она не проверяет, что отказ произошёл до мутации дерева проекта. Поэтому сам неправильный OBJECT проходит W.

СОСТОЯНИЕ: чистый временный git-проект, поддельный HOME и двойник `workshop`; только `~/.config/dev-harness/secrets.env` содержит байты `FOO_URL\0=probe-nul-value\n`, а индексируемый `leak.txt` содержит `probe-nul-value`. Реальный дом секретов станции не читался.

НАБЛЮДЕНИЕ:

```text
$ cd /tmp/dev-harness-verify/Adv142c && bash nul_precheck_probe.sh
literal-nul rc=1 calls=0 stderr=connect ОТКАЗ: sekret-v-dereve: NUL (байт 0x00) в доме секретов «…/secrets.env» — файл не читается как KEY=VALUE; сессия не запускается
literal-nul artifacts env=yes profile=yes trace=yes
```

То есть обязательный именованный отказ и отсутствие сессии соблюдены, но до отказа уже созданы `.harness/.env`, `harness.project.json` и `.harness/registry/trace.tsv`. Это наблюдаемая мутация проекта при входе, который обязан остановиться предпроверкой до любых действий.

Та же проверка на фактическом OBJECT зелёная:

```text
$ cd repo && bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh
s142 subjekt: клеток 132, зелёных 132, красных 0
# rc=0
$ bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --repo /tmp/dev-harness-verify/Adv142c/repo
s142 repo: клеток 132, зелёных 132, красных 0
# rc=0
```

ЗАКРЫВАЮЩЕЕ СВОЙСТВО: при любом NUL в существующем регулярном доме секретов дверь до создания/изменения любого пути подключаемого проекта отказывает `sekret-v-dereve` с категорией NUL, rc 1 и без запуска workshop. Батарея должна наблюдать отсутствие указанных мутаций в NUL-мире, а не только rc/err/calls.

# СОВЕТ

Нет.

# Проверенные классы и сырые результаты

* Идентичность кандидата: `git cat-file -t f056f52cb239f16a54a9ff90651278cbfe56028c` → `commit`. `git diff --name-only origin/main..HEAD` → `scripts/connect_project.sh`. Полный `diff -u scripts/connect_project.sh fixtures/workshop_project/skaner_sekretov_142/model/connect_project.sh` → rc 0, вывода нет.

* Позитивный контроль честной реализации:

```text
$ bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --model
s142 model: клеток 132, зелёных 132, красных 0
# rc=0
```

* Архитекторская батарея обманных реализаций:

```text
$ bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --stabs
s142 model-opora-stabov: клеток 132, зелёных 132, красных 0
s142 stabs: стабов 31, привязок 197, непойманных 0
# rc=0
```

  В частности пойманы отключение стража, константные белые списки, грамматика после суффикса, NUL-нормализация `read`, NUL только в первой строке/до `=`, fail-open при ошибке предпроверки и печать значения в NUL-отказе. Они не моделируют позднюю предпроверку после мутаций дерева.

* Собственная нейтрализация: в одноразовой копии изменён NUL-предикат так, что он исполнялся только для файла с LF на последнем байте. Проверка поймала именно пропущенные NUL-классы:

```text
$ bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --repo /tmp/dev-harness-verify/Adv142c/unterminated-nul-mutant
КЛЕТКА n5-bez-hvostogo-lf КРАСНА: ждали именованный отказ … rc=0; … сессия запущена;
КЛЕТКА n12-nechitaemyj-dom КРАСНА: ждали именованный отказ … rc=0; … сессия запущена;
s142 repo: клеток 132, зелёных 130, красных 2
# rc=1
```

* Буквальный NUL, инструмент вне PATH и пустой вход проверены отдельным миром:

```text
literal-nul rc=1 calls=0 stderr=connect ОТКАЗ: sekret-v-dereve: NUL …
symlink-nul rc=1 calls=0 stderr=connect ОТКАЗ: sekret-v-dereve: NUL …
clean-regular rc=0 calls=1 stderr=
grep-127 rc=1 calls=0 stderr=connect ОТКАЗ: sekret-v-dereve: предпроверка NUL дома секретов не исполнилась — сессия не запускается
```

  Следовательно нормальный регулярный дом проходит, NUL в регулярном файле и симлинке ловится без запуска, а `grep -P` с rc 127 не воспринимается как «NUL не найден». В том же повторном, уже установленном мире каталог и FIFO на пути дома дали `rc=0 calls=1`; это не поднимается блокером: путь не является регулярным файлом дома секретов, класс существовал до дельты и не доказывает обход И-7 на объявленном входе.

* Оракул защищён от порчи:

```text
$ truncate -s 0 oracle-tamper/fixtures/workshop_project/skaner_sekretov_142/model/connect_project.sh
$ cd oracle-tamper && bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --model
s142: ORACLE_TAMPERED: sha256 модели ≠ source.json:.model_sha256
# rc=2
```

* Наследие и устав:

```text
$ bash fixtures/workshop_project/sessii_125/red_sessii_125.sh
s125 red: зелёных 70, красных 0
# rc=0
$ bash fixtures/workshop_project/sessii_136/red_sessii_136.sh
sessii_136: клеток 87, зелёных 87, красных 0
# rc=0
$ bash scripts/check_charter.sh
уставных документов: 141 · изменений в них: 346 · с разрешения: 346
# rc=0
```

# Не проверено

TOCTOU между успешной предпроверкой и `read` не атакован как блокер: он прямо вынесен контрактом в «НЕ ЗАЩИЩАЕТ», а доказательства достижимости противником нет. PCRE2 не квалифицирован как дефект: зависимость прямо объявлена, а rc 127 проверен как fail-closed. Реальный дом секретов станции не читался. Commit и push не выполнялись по прямому запрету задания.
