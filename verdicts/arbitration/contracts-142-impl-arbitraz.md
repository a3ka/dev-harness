РЕШЕНИЕ
OBJECT=5f7649de1db2801eb7f6de221f5d62d03dfa5755
СУД: repo=dev-harness; предмет=142; фаза=реализация; роль=arbiter; вызов=арбитраж реализации (один на фазу; арбитраж по контракту `contracts-142-arbitraz.md` — другая фаза, прецедент 118: `contracts-118-v2-arbitraz.md` + `contracts-118-impl-arbitraz.md`); модель-план=anthropic/claude-fable-5-1 (роль arbiter → профиль `plan` = @fable, `config/agent_models.json:69-73,96`); сессия=Arbiter142-2; модель-факт=anthropic/claude-fable-5-1; SHA=5f7649de1db2801eb7f6de221f5d62d03dfa5755; предыдущий=adversary 142 вызов 1/2 FAIL (`verdicts/adversary/contracts-142-impl-v1.md`, OBJECT `f7eee4bae373`) + вызов 2/2 FAIL (`verdicts/adversary/contracts-142-impl-v2.md`, OBJECT `5f7649de`), оба в main `039db92b`; исключение=нет
Независимость: автор конструкции — architect (GLM, `config/agent_models.json`), исполнитель Impl142b (MiniMax/GLM по заданию), адверсарий — openai-codex/gpt-5.6-terra (строка СУД обоих вердиктов); арбитр — anthropic/claude-fable-5-1. Семейного совпадения ни с одной стороной нет. Каждый спорный пункт решён собственным прогоном дверей, не доверием к вердикту стороны.
Счёт по сторонам: вопрос 1 (нарушено ли И-4/И-5) — автору/исполнителю целиком; вопрос 2 (путь) — (Б) принять остаток, cognitive-only; вопрос 3 — граница задана ниже. Замер адверсария воспроизведён дословно и верен как факт; неверна квалификация.

# Итог одной строкой

