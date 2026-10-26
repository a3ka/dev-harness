FAIL
OBJECT=9ec350f7e34f893028c5a0b2b31913a6dca44da8
СУД: repo=dev-harness; предмет=140; фаза=реализация; роль=adversary; вызов=2/2; модель-план=zai/glm-5.3; сессия=Adv140b; модель-факт=openai-codex/gpt-5.6-terra; SHA=9ec350f7e34f893028c5a0b2b31913a6dca44da8; предыдущий=/tmp/dev-harness-verify/Adv140/verdicts/adversary/contracts-140-impl-v1.md; исключение=нет

Кандидат прочитан в изолированном SSH-клоне `/tmp/dev-harness-verify/Adv140b/repo`; `git rev-parse HEAD` = `9ec350f7e34f893028c5a0b2b31913a6dca44da8`. Автор реализации — семейство zai/glm-5.3 по заданию, судья — openai-codex/gpt-5.6-terra: независимость соблюдена.

## БЛОКИРУЕТ

БЛОКИРУЕТ `scripts/zamok_predmeta.sh:165-176` и непокрытый класс батареи — канон класса риска всё ещё допускает `reviewer` без yielded `adversary` при недопустимом/неоднозначном источнике класса.

ОБЯЗАТЕЛЬСТВО: исправительный объём прямо требует, чтобы значение вне алфавита, ложная строка в Markdown-коде, matching-файл в подкаталоге или симлинк не превращали предмет в «обычный»: в этих состояниях дверь обязана до START отказать `KLASS_RISKA_NET`, а не пустить reviewer. Это — условие воли владельца «рисковый — адверсарий строго до ревьюера» и закрытие причины первого FAIL.

КЛАСС ПРИЧИНЫ: правильный ответ не на тот вопрос / неполный синтаксический канон. `klass_riska()` берёт `grep '^КЛАСС РИСКА:'`, затем отбрасывает всё после первого ASCII-пробела через `cut -d' ' -f1`; он не знает Markdown-контекст. Одновременно `find ... -maxdepth 1 -type f -name "$1-*.md"` молча исключает matching-пути в подкаталогах и симлинки. Эти отброшенные данные не создают неоднозначности и не дают fail-closed.

СОСТОЯНИЕ: для каждого случая создан отдельный одноразовый git-мир под `/tmp/dev-harness-verify/Adv140b/risk-probe/`: есть worker `Worker141` с START, его журнал содержит literal `{"toolName":"yield"}`, ветка `wip/141/test` существует, OBJECT reviewer равен её tip, adversary START/yield отсутствует. Поэтому до классификации соблюдены все независимые ворота судьи. В `contracts/` лежат соответственно:

* единственный `141-a.md`: `КЛАСС РИСКА: обычный EXTRA` (значение вне допустимого алфавита);
* единственный `141-a.md`, где ровно строка `КЛАСС РИСКА: обычный` лежит между fenced-code markers;
* regular `141-a.md` с `обычный` плюс `sub/141-b.md` с `рисковый`;
* regular `141-a.md` с `обычный` плюс `141-b.md`-симлинк на файл с `рисковый`.

НАБЛЮДЕНИЕ (сырая команда и вывод):
```text
$ python3 /tmp/dev-harness-verify/Adv140b/risk_source_probe.py
invalid-trailing rc=0 stdout='PUSCHEM Reviewer141 dev-harness/141 (sudja/reviewer)' stderr='' ledger=[..., '{"t":"START",...,"holder":"Reviewer141","klass":"sudja","rol":"reviewer",...}']
code-only-ordinary rc=0 stdout='PUSCHEM Reviewer141 dev-harness/141 (sudja/reviewer)' stderr='' ledger=[..., '{"t":"START",...,"holder":"Reviewer141","klass":"sudja","rol":"reviewer",...}']
subdir-risk-ignored rc=0 stdout='PUSCHEM Reviewer141 dev-harness/141 (sudja/reviewer)' stderr='' ledger=[..., '{"t":"START",...,"holder":"Reviewer141","klass":"sudja","rol":"reviewer",...}']
symlink-risk-ignored rc=0 stdout='PUSCHEM Reviewer141 dev-harness/141 (sudja/reviewer)' stderr='' ledger=[..., '{"t":"START",...,"holder":"Reviewer141","klass":"sudja","rol":"reviewer",...}']
[rc=0]
```

Это достижимый обход порядка adversary→reviewer: reviewer уже создан (START в ledger), хотя обозначение риска не было валидно и/или конфликтующий риск был исключён из канона. Поставленная батарея остаётся зелёной на той же реализации, следовательно не предъявляет этот класс.

ЗАКРЫВАЮЩЕЕ СВОЙСТВО: для всех объявленных форм источника класс считается определённым только по строгой единственной декларации допустимого значения в каждом допустимом каноническом файле; добавочный текст, Markdown-контекст, несколько деклараций, ignored matching-path или неканонический тип файла создают именованный fail-closed до START. Батарея должна иметь негативные reviewer-without-adversary клетки для каждого самостоятельного обхода и позитив для двух согласных обычных файлов.

АРБИТР: вызов 2/2 завершён вторым FAIL; по §Быстрый-процесс требуется немедленный arbiter по предмету 140, спор — граница и строгая грамматика `КЛАСС РИСКА` для предотвращения reviewer-before-adversary.

## СОВЕТ

Нет.

## Проверенные классы и сырые результаты

