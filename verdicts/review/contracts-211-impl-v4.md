accept
OBJECT=e52c02625e6d85c2bc5a9bacfe98bfae045d9fb8
СУД: репо=dev-harness; предмет=211; фаза=реализация; роль=reviewer; вызов=4 (дополнительный; слово владельца R-0092 п.3; SANKCIJA); сессия=Rev211d; модель-факт=anthropic/claude-opus-5-5 (`bash scripts/models_actual.sh --tsv --bind --session Rev211d` → `reviewer	anthropic/claude-opus-5-5	allowed	Rev211d	e52c02625e6d85c2bc5a9bacfe98bfae045d9fb8`, rc 0); автор Architect211m — gpt-6.1-sol; предыдущий=archive/211/reviewer-v3-fail-53f442a625; арбитраж=archive/211/arbiter-v1-8eca3f7e23; адверсарий — правило остановки R-0074
КЛАСС=КОДОВЫЙ. Суд УЗКИЙ: дельта `10f6ad777c95121d344198696679597409ac8a8a..e52c02625e6d85c2bc5a9bacfe98bfae045d9fb8` (граница арбитража `211-granica-posle-rev211c.md` §4). Находки: блоков 0, советов 0; `.review/` не заводил — чинить в дельте нечего.

# Вердикт reviewer — 211, реализация, вызов 4 (узкий контроль исполнения способа X)

**БЛОКИРУЕТ: нет**

**СОВЕТ: 0**

**Б-1 вызова 3 закрыт.** Четыре пина production-слоёв стабов (`probe211.py:85-88`, `source.json:7-10`) перенесены на предков OBJECT с тем же blob `scripts/zamok_predmeta.sh`. В чистом клоне только с origin старых r9-объектов нет (`cat-file -e` rc 1), а `--stabs` даёт rc 0 и `SVJAZI 78 ZHIVYH 0`. Новый страж `piny_sverka` (`probe211.py:1788-1805`) проверяет предковость настоящим `git merge-base --is-ancestor <литерал> HEAD`, а не по имени. Его вызов стоит в `main()` до `--repo`/`--model`/`--stabs` (`probe211.py:1915`). Своя мера показала: без вызова стража ловушка Б-1 (существующий непредок с тем же blob) зелёная, со стражем — rc 2 `PIN_NE_PREDOK_HEAD` (§3, R2/R2b). Production, контракт, реестры, CI, клетки b01–b59, стабы st01–st69, модель и обёртка не тронуты.

Перепроверил ВСЁ: область правки, сырой вывод, не переписаны ли проверки под код.

## 0. Подготовка

```
pwd → /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t17416d3c0/m
git fetch ssh://…/dev-harness.git refs/heads/wip/211/orchestrator-r11 refs/heads/main refs/heads/archive/211/arbiter-v1-8eca3f7e23 refs/heads/archive/211/reviewer-v3-fail-53f442a625 refs/heads/archive/211/reviewer-v2-fail-12ea23adb1 '+refs/tags/*:refs/tags/*' → rc 0
git switch --detach e52c02625e6d…; git rev-parse HEAD → e52c02625e6d85c2bc5a9bacfe98bfae045d9fb8
git remote add origin ssh://git@github.com/a3ka/dev-harness.git → rc 0
git merge-base --is-ancestor 10f6ad777 e52c02625 → rc 0
TMPDIR=/tmp/dev-harness-verify/scratch-rev211d (удалён перед докладом)
```
Чистые клоны (удалены перед докладом), alternates нет ни в одном:
```
git clone -q --single-branch --branch wip/211/orchestrator-r11 --no-tags ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/rev211d-clean
  HEAD → e52c02625e6d85c2bc5a9bacfe98bfae045d9fb8; .git/objects/info/alternates — нет
  8c50b4c67… cat-file-e=1 inrevlist=0
  21aafbe4e… cat-file-e=1 inrevlist=0
  1a239b49a… cat-file-e=1 inrevlist=0
  bc303e9ae… cat-file-e=1 inrevlist=0
git clone --no-local --no-hardlinks <rev211d-clean> /tmp/dev-harness-verify/rev211d-guard   (для стража и мутантов, чтобы не гоняться с батареей)
```

