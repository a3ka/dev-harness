FAIL
OBJECT=c973670faf64f9e354031cf602cb5d2b44e98f08
СУД: репо=dev-harness; предмет=211; фаза=реализация; роль=reviewer; вызов=2 (узкий scoped; SANKCIJA консультанта); сессия=Rev211b; модель-факт=anthropic/claude-opus-5-5 (`bash scripts/models_actual.sh --tsv --bind --session Rev211b | cut -f1-3` → `reviewer	anthropic/claude-opus-5-5	allowed`, rc 0); автор Impl211e — implementer (MiniMax), Architect211k; предыдущий=archive/211/reviewer-v1-fail-57d8b8dfeb (FAIL Б-1/Б-2); адверсарий — правило остановки R-0074
КЛАСС=КОДОВЫЙ. Находки: блок 1 (Б-1), совет 1 (С-5), чекбоксы — `.review/2026-11-25-rev211b-1.md`. Остатки С-1…С-4 вызова 1 перечислены ниже, ловец у каждого назван.

# Вердикт reviewer — 211, реализация, вызов 2 (узкий, ремонт r8)

**БЛОКИРУЕТ: Б-1** — инв. 1 (б3) и п.1 задания («необъявленная семантика в дельте»). Ремонт перенёс `LC_ALL=C sort -z` в общий помощник `kontrakt_zapisi` (`scripts/zamok_predmeta.sh:720`). Его второй потребитель, `perechen_kontrakta_raven` (`:875-904`), сверяет перечни O и F попарно (`:890`). Ключ сортировки начинается с mode, поэтому при двух файлах предмета смена одного exec-бита после заморозки (у файла с меньшим sha) снимает удостоверение. r6 на этом входе давал reviewer rc 0 `PUSCHEM`, OBJECT даёт rc 1 `KLASS_RISKA_NET` + `ADVERSARIJ_DO_REVJUERA`. Направление fail-closed: класс не занижается. Но (б3) выполнено, а класс из OBJECT не выдан. Модель-эталон несёт тот же дефект. Простая форма прогнана: 58/0, 208 35/0, оба варианта chmod rc 0.
**СОВЕТ: 1** — С-5: пин st68 `24230d10` не предок OBJECT, а `SDACHA.md` утверждает обратное.

Прежние блоки закрыты. **Б-1 вызова 1** (чтение класса по blob) — да: класс читается по пути (`:756`). Своя мера: 0 расхождений с базой на ASCII-именах (было 28/34/30), D42 и D52 на `211-a^-b.md` дают байты базы. **Б-2 вызова 1** (массивы `sp_*`) — да: массивов нет, сортирует поток, форма «+4/−20» выполнена.

Перепроверил ВСЁ: область правки, сырой вывод, не переписаны ли проверки под код.

## 0. Подготовка

```
pwd → /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t7c429073f/m
git fetch ssh://…/dev-harness.git refs/heads/wip/211/orchestrator-r8 refs/heads/main refs/heads/archive/211/reviewer-v1-fail-57d8b8dfeb refs/heads/archive/211/adversary-v4-fail-c187e3c343 → rc 0
git switch --detach c973670faf64…; git rev-parse HEAD → c973670faf64f9e354031cf602cb5d2b44e98f08
теги '+refs/tags/*:refs/tags/*' → rc 0; git remote add origin … → rc 0; git fetch origin main → rc 0
git rev-parse origin/main = git merge-base origin/main HEAD = 1c5d89e69e7f0a811d07114eeadf05fe429b47ea
TMPDIR — свой каталог на каждый прогон под /tmp/dev-harness-verify/scratch-rev211b/ (удалён перед докладом)
```

## 1. Область правки

