FAIL
OBJECT=3d5d2e0289691eb74842a4af47840f694ece3914
СУД: репо=dev-harness; предмет=219; фаза=реализация; роль=adversary; вызов=2 (узкий, дельта ремонта; предыдущий=archive/219/adversary-v1-fail-159beca827); сессия=Adv219b; модель-факт=openai-codex/gpt-6.1-terra; автор implementer — MiniMax, батарея Architect219b; класс=рисковый.

## Блоки

**К-01 — закрыт.** `registry/ci-steps.tsv:335` содержит один шаг: `bash fixtures/workshop_project/uchetnye_puti_219/red_uchetnye_puti_219.sh --repo . && bash fixtures/workshop_project/uchetnye_puti_219/red_uchetnye_puti_219.sh --stabs`. Извлечённая команда выполнена через `bash -c` в отдельном чистом клоне с origin, rc 0; обе части реально напечатали итоги, 35/35 и 31/31. `bash scripts/gen_ci_steps.sh --check` rc 0. Вес 30, замер 16.

**К-08 — БЛОКИРУЕТ: закрыт конкретный прежний мутант, но не класс совместных правок U и учётного файла.** ПРОИСХОЖДЕНИЕ: узкое-закрытие. КЛАСС: К-08. ОБЯЗАТЕЛЬСТВО: `contracts/219-uchetnye-puti-ci-klass.md:56` требует `kod` для добавления, удаления и подмены U даже при одновременной правке исключаемого пути. СОСТОЯНИЕ: `fixtures/workshop_project/uchetnye_puti_219/probe.py:242-255` в новых add/remove-мирах меняет только pauzy; в replace-мире меняет одновременно все три файла. Вход — штатный Git-коммит, прямо предусмотренный И3: изменение U и одного из включённых файлов. Источник ошибочного механизма — замена существующего сравнения хешей `scripts/ci_klass.sh:219` условной веткой, а не подделка фикстуры или оракула.

ОБХОД: в отдельном клоне заменить строку вывода `c_klass` приведённым ниже телом, выбрав `target = 'registry/mesto-legacy.tsv'` и `condition = len(after) < len(before)`. `W --repo .` зелена, rc 0, 35/35, но настоящий Git-мир с удалением строки `uchet docs/` и правкой только `registry/mesto-legacy.tsv` возвращает `uchet`, rc 0, вместо обязательного `kod`. На той же паре входов честная production возвращает `kod`, rc 0. Аналогично зелены мутанты place/add и lessons/remove; lessons/replace ловится. Каждая является отдельной заменой единственной существующей операции, остальные hash/strip оставлены честными. Проверяемое закрывающее свойство — различать такие совместные изменения независимо от того, какой включённый файл меняется и как меняется U; соседний data-only контроль должен остаться зелёным.

Тело замены (внутри `c_klass`, `o`, `n`, `pats` — существующие локальные переменные):

```python
    changed = git('diff', '--name-only', o, n)[1].decode().splitlines()
    before = set(x for x in git('show', o + ':' + REG)[1].splitlines() if x.startswith(b'uchet\t'))
    after = set(x for x in git('show', n + ':' + REG)[1].splitlines() if x.startswith(b'uchet\t'))
    if REG in changed and 'registry/mesto-legacy.tsv' in changed and len(after) < len(before):
        print('uchet')
    else:
        print('uchet' if kod_hash(o, pats) == kod_hash(n, pats) else 'kod')
```

Для воспроизведения в одноразовом клоне: применить замену единственного якоря `    print('uchet' if kod_hash(o, pats) == kod_hash(n, pats) else 'kod')`; `W --repo .`. Для свидетеля создать Git-репозиторий с этим `scripts/ci_klass.sh`, `.github/workflows/ci.yml`, `registry/ci-steps.tsv` со строками `uchet<TAB>docs/` и `uchet<TAB>registry/mesto-legacy.tsv`, и файлом `registry/mesto-legacy.tsv`; commit base. Удалить первую строку реестра и изменить только место; commit joint; `bash scripts/ci_klass.sh klass <base> HEAD`. Сравнить с той же процедурой при неизменном `scripts/ci_klass.sh`. Все операции выполнены в отдельных репозиториях с собственной `.git`.

Сырой результат атак (команда `python3 tmp/attacks219.py`, скрипт — временный локальный генератор описанных выше отдельных миров; имена обозначают файл и операцию U):