Строка дома `FOO_URL\0=<значение>` НЕ нарушает И-4/И-5 frozen-контракта 142/1: «имя ключа» в контракте — ключ парсера 125 (`load_env`, И-5 «парсер KEY=VALUE … не меняются», §Существующее «парсер KEY=VALUE как `load_env`», §Демаркация «ключ … с усечением по пробелу»), а парсер 125 — и в двери, и в самом `workshop` — отдаёт для этой строки ключ `FOO_URL`; сужение на ней есть ровно класс И-3 (адресное имя ∧ значение без userinfo), то есть единственное разрешённое. NUL — ЕДИНСТВЕННЫЙ из 256 байтов, который `read` удаляет (замер 4); все остальные байты вне грамматики (C0, DEL, 0x80–0xFF, не-UTF8, `\`, CR в имени, TAB) в имени сохраняются, грамматику не проходят и судятся fail-closed на OBJECT (замер 1, обе локали). Закрывающее свойство адверсария, применённое буквально, запрещает и усечение по пробелу (`FOO_URL extra=v`: OBJECT rc 0 / main rc 1 — замер 1), которое frozen-текст прямо объявляет конформным. Состояние достижимо только рукой доверенного писателя дома (харнесс дом не пишет — замер 3), и его эффект тождествен конформной строке `FOO_URL=<значение>`, принятой словом владельца. Путь (Б): остаток `cognitive-only`, frozen-текст НЕ правится, подпись владельца НЕ нужна. Исправительного круга нет; предмет идёт к ревьюеру (один полный вызов, бюджет ревьюера не тронут).

# 1. Первоисточники и замеры

Рабочий клон: `/tmp/dev-harness-verify/Arbiter142/repo`, `git checkout 5f7649de…` (ветка `origin/owner/train-i142c`); `origin/main` = `039db92b`; merge-base = `db45f9a0`; `git diff --stat origin/main HEAD -- scripts/connect_project.sh` → `31 insertions(+), 12 deletions(-)`; `frozen/contracts/142/1` = `5663a392`, `git diff frozen/contracts/142/1 HEAD -- contracts/142-skaner-sekretov.md` → пусто (текст контракта на OBJECT = замороженный). Дом секретов станции не читался и не копировался: все миры — поддельный `HOME` в `mktemp -d` под `/tmp/dev-harness-verify/Arbiter142/probe/`, удалены по trap.

Двери: `door_object.sh` = `scripts/connect_project.sh` OBJECT (sha256 `62a33e2c…`), `door_main.sh` = `git show origin/main:scripts/connect_project.sh` (sha256 `6e49b5ae…`). Мир = установка (субъект + `path-guard.ts` + `agent_models.json` + `next_id.sh`/`profile_resolver.sh` из дерева) + двойник `workshop` (пишет `launch`) + стаб `omp` v10 + git-проект с неотслеживаемым `leak.txt`, содержащим ожидаемое (нормализованное) значение; дом — байты по `printf`. Запуск: `env -u HARNESS_PROJECT_LAYER_ROOT HOME=$M/home PATH=$M/bin:$PATH LC_ALL=<loc> bash $M/inst/scripts/connect_project.sh $M/proj`.

## Замер 1 — обе двери на сырых строках дома (`probe/probe.sh`, LC_ALL=C.UTF-8; bash 5.2.21)

```text
nul-konec-imeni        house=FOO_URL\0=probe-nul-value\n      | OBJECT rc=0 calls=1 err= | MAIN rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve: значение дом
nul-seredina-imeni     house=FOO\0_URL=probe-v2\n             | OBJECT rc=0 calls=1 err= | MAIN rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve …
nul-nachalo-imeni      house=\0FOO_URL=probe-v3\n             | OBJECT rc=0 calls=1 err= | MAIN rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve …
nul-imya-marker        house=FOO_URL\0_KEY=probe-v4\n         | OBJECT rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve … | MAIN rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve …
nul-imya-userinfo      house=FOO_URL\0=http://u:p@h/x\n       | OBJECT rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve … | MAIN rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve …
nul-v-znachenii-adr    house=FOO_URL=pro\0be5\n               | OBJECT rc=0 calls=1 err= | MAIN rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve …
nul-v-znachenii-sek    house=ZAI_API_KEY=pro\0be6\n           | OBJECT rc=1 calls=0 err=grep: …/secrets.env: binary file matches | MAIN rc=1 calls=0 err=grep: …/secrets.env: binary file matches
nul-pustoe-imya        house=\0=probe17\n                     | OBJECT rc=0 calls=1 err= | MAIN rc=0 calls=1 err=
nul-bez-lf             house=FOO_URL\0=probe18                | OBJECT rc=0 calls=1 err= | MAIN rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve …
soh-v-imeni            house=FOO_URL\001=probe7\n             | OBJECT rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve … | MAIN rc=1 calls=0 …
cr-v-imeni             house=FOO_URL\r=probe8\n               | OBJECT rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve … | MAIN rc=1 calls=0 …
tab-v-imeni            house=FOO_URL\t=probe9\n               | OBJECT rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve … | MAIN rc=1 calls=0 …
ff-bajt-v-imeni        house=FOO_URL\377=probe10\n            | OBJECT rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve … | MAIN rc=1 calls=0 …
c0-80-v-imeni          house=FOO_URL\300\200=probe10b\n       | OBJECT rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve … | MAIN rc=1 calls=0 …
del-v-imeni            house=FOO_URL\177=probe11\n            | OBJECT rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve … | MAIN rc=1 calls=0 …
esc-v-imeni            house=FOO_URL\033=probe12\n            | OBJECT rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve … | MAIN rc=1 calls=0 …
vt-v-imeni             house=FOO_URL\013=probe13\n            | OBJECT rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve … | MAIN rc=1 calls=0 …
bs-v-imeni             house=FOO_URL\\=probe14\n              | OBJECT rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve … | MAIN rc=1 calls=0 …
probel-usechenie       house=FOO_URL extra=probe15\n          | OBJECT rc=0 calls=1 err= | MAIN rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve …
vedushhee-ravno        house==FOO_URL=probe16\n               | OBJECT rc=0 calls=1 err= | MAIN rc=0 calls=1 err=
konform-adres          house=FOO_URL=probe20\n                | OBJECT rc=0 calls=1 err= | MAIN rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve …
konform-sekret         house=ZAI_API_KEY=probe21\n            | OBJECT rc=1 calls=0 err=connect ОТКАЗ: sekret-v-dereve … | MAIN rc=1 calls=0 …
```

Повтор под `LC_ALL=C` (те же миры): `nul-konec/seredina/nachalo` — OBJECT rc 0 calls 1 / MAIN rc 1 calls 0; `ff-bajt`, `c0-80`, `del` — rc 1 calls 0 на обеих; `probel-usechenie` — OBJECT rc 0 / MAIN rc 1. Локаль результат не меняет.

Пояснения к двум строкам (`probe/probe2.sh`, полный stderr): `nul-v-znachenii-sek` — `grep: … binary file matches` печатает бутстрап-grep строки 187 двери (`grep -E '^(ZAI_API_KEY|…)=' "$DOM_SEKRETOV"`), одинаковый на обеих дверях; второй строкой stderr — тот же `connect ОТКАЗ: sekret-v-dereve … «leak.txt»`, rc 1 на обеих. Вариант `A=1\nFOO_URL\0=probe19` дал rc 1 на обеих из-за значения `1` (имя `A` — секрет fail-closed, `1` найдено в `.harness/project-layer.json`), а не из-за NUL; с нейтральной первой строкой (`ABCDEF=zzz-nikuda\nFOO_URL\0=probe19`) — OBJECT rc 0 calls 1 / MAIN rc 1 calls 0, как в одиночной строке.

Факт адверсария воспроизведён дословно: на строке с NUL в имени OBJECT поднимает сессию, main отказывает.

## Замер 2 — батарея на OBJECT

```text
$ bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh
… s142 subjekt: клеток 119, зелёных 119, красных 0
rc=0
$ jq -r '.osi|length' …/source.json → 119;  клеток с «nul» в id → 0
```

## Замер 3 — кто пишет дом секретов

`grep secrets\.env` по `scripts/`, `workshop`, `.omp/`: `workshop:142-148` (`bootstrap_env` — только чтение), `connect_project.sh:177,186-187,316` (чтение), `check_metering.sh:285,898` и `proxy/metering_proxy.ts:953` (пишут СВОИ временные `secrets.env` в tmp, не дом станции). Ни один инструмент харнесса дом `~/.config/dev-harness/secrets.env` не пишет; писатель — человек (владелец/консультант) редактором или `printf`.

## Замер 4 — какие байты парсер 125 (`IFS='=' read -r k v`) не сохраняет в имени (`probe/probe4_bytes.sh`, все 256 байтов, LC_ALL=C)

```text
bash=5.2.21(1)-release kept=253 lost=[0:NUL] split=[10:LF-конец-строки 61:'='-разрез]
```

Удаляется только NUL. LF и `=` — контрактная семантика строки/разреза. Всё прочее остаётся в `k` и (вне `[A-Za-z0-9_]`) грамматику `IMYA_RE` не проходит → судится (замер 1).

## Замер 5 — эталонный парсер 125 (`workshop` `load_env`, строки 127-135 дословно; `probe/probe3_loadenv.sh`)

```text
$ printf 'FOO_URL\0=val1\nFOO.URL=val2\n' > .env; load_env .; env | grep -E '^FOO'
…probe3_loadenv.sh: line 10: FOO.URL: invalid variable name
FOO_URL=val1
```

Система сама (workshop) читает строку `FOO_URL\0=val1` как переменную `FOO_URL`; `FOO.URL` — отвергает. Это ровно различие между блокером 1 адверсария 1/2 (`FOO.URL`: ключ парсера 125 неконформен — нарушение, принято и исправлено) и блокером адверсария 2/2 (`FOO_URL\0`: ключ парсера 125 конформен и адресен).

# 2. Вопрос 1 — достижимость и нарушение И-4/И-5

**Решение: нарушения нет. Прав автор/исполнитель.**

1. Что такое «имя» в контракте. И-5: «парсер KEY=VALUE (первый `=`, усечение пробела, `#`-комментарии, CRLF-снятие, идиома последней строки, …) — не меняются и не ослабляются». §Существующее: «парсер KEY=VALUE как `load_env` (… ключ-алфавит `[A-Za-z_][A-Za-z0-9_]*`, усечение ключа по пробелу …)». §Демаркация: «ключ `[A-Za-z_][A-Za-z0-9_]*` с усечением по пробелу». Грамматика применяется к ключу ПОСЛЕ парсера 125 — иначе «усечение по пробелу» не было бы конформным. Парсер 125 есть `bash read` (И-5 запрещает его менять), и для строки с NUL его ключ — `FOO_URL` (замеры 4, 5). И-3 на этом ключе выполняется (адресный суффикс, значение без userinfo) — сужение относится к единственному разрешённому классу И-4.
2. Закрывающее свойство адверсария («никакая строка с неконформным ИСХОДНЫМ именем не получает исключение И-3 нормализацией») противоречит frozen-тексту: усечение по пробелу — та же нормализация парсера 125 до грамматики, и на ней OBJECT/main расходятся так же (`FOO_URL extra=v`: rc 0 / rc 1, замер 1), а контракт объявляет её конформной. Свойство в этой формулировке принять нельзя без правки замороженного текста.
3. Допустимый вход. §Демаркация ограничивает конформные строки дома грамматикой 125; строка с NUL в неё не входит. Порог (`roles/critic.md` §Порог) требует «допустимый вход ИЛИ достижимое состояние». Достижимость: дом пишут только люди (замер 3); редактор/буфер обмена NUL не вносят; сбойное зануление файла (crash zero-fill) даёт NUL-ПРОБЕГ вместо содержимого, у такой строки значение пусто/NUL → обе двери её пропускают одинаково (`\0=…`, пустое значение), расхождения нет. Состояние достижимо ТОЛЬКО намеренным `printf`/скриптом доверенного писателя дома, который тем же правом пишет конформную `FOO_URL=<секрет>` — с тем же эффектом на OBJECT (И-3, слово владельца 26.10). Атакующий модели угроз 125/142 — агент сессии, пишущий в дерево проекта; дом секретов он не пишет. Следовательно, это не «нарушение обязательства на достижимом состоянии», а состояние, эффект которого тождествен уже принятому владельцем классу.
4. Сравнение с принятыми классами (замер 1 и вердикт 2/2): многострочное имя, `FOO.URL`, `FOO-URL`, `FOO URL`, цифра первой, Unicode, `＝`, пустое имя — ключ парсера 125 неконформен → судятся fail-closed на OBJECT (rc 1), как у main. NUL — единственный байт, который парсер удаляет, и единственный, где «сырое имя» и «ключ парсера» различаются. Класс конечен и исчерпан этим байтом (замер 4).
5. И-5 не нарушено: парсер, имя/текст/момент отказа, границы, `grep -lsF` — дословно (diff 31/12 только блок предиката, подтверждено адверсарием 2/2 и диффом здесь). Напротив, именно И-5 запрещает дешёвое «закрытие»: проверка сырых байтов ДО `read` — изменение парсера или новый именованный отказ двери, которого нет ни в 125, ни в блоке предиката.

# 3. Вопрос 2 — путь: (Б) принять остаток, cognitive-only

**Решение: (Б).** Основание — §2: обязательство не нарушено, поэтому §Быстрый-процесс («доказанное нарушение … исправляется до accept») не включается, и действует правило триажа владельца («выдуманное адверсарием — принятый остаточный риск cognitive-only»).

Цена (А), отвергнутая: детектировать NUL внутри `k` невозможно (bash-строка NUL не несёт), значит правка — вне цикла: либо предпроверка файла (`tr -d '\0' | cmp`, `grep -P '\x00'`, `od`) с НОВЫМ именованным отказом двери (новая семантика 125-зоны: дверь отказывает на файле, который сам `workshop` читает штатно), либо подмена байта до `read` (`tr '\0' '\001'`) — меняет парсер (И-5) и открывает следующий круг: NUL в ЗНАЧЕНИИ под секретным именем (`ZAI_API_KEY=pro\0be`) main судит как `probe`, а подменённая дверь судила бы `pro\1be` — новое «сужение» того же неконформного класса. Плюс: модель + sha256-пин + клетки + стаб (architect), блок (implementer), scoped-судья — три агента и перерасход бюджета ради состояния, эффект которого равен уже принятому. Выбор (А) при нулевой инженерной выгоде был бы решением о деньгах, а не о правоте.

Правка frozen-текста (v2) и подпись владельца — НЕ нужны: текст 142/1 на OBJECT неизменён (diff с тегом пуст), новый риск сверх принятого И-3 не принимается, формулировка остатка — запись в `NABLIUDENIA` (project state) и этот вердикт.

Текст записи для NABLIUDENIA (ставит оркестратор/архитектор по этому вердикту, не арбитр):

> Н-142-NUL (cognitive-only, арбитраж `verdicts/arbitration/contracts-142-impl-arbitraz.md`): строка дома секретов с байтом NUL в имени (`FOO_URL\0=…`) читается парсером 125 (`bash read`, как `workshop load_env`) как ключ без NUL; если ключ после этого адресный без userinfo — значение не судится (класс И-3). NUL — единственный байт, удаляемый парсером (замер 256 байтов); все прочие байты вне грамматики в имени судятся fail-closed. Дом пишут только владелец/консультант; эффект тождествен конформной строке `FOO_URL=…`. Ловец — ревьюер конфигурации дома секретов; закрытие (если захочет владелец) — v+1 142 с новым именованным отказом двери на NUL в доме, цена: модель+клетки+стаб+блок+судья.

# 4. Вопрос 3 — конечная граница (что судьи больше не поднимают блокером по 142)

Хотя путь (Б) исправительного круга не требует, граница фиксируется, чтобы цепочка не продолжилась у ревьюера:

- **Вне блокера (решено здесь):** любой байт в СЫРОЙ строке дома, который парсер 125 удаляет или по которому режет — NUL (удаляется; единственный такой байт), LF (конец строки), первый `=` (разрез), пробел в ключе (усечение), CR в конце значения (снятие), отсутствие хвостового LF. Поведение OBJECT на такой строке = поведение на строке после нормализации парсера 125; расхождение с main на ней — класс И-3, разрешённый.
- **Вне блокера (измерено, совпадает с main):** все 253 прочих байта в имени (C0-управляющие, TAB, CR внутри имени, DEL, 0x80–0xFF, не-UTF8, `\`, Unicode, `＝`), имена с `.`/`-`/пробелом/цифрой первой, пустое имя, многострочные — судятся fail-closed на OBJECT (rc 1 до `workshop`); NUL в имени с секретным маркером или с userinfo в значении — судятся (замер 1).
- **Вне предмета 142 (решено адверсарием 1/2+2/2, подтверждено):** `xargs grep -lsF | sed -n 1p` без `pipefail` (grep rc 127) — строка идентична main, 142 её не меняет; ловец — отдельный предмет, если владелец его захочет.
- **Вне предмета (frozen §НЕ ЗАЩИЩАЕТ):** токен в path/query под адресным именем; `=` в значении; LOG_LEVEL-подобные «прочие параметры»; игнорируемые git файлы; живой omp после exec; байтовое равенство моделей 125/136.

Новый блокер по 142 возможен только на КОНФОРМНОМ входе §Демаркация (ключ грамматики 125 после парсера) либо на изменённой дельте.

# 5. Что дальше (порядок, не новый круг)

1. Исправительного круга по адверсарию нет: правка кода не требуется, OBJECT `5f7649de` остаётся предметом. Бюджет адверсария исчерпан; этот вердикт accept не является и дополнительного вызова адверсария не открывает (§Остановка). Повторный вызов адверсария ради перештамповки без дельты — лишний; если оркестратор/владелец читает «обязательный accept» как требование подписи адверсария `accept` в файле, это явное решение владельца о дополнительном вызове (воля/деньги), и содержанием такого вызова была бы только граница §4.
2. Ревьюер — ОДИН полный вызов по `roles/reviewer.md` (бюджет ревьюера не тронут: 1 полный + ≤1 scoped). Предмет: весь diff OBJECT против main (31/12 в `scripts/connect_project.sh`), граница implementer (diff минус комментарии = блок предиката по модели `fixtures/workshop_project/skaner_sekretov_142/model/connect_project.sh`), наследие P/Q, канон байт в байт (клетки r1/r2). Классы §4 ревьюер блокером не поднимает; новый класс — только по правилу §Порог на конформном входе.
3. Запись Н-142-NUL в NABLIUDENIA (текст §3) — оркестратор/архитектор, в проектном state по контракту 996; frozen-текст и `source.json` не трогаются.
4. Затем — проводка CI оркестратором (step-строка 142, окно freeze..done) → done, как в контракте.

# 6. Остаток и процессные замечания (не блокеры)

- Процесс: `roles/critic.md` §Остановка говорит «один арбитраж на предмет»; по 142 уже был арбитраж фазы контракта. Этот вызов созван оркестратором с подтверждением консультанта как арбитраж фазы реализации — по прецеденту 118 (арбитражи `contracts-118-v2-arbitraz.md` и `contracts-118-impl-arbitraz.md`). Если владелец читает норму буквально — вопрос передаётся ему; инженерное решение от этого не меняется.
- Адверсарию: факт измерен верно и воспроизведён; квалификация «неконформное исходное имя» расходится с определением имени во frozen-тексте (ключ парсера 125) и с конформностью усечения по пробелу. Совет на будущее (не норма): закрывающее свойство о «сыром имени» требует сначала показать, что контракт определяет имя сырыми байтами.
- Артефакты замеров: `/tmp/dev-harness-verify/Arbiter142/probe/{probe.sh,probe2.sh,probe3_loadenv.sh,probe4_bytes.sh,door_object.sh,door_main.sh}`; миры удалены. Commit/push этого вердикта — по прямому запрету задания не выполнялись; файл лежит в `/tmp/dev-harness-verify/Arbiter142/verdicts/arbitration/`, в репозиторий его кладёт оркестратор под `user.name=arbiter`.