```
git diff --name-status 1c5d89e69 HEAD → 73 файла: 72 в fixtures/workshop_project/d52_bootstrap_sudej_211/ + scripts/zamok_predmeta.sh (A 15, M 58)
git log --format='%h %an %cn %s' 1c5d89e69..HEAD (по коммиту: зона файлов):
  c973670fa architect   orchestrator 211 architect-k …        → fixtures/…/d52_bootstrap_sudej_211 (4)
  a0a994692 implementer orchestrator 211 implementer-e …      → scripts/zamok_predmeta.sh (1)
  30fa42897 architect   …-j (7)  2934d634b implementer …-d (1)  d4b95caa0 architect (9)  3a9101448 architect (61)
  cea573e0d implementer …-c (1)  6251a2d1d architect (60)  5cdf6d2f6 implementer …-b (1)  44a092bd2 implementer (1)
git diff --stat 24d8ca7ec HEAD -- scripts/zamok_predmeta.sh fixtures/…/d52_bootstrap_sudej_211/ →
  SDACHA.md 28, probe211.py 94 (+87/−7), source.json 13, stabs/st68-V-klass-po-blob/zamok_predmeta.sh +1835 (A), scripts/zamok_predmeta.sh 63 (+25/−38)
```
Implementer правил только `scripts/zamok_predmeta.sh`, architect — только свою пачку. Контракт, норма, реестры и CI не тронуты. Каждый круг — отдельный коммит.

Дельта production к r6 `24d8ca7ec` (сверена построчно):

| место | что | объявлено |
|---|---|---|
| `:756` | `git cat-file blob "$blob"` → `git show "$obj:$kat/$put"` | да, Б-1 вызова 1 |
| `:723`, `:747`, `:778-779` | массивы `sp_*`, `sk`, второй цикл с разбором ключа и печать в `sort -z` удалены; счётчик `schetchik`; проверка `net_stroki` после цикла | да, Б-2 вызова 1 |
| **`:720`** | **`| LC_ALL=C sort -z` в `kontrakt_zapisi` — помощнике, общем для `klass_riska` и `perechen_kontrakta_raven`** | **для `klass_riska` — да. Эффект на `perechen_kontrakta_raven` не объявлен, его комментарий `:869-871` («mode НЕ входит») стал ложным → Б-1** |
| комментарии `:697-707`, `:736-744` | перенос текста [Б-3] и новый [Б-1 Rev211] | — |

## 2. Сырой вывод (по одной, rc и числа)

`B=bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh`, cwd — корень копии, у каждого прогона свой TMPDIR.

```
B --repo .        → SUBJEKT 211: KLETKI 58 KRASNYH 0                                   RC=0
B --model         → MODEL 211: KLETKI 58 KRASNYH 0                                     RC=0
B --stabs         → MODEL 211: KLETKI 58 KRASNYH 0 / STABY 211: SVJAZI 77 ZHIVYH 0      RC=0
B --sintaksis     → SINTAKSIS OK                                                       RC=0
B --sosed-208     → SUBJEKT 208: KLETKI 35 KRASNYH 0                                   RC=0
B --negativ-208   → NEGATIV 208: KLETKI 35 KRASNYH 2 (r31-review-txt-vperjod, r32-review-vlozhenyj-vperjod) — режим --sosed-208 различает базу без verdikt_put   RC=0
red_zamok_object_predok_208.sh --repo .   → SUBJEKT 208: KLETKI 35 KRASNYH 0           RUN=208 RC=0
red_obryv_167.sh --repo .                 → MERGE separate…other_ref ok                 RUN=167 RC=0
red_pre_judge_leak_185.sh --repo          → clean/dirty/local_fake/missing_harness/missing_harness_local_fake ZELENO   RUN=185 RC=0
red_architecture_process_187.sh --repo .  → CELLS=111 STABS=0 FAILURES=0               RUN=187 RC=0
red_odin_agent_140.sh --model             → MODEL_KLETKI 244 KRASNYH 0                 RUN=140 RC=0
run_battery.sh zamok_predmeta             → итог 4/4 классов закрыто                    RUN=hyg RC=0
bash -n scripts/zamok_predmeta.sh                                                      RUN=bashn RC=0
shellcheck 0.11.0 -S warning (-f gcc): OBJECT — SC1090 :560, SC2034 :1290 (psv2/prol2/pobj2); база 1ec472715 — SC1090 :534, SC2034 :1115 (те же три); r6 — :560, :1303. Строк `In ` 2 = 2 → не хуже базы
bash scripts/pre_critic.sh contracts/211-d52-bootstrap-sudej.md → … проводка красна / сдаточный лист красен / КРИТИК: дверь зелёная   RC_pre=0 (472 с)
bash scripts/check_sdacha.sh "$PWD" contracts/211-d52-bootstrap-sudej.md --run → ОТКАЗ: строка 30: фактический rc=1 ≠ заявленного 0: bash scripts/check_spec_ready.sh . contracts/211-d52-bootstrap-sudej.md   RC_sdacha=1 (288 с, нагрузка)
  повтор изолированно: bash scripts/check_spec_ready.sh . contracts/211-d52-bootstrap-sudej.md (копия) → «спек-гейт 036: проба превысила таймаут» RC_spec=1, load 18.50 — таймаут пробы 60 с (`check_spec_ready.sh:241-243`), не дефект
  повтор в чистом клоне на OBJECT (/tmp/…/rev211b-chist, HEAD c973670fa, status пуст): check_spec_ready → OK RC_spec=0 (load 12.72); check_sdacha --run → СДАЧА: лист зелёный (двери=17 карта=17/17 дельта=3) RC_sdacha=0 (581 с)
bash scripts/gen_ci_steps.sh --check → RC_gen=0; awk '/d52_bootstrap/' registry/ci-steps.tsv | wc -l → 0 (шага 211 нет — С-4)
```

