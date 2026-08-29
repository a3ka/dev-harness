FAIL

Судился живой HEAD `eac98d0` и фикс `3f47d44..eac98d0`. Предмет и проверки не менялись; все подмены жили только в `/tmp`. MD5-сторож `NABLIUDENIA.md` до и после **каждого** ниже названного прогона совпал: `35ccdd6086b421be5d2a1350e322d608`.

## 1. Прежние находки пойманы

### 1.1 Черновик без дедупа

В `/tmp/adv015b-draft` был подложен бесмаркерный `scripts/draft_nabludenia.sh`, который на каждом вызове создаёт новый файл с `повторов: 1`. Два одинаковых вызова:

```sh
TMPDIR=/tmp/adv015b-draft-tmp bash /tmp/adv015b-draft/scripts/draft_nabludenia.sh scripts/check_charter.sh 'FAIL charter: adversary'
TMPDIR=/tmp/adv015b-draft-tmp bash /tmp/adv015b-draft/scripts/draft_nabludenia.sh scripts/check_charter.sh 'FAIL charter: adversary'
```

создали два разных `.md`. Затем:

```sh
cd /tmp/adv015b-draft
bash scripts/verify_antiplacebo.sh --scope drill_gate_draft
```

дал `rc=1`: все семь case остановлены отсутствующим положительным контролем. Его причина — новая real-ветвь дрилла вызвала субъект дважды, увидела не `ровно 1` файл и не признала подмену зелёной. Старый обход больше не проходит.

### 1.2 Дайджест с константами-нулями

В `/tmp/adv015b-digest` был подложен бесмаркерный `scripts/nabludenia_digest.sh`, печатающий, в частности, `открытых: 0`, `ahead 0, behind 0`, `теги: 0`, `статус: чисто`, `черновиков: 0`. Его прямой вывод был ложным. Затем:

```sh
cd /tmp/adv015b-digest
bash scripts/verify_antiplacebo.sh --scope drill_startup_digest
```

дал `rc=1`: все 12 case остановлены отсутствующим положительным контролем. Новая real-ветвь требует назвать открытые записи и отвергает литерал `теги: 0`; прежний обход нулями пойман.

## 2. Новые бесмаркерные кандидаты

### 2.1 Разные ключи дедупа — это не дыра

Кандидат в `/tmp/adv015b-draft` дедуплицирует точный ключ `(команда + первая FAIL-строка)`, но создаёт по одному файлу для разных ключей. Пара:

```sh
TMPDIR=/tmp/adv015b-draft-distinct bash /tmp/adv015b-draft/scripts/draft_nabludenia.sh scripts/check_charter.sh 'FAIL charter: first'
TMPDIR=/tmp/adv015b-draft-distinct bash /tmp/adv015b-draft/scripts/draft_nabludenia.sh scripts/check_contract_frozen.sh 'FAIL frozen: second'
```

дала два файла (`66afde688057b92d.md`, `e40670a17b758dc7.md`). Это **легально**: инвариант 4 прямо требует «другой отказ — другой файл». Тот же кандидат прошёл:

```sh
cd /tmp/adv015b-draft
bash scripts/verify_antiplacebo.sh --scope drill_gate_draft
```

`rc=0`, 7/7. Это положительный контроль поведенческого предъявления: одинаковый вход дедуплицируется, in-tree `TMPDIR` отвергается; требовать один черновик от разных входов изменило бы контракт.

### 2.2 FAIL — дайджест лжёт о дереве и проходит scoped

Построен **новый бесмаркерный** `scripts/nabludenia_digest.sh` в `/tmp/adv015b-digest`. Он честно называет первую открытую запись из `NABLIUDENIA*`, но безусловно печатает:

```text
непушенных тегов: 0
статус: чисто
```

Контролируемый git-корень `/tmp/adv015b-digest-controlled` содержал открытую `Н-777`, локальный тег `local-only`, bare `origin` без тегов (`git -C /tmp/adv015b-digest-controlled ls-remote --tags origin | wc -l` → `0`) и неотслеживаемый `untracked.txt` (`git status --short` → `?? untracked.txt`). Прямой запуск:

```sh
bash /tmp/adv015b-digest/scripts/nabludenia_digest.sh --for-session --root /tmp/adv015b-digest-controlled
```

вывел `Н-777 → контракт 015`, но одновременно ложные `непушенных тегов: 0` и `статус: чисто` при одном непушенном теге и грязном дереве.

Несмотря на эту ложь, проверка прошла зелёной:

```sh
cd /tmp/adv015b-digest
bash scripts/verify_antiplacebo.sh --scope drill_startup_digest
```

**`rc=0`, 12/12.** Это дефект проверки. Real-ветвь проверяет наличие хотя бы одного имени открытой записи; тег сверяет лишь когда фактический счётчик больше нуля в пустом `$WORK`, а `git status` в real-ветви вообще не предъявляется. После зелёного контроля fixtures подменяют субъект только своими маркерными стабами, поэтому бесмаркерная ложь о тегах и статусе не исполняется против грязного/tagged входа.

Требуемая правка за автором: real-предъявление должно создавать управляемый git-root с непушенным тегом и аномалией статуса и требовать точное число тегов/их имя и строку `статус: аномалии` с записью статуса. Проверка не должна зависеть от строк-маркеров фикстур для этих инвариантов.

## 3. Живое дерево

Каждый запуск ниже дал `rc=0` и был обрамлён неизменным MD5-сторожем:

- `bash scripts/verify_antiplacebo.sh --scope check_nabludenia` — 12/12;
- `bash scripts/verify_antiplacebo.sh --scope drill_gate_draft` — 7/7;
- `bash scripts/verify_antiplacebo.sh --scope drill_startup_digest` — 12/12;
- `bash scripts/verify_antiplacebo.sh --scope drill_nabludenia_nechitaemo` — 1/1;
- пять проб: `fixtures/check_nabludenia/probe_nabludenia_krasnoe.sh`, `fixtures/drill_gate_draft/probe_gate_draft_krasnyj.sh`, `fixtures/drill_startup_digest/probe_digest_krasnyj.sh`, прямой `scripts/drill_nabludenia_nechitaemo.sh`, `fixtures/check_nabludenia/probe_migracija_adresov.sh`;
- `bash scripts/check_contract_frozen.sh` — `rc=0` (15 замороженных, 3 черновика).

Живая зелень не отменяет находку 2.2: она доказывает работоспособность текущего предмета, но не то, что scoped-предъявление ловит бесмаркерную ложь о состоянии дерева.
