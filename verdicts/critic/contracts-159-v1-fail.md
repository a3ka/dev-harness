FAIL
OBJECT=1ed1cab690daefc11a133a004023900612612f0e
СУД: repo=dev-harness; предмет=159; фаза=контракт v1 (+красная батарея); роль=critic; вызов=1/5; модель-план=openai-codex/gpt-6-sol; сессия=Crit159; модель-факт=openai-codex/gpt-6-sol; SHA=1ed1cab690daefc11a133a004023900612612f0e; предыдущий=нет; исключение=нет.

Судится закоммиченный OBJECT, не рабочий текст. Независимость: автор Arch159 — zai/glm-5.3, критик — openai-codex/gpt-6-sol (runtime); признаков fallback в доступном контексте нет. Класс риска «обычный» соответствует механизму приёмки; область текущего `W --repo` — четыре перечисленные батареи. Две копии объекта использовались только под проверки, основной чекаут не менялся.

## Блокирующие находки

БЛОКИРУЕТ contracts/159-pustoj-produkt-krasnyj.md:22-25 — грамматика признаёт непустым продукт без единого файла экрана, записью карты считает `null`, а экраном — пустой идентификатор. Класс причины: наличие контейнера/ключа принято за наличие цели и содержимого.
ОБХОД: на допустимом R с `mobile/ci-screens.json={"ekrany":[{"id":"demo"}]}`, `mobile/e2e-demo/ekran.json={"ekran":"demo"}` и единственной пустой `mobile/src/features/` (в `mobile/src/` НЕТ ни файла, ни иной исходной реализации) эталон `sudi(R)` вернул `(0, '')`; `W --model` не содержит такого входа. На R с `ekrany:[null]` и настоящим src эталон также вернул `(0, '')`: это не «непустой список записей». Пустой `"ekran":""` также даёт `(0, '')`. Таким деревом удовлетворяется критерий гейта, но продуктовый экран по-прежнему пуст; копирование эталона в гейт не исправит ложный допуск. Симлинк `mobile/src/features` на пустой каталог ВНЕ R тоже принят как содержимый src (тот же класс структурной пустоты). Защита от непустого, но ложного содержимого/пустых Pressable объявлена вне предмета; данная находка о нуле файлов/нуле записей, а не о качестве рендера.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: непустым считается лишь продукт, имеющий действительную запись экранной цели и принадлежащее R фактическое содержимое экранного слоя, а не одни пустые контейнеры/пустое значение; красные входы этих типов отличимы от конформного продукта с исходным файлом. Границу содержательности далее можно определить в контракте, не навязывая реализацию.

БЛОКИРУЕТ contracts/159-pustoj-produkt-krasnyj.md:22 — ветвь «карта не словарь → KARTA_BEZ_CELEJ» реализована в самом обязательном эталоне неполно. Класс причины: обращение к `.get` до проверки типа.
ОБЯЗАТЕЛЬСТВО: при JSON-карте не-словаре именованный отказ `PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ` согласно старшинству, а не traceback.
СОСТОЯНИЕ: существующий R с `mobile/ci-screens.json=[{"id":"demo"}]` (непустой JSON-массив), прочие поля можно заполнить корректно.
НАБЛЮДЕНИЕ: `python3 .../model/check_pustoj_produkt_159.py R` → rc 1, stdout пуст, последняя строка stderr `AttributeError: 'list' object has no attribute 'get'`. Проверяемые шесть входов эту ветвь не достигают; реализация, копирующая эталон, нарушит названную причину. Этот блок независим от предыдущего: здесь ложный *неименованный отказ*, там ложный допуск.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: любой допустимый JSON не-словарь (включая непустые списки/примитивы) даёт один именованный отказ KARTA_BEZ_CELEJ без исключения; проверяется живым входом модели и гейта.