Своя мера чисел, другой командой. `jq '{KLETKI:(.kejsy|length),MUTACII:(.stab_vhod|length),SVJAZI:([.stab_vhod[]|length]|add)}' source.json` → 58/68/77. `find stabs -mindepth 1 -maxdepth 1 -type d | wc -l` → 68. Ключи клеток b01…b58 идут без пропусков. Заявленное в `SDACHA.md` и в задании (58/68/77) совпадает с фактом.

## 3. Закрытие Б-1/Б-2 вызова 1 — своя мера

**Дифференциал `klass_riska`.** Генератор `diff_klass.py`, текст — в §7. Функции `profil_sostoyanie`, `kontrakt_kat`, `kontrakt_zapisi` и `klass_riska` извлекаются из текста каждой версии (`git show <sha>:scripts/zamok_predmeta.sh`). Деревья собираются через `mktree`: режимы 644/755/040000/160000/120000, имена с `^-`, `-`, пробелом, регистром, `.md.md`-близнецами, `~1`, `..`, `@{1}`, `:`, `^{}`, `^!`, кириллицей, `"`, `\`, TAB, LF, плюс шумовые имена. legacy-реестр пишется случайно. Сравнивается пара (rc, stdout) байтами в локалях C и en_US.utf8. Классы миров: ASCII (без симлинков), SIMLINK (ASCII-имена плюс запись 120000), EXOTIC.

```
                      seed 20261125 | seed 7   | seed 11     (700 миров, 1400 прогонов на seed)