1. Закрытие блокера первого вызова и позитивные контроли источника риска:
```text
$ python3 /tmp/dev-harness-verify/Adv140b/risk_source_probe.py
conflict-ab rc=1 stderr='ОТКАЗ: KLASS_RISKA_NET: ... neodnoznachno ... 141-b.md'
conflict-ba rc=1 stderr='ОТКАЗ: KLASS_RISKA_NET: ... neodnoznachno ... 141-b.md'
missing-second rc=1 stderr='ОТКАЗ: KLASS_RISKA_NET: ... 141-b.md'
two-lines-one-file rc=1 stderr='ОТКАЗ: KLASS_RISKA_NET: ... 141-a.md'
agree-ordinary rc=0 stdout='PUSCHEM Reviewer141 dev-harness/141 (sudja/reviewer)'
agree-risky rc=1 stderr='ОТКАЗ: ADVERSARIJ_DO_REVJUERA: предмет 141 рисковый, завершённого адверсария в учёте нет — ревьюер раньше адверсария запрещён'
[rc=0]
```
Во всех отказах ledger содержит только START worker: START reviewer/ребёнка нет. Тем самым исходная коллизия двух regular файлов обоих порядков закрыта; дефект выше — иной неполный разбор канона.

2. Батарея v3 на поставленной двери и позитивный контроль:
```text
$ TMPDIR=/tmp/dev-harness-verify/Adv140b/tmp bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model
54 CASE ... ok
MODEL_rc=0
$ ... red_odin_agent_140.sh
SUBJEKT: /tmp/dev-harness-verify/Adv140b/repo/scripts/zamok_predmeta.sh
KLETKI 54 KRASNYH 0
PLAIN_rc=0
$ ... red_odin_agent_140.sh --stabs
SVJAZI 43
SUBJEKT_SVJAZI 43
STABS_rc=0
```
`--stabs` предъявил 29 стабов, включая `s28-pervyj-rezultat-find` красным на s23/s24/s25/s28, и `x01-vsegda-puschem` красным на 12 связях; `STAB_ZHIV` не напечатан.

3. Изолированная среда и порча носителя:
```text
$ env -i PATH=/usr/bin:/bin HOME=$tmp TMPDIR=$tmp bash .../red_odin_agent_140.sh --model
MODEL_ENV_rc=0
$ env -i PATH=/usr/bin:/bin HOME=$tmp TMPDIR=$tmp bash .../red_odin_agent_140.sh --stabs
SVJAZI 43
SUBJEKT_SVJAZI 43
STABS_ENV_rc=0
$ python3 /tmp/dev-harness-verify/Adv140b/tamper_probe.py
MODEL_TAMPER rc=2 stdout='' stderr='ORACLE_TAMPERED: sha256 носителя model/zamok_predmeta.sh'
```

4. Отрицательный контроль старой двери именно на исправленных клетках:
```text
$ python3 /tmp/dev-harness-verify/Adv140b/old_door_probe.py
OLD_DOOR rc=1
CASE s23-klass-riska-konflikt-ab KRASNO: ...
CASE s24-klass-riska-konflikt-ba KRASNO: rc: rc 0 != 1; ...
CASE s25-klass-riska-net-stroki-vo-vtorom KRASNO: rc: rc 0 != 1; ...
CASE s28-klass-riska-shest-fajlov KRASNO: rc: rc 0 != 1; ...
KLETKI 54 KRASNYH 4
```
Все остальные 50 клеток в этом прогоне напечатаны `ok`.

5. Станционная интеграция — три последовательных прогона:
```text
$ TMPDIR=/tmp/dev-harness-verify/Adv140b/stationtmp bash fixtures/workshop_project/odin_agent_140/stancija_odin_agent_140.sh
PROB VSEGO 15 KRASNYH 0
S1_rc=0
... второй тот же прогон: PROB VSEGO 15 KRASNYH 0; S2_rc=0
... третий тот же прогон: PROB VSEGO 15 KRASNYH 0; S3_rc=0
```
В каждом прогоне p01–p14 и m01 напечатаны `OK`.

6. Регресс-сеть:
```text
$ bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta
БАТАРЕЯ zamok_predmeta: итог 4/4 классов закрыто
[rc=0]
$ npm run check:antiplacebo -- --scope check_ids
барьеров: 1 · фикстур: 11 · предъявлено красным повторным прогоном: 11
[rc=0]
$ git fetch --no-write-fetch-head origin 73aa92b7a0b0d756f26c35a06f5f529154cf37da && git diff --exit-code 73aa92b7a..9ec350f7e -- .omp/extensions/spawn-guard.ts
SPAWN_DIFF_rc=0
```
`git diff --name-only 1994628e1..9ec350f7e` предъявил только `scripts/zamok_predmeta.sh`, `.omp/extensions/spawn-guard.ts`, профиль `zamok_predmeta` и 33 файла батареи `fixtures/workshop_project/odin_agent_140/` (model/osi/probe/source/stabs); иных зон нет.

## Не проверено

Живой `omp`-спавн с локальным provider-stand повторно не запускался: после доказанного второго блокирующего класса scoped-повтор не требует нового полного исследования неизменённой поверхности. В первом вызове живая изолированная проба уже показала один разрешённый worker и блокирование дубля до создания `WorkerTwo`; текущая станционная приёмка p01–p14/m01 прошла 15/15 трижды. Путь self-block легитимного спавна отдельно не оспорен новым фактом.