БЛОКИРУЕТ contracts/159-pustoj-produkt-krasnyj.md:23,34-35 — приёмка не доказывает, что общий гейт ВЫЗВАН и именно ПЕРВЫМ действием всех четырёх `--repo`-ветвей. Класс причины: строка результата отождествлена с фактом и порядком вызова; stdout и stderr дополнительно соединяются не во временном порядке (`probe.py`: `p.stdout + p.stderr`).
ОБХОД: на одноразовой копии OBJECT поставлен поведенчески корректный гейт; в четырёх `probe.py` перед обычной `--repo`-ветвью выполнялась независимая проверка ТЕМ ЖЕ эталоном с выводом той же причины, но `scripts/check_pustoj_produkt.sh` не вызывался. Полный `W` дал rc 0, **27/27**; обязанность о единственном общем механизме и вызове гейта не выполнена. Второй контрпример: сначала печать `EARLY_CHECK_BEFORE_GATE` в stderr, потом действительный вызов гейта с причиной в stdout: `W` снова rc 0, **27/27**, хотя первой в реальном потоке была чужая строка и гейт не был первым действием. Отдельно стаб `stabs/s1_ignoriruet_rezultat.py` не запускает `scripts/check_pustoj_produkt.sh`: вычисляет локальный `pustoj` и сам печатает `GATE_VYZVAN rc=N ignored`; ветвь `--stabs` ищет лишь подстроку `ignored` в выводе. Требуемая трасса реального вызова так не доказывается.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: на каждой батарее доказано исполнение именно общего гейта ДО остальных действий/вывода в `--repo`, с сохранением порядка stdout/stderr, и варианты «своя проверка вместо гейта» и «stderr до гейта» красны собственными проверками; случай выброшенного результата проверяется действительным вызовом и наблюдаемым игнорированием rc, а не строкой, напечатанной субъектом.

БЛОКИРУЕТ contracts/159-pustoj-produkt-krasnyj.md:84-88 — обязательный раздел незаполненных требований поглощает все последующие `ПЕРЕСЕЧЕНИЕ`-строки вплоть до EOF; эти строки не начинаются с `- `. Класс причины: отсутствует граница секции, норма frozen 004/1 (§Инварианты, п.3: каждая строка тела — `- …` либо единственное `нет`).
ОБЯЗАТЕЛЬСТВО: черновик до заморозки удовлетворяет действующей грамматике раздела `## Незаполненные требования:`.
СОСТОЯНИЕ: ровно предъявленный OBJECT, где после трёх пунктов в строках 85–87 идёт `ПЕРЕСЕЧЕНИЕ orchestrator:` с 88-й строки без нового заголовка `##`.
НАБЛЮДЕНИЕ: `bash scripts/check_ceilings.sh .` → rc 1: `FAIL контракт ./contracts/159-pustoj-produkt-krasnyj.md (28736 байт): тело раздела «Незаполненные требования:» вне грамматики`. Есть ВТОРОЙ независимый FAIL о соседней заглушке 158, но отказ 159 остаётся на OBJECT независимо от неё. `pre_critic` rc 0 здесь не подменяет проверку 004.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: раздел 159 завершается перед декларациями пересечений, его тело остаётся целиком валидным списком; проверка 004 не сообщает нарушение для 159, независимо от состояния 158.

СОВЕТ contracts/159-pustoj-produkt-krasnyj.md:24 — фиксированный перечень четырёх батарей честно объявлен, шесть без `--repo` вне домена. При добавлении новой батареи с `--repo` правило не расширится автоматически: отдельный предмет заявлен, но слово «ВСЕХ» в заголовке полезно сопровождать явным механизмом проверки членства будущих батарей. Будущее добавление вне кандидата; текущий вердикт на этом не основан.
СОВЕТ contracts/159-pustoj-produkt-krasnyj.md:36 — `W147/W148/W149/W151` и происхождение живого R стоит раскрыть в исполняемые команды или явные ссылки на рецепты; существующие батареи и рецепт 147 позволяют восстановить намерение, потому отдельным блоком не считаю.

## Выполненные команды и сырой результат