r6 24d8ca7ec  ASCII   28/642        | 34/686   | 30/674      ← красный контроль меры (все с «^-»: ASCII_S_IMENEM_^- 28/98, 34/116, 30/100)
OBJECT        ASCII    0/642        |  0/686   |  0/674      ASCII_S_IMENEM_^- 0/98, 0/116, 0/100
OBJECT        SIMLINK 30/122        | 36/128   | 28/106      ← дельта D36 r6 (Adv211 Б-2: 120000 — не канон), ремонт её не трогал
OBJECT        EXOTIC 472/636        | 448/586  | 488/620     ← объявленный остаток «D52/critic строже базы»
NE_STROZHE (OBJECT не neodnoznachno там, где база иное): 12 | 20 | 28 — все EXOTIC: база `net_stroki` (имени не видит), OBJECT читает декларацию. Это остаток вызова 1, закреплённый моделью и клетками b38–b43
```
На ASCII-именах расхождений 0 (было 28/34/30). У симлинка OBJECT всегда даёт `neodnoznachno` (fail-closed). Вне EXOTIC мягче базы OBJECT не бывает.

**Двери целиком** (`troiki.py`; миры строителями `probe211.py`, каждой двери свой мир):
```
D42 reviewer 211-a^-b.md   base   rc=1 stderr='ПРЕДУПРЕЖДЕНИЕ: KLASS_RISKA_NET: … (neodnoznachno); файлы: 211-a^-b.md — …\nОТКАЗ: ADVERSARIJ_DO_REVJUERA: …'
D42 reviewer 211-a^-b.md   model  rc=1 (те же байты)
D42 reviewer 211-a^-b.md   r6     rc=0 stdout='PUSCHEM Rev211 dev-harness/211 (sudja/reviewer)\n' stderr=''
D42 reviewer 211-a^-b.md   object rc=1 (байты базы)
D42 reviewer 211-^-.md     base/model/object rc=1 (байты базы); r6 rc=0 PUSCHEM
D42 reviewer 211-fixture.md  все четыре rc=0 PUSCHEM, stderr ''
D52 critic   211-a^-b.md   base/model/object rc=0 PUSCHEM Crit211 + 'ПРЕДУПРЕЖДЕНИЕ: KLASS_RISKA_NET: … файлы: 211-a^-b.md — …'; r6 rc=0 stderr ''
D52 critic   211-^-.md     то же; 211-fixture.md — все четыре stderr ''
```

**Свои мутанты production.** Корень мутанта — каталог с единственным `scripts/zamok_predmeta.sh`, прогон — штатный `B --repo <корень>`. Каждая замена — одна (кратность якоря 1) и не совпадает с заменами `stabs/`. st68 ставит `cat-file blob "$blob"`, мой m1 — `show "$blob"`.

| мутант | замена | bash -n | rc | красные клетки |
|---|---|---:|---:|---|
| m0-kontrol | — | 0 | 0 | — (58/0) |
| m1-show-blob | `show "$obj:$kat/$put"` → `show "$blob"` | 0 | 1 | b57, b58 |
| m2-sort-bez-LC_ALL | `\| LC_ALL=C sort -z)` → `\| sort -z)` | 0 | 1 | b55 |
| m3-sort-bez-z | `\| LC_ALL=C sort -z)` → `\| LC_ALL=C sort)` | 0 | 1 | b44 b45 b47 b49 b54 b55 |

Порядок D52 и тай-брейк равных ключей сохранены: b44–b56 зелёны на OBJECT, m2/m3 их красят, ASCII-дифференциал 0.

## 4. Не подогнаны ли проверки под код

- **b01–b56 не изменены.** `git diff 24d8ca7ec HEAD -- probe211.py`: +87/−7. Удалены только строки комментария шапки, комментарий `tekst_staba`, строка `zametki` и тело `predupr_neodnoznachno`. В последнем добавлен параметр `fajly=None`, и при умолчании строка побайтно прежняя: `'%s-fixture.md' % subj`. Ожидания прежних клеток не тронуты.
- **b57 и b58 судят поведение, а не текст.** `d42_zhivaja_baza` и `d52_zhivaja_baza` пишут живую дверь базы (`tekst_bazy(BAZA_D52)`) в kontrol-мир и запускают её. Тройка базы сверяется с литералом (`D42_BASE_DRIFT` / `D52_BASE_DRIFT`), и только потом этой тройкой судится субъект. Сверки с текстом скрипта нет.
- **st68 соответствует Н-39.** `git diff HEAD:scripts/zamok_predmeta.sh HEAD:…/stabs/st68-V-klass-po-blob/zamok_predmeta.sh` — одна строка `:756` (`show "$obj:$kat/$put"` → `cat-file blob "$blob"`). Пин `24230d10` несёт blob `65b3a8a8e`, тот же, что у OBJECT и `a0a994692`, то есть это копия починенной production. Привязка задана кодом: `STAB_VHOD['st68-V-klass-po-blob'] = [b57, b58]`, сгенерирована в `source.json`. Пин вне истории OBJECT — С-5.
- **Implementer батарею не трогал, architect не трогал production** (§1).

## 5. Б-1 (этот вызов) — сырой вывод

`mode2.py` — b34 на двух файлах (текст в §7). Миры строятся строителями `probe211.py`. Файлы: `contracts/211-fixture.md` и `contracts/211-zz.md`, оба `КЛАСС РИСКА: обычный`. F — оба 100644, тег `/1` у владельца, строки REPLACE нет. W — chmod 755 одного файла. Вызов reviewer, путь D64.
```
--- chmod 755 211-fixture.md
F: 100644 blob 0b86d5d8f8a5…	211-fixture.md / 100644 blob 424a3fc45a17…	211-zz.md
W: 100755 blob 0b86d5d8f8a5…	211-fixture.md / 100644 blob 424a3fc45a17…	211-zz.md
D64 reviewer base     rc=1 'ПРЕДУПРЕЖДЕНИЕ: KLASS_RISKA_NET: предмет 211: закреплённый frozen недоступен — класс не определён, предмет считается рисковым\nОТКАЗ: ADVERSARIJ_DO_REVJUERA: …'
D64 reviewer r6       rc=0 stdout='PUSCHEM Rev211 dev-harness/211 (sudja/reviewer)\n' stderr=''
D64 reviewer model    rc=1 (те же байты, что base)
D64 reviewer object   rc=1 (те же байты, что base)
D64 reviewer kandidat rc=0
--- chmod 755 211-zz.md
D64 reviewer base rc=1; r6 rc=0; model rc=0; object rc=0; kandidat rc=0
```
Механизм такой. Перечень OBJECT после `sort -z` (`:720`) идёт в порядке `100644 …424a… 211-zz.md`, затем `100755 …0b86… 211-fixture.md`. Перечень F идёт в порядке sha: `0b86…`, затем `424a…`. На `:890` имена первой пары различаются, удостоверения нет, выход — «промах» (инв. 2).

Форма-кандидат (`kandidat.py`). Тело `perechen_kontrakta_raven` (−28 строк) заменено на (+16):
```bash
kontrakt_perechen() {  # <репозиторий> <tree:каталог> <NNN> → «%q имя sha» по строке | rc 1 — запись не обычный файл
  local imya mode tip sha
  while IFS= read -r -d '' imya && IFS= read -r -d '' mode \
        && IFS= read -r -d '' tip && IFS= read -r -d '' sha; do
    [ "$tip" = blob ] || return 1
    { [ "$mode" = 100644 ] || [ "$mode" = 100755 ]; } || return 1
    printf '%q %s\n' "$imya" "$sha"
  done < <(kontrakt_zapisi "$1" "$2" "$3")
}
perechen_kontrakta_raven() {  # <репозиторий> <treeO:каталог> <treeF:каталог> <NNN> → 0 равны | 1 нет
  local spO spF
  spO="$(kontrakt_perechen "$1" "$2" "$4")" || return 1
  spF="$(kontrakt_perechen "$1" "$3" "$4")" || return 1
  [ -n "$spO" ] || return 1
  [ "$(printf '%s\n' "$spO" | LC_ALL=C sort)" = "$(printf '%s\n' "$spF" | LC_ALL=C sort)" ]
}
```
```
bash -n → 0
B --repo /tmp/…/kandidat → SUBJEKT 211: KLETKI 58 KRASNYH 0                RC_211=0
red_zamok_object_predok_208.sh --repo /tmp/…/kandidat → SUBJEKT 208: KLETKI 35 KRASNYH 0   RC_208=0
mode2.py … kandidat → rc 0 в обоих вариантах chmod
```

## 6. Соответствие контракту — только дельта ремонта

| инв. | вывод |
|---|---|
| 1 (D64, б3) | **нарушен на достижимом входе: два файла + mode-only у файла с меньшим sha → Б-1**. Одно файловое b34 зелено |
| 2 (промах — прежнее поведение) | байты промаха равны базе. Сам промах здесь ложный, см. инв. 1 |
| 3 (класс не занижается) | соответствует: `^-` → рисковый на D42 (b57, troiki), дефект Б-1 только fail-closed |
| 4 (critic/D52 как база) | соответствует на ASCII: дифференциал 0, b44–b58 зелёны, D52 `^-` даёт байты базы |
| 5–7 | дельта не трогает: b03/b04/b08/b10–b13/b18/b20/b25 зелёны |
| 8 (регресс A2/208) | соседи зелёные (§2) |

## Регресс

Числа — §2. Все соседи зелёные и совпадают с вызовом 1, кроме роста батареи 211 (56→58 клеток, 75→77 связей, 67→68 стабов). shellcheck: 2 = 2. pre_critic rc 0. check_sdacha --run rc 0 в чистом клоне. Первый прогон дал rc 1 только из-за таймаута пробы под нагрузкой, см. §2.

## Остатки

- **ОСТАТОК «батарея — конечный набор; остаток — судьи» (контракт, НЕ ЗАЩИЩАЕТ; ловец adversary → reviewer) — укусил.** Место — `scripts/zamok_predmeta.sh:720` вместе с `:890` (Б-1): клетки «≥2 файла + mode-only» нет.
- **ОСТАТОК «D52/critic строже базы» (кириллица, `"`, `\`, TAB, LF, симлинк) — не укусил, остаётся.** EXOTIC и SIMLINK — по §3. Направление прежнее: на EXOTIC с единственным не-ASCII-файлом база даёт `net_stroki`, OBJECT читает декларацию (b38–b43, модель).
- **ОСТАТОК «граница risk_repo = носитель» (принята владельцем 23.11, арбитраж 2353d9e0b8 §4) — не укусил.** Дельта ремонта выбор `risk_repo` не трогает.
- **ОСТАТОК «D52 читает профиль и legacy носителя» — не укусил.** b37 зелена.
- **ОСТАТОК «живость тега на origin» (ловец — оркестратор) и «побайтовая форма учёта» (ловец — отдельный предмет)** — дельта их не касается.
- **С-1 вызова 1** (модель берёт вложенный ref `…/211/x/2` как версию, `model:815`). Модель в дельте не менялась, совет в силе. Ловец — architect при правке модели по Б-1.
- **С-2 вызова 1** (пины st58–st67 вне истории OBJECT). В силе и расширен: С-5 (st68). Ловец — architect.
- **С-3 вызова 1** (`perechen_kontrakta_raven` тяжелее формы модели). Простая форма Б-1 закрывает его заодно (−28/+16). Ловец — implementer.
- **С-4 вызова 1** (шага CI 211 нет: `registry/ci-steps.tsv` 0 строк, `gen_ci_steps --check` rc 0). Ловец — оркестратор, шаг 2 последовательности контракта, до ленда.
- **Совет Б-2 вызова 1 «+4/−20» выполнен.** Но в этой форме был изъян: она сортировала общий помощник, из-за этого и возник Б-1. Совет был мой.

