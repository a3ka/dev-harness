FAIL

# Ревьюер — финальный гейт контракта 015

Проверено в живом `/home/aka/Documents/dev-harness` на
`000116ba56ff39f206c9c6264fc9209e7986fa14`. Вердикт — **FAIL**: два
исполняемых пункта §Предмет нарушены реальным кодом, а две frozen-фикстуры
были переписаны после заморозки. Зелёные прогоны ниже не отменяют этих
находок.

## Находки

### R015-1 — ПРЕДМЕТ / механизм 3 / потолок: больше 40 строк

Контракт требует, чтобы дайджест *суммарно* печатал не более 40 строк. В
`scripts/nabludenia_digest.sh:229-234` реализация берёт первые 40 строк и
**затем** добавляет строку `…и ещё N`; следовательно, любой переполненный
вывод содержит 41 строку. Кроме того, глобальное усечение может отрезать
обязательные поздние секции `черновики` и `HANDOFF`, а не схлопнуть хвост
списка внутри секции.

Это исполненный, не тестовый, контрпример. В новом временном git-корне были
созданы 50 валидных открытых заголовков, оба файла наблюдений и HANDOFF; после
вызова реального скрипта временные каталоги удалены:

```text
$ TMPDIR="$D" bash scripts/nabludenia_digest.sh --for-session --root "$T" > "$T/out"; rc=$?; printf 'digest_rc=%s\nline_count=' "$rc"; wc -l < "$T/out"
digest_rc=0
line_count=41
```

Начало вывода содержит 30 записей и `…и ещё 20`; конец ровно 41-строчного
вывода — секция `дерево:` и `…и ещё 7`. Секций `черновики:` и `HANDOFF:` в
результате нет. Это прямое нарушение §Предмет механизма 3, несмотря на зелёный
`case_potolok_prevyshaetsja`: тот case ловит только стаб «без потолка», но не
проверяет предел реального переполненного дайджеста.

### R015-2 — ПРЕДМЕТ / механизм 1 / пост-миграционная граница нарушена

§Предмет устанавливает, что равенство набора адресатных ключей — **только**
миграционная проба, которая умирает с таблицей в вводном коммите; после
миграции барьер судит только форму. Однако реальный
`scripts/check_nabludenia.sh` продолжает читать контрактную таблицу
(`load_migration`, строки 91–167) и после успешного `GRAMMAR.fullmatch`
сверяет `TABLE[rid]` в строках 228–239.

Прямая проба в новом временном корне содержит валидный по грамматике заголовок
`Н-14` с адресом `контракт 015`; оба файла существуют. Реальный барьер отверг
его именно по запрещённой пост-миграционной мере:

```text
$ bash scripts/check_nabludenia.sh "$T"; rc=$?; printf 'rc=%s\n' "$rc"
  FAIL Н-14: назначение изменено — таблица ждёт Q, значение несёт K:015
rc=1
```

Следовательно, это не «тест зелёный, предмет существует»: механизм 1
реализует более сильное, но несоответствующее frozen-контракту правило и
связывает будущую живую запись с одноразовой таблицей миграции.

### R015-3 — ОБЛАСТЬ / заморозка / подгонка проверки: фикстуры изменены после freeze

Тег `frozen/contracts/015/1^{commit}` разрешается в
`3a55e912098ae3b9458eeff0e8a1a666b1262f1f`. Собственная сверка frozen-границы
показывает, что нормативный контракт действительно не менялся, но две
фикстуры изменены после freeze:

```text
$ git rev-parse 'refs/tags/frozen/contracts/015/1^{commit}'
3a55e912098ae3b9458eeff0e8a1a666b1262f1f

$ git diff --name-status 'refs/tags/frozen/contracts/015/1^{commit}' HEAD -- contracts/015-jadro-avtonomnosti-nabljudenij.md fixtures/check_nabludenia fixtures/drill_gate_draft fixtures/drill_startup_digest fixtures/drill_nabludenia_nechitaemo
M	fixtures/drill_nabludenia_nechitaemo/case_nechitaemoe_schitano_otsutstvujushhim.sh
M	fixtures/drill_nabludenia_nechitaemo/probe_nechitaemo_krasnyj.sh

$ git rev-parse 'refs/tags/frozen/contracts/015/1^{commit}:contracts/015-jadro-avtonomnosti-nabljudenij.md' 'HEAD:contracts/015-jadro-avtonomnosti-nabljudenij.md'
ebcea273ab1dbffcfe6a18f50e4129875af732ac
ebcea273ab1dbffcfe6a18f50e4129875af732ac
```

Изменение внесено коммитом `1bff2df` (`architect`), то есть не является
допустимым implementer-диффом и делает проверку после заморозки подвижной.
Это самостоятельный отказ области и требования «фикстуры/контракт не
переписаны».

## Что всё же проверено

### Сверка предмета с кодом и миграцией

* **Механизм 1:** грамматика определена в
  `scripts/check_nabludenia.sh:73-84`; разбор заголовков, статуса, `адрес:` и
  rc=1 находится в строках 204–243. Найдена R015-2: код не останавливается на
  форме, а применяет миграционную таблицу.
* **Механизм 2:** единственный фильтр гейта и внешний канонический `${TMPDIR}`
  находятся в `scripts/draft_nabludenia.sh:40-92`, дедуп и запись —
  `:121-145`; `.omp/extensions/gate-draft.ts:30-52` регистрирует один
  `tool_result` handler и передаёт ему bash-ошибку. Scoped-прогон ниже
  предъявил все 7 красных case.