## 1. Область правки

```
git diff --name-status 10f6ad777 e52c02625
M	fixtures/workshop_project/d52_bootstrap_sudej_211/SDACHA.md
A	fixtures/workshop_project/d52_bootstrap_sudej_211/check_piny211.py
M	fixtures/workshop_project/d52_bootstrap_sudej_211/probe211.py
M	fixtures/workshop_project/d52_bootstrap_sudej_211/source.json
git diff --numstat: 19/14 SDACHA.md, 52/0 check_piny211.py, 33/11 probe211.py, 5/5 source.json → +109/−30
git diff --stat 10f6ad777 e52c02625 -- scripts contracts registry .github → пусто, rc 0
git diff --quiet 10f6ad777 e52c02625 -- …/stabs …/model …/red_d52_bootstrap_sudej_211.sh → rc 0
git log 10f6ad777..e52c02625:
  e52c02625… architect <architect@dev-harness.local> | 211: use executable form accepted by delivery sheet gate
  ae4cdaa6d… architect <architect@dev-harness.local> | 211: pin fixture layers to r10 ancestors and guard pin history
```
Оба коммита — architect, только своя пачка семьи 211. Каждый коммит отдельный и ссылается на предмет. `e52c02625` меняет одну строку листа: команда двери «Piny» `python3 …/check_piny211.py` → `…/check_piny211.py`. Файл в дереве `100755`, shebang `#!/usr/bin/env python3`, и прямой запуск в чистом клоне дал rc 0 (§3). Соседи не затронуты, дельта есть только в фикстуре 211. Вне зоны ничего нет.

## 2. Закрытие Б-1 — своя мера

**Пары «старый → новый пин», blob `scripts/zamok_predmeta.sh`** (`git rev-parse <sha>:scripts/zamok_predmeta.sh` в рабочей копии, где старые r9-объекты ещё есть; `merge-base --is-ancestor <sha> OBJECT`):
```
old=8c50b4c67 blob=8c3d1b966981e79d03b6d177fa84bd60f7107f00 anc_old=1 | new=5131664ec blob=8c3d1b966981e79d03b6d177fa84bd60f7107f00 anc_new=0 | eq=YES
old=21aafbe4e blob=d1a66c35f48099e3984d5ed073060419c8998617 anc_old=1 | new=23bdfb3ba blob=d1a66c35f48099e3984d5ed073060419c8998617 anc_new=0 | eq=YES
old=1a239b49a blob=65b3a8a8ef80daebc11c9d2cf624ba53d38777b2 anc_old=1 | new=07cd89297 blob=65b3a8a8ef80daebc11c9d2cf624ba53d38777b2 anc_new=0 | eq=YES
old=bc303e9ae blob=8539b8d4b314033f5bf7fb3a9d94f19eb9ff1b55 anc_old=1 | new=51665ada0 blob=8539b8d4b314033f5bf7fb3a9d94f19eb9ff1b55 anc_new=0 | eq=YES
```

**Все sha-литералы фикстуры.** Мера другая, чем у стража: `git grep -ohE '[0-9a-f]{40,}' OBJECT -- fixtures/…/d52_bootstrap_sudej_211`, длина ровно 40, `sort -u`, затем `merge-base --is-ancestor`:
```
07cd89297dbd4b8d96efc044289d7a65b3f9d2dd anc=0
1ec47271534b8c468611ce26a7769eaeec298644 anc=0
23bdfb3ba26de5d4c880c734aa5f65d7bf6254b1 anc=0
5131664ec3cad043489ec6b3923c1e8a6716c559 anc=0
51665ada0935c0d4bbacc46b03cc57e1fa5d295c anc=0
длины совпадений [0-9a-fA-F]{40,}: 12 × 40, 70 × 64 (SHA-256 носителей); 40-hex с A–F: 0
```
5 различных литералов, все предки OBJECT. Своё число (5) равно счёту стража `PINY 211: PREDKOV 5`. Потребители пинов в коде — ровно 5 констант `BAZA_D52`, `BAZA_PRODUCTION`, `_211D`, `_211E`, `_211F` (`probe211.py:84-88`, `tekst_bazy` `:1044,:1107,:1174,:1604-1609`). Все пять входят в проверяемый набор.