## СВЕРКА-СТАНДАРТОВ

н/п: `AGENTS.md` станции документа архитектуры и стандарта кода не объявляет (`awk '/ARCHITECTURE|CODING-STANDARDS/' AGENTS.md | wc -l` → 0).

## СВЕРКА-АРХИТЕКТУРЫ

Размещение не изменилось: дверь в `scripts/`, батарея в своей пачке. Новых зависимостей и писателей нет, новых операций нет. `bindings.json` и `tooling/checks/cli.js` в дереве отсутствуют (`test -e` → rc 1), sourceCanon не объявлен, модель архитектуры пуста, уровень L не применим, `finding new` не заводил. Расширение долга: общий помощник `kontrakt_zapisi` теперь несёт порядок, нужный одному потребителю (Б-1).

## Паразитная сложность (050)

Ответы на (1) свойство / (2) состояние / (3) число файлов при правке свойства / (4) глубина / (5) потребитель:

- production, ремонт `klass_riska`/`kontrakt_zapisi` — (1) инв. 4 (порядок базы) и Б-2; (2) состояние исчезло: массивов нет, поток явный; (3) 2 файла (дверь и модель), как прежде; (4) интерфейс не вырос, `sort` в помощнике; (5) `klass_riska`. **ESSENTIAL**, но размещение сортировки в общем помощнике ломает второго потребителя → Б-1. Простая форма в §5.
- `d42_zhivaja_baza` (`probe211.py`, +46) — (1) инв. 3/8 на пути D42 (Б-1 вызова 1); (2) kontrol-мир в `m.root`, явно; (3) 1; (4) один аргумент `imja`, работа — живая база в двух мирах; (5) b57 в `--repo`. По строению повторяет `d52_zhivaja_baza`, но отличается путём (тег + REPLACE, reviewer, отказ с неизменным учётом). **ESSENTIAL.** Слияние в один помощник с параметром пути — вкусовое, не находка.
- `predupr_neodnoznachno(fajly=None)` — (1) b57: точное имя файла в диагностике; (2) нет; (3) 1; (4) +1 необязательный аргумент, умолчание прежнее; (5) b57. **ESSENTIAL.**
- `BAZA_PRODUCTION_211E`, `PRODUCTION_STABY_211E`, ветвь `tekst_staba` и стаб st68 — (1) К-08: стаб на Б-1 вызова 1; (2) внешний git-объект `24230d10` вне истории OBJECT, неявно → С-5; (3) 3 (`probe211.py`, `source.json`, `stabs/`), их связывает генератор; (4) третий пин-слой; (5) `--stabs`, связи b57/b58. **ESSENTIAL**, пин — совет С-5 (простая форма: пин `a0a994692`).