- `git -C /home/harness/dev-harness cat-file -t 1ed1cab690daefc11a133a004023900612612f0e` → rc 0, `commit`. Архив OBJECT извлечён; sha256 контракта из `git show OBJECT:contracts/159-pustoj-produkt-krasnyj.md` и из копии совпал: `9a64b6d709044b3a1f83cd8019af3ae682fb5bb2a51fc77368a43c69a8dbb5de`.
- `bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh` (исходный OBJECT) → rc 1, сырой финал: `клеток 22, зелёных 0, красных 22; режим derevo`; обе `s-gate-*` — `SUBJECT_ABSENT`, все 20 `W-*` — `GATE_NE_VYZVAN_PERVYM` (первые строки у 151 `INFRASTRUCTURE`, у 149/147 `CASE a-kontrol-forma ok`, у 148 `CASE chestnyj-vkladki ok`). До реализации ожидаемо красен.
- `bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh --model` → rc 0, сырой итог: `CASE m-a-forma-pusta ok`, `CASE m-b1-pustoj-katalog ok`, `CASE m-b2-otsutstvujushchij ok`, `CASE m-g-koren-bez-soderzhimogo ok`, `CASE m-konformnyj ok`, `CASE m-v-karta-bez-celej ok`, `клеток 6, зелёных 6, красных 0; режим model`.
- `bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh --stabs` → rc 0, `STAB s1_ignoriruet_rezultat.py KRASEN` на всех пяти пустых входах, `STAB s2_tolko_ekran_json.py KRASEN` на b1/b2/v/g, `STAB s3_pri_targets_pust.py KRASEN v-karta-bez-celej`, `SVJAZI 3`, `клеток 6, зелёных 6, красных 0; режим stabs`.
- `python3 /tmp/dev-harness-verify/Crit159/probe_boundary.py` → rc 0, сырой вывод:
```
all-directories-empty (0, '')
map-entry-null (0, '')
empty-screen-identifier (0, '')
external-symlink-only (0, '')
explicit-targets-empty (0, '')
non-dict-map rc= 1 stdout= '' stderr-last= "AttributeError: 'list' object has no attribute 'get'"
```
  Проба создала только одноразовые R; вариант `explicit-targets-empty` не полагаю самостоятельно обязательной формой, это диагностика границы карты.