**Чистый клон только с origin, `B --stabs`:**
```
MODEL 211: KLETKI 59 KRASNYH 0
STABY 211: SVJAZI 78 ZHIVYH 0
real 0m30.383s
STABS rc=0
```

**Страж прочитан целиком** (`check_piny211.py` 1–52, `probe211.py:1788-1805`, `:1915`):
- Сравнение настоящее: `git merge-base --is-ancestor <sha> HEAD` с `cwd=KOREN` для каждого литерала. По имени ничего не сравнивается.
- Набор — каждый самостоятельный `[0-9a-f]{40}` (lookaround отсекает 64-hex SHA-256) во всех файлах семьи с суффиксами `.py/.sh/.json/.md`. Других суффиксов в семье нет (glob: 69 `stabs/*/zamok_predmeta.sh`, `model/zamok_predmeta.sh`, `probe211.py`, `check_piny211.py`, `red_….sh`, `source.json`, `SDACHA.md`).
- Пустой набор → rc 2 `PINY_PUSTO`.
- Флагов-обходов нет. В `argparse` нет `--no-*`, env `probe211.py` не читает (единственный `os.environ` — копия в `GIT_ENV`, `:101`). Обёртка `red_….sh` только `exec python3 probe211.py "$@"`. Режимы, пропускающие страж (`--sintaksis`, `--sosed-208`, `--negativ-208`, `--sgeneriruj-staby`), пины не потребляют. Генератор, записавший стабы из непредка, ловится следующим `--stabs` (стабы и `nositeli`).
- Негативы `check_piny211.py` запускают настоящий `red_….sh --stabs` и требуют точную тройку `(2, b'', b'ORACLE_TAMPERED: PIN_NE_PREDOK_HEAD: <pin>\n')`. Непредок строится `commit-tree` из `HEAD^{tree}`, и скрипт проверяет `is-ancestor` rc 1 и равенство двери с HEAD. Поэтому красит именно предковость, а не отсутствие содержимого. Временный файл удаляется в `finally`.

## 3. Красное предъявлено — своя мера (`red211d.sh`, одноразовый клон `rev211d-guard`)