## Что чинить (порядок)

1. Implementer: Б-1 — `perechen_kontrakta_raven` сверяет перечни независимо от mode (форма §5 проверена; заодно закрывает С-3). `klass_riska` и порядок D52 не трогать.
2. Architect: та же правка в модели (`model:829-831`), клетка D64 «два файла + mode-only у файла с меньшим sha → reviewer rc 0 PUSCHEM» со стабом на неё (копия починенной production с попарной сверкой по mode-сортированному потоку). С-5: перепин st68 на `a0a994692` и исправить фразу в `SDACHA.md`. С-1 — по усмотрению.
3. Повтор: узкий вызов reviewer на дельту.

## НЕ ЗАЩИЩАЕТ (этот вердикт)

- Мутационный поиск адверсария не повторялся. Мутанты m1–m3 нужны только для красного своей мерой.
- `check_zones.sh` целиком не гонялся: зона сверена по автору и путям каждого коммита.
- Живую станцию и настоящее состояние замка не трогал: все прогоны шли в одноразовых мирах под TMPDIR.
- Мобильного экрана в предмете нет. Запись СУД в HANDOFF дописывает оркестратор.

## 7. Генераторы своей меры (тексты, scratch удалён)

`diff_klass.py` — дифференциал §3. Извлекает функции из `git show <sha>:scripts/zamok_predmeta.sh` (от строки `name() {` до первой строки `}`). Строит мир как `git mktree -z --missing` над записями `(mode, tip, sha, имя)` под `contracts/`, затем `commit-tree`. Случайно пишет `registry/risk-legacy.tsv` (blob → класс). Вызов: `bash -c 'source lib; klass_riska 211 "$wt" "$c"'` при `LC_ALL ∈ {C, en_US.utf8}`. Классы миров и счётчик NE_STROZHE — §3. Аргументы: `<корень> <OBJECT> <seed> 700 <мир>`.
`troiki.py` — §3. `mode2.py` — §5: тот же строитель, что у b34 (`nositel` + `kommit_vse` + `stancija_teg`), второй файл `211-zz.md` = `kontrakt_tekst(211,'обычный') + 'второй файл\n'`. `kandidat.py` — подставляет тело из §5 вместо `perechen_kontrakta_raven`. `mutanty.py` — §3, таблица.