```text
ATTACK place-add rc 0
KLETKI=35 ZELENYE=35 KRASNYE=0
WITNESS place-add rc 0 stdout 'uchet\n' stderr ''
ATTACK place-remove rc 0
KLETKI=35 ZELENYE=35 KRASNYE=0
WITNESS place-remove rc 0 stdout 'uchet\n' stderr ''
ATTACK lessons-remove rc 0
KLETKI=35 ZELENYE=35 KRASNYE=0
WITNESS lessons-remove rc 0 stdout 'uchet\n' stderr ''
ATTACK lessons-replace rc 1
registry-replace-uchet-with-data: RED ["BYTES expected=(0, b'kod\\n', b'') actual=(0, b'uchet\\n', b'')", ...]
KLETKI=35 ZELENYE=34 KRASNYE=1
WITNESS lessons-replace rc 0 stdout 'uchet\n' stderr ''
HONEST registry/mesto-legacy.tsv add rc 0 stdout 'kod\n' stderr ''
HONEST registry/mesto-legacy.tsv remove rc 0 stdout 'kod\n' stderr ''
HONEST registry/lessons-harness.tsv remove rc 0 stdout 'kod\n' stderr ''
```

Для add условие `len(after) > len(before)`, для replace — `len(after) == len(before) and after != before`; для lessons вместо target место указан `registry/lessons-harness.tsv`. В каждом свидетеле меняется именно один соответствующий учётный файл. Это не утверждение о дефекте честного классификатора.

**Правило остановки:** остался только К-08 при честной production. Маршрут — reviewer + owner-аттестат консультанта (R-0074-класс); слово владельца для 219 пока не дано. Повторный FAIL того же класса также требует разрешения установленного порядка остановки/арбитража; не объявлять третий полный проход автоматически.

## Остатки

- ОСТАТОК: К-08 — укусил. `python3 tmp/attacks219.py`: place/remove и lessons/remove `W --repo .` rc 0, 35/35 при ошибочном `klass=uchet`, rc 0, на поддерживаемых joint-коммитах; полный вывод выше. Остаток о распознавании самой фикстуры и подделке оракула общим uid здесь не использован.
- ОСТАТОК: К-16 — не укусил на вызове 1: `bash scripts/ci_klass.sh klass <base> HEAD` с mode/symlink учётного пути: `uchet`, rc 0; вывод командного текста из данных не является его исполнением. Потребители и production в этой дельте не менялись; новый прогон вне узкой области не заявляется.

## Регресс и область

Клон чистый, отдельная `.git`, origin указывает на GitHub, TMPDIR — сосед клона внутри рабочей копии. `W = bash fixtures/workshop_project/uchetnye_puti_219/red_uchetnye_puti_219.sh`. Последовательные прогоны:

```text
W --repo .             rc 0  KLETKI=35 ZELENYE=35 KRASNYE=0
W --model              rc 0  KLETKI=35 ZELENYE=35 KRASNYE=0
W --model --compat     rc 0  ИТОГ 087: клеток ok=110 КРАСНО=0; стаб-пак: поймано 31/31
COMPAT red_ci_b_087.sh rc=0
COMPAT gen_ci_steps.sh rc=0
COMPAT check_provodka.sh rc=0
W --stabs              rc 0  MUTACII=14 SVJAZI=31 POIMANY=31 ZHIVYH=0
W --sintaksis          rc 0  SYNTAX rc=0
W --catalog            rc 0  KLETKI=35 MUTACII=14 SVJAZI=31 UCHET=13
bash scripts/gen_ci_steps.sh --check  rc 0
```

Точная обманка вызова 1 (`model/registry_data_mutation.py:AFTER`, дословная замена `c_klass`): `W --repo .` rc 1, 32/35, красные ровно три новые клетки add/remove/replace; штатный `W --stabs` ловит её на каждой с зелёным `accounting-data-only`. Старые привязки `stabs.tsv` не удалены; diff `probe.py` не удаляет старые клетки, изменения существующих ветвей только расширяют обработку новых имён операций.

`git diff --name-status 89893e66aaa8de10ef07e9f44122cc6b4f066c5d HEAD`: ровно `.github/workflows/ci.yml`, `registry/ci-steps.tsv`, `registry/ci-zamery.tsv` и четыре файла фикстуры: `SDACHA.md`, `model/registry_data_mutation.py`, `probe.py`, `stabs.tsv`. `git diff 89893e66aaa8de10ef07e9f44122cc6b4f066c5d HEAD -- scripts contracts` пуст. Прежние атаки exit 127, константа, PATH, пустой набор, соседний хеш и strip приведены в вердикте вызова 1; на этом узком повторе не выдаются за новые прогоны.

## Карта классов

К-01: закрыт — CI-шаг и generator, rc 0. К-08: блок — joint U+данные выше. К-02–К-07 и К-09–К-17: без изменений с вызова 1 в области дельты; приведённый совместимый регресс не является новым полным аудитом.

## НЕ ЗАЩИЩАЕТ

Вывод ограничен указанным OBJECT и предъявленными Git-мирами. Он не утверждает существования ошибки в неизменной production, не доказывает безопасность от подделки оракула общим uid или будущих потребителей и не заменяет reviewer.

## Советы

Не привязывать все новые ветви только к одному файлу: проверять операции U с отдельными учётными путями и сохранять чистый data-only контроль. Выбор конкретной реализации исправления остаётся за автором.