**Контрпример 1, без вызова гейта.** Из `git archive OBJECT` в отдельный одноразовый каталог извлечено дерево; `python3 /tmp/dev-harness-verify/Crit159/negative_wiring.py` → rc 0, `Prepared four battery --repo branches that check independent oracle, NEVER invoke scripts/check_pustoj_produkt.sh`; в copy живой гейт вызывает эталон для проверки его собственных шести входов, но четыре батареи зовут не гейт, а непосредственно эталон. `bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh` → rc 0, сырой вывод:
```
CASE s-gate-v-dereve ok 
CASE s-gate-raven-etalonu/a-forma-pusta ok 
CASE s-gate-raven-etalonu/b1-pustoj-katalog ok 
CASE s-gate-raven-etalonu/b2-otsutstvujushchij ok 
CASE s-gate-raven-etalonu/g-koren-bez-soderzhimogo ok 
CASE s-gate-raven-etalonu/konformnyj ok 
CASE s-gate-raven-etalonu/v-karta-bez-celej ok 
CASE W-gespraech_otdacha_151/a-forma-pusta ok PUSTOJ_PRODUKT: FORMA_PUSTA
CASE W-gespraech_otdacha_151/b1-pustoj-katalog ok PUSTOJ_PRODUKT: KATALOG_PUST
CASE W-gespraech_otdacha_151/b2-otsutstvujushchij ok PUSTOJ_PRODUKT: KATALOG_OTSUTSTVUET
CASE W-gespraech_otdacha_151/v-karta-bez-celej ok PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ
CASE W-gespraech_otdacha_151/g-koren-bez-soderzhimogo ok PUSTOJ_PRODUKT: KOREN_BEZ_SODERZHIMOGO
CASE W-gespraech_tekst_149/a-forma-pusta ok PUSTOJ_PRODUKT: FORMA_PUSTA
CASE W-gespraech_tekst_149/b1-pustoj-katalog ok PUSTOJ_PRODUKT: KATALOG_PUST
CASE W-gespraech_tekst_149/b2-otsutstvujushchij ok PUSTOJ_PRODUKT: KATALOG_OTSUTSTVUET
CASE W-gespraech_tekst_149/v-karta-bez-celej ok PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ
CASE W-gespraech_tekst_149/g-koren-bez-soderzhimogo ok PUSTOJ_PRODUKT: KOREN_BEZ_SODERZHIMOGO
CASE W-gespraech_vhod_147/a-forma-pusta ok PUSTOJ_PRODUKT: FORMA_PUSTA
CASE W-gespraech_vhod_147/b1-pustoj-katalog ok PUSTOJ_PRODUKT: KATALOG_PUST
CASE W-gespraech_vhod_147/b2-otsutstvujushchij ok PUSTOJ_PRODUKT: KATALOG_OTSUTSTVUET
CASE W-gespraech_vhod_147/v-karta-bez-celej ok PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ
CASE W-gespraech_vhod_147/g-koren-bez-soderzhimogo ok PUSTOJ_PRODUKT: KOREN_BEZ_SODERZHIMOGO
CASE W-vkladki_tabov_148/a-forma-pusta ok PUSTOJ_PRODUKT: FORMA_PUSTA
CASE W-vkladki_tabov_148/b1-pustoj-katalog ok PUSTOJ_PRODUKT: KATALOG_PUST
CASE W-vkladki_tabov_148/b2-otsutstvujushchij ok PUSTOJ_PRODUKT: KATALOG_OTSUTSTVUET
CASE W-vkladki_tabov_148/v-karta-bez-celej ok PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ
CASE W-vkladki_tabov_148/g-koren-bez-soderzhimogo ok PUSTOJ_PRODUKT: KOREN_BEZ_SODERZHIMOGO
клеток 27, зелёных 27, красных 0; режим derevo
```
**Контрпример 2, нарушен временной порядок.** На том же одноразовом дереве `python3 /tmp/dev-harness-verify/Crit159/negative_order.py` → rc 0, `Prepared four branches: stderr warning BEFORE real gate invocation; gate stdout still first after concatenation`; батареи выводят в stderr `EARLY_CHECK_BEFORE_GATE`, затем вызывают живой гейт, после получают его stdout. `bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh` → rc 0, сырой вывод:
```
CASE s-gate-v-dereve ok 
CASE s-gate-raven-etalonu/a-forma-pusta ok 
CASE s-gate-raven-etalonu/b1-pustoj-katalog ok 
CASE s-gate-raven-etalonu/b2-otsutstvujushchij ok 
CASE s-gate-raven-etalonu/g-koren-bez-soderzhimogo ok 
CASE s-gate-raven-etalonu/konformnyj ok 
CASE s-gate-raven-etalonu/v-karta-bez-celej ok 
CASE W-gespraech_otdacha_151/a-forma-pusta ok PUSTOJ_PRODUKT: FORMA_PUSTA
CASE W-gespraech_otdacha_151/b1-pustoj-katalog ok PUSTOJ_PRODUKT: KATALOG_PUST
CASE W-gespraech_otdacha_151/b2-otsutstvujushchij ok PUSTOJ_PRODUKT: KATALOG_OTSUTSTVUET
CASE W-gespraech_otdacha_151/v-karta-bez-celej ok PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ
CASE W-gespraech_otdacha_151/g-koren-bez-soderzhimogo ok PUSTOJ_PRODUKT: KOREN_BEZ_SODERZHIMOGO
CASE W-gespraech_tekst_149/a-forma-pusta ok PUSTOJ_PRODUKT: FORMA_PUSTA
CASE W-gespraech_tekst_149/b1-pustoj-katalog ok PUSTOJ_PRODUKT: KATALOG_PUST
CASE W-gespraech_tekst_149/b2-otsutstvujushchij ok PUSTOJ_PRODUKT: KATALOG_OTSUTSTVUET
CASE W-gespraech_tekst_149/v-karta-bez-celej ok PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ
CASE W-gespraech_tekst_149/g-koren-bez-soderzhimogo ok PUSTOJ_PRODUKT: KOREN_BEZ_SODERZHIMOGO
CASE W-gespraech_vhod_147/a-forma-pusta ok PUSTOJ_PRODUKT: FORMA_PUSTA
CASE W-gespraech_vhod_147/b1-pustoj-katalog ok PUSTOJ_PRODUKT: KATALOG_PUST
CASE W-gespraech_vhod_147/b2-otsutstvujushchij ok PUSTOJ_PRODUKT: KATALOG_OTSUTSTVUET
CASE W-gespraech_vhod_147/v-karta-bez-celej ok PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ
CASE W-gespraech_vhod_147/g-koren-bez-soderzhimogo ok PUSTOJ_PRODUKT: KOREN_BEZ_SODERZHIMOGO
CASE W-vkladki_tabov_148/a-forma-pusta ok PUSTOJ_PRODUKT: FORMA_PUSTA
CASE W-vkladki_tabov_148/b1-pustoj-katalog ok PUSTOJ_PRODUKT: KATALOG_PUST
CASE W-vkladki_tabov_148/b2-otsutstvujushchij ok PUSTOJ_PRODUKT: KATALOG_OTSUTSTVUET
CASE W-vkladki_tabov_148/v-karta-bez-celej ok PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ
CASE W-vkladki_tabov_148/g-koren-bez-soderzhimogo ok PUSTOJ_PRODUKT: KOREN_BEZ_SODERZHIMOGO
клеток 27, зелёных 27, красных 0; режим derevo
```

