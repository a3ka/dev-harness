FAIL
OBJECT=60824db442c0fa7695a4ede8118c268e4cd84bc0
СУД: repo=dev-harness; предмет=142; фаза=реализация (v4); роль=reviewer; вызов=1/2 (полный); модель-план=anthropic/claude-opus-5-5 (роль reviewer, config/agent_models.json); сессия=Rev142v4; модель-факт=anthropic/claude-opus-5-5; SHA=60824db442c0fa7695a4ede8118c268e4cd84bc0 (батарея) + субъект 61ab259a4eed685a2407a0ab9931605ea2ab6cb0, интегральный поезд owner/train-142int d13b48b6180ca7e7699df4b489fbc1bd01197663 (PR #431); предыдущий=adversary 142 impl v4: 1/2 FAIL, 2/2 FAIL, scoped 3 FAIL B4 (B4 принят владельцем 28.10 ~20:10); исключение=нет; независимость: implementer — MiniMax, батарея — architect (GLM), adversary — gpt-5.6-terra, судья — Anthropic opus; переписка сторон не наследовалась.

Находки: `.review/2026-10-28-02.md` (status: ready) — R142v4-B1 (БЛОК), R142v4-S1 (СОВЕТ).

# БЛОКИРУЕТ

## R142v4-B1 — общий класс B4 достижим без знания мира батареи: узкий исполняемый класс СХЕМЫ проходит 158/158

- **ОБЯЗАТЕЛЬСТВО.**
  - И-1/И-2: канон — единственный источник; токен-ветвь `^([^/?#[:space:]]*:)?//…` с необязательной схемой класса `[^/?#[:space:]]*`.
  - §ПРОВОДКА-ЭНФОРСМЕНТ: «guard — чистый энфорсмент И-1…И-7».
  - §ЗАЩИЩАЕТ: «`https://<токен>@host` … с утечкой обязан отказывать».
  - И-5/§Демаркация: значение в кавычках — конформная форма 125 («обе формы значения», клетка z2-kavychki).
  - Порог задания: «если В4 ДОСТИЖИМ БЕЗ знания мира батареи — общий класс — это БЛОК».
- **КЛАСС ПРИЧИНЫ.** Тот же класс, что B2/B3 (арбитр признал их валидными): литерал канона в файле не доказывает исполняемую семантику.
  - Развёртка арбитра Q1 покрыла:
    - класс токена (k121/k122);
    - двоеточие-ветвь (k123);
    - пробельную границу (k124).
  - Класс СХЕМЫ (`[^/?#[:space:]]*:`) не развёрнут.
  - Ни одна из 158 клеток не несёт в позиции схемы байт вне RFC 3986 `[A-Za-z][A-Za-z0-9+.-]*`.
  - В частности, нет клетки со значением токен-URL в кавычках.
- **ДОСТИЖИМОЕ СОСТОЯНИЕ.** Только копия двери: `/tmp/dev-harness-verify/Rev142v4/mutants/mut-rfc-shema/scripts/connect_project.sh`.
  - Строка канона `USERINFO_RE` нетронута.
  - Добавлен `USERINFO_TEST_RE='(^([A-Za-z][A-Za-z0-9+.-]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'`.
  - Исполняемый `grep -Eq` переключён на этот RE; diff — 1 строка добавлена, 1 изменена.
  - Это учебная схема RFC, а не распознавание sentinel, имён или значений батареи.
  - Реальный дом секретов не читался.
- **НАБЛЮДЕНИЕ:**
```text
$ env -i PATH=… HOME=…/Rev142v4/home LC_ALL=C bash fixtures/…/red_skaner_sekretov_142.sh --repo /tmp/dev-harness-verify/Rev142v4/mutants/mut-rfc-shema
s142 repo: клеток 158, зелёных 158, красных 0
rc=0
$ env -i … LC_ALL=C bash /tmp/dev-harness-verify/Rev142v4/probe.sh . scripts/connect_project.sh          # честная дверь
fixture=tok-quoted-val loc=C expect=otkaz rc=1 calls=0 leak_in_err=0 err=connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «leak.txt», к…
$ env -i … LC_ALL=C bash /tmp/dev-harness-verify/Rev142v4/probe.sh . …/mutants/mut-rfc-shema/scripts/connect_project.sh
fixture=tok-quoted-val loc=C expect=otkaz rc=0 calls=1 leak_in_err=0 err=
```
  - Фикстура `tok-quoted-val`: дом `GIT_URL="https://synth-<rnd>@host.test/p"`, индексируемый `leak.txt` содержит `remote https://synth-<rnd>@host.test/p`.
  - Вывод: мутант проходит всю батарею и запускает workshop при утечке.
  - Повтор пробы мутанта в `LC_ALL=en_US.UTF-8`: `tok-quoted-val rc=0 calls=1`; `tok-https` (без кавычек) — `rc=1 calls=0`. Не зависит от локали.
- **Почему это не принятый остаток.** §Принятые остатки арбитража `contracts-142-impl-v4-arbitraz.md` называют «сужение класса СХЕМЫ (`[^/?#[:space:]]*:` → `[a-z]+:`): для реальных схем не fail-open».
  - Обоснование самого канона v4 прямо закладывает это поведение. В матрице арбитража контракта `verdicts/arbitration/contracts-142-v4-arbitraz.md` есть строка `quoted-token | "https://tok@host" | rc0 | rc1 | rc1 | расширение (кавычка в классе схемы)`. Значит, судимость кавычечного токена — замеренная часть расширения v4, на которую опирается freeze 142/4. В батарее у неё нет ни одной клетки.
  - Посылка опровергнута замером выше: схема реальная (`https`), fail-open на конформной кавычечной форме 125.
  - Слово владельца 28.10 ~20:10 (HANDOFF «28.10 ~22:00») принимает B4 как «зашитый детерминированный sentinel k121/k122», B1 и локале-байты. Этот класс оно не принимает.
- **ЗАКРЫВАЮЩЕЕ СВОЙСТВО.** Батарея краснит субъект, который хранит канон-литерал, но исполняет более узкий класс СХЕМЫ токен-ветви. Минимум — клетки под порождённым адресным именем с утечкой:
  - (а) значение в кавычках `X_URL="https://<tok>@host"`;
  - (б) позиция схемы несёт байты `[^/?#[:space:]]` вне RFC-алфавита, порождённые дополнением (как `ves_klass_tok`);
  - ожидание в каждой клетке: rc 1, `sekret-v-dereve`, 0 workshop, значение в отказе не печатается;
  - `mut-rfc-shema` обязан покраснеть.
- **Адресат:** architect (дверь не меняется). Дверь == модель — проверено ниже.

# СОВЕТ

## R142v4-S1 — непоименованный остаток канона, достижимый на РЕАЛЬНОЙ двери (v3-паритет, к владельцу)

Честная дверь пропускает утечку токена, если перед `//`/схемой стоит обрамление:
- `MIRROR_URL="//synth-<rnd>@host.test/p"`;
- `MIRROR_URL='//synth-<rnd>@host.test/p'`;
- `GIT_URL = https://synth-<rnd>@host.test/p` (пробел вокруг `=`).

Замер: `rc=0 calls=1` в C и en_US.UTF-8; на двери main (v3) — тоже `rc=0 calls=1`. Это не регресс: И-4 соблюдён, матрица ниже.

Причина:
- канон судит сырую строку с якорем `^`;
- кавычка проходит только в позиции схемы (`"https:` ∈ `[^/?#[:space:]]*:`), поэтому `"https://…"` судится, а `"//…"` — нет;
- ведущий пробел не входит ни в один класс.

Где искал: grep по `verdicts/`, `.review/`, контракту и HANDOFF (шаблоны `"//`, `'//`, кавычки перед `//`, ведущий пробел). Форма не названа нигде. Implementer её не починит: И-1 и §Граница implementer. Решение — за владельцем, v+1. Подробности — `.review/2026-10-28-02.md`.

# Сверка (сырые команды, rc, вывод)

Все прогоны выполнялись так:
- клон `/tmp/dev-harness-verify/Rev142v4/repo`, checkout `origin/owner/train-142int`;
- `env -i PATH=/home/harness/.local/bin:/usr/local/bin:/usr/bin:/bin HOME=/tmp/dev-harness-verify/Rev142v4/home`;
- GNU grep 3.11, bash 5.2.21;
- батареи — по одной, синхронно.

## 1. Объект и область

```text
$ git cat-file -t 60824db442c0fa7695a4ede8118c268e4cd84bc0          → commit
$ git rev-parse HEAD origin/main                                     → d13b48b6180ca7e7699df4b489fbc1bd01197663 / 8b25a61cc6d3…
$ git rev-parse 61ab259a:scripts/connect_project.sh HEAD:scripts/connect_project.sh
f6d738a2f314bdec7ed3238966f4b7f82c1e1b29 (оба)
$ git rev-parse 60824db4:fixtures/workshop_project/skaner_sekretov_142 HEAD:fixtures/workshop_project/skaner_sekretov_142
c7376fe2a316cdd741536745f56316c7b8887622 (оба)
$ git diff --name-only origin/main...HEAD     (merge-base 5653f6d5; main с тех пор не трогал дверь/фикстуру/контракт: git diff --quiet 5653f6d5 origin/main -- … rc 0)
architect   (5c2ce59e): ровно 9 файлов в fixtures/workshop_project/skaner_sekretov_142/
implementer (c8a2f357): ровно scripts/connect_project.sh
orchestrator(d13b48b6): ровно .github/workflows/ci.yml registry/ci-steps.tsv registry/ci-zamery.tsv
$ git diff --quiet origin/main..HEAD -- contracts/142-skaner-sekretov.md fixtures/…/model/connect_project.sh   → rc 0
$ git diff --quiet frozen/contracts/142/4 HEAD -- contracts/142-skaner-sekretov.md                            → rc 0
$ sha256sum scripts/connect_project.sh fixtures/workshop_project/skaner_sekretov_142/model/connect_project.sh
e2f5c3945a191c79e26757cb49b87348aad396abc69ebf7c709428716f693504  (оба; модель на origin/main — тот же sha)
$ cmp scripts/connect_project.sh fixtures/…/model/connect_project.sh   → rc 0
$ git diff origin/main..HEAD -- scripts/connect_project.sh             → 1 hunk @@ -302,7 +302,27 @@: −1 строка USERINFO_RE v3, +20 строк комментария-основания, +1 строка канона v4; прочее двери (NUL-блок, пин, трасса, argv, exec, HIT=…xargs -0r grep -lsF…| sed -n 1p) байт-неизменно
```

Примечание: двухточечный `git diff --name-only origin/main..HEAD` даёт 21 файл, потому что main ушёл вперёд (HANDOFF, ROADMAP, вердикты 144). Область меряна трёхточечным diff и `diff-tree` по коммитам.

## 2. Обязательства контракта v4

- Матрица ДО (v3 main) / ПОСЛЕ (v4). Скрипт `/tmp/dev-harness-verify/Rev142v4/matrix.py`. Канон-строки берутся из деревьев через `git show`, не из текста задания. Корпус — 46 099 значений.
```text
RE3 [^/@[:space:]]*:[^/@[:space:]]*@
RE4 (^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)
loc=C           values=46099 judged_v3=16699 judged_v4=17139 v3_not_v4=0 v4_only=440
loc=C.UTF-8     values=46099 judged_v3=16699 judged_v4=17139 v3_not_v4=0 v4_only=440
loc=en_US.UTF-8 values=46099 judged_v3=16699 judged_v4=17139 v3_not_v4=0 v4_only=440
```
  Ни один отказ v3 не стал запуском (И-4). Повтор с другим зерном (4242): 45 991 значение, `v3_not_v4=0` во всех трёх локалях. Строка канона v3 буквально входит в v4 последней альтернативой: `v4.endswith('|'+v3+')')` → True.
- Живое воспроизведение на настоящей двери. Скрипт `/tmp/dev-harness-verify/Rev142v4/probe.sh`. Устройство:
  - mktemp-миры по образцу `mir()`;
  - поддельный HOME;
  - двойник workshop;
  - стаб omp v10.

  `LC_ALL=C`, затем повтор в en_US.UTF-8 — результаты те же:
```text
tok-https      GIT_URL=https://synth-R@host.test/p          rc=1 calls=0 leak_in_err=0 sekret-v-dereve
tok-sr         MIRROR_URL=//synth-R@host.test/p             rc=1 calls=0 leak_in_err=0
userpass       REPO_URL=https://user:pw-R@host.test/p       rc=1 calls=0 leak_in_err=0
pass-hash      DB_URL=postgres://u:p#w-R@host/db            rc=1 calls=0 leak_in_err=0
pass-q         DB_URL=postgres://u:p?w-R@host/db            rc=1 calls=0 leak_in_err=0
sr-userpass    MIRROR_URL=//user:pw-R@host.test/p           rc=1 calls=0 leak_in_err=0
tok-quote      X_URL=https://to"k-R@host.test/p             rc=1 calls=0 leak_in_err=0
tok-dot-pct    X_ENDPOINT=https://t.%~R@host.test/p         rc=1 calls=0 leak_in_err=0
tok-quoted-val GIT_URL="https://synth-R@host.test/p"        rc=1 calls=0 leak_in_err=0
pain           METERING_PROXY_URL=http://127.0.0.1:8787     rc=0 calls=1   (боль 26.10 — запуск, И-3)
pain-lower     metering_proxy_url=http://127.0.0.1:8787     rc=0 calls=1
host-port      DB_HOST/DB_PORT/SVC_NAME                     rc=0 calls=1
nested-q       https://host.test/p?next=https://tok-R@evil  rc=0 calls=1   (k108–k110: вложенный URL не userinfo)
nested-slash   https://host.test/https://tok-R@evil         rc=0 calls=1
nested-hash    https://host.test/p#https://tok-R@evil       rc=0 calls=1
port-q-path    https://host.test:8080/p?x=a@b               rc=0 calls=1   (`/` до `@` рвёт двоеточие-ветвь — ложного отказа нет)
port-q-noslash https://host.test:80?u=a@b                   rc=1 calls=0   (ОБЪЯВЛЕННЫЙ ложный отказ fail-closed: §НЕ ЗАЩИЩАЕТ п.3, k111)
port-frag      https://host.test:80#u=a@b                   rc=1 calls=0   (то же, k112)
mailto         X_ADDR=mailto:admin@x.test                   rc=1 calls=0   (объявлен, §НЕ ЗАЩИЩАЕТ п.2/п.3)
nul            FOO_URL\0=probe-nul-R                        rc=1 calls=0 leak_in_err=0 «sekret-v-dereve: NUL (байт 0x00) в доме секретов …» (И-7, до workshop)
q-sr-token     MIRROR_URL="//synth-R@host.test/p"           rc=0 calls=1   ← R142v4-S1
sq-sr-token    MIRROR_URL='//synth-R@host.test/p'           rc=0 calls=1   ← R142v4-S1
sp-eq-token    GIT_URL = https://synth-R@host.test/p        rc=0 calls=1   ← R142v4-S1
```
  На двери main (v3, sha256 `8076f5b0…`):
  - tok-* — `rc=0 calls=1` (R142-S1 v3: токен без двоеточия не судился);
  - двоеточие-формы, port-q-noslash, port-frag, mailto, nul — `rc=1`;
  - q-sr/sq-sr/sp-eq — `rc=0 calls=1`.

  Значение в отказе не печатается ни в одной фикстуре (`leak_in_err=0`).

## 3. Приёмка и батарея (158/48/251 — меряно своей мерой)

```text
$ python3 (json): osi 158 {K 124, Z 7, F 7, D 5, R 3, N 12}; stab keys 48; bindings 251; висячих привязок 0
  против origin/main: osi 150 / stabs 43 / bind 232; снятых клеток 0; сменённых vid 0; потерянных привязок 0; kanon и model_sha256 те же
$ ls stabs | wc -l → 48
$ bash -n (дверь, раннер, модель, 48 стабов) → все rc 0
$ W                              → s142 subjekt: клеток 158, зелёных 158, красных 0   rc=0  (grep -c ЗЕЛЕНА$ = 158)
$ W --model  LC_ALL=C            → s142 model: клеток 158, зелёных 158, красных 0     rc=0
$ W --model  LC_ALL=C.UTF-8      → s142 model: клеток 158, зелёных 158, красных 0     rc=0
$ W --model  LC_ALL=en_US.UTF-8  → s142 model: клеток 158, зелёных 158, красных 0     rc=0
$ W --stabs                      → s142 model-opora-stabov: клеток 158, зелёных 158, красных 0
                                   s142 stabs: стабов 48, привязок 251, непойманных 0   rc=0  (grep -c ^ПОЙМАН = 251; 146.9 s)
$ W --repo <main-дверь v3>       → s142 repo: клеток 158, зелёных 146, красных 12      rc=1
   красны РОВНО: k99 k100 k101 k107 k114 (6 v4 с r1) · k117 k118 k119 k120 (4 B2) · k121 k122 · r1-kanon-v-subekte
$ P = sessii_125/red_sessii_125.sh → s125 red: зелёных 70, красных 0           rc=0
$ Q = sessii_136/red_sessii_136.sh → sessii_136: клеток 87, зелёных 87, красных 0  rc=0
```

Мутанты я построил сам (`/tmp/dev-harness-verify/Rev142v4/make_mutants.py`), мутантов адверсария не брал. У каждого канон-литерал на месте, исполняемый grep идёт по `USERINFO_TEST_RE`, diff двери — 1 строка добавлена, 1 изменена:
```text
mut-b3                 (^([A-Za-z0-9_.%~!$&'()*+,;=-]+:)?//[…тот же]+@|колон)  → 158/156/2  rc=1  красны РОВНО k121, k122
mut-bez-kavychki       токен-класс [^/?#"[:space:]]                            → 158/156/2  rc=1  РОВНО k121, k122
mut-ascii              токен-класс = печатный ASCII перечислением               → 158/156/2  rc=1  РОВНО k121, k122
mut-colon-bez-kavychki [^/@"[:space:]]*:[^/@"[:space:]]*@                       → 158/157/1  rc=1  РОВНО k123
mut-bez-space          токен-класс [^/?#]+                                      → 158/157/1  rc=1  РОВНО k124
mut-rfc-shema          схема [A-Za-z][A-Za-z0-9+.-]*:                           → 158/158/0  rc=0  ← R142v4-B1
```

Ожидания не подогнаны под реализацию:
- `git log` по `fixtures/…/skaner_sekretov_142/` в поезде — только architect (1 коммит);
- implementer фикстур не касался;
- модель не менялась с freeze: последний коммит модели — architect `e568fe98`, sha пина тот же;
- k121–k123 строятся `ves_klass_tok`/`ves_klass_dvoet` как дополнение запрещённого множества (`seq 1 127` минус перечень байтов канона), а не ручным перечнем;
- implementer `61ab259a` (15:13) лёг раньше усиления батареи `60824db4` (16:13). Батарея усилена против неизменной модели — подгонки под субъект нет.

Счётные утверждения, проверенные иной мерой:
- 158/48/251 — подтверждено (jq/python, `ls | wc -l`, `grep -c ^ПОЙМАН`).
- 12 красных на main — подтверждено.
- В арбитраже разбивка «K 120, Z 7, F 7, D 5, N 12, R 3» даёт в сумме 154 ≠ 158. Факт по дереву — K 124. Это описка в чужом вердикте; на предмет не влияет.

## 4. Остатки

Названы честно:
- B4 — HANDOFF 28.10 ~22:00, вердикт adv krug3.
- B1 — замороженный §НЕ ЗАЩИЩАЕТ (последний пункт), арбитраж Q3, HANDOFF.
- Локале-байты 0x80+ и Unicode-пробелы — арбитраж §Принятые остатки, HANDOFF.
- Позиционные предикаты и N≥128 — арбитраж.
- Неполнота привязок — арбитраж.
- `dubli-klyucha` сверх привязок — задание.

Остаток «сужение класса схемы» назван арбитром с ложной посылкой «не fail-open» — см. R142v4-B1.

Найден пятый, непоименованный и достижимый на реальной двери — R142v4-S1 (совет, v3-паритет).

## 5. Проводка CI 142

```text
$ git show d13b48b6 -- registry/ci-steps.tsv
-step check:skaner-sekretov-142-family-selftest 150 bash …/red_skaner_sekretov_142.sh --stabs
+step check:skaner-sekretov-142-family-selftest 60  bash …/red_skaner_sekretov_142.sh
$ bash scripts/gen_ci_steps.sh --check                                → rc=0
$ bash scripts/check_provodka.sh . contracts/142-skaner-sekretov.md   → rc=0
$ bash scripts/check_charter.sh                                       → «уставных документов: 141 · изменений в них: 359 · с разрешения: 359» rc=0
$ gh pr checks 431 → 16 pass (ap1–ap5, l1–l7 вкл. l5 c check:skaner-sekretov-142-family-selftest, klass, legkij, obshchij, tyazhelyj-itog), vorota skipping; headRefOid d13b48b6180ca7e7699df4b489fbc1bd01197663
```

```text
$ env -i PATH=… HOME=…/Rev142v4/home bash scripts/check_zones.sh .        (последним, 313.1 s)
замороженных контрактов: 141 · объявленных авторов: 5 · коммитов в диапазонах: 36417 · проверено по зонам: 8121
rc=0
```

# Паразитная сложность (050)

- **Канон-строка `USERINFO_RE` (раздута: +токен-ветвь) и её 20-строчный комментарий.**
  - (1) И-1/И-2 v4, слово владельца 28.10.
  - (2) Нового состояния нет.
  - (3) Число совместно меняемых файлов не выросло: source.json, модель, субъект — как прежде.
  - (4) Интерфейс прежний: один `grep -Eq`.
  - (5) Потребитель — r1 и k99–k124.
  - Класс: ESSENTIAL.
- **Функции `ves_klass_tok`/`ves_klass_dvoet`.**
  - (1) Развёртка полного канон-класса — решение арбитра Q1.
  - (2) Состояния нет, только печать.
  - (3) Связаны с каноном неявно: перечень исключённых байтов дублирует классы канона руками (`9|10|11|12|13|32|35|47|58|63|64`). При правке канона его придётся менять вместе.
  - (4) Глубина нормальная.
  - (5) Потребитель — k121–k123.
  - Класс: ESSENTIAL. Ручное дублирование отмечаю наблюдением, не находкой.
- **Семья клеток k117–k124 (одним артефактом).** ESSENTIAL: B2/B3; потребители — строка приёмки `W` и CI.
- **Семья 4 новых стабов и правка двух стабов (`set -u`).** ESSENTIAL: стабы доказывают поимку классов, Н-39. Без правки двух стабов «ПОЙМАН» был артефактом краша — замер арбитра; подтверждаю `W --stabs` 251/251.
- **Строка ci-steps.** Не новая; вес и режим сменены по объявлению. Новых ACCIDENTAL-находок нет.

СВЕРКА-СТАНДАРТОВ: AGENTS.md dev-harness не объявляет ни документа архитектуры, ни стандарта кода (`grep ARCHITECTURE.md|CODING-STANDARDS|стандарт кода` → 0 совпадений). Разделов для сверки нет — неприменимо.

# Что НЕ проверено

- Наблюдение CI-раннера: `gh pr checks` показывает только статусы, логи шага l5 не читались.
- Мутанты адверсария и арбитра не прогонялись; вместо них — собственные, по их описанию.
- `check_spec_ready`/`pre_critic` не запускались — не в задании ревьюера v4.
- Батарея пишет миры в `/tmp/dev-harness-verify/s142/run-XXXX`: путь жёстко зашит в раннере, mktemp удаляются trap'ом. Это вне `Rev142v4/**`, изменить без правки предмета нельзя.
- Поведение на минимальной платформе без `grep -P` — объявленный остаток, не мерялось.
- Push/commit не делались по заданию; вердикт и находки лежат в `/tmp/dev-harness-verify/Rev142v4/`.