* **Механизм 3:** общая грамматика и разбор обеих книг —
  `scripts/nabludenia_digest.sh:54-110`; секции строятся в `:218-223`;
  `.omp/extensions/startup-digest.ts:18-38` регистрирует `session_start` и
  делает один `sendMessage` с `deliverAs: "nextTurn"`. Найдена R015-1 в
  реально исполнимом потолке `:229-234`.
* **Нечитаемость:** `scripts/drill_nabludenia_nechitaemo.sh:70-87` строит
  внешний sandbox, а `:127-164` требует у реального барьера rc=2 и строку
  `нечем проверить`.
* **Миграция не только в тесте:** сырой
  `git diff --unified=0 3a55e91 fd5a17a -- NABLIUDENIA.md
  NABLIUDENIA_ARCHITECT.md` даёт `35 insertions(+), 35 deletions(-)` именно в
  двух книгах и показывает заменённые заголовки, например Н-45, Н-41, Н-49,
  Н-50, Н-13, А-7, А-11, А-12, А-15, А-16 и А-17, на маркеры с
  `ОТКРЫТО — адрес:`/статусом. Поэтому миграция в вводном коммите реальна, но
  не оправдывает R015-2.

### Атомарность и дифф

Вводный `fd5a17a` автора `implementer` содержит только десять разрешённых
путей: 4 скрипта механизма, 2 расширения, 2 книги заголовков и 2 дрилла;
остальные названные implementer-фиксы меняют один или два скрипта. Но
`1bff2df` изменяет две frozen fixture, что образует R015-3. Суммарный
`git diff --name-status fd5a17a^ d857ef7` также содержит эти fixture, а кроме
разрешённой зоны — `HANDOFF.md`, verdicts/adversary и verdicts/arbitration;
поэтому весь интервал нельзя выдать за чистый implementer-дифф.

### Сырые зелёные прогоны (md5-сторож до и после каждого)

Во всех следующих командах до и после был один и тот же вывод:

```text
35ccdd6086b421be5d2a1350e322d608  NABLIUDENIA.md
```

```text
$ bash scripts/verify_antiplacebo.sh --scope check_nabludenia
барьеров: 1 · фикстур: 12 · предъявлено красным повторным прогоном: 12
rc=0

$ bash scripts/verify_antiplacebo.sh --scope drill_gate_draft
барьеров: 1 · фикстур: 7 · предъявлено красным повторным прогоном: 7
rc=0

$ bash scripts/verify_antiplacebo.sh --scope drill_startup_digest
барьеров: 1 · фикстур: 12 · предъявлено красным повторным прогоном: 12
rc=0

$ bash scripts/verify_antiplacebo.sh --scope drill_nabludenia_nechitaemo
барьеров: 1 · фикстур: 1 · предъявлено красным повторным прогоном: 1
rc=0

$ bash fixtures/check_nabludenia/probe_nabludenia_krasnoe.sh
ok: барьер зелёный на живом дереве — миграционная пачка в коммите введения
rc=0

$ bash fixtures/drill_gate_draft/probe_gate_draft_krasnyj.sh
ok: дрилл gate-draft зелёный на живом дереве
rc=0

$ bash fixtures/drill_startup_digest/probe_digest_krasnyj.sh
ok: дрилл startup-digest зелёный на живом дереве
rc=0

$ bash scripts/drill_nabludenia_nechitaemo.sh
  ok   зелёный контроль: барьер rc=0 на чистом дереве
  ok   нечитаемое: rc=2 + строка «нечем проверить: NABLIUDENIA.md»
  дрилл nabludenia-nechitaemo: ветвь rc=2 поймана
rc=0

$ bash fixtures/check_nabludenia/probe_migracija_adresov.sh
ok: все ОТКРЫТО-маркеры несут адрес структурной грамматикой; назначение каждой строки §Материал сохранено
rc=0
```

Frozen-гейт также зелёный и не маскирует R015-3, потому что он проверяет
только contracts/plans:

```text
$ bash scripts/check_contract_frozen.sh
  ok   contracts/015-jadro-avtonomnosti-nabljudenij.md — заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают

планов и контрактов на HEAD: 18 · черновиков: 3 · заморожено: 15 · реестр: full
rc=0
```

### Выборочная воспроизводимость судейских команд

Две команды из critic и прямой запуск из adversary воспроизведены без изменения
исходников; md5-сторож до/после каждой — тот же `35ccdd…d608`:

```text
$ python3 fixtures/check_nabludenia/build_root.py "$T" 'контракт 015 — примечание'; bash fixtures/check_nabludenia/probe_migracija_adresov.sh "$T"
корень: 36 строк §Материал (Н-36: контракт 015 — примечание)
ok: все ОТКРЫТО-маркеры несут адрес структурной грамматикой; назначение каждой строки §Материал сохранено
rc=0

$ python3 fixtures/check_nabludenia/build_root.py "$T" 'контракт 015 —'; bash fixtures/check_nabludenia/probe_migracija_adresov.sh "$T"
корень: 36 строк §Материал (Н-36: контракт 015 —)
ok: все ОТКРЫТО-маркеры несут адрес структурной грамматикой; назначение каждой строки §Материал сохранено
rc=0

$ bash scripts/drill_startup_digest.sh
  ok   real: реальный дайджест называет ожидаемые из памяти теги и аномалии статуса в своих секциях
rc=0
```

## Итог

Зелёные 12/7/12/1, пять проб, frozen и выборочные судейские команды
воспроизводимы, но не являются доказательством соблюдения §Предмет при
переполнении дайджеста и после миграции. R015-1, R015-2 и R015-3 — блокеры;
приёмка отклонена.