Прочие scoped-команды на извлечённом архиве: `bash scripts/pre_critic.sh contracts/159-pustoj-produkt-krasnyj.md` → rc 0, `КРИТИК: дверь зелёная`; `bash scripts/check_precision_gate.sh . contracts/159-pustoj-produkt-krasnyj.md` → rc 0, `OK`; `bash scripts/check_spec_ready.sh . contracts/159-pustoj-produkt-krasnyj.md` → rc 0, `OK`; `bash scripts/check_threat_model.sh . contracts/159-pustoj-produkt-krasnyj.md` → rc 0, `модель угроз: секция валидна (ЗАЩИЩАЕТ 5 буллет(ов), НЕ ЗАЩИЩАЕТ 4 буллет(ов))`; `bash scripts/check_provodka.sh . contracts/159-pustoj-produkt-krasnyj.md` → rc 1, `проводка: guard не подключён` (ожидаемо до реализации). `bash scripts/check_ceilings.sh .` → rc 1, оба отказа 158 и 159 приведены выше. `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model` → rc 0, все 66 показанных CASE `ok` после обеспечения изолированной копии git-метаданными и frozen-тегами. Первоначальный запуск в голом архиве был rc 1 по `g05-samo-prolozhenie` с `NOT_IMPLEMENTED: worktree пина не репо`; после получения истории он зелёный. Проверка `check_zones.sh .` на полном дереве не завершилась за 180 с (завершена timeout), поэтому зелёный исход по зонам **не заявлен**; `check_precision_gate` непосредственно проверил декларации пересечений и прошёл.

## Не проверено

- Зелёный `W` после ЧЕСТНОЙ реализации, CI-ленд и живые исходы батарей на внешнем реальном продукте — реализации на OBJECT нет; показанная зелень 27/27 относится только к негативным одноразовым образцам и НЕ является приёмкой продукта.
- Полный `check_zones.sh` не успел завершиться (timeout 180 с); иных утверждений о его зелени нет. Проводка CI до реализации отсутствует, что ожидаемо.
- Фактический trace session-id и независимая трассовая сверка модели не предоставлены критическому процессу; указан `сессия=Crit159` — подтверждённый идентификатор агента, `модель-факт` — объявленная runtime-модель. Оркестратор должен дополнить строку фактической сессией/моделью из трейса до материализации и переноса вердикта. В основной репозиторий не коммичу: задание требует основной checkout read-only и вердикт по этому пути.