Свой непредок построен иначе, чем у автора: дерево пина `51665ada0^{tree}` с родителем `10f6ad777`.
```
BOK=d31a7a98d55906c6e79f36d3dbf0faac744677fc
BOK is-ancestor rc=1
BOK blob=8539b8d4b314033f5bf7fb3a9d94f19eb9ff1b55 NEW blob=8539b8d4b314033f5bf7fb3a9d94f19eb9ff1b55
== R1 r9-пины --stabs: rc=2
   stdout: 
   stderr: ORACLE_TAMPERED: PIN_NE_PREDOK_HEAD: 1a239b49a5e36fb81281e0678ffbc43713910d25|
== R1 r9-пины --repo .: rc=2
   stdout: 
   stderr: ORACLE_TAMPERED: PIN_NE_PREDOK_HEAD: 1a239b49a5e36fb81281e0678ffbc43713910d25|
== R2 непредок-тот-же-blob --stabs (страж на месте): rc=2
   stdout: 
   stderr: ORACLE_TAMPERED: PIN_NE_PREDOK_HEAD: d31a7a98d55906c6e79f36d3dbf0faac744677fc|
== R2b непредок, БЕЗ вызова piny_sverka --stabs: rc=0
   stdout: MODEL 211: KLETKI 59 KRASNYH 0|STABY 211: SVJAZI 78 ZHIVYH 0|
   stderr: 
== R3 непредок только в SDACHA.md --model: rc=2
   stdout: 
   stderr: ORACLE_TAMPERED: PIN_NE_PREDOK_HEAD: d31a7a98d55906c6e79f36d3dbf0faac744677fc|
== R4 пустой набор: rc=2
   stdout: 
   stderr: ORACLE_TAMPERED: PINY_PUSTO|
== R5a непредок ВЕРХНИМ регистром --stabs: rc=0
   stdout: MODEL 211: KLETKI 59 KRASNYH 0|STABY 211: SVJAZI 78 ZHIVYH 0|
   stderr: 
== R5b непредок сокращённым sha --stabs: rc=0
   stdout: MODEL 211: KLETKI 59 KRASNYH 0|STABY 211: SVJAZI 78 ZHIVYH 0|
   stderr: 
итог: porcelain после восстановления выше пуст
```
- **R1** — состояние Б-1 вызова 3 (старые r9-пины) в чистом клоне. Теперь rc 2 даёт страж до любой клетки, и на `--stabs`, и на `--repo`.
- **R2/R2b** — ловушка Б-1: объект есть, но не предок, и blob тот же. Со стражем rc 2. Без единственной строки вызова `piny_sverka()` — rc 0 и 78/0. Значит, красит именно этот барьер, а не «любой вызванный скрипт».
- **R3** — литерал только в прозе листа тоже судится.
- **R5** — не находка дельты. Верхний регистр и сокращённый sha вне набора стража: если объект в копии есть, батарея зелёная. Это ровно остаток, названный арбитражем («страж пинов не универсальный анализатор … сокращённых ссылок или иных будущих форматов; ловец — reviewer дельты пин-слоя, CI чистого клона через --stabs», «расширять механизм … сейчас не требуется»). Нынешние пять пинов полные и в нижнем регистре (§2). В чистом клоне непредок недоступен в любой форме, и `tekst_bazy` даёт rc 2 (как в Б-1 вызова 3). Замер подтверждает границу остатка, но не нарушает обязательство на достижимом состоянии.

Страж автора — прямым запуском по форме листа, в чистом клоне:
```
fixtures/workshop_project/d52_bootstrap_sudej_211/check_piny211.py
PINY NEGATIV net-obekta: rc=2 stdout=b'' stderr=b'ORACLE_TAMPERED: PIN_NE_PREDOK_HEAD: 0000000000000000000000000000000000000000\n'
PINY NEGATIV est-obekt-ne-predok: rc=2 stdout=b'' stderr=b'ORACLE_TAMPERED: PIN_NE_PREDOK_HEAD: 2785aa132787ccc1ebcf03c8c8ad391aa7cf2804\n'
PINY 211: PREDKOV 5 NEGATIVOV 2
real 0m1.151s
PINY rc=0
git status --porcelain → пусто
```

## 4. Не подогнаны ли проверки под код

- `git diff 10f6ad777 e52c02625 -- probe211.py`: все удалённые строки (11) содержат sha. Это 4 константы пинов, 3 строки заголовка и 4 строки `zametki` генератора. `grep -E '^-[^-]' | grep -vE '[0-9a-f]{9}'` → пусто, rc 1. Тела клеток, ожидания, `STAB_MUTACII`/`STAB_VHOD`, якоря не менялись. Добавлены `import re`, `piny_sverka` и её вызов.
- `source.json`: изменены только 4 пина и `zametki`. `kejsy`, `stab_vhod` и `nositeli` (SHA-256 стабов) прежние, потому что blob пинов тот же и тексты стабов побайтно прежние.
- `stabs/`, `model/`, обёртка: `git diff --quiet` rc 0.
- Implementer дельту не трогал, architect не трогал production (§1).

## 5. Регресс (rc / числа)

`B=bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh`, cwd — чистый клон `rev211d-clean` (только origin, HEAD=OBJECT), TMPDIR — scratch:
```
B --repo .       → SUBJEKT 211: KLETKI 59 KRASNYH 0                                     REPO rc=0      (real 0m13.820s)
B --model        → MODEL 211: KLETKI 59 KRASNYH 0                                       MODEL rc=0     (real 0m13.826s)
B --stabs        → MODEL 211: KLETKI 59 KRASNYH 0 / STABY 211: SVJAZI 78 ZHIVYH 0       STABS rc=0     (real 0m30.383s)
B --sintaksis    → SINTAKSIS OK                                                         SINTAKSIS rc=0
B --sosed-208    → SUBJEKT 208: KLETKI 35 KRASNYH 0                                     SOSED rc=0
B --negativ-208  → NEGATIV 208: KLETKI 35 KRASNYH 2 (r31-review-txt-vperjod, r32-review-vlozhenyj-vperjod) — режим --sosed-208 различает базу без verdikt_put   NEGATIV rc=0
```
**Своя мера чисел, другой командой.** Счёт по `source.json`: `jq '{KLETKI:(.kejsy|length),MUTACII:(.stab_vhod|length),SVJAZI:([.stab_vhod[]|length]|add)}'` → 59/69/78. Счёт по коду (импорт `probe211`): `KLETKI(kod) 59 MUTACII(kod) 69 SVJAZI(kod) 78 pervaja b01-bootstrap-adversary poslednjaja b59-d64-dva-fajla-mode-menshego-sha`, `PINY(kod) 5`. Каталогов `stabs/*/` — 69 (glob). Заявленное (59/69/78, 5 предков, 2 негатива) совпадает с фактом.

**Ворота:**
```
Q в рабочей копии (полный реестр тегов после fetch подготовки):
  bash scripts/check_precision_gate.sh "$PWD" contracts/211-d52-bootstrap-sudej.md → OK   PRECISION rc=0 (real 0m15.762s; load 6.85 → 7.75)
В чистом клоне rev211d-clean после `git fetch origin '+refs/heads/main:refs/remotes/origin/main' '+refs/tags/*:refs/tags/*'` (HEAD=OBJECT, porcelain пуст, не shallow; VALIDATE_STD_SHELLCHECK=…/shellcheck/0.11.0/shellcheck):
  R  bash scripts/check_spec_ready.sh . contracts/211-d52-bootstrap-sudej.md → OK   SPEC rc=0 (real 0m58.655s — у предела 60 с пробы 036; load 8.73 → 9.11)
  Q  bash scripts/check_precision_gate.sh . contracts/211-d52-bootstrap-sudej.md → OK   PRECISION_clean rc=0 (real 0m21.468s)
  S  SDACHA_TIMEOUT_SEK=600 SDACHA_BUDZHET_SEK=2400 bash scripts/check_sdacha.sh "$PWD" contracts/211-d52-bootstrap-sudej.md --run
     → СДАЧА: лист зелёный (двери=18 карта=17/17 дельта=3)   SDACHA rc=0 (real 7m9.342s; load 9.59 → 8.72)
  P  bash scripts/pre_critic.sh contracts/211-d52-bootstrap-sudej.md
       ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=1
       ok   гейт трека: 
       ok   модель угроз красна
       ok   потолки красны
       ok   проводка красна
       ok   сдаточный лист красен
     КРИТИК: дверь зелёная   PRE_CRITIC rc=0 (real 8m0.397s; load 8.66 → 8.81)
  git status --porcelain после S и P → пусто
```

## 6. Остатки

- **С-1** (модель берёт вложенный ref `frozen/contracts/211/x/2` как версию; `model/zamok_predmeta.sh`, production отсекает весь нечисловой хвост). Вне дельты, модель не менялась (`git diff --quiet … model` rc 0). Ловец — reviewer при изменении грамматики версии/модели, адресную клетку готовит architect. Не блок.
- **С-4** (шага CI 211 нет). Ловец — оркестратор: шаг 2 последовательности после accept, `gen_ci_steps.sh --write`, до ленда `--stabs`. Не блок этой дельты, но обязательство до ленда/done (арбитраж §Конечная граница п.4). Предпосылка для шага проверена: CI-checkout везде `fetch-depth: 0` (`.github/workflows/ci.yml:51,69,88,198,248,290`), а main принимает PR merge-коммитами (`git log --first-parent main`: «Merge pull request #1388/#1380/#1384…»). Пины-предки останутся предками и после ленда, `piny_sverka` перед `--repo` в безфлаговом шаге не покраснеет.
- **Остаток арбитража «страж не универсальный анализатор»** — замером R5 подтверждён ровно в названной границе (верхний регистр/сокращённый sha вне набора). Ловец — reviewer дельты пин-слоя и CI чистого клона через `--stabs`. Не блок.
- **Owner-аттестат adversary (R-0074)** — консультант, после этого accept, на тот же OBJECT.
- **Ворота P/S/Q/R** на этом OBJECT в чистом origin-клоне с полным реестром тегов зелёные (§5): `missing-remote` арбитража снят полным fetch тегов. Спек-проба 036 прошла за 58.7 с, у самого предела 60 с; под нагрузкой станции она может снова упасть по таймауту. Это не дефект предмета, ловец — оркестратор: повторить прогон изолированно, предел не повышать. Финальный прогон ворот перед лендом — за оркестратором (на ветке с вердиктом).

## СВЕРКА-СТАНДАРТОВ

н/п: `AGENTS.md` станции документа архитектуры и стандарта кода не объявляет (как в вызове 3). Дельта — Python-фикстура и лист сдачи, shell не менялся.

## СВЕРКА-АРХИТЕКТУРЫ

Размещение прежнее: всё в пачке `fixtures/workshop_project/d52_bootstrap_sudej_211/`. Новых зависимостей нет (`re` — stdlib; `git merge-base` уже применялся станцией). Писателей и операций production нет. `check_piny211.py` пишет временный файл в каталог семьи (удаляется в `finally`) и висячий объект `commit-tree` в `.git` корня запуска; ни один ref не двигается. `bindings.json` и `tooling/checks/cli.js` в дереве отсутствуют. sourceCanon не объявлен, модель архитектуры пуста, уровень L не применим, `finding new` не заводил. Долг не расширен.

## Паразитная сложность (050)

Ответы на (1) свойство / (2) состояние / (3) число файлов при правке свойства / (4) глубина / (5) потребитель:

- **`piny_sverka` + вызов в `main()`** (+21). (1) Строка приёмки `--stabs` rc 0 в чистом origin-клоне (Б-1 вызова 3; §Приёмка контракта). (2) Состояния нет, решение видно в rc 2 и stderr `PIN_NE_PREDOK_HEAD: <sha>`/`PINY_PUSTO`. (3) При следующем перепине меняются те же `probe211.py` и `source.json` (генерируется), и страж не прибавляет совместно меняемых файлов. (4) Без аргументов, один код отказа, работа — обход всех литералов семьи. (5) `--repo`/`--model`/`--stabs`, двери листа Red-do/Model/Stabs, будущий шаг CI. Более простой формы того же свойства нет: без стража ловушка зелёная (R2b). **ESSENTIAL.**
- **`check_piny211.py`** (+52). (1) Красное нового барьера (норма reviewer п.4) и дверь листа «Piny». (2) Временный файл `pin211-*.json` (удаляется в `finally`, видно в коде) и висячий commit-объект — побочный эффект, в выводе он виден как sha в stderr негатива. (3) 1 файл. (4) Без аргументов, rc 0/assert. (5) Дверь «Piny» в `SDACHA.md` (`check_sdacha --run`). **ESSENTIAL.**
- **Строка листа «Piny»** и правка формы команды (`e52c02625`). (1) Исполнимость двери листа. (2) Нет. (3) 1. (5) `check_sdacha`. Нейтрально.

## НЕ ЗАЩИЩАЕТ (этот вердикт)

- Production-суд вызова 3 (Rev211c принял дельту production) не повторялся: production в дельте не менялась (`git diff … -- scripts` пуст).
- Мутационный поиск адверсария не повторялся. R1–R5 — только красное стража своей мерой.
- Живую станцию и настоящее состояние замка не трогал: все прогоны батареи и стража шли в одноразовых клонах с собственным `.git`, миры — под TMPDIR. Precision-гейт в рабочей копии — только чтение.
- Мобильного экрана в предмете нет. Запись СУД в HANDOFF дописывает оркестратор.
